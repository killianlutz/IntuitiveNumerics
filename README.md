# IntuitiveNumerics.jl

## One purpose: providing an intuitive understanding of classical numerical methods
This project gathers various animations which illustrate the principles and limitations of some classical numerical methods for optimization. See the `animations/` folder.

### Main idea
Most animations involve iterative algorithms for optimization and showcase the simultaneous evolutions of a bunch of starting points. These are shown on the graph of the objective function as if they were conservative physical systems seeking to reach equilibrium by minimizing their potential energy (objective function).

### Currently available numerical methods
To this day
1. Gradient descent:
    * Constant step size,
    * Line-search for optimal step size,
    * Projected,
    * Penalized.
2. Primal-dual methods:
    * Uzawa,
    * Arrow-Hurwicz,
    * Augmented Lagrangian.

Supported constraints for now include ellipsoïds and unbounded boxes in the euclidean plane.

### Source code
The code in the `src/` folder is written in `Julia` and builds upon the plotting library [https://docs.makie.org/stable/](GLMakie). All animations may be reproduced by executing the script `save_animations.jl` found in the `scripts/` folder.

## For whom were those animations designed?
Anyone interested in numerical analysis or scientific computing might find interest in those simulations, especially -but not only- undergraduate students who might feel underwhelmed by the underlying methods.

## Outlooks
Next methods to be implemented include:
* Nesterov accelerated gradient descent,
* Stochastic Adam optimizer,
* Proximal methods.

## Last words
The source code is mainly provided for reproducibility purposes and the user's convenience. Any suggestions are more than welcome.

If you enjoy those animations, please do not hesitate to refer to this [https://github.com/killianlutz/IntuitiveNumerics.jl](repository) or its author [https://github.com/killianlutz](Killian Lutz).






A README is often the first item a visitor will see when visiting your repository. README files typically include information on:

    What the project does
    Why the project is useful
    How users can get started with the project
    Where users can get help with your project
    Who maintains and contributes to the project
