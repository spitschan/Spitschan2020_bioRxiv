function dataTraceFiltered = achm_filterData(dataTraceInterpolated)
dataTraceFiltered = sgolayfilt(dataTraceInterpolated, 11, 21);