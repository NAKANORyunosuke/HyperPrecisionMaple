restart:
read "../HyperPrecision.mpl":
with(HyperPrecision):

failures := 0:

CheckClose := proc(label, actual, expectedValue, tolerance)
    global failures;
    local err;
    err := evalf(abs(actual-expectedValue));
    if err > tolerance then
        failures := failures+1;
        printf("FAIL %s: error=%a actual=%a expected=%a\n",
            label, err, actual, expectedValue);
    else
        printf("PASS %s: error=%a\n", label, err);
    end if;
end proc:

CheckTrue := proc(label, condition)
    global failures;
    if condition then
        printf("PASS %s\n", label);
    else
        failures := failures+1;
        printf("FAIL %s\n", label);
    end if;
end proc:

# Gauss 2F1 inside and outside its defining disk.
gaussSeries := FunctionSeries("Hypergeometric2F1", [1,1,2], 1):
gaussInside := Evaluate(gaussSeries, [1/2], 'digits'=25):
CheckClose("Gauss series", gaussInside, evalf[30](2*log(2)), 1.e-23):

gaussOutside := Evaluate(gaussSeries, [-2], 'digits'=25):
CheckClose("Gauss transport", gaussOutside, evalf[30](log(3)/2), 1.e-23):

# The Appell F2 system has the rank and integrability stated in Section 2.3.
f2Series := FunctionSeries("AppellF2", [2,3/2,5/4,4,7/3], 2):
f2Orders := FindHypergeometricOrder(f2Series, 'digits'=25):
CheckTrue("Appell F2 orders", evalb(f2Orders=[2,2])):
f2Rank := FindHolonomicRank(f2Series, 'digits'=25):
CheckTrue("Appell F2 rank", evalb(f2Rank[1]=4)):
f2System := FindPfaffianSystem(f2Series, 'digits'=25):
f2Check := CheckIntegrability(f2System):
CheckTrue("Appell F2 integrability", f2Check:-passed):

# Lauricella FD in two variables is Appell F1.
appellValue := AppellF1(1/2,2/3,3/4,5/2,1/10,1/5,'digits'=25):
lauricellaValue := LauricellaFD(1/2,[2/3,3/4],5/2,[1/10,1/5],
    'digits'=25):
CheckClose("Appell F1 = Lauricella FD", appellValue, lauricellaValue, 1.e-23):

# 2F1(epsilon,1;1;z)=(1-z)^(-epsilon).
epsilonSeries := FunctionSeries("Hypergeometric2F1",
    [EpsilonParameter(0,1),1,1],1):
epsilonExpansion := HypExpand(epsilonSeries,[1/3],2,18,
    'interpolationGuard'=2):
logTerm := evalf[30](-log(2/3)):
CheckClose("epsilon coefficient 0", LaurentCoefficient(epsilonExpansion,0), 1, 1.e-16):
CheckClose("epsilon coefficient 1", LaurentCoefficient(epsilonExpansion,1), logTerm, 1.e-16):
CheckClose("epsilon coefficient 2", LaurentCoefficient(epsilonExpansion,2),
    logTerm^2/2, 1.e-16):

# The held-call wrapper accepts an affine expression in the named epsilon.
heldExpansion := HypFunctionExpand(
    'Hypergeometric2F1'(epsilon,1,1,1/3), epsilon, 1, 14,
    'interpolationGuard'=2
):
CheckClose("held-call epsilon coefficient", LaurentCoefficient(heldExpansion,1),
    logTerm, 1.e-12):

if failures = 0 then
    printf("All regular tests passed.\n"):
else
    printf("%d test(s) failed.\n", failures):
    error "%1 test(s) failed", failures:
end if:
quit:
