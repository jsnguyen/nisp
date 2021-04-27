using Plots
using Dates

include("triangles.jl")
include("sphere.jl")
include("stl.jl")

# get projected area given the latitude
# returns an array of the percent increase in area over given range
function get_projected_area(lat, range)

    sphere_radius = 1.0
    n_points = 10
    side_length = sphere_radius/1000
    earth_axial_tilt = deg2rad(23.43652)

    inc_area = Vector{Float64}()
    for ang in range
        off_axis_angle = pi/2 - (earth_axial_tilt*cos(ang) + (pi/2-lat))
        offset = sphere_radius*sin(off_axis_angle)
        tris = get_plane_triangle_mesh(side_length, side_length, n_points, n_points, offset, 0.0, 0.0)
        tris = map_tris_to_sphere_surface(tris, sphere_radius)
        area = ((area_of_triangle_mesh(tris)/(side_length^2))-1) * 100 # gives the percent increase in area
        append!(inc_area,area)
    end

    return inc_area

end

function main()

    orbit_range = 0:0.01:2*pi

    # clear old plot
    plot()

    ################
    # PLOT EQUATOR #
    ################
    
    lat = 0
    inc_area = get_projected_area(lat, orbit_range)
    println("Max at 0° ",maximum(inc_area))
    plot!(map(x -> rad2deg(x), orbit_range), 
          inc_area,
          label = "0°",
          xticks=0:30:360,
          yticks=0:25:200,
          linewidth=3,
          title="Projected Area Across One Full Orbit",
          legendtitlefontsize=9,
          legendtitle="Latitude",
          legendfonthalign=:right,
          size = (400, 300),
          color=:black,
          linestyle=:dot,
          alpha=1)

    ################
    # PLOT N. LATS #
    ################

    lat_range = [pi/12 , pi/6, pi/4]
    lat_range_strings = ["15° N", "30° N", "45° N"]

    for (i,(lat, lat_str)) in enumerate(zip(lat_range, lat_range_strings))
        inc_area = get_projected_area(lat, orbit_range)
        println("Max at ",lat_str," ",maximum(inc_area))
        plot!(map(x -> rad2deg(x), orbit_range),
              inc_area, 
              label = lat_str,
              xticks=0:30:360,
              yticks=0:25:200,
              linewidth=3,
              title="Projected Area Across One Full Orbit",
              legendtitlefontsize=9,
              legendtitle="Latitude", 
              legendfonthalign=:right,
              size = (400, 300),
              color=i)
    end

    ################
    # PLOT S. LATS #
    ################
    
    lat_range = [-pi/12 , -pi/6, -pi/4]
    lat_range_strings = [ "15° S", "30° S", "45° S"]

    for (i,(lat, lat_str)) in enumerate(zip(lat_range, lat_range_strings))
        inc_area = get_projected_area(lat, orbit_range)
        println("Max at ",lat_str," ",maximum(inc_area))

        plot!(map(x -> rad2deg(x), orbit_range),
              inc_area, 
              label = lat_str,
              xticks=0:30:360,
              yticks=0:25:200,
              linewidth=3,
              title="Proj. Area Across One Full Orbit",
              legendtitlefontsize=9,
              legendtitle="Latitude", 
              legendfonthalign=:right,
              size = (400, 300),
              color=i,
              alpha=0.4,
              linestyle=:dash)
    end

    xlabel!("Orbit Angle [deg]")
    ylabel!("Increase in Projected Area [%]")
    plot!()
    savefig("area_plot.png")

end

main()
