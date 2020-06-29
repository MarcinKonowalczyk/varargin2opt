function handle_expected_exception(me,id)
% @( Exception, expected exception ID )
if ~isequal(me.identifier,id)
    fprintf('Uncaught exception\n');
    fail()
else
    pass()
end