/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class Mass {
	dMass __mass;

	public:

	Mass() { dMassSetZero(&__mass); }
	~Mass() { }
	
	void setParameters(dReal mass, tuple centre, tuple imatrix);
	void translate(tuple vec);
	void rotate(tuple matrix);
	void add(Mass *mass);

	void setZero()
	{ dMassSetZero(&__mass); }
	void setSphere(dReal density, dReal radius)
	{ dMassSetSphere (&__mass, density, radius); }
	void setCappedCylinder(dReal density, int direction, dReal a, dReal b)
	{ dMassSetCappedCylinder(&__mass, density, direction, a, b); }
	void setBox(dReal density, dReal lx, dReal ly, dReal lz)
	{ dMassSetBox(&__mass, density, lx, ly, lz); }
	void adjust(dReal newmass)
	{ dMassAdjust(&__mass, newmass); }

	dReal getMass() { return __mass.mass; }
	tuple getCentre();
	tuple getInertia();

	dMass *getdMass() { return &__mass; }
};

void exportMass();

