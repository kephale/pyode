/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

class Space {
	dSpaceID __id;

	public:

	Space() { }
	Space(dSpaceID id) { __id = id; dSpaceSetCleanup(__id, 0); }
	~Space() { dSpaceDestroy(__id); }

	dSpaceID id() { return __id; }

	//void setCleanup(int c) { dSpaceSetCleanup(__id, c); }
	//int getCleanup() { return dSpaceGetCleanup(__id); }

	void add(Geom &g) { dSpaceAdd(__id, g.id()); }
	void remove(Geom &g) { dSpaceRemove(__id, g.id()); }

	int query(Geom &g) { return dSpaceQuery(__id, g.id()); }
	int getNumGeoms() { return dSpaceGetNumGeoms(__id); }
};

class SimpleSpace : public Space {
	public:

	SimpleSpace() : Space(dSimpleSpaceCreate(0)) { }
	SimpleSpace(Space &s) : Space(dSimpleSpaceCreate(s.id())) { }
};

class HashSpace : public Space {
	public:
	
	HashSpace() : Space(dHashSpaceCreate(0)) { }
	HashSpace(Space &s) : Space(dHashSpaceCreate(s.id())) { }

	void setLevels(int min, int max) { dHashSpaceSetLevels(id(), min, max); }
};
	

void exportSpace();

