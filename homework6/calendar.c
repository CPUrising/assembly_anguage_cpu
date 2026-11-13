#include <stdio.h>

/*
 * 作业题目 6：输出日历（C 语言对照实现）
 *
 * 与 calendar.asm 的功能和算法一一对应：
 *   days_in_month()  <-> CALC_MONTH_DAYS
 *   first_weekday()  <-> CALC_FIRST_DAY
 *   print_month()    <-> PRINT_CALENDAR
 *
 * 汇编版把功能封装成 FAR 过程，分别用寄存器、数据段、堆栈传参；
 * C 版由编译器统一用栈/寄存器传参，可对比反汇编观察调用约定。
 *
 * 编译：gcc -O0 calendar.c -o calendar_c.exe
 */

static const char *month_names[12] = {
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
};

/* 平年各月天数 */
static const int day_tab[12] = {
    31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
};

/* 平年时某月之前累计的天数 */
static const int acc_tab[12] = {
    0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334
};

/* 1900~2099 范围内：能被 4 整除且不是 1900 的年份是闰年 */
int is_leap(int y)
{
    return (y % 4 == 0 && y != 1900);
}

int days_in_month(int y, int m)
{
    int d = day_tab[m - 1];

    if (m == 2 && is_leap(y))
        d = 29;
    return d;
}

/* 以 1900-01-01 是星期一为基准，返回 0~6（0 = 周日） */
int first_weekday(int y, int m)
{
    int days;

    days = 365 * (y - 1900) + ((y - 1) / 4 - 475) + acc_tab[m - 1];
    if (m > 2 && is_leap(y))
        days++;
    return (days + 1) % 7;
}

void print_month(int y, int m)
{
    int d;
    int w;              /* 当前列，0 = 周日 ... 6 = 周六 */

    printf("%d  %s\n", y, month_names[m - 1]);
    printf("Su Mo Tu We Th Fr Sa\n");

    w = first_weekday(y, m);
    for (d = 0; d < w; d++)
        printf("   ");                  /* 每个空位占 3 列 */

    for (d = 1; d <= days_in_month(y, m); d++) {
        printf("%2d ", d);              /* 每个日期占 3 列 */
        if (++w == 7) {
            w = 0;
            printf("\n");
        }
    }
    if (w != 0)
        printf("\n");
}

int main(void)
{
    int y, m;

    printf("Please input year (1900-2099): ");
    if (scanf("%d", &y) != 1 || y < 1900 || y > 2099) {
        printf("Invalid input!\n");
        return 0;
    }

    printf("Please input month (1-12): ");
    if (scanf("%d", &m) != 1 || m < 1 || m > 12) {
        printf("Invalid input!\n");
        return 0;
    }

    printf("\n");
    print_month(y, m);
    return 0;
}
