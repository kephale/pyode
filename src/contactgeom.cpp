/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"


void ContactGeom::setPos(tuple pos)
{
	tuple_to_dVector3(pos, cg.pos);
}

void ContactGeom::setNormal(tuple normal)
{
	tuple_to_dVector3(normal, cg.normal);
}

tuple ContactGeom::getPos()
{
	return dVector3_to_tuple(cg.pos);
}

tuple ContactGeom::getNormal()
{
	return dVector3_to_tuple(cg.normal);
}

void ContactGeom::setGeoms(Geom &g1, Geom &g2)
{
	__g1 = &g1;
	__g2 = &g2;

	cg.g1 = g1.id();
	cg.g2 = g2.id();
}

Geom const& ContactGeom::getGeom(int index) const
{
	if (index==0) {
		return (Geom const&) *__g1;
	} else {
		return (Geom const&) *__g2;
	}
}


void exportContactGeom()
{
	class_<ContactGeom>("ContactGeom")
		.def("setPos", &ContactGeom::setPos)
		.def("getPos", &ContactGeom::getPos)
		.def("setNormal", &ContactGeom::setNormal)
		.def("getNormal", &ContactGeom::getNormal)
		.def("setDepth", &ContactGeom::setDepth)
		.def("getDepth", &ContactGeom::getDepth)
		.def("setGeoms", &ContactGeom::setGeoms, with_custodian_and_ward<1,2,
							 with_custodian_and_ward<1,3> >())
		.def("getGeom", &ContactGeom::getGeom, return_internal_reference<>())
	;
}

