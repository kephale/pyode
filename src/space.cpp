/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"

void exportSpace()
{
	class_<Space>("Space", no_init)
		//.def("setCleanup", &Space::setCleanup)
		//.def("getCleanup", &Space::getCleanup)
		.def("add", &Space::add)
		.def("remove", &Space::remove)
		.def("query", &Space::query)
		.def("getNumGeoms", &Space::getNumGeoms)
	;

	class_<SimpleSpace, bases<Space> >("SimpleSpace")
		.def(init<Space &>()[with_custodian_and_ward<2,1>()])
	;

	class_<HashSpace, bases<Space> >("HashSpace")
		.def(init<Space &>()[with_custodian_and_ward<2,1>()])
		.def("setLevels", &HashSpace::setLevels)
	;
}

