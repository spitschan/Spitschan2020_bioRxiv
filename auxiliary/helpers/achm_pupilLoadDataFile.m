function [theData theConfidence theT theDataIdx] = achm_pupilLoadDataFile(dataPath)
Mtmp = readtable(dataPath);
theData = Mtmp.diameter;
theConfidence = Mtmp.confidence;
theDataIdx = Mtmp.world_index;
theT = Mtmp.pupil_timestamp;