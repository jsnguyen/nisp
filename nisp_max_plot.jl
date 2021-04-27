using Plots
using Dates

include("triangles.jl")
include("sphere.jl")
include("stl.jl")

# get projected area given the latitude
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
        area = ((area_of_triangle_mesh(tris)/(side_length^2))-1) * 100
        append!(inc_area,area)
    end
    return inc_area

end

function main()

    plot()

    lat_range = 0:0.01:pi/2-pi/12

    inc_area = Vector{Float64}()
    for lat in lat_range
        append!(inc_area, get_projected_area(lat, [pi/2]))
    end

    plot!(map(x -> rad2deg(x), lat_range),
          inc_area,
          xticks=0:5:75, 
          yticks=0:25:300,
          linewidth=3,
          legend=false,
          size = (400, 300),
          color=:red)

    xlabel!("Latitude [deg]")
    ylabel!("Max Increase in Proj. Area [%]")
    plot!()
    savefig("max_area_plot.png")


end

main()
