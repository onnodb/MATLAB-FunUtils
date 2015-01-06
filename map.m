function [B] = map(A, fun, varargin)
% MAP Apply a function to all elements of a collection, and return the results.
%
% SYNTAX:
% B = map(A, @fun)
% B = map(A, @fun, dim)
%
% INPUT:
% A = an N-D array (vector, matrix, or multidimensional array); a cell
%       array (of any number of dimensions); or a struct array (of any
%       number of dimensions).
% fun = a function of one of the following prototypes:
%           function [b] = fun(item)
%           function [b] = fun(item, idx)
%       with:
%           item = an item from the collection.
%           idx = index of the item within the collection.
%
% OUTPUT:
% B = values from A, after processing by 'fun'.
%       Note that 'map' tries to intelligently adapt the type and shape of
%       'B' to the type of output produced by 'fun'.
%
% SEE ALSO:
% arrayfun, cellfun

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Process & validate input

ndArrayProcessing = false;

if ~isempty(varargin)
    if isnumeric(varargin{1}) && isscalar(varargin{1})
        % Second syntax, for N-D numeric arrays, specifying 'dim' to iterate
        % over.
        if ~isnumeric(A)
            error('MAP:InvalidArgument', 'Invalid collection: numeric N-D array expected.');
        end
        origSize = size(A);
        dim = varargin{1};
        [A, elemSize, dimPermute] = splitByDim(A, dim);
        varargin(1) = []; % pop

        ndArrayProcessing = true;
    end
end

if ~isa(fun, 'function_handle')
    error('MAP:InvalidMapFunction', 'Handle to map function expected.');
end

% Figure out what syntax the mapping function is using.
funType = nargin(fun);
if funType < 1 || funType > 2
    error('MAP:InvalidMapFunction', 'Invalid map function: invalid number of arguments.');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Perform mapping

B = cell(size(A));
outputIsScalar = false(size(A));

for i = 1:numel(A)
    item = A(i);
    if iscell(item) && isscalar(item)
        item = item{1};
    end
    switch funType
        case 1
            B{i} = fun(item);
        case 2
            B{i} = fun(item, i);
    end

    outputIsScalar(i) = isscalar(B{i});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Process output

if isempty(B)
    B = [];
elseif ndArrayProcessing
    if all(outputIsScalar(:))
        % Always output a column vector in this case.
        B = reshape(cell2mat(B), [length(B) 1]);
    elseif isequal(size(B{1}), elemSize)
        % Reverse splitting.
        B = unsplitByDim(B, dimPermute, origSize);
    end
elseif all(outputIsScalar(:))
    B = cell2mat(B);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function [splitA, elemSize, dimPermute] = splitByDim(A, dim)
        if dim == 0
            splitA = A(:);
        else
            if dim > ndims(A)
                error('MAP:InvalidDimension', 'Invalid dimension %d: input only has %d dimensions.', dim, ndims(A));
            end

            % Permute the dimensions of the N-D matrix so that the dimension of
            % interest is the last one.
            dimPermute = [(1:(dim-1)) ((dim+1):ndims(A)) dim];
            A = permute(A, dimPermute);

            % Now split into sub-matrices on the given dimension.
            subShape = size(A);
            nSplit = subShape(end);
            subShape = subShape(1:end-1);
            if isscalar(subShape)
                subShape = [subShape 1];
            end
            subShapeNumEl = prod(subShape);

            splitA = cell(nSplit,1);
            for j = 1:nSplit
                startIdx = (j-1) * subShapeNumEl + 1;
                endIdx   = j * subShapeNumEl;
                splitA{j} = reshape(A(startIdx:endIdx), subShape);
            end

            elemSize = subShape;
        end
    end

    function [unsplitB] = unsplitByDim(B, dimPermute, origSize)
        unsplitB = permute(zeros(origSize), dimPermute);
        subShape = size(B{1});
        subShapeNumEl = prod(subShape);

        nSplit = length(B);
        for j = 1:nSplit
            startIdx = (j-1) * subShapeNumEl + 1;
            endIdx   = j * subShapeNumEl;
            unsplitB(startIdx:endIdx) = B{j}(:);
        end

        unsplitB = ipermute(unsplitB, dimPermute);
    end

end