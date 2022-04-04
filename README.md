# MySave
Package for saving and loading files.

 #Copyright (c) 2021 Ryuichi Okamoto <ryubee@gmail.com>
Licence: https://opensource.org/licenses/MIT
New macros, @savevarn, @loadvarn, and @loadstr have been added to Gen Kuroki's MySave.jl in <https://github.com/genkuroki/MyUtils.jl.git>

Copyright (c) 2021 Gen Kuroki
Licence: https://opensource.org/licenses/MIT

## Usage
# dir_savevar[ ]
This variable specifies the directory to which the macro @savevar/@savevarn saves files. The macro @loadvar/@loadvarn also loads files from this directory.
Its default value is "."; that is, the macros save to (or, load from) the current directory "./". To change the directory to, for example, "./DIR/", execute
```sh
julia> dir_savevar[]="DIR"
```


# @savevar
This is a macro for saving variables. 

Example:
```sh
julia> a=1.0;b=2;c=[1.3,1.8]
julia> @savevar a b c
```
The values of a, b, and c are saved to the files "a.txt", "b.txt", and "c.txt", respectively.

# @loadvar
This is a macro for loading files.

Example:
```sh
julia> A,B,C=@loadvar a b c
```
The values in the files "a.txt", "b.txt", and "c.txt" are loaded respectively to the variables A, B, and C. Hence
```sh
julia> a=1.2;b=[4,9]
julia> @savevar a b
julia> A,B=@loadvar a b
julia> (A,B)==(a,b)
true #same values
julia> (A,B)===(a,b)
false #different variables
```

# @loadstr
This is macro for loading data as String.

Example:
```sh
julia> A,B=@loadstr a b
```
The values in the files "a.txt" and "b.txt" are loaded to the variables A and B, respectively as String. Hence,

```sh
julia> a=4.0
julia> @savevar a
julia> A=@loadstr a
julia> A
"4.0"
julia> typeof(A)
String
```

This macro is convenient, for example, to save and load expressions of SymPy.jl, for which @loadvar cannot be used in local scope.
```sh
julia> using SymPy
julia> @vars a b c
julia> x=a+b+c
julia> @savevar x
julia> Xst=@loadstr x
julia> typeof(Xst)
String
julia> Xst
"a+b+c"
julia> X=sympify(Xst) #converting strings into SymPy expression
julia> X
a+b+c
julia> X==x
true
```


# @savevarn
This macro is the same as @savevar except that @savevarn adds the integer number to the filename. 
Specify the integer as the first argument:
```sh
julia> a=1.2;b=5
julia> @savevarn 1 a b
```
Then the values of a and b are saved to "a_1.txt" and "b_1.txt", respectively. One can instead do the following to get the same result:
```sh
julia> a=1.2;b=5;n=1
julia> @savevarn n a b
```


# @loadvarn
This is the macro conjugate to @savevarn. That is, for example, "B=@loadvarn 5 a" loads the value in the file "a_5.txt" to the variable B.

Example:
```sh
julia> a=1.2;b=5
julia> @savevarn 3 a b
julia> A,B=@loadvarn 3 a b
julia> (A,B)==(a,b)
true #same values
julia> (A,B)===(a,b)
false #different variables
```
One can instead do the following to get the same result:
```sh
julia> a=1.2;b=5
julia> @savevarn 3 a b 
julia> n=3
julia> A,B=@loadvarn n a b
julia> (A,B)==(a,b)
true #same values
julia> (A,B)===(a,b)
false #different variables
```
