function [tests] = test_map()
tests = functiontests(localfunctions);
end

function testSimpleMappingOfNumericVector(testCase)
    A = 1:10;
    B = map(A, @(i) i*2);

    verifyEqual(testCase, B, 2.*A);
end

function testSimpleMappingOfCellArray(testCase)
    A = {1, 10, 20};
    B = map(A, @(i) i*2);

    verifyEqual(testCase, B, [2 20 40]);
end

function testMappingOfCellMatrix(testCase)
    A = {1 2; 3 4};
    B = map(A, @(i) i*2);

    verifyEqual(testCase, B, [2 4; 6 8]);
end

function testMappingOfCellArrayWithNumericVectors(testCase)
    A = {[1 2 3], [4 5], [6 7 8 9]};
    B = map(A, @(x) x.*10);

    verifyEqual(testCase, B, {[10 20 30], [40 50], [60 70 80 90]});
end

function testMappingOfCellArrayWithStrings(testCase)
    A = {'gazillions', 'of', 'Pink', 'ElEpHaNtS'};
    B = map(A, @upper);

    verifyEqual(testCase, B, {'GAZILLIONS', 'OF', 'PINK', 'ELEPHANTS'});
end

function testMappingOfMatrixElements(testCase)
    % 'map' should operate on individual elements by default.
    A = [1 2 3; 4 5 6; 7 8 9];
    B = map(A, @(x) x*10);

    verifyEqual(testCase, B, A.*10);
end

function testMappingOfMatrixColumnsAsColumns(testCase)
    A = [1 4 7; 2 5 8; 3 6 9];
    B = map(A, @(col) col./mean(col), 2);

    verifyEqual(testCase, B, [0.5 1.0 1.5; 0.8 1.0 1.2; 0.875 1.0 1.125]');
end

function testMappingOfMatrixRowsAsRows(testCase)
    A = [1 2 3; 4 5 6; 7 8 9];
    B = map(A, @(row) row./mean(row), 1);

    verifyEqual(testCase, B, [0.5 1.0 1.5; 0.8 1.0 1.2; 0.875 1.0 1.125]);
end

function testMappingOf3DMatrixAlongDim1(testCase)
    A = reshape(1:24, [3 2 4]);
    B = map(A, @(x) sum(x(:)), 1);

    verifyEqual(testCase, B, [92 100 108]');
end

function testMappingOf3DMatrixAlongDim2(testCase)
    A = reshape(1:24, [3 2 4]);
    B = map(A, @(x) sum(x(:)), 2);

    verifyEqual(testCase, B, [132 168]');
end

function testMappingOf3DMatrixAlongDim3(testCase)
    A = reshape(1:24, [3 2 4]);
    B = map(A, @(x) sum(x(:)), 3);

    verifyEqual(testCase, B, [21 57 93 129]');
end

function testMappingWithExtendedMapFun(testCase)
    A = rand(10,1);
    B = map(A, @(item,idx) idx);

    verifyEqual(testCase, B', 1:10);
end

