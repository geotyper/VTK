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
vtkPolyDataReader input
  input SetFileName "$VTK_DATA/brainImageSmooth.vtk"

#
# generate vectors
vtkCleanPolyData clean
  clean SetInput [input GetOutput]

vtkWindowedSincPolyDataFilter smooth
  smooth SetInput [clean GetOutput]
  smooth GenerateErrorVectorsOn
  smooth GenerateErrorScalarsOn
  smooth Update

vtkPolyDataMapper mapper
  mapper SetInput [smooth GetOutput]
  eval mapper SetScalarRange [[smooth GetOutput] GetScalarRange]

vtkActor brain
  brain SetMapper mapper


# Add the actors to the renderer, set the background and size
#
ren1 AddActor brain

renWin SetSize 320 240

set cam1 [ren1 GetActiveCamera]
$cam1 SetPosition 152.589  -135.901 173.068
$cam1 SetFocalPoint 146.003 22.3839 0.260541
$cam1 SetViewUp -0.255578 -0.717754 -0.647695
ren1 ResetCameraClippingRange

iren Initialize
renWin Render

# render the image
#
iren SetUserMethod {wm deiconify .vtkInteract}

# prevent the tk window from showing up then start the event loop
wm withdraw .

#renWin SetFileName writers.tcl.ppm
#renWin SaveImageAsPPM

#
# test the writers
vtkDataSetWriter dsw
  dsw SetInput [smooth GetOutput]
  dsw SetFileName brain.dsw
  dsw Write

vtkPolyDataWriter pdw
  pdw SetInput [smooth GetOutput]
  pdw SetFileName brain.pdw
  pdw Write

if { [info command vtkIVWriter] != "" } {
  vtkIVWriter iv
    iv SetInput [smooth GetOutput]
    iv SetFileName brain.iv
    iv Write
}

#
# the next writers only handle triangles
vtkTriangleFilter triangles
  triangles SetInput [smooth GetOutput]

if { [info command vtkIVWriter] != "" } {
  vtkIVWriter iv2
    iv2 SetInput [triangles GetOutput]
    iv2 SetFileName brain2.iv
    iv2 Write
}

if { [info command vtkIVWriter] != "" } {
  vtkExtractEdges edges
    edges SetInput [triangles GetOutput]
  vtkIVWriter iv3
    iv3 SetInput [edges GetOutput]
    iv3 SetFileName brain3.iv
    iv3 Write
}

vtkBYUWriter byu
  byu SetGeometryFileName brain.g
  byu SetScalarFileName brain.s
  byu SetDisplacementFileName brain.d
  byu SetInput [triangles GetOutput]
  byu Write

vtkMCubesWriter mcubes
  mcubes SetInput [triangles GetOutput]
  mcubes SetFileName brain.tri
  mcubes SetLimitsFileName brain.lim
  mcubes Write

vtkSTLWriter stl
  stl SetInput [triangles GetOutput]
  stl SetFileName brain.stl
  stl Write

vtkSTLWriter stlBinary
  stlBinary SetInput [triangles GetOutput]
  stlBinary SetFileName brainBinary.stl
  stlBinary SetFileType 2
  stlBinary Write



