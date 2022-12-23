#Copyright (c) 2021 Ryuichi Okamoto <ryubee@gmail.com>
#License: https://opensource.org/licenses/MIT
#New macros, @savevarn, @loadvarn, and @loadstr have been added to Gen Kuroki's MySave.jl in <https://github.com/genkuroki/MyUtils.jl.git>

#Copyright (c) 2021 Gen Kuroki
#License: https://opensource.org/licenses/MIT

"""
Module for saving and loading variables.

functions: readff,savevar, loadvar, loadstr, fn_savevar

macros: @savevar, @loadvar, @loadstr, @savevarn, @loadvarn

variables: dir_savevar[]

To save(load) variables to(from) the directory "./SAVEVAR/", set

julia> dir_savevar[]=SAVEVAR

The default save/load directory is the current one, "./".

"""
module MySave

greeting() = print("Hello My module for saving and loading files!")

"""
    readff("fn"::String, nc::Int)

Read numerical data in a file named ``fn``.  The variable ``nc::Int`` is the column number of the data. The output is a two dimensional array ``Array{Float64,2}`` whose column number is ``nc``. The lines that begin with #, @, or " in the file are ignored.
"""
function readff(file,nc)
    fn=joinpath(dir_savevar[], file)
    fr=open(fn,"r")
    N=0
    while !eof(fr)
        line=readline(fr)
        if(sizeof(line)!=0)
            if(line[1][1]!='#' && line[1][1]!='@' && line[1][1]!='"')
                N=N+1
            end
        end
    end
    close(fr)

    fn=joinpath(dir_savevar[], file)
    fr=open(fn,"r")
    data=Array{Float64}(undef,N,nc)
    rl=Array{Float64}(undef,1, nc)
    i=1
    while !eof(fr)
        line=readline(fr)
        s=split(line)
        if(sizeof(s)!=0)
            if(s[1][1]!='#' && s[1][1]!='@' && s[1][1]!='"')
                for i in 1:nc
                    rl[i]=parse(Float64,s[i])
                end
                data[i,:] = rl
                i=i+1
            end
        end
    end
    close(fr)
    data
end

# This original code is extremely slow (for a large data file) due to huge memory allocation as calling vcat many times.
# function readff(file,nc)
#     fn=joinpath(dir_savevar[], file)
#     fr=open(fn,"r")
#     data=Array{Float64}(undef,0,nc)
#     rl=Array{Float64}(undef,1, nc)
#     while !eof(fr)
#         line=readline(fr)
#         s=split(line)
#         if(sizeof(s)!=0)
#             if(s[1][1]!='#' && s[1][1]!='@' && s[1][1]!='"')
#                 for i in 1:nc
#                     rl[i]=parse(Float64,s[i])
#                 end
#                 data=vcat(data,rl)
#             end
#         end
#     end
#     close(fr)
#     data
# end



"""
    savevar(fn, x)

saves the value of `x` to the file `fn`, where `fn` is the filename string of the file.
"""
savevar(fn, x) = write(fn, string(x))

"""
    savevar_num(n::Int64, x, xstr::String)

saves the value of `x` to the file `xstr_n.txt`.
"""
function savevar_num(n::Int64,x,xstr::String)  
    fn=joinpath(dir_savevar[], xstr*"_"*string(n)*".txt")
    savevar(fn, x)
    nothing
end

"""
    xstrng(xsym::Symbol)

transforms the Symbol `xsym` to a String.
"""
function xstrng(xsym::Symbol)
    string(xsym)
end

"""
    loadvar(fn)

loads the file `fn` (the filename string of the file) and `Meta.parse |> eval`.
"""
loadvar(fn) = read(fn, String) |> Meta.parse |> eval

"""
    loadvar_num(n::Int64,xstr::String)

loads the file `xstr_n.txt` and `Meta.parse |> eval`.
"""
function loadvar_num(n::Int64,xstr::String)  
    fn=joinpath(dir_savevar[], xstr*"_"*string(n)*".txt")
    loadvar(fn)
end

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
#fn_savevar(n::Base.RefValue{Int64},x::Symbol)=joinpath(dir_savevar[], string(x)*"_"*string(n[])*".txt")
#fn_savevar(n::Symbol,x::Symbol)=joinpath(dir_savevar[], string(x)*"_"*string(n)*".txt")
#fn_savevar(n::Base.RefValue{Int64},x::Symbol)=joinpath(dir_savevar[], string(x)*"_"*string(n[])*".txt")
#fn_savevar(n::Int64,x::Symbol)=joinpath(dir_savevar[], string(x)*"_"*string(n)*".txt")


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
    @savevarn(fnum::Int64, args...)

saves the variables in args to the corresponding textfiles.

Example: `@savevarn fnum A B C` saves the variables `A`, `B`, `C` to textfiles, where fnum is an integer that appears in the file name; the names of the files are `A_fnum.txt`, `B_fnum.txt`, `C_fnum.txt`. 
"""
macro savevarn(fnum,args...)
    #A = [quote savevar($(fn_savevar(Ref(fnum),x)), $(esc(x))) end for x in args]
    A = [quote savevar_num($(esc(fnum)), $(esc(x)), $(xstrng(x))) end for x in args]
    
   # A = [quote fnumV=$fnum;savevar($(fn_savevar(fnumV,x)), $(esc(x))) end for x in args]
    
    #A = [:(savevar($(fn_savevar(fnum,x)), $(esc(x)))) for x in args]
    quote $(A...); nothing end
end

"""
    @loadvarn(fnum::Int64,args...)

loads the values from the textfiles corresponding to `args`.
If `length(args)` is greater than 1, then it returns the tuple of the values.

Example: `a, b, c = @loadvar fnum A B C` loads 
the values in `A_fnum.txt`, `B_fnum.txt`, `C_fnum.txt` to the variables `a`, `b`, `c`.
"""
macro loadvarn(fnum, args...)
    
    # if length(args) == 1
    #     x = args[1]
    #     :(loadvar($(fn_savevar(fnum,x))))
    # else
    #     A = [:(loadvar($(fn_savevar(fnum,x)))) for x in args]
    #     :(($(A...),))
    # end

    if length(args) == 1
        x = args[1]
        :(loadvar_num($(esc(fnum)), $(xstrng(x))))
    else
        A = [:(loadvar_num($(esc(fnum)), $(xstrng(x)))) for x in args]
        :(($(A...),))
    end
end

end#module
