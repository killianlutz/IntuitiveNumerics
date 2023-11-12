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
        "$(anim[:method])/$(anim[:objective])_$(anim[:dim])_step$(replace_float2string(anim[:step]))$(finishes_with).mp4"
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
function save_linesearch_(animations::Dict)
    # method specific
    setups = Dict(
        dim => ((par, anim) -> setup(par...; step_size=anim[:step], objective_type=anim[:objective])) 
        for (dim, setup) in zip(("2D", "3D"), (setup_linesearch_gradient, setup_linesearch_gradient))
    )

    to_filename(anim) = "$(anim[:method])/$(anim[:objective])_$(anim[:dim])_step$(replace_float2string(anim[:step])).mp4"

    foreach(animations) do x
        setup_and_record(x, setups, to_filename)
    end
end

function save_linesearch()
    animations = Vector{Any}[]
    base_animation = Dict(
        :method => "linesearch",
        :objective => "gaussian",
        :constraint => missing,
        :dim => "2D",
        :nframe => 20,
        :xylims => (-5.0, 5.0, -5.0, 5.0),
        :step => 0.1,
    )

    for objective in ("gaussian", "multimodal")
        animation = deepcopy(base_animation)
        animation[:objective] = objective

        push!(animations, animation)
    end

    save_linesearch_(animations)
end

################ projected ################
function save_projected_(animations::Dict)
    # method specific
    setups = Dict(
        dim => ((par, anim) -> setup(par...; step_size=anim[:step], objective_type=anim[:objective], constraint_type=anim[:constraint])) 
        for (dim, setup) in zip(("2D", "3D"), (setup_projgradient, setup_projgradient))
    )

    to_filename(anim) = "$(anim[:method])/$(anim[:objective])_$(anim[:dim])_step$(replace_float2string(anim[:step]))_$(anim[:constraint]).mp4"

    foreach(animations) do x
        setup_and_record(x, setups, to_filename)
    end
end

function save_projected()
    animations = Vector{Any}[]
    base_animation = Dict(
        :method => "projected",
        :objective => "gaussian",
        :constraint => "ball",
        :dim => "2D",
        :nframe => 800,
        :xylims => (-5.0, 5.0, -5.0, 5.0),
        :step => 0.0005,
    )

    objective_to_nframe = Dict("gaussian" => 800, "multimodal" => 1000, "1modeat0" => 300)
    for objective in ("gaussian", "multimodal", "1modeat0"), constraint in ("ball", "box")
        animation = deepcopy(base_animation)
        animation[:objective] = objective
        animation[:constraint] = constraint
        animation[:nframe] = objective_to_nframe[objective]

        push!(animations, animation)
    end

    save_projected_(animations)
end

################ penalized ################
function save_penalized_(animations::Dict)
    # method specific
    setups = Dict(
        dim => ((par, anim) -> setup(par...; step_size=anim[:step], objective_type=anim[:objective], ϵ=anim[:ϵ])) 
        for (dim, setup) in zip(("2D", "3D"), (setup_penalized_gradient, setup_penalized_gradient3d))
    )

    to_filename(anim) = "$(anim[:method])/$(anim[:objective])_$(anim[:dim])_step$(replace_float2string(anim[:step]))_ϵ$(anim[:ϵ]).mp4"

    foreach(animations) do x
        setup_and_record(x, setups, to_filename)
    end
end

function save_penalized()
    animations = Vector{Any}[]
    base_animation = Dict(
        :method => "penalized",
        :objective => "gaussian",
        :constraint => "ball",
        :dim => "2D",
        :nframe => 1500,
        :xylims => (-5.0, 5.0, -5.0, 5.0),
        :step => 0.01,
        :ϵ => 1.0
    )

    for objective in ("gaussian", "multimodal", "1modeat0"), step in (1e-2, 1e-4), ϵ in (1.0, 0.1)
        animation = deepcopy(base_animation)
        animation[:objective] = objective
        animation[:step] = step
        animation[:ϵ] = ϵ

        push!(animations, animation)
    end

    save_penalized_(animations)
end

################ uzawa ################
function save_uzawa_(animations::Dict)
    # method specific
    setups = Dict(
        dim => ((par, anim) -> setup(par...; step_size=anim[:step], algorithm=anim[:algo], anim[:A], anim[:b])) 
        for (dim, setup) in zip(("2D", "3D"), (setup_primaldual3d, setup_primaldual3d))
    )

    to_filename(anim) = "$(anim[:method])/quadratic_$(anim[:dim])_step$(replace_float2string(anim[:step])).mp4"

    foreach(animations) do x
        setup_and_record(x, setups, to_filename)
    end
end

function save_uzawa()
    A = [1.0 0.05; 0.05 1.0]
    animations = Vector{Any}[]
    base_animation = Dict(
        :method => "uzawa",
        :dim => "3D",
        :nframe => 250,
        :xylims => (-1.0, 2.0, -1.0, 2.0),
        :step => 0.05,
        :algo => "uzawa"
        :A => A,
        :b => A*[1.5, 1.2]
    )

    animation = deepcopy(base_animation)
    push!(animations, animation)

    save_uzawa_(animations)
end

################ step_arrowhurwicz ################
function save_arrowhurwicz_(animations::Dict)
    # method specific
    setups = Dict(
        dim => ((par, anim) -> setup(par...; step_size=anim[:step], algorithm=anim[:algo], anim[:A], anim[:b])) 
        for (dim, setup) in zip(("2D", "3D"), (setup_primaldual3d, setup_primaldual3d))
    )

    to_filename(anim) = "$(anim[:method])/quadratic_$(anim[:dim])_step$(replace_float2string(anim[:step])).mp4"

    foreach(animations) do x
        setup_and_record(x, setups, to_filename)
    end
end

function save_arrowhurwicz()
    A = [1.0 0.05; 0.05 1.0]
    animations = Vector{Any}[]
    base_animation = Dict(
        :method => "arrowhurwicz",
        :dim => "3D",
        :nframe => 150,
        :xylims => (-1.0, 2.0, -1.0, 2.0),
        :step => 0.05,
        :algo => "arrowhurwicz"
        :A => A,
        :b => A*[1.5, 1.2]
    )

    animation = deepcopy(base_animation)
    push!(animations, animation)

    save_arrowhurwicz_(animations)
end

################ augmented lagrangian ################
function save_augmented_lagrangian_(animations::Dict)
    # method specific
    setups = Dict(
        dim => ((par, anim) -> setup(par...; step_size=anim[:step], A=anim[:A], b=anim[:b], B=anim[:B], grad_step=anim[:grad_step], grad_iter=anim[:grad_iter])) 
        for (dim, setup) in zip(("2D", "3D"), (setup_augmented_lagrangian3d, setup_augmented_lagrangian3d))
    )

    to_filename(anim) = "$(anim[:method])/quadratic_$(anim[:dim])_step$(replace_float2string(anim[:step]))_$(anim[:constraint]).mp4"

    foreach(animations) do x
        setup_and_record(x, setups, to_filename)
    end
end

function save_augmented_lagrangian()
    A = [1.0 0.05; 0.05 1.0]
    B = ([1.0 0; 0 1.0], [1.0 0; 0 4.0])
    animations = Vector{Any}[]
    base_animation = Dict(
        :method => "augmented_lagrangian",
        :constraint => "ball"
        :dim => "3D",
        :nframe => 50,
        :xylims => (-1.0, 2.0, -1.0, 2.0),
        :step => 1.0,
        :A => A,
        :b => A*[1.5, 1.2],
        :B => missing,
        :grad_step => 0.001,
        :grad_iter => 200
    )

    constraint_to_B = Dict("ball" => first(B), "ellipsoid" => last(B))
    for constraint in ("ball", "ellipsoid")
        animation = deepcopy(base_animation)
        animation[:constraint] = constraint
        animation[:B] = constraint_to_B[constraint]

        push!(animations, animation)
    end

    save_augmented_lagrangian_(animations)
end

################ else 
function replace_float2string(x)
    replace(string(x), "." => "_")
end