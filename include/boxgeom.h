/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class BoxGeom : public Geom {
	public:
	
	BoxGeom(tuple &len) : Geom(dCreateBox(0, extract<dReal>(len[0]),
						extract<dReal>(len[1]),
						extract<dReal>(len[2]))) { }

	BoxGeom(Space &s, tuple &len) : Geom(dCreateBox(s.id(), extract<dReal>(len[0]),
							       extract<dReal>(len[1]),
							       extract<dReal>(len[2]))) { }

	void setLengths(tuple len);
	tuple getLengths();

	dReal pointDepth(tuple point);

};

void exportBoxGeom();

