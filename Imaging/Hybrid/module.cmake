vtk_module(vtkImagingHybrid
  GROUPS
    Imaging
    StandAlone
  DEPENDS
    vtkFiltersGeneral#for vtkPartialVolumeModeller
    vtkFiltersGeometry#for vtkPartialVolumeModeller
    vtkImagingCore
    vtkIOImage
  TEST_DEPENDS
    vtkTestingCore
    vtkCommonCore
    vtkCommonDataModel
  )
