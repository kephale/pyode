/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

int areConnected(Body *b1, Body *b2);
int areConnectedExcluding(Body *b1, Body *b2, int joint_type);

tuple getIdentityMatrix();
tuple getRotationMatrixFromAxisAngle(tuple axis, dReal angle);
tuple getRotationMatrixFromEulerAngle(dReal phi, dReal theta, dReal psi);
tuple getRotationMatrixFromAxes(tuple axis1, tuple axis2);

tuple getIdentityQuaternion();
tuple getQuaternion(tuple axis, dReal angle);

tuple quaternion_to_matrix(tuple q);
tuple matrix_to_quaternion(tuple m);

void exportMain();

