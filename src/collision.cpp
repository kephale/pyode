/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"
#define MAX_CONTACTGEOMS 30


list collide(Geom &g1, Geom &g2, int flags)
{
	dContactGeom cgs[MAX_CONTACTGEOMS];
	flags &= MAX_CONTACTGEOMS;
	int num = dCollide(g1.id(), g2.id(), flags, cgs, sizeof(dContactGeom));

	list l;
	for(int i=0; i<num; i++) {
		l.append(ContactGeom(cgs[i]));
	}
	return l;
}


void nearCallback(void *data, dGeomID o1, dGeomID o2)
{
	PyObject *self = (PyObject *) data;
	call_method<void, Geom, Geom>(self, "callback", Geom(o1), Geom(o2));
}

void spaceCollide(Space &s, PyObject *cb)
{
	dSpaceCollide(s.id(), (void *) cb, nearCallback);
}

void spaceCollide2(Geom &g1, Geom &g2, PyObject *cb)
{
	dSpaceCollide2(g1.id(), g2.id(), (void *) cb, nearCallback);
}



void exportCollision()
{
	def("collide", &collide);
	def("spaceCollide", &spaceCollide);
	def("spaceCollide2", &spaceCollide2);
}


