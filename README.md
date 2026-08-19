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

The implementation follows the Pfaffian-transport method of Banik and Bera.
It is independent of the reference Mathematica package and of
`HyperPrecision.jl`; neither is required at run time.

## Features

- Complete Horn series with positive or negative integral weight rows.
- Full Pfaffian connections for Appell `F1`--`F4`, Horn `G` and `H`, and
  Lauricella `FA`--`FD` functions.
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
`roundingError`.

The automatic dispatcher first groups exactly equal raw coordinates and sums
their exponents before any floating-point conversion. It then applies a
terminating series when `a` is a nonpositive integer, the product formula when
`c=a` on the principal sheet, the grouped series for `max(abs(x_i))<1`, the
Euler integral when its parameter and conditioning tests pass, and the
explicit rank-`n+1` Pfaffian transport otherwise. Large exponents and small
nonzero coordinate separations increase the internal working precision. In
the Euler integrand, opposite exponents at nearby coordinates are combined by
a uniformly bounded logarithmic expansion before quadrature.

Explicit waypoints force Pfaffian transport, since the grouped series and the
straight Euler integral evaluate the principal germ at the origin and cannot
retain a user-specified path class. The `c=a` product reduction is also
disabled when a path is supplied.

The specialized recurrence has a hard limit of 20,000,000 scalar updates.
An automatic call that exceeds this limit proceeds to the next applicable
method; a forced series call raises an error before allocating its coefficient
arrays. A terminating series allocates only through its exact polynomial
degree, independently of a larger `maximumDegree` setting. The generic Horn
evaluator has a separate one-million-term limit. Conditioning guards above
4,096 extra digits are rejected explicitly instead of attempting an
unbounded allocation.

An `AffineParameter(c,s)` denotes `c+s*epsilon`. Section 4.4 of the paper is
reproduced by

```maple
b2 := EpsilonParameter(1,1):
c2 := EpsilonParameter(-1,-1):
paperExpansion := AppellF2(2,3/2,b2,4,c2,3,11/3,
    'epsilonOrder'=1,'digits'=10):
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
the automatic method. Adversarial checks include terminating parameters,
`c=a`, exponents of size `10^40`, distinct coordinates separated by
`10^(-40)`, cancellation that defeats a last-shell stopping rule, and Euler
fallback.

The benchmark warms every applicable method and compares them at the same
point, precision, and transport settings. It requires the automatic method to
take at most `1.25` times the fastest applicable forced method plus `0.05`
seconds, and it imposes a five-second upper bound on the seven-variable
principal-germ evaluation. The old degree-40 enumeration has 62,891,499
multi-indices, whereas the degree-100 grouped recurrence performs 11,500
scalar recurrence updates including its absolute majorant. Timings depend on
Maple and the host CPU; correctness checks use reference values and connection
identities rather than timing alone.

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
next applicable method. For the series, closed-form, and Pfaffian routes,
`errorEstimate` also includes a conservative allowance for rounding the
returned value to the requested significant digits; `roundingError` records
that allowance together with any measured working-precision discrepancy.

The Euler and Pfaffian methods retain their separate numerical checks. The
Euler quadrature and the doubled-degree comparison are not interval
certificates.

`mode="certified"` is reserved for a future complex-ball implementation.
Calling it raises an explicit error; the package never silently labels a
midpoint result as certified.

## Limitations

- The derivative basis is selected by a high-precision numerical Macaulay
  reduction. Resonant parameters can change the rank or basis; use an affine
  epsilon regulator or nonresonant parameters when necessary.
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
