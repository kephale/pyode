/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class Joint {
	dJointID __id;
	Body *__body1;
	Body *__body2;
	
	public:

	Joint(dJointID id) { __id = id; }
	~Joint() { dJointDestroy(__id); }

	void attach(Body &body1, Body &body2);
	int getType() { return dJointGetType(__id); }
	Body const& getBody(int index) const;
	void setFeedback(tuple feedback);
	tuple getFeedback();

	dJointID id() { return __id; }
};

void exportJoint();

