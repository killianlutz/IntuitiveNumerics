set_theme!(theme_dark())

const NPOINTS = 40

function setup_and_record(setup_function, parameters, filename)
    nframe = parameters.nframe + 24
    fig, step_forward = setup_function(parameters)

    record(fig, filename, 1:nframe; framerate = 24) do frame
        (frame <= 24) ? display(fig) : step_forward(frame - 24)
    end
end

function setup_and_record(animation::Dict, setups::Dict, to_filename::Function)
    params = (; nframe=animation[:nframe], NPOINTS, xygrid_lims=animation[:xylims])
    filename = to_filename(animation)

    setup_and_record(params, filename) do p
        setups["$(animation[:dim])"](p, animation)
    end
end

################ descent ################
function save_descent_(animations::Union{T, AbstractArray{T}}) where T<:Dict
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

################ linesearch ################
function save_linesearch_(animations::Union{T, AbstractArray{T}}) where T<:Dict
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

################ projected ################
function save_projected_(animations::Union{T, AbstractArray{T}}) where T<:Dict
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

################ penalized ################
function save_penalized_(animations::Union{T, AbstractArray{T}}) where T<:Dict
    # method specific
    setups = Dict(
        dim => ((par, anim) -> setup(par...; step_size=anim[:step], objective_type=anim[:objective], ϵ=anim[:ϵ])) 
        for (dim, setup) in zip(("2D", "3D"), (setup_penalized_gradient, setup_penalized_gradient3d))
    )

    to_filename(anim) = "$(anim[:method])/$(anim[:objective])_$(anim[:dim])_step$(replace_float2string(anim[:step]))_epsilon$(anim[:ϵ]).mp4"

    foreach(animations) do x
        setup_and_record(x, setups, to_filename)
    end
end

################ uzawa ################
function save_uzawa_(animations::Union{T, AbstractArray{T}}) where T<:Dict
    # method specific
    setups = Dict(
        dim => ((par, anim) -> setup(par...; step_size=anim[:step], algorithm=anim[:algo], A=anim[:A], b=anim[:b])) 
        for (dim, setup) in zip(("2D", "3D"), (setup_primaldual3d, setup_primaldual3d))
    )

    to_filename(anim) = "$(anim[:method])/quadratic_$(anim[:dim])_step$(replace_float2string(anim[:step])).mp4"

    foreach(animations) do x
        setup_and_record(x, setups, to_filename)
    end
end

################ arrow hurwicz ################
function save_arrowhurwicz_(animations::Union{T, AbstractArray{T}}) where T<:Dict
    # method specific
    setups = Dict(
        dim => ((par, anim) -> setup(par...; step_size=anim[:step], algorithm=anim[:algo], A=anim[:A], b=anim[:b])) 
        for (dim, setup) in zip(("2D", "3D"), (setup_primaldual3d, setup_primaldual3d))
    )

    to_filename(anim) = "$(anim[:method])/quadratic_$(anim[:dim])_step$(replace_float2string(anim[:step])).mp4"

    foreach(animations) do x
        setup_and_record(x, setups, to_filename)
    end
end

################ augmented lagrangian ################
function save_augmented_lagrangian_(animations::Union{T, AbstractArray{T}}) where T<:Dict
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

################ else 
function replace_float2string(x)
    replace(string(x), "." => "_")
end