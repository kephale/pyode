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

    def _id(self):
        """_id() -> int

        Return the internal id of the geom (dGeomID) as returned by
        the dCreateXyz() functions.

        This method has to be overwritten in derived methods.        
        """
        raise NotImplementedError, "Bug: The _id() method is not implemented."

    def placeable(self):
        """placeable() -> bool

        Returns True if the geom object is a placeable geom.

        This method has to be overwritten in derived methods.
        """
        return False

    def setBody(self, Body body):
        """setBody(body)

        Set the body associated with a placeable geom.

        @param body: The Body object or None.
        @type body: Body
        """

        if not self.placeable():
            raise ValueError, "Non-placeable geoms cannot have a body associated to them."
        
        if body==None:
            dGeomSetBody(self.gid, NULL)
        else:
            dGeomSetBody(self.gid, body.bid)
        self.body = body

    def getBody(self):
        """getBody() -> Body

        Get the body associated with this geom.
        """
        if not self.placeable():
            return environment
        
        return self.body

    def setPosition(self, pos):
        """setPosition(pos)

        Set the position of the geom. If the geom is attached to a body,
        the body's position will also be changed.

        @param pos: Position
        @type pos: 3-sequence of floats
        """
        if not self.placeable():
            raise ValueError, "Cannot set a position on non-placeable geoms."
        dGeomSetPosition(self.gid, pos[0], pos[1], pos[2])

    def getPosition(self):
        """getPosition() -> 3-tuple

        Get the current position of the geom. If the geom is attached to
        a body the returned value is the body's position.
        """
        if not self.placeable():
            raise ValueError, "Non-placeable geoms do not have a position."

        cdef dReal* p
        p = <dReal*>dGeomGetPosition(self.gid)
        return (p[0],p[1],p[2])

    def setRotation(self, R):
        """setRotation(R)

        Set the orientation of the geom. If the geom is attached to a body,
        the body's orientation will also be changed.

        @param R: Rotation matrix
        @type R: 9-sequence of floats
        """
        if not self.placeable():
            raise ValueError, "Cannot set a rotation on non-placeable geoms."

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
        """getRotation() -> 9-tuple

        Get the current orientation of the geom. If the geom is attached to
        a body the returned value is the body's orientation.
        """
        if not self.placeable():
            raise ValueError, "Non-placeable geoms do not have a rotation."

        cdef dReal* m
        m = <dReal*>dGeomGetRotation(self.gid)
        return [m[0],m[1],m[2],m[4],m[5],m[6],m[8],m[9],m[10]]

    def getAABB(self):
        """getAABB() -> 6-tuple

        Return an axis aligned bounding box that surrounds the geom.
        The return value is a 6-tuple (minx, maxx, miny, maxy, minz, maxz).
        """
        cdef dReal aabb[6]
        
        dGeomGetAABB(self.gid, aabb)
        return (aabb[0], aabb[1], aabb[2], aabb[3], aabb[4], aabb[5])

    def isSpace(self):
        """isSpace() -> bool

        Return 1 if the given geom is a space, or 0 if not."""
        return dGeomIsSpace(self.gid)

    def getSpace(self):
        """Return the space that contains the geom.
        
        Return the space that the given geometry is contained in,
        or return None if it is not contained in any space."""        
        return self.space

    def setCollideBits(self, bits):
        """setCollideBits(bits)

        Set the "collide" bitfields for this geom.

        @param bits: Collide bit field
        @type bits: int
        """
        dGeomSetCollideBits(self.gid, bits)
        
    def setCategoryBits(self, bits):
        """setCategoryBits(bits)

        Set the "category" bitfields for this geom.

        @param bits: Category bit field
        @type bits: int
        """
        dGeomSetCategoryBits(self.gid, bits)

    def getCollideBits(self):
        """getCollideBits() -> int

        Return the "collide" bitfields for this geom.
        """
        return dGeomGetCollideBits(self.gid)

    def getCategoryBits(self):
        """getCategoryBits() -> int

        Return the "category" bitfields for this geom.
        """
        return dGeomGetCategoryBits(self.gid)
    
    def enable(self):
        """enable()

        Enable the geom."""
        dGeomEnable(self.gid)

    def disable(self):
        """disable()

        Disable the geom."""
        dGeomDisable(self.gid)

    def isEnabled(self):
        """isEnabled() -> bool

        Return True if the geom is enabled."""
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

    def placeable(self):
        return True

    def _id(self):
        cdef long id
        id = <long>self.gid
        return id

    def setRadius(self, radius):
        """setRadius(radius)

        Set the radius of the sphere.

        @param radius: New radius
        @type radius: float
        """
        dGeomSphereSetRadius(self.gid, radius)

    def getRadius(self):
        """getRadius() -> float

        Return the radius of the sphere.
        """
        return dGeomSphereGetRadius(self.gid)

    def pointDepth(self, p):
        """pointDepth(p) -> float

        Return the depth of the point p in the sphere. Points inside
        the geom will have positive depth, points outside it will have
        negative depth, and points on the surface will have zero
        depth.

        @param p: Point
        @type p: 3-sequence of floats
        """
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

    def placeable(self):
        return True

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
        """pointDepth(p) -> float

        Return the depth of the point p in the box. Points inside the
        geom will have positive depth, points outside it will have
        negative depth, and points on the surface will have zero
        depth.

        @param p: Point
        @type p: 3-sequence of floats
        """
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
        """pointDepth(p) -> float

        Return the depth of the point p in the plane. Points inside the
        geom will have positive depth, points outside it will have
        negative depth, and points on the surface will have zero
        depth.

        @param p: Point
        @type p: 3-sequence of floats
        """
        return dGeomPlanePointDepth(self.gid, p[0], p[1], p[2])


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

    def placeable(self):
        return True

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
        """pointDepth(p) -> float

        Return the depth of the point p in the cylinder. Points inside the
        geom will have positive depth, points outside it will have
        negative depth, and points on the surface will have zero
        depth.

        @param p: Point
        @type p: 3-sequence of floats
        """
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

    A geometry transform "T" is a geom that encapsulates another geom
    "E", allowing E to be positioned and rotated arbitrarily with
    respect to its point of reference.
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
        # Set cleanup mode to 0 as a contained geom will be deleted
        # by its Python wrapper class
        dGeomTransformSetCleanup(self.gid, 0)
#        if space!=None:
#            space._addgeom(self)

        _geom_c2py_lut[<long>self.gid]=self

    def __init__(self, space=None):
        self.space = space
        self.body = None
        self.geom = None

        self.attribs={}

    def placeable(self):
        return True

    def _id(self):
        cdef long id
        id = <long>self.gid
        return id

    def setGeom(self, GeomObject geom not None):
        """setGeom(geom)

        Set the geom that the geometry transform encapsulates.
        A ValueError exception is thrown if a) the geom is not placeable,
        b) the geom was already inserted into a space or c) the geom is
        already associated with a body.

        @param geom: Geom object to encapsulate
        @type geom: GeomObject
        """
        cdef long id

        if not geom.placeable():
            raise ValueError, "Only placeable geoms can be encapsulated by a GeomTransform"
        if dGeomGetSpace(geom.gid)!=<dSpaceID>0:
            raise ValueError, "The encapsulated geom was already inserted into a space."
        if dGeomGetBody(geom.gid)!=<dBodyID>0:
            raise ValueError, "The encapsulated geom is already associated with a body."
        
        id = geom._id()
        dGeomTransformSetGeom(self.gid, <dGeomID>id)
        self.geom = geom

    def getGeom(self):
        """getGeom() -> GeomObject

        Get the geom that the geometry transform encapsulates.
        """
        return self.geom

    def setInfo(self, int mode):
        """setInfo(mode)

        Set the "information" mode of the geometry transform.

        With mode 0, when a transform object is collided with another
        object, the geom field of the ContactGeom structure is set to the
        geom that is encapsulated by the transform object.

        With mode 1, the geom field of the ContactGeom structure is set
        to the transform object itself.

        @param mode: Information mode (0 or 1)
        @type mode: int
        """
        if mode<0 or mode>1:
            raise ValueError, "Invalid information mode (%d). Must be either 0 or 1."%mode
        dGeomTransformSetInfo(self.gid, mode)

    def getInfo(self):
        """getInfo() -> int

        Get the "information" mode of the geometry transform (0 or 1).

        With mode 0, when a transform object is collided with another
        object, the geom field of the ContactGeom structure is set to the
        geom that is encapsulated by the transform object.

        With mode 1, the geom field of the ContactGeom structure is set
        to the transform object itself.
        """
        return dGeomTransformGetInfo(self.gid)


include "trimeshdata.pyx"

# GeomTriMesh
cdef class GeomTriMesh(GeomObject):
    """TriMesh object.

    To construct the trimesh geom you need a TriMeshData object that
    stores the actual mesh. This object has to be passed as first
    argument to the constructor.
    """

    # Keep a reference to the data
    cdef TriMeshData data

    def __new__(self, TriMeshData data not None, space=None):
        cdef Space sp
        cdef dSpaceID sid

        self.data = data

        sid=NULL
        if space!=None:
            sp = space
            sid = sp.sid
        self.gid = dCreateTriMesh(sid, data.tmdid, NULL, NULL, NULL)

        _geom_c2py_lut[<long>self.gid] = self


    def __init__(self, TriMeshData data not None, space=None):
        self.space = space
        self.body = None

    def placeable(self):
        return True

    def _id(self):
        cdef long id
        id = <long>self.gid
        return id

    def clearTCCache(self):
        """clearTCCache()

        Clears the internal temporal coherence caches.
        """
        dGeomTriMeshClearTCCache(self.gid)

    def getTriangle(self, int idx):
        """getTriangle(idx) -> (v0, v1, v2)

        @param idx: Triangle index
        @type idx: int
        """

        cdef dVector3 v0, v1, v2
        cdef dVector3* vp0
        cdef dVector3* vp1
        cdef dVector3* vp2

        vp0 = <dVector3*>v0
        vp1 = <dVector3*>v1
        vp2 = <dVector3*>v2

        dGeomTriMeshGetTriangle(self.gid, idx, vp0, vp1, vp2)
        return ((v0[0],v0[1],v0[2]), (v1[0],v1[1],v1[2]), (v2[0],v2[1],v2[2]))
        

