/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class FixedJoint : public Joint {
	public:
	FixedJoint(World &world, JointGroup &group) : Joint(dJointCreateFixed(world.id(), group.id())) { }
	FixedJoint(World &world) : Joint(dJointCreateFixed(world.id(), 0)) { }

	void set() { dJointSetFixed(id()); }
};

void exportFixedJoint();

