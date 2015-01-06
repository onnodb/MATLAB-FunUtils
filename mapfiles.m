function [B] = mapfiles(pathName, fun, varargin)
% MAPFILES Map filenames from the filesystem.
%
% SYNTAX:
% B = mapfiles(pathName, fun)
% B = mapfiles(..., 'key', value)
% B = mapfiles(..., 'flag')
%
% INPUT:
% pathName = name of a folder, or set of files. You can use wildcards (*), just
%       like in MATLAB's own "dir" function.
% fun = handle to a function that takes a string containing a filename (and,
%       optionally, an index; see the documentation for "map").
%
% FLAG ARGUMENTS:
% dirsOnly = if given, only processes directories, not files.
% filesOnly = if given, only processes files, not directories.
% noHidden = don't process any hidden files. (Note: this uses the UNIX
%       definition of a hidden file, i.e., a file or directory whose name
%       starts with a period (.)).
% recursive = if given, also recurses into subdirectories.
% useParallel = if given, uses a 'parfor' loop, for parallel processing.
%
% SEE ALSO:
% dir, map

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parse & validate input

% Key-value pair, and flag arguments.
defArgs = struct(...
                  'dirsOnly',                               false ...
                , 'filesOnly',                              false ...
                , 'noHidden',                               false ...
                , 'recursive',                              false ...
                , 'useParallel',                            false ...
                );
args = pargs(varargin, defArgs, {'dirsOnly', 'filesOnly', 'noHidden', 'recursive', 'useParallel'});

if args.dirsOnly && args.filesOnly
    error('Cannot give both the "dirsOnly" and the "filesOnly" flag.');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop over files in filesystem

if isdir(pathName)
    mask = [];
elseif ~isempty(strfind(pathName, '*'))
    [rootPath, fileName, fileExt] = fileparts(pathName);
    fileName = [fileName fileExt];
    if isempty(strfind(fileName, '*'))
        mask = [];
    else
        pathName = rootPath;
        mask     = fileName;
    end
end

pathsToProcess = collectPaths(pathName, mask);

B = map(pathsToProcess', fun, 'useParallel', args.useParallel);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function [p] = collectPaths(pathName, mask)
        if isempty(mask)
            files = dir(pathName);
        else
            files = dir(fullfile(pathName, mask));
        end

        p = {};
        for i = 1:length(files)
            if ~any(strcmp(files(i).name, {'.', '..'}))
                if args.noHidden
                    isHidden = (files(i).name(1) == '.');
                else
                    isHidden = false;
                end

                if (files(i).isdir && args.filesOnly) || (~files(i).isdir && args.dirsOnly) || ...
                        (isHidden && args.noHidden)
                    % skip
                else
                    p{end+1} = fullfile(pathName, files(i).name);
                end
            end
        end

        if args.recursive
            dirs = dir(pathName);
            for i = 1:length(dirs)
                if ~any(strcmp(dirs(i).name, {'.', '..'})) && dirs(i).isdir
                    if args.noHidden
                        isHidden = (dirs(i).name(1) == '.');
                    else
                        isHidden = false;
                    end

                    if (isHidden && args.noHidden)
                        % skip
                    else
                        p = [p collectPaths(fullfile(pathName, dirs(i).name), mask)];
                    end
                end
            end
        end
    end

end
