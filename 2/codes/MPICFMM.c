#define N 1000
#define NR N
#define NC N
#define MASTER 0
#define TOMASTER 8055
#define TOSLAVE 5088 /* slave-slave connection is not required */


#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

void printMat(float A[NR][NC]);
void initMat(float A[NR][NC],float B[NR][NC]);

int main(int argc, char **argv){

	double start_time, end_time;
	int i,j,k;
	int npes;
	int mype;
	int rows;

	MPI_Status status;

	MPI_Init(&argc, &argv);

	MPI_Comm_size(MPI_COMM_WORLD, &npes);
	MPI_Comm_rank(MPI_COMM_WORLD, &mype);	

	if ( npes < 2 ) {
		printf("Should have at least 2 PEs\n");
		MPI_Finalize();
		exit(1);
	}

	start_time = MPI_Wtime(); 

	static float A[NR][NC];
	static float B[NR][NC]; /*All PEs need B*/
	static float C[NR][NC] = {{0}}; /* initialize to 0 */

	if ( mype == MASTER ){	


		initMat(A,B);		/* fills A with random floats */
		
		int noOfRows[npes]; /* no of rows computed by a PE */
		int startingRow[npes]; /* */
		startingRow[0] = 0;
		noOfRows[0] = NR/(1*npes);
		int rowsRemaining = NR - noOfRows[0];
		int l;
		int rem = rowsRemaining%(npes-1);
		
		for(l=1;l<npes;l++){
			noOfRows[l] = rowsRemaining /(npes-1);	
			if( rem > 0){
				noOfRows[l]++;
				rem--;
			}
			startingRow[l] = startingRow[l-1] + noOfRows[l-1];

		}

		for( l = 1; l<npes; l++){  /* send rows to PEs*/
			rows = noOfRows[l];

			MPI_Send(&rows,1,MPI_INT,l,TOSLAVE,MPI_COMM_WORLD);	
			MPI_Send(&A[startingRow[l]][0],rows*NC,MPI_FLOAT,l,
					TOSLAVE,MPI_COMM_WORLD);
			MPI_Send(B,NR*NC,MPI_FLOAT,l,
					TOSLAVE,MPI_COMM_WORLD);

		}


		for( i=0; i<noOfRows[0]; i++ ){ /* computation */
			for( k=0; k<NC; k++){
				for( j=0; j<NC; j++ ){
					C[i][j] = C[i][j] + A[i][k]*B[k][j];
				}

			}
		}	

		for( l = 1; l<npes; l++){  /* receive rows from PEs*/
			rows = noOfRows[l];

			MPI_Recv(&C[startingRow[l]][0],rows*NC,MPI_FLOAT,l,
					TOMASTER,MPI_COMM_WORLD,MPI_STATUS_IGNORE);

		}

		end_time = MPI_Wtime();

		//printMat(C);

		printf("\n Time taken is %f \n",(float)(end_time - start_time));
	}

	else {
		MPI_Recv(&rows,1,MPI_INT,MASTER,TOSLAVE,MPI_COMM_WORLD,MPI_STATUS_IGNORE);

		MPI_Recv(A,rows*NC,MPI_FLOAT,MASTER,TOSLAVE,MPI_COMM_WORLD,MPI_STATUS_IGNORE);

		MPI_Recv(B,NR*NC,MPI_FLOAT,MASTER,TOSLAVE,MPI_COMM_WORLD,MPI_STATUS_IGNORE);

		for( i=0; i<rows; i++ ){ /* computation */
			for( k=0; k<NC; k++){
				for( j=0; j<NC; j++ ){
					C[i][j] = C[i][j] + A[i][k]*B[k][j];
				}

			}
		}	

		MPI_Send(C,rows*NC,MPI_FLOAT,MASTER,
				TOMASTER,MPI_COMM_WORLD);

	}

	MPI_Finalize();
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
