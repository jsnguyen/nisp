using Printf
using Plots

include("triangles.jl")
include("sphere.jl")
include("stl.jl")

function main()
  sphere_radius = 1.0
  n_points = 10
  side_length = sphere_radius/10
  earth_axial_tilt = deg2rad(23.43652)
  lat = deg2rad(30)

  # pi/2 - lat due to lat convention of 0 deg at equator
  min_off_axis_angle = pi/2 - (-earth_axial_tilt + (pi/2-lat))
  max_off_axis_angle = pi/2 - ( earth_axial_tilt + (pi/2-lat))

  min_offset = sphere_radius*sin(min_off_axis_angle)
  max_offset = sphere_radius*sin(max_off_axis_angle)

  println("Calculating face-on...")
  # head on, normal to the surface
  mid_tris = get_plane_triangle_mesh(side_length, side_length, n_points, n_points, 0.0, 0.0, 0.0)
  mid_tris = map_tris_to_sphere_surface(mid_tris, sphere_radius)
  mid_area = area_of_triangle_mesh(mid_tris)

  println("Calculating minimum...")
  # minimum (winter in northern hemisphere)
  min_tris = get_plane_triangle_mesh(side_length, side_length, n_points, n_points, min_offset, 0.0, 0.0)
  min_tris = map_tris_to_sphere_surface(min_tris, sphere_radius)
  min_area = area_of_triangle_mesh(min_tris)

  println("Calculating maximum...")
  # maximum (summer in northern hemisphere)
  max_tris = get_plane_triangle_mesh(side_length, side_length, n_points, n_points, max_offset, 0.0, 0.0)
  max_tris = map_tris_to_sphere_surface(max_tris, sphere_radius)
  max_area = area_of_triangle_mesh(max_tris)

  @printf("Minimum Offset: %.6f\n", min_offset)
  @printf("Maximum Offset: %.6f\n", max_offset)
  @printf("Face-On Area  : %.6f\n", mid_area)
  @printf("Minimum Area  : %.6f %8.3f%%\n", min_area,abs(min_area-mid_area)/mid_area * 100)
  @printf("Maximum Area  : %.6f %8.3f%%\n", max_area,abs(max_area-mid_area)/mid_area * 100)

  # linear interpolation between max to min, probably not actually linear...
  # change this to sinusoidal eventually
  mod_area = Vector{Float64}()
  for off in max_offset:0.01:min_offset
    tris = get_plane_triangle_mesh(side_length, side_length, n_points, n_points, off, 0.0, 0.0)
    tris = map_tris_to_sphere_surface(tris, sphere_radius)
    area = area_of_triangle_mesh(tris)
    append!(mod_area,area)
  end
  
  plot(max_offset:0.01:min_offset, mod_area)
  savefig("out.png")

end

main()
