# ODE Demo

import sys
import pygame
from pygame.locals import *
import ode

def coord(x,y):
    "Convert world coordinates to pixel coordinates."
    return 320+170*x, 400-170*y


# Initialize pygame
pygame.init()

# Open a display
srf = pygame.display.set_mode((640,480))

world = ode.World()
world.setGravity((0,-9.81,0))

body1 = ode.Body(world)
M = ode.Mass()
M.setSphere(2500, 0.05)
body1.setMass(M)
body1.setPosition((1,2,0))

body2 = ode.Body(world)
M = ode.Mass()
M.setSphere(2500, 0.05)
body2.setMass(M)
body2.setPosition((2,2,0))

j1 = ode.BallJoint(world)
j1.attach(body1, ode.environment)
j1.setAnchor( (0,2,0) )
#j1 = ode.HingeJoint(world)
#j1.attach(body1, ode.environment)
#j1.setAnchor( (0,2,0) )
#j1.setAxis( (0,0,1) )
#j1.setParam(ode.ParamVel, 3)
#j1.setParam(ode.ParamFMax, 22)

j2 = ode.BallJoint(world)
j2.attach(body1, body2)
j2.setAnchor( (1,2,0) )

clk = pygame.time.Clock()

# Keep the window open and wait for a key
fps = 50
dt = 1.0/fps
loopFlag = True
while loopFlag:
    events = pygame.event.get()
    for e in events:
        if e.type==QUIT:
            loopFlag=False
#        if e.type==KEYDOWN:
#            loopFlag=False

    # Clear the screen
    srf.fill((255,255,255))

    x1,y1,z1 = body1.getPosition()
    x2,y2,z2 = body2.getPosition()
    pygame.draw.circle(srf, (55,0,200), coord(x1,y1), 20, 0)
    pygame.draw.line(srf, (55,0,200), coord(0,2), coord(x1,y1), 2)
    pygame.draw.circle(srf, (55,0,200), coord(x2,y2), 20, 0)
    pygame.draw.line(srf, (55,0,200), coord(x1,y1), coord(x2,y2), 2)

    pygame.display.flip()

    world.step(dt)
    
    clk.tick(fps)
#    print "fps: %2.1f  dt:%d rawdt:%d"%(clk.get_fps(), clk.get_time(), clk.get_rawtime())
    

