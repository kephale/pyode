
# World
cdef class World:
    """Dynamics world.
    
    The world object is a container for rigid bodies and joints.
    """

    cdef dWorldID wid

    def __new__(self):
        self.wid = dWorldCreate()

    def __dealloc__(self):
        if self.wid!=NULL:
            dWorldDestroy(self.wid)

    # setGravity
    def setGravity(self, gravity):
        """Set the world's global gravity vector."""
        dWorldSetGravity(self.wid, gravity[0], gravity[1], gravity[2])

    # getGravity
    def getGravity(self):
        """Get the world's global gravity vector."""
        cdef dVector3 g
        dWorldGetGravity(self.wid, g)
        return (g[0],g[1],g[2])

    # setERP
    def setERP(self, erp):
        dWorldSetERP(self.wid, erp)

    # getERP
    def getERP(self):
        return dWorldGetERP(self.wid)

    # setCFM
    def setCFM(self, cfm):
        dWorldSetCFM(self.wid, cfm)

    # getCFM
    def getCFM(self):
        return dWorldGetCFM(self.wid)

    # step
    def step(self, stepsize):
        dWorldStep(self.wid, stepsize)

    # quickStep
    def quickStep(self, stepsize):
        dWorldQuickStep(self.wid, stepsize)

    # setQuickStepNumIterations
    def setQuickStepNumIterations(self, num):
        dWorldSetQuickStepNumIterations(self.wid, num)

    # getQuickStepNumIterations
    def getQuickStepNumIterations(self):
        return dWorldGetQuickStepNumIterations(self.wid)

    # createBody
    def createBody(self):
        return Body(self)

    # createBallJoint
    def createBallJoint(self, jointgroup=None):
        return BallJoint(self, jointgroup)

    # createHingeJoint
    def createHingeJoint(self, jointgroup=None):
        return HingeJoint(self, jointgroup)

    # createHinge2Joint
    def createHinge2Joint(self, jointgroup=None):
        return Hinge2Joint(self, jointgroup)

    # createSliderJoint
    def createSliderJoint(self, jointgroup=None):
        return SliderJoint(self, jointgroup)

    # createFixedJoint
    def createFixedJoint(self, jointgroup=None):
        return FixedJoint(self, jointgroup)

    # createContactJoint
    def createContactJoint(self, jointgroup, contact):
        return ContactJoint(self, jointgroup, contact)
