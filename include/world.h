/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class World {
	dWorldID __id;

	public:

	World() { __id = dWorldCreate(); }
	~World() { dWorldDestroy(__id); }

	dWorldID id() { return __id; }
	

	void setGravity(tuple vec);
	tuple getGravity();

	void setERP(dReal erp) { dWorldSetERP(__id, erp); }
	dReal getERP() { return dWorldGetERP(__id); }

	void setCFM(dReal cfm) { dWorldSetCFM(__id, cfm); }
	dReal getCFM() { return dWorldGetCFM(__id); }

	void step(dReal stepsize) { dWorldStep(__id, stepsize); }

	tuple impulseToForce(dReal stepsize, tuple vec);
};

void exportWorld();

