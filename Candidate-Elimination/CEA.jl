# Canidate Elimination Algorithm for finding
# all maximally specific and general hypotheses
# in the version space.

struct Point
    x::Float64
    y::Float64
end

struct Circle
    x::Int
    y::Int
    r::Int
end

positivePoints = [
    Point(0,0)
    Point(1,0)
    Point(1/2,-1/2)
]

negativePoints = [
    Point(2,3)
    Point(4,-1)
    Point(-1,4)
    Point(-3,1)
]

DOMAIN = -5:1:5
RANGE = -5:1:5
R_RANGE = 1:1:10

# Takes Vector{Point} for positive points and Vector{Point} for negative points.
# Bruteforces through every circle in instance space and returns a Set{Circle}
# where the set is the version space.
function getVersionSpace(points⁺::Vector{Point}, points⁻::Vector{Point})
    versionSpace = Set{Circle}()

    for x in DOMAIN
        for y in RANGE
            for r in R_RANGE
                circle = Circle(x,y,r)
                (_checkNegative(circle, points⁻) && _checkPositive(circle, points⁺)
                 ? push!(versionSpace,circle)
                 : nothing)
            end
        end
    end

    return versionSpace
end

# Helper function to check whether for a given Circle
# are all negative points outside boundary.
# If so return true.
function _checkNegative(circle::Circle, points⁻::Vector{Point})
    x₁, y₁, r = circle.x, circle.y, circle.r
    for point in points⁻
        x₂, y₂ = point.x, point.y

        distance = √((x₂-x₁)^2 + (y₂ - y₁)^2)
        if distance <= r
            return false
        end
    end

    return true
end


# Helper function to check whether for a given Circle
# are all positive points contained inside boundary.
# If so return true.
function _checkPositive(circle::Circle, points⁺::Vector{Point})
    x₁, y₁, r = circle.x, circle.y, circle.r
    for point in points⁺
        x₂, y₂ = point.x, point.y

        distance = √((x₂-x₁)^2 + (y₂ - y₁)^2)
        if distance > r
            return false
        end
    end

    return true
end

# Checks if first circle is fully contained in second circle.
function containedIn(circ1::Circle, circ2::Circle)
    x₁, y₁, r₁ = circ1.x, circ1.y, circ1.r
    x₂, y₂, r₂ = circ2.x, circ2.y, circ2.r

    distance = √((x₂-x₁)^2 + (y₂ - y₁)^2)
    return distance + r₁ <= r₂
end

# Returns set of maximally specific hypotheses
function getMaximallySpecific(versionSpace::Set{Circle})
    maximallySpecific = copy(versionSpace)

    for circle_keep in collect(versionSpace)
        circle_remove = nothing

        for c in versionSpace
            if c !== circle_keep && containedIn(c, circle_keep)
                circle_remove = circle_keep
                delete!(maximallySpecific, circle_remove)
            end
        end
    end

    return maximallySpecific
end

# Returns set of maximally general hypotheses
function getMaximallyGeneral(versionSpace::Set{Circle})
    maximallyGeneral = copy(versionSpace)

    for circle_keep in collect(versionSpace)
        circle_remove = nothing

        for c in versionSpace
            if c !== circle_keep && containedIn(c, circle_keep)
                circle_remove = c
                delete!(maximallyGeneral, circle_remove)
            end
        end
    end

    return maximallyGeneral
end

VS = getVersionSpace(positivePoints, negativePoints)
MS = getMaximallySpecific(VS)
MG = getMaximallyGeneral(VS)

println("Version Space:")
for c in VS println(c) end
println()
println("Maximally Specific:")
for c in MS println(c) end
println()
println("Maximally General:")
for c in MG println(c) end
