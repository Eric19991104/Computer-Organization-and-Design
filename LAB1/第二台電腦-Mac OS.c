#include<stdio.h>
#include<stdlib.h>
#include<sys/sysctl.h>
#include<sys/time.h>
#include<math.h>

// 定義RDTSC指令，計算記憶體存取的時間用。
static __inline__ uint64_t rdtsc(void) 
{
    unsigned int lo, hi;
    __asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
    return ((uint64_t)hi << 32) | lo;
}

size_t size;
int mib[2] = {CTL_HW,HW_MEMSIZE}; // 取得主記憶體大小及 CPU 時脈頻率用

main()
{
    int ch; // 選項
    printf("%s","[1]ALU Computer Time [2]記憶體存取 Computer Time:");
    scanf("%d",&ch);

    /*int cpuCount;
    size_t size = sizeof(cpuCount);
    sysctlbyname("hw.physicalcpu", &cpuCount, &size, NULL, 0); // 取得CPU核心數量
    printf("Number of CPU cores: %d\n", cpuCount);*/

    char modelName[128];
    size = sizeof(modelName);
    sysctlbyname("machdep.cpu.brand_string", &modelName, &size, NULL, 0); // 取得CPU型號
    printf("CPU 型號: %s\n", modelName);

    uint64_t memSize;
    size = sizeof(memSize);
    if (sysctl(mib, 2, &memSize, &size, NULL, 0) == 0) // 取得主記憶體大小
    {
        printf("Main Memory Size: %.2f Gbytes\n", memSize / pow(2,30));
    } else 
    {
        printf("Failed to get memory size\n");
    }

    uint64_t cpuFreq;
    size = sizeof(cpuFreq);
    if (sysctl(mib, 2, &cpuFreq, &size, NULL, 0) == 0) // 取得CPU時脈頻率
    {
        printf("CPU frequency: %.2f GHz\n", cpuFreq / pow(2,30));
    } else 
    {
        printf("Failed to get CPU frequency\n");
    }

    double elapsedTime; // 計算時間差
    struct timeval start, end; // 計算 ALU Computer Time 用
    uint64_t Start, End; // 計算記憶體存取 Computer Time 用
    int *array;
    switch(ch)
    {
        case 1:
            gettimeofday(&start, NULL); // 開始測量時間
            int a = 1234;
            int b = 5678;
            for (int i = 0; i < (int)pow(2,30); i++) 
            {
                int c = a + b;
            }
            gettimeofday(&end, NULL); // 結束測量時間
            elapsedTime = (end.tv_sec - start.tv_sec) + (end.tv_usec - start.tv_usec) / 1000000.0; // 計算時間差
            printf("ALU Computer time: %.2lf seconds\n", elapsedTime);
            break;
        case 2:
            array = malloc((int)pow(2,30) * sizeof(int)); // 分配1GB的記憶體
            Start = rdtsc(); // 開始測量時間
            for (int i = 0; i < (int)pow(2,30); i++) 
            {
                array[i] = i;
            }
            End = rdtsc(); // 結束測量時間
            elapsedTime = (double)(End - Start) / 2800000000.0; // 計算時間差（注意CPU的主頻）
            printf("記憶體存取 Computer time: %.2lf seconds\n", elapsedTime);
            free(array);
            break;
        default:
            break;
    }    
}
