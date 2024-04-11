#include<stdio.h>
#include<stdlib.h>
#include<stdbool.h> 
#include<string.h>
#define LENGTH 20 //字串長度

int GCD(int,int); //找出最大公因數

main()
{
    int a,b; //輸入的兩個自然數
    char str[LENGTH], *delim; //因為兩個自然數中間用空格隔開所以要以字串的型態輸入，並用空格作為分隔符切割字串。
    bool first_flag = true,second_flag = true; //用來控制能不能轉成整數型態存到自然數變數，第一個切割的字串存在第一個整數 a，存入後這個整數就不能再更動。
    printf("Enter the values of a and b:");
    fgets(str,LENGTH,stdin);
    delim = strtok(str," ");
    while(delim != NULL)
    {
        if(first_flag) //一定要用 if...else if...else，不然兩個變數都會被存到。
        {
            a = atoi(delim);
            first_flag = false;
            delim = strtok(NULL," ");
        }
        else if(second_flag)
        {
            b = atoi(delim);
            second_flag = false;
            delim = strtok(NULL," ");
        }
        else //如果輸入好幾個數，或第二個自然數後面還接一個空格，只會取前兩個自然數。
        {
            break;
        }
    }
    printf("The GCD of a and b is %d\n",GCD(a,b));
}

int GCD(int a,int b) //輾轉相除法
{
    if(a == 0)
    {
        return b;
    }
    else if(b == 0)
    {
        return a;
    }
    else
    {
        if(a > b)
        {
            return GCD(a % b,b);
        }
        else
        {
            return GCD(a,b % a);
        }
    }
}