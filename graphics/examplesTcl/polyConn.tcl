catch {load vtktcl}
if { [catch {set VTK_TCL $env(VTK_TCL)}] != 0} { set VTK_TCL "../../examplesTcl" }
if { [catch {set VTK_DATA $env(VTK_DATA)}] != 0} { set VTK_DATA "../../../vtkdata" }

# get the interactor ui
source $VTK_TCL/vtkInt.tcl
source $VTK_TCL/colors.tcl

# Create the RenderWindow, Renderer and both Actors
#
vtkRenderer ren1
vtkRenderWindow renWin
    renWin AddRenderer ren1
vtkRenderWindowInteractor iren
    iren SetRenderWindow renWin

# read data
#
vtkPLOT3DReader pl3d
    pl3d SetXYZFileName "$VTK_DATA/bluntfinxyz.bin"
    pl3d SetQFileName "$VTK_DATA/bluntfinq.bin"
    pl3d SetScalarFunctionNumber 100
    pl3d SetVectorFunctionNumber 202
    pl3d Update

# wall
#
vtkStructuredGridGeometryFilter wall
    wall SetInput [pl3d GetOutput]
    wall SetExtent 0 100 0 0 0 100
vtkPolyDataMapper wallMap
    wallMap SetInput [wall GetOutput]
    wallMap ScalarVisibilityOff
vtkActor wallActor
    wallActor SetMapper wallMap
    eval [wallActor GetProperty] SetColor 0.8 0.8 0.8

# fin
# 
vtkStructuredGridGeometryFilter fin
    fin SetInput [pl3d GetOutput]
    fin SetExtent 0 100 0 100 0 0
vtkPolyDataMapper finMap
    finMap SetInput [fin GetOutput]
    finMap ScalarVisibilityOff
vtkActor finActor
    finActor SetMapper finMap
    eval [finActor GetProperty] SetColor 0.8 0.8 0.8

# planes to connect
vtkStructuredGridGeometryFilter plane1
    plane1 SetInput [pl3d GetOutput]
    plane1 SetExtent 10 10 0 100 0 100
vtkPolyDataConnectivityFilter conn
    conn SetInput [plane1 GetOutput]
    conn ScalarConnectivityOn
    conn SetScalarRange 1.5 4.0
vtkPolyDataMapper plane1Map
    plane1Map SetInput [conn GetOutput]
    eval plane1Map SetScalarRange [[pl3d GetOutput] GetScalarRange]
vtkActor plane1Actor
    plane1Actor SetMapper plane1Map
    [plane1Actor GetProperty] SetOpacity 0.999

# outline
vtkStructuredGridOutlineFilter outline
    outline SetInput [pl3d GetOutput]
vtkPolyDataMapper outlineMapper
    outlineMapper SetInput [outline GetOutput]
vtkActor outlineActor
    outlineActor SetMapper outlineMapper
    set outlineProp [outlineActor GetProperty]
    eval $outlineProp SetColor 0 0 0

# Add the actors to the renderer, set the background and size
#
ren1 AddActor outlineActor
ren1 AddActor wallActor
ren1 AddActor finActor
ren1 AddActor plane1Actor
ren1 SetBackground 1 1 1
renWin SetSize 400 400

vtkCamera cam1
  cam1 SetClippingRange 1.51176 75.5879
  cam1 SetFocalPoint 2.33749 2.96739 3.61023
  cam1 SetPosition 10.8787 5.27346 15.8687
  cam1 SetViewAngle 30
  cam1 SetViewPlaneNormal 0.564986 0.152542 0.810877
  cam1 SetViewUp -0.0610856 0.987798 -0.143262
ren1 SetActiveCamera cam1

iren Initialize

# render the image
#
iren SetUserMethod {wm deiconify .vtkInteract}

renWin SetFileName "polyConn.tcl.ppm"
#renWin SaveImageAsPPM

# prevent the tk window from showing up then start the event loop
wm withdraw .



