/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"



void BallJoint::setAnchor(tuple vec)
{
	dJointSetBallAnchor(id(), extract<dReal>(vec[0]),
				  extract<dReal>(vec[1]),
				  extract<dReal>(vec[2]));
}

tuple BallJoint::getAnchor()
{
	dVector3 r;
	dJointGetBallAnchor(id(), r);
	return dVector3_to_tuple(r);
}

void exportBallJoint()
{
	class_<BallJoint, bases<Joint> >("BallJoint", init<World &>()[with_custodian_and_ward<1,2>()])
		.def(init<World &, JointGroup &>()[with_custodian_and_ward<1,2,
						   with_custodian_and_ward<1,3> >()])
		.def("setAnchor", &BallJoint::setAnchor)
		.def("getAnchor", &BallJoint::getAnchor)
	;
}

