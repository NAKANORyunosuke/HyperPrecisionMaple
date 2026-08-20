restart:
read "../HyperPrecision.mpl":
with(HyperPrecision):

failures := 0:

CheckClose := proc(label,actual,expectedValue,tolerance) global failures; local actualExact,expectedExact,err,toleranceExact; actualExact := convert(Re(actual),rational)+I*convert(Im(actual),rational); expectedExact := convert(Re(expectedValue),rational)+I*convert(Im(expectedValue),rational); toleranceExact := convert(tolerance,rational); err := evalf[40](abs(actualExact-expectedExact)); if evalb(err > toleranceExact) then failures := failures+1; printf("FAIL %s: error=%a actual=%a expected=%a\n",label,err,actual,expectedValue); else printf("PASS %s: error=%a\n",label,err); end if; end proc:
CheckTrue := proc(label,condition) global failures; if condition then printf("PASS %s\n",label); else failures := failures+1; printf("FAIL %s\n",label); end if; end proc:

quarter3Reference := evalf[40](1.0873608547101928769255558171798482881859209127925):
quarter7Reference := evalf[40](1.1420121941001597687800075211173977305285559453994):
quarter7DerivativeReference := [evalf[40](.13379115778165143470437821067742502136668293838365),evalf[40](.11186140012877355864172229274814215227800348250890),evalf[40](.10376156396491352762339631119775774472878712938156),evalf[40](.099529025399951066858418816641409864306043941504891),evalf[40](.096925174567551199058931629029213546820536045895809),evalf[40](.095160907003507909310763349216086651591702144782414),evalf[40](.093886286680443567256305337428224290014419352674894)]:
b7 := [1/4$7]:
x7 := [1/2,1/3,1/4,1/5,1/6,1/7,1/8]:

startTime := time():
auto7 := LauricellaFD(1/4,b7,1,x7,'digits'=15,'returnDiagnostics'=true):
auto7Elapsed := time()-startTime:
CheckClose("FD7 grouped-series value",auto7:-value,quarter7Reference,1.e-14):
CheckTrue("FD7 auto method",evalb(auto7:-methodUsed="series")):
CheckTrue("FD7 hard performance gate",evalb(auto7Elapsed < 5)):
CheckTrue("FD7 absolute tail and output-rounding bounds",evalb(auto7:-tailBound >= 0 and auto7:-tailBound < 1.e-18 and auto7:-errorEstimate >= auto7:-tailBound and auto7:-errorEstimate < 1.e-13)):

initial7 := LauricellaFDInitialVector(1/4,b7,1,x7,'digits'=15,'returnDiagnostics'=true):
CheckClose("FD7 initial scalar",initial7:-value[1],quarter7Reference,1.e-14):
for i to 7 do CheckClose(cat("FD7 derivative ",i),initial7:-value[i+1],quarter7DerivativeReference[i],1.e-14); end do:
CheckTrue("FD7 initial-vector method",evalb(initial7:-methodUsed="series")):

system7 := LauricellaFDPfaffianSystem(1/4,b7,1,'digits'=15):
CheckTrue("FD7 explicit rank",evalb(system7:-rank=8)):
system3 := LauricellaFDPfaffianSystem(1/4,[1/4$3],1,'digits'=15):
CheckTrue("FD3 exact flatness",CheckExactFlatness(system3):-passed):

pfaffian3 := LauricellaFD(1/4,[1/4$3],1,[1/2,1/3,1/4],'digits'=8,'method'="pfaffian",'frobeniusOrder'=24,'returnDiagnostics'=true):
CheckClose("FD3 explicit Pfaffian",pfaffian3:-value,quarter3Reference,1.e-7):
CheckTrue("FD3 forced method",evalb(pfaffian3:-methodUsed="pfaffian" and pfaffian3:-transportFactors>0)):
routeSeries := LauricellaFD(1/4,[1/4,1/4],1,[1/5,1/6],'digits'=8,'method'="series",'returnDiagnostics'=true):
routeEuler := LauricellaFD(1/4,[1/4,1/4],1,[1/5,1/6],'digits'=8,'method'="euler",'returnDiagnostics'=true):
routeClosed := LauricellaFD(2/3,[1/4],2/3,[1/5],'digits'=8,'returnDiagnostics'=true):
CheckTrue("FD route working precision is effective precision",evalb(routeSeries:-workingDigits>=22 and routeEuler:-workingDigits>=22 and pfaffian3:-workingDigits>=26 and routeClosed:-workingDigits>=22)):
CheckTrue("forced Euler diagnostics are honest",evalb(routeEuler:-certificate="quadrature_unverified" and routeEuler:-errorStatus="unknown" and routeEuler:-errorEstimate=infinity and routeEuler:-roundingError>=0)):

radialRoots := RestrictedSingularRoots(system3,[1/16,1/24,1/32],[1/2,1/3,1/4],'digits'=12):
CheckTrue("square-free restricted roots",evalb(nops(radialRoots)=4)):

diagonal7 := LauricellaFD(1/4,b7,1,[.9$7],'digits'=15,'returnDiagnostics'=true):
CheckClose("FD7 diagonal reduction",diagonal7:-value,evalf[30](4.0474467234750604716962305635510883237162779443989),1.e-13):
CheckTrue("FD7 diagonal dispatch avoids full-rank transport",evalb(member(diagonal7:-methodUsed,["series","euler"]) and diagonal7:-compressedDimension=1)):
diagonalBoundary7 := LauricellaFD(1/4,b7,1,[1-1/10^8$7],'digits'=10,'returnDiagnostics'=true):
CheckClose("FD7 diagonal near-singular boundary",diagonalBoundary7:-value,evalf[25](30010547.627274346492673249188335914156712652219188),1.e-2):
CheckTrue("FD7 near-singular compression",evalb(diagonalBoundary7:-methodUsed="euler" and diagonalBoundary7:-compressedDimension=1)):

zeroSum := LauricellaFD(2/5,[2/3,-2/3],7/5,[.37,.37],'digits'=15,'returnDiagnostics'=true):
CheckClose("zero-sum coalescence",zeroSum:-value,1,1.e-15):
CheckTrue("zero-sum scalar compression",evalb(zeroSum:-methodUsed="exact_reduction" and zeroSum:-compressedDimension=0)):
CheckTrue("zero-sum midpoint is not certified",evalb(zeroSum:-certificate="exact_cancellation" and zeroSum:-errorStatus="heuristic" and zeroSum:-errorEstimate>0 and zeroSum:-roundingError>0)):

branchSideFull := LauricellaFD(1/4,[1/4,1/4],1,[1/5,1/5],'digits'=8,'branchSide'=0,'returnDiagnostics'=true):
branchSideReference := evalf[25](hypergeom([1/4,1/2],[1],1/5)):
CheckClose("branch-side full-coordinate FD value",branchSideFull:-value,branchSideReference,1.e-7):
CheckTrue("branch-side FD retains all coordinates",evalb(branchSideFull:-methodUsed="pfaffian" and branchSideFull:-compressedDimension=2 and branchSideFull:-pathDependent and branchSideFull:-branchProvenance="explicit_transport")):

nearCoalescent := LauricellaFD(1/4,b7,1,[.5-3.e-12,.5-2.e-12,.5-1.e-12,.5,.5+1.e-12,.5+2.e-12,.5+3.e-12],'digits'=12,'returnDiagnostics'=true):
CheckTrue("near-coalescent dispatch avoids ill-conditioned Pfaffian",evalb(nearCoalescent:-methodUsed="series")):

terminating := LauricellaFD(-3,[1/4],7/6,[9/10],'digits'=15,'returnDiagnostics'=true):
terminatingReference := evalf[30](hypergeom([-3,1/4],[7/6],9/10)):
CheckClose("terminating upper parameter",terminating:-value,terminatingReference,1.e-14):
CheckTrue("terminating dispatch",evalb(terminating:-methodUsed="series" and terminating:-degree=3)):
terminatingZero := LauricellaFD(0,[7/5],3/2,[2],'digits'=15,'method'="series",'maximumDegree'=0,'returnDiagnostics'=true,'returnDerivatives'=true):
CheckClose("zero upper parameter",terminatingZero:-value,1,1.e-15):
CheckTrue("zero upper parameter degree and derivatives",evalb(terminatingZero:-methodUsed="series" and terminatingZero:-degree=0 and terminatingZero:-derivatives=[0.])):
CheckTrue("zero upper parameter bounded provenance",evalb(terminatingZero:-errorStatus<>"certified" and terminatingZero:-branchProvenance="principal_origin_germ")):
terminatingExterior := LauricellaFD(-3,[1/4],7/6,[2],'digits'=15,'maximumDegree'=100000000,'returnDiagnostics'=true):
terminatingExteriorReference := evalf[30](hypergeom([-3,1/4],[7/6],2)):
CheckClose("terminating series outside the unit disk",terminatingExterior:-value,terminatingExteriorReference,1.e-14):
CheckTrue("terminating series uses its exact allocation degree",evalb(terminatingExterior:-methodUsed="series" and terminatingExterior:-degree=3)):
terminatingExactCap := LauricellaFD(-3,[1/4],7/6,[2],'digits'=15,'method'="series",'maximumDegree'=3,'returnDiagnostics'=true):
CheckClose("terminating series accepts its exact maximum degree",terminatingExactCap:-value,terminatingExteriorReference,1.e-14):
CheckTrue("terminating exact cap metadata",evalb(terminatingExactCap:-degree=3)):

closedForm := LauricellaFD(2/3,[5/7],2/3,[99/100],'digits'=15,'returnDiagnostics'=true):
CheckClose("c equals a product reduction",closedForm:-value,evalf[30]((1-99/100)^(-5/7)),1.e-14):
CheckTrue("c equals a dispatch",evalb(closedForm:-methodUsed="closed_form")):

singularLowerRejected := false:
try LauricellaFD(1,[0],0,[1/5],'digits'=15): catch: singularLowerRejected := true: end try:
CheckTrue("singular lower parameter is rejected before zero reduction",singularLowerRejected):
nearLower := LauricellaFD(1/3,[1/4],-2+1/10^40,[1/10],'digits'=15,'method'="series",'maximumDegree'=80,'returnDiagnostics'=true):
nearLowerReference := evalf[70](hypergeom([1/3,1/4],[-2+1/10^40],1/10)):
CheckTrue("exact near-pole lower parameter remains regular",evalb(evalf[30](abs(nearLower:-value-nearLowerReference)/max(abs(nearLowerReference),1))<1.e-14)):
nearTerminating := LauricellaFD(-3+1/10^40,[1/4],7/6,[1/10],'digits'=15,'method'="series",'maximumDegree'=80,'returnDiagnostics'=true):
CheckTrue("near-integral upper parameter does not terminate",evalb(nearTerminating:-degree>3)):

# Stored arbitrary-precision floats must retain a displacement from a lower
# pole before the public evaluator lowers Digits.  One-variable FD is checked
# against the independent pFq kernel, including the first derivative.
fdSourceDigits := Digits:
Digits := 220:
fdNearRealExact := -100+1/10^100:
fdNearDiagonalExact := -100+1/10^100+I/10^100:
fdNearMinusTwoExact := -2+1/10^80+I/10^80:
fdNearRealFloat := evalf(fdNearRealExact):
fdNearDiagonalFloat := evalf(fdNearDiagonalExact):
fdNearMinusTwoFloat := evalf(fdNearMinusTwoExact):
fdStoredA := evalf(1/4):
fdStoredX := evalf(1/10):
Digits := fdSourceDigits:
fdStoredSeries := LauricellaFD(fdStoredA,[1/4],1,[fdStoredX],'digits'=15,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true):
fdStoredInitial := LauricellaFDInitialVector(fdStoredA,[1/4],1,[fdStoredX],'digits'=15,'maximumDegree'=260,'returnDiagnostics'=true):
fdStoredEuler := LauricellaFD(fdStoredA,[1/4],1,[fdStoredX],'digits'=8,'method'="euler",'returnDiagnostics'=true):
CheckTrue("stored-float FD series source floor",evalb(fdStoredSeries:-workingDigits>=220)):
CheckTrue("stored-float FD initial-vector source floor",evalb(fdStoredInitial:-workingDigits>=220)):
CheckTrue("stored-float FD Euler source floor",evalb(fdStoredEuler:-workingDigits>=220 and fdStoredEuler:-certificate="quadrature_unverified" and fdStoredEuler:-errorEstimate=infinity)):
fdNearRealReference := Hypergeometric2F1(1/3,2/5,fdNearRealExact,1/100,'digits'=24,'method'="series",'returnDerivatives'=true):
fdNearDiagonalReference := Hypergeometric2F1(1/3,2/5,fdNearDiagonalExact,1/100,'digits'=24,'method'="series",'returnDerivatives'=true):
fdNearMinusTwoReference := Hypergeometric2F1(1/3,2/5,fdNearMinusTwoExact,1/10,'digits'=24,'method'="series",'returnDerivatives'=true):
fdNearRealFloatResult := LauricellaFD(1/3,[2/5],fdNearRealFloat,[1/100],'digits'=20,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=true):
fdNearDiagonalExactResult := LauricellaFD(1/3,[2/5],fdNearDiagonalExact,[1/100],'digits'=20,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=true):
fdNearDiagonalFloatResult := LauricellaFD(1/3,[2/5],fdNearDiagonalFloat,[1/100],'digits'=20,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=true):
fdNearDiagonalAutoResult := LauricellaFD(1/3,[2/5],fdNearDiagonalFloat,[1/100],'digits'=20,'method'="auto",'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=true):
fdNearMinusTwoFloatResult := LauricellaFD(1/3,[2/5],fdNearMinusTwoFloat,[1/10],'digits'=20,'method'="series",'maximumDegree'=160,'returnDiagnostics'=true,'returnDerivatives'=true):
CheckTrue("stored-float real near-pole FD value",evalb(evalf[30](abs(fdNearRealFloatResult:-value-fdNearRealReference[1])/max(1,abs(fdNearRealReference[1])))<1.e-18)):
CheckTrue("stored-float real near-pole FD derivative",evalb(evalf[30](abs(fdNearRealFloatResult:-derivatives[1]-fdNearRealReference[2])/max(1,abs(fdNearRealReference[2])))<1.e-18)):
CheckTrue("exact diagonal near-pole FD value",evalb(evalf[30](abs(fdNearDiagonalExactResult:-value-fdNearDiagonalReference[1])/max(1,abs(fdNearDiagonalReference[1])))<1.e-18)):
CheckTrue("stored-float diagonal near-pole FD value",evalb(evalf[30](abs(fdNearDiagonalFloatResult:-value-fdNearDiagonalReference[1])/max(1,abs(fdNearDiagonalReference[1])))<1.e-18)):
CheckTrue("stored-float diagonal near-pole FD derivative",evalb(evalf[30](abs(fdNearDiagonalFloatResult:-derivatives[1]-fdNearDiagonalReference[2])/max(1,abs(fdNearDiagonalReference[2])))<1.e-18)):
CheckTrue("near-pole forced and automatic contract",evalb(fdNearDiagonalAutoResult:-methodUsed="series" and fdNearDiagonalAutoResult:-degree=fdNearDiagonalFloatResult:-degree and fdNearDiagonalAutoResult:-errorStatus=fdNearDiagonalFloatResult:-errorStatus and fdNearDiagonalAutoResult:-branchProvenance=fdNearDiagonalFloatResult:-branchProvenance and evalf[30](abs(fdNearDiagonalAutoResult:-value-fdNearDiagonalFloatResult:-value))<1.e-22 and evalf[30](abs(fdNearDiagonalAutoResult:-derivatives[1]-fdNearDiagonalFloatResult:-derivatives[1]))<1.e-22)):
CheckTrue("stored-float diagonal c=-2 FD value",evalb(evalf[30](abs(fdNearMinusTwoFloatResult:-value-fdNearMinusTwoReference[1])/max(1,abs(fdNearMinusTwoReference[1])))<1.e-18)):
CheckTrue("near-pole FD evaluates past the lower-pole index",evalb(fdNearRealFloatResult:-degree>100 and fdNearDiagonalExactResult:-degree>100 and fdNearDiagonalFloatResult:-degree>100)):
CheckTrue("near-pole FD reports final-rounding scale",evalb(fdNearDiagonalFloatResult:-errorEstimate>=1.e-20*max(1,abs(fdNearDiagonalFloatResult:-value)) and fdNearDiagonalFloatResult:-errorEstimate<1.e-17*max(1,abs(fdNearDiagonalFloatResult:-value)))):
fdNearInitial := LauricellaFDInitialVector(1/3,[2/5],fdNearDiagonalFloat,[1/100],'digits'=20,'maximumDegree'=260,'returnDiagnostics'=true):
CheckTrue("stored-float near-pole FD initial vector",evalb(fdNearInitial:-degree>100 and evalf[30](abs(fdNearInitial:-value[1]-fdNearDiagonalReference[1])/max(1,abs(fdNearDiagonalReference[1])))<1.e-18 and evalf[30](abs(fdNearInitial:-value[2]-fdNearDiagonalReference[2])/max(1,abs(fdNearDiagonalReference[2])))<1.e-18)):
fdNearDegreeRejected := false:
try LauricellaFD(1/3,[2/5],fdNearDiagonalFloat,[1/100],'digits'=20,'method'="series",'maximumDegree'=100): catch: fdNearDegreeRejected := evalb(StringTools:-Search("did not converge",convert(lastexception[2],string))>0): end try:
CheckTrue("near-pole FD fails closed below the pole index",fdNearDegreeRejected):

# The same source-precision path must fail before evaluation when the guard
# exceeds its public 4096-digit conditioning cap.
Digits := 17000:
fdCapRealFloat := evalf(-2+1/10^5000):
fdCapDiagonalFloat := evalf(-2+1/10^5000+I/10^5000):
Digits := fdSourceDigits:
fdCapRealRejected := false:
try LauricellaFD(1/3,[2/5],fdCapRealFloat,[1/10],'digits'=15,'method'="series",'maximumDegree'=20): catch: fdCapRealRejected := evalb(StringTools:-Search("conditioning guard exceeds 4096 digits",convert(lastexception[2],string))>0): end try:
CheckTrue("stored-float real FD conditioning cap",evalb(fdCapRealRejected and Digits=fdSourceDigits)):
fdCapDiagonalRejected := false:
try LauricellaFD(1/3,[2/5],fdCapDiagonalFloat,[1/10],'digits'=15,'method'="series",'maximumDegree'=20): catch: fdCapDiagonalRejected := evalb(StringTools:-Search("conditioning guard exceeds 4096 digits",convert(lastexception[2],string))>0): end try:
CheckTrue("stored-float diagonal FD conditioning cap",evalb(fdCapDiagonalRejected and Digits=fdSourceDigits)):

largeB := 10^40:
largeCancellation := LauricellaFD(1/3,[largeB,-largeB+1],7/6,[1/2,1/2],'digits'=15,'returnDiagnostics'=true):
largeCancellationReference := evalf[40](1.214325323943790805909970844890465624277517422437454637):
CheckClose("exact compression with large cancelling exponents",largeCancellation:-value,largeCancellationReference,1.e-14):
CheckTrue("large exact compression dimension",evalb(largeCancellation:-compressedDimension=1)):

largeNearCoordinates := LauricellaFD(1/3,[largeB,-largeB],7/6,[1/2,1/2+1/largeB],'digits'=15,'returnDiagnostics'=true):
largeNearReference := evalf[40](.730379462420801339183052500462545280864244243982685558):
CheckClose("near coordinates survive high-precision evaluation",largeNearCoordinates:-value,largeNearReference,1.e-14):
CheckTrue("large near-coordinate dispatch",evalb(largeNearCoordinates:-methodUsed="series" and largeNearCoordinates:-compressedDimension=2 and largeNearCoordinates:-convergenceTest="doubled_degree" and largeNearCoordinates:-tailBound=-1 and largeNearCoordinates:-doubledDegreeDifference>=0 and largeNearCoordinates:-errorEstimate<=1.1e-14 and largeNearCoordinates:-roundingError<=1.1e-14)):
largeNearClosedForm := LauricellaFD(2/3,[largeB,-largeB],2/3,[1/2,1/2+1/largeB],'digits'=15,'returnDiagnostics'=true):
CheckClose("log-stabilized c equals a cancellation",largeNearClosedForm:-value,evalf[30](exp(-2)),1.e-14):
CheckTrue("large c equals a dispatch",evalb(largeNearClosedForm:-methodUsed="closed_form" and largeNearClosedForm:-compressedDimension=2)):
largeNearEuler := LauricellaFD(1/3,[largeB,-largeB],7/6,[1/2,1/2+1/largeB],'digits'=15,'method'="euler",'returnDiagnostics'=true):
CheckClose("log-stabilized Euler cancellation",largeNearEuler:-value,largeNearReference,1.e-14):
largeNearEulerReversed := LauricellaFD(1/3,[-largeB,largeB],7/6,[1/2+1/largeB,1/2],'digits'=15,'method'="euler",'returnDiagnostics'=true):
CheckClose("log-stabilized Euler order invariance",largeNearEulerReversed:-value,largeNearReference,1.e-14):

eulerFallback := LauricellaFD(1.e-20,[100,-100],1.25,[.7,.699],'digits'=8,'frobeniusOrder'=24,'returnDiagnostics'=true):
CheckTrue("ill-conditioned Euler is avoided",evalb(eulerFallback:-methodUsed<>"euler" and (type(eulerFallback:-value,numeric) or type(eulerFallback:-value,complex(numeric))))):

falseConvergenceRejected := false:
try LauricellaFD(1.e-20,[1],-100.5,[.9],'digits'=12,'method'="series",'maximumDegree'=40): catch: falseConvergenceRejected := true: end try:
CheckTrue("absolute majorant rejects a cancelling prefix",falseConvergenceRejected):

oversizedSeriesRejected := false:
try LauricellaFD(1/3,[1/4],7/6,[99/100],'digits'=100,'method'="series",'maximumDegree'=30000): catch: oversizedSeriesRejected := true: end try:
CheckTrue("specialized operation gate rejects forced oversized series",oversizedSeriesRejected):
oversizedAuto := LauricellaFD(1/3,[1/4],7/6,[1/2],'digits'=10,'maximumDegree'=10000,'returnDiagnostics'=true):
CheckClose("huge-cap automatic admission",oversizedAuto:-value,evalf[25](hypergeom([1/3,1/4],[7/6],1/2)),1.e-9):
CheckTrue("huge-cap automatic predicted series",evalb(oversizedAuto:-methodUsed="series" and oversizedAuto:-degree<10000)):

upperCut := LauricellaFD(1/3,[1/4],7/6,[2],'digits'=8,'waypoints'=[[1+I/2]],'frobeniusOrder'=28,'returnDiagnostics'=true):
lowerCut := LauricellaFD(1/3,[1/4],7/6,[2],'digits'=8,'waypoints'=[[1-I/2]],'frobeniusOrder'=28,'returnDiagnostics'=true):
cutReference := evalf[30](1.0986624951132961991043487149468682260037065149063+.23747202829706179971998072222990036888429981175368*I):
CheckClose("upper cut continuation",upperCut:-value,cutReference,1.e-8):
CheckClose("lower cut continuation",lowerCut:-value,conjugate(cutReference),1.e-8):
CheckTrue("waypoints force Pfaffian",evalb(upperCut:-methodUsed="pfaffian" and lowerCut:-methodUsed="pfaffian")):

waypointSeriesRejected := false:
try LauricellaFD(1/3,[1/4],7/6,[2],'digits'=8,'method'="series",'waypoints'=[[1+I/2]]): catch: waypointSeriesRejected := true: end try:
CheckTrue("principal series rejects waypoints",waypointSeriesRejected):

if failures = 0 then printf("All Lauricella FD tests passed.\n"): else printf("%d Lauricella FD test(s) failed.\n",failures): error "%1 Lauricella FD test(s) failed",failures: end if:
quit:
