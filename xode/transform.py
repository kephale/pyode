# XODE Importer for PyODE
# Copyright (C) 2004 Timothy Stranex

"""
XODE Transform
@author: U{Timothy Stranex<mailto:timothy@stranex.com>}
"""

import math

class Transform:
    """
    A matrix transform.
    """

    def __init__(self):
        """
        Initialise as an identity transform.
        """
        
        self.m = [[0, 0, 0, 0],
                  [0, 0, 0, 0],
                  [0, 0, 0, 0],
                  [0, 0, 0, 0]]
        self.setIdentity()

    def takeParser(self, parser, node, attrs):
        """
        Called to make this object handle further parsing. It should be called
        immediately after the <transform> tag has been encountered.

        @param parser: The parser.
        @type parser: instance of L{parser.Parser}

        @param node: The node that is to be transformed.
        @type node: instance of L{node.TreeNode}

        @param attrs: The <transform> tag attributes.
        @type attrs: dict
        """
        
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
        """
        Set the matrix so that there is no translation, rotation or scaling.
        """
        
        for r in range(4):
            for c in range(4):
                self.m[r][c] = 0
        
        for i in range(4):
            self.m[i][i] = 1

    def translate(self, x, y, z):
        """
        Set the matrix to translate a point.

        @param x: The offset along the x axis.
        @type x: float

        @param y: The offset along the y axis.
        @type y: float

        @param z: The offset along the z axis.
        @type z: float
        """
        
        t = Transform()
        t.m[3][0] = x
        t.m[3][1] = y
        t.m[3][2] = z

        r = self * t;
        self.m = r.m

    def scale(self, x, y, z):
        """
        Set the matrix to scale a point.

        @param x: The scaling factor along the x axis.
        @type x: float

        @param y: The scaling factor along the y axis.
        @type y: float

        @param z: The scaling factor along the z axis.
        @type z: float
        """
        
        t = Transform()
        t.m[0][0] = x
        t.m[1][1] = y
        t.m[2][2] = z

        r = self * t
        self.m = r.m

    def rotate(self, x, y, z):
        """
        Set the matrix to rotate a point.

        @param x: Rotation around the x axis in radians.
        @type x: float

        @param y: Rotation around the y axis in radians.
        @type y: float

        @param z: Rotation around the z axis in radians.
        @type z: float
        """
        
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
        """
        Extracts the position vector. It is returned as a tuple in the form
        (x, y, z).
        
        @return: The position vector.
        @rtype: tuple
        """
        
        return self.m[3][0], self.m[3][1], self.m[3][2]

    def getRotation(self):
        """
        Extracts the rotation matrix. It is returned as a tuple in the form
        (m00, m01, m02, m10, m11, m12, m20, m21, m22).
        
        @return: The rotation matrix.
        @rtype: tuple
        """
        
        return self.m[0][0], self.m[0][1], self.m[0][2], \
               self.m[1][0], self.m[1][1], self.m[1][2], \
               self.m[2][0], self.m[2][1], self.m[2][2]

    def __mul__(self, t2):
        """
        Concatenate this transform with another.

        @param t2: The second transform.
        @type t2: instance of L{Transform}
        """
        
        ret = Transform()
        
        for row in range(4):
            for col in range(4):
                part = 0
                for i in range(4):
                    part = part + self.m[row][i] * t2.m[i][col]
                ret.m[row][col] = part

        return ret
