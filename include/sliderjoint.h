/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class SliderJoint : public Joint {
	public:
	SliderJoint(World &world, JointGroup &group) : Joint(dJointCreateSlider(world.id(), group.id())) { }
	SliderJoint(World &world) : Joint(dJointCreateSlider(world.id(), 0)) { }

	void setAxis(tuple vec);
	tuple getAxis();
	
	dReal getPosition() { return dJointGetSliderPosition(id()); }
	dReal getPositionRate() { return dJointGetSliderPositionRate(id()); }

	void setParam(int parameter, dReal value)
	{ dJointSetSliderParam(id(), parameter, value); }
	dReal getParam(int parameter)
	{ return dJointGetSliderParam(id(), parameter); }
};

void exportSliderJoint();

