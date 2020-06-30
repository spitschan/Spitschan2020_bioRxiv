%% Information
% This script runs all the relevant code related to the article
% "Rest-activity cycles and melatonin phase angle of circadian entrainment
% in people without cone-mediated vision" by Spitschan et al.
% (https://doi.org/10.1101/2020.06.02.129502).
%
% All figures are saved in figures/raw
%
% Function          Output                  Place in manuscript
% ==================================================================
% f_makeFig1        figures/raw/Fig1.pdf    Figure 1, panels b and d
% f_makeFig2        figures/raw/Fig2.pdf    Figure 2
% f_makeFig3        figures/raw/Fig2.pdf    Figure 3
% f_makeFig5_6      figures/raw/Fig5.pdf    Figure 5
%                   figures/raw/Fig6.pdf    Figure 6
% f_makeFig7        figures/raw/Fig7.pdf    Figure 7
%
% Note 1: All figures are produced in 'raw' version, i.e. some graphical
% elements have been modified in Adobe Illustrator afterwards.
%
% Note 2: Figure 4 comprises screenshots from the proprietary ActTrust
% software and is not part of the programmatic analysis.

%% (0) Housekeeping
close all; clearvars;

%% (1) Prepare the directory structure
f_prep();

%% (2) Make raw materials for panels b and d of Figure 1
f_makeFig1();

%% (3) Make raw version of Figure 2
f_makeFig2();

%% (4) Make raw version of Figure 3
f_makeFig3();

%% (5) Make raw version of Figure 5
f_makeFigs5_6();

%% (6) Make raw version of Figure 7
f_makeFig7();