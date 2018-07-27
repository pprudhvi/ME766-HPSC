#define N 1024
#define NR N
#define NC N

#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include "cuda_runtime.h"

void printMat(float A[NR][NC]);
void initMat(float A[NR][NC], float B[NR][NC]);

__global__ void matSum(float *A, float *B, float *C);

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
//	cudaMemcpy(dev_C,&C,size,cudaMemcpyHostToDevice);	

	dim3 dimGrid(N/32,N/32);
	dim3 dimBlock(32,32,1);	

	matSum<<<dimGrid,dimBlock>>>(dev_A,dev_B,dev_C);
	
	cudaMemcpy(&C,dev_C,size,cudaMemcpyDeviceToHost);

	cudaFree(dev_A);
	cudaFree(dev_B);
	cudaFree(dev_C);
	
	end_time = clock();
	elapsed = ( (double) (end_time-start_time))/ CLOCKS_PER_SEC;
	
	printMat(C);
	
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
			A[i][j] = 1;
			B[i][j] = 1;
		}
	} 

}

__global__ void matSum(float *A, float *B, float *C){
	int row = blockIdx.y*blockDim.y + threadIdx.y;
	int col = blockIdx.x*blockDim.x + threadIdx.x;
	int index = row*NC + col;
	C[index] = A[index] + B[index];
}
