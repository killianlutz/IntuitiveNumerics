################ descent ################
function save_descent()
    animations = Dict{Symbol, Any}[]
    base_animation = Dict(
        :method => "descent",
        :objective => "gaussian",
        :constraint => missing,
        :dim => "2D",
        :nframe => 1500,
        :xylims => (-5.0, 5.0, -5.0, 5.0),
        :step => 0.01,
        :dynamic => missing,
        :zoom => missing
    )

    objective_to_step = Dict("gaussian" => 0.01, "multimodal" => 0.0001)
    for objective in ("gaussian", "multimodal"), dim in ("2D", "3D")
        animation = deepcopy(base_animation)
        animation[:objective] = objective
        animation[:step] = objective_to_step[objective]
        animation[:dim] = dim

        push!(animations, animation)
    end

    for step in (0.004, 0.005)
        animation = deepcopy(base_animation)
        animation[:objective] = "rosenbrock"
        animation[:xylims] = (-1.5, 1.5, -1.5, 1.5)
        animation[:step] = step

        push!(animations, animation)
    end

    animation = deepcopy(base_animation)
    animation[:objective] = "rosenbrock"
    animation[:xylims] = (0.5, 1.5, 0.5, 1.5)
    animation[:step] = 0.005
    animation[:zoom] = true

    push!(animations, animation)

    save_descent_(animations)
end

################ linesearch ################
function save_linesearch()
    animations = Dict{Symbol, Any}[]
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
function save_projected()
    animations = Dict{Symbol, Any}[]
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
function save_penalized()
    animations = Dict{Symbol, Any}[]
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

    epsilon_to_step = Dict(
        "gaussian" => Dict(1.0 => 3e-2, 0.1 => 1e-5),
        "multimodal" => Dict(1.0 => 1e-2, 0.1 => 1e-4),
        "1modeat0" => Dict(1.0 => 1e-2, 0.1 => 1e-5)
    )
    for objective in ("gaussian", "multimodal", "1modeat0"), ϵ in (1.0, 0.1), dim in ("2D", "3D")
        animation = deepcopy(base_animation)
        animation[:objective] = objective
        animation[:dim] = dim
        animation[:step] = epsilon_to_step[objective][ϵ]
        animation[:ϵ] = ϵ

        push!(animations, animation)
    end

    save_penalized_(animations)
end

################ uzawa ################
function save_uzawa()
    A = [1.0 0.05; 0.05 1.0]
    animations = Dict{Symbol, Any}[]
    base_animation = Dict(
        :method => "uzawa",
        :dim => "3D",
        :nframe => 250,
        :xylims => (-1.0, 2.0, -1.0, 2.0),
        :step => 0.05,
        :algo => "uzawa",
        :A => A,
        :b => A*[1.5, 1.2]
    )

    animation = deepcopy(base_animation)
    push!(animations, animation)

    save_uzawa_(animations)
end

################ step_arrowhurwicz ################
function save_arrowhurwicz()
    A = [1.0 0.05; 0.05 1.0]
    animations = Dict{Symbol, Any}[]
    base_animation = Dict(
        :method => "arrowhurwicz",
        :dim => "3D",
        :nframe => 150,
        :xylims => (-1.0, 2.0, -1.0, 2.0),
        :step => 0.05,
        :algo => "arrowhurwicz",
        :A => A,
        :b => A*[1.5, 1.2]
    )

    animation = deepcopy(base_animation)
    push!(animations, animation)

    save_arrowhurwicz_(animations)
end

################ augmented lagrangian ################
function save_augmented_lagrangian()
    A = [1.0 0.05; 0.05 1.0]
    B = ([1.0 0; 0 1.0], [1.0 0; 0 4.0])
    animations = Dict{Symbol, Any}[]
    base_animation = Dict(
        :method => "augmented_lagrangian",
        :constraint => "ball",
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