/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class Hinge2Joint : public Joint {
	public:
	Hinge2Joint(World &world, JointGroup &group) : Joint(dJointCreateHinge2(world.id(), group.id())) { }
	Hinge2Joint(World &world) : Joint(dJointCreateHinge2(world.id(), 0)) { }

	void setAnchor(tuple vec);
	void setAxis1(tuple vec);
	void setAxis2(tuple vec);

	tuple getAnchor();
	tuple getAxis1();
	tuple getAxis2();

	dReal getAngle1() { return dJointGetHinge2Angle1(id()); }
	dReal getAngle1Rate() { return dJointGetHinge2Angle1Rate(id()); }
	dReal getAngle2Rate() { return dJointGetHinge2Angle2Rate(id()); }

	void setParam(int parameter, dReal value)
	{ dJointSetHinge2Param(id(), parameter, value); }
	dReal getParam(int parameter)
	{ return dJointGetHinge2Param(id(), parameter); }
};

void exportHinge2Joint();

