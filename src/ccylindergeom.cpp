/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"

tuple CCylinderGeom::getParams()
{
	dReal rad, len;
	dGeomCCylinderGetParams(id(), &rad, &len);
	return make_tuple(rad, len);
}

dReal CCylinderGeom::pointDepth(tuple point)
{
	return dGeomCCylinderPointDepth(id(), extract<dReal>(point[0]),
					      extract<dReal>(point[1]),
					      extract<dReal>(point[2]));
}


void exportCCylinderGeom()
{
	class_<CCylinderGeom, bases<Geom> >("CCylinderGeom", init<dReal,dReal>())
		.def(init<Space &, dReal, dReal>())
		.def("pointDepth", &CCylinderGeom::pointDepth)
		.def("setParams", &CCylinderGeom::setParams)
		.def("getParams", &CCylinderGeom::getParams)
	;
}

