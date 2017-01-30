def sample_generator(map_data, sample_length)

  samples = []

  loops = 0

  working_data = map_data

  while loops < sample_length

    loops += 1

    new_map_data = working_data

    rando = rand(new_map_data.length)

    rand_poly = new_map_data[rando]

    samples << rand_poly

    new_map_data.delete_at(rando)

    working_data = new_map_data

  end

  return samples

end