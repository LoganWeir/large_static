    # for polygon in target_boxes[0]['polygons']

    #     # puts ">>>>>>>>>>"
    #     # puts ""

    #     poly_area = polygon.area
    #     envelope_area = polygon.envelope.area

    #     # puts "POLYGON AREA"
    #     # puts poly_area

    #     # puts "ENVELOPE AREA"
    #     # puts envelope_area

    #     poly_fill = poly_area/envelope_area

    #     # puts "POLYGON FILL"
    #     # puts poly_fill

    #     # puts "BBOX AREA"
    #     # puts bbox_area

    #     bbox_fill = poly_area/bbox_area

    #     # puts "BBOX FILL"
    #     # puts bbox_fill

    #     # puts ""

    #     # puts "COMPARISON"

    #     # puts "#{poly_fill} | #{bbox_fill * 10**6}"

    #     # puts ""

    #     calc = (poly_area**2/(envelope_area * bbox_area)) * 10**6

    #     # puts "CALCULATION"
    #     # puts calc

    #     # puts ""
    #     # puts "<<<<<<<<<<"

    #     calcutaions << calc

    # end

    # puts 500000/bbox_area
