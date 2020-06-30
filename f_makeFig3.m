function f_makeFig3()

basePaths = {'pupil_000' ...
    'pupil_001'}; % Contains exported data from Pupil Labs

% Calculate aspects of the spectra

%% Setup the Import Options
opts = delimitedTextImportOptions("NumVariables", 13);

% Specify range and delimiter
opts.DataLines = [450, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Var1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13"];
opts.SelectedVariableNames = ["VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13"];
opts.VariableTypes = ["string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "Var1", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Var1", "EmptyFieldRule", "auto");

% Import the data
spectra = readtable("spectra.csv", opts);

% Import the data
ACHMDoseResponseCurveMeasurements = readtable("spectra.csv", opts);
spd = table2array(ACHMDoseResponseCurveMeasurements);

% Get CIE S026
T = GetCIES026;
T(isnan(T)) = 0;

primary2Rods = [0 0 T(4, :)*spd(:, 1:6)]
primary2Mel = [0 0 T(5, :)*spd(:, 1:6)]

primary8Rods = [0 0 T(4, :)*spd(:, 7:end)]
primary8Mel = [0 0 T(5, :)*spd(:, 7:end)]

% Obtain the data
for b = 1:length(basePaths)
    switch b
        case 1
            primaryRod = primary2Rods;
            primaryMel = primary2Mel;
            theColor = [44,127,184]/255;
            whichPlot = 2;
        case 2
            primaryRod = primary8Rods;
            primaryMel = primary8Mel;
            theColor = [253,174,107]/255;
            whichPlot = 3;
    end
    [dataTraceRaw, confidenceRaw, timeTraceRawExpt, dataTraceIdx] = achm_pupilLoadDataFile(fullfile(basePaths{b}, 'pupil_positions.csv'));
    annotIdx = achm_pupilLoadAnnotationFile(fullfile(basePaths{b}, 'annotations.csv'));
    
    dataTraceRaw(confidenceRaw < 0.8) = NaN;
    dataTraceRaw(dataTraceRaw > 100) = NaN;
    dataTraceRaw(dataTraceRaw < 25) = NaN;
    
    % Start time
    theOffsets = [-7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7];
    allIndices = [];
    for ii = 1:15
        targetTime = timeTraceRawExpt(annotIdx(1))+theOffsets(ii)*30.5;
        [~, idx] = min(abs(timeTraceRawExpt-targetTime))
        allIndices(ii) = idx;
    end
    
    startIdx = allIndices;
    endIdx = [allIndices(2:end)-1 length(dataTraceRaw)];
    
    %  tNew = (timeTraceRawExpt/60)-(timeTraceRawExpt(startIdx(1))/60);
    % baselineDiameter = nanmedian(dataTraceRaw(1:startIdx));
    
    %
    baselineDiameter = nanmedian(dataTraceRaw(1:startIdx));
    for ii = 1:15
        theMedian(ii) = nanmedian(dataTraceRaw(startIdx(ii):endIdx(ii)))
        %plot(ii, nanmedian(theData(startIdx(ii):endIdx(ii))), 'ok'); hold on
        %plot(0, nanmedian(theData(1:startIdx(1))), 'sk');
    end
    theIndices = [1:8 7:-1:1];
    subplot(2, 3, whichPlot);
    plot(log10(1000*primaryRod(theIndices(1:8))), 100*(theMedian(1:8)-baselineDiameter)/baselineDiameter, ':ok', 'MarkerFaceColor', theColor); hold on
    plot(log10(1000*primaryRod(theIndices(9:end))), 100*(theMedian(9:end)-baselineDiameter)/baselineDiameter, ':sk', 'MarkerFaceColor', theColor); hold on
    xlim([-1.5 2.5]);
    ylim([-50 10]);
    plot([-1.5 2.5], [0 0], ':k');
    
    if b == 1
        ylabel('% of initial pupil size');
    end
    xlabel('Scotopic irradiance [mW/m2/sr]');
    set(gca, 'XTick', -1.5:0.5:2.5, 'XTickLabel', {'' -1 '' 0 '' 1 '' 2 ''})
    pbaspect([1 0.8 1]);
    set(gca, 'color', [247 247 247]/255);
    set(gca, 'TickDir', 'out', 'TickLength', [0.03, 0.03]);
    title('Pupil size');
end

%%
subplot(2, 3, 1);
wls = (380:1:780)';
plot(wls, spd(:, 6), 'Color', [44,127,184]/255, 'LineWidth', 2); hold on
plot(wls, spd(:, end), 'Color', [253,174,107]/255, 'LineWidth', 2);
pbaspect([1 0.8 1]);
xlabel('Wavelength [nm]');
ylabel({'Spectral irradiance' '[W/m2/nm]'});
xlim([380 780]);
ylim([0 0.021]);
set(gca, 'color', [247 247 247]/255);
title('Spectral stimuli');
set(gca, 'color', [247 247 247]/255);
set(gca, 'TickDir', 'out', 'TickLength', [0.03, 0.03]);


% Now add the ratings
rating1 = [1 1 2 4 5 6 8 8 6 4 1 1 1 1 1];
rating2 = [1 1 3 4 6 6 8 10 9 7 6 4 3 1 1];

subplot(2, 3, 5);
primaryRod = primary2Rods;
primaryMel = primary2Mel;
theColor = [44,127,184]/255;
plot(log10(1000*primaryRod(theIndices(1:8))), rating1(1:8), ':ok', 'MarkerFaceColor', theColor); hold on
plot(log10(1000*primaryRod(theIndices(9:end))), rating1(9:end), ':sk', 'MarkerFaceColor', theColor); hold on

xlim([-1.5 2.5]); ylim([-0.1 10.6]);
xlabel('Scotopic irradiance [mW/m2/sr]');
set(gca, 'XTick', -1.5:0.5:2.5, 'XTickLabel', {'' -1 '' 0 '' 1 '' 2 ''})
pbaspect([1 0.8 1]);
set(gca, 'color', [247 247 247]/255);
set(gca, 'TickDir', 'out', 'TickLength', [0.03, 0.03]);
title('Discomfort rating');
set(gca, 'YTick', 0:10, 'YTickLabel', {0 '' 2 '' 4 '' 6 '' 8 '' 10});

subplot(2, 3, 6);
primaryRod = primary8Rods;
primaryMel = primary8Mel;
theColor = [253,174,107]/255;
plot(log10(1000*primaryRod(theIndices(1:8))), rating2(1:8), ':ok', 'MarkerFaceColor', theColor); hold on
plot(log10(1000*primaryRod(theIndices(9:end))), rating2(9:end), ':sk', 'MarkerFaceColor', theColor); hold on

xlim([-1.5 2.5]); ylim([-0.1 10.6]);
xlabel('Scotopic irradiance [mW/m2/sr]');
set(gca, 'XTick', -1.5:0.5:2.5, 'XTickLabel', {'' -1 '' 0 '' 1 '' 2 ''})
pbaspect([1 0.8 1]);
set(gca, 'color', [247 247 247]/255);
set(gca, 'TickDir', 'out', 'TickLength', [0.03, 0.03]);
title('Discomfort rating');
set(gca, 'YTick', 0:10, 'YTickLabel', {0 '' 2 '' 4 '' 6 '' 8 '' 10});

set(gcf, 'PaperPosition', [0 0 20 15]);
set(gcf, 'PaperSize', [20 15]);
set(gcf, 'Color', 'w');
set(gcf, 'InvertHardcopy', 'off');
saveas(gcf, 'figures/raw/Fig3.pdf', 'pdf');
close(gcf);