restart:
read "../HyperPrecision.mpl":
with(HyperPrecision):

failures := 0:

CheckTrue := proc(label::string,condition)
    global failures;
    if condition then printf("PASS %s\n",label); else failures:=failures+1; printf("FAIL %s\n",label); end if;
end proc:

CheckRelative := proc(label::string,actual,expectedValue,tolerance)
    global failures;
    local difference,scale;
    scale:=max(abs(expectedValue),1); difference:=evalf(abs(actual-expectedValue)/scale);
    if difference<=tolerance then printf("PASS %s: relative error=%a\n",label,difference); else failures:=failures+1; printf("FAIL %s: relative error=%a\n",label,difference); end if;
end proc:

CheckCoverage := proc(label::string,report,oracle,digits::posint)
    global failures;
    local difference,allowance;
    difference := evalf(abs(report:-value-oracle));
    allowance := max(report:-errorEstimate,
        evalf(10^(1-digits)*max(abs(report:-value),1)));
    if difference<=allowance then
        printf("PASS %s: error=%a allowance=%a\n",label,difference,allowance);
    else
        failures:=failures+1;
        printf("FAIL %s: error=%a allowance=%a\n",label,difference,allowance);
    end if;
end proc:

ExpectError := proc(label::string,callback::procedure,pattern::string)
    global failures;
    local messageText;
    try callback(); failures:=failures+1; printf("FAIL %s: no error was raised\n",label); catch: messageText:=convert(lastexception[2],string); if StringTools:-Search(pattern,messageText)>0 then printf("PASS %s: %s\n",label,messageText); else failures:=failures+1; printf("FAIL %s: unexpected error: %s\n",label,messageText); end if; end try;
end proc:

# Native pFq is selected only for an ordinary nonterminating principal germ.
for requestedDigits in [15,50,100] do
    pfqReport := HypergeometricPFQ([1/7,2/7,3/7],[5/6,7/8],9/20,'digits'=requestedDigits,'returnDiagnostics'=true):
    pfqReference := evalf[requestedDigits+30](hypergeom([1/7,2/7,3/7],[5/6,7/8],9/20)):
    CheckRelative(cat("native pFq value ",requestedDigits),pfqReport:-value,pfqReference,10^(-requestedDigits+2)):
    CheckTrue(cat("native pFq diagnostics ",requestedDigits),evalb(pfqReport:-methodUsed="native" and pfqReport:-errorStatus="heuristic" and pfqReport:-workingDigits>=requestedDigits+8 and pfqReport:-branchProvenance="principal_origin_germ" and pfqReport:-compressedDimension=1)):
end do:

# The exact exp identity is independent of Maple's hypergeom implementation.
zeroReport := HypergeometricPFQ([],[],-1000,'digits'=80,'returnDerivatives'=true):
zeroReference := evalf[110](exp(-1000)):
CheckTrue("0F0 exp(-1000)",evalb(abs(zeroReport[1]/zeroReference-1)<1.e-78)):
CheckTrue("0F0 derivative",evalb(abs(zeroReport[2]/zeroReference-1)<1.e-78)):

# The degree cap rejects a boundary series before a recurrence array is built.
gateStart := time[real]():
ExpectError("pFq estimated-degree pre-gate",proc() Hypergeometric2F1(1/3,2/5,7/6,19/20,'digits'=50,'method'="series",'maximumDegree'=260) end proc,"below the estimated pFq tail degree"):
CheckTrue("pFq pre-gate latency",evalb(time[real]()-gateStart<1)):

# Maple's Appell kernels are checked against the independent convolution/FD
# implementations at all production precision levels.
for requestedDigits in [15,50,100] do
    f1Native := AppellF1(1/4,1/3,1/5,7/6,1/20,1/30,'digits'=requestedDigits,'returnDiagnostics'=true):
    f1Series := AppellF1(1/4,1/3,1/5,7/6,1/20,1/30,'digits'=requestedDigits+8,'method'="series"):
    f2Native := AppellF2(1/4,1/3,1/5,7/6,8/7,1/20,1/30,'digits'=requestedDigits,'returnDiagnostics'=true):
    f2Series := AppellF2(1/4,1/3,1/5,7/6,8/7,1/20,1/30,'digits'=requestedDigits+8,'method'="series"):
    f3Native := AppellF3(1/4,1/3,1/5,2/7,7/6,1/20,1/30,'digits'=requestedDigits,'returnDiagnostics'=true):
    f3Series := AppellF3(1/4,1/3,1/5,2/7,7/6,1/20,1/30,'digits'=requestedDigits+8,'method'="series"):
    f4Native := AppellF4(1/4,1/3,7/6,8/7,1/100,1/120,'digits'=requestedDigits,'returnDiagnostics'=true):
    f4Series := AppellF4(1/4,1/3,7/6,8/7,1/100,1/120,'digits'=requestedDigits+8,'method'="series"):
    for comparison in [["F1",f1Native,f1Series],["F2",f2Native,f2Series],["F3",f3Native,f3Series],["F4",f4Native,f4Series]] do
        CheckRelative(cat("native Appell ",comparison[1]," ",requestedDigits),comparison[2]:-value,comparison[3],10^(-requestedDigits+2)):
        CheckTrue(cat("native Appell diagnostics ",comparison[1]," ",requestedDigits),evalb(comparison[2]:-methodUsed="native" and comparison[2]:-errorStatus="heuristic" and comparison[2]:-branchProvenance="principal_origin_germ" and comparison[2]:-compressedDimension=2)):
    end do:
end do:

# This boundary golden was cross-checked against the unrelated generic
# Pfaffian evaluator at 20 digits during the production audit.
f2BoundaryGolden := 1.079010979641577067020315105109892148909503913518284738773546901925953243993763105951226940082286296:
for requestedDigits in [15,50,100] do
    f2Boundary := AppellF2(1/4,1/3,1/5,7/6,8/7,1/2,9/20,'digits'=requestedDigits,'maximumDegree'=260,'returnDiagnostics'=true):
    CheckRelative(cat("Appell F2 q095 golden ",requestedDigits),f2Boundary:-value,f2BoundaryGolden,10^(-requestedDigits+2)):
    CheckTrue(cat("Appell F2 q095 native route ",requestedDigits),evalb(f2Boundary:-methodUsed="native")):
end do:

# Scalar diagnostics and derivative workloads are independent.  Every first
# derivative is checked through a contiguous identity, or through a guarded
# central difference for a Horn family whose shifts are not exposed publicly.
for requestedDigits in [15,50,100] do
    Digits := 2*requestedDigits+50:
    oracleDigits := requestedDigits+24:
    derivativeTolerance := 10^(-requestedDigits+3):

    pfqScalarReport := HypergeometricPFQ([1/7,2/7,3/7],[5/6,7/8],9/20,'digits'=requestedDigits,'returnDiagnostics'=true):
    pfqDerivativeReport := HypergeometricPFQ([1/7,2/7,3/7],[5/6,7/8],9/20,'digits'=requestedDigits,'returnDiagnostics'=true,'returnDerivatives'=true):
    pfqValueOracle := HypergeometricPFQ([1/7,2/7,3/7],[5/6,7/8],9/20,'digits'=oracleDigits,'method'="series",'maximumDegree'=1200):
    pfqDerivativeOracle := (1/7*2/7*3/7)/(5/6*7/8)*HypergeometricPFQ([8/7,9/7,10/7],[11/6,15/8],9/20,'digits'=oracleDigits,'method'="series",'maximumDegree'=1200):
    CheckTrue(cat("pFq scalar/derivative workload split ",requestedDigits),evalb(nops(pfqScalarReport:-derivatives)=0 and not pfqScalarReport:-derivativeWorkload and nops(pfqDerivativeReport:-derivatives)=1 and pfqDerivativeReport:-derivativeWorkload)):
    CheckRelative(cat("pFq guarded derivative ",requestedDigits),pfqDerivativeReport:-derivatives[1],pfqDerivativeOracle,derivativeTolerance):
    CheckCoverage(cat("pFq value error coverage ",requestedDigits),pfqDerivativeReport,pfqValueOracle,requestedDigits):
    CheckTrue(cat("pFq path metadata ",requestedDigits),evalb(not pfqDerivativeReport:-pathDependent and pfqDerivativeReport:-branchProvenance="principal_origin_germ")):

    f1DerivativeReport := AppellF1(1/4,1/3,1/5,7/6,1/20,1/30,'digits'=requestedDigits,'returnDiagnostics'=true,'returnDerivatives'=true):
    f1DxOracle := (1/4*1/3)/(7/6)*AppellF1(5/4,4/3,1/5,13/6,1/20,1/30,'digits'=oracleDigits,'method'="series"):
    f1DyOracle := (1/4*1/5)/(7/6)*AppellF1(5/4,1/3,6/5,13/6,1/20,1/30,'digits'=oracleDigits,'method'="series"):
    f2DerivativeReport := AppellF2(1/4,1/3,1/5,7/6,8/7,1/20,1/30,'digits'=requestedDigits,'returnDiagnostics'=true,'returnDerivatives'=true):
    f2DxOracle := (1/4*1/3)/(7/6)*AppellF2(5/4,4/3,1/5,13/6,8/7,1/20,1/30,'digits'=oracleDigits,'method'="series"):
    f2DyOracle := (1/4*1/5)/(8/7)*AppellF2(5/4,1/3,6/5,7/6,15/7,1/20,1/30,'digits'=oracleDigits,'method'="series"):
    f3DerivativeReport := AppellF3(1/4,1/3,1/5,2/7,7/6,1/20,1/30,'digits'=requestedDigits,'returnDiagnostics'=true,'returnDerivatives'=true):
    f3DxOracle := (1/4*1/5)/(7/6)*AppellF3(5/4,1/3,6/5,2/7,13/6,1/20,1/30,'digits'=oracleDigits,'method'="series"):
    f3DyOracle := (1/3*2/7)/(7/6)*AppellF3(1/4,4/3,1/5,9/7,13/6,1/20,1/30,'digits'=oracleDigits,'method'="series"):
    f4DerivativeReport := AppellF4(1/4,1/3,7/6,8/7,1/100,1/120,'digits'=requestedDigits,'returnDiagnostics'=true,'returnDerivatives'=true):
    f4DxOracle := (1/4*1/3)/(7/6)*AppellF4(5/4,4/3,13/6,8/7,1/100,1/120,'digits'=oracleDigits,'method'="series"):
    f4DyOracle := (1/4*1/3)/(8/7)*AppellF4(5/4,4/3,7/6,15/7,1/100,1/120,'digits'=oracleDigits,'method'="series"):
    for derivativeComparison in [["F1",f1DerivativeReport,f1DxOracle,f1DyOracle],["F2",f2DerivativeReport,f2DxOracle,f2DyOracle],["F3",f3DerivativeReport,f3DxOracle,f3DyOracle],["F4",f4DerivativeReport,f4DxOracle,f4DyOracle]] do
        CheckRelative(cat("Appell ",derivativeComparison[1]," guarded derivative x ",requestedDigits),derivativeComparison[2]:-derivatives[1],derivativeComparison[3],derivativeTolerance):
        CheckRelative(cat("Appell ",derivativeComparison[1]," guarded derivative y ",requestedDigits),derivativeComparison[2]:-derivatives[2],derivativeComparison[4],derivativeTolerance):
        CheckTrue(cat("Appell ",derivativeComparison[1]," derivative metadata ",requestedDigits),evalb(nops(derivativeComparison[2]:-derivatives)=2 and derivativeComparison[2]:-derivativeWorkload and not derivativeComparison[2]:-pathDependent and derivativeComparison[2]:-branchProvenance="principal_origin_germ")):
    end do:

    hornDerivativeReport := HornH3(2/7,3/8,5/9,1/50,3/200,'digits'=requestedDigits,'maximumDegree'=600,'returnDiagnostics'=true,'returnDerivatives'=true):
    hornStep := 1/10^(requestedDigits+8):
    hornOracleDigits := 2*requestedDigits+35:
    hornDxOracle := (HornH3(2/7,3/8,5/9,1/50+hornStep,3/200,'digits'=hornOracleDigits,'method'="series",'maximumDegree'=600)-HornH3(2/7,3/8,5/9,1/50-hornStep,3/200,'digits'=hornOracleDigits,'method'="series",'maximumDegree'=600))/(2*hornStep):
    hornDyOracle := (HornH3(2/7,3/8,5/9,1/50,3/200+hornStep,'digits'=hornOracleDigits,'method'="series",'maximumDegree'=600)-HornH3(2/7,3/8,5/9,1/50,3/200-hornStep,'digits'=hornOracleDigits,'method'="series",'maximumDegree'=600))/(2*hornStep):
    CheckRelative(cat("Horn H3 guarded derivative x ",requestedDigits),hornDerivativeReport:-derivatives[1],hornDxOracle,derivativeTolerance):
    CheckRelative(cat("Horn H3 guarded derivative y ",requestedDigits),hornDerivativeReport:-derivatives[2],hornDyOracle,derivativeTolerance):
    CheckTrue(cat("Horn H3 derivative metadata ",requestedDigits),evalb(nops(hornDerivativeReport:-derivatives)=2 and hornDerivativeReport:-derivativeWorkload and not hornDerivativeReport:-pathDependent and hornDerivativeReport:-branchProvenance<>"unspecified")):

    fdOraclePoint := [1/2,1/3,1/4,1/5,1/6,1/7,1/8]:
    fdDerivativeReport := LauricellaFD(1/4,[1/4$7],1,fdOraclePoint,'digits'=requestedDigits,'maximumDegree'=1200,'returnDiagnostics'=true,'returnDerivatives'=true):
    fdValueOracle := LauricellaFD(1/4,[1/4$7],1,fdOraclePoint,'digits'=oracleDigits,'method'="series",'maximumDegree'=1200):
    CheckCoverage(cat("FD7 value error coverage ",requestedDigits),fdDerivativeReport,fdValueOracle,requestedDigits):
    for derivativeIndex to 7 do
        fdShiftedB := subsop(derivativeIndex=5/4,[1/4$7]):
        fdDerivativeOracle := 1/16*LauricellaFD(5/4,fdShiftedB,2,fdOraclePoint,'digits'=oracleDigits,'method'="series",'maximumDegree'=1200):
        CheckRelative(cat("FD7 guarded derivative ",derivativeIndex," ",requestedDigits),fdDerivativeReport:-derivatives[derivativeIndex],fdDerivativeOracle,derivativeTolerance):
    end do:
    CheckTrue(cat("FD7 derivative metadata ",requestedDigits),evalb(nops(fdDerivativeReport:-derivatives)=7 and fdDerivativeReport:-derivativeWorkload and not fdDerivativeReport:-pathDependent and fdDerivativeReport:-branchProvenance="principal_origin_germ" and fdDerivativeReport:-resourceStatus="ok")):
end do:
Digits := 10:

nearPoleF2 := AppellF2(1/4,1/3,1/5,-2+I/10^40,8/7,1/100,1/120,'digits'=18,'maximumDegree'=120,'returnDiagnostics'=true):
nearPoleF2Series := AppellF2(1/4,1/3,1/5,-2+I/10^40,8/7,1/100,1/120,'digits'=22,'maximumDegree'=120,'method'="series"):
CheckRelative("near-pole Appell bypasses native",nearPoleF2:-value,nearPoleF2Series,1.e-16):
CheckTrue("near-pole Appell convolution route",evalb(nearPoleF2:-methodUsed="convolution" and nearPoleF2:-workingDigits>=58)):

# FD uses series in the deep interior and Euler near the boundary.  Forced
# boundary series fails at its public degree cap before allocating arrays.
fdInterior := LauricellaFD(1/4,[1/4$7],1,[1/2,1/3,1/4,1/5,1/6,1/7,1/8],'digits'=50,'maximumDegree'=800,'returnDiagnostics'=true):
CheckTrue("FD7 interior series route",evalb(fdInterior:-methodUsed="series" and fdInterior:-errorStatus="bounded")):
fdBoundary := LauricellaFD(1/4,[1/4$7],1,[19/20,9/10,4/5,7/10,3/5,1/2,2/5],'digits'=15,'maximumDegree'=260,'returnDiagnostics'=true):
CheckTrue("FD7 q095 Euler route",evalb(fdBoundary:-methodUsed="euler" and fdBoundary:-errorStatus="unknown" and fdBoundary:-estimatedDegree>260)):
for fdBoundaryCase in [[15,1600],[50,3400],[100,6000]] do
    fdBoundaryDerivatives := LauricellaFD(1/4,[1/4$7],1,[19/20,9/10,4/5,7/10,3/5,1/2,2/5],'digits'=fdBoundaryCase[1],'maximumDegree'=fdBoundaryCase[2],'returnDiagnostics'=true,'returnDerivatives'=true):
    CheckTrue(cat("FD7 q095 derivative series route ",fdBoundaryCase[1]),evalb(fdBoundaryDerivatives:-methodUsed="series" and fdBoundaryDerivatives:-derivativeWorkload and nops(fdBoundaryDerivatives:-derivatives)=7 and fdBoundaryDerivatives:-errorStatus="bounded" and fdBoundaryDerivatives:-degree<=fdBoundaryDerivatives:-estimatedDegree and fdBoundaryDerivatives:-branchProvenance="principal_origin_germ")):
end do:
fdBoundaryCapLow := LauricellaFD(1/4,[1/4$7],1,[19/20,9/10,4/5,7/10,3/5,1/2,2/5],'digits'=15,'maximumDegree'=900,'returnDiagnostics'=true,'returnDerivatives'=true):
for fdBoundaryCap in [1224,1225,1000000] do
    fdBoundaryCapAuto := LauricellaFD(1/4,[1/4$7],1,[19/20,9/10,4/5,7/10,3/5,1/2,2/5],'digits'=15,'maximumDegree'=fdBoundaryCap,'returnDiagnostics'=true,'returnDerivatives'=true):
    fdBoundaryCapForced := LauricellaFD(1/4,[1/4$7],1,[19/20,9/10,4/5,7/10,3/5,1/2,2/5],'digits'=15,'method'="series",'maximumDegree'=fdBoundaryCap,'returnDiagnostics'=true,'returnDerivatives'=true):
    CheckTrue(cat("FD7 q095 cap route/provenance ",fdBoundaryCap),evalb(fdBoundaryCapAuto:-methodUsed="series" and fdBoundaryCapForced:-methodUsed="series" and fdBoundaryCapAuto:-degree=fdBoundaryCapForced:-degree and fdBoundaryCapAuto:-degree<fdBoundaryCap and fdBoundaryCapAuto:-errorStatus=fdBoundaryCapForced:-errorStatus and fdBoundaryCapAuto:-errorEstimate=fdBoundaryCapForced:-errorEstimate and fdBoundaryCapAuto:-branchProvenance=fdBoundaryCapForced:-branchProvenance)):
    CheckRelative(cat("FD7 q095 cap value ",fdBoundaryCap),fdBoundaryCapAuto:-value,fdBoundaryCapForced:-value,1.e-12):
    for derivativeIndex to 7 do CheckRelative(cat("FD7 q095 cap derivative ",fdBoundaryCap,"/",derivativeIndex),fdBoundaryCapAuto:-derivatives[derivativeIndex],fdBoundaryCapForced:-derivatives[derivativeIndex],1.e-12): end do:
end do:
CheckTrue("FD7 q095 insufficient cap bypasses series",evalb(fdBoundaryCapLow:-methodUsed="euler")):
gateStart := time[real]():
ExpectError("FD estimated-degree pre-gate",proc() LauricellaFD(1/4,[1/4$7],1,[19/20,9/10,4/5,7/10,3/5,1/2,2/5],'digits'=15,'method'="series",'maximumDegree'=260) end proc,"below the estimated Lauricella FD tail degree"):
ExpectError("FD derivative insufficient-cap pre-gate",proc() LauricellaFD(1/4,[1/4$7],1,[19/20,9/10,4/5,7/10,3/5,1/2,2/5],'digits'=15,'method'="series",'maximumDegree'=900,'returnDerivatives'=true) end proc,"below the estimated Lauricella FD tail degree"):
ExpectError("FD predicted-work hard resource gate",proc() LauricellaFD(1/4,[1/4],1,[99/100],'digits'=100,'method'="series",'maximumDegree'=30000,'returnDerivatives'=true) end proc,"hard operation limit"):
CheckTrue("FD pre-gate latency",evalb(time[real]()-gateStart<1)):

# Exact finite support and delayed poles remain on their checked recurrences.
terminatingReport := Hypergeometric2F1(-300,1,2,2,'digits'=40,'maximumDegree'=300,'returnDiagnostics'=true):
CheckTrue("terminating pFq midpoint is a posteriori",evalb(terminatingReport:-methodUsed="series" and terminatingReport:-errorStatus="a_posteriori" and terminatingReport:-degree=300)):
fdCancellationReport := LauricellaFD(1/4,[1/3,1/5],1/4,[1/5,1/7],'digits'=30,'returnDiagnostics'=true):
CheckTrue("FD exact-cancellation midpoint is heuristic",evalb(fdCancellationReport:-certificate="exact_cancellation" and fdCancellationReport:-errorStatus="heuristic")):
delayedPole := Hypergeometric2F1(1/3,2/5,-100+I/10^100,1/100,'digits'=18,'maximumDegree'=260,'returnDiagnostics'=true):
CheckTrue("delayed pole remains on series",evalb(delayedPole:-methodUsed="series" and delayedPole:-degree>100)):

# Horn routing includes the output workload: derivative grids and scalar grids
# have different measured crossover points.
g1At15 := HornG1(2/7,3/8,5/9,1/50,3/200,'digits'=15,'returnDiagnostics'=true):
g1At50 := HornG1(2/7,3/8,5/9,1/50,3/200,'digits'=50,'returnDiagnostics'=true):
g1At100 := HornG1(2/7,3/8,5/9,1/50,3/200,'digits'=100,'returnDiagnostics'=true):
g2At100 := HornG2(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=100,'returnDiagnostics'=true):
g1DerivativeAt50 := HornG1(2/7,3/8,5/9,1/50,3/200,'digits'=50,'returnDiagnostics'=true,'returnDerivatives'=true):
g2DerivativeAt80 := HornG2(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=80,'returnDiagnostics'=true,'returnDerivatives'=true):
g2DerivativeAt90 := HornG2(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=90,'returnDiagnostics'=true,'returnDerivatives'=true):
g2DerivativeAt95 := HornG2(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=95,'returnDiagnostics'=true,'returnDerivatives'=true):
g2DerivativeAt100 := HornG2(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=100,'returnDiagnostics'=true,'returnDerivatives'=true):
g2DerivativeSeriesAt100 := HornG2(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=100,'method'="series",'returnDiagnostics'=true,'returnDerivatives'=true):
g2DerivativeGenericAt100 := HornG2(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=100,'method'="generic",'returnDiagnostics'=true,'returnDerivatives'=true):
g2DerivativeAt120 := HornG2(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=120,'returnDiagnostics'=true,'returnDerivatives'=true):
h7ScalarAt50 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=50,'returnDiagnostics'=true):
h7ScalarAt69 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=69,'returnDiagnostics'=true):
h7SeriesAt69 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=69,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true):
h7ScalarAt70 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=70,'returnDiagnostics'=true):
h7GenericAt70 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=70,'method'="generic",'maximumDegree'=260,'returnDiagnostics'=true):
h7ScalarAt75 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=75,'returnDiagnostics'=true):
h7GenericAt75 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=75,'method'="generic",'maximumDegree'=260,'returnDiagnostics'=true):
h7ScalarAt80 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=80,'returnDiagnostics'=true):
h7GenericAt80 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=80,'method'="generic",'maximumDegree'=260,'returnDiagnostics'=true):
h7SeriesAt80 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=80,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true):
h7ScalarAt85 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=85,'returnDiagnostics'=true):
h7GenericAt85 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=85,'method'="generic",'maximumDegree'=260,'returnDiagnostics'=true):
h7ScalarAt90 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=90,'returnDiagnostics'=true):
h7GenericAt90 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=90,'method'="generic",'maximumDegree'=260,'returnDiagnostics'=true):
h7ScalarAt100 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=100,'returnDiagnostics'=true):
h7SeriesAt100 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=100,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true):
h7DerivativeAt100 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=100,'returnDiagnostics'=true,'returnDerivatives'=true):
h7ScalarAt120 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=120,'returnDiagnostics'=true):
h7SeriesAt120 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=120,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true):
h7DerivativeAt80 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=80,'returnDiagnostics'=true,'returnDerivatives'=true):
h7DerivativeGenericAt80 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=80,'method'="generic",'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=true):
h7DerivativeAt120 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=120,'returnDiagnostics'=true,'returnDerivatives'=true):
h7DerivativeGenericAt120 := HornH7(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=120,'method'="generic",'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=true):
CheckTrue("Horn G1 15-digit generic route",evalb(g1At15:-methodUsed="pfaffian")):
CheckTrue("Horn G1 50-digit scalar neighbor route",evalb(g1At50:-methodUsed="neighbor_series")):
CheckTrue("Horn G1 100-digit neighbor route",evalb(g1At100:-methodUsed="neighbor_series")):
CheckTrue("Horn G2 100-digit scalar neighbor route",evalb(g2At100:-methodUsed="neighbor_series")):
CheckTrue("diagnostics-only Horn calls remain scalar",evalb(nops(g1At50:-derivatives)=0 and nops(g2At100:-derivatives)=0 and not g1At50:-derivativeWorkload and not g2At100:-derivativeWorkload)):
CheckTrue("Horn derivative workload retains generic routes",evalb(g1DerivativeAt50:-methodUsed="pfaffian" and g2DerivativeAt80:-methodUsed="pfaffian" and g2DerivativeAt90:-methodUsed="pfaffian" and g2DerivativeAt95:-methodUsed="pfaffian" and nops(g1DerivativeAt50:-derivatives)=2 and nops(g2DerivativeAt95:-derivatives)=2 and g1DerivativeAt50:-derivativeWorkload and g2DerivativeAt95:-derivativeWorkload)):
CheckTrue("Horn G2 derivative crossover hysteresis",evalb(g2DerivativeAt80:-methodUsed="pfaffian" and g2DerivativeAt90:-methodUsed="pfaffian" and g2DerivativeAt95:-methodUsed="pfaffian" and g2DerivativeAt100:-methodUsed="neighbor_series" and g2DerivativeAt120:-methodUsed="neighbor_series" and g2DerivativeAt100:-degree=g2DerivativeSeriesAt100:-degree and g2DerivativeAt100:-errorStatus=g2DerivativeSeriesAt100:-errorStatus and g2DerivativeAt100:-errorEstimate=g2DerivativeSeriesAt100:-errorEstimate and g2DerivativeAt100:-branchProvenance="principal_origin_germ" and g2DerivativeSeriesAt100:-branchProvenance="principal_origin_germ" and g2DerivativeGenericAt100:-branchProvenance="principal_canonical_transport")):
CheckRelative("Horn G2 crossover value against series",g2DerivativeAt100:-value,g2DerivativeSeriesAt100:-value,1.e-97):
CheckRelative("Horn G2 crossover value against generic",g2DerivativeAt100:-value,g2DerivativeGenericAt100:-value,1.e-97):
for derivativeIndex to 2 do
    CheckRelative(cat("Horn G2 crossover derivative ",derivativeIndex," against series"),g2DerivativeAt100:-derivatives[derivativeIndex],g2DerivativeSeriesAt100:-derivatives[derivativeIndex],1.e-97):
    CheckRelative(cat("Horn G2 crossover derivative ",derivativeIndex," against generic"),g2DerivativeAt100:-derivatives[derivativeIndex],g2DerivativeGenericAt100:-derivatives[derivativeIndex],1.e-97):
end do:
CheckTrue("Horn H7 scalar crossover routes",evalb(h7ScalarAt50:-methodUsed="neighbor_series" and h7ScalarAt69:-methodUsed="neighbor_series" and h7ScalarAt70:-methodUsed="pfaffian" and h7ScalarAt75:-methodUsed="pfaffian" and h7ScalarAt80:-methodUsed="pfaffian" and h7ScalarAt85:-methodUsed="pfaffian" and h7ScalarAt90:-methodUsed="pfaffian" and h7ScalarAt100:-methodUsed="neighbor_series" and h7ScalarAt120:-methodUsed="neighbor_series")):
CheckTrue("Horn H7 derivative routes remain independent",evalb(h7DerivativeAt80:-methodUsed="pfaffian" and h7DerivativeAt100:-methodUsed="pfaffian" and h7DerivativeAt120:-methodUsed="pfaffian" and h7DerivativeAt80:-derivativeWorkload and h7DerivativeAt100:-derivativeWorkload and h7DerivativeAt120:-derivativeWorkload)):
for h7CrossoverIndex to 5 do
    h7CrossoverDigits := [70,75,80,85,90][h7CrossoverIndex]:
    h7CrossoverAuto := [h7ScalarAt70,h7ScalarAt75,h7ScalarAt80,h7ScalarAt85,h7ScalarAt90][h7CrossoverIndex]:
    h7CrossoverGeneric := [h7GenericAt70,h7GenericAt75,h7GenericAt80,h7GenericAt85,h7GenericAt90][h7CrossoverIndex]:
    CheckRelative(cat("Horn H7 generic safety-band value at ",h7CrossoverDigits," digits"),h7CrossoverAuto:-value,h7CrossoverGeneric:-value,10^(-h7CrossoverDigits+3)):
    CheckTrue(cat("Horn H7 generic safety-band diagnostics at ",h7CrossoverDigits," digits"),evalb(h7CrossoverAuto:-errorStatus="unknown" and h7CrossoverAuto:-errorEstimate=infinity and not h7CrossoverAuto:-pathDependent and h7CrossoverAuto:-branchProvenance="principal_canonical_transport" and h7CrossoverAuto:-errorStatus=h7CrossoverGeneric:-errorStatus and h7CrossoverAuto:-errorEstimate=h7CrossoverGeneric:-errorEstimate and h7CrossoverAuto:-branchProvenance=h7CrossoverGeneric:-branchProvenance)):
end do:
CheckRelative("Horn H7 69-digit lower-boundary value",h7ScalarAt69:-value,h7SeriesAt69:-value,1.e-66):
CheckTrue("Horn H7 69-digit lower-boundary diagnostics",evalb(h7ScalarAt69:-degree=h7SeriesAt69:-degree and h7ScalarAt69:-errorStatus=h7SeriesAt69:-errorStatus and h7ScalarAt69:-errorEstimate=h7SeriesAt69:-errorEstimate and not h7ScalarAt69:-pathDependent and h7ScalarAt69:-branchProvenance="principal_origin_germ")):
CheckRelative("Horn H7 safety-band value against the neighbor grid",h7ScalarAt80:-value,h7SeriesAt80:-value,1.e-77):
CheckRelative("Horn H7 scalar crossover forced-series value",h7ScalarAt100:-value,h7SeriesAt100:-value,1.e-97):
CheckTrue("Horn H7 scalar crossover provenance and error",evalb(h7ScalarAt100:-degree=h7SeriesAt100:-degree and h7ScalarAt100:-errorStatus=h7SeriesAt100:-errorStatus and h7ScalarAt100:-errorEstimate=h7SeriesAt100:-errorEstimate and h7ScalarAt100:-branchProvenance="principal_origin_germ" and h7SeriesAt100:-branchProvenance="principal_origin_germ")):
CheckRelative("Horn H7 120-digit upper-boundary value",h7ScalarAt120:-value,h7SeriesAt120:-value,1.e-117):
CheckTrue("Horn H7 120-digit upper-boundary diagnostics",evalb(h7ScalarAt120:-degree=h7SeriesAt120:-degree and h7ScalarAt120:-errorStatus=h7SeriesAt120:-errorStatus and h7ScalarAt120:-errorEstimate=h7SeriesAt120:-errorEstimate and not h7ScalarAt120:-pathDependent and h7ScalarAt120:-branchProvenance="principal_origin_germ")):
for derivativeIndex to 2 do
    CheckRelative(cat("Horn H7 80-digit derivative ",derivativeIndex),h7DerivativeAt80:-derivatives[derivativeIndex],h7DerivativeGenericAt80:-derivatives[derivativeIndex],1.e-77):
    CheckRelative(cat("Horn H7 120-digit derivative ",derivativeIndex),h7DerivativeAt120:-derivatives[derivativeIndex],h7DerivativeGenericAt120:-derivatives[derivativeIndex],1.e-117):
end do:
CheckTrue("Horn H7 derivative diagnostics remain generic",evalb(h7DerivativeAt80:-errorStatus="unknown" and h7DerivativeAt120:-errorStatus="unknown" and h7DerivativeAt80:-errorEstimate=infinity and h7DerivativeAt120:-errorEstimate=infinity and not h7DerivativeAt80:-pathDependent and not h7DerivativeAt120:-pathDependent and h7DerivativeAt80:-branchProvenance="principal_canonical_transport" and h7DerivativeAt120:-branchProvenance="principal_canonical_transport")):
CheckTrue("generic step provenance is reported",evalb(g1DerivativeAt50:-genericStepCount>=0 and g2DerivativeAt95:-genericStepCount>=0 and g1DerivativeAt50:-genericProvenance<>"not_applicable" and g2DerivativeAt95:-genericProvenance<>"not_applicable")):

# The estimated H4 shell at 100 digits is insufficient for the checked
# comparison.  Automatic dispatch must use the same degree-260 retry as a
# forced series call instead of paying for a failed grid and then rebuilding
# the function as a generic Pfaffian system.
h4Series100 := HornH4(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=100,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=true):
h4Generic100 := HornH4(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=100,'method'="generic",'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=true):
h4Auto100 := HornH4(2/7,3/8,5/9,7/10,1/50,3/200,'digits'=100,'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=true):
CheckRelative("Horn H4 retry value against series",h4Auto100:-value,h4Series100:-value,1.e-97):
CheckRelative("Horn H4 retry value against generic",h4Auto100:-value,h4Generic100:-value,1.e-97):
for derivativeIndex to 2 do
    CheckRelative(cat("Horn H4 retry derivative ",derivativeIndex," against series"),h4Auto100:-derivatives[derivativeIndex],h4Series100:-derivatives[derivativeIndex],1.e-97):
    CheckRelative(cat("Horn H4 retry derivative ",derivativeIndex," against generic"),h4Auto100:-derivatives[derivativeIndex],h4Generic100:-derivatives[derivativeIndex],1.e-97):
end do:
CheckTrue("Horn H4 automatic bounded retry",evalb(h4Auto100:-methodUsed="neighbor_series" and h4Auto100:-degree=260 and h4Series100:-degree=260 and h4Auto100:-errorStatus=h4Series100:-errorStatus and h4Auto100:-errorEstimate=h4Series100:-errorEstimate)):
CheckTrue("Horn H4 principal path metadata",evalb(not h4Auto100:-pathDependent and not h4Series100:-pathDependent and not h4Generic100:-pathDependent and h4Auto100:-branchProvenance="principal_origin_germ" and h4Series100:-branchProvenance="principal_origin_germ" and h4Generic100:-branchProvenance="principal_canonical_transport")):

# A native representation cannot replace a path-dependent request.
ExpectError("native Appell rejects explicit path",proc() AppellF2(1/4,1/3,1/5,7/6,8/7,1/20,1/30,'digits'=20,'method'="native",'waypoints'=[[1/100,1/100]]) end proc,"cannot honour an explicit"):

if failures=0 then printf("All production dispatch tests passed.\n"): else printf("%d production dispatch test(s) failed.\n",failures): error "%1 production dispatch test(s) failed",failures: end if:
quit:
