# Production dispatch baseline

We measured this baseline on 2026-08-20 with Maple 2025.2 (Build 1971053)
on an Intel Core Ultra 9 185H. Times are wall-clock seconds. We disabled
Maple's whole-result cache and cleared the numerical Appell and `hypergeom`
remember tables outside each timed call.

## Regressions found before the production selector

| Case | Digits | Previous auto | Competing method | Competing time |
|---|---:|---:|---|---:|
| `3F2(0.45)` | 15 | series, 0.0046 | Maple native | 0.0003 |
| `3F2(0.45)` | 50 | series, 0.0155 | Maple native | 0.0004 |
| `2F1(z=0.95)` | 15 | series, 0.0600 | Maple native | 0.0035 |
| `2F1(z=0.95)` | 50 | series, 0.1875 | Maple native | 0.0080 |
| Appell `F2(0.5,0.45)` | 20 | generic, 19.69 | Maple native | below 0.1 |
| seven-variable `FD`, `q=0.95` | 15 | series, 2.839 | Euler | 1.102 |

The previous 100-digit `3F2` automatic call stopped at the default degree cap
before reaching its native fallback. The previous 50-digit boundary `FD`
series did not finish within two minutes in the audit process.

## Appell boundary cross-check

We evaluated

```text
F2(1/4,1/3,1/5;7/6,8/7;1/2,9/20).
```

Maple's native kernel gives

```text
1.079010979641577067020315105109892148909503913518284738773546901925953243993763105951226940082286296
```

The unrelated generic Pfaffian evaluator agrees to 19 decimal places; its
20-digit call took 19.69 seconds. The native calls took 0.014, 0.035, and
0.068 seconds at 15, 50, and 100 digits before derivative and diagnostic
overhead was added.

## Horn crossover audit

The following tables use the shared point `(1/50,3/200)`. Each entry has the
form `neighbor/generic`. These are uncached audit calls used to calibrate the
selector; `benchmark_production_dispatch.mpl` supplies the five-sample median
acceptance gate.

### Scalar values

| Family | 15 digits | 50 digits | 100 digits |
|---|---:|---:|---:|
| G1 | 0.098 / 0.065 | 0.306 / 0.411 | 0.703 / 1.652 |
| G2 | 0.077 / 0.059 | 0.310 / 0.266 | 0.736 / 1.459 |
| G3 | 0.057 / 0.085 | 0.398 / 0.609 | 3.272 / 2.874 |
| H1 | 0.101 / 0.089 | 0.250 / 0.575 | 1.353 / 3.089 |
| H2 | 0.082 / 0.056 | 0.267 / 0.616 | 0.753 / 1.759 |
| H3 | 0.072 / 0.187 | 0.406 / 0.979 | 3.232 / 5.444 |
| H4 | 0.082 / 0.188 | 2.530 / 1.402 | 3.611 / 7.065 |
| H5 | 0.102 / 0.385 | 2.439 / 2.553 | degree-cap failure / 12.797 |
| H6 | 0.085 / 0.128 | 0.435 / 0.701 | degree-cap failure / 3.298 |
| H7 | 0.092 / 0.116 | 0.252 / 0.850 | degree-cap failure / 3.961 |

### Values and first derivatives

| Family | 15 digits | 50 digits | 100 digits |
|---|---:|---:|---:|
| G1 | 0.158 / 0.049 | 0.457 / 0.349 | 1.365 / 1.734 |
| G2 | 0.141 / 0.050 | 0.436 / 0.264 | 1.408 / 1.419 |
| G3 | 0.132 / 0.102 | 0.839 / 0.806 | 7.112 / 2.976 |
| H1 | 0.134 / 0.083 | 0.472 / 0.559 | 6.601 / 2.911 |
| H2 | 0.132 / 0.060 | 0.501 / 0.372 | 1.691 / 1.782 |
| H3 | 0.116 / 0.135 | 4.822 / 0.972 | 6.688 / 5.105 |
| H4 | 0.129 / 0.181 | 4.817 / 1.680 | 7.019 / 7.550 |
| H5 | 0.142 / 0.292 | 4.697 / 2.558 | degree-cap failure / 13.163 |
| H6 | 0.118 / 0.108 | 4.917 / 0.703 | degree-cap failure / 3.629 |
| H7 | 0.162 / 0.102 | 4.720 / 1.089 | degree-cap failure / 3.985 |

The production threshold depends on the family, precision, and requested
output workload. Exact finite support and delayed lower-parameter poles do not
use this timing selector.

## Output-workload and FD admission audit

Diagnostics alone now measure a scalar call. They do not request first
derivatives. The benchmark treats scalar and derivative workloads separately
at 15, 50, and 100 digits. Representative `pFq`, Appell `F1`--`F4`, and
seven-variable `FD` derivatives are compared with contiguous-identity series
oracles at `p+24` digits. The `H3` derivatives are compared with a guarded
higher-precision central difference. The remaining Horn crossover rows check
automatic-versus-forced parity rather than a separate oracle. A specialized
Lauricella `FD` Pfaffian call transports one rank-`n+1` state. It does not
transport a rank-by-rank fundamental matrix unless the caller explicitly
requests connection or monodromy data.

At the seven-variable point with `q=0.95`, the scalar dispatcher selects the
Euler integral. A request for the value and all seven first derivatives
selects the grouped series, which returns all eight components in one
recurrence. The measured certified and admission degrees are as follows.

| Digits | Admission degree | Certified degree |
|---:|---:|---:|
| 15 | 914 | 912 |
| 50 | 2485 | 2473 |
| 100 | 4729 | 4711 |

The `maximumDegree` option is a ceiling, not the predicted work. With
`maximumDegree` equal to 1224, 1225, or 1,000,000 at 15 digits, forced and
automatic series calls use the same degree-912 recurrence. Their values,
seven derivatives, error estimates, error statuses, and branch metadata are
equal. A ceiling of 900 fails the degree pre-gate. The separate hard gate is
applied to the predicted trial and its bounded retry; it is not applied to an
unused part of a large user ceiling.

## Bounded-retry audit

For `H4(2/7,3/8,5/9,7/10;1/50,3/200)` at 100 digits, the estimated shell is
144 and the first checked grid uses degree 156. That grid does not certify the
requested precision. The previous automatic path then rebuilt the function as
a generic Pfaffian system, whereas a forced series call retried through the
public degree cap 260 and succeeded.

After applying the same bounded retry to the automatic neighbor candidate, an
order-interleaved diagnostic run gave the following medians:

| Forced series | Forced generic | Automatic | Automatic route |
|---:|---:|---:|---|
| 7.964 | 8.717 | 7.928 | neighbor series, degree 260 |

The automatic and forced-series records have equal values, first derivatives,
error estimates, and error statuses. Both records have
`branchProvenance="principal_origin_germ"` and `pathDependent=false`. The
generic cross-check has `branchProvenance="principal_canonical_transport"` and
agrees to the requested precision.

The same audit exposed a separate `H7` scalar crossover. At 80 digits, three
rounds of five interleaved samples made the old automatic neighbor route fail
the gate with ratios 1.2894, 1.2558, and 1.2779. Generic transport was the
fastest candidate at 70, 75, 80, 85, and 90 digits. The neighbor grid was the
fastest candidate at 100 and 120 digits, and it also remained the measured
50-digit route. The scalar selector therefore uses generic transport from 70
through 99 digits and the neighbor grid outside this interval. The derivative
selector retains its separate cost model.

After the correction, the 70-, 90-, 100-, and 120-digit gates passed with five
paired samples. The 80-digit gate passed three independent five-pair rounds;
the automatic-to-fastest ratios were 1.008, 1.010, and 1.046. The permanent
benchmark checks 70, 80, 90, 100, and 120 digits, repeats the 80-digit scalar
case three times, and checks the 80- and 120-digit derivative routes.

## Acceptance rule

For each routine benchmark case, we require

```text
time(auto) <= 1.25 * min(time(valid forced methods)) + 0.003 seconds.
```

The benchmark reports package-load time, uncached cold time, warm medians,
symbolic-system construction, and numerical transport separately. General,
Horn, and fast `FD` cases use five order-interleaved samples and print the
underlying timing lists. A dominated long-running `FD` candidate retains one
capped sample and an explicit resource or numerical failure classification.
Every compared call uses the same input, precision, derivative request, path,
diagnostics, and resource limits.
