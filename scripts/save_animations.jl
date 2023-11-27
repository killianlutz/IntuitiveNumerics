using Pkg
Pkg.activate("../venv_IterAlgoAnimation/")

include("../src/modules/IterAlgoAnimation.jl")
using .IterAlgoAnimation

# path to which animations will be saved
cd(".\\animations/")

animation_to_save = [
    IterAlgoAnimation.save_descent,
    IterAlgoAnimation.save_linesearch,
    IterAlgoAnimation.save_projected,
    IterAlgoAnimation.save_penalized,
    IterAlgoAnimation.save_uzawa,
    IterAlgoAnimation.save_arrowhurwicz,
    IterAlgoAnimation.save_augmented_lagrangian
]

foreach(animation_to_save) do animation 
    animation()
end