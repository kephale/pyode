INCLUDES = $(BOOST_CFLAGS) $(PYTHON_CFLAGS) -ftemplate-depth-100 -I../include

bin_PROGRAMS = pyode.so

pyode_so_SOURCES = mass.cpp world.cpp body.cpp joint.cpp jointgroup.cpp \
                   balljoint.cpp hingejoint.cpp sliderjoint.cpp \
		   universaljoint.cpp fixedjoint.cpp contactjoint.cpp \
		   hinge2joint.cpp amotorjoint.cpp main.cpp util.cpp \
		   pyode.cpp geom.cpp contactgeom.cpp space.cpp \
		   spheregeom.cpp

pyode_so_LDFLAGS = -shared
pyode_so_LDADD = $(BOOST_LIBS) $(PYTHON_LIBS) -lode

