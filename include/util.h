/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

void tuple_to_dMatrix3(tuple m, dMatrix3 dm);
void tuple_to_dVector3(tuple vec, dVector3 v);
void tuple_to_dQuaternion(tuple q, dQuaternion dq);

tuple dVector3_to_tuple(dVector3 vec);
tuple dVector4_to_tuple(dVector4 vec);
tuple dMatrix3_to_tuple(dMatrix3 matrix);
tuple dQuaternion_to_tuple(dQuaternion q);

