/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"

dReal SphereGeom::pointDepth(tuple point)
{
	return dGeomSpherePointDepth(id(), extract<dReal>(point[0]),
					   extract<dReal>(point[1]),
					   extract<dReal>(point[2]));
}

void exportSphereGeom()
{
	class_<SphereGeom, bases<Geom> >("SphereGeom", init<dReal>())
		.def(init<Space &, dReal>())
		.def("pointDepth", &SphereGeom::pointDepth)
	;
}

