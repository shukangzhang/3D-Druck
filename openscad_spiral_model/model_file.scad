// Environment parameters
$fn = 100;

/* Tool functions */
// Build sum of flattened vector
function add(v, i=0, r=0) = i<len(v) ? add(v, i+1, r+v[i]) : r;
// Flatten nested list
function flatten(l) = [ for (a = l) for (b = a) b ];
// Calculate center points of ring structure
function get_center_points(ring_structure) = [for (ring=ring_structure) let (degrees=360/ring[0], distance_to_center=ring[1])
        // Check if current ring contains elements
        if (ring[0]==0) []
        // No rotation is given for the current ring
        else if (len(ring)==3) 
            [for (a=[0:ring[0]-1]) [distance_to_center*cos(a*degrees), distance_to_center*sin(a*degrees)]] 
        // Rotation is given and must be added for the current ring
        else 
            [for (a=[0:ring[0]-1]) [distance_to_center*cos(a*degrees + ring[3]), distance_to_center*sin(a*degrees + ring[3])]]
    ];

/* Modules for the structure */
// Creates simple connection between two points in 2D; points in form [x, y]
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

/* Input parameters */
// Parameters for the 2D-structure

// Ring structure is an array with each element describing one ring in the form [number of objects, distance to center, radius of sphere, optional rotation]
// It has to be sorted from outer most to inner most rings
ring_structure = [
    [12, 45, 2, 10],
    [0, 36, 2],
    [4, 20, 2],
    [1, 0, 3]
];
// Thickness of the bridges connecting the circles
bridge_thickness = 4.0;

// Parameters for the 3D-structure
// Height of the completed structure
structure_height = 200;
// Twist applied to the structure to build the helixes in degrees
structure_twist = 112.5;

/* Create the structure */
// Calculate center points of the structures to extrude
center_points = get_center_points(ring_structure);


// Extrude the 2D-Structure with a twist to create helixes
// Color for better contrast in preview mode
color("lightgrey")
difference() {
union() {
    linear_extrude(height=structure_height/2, center=false, twist=structure_twist, slices=50) {
        // Create ring structure in 2D 
        for (current_ring=ring_structure) {
            // Check if ring has elements
            if (current_ring[0] == 0) {}
            // Check if ring has rotation
            else if (len(current_ring) == 4)
                ring(current_ring[0], current_ring[1], current_ring[2], current_ring[3]);
            // Ring has no rotation
            else 
                ring(current_ring[0], current_ring[1], current_ring[2]);
        }
        // Create bridges between rings
        bridges_between_rings(ring_structure, center_points, bridge_thickness);
    }
    translate([0, 0, structure_height/2])
    rotate(-structure_twist)
    linear_extrude(height=structure_height/2, center=false, twist=-structure_twist, slices=50) {
        // Create ring structure in 2D 
        for (current_ring=ring_structure) {
            // Check if ring has elements
            if (current_ring[0] == 0) {}
            // Check if ring has rotation
            else if (len(current_ring) == 4)
                ring(current_ring[0], current_ring[1], current_ring[2], current_ring[3]);
            // Ring has no rotation
            else 
                ring(current_ring[0], current_ring[1], current_ring[2]);
        }
        // Create bridges between rings
        bridges_between_rings(ring_structure, center_points, bridge_thickness);
    }
}
translate([-50, 0, 0])
cube([200, 200, structure_height]);
}
// Create simple model of tube for sanity checking
%cylinder(structure_height, d=94);




test = [for (i=[0:5])
    if (i%4 == 0) 
        [0,0]
    else if (i%4 == 1) 
        [0,1]
    else if (i%4 == 2) 
        [1,0]
    else 
        [1,1]
];