# Trimesh dummy classes.

# These classes are included by the file _trimesh_switch.pyx if the
# variable TRIMESH_SUPPORT was set to False in the setup script.


cdef class TriMeshData:
    """This class stores the mesh data.

    This is only a dummy class that's used when trimesh support was disabled.
    """

    def __init__(self):
        raise NotImplementedError, "Trimesh support is disabled"


cdef class GeomTriMesh(GeomObject):
    """Trimesh object.
    
    This is only a dummy class that's used when trimesh support was disabled.
    """

    def __init__(self, TriMeshData data not None, space=None):
        raise NotImplementedError, "Trimesh support is disabled"
