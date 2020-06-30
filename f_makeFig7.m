function f_makeFig7

%% Analysis of DLMO data
M = csvread('aDLMO_data.csv', 1, 1);
subjIDs = M(:, 1);
uniqueSubjIDs = unique(subjIDs);
relTimeHour = M(:, 3);
melConcentration = M(:, 4);

% Set up some plot parameters
NSubplotRows = 2;
NSubplotCols = 3;
yLims = [-1 41];
xLims = [-5.5 1.5];

% Definitions from hockey stick algorithm
whichIncluded = {2:12 ; ... % This comes from the hockey stick algorithm
    1:12 ; ...
    1:11 ; ...
    1:10 ; ...
    NaN};
inflectionPoint = [-2.51 ; ...
    -1.54 ; ...
    -0.71 ; ...
    -3.02 ; ...
    NaN]; % No dynamic part

% Define the subject, by maximum concentration
sortedSubs = [4 1 2 3 5];
subjID = {'s001', 's002', 's003', 's004', 's005', 's006'};

% Hockeystick model: These come from the hockey stick software
hockeyModel1 = {'Y=0.2000*t+1.8210' 'Y=0.2000*t+1.8680' 'Y=0.1302*t+1.0024' 'Y=-0.1022*t+0.6906' '' ''};
hockeyModel2 = {'Y=6.3166*t+17.1431' 'Y=5.2463*t+9.6393' 'Y=4.2141*t+3.9016' 'Y=2.4897*t.^2+20.5074*t+40.2525' '' ''};


% Iterate and plot
for ii = 1:length(sortedSubs)
    subplot(NSubplotRows, NSubplotCols, ii)
    idx = find(subjIDs == uniqueSubjIDs(sortedSubs(ii)));
    thisTimeHour = relTimeHour(idx);
    thisMelConcentration = melConcentration(idx);
    
    % Plot inflection point
    plot([inflectionPoint(sortedSubs(ii)) inflectionPoint(sortedSubs(ii))], [4 8], '-k'); hold on
    hold on
    % Plot hockey stick components
    if ~isempty(hockeyModel1{sortedSubs(ii)})
        t = (thisTimeHour(1)-1):0.01:(thisTimeHour(end)+1);
        Y0 = [];
        % Function
        eval(hockeyModel1{sortedSubs(ii)});
        Y0(t < inflectionPoint(sortedSubs(ii))) = Y(t < inflectionPoint(sortedSubs(ii)));
        
        eval(hockeyModel2{sortedSubs(ii)})
        Y0(t >= inflectionPoint(sortedSubs(ii))) = Y(t >= inflectionPoint(sortedSubs(ii)));
        
        eval(hockeyModel1{sortedSubs(ii)})
        plot(t, Y, ':', 'Color', [251,128,114]/255);
        eval(hockeyModel2{sortedSubs(ii)})
        plot(t, Y, ':', 'Color', [251,128,114]/255);
        plot(t, Y0, 'LineWidth', 2, 'Color', [251,128,114]/255);
    end
    
    % Plot profile
    plot(thisTimeHour, thisMelConcentration, '-ok', 'MarkerFaceColor', 'w');
    
    
    
    xlim(xLims);
    ylim(yLims);
    pbaspect([1 0.8 1]);
    set(gca, 'TickDir', 'out', 'TickLength', [0.03, 0.03]);
    title(subjID{ii});
    
    if isnan(inflectionPoint(sortedSubs(ii)))
        text(-5.3, 37, 'No clear dynamic part');
    else
        text(-5.3, 37, ['hDLMO = ' num2str(inflectionPoint(sortedSubs(ii)))]);
    end
    set(gca, 'color', [247 247 247]/255);
    
    % Set up plot parameters
    switch ii
        case {4 5 6}
            xlabel({'Time to habitual bedtime'  '[h]'});
            set(gca, 'XTick', -6:1)%, 'XTickLabel', {'00:00' '' '12:00' '' '24:00'});
        otherwise
            set(gca, 'XTick', -6:1, 'XTickLabel', []);
    end
    switch ii
        case {1 4}
            ylabel({'Salivary melatonin' '[pg/mL]'});
            set(gca, 'YTick', 0:10:40);
        otherwise
            set(gca, 'YTick', 0:10:40, 'YTickLabel', []);
    end
end

%% Add A01 data in the final panel
M = csvread('aDLMO_dataA01.csv', 1, 1);
sessionIDs = M(:, 1);
uniqueSessionIDs = unique(sessionIDs);
relTimeHour = M(:, 2);
melConcentration = M(:, 3);
melConcentration(melConcentration == 0) = NaN;

theRGB = [179 226 205 ; ...
    253 205 172 ; ...
    203 213 232 ; ...
    244 202 228 ; ...
    230 245 201 ; ...
    255 242 174]/255;

subplot(NSubplotRows, NSubplotCols, 6)
idx = find(sessionIDs == 4); % Corresponds to mask
thisTimeHour = relTimeHour(idx);
thisMelConcentration = melConcentration(idx);
maskIdx = ~(isoutlier(thisMelConcentration,'grubbs')); % Remove outliers (2 out of 55)
h(ii) = plot(relTimeHour(idx(maskIdx)), melConcentration(idx(maskIdx)), '-ok', 'MarkerFaceColor', 'w'); hold on;

xlim(xLims);
ylim(yLims);
pbaspect([1 0.8 1]);
set(gca, 'TickDir', 'out', 'TickLength', [0.03, 0.03]);
title('s006');
set(gca, 'color', [247 247 247]/255);
xlabel({'Time to habitual bedtime'  '[h]'});
set(gca, 'XTick', -6:1)
set(gca, 'YTick', 0:10:40, 'YTickLabel', []);
text(-5.3, 37, 'No clear dynamic part');

%% Save the figure
set(gcf, 'PaperPosition', [0 0 20 15]);
set(gcf, 'PaperSize', [20 15]);
set(gcf, 'Color', 'w');
set(gcf, 'InvertHardcopy', 'off');
saveas(gcf, 'figures/raw/Fig7.pdf', 'pdf');
close(gcf);