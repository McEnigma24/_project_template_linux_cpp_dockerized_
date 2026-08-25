// clang-format off
#include <benchmark/benchmark.h> // must be first
// clang-format on
#include "__preprocessor__.h"

static void BM_Sanity(benchmark::State& state)
{
    for (auto _ : state)
    {
        benchmark::DoNotOptimize(1 + 1);
    }
}
BENCHMARK(BM_Sanity);

static void BM_VectorSum(benchmark::State& state)
{
    const int n = static_cast<int>(state.range(0));
    std::vector<int> data(static_cast<size_t>(n), 1);

    for (auto _ : state)
    {
        int sum = 0;
        for (int v : data)
            sum += v;
        benchmark::DoNotOptimize(sum);
    }
}
BENCHMARK(BM_VectorSum)->Range(8, 8 << 10);

BENCHMARK_MAIN();
