#include <stdio.h>

int main(void)
{
    int n, i, sum = 0;

    printf("Please input N (1-100): ");
    scanf("%d", &n);

    for (i = 1; i <= n; i++) {
        sum += i;
    }

    printf("The sum is: %d\n", sum);
    return 0;
}