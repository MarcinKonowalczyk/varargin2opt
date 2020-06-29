function options = varargin2opt(varargin)
%% options = varargin2opt(...)
% This function parses a key-value 'varargin' input of a function into
% a struct.
%
% SYNTAX
%
%  function [...] = myLittleFunction(...,varargin)
% 
%  opt = varargin2opt(varargin)
%
%  spec = {'plot',false;'varbosity',false};
%  opt = varargin2opt(varargin,spec);
%
%  spec = {'plot'     ,false  ,''    ;
%          'wildcard' ,[]     ,'any';
%          'magicfun' ,[1,2,3],@(x) size(x,2)==3}
%  opt = varargin2opt(varargin,spec);
%
% Written by Marcin Konowalczyk
% Timmel Group @ Oxford University

%%
narginchk(1,2)
II = 'varargin2opt:invalidinput'; % Invalid input message ID

%% Just the 'varargin'
if nargin == 1
    % Check varargin
    varargin = varargin{1};
    assert(isa(varargin,'cell'),II,'Invalid ''varargin''. Must be a cell');
    N = numel(varargin);
    assert(~mod(N,2),II,'Invalid ''varargin''. Must have even length');
    
    % Parse options
    options = struct();
    if N > 1
        for Ni = 1:(N/2)
            key = varargin{2*(Ni-1)+1};
            assert(ischar(key),II,'Varargin key of class ''%s'' as opposed to ''char''',class(key));
            value = varargin{2*Ni};
            options.(matlab.lang.makeValidName(key)) = value;
        end
    end
    
%% 'varargin' and input specifications
else
    % Add the third default entry to specs
    specs = varargin{2};
    assert(isa(specs,'cell'),II,'Invalid specifications. Must be a cell');
    s = size(specs,2); N = size(specs,1);
    assert(s==2 || s==3,II,'Invalid specifications. Must be Nx2 or Nx3');
    if s==2
        for Ni = 1:N
           specs{Ni,3} = '';
        end
    end
    
    % Check varargin
    varargin = varargin{1};
    assert(isa(varargin,'cell'),II,'Invalid ''varargin''. Must be a cell');
    assert(~mod(numel(varargin),2),II,'Invalid ''varargin''. Must have even length');
    
    % Create input parser
    p = inputParser;
    p.CaseSensitive = false;
    p.FunctionName = mfilename;
    p.KeepUnmatched = true;
    
    % Parse options
    for Ni = 1:N
        [name, default, valid] = deal(specs{Ni,:});
        assert(ischar(name),II,'Specified key of class ''%s'' as opposed to ''char''',class(name));
        
        % Add parameter to the input parser
        if isa(valid,'function_handle') % Validator supplied
            addParameter(p,name,default,valid);
        elseif strcmpi(valid,'any') % Accept any parameter
            addParameter(p,name,default);
        elseif isempty(valid) % Input of the came class as default
            addParameter(p,name,default,@(x) isa(x,class(default)));
        else
            error(II,'Specified validator invalid');
        end 
    end
    parse(p,varargin{:});
    options = p.Results;
    
    % Warn if some unmatched
    unmatched = fields(p.Unmatched);
    if ~isempty(unmatched)
        names = '';
        for j = 1:numel(unmatched)
            names = [names unmatched{j} ', ']; %#ok<AGROW>
        end
        names(end-1:end) = [];
        warning('varargin2opt:unmatchedOptions','Some options (%s) were not matched to any pattern',names);
    end
end
options = orderfields(options);
end