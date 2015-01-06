function [ax] = mapsubplots(n, plotFun, varargin)
% MAPSUBPLOTS Create a figure with subplots, using anonymous functions.
%
% SYNTAX:
% mapsubplots(n, plotFun)
% mapsubplots([rows cols], plotFun)
% mapsubplots(..., 'key', value)
% ax = mapsubplots(...)
%
% INPUT:
% n = number of subplots to create. The number of rows and columns is
%       automatically calculated.
% [rows cols] = vector with the number of subplot rows/columns.
% plotFun = function handle to a function of the following prototype:
%           plotFun(idx)
%       with:
%           idx = index of the subplot.
%       The function should call plotting functions to create the actual plots.
%
% OUTPUT:
% ax = cell array with axes handles of the subplots created.
%
% KEY-VALUE PAIR ARGUMENTS:
% title = either a string that can be passed into "sprintf", containing a
%       single formatspec "%d"; the formatted string is then used as title
%       for each of the subplots. Or a function handle, to a function of
%       the following prototype:
%           [s] = titleFun(idx)
%       with:
%           idx = index of the subplot.
%           s = title for the subplot with index "idx".
% xlabel = works analogously to "title", but sets the "xlabel" of each of the
%       subplots.
% ylabel = works analogously to "title", but sets the "ylabel" of each of the
%       subplots.
%
% EXAMPLES:
% mapsubplots(4, @(i) plot(i.*rand(100,1), '-'));
%
% SEE ALSO:
% sprintf

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parse & validate input

if ~isa(plotFun, 'function_handle')
    error('Invalid argument "plotFun": function handle expected.');
end

defArgs = struct(...
                  'title',                              [] ...
                , 'xlabel',                             [] ...
                , 'ylabel',                             [] ...
                );
args = pargs(varargin, defArgs);

if isscalar(n)
    nRows = floor(sqrt(n));
    nCols = ceil(n/nRows);
elseif isvector(n) && length(n) == 2
    nRows = n(1);
    nCols = n(2);
    n = prod(n);
else
    error('Invalid argument "n": scalar or vector of length 2 expected.');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make plots

figure;

ax = cell(n,1);

for iSubplot = 1:n
    ax{iSubplot} = subplot(nRows, nCols, iSubplot);

    plotFun(iSubplot);

    callLayoutFun(@title,  args.title,  iSubplot);
    callLayoutFun(@xlabel, args.xlabel, iSubplot);
    callLayoutFun(@ylabel, args.ylabel, iSubplot);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function callLayoutFun(layoutFun, layoutDef, idx)
        if ~isempty(layoutDef)
            if ischar(layoutDef)
                if isempty(strfind(layoutDef, '%d'))
                    layoutFun(gca(), layoutDef);
                else
                    layoutFun(gca(), sprintf(layoutDef, idx));
                end
            elseif isa(layoutDef, 'function_handle')
                layoutFun(layoutDef(idx));
            else
                error('Invalid argument: function handle or formatting string expected.');
            end
        end
    end

end

