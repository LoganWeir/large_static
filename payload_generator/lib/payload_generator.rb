#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'json'
require 'trollop'
require 'rgeo/geo_json'
require 'rgeo'
# For pretty printing, if needed
require 'pry'

require 'bounding_box_testing'

# # Set options outside of ARGV
opts = Trollop::options do
  opt :payload_testing, "Payload Testing", 
  	default: nil, short: 'p', type: String
end


# Payload testing
if opts[:payload_testing]
	
	puts "Generating Bounding Box Intersection JSON"

	# Create file where intersections can be saved
	filename = "output/zoom_" + opts[:payload_testing] + "_payload_testing.json"

	payload_output = open(filename, 'w')

	payload_array = opts[:payload_testing].split(",")

	# Testing layer payload size with bounding boxes
	raw_bboxes = JSON.parse(File.read('bounding_boxes_for_testing.json'))

	# Boxes converted to RGEO and poly/bbox size ratio
	ready_bboxes = bounding_box_builder(raw_bboxes['boxes'], 
		payload_array)

else

	raise ArgumentError, "Please specify zoom levels"

end



# Import all parameters for the generator
seed_parameters = JSON.parse(File.read('seed_parameters.json'))

map_data = []


# Allows for multiple files to be processed
ARGV.each do | item |
	raw_data = JSON.parse(File.read(item))
	for feature in raw_data
		# Set filter target
		filter_target = feature['properties']['FLD_ZONE']
		# Separate with ternary operator
		seed_parameters['filter_parameters'].include?(filter_target) ? \
			next : map_data << feature
	end
end


zoom_hash = seed_parameters['zoom_parameters']


# Setup RGeo factory for handling geographic data
# Uses projection for calculations
# Converts area/distance calculations to meters (75% sure)
factory = RGeo::Geographic.simple_mercator_factory(:srid => 4326)


# # Used for testing
# test_data = map_data[0..500]


# Begin iterating through data
map_data.each.with_index(1) do |item, index|

	# Good for monitoring progress
	puts "Starting item ##{index}! Left to go: #{(map_data.length - index)}"

	# Get Flood Zone for Feature Filtering
	flood_zone = item['properties']['FLD_ZONE']
	sub_type = item['properties']['ZONE_SUBTY']
	complete_fld_type = [flood_zone, sub_type].join(", ")

	# Convert data into RGeo, then proper factory
	rgeo_hash = RGeo::GeoJSON.decode(item['geometry'])
	geo_data_projection = factory.collection([rgeo_hash])


	payload_array.each do |zoom_level|

		for box in ready_bboxes[zoom_level]['boxes']

			zoom_params = zoom_hash[zoom_level]
			polygon = geo_data_projection[0]
			bbox = box['rgeo_box']

			if filter_intersect_test(polygon, bbox, zoom_params, complete_fld_type)
				box['intersections'] << geo_data_projection[0]
			end

		end

	end	

end


payload_output.write(ready_bboxes.to_json) unless payload_output.nil?

payload_output.close unless payload_output.nil?

puts "\a"
