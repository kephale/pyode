/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"



void AMotorJoint::setAxis(int anum, int rel, tuple vec)
{
	dJointSetAMotorAxis(id(), anum, rel, extract<dReal>(vec[0]),
					     extract<dReal>(vec[1]),
					     extract<dReal>(vec[2]));
}

tuple AMotorJoint::getAxis(int anum)
{
	dVector3 r;
	dJointGetAMotorAxis(id(), anum, r);
	return dVector3_to_tuple(r);
}

void exportAMotorJoint()
{
	class_<AMotorJoint, bases<Joint> >("AMotorJoint", init<World &>()[with_custodian_and_ward<1,2>()])
		.def(init<World &, JointGroup &>()[with_custodian_and_ward<1,2,
						   with_custodian_and_ward<1,3> >()])
		.def("setMode", &AMotorJoint::setMode)
		.def("getMode", &AMotorJoint::getMode)
		.def("setNumAxes", &AMotorJoint::setNumAxes)
		.def("getNumAxes", &AMotorJoint::getNumAxes)
		.def("getAxis", &AMotorJoint::getAxis)
		.def("setAxis", &AMotorJoint::setAxis)
		.def("setAngle", &AMotorJoint::setAngle)
		.def("getAngle", &AMotorJoint::getAngle)
		.def("getAngleRate", &AMotorJoint::getAngleRate)
		.def("setParam", &AMotorJoint::setParam)
		.def("getParam", &AMotorJoint::getParam)
	;
}

