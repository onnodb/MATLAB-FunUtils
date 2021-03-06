function [tests] = test_cmap()
tests = functiontests(localfunctions);
end

function testSimpleMappingOfNumericVector(testCase)
    A = 1:10;
    B = cmap(A, @(i) i*2);

    verifyEqual(testCase, B, 2.*A);
end

function testSimpleMappingOfCellArray(testCase)
    A = {1, 10, 20};
    B = cmap(A, @(i) i*2);

    verifyEqual(testCase, B, [2 20 40]);
end

function testMappingOfCellMatrix(testCase)
    A = {1 2; 3 4};
    B = cmap(A, @(i) i*2);

    verifyEqual(testCase, B, [2 4; 6 8]);
end

function testMappingOfCellArrayWithNumericVectors(testCase)
    A = {[1 2 3], [4 5], [6 7 8 9]};
    B = cmap(A, @(x) x.*10);

    verifyEqual(testCase, B, {[10 20 30], [40 50], [60 70 80 90]});
end

function testMappingOfCellArrayWithStrings(testCase)
    A = {'gazillions', 'of', 'Pink', 'ElEpHaNtS'};
    B = cmap(A, @upper);

    verifyEqual(testCase, B, {'GAZILLIONS', 'OF', 'PINK', 'ELEPHANTS'});
end

function testMappingOfMatrixElements(testCase)
    % 'map' should operate on individual elements by default.
    A = [1 2 3; 4 5 6; 7 8 9];
    B = cmap(A, @(x) x*10);

    verifyEqual(testCase, B, A.*10);
end

function testMappingOfMatrixColumnsAsColumns(testCase)
    A = [1 4 7; 2 5 8; 3 6 9];
    B = cmap(A, @(col) col./mean(col), 2);

    verifyEqual(testCase, B, [0.5 1.0 1.5; 0.8 1.0 1.2; 0.875 1.0 1.125]');
end

function testMappingOfMatrixRowsAsRows(testCase)
    A = [1 2 3; 4 5 6; 7 8 9];
    B = cmap(A, @(row) row./mean(row), 1);

    verifyEqual(testCase, B, [0.5 1.0 1.5; 0.8 1.0 1.2; 0.875 1.0 1.125]);
end

function testMappingOf3DMatrixAlongDim1(testCase)
    A = reshape(1:24, [3 2 4]);
    B = cmap(A, @(x) sum(x(:)), 1);

    verifyEqual(testCase, B, [92 100 108]');
end

function testMappingOf3DMatrixAlongDim2(testCase)
    A = reshape(1:24, [3 2 4]);
    B = cmap(A, @(x) sum(x(:)), 2);

    verifyEqual(testCase, B, [132 168]');
end

function testMappingOf3DMatrixAlongDim3(testCase)
    A = reshape(1:24, [3 2 4]);
    B = cmap(A, @(x) sum(x(:)), 3);

    verifyEqual(testCase, B, [21 57 93 129]');
end

function testMappingWithExtendedMapFun(testCase)
    A = rand(10,1);
    B = cmap(A, @(item,idx) idx);

    verifyEqual(testCase, B', 1:10);
end

function testMappingWithStructArray(testCase)
    A = struct('value', {1 2 3 4}, 'anothervalue', {5 6 7 8});
    B = cmap(A, @(s) struct('value', s.value*2, 'more', s.anothervalue*3));
    B_correct = struct('value', {2 4 6 8}, 'more', {15 18 21 24});

    verifyEqual(testCase, B, B_correct);
end

function testParallelization(testCase)
    A = 1:10;
    B = cmap(A, @(i) i*2, 'useParallel');

    verifyEqual(testCase, B, 2.*A);
end
