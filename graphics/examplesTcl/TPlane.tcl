catch {load vtktcl}
if { [catch {set VTK_TCL $env(VTK_TCL)}] != 0} { set VTK_TCL "../../examplesTcl" }
if { [catch {set VTK_DATA $env(VTK_DATA)}] != 0} { set VTK_DATA "../../../vtkdata" }


# get the interactor ui
source $VTK_TCL/vtkInt.tcl

# Create the RenderWindow, Renderer and both Actors
vtkRenderer ren1
vtkRenderWindow renWin
    renWin AddRenderer ren1
vtkRenderWindowInteractor iren
    iren SetRenderWindow renWin

# create a plane source and actor
vtkPlaneSource plane
vtkPolyDataMapper  planeMapper
planeMapper SetInput [plane GetOutput]
vtkActor planeActor
planeActor SetMapper planeMapper


# load in the texture map
#
vtkTexture atext
vtkPNMReader pnmReader
pnmReader SetFileName "$VTK_DATA/masonry.ppm"
atext SetInput [pnmReader GetOutput]
atext InterpolateOn
planeActor SetTexture atext

vtkImageViewer view
view SetInput [pnmReader GetOutput]
view SetColorWindow 255
view SetColorLevel 127.5

view Render

# Add the actors to the renderer, set the background and size
ren1 AddActor planeActor
ren1 SetBackground 0.1 0.2 0.4
renWin SetSize 500 500

# render the image
iren Initialize
iren SetUserMethod {wm deiconify .vtkInteract}

renWin Render

set cam1 [ren1 GetActiveCamera]
$cam1 Elevation -30
$cam1 Roll -20
renWin Render

#renWin SetFileName "TPlane.tcl.ppm"
#renWin SaveImageAsPPM

# prevent the tk window from showing up then start the event loop
wm withdraw .





