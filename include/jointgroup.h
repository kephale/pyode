/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class JointGroup {
	dJointGroupID __id;
	
	public:

	JointGroup() { __id = dJointGroupCreate(0); }
	~JointGroup() { dJointGroupDestroy(__id); }

	dJointGroupID id() { return __id; }
	void empty() { dJointGroupEmpty(__id); }
};

void exportJointGroup();

