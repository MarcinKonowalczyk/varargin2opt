function test_varargin2opt()

% Go to parent folder
% [path,~,~] = fileparts(fileparts(mfilename('fullpath')));
% old = cd(path);
% cleaner = onCleanup(@()cd(old)); % Return to this folder on cleanup


fprintf('Test basic functionality\n');

c = {'name','Lyra','age',14};
opt = varargin2opt(c);
disp(opt);

s = {'name','Boris'};
opt = varargin2opt(c,s);
% Warning: Some options (age) were not matched to any pattern
disp(opt);

opt = varargin2opt({},s);
disp(opt);

fprintf('Test validators\n');

s = {'name','Boris','';...
       'age',-1,@(x) x>0 && x<100};
opt = varargin2opt(c,s); % No error
disp(opt);

end