restart:
read "../HyperPrecision.mpl":
with(HyperPrecision):
Digits := 50:

failures := 0:

CheckClose := proc(label,actual,expectedValue,tolerance)
    global failures;
    local errorValue;
    errorValue := evalf(abs(actual-expectedValue));
    if errorValue>tolerance then
        failures := failures+1;
        printf("FAIL %s: error=%a actual=%a expected=%a\n",label,errorValue,actual,expectedValue);
    else
        printf("PASS %s: error=%a\n",label,errorValue);
    end if;
end proc:

CheckRelative := proc(label,actual,expectedValue,tolerance)
    global failures;
    local errorValue,scale;
    scale := abs(expectedValue):
    errorValue := evalf(abs(actual-expectedValue)/`if`(scale=0,1,scale)):
    if errorValue>tolerance then
        failures := failures+1:
        printf("FAIL %s: relative error=%a actual=%a expected=%a\n",label,errorValue,actual,expectedValue):
    else
        printf("PASS %s: relative error=%a\n",label,errorValue):
    end if:
end proc:

CheckTrue := proc(label,condition)
    global failures;
    if condition then
        printf("PASS %s\n",label);
    else
        failures := failures+1;
        printf("FAIL %s\n",label);
    end if;
end proc:

ExpectError := proc(label,callback::procedure,pattern::string)
    global failures;
    local messageText;
    try
        callback();
        failures := failures+1;
        printf("FAIL %s: no error was raised\n",label);
    catch:
        messageText := convert(lastexception[2],string);
        if StringTools:-Search(pattern,messageText)>0 then
            printf("PASS %s: %s\n",label,messageText);
        else
            failures := failures+1;
            printf("FAIL %s: unexpected error: %s\n",label,messageText);
        end if;
    end try;
end proc:

RisingExact := proc(parameter,order::nonnegint)
    local k;
    return mul(parameter+k,k=0..order-1);
end proc:

# An independent finite double sum is an oracle for an interior Appell F2 value.
a := 1/4: b1 := 1/3: b2 := 1/5: c1 := 7/6: c2 := 8/7: x := 1/20: y := 1/30:
f2Oracle := evalf[50](add(add(RisingExact(a,m+n)*RisingExact(b1,m)*RisingExact(b2,n)*x^m*y^n/(RisingExact(c1,m)*RisingExact(c2,n)*m!*n!),n=0..40-m),m=0..40)):
f2Report := AppellF2(a,b1,b2,c1,c2,x,y,'digits'=30,'returnDiagnostics'=true):
CheckClose("Appell F2 independent double sum",f2Report:-value,f2Oracle,1.e-28):
CheckTrue("Appell F2 convolution dispatch",evalb(f2Report:-methodUsed="convolution")):

# First derivatives are checked through shifted-parameter identities.
f2Vector := AppellF2(a,b1,b2,c1,c2,x,y,'digits'=30,'returnDerivatives'=true):
f2Dx := a*b1/c1*AppellF2(a+1,b1+1,b2,c1+1,c2,x,y,'digits'=32):
f2Dy := a*b2/c2*AppellF2(a+1,b1,b2+1,c1,c2+1,x,y,'digits'=32):
CheckClose("Appell F2 derivative x",f2Vector[2],f2Dx,1.e-28):
CheckClose("Appell F2 derivative y",f2Vector[3],f2Dy,1.e-28):

f3Vector := AppellF3(2/7,3/8,5/9,7/10,11/9,1/40,1/50,'digits'=28,'returnDerivatives'=true):
f3Dx := (2/7)*(5/9)/(11/9)*AppellF3(2/7+1,3/8,5/9+1,7/10,11/9+1,1/40,1/50,'digits'=30):
f3Dy := (3/8)*(7/10)/(11/9)*AppellF3(2/7,3/8+1,5/9,7/10+1,11/9+1,1/40,1/50,'digits'=30):
CheckClose("Appell F3 derivative x",f3Vector[2],f3Dx,1.e-26):
CheckClose("Appell F3 derivative y",f3Vector[3],f3Dy,1.e-26):

f4Vector := AppellF4(2/7,3/8,7/6,8/7,1/100,1/120,'digits'=28,'returnDerivatives'=true):
f4Dx := (2/7)*(3/8)/(7/6)*AppellF4(2/7+1,3/8+1,7/6+1,8/7,1/100,1/120,'digits'=30):
f4Dy := (2/7)*(3/8)/(8/7)*AppellF4(2/7+1,3/8+1,7/6,8/7+1,1/100,1/120,'digits'=30):
CheckClose("Appell F4 derivative x",f4Vector[2],f4Dx,1.e-26):
CheckClose("Appell F4 derivative y",f4Vector[3],f4Dy,1.e-26):

# Appell F1 is routed through the specialized rank-three Lauricella FD path.
f1Report := AppellF1(1/2,2/3,3/4,5/2,1/10,1/5,'digits'=25,'returnDiagnostics'=true):
fdReport := LauricellaFD(1/2,[2/3,3/4],5/2,[1/10,1/5],'digits'=25,'returnDiagnostics'=true):
CheckClose("Appell F1 equals Lauricella FD2",f1Report:-value,fdReport:-value,1.e-24):
CheckTrue("Appell F1 uses FD dispatch",evalb(f1Report:-hpType="LauricellaFDEvaluation")):

# Exact cancellation is performed before lower-parameter pole checks.
zeroFZero := HypergeometricPFQ([],[],2,'digits'=25,'returnDerivatives'=true):
CheckClose("0F0 value",zeroFZero[1],exp(2),1.e-24):
CheckClose("0F0 derivative",zeroFZero[2],exp(2),1.e-24):
CheckClose("1F1 entire series",HypergeometricPFQ([1/3],[5/4],3,'digits'=25),evalf[30](hypergeom([1/3],[5/4],3)),1.e-24):
ExpectError("divergent pFq fails closed",proc() HypergeometricPFQ([1,1],[],1/10,'digits'=20) end proc,"divergent for p>q+1"):
CheckClose("terminating 2F0",HypergeometricPFQ([-2,1],[],2,'digits'=20),5,1.e-19):
CheckClose("exact upper-lower cancellation",Hypergeometric2F1(1,-2,-2,1/3,'digits'=25),3/2,1.e-24):
ExpectError("uncancelled lower pole",proc() Hypergeometric2F1(1,1,0,1/10,'digits'=20) end proc,"uncancelled singular lower parameter"):
CheckClose("cancelled lower pole at origin",Hypergeometric2F1(1,-2,-2,0,'digits'=20),1,1.e-19):
ExpectError("uncancelled lower pole at origin",proc() Hypergeometric2F1(1,1,0,0,'digits'=20) end proc,"uncancelled singular lower parameter"):

# Large terminating degrees and severe cancellation use exact identities.
largeBinomialAtOne := HypergeometricPFQ([-1000],[],1,'digits'=30,'returnDiagnostics'=true):
largeBinomialAtTwo := HypergeometricPFQ([-1000],[],2,'digits'=30,'returnDiagnostics'=true):
CheckClose("large terminating 1F0 at one",largeBinomialAtOne:-value,0,0):
CheckClose("large terminating 1F0 at two",largeBinomialAtTwo:-value,1,0):
CheckTrue("large terminating 1F0 closed dispatch",evalb(largeBinomialAtOne:-methodUsed="closed_form" and largeBinomialAtTwo:-methodUsed="closed_form")):
tinyExponential := HypergeometricPFQ([],[],-1000,'digits'=30,'returnDiagnostics'=true):
CheckRelative("0F0 preserves exp(-1000)",tinyExponential:-value,evalf[60](exp(-1000)),1.e-29):
CheckTrue("0F0 tiny value is not chopped",evalb(tinyExponential:-value<>0)):
vandermondeZero := Hypergeometric2F1(-100,100,1,1,'digits'=30,'returnDiagnostics'=true):
CheckClose("terminating 2F1 cancellation at one",vandermondeZero:-value,0,0):
CheckTrue("terminating 2F1 cancellation error floor",evalb(vandermondeZero:-errorEstimate>=1.e-29)):

# Cancelling 0/0 parameter rows are removed before derivative quotients.
cancelledZeroVector := HypergeometricPFQ([0],[0],1/2,'digits'=30,'returnDerivatives'=true):
CheckClose("cancelled 0/0 value",cancelledZeroVector[1],evalf[40](exp(1/2)),1.e-29):
CheckClose("cancelled 0/0 derivative",cancelledZeroVector[2],evalf[40](exp(1/2)),1.e-29):
cancelledZeroBinomial := HypergeometricPFQ([1/3,0],[0],1/2,'digits'=30,'returnDerivatives'=true):
CheckClose("cancelled 0/0 binomial derivative",cancelledZeroBinomial[2],evalf[40]((1/3)*(1-1/2)^(-4/3)),1.e-28):

# Generic rank-one connections reconstruct derivatives from dF=A(x)F.
genericZeroFZero := HypergeometricPFQ([],[],1/5,'digits'=20,'method'="generic",'returnDiagnostics'=true):
CheckClose("generic rank-one 0F0 derivative",genericZeroFZero:-derivatives[1],evalf[30](exp(1/5)),1.e-19):
CheckTrue("generic Pfaffian error is explicitly unknown",evalb(genericZeroFZero:-certificate="transport_error_unknown" and genericZeroFZero:-errorEstimate=infinity)):
genericOneFZero := HypergeometricPFQ([1/3],[],1/5,'digits'=20,'method'="generic",'returnDerivatives'=true):
CheckClose("generic rank-one 1F0 derivative",genericOneFZero[2],evalf[30]((1/3)*(1-1/5)^(-4/3)),1.e-19):
genericCancelled := HypergeometricPFQ([0],[0],1/5,'digits'=20,'method'="generic",'returnDerivatives'=true):
CheckClose("generic cancelled pFq derivative",genericCancelled[2],evalf[30](exp(1/5)),1.e-19):
genericCancelledFA := LauricellaFA(1/3,[0],[0],[1/5],'digits'=20,'method'="generic",'returnDerivatives'=true):
CheckClose("generic cancelled FA derivative",genericCancelledFA[2],evalf[30]((1/3)*(1-1/5)^(-4/3)),1.e-19):

# In one variable, FB and FC cancellation must precede termination tests.
reducedFB := LauricellaFB([-2],[1/4],-2,[1/3],'digits'=28,'returnDerivatives'=true):
reducedFC := LauricellaFC(-2,1/4,[-2],[1/3],'digits'=28,'returnDerivatives'=true):
reducedValue := evalf[35]((1-1/3)^(-1/4)):
reducedDerivative := evalf[35]((1/4)*(1-1/3)^(-5/4)):
CheckClose("Lauricella FB exact row cancellation",reducedFB[1],reducedValue,1.e-27):
CheckClose("Lauricella FB cancelled derivative",reducedFB[2],reducedDerivative,1.e-27):
CheckClose("Lauricella FC exact row cancellation",reducedFC[1],reducedValue,1.e-27):
CheckClose("Lauricella FC cancelled derivative",reducedFC[2],reducedDerivative,1.e-27):

# The FD/F1 a=c product identity is regular even for a=c=-2.
fdCancelled := LauricellaFD(-2,[1/3,1/4],-2,[1/5,1/6],'digits'=25,'returnDiagnostics'=true):
f1Cancelled := AppellF1(-2,1/3,1/4,-2,1/5,1/6,'digits'=25,'returnDiagnostics'=true):
fdCancelledForced := LauricellaFD(-2,[1/3,1/4],-2,[1/5,1/6],'digits'=25,'method'="series"):
fdCancelledOracle := evalf[35]((1-1/5)^(-1/3)*(1-1/6)^(-1/4)):
CheckClose("Lauricella FD nonpositive a=c reduction",fdCancelled:-value,fdCancelledOracle,1.e-24):
CheckClose("Appell F1 nonpositive a=c reduction",f1Cancelled:-value,fdCancelledOracle,1.e-24):
CheckClose("forced-series FD a=c reduction",fdCancelledForced,fdCancelledOracle,1.e-24):
CheckTrue("nonpositive a=c closed dispatch",evalb(fdCancelled:-methodUsed="closed_form" and f1Cancelled:-methodUsed="closed_form")):

# This large-parameter case is an independent regression oracle for a false
# small-prefix result observed in other backends.
hardGauss30 := Hypergeometric2F1(1000,-99975/100,6/5,1/100,'digits'=30,'returnDiagnostics'=true):
hardGauss40 := Hypergeometric2F1(1000,-99975/100,6/5,1/100,'digits'=40):
CheckClose("large-parameter 2F1 independent oracle",hardGauss30:-value,-.00571510427786643869808599,1.e-24):
CheckRelative("large-parameter 2F1 precision stability",hardGauss30:-value,hardGauss40,1.e-28):
CheckTrue("large-parameter 2F1 diagnostic floor",evalb(hardGauss30:-errorEstimate>=1.e-29)):

# Exact perturbations of a nonpositive lower parameter must survive numeric
# conversion.  Each low/high pair either agrees or the evaluator fails closed.
nearPole := -100+10^(-100):
nearGauss18 := Hypergeometric2F1(1/3,2/5,nearPole,1/2,'digits'=18,'returnDiagnostics'=true):
nearGauss28 := Hypergeometric2F1(1/3,2/5,nearPole,1/2,'digits'=28):
CheckRelative("near-pole 2F1 precision stability",nearGauss18:-value,nearGauss28,1.e-17):
nearFA18 := LauricellaFA(1/3,[1/5,1/7],[nearPole,6/5],[1/4,1/5],'digits'=18,'returnDiagnostics'=true):
nearFA28 := LauricellaFA(1/3,[1/5,1/7],[nearPole,6/5],[1/4,1/5],'digits'=28):
CheckRelative("near-pole Lauricella FA precision stability",nearFA18:-value,nearFA28,1.e-16):
nearFB18 := LauricellaFB([1/3,2/7],[1/5,1/7],nearPole,[1/4,1/5],'digits'=18,'returnDiagnostics'=true):
nearFB28 := LauricellaFB([1/3,2/7],[1/5,1/7],nearPole,[1/4,1/5],'digits'=28):
CheckRelative("near-pole Lauricella FB precision stability",nearFB18:-value,nearFB28,1.e-16):
nearFC18 := LauricellaFC(1/3,2/5,[nearPole,6/5],[1/4,1/16],'digits'=18,'maximumDegree'=420,'returnDiagnostics'=true):
nearFC28 := LauricellaFC(1/3,2/5,[nearPole,6/5],[1/4,1/16],'digits'=28,'maximumDegree'=480):
CheckRelative("near-pole Lauricella FC precision stability",nearFC18:-value,nearFC28,1.e-16):
nearH318 := HornH3(1/3,2/5,nearPole,1/100,1/120,'digits'=18,'returnDiagnostics'=true):
nearH328 := HornH3(1/3,2/5,nearPole,1/100,1/120,'digits'=28):
CheckRelative("near-pole Horn H3 precision stability",nearH318:-value,nearH328,1.e-16):
for nearReport in [nearGauss18,nearFA18,nearFB18,nearFC18,nearH318] do CheckTrue("near-pole diagnostic rounding floor",evalb(nearReport:-errorEstimate>=10^(1-18)*max(abs(nearReport:-value),1))): end do:

nearH3Small := -2+10^(-80):
nearH3Small20 := HornH3(1/3,2/5,nearH3Small,1/100,1/120,'digits'=20,'returnDiagnostics'=true):
nearH3Small30 := HornH3(1/3,2/5,nearH3Small,1/100,1/120,'digits'=30):
CheckRelative("Horn H3 80-digit pole separation",nearH3Small20:-value,nearH3Small30,1.e-19):
CheckTrue("Horn H3 near-pole diagnostic is nonzero",evalb(nearH3Small20:-errorEstimate>=10^(1-20)*abs(nearH3Small20:-value))):

# A diagonal complex displacement must be measured in the complex plane.  At
# ordinary guard precision its real part would otherwise round onto the pole
# while its imaginary part survived, changing the phase by order one.
nearComplexDiagonal := -2+1/10^80+I/10^80:
complexGauss20 := Hypergeometric2F1(1/3,2/5,nearComplexDiagonal,1/10,'digits'=20,'method'="series",'returnDiagnostics'=true):
complexGaussReference := Hypergeometric2F1(1/3,2/5,nearComplexDiagonal,1/10,'digits'=110,'method'="series"):
CheckRelative("complex diagonal near-pole pFq",complexGauss20:-value,complexGaussReference,1.e-18):
complexFA20 := LauricellaFA(1/3,[1/5,1/7],[nearComplexDiagonal,6/5],[1/10,1/12],'digits'=20,'method'="series",'returnDiagnostics'=true):
complexFAReference := LauricellaFA(1/3,[1/5,1/7],[nearComplexDiagonal,6/5],[1/10,1/12],'digits'=110,'method'="series"):
CheckRelative("complex diagonal near-pole FA",complexFA20:-value,complexFAReference,1.e-18):
complexFB20 := LauricellaFB([1/3,2/7],[1/5,1/7],nearComplexDiagonal,[1/10,1/12],'digits'=20,'method'="series",'returnDiagnostics'=true):
complexFBReference := LauricellaFB([1/3,2/7],[1/5,1/7],nearComplexDiagonal,[1/10,1/12],'digits'=110,'method'="series"):
CheckRelative("complex diagonal near-pole FB",complexFB20:-value,complexFBReference,1.e-18):
complexFC20 := LauricellaFC(1/3,2/5,[nearComplexDiagonal,6/5],[1/100,1/120],'digits'=20,'method'="series",'maximumDegree'=420,'returnDiagnostics'=true):
complexFCReference := LauricellaFC(1/3,2/5,[nearComplexDiagonal,6/5],[1/100,1/120],'digits'=110,'method'="series",'maximumDegree'=520):
CheckRelative("complex diagonal near-pole FC",complexFC20:-value,complexFCReference,1.e-18):
complexH320 := HornH3(1/3,2/5,nearComplexDiagonal,1/100,0,'digits'=20,'method'="series",'maximumDegree'=200,'returnDiagnostics'=true):
complexH3Reference := Hypergeometric2F1(1/6,2/3,nearComplexDiagonal,1/25,'digits'=110,'method'="series"):
CheckRelative("complex diagonal near-pole Horn H3",complexH320:-value,complexH3Reference,1.e-18):
digitsBeforeGuardFailure := Digits:
ExpectError("complex conditioning guard cap",proc() Hypergeometric2F1(1/3,2/5,-2+1/10^5000+I/10^5000,1/10,'digits'=20,'method'="series") end proc,"conditioning guard exceeds 4096 digits"):
CheckTrue("complex conditioning guard restores Digits",evalb(Digits=digitsBeforeGuardFailure)):

# A lower parameter near -100 can hide the coefficient surge until degree 101.
# Independent pFq axes verify every multivariate kernel and the reported degree.
for poleSeparation in [100,150,180] do
    delayedComplexPole := -100+I/10^poleSeparation:
    delayedAxisReference := Hypergeometric2F1(1/3,2/5,delayedComplexPole,1/100,'digits'=22,'method'="series",'maximumDegree'=260):
    delayedHornReference := Hypergeometric2F1(1/6,2/3,delayedComplexPole,1/25,'digits'=22,'method'="series",'maximumDegree'=260):
    delayedReports := [
        LauricellaFA(1/3,[2/5,0],[delayedComplexPole,6/5],[1/100,0],'digits'=18,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true),
        LauricellaFB([1/3,0],[2/5,0],delayedComplexPole,[1/100,0],'digits'=18,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true),
        LauricellaFC(1/3,2/5,[delayedComplexPole,6/5],[1/100,0],'digits'=18,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true)
    ]:
    for delayedReport in delayedReports do
        CheckRelative(cat("complex delayed-pole Lauricella axis ",poleSeparation),delayedReport:-value,delayedAxisReference,1.e-16):
        CheckTrue(cat("complex delayed-pole Lauricella degree ",poleSeparation),evalb(delayedReport:-degree>100)):
    end do:
    delayedHornReports := [
        HornH3(1/3,0,delayedComplexPole,1/100,0,'digits'=18,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true),
        HornH4(1/3,0,delayedComplexPole,0,1/100,0,'digits'=18,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true)
    ]:
    for delayedReport in delayedHornReports do
        CheckRelative(cat("complex delayed-pole Horn axis ",poleSeparation),delayedReport:-value,delayedHornReference,1.e-16):
        CheckTrue(cat("complex delayed-pole Horn degree ",poleSeparation),evalb(delayedReport:-degree>100)):
    end do:
end do:
ExpectError("delayed-pole pFq maximumDegree fail-closed",proc() Hypergeometric2F1(1/3,2/5,-100+I/10^150,1/100,'digits'=18,'maximumDegree'=80) end proc,"below the near-pole transient-and-tail degree"):
ExpectError("delayed-pole FA maximumDegree fail-closed",proc() LauricellaFA(1/3,[2/5,0],[-100+I/10^150,6/5],[1/100,0],'digits'=18,'maximumDegree'=80) end proc,"below the near-pole transient-and-tail degree"):
ExpectError("delayed-pole FB maximumDegree fail-closed",proc() LauricellaFB([1/3,0],[2/5,0],-100+I/10^150,[1/100,0],'digits'=18,'maximumDegree'=80) end proc,"below the near-pole transient-and-tail degree"):
ExpectError("delayed-pole FC maximumDegree fail-closed",proc() LauricellaFC(1/3,2/5,[-100+I/10^150,6/5],[1/100,0],'digits'=18,'maximumDegree'=80) end proc,"below the near-pole transient-and-tail degree"):
ExpectError("delayed-pole H3 maximumDegree fail-closed",proc() HornH3(1/3,0,-100+I/10^150,1/100,0,'digits'=18,'maximumDegree'=80) end proc,"below the near-pole transient-and-tail degree"):
ExpectError("delayed-pole H4 maximumDegree fail-closed",proc() HornH4(1/3,0,-100+I/10^150,0,1/100,0,'digits'=18,'maximumDegree'=80) end proc,"below the near-pole transient-and-tail degree"):

# A Maple float retains its own decimal mantissa even after the global Digits
# setting is lowered.  The evaluator must inspect that stored precision before
# forming constant+0*epsilon, or the real part of a near-pole displacement is
# lost while its imaginary part survives.
savedSourceDigits := Digits:
Digits := 220:
sourceExactRealPole := -100+1/10^100:
sourceFloatRealPole := evalf(sourceExactRealPole):
sourceExactDiagonalPole := -100+1/10^100+I/10^100:
sourceFloatDiagonalPole := evalf(sourceExactDiagonalPole):
Digits := savedSourceDigits:
sourceRealReference := Hypergeometric2F1(1/3,2/5,sourceExactRealPole,1/100,'digits'=22,'method'="series",'maximumDegree'=260):
sourceRealReport := Hypergeometric2F1(1/3,2/5,sourceFloatRealPole,1/100,'digits'=18,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true):
CheckRelative("stored-float real near-pole pFq",sourceRealReport:-value,sourceRealReference,1.e-16):
sourceDiagonalReference := Hypergeometric2F1(1/3,2/5,sourceExactDiagonalPole,1/100,'digits'=22,'method'="series",'maximumDegree'=260):
sourceHornReference := Hypergeometric2F1(1/6,2/3,sourceExactDiagonalPole,1/25,'digits'=22,'method'="series",'maximumDegree'=260):
for sourcePole in [sourceExactDiagonalPole,sourceFloatDiagonalPole] do
    sourceReports := [
        Hypergeometric2F1(1/3,2/5,sourcePole,1/100,'digits'=18,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true),
        LauricellaFA(1/3,[2/5,0],[sourcePole,6/5],[1/100,0],'digits'=18,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true),
        LauricellaFB([1/3,0],[2/5,0],sourcePole,[1/100,0],'digits'=18,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true),
        LauricellaFC(1/3,2/5,[sourcePole,6/5],[1/100,0],'digits'=18,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true)
    ]:
    for sourceReport in sourceReports do
        CheckRelative("stored-float diagonal near-pole pFq/Lauricella",sourceReport:-value,sourceDiagonalReference,1.e-16):
        CheckTrue("stored-float diagonal transient degree",evalb(sourceReport:-degree>100)):
        CheckTrue("stored-float diagonal error floor",evalb(sourceReport:-errorEstimate>=10^(1-18)*max(abs(sourceReport:-value),1))):
    end do:
    sourceHornReports := [
        HornH3(1/3,0,sourcePole,1/100,0,'digits'=18,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true),
        HornH4(1/3,0,sourcePole,0,1/100,0,'digits'=18,'method'="series",'maximumDegree'=260,'returnDiagnostics'=true)
    ]:
    for sourceReport in sourceHornReports do
        CheckRelative("stored-float diagonal near-pole Horn",sourceReport:-value,sourceHornReference,1.e-16):
        CheckTrue("stored-float diagonal Horn transient degree",evalb(sourceReport:-degree>100)):
        CheckTrue("stored-float diagonal Horn error floor",evalb(sourceReport:-errorEstimate>=10^(1-18)*max(abs(sourceReport:-value),1))):
    end do:
end do:

Digits := 17000:
sourceFloatRealCap := evalf(-2+1/10^5000):
sourceFloatDiagonalCap := evalf(-2+1/10^5000+I/10^5000):
Digits := savedSourceDigits:
digitsBeforeSourceGuardFailure := Digits:
ExpectError("stored-float real conditioning guard cap",proc() Hypergeometric2F1(1/3,2/5,sourceFloatRealCap,1/10,'digits'=20,'method'="series") end proc,"conditioning guard exceeds 4096 digits"):
ExpectError("stored-float diagonal conditioning guard cap",proc() Hypergeometric2F1(1/3,2/5,sourceFloatDiagonalCap,1/10,'digits'=20,'method'="series") end proc,"conditioning guard exceeds 4096 digits"):
CheckTrue("stored-float guard failures restore Digits",evalb(Digits=digitsBeforeSourceGuardFailure)):

# A terminating upper parameter is valid outside the nonterminating convergence disk.
terminationReport := Hypergeometric2F1(-3,2,5,2,'digits'=25,'returnDiagnostics'=true):
CheckClose("terminating pFq outside disk",terminationReport:-value,3/35,1.e-24):
CheckTrue("terminating pFq certificate",evalb(terminationReport:-convergenceTest="exact_termination" and terminationReport:-degree=3)):

faPolynomial := LauricellaFA(-3,[1/3,1/5],[7/6,8/7],[2,3],'digits'=25,'method'="series"):
faPolynomialOracle := add(add(RisingExact(-3,m+n)*RisingExact(1/3,m)*RisingExact(1/5,n)*2^m*3^n/(RisingExact(7/6,m)*RisingExact(8/7,n)*m!*n!),n=0..3-m),m=0..3):
CheckClose("terminating Lauricella FA outside domain",faPolynomial,faPolynomialOracle,1.e-24):

# An exact degree-two polynomial is an independent seven-variable FA oracle.
fa7B := [1/5$7]:
fa7C := [6/5$7]:
fa7X := [2,1/2,1/3,1/4,1/5,1/6,1/7]:
fa7Expected := 1:
for i to 7 do
    fa7Expected := fa7Expected-2*fa7B[i]*fa7X[i]/fa7C[i]+fa7B[i]*(fa7B[i]+1)*fa7X[i]^2/(fa7C[i]*(fa7C[i]+1)):
    for j from i+1 to 7 do fa7Expected := fa7Expected+2*fa7B[i]*fa7B[j]*fa7X[i]*fa7X[j]/(fa7C[i]*fa7C[j]): end do:
end do:
fa7Polynomial := LauricellaFA(-2,fa7B,fa7C,fa7X,'digits'=28,'returnDiagnostics'=true):
CheckClose("terminating Lauricella FA7 exact oracle",fa7Polynomial:-value,fa7Expected,1.e-25):
CheckTrue("terminating Lauricella FA7 exterior dispatch",evalb(fa7Polynomial:-methodUsed="convolution" and fa7Polynomial:-convergenceTest="exact_termination")):

# High-degree exact polynomials require a complete-sum precision ladder.  These
# cases used to fail certification, and auto pFq then returned a grossly wrong
# complex Pfaffian value on the real axis.
for largeTerminationDegree in [200,299,600] do
    terminatingPFQ := Hypergeometric2F1(-largeTerminationDegree,1,2,2,'digits'=30,'maximumDegree'=largeTerminationDegree,'returnDiagnostics'=true):
    terminatingPFQExpected := (1-(-1)^(largeTerminationDegree+1))/(2*(largeTerminationDegree+1)):
    CheckClose(cat("large terminating pFq ",largeTerminationDegree),terminatingPFQ:-value,terminatingPFQExpected,1.e-28):
    CheckTrue(cat("large terminating pFq series route ",largeTerminationDegree),evalb(terminatingPFQ:-methodUsed="series")):
end do:
for largeTerminationDegree in [200,300,600] do
    terminatingFA := LauricellaFA(-largeTerminationDegree,[1,1],[1,2],[1,0],'digits'=30,'method'="series",'maximumDegree'=largeTerminationDegree,'returnDiagnostics'=true):
    CheckClose(cat("large terminating FA value ",largeTerminationDegree),terminatingFA:-value,0,1.e-28):
    CheckTrue(cat("large terminating FA derivatives ",largeTerminationDegree),evalb(max(seq(abs(terminatingFA:-derivatives[i]),i=1..2))<1.e-28)):
    CheckTrue(cat("large terminating FA precision rerun ",largeTerminationDegree),evalb(terminatingFA:-convergenceTest="precision_rerun_exact_termination")):
end do:

# Safe nonnegative Horn constraints provide a finite-support degree.
finiteH3Oracle := evalf[45](add(add(RisingExact(-4,2*m+n)*RisingExact(1/3,n)*(2/5)^m*(1/5)^n/(RisingExact(5/4,m+n)*m!*n!),n=0..4-2*m),m=0..2)):
finiteH3 := HornH3(-4,1/3,5/4,2/5,1/5,'digits'=28,'method'="series",'maximumDegree'=4,'returnDiagnostics'=true):
CheckClose("Horn H3 finite-support oracle",finiteH3:-value,finiteH3Oracle,1.e-26):
CheckTrue("Horn H3 finite-support certificate",evalb(finiteH3:-degree=4 and finiteH3:-convergenceTest="exact_termination")):

# Termination and operation gates run before coefficient arrays or loops.
ExpectError("terminating pFq maximumDegree gate",proc() Hypergeometric2F1(-300,1/3,5/4,1/3,'digits'=15,'method'="series",'maximumDegree'=50) end proc,"needs degree"):
ExpectError("terminating FA maximumDegree gate",proc() LauricellaFA(-300,[1/3,1/4],[5/4,6/5],[1/3,1/4],'digits'=15,'method'="series",'maximumDegree'=50) end proc,"needs degree"):
ExpectError("terminating Horn maximumDegree gate",proc() HornH3(-300,1/3,5/4,1/10,1/20,'digits'=15,'method'="series",'maximumDegree'=50) end proc,"needs degree"):
largeGateStart := time[real]():
ExpectError("huge terminating pFq operation gate",proc() Hypergeometric2F1(-10000000,1/3,5/4,1/3,'digits'=15,'method'="series",'maximumDegree'=10000000) end proc,"operation resource gate"):
ExpectError("huge terminating FA operation gate",proc() LauricellaFA(-100000,[1/3,1/4],[5/4,6/5],[1/3,1/4],'digits'=15,'method'="series",'maximumDegree'=100000) end proc,"operation resource gate"):
ExpectError("huge terminating Horn term gate",proc() HornH3(-100000,1/3,5/4,1/10,1/20,'digits'=15,'method'="series",'maximumDegree'=100000) end proc,"two-million-term resource gate"):
CheckTrue("huge termination gates are preallocation",evalb(time[real]()-largeGateStart<2)):

# Explicit path data cannot be silently replaced by a principal series or native call.
ExpectError("waypoint rejects principal series",proc() Hypergeometric2F1(1,1,2,1/2,'digits'=20,'method'="series",'waypoints'=[[1/4]]) end proc,"cannot honour an explicit"):
ExpectError("branch request rejects native call",proc() Hypergeometric2F1(1,1,2,1/2,'digits'=20,'method'="native",'branchSide'=1) end proc,"cannot honour an explicit"):
ExpectError("nonfinite waypoint is rejected",proc() Hypergeometric2F1(1,1,2,1/2,'digits'=12,'method'="pfaffian",'waypoints'=[[infinity]]) end proc,"nonfinite"):
principalLogarithm := Hypergeometric2F1(1,1,2,1/2,'digits'=14):
windingWaypoints := [[1/2],[1+I/2],[3/2],[1-I/2],[1/2]]:
windingReport := Hypergeometric2F1(1,1,2,1/2,'digits'=12,'method'="pfaffian",'waypoints'=windingWaypoints,'returnDiagnostics'=true):
CheckClose("explicit 2F1 winding changes the sheet",abs(windingReport:-value-principalLogarithm),evalf[16](4*Pi),1.e-6):
CheckTrue("winding Pfaffian diagnostics are truthful",evalb(windingReport:-methodUsed="pfaffian" and windingReport:-certificate="transport_error_unknown" and windingReport:-errorEstimate=infinity)):

# The error estimate includes the final requested-digit presentation rounding.
roundingReport := Hypergeometric2F1(1,1,2,1/2,'digits'=20,'returnDiagnostics'=true):
roundingFloor := evalf[24](10^(1-20)*max(abs(roundingReport:-value),1)):
CheckTrue("diagnostic rounding floor",evalb(roundingReport:-errorEstimate>=roundingFloor)):

# The forced generic path remains available and agrees with the specialized path.
genericValue := AppellF2(a,b1,b2,c1,c2,1/50,1/60,'digits'=20,'method'="generic"):
specializedValue := AppellF2(a,b1,b2,c1,c2,1/50,1/60,'digits'=20,'method'="series"):
CheckClose("forced generic Appell F2 parity",genericValue,specializedValue,1.e-19):
normalizedF2Series := AppellF2(1/3,0,1/5,0,7/6,1/50,1/60,'digits'=20,'method'="series"):
normalizedF2Generic := AppellF2(1/3,0,1/5,0,7/6,1/50,1/60,'digits'=20,'method'="generic"):
CheckClose("forced generic Appell F2 exact normalization",normalizedF2Generic,normalizedF2Series,1.e-19):
normalizedH4Series := HornH4(1/3,0,7/6,0,1/100,1/120,'digits'=20,'method'="series"):
normalizedH4Generic := HornH4(1/3,0,7/6,0,1/100,1/120,'digits'=20,'method'="generic"):
CheckClose("forced generic Horn H4 exact normalization",normalizedH4Generic,normalizedH4Series,1.e-19):

# The resource gate is checked before a seven-variable Macaulay matrix is allocated.
gateStart := time():
ExpectError("generic Macaulay resource gate",proc() LauricellaFA(1/4,[1/5$7],[6/5$7],[1/2$7],'digits'=15,'method'="generic") end proc,"disabled above three variables"):
fd7GenericSeries := FunctionSeries("LauricellaFD",[1/4,1/5,1/5,1/5,1/5,1/5,1/5,1/5,1],7):
ExpectError("public Pfaffian resource gate",proc() FindPfaffianSystem(fd7GenericSeries,'digits'=15) end proc,"disabled above three variables"):
CheckTrue("resource gate latency",evalb(time()-gateStart<1.0)):

# Exact axis reductions provide independent univariate oracles for Horn G/H.
axisX := 1/50:
CheckClose("Horn G1 axis",HornG1(2/7,3/8,5/9,axisX,0,'digits'=25),Hypergeometric2F1(2/7,5/9,1-3/8,-axisX,'digits'=27),1.e-23):
CheckClose("Horn G2 axis",HornG2(2/7,3/8,5/9,7/10,axisX,0,'digits'=25),Hypergeometric2F1(2/7,7/10,1-5/9,-axisX,'digits'=27),1.e-23):
CheckClose("Horn G3 axis",HornG3(2/7,3/8,axisX,0,'digits'=25),Hypergeometric2F1((3/8)/2,(3/8+1)/2,1-2/7,-4*axisX,'digits'=27),1.e-23):
CheckClose("Horn H1 axis",HornH1(2/7,3/8,5/9,7/10,axisX,0,'digits'=25),Hypergeometric2F1(2/7,3/8,7/10,axisX,'digits'=27),1.e-23):
CheckClose("Horn H2 axis",HornH2(2/7,3/8,5/9,7/10,11/12,axisX,0,'digits'=25),Hypergeometric2F1(2/7,3/8,11/12,axisX,'digits'=27),1.e-23):
CheckClose("Horn H3 axis",HornH3(2/7,3/8,5/9,axisX,0,'digits'=25),Hypergeometric2F1((2/7)/2,(2/7+1)/2,5/9,4*axisX,'digits'=27),1.e-23):
CheckClose("Horn H4 axis",HornH4(2/7,3/8,5/9,7/10,axisX,0,'digits'=25),Hypergeometric2F1((2/7)/2,(2/7+1)/2,5/9,4*axisX,'digits'=27),1.e-23):
CheckClose("Horn H5 axis",HornH5(2/7,3/8,5/9,axisX,0,'digits'=25),Hypergeometric2F1((2/7)/2,(2/7+1)/2,1-3/8,-4*axisX,'digits'=27),1.e-23):
CheckClose("Horn H6 axis",HornH6(2/7,3/8,5/9,axisX,0,'digits'=25),Hypergeometric2F1((2/7)/2,(2/7+1)/2,1-3/8,-4*axisX,'digits'=27),1.e-23):
CheckClose("Horn H7 axis",HornH7(2/7,3/8,5/9,7/10,axisX,0,'digits'=25),Hypergeometric2F1((2/7)/2,(2/7+1)/2,7/10,4*axisX,'digits'=27),1.e-23):

# G1 can cross an exact zero row and later return to nonzero diagonal
# coefficients.  The recurrence must use a nonsingular predecessor instead of
# propagating the zero through the whole grid.
RisingInteger := proc(parameter,order::integer)
    local offset;
    if order=0 then return 1;
    elif order>0 then return mul(parameter+offset,offset=0..order-1);
    end if;
    return 1/mul(parameter-offset,offset=1..-order);
end proc:
zeroBarrierOracle := evalf[55](add(add(
    RisingInteger(1/4,m+n)*RisingInteger(0,n-m)*RisingInteger(2/5,m-n)*
    (1/100)^m*(1/200)^n/(m!*n!),n=0..50),m=0..50)):
zeroBarrierReport := HornG1(1/4,0,2/5,1/100,1/200,'digits'=30,'method'="series",'maximumDegree'=120,'returnDiagnostics'=true):
CheckRelative("Horn G1 zero-barrier recurrence",zeroBarrierReport:-value,zeroBarrierOracle,1.e-28):

# Interior decimal oracles were computed independently from coefficient sums.
hornNames := ["HornG1","HornG2","HornG3","HornH1","HornH2","HornH3","HornH4","HornH5","HornH6","HornH7"]:
hornParameters := [[2/7,3/8,5/9],[2/7,3/8,5/9,7/10],[2/7,3/8],[2/7,3/8,5/9,7/10],[2/7,3/8,5/9,7/10,11/12],[2/7,3/8,5/9],[2/7,3/8,5/9,7/10],[2/7,3/8,5/9],[2/7,3/8,5/9],[2/7,3/8,5/9,7/10]]:
hornExpected := [.99150549572316836314226764212656091567861705457313,.98087503576107930264150747526998024671764481629630,.97771462079409268728694930808128597966221847904915,.99887766011490925537480283228094560275355735357656,.99433266055868541101221242743295755653222685503632,1.0169383836103631913912106741270287495123734749011,1.0164900377656771478433736471527752138895877104222,.99204401387747088460092106836572102879234747118349,.98447048211776931965798416234815556252211232390203,1.0066797826720751400383863896373855273597802541652]:
hornMethods := ["pfaffian","neighbor_series","neighbor_series","neighbor_series","neighbor_series","neighbor_series","neighbor_series","pfaffian","neighbor_series","neighbor_series"]:
for i to nops(hornNames) do
    hornSeries := FunctionSeries(hornNames[i],hornParameters[i],2):
    hornReport := Evaluate(hornSeries,[1/50,3/200],'digits'=28,'returnDiagnostics'=true):
    CheckClose(cat(hornNames[i]," decimal oracle"),hornReport:-value,hornExpected[i],1.e-26):
    CheckTrue(cat(hornNames[i]," automatic dispatch"),evalb(hornReport:-methodUsed=hornMethods[i])):
end do:
forcedHornReport := HornG1(2/7,3/8,5/9,1/50,3/200,'digits'=28,'method'="series",'returnDiagnostics'=true):
CheckClose("Horn G1 forced neighbor oracle",forcedHornReport:-value,hornExpected[1],1.e-26):
CheckTrue("Horn G1 forced neighbor remains available",evalb(forcedHornReport:-methodUsed="neighbor_series")):

# A central difference checks the public Horn derivative independently.
step := 1.e-14:
hornVector := HornG1(2/7,3/8,5/9,1/50,3/200,'digits'=35,'returnDerivatives'=true):
hornDifference := (HornG1(2/7,3/8,5/9,1/50+step,3/200,'digits'=35)-HornG1(2/7,3/8,5/9,1/50-step,3/200,'digits'=35))/(2*step):
CheckClose("Horn G1 derivative central difference",hornVector[2],hornDifference,1.e-12):

# The legacy default API still returns a scalar.
CheckTrue("legacy scalar return",type(Hypergeometric2F1(1,1,2,1/2,'digits'=15),numeric)):
customSeries := HornSeries([1,1],[[1],[1]],[2],[[1]],"CustomGauss"):
customValue := Evaluate(customSeries,[1/3],'digits'=20,'method'="series"):
CheckClose("custom Horn series method",customValue,-log(1-1/3)/(1/3),1.e-18):

if failures=0 then
    printf("All fast hypergeometric tests passed.\n"):
else
    printf("%d fast hypergeometric test(s) failed.\n",failures):
    error "%1 fast hypergeometric test(s) failed",failures:
end if:
quit:
