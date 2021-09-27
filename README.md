# MySave
Package for saving and loading files.

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

# @savevarn
This macro is the same as @savevar except that @savevarn adds the integer number fnum[] to the filename. 

Example:
```sh
julia> fnum[]=3
julia> a=1.2;b=5
julia> @savevarn a b
```
Then the values of a and b are saved to "a_3.txt" and "b_3.txt", respectively.

# @loadvarn
This is the macro conjugate to @savevarn. That is, if fnum[]=5, for example, "B=@loadvarn a" loads the value in the file "a_5.txt" to the variable B.

Example:
```sh
julia> fnum[]=3
julia> a=1.2;b=5
julia> @savevarn a b
julia> A,B=@loadvarn a b
julia> (A,B)==(a,b)
true #same values
julia> (A,B)===(a,b)
false #different variables
```

# fnum[ ]
The integer number added to the file name by @savevarn. Its default value is 0.
