/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

#include "pyode.h"


void Body::setPosition(tuple vec)
{
	dBodySetPosition(__id, extract<dReal>(vec[0]),
			       extract<dReal>(vec[1]),
			       extract<dReal>(vec[2]));
}

void Body::setRotation(tuple matrix)
{
	dMatrix3 m;
	tuple_to_dMatrix3(matrix, m);
	dBodySetRotation(__id, m);
}

void Body::setQuaternion(tuple q)
{
	dQuaternion dq;
	tuple_to_dQuaternion(q, dq);
	dBodySetQuaternion(__id, dq);
}

void Body::setLinearVel(tuple vec)
{
	dBodySetLinearVel(__id,	extract<dReal>(vec[0]),
			        extract<dReal>(vec[1]),
			        extract<dReal>(vec[2]));
}

void Body::setAngularVel(tuple vec)
{
	dBodySetAngularVel(__id, extract<dReal>(vec[0]),
			         extract<dReal>(vec[1]),
			         extract<dReal>(vec[2]));
}

tuple Body::getPosition()
{
	const dReal *pos;
	pos = dBodyGetPosition(__id);
	return dVector3_to_tuple((dVector3) pos);
}

tuple Body::getRotation()
{
	const dReal *rot;
	rot = dBodyGetRotation(__id);
	return dMatrix3_to_tuple((dMatrix3) rot);
}

tuple Body::getQuaternion()
{
	const dReal *q;
	q = dBodyGetQuaternion(__id);
	return dQuaternion_to_tuple((dQuaternion) q);
}

tuple Body::getLinearVel()
{
	const dReal *vel;
	vel = dBodyGetLinearVel(__id);
	return dVector3_to_tuple((dVector3) vel);
}

tuple Body::getAngularVel()
{
	const dReal *vel;
	vel = dBodyGetAngularVel(__id);
	return dVector3_to_tuple((dVector3) vel);
}


void Body::addForce(tuple vec, bool rel)
{
	dReal x,y,z;

	x = extract<dReal>(vec[0]);
	y = extract<dReal>(vec[1]);
	z = extract<dReal>(vec[2]);

	if (rel) {
		dBodyAddRelForce(__id, x, y, z);
	} else {
		dBodyAddForce(__id, x, y, z);
	}
}

void Body::addTorque(tuple vec, bool rel)
{
	dReal x,y,z;

	x = extract<dReal>(vec[0]);
	y = extract<dReal>(vec[1]);
	z = extract<dReal>(vec[2]);

	if (rel) {
		dBodyAddRelTorque(__id, x, y, z);
	} else {
		dBodyAddTorque(__id, x, y, z);
	}
}

void Body::addForceAtPos(tuple vec, tuple pos, bool rel)
{
	dReal x,y,z;
	dReal px,py,pz;

	x = extract<dReal>(vec[0]);
	y = extract<dReal>(vec[1]);
	z = extract<dReal>(vec[2]);

	px = extract<dReal>(pos[0]);
	py = extract<dReal>(pos[1]);
	pz = extract<dReal>(pos[2]);

	if (rel) {
		dBodyAddRelForceAtPos(__id, x, y, z, px, py, pz);
	} else {
		dBodyAddForceAtPos(__id, x, y, z, px, py, pz);
	}
}

void Body::addForceAtRelPos(tuple vec, tuple pos, bool rel)
{
	dReal x,y,z;
	dReal px,py,pz;

	x = extract<dReal>(vec[0]);
	y = extract<dReal>(vec[1]);
	z = extract<dReal>(vec[2]);

	px = extract<dReal>(pos[0]);
	py = extract<dReal>(pos[1]);
	pz = extract<dReal>(pos[2]);

	if (rel) {
		dBodyAddRelForceAtRelPos(__id, x, y, z, px, py, pz);
	} else {
		dBodyAddForceAtRelPos(__id, x, y, z, px, py, pz);
	}
}

tuple Body::getForce()
{
	const dReal *force = dBodyGetForce(__id);
	return dVector3_to_tuple((dVector3) force);
}

tuple Body::getTorque()
{
	const dReal *t = dBodyGetTorque(__id);
	return dVector3_to_tuple((dVector3) t);
}

void Body::setForce(tuple vec)
{
	dBodySetForce(__id, extract<dReal>(vec[0]),
			    extract<dReal>(vec[1]),
			    extract<dReal>(vec[2]));
}

void Body::setTorque(tuple vec)
{
	dBodySetTorque(__id, extract<dReal>(vec[0]),
			     extract<dReal>(vec[1]),
			     extract<dReal>(vec[2]));
}


tuple Body::getRelPointPos(tuple vec)
{
	dVector3 result;
	dBodyGetRelPointPos(__id, extract<dReal>(vec[0]),
				  extract<dReal>(vec[1]),
				  extract<dReal>(vec[2]),
				  result);
	return dVector3_to_tuple(result);
}

tuple Body::getRelPointVel(tuple vec)
{
	dVector3 result;
	dBodyGetRelPointVel(__id, extract<dReal>(vec[0]),
				  extract<dReal>(vec[1]),
				  extract<dReal>(vec[2]),
				  result);
	return dVector3_to_tuple(result);
}

tuple Body::getPointVel(tuple vec)
{
	dVector3 result;
	dBodyGetPointVel(__id,	extract<dReal>(vec[0]),
				extract<dReal>(vec[1]),
				extract<dReal>(vec[2]),
				result);
	return dVector3_to_tuple(result);
}

tuple Body::getPosRelPoint(tuple vec)
{
	dVector3 result;
	dBodyGetPosRelPoint(__id, extract<dReal>(vec[0]),
				  extract<dReal>(vec[1]),
				  extract<dReal>(vec[2]),
				  result);
	return dVector3_to_tuple(result);
}

tuple Body::vectorToWorld(tuple vec)
{
	dVector3 result;
	dBodyVectorToWorld(__id, extract<dReal>(vec[0]),
				 extract<dReal>(vec[1]),
				 extract<dReal>(vec[2]),
				 result);
	return dVector3_to_tuple(result);
}

tuple Body::vectorFromWorld(tuple vec)
{
	dVector3 result;
	dBodyVectorFromWorld(__id, extract<dReal>(vec[0]),
				   extract<dReal>(vec[1]),
				   extract<dReal>(vec[2]),
				   result);
	return dVector3_to_tuple(result);
}

void Body::setFiniteRotationAxis(tuple vec)
{
	dBodySetFiniteRotationAxis(__id, extract<dReal>(vec[0]),
					 extract<dReal>(vec[1]),
					 extract<dReal>(vec[2]));
}

tuple Body::getFiniteRotationAxis()
{
	dVector3 v;
	dBodyGetFiniteRotationAxis(__id, v);
	return dVector3_to_tuple(v);
}

void exportBody()
{
	class_<Body>("Body", init<World&>()[with_custodian_and_ward<1,2>()])
		.def("setPosition", &Body::setPosition)
		.def("setRotation", &Body::setRotation)
		.def("setQuaternion", &Body::setQuaternion)
		.def("setLinearVel", &Body::setLinearVel)
		.def("setAngularVel", &Body::setAngularVel)

		.def("getPosition", &Body::getPosition)
		.def("getRotation", &Body::getRotation)
		.def("getQuaternion", &Body::getQuaternion)
		.def("getLinearVel", &Body::getLinearVel)
		.def("getAngularVel", &Body::getAngularVel)

		.def("setMass", &Body::setMass, with_custodian_and_ward<1,2>())
		.def("getMass", &Body::getMass, return_internal_reference<>())

		.def("addForce", &Body::addForce)
		.def("addTorque", &Body::addTorque)
		.def("addForceAtPos", &Body::addForceAtPos)
		.def("addForceAtRelPos", &Body::addForceAtRelPos)

		.def("getForce", &Body::getForce)
		.def("getTorque", &Body::getTorque)

		.def("setForce", &Body::setForce)
		.def("setTorque", &Body::setTorque)

	
		.def("getRelPointPos", &Body::getRelPointPos)
		.def("getRelPointVel", &Body::getRelPointVel)
		.def("getPointVel", &Body::getPointVel)
		.def("getPosRelPoint", &Body::getPosRelPoint)

		.def("vectorToWorld", &Body::vectorToWorld)
		.def("vectorFromWorld", &Body::vectorFromWorld)

		.def("enable", &Body::enable)
		.def("disable", &Body::disable)
		.def("isEnabled", &Body::isEnabled)

		.def("setFiniteRotationMode", &Body::setFiniteRotationMode)
		.def("getFiniteRotationMode", &Body::getFiniteRotationMode)

		.def("setFiniteRotationAxis", &Body::setFiniteRotationAxis)
		.def("getFiniteRotationAxis", &Body::getFiniteRotationAxis)

		.def("getNumJoints", &Body::getNumJoints)
		.def("setGravityMode", &Body::setGravityMode)
		.def("getGravityMode", &Body::getGravityMode)
	;
}

