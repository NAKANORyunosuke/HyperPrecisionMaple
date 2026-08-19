restart:

worksheetDirectory := interface('worksheetdir'):
sourceFile := FileTools:-JoinPath([worksheetDirectory,"..","HyperPrecision.mpl"]):
read sourceFile:
with(HyperPrecision):

workDigits := 12:
Digits := workDigits+10:

a := 1/4:
b := [1/4,1/4,1/4]:
c := 1:

# On the diagonal, Lauricella FD reduces to a Gauss hypergeometric function.
diagonalParameter := 1/20:
diagonalPoint := [diagonalParameter$3]:
fdDiagonal := LauricellaFD(a,b,c,diagonalPoint,'digits'=workDigits):
gaussDiagonal := Hypergeometric2F1(1/4,3/4,1,diagonalParameter,'digits'=workDigits):
diagonalError := evalf(abs(fdDiagonal-gaussDiagonal)):

printf("Lauricella FD diagonal value = %a\n",fdDiagonal):
printf("Gauss diagonal value         = %a\n",gaussDiagonal):
printf("diagonal identity error      = %a\n\n",diagonalError):

# Build the explicit full rank-four Pfaffian system.  This constructor avoids
# generic Macaulay reduction and remains practical in higher dimensions.
fdSystem := LauricellaFDPfaffianSystem(a,b,c,'digits'=workDigits):
rankData := [fdSystem:-rank,fdSystem:-basis]:
flatness := CheckIntegrability(fdSystem):
divisor := SingularFactors(fdSystem):

printf("holonomic rank = %d\n",rankData[1]):
printf("basis          = %a\n",rankData[2]):
printf("flatness       = %a\n",flatness:-passed):
printf("singular factors = %a\n\n",divisor:-factors):

# Transport the full fundamental matrix between two regular points.
basepoint := [1/10,1/20,1/40]:
target := [1/5,1/10,1/20]:
initialVector := LauricellaFDInitialVector(a,b,c,basepoint,'digits'=workDigits):
path := PlanPath(fdSystem,basepoint,target,'mode'="canonical",'digits'=workDigits):
transport := TransportFundamental(fdSystem,path,'digits'=workDigits,'taylorOrder'=24,'verificationOrder'=4,'verifyReverse'=true):
continuedVector := ApplyTransport(transport,initialVector):
directTarget := LauricellaFD(a,b,c,target,'digits'=workDigits):
transportError := evalf(abs(continuedVector[1]-directTarget)):

printf("continued FD value = %a\n",continuedVector[1]):
printf("direct FD value    = %a\n",directTarget):
printf("transport error    = %a\n",transportError):
printf("Taylor patches     = %d\n",nops(transport:-history)):
printf("reverse residual   = %a\n",transport:-diagnostics:-reverseError):
printf("max ODE residual   = %a\n",transport:-diagnostics:-maxDifferentialResidual):

CheckSample := proc(rankDatum,flatnessRecord,diagonalResidual,transportResidual,reverseResidual) if rankDatum[1] <> 4 or not flatnessRecord:-passed or diagonalResidual > 1.e-9 or transportResidual > 1.e-7 or reverseResidual > 1.e-6 then error "Lauricella FD worksheet regression failed"; end if; return "Lauricella FD quarter-parameter sample passed."; end proc:

printf("\n%s\n",CheckSample(rankData,flatness,diagonalError,transportError,transport:-diagnostics:-reverseError)):
