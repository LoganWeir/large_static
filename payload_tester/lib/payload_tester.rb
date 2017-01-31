#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'json'
require 'trollop'
require 'rgeo/geo_json'
require 'rgeo'
# For pretty printing, if needed
require 'pry'


require 'bounding_box_testing'
require 'test_builder'
require 'single_test'


# !OPTIONS FOR EXECUTION
# single - payload size test for each bounding box/poly set with parameters
# trim - after initial test, trim payload to size set in function argument
# layer - build test layer from final payload. zoom level and box set in function argument


# TO ADD LATER
# small - create a layer of the largest polygons beneath the size threshold





# Set options outside of ARGV
opts = Trollop::options do
  opt :trim, "Trim to Size", default: nil,
  	short: 't', type: String
  opt :layer, "Generate Layer", default: nil,
  	short: 'l', type: String
end

if ARGV.length == 0

	raise ArgumentError, "Please include test payload(s)"

else

	# Get bounding boxes and their intersecting polygons
	raw_payloads = JSON.parse(File.read(ARGV[0]))

end

# Get Parameters
seed_parameters = JSON.parse(File.read('seed_parameters.json'))
zoom_parameters = seed_parameters['zoom_parameters']














# if opts[:execution] == "single_test"

# 	puts "Executing Single Test"

# elsif opts[:execution] == "single_test_layer"

# 	puts "Executing Single Test, Building Layer"

# elsif opts[:execution] == "single_test_layer"

# 	puts "Executing Single Test, Building Layer"

# elsif opts[:execution] == "single_test_layer"

# 	puts "Executing Single Test, Building Layer"

# else

# 	raise ArgumentError, "Please specify execution"

# end



  # opt :parameter_output, "Parameter Output", default: nil, 
  # 	short: 'p', type: String
  # opt :layer_output, "Layer Output", default: nil,
  # 	short: 'l', type: String

# # Only produce output file if asked for it
# if opts[:parameter_output].nil? && opts[:layer_output].nil?

# 	output = nil

# elsif opts[:layer_output].nil?

# 	path_file = 'output/' + opts[:parameter_output]
# 	output = open(path_file, 'w')

# elsif opts[:parameter_output].nil?

# 	path_file = 'output/' + opts[:layer_output]
# 	output = open(path_file, 'w')

# else

# 	puts "Output unclear"

# end




# # Get bounding boxes and their intersecting polygons
# zoom_bboxes_intersections = JSON.parse(File.read(ARGV[0]))

# # Get the simpliciation parameters
# seed_parameters = JSON.parse(File.read('seed_parameters.json'))
# zoom_parameters = seed_parameters['zoom_parameters']


# # Setup RGeo factory for handling geographic data
# # Uses projection for calculations
# # Converts area/distance calculations to meters (75% sure)
# factory = RGeo::Geographic.simple_mercator_factory(:srid => 4326)


# # Preparing Hash for Testing
# puts "Building Testing Hash"
# puts ""

# testing_hash = {}


# # For each zoom level tested
# for zoom_level, zoom_value in zoom_bboxes_intersections

# 	testing_hash[zoom_level] = {}

# 	# Gather Bounding Box Meta Data
# 	testing_hash[zoom_level]['settings'] = zoom_parameters[zoom_level]
# 	testing_hash[zoom_level]['average_box_area'] = zoom_value['average_area']

# 	# Zoom Parameters
# 	zoom_params = zoom_parameters[zoom_level]

# 	#Get simplifaction reduction percentage 
# 	simplification = zoom_params['simplification']

# 	# Create array of hashes, where each hash is a bound box and polygons
# 	testing_hash[zoom_level]['boxes'] = []

# 	for box in zoom_value['boxes']

# 		box_hash = {}

# 		# Convert Bounding Box to RGEO
# 		bounding_box = factory.parse_wkt(box['rgeo_box'])
# 		box_hash['bbox'] = factory.parse_wkt(box['rgeo_box'])

# 		# Get BBox Area for Polygon Rating
# 		bbox_area = bounding_box.area

# 		# Ratio of BBox Size to Minimum Polygon Size
# 		min_poly_bbox_ratio = zoom_params['minimum_poly_bbox_ratio']

# 		# Minimum Polygon Size, Regardless of Fill
# 		min_poly_size = bbox_area * min_poly_bbox_ratio

# 		# Where polygons will get stored
# 		box_hash['polygons'] = []

# 		# Iterate though polygons
# 		# Filter and Simplify on first iteration
# 		for polygon in box['intersections']

# 			# Format polygon
# 			rgeo_poly = factory.parse_wkt(polygon)

# 			# Establish polygon area
# 			poly_area = rgeo_poly.area

# 			# Filter out polygons that are too small
# 			next if rgeo_poly.area <= min_poly_size

# 			# Filter out holes in polygons that are too small
# 			hole_filtered_poly = hole_filtering(min_poly_size, rgeo_poly, factory)

# 			# Add simplification here
# 			simplied_polygons = polygon_simplifier(hole_filtered_poly, 
# 				simplification, min_poly_size)

# 			for simple_polygon in simplied_polygons

# 				if simple_polygon.area > min_poly_size

# 					# Grab Polygon
# 					box_hash['polygons'] << simple_polygon

# 				end

# 			end

# 		end

# 		testing_hash[zoom_level]['boxes'] << box_hash

# 	end

# end


# # Jump back into array, get the length of each payload
# for zoom_level, zoom_value in testing_hash

# 	puts "Zoom Level: #{zoom_level}\n"

# 	for bbox_test in zoom_value['boxes']

# 		polygons = bbox_test['polygons']

# 		bbox = bbox_test['bbox']

# 		payload_length = polychop_lentest(polygons, bbox)

# 		puts "Payload Size: #{payload_length}"

# 	end

# end







# # Create file if asked to
# unless output == nil

# 	if opts[:layer_output].nil?

# 		output.write(size_parameters.to_json)
# 		output.close

# 	elsif opts[:testing_output].nil?

# 		# REQUIRES ARRAY OF POLYGONS EXTRACTED FROM TESTING HASH
# 		target_polygons = testing_hash['9']['boxes'][0]['polygons']

# 		# Build a Map Layer for Testing
# 		final_output = {}

# 		test_layer_build = layer_builder("Test Layer")

# 		final_output['layer_data'] = test_layer_build[0]

# 		layer_id = test_layer_build[1]

# 		feature_array = []

# 		length_test = []

# 		for polygon in target_polygons

# 				poly_params = {}
# 				poly_params['id'] = layer_id
# 				poly_params['title'] = "TEST MOTHER FUCKER"
# 				poly_params['description'] = "DID YOU NOT HEAR ME?"
# 				poly_params['color'] = "#de2d26"
# 				poly_params['zoom'] = 9

# 				feature_array << feature_builder(poly_params, factory.collection([polygon]))

# 		end

# 		final_output['feature_data'] = feature_array

# 		output.write(final_output.to_json)
# 		output.close

# 	else

# 		puts "Output unclear"

# 	end

# end



# puts "\a"
# puts "\a"
# puts "\a"








# RATINGS CRAP

# 		# Where polygons will get stored
# 		box_hash['polygon_rating'] = []

# 		# Where ratings will get stored
# 		size_fill_unsorted = [] 

# 		# Iterate though polygons
# 		# Filter and Simplify on first iteration
# 		for polygon in box['intersections']

# 			# Format polygon
# 			rgeo_poly = factory.parse_wkt(polygon)

# 			# Establish polygon area
# 			poly_area = rgeo_poly.area

# 			# Filter out polygons that are too small
# 			next if rgeo_poly.area <= min_poly_size

# 			# Filter out holes in polygons that are too small
# 			hole_filtered_poly = hole_filtering(min_poly_size, rgeo_poly, factory)

# 			# Add simplification here
# 			simplied_polygons = polygon_simplifier(hole_filtered_poly, 
# 				simplification, min_poly_size)

# 			for simple_polygon in simplied_polygons

# 				poly_hash = {}

# 				# Get ratings for simplified polygons
# 				envelope_area = simple_polygon.envelope.area
# 				rating = fill_size_rating(simple_polygon.area, bbox_area, envelope_area)

# 				# Grab Rating
# 				poly_hash['rating'] = rating

# 				# Grab Polygon
# 				poly_hash['polygon'] = simple_polygon

# 				box_hash['polygon_rating'] << poly_hash

# 				size_fill_unsorted << rating

# 			end

# 		end

# 		box_hash['ratings'] = size_fill_unsorted.sort

# 		testing_hash[zoom_level]['boxes'] << box_hash

# 	end

# end



# # Jump back into array, starting trimming by rating
# for zoom_level, zoom_value in testing_hash

# 	for bbox_test in zoom_value['boxes']

# 		bbox = bbox_test['bbox']

# 		polygons_ratings = bbox_test['polygon_rating']

# 		ratings = bbox_test['ratings']

# 		unsimp_payload_size = polychop_lentest(bbox_test['unsimplified'], bbox)

# 		payload_size = poly_rating_test(polygons_ratings, 0, bbox)

# 		# Remember, simplification ratio target is .025
# 		ratio = payload_size/unsimp_payload_size

# # 		# # USED FOR DOING RATIOS
# # 		# reduction = 0

# # 		# while ratio > 0.026

# # 		# 	reduction += 1

# # 		# 	rating_limit = ratings[reduction]

# # 		# 	puts ">>>>>>>>>>"

# # 		# 	puts "Attempt: #{reduction}"
# # 		# 	puts "Rating Threshold: #{rating_limit}"

# # 		# 	puts "Percent removed: #{(reduction).to_f/(ratings.length).to_f}"

# # 		# 	payload_size = poly_rating_test(polygons_ratings, rating_limit, bbox)

# # 		# 	ratio = payload_size/unsimp_payload_size

# # 		# 	puts "Ratio: #{ratio}"

# # 		# 	puts "<<<<<<<<<<"

# # 		# end


# 		# USED FOR TOTAL PAYLOAD
# 		# Starting at 100!!!
# 		reduction = 200

# 		while payload_size > 4

# 			reduction += 5

# 			rating_limit = ratings[reduction]

# 			puts ">>>>>>>>>>"

# 			puts "Attempt: #{reduction/5}"
# 			puts "Rating Threshold: #{rating_limit}"

# 			puts "Percent removed: #{(reduction).to_f/(ratings.length).to_f}"
# 			puts "Remaining polygons: #{ratings[reduction..-1].length}"

# 			payload_size = poly_rating_test(polygons_ratings, rating_limit, bbox)

# 			# ratio = payload_size/unsimp_payload_size

# 			puts "Payload: #{payload_size}"

# 			puts "<<<<<<<<<<"

# 		end

# 		puts "FINAL RATING LIMIT: #{rating_limit}"

# 	end

# end




























# target = testing_hash['8']['boxes'][0]
# polygons = target['polygon_rating']
# bbox = testing_hash['8']['boxes'][0]['bbox']


# sorted_sizes = target['polygon_sizes'].sort

# puts "Smallest: #{sorted_sizes[0]}"
# puts "Largest: #{sorted_sizes[-1]}"

# target_size = sorted_sizes[-100]


# output_polygons = []

# for poly_rating in polygons

# 	# output_polygons << poly_rating['polygon']

# 	if poly_rating['size'] >= target_size

# 		output_polygons << poly_rating['polygon']

# 	end

# end






# # Assemble simplified polygons for testing untrimmed
# target = testing_hash['8']['boxes'][0]

# output_polygons = []

# for poly_rating in target['polygon_rating']

# 	# output_polygons << poly_rating['polygon']

# 	if poly_rating['rating'] >= rating_limit

# 		output_polygons << poly_rating['polygon']

# 	end

# end


# TESTING SMALLEST POLYGONS



# # Getting total poly count
# total_poly_length = box['intersections'].length


# # Save unsimplified polygons for getting reduction ratio
# box_hash['unsimplified'] = []




# puts "Total number of polygons: #{total_poly_length}"

# puts "Number of too-small polygons: #{target_polygons.length}"

# puts "Ratio: #{(target_polygons.length).to_f/(total_poly_length).to_f}"

# puts "Minimum poly length test: #{polychop_lentest(target_polygons, bbox)}"


# puts "Sample length: #{polychop_lentest(target_polygons[0..500], bbox)}"








# target = testing_hash['8']['boxes'][0]
# target_polygons = target['polygons']
# target_bbox = target['bbox']


# unsimplified_polys = target['unsimplified']


# # Get Estimated Payload Size
# simpl_length = polychop_lentest(target_polygons, target_bbox)
# unsimpl_length = polychop_lentest(unsimplified_polys, target_bbox)


# puts "Simplifaction Ratio: #{simpl_length/unsimpl_length}"
# puts "Total Payload size: #{simpl_length}"

# Trying to simplify again








# # Output
# size_parameters = {}

# # Testing
# for zoom_level, zoom_contents in testing_hash

# 	size_parameters[zoom_level] = {}

# 	# BBox samples and their intersecting polygons
# 	target_boxes = zoom_contents['boxes']

# 	# Total bounding box area
# 	bbox_area = zoom_contents['average_box_area']

# 	# Ratio of BBox Size to Minimum Polygon Size
# 	min_poly_bbox_ratio = zoom_contents['settings']['minimum_poly_bbox_ratio']

# 	# Minimum Polygon Size, Regardless of Fill
# 	min_poly_size = bbox_area * min_poly_bbox_ratio

# 	# For Each Test BBox and its intersecting polygons:
# 	for box in target_boxes

# 		# Filter out polygons and holes beneath rating threshold
# 		for polygon in box['polygons']

# 			puts "Hello"

# 		end

# 	end

# end







# puts average(calcutaions)

# sorted = calcutaions.sort

# puts sorted[0]
# puts sorted[-1]


# 	# Establishing parameters from zoom_parameters 
# 	# The area threshold for removing a hole from a polygon
# 	min_hole_size = zoom_contents['settings']["minimum_hole_size"]
# 	# The pencent of original size to which a polygon may be reduced
# 	simplify_ratio = zoom_contents['settings']["simplification"] 

# 	size_fill_ratio = zoom_contents['settings']["size_fill_limits"]


# 	# Setting Limits for Looping
# 	min_hole_size_limit = min_hole_size * 10


# 	size_fill_limits = {}
# 	size_fill_limits["0.5"] = size_fill_ratio["0.5"] * 10
# 	size_fill_limits["0.25"] = size_fill_ratio["0.25"] * 10
# 	size_fill_limits["0"] = size_fill_ratio["0"] * 10



# 	#  "0.5": 1000000,
# 	# "0.25": 3000000,
# 	# "0": 5000000



# 	# Size/fill elimination explores the ratio between two ratios
# 	# Size is polygon area compared to bounding box area
# 	# fill is polygon area compared to polygon envelope





# 	# # DONE AS RATIO, RATIO IS SET BY TESTING ON ZOOM 8
# 	# size_fill_ratio = {}
# 	# size_fill_ratio["0.5"] = bbox_area * (50 * (10 ** -7))
# 	# size_fill_ratio["0.25"] = bbox_area * (10 * (10 ** -6))
# 	# size_fill_ratio["0"] = bbox_area * (20 * (10 ** -6))


# 	# # DONE MANUALLY
# 	# size_fill_ratio = {}
# 	# size_fill_ratio[0.5] = 0
# 	# size_fill_ratio[0.25] = 0
# 	# size_fill_ratio[0] = 0


# 	# # Setting Limits
# 	# min_hole_size_limit = 10000


# 	# size_fill_limits = {}
# 	# size_fill_limits[0.5] = 10000
# 	# size_fill_limits[0.25] = 10000
# 	# size_fill_limits[0] = 100000











# 	puts "Starting first Simplification"
# 	puts ""

# 	# Filter Holes, Filter Small Polygons, Simplify Polygon in Each Box
# 	first_simplification = box_simplifier(simplify_ratio,
# 		min_hole_size, size_fill_ratio, target_boxes, factory)

# 	current_payload_average = average_box_length(first_simplification)
# 	average_point_length = average_polygon_point_count(first_simplification)

# 	puts ">>>>>>>>>>"
# 	puts "Zoom Level #{zoom_level} initial size: #{current_payload_average}"

# 	puts "Average BBox-Chopped Polygon Point Length: #{average_point_length[0]}"
# 	puts "Max BBox-Chopped Polygon Point Length: #{average_point_length[1]}"

# 	puts "\a"
	
# 	attempts = 0

# 	while current_payload_average > 1

# 		attempts += 1

# 		puts "=========="
# 		puts "Attempt ##{attempts}"

# 		if min_hole_size > min_hole_size_limit
# 			puts "Minimum Hole Size Reached"
# 			break
# 		else
# 			min_hole_size = min_hole_size * 1.25
# 		end


# 		for fill, size_limit in size_fill_ratio

# 			if size_limit > size_fill_limits[fill]
# 				puts "Max Size/Fill Reached: #{fill}: #{size_limit}"
# 				break
# 			else
# 				size_fill_ratio[fill] = size_limit * 1.25
# 			end

# 		end

# 		# if simplify_ratio < 0.1
# 		# 	puts "Simplification Limit Hit"
# 		# 	# break
# 		# else
# 		# 	simplify_ratio -= 0.05
# 		# end

# 		if attempts == 20
# 			puts "TOO MANY ATTEMPTS!!!"
# 			break
# 		end


# 		puts "=========="
# 		puts "Minimum Hole Size: #{min_hole_size}"
# 		puts "Simplification: #{simplify_ratio}"
# 		puts "Size/Fill Limits: #{size_fill_ratio}"
# 		puts "=========="

# 		simplified_boxes = box_simplifier(simplify_ratio, min_hole_size, 
# 			size_fill_ratio, target_boxes, factory)

# 		current_payload_average = average_box_length(simplified_boxes)

# 		puts "Payload = #{current_payload_average}"
# 		puts "=========="
# 		puts "\a"

# 	end

# 	puts "Zoom Level #{zoom_level} final size: #{current_payload_average}"
# 	puts "<<<<<<<<<<"

# 	size_parameters[zoom_level]['Simplification'] = simplify_ratio
# 	size_parameters[zoom_level]['Minimum Hole Size'] = min_hole_size
# 	size_parameters[zoom_level]['Fill Size Limits'] = size_fill_ratio
# 	size_parameters[zoom_level]['Final Payload'] = current_payload_average
# end


# pp(size_parameters)




