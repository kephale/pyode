#include "pyode.h"

BOOST_PYTHON_MODULE(pyode)
{
	exportMass();
	exportWorld();
	exportBody();
	exportJoint();
	exportJointGroup();

	exportGeom();
	exportContactGeom();
	
	exportAMotorJoint();
	exportBallJoint();
	exportFixedJoint();
	exportHinge2Joint();
	exportHingeJoint();
	exportSliderJoint();
	exportUniversalJoint();
	exportContactJoint();

	exportMain();
}

