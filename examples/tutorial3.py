# pyODE example 3: Collision detection

import sys, os, random
import pygame 
from pygame.locals import *
from cgtypes import *
from math import *
from OpenGL.GL import *
from OpenGL.GLU import *
from OpenGL.GLUT import *
import ode


# prepare_GL
def prepare_GL():
    """Prepare drawing.
    """
    
    # Viewport
    glViewport(0,0,640,480)

    # Initialize
    glClearColor(0.8,0.8,0.9,0)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST)
    glDisable(GL_LIGHTING)
    glEnable(GL_LIGHTING)
    glEnable(GL_NORMALIZE)
    glShadeModel(GL_FLAT)

    # Projection
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    P = mat4(1).perspective(45,1.3333,0.2,20)
    glMultMatrixd(P.toList())

    # Initialize ModelView matrix
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()

    # Light source
    glLightfv(GL_LIGHT0,GL_POSITION,[0,0,1,0])
    glLightfv(GL_LIGHT0,GL_DIFFUSE,[1,1,1,1])
    glLightfv(GL_LIGHT0,GL_SPECULAR,[1,1,1,1])
    glEnable(GL_LIGHT0)

    # View transformation
    V = mat4(1).lookAt(1.2*vec3(2,3,4),(0.5,0.5,0), up=(0,1,0))
    V.rotate(pi,vec3(0,1,0))  
    V = V.inverse()
    glMultMatrixd(V.toList())


# draw_body
def draw_body(body):
    """Draw an ODE body.
    """
    
    x,y,z = body.getPosition()
    R = body.getRotation()
    T = mat4()
    T[0,0] = R[0]
    T[0,1] = R[1]
    T[0,2] = R[2]
    T[1,0] = R[3]
    T[1,1] = R[4]
    T[1,2] = R[5]
    T[2,0] = R[6]
    T[2,1] = R[7]
    T[2,2] = R[8]
    T[3] = (x,y,z,1.0)

    glPushMatrix()
    glMultMatrixd(T.toList())
    if body.shape=="box":
        sx,sy,sz = body.boxsize
        glScale(sx, sy, sz)
        glutSolidCube(1)
    glPopMatrix()


# create_box
def create_box(world, space, density, lx, ly, lz):
    """Create a box body and its corresponding geom."""

    # Create body
    body = ode.Body(world)
    M = ode.Mass()
    M.setBox(density, lx, ly, lz)
    body.setMass(M)

    # Set parameters for drawing the body
    body.shape = "box"
    body.boxsize = (lx, ly, lz)

    # Create a box geom for collision detection
    geom = ode.GeomBox(space, lengths=body.boxsize)
    geom.setBody(body)

    return body

# drop_object
def drop_object():
    """Drop an object into the scene."""
    
    global bodies, counter, objcount
    
    body = create_box(world, space, 1000, 1.0,0.2,0.2)
    body.setPosition( (random.gauss(0,0.1),3.0,random.gauss(0,0.1)) )
    m = mat4().rotation(random.uniform(0,2*pi), (0,1,0))
    body.setRotation(m.toList())
    bodies.append(body)
    counter=0
    objcount+=1

# explosion
def explosion():
    """Simulate an explosion.

    Every object is pushed away from the origin.
    The force is dependent on the objects distance from the origin.
    """
    global bodies

    for b in bodies:
        p = vec3(b.getPosition())
        d = p.length()
        a = max(0, 40000*(1.0-0.2*d*d))
        p = vec3(p.x/4, p.y, p.z/4)
        b.addForce(a*p.normalize())

# pull
def pull():
    """Pull the objects back to the origin.

    Every object will be pulled back to the origin.
    Every couple of frames there'll be a thrust upwards so that
    the objects won't stick to the ground all the time.
    """
    global bodies, counter
    
    for b in bodies:
        p = vec3(b.getPosition())
        b.addForce(-1000*p.normalize())
        if counter%60==0:
            b.addForce((0,10000,0))
    
# Collision callback
def near_callback(args, geom1, geom2):
    """Callback function for the collide() method.

    This function checks if the given geoms do collide and
    creates contact joints if they do.
    """

    # Check if the objects do collide
    contacts = ode.collide(geom1, geom2)

    # Create contact joints
    world,contactgroup = args
    for c in contacts:
        c.setBounce(0.2)
        c.setMu(5000)
        j = ode.ContactJoint(world, contactgroup, c)
        j.attach(geom1.getBody(), geom2.getBody())


######################################################################

# Initialize pygame
passed, failed = pygame.init()

# Open a window
srf = pygame.display.set_mode((640,480), OPENGL | DOUBLEBUF)

# Create a world object
world = ode.World()
world.setGravity( (0,-9.81,0) )
world.setERP(0.8)
world.setCFM(1E-5)

# Create a space object
space = ode.Space()

# Create a plane geom which prevent the objects from falling forever
floor = ode.GeomPlane(space, (0,1,0), 0)

# A list with ODE bodies
bodies = []

# A joint group for the contact joints that are generated whenever
# two bodies collide
contactgroup = ode.JointGroup()

# Some variables used inside the simulation loop
fps = 50
dt = 1.0/fps
running = True
state = 0
counter = 0
objcount = 0
clk = pygame.time.Clock()
#frame=1
while running:
    events = pygame.event.get()
    for e in events:
        if e.type==QUIT:
            running=False
        elif e.type==KEYDOWN:
            running=False
        elif e.type==MOUSEBUTTONDOWN or e.type==MOUSEMOTION:
            pass

    counter+=1
    # State 0: Drop objects
    if state==0:
        if counter==20:
            drop_object()
        if objcount==30:
            state=1
            counter=0
    # State 1: Explosion and pulling back the objects
    elif state==1:
        if counter==100:
            explosion()
        if counter>300:
            pull()
        if counter==500:
            counter=20

    # Draw the scene
    prepare_GL()
    for b in bodies:
        draw_body(b)
    
    pygame.display.flip()
#    pygame.image.save(srf,"delme%04d.bmp"%frame)
#    frame+=1

    # Simulate
    n = 2
    for i in range(n):
        # Detect collisions and create contact joints
        space.collide((world,contactgroup), near_callback)

        # Simulation step
#        world.step(dt/n)
        world.quickStep(dt/n)

        # Remove all contact joints
        contactgroup.empty()
    
    clk.tick(fps)
    
