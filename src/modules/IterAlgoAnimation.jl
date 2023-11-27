module IterAlgoAnimation

using GLMakie
using LinearAlgebra
using ColorSchemes
using Base.Threads

include("../standard_examples.jl")
include("../others.jl")
include("../figures.jl")
include("../one_iteration.jl")
include("../combine_figure_method.jl")
include("../make_animations.jl")
include("../define_animations.jl")

export setup_gradient
export setup_projgradient
export setup_linesearch_gradient
export setup_penalized_gradient

export setup_gradient3d
export setup_primaldual3d
export setup_augmented_lagrangian3d
export setup_penalized_gradient3d

end # module IterAlgoAnimation