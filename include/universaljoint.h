/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class UniversalJoint : public Joint {
	public:
	UniversalJoint(World &world, JointGroup &group) : Joint(dJointCreateUniversal(world.id(), group.id())) { }
	UniversalJoint(World &world) : Joint(dJointCreateUniversal(world.id(), 0)) { }

	void setAnchor(tuple vec);
	void setAxis1(tuple vec);
	void setAxis2(tuple vec);
	
	tuple getAnchor();
	tuple getAxis1();
	tuple getAxis2();
};

void exportUniversalJoint();

