# joints

# For every joint type there is a separate class that wraps this joint.
# These classes are derived from the base class "Joint" that contains
# all the common stuff (including destruction).
# The ODE joint is created in the constructor and destroyed in the destructor.
# So it's the respective Python wrapper class that has ownership of the
# ODE joint. If joint groups are used it can happen that an ODE joint gets
# destroyed outside of its Python wrapper (whenever you empty the group).
# In such cases the Python wrapper has to be notified so that it dismisses
# its pointer. This is done by calling _destroyed() on the respective
# Python wrapper (which is done by the JointGroup wrapper).


######################################################################

# JointGroup
cdef class JointGroup:
    """Joint group."""

    # JointGroup ID
    cdef dJointGroupID gid
    # A list of Python joints that were added to the group
    cdef object jointlist

    def __new__(self):
        self.gid = dJointGroupCreate(0)

    def __init__(self):
        self.jointlist = []

    def __dealloc__(self):
        if self.gid!=NULL:
            dJointGroupDestroy(self.gid)

    # empty
    def empty(self):
        dJointGroupEmpty(self.gid)
        for j in self.jointlist:
            j._destroyed()
        self.jointlist = []


    def _addjoint(self, j):
        """Add a joint to the group.

        This is an internal method that is called by the joints.
        The group has to know the Python wrappers because it has to
        notify them when the group is emptied (so that the ODE joints
        won't get destroyed twice). The notification is done by
        calling _destroyed() on the Python joints.
        """
        self.jointlist.append(j)


######################################################################

cdef class Joint:

    # Joint id as returned by dJointCreateXxx()
    cdef dJointID jid
    # A reference to the world so that the world won't be destroyed while
    # there are still joints using it.
    cdef object world
    # The feedback buffer
    cdef dJointFeedback* feedback

    def __new__(self, *a, **kw):
        self.jid = NULL
        self.world = None
        self.feedback = NULL

    def __init__(self, *a, **kw):
        raise NotImplementedError, "The Joint base class can't be used directly."

    def __dealloc__(self):
        self.setFeedback(False)
        if self.jid!=NULL:
            dJointDestroy(self.jid)

    # _destroyed
    def _destroyed(self):
        """Notify the joint object about an external destruction of the ODE joint.

        This method has to be called when the underlying ODE object
        was destroyed by someone else (e.g. by a joint group). The Python
        wrapper will then refrain from destroying it again.
        """
        self.jid = NULL

    # attach
    def attach(self, Body Body1, Body Body2):
        """TODO: What if there's only one body."""
        dJointAttach(self.jid, Body1.bid, Body2.bid)

    # setFeedback
    def setFeedback(self, flag=1):
        """Create a feedback buffer.

        If flag is True then a buffer is allocated, otherwise it is
        removed.
        """
        if flag:
            # Was there already a buffer allocated? then we're finished
            if self.feedback!=NULL:
                return
            # Allocate a buffer and pass it to ODE
            self.feedback = <dJointFeedback*>malloc(sizeof(dJointFeedback))
            if self.feedback==NULL:
                raise MemoryError("can't allocate feedback buffer")
            dJointSetFeedback(self.jid, self.feedback)
        else:
            if self.feedback!=NULL:
                # Free a previously allocated buffer
                dJointSetFeedback(self.jid, NULL)
                free(self.feedback)
                self.feedback = NULL
        
    # getFeedback
    def getFeedback(self):
        """Get the forces/torques applied to the joint.

        If feedback is activated (i.e. setFeedback(True) was called)
        then this method returns a tuple (force1, torque1, force2, torque2)
        with the forces and torques applied to body 1 and body 2.
        The forces/torques are given as 3-tuples.

        If feedback is deactivated then the method returns None.
        """
        cdef dJointFeedback* fb
        
        fb = dJointGetFeedback(self.jid)
        if (fb==NULL):
            return None
           
        f1 = (fb.f1[0], fb.f1[1], fb.f1[2])
        t1 = (fb.t1[0], fb.t1[1], fb.t1[2])
        f2 = (fb.f2[0], fb.f2[1], fb.f2[2])
        t2 = (fb.t2[0], fb.t2[1], fb.t2[2])
        return (f1,t1,f2,t2)

######################################################################
       
        
# BallJoint
cdef class BallJoint(Joint):
    """Ball joint.
    """

    def __new__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreateBall(world.wid, jgid)

    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)
            
    # setAnchor
    def setAnchor(self, pos):
        dJointSetBallAnchor(self.jid, pos[0], pos[1], pos[2])
    
    # getAnchor
    def getAnchor(self):
        cdef dVector3 p
        dJointGetBallAnchor(self.jid, p)
        return (p[0],p[1],p[2])

    # setParam
    def setParam(self, param, value):
        pass

    # getParam
    def getParam(self, param):
        return 0.0
        
    
# HingeJoint
cdef class HingeJoint(Joint):
    """Hinge joint.
    """

    def __new__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid
        
        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreateHinge(world.wid, jgid)
        
    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)

    # setAnchor
    def setAnchor(self, pos):
        dJointSetHingeAnchor(self.jid, pos[0], pos[1], pos[2])
    
    # getAnchor
    def getAnchor(self):
        cdef dVector3 p
        dJointGetHingeAnchor(self.jid, p)
        return (p[0],p[1],p[2])

    # setAxis
    def setAxis(self, axis):
        dJointSetHingeAxis(self.jid, axis[0], axis[1], axis[2])
    
    # getAxis
    def getAxis(self):
        cdef dVector3 a
        dJointGetHingeAxis(self.jid, a)
        return (a[0],a[1],a[2])

    # getAngle
    def getAngle(self):
        return dJointGetHingeAngle(self.jid)

    # getAngleRate
    def getAngleRate(self):
        return dJointGetHingeAngleRate(self.jid)

    # setParam
    def setParam(self, param, value):
        dJointSetHingeParam(self.jid, param, value)

    # getParam
    def getParam(self, param):
        return dJointGetHingeParam(self.jid, param)
        
        
# SliderJoint
cdef class SliderJoint(Joint):
    """Slider joint.
    """

    def __new__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreateSlider(world.wid, jgid)

    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)
          
    # setAxis
    def setAxis(self, axis):
        dJointSetSliderAxis(self.jid, axis[0], axis[1], axis[2])
    
    # getAxis
    def getAxis(self):
        cdef dVector3 a
        dJointGetSliderAxis(self.jid, a)
        return (a[0],a[1],a[2])

    # getPosition
    def getPosition(self):
        return dJointGetSliderPosition(self.jid)

    # getPositionRate
    def getPositionRate(self):
        return dJointGetSliderPositionRate(self.jid)

    # setParam
    def setParam(self, param, value):
        dJointSetSliderParam(self.jid, param, value)

    # getParam
    def getParam(self, param):
        return dJointGetSliderParam(self.jid, param)
        
    
# UniversalJoint
cdef class UniversalJoint(Joint):
    """Universal joint.
    """

    def __new__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreateUniversal(world.wid, jgid)

    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)

    # setAnchor
    def setAnchor(self, pos):
        dJointSetUniversalAnchor(self.jid, pos[0], pos[1], pos[2])
    
    # getAnchor
    def getAnchor(self):
        cdef dVector3 p
        dJointGetUniversalAnchor(self.jid, p)
        return (p[0],p[1],p[2])

    # setAxis1
    def setAxis1(self, axis):
        dJointSetUniversalAxis1(self.jid, axis[0], axis[1], axis[2])
    
    # getAxis1
    def getAxis1(self):
        cdef dVector3 a
        dJointGetUniversalAxis1(self.jid, a)
        return (a[0],a[1],a[2])

    # setAxis2
    def setAxis2(self, axis):
        dJointSetUniversalAxis2(self.jid, axis[0], axis[1], axis[2])
    
    # getAxis2
    def getAxis2(self):
        cdef dVector3 a
        dJointGetUniversalAxis2(self.jid, a)
        return (a[0],a[1],a[2])

    # setParam
    def setParam(self, param, value):
        dJointSetUniversalParam(self.jid, param, value)

    # getParam
    def getParam(self, param):
       return dJointGetUniversalParam(self.jid, param)

    
# Hinge2Joint
cdef class Hinge2Joint(Joint):
    """Hinge2 joint.
    """

    def __new__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreateHinge2(world.wid, jgid)

    def __init__(self, World world, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)

    # setAnchor
    def setAnchor(self, pos):
        dJointSetHinge2Anchor(self.jid, pos[0], pos[1], pos[2])
    
    # getAnchor
    def getAnchor(self):
        cdef dVector3 p
        dJointGetHinge2Anchor(self.jid, p)
        return (p[0],p[1],p[2])

    # setAxis1
    def setAxis1(self, axis):
        dJointSetHinge2Axis1(self.jid, axis[0], axis[1], axis[2])
    
    # getAxis1
    def getAxis1(self):
        cdef dVector3 a
        dJointGetHinge2Axis1(self.jid, a)
        return (a[0],a[1],a[2])

    # setAxis2
    def setAxis2(self, axis):
        dJointSetHinge2Axis2(self.jid, axis[0], axis[1], axis[2])
    
    # getAxis2
    def getAxis2(self):
        cdef dVector3 a
        dJointGetHinge2Axis2(self.jid, a)
        return (a[0],a[1],a[2])

    # getAngle
    def getAngle1(self):
        return dJointGetHinge2Angle1(self.jid)

    # getAngle1Rate
    def getAngle1Rate(self):
        return dJointGetHinge2Angle1Rate(self.jid)

    # getAngle2Rate
    def getAngle2Rate(self):
        return dJointGetHinge2Angle2Rate(self.jid)

    # setParam
    def setParam(self, param, value):
        dJointSetHinge2Param(self.jid, param, value)

    # getParam
    def getParam(self, param):
        return dJointGetHinge2Param(self.jid, param)

    
# FixedJoint
cdef class FixedJoint(Joint):
    """Fixed joint.
    """

    def __new__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreateFixed(world.wid, jgid)

    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)

    # setFixed
    def setFixed(self):
        dJointSetFixed(self.jid)

        
# ContactJoint
cdef class ContactJoint(Joint):
    """Contact joint.
    """

    def __new__(self, World world not None, jointgroup, Contact contact):
        cdef JointGroup jg
        cdef dJointGroupID jgid
        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreateContact(world.wid, jgid, &contact._contact)

    def __init__(self, World world not None, jointgroup, Contact contact):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)


