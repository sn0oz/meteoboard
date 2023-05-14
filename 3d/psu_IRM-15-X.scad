
include<psu_IRM-15-X_dimensions.scad>;

eps = 0.01;

module PSU_IRM_15_X() {

    gray = [0.7, 0.7, 0.7];
    black = [0, 0, 0];

    pin_height = 3.5;
    module pin() {
        color(gray) {
            linear_extrude(height=pin_height) {
                circle(0.5);
            }
        }
    }

    module chassis() {
        color(black) {
            cube([psu_length, psu_width, psu_height]);
        }
    }
  

    chassis();
    // AC pins
    for (y = [3.2, 24]) {
        translate([3.4, y, -pin_height]) {
            pin();
        }
    }
    // DC pins
    for (y = [3.2, 11.2]) {
        translate([48.4, y, -pin_height]) {
            pin();
        }
    }
}

// Example usage:
PSU_IRM_15_X();