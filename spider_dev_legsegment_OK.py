import Part
from FreeCAD import Base


# tapered tube with elliptical cross section
# major axis in x-direction (because Part.Ellipse works that way)
def makeSpiderLegSegment (baseDiamX = 1.0, baseDiamY = 0.8, 
                          tipDiamX = 0.8, tipDiamY = 0.6,
                          segLength = 5.0, skinThick = 0.25,
                          name = "segment"):
            
    # outer shell is a tapered ellipsoid loft            
    ellipse1 = Part.Ellipse(Base.Vector(0,0,0), baseDiamX, baseDiamY)
    base1=Part.Wire(Part.Edge(ellipse1))

    ellipse2 = Part.Ellipse(Base.Vector(0,0,0), tipDiamX, tipDiamY)
    ellipse2.translate(Base.Vector(0,0,segLength))
    tip1 = Part.Wire(Part.Edge(ellipse2))

    shell = App.ActiveDocument.addObject("Part::Feature", "shell")
    shell.Shape = Part.makeLoft([base1, tip1], True)

    # hollow core is a tapered ellipsoid loft
    ellipse3 = Part.Ellipse(Base.Vector(0,0,0), 
           baseDiamX-skinThick, baseDiamY-skinThick)
    base2=Part.Wire(Part.Edge(ellipse3))

    ellipse4 = Part.Ellipse(Base.Vector(0,0,0), 
                  tipDiamX-skinThick, tipDiamY-skinThick)
    ellipse4.translate(Base.Vector(0,0,segLength))
    tip2 = Part.Wire(Part.Edge(ellipse4))

    core = App.ActiveDocument.addObject("Part::Feature", "core")
    core.Shape = Part.makeLoft([base2, tip2], True)

    # Make tube by cutting core from shell
    legSegment = App.ActiveDocument.addObject("Part::Cut", name)
    App.ActiveDocument.ActiveObject.Base = shell 
    App.ActiveDocument.ActiveObject.Tool = core 
    
    return legSegment


fred = makeSpiderLegSegment(name="fred")

fred.Placement = App.Placement(App.Vector(0,0,0), App.Rotation(App.Vector(0,0,1), 90))


