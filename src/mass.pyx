# Mass class.

cdef class Mass:
    """Mass parameters of a rigid body.

    This class stores mass parameters of a rigid body which can be
    accessed through the following attributes:

    - mass: The total mass of the body (float)
    - c:    The center of gravity position in body frame (3-tuple of floats)
    - I:    The 3x3 inertia tensor in body frame (3-tuple of 3-tuples (rows))

    This class wraps the dMass structure from the C API.
    """
    cdef dMass _mass

    def __new__(self):
        dMassSetZero(&self._mass)

    def setZero(self):
        "Set all the mass parameters to zero."
        dMassSetZero(&self._mass)

    def setParameters(self, themass, cgx, cgy, cgz, I11, I22, I33, I12, I13, I23):
        """Set the mass parameters to the given values.

        themass     - Total mass of the body.
        cgx,cgy,cgz - Center of gravity position in the body frame.
        Ixx         - Elements of the inertia matrix
                      [ I11  I12  I13 ]
                      [ I12  I22  I23 ]
                      [ I13  I23  I33 ]
        """
        dMassSetParameters(&self._mass, themass, cgx, cgy, cgz, I11, I22, I33, I12, I13, I23)

    def setSphere(self, density, radius):
        """Set the mass parameters for a sphere.
        
        Set the mass parameters to represent a sphere of the given radius
        and density, with the center of mass at (0,0,0) relative to the body.
        """
        dMassSetSphere(&self._mass, density, radius)

    def setCappedCylinder(self, density, direction, a, b):
        """Set the mass parameters for a capped cylinder.
        
        Set the mass parameters to represent a capped cylinder of the
        given parameters and density, with the center of mass at
        (0,0,0) relative to the body. The radius of the cylinder (and
        the spherical cap) is a. The length of the cylinder (not
        counting the spherical cap) is b. The cylinder's long axis is
        oriented along the body's x, y or z axis according to the
        value of direction (1=x, 2=y, 3=z).
        """
        dMassSetCappedCylinder(&self._mass, density, direction, a, b)

    def setCylinder(self, density, direction, a, b):
        """Set the mass parameters for a flat-ended cylinder.
        
        Set the mass parameters to represent a flat-ended cylinder of
        the given parameters and density, with the center of mass at
        (0,0,0) relative to the body. The radius of the cylinder is
        radius. The length of the cylinder is length. The cylinder's
        long axis is oriented along the body's x, y or z axis
        according to the value of direction (1=x, 2=y, 3=z).
        """
        dMassSetCylinder(&self._mass, density, direction, a, b)

    def setBox(self, density, lx, ly, lz):
        """Set the mass parameters for a box.

        Set the mass parameters to represent a box of the given
        dimensions and density, with the center of mass at (0,0,0)
        relative to the body. The side lengths of the box along the x,
        y and z axes are lx, ly and lz.
        """
        dMassSetBox(&self._mass, density, lx, ly, lz)

    def adjust(self, newmass):
        """Adjust the total mass.

        Given mass parameters for some object, adjust them so the
        total mass is now newmass. This is useful when using the setXyz()
        methods to set the mass parameters for certain objects -
        they take the object density, not the total mass.
        """
        dMassAdjust(&self._mass, newmass)

    def translate(self, t):
        """Adjust mass parameters.

        Given mass parameters for some object, adjust them to
        represent the object displaced by (x,y,z) relative to the body
        frame.
        """
        dMassTranslate(&self._mass, t[0], t[1], t[2])

#    def rotate(self, R):
#        """
#        Given mass parameters for some object, adjust them to
#        represent the object rotated by R relative to the body frame.
#        """
#        pass

    def add(self, Mass b):
        """Add the mass b to the mass a.

        a must also be a Mass object. Masses can also be added using
        the + operator.
        """
        dMassAdd(&self._mass, &b._mass)

    def __getattr__(self, name):
        if name=="mass":
            return self._mass.mass
        elif name=="c":
            return (self._mass.c[0], self._mass.c[1], self._mass.c[2])
        elif name=="I":
            return ((self._mass.I[0],self._mass.I[1],self._mass.I[2]),
                    (self._mass.I[4],self._mass.I[5],self._mass.I[6]),
                    (self._mass.I[8],self._mass.I[9],self._mass.I[10]))
        else:
            raise AttributeError,"Mass object has no attribute '"+name+"'"

    def __setattr__(self, name, value):
        if name=="mass":
            self.adjust(value)
        elif name=="c":
            raise AttributeError,"Use the setParameter() method to change c"
        elif name=="I":
            raise AttributeError,"Use the setParameter() method to change I"
        else:
            raise AttributeError,"Mass object has no attribute '"+name+"'"

    def __add__(self, Mass b):
        self.add(b)
        return self

    def __str__(self):
        m   = str(self._mass.mass)
        sc0 = str(self._mass.c[0])
        sc1 = str(self._mass.c[1])
        sc2 = str(self._mass.c[2])
        I11 = str(self._mass.I[0])
        I22 = str(self._mass.I[5])
        I33 = str(self._mass.I[10])
        I12 = str(self._mass.I[1])
        I13 = str(self._mass.I[2])
        I23 = str(self._mass.I[6])
        return "Mass=%s\nCg=(%s, %s, %s)\nI11=%s I22=%s I33=%s\nI12=%s I13=%s I23=%s"%(m,sc0,sc1,sc2,I11,I22,I33,I12,I13,I23)
#        return "Mass=%s / Cg=(%s, %s, %s) / I11=%s I22=%s I33=%s I12=%s I13=%s I23=%s"%(m,sc0,sc1,sc2,I11,I22,I33,I12,I13,I23)
