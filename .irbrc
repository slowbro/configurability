#!/usr/bin/ruby -*- ruby -*-

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.expand_path
	libdir = basedir + "lib"

	puts ">>> Adding #{libdir} to load path..."
	$LOAD_PATH.unshift( libdir.to_s )
}

# Set some ANSI escape code constants (Shamelessly stolen from Perl's
# Term::ANSIColor by Russ Allbery <rra@stanford.edu> and Zenin <zenin@best.com>
ANSI_ATTRIBUTES = {
	'clear'      => 0,
	'reset'      => 0,
	'bold'       => 1,
	'dark'       => 2,
	'underline'  => 4,
	'underscore' => 4,
	'blink'      => 5,
	'reverse'    => 7,
	'concealed'  => 8,

	'black'      => 30,   'on_black'   => 40, 
	'red'        => 31,   'on_red'     => 41, 
	'green'      => 32,   'on_green'   => 42, 
	'yellow'     => 33,   'on_yellow'  => 43, 
	'blue'       => 34,   'on_blue'    => 44, 
	'magenta'    => 35,   'on_magenta' => 45, 
	'cyan'       => 36,   'on_cyan'    => 46, 
	'white'      => 37,   'on_white'   => 47
}

### Create a string that contains the ANSI codes specified and return it
def ansi_code( *attributes )
	attributes.flatten!
	attributes.collect! {|at| at.to_s }
	# $stderr.puts "Returning ansicode for TERM = %p: %p" %
	# 	[ ENV['TERM'], attributes ]
	return '' unless /(?:vt10[03]|xterm(?:-color)?|linux|screen)/i =~ ENV['TERM']
	attributes = ANSI_ATTRIBUTES.values_at( *attributes ).compact.join(';')

	# $stderr.puts "  attr is: %p" % [attributes]
	if attributes.empty? 
		return ''
	else
		return "\e[%sm" % attributes
	end
end


### Colorize the given +string+ with the specified +attributes+ and return it, handling 
### line-endings, color reset, etc.
def colorize( *args )
	string = ''

	if block_given?
		string = yield
	else
		string = args.shift
	end

	ending = string[/(\s)$/] || ''
	string = string.rstrip

	return ansi_code( args.flatten ) + string + ansi_code( 'reset' ) + ending
end


begin
	$stderr.puts "Loading configurability..."
	require 'configurability'
rescue => e
	$stderr.puts "Ack! Configurability library failed to load: #{e.message}\n\t" +
		e.backtrace.join( "\n\t" )
end

