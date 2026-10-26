######################################################
#  Student Name: Steven Stokes
#  Course Code: CSCI 460 -- Fall 2026
#  Assignment Due Date: 10/25/2026
#  GitHub Link: https://github.com/Steven-S1020/Machine-Learning-Programs/tree/main/Naive-Bayes-Classifier
######################################################
# Making it able to be run as a script and have all needed packages
using Pkg
Pkg.activate(@__DIR__)  # Activates the environment in the script's directory
Pkg.instantiate()       # Automatically downloads/installs missing packages 

using CSV
using DataFrames, PrettyTables
using MLJScikitLearnInterface
using MLJ
using Statistics
import Random.Xoshiro


#--- Task I: Data Preperation ---#
println("[--- Task I ---]")
data_file = "./data/bank-full.csv"
df = CSV.read(data_file, DataFrame; delim=";")
println("Loaded '$data_file'...")

# Removes any rows that contain missing, NA, or "unknown" data
dropmissing!(df)
filter!(row -> !any(==("unknown"), row), df)


# Coerce Scientific Types so model interprets data correctly
# Outcomes => Multiclass
# Textual => Multiclass
# Attributes => Continuous
coerce!(df, :y => OrderedFactor)
coerce!(df, Textual => Multiclass)
coerce!(df, Count => Continuous)

# Seperate Dataframe into attributes and outcomes
y, X = unpack(df, ==(:y))

# This maps all Multiclass and OrderedFactor columns to integer encoded values.
encoder = MLJ.OrdinalEncoder(ordered_factor=true)
mach = machine(encoder, X) |> fit!
X = MLJ.transform(mach, X)


println("Data Prepared")
println("[--------------]")
println()

#--- Task II: Train and Test a Naive Bayes Model ---#
println("[--- Task II ---]")

# Gets index values for training and testing data
println("Split data using 70-30 stratified")

# Loads GaussianNBClassifier and instantiates the model
GaussianNBClassifier = (@load GaussianNBClassifier pkg=MLJScikitLearnInterface verbosity=0)
gnb_model = GaussianNBClassifier()

# Wrap the model and data into an MLJ machine
train_idxs, test_idxs = partition(eachindex(y), 0.7, stratify=y, shuffle=true)
custom_holdout = [(train_idxs, test_idxs)]
initial_results = evaluate(gnb_model, X, y, resampling=custom_holdout, measure=[accuracy, f1score])
results_df = DataFrame(
    Measure = ["Accuracy", "F1 Score"],
    Value   = initial_results.measurement,
)
pretty_table(results_df, show_first_column_label_only = true)

#--- Task III ---#
println("[--- Task III ---]")

fractions = 0.1:0.1:0.9
n_iter = 10

results = DataFrame(
    Train_Fraction = String[],
    Acc_Mean = Float64[], Acc_Std = Float64[],
    F1_Mean  = Float64[], F1_Std  = Float64[],
)

for f in fractions
    accs = Float64[]
    f1s  = Float64[]

    for i in 1:n_iter
        # Different seed for each (fraction, iteration) pair
        seed = round(Int, f * 100) * 100 + i
        train, test = partition(eachindex(y), f, stratify=y, shuffle=true, rng=Xoshiro(seed))

        r = evaluate(gnb_model, X, y,
                     resampling=[(train, test)],
                     measure=[accuracy, f1score],
                     verbosity=0)

        push!(accs, r.measurement[1])
        push!(f1s,  r.measurement[2])
    end

    push!(results, ("$(Int(round(f * 100)))%", mean(accs), std(accs), mean(f1s), std(f1s)))
end

pretty_table(results, show_first_column_label_only = true)
