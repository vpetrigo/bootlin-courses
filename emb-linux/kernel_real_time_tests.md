All tests have been performed under Linux Kernel 5.10.8

Standard Kernel
===============

Options:
 - _no high resolution timer_
 - _measure latencies for 1 minute_

Results:

| Clock resolution (ns) | Samples | Min latency | Max latency | Average latency |
| --------------------- |:-------:|:-----------:|:-----------:|:---------------:|
| 10000000              | 6000    | 9350 us     | 10473 us    | 9895 us         |

Standard Kernel
===============

Options:
 - _with high resolution timer_
 - _measure latencies for 1 minute_

Results:

| Clock resolution (ns) | Samples | Min latency | Max latency | Average latency |
| --------------------- |:-------:|:-----------:|:-----------:|:---------------:|
| 1                     | 306473  | 61 us       | 349 us      | 90 us           |

Standard Kernel
===============

Options:
 - _workload applied_
 - _with high resolution timer_
 - _measure latencies for 1 minute_

Results:

| Clock resolution (ns) | Samples | Min latency | Max latency | Average latency |
| --------------------- |:-------:|:-----------:|:-----------:|:---------------:|
| 1                     | 22233   | 82 us       | 1912921 us  | 2587 us         |

Standard Kernel
===============

Options:
 - _workload applied_
 - _with high resolution timer_
 - *SCHED_FIFO(99) applied for latency measurement tool*
 - _measure latencies for 1 minute_

Results:

| Clock resolution (ns) | Samples | Min latency | Max latency | Average latency |
| --------------------- |:-------:|:-----------:|:-----------:|:---------------:|
| 1                     | 343249  | 24 us       | 2296 us     | 69 us           |

Standard Kernel
===============

Options:
 - _with high resolution timer_
 - _kernel PREEMPT option enabled_
 - _measure latencies for 1 minute_

Results:

| Clock resolution (ns) | Samples | Min latency | Max latency | Average latency |
| --------------------- |:-------:|:-----------:|:-----------:|:---------------:|
| 1                     | 291966  | 78 us       | 311 us      | 101 us          |

Standard Kernel
===============

Options:
 - _workload applied_
 - _with high resolution timer_
 - _kernel PREEMPT option enabled_
 - _measure latencies for 1 minute_

Results:

| Clock resolution (ns) | Samples | Min latency | Max latency | Average latency |
| --------------------- |:-------:|:-----------:|:-----------:|:---------------:|
| 1                     | 27543   | 87 us       | 569314 us   | 2067 us         |

Real-Time Kernel
===============

Options:
 - _realtime patch applied_
 - _with high resolution timer_
 - *kernel PREEMPT_RT option enabled*
 - _measure latencies for 1 minute_

Results:

| Clock resolution (ns) | Samples | Min latency | Max latency | Average latency |
| --------------------- |:-------:|:-----------:|:-----------:|:---------------:|
| 1                     | 238609  | 119 us      | 534 us      | 146 us          |

Real-Time Kernel
===============

Options:
 - _workload applied_
 - _realtime patch applied_
 - _with high resolution timer_
 - *kernel PREEMPT_RT option enabled*
 - _measure latencies for 1 minute_

Results:

| Clock resolution (ns) | Samples | Min latency | Max latency | Average latency |
| --------------------- |:-------:|:-----------:|:-----------:|:---------------:|
| 1                     | 28575   | 131 us      | 391401 us   | 1992 us         |
