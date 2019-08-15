
def blktotxt(filepath,dest_file):
    blk_file= open("G:/intern/Aggrager_project_files/engine_2_output.txt",'r')
    out_file= open("G:/intern/Aggrager_project_files/ENGINE_2_OUT_c.txt",'w')
    count=0
    counter=0
    print(count)
    while True:
        line=blk_file.readline()
        if counter==0:
            LINE_1=line.replace(" ", "")
            LINE1=LINE_1.rstrip()
            counter=counter+1
            
        elif counter==1:
            LINE2=line.replace(" ", "")
            LINE=LINE1+LINE2
            #LINE_INT=hex(int(LINE,16))
            print (LINE)
            LINE_NEW=""
            LINE_END=""
            #print LINE_INT[2:]
            for i in range (0,16,1):
                LINE_NEW=LINE_NEW+LINE[((2*i)+1)*4:(((2*i)+1)*4)+4]+LINE[((2*i))*4:((2*i)*4)+4]
            print (LINE_NEW)
            for i in range (0,16,1):
                LINE_END=LINE_END+LINE_NEW[(i*4)+2:(i*4)+4]+LINE_NEW[i*4:(i*4)+2]
            print (LINE_END)
            LINE_END=LINE_END+"\n"
            

            
            counter=0
            out_file.write(LINE_END)
            
        
        count=count+1

        print(count)
        
        if not line:
          break
        
        
    blk_file.close()
    out_file.close()

blktotxt("G:/intern/Aggrager_project_files/engine_2_output.blk","G:/intern/Aggrager_project_files/ENGINE_2_OUT.txt")


##import os
##blk_file= "G:/intern/Aggrager_project_files/engine_1_output_1.blk"
##base = os.path.splitext(blk_file)[0]
##os.rename(blk_file,base+'.txt')
##    
