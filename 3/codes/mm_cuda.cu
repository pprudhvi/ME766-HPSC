#define N 10016
#define NR N
#define NC N
#define BLOCKSIZE 32
#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include "cuda_runtime.h"

void printMat(float A[NR][NC]);
void initMat(float A[NR][NC], float B[NR][NC]);

__global__ void multiply(float *A, float *B, float *C);

int main(){
	static float A[NR][NC];

	static float B[NR][NC];

	static float C[NR][NC] = {{0}}; /* initialize to 0 */

	clock_t start_time, end_time;
	double elapsed;

	float *dev_A, *dev_B, *dev_C;
	int size = NR*NC*sizeof(float);

	start_time = clock();

	cudaMalloc((void **)&dev_A,size);
	cudaMalloc((void **)&dev_B,size);
	cudaMalloc((void **)&dev_C,size);
	
	initMat(A,B);		/* fills A with random floats */
	
	cudaMemcpy(dev_A,&A,size,cudaMemcpyHostToDevice);	
	cudaMemcpy(dev_B,&B,size,cudaMemcpyHostToDevice);	

	dim3 dimGrid(N/BLOCKSIZE,N/BLOCKSIZE);
	dim3 dimBlock(BLOCKSIZE,BLOCKSIZE);
	multiply<<<dimGrid,dimBlock>>>(dev_A,dev_B,dev_C);
	cudaError_t err = cudaGetLastError();
	if (err != cudaSuccess) 
		printf("Error: %s\n", cudaGetErrorString(err));
	cudaMemcpy(&C,dev_C,size,cudaMemcpyDeviceToHost);

	cudaFree(dev_A);
	cudaFree(dev_B);
	cudaFree(dev_C);

	end_time = clock();
	elapsed = ( (double) (end_time-start_time))/ CLOCKS_PER_SEC;

	//printMat(C);

	printf(" \n Time taken is %f \n",elapsed);

	return 0;
}

void printMat(float A[NR][NC]){

	int i,j;

	for( i=0; i<NR; i++ ){
		printf("ROW %d:",i+1);
		for( j=0; j<NC; j++ ){
			printf("%.3f\t",A[i][j]);	
		}
		printf("\n");
	}

}

void initMat(float A[NR][NC],float B[NR][NC]){

	int i,j;

	for( i=0; i < NR; i++){
		for( j=0; j<NC; j++){
			A[i][j] = i+j;
			B[i][j] = i*j;
		}
	} 

}
__global__ void multiply(float *A, float *B, float *C){

	// get block position in grid
	// int blockRow = blockIdx.y;
	// int blockCol = blockIdx.x;

	// get thread position in block
	int row = threadIdx.y;
	int col = threadIdx.x;

	// get absolute position
	int absRow = blockIdx.y*blockDim.y + threadIdx.y;
	int absCol = blockIdx.x*blockDim.x + threadIdx.x;
	int index = absRow*NC + absCol; // location in contiguous 1-d

	int j;
	int sum = 0;
	for(j=0;j<NC/BLOCKSIZE;j++){
		__shared__ float Apatch[BLOCKSIZE][BLOCKSIZE];
		__shared__ float Bpatch[BLOCKSIZE][BLOCKSIZE];

		//fetch the corresponding rows and cols of A,B; each thread gets one element
		Apatch[row][col] = A[absRow*NC+j*BLOCKSIZE+col];
		Bpatch[row][col] = B[absCol+j*BLOCKSIZE*NC+row*NC];
		__syncthreads();

		int i;
		for(i=0; i<BLOCKSIZE; i++) sum += Apatch[row][i]*Bpatch[i][col];
		__syncthreads();
	}
	
	C[index] = sum;

}
