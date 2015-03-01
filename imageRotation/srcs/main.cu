#include <iostream>
#include <string>
#include <stdio.h>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
/********************/
__global__ void kernel(cv::Mat *d_ori, cv::Mat *d_dest, int rows, int cols)
{
	int index_x = blockIdx.x * blockDim.x + threadIdx.x; // access thread # within all grids
	int index_y = blockIdx.y * blockDim.y + threadIdx.y;
	int grid_width = gridDim.x * blockDim.x; // access # of thread
	int index = index_y * grid_width + index_x; // access thread # within all grids
	int r = blockIdx.y * gridDim.x + blockIdx.x; // access block # within all grids

	int x = (index * cols - index) / (rows * cols - 1);
	int y = ((rows - 1) * index) / (rows * cols - 1);

	//printf("[%d, %d]\n", index_x, index_y);
	printf("[%d, %d, %d ||| %d, %d, %d] --> %d, %d ||| [%d] --> %d --> %d ||| %d !!! %d, %d\n", blockIdx.x, blockDim.x, threadIdx.x, blockIdx.y, blockDim.y, threadIdx.y, index_x, index_y, gridDim.x, grid_width, index, r, x, y);
	
	return ;
}

void			cudaTest(cv::Mat *h_ori, cv::Mat *h_dest)
{
	cv::Mat		*d_ori, *d_dest;
	int			rows = h_ori->rows;
	int			cols = h_ori->cols;
	int			pixels = rows * cols;
	size_t		blockSize, gridSize;

	cudaMalloc((void**)&d_ori, sizeof(cv::Mat));
	cudaMalloc((void**)&d_dest, sizeof(cv::Mat));

	// blockSize = 1;
	// gridSize = pixels / blockSize;
	// if (pixels % blockSize)
	// 	++gridSize;

	cudaMemcpy(d_ori, h_ori, sizeof(cv::Mat), cudaMemcpyHostToDevice);
	cudaMemcpy(d_dest, h_dest, sizeof(cv::Mat), cudaMemcpyHostToDevice);
	// kernel<<< gridSize, blockSize >>>(d_dest, rows, cols);
	kernel<<< rows, cols >>>(d_ori, d_dest, rows, cols);
	cudaMemcpy(h_dest, d_dest, sizeof(cv::Mat), cudaMemcpyDeviceToHost);
	cudaFree(d_ori);
	cudaFree(d_dest);
	return ;
}
/********************/

int				main(int ac, char **av)
{
	cv::Mat		*h_originImg, *h_destImg;
	char		*originName, *destName;
	int			degreeRot;

	if (ac != 4) {
		std::cout << "usage: ./cudaRotate src_name dest_name degree_rot" << std::endl;
		return (1);
	}
	try {
		degreeRot = std::stoi(av[3]);
	} catch (std::exception & e) {
		std::cout << "error: " << e.what() << std::endl;
		return (2);
	}
	originName = av[1];
	destName = av[2];
	h_originImg = new cv::Mat(2, 2, CV_8SC1);/////////////
	//*h_originImg = cv::imread(originName, CV_8SC1);
	h_destImg = new cv::Mat();
	cudaTest(h_originImg, h_destImg);//////////////
	//h_originImg->copyTo(*h_destImg);////////////////
	try {
		cv::imwrite(destName, *h_destImg);
	} catch (std::exception & e) {
		std::cout << "error: " << e.what() << std::endl;
		return (3);
	}
	delete h_originImg;
	delete h_destImg;
	return (0);
}
