#include <stdio.h>

/*
 * 作业题目 5：递归调用
 * 用 C 语言实现斐波那契数列的递归求解，用于对照汇编实现并查看反汇编代码。
 *
 * F(0) = 0, F(1) = 1, F(n) = F(n-1) + F(n-2)
 *
 * 说明：这里是最直接的递归写法，重点在于观察编译器如何生成
 * 函数调用（call/ret）、栈帧建立与恢复、参数与返回值的传递。
 * 朴素递归为指数级复杂度，n 较大时运行时间很长；
 * 另外 long long 只能表示到 F(92)，更大的 n 会溢出。
 * 汇编版本使用十进制大数存储并加了记忆化，因此可以正确、快速地
 * 输出 1~100 的全部结果。
 */
long long fib(int n)
{
    if (n <= 1)
        return n;
    return fib(n - 1) + fib(n - 2);
}

int main(void)
{
    int n;

    printf("Please input n (1-100): ");
    if (scanf("%d", &n) != 1 || n < 1 || n > 100) {
        printf("Invalid input!\n");
        return 0;
    }

    printf("The Fibonacci number is: %lld\n", fib(n));
    return 0;
}
