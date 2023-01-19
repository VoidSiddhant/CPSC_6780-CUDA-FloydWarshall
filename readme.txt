A computational comparision between serialized code (CPU) against parallel code (CUDA).
Floyd Warshall algorithm is implemented using both serialzed approach and parallel approach.

Required : CUDA (nvcc) and g++

Before compiling, if cuda was needed to load:

module load cuda/11.1.1-gcc/9.5.0




To compile the file, please use:
	
for serial.cpp: g++ -o s serial.cpp 	
for floyd.cu: nvcc -o f floyd.cu 	




A example could be like:

[qiaoyiy@node0174 p1]$ ./s
CPU-Floyd Computation took : 5 seconds
[qiaoyiy@node0174 p1]$ ./f
GPU-Floyd Execution took : 0.0137646 seconds
