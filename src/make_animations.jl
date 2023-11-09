set_theme!(theme_dark())

const NPOINTS = 40

function setup_and_record(setup_function, parameters, filename)
    nframe = parameters.nframe + 24
    fig, iter = setup_function(parameters)
    record(fig, filename, 1:nframe; framerate = 24) do _
        (i <= 24) ? display(fig) : iter()
    end
end

################ descent ################
function save_descent()
    method = "descent"
    objectives = ["gaussian", "multimodal", "rosenbrock"]
    step_sizes = [0.1, 0.005]
    params = (; nframe=500, xygrid_lims=(-5.0, 5.0, -5.0, 5.0), NPOINTS)

    for objective_type in objectives[begin:end-1], step_size in step_sizes
        step = replace_float2string(step)

        dim = "2D"
        filename = "$(method)_$(objective_type)_$(dim)_step$(step).mp4"
        setup_and_record(params, filename) do p
            setup_gradient(p...; step_size, objective_type)
        end

        dim = "3D"
        filename = "$(method)_$(objective_type)_$(dim)_step$(step).mp4"
        setup_and_record(params, filename) do p
            setup_gradient3d(p...; step_size, objective_type)
        end
    end

    dim = "2D"; objective_type = objectives[end]; step_sizes = [0.004, 0.005]
    params = (; nframe=1500, xygrid_lims=(-5.0, 5.0, -5.0, 5.0), NPOINTS)
    for step_size in step_sizes
        step = replace_float2string(step)
        filename = "$(method)_$(objective_type)_$(dim)_step$(step).mp4"
        setup_and_record(params, filename) do p
            setup_gradient(p...; step_size, objective_type)
        end
    end
    
    params = (; nframe=1500, xygrid_lims=(0.5, 1.5, 0.5, 1.5), NPOINTS)
    filename = "$(method)_$(objective_type)_$(dim)_step0_005_zoom.mp4"
    setup_and_record(params, filename) do p
        setup_gradient(p...; step_size = 0.005, objective_type)
    end

    # dynamic
    dim = "3D"; objective_type = "gaussian"; step_size = 0.05; step = replace_float2string(step_size);
    params = (; nframe=800, xygrid_lims=(-5.0, 5.0, -5.0, 5.0), NPOINTS)
    filename = "$(method)_$(objective_type)_$(dim)_step$(step)_dynamic.mp4"

    nframe = params.nframe + 24
    fig, iter = setup_gradient3d(params...; step_size, objective_type)
    record(fig, filename, 1:nframe; framerate = 24) do frame
        if frame <= 24
            display(fig)
        else
            fig.content[1].azimuth[] = 1.7π + 3.0 * sin(2π * frame / 1000)
            fig.content[1].elevation[] = 0.15 + 1.0 * sin(2π * frame / 800)
            iter()
        end
    end
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