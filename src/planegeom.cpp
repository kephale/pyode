/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"

void PlaneGeom::setParams(tuple vec)
{
	dGeomPlaneSetParams(id(), extract<dReal>(vec[0]),
				  extract<dReal>(vec[1]),
				  extract<dReal>(vec[2]),
				  extract<dReal>(vec[3]));
}

tuple PlaneGeom::getParams()
{
	dVector4 r;
	dGeomPlaneGetParams(id(), r);
	return dVector4_to_tuple(r);
}

dReal PlaneGeom::pointDepth(tuple point)
{
	return dGeomPlanePointDepth(id(), extract<dReal>(point[0]),
					extract<dReal>(point[1]),
					extract<dReal>(point[2]));
}


void exportPlaneGeom()
{
	class_<PlaneGeom, bases<Geom> >("PlaneGeom", init<tuple &>())
		.def(init<Space &, tuple &>())
		.def("pointDepth", &PlaneGeom::pointDepth)
		.def("setParams", &PlaneGeom::setParams)
		.def("getParams", &PlaneGeom::getParams)
	;
}

