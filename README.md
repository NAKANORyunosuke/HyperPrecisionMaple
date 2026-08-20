# HyperPrecisionMaple

## Overview

`HyperPrecisionMaple` is a Maple 2025 implementation of arbitrary-precision
analytic continuation for complete Horn-type hypergeometric series. It builds
an annihilating PDE ideal, selects a finite derivative basis, evaluates the
full multivariate Pfaffian connection

```math
\partial_{x_i}Y=\Omega_i(x)Y,
```

and restricts that connection to piecewise-linear paths. In addition to a
distinguished hypergeometric solution, the package transports the full
fundamental matrix and computes numerical monodromy representations.

Principal-germ evaluations use specialized recurrences before a Pfaffian
system is constructed. Generalized univariate functions, the four Appell
functions, the ten named Horn functions, and the four Lauricella families
have separate dispatch rules and resource gates.

The implementation follows the Pfaffian-transport method of Banik and Bera.
It is independent of the reference Mathematica package and of
`HyperPrecision.jl`; neither is required at run time.

## Features

- Complete Horn series with positive or negative integral weight rows.
- Full Pfaffian connections for Appell `F1`--`F4`, Horn `G` and `H`, and
  Lauricella `FA`--`FD` functions.
- An `O((p+q)*D)` term recurrence for generalized `pFq` functions through
  degree `D`, together with Maple's native principal-branch evaluator away
  from the real branch cut.
- Convolution kernels for Lauricella `FA`, `FB`, and `FC`. Appell `F2`, `F3`,
  and `F4` use the corresponding two-variable kernels, while Appell `F1`
  uses the Lauricella `FD` evaluator.
- Neighbor-ratio total-degree grids for Horn `G1`--`G3` and `H1`--`H7`,
  including negative Pochhammer shifts.
- A grouped total-degree recurrence for Lauricella `FD`, with cost
  `O(D^2+n*D)` through degree `D`, an absolute tail majorant or a guarded
  doubled-degree check, and no multi-index enumeration.
- An explicit rank-`n+1` Lauricella `FD` Pfaffian connection in the basis
  `[F,dF/dx1,...,dF/dxn]`.
- Automatic selection among the grouped series, the Euler integral, and
  Pfaffian transport. Each method can also be selected explicitly.
- Exact singular-support extraction from the selected Macaulay pivot
  determinant when the parameters are exact.
- Canonical and user-supplied paths, a non-mutating `safe_opt`, and an
  explicitly unverified `fast_opt` shortcut planner.
- Restricted-root-based Taylor steps along every path segment.
- Factorized full fundamental transport, reverse-path and differential-residual
  checks, order checks, and precision-escalation history.
- Univariate polygon loops, multivariate meridians, and numerical monodromy
  matrices.
- Fixed-parameter values, epsilon Laurent expansions, and held-call syntax.
- Common `method`, `returnDiagnostics`, and `returnDerivatives` options for
  the predefined fixed-parameter interfaces.
- Exact cancellation of identical upper and lower Pochhammer factors before
  pole and termination tests, and a preallocation gate for generic Macaulay
  reductions.
- Arbitrary-precision midpoint arithmetic in `fast` mode.

## Requirements and installation

- Maple 2025. Earlier Maple releases have not been tested.
- `cmaple` on `PATH` for the command-line test runner.

Clone the repository and load the source file from Maple:

```maple
read "HyperPrecision.mpl":
with(HyperPrecision):
```

No package installation or external numerical library is required.

## Quick start

The following point lies outside the convergence disk of the defining Gauss
series:

```maple
hpValue := HypergeometricPFQ([1,1],[2],-2,'digits'=40);
# log(3)/2
```

The predefined interfaces are `Hypergeometric2F1`, `HypergeometricPFQ`,
`AppellF1`--`AppellF4`, `HornG1`--`HornG3`, `HornH1`--`HornH7`, and
`LauricellaFA`--`LauricellaFD`.

### General hypergeometric dispatch

The generalized univariate evaluator uses one recurrence for the value and
its first derivative:

```maple
pfqReport := HypergeometricPFQ([1/7,2/7,3/7],[5/6,7/8],.45,'digits'=30,'returnDiagnostics'=true):
pfqReport:-value;
pfqReport:-methodUsed;
pfqReport:-errorEstimate;
```

For fixed parameters, `method` can be set to `"auto"`, `"series"`,
`"native"`, `"pfaffian"`, or `"generic"`. The `"native"` method is
defined for generalized univariate functions and Appell's four functions.
The `"generic"` method retains the numerical Macaulay route for comparisons.
An explicit waypoint or a nondefault branch-side request disables principal
series, convolution, and native evaluation. `TransportDE` normalizes explicit
waypoints before it tests direct-series eligibility, so an explicit loop is
always transported.

For an ordinary nonterminating principal-germ `pFq` call, the automatic
dispatcher uses Maple's native kernel before allocating a recurrence ladder.
Exact termination and a delayed lower-parameter pole retain the checked
recurrence. For `p>q+1`, the defining series is used only when an upper
parameter gives exact termination. The native method can be selected
separately when Maple defines the requested continuation.

Large terminating `1F0` polynomials and terminating `2F1` values at `z=1`
use exact binomial and Chu--Vandermonde products, respectively. These products
avoid cancellation among large intermediate terms. Diagnostics identify this
route as `closed_form`. A nonzero value smaller than `10^(-digits)` is retained;
component chopping is relative to the complex value rather than absolute.
The O(1) `1F0` reductions at `z=1` and `z=2` remain available for a large
polynomial degree. Other terminating recurrences must satisfy
`maximumDegree` and their operation gate before coefficient generation.

In their open convergence domains, nonterminating principal-germ calls to
Appell `F1`, `F2`, `F3`, and `F4` use Maple's native kernels. Their first
derivatives are evaluated by the contiguous derivative identities. Forced
series calls retain the Lauricella `FD`, `FA`, `FB`, and `FC` implementations,
respectively. Thus the following call returns the value and all first partial
derivatives from the selected representation:

```maple
f2Vector := AppellF2(1/4,1/3,1/5,7/6,8/7,1/20,1/30,'digits'=30,'returnDerivatives'=true):
```

The standard open convergence domains used by the automatic convolution
dispatcher are

```math
\sum_i |x_i|<1\quad(F_A),\qquad
\max_i |x_i|<1\quad(F_B),\qquad
\sum_i \sqrt{|x_i|}<1\quad(F_C).
```

An exact terminating parameter permits evaluation outside these domains.
The convolution is accepted only after a degree comparison and a repeated
working-precision comparison. Exact identical weight rows are cancelled before
termination or pole tests; this rule includes one-variable `FB` and `FC`.
The `FD` identity with `a=c` is applied before a lower-parameter pole test.
Exact normalization, termination, cancellation, and product reductions precede
numerical method selection and may supersede a forced numerical method.
The field `methodUsed` reports the representation that is actually evaluated.
Named Horn `G` and `H` series use a conservative interior cost test followed
by a geometric-shell check, a degree comparison, and a working-precision
comparison. The automatic dispatcher compares a family-specific neighbor-term
estimate with a calibrated generic-transport threshold. The threshold depends
on the requested precision and on whether first derivatives are requested.
Finite support and delayed poles retain the checked neighbor recurrence.
After the cost selector admits a neighbor candidate, `"auto"` uses the same
bounded `maximumDegree` retry as a forced series call. Only a failed bounded
retry proceeds to the Pfaffian route. No Laplace, Bessel, or Mellin--Barnes
formula is enabled automatically.

With `returnDiagnostics=true`, a fixed-parameter call returns a record with
the common fields `value`, `derivatives`, `methodUsed`, `degree`,
`errorEstimate`, `elapsedSeconds`, `convergenceTest`, `estimatedDegree`,
`workingDigits`, `errorStatus`, `compressedDimension`, and
`branchProvenance`. The aliases `method`, `estimatedError`, `elapsedTime`, and
`certificate` are also present. Diagnostics alone request only the scalar
value: `derivatives=[]` and `derivativeWorkload=false`. Set both
`returnDiagnostics=true` and `returnDerivatives=true` to include all first
derivatives in the record. The fields `genericStepCount` and
`genericProvenance` distinguish direct basis evaluation from state-vector
transport, and `resourceStatus="ok"` distinguishes returned records from
classified resource failures in the benchmark. The error status is one of `certified`,
`bounded`, `a_posteriori`, `heuristic`, or `unknown`. Maple native values are
marked as `heuristic`; the package does not relabel their rounding allowance
as a proof. Exact terminating midpoint sums are `a_posteriori`, while an
exact-cancellation midpoint formula is `heuristic`; the exact identity remains
recorded in `certificate`. A generic Pfaffian value does not yet carry a transport residual;
its diagnostics use `certificate="transport_error_unknown"`,
`errorStatus="unknown"`, and `errorEstimate=infinity`. For a rank-one generic
connection, first derivatives are reconstructed from `dF=A_i(x)F`.

The file `examples/hypergeometric_fast.mpl` contains one-line Maple calls for
generalized `pFq`, Appell `F2`, Horn `G1`, and seven-variable Lauricella `FA`.
It can be pasted into the worksheet GUI without joining continuation lines.

### Lauricella FD dispatch

The following seven-variable evaluation uses the grouped series and does not
construct a generic Macaulay system:

```maple
fd7 := LauricellaFD(1/4,[1/4$7],1,[1/2,1/3,1/4,1/5,1/6,1/7,1/8],'digits'=15);
# 1.1420121941001597687800075...
```

Set `method` to `"series"`, `"euler"`, `"pfaffian"`, `"generic"`, or
`"auto"`. The default value is `"auto"`; `"generic"` selects the original
Macaulay-system route. With `returnDiagnostics=true`, the result is a
record containing `value`, `methodUsed`, `degree`, `errorEstimate`,
`elapsedSeconds`, `compressedDimension`, `transportFactors`,
`convergenceTest`, `tailBound`, `doubledDegreeDifference`, and
`roundingError`. It also contains `workingDigits`, `errorStatus`, and
`branchProvenance`. For specialized Pfaffian evaluation,
`transportKind="rank_state"`, `stateStepCount`, and `transportProvenance`
report the state-vector workload. The legacy `transportFactors` field equals
the state-step count for this route.

The automatic dispatcher first groups exactly equal raw coordinates and sums
their exponents before any floating-point conversion. It then applies a
terminating series when `a` is a nonpositive integer and the product formula
when `c=a` on the principal sheet. For a nonterminating call, it compares the
estimated quadratic series work with a precision- and dimension-dependent
degree budget. It uses the grouped series in the admitted interior, the Euler
integral when its applicability and cost tests pass, and the explicit
rank-`n+1` Pfaffian transport otherwise. Scalar and derivative requests both
transport one rank-`n+1` state; they do not construct or transport a
rank-by-rank fundamental matrix. The full fundamental transport remains
available through `TransportFundamental` for explicit connection and
monodromy computations. Large exponents and small nonzero
coordinate separations increase the internal working precision. In the Euler
integrand, opposite exponents at nearby coordinates are combined by a
uniformly bounded logarithmic expansion before quadrature.
The evaluator also preserves the stored mantissa precision of Maple `Float`
inputs, including parameters and coordinates removed by an exact reduction.
The field `workingDigits` reports the maximum effective precision used by the
selected numerical kernel.

Explicit waypoints and branch-side requests force Pfaffian transport, since
the grouped series and the straight Euler integral evaluate the principal germ
at the origin and cannot retain a user-specified path class. Such a request
retains every endpoint coordinate and every waypoint coordinate. The `c=a`
product reduction is also disabled when a path is supplied.

For a nonterminating automatic call, `maximumDegree` is a resource ceiling,
not a prediction of the work. Both forced and automatic series use the
conservative tail-degree estimate and reserve one retry whose degree is at
most 20 percent larger, plus 32 degrees. An unnecessarily large user ceiling
therefore does not suppress a cheap series or cause a correspondingly large
allocation. The specialized recurrence retains a separate hard limit of
40,000,000 scalar updates, evaluated on the planned retry. If the predicted
bounded work itself exceeds this limit, the evaluator raises an error before
allocating an oversized coefficient array. A terminating series
allocates only through its exact polynomial degree, independently of a larger
`maximumDegree` setting. The generic Horn evaluator has a separate
one-million-term limit. Conditioning guards above 4,096 extra digits are
rejected explicitly instead of attempting an unbounded allocation.

An `AffineParameter(c,s)` denotes `c+s*epsilon`. Section 4.4 of the paper is
reproduced by

```maple
b2 := EpsilonParameter(1,1):
c2 := EpsilonParameter(-1,-1):
paperExpansion := AppellF2(2,3/2,b2,4,c2,3,11/3,'epsilonOrder'=1,'digits'=10):
LaurentPolynomial(paperExpansion,epsilon);
paperExpansion:-estimatedError;
```

With the default `branchSide=-1`, the coefficients through order one agree
with the branch reported in the paper. `HypExpand` and `HypFunctionExpand`
provide the corresponding general-series and held-call interfaces.

The AGM test checks

```math
{}_2F_1\left(\tfrac12,\tfrac12;1;z\right)
=\mathrm{AGM}(1,\sqrt{1-z})^{-1},
```

at `z=1-10^(-8)`.

The worksheet `examples/lauricella_fd_quarter.mw` evaluates
`LauricellaFD(1/4,[1/4,1/4,1/4],1,x)`, checks its diagonal reduction to a
Gauss function, constructs the full rank-four Pfaffian connection, and
transports a full fundamental matrix. The adjacent Markdown file is the
worksheet source, and `examples/lauricella_fd_quarter.mpl` is the command-line
version. The command-line file keeps each Maple call on one line for direct
use in the worksheet GUI. Regenerate the worksheet from the `examples`
directory by

```powershell
cmaple -q build_lauricella_fd_quarter_worksheet.mpl
```

## Full Pfaffian connection

Construct a complete Horn series and its full connection as follows:

```maple
f2Series := FunctionSeries("AppellF2",[2,3/2,5/4,4,7/3],2):
f2System := FindPfaffianSystem(f2Series,'digits'=40):
rankAndBasis := FindHolonomicRank(f2Series,'digits'=40):
omega := ConnectionMatrices(f2System,[1/10,1/5]):
flatness := CheckIntegrability(f2System):
divisor := SingularFactors(f2System):
```

`PDEGenerator` returns the sparse annihilating operators.
`FindHolonomicRank` returns `[rank,basis]`, where the basis consists of
ordinary partial derivatives ordered by total degree. `ConnectionMatrices`
evaluates every matrix `Omega[i]` at an arbitrary regular point, rather than
constructing only a pre-restricted connection.

`SingularFactors` returns the factored determinant of the selected pivot
matrix. Its zero set contains all poles of this connection representation; it
may also contain apparent or basis-dependent singular factors.
`RestrictedSingularRoots(system,p,q)` substitutes `p+t*(q-p)` and returns all
detected complex roots in the segment parameter `t`.

The milestone suite constructs full connections for Appell `F1`, `F2`, and
`F3`, and for three-variable Lauricella `FD`.

For Lauricella `FD`, use the explicit constructor when a full connection is
needed:

```maple
fdSystem := LauricellaFDPfaffianSystem(1/4,[1/4$7],1,'digits'=20):
fdBasepoint := [1/16,1/24,1/32,1/40,1/48,1/56,1/64]:
fdInitial := LauricellaFDInitialVector(1/4,[1/4$7],1,fdBasepoint,'digits'=20):
```

The constructor has rank eight in this example. It uses the singular factors
`x_i`, `1-x_i`, and `x_i-x_j` directly. Thus it does not expand the repeated
denominators of all connection entries. `LauricellaFDInitialVector` returns
the principal-germ vector `[F,dF/dx1,...,dF/dxn]` by the grouped recurrence.

A rational connection can also be supplied directly:

```maple
userSystem := UserPfaffianSystem(
    [Matrix([[y]]),Matrix([[x]])],[x,y],
    'digits'=40,'singularFactors'=[]):
```

`PfaffianFromConnection` is an alias. All matrices must have one common square
shape, and there must be one matrix per variable. Denominators and optional
declared factors form the singular support. A user system has no distinguished
hypergeometric solution, so its initial vector must be supplied explicitly.
`CheckExactFlatness` symbolically simplifies every curvature entry of an exact
rational user connection. An inexact connection has flatness status
`"unknown_inexact"`; it may be transported, but it is not accepted as a
monodromy representation.

## Path planning

`PlanPath` always returns a `PfaffianPathPlan` whose `points` include both
endpoints:

```maple
path := PlanPath(f2System,[1/10,1/10],[3/2+I/5,11/6-I/7],
    'mode'="safe_opt",'pathClass'="principal",'branchSide'=-1):
```

The modes are:

- `canonical`: retain user waypoints, or construct a deterministic complex
  detour if the direct segment meets the detected divisor;
- `user`: retain the supplied piecewise-linear representative;
- `safe_opt`: return the canonical or user representative unchanged because
  this Maple version has no interval certificate for a homotopy strip;
- `fast_opt`: remove sampled redundant waypoints after point and segment
  checks, without claiming preservation of the path class.

The plan records restricted roots, minimum clearances, accepted shortcuts,
and segment counts. `ReversePath(path)` constructs the reversed point list.
Finite real and nonreal restricted roots are retained. When a direct segment
is singular, the canonical planner tests the effective coordinates on the
requested `branchSide`; it never silently switches to the opposite side. If
that deterministic deformation meets another divisor, planning fails closed
and the opposite side or explicit waypoints must be requested by the user.
For `safe_opt`, `homotopyVerification` is
`"not_certified_no_change"`. The sampled `fast_opt` result is marked
`"sampled_unverified"`.

## Fundamental transport

Use a regular basepoint in a convergence region and normalize the fundamental
matrix there:

```maple
gauss := FunctionSeries("Hypergeometric2F1",[1/3,1/4,1/2],1):
system := FindPfaffianSystem(gauss,'digits'=30):
basepoint := ChooseBasepoint(system,'digits'=25):
initialVector := InitialVector(system,basepoint,'digits'=25):
path := PlanPath(system,basepoint,[4/5],'mode'="canonical"):
transport := TransportFundamental(system,path,'digits'=25):

denseMatrix := MaterializeTransport(transport):
continuedVector := ApplyTransport(transport,initialVector):
inverseTransport := InverseTransport(transport):
```

`TransportFundamental` computes every column simultaneously by the Taylor
recurrence

```math
U_{n+1}=\frac1{n+1}\sum_{k=0}^{n}A_kU_{n-k},\qquad U_0=I.
```

It returns a `FactorizedFundamentalTransport`. The `factors` remain in path
order and can also be accessed through the record closures
`transport:-Apply(v)`, `transport:-Materialize()`, and
`transport:-Inverse()`. The `history` contains the segment, center, step,
restricted radius, truncation order, working precision, tail estimate, and
`N` versus `N+Delta` discrepancy for every patch. It also records an
independently evaluated local differential residual `dU/dt-A(t)U`.
`diagnostics` contains its maximum, the independently transported reverse-path
residual, and every precision attempt. An inverse transport reverses the
factor order and rewrites segment numbers, patch parameters, and centers in
reverse-path coordinates; its diagnostics identify this algebraic history.

The original `TransportDE` API remains available for the distinguished
hypergeometric solution and is backward compatible.

## Monodromy

For one variable, `MeridianGenerators` connects the basepoint to a small
counterclockwise polygon around each requested singular point. For several
variables, it constructs a transverse meridian around a detected coordinate
slice or a user-specified smooth divisor point:

```maple
loops := MeridianGenerators(system,[1/5],
    'components'=[1],'vertices'=8,'radius'=1/10):
rho := Monodromy(system,loops,'digits'=20):
M1 := MonodromyMatrix(rho,"D1"):
```

For a custom multivariate component, pass a record with fields `point`,
`direction`, and `label`. The point must lie on exactly one detected factor,
and the direction must be transverse. Every detected restricted root on that
transverse line bounds the disk radius. An explicit disk that contains any
other singular germ is rejected; an automatic radius is reduced. Connector
edges and every polygon chord are checked as well. In one
variable, requested centres must match detected roots and the radius is bounded
by all other roots, not only by the requested component list. The monodromy
matrix is obtained by direct full fundamental transport around the closed
path, so the method is not based on a nonresonant residue shortcut.

`NumericalMonodromyRepresentation` stores the basepoint, derivative basis,
loops, matrices, verified reverse relations, and
`generatorSetComplete="unknown"`. Automatically detected coordinate-slice
meridians are useful generators; they are not claimed to be a complete
presentation of the fundamental group. `Monodromy` rejects empty or open
paths, mixed loop basepoints, duplicate labels, and connections that fail the
required flatness checks. Exact rational user connections must pass the full
symbolic curvature identity; inexact user connections are not accepted for
representations. Every automatically generated polygon edge is checked
through its restricted roots, not merely at its vertices.

The extended suite verifies the known `x=1` invariants for
`2F1(1/3,1/4;1/2;x)` and for an Appell `F3` transverse slice. In both cases
the nontrivial eigenvalue is `exp(-Pi*I/6)`. The `F3` test also checks the
reflection characteristic relation `(M-I)(M-exp(-Pi*I/6)I)=0` numerically.

## Tests and benchmarks

Run the regular and Pfaffian-engine tests with

```powershell
powershell -ExecutionPolicy Bypass -File .\run-tests.ps1
```

Additional suites are selected explicitly:

```powershell
powershell -ExecutionPolicy Bypass -File .\run-tests.ps1 -AGM
powershell -ExecutionPolicy Bypass -File .\run-tests.ps1 -Extended
powershell -ExecutionPolicy Bypass -File .\run-tests.ps1 -Monodromy
powershell -ExecutionPolicy Bypass -File .\run-tests.ps1 -Benchmarks
```

`-Extended` runs the paper example. `-Monodromy` runs the slower known
monodromy examples. The regular runner also checks the seven-variable
Lauricella `FD` value and derivative vector, the explicit rank-eight
connection, exact flatness, diagonal compression, branch-cut conjugacy, and
the automatic method. It also checks generalized `pFq`, the Appell aliases,
all ten named Horn functions, the `FA`--`FC` convolution derivatives, exact
axis reductions, an independent exact seven-variable `FA` polynomial, and the
pre-Macaulay resource gate. Adversarial checks include exact upper--lower
cancellation, an uncancelled lower pole, a terminating polynomial outside its
nonterminating convergence domain, exact perturbations of size `10^(-100)`
from a lower-parameter pole, a value of order `10^(-435)`, explicit path
requests, a winding that changes `2F1(1,1;2;1/2)` by magnitude `4*Pi`,
nonpositive exact row cancellations, preallocation termination gates, `c=a`,
exponents of size `10^40`, distinct coordinates separated by `10^(-40)`,
cancellation that defeats a last-shell stopping rule, and Euler fallback. The
production-dispatch suite also checks the native `pFq` and Appell portfolios at
15, 50, and 100 digits, the `q=0.95` Appell and `FD` routes, working-precision
metadata, error-status metadata, delayed-pole exclusions, and degree gates
before recurrence allocation.

The production benchmark clears Maple's Appell, `hypergeom`, and whole-result
caches outside every timed call. It records load time and uncached cold time
separately at 15, 50, and 100 digits. The general portfolio uses five warm
samples. The Horn portfolio uses five order-interleaved samples for every one
of `G1`--`G3` and `H1`--`H7`, separately for scalar and derivative workloads.
Forced methods receive the same perturbed inputs, derivatives, diagnostics, path
settings, and resource limits as `"auto"`. The gate requires
`time(auto) <= 1.25*time(fastest) + 0.003` seconds. It covers generalized
`pFq`, `2F1` near `q=0.95`, Appell `F2`, all ten named Horn functions, and
seven-variable `FD`. The `FD` portfolio includes the series, Euler, Pfaffian,
and automatic candidates in both the deep interior and the `q=0.95` case.
At `q=0.95`, scalar evaluation selects the single Euler integral, whereas a
value together with all seven first derivatives selects the grouped series;
the latter computes every component in one recurrence instead of evaluating
eight Euler integrals.
Fast candidates receive five paired warm samples. A dominated long-running
candidate retains its first measured sample instead of being omitted; a
failed bounded attempt is reported as `resource_failure` or
`numerical_failure`.
Generic construction and numerical transport
are timed separately. A forced 100-digit generic `pFq` baseline exceeded 30
seconds, so the routine gate records this baseline and compares the series and
native production candidates instead of repeating the dominated route. The
old degree-40 enumeration has 62,891,499
multi-indices, whereas the degree-100 grouped recurrence performs 11,500
scalar recurrence updates including its absolute majorant. Timings depend on
Maple and the host CPU; correctness checks use reference values and connection
identities rather than timing alone.
The measured crossover table is recorded in
[`benchmark/PRODUCTION_BASELINE.md`](benchmark/PRODUCTION_BASELINE.md).

## Numerical modes and guarantees

`mode="fast"` uses guarded arbitrary-precision midpoint arithmetic. Its
checks comprise restricted-root step control, an `N` versus `N+Delta`
comparison, a sparse-safe local tail estimate, the differential residual,
independent reverse-path transport, and automatic working-precision and order
escalation. These are strong numerical checks, but not a proof by interval
arithmetic.

For the grouped Lauricella `FD` series, the primary stopping test uses an
absolute majorant. Let `q=max(abs(x_i))` and `B=sum(abs(b_i))`. After degree
`k`, the code bounds every later scalar and first-derivative shell by a
geometric ratio derived from

```math
q\frac{k+|a|}{k-|c|}\frac{k+B}{k}.
```

When this ratio is less than one and the resulting geometric tail is below the
working tolerance, `convergenceTest="majorant"`, and the `tailBound` field
records that bound. Signed parameters can make the absolute-parameter
majorant unusable even when the grouped series converges. In that case, the
evaluator compares
the sums at degrees `D/2` and `D` after passing the possible amplification
range of the lower parameter, and it repeats the degree-`D` sum at a higher
working precision. An accepted comparison has
`convergenceTest="doubled_degree"`, `tailBound=-1`, and a nonnegative
`doubledDegreeDifference`. This comparison is a fast-mode error estimate, not
an analytic tail bound. Failure of both checks sends `method="auto"` to the
next applicable method. For the series and closed-form routes,
`errorEstimate` includes a conservative allowance for rounding the returned
value to the requested significant digits; `roundingError` records that
allowance together with any measured working-precision discrepancy. The
specialized `FD` Pfaffian route also includes the boundary-series discrepancy,
the state-transport tail estimate, and the optional reverse-state discrepancy.
Generic Pfaffian diagnostics explicitly mark the transport error as
unknown.

The specialized `FD` Pfaffian method retains its state-transport checks. An
Euler quadrature result has `certificate="quadrature_unverified"`,
`errorStatus="unknown"`, and `errorEstimate=infinity`; its output-rounding
allowance remains in `roundingError`. The Euler quadrature and the
doubled-degree comparison are not interval certificates.

For generalized `pFq`, the recurrence uses an absolute geometric tail bound
after the parameter-dependent transient range and repeats the sum at a higher
working precision. The `FA`--`FC` convolution and the named Horn grids use
standard convergence-domain tests followed by degree and working-precision
comparisons. These comparisons are midpoint error estimates. Failure does not
produce a value; the automatic dispatcher selects a bounded continuation
route or raises a resource error.

For a Horn series with an exact nonpositive upper parameter and nonnegative
weights, the evaluator derives a conservative finite-support degree whenever
the resulting inequalities bound every coordinate. The finite degree,
`maximumDegree`, the total grid size, and the convolution or recurrence work
are checked before coefficient storage is allocated.

Before numerical conversion, the common evaluator and the specialized
Lauricella FD evaluator measure the exact distance of every real or complex
parameter from the nearest nonpositive integer in the complex plane. For an
arbitrary-precision Maple float, they first inspect the stored decimal mantissa
at its source precision; lowering `Digits` cannot erase a real or complex
displacement before the guard is chosen. The distance determines extra working
digits. A convergent
defining series is also evaluated beyond the near-pole transient degree plus a
tail margin, so a small prefix cannot hide a later regular coefficient surge.
If `maximumDegree` is below that range, automatic evaluation fails closed
instead of routing the under-resolved germ into continuation. Complete sums
are compared along a bounded precision ladder when two ordinary guard
precisions disagree; this comparison includes values and all requested first
derivatives. An unresolved terminating polynomial is never sent to an
uncertified Pfaffian fallback.

`mode="certified"` is reserved for a future complex-ball implementation.
Calling it raises an explicit error; the package never silently labels a
midpoint result as certified.

## Limitations

- Automatic Maple-native Appell evaluation is restricted to a nonterminating,
  non-near-pole principal point inside the defining convergence domain. Its
  error status is `heuristic`. Forced series and path-dependent Pfaffian routes
  remain available.
- The Horn and `FD` cost thresholds are calibrated by uncached 15-, 50-, and
  100-digit wall times. The benchmark gate reports a regression when a host or
  Maple release moves a measured crossover outside the admitted threshold.
- The derivative basis is selected by a high-precision numerical Macaulay
  reduction. Resonant parameters can change the rank or basis; use an affine
  epsilon regulator or nonresonant parameters when necessary.
- A rank-one generic connection supplies derivatives through its connection
  matrix. For a higher-rank generic basis that omits a requested first
  derivative, the evaluator raises an explicit unsupported-basis error.
- Exact factorization is available when the Horn parameters and epsilon value
  are exact. With inexact parameters, the returned pivot determinant can be
  left as a single numerical factor.
- Targets and Taylor centers on the detected singular locus are unsupported.
- `safe_opt` deliberately performs no shortcut without an interval
  certificate. `fast_opt` uses sampled homotopy strips and does not certify
  high-dimensional homotopy equivalence.
- `pathClass` is retained as provenance metadata. In this version, the actual
  representative is controlled by `branchSide` and explicit waypoints; named
  branch-cut atlases are not inferred from a string label. The canonical
  planner does not cross a colliding detour scale or substitute the opposite
  branch side automatically.
- Automatic multivariate meridians search coordinate slices. A general smooth
  divisor point and transverse direction may need to be supplied by the user.
- Direct rational user Pfaffian systems are supported, but symbolic gauge
  normalization and an automatically selected distinguished initial solution
  are not. Exact rational connections receive a symbolic curvature check;
  inexact user connections can be transported but cannot define a numerical
  monodromy representation in this release.
- Resonant Levelt bases, logarithmic local Frobenius bases, complex-ball tail
  bounds, braid generators, invariant-form solvers, and a GKZ frontend are not
  implemented.
- Epsilon interpolation is serial.
- Generic Horn-series enumeration stops before its cumulative work exceeds
  one million multi-indices. Specialized evaluators and Pfaffian transport are
  used instead when they are available.
- Generic Pfaffian construction is disabled above three variables. For at
  most three variables, the estimated seed order, column count, and dense
  matrix cell count are checked before a Macaulay matrix is allocated. A
  specialized connection or a convergent specialized series is required when
  this gate fails.
- The named Horn neighbor evaluator uses a conservative interior selector.
  A point outside that selector requires a Pfaffian path or a user-selected
  method. Full analytic convergence-region classifiers for all ten named Horn
  series are not implemented.

## License and references

`HyperPrecisionMaple` is distributed under the GNU General Public License,
version 3 only. See `LICENSE`, `NOTICE`, and `THIRD_PARTY_NOTICES.md`.

The method and benchmark examples are based on:

- S. Banik and S. Bera, *HyperPrecision: A Mathematica package for
  High-Precision Numerical Evaluation of Multivariate Hypergeometric
  Functions*, Computer Physics Communications 328 (2026), 110328,
  [arXiv:2605.30216v2](https://arxiv.org/abs/2605.30216v2).
- The GPL-3.0 reference implementation:
  <https://github.com/HyperPrecision/HyperPrecision>.
- F. Johansson, *Computing hypergeometric functions rigorously*,
  [arXiv:1606.06977](https://arxiv.org/abs/1606.06977).
- T. Kimura, *On the convergence of multivariable hypergeometric series*,
  Kyushu Journal of Mathematics 78 (2024), 129--153,
  [doi:10.2206/kyushujm.78.129](https://doi.org/10.2206/kyushujm.78.129).
