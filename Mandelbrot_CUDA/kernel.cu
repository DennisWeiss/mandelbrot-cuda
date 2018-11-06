
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <Windows.h>

#include <stdio.h>
#include "SDL2-2.0.9/include/SDL.h"

#include <complex>

#include "Color.cpp"
#include "Vector2.cpp"

#include <thrust/complex.h>


using namespace thrust;

Vector2<int> windowSize(900, 600);
int iterations = 2000;

double minReal = -2;
double maxReal = 1;
double minImag = -1;
double maxImag = 1;

complex<double> zoomInPoint(-0.7336438924199521, 0.2455211406714035);

float zoomInFactor = 0.3;

void updateBoundaries() {
  minReal += zoomInFactor * (zoomInPoint.real() - minReal);
  maxReal -= zoomInFactor * (maxReal - zoomInPoint.real());
  minImag += zoomInFactor * (zoomInPoint.imag() - minImag);
  maxImag -= zoomInFactor * (maxImag - zoomInPoint.imag());

  printf("%f + %fi, %f + %fi\n", minReal, minImag, maxReal, maxImag);
}

__device__ complex<double> pixelToComplex(double minReal, double maxReal,
                                          double minImag, double maxImag, int x,
                                          int y, int pixelsX, int pixelsY) {
  double real = ((double)x / pixelsX) * (maxReal - minReal) + minReal;
  double imag = maxImag - ((double)y / pixelsY) * (maxImag - minImag);
  return complex<double>(real, imag);
}

__device__ unsigned char computeGrayscale(complex<double> c, int iterations) {
  complex<double> c2 = complex<double>(0, 0);
  for (int i = 0; i < iterations; i++) {
    c2 = c2 * c2 + c;
    if (abs(c2) > 4) {
      return 255 - 255 * i / iterations;
    }
  }
  return 0;
}

__global__ void computeGrayScaleValues(unsigned char* pixelValues, int* pixelsX,
                                       double* minReal, double* maxReal,
                                       double* minImag, double* maxImag,
                                       int* pixelsY, int* iterations) {
  for (int i = threadIdx.x; i < *pixelsX; i += blockDim.x) {
    for (int j = blockIdx.x; j < *pixelsY; j += gridDim.x) {
      unsigned char grayScale =
          computeGrayscale(pixelToComplex(*minReal, *maxReal, *minImag,
                                          *maxImag, i, j, *pixelsX, *pixelsY),
                           *iterations);

      pixelValues[j * *pixelsX + i] = grayScale;
    }
  }
}

void drawMandelbrot(SDL_Renderer* renderer, Vector2<int> size,
                    unsigned char* pixelValues) {
  for (int i = 0; i < size.x; i++) {
    for (int j = 0; j < size.y; j++) {
      int grayScale = pixelValues[j * size.x + i];
      // printf("%d %d : %d\n", i, j, grayScale);
      SDL_SetRenderDrawColor(renderer, grayScale, grayScale, grayScale, 255);
      SDL_RenderDrawPoint(renderer, i, j);
    }
  }
  SDL_RenderPresent(renderer);
}

int main(int argc, char** argv) {
  SDL_Window* window;
  SDL_Renderer* renderer;
  SDL_CreateWindowAndRenderer(windowSize.x, windowSize.y, 0, &window,
                              &renderer);

  int* devPixelsX;
  int* devPixelsY;
  double* devMinReal;
  double* devMaxReal;
  double* devMinImag;
  double* devMaxImag;
  int* devIterations;

  unsigned char* pixelValues = new unsigned char[windowSize.x * windowSize.y];
  unsigned char* devPixelValues =
      new unsigned char[windowSize.x * windowSize.y];

  cudaMalloc((void**)&devPixelsX, sizeof(int));
  cudaMalloc((void**)&devPixelsY, sizeof(int));
  cudaMalloc((void**)&devMinReal, sizeof(double));
  cudaMalloc((void**)&devMaxReal, sizeof(double));
  cudaMalloc((void**)&devMinImag, sizeof(double));
  cudaMalloc((void**)&devMaxImag, sizeof(double));
  cudaMalloc((void**)&devIterations, sizeof(int));
  cudaMalloc(&devPixelValues,
             windowSize.x * windowSize.y * sizeof(unsigned char));

  for (int i = 0; i < 12; i++) {
    
  }

  while (true) {
    cudaMemcpy(devPixelsX, &windowSize.x, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(devPixelsY, &windowSize.y, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(devMinReal, &minReal, sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy(devMaxReal, &maxReal, sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy(devMinImag, &minImag, sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy(devMaxImag, &maxImag, sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy(devIterations, &iterations, sizeof(int), cudaMemcpyHostToDevice);

    computeGrayScaleValues<<<512, 128>>>(devPixelValues, devPixelsX, devMinReal,
                                        devMaxReal, devMinImag, devMaxImag,
                                        devPixelsY, devIterations);

    cudaMemcpy((void*)pixelValues, (void*)devPixelValues,
               windowSize.x * windowSize.y * sizeof(unsigned char),
               cudaMemcpyDeviceToHost);

    drawMandelbrot(renderer, windowSize, pixelValues);

    updateBoundaries();

    Sleep(200);
  }

  getchar();
  return 0;
}
