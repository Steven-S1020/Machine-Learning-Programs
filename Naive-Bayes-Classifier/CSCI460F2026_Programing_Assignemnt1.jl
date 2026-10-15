using CSV
using DataFrames

df = CSV.read("./data/bank-full.csv", DataFrame; delim=";")

#=
Map each categorical variables into an integer number starting at 0. This applies to the 
columns: ‘job’, 'marital', 'education', 'default', 'housing', 'loan', 'contact', 'month', 
'poutcome', and the target column ‘y’
=#
categorical_cols = [
    "job",
    "marital",
    "education",
    "default",
    "housing",
    "loan",
    "contact",
    "month",
    "poutcome",
    "y"
]

for col in categorical_cols
    d = Dict(word => idx - 1 for (idx, word) in enumerate(unique(df[!, col])))
    transform!(df, col .=> ByRow(x -> get(d, x, missing)), renamecols=false)
end


