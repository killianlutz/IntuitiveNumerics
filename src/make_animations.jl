set_theme!(theme_dark())

const NPOINTS = 40

function setup_and_record(setup_function, parameters, filename)
    nframe = parameters.nframe + 24
    fig, iter = setup_function(parameters)

    record(fig, filename, 1:nframe; framerate = 24) do frame
        (i <= 24) ? display(fig) : iter(frame)
    end
end

function setup_and_record(animation::Dict, setups::Dict, to_filename::Function)
    params = (; nframe=animation[:nframe], xygrid_lims=animation[:xygrid_lims], NPOINTS)
    filename = to_filename(animation)

    setup_and_record(params, filename) do p
        setups["$(animation[:dim])"](p, animation)
    end
end

################ descent ################
function save_descent_(animations::Dict)
    # method specific
    setups = Dict(
        dim => ((par, anim) -> setup(par...; step_size=anim[:step], objective_type=anim[:objective])) 
        for (dim, setup) in zip(("2D", "3D"), (setup_gradient, setup_gradient3d))
    )

    to_filename(anim) = begin 
        finishes_with = ""
        if !ismissing(anim[:zoom])
            finishes_with = "_zoom"
        elseif !ismissing(anim[:dynamic])
            finishes_with = "_dynamic"
        end
        "$(anim[:method])_$(anim[:objective])_$(anim[:dim])_step$(replace_float2string(anim[:step]))$(finishes_with).mp4"
    end

    foreach(animations) do x
        setup_and_record(x, setups, to_filename)
    end
end

function save_descent()
    animations = Vector{Any}[]
    base_animation = Dict(
        :method => "descent",
        :objective => "gaussian",
        :constraint => missing,
        :dim => "2D",
        :nframe => 500,
        :xylims => (-5.0, 5.0, -5.0, 5.0),
        :step => 0.01,
        :dynamic => missing,
        :zoom => missing
    )

    for objective in ("gaussian", "multimodal"), step in (0.1, 0.005), dim in ("2D", "3D")
        animation = deepcopy(base_animation)
        animation[:objective] = objective
        animation[:step] = step
        animation[:dim] = dim

        push!(animations, animation)
    end

    for step in (0.004, 0.005)
        animation = deepcopy(base_animation)
        animation[:objective] = "rosenbrock"
        animation[:nframe] = 1500
        animation[:step] = step

        push!(animations, animation)
    end

    animation = deepcopy(base_animation)
    animation[:objective] = "rosenbrock"
    animation[:nframe] = 1500
    animation[:xylims] = (0.5, 1.5, 0.5, 1.5)
    animation[:step] = 0.005
    animation[:zoom] = true

    push!(animations, animation)

    save_descent_(animations)
end

################ linesearch ################
function save_linesearch()
    
end

################ projected ################
function save_projected()
    
end

################ penalized ################
function save_penalized()
    
end

################ uzawa ################
function save_uzawa()
    
end

################ step_arrowhurwicz ################
function save_arrowhurwicz()
    
end

################ augmented lagrangian ################
function save_augmented_lagrangian()
    
end


################ else 
function replace_float2string(x)
    replace(string(x), "." => "_")
end


## record animation
# fig, iter = setup_projgradient(params...; step_size = 0.0005, objective_type = "multimodal", constraint_type = "ball")
# record(fig, "descent_projected_multimodal_ball.mp4", 1:nframe; framerate = 24) do i
#     if i <= 24
#         display(fig)
#     else
#         iter()
#     end
# end

# fig, iter = setup_gradient(params...; step_size = 0.005, objective_type = "rosenbrock")
# display(fig)
# record(fig, "descent_rosenbrock2D_step0_005_zoom.mp4", 1:nframe; framerate = 24) do _
#     iter()
# end

# fig, iter = with_theme(theme_dark()) do 
#     setup_gradient3d(params...; step_size = 0.05, objective_type = "gaussian")
# end
# ax = fig.content[1]
# display(fig)
# record(fig, "descent_gaussian_dynamic.mp4", 1:nframe; framerate = 24) do frame
#     ax.azimuth[] = 1.7π + 3.0 * sin(2π * frame / 1000)
#     ax.elevation[] = 0.15 + 1.0 * sin(2π * frame / 800)
#     iter()
# end

# fig, iter = with_theme(theme_dark()) do 
#     setup_gradient3d(params...; step_size = 0.1, objective_type = "gaussian")
# end
# display(fig)
# record(fig, "gaussian.mp4", 1:nframe; framerate = 24) do _
#     iter()
# end

# fig, iter = setup_gradient(params...; step_size = 0.0005, objective_type = "multimodal")
# display(fig)
# record(fig, "descent_multimodal2D.mp4", 1:nframe; framerate = 24) do _
#     iter()
# end

# fig, iter = setup_linesearch_gradient(params...; step_size = 0.1, objective_type = "multimodal")
# display(fig)
# record(fig, "linesearch_descent_multimodal2D.mp4", 1:nframe; framerate = 1) do i
#     i <= 1 ? display(fig) : iter()
# end

# fig, iter = setup_linesearch_gradient(params...; step_size = 0.1, objective_type = "gaussian")
# display(fig)
# record(fig, "linesearch_descent_gaussian2D_maxstep0.1.mp4", 1:nframe; framerate = 1) do i
#     i <= 1 ? display(fig) : iter()
# end

# fig, iter = with_theme(theme_dark()) do 
#     setup_gradient3d(params...; step_size = 0.1, objective_type = "gaussian")
# end
# display(fig)
# record(fig, "descent_gaussian.mp4", 1:nframe; framerate = 24) do _
#     iter()
# end