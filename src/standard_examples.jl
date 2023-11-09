function gaussian(x, x0, α, var)
    - α * exp(- 0.5 / var * sum(abs2, x - x0))
end
function dgaussian(x, x0, α, var)
    Point2(- gaussian(x, x0, α, var) * first(x - x0) / var, - gaussian(x, x0, α, var) * last(x - x0) / var)
end
function quadratic_form(x, A, b)
    0.5*dot(x, A, x) - dot(b, x)
end
function ellipsoid_constraint(x, B, r)
    dot(x, B, x) - r^2
end

function get_objective(type::AbstractString)
    if type == "gaussian"
        σ = 1.0  # standard deviation
        x_min = [Point2(1.5, 0.7), Point2(-0.7, -2.0)] # minimizer locations
        # objective function
        g(x) = gaussian(x, first(x_min), 2.0, σ^2) + gaussian(x, last(x_min), 1.0, 2 * σ^2)
        dg(x) = dgaussian(x, first(x_min), 2.0, σ^2) + dgaussian(x, last(x_min), 1.0, 2 * σ^2)
        
        return g, dg
    elseif type == "rosenbrock"
        b = 50
        r(x) = (1 - first(x))^2 + b * (last(x) - first(x)^2)^2
        dr(x) = Point2(- 2 * (1 - first(x)) - 4 * b * (last(x) - first(x)^2) * first(x), 
                    2 * b * (last(x) - first(x)^2))
        
        return r, dr
    elseif type == "multimodal"
        m(x) = (first(x)^2 + last(x) - 11)^2 + (first(x) + last(x)^2 - 7)^2
        dm(x) = Point2(2 * (first(x)^2 + last(x) - 11) * 2 * first(x) + 2 * (first(x) + last(x)^2 - 7),
                    2 * (first(x)^2 + last(x) - 11) + 2 * (first(x) + last(x)^2 - 7) * 2 * last(x))
        
        return m, dm
    elseif type == "1modeat0"
        q(x) = sum(abs2, x) - first(x)*last(x)
        dq(x) = Point2(2*first(x) - last(x), 2*last(x) - first(x))

        return q, dq
    end
end