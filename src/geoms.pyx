# Each geom object has to insert itself into the global dictionary
# _geom_c2py_lut (key:address - value:Python object).
# This lookup table is used in the near callback to translate the C
# pointers into corresponding Python wrapper objects.
#
# Additionally, each geom object must have a method _id() that returns
# the ODE geom id. This is used during collision detection.
# 
# ##########################
# # Obsolete:
# #
# # Each geom object has to register itself at its space as the
# # space keeps a dictionary that's used as lookup table to translate
# # C pointers into Python objects (this is used in the near callback).


# Geom base class
cdef class GeomObject:
    """This is the abstract base class for all geom objects.
    """
    
    # The id of the geom object as returned by dCreateXxxx()
    cdef dGeomID gid
    # The space in which the geom was placed (or None). This reference
    # is kept so that the space won't be destroyed while there are still
    # geoms around that might use it. 
    cdef object space
    # The body that the geom was attached to (or None).
    cdef object body

    # A dictionary with user defined attributes
    cdef object attribs

    def __new__(self, *a, **kw):
        self.gid = NULL
        self.space = None
        self.body = None
        self.attribs = {}

    def __init__(self, *a, **kw):
        raise NotImplementedError, "The GeomObject base class can't be used directly."

    def __dealloc__(self):
        if self.gid!=NULL:
            dGeomDestroy(self.gid)

    def __getattr__(self, name):
        if name in self.attribs:
            return self.attribs[name]
        else:
            raise AttributeError, "geom has no attribute '%s'."%name

    def __setattr__(self, name, val):
        self.attribs[name]=val

    def setBody(self, Body body):
        """Associate the geom to a body or remove an association.

        @param body: The Body object or None.
        """
        
        if body==None:
            dGeomSetBody(self.gid, NULL)
        else:
            dGeomSetBody(self.gid, body.bid)
        self.body = body

    def getBody(self):
        return self.body

    def setPosition(self, pos):
        dGeomSetPosition(self.gid, pos[0], pos[1], pos[2])

    def getPosition(self):
        cdef dReal* p
        p = <dReal*>dGeomGetPosition(self.gid)
        return (p[0],p[1],p[2])

    def setRotation(self, R):
        cdef dMatrix3 m
        m[0] = R[0]
        m[1] = R[1]
        m[2] = R[2]
        m[3] = 0
        m[4] = R[3]
        m[5] = R[4]
        m[6] = R[5]
        m[7] = 0
        m[8] = R[6]
        m[9] = R[7]
        m[10] = R[8]
        m[11] = 0
        dGeomSetRotation(self.gid, m)

    def getRotation(self):
        cdef dReal* m
        m = <dReal*>dGeomGetRotation(self.gid)
        return [m[0],m[1],m[2],m[4],m[5],m[6],m[8],m[9],m[10]]

    def isSpace(self):
        """Return 1 if the given geom is a space, or 0 if not."""
        return dGeomIsSpace(self.gid)

    def getSpace(self):
        """Return the space that contains the geom.
        
        Return the space that the given geometry is contained in,
        or return None if it is not contained in any space."""        
        return self.space

    def setCollideBits(self, bits):
        dGeomSetCollideBits(self.gid, bits)
        
    def setCategoryBits(self, bits):
        dGeomSetCategoryBits(self.gid, bits)

    def getCollideBits(self):
        return dGeomGetCollideBits(self.gid)

    def getCategoryBits(self):
        return dGeomGetCategoryBits(self.gid)
    
    def enable(self):
        """Enable the geom."""
        dGeomEnable(self.gid)

    def disable(self):
        """Disable the geom."""
        dGeomDisable(self.gid)

    def isEnabled(self):
        """Return True if the geom is enabled."""
        return dGeomIsEnabled(self.gid)


######################################################################

# GeomSphere
cdef class GeomSphere(GeomObject):
    """Sphere object.
    """

    def __new__(self, space=None, radius=1.0):
        cdef Space sp
        cdef dSpaceID sid

        sid=NULL
        if space!=None:
            sp = space
            sid = sp.sid
        self.gid = dCreateSphere(sid, radius)
#        if space!=None:
#            space._addgeom(self)

        _geom_c2py_lut[<long>self.gid]=self


    def __init__(self, space=None, radius=1.0):
        self.space = space
        self.body = None

    def _id(self):
        cdef long id
        id = <long>self.gid
        return id

    def setRadius(self, radius):
        dGeomSphereSetRadius(self.gid, radius)

    def getRadius(self):
        return dGeomSphereGetRadius(self.gid)

    def pointDepth(self, p):
        return dGeomSpherePointDepth(self.gid, p[0], p[1], p[2])

                
# GeomBox
cdef class GeomBox(GeomObject):
    """Box object.
    """

    def __new__(self, space=None, lengths=(1.0, 1.0, 1.0)):
        cdef Space sp
        cdef dSpaceID sid
        
        sid=NULL
        if space!=None:
            sp = space
            sid = sp.sid
        self.gid = dCreateBox(sid, lengths[0],lengths[1],lengths[2])
#        if space!=None:
#            space._addgeom(self)

        _geom_c2py_lut[<long>self.gid]=self

    def __init__(self, space=None, lengths=(1.0, 1.0, 1.0)):
        self.space = space
        self.body = None

    def _id(self):
        cdef long id
        id = <long>self.gid
        return id

    def setLengths(self, lengths):
        dGeomBoxSetLengths(self.gid, lengths[0], lengths[1], lengths[2])

    def getLengths(self):
        cdef dVector3 res
        dGeomBoxGetLengths(self.gid, res)
        return (res[0], res[1], res[2])

    def pointDepth(self, p):
        return dGeomBoxPointDepth(self.gid, p[0], p[1], p[2])


# GeomPlane
cdef class GeomPlane(GeomObject):
    """Plane object.

    This object can't be attached to a body.
    If you call getBody() on this object it always returns ode.environment.
    """

    def __new__(self, space=None, normal=(0,0,1), dist=0):
        cdef Space sp
        cdef dSpaceID sid
        
        sid=NULL
        if space!=None:
            sp = space
            sid = sp.sid
        self.gid = dCreatePlane(sid, normal[0], normal[1], normal[2], dist)
#        if space!=None:
#            space._addgeom(self)

        _geom_c2py_lut[<long>self.gid]=self


    def __init__(self, space=None, normal=(0,0,1), dist=0):
        self.space = space


    def _id(self):
        cdef long id
        id = <long>self.gid
        return id

    def setParams(self, normal, dist):
        dGeomPlaneSetParams(self.gid, normal[0], normal[1], normal[2], dist)

    def getParams(self):
        cdef dVector4 res
        dGeomPlaneGetParams(self.gid, res)
        return ((res[0], res[1], res[2]), res[3])

    def pointDepth(self, p):
        return dGeomPlanePointDepth(self.gid, p[0], p[1], p[2])

    def getBody(self):
        return environment

    def setBody(self, Body body):
        if body!=None:
            raise ValueError, "A GeomPlane cannot be associated to a body."


# GeomCCylinder
cdef class GeomCCylinder(GeomObject):
    """Capped cylinder object.
    """

    def __new__(self, space=None, radius=0.5, length=1.0):
        cdef Space sp
        cdef dSpaceID sid
        
        sid=NULL
        if space!=None:
            sp = space
            sid = sp.sid
        self.gid = dCreateCCylinder(sid, radius, length)
#        if space!=None:
#            space._addgeom(self)

        _geom_c2py_lut[<long>self.gid]=self

    def __init__(self, space=None, radius=0.5, length=1.0):
        self.space = space
        self.body = None


    def _id(self):
        cdef long id
        id = <long>self.gid
        return id

    def setParams(self, radius, length):
        dGeomCCylinderSetParams(self.gid, radius, length)

    def getParams(self):
        cdef dReal radius, length
        dGeomCCylinderGetParams(self.gid, &radius, &length)
        return (radius, length)

    def pointDepth(self, p):
        return dGeomCCylinderPointDepth(self.gid, p[0], p[1], p[2])


# GeomRay
cdef class GeomRay(GeomObject):
    """Ray object.
    """

    def __new__(self, space=None, rlen=1.0):
        cdef Space sp
        cdef dSpaceID sid
        
        sid=NULL
        if space!=None:
            sp = space
            sid = sp.sid
        self.gid = dCreateRay(sid, rlen)
#        if space!=None:
#            space._addgeom(self)

        _geom_c2py_lut[<long>self.gid]=self


    def __init__(self, space=None, rlen=1.0):
        self.space = space
        self.body = None

    def _id(self):
        cdef long id
        id = <long>self.gid
        return id

    def setLength(self, rlen):
        dGeomRaySetLength(self.gid, rlen)

    def getLength(self):
        return dGeomRayGetLength(self.gid)

    def set(self, p, u):
        dGeomRaySet(self.gid, p[0],p[1],p[2], u[0],u[1],u[2])

    def get(self):
        cdef dVector3 start
        cdef dVector3 dir
        dGeomRayGet(self.gid, start, dir)
        return ((start[0],start[1],start[2]), (dir[0],dir[1],dir[2]))


# GeomTransform
cdef class GeomTransform(GeomObject):
    """GeomTransform.
    """

    cdef object geom

    def __new__(self, space=None):
        cdef Space sp
        cdef dSpaceID sid
        
        sid=NULL
        if space!=None:
            sp = space
            sid = sp.sid
        self.gid = dCreateGeomTransform(sid)
#        if space!=None:
#            space._addgeom(self)

        _geom_c2py_lut[<long>self.gid]=self


    def __init__(self, space=None):
        self.space = space
        self.body = None
        self.geom = None

        self.attribs={}

    def _id(self):
        cdef long id
        id = <long>self.gid
        return id

    def setGeom(self, geom):
        cdef long id
        
        id = geom._id()
        dGeomTransformSetGeom(self.gid, <dGeomID>id)
        self.geom = geom

    def getGeom(self):
        return self.geom

