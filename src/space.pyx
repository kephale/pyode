# Space
cdef class Space(GeomObject):
    """Space class (container for geometry objects).

    A Space object is a container for geometry objects which are used
    to do collision detection.
    The space does high level collision culling, which means that it
    can identify which pairs of geometry objects are potentially
    touching.

    This Space class can be used for both, a SimpleSpace and a HashSpace
    (see ODE documentation).

     >>> space = Space(type=0)   # Create a SimpleSpace
     >>> space = Space(type=1)   # Create a HashSpace
    """

    # The id of the space. Actually this is a copy of the value in self.gid
    # (as the Space is derived from GeomObject) which can be used without
    # casting whenever a *space* id is required.
    cdef dSpaceID sid
    
    # Dictionary with Geomobjects. Key is the ID (geom._id()) and the value
    # is the geom object (Python wrapper). This is used in collide_callback()
#    cdef object geom_dict

    def __new__(self, type=0):
        if type==0:
            self.sid = dSimpleSpaceCreate(0)
        else:
            self.sid = dHashSpaceCreate(0)

        # Copy the ID
        self.gid = <dGeomID>self.sid

        dSpaceSetCleanup(self.sid, 0)
        _geom_c2py_lut[<long>self.sid]=self

    def __init__(self, type=0):
        pass
#        self.geom_dict = {}

    def __dealloc__(self):
        if self.gid!=NULL:
            dSpaceDestroy(self.sid)
            self.sid = NULL
            self.gid = NULL

#    def _addgeom(self, geom):
#        """Insert the geom object into the dictionary (internal method).
#
#        This method has to called in the constructor of a geom object.
#        """
#        self.geom_dict[geom._id()]=geom


#    def _id2geom(self, id):
#        """Get the Python wrapper that corresponds to an ID.
#
#        The ID is the integer value, as returned by geom._id().
#        If the ID is unknown then None is returned.
#        """
#        if id in self.geom_dict:
#            return self.geom_dict[id]
#        else:
#            return None
       
    def _id(self):
        cdef long id
        id = <long>self.sid
        return id

    def add(self, GeomObject geom):
        """add(geom)

        Add a geom to a space. This does nothing if the geom is
        already in the space.

        @param geom: Geom object to add
        @type geom: GeomObject
        """
        
        dSpaceAdd(self.sid, geom.gid)

    def remove(self, GeomObject geom):
        """remove(geom)

        Remove a geom from a space.

        @param geom: Geom object to remove
        @type geom: GeomObject
        """
        dSpaceRemove(self.sid, geom.gid)

    def query(self, GeomObject geom):
        """query(geom) -> bool

        Return True if the given geom is in the space.

        @param geom: Geom object to check
        @type geom: GeomObject
        """
        return dSpaceQuery(self.sid, geom.gid)

    def getNumGeoms(self):
        """getNumGeoms() -> int

        Return the number of geoms contained within the space.
        """
        return dSpaceGetNumGeoms(self.sid)

    def getGeom(self, int idx):
        """getGeom(idx) -> GeomObject

        Return the geom with the given index contained within the space.

        @param idx: Geom index (0,1,...,getNumGeoms()-1)
        @type idx: int
        """
        cdef dGeomID gid

        # Check the index
        if idx<0 or idx>=dSpaceGetNumGeoms(self.sid):
            raise IndexError, "geom index out of range"

        gid = dSpaceGetGeom(self.sid, idx)
        if <long>gid not in _geom_c2py_lut:
            raise RuntimeError, "geom id cannot be translated to a Python object"

        return _geom_c2py_lut[<long>gid]

    def collide(self, arg, callback):
        """Do collision detection.

        Call a callback function one or more times, for all
        potentially intersecting objects in the space. The callback
        function takes 3 arguments:

        def NearCallback(arg, geom1, geom2):

        The arg parameter is just passed on to the callback function.
        Its meaning is user defined. The geom1 and geom2 arguments are
        the geometry objects that may be near each other. The callback
        function can call the function collide() (not the Space
        method) on geom1 and geom2, perhaps first determining
        whether to collide them at all based on other information.
        """
        
        cdef void* data
        cdef object tup
        tup = (callback, arg)
        data = <void*>tup
        dSpaceCollide(self.sid, data, collide_callback)
        

# Callback function for the dSpaceCollide() call in the Space.collide() method
# The data parameter is a tuple (Python-Callback, Arguments).
# The function calls a Python callback function with 3 arguments:
# def callback(UserArg, Geom1, Geom2)
# Geom1 and Geom2 are instances of GeomXyz classes.
cdef void collide_callback(void* data, dGeomID o1, dGeomID o2):
    cdef object tup
#    cdef Space space
    cdef long id1, id2

#    if (dGeomGetBody(o1)==dGeomGetBody(o2)):
#        return
    
    tup = <object>data
    callback, arg = tup
    id1 = <long>o1
    id2 = <long>o2
    g1=_geom_c2py_lut[id1]
    g2=_geom_c2py_lut[id2]
    callback(arg,g1,g2)
