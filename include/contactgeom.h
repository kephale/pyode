class ContactGeom {
	dContactGeom cg;
	Geom *__g1;
	Geom *__g2;
	
	public:

	ContactGeom() { }
	ContactGeom(dContactGeom dcg) { cg = dcg; }

	dContactGeom getcg() { return cg; }
	
	void setPos(tuple vec);
	void setNormal(tuple normal);
	void setDepth(dReal depth) { cg.depth = depth; }
	
	tuple getPos();
	tuple getNormal();
	dReal getDepth() { return cg.depth; }

	void setGeoms(Geom &g1, Geom &g2);
	Geom const& getGeom(int index) const;
};

void exportContactGeom();

