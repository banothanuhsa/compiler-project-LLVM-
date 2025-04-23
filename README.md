# compiler-project-LLVM-
This project builds a simple intermediate code generator for a toy programming language
by using commands --------
Generate ll file
-----------------
clang -S -emit-llvm test.c 

Generate bit code
-----------------
llvm-as test.ll -o test.bc

Generate executable
--------------------
clang test.bc -o out

Run the interpreter
-------------------
lli test.ll
