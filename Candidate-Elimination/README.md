<h1 align='center'>
  Candidate Elimination
</h1>

This program was written to solve this given problem.

Consider the instance space of a Euclidean 2D plane. Let us suppose that the hypotheses are represented
by a circle formalized as $`[(a,b),r]`$, where $`(a,b,)`$ is the circle's center point, $r$ is the radius of
the circle and $`a,b\in\{ -5,-4,\cdots,0,\cdots,4,5\}`$ and $`r\in\{1,2,\cdots,10\}`$. The hypothesis
is negative. Suppose our data set consists of the following. Positive points: $`(0,0),(1,0),(\frac{1}{2},-\frac{1}{2})`$;
Negative points: $`(2,3),(4,-1),(-3,1)`$. List all the maximally specific hypotheses and all the maximally general
hypotheses in the version space.

### Usage
```bash
julia CEA.jl
```
