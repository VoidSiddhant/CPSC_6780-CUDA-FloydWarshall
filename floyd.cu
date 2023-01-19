#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <chrono>
#include <cassert>
#include <sys/time.h>

using namespace std;
using namespace std::chrono;


// Kernel function for inner two loop of Floyd Warshall Algorithm
__global__ void GPUInnerLoops(int V, int k, int* dis)
{
	int tid = (blockDim.x * blockDim.y) * threadIdx.z + (threadIdx.y * blockDim.x) + (threadIdx.x);
	int bid = (gridDim.x * gridDim.y) * blockIdx.z + (blockIdx.y * gridDim.x) + (blockIdx.x);
	int T = blockDim.x * blockDim.y * blockDim.z;
	int B = gridDim.x * gridDim.y * gridDim.z;

	int tm = 0;
    
	/*
	 * Each cell in the matrix is assigned to a different thread. 
	 * Each thread do O(N*number of asssigned cell) computation.
	 * Assigned cells of different threads does not overlape with
	 * each other. And so no need for synchronization.
	 */
     
	for (int i = bid; i < V; i += B)
	{
		for (int j = tid; j < V; j += T)
		{
			tm = dis[i * V + k] + dis[k * V + j];
			dis[i * V + j] = tm * (tm < dis[i * V + j]) + dis[i * V + j] * (tm >= dis[i * V + j]);
		}
	}
}

const int V = 1000;

const int INF = 99999;


void FloydWarshall(int* dis)
{

	// Timer functions
    float timeElapsed = 0.0f;
	cudaEvent_t timeStart, timeStop;
	cudaEventCreate(&timeStart);
	cudaEventCreate(&timeStop);
	cudaEventRecord(timeStart, 0);
    
    
	for (int k = 0; k < V; k++)
	{
		GPUInnerLoops << <dim3(16, 8, 8), dim3(8, 8, 8) >> > (V, k, dis);
		cudaDeviceSynchronize();
	}
    

	cudaEventRecord(timeStop, 0);
	cudaEventSynchronize(timeStop);
	cudaEventElapsedTime(&timeElapsed, timeStart, timeStop);
	std::cout << "GPU-Floyd Execution took : " << timeElapsed/1000.0f << " seconds" << endl;
	cudaEventDestroy(timeStart);
	cudaEventDestroy(timeStop);
}

int main(void)
{

	int* dis;

	// Allocate Unified Memory - accessible from CPU or GPU
	cudaMallocManaged(&dis, V * V * sizeof(int));

	//initialize dis array on the host
	for (int i = 0; i < V; i++)
	{
		for (int j = 0; j < V; j++)
		{

			if (j == i + 1) dis[i * V + j] = 1;
			else if (i != j) dis[i * V + j] = INF;
			else dis[i * V + j] = 0;
		}
	}
	FloydWarshall(dis);

	for (int i = 0; i < V; i++)
	{
		for (int j = 0; j < V; j++)
		{
			if (j >= i)
			{
				assert(dis[i * V + j] == j - i);
			}
			else assert(dis[i * V + j] == INF);
		}
	}


	// Free memory
	cudaFree(dis);
	return 0;
}

