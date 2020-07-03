// Environment parameters
$fn = 20;

/* Tool functions */
// Build sum of flattened vector
function add(v, i=0, r=0) = i<len(v) ? add(v, i+1, r+v[i]) : r;
// Flatten nested list
function flatten(l) = [ for (a = l) for (b = a) b ];
// Calculate center points of ring structure
function get_center_points(ring_structure) = [for (ring=ring_structure) let (degrees=360/ring[0], distance_to_center=ring[1])
        // no rotation is given for the current ring
        if (len(ring)==3) 
            [for (a=[0:ring[0]-1]) [distance_to_center*cos(a*degrees), distance_to_center*sin(a*degrees)]] 
        // rotation is given and must be added for the current ring
        else 
            [for (a=[0:ring[0]-1]) [distance_to_center*cos(a*degrees + ring[3]), distance_to_center*sin(a*degrees + ring[3])]]
    ];

/* Old non-functioning
// points in form [x, y]
module square_between_two_points(point_one, point_two, thickness) {
    length = norm(point_one - point_two);
    degree = atan2(point_one[0] - point_two[0], point_one[1] - point_two[1]);
    translate(point_one)
    rotate(degree)
    translate([0, -thickness/2])
    square([length, thickness], center=false);
}
*/

// Creates simple connection between two points in 2D
// points in form [x, y]
module square_between_two_points(point_one, point_two, thickness) {
    hull() {
        translate(point_one)
        circle(d=thickness);
        translate(point_two)
        circle(d=thickness);
    }
}

module ring(number_of_objects, distance_to_center, radius, rotation=0) {
    degrees = 360/number_of_objects;
    for (a =[0:number_of_objects-1]) {
        rotate(a*degrees + rotation)
        translate([distance_to_center, 0])
        circle(radius);
    }
    // center points of the circles
    //center_points_a = [for (a=[0:number_of_objects-1]) [distance_to_center*cos(a*degrees + rotation), distance_to_center*sin(a*degrees + rotation)]];
    //echo("center_points", center_points_a);
    /* 
    // Test center points
    for(c = center_points) {
        translate(c)
        cylinder(2, r=0.5);
    } 
    */
}

// For every center point find the closest center point from an ring closer to the center and connect them with a square
module bridges_between_rings(ring_structure, center_points, thickness_bridge) {
    
    for (ring_index=[0:len(ring_structure)-2]) {
        inner_rings_center_points = [for (a=[ring_index+1:len(ring_structure)-1]) center_points[a]];
        flattened_inner_rings_center_points = flatten(inner_rings_center_points);
        //echo("inner_rings:", inner_rings_center_points);
        //echo("flattened inner_rings:", flattened_inner_rings_center_points);
        for (center_point=center_points[ring_index]) {
            // vector of distances to each other center point of more inner rings
            distances = [for (other_point=flattened_inner_rings_center_points) norm(center_point-other_point)];
            //echo("distances:", distances);
            //echo("min_distance:", min(distances));
            min_distance_index = search(min(distances), distances)[0];
            //echo("min_distance_index", min_distance_index);
            // create bridge between those two points
            //echo("from:", center_point, " ;to:", flattened_inner_rings_center_points[min_distance_index]);
            square_between_two_points(center_point, flattened_inner_rings_center_points[min_distance_index], thickness_bridge);
            /*
            // Show start and end point of bridge
            translate(flattened_inner_rings_center_points[min_distance_index])
            cylinder(4, r=0.5);
            color("red")
            translate(center_point)
            cylinder(2, r=1);
            */
        }
    }

    // Connect inner ring with itself if it contains more than one object
    inner_ring = ring_structure[len(ring_structure)-1];
    if (inner_ring[0] > 1) {
        inner_ring_center_points = center_points[len(center_points)-1];
        for (center_point_index=[0:(len(inner_ring_center_points)-1)]) {
            if (center_point_index==len(inner_ring_center_points)-1) {
                square_between_two_points(inner_ring_center_points[center_point_index], inner_ring_center_points[0]);
            }
            else {
                square_between_two_points(inner_ring_center_points[center_point_index], inner_ring_center_points[center_point_index+1]);
            }
        }
    }

}

/* Define parameters */
// Animation parameter
fps = 20;
steps = 200;
number_of_seconds = steps/fps;
// animation parameter with range [0-9]
animation_parameter_0_10_1 = floor(10*$t);
animation_parameter_0_40_1 = floor(40*$t);
animation_parameter_2_6_1 = floor(4*$t) + 2;
animation_parameter_0_90_1 = floor(91*$t);
echo("ap_0_10_1:", animation_parameter_0_10_1);
echo("ap_2_6_1:", animation_parameter_2_6_1);
echo("ap_0_90_1:", animation_parameter_0_90_1);

// Ring structure is an array with each element describing one ring in the form [number of objects, distance to center, radius of sphere, optional rotation]
// It has to be sorted from outer most to inner most rings
ring_structure = [
    [12, 48, 2, 10],
    [12, 36, 4],
    [4, 22, 6],
    [1, 0, 8]
];
animation_ring_structure = [
    [10+animation_parameter_0_40_1, 60+3*animation_parameter_0_10_1, 2],
    [6+animation_parameter_2_6_1, 50+3*animation_parameter_0_10_1, 4],
    [6+animation_parameter_2_6_1, 30+animation_parameter_0_40_1/2, 8-animation_parameter_2_6_1+1, 2*animation_parameter_0_90_1],
    [animation_parameter_2_6_1, 10, 5]
];

// Calculate center points of the structures to extrude
center_points = get_center_points(ring_structure);
animation_center_points = get_center_points(animation_ring_structure);

/*
// Extrude the 2D-Structure with a twist to create helixes
linear_extrude(height= 100, center=false, twist=90, slices=20) {
    // Create ring structure in 2D 
    for (current_ring=ring_structure) {
        if (len(current_ring) == 4)
            ring(current_ring[0], current_ring[1], current_ring[2], current_ring[3]);
        else 
            ring(current_ring[0], current_ring[1], current_ring[2]);
    }
    // Create bridges between rings
    bridges_between_rings(ring_structure, center_points, 1);
}
*/

// Extrude animation structure
linear_extrude(height= 100, center=false, twist=45+animation_parameter_0_90_1, slices=20) {
    // Create ring structure in 2D 
    for (current_ring=animation_ring_structure) {
        if (len(current_ring) == 4)
            ring(current_ring[0], current_ring[1], current_ring[2], current_ring[3]);
        else 
            ring(current_ring[0], current_ring[1], current_ring[2]);
    }
    // Create bridges between rings
    color("green")
    bridges_between_rings(animation_ring_structure, animation_center_points, 1);
}
