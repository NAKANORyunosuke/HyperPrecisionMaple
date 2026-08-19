restart:
read "../HyperPrecision.mpl":
with(HyperPrecision):

b7 := [1/4$7]:
x7 := [1/2,1/3,1/4,1/5,1/6,1/7,1/8]:
referenceValue := evalf[40](1.1420121941001597687800075211173977305285559453994):
benchmarkDigits := 15:
benchmarkOrder := 48:

MedianTime := proc(samples::list) local ordered; ordered := sort(samples); return ordered[iquo(nops(ordered)+1,2)]; end proc:
TimeEvaluation := proc(selectedMethod,repetitions) global benchmarkDigits,benchmarkOrder; local samples,result,startTime,i,oldCacheClearLimit; samples := []; result := NULL; oldCacheClearLimit := kernelopts(cacheclearlimit); kernelopts(cacheclearlimit=1); try for i to repetitions do gc(); startTime := time[real](); result := LauricellaFD(1/4,b7,1,x7,'digits'=benchmarkDigits,'method'=selectedMethod,'frobeniusOrder'=benchmarkOrder,'returnDiagnostics'=true); samples := [op(samples),evalf(time[real]()-startTime)]; end do; finally kernelopts(cacheclearlimit=oldCacheClearLimit); end try; return [MedianTime(samples),result,samples]; end proc:

# Warm every applicable method before collecting comparable timings.
LauricellaFD(1/4,b7,1,x7,'digits'=benchmarkDigits,'method'="series"):
LauricellaFD(1/4,b7,1,x7,'digits'=benchmarkDigits,'method'="euler"):
LauricellaFD(1/4,b7,1,x7,'digits'=benchmarkDigits,'method'="pfaffian",'frobeniusOrder'=benchmarkOrder):
LauricellaFD(1/4,b7,1,x7,'digits'=benchmarkDigits,'method'="auto"):

seriesTiming := TimeEvaluation("series",5):
eulerTiming := TimeEvaluation("euler",3):
autoTiming := TimeEvaluation("auto",5):
pfaffianTiming := TimeEvaluation("pfaffian",3):

fastestOrdinary := min(seriesTiming[1],eulerTiming[1],pfaffianTiming[1]):
autoError := evalf[30](abs(autoTiming[2]:-value-referenceValue)):
pfaffianError := evalf[30](abs(pfaffianTiming[2]:-value-referenceValue)):
oldDegree40Terms := binomial(40+7,7):
groupedDegree100Units := 2*(100*7+100*101/2):

printf("FD7 old degree-40 multi-index terms = %d\n",oldDegree40Terms):
printf("FD7 grouped degree-100 recurrence units = %d\n",groupedDegree100Units):
printf("FD7 series median = %.6f s, samples=%a\n",seriesTiming[1],seriesTiming[3]):
printf("FD7 Euler median = %.6f s, samples=%a\n",eulerTiming[1],eulerTiming[3]):
printf("FD7 auto median = %.6f s, samples=%a, method=%s\n",autoTiming[1],autoTiming[3],autoTiming[2]:-methodUsed):
printf("FD7 Pfaffian median = %.6f s, samples=%a, factors=%d\n",pfaffianTiming[1],pfaffianTiming[3],pfaffianTiming[2]:-transportFactors):
printf("FD7 auto error = %a, Pfaffian error = %a\n",autoError,pfaffianError):

# Identical numerical Int calls can hit Maple's whole-result cache.  The timing
# helper temporarily lowers cacheclearlimit and collects after every sample, so
# each result is genuinely recomputed while the loaded code remains warm.  Auto
# is compared with the fastest measured applicable forced method, including an
# uncached Euler evaluation.
if autoTiming[2]:-methodUsed <> "series" or autoTiming[1] > 5 or autoTiming[1] > 1.25*fastestOrdinary+.05 or autoError > 1.e-14 or pfaffianError > 1.e-12 then error "Lauricella FD benchmark gate failed"; end if:
printf("Lauricella FD benchmark completed.\n"):
quit:
