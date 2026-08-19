restart:
read "../HyperPrecision.mpl":
with(HyperPrecision):

Digits := 30:

# Backward-compatible distinguished-solution evaluation.
started := time():
legacyValue := HypergeometricPFQ([1,1],[2],-2,'digits'=25):
legacyTime := time()-started:
legacyError := max(0.,evalf(abs(legacyValue-log(3)/2))):
printf("legacy Gauss evaluation: time=%a seconds, error=%a\n",
    legacyTime,legacyError):

seriesObject := FunctionSeries("Hypergeometric2F1",[1/3,1/4,1/2],1):
started := time():
hpSystem := FindPfaffianSystem(seriesObject,'digits'=16):
buildTime := time()-started:

waypoints := [[.3],[.4],[.5]]:
canonicalPlan := PlanPath(hpSystem,[.2],[.6],
    'mode'="canonical",'waypoints'=waypoints,'digits'=12):
fastPlan := PlanPath(hpSystem,[.2],[.6],
    'mode'="fast_opt",'waypoints'=waypoints,'digits'=12):

started := time():
canonicalTransport := TransportFundamental(hpSystem,canonicalPlan,
    'digits'=10,'taylorOrder'=24,'verificationOrder'=4,
    'verifyReverse'=false):
canonicalTime := time()-started:

started := time():
fastTransport := TransportFundamental(hpSystem,fastPlan,
    'digits'=10,'taylorOrder'=24,'verificationOrder'=4,
    'verifyReverse'=true,'maximumPrecisionEscalations'=1):
fastTimeIncludingReverse := time()-started:

printf("Pfaffian build: time=%a seconds, rank=%d\n",
    buildTime,nops(hpSystem:-basis)):
printf("canonical: segments=%d, Taylor patches=%d, time=%a seconds\n",
    nops(canonicalPlan:-points)-1,nops(canonicalTransport:-history),
    canonicalTime):
printf("fast_opt: segments=%d, Taylor patches=%d, time including reverse=%a seconds\n",
    nops(fastPlan:-points)-1,nops(fastTransport:-history),
    fastTimeIncludingReverse):
printf("fast_opt reverse residual=%a, estimated error=%a, shortcuts=%d\n",
    fastTransport:-diagnostics:-reverseError,
    fastTransport:-diagnostics:-estimatedError,
    fastPlan:-diagnostics:-shortcutsAccepted):

if nops(fastPlan:-points) >= nops(canonicalPlan:-points) then
    error "fast_opt did not reduce the measured path-segment count";
end if:
if nops(fastTransport:-history) >= nops(canonicalTransport:-history) then
    error "fast_opt did not reduce the measured Taylor-patch count";
end if:

# A known monodromy invariant around x=1.
generators := MeridianGenerators(hpSystem,[1/5],
    'components'=[1],'digits'=10,'vertices'=8,'radius'=1/10):
started := time():
representation := Monodromy(hpSystem,generators,
    'digits'=6,'taylorOrder'=16,'verificationOrder'=2,
    'safetyFactor'=.75,'verifyReverse'=false,
    'maximumPrecisionEscalations'=0):
monodromyTime := time()-started:
monodromyMatrix := MonodromyMatrix(representation,"D1"):
expectedPhase := evalf[30](exp(-Pi*I/6)):
determinantError := evalf(abs(
    LinearAlgebra:-Determinant(monodromyMatrix)-expectedPhase)):
traceError := evalf(abs(
    LinearAlgebra:-Trace(monodromyMatrix)-(1+expectedPhase))):
printf("Gauss monodromy: time=%a seconds, determinant error=%a, trace error=%a\n",
    monodromyTime,determinantError,traceError):

printf("Pfaffian benchmark completed.\n"):
quit:
