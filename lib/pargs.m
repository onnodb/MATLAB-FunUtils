function [argStruct] = pargs(args, defArgStruct, flagParamNames)
% Helper function for parsing varargin.
%
% INPUT:
% args = 'varargin' 1xN cell array
% defArgStruct = struct with argument names and corresponding default
%                values.
% flagParamNames = 1xM cell array with names of parameters that don't
%                  require a value. If they appear in 'args', their value
%                  will be set to 1. (Optional)
%
% OUTPUT:
% argStruct = struct with parsed arguments/values. Flags are guaranteed to
%             get assigned either a true/false value by pargs.
%
% EXAMPLES:
% argStruct = pargs(varargin, struct('param1', 0.1, 'otherParam', 'test'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization

if nargin < 3
    flagParamNames = {};
end

if ~(isscalar(defArgStruct) && isstruct(defArgStruct))
    error('PARGS:InvalidDefArgStruct', 'Invalid default parameter specification: should be a single struct');
end

% Create matrix of accepted parameter names
validParamNames = fieldnames(defArgStruct);

for i = 1:length(flagParamNames)
    if ~isValidParamName(flagParamNames{i}, validParamNames)
        error('PARGS:InvalidFlagParamName', 'Invalid flag parameter name "%s"', flagParamNames{i});
    end
end

argStruct = defArgStruct;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parse!

parseStates = struct('paramName', 1, 'paramValue', 2);
curParseState = parseStates.paramName;
curParamName = '';
curArgIdx = 1;

while curArgIdx <= length(args)
    if curParseState == parseStates.paramName
        curParamName = parseParamName(args{curArgIdx}, validParamNames);
        if isempty(curParamName)
            error('PARGS:InvalidArgument', 'Invalid argument "%s"', args{curArgIdx});
        end
        if isFlagParam(curParamName, flagParamNames)
            % Flag parameter!
            % Value might be explicitly specified...
            if length(args) > curArgIdx
                if islogical(args{curArgIdx+1}) || isnumeric(args{curArgIdx+1})
                    % Flag value is explicitly specified
                    if args{curArgIdx+1}
                        argStruct.(curParamName) = true;    % make sure we explicitly assign true/false
                    else
                        argStruct.(curParamName) = false;
                    end

                    % --> paramName (skip 1 arg)
                    curArgIdx = curArgIdx + 2;
                    curParseState = parseStates.paramName;
%^^^
                    continue;
                end
            end

            % Apparently, value was not explicitly specified: turn it on
            argStruct.(curParamName) = true;

            % --> paramName
            curArgIdx = curArgIdx + 1;
            curParseState = parseStates.paramName;
%^^^
            continue;
        else
            % Not a flag parameter
            % --> paramValue
            curArgIdx = curArgIdx + 1;
            curParseState = parseStates.paramValue;
%^^^
            continue;
        end
    elseif curParseState == parseStates.paramValue
        % Save parameter value
        argStruct.(curParamName) = args{curArgIdx};

        % --> paramName
        curArgIdx = curArgIdx + 1;
        curParseState = parseStates.paramName;
%^^^
        continue;
    else
        error('Invalid parse state in pargs!');
    end
end % while

% Are we missing anything?
if curParseState == parseStates.paramValue
    error('PARGS:MissingArgumentValue', 'Missing value for argument "%s"', curParamName);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function [valid] = isValidParamName(paramName, validParamNames)
        valid = ~isempty(parseParamName(paramName, validParamNames));
    end

    function [parsedParamName] = parseParamName(paramName, validParamNames)
        parsedParamName = '';
        for j = 1:length(validParamNames)
            if strcmpi(paramName, validParamNames{j})
                parsedParamName = validParamNames{j};
                return
            end
        end
    end

    function [isFlag] = isFlagParam(paramName, flagParamNames)
        isFlag = false;
        for j = 1:length(flagParamNames)
            if strcmpi(paramName, flagParamNames{j})
                isFlag = true;
                return
            end
        end
    end

end

