function options = varargin2opt_tiny(va,specs)
%% options = varargin2opt_tiny(...)
% Tiny implementation of varargin2opt to be appended to other functions
% which may need it.
%
% SYNTAX
%  spec = {'plot', false, '';
%          'wildcard', [], 'any';
%          'magicfun', [1,2,3], @(x) size(x,2)==3};
%  opt = varargin2opt(varargin,spec);
%
% Written by Marcin Konowalczyk
% Timmel Group @ Oxford University

II = 'varargin2opt:invalidinput'; % Invalid input message ID
assert(isa(specs,'cell'),II,'Invalid specifications. Must be a cell');
assert(size(specs,2)==3,II,'Invalid specifications. Must be Nx2 or Nx3');
assert(isa(va,'cell'),II,'Invalid ''varargin''. Must be a cell');
assert(~mod(numel(va),2),II,'Invalid ''varargin''. Must have even length');

% Parse options
p = inputParser; p.CaseSensitive = false; p.FunctionName = mfilename; p.KeepUnmatched = true; p.PartialMatching = false; p.StructExpand = false;
    
for Ni = 1:size(specs,1)
    [name, default, valid] = deal(specs{Ni,:});
    assert(ischar(name),II,'Specified key of class ''%s'' as opposed to ''char''',class(name));
    
    % Add parameter to the input parser
    if isa(valid,'function_handle'), addParameter(p,name,default,valid); % Validator supplied
    elseif strcmpi(valid,'any'), addParameter(p,name,default); % Accept any parameter
    elseif isempty(valid), addParameter(p,name,default,@(x) isa(x,class(default))); % Input of the came class as default
    else, error(II,'Specified validator invalid');
    end
end
parse(p,va{:}); options = p.Results;

% Warn if some unmatched
if ~isempty(fields(p.Unmatched))
    warning('varargin2opt:unmatchedOptions','Some options were not matched to any pattern');
end
options = orderfields(options);
end