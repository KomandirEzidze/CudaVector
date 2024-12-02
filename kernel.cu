// Artem Fomin

#include "cuda_runtime.h"
#include <stdio.h>
#include <malloc.h>
#include <stdlib.h>
#include <time.h>
#include <cuda.h>

struct Vector {
	int n;
	int* data;
};

struct Vector* new_vector_cpu(int n, bool random = false) {
	struct Vector* vector = (struct Vector*)malloc(sizeof(struct Vector));

	vector->n = n;
	vector->data = (int*)malloc(n * sizeof(int));

	srand(time(NULL));
	for (int i = 0; i < n; i++) {
		if (random) {
			vector->data[i] = rand() % 100;
		} else {
			vector->data[i] = 0;
		}
	}

	return vector;
}

struct Vector* new_vector_gpu(int n) {
	struct Vector* vector = nullptr;

	cudaMalloc((void**)&vector, sizeof(struct Vector));
	cudaMalloc((void**)(&(vector->data)), n * sizeof(int));

	cudaMemcpy((void*)(vector->n), &n, sizeof(int), cudaMemcpyHostToDevice);

	int* data = (int*)malloc(n * sizeof(int));
	for (int i = 0; i < n; i++) {
		data[i] = 0;
	}
	cudaMemcpy((void*)(vector->data), data, n * sizeof(int), cudaMemcpyHostToDevice);

	free(data);

	return vector;
}

void free_vector_cpu(struct Vector* vector) {
	if (vector->data != nullptr) {
		free(vector->data);
	}

	if (vector != nullptr) {
		free(vector);
	}
}

void free_vector_gpu(struct Vector* vector) {
	if (vector->data != nullptr) {
		cudaFree(vector->data);
	}

	if (vector != nullptr) {
		cudaFree(vector);
	}
}

int add_vectors_on_cpu(struct Vector* const a, struct Vector* const b, struct Vector* c) {
	if (a->n != b->n) {
		return 1;
	}

	int n = a->n;
	c = new_vector_cpu(n);
	for (int i = 0; i < n; i++) {
		c->data[i] = a->data[i] + b->data[i];
	}

	return 0;
}

void copy_vector_h_to_d(struct Vector* const vec_h, struct Vector** vec_d) {
	*vec_d = new_vector_gpu(vec_h->n);

	cudaMemcpy((void*)((*vec_d)->n), &(vec_h->n), sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy((void*)((*vec_d)->data), &(vec_h->data), vec_h->n * sizeof(int), cudaMemcpyHostToDevice);
}



int add_vectors_on_gpu(struct Vector* a_h, struct Vector* b_h, struct Vector* c_h) {
	if (a_h->n != b_h->n) {
		return 1;
	}

	int n = a_h->n;
	struct Vector *a_d, *b_d, *c_d;

	copy_vector_h_to_d(a_h, &a_d);
	copy_vector_h_to_d(b_h, &b_d);
	c_d = new_vector_gpu(n);
}

__global__ void add_vectors_d(struct Vector* a, struct Vector* b, struct Vector* c) {
	c->data[threadIdx.x] = a->data[threadIdx.x] + b->data[threadIdx.x];
}

int main(void) {

	return 0;
}
