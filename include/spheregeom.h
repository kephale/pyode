/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class SphereGeom : public Geom {
	public:
	
	SphereGeom(dReal radius)
		: Geom(dCreateSphere(0, radius)) { }
	SphereGeom(Space &s, dReal radius)
		: Geom(dCreateSphere(s.id(), radius)) { }

	void setRadius(dReal radius) { dGeomSphereSetRadius(id(), radius); }
	dReal getRadius() { return dGeomSphereGetRadius(id()); }

	dReal pointDepth(tuple point);
};

void exportSphereGeom();

