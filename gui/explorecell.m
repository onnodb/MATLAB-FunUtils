function explorecell(ca, drawFun, hFig)
% EXPLORECELL Visually explore the contents of a cell array.
%
% This function creates a simple GUI for exploring the contents of a cell
% array visually.
%
% INPUT:
% ca = a cell array vector, containing, e.g., results of an analysis;
%       alternatively, a number indicating the number of elements in a
%       'virtual cell array' (if your drawing function is more complex).
% drawFun = function handle to a function that takes an item from the cell
%            array, as well as an axes handle, and visualizes the contents
%            of the cell on the screen.
%            Prototype of the function:
%               drawFun(handle, cellItem, itemIndex)
%            Where:
%               handle = either an axes handle (default), or a figure handle
%                   (if using the 'hFig' argument) that should be used
%                   for creating the plot.
%               cellItem = item in the cell array 'ca' that was selected by
%                   the user.
%               itemIndex = index of the item selected by the user.
% hFig = if using an external figure window for plotting, pass in the figure
%       handle as third argument. This handle then gets passed into 'drawFun'
%       as well (as the first argument 'handle').
%
% EXAMPLES:
% >> myCell = {1, 5, 10};
% >> explorecell(myCell, @(ax,item,idx) plot(ax, item .* rand(100,1), '-'));
%
% >> explorecell(myCell, @(hFig,item,idx) plot(item .* rand(100,1), '-'), figure());
%
% >> myCell = {imread('peppers.png'), imread('fabric.png'), imread('football.jpg')};
% >> explorecell(myCell, @(ax,item,idx) imshow(item, 'parent', ax));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process & validate input

if isscalar(ca) && isnumeric(ca)
    ca = cell(1, ca);               % make dummy cell array
elseif iscell(ca) && isvector(ca)
    % ok
else
    error('explorecell:invalidArgument', 'Invalid argument "ca": cell array vector expected (dimensions 1xN or Nx1)');
end

if ~isa(drawFun, 'function_handle')
    error('explorecell:invalidArgument', 'Invalid argument "drawFun": function handle expected');
end

if nargin < 3
    hFig = [];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open up GUI

gui = createGUI();
set(gui.window, 'UserData', 1);        % UserData stores current item index

setItem(1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function [gui] = createGUI()
        gui = struct();

        if isempty(hFig)
            screenSize = get(0, 'MonitorPositions');
            if size(screenSize,1) > 1
                screenSize = screenSize(1,:);
            end
            winPos = [screenSize(3)/8 screenSize(4)/2 screenSize(3)/1.4 screenSize(4)/1.4];
        else
            winPos = getCompanionWinPos(get(hFig, 'Position'), [280 50]);
        end
        gui.window = figure(...
            'Name',             'Cell Explorer' ...
          , 'NumberTitle',      'off' ...
          , 'MenuBar',          'none' ...
          , 'Toolbar',          'none' ...
          , 'HandleVisibility', 'off' ...
          , 'Position',         winPos ...
          , 'KeyPressFcn',      @onWindowKeyPress ...
          , 'CloseRequestFcn',  @onWindowClose ...
          );
        gui.main = uiextras.VBox('Parent', gui.window);

        % ----- Toolbar
        gui.toolbar.panel = uiextras.HBox('Parent', gui.main, 'Spacing', 3);
        gui.toolbar.first = uicontrol(...
            'Parent',           gui.toolbar.panel ...
          , 'Style',            'pushbutton' ...
          , 'String',           '<<' ...
          , 'Callback',         @onToolbarFirstPress ...
          );
        gui.toolbar.prev = uicontrol(...
            'Parent',           gui.toolbar.panel ...
          , 'Style',            'pushbutton' ...
          , 'String',           '<' ...
          , 'Callback',         @onToolbarPrevPress ...
          );
        gui.toolbar.item = uicontrol(...
            'Parent',           gui.toolbar.panel ...
          , 'Style',            'edit' ...
          , 'HorizontalAlignment', 'center' ...
          , 'Callback',         @onToolbarItemChange ...
          );
        gui.toolbar.maxItems = uicontrol(...
            'Parent',           gui.toolbar.panel ...
          , 'Style',            'edit' ...
          , 'String',           [' / ' num2str(length(ca))] ...
          , 'Enable',          'off' ...
          );
        gui.toolbar.next = uicontrol(...
            'Parent',           gui.toolbar.panel ...
          , 'Style',            'pushbutton' ...
          , 'String',           '>' ...
          , 'Callback',         @onToolbarNextPress ...
          );
        gui.toolbar.last = uicontrol(...
            'Parent',           gui.toolbar.panel ...
          , 'Style',            'pushbutton' ...
          , 'String',           '>>' ...
          , 'Callback',         @onToolbarLastPress ...
          );

        set(gui.toolbar.panel, 'Sizes', [30 30 100 40 30 30]);

        % ----- Axes
        gui.axes = axes('Parent', gui.main);

        set(gui.main, 'Sizes', [30 -1]);

        % Link to external window (but don't overwrite events)
        if ~isempty(hFig)
            if isempty(get(hFig, 'KeyPressFcn'))
                set(hFig, 'KeyPressFcn', @onWindowKeyPress);
            end
            if isempty(get(hFig, 'CloseRequestFcn')) || strcmp(get(hFig, 'CloseRequestFcn'), 'closereq')
                set(hFig, 'CloseRequestFcn', @onWindowClose);
            end
        end
    end

    function [cwp] = getCompanionWinPos(extWinPos, winSize)
        screenSize = get(0, 'ScreenSize');

        margin = 50;

        % Try positioning on left of external window's top-left corner
        cwp = [(extWinPos(1)-winSize(1)-margin) (extWinPos(2)+extWinPos(4)) winSize];

        if cwp(2) > (screenSize(4)-margin-winSize(2)) || cwp(1) < 10
            % Position would be off-screen; try above external window
            cwp = [extWinPos(1) (extWinPos(2)+extWinPos(4)+margin+winSize(2)) winSize];

            if cwp(2) > (screenSize(4)-margin-winSize(2)-50)
                % Last attempt: try below external window
                cwp(2) = extWinPos(2)-margin-winSize(2);
            end
        end
    end

    function setItem(itemIndex)
        set(gui.toolbar.item, 'String', num2str(itemIndex));
        set(gui.window, 'UserData', itemIndex);

        if isempty(hFig)
            cla(gui.axes);
            drawFun(gui.axes, ca{itemIndex}, itemIndex);
        else
            clf(hFig);
            drawFun(hFig, ca{itemIndex}, itemIndex);
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function onToolbarFirstPress(~, ~)
        setItem(1);
    end

    function onToolbarPrevPress(~, ~)
        idx = get(gui.window, 'UserData') - 1;
        if idx >= 1
            setItem(idx);
        end
    end

    function onToolbarNextPress(~, ~)
        idx = get(gui.window, 'UserData') + 1;
        if idx <= length(ca)
            setItem(idx);
        end
    end

    function onToolbarLastPress(~, ~)
        setItem(length(ca));
    end

    function onToolbarItemChange(~, ~)
        idx = round(str2double(get(gui.toolbar.item, 'String')));
        if idx < 1 || idx > length(ca)
            idx = NaN;
        end

        if isnan(idx)
            % User didn't enter a valid number
            set(gui.toolbar.item, 'String', num2str(get(gui.window, 'UserData')));
        else
            % OK: apply
            setItem(idx);
        end
    end

    function onWindowClose(~, ~)
        if ishandle(gui.window)
            delete(gui.window);
        end

        if ~isempty(hFig)
            % If one window is closed, automatically close the other as well
            if ishandle(hFig)
                delete(hFig)
            end;
        end
    end

    function onWindowKeyPress(~, e)
        % Allow for easy key navigation
        switch e.Key
            case {'downarrow','leftarrow','pageup'}
                onToolbarPrevPress();
            case {'uparrow','rightarrow','pagedown'}
                onToolbarNextPress();
            case 'home'
                onToolbarFirstPress();
            case 'end'
                onToolbarLastPress();
            case 'escape'
                delete(gui.window);
            case 'f5'       % refresh
                setItem(get(gui.window, 'UserData'));
        end
    end

end

