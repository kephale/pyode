/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"



void UniversalJoint::setAnchor(tuple vec)
{
	dJointSetUniversalAnchor(id(), extract<dReal>(vec[0]),
				       extract<dReal>(vec[1]),
				       extract<dReal>(vec[2]));
}

void UniversalJoint::setAxis1(tuple vec)
{
	dJointSetUniversalAxis1(id(), extract<dReal>(vec[0]),
				      extract<dReal>(vec[1]),
				      extract<dReal>(vec[2]));
}

void UniversalJoint::setAxis2(tuple vec)
{
	dJointSetUniversalAxis2(id(), extract<dReal>(vec[0]),
				      extract<dReal>(vec[1]),
				      extract<dReal>(vec[2]));
}
	
tuple UniversalJoint::getAnchor()
{
	dVector3 r;
	dJointGetUniversalAnchor(id(), r);
	return dVector3_to_tuple(r);
}

tuple UniversalJoint::getAxis1()
{
	dVector3 r;
	dJointGetUniversalAxis1(id(), r);
	return dVector3_to_tuple(r);
}

tuple UniversalJoint::getAxis2()
{
	dVector3 r;
	dJointGetUniversalAxis2(id(), r);
	return dVector3_to_tuple(r);
}

void exportUniversalJoint()
{
	class_<UniversalJoint, bases<Joint> >("UniversalJoint", init<World &>()[with_custodian_and_ward<1,2>()])
		.def(init<World &, JointGroup &>()[with_custodian_and_ward<1,2,
						   with_custodian_and_ward<1,3> >()])
		.def("setAnchor", &UniversalJoint::setAnchor)
		.def("setAxis1", &UniversalJoint::setAxis1)
		.def("setAxis2", &UniversalJoint::setAxis2)

		.def("getAnchor", &UniversalJoint::getAnchor)
		.def("getAxis1", &UniversalJoint::getAxis1)
		.def("getAxis2", &UniversalJoint::getAxis2)
	;
}

