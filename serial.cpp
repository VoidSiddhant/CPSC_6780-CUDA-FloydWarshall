#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <chrono>
#include <cassert>


using namespace std;
using namespace std::chrono;

const int V = 1000;

const int INF = 99999;

void InnerLoops(int dis[][V], int k)
{
	int tm = 0;
	for (int i = 0; i < V; i++)
	{
		for (int j = 0; j < V; j++)
		{
			tm = dis[i][k] + dis[k][j];
			dis[i][j] = tm * (tm < dis[i][j]) + dis[i][j] * (tm >= dis[i][j]);
		}
	}
}

void FloydWarshall(int dis[][V])
{
	for (int k = 0; k < V; k++)
	{
		InnerLoops(dis, k);
	}
}

int dis[V][V];
int main()
{

    
	for (int i = 0; i < V; i++)
	{
		for (int j = 0; j < V; j++)
		{
			if (j == i + 1)
				dis[i][j] = 1;
			else if (i != j)
				dis[i][j] = INF;
			else
				dis[i][j] = 0;
		}
	}

    // Timer functions
	time_t start = clock();

	FloydWarshall(dis);

	time_t end = clock();
	float timeElapsed = (end - start) / CLOCKS_PER_SEC;
	cout << "CPU-Floyd Computation took : " << timeElapsed << " seconds" << endl;

	for (int i = 0; i < V; i++)
	{
		for (int j = 0; j < V; j++)
		{
			if (j >= i)
				assert(dis[i][j] == j - i);
			else
				assert(dis[i][j] == INF);
		}
	}
    
    


	return 0;
}
