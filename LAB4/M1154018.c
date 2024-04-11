#include<stdio.h>
#include<sys/sysctl.h>

//Union 所有成員共用一個記憶體空間
typedef union
{
  unsigned long long l;
  unsigned char str[4];
}endian;

char *first_member = "M1154018 許嘉和", *second_member = "M1154019 洪郁翔";

main()
{
    char modelName[256];
    size_t size = sizeof(modelName);
    sysctlbyname("machdep.cpu.brand_string", &modelName, &size, NULL, 0); //取得CPU型號
    printf("%s 是 ", modelName);

    endian data;
    data.l = 0x12345678;
    if(data.str[0] == 0x78 && data.str[1] == 0x56 && data.str[2] == 0x34 && data.str[3] == 0x12) //如果低記憶體位址放的是低位元組的資料
    {
        puts("Little Endiann");
    }
    else if(data.str[0] == 0x12 && data.str[1] == 0x34 && data.str[2] == 0x56 && data.str[3] == 0x78)  //如果低記憶體位址放的是高位元組的資料
    {
        puts("Big Endiann");
    }
    else
    {
        puts("Unknown Endiann");
    }
    puts(first_member);
    puts(second_member);
}