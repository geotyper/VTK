# Test the recomputation of normals within a subregion
catch {load vtktcl}
if { [catch {set VTK_TCL $env(VTK_TCL)}] != 0} { set VTK_TCL "../../examplesTcl" }
if { [catch {set VTK_DATA $env(VTK_DATA)}] != 0} { set VTK_DATA "../../../vtkdata" }

source $VTK_TCL/vtkInt.tcl

vtkSLCReader reader
    reader SetFileName "$VTK_DATA/bolt.slc"

vtkExtractVOI voi
    voi SetInput [reader GetOutput]
    voi SetVOI 20 45 20 45 0 30

vtkPiecewiseFunction opacityTransferFunction
    opacityTransferFunction AddPoint   80  0.0
    opacityTransferFunction AddPoint  100  1.0

vtkColorTransferFunction colorTransferFunction
    colorTransferFunction AddRGBPoint     0 1.0 1.0 1.0
    colorTransferFunction AddRGBPoint   255 1.0 1.0 1.0

vtkVolumeProperty volumeProperty
    volumeProperty SetColor colorTransferFunction
    volumeProperty SetScalarOpacity opacityTransferFunction
    volumeProperty ShadeOn
    volumeProperty SetInterpolationTypeToLinear

vtkFiniteDifferenceGradientEstimator gradest

vtkVolumeRayCastCompositeFunction  compositeFunction

vtkVolumeRayCastMapper volumeMapper
    volumeMapper SetInput [voi GetOutput]
    volumeMapper SetVolumeRayCastFunction compositeFunction
    volumeMapper SetSampleDistance 0.5
    volumeMapper SetGradientEstimator gradest

vtkVolume volume
    volume SetMapper volumeMapper
    volume SetProperty volumeProperty

vtkRenderer ren1
vtkRenderWindow renWin
    renWin AddRenderer ren1
    renWin SetSize 256 256
vtkRenderWindowInteractor iren
    iren SetRenderWindow renWin

ren1 AddVolume volume
ren1 SetBackground 0.1 0.2 0.4
renWin Render

[ren1 GetActiveCamera] Zoom 1.4

gradest SetSampleSpacingInVoxels 10
renWin Render

gradest CylinderClipOn
gradest SetSampleSpacingInVoxels 1
renWin Render

gradest BoundsClipOn
gradest SetSampleSpacingInVoxels 10 
gradest SetBounds 15 25 15 25 0 30
renWin Render

proc TkCheckAbort {} {
  set foo [renWin GetEventPending]
  if {$foo != 0} {renWin SetAbortRender 1}
}
renWin SetAbortCheckMethod {TkCheckAbort}

iren SetUserMethod {wm deiconify .vtkInteract}
iren Initialize


renWin SetFileName "valid/volCylinderClipNormals.ppm"
#renWin SaveImageAsPPM

wm withdraw .

