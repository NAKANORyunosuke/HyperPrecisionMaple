restart:
read "../HyperPrecision.mpl":
with(HyperPrecision):

b2 := EpsilonParameter(1, 1):
c2 := EpsilonParameter(-1, -1):

paperExpansion := AppellF2(
    2, 3/2, b2, 4, c2, 3, 11/3,
    'epsilonOrder' = 1,
    'digits' = 10,
    'branchSide' = -1,
    'verbose' = true
):

printf("epsilon^(-1): %a\n", LaurentCoefficient(paperExpansion, -1)):
printf("epsilon^(0):  %a\n", LaurentCoefficient(paperExpansion, 0)):
printf("epsilon^(1):  %a\n", LaurentCoefficient(paperExpansion, 1)):
printf("estimated interpolation error: %a\n", paperExpansion:-estimatedError):
