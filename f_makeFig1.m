function f_makeFigure1()

% Plot the receptors
T_receptors = GetCIES026;
wls = (380:1:780)';

plot(wls, (T_receptors(4, :)), '-', 'Color', [1,108,89]/255, 'LineWidth', 2); hold on
plot(wls, (T_receptors(5, :)), '-', 'Color', [103,169,207]/255, 'LineWidth', 2);
plot(wls, (T_receptors(1:3, :)), ':', 'Color', [0.5 0.5 0.5]);
set(gca, 'color', [247 247 247]/255);
set(gca, 'TickDir', 'out', 'TickLength', [0.03, 0.03]);
xlim([380 780]);
ylim([-0.05 1.05]);
set(gca, 'XTick', [400:100:700], 'XTickLabel', []);
ylabel('Linear sensitivity');
pbaspect([1 0.8 1]);

%% Save the figure
set(gcf, 'PaperPosition', [0 0 15 10]);
set(gcf, 'PaperSize', [15 10]);
set(gcf, 'Color', 'w');
set(gcf, 'InvertHardcopy', 'off');
saveas(gcf, 'figures/raw/Fig1.pdf', 'pdf');
close(gcf);