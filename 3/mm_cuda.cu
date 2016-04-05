#define N 10000
#define NR N
#define NC N

#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include "cuda_runtime.h"

void printMat(float A[NR][NC]);
void initMat(float A[NR][NC], float B[NR][NC]);

__global__ void multiply(float *A, float *B);

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

	/* decide block sizes
	   call the function
		-init dev_C to 0

	   */
	cudaMemcpy(&C,dev_C,size,cudaMemcpyDeviceToHost);

	end_time = clock();
	elapsed = ( (double) (end_time-start_time))/ CLOCKS_PER_SEC;
	
	// printMat(C);
	
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
