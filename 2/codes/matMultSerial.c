#define N 500
#define NR N
#define NC N

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void printMat(float A[NR][NC]);
void initMat(float A[NR][NC]);

int main(){
	
	float A[NR][NC];

	float B[NR][NC];

	float C[NR][NC] = {{0}}; /* initialize to 0 */
	
	clock_t start_time, end_time;

	start_time = clock();
	int i,j,k;
	
	initMat(A);		/* fills A with random floats */
	initMat(B);
	
	for( i=0; i<NR; i++ ){
		for( k=0; k<NC; k++){
			for( j=0; j<NC; j++ ){
				C[i][j] = C[i][j] + A[i][k]*B[k][j];
			}
		
		}
	}	

	end_time = clock();	
	
	printMat(C);
	
	printf("\n Time taken is %f \n",(double)(end_time - start_time)/CLOCKS_PER_SEC);

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

void initMat(float A[NR][NC]){
	
	srand( (unsigned int) time(NULL) );
	
	float range = 1.0; /* max element in the array */

	int i,j;

	for( i=0; i < NR; i++){
		for( j=0; j<NC; j++){
			A[i][j] = ( (float)rand() / (float)(RAND_MAX) ) * range;
		}
	} 

}
