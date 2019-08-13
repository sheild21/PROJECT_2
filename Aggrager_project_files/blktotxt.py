
def blktotxt(file,out):
    blk_file= open("/home/shield/intern/Aggrager_project_files/1.txt",'r')
    out_file= open("/home/shield/intern/Aggrager_project_files/input_golden_2_blocks_little_endian.txt",'w')
    count=0
    counter=0
    print(count)
    while True:
        line=blk_file.readline()
        if counter==0:
            LINE_1=line.replace(" ", "")
            LINE1=LINE_1.rstrip()
            LINE1=line
            counter=counter+1
            
        elif counter==1:
            LINE2=line.replace(" ", "")
            LINE=LINE1+LINE2
            LINE=LINE1+line
            
            print (LINE)
            LINE_NEW=""
            LINE_END=""
            
            for i in range (0,16,1):
                LINE_NEW=LINE_NEW+LINE[64-((i+1)*4):(64-(i*4))]
            print (LINE_NEW)
            for i in range (0,16,1):
                LINE_END=LINE_END+LINE_NEW[(i*4)+2:(i*4)+4]+LINE_NEW[i*4:(i*4)+2]
            LINE_END=LINE_END+"\n"
            print (LINE_END)
            counter=0
            out_file.write(LINE_END)
            
        
        count=count+1

        print(count)
        
        if not line:
          break
        
        
    blk_file.close()
    out_file.close()

blktotxt("/home/shield/intern/Aggrager_project_files/input_golden_2_blocks.txt","/home/shield/intern/Aggrager_project_files/input_golden_2_blocks_little_endian.txt");


##import os
##blk_file= "G:/intern/Aggrager_project_files/engine_1_output_1.blk"
##base = os.path.splitext(blk_file)[0]
##os.rename(blk_file,base+'.txt')
##    
