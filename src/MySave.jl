"""
Module for saving and loading variables.

functions: savevar, loadvar, loadstr, fn_savevar

macros: @savevar, @loadvar, @loadstr, @savevarn, @loadvarn

variables: dir_savevar[], fnum[]

1) To save(load) variables to(from) the directory "./SAVEVAR/", set

julia> dir_savevar[]=SAVEVAR

The default save/load directory is the current one, "./".


2) To save(load) variables to(from)  numbered files, set, for example,

julia> fnum[]=3

and use @savevarn(@loadvarn). See also the helps for @savevarn and @loadvarn.
"""
module MySave


greet() = print("Hello My module for saving and loading files!")


"""
    savevar(fn, x)

saves the value of `x` to the file `fn`, where `fn` is the filename string of the file.
"""
savevar(fn, x) = write(fn, string(x))

"""
    loadvar(fn)

loads the file `fn` (the filename string of the file) and `Meta.parse |> eval`.
"""
loadvar(fn) = read(fn, String) |> Meta.parse |> eval

"""
    loadstr(fn)

loads the file `fn` (the filename string of the file) and `Meta.parse |> string`.
"""
#loadstr(fn) = read(fn, String) |> Meta.parse |> string
loadstr(fn) = read(fn, String)

"""
    dir_savevar[]

is the default directory to which `@savevar` saves the values of variables and from which `@loadvar` loads the saved file. Default directry is set to "." If one wants to save at "./DIR/", write

    dir_savevar[]="DIR"

"""
const dir_savevar = Ref(".")

"""
    fn_savevar(x::Symbol)
    fn_savevar(n::Base.RefValue{Int64},x::Symbol)

is the filename string to which `@savevar` saves the value of a variable.
"""
fn_savevar(x::Symbol) = joinpath(dir_savevar[], string(x) * ".txt")
fn_savevar(n::Base.RefValue{Int64},x::Symbol)=joinpath(dir_savevar[], string(x)*"_"*string(n[])*".txt")

"""
    @savevar(args...)

saves the variables in args to the corresponding textfiles.

Example: `@savevar A B C` saves the variables `A`, `B`, `C` to textfiles. 
The names of the files are `A.txt`, `B.txt`, `C.txt`.
"""
macro savevar(args...)
    A = [:(savevar($(fn_savevar(x)), $(esc(x)))) for x in args]
    quote $(A...); nothing end
end

"""
    @loadvar(args...)

loads the values from the textfiles corresponding to `args`.
If `length(args)` is greater than 1, then it returns the tuple of the values.

Example: `a, b, c = @loadvar A B C` loads 
the values in `A.txt`, `B.txt`, `C.txt` to the variables `a`, `b`, `c`.
"""
macro loadvar(args...)
    if length(args) == 1
        x = args[1]
        :(loadvar($(fn_savevar(x))))
    else
        A = [:(loadvar($(fn_savevar(x)))) for x in args]
        :(($(A...),))
    end
end

"""
    @loadstr(args...)

loads the values as Strings from the textfiles corresponding to `args`.
If `length(args)` is greater than 1, then it returns the tuple of the values.

Example: `a, b, c = @loadstr A B C` loads 
the data in `A.txt`, `B.txt`, `C.txt` as String to the variables `a`, `b`, `c`.
"""
macro loadstr(args...)
    if length(args) == 1
        x = args[1]
        :(loadstr($(fn_savevar(x))))
    else
        A = [:(loadstr($(fn_savevar(x)))) for x in args]
        :(($(A...),))
    end
end

"""
    fnum[]

is the integer number added to the file name in the @savevarn macro. 
Also is the file number loaded in the @loadvarn macro.
Default value is 0, but one can set other integer values, e.g., fnum[]=2.

Example 1: `fnum[]=3;@savevarn x y` saves the variables x and y in the files `x_3.txt` and `y_3.txt`.

Example 2: `fnum[]=3;X, Y=@loadvarn x y` load the values of x and y from the files `x_3.txt` and `y_3.txt`.
"""
   fnum=Ref(0)

"""
    @savevarn(args...)

saves the variables in args to the corresponding textfiles.

Example: `@savevarn A B C` saves the variables `A`, `B`, `C` to textfiles. 
The names of the files are `A_fnum[].txt`, `B_fnum[].txt`, `C_fnum[].txt`.
"""
macro savevarn(args...)
    A = [:(savevar($(fn_savevar(fnum,x)), $(esc(x)))) for x in args]
    quote $(A...); nothing end
end

"""
    @loadvarn(args...)

loads the values from the textfiles corresponding to `args`.
If `length(args)` is greater than 1, then it returns the tuple of the values.

Example: `a, b, c = @loadvar A B C` loads 
the values in `A_fnum[].txt`, `B_fnum[].txt`, `C_fnum[].txt` to the variables `a`, `b`, `c`.
"""
macro loadvarn(args...)
    if length(args) == 1
        x = args[1]
        :(loadvar($(fn_savevar(fnum,x))))
    else
        A = [:(loadvar($(fn_savevar(fnum,x)))) for x in args]
        :(($(A...),))
    end
end

end#module
