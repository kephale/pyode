/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class Geom {
	dGeomID __id;
	Body *__body;

	public:

	Geom(dGeomID id) { __id = id; }
	~Geom() { dGeomDestroy(__id); }

	dGeomID id() { return __id; }

	void setBody(Body &body);
	Body const& getBody() const;

	void setPosition(tuple vec);
	void setRotation(tuple matrix);

	tuple getPosition();
	tuple getRotation();

	tuple getAABB();

	int isSpace() { return dGeomIsSpace(__id); }
	int getClass() { return dGeomGetClass(__id); }

	// FIXME
	void setCategoryBits(unsigned long bits);
	void setCollideBits(unsigned long bits);
	unsigned long getCategoryBits();
	unsigned long getCollideBits();

	//void enable() { dGeomEnable(__id); }
	//void disable() { dGeomDisable(__id); }
	//int isEnabled() { return dGeomIsEnabled(__id); }
};

void exportGeom();

