function f_prep()
% Add everything to the path
addpath(genpath(pwd));

% Make folder to save figures in
if ~exist('figures/', 'dir')
    mkdir('figures/');
end
if ~exist('figures/raw', 'dir')
    mkdir('figures/raw');
end