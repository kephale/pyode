/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"


void Contact::setStruct(dContact *s)
{
	dVector3 vec;
	tuple_to_dVector3(fdir1, vec);

	surface.setStruct(&s->surface);
	s->fdir1 = vec;
	s->geom = geom.getcg();
}

void SurfaceParameters::setStruct(dSurfaceParameters *s)
{
	s->mode = mode;
	s->mu = mu;
	s->mu2 = mu2;
	s->bounce = bounce;
	s->bounce_vel = bounce_vel;
	s->soft_erp = soft_erp;
	s->soft_cfm = soft_cfm;
	s->motion1 = motion1;
	s->motion2 = motion2;
	s->slip1 = slip1;
	s->slip2 = slip2;
}

void exportContactJoint()
{
	class_<SurfaceParameters>("SurfaceParameters")
		.def_readwrite("mode", &SurfaceParameters::mode)
		.def_readwrite("mu", &SurfaceParameters::mu)
		.def_readwrite("mu2", &SurfaceParameters::mu2)
		.def_readwrite("bounce", &SurfaceParameters::bounce)
		.def_readwrite("bounce_vel", &SurfaceParameters::bounce_vel)
		.def_readwrite("soft_erp", &SurfaceParameters::soft_erp)
		.def_readwrite("soft_cfm", &SurfaceParameters::soft_cfm)
		.def_readwrite("motion1", &SurfaceParameters::motion1)
		.def_readwrite("motion2", &SurfaceParameters::motion2)
		.def_readwrite("slip1", &SurfaceParameters::slip1)
		.def_readwrite("slip2", &SurfaceParameters::slip2)
	;

	class_<Contact>("Contact")
		.def_readwrite("surface", &Contact::surface)
		.def_readwrite("fdir1", &Contact::fdir1)
		.def_readwrite("geom", &Contact::geom)
	;


	class_<ContactJoint, bases<Joint> >("ContactJoint",
			init<World &, Contact &>()[with_custodian_and_ward<1,2>()])
		.def(init<World &, JointGroup &, Contact &>()[with_custodian_and_ward<1,2,
							      with_custodian_and_ward<3,1> >()])
	;
}

