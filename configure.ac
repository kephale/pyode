AC_INIT(src/pyode.cpp)
AM_INIT_AUTOMAKE(pyode,0.1)
AM_CONFIG_HEADER(src/config.h)

AC_PROG_CC
AC_PROG_CXX
AC_PROG_INSTALL

boost_inc_dir=""
boost_lib_dir=""

AC_ARG_WITH(boost-includes,
	AC_HELP_STRING([--with-boost-includes=PATH],
                       [Directory that has the boost headers.]),
	boost_inc_dir=$withval)
	
AC_ARG_WITH(boost-libs,
	AC_HELP_STRING([--with-boost-libs=PATH],
		       [Directory that has the boost libraries]),
	boost_lib_dir=$withval)

BOOST_CFLAGS=""
BOOST_LIBS="-lboost_python"

if test -n "$boost_inc_dir"; then
    AC_MSG_CHECKING(boost include dir)
    if test -e $boost_inc_dir/boost/python.hpp; then
        BOOST_CFLAGS="-I$boost_inc_dir";
    else
        AC_MSG_ERROR("Unable to find boost/python.hpp in $boost_inc_dir")
    fi
    AC_MSG_RESULT(done)
fi

if test -n "$boost_lib_dir"; then
    AC_MSG_CHECKING(boost library dir)
    if test -e $boost_lib_dir/libboost_python.so; then
        BOOST_LIBS="-L$boost_lib_dir $BOOST_LIBS";
    else
        AC_MSG_ERROR("Unable to find libboost_python.so in $boost_lib_dir")
    fi
    AC_MSG_RESULT(done)
fi

AC_SUBST(BOOST_CFLAGS)
AC_SUBST(BOOST_LIBS)

pylibdir="" dnl Default just means we use /usr/lib
pyincdir="" dnl Default just means we use /usr/include
pyversion="2.2"
AC_ARG_WITH(python-version, AC_HELP_STRING([--with-python-version=VER],
                            [The version of python to use, default 2.2]),
            pyversion=$withval)
AC_ARG_WITH(python-libs, AC_HELP_STRING([--with-python-libs=PATH],
                            [Directory that has the python library]),
            pyincdir=$withval)
AC_ARG_WITH(python-includes, AC_HELP_STRING([--with-python-includes=PATH],
                            [Directory that has the python headers]),
            pylibdir=$withval)

PYTHON_CFLAGS="-I/usr/include/python$pyversion"
PYTHON_LIBS="-lpython$pyversion"
if test -n "$pyincdir"; then
    AC_MSG_CHECKING(for python headers in $pyincdir/python$pyversion)
    if test -e $pyincdir/python$pyversion/Python.h; then
        PYTHON_CFLAGS="-I$pyincdir/python$pyversion";
    else
        AC_MSG_ERROR("Unable to locate")
    fi
    AC_MSG_RESULT(found)
fi

if test -n "$pylibdir"; then
    AC_MSG_CHECKING(for python library version $pyversion in $pylibdir)
    if test -e $pylibdir/libpython$pyversion.so; then
        PYTHON_LIBS="-L$pylibdir $PYTHON_LIBS";
    else
        AC_MSG_ERROR("Unable to locate")
    fi
    AC_MSG_RESULT(found)
fi

AC_SUBST(PYTHON_CFLAGS)
AC_SUBST(PYTHON_LIBS)

AC_OUTPUT(Makefile src/Makefile)

