# XODE Importer for PyODE
# Copyright (C) 2004 Timothy Stranex

"""
XODE Body and Mass Parser
@author: U{Timothy Stranex<mailto:timothy@stranex.com>}
"""

import ode
import parser, node, joint, transform

class Body(node.TreeNode):
    """
    Represents an ode.Body object and corresponds to the <body> tag.
    """
    
    def __init__(self, name, parent, attrs):
        node.TreeNode.__init__(self, name, parent)
        world = parent.getFirstAncestor(ode.World)
        self.setODEObject(ode.Body(world.getODEObject()))

        enabled = attrs.get('enabled', 'true')
        if (enabled not in ['true', 'false']):
            raise parser.InvalidError("Enabled attribute must be either 'true' or " \
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
        """
        Handle further parsing. It should be called immediately after the <body>
        tag has been encountered.
        """
        
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
            t = transform.Transform()
            t.takeParser(self._parser, self, attrs)
        else:
            self._applyTransform()
        
        if (name == 'torque'):
            self.getODEObject().setTorque(self._parser.parseVector(attrs))
        elif (name == 'force'):
            self.getODEObject().setForce(self._parser.parseVector(attrs))
        elif (name == 'finiteRotation'):
            mode = int(attrs['mode'])

            try:
                axis = (float(attrs['xaxis']),
                        float(attrs['yaxis']),
                        float(attrs['zaxis']))
            except KeyError:
                raise parser.InvalidError('finiteRotation element must have' \
                                          ' xaxis, yaxis and zaxis attributes')

            if (mode not in [0, 1]):
                raise parser.InvalidError('finiteRotation mode attribute must' \
                                          ' be either 0 or 1.')
            
            self.getODEObject().setFiniteRotationMode(mode)
            self.getODEObject().setFiniteRotationAxis(axis)
        elif (name == 'linearVel'):
            self.getODEObject().setLinearVel(self._parser.parseVector(attrs))
        elif (name == 'angularVel'):
            self.getODEObject().setAngularVel(self._parser.parseVector(attrs))
        elif (name == 'mass'):
            self._mass = Mass(nodeName, self)
            self._mass.takeParser(self._parser)
        elif (name == 'joint'):
            j = joint.Joint(nodeName, self)
            j.takeParser(self._parser)

    def _endElement(self, name):
        if (name == 'body'):
            self._parser.pop()
            
            self._applyTransform()
            if (self._mass is not None):
                self.getODEObject().setMass(self._mass.getODEObject())

class Mass(node.TreeNode):
    """
    Represents an ode.Mass object and corresponds to the <mass> tag.
    """
    
    def __init__(self, name, parent):
        node.TreeNode.__init__(self, name, parent)

        mass = ode.Mass()
        self.setODEObject(mass)
                
        body = self.getFirstAncestor(ode.Body)
        body.getODEObject().setMass(mass)

    def takeParser(self, parser):
        """
        Handle further parsing. It should be called immediately after the <mass>
        tag is encountered.
        """
        
        self._parser = parser
        self._parser.push(startElement=self._startElement,
                          endElement=self._endElement)

    def _startElement(self, name, attrs):
        nodeName = attrs.get('name', None)

        if (name == 'mass_struct'):
            pass
        elif (name == 'mass_shape'):
            self._parseMassShape(attrs)
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
            raise parser.InvalidError('%s is not a valid child of <mass>' %
                                      repr(name))

    def _endElement(self, name):
        if (name == 'mass'):
            try:
                mass = self.getFirstAncestor(ode.Mass)
            except node.AncestorNotFoundError:
                pass
            else:
                mass.getODEObject().add(self.getODEObject())
            self._parser.pop()

    def _parseMassShape(self, attrs):
        density = attrs.get('density', None)
        mass = self.getODEObject()
    
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
                self._parser.pop()
    
        self._parser.push(startElement=start, endElement=end)
