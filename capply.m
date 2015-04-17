function capply(A, fun, varargin)
% CAPPLY Run a function on all elements of a collection.
%
% SYNTAX:
% capply(A, @fun)
%
% INPUT:
% A = a vector, either numeric, a cell array, or a struct array.
% fun = a function of one of the following prototypes:
%           function [b] = fun(item)
%           function [b] = fun(item, idx)
%       with:
%           item = an item from the collection.
%           idx = index of the item within the collection.
%           b = a boolean, indicating if the item should be kept.
%
% NOTE: This is really just a simple wrapper around "cmap", for map functions
% that don't return anything.
%
% SEE ALSO:
% cmap


switch nargin(fun)
    case 1
        wrapperFun = @capply_internal1;
    case 2
        wrapperFun = @capply_internal2;
    otherwise
        error('CAPPLY:InvalidMapFunction', 'Invalid map function: invalid number of arguments.');
end

cmap(A, wrapperFun, varargin{:});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function [dummy] = capply_internal1(item)
        dummy = [];
        fun(item);
    end

    function [dummy] = capply_internal2(item, idx)
        dummy = [];
        fun(item, idx);
    end

end
