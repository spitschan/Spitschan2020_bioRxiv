clearvars;
%close all
theParticipants = {'A01.txt', ...
    'A02.txt', ...
    'A03.txt', ...
    'A06.txt', ...
    'A07.txt', ...
    'A10.txt'};
NRows = 2;
NColumns = 3;

sortedSubs = [5 2 3 4 6 1];
subjID = {'s001', 's002', 's003', 's004', 's005', 's006'};
theParticipants = {theParticipants{sortedSubs}};

for p = 1:length(theParticipants)
    subplot(NRows, NColumns, p);
    a = readtable(theParticipants{p});
    
    % Date time array without times
    d = dateshift(a.DATE_TIME, 'start', 'day');
    d.Format = 'dd-MMM-yyyy';
    NDays = days(d(end)-d(1));
    
    t = hour(datetime(a.DATE_TIME))/24 + minute(datetime(a.DATE_TIME))/(24*60) + second(datetime(a.DATE_TIME))/(24*60*60);
    activity = a.PIMn;
    %plot(t, activity)
    
    edges = [0:(0.5/24):1];
    edges0 = [-0.05:(0.5/24):1.05];
    x = t;
    y= activity;
    [~,~,loc]=histcounts(x,edges);
    meany = accumarray(loc(:),y(:))./accumarray(loc(:),1);
    xmid = 0.5*(edges(1:end-1)+edges(2:end));
    %plot(x,y)
    hold on;
    meany_zs = zscore(meany);
    plot(xmid,meany_zs, 'ok', 'MarkerFaceColor', 'w')
    xlim([-0.05 1.05]);
    ylim([-3.1 3.1]);
    set(gca, 'color', [247 247 247]/255);
    
    
    % Do a fit
    [xData, yData] = prepareCurveData( xmid, meany_zs );
    
    % Set up fittype and options.
    ft = fittype( 'a1*sin(2*pi*x+c1) + a2*sin(2*2*pi*x+c2)', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    %opts.StartPoint = [0.913375856139019 0.546881519204984 0.157613081677548 0.0975404049994095 0.957506835434298 0.964888535199277];
    
    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    
    % Plot fit with data
    edgesFit = [-0.05:0.01:1.05];
    yfit = feval(fitresult, edgesFit);
    h = plot(edgesFit, yfit, '-', 'Color', [231,41,138]/255, 'LineWidth', 2);
    set(gca,'children',flipud(get(gca,'children')))
    
    
    switch p
        case {4 5 6}
            xlabel('Local time of day [h]');
            set(gca, 'XTick', [0:6:24]/24, 'XTickLabel', {'00:00' '' '12:00' '' '24:00'});
        otherwise
            set(gca, 'XTick', [0:6:24]/24, 'XTickLabel', []);
    end
    switch p
        case {1 4}
            ylabel('z-scored activity');
            set(gca, 'YTick', [-4:4], 'YTickLabel', [-4:4]);
        otherwise
            set(gca, 'YTick', [-4:4], 'YTickLabel', []);
    end
    
    % Add R2
    text(23.5/24, -4.5, ['R2 = ' num2str(gof.adjrsquare, '%.2f')], 'HorizontalAlignment', 'right');
    set(gca, 'color', [247 247 247]/255);
    
    pbaspect([1 1.1 1]);
    set(gca, 'TickDir', 'out', 'TickLength', [0.03, 0.03]);
    box on;
    title(subjID{p});
    
    % Load sleep diary
    [~, dataID] = fileparts(theParticipants{p});
    A = readtable([dataID '.xlsx'])
    bedTimes = A.WannSindSieZuBettGegangen_;
    wakeupTimes = A.WannSindSieEndg_ltigAufgewacht_;
    weekendLogical = logical(A.Wochenende_);
    
    bedTimeWeekend = (circ_mean(bedTimes(weekendLogical & ~isnan(bedTimes))*2*pi)/(2*pi));
    bedTimeWeekday = (circ_mean(bedTimes(~weekendLogical & ~isnan(bedTimes))*2*pi)/(2*pi));
    wakeTimeWeekend = (circ_mean(wakeupTimes(weekendLogical & ~isnan(wakeupTimes))*2*pi)/(2*pi));
    wakeTimeWeekday = (circ_mean(wakeupTimes(~weekendLogical & ~isnan(wakeupTimes))*2*pi)/(2*pi));
    
    bedTimeWeekendSD = (circ_std(bedTimes(weekendLogical & ~isnan(bedTimes))*2*pi)/(2*pi));
    bedTimeWeekdaySD = (circ_std(bedTimes(~weekendLogical & ~isnan(bedTimes))*2*pi)/(2*pi));
    wakeTimeWeekendSD = (circ_std(wakeupTimes(weekendLogical & ~isnan(wakeupTimes))*2*pi)/(2*pi));
    wakeTimeWeekdaySD = (circ_std(wakeupTimes(~weekendLogical & ~isnan(wakeupTimes))*2*pi)/(2*pi));
    
    SDMultiplier = 1;
    plot([bedTimeWeekend-SDMultiplier*bedTimeWeekendSD wakeTimeWeekend+SDMultiplier*wakeTimeWeekendSD], [2.8 2.8], '-', 'Color', [217,95,2]/255, 'LineWidth', 1);
    plot([bedTimeWeekday-SDMultiplier*bedTimeWeekdaySD wakeTimeWeekday+SDMultiplier*wakeTimeWeekdaySD], [3.5 3.5], '-', 'Color', [27,158,119]/255, 'LineWidth', 1);
    plot(1+[bedTimeWeekend-SDMultiplier*bedTimeWeekendSD wakeTimeWeekend+SDMultiplier*wakeTimeWeekendSD], [2.8 2.8], '-', 'Color', [217,95,2]/255, 'LineWidth', 1);
    plot(1+[bedTimeWeekday-SDMultiplier*bedTimeWeekdaySD wakeTimeWeekday+SDMultiplier*wakeTimeWeekdaySD], [3.5 3.5], '-', 'Color', [27,158,119]/255, 'LineWidth', 1);
    
    plot([bedTimeWeekday bedTimeWeekend], [3.5 2.8], '-k');
    plot([wakeTimeWeekday wakeTimeWeekend], [3.5 2.8], '-k');
    plot(1+[bedTimeWeekday bedTimeWeekend], [3.5 2.8], '-k');
    plot(1+[wakeTimeWeekday wakeTimeWeekend], [3.5 2.8], '-k');
    
    plot([bedTimeWeekend wakeTimeWeekend], [2.8 2.8], '-', 'Color', [217,95,2]/255, 'LineWidth', 4);
    plot([bedTimeWeekday wakeTimeWeekday], [3.5 3.5], '-', 'Color', [27,158,119]/255, 'LineWidth', 4);
    plot(1+[bedTimeWeekend wakeTimeWeekend], [2.8 2.8], '-', 'Color', [217,95,2]/255, 'LineWidth', 4);
    plot(1+[bedTimeWeekday wakeTimeWeekday], [3.5 3.5], '-', 'Color', [27,158,119]/255, 'LineWidth', 4);
    ylim([-5 5]);
    if p == 1
        text(0.5, 2.8, 'Weekend');
        text(0.5, 3.5, 'Weekday');
        text(0.5, 4.2, 'All days');
    end
    
    
    % Aggregate
    bedTimesAll(p) = (circ_mean(bedTimes(~isnan(bedTimes))*2*pi)/(2*pi));
    bedTimesAllSD(p) = (circ_std(bedTimes(~isnan(bedTimes))*2*pi)/(2*pi));
    wakeupTimesAll(p) = (circ_mean(wakeupTimes(~isnan(wakeupTimes))*2*pi)/(2*pi));
    wakeupTimesAllSD(p) = (circ_std(wakeupTimes(~isnan(wakeupTimes))*2*pi)/(2*pi));
    
        bedTimeWeekendAll(p) = (circ_mean(bedTimes(weekendLogical & ~isnan(bedTimes))*2*pi)/(2*pi));
    bedTimeWeekdayAll(p) = (circ_mean(bedTimes(~weekendLogical & ~isnan(bedTimes))*2*pi)/(2*pi));
    wakeTimeWeekendAll(p) = (circ_mean(wakeupTimes(weekendLogical & ~isnan(wakeupTimes))*2*pi)/(2*pi));
    wakeTimeWeekdayAll(p) = (circ_mean(wakeupTimes(~weekendLogical & ~isnan(wakeupTimes))*2*pi)/(2*pi));
    
    % Also plot bed and wake times irrespective of weekend/weekday
    % distinction
    plot([bedTimesAll(p) wakeupTimesAll(p)], [4.2 4.2], '-k', 'LineWidth', 4);
    plot(1+[bedTimesAll(p) wakeupTimesAll(p)], [4.2 4.2], '-k', 'LineWidth', 4);
    plot([bedTimesAll(p)-SDMultiplier*bedTimesAllSD(p) wakeupTimesAll(p)+SDMultiplier*wakeupTimesAllSD(p)], [4.2 4.2], '-k', 'LineWidth', 1);
    plot(1+[bedTimesAll(p)-SDMultiplier*bedTimesAllSD(p) wakeupTimesAll(p)+SDMultiplier*wakeupTimesAllSD(p)], [4.2 4.2], '-k', 'LineWidth', 1);
    
    %
    [~, idx] = min(yfit);
    activityMinimum(p) = edgesFit(idx);
    
    % Fix axes
    pbaspect([1 1.5 1]);
    
    x = hours(a.DATE_TIME-a.DATE_TIME(1));
    
    [py{p}, px{p}] = plomb(zscore(y), x, 1/6);
end

[median(wakeTimeWeekendAll*24-wakeTimeWeekdayAll*24) iqr(wakeTimeWeekendAll*24-wakeTimeWeekdayAll*24)]
[median(bedTimeWeekendAll*24-bedTimeWeekdayAll*24) iqr(bedTimeWeekendAll*24-bedTimeWeekdayAll*24)]

%%
% Save the figure
set(gcf, 'PaperPosition', [0 0 20 15]);
set(gcf, 'PaperSize', [20 15]);
set(gcf, 'Color', 'w');
set(gcf, 'InvertHardcopy', 'off');
saveas(gcf, 'figures/raw/Fig5.pdf', 'pdf');
close(gcf);

%% close figure
close all
%

theColors = [141,211,199 ; ...
    255,237,111 ; ...
    190,186,218 ; ...
    251,128,114 ; ...
    128,177,211 ; ...
    253,180,98]/255;

subplot(1, 2, 1);
for p = 1:length(theParticipants)
    h(p) = plot(1./px{p}-24, py{p}, 'Color', theColors(p, :), 'LineWidth', 2); hold on
end
xlim([-12 12]);
set(gca, 'XTick', [-12:3:12], 'XTickLabel', {-12 '' -6 '' 0 '' 6 '' 12});

set(gca, 'TickDir', 'out', 'TickLength', [0.03, 0.03]);
box on;
xlabel('\Delta(\tau, 24h)');
ylabel('Power [a.u.]');
ylim([0 95]);
xlim([-6.5 6.5]);
plot([0 0], [0 95], ':k');
pbaspect([1 1.5 1]);
set(gca, 'color', [247 247 247]/255);
lgnd = legend(h, 's001', 's002', 's003', 's004', 's005', 's006', 'Location', 'NorthWest');
set(lgnd,'color','w');

%
subplot(1, 2, 2);

%
bedTime = 24*bedTimesAll;
activityMin = 24*activityMinimum;

% Plot the errorbars first
for p = 1:length(theParticipants)
    plot([24*(bedTimesAll(p)-SDMultiplier*bedTimesAllSD(p)) 24*(bedTimesAll(p)+SDMultiplier*bedTimesAllSD(p))], [activityMin(p) activityMin(p)], '-k'); hold on
    plot(bedTime(p), activityMin(p), 'ok', 'MarkerFaceColor', theColors(p, :));
end

% Add trendline
[xData, yData] = prepareCurveData( bedTime, activityMin );
ft = fittype( 'a+b*x', 'independent', 'x', 'dependent', 'y' ); opts = fitoptions( 'Method', 'NonlinearLeastSquares' ); opts.Display = 'Off'; opts.StartPoint = [0.852339164808241 0.257374130045208];
[fitresult, gof] = fit( xData, yData, ft, opts );
yTrend = feval(fitresult, [-2.5 2.5]);
plot([-2.5 2.5], yTrend, ':k')

% Tweak axis and change plot
xlim([-2.5 2.5]); ylim([1.8 5.2]);
pbaspect([1 1.5 1]);
set(gca, 'color', [247 247 247]/255);
set(gca, 'XTick', [-2:2], 'XTickLabel', {'22:00' '' '00:00' '' '02:00'});
set(gca, 'YTick', [2:5], 'YTickLabel', {'02:00' '03:00' '04:00' '05:00'});
set(gca, 'TickDir', 'out', 'TickLength', [0.03, 0.03]);
xlabel('Habitual bedtime [local time]');
ylabel('Minimum activity [local time]');

text(-1, 5, ['y=' num2str(fitresult.a, '%.2f') '+' num2str(fitresult.b, '%.2f') 'x (R2=' num2str(gof.rsquare, '%.2f') ')']);



%
% Save the figure
set(gcf, 'PaperPosition', [0 0 14 10]);
set(gcf, 'PaperSize', [14 10]);
set(gcf, 'Color', 'w');
set(gcf, 'InvertHardcopy', 'off');
saveas(gcf, 'figures/raw/Fig6.pdf', 'pdf');
close(gcf);

%%
%%

