"""
XODE Importer for PyODE
"""

import ode
import math
import xml.parsers.expat

class AncestorNotFoundError(Exception):
    """
    Raised when an ancestor represeting an ODE object of some type was not
    found in the tree.

    @ivar type: The object type.
    @type type: class
    """
    
    def __init__(self, type):
        self.type = type
        
    def __str__(self):
        return "<AncestorNotFoundException: " \
               "No ancestor with type %s found.>" % repr(self.type.__name__)

class InvalidError(Exception):
    """
    Raised when an XODE document is invalid.
    """

class Parser:
    """
    An XODE parser.
    """

    def _nullHandler(self, *args, **kwargs):
        return

    def push(self, startElement=None, endElement=None):
        self._handlers.append({'startElement': self._expat.StartElementHandler,
                               'endElement': self._expat.EndElementHandler})
        
        self._expat.StartElementHandler = startElement or self._nullHandler
        self._expat.EndElementHandler = endElement or self._nullHandler

    def pop(self):
        top = self._handlers.pop()
        self._expat.StartElementHandler = top['startElement']
        self._expat.EndElementHandler = top['endElement']

    def _create(self):
        """
        Creates an expat parser.
        """

        self._handlers = []
        self._expat = xml.parsers.expat.ParserCreate()

        self._expat.StartElementHandler = self._nullHandler
        self._expat.EndElementHandler = self._nullHandler

        self.push(self._startElement)
        
        return self._expat

    def _startElement(self, name, attrs):
        if (name == 'xode'):
            self._root = Root(None, None)
            self._root.takeParser(self)
        else:
            raise InvalidError('Root element must be <xode>.')

    def parseString(self, xml):
        """
        Parses the given string.

        @param xml: The string to parse.
        @type xml: str

        @return: The root container.
        @rtype: instance of Container

        @raise InvalidException: The document is invalid.
        """

        self._create().Parse(xml, 1)
        return self._root

    def parseFile(self, fp):
        """
        Parses the given file.

        @param fp: A file-like object.
        @type fp: file-like instance

        @return: The root container.
        @rtype: instance of Container

        @raise InvalidException: The document is invalid.
        """

        self._create().ParseFile(fp)
        return self._root

class Transform:
    """
    A matrix transform.
    """

    def __init__(self):
        self.m = [[0, 0, 0, 0],
                  [0, 0, 0, 0],
                  [0, 0, 0, 0],
                  [0, 0, 0, 0]]
        self.setIdentity()

    def takeParser(self, parser, node, attrs):
        self._scale = float(attrs.get('scale', 1.0))
        self._node = node
        self._parser = parser
        self._parser.push(startElement=self._startElement,
                          endElement=self._endElement)

    def _startElement(self, name, attrs):
        if (name == 'matrix4f'):
            self.setIdentity()
            for r in range(4):
                for c in range(4):
                    self.m[r][c] = float(attrs['m%i%i' % (r, c)])
        elif (name == 'position'):
            self.translate(float(attrs['x']),
                           float(attrs['y']),
                           float(attrs['z']))
        elif (name == 'euler'):
            coeff = 1
            if (attrs.get('aformat', 'radians') == 'degrees'):
                coeff = math.pi/180

            x = coeff * float(attrs['x'])
            y = coeff * float(attrs['y'])
            z = coeff * float(attrs['z'])
            
            self.rotate(x, y, z)

    def _endElement(self, name):
        if (name == 'transform'):
            self.scale(self._scale, self._scale, self._scale)
            self._node.setNodeTransform(self)
            self._parser.pop()

    def setIdentity(self):
        for r in range(4):
            for c in range(4):
                self.m[r][c] = 0
        
        for i in range(4):
            self.m[i][i] = 1

    def translate(self, x, y, z):
        t = Transform()
        t.m[3][0] = x
        t.m[3][1] = y
        t.m[3][2] = z

        r = self * t;
        self.m = r.m

    def scale(self, x, y, z):
        t = Transform()
        t.m[0][0] = x
        t.m[1][1] = y
        t.m[2][2] = z

        r = self * t
        self.m = r.m

    def rotate(self, x, y, z):
        rx = Transform()
        rx.m[1][1] = math.cos(x)
        rx.m[1][2] = math.sin(x)
        rx.m[2][1] = -math.sin(x)
        rx.m[2][2] = math.cos(x)

        ry = Transform()
        ry.m[0][0] = math.cos(x)
        ry.m[0][2] = -math.sin(x)
        ry.m[2][0] = math.sin(x)
        ry.m[2][2] = math.cos(x)

        rz = Transform()
        rz.m[0][0] = math.cos(z)
        rz.m[0][1] = math.sin(z)
        rz.m[1][0] = -math.sin(z)
        rz.m[1][1] = math.cos(z)

        r = self * rz * ry * rz
        self.m = r.m

    def getPosition(self):
        return self.m[3][0], self.m[3][1], self.m[3][2]

    def getRotation(self):
        return self.m[0][0], self.m[0][1], self.m[0][2], \
               self.m[1][0], self.m[1][1], self.m[1][2], \
               self.m[2][0], self.m[2][1], self.m[2][2]

    def __mul__(self, t2):
        ret = Transform()
        
        for row in range(4):
            for col in range(4):
                part = 0
                for i in range(4):
                    part = part + self.m[row][i] * t2.m[i][col]
                ret.m[row][col] = part

        return ret

class TreeNode:
    """
    A collection of ODE objects.
    """

    def __init__(self, name, parent):
        """
        Initialises this. If the parent is not None, parent.addChild() is
        called.

        @param name: The name of this container or None if there is none.
        @type name: str

        @param parent: The parent of this node or None.
        @type parent: instance or None
        """

        self._name = name
        self._parent = parent
        self._obj = None
        self._transform = Transform()
        
        self._childs = []
        self._namedChild = {}

        if (self._parent is not None):
            self._parent.addChild(self, name)

    def takeParser(self, parser):
        """
        Called to make this node handle further parsing. It will release the
        parser when it has finished.

        @param parser: The C{Parser}
        @type parser: instance of Parser
        """

    def setODEObject(self, obj):
        """
        Sets the ODE object represented by this node.

        @param obj: The ODE object.
        @type obj: instance
        """

        self._obj = obj

    def getODEObject(self):
        """
        @return: The ODE object represented by this node or None if this node
        does not represent an ODE object.
        @rtype: instance
        """

        return self._obj

    def setNodeTransform(self, transform):
        """
        @param transform: This node's transform.
        @type transform: instance of Transform
        """

        self._transform = transform

    def getNodeTransform(self):
        """
        @return: The transform of this node.
        @rtype: instance of Transform
        """

        return self._transform

    def getTransform(self):
        """
        @return: The absolute transform at this node.
        @rtype: instance of Transform
        """

        p = self.getParent()
        t = self.getNodeTransform()

        if (p is not None):
            return p.getTransform() * t
        else:
            return t

    def getName(self):
        """
        @return: This container's name, if there it is named, or None if not.
        @rtype: str or None
        """

        return self._name

    def getChildren(self):
        """
        @return: The list of child objects.
        @rtype: list
        """

        return self._childs

    def namedChild(self, name):
        """
        Retrieves a named child object. If no child by that name is found
        in this container, all the child containers will be searched
        recursively until either something is found or everything has been
        searched.

        @param name: The name of the object.
        @type name: str
        
        @return: The object.
        @rtype: instance

        @raise KeyError: No object or container with the given name was found.
        """

        if (self._namedChild.has_key(name)):
            return self._namedChild[name]
        else:
            for child in self._childs:
                if (isinstance(child, TreeNode)):
                    try:
                        obj = child.namedChild(name)
                    except KeyError:
                        pass
                    else:
                        return obj

        raise KeyError("Could not find child named '%s'." % name)

    def addChild(self, child, name):
        """
        Adds a child object.

        @param child: The child object.
        @type child: instance

        @param name: The child's name or None.
        @type name: str or None
        """

        if (name is not None):
            self._namedChild[name] = child

        self._childs.append(child)

    def getParent(self):
        """
        @return: The parent of this container or None if this is the root
        container.
        @rtype: instance of Container
        """

        return self._parent

    def getFirstAncestor(self, type):
        """
        Find the first ancestor that represents an ODE object of the specified
        type.

        @param type: The ODE type.
        @type type: class

        @return: The ancestor TreeNode.
        @rtype: instance of TreeNode

        @raise AncestorNotFoundError: Raised when no ancestor was found.
        """

        parent = self.getParent()
        if (parent is not None):
            if (isinstance(parent.getODEObject(), type)):
                return parent
            else:
                return parent.getFirstAncestor(type)
        else:
            raise AncestorNotFoundError(type)

    def getRoot(self):
        """
        Finds the root node.

        @return: The root node.
        @rtype: instance of TreeNode
        """

        if (self.getParent() is None):
            return self
        else:
            return self.getParent().getRoot()

class Root(TreeNode):

    def takeParser(self, parser):
        self._parser = parser
        self._parser.push(startElement=self._startElement,
                          endElement=self._endElement)

    def _startElement(self, name, attrs):
        nodeName = attrs.get('name', None)
        
        if (name == 'world'):
            world = World(nodeName, self)
            world.takeParser(self._parser)
        elif (name == 'ext'):
            pass
        else:
            raise InvalidError('%s is not a valid child of <xode>.' %
                               repr(name))

    def _endElement(self, name):
        if (name == 'xode'):
            self._parser.pop()
        
class World(TreeNode):

    def __init__(self, name, parent):
        TreeNode.__init__(self, name, parent)
        self.setODEObject(ode.World())

    def takeParser(self, parser):
        self._parser = parser
        self._parser.push(startElement=self._startElement,
                          endElement=self._endElement)

    def _startElement(self, name, attrs):
        nodeName = attrs.get('name', None)
        
        if (name == 'transform'):
            t = Transform()
            t.takeParser(self._parser, self, attrs)
        elif (name == 'space'):
            space = Space(nodeName, self)
            space.takeParser(self._parser)
        elif (name == 'ext'):
            pass
        else:
            raise InvalidError('%s is not a valid child of <world>' %
                               repr(name))

    def _endElement(self, name):
        if (name == 'world'):
            self._parser.pop()

class Space(TreeNode):

    def __init__(self, name, parent):
        TreeNode.__init__(self, name, parent)
        self.setODEObject(ode.Space())

    def takeParser(self, parser):
        self._parser = parser
        self._parser.push(startElement=self._startElement,
                          endElement=self._endElement)

    def _startElement(self, name, attrs):
        nodeName = attrs.get('name', None)
        
        if (name == 'transform'):
            t = Transform()
            t.takeParser(self._parser, self, attrs)
        elif (name == 'geom'):
            # parse geom
            pass
        elif (name == 'group'):
            # parse group
            pass
        elif (name == 'body'):
            body = Body(nodeName, self, attrs)
            body.takeParser(self._parser)
        elif (name == 'jointgroup'):
            # parse joint group
            pass
        elif (name == 'joint'):
            joint = Joint(nodeName, self)
            joint.takeParser(self._parser)
        elif (name == 'ext'):
            # parse ext
            pass
        else:
            raise InvalidError('%s is not a valid child of <space>.' %
                               repr(name))

    def _endElement(self, name):
        if (name == 'space'):
            self._parser.pop()

def parseVector(attrs):
    try:
        vec = float(attrs['x']), float(attrs['y']), float(attrs['z'])
    except ValueError:
        raise InvalidError('Vector attributes must be numbers.')
    except KeyError:
        raise InvalidError('Vector elements must have x, y and z attributes.')
    else:
        return vec

class Body(TreeNode):
    
    def __init__(self, name, parent, attrs):
        TreeNode.__init__(self, name, parent)
        world = parent.getFirstAncestor(ode.World)
        self.setODEObject(ode.Body(world.getODEObject()))

        enabled = attrs.get('enabled', 'true')
        if (enabled not in ['true', 'false']):
            raise InvalidError("Enabled attribute must be either 'true' or " \
                               "'false'.")
        else:
            if (enabled == 'false'):
                self.getODEObject().disable()

        gravitymode = int(attrs.get('gravitymode', 1))
        if (gravitymode == 0):
            self.getODEObject().setGravityMode(0)

        self._mass = None
        self._transformed = False

    def takeParser(self, parser):
        self._parser = parser
        self._parser.push(startElement=self._startElement,
                          endElement=self._endElement)

    def _applyTransform(self):
        if (self._transformed): return

        t = self.getTransform()

        body = self.getODEObject()
        body.setPosition(t.getPosition())
        body.setRotation(t.getRotation())

        self._transformed = True

    def _startElement(self, name, attrs):
        nodeName = attrs.get('name', None)

        if (name == 'transform'):
            t = Transform()
            t.takeParser(self._parser, self, attrs)
        else:
            self._applyTransform()
        
        if (name == 'torque'):
            self.getODEObject().setTorque(parseVector(attrs))
        elif (name == 'force'):
            self.getODEObject().setForce(parseVector(attrs))
        elif (name == 'finiteRotation'):
            mode = int(attrs['mode'])

            try:
                axis = (float(attrs['xaxis']),
                        float(attrs['yaxis']),
                        float(attrs['zaxis']))
            except KeyError:
                raise InvalidError('finiteRotation element must have xaxis, ' \
                                   'yaxis and zaxis attributes')

            if (mode not in [0, 1]):
                raise InvalidError('finiteRotation mode attribute must be ' \
                                   'either 0 or 1.')
            
            self.getODEObject().setFiniteRotationMode(mode)
            self.getODEObject().setFiniteRotationAxis(axis)
        elif (name == 'linearVel'):
            self.getODEObject().setLinearVel(parseVector(attrs))
        elif (name == 'angularVel'):
            self.getODEObject().setAngularVel(parseVector(attrs))
        elif (name == 'mass'):
            self._mass = Mass(nodeName, self)
            self._mass.takeParser(self._parser)
        elif (name == 'joint'):
            joint = Joint(nodeName, self)
            joint.takeParser(self._parser)

    def _endElement(self, name):
        if (name == 'body'):
            self._parser.pop()
            
            self._applyTransform()
            if (self._mass is not None):
                self.getODEObject().setMass(self._mass.getODEObject())

class Mass(TreeNode):
    
    def __init__(self, name, parent):
        TreeNode.__init__(self, name, parent)

        mass = ode.Mass()
        self.setODEObject(mass)
                
        body = self.getFirstAncestor(ode.Body)
        body.getODEObject().setMass(mass)

    def takeParser(self, parser):
        self._parser = parser
        self._parser.push(startElement=self._startElement,
                          endElement=self._endElement)

    def _startElement(self, name, attrs):
        nodeName = attrs.get('name', None)

        if (name == 'mass_struct'):
            pass
        elif (name == 'mass_shape'):
            parseMassShape(self._parser, self.getODEObject(), attrs)
        elif (name == 'transform'):
            # parse transform
            pass
        elif (name == 'adjust'):
            total = float(attrs['total'])
            self.getODEObject().adjust(total)
        elif (name == 'mass'):
            mass = Mass(nodeName, self)
            mass.takeParser(self._parser)
        else:
            raise InvalidError('%s is not a valid child of <mass>' % repr(name))

    def _endElement(self, name):
        if (name == 'mass'):
            try:
                mass = self.getFirstAncestor(ode.Mass)
            except AncestorNotFoundError:
                pass
            else:
                mass.getODEObject().add(self.getODEObject())
            self._parser.pop()

def parseMassShape(parser, mass, attrs):
    density = attrs.get('density', None)
    
    def start(name, attrs):
        if (name == 'sphere'):
            radius = float(attrs.get('radius', 1.0))
            if (density is not None):
                mass.setSphere(float(density), radius)
        else:
            # parse other shapes
            pass
    
    def end(name):
        if (name == 'mass_shape'):
            parser.pop()
    
    parser.push(startElement=start, endElement=end)

class Joint(TreeNode):

    def __init__(self, name, parent):
        TreeNode.__init__(self, name, parent)

        self._world = self.getFirstAncestor(ode.World).getODEObject()

        try:
            self._jg = self.getFirstAncestor(ode.JointGroup).getODEObject()
        except AncestorNotFoundError:
            self._jg = None

        try:
            self._body = self.getFirstAncestor(ode.Body).getODEObject()
        except AncestorNotFoundError:
            self._body = None

        self._link1 = None
        self._link2 = None

        self.setODEObject(None)

    def _getName(self, name):
        root = self.getRoot()
        
        try:
            link = root.namedChild(name).getODEObject()
        except KeyError:
            raise InvalidError('Joint link must reference an already '\
                               'parsed body.')

        if (not isinstance(link, ode.Body)):
            raise InvalidError('Joint link must reference a body.')

        return link

    def _getLinks(self):
        body = self._body or ode.environment

        if (self._link1 is not None):
            link1 = self._getName(self._link1)
        else:
            link1 = body
            body = ode.environment

        if (self._link2 is not None):
            link2 = self._getName(self._link2)
        else:
            link2 = body

        if (link1 is link2):
            raise InvalidError('Joint requires two objects.')

        return link1, link2

    def takeParser(self, parser):
        self._parser = parser
        self._parser.push(startElement=self._startElement,
                          endElement=self._endElement)

    def _startElement(self, name, attrs):
        if (name == 'link1'):
            self._link1 = attrs['body']
        elif (name == 'link2'):
            self._link2 = attrs['body']
        elif (name == 'ext'):
            pass
        elif (name == 'amotor'):
            pass
        elif (name == 'ball'):
            l1, l2 = self._getLinks()
            self.setODEObject(parseBallJoint(self._parser, self, self._world,
                                             l1, l2, self._jg))
        elif (name == 'fixed'):
            pass
        elif (name == 'hinge'):
            pass
        elif (name == 'hinge2'):
            pass
        elif (name == 'slider'):
            pass
        elif (name == 'universal'):
            pass
        else:
            raise InvalidError('%s is not a valid child of <joint>.' %
                               repr(name))

    def _endElement(self, name):
        if (name == 'joint'):
            if (self.getODEObject() is None):
                raise InvalidError('No joint type element found.')
            self._parser.pop()

def parseBallJoint(parser, node, world, link1, link2, jg):
    anchor = [None]
    
    def start(name, attrs):
        if (name == 'anchor'):
            anchor[0] = parseVector(attrs)
        else:
            raise InvalidError('%s is not a valid child of <ball>.' %
                               repr(name))
    
    def end(name):
        if (name == 'ball'):
            joint = ode.BallJoint(world, jg)
            joint.attach(link1, link2)
            if (anchor[0] is not None):
                joint.setAnchor(anchor[0])
            node.setODEObject(joint)
            
            parser.pop()
    
    parser.push(startElement=start, endElement=end)
