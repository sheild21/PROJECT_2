def ctoout():
    OUT_file= open("/home/shield/intern/Aggrager_project_files/OUT.txt",'r')
    out_end_file= open("/home/shield/intern/Aggrager_project_files/OUT_END.txt",'w')    count=0
    counter=0
    print(counter)
    line=""
    LINE_NEW=""
    while True:
        while (count!=64):
            char=OUT_file.read(1)
            #print(char)
            if char!="\n":
                line=line+char
                count=count+1
        print(line)        
        for i in range(0,8,1):
            LINE_NEW=LINE_NEW+line[(8-(i+1))*8:64-i*8]
        count=0
        print(LINE_NEW)
        out_end_file.write(LINE_NEW)
        out_end_file.write("\n")
        line=""
        LINE_NEW=""
        counter=counter+1
        print(counter)
        

        if not char:
            break
    OUT_file.close()
    out_end_file.close()
        
        
ctoout()
        
