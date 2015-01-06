function [tests] = test_cfilter()
tests = functiontests(localfunctions);
end

function testSimpleFilter(testCase)
    A = [1 2 3 4 5 6 7 8 9 10];
    B = cfilter(A, @(i) mod(i,2)==0);

    verifyEqual(testCase, B, [2 4 6 8 10]);
end

function testCellArrayFilter(testCase)
    A = {[1 2], [4 5 6], [], [9 10 11], []};
    B = cfilter(A, @(x) ~isempty(x));

    verifyEqual(testCase, B, {[1 2], [4 5 6], [9 10 11]});
end
