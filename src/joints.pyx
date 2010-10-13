######################################################################
# Python Open Dynamics Engine Wrapper
# Copyright (C) 2004 PyODE developers (see file AUTHORS)
# All rights reserved.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of EITHER:
#   (1) The GNU Lesser General Public License as published by the Free
#       Software Foundation; either version 2.1 of the License, or (at
#       your option) any later version. The text of the GNU Lesser
#       General Public License is included with this library in the
#       file LICENSE.
#   (2) The BSD-style license that is included with this library in
#       the file LICENSE-BSD.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the files
# LICENSE and LICENSE-BSD for more details.
######################################################################

# For every joint type there is a separate class that wraps that joint.
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
    """Joint group.

    Constructor::

      JointGroup()
    """

    # JointGroup ID
    cdef dJointGroupID gid
    # A list of Python joints that were added to the group
    cdef object jointlist

    def __cinit__(self):
        self.gid = dJointGroupCreate(0)

    def __init__(self):
        self.jointlist = []

    def __dealloc__(self):
        if self.gid!=NULL:
            for j in self.jointlist:
                j._destroyed()
            dJointGroupDestroy(self.gid)

    # empty
    def empty(self):
        """empty()

        Destroy all joints in the group.
        """
        dJointGroupEmpty(self.gid)
        for j in self.jointlist:
            j._destroyed()
        self.jointlist = []


    def _addjoint(self, j):
        """_addjoint(j)

        Add a joint to the group.  This is an internal method that is
        called by the joints.  The group has to know the Python
        wrappers because it has to notify them when the group is
        emptied (so that the ODE joints won't get destroyed
        twice). The notification is done by calling _destroyed() on
        the Python joints.

        @param j: The joint to add
        @type j: Joint
        """
        self.jointlist.append(j)


######################################################################


class JointParam(object):
    __slots__ = ('param_id')

    def __init__(self, param_id):
        self.param_id = param_id

    def __get__(self, instance, owner):
        try:
            i = instance._index
            if i < 1: i = 1
            if i > 3: i = 3
            #~ print "get", instance._index, self.param_id
            val = instance._getParam(self.param_id + ParamGroup * (i-1))
        finally:
            instance._index = 1
        return val

    def __set__(self, instance, value):
        try:
            i = instance._index
            if i < 1: i = 1
            if i > 3: i = 3
            #~ print "set", instance._index, self.param_id
            instance._setParam(self.param_id + ParamGroup * (i-1), value)
        finally:
            instance._index = 1


class JointParams(object):
    # Do not let the user add custom fields to this class
    # He may mispell a parameter name withoug getting any warning/error
    __slots__ = ('_index', '_setParam', '_getParam', 'lo_stop', 'hi_stop', 'vel', 'fmax', 'fudge_factor', 'bounce', 'cfm', 'stop_erp', 'stop_cfm', 'suspension_erp', 'suspension_cfm')
    lo_stop = JointParam(ParamLoStop )
    hi_stop = JointParam(ParamHiStop)
    vel = JointParam(ParamVel)
    fmax = JointParam(ParamFMax)
    fudge_factor = JointParam(ParamFudgeFactor)
    bounce = JointParam(ParamBounce)
    cfm = JointParam(ParamCFM)
    stop_erp = JointParam(ParamStopERP)
    stop_cfm = JointParam(ParamStopCFM)
    suspension_erp = JointParam(ParamSuspensionERP)
    suspension_cfm = JointParam(ParamSuspensionCFM)

    _index = 1

    def __init__(self, getParam, setParam):
        self._setParam = setParam
        self._getParam = getParam

    def __getitem__(self, key):
        self._index = int(key)
        return self


# Joint
cdef class Joint:
    """Base class for all joint classes."""

    # Joint id as returned by dJointCreateXxx()
    cdef dJointID jid
    # A reference to the world so that the world won't be destroyed while
    # there are still joints using it.
    cdef object world
    # The feedback buffer
    cdef dJointFeedback* feedback

    cdef object body1
    cdef object body2

    cdef readonly object param

    cdef void (*setJointParam)(dJointID, int, dReal)
    cdef dReal (*getJointParam)(dJointID, int)

    # A dictionary with user attributes
    # (set via __getattr__ and __setattr__)
    cdef object userattribs

    def __cinit__(self, *a, **kw):
        self.jid = NULL
        self.world = None
        self.feedback = NULL
        self.body1 = None
        self.body2 = None
        self.userattribs = {}
        self.setJointParam = NULL
        self.getJointParam = NULL

    def __init__(self, *a, **kw):
        raise NotImplementedError, "The Joint base class can't be used directly."

    def __dealloc__(self):
        self.setFeedback(False)
        if self.jid!=NULL and self.world:
            dJointDestroy(self.jid)

    def __getattr__(self, name):
        try:
            return self.userattribs[name]
        except:
            raise AttributeError, "Joint object has no attribute '%s'"%name

    def __setattr__(self, name, value):
        self.userattribs[name] = value

    def __delattr__(self, name):
        try:
            del self.userattribs[name]
        except:
            raise AttributeError, "Joint object has no attribute '%s'"%name

    # _destroyed
    def _destroyed(self):
        """Notify the joint object about an external destruction of the ODE joint.

        This method has to be called when the underlying ODE object
        was destroyed by someone else (e.g. by a joint group). The Python
        wrapper will then refrain from destroying it again.
        """
        self.jid = NULL

    # attach
    def attach(self, Body body1, Body body2):
        """attach(body1, body2)

        Attach the joint to some new bodies. A body can be attached
        to the environment by passing None as second body.

        @param body1: First body
        @param body2: Second body
        @type body1: Body
        @type body2: Body
        """
        cdef dBodyID id1, id2

        if body1==None:
            id1 = NULL
        else:
            id1 = body1.bid

        if body2==None:
            id2 = NULL
        else:
            id2 = body2.bid

        self.body1 = body1
        self.body2 = body2
        dJointAttach(self.jid, id1, id2)

    # getBody
    def getBody(self, index):
        """getBody(index) -> Body

        Return the bodies that this joint connects. If index is 0 the
        "first" body will be returned, corresponding to the body1
        argument of the attach() method. If index is 1 the "second" body
        will be returned, corresponding to the body2 argument of the
        attach() method.

        @param index: Bodx index (0 or 1).
        @type index: int
        """

        if (index == 0):
            return self.body1
        elif (index == 1):
            return self.body2
        else:
            raise IndexError()

    def enable(self):
        dJointEnable(self.jid)

    def disable(self):
        dJointDisable(self.jid)

    def isEnabled(self):
        return dJointIsEnabled(<dJointID>self.jid)

    # setFeedback
    def setFeedback(self, flag=1):
        """setFeedback(flag=True)

        Create a feedback buffer. If flag is True then a buffer is
        allocated and the forces/torques applied by the joint can
        be read using the getFeedback() method. If flag is False the
        buffer is released.

        @param flag: Specifies whether a buffer should be created or released
        @type flag: bool
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
        """getFeedback() -> (force1, torque1, force2, torque2)

        Get the forces/torques applied by the joint. If feedback is
        activated (i.e. setFeedback(True) was called) then this method
        returns a tuple (force1, torque1, force2, torque2) with the
        forces and torques applied to body 1 and body 2.  The
        forces/torques are given as 3-tuples.

        If feedback is deactivated then the method always returns None.
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


    # setParam
    def setParam(self, param, value):
        """setParam(param, value)

        Set limit/motor parameters for the joint.

        param is one of ParamLoStop, ParamHiStop, ParamVel, ParamFMax,
        ParamFudgeFactor, ParamBounce, ParamCFM, ParamStopERP, ParamStopCFM,
        ParamSuspensionERP, ParamSuspensionCFM.

        These parameter names can be optionally followed by a digit (2
        or 3) to indicate the second or third set of parameters.

        @param param: Selects the parameter to set
        @param value: Parameter value
        @type param: int
        @type value: float
        """

        self.setJointParam(self.jid, param, value)

    # getParam
    def getParam(self, param):
        """getParam(param) -> float

        Get limit/motor parameters for the joint.

        param is one of ParamLoStop, ParamHiStop, ParamVel, ParamFMax,
        ParamFudgeFactor, ParamBounce, ParamCFM, ParamStopERP, ParamStopCFM,
        ParamSuspensionERP, ParamSuspensionCFM.

        These parameter names can be optionally followed by a digit (2
        or 3) to indicate the second or third set of parameters.

        @param param: Selects the parameter to read
        @type param: int
        """
        return self.getJointParam(self.jid, param)


######################################################################


# BallJoint
cdef class BallJoint(Joint):
    """Ball joint.

    Constructor::

      BallJoint(world, jointgroup=None)
    """

    def __cinit__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreateBall(world.wid, jgid)

        self.setJointParam = dJointSetBallParam
        self.getJointParam = dJointGetBallParam


    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)
        self.param = JointParams(self.getParam, self.setParam)

    # setAnchor
    def setAnchor(self, pos):
        """setAnchor(pos)

        Set the joint anchor point which must be specified in world
        coordinates.

        @param pos: Anchor position
        @type pos: 3-sequence of floats
        """
        dJointSetBallAnchor(self.jid, pos[0], pos[1], pos[2])

    # getAnchor
    def getAnchor(self):
        """getAnchor() -> 3-tuple of floats

        Get the joint anchor point, in world coordinates.  This
        returns the point on body 1.  If the joint is perfectly
        satisfied, this will be the same as the point on body 2.
        """

        cdef dVector3 p
        dJointGetBallAnchor(self.jid, p)
        return (p[0],p[1],p[2])

    # getAnchor2
    def getAnchor2(self):
        """getAnchor2() -> 3-tuple of floats

        Get the joint anchor point, in world coordinates.  This
        returns the point on body 2. If the joint is perfectly
        satisfied, this will be the same as the point on body 1.
        """

        cdef dVector3 p
        dJointGetBallAnchor2(self.jid, p)
        return (p[0],p[1],p[2])



# HingeJoint
cdef class HingeJoint(Joint):
    """Hinge joint.

    Constructor::

      HingeJoint(world, jointgroup=None)
    """

    def __cinit__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreateHinge(world.wid, jgid)

        self.setJointParam = dJointSetHingeParam
        self.getJointParam = dJointGetHingeParam

    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)
        self.param = JointParams(self.getParam, self.setParam)



    # setAnchor
    def setAnchor(self, pos):
        """setAnchor(pos)

        Set the hinge anchor which must be given in world coordinates.

        @param pos: Anchor position
        @type pos: 3-sequence of floats
        """
        dJointSetHingeAnchor(self.jid, pos[0], pos[1], pos[2])

    # getAnchor
    def getAnchor(self):
        """getAnchor() -> 3-tuple of floats

        Get the joint anchor point, in world coordinates. This returns
        the point on body 1. If the joint is perfectly satisfied, this
        will be the same as the point on body 2.
        """
        cdef dVector3 p
        dJointGetHingeAnchor(self.jid, p)
        return (p[0],p[1],p[2])

    # getAnchor2
    def getAnchor2(self):
        """getAnchor2() -> 3-tuple of floats

        Get the joint anchor point, in world coordinates. This returns
        the point on body 2. If the joint is perfectly satisfied, this
        will be the same as the point on body 1.
        """
        cdef dVector3 p
        dJointGetHingeAnchor2(self.jid, p)
        return (p[0],p[1],p[2])

    # setAxis
    def setAxis(self, axis):
        """setAxis(axis)

        Set the hinge axis.

        @param axis: Hinge axis
        @type axis: 3-sequence of floats
        """
        dJointSetHingeAxis(self.jid, axis[0], axis[1], axis[2])

    def setAxisAndAngleOffset(self, axis, angle_offset):
        """setAxisAndAngleOffset(axis)

        Set the hinge axis and angle offset.
        Wraps dJointSetHingeAxisOffset.

        @param axis: Hinge axis
        @type axis: 3-sequence of floats
        """
        dJointSetHingeAxisOffset(self.jid, axis[0], axis[1], axis[2], angle_offset)

    def setAngleOffset(self, angle_offset):
        """setAngleOffset(axis)

        Set the angle offset.
        """
        cdef dVector3 a
        dJointGetHingeAxis(self.jid, a)
        dJointSetHingeAxisOffset(self.jid, a[0], a[1], a[2], angle_offset)

    # getAxis
    def getAxis(self):
        """getAxis() -> 3-tuple of floats

        Get the hinge axis.
        """
        cdef dVector3 a
        dJointGetHingeAxis(self.jid, a)
        return (a[0],a[1],a[2])

    # getAngle
    def getAngle(self):
        """getAngle() -> float

        Get the hinge angle. The angle is measured between the two
        bodies, or between the body and the static environment. The
        angle will be between -pi..pi.

        When the hinge anchor or axis is set, the current position of
        the attached bodies is examined and that position will be the
        zero angle.
        """

        return dJointGetHingeAngle(self.jid)

    # getAngleRate
    def getAngleRate(self):
        """getAngleRate() -> float

        Get the time derivative of the angle.
        """
        return dJointGetHingeAngleRate(self.jid)

    # addTorque
    def addTorque(self, torque):
        """addTorque(torque)

        Applies the torque about the hinge axis.

        @param torque: Torque magnitude
        @type torque: float
        """
        dJointAddHingeTorque(self.jid, torque)


# SliderJoint
cdef class SliderJoint(Joint):
    """Slider joint.

    Constructor::

      SlideJoint(world, jointgroup=None)
    """

    def __cinit__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreateSlider(world.wid, jgid)

        self.setJointParam = dJointSetSliderParam
        self.getJointParam = dJointGetSliderParam

    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)
        self.param = JointParams(self.getParam, self.setParam)

    # setAxis
    def setAxis(self, axis):
        """setAxis(axis)

        Set the slider axis parameter.

        @param axis: Slider axis
        @type axis: 3-sequence of floats
        """
        dJointSetSliderAxis(self.jid, axis[0], axis[1], axis[2])

    # getAxis
    def getAxis(self):
        """getAxis() -> 3-tuple of floats

        Get the slider axis parameter.
        """
        cdef dVector3 a
        dJointGetSliderAxis(self.jid, a)
        return (a[0],a[1],a[2])

    # getPosition
    def getPosition(self):
        """getPosition() -> float

        Get the slider linear position (i.e. the slider's "extension").

        When the axis is set, the current position of the attached
        bodies is examined and that position will be the zero
        position.
        """

        return dJointGetSliderPosition(self.jid)

    # getPositionRate
    def getPositionRate(self):
        """getPositionRate() -> float

        Get the time derivative of the position.
        """
        return dJointGetSliderPositionRate(self.jid)

    # addForce
    def addForce(self, force):
        """addForce(force)

        Applies the given force in the slider's direction.

        @param force: Force magnitude
        @type force: float
        """
        dJointAddSliderForce(self.jid, force)


# UniversalJoint
cdef class UniversalJoint(Joint):
    """Universal joint.

    Constructor::

      UniversalJoint(world, jointgroup=None)
    """

    def __cinit__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreateUniversal(world.wid, jgid)

        self.setJointParam = dJointSetUniversalParam
        self.getJointParam = dJointGetUniversalParam

    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)
        self.param = JointParams(self.getParam, self.setParam)

    # setAnchor
    def setAnchor(self, pos):
        """setAnchor(pos)

        Set the universal anchor.

        @param pos: Anchor position
        @type pos: 3-sequence of floats
        """
        dJointSetUniversalAnchor(self.jid, pos[0], pos[1], pos[2])

    # getAnchor
    def getAnchor(self):
        """getAnchor() -> 3-tuple of floats

        Get the joint anchor point, in world coordinates. This returns
        the point on body 1. If the joint is perfectly satisfied, this
        will be the same as the point on body 2.
        """

        cdef dVector3 p
        dJointGetUniversalAnchor(self.jid, p)
        return (p[0],p[1],p[2])

    # getAnchor2
    def getAnchor2(self):
        """getAnchor2() -> 3-tuple of floats

        Get the joint anchor point, in world coordinates. This returns
        the point on body 2. If the joint is perfectly satisfied, this
        will be the same as the point on body 1.
        """

        cdef dVector3 p
        dJointGetUniversalAnchor2(self.jid, p)
        return (p[0],p[1],p[2])

    # setAxis1
    def setAxis1(self, axis):
        """setAxis1(axis)

        Set the first universal axis. Axis 1 and axis 2 should be
        perpendicular to each other.

        @param axis: Joint axis
        @type axis: 3-sequence of floats
        """
        dJointSetUniversalAxis1(self.jid, axis[0], axis[1], axis[2])

    # getAxis1
    def getAxis1(self):
        """getAxis1() -> 3-tuple of floats

        Get the first univeral axis.
        """
        cdef dVector3 a
        dJointGetUniversalAxis1(self.jid, a)
        return (a[0],a[1],a[2])

    # setAxis2
    def setAxis2(self, axis):
        """setAxis2(axis)

        Set the second universal axis. Axis 1 and axis 2 should be
        perpendicular to each other.

        @param axis: Joint axis
        @type axis: 3-sequence of floats
        """
        dJointSetUniversalAxis2(self.jid, axis[0], axis[1], axis[2])

    # getAxis2
    def getAxis2(self):
        """getAxis2() -> 3-tuple of floats

        Get the second univeral axis.
        """
        cdef dVector3 a
        dJointGetUniversalAxis2(self.jid, a)
        return (a[0],a[1],a[2])

    # addTorques
    def addTorques(self, torque1, torque2):
        """addTorques(torque1, torque2)

        Applies torque1 about axis 1, and torque2 about axis 2.

        @param torque1: Torque 1 magnitude
        @param torque2: Torque 2 magnitude
        @type torque1: float
        @type torque2: float
        """
        dJointAddUniversalTorques(self.jid, torque1, torque2)

    def getAngle1(self):
        return dJointGetUniversalAngle1(self.jid)

    def getAngle2(self):
        return dJointGetUniversalAngle2(self.jid)

    def getAngle1Rate(self):
        return dJointGetUniversalAngle1Rate(self.jid)

    def getAngle2Rate(self):
        return dJointGetUniversalAngle2Rate(self.jid)



# Hinge2Joint
cdef class Hinge2Joint(Joint):
    """Hinge2 joint.

    Constructor::

      Hinge2Joint(world, jointgroup=None)
    """

    def __cinit__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreateHinge2(world.wid, jgid)

        self.setJointParam = dJointSetHinge2Param
        self.getJointParam = dJointGetHinge2Param

    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)
        self.param = JointParams(self.getParam, self.setParam)

    # setAnchor
    def setAnchor(self, pos):
        """setAnchor(pos)

        Set the hinge-2 anchor.

        @param pos: Anchor position
        @type pos: 3-sequence of floats
        """
        dJointSetHinge2Anchor(self.jid, pos[0], pos[1], pos[2])

    # getAnchor
    def getAnchor(self):
        """getAnchor() -> 3-tuple of floats

        Get the joint anchor point, in world coordinates. This returns
        the point on body 1. If the joint is perfectly satisfied, this
        will be the same as the point on body 2.
        """

        cdef dVector3 p
        dJointGetHinge2Anchor(self.jid, p)
        return (p[0],p[1],p[2])

    # getAnchor2
    def getAnchor2(self):
        """getAnchor2() -> 3-tuple of floats

        Get the joint anchor point, in world coordinates. This returns
        the point on body 2. If the joint is perfectly satisfied, this
        will be the same as the point on body 1.
        """

        cdef dVector3 p
        dJointGetHinge2Anchor2(self.jid, p)
        return (p[0],p[1],p[2])

    # setAxis1
    def setAxis1(self, axis):
        """setAxis1(axis)

        Set the first hinge-2 axis. Axis 1 and axis 2 must not lie
        along the same line.

        @param axis: Joint axis
        @type axis: 3-sequence of floats
        """

        dJointSetHinge2Axis1(self.jid, axis[0], axis[1], axis[2])

    # getAxis1
    def getAxis1(self):
        """getAxis1() -> 3-tuple of floats

        Get the first hinge-2 axis.
        """
        cdef dVector3 a
        dJointGetHinge2Axis1(self.jid, a)
        return (a[0],a[1],a[2])

    # setAxis2
    def setAxis2(self, axis):
        """setAxis2(axis)

        Set the second hinge-2 axis. Axis 1 and axis 2 must not lie
        along the same line.

        @param axis: Joint axis
        @type axis: 3-sequence of floats
        """
        dJointSetHinge2Axis2(self.jid, axis[0], axis[1], axis[2])

    # getAxis2
    def getAxis2(self):
        """getAxis2() -> 3-tuple of floats

        Get the second hinge-2 axis.
        """
        cdef dVector3 a
        dJointGetHinge2Axis2(self.jid, a)
        return (a[0],a[1],a[2])

    # getAngle
    def getAngle1(self):
        """getAngle1() -> float

        Get the first hinge-2 angle (around axis 1).

        When the anchor or axis is set, the current position of the
        attached bodies is examined and that position will be the zero
        angle.
        """
        return dJointGetHinge2Angle1(self.jid)

    # getAngle1Rate
    def getAngle1Rate(self):
        """getAngle1Rate() -> float

        Get the time derivative of the first hinge-2 angle.
        """
        return dJointGetHinge2Angle1Rate(self.jid)

    # getAngle2Rate
    def getAngle2Rate(self):
        """getAngle2Rate() -> float

        Get the time derivative of the second hinge-2 angle.
        """
        return dJointGetHinge2Angle2Rate(self.jid)

    # addTorques
    def addTorques(self, torque1, torque2):
        """addTorques(torque1, torque2)

        Applies torque1 about axis 1, and torque2 about axis 2.

        @param torque1: Torque 1 magnitude
        @param torque2: Torque 2 magnitude
        @type torque1: float
        @type torque2: float
        """
        dJointAddHinge2Torques(self.jid, torque1, torque2)

cdef void _dJointSetFixedParam(dJointID id, int param, dReal value):
    raise Exception, "Fixed joint does not have any parameters"

cdef dReal _dJointGetFixedParam(dJointID id, int param):
    raise Exception, "Fixed joint does not have any parameters"

# FixedJoint
cdef class FixedJoint(Joint):
    """Fixed joint.

    Constructor::

      FixedJoint(world, jointgroup=None)
    """

    def __cinit__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreateFixed(world.wid, jgid)

        self.setJointParam = _dJointSetFixedParam
        self.getJointParam = _dJointGetFixedParam

    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)
        self.param = JointParams(self.getParam, self.setParam)

    # setFixed
    def setFixed(self):
        """setFixed()

        Call this on the fixed joint after it has been attached to
        remember the current desired relative offset and desired
        relative rotation between the bodies.
        """
        dJointSetFixed(self.jid)

def CreateContactJointQ(world, jointgroup, c, contactprops, geom1, geom2):
    cdef dBodyID b1id, b2id

    c.setContactSurfaceParams(*contactprops)

    # Create the contact joint
    j = ContactJoint(world, jointgroup, c)
    j.attach(geom1.getBody(), geom2.getBody())
    #dJointAttach(self.jid, id1, id2)

    #~ b1id = dGeomGetBody(<dGeomID>geom1.gid)
    #~ b2id = dGeomGetBody(<dGeomID>geom2.gid)
#            if b1==None:
#                b1=ode.environment
#            if b2==None:
#                b2=ode.environment
    #j.attach(b1, b2)


# ContactJoint
cdef class ContactJoint(Joint):
    """Contact joint.

    Constructor::

      ContactJoint(world, jointgroup, contact)
    """

    def __cinit__(self, World world not None, jointgroup, Contact contact):
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

# AMotor
cdef class AMotor(Joint):
    """AMotor joint.

    Constructor::

      AMotor(world, jointgroup=None)
    """

    def __cinit__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid = NULL
        if jointgroup!=None:
            jg = jointgroup
            jgid = jg.gid
        self.jid = dJointCreateAMotor(world.wid, jgid)

        self.setJointParam = dJointSetAMotorParam
        self.getJointParam = dJointGetAMotorParam

    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)
        self.param = JointParams(self.getParam, self.setParam)

    # setMode
    def setMode(self, mode):
        """setMode(mode)

        Set the angular motor mode.  mode must be either AMotorUser or
        AMotorEuler.

        @param mode: Angular motor mode
        @type mode: int
        """
        dJointSetAMotorMode(self.jid, mode)

    # getMode
    def getMode(self):
        """getMode()

        Return the angular motor mode (AMotorUser or AMotorEuler).
        """
        return dJointGetAMotorMode(self.jid)

    # setNumAxes
    def setNumAxes(self, int num):
        """setNumAxes(num)

        Set the number of angular axes that will be controlled by the AMotor.
        num may be in the range from 0 to 3.

        @param num: Number of axes (0-3)
        @type num: int
        """
        dJointSetAMotorNumAxes(self.jid, num)

    # getNumAxes
    def getNumAxes(self):
        """getNumAxes() -> int

        Get the number of angular axes that are controlled by the AMotor.
        """
        return dJointGetAMotorNumAxes(self.jid)

    # setAxis
    def setAxis(self, int anum, int rel, axis):
        """setAxis(anum, rel, axis)

        Set an AMotor axis.

        The anum argument selects the axis to change (0,1 or 2).
        Each axis can have one of three "relative orientation" modes,
        selected by rel:

        0: The axis is anchored to the global frame.
        1: The axis is anchored to the first body.
        2: The axis is anchored to the second body.

        The axis vector is always specified in global coordinates
        regardless of the setting of rel.

        @param anum: Axis number
        @param rel: Relative orientation mode
        @param axis: Axis
        @type anum: int
        @type rel: int
        @type axis: 3-sequence of floats
        """
        dJointSetAMotorAxis(self.jid, anum, rel, axis[0], axis[1], axis[2])

    # getAxis
    def getAxis(self, int anum):
        """getAxis(anum)

        Get an AMotor axis.

        @param anum: Axis index (0-2)
        @type anum: int
        """
        cdef dVector3 a
        dJointGetAMotorAxis(self.jid, anum, a)
        return (a[0],a[1],a[2])

    # getAxisRel
    def getAxisRel(self, int anum):
        """getAxisRel(anum) -> int

        Get the relative mode of an axis.

        @param anum: Axis index (0-2)
        @type anum: int
        """
        return dJointGetAMotorAxisRel(self.jid, anum)

    # setAngle
    def setAngle(self, int anum, angle):
        """setAngle(anum, angle)

        Tell the AMotor what the current angle is along axis anum.

        @param anum: Axis index
        @param angle: Angle
        @type anum: int
        @type angle: float
        """
        dJointSetAMotorAngle(self.jid, anum, angle)

    # getAngle
    def getAngle(self, int anum):
        """getAngle(anum) -> float

        Return the current angle for axis anum.

        @param anum: Axis index
        @type anum: int
        """
        return dJointGetAMotorAngle(self.jid, anum)

    # getAngleRate
    def getAngleRate(self, int anum):
        """getAngleRate(anum) -> float

        Return the current angle rate for axis anum.

        @param anum: Axis index
        @type anum: int
        """
        return dJointGetAMotorAngleRate(self.jid, anum)

    # addTorques
    def addTorques(self, torque0, torque1, torque2):
        """addTorques(torque0, torque1, torque2)

        Applies torques about the AMotor's axes.

        @param torque0: Torque 0 magnitude
        @param torque1: Torque 1 magnitude
        @param torque2: Torque 2 magnitude
        @type torque0: float
        @type torque1: float
        @type torque2: float
        """
        dJointAddAMotorTorques(self.jid, torque0, torque1, torque2)


# LMotor
cdef class LMotor(Joint):
    """LMotor joint.

    Constructor::

      LMotor(world, jointgroup=None)
    """

    def __cinit__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid = NULL
        if jointgroup!=None:
            jg = jointgroup
            jgid = jg.gid
        self.jid = dJointCreateLMotor(world.wid, jgid)

        self.setJointParam = dJointSetLMotorParam
        self.getJointParam = dJointGetLMotorParam

    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)
        self.param = JointParams(self.getParam, self.setParam)

    # setNumAxes
    def setNumAxes(self, int num):
        """setNumAxes(num)

        Set the number of angular axes that will be controlled by the LMotor.
        num may be in the range from 0 to 3.

        @param num: Number of axes (0-3)
        @type num: int
        """
        dJointSetLMotorNumAxes(self.jid, num)

    # getNumAxes
    def getNumAxes(self):
        """getNumAxes() -> int

        Get the number of angular axes that are controlled by the LMotor.
        """
        return dJointGetLMotorNumAxes(self.jid)

    # setAxis
    def setAxis(self, int anum, int rel, axis):
        """setAxis(anum, rel, axis)

        Set an LMotor axis.

        The anum argument selects the axis to change (0,1 or 2).
        Each axis can have one of three "relative orientation" modes,
        selected by rel:

        0: The axis is anchored to the global frame.
        1: The axis is anchored to the first body.
        2: The axis is anchored to the second body.

        @param anum: Axis number
        @param rel: Relative orientation mode
        @param axis: Axis
        @type anum: int
        @type rel: int
        @type axis: 3-sequence of floats
        """
        dJointSetLMotorAxis(self.jid, anum, rel, axis[0], axis[1], axis[2])

    # getAxis
    def getAxis(self, int anum):
        """getAxis(anum)

        Get an LMotor axis.

        @param anum: Axis index (0-2)
        @type anum: int
        """
        cdef dVector3 a
        dJointGetLMotorAxis(self.jid, anum, a)
        return (a[0],a[1],a[2])



# Plane2DJoint
cdef class Plane2DJoint(Joint):
    """Plane-2D Joint.

    Constructor::

      Plane2DJoint(world, jointgroup=None)
    """

    cdef readonly object paramX
    cdef readonly object paramY
    cdef readonly object paramAngle

    def __cinit__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreatePlane2D(world.wid, jgid)

    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)

        self.paramX = JointParams(self.dontGetParam, self.setXParam)
        self.paramY = JointParams(self.dontGetParam, self.setYParam)
        self.paramAngle = JointParams(self.dontGetParam, self.setAngleParam)
        self.param = {'X': self.paramX, 'Y': self.paramY, 'Angle': self.paramAngle}

    def dontGetParam(self, param):
        print "You may only set Plane2D parameters."
        print "ODE API does not expose methods for reading their values."

    def setXParam(self, param, value):
        dJointSetPlane2DXParam(self.jid, param, value)

    def setYParam(self, param, value):
        dJointSetPlane2DYParam(self.jid, param, value)

    def setAngleParam(self, param, value):
        dJointSetPlane2DAngleParam(self.jid, param, value)

cdef class PRJoint(Joint):
    """PR (Prismatic and Rotoide) joint.

    Constructor::

      PRJoint(world, jointgroup=None)

    http://opende.sourceforge.net/wiki/index.php/Manual_(Joint_Types_and_Functions)#Prismatic_and_Rotoide

    """

    def __cinit__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreatePR(world.wid, jgid)

        self.setJointParam = dJointSetPRParam
        self.getJointParam = dJointGetPRParam

    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)
        self.param = JointParams(self.getParam, self.setParam)

    def setAxis1(self, axis):
        """setAxis1(axis)

        Set the first PR axis (this is the prismatic axis).

        @param axis: Prismatic axis
        @type axis: 3-sequence of floats
        """
        dJointSetPRAxis1(self.jid, axis[0], axis[1], axis[2])

    def getAxis1(self):
        """getAxis1() -> 3-tuple of floats

        Get the first PR axis (this is the prismatic axis).
        """
        cdef dVector3 a
        dJointGetPRAxis1(self.jid, a)
        return (a[0],a[1],a[2])

    def setAxis2(self, axis):
        """setAxis2(axis)

        Set the second PR axis (this is the rotoide axis).

        Important: The two axes must not be parallel.
        Since this is a new joint only when the 2 joint are at 90deg
        of each other was fully tested.

        @param axis: Rotoide axis
        @type axis: 3-sequence of floats
        """
        dJointSetPRAxis2(self.jid, axis[0], axis[1], axis[2])

    def getAxis2(self):
        """getAxis2() -> 3-tuple of floats

        Get the second PR axis (this is the rotoide axis).
        """
        cdef dVector3 a
        dJointGetPRAxis2(self.jid, a)
        return (a[0],a[1],a[2])

    # getPosition
    def getPosition(self):
        """getPosition() -> float

        Get the PR linear position (i.e. the prismatic's extension).

        When the axis is set, the current position of body1 and the anchor
        is examined and that position will be the zero position.

        The position is the "oriented" length between the body1 and and
        the rotoide articulation.

        position = (Prismatic axis) dot_product [(body1 + offset) - (body2 + anchor2)]
        """

        return dJointGetPRPosition(self.jid)


cdef class PistonJoint(Joint):
    """Piston joint.

    Constructor::

      PistonJoint(world, jointgroup=None)

    A piston joint is similar to a Slider joint, except that
    rotation around the translation axis is possible.

    The default axis is: Axis: x=1, y=0, z=0

    http://opende.sourceforge.net/wiki/index.php/Manual_(Joint_Types_and_Functions)#Piston

    """

    def __cinit__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreatePiston(world.wid, jgid)

        self.setJointParam = dJointSetPistonParam
        self.getJointParam = dJointGetPistonParam


    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)
        self.param = JointParams(self.getParam, self.setParam)


    # getAnchor
    def getAnchor(self):
        """getAnchor() -> 3-tuple of floats

        """

        cdef dVector3 p
        dJointGetPistonAnchor(self.jid, p)
        return (p[0],p[1],p[2])

    # getAnchor2
    def getAnchor2(self):
        """getAnchor2() -> 3-tuple of floats

        Get the joint anchor point, in world coordinates.

        This returns the point on body 2. If the joint is perfectly satisfied,
        this will return the same value as dJointGetPistonAnchor.
        If not, this value will be slightly different.

        This can be used, for example, to see how far the joint has come apart.
        """

        cdef dVector3 p
        dJointGetPistonAnchor2(self.jid, p)
        return (p[0],p[1],p[2])

    # setAnchor
    def setAnchor(self, pos):
        """setAnchor(pos)

        Set the Piston anchor.

        @param pos: Anchor position
        @type pos: 3-sequence of floats
        """
        dJointSetPistonAnchor(self.jid, pos[0], pos[1], pos[2])



    def getAxis(self):
        """getAxis() -> 3-tuple of floats

        Get the piston axis.
        """
        cdef dVector3 a
        dJointGetPistonAxis(self.jid, a)
        return (a[0],a[1],a[2])

    def setAxis(self, axis):
        """setAxis(axis)

        Set the piston axis.

        When the piston axis is set, the current position of the attached
        bodies is examined and that position will be the zero angle.

        @param axis: Piston axis
        @type axis: 3-sequence of floats
        """
        dJointSetPistonAxis(self.jid, axis[0], axis[1], axis[2])


    def setAxisDelta(self, axis, delta):
        """setAxisDelta(axis)

        Does some black magic (not documented in the ODE wiki)

        @param axis: Piston axis
        @param delta: Piston delta
        @type axis: 3-sequence of floats
        """
        dJointSetPistonAxisDelta(self.jid, axis[0], axis[1], axis[2], delta[0], delta[1], delta[2])

    # getPosition
    def getPosition(self):
        """getPosition() -> float

        Get the Piston linear position (i.e. the prismatic's extension)

        [The explanation from ODE wiki is copied from PU joint,
         and might not be 100% accurate]

        When the anchor is set, the current position of body1 and the anchor
        is examined and that position will be the zero position (initial_offset)
        (i.e. dJointGetPUPosition with the body1 at that position with respect
        to the anchor will return 0.0).

        The position is the "oriented" length between the body1 and and the anchor.

        position = { (Prismatic axis) dot_product [body1 - anchor] } - initial_offset
        """
        return dJointGetPistonPosition(self.jid)

    # getPositionRate
    def getPositionRate(self):
        """getPositionRate() -> float

        Get the time derivative of the position.
        """
        return dJointGetPistonPositionRate(self.jid)


   # dReal dJointGetPistonAngle (dJointID);
    def getAngle(self):
        """
        getAngle() -> float

        This is a wrapper for the following ODE function:

        dReal dJointGetPistonAngle (dJointID);

        """
        return dJointGetPistonAngle(self.jid)


    # dReal dJointGetPistonAngleRate (dJointID);
    def getAngleRate(self):
        """
        getPistonAngleRate() -> float

        This is a wrapper for the following ODE function:

        dReal dJointGetPistonAngleRate (dJointID);

        """
        return dJointGetPistonAngleRate(self.jid)

    # addForce
    def addForce(self, force):
        """addForce(force)

        Applies the given force in the piston's direction.

        @param force: Force magnitude
        @type force: float
        """
        dJointAddPistonForce(self.jid, force)



cdef class PUJoint(Joint):
    """PU (Prismatic - Universal) joint.

    Constructor::

      PUJoint(world, jointgroup=None)

    http://opende.sourceforge.net/wiki/index.php/Manual_(Joint_Types_and_Functions)#Prismatic_-_Universal

    """

    def __cinit__(self, World world not None, jointgroup=None):
        cdef JointGroup jg
        cdef dJointGroupID jgid

        jgid=NULL
        if jointgroup!=None:
            jg=jointgroup
            jgid=jg.gid
        self.jid = dJointCreatePU(world.wid, jgid)

        self.setJointParam = dJointSetPUParam
        self.getJointParam = dJointGetPUParam

    def __init__(self, World world not None, jointgroup=None):
        self.world = world
        if jointgroup!=None:
            jointgroup._addjoint(self)
        self.param = JointParams(self.getParam, self.setParam)


    # getAnchor
    def getAnchor(self):
        """getAnchor() -> 3-tuple of floats

        """

        cdef dVector3 p
        dJointGetPUAnchor(self.jid, p)
        return (p[0],p[1],p[2])

    # setAnchor
    def setAnchor(self, pos):
        """setAnchor(pos)

        Set the PU anchor.

        @param pos: Anchor position
        @type pos: 3-sequence of floats
        """
        dJointSetPUAnchor(self.jid, pos[0], pos[1], pos[2])

    # setAnchor
    def setAnchorDelta(self, pos, delta):
        """setAnchorDelta(pos, delta)

        Set the PU anchor and the relative position of each body,
        as if body1 was at its current position + [dx,dy,dy]
        (dx, dy, dx in world frame).

        [DZ is missing?!]

        This is like setting the joint with the prismatic part
        already elongated or compressed.

        After setting the anchor with a delta, if the function
        dJointGetPUPosition is called, the answer will be:

        sqrt(dx*dx + dy*dy + dz*dz) * Normalize[axis3 dot_product (dx,dy,dz)]


        @param pos: Anchor position
        @param delta: Anchor position
        @type pos: 3-sequence of floats
        """
        dJointSetPUAnchorDelta(self.jid, pos[0], pos[1], pos[2], delta[0], delta[1], delta[2])

    def setAxis1(self, axis):
        """setAxis1(axis)

        Set the first PU axis.

        @param axis: Axis 1
        @type axis: 3-sequence of floats
        """
        dJointSetPUAxis1(self.jid, axis[0], axis[1], axis[2])

    def getAxis1(self):
        """getAxis1() -> 3-tuple of floats

        Get the first PU axis.
        """
        cdef dVector3 a
        dJointGetPUAxis1(self.jid, a)
        return (a[0],a[1],a[2])

    def setAxis2(self, axis):
        """setAxis2(axis)

        Set the second PU axis.

        Axis 1 and axis 2 should be perpendicular to each other.

        @param axis: Axis 2
        @type axis: 3-sequence of floats
        """
        dJointSetPUAxis2(self.jid, axis[0], axis[1], axis[2])

    def getAxis2(self):
        """getAxis2() -> 3-tuple of floats

        Get the second PR axis (this is the rotoide axis).
        """
        cdef dVector3 a
        dJointGetPUAxis2(self.jid, a)
        return (a[0],a[1],a[2])

    def setAxis3(self, axis):
        """setAxis3(axis)

        Set the axis for the prismatic articulation.

        @param axis: Axis 3
        @type axis: 3-sequence of floats
        """
        dJointSetPUAxis3(self.jid, axis[0], axis[1], axis[2])

    def getAxis3(self):
        """getAxis3() -> 3-tuple of floats

        Get the axis for the prismatic articulation.
        """
        cdef dVector3 a
        dJointGetPUAxis3(self.jid, a)
        return (a[0],a[1],a[2])

    def getAxisP(self):
        return getAxis3(self)
    def setAxisP(self, axis):
        setAxis3(self, axis)


    # void dJointGetPUAngles (dJointID, dReal *angle1, dReal *angle2);
    def getAngles(self):
        """
        getAngles() -> void

        This is a wrapper for the following ODE function:

        void dJointGetPUAngles (dJointID, dReal *angle1, dReal *angle2);

        """
        cdef dReal angle1, angle2
        dJointGetPUAngles(self.jid, &angle1, &angle2)
        return (angle1, angle2)


    # dReal dJointGetPUAngle1 (dJointID);
    def getAngle1(self):
        """
        getAngle1() -> float

        This is a wrapper for the following ODE function:

        dReal dJointGetPUAngle1 (dJointID);

        """
        return dJointGetPUAngle1(self.jid)


    # dReal dJointGetPUAngle2 (dJointID);
    def getAngle2(self):
        """
        getAngle2() -> float

        This is a wrapper for the following ODE function:

        dReal dJointGetPUAngle2 (dJointID);

        """
        return dJointGetPUAngle2(self.jid)


    # dReal dJointGetPUAngle1Rate (dJointID);
    def getAngle1Rate(self):
        """
        getAngle1Rate() -> float

        This is a wrapper for the following ODE function:

        dReal dJointGetPUAngle1Rate (dJointID);

        """
        return dJointGetPUAngle1Rate(self.jid)


    # dReal dJointGetPUAngle2Rate (dJointID);
    def getAngle2Rate(self):
        """
        getAngle2Rate() -> float

        This is a wrapper for the following ODE function:

        dReal dJointGetPUAngle2Rate (dJointID);

        """
        return dJointGetPUAngle2Rate(self.jid)

    # getPosition
    def getPosition(self):
        """getPosition() -> float

        Get the PU linear position (i.e. the prismatic's extension).

        When the anchor is set, the current position of body1 and the
        anchor is examined and that position will be the zero position
        (initial_offset) (i.e. dJointGetPUPosition with the body1
        at that position with respect to the anchor will return 0.0).

        The position is the "oriented" length between the body1 and
        and the universal articulation (anchor).

        position = { (Prismatic axis) dot_product [body1 - anchor] } - initial_offset

        """
        return dJointGetPUPosition(self.jid)

    # getPositionRate
    def getPositionRate(self):
        """getPositionRate() -> float

        Get the time derivative of the position.
        """
        return dJointGetPUPositionRate(self.jid)
