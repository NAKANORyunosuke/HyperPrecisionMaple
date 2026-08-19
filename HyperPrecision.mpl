# SPDX-FileCopyrightText: 2026 NAKANO Ryuosuke and contributors
# SPDX-License-Identifier: GPL-3.0-only

HyperPrecision := module()
option package;

export
    AffineParameter, EpsilonParameter, HornSeries,
    UserPfaffianSystem, PfaffianFromConnection,
    PDEGenerator, FindHypergeometricOrder, FindHolonomicRank,
    FindPfaffianSystem, FindRestrictedPfaffianSystem,
    ConnectionMatrices, CheckIntegrability, TransportDE,
    CheckExactFlatness,
    ChooseBasepoint, InitialVector,
    SingularFactors, RestrictedSingularRoots,
    PlanPath, ReversePath,
    FactorizedFundamentalTransport, TransportFundamental,
    ApplyTransport, MaterializeTransport, InverseTransport,
    MeridianGenerators, Monodromy,
    NumericalMonodromyRepresentation, MonodromyMatrix,
    Evaluate, HypExpand, HypFunctionExpand,
    LaurentCoefficient, LaurentPolynomial,
    HypergeometricPFQ, Hypergeometric2F1,
    AppellF1, AppellF2, AppellF3, AppellF4,
    HornG1, HornG2, HornG3,
    HornH1, HornH2, HornH3, HornH4, HornH5, HornH6, HornH7,
    LauricellaFA, LauricellaFB, LauricellaFC, LauricellaFD,
    LauricellaFDPfaffianSystem, LauricellaFDInitialVector,
    FunctionSeries;

local
    IsAffineParameter, AsAffineParameter, EvaluateParameter, HasEpsilon,
    NumericSeries, ExactParameterSeries, RestrictZeroVariables,
    ZeroIndex, UnitIndex, AddIndex, WeightDot,
    Compositions, AllMultiIndices, LexGreater,
    MultiIndexGreater, MultiIndexLess,
    PolyConstant, PolyMonomial, PolyCopy, PolyAdd, PolyScale, PolyMultiply,
    PolyDerivative, PolyEvaluate, PolyDegree, AffinePolynomial,
    OperatorAdd, OperatorScale, OperatorDerivative,
    DifferentiateOperator, OperatorOrder,
    StirlingSecond, CartesianChoices, EulerToOperator,
    MultiplyAffine, RatioPolynomials, BasePDEs,
    DifferentialClosure, EquationColumns, EquationMatrix,
    MatrixMaxAbs, VectorMaxAbs, RREF, GenericPoint,
    ExtractConnectionMatrices, DerivePfaffian, ConnectionMatricesInternal,
    RisingFactorial, FallingFactorial, SeriesCoefficient,
    SeriesVector, DirectSeriesValue, BoundarySeries,
    CancelExactSeriesParameters, NumericParameterSeries,
    ExactNonpositiveIntegerDegree, ExactTotalTerminationDegree,
    ExactFiniteSupportDegree,
    GenericPfaffianCostEstimate, EnsureGenericPfaffianSafe,
    HypergeometricRoundingAllowance, HypergeometricSeriesDegree,
    StoredNumericDigits, HypergeometricSourceDigits,
    HypergeometricConditioningGuardDigits, HypergeometricTransientDegree,
    PFQExactTerminationAndPoleCheck,
    PFQExactClosedFormVector,
    PFQFastSeriesVector, PFQFastSeriesChecked, PFQNativeValue,
    SmallIntegerPochhammer, HornCoefficientStep,
    HornFastGridVector, HornFastGridChecked,
    TruncatedConvolution, UnitCoefficientArray,
    LauricellaConvolutionRadius, LauricellaConvolutionTerminationDegree,
    LauricellaConvolutionVector, LauricellaConvolutionChecked,
    ValidateLauricellaConvolutionParameters,
    Convolve, PolynomialOnLine, EquationMatrixOnLine,
    ReductionSeries, RestrictedMatrixSeries,
    RationalTaylorSeries,
    FrobeniusSolutionCoefficients, EvaluateFrobeniusSeries,
    IntegrateSegmentFrobenius, NormaliseWaypoints,
    PolyExpression, PivotPolynomialMatrix, PivotDeterminantExpression,
    DistanceToUnitInterval, SegmentSafety, HomotopyShortcutSampled,
    FundamentalSolutionCoefficients, EvaluateFundamentalSeries,
    FundamentalDifferentialResidual,
    IntegrateSegmentFundamental, TransportFundamentalOnce,
    ApplyFactorList, MaterializeFactorList, InvertFactorList,
    InvertTransportHistory,
    MatrixIdentityResidual, MakeCanonicalPath, NormalisePathArgument,
    UnivariateMeridianLoop, MultivariateMeridianLoop, LoopSegmentsSafe,
    SystemNVariables, SystemRank, UserConnectionMatricesInternal,
    UserRestrictedMatrixSeries, ValidateMeridianComponent,
    EstimatePoleOrder, ChopValue, IsFiniteNumber,
    PredefinedSeries, UnitWeight, WeightRows,
    FinishPredefined, ConvertEpsilonExpression, ParseFunctionCall,
    LauricellaFDCompressVariables, LauricellaFDEstimatedDegree,
    LauricellaFDFastSeriesVector, LauricellaFDEulerApplicable,
    LauricellaFDEulerCostSafe, LauricellaFDEulerValue,
    LauricellaFDWorkingGuardDigits, LauricellaFDFastSeriesChecked,
    LauricellaFDSeriesTerminates, LauricellaFDTerminationDegree,
    LauricellaFDLowerParameterRegular,
    LauricellaFDClosedFormApplicable, LauricellaFDClosedFormValue,
    LauricellaFDSeriesOperationCount, LauricellaFDRoundingAllowance,
    LauricellaFDPfaffianValue;

local
    MakeAffineRecord, MakeHornRecord, MakeNumericHornRecord,
    MakeRREFRecord, MakePfaffianRecord, MakeCheckRecord,
    MakeRestrictedRecord, MakeLaurentRecord, MakeSingularRecord,
    MakePathPlanRecord, MakeFactorizedRecord, MakeLoopSetRecord,
    MakeMonodromyRecord, MakeSegmentCheckRecord,
    MakePlanDiagnosticsRecord, MakePatchHistoryRecord,
    MakeFactorDiagnosticsRecord, MakeInverseDiagnosticsRecord,
    MakePrecisionAttemptRecord, MakeTransportDiagnosticsRecord,
    MakeMeridianMetadataRecord, MakeRelationRecord,
    MakeGeneratorBundleRecord, MakeUserPfaffianRecord,
    MakeExactFlatnessRecord, MakeLauricellaFDEvaluationRecord,
    MakeHypergeometricEvaluationRecord;

MakeAffineRecord := proc(p1, p2)
    return Record('hpType' = "AffineParameter", 'constant' = p1, 'slope' = p2);
end proc;

MakeHornRecord := proc(p1, p2, p3, p4, p5, p6)
    return Record('hpType' = "HornSeries", 'name' = p1, 'nvariables' = p2,
        'upperParameters' = p3, 'upperWeights' = p4,
        'lowerParameters' = p5, 'lowerWeights' = p6);
end proc;

MakeNumericHornRecord := proc(p1, p2, p3, p4, p5, p6)
    return Record('hpType' = "NumericHornSeries", 'name' = p1, 'nvariables' = p2,
        'upperParameters' = p3, 'upperWeights' = p4,
        'lowerParameters' = p5, 'lowerWeights' = p6);
end proc;

MakeRREFRecord := proc(p1, p2, p3, p4, p5)
    return Record('reduced' = p1, 'pivotColumns' = p2, 'pivotRows' = p3,
        'freeColumns' = p4, 'threshold' = p5);
end proc;

MakePfaffianRecord := proc(p1, p2, p3, p4, p5, p6, p7, p8, p9,
                          p10 := NULL, p11 := [], p12 := 0)
    return Record('hpType' = "PfaffianSystem", 'series' = p1, 'basis' = p2,
        'equations' = p3, 'columns' = p4, 'pivotColumns' = p5,
        'freeColumns' = p6, 'equationRows' = p7, 'orders' = p8, 'digits' = p9,
        'exactSeries' = p10, 'exactEquations' = p11, 'closureSeed' = p12);
end proc;

MakeCheckRecord := proc(p1, p2, p3)
    return Record('passed' = p1, 'residual' = p2, 'tolerance' = p3);
end proc;

MakeRestrictedRecord := proc(p1, p2, p3)
    return Record('hpType' = "RestrictedPfaffianSystem", 'system' = p1,
        'target' = p2, 'waypoints' = p3);
end proc;

MakeLaurentRecord := proc(p1, p2, p3, p4)
    return Record('hpType' = "LaurentExpansion", 'firstOrder' = p1,
        'coefficients' = p2, 'estimatedError' = p3, 'digits' = p4);
end proc;

MakeSingularRecord := proc(p1, p2, p3, p4)
    return Record('hpType' = "SingularDivisor", 'variables' = p1,
        'determinant' = p2, 'factors' = p3, 'multiplicities' = p4);
end proc;

MakePathPlanRecord := proc(p1, p2, p3, p4, p5, p6)
    return Record('hpType' = "PfaffianPathPlan", 'start' = p1,
        'target' = p2, 'points' = p3, 'mode' = p4,
        'pathClass' = p5, 'diagnostics' = p6);
end proc;

MakeFactorizedRecord := proc(p1, p2, p3, p4, p5, p6,
                             p7, p8, p9)
    return Record('hpType' = "FactorizedFundamentalTransport",
        'factors' = p1, 'path' = p2, 'digits' = p3, 'mode' = p4,
        'diagnostics' = p5, 'history' = p6,
        'Apply' = p7, 'Materialize' = p8, 'Inverse' = p9);
end proc;

MakeLoopSetRecord := proc(p1, p2, p3, p4)
    return Record('hpType' = "MeridianGeneratorSet", 'basepoint' = p1,
        'labels' = p2, 'loops' = p3, 'metadata' = p4,
        'generatorSetComplete' = "unknown");
end proc;

MakeMonodromyRecord := proc(p1, p2, p3, p4, p5, p6)
    return Record('hpType' = "NumericalMonodromyRepresentation",
        'basepoint' = p1, 'basis' = p2, 'generators' = p3,
        'matrices' = p4, 'verifiedRelations' = p5,
        'generatorSetComplete' = p6);
end proc;

MakeSegmentCheckRecord := proc(p1, p2, p3)
    return Record('segment' = p1, 'minimumRestrictedRootDistance' = p2,
        'restrictedRoots' = p3);
end proc;

MakePlanDiagnosticsRecord := proc(p1, p2, p3, p4, p5)
    return Record('segmentsBefore' = p1, 'segmentsAfter' = p2,
        'shortcutsAccepted' = p3, 'segmentChecks' = p4,
        'homotopyVerification' = p5);
end proc;

MakePatchHistoryRecord := proc(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11)
    return Record('segment' = p1, 'segmentParameterStart' = p2,
        'segmentParameterEnd' = p3, 'step' = p4, 'order' = p5,
        'workingDigits' = p6, 'relativeTail' = p7,
        'orderDiscrepancy' = p8, 'restrictedRadius' = p9,
        'center' = p10, 'differentialResidual' = p11);
end proc;

MakeFactorDiagnosticsRecord := proc(p1)
    return Record('factorCount' = p1);
end proc;

MakeInverseDiagnosticsRecord := proc(p1)
    return Record('constructedAsInverse' = true, 'factorCount' = p1,
        'historySemantics' = "reversed algebraic factor history");
end proc;

MakePrecisionAttemptRecord := proc(p1, p2, p3, p4, p5, p6)
    return Record('attempt' = p1, 'digits' = p2, 'taylorOrder' = p3,
        'estimatedError' = p4, 'reverseError' = p5,
        'differentialResidual' = p6);
end proc;

MakeTransportDiagnosticsRecord := proc(p1, p2, p3, p4, p5, p6, p7, p8, p9)
    return Record('factorCount' = p1, 'estimatedError' = p2,
        'reverseChecked' = p3, 'reverseError' = p4,
        'precisionEscalations' = p5, 'finalDigits' = p6,
        'finalTaylorOrder' = p7, 'precisionHistory' = p8,
        'maxDifferentialResidual' = p9,
        'arithmetic' = "arbitrary-precision midpoint");
end proc;

MakeMeridianMetadataRecord := proc(p1, p2, p3, p4, p5 := 0)
    if p5 = 0 then
        return Record('label' = p1, 'singularPoint' = p2,
            'transverseDirection' = p3, 'radius' = p4,
            'orientation' = "counterclockwise");
    end if;
    return Record('label' = p1, 'singularPoint' = p2,
        'transverseDirection' = p3, 'radius' = p4,
        'orientation' = "counterclockwise", 'coordinateSlice' = p5);
end proc;

MakeRelationRecord := proc(p1, p2, p3)
    return Record('word' = p1, 'residual' = p2, 'verified' = p3);
end proc;

MakeGeneratorBundleRecord := proc(p1, p2, p3)
    return Record('loops' = p1, 'labels' = p2, 'transports' = p3);
end proc;

MakeUserPfaffianRecord := proc(p1, p2, p3, p4, p5, p6, p7,
                              p8 := "generic", p9 := [])
    return Record('hpType' = "UserPfaffianSystem",
        'connection' = p1, 'variables' = p2, 'rank' = p3,
        'basis' = p4, 'digits' = p5, 'declaredSingularFactors' = p6,
        'exactFlatness' = p7, 'family' = p8, 'familyParameters' = p9);
end proc;

MakeLauricellaFDEvaluationRecord := proc(p1,p2,p3,p4,p5,p6,p7,p8,
                                        p9 := "not_applicable",p10 := -1,
                                        p11 := -1,p12 := -1,p13 := [])
    return Record('hpType'="LauricellaFDEvaluation",'value'=p1,
        'methodUsed'=p2,'method'=p2,'degree'=p3,'errorEstimate'=p4,
        'estimatedError'=p4,'elapsedSeconds'=p5,'elapsedTime'=p5,
        'estimatedDegree'=p6,
        'compressedDimension'=p7,'transportFactors'=p8,
        'convergenceTest'=p9,'certificate'=p9,'tailBound'=p10,
        'doubledDegreeDifference'=p11,'roundingError'=p12,
        'derivatives'=p13);
end proc;

MakeHypergeometricEvaluationRecord := proc(
    p1, p2::list, p3::string, p4,
    p5, p6, p7::string,
    p8::string, p9::nonnegint,
    p10 := -1, p11 := 0
)
    return Record('hpType'="HypergeometricEvaluation",'value'=p1,
        'derivatives'=p2,'methodUsed'=p3,'method'=p3,
        'degree'=p4,'errorEstimate'=p5,
        'estimatedError'=p5,'elapsedSeconds'=p6,
        'elapsedTime'=p6,'convergenceTest'=p7,
        'certificate'=p7,'functionName'=p8,
        'activeVariables'=p9,'estimatedDegree'=p10,
        'transportFactors'=p11);
end proc;

MakeExactFlatnessRecord := proc(p1, p2, p3)
    return Record('passed' = p1, 'status' = p2,
        'nonzeroCurvatures' = p3);
end proc;

# ---------------------------------------------------------------------------
# Public data constructors
# ---------------------------------------------------------------------------

AffineParameter := proc(constant, slope := 0)
    return MakeAffineRecord(constant, slope);
end proc;

EpsilonParameter := proc(constant := 0, slope := 1)
    return AffineParameter(constant, slope);
end proc;

IsAffineParameter := proc(value)
    try
        return evalb(value:-hpType = "AffineParameter");
    catch:
        return false;
    end try;
end proc;

AsAffineParameter := proc(value)
    if IsAffineParameter(value) then
        return value;
    end if;
    return AffineParameter(value, 0);
end proc;

EvaluateParameter := proc(parameter, epsilon)
    local affine;
    affine := AsAffineParameter(parameter);
    return evalf(affine:-constant + affine:-slope * epsilon);
end proc;

HornSeries := proc(
    upperParameters::list,
    upperWeights::list,
    lowerParameters::list,
    lowerWeights::list,
    name := "HornSeries"
)
    local n, row;
    if nops(upperParameters) <> nops(upperWeights) then
        error "the number of upper weight rows must equal the number of upper parameters";
    end if;
    if nops(lowerParameters) <> nops(lowerWeights) then
        error "the number of lower weight rows must equal the number of lower parameters";
    end if;
    if nops(upperWeights) > 0 then
        n := nops(upperWeights[1]);
    elif nops(lowerWeights) > 0 then
        n := nops(lowerWeights[1]);
    else
        error "the number of variables cannot be inferred from two empty weight lists";
    end if;
    if n < 1 then
        error "a Horn series must have at least one variable";
    end if;
    for row in [op(upperWeights), op(lowerWeights)] do
        if nops(row) <> n then
            error "all weight vectors must have the same length";
        end if;
        if not andmap(type, row, integer) then
            error "weight vectors must contain integers";
        end if;
    end do;
    return MakeHornRecord(convert(name, string), n,
        map(AsAffineParameter, upperParameters), upperWeights,
        map(AsAffineParameter, lowerParameters), lowerWeights);
end proc;

CheckExactFlatness := proc(systemOrConnection, variablesArgument := [])
    local connectionList, variableList, rank, inexact, matrixValue,
          numeratorValue, denominatorValue, curvature, entryValue,
          nonzeroValues, i, j, row, column;
    try
        if systemOrConnection:-hpType = "UserPfaffianSystem" then
            connectionList := systemOrConnection:-connection;
            variableList := systemOrConnection:-variables;
        else
            connectionList := systemOrConnection;
            variableList := variablesArgument;
        end if;
    catch:
        connectionList := systemOrConnection;
        variableList := variablesArgument;
    end try;
    if not type(connectionList,list) or nops(connectionList) <> nops(variableList) or
       nops(connectionList) = 0 then
        error "CheckExactFlatness expects a connection-matrix list and its variables";
    end if;
    rank := LinearAlgebra:-RowDimension(connectionList[1]);
    inexact := false;
    for matrixValue in connectionList do
        for row to rank do
            for column to rank do
                entryValue := normal(matrixValue[row,column]);
                if nops(indets(entryValue,float)) > 0 then inexact := true; end if;
                numeratorValue := numer(entryValue);
                denominatorValue := denom(entryValue);
                if not type(numeratorValue,
                    polynom(anything,convert(variableList,set))) or
                   not type(denominatorValue,
                    polynom(anything,convert(variableList,set))) then
                    error "user Pfaffian entries must be rational functions of the declared variables";
                end if;
            end do;
        end do;
    end do;
    if inexact then
        return MakeExactFlatnessRecord(false,"unknown_inexact",[]);
    end if;
    nonzeroValues := [];
    for i to nops(variableList) do
        for j from i+1 to nops(variableList) do
            curvature := Matrix(rank,rank,datatype=anything);
            for row to rank do
                for column to rank do
                    curvature[row,column] := normal(simplify(
                        diff(connectionList[i][row,column],variableList[j])-
                        diff(connectionList[j][row,column],variableList[i])+
                        (connectionList[i].connectionList[j])[row,column]-
                        (connectionList[j].connectionList[i])[row,column]));
                    if curvature[row,column] <> 0 then
                        nonzeroValues := [op(nonzeroValues),
                            [i,j,row,column,curvature[row,column]]];
                    end if;
                end do;
            end do;
        end do;
    end do;
    if nops(nonzeroValues) = 0 then
        return MakeExactFlatnessRecord(true,"verified_exact",[]);
    end if;
    return MakeExactFlatnessRecord(false,"failed_exact",nonzeroValues);
end proc;

UserPfaffianSystem := proc(
    connectionMatrices::list,
    variables::list,
    {digits := 50, singularFactors := []}
)
    local rank, matrixValue, row, column, entryValue, basisLabels,
          exactFlatness, i;
    if nops(variables) = 0 or nops(connectionMatrices) <> nops(variables) then
        error "one connection matrix is required for each variable";
    end if;
    if not andmap(type,variables,symbol) or
       nops(convert(variables,set)) <> nops(variables) then
        error "variables must be distinct unassigned symbols";
    end if;
    if digits < 1 then error "digits must be positive"; end if;
    if not type(singularFactors,list) then
        error "singularFactors must be a list of polynomial factors";
    end if;
    if not type(connectionMatrices[1],Matrix) then
        error "connection matrices must be Maple Matrix objects";
    end if;
    rank := LinearAlgebra:-RowDimension(connectionMatrices[1]);
    if rank < 1 or LinearAlgebra:-ColumnDimension(connectionMatrices[1]) <> rank then
        error "connection matrices must be nonempty and square";
    end if;
    for matrixValue in connectionMatrices do
        if not type(matrixValue,Matrix) or
           LinearAlgebra:-RowDimension(matrixValue) <> rank or
           LinearAlgebra:-ColumnDimension(matrixValue) <> rank then
            error "all connection matrices must have the same square shape";
        end if;
        for row to rank do
            for column to rank do
                entryValue := normal(matrixValue[row,column]);
                if denom(entryValue) = 0 then
                    error "a connection entry has an identically zero denominator";
                end if;
            end do;
        end do;
    end do;
    basisLabels := [seq(cat("e",i),i=1..rank)];
    exactFlatness := CheckExactFlatness(connectionMatrices,variables);
    return MakeUserPfaffianRecord(map(copy,connectionMatrices),variables,
        rank,basisLabels,digits,singularFactors,exactFlatness);
end proc;

PfaffianFromConnection := proc(
    connectionMatrices::list,
    variables::list,
    {digits := 50, singularFactors := []}
)
    return UserPfaffianSystem(connectionMatrices,variables,
        'digits'=digits,'singularFactors'=singularFactors);
end proc;

SystemNVariables := proc(system)
    if system:-hpType = "UserPfaffianSystem" then
        return nops(system:-variables);
    elif system:-hpType = "PfaffianSystem" then
        return system:-series:-nvariables;
    end if;
    error "expected a Pfaffian system";
end proc;

SystemRank := proc(system)
    if system:-hpType = "UserPfaffianSystem" then
        return system:-rank;
    elif system:-hpType = "PfaffianSystem" then
        return nops(system:-basis);
    end if;
    error "expected a Pfaffian system";
end proc;

HasEpsilon := proc(series)
    local parameter;
    for parameter in [op(series:-upperParameters), op(series:-lowerParameters)] do
        if parameter:-slope <> 0 then
            return true;
        end if;
    end do;
    return false;
end proc;

NumericSeries := proc(series, epsilon)
    return MakeNumericHornRecord(series:-name, series:-nvariables,
        map(p -> EvaluateParameter(p, epsilon), series:-upperParameters),
        series:-upperWeights,
        map(p -> EvaluateParameter(p, epsilon), series:-lowerParameters),
        series:-lowerWeights);
end proc;

# Preserve exact rational parameters when possible.  This companion to
# NumericSeries is used only for algebraic singular-divisor extraction; the
# numerical Macaulay reduction continues to use guarded floating arithmetic.
ExactParameterSeries := proc(series, epsilon)
    local parameterValue;
    parameterValue := p -> p:-constant + p:-slope * epsilon;
    return MakeNumericHornRecord(series:-name, series:-nvariables,
        map(parameterValue, series:-upperParameters), series:-upperWeights,
        map(parameterValue, series:-lowerParameters), series:-lowerWeights);
end proc;

# ---------------------------------------------------------------------------
# Multi-indices and sparse multivariate polynomials
# ---------------------------------------------------------------------------

ZeroIndex := proc(n::posint)
    local i;
    return [seq(0, i = 1 .. n)];
end proc;

UnitIndex := proc(n::posint, variable::posint)
    local i;
    return [seq(`if`(i = variable, 1, 0), i = 1 .. n)];
end proc;

AddIndex := proc(index::list, variable::posint)
    local i;
    return [seq(index[i] + `if`(i = variable, 1, 0), i = 1 .. nops(index))];
end proc;

WeightDot := proc(weights::list, index::list)
    local i;
    return add(weights[i] * index[i], i = 1 .. nops(index));
end proc;

Compositions := proc(total::nonnegint, n::posint)
option remember;
    local result, first, tail, tails;
    if n = 1 then
        return [[total]];
    end if;
    result := [];
    for first from 0 to total do
        tails := Compositions(total - first, n - 1);
        for tail in tails do
            result := [op(result), [first, op(tail)]];
        end do;
    end do;
    return result;
end proc;

AllMultiIndices := proc(n::posint, maximumTotal::nonnegint)
    local result, total;
    result := [];
    for total from 0 to maximumTotal do
        result := [op(result), op(Compositions(total, n))];
    end do;
    return result;
end proc;

LexGreater := proc(left::list, right::list)
    local i;
    for i to nops(left) do
        if left[i] > right[i] then
            return true;
        elif left[i] < right[i] then
            return false;
        end if;
    end do;
    return false;
end proc;

MultiIndexGreater := proc(left::list, right::list)
    local sl, sr, ml, mr;
    sl := add(left); sr := add(right);
    if sl <> sr then return evalb(sl > sr); end if;
    ml := max(op(left)); mr := max(op(right));
    if ml <> mr then return evalb(ml > mr); end if;
    return LexGreater(left, right);
end proc;

MultiIndexLess := proc(left::list, right::list)
    local sl, sr, ml, mr;
    sl := add(left); sr := add(right);
    if sl <> sr then return evalb(sl < sr); end if;
    ml := max(op(left)); mr := max(op(right));
    if ml <> mr then return evalb(ml < mr); end if;
    return LexGreater(right, left);
end proc;

PolyConstant := proc(n::posint, value)
    local result;
    result := table();
    if value <> 0 then result[ZeroIndex(n)] := value; end if;
    return result;
end proc;

PolyMonomial := proc(exponent::list, value)
    local result;
    result := table();
    if value <> 0 then result[exponent] := value; end if;
    return result;
end proc;

PolyCopy := proc(polynomial::table)
    local result, key;
    result := table();
    for key in [indices(polynomial, 'nolist')] do
        result[key] := polynomial[key];
    end do;
    return result;
end proc;

PolyAdd := proc(left::table, right::table)
    local result, key, value;
    result := PolyCopy(left);
    for key in [indices(right, 'nolist')] do
        if assigned(result[key]) then
            value := result[key] + right[key];
        else
            value := right[key];
        end if;
        result[key] := value;
    end do;
    return result;
end proc;

PolyScale := proc(polynomial::table, scalar)
    local result, key;
    result := table();
    if scalar = 0 then return result; end if;
    for key in [indices(polynomial, 'nolist')] do
        if polynomial[key] <> 0 then
            result[key] := scalar * polynomial[key];
        end if;
    end do;
    return result;
end proc;

PolyMultiply := proc(left::table, right::table)
    local result, lk, rk, exponent, value, i;
    result := table();
    for lk in [indices(left, 'nolist')] do
        if left[lk] = 0 then next; end if;
        for rk in [indices(right, 'nolist')] do
            if right[rk] = 0 then next; end if;
            exponent := [seq(lk[i] + rk[i], i = 1 .. nops(lk))];
            value := left[lk] * right[rk];
            if assigned(result[exponent]) then
                result[exponent] := result[exponent] + value;
            else
                result[exponent] := value;
            end if;
        end do;
    end do;
    return result;
end proc;

PolyDerivative := proc(polynomial::table, variable::posint)
    local result, key, exponent, value, i;
    result := table();
    for key in [indices(polynomial, 'nolist')] do
        if key[variable] = 0 or polynomial[key] = 0 then next; end if;
        exponent := [seq(key[i] - `if`(i = variable, 1, 0), i = 1 .. nops(key))];
        value := polynomial[key] * key[variable];
        if assigned(result[exponent]) then
            result[exponent] := result[exponent] + value;
        else
            result[exponent] := value;
        end if;
    end do;
    return result;
end proc;

PolyEvaluate := proc(polynomial::table, point::list)
    local result, key, term, i;
    result := 0;
    for key in [indices(polynomial, 'nolist')] do
        term := polynomial[key];
        if term = 0 then next; end if;
        for i to nops(key) do
            if key[i] <> 0 then term := term * point[i]^key[i]; end if;
        end do;
        result := result + term;
    end do;
    return evalf(result);
end proc;

PolyDegree := proc(polynomial::table)
    local degree, key;
    degree := -1;
    for key in [indices(polynomial, 'nolist')] do
        if polynomial[key] <> 0 then degree := max(degree, add(key)); end if;
    end do;
    return degree;
end proc;

AffinePolynomial := proc(n::posint, constant, weights::list)
    local result, variable;
    result := PolyConstant(n, constant);
    for variable to n do
        if weights[variable] <> 0 then
            result := PolyAdd(
                result,
                PolyMonomial(UnitIndex(n, variable), weights[variable])
            );
        end if;
    end do;
    return result;
end proc;

# ---------------------------------------------------------------------------
# Sparse differential operators in ordinary derivatives
# ---------------------------------------------------------------------------

OperatorAdd := proc(left::table, right::table)
    local result, key;
    result := table();
    for key in [indices(left, 'nolist')] do result[key] := PolyCopy(left[key]); end do;
    for key in [indices(right, 'nolist')] do
        if assigned(result[key]) then
            result[key] := PolyAdd(result[key], right[key]);
        else
            result[key] := PolyCopy(right[key]);
        end if;
    end do;
    return result;
end proc;

OperatorScale := proc(operator::table, scalar)
    local result, key;
    result := table();
    for key in [indices(operator, 'nolist')] do
        result[key] := PolyScale(operator[key], scalar);
    end do;
    return result;
end proc;

OperatorDerivative := proc(operator::table, variable::posint)
    local result, derivative, coefficientDerivative, higher;
    result := table();
    for derivative in [indices(operator, 'nolist')] do
        coefficientDerivative := PolyDerivative(operator[derivative], variable);
        if PolyDegree(coefficientDerivative) >= 0 then
            if assigned(result[derivative]) then
                result[derivative] := PolyAdd(result[derivative], coefficientDerivative);
            else
                result[derivative] := coefficientDerivative;
            end if;
        end if;
        higher := AddIndex(derivative, variable);
        if assigned(result[higher]) then
            result[higher] := PolyAdd(result[higher], operator[derivative]);
        else
            result[higher] := PolyCopy(operator[derivative]);
        end if;
    end do;
    return result;
end proc;

DifferentiateOperator := proc(operator::table, derivative::list)
    local result, variable, count;
    result := operator;
    for variable to nops(derivative) do
        for count to derivative[variable] do
            result := OperatorDerivative(result, variable);
        end do;
    end do;
    return result;
end proc;

OperatorOrder := proc(operator::table)
    local order, derivative;
    order := -1;
    for derivative in [indices(operator, 'nolist')] do
        if PolyDegree(operator[derivative]) >= 0 then
            order := max(order, add(derivative));
        end if;
    end do;
    return order;
end proc;

StirlingSecond := proc(n::nonnegint, k::nonnegint)
option remember;
    if n = 0 then return `if`(k = 0, 1, 0); end if;
    if k = 0 or k > n then return 0; end if;
    return StirlingSecond(n - 1, k - 1) + k * StirlingSecond(n - 1, k);
end proc;

CartesianChoices := proc(choices::list)
    local result, choice, suffix, tails;
    if nops(choices) = 0 then return [[[], 1]]; end if;
    result := [];
    tails := CartesianChoices(choices[2 .. -1]);
    for choice in choices[1] do
        for suffix in tails do
            result := [op(result), [[choice[1], op(suffix[1])], choice[2] * suffix[2]]];
        end do;
    end do;
    return result;
end proc;

EulerToOperator := proc(thetaPolynomial::table, variableMonomial := [])
    local keys, n, monomial, choices, variable, power, ordinary,
          combination, derivative, exponent, polynomial, result, i, vm;
    keys := [indices(thetaPolynomial, 'nolist')];
    if nops(keys) = 0 then return table(); end if;
    n := nops(keys[1]);
    vm := variableMonomial;
    if nops(vm) = 0 then vm := ZeroIndex(n); end if;
    result := table();
    for monomial in keys do
        if thetaPolynomial[monomial] = 0 then next; end if;
        choices := [];
        for variable to n do
            power := monomial[variable];
            if power = 0 then
                choices := [op(choices), [[0, 1]]];
            else
                choices := [op(choices), [seq([ordinary, StirlingSecond(power, ordinary)], ordinary = 1 .. power)]];
            end if;
        end do;
        for combination in CartesianChoices(choices) do
            derivative := combination[1];
            exponent := [seq(derivative[i] + vm[i], i = 1 .. n)];
            polynomial := PolyMonomial(
                exponent,
                thetaPolynomial[monomial] * combination[2]
            );
            if assigned(result[derivative]) then
                result[derivative] := PolyAdd(result[derivative], polynomial);
            else
                result[derivative] := polynomial;
            end if;
        end do;
    end do;
    return result;
end proc;

# ---------------------------------------------------------------------------
# Horn shift ratios and annihilating PDEs
# ---------------------------------------------------------------------------

MultiplyAffine := proc(polynomial::table, constant, weights::list)
    return PolyMultiply(polynomial, AffinePolynomial(nops(weights), constant, weights));
end proc;

RatioPolynomials := proc(series, variable::posint)
    local n, numerator, denominator, numeratorDegree, denominatorDegree,
          i, shift, offset, distance, parameter, weights, shiftedConstant;
    n := series:-nvariables;
    numerator := PolyConstant(n, 1);
    denominator := MultiplyAffine(PolyConstant(n, 1), 0, UnitIndex(n, variable));
    numeratorDegree := 0;
    denominatorDegree := 1;

    for i to nops(series:-upperParameters) do
        parameter := series:-upperParameters[i];
        weights := series:-upperWeights[i];
        shift := weights[variable];
        if shift > 0 then
            for offset from 0 to shift - 1 do
                numerator := MultiplyAffine(numerator, parameter + offset, weights);
                numeratorDegree := numeratorDegree + 1;
            end do;
        elif shift < 0 then
            for distance to -shift do
                shiftedConstant := parameter - distance - weights[variable];
                denominator := MultiplyAffine(denominator, shiftedConstant, weights);
                denominatorDegree := denominatorDegree + 1;
            end do;
        end if;
    end do;

    for i to nops(series:-lowerParameters) do
        parameter := series:-lowerParameters[i];
        weights := series:-lowerWeights[i];
        shift := weights[variable];
        if shift > 0 then
            for offset from 0 to shift - 1 do
                shiftedConstant := parameter + offset - weights[variable];
                denominator := MultiplyAffine(denominator, shiftedConstant, weights);
                denominatorDegree := denominatorDegree + 1;
            end do;
        elif shift < 0 then
            for distance to -shift do
                numerator := MultiplyAffine(numerator, parameter - distance, weights);
                numeratorDegree := numeratorDegree + 1;
            end do;
        end if;
    end do;
    return [numerator, denominator, max(numeratorDegree, denominatorDegree)];
end proc;

BasePDEs := proc(series)
    local equations, orders, variable, ratio, denominatorOperator,
          numeratorOperator, unit;
    equations := []; orders := [];
    for variable to series:-nvariables do
        ratio := RatioPolynomials(series, variable);
        unit := UnitIndex(series:-nvariables, variable);
        denominatorOperator := EulerToOperator(ratio[2]);
        numeratorOperator := EulerToOperator(ratio[1], unit);
        equations := [op(equations), OperatorAdd(
            denominatorOperator,
            OperatorScale(numeratorOperator, -1)
        )];
        orders := [op(orders), ratio[3]];
    end do;
    return [equations, orders];
end proc;

PDEGenerator := proc(series, {epsilon := 0, digits := 50})
    local oldDigits, result;
    if digits < 1 then error "digits must be positive"; end if;
    oldDigits := Digits; Digits := digits + 10;
    try
        result := BasePDEs(NumericSeries(series, epsilon))[1];
    finally
        Digits := oldDigits;
    end try;
    return result;
end proc;

FindHypergeometricOrder := proc(series, {epsilon := 0, digits := 50})
    local oldDigits, result;
    oldDigits := Digits; Digits := digits + 10;
    try
        result := BasePDEs(NumericSeries(series, epsilon))[2];
    finally
        Digits := oldDigits;
    end try;
    return result;
end proc;

# ---------------------------------------------------------------------------
# Numerical Macaulay reduction and Pfaffian systems
# ---------------------------------------------------------------------------

DifferentialClosure := proc(baseEquations::list, seed::nonnegint)
    local equations, equation, remaining, derivative;
    equations := [];
    for equation in baseEquations do
        remaining := seed - OperatorOrder(equation);
        if remaining < 0 then next; end if;
        for derivative in AllMultiIndices(nops([indices(equation, 'nolist')][1]), remaining) do
            equations := [op(equations), DifferentiateOperator(equation, derivative)];
        end do;
    end do;
    return equations;
end proc;

EquationColumns := proc(equations::list, n::posint, seed::nonnegint)
    local seen, equation, derivative, columns;
    seen := table();
    for derivative in AllMultiIndices(n, seed) do seen[derivative] := true; end do;
    for equation in equations do
        for derivative in [indices(equation, 'nolist')] do
            seen[derivative] := true;
        end do;
    end do;
    columns := [indices(seen, 'nolist')];
    return sort(columns, MultiIndexGreater);
end proc;

EquationMatrix := proc(equations::list, columns::list, point::list)
    local matrix, columnIndex, row, column, derivative, equation;
    matrix := Matrix(nops(equations), nops(columns), datatype = anything);
    columnIndex := table();
    for column to nops(columns) do columnIndex[columns[column]] := column; end do;
    for row to nops(equations) do
        equation := equations[row];
        for derivative in [indices(equation, 'nolist')] do
            matrix[row, columnIndex[derivative]] := PolyEvaluate(equation[derivative], point);
        end do;
    end do;
    return matrix;
end proc;

MatrixMaxAbs := proc(matrix::Matrix)
    local maximumValue, i, j, value;
    maximumValue := 0;
    for i to LinearAlgebra:-RowDimension(matrix) do
        for j to LinearAlgebra:-ColumnDimension(matrix) do
            value := evalf(abs(matrix[i, j]));
            if value > maximumValue then maximumValue := value; end if;
        end do;
    end do;
    return maximumValue;
end proc;

VectorMaxAbs := proc(vector::Vector)
    local maximumValue, i, value;
    maximumValue := 0;
    for i to LinearAlgebra:-Dimension(vector) do
        value := evalf(abs(vector[i]));
        if value > maximumValue then maximumValue := value; end if;
    end do;
    return maximumValue;
end proc;

RREF := proc(inputMatrix::Matrix, digits::posint)
    local reduced, rows, columns, scale, threshold, pivotColumns,
          pivotRows, row, column, pivotRow, candidate, pivot,
          otherRow, factor, temporary, freeColumns, c;
    reduced := copy(inputMatrix);
    rows := LinearAlgebra:-RowDimension(reduced);
    columns := LinearAlgebra:-ColumnDimension(reduced);
    scale := max(MatrixMaxAbs(reduced), 1);
    threshold := evalf(scale * 10^(-max(20, iquo(digits, 2))));
    pivotColumns := []; pivotRows := []; row := 1;
    for column to columns while row <= rows do
        pivotRow := row;
        pivot := evalf(abs(reduced[row, column]));
        for candidate from row + 1 to rows do
            if evalf(abs(reduced[candidate, column])) > pivot then
                pivotRow := candidate;
                pivot := evalf(abs(reduced[candidate, column]));
            end if;
        end do;
        if pivot <= threshold then next; end if;
        if pivotRow <> row then
            for c to columns do
                temporary := reduced[row, c];
                reduced[row, c] := reduced[pivotRow, c];
                reduced[pivotRow, c] := temporary;
            end do;
        end if;
        pivot := reduced[row, column];
        for c to columns do reduced[row, c] := evalf(reduced[row, c] / pivot); end do;
        for otherRow to rows do
            if otherRow = row then next; end if;
            factor := reduced[otherRow, column];
            if evalf(abs(factor)) <= threshold then next; end if;
            for c to columns do
                reduced[otherRow, c] := evalf(reduced[otherRow, c] - factor * reduced[row, c]);
            end do;
        end do;
        pivotColumns := [op(pivotColumns), column];
        pivotRows := [op(pivotRows), row];
        row := row + 1;
    end do;
    freeColumns := [];
    for column to columns do
        if not member(column, pivotColumns) then
            freeColumns := [op(freeColumns), column];
        end if;
    end do;
    return MakeRREFRecord(reduced, pivotColumns, pivotRows, freeColumns, threshold);
end proc;

GenericPoint := proc(n::posint)
    local denominator, variable;
    denominator := 4 * n + 17;
    return [seq(evalf((2 * variable + 1) / denominator +
        I * variable / (7 * denominator)), variable = 1 .. n)];
end proc;

ExtractConnectionMatrices := proc(
    reduced::Matrix,
    pivotColumns::list,
    pivotRows::list,
    freeColumns::list,
    columns::list,
    basis::list,
    threshold
)
    local n, columnIndex, pivotRowForColumn, freeSet, basisColumns,
          basisSet, rank, matrices, variable, basisRow, derivative,
          target, targetColumn, basisIndex, relationRow, freeColumn,
          coefficient, matrixIndex, i;
    if nops(basis) = 0 then return FAIL; end if;
    n := nops(basis[1]);
    columnIndex := table();
    for i to nops(columns) do columnIndex[columns[i]] := i; end do;
    pivotRowForColumn := table();
    for i to nops(pivotColumns) do
        pivotRowForColumn[pivotColumns[i]] := pivotRows[i];
    end do;
    freeSet := table();
    for i in freeColumns do freeSet[i] := true; end do;
    basisColumns := [];
    for derivative in basis do
        if not assigned(columnIndex[derivative]) then return FAIL; end if;
        basisColumns := [op(basisColumns), columnIndex[derivative]];
    end do;
    for i in basisColumns do
        if not assigned(freeSet[i]) then return FAIL; end if;
    end do;
    basisSet := table();
    for i in basisColumns do basisSet[i] := true; end do;
    rank := nops(basis);
    matrices := [seq(Matrix(rank, rank, datatype = anything), variable = 1 .. n)];
    for variable to n do
        for basisRow to rank do
            derivative := basis[basisRow];
            target := AddIndex(derivative, variable);
            if not assigned(columnIndex[target]) then return FAIL; end if;
            targetColumn := columnIndex[target];
            if assigned(freeSet[targetColumn]) then
                if not assigned(basisSet[targetColumn]) then return FAIL; end if;
                for basisIndex to rank do
                    if basisColumns[basisIndex] = targetColumn then
                        matrices[variable][basisRow, basisIndex] := 1;
                        break;
                    end if;
                end do;
            else
                if not assigned(pivotRowForColumn[targetColumn]) then return FAIL; end if;
                relationRow := pivotRowForColumn[targetColumn];
                for freeColumn in freeColumns do
                    coefficient := reduced[relationRow, freeColumn];
                    if abs(coefficient) > 10 * threshold and not assigned(basisSet[freeColumn]) then
                        return FAIL;
                    end if;
                end do;
                for basisIndex to rank do
                    matrices[variable][basisRow, basisIndex] :=
                        -reduced[relationRow, basisColumns[basisIndex]];
                end do;
            end if;
        end do;
    end do;
    return matrices;
end proc;

DerivePfaffian := proc(numericSeries, digits::posint, maximumSeed,
                       exactSeries := NULL)
    local base, baseEquations, orders, maximumBasisOrder, initialSeed,
           finalSeed, point, seed, equations, columns, matrix, reduction,
           basis, zero, matrices, pivotSubmatrix, rowReduction,
           selectedRows, exactBase, exactEquations, i, j;
    base := BasePDEs(numericSeries);
    baseEquations := base[1]; orders := base[2];
    maximumBasisOrder := add(max(orders[i] - 1, 0), i = 1 .. nops(orders));
    initialSeed := maximumBasisOrder + `if`(nops(convert(orders, set)) = 1, 1, 2);
    if maximumSeed = 0 then
        finalSeed := max(initialSeed + 4, 8);
    else
        finalSeed := maximumSeed;
    end if;
    if finalSeed < initialSeed then
        error "maximumSeed must be at least %1", initialSeed;
    end if;
    point := GenericPoint(numericSeries:-nvariables);
    for seed from initialSeed to finalSeed do
        equations := DifferentialClosure(baseEquations, seed);
        columns := EquationColumns(equations, numericSeries:-nvariables, seed);
        matrix := EquationMatrix(equations, columns, point);
        reduction := RREF(matrix, digits);
        basis := [];
        for i in reduction:-freeColumns do
            if add(columns[i][j], j = 1 .. nops(columns[i])) <= maximumBasisOrder then
                basis := [op(basis), columns[i]];
            end if;
        end do;
        basis := sort(basis, MultiIndexLess);
        if nops(basis) = 0 then next; end if;
        zero := ZeroIndex(numericSeries:-nvariables);
        if not member(zero, basis) then next; end if;
        matrices := ExtractConnectionMatrices(
            reduction:-reduced,
            reduction:-pivotColumns,
            reduction:-pivotRows,
            reduction:-freeColumns,
            columns,
            basis,
            reduction:-threshold
        );
        if matrices = FAIL then next; end if;
        pivotSubmatrix := Matrix(
            LinearAlgebra:-RowDimension(matrix),
            nops(reduction:-pivotColumns),
            (i, j) -> matrix[i, reduction:-pivotColumns[j]],
            datatype = anything
        );
        rowReduction := RREF(LinearAlgebra:-Transpose(pivotSubmatrix), digits);
        selectedRows := rowReduction:-pivotColumns;
        if nops(selectedRows) <> nops(reduction:-pivotColumns) then next; end if;
        if exactSeries = NULL then
            exactEquations := [];
        else
            exactBase := BasePDEs(exactSeries);
            exactEquations := DifferentialClosure(exactBase[1], seed);
        end if;
        return MakePfaffianRecord(numericSeries, basis, equations, columns,
            reduction:-pivotColumns, reduction:-freeColumns, selectedRows,
            orders, digits, exactSeries, exactEquations, seed);
    end do;
    error "the finite derivative basis did not close through seed order %1; increase maximumSeed or use non-resonant parameters", finalSeed;
end proc;

FindPfaffianSystem := proc(
    series,
    {epsilon := 0, digits := 50, maximumSeed := 0}
)
    local oldDigits, result, numeric;
    if digits < 1 then error "digits must be positive"; end if;
    oldDigits := Digits; Digits := digits + 14;
    try
        numeric := NumericSeries(series,epsilon);
        EnsureGenericPfaffianSafe(numeric,maximumSeed);
        result := DerivePfaffian(numeric,digits+10,
            maximumSeed, ExactParameterSeries(series, epsilon));
    finally
        Digits := oldDigits;
    end try;
    return result;
end proc;

FindHolonomicRank := proc(
    series,
    {epsilon := 0, digits := 50, maximumSeed := 0}
)
    local system;
    system := FindPfaffianSystem(
        series,
        parse("epsilon")=epsilon,
        parse("digits")=digits,
        parse("maximumSeed")=maximumSeed
    );
    return [nops(system:-basis), system:-basis];
end proc;

UserConnectionMatricesInternal := proc(system, point::list)
    local rank, result, matrixValue, evaluatedMatrix, variable,
          row, column, entryValue, i;
    if nops(point) <> nops(system:-variables) then
        error "the point has the wrong length";
    end if;
    rank := system:-rank; result := [];
    for matrixValue in system:-connection do
        evaluatedMatrix := Matrix(rank,rank,datatype=anything);
        for row to rank do
            for column to rank do
                entryValue := evalf(subs(seq(system:-variables[i]=point[i],
                    i=1..nops(point)),matrixValue[row,column]));
                if not IsFiniteNumber(entryValue) then
                    error "the user Pfaffian connection is singular at the requested point";
                end if;
                evaluatedMatrix[row,column] := entryValue;
            end do;
        end do;
        result := [op(result),evaluatedMatrix];
    end do;
    return result;
end proc;

ConnectionMatricesInternal := proc(system, point::list)
    local selectedEquations, selectedColumns, derivatives, matrix,
          pivotCount, freeCount, pivotMatrix, freeMatrix, reduction,
          freePosition, pivotPosition, columnIndex, basisColumns,
          basisPositions, basisSet, threshold, rank, n, matrices,
          variable, basisRow, derivative, target, targetColumn,
          position, basisColumn, reductionRow, freeColumn, i, j;
    if system:-hpType = "UserPfaffianSystem" then
        return UserConnectionMatricesInternal(system,point);
    end if;
    selectedEquations := [seq(system:-equations[system:-equationRows[i]],
        i = 1 .. nops(system:-equationRows))];
    selectedColumns := [op(system:-pivotColumns), op(system:-freeColumns)];
    derivatives := [seq(system:-columns[selectedColumns[i]], i = 1 .. nops(selectedColumns))];
    matrix := EquationMatrix(selectedEquations, derivatives, point);
    pivotCount := nops(system:-pivotColumns);
    freeCount := nops(system:-freeColumns);
    pivotMatrix := Matrix(pivotCount, pivotCount,
        (i, j) -> matrix[i, j], datatype = anything);
    freeMatrix := Matrix(pivotCount, freeCount,
        (i, j) -> matrix[i, pivotCount + j], datatype = anything);
    try
        reduction := LinearAlgebra:-LinearSolve(pivotMatrix, -freeMatrix);
    catch:
        error "the selected derivative basis is singular at the requested point";
    end try;
    freePosition := table();
    for i to freeCount do freePosition[system:-freeColumns[i]] := i; end do;
    pivotPosition := table();
    for i to pivotCount do pivotPosition[system:-pivotColumns[i]] := i; end do;
    columnIndex := table();
    for i to nops(system:-columns) do columnIndex[system:-columns[i]] := i; end do;
    basisColumns := [seq(columnIndex[system:-basis[i]], i = 1 .. nops(system:-basis))];
    basisPositions := [];
    for i in basisColumns do
        if not assigned(freePosition[i]) then
            error "the derivative basis changed at the requested point";
        end if;
        basisPositions := [op(basisPositions), freePosition[i]];
    end do;
    basisSet := table();
    for i in basisPositions do basisSet[i] := true; end do;
    threshold := max(MatrixMaxAbs(pivotMatrix), 1) * 10^(-max(20, iquo(system:-digits, 2)));
    rank := nops(system:-basis); n := system:-series:-nvariables;
    matrices := [seq(Matrix(rank, rank, datatype = anything), variable = 1 .. n)];
    for variable to n do
        for basisRow to rank do
            derivative := system:-basis[basisRow];
            target := AddIndex(derivative, variable);
            if not assigned(columnIndex[target]) then
                error "the derivative closure is incomplete";
            end if;
            targetColumn := columnIndex[target];
            if assigned(freePosition[targetColumn]) then
                position := freePosition[targetColumn];
                if not assigned(basisSet[position]) then
                    error "the derivative basis changed at the requested point";
                end if;
                for basisColumn to rank do
                    if basisPositions[basisColumn] = position then
                        matrices[variable][basisRow, basisColumn] := 1;
                        break;
                    end if;
                end do;
            else
                if not assigned(pivotPosition[targetColumn]) then
                    error "the derivative closure is incomplete";
                end if;
                reductionRow := pivotPosition[targetColumn];
                for freeColumn to freeCount do
                    if abs(reduction[reductionRow, freeColumn]) > 10 * threshold and
                       not assigned(basisSet[freeColumn]) then
                        error "the selected equations do not close on the derivative basis";
                    end if;
                end do;
                for basisColumn to rank do
                    matrices[variable][basisRow, basisColumn] :=
                        reduction[reductionRow, basisPositions[basisColumn]];
                end do;
            end if;
        end do;
    end do;
    return matrices;
end proc;

ConnectionMatrices := proc(system, point::list)
    local oldDigits, numericPoint, result;
    if nops(point) <> SystemNVariables(system) then
        error "the point has the wrong length";
    end if;
    oldDigits := Digits; Digits := system:-digits + 14;
    try
        numericPoint := map(evalf, point);
        result := ConnectionMatricesInternal(system, numericPoint);
    finally
        Digits := oldDigits;
    end try;
    return result;
end proc;

CheckIntegrability := proc(system, {point := []})
    local oldDigits, x, n, h, omega, maximumResidual, i, j,
          xPlusJ, xMinusJ, xPlusI, xMinusI, derivativeJI,
          derivativeIJ, residual, tolerance, result, k;
    oldDigits := Digits; Digits := system:-digits + 14;
    try
        n := SystemNVariables(system);
        x := `if`(nops(point) = 0, GenericPoint(n), map(evalf, point));
        if nops(x) <> n then error "the point has the wrong length"; end if;
        h := evalf(10^(-min(8, max(3, iquo(system:-digits, 4)))));
        omega := ConnectionMatricesInternal(system, x);
        maximumResidual := 0;
        for i to n do
            for j from i + 1 to n do
                xPlusJ := [op(x)]; xMinusJ := [op(x)];
                xPlusI := [op(x)]; xMinusI := [op(x)];
                xPlusJ[j] := xPlusJ[j] + h; xMinusJ[j] := xMinusJ[j] - h;
                xPlusI[i] := xPlusI[i] + h; xMinusI[i] := xMinusI[i] - h;
                derivativeJI := (ConnectionMatricesInternal(system, xPlusJ)[i] -
                    ConnectionMatricesInternal(system, xMinusJ)[i]) / (2 * h);
                derivativeIJ := (ConnectionMatricesInternal(system, xPlusI)[j] -
                    ConnectionMatricesInternal(system, xMinusI)[j]) / (2 * h);
                residual := derivativeJI - derivativeIJ + omega[i].omega[j] - omega[j].omega[i];
                maximumResidual := max(maximumResidual, MatrixMaxAbs(residual));
            end do;
        end do;
        tolerance := sqrt(h);
        result := MakeCheckRecord(evalb(maximumResidual <= tolerance),
            maximumResidual, tolerance);
    finally
        Digits := oldDigits;
    end try;
    return result;
end proc;

ChooseBasepoint := proc(
    system,
    {digits := 0, radius := 0.12, maximumAttempts := 12,
     maximumDegree := 220}
)
    local effectiveDigits, oldDigits, attempt, scale, candidate,
          connectionValue, initialValue, n, i;
    if radius <= 0 then error "radius must be positive"; end if;
    effectiveDigits := `if`(digits = 0, system:-digits, digits);
    n := SystemNVariables(system);
    oldDigits := Digits;
    Digits := max(oldDigits,system:-digits,effectiveDigits+14);
    try
        for attempt to maximumAttempts do
            scale := evalf(radius * (0.55 + 0.4*attempt/maximumAttempts));
            candidate := [seq(evalf(scale*(i+1)/(n+2) +
                I*scale*(attempt+i)/(17*maximumAttempts)), i = 1 .. n)];
            try
                connectionValue := ConnectionMatricesInternal(system,candidate);
                if system:-hpType = "UserPfaffianSystem" then
                    return candidate;
                end if;
                initialValue := SeriesVector(system:-series,candidate,
                    system:-basis,effectiveDigits,maximumDegree);
                if initialValue[2] then return candidate; end if;
            catch:
                # Try the next deterministic regular candidate.
            end try;
        end do;
    finally
        Digits := oldDigits;
    end try;
    error "a regular convergent basepoint was not found; supply one explicitly";
end proc;

InitialVector := proc(
    system,
    basepoint::list,
    {digits := 0, maximumDegree := 260}
)
    local effectiveDigits, oldDigits, result;
    if system:-hpType = "UserPfaffianSystem" then
        error "a user Pfaffian system has no distinguished initial vector; supply one explicitly";
    end if;
    if nops(basepoint) <> SystemNVariables(system) then
        error "the basepoint has the wrong length";
    end if;
    effectiveDigits := `if`(digits = 0, system:-digits, digits);
    oldDigits := Digits; Digits := effectiveDigits + 14;
    try
        result := SeriesVector(system:-series,map(evalf,basepoint),
            system:-basis,effectiveDigits,maximumDegree);
        if not result[2] then
            error "the defining series did not converge at the selected basepoint";
        end if;
    finally
        Digits := oldDigits;
    end try;
    return result[1];
end proc;

# ---------------------------------------------------------------------------
# Singular divisor and path planning for the full multivariate connection
# ---------------------------------------------------------------------------

PolyExpression := proc(polynomial::table, variables::list)
    local result, exponent, coefficientValue, i;
    result := 0;
    for exponent in [indices(polynomial, 'nolist')] do
        coefficientValue := polynomial[exponent];
        for i to nops(exponent) do
            coefficientValue := coefficientValue * variables[i]^exponent[i];
        end do;
        result := result + coefficientValue;
    end do;
    return expand(result);
end proc;

PivotPolynomialMatrix := proc(system, variables::list)
    local sourceEquations, selectedEquations, selectedColumns,
          pivotCount, result, row, column, derivative;
    if nops(variables) <> system:-series:-nvariables then
        error "the variable-name list has the wrong length";
    end if;
    if nops(system:-exactEquations) > 0 then
        sourceEquations := system:-exactEquations;
    else
        sourceEquations := system:-equations;
    end if;
    selectedEquations := [seq(sourceEquations[system:-equationRows[row]],
        row = 1 .. nops(system:-equationRows))];
    selectedColumns := system:-pivotColumns;
    pivotCount := nops(selectedColumns);
    result := Matrix(pivotCount, pivotCount, datatype = anything);
    for row to pivotCount do
        for column to pivotCount do
            derivative := system:-columns[selectedColumns[column]];
            if assigned(selectedEquations[row][derivative]) then
                result[row, column] :=
                    PolyExpression(selectedEquations[row][derivative], variables);
            else
                result[row, column] := 0;
            end if;
        end do;
    end do;
    return result;
end proc;

PivotDeterminantExpression := proc(system, variables::list)
    return factor(expand(LinearAlgebra:-Determinant(
        PivotPolynomialMatrix(system, variables))));
end proc;

SingularFactors := proc(system, {variableNames := []})
    local variables, determinantExpression, factorData,
          factorList, multiplicities, entry, matrixValue, row, column,
          originalVariables, i;
    option remember;
    if nops(variableNames) = 0 then
        if system:-hpType = "UserPfaffianSystem" then
            variables := system:-variables;
        else
            variables := [seq(parse(cat("hp_x", i)),
                i = 1 .. SystemNVariables(system))];
        end if;
    else
        variables := variableNames;
    end if;
    if nops(variables) <> SystemNVariables(system) then
        error "variableNames has the wrong length";
    end if;
    if system:-hpType = "UserPfaffianSystem" then
        originalVariables := system:-variables;
        if system:-family = "LauricellaFD" then
            # The explicit constructor already supplies the complete
            # square-free divisor x_i(1-x_i)prod_{i<j}(x_i-x_j).  Expanding
            # the repeated denominators of all (n+1)^2 connection entries is
            # exponentially wasteful in seven or more variables.
            factorList := system:-declaredSingularFactors;
            if variables <> originalVariables then
                factorList := [seq(subs(seq(originalVariables[i]=variables[i],
                    i=1..nops(variables)),entry),entry in factorList)];
            end if;
            determinantExpression := mul(entry,entry in factorList);
            multiplicities := [1$nops(factorList)];
            return MakeSingularRecord(variables,determinantExpression,
                factorList,multiplicities);
        end if;
        determinantExpression := 1;
        for matrixValue in system:-connection do
            for row to system:-rank do
                for column to system:-rank do
                    determinantExpression := determinantExpression *
                        denom(normal(matrixValue[row,column]));
                end do;
            end do;
        end do;
        for entry in system:-declaredSingularFactors do
            determinantExpression := determinantExpression * entry;
        end do;
        if variables <> originalVariables then
            determinantExpression := subs(seq(originalVariables[i]=variables[i],
                i=1..nops(variables)),determinantExpression);
        end if;
        determinantExpression := factor(expand(determinantExpression));
    else
        determinantExpression := PivotDeterminantExpression(system, variables);
    end if;
    factorList := []; multiplicities := [];
    try
        factorData := factors(determinantExpression);
        if type(factorData, list) and nops(factorData) = 2 and
           type(factorData[2], list) then
            for entry in factorData[2] do
                factorList := [op(factorList), entry[1]];
                multiplicities := [op(multiplicities), entry[2]];
            end do;
        end if;
    catch:
        factorList := [];
    end try;
    if nops(factorList) = 0 and determinantExpression <> 1 then
        factorList := [determinantExpression];
        multiplicities := [1];
    end if;
    return MakeSingularRecord(variables, determinantExpression,
        factorList, multiplicities);
end proc;

RestrictedSingularRoots := proc(
    system,
    segmentStart::list,
    segmentEnd::list,
    {digits := 0}
)
    local effectiveDigits, oldDigits, divisor, tau, direction,
          factorValue, restricted, numeratorExpression, rawRoots, roots,
          rootValue, duplicate, existing, i;
    if nops(segmentStart) <> SystemNVariables(system) or
       nops(segmentEnd) <> SystemNVariables(system) then
        error "a segment endpoint has the wrong length";
    end if;
    effectiveDigits := `if`(digits = 0, system:-digits, digits);
    oldDigits := Digits;
    Digits := max(oldDigits,system:-digits,effectiveDigits+14);
    try
        divisor := SingularFactors(system);
        tau := parse("hp_tau");
        direction := [seq(segmentEnd[i] - segmentStart[i],
            i = 1 .. nops(segmentStart))];
        roots := [];
        # Solve each square-free divisor component separately.  Solving the
        # expanded determinant makes repeated denominator factors look like a
        # high-multiplicity polynomial; fsolve then returns clouds of spurious
        # nearby roots and can force thousands of unnecessary Taylor patches.
        for factorValue in divisor:-factors do
            restricted := expand(subs(seq(divisor:-variables[i] =
                segmentStart[i] + tau * direction[i],
                i = 1 .. nops(direction)), factorValue));
            numeratorExpression := numer(normal(restricted));
            if evalb(numeratorExpression = 0) then
                error "the entire segment is contained in the selected singular divisor";
            elif not has(numeratorExpression, tau) then
                next;
            end if;
            rawRoots := [fsolve(numeratorExpression = 0, tau, complex)];
            for rootValue in rawRoots do
                rootValue := evalf(rootValue);
                if not IsFiniteNumber(rootValue) then next; end if;
                duplicate := false;
                for existing in roots do
                    if abs(rootValue - existing) <
                       10^(-max(8, iquo(effectiveDigits, 2))) then
                        duplicate := true; break;
                    end if;
                end do;
                if not duplicate then roots := [op(roots), rootValue]; end if;
            end do;
        end do;
    finally
        Digits := oldDigits;
    end try;
    return roots;
end proc;

DistanceToUnitInterval := proc(rootValue)
    local realPart, imaginaryPart;
    realPart := Re(rootValue); imaginaryPart := Im(rootValue);
    if realPart < 0 then
        return abs(rootValue);
    elif realPart > 1 then
        return abs(rootValue - 1);
    end if;
    return abs(imaginaryPart);
end proc;

SegmentSafety := proc(system, segmentStart::list, segmentEnd::list,
                      digits::posint, clearance)
    local roots, minimumDistance, rootValue;
    roots := RestrictedSingularRoots(system, segmentStart, segmentEnd,
        'digits' = digits);
    minimumDistance := infinity;
    for rootValue in roots do
        minimumDistance := min(minimumDistance,
            DistanceToUnitInterval(rootValue));
    end do;
    return [evalb(minimumDistance > clearance), minimumDistance, roots];
end proc;

HomotopyShortcutSampled := proc(system, leftPoint::list, middlePoint::list,
                             rightPoint::list, digits::posint,
                             samples::posint, clearance)
    local divisor, s, u, oldPoint, newPoint, point, determinantValue,
          scale, segmentCheck, i, j, k;
    segmentCheck := SegmentSafety(system, leftPoint, rightPoint,
        digits, clearance);
    if not segmentCheck[1] then return false; end if;
    divisor := SingularFactors(system);
    scale := 1;
    for j from 0 to samples do
        s := evalf(j / samples);
        if s <= 1/2 then
            oldPoint := [seq(leftPoint[i] + 2*s*(middlePoint[i]-leftPoint[i]),
                i = 1 .. nops(leftPoint))];
        else
            oldPoint := [seq(middlePoint[i] + 2*(s-1/2)*(rightPoint[i]-middlePoint[i]),
                i = 1 .. nops(leftPoint))];
        end if;
        newPoint := [seq(leftPoint[i] + s*(rightPoint[i]-leftPoint[i]),
            i = 1 .. nops(leftPoint))];
        for k from 0 to samples do
            u := evalf(k / samples);
            point := [seq((1-u)*oldPoint[i] + u*newPoint[i],
                i = 1 .. nops(leftPoint))];
            determinantValue := evalf(subs(seq(divisor:-variables[i] = point[i],
                i = 1 .. nops(point)), divisor:-determinant));
            scale := max(scale, abs(determinantValue));
            if abs(determinantValue) <= clearance * scale then return false; end if;
        end do;
    end do;
    return true;
end proc;

MakeCanonicalPath := proc(system, startPoint::list, targetPoint::list,
                          digits::posint, branchSide::integer, clearance)
    local directCheck, side, amplitude, midpoint, candidate,
          firstCheck, secondCheck, coordinate, i;
    directCheck := SegmentSafety(system, startPoint, targetPoint,
        digits, clearance);
    if directCheck[1] then return [startPoint, targetPoint]; end if;
    if branchSide = 0 then
        error "a singular direct segment requires branchSide=-1 or branchSide=1";
    end if;
    side := branchSide;
    amplitude := max(0.15, add(abs(targetPoint[i]-startPoint[i]),
        i = 1 .. nops(startPoint)) / max(1, nops(startPoint)));
    for coordinate to nops(startPoint) do
        midpoint := [seq((startPoint[i] + targetPoint[i])/2,
            i = 1 .. nops(startPoint))];
        midpoint[coordinate] := midpoint[coordinate] +
            side * I * amplitude;
        candidate := [startPoint, midpoint, targetPoint];
        firstCheck := SegmentSafety(system, candidate[1], candidate[2],
            digits, clearance);
        secondCheck := SegmentSafety(system, candidate[2], candidate[3],
            digits, clearance);
        if firstCheck[1] and secondCheck[1] then return candidate; end if;
    end do;
    error "a canonical detour on the requested branchSide avoiding the detected singular divisor was not found";
end proc;

ReversePath := proc(pathOrPlan)
    local points, result, i;
    if type(pathOrPlan, record) and
       evalb(pathOrPlan:-hpType = "PfaffianPathPlan") then
        points := pathOrPlan:-points;
    else
        points := pathOrPlan;
    end if;
    result := [];
    for i from nops(points) by -1 to 1 do
        result := [op(result), points[i]];
    end do;
    return result;
end proc;

PlanPath := proc(
    system,
    startPoint::list,
    targetPoint::list,
    {pathClass := "principal", mode := "safe_opt", waypoints := [],
     branchSide := -1, digits := 0, homotopySamples := 10,
     clearance := 1.e-10}
)
    local effectiveDigits, path, point, candidate, removed,
          changed, i, beforeCount, checks, segmentIndex,
          checkValue, diagnostics;
    if not member(mode, ["canonical", "user", "safe_opt", "fast_opt"]) then
        error "planner mode must be canonical, user, safe_opt, or fast_opt";
    end if;
    if not member(branchSide, [-1, 0, 1]) then
        error "branchSide must be -1, 0, or 1";
    end if;
    if nops(startPoint) <> SystemNVariables(system) or
       nops(targetPoint) <> SystemNVariables(system) then
        error "a path endpoint has the wrong length";
    end if;
    effectiveDigits := `if`(digits = 0, system:-digits, digits);
    if nops(waypoints) = 0 then
        if mode = "user" then
            path := [map(evalf,startPoint),map(evalf,targetPoint)];
        else
            path := MakeCanonicalPath(system, map(evalf, startPoint),
                map(evalf, targetPoint), effectiveDigits, branchSide, clearance);
        end if;
    else
        path := [map(evalf, startPoint)];
        for point in waypoints do
            if nops(point) <> nops(startPoint) then
                error "a path waypoint has the wrong length";
            end if;
            path := [op(path), map(evalf, point)];
        end do;
        path := [op(path), map(evalf, targetPoint)];
    end if;
    beforeCount := nops(path) - 1; removed := 0;
    if mode = "fast_opt" and nops(path) > 2 then
        changed := true;
        while changed do
            changed := false;
            for i from 2 to nops(path) - 1 do
                if HomotopyShortcutSampled(system, path[i-1], path[i], path[i+1],
                    effectiveDigits, homotopySamples, clearance) then
                    candidate := [op(path[1 .. i-1]), op(path[i+1 .. -1])];
                    path := candidate; removed := removed + 1;
                    changed := true; break;
                end if;
            end do;
        end do;
    end if;
    checks := [];
    for segmentIndex to nops(path)-1 do
        checkValue := SegmentSafety(system, path[segmentIndex],
            path[segmentIndex+1], effectiveDigits, clearance);
        if not checkValue[1] then
            error "planned segment %1 intersects or approaches the detected singular divisor", segmentIndex;
        end if;
        checks := [op(checks), MakeSegmentCheckRecord(segmentIndex,
            checkValue[2], checkValue[3])];
    end do;
    diagnostics := MakePlanDiagnosticsRecord(beforeCount, nops(path)-1,
        removed, checks, `if`(mode = "safe_opt",
        "not_certified_no_change", `if`(mode = "fast_opt",
        "sampled_unverified", "not-requested")));
    return MakePathPlanRecord(path[1], path[-1], path, mode,
        convert(pathClass, string), diagnostics);
end proc;

# ---------------------------------------------------------------------------
# Defining series and boundary values
# ---------------------------------------------------------------------------

RisingFactorial := proc(value, order::integer)
    local result, offset, distance;
    result := 1;
    if order >= 0 then
        for offset from 0 to order - 1 do result := result * (value + offset); end do;
    else
        for distance to -order do result := result / (value - distance); end do;
    end if;
    return evalf(result);
end proc;

FallingFactorial := proc(value::nonnegint, order::nonnegint)
    local result, offset;
    if order > value then return 0; end if;
    result := 1;
    for offset from 0 to order - 1 do result := result * (value - offset); end do;
    return result;
end proc;

SeriesCoefficient := proc(series, index::list)
    local result, i, order;
    result := 1;
    for i to nops(series:-upperParameters) do
        order := WeightDot(series:-upperWeights[i], index);
        result := result * RisingFactorial(series:-upperParameters[i], order);
    end do;
    for i to nops(series:-lowerParameters) do
        order := WeightDot(series:-lowerWeights[i], index);
        result := result / RisingFactorial(series:-lowerParameters[i], order);
    end do;
    for i to nops(index) do result := result / index[i]!; end do;
    return evalf(result);
end proc;

# Cancel only identical Pochhammer factors with identical weight rows.  The
# comparison is made before numerical conversion, so a near cancellation is
# never promoted to an exact cancellation.
CancelExactSeriesParameters := proc(series)
    local upperParameters,upperWeights,lowerParameters,lowerWeights,
          keptUpperParameters,keptUpperWeights,keptLowerParameters,
          keptLowerWeights,usedLower,equalParameters,i,j;
    upperParameters := series:-upperParameters;
    upperWeights := series:-upperWeights;
    lowerParameters := series:-lowerParameters;
    lowerWeights := series:-lowerWeights;
    usedLower := Array(1..nops(lowerParameters),fill=false);
    keptUpperParameters := []; keptUpperWeights := [];
    for i to nops(upperParameters) do
        equalParameters := false;
        for j to nops(lowerParameters) do
            if usedLower[j] or not evalb(upperWeights[i]=lowerWeights[j]) then
                next;
            end if;
            try
                equalParameters := evalb(normal(upperParameters[i]-lowerParameters[j])=0);
            catch:
                equalParameters := evalb(upperParameters[i]=lowerParameters[j]);
            end try;
            if equalParameters then
                usedLower[j] := true;
                break;
            end if;
        end do;
        if not equalParameters then
            keptUpperParameters := [op(keptUpperParameters),upperParameters[i]];
            keptUpperWeights := [op(keptUpperWeights),upperWeights[i]];
        end if;
    end do;
    keptLowerParameters := []; keptLowerWeights := [];
    for j to nops(lowerParameters) do
        if not usedLower[j] then
            keptLowerParameters := [op(keptLowerParameters),lowerParameters[j]];
            keptLowerWeights := [op(keptLowerWeights),lowerWeights[j]];
        end if;
    end do;
    return MakeNumericHornRecord(series:-name,series:-nvariables,
        keptUpperParameters,keptUpperWeights,
        keptLowerParameters,keptLowerWeights);
end proc;

NumericParameterSeries := proc(series)
    return MakeNumericHornRecord(series:-name,series:-nvariables,
        map(evalf,series:-upperParameters),series:-upperWeights,
        map(evalf,series:-lowerParameters),series:-lowerWeights);
end proc;

ExactNonpositiveIntegerDegree := proc(value)
    if type(value,integer) and value<=0 then return -value; end if;
    return infinity;
end proc;

# A total-degree termination is available when an upper Pochhammer parameter
# with the all-one weight row is an exact nonpositive integer.
ExactTotalTerminationDegree := proc(series)
    local degreeValue,candidate,i;
    degreeValue := infinity;
    for i to nops(series:-upperParameters) do
        if andmap(value->evalb(value=1),series:-upperWeights[i]) then
            candidate := ExactNonpositiveIntegerDegree(series:-upperParameters[i]);
            if candidate<>infinity then degreeValue := min(degreeValue,candidate); end if;
        end if;
    end do;
    return degreeValue;
end proc;

# Nonnegative upper-weight rows with exact nonpositive parameters impose
# linear bounds on the support.  Bounding every coordinate separately gives
# a conservative finite total degree; the all-one bound above is retained
# when it is sharper.
ExactFiniteSupportDegree := proc(series)
    local degreeValue,coordinateBounds,parameterDegree,weights,
          candidate,i,j;
    degreeValue := ExactTotalTerminationDegree(series);
    coordinateBounds := [seq(infinity,j=1..series:-nvariables)];
    for i to nops(series:-upperParameters) do
        parameterDegree := ExactNonpositiveIntegerDegree(
            series:-upperParameters[i]);
        if parameterDegree=infinity then next; end if;
        weights := series:-upperWeights[i];
        if not andmap(weight->evalb(weight>=0),weights) then next; end if;
        if andmap(weight->evalb(weight>0),weights) then
            degreeValue := min(degreeValue,
                floor(parameterDegree/min(op(weights))));
        end if;
        for j to series:-nvariables do
            if weights[j]>0 then
                coordinateBounds[j] := min(coordinateBounds[j],
                    floor(parameterDegree/weights[j]));
            end if;
        end do;
    end do;
    if andmap(bound->evalb(bound<>infinity),coordinateBounds) then
        candidate := add(coordinateBounds[j],j=1..series:-nvariables);
        degreeValue := min(degreeValue,candidate);
    end if;
    return degreeValue;
end proc;

# Estimate the final dense Macaulay matrix before constructing it.  The hard
# gate is deliberately below the regime in which Maple can spend minutes or
# hours materialising a reduction with no useful progress report.
GenericPfaffianCostEstimate := proc(series,maximumSeed)
    local base,orders,maximumBasisOrder,initialSeed,finalSeed,n,
          columns,equations,cells,i;
    n := series:-nvariables;
    base := BasePDEs(series); orders := base[2];
    maximumBasisOrder := add(max(orders[i]-1,0),i=1..nops(orders));
    initialSeed := maximumBasisOrder+`if`(nops(convert(orders,set))=1,1,2);
    finalSeed := `if`(maximumSeed=0,max(initialSeed+4,8),maximumSeed);
    columns := binomial(finalSeed+n,n);
    equations := n*binomial(finalSeed+n,n);
    cells := columns*equations;
    return [cells,columns,equations,initialSeed,finalSeed];
end proc;

EnsureGenericPfaffianSafe := proc(series,maximumSeed)
    local estimate;
    if series:-nvariables>3 then
        error "generic Pfaffian construction is disabled above three variables; use a specialized connection or a convergent series method";
    end if;
    estimate := GenericPfaffianCostEstimate(series,maximumSeed);
    if estimate[5]>12 or estimate[2]>600 or estimate[1]>3000000 then
        error "generic Pfaffian construction exceeds the resource gate (seed %1, columns %2, estimated cells %3)",estimate[5],estimate[2],estimate[1];
    end if;
    return estimate;
end proc;

HypergeometricRoundingAllowance := proc(value,digits::posint)
    return evalf[digits+4](10^(1-digits)*max(abs(value),1));
end proc;

HypergeometricSeriesDegree := proc(radius,digits::posint)
    if radius=0 then return 8; end if;
    if radius>=1 then return infinity; end if;
    return max(16,ceil((digits+12)*evalf(ln(10))/(-evalf(ln(radius)))+12));
end proc;

# Maple floats retain a decimal mantissa whose precision can exceed the
# current Digits setting.  Inspect that stored mantissa before performing any
# arithmetic, since lowering Digits first can erase a small displacement from
# a nearby integer even though the input float still contains it.
StoredNumericDigits := proc(value)
    local result,realPart,imaginaryPart;
    result := 0;
    try
        if type(value,float) then
            return length(op(1,value));
        end if;
        if type(value,numeric) or type(value,complex) then
            realPart := Re(value); imaginaryPart := Im(value);
            if type(realPart,float) then
                result := max(result,length(op(1,realPart)));
            end if;
            if type(imaginaryPart,float) then
                result := max(result,length(op(1,imaginaryPart)));
            end if;
        end if;
    catch:
        return result;
    end try;
    return result;
end proc;

HypergeometricSourceDigits := proc(series,target::list,waypoints::list,epsilon)
    local result,parameterValue,value,point;
    result := StoredNumericDigits(epsilon);
    for parameterValue in
        [op(series:-upperParameters),op(series:-lowerParameters)] do
        result := max(result,
            StoredNumericDigits(parameterValue:-constant),
            StoredNumericDigits(parameterValue:-slope));
    end do;
    for value in target do
        result := max(result,StoredNumericDigits(value));
    end do;
    for point in waypoints do
        for value in point do
            result := max(result,StoredNumericDigits(value));
        end do;
    end do;
    return result;
end proc;

# Preserve exact perturbations of nonpositive integral parameters throughout
# every numerical kernel.  A lower parameter such as -100+10^(-100) is
# regular, but evaluating it at ordinary guard precision rounds it onto a
# pole and can also hide the coefficient surge immediately after degree 100.
HypergeometricConditioningGuardDigits := proc(series,target::list)
    local oldDigits,parameterMagnitude,magnitudeGuard,separationGuard,
          parameterValue,nearestInteger,candidate,ratio,scale,i,j,
          guardDigits;
    oldDigits := Digits; Digits := max(oldDigits,30);
    magnitudeGuard := 0; separationGuard := 0;
    try
        parameterMagnitude := add(abs(evalf(parameterValue)),parameterValue in
            [op(series:-upperParameters),op(series:-lowerParameters)]);
        if IsFiniteNumber(parameterMagnitude) and parameterMagnitude>1 then
            magnitudeGuard := ceil(evalf(ln(parameterMagnitude)/ln(10)));
        end if;
        for parameterValue in
            [op(series:-upperParameters),op(series:-lowerParameters)] do
            # Use the Euclidean complex distance to the nearest integer on the
            # nonpositive real axis.  Testing Im(parameterValue)=0 first loses
            # a diagonal perturbation such as -2+10^(-80)+I*10^(-80): at low
            # precision its real displacement rounds away while the imaginary
            # displacement remains, changing the phase of the pole residue.
            nearestInteger := round(Re(parameterValue));
            candidate := parameterValue-nearestInteger;
            if nearestInteger<=0 and not evalb(candidate=0) then
                ratio := evalf(max(1,abs(parameterValue))/abs(candidate));
                if IsFiniteNumber(ratio) and ratio>1 then
                    separationGuard := max(separationGuard,
                        ceil(evalf(ln(ratio)/ln(10))));
                end if;
            end if;
        end do;
        if nops(target)>0 then
            scale := max(1,seq(abs(evalf(target[i])),i=1..nops(target)));
            for i to nops(target) do
                candidate := 1-target[i];
                if not evalb(candidate=0) then
                    ratio := evalf(scale/abs(candidate));
                    if IsFiniteNumber(ratio) and ratio>1 then
                        separationGuard := max(separationGuard,
                            ceil(evalf(ln(ratio)/ln(10))));
                    end if;
                end if;
                for j from i+1 to nops(target) do
                    candidate := target[i]-target[j];
                    if not evalb(candidate=0) then
                        ratio := evalf(scale/abs(candidate));
                        if IsFiniteNumber(ratio) and ratio>1 then
                            separationGuard := max(separationGuard,
                                ceil(evalf(ln(ratio)/ln(10))));
                        end if;
                    end if;
                end do;
            end do;
        end if;
    catch:
        magnitudeGuard := max(magnitudeGuard,0);
        separationGuard := max(separationGuard,0);
    finally
        Digits := oldDigits;
    end try;
    guardDigits := magnitudeGuard+separationGuard;
    if guardDigits>4096 then
        error "the hypergeometric conditioning guard exceeds 4096 digits";
    end if;
    return max(0,guardDigits);
end proc;

# A convergent series must be evaluated beyond a nearby lower-parameter pole;
# otherwise a small prefix can precede a large regular coefficient.  The
# returned total degree is conservative for every positive weight row.
HypergeometricTransientDegree := proc(series)
    local transientDegree,parameterValue,nearestInteger,candidate,
          candidateMagnitude,maximumWeight,i,j;
    transientDegree := 0;
    for i to nops(series:-lowerParameters) do
        parameterValue := series:-lowerParameters[i];
        try
            nearestInteger := round(Re(parameterValue));
            candidate := parameterValue-nearestInteger;
            candidateMagnitude := evalf(abs(candidate));
            if nearestInteger>0 or evalb(candidate=0) or
               not IsFiniteNumber(candidateMagnitude) or
               candidateMagnitude>=1/10 then next; end if;
            maximumWeight := max(0,seq(series:-lowerWeights[i][j],
                j=1..series:-nvariables));
            if maximumWeight>0 then
                transientDegree := max(transientDegree,
                    ceil((1-nearestInteger)/maximumWeight));
            end if;
        catch:
            next;
        end try;
    end do;
    return transientDegree;
end proc;

# Exact polynomial identities avoid catastrophic binomial cancellation.  The
# first case is 1F0(-n;;z)=(1-z)^n.  The second is Chu--Vandermonde for a
# terminating Gauss function at z=1.  Both derivatives are evaluated from
# their exact finite products, without a parameter quotient of the form 0/0.
PFQExactClosedFormVector := proc(exactSeries,z)
    local upper,lower,values,n,terminatingIndex,other,c,numerator,
          denominator,derivativeNumerator,derivativeDenominator,k;
    upper := exactSeries:-upperParameters;
    lower := exactSeries:-lowerParameters;
    values := Vector(2,datatype=anything);
    if nops(upper)=1 and nops(lower)=0 and
       type(upper[1],integer) and upper[1]<=0 then
        n := -upper[1];
        values[1] := evalf((1-z)^n);
        values[2] := `if`(n=0,0,evalf(-n*(1-z)^(n-1)));
        return [true,values,"exact_binomial"];
    end if;
    if nops(upper)<>2 or nops(lower)<>1 or not evalb(z=1) then
        return [false,Vector(0,datatype=anything),"not_applicable"];
    end if;
    terminatingIndex := 0;
    if type(upper[1],integer) and upper[1]<=0 then terminatingIndex := 1;
    elif type(upper[2],integer) and upper[2]<=0 then terminatingIndex := 2;
    end if;
    if terminatingIndex=0 then
        return [false,Vector(0,datatype=anything),"not_applicable"];
    end if;
    n := -upper[terminatingIndex];
    other := upper[3-terminatingIndex]; c := lower[1];
    numerator := 1; denominator := 1;
    for k from 0 to n-1 do
        numerator := numerator*(c-other+k);
        denominator := denominator*(c+k);
    end do;
    if evalb(denominator=0) then
        error "Chu--Vandermonde encountered an uncancelled singular lower parameter";
    end if;
    values[1] := evalf(numerator/denominator);
    if n=0 then
        values[2] := 0;
    else
        derivativeNumerator := 1; derivativeDenominator := 1;
        for k from 0 to n-2 do
            derivativeNumerator := derivativeNumerator*(c-other+k);
            derivativeDenominator := derivativeDenominator*(c+1+k);
        end do;
        values[2] := evalf(upper[terminatingIndex]*other/c*
            derivativeNumerator/derivativeDenominator);
    end if;
    return [true,values,"chu_vandermonde"];
end proc;

# O(D p) recurrence for the generalized pF(p-1) series.  The derivative is
# accumulated from the same terms, including at z=0 where division by z would
# be invalid.
PFQFastSeriesVector := proc(series,z,digits::posint,maximumDegree::nonnegint,
                            terminationDegree)
    local values,term,derivativeValue,coefficientRatio,derivativeTerm,
          degree,parameter,rhoScalar,rhoDerivative,tailEstimate,
          parameterMagnitude,valueNorm,tolerance;
    values := Vector(2,datatype=anything); values[1] := 1; values[2] := 0;
    if terminationDegree=0 then return [values,true,0,0]; end if;
    if z=0 then
        coefficientRatio := 1;
        for parameter in series:-upperParameters do coefficientRatio := coefficientRatio*parameter; end do;
        for parameter in series:-lowerParameters do
            if evalb(parameter=0) then error "the generalized hypergeometric series has a singular lower parameter"; end if;
            coefficientRatio := coefficientRatio/parameter;
        end do;
        values[2] := evalf(coefficientRatio);
        return [values,true,0,0];
    end if;
    term := 1; derivativeValue := 0; tailEstimate := infinity;
    tolerance := evalf(10^(-(digits+6)));
    parameterMagnitude := max(1,seq(abs(parameter),parameter in
        [op(series:-upperParameters),op(series:-lowerParameters)]));
    for degree to maximumDegree do
        coefficientRatio := 1/degree;
        for parameter in series:-upperParameters do
            coefficientRatio := coefficientRatio*(parameter+degree-1);
        end do;
        for parameter in series:-lowerParameters do
            if evalb(parameter+degree-1=0) then
                error "the generalized hypergeometric series has a singular lower parameter at degree %1",degree;
            end if;
            coefficientRatio := coefficientRatio/(parameter+degree-1);
        end do;
        derivativeTerm := evalf(term*degree*coefficientRatio);
        term := evalf(term*z*coefficientRatio);
        derivativeValue := evalf(derivativeValue+derivativeTerm);
        values[1] := evalf(values[1]+term); values[2] := derivativeValue;
        if not IsFiniteNumber(term) or not IsFiniteNumber(derivativeValue) or
           not IsFiniteNumber(values[1]) then
            return [values,false,degree,infinity];
        end if;
        if terminationDegree<>infinity and degree>=terminationDegree then
            return [values,true,degree,0];
        end if;
        if degree>parameterMagnitude+4 and degree>=8 then
            rhoScalar := abs(z);
            for parameter in series:-upperParameters do
                rhoScalar := rhoScalar*(degree+abs(parameter));
            end do;
            for parameter in series:-lowerParameters do
                rhoScalar := rhoScalar/max(degree-abs(parameter),1/10);
            end do;
            rhoScalar := evalf(rhoScalar/(degree+1));
            rhoDerivative := evalf(rhoScalar*(degree+1)/degree);
            if rhoDerivative<1 then
                tailEstimate := evalf(max(abs(term),abs(derivativeTerm))*
                    rhoDerivative/(1-rhoDerivative));
                valueNorm := max(abs(values[1]),abs(values[2]),1);
                if tailEstimate<=tolerance*valueNorm then
                    return [values,true,degree,tailEstimate];
                end if;
            end if;
        end if;
    end do;
    return [values,false,maximumDegree,tailEstimate];
end proc;

PFQExactTerminationAndPoleCheck := proc(exactSeries)
    local terminationDegree,lowerPole,parameter;
    terminationDegree := ExactTotalTerminationDegree(exactSeries);
    lowerPole := infinity;
    for parameter in exactSeries:-lowerParameters do
        if type(parameter,integer) and parameter<=0 then
            lowerPole := min(lowerPole,1-parameter);
        end if;
    end do;
    if lowerPole<>infinity and
       (terminationDegree=infinity or terminationDegree>=lowerPole) then
        error "the generalized hypergeometric series has an uncancelled singular lower parameter";
    end if;
    return terminationDegree;
end proc;

PFQFastSeriesChecked := proc(exactSeries,z,digits::posint,
                             maximumDegree::posint)
    local terminationDegree,effectiveDegree,
          oldDigits,lower,current,previous,discrepancy,tolerance,i,guardDigits,
          operationCount,precisionOffsets,attempt,workingPrecision,stable,
          certificate,precisionRerun;
    terminationDegree := PFQExactTerminationAndPoleCheck(exactSeries);
    if terminationDegree<>infinity and terminationDegree>maximumDegree then
        error "the terminating generalized hypergeometric series needs degree %1, above maximumDegree=%2",terminationDegree,maximumDegree;
    end if;
    effectiveDegree := `if`(terminationDegree=infinity,maximumDegree,terminationDegree);
    operationCount := (effectiveDegree+1)*
        (nops(exactSeries:-upperParameters)+
         nops(exactSeries:-lowerParameters)+4);
    if operationCount>20000000 then
        error "the generalized hypergeometric recurrence exceeds its twenty-million-operation resource gate";
    end if;
    guardDigits := HypergeometricConditioningGuardDigits(exactSeries,[z]);
    oldDigits := Digits; tolerance := evalf(10^(-(digits+3)));
    precisionOffsets := [14,24,56,120,248,504,1016,2040,4088];
    stable := false; attempt := 2; precisionRerun := false;
    try
        Digits := digits+guardDigits+precisionOffsets[1];
        lower := PFQFastSeriesVector(NumericParameterSeries(exactSeries),
            evalf(z),digits,effectiveDegree,terminationDegree);
        previous := lower;
        Digits := digits+guardDigits+precisionOffsets[2];
        current := PFQFastSeriesVector(NumericParameterSeries(exactSeries),
            evalf(z),digits,effectiveDegree,terminationDegree);
        workingPrecision := digits+guardDigits+precisionOffsets[2];
        discrepancy := max(seq(abs(current[1][i]-lower[1][i]),i=1..2));
        if current[2] and lower[2] and discrepancy<=tolerance*
           max(seq(abs(current[1][i]),i=1..2),1) then
            stable := true;
        end if;
        # Exact finite sums and large opposing parameters can lose hundreds of
        # digits even though both ordinary guard precisions are finite.  Raise
        # precision until two independently rounded complete sums agree.  The
        # finite ladder is capped, so an unresolved computation still fails
        # closed instead of falling through to an uncertified continuation.
        for attempt from 3 to nops(precisionOffsets) while not stable do
            if not current[2] then break; end if;
            precisionRerun := true;
            previous := current;
            Digits := digits+guardDigits+precisionOffsets[attempt];
            workingPrecision := Digits;
            current := PFQFastSeriesVector(NumericParameterSeries(exactSeries),
                evalf(z),digits,effectiveDegree,terminationDegree);
            discrepancy := max(seq(abs(current[1][i]-previous[1][i]),i=1..2));
            if current[2] and previous[2] and discrepancy<=tolerance*
               max(seq(abs(current[1][i]),i=1..2),1) then
                stable := true;
            end if;
        end do;
    finally
        Digits := oldDigits;
    end try;
    if stable then
        certificate := `if`(terminationDegree=infinity,
            `if`(not precisionRerun,"majorant","majorant_and_precision_rerun"),
            `if`(not precisionRerun,"exact_termination",
                "precision_rerun_exact_termination"));
        return [current[1],true,current[3],max(current[4],discrepancy),
            discrepancy,workingPrecision,certificate];
    end if;
    return [current[1],false,current[3],current[4],discrepancy,
        workingPrecision,"precision_unstable"];
end proc;

PFQNativeValue := proc(exactSeries,z,digits::posint)
    local upper,lower,value,derivativeValue,prefactor,parameter;
    upper := exactSeries:-upperParameters; lower := exactSeries:-lowerParameters;
    value := evalf[digits+8](hypergeom(upper,lower,z));
    prefactor := mul(parameter,parameter in upper)/
        mul(parameter,parameter in lower);
    derivativeValue := evalf[digits+8](prefactor*
        hypergeom(map(parameter->parameter+1,upper),
                  map(parameter->parameter+1,lower),z));
    if not IsFiniteNumber(value) or not IsFiniteNumber(derivativeValue) then
        error "Maple's native hypergeometric evaluator did not return a finite value";
    end if;
    return Vector([value,derivativeValue],datatype=anything);
end proc;

# Compute c_(m+e_j)/c_m directly from the Pochhammer shifts.  This neighbor
# recurrence supports the negative weights occurring in Horn's G and H
# families and avoids recomputing every Pochhammer product from the origin.
SmallIntegerPochhammer := proc(base,shift::integer)
    if shift=0 then return 1;
    elif shift=1 then return base;
    elif shift=2 then return base*(base+1);
    elif shift=-1 then return 1/(base-1);
    elif shift=-2 then return 1/((base-1)*(base-2));
    end if;
    return RisingFactorial(base,shift);
end proc;

HornCoefficientStep := proc(series,previousIndex::list,variable::posint)
    local ratio,parameter,weights,shift,i;
    ratio := 1/(previousIndex[variable]+1);
    for i to nops(series:-upperParameters) do
        parameter := series:-upperParameters[i]; weights := series:-upperWeights[i];
        shift := weights[variable];
        ratio := ratio*SmallIntegerPochhammer(
            parameter+WeightDot(weights,previousIndex),shift);
    end do;
    for i to nops(series:-lowerParameters) do
        parameter := series:-lowerParameters[i]; weights := series:-lowerWeights[i];
        shift := weights[variable];
        ratio := ratio/SmallIntegerPochhammer(
            parameter+WeightDot(weights,previousIndex),shift);
    end do;
    return evalf(ratio);
end proc;

HornFastGridVector := proc(series,target::list,digits::posint,
                           maximumDegree::nonnegint,terminationDegree,
                           computeDerivatives::boolean := true,
                           checkpointDegree := -1)
    local n,coefficients,values,zero,index,previousIndex,coefficient,
          candidate,ratio,term,derivativeTerm,shellNorm,previousShell,
          shellRatios,rho,tailEstimate,valueNorm,tolerance,degree,
          variable,found,i,checkpointValues,checkpointCaptured;
    n := series:-nvariables;
    if binomial(maximumDegree+n,n)>2000000 then
        error "the neighbor-ratio series exceeds its two-million-term resource gate";
    end if;
    coefficients := table(); zero := ZeroIndex(n); coefficients[zero] := 1;
    values := Vector(n+1,datatype=anything); values[1] := 1;
    checkpointValues := Vector(n+1,datatype=anything);
    checkpointCaptured := false;
    if checkpointDegree=0 then
        checkpointValues := map(entry->entry,values); checkpointCaptured := true;
    end if;
    previousShell := 0; shellRatios := []; tailEstimate := infinity;
    tolerance := evalf(10^(-(digits+6)));
    if maximumDegree=0 then
        return [values,evalb(terminationDegree=0),0,
            `if`(terminationDegree=0,0,infinity),values];
    end if;
    for degree to maximumDegree do
        shellNorm := 0;
        for index in Compositions(degree,n) do
            found := false; coefficient := 0;
            for variable to n do
                if index[variable]=0 then next; end if;
                previousIndex := subsop(variable=index[variable]-1,index);
                if not assigned(coefficients[previousIndex]) then next; end if;
                try
                    ratio := HornCoefficientStep(series,previousIndex,variable);
                    candidate := evalf(coefficients[previousIndex]*ratio);
                    if IsFiniteNumber(candidate) then
                        coefficient := candidate; found := true; break;
                    end if;
                catch:
                    found := false;
                end try;
            end do;
            if not found then
                try
                    coefficient := SeriesCoefficient(series,index);
                    found := IsFiniteNumber(coefficient);
                catch:
                    found := false;
                end try;
            end if;
            if not found then return [values,false,degree,infinity,values]; end if;
            coefficients[index] := coefficient;
            term := coefficient;
            for variable to n do
                if index[variable]<>0 then
                    term := term*target[variable]^index[variable];
                end if;
            end do;
            term := evalf(term); values[1] := evalf(values[1]+term);
            shellNorm := shellNorm+abs(term);
            if computeDerivatives then
                for variable to n do
                    if index[variable]=0 then next; end if;
                    derivativeTerm := coefficient*index[variable];
                    for i to n do
                        if index[i]-`if`(i=variable,1,0)<>0 then
                            derivativeTerm := derivativeTerm*
                                target[i]^(index[i]-`if`(i=variable,1,0));
                        end if;
                    end do;
                    derivativeTerm := evalf(derivativeTerm);
                    values[variable+1] := evalf(values[variable+1]+derivativeTerm);
                    shellNorm := shellNorm+abs(derivativeTerm);
                end do;
            end if;
        end do;
        if degree=checkpointDegree then
            checkpointValues := map(entry->entry,values); checkpointCaptured := true;
        end if;
        if not andmap(IsFiniteNumber,[seq(values[i],i=1..n+1)]) then
            return [values,false,degree,infinity,
                `if`(checkpointCaptured,checkpointValues,values)];
        end if;
        if terminationDegree<>infinity and degree>=terminationDegree then
            return [values,true,degree,0,
                `if`(checkpointCaptured,checkpointValues,values)];
        end if;
        if previousShell>0 then
            shellRatios := [op(shellRatios),evalf(shellNorm/previousShell)];
            if nops(shellRatios)>8 then shellRatios := shellRatios[2..-1]; end if;
        end if;
        previousShell := shellNorm;
    end do;
    if nops(shellRatios)>=6 then
        rho := evalf(6/5*max(op(shellRatios)));
        if rho<1 then
            tailEstimate := evalf(previousShell*rho/(1-rho));
            valueNorm := max(seq(abs(values[i]),i=1..n+1),1);
            if maximumDegree>=16 and tailEstimate<=tolerance*valueNorm then
                return [values,true,maximumDegree,tailEstimate,
                    `if`(checkpointCaptured,checkpointValues,values)];
            end if;
        end if;
    end if;
    return [values,false,maximumDegree,tailEstimate,
        `if`(checkpointCaptured,checkpointValues,values)];
end proc;

HornFastGridChecked := proc(exactSeries,target::list,digits::posint,
                            maximumDegree::posint,comparisonDegree := -1,
                            computeDerivatives::boolean := true)
    local terminationDegree,effectiveDegree,lowerDegree,oldDigits,
          current,previous,lowerPrecision,degreeDifference,precisionDifference,
          tolerance,valueNorm,n,i,numberOfComponents,guardDigits,
          precisionOffsets,attempt,workingPrecision,precisionStable,
          precisionRerun;
    n := exactSeries:-nvariables;
    terminationDegree := ExactFiniteSupportDegree(exactSeries);
    if terminationDegree<>infinity and terminationDegree>maximumDegree then
        error "the terminating Horn series needs degree %1, above maximumDegree=%2",terminationDegree,maximumDegree;
    end if;
    effectiveDegree := `if`(terminationDegree=infinity,maximumDegree,terminationDegree);
    if binomial(effectiveDegree+n,n)>2000000 then
        error "the neighbor-ratio series exceeds its two-million-term resource gate";
    end if;
    lowerDegree := `if`(terminationDegree=infinity,
        `if`(comparisonDegree<0,max(8,floor(effectiveDegree/2)),comparisonDegree),
        effectiveDegree);
    if terminationDegree=infinity and lowerDegree+8>effectiveDegree then
        return [Vector(n+1,datatype=anything),false,effectiveDegree,
            infinity,infinity,infinity,digits,"insufficient_degree"];
    end if;
    numberOfComponents := `if`(computeDerivatives,n+1,1);
    guardDigits := HypergeometricConditioningGuardDigits(exactSeries,target);
    oldDigits := Digits; tolerance := evalf(10^(-(digits+3)));
    precisionOffsets := [14,24,56,120,248,504,1016,2040,4088];
    precisionStable := false; attempt := 2; precisionRerun := false;
    try
        Digits := digits+guardDigits+precisionOffsets[1];
        lowerPrecision := HornFastGridVector(NumericParameterSeries(exactSeries),
            map(evalf,target),digits,lowerDegree,terminationDegree,
            computeDerivatives,lowerDegree);
        Digits := digits+guardDigits+precisionOffsets[2];
        current := HornFastGridVector(NumericParameterSeries(exactSeries),
            map(evalf,target),digits,effectiveDegree,terminationDegree,
            computeDerivatives,lowerDegree);
        workingPrecision := Digits;
        degreeDifference := max(seq(abs(current[1][i]-current[5][i]),
            i=1..numberOfComponents));
        precisionDifference := max(seq(
            abs(current[5][i]-lowerPrecision[1][i]),i=1..numberOfComponents));
        valueNorm := max(seq(abs(current[1][i]),i=1..numberOfComponents),1);
        precisionStable := evalb(current[2] and lowerPrecision[2] and
            precisionDifference<=tolerance*valueNorm and
            (terminationDegree<>infinity or
             degreeDifference<=tolerance*valueNorm));
        # If the initial comparison fails, compare complete grids at a precision
        # ladder.  This catches cancellation that appears after the checkpoint,
        # while a stable full-grid comparison followed by a persistent degree
        # discrepancy remains an honest truncation failure.
        for attempt from 3 to nops(precisionOffsets) while not precisionStable do
            if not current[2] then break; end if;
            precisionRerun := true;
            previous := current;
            Digits := digits+guardDigits+precisionOffsets[attempt];
            workingPrecision := Digits;
            current := HornFastGridVector(NumericParameterSeries(exactSeries),
                map(evalf,target),digits,effectiveDegree,terminationDegree,
                computeDerivatives,lowerDegree);
            precisionDifference := max(seq(abs(current[1][i]-previous[1][i]),
                i=1..numberOfComponents));
            degreeDifference := max(seq(abs(current[1][i]-current[5][i]),
                i=1..numberOfComponents));
            valueNorm := max(seq(abs(current[1][i]),i=1..numberOfComponents),1);
            if current[2] and previous[2] and
               precisionDifference<=tolerance*valueNorm then
                precisionStable := true;
            end if;
        end do;
    finally
        Digits := oldDigits;
    end try;
    valueNorm := max(seq(abs(current[1][i]),i=1..numberOfComponents),1);
    if precisionStable and current[2] and
       (terminationDegree<>infinity or degreeDifference<=tolerance*valueNorm) then
        return [current[1],true,current[3],
            max(current[4],degreeDifference,precisionDifference),
            degreeDifference,precisionDifference,workingPrecision,
            `if`(terminationDegree=infinity,
                `if`(not precisionRerun,"geometric_shell_and_doubled_degree",
                    "geometric_shell_doubled_degree_and_precision_rerun"),
                `if`(not precisionRerun,"exact_termination",
                    "precision_rerun_exact_termination"))];
    end if;
    return [current[1],false,current[3],
        max(current[4],degreeDifference,precisionDifference),
        degreeDifference,precisionDifference,workingPrecision,
        `if`(precisionStable,"failed","precision_unstable")];
end proc;

UnitCoefficientArray := proc(maximumDegree::nonnegint)
    local result;
    result := Array(0..maximumDegree,fill=0); result[0] := 1;
    return result;
end proc;

TruncatedConvolution := proc(left,right,maximumDegree::nonnegint)
    local result,i,j;
    result := Array(0..maximumDegree,fill=0);
    for i from 0 to maximumDegree do
        if left[i]=0 then next; end if;
        for j from 0 to maximumDegree-i do
            if right[j]<>0 then result[i+j] := result[i+j]+left[i]*right[j]; end if;
        end do;
    end do;
    return result;
end proc;

LauricellaConvolutionRadius := proc(familyName::string,target::list)
    local name,value;
    name := StringTools:-LowerCase(familyName);
    if member(name,["lauricellafa","appellf2"]) then
        return evalf(add(abs(value),value in target));
    elif member(name,["lauricellafb","appellf3"]) then
        return evalf(max(seq(abs(value),value in target)));
    elif member(name,["lauricellafc","appellf4"]) then
        return evalf(add(sqrt(abs(value)),value in target));
    end if;
    error "the family does not have a Lauricella convolution kernel";
end proc;

LauricellaConvolutionTerminationDegree := proc(series)
    local name,n,degreeValue,candidate,i,firstDegree,secondDegree,
          allTerminating;
    name := StringTools:-LowerCase(series:-name); n := series:-nvariables;
    degreeValue := infinity;
    if member(name,["lauricellafa","appellf2"]) then
        degreeValue := ExactNonpositiveIntegerDegree(series:-upperParameters[1]);
        allTerminating := true; candidate := 0;
        for i to n do
            if evalb(series:-upperParameters[i+1]=series:-lowerParameters[i]) then
                allTerminating := false; break;
            end if;
            firstDegree := ExactNonpositiveIntegerDegree(series:-upperParameters[i+1]);
            if firstDegree=infinity then allTerminating := false; break; end if;
            candidate := candidate+firstDegree;
        end do;
        if allTerminating then degreeValue := min(degreeValue,candidate); end if;
    elif member(name,["lauricellafb","appellf3"]) then
        allTerminating := true; candidate := 0;
        for i to n do
            firstDegree := ExactNonpositiveIntegerDegree(series:-upperParameters[i]);
            secondDegree := ExactNonpositiveIntegerDegree(series:-upperParameters[n+i]);
            if firstDegree=infinity and secondDegree=infinity then
                allTerminating := false; break;
            end if;
            candidate := candidate+min(firstDegree,secondDegree);
        end do;
        if allTerminating then degreeValue := candidate; end if;
    elif member(name,["lauricellafc","appellf4"]) then
        firstDegree := ExactNonpositiveIntegerDegree(series:-upperParameters[1]);
        secondDegree := ExactNonpositiveIntegerDegree(series:-upperParameters[2]);
        degreeValue := min(firstDegree,secondDegree);
    end if;
    return degreeValue;
end proc;

ValidateLauricellaConvolutionParameters := proc(series,terminationDegree)
    local name,n,parameter,poleDegree,numeratorDegree,i;
    name := StringTools:-LowerCase(series:-name); n := series:-nvariables;
    if member(name,["lauricellafa","appellf2"]) then
        for i to n do
            parameter := series:-lowerParameters[i];
            if type(parameter,integer) and parameter<=0 and
               not evalb(series:-upperParameters[i+1]=parameter) then
                poleDegree := 1-parameter;
                numeratorDegree := ExactNonpositiveIntegerDegree(
                    series:-upperParameters[i+1]);
                if min(terminationDegree,numeratorDegree)>=poleDegree then
                    error "the Lauricella FA series has an uncancelled singular lower parameter in variable %1",i;
                end if;
            end if;
        end do;
    elif member(name,["lauricellafb","appellf3"]) then
        parameter := series:-lowerParameters[1];
        if type(parameter,integer) and parameter<=0 and
           terminationDegree>=1-parameter then
            error "the Lauricella FB series has an uncancelled singular lower parameter";
        end if;
    elif member(name,["lauricellafc","appellf4"]) then
        for i to n do
            parameter := series:-lowerParameters[i];
            if type(parameter,integer) and parameter<=0 and
               terminationDegree>=1-parameter then
                error "the Lauricella FC series has an uncancelled singular lower parameter in variable %1",i;
            end if;
        end do;
    end if;
    return true;
end proc;

# The FA, FB, and FC coefficients factor into one-variable sequences followed
# by a single total-degree Pochhammer factor.  Prefix and suffix convolutions
# provide the value and every first derivative in O(n D^2) operations.
LauricellaConvolutionVector := proc(series,target::list,
                                   maximumDegree::nonnegint)
    local name,n,individual,derivativeIndividual,prefix,suffix,
          baseSequence,derivativeSequence,productSequence,
          derivativeProduct,temporary,outerWeights,values,a,b,c,
          av,bv,cv,ratio,derivativeRatio,cancelled,degree,i,k;
    name := StringTools:-LowerCase(series:-name); n := series:-nvariables;
    individual := Array(1..n); derivativeIndividual := Array(1..n);
    for i to n do
        baseSequence := Array(0..maximumDegree,fill=0);
        derivativeSequence := Array(0..maximumDegree,fill=0);
        baseSequence[0] := 1;
        if member(name,["lauricellafa","appellf2"]) then
            bv := series:-upperParameters[i+1]; cv := series:-lowerParameters[i];
            cancelled := evalb(bv=cv);
            derivativeSequence[0] := `if`(cancelled,1,bv/cv);
            for degree to maximumDegree do
                ratio := `if`(cancelled,1,(bv+degree-1)/(cv+degree-1));
                baseSequence[degree] := evalf(baseSequence[degree-1]*
                    ratio*target[i]/degree);
                derivativeRatio := `if`(cancelled,1,(bv+degree)/(cv+degree));
                derivativeSequence[degree] := evalf(derivativeSequence[degree-1]*
                    derivativeRatio*target[i]/degree);
            end do;
        elif member(name,["lauricellafb","appellf3"]) then
            av := series:-upperParameters[i]; bv := series:-upperParameters[n+i];
            derivativeSequence[0] := av*bv;
            for degree to maximumDegree do
                baseSequence[degree] := evalf(baseSequence[degree-1]*
                    (av+degree-1)*(bv+degree-1)*target[i]/degree);
                derivativeSequence[degree] := evalf(derivativeSequence[degree-1]*
                    (av+degree)*(bv+degree)*target[i]/degree);
            end do;
        else
            cv := series:-lowerParameters[i]; derivativeSequence[0] := 1/cv;
            for degree to maximumDegree do
                baseSequence[degree] := evalf(baseSequence[degree-1]*
                    target[i]/((cv+degree-1)*degree));
                derivativeSequence[degree] := evalf(derivativeSequence[degree-1]*
                    target[i]/((cv+degree)*degree));
            end do;
        end if;
        individual[i] := baseSequence; derivativeIndividual[i] := derivativeSequence;
    end do;
    prefix := Array(0..n); suffix := Array(1..n+1);
    prefix[0] := UnitCoefficientArray(maximumDegree);
    for i to n do
        prefix[i] := TruncatedConvolution(prefix[i-1],individual[i],maximumDegree);
    end do;
    suffix[n+1] := UnitCoefficientArray(maximumDegree);
    for i from n by -1 to 1 do
        suffix[i] := TruncatedConvolution(individual[i],suffix[i+1],maximumDegree);
    end do;
    productSequence := prefix[n];
    outerWeights := Array(0..maximumDegree+1,fill=0); outerWeights[0] := 1;
    if member(name,["lauricellafa","appellf2"]) then
        a := series:-upperParameters[1];
        for degree to maximumDegree+1 do
            outerWeights[degree] := evalf(outerWeights[degree-1]*(a+degree-1));
        end do;
    elif member(name,["lauricellafb","appellf3"]) then
        c := series:-lowerParameters[1];
        for degree to maximumDegree+1 do
            outerWeights[degree] := evalf(outerWeights[degree-1]/(c+degree-1));
        end do;
    else
        a := series:-upperParameters[1]; b := series:-upperParameters[2];
        for degree to maximumDegree+1 do
            outerWeights[degree] := evalf(outerWeights[degree-1]*
                (a+degree-1)*(b+degree-1));
        end do;
    end if;
    values := Vector(n+1,datatype=anything);
    values[1] := evalf(add(outerWeights[degree]*productSequence[degree],
        degree=0..maximumDegree));
    for i to n do
        temporary := TruncatedConvolution(prefix[i-1],
            derivativeIndividual[i],maximumDegree);
        derivativeProduct := TruncatedConvolution(temporary,suffix[i+1],maximumDegree);
        values[i+1] := evalf(add(outerWeights[k+1]*derivativeProduct[k],
            k=0..maximumDegree-1));
    end do;
    if not andmap(IsFiniteNumber,[seq(values[i],i=1..n+1)]) then
        return [values,false];
    end if;
    return [values,true];
end proc;

LauricellaConvolutionChecked := proc(exactSeries,target::list,digits::posint,
                                    maximumDegree::posint)
    local radius,terminationDegree,estimatedDegree,effectiveDegree,
          lowerDegree,operationCount,oldDigits,half,lowerPrecision,current,previous,
          degreeDifference,precisionDifference,errorEstimate,tolerance,
          valueNorm,n,i,success,certificate,guardDigits,transientDegree,
          precisionOffsets,attempt,workingPrecision,precisionStable,
          precisionRerun;
    n := exactSeries:-nvariables;
    radius := LauricellaConvolutionRadius(exactSeries:-name,target);
    terminationDegree := LauricellaConvolutionTerminationDegree(exactSeries);
    ValidateLauricellaConvolutionParameters(exactSeries,terminationDegree);
    estimatedDegree := `if`(terminationDegree=infinity,
        HypergeometricSeriesDegree(radius,digits),terminationDegree);
    transientDegree := HypergeometricTransientDegree(exactSeries);
    if terminationDegree=infinity and estimatedDegree<>infinity and
       transientDegree>0 then
        estimatedDegree := estimatedDegree+transientDegree+12;
    end if;
    if terminationDegree<>infinity and terminationDegree>maximumDegree then
        error "the terminating %1 series needs degree %2, above maximumDegree=%3",exactSeries:-name,terminationDegree,maximumDegree;
    end if;
    if terminationDegree=infinity and radius>=1 then
        return [Vector(n+1,datatype=anything),false,0,infinity,
            infinity,infinity,0,"outside_convergence_domain",estimatedDegree,radius];
    end if;
    effectiveDegree := `if`(terminationDegree=infinity,maximumDegree,terminationDegree);
    if estimatedDegree<>infinity and terminationDegree=infinity and
       estimatedDegree+8>effectiveDegree then
        return [Vector(n+1,datatype=anything),false,effectiveDegree,infinity,
            infinity,infinity,0,"insufficient_degree",estimatedDegree,radius];
    end if;
    operationCount := 8*n*(effectiveDegree+1)^2;
    if operationCount>20000000 then
        error "the Lauricella convolution exceeds its twenty-million-operation resource gate";
    end if;
    lowerDegree := `if`(terminationDegree=infinity,
        max(8,estimatedDegree,floor(effectiveDegree/2)),effectiveDegree);
    guardDigits := HypergeometricConditioningGuardDigits(exactSeries,target);
    oldDigits := Digits; tolerance := evalf(10^(-(digits+3)));
    precisionOffsets := [14,24,56,120,248,504,1016,2040,4088];
    precisionStable := false; attempt := 2; precisionRerun := false;
    try
        Digits := digits+guardDigits+precisionOffsets[1];
        half := LauricellaConvolutionVector(NumericParameterSeries(exactSeries),
            map(evalf,target),lowerDegree);
        lowerPrecision := LauricellaConvolutionVector(
            NumericParameterSeries(exactSeries),map(evalf,target),effectiveDegree);
        Digits := digits+guardDigits+precisionOffsets[2];
        current := LauricellaConvolutionVector(NumericParameterSeries(exactSeries),
            map(evalf,target),effectiveDegree);
        workingPrecision := Digits;
        degreeDifference := max(seq(abs(current[1][i]-half[1][i]),i=1..n+1));
        precisionDifference := max(seq(abs(current[1][i]-
            lowerPrecision[1][i]),i=1..n+1));
        valueNorm := max(seq(abs(current[1][i]),i=1..n+1),1);
        precisionStable := evalb(current[2] and lowerPrecision[2] and
            precisionDifference<=tolerance*valueNorm);
        # Repeat a complete convolution at successively higher precision when
        # a terminating polynomial or opposing parameters amplify rounding.
        # Agreement covers the value and every first derivative.
        for attempt from 3 to nops(precisionOffsets) while not precisionStable do
            if not current[2] then break; end if;
            precisionRerun := true;
            previous := current;
            Digits := digits+guardDigits+precisionOffsets[attempt];
            workingPrecision := Digits;
            current := LauricellaConvolutionVector(
                NumericParameterSeries(exactSeries),map(evalf,target),effectiveDegree);
            precisionDifference := max(seq(abs(current[1][i]-
                previous[1][i]),i=1..n+1));
            valueNorm := max(seq(abs(current[1][i]),i=1..n+1),1);
            precisionStable := evalb(current[2] and previous[2] and
                precisionDifference<=tolerance*valueNorm);
        end do;
        if precisionStable and precisionRerun then
            # The doubled-degree comparison must be formed at the same final
            # precision; otherwise an inaccurate low-precision half sum can
            # masquerade as truncation error after a successful rerun.
            half := LauricellaConvolutionVector(NumericParameterSeries(exactSeries),
                map(evalf,target),lowerDegree);
            degreeDifference := max(seq(abs(current[1][i]-half[1][i]),
                i=1..n+1));
        end if;
    finally
        Digits := oldDigits;
    end try;
    valueNorm := max(seq(abs(current[1][i]),i=1..n+1),1);
    errorEstimate := max(precisionDifference,
        `if`(terminationDegree=infinity,
            degreeDifference/max(1-radius,10^(-digits)),0));
    success := evalb(precisionStable and current[2] and
        (terminationDegree<>infinity or
         errorEstimate<=tolerance*valueNorm));
    certificate := `if`(terminationDegree=infinity,
        `if`(not precisionRerun,"convergence_domain_and_doubled_degree",
            "convergence_domain_doubled_degree_and_precision_rerun"),
        `if`(not precisionRerun,"exact_termination",
            "precision_rerun_exact_termination"));
    return [current[1],success,effectiveDegree,errorEstimate,
        degreeDifference,precisionDifference,workingPrecision,
        `if`(success,certificate,
            `if`(precisionStable,"failed","precision_unstable")),
        estimatedDegree,radius];
end proc;

IsFiniteNumber := proc(value)
    local realPart, imaginaryPart;
    if not type(value,numeric) and
       not type(value,complex(numeric)) then return false; end if;
    if has(value,{undefined,infinity,-infinity}) then return false; end if;
    try
        realPart := evalf(Re(value));
        imaginaryPart := evalf(Im(value));
    catch:
        return false;
    end try;
    if not type(realPart,numeric) or not type(imaginaryPart,numeric) or
       has({realPart,imaginaryPart},{undefined,infinity,-infinity}) then
        return false;
    end if;
    return true;
end proc;

SeriesVector := proc(
    series,
    point::list,
    basis::list,
    digits::posint,
    maximumDegree::posint
)
    local values, tolerance, consecutiveSmall, consecutiveGrowth,
          previousNorm, degree, shell, index, coefficient,
          basisIndex, derivative, term, variable, exponent,
          shellNorm, valueNorm, allLargeEnough, termBudget,
          shellTermCount, i;
    values := Vector(nops(basis), datatype = anything);
    tolerance := evalf(10^(-(digits + 8)));
    consecutiveSmall := 0; consecutiveGrowth := 0; previousNorm := infinity;
    termBudget := 0;
    for degree from 0 to maximumDegree do
        shellTermCount := binomial(degree+series:-nvariables-1,
            series:-nvariables-1);
        if termBudget+shellTermCount > 1000000 then
            # A generic multi-index expansion above this budget is not a
            # practical evaluator.  Return control to the Pfaffian dispatcher
            # instead of materialising millions of compositions.
            return [values,false,degree];
        end if;
        termBudget := termBudget+shellTermCount;
        shell := Vector(nops(basis), datatype = anything);
        for index in Compositions(degree, series:-nvariables) do
            try
                coefficient := SeriesCoefficient(series, index);
            catch:
                return [values, false, degree];
            end try;
            if not IsFiniteNumber(coefficient) then return [values, false, degree]; end if;
            for basisIndex to nops(basis) do
                derivative := basis[basisIndex];
                allLargeEnough := true;
                for variable to series:-nvariables do
                    if index[variable] < derivative[variable] then
                        allLargeEnough := false; break;
                    end if;
                end do;
                if not allLargeEnough then next; end if;
                term := coefficient;
                for variable to series:-nvariables do
                    term := term * FallingFactorial(index[variable], derivative[variable]);
                    exponent := index[variable] - derivative[variable];
                    if exponent <> 0 then term := term * point[variable]^exponent; end if;
                end do;
                shell[basisIndex] := shell[basisIndex] + term;
            end do;
        end do;
        for i to nops(basis) do values[i] := evalf(values[i] + shell[i]); end do;
        shellNorm := VectorMaxAbs(shell);
        valueNorm := max(VectorMaxAbs(values), 1);
        if degree >= 4 and shellNorm <= tolerance * valueNorm then
            consecutiveSmall := consecutiveSmall + 1;
        else
            consecutiveSmall := 0;
        end if;
        if consecutiveSmall >= 5 then return [values, true, degree]; end if;
        if degree >= 10 and previousNorm <> infinity and shellNorm > 1.15 * previousNorm then
            consecutiveGrowth := consecutiveGrowth + 1;
        else
            consecutiveGrowth := 0;
        end if;
        if consecutiveGrowth >= 10 and shellNorm > 10^4 * valueNorm then
            return [values, false, degree];
        end if;
        previousNorm := shellNorm;
    end do;
    return [values, false, maximumDegree];
end proc;

DirectSeriesValue := proc(series, target::list, digits::posint, maximumDegree::posint)
    local result;
    result := SeriesVector(series, target, [ZeroIndex(series:-nvariables)], digits, maximumDegree);
    return [result[1][1], result[2], result[3]];
end proc;

BoundarySeries := proc(system, target::list, maximumDegree::posint)
    local maximumTarget, localRadius, scale, attempt, start, result,
          values, basisValue, derivative, i;
    maximumTarget := max(seq(abs(target[i]), i = 1 .. nops(target)));
    if maximumTarget = 0 then
        values := Vector(nops(system:-basis), datatype = anything);
        for i to nops(system:-basis) do
            derivative := system:-basis[i];
            if derivative = ZeroIndex(system:-series:-nvariables) then
                values[i] := 1;
            else
                basisValue := SeriesCoefficient(system:-series, derivative);
                basisValue := basisValue * mul(derivative[i]!, i = 1 .. nops(derivative));
                values[i] := basisValue;
            end if;
        end do;
        return [[seq(0, i = 1 .. nops(target))], values];
    end if;
    localRadius := evalf(1 / (4 * system:-series:-nvariables^2));
    scale := min(0.20, localRadius / maximumTarget);
    for attempt to 12 do
        start := [seq(evalf(scale * target[i]), i = 1 .. nops(target))];
        result := SeriesVector(
            system:-series,
            start,
            system:-basis,
            system:-digits + 8,
            maximumDegree
        );
        if result[2] then return [start, result[1]]; end if;
        scale := scale / 2;
    end do;
    error "the defining series did not converge at an automatically selected boundary point";
end proc;

RestrictZeroVariables := proc(series, active::list)
    local upperParameters, upperWeights, lowerParameters, lowerWeights,
          i, weights, j;
    if nops(active) = series:-nvariables then return series; end if;
    if nops(active) = 0 then error "at least one active variable is required"; end if;
    upperParameters := []; upperWeights := [];
    lowerParameters := []; lowerWeights := [];
    for i to nops(series:-upperParameters) do
        weights := [seq(series:-upperWeights[i][active[j]], j = 1 .. nops(active))];
        if not andmap(w -> evalb(w = 0), weights) then
            upperParameters := [op(upperParameters), series:-upperParameters[i]];
            upperWeights := [op(upperWeights), weights];
        end if;
    end do;
    for i to nops(series:-lowerParameters) do
        weights := [seq(series:-lowerWeights[i][active[j]], j = 1 .. nops(active))];
        if not andmap(w -> evalb(w = 0), weights) then
            lowerParameters := [op(lowerParameters), series:-lowerParameters[i]];
            lowerWeights := [op(lowerWeights), weights];
        end if;
    end do;
    return HornSeries(upperParameters, upperWeights, lowerParameters, lowerWeights, series:-name);
end proc;

# ---------------------------------------------------------------------------
# Restriction to a contour and local Frobenius transport
# ---------------------------------------------------------------------------

Convolve := proc(left::list, right::list)
    local result, i, j;
    result := [seq(0, i = 1 .. nops(left) + nops(right) - 1)];
    for i to nops(left) do
        for j to nops(right) do
            result[i + j - 1] := result[i + j - 1] + left[i] * right[j];
        end do;
    end do;
    return result;
end proc;

PolynomialOnLine := proc(polynomial::table, center::list, direction::list)
    local degree, coefficients, exponent, scalar, localCoefficients,
          variable, power, factor, order, i;
    degree := max(PolyDegree(polynomial), 0);
    coefficients := [seq(0, i = 0 .. degree)];
    for exponent in [indices(polynomial, 'nolist')] do
        scalar := polynomial[exponent];
        if scalar = 0 then next; end if;
        localCoefficients := [1];
        for variable to nops(exponent) do
            power := exponent[variable];
            if power = 0 then next; end if;
            factor := [seq(
                binomial(power, order) * center[variable]^(power - order) *
                    direction[variable]^order,
                order = 0 .. power
            )];
            localCoefficients := Convolve(localCoefficients, factor);
        end do;
        for i to nops(localCoefficients) do
            coefficients[i] := coefficients[i] + scalar * localCoefficients[i];
        end do;
    end do;
    return map(evalf, coefficients);
end proc;

EquationMatrixOnLine := proc(system, center::list, direction::list)
    local selectedEquations, selectedColumns, derivatives, columnIndex,
          matrices, row, equation, derivative, coefficients,
          order, i, j, column;
    selectedEquations := [seq(system:-equations[system:-equationRows[i]],
        i = 1 .. nops(system:-equationRows))];
    selectedColumns := [op(system:-pivotColumns), op(system:-freeColumns)];
    derivatives := [seq(system:-columns[selectedColumns[i]], i = 1 .. nops(selectedColumns))];
    columnIndex := table();
    for i to nops(derivatives) do columnIndex[derivatives[i]] := i; end do;
    matrices := [Matrix(nops(selectedEquations), nops(derivatives), datatype = anything)];
    for row to nops(selectedEquations) do
        equation := selectedEquations[row];
        for derivative in [indices(equation, 'nolist')] do
            coefficients := PolynomialOnLine(equation[derivative], center, direction);
            while nops(matrices) < nops(coefficients) do
                matrices := [op(matrices), Matrix(nops(selectedEquations), nops(derivatives), datatype = anything)];
            end do;
            column := columnIndex[derivative];
            for order to nops(coefficients) do
                matrices[order][row, column] := coefficients[order];
            end do;
        end do;
    end do;
    return matrices;
end proc;

ReductionSeries := proc(system, center::list, direction::list, order::nonnegint)
    local equationCoefficients, pivotCount, freeCount, pivotCoefficients,
          freeCoefficients, reductions, degree, right, positiveDegree,
          zeroMatrix, i, j;
    equationCoefficients := EquationMatrixOnLine(system, center, direction);
    pivotCount := nops(system:-pivotColumns);
    freeCount := nops(system:-freeColumns);
    pivotCoefficients := [seq(Matrix(pivotCount, pivotCount,
        (i, j) -> equationCoefficients[degree][i, j], datatype = anything),
        degree = 1 .. nops(equationCoefficients))];
    freeCoefficients := [seq(Matrix(pivotCount, freeCount,
        (i, j) -> equationCoefficients[degree][i, pivotCount + j], datatype = anything),
        degree = 1 .. nops(equationCoefficients))];
    reductions := [];
    for degree from 0 to order do
        if degree + 1 <= nops(freeCoefficients) then
            right := -copy(freeCoefficients[degree + 1]);
        else
            right := Matrix(pivotCount, freeCount, datatype = anything);
        end if;
        for positiveDegree from 1 to min(degree, nops(pivotCoefficients) - 1) do
            right := right - pivotCoefficients[positiveDegree + 1].reductions[degree - positiveDegree + 1];
        end do;
        try
            reductions := [op(reductions), LinearAlgebra:-LinearSolve(pivotCoefficients[1], right)];
        catch:
            error "a Frobenius centre lies on the singular locus";
        end try;
    end do;
    return reductions;
end proc;

RationalTaylorSeries := proc(expressionValue,z::symbol,order::nonnegint)
    local rationalValue, numeratorValue, denominatorValue,
          numeratorCoefficients, denominatorCoefficients, coefficients,
          degree, convolutionDegree, value;
    rationalValue := normal(expressionValue);
    numeratorValue := expand(numer(rationalValue));
    denominatorValue := expand(denom(rationalValue));
    numeratorCoefficients := Array(0..order,fill=0);
    denominatorCoefficients := Array(0..order,fill=0);
    coefficients := Array(0..order,fill=0);
    for degree from 0 to order do
        numeratorCoefficients[degree] := evalf(coeff(numeratorValue,z,degree));
        denominatorCoefficients[degree] := evalf(coeff(denominatorValue,z,degree));
    end do;
    if denominatorCoefficients[0] = 0 then
        error "a Taylor centre lies on the singular locus of the user Pfaffian connection";
    end if;
    coefficients[0] := evalf(numeratorCoefficients[0]/denominatorCoefficients[0]);
    for degree to order do
        value := numeratorCoefficients[degree];
        for convolutionDegree to degree do
            value := value-denominatorCoefficients[convolutionDegree]*
                coefficients[degree-convolutionDegree];
        end do;
        coefficients[degree] := evalf(value/denominatorCoefficients[0]);
    end do;
    return coefficients;
end proc;

UserRestrictedMatrixSeries := proc(
    system,
    center::list,
    direction::list,
    order::nonnegint
)
    local z, rank, coefficients, variable, row, column,
          restrictedEntry, expansionValue, degree, i;
    z := parse("hp_local_z"); rank := system:-rank;
    coefficients := [seq(Matrix(rank,rank,datatype=anything),
        degree=0..order)];
    for variable to nops(system:-variables) do
        if direction[variable] = 0 then next; end if;
        for row to rank do
            for column to rank do
                restrictedEntry := subs(seq(system:-variables[i]=
                    center[i]+z*direction[i],i=1..nops(center)),
                    system:-connection[variable][row,column]);
                expansionValue := RationalTaylorSeries(restrictedEntry,z,order);
                for degree from 0 to order do
                    coefficients[degree+1][row,column] :=
                        coefficients[degree+1][row,column] +
                        direction[variable]*expansionValue[degree];
                end do;
            end do;
        end do;
    end do;
    return coefficients;
end proc;

RestrictedMatrixSeries := proc(system, center::list, direction::list, order::nonnegint)
    local reductions, freePosition, pivotPosition, columnIndex,
          basisColumns, basisPositions, basisSet, rank, coefficients,
          n, variable, basisRow, derivative, target, targetColumn,
          position, basisColumn, reductionRow, degree, i;
    if system:-hpType = "UserPfaffianSystem" then
        return UserRestrictedMatrixSeries(system,center,direction,order);
    end if;
    reductions := ReductionSeries(system, center, direction, order);
    freePosition := table();
    for i to nops(system:-freeColumns) do freePosition[system:-freeColumns[i]] := i; end do;
    pivotPosition := table();
    for i to nops(system:-pivotColumns) do pivotPosition[system:-pivotColumns[i]] := i; end do;
    columnIndex := table();
    for i to nops(system:-columns) do columnIndex[system:-columns[i]] := i; end do;
    basisColumns := [seq(columnIndex[system:-basis[i]], i = 1 .. nops(system:-basis))];
    basisPositions := [];
    for i in basisColumns do
        if not assigned(freePosition[i]) then
            error "the derivative basis changed at a Frobenius centre";
        end if;
        basisPositions := [op(basisPositions), freePosition[i]];
    end do;
    basisSet := table();
    for i in basisPositions do basisSet[i] := true; end do;
    rank := nops(system:-basis); n := system:-series:-nvariables;
    coefficients := [seq(Matrix(rank, rank, datatype = anything), degree = 0 .. order)];
    for variable to n do
        for basisRow to rank do
            derivative := system:-basis[basisRow];
            target := AddIndex(derivative, variable);
            if not assigned(columnIndex[target]) then error "the derivative closure is incomplete"; end if;
            targetColumn := columnIndex[target];
            if assigned(freePosition[targetColumn]) then
                position := freePosition[targetColumn];
                if not assigned(basisSet[position]) then
                    error "the derivative basis changed at a Frobenius centre";
                end if;
                for basisColumn to rank do
                    if basisPositions[basisColumn] = position then
                        coefficients[1][basisRow, basisColumn] :=
                            coefficients[1][basisRow, basisColumn] + direction[variable];
                        break;
                    end if;
                end do;
            else
                if not assigned(pivotPosition[targetColumn]) then error "the derivative closure is incomplete"; end if;
                reductionRow := pivotPosition[targetColumn];
                for degree from 0 to order do
                    for basisColumn to rank do
                        coefficients[degree + 1][basisRow, basisColumn] :=
                            coefficients[degree + 1][basisRow, basisColumn] +
                            direction[variable] * reductions[degree + 1][reductionRow, basisPositions[basisColumn]];
                    end do;
                end do;
            end if;
        end do;
    end do;
    return coefficients;
end proc;

FrobeniusSolutionCoefficients := proc(matrixCoefficients::list, initialValue::Vector, order::posint)
    local coefficients, degree, nextValue, matrixDegree;
    coefficients := [copy(initialValue)];
    for degree from 0 to order - 1 do
        nextValue := Vector(LinearAlgebra:-Dimension(initialValue), datatype = anything);
        for matrixDegree from 0 to degree do
            nextValue := nextValue + matrixCoefficients[matrixDegree + 1].coefficients[degree - matrixDegree + 1];
        end do;
        coefficients := [op(coefficients), evalf(nextValue / (degree + 1))];
    end do;
    return coefficients;
end proc;

EvaluateFrobeniusSeries := proc(coefficients::list, step, digits::posint)
    local result, termNorms, power, degree, term, scale,
          tailLength, tailStart, tail, tolerance, decreasing,
          previousNonzero, monotonicSlack, i;
    result := Vector(LinearAlgebra:-Dimension(coefficients[1]), datatype = anything);
    termNorms := []; power := 1;
    for degree from 0 to nops(coefficients) - 1 do
        term := evalf(power * coefficients[degree + 1]);
        result := result + term;
        termNorms := [op(termNorms), VectorMaxAbs(term)];
        power := power * step;
    end do;
    scale := max(VectorMaxAbs(result), 1);
    tailLength := min(8, nops(termNorms));
    tailStart := nops(termNorms) - tailLength + 1;
    tail := max(seq(termNorms[i], i = tailStart .. nops(termNorms)));
    tolerance := evalf(10^(-(digits + 5)));
    decreasing := true; previousNonzero := infinity;
    monotonicSlack := evalf(1+10^(-max(4,iquo(digits,2))));
    for i from tailStart to nops(termNorms) do
        if termNorms[i] > 0 then
            if previousNonzero <> infinity and
               termNorms[i] > monotonicSlack*previousNonzero then
                decreasing := false; break;
            end if;
            previousNonzero := termNorms[i];
        end if;
    end do;
    return [result, evalf(tail / scale), evalb(tail <= tolerance * scale and decreasing)];
end proc;

IntegrateSegmentFrobenius := proc(
    system,
    segmentStart::list,
    segmentEnd::list,
    initialValue::Vector,
    digits::posint,
    seriesOrder::posint,
    maximumSteps::posint,
    verbose::boolean
)
    local direction, parameter, value, patches, minimumStep, center,
          matrixCoefficients, solutionCoefficients, step, accepted,
          candidate, relativeTail, evaluation, i;
    direction := [seq(evalf(segmentEnd[i] - segmentStart[i]), i = 1 .. nops(segmentStart))];
    if max(seq(abs(direction[i]), i = 1 .. nops(direction))) = 0 then return initialValue; end if;
    parameter := 0.; value := copy(initialValue); patches := 0;
    minimumStep := evalf(10^(-max(20, digits + 8)));
    while parameter < 1 do
        patches := patches + 1;
        if patches > maximumSteps then error "the Frobenius solver exceeded maximumSteps"; end if;
        center := [seq(evalf(segmentStart[i] + parameter * direction[i]), i = 1 .. nops(direction))];
        matrixCoefficients := RestrictedMatrixSeries(system, center, direction, seriesOrder - 1);
        solutionCoefficients := FrobeniusSolutionCoefficients(matrixCoefficients, value, seriesOrder);
        step := evalf(1 - parameter); accepted := false;
        candidate := value; relativeTail := infinity;
        while step >= minimumStep do
            evaluation := EvaluateFrobeniusSeries(solutionCoefficients, step, digits);
            candidate := evaluation[1]; relativeTail := evaluation[2]; accepted := evaluation[3];
            if accepted then break; end if;
            step := step / 2;
        end do;
        if not accepted then error "the Frobenius series did not converge along the selected contour"; end if;
        value := candidate; parameter := evalf(parameter + step);
        if abs(1 - parameter) <= 10 * minimumStep then parameter := 1; end if;
        if verbose then
            printf("HyperPrecision: Frobenius patch %d, step = %a, relative tail = %a\n",
                patches, step, relativeTail);
        end if;
    end do;
    return value;
end proc;

# ---------------------------------------------------------------------------
# Full fundamental-matrix Taylor transport
# ---------------------------------------------------------------------------

FundamentalSolutionCoefficients := proc(
    matrixCoefficients::list,
    rank::posint,
    order::posint
)
    local coefficients, degree, nextMatrix, matrixDegree;
    coefficients := [LinearAlgebra:-IdentityMatrix(rank,
        datatype = anything)];
    for degree from 0 to order - 1 do
        nextMatrix := Matrix(rank, rank, datatype = anything);
        for matrixDegree from 0 to degree do
            nextMatrix := nextMatrix +
                matrixCoefficients[matrixDegree + 1].
                coefficients[degree - matrixDegree + 1];
        end do;
        coefficients := [op(coefficients),
            evalf(nextMatrix / (degree + 1))];
    end do;
    return coefficients;
end proc;

EvaluateFundamentalSeries := proc(
    coefficients::list,
    step,
    digits::posint
)
    local rank, result, termNorms, power, degree, term, scale,
          tailLength, tailStart, tail, tolerance, decreasing,
          previousNonzero, monotonicSlack, i;
    rank := LinearAlgebra:-RowDimension(coefficients[1]);
    result := Matrix(rank, rank, datatype = anything);
    termNorms := []; power := 1;
    for degree from 0 to nops(coefficients) - 1 do
        term := evalf(power * coefficients[degree + 1]);
        result := result + term;
        termNorms := [op(termNorms), MatrixMaxAbs(term)];
        power := power * step;
    end do;
    scale := max(MatrixMaxAbs(result), 1);
    tailLength := min(8, nops(termNorms));
    tailStart := nops(termNorms) - tailLength + 1;
    tail := max(seq(termNorms[i], i = tailStart .. nops(termNorms)));
    tolerance := evalf(10^(-(digits + 4)));
    decreasing := true; previousNonzero := infinity;
    monotonicSlack := evalf(1+10^(-max(4,iquo(digits,2))));
    for i from tailStart to nops(termNorms) do
        if termNorms[i] > 0 then
            if previousNonzero <> infinity and
               termNorms[i] > monotonicSlack*previousNonzero then
                decreasing := false; break;
            end if;
            previousNonzero := termNorms[i];
        end if;
    end do;
    return [result, evalf(tail / scale),
        evalb(tail <= tolerance * scale and decreasing)];
end proc;

FundamentalDifferentialResidual := proc(
    system,
    center::list,
    direction::list,
    coefficients::list,
    step,
    transportedMatrix::Matrix
)
    local rank, derivativeValue, power, degree, endpoint,
          omega, restrictedMatrix, scale, variable, i;
    rank := LinearAlgebra:-RowDimension(transportedMatrix);
    derivativeValue := Matrix(rank,rank,datatype=anything);
    power := 1;
    for degree from 1 to nops(coefficients)-1 do
        derivativeValue := derivativeValue +
            degree*power*coefficients[degree+1];
        power := power*step;
    end do;
    endpoint := [seq(evalf(center[i]+step*direction[i]),
        i=1..nops(center))];
    omega := ConnectionMatricesInternal(system,endpoint);
    restrictedMatrix := Matrix(rank,rank,datatype=anything);
    for variable to nops(direction) do
        restrictedMatrix := restrictedMatrix + direction[variable]*omega[variable];
    end do;
    scale := max(1,MatrixMaxAbs(derivativeValue),
        MatrixMaxAbs(restrictedMatrix.transportedMatrix));
    return evalf(MatrixMaxAbs(derivativeValue-
        restrictedMatrix.transportedMatrix)/scale);
end proc;

MatrixIdentityResidual := proc(inputMatrix::Matrix)
    local rows, columns;
    rows := LinearAlgebra:-RowDimension(inputMatrix);
    columns := LinearAlgebra:-ColumnDimension(inputMatrix);
    if rows <> columns then error "an identity residual requires a square matrix"; end if;
    return MatrixMaxAbs(inputMatrix -
        LinearAlgebra:-IdentityMatrix(rows, datatype = anything));
end proc;

IntegrateSegmentFundamental := proc(
    system,
    segmentStart::list,
    segmentEnd::list,
    digits::posint,
    seriesOrder::posint,
    maximumSteps::posint,
    safetyFactor,
    verificationOrder::nonnegint,
    verbose::boolean
)
    local direction, rank, roots, parameter, patches, minimumStep,
          factors, history, maximumError, maximumDifferentialResidual,
          center, nearestRoot,
          rootValue, permittedStep, matrixCoefficients,
          solutionCoefficients, step, accepted, highEvaluation,
          lowEvaluation, candidate, discrepancy, relativeTail,
          differentialResidual, differentialTolerance,
          totalOrder, scale, i;
    direction := [seq(evalf(segmentEnd[i] - segmentStart[i]),
        i = 1 .. nops(segmentStart))];
    rank := SystemRank(system);
    if max(seq(abs(direction[i]), i = 1 .. nops(direction))) = 0 then
        return [[LinearAlgebra:-IdentityMatrix(rank, datatype = anything)],
            [MakePatchHistoryRecord(0, 0., 1., 1., seriesOrder,
                Digits, 0., 0., infinity, segmentStart, 0.)], 0., 0.];
    end if;
    if not evalb(safetyFactor > 0 and safetyFactor < 1) then
        error "safetyFactor must lie strictly between 0 and 1";
    end if;
    roots := RestrictedSingularRoots(system, segmentStart, segmentEnd,
        'digits' = digits);
    parameter := 0.; patches := 0; factors := []; history := [];
    maximumError := 0.; maximumDifferentialResidual := 0.;
    minimumStep := evalf(10^(-max(20, digits + 8)));
    differentialTolerance := evalf(10^(-max(6,digits-3)));
    totalOrder := seriesOrder + verificationOrder;
    while parameter < 1 do
        patches := patches + 1;
        if patches > maximumSteps then
            error "the fundamental Taylor solver exceeded maximumSteps";
        end if;
        center := [seq(evalf(segmentStart[i] + parameter * direction[i]),
            i = 1 .. nops(direction))];
        nearestRoot := infinity;
        for rootValue in roots do
            nearestRoot := min(nearestRoot, abs(parameter - rootValue));
        end do;
        if nearestRoot <> infinity and nearestRoot <= minimumStep then
            error "a Taylor centre is on or too near a restricted singularity";
        end if;
        permittedStep := `if`(nearestRoot = infinity, 1-parameter,
            safetyFactor * nearestRoot);
        step := min(evalf(1 - parameter), evalf(permittedStep));
        matrixCoefficients := RestrictedMatrixSeries(system, center,
            direction, totalOrder - 1);
        solutionCoefficients := FundamentalSolutionCoefficients(
            matrixCoefficients, rank, totalOrder);
        accepted := false; candidate :=
            LinearAlgebra:-IdentityMatrix(rank, datatype = anything);
        discrepancy := infinity; relativeTail := infinity;
        differentialResidual := infinity;
        while step >= minimumStep do
            highEvaluation := EvaluateFundamentalSeries(
                solutionCoefficients, step, digits);
            lowEvaluation := EvaluateFundamentalSeries(
                solutionCoefficients[1 .. seriesOrder + 1], step,
                max(1, digits - 2));
            candidate := highEvaluation[1];
            scale := max(MatrixMaxAbs(candidate), 1);
            discrepancy := evalf(MatrixMaxAbs(
                candidate - lowEvaluation[1]) / scale);
            relativeTail := highEvaluation[2];
            differentialResidual := FundamentalDifferentialResidual(
                system,center,direction,solutionCoefficients,step,candidate);
            accepted := evalb(highEvaluation[3] and
                discrepancy <= 10^(-max(6, digits - 2)) and
                differentialResidual <= differentialTolerance);
            if accepted then break; end if;
            step := step / 2;
        end do;
        if not accepted then
            error "the fundamental Taylor series did not converge along the selected contour";
        end if;
        factors := [op(factors), candidate];
        history := [op(history), MakePatchHistoryRecord(0, parameter,
            evalf(parameter + step), step, totalOrder, Digits,
            relativeTail, discrepancy, nearestRoot, center,
            differentialResidual)];
        maximumError := max(maximumError, relativeTail, discrepancy);
        maximumDifferentialResidual := max(maximumDifferentialResidual,
            differentialResidual);
        parameter := evalf(parameter + step);
        if abs(1 - parameter) <= 10 * minimumStep then parameter := 1; end if;
        if verbose then
            printf("HyperPrecision: fundamental patch %d, step = %a, root radius = %a, error = %a\n",
                patches, step, nearestRoot,
                max(relativeTail,discrepancy,differentialResidual));
        end if;
    end do;
    return [factors, history, maximumError, maximumDifferentialResidual];
end proc;

ApplyFactorList := proc(factors::list, initialObject)
    local result, factorMatrix;
    result := copy(initialObject);
    for factorMatrix in factors do result := factorMatrix.result; end do;
    return result;
end proc;

MaterializeFactorList := proc(factors::list)
    local rank, result, factorMatrix;
    if nops(factors) = 0 then
        error "an empty factor list has no inferable rank";
    end if;
    rank := LinearAlgebra:-RowDimension(factors[1]);
    result := LinearAlgebra:-IdentityMatrix(rank, datatype = anything);
    for factorMatrix in factors do result := factorMatrix.result; end do;
    return result;
end proc;

InvertFactorList := proc(factors::list)
    local result, identityMatrix, rank, i;
    if nops(factors) = 0 then return []; end if;
    rank := LinearAlgebra:-RowDimension(factors[1]);
    identityMatrix := LinearAlgebra:-IdentityMatrix(rank,
        datatype = anything);
    result := [];
    for i from nops(factors) by -1 to 1 do
        result := [op(result), LinearAlgebra:-LinearSolve(
            factors[i], identityMatrix)];
    end do;
    return result;
end proc;

InvertTransportHistory := proc(history::list,path::list)
    local result, reversedPath, segmentCount, oldEntry, newSegment,
          newStart, newEnd, newCenter, direction, coordinate, i;
    if nops(history) = 0 then return []; end if;
    if nops(path) < 2 then
        error "an inverse transport history requires a nonempty path";
    end if;
    reversedPath := ReversePath(path);
    segmentCount := nops(path)-1;
    result := [];
    for i from nops(history) by -1 to 1 do
        oldEntry := history[i];
        newSegment := segmentCount-oldEntry:-segment+1;
        if newSegment < 1 or newSegment > segmentCount then
            error "a transport history segment is inconsistent with its path";
        end if;
        newStart := evalf(1-oldEntry:-segmentParameterEnd);
        newEnd := evalf(1-oldEntry:-segmentParameterStart);
        direction := [seq(evalf(reversedPath[newSegment+1][coordinate]-
            reversedPath[newSegment][coordinate]),
            coordinate=1..nops(reversedPath[newSegment]))];
        newCenter := [seq(evalf(reversedPath[newSegment][coordinate]+
            newStart*direction[coordinate]),
            coordinate=1..nops(direction))];
        result := [op(result),MakePatchHistoryRecord(newSegment,newStart,
            newEnd,oldEntry:-step,oldEntry:-order,
            oldEntry:-workingDigits,oldEntry:-relativeTail,
            oldEntry:-orderDiscrepancy,oldEntry:-restrictedRadius,
            newCenter,oldEntry:-differentialResidual)];
    end do;
    return result;
end proc;

FactorizedFundamentalTransport := proc(
    factors::list,
    path::list,
    {digits := 50, mode := "fast", diagnostics := NULL, history := []}
)
    local frozenFactors, frozenPath, frozenDiagnostics, frozenHistory,
          frozenDigits, frozenMode,
          applyProcedure, materializeProcedure, inverseProcedure;
    if mode = "certified" then
        error "certified complex-ball transport is not implemented in Maple; use mode=fast";
    elif mode <> "fast" then
        error "transport mode must be fast or certified";
    end if;
    if nops(factors) = 0 then error "factors must not be empty"; end if;
    frozenFactors := map(copy, factors); frozenPath := path;
    frozenDiagnostics := `if`(diagnostics = NULL,
        MakeFactorDiagnosticsRecord(nops(factors)), diagnostics);
    frozenHistory := history; frozenDigits := digits; frozenMode := mode;
    applyProcedure := proc(p1)
        return ApplyFactorList(frozenFactors, p1);
    end proc;
    materializeProcedure := proc()
        return MaterializeFactorList(frozenFactors);
    end proc;
    inverseProcedure := proc()
        return FactorizedFundamentalTransport(InvertFactorList(frozenFactors),
            ReversePath(frozenPath),
            parse("digits")=frozenDigits,parse("mode")=frozenMode,
            parse("diagnostics")=
                MakeInverseDiagnosticsRecord(nops(frozenFactors)),
            parse("history")=
                InvertTransportHistory(frozenHistory,frozenPath));
    end proc;
    return MakeFactorizedRecord(frozenFactors, frozenPath, digits, mode,
        frozenDiagnostics, frozenHistory, applyProcedure,
        materializeProcedure, inverseProcedure);
end proc;

ApplyTransport := proc(transport, initialObject)
    if transport:-hpType <> "FactorizedFundamentalTransport" then
        error "expected a FactorizedFundamentalTransport";
    end if;
    return ApplyFactorList(transport:-factors, initialObject);
end proc;

MaterializeTransport := proc(transport)
    if transport:-hpType <> "FactorizedFundamentalTransport" then
        error "expected a FactorizedFundamentalTransport";
    end if;
    return MaterializeFactorList(transport:-factors);
end proc;

InverseTransport := proc(transport)
    if transport:-hpType <> "FactorizedFundamentalTransport" then
        error "expected a FactorizedFundamentalTransport";
    end if;
    return FactorizedFundamentalTransport(InvertFactorList(transport:-factors),
        ReversePath(transport:-path), 'digits' = transport:-digits,
        'mode' = transport:-mode,
        'diagnostics' = MakeInverseDiagnosticsRecord(nops(transport:-factors)),
        'history' = InvertTransportHistory(transport:-history,
            transport:-path));
end proc;

NormalisePathArgument := proc(system, pathOrPlan)
    local points, point;
    try
        if pathOrPlan:-hpType = "PfaffianPathPlan" then
            points := pathOrPlan:-points;
        else
            points := pathOrPlan;
        end if;
    catch:
        points := pathOrPlan;
    end try;
    if not type(points, list) or nops(points) < 2 then
        error "a transport path must contain at least two points";
    end if;
    for point in points do
        if not type(point, list) or
           nops(point) <> SystemNVariables(system) then
            error "a transport path point has the wrong dimension";
        end if;
    end do;
    return map(p -> map(evalf, p), points);
end proc;

TransportFundamentalOnce := proc(
    system,
    points::list,
    digits::posint,
    seriesOrder::posint,
    maximumSteps::posint,
    safetyFactor,
    verificationOrder::nonnegint,
    verbose::boolean
)
    local factors, history, maximumError, maximumDifferentialResidual,
          segmentResult, segment,
          historyEntry, segmentHistory;
    factors := []; history := []; maximumError := 0.;
    maximumDifferentialResidual := 0.;
    for segment to nops(points)-1 do
        segmentResult := IntegrateSegmentFundamental(system,
            points[segment], points[segment+1], digits, seriesOrder,
            maximumSteps, safetyFactor, verificationOrder, verbose);
        factors := [op(factors), op(segmentResult[1])];
        segmentHistory := [];
        for historyEntry in segmentResult[2] do
            segmentHistory := [op(segmentHistory), MakePatchHistoryRecord(
                segment, historyEntry:-segmentParameterStart,
                historyEntry:-segmentParameterEnd, historyEntry:-step,
                historyEntry:-order, historyEntry:-workingDigits,
                historyEntry:-relativeTail,
                historyEntry:-orderDiscrepancy,
                historyEntry:-restrictedRadius,
                historyEntry:-center,
                historyEntry:-differentialResidual)];
        end do;
        history := [op(history), op(segmentHistory)];
        maximumError := max(maximumError, segmentResult[3]);
        maximumDifferentialResidual := max(maximumDifferentialResidual,
            segmentResult[4]);
    end do;
    return [factors, history, maximumError,maximumDifferentialResidual];
end proc;

TransportFundamental := proc(
    system,
    pathOrPlan,
    {digits := 0, mode := "fast", taylorOrder := 0,
     verificationOrder := 8, maximumSteps := 20000,
     safetyFactor := 0.62, verifyReverse := true,
     maximumPrecisionEscalations := 2, precisionStep := 16,
     verbose := false}
)
    local effectiveDigits, effectiveOrder, points, oldDigits,
          escalation, forwardResult, reverseResult, forwardMatrix,
          reverseMatrix, reverseError, tolerance, diagnostics,
          precisionHistory, result;
    if mode = "certified" then
        error "certified complex-ball transport is not implemented in Maple; use mode=fast";
    elif mode <> "fast" then
        error "transport mode must be fast or certified";
    end if;
    points := NormalisePathArgument(system, pathOrPlan);
    effectiveDigits := `if`(digits = 0, system:-digits, digits);
    effectiveOrder := `if`(taylorOrder = 0,
        max(36, ceil(3.1 * (effectiveDigits + 5))), taylorOrder);
    if effectiveOrder < 8 then error "taylorOrder must be at least 8"; end if;
    precisionHistory := [];
    oldDigits := Digits;
    try
        for escalation from 0 to maximumPrecisionEscalations do
            Digits := max(system:-digits, effectiveDigits + 14);
            forwardResult := TransportFundamentalOnce(system, points,
                effectiveDigits, effectiveOrder, maximumSteps,
                safetyFactor, verificationOrder, verbose);
            reverseError := undefined;
            if verifyReverse then
                reverseResult := TransportFundamentalOnce(system,
                    ReversePath(points), effectiveDigits, effectiveOrder,
                    maximumSteps, safetyFactor, verificationOrder, verbose);
                forwardMatrix := MaterializeFactorList(forwardResult[1]);
                reverseMatrix := MaterializeFactorList(reverseResult[1]);
                reverseError := MatrixIdentityResidual(
                    reverseMatrix.forwardMatrix);
                tolerance := evalf(10^(-max(8, effectiveDigits - 5)));
            else
                tolerance := infinity;
            end if;
            precisionHistory := [op(precisionHistory),
                MakePrecisionAttemptRecord(escalation + 1,
                effectiveDigits, effectiveOrder, forwardResult[3],
                reverseError,forwardResult[4])];
            if not verifyReverse or reverseError <= tolerance then break; end if;
            effectiveDigits := effectiveDigits + precisionStep;
            effectiveOrder := effectiveOrder + max(12, precisionStep);
        end do;
        if verifyReverse and reverseError > tolerance then
            error "reverse-path consistency did not reach the requested tolerance; last residual was %1", reverseError;
        end if;
        diagnostics := MakeTransportDiagnosticsRecord(
            nops(forwardResult[1]), forwardResult[3], verifyReverse,
            reverseError, escalation, effectiveDigits, effectiveOrder,
            precisionHistory,forwardResult[4]);
        result := FactorizedFundamentalTransport(forwardResult[1], points,
            'digits' = effectiveDigits, 'mode' = mode,
            'diagnostics' = diagnostics, 'history' = forwardResult[2]);
    finally
        Digits := oldDigits;
    end try;
    return result;
end proc;

# ---------------------------------------------------------------------------
# Meridian loops and numerical monodromy representations
# ---------------------------------------------------------------------------

UnivariateMeridianLoop := proc(
    system,
    basepoint::list,
    singularity,
    radius,
    vertices::posint,
    digits::posint,
    planner::string
)
    local radialDirection, approach, connectionPlan, connector,
          circle, reverseConnector, points, k;
    if abs(basepoint[1] - singularity) <= radius then
        error "the requested univariate meridian contains the basepoint";
    end if;
    radialDirection := (basepoint[1] - singularity) /
        abs(basepoint[1] - singularity);
    approach := [evalf(singularity + radius * radialDirection)];
    connectionPlan := PlanPath(system, basepoint, approach,
        'mode' = planner, 'digits' = digits, 'branchSide' = -1);
    connector := connectionPlan:-points;
    circle := [seq([evalf(singularity + radius * radialDirection *
        exp(2*Pi*I*k/vertices))], k = 1 .. vertices)];
    reverseConnector := ReversePath(connector);
    points := [op(connector), op(circle)];
    if nops(reverseConnector) > 1 then
        points := [op(points), op(reverseConnector[2 .. -1])];
    end if;
    return points;
end proc;

MultivariateMeridianLoop := proc(
    system,
    basepoint::list,
    singularPoint::list,
    transverseDirection::list,
    radius,
    vertices::posint,
    digits::posint,
    planner::string
)
    local normDirection, normValue, phaseNumerator, phase,
          approachDirection, approach, connectionPlan, connector,
          circle, reverseConnector, points, k, i;
    normValue := sqrt(add(abs(transverseDirection[i])^2,
        i = 1 .. nops(transverseDirection)));
    if normValue = 0 then error "a transverse direction must be nonzero"; end if;
    normDirection := [seq(transverseDirection[i] / normValue,
        i = 1 .. nops(transverseDirection))];
    phaseNumerator := add(conjugate(normDirection[i]) *
        (basepoint[i] - singularPoint[i]),
        i = 1 .. nops(normDirection));
    phase := `if`(abs(phaseNumerator) = 0, 1,
        phaseNumerator / abs(phaseNumerator));
    approachDirection := [seq(phase * normDirection[i],
        i = 1 .. nops(normDirection))];
    approach := [seq(evalf(singularPoint[i] + radius*approachDirection[i]),
        i = 1 .. nops(singularPoint))];
    connectionPlan := PlanPath(system, basepoint, approach,
        'mode' = planner, 'digits' = digits, 'branchSide' = -1);
    connector := connectionPlan:-points;
    circle := [seq([seq(evalf(singularPoint[i] +
        radius*exp(2*Pi*I*k/vertices)*approachDirection[i]),
        i = 1 .. nops(singularPoint))], k = 1 .. vertices)];
    reverseConnector := ReversePath(connector);
    points := [op(connector), op(circle)];
    if nops(reverseConnector) > 1 then
        points := [op(points), op(reverseConnector[2 .. -1])];
    end if;
    return points;
end proc;

LoopSegmentsSafe := proc(system, points::list, digits::posint, clearance)
    local segment, checkValue;
    for segment to nops(points)-1 do
        checkValue := SegmentSafety(system, points[segment],
            points[segment+1], digits, clearance);
        if not checkValue[1] then return false; end if;
    end do;
    return true;
end proc;

ValidateMeridianComponent := proc(
    system,
    singularPoint::list,
    transverseDirection::list,
    digits::posint
)
    local divisor, tolerance, vanishingFactors, transverseFactors,
          factorValue, valueAtPoint, directionalDerivative, i;
    if nops(singularPoint) <> SystemNVariables(system) or
       nops(transverseDirection) <> SystemNVariables(system) then
        error "a meridian component point or direction has the wrong dimension";
    end if;
    if add(abs(transverseDirection[i]),i=1..nops(transverseDirection)) = 0 then
        error "a transverse direction must be nonzero";
    end if;
    divisor := SingularFactors(system);
    tolerance := evalf(10^(-max(8,iquo(digits,2))));
    vanishingFactors := []; transverseFactors := [];
    for factorValue in divisor:-factors do
        valueAtPoint := evalf(subs(seq(divisor:-variables[i]=singularPoint[i],
            i=1..nops(singularPoint)),factorValue));
        if abs(valueAtPoint) <= tolerance then
            vanishingFactors := [op(vanishingFactors),factorValue];
            directionalDerivative := evalf(subs(seq(divisor:-variables[i]=
                singularPoint[i],i=1..nops(singularPoint)),
                add(diff(factorValue,divisor:-variables[i])*
                    transverseDirection[i],i=1..nops(singularPoint))));
            if abs(directionalDerivative) > tolerance then
                transverseFactors := [op(transverseFactors),factorValue];
            end if;
        end if;
    end do;
    if nops(vanishingFactors) = 0 then
        error "the proposed meridian point is not on the detected singular divisor";
    elif nops(vanishingFactors) > 1 then
        error "the proposed meridian point lies on an intersection of detected divisor components";
    elif nops(transverseFactors) <> 1 then
        error "the proposed meridian direction is tangent to the detected divisor component";
    end if;
    return transverseFactors[1];
end proc;

MeridianGenerators := proc(
    system,
    basepoint::list,
    {components := "all", planner := "canonical", digits := 0,
     vertices := 16, radius := 0, maximumRadius := 0.12,
     maximumGenerators := 12}
)
    local effectiveDigits, n, labels, loops, metadata,
          roots, rootValue, singularities, allSingularities, singularity,
          nearestSeparation, other, localRadius, labelValue,
          endpoint, singularPoint, transverse,
          variable, generated, entry, loopPoints, radiusAttempt,
          matchDistance, componentTolerance,
          normValue, normDirection, transverseEndpoint,
          transverseRoots, rootDistance, i;
    effectiveDigits := `if`(digits = 0, system:-digits, digits);
    n := SystemNVariables(system);
    if nops(basepoint) <> n then error "the basepoint has the wrong length"; end if;
    if vertices < 8 then error "a meridian needs at least eight vertices"; end if;
    if radius < 0 or maximumRadius <= 0 then
        error "radius must be nonnegative and maximumRadius must be positive";
    end if;
    componentTolerance := evalf(10^(-max(8,iquo(effectiveDigits,2))));
    labels := []; loops := []; metadata := []; generated := 0;
    if n = 1 then
        roots := RestrictedSingularRoots(system, basepoint,
            [basepoint[1] + 1], 'digits' = effectiveDigits);
        allSingularities := [seq(evalf(basepoint[1] + rootValue),
            rootValue in roots)];
        if components = "all" then
            singularities := allSingularities;
        elif type(components, list) then
            singularities := components;
        else
            error "components must be all or a list of singular points";
        end if;
        for singularity in singularities do
            if generated >= maximumGenerators then break; end if;
            if nops(allSingularities) = 0 then
                error "no univariate singularity was detected";
            end if;
            matchDistance := min(seq(abs(other-singularity),
                other in allSingularities));
            if matchDistance > componentTolerance then
                error "a requested univariate meridian centre is not a detected singular point";
            end if;
            ValidateMeridianComponent(system,[singularity],[1],effectiveDigits);
            nearestSeparation := abs(basepoint[1] - singularity);
            for other in allSingularities do
                if abs(other-singularity) > componentTolerance then
                    nearestSeparation := min(nearestSeparation,
                        abs(other - singularity));
                end if;
            end do;
            if radius <> 0 and radius >= nearestSeparation*(1-componentTolerance) then
                error "the requested univariate meridian radius contains the basepoint or another singular point";
            end if;
            localRadius := `if`(radius = 0,
                min(maximumRadius, 0.18*nearestSeparation), radius);
            if localRadius <= 0 then next; end if;
            for radiusAttempt to 8 do
                loopPoints := UnivariateMeridianLoop(system,
                    map(evalf, basepoint), singularity, localRadius,
                    vertices, effectiveDigits, planner);
                if LoopSegmentsSafe(system, loopPoints, effectiveDigits,
                    10^(-max(8,iquo(effectiveDigits,2)))) then break; end if;
                localRadius := localRadius/2;
            end do;
            if radiusAttempt > 8 then
                error "a safe radius for a univariate meridian was not found";
            end if;
            generated := generated + 1;
            labelValue := cat("D", generated);
            labels := [op(labels), labelValue];
            loops := [op(loops), loopPoints];
            metadata := [op(metadata), MakeMeridianMetadataRecord(
                labelValue, [singularity], [1], localRadius)];
        end do;
    elif components = "all" then
        for variable to n do
            endpoint := [op(basepoint)]; endpoint[variable] := endpoint[variable] + 1;
            roots := RestrictedSingularRoots(system, basepoint, endpoint,
                'digits' = effectiveDigits);
            for rootValue in roots do
                if generated >= maximumGenerators then break; end if;
                singularPoint := [op(basepoint)];
                singularPoint[variable] := singularPoint[variable] + rootValue;
                transverse := [seq(`if`(i = variable, 1, 0), i = 1 .. n)];
                try
                    ValidateMeridianComponent(system,singularPoint,
                        transverse,effectiveDigits);
                catch:
                    next;
                end try;
                nearestSeparation := abs(rootValue);
                for other in roots do
                    if abs(other-rootValue) > componentTolerance then
                        nearestSeparation := min(nearestSeparation,
                            abs(other-rootValue));
                    end if;
                end do;
                if radius <> 0 and
                   radius >= nearestSeparation*(1-componentTolerance) then
                    error "the requested multivariate meridian radius contains the basepoint or another singular point on its transverse slice";
                end if;
                localRadius := `if`(radius = 0,
                    min(maximumRadius, 0.15*nearestSeparation), radius);
                if localRadius <= 0 then next; end if;
                for radiusAttempt to 8 do
                    loopPoints := MultivariateMeridianLoop(system,
                        map(evalf, basepoint), singularPoint, transverse,
                        localRadius, vertices, effectiveDigits, planner);
                    if LoopSegmentsSafe(system, loopPoints, effectiveDigits,
                        10^(-max(8,iquo(effectiveDigits,2)))) then break; end if;
                    localRadius := localRadius/2;
                end do;
                if radiusAttempt > 8 then
                    error "a safe radius for a multivariate meridian was not found";
                end if;
                generated := generated + 1; labelValue := cat("D", generated);
                labels := [op(labels), labelValue];
                loops := [op(loops), loopPoints];
                metadata := [op(metadata), MakeMeridianMetadataRecord(
                    labelValue, singularPoint, transverse, localRadius,
                    variable)];
            end do;
            if generated >= maximumGenerators then break; end if;
        end do;
    elif type(components, list) then
        for entry in components do
            if generated >= maximumGenerators then break; end if;
            try
                singularPoint := entry:-point;
                transverse := entry:-direction;
                labelValue := entry:-label;
            catch:
                error "a multivariate component must be a record with point, direction, and label";
            end try;
            ValidateMeridianComponent(system,singularPoint,transverse,
                effectiveDigits);
            normValue := sqrt(add(abs(transverse[i])^2,i=1..n));
            normDirection := [seq(transverse[i]/normValue,i=1..n)];
            transverseEndpoint := [seq(evalf(singularPoint[i]+
                normDirection[i]),i=1..n)];
            transverseRoots := RestrictedSingularRoots(system,
                singularPoint,transverseEndpoint,'digits'=effectiveDigits);
            if nops(transverseRoots) = 0 or
               min(seq(abs(rootValue),rootValue in transverseRoots)) >
                   componentTolerance then
                error "the proposed meridian centre was not detected as a restricted root on its transverse slice";
            end if;
            nearestSeparation := infinity;
            for rootValue in transverseRoots do
                rootDistance := abs(rootValue);
                if rootDistance > componentTolerance then
                    nearestSeparation := min(nearestSeparation,rootDistance);
                end if;
            end do;
            if radius <> 0 and nearestSeparation <> infinity and
               radius >= nearestSeparation*(1-componentTolerance) then
                error "the requested multivariate meridian radius contains another singular point on its transverse slice";
            end if;
            localRadius := `if`(radius = 0,
                `if`(nearestSeparation=infinity,maximumRadius,
                    min(maximumRadius,0.15*nearestSeparation)),radius);
            for radiusAttempt to 8 do
                loopPoints := MultivariateMeridianLoop(system,
                    map(evalf, basepoint), singularPoint, transverse,
                    localRadius, vertices, effectiveDigits, planner);
                if LoopSegmentsSafe(system, loopPoints, effectiveDigits,
                    10^(-max(8,iquo(effectiveDigits,2)))) then break; end if;
                localRadius := localRadius/2;
            end do;
            if radiusAttempt > 8 then
                error "a safe radius for a user meridian was not found";
            end if;
            generated := generated + 1;
            labels := [op(labels), labelValue];
            loops := [op(loops), loopPoints];
            metadata := [op(metadata), MakeMeridianMetadataRecord(
                labelValue, singularPoint, transverse, localRadius)];
        end do;
    else
        error "components must be all or a list";
    end if;
    if nops(loops) = 0 then
        error "no meridian generator was found on the selected coordinate slices";
    end if;
    return MakeLoopSetRecord(map(evalf, basepoint), labels, loops, metadata);
end proc;

NumericalMonodromyRepresentation := proc(
    basepoint::list,
    basis::list,
    generators,
    matrices::table,
    {verifiedRelations := [], generatorSetComplete := "unknown"}
)
    if not member(generatorSetComplete, ["unknown", "yes", "no"]) then
        error "generatorSetComplete must be unknown, yes, or no";
    end if;
    return MakeMonodromyRecord(basepoint, basis, generators, matrices,
        verifiedRelations, generatorSetComplete);
end proc;

Monodromy := proc(
    system,
    loopsOrGeneratorSet,
    {digits := 0, mode := "fast", taylorOrder := 0,
     verificationOrder := 8, maximumSteps := 20000,
     safetyFactor := 0.62, verifyReverse := true,
     maximumPrecisionEscalations := 2, verbose := false}
)
    local loops, labels, basepoint, matrices, relations,
           transports, transport, labelValue, effectiveDigits,
           loopValue, pointValue, closureTolerance, flatness,
           exactFlatness, normalizedLabels, i, j;
    if not member(system:-hpType,["PfaffianSystem","UserPfaffianSystem"]) then
        error "Monodromy requires a full PfaffianSystem";
    end if;
    try
        if loopsOrGeneratorSet:-hpType = "MeridianGeneratorSet" then
            loops := loopsOrGeneratorSet:-loops;
            labels := loopsOrGeneratorSet:-labels;
            basepoint := loopsOrGeneratorSet:-basepoint;
        else
            error "not generator set";
        end if;
    catch:
        loops := loopsOrGeneratorSet;
        if not type(loops,list) or nops(loops) = 0 then
            error "the loop list is empty";
        end if;
        labels := [seq(cat("D", i), i = 1 .. nops(loops))];
        basepoint := loops[1][1];
    end try;
    if not type(loops,list) or nops(loops) = 0 then
        error "the loop list is empty";
    end if;
    if nops(labels) <> nops(loops) then
        error "the number of loop labels does not match the loop count";
    end if;
    if not andmap(labelEntry -> type(labelEntry,{string,symbol}),labels) then
        error "monodromy generator labels must be strings or symbols";
    end if;
    normalizedLabels := map(labelEntry -> convert(labelEntry,string),labels);
    if nops(convert(normalizedLabels,set)) <> nops(normalizedLabels) then
        error "monodromy generator labels must be unique";
    end if;
    labels := normalizedLabels;
    effectiveDigits := `if`(digits = 0, system:-digits, digits);
    closureTolerance := evalf(10^(-max(8,iquo(effectiveDigits,2))));
    if not type(basepoint,list) or
       nops(basepoint) <> SystemNVariables(system) then
        error "the loop basepoint has the wrong dimension";
    end if;
    for loopValue in loops do
        if not type(loopValue,list) or nops(loopValue) < 2 then
            error "each monodromy generator must be a nonempty closed path";
        end if;
        for pointValue in loopValue do
            if not type(pointValue,list) or
               nops(pointValue) <> nops(basepoint) then
                error "a monodromy path point has the wrong dimension";
            end if;
        end do;
        if max(seq(abs(loopValue[1][j]-loopValue[-1][j]),
            j = 1 .. nops(basepoint))) > closureTolerance then
            error "an open path cannot be used as a monodromy generator";
        end if;
        if max(seq(abs(loopValue[1][j]-basepoint[j]),
            j = 1 .. nops(basepoint))) > closureTolerance then
            error "all monodromy generators must have the same basepoint";
        end if;
    end do;
    if system:-hpType = "UserPfaffianSystem" then
        exactFlatness := system:-exactFlatness;
        if exactFlatness:-status = "unknown_inexact" then
            error "numerical user Pfaffian connections cannot be certified flat and are not accepted for monodromy";
        elif not exactFlatness:-passed then
            error "the user Pfaffian connection is not symbolically flat; nonzero curvature entries=%1", exactFlatness:-nonzeroCurvatures;
        end if;
    end if;
    flatness := CheckIntegrability(system,'point'=basepoint);
    if not flatness:-passed then
        error "the supplied Pfaffian connection failed the flatness check at the loop basepoint; residual=%1", flatness:-residual;
    end if;
    matrices := table(); transports := table(); relations := [];
    for i to nops(loops) do
        labelValue := labels[i];
        transport := TransportFundamental(system, loops[i],
            'digits' = digits, 'mode' = mode,
            'taylorOrder' = taylorOrder,
            'verificationOrder' = verificationOrder,
            'maximumSteps' = maximumSteps,
            'safetyFactor' = safetyFactor,
            'verifyReverse' = verifyReverse,
            'maximumPrecisionEscalations' = maximumPrecisionEscalations,
            'verbose' = verbose);
        matrices[labelValue] := MaterializeTransport(transport);
        transports[labelValue] := transport;
        if verifyReverse then
            relations := [op(relations), MakeRelationRecord(
                cat(labelValue, "^-1*", labelValue),
                transport:-diagnostics:-reverseError, true)];
        end if;
    end do;
    return MakeMonodromyRecord(basepoint, system:-basis,
        MakeGeneratorBundleRecord(loops, labels, transports), matrices,
        relations, "unknown");
end proc;

MonodromyMatrix := proc(representation, labelValue)
    local lookupKey;
    if representation:-hpType <> "NumericalMonodromyRepresentation" then
        error "expected a NumericalMonodromyRepresentation";
    end if;
    lookupKey := labelValue;
    if not assigned(representation:-matrices[lookupKey]) and
       type(labelValue, symbol) then
        lookupKey := convert(labelValue, string);
    end if;
    if not assigned(representation:-matrices[lookupKey]) then
        error "unknown monodromy generator %1", labelValue;
    end if;
    return representation:-matrices[lookupKey];
end proc;

NormaliseWaypoints := proc(target::list, branchSide::integer, waypoints::list)
    local realTarget, imaginaryShift, path, point, numericPoint, i;
    if not member(branchSide, [-1, 0, 1]) then error "branchSide must be -1, 0, or 1"; end if;
    if not andmap(IsFiniteNumber,target) then
        error "the transport target must contain finite numeric coordinates";
    end if;
    if nops(waypoints) > 0 then
        path := [];
        for point in waypoints do
            if nops(point) <> nops(target) then error "a contour waypoint has the wrong length"; end if;
            numericPoint := map(evalf,point);
            if not andmap(IsFiniteNumber,numericPoint) then
                error "a contour waypoint contains a nonfinite coordinate";
            end if;
            path := [op(path),numericPoint];
        end do;
        if nops(path) = 0 or max(seq(abs(path[-1][i] - target[i]), i = 1 .. nops(target))) <> 0 then
            path := [op(path), target];
        end if;
        return path;
    end if;
    realTarget := andmap(value -> evalb(Im(value) = 0), target);
    if branchSide <> 0 and realTarget then
        imaginaryShift := evalf(I * branchSide * 0.18);
        return [
            [seq(evalf((0.25 + imaginaryShift) * target[i]), i = 1 .. nops(target))],
            [seq(evalf((0.75 + imaginaryShift) * target[i]), i = 1 .. nops(target))],
            target
        ];
    end if;
    return [target];
end proc;

FindRestrictedPfaffianSystem := proc(
    series,
    target::list,
    {epsilon := 0, digits := 50, branchSide := -1, waypoints := [], maximumSeed := 0}
)
    local system, path;
    system := FindPfaffianSystem(series,parse("epsilon")=epsilon,
        parse("digits")=digits,parse("maximumSeed")=maximumSeed);
    path := NormaliseWaypoints(map(evalf, target), branchSide, waypoints);
    return MakeRestrictedRecord(system, map(evalf, target), path);
end proc;

TransportDE := proc(
    systemOrRestricted,
    targetArgument := [],
    {digits := 0, branchSide := -1, waypoints := [], frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    local system, target, path, effectiveDigits, direct, directBasis,
          boundary, current, value, endpoint, localSeriesOrder,
          oldDigits, result,pathRequested;
    if systemOrRestricted:-hpType = "RestrictedPfaffianSystem" then
        system := systemOrRestricted:-system;
        target := systemOrRestricted:-target;
        path := systemOrRestricted:-waypoints;
        branchSide := 0;
        pathRequested := true;
    else
        system := systemOrRestricted;
        target := map(evalf, targetArgument);
        pathRequested := evalb(nops(waypoints)>0 or branchSide<>-1);
        path := `if`(pathRequested,
            NormaliseWaypoints(target,branchSide,waypoints),[]);
    end if;
    effectiveDigits := `if`(digits = 0, system:-digits, digits);
    oldDigits := Digits; Digits := max(system:-digits, effectiveDigits + 12);
    try
        if not pathRequested then
            direct := DirectSeriesValue(system:-series, target, effectiveDigits,
                min(maximumDegree, 180));
            if direct[2] then
                directBasis := SeriesVector(system:-series, target, system:-basis,
                    effectiveDigits, maximumDegree);
                if directBasis[2] then
                    result := directBasis[1];
                    return result;
                end if;
            end if;
        end if;
        boundary := BoundarySeries(system, target, maximumDegree);
        current := boundary[1]; value := boundary[2];
        if nops(path) = 0 then path := NormaliseWaypoints(target, branchSide, waypoints); end if;
        localSeriesOrder := `if`(frobeniusOrder = 0,
            max(40, ceil(3.4 * (effectiveDigits + 6))), frobeniusOrder);
        if localSeriesOrder < 8 then error "frobeniusOrder must be at least 8"; end if;
        for endpoint in path do
            value := IntegrateSegmentFrobenius(system, current, endpoint, value,
                effectiveDigits, localSeriesOrder, maximumSteps, verbose);
            current := endpoint;
        end do;
        result := value;
    finally
        Digits := oldDigits;
    end try;
    return result;
end proc;

ChopValue := proc(value, digits::posint)
    local threshold, realPart, imaginaryPart,scale;
    threshold := evalf(10^(-digits));
    realPart := Re(value); imaginaryPart := Im(value);
    scale := max(abs(realPart),abs(imaginaryPart));
    if evalb(scale=0) then return 0; end if;
    realPart := `if`(abs(realPart)<=threshold*scale,0,realPart);
    imaginaryPart := `if`(abs(imaginaryPart)<=threshold*scale,0,imaginaryPart);
    if imaginaryPart = 0 then return evalf(realPart); end if;
    return evalf(realPart + I * imaginaryPart);
end proc;

Evaluate := proc(
    series,
    target::list,
    {digits := 50, epsilon := 0, branchSide := -1, waypoints := [],
     maximumSeed := 0, frobeniusOrder := 0, maximumDegree := 260,
     maximumSteps := 20000, verbose := false, method := "auto",
     returnDiagnostics := false, returnDerivatives := false}
)
    local oldDigits, workingDigits, active, restrictedSeries,
          restrictedTarget, restrictedWaypoints, exactSeries,
          simplifiedExactSeries,numeric,system,vector,result,i,j,point,
          familyName,pathRequested,needDerivatives,evaluationAvailable,
          evaluationVector,seriesResult,methodUsed,certificate,degreeUsed,
          errorEstimate,estimatedDegree,radius,seriesDegree,
          terminationDegree,nativeSafe,transportFactors,startTime,
          presentedValues,derivatives,unit,position,upperCount,lowerCount,
          preferGeneric,neighborTerms,guardDigits,transientDegree,
          sourceDigits,specialResult,connectionAtTarget,
          univariateReduction,pfqLike;
    startTime := time();
    if digits < 1 then error "digits must be positive"; end if;
    if not member(method,["auto","series","native","pfaffian","generic"]) then
        error "method must be auto, series, native, pfaffian, or generic";
    end if;
    if nops(target) <> series:-nvariables then error "the target has the wrong length"; end if;
    pathRequested := evalb(nops(waypoints)>0 or branchSide<>-1);
    if pathRequested and member(method,["series","native"]) then
        error "series and native methods evaluate the principal origin germ and cannot honour an explicit path or branch-side request; use method=pfaffian";
    end if;
    needDerivatives := evalb(returnDerivatives or returnDiagnostics);
    if needDerivatives then
        active := [seq(i,i=1..nops(target))];
    else
        active := [];
        for i to nops(target) do
            if target[i]<>0 then active := [op(active),i]; end if;
        end do;
    end if;
    if nops(active)=0 then active := [seq(i,i=1..nops(target))]; end if;
    restrictedSeries := RestrictZeroVariables(series, active);
    restrictedTarget := [seq(target[active[i]], i = 1 .. nops(active))];
    restrictedWaypoints := [];
    for point in waypoints do
        if nops(point) <> nops(target) then error "a contour waypoint has the wrong length"; end if;
        restrictedWaypoints := [op(restrictedWaypoints),
            [seq(point[active[i]], i = 1 .. nops(active))]];
    end do;
    sourceDigits := HypergeometricSourceDigits(restrictedSeries,
        restrictedTarget,restrictedWaypoints,epsilon);
    workingDigits := max(digits+14,sourceDigits);
    oldDigits := Digits; Digits := workingDigits;
    evaluationAvailable := false; evaluationVector := Vector(0);
    methodUsed := "none"; certificate := "not_applicable";
    degreeUsed := -1; errorEstimate := infinity; estimatedDegree := -1;
    transportFactors := 0;
    try
        exactSeries := ExactParameterSeries(restrictedSeries,epsilon);
        simplifiedExactSeries := CancelExactSeriesParameters(exactSeries);
        guardDigits := HypergeometricConditioningGuardDigits(
            simplifiedExactSeries,restrictedTarget);
        workingDigits := digits+14+guardDigits;
        Digits := workingDigits;
        numeric := NumericParameterSeries(simplifiedExactSeries);
        familyName := StringTools:-LowerCase(restrictedSeries:-name);
        univariateReduction := evalb(simplifiedExactSeries:-nvariables=1 and
            andmap(row->evalb(row=[1]),
                [op(simplifiedExactSeries:-upperWeights),
                 op(simplifiedExactSeries:-lowerWeights)]));
        pfqLike := evalb(member(familyName,
            ["hypergeometricpfq","hypergeometric2f1"]) or
            univariateReduction);
        restrictedTarget := map(evalf,restrictedTarget);
        if pfqLike then
            PFQExactTerminationAndPoleCheck(simplifiedExactSeries);
        elif member(familyName,["lauricellafa","lauricellafb","lauricellafc",
                                "appellf2","appellf3","appellf4"]) then
            terminationDegree := LauricellaConvolutionTerminationDegree(exactSeries);
            ValidateLauricellaConvolutionParameters(exactSeries,terminationDegree);
        elif familyName="lauricellafd" and
             nops(simplifiedExactSeries:-lowerParameters)>0 and
             type(simplifiedExactSeries:-lowerParameters[1],integer) and
             simplifiedExactSeries:-lowerParameters[1]<=0 then
            terminationDegree := ExactTotalTerminationDegree(simplifiedExactSeries);
            if terminationDegree=infinity or terminationDegree>=
               1-simplifiedExactSeries:-lowerParameters[1] then
                error "the Lauricella FD series has an uncancelled singular lower parameter";
            end if;
        end if;

        if not pathRequested and
           pfqLike and
           method="auto" then
            terminationDegree := ExactTotalTerminationDegree(
                simplifiedExactSeries);
            if terminationDegree<>infinity and
               (terminationDegree<=maximumDegree or
                (nops(simplifiedExactSeries:-upperParameters)=1 and
                 nops(simplifiedExactSeries:-lowerParameters)=0 and
                 evalb(restrictedTarget[1]=1 or
                       restrictedTarget[1]=2))) then
                specialResult := PFQExactClosedFormVector(simplifiedExactSeries,
                    restrictedTarget[1]);
                if specialResult[1] then
                    evaluationVector := specialResult[2];
                    evaluationAvailable := true; methodUsed := "closed_form";
                    degreeUsed := terminationDegree;
                    certificate := specialResult[3];
                    errorEstimate := HypergeometricRoundingAllowance(
                        evaluationVector[1],digits+4);
                end if;
            end if;
        end if;

        if not evaluationAvailable and not pathRequested and
           pfqLike and
           member(method,["auto","series"]) then
            terminationDegree := ExactTotalTerminationDegree(simplifiedExactSeries);
            radius := abs(restrictedTarget[1]);
            upperCount := nops(simplifiedExactSeries:-upperParameters);
            lowerCount := nops(simplifiedExactSeries:-lowerParameters);
            estimatedDegree := `if`(terminationDegree<>infinity,
                terminationDegree,`if`(upperCount<=lowerCount,
                    maximumDegree,HypergeometricSeriesDegree(radius,digits)));
            transientDegree := HypergeometricTransientDegree(simplifiedExactSeries);
            if terminationDegree=infinity and estimatedDegree<>infinity and
               transientDegree>0 then
                estimatedDegree := estimatedDegree+transientDegree+12;
            end if;
            if terminationDegree=infinity and transientDegree>0 and
               estimatedDegree<>infinity and
               estimatedDegree>maximumDegree then
                error "maximumDegree=%1 is below the near-pole transient-and-tail degree %2",maximumDegree,estimatedDegree;
            end if;
            if method="series" or terminationDegree<>infinity or
               upperCount<=lowerCount or
               (upperCount=lowerCount+1 and radius<1 and
                estimatedDegree<=maximumDegree) then
                seriesDegree := `if`(terminationDegree=infinity,
                    `if`(upperCount<=lowerCount or estimatedDegree=infinity,
                        maximumDegree,
                        min(maximumDegree,max(16,estimatedDegree))),
                    maximumDegree);
                seriesResult := PFQFastSeriesChecked(simplifiedExactSeries,
                    restrictedTarget[1],digits,max(1,seriesDegree));
                if not seriesResult[2] and terminationDegree=infinity and
                   seriesDegree<maximumDegree and
                   (method="series" or transientDegree>0) then
                    seriesDegree := maximumDegree;
                    seriesResult := PFQFastSeriesChecked(simplifiedExactSeries,
                        restrictedTarget[1],digits,max(1,seriesDegree));
                end if;
                if seriesResult[2] then
                    evaluationVector := seriesResult[1]; evaluationAvailable := true;
                    methodUsed := "series"; degreeUsed := seriesResult[3];
                    errorEstimate := seriesResult[4]; certificate := seriesResult[7];
                elif terminationDegree<>infinity then
                    error "the terminating generalized hypergeometric recurrence remained precision-unstable through its bounded precision ladder";
                elif method="series" then
                    error "the generalized hypergeometric recurrence did not certify %1 digits through degree %2",digits,seriesDegree;
                end if;
            elif method="series" then
                error "the requested generalized hypergeometric series is outside its convergence disk";
            end if;
        end if;

        if not evaluationAvailable and not pathRequested and
           member(familyName,["lauricellafa","lauricellafb","lauricellafc",
                              "appellf2","appellf3","appellf4"]) and
           not univariateReduction and
           member(method,["auto","series"]) then
            radius := LauricellaConvolutionRadius(exactSeries:-name,restrictedTarget);
            terminationDegree := LauricellaConvolutionTerminationDegree(exactSeries);
            estimatedDegree := `if`(terminationDegree=infinity,
                HypergeometricSeriesDegree(radius,digits),terminationDegree);
            transientDegree := HypergeometricTransientDegree(exactSeries);
            if terminationDegree=infinity and estimatedDegree<>infinity and
               transientDegree>0 then
                estimatedDegree := estimatedDegree+transientDegree+12;
            end if;
            if terminationDegree=infinity and transientDegree>0 and
               estimatedDegree<>infinity and
               estimatedDegree>maximumDegree then
                error "maximumDegree=%1 is below the near-pole transient-and-tail degree %2",maximumDegree,estimatedDegree;
            end if;
            seriesDegree := `if`(terminationDegree=infinity,
                `if`(estimatedDegree=infinity,maximumDegree,
                    min(maximumDegree,max(16,estimatedDegree+12))),
                maximumDegree);
            if method="series" or terminationDegree<>infinity or radius<1 then
                seriesResult := LauricellaConvolutionChecked(exactSeries,
                    restrictedTarget,digits,max(1,seriesDegree));
                if not seriesResult[2] and terminationDegree=infinity and
                   seriesDegree<maximumDegree and
                   (method="series" or transientDegree>0) then
                    seriesDegree := maximumDegree;
                    seriesResult := LauricellaConvolutionChecked(exactSeries,
                        restrictedTarget,digits,max(1,seriesDegree));
                end if;
                if verbose then
                    printf("HyperPrecision: %s convolution degree %a, estimated degree %a, radius %a, error %a, certificate %s\n",restrictedSeries:-name,seriesResult[3],seriesResult[9],seriesResult[10],seriesResult[4],seriesResult[8]);
                end if;
                if seriesResult[2] then
                    evaluationVector := seriesResult[1]; evaluationAvailable := true;
                    methodUsed := "convolution"; degreeUsed := seriesResult[3];
                    errorEstimate := seriesResult[4]; certificate := seriesResult[8];
                    estimatedDegree := seriesResult[9];
                elif terminationDegree<>infinity then
                    error "the terminating %1 convolution remained precision-unstable through its bounded precision ladder",restrictedSeries:-name;
                elif method="series" then
                    error "the %1 convolution did not certify %2 digits through degree %3 (%4)",restrictedSeries:-name,digits,seriesDegree,seriesResult[8];
                end if;
            elif method="series" then
                error "the requested %1 series is outside its standard convergence domain",restrictedSeries:-name;
            end if;
        end if;

        if not evaluationAvailable and not pathRequested and
           member(familyName,["horng1","horng2","horng3","hornh1","hornh2",
                              "hornh3","hornh4","hornh5","hornh6","hornh7"]) and
           member(method,["auto","series"]) then
            terminationDegree := ExactFiniteSupportDegree(simplifiedExactSeries);
            radius := evalf(4*add(abs(restrictedTarget[i]),i=1..nops(restrictedTarget)));
            estimatedDegree := `if`(terminationDegree=infinity,
                HypergeometricSeriesDegree(radius,digits),terminationDegree);
            transientDegree := HypergeometricTransientDegree(simplifiedExactSeries);
            if terminationDegree=infinity and estimatedDegree<>infinity and
               transientDegree>0 then
                estimatedDegree := estimatedDegree+transientDegree+12;
            end if;
            if terminationDegree=infinity and transientDegree>0 and
               estimatedDegree<>infinity and
               estimatedDegree>maximumDegree then
                error "maximumDegree=%1 is below the near-pole transient-and-tail degree %2",maximumDegree,estimatedDegree;
            end if;
            if method="series" or terminationDegree<>infinity or radius<1 then
                seriesDegree := `if`(terminationDegree=infinity,
                    `if`(estimatedDegree=infinity,maximumDegree,
                        min(maximumDegree,max(24,estimatedDegree+12))),
                    maximumDegree);
                # G1 has a low-rank generic connection.  Once the two checked
                # total-degree grids exceed this calibrated term count, even a
                # cold Pfaffian construction is faster.  An explicit series
                # request always retains the neighbor-ratio implementation.
                neighborTerms := binomial(seriesDegree+nops(restrictedTarget),
                    nops(restrictedTarget))+binomial(
                    floor(seriesDegree/2)+nops(restrictedTarget),
                    nops(restrictedTarget));
                preferGeneric := evalb(method="auto" and familyName="horng1" and
                    nops(restrictedTarget)=2 and terminationDegree=infinity and
                    neighborTerms>1600);
                if not preferGeneric then
                    seriesResult := HornFastGridChecked(simplifiedExactSeries,
                        restrictedTarget,digits,max(1,seriesDegree),
                        `if`(terminationDegree=infinity and transientDegree>0,
                            min(seriesDegree-8,estimatedDegree),-1),
                        needDerivatives);
                    if not seriesResult[2] and terminationDegree=infinity and
                       seriesDegree<maximumDegree and
                       (method="series" or transientDegree>0) then
                        seriesDegree := maximumDegree;
                        seriesResult := HornFastGridChecked(simplifiedExactSeries,
                            restrictedTarget,digits,max(1,seriesDegree),
                            `if`(transientDegree>0,
                                min(seriesDegree-8,estimatedDegree),-1),
                            needDerivatives);
                    end if;
                    if seriesResult[2] then
                        evaluationVector := seriesResult[1]; evaluationAvailable := true;
                        methodUsed := "neighbor_series"; degreeUsed := seriesResult[3];
                        errorEstimate := seriesResult[4]; certificate := seriesResult[8];
                    elif terminationDegree<>infinity then
                        error "the terminating Horn neighbor recurrence remained precision-unstable through its bounded precision ladder";
                    elif method="series" then
                        error "the Horn neighbor recurrence did not certify %1 digits through degree %2",digits,seriesDegree;
                    end if;
                end if;
            elif method="series" then
                error "automatic Horn series evaluation is restricted to its conservative interior; use method=pfaffian with an explicit path";
            end if;
        end if;

        if not evaluationAvailable and not pathRequested and
           not member(familyName,["hypergeometricpfq","hypergeometric2f1",
               "lauricellafa","lauricellafb","lauricellafc",
               "appellf1","appellf2","appellf3","appellf4",
               "horng1","horng2","horng3","hornh1","hornh2","hornh3",
               "hornh4","hornh5","hornh6","hornh7","lauricellafd"]) and
           member(method,["auto","series"]) then
            terminationDegree := ExactFiniteSupportDegree(simplifiedExactSeries);
            radius := evalf(4*add(abs(restrictedTarget[i]),i=1..nops(restrictedTarget)));
            estimatedDegree := `if`(terminationDegree=infinity,
                HypergeometricSeriesDegree(radius,digits),terminationDegree);
            transientDegree := HypergeometricTransientDegree(simplifiedExactSeries);
            if terminationDegree=infinity and estimatedDegree<>infinity and
               transientDegree>0 then
                estimatedDegree := estimatedDegree+transientDegree+12;
            end if;
            if terminationDegree=infinity and transientDegree>0 and
               estimatedDegree<>infinity and
               estimatedDegree>maximumDegree then
                error "maximumDegree=%1 is below the near-pole transient-and-tail degree %2",maximumDegree,estimatedDegree;
            end if;
            if method="series" or terminationDegree<>infinity or radius<1 then
                seriesDegree := `if`(terminationDegree=infinity,
                    `if`(estimatedDegree=infinity,maximumDegree,
                        min(maximumDegree,max(24,estimatedDegree+12))),
                    maximumDegree);
                seriesResult := HornFastGridChecked(simplifiedExactSeries,
                    restrictedTarget,digits,max(1,seriesDegree),
                    `if`(terminationDegree=infinity and transientDegree>0,
                        min(seriesDegree-8,estimatedDegree),-1),
                    needDerivatives);
                if not seriesResult[2] and terminationDegree=infinity and
                   seriesDegree<maximumDegree and
                   (method="series" or transientDegree>0) then
                    seriesDegree := maximumDegree;
                    seriesResult := HornFastGridChecked(simplifiedExactSeries,
                        restrictedTarget,digits,max(1,seriesDegree),
                        `if`(transientDegree>0,
                            min(seriesDegree-8,estimatedDegree),-1),
                        needDerivatives);
                end if;
                if seriesResult[2] then
                    evaluationVector := seriesResult[1]; evaluationAvailable := true;
                    methodUsed := "neighbor_series"; degreeUsed := seriesResult[3];
                    errorEstimate := seriesResult[4]; certificate := seriesResult[8];
                elif terminationDegree<>infinity then
                    error "the terminating Horn neighbor recurrence remained precision-unstable through its bounded precision ladder";
                elif method="series" then
                    error "the Horn neighbor recurrence did not certify the requested precision within maximumDegree";
                end if;
            elif method="series" then
                error "the requested Horn series is outside the conservative series selector";
            end if;
        end if;

        if not evaluationAvailable and
           pfqLike then
            upperCount := nops(simplifiedExactSeries:-upperParameters);
            lowerCount := nops(simplifiedExactSeries:-lowerParameters);
            terminationDegree := ExactTotalTerminationDegree(simplifiedExactSeries);
            if terminationDegree=infinity and upperCount>lowerCount+1 and
               method<>"native" then
                error "the defining pFq series is divergent for p>q+1; select method=native explicitly if Maple's continuation is intended";
            end if;
        end if;

        if not evaluationAvailable and not pathRequested and
           pfqLike and
           member(method,["auto","native"]) then
            upperCount := nops(simplifiedExactSeries:-upperParameters);
            lowerCount := nops(simplifiedExactSeries:-lowerParameters);
            nativeSafe := evalb(upperCount<=lowerCount or
                Im(restrictedTarget[1])<>0 or Re(restrictedTarget[1])<1);
            if nativeSafe then
                evaluationVector := PFQNativeValue(simplifiedExactSeries,
                    restrictedTarget[1],digits+4+guardDigits);
                evaluationAvailable := true; methodUsed := "native";
                degreeUsed := -1; certificate := "maple_native";
                errorEstimate := HypergeometricRoundingAllowance(
                    evaluationVector[1],digits+4);
            elif method="native" then
                error "the native method cannot honour a requested side of the real branch cut; use method=pfaffian";
            end if;
        elif method="native" and not
             pfqLike then
            error "the native method is available only for generalized univariate hypergeometric functions";
        end if;

        if not evaluationAvailable then
            EnsureGenericPfaffianSafe(numeric,maximumSeed);
            system := DerivePfaffian(numeric, workingDigits, maximumSeed);
            vector := TransportDE(system,restrictedTarget,
                parse("digits")=digits+4,
                parse("branchSide")=branchSide,
                parse("waypoints")=restrictedWaypoints,
                parse("frobeniusOrder")=frobeniusOrder,
                parse("maximumDegree")=maximumDegree,
                parse("maximumSteps")=maximumSteps,
                parse("verbose")=verbose);
            evaluationVector := Vector(nops(active)+1,datatype=anything);
            evaluationVector[1] := vector[1];
            connectionAtTarget := NULL;
            for i to nops(active) do
                unit := UnitIndex(nops(active),i); position := 0;
                for j to nops(system:-basis) do
                    if evalb(system:-basis[j]=unit) then position := j; break; end if;
                end do;
                if position=0 then
                    if nops(system:-basis)=1 then
                        if connectionAtTarget=NULL then
                            connectionAtTarget := ConnectionMatricesInternal(
                                system,restrictedTarget);
                        end if;
                        evaluationVector[i+1] :=
                            connectionAtTarget[i][1,1]*vector[1];
                    elif needDerivatives then
                        error "the generic Pfaffian basis does not expose derivative %1",i;
                    else
                        evaluationVector[i+1] := 0;
                    end if;
                else
                    evaluationVector[i+1] := vector[position];
                end if;
            end do;
            evaluationAvailable := true; methodUsed := "pfaffian";
            certificate := "transport_error_unknown"; degreeUsed := -1;
            errorEstimate := infinity;
            transportFactors := -1;
        end if;

        presentedValues := [seq(evalf[digits](ChopValue(
            evaluationVector[i],digits)),i=1..nops(active)+1)];
        result := presentedValues[1];
        derivatives := `if`(needDerivatives,presentedValues[2..-1],[]);
    finally
        Digits := oldDigits;
    end try;
    if returnDiagnostics then
        errorEstimate := max(errorEstimate,
            HypergeometricRoundingAllowance(result,digits));
        return MakeHypergeometricEvaluationRecord(result,derivatives,
            methodUsed,degreeUsed,errorEstimate,evalf(time()-startTime),
            certificate,series:-name,nops(active),estimatedDegree,
            transportFactors);
    elif returnDerivatives then
        return Vector([result,op(derivatives)],datatype=anything);
    end if;
    return result;
end proc;

# ---------------------------------------------------------------------------
# Laurent reconstruction in epsilon
# ---------------------------------------------------------------------------

EstimatePoleOrder := proc(series)
    local order, i, parameter, constant, weights;
    order := 0;
    for i to nops(series:-lowerParameters) do
        parameter := series:-lowerParameters[i];
        if parameter:-slope = 0 then next; end if;
        constant := parameter:-constant;
        if type(constant, integer) and constant <= 0 then
            weights := series:-lowerWeights[i];
            if ormap(w -> evalb(w > 0), weights) then order := order + 1; end if;
        end if;
    end do;
    for i to nops(series:-upperParameters) do
        parameter := series:-upperParameters[i];
        if parameter:-slope = 0 then next; end if;
        constant := parameter:-constant;
        if type(constant, integer) and constant > 0 then
            weights := series:-upperWeights[i];
            if ormap(w -> evalb(w < 0), weights) then order := order + 1; end if;
        end if;
    end do;
    return order;
end proc;

HypExpand := proc(
    series,
    target::list,
    epsilonOrder::nonnegint,
    digits::posint,
    {poleOrder := "automatic", interpolationGuard := 3, branchSide := -1,
     waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    local inferredPole, targetDegree, fitDegree, sampleCount, scaleExponent,
          workingDigits, oldDigits, epsilonScale, scaledNodes, valuesAtNodes,
          index, epsilonValue, value, vandermonde, row, column, power,
          scaledCoefficients, coefficients, exponent, polynomialDegree,
          coefficient, validationNode, validationEpsilon, validationValue,
          reconstructed, estimatedError, result, i;
    if interpolationGuard < 1 then error "interpolationGuard must be positive"; end if;
    inferredPole := `if`(poleOrder = "automatic", EstimatePoleOrder(series), poleOrder);
    if not type(inferredPole, nonnegint) then error "poleOrder must be non-negative"; end if;
    if not HasEpsilon(series) then
        value := Evaluate(series,target,parse("digits")=digits,
            parse("branchSide")=branchSide,parse("waypoints")=waypoints,
            parse("maximumSeed")=maximumSeed,
            parse("frobeniusOrder")=frobeniusOrder,
            parse("maximumDegree")=maximumDegree,
            parse("maximumSteps")=maximumSteps,parse("verbose")=verbose);
        coefficients := [value, seq(0, i = 1 .. epsilonOrder)];
        return MakeLaurentRecord(0, coefficients, 0, digits);
    end if;
    targetDegree := inferredPole + epsilonOrder;
    fitDegree := targetDegree + interpolationGuard;
    sampleCount := fitDegree + 1;
    scaleExponent := max(2, ceil((digits + 10) / (fitDegree + 1)));
    workingDigits := digits + scaleExponent * (targetDegree + 3) + 18;
    oldDigits := Digits; Digits := workingDigits;
    try
        epsilonScale := evalf(10^(-scaleExponent));
        scaledNodes := [seq(evalf(1 + (index - 1) / (2 * sampleCount + 1)),
            index = 1 .. sampleCount)];
        valuesAtNodes := Vector(sampleCount, datatype = anything);
        for index to sampleCount do
            epsilonValue := evalf(epsilonScale * scaledNodes[index]);
            if verbose then
                printf("HyperPrecision: epsilon sample %d/%d at %a\n",
                    index, sampleCount, epsilonValue);
            end if;
            value := Evaluate(series,target,parse("digits")=workingDigits,
                parse("epsilon")=epsilonValue,
                parse("branchSide")=branchSide,parse("waypoints")=waypoints,
                parse("maximumSeed")=maximumSeed,
                parse("frobeniusOrder")=frobeniusOrder,
                parse("maximumDegree")=maximumDegree,
                parse("maximumSteps")=maximumSteps,parse("verbose")=false);
            valuesAtNodes[index] := evalf(value *
                (epsilonScale * scaledNodes[index])^inferredPole);
        end do;
        vandermonde := Matrix(sampleCount, sampleCount, datatype = anything);
        for row to sampleCount do
            power := 1;
            for column to sampleCount do
                vandermonde[row, column] := power;
                power := power * scaledNodes[row];
            end do;
        end do;
        scaledCoefficients := LinearAlgebra:-LinearSolve(vandermonde, valuesAtNodes);
        coefficients := [];
        for exponent from -inferredPole to epsilonOrder do
            polynomialDegree := exponent + inferredPole;
            coefficient := scaledCoefficients[polynomialDegree + 1] /
                epsilonScale^polynomialDegree;
            coefficients := [op(coefficients), ChopValue(coefficient, digits)];
        end do;
        validationNode := evalf(1.75);
        validationEpsilon := evalf(epsilonScale * validationNode);
        validationValue := Evaluate(series,target,
            parse("digits")=workingDigits,parse("epsilon")=validationEpsilon,
            parse("branchSide")=branchSide,parse("waypoints")=waypoints,
            parse("maximumSeed")=maximumSeed,
            parse("frobeniusOrder")=frobeniusOrder,
            parse("maximumDegree")=maximumDegree,
            parse("maximumSteps")=maximumSteps,parse("verbose")=false);
        reconstructed := 0;
        for polynomialDegree from 0 to fitDegree do
            reconstructed := reconstructed + scaledCoefficients[polynomialDegree + 1] *
                validationNode^polynomialDegree;
        end do;
        reconstructed := reconstructed / validationEpsilon^inferredPole;
        estimatedError := evalf(abs(reconstructed - validationValue));
        result := MakeLaurentRecord(-inferredPole, coefficients,
            estimatedError, digits);
    finally
        Digits := oldDigits;
    end try;
    return result;
end proc;

LaurentCoefficient := proc(expansion, order::integer)
    local position;
    position := order - expansion:-firstOrder + 1;
    if position < 1 or position > nops(expansion:-coefficients) then
        error "the requested Laurent order is outside the stored range";
    end if;
    return expansion:-coefficients[position];
end proc;

LaurentPolynomial := proc(expansion, epsilonName := epsilon)
    local result, i, order;
    result := 0;
    for i to nops(expansion:-coefficients) do
        order := expansion:-firstOrder + i - 1;
        result := result + expansion:-coefficients[i] * epsilonName^order;
    end do;
    return result;
end proc;

# ---------------------------------------------------------------------------
# Predefined functions from Appendix C of the paper
# ---------------------------------------------------------------------------

UnitWeight := proc(n::posint, index::posint)
    return UnitIndex(n, index);
end proc;

WeightRows := proc(rows::list)
    return rows;
end proc;

PredefinedSeries := proc(functionName, parameters::list, variables::nonnegint)
    local name, n, rows, upperRows, lowerRows, upperCount,
          lowerCount, i, b, c, a;
    name := StringTools:-LowerCase(convert(functionName, string));
    if member(name, ["hypergeometricpfq", "pfq"]) then
        if nops(parameters) <> 2 then error "HypergeometricPFQ expects upper and lower parameter lists"; end if;
        if nops(parameters[1])=0 and nops(parameters[2])=0 then
            return MakeHornRecord("HypergeometricPFQ",1,[],[],[],[]);
        end if;
        return HornSeries(parameters[1], [seq([1], i = 1 .. nops(parameters[1]))],
            parameters[2], [seq([1], i = 1 .. nops(parameters[2]))], "HypergeometricPFQ");
    elif member(name, ["hypergeometric2f1", "gauss", "2f1"]) then
        if nops(parameters) <> 3 then error "Hypergeometric2F1 expects three parameters"; end if;
        return HornSeries(parameters[1 .. 2], [[1], [1]], [parameters[3]], [[1]], "Hypergeometric2F1");
    elif member(name, ["appellf1", "f1"]) then
        return HornSeries(parameters[1 .. 3], [[1,1],[1,0],[0,1]], [parameters[4]], [[1,1]], "AppellF1");
    elif member(name, ["appellf2", "f2"]) then
        return HornSeries(parameters[1 .. 3], [[1,1],[1,0],[0,1]], parameters[4 .. 5], [[1,0],[0,1]], "AppellF2");
    elif member(name, ["appellf3", "f3"]) then
        return HornSeries(parameters[1 .. 4], [[1,0],[0,1],[1,0],[0,1]], [parameters[5]], [[1,1]], "AppellF3");
    elif member(name, ["appellf4", "f4"]) then
        return HornSeries(parameters[1 .. 2], [[1,1],[1,1]], parameters[3 .. 4], [[1,0],[0,1]], "AppellF4");
    elif name = "horng1" then
        upperRows := [[1,1],[-1,1],[1,-1]]; lowerRows := [];
    elif name = "horng2" then
        upperRows := [[1,0],[0,1],[-1,1],[1,-1]]; lowerRows := [];
    elif name = "horng3" then
        upperRows := [[-1,2],[2,-1]]; lowerRows := [];
    elif name = "hornh1" then
        upperRows := [[1,-1],[1,1],[0,1]]; lowerRows := [[1,0]];
    elif name = "hornh2" then
        upperRows := [[1,-1],[1,0],[0,1],[0,1]]; lowerRows := [[1,0]];
    elif name = "hornh3" then
        upperRows := [[2,1],[0,1]]; lowerRows := [[1,1]];
    elif name = "hornh4" then
        upperRows := [[2,1],[0,1]]; lowerRows := [[1,0],[0,1]];
    elif name = "hornh5" then
        upperRows := [[2,1],[-1,1]]; lowerRows := [[0,1]];
    elif name = "hornh6" then
        upperRows := [[2,-1],[-1,1],[0,1]]; lowerRows := [];
    elif name = "hornh7" then
        upperRows := [[2,-1],[0,1],[0,1]]; lowerRows := [[1,0]];
    elif member(name, ["lauricellafa", "fa"]) then
        n := variables; a := parameters[1];
        b := parameters[2 .. n + 1]; c := parameters[n + 2 .. 2*n + 1];
        upperRows := [[seq(1, i = 1 .. n)], seq(UnitWeight(n, i), i = 1 .. n)];
        lowerRows := [seq(UnitWeight(n, i), i = 1 .. n)];
        return HornSeries([a, op(b)], upperRows, c, lowerRows, "LauricellaFA");
    elif member(name, ["lauricellafb", "fb"]) then
        n := variables;
        upperRows := [seq(UnitWeight(n, i), i = 1 .. n), seq(UnitWeight(n, i), i = 1 .. n)];
        return HornSeries(parameters[1 .. 2*n], upperRows, [parameters[2*n + 1]],
            [[seq(1, i = 1 .. n)]], "LauricellaFB");
    elif member(name, ["lauricellafc", "fc"]) then
        n := variables;
        return HornSeries(parameters[1 .. 2], [[seq(1, i = 1 .. n)], [seq(1, i = 1 .. n)]],
            parameters[3 .. n + 2], [seq(UnitWeight(n, i), i = 1 .. n)], "LauricellaFC");
    elif member(name, ["lauricellafd", "fd"]) then
        n := variables;
        upperRows := [[seq(1, i = 1 .. n)], seq(UnitWeight(n, i), i = 1 .. n)];
        return HornSeries(parameters[1 .. n + 1], upperRows, [parameters[n + 2]],
            [[seq(1, i = 1 .. n)]], "LauricellaFD");
    else
        error "unsupported predefined function: %1", functionName;
    end if;
    upperCount := nops(upperRows); lowerCount := nops(lowerRows);
    if nops(parameters) <> upperCount + lowerCount then
        error "%1 expects %2 parameters", functionName, upperCount + lowerCount;
    end if;
    return HornSeries(parameters[1 .. upperCount], upperRows,
        `if`(lowerCount = 0, [], parameters[upperCount + 1 .. -1]),
        lowerRows, functionName);
end proc;

FunctionSeries := proc(functionName, parameters::list, variables := 0)
    return PredefinedSeries(functionName, parameters, variables);
end proc;

ConvertEpsilonExpression := proc(value, epsilonName)
    local expanded, constant, slope;
    if IsAffineParameter(value) then return value; end if;
    if not has(value, epsilonName) then return AffineParameter(value, 0); end if;
    expanded := expand(value);
    if not type(expanded, polynom(anything, {epsilonName})) or degree(expanded, epsilonName) > 1 then
        error "Pochhammer parameters must depend affinely on epsilon";
    end if;
    constant := subs(epsilonName = 0, expanded);
    slope := coeff(expanded, epsilonName, 1);
    return AffineParameter(constant, slope);
end proc;

FinishPredefined := proc(
    series, target, digits, epsilon, epsilonOrder, poleOrder,
    branchSide, waypoints, maximumSeed, frobeniusOrder,
    maximumDegree, maximumSteps, verbose, method := "auto",
    returnDiagnostics := false, returnDerivatives := false
)
    if epsilonOrder = "none" then
        return Evaluate(series,target,parse("digits")=digits,
            parse("epsilon")=epsilon,parse("branchSide")=branchSide,
            parse("waypoints")=waypoints,parse("maximumSeed")=maximumSeed,
            parse("frobeniusOrder")=frobeniusOrder,
            parse("maximumDegree")=maximumDegree,
            parse("maximumSteps")=maximumSteps,parse("verbose")=verbose,
            parse("method")=method,
            parse("returnDiagnostics")=returnDiagnostics,
            parse("returnDerivatives")=returnDerivatives);
    end if;
    if method<>"auto" or returnDiagnostics or returnDerivatives then
        error "method selection and evaluation diagnostics are not available during epsilon expansion";
    end if;
    return HypExpand(series,target,epsilonOrder,digits,
        parse("poleOrder")=poleOrder,parse("branchSide")=branchSide,
        parse("waypoints")=waypoints,parse("maximumSeed")=maximumSeed,
        parse("frobeniusOrder")=frobeniusOrder,
        parse("maximumDegree")=maximumDegree,
        parse("maximumSteps")=maximumSteps,parse("verbose")=verbose);
end proc;

HypergeometricPFQ := proc(
    upper::list, lower::list, argument,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    return FinishPredefined(PredefinedSeries("HypergeometricPFQ", [upper, lower], 1),
        [argument], digits, epsilon, epsilonOrder, poleOrder, branchSide, waypoints,
        maximumSeed, frobeniusOrder, maximumDegree, maximumSteps, verbose,
        method,returnDiagnostics,returnDerivatives);
end proc;

Hypergeometric2F1 := proc(
    a, b, c, argument,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    return FinishPredefined(PredefinedSeries("Hypergeometric2F1", [a,b,c], 1),
        [argument], digits, epsilon, epsilonOrder, poleOrder, branchSide, waypoints,
        maximumSeed, frobeniusOrder, maximumDegree, maximumSteps, verbose,
        method,returnDiagnostics,returnDerivatives);
end proc;

AppellF1 := proc(
    a, b1, b2, c, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    if method="native" then error "the native method is not available for Appell F1"; end if;
    return LauricellaFD(a,[b1,b2],c,[x,y],
        parse("digits")=digits,parse("epsilon")=epsilon,
        parse("epsilonOrder")=epsilonOrder,parse("poleOrder")=poleOrder,
        parse("branchSide")=branchSide,parse("waypoints")=waypoints,
        parse("maximumSeed")=maximumSeed,
        parse("frobeniusOrder")=frobeniusOrder,
        parse("maximumDegree")=maximumDegree,
        parse("maximumSteps")=maximumSteps,parse("verbose")=verbose,
        parse("method")=method,
        parse("returnDiagnostics")=returnDiagnostics,
        parse("returnDerivatives")=returnDerivatives);
end proc;

AppellF2 := proc(
    a, b1, b2, c1, c2, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    return LauricellaFA(a,[b1,b2],[c1,c2],[x,y],
        parse("digits")=digits,parse("epsilon")=epsilon,
        parse("epsilonOrder")=epsilonOrder,parse("poleOrder")=poleOrder,
        parse("branchSide")=branchSide,parse("waypoints")=waypoints,
        parse("maximumSeed")=maximumSeed,
        parse("frobeniusOrder")=frobeniusOrder,
        parse("maximumDegree")=maximumDegree,
        parse("maximumSteps")=maximumSteps,parse("verbose")=verbose,
        parse("method")=method,
        parse("returnDiagnostics")=returnDiagnostics,
        parse("returnDerivatives")=returnDerivatives);
end proc;

AppellF3 := proc(
    a1, a2, b1, b2, c, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    return LauricellaFB([a1,a2],[b1,b2],c,[x,y],
        parse("digits")=digits,parse("epsilon")=epsilon,
        parse("epsilonOrder")=epsilonOrder,parse("poleOrder")=poleOrder,
        parse("branchSide")=branchSide,parse("waypoints")=waypoints,
        parse("maximumSeed")=maximumSeed,
        parse("frobeniusOrder")=frobeniusOrder,
        parse("maximumDegree")=maximumDegree,
        parse("maximumSteps")=maximumSteps,parse("verbose")=verbose,
        parse("method")=method,
        parse("returnDiagnostics")=returnDiagnostics,
        parse("returnDerivatives")=returnDerivatives);
end proc;

AppellF4 := proc(
    a, b, c1, c2, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    return LauricellaFC(a,b,[c1,c2],[x,y],
        parse("digits")=digits,parse("epsilon")=epsilon,
        parse("epsilonOrder")=epsilonOrder,parse("poleOrder")=poleOrder,
        parse("branchSide")=branchSide,parse("waypoints")=waypoints,
        parse("maximumSeed")=maximumSeed,
        parse("frobeniusOrder")=frobeniusOrder,
        parse("maximumDegree")=maximumDegree,
        parse("maximumSteps")=maximumSteps,parse("verbose")=verbose,
        parse("method")=method,
        parse("returnDiagnostics")=returnDiagnostics,
        parse("returnDerivatives")=returnDerivatives);
end proc;

HornG1 := proc(
    a, b, c, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    local selectedMethod, radius, estimatedDegree, seriesDegree, neighborTerms;
    selectedMethod := method;
    # Avoid paying the complete automatic-series admission cost before the
    # low-rank generic connection in the regime where the calibrated selector
    # will choose that connection anyway.  Keep exact finite support and
    # epsilon reconstruction on the full automatic path.
    if method="auto" and epsilonOrder="none" and
       type(a,numeric) and type(b,numeric) and type(c,numeric) and
       type(x,numeric) and type(y,numeric) and
       not (type(a,integer) and a<=0) then
        radius := evalf(4*(abs(x)+abs(y)));
        if radius<1 then
            estimatedDegree := HypergeometricSeriesDegree(radius,digits);
            seriesDegree := `if`(estimatedDegree=infinity,maximumDegree,
                min(maximumDegree,max(24,estimatedDegree+12)));
            neighborTerms := binomial(seriesDegree+2,2)+
                binomial(floor(seriesDegree/2)+2,2);
            if neighborTerms>1600 then selectedMethod := "generic"; end if;
        end if;
    end if;
    return FinishPredefined(PredefinedSeries("HornG1", [a,b,c], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose,
        selectedMethod,returnDiagnostics,returnDerivatives);
end proc;

HornG2 := proc(
    a, b, c, d, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    return FinishPredefined(PredefinedSeries("HornG2", [a,b,c,d], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose,
        method,returnDiagnostics,returnDerivatives);
end proc;

HornG3 := proc(
    a, b, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    return FinishPredefined(PredefinedSeries("HornG3", [a,b], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose,
        method,returnDiagnostics,returnDerivatives);
end proc;

HornH1 := proc(
    a, b, c, d, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    return FinishPredefined(PredefinedSeries("HornH1", [a,b,c,d], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose,
        method,returnDiagnostics,returnDerivatives);
end proc;

HornH2 := proc(
    a, b, c, d, e, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    return FinishPredefined(PredefinedSeries("HornH2", [a,b,c,d,e], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose,
        method,returnDiagnostics,returnDerivatives);
end proc;

HornH3 := proc(
    a, b, c, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    return FinishPredefined(PredefinedSeries("HornH3", [a,b,c], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose,
        method,returnDiagnostics,returnDerivatives);
end proc;

HornH4 := proc(
    a, b, c, d, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    return FinishPredefined(PredefinedSeries("HornH4", [a,b,c,d], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose,
        method,returnDiagnostics,returnDerivatives);
end proc;

HornH5 := proc(
    a, b, c, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    return FinishPredefined(PredefinedSeries("HornH5", [a,b,c], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose,
        method,returnDiagnostics,returnDerivatives);
end proc;

HornH6 := proc(
    a, b, c, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    return FinishPredefined(PredefinedSeries("HornH6", [a,b,c], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose,
        method,returnDiagnostics,returnDerivatives);
end proc;

HornH7 := proc(
    a, b, c, d, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    return FinishPredefined(PredefinedSeries("HornH7", [a,b,c,d], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose,
        method,returnDiagnostics,returnDerivatives);
end proc;

LauricellaFA := proc(
    a, b::list, c::list, x::list,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    local parameters;
    if nops(b) <> nops(c) or nops(b) <> nops(x) then
        error "b, c, and x must have the same length";
    end if;
    parameters := [a, op(b), op(c)];
    return FinishPredefined(PredefinedSeries("LauricellaFA", parameters, nops(x)), x,
        digits, epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose,
        method,returnDiagnostics,returnDerivatives);
end proc;

LauricellaFB := proc(
    a::list, b::list, c, x::list,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    local parameters;
    if nops(a) <> nops(b) or nops(a) <> nops(x) then
        error "a, b, and x must have the same length";
    end if;
    parameters := [op(a), op(b), c];
    return FinishPredefined(PredefinedSeries("LauricellaFB", parameters, nops(x)), x,
        digits, epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose,
        method,returnDiagnostics,returnDerivatives);
end proc;

LauricellaFC := proc(
    a, b, c::list, x::list,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", returnDiagnostics := false, returnDerivatives := false}
)
    if nops(c) <> nops(x) then error "c and x must have the same length"; end if;
    return FinishPredefined(PredefinedSeries("LauricellaFC", [a,b,op(c)], nops(x)), x,
        digits, epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose,
        method,returnDiagnostics,returnDerivatives);
end proc;

# Compress zero and exactly repeated variables before selecting an evaluation
# method.  The identity follows immediately from the Euler integrand (or from
# the defining series): equal arguments combine their b parameters.
LauricellaFDCompressVariables := proc(b::list, x::list)
    local compressedB, compressedX, filteredB, filteredX,
          value, position, found, i;
    if nops(b) <> nops(x) then error "b and x must have the same length"; end if;
    compressedB := []; compressedX := [];
    for i to nops(x) do
        if evalb(x[i] = 0) then next; end if;
        found := 0;
        for position to nops(compressedX) do
            if evalb(x[i] = compressedX[position]) then
                found := position;
                break;
            end if;
        end do;
        if found = 0 then
            compressedX := [op(compressedX),x[i]];
            compressedB := [op(compressedB),b[i]];
        else
            value := compressedB[found] + b[i];
            compressedB := subsop(found=value,compressedB);
        end if;
    end do;
    filteredB := []; filteredX := [];
    for position to nops(compressedB) do
        if evalb(compressedB[position]=0) then next; end if;
        filteredB := [op(filteredB),compressedB[position]];
        filteredX := [op(filteredX),compressedX[position]];
    end do;
    return [filteredB,filteredX];
end proc;

LauricellaFDEstimatedDegree := proc(x::list, digits::posint)
    local rho, value;
    if nops(x) = 0 then return 0; end if;
    rho := max(seq(evalf(abs(value)),value in x));
    if rho = 0 then return 8; end if;
    if rho >= 1 then return infinity; end if;
    return max(12,ceil((digits+12)*evalf(ln(10))/(-evalf(ln(rho)))+12));
end proc;

LauricellaFDSeriesOperationCount := proc(numberOfVariables::nonnegint,
                                         maximumDegree::nonnegint)
    return 2*(numberOfVariables*maximumDegree+
        maximumDegree*(maximumDegree+1)/2);
end proc;

# A conservative final-rounding allowance for a value returned with the
# requested number of decimal significant digits.  Internal truncation and
# transport diagnostics are computed at guard precision; this term prevents
# the public error estimate from ignoring the final presentation rounding.
LauricellaFDRoundingAllowance := proc(value,digits::posint)
    return evalf[digits+4](10^(1-digits)*max(abs(value),1));
end proc;

# Extra working digits required by large parameters, near-integral
# parameters, and small distances to x_i=1 or x_i=x_j.  Equality tests are
# performed on the raw input before any evalf call; the returned guard is used
# only for subsequent arithmetic.
LauricellaFDWorkingGuardDigits := proc(b::list,x::list,a := 0,c := 1)
    local oldDigits, parameterMagnitude, scale, ratio, candidate,
          nearestInteger, parameterValue, magnitudeGuard, separationGuard,
          guardDigits, i, j;
    oldDigits := Digits; Digits := max(oldDigits,30);
    magnitudeGuard := 0; separationGuard := 0;
    try
        parameterMagnitude := abs(evalf(a))+abs(evalf(c))+
            add(abs(evalf(b[i])),i=1..nops(b));
        if IsFiniteNumber(parameterMagnitude) and parameterMagnitude > 1 then
            magnitudeGuard := max(magnitudeGuard,
                ceil(evalf(ln(parameterMagnitude)/ln(10))));
        end if;
        scale := max(1,seq(abs(evalf(x[i])),i=1..nops(x)));
        for i to nops(x) do
            candidate := 1-x[i];
            if not evalb(candidate=0) then
                ratio := evalf(scale/abs(candidate));
                if IsFiniteNumber(ratio) and ratio > 1 then
                    separationGuard := max(separationGuard,
                        ceil(evalf(ln(ratio)/ln(10))));
                end if;
            end if;
            for j from i+1 to nops(x) do
                candidate := x[i]-x[j];
                if not evalb(candidate=0) then
                    ratio := evalf(scale/abs(candidate));
                    if IsFiniteNumber(ratio) and ratio > 1 then
                        separationGuard := max(separationGuard,
                            ceil(evalf(ln(ratio)/ln(10))));
                    end if;
                end if;
            end do;
        end do;
        for parameterValue in [a,c] do
            # Measure the full complex distance to a nonpositive integer.
            # A real-only test loses the phase of a diagonal perturbation
            # after the caller lowers Digits.
            nearestInteger := round(Re(parameterValue));
            candidate := parameterValue-nearestInteger;
            if nearestInteger<=0 and not evalb(candidate=0) then
                ratio := evalf(max(1,abs(parameterValue))/abs(candidate));
                if IsFiniteNumber(ratio) and ratio>1 then
                    separationGuard := max(separationGuard,
                        ceil(evalf(ln(ratio)/ln(10))));
                end if;
            end if;
        end do;
    catch:
        # Nonnumeric data are rejected by the evaluator itself.  A failed
        # conditioning estimate must not manufacture a precision claim.
        magnitudeGuard := max(magnitudeGuard,0);
        separationGuard := max(separationGuard,0);
    finally
        Digits := oldDigits;
    end try;
    guardDigits := magnitudeGuard+separationGuard;
    if guardDigits > 4096 then
        error "the Lauricella FD conditioning guard exceeds 4096 digits";
    end if;
    return max(0,guardDigits);
end proc;

LauricellaFDSeriesTerminates := proc(a)
    local value;
    if type(a,integer) then return evalb(a<=0); end if;
    try
        value := a;
        if not IsFiniteNumber(value) then return false; end if;
        return evalb(Im(value)=0 and Re(value)<=0 and
            Re(value)=round(Re(value)));
    catch:
        return false;
    end try;
end proc;

LauricellaFDTerminationDegree := proc(a)
    local value;
    if type(a,integer) and a<=0 then return -a; end if;
    try
        value := a;
        if IsFiniteNumber(value) and Im(value)=0 and Re(value)<=0 and
           Re(value)=round(Re(value)) then
            return round(-Re(value));
        end if;
    catch:
        return infinity;
    end try;
    return infinity;
end proc;

LauricellaFDLowerParameterRegular := proc(c)
    local value;
    if type(c,integer) then return evalb(c>0); end if;
    try
        value := c;
        if not IsFiniteNumber(value) then return false; end if;
        if Im(value)=0 and Re(value)<=0 and
           Re(value)=round(Re(value)) then return false; end if;
    catch:
        return false;
    end try;
    return true;
end proc;

LauricellaFDClosedFormApplicable := proc(x::list)
    local value, numericValue;
    for value in x do
        try
            numericValue := evalf(value);
            if not IsFiniteNumber(numericValue) then return false; end if;
            if Im(numericValue)=0 and Re(numericValue)>=1 then return false; end if;
        catch:
            return false;
        end try;
    end do;
    return true;
end proc;

LauricellaFDClosedFormValue := proc(b::list,x::list)
    local i;
    return evalf(exp(-add(b[i]*ln(1-x[i]),i=1..nops(x))));
end proc;

# Let S(t)=product_i (1-x_i*t)^(-b_i)=sum_k s_k*t^k.  Its logarithmic
# derivative gives k*s_k=sum_{j=1}^k p_j*s_(k-j), where
# p_j=sum_i b_i*x_i^j.  This replaces binomial(D+n,n) multi-indices by an
# O(D^2+nD) recurrence.  The same coefficients yield every first derivative
# because dS/dx_i=b_i*t*S/(1-x_i*t).
LauricellaFDFastSeriesVector := proc(
    a, b::list, c, x::list, digits::posint, maximumDegree::nonnegint
)
    local n, coefficients, powerSums, quotientCoefficients, values,
          majorantCoefficients, majorantPowerSums,
          majorantQuotientCoefficients, pochhammerRatio,
          majorantPochhammerRatio, degree, inner, majorantInner,
          coefficientValue, majorantCoefficient, termValue,
          derivativeTerm, majorantTerm, shellNorm, majorantShell,
          valueNorm, tolerance, qBound, bMagnitude, rhoUpper,
          tailEstimate, aMagnitude, cMagnitude, i, j;
    n := nops(x);
    if nops(b) <> n then error "b and x must have the same length"; end if;
    coefficients := Array(0..maximumDegree,fill=0);
    powerSums := Array(0..maximumDegree,fill=0);
    majorantCoefficients := Array(0..maximumDegree,fill=0);
    majorantPowerSums := Array(0..maximumDegree,fill=0);
    coefficients[0] := 1;
    majorantCoefficients[0] := 1;
    quotientCoefficients := Vector(n,datatype=anything,fill=1);
    majorantQuotientCoefficients := Vector(n,datatype=anything,fill=1);
    values := Vector(n+1,datatype=anything);
    values[1] := 1;
    pochhammerRatio := 1; majorantPochhammerRatio := 1;
    tolerance := evalf(10^(-(digits+6)));
    qBound := `if`(n=0,0,max(seq(abs(x[i]),i=1..n)));
    bMagnitude := add(abs(b[i]),i=1..n);
    aMagnitude := evalf(abs(a));
    cMagnitude := evalf(abs(c));
    tailEstimate := infinity;
    for degree to maximumDegree do
        if evalb(c+degree-1 = 0) then
            error "the defining Lauricella FD series has a singular lower parameter";
        end if;
        powerSums[degree] := add(b[i]*x[i]^degree,i=1..n);
        majorantPowerSums[degree] :=
            add(abs(b[i])*abs(x[i])^degree,i=1..n);
        inner := 0; majorantInner := 0;
        for j to degree do
            inner := inner + powerSums[j]*coefficients[degree-j];
            majorantInner := majorantInner+
                majorantPowerSums[j]*majorantCoefficients[degree-j];
        end do;
        coefficientValue := evalf(inner/degree);
        majorantCoefficient := evalf(majorantInner/degree);
        coefficients[degree] := coefficientValue;
        majorantCoefficients[degree] := majorantCoefficient;
        pochhammerRatio := evalf(pochhammerRatio*(a+degree-1)/(c+degree-1));
        majorantPochhammerRatio := evalf(majorantPochhammerRatio*
            abs(a+degree-1)/abs(c+degree-1));
        termValue := evalf(pochhammerRatio*coefficientValue);
        values[1] := evalf(values[1]+termValue);
        shellNorm := abs(termValue);
        majorantShell := evalf(majorantPochhammerRatio*
            majorantCoefficient);
        for i to n do
            derivativeTerm := evalf(pochhammerRatio*b[i]*quotientCoefficients[i]);
            values[i+1] := evalf(values[i+1]+derivativeTerm);
            shellNorm := max(shellNorm,abs(derivativeTerm));
            majorantTerm := evalf(majorantPochhammerRatio*abs(b[i])*
                majorantQuotientCoefficients[i]);
            majorantShell := max(majorantShell,majorantTerm);
            quotientCoefficients[i] := evalf(coefficientValue+x[i]*quotientCoefficients[i]);
            majorantQuotientCoefficients[i] := evalf(majorantCoefficient+
                abs(x[i])*majorantQuotientCoefficients[i]);
        end do;
        if not IsFiniteNumber(shellNorm) or not IsFiniteNumber(majorantShell) or
           not andmap(IsFiniteNumber,[seq(values[i],i=1..n+1)]) then
            return [values,false,degree,infinity];
        end if;
        valueNorm := max(VectorMaxAbs(values),1);
        if majorantPochhammerRatio=0 then
            return [values,true,degree-1,0];
        end if;
        # For all later shell indices j >= degree, the scalar and every
        # first-derivative majorant ratio is bounded by the expression below.
        # Its two rational factors decrease once degree>|c|.  This supplies an
        # absolute geometric tail bound and cannot be fooled by cancellation.
        if degree > cMagnitude and degree >= 8 then
            rhoUpper := evalf(qBound*(degree+aMagnitude)/(degree-cMagnitude)*
                (degree+bMagnitude)/degree);
        else
            rhoUpper := infinity;
        end if;
        if rhoUpper < 1 then
            tailEstimate := evalf(majorantShell*rhoUpper/(1-rhoUpper));
            if tailEstimate <= tolerance*valueNorm then
                return [values,true,degree,tailEstimate];
            end if;
        end if;
    end do;
    return [values,false,maximumDegree,tailEstimate];
end proc;

# Repeat the grouped recurrence at successively higher working precision.  The
# absolute majorant controls truncation; this independent comparison controls
# rounding loss from large cancelling parameters.
LauricellaFDFastSeriesChecked := proc(
    a,b::list,c,x::list,digits::posint,maximumDegree::posint,
    extraGuard::nonnegint
)
    local oldDigits, guardDigits, attempt, workingDigits, current, lower,
          previous, discrepancy, degreeDiscrepancy, tolerance,
          lowerDegree, qBound, valuesFinite, majorantPassed, i,
          terminationDegree, effectiveMaximumDegree,
          degreeScaledDiscrepancy, precisionScaledDiscrepancy;
    oldDigits := Digits;
    guardDigits := max(extraGuard,LauricellaFDWorkingGuardDigits(b,x,a,c));
    terminationDegree := LauricellaFDTerminationDegree(a);
    effectiveMaximumDegree := `if`(terminationDegree=infinity,
        maximumDegree,min(maximumDegree,terminationDegree));
    if LauricellaFDSeriesOperationCount(nops(x),effectiveMaximumDegree)>20000000 then
        error "the specialized Lauricella FD series exceeds its hard operation limit";
    end if;
    previous := NULL; discrepancy := infinity;
    tolerance := evalf(10^(-(digits+3)));
    try
        for attempt from 0 to 2 do
            workingDigits := digits+14+guardDigits+10*attempt;
            Digits := workingDigits;
            current := LauricellaFDFastSeriesVector(a,b,c,map(evalf,x),
                digits,effectiveMaximumDegree);
            if terminationDegree<>infinity and
               maximumDegree>=terminationDegree then
                current := [current[1],true,terminationDegree,0];
            end if;
            valuesFinite := andmap(IsFiniteNumber,
                [seq(current[1][i],i=1..nops(x)+1)]);
            if not valuesFinite then
                return [current[1],false,current[3],infinity,
                    infinity,workingDigits,"failed"];
            end if;
            majorantPassed := current[2];
            degreeDiscrepancy := current[4];
            degreeScaledDiscrepancy := infinity;
            if not majorantPassed and effectiveMaximumDegree >= 4 then
                # Signed parameters can make the absolute-parameter majorant
                # unusable even though the grouped series converges rapidly.
                # Compare fixed sums at D/2 and D only after the possible
                # amplification near a negative lower parameter has passed.
                lowerDegree := floor(effectiveMaximumDegree/2);
                qBound := max(seq(abs(evalf(x[i])),i=1..nops(x)));
                if qBound < 1 and effectiveMaximumDegree > abs(evalf(c))+digits+16 then
                    lower := LauricellaFDFastSeriesVector(a,b,c,map(evalf,x),
                        digits,lowerDegree);
                    if andmap(IsFiniteNumber,
                       [seq(lower[1][i],i=1..nops(x)+1)]) then
                        degreeDiscrepancy := evalf(
                            abs(current[1][1]-lower[1][1])/(1-qBound));
                        degreeScaledDiscrepancy := evalf(max(seq(
                            abs(current[1][i]-lower[1][i])/
                            max(abs(current[1][i]),1),i=1..nops(x)+1)) /
                            (1-qBound));
                    end if;
                end if;
            end if;
            if previous <> NULL then
                discrepancy := abs(current[1][1]-previous[1][1]);
                precisionScaledDiscrepancy := evalf(max(seq(
                    abs(current[1][i]-previous[1][i])/
                    max(abs(current[1][i]),1),i=1..nops(x)+1)));
                if precisionScaledDiscrepancy <= tolerance and
                   (majorantPassed or degreeScaledDiscrepancy <= tolerance) then
                    return [current[1],true,current[3],
                        max(`if`(majorantPassed,current[4],degreeDiscrepancy),
                            discrepancy),discrepancy,
                        workingDigits,
                        `if`(majorantPassed,"majorant","doubled_degree")];
                end if;
            end if;
            previous := current;
        end do;
    finally
        Digits := oldDigits;
    end try;
    return [current[1],false,current[3],current[4],
        discrepancy,workingDigits,"failed"];
end proc;

LauricellaFDEulerApplicable := proc(a,b::list,c,x::list)
    local av, cv, value;
    try
        av := evalf(a); cv := evalf(c);
        if not IsFiniteNumber(av) or not IsFiniteNumber(cv) then return false; end if;
        if Im(av) <> 0 or Im(cv) <> 0 or Re(av) <= 0 or Re(cv-av) <= 0 then
            return false;
        end if;
        for value in [op(b),op(x)] do
            if not IsFiniteNumber(evalf(value)) then return false; end if;
        end do;
        for value in x do
            if Im(evalf(value)) <> 0 or Re(evalf(value)) >= 1 then return false; end if;
        end do;
    catch:
        return false;
    end try;
    return true;
end proc;

LauricellaFDEulerCostSafe := proc(b::list,digits::posint)
    local magnitude, value;
    try
        magnitude := 0;
        for value in b do magnitude := magnitude+abs(evalf(value)); end do;
        return evalb(IsFiniteNumber(magnitude) and
            magnitude <= max(32,2*digits));
    catch:
        return false;
    end try;
end proc;

# Principal-germ boundary vector [F,dF/dx_1,...,dF/dx_n] for the explicit
# Lauricella FD connection.  This is the practical seed for full Pfaffian
# transport and uses the grouped total-degree recurrence above.
LauricellaFDInitialVector := proc(
    a,b::list,c,x::list,
    {digits := 50, maximumDegree := 260, returnDiagnostics := false}
)
    local result, guardDigits, presentedValues, outputRounding, value,
          series, sourceDigits, oldDigits, answer;
    if nops(b) <> nops(x) then error "b and x must have the same length"; end if;
    if digits < 1 then error "digits must be positive"; end if;
    series := PredefinedSeries("LauricellaFD",[a,op(b),c],nops(x));
    sourceDigits := HypergeometricSourceDigits(series,x,[],0);
    oldDigits := Digits; Digits := max(digits+14,sourceDigits);
    try
        guardDigits := LauricellaFDWorkingGuardDigits(b,x,a,c);
        result := LauricellaFDFastSeriesChecked(a,b,c,x,digits,
            maximumDegree,guardDigits);
        if not result[2] then
            error "the grouped Lauricella FD boundary series did not converge or lost precision through degree %1",maximumDegree;
        end if;
        presentedValues := map(entry->evalf[digits](entry),result[1]);
        outputRounding := max(seq(
            LauricellaFDRoundingAllowance(value,digits),
            value in convert(presentedValues,list)));
        if returnDiagnostics then
            answer := Record('hpType'="LauricellaFDInitialVector",
                'value'=presentedValues,'methodUsed'="series",
                'degree'=result[3],
                'tailBound'=`if`(result[7]="majorant",result[4],-1),
                'doubledDegreeDifference'=
                    `if`(result[7]="doubled_degree",result[4],-1),
                'convergenceTest'=result[7],
                'roundingError'=max(result[5],outputRounding),
                'workingDigits'=result[6]);
        else
            answer := presentedValues;
        end if;
    finally
        Digits := oldDigits;
    end try;
    return answer;
end proc;

LauricellaFDEulerValue := proc(a,b::list,c,x::list,digits::posint)
    local parameter, exponentValue, integrand, prefactor, usedIndices,
          paired, allExponentsPaired, differenceRatio, ratioBound, exponentTail,
          exponentTolerance, truncationDegree, maximumLogDegree,
          pairCoefficient, alternativeRatio,
          i, j, k, oldDigits, result;
    if not LauricellaFDEulerApplicable(a,b,c,x) then
        error "the real Euler integral requires Re(c)>Re(a)>0 and real x_i<1";
    end if;
    parameter := parse("hp_fd_euler_t");
    oldDigits := Digits; Digits := max(oldDigits,digits+10);
    try
        # Opposite exponents at nearby coordinates are combined before
        # quadrature.  Expanding log(1-u) avoids forming two large powers or
        # subtracting nearly equal logarithms at every quadrature node.
        exponentValue := 0; usedIndices := {}; maximumLogDegree := 32;
        allExponentsPaired := true;
        exponentTolerance := evalf(10^(-(digits+8)));
        for i to nops(x) do
            if member(i,usedIndices) then next; end if;
            paired := false;
            for j from i+1 to nops(x) do
                if member(j,usedIndices) or not evalb(b[i]+b[j]=0) then
                    next;
                end if;
                if Im(evalf(x[i]))<>0 or Im(evalf(x[j]))<>0 then
                    next;
                end if;
                differenceRatio := normal(
                    (x[j]-x[i])*parameter/(1-x[i]*parameter));
                ratioBound := evalf(abs(x[j]-x[i])/abs(1-x[i]));
                pairCoefficient := b[i];
                alternativeRatio := evalf(abs(x[i]-x[j])/abs(1-x[j]));
                if alternativeRatio < ratioBound then
                    differenceRatio := normal(
                        (x[i]-x[j])*parameter/(1-x[j]*parameter));
                    ratioBound := alternativeRatio;
                    pairCoefficient := b[j];
                end if;
                if ratioBound >= 1 then next; end if;
                truncationDegree := 1;
                exponentTail := evalf(abs(pairCoefficient)*ratioBound^2/
                    (2*(1-ratioBound)));
                while exponentTail > exponentTolerance and
                      truncationDegree < maximumLogDegree do
                    truncationDegree := truncationDegree+1;
                    exponentTail := evalf(abs(pairCoefficient)*
                        ratioBound^(truncationDegree+1)/
                        ((truncationDegree+1)*(1-ratioBound)));
                end do;
                if exponentTail <= exponentTolerance then
                    exponentValue := exponentValue-pairCoefficient*
                        add(differenceRatio^k/k,k=1..truncationDegree);
                    usedIndices := usedIndices union {i,j};
                    paired := true;
                    break;
                end if;
            end do;
            if not paired then
                exponentValue := exponentValue-b[i]*ln(1-x[i]*parameter);
                usedIndices := usedIndices union {i};
                allExponentsPaired := false;
            end if;
        end do;
        # The raw inputs were already rounded with the dynamic guard, and the
        # small coordinate differences are now explicit coefficients of the
        # stabilized exponent.  Quadrature itself therefore needs only the
        # requested precision plus its integration guard.
        Digits := digits+10;
        integrand := parameter^(a-1)*(1-parameter)^(c-a-1)*
            exp(exponentValue);
        prefactor := GAMMA(c)/(GAMMA(a)*GAMMA(c-a));
        if allExponentsPaired then
            result := evalf(prefactor*Int(integrand,parameter=0..1,
                parse("method")=parse("_Dexp")));
        else
            result := evalf(prefactor*Int(integrand,parameter=0..1));
        end if;
        if not IsFiniteNumber(result) then
            error "the Euler integral did not return a finite numerical value";
        end if;
    finally
        Digits := oldDigits;
    end try;
    return result;
end proc;

# Explicit rank-(n+1) connection in the derivative basis
# [F,dF/dx_1,...,dF/dx_n].  It follows from the standard Lauricella FD PDEs
# and avoids a generic Macaulay reduction.
LauricellaFDPfaffianSystem := proc(
    a, b::list, c,
    {digits := 50, variableNames := []}
)
    local n, variables, rank, matrices, matrixValue, diagonalCoefficient,
          singularFactors, basisLabels, i, j, k;
    n := nops(b);
    if n = 0 then error "Lauricella FD needs at least one variable"; end if;
    if nops(variableNames) = 0 then
        variables := [seq(parse(cat("hp_fd_x",i)),i=1..n)];
    else
        variables := variableNames;
    end if;
    if nops(variables) <> n or not andmap(type,variables,symbol) or
       nops(convert(variables,set)) <> n then
        error "variableNames must contain one distinct symbol per b parameter";
    end if;
    rank := n+1; matrices := [];
    for k to n do
        matrixValue := Matrix(rank,rank,datatype=anything);
        matrixValue[1,k+1] := 1;
        for i to n do
            if i = k then next; end if;
            matrixValue[i+1,i+1] := normal(b[k]/(variables[i]-variables[k]));
            matrixValue[i+1,k+1] := normal(-b[i]/(variables[i]-variables[k]));
        end do;
        matrixValue[k+1,1] := normal(a*b[k]/(variables[k]*(1-variables[k])));
        diagonalCoefficient := -c+(a+b[k]+1)*variables[k];
        for j to n do
            if j = k then next; end if;
            diagonalCoefficient := diagonalCoefficient-
                (1-variables[k])*variables[j]*b[j]/(variables[k]-variables[j]);
            matrixValue[k+1,j+1] := normal(
                b[k]*variables[j]*(1-variables[j])/
                (variables[k]*(1-variables[k])*(variables[k]-variables[j])));
        end do;
        matrixValue[k+1,k+1] := normal(
            diagonalCoefficient/(variables[k]*(1-variables[k])));
        matrices := [op(matrices),matrixValue];
    end do;
    singularFactors := [seq(variables[i],i=1..n),
        seq(1-variables[i],i=1..n),
        seq(seq(variables[i]-variables[j],j=i+1..n),i=1..n-1)];
    basisLabels := ["F",seq(cat("dF_dx",i),i=1..n)];
    return MakeUserPfaffianRecord(matrices,variables,rank,basisLabels,digits,
        singularFactors,MakeExactFlatnessRecord(true,"verified_lauricella_fd_formula",[]),
        "LauricellaFD",[a,b,c]);
end proc;

LauricellaFDPfaffianValue := proc(
    a,b::list,c,x::list,digits::posint,maximumDegree::posint,
    guardDigits::nonnegint,
    branchSide::integer,waypoints::list,frobeniusOrder::nonnegint,
    maximumSteps::posint,verifyReverse::boolean,verbose::boolean
)
    local system, targetPoint, maximumTarget, scale, basepoint, initialData, path,
          transport, continued, oldDigits, workingDigits, seedDegree, result, i;
    if nops(x) = 0 then return 1; end if;
    # parse prevents Maple from evaluating an option name that is also a
    # positional parameter of this procedure (for example digits=10 becoming
    # the meaningless equation 10=18 in a nested call).
    system := LauricellaFDPfaffianSystem(a,b,c,
        parse("digits")=digits+8+guardDigits);
    if verbose then printf("HyperPrecision: explicit Lauricella FD rank-%d connection constructed for parameters %a, %a, %a\n",nops(x)+1,a,b,c); end if;
    workingDigits := digits+14+guardDigits;
    oldDigits := Digits; Digits := max(oldDigits,workingDigits);
    try
        targetPoint := map(evalf,x);
        maximumTarget := max(seq(abs(targetPoint[i]),i=1..nops(targetPoint)));
        scale := min(1/8,1/(8*max(maximumTarget,1)));
        basepoint := [seq(evalf(scale*x[i]),i=1..nops(targetPoint))];
        seedDegree := min(maximumDegree,1000);
        initialData := LauricellaFDFastSeriesChecked(a,b,c,basepoint,
            digits+4,seedDegree,guardDigits);
        if not initialData[2] then
            error "the fast Lauricella FD boundary series did not converge or lost precision";
        end if;
        if verbose then printf("HyperPrecision: boundary series degree %d, tail estimate %a\n",initialData[3],initialData[4]); end if;
        path := PlanPath(system,basepoint,targetPoint,
            parse("mode")=`if`(nops(waypoints)=0,"canonical","user"),
            parse("waypoints")=waypoints,
            parse("branchSide")=branchSide,parse("digits")=digits);
        if verbose then printf("HyperPrecision: Pfaffian path has %d segment(s)\n",nops(path:-points)-1); end if;
        transport := TransportFundamental(system,path,parse("digits")=digits,
            parse("taylorOrder")=frobeniusOrder,
            parse("maximumSteps")=maximumSteps,
            parse("verificationOrder")=4,
            parse("verifyReverse")=verifyReverse,
            parse("verbose")=verbose);
        continued := ApplyTransport(transport,initialData[1]);
        result := ChopValue(continued[1],digits);
    finally
        Digits := oldDigits;
    end try;
    return [result,transport,initialData[3],initialData[4],continued];
end proc;

LauricellaFD := proc(
    a, b::list, c, x::list,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false,
     method := "auto", verifyReverse := false, returnDiagnostics := false,
     returnDerivatives := false}
)
    local series, exactCompressed, activeB, activeX,
          exactA, exactB, exactC, numericA, numericC, estimate,
          seriesResult, pfaffianResult, result, oldDigits, startTime,
          guardDigits, qBound, seriesOperationAllowed, eulerSucceeded, i,
          terminationDegree, seriesEffectiveDegree, outputRounding,
          totalErrorEstimate,derivatives,shiftedB,derivativeValue,
          sourceDigits;
    startTime := time();
    if nops(b) <> nops(x) then error "b and x must have the same length"; end if;
    if not member(method,["auto","series","euler","pfaffian","generic"]) then
        error "method must be auto, series, euler, pfaffian, or generic";
    end if;
    series := PredefinedSeries("LauricellaFD",[a,op(b),c],nops(x));
    if epsilonOrder <> "none" then
        return FinishPredefined(series,x,digits,epsilon,epsilonOrder,poleOrder,
            branchSide,waypoints,maximumSeed,frobeniusOrder,maximumDegree,
            maximumSteps,verbose,"auto",returnDiagnostics,returnDerivatives);
    elif method = "generic" then
        return FinishPredefined(series,x,digits,epsilon,epsilonOrder,poleOrder,
            branchSide,waypoints,maximumSeed,frobeniusOrder,maximumDegree,
            maximumSteps,verbose,"generic",returnDiagnostics,returnDerivatives);
    end if;
    if digits < 1 then error "digits must be positive"; end if;
    oldDigits := Digits;
    # Inspect arbitrary-precision Float mantissas before any parameter
    # arithmetic.  Otherwise lowering Digits can round a regular parameter
    # such as -100+10^(-100)+I*10^(-100) onto, or towards, a pole.
    sourceDigits := HypergeometricSourceDigits(series,x,waypoints,epsilon);
    Digits := max(digits+14,sourceDigits);
    try
        exactA := series:-upperParameters[1]:-constant+
            series:-upperParameters[1]:-slope*epsilon;
        exactB := [seq(series:-upperParameters[i]:-constant+
            series:-upperParameters[i]:-slope*epsilon,
            i=2..nops(series:-upperParameters))];
        exactC := series:-lowerParameters[1]:-constant+
            series:-lowerParameters[1]:-slope*epsilon;
        if nops(waypoints)=0 and not returnDerivatives then
            # Group the raw inputs exactly once.  Grouping rounded parameters
            # or coordinates can erase a small difference multiplied by a
            # large exponent and can also give b and x different dimensions.
            exactCompressed := LauricellaFDCompressVariables(exactB,x);
        else
            # Endpoint compression is a principal-germ identity.  Equal
            # endpoint coordinates can have different sheets after travelling
            # along user paths, so a path-dependent evaluation retains every
            # original variable.
            exactCompressed := [exactB,x];
        end if;
        guardDigits := LauricellaFDWorkingGuardDigits(
            exactCompressed[1],exactCompressed[2],exactA,exactC);
        Digits := digits+14+guardDigits;
        activeB := map(evalf,exactCompressed[1]);
        activeX := map(evalf,exactCompressed[2]);
        numericA := evalf(exactA); numericC := evalf(exactC);
        # The exact a=c identity cancels the common Pochhammer row before any
        # lower-parameter pole test.  In particular, a=c=-N defines the
        # regular product reduction even though c alone is nonpositive.
        if member(method,["auto","series"]) and
           nops(waypoints)=0 and branchSide=-1 and
           evalb(exactA=exactC) and
           LauricellaFDClosedFormApplicable(exactCompressed[2]) then
            result := ChopValue(LauricellaFDClosedFormValue(
                exactCompressed[1],exactCompressed[2]),digits);
            result := evalf[digits](result);
            derivatives := [];
            if returnDerivatives then
                derivatives := [seq(evalf[digits](ChopValue(
                    result*activeB[i]/(1-activeX[i]),digits)),
                    i=1..nops(activeX))];
            end if;
            if returnDiagnostics then
                outputRounding := LauricellaFDRoundingAllowance(result,digits);
                return MakeLauricellaFDEvaluationRecord(result,
                    "closed_form",0,outputRounding,
                    evalf(time()-startTime),0,nops(activeX),0,
                    "exact_cancellation",0,0,outputRounding,derivatives);
            end if;
            if returnDerivatives then
                return Vector([result,op(derivatives)],datatype=anything);
            end if;
            return result;
        end if;
        if not LauricellaFDLowerParameterRegular(exactC) then
            error "the defining Lauricella FD function has a singular lower parameter";
        end if;
        if nops(activeX) = 0 then
            result := evalf[digits](1);
            if returnDiagnostics then
                return MakeLauricellaFDEvaluationRecord(result,
                    "exact_reduction",0,0,evalf(time()-startTime),0,0,0,
                    "exact",0,0,0,[]);
            end if;
            if returnDerivatives then return Vector([result],datatype=anything); end if;
            return result;
        end if;
        estimate := LauricellaFDEstimatedDegree(activeX,digits);
        if (nops(waypoints)>0 or branchSide<>-1) and
           member(method,["series","euler"]) then
            error "series and Euler methods evaluate the principal origin germ and cannot honour an explicit path or branch-side request; use method=pfaffian";
        end if;
        qBound := max(seq(abs(activeX[i]),i=1..nops(activeX)));
        terminationDegree := LauricellaFDTerminationDegree(exactA);
        seriesEffectiveDegree := `if`(terminationDegree=infinity,
            maximumDegree,min(maximumDegree,terminationDegree));
        seriesOperationAllowed := evalb(
            LauricellaFDSeriesOperationCount(nops(activeX),seriesEffectiveDegree)
                <=20000000);
        if method="series" and not seriesOperationAllowed then
            error "the specialized Lauricella FD series exceeds its hard operation limit";
        end if;
        if method = "series" or
           (method = "auto" and nops(waypoints)=0 and branchSide=-1 and
            seriesOperationAllowed and
            (LauricellaFDSeriesTerminates(exactA) or qBound < 1)) then
            seriesResult := LauricellaFDFastSeriesChecked(exactA,
                exactCompressed[1],exactC,exactCompressed[2],digits,
                maximumDegree,guardDigits);
            if seriesResult[2] then
                result := ChopValue(seriesResult[1][1],digits);
                result := evalf[digits](result);
                derivatives := [];
                if returnDerivatives then
                    derivatives := [seq(evalf[digits](ChopValue(
                        seriesResult[1][i+1],digits)),i=1..nops(activeX))];
                end if;
                if returnDiagnostics then
                    outputRounding := LauricellaFDRoundingAllowance(result,digits);
                    totalErrorEstimate := max(seriesResult[4],outputRounding);
                    return MakeLauricellaFDEvaluationRecord(result,
                        "series",seriesResult[3],totalErrorEstimate,
                        evalf(time()-startTime),estimate,nops(activeX),0,
                        seriesResult[7],
                        `if`(seriesResult[7]="majorant",seriesResult[4],-1),
                        `if`(seriesResult[7]="doubled_degree",seriesResult[4],-1),
                        max(seriesResult[5],outputRounding),derivatives);
                end if;
                if returnDerivatives then
                    return Vector([result,op(derivatives)],datatype=anything);
                end if;
                return result;
            end if;
            if method = "series" then
                error "the fast Lauricella FD series did not converge through degree %1",maximumDegree;
            end if;
        end if;
        if method = "euler" then
            result := LauricellaFDEulerValue(numericA,activeB,numericC,activeX,digits);
            result := ChopValue(result,digits);
            result := evalf[digits](result);
            derivatives := [];
            if returnDerivatives then
                for i to nops(activeX) do
                    shiftedB := subsop(i=activeB[i]+1,activeB);
                    derivativeValue := numericA*activeB[i]/numericC*
                        LauricellaFDEulerValue(numericA+1,shiftedB,
                            numericC+1,activeX,digits);
                    derivatives := [op(derivatives),evalf[digits](
                        ChopValue(derivativeValue,digits))];
                end do;
            end if;
            if returnDiagnostics then
                return MakeLauricellaFDEvaluationRecord(result,
                    "euler",-1,-1,evalf(time()-startTime),estimate,
                    nops(activeX),0,"not_applicable",-1,-1,-1,derivatives);
            end if;
            if returnDerivatives then
                return Vector([result,op(derivatives)],datatype=anything);
            end if;
            return result;
        elif method = "auto" and nops(waypoints)=0 and branchSide=-1 and
             LauricellaFDEulerApplicable(numericA,activeB,numericC,activeX) and
             LauricellaFDEulerCostSafe(activeB,digits) then
            eulerSucceeded := false;
            try
                result := LauricellaFDEulerValue(
                    numericA,activeB,numericC,activeX,digits);
                eulerSucceeded := IsFiniteNumber(result);
            catch:
                eulerSucceeded := false;
                if verbose then
                    printf("HyperPrecision: Euler evaluation failed; falling back to Pfaffian transport\n");
                end if;
            end try;
            if eulerSucceeded then
                result := ChopValue(result,digits);
                result := evalf[digits](result);
                derivatives := [];
                if returnDerivatives then
                    for i to nops(activeX) do
                        shiftedB := subsop(i=activeB[i]+1,activeB);
                        derivativeValue := numericA*activeB[i]/numericC*
                            LauricellaFDEulerValue(numericA+1,shiftedB,
                                numericC+1,activeX,digits);
                        derivatives := [op(derivatives),evalf[digits](
                            ChopValue(derivativeValue,digits))];
                    end do;
                end if;
                if returnDiagnostics then
                    return MakeLauricellaFDEvaluationRecord(result,
                        "euler",-1,-1,evalf(time()-startTime),estimate,
                        nops(activeX),0,"not_applicable",-1,-1,-1,derivatives);
                end if;
                if returnDerivatives then
                    return Vector([result,op(derivatives)],datatype=anything);
                end if;
                return result;
            end if;
        end if;
        pfaffianResult := LauricellaFDPfaffianValue(exactA,
            exactCompressed[1],exactC,exactCompressed[2],
            digits,maximumDegree,guardDigits,branchSide,waypoints,frobeniusOrder,
            maximumSteps,verifyReverse,verbose);
        result := evalf[digits](pfaffianResult[1]);
        derivatives := [];
        if returnDerivatives then
            derivatives := [seq(evalf[digits](ChopValue(
                pfaffianResult[5][i+1],digits)),i=1..nops(activeX))];
        end if;
        if returnDiagnostics then
            outputRounding := LauricellaFDRoundingAllowance(result,digits);
            return MakeLauricellaFDEvaluationRecord(result,"pfaffian",
                pfaffianResult[3],max(pfaffianResult[4],
                pfaffianResult[2]:-diagnostics:-estimatedError,
                pfaffianResult[2]:-diagnostics:-maxDifferentialResidual,
                outputRounding),
                evalf(time()-startTime),estimate,nops(activeX),
                nops(pfaffianResult[2]:-factors),"not_applicable",-1,-1,
                outputRounding,derivatives);
        end if;
        if returnDerivatives then
            return Vector([result,op(derivatives)],datatype=anything);
        end if;
    finally
        Digits := oldDigits;
    end try;
    return result;
end proc;

ParseFunctionCall := proc(functionSpec, epsilonName)
    local head, name, arguments, parameters, target, n, i;
    if not type(functionSpec, function) then
        error "the first argument must be an unevaluated predefined function call";
    end if;
    head := op(0, functionSpec);
    name := convert(head, string);
    if StringTools:-Search(":-", name) > 0 then
        name := StringTools:-Split(name, ":-")[-1];
    end if;
    arguments := [op(functionSpec)];
    if member(name, ["HypergeometricPFQ", "PFQ"]) then
        parameters := [map(v -> ConvertEpsilonExpression(v, epsilonName), arguments[1]),
            map(v -> ConvertEpsilonExpression(v, epsilonName), arguments[2])];
        target := [arguments[3]]; n := 1;
    elif member(name, ["Hypergeometric2F1", "Gauss"]) then
        parameters := map(v -> ConvertEpsilonExpression(v, epsilonName), arguments[1 .. 3]);
        target := [arguments[4]]; n := 1;
    elif member(name, ["AppellF1", "AppellF2", "AppellF3"]) then
        parameters := map(v -> ConvertEpsilonExpression(v, epsilonName), arguments[1 .. 5]);
        if name = "AppellF1" then parameters := parameters[1 .. 4]; end if;
        target := arguments[-2 .. -1]; n := 2;
    elif name = "AppellF4" then
        parameters := map(v -> ConvertEpsilonExpression(v, epsilonName), arguments[1 .. 4]);
        target := arguments[-2 .. -1]; n := 2;
    elif member(name, ["HornG1", "HornG2", "HornG3",
                        "HornH1", "HornH2", "HornH3", "HornH4",
                        "HornH5", "HornH6", "HornH7"]) then
        parameters := map(v -> ConvertEpsilonExpression(v, epsilonName), arguments[1 .. -3]);
        target := arguments[-2 .. -1]; n := 2;
    elif member(name, ["LauricellaFA", "LauricellaFB", "LauricellaFC", "LauricellaFD"]) then
        target := arguments[-1]; n := nops(target);
        if name = "LauricellaFA" then
            parameters := [arguments[1], op(arguments[2]), op(arguments[3])];
        elif name = "LauricellaFB" then
            parameters := [op(arguments[1]), op(arguments[2]), arguments[3]];
        elif name = "LauricellaFC" then
            parameters := [arguments[1], arguments[2], op(arguments[3])];
        else
            parameters := [arguments[1], op(arguments[2]), arguments[3]];
        end if;
        parameters := map(v -> ConvertEpsilonExpression(v, epsilonName), parameters);
    else
        error "unsupported predefined function call: %1", name;
    end if;
    return [PredefinedSeries(name, parameters, n), target];
end proc;

HypFunctionExpand := proc(
    functionSpec,
    epsilonName,
    epsilonOrder::nonnegint,
    digits::posint,
    {poleOrder := "automatic", interpolationGuard := 3, branchSide := -1,
     waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    local parsed;
    parsed := ParseFunctionCall(functionSpec, epsilonName);
    return HypExpand(parsed[1],parsed[2],epsilonOrder,digits,
        parse("poleOrder")=poleOrder,
        parse("interpolationGuard")=interpolationGuard,
        parse("branchSide")=branchSide,parse("waypoints")=waypoints,
        parse("maximumSeed")=maximumSeed,
        parse("frobeniusOrder")=frobeniusOrder,
        parse("maximumDegree")=maximumDegree,
        parse("maximumSteps")=maximumSteps,parse("verbose")=verbose);
end proc;

end module:
