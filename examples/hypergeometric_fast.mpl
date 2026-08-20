restart:
read "../HyperPrecision.mpl":
with(HyperPrecision):

pfqReport := HypergeometricPFQ([1/7,2/7,3/7],[5/6,7/8],.45,'digits'=30,'returnDiagnostics'=true):
printf("3F2 value = %a, method = %s, status = %s, working digits = %d\n",pfqReport:-value,pfqReport:-methodUsed,pfqReport:-errorStatus,pfqReport:-workingDigits):

f2Vector := AppellF2(1/4,1/3,1/5,7/6,8/7,1/20,1/30,'digits'=30,'returnDerivatives'=true):
printf("Appell F2 [F,dF/dx,dF/dy] = %a\n",convert(f2Vector,list)):

f2BoundaryReport := AppellF2(1/4,1/3,1/5,7/6,8/7,1/2,9/20,'digits'=30,'returnDiagnostics'=true):
printf("Appell F2 q=0.95 value = %a, method = %s, branch = %s\n",f2BoundaryReport:-value,f2BoundaryReport:-methodUsed,f2BoundaryReport:-branchProvenance):

g1Report := HornG1(2/7,3/8,5/9,1/50,3/200,'digits'=28,'returnDiagnostics'=true):
printf("Horn G1 value = %a, method = %s, certificate = %s\n",g1Report:-value,g1Report:-methodUsed,g1Report:-convergenceTest):

fa7Report := LauricellaFA(1/4,[1/5$7],[6/5$7],[1/50,1/60,1/70,1/80,1/90,1/100,1/110],'digits'=20,'returnDiagnostics'=true):
printf("Lauricella FA7 value = %a, method = %s, degree = %a\n",fa7Report:-value,fa7Report:-methodUsed,fa7Report:-degree):

printf("Fast hypergeometric example completed.\n"):
quit:
