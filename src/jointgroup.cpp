/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"

void exportJointGroup()
{
	class_<JointGroup>("JointGroup")
		.def("empty", &JointGroup::empty)
	;
}

