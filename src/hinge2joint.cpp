/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"



void Hinge2Joint::setAnchor(tuple vec)
{
	dJointSetHinge2Anchor(id(), extract<dReal>(vec[0]),
				    extract<dReal>(vec[1]),
				    extract<dReal>(vec[2]));
}

void Hinge2Joint::setAxis1(tuple vec)
{
	dJointSetHinge2Axis1(id(),  extract<dReal>(vec[0]),
				    extract<dReal>(vec[1]),
				    extract<dReal>(vec[2]));
}

void Hinge2Joint::setAxis2(tuple vec)
{
	dJointSetHinge2Axis2(id(),  extract<dReal>(vec[0]),
				    extract<dReal>(vec[1]),
				    extract<dReal>(vec[2]));
}

tuple Hinge2Joint::getAnchor()
{
	dVector3 r;
	dJointGetHinge2Anchor(id(), r);
	return dVector3_to_tuple(r);
}

tuple Hinge2Joint::getAxis1()
{
	dVector3 r;
	dJointGetHinge2Axis1(id(), r);
	return dVector3_to_tuple(r);
}

tuple Hinge2Joint::getAxis2()
{
	dVector3 r;
	dJointGetHinge2Axis2(id(), r);
	return dVector3_to_tuple(r);
}

void exportHinge2Joint()
{
	class_<Hinge2Joint, bases<Joint> >("Hinge2Joint", init<World &>()[with_custodian_and_ward<1,2>()])
		.def(init<World &, JointGroup &>()[with_custodian_and_ward<1,2,
						   with_custodian_and_ward<1,3> >()])
		.def("setAnchor", &Hinge2Joint::setAnchor)
		.def("setAxis1", &Hinge2Joint::setAxis1)
		.def("setAxis2", &Hinge2Joint::setAxis2)

		.def("getAnchor", &Hinge2Joint::getAnchor)
		.def("getAxis1", &Hinge2Joint::getAxis1)
		.def("getAxis2", &Hinge2Joint::getAxis2)

		.def("getAngle1", &Hinge2Joint::getAngle1)
		.def("getAngle1Rate", &Hinge2Joint::getAngle1Rate)
		.def("getAngle2Rate", &Hinge2Joint::getAngle2Rate)

		.def("setParam", &Hinge2Joint::setParam)
		.def("getParam", &Hinge2Joint::getParam)

	;
}

