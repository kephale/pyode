/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/


class SurfaceParameters {
	public:
	
	SurfaceParameters() { }
	
	void setStruct(dSurfaceParameters *s);

	int mode;
	dReal mu,mu2;
	dReal bounce,bounce_vel;
	dReal soft_erp;
	dReal soft_cfm;
	dReal motion1, motion2;
	dReal slip1, slip2;
};

class Contact {
	public:
	
	Contact() { }
		
	void setStruct(dContact *s);

	SurfaceParameters surface;
	tuple fdir1;
	ContactGeom geom;
};

class ContactJoint : public Joint {
	dContact __contact;
	
	public:
	ContactJoint(World &world, JointGroup &group, Contact &contact)
		: Joint(dJointCreateContact(world.id(), group.id(), &__contact))
		{ contact.setStruct(&__contact); }

	ContactJoint(World &world, Contact &contact)
		: Joint(dJointCreateContact(world.id(), 0, &__contact))
		{ contact.setStruct(&__contact); }

};


void exportContactJoint();

