function annotIdx = achm_pupilLoadAnnotationFile(annotPath)
Mtmp = readtable(annotPath);
annotIdx = Mtmp.index;