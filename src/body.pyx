
# Body
cdef class Body:
    """Rigid body.
    """

    cdef dBodyID bid
    # A reference to the world so that the world won't be destroyed while
    # there are still joints using it.
    cdef object world
    
    # A dictionary with user attributes
    # (set via __getattr__ and __setattr__)
    cdef object userattribs

    def __new__(self, World world):
        cdef World w

        self.bid = NULL
        if world!=None:
            w = world
            self.bid = dBodyCreate(w.wid)

    def __init__(self, world):
        self.world = world
        self.userattribs = {}

    def __dealloc__(self):
        if self.bid!=NULL:
            dBodyDestroy(self.bid)

    def __getattr__(self, name):
        try:
            return self.userattribs[name]
        except:
            raise AttributeError, "Body object has no attribute '%s'"%name
            
    def __setattr__(self, name, value):
        self.userattribs[name] = value

    def __delattr__(self, name):
        try:
            del self.userattribs[name]
        except:
            raise AttributeError, "Body object has no attribute '%s'"%name

    # setPosition
    def setPosition(self, pos):
        dBodySetPosition(self.bid, pos[0], pos[1], pos[2])

    # getPosition
    def getPosition(self):
        cdef dReal* p
        # The "const" in the original return value is cast away
        p = <dReal*>dBodyGetPosition(self.bid)
        return (p[0],p[1],p[2])

    # setRotation
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
        dBodySetRotation(self.bid, m)

    # getRotation
    def getRotation(self):
        cdef dReal* m
        # The "const" in the original return value is cast away
        m = <dReal*>dBodyGetRotation(self.bid)
        return [m[0],m[1],m[2],m[4],m[5],m[6],m[8],m[9],m[10]]

    def getQuaternion(self):
        cdef dReal* q
        q = <dReal*>dBodyGetQuaternion(self.bid)
        return [q[0], q[1], q[2], q[3]]

    # setLinearVel
    def setLinearVel(self, pos):
        dBodySetLinearVel(self.bid, pos[0], pos[1], pos[2])

    # getLinearVel
    def getLinearVel(self):
        cdef dReal* p
        # The "const" in the original return value is cast away
        p = <dReal*>dBodyGetLinearVel(self.bid)
        return (p[0],p[1],p[2])

    # setAngularVel
    def setAngularVel(self, pos):
        dBodySetAngularVel(self.bid, pos[0], pos[1], pos[2])

    # getAngularVel
    def getAngularVel(self):
        cdef dReal* p
        # The "const" in the original return value is cast away
        p = <dReal*>dBodyGetAngularVel(self.bid)
        return (p[0],p[1],p[2])
    
    # setMass
    def setMass(self, Mass mass):
        dBodySetMass(self.bid, &mass._mass)

    # getMass
    def getMass(self):
        cdef Mass m
        m=Mass()
        dBodyGetMass(self.bid, &m._mass)
        return m

    # addForce
    def addForce(self, f):
        dBodyAddForce(self.bid, f[0], f[1], f[2])

    # addTorque
    def addTorque(self, f):
        dBodyAddTorque(self.bid, f[0], f[1], f[2])

    # addRelForce
    def addRelForce(self, f):
        dBodyAddRelForce(self.bid, f[0], f[1], f[2])

    # addRelTorque
    def addRelTorque(self, f):
        dBodyAddRelTorque(self.bid, f[0], f[1], f[2])

    # addForceAtPos
    def addForceAtPos(self, f, p):
        dBodyAddForceAtPos(self.bid, f[0], f[1], f[2], p[0], p[1], p[2])

    # addForceAtRelPos
    def addForceAtRelPos(self, f, p):
        dBodyAddForceAtRelPos(self.bid, f[0], f[1], f[2], p[0], p[1], p[2])

    # addRelForceAtPos
    def addRelForceAtPos(self, f, p):
        dBodyAddRelForceAtPos(self.bid, f[0], f[1], f[2], p[0], p[1], p[2])

    # addRelForceAtRelPos
    def addRelForceAtRelPos(self, f, p):
        dBodyAddRelForceAtRelPos(self.bid, f[0], f[1], f[2], p[0], p[1], p[2])

    # getForce
    def getForce(self):
        cdef dReal* f
        # The "const" in the original return value is cast away
        f = <dReal*>dBodyGetForce(self.bid)
        return (f[0],f[1],f[2])

    # getTorque
    def getTorque(self):
        cdef dReal* f
        # The "const" in the original return value is cast away
        f = <dReal*>dBodyGetTorque(self.bid)
        return (f[0],f[1],f[2])

    # setForce
    def setForce(self, f):
        dBodySetForce(self.bid, f[0], f[1], f[2])

    # setTorque
    def setTorque(self, f):
        dBodySetTorque(self.bid, f[0], f[1], f[2])
        
    # Enable
    def enable(self):
        dBodyEnable(self.bid)
        
    # Disable
    def disable(self):
        dBodyDisable(self.bid)
        
    # isEnabled
    def isEnabled(self):
        return dBodyIsEnabled(self.bid)
        
    # setFiniteRotationMode
    def setFiniteRotationMode(self, mode):
        dBodySetFiniteRotationMode(self.bid, mode)
        
    # getFiniteRotationMode
    def getFiniteRotationMode(self):
        return dBodyGetFiniteRotationMode(self.bid)

    # setFiniteRotationAxis
    def setFiniteRotationAxis(self, a):
        dBodySetFiniteRotationAxis(self.bid, a[0], a[1], a[2])

    # getFiniteRotationAxis
    def getFiniteRotationAxis(self):
        cdef dVector3 p
        # The "const" in the original return value is cast away
        dBodyGetFiniteRotationAxis(self.bid, p)
        return (p[0],p[1],p[2])
        
    # getNumJoints
    def getNumJoints(self):
        return dBodyGetNumJoints(self.bid)

    # setGravityMode
    def setGravityMode(self, mode):
        dBodySetGravityMode(self.bid, mode)
        
    # getGravityMode
    def getGravityMode(self):
        return dBodyGetGravityMode(self.bid)
