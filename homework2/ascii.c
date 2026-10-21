#include <stdio.h>

int main() {
    char ch = 'a';  // 从 'a' 开始
    int i, j;

    for (i = 0; i < 2; i++) {        // 外层循环：2 行
        for (j = 0; j < 13; j++) {   // 内层循环：13 个字符
            printf("%c ", ch);       // 打印字符和空格
            ch++;                    // 字符递增
        }
        printf("\n");                // 换行
    }
    return 0;
}