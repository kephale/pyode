/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"



void tuple_to_dMatrix3(tuple m, dMatrix3 dm)
{
	for (int r=0; r<3; r++) {
		for (int c=0; c<3; c++) {
			dm[r*3+c] = extract<dReal>(m[r][c]);
		}
	}
}

void tuple_to_dVector3(tuple vec, dVector3 v)
{
	v[0] = extract<dReal>(vec[0]);
	v[1] = extract<dReal>(vec[1]);
	v[2] = extract<dReal>(vec[2]);
}

void tuple_to_dQuaternion(tuple q, dQuaternion dq)
{
	dq[0] = extract<dReal>(q[0]);
	dq[1] = extract<dReal>(q[1]);
	dq[2] = extract<dReal>(q[2]);
	dq[3] = extract<dReal>(q[3]);
}

tuple dVector3_to_tuple(dVector3 vec)
{
	return make_tuple(vec[0], vec[1], vec[2]);
}

tuple dVector4_to_tuple(dVector4 vec)
{
	return make_tuple(vec[0], vec[1], vec[2], vec[3]);
}

tuple dMatrix3_to_tuple(dMatrix3 matrix)
{
	return make_tuple(
			make_tuple(matrix[0], matrix[1], matrix[2]),
			make_tuple(matrix[3], matrix[4], matrix[5]),
			make_tuple(matrix[6], matrix[7], matrix[8]));
}

tuple dQuaternion_to_tuple(dQuaternion q)
{
	return make_tuple(q[0], q[1], q[2], q[3]);
}

