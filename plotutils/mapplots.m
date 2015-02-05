function [h] = mapplots(n, plotFun, varargin)
% MAPPLOTS Create a figure with multiple plots, using anonymous functions.
%
% SYNTAX:
% mapsubplots(n, plotFun)
% h = mapsubplots(...)
%
% INPUT:
% n = number of plots to create.
% plotFun = function handle to a function of the following prototype:
%           h = plotFun(idx)
%       with:
%           idx = index of the subplot.
%           h = the handle of the plot created.
%       The function should call plotting functions to create the actual plots,
%       and return the created plot handle.
%
% OUTPUT:
% h = cell array with plot handles of the plots created.
%
% KEY-VALUE PAIR ARGUMENTS:
% parent = handle to the Axes to contain the plot (optional).
%
% EXAMPLES:
% mapplots(4, @(i) plot(i.*rand(100,1), '-'));
%
% SEE ALSO:
% sprintf

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parse & validate input

if ~isa(plotFun, 'function_handle')
    error('Invalid argument "plotFun": function handle expected.');
end

defArgs = struct(...
                  'parent',                             [] ...
                );
args = pargs(varargin, defArgs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make plots

if isempty(args.parent)
    figure;
else
    axes(args.parent);
end

h = cell(n,1);

for iPlot = 1:n
    h{iPlot} = plotFun(iPlot);
    if iPlot == 1
        hold('on');
    end
end

end

