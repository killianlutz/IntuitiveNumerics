function setup_gradient(nframe, npoints, xygrid_lims; step_size = 0.5, objective_type = "gaussian")
    J, dJ = get_objective(objective_type)
    fig, obs = setup_figure2d(xygrid_lims, npoints, J)
    
    return fig, frame -> animstep!(step_gradient, obs.x, (step_size, dJ), obs.n)
end

function setup_projgradient(nframe, npoints, xygrid_lims; step_size = 0.5, objective_type = "gaussian", constraint_type = "ball")
    J, dJ = get_objective(objective_type)
    fig, obs = setup_figure2d(xygrid_lims, npoints, J)
    projector = setup_constraint!(fig, constraint_type)
    
    return fig, frame -> animstep!(step_projgradient, obs.x, (step_size, dJ, projector), obs.n)
end

function setup_linesearch_gradient(nframe, npoints, xygrid_lims; step_size = 0.5, objective_type = "gaussian")
    J, dJ = get_objective(objective_type) 
    fig, obs = setup_figure2d(xygrid_lims, npoints, J)
    
    return fig, frame -> animstep!(step_linesearch_gradient, obs.x, (step_size, dJ, J), obs.n)
end

function setup_penalized_gradient(nframe, npoints, xygrid_lims; step_size = 0.5, objective_type = "gaussian", constraint_type = "ball", ϵ = 1e-3)
    J, dJ = get_objective(objective_type) 
    fig, obs = setup_figure2d(xygrid_lims, npoints, J)
    setup_constraint!(fig, constraint_type)

    center = Point2(-1.0, -0.2)
    radius = 3.0
    c(x) = sum(abs2, x - center) - radius^2
    dc(x) = 2 .* (x .- center)
    
    return fig, frame -> animstep!(step_penalized_gradient, obs.x, (step_size, dJ, dc, c, ϵ), obs.n)
end

function setup_gradient3d(nframe, npoints, xygrid_lims; step_size = 0.5, objective_type = "gaussian")
    J, dJ = get_objective(objective_type) 
    fig, obs = setup_figure3d(xygrid_lims, npoints, J)
    
    return fig, frame -> animstep!(step_gradient3d, obs.x, (step_size, dJ, J), obs.n)
end

function setup_primaldual3d(nframe, npoints, xygrid_lims; step_size = 0.5, algorithm = "uzawa", A = [3.0 1.0; 1.0 3.0], b = A*[1.5, 1.2])
    x_min = A \ b; x_min = Point3(x_min..., quadratic_form(x_min, A, b))
    fig, obs = setup_figure3d_primaldual(xygrid_lims, npoints, x -> quadratic_form(x, A, b); x_min)

    algorithm == "uzawa" ? forward = step_uzawa3d! : forward = step_arrowhurwicz!
    p = (step_size, A, b)

    on(obs.n) do _
        # step n + 1
        for (xij, μij) in zip(obs.x, obs.μ)
            # update observables of axis (i + 1, j) of the figure
            dx = similar(to_value(xij))
            dμ = similar(to_value(μij))
            @threads for k in eachindex(to_value(xij))
                dx[k], dμ[k] = forward(to_value(xij)[k], to_value(μij)[k], p)
            end

            xij[] = dx
            μij[] = dμ
        end
    end

    iter_animation = frame -> begin
        obs.n[] = to_value(obs.n) + 1
    end

    return fig, iter_animation
end

function setup_augmented_lagrangian3d(nframe, npoints, xygrid_lims; step_size = 0.5, A = [3.0 1.0; 1.0 3.0], b = A*[1.5, 1.2], B = [4.0 0; 0 1.0], grad_step = 0.005, grad_iter = 200)
    x_min = A \ b; x_min = Point3(x_min..., quadratic_form(x_min, A, b))
    fig, obs = setup_figure3d_primaldual(
        xygrid_lims, 
        npoints,
        x -> quadratic_form(x, A, b); 
        x_min, 
        μ0 = [-10.0 0.0; 5.0 10.0], 
        colorrange = (-1.0, 1.0), 
        colorbar_labels = [L"\textrm{min. } <0", L"\textrm{max. }>0"],
        ellipsoid_axes = diag(B)
    )
    p = (step_size, A, b, B, grad_step, grad_iter)

    on(obs.n) do _
        # step n + 1
        for (xij, μij) in zip(obs.x, obs.μ)
            # update observables of axis (i + 1, j) of the figure
            dx = similar(to_value(xij))
            dμ = similar(to_value(μij))
            @threads for k in eachindex(to_value(xij))
                dx[k], dμ[k] = step_augmented_lagrangian!(to_value(xij)[k], to_value(μij)[k], p)
            end

            xij[] = dx
            μij[] = dμ
        end
    end

    iter_animation = frame -> begin
        obs.n[] = to_value(obs.n) + 1
    end

    return fig, iter_animation
end

function setup_penalized_gradient3d(nframe, npoints, xygrid_lims; step_size = 0.5, objective_type = "gaussian", constraint_type = "ball", ϵ = 1e-3)
    J, dJ = get_objective(objective_type) 
    fig, obs = setup_figure3d(xygrid_lims, npoints, J)
    setup_constraint!(fig, constraint_type)

    center = Point2(-1.0, -0.2)
    radius = 3.0
    c(x) = sum(abs2, x - center) - radius^2
    dc(x) = 2 .* (x .- center)
    
    return fig, frame -> animstep!(step_penalized_gradient3d, obs.x, (step_size, dJ, J, dc, c, ϵ), obs.n)
end
