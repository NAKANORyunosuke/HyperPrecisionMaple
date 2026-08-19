restart:
read "../HyperPrecision.mpl":
with(HyperPrecision):

AGMReference := proc(z, digits)
    local oldDigits, aa, bb, nextA, nextB, tolerance, result;
    oldDigits := Digits;
    Digits := digits+12;
    try
        aa := 1.;
        bb := evalf(sqrt(1-z));
        tolerance := evalf(10^(-(digits+6)));
        while abs(aa-bb) > tolerance*max(abs(aa),1) do
            nextA := evalf((aa+bb)/2);
            nextB := evalf(sqrt(aa*bb));
            aa := nextA; bb := nextB;
        end do;
        result := evalf(1/aa);
    finally
        Digits := oldDigits;
    end try;
    return result;
end proc:

# This point is close enough to z=1 that the 180-shell direct-series test does
# not converge to 20 digits. The package therefore uses Pfaffian transport.
edgePoint := 1-1/10^8:
transportedValue := Hypergeometric2F1(1/2,1/2,1,edgePoint,
    'digits'=20, 'branchSide'=0, 'frobeniusOrder'=96):
agmValue := AGMReference(edgePoint,20):
agmError := evalf(abs(transportedValue-agmValue)):

printf("transported = %a\n", transportedValue):
printf("AGM reference = %a\n", agmValue):
printf("absolute error = %a\n", agmError):

if agmError <= 1.e-18 then
    printf("AGM test passed.\n"):
else
    printf("AGM test failed.\n"):
    error "AGM test failed":
end if:
quit:
