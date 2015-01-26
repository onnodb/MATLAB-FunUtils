function [out] = ifthen(condition, if_true, if_false)
% IFTHEN Returns either the 2nd or 3rd argument, depending on the first.
%
% SYNTAX:
% out = ifthen(condition, if_true, if_false)
%
% INPUT:
% condition = boolean condition evaluating to true or false.
% if_true = value that is returned if 'condition' is true; or, alternatively,
%       a handle to a function without input arguments, that is to be evaluated
%       if 'condition' is true (see notes below).
% if_false = value that is returned if 'condition' is false; etc.
%
% OUTPUT:
% out = 'if_true' or 'if_false', depending on 'condition'.
%
% NOTE:
% "if_true" and "if_false" can be either a value, or a function handle. In the
% latter case, the function matching "condition" is evaluated, and the output
% is returned. This is useful in cases where evaluation of the expression for
% "if_true"/"if_false" would lead to an error if "condition" does *not* match.
% A concrete example:
%
%   >> a = [1 2 3];
%   >> b = 5;
%   >> ifthen(b<=length(a), a(b), 0)
%   Index exceeds matrix dimensions.
%
% By implementing this "lazy evaluation" trick, we can make the above work
% without errors:
%
%   >> ifthen(b<=length(a), @() a(b), @() 0)
%
%   ans =
%
%         0

if condition
    out = if_true;
else
    out = if_false;
end

if isa(out, 'function_handle') && nargin(out) == 0
    out = out();
end

end
