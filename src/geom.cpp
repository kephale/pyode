/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"


void Geom::setBody(Body &body)
{
	__body = &body;
	dGeomSetBody(__id, body.id());
}

Body const& Geom::getBody() const
{
	return (Body const&) *__body;
}

void Geom::setPosition(tuple vec)
{
	dGeomSetPosition(__id, extract<dReal>(vec[0]),
			       extract<dReal>(vec[1]),
			       extract<dReal>(vec[2]));
}

void Geom::setRotation(tuple matrix)
{
	dMatrix3 R;
	tuple_to_dMatrix3(matrix, R);
	dGeomSetRotation(__id, R);
}

tuple Geom::getPosition()
{
	const dReal *pos = dGeomGetPosition(__id);
	return dVector3_to_tuple((dVector3) pos);
}

tuple Geom::getRotation()
{
	const dReal *rot = dGeomGetRotation(__id);
	return dMatrix3_to_tuple((dMatrix3) rot);
}

tuple Geom::getAABB()
{
	dReal aabb[6];
	dGeomGetAABB(__id, aabb);
	return make_tuple(aabb[0], aabb[1], aabb[2], aabb[3], aabb[4], aabb[5], aabb[6]);
}


void Geom::setCategoryBits(unsigned long bits)
{
	dGeomSetCategoryBits(__id, bits);
}

void Geom::setCollideBits(unsigned long bits)
{
	dGeomSetCollideBits(__id, bits);
}

unsigned long Geom::getCategoryBits()
{
	return dGeomGetCategoryBits(__id);
}

unsigned long Geom::getCollideBits()
{
	return dGeomGetCollideBits(__id);
}


void exportGeom()
{
	class_<Geom>("Geom", no_init)
		.def("setBody", &Geom::setBody, with_custodian_and_ward<1,2>())
		.def("getBody", &Geom::getBody, return_internal_reference<>())
		.def("setPosition", &Geom::setPosition)
		.def("getPosition", &Geom::getPosition)
		.def("getAABB", &Geom::getAABB)
		.def("isSpace", &Geom::isSpace)
		.def("getClass", &Geom::getClass)
		.def("setCategoryBits", &Geom::setCategoryBits)
		.def("getCategoryBits", &Geom::getCategoryBits)
		.def("setCollideBits", &Geom::setCollideBits)
		.def("getCollideBits", &Geom::getCollideBits)
		//.def("enable", &Geom::enable)
		//.def("disable", &Geom::disable)
		//.def("isEnabled", &Geom::isEnabled)
	;
}

