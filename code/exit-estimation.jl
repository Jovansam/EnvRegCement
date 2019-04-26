using CSV
using DataFrames
using Statistics
using Impute
using FixedEffectModels
using GLM

# Input files
dataFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\data\\"
codeFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\code\\"
resultsFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\results\\"

include(codeFolder * "demand-estimation.jl")
include(codeFolder * "production-data.jl")

dfExit = by(dfProd, [:Market, :firmID], exit = :year => maximum)

dfExit = dfExit[dfExit[:exit] .< 1998.0, :]

dMktFirmtoExitYear = Dict()
for mkt in vMkts
    vFirms = unique(vcat([dMkttoFirms[mkt, year] for year in vYears]...))
    for firm in vFirms
        dMktFirmtoExitYear[mkt, firm] = dfExit[(dfExit[:Market] .== mkt) .* (dfExit[:firmID] .== firm), :exit]
    end
end

df = dfProd

df[:exit] = zeros(size(df, 1))
df[:totcap] = zeros(size(df, 1))

dfTotCap = by(dfProd, [:Market, :year], totcap = :cap => sum)

for i in 1:size(df, 1)
    if df[i, :year] ∈ dMktFirmtoExitYear[df[i, :Market], df[i, :firmID]]
        df[i, :exit] = 1.0
    end
    mkt = df[i, :Market]
    year = df[i, :year]
    df[i, :totcap] = dfTotCap[(dfTotCap[:Market] .== mkt) .* (dfTotCap[:year] .== year), :totcap][1]
end

df[:compcap] = df[:totcap] - df[:cap]
df

#probit = glm(@formula(exit ~ sumcap + post1990), df, Binomial(), ProbitLink())
