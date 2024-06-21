#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

kernel void crash(device atomic_uint& counter,
                 threadgroup atomic_int& mem0,
                 threadgroup atomic_int& mem1,
                 uint gid [[thread_position_in_threadgroup]]) {
    uint pc = 0;
    uint terminate = 0;
    if (gid == 0) {
        terminate = 0;
        while (true) {
            if (terminate == 1) {
                break;
            }
            switch (pc) {
                case 0:
                    if (atomic_load_explicit(&mem0, memory_order_relaxed) == 0) {
                        pc = 0;
                    } else {
                        pc++;
                    }
                    break;
                case 1:
                    atomic_store_explicit(&mem1, 1, memory_order_relaxed);
                    pc++;
                    break;
                case 2:
                    terminate = 1;
                    break;
                default:
                    break;
            }
        }
    }
    if (gid == 1) {
        terminate = 0;
        while (true) {
            if (terminate == 1) {
                break;
            }
            switch (pc) {
                case 0:
                    if (atomic_load_explicit(&mem1, memory_order_relaxed) == 0) {
                        pc = 0;
                    } else {
                        pc++;
                    }
                    break;
                case 1:
                    terminate = 1;
                    break;
                default:
                    break;
            }
        }
    }
    if (gid == 2) {
        terminate = 0;
        while (true) {
            if (terminate == 1) {
                break;
            }
            switch (pc) {
                case 0:
                    atomic_store_explicit(&mem0, 1, memory_order_relaxed);
                    pc++;
                    break;
                case 1:
                    terminate = 1;
                    break;
                default:
                    break;
            }
        }
    }
    atomic_fetch_add_explicit(&counter, 1, memory_order_relaxed);
}