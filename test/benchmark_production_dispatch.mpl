restart:
loadStart := time[real]():
read "../HyperPrecision.mpl":
loadSeconds := evalf(time[real]()-loadStart):
with(HyperPrecision):

timerFloor := .003:
hornOnly := evalb(getenv("HYPERPRECISION_BENCHMARK_HORN_ONLY")="1"):

MedianTime := proc(samples::list)
    local ordered;
    ordered := sort(samples);
    return ordered[iquo(nops(ordered)+1,2)];
end proc:

# Maple keeps numerical Appell and hypergeom results in evaluator-specific
# remember tables.  Clearing these names before, but outside, each timed call
# prevents a lookup from replacing the requested computation.
ClearResultCaches := proc()
    local cacheName,oldCacheClearLimit;
    for cacheName in ['evalf/AppellF1','evalf/AppellF2',
                      'evalf/AppellF3','evalf/AppellF4',
                      'evalf/hypergeom','evalf/Hypergeom'] do
        try forget(cacheName); catch: end try;
    end do;
    oldCacheClearLimit := kernelopts(cacheclearlimit);
    kernelopts(cacheclearlimit=1);
    gc();
    kernelopts(cacheclearlimit=oldCacheClearLimit);
    return NULL;
end proc:

ColdTiming := proc(callback::procedure)
    local result,startTime;
    ClearResultCaches();
    startTime := time[real]();
    result := callback(900001);
    return [evalf(time[real]()-startTime),result];
end proc:

WarmTiming := proc(callback::procedure,repetitions::posint,batchSize::posint)
    local result,samples,total,startTime,i,j,index;
    ClearResultCaches(); callback(700001);
    samples := []; result := NULL;
    for i to repetitions do
        total := 0;
        for j to batchSize do
            index := (i-1)*batchSize+j;
            ClearResultCaches();
            startTime := time[real]();
            result := callback(index);
            total := total+time[real]()-startTime;
        end do;
        samples := [op(samples),evalf(total/batchSize)];
    end do;
    return [MedianTime(samples),result,samples];
end proc:

InterleavedTimings := proc(callbacks::list,repetitions::posint,
                           batchSize::posint)
    local n,sampleLists,results,totals,round,batchIndex,inputIndex,
          offset,candidateIndex,startTime,i;
    n := nops(callbacks);
    sampleLists := Array(1..n,fill=[]);
    results := Array(1..n,fill=0);
    for i to n do
        ClearResultCaches();
        callbacks[i](700001);
    end do;
    for round to repetitions do
        totals := Array(1..n,fill=0);
        for batchIndex to batchSize do
            inputIndex := (round-1)*batchSize+batchIndex;
            for offset from 0 to n-1 do
                candidateIndex := 1+((offset+round+batchIndex-2) mod n);
                ClearResultCaches();
                startTime := time[real]();
                results[candidateIndex] := callbacks[candidateIndex](inputIndex);
                totals[candidateIndex] := totals[candidateIndex]+
                    time[real]()-startTime;
            end do;
        end do;
        for i to n do
            sampleLists[i] := [op(sampleLists[i]),
                evalf(totals[i]/batchSize)];
        end do;
    end do;
    return [seq([MedianTime(sampleLists[i]),results[i],sampleLists[i]],i=1..n)];
end proc:

CheckEquivalent := proc(label::string,left,right,digits::posint)
    local scale,difference,tolerance;
    scale := max(abs(left),abs(right),1);
    difference := evalf(abs(left-right)/scale);
    tolerance := evalf(10^(-digits+3));
    if difference>tolerance then
        error "%1 value parity failed: relative difference %2",label,difference;
    end if;
end proc:

CheckEvaluationRecordPair := proc(label::string,left,right,digits::posint)
    local i;
    CheckEquivalent(cat(label," value"),left:-value,right:-value,digits);
    if nops(left:-derivatives)<>nops(right:-derivatives) then
        error "%1 derivative workload mismatch",label;
    end if;
    for i to nops(left:-derivatives) do
        CheckEquivalent(cat(label," derivative ",i),
            left:-derivatives[i],right:-derivatives[i],digits);
    end do;
end proc:

ClassifyFailure := proc(messageText::string)
    if StringTools:-Search("resource gate",messageText)>0 or
       StringTools:-Search("operation limit",messageText)>0 or
       StringTools:-Search("maximumDegree",messageText)>0 or
       StringTools:-Search("exceeded maximumSteps",messageText)>0 or
       StringTools:-Search("time limit",messageText)>0 or
       StringTools:-Search("time expired",messageText)>0 then
        return "resource_failure";
    end if;
    return "numerical_failure";
end proc:

PortfolioThree := proc(label::string,digits::posint,
                       callbackA::procedure,nameA::string,
                       callbackB::procedure,nameB::string,
                       callbackC::procedure,nameC::string,
                       autoCallback::procedure,batchSize::posint)
    global timerFloor,loadSeconds;
    local cold,timings,timingA,timingB,timingC,autoTiming,fastest,report;
    cold := ColdTiming(autoCallback);
    timings := InterleavedTimings(
        [callbackA,callbackB,callbackC,autoCallback],5,batchSize);
    timingA := timings[1]; timingB := timings[2];
    timingC := timings[3]; autoTiming := timings[4];
    report := autoTiming[2];
    CheckEvaluationRecordPair(label,report,timingA[2],digits);
    CheckEvaluationRecordPair(label,report,timingB[2],digits);
    CheckEvaluationRecordPair(label,report,timingC[2],digits);
    fastest := min(timingA[1],timingB[1],timingC[1]);
    printf("%s digits=%d load=%.6f cold-auto=%.6f %s=%.6f %s=%.6f %s=%.6f auto=%.6f method=%s status=%s\n",
        label,digits,loadSeconds,cold[1],nameA,timingA[1],nameB,timingB[1],
        nameC,timingC[1],autoTiming[1],report:-methodUsed,
        report:-errorStatus);
    if autoTiming[1]>1.25*fastest+timerFloor then
        error "%1 automatic dispatch performance gate failed",label;
    end if;
    return [timingA,timingB,timingC,autoTiming,report,cold];
end proc:

PortfolioTwo := proc(label::string,digits::posint,
                     callbackA::procedure,nameA::string,
                     callbackB::procedure,nameB::string,
                     autoCallback::procedure,batchSize::posint)
    global timerFloor,loadSeconds;
    local cold,timings,timingA,timingB,autoTiming,fastest,report;
    cold := ColdTiming(autoCallback);
    timings := InterleavedTimings([callbackA,callbackB,autoCallback],
        5,batchSize);
    timingA := timings[1]; timingB := timings[2]; autoTiming := timings[3];
    report := autoTiming[2];
    CheckEvaluationRecordPair(label,report,timingA[2],digits);
    CheckEvaluationRecordPair(label,report,timingB[2],digits);
    fastest := min(timingA[1],timingB[1]);
    printf("%s digits=%d load=%.6f cold-auto=%.6f %s=%.6f %s=%.6f auto=%.6f method=%s status=%s\n",
        label,digits,loadSeconds,cold[1],nameA,timingA[1],nameB,timingB[1],
        autoTiming[1],report:-methodUsed,report:-errorStatus);
    if autoTiming[1]>1.25*fastest+timerFloor then
        error "%1 automatic dispatch performance gate failed",label;
    end if;
    return [timingA,timingB,autoTiming,report,cold];
end proc:

PortfolioOne := proc(label::string,digits::posint,
                     callbackA::procedure,nameA::string,
                     autoCallback::procedure,batchSize::posint)
    global timerFloor,loadSeconds;
    local cold,timings,timingA,autoTiming,report;
    cold := ColdTiming(autoCallback);
    timings := InterleavedTimings([callbackA,autoCallback],5,batchSize);
    timingA := timings[1]; autoTiming := timings[2];
    report := autoTiming[2];
    CheckEvaluationRecordPair(label,report,timingA[2],digits);
    printf("%s digits=%d load=%.6f cold-auto=%.6f %s=%.6f auto=%.6f method=%s status=%s\n",
        label,digits,loadSeconds,cold[1],nameA,timingA[1],autoTiming[1],
        report:-methodUsed,report:-errorStatus);
    if autoTiming[1]>1.25*timingA[1]+timerFloor then
        error "%1 automatic dispatch performance gate failed",label;
    end if;
    return [timingA,autoTiming,report,cold];
end proc:

# Horn methods are deliberately interleaved.  Every round uses one perturbed
# input for all candidates, but the candidate order rotates.  Thus kernel
# warm-up and slow-first effects cannot systematically favour one method.
HornPortfolioCall := proc(familyName::string,k::posint,requestedDigits::posint,
                          forcedMethod::string,derivativeWorkload::boolean)
    local y;
    y := 3/200+(k mod 97)/10^9;
    if familyName="G1" then return HornG1(2/7,3/8,5/9,1/50,y,'digits'=requestedDigits,'method'=forcedMethod,'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=derivativeWorkload);
    elif familyName="G2" then return HornG2(2/7,3/8,5/9,7/10,1/50,y,'digits'=requestedDigits,'method'=forcedMethod,'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=derivativeWorkload);
    elif familyName="G3" then return HornG3(2/7,3/8,1/50,y,'digits'=requestedDigits,'method'=forcedMethod,'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=derivativeWorkload);
    elif familyName="H1" then return HornH1(2/7,3/8,5/9,7/10,1/50,y,'digits'=requestedDigits,'method'=forcedMethod,'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=derivativeWorkload);
    elif familyName="H2" then return HornH2(2/7,3/8,5/9,7/10,11/12,1/50,y,'digits'=requestedDigits,'method'=forcedMethod,'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=derivativeWorkload);
    elif familyName="H3" then return HornH3(2/7,3/8,5/9,1/50,y,'digits'=requestedDigits,'method'=forcedMethod,'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=derivativeWorkload);
    elif familyName="H4" then return HornH4(2/7,3/8,5/9,7/10,1/50,y,'digits'=requestedDigits,'method'=forcedMethod,'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=derivativeWorkload);
    elif familyName="H5" then return HornH5(2/7,3/8,5/9,1/50,y,'digits'=requestedDigits,'method'=forcedMethod,'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=derivativeWorkload);
    elif familyName="H6" then return HornH6(2/7,3/8,5/9,1/50,y,'digits'=requestedDigits,'method'=forcedMethod,'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=derivativeWorkload);
    elif familyName="H7" then return HornH7(2/7,3/8,5/9,7/10,1/50,y,'digits'=requestedDigits,'method'=forcedMethod,'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=derivativeWorkload);
    end if;
    error "unknown Horn benchmark family %1",familyName;
end proc:

TimedHornAttempt := proc(familyName::string,digits::posint,
                         forcedMethod::string,k::posint,
                         derivativeWorkload::boolean)
    local result,startTime,messageText;
    ClearResultCaches();
    startTime := time[real]();
    try
        result := HornPortfolioCall(familyName,k,digits,forcedMethod,
            derivativeWorkload);
        return [true,evalf(time[real]()-startTime),result,"","ok"];
    catch:
        messageText := convert(lastexception[2],string);
        return [false,evalf(time[real]()-startTime),0,messageText,
            ClassifyFailure(messageText)];
    end try;
end proc:

CheckHornRecordPair := proc(label::string,left,right,digits::posint,
                            derivativeWorkload::boolean)
    local i;
    CheckEquivalent(cat(label," value"),left:-value,right:-value,digits);
    if derivativeWorkload then
        if nops(left:-derivatives)<>2 or nops(right:-derivatives)<>2 then
            error "%1 derivative vector has the wrong length",label;
        end if;
        for i to 2 do
            CheckEquivalent(cat(label," derivative ",i),
                left:-derivatives[i],right:-derivatives[i],digits);
        end do;
    elif nops(left:-derivatives)<>0 or nops(right:-derivatives)<>0 then
        error "%1 diagnostics-only workload computed derivatives",label;
    end if;
end proc:

HornPortfolio := proc(familyName::string,digits::posint,
                      derivativeWorkload::boolean)
    global timerFloor,loadSeconds;
    local orders,round,batchCount,batchIndex,inputIndex,orderIndex,
          candidate,attempt,totals,cold,seriesSamples,genericSamples,
          autoSamples,seriesFailures,seriesMessage,seriesReport,genericReport,
          autoReport,seriesMedian,genericMedian,autoMedian,fastest,
          seriesApplicable,seriesCategory;
    orders := [["series","generic","auto"],
               ["generic","auto","series"],
               ["auto","series","generic"]];
    cold := TimedHornAttempt(familyName,digits,"auto",900001,
        derivativeWorkload);
    if not cold[1] then error "Horn-%1 cold auto failed: %2",familyName,cold[4]; end if;
    seriesSamples := []; genericSamples := []; autoSamples := [];
    seriesFailures := 0; seriesMessage := ""; seriesCategory := "ok";
    seriesReport := 0; genericReport := 0; autoReport := 0;
    batchCount := 1;
    for round to 5 do
        totals := table();
        totals["series"] := 0; totals["generic"] := 0; totals["auto"] := 0;
        for batchIndex to batchCount do
            inputIndex := (round-1)*batchCount+batchIndex;
            orderIndex := 1+((round+batchIndex-2) mod 3);
            for candidate in orders[orderIndex] do
                attempt := TimedHornAttempt(familyName,digits,candidate,
                    inputIndex,derivativeWorkload);
                totals[candidate] := totals[candidate]+attempt[2];
                if candidate="series" then
                    if attempt[1] then
                        seriesReport := attempt[3];
                    else
                        seriesFailures := seriesFailures+1;
                        seriesMessage := attempt[4];
                        seriesCategory := attempt[5];
                    end if;
                elif candidate="generic" then
                    if not attempt[1] then error "Horn-%1 generic failed: %2",familyName,attempt[4]; end if;
                    genericReport := attempt[3];
                else
                    if not attempt[1] then error "Horn-%1 auto failed: %2",familyName,attempt[4]; end if;
                    autoReport := attempt[3];
                end if;
            end do;
        end do;
        seriesSamples := [op(seriesSamples),evalf(totals["series"]/batchCount)];
        genericSamples := [op(genericSamples),evalf(totals["generic"]/batchCount)];
        autoSamples := [op(autoSamples),evalf(totals["auto"]/batchCount)];
    end do;
    if seriesFailures<>0 and seriesFailures<>5*batchCount then
        error "Horn-%1 forced series has input-dependent resource behaviour",familyName;
    end if;
    seriesApplicable := evalb(seriesFailures=0);
    seriesMedian := MedianTime(seriesSamples);
    genericMedian := MedianTime(genericSamples);
    autoMedian := MedianTime(autoSamples);
    CheckHornRecordPair(cat("Horn-",familyName," auto/generic"),
        autoReport,genericReport,digits,derivativeWorkload);
    if genericReport:-pathDependent or
       genericReport:-branchProvenance<>"principal_canonical_transport" or
       genericReport:-errorStatus<>"unknown" or
       genericReport:-errorEstimate<>infinity or
       genericReport:-genericProvenance="not_applicable" or
       genericReport:-genericStepCount<0 then
        error "Horn-%1 generic diagnostics or path provenance changed",familyName;
    end if;
    if autoReport:-pathDependent then
        error "Horn-%1 automatic principal evaluation became path-dependent",familyName;
    end if;
    if seriesApplicable then
        CheckHornRecordPair(cat("Horn-",familyName," auto/series"),
            autoReport,seriesReport,digits,derivativeWorkload);
        if seriesReport:-pathDependent or
           seriesReport:-branchProvenance<>"principal_origin_germ" then
            error "Horn-%1 series path provenance changed",familyName;
        end if;
        fastest := min(seriesMedian,genericMedian);
        printf("Horn-%s workload=%s digits=%d load=%.6f cold-auto=%.6f neighbor=%.6f generic=%.6f auto=%.6f method=%s degree=%d status=%s path=%a steps=%d provenance=%s\n",
            familyName,`if`(derivativeWorkload,"derivatives","scalar"),digits,loadSeconds,cold[2],seriesMedian,genericMedian,
            autoMedian,autoReport:-methodUsed,autoReport:-degree,
            autoReport:-errorStatus,autoReport:-pathDependent,
            genericReport:-genericStepCount,genericReport:-genericProvenance);
    else
        fastest := genericMedian;
        printf("Horn-%s workload=%s digits=%d load=%.6f cold-auto=%.6f neighbor=%s(%.6f) generic=%.6f auto=%.6f method=%s degree=%d status=%s path=%a steps=%d provenance=%s\n",
            familyName,`if`(derivativeWorkload,"derivatives","scalar"),digits,loadSeconds,cold[2],
            seriesCategory,seriesMedian,genericMedian,autoMedian,
            autoReport:-methodUsed,autoReport:-degree,
            autoReport:-errorStatus,autoReport:-pathDependent,
            genericReport:-genericStepCount,genericReport:-genericProvenance);
        if seriesCategory="numerical_failure" and
           StringTools:-Search("did not certify",seriesMessage)=0 then
            error "Horn-%1 forced series failed for an unexpected reason: %2",familyName,seriesMessage;
        end if;
    end if;
    if autoReport:-methodUsed="neighbor_series" then
        if not seriesApplicable or
           autoReport:-branchProvenance<>"principal_origin_germ" or
           autoReport:-degree<>seriesReport:-degree or
           autoReport:-errorStatus<>seriesReport:-errorStatus or
           autoReport:-errorEstimate<>seriesReport:-errorEstimate then
            error "Horn-%1 automatic neighbor retry differs from forced series",familyName;
        end if;
    elif autoReport:-methodUsed="pfaffian" then
        if autoReport:-branchProvenance<>"principal_canonical_transport" or
           autoReport:-errorStatus<>"unknown" or
           autoReport:-errorEstimate<>infinity then
            error "Horn-%1 automatic generic diagnostics changed",familyName;
        end if;
    else
        error "Horn-%1 automatic selector returned unexpected method %2",familyName,autoReport:-methodUsed;
    end if;
    if familyName="H4" and digits=100 and
       (autoReport:-methodUsed<>"neighbor_series" or autoReport:-degree<>260) then
        error "Horn-H4 100-digit bounded retry regression";
    end if;
    if familyName="G2" and derivativeWorkload and
       member(digits,[80,90,95]) and autoReport:-methodUsed<>"pfaffian" then
        error "Horn-G2 derivative pre-crossover hysteresis regression at %1 digits",digits;
    end if;
    if familyName="G2" and derivativeWorkload and
       member(digits,[100,120]) and autoReport:-methodUsed<>"neighbor_series" then
        error "Horn-G2 derivative post-crossover hysteresis regression at %1 digits",digits;
    end if;
    if familyName="H7" and not derivativeWorkload and
       member(digits,[70,75,80,85,90]) and autoReport:-methodUsed<>"pfaffian" then
        error "Horn-H7 scalar generic safety-band regression at %1 digits",digits;
    end if;
    if familyName="H7" and not derivativeWorkload and
       member(digits,[50,69,100,120]) and autoReport:-methodUsed<>"neighbor_series" then
        error "Horn-H7 scalar neighbor-boundary regression at %1 digits",digits;
    end if;
    if autoMedian>1.25*fastest+timerFloor then
        error "Horn-%1 automatic dispatch performance gate failed at %2 digits",familyName,digits;
    end if;
    printf("Horn-%s workload=%s samples neighbor=%a generic=%a auto=%a\n",
        familyName,`if`(derivativeWorkload,"derivatives","scalar"),
        seriesSamples,genericSamples,autoSamples);
    return NULL;
end proc:

printf("PRODUCTION DISPATCH PORTFOLIO\n"):

if not hornOnly then
for benchmarkDigits in [15,50,100] do
  for generalDerivativeWorkload in [false,true] do
    workloadLabel := `if`(generalDerivativeWorkload,"derivatives","scalar"):
    pfqSeries := proc(k) local z; z:=9/20+(k mod 97)/10^9; return HypergeometricPFQ([1/7,2/7,3/7],[5/6,7/8],z,'digits'=benchmarkDigits,'method'="series",'maximumDegree'=1200,'returnDiagnostics'=true,'returnDerivatives'=generalDerivativeWorkload); end proc:
    pfqNative := proc(k) local z; z:=9/20+(k mod 97)/10^9; return HypergeometricPFQ([1/7,2/7,3/7],[5/6,7/8],z,'digits'=benchmarkDigits,'method'="native",'maximumDegree'=1200,'returnDiagnostics'=true,'returnDerivatives'=generalDerivativeWorkload); end proc:
    pfqGeneric := proc(k) local z; z:=9/20+(k mod 97)/10^9; return HypergeometricPFQ([1/7,2/7,3/7],[5/6,7/8],z,'digits'=benchmarkDigits,'method'="generic",'maximumDegree'=1200,'returnDiagnostics'=true,'returnDerivatives'=generalDerivativeWorkload); end proc:
    pfqAuto := proc(k) local z; z:=9/20+(k mod 97)/10^9; return HypergeometricPFQ([1/7,2/7,3/7],[5/6,7/8],z,'digits'=benchmarkDigits,'maximumDegree'=1200,'returnDiagnostics'=true,'returnDerivatives'=generalDerivativeWorkload); end proc:
    if benchmarkDigits<100 then
        PortfolioThree(cat("pFq-interior-",workloadLabel),benchmarkDigits,pfqSeries,"series",pfqNative,"native",pfqGeneric,"generic",pfqAuto,10):
    else
        # An uncached 100-digit forced generic call exceeded 30 seconds in the
        # baseline audit.  Auto and native complete in milliseconds, so the
        # routine gate does not rerun the dominated diagnostic-only route.
        PortfolioTwo(cat("pFq-interior-",workloadLabel),benchmarkDigits,pfqSeries,"series",pfqNative,"native",pfqAuto,5):
        printf("pFq-interior workload=%s digits=100 generic baseline exceeded 30 seconds\n",workloadLabel):
    end if:

    gaussSeries := proc(k) local z; z:=19/20-(k mod 97)/10^9; return Hypergeometric2F1(1/3,2/5,7/6,z,'digits'=benchmarkDigits,'method'="series",'maximumDegree'=6000,'returnDiagnostics'=true,'returnDerivatives'=generalDerivativeWorkload); end proc:
    gaussNative := proc(k) local z; z:=19/20-(k mod 97)/10^9; return Hypergeometric2F1(1/3,2/5,7/6,z,'digits'=benchmarkDigits,'method'="native",'maximumDegree'=6000,'returnDiagnostics'=true,'returnDerivatives'=generalDerivativeWorkload); end proc:
    gaussAuto := proc(k) local z; z:=19/20-(k mod 97)/10^9; return Hypergeometric2F1(1/3,2/5,7/6,z,'digits'=benchmarkDigits,'maximumDegree'=6000,'returnDiagnostics'=true,'returnDerivatives'=generalDerivativeWorkload); end proc:
    PortfolioTwo(cat("2F1-q095-",workloadLabel),benchmarkDigits,gaussSeries,"series",gaussNative,"native",gaussAuto,2):

    f2Series := proc(k) local y; y:=1/30+(k mod 97)/10^9; return AppellF2(1/4,1/3,1/5,7/6,8/7,1/20,y,'digits'=benchmarkDigits,'method'="series",'returnDiagnostics'=true,'returnDerivatives'=generalDerivativeWorkload); end proc:
    f2Native := proc(k) local y; y:=1/30+(k mod 97)/10^9; return AppellF2(1/4,1/3,1/5,7/6,8/7,1/20,y,'digits'=benchmarkDigits,'method'="native",'returnDiagnostics'=true,'returnDerivatives'=generalDerivativeWorkload); end proc:
    f2Generic := proc(k) local y; y:=1/30+(k mod 97)/10^9; return AppellF2(1/4,1/3,1/5,7/6,8/7,1/20,y,'digits'=benchmarkDigits,'method'="generic",'returnDiagnostics'=true,'returnDerivatives'=generalDerivativeWorkload); end proc:
    f2Auto := proc(k) local y; y:=1/30+(k mod 97)/10^9; return AppellF2(1/4,1/3,1/5,7/6,8/7,1/20,y,'digits'=benchmarkDigits,'returnDiagnostics'=true,'returnDerivatives'=generalDerivativeWorkload); end proc:
    PortfolioThree(cat("Appell-F2-interior-",workloadLabel),benchmarkDigits,f2Series,"convolution",f2Native,"native",f2Generic,"generic",f2Auto,1):

    f2BoundaryNative := proc(k) local y; y:=9/20-(k mod 97)/10^9; return AppellF2(1/4,1/3,1/5,7/6,8/7,1/2,y,'digits'=benchmarkDigits,'method'="native",'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=generalDerivativeWorkload); end proc:
    f2BoundaryAuto := proc(k) local y; y:=9/20-(k mod 97)/10^9; return AppellF2(1/4,1/3,1/5,7/6,8/7,1/2,y,'digits'=benchmarkDigits,'maximumDegree'=260,'returnDiagnostics'=true,'returnDerivatives'=generalDerivativeWorkload); end proc:
    PortfolioOne(cat("Appell-F2-q095-",workloadLabel),benchmarkDigits,f2BoundaryNative,"native",f2BoundaryAuto,1):

  end do:
end do:

b7 := [1/4$7]:
x7Interior := [1/2,1/3,1/4,1/5,1/6,1/7,1/8]:
x7Boundary := [19/20,9/10,4/5,7/10,3/5,1/2,2/5]:

FDPortfolioCall := proc(region::string,k::posint,requestedDigits::posint,
                        forcedMethod::string,derivativeWorkload::boolean)
    global b7,x7Interior,x7Boundary;
    local point,degreeCap;
    point := `if`(region="interior",x7Interior,x7Boundary);
    point := subsop(7=point[7]+(k mod 97)/10^9,point);
    if region="interior" then
        degreeCap := 800;
    elif forcedMethod="series" then
        degreeCap := `if`(requestedDigits=15,1600,
            `if`(requestedDigits=50,3400,6000));
    else
        degreeCap := 6000;
    end if;
    return LauricellaFD(1/4,b7,1,point,'digits'=requestedDigits,
        'method'=forcedMethod,'maximumDegree'=degreeCap,
        'returnDiagnostics'=true,'returnDerivatives'=derivativeWorkload);
end proc:

TimedFDAttempt := proc(region::string,digits::posint,forcedMethod::string,
                       k::posint,derivativeWorkload::boolean)
    local result,startTime,messageText;
    ClearResultCaches();
    startTime := time[real]();
    try
        result := timelimit(90,FDPortfolioCall(region,k,digits,
            forcedMethod,derivativeWorkload));
        return [true,evalf(time[real]()-startTime),result,"","ok"];
    catch:
        messageText := convert(lastexception[2],string);
        return [false,evalf(time[real]()-startTime),0,messageText,
            ClassifyFailure(messageText)];
    end try;
end proc:

FDCapPortfolioCall := proc(k::posint,degreeCap::posint,
                           forcedMethod::string)
    global b7,x7Boundary;
    local point;
    point := subsop(7=x7Boundary[7]+(k mod 97)/10^9,x7Boundary);
    return LauricellaFD(1/4,b7,1,point,'digits'=15,
        'method'=forcedMethod,'maximumDegree'=degreeCap,
        'returnDiagnostics'=true,'returnDerivatives'=true);
end proc:

CheckFDRecordPair := proc(label::string,left,right,digits::posint,
                          derivativeWorkload::boolean)
    local i;
    CheckEquivalent(cat(label," value"),left:-value,right:-value,digits);
    if derivativeWorkload then
        if nops(left:-derivatives)<>7 or nops(right:-derivatives)<>7 then
            error "%1 derivative vector has the wrong length",label;
        end if;
        for i to 7 do
            CheckEquivalent(cat(label," derivative ",i),
                left:-derivatives[i],right:-derivatives[i],digits);
        end do;
    elif nops(left:-derivatives)<>0 or nops(right:-derivatives)<>0 then
        error "%1 diagnostics-only workload computed derivatives",label;
    end if;
end proc:

for benchmarkDigits in [15,50,100] do
    for fdDerivativeWorkload in [false,true] do
        fdSeries := proc(k) return FDPortfolioCall("interior",k,benchmarkDigits,"series",fdDerivativeWorkload); end proc:
        fdAuto := proc(k) return FDPortfolioCall("interior",k,benchmarkDigits,"auto",fdDerivativeWorkload); end proc:
        fdInteriorGate := PortfolioOne(cat("FD7-interior-",`if`(fdDerivativeWorkload,"derivatives","scalar")),benchmarkDigits,fdSeries,"series",fdAuto,1):
        fdEulerAttempt := TimedFDAttempt("interior",benchmarkDigits,"euler",5,fdDerivativeWorkload):
        fdPfaffianAttempt := TimedFDAttempt("interior",benchmarkDigits,"pfaffian",5,fdDerivativeWorkload):
        fdFastest := fdInteriorGate[1][1]:
        if fdEulerAttempt[1] then
            CheckFDRecordPair("FD7 interior auto/Euler",fdInteriorGate[3],fdEulerAttempt[3],benchmarkDigits,fdDerivativeWorkload):
            fdFastest := min(fdFastest,fdEulerAttempt[2]):
        elif fdEulerAttempt[5]<>"resource_failure" then error "FD7 interior Euler failed numerically: %1",fdEulerAttempt[4]; end if:
        fdPfaffianSteps := -1:
        if fdPfaffianAttempt[1] then
            CheckFDRecordPair("FD7 interior auto/Pfaffian",fdInteriorGate[3],fdPfaffianAttempt[3],benchmarkDigits,fdDerivativeWorkload):
            if fdPfaffianAttempt[3]:-transportKind<>"rank_state" or fdPfaffianAttempt[3]:-stateStepCount<=0 or fdPfaffianAttempt[3]:-transportProvenance="not_applicable" then error "FD7 Pfaffian did not report rank-state transport provenance"; end if:
            fdPfaffianSteps := fdPfaffianAttempt[3]:-stateStepCount:
            fdFastest := min(fdFastest,fdPfaffianAttempt[2]):
        elif fdPfaffianAttempt[5]<>"resource_failure" then error "FD7 interior Pfaffian failed numerically: %1",fdPfaffianAttempt[4]; end if:
        if fdInteriorGate[2][1]>1.25*fdFastest+timerFloor then error "FD7 interior automatic dispatch performance gate failed"; end if:
        printf("FD7-interior workload=%s digits=%d series5=%a auto5=%a Euler-first-status=%s Euler-first=%.6f Pfaffian-first-status=%s Pfaffian-first=%.6f Pfaffian-steps=%d\n",`if`(fdDerivativeWorkload,"derivatives","scalar"),benchmarkDigits,fdInteriorGate[1][3],fdInteriorGate[2][3],fdEulerAttempt[5],fdEulerAttempt[2],fdPfaffianAttempt[5],fdPfaffianAttempt[2],fdPfaffianSteps):

        # Scalar Euler evaluation is one quadrature and wins near q=.95.
        # Derivative Euler evaluation requires eight independent quadratures,
        # while the grouped recurrence returns the value and all seven first
        # derivatives together.  Pair auto with the measured fast workload;
        # retain exactly one capped sample of the alternate long candidate.
        fdBoundaryFastMethod := `if`(fdDerivativeWorkload,"series","euler"):
        fdBoundaryAlternateMethod := `if`(fdDerivativeWorkload,"euler","series"):
        fdBoundaryFast := proc(k) return FDPortfolioCall("boundary",k,benchmarkDigits,fdBoundaryFastMethod,fdDerivativeWorkload); end proc:
        fdBoundaryAuto := proc(k) return FDPortfolioCall("boundary",k,benchmarkDigits,"auto",fdDerivativeWorkload); end proc:
        fdBoundaryGate := PortfolioOne(cat("FD7-q095-",`if`(fdDerivativeWorkload,"derivatives","scalar")),benchmarkDigits,fdBoundaryFast,fdBoundaryFastMethod,fdBoundaryAuto,1):
        if fdBoundaryGate[3]:-methodUsed<>fdBoundaryFastMethod then error "FD7 q=.95 automatic selector used %1 instead of the measured %2 workload",fdBoundaryGate[3]:-methodUsed,fdBoundaryFastMethod; end if:
        fdBoundaryAlternateAttempt := TimedFDAttempt("boundary",benchmarkDigits,fdBoundaryAlternateMethod,5,fdDerivativeWorkload):
        fdBoundaryPfaffianAttempt := TimedFDAttempt("boundary",benchmarkDigits,"pfaffian",5,fdDerivativeWorkload):
        if fdBoundaryAlternateAttempt[1] then
            CheckFDRecordPair(cat("FD7 q095 auto/",fdBoundaryAlternateMethod),fdBoundaryGate[3],fdBoundaryAlternateAttempt[3],benchmarkDigits,fdDerivativeWorkload):
            fdBoundaryFastest := min(fdBoundaryGate[1][1],fdBoundaryAlternateAttempt[2]);
        else
            fdBoundaryFastest := fdBoundaryGate[1][1];
        end if:
        fdBoundaryPfaffianSteps := -1:
        if fdBoundaryPfaffianAttempt[1] then
            CheckFDRecordPair("FD7 q095 auto/Pfaffian",fdBoundaryGate[3],fdBoundaryPfaffianAttempt[3],benchmarkDigits,fdDerivativeWorkload):
            fdBoundaryFastest := min(fdBoundaryFastest,fdBoundaryPfaffianAttempt[2]):
            fdBoundaryPfaffianSteps := fdBoundaryPfaffianAttempt[3]:-stateStepCount:
        elif fdBoundaryPfaffianAttempt[5]<>"resource_failure" then error "FD7 q095 Pfaffian candidate failed: %1",fdBoundaryPfaffianAttempt[4]; end if:
        if fdBoundaryGate[2][1]>1.25*fdBoundaryFastest+timerFloor then error "FD7 q095 automatic dispatch performance gate failed"; end if:
        printf("FD7-q095 workload=%s digits=%d fast-method=%s fast5=%a auto5=%a alternate-method=%s alternate-first-status=%s alternate-first=%.6f Pfaffian-first-status=%s Pfaffian-first=%.6f Pfaffian-steps=%d\n",`if`(fdDerivativeWorkload,"derivatives","scalar"),benchmarkDigits,fdBoundaryFastMethod,fdBoundaryGate[1][3],fdBoundaryGate[2][3],fdBoundaryAlternateMethod,fdBoundaryAlternateAttempt[5],fdBoundaryAlternateAttempt[2],fdBoundaryPfaffianAttempt[5],fdBoundaryPfaffianAttempt[2],fdBoundaryPfaffianSteps):
    end do:
end do:

# The tail estimate is an admission cost, whereas maximumDegree is a ceiling.
# Caps 1224 and 1225 both admit the measured degree-912 recurrence.  The huge
# cap is also only a ceiling: forced and automatic calls must use the same
# predicted bounded recurrence rather than allocating to the supplied cap.
for fdBoundaryCap in [1224,1225,1000000] do
    fdCapSeries := proc(k) return FDCapPortfolioCall(k,fdBoundaryCap,"series"); end proc:
    fdCapAuto := proc(k) return FDCapPortfolioCall(k,fdBoundaryCap,"auto"); end proc:
    fdCapGate := PortfolioOne(cat("FD7-q095-derivatives-cap",fdBoundaryCap),15,fdCapSeries,"series",fdCapAuto,1):
    fdCapForcedRecord := fdCapGate[1][2]: fdCapAutoRecord := fdCapGate[3]:
    if fdCapAutoRecord:-methodUsed<>"series" or fdCapForcedRecord:-degree<>fdCapAutoRecord:-degree or fdCapAutoRecord:-degree>=1224 or fdCapForcedRecord:-certificate<>fdCapAutoRecord:-certificate or fdCapForcedRecord:-errorStatus<>fdCapAutoRecord:-errorStatus or fdCapForcedRecord:-errorEstimate<>fdCapAutoRecord:-errorEstimate or fdCapForcedRecord:-branchProvenance<>fdCapAutoRecord:-branchProvenance or fdCapForcedRecord:-pathDependent<>fdCapAutoRecord:-pathDependent or not fdCapForcedRecord:-derivativeWorkload or not fdCapAutoRecord:-derivativeWorkload or fdCapForcedRecord:-resourceStatus<>"ok" or fdCapAutoRecord:-resourceStatus<>"ok" then error "FD7 cap %1 automatic selector did not preserve the bounded forced-series workload and diagnostics",fdBoundaryCap; end if:
end do:
end if:

for benchmarkDigits in [15,50,100] do
    for hornFamily in ["G1","G2","G3","H1","H2","H3","H4","H5","H6","H7"] do
        HornPortfolio(hornFamily,benchmarkDigits,false):
        HornPortfolio(hornFamily,benchmarkDigits,true):
    end do:
end do:

# Five paired samples on both sides of the G2 derivative crossover keep a
# five-digit safety band.  The 100-digit point is already covered by the full
# matrix above; these neighbors prevent a one-point selector fit.
for benchmarkDigits in [80,90,95,120] do
    HornPortfolio("G2",benchmarkDigits,true):
end do:

# Audit the H7 scalar generic safety band.  Three independent five-pair calls
# retain the measured variance at 80 digits.  The 100-digit neighbor boundary
# is included in the full matrix above.
for benchmarkDigits in [70,80,80,80,90,120] do
    HornPortfolio("H7",benchmarkDigits,false):
end do:

# The derivative selector remains independent of the scalar safety band.
for benchmarkDigits in [80,120] do
    HornPortfolio("H7",benchmarkDigits,true):
end do:

# Symbolic construction and numerical transport are separate workloads.
g1SeriesObject := FunctionSeries("HornG1",[2/7,3/8,5/9],2):
buildCallback := proc(k) return FindPfaffianSystem(g1SeriesObject,'digits'=30); end proc:
buildCold := ColdTiming(buildCallback):
buildTiming := WarmTiming(buildCallback,5,1):
g1System := buildCallback(0):
transportCallback := proc(k) local y; y:=3/200+(k mod 97)/10^9; return TransportDE(g1System,[1/50,y],'digits'=30,'maximumDegree'=260); end proc:
transportCold := ColdTiming(transportCallback):
transportTiming := WarmTiming(transportCallback,5,1):
printf("Horn-G1 generic build cold=%.6f warm=%.6f transport cold=%.6f warm=%.6f\n",buildCold[1],buildTiming[1],transportCold[1],transportTiming[1]):

# The specialized FD connection build, boundary seed, and rank-state
# transport are measured independently from the end-to-end portfolio.
fdBuildCallback := proc(k) return LauricellaFDPfaffianSystem(1/4,[1/4$7],1,'digits'=23); end proc:
fdBuildCold := ColdTiming(fdBuildCallback):
fdBuildTiming := WarmTiming(fdBuildCallback,5,1):
fdTransportSystem := fdBuildCallback(0):
fdTransportTarget := [1/2,1/3,1/4,1/5,1/6,1/7,1/8]:
fdTransportBase := map(value->value/8,fdTransportTarget):
fdSeedCallback := proc(k) return LauricellaFDInitialVector(1/4,[1/4$7],1,fdTransportBase,'digits'=15,'maximumDegree'=800); end proc:
fdSeedCold := ColdTiming(fdSeedCallback):
fdSeedTiming := WarmTiming(fdSeedCallback,5,1):
fdTransportSeed := fdSeedCallback(0):
fdStateTransportCallback := proc(k) local target; target:=subsop(7=fdTransportTarget[7]+(k mod 97)/10^9,fdTransportTarget); return TransportDE(fdTransportSystem,target,'digits'=15,'branchSide'=0,'frobeniusOrder'=48,'maximumSteps'=20000,'initialValue'=fdTransportSeed,'initialPoint'=fdTransportBase,'returnDiagnostics'=true); end proc:
fdTransportCold := ColdTiming(fdStateTransportCallback):
fdTransportTiming := WarmTiming(fdStateTransportCallback,5,1):
if fdTransportTiming[2]:-diagnostics:-provenance<>"explicit_state_transport" or fdTransportTiming[2]:-diagnostics:-stepCount<=0 then error "FD state-only transport diagnostics changed"; end if:
printf("FD7 state build cold=%.6f warm=%.6f seed cold=%.6f warm=%.6f transport cold=%.6f warm=%.6f steps=%d\n",fdBuildCold[1],fdBuildTiming[1],fdSeedCold[1],fdSeedTiming[1],fdTransportCold[1],fdTransportTiming[1],fdTransportTiming[2]:-diagnostics:-stepCount):

printf("Production dispatch benchmark completed.\n"):
quit:
