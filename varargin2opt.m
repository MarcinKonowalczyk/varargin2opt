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
W = warning('off','backtrace'); % Turn off warning backtrace
cleaner = onCleanup(@()warning(W)); % Return warnings to preious state

%% Unpack the actuall `varargin` and input specifications
if nargin>=2
    specs = varargin{2};
else
    specs = {};
end
varargin = varargin{1};

% Check special case for chaining: opt = varargin2opt(varargin2opt(...))
if isstruct(varargin)
    % Assume that varargin{1} is the options structure
    options = varargin;
    return
else
    options = struct();
end

% Check varargin
assert(isa(varargin,'cell'),II,'Invalid ''varargin''. Must be a cell');
N = numel(varargin);
if N==0, return, end
assert(~mod(N,2),II,'Invalid ''varargin''. Must have even length');

%% Check specs
if ~isempty(specs)
    assert(isa(specs,'cell'),II,'Invalid specifications. Must be a cell.');
    s = size(specs,2);
    assert(s==2 || s==3,II,'Invalid specifications. Must be Nx2 or Nx3.');
    if s==2 % Add the third default entry to specs
        for Si = 1:size(specs,1)
            specs{Si,3} = '';
        end
    end
    for Si = 1:size(specs,1)
        [name, ~, valid] = deal(specs{Si,:});
        assert(ischar(name),II,...
            'Specs key is of class ''%s'' as opposed to ''char''',class(name));
        assert(strcmp(valid,'')||strcmp(valid,'any')||isa(valid,'function_handle'),II,...
            'Invalid validation function specified. Must be '''', ''any'' or a funciton handle.');
    end
    for Si = 1:size(specs,1) % Add a 4th collumn which marks whether entry has been matched
        specs{Si,4} = false;
    end
end

%% Parse options
for Ni = 1:(N/2)
    key = varargin{2*(Ni-1)+1};
    assert(ischar(key),II,'Varargin key of class ''%s'' as opposed to ''char''',class(key));
    key = makeValidName(key);
    value = varargin{2*Ni};
    if isempty(specs)
        options.(key) = value; % Just assign value to the key
    else % Validate the key against the specifications
        unmatched = true;
        % Try to match for each specification
        for Si = 1:size(specs,1)
            [name, default, valid, matched] = deal(specs{Si,:});
            if strcmp(name,key)
                unmatched = false;
                break
            end
        end
        % Warn if unmatched
        if unmatched
            warning('varargin2opt:unmatchedOptions',...
                'Unmatched option ''%s''. This option will be discarded.',key);
        else
            if matched
                text = sprintf('Option ''%s'' was matched multiple times. Only the most recent match will be left.',name);
                warning('varargin2opt:mulipleMatch',text) %#ok<SPWRN>
            elseif isa(valid,'function_handle') % Validator supplied
                assert(valid(value),II,...
                    'The value of ''%s'' is invalid. It must satisfy the funcion: %s',key,func2str(valid));
            elseif strcmpi(valid,'any') % Accept any parameter
            elseif isempty(valid) % Input of the came class as default
                assert(isa(value,class(default)),II,...
                    'The value of ''%s'' is invalid. It must be of class ''%s'' as opposed to ''%s''',key,class(default),class(value));
            else
                error('This should never happen')
            end
            options.(key) = value;
            specs{Si,4} = true; % Mark as matched
        end
    end
end

% Add Unspecified options
if ~isempty(specs)
    for Si = 1:size(specs,1)
        [name, default, ~, matched] = deal(specs{Si,:});
        if ~matched
            key = makeValidName(name);
            options.(key)=default;
        end
    end
end

options = orderfields(options); % Ordeer fields alphabetically

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