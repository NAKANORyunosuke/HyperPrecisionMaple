# SPDX-FileCopyrightText: 2026 NAKANO Ryuosuke and contributors
# SPDX-License-Identifier: GPL-3.0-only

HyperPrecision := module()
option package;

export
    AffineParameter, EpsilonParameter, HornSeries,
    PDEGenerator, FindHypergeometricOrder, FindHolonomicRank,
    FindPfaffianSystem, FindRestrictedPfaffianSystem,
    ConnectionMatrices, CheckIntegrability, TransportDE,
    Evaluate, HypExpand, HypFunctionExpand,
    LaurentCoefficient, LaurentPolynomial,
    HypergeometricPFQ, Hypergeometric2F1,
    AppellF1, AppellF2, AppellF3, AppellF4,
    HornG1, HornG2, HornG3,
    HornH1, HornH2, HornH3, HornH4, HornH5, HornH6, HornH7,
    LauricellaFA, LauricellaFB, LauricellaFC, LauricellaFD,
    FunctionSeries;

local
    IsAffineParameter, AsAffineParameter, EvaluateParameter, HasEpsilon,
    NumericSeries, RestrictZeroVariables,
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
    Convolve, PolynomialOnLine, EquationMatrixOnLine,
    ReductionSeries, RestrictedMatrixSeries,
    FrobeniusSolutionCoefficients, EvaluateFrobeniusSeries,
    IntegrateSegmentFrobenius, NormaliseWaypoints,
    EstimatePoleOrder, ChopValue, IsFiniteNumber,
    PredefinedSeries, UnitWeight, WeightRows,
    FinishPredefined, ConvertEpsilonExpression, ParseFunctionCall;

local
    MakeAffineRecord, MakeHornRecord, MakeNumericHornRecord,
    MakeRREFRecord, MakePfaffianRecord, MakeCheckRecord,
    MakeRestrictedRecord, MakeLaurentRecord;

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

MakePfaffianRecord := proc(p1, p2, p3, p4, p5, p6, p7, p8, p9)
    return Record('hpType' = "PfaffianSystem", 'series' = p1, 'basis' = p2,
        'equations' = p3, 'columns' = p4, 'pivotColumns' = p5,
        'freeColumns' = p6, 'equationRows' = p7, 'orders' = p8, 'digits' = p9);
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

DerivePfaffian := proc(numericSeries, digits::posint, maximumSeed)
    local base, baseEquations, orders, maximumBasisOrder, initialSeed,
          finalSeed, point, seed, equations, columns, matrix, reduction,
          basis, zero, matrices, pivotSubmatrix, rowReduction,
          selectedRows, i, j;
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
        return MakePfaffianRecord(numericSeries, basis, equations, columns,
            reduction:-pivotColumns, reduction:-freeColumns, selectedRows,
            orders, digits);
    end do;
    error "the finite derivative basis did not close through seed order %1; increase maximumSeed or use non-resonant parameters", finalSeed;
end proc;

FindPfaffianSystem := proc(
    series,
    {epsilon := 0, digits := 50, maximumSeed := 0}
)
    local oldDigits, result;
    if digits < 1 then error "digits must be positive"; end if;
    oldDigits := Digits; Digits := digits + 14;
    try
        result := DerivePfaffian(NumericSeries(series, epsilon), digits + 10, maximumSeed);
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
        'epsilon' = epsilon,
        'digits' = digits,
        'maximumSeed' = maximumSeed
    );
    return [nops(system:-basis), system:-basis];
end proc;

ConnectionMatricesInternal := proc(system, point::list)
    local selectedEquations, selectedColumns, derivatives, matrix,
          pivotCount, freeCount, pivotMatrix, freeMatrix, reduction,
          freePosition, pivotPosition, columnIndex, basisColumns,
          basisPositions, basisSet, threshold, rank, n, matrices,
          variable, basisRow, derivative, target, targetColumn,
          position, basisColumn, reductionRow, freeColumn, i, j;
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
    if nops(point) <> system:-series:-nvariables then
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
        n := system:-series:-nvariables;
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

IsFiniteNumber := proc(value)
    if not type(value, numeric) then return false; end if;
    if has(value, {undefined, infinity, -infinity}) then return false; end if;
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
          shellNorm, valueNorm, allLargeEnough, i;
    values := Vector(nops(basis), datatype = anything);
    tolerance := evalf(10^(-(digits + 8)));
    consecutiveSmall := 0; consecutiveGrowth := 0; previousNorm := infinity;
    for degree from 0 to maximumDegree do
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

RestrictedMatrixSeries := proc(system, center::list, direction::list, order::nonnegint)
    local reductions, freePosition, pivotPosition, columnIndex,
          basisColumns, basisPositions, basisSet, rank, coefficients,
          n, variable, basisRow, derivative, target, targetColumn,
          position, basisColumn, reductionRow, degree, i;
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
          tailLength, tailStart, tail, tolerance, decreasing, i;
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
    decreasing := evalb(tailLength < 2 or termNorms[-1] <= termNorms[tailStart]);
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

NormaliseWaypoints := proc(target::list, branchSide::integer, waypoints::list)
    local realTarget, imaginaryShift, path, point, i;
    if not member(branchSide, [-1, 0, 1]) then error "branchSide must be -1, 0, or 1"; end if;
    if nops(waypoints) > 0 then
        path := [];
        for point in waypoints do
            if nops(point) <> nops(target) then error "a contour waypoint has the wrong length"; end if;
            path := [op(path), map(evalf, point)];
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
    system := FindPfaffianSystem(series, 'epsilon' = epsilon, 'digits' = digits,
        'maximumSeed' = maximumSeed);
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
          oldDigits, result;
    if systemOrRestricted:-hpType = "RestrictedPfaffianSystem" then
        system := systemOrRestricted:-system;
        target := systemOrRestricted:-target;
        path := systemOrRestricted:-waypoints;
        branchSide := 0;
    else
        system := systemOrRestricted;
        target := map(evalf, targetArgument);
        path := [];
    end if;
    effectiveDigits := `if`(digits = 0, system:-digits, digits);
    oldDigits := Digits; Digits := max(system:-digits, effectiveDigits + 12);
    try
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
    local threshold, realPart, imaginaryPart;
    threshold := evalf(10^(-digits));
    realPart := `if`(abs(Re(value)) <= threshold, 0, Re(value));
    imaginaryPart := `if`(abs(Im(value)) <= threshold, 0, Im(value));
    if imaginaryPart = 0 then return evalf(realPart); end if;
    return evalf(realPart + I * imaginaryPart);
end proc;

Evaluate := proc(
    series,
    target::list,
    {digits := 50, epsilon := 0, branchSide := -1, waypoints := [],
     maximumSeed := 0, frobeniusOrder := 0, maximumDegree := 260,
     maximumSteps := 20000, verbose := false}
)
    local oldDigits, workingDigits, active, restrictedSeries,
          restrictedTarget, restrictedWaypoints, numeric, direct,
          system, vector, result, i, point;
    if digits < 1 then error "digits must be positive"; end if;
    if nops(target) <> series:-nvariables then error "the target has the wrong length"; end if;
    active := [];
    for i to nops(target) do if target[i] <> 0 then active := [op(active), i]; end if; end do;
    if nops(active) = 0 then return evalf[digits](1); end if;
    restrictedSeries := RestrictZeroVariables(series, active);
    restrictedTarget := [seq(target[active[i]], i = 1 .. nops(active))];
    restrictedWaypoints := [];
    for point in waypoints do
        if nops(point) <> nops(target) then error "a contour waypoint has the wrong length"; end if;
        restrictedWaypoints := [op(restrictedWaypoints),
            [seq(point[active[i]], i = 1 .. nops(active))]];
    end do;
    workingDigits := digits + 14;
    oldDigits := Digits; Digits := workingDigits;
    try
        numeric := NumericSeries(restrictedSeries, epsilon);
        restrictedTarget := map(evalf, restrictedTarget);
        direct := DirectSeriesValue(numeric, restrictedTarget, workingDigits,
            min(maximumDegree, 180));
        if direct[2] then
            result := ChopValue(direct[1], digits);
        else
            system := DerivePfaffian(numeric, workingDigits, maximumSeed);
            vector := TransportDE(system, restrictedTarget,
                'digits' = digits + 4,
                'branchSide' = branchSide,
                'waypoints' = restrictedWaypoints,
                'frobeniusOrder' = frobeniusOrder,
                'maximumDegree' = maximumDegree,
                'maximumSteps' = maximumSteps,
                'verbose' = verbose);
            result := ChopValue(vector[1], digits);
        end if;
    finally
        Digits := oldDigits;
    end try;
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
        value := Evaluate(series, target, 'digits' = digits,
            'branchSide' = branchSide, 'waypoints' = waypoints,
            'maximumSeed' = maximumSeed, 'frobeniusOrder' = frobeniusOrder,
            'maximumDegree' = maximumDegree, 'maximumSteps' = maximumSteps,
            'verbose' = verbose);
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
            value := Evaluate(series, target, 'digits' = workingDigits,
                'epsilon' = epsilonValue, 'branchSide' = branchSide,
                'waypoints' = waypoints, 'maximumSeed' = maximumSeed,
                'frobeniusOrder' = frobeniusOrder,
                'maximumDegree' = maximumDegree, 'maximumSteps' = maximumSteps,
                'verbose' = false);
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
        validationValue := Evaluate(series, target, 'digits' = workingDigits,
            'epsilon' = validationEpsilon, 'branchSide' = branchSide,
            'waypoints' = waypoints, 'maximumSeed' = maximumSeed,
            'frobeniusOrder' = frobeniusOrder,
            'maximumDegree' = maximumDegree, 'maximumSteps' = maximumSteps,
            'verbose' = false);
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
        if nops(parameters[1]) <> nops(parameters[2]) + 1 then
            error "the implemented generalized function must have type pF(p-1)";
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
    maximumDegree, maximumSteps, verbose
)
    if epsilonOrder = "none" then
        return Evaluate(series, target, 'digits' = digits, 'epsilon' = epsilon,
            'branchSide' = branchSide, 'waypoints' = waypoints,
            'maximumSeed' = maximumSeed, 'frobeniusOrder' = frobeniusOrder,
            'maximumDegree' = maximumDegree, 'maximumSteps' = maximumSteps,
            'verbose' = verbose);
    end if;
    return HypExpand(series, target, epsilonOrder, digits,
        'poleOrder' = poleOrder, 'branchSide' = branchSide,
        'waypoints' = waypoints, 'maximumSeed' = maximumSeed,
        'frobeniusOrder' = frobeniusOrder, 'maximumDegree' = maximumDegree,
        'maximumSteps' = maximumSteps, 'verbose' = verbose);
end proc;

HypergeometricPFQ := proc(
    upper::list, lower::list, argument,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    return FinishPredefined(PredefinedSeries("HypergeometricPFQ", [upper, lower], 1),
        [argument], digits, epsilon, epsilonOrder, poleOrder, branchSide, waypoints,
        maximumSeed, frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

Hypergeometric2F1 := proc(
    a, b, c, argument,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    return FinishPredefined(PredefinedSeries("Hypergeometric2F1", [a,b,c], 1),
        [argument], digits, epsilon, epsilonOrder, poleOrder, branchSide, waypoints,
        maximumSeed, frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

AppellF1 := proc(
    a, b1, b2, c, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    return FinishPredefined(PredefinedSeries("AppellF1", [a,b1,b2,c], 2), [x,y],
        digits, epsilon, epsilonOrder, poleOrder, branchSide, waypoints,
        maximumSeed, frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

AppellF2 := proc(
    a, b1, b2, c1, c2, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    return FinishPredefined(PredefinedSeries("AppellF2", [a,b1,b2,c1,c2], 2), [x,y],
        digits, epsilon, epsilonOrder, poleOrder, branchSide, waypoints,
        maximumSeed, frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

AppellF3 := proc(
    a1, a2, b1, b2, c, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    return FinishPredefined(PredefinedSeries("AppellF3", [a1,a2,b1,b2,c], 2), [x,y],
        digits, epsilon, epsilonOrder, poleOrder, branchSide, waypoints,
        maximumSeed, frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

AppellF4 := proc(
    a, b, c1, c2, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    return FinishPredefined(PredefinedSeries("AppellF4", [a,b,c1,c2], 2), [x,y],
        digits, epsilon, epsilonOrder, poleOrder, branchSide, waypoints,
        maximumSeed, frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

HornG1 := proc(
    a, b, c, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    return FinishPredefined(PredefinedSeries("HornG1", [a,b,c], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

HornG2 := proc(
    a, b, c, d, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    return FinishPredefined(PredefinedSeries("HornG2", [a,b,c,d], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

HornG3 := proc(
    a, b, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    return FinishPredefined(PredefinedSeries("HornG3", [a,b], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

HornH1 := proc(
    a, b, c, d, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    return FinishPredefined(PredefinedSeries("HornH1", [a,b,c,d], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

HornH2 := proc(
    a, b, c, d, e, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    return FinishPredefined(PredefinedSeries("HornH2", [a,b,c,d,e], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

HornH3 := proc(
    a, b, c, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    return FinishPredefined(PredefinedSeries("HornH3", [a,b,c], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

HornH4 := proc(
    a, b, c, d, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    return FinishPredefined(PredefinedSeries("HornH4", [a,b,c,d], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

HornH5 := proc(
    a, b, c, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    return FinishPredefined(PredefinedSeries("HornH5", [a,b,c], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

HornH6 := proc(
    a, b, c, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    return FinishPredefined(PredefinedSeries("HornH6", [a,b,c], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

HornH7 := proc(
    a, b, c, d, x, y,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    return FinishPredefined(PredefinedSeries("HornH7", [a,b,c,d], 2), [x,y], digits,
        epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

LauricellaFA := proc(
    a, b::list, c::list, x::list,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    local parameters;
    if nops(b) <> nops(c) or nops(b) <> nops(x) then
        error "b, c, and x must have the same length";
    end if;
    parameters := [a, op(b), op(c)];
    return FinishPredefined(PredefinedSeries("LauricellaFA", parameters, nops(x)), x,
        digits, epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

LauricellaFB := proc(
    a::list, b::list, c, x::list,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    local parameters;
    if nops(a) <> nops(b) or nops(a) <> nops(x) then
        error "a, b, and x must have the same length";
    end if;
    parameters := [op(a), op(b), c];
    return FinishPredefined(PredefinedSeries("LauricellaFB", parameters, nops(x)), x,
        digits, epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

LauricellaFC := proc(
    a, b, c::list, x::list,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    if nops(c) <> nops(x) then error "c and x must have the same length"; end if;
    return FinishPredefined(PredefinedSeries("LauricellaFC", [a,b,op(c)], nops(x)), x,
        digits, epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose);
end proc;

LauricellaFD := proc(
    a, b::list, c, x::list,
    {digits := 50, epsilon := 0, epsilonOrder := "none", poleOrder := "automatic",
     branchSide := -1, waypoints := [], maximumSeed := 0, frobeniusOrder := 0,
     maximumDegree := 260, maximumSteps := 20000, verbose := false}
)
    if nops(b) <> nops(x) then error "b and x must have the same length"; end if;
    return FinishPredefined(PredefinedSeries("LauricellaFD", [a,op(b),c], nops(x)), x,
        digits, epsilon, epsilonOrder, poleOrder, branchSide, waypoints, maximumSeed,
        frobeniusOrder, maximumDegree, maximumSteps, verbose);
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
    return HypExpand(parsed[1], parsed[2], epsilonOrder, digits,
        'poleOrder' = poleOrder, 'interpolationGuard' = interpolationGuard,
        'branchSide' = branchSide, 'waypoints' = waypoints,
        'maximumSeed' = maximumSeed, 'frobeniusOrder' = frobeniusOrder,
        'maximumDegree' = maximumDegree, 'maximumSteps' = maximumSteps,
        'verbose' = verbose);
end proc;

end module:
