#!/usr/bin/env python

import unittest
import ode
import math
from xode import node, transform, parser, errors

test_doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
<xode>
  <world name="world1">

    <transform>
      <matrix4f m00="1.0" m01="2.0" m02="3.0" m03="4.0"
                m10="1.2" m11="2.2" m12="3.2" m13="4.2"
                m20="1.4" m21="2.4" m22="3.4" m23="4.4"
                m30="1.8" m31="2.8" m32="3.8" m33="4.8"/>
    </transform>
  
    <space name="space1">
      <body name="body1" enabled="false" gravitymode="0">
        
        <transform scale="2.0">
          <position x="10.0" y="11.0" z="12.0"/>
          <rotation>
            <euler x="45.0" y="45.0" z="45.0" aformat="radians"/>
          </rotation>
        </transform>
        
        <torque x="1.0" y="2.0" z="3.0"/>
        <force x="2.0" y="3.0" z="4.0"/>
        <finiteRotation mode="1" xaxis="1.0" yaxis="1.0" zaxis="1.0"/>
        <linearVel x="1.0" y="2.0" z="3.0"/>
        <angularVel x="3.0" y="2.0" z="1.0"/>

        <mass name="mass1">
          <mass_shape density="1.0">
            <sphere radius="1.0"/>
          </mass_shape>

          <mass name="mass2">
            <mass_shape density="2.0">
              <sphere radius="10.0"/>
            </mass_shape>
            <adjust total="4.0"/>
          </mass>
        </mass>

        <joint name="joint1">
          <ball>
            <anchor x="1.0" y="2.0" z="3.0"/>
          </ball>
        </joint>

        <geom name="geom1">
          <box sizex="10" sizey="20" sizez="30"/>
        </geom>
      </body>

      <body name="body2">
        <joint name="joint2">
          <link1 body="body1"/>
          <ball/>
        </joint>
      </body>

      <joint name="joint3">
        <link1 body="body1"/>
        <link2 body="body2"/>
        <ball/>
      </joint>
      
    </space>
  </world>

  <world name="world2">
    <space>
    <body name="body3">
      <transform>
        <matrix4f m00="1.0" m01="0.0" m02="0.0" m03="0.0"
                  m10="0.0" m11="1.0" m12="0.0" m13="0.0"
                  m20="0.0" m21="0.0" m22="1.0" m23="0.0"
                  m30="10.0" m31="20.0" m32="30.0" m33="0.0"/>
      </transform>
    </body>

    <body name="body4">
      <transform>
        <position x="1" y="1" z="1"/>
      </transform>
      <body name="body5">
        <transform>
          <position x="2" y="2" z="2"/>
        </transform>
      </body>
    </body>

    <body name="body6">
      <transform>
        <rotation>
          <euler x="0" y="0" z="0.78" aformat="radians"/>
        </rotation>
      </transform>

      <body name="body7">
        <transform absolute="true">
          <matrix4f m00="1.0" m01="2.0" m02="3.0" m03="4.0"
                    m10="1.2" m11="2.2" m12="3.2" m13="4.2"
                    m20="1.4" m21="2.4" m22="3.4" m23="4.4"
                    m30="1.8" m31="2.8" m32="3.8" m33="4.8"/>
        </transform>

        <geom name="geom6">
          <transform>
            <position x="1.0" y="2.0" z="3.0"/>
            <rotation>
              <euler x="0.78" y="0" z="0" aformat="radians"/>
            </rotation>
          </transform>
          <sphere radius="1.0"/>
        </geom>
        
      </body>
    </body>

    <geom name="geom2">
      <cappedCylinder radius="15.0" length="3.0"/>
    </geom>

    <geom name="geom3">
      <ray length="11.0"/>
      
      <geom name="geom4">
        <plane a="0.0" b="1.0" c="0.0" d="17.0"/>
      </geom>

      <geom name="geom5">
        <transform>
          <position x="1.0" y="2.0" z="3.0"/>
          <rotation>
            <euler x="0.0" y="0.0" z="0.78" aformat="radians"/>
          </rotation>
        </transform>

        <sphere radius="23.0"/>
      </geom>
      
    </geom>
    
    </space>
  </world>

</xode>'''

trimesh_doc='''<?xml version="1.0" encoding="iso-8859-1"?>
<xode>
  <world>
    <space>
      <geom name="trimesh1">
        <trimesh>
          <vertices>
            <v x="0" y="1" z="1" />
            <v x="1" y="2" z="2" />
            <v x="2" y="0" z="1" />
            <v x="0" y="1" z="2" />
            <v x="2" y="2" z="1" />
          </vertices>
          <triangles>
            <t ia="1" ib="2" ic="3" />
            <t ia="2" ib="1" ic="4" />
            <t ia="3" ib="2" ic="1" />
          </triangles>
        </trimesh>
      </geom>
    </space>
  </world>
</xode>
'''

def feq(n1, n2, error=0.1):
    """
    Compare two floating point numbers. If the differ by less than C{error},
    return True; otherwise, return False.
    """

    n = math.fabs(n1 - n2)
    if (n <= error):
        return True
    else:
        return False

class Class1:
    pass

class Class2:
    pass

class TestTreeNode(unittest.TestCase):

    def setUp(self):
        self.node1 = node.TreeNode('node1', None)
        self.node2 = node.TreeNode('node2', self.node1)
        self.node3 = node.TreeNode('node3', self.node2)
        self.node4 = node.TreeNode('node4', self.node3)

        self.t2 = transform.Transform()
        self.t2.scale(2.0, 3.0, 4.0)
        self.node2.setNodeTransform(self.t2)

        self.t3 = transform.Transform()
        self.t3.rotate(1.0, 2.0, 3.0)
        self.node3.setNodeTransform(self.t3)

        self.t4 = transform.Transform()
        self.t4.translate(2.0, 3.0, 1.0)
        self.node4.setNodeTransform(self.t4)

        self.node1.setODEObject(Class2())
        self.node2.setODEObject(Class2())
        self.node3.setODEObject(Class1())
    
    def testGetName(self):
        self.assertEqual(self.node1.getName(), 'node1')

    def testGetParent(self):
        self.assertEqual(self.node2.getParent(), self.node1)

    def testGetChildren(self):
        self.assertEqual(self.node1.getChildren(), [self.node2])
        self.assertEqual(self.node2.getChildren(), [self.node3])
        self.assertEqual(self.node3.getChildren(), [self.node4])
        self.assertEqual(self.node4.getChildren(), [])

    def testNamedChildLocal(self):
        self.assertEqual(self.node1.namedChild('node2'), self.node2)

    def testNamedChildRemote(self):
        self.assertEqual(self.node1.namedChild('node3'), self.node3)

    def testNamedChildNotFound(self):
        self.assertRaises(KeyError, self.node1.namedChild, 'undefined')

    def testGetFirstAncestor(self):
        self.assertEqual(self.node3.getFirstAncestor(Class2), self.node2)

    def testGetFirstAncestorNotFound(self):
        self.assertRaises(node.AncestorNotFoundError,
                          self.node3.getFirstAncestor, Class1)

    def testInitialTransform(self):
        t = transform.Transform()
        t.setIdentity()
        self.assertEqual(self.node1.getNodeTransform().m, t.m)

    def testGetTransform(self):
        ref = self.node1.getNodeTransform() * self.t2 * self.t3
        self.assertEqual(self.node3.getTransform().m, ref.m)

    def testGetTransformUntil(self):
        ref = self.t3 * self.t4
        self.assertEqual(self.node4.getTransform(self.node2).m, ref.m)

class TestParser(unittest.TestCase):
    def setUp(self):
        self.p = parser.Parser()
        self.root = self.p.parseString(test_doc)

class TestWorldParser(TestParser):
    def testInstance(self):
        world = self.root.namedChild('world1').getODEObject()
        self.assert_(isinstance(world, ode.World))

class TestSpaceParser(TestParser):
    def setUp(self):
        TestParser.setUp(self)
        self.simpleSpace = self.root.namedChild('space1').getODEObject()

        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><world>
          <space name="space1"/>
        </world></xode>
        '''

        self.p2 = parser.Parser()
        self.p2.setParams(spaceFactory=ode.HashSpace)
        self.root2 = self.p2.parseString(doc)
        self.hashSpace = self.root2.namedChild('space1').getODEObject()

        def makeSpace():
            return ode.QuadTreeSpace((0, 0, 0), (2, 2, 2), 3)

        self.p3 = parser.Parser()
        self.p3.setParams(spaceFactory=makeSpace)
        self.root3 = self.p3.parseString(doc)
        self.quadSpace = self.root3.namedChild('space1').getODEObject()
        
    def testSimpleInstance(self):
        self.assert_(isinstance(self.simpleSpace, ode.SimpleSpace))

    def testHashInstance(self):
        self.assert_(isinstance(self.hashSpace, ode.HashSpace))

    def testQuadInstance(self):
        self.assert_(isinstance(self.quadSpace, ode.QuadTreeSpace))

    def testSpaceBase(self):
        self.assert_(isinstance(self.simpleSpace, ode.SpaceBase))
        self.assert_(isinstance(self.hashSpace, ode.SpaceBase))
        self.assert_(isinstance(self.quadSpace, ode.SpaceBase))

class TestBodyParser(TestParser):
    def setUp(self):
        TestParser.setUp(self)
        self.body1 = self.root.namedChild('body1').getODEObject()
        self.body3 = self.root.namedChild('body3').getODEObject()
        self.body6 = self.root.namedChild('body6').getODEObject()
        
    def testInstance(self):
        self.assert_(isinstance(self.body1, ode.Body))

    def testRotation(self):
        ref = transform.Transform()
        ref.rotate(0.0, 0.0, 0.78)

        rot = self.body6.getRotation()
        for n1, n2 in zip(ref.getRotation(), rot):
            self.assert_(feq(n1, n2))

    def testPosition(self):
        self.assertEqual(self.body3.getPosition(), (10.0, 20.0, 30.0))

    def testEnable(self):
        self.assertEqual(self.body1.isEnabled(), 0)

    def testGravityMode(self):
        self.assertEqual(self.body1.getGravityMode(), 0)

    def testTorque(self):
        self.assertEqual(self.body1.getTorque(), (1.0, 2.0, 3.0))

    def testForce(self):
        self.assertEqual(self.body1.getForce(), (2.0, 3.0, 4.0))

    def testFiniteRotation(self):
        self.assertEqual(self.body1.getFiniteRotationMode(), 1)
        x, y, z = self.body1.getFiniteRotationAxis()
        self.assertEqual(x, y, z)

    def testLinearVel(self):
        self.assertEqual(self.body1.getLinearVel(), (1.0, 2.0, 3.0))

    def testAngularVel(self):
        self.assertEqual(self.body1.getAngularVel(), (3.0, 2.0, 1.0))

class TestMassParser(TestParser):    
    def setUp(self):
        TestParser.setUp(self)
        self.mass1 = self.root.namedChild('mass1').getODEObject()
        self.mass2 = self.root.namedChild('mass2').getODEObject()

        self.ref2 = ode.Mass()
        self.ref2.setSphere(2.0, 10.0)
        self.ref2.adjust(4.0)

    def testInstance(self):
        self.assert_(isinstance(self.mass1, ode.Mass))

    def testTotal(self):
        self.assertEqual(self.mass2.mass, 4.0)

    def testSphere(self):
        self.assertEqual(self.ref2.c, self.mass2.c)
        self.assertEqual(self.ref2.I, self.mass2.I)

    def testAdd(self):
        ref = ode.Mass()
        ref.setSphere(1.0, 1.0)
        ref.add(self.ref2)

        self.assertEqual(ref.c, self.mass1.c)
        self.assertEqual(ref.I, self.mass1.I)

class TestJointParser(TestParser):
    def setUp(self):
        TestParser.setUp(self)
        self.body1 = self.root.namedChild('body1').getODEObject()
        self.body2 = self.root.namedChild('body2').getODEObject()
        self.joint1 = self.root.namedChild('joint1').getODEObject()
        self.joint2 = self.root.namedChild('joint2').getODEObject()
        self.joint3 = self.root.namedChild('joint3').getODEObject()

    def testInstance(self):
        self.assert_(isinstance(self.joint1, ode.BallJoint))

    def testBodyAncestor(self):
        self.assertEqual(self.joint1.getBody(0), self.body1)

    def testEnvironment(self):
        self.assertEqual(self.joint1.getBody(1), ode.environment)

    def testBodyReference(self):
        self.assertEqual(self.joint2.getBody(0), self.body1)

    def testSpaceParent(self):
        self.assertEqual(self.joint3.getBody(0), self.body1)
        self.assertEqual(self.joint3.getBody(1), self.body2)

    def testBallAnchor(self):
        for n1, n2 in zip(self.joint1.getAnchor(), (1.0, 2.0, 3.0)):
            self.assert_(feq(n1, n2))

class TestGeomParser(TestParser):
    def setUp(self):
        TestParser.setUp(self)
        
        self.geom1 = self.root.namedChild('geom1').getODEObject()
        self.geom2 = self.root.namedChild('geom2').getODEObject()
        self.geom3 = self.root.namedChild('geom3').getODEObject()
        self.geom4 = self.root.namedChild('geom4').getODEObject()
        self.geom5 = self.root.namedChild('geom5').getODEObject()
        self.geom6 = self.root.namedChild('geom6').getODEObject()
        
        self.body1 = self.root.namedChild('body1').getODEObject()
        self.space1 = self.root.namedChild('space1').getODEObject()

    def testSpaceAncestor(self):
        self.assertEqual(self.geom1.getSpace(), self.space1)

    def testBodyAttach(self):
        self.assertEqual(self.geom1.getBody(), self.body1)

    def testBoxInstance(self):
        self.assert_(isinstance(self.geom1, ode.GeomBox))

    def testBoxSize(self):
        self.assertEqual(self.geom1.getLengths(), (10.0, 20.0, 30.0))

    def testCCylinderInstance(self):
        self.assert_(isinstance(self.geom2, ode.GeomCCylinder))

    def testCCylinderParams(self):
        self.assertEqual(self.geom2.getParams(), (15.0, 3.0))

    def testSphereInstance(self):
        self.assert_(isinstance(self.geom5, ode.GeomSphere))

    def testSphereRadius(self):
        self.assertEqual(self.geom5.getRadius(), 23.0)

    def testPlaneInstance(self):
        self.assert_(isinstance(self.geom4, ode.GeomPlane))

    def testPlaneParams(self):
        self.assertEqual(self.geom4.getParams(), ((0.0, 1.0, 0.0), 17.0))

    def testRayInstance(self):
        self.assert_(isinstance(self.geom3, ode.GeomRay))

    def testRayLength(self):
        self.assertEqual(self.geom3.getLength(), 11.0)

    def testIndependantRotation(self):
        ref = transform.Transform()
        ref.rotate(0.0, 0.0, 0.78)

        for n1, n2 in zip(self.geom5.getRotation(), ref.getRotation()):
            self.assert_(feq(n1, n2))

    def testIndependantPosition(self):
        self.assertEqual(self.geom5.getPosition(), (1.0, 2.0, 3.0))

    def testTransformInstance(self):
        self.assert_(isinstance(self.geom6, ode.GeomTransform))

    def testTransformGeomInstance(self):
        self.assert_(isinstance(self.geom6.getGeom(), ode.GeomSphere))

    def testTransformPosition(self):
        pos = self.geom6.getGeom().getPosition()
        self.assertEqual(pos, (1.0, 2.0, 3.0))

    def testTransformRotation(self):
        ref = transform.Transform()
        ref.rotate(0.78, 0.0, 0.0)
        rot = self.geom6.getGeom().getRotation()

        for n1, n2 in zip(rot, ref.getRotation()):
            self.assert_(feq(n1, n2))

class TestTransformParser(TestParser):
    def setUp(self):
        TestParser.setUp(self)
        self.world1 = self.root.namedChild('world1')
        self.body1 = self.root.namedChild('body1')
        self.body5 = self.root.namedChild('body5')
        self.body7 = self.root.namedChild('body7')

    def testMatrixStyle(self):
        t = self.world1.getNodeTransform()
        self.assertEqual(t.m, [[1.0, 2.0, 3.0, 4.0],
                               [1.2, 2.2, 3.2, 4.2],
                               [1.4, 2.4, 3.4, 4.4],
                               [1.8, 2.8, 3.8, 4.8]])

    def testVector(self):
        ref = transform.Transform()
        ref.rotate(45.0, 45.0, 45.0)
        ref.translate(10.0, 11.0, 12.0)
        ref.scale(2.0, 2.0, 2.0)
        self.assertEqual(self.body1.getNodeTransform().m, ref.m)

    def testAbsolute(self):
        t = self.body7.getTransform()
        self.assertEqual(t.m, [[1.0, 2.0, 3.0, 4.0],
                               [1.2, 2.2, 3.2, 4.2],
                               [1.4, 2.4, 3.4, 4.4],
                               [1.8, 2.8, 3.8, 4.8]])

    def testRelative(self):
        t1 = transform.Transform()
        t1.translate(1.0, 1.0, 1.0)
        t2 = transform.Transform()
        t2.translate(2.0, 2.0, 2.0)

        t3 = t1 * t2

        self.assertEqual(self.body5.getTransform().m, t3.m)
        
    def testMultiply(self):
        t1 = transform.Transform()
        t2 = transform.Transform()
        for r in range(4):
            for c in range(4):
                t1.m[r][c] = 1
                t2.m[r][c] = 2

        result = t1 * t2
        for r in range(4):
            for c in range(4):
                self.assertEqual(result.m[r][c], 8)

    def testInitialIdentity(self):
        t = transform.Transform()
        for r in range(4):
            for c in range(4):
                if (r == c):
                    self.assertEqual(t.m[r][c], 1)
                else:
                    self.assertEqual(t.m[r][c], 0)

class TestTriMeshParser(unittest.TestCase):
    def setUp(self):
        self.p = parser.Parser()
        self.root = self.p.parseString(trimesh_doc)
        self.trimesh1 = self.root.namedChild('trimesh1').getODEObject()

    def testInstance(self):
        self.assert_(isinstance(self.trimesh1, ode.GeomTriMesh))

    def testTriangles(self):
        triangles = [(1, 2, 3),
                     (2, 1, 4),
                     (3, 2, 1)]

        vertices = [(0.0, 1.0, 1.0),
                    (1.0, 2.0, 2.0),
                    (2.0, 0.0, 1.0),
                    (0.0, 1.0, 2.0),
                    (2.0, 2.0, 1.0)]

        for i in range(len(triangles)):
            tri = self.trimesh1.getTriangle(i)
            
            ref = []
            for v in triangles[i]:
                ref.append(vertices[v-1])
                
            self.assertEqual(tri, tuple(ref))

class TestInvalid(unittest.TestCase):
    def setUp(self):
        self.p = parser.Parser()

class TestInvalidTags(TestInvalid):
    def testRoot(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <test></test>'''
        self.assertRaises(errors.InvalidError, self.p.parseString, doc)
        
    def testRootChild(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><test/></xode>'''
        self.assertRaises(errors.ChildError, self.p.parseString, doc)

    def testWorldChild(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><world>
          <test/>
        </world></xode>'''

        self.assertRaises(errors.ChildError, self.p.parseString, doc)

    def testSpaceChild(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><world><space>
          <test/>
        </space></world></xode>'''

        self.assertRaises(errors.ChildError, self.p.parseString, doc)

    def testMassChild(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><world><space>
          <body>
            <mass>
              <test/>
            </mass>
          </body>
        </space></world></xode>'''

        self.assertRaises(errors.ChildError, self.p.parseString, doc)

    def testJointChild(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><world><space><joint><test/></joint></space></world></xode>'''
        self.assertRaises(errors.ChildError, self.p.parseString, doc)

    def testGeomChild(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><world><space><geom><test/></geom></space></world></xode>'''
        self.assertRaises(errors.ChildError, self.p.parseString, doc)

    def testTriMeshChild(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><world><space><geom><trimesh><test/>
        </trimesh></geom></space></world></xode>
        '''
        self.assertRaises(errors.ChildError, self.p.parseString, doc)

class TestInvalidBody(TestInvalid):
    def testBadVector(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><world>
          <body>
            <torque x="1"/>
          </body>
        </world></xode>'''
        
        self.assertRaises(errors.InvalidError, self.p.parseString, doc)

    def testBodyEnable(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><world>
          <body enabled="unsure">
          </body>
        </world></xode>'''
        
        self.assertRaises(errors.InvalidError, self.p.parseString, doc)

    def testFiniteRotationMode(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><world>
          <body>
            <finiteRotation mode="99" xaxis="0" yaxis="0" zaxis="0"/>
          </body>
        </world></xode>'''
        
        self.assertRaises(errors.InvalidError, self.p.parseString, doc)

    def testFiniteRotationAxes(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><world>
          <body>
            <finiteRotation mode="0" xaxis="0" yaxis="0"/>
          </body>
        </world></xode>'''
        
        self.assertRaises(errors.InvalidError, self.p.parseString, doc)

class TestInvalidJoint(TestInvalid):
    def testEqualLinks(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><world><space>
          <joint>
            <ball/>
          </joint>
        </space></world></xode>'''
        
        # both links are ode.environment
        self.assertRaises(errors.InvalidError, self.p.parseString, doc)

    def testNoType(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><world><space>
          <joint/>
        </space></world></xode>'''

        self.assertRaises(errors.InvalidError, self.p.parseString, doc)

    def testWrongType(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><world><space name="space1">
          <body name="body1"/>
          <joint>
            <link1 body="body1"/>
            <link2 body="space1"/>
            <ball/>
          </joint>
        </space></world></xode>'''

        self.assertRaises(errors.InvalidError, self.p.parseString, doc)

    def testMisplacedReference(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><world><space name="space1">
          <body name="body1"/>
          <joint>
            <link1 body="body1"/>
            <link2 body="body2"/>
            <ball/>
          </joint>
          <body name="body2"/>
        </space></world></xode>'''
        # bodies must be defined before the joint

        self.assertRaises(errors.InvalidError, self.p.parseString, doc)

class TestInvalidGeom(TestInvalid):
    def testNoType(self):
        doc = '''<?xml version="1.0" encoding="iso-8859-1"?>
        <xode><world><space>
          <geom/>
        </space></world></xode>'''

        self.assertRaises(errors.InvalidError, self.p.parseString, doc)
        
if (__name__ == '__main__'):
    unittest.main()
