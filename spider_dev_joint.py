import Part
from FreeCAD import Base


def makeJoint(radius = 1.0, height = 1.25, width = 1.75, thickness = 0.1):


    # vertices on outer edge 
    V1 = Base.Vector(-radius, -height, -width/2)  # lower left
    V2 = Base.Vector(-radius,  0, -width/2)
    V3 = Base.Vector(0,   radius, -width/2)  # top 
    V4 = Base.Vector(radius,   0, -width/2)
    V5 = Base.Vector(radius,  -height, -width/2)  # lower right

    # vertices on inner edge 
    # keep numbering in same direction around loop
    V6 = Base.Vector(radius-thickness,  -height, -width/2)  # lower left
    V7 = Base.Vector(radius-thickness,   0, -width/2)
    V8 = Base.Vector(0,   radius-thickness, -width/2)  # top 
    V9 = Base.Vector(-radius+thickness,  0, -width/2)
    VA = Base.Vector(-radius+thickness, -height, -width/2)  # lower right

    # create edge segments
    L1 = Part.LineSegment(V1, V2)
    C1 = Part.Arc(V2, V3, V4)
    L2 = Part.LineSegment(V4, V5)
    L3 = Part.LineSegment(V5, V6)
    L4 = Part.LineSegment(V6, V7)
    C2 = Part.Arc(V7, V8, V9)
    L5 = Part.LineSegment(V9, VA)
    L6 = Part.LineSegment(VA, V1)

    thickness = Part.Shape([L1, C1, L2, L3, L4, C2, L5, L6])
    W = Part.Wire(thickness.Edges)

    F = Part.Face(W)
    P = F.extrude(Base.Vector(0, 0, width))
    
    return P
   
aJoint = makeJoint()
Part.show(aJoint)

