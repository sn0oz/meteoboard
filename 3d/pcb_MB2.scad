
include<pcb_MB2_dimensions.scad>;
include<psu_IRM-15-X_dimensions.scad>;
include<esp32_nodeMCU_dimensions.scad>;

use<psu_IRM-15-X.scad>;
use<esp32_nodeMCU.scad>;


eps = 0.01;
$fn = 64;

module PCB_MB2() {

    gray = [0.7, 0.7, 0.7];
    black = [0, 0, 0];
    green = [0.2, 0.7, 0.2];
    light_green = [0.2, 0.9, 0.2];

    module base_plate() {
        color(green) {
            linear_extrude(height=pcb_height) {
                difference() {
            
                    square([pcb_width, pcb_length]);

                    // PCB mount holes
                    mh_radius = 2.15;
                    translate([4.6, 16])
                        circle(mh_radius);
                    translate([35.5, 56.4])
                        circle(mh_radius);
                    x = [28.5, 21];
                    for (i = [0:6]) {
                        translate([x[i%2], 112.6 + i*2*(mh_radius+0.1)])
                            circle(mh_radius);
                    }

                    // PIR hole
                    translate([24.8, 72.6])
                        circle(12);
                    
                    // PIR mount holes
                    ph_radius = 1.3;
                    for (y = [60.6, 77.3]) {
                        translate([2.8, y])
                            circle(ph_radius);
                    }
                    translate([38.6, 60.6]) {
                            circle(ph_radius);
                    }
                }
            }
        }
    }

    module pin_female(cols, rows=1) {
        w = 2.54; h = 8.5; p = 0.65;
        for(x = [0 : (cols -1)]) {
            for(y = [0 : (rows  - 1)]) {
                translate([w * x, w * y, 0]) {
                    union() {
                        color([0.2, 0.2, 0.2]) difference() {
                            cube([w, w, h]);
                            translate([(w - p) / 2,(w - p) / 2,h - 6]) cube([p, p, 6.1]);
                        }
                        color("gold")  translate([(w - p) / 2, (w - p) / 2, -3]) cube([p, p, 3]);
                    }
                }
            }
        }
    }

    module power_connector() {
        color(light_green) {
            cube([7.6, 10.2, 10]);
        }
    }

    base_plate();
    for (y = [1.1, 20.65, 44.3, 79.8, 102.9, 132.3]) {
        translate([0.1, y, pcb_height])
            power_connector();
    }
    // PSU
    translate([10.9 + psu_width, 0.2, pcb_height])
        rotate([0, 0, 90])
            PSU_IRM_15_X();

    // ESP32
    for (x = [13.7, 39.1]) {
        translate([x, 103.7, pcb_height])
            rotate([0, 0, 90])
                pin_female(15, rows=1);
    }
    translate([13.7 - 2.54, 103.7 - 9 + esp32_length, pcb_height + 8.5 + 3])
        rotate([0, 0, -90])
            ESP32_nodeMCU();
}

// Example usage:
PCB_MB2();