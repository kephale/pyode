############################## Contact ################################

cdef class Contact:
    """This class represents a contact between two bodies in one point.

    A Contact object stores all the input parameters for a ContactJoint.
    This class wraps the ODE dContact structure which has 3 components::

     struct dContact {
       dSurfaceParameters surface;
       dContactGeom geom;
       dVector3 fdir1;
     };    

    This wrapper class provides methods to get and set the items of those
    structures.
    """
    
    cdef dContact _contact

    def __new__(self):
        self._contact.surface.mode = ContactBounce
        self._contact.surface.mu   = dInfinity

        self._contact.surface.bounce = 0.1

    def getMode(self):
        return self._contact.surface.mode

    def setMode(self, m):
        self._contact.surface.mode = m

    def getMu(self):
        return self._contact.surface.mu
    
    def setMu(self, mu):
        self._contact.surface.mu = mu

    def getMu2(self):
        return self._contact.surface.mu2
    
    def setMu2(self, mu):
        self._contact.surface.mu2 = mu

    def getBounce(self):
        return self._contact.surface.bounce

    def setBounce(self, b):
        self._contact.surface.bounce = b

    def getBounceVel(self):
        return self._contact.surface.bounce_vel

    def setBounceVel(self, bv):
        self._contact.surface.bounce_vel = bv

    def getSoftERP(self):
        return self._contact.surface.soft_erp

    def setSoftERP(self, erp):
        self._contact.surface.soft_erp = erp

    def getSoftCFM(self):
        return self._contact.surface.soft_cfm

    def setSoftCFM(self, cfm):
        self._contact.surface.soft_cfm = cfm

    def getMotion1(self):
        return self._contact.surface.motion1

    def setMotion1(self, m):
        self._contact.surface.motion1 = m

    def getMotion2(self):
        return self._contact.surface.motion2

    def setMotion2(self, m):
        self._contact.surface.motion2 = m

    def getSlip1(self):
        return self._contact.surface.slip1

    def setSlip1(self, s):
        self._contact.surface.slip1 = s

    def getSlip2(self):
        return self._contact.surface.slip2

    def setSlip2(self, s):
        self._contact.surface.slip2 = s

    def getContactGeomParams(self):
        """Get the ContactGeom structure of the contact.

        The return value is a tuple (pos,normal,depth,geom1,geom2)
        where pos and normal are 3-tuples of floats and depth is a single
        float. geom1 and geom2 are the Geom objects of the geoms in contact.
        """
        cdef long id1, id2

        pos = (self._contact.geom.pos[0], self._contact.geom.pos[1], self._contact.geom.pos[2])
        normal = (self._contact.geom.normal[0], self._contact.geom.normal[1], self._contact.geom.normal[2])
        depth = self._contact.geom.depth

        id1 = <long>self._contact.geom.g1
        id2 = <long>self._contact.geom.g2
        g1 = _geom_c2py_lut[id1]
        g2 = _geom_c2py_lut[id2]
        return (pos,normal,depth,g1,g2)


    def setContactGeomParams(self, pos, normal, depth, g1=None, g2=None):
        """Set the ContactGeom structure of the contact.

        pos (3-tuple):    Contact position, in global coordinates
        normal (3-tuple): Unit length normal vector
        depth (float):    Depth to which the two bodies inter-penetrate.
        g1 (geom object): Geometry objects that collided
        g2 (geom object):   ''        ''            ''
        """

        cdef long id

        self._contact.geom.pos[0] = pos[0]
        self._contact.geom.pos[1] = pos[1]
        self._contact.geom.pos[2] = pos[2]
        self._contact.geom.normal[0] = normal[0]
        self._contact.geom.normal[1] = normal[1]
        self._contact.geom.normal[2] = normal[2]
        self._contact.geom.depth = depth
        if g1!=None:
            id = g1._id()
            self._contact.geom.g1 = <dGeomID>id
        else:
            self._contact.geom.g1 = <dGeomID>0
            
        if g2!=None:
            id = g2._id()
            self._contact.geom.g2 = <dGeomID>id
        else:
            self._contact.geom.g2 = <dGeomID>0
