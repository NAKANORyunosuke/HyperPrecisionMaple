restart:
read "../HyperPrecision.mpl":
with(HyperPrecision):

paperSeries := FunctionSeries("AppellF2", [
    2, 3/2, EpsilonParameter(1,1), 4, EpsilonParameter(-1,-1)
], 2):

paperExpansion := HypExpand(paperSeries, [3,11/3], 1, 8,
    'branchSide'=-1, 'interpolationGuard'=2,
    'frobeniusOrder'=80, 'verbose'=true):

expectedPole := .5149686376:
expectedFinite := .528662817-4.194390019*I:
expectedLinear := -10.978138236-4.834942296*I:

poleError := evalf(abs(LaurentCoefficient(paperExpansion,-1)-expectedPole)):
finiteError := evalf(abs(LaurentCoefficient(paperExpansion,0)-expectedFinite)):
linearError := evalf(abs(LaurentCoefficient(paperExpansion,1)-expectedLinear)):

printf("computed: %a\n", LaurentPolynomial(paperExpansion,epsilon)):
printf("errors: pole=%a finite=%a linear=%a\n",
    poleError, finiteError, linearError):

if max(poleError,finiteError,linearError) <= 5.e-9 then
    printf("Paper example passed.\n"):
else
    printf("Paper example failed.\n"):
    error "paper example failed":
end if:
quit:
