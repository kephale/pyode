/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"

void RayGeom::set(tuple pos, tuple dir)
{
	dGeomRaySet(id(), extract<dReal>(pos[0]),
			  extract<dReal>(pos[1]),
			  extract<dReal>(pos[2]),
			  
			  extract<dReal>(dir[0]),
			  extract<dReal>(dir[1]),
			  extract<dReal>(dir[2]));
}

tuple RayGeom::get()
{
	dVector3 pos, dir;
	dGeomRayGet(id(), pos, dir);
	return make_tuple(dVector3_to_tuple(pos), dVector3_to_tuple(dir));
}

void exportRayGeom()
{
	class_<RayGeom, bases<Geom> >("RayGeom", init<dReal>())
		.def(init<Space &, dReal>())
		.def("setLength", &RayGeom::setLength)
		.def("getLength", &RayGeom::getLength)
		.def("set", &RayGeom::set)
		.def("get", &RayGeom::get)
	;
}

