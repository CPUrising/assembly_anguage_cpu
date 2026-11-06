#include <stdio.h>
char table[9][9] = {...};
int main() {
    for (int i = 1; i <= 9; i++)
        for (int j = 1; j <= 9; j++)
            if (table[i-1][j-1] != i * j)
                printf("%d %d     error\n", i, j);
    printf("accomplish!\n");
    return 0;
}