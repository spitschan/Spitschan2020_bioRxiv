% Plot the receptors
addpath(genpath(pwd))
T_receptors = GetCIES026;
wls = (380:1:780)';

% Correlation plot
% Load the CIE 1931 2° CMF
load T_xyz1931

% Spline them to standard wl spacing
T_xyz = SplineCmf(S_xyz1931, 683*T_xyz1931, wls);

% Load Houser spectra and spline as well
load spd_houser
spd_houser = SplineSpd(S_houser, spd_houser, wls);

% Scale
XYZ_houser= (T_xyz*spd_houser);
scalar = 100./XYZ_houser(2, :);
spd_houser = (scalar.*spd_houser);

% Plot 
subplot(1, 3, 1);
rodResponses = 1745*T_receptors(4, :)*spd_houser;
melResponses = 1000*T_receptors(5, :)*spd_houser;

% Fit data
[xData, yData] = prepareCurveData( rodResponses, melResponses );

% Set up fittype and options.
ft = fittype( 'a*x + b', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.839570171627704 0.193027389667444];

% Fit model to data.
xLims = [-20 350];
xlim(xLims);
yLims = [-20 210];
ylim(yLims);
[fitresult, gof] = fit( xData, yData, ft, opts );
xfit = xLims(1):xLims(2);
feval(fitresult, xfit)
yfit = feval(fitresult, xfit);
plot(xfit, yfit, ':r', 'LineWidth', 2); hold on

set(gca, 'color', [247 247 247]/255);
set(gca, 'TickDir', 'out', 'TickLength', [0.03, 0.03]);

fitEq = ['y = ' num2str(fitresult.b, '%.2f') ' + ' num2str(fitresult.a, '%.2f') 'x'];
R2 = ['R2 = ' num2str(gof.rsquare, '%.2f')];
text(10, 195, fitEq, 'HorizontalAlignment', 'Left')
text(10, 178, R2, 'HorizontalAlignment', 'Left')
text(335, -5, 'n=401 [100 cd/m2]', 'HorizontalAlignment', 'Right');
pbaspect([0.8 1 1])
plot(rodResponses, melResponses, 'ok', 'MarkerFaceColor', 'w'); hold on;
xlabel({'Scotopic luminance' '[sc cd/m2]'});
ylabel({'Melanopic irradiance' '[mW/m2/sr]'});

% Set up plot first
xLims = [-20 350];
xlim(xLims);
yLims = [-20 210];
ylim(yLims);
set(gca, 'color', [247 247 247]/255);
set(gca, 'TickDir', 'out', 'TickLength', [0.03, 0.03]);

% Filters
subplot(1, 3, 2);
opts = delimitedTextImportOptions("NumVariables", 2);
opts.DataLines = [1723, 2123];
opts.Delimiter = ",";
opts.VariableNames = ["sample1", "VarName2"]; opts.VariableTypes = ["double", "double"]; opts.ExtraColumnsRule = "ignore"; opts.EmptyLineRule = "read";
F90data = readtable("F90 data.csv", opts);
F540data = readtable("F540 data.csv", opts);

trans_F90 = F90data.VarName2(end:-1:1);
plot(wls, trans_F90, 'Color', [239,101,72]/255, 'LineWidth', 2); hold on
trans_F540 = F540data.VarName2(end:-1:1);
plot(wls, trans_F540, 'Color', [253,187,132]/255, 'LineWidth', 2);
xlabel('Wavelength [nm]');
ylabel('Transmittance [%]');

set(gca, 'color', [247 247 247]/255);
xlim([380 780]);
ylim([-5 105]);
set(gca, 'XTick', [400:100:700]);
set(gca, 'TickDir', 'out', 'TickLength', [0.03, 0.03]);
pbaspect([0.8 1 1])


%%
subplot(1, 3, 3);
rodResponses_F90 = 1745*T_receptors(4, :)*((trans_F90/100).*spd_houser);
melResponses_F90 = 1000*T_receptors(5, :)*((trans_F90/100).*spd_houser);

rodResponses_F540 = 1745*T_receptors(4, :)*((trans_F540/100).*spd_houser);
melResponses_F540 = 1000*T_receptors(5, :)*((trans_F540/100).*spd_houser);

plot(log10(rodResponses), log10(melResponses), 'ok', 'MarkerFaceColor', 'w'); hold on
plot(log10(rodResponses_F540), log10(melResponses_F540), 'ok', 'MarkerFaceColor', [253,187,132]/255); hold on;
plot(log10(rodResponses_F90), log10(melResponses_F90), 'ok', 'MarkerFaceColor', [239,101,72]/255); hold on;
text(1.75, 0.75, 'F540', 'HorizontalAlignment', 'Left');
text(0.5, -0.35, 'F90', 'HorizontalAlignment', 'Left');
text(2, 2, 'Unfiltered', 'HorizontalAlignment', 'Right');
xlabel({'Scotopic luminance' '[sc cd/m2]'});
ylabel({'Melanopic irradiance' '[mW/m2/sr]'});
xLims = [-0.75 2.75];
xlim(xLims);
yLims = [-0.75 2.75];
ylim(yLims);
set(gca, 'color', [247 247 247]/255);
set(gca, 'TickDir', 'out', 'TickLength', [0.03, 0.03]);
pbaspect([0.8 1 1])

%% Contrast
% M = csvread('ces.csv')
% 
% load spd_D65.mat
% spd_D65 = SplineSpd(S_D65, spd_D65, wls);
% 
% spd_samples = T_receptors(4,:) * (spd_D65.*M);
% spd_samples2 = T_receptors(4,:) * ((trans_F540/100).*(spd_D65.*M));
% spd_samples3 = T_receptors(4,:) * ((trans_F90/100).*(spd_D65.*M));
% 
% contrast1 = (spd_samples-mean(spd_samples)) ./ (mean(spd_samples))
% contrast2 = (spd_samples2-mean(spd_samples2)) ./ (mean(spd_samples2))
% contrast3 = (spd_samples3-mean(spd_samples3)) ./ (mean(spd_samples3))


%% Save the figure
set(gcf, 'PaperPosition', [0 0 20 10]);
set(gcf, 'PaperSize', [20 10]);
set(gcf, 'Color', 'w');
set(gcf, 'InvertHardcopy', 'off');
saveas(gcf, 'figures/raw/Fig2.pdf', 'pdf');
close(gcf);