#include <stdio.h>

int main() {
    printf("\nThe 9mul9 table:\n");
    
    // 外层循环：控制行数，从 9 递减到 1
    for (int i = 9; i >= 1; i--) {
        // 内层循环：控制每行的列数，从 1 递增到 i
        for (int j = 1; j <= i; j++) {
            // 输出格式：i*j=result，并加上制表符 \t 对齐
            printf("%d*%d=%d\t", i, j, i * j);
        }
        // 每行输出结束后换行
        printf("\n");
    }
    return 0;
}