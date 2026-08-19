restart:
read "../HyperPrecision.mpl":
with(HyperPrecision):

failures := 0:

CheckTrue := proc(label, condition)
    global failures;
    if condition then
        printf("PASS %s\n", label);
    else
        failures := failures + 1;
        printf("FAIL %s\n", label);
    end if;
end proc:

CheckSmall := proc(label, actual, tolerance)
    global failures;
    if evalf(abs(actual)) <= tolerance then
        printf("PASS %s: residual=%a\n", label, actual);
    else
        failures := failures + 1;
        printf("FAIL %s: residual=%a tolerance=%a\n",
            label, actual, tolerance);
    end if;
end proc:

# The algebraic frontend must close the full connection for all systems in
# the first research-usable milestone.
f1System := FindPfaffianSystem(FunctionSeries("AppellF1",
    [1/3,1/4,1/5,7/6],2), 'digits'=14):
f2System := FindPfaffianSystem(FunctionSeries("AppellF2",
    [1/3,1/4,1/5,7/6,8/7],2), 'digits'=14):
f3System := FindPfaffianSystem(FunctionSeries("AppellF3",
    [1/3,2/5,1/4,1/5,1/2],2), 'digits'=14):
fd3System := FindPfaffianSystem(FunctionSeries("LauricellaFD",
    [1/3,1/4,1/5,2/7,7/6],3), 'digits'=14):

CheckTrue("Appell F1 full rank", nops(f1System:-basis)=3):
CheckTrue("Appell F2 full rank", nops(f2System:-basis)=4):
CheckTrue("Appell F3 full rank", nops(f3System:-basis)=4):
CheckTrue("Lauricella FD3 full rank", nops(fd3System:-basis)=4):
CheckTrue("Appell F1 full connection dimensions",
    nops(ConnectionMatrices(f1System,[1/7,1/9]))=2):
CheckTrue("Lauricella FD3 full connection dimensions",
    nops(ConnectionMatrices(fd3System,[1/11,1/13,1/17]))=3):

# For the Gauss equation the selected Macaulay pivot determinant has the
# singular support x^2(x-1).  Restricted roots are expressed in segment t.
gaussSystem := FindPfaffianSystem(FunctionSeries("Hypergeometric2F1",
    [1/3,1/4,1/2],1), 'digits'=16):
automaticBasepoint := ChooseBasepoint(gaussSystem,'digits'=12):
automaticInitialVector := InitialVector(gaussSystem,automaticBasepoint,
    'digits'=12):
CheckTrue("automatic regular basepoint and initial vector",
    nops(automaticBasepoint)=1 and
    LinearAlgebra:-Dimension(automaticInitialVector)=2):
gaussDivisor := SingularFactors(gaussSystem):
CheckTrue("Gauss singular factors extracted",
    nops(gaussDivisor:-factors)=2):
gaussRoots := RestrictedSingularRoots(gaussSystem,[1/5],[6/5],
    'digits'=16):
CheckTrue("Gauss restricted roots contain x=0",
    min(seq(abs(r+1/5),r in gaussRoots)) < 1.e-12):
CheckTrue("Gauss restricted roots contain x=1",
    min(seq(abs(r-4/5),r in gaussRoots)) < 1.e-12):

# Restricted-root and direct user evaluation logic must retain finite complex
# values.  Maple classifies nonreal floats as complex(numeric), not numeric.
imaginaryPoleSystem := UserPfaffianSystem(
    [Matrix([[1/(userX^2+1)]])],[userX],'digits'=16):
imaginaryRoots := RestrictedSingularRoots(imaginaryPoleSystem,[0],[1],
    'digits'=16):
CheckTrue("finite nonreal restricted roots are retained",
    nops(imaginaryRoots)=2):
if nops(imaginaryRoots)=2 then
    CheckSmall("restricted root +I",
        min(seq(abs(r-I),r in imaginaryRoots)),1.e-12):
    CheckSmall("restricted root -I",
        min(seq(abs(r+I),r in imaginaryRoots)),1.e-12):
end if:
complexCoefficientSystem := UserPfaffianSystem(
    [Matrix([[1/((1+I)*(userX-1/2))]])],[userX],'digits'=16):
complexCrossingRejected := false:
try PlanPath(complexCoefficientSystem,[0],[1],
    'mode'="user",'digits'=12):
catch: complexCrossingRejected := true: end try:
CheckTrue("complex-coefficient real crossing rejected",
    complexCrossingRejected):
complexEvaluationSystem := UserPfaffianSystem(
    [Matrix([[1/(userX-2)]])],[userX],'digits'=16):
complexConnection := ConnectionMatrices(complexEvaluationSystem,[I/2]):
CheckSmall("complex user connection evaluation",
    complexConnection[1][1,1]-1/(I/2-2),1.e-14):

# Sparse Taylor recurrences have interleaved zero coefficients.  Tail
# monotonicity therefore compares the nonzero envelope rather than the first
# and last raw slots of a fixed window.
sparsePositiveSystem := UserPfaffianSystem(
    [Matrix([[userX]])],[userX],'digits'=16):
sparsePositiveTransport := TransportFundamental(sparsePositiveSystem,
    [[0],[1/5]],'digits'=12,'taylorOrder'=24,
    'verificationOrder'=4,'verifyReverse'=true):
CheckSmall("sparse even Taylor transport exp(x^2/2)",
    MaterializeTransport(sparsePositiveTransport)[1,1]-
        evalf[30](exp(1/50)),1.e-13):
sparseAlternatingSystem := UserPfaffianSystem(
    [Matrix([[-userX]])],[userX],'digits'=16):
sparseAlternatingTransport := TransportFundamental(sparseAlternatingSystem,
    [[0],[1/5]],'digits'=12,'taylorOrder'=24,
    'verificationOrder'=4,'verifyReverse'=true):
CheckSmall("alternating sparse Taylor transport exp(-x^2/2)",
    MaterializeTransport(sparseAlternatingTransport)[1,1]-
        evalf[30](exp(-1/50)),1.e-13):

# The requested branch side is provenance.  If its deterministic candidate
# collides with another divisor, canonical planning fails instead of silently
# returning the opposite-side homotopy class.
branchProvenanceSystem := UserPfaffianSystem(
    [Matrix([[0]])],[userX],'digits'=16,
    'singularFactors'=[userX,userX+2*I]):
negativeBranchRejected := false:
try PlanPath(branchProvenanceSystem,[-1],[1],
    'mode'="canonical",'branchSide'=-1,'digits'=12):
catch: negativeBranchRejected := true: end try:
CheckTrue("canonical planner does not switch branchSide",
    negativeBranchRejected):
positiveBranchPlan := PlanPath(branchProvenanceSystem,[-1],[1],
    'mode'="canonical",'branchSide'=1,'digits'=12):
CheckTrue("opposite branch requires explicit selection",
    Im(positiveBranchPlan:-points[2][1])>0):

# A deliberately over-segmented representative is shortened only after the
# sampled homotopy strip and all replacement segments pass the divisor test.
redundantWaypoints := [[.3],[.4],[.5]]:
canonicalPlan := PlanPath(gaussSystem,[.2],[.6],
    'mode'="canonical",'waypoints'=redundantWaypoints,'digits'=12):
safePlan := PlanPath(gaussSystem,[.2],[.6],
    'mode'="safe_opt",'waypoints'=redundantWaypoints,'digits'=12):
fastPlan := PlanPath(gaussSystem,[.2],[.6],
    'mode'="fast_opt",'waypoints'=redundantWaypoints,'digits'=12):
CheckTrue("safe_opt preserves the canonical representative",
    safePlan:-points=canonicalPlan:-points and
    safePlan:-diagnostics:-homotopyVerification=
        "not_certified_no_change"):
CheckTrue("fast_opt preserves endpoints",
    fastPlan:-points[1]=canonicalPlan:-points[1] and
    fastPlan:-points[-1]=canonicalPlan:-points[-1]):
CheckTrue("fast_opt removes sampled redundant segments",
    nops(fastPlan:-points) < nops(canonicalPlan:-points) and
    fastPlan:-diagnostics:-shortcutsAccepted=3 and
    fastPlan:-diagnostics:-homotopyVerification="sampled_unverified"):

canonicalTransport := TransportFundamental(gaussSystem,canonicalPlan,
    'digits'=10,'taylorOrder'=24,'verificationOrder'=4,
    'verifyReverse'=false):
fastTransport := TransportFundamental(gaussSystem,fastPlan,
    'digits'=10,'taylorOrder'=24,'verificationOrder'=4,
    'verifyReverse'=true,'maximumPrecisionEscalations'=1):
CheckTrue("fast_opt reduces measured Taylor patches",
    nops(fastTransport:-history) < nops(canonicalTransport:-history)):
CheckSmall("independent reverse-path consistency",
    fastTransport:-diagnostics:-reverseError,1.e-12):
CheckTrue("transport history is retained",
    nops(fastTransport:-history)=nops(fastTransport:-factors) and
    fastTransport:-history[1]:-order=28):
CheckTrue("differential residual is retained and bounded",
    fastTransport:-diagnostics:-maxDifferentialResidual < 1.e-7 and
    max(seq(entry:-differentialResidual,
        entry in fastTransport:-history)) =
        fastTransport:-diagnostics:-maxDifferentialResidual):

materialized := MaterializeTransport(fastTransport):
initialVector := Vector([1.,-2.]):
applied := ApplyTransport(fastTransport,initialVector):
CheckSmall("factorwise Apply equals dense materialization",
    LinearAlgebra:-Norm(applied-materialized.initialVector,infinity),1.e-12):
CheckSmall("record Apply closure",
    LinearAlgebra:-Norm(fastTransport:-Apply(initialVector)-applied,
        infinity),1.e-12):
inverseDense := MaterializeTransport(InverseTransport(fastTransport)):
CheckSmall("algebraic inverse transport",
    LinearAlgebra:-MatrixNorm(inverseDense.materialized-
        LinearAlgebra:-IdentityMatrix(2),infinity),1.e-12):
methodInverse := fastTransport:-Inverse():
CheckSmall("record Inverse closure",
    LinearAlgebra:-MatrixNorm(methodInverse:-Materialize()-
        inverseDense,infinity),1.e-12):
CheckTrue("inverse history is reversed algebraically",
    nops(methodInverse:-history)=nops(fastTransport:-history) and
    methodInverse:-diagnostics:-historySemantics=
        "reversed algebraic factor history" and
    methodInverse:-history[1]:-segment=
        nops(fastTransport:-path)-fastTransport:-history[-1]:-segment):
CheckSmall("inverse history reverses patch parameters",
    methodInverse:-history[1]:-segmentParameterStart-
        (1-fastTransport:-history[-1]:-segmentParameterEnd),1.e-14):

# Complex user targets and an automatically constructed multivariate
# meridian are API smoke tests; monodromy invariants are in the extended test.
complexPlan := PlanPath(f1System,[.1,.08],[.2+.07*I,.15-.03*I],
    'mode'="user",'waypoints'=[[.14+.02*I,.1]],'digits'=12):
CheckTrue("complex user path", nops(complexPlan:-points)=3):
complexTransport := TransportFundamental(f1System,complexPlan,
    'digits'=8,'taylorOrder'=22,'verificationOrder'=4,
    'verifyReverse'=true,'maximumPrecisionEscalations'=1):
CheckSmall("complex user-path transport",
    complexTransport:-diagnostics:-reverseError,1.e-10):
canonicalComplexPlan := PlanPath(f1System,[.1,.08],
    [.2+.07*I,.15-.03*I],'mode'="canonical",'digits'=12):
CheckTrue("complex canonical path",
    canonicalComplexPlan:-points[1]=[.1,.08] and
    canonicalComplexPlan:-points[-1]=[.2+.07*I,.15-.03*I]):
autoMeridians := MeridianGenerators(f3System,[1/5,1/10],
    'components'="all",'planner'="canonical",'digits'=10,
    'vertices'=8,'maximumGenerators'=1):
CheckTrue("automatic multivariate meridian",
    nops(autoMeridians:-loops)=1 and
    autoMeridians:-loops[1][1]=autoMeridians:-loops[1][-1] and
    autoMeridians:-generatorSetComplete="unknown"):

# Monodromy is defined only for closed loops with one common basepoint.
emptyRejected := false:
try Monodromy(gaussSystem,[]): catch: emptyRejected := true: end try:
CheckTrue("empty monodromy generator list rejected",emptyRejected):
openRejected := false:
try Monodromy(gaussSystem,[[[.2],[.3]]]):
catch: openRejected := true: end try:
CheckTrue("open monodromy path rejected",openRejected):
mixedBaseRejected := false:
try Monodromy(gaussSystem,
    [[[.2],[.25],[.2]],[[.3],[.35],[.3]]]):
catch: mixedBaseRejected := true: end try:
CheckTrue("mixed loop basepoints rejected",mixedBaseRejected):
duplicateGeneratorSet := Record(
    'hpType'="MeridianGeneratorSet",'basepoint'=[.2],
    'labels'=["same","same"],
    'loops'=[[[.2],[.25],[.2]],[[.2],[.3],[.2]]],
    'metadata'=[], 'generatorSetComplete'="unknown"):
duplicateLabelsRejected := false:
try Monodromy(gaussSystem,duplicateGeneratorSet,'digits'=8):
catch: duplicateLabelsRejected := true: end try:
CheckTrue("duplicate monodromy labels rejected",duplicateLabelsRejected):
edgeCrossingRejected := false:
try PlanPath(gaussSystem,[.8],[1.2],'mode'="user",
    'digits'=12):
catch: edgeCrossingRejected := true: end try:
CheckTrue("edge-interior divisor crossing rejected",edgeCrossingRejected):

# Directly supplied rational Pfaffian connections use the same transport and
# monodromy backend.  Flatness is mandatory before a representation is made.
flatUserSystem := UserPfaffianSystem(
    [Matrix([[userY]]),Matrix([[userX]])],[userX,userY],
    'digits'=16):
flatUserLoop := [[.1,.2],[.2,.2],[.2,.3],[.1,.3],[.1,.2]]:
flatUserRepresentation := Monodromy(flatUserSystem,[flatUserLoop],
    'digits'=10,'taylorOrder'=16,'verificationOrder'=3,
    'verifyReverse'=true):
CheckSmall("flat rank-one user Pfaffian monodromy",
    MonodromyMatrix(flatUserRepresentation,"D1")[1,1]-1,1.e-12):
nonflatUserSystem := UserPfaffianSystem(
    [Matrix([[0,userY],[0,0]]),Matrix(2,2,0)],
    [userX,userY],'digits'=16):
CheckTrue("nonflat user Pfaffian detected",
    not CheckIntegrability(nonflatUserSystem,'point'=[.1,.2]):-passed):
nonflatRejected := false:
try Monodromy(nonflatUserSystem,[flatUserLoop],'digits'=8):
catch: nonflatRejected := true: end try:
CheckTrue("nonflat user Pfaffian monodromy rejected",nonflatRejected):

# Exact symbolic curvature is required.  At the chosen basepoint the
# derivative of (y-1/5)^2 vanishes, so a one-point numerical check alone is
# insufficient, while the exact curvature polynomial is nonzero.
hiddenCurvatureSystem := UserPfaffianSystem(
    [Matrix([[(userY-1/5)^2]]),Matrix([[0]])],
    [userX,userY],'digits'=16):
CheckTrue("exact symbolic curvature detects a pointwise false positive",
    hiddenCurvatureSystem:-exactFlatness:-status="failed_exact" and
    nops(hiddenCurvatureSystem:-exactFlatness:-nonzeroCurvatures)>0):
hiddenCurvatureRejected := false:
try Monodromy(hiddenCurvatureSystem,[flatUserLoop],'digits'=8):
catch: hiddenCurvatureRejected := true: end try:
CheckTrue("pointwise-flat user connection rejected",hiddenCurvatureRejected):

inexactFlatSystem := UserPfaffianSystem(
    [Matrix([[0.1]]),Matrix([[0.]])],[userX,userY],'digits'=16):
CheckTrue("inexact user flatness is explicitly unknown",
    inexactFlatSystem:-exactFlatness:-status="unknown_inexact"):
inexactMonodromyRejected := false:
try Monodromy(inexactFlatSystem,[flatUserLoop],'digits'=8):
catch: inexactMonodromyRejected := true: end try:
CheckTrue("inexact user representation rejected",inexactMonodromyRejected):

# Requested meridian centres and disks are validated against every detected
# restricted root, not just against the requested component list.
twoPoleSystem := UserPfaffianSystem(
    [Matrix([[1/userX+1/(userX-1)]])],[userX],'digits'=16):
foreignPoleRadiusRejected := false:
try MeridianGenerators(twoPoleSystem,[3],'components'=[0],
    'radius'=3/2,'vertices'=8,'digits'=12):
catch: foreignPoleRadiusRejected := true: end try:
CheckTrue("univariate disk containing a foreign pole rejected",
    foreignPoleRadiusRejected):
regularPointRejected := false:
try MeridianGenerators(twoPoleSystem,[3],'components'=[2],
    'radius'=1/10,'vertices'=8,'digits'=12):
catch: regularPointRejected := true: end try:
CheckTrue("regular univariate component rejected",regularPointRejected):

xDivisorSystem := UserPfaffianSystem(
    [Matrix([[1/(userX-1)]]),Matrix([[0]])],
    [userX,userY],'digits'=16):
offDivisorComponent := Record('point'=[0,0],
    'direction'=[0,1],'label'="off divisor"):
offDivisorRejected := false:
try MeridianGenerators(xDivisorSystem,[3,0],
    'components'=[offDivisorComponent],'vertices'=8,'digits'=12):
catch: offDivisorRejected := true: end try:
CheckTrue("off-divisor multivariate component rejected",offDivisorRejected):
tangentComponent := Record('point'=[1,0],
    'direction'=[0,1],'label'="tangent"):
tangentRejected := false:
try MeridianGenerators(xDivisorSystem,[3,0],
    'components'=[tangentComponent],'vertices'=8,'digits'=12):
catch: tangentRejected := true: end try:
CheckTrue("tangent multivariate component rejected",tangentRejected):

twoDivisorSystem := UserPfaffianSystem(
    [Matrix([[1/(2*userX)+1/(3*(userX-1))]]),Matrix([[0]])],
    [userX,userY],'digits'=16):
zeroComponent := Record('point'=[0,0],
    'direction'=[1,0],'label'="x=0"):
foreignSlicePoleRejected := false:
try MeridianGenerators(twoDivisorSystem,[3,0],
    'components'=[zeroComponent],'radius'=3/2,
    'vertices'=8,'digits'=12):
catch: foreignSlicePoleRejected := true: end try:
CheckTrue("multivariate disk containing a foreign slice pole rejected",
    foreignSlicePoleRejected):

# A canonical detour must perturb a coordinate on which the restricted
# divisor actually varies.  Moving x cannot avoid the y=0 divisor.
yPoleSystem := UserPfaffianSystem(
    [Matrix([[0]]),Matrix([[1/userY]])],
    [userX,userY],'digits'=16):
yDetourPlan := PlanPath(yPoleSystem,[0,-1],[0,1],
    'mode'="canonical",'digits'=12):
CheckTrue("canonical detour searches all coordinates",
    nops(yDetourPlan:-points)=3 and
    abs(yDetourPlan:-points[2][2])>0 and
    yDetourPlan:-points[1]=[0.,-1.] and
    yDetourPlan:-points[-1]=[0.,1.]):

singularUserSystem := PfaffianFromConnection(
    [Matrix([[1/(2*(userX-1))]])],[userX],'digits'=16):
CheckTrue("user Pfaffian denominator factor extracted",
    nops(SingularFactors(singularUserSystem):-factors)=1):

certifiedRejected := false:
try
    TransportFundamental(gaussSystem,fastPlan,'mode'="certified"):
catch:
    certifiedRejected := true:
end try:
CheckTrue("certified mode fails explicitly",certifiedRejected):

if failures=0 then
    printf("All Pfaffian monodromy engine tests passed.\n"):
else
    error "%1 Pfaffian monodromy engine test(s) failed",failures:
end if:
quit:
