/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"



void HingeJoint::setAnchor(tuple vec)
{
	dJointSetHingeAnchor(id(), extract<dReal>(vec[0]),
				   extract<dReal>(vec[1]),
				   extract<dReal>(vec[2]));
}

void HingeJoint::setAxis(tuple vec)
{
	dJointSetHingeAxis(id(), extract<dReal>(vec[0]),
				 extract<dReal>(vec[1]),
				 extract<dReal>(vec[2]));
}

tuple HingeJoint::getAnchor()
{
	dVector3 r;
	dJointGetHingeAnchor(id(), r);
	return dVector3_to_tuple(r);
}

tuple HingeJoint::getAxis()
{
	dVector3 r;
	dJointGetHingeAxis(id(), r);
	return dVector3_to_tuple(r);
}

void exportHingeJoint()
{
	class_<HingeJoint, bases<Joint> >("HingeJoint", init<World &>()[with_custodian_and_ward<1,2>()])
		.def(init<World &, JointGroup &>()[with_custodian_and_ward<1,2,
						   with_custodian_and_ward<1,3> >()])
		.def("setAnchor", &HingeJoint::setAnchor)
		.def("setAxis", &HingeJoint::setAxis)
		
		.def("getAnchor", &HingeJoint::getAnchor)
		.def("getAxis", &HingeJoint::getAxis)
		
		.def("getAngle", &HingeJoint::getAngle)
		.def("getAngleRate", &HingeJoint::getAngleRate)

		.def("setParam", &HingeJoint::setParam)
		.def("getParam", &HingeJoint::getParam)

	;
}

