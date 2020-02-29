Recursive Back-Tracking Maze
============================
 
This script implements a simple recursive backtracking algorithm to draw simple ASCII mazes:

* Choose a starting point in the grid.
* Randomly choose a wall to "knock down". 
* "Knock down" and carve a path to the adjacent cell, but only if the adjacent cell has NOT yet been visited.
* Once ALL adjacent cells have been visited, back up to the last cell that has uncarved walls and repeat.
* The algorithm terminates when the process has backed up all the way.

Note that this scheme can easily be extended to three dimensions, by assigning values 16 and 32 to "up" and "down" respectively.

The algorithm is a "depth-first" traversal of the grid. The intuition is that the maze is an undirected graph and the algorithm will construct the maze by traversing that graph in depth-first order. It's a straightforward approach, but it requires a stack size proportional to the longest acyclic path through the maze, which in the worst case is the entire maze itself.

A possible "optimization" would be to implement a breadth-first traversal.

Sample Maze
-----------
[![](http://farm6.static.flickr.com/5023/5599940326_80d2183d6b_m.jpg)](http://farm6.static.flickr.com/5023/5599940326_80d2183d6b_m.jpg)