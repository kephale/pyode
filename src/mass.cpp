/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"



void Mass::setParameters(dReal mass, tuple centre, tuple imatrix)
{
	dMassSetParameters(&__mass, mass,
                         extract<dReal>(centre[0]),
			 extract<dReal>(centre[1]),
			 extract<dReal>(centre[2]),
			 
			 extract<dReal>(imatrix[0][0]),
			 extract<dReal>(imatrix[0][1]),
			 extract<dReal>(imatrix[0][2]),

			 extract<dReal>(imatrix[1][0]),
			 extract<dReal>(imatrix[1][1]),
			 extract<dReal>(imatrix[1][2]));
}

void Mass::translate(tuple vec)
{
	dMassTranslate(&__mass,
			extract<dReal>(vec[0]),
			extract<dReal>(vec[1]),
			extract<dReal>(vec[2]));
}

void Mass::rotate(tuple matrix)
{
	dMatrix3 m;
	tuple_to_dMatrix3(matrix, m);
	dMassRotate(&__mass, m);
}

void Mass::add(Mass *mass)
{
	dMassAdd(&__mass, mass->getdMass());
}

tuple Mass::getCentre()
{
	return make_tuple(__mass.c[0], __mass.c[1],
			  __mass.c[2], __mass.c[3]);
}

tuple Mass::getInertia()
{
	return make_tuple(
			make_tuple(__mass.I[0], __mass.I[1], __mass.I[2]),
			make_tuple(__mass.I[3], __mass.I[4], __mass.I[5]),
			make_tuple(__mass.I[6], __mass.I[7], __mass.I[8]));
}

void exportMass()
{
	class_<Mass>("Mass")
		.def("setParameters", &Mass::setParameters)
		.def("translate", &Mass::translate)
		.def("rotate", &Mass::rotate)
		.def("add", &Mass::add)
		.def("setZero", &Mass::setZero)
		.def("setSphere", &Mass::setSphere)
		.def("setCappedCylinder", &Mass::setCappedCylinder)
		.def("setBox", &Mass::setBox)
		.def("adjust", &Mass::adjust)
		.def("getMass", &Mass::getMass)
		.def("getCentre", &Mass::getCentre)
		.def("getInertia", &Mass::getInertia)
	;
}

