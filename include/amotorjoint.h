/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class AMotorJoint : public Joint {
	public:
	AMotorJoint(World &world, JointGroup &group) : Joint(dJointCreateAMotor(world.id(), group.id())) { }
	AMotorJoint(World &world) : Joint(dJointCreateAMotor(world.id(), 0)) { }

	void setMode(int mode) { dJointSetAMotorMode(id(), mode); }
	int getMode() { return dJointGetAMotorMode(id()); }
	
	void setNumAxes(int num) { dJointSetAMotorNumAxes(id(), num);}
	int getNumAxes() { return dJointGetAMotorNumAxes(id()); }

	void setAxis(int anum, int rel, tuple vec);
	tuple getAxis(int anum);
	int getAxisRel(int anum) { return dJointGetAMotorAxisRel(id(), anum); }

	void setAngle(int anum, dReal angle) { dJointSetAMotorAngle(id(), anum, angle); }
	dReal getAngle(int anum) { return dJointGetAMotorAngle(id(), anum); }
	dReal getAngleRate(int anum) { return dJointGetAMotorAngleRate(id(), anum); }

	void setParam(int parameter, dReal value)
	{ dJointSetAMotorParam(id(), parameter, value); }
	dReal getParam(int parameter)
	{ dJointGetAMotorParam(id(), parameter); }
};

void exportAMotorJoint();

