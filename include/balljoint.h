/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class BallJoint : public Joint {
	public:
	BallJoint(World &world, JointGroup &group) : Joint(dJointCreateBall(world.id(), group.id())) { }
	BallJoint(World &world) : Joint(dJointCreateBall(world.id(), 0)) { }

	void setAnchor(tuple vec);
	tuple getAnchor();
};

void exportBallJoint();

