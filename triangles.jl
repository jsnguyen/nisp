using Printf
using LinearAlgebra

# makes a centered rectangular mesh with points x_size by y_size
# the mesh is translated to (center_x,center_y) first, then scaled
# z_offset is not multiplied by scale!
# changing scale is just a simple multiplier in x and y
# e.g.
# x_size = 2, y_size = 2, scale = 1 will make a 2x2 square
# x_size = 2, y_size = 2, scale = 2 will make a 4x4 square
# x_size = 3, y_size = 8, scale = 3 will make a 9x24 square
function get_plane_triangle_mesh(x_size::Float64, y_size::Float64, n_x_points::Int64, n_y_points::Int64, x_center::Float64=0, y_center::Float64=0, z_offset::Float64=0)

  n_tris = 2*(n_x_points)*(n_y_points)
  tris = Array{Array{Array{Float64,1},1},1}(undef,n_tris)

  tri_counter=1
  triangle_a = Array{Array{Float64,1},1}(undef,3)
  triangle_b = Array{Array{Float64,1},1}(undef,3)

  for i in 1:3
    triangle_a[i] = Array{Float64,1}(undef,3)
    triangle_b[i] = Array{Float64,1}(undef,3)
  end

  for i in 1:n_x_points
    i -= 1
    for j in 1:n_y_points
      j -= 1
      
      triangle_a[1][1] = i
      triangle_a[1][2] = j
      triangle_a[1][3] = z_offset

      triangle_a[2][1] = (i+1)
      triangle_a[2][2] = j
      triangle_a[2][3] = z_offset

      triangle_a[3][1] = i
      triangle_a[3][2] = (j+1)
      triangle_a[3][3] = z_offset

      triangle_b[1][1] = (i+1)
      triangle_b[1][2] = (j+1)
      triangle_b[1][3] = z_offset

      triangle_b[2][1] = i
      triangle_b[2][2] = (j+1)
      triangle_b[2][3] = z_offset

      triangle_b[3][1] = (i+1)
      triangle_b[3][2] = j
      triangle_b[3][3] = z_offset

      tris[tri_counter] = deepcopy(triangle_a)
      tri_counter+=1
      tris[tri_counter] = deepcopy(triangle_b)
      tri_counter+=1

    end
    #@printf("%3.2f%%\n",100.0*(n_tris\tri_counter))
  end

  x_scale = x_size / n_x_points
  y_scale = y_size / n_y_points
  tris = translate_triangle_mesh(tris,-n_x_points/2.0 + x_center/x_scale,-n_y_points/2.0 + y_center/y_scale)
  tris = scale_triangle_mesh(tris,x_scale,y_scale)

  return tris 
end

function translate_triangle_mesh(tris::Array{Array{Array{Float64,1},1},1}, x_offset::Float64, y_offset::Float64)

  n_triangles = size(tris,1)
  for i in 1:n_triangles
    n_points = size(tris[i],1)
    for j in 1:n_points
      tris[i][j][1] += x_offset
      tris[i][j][2] += y_offset
    end
  end

  return tris
end

function scale_triangle_mesh(tris::Array{Array{Array{Float64,1},1},1}, x_scale::Float64, y_scale::Float64)

  n_triangles = size(tris,1)
  for i in 1:n_triangles
    n_points = size(tris[i],1)
    for j in 1:n_points
      tris[i][j][1] *= x_scale
      tris[i][j][2] *= y_scale
    end
  end

  return tris
end

function area_of_triangle(tri::Array{Array{Float64,1},1})

  AB = tri[1]-tri[2]
  BC = tri[2]-tri[3]
  dot_prod = dot(AB,BC)
  norm_AB = norm(AB)
  norm_BC = norm(BC)

  return 0.5 * norm_AB * norm_BC * sqrt(1 - (dot_prod / (norm_AB*norm_BC))^2)
end

function area_of_triangle_mesh(tris::Array{Array{Array{Float64,1},1},1})

  sum = 0
  n_triangles = size(tris,1)
  for i in 1:n_triangles
    sum += area_of_triangle(tris[i])
  end

  return sum
end
