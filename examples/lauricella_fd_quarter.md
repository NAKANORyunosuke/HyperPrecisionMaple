# Lauricella FD Quarter-Parameter Sample

This worksheet evaluates the three-variable Lauricella function with parameters

$$
F_D^{(3)}\left(\frac14;\frac14,\frac14,\frac14;1;x_1,x_2,x_3\right).
$$

It also constructs the full Pfaffian connection of rank four and transports a
full fundamental matrix between two regular points.

## 1. Load HyperPrecisionMaple

The worksheet file is in the `examples` directory. The following cell loads
`HyperPrecision.mpl` from its parent directory.

```maple
restart:
worksheetDirectory := interface('worksheetdir'):
sourceFile := FileTools:-JoinPath([worksheetDirectory,"..","HyperPrecision.mpl"]):
read sourceFile:
with(HyperPrecision):
```

## 2. Fix the parameters

We fix the parameters and the working precision by

```maple
workDigits := 12:
Digits := workDigits+10:

a := 1/4:
b := [1/4,1/4,1/4]:
c := 1:
```

We denote the Gauss hypergeometric function by $F(a,b;c;t)$. On the diagonal,
the defining series gives

$$
F_D^{(3)}(a;b_1,b_2,b_3;c;t,t,t)
=F(a,b_1+b_2+b_3;c;t).
$$

For the fixed parameters, the right-hand side is

$$
F\left(\frac14,\frac34;1;t\right).
$$

The following cell checks the diagonal identity at $t=1/20$.

```maple
diagonalParameter := 1/20:
diagonalPoint := [diagonalParameter$3]:

fdDiagonal := LauricellaFD(a,b,c,diagonalPoint,'digits'=workDigits):
gaussDiagonal := Hypergeometric2F1(1/4,3/4,1,diagonalParameter,'digits'=workDigits):
diagonalError := evalf(abs(fdDiagonal-gaussDiagonal)):

fdDiagonal;
gaussDiagonal;
diagonalError;
```

## 3. Construct the full Pfaffian connection

We construct the complete Horn series and the full Pfaffian connection.

```maple
fdSeries := FunctionSeries("LauricellaFD",[a,op(b),c],3):
fdSystem := FindPfaffianSystem(fdSeries,'digits'=workDigits):

rankData := FindHolonomicRank(fdSeries,'digits'=workDigits):
flatness := CheckIntegrability(fdSystem):
divisor := SingularFactors(fdSystem):

rankData;
flatness:-passed;
divisor:-factors;
```

The basis begins with the function itself and contains its three first partial
derivatives. The singular factors include $x_i=0$, $x_i=1$, and $x_i=x_j$ for
distinct indices $i$ and $j$.

## 4. Plan a regular path

We choose two points satisfying $x_1>x_2>x_3>0$. The segment remains away from
the detected singular factors.

```maple
basepoint := [1/10,1/20,1/40]:
target := [1/5,1/10,1/20]:

initialVector := InitialVector(fdSystem,basepoint,'digits'=workDigits):
path := PlanPath(fdSystem,basepoint,target,'mode'="canonical",'digits'=workDigits):

path:-points;
```

The following cell displays the path in the three coordinate variables.

```maple
plots:-pointplot3d(path:-points,'connect'=true,'axes'='boxed','labels'=["x1","x2","x3"],'symbol'='solidcircle','color'='blue');
```

## 5. Transport the full fundamental matrix

The next cell transports all four columns. It also performs an independent
transport along the reversed path.

```maple
transport := TransportFundamental(fdSystem,path,'digits'=workDigits,'taylorOrder'=24,'verificationOrder'=4,'verifyReverse'=true):

continuedVector := ApplyTransport(transport,initialVector):
directTarget := LauricellaFD(a,b,c,target,'digits'=workDigits):
transportError := evalf(abs(continuedVector[1]-directTarget)):
```

We display the distinguished solution and the transport diagnostics.

```maple
continuedVector[1];
directTarget;
transportError;
nops(transport:-history);
transport:-diagnostics:-reverseError;
transport:-diagnostics:-maxDifferentialResidual;
```

The factorized transport can be materialized when a dense matrix is required.

```maple
denseTransport := MaterializeTransport(transport):
denseTransport;
```

## 6. Check the sample

The tested run has rank four, zero displayed diagonal error, transport error
below $10^{-20}$, and reverse residual below $10^{-23}$. The following cell
uses looser thresholds so that the check does not depend on displayed rounding.

```maple
CheckSample := proc(rankDatum,flatnessRecord,diagonalResidual,transportResidual,reverseResidual) if rankDatum[1] <> 4 or not flatnessRecord:-passed or diagonalResidual > 1.e-9 or transportResidual > 1.e-7 or reverseResidual > 1.e-6 then error "Lauricella FD worksheet regression failed"; end if; return "Lauricella FD quarter-parameter sample passed."; end proc:

CheckSample(rankData,flatness,diagonalError,transportError,transport:-diagnostics:-reverseError);
```

The variables `basepoint`, `target`, and `workDigits` can be changed in their
cells. A path that meets a detected singular factor is rejected or receives a
canonical complex detour according to the selected path mode.
