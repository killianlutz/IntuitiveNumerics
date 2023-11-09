function golden_section(f::Function, interval::NTuple{2,<:Real}, abstol::Real, max_iterations::Integer; reference_value::Real = Inf)
    a, b = interval
    γ = oftype(a, (1 + sqrt(5)) / 2) # golden number

    c = b - (γ - 1) * (b - a)
    d = a + (γ - 1) * (b - a)
    left_value = f(c)
    right_value = f(d)

    count = 1
    while (count <= max_iterations) && (b - a > abstol)
        if left_value <= right_value
            b = d; d = c;
            c = b - (γ - 1) * (b - a)
            # only 1 evaluation of f instead of 2
            right_value = left_value
            left_value = f(c)
        elseif left_value > right_value
            a = c; c = d;
            d = a + (γ - 1) * (b - a)

            left_value = right_value
            right_value = f(d)
        end
        count += 1
    end

    # estimated minimizer 
    midpoint = (a + b) / 2
    midpoint_value = f(midpoint)
    if reference_value > midpoint_value
        # println("GS ----- steps: $(count) // minimizer estimate: $(midpoint) // Δf = $(reference_value-midpoint_value)")
        return (midpoint, midpoint_value)
    elseif reference_value <= midpoint_value
        # The line search failed to reduce the reference_value of f
        # println("GS FAILED ----- steps: $(count) // last estimate: $(midpoint)")
        return (eps(a), f(eps(a)))
    end
end