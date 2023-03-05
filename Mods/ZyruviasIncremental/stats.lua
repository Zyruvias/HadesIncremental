--[[
TODO: Type checking
TODO: Sample Size
TODO: Chi-Square test
TODO: Add more quantile algorithms 
      use: http://127.0.0.1:11774/library/stats/html/quantile.html
]]


--[[ Generics ]]--

local function assertTables(...)
    for _, t in pairs({...}) do
      assert(type(t) == "table", "Argument must be a table")
    end
  end
  
  
  -- Simple map function
  local function map(t, f, ...)
    assert(t ~= nil, "No table provided to map")
    assert(f ~= nil, "No function provided to map")
    local output = {}
  
    for i, e in pairs(t) do
      output[i] = f(e, ...)
    end
    return output
  end 
  
  
  -- Simple reduce function
  local function reduce(t, f)
    assert(t ~= nil, "No table provided to reduce")
    assert(f ~= nil, "No function provided to reduce")
    local result
  
    for i, value in ipairs(t) do
      if i == 1 then
        result = value
      else
        result = f(result, value)
      end 
    end
    return result
  end 
  
  
  -- Returns a table consisting of all values looked up in the tables
  local function multiSubscript(i, ...)
    assertTables(...)
    assert(#{...} > 0, "Must provide at least one table")
    return map({...}, function(t, index) return t[index] end, i)
  end 
  
  
  -- checks if a value is in a table as a value or key
  local function in_table(value, t, key)
    assert(type(t) == 'table', "The second argument must be a table")
    key = key or false
    for i, e in pairs(t) do
      if value == (key and i or e) then
        return true
      end
    end
    return false
  end
  
  
  -- Concatenates tables and scalars into one list
  local function unify(...)
    local output = {}
    for i, element in ipairs({...}) do
      if type(element) == 'number' then
        table.insert(output, element)
      elseif type(element) == 'table' then
        for j, row in ipairs(element) do
          table.insert(output, row)
        end
      end 
    end 
    return output
  end 
  
  
  -- Integrates a function from start to stop in delta sized steps
  local function integral(f, start, stop, delta, ...)
    local delta = delta or 1e-5
    local area = 0
    for i = start, stop, delta do
      area = area + f(i, ...) * delta
    end
    return area
  end
  
  
  -- Integrates a function from a given start value until
  -- it fills the absolute area a
  local function integralUntil(f, a, start, delta, ...)
    assert(f ~= nil, "No function provided")
    assert(a > 0, "Target Area must be > 0")
    start = start or 0
    delta = delta or 0.001
    local currentA = 0
  
    while currentA < a do
      currentA = currentA + math.abs(f(start, ...) * delta)
      start = start + delta
    end
    return start - delta / 2
  end
  
  
  -- Calculates the factorial of a number n recursively
  function factorial(x)
    assert(x >= 0, "x has to be a positive integer or 0")
    if (x == 0) then
      return 1
    elseif (x == 1) then
      return x
    elseif (x % 1 == 0) then
      return x * (factorial(x - 1))
    else 
      return gamma(x - 1)
    end
  end
  
  -- finds the x neded for a givnen function f
  -- Need to find a way to pass min and max bounds for estimator
  function findX(y, f, accuracy, ...)
    assert(y ~= nil, "No y value provided")
    assert(f ~= nil, "No function provided")
    accuracy = accuracy or 0.001
  
    local minX, maxX, yVal, xVal = -100, 100, 0, 0
  
    while (maxX - minX > accuracy) do 
      yVal = f(xVal, ...)
      if (yVal > y) then
        maxX = xVal
      else
        minX = xVal
      end 
      xVal = (maxX + minX) / 2
    end 
    return xVal
  end 
  
  
  -- I have no idea what the hell is going on here. Taken from:
  -- http://rosettacode.org/wiki/Gamma_function#Lua
  function gamma(x)
    local gamma =  0.577215664901
    local coeff = -0.65587807152056
    local quad  = -0.042002635033944
    local qui   =  0.16653861138228
    local set   = -0.042197734555571
  
    local function recigamma(z)
      return z + gamma * z^2 + coeff * z^3 + quad * z^4 + qui * z^5 + set * z^6
    end
     
    local function gammafunc(z)
      if z == 1 then return 1
      elseif math.abs(z) <= 0.5 then return 1 / recigamma(z)
      else return (z - 1) * gammafunc(z - 1)
      end
    end
  
    return gammafunc(x)
  end 
  
  
  -- Beta function 
  function beta(x, y)
    assert(x > 0, "x must be positive")
    assert(y > 0, "y must be positive")
    return (gamma(x) * gamma(y)) / gamma(x + y)
  end
  
  
  -- p-value of a quantile q of a probability function f
  function pValue(q, f, ...)
    assert(q ~= nil, "pValue needs a q-value")
    assert(f ~= nil, "pValue needs a function")
    return math.abs(1 - math.abs(f(q, ...) - f(-q, ...)))
  end
  
  
  --[[ Basic Arithmetic functions needed for aggregate functions ]]--
  local function sum(...) 
    return reduce(unify(...), function(a, b) return a + b end)
  end 
  
  
  local function count(...) 
    return #unify(...) 
  end 
  
  
  local function mean(...) 
    return sum(...) / count(...) 
  end 
  
  
  local function sumSquares(...)
    local data = unify(...)
    local mu = mean(data)
  
    return sum(map(data, function(x) return (x - mu)^2 end))  
  end 
  
  
  local function var(...)
    return sumSquares(...) / (count(...) - 1)
  end
  
  
  local function varPop(...)
    return sumSquares(...) / count(...)
  end 
  
  
  local function sd(...)
    return math.sqrt(var(...))
  end 
  
  
  local function sdPop(...)
    return math.sqrt(varPop(...))
  end
  
  
  local function min(...)
    local data = unify(...)
    
    table.sort(data)
    return data[1]
  end 
  
  
  local function max(...)
    local data = unify(...)
    table.sort(data)
    return data[#data]
  end 
  
  
  -- Covariance
  function cov(t1, t2)
    assertTables(t1, t2)
    assert(#t1 == #t2, "The tables have to be of equal length")
  
    local mu1, mu2 = mean(t1), mean(t2)
    local dev1 = map(t1, function(x) return x-mu1 end)
    local dev2 = map(t2, function(x) return x-mu2 end)
    
    local ss = 0
    for i, v in ipairs(dev1) do
      ss = ss + v * dev2[i]
    end 
  
    return ss / (#t1 - 1)
  end 
  
  
  --Correlation
  function cor(t1, t2, method)
    assertTables(t1, t2)
    assert(#t1 == #t2, "The tables have to be of equal length")
    method = method or "Pearson"
  
    if method == "Pearson" then
      return cov(t1, t2) / (sd(t1) * sd(t2))
    else 
      return nil -- Implement spearman and kendall
    end 
  end
  
  function unique(t)
    assertTables(t)
    local uniqueValues = {}
    for _, value in ipairs(t) do
      if in_table(value, uniqueValues) == false then
        table.insert(uniqueValues, value)
      end 
    end
    return uniqueValues
  end
  
  
  function frequency(t)
    assertTables(t)
    local counts = {}
    for _, value in ipairs(t) do
      if in_table(value, counts, true) then
        counts[value] = counts[value] + 1
      else 
        counts[value] = 1
      end
    end 
    return counts
  end
  
  
  -- Pooled standard deviation for two already calculated standard deviations
  -- Seconds return is the new sample size adjusted for degrees of freedom
  function sdPooled(sd1, n1, sd2, n2)
    return math.sqrt(((n1 - 1) * sd1^2 + (n2 - 1) * sd2^2) / (n1 + n2 - 2))
  end 
  
  
  -- Calculates the quantile
  -- Currently uses the weighted mean of the two values the position is inbetween
  function quantile(t, q)
    assert(t ~= nil, "No table provided to quantile")
    assert(q >= 0 and q <= 1, "Quantile must be between 0 and 1")
    table.sort(t)
    local position = #t * q + 0.5
    local mod = position % 1
  
    if position < 1 then 
      return t[1]
    elseif position > #t then
      return t[#t]
    elseif mod == 0 then
      return t[position]
    else
      return mod * t[math.ceil(position)] +
             (1 - mod) * t[math.floor(position)] 
    end 
  end 
  
  
  function median(t)
    assert(t ~= nil, "No table provided to median")
    return quantile(t, 0.5)
  end
  
  
  function quartile(t, i)
    local quartiles = {0, 0.25, 0.5, 0.75, 1}
    assert(in_table(i, {1,2,3,4,5}), "i must be an integer between 1 and 5")
    if i == 1 then 
      return min(t)
    elseif i== 5 then
      return max(t)
    else 
      return quantile(t, quartiles[i])
    end 
  end
  
  function mode(t)
    local frequencies = frequency(t)
    local last
    local most
  
    for value, repeats in pairs(frequency) do
      if not last or (value > last) then
        last = repeats
        most = value
      end
    end
  
    return most
  end
  
  
  --[[ Normal Distribution Functions ]]--
  
  -- Probability Density function of a Normal Distribution
  function dNorm(x, mu, sd)
    assert(type(x) == "number", "x must be a number")
    local mu = mu or 0
    local sd = sd or 1
  
    return (1 / 
           (sd * math.sqrt(2 * math.pi))) * 
           math.exp(-(((x - mu) * (x - mu)) / (2 * sd^2)))
  end
  
  
  -- CDF of a normal distribution
  function pNorm(q, mu, sd, accuracy)
    assert(type(q) == "number", "q must be a number")
    mu = mu or 0
    sd = sd or 1
    accuracy = accuracy or 1e-3
  
    return 0.5 + 
      (q > 0 and 1 or -1) * integral(dNorm, 0, math.abs(q), accuracy, mu, sd)
  end
  
  -- Quantile function of the Normal distribution
  -- Calculates the Z-Score based on the cumulative probabiltiy
  function qNorm(p, accuracy)
    accuracy = accuracy or 0.01
    return  integralUntil(dNorm, p, -20, 0.0001)
  end 
  
  
  --[[ T-Distribution Functions ]]--
  
  -- Probability Density function of a T Distribution
  function dT(x, df)
    return gamma((df + 1) / 2) / 
           (math.sqrt(df * math.pi) * gamma(df / 2)) * 
           (1 + x^2 / df)^(-(df + 1) / 2)
  end 
  
  
  -- CDF of the T-Distribution
  function pT(q, df, accuracy)
    assert(df > 0, "More at least 1 degree of freedom needed")
    accuracy = accuracy or 1e-4
  
    return 0.5 + (q > 0 and 1 or -1) * integral(dT, 0, math.abs(q), accuracy, df)
  end 
  
  -- Finds T-Ratio for a given p-value.
  function qT(p, df, accuracy)
    accuracy = accuracy or 0.01
    return integralUntil(dT, p, -20, 0.0001, df)
  end 
  
  
  --[[ Chi-Square Distribution Functions ]]--
  
  -- Probability density of the chi square distribution.
  function dChisq(x, df)
    return 1 / (2^(df / 2) * gamma(df / 2)) * x^(df / 2 - 1) * math.exp(-x / 2)
  end
  
  
  -- CDF of the Chi square distribution.
  function pChisq(q, df)
    return integral(dChisq, 0, q, 1e-4, df)
  end 
  
  
  -- Quantile function of the Chi-Square Distribution.
  function qChisq(p, df, accuracy)
      accuracy = accuracy or 0.001
      return integralUntil(dChisq, p, 0, 0.001, df)
  end 
  
  
  --[[ F Distribution Functions ]]--
  
  -- Probability Density of the F distribution
  function dF(x, df1, df2)
    return math.sqrt(((df1 * x)^df1 * df2^df2) / 
                     ((df1 * x + df2)^(df1 + df2))) / 
                    (x * beta(df1 / 2, df2 / 2))
  end
  
  
  -- CDF of the F distribution
  function pF(x, df1, df2)
    return integral(dF, 0.0001, x, 1e-4, df1, df2)
  end
  
  
  -- Quantile function of the F Distribution
  function qF(p, df1, df2, accuracy)
    if p == 0 then
      return 0
    elseif p == 1 then
      return math.huge
    else
      assert(p > 0 and p < 1, "p must be between 0 and 1")
    end
    accuracy = accuracy or 0.001
    return integralUntil(dF, p, 0.00001, accuracy, df1, df2)
  end
  
  
  --[[ Tests ]]--
  
  -- Calculates the Z-Score for one or two samples. 
  -- Assumes non equivalent Variance.
  function zValue(y1, sd1, n1, y2, sd2, n2, sameVar)
    assert(sd1 > 0, "Standard Deviation has to be positive")
    assert(n1  > 1, "Sample Size has to be at least 2")
    
    y2 = y2 or 0
    sameVar = sameVar or false
    local z
    local d = y1 - y2
  
    if n2 == nil then
      z = d / (sd1 / math.sqrt(n1))
    elseif sameVar then
      z = d / math.sqrt(sd1^2 / n1 + sd2^2 / n2)
    else
      z = d / (sdPooled(sd1, n1, sd2, n2) * math.sqrt(1 / n1 + 1 / n2))
    end
  
    return z
  end
  
  
  -- Performs a z-test on two tables and returns z-statistic.
  function zTest(t1, t2, sameVar)
    assertTables(t1, t2)
    return zValue(mean(t1), sd(t1), #t1, mean(t2), sd(t2), #t2, sameVar)
  end 
  
  
  -- Calculates the p-value of a two sample zTest.
  function zTestP(t1, t2, sameVar)
    assertTables(t1, t2)
    return pValue(zTest(t1, t2, sameVar), pNorm)
  end
  
  
  -- Calculates the t-value of one or two means, assuming non equivalent variance.
  function tValue(y1, sd1, n1, y2, sd2, n2, sameVar)
    return zValue(v1, sd1, n1, v2, sd2, n2, sameVar)
  end
  
  
  -- Performs a t-test on two tables and returns t-statistic.
  function tTest(t1, t2, sameVar)
    return zTest(t1, t2, sameVar)
  end 
  
  
  -- Calculates the p-value of a two sample tTest.
  function tTestP(t1, t2, sameVar)
    assertTables(t1, t2)
    return pValue(zTest(t1, t2, sameVar), pT, count(t1, t2) - 2)
  end
  
  
  -- Returns the f-value of two variances
  function fValue(s1, s2)
    return s1 / s2
  end
  
  
  -- Performs an f-test on two tables
  function fTest(t1, t2)
    assertTables(t1, t2)
  
    return var(t1) / var(t2)
  end
  
  
  -- Returns the p-value of an f-test on two tables
  function fTestP(t1, t2)
    assertTables(t1, t2)
    return pValue(fTest(t1, t2), pF, #t1, #t2)
  end 

