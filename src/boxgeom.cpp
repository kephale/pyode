/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"

void BoxGeom::setLengths(tuple len)
{
	dGeomBoxSetLengths(id(), extract<dReal>(len[0]),
				 extract<dReal>(len[1]),
				 extract<dReal>(len[2]));
}

tuple BoxGeom::getLengths()
{
	dVector3 vec;
	dGeomBoxGetLengths(id(), vec);
	return dVector3_to_tuple(vec);
}

dReal BoxGeom::pointDepth(tuple point)
{
	return dGeomBoxPointDepth(id(), extract<dReal>(point[0]),
					extract<dReal>(point[1]),
					extract<dReal>(point[2]));
}

void exportBoxGeom()
{
	class_<BoxGeom, bases<Geom> >("BoxGeom", init<tuple&>())
		.def(init<Space &, tuple&>())
		.def("setLengths", &BoxGeom::setLengths)
		.def("getLengths", &BoxGeom::getLengths)
		.def("pointDepth", &BoxGeom::pointDepth)
	;
}

