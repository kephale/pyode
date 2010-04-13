# Script to generate Pyrex declarations from the ODE headers.
# alex@cimr.pub.ro
import re
import string

decl = """
 dReal dBodyGetLinearDamping (dBodyID);
 dReal dBodyGetAngularDamping (dBodyID);
 void dBodySetLinearDamping (dBodyID, dReal scale);
 void dBodySetAngularDamping (dBodyID, dReal scale);
 void dBodySetDamping (dBodyID, dReal linear_scale, dReal angular_scale);
 dReal dBodyGetLinearDampingThreshold (dBodyID);
 dReal dBodyGetAngularDampingThreshold (dBodyID);
 void dBodySetLinearDampingThreshold (dBodyID, dReal threshold);
 void dBodySetAngularDampingThreshold (dBodyID, dReal threshold);
 void dBodySetDampingDefaults (dBodyID);
 dReal dBodyGetMaxAngularSpeed (dBodyID);
 void dBodySetMaxAngularSpeed (dBodyID, dReal max_speed);
"""

lines = decl.split("\n")
for line in lines:
    line = line.strip()
    reg = "(void|[^ ]+)\ d(.*)(G|S)et([^ ]+)\ \(d(.*)ID([^\)]*)\)"
    m = re.match(reg, line)
    #~ print m
    if m:
        print
        print "    # %s" % line

        g = m.groups()
        #~ print g
        if g[2] == 'G':
            obj = g[1]
            name = g[3]
            type = g[0]
            type = type.replace("dReal", "float")
            print """    def get%s(self):
        \"""
        get%s() -> %s

        This is a wrapper for the following ODE function:

        %s

        \"""
        return d%sGet%s(self.%sid)
        """ % (name,name,type,line,obj,name,obj[0].lower())

        elif g[2] == 'S':
            obj = g[1]
            name = g[3]
            type = g[0]
            type = type.replace("dReal", "float")
            #~ print g
            exa = g[-1].split(",")[1:]
            extra_args = []
            extra_args_names = []
            for a in exa:
                a = a.split(" ")
                varname = a[-1]
                vartype = string.join(a[:-1], "")
                extra_args.append((varname,vartype))
                extra_args_names.append(varname)

            print """    def set%s(%s):
        \"""
        set%s(%s)

        This is a wrapper for the following ODE function:

        %s

        \"""
        d%sSet%s(%s)
        """ % (name,
               string.join(["self"] + extra_args_names, ", "),
               name,
               string.join(extra_args_names, ", "),
               line,
               obj,
               name,
               string.join(["self.%sid" % obj[0].lower()] + extra_args_names, ", "))



