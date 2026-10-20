# Making it able to be run as a script and have all needed packages
using Pkg
Pkg.activate(@__DIR__)  # Activates the environment in the script's directory
Pkg.instantiate()       # Automatically downloads/installs missing packages 

using CSV
using DataFrames
using MLJ, MLJNaiveBayesInterface

# Function to partition data given training fraction,
# train model using this partition,
# test model and return accuracy and f1score.
function part_train_test(mach::Machine, train_fraction::Float64, X, y)
    train_idxs, test_idxs = partition(eachindex(y), train_fraction, stratify=y)
    fit!(mach, rows=train_idxs, force=true)

    y_hat = predict_mode(mach, rows=test_idxs)
    y_true = y[test_idxs]

    return (
        acc = accuracy(y_hat, y_true),
        f1 = f1score(y_hat, y_true)
    )
end

#--- Task I: Data Preperation ---#
println("[--- Task Ⅰ ---]")
data_file = "./data/bank-full.csv"
df = CSV.read(data_file, DataFrame; delim=";")
println("Loaded '$data_file'...")

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

# Mapping logic
for col in categorical_cols
    d = Dict(word => idx - 1 for (idx, word) in enumerate(unique(df[!, col])))
    transform!(df, col .=> ByRow(x -> get(d, x, missing)), renamecols=false)
end

# Removes any rows that contain missing or NA data
dropmissing!(df)

df.y = Int64.(df.y)

# Coerce Scientific Types so model interprets data correctly
# Attributes => Continuous
# Outcomes => Multiclass
coerce!(df, Count => Continuous)
coerce!(df, :y => Multiclass)

# Seperate Dataframe into attributes and outcomes
initial_y, initial_X = unpack(df, ==(:y))

println("Data Prepared")
println("[--------------]")
println()

#--- Task II: Train and Test a Naive Bayes Model ---#
println("[--- Task Ⅱ ---]")

# Gets index values for training and testing data
println("Split data using 70-30 stratified")

# Loads GaussianNBClassifier and instantiates the model
GaussianNBClassifier = @load GaussianNBClassifier pkg=NaiveBayes
gnb_model = GaussianNBClassifier()

# Wrap the model and data into an MLJ machine
initial_machine = machine(gnb_model, initial_X, initial_y)
initial_results = part_train_test(initial_machine, 0.7)

println("The accuracy of my Naive Bayes Model is: $(initial_results[1])")
println("The F1 Score of my Naive Bayes Model is: $(initial_results[2])")

#--- Task III ---#
fractions = 0.1:0.1:0.9


# comparison_df = DataFrame(
#     Train_Fraction = ["$(Int(f * 100))%" for f in fractions],
#         Accuracy = ["$(round(r.measurements[1] * 100, digits = 2))%" for r in results],
#         F1_Score = [r.measurements[2] for r in results]
# 
# )


