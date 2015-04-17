function [B] = cfilter(A, fun, varargin)
% CFILTER Filter elements from a collection.
%
% SYNTAX:
% B = cfilter(A, @fun)
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
% OUTPUT:
% B = a vector, with only the elements from A remaining for which the filter
%       function returned 'true'.

keep = cmap(A, fun, varargin{:});
B = A(keep);

end
