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
W = warning('off','backtrace'); % Turn
cleaner = onCleanup(@()warning(W)); % Return warnings to preious state

%% Just the 'varargin'
if nargin == 1
    varargin = varargin{1};
    
    % Check special (fast) case
    if isstruct(varargin)
        % Assume that varargin{1} is the options structure and immediatelly return
        options = varargin;
        return
    end
    
    % Check varargin
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
            options.(makeValidName(key)) = value;
        end
    end
    
    %% 'varargin' and input specifications
else
    varargin_temp = varargin{1};
    
    % Check special (fast) case
    if isstruct(varargin_temp)
        % Assume that varargin{1} is the options structure and immediatelly return
        options = varargin_temp;
        return
    end
    
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
    varargin = varargin_temp;
    assert(isa(varargin,'cell'),II,'Invalid ''varargin''. Must be a cell');
    assert(~mod(numel(varargin),2),II,'Invalid ''varargin''. Must have even length');
    
    % Create input parser
    p = inputParser;
    p.CaseSensitive = false;
    p.FunctionName = mfilename;
    p.KeepUnmatched = true;
    p.PartialMatching = false;
    p.StructExpand = false;
    
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

function key = makeValidName(key)
% Substitute for 'key = matlab.lang.makeValidName(key);'
%
% Written by Marcin Konowalczyk
% Timmel Group @ Oxford University

%% Special case of an empty string
if numel(key)==0
    key = 'x';
    return
end

%% Replace all the invalid characters with underscores
valid = ['0':'9' 'A':'Z' 'a':'z' '_'];
isvalid = @(x)any(arrayfun(@(y)strcmp(x,y),valid));

new_key = '';
eaten_space = false;
for j = 1:numel(key)
    ch = key(j);
    if ~isvalid(ch)
        if strcmp(ch,' ')
            eaten_space = true;
        else
            new_key(end+1) = '_';
        end
    elseif eaten_space
        new_key(end+1) = upper(ch);
        eaten_space = false;
    else
        new_key(end+1) = ch;
    end
end
key = new_key;

%% Add leading pad character if starting with a number
if any(arrayfun(@(x)x==key(1),['0':'9' '_']))
    key = ['x' key];
end

%% Trim to 63 characters
if numel(key)>63
    key = key(1:63);
end
end