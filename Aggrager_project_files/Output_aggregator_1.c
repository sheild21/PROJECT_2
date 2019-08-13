#include <stdio.h>
#include <stdlib.h>


int main()
{
    char *row_len1;
    char *row_len2;
    char *data1;
    char *data2;
    char *ptr;
    char  x;
    int length_byte=8;
    row_len1=(int*)malloc(8*sizeof(char));
    row_len2=(int*)malloc(8*sizeof(char));
    int engine_1=1;
    int engine_2=0;
    int space=0;
    int row_len1_int = 0;
    int row_len2_int = 0;
    int r1,r2,r3,r4=0;
    int end=0;
    int i=0;
    int j=0;
    FILE *input_engine1,*input_engine2,*out_file;
    input_engine1=fopen("G:/intern/Aggrager_project_files/ENGINE_1_OUT_c.txt","r");
    input_engine2=fopen("G:/intern/Aggrager_project_files/ENGINE_2_OUT_c.txt","r");
    out_file= fopen("G:/intern/Aggrager_project_files/OUT.txt","w");
    if ((input_engine1==NULL)||(input_engine2==NULL)){
        printf("Error");
    }
    else {
        while(end!=2) {
            if (engine_1==1){
                r1=fread(row_len1,1,length_byte,input_engine1);
                printf(" r1 %d\n",r1);
                printf("%s\n",row_len1);


                if (r1==length_byte){
                    fwrite(row_len1,1,length_byte,out_file);
                    printf("%s\n",row_len1);
                    row_len1_int = strtol(row_len1, NULL, 16);
                    printf("row len1 int %d\n", row_len1_int);
                    //space=row_len1_int*8/256;
                    space=137;
                    data1 = (int*) malloc((2*(row_len1_int)+1+space-8) * sizeof(char));
                    printf ("%s\n",data1[4]);
                    r2=fread(data1,1,2*(row_len1_int)+space-8,input_engine1);
                    printf(" r2 %d\n",r2);
                    fwrite(data1,1,2*(row_len1_int)+space-8,out_file);
                    printf("data %s\n",data1);

                    if (r2!=2*(row_len1_int)+space-8){
                            fclose(input_engine1);
                            end=end+1;
                            printf("end %d\n",end);
                    }
                }
                else{

                    fclose(input_engine1);
                    end=end+1;
                    printf("end %d\n",end);
                }
                    engine_1=0;
                    engine_2=1;
                    printf("engine2 %d\n",engine_2);

            }
            else if (engine_2==1){
                    r3=fread(row_len2,1,length_byte,input_engine2);
                    if (r3==length_byte){
                        fwrite(row_len2,1,length_byte,out_file);
                        printf("%s\n",row_len2);
                        row_len2_int = strtol(row_len2, NULL, 16);
                        printf("row len2 int %d\n", row_len2_int);
                        space=row_len2_int*8/256;
                        data2 = (int*) malloc((2*(row_len1_int)-8+1+space) * sizeof(char));
                        r4=fread(data2,1,2*(row_len1_int)-8+space,input_engine2);
                        fwrite(data2,1,2*(row_len1_int)-8+space,out_file);
                        printf("data %s\n",data2);
                        if (r4!=2*(row_len1_int)-8+space){
                            fclose(input_engine1);
                            end=end+1;
                            printf("end %d\n",end);
                        }
                    }
                    else{
                        fclose(input_engine2);
                        end=end+1;
                        printf("end %d\n",end);

                    }
                    engine_1=1;
                    engine_2=0;
                    printf("engine1 %d\n",engine_1);
                    printf("end %d\n",end);


                    }

            }
            fclose(out_file);
        }
    }

