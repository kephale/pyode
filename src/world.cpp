/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"



void World::setGravity(tuple vec)
{
	dWorldSetGravity(__id, extract<dReal>(vec[0]),
			       extract<dReal>(vec[1]),
			       extract<dReal>(vec[2]));
}

tuple World::getGravity()
{
	dVector3 gravity;
	dWorldGetGravity(__id, gravity);
	return dVector3_to_tuple(gravity);
}

tuple World::impulseToForce(dReal stepsize, tuple vec)
{
	dVector3 force;
	dWorldImpulseToForce(__id, stepsize, extract<dReal>(vec[0]),
					     extract<dReal>(vec[1]),
					     extract<dReal>(vec[2]),
					     force);
	return dVector3_to_tuple(force);
}

void exportWorld()
{
	class_<World>("World")
		.def("setGravity", &World::setGravity)
		.def("getGravity", &World::getGravity)
		.def("setERP", &World::setERP)
		.def("getERP", &World::getERP)
		.def("setCFM", &World::setCFM)
		.def("getCFM", &World::getCFM)
		.def("step", &World::step)
		.def("impulseToForce", &World::impulseToForce)
	;	
}

