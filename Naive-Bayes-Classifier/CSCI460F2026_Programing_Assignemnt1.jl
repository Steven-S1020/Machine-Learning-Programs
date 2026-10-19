using CSV
using DataFrames
using MLJ
using MLUtils


#--- Task I: Data Preperation ---#
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

dropmissing!(df)

#--- Task II: Train and Test a Naive Bayes Model ---#
train_df, test_df = MLUtils.splitobs(df; at = 0.7, stratified = df.y)
