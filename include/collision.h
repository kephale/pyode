/**************************************
 * pyode - Python-ODE interface	      *
 * Copyright (C) 2003 Timothy Stranex *
 **************************************/

list collide(Geom &g1, Geom &g2, int flags);
void spaceCollide(Space &s, PyObject *cb);
void spaceCollide2(Geom &g1, Geom &g2, PyObject *cb);

void exportCollision();

