import Part
from FreeCAD import Base





ellipse1 = Part.Ellipse(Base.Vector(0,0,0), 1.0, 0.8)
base1=Part.Wire(Part.Edge(ellipse1))


ellipse2 = Part.Ellipse(Base.Vector(0,0,0), 0.8, 0.6)
ellipse2.translate(Base.Vector(0,0,5))
tip1 = Part.Wire(Part.Edge(ellipse2))

side = Part.makeLoft([base1, tip1], True)

ellipse3 = Part.Ellipse(Base.Vector(0,0,0), .8, 0.6)
base2=Part.Wire(Part.Edge(ellipse3))


ellipse4 = Part.Ellipse(Base.Vector(0,0,0), 0.6, 0.4)
ellipse4.translate(Base.Vector(0,0,5))
tip2 = Part.Wire(Part.Edge(ellipse4))

core = Part.makeLoft([base2, tip2], True)

Part.show(side)
Part.show(core)

App.ActiveDocument.addObject("Part::Cut", "Segment")
App.ActiveDocument.Segment.Base = App.ActiveDocument.Shape
App.ActiveDocument.Segment.Tool = App.ActiveDocument.Shape001

Gui.activeDocument.Shape.Visibility=False
Gui.activeDocument.Shape001.Visibility=False


