function setup_figure2d(xygrid_lims, npoints, f)
    x1s = range(xygrid_lims[1:2]..., npoints)
    x2s = range(xygrid_lims[3:4]..., npoints)
    zs = [f(Point2(x1, x2)) for x1 in x1s, x2 in x2s]

    # setup observables
    n = Observable(0)
    title = lift(n) do t; L"$t = %$(t)"; end
    x = [Point2(x1, x2) for x1 in x1s, x2 in x2s]
    x = Observable(reshape(x, :))
    color = lift(x) do y; f.(y); end # coloured with function values
    # color = lift(x) do y; norm.(y); end

    # static elements
    bbox_lims = xygrid_lims
    fig = Figure(); ax = Axis(fig[1, 1], xlabel = L"$x$", ylabel = L"$y$", limits = bbox_lims);
    
    # contour plot
    ax = first(fig.content)
    bbox = to_value(ax.limits)
    xs = range(bbox[1:2]..., 50); ys = range(bbox[3:4]..., 50);
    zs = [f(Point2(x, y)) for x in xs, y in ys]
    cmap = ColorSchemes.RGBA.(ColorSchemes.color.(to_colormap(:grays)), 0.7) # transparent colormap
    contourf!(ax, xs, ys, zs, colormap = cmap, linewidth = 2)
    
    # decorations
    colormap = cgrad(:bamako, rev=true)
    Label(fig[1, 1, Top()], title, valign = :center, padding = (0.0, 0.0, 10.0, 0.0))
    scatter!(ax, x, color = color, colormap = colormap, markersize = 8)
    
    obs = (; x, n, title, color) # observables
    return (fig, obs)
end

function setup_figure3d(xygrid_lims, npoints, f)
    x1s = range(xygrid_lims[1:2]..., npoints)
    x2s = range(xygrid_lims[3:4]..., npoints)
    zs = [f(Point2(x1, x2)) for x1 in x1s, x2 in x2s]

    # setup observables
    n = Observable(0)
    title = lift(n) do t; L"$t = %$(t)"; end
    x = [Point3(x1, x2, f(Point2(x1, x2))) for x1 in x1s, x2 in x2s]
    x = Observable(reshape(x, :))
    color = lift(x) do y; f.((yi[1:2] for yi in y)); end
    # color = norm.((xi[1:2] for xi in to_value(x)))
    # color = lift(x) do y; norm.((yi[1:2] for yi in y)); end


    # static elements
    bbox_lims = (xygrid_lims..., extrema(last.(zs))...)
    fig = Figure(); ax = Axis3(fig[1, 1], xlabel = L"$x$", ylabel = L"$y$", zlabel = L"$J(x, y)$", limits = bbox_lims);
    Label(fig[1, 1, Top()], title, valign = :center, padding = (0.0, 0.0, 10.0, 0.0))
    
    cmap = ColorSchemes.RGBA.(ColorSchemes.color.(to_colormap(:grays)), 0.7) # transparent colormap
    surface!(ax, x1s, x2s, zs, colormap = cmap)
    colormap = cgrad(:bamako, rev=true)
    scatter!(ax, x, color = color, colormap = colormap, markersize = 8)
    ax.elevation = 0.05 * π
    ax.azimuth = -0.4 * π
    hidedecorations!(ax)
    
    obs = (; x, n, title, color) # observables
    return (fig, obs)
end


function setup_figure3d_primaldual(xygrid_lims, npoints, f; x_min = nothing, μ0 = [0.0 1.0; 3.0 5.0], colorrange = (0.0, 1.0), colorbar_labels = [L"\textrm{min.}", L"\textrm{max.}"], ellipsoid_axes = [1.0, 1.0])
    x1s = range(xygrid_lims[1:2]..., npoints)
    x2s = range(xygrid_lims[3:4]..., npoints)
    zs = [f(Point2(x1, x2)) for x1 in x1s, x2 in x2s]
    N = length(zs)

    # setup observables
    n = Observable(0)
    x = [Observable(
        reshape(
            [Point3(x1, x2, f(Point2(x1, x2))) for x1 in x1s, x2 in x2s], :)
        ) for _ in 1:2, _ in 1:2]
    μ = Matrix{Any}(nothing, 2, 2)
    for i in 1:2, j in 1:2
        μ[i, j] = μ0[i, j]*ones(N)
    end
    μ = Observable.(μ) # color is multiplier strength
    title_counter = lift(n) do t; L"t = %$(t)"; end

    # static elements
    bbox_lims = (xygrid_lims..., extrema(last.(zs))...)
    cmap = ColorSchemes.RGBA.(ColorSchemes.color.(to_colormap(:grays)), 0.7) # transparent colormap
    colormap = cgrad(:bamako, rev = false)
    multiplier_titles = [L"μ_0 = %$(first(to_value(mu)))" for mu in μ]

    fig = Figure()
    axes = [Axis3(fig[i, j], limits = bbox_lims) for i in 2:3, j in 1:2]
    Label(fig[1, 1], title_counter, valign = :center, tellwidth = false)
    Label(fig[1, 2][1, 1], L"μ", valign = :center, halign = :right, tellwidth = false)
    Colorbar(fig[1, 2][1, 2], 
        colorrange = colorrange, 
        ticks = [colorrange...], 
        tickformat = values -> [(val == first(colorrange)) ? first(colorbar_labels) : last(colorbar_labels) for val in values],
        colormap = colormap, 
        vertical = :false, 
        tellwidth = false
    )

    for i in 1:2, j in 1:2
        Label(fig[i + 1, j, Top()], multiplier_titles[i, j], valign = :center)
        surface!(axes[i, j], x1s, x2s, zs, colormap = cmap)
        scatter!(axes[i, j], x[i, j], color = μ[i, j], colormap = colormap, markersize = 8)
        axes[i, j].elevation = 0.3 * π
        axes[i, j].azimuth = -0.4 * π
        hidedecorations!(axes[i, j])
    end
    
    # constraint 
    center = Point3(0.0, 0.0, 0.0)
    radius = 1.0
    # plot of admissible set boundary
    nθ = Int( round(50*radius) )
    θs = range(0, 2π - 1e-6, nθ)
    a1, a2 = ellipsoid_axes
    boundary = [center .+ Point3(cos(θ)*radius/a1, sin(θ)*radius/a2, f(Point2(cos(θ)*radius/a1, sin(θ)*radius/a2))) for θ in θs]
    foreach(axes) do ax
        scatter!(ax, x_min, marker=:cross, markersize=10, color=:orange)
        lines!(ax, boundary, linewidth=5, linestyle=:solid, color=:red, alpha=0.85)
    end

    obs = (; x, μ, n, title_counter) # observables
    return (fig, obs)
end

function setup_constraint!(figure, constraint_type="ball")
    axis = figure.content[1, 1]
    if constraint_type == "ball"
        center = Point2(-1.0, -0.2)
        radius = 3.0
        # projection onto admissible set
        ball_projector(x) = begin 
            distance = norm(x - center)
            (distance <= radius) ? x : center + radius*(x - center)/distance
        end
        # plot of admissible set boundary
        nθ = Int( round(30*radius) )
        θs = range(0, 2π - 1e-6, nθ)
        boundary = [ center .+ radius.*Point2(cos(θ), sin(θ)) for θ in θs]
        
        scatter!(axis, center, marker=:cross, markersize=15, color=:red)
        admset_boundary = lines!(axis, boundary, linewidth=3, linestyle=:dashdot, color=:red, alpha=0.75)
        Legend(figure[1, 1, TopLeft()], [admset_boundary], [L"∂(\text{Adm.})"], labelsize=15, orientation=:vertical)

        return ball_projector

    elseif constraint_type == "box"
        x1_right = -0.5
        x2_top = -1.0
        # projection onto admissible set
        quarterplane_projector(x) = begin 
            x1, x2 = x
            if (x1 <= x1_right) && (x2 > x2_top)
                return Point2(x1, x2_top)
            elseif (x2 <= x2_top) & (x1 > x1_right)
                return Point2(x1_right, x2)
            elseif (x1 > x1_right) & (x2 > x2_top)
                return Point2(x1_right, x2_top)
            else 
                return x
            end
        end
        # plot of admissible set boundary
        left, right, bot, top = axis.limits |> to_value
        horizontal_boundary = [Point2(x1, x2_top) for x1 in range(left, min(x1_right, right), 50)]
        vertical_boundary = [Point2(x1_right, x2) for x2 in range(bot, min(x2_top, top), 50)]

        lines!(axis, horizontal_boundary, linewidth=3, linestyle=:dashdot, color=:red, alpha=0.75)
        admset_boundary = lines!(axis, vertical_boundary, linewidth=3, linestyle=:dashdot, color=:red, alpha=0.75)
        Legend(figure[1, 1, TopLeft()], [admset_boundary], [L"∂(\text{Adm.})"], labelsize=15, orientation=:vertical)

        return quarterplane_projector
    end
end