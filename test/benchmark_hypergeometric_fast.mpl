restart:
read "../HyperPrecision.mpl":
with(HyperPrecision):

MedianTime := proc(samples::list)
    local ordered;
    ordered := sort(samples);
    return ordered[iquo(nops(ordered)+1,2)];
end proc:

TimeCall := proc(callback::procedure,repetitions::posint,batchSize::posint := 1)
    local samples,result,startTime,i,j;
    samples := []; result := NULL;
    for i to repetitions do
        gc();
        startTime := time[real]();
        for j to batchSize do result := callback(); end do;
        samples := [op(samples),evalf((time[real]()-startTime)/batchSize)];
    end do;
    return [MedianTime(samples),result,samples];
end proc:

pfqSeriesCall := proc() HypergeometricPFQ([1/7,2/7,3/7],[5/6,7/8],.45,'digits'=15,'method'="series") end proc:
pfqNativeCall := proc() HypergeometricPFQ([1/7,2/7,3/7],[5/6,7/8],.45,'digits'=15,'method'="native") end proc:
pfqGenericCall := proc() HypergeometricPFQ([1/7,2/7,3/7],[5/6,7/8],.45,'digits'=15,'method'="generic") end proc:
pfqAutoCall := proc() HypergeometricPFQ([1/7,2/7,3/7],[5/6,7/8],.45,'digits'=15,'method'="auto") end proc:

f2SeriesCall := proc() AppellF2(1/4,1/3,1/5,7/6,8/7,1/20,1/30,'digits'=15,'method'="series") end proc:
f2NativeCall := proc() AppellF2(1/4,1/3,1/5,7/6,8/7,1/20,1/30,'digits'=15,'method'="native") end proc:
f2GenericCall := proc() AppellF2(1/4,1/3,1/5,7/6,8/7,1/20,1/30,'digits'=15,'method'="generic") end proc:
f2AutoCall := proc() AppellF2(1/4,1/3,1/5,7/6,8/7,1/20,1/30,'digits'=15,'method'="auto") end proc:

g1SeriesCall := proc() HornG1(2/7,3/8,5/9,1/50,3/200,'digits'=15,'method'="series") end proc:
g1GenericCall := proc() HornG1(2/7,3/8,5/9,1/50,3/200,'digits'=15,'method'="generic") end proc:
g1AutoCall := proc() HornG1(2/7,3/8,5/9,1/50,3/200,'digits'=15,'method'="auto") end proc:

fa7SeriesCall := proc() LauricellaFA(1/4,[1/5$7],[6/5$7],[1/50,1/60,1/70,1/80,1/90,1/100,1/110],'digits'=15,'method'="series") end proc:
fa7AutoCall := proc() LauricellaFA(1/4,[1/5$7],[6/5$7],[1/50,1/60,1/70,1/80,1/90,1/100,1/110],'digits'=15,'method'="auto") end proc:

# Record cold calls before warming every applicable method.
gc(): startTime := time[real](): pfqCold := pfqAutoCall(): pfqColdTime := evalf(time[real]()-startTime):
gc(): startTime := time[real](): f2Cold := f2AutoCall(): f2ColdTime := evalf(time[real]()-startTime):
gc(): startTime := time[real](): g1Cold := g1AutoCall(): g1ColdTime := evalf(time[real]()-startTime):
gc(): startTime := time[real](): fa7Cold := fa7AutoCall(): fa7ColdTime := evalf(time[real]()-startTime):

pfqSeriesCall(): pfqNativeCall(): pfqGenericCall(): pfqAutoCall():
f2SeriesCall(): f2NativeCall(): f2GenericCall(): f2AutoCall():
g1SeriesCall(): g1GenericCall(): g1AutoCall():
fa7SeriesCall(): fa7AutoCall():

pfqSeriesTiming := TimeCall(pfqSeriesCall,5,20):
pfqNativeTiming := TimeCall(pfqNativeCall,5,20):
pfqGenericTiming := TimeCall(pfqGenericCall,5):
pfqAutoTiming := TimeCall(pfqAutoCall,5,20):
f2SeriesTiming := TimeCall(f2SeriesCall,5,10):
f2NativeTiming := TimeCall(f2NativeCall,5,10):
f2GenericTiming := TimeCall(f2GenericCall,5,10):
f2AutoTiming := TimeCall(f2AutoCall,5,10):
g1SeriesTiming := TimeCall(g1SeriesCall,5,3):
g1GenericTiming := TimeCall(g1GenericCall,5,3):
g1AutoTiming := TimeCall(g1AutoCall,5,3):
fa7SeriesTiming := TimeCall(fa7SeriesCall,5,2):
fa7AutoTiming := TimeCall(fa7AutoCall,5,2):

pfqReport := HypergeometricPFQ([1/7,2/7,3/7],[5/6,7/8],.45,'digits'=15,'returnDiagnostics'=true):
f2Report := AppellF2(1/4,1/3,1/5,7/6,8/7,1/20,1/30,'digits'=15,'returnDiagnostics'=true):
g1Report := HornG1(2/7,3/8,5/9,1/50,3/200,'digits'=15,'returnDiagnostics'=true):
g1ForcedReport := HornG1(2/7,3/8,5/9,1/50,3/200,'digits'=15,'method'="series",'returnDiagnostics'=true):
fa7Report := LauricellaFA(1/4,[1/5$7],[6/5$7],[1/50,1/60,1/70,1/80,1/90,1/100,1/110],'digits'=15,'returnDiagnostics'=true):

printf("pFq cold auto = %.6f s\n",pfqColdTime):
printf("pFq warm medians: series=%.6f native=%.6f generic=%.6f auto=%.6f; samples=%a\n",pfqSeriesTiming[1],pfqNativeTiming[1],pfqGenericTiming[1],pfqAutoTiming[1],pfqAutoTiming[3]):
printf("Appell F2 cold auto = %.6f s\n",f2ColdTime):
printf("Appell F2 warm medians: convolution=%.6f native=%.6f generic=%.6f auto=%.6f; samples=%a\n",f2SeriesTiming[1],f2NativeTiming[1],f2GenericTiming[1],f2AutoTiming[1],f2AutoTiming[3]):
printf("Horn G1 cold auto = %.6f s\n",g1ColdTime):
printf("Horn G1 warm medians: neighbor=%.6f generic=%.6f auto=%.6f; samples=%a\n",g1SeriesTiming[1],g1GenericTiming[1],g1AutoTiming[1],g1AutoTiming[3]):
printf("Lauricella FA7 cold auto = %.6f s\n",fa7ColdTime):
printf("Lauricella FA7 warm medians: convolution=%.6f auto=%.6f; samples=%a\n",fa7SeriesTiming[1],fa7AutoTiming[1],fa7AutoTiming[3]):
printf("dispatches: pFq=%s F2=%s G1=%s FA7=%s\n",pfqReport:-methodUsed,f2Report:-methodUsed,g1Report:-methodUsed,fa7Report:-methodUsed):

timingFloor := .01:
if pfqAutoTiming[1]>1.25*min(pfqSeriesTiming[1],pfqNativeTiming[1],pfqGenericTiming[1])+timingFloor then error "pFq automatic dispatch benchmark gate failed"; end if:
if f2AutoTiming[1]>1.25*min(f2SeriesTiming[1],f2NativeTiming[1],f2GenericTiming[1])+timingFloor then error "Appell F2 automatic dispatch benchmark gate failed"; end if:
if g1AutoTiming[1]>1.25*min(g1SeriesTiming[1],g1GenericTiming[1])+timingFloor then error "Horn G1 automatic dispatch benchmark gate failed"; end if:
if fa7AutoTiming[1]>1.25*fa7SeriesTiming[1]+timingFloor then error "Lauricella FA7 automatic dispatch benchmark gate failed"; end if:
if abs(pfqAutoTiming[2]-pfqGenericTiming[2])>1.e-14 or abs(f2AutoTiming[2]-f2GenericTiming[2])>1.e-14 or abs(g1AutoTiming[2]-g1GenericTiming[2])>1.e-14 or abs(fa7AutoTiming[2]-fa7SeriesTiming[2])>1.e-14 then error "fast hypergeometric benchmark value parity failed"; end if:
if pfqReport:-methodUsed<>"native" or f2Report:-methodUsed<>"native" or g1Report:-methodUsed<>"pfaffian" or g1ForcedReport:-methodUsed<>"neighbor_series" or fa7Report:-methodUsed<>"convolution" then error "fast hypergeometric benchmark dispatch check failed"; end if:

printf("Fast hypergeometric benchmark completed.\n"):
quit:
