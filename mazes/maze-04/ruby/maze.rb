#!/usr/bin/ruby

require 'optparse'

DEFAULT_WIDTH = 10
DEFAULT_HEIGHT = 10
DEFAULT_SEED = rand(0xFFFF_FFFF)
DEFAULT_ANIMATE = false
DEFAULT_DELAY = 0.01

# ==================================================================
# Class Maze defines basic behavior to which a maze should conform.
# It provides basic initialization/construction for the maze class,
# and provides a method for drawing ASCII mazes.
#
# Specific "maze-carving" techniques are implemented in subclasses.
# ==================================================================
class Maze
	@@N, @@S, @@E, @@W = 1, 2, 4, 8
	@@DX = { @@E => 1, @@W => -1, @@N => 0, @@S => 0 }
	@@DY = { @@E => 0, @@W => 0, @@N => -1, @@S => 1 }
	@@OPPOSITE = { @@E => @@W, @@W => @@E, @@N => @@S, @@S => @@N }

	def self.N; @@N; end
	def self.S; @@S; end
	def self.E; @@E; end
	def self.W; @@W; end
	def self.OPPOSITE; @@OPPOSITE; end

	def initialize( w=DEFAULT_WIDTH, h=DEFAULT_HEIGHT, s=DEFAULT_SEED )
		@width = w
		@height = h
		@seed = s

		srand(@seed)

		@grid = Array.new(h) { Array.new(w,0) }
	end

	attr_reader :width, :height, :seed

	def draw
		#
		# Draw the "top" line
		#
		puts " " + "_" * (@width * 2 - 1)

		#	
		# Draw each of the rows.
		#
		@height.times do |y|
			print "|"
			@width.times do |x|
				# render "bottom" using "S" switch
				print( (@grid[y][x] & @@S != 0) ? " " : "_" )
			
				# render "side" using "E" switch	
				if @grid[y][x] & @@E != 0
					print( ( (@grid[y][x] | @grid[y][x+1]) & @@S != 0 ) ? " " : "_" )
				else
					print "|"
				end
			end
			puts
		end

		#
		# Output maze metadata.
		#
		puts "#{$0} #{@width} #{@height} #{@seed} #{@delay}"
	end
end

# ========================================================================
# Generate a maze using randomized variant of Kruskal's algorithm.
#
# Loosely speaking, the algorithm is implemented as follows:
# 
# (1) Designate the "walls" between cells as edges.
# (2) Randomly selected an edge.
# (3) If the selected edge connects two disjoint trees, join the trees.
# (4) Otherwise, throw that edge away.
# (5) Repeat at Step 2.
# ========================================================================
class Kruskal < Maze

	def initialize( w=DEFAULT_WIDTH, h=DEFAULT_HEIGHT, s=DEFAULT_SEED, a=DEFAULT_ANIMATE, d=DEFAULT_DELAY )
		# 
		# Invoke super-constructor
		#
		super(w,h,s)
		
		#
		# Initialize the sets to the same dimension as the maze.
		# We use Tree objects to represent the sets to be joined.
		#
		@sets = Array.new(height) { Array.new(width) { Tree.new } }
		
		#
		# Build the collection of edges and randomize.
		# Edges are "north" and "west" sides of cell, 
		# if index is greater than 0.
		#
		@edges = []
		@height.times do |y|
			@width.times do |x|
				@edges << [x, y, @@N] if y > 0
				@edges << [x, y, @@W] if x > 0
			end
		end
		@edges = @edges.sort_by{rand}
		
		# 
		# Only prepare the maze beforehand if we are doing "static" (i.e., animate = false) drawing
		#
		@delay = d		
		@animate = a
		if not @animate
			carve_passages
		end
	end

	attr_reader :delay, :animate
	
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	# Method only needs to be overridden if we are animating.
	#
	# If we are drawing the maze statically, defer to the superclass.
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	def draw
		# 
		# Clear the screen.
		#
		print "\e[2J"
		if not @animate
		
			#
			# Move to upper left and defer to superclass.
			#
			print "\e[H"
			super()
			
		else
		
			#
			# Carve the passages and animate as we go.
			#
			carve_passages
		end
	end
	
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
	# Very similar, in terms of implementation, to the draw()
	# method in the superclass, the main difference being that
	# here we will color a cell gray if it remains unconnected.
	# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	def display
	
		#
		# Draw the "top row" of the maze.
		#
		print "\e[H"
		puts " " + "_" * ( @width * 2 - 1)
		
		#
		# Step through the grid/maze, cell-by-cell.
		#
		@grid.each_with_index do |row,y|
			print "|"
				row.each_with_index do |cell,x|
					#
					# Start coloring, if unconnected.
					#
					print "\e[47m" if cell == 0
					print( (cell & @@S != 0) ? " " : "_" )
					
					if cell & @@E != 0
						print( ( (cell | row[x+1]) & @@S != 0 ) ? " ": "_" )
					else
						print "|"
					end
					
					# 
					# Stop coloring, if unconnected.
					#
					print "\e[m" if cell == 0
				end
			puts
		end
	end
	
	# +++++++++++++++++++++++++++++++++++++++++++++++++ 
	# Implement Kruskal's algorithm:
	# 
	# (1) Randomly selected an edge.
	# (2) If the sets are not already connected, then
	# (3) Connect the sets, and
	# (4) Knock down the wall between the sets.
	# (5) Repeat at Step 1.
	# +++++++++++++++++++++++++++++++++++++++++++++++++
	def carve_passages
		until @edges.empty? 
			#
			# Select the next edge, and decide which direction we are going in.
			#
			x, y, direction = @edges.pop
			dx, dy = x + @@DX[direction], y + @@DY[direction]
			
			#
			# Pluck out the corresponding sets.
			#
			set1, set2 = @sets[y][x], @sets[dy][dx]
			
			unless set1.connected?(set2)
				#
				# If we are animating, display the maze and pause.
				#
				if @animate
					display
					sleep(@delay)
				end
				
				#
				# Connect the two sets and "knock down" the wall between them.
				#
				set1.connect(set2)
				@grid[y][x] |= direction
				@grid[dy][dx] |= @@OPPOSITE[direction] 
			end
		end
		
		if @animate
			# 
			# Display the final iteration.
			#
			display
			
			#
			# Output maze metadata.
			#
			puts "#{$0} #{@width} #{@height} #{@seed} #{@delay}"
		end
	end
end

# =============================================================== 
# We will use a tree structure to model the "set" (or "vertex") 
# that is used in Kruskal to build the graph.
# ===============================================================
class Tree
	#
	# Build a new tree object
	#
	def initialize
		@parent = nil
	end

	attr_accessor :parent

	#
	# If we are joined, return the root. Otherwise return self.
	#
	def root
		@parent ? @parent.root : self
	end

	# 
	# Are we connected to this tree?
	#
	def connected?(tree)
		root == tree.root
	end

	#
	# Connect to tree
	#
	def connect(tree)
		tree.root.parent = self
	end
end

# ============================
# Command line code goes here
# ============================
OPTIONS  = {
	:w => DEFAULT_WIDTH,
	:h => DEFAULT_HEIGHT,
	:s => DEFAULT_SEED,
	:a => DEFAULT_ANIMATE,
	:d => DEFAULT_DELAY
}

if __FILE__ == $0
	ARGV.options do |o|
		# parse the command line options
		o.separator ""
		o.on("-w","--width=[value]", Integer, "Width of maze (default: " + DEFAULT_WIDTH.to_s + ")") 		{ |OPTIONS[:w]| }
		o.on("-h","--height=[value]", Integer, "Height of maze (default: " + DEFAULT_HEIGHT.to_s + ")")		{ |OPTIONS[:h]| }
		o.on("-s","--seed=[value]", Integer, "User-defined seed will model deterministic behavior (default: " + DEFAULT_SEED.to_s + ")")	{ |OPTIONS[:s]| }
		o.on("-a","--[no-]animated", true.class, "Animate rendering (default: " + DEFAULT_ANIMATE.to_s + ")")		{ |OPTIONS[:a]| }
		o.on("-d","--delay=[value]", Float, "Animation delay (default: " + DEFAULT_DELAY.to_s + ")")	{ |OPTIONS[:d]| } 
		o.separator ""
		o.parse!

		# sanitize the input from the command line
		good = true
		if OPTIONS[:w] == "" or OPTIONS[:w] == nil 
			good = false
		elsif OPTIONS[:h] == "" or OPTIONS[:h] == nil 
			good = false
		elsif OPTIONS[:s] == "" or OPTIONS[:s] == nil
			good = false
		elsif OPTIONS[:d] == "" or OPTIONS[:d] == nil
			good = false
  		end

		if good
			# build and draw a new maze
			Kruskal.new( w=OPTIONS[:w], h=OPTIONS[:h], s=OPTIONS[:s], a=OPTIONS[:a], d=OPTIONS[:d] ).draw
		else
			puts o
		end
	end
end

