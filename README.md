[![View varargin2opt on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/69972-varargin2opt)

<!-- language-all: lang-matlab -->

# varargin2opt <!-- omit in toc -->
Varargin parser for Matlab


This function parses a content of a cell with `{key,value,...}` pairs (usually `varargin`) into an option with fields `opt.key = value`. It allows one to specify input specification and supply validator functions. This is a utility function based on Matlab's `inputParser`.

## Usage

`c` is a cell of key-value pairs, where each key is a string

    > c = {'name','Lyra','age',14};
    > varargin2opt(c)
    ans = 
      struct with fields:
         age: 14
        name: 'Lyra'

`s` is an optional structure of expected keys and corresponding default values. Unmatched keys are discarded and a warning is thrown.

<pre><code>
&gt; s = {'name','Boris'};
&gt; varargin2opt(c,s)
<font style="color:#ff6400">Warning: Some options (age) were not matched to any pattern</font>
ans = 
  struct with fields:
    name: 'Lyra'
&gt; varargin2opt({},s)
ans = 
  struct with fields:
    name: 'Boris'
</code></pre>

### Validators

Additionally, validation functions can be added to `s`. Empty string (`''`) parses as: _'check that the class of the supplied argument is the same as that of the default value'_

    > s = {'name','Boris','';...
           'age',-1,@(x) x>0 & s<100};
    > varargin2opt(c,s) # No error

<pre><code>&gt; c = {'name','Lyra','age',114};
&gt; varargin2opt(c,s) # Too old
<span style="color:#e90000">Error using varargin2opt
The value of 'age' is invalid. It must satisfy the function: @(x)x&gt;0&x&lt;100.
Error in varargin2opt (line 104)
    parse(p,varargin{:});</span>
</code></pre>

<cr>

<pre><code>&gt; c = {'name',@std,'age',14};
&gt; varargin2opt(c,s) # Invalid name
<span style="color:red">Error using varargin2opt
The value of 'name' is invalid. It must satisfy the function: @(x)isa(x,class(default)).
Error in varargin2opt (line 104)
    parse(p,varargin{:});</span>
</code></pre>

But the default values are *not* checked.

    s = {'name','Boris','';...'age',};
         'age',-1,@(x) x>0 & s<100};
    varargin2opt({},s)
    ans = 
      struct with fields:
         age: -1
        name: 'Boris'

### Chaining

If the input to `varargin2opt` is a struct, it assumes that it is the desired `opt` structure and passes it along.

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

The input is then, however, not checked against the specifications(!).

    > s = {'name','Boris'};
    > varargin2opt(opt,s) # Does not warn
    ans = 
      struct with fields:
         age: 14
        name: 'Lyra'


### In a function

A typical usage of `varargin2opt` is inside of a function, as `varargin` parser:

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


## ToDo's

- [ ] Make chaining check the input against the specs and add other specification defaults.