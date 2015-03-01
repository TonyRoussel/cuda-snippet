#include <iostream>
#include <string>
#include <stdio.h>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

int main(int ac, char **av)
{
	cv::Mat		*h_originImg, *d_originImg;
	cv::Mat		*h_destImg, *d_destImg;
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
	h_originImg = new cv::Mat();
	*h_originImg = cv::imread(originName, CV_8UC1);
	return (0);
}
