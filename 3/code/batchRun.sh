#!/bin/bash
for matSize in {96,192,416,800,1024,2016,4096,8000,10016}
do

	sed -i "1s/.*/#define\ N\ $matSize/" mm_cuda.cu;
	nvcc -o mm_cuda mm_cuda.cu;
	./mm_cuda | sed "s/\ Time\ taken\ is\ //" >> runtimes;
	
done
