# XODE Importer for PyODE
# Copyright (C) 2004 Timothy Stranex

"""
XODE Joint Parser
@author: U{Timothy Stranex<mailto:timothy@stranex.com>}
"""

import ode
import node, parser

class Joint(node.TreeNode):
    """
    Represents an ode.Joint-based object and corresponds to the <joint> tag.
    """

    def __init__(self, name, parent):
        node.TreeNode.__init__(self, name, parent)

        self._world = self.getFirstAncestor(ode.World).getODEObject()

        try:
            self._jg = self.getFirstAncestor(ode.JointGroup).getODEObject()
        except node.AncestorNotFoundError:
            self._jg = None

        try:
            self._body = self.getFirstAncestor(ode.Body).getODEObject()
        except node.AncestorNotFoundError:
            self._body = None

        self._link1 = None
        self._link2 = None

        self.setODEObject(None)

    def _getName(self, name):
        root = self.getRoot()
        
        try:
            link = root.namedChild(name).getODEObject()
        except KeyError:
            raise parser.InvalidError('Joint link must reference an already '\
                               'parsed body.')

        if (not isinstance(link, ode.Body)):
            raise parser.InvalidError('Joint link must reference a body.')

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
            raise parser.InvalidError('Joint requires two objects.')

        return link1, link2

    def takeParser(self, parser):
        """
        Handles further parsing. It should be called immediately after the
        <joint> tag is encountered.
        """
        
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
            self._parseBallJoint(self._world, l1, l2)
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
            raise parser.InvalidError('%s is not a valid child of <joint>.' %
                               repr(name))

    def _endElement(self, name):
        if (name == 'joint'):
            if (self.getODEObject() is None):
                raise parser.InvalidError('No joint type element found.')
            self._parser.pop()

    def _parseBallJoint(self, world, link1, link2):
        anchor = [None]
    
        def start(name, attrs):
            if (name == 'anchor'):
                anchor[0] = self._parser.parseVector(attrs)
            else:
                raise parser.InvalidError('%s is not a valid child of <ball>.' %
                                   repr(name))
    
        def end(name):
            if (name == 'ball'):
                joint = ode.BallJoint(world, self._jg)
                joint.attach(link1, link2)
                if (anchor[0] is not None):
                    joint.setAnchor(anchor[0])
                
                self.setODEObject(joint)
                self._parser.pop()
    
        self._parser.push(startElement=start, endElement=end)
