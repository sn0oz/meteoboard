
include<pir_SBC_dimensions.scad>;

module PIR_SBC() {
    $fn = 30;

    eps = 0.01;

    black = [0.05, 0.05, 0.05];
    white = [1, 1, 1];

    module chassis() {
        color(black) {
            translate([0, 0, 0]) {
                cube([pir_length, pir_width, pir_height]);
            }
        }
    }

    module lens() {
        color (white) {
            union() {
                cylinder(h=pir_lens_height, r=pir_lens_radius);
                translate([0, 0, pir_lens_height])
                    sphere(pir_lens_radius);
                
            }
        }
    }

    module pins() {
        color (white) {
            cube([2, 10, 2]);
        }
    }

    module connector() {
        union() {
            color (black) {
                cube([2.5, 10, 2.5]);
            }
            color (white) {
                translate([0, 0, 2.5])
                    cube([8.5, 10, 2.5]);
            }
        }
    }
    
    module screw_hole() {
        cylinder(pir_height + eps, d=2*pir_screw_hole_radius);
    }

    translate([0, 0, 0]) {
        difference() {
            chassis();
            screw_hole_distance = pir_screw_hole_radius + pir_screw_hole_margin;
            for (i = [screw_hole_distance, pir_length - screw_hole_distance]) {
                for (j = [screw_hole_distance, pir_width - screw_hole_distance]) {
                    translate([i, j, -eps/2])
                       screw_hole();
                }
            }
        }
        translate([pir_length/2, pir_width/2, pir_height]) {
            lens();
        }
        translate([31.25, 15.5, 0])
            rotate([0, 180, 180])
                connector();
        translate([31.5, 5.5, pir_height])
            pins();
    }
}

// Example usage:
PIR_SBC();