#!/bin/bash
for matSize in {100,200,400,800,1000,2000,5000,8000,10000}
do

	##OPENMP
	sed -i "1s/.*/#define\ N\ $matSize/" OMPCFMM.c
	mpicc -fopenmp -o  OMPCFMM OMPCFMM.c
	for numThreads in {2,4,8}
	do
		export OMP_NUM_THREADS=$numThreads
		echo $numThreads >> ompruns
		./OMPCFMM | sed "s/\ Time\ taken\ is\ //" >> ompruns 
	done
	unset OMP_NUM_THREADS
	echo all >> ompruns
	./OMPCFMM | sed "s/\ Time\ taken\ is\ //" >> ompruns

	##MPI
	sed -i "1s/.*/#define\ N\ $matSize/" MPICFMM.c
	mpicc -o MPICFMM MPICFMM.c
	for npes in {2,4,8}
	do
		echo $npes >> mpiruns
		mpirun -np $npes MPICFMM | sed "s/\ Time\ taken\ is\ //" >> mpiruns
	done
	echo all >> mpiruns
	mpirun -np 24 MPICFMM | sed "s/\ Time\ taken\ is\ //" >> mpiruns

	##Serial CF
	sed -i "1s/.*/#define\ N\ $matSize/" SerialCFMM.c
	mpicc -o SerialCFMM SerialCFMM.c
	./SerialCFMM | sed "s/\ Time\ taken\ is\ //" >> serialCFruns
	
	##Serial	
	sed -i "1s/.*/#define\ N\ $matSize/" SerialMM.c
	mpicc -o SerialMM SerialMM.c
	./SerialMM | sed "s/\ Time\ taken\ is\ //" >> serialruns

done
