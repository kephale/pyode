/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class PlaneGeom : public Geom {
	public:

	PlaneGeom(tuple &vec)
		: Geom(dCreatePlane(0,  extract<dReal>(vec[0]),
					extract<dReal>(vec[1]),
					extract<dReal>(vec[2]),
					extract<dReal>(vec[3]))) { }
	
	PlaneGeom(Space &s, tuple &vec)
		: Geom(dCreatePlane(s.id(), extract<dReal>(vec[0]),
					    extract<dReal>(vec[1]),
					    extract<dReal>(vec[2]),
					    extract<dReal>(vec[4]))) { }
	void setParams(tuple vec);
	tuple getParams();
	dReal pointDepth(tuple point);
};

void exportPlaneGeom();

