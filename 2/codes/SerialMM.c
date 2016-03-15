#define N 1000
#define NR N
#define NC N

#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

void printMat(float A[NR][NC]);
void initMat(float A[NR][NC],float B[NR][NC]);

int main(){
	
	static float A[NR][NC];

	static float B[NR][NC];

	static float C[NR][NC] = {{0}}; /* initialize to 0 */
	
	double start_time, end_time;

	start_time = MPI_Wtime(); 
	int i,j,k;
	
	initMat(A,B);		/* fills A with random floats */
	
	for( i=0; i<NR; i++ ){
		for( j=0; j<NC; j++ ){
			for( k=0; k<NC; k++){
				C[i][j] = C[i][j] + A[i][k]*B[k][j];
			}
		
		}
	}	

	end_time = MPI_Wtime();
	
	//printMat(C);
	
	printf("\n Time taken is %f \n",(float)(end_time - start_time));

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
