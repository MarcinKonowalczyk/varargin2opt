[![View varargin2opt on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/69972-varargin2opt)

<!-- language-all: lang-matlab -->

# varargin2opt <!-- omit in toc -->
Varargin parser for Matlab


This function parses a content of a cell with `{key,value,...}` pairs (usually `varargin`) into an option with fields `opt.key = value`. It allows one to specify input specification and supply validator functions. This is a utility function based on Matlab's `inputParser`.

## Usage

`c` is a cell of key-value pairs, where each key is a string

```matlab
> c = {'name','Lyra','age',14};
> varargin2opt(c)
ans = 
  struct with fields:
     age: 14
    name: 'Lyra'
```

`s` is an optional structure of expected keys and corresponding default values. Unmatched keys are discarded and a warning is thrown.

```matlab
> s = {'name','Boris'};
> varargin2opt(c,s)
Warning: Some options (age) were not matched to any pattern
ans = 
  struct with fields:
    name: 'Lyra'
> varargin2opt({},s)
ans = 
  struct with fields:
    name: 'Boris'
```

### Validators

Additionally, validation functions can be added to `s`. Empty string (`''`) parses as: _'check that the class of the supplied argument is the same as that of the default value'_

```matlab
> s = {'name','Boris','';...
       'age',-1,@(x) x>0 && x<100};
> varargin2opt(c,s) # No error
```

```matlab
> c = {'name','Lyra','age',114};
> varargin2opt(c,s) # Too old
Error using varargin2opt
The value of 'age' is invalid. It must satisfy the function: @(x)x&gt;0&x&lt;100.
Error in varargin2opt (line 104)
    parse(p,varargin{:});
```

```matlab
> c = {'name',@std,'age',14};
> varargin2opt(c,s) # Invalid name
Error using varargin2opt
The value of 'name' is invalid. It must satisfy the function: @(x)isa(x,class(default)).
Error in varargin2opt (line 104)
    parse(p,varargin{:});
```

But the default values are *not* checked.

```matlab
s = {'name','Boris','';
     'age',-1,@(x) x>0 && x<100};
varargin2opt({},s)
ans = 
  struct with fields:
     age: -1
    name: 'Boris'
```

The specification of `'any'` means that any input for that particular key is accepted.

```matlab
s = {'name','Boris','any';
     'age',-1,@(x) x>0 && x<100};
c = {'name',@std,'age',14};
varargin2opt({},s)
ans = 
  struct with fields:
     age: 14
    name: @std
```

### Chaining

If the input to `varargin2opt` is a struct, it assumes that it is the desired `opt` structure and passes it along.

```matlab
> c = {'name','Lyra','age',14};
> opt = varargin2opt(c)
ans = 
  struct with fields:
     age: 14
    name: 'Lyra'
> varargin2opt(opt)
ans = 
  struct with fields:
     age: 14
    name: 'Lyra'
```

The input is then, however, not checked against the specifications(!).

```matlab
> s = {'name','Boris',@(x)strcmp(x,'Boris')};
> varargin2opt(opt,s)
ans = 
  struct with fields:
     age: 14
    name: 'Lyra'
```

### In a function

A typical usage of `varargin2opt` is inside of a function, as `varargin` parser:

```matlab
function [...] = myLittleFunction(...,varargin)
% Docstring ...

opt = varargin2opt(varargin)

%(...)

end
```

With input specifications:

```matlab
spec = {'plot',false;'varbosity',false};
opt = varargin2opt(varargin,spec);
```

And with input validation.

```matlab
spec = {'plot'     ,false  ,''    ;
        'wildcard' ,[]     ,'any';
        'lambda' ,[1,2,3],@(x) size(x,2)==3}
opt = varargin2opt(varargin,spec);
```

Empty string (`''`) parses as: _'check that the class of the supplied argument is the same as that of the default value'_


## ToDo's

- [ ] Make chaining check the input against the specs and add other specification defaults.