/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"



void Joint::setFeedback(tuple feedback)
{
	dJointFeedback *f;
	
	f = new dJointFeedback;
	tuple_to_dVector3(feedback[0], f->t1);
	tuple_to_dVector3(feedback[1], f->f1);
	tuple_to_dVector3(feedback[2], f->t2);
	tuple_to_dVector3(feedback[3], f->f2);

	dJointSetFeedback(__id, f);
}

tuple Joint::getFeedback()
{
	dJointFeedback *f = dJointGetFeedback(__id);
	return make_tuple(dVector3_to_tuple(f->t1), dVector3_to_tuple(f->f1),
			  dVector3_to_tuple(f->t2), dVector3_to_tuple(f->f2));
}

void Joint::attach(Body &body1, Body &body2)
{
	dJointAttach(__id, body1.id(), body2.id());
	__body1 = &body1;
	__body2 = &body2;
}

Body const& Joint::getBody(int index) const
{
	if (index == 0) {
		return (Body const&) *__body1;
	} else {
		return (Body const&) *__body2;
	}
}

void exportJoint()
{
	class_<Joint>("Joint", no_init)
		.def("attach", &Joint::attach, with_custodian_and_ward<1,2,
					       with_custodian_and_ward<1,3> >())
		.def("getType", &Joint::getType)
		.def("getBody", &Joint::getBody, return_internal_reference<>())
		.def("setFeedback", &Joint::setFeedback)
		.def("getFeedback", &Joint::getFeedback)
	;
}

