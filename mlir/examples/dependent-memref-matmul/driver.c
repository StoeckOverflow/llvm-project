#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

typedef struct {
  float *allocated;
  float *aligned;
  int64_t offset;
  int64_t sizes[2];
  int64_t strides[2];
} MemRef2D;

#if defined(DEPENDENT_KERNEL)
extern float *dependent_matmul_kernel(int64_t n, int64_t k, int64_t m, float *a,
                                      float *b, float *c);
#elif defined(BASELINE_KERNEL)
extern MemRef2D baseline_matmul_kernel(
    int64_t n, int64_t k, int64_t m, float *aAllocated, float *aAligned,
    int64_t aOffset, int64_t aSize0, int64_t aSize1, int64_t aStride0,
    int64_t aStride1, float *bAllocated, float *bAligned, int64_t bOffset,
    int64_t bSize0, int64_t bSize1, int64_t bStride0, int64_t bStride1,
    float *cAllocated, float *cAligned, int64_t cOffset, int64_t cSize0,
    int64_t cSize1, int64_t cStride0, int64_t cStride1);
#else
#error "Define DEPENDENT_KERNEL or BASELINE_KERNEL"
#endif

static double nowSeconds(void) {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return (double)ts.tv_sec + (double)ts.tv_nsec * 1.0e-9;
}

static int compareDoubles(const void *lhs, const void *rhs) {
  double a = *(const double *)lhs;
  double b = *(const double *)rhs;
  return (a > b) - (a < b);
}

static void fillInputs(float *a, float *b, float *c, int64_t n, int64_t k,
                       int64_t m) {
  for (int64_t i = 0; i < n * k; ++i)
    a[i] = (float)((i % 17) - 8) * 0.125f;
  for (int64_t i = 0; i < k * m; ++i)
    b[i] = (float)((i % 13) - 6) * 0.25f;
  for (int64_t i = 0; i < n * m; ++i)
    c[i] = 0.0f;
}

static void referenceMatmul(float *ref, const float *a, const float *b,
                            int64_t n, int64_t k, int64_t m) {
  for (int64_t i = 0; i < n; ++i) {
    for (int64_t j = 0; j < m; ++j) {
      float sum = 0.0f;
      for (int64_t p = 0; p < k; ++p)
        sum += a[i * k + p] * b[p * m + j];
      ref[i * m + j] = sum;
    }
  }
}

static void runKernel(int64_t n, int64_t k, int64_t m, float *a, float *b,
                      float *c) {
#if defined(DEPENDENT_KERNEL)
  (void)dependent_matmul_kernel(n, k, m, a, b, c);
#elif defined(BASELINE_KERNEL)
  (void)baseline_matmul_kernel(n, k, m, a, a, 0, n, k, k, 1, b, b, 0, k, m, m,
                               1, c, c, 0, n, m, m, 1);
#endif
}

int main(int argc, char **argv) {
  const char *kind =
#if defined(DEPENDENT_KERNEL)
      "dependent";
#else
      "baseline";
#endif
  if (argc > 1)
    kind = argv[1];
  int64_t n = argc > 2 ? atoll(argv[2]) : 128;
  int64_t k = argc > 3 ? atoll(argv[3]) : n;
  int64_t m = argc > 4 ? atoll(argv[4]) : n;
  int repeats = argc > 5 ? atoi(argv[5]) : 10;
  if (n <= 0 || k <= 0 || m <= 0 || repeats <= 0) {
    fprintf(stderr, "expected positive n, k, m, and repeats\n");
    return 2;
  }

  float *a = calloc((size_t)(n * k), sizeof(float));
  float *b = calloc((size_t)(k * m), sizeof(float));
  float *c = calloc((size_t)(n * m), sizeof(float));
  float *ref = calloc((size_t)(n * m), sizeof(float));
  double *times = calloc((size_t)repeats, sizeof(double));
  if (!a || !b || !c || !ref || !times) {
    fprintf(stderr, "allocation failed\n");
    return 3;
  }

  fillInputs(a, b, c, n, k, m);
  referenceMatmul(ref, a, b, n, k, m);
  runKernel(n, k, m, a, b, c);

  double maxError = 0.0;
  double checksum = 0.0;
  for (int64_t i = 0; i < n * m; ++i) {
    double error = fabs((double)c[i] - (double)ref[i]);
    if (error > maxError)
      maxError = error;
    checksum += c[i];
  }
  if (maxError > 1.0e-3) {
    fprintf(stderr, "validation failed: max_error=%g\n", maxError);
    return 4;
  }

  for (int r = 0; r < repeats; ++r) {
    double start = nowSeconds();
    runKernel(n, k, m, a, b, c);
    double end = nowSeconds();
    times[r] = (end - start) * 1.0e9;
  }
  qsort(times, (size_t)repeats, sizeof(double), compareDoubles);

  printf("kind=%s\n", kind);
  printf("n=%lld\n", (long long)n);
  printf("k=%lld\n", (long long)k);
  printf("m=%lld\n", (long long)m);
  printf("repeats=%d\n", repeats);
  printf("median_ns=%.0f\n", times[repeats / 2]);
  printf("checksum=%.6f\n", checksum);
  printf("max_error=%.6g\n", maxError);

  free(times);
  free(ref);
  free(c);
  free(b);
  free(a);
  return 0;
}
