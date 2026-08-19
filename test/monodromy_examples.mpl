restart:
read "../HyperPrecision.mpl":
with(HyperPrecision):

failures := 0:

CheckClose := proc(label, actual, expectedValue, tolerance)
    global failures;
    local residual;
    residual := evalf(abs(actual-expectedValue));
    if residual <= tolerance then
        printf("PASS %s: residual=%a\n",label,residual);
    else
        failures := failures+1;
        printf("FAIL %s: residual=%a actual=%a expected=%a\n",
            label,residual,actual,expectedValue);
    end if;
end proc:

CheckTrue := proc(label, condition)
    global failures;
    if condition then
        printf("PASS %s\n",label);
    else
        failures := failures+1;
        printf("FAIL %s\n",label);
    end if;
end proc:

# Around x=1, the Gauss exponents are 0 and c-a-b=-1/12.  Hence the
# monodromy invariants are det(M)=exp(-Pi*I/6) and tr(M)=1+det(M).
phase := evalf[30](exp(-Pi*I/6)):
gaussSystem := FindPfaffianSystem(FunctionSeries("Hypergeometric2F1",
    [1/3,1/4,1/2],1),'digits'=14):
gaussGenerators := MeridianGenerators(gaussSystem,[1/5],
    'components'=[1],'digits'=10,'vertices'=8,'radius'=1/10):
started := time():
gaussRepresentation := Monodromy(gaussSystem,gaussGenerators,
    'digits'=6,'taylorOrder'=16,'verificationOrder'=2,
    'safetyFactor'=.75,'verifyReverse'=false,
    'maximumPrecisionEscalations'=0):
gaussMatrix := MonodromyMatrix(gaussRepresentation,"D1"):
printf("Gauss monodromy time=%a seconds, factors=%d\n",time()-started,
    nops(gaussRepresentation:-generators:-transports["D1"]:-factors)):
CheckClose("Gauss x=1 determinant",
    LinearAlgebra:-Determinant(gaussMatrix),phase,1.e-9):
CheckClose("Gauss x=1 trace",
    LinearAlgebra:-Trace(gaussMatrix),1+phase,1.e-9):
CheckTrue("Gauss monodromy is nontrivial",
    LinearAlgebra:-MatrixNorm(gaussMatrix-
        LinearAlgebra:-IdentityMatrix(2),infinity)>.1):

# On the transverse slice y=1/10, Appell F3 has the x=1 exponent
# c-a1-b1=-1/12.  In rank four the other three eigenvalues are 1, so the
# expected determinant and trace are phase and 3+phase.
f3System := FindPfaffianSystem(FunctionSeries("AppellF3",
    [1/3,2/5,1/4,1/5,1/2],2),'digits'=14):
xOneComponent := Record('point'=[1,1/10],
    'direction'=[1,0],'label'="x=1"):
f3Generators := MeridianGenerators(f3System,[1/5,1/10],
    'components'=[xOneComponent],'digits'=10,'vertices'=8,'radius'=1/10):
started := time():
f3Representation := Monodromy(f3System,f3Generators,
    'digits'=8,'taylorOrder'=24,'verificationOrder'=4,
    'safetyFactor'=.7,'verifyReverse'=false,
    'maximumPrecisionEscalations'=0):
f3Matrix := MonodromyMatrix(f3Representation,"x=1"):
printf("Appell F3 monodromy time=%a seconds, factors=%d\n",time()-started,
    nops(f3Representation:-generators:-transports["x=1"]:-factors)):
CheckClose("Appell F3 x=1 determinant",
    LinearAlgebra:-Determinant(f3Matrix),phase,1.e-9):
CheckClose("Appell F3 x=1 trace",
    LinearAlgebra:-Trace(f3Matrix),3+phase,1.e-9):
CheckTrue("Appell F3 monodromy is nontrivial",
    LinearAlgebra:-MatrixNorm(f3Matrix-
        LinearAlgebra:-IdentityMatrix(4),infinity)>.1):
f3Identity := LinearAlgebra:-IdentityMatrix(4):
f3ReflectionResidual := LinearAlgebra:-MatrixNorm(
    (f3Matrix-f3Identity).(f3Matrix-phase*f3Identity),infinity):
CheckClose("Appell F3 reflection characteristic relation",
    f3ReflectionResidual,0,1.e-8):

if failures=0 then
    printf("All known monodromy examples passed.\n"):
else
    error "%1 known monodromy example(s) failed",failures:
end if:
quit:
