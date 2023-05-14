
include<esp32_nodeMCU_dimensions.scad>;

module ESP32_nodeMCU() {
    $fn = 30;

    eps = 0.01;

    black = [0.05, 0.05, 0.05];
    gray = [0.5, 0.5, 0.5];

    module chassis() {
        color(gray) {
            translate([0, 0, 0]) {
                cube([esp32_length, esp32_width, esp32_height]);
            }
        }
    }

    module pin() {
        union() {
            color(black) {
                cube(2.54);
            }
            translate([2.54/2, 2.54/2, 2.54]) {
                color(gray) {
                    cube([0.5, 0.5, 6]);
                }
            }
        }
    }

    module pin_header() {
        union() {
            for (i = [0:14]) {
                translate([i*2.54, 0, 0])
                    pin();
            }
        }
    }

    module screw_hole() {
        cylinder(esp32_height + eps, d=2*esp32_screw_hole_radius);
    }

    difference() {
        chassis();
        screw_hole_distance = esp32_screw_hole_radius + esp32_screw_hole_margin;
        for (i = [screw_hole_distance, esp32_length - screw_hole_distance]) {
            for (j = [screw_hole_distance, esp32_width - screw_hole_distance]) {
                translate([i, j, -eps/2])
                    screw_hole();
            }
        }
    }
    translate([4.5, 2.54, 0])
        rotate([180, 0, 0])
            pin_header();
    translate([4.5, esp32_width, 0]) 
        rotate([180, 0, 0])
            pin_header();
}

// Example usage:
ESP32_nodeMCU();