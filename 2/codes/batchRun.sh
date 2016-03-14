#!/bin/bash
for matSize in {100,200,400,800,1000}
do
	sed -i "1s/.*/#define\ N\ $matSize/" SerialCFMM.c
	mpicc -o SerialCFMM SerialCFMM.c
	./SerialCFMM | sed "s/\ Time\ taken\ is\ //" >> serialruns

	sed -i "1s/.*/#define\ N\ $matSize/" OMPCFMM.c
	mpicc -fopenmp -o  OMPCFMM OMPCFMM.c
	./OMPCFMM | sed "s/\ Time\ taken\ is\ //" >> ompruns 
	
	sed -i "1s/.*/#define\ N\ $matSize/" MPICFMM.c
	mpicc -o MPICFMM MPICFMM.c
	mpirun -np 8 MPICFMM | sed "s/\ Time\ taken\ is\ //" >> mpiruns
	
done
