/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"



int areConnected(Body *b1, Body *b2)
{
	return dAreConnected(b1->id(), b2->id());
}

int areConnectedExcluding(Body *b1, Body *b2, int joint_type)
{
	return dAreConnectedExcluding(b1->id(), b2->id(), joint_type);
}

tuple getIdentityMatrix()
{
	dMatrix3 R;
	dRSetIdentity(R);
	return dMatrix3_to_tuple(R);
}

tuple getIdentityQuaternion()
{
	dQuaternion q;
	dQSetIdentity(q);
	return dQuaternion_to_tuple(q);
}

tuple getRotationMatrixFromAxisAngle(tuple axis, dReal angle)
{
	dMatrix3 R;
	dRFromAxisAndAngle(R, extract<dReal>(axis[0]),
			      extract<dReal>(axis[1]),
			      extract<dReal>(axis[2]), angle);
	return dMatrix3_to_tuple(R);
}

tuple getRotationMatrixFromEulerAngle(dReal phi, dReal theta, dReal psi)
{
	dMatrix3 R;
	dRFromEulerAngles(R, phi, theta, psi);
	return dMatrix3_to_tuple(R);
}

tuple getRotationMatrixFromAxes(tuple axis1, tuple axis2)
{
	dMatrix3 R;
	dRFrom2Axes(R, extract<dReal>(axis1[0]), extract<dReal>(axis1[1]), extract<dReal>(axis1[2]),
		       extract<dReal>(axis2[0]), extract<dReal>(axis2[1]), extract<dReal>(axis2[2]));
	return dMatrix3_to_tuple(R);
}

tuple getQuaternion(tuple axis, dReal angle)
{
	dQuaternion q;
	dQFromAxisAndAngle(q, extract<dReal>(axis[0]), extract<dReal>(axis[1]), extract<dReal>(axis[2]),
			angle);
	return dQuaternion_to_tuple(q);
}

tuple quaternion_to_matrix(tuple q)
{
	dQuaternion dq;
	dMatrix3 m;

	tuple_to_dQuaternion(q, dq);
	
	dQtoR(dq, m);
	return dMatrix3_to_tuple(m);
}

tuple matrix_to_quaternion(tuple m)
{
	dMatrix3 dm;
	dQuaternion q;

	tuple_to_dMatrix3(m, dm);
	
	dRtoQ(dm, q);
	return dQuaternion_to_tuple(q);
}

void exportMain()
{
	def("areConnected", &areConnected);
	def("areConnectedExcluding", &areConnectedExcluding);
	def("getIdentityMatrix", &getIdentityMatrix);
	def("getRotationMatrixFromAxisAngle", &getRotationMatrixFromAxisAngle);
	def("getRotationMatrixFromAxes", &getRotationMatrixFromAxes);
	def("getRotationMatrixFromEulerAngle", &getRotationMatrixFromEulerAngle);
	def("getIdentityQuaternion", &getIdentityQuaternion);
	def("getQuaternion", &getQuaternion);
	def("quaternion_to_matrix", &quaternion_to_matrix);
	def("matrix_to_quaternion", &matrix_to_quaternion);
}


