/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class CCylinderGeom : public Geom {
	public:

	CCylinderGeom(dReal radius, dReal length)
		: Geom(dCreateCCylinder(0, radius, length)) { }
	CCylinderGeom(Space &s, dReal radius, dReal length)
		: Geom(dCreateCCylinder(s.id(), radius, length)) { }

	void setParams(dReal radius, dReal length)
	{ dGeomCCylinderSetParams(id(), radius, length); }
	tuple getParams();

	dReal pointDepth(tuple point);
};

void exportCCylinderGeom();

