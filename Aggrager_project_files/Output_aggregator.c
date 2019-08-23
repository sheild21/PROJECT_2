#include <stdio.h>
#include <stdlib.h>

//#include <sstream>
/*int hextodec(char length )
{   int i=0
    int value
    for (i=0,i<10,i++){
        if (!(row_value[i]>='0' && row_value[i]<='9')||
            (row_value[i]>='A' && row_value[i]<='F')||
        (row_value[i]>='a' && row_value[i]<='f')){
        printf("Invalid\n");
        }
        else if(row_value[i]>='0' && row_value[i]<='9'){
            value=atoi(row_value[i])
            switch(row_value[i]){
                case '0':
                    value=0;
                    break;
                case '1':
                    value=0;
                    break;
                case '2':
                    value=0;
                    break;
                case '3':
                    value=0;
                    break;
                case '4':
                    value=0;
                    break;
                case '0':
                    value=0;
                    break;
                case '5':
                    value=0;
                    break;
                case '0':
                    value=0;
                    break;
            }
    }
}*/


int main()
{
    char row_len[4];
    char row[64];
    char row_value[9];
    char a[2];
    char x=&row_value[8];
    int length=0;
    int value;
    int i;
    int row_len_int = 0;
    FILE *input_engine1,*input_engine2,*out_file;
    input_engine1=fopen("G:/intern/Aggrager_project_files/ENGINE_1_OUT.txt","r");
    input_engine2=fopen("G:/intern/Aggrager_project_files/ENGINE_2_OUT.txt","r");
    out_file= fopen("G:/intern/Aggrager_project_files/OUT.txt","w");
    if ((input_engine1==NULL)||(input_engine2==NULL)){
        printf("Error");
    }
    else {
        while(input_engine1 != EOF || input_engine2 != EOF) {
            if(input_engine1 != EOF) {
                fread(row_len,4,1,input_engine1);
                printf("%s\n",row_len);
                i=0;
                row_len_int = strtol(row_len, NULL, 16);
                printf("row len int %d\n", row_len_int);
                while (i<8) {a[1]='\0';
                    row_value[i] = row[56+i];
                    a[0]=row_value[i];
                    a[1]='\0';
                    value = strtol(a,NULL, 16);
                    length=(length<<4)|value;
                    printf("%x\n",value);
                    printf("%x\n",length);
                    i++;
                }
                /*row_value[i] = '\0';
                printf("%s\n",row_value);
                //for ()
                a[0]=row_value[0];
                a[1]='\0';
                printf("%s\n",a);



                length = strtol(a,NULL, 16);
                //length = atoi(row_value[8]);
                printf("%x\n",length);
                fclose(input_engine1);*/
                return 0;


        }
'\0';
    }




}
}
