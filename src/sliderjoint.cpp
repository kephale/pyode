/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"



void SliderJoint::setAxis(tuple vec)
{
	dJointSetSliderAxis(id(), extract<dReal>(vec[0]),
				  extract<dReal>(vec[1]),
				  extract<dReal>(vec[2]));
}

tuple SliderJoint::getAxis()
{
	dVector3 r;
	dJointGetSliderAxis(id(), r);
	return dVector3_to_tuple(r);
}

void exportSliderJoint()
{
	class_<SliderJoint, bases<Joint> >("SliderJoint", init<World &>()[with_custodian_and_ward<1,2>()])
		.def(init<World &, JointGroup &>()[with_custodian_and_ward<1,2,
						   with_custodian_and_ward<1,3> >()])
		.def("setAxis", &SliderJoint::setAxis)
		.def("getAxis", &SliderJoint::getAxis)
		.def("getPosition", &SliderJoint::getPosition)
		.def("getPositionRate", &SliderJoint::getPositionRate)
		.def("setParam", &SliderJoint::setParam)
		.def("getParam", &SliderJoint::getParam)
	;
}

