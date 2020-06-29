clear; clc;

global failed;
failed = false;

II = 'varargin2opt:invalidinput';

%% Just a cell without specifications
fprintf('Just a cell without specifications\n');
c = {'name','Lyra','age',14};
t.name = 'Lyra'; t.age = 14;    
try
    opt = varargin2opt(c);
    assert(isequal(opt,t),'Invalid result');
    pass();
catch me
    exit_message(me);
    fail();
end

%% Empty cell without specifications
fprintf('Empty cell without specifications\n');
c = {}; t = struct();
try
    opt = varargin2opt(c);
    assert(isequal(opt,t),'Invalid result');
    pass()
catch me
    exit_message(me)
    fail()
end

%% Keys must be character arrays
fprintf('Keys must be character arrays\n');
c = {'name','Lyra',[1,2,3],14};
try
    opt = varargin2opt(c);
    fail()
catch me
    exit_message(me)
    handle_expected_exception(me,II)
end

%% Keys must be of even length
fprintf('Keys must be of even length\n');
c = {'name','Lyra','name'};
try
    opt = varargin2opt(c);
    fail()
catch me
    exit_message(me)
    handle_expected_exception(me,II)
end

%% Cell with specifications, but no validator
fprintf('Cell with specifications, but no validator\n');
c = {'name','Lyra','age',14};
s = {'name','Boris'};
t = struct(); t.name = 'Lyra';
UO = 'varargin2opt:unmatchedOptions'; % Warning ID
try
    out = varargin2opt(c,s);
    assert(isequal(out,t),'Invalid result');
    warning('error',UO); %#ok<CTPCT> % Make unmatchedOptions an error
    varargin2opt(c,s);
    fail()
catch me
    exit_message(me)
    handle_expected_exception(me,UO)
end
warning('on','varargin2opt:unmatchedOptions'); % Restore warning status

%% By default, specified name must be of the same type
fprintf('By default, specified name must be of the same type\n');
c = {'name','Lyra'};
s = {'name',999};
try
    out = varargin2opt(c,s);
    fail()
catch me
    exit_message(me)
    handle_expected_exception(me,II);
end

%% Cell with specifications and validators
fprintf('Cell with specifications and validators\n');
c = {'name','Lyra','age',14};
s = {'name','Boris','';
     'age',-1,@(x)x>0&&x<50};
t = struct(); t.name = 'Lyra'; t.age = 14;
try
    out = varargin2opt(c,s);
    assert(isequal(out,t),'Invalid result');
    pass()
catch me
    exit_message(me)
    fail();
end

%% Pass in invalid input
fprintf('Pass in invalid input\n');
c = {'name','Lyra','age',98};
s = {'name','Boris','';
     'age',-1,@(x)x>0&&x<50};
try
    out = varargin2opt(c,s);
    fail()
catch me
    exit_message(me)
    handle_expected_exception(me,II);
end

%% Accept any name...
fprintf('Accept any name...\n');
c = {'name',@mean,'age',14};
s = {'name','Boris','any';
     'age',-1,''};
t = struct(); t.name = @mean; t.age = 14;
try
    out = varargin2opt(c,s);
    assert(isequal(out,t),'Invalid result');
    pass()
catch me
    exit_message(me)
    fail()
end


%% ...but fail when the class does not match
fprintf('...but fail when the class does not match\n');
c = {'name',@mean,'age',@std};
s = {'name','Boris','any';
     'age',-1,''};
try
    out = varargin2opt(c,s);
    assert(isequal(out,t),'Invalid result');
    fail()
catch me
    exit_message(me)
    handle_expected_exception(me,II)
end

%% Warn about multiple matches
fprintf('Warn about multiple matches\n');
c = {'name','Lyra','age',14,'name','Pantalaimon'};
s = {'name','Boris','any';
     'age',-1,''};
t = struct(); t.name = 'Pantalaimon'; t.age = 14;
MM = 'varargin2opt:mulipleMatch';

try
    out = varargin2opt(c,s);
    assert(isequal(out,t),'Invalid result');
    warning('error',MM); %#ok<CTPCT> % Turn multipleMatch into an error
    varargin2opt(c,s);
    fail()
catch me
    exit_message(me)
    handle_expected_exception(me,MM);
end
warning('on',MM); % Restore warning status

%% Test chaining
fprintf('Test chaining\n');
try
    c = {'name','Lyra','age',14};
    out = varargin2opt(c);
    out2 = varargin2opt(out);
    assert(isequal(out2,out),'Invalid result');
    pass()
catch me
    exit_message(me)
    fail()
end  

%% Throw an error is any of the tests failed
if failed
    error('Some tests failed')
end
