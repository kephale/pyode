# Trimesh

# This file is included by _trimesh_switch.pyx if the variable
# TRIMESH_SUPPORT was set to True in the setup script.

# GeomTriMesh
cdef class GeomTriMesh(GeomObject):
    """TriMesh object.

    To construct the trimesh geom you need a TriMeshData object that
    stores the actual mesh. This object has to be passed as first
    argument to the constructor.

    Constructor::
    
      GeomTriMesh(data, space=None)    
    """

    # Keep a reference to the data
    cdef TriMeshData data

    def __new__(self, TriMeshData data not None, space=None):
        cdef SpaceBase sp
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
        

