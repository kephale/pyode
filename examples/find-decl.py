# find-decl.py
# Finds functions from objects.h and mass.h which are not implemented in PyODE
# Alex Dumitrache <alex@cimr.pub.ro>
#
# Usage: 
#  1) Set the correct paths for ODE include dir and PyODE source dir
#  2) python find-decl.py | grep NOT


import re, os, sys, string

odeinc = '/home/alex/src/ode-svn/opende/trunk/include/ode/'
srcdir = "pyode/src/"

lines = []
for f in ['objects.h', 'mass.h']:
    if f.endswith(".h"):
        lin = open(os.path.join(odeinc, f)).readlines()
        lines.extend(lin)


src = {}
for f in os.listdir(srcdir):
    if f.endswith(".pyx"):
        text = open(os.path.join(srcdir, f)).read()
        src[f] = text



def find_decl(line):
    line = line.strip()
    print "searching for ", line
    found_decl = False
    found_impl = False
    for f in src:
        if line in src[f]:
            if f == "declarations.pyx":
                print "declared"
                found_decl = True
            else:
                print "implemented in", f
                found_impl = True

    
    if not found_decl:
        if found_impl:
            print "IMPLEMENTED, BUT NOT DECLARED: ", line
        else:
            print "NOT FOUND: ", line
    else:
        if not found_impl:
            print "NOT IMPLEMENTED:", line
            

def parse_decl(line):
    line = line.strip() + " "
    # find function name
    b = string.find(line, "(")
    #print "parsing ", line
    if b > 0:
        line = line[:b].strip()

    words = line.split(" ")
    funcname = words[-1]
    funcname = funcname.strip("*")
    #print "=> ", funcname
    return funcname
    


doc = ""
for l in lines:
    if 'DEPRECATED' in l:
        continue
    m = re.match("^ODE_API\ (.*)$", l.strip())
    if m: # is a declaration
        decl = m.groups()[0]
        funcname = parse_decl(decl)
        find_decl(funcname)
        #print decl
        #print doc
        doc = ""

    if re.match("(/\*\*|\*)", l.strip()):
        doc += l.strip("* /\n") + "\n"
    