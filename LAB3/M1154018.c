#include<stdio.h>
#include<stdlib.h>
#include<string.h>

const char *number1 = "M1154018 許嘉和",*number2 = "M1154019 洪郁翔";

main()
{
    char first_array[30],second_array[30];

    printf("輸入第1數列:");
    gets(first_array);
    printf("輸入第2數列:");
    gets(second_array);
    
    int array_1[20],array_2[20]; //把數列 1 和數列 2 轉成整數陣列

    char *token;
    int top = -1; //切割時計算共有幾個整數，因為陣列的索引從 0 開始，遇到空白才加 1 所以初始值為 -1。
    int one_length,two_length;

    token = strtok(first_array, " "); //利用空白切割
    while(token != NULL) //轉成整數
    {
        top++;
        array_1[top] = atoi(token);

        token = strtok(NULL, " ");
    }
    one_length = top; //儲存整數陣列 1 的長度

    top = -1;
    token = strtok(second_array, " ");
    while(token != NULL)
    {
        top++;
        array_2[top] = atoi(token);

        token = strtok(NULL, " ");
    }
    two_length = top;
    
    int flag_1 = 0,flag_2 = 0; //用來判斷陣列的最後一個元素是不是一樣

    if(one_length == two_length) //如果兩個整數陣列的長度一樣
    {
        for(int i = 0 ; i <= one_length ; i++)
        {
            if(array_1[i] != array_2[i]) //如果有遇到同個索引但值不一樣的
            {
                printf("%d\n",i); //印出索引
                flag_1 = 1;
                break; //離開迴圈
            }
        }
        if(!flag_1) //如果直到最後一個元素都一樣
        {
            printf("%d\n",one_length); //就印出最後一個索引
        }
    }
    else
    {
        int length = one_length > two_length ? two_length : one_length; //長度不一樣就選擇比較短的那個
        for(int i = 0 ; i <= length ; i++)
        {
            if(array_1[i] != array_2[i])
            {
                printf("%d\n",i);
                flag_2 = 1;
                break;
            }
        }
        if(!flag_2)
        {
            printf("%d\n",length + 1); //如果直到短的那個整數陣列最後一個元素都是一樣，那麼印出的索引值就加 1。
        }
    }
    puts(number1);
    puts(number2);
}