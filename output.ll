define i32 @main() #0
{
%1 = alloca i32, align 4
%2 = alloca i32, align 4
%3 = alloca i32, align 4
%4 = alloca i32, align 4
%5 = add i32 0, 1
store i32 %5, i32* %1, align 4
%6 = add i32 0, 2
store i32 %6, i32* %2, align 4
%7 = add i32 0, 7
store i32 %7, i32* %3, align 4
%8 = load i32, i32* %1, align 4
%9 = load i32, i32* %2, align 4
%10 = add i32 0, 2
%11 = mul nsw i32 %9, %10
%12 = add nsw i32 %8, %11
store i32 %12, i32* %4, align 4
ret i32 0
ret i32 0

}