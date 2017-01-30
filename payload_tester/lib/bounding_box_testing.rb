require 'rgeo/geo_json'
require 'rgeo'
require 'pry'





# Filtering out holes that are too small
def hole_filtering(minimum_hole_size, polygon, factory)
	# If holes
	if polygon.num_interior_rings > 0
		new_inner_array = []
		# For each hole
		for inner_ring in polygon.interior_rings do
			# Test size
			if factory.polygon(inner_ring).area > minimum_hole_size
				# If big enough, add to array
				new_inner_array << inner_ring
			end
		end
		if new_inner_array.length > 0
			# If any made it, build new polygon
			new_polygon = factory.polygon(polygon.exterior_ring, 
				new_inner_array)
		else
			# Else, new polygon with no holes
			new_polygon = factory.polygon(polygon.exterior_ring)				
		end
		return new_polygon
	else
		return polygon
	end
end


# Rates the polygons based on their size relative to the bbox, and their fill
def fill_size_rating(poly_area, bbox_area, envelope_area)

	rating = (poly_area**2/((envelope_area * 10) * bbox_area)) * 10**6

	return rating

end


# The the average value for an array of numbers
def average(array)
	average = array.inject \
			{ |sum, el| sum + el }.to_f / array.length.to_f
end




# Takes in RGEO Polygons, Chops to fit BBox, Converts to JOSN, Returns Length
def polychop_lentest(array, bounding_box)
	chopped_json_polys = []
	for polygon in array
		if polygon.intersects?(bounding_box)
			poly_chop = bounding_box.intersection(polygon)
			geo_type = poly_chop.geometry_type.type_name
			if geo_type == "Polygon"
				json_poly = RGeo::GeoJSON.encode(poly_chop)
				chopped_json_polys << json_poly
			elsif geo_type == "MultiPolygon"
				for single_poly in poly_chop
					json_poly = RGeo::GeoJSON.encode(single_poly)
					chopped_json_polys << json_poly
				end
			end
		end
	end
	return (chopped_json_polys.to_json.length.to_f/1024)/1024
end




# Gets the average JSON length of all boxes
def average_box_length(array)
	all_box_lengths = []
	for box in array
		all_box_lengths << polychop_lentest(box['polygons'], box['bbox'])
	end
	average(all_box_lengths)
end









# GETTING THE AVERAHE POINT LENGTH OF BBOX CHOPPED POLYGON
# Takes in RGEO Polygons, Chops to fit BBox, Converts to JOSN, Returns Length
def polychop_point_test(array, bounding_box)
	point_lengths = []
	for polygon in array
		if polygon.intersects?(bounding_box)
			poly_chop = bounding_box.intersection(polygon)
			geo_type = poly_chop.geometry_type.type_name
			if geo_type == "Polygon"	
				point_lengths << total_point_count(poly_chop)
			elsif geo_type == "MultiPolygon"
				for single_poly in poly_chop
					point_lengths << total_point_count(single_poly)
				end
			end
		end
	end
	return [average(point_lengths), point_lengths.max, point_lengths.sort[-10..-1]]
end




# Gets the average JSON length of all boxes
def average_polygon_point_count(array)
	all_polygon_lengths = []
	max_polygon_length = []
	for box in array
		testing = polychop_point_test(box['polygons'], box['bbox'])
		all_polygon_lengths << testing[0]
		max_polygon_length << testing[1]

	end
	[average(all_polygon_lengths),  average(max_polygon_length)]
end


# Counts exterior ring and inside rings
def total_point_count(polygon)
	total_count = 0
	total_count += polygon.exterior_ring.num_points
	if polygon.num_interior_rings > 0
		for inner_ring in polygon.interior_rings do 
			total_count += inner_ring.num_points
		end
	end
	total_count
end



# Counts the total points in a multi-polygon
def poly_array_point_count(polygon_array)

	total = 0

	# THIS WONT FUCKING WORK ITS JUST PSEUDO CODE BITCH
	for polygon in polygon_array

		total += total_point_count(polygon)

	end

	return total

end







# SIMPLIFICATION
def polygon_simplifier(polygon, ratio, minimum_area)

	# Establish Target Reduction
	max_points = total_point_count(polygon) * ratio

	# Establish original count to track reduction percentage
	original_point_count = total_point_count(polygon)

	simplfication = 0

	# Used to collect multi_polygon splits
	multi_split = []

	# Start looping
	while total_point_count(polygon) > max_points

	# # ENDLESS LOOPING
	# while true

		simplfication += 1

		new_simple_projection = polygon.simplify(simplfication)

		# Over-simplification can delete polygons
		if new_simple_projection == nil

			break

		# Polygons can simply end up empty?
		elsif new_simple_projection.is_empty?

			break 

		elsif new_simple_projection.area < minimum_area

			break

		# Over-simplification can turn the projection into a multi-polygon
		elsif new_simple_projection.geometry_type.type_name == "MultiPolygon"

			current_point_count = total_point_count(polygon)

			multi_polygon_simplifier(current_point_count, max_points, 
				new_simple_projection, multi_split, minimum_area)

			break 					

		else

			polygon = new_simple_projection

		end				

	end


	if multi_split.length > 0

		return multi_split

	else

		return [polygon]

	end

end



# Takes a Multi-Polygon, Simplifies each polygon until point sum is less than max
def multi_polygon_simplifier(current_points, max_points, multi_polygon, output_array, minimum_area)

	# Turn Multi-polygon into an arrary of polygons
	polygon_array = []

	multi_polygon.each do |poly|
		polygon_array << poly
	end

	simplfication = 0

	while current_points > max_points

	# # ENDLESS LOOPING
	# while true

		simplfication += 1

		new_poly_array = []

		for polygon in polygon_array

			new_polygon = polygon.simplify(simplfication)

			# Over-simplification can delete polygons
			if new_polygon == nil
				
				# Add the old polygon
				new_poly_array << polygon

			# Polygons can simply end up empty?
			elsif new_polygon.is_empty?
				
				# Add the old polygon
				new_poly_array << polygon

			elsif new_polygon.area <= minimum_area

				# Skip if rendered too small
				next

			# Over-simplification can turn the projection into a multi-polygon
			elsif new_polygon.geometry_type.type_name == "MultiPolygon"

				new_polygon.each do |poly|

					# Add polygons that are big enough to array
					if poly.area > minimum_area

						new_poly_array << poly

					end

				end 					

			else
			
				# Add new, simpler polygon back into array
				new_poly_array << new_polygon
			
			end

		end

		new_points = poly_array_point_count(polygon_array)

		if current_points == new_points

			polygon_array = new_poly_array

			break

		else

			current_points = new_points

			polygon_array = new_poly_array

		end		

	end


	for final_poly in polygon_array

		output_array << final_poly

	end

end








# ALL TOGETHER NOW
def box_simplifier(ratio, min_hole_size, size_fill_limits = {}, boxes, factory)
	simpler_boxes = []
	for box in boxes
		simpler_box_hash = {}
		simpler_box_hash['bbox'] = box['bbox']
		simpler_box_hash['polygons'] = []
		for polygon in box['polygons']
			hole_filtered = hole_filtering(min_hole_size, polygon, factory)
			simple_poly = polygon_simplifier(hole_filtered, ratio)
			if size_fill_testing(simple_poly, size_fill_limits) == false
				next
			else
				simpler_box_hash['polygons'] << simple_poly
			end
		end
		simpler_boxes << simpler_box_hash
	end
	simpler_boxes
end










# SIZE AND FILL LIMITS
def size_fill_testing(polygon, size_fill_limits = {})
	fit = 0
	polygon_fill = polygon.area/polygon.envelope.area
	polygon_area = polygon.area
	for fill, size in size_fill_limits
		if polygon_fill > fill.to_f &&  polygon_area > size
			fit += 1
		end
	end
	if fit == 0
		return false
	else
		return true
	end
end




def poly_rating_test(polygon_ratings_array, rating_threshold, bbox)

	poly_array = []

	for poly_rating in polygon_ratings_array

		if poly_rating['rating'] > rating_threshold

			poly_array << poly_rating['polygon']

		end

	end

	payload_size = polychop_lentest(poly_array, bbox)

	return payload_size

end





# # Converts polygons from strings into RGeo
# def convert_poly_rgeo(array, factory)
# 	rgeo_polys = []
# 	for polygon in array
# 			rgeo_poly = factory.parse_wkt(polygon)
# 			rgeo_polys << rgeo_poly
# 	end
# 	rgeo_polys
# end





