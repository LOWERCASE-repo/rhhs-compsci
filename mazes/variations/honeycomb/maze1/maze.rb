#!/usr/bin/ruby

require 'optparse'

DEFAULT_WIDTH = 10
DEFAULT_HEIGHT = 10
DEFAULT_SEED = rand(0xFFFF_FFFF)
DEFAULT_ANIMATE = false
DEFAULT_DELAY = 0.02

# =======================================================================
# Class HoneycombMaze defines basic behavior to which a honeycomb-maze 
# (i.e., 6-sided maze) should conform. It provides basic initialization 
# and/or construction for the maze class, and provides a method for 
# drawing ASCII mazes. 
#
# Specific "maze-carving" techniques are implemented in subclasses.
# =======================================================================
class HoneycombMaze 
      # +++++++++++++++++++++++++++
      # Configure class variables.
      # +++++++++++++++++++++++++++
      @@N, @@NE, @@SE, @@S, @@SW, @@NW = 1, 2, 4, 8, 16, 32
      @@DXU = { @@N => 0, @@S => 0, @@NE => +1, @@SW => -1, @@SE => 0, @@NW => 0 }
      @@DXD = { @@N => 0, @@S => 0, @@NE => 0, @@SW => 0, @@SE => +1, @@NW => -1 }
      @@DY = { @@N => -1, @@S => +1, @@NE => 0, @@SE => 0, @@SW => 0, @@NW => 0 }
      @@OPPOSITE = { @@N => @@S, @@S => @@N, @@SE => @@NW, @@NW => @@SE, @@SW => @@NE, @@NE => @@SW } 

      def self.N; @@N; end
      def self.S; @@S; end
      def self.NE; @@NE; end
      def self.NW; @@NW; end
      def self.SE; @@SE; end
      def self.SW; @@SW; end
      def self.DXU; @@DXU; end
      def self.DXD; @@DXD; end
      def self.DY; @@DY; end
      def self.OPPOSITE; @@OPPOSITE; end

      # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      # Initialize a new 2D maze with the given width and height.
      #
      # Default seed value will give "random" behavior.
      # User-supplied seed value will give "deterministic behavior.
      # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      def initialize( w=DEFAULT_WIDTH, h=DEFAULT_HEIGHT, s=DEFAULT_SEED )
      	  @width = w
	  @height = h
	  @seed = s

	  srand(@seed)

	  @grid = Array.new(h) { Array.new(w,0) }
      end

      attr_reader :width, :height, :seed

      def draw
      	  puts " _   _"
	  puts "/ \\_/ \\"
      end
end

m = HoneycombMaze.new()
m.draw