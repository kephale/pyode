/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class HingeJoint : public Joint {
	public:
	HingeJoint(World &world, JointGroup &group) : Joint(dJointCreateHinge(world.id(), group.id())) { }
	HingeJoint(World &world) : Joint(dJointCreateHinge(world.id(), 0)) { }

	void setAnchor(tuple vec);
	void setAxis(tuple vec);

	tuple getAnchor();
	tuple getAxis();

	dReal getAngle() { return dJointGetHingeAngle(id()); }
	dReal getAngleRate() { return dJointGetHingeAngleRate(id()); }

	void setParam(int parameter, dReal value)
	{ dJointSetHingeParam(id(), parameter, value); }
	dReal getParam(int parameter)
	{ return dJointGetHingeParam(id(), parameter); }
};

void exportHingeJoint();

