/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class Body {
	dBodyID __id;
	Mass __mass;

	public:

	Body() { }
	Body(World &world) { __id = dBodyCreate(world.id()); }
	~Body() { dBodyDestroy(__id); }

	dBodyID id() { return __id; }

	void setPosition(tuple vec);
	void setRotation(tuple matrix);
	void setQuaternion(tuple q);
	void setLinearVel(tuple vec);
	void setAngularVel(tuple vec);

	tuple getPosition();
	tuple getRotation();
	tuple getQuaternion();
	tuple getLinearVel();
	tuple getAngularVel();

	void setMass(Mass &mass)
	{
		__mass = mass;
		dBodySetMass(__id, mass.getdMass());
	}

	Mass const& getMass() const { return __mass; }

	void addForce(tuple vec, bool rel);
	void addTorque(tuple vec, bool rel);
	void addForceAtPos(tuple vec, tuple pos, bool rel);
	void addForceAtRelPos(tuple vec, tuple pos, bool rel);

	tuple getForce();
	tuple getTorque();

	void setForce(tuple vec);
	void setTorque(tuple vec);

	
	tuple getRelPointPos(tuple vec);
	tuple getRelPointVel(tuple vec);
	tuple getPointVel(tuple vec);
	tuple getPosRelPoint(tuple vec);

	tuple vectorToWorld(tuple vec);
	tuple vectorFromWorld(tuple vec);

	void enable() { dBodyEnable(__id); }
	void disable() { dBodyDisable(__id); }
	int isEnabled() { return dBodyIsEnabled(__id); }

	void setFiniteRotationMode(int mode) { dBodySetFiniteRotationMode(__id, mode); }
	int getFiniteRotationMode() { return dBodyGetFiniteRotationMode(__id); }

	void setFiniteRotationAxis(tuple vec);
	tuple getFiniteRotationAxis();

	int getNumJoints() { return dBodyGetNumJoints(__id); }

	// TODO
	// dJointID dBodyGetJoint (dBodyID, int index);
	
	void setGravityMode(int mode) { dBodySetGravityMode(__id, mode); }
	int getGravityMode() { return dBodyGetGravityMode(__id); }
};

void exportBody();

