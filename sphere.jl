function get_sphere_surface_pos(x::Float64, y::Float64, sphere_radius::Float64)
    return sqrt(sphere_radius*sphere_radius - x*x - y*y)
end

function get_sphere_surface_neg(x::Float64, y::Float64, sphere_radius::Float64)
    return -sqrt(sphere_radius*sphere_radius - x*x - y*y)
end

function map_tris_to_sphere_surface(tris::Array{Array{Array{Float64,1},1},1}, sphere_radius::Float64)

    n_triangles = size(tris,1)
    for i in 1:n_triangles
        n_points = size(tris[i],1)
        for j in 1:n_points
            tris[i][j][3] = get_sphere_surface_pos(tris[i][j][1],tris[i][j][2], sphere_radius)
        end
    end

    return tris
end
