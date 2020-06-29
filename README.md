[![View varargin2opt on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/69972-varargin2opt)

# varargin2opt
Varargin parser for Matlab

This function parses a content of a cell with `{key,value,...}` pairs (usually `varargin`) into an option with fields `opt.key = value`. It allows one to specify input specification and supply validator functions. This is a utility function based on Matlab's `inputParser`.

## Example

<!-- language-all: lang-matlab -->

The basic usage is inside of a function:

    function [...] = myLittleFunction(...,varargin)
    
    opt = varargin2opt(varargin)

With input specifications:

    spec = {'plot',false;'varbosity',false};
    opt = varargin2opt(varargin,spec);

And with input validation.

    spec = {'plot'     ,false  ,''    ;
            'wildcard' ,[]     ,'any';
            'lambda' ,[1,2,3],@(x) size(x,2)==3}
    opt = varargin2opt(varargin,spec);

Empty string (`''`) parses as: _'check that the class of the supplied argument is the same as that of the default value'_
