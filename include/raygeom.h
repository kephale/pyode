/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class RayGeom : public Geom {
	public:

	RayGeom(dReal length)
		: Geom(dCreateRay(0, length)) { }
	RayGeom(Space &s, dReal length)
		: Geom(dCreateRay(s.id(), length)) { }

	void setLength(dReal len) { dGeomRaySetLength(id(), len); }
	dReal getLength() { return dGeomRayGetLength(id()); }

	void set(tuple pos, tuple dir);
	tuple get();
};

void exportRayGeom();

