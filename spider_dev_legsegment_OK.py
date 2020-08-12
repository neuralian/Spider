import Part
from FreeCAD import Base


# tapered tube with elliptical cross section
# major axis in x-direction (because Part.Ellipse works that way)
def makeSpiderLegSegment (baseDiamX = 1.0, baseDiamY = 0.8, 
                          tipDiamX = 0.8, tipDiamY = 0.6,
                          segLength = 5.0, skinThick = 0.25):
            
    # outer shell tapered ellipsoid loft            
    ellipse1 = Part.Ellipse(Base.Vector(0,0,0), baseDiamX, baseDiamY)
    base1=Part.Wire(Part.Edge(ellipse1))

    ellipse2 = Part.Ellipse(Base.Vector(0,0,0), tipDiamX, tipDiamY)
    ellipse2.translate(Base.Vector(0,0,segLength))
    tip1 = Part.Wire(Part.Edge(ellipse2))

    shell = Part.makeLoft([base1, tip1], True)

    # hollow core tapered loft
    ellipse3 = Part.Ellipse(Base.Vector(0,0,0), 
           baseDiamX-skinThick, baseDiamY-skinThick)
    base2=Part.Wire(Part.Edge(ellipse3))


    ellipse4 = Part.Ellipse(Base.Vector(0,0,0), 
                  tipDiamX-skinThick, tipDiamY-skinThick)
    ellipse4.translate(Base.Vector(0,0,segLength))
    tip2 = Part.Wire(Part.Edge(ellipse4))

    core = Part.makeLoft([base2, tip2], True)

    # 'show' creates GUI objects from the App objects
    # necessary for applying Boolean operations
    Part.show(shell)
    Part.show(core)

    # Boolean cut core from shell
    App.ActiveDocument.addObject("Part::Cut", "Segment")
    App.ActiveDocument.Segment.Base = App.ActiveDocument.Shape
    App.ActiveDocument.Segment.Tool = App.ActiveDocument.Shape001


makeSpiderLegSegment()

