#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <time.h>
#include <malloc.h>
#include <math.h>

#define G_MBytes 1024
#define GBYTES 1073741824
#define ARRAY_SIZE (int)pow(2,30)
#define SIZE (int)pow(2,30)

int CPU_Type();
int MainMemorySize();
int CPU_Frequency();
int ALU_CPU_Time();
int Memory_CPU_Time();

int main()
{	
	int choose = 0;
	printf("Enter choose : (1)ALU (2)Memory \n");
	scanf("%d",&choose);  
    CPU_Type();
    MainMemorySize();
    CPU_Frequency();
    if(choose == 1){
    	ALU_CPU_Time();
	}
    else {
    	Memory_CPU_Time();
	}
    return 0;
}

int CPU_Type(){
	char buffer[1024];
    FILE* fp = popen("wmic cpu get name", "r");
    if (fp == NULL) {
        printf("Error: Failed to run command\n");
        return 1;
    }
    fgets(buffer, sizeof(buffer), fp);
    fgets(buffer, sizeof(buffer), fp);
    printf("CPU type: %s\n", buffer);
    pclose(fp);	
    return 0;
}

int MainMemorySize(){
	MEMORYSTATUSEX memInfo;
    memInfo.dwLength = sizeof(MEMORYSTATUSEX);
    GlobalMemoryStatusEx(&memInfo);
    printf("Total memory: %lld Gbytes\n", (memInfo.ullTotalPhys / GBYTES));
    return 0;
}

int CPU_Frequency(){
	HKEY hKey;
    DWORD value;
    DWORD valueSize = sizeof(DWORD);
    DWORD type = REG_DWORD;
    LONG result;
    double value_f;
    double GB = G_MBytes;
    result = RegOpenKeyEx(HKEY_LOCAL_MACHINE, "HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0", 0, KEY_QUERY_VALUE, &hKey);
    if (result != ERROR_SUCCESS) {
        printf("Cannot open registry key.\n");
        return 1;
    }
    result = RegQueryValueEx(hKey, "~MHz", NULL, &type, (LPBYTE)&value, &valueSize);
    if (result != ERROR_SUCCESS) {
        printf("Cannot query registry value.\n");
        return 1;
    }
    value_f = value / GB;
    printf("CPU frequency: %.2f GHz\n", value_f);
    RegCloseKey(hKey);
    return 0;	
}

int ALU_CPU_Time(){
	clock_t start, end;
    double cpu_time_used;
	int i = 0;
	
    start = clock();
    // 在這裡插入ALU的運算代碼
    int a = 1234;
    int b = 5678;
	for(i = 0 ; i < SIZE ; i++){
		// 加法
    	int c = a + b;
	}
    end = clock();

    cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    //printf("Result : %d\n",result); 
    printf("Computer time used: %.2lf seconds\n", cpu_time_used);
    return 0;
} 

int Memory_CPU_Time(){
	int i;
    int sum = 0;
    //int array[ARRAY_SIZE];
    int *array; 
    array = malloc(ARRAY_SIZE*sizeof(int));   
    // 開始計時
    clock_t start = clock();
    // 初始化數組
    for (i = 0; i < ARRAY_SIZE; i++)
    {
        array[i] = i;
    }
	free(array);
    // 結束計時
    clock_t end = clock();
    // 計算 CPU Time
    double cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    // 輸出結果
	//printf("Array sum: %d\n", sum);
    printf("Computer Time: %.2lf seconds\n", cpu_time_used);

    return 0;
}
