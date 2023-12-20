# IntuitiveOptimization

## Goal: an intuitive understanding of numerical optimization techniques
This project gathers various animations which illustrate the principles and limitations of some classical numerical methods for optimization. See the `animations/` folder. 

https://github.com/killianlutz/IntuitiveOptimization/assets/152091888/50036378-13d0-4b13-9c9c-da0e7c7551df

### Animation philosophy
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
The code in the `src/` folder is written in `Julia` and builds upon the plotting library [GLMakie](https://docs.makie.org/stable/). All animations may be reproduced by executing the script `save_animations.jl` found in the `scripts/` folder.

## For whom were those animations designed?
Anyone interested in numerical analysis or scientific computing might find interest in those simulations, especially -but not only- undergraduate students who might feel underwhelmed by the underlying methods.

## Outlooks
Next methods to be implemented include:
* Nesterov accelerated gradient descent,
* Stochastic Adam optimizer,
* Proximal methods.

## Last words
The source code is mainly provided for reproducibility purposes and the user's convenience. Any suggestions are more than welcome.

If you enjoy those animations, I would be grateful if you could refer to this [repository](https://github.com/killianlutz/IntuitiveOptimization) or its author [Killian Lutz](https://github.com/killianlutz).

Thank you for your time and enjoy!
