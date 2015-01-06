# MATLAB Fun Utils

Functional programming-inspired utility functions for MATLAB. Puts some fun into
using MATLAB :-)


## Motivation

For some non-vectorizable operations, it's nicer if you can write a one-liner
using anonymous function syntax, instead of writing yet another `for` loop. The
utility functions in this library provide such functionality.

Note that MATLAB already provides some similar functionality with its `arrayfun`
and `cellfun` functions. Do check those functions out, too, if you aren't
familiar with them.


## Requirements

Should work in any recent version of MATLAB (say, R2012a or higher). Thus far,
only tested on R2014b.


## Package contents

Note: each function is documented. Use `help <function name>` or `doc <function
name>` to read the documentation.

Unit tests are also included. Execute `runtests tests` in the root folder to
run them, using MATLAB's built-in Unit Testing framework.


### cmap

A basic implementation of a generic `map` function for processing items in a
collection, whether it's a numeric vector, a matrix with rows or columns, a cell
array, or a struct array.

Supports parallel processing (pass in the `useParallel` flag).


### cfilter

Basic `filter` function for filtering items in a collection.


### mapfiles

Alternative to MATLAB's `dir` function. Compare:

    files = dir('/my/path/*.png');
    images = cell(size(files));
    for i = 1:length(files)
        images{i} = imread(fullfile('/my/path', files(i).name));
    end

...with:

    images = mapfiles('/my/path/*.png', @(f) imread(f));

Also includes support for recursive listing, and basic filtering (files only,
directories only, exclude hidden files).


### mapsubplots

Easily create a plot with subplots:

    mapsubplots(4, @(i) plot(i.*rand(100,1), '-'), 'title', 'Plot %d');


### explorecell

A small graphical user interface for exploring the contents of a cell array. Try
this, for example:

    % Read a bunch of images.
    myCell = cmap({'peppers.png', 'fabric.png', 'football.jpg'}, @(f) imread(f));

    % Open the Cell Explorer to view all the images.
    explorecell(myCell, @(ax,item,idx) imshow(item, 'parent', ax));

