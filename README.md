# HyperPrecisionMaple

`HyperPrecisionMaple` evaluates complete Horn-type multivariate
hypergeometric series with arbitrary precision at real or complex points. It
implements the Pfaffian-transport method of Banik and Bera in Maple 2025.

This Maple port is maintained separately from the reference Mathematica
implementation and from `HyperPrecision.jl`. It does not require Mathematica,
FiniteFlow, or AMFlow.

The package performs the following computations.

1. It obtains the neighbouring coefficient ratios of a Horn series.
2. It generates the annihilating partial differential equations.
3. It differentiates these equations and determines a finite derivative basis
   by a high-precision Macaulay-matrix reduction.
4. It restricts the Pfaffian connection to a contour from the origin to the
   target point.
5. It transports the boundary vector by matching local Frobenius power
   series.
6. It reconstructs a Laurent expansion from evaluations on an epsilon grid.

## Requirements

- Maple 2025. Earlier releases have not been tested.
- The command-line tests use `cmaple`.

## Loading the package

Start Maple in this directory and read the source file.

```maple
read "HyperPrecision.mpl":
with(HyperPrecision):
```

## Fixed-parameter evaluation

The following evaluation lies outside the disk of convergence of the defining
Gauss series.

```maple
hpValue := HypergeometricPFQ([1, 1], [2], -2, 'digits' = 40);

# log(3)/2
```

The predefined interfaces are

- `Hypergeometric2F1` and `HypergeometricPFQ`, with the latter restricted to
  functions of type pF(p-1);
- `AppellF1`, `AppellF2`, `AppellF3`, and `AppellF4`;
- `HornG1`, `HornG2`, and `HornG3`;
- `HornH1` through `HornH7`;
- `LauricellaFA`, `LauricellaFB`, `LauricellaFC`, and `LauricellaFD`.

For example, the two-variable Lauricella function `FD` coincides with Appell's
function `F1`.

```maple
appellValue := AppellF1(1/2, 2/3, 3/4, 5/2, 1/10, 1/5, 'digits' = 30):
lauricellaValue := LauricellaFD(1/2, [2/3, 3/4], 5/2, [1/10, 1/5],
    'digits' = 30):
evalf(abs(appellValue-lauricellaValue));
```

## Laurent expansion in epsilon

An `AffineParameter(c, s)` represents `c + s*epsilon`. The example in Section
4.4 of the paper is computed as follows.

```maple
b2 := EpsilonParameter(1, 1):
c2 := EpsilonParameter(-1, -1):

paperExpansion := AppellF2(
    2, 3/2, b2, 4, c2, 3, 11/3,
    'epsilonOrder' = 1,
    'digits' = 10
):

LaurentCoefficient(paperExpansion, -1);
LaurentCoefficient(paperExpansion, 0);
LaurentCoefficient(paperExpansion, 1);
paperExpansion:-estimatedError;
LaurentPolynomial(paperExpansion, epsilon);
```

With `branchSide = -1`, the coefficients agree with the branch reported in
the paper:

```text
epsilon^(-1):   0.5149686376
epsilon^(0):    0.528662817 - 4.194390019*I
epsilon^(1):  -10.978138236 - 4.834942296*I
```

The pole order is inferred from affine Pochhammer parameters. The keyword
`poleOrder` overrides the inferred order.

## A general Horn series

We define

```math
F(x)=\sum_{m\in\mathbb N_0^n}
\frac{\prod_r(a_r)_{\mu_r\cdot m}}
     {\prod_s(b_s)_{\nu_s\cdot m}}\frac{x^m}{m!}.
```

The rows of `upperWeights` are the vectors `mu_r`, and the rows of
`lowerWeights` are the vectors `nu_s`.

```maple
f2series := HornSeries(
    [2, 3/2, 5/4],
    [[1, 1], [1, 0], [0, 1]],
    [4, 7/3],
    [[1, 0], [0, 1]],
    "F2"
):

orders := FindHypergeometricOrder(f2series, 'digits' = 40):
rankAndBasis := FindHolonomicRank(f2series, 'digits' = 40):
f2system := FindPfaffianSystem(f2series, 'digits' = 40):
matrices := ConnectionMatrices(f2system, [1/10, 1/5]):
check := CheckIntegrability(f2system):
f2value := Evaluate(f2series, [3, 11/3], 'digits' = 30):
```

`PDEGenerator` returns the sparse annihilating operators. A differential
multi-index is a table key, and its value is a sparse polynomial table in the
kinematic variables. `FindHolonomicRank` returns `[rank, basis]`. The basis uses
ordinary partial derivatives and is sorted by total derivative order.

The keyword `branchSide` is `-1` by default. The values `-1` and `1` select the
two sides of a real singular locus. Set it to `0` for a straight real contour,
or pass a list of complex contour points with the keyword `waypoints`.

## AGM cross-check

The test `test/agm.mpl` compares the transported value with Gauss's identity

```math
{}_2F_1\left(\tfrac12,\tfrac12;1;z\right)
=\operatorname{AGM}(1,\sqrt{1-z})^{-1}.
```

The extended test uses `z = 1-10^(-8)`, where the defining hypergeometric
series converges too slowly for the truncation used by the package.

## Tests

From the `test` directory, run

```powershell
cmaple -q runtests.mpl
cmaple -q agm.mpl
cmaple -q paper_example.mpl
```

On Windows, the repository runner provides the same commands:

```powershell
powershell -ExecutionPolicy Bypass -File .\run-tests.ps1
powershell -ExecutionPolicy Bypass -File .\run-tests.ps1 -AGM
powershell -ExecutionPolicy Bypass -File .\run-tests.ps1 -AGM -Extended
```

The first command runs the regular test suite. The AGM and paper examples are
separate because they perform several high-precision transports.

## Numerical scope

- The derivative-basis reduction is numerical. Parameters on a resonant locus
  can change the holonomic rank or the selected derivative basis. Add an
  affine epsilon regulator or pass non-resonant parameters in this case.
- Targets on the singular locus are not supported.
- Epsilon-grid evaluations are serial in this version.
- The package handles the complete Horn form represented by `HornSeries`.
  It does not parse a symbolic summand automatically.

## License and provenance

`HyperPrecisionMaple` is distributed under GNU General Public License version
3 only. See `LICENSE`.

This package is a reimplementation of the method of Banik and Bera. Their
Mathematica reference implementation is distributed under GPL-3.0 at
<https://github.com/HyperPrecision/HyperPrecision>. This repository does not
include the Mathematica source files. See `NOTICE` for attribution.

## Reference

- S. Banik and S. Bera, *HyperPrecision: A Mathematica package for
  High-Precision Numerical Evaluation of Multivariate Hypergeometric
  Functions*, Computer Physics Communications 328 (2026), 110328,
  [arXiv:2605.30216v2](https://arxiv.org/abs/2605.30216v2).
