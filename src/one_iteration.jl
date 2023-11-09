function animstep!(f, x, p, n)
    x[] = map(x.val) do y; f(y, p, n.val); end
    n[] = n.val + 1
end

# Δx = step(x, p, n)
function step_linesearch_gradient(x, p, n)
    # dJ(x::Point2)::Point2, J(x::Point2)::Real
    max_step, dJ, J = p
    ∇J = dJ(x)

    optimal_step, _ = golden_section((0.0, max_step), 1e-8, 100) do s
        J(x - s * ∇J)
    end
    x - optimal_step * dJ(x)
end

function step_gradient(x, p, n)
    # dJ(x::Point2)::Point2
    s, dJ = p
    x - s * dJ(x)
end

function step_projgradient(x, p, n)
    s, dJ, proj = p
    proj(x - s * dJ(x))
end

function step_gradient3d(x, p, n)
    # dJ(x::Point2)::Point2
    a, b, c = x
    s, dJ, J = p

    y = Point2(a, b)
    y = y - s * dJ(y)
    Point3(first(y), last(y), J(y))
end

function step_projgradient3d(x, p, n)
    a, b, c = x
    s, dJ, J, proj = p

    y = Point2(a, b)
    y = proj(y - s * dJ(y))
    Point3(first(y), last(y), J(y))
end

function step_uzawa3d!(x, μ, p)
    s, A, b = p

    dx12 = (A .+ 2 .* μ) \ b # primal update
    dx3 = quadratic_form(dx12, A, b)

    dx = Point3(first(dx12), last(dx12), dx3)
    dμ = max(0, μ + s*(sum(abs2, x[1:2]) - 1)) # dual update

    return dx, dμ
end

function step_arrowhurwicz!(x::Point, μ::Real, p)
    s, A, b = p

    dx12 = x[1:2] .- s .*(A*x[1:2] .- b + 2 .* μ.*x[1:2]) # primal update
    dx3 = quadratic_form(dx12, A, b)

    dx = Point3(first(dx12), last(dx12), dx3)
    dμ = max(0, μ + s*(sum(abs2, x[1:2]) - 1)) # dual update

    return dx, dμ
end

function step_augmented_lagrangian!(x::Point, μ::Real, p)
    s, A, b, B, grad_step, grad_iter = p

    dx12 = deepcopy(x[1:2])
    grad = zero(dx12)
    for i in 1:grad_iter
        c = dot(dx12, B, dx12) - 1
        grad .= -1 .* b
        mul!(grad, A, dx12, 1, 1)
        mul!(grad, B, dx12, 2*μ + 2*s*c, 1)
        dx12 .-= grad_step .* grad
    end # primal update

    dx3 = quadratic_form(dx12, A, b)
    dx = Point3(first(dx12), last(dx12), dx3)

    constraint = dot(x[1:2], B, x[1:2]) - 1
    dμ = μ + s*constraint # dual update

    return dx, dμ
end

function step_penalized_gradient(x, p, n)
    s, dJ, dc, c, ϵ = p
    x .- s .* (dJ(x) .+ 2 .* c(x) .* dc(x) ./ ϵ)
end

function step_penalized_gradient3d(x, p, n)
    a, b, c = x
    s, dJ, J, dc, c, ϵ = p

    y = Point2(a, b)
    y = y .- s .* (dJ(y) .+ 2 .* c(y) .* dc(y) ./ ϵ)
    Point3(first(y), last(y), J(y))
end
