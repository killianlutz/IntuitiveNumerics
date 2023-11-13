using Pkg
Pkg.activate("./venv_IterAlgoAnimation/")
# Pkg.instantiate() # first use: resolves appropriate package versions

include("../src/IterAlgoAnimation.jl")
using .IterAlgoAnimation
import GLMakie.theme_dark
import GLMakie.set_theme!
set_theme!(theme_dark())

#####
# sequence parameters
nframe = 250
npoints = 40
xygrid_lims = (-1.0, 2.0, -1.0, 2.0)#(-5.0, 5.0, -5.0, 5.0)
params = (; nframe, npoints, xygrid_lims)

" gradient step "
fig, step_forward = setup_gradient(params...; step_size = 0.005, objective_type = "multimodal")
# rosenbrock : 0.01, 0.005, 0.004, 0.001 ; 1500 frames ; (0.5, 1.2, 0.5, 1.2) or (-1.5, 1.5, -1.5, 1.5)
" gradient step in 3D "
fig, step_forward = setup_gradient3d(params...; step_size = 0.05, objective_type = "gaussian")

" optimal step gradient "
fig, step_forward = setup_linesearch_gradient(params...; step_size = 0.1, objective_type = "multimodal")

" projected gradient "
fig, step_forward = setup_projgradient(params...; step_size = 0.01, objective_type = "1modeat0", constraint_type = "box")

" uzawa/arrow-hurwicz "
A = [1.0 0.05; 0.05 1.0] # positive definite ?
b = A*[1.5, 1.2]
fig, step_forward = setup_primaldual3d(params...; step_size = 0.05, algorithm = "arrowhurwicz", A, b)
# step size 0.05 for uzawa/arrowhurwicz and limits (-1.0, 2.0, -1.0, 2.0)

" augmented lagrangian "
A = [1.0 0.05; 0.05 1.0] # positive definite ?
b = A*[1.5, 1.2]
B = [1.0 0; 0 1.0] # try with anisotropic axes
fig, step_forward = setup_augmented_lagrangian3d(params...; step_size = 1.0, A, b, B, grad_step = 0.001, grad_iter = 200)

" penalized gradient 2D / 3D "
fig, step_forward = setup_penalized_gradient(params...; step_size = 0.01, objective_type = "gaussian", ϵ = 1e-0)

fig, step_forward = setup_penalized_gradient3d(params...; step_size = 0.0001, objective_type = "gaussian", ϵ = 1e-1)

display(fig)
for i in 1:nframe
    i == 1 ? sleep(2.0) : sleep(0.01)
    step_forward(i)
end

# # with periodic cameras moves 
# fig, step_forward = setup_gradient3d(params...; step_size = 0.05, objective_type = "gaussian")
# ax = fig.content[1]
# for i in 1:nframe
#     step_forward(i)
#     ax.azimuth[] = 1.7π + 3.0 * sin(2π * i / 1000)
#     ax.elevation[] = 0.15 + 1.0 * sin(2π * i / 800)
#     sleep(0.01)
# end