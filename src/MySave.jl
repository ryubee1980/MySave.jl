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
    dir_savevar[]

is the default directory to which `@savevar` saves the values of variables and from which `@loadvar` loads the saved file. Default directry is set to "." If one wants to save at "./DIR/", write

    dir_savevar[]="DIR"

"""
const dir_savevar = Ref(".")

"""
    fn_savevar(x::Symbol)
    fn_savevar(n::Int64,x::Symbol)

is the filename string to which `@savevar` saves the value of a variable.
"""
fn_savevar(x::Symbol) = joinpath(dir_savevar[], string(x) * ".txt")
fn_savevar(n::Int64,x::Symbol)=joinpath(dir_savevar[], string(x)*"_"*string(n)*".txt")

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
the values of `A`, `B`, `C` in textfiles to the variables `a`, `b`, `c`.
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
    file_num

is the integer number added to the file name in the @savevarn macro. 
Also is the number of file loaded in the @loadvarn macro

Example 1: `file_num=3;@savevarn x y` saves the variables x and y in the files `x_3.txt` and `y_3.txt`.

Example 2: `file_num=3;X, Y=@loadvarn x y` load the values of x and y from the files `x_3.txt` and `y_3.txt`.
"""
fnum=Ref(0)

"""
    @savevarn(file_num, args...)

saves the variables in args to the corresponding textfiles.

Example: `@savevarn A B C` saves the variables `A`, `B`, `C` to textfiles. 
The names of the files are `A_$(fnum).txt`, `B_$(fnum).txt`, `C_$(fnum).txt`.
"""
macro savevarn(args...)
    A = [:(savevar($(fn_savevar(fnum,x)), $(esc(x)))) for x in args]
    quote $(A...); nothing end
end

end#module
