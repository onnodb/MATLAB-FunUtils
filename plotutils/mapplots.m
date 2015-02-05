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
%       Alternatively, it is also possible to specify a cell array with
%       multiple function handles.
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

if isa(plotFun, 'function_handle')
    plotFun = {plotFun};
elseif (iscell(plotFun) && ~isempty(plotFun) && isa(plotFun{1}, 'function_handle'))
    % ok
else
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

h = cell(n,length(plotFun));

for iPlot = 1:n
    for i = 1:length(plotFun)
        if nargout(plotFun{i}) == 0
            plotFun{i}(iPlot);
        else
            h{iPlot,i} = plotFun{i}(iPlot);
        end
    end
    if iPlot == 1
        hold('on');
    end
end

end

