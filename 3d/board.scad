

use<pcb_MB2.scad>;
use<pir_SBC.scad>;
use<led_ADA1376.scad>;
use<label.scad>;
use<projection_renderer.scad>;

include<pcb_MB2_dimensions.scad>;
include<psu_IRM-15-X_dimensions.scad>;
include<pir_SBC_dimensions.scad>;
include<led_ADA1376_dimensions.scad>;

version = "2.1.1";

testing = false;
explosion = 0;

render_3d = true;
render_back_panel = true;
render_electronics = true;
render_front_panel_veneer = true;
render_unmounted_support = true;

// board parameters
pixels_h = 9;
pixels_v = 5;
thickness = 3;
veneer_thickness = 0.3;
num_touch_buttons = 4;
touch_button_radius = 4.5;
front_panel_bicolor = true;
pixel_width = led_interval;
pixel_height = pixel_width;
echo(pixel_width = pixel_width);

// assembly parameters
side_panel_num_notches = 7;
pcb_num_notches = 5;
bp_notch_length = 6;
pcb_clearance = 1;
cable_clearance = 12;
vents_number = 7;
vents_width = 1;
power_cable_position = 0;   // 0 = both, 1 = left, 2 = bottom
power_cable_hole_radius = 3;
buttons_height = pixel_height + thickness;
logo_scale_factor = 1.5;

// 2d parameters
render_index = -1;
render_etch = true;
render_mark = true;
render_engrave = true;
panel_horizontal = 0;
panel_vertical = 0;
render_2d_mirror = false;
a3_fit_offset = 20;

// Remember: it's better to underestimate (looser fit) than overestimate (no fit)
kerf = 0.12;

$fn = 60;

wood = [0.76, 0.6, 0.42];
sycomore = [0.9, 0.85, 0.75];
cherrywood = [0.2, 0.15, 0.2];
etch_color = [0, 0, 0];
mark_color = [0.2, 0.4, 0.6];
engrave_color = [0.85, 0.4, 0];

etch_depth = 0.1;
mark_depth = 0.1;
engrave_depth = 0.1;

// "Epsilon" - a small error tolerance value, used when designing 3d parts to avoid 
// exact complanar faces that cause OpenSCAD rendering artifacts
// See https://3dprinting.stackexchange.com/a/9795
eps = 0.01;

// CHANGELOG v2.1.1
// wall mounted holes gap identical for horizontal and vertical positions
// separator_v0 led cable notches
// power cable hole choice


// TODO: mark helpers and reminders (separators, ...)



// PCB position
pcb_x = thickness + pcb_clearance;
pcb_y = thickness + cable_clearance/2;

// board dimensions
extension_width = pcb_x + pcb_width + cable_clearance;
echo(extension_width = extension_width);

board_height = thickness + pcb_height + psu_height + pcb_clearance + thickness;
echo(board_height=board_height);
board_width = pixels_v*pixel_height + thickness;
echo(board_width = board_width);
board_length = extension_width + pixels_h*pixel_width + thickness;
echo(board_length = board_length);

// common notch width for panel assembly
notch_width = board_height / side_panel_num_notches;

// unmounted support height
um_support_h = (pixels_v-2)*pixel_height + 4*thickness;


if (!testing) {
    assert(board_width >= pcb_y + pcb_length + pcb_clearance,
                                                "Insufficient panel height for PCB !");
    assert(board_length + extension_width + 2*kerf < 418,
                                                "A3 part 1 length overrun !");
    assert(12*board_height + 11*kerf < 416,
                                                "A3 part 2 length overrun !");
    assert(board_width + 3*board_height + 3*kerf < 293,
                                                "A3 part 1 width overrun !");
    assert(board_width + um_support_h + kerf < 293,
                                                "A3 part 2 width overrun !");
}



module copyleft() {
    text(text=str("meteoboard v", version), font = "Roboto", size = 4, valign = "center",
                                                halign = "center");
}

module logo(scale_factor, centered = false) {
    logo_length = 6;
    logo_width = 5;
    if (centered) {
        translate([-logo_length*scale_factor/2, -logo_width*scale_factor/2])
            scale([scale_factor, scale_factor])
                import("images/mb_logo_b&w.svg");
    }
    else {
        scale([scale_factor, scale_factor])
            import("images/mb_logo_b&w.svg");
    }
}

module laser_mirror() {
    if (render_2d_mirror) {
        mirror([1, 0, 0])
            children();
    }
    else {
        children();
    }
}

module laser_etch_style() {
    color(etch_color)
        linear_extrude(height=etch_depth)
            children();
}

module laser_mark_style() {
    color(mark_color)
        linear_extrude(height=mark_depth)
            children();
}

module laser_engrave_style() {
    color(engrave_color)
        linear_extrude(height=engrave_depth)
            children();
}

module air_vents_2d() {
    hull() {
        translate([0, vents_width/2])
            circle(vents_width/2);
        translate([board_height-5*thickness-vents_width, vents_width/2])
            circle(vents_width/2);
    }
}

module wall_mount_hole() {
    hull() {
        circle(3);
        translate([0, 3])
            circle(1);
    }
}

module hook() {
    union() {
        square([3*thickness, 2*thickness]);
        translate([2*thickness, -thickness])
            square(thickness);
    }
}

module unmounted_support_cap() {
    color(wood) {
        linear_extrude(height=thickness) {
            union() {
                hook();
                translate([2*thickness, 2*thickness])
                    square(thickness);
            }
        }
    }
}

module unmounted_support() {
    color(wood) {
        linear_extrude(height=thickness) {
            difference() {
                h = um_support_h;
                union() {
                    polygon([[-board_height,0], [0,0], [0,h], [-2*thickness,h]]);
                    translate([0, pixel_height + thickness])
                        hook();
                    translate([0, h - 3*thickness])
                        hook();
                }

                // link notches
                for (i = [2:2:side_panel_num_notches-1]) {
                    translate([-notch_width*i, thickness])
                        square([notch_width, thickness]);
                }
            }
        }
    }
}


module unmounted_support_link() {
    color(wood) {
        linear_extrude(height=thickness) {
            difference() {
                len = (pixels_h-3)*pixel_width + thickness;
                square([len, board_height]);
                
                // unmounted support notches
                for (i = [0:2:side_panel_num_notches-1]) {
                    translate([0, notch_width*i])
                        square([thickness, notch_width]);
                    translate([len - thickness, notch_width*i])
                        square([thickness, notch_width]);
                }
            }
        }
    }
}


module extension_panel_2d() {
    difference() {
        square([extension_width - kerf, board_width]);
        
        // side panel notches
        for (i = [0:pixels_v]) {
            translate([0, i*pixel_width - bp_notch_length])
                square([thickness, 2*bp_notch_length + thickness]);
        }
        
        // top & bottom panel notches
        translate([extension_width - bp_notch_length, 0])
            square([bp_notch_length, thickness]);
        translate([extension_width - bp_notch_length, board_width - thickness])
            square([bp_notch_length, thickness]);
        square([extension_width - pixel_width + bp_notch_length + thickness, thickness]);
        translate([0, board_width - thickness])
            square([extension_width - pixel_width + bp_notch_length + thickness, thickness]);
    }
}


module extension_back_panel() {
    // takedown back panel for maintenance
    color(wood) {
        linear_extrude(height=thickness) {
            difference() {
                extension_panel_2d();

                // screw holes
                for (i = [1, pixels_v-1]) {
                    translate([extension_width - thickness, 
                                        pixel_height*i + thickness/2])
                        circle(1);
                }

                // air vents
                for (i = [0:vents_number-1]) {
                    translate([(extension_width - 5*thickness + vents_width)/2,
                                            3*thickness + (2*i+1)*vents_width])
                        air_vents_2d();
                }
                

                // power cable hole
                translate([thickness + 0.5*power_cable_hole_radius, thickness + 0.5*power_cable_hole_radius])
                    circle(1.25*power_cable_hole_radius);
            }
        }
    }
}


module extension_front_panel() {
    // PCB support panel
    color(wood) {
        linear_extrude(height=thickness) {
            difference() {
                union() {
                    extension_panel_2d();
                    translate([extension_width - kerf, thickness])
                        square([kerf + thickness, board_width - 2*thickness]);                
                }

                // separator_v0 notches
                for (i = [0:pixels_v]) {
                    translate([extension_width, i*pixel_width - bp_notch_length])
                    square([thickness, 2*bp_notch_length + thickness]);
                }

                // button cables hole
                interval = (extension_width)/(num_touch_buttons+1);
                translate([interval - thickness/2, buttons_height + pixel_height*0.25])
                    square([extension_width - interval - thickness, pixel_height/4]);
                
                // button pin holes
                for (i = [1:num_touch_buttons]) {
                    translate([i*interval, buttons_height])
                        circle(0.25);
                }
                
                // PIR hole
                translate([pcb_x + pcb_width - 24.8, pcb_y + 72.6])
                    circle(12 + 0.25);
                
                // antenna hole
                ant_hole_y = cable_clearance/2 + pcb_length;
                translate([thickness*3, ant_hole_y])
                    square([extension_width - thickness*5,
                                            board_width - 3*thickness - ant_hole_y]);

                // PCB mount holes
                translate([pcb_x, pcb_y]) {
                    mh_radius = 1;
                    translate([pcb_width - 4.6, 16])
                        circle(mh_radius);
                    translate([pcb_width - 35.5, 56.4])
                        circle(mh_radius);
                    translate([pcb_width - 28.5, 112.6])
                        circle(mh_radius);
                    translate([pcb_width - 21, 112.6 + 10*2.25])
                        circle(mh_radius);
                }
            }
        }
    }
}


module back_panel() {
    color(wood) {
        linear_extrude(height=thickness) {
            difference() {
                square([board_length - extension_width, board_width]);

                // vertical wall mount holes
                translate([(pixels_h-0.5)*pixel_width, pixel_height - (pixel_height-thickness - led_width)/4])
                    rotate([0, 0, -90])
                        wall_mount_hole();
                translate([(pixels_h-0.5)*pixel_width, 
                                        board_width - pixel_height + (pixel_height-thickness - led_width)/4])
                    rotate([0, 0, -90])
                        wall_mount_hole();
                
                // horizontal wall mount holes
                translate([2*pixel_width - (pixel_width-thickness - led_width)/4,
                                                board_width - pixel_height/2 + led_width/2 + 2])
                    wall_mount_hole();
                translate([(pixels_v)*pixel_width + thickness + (pixel_width-thickness - led_width)/4,
                                                board_width - pixel_height/2 + led_width/2 + 2])
                    wall_mount_hole();
                
                // side panel notches
                for (i = [0:pixels_v]) {
                    translate([board_length - extension_width - thickness, i*pixel_width - bp_notch_length])
                        square([thickness, 2*bp_notch_length + thickness]);
                }

                // top & bottom panel notches
                for (i = [0:pixels_h]) {
                    translate([i*pixel_width - bp_notch_length, 0])
                        square([2*bp_notch_length + thickness, thickness]);
                    translate([i*pixel_width - bp_notch_length, board_width - thickness])
                        square([2*bp_notch_length + thickness, thickness]);
                }
                
                // V separators notches
                for (i = [-1:pixels_v-1] ) {
                    for (j = [0:pixels_h-1]) {
                        translate([thickness/2 + j*pixel_width, pixel_height + thickness/2 + i*pixel_height])
                            square([thickness, 2*bp_notch_length + thickness], center=true);
                    }
                }
                // H separator notches
                for (i = [0:pixels_v-2] ) {
                    translate([thickness/2 + bp_notch_length/2, pixel_height + thickness/2 + i*pixel_height])
                        square([bp_notch_length + thickness, thickness], center=true);
                    for (j = [1:pixels_h]) {
                        translate([thickness/2 + j*pixel_width, pixel_height + thickness/2 + i*pixel_height])
                            square([2*bp_notch_length + thickness, thickness], center=true);
                    }
                }

                // unmounted support holes
                for (x = [1, pixels_h-2]) {
                    for (y = [1, pixels_v-2]) {
                        translate([x*pixel_width + thickness, y*pixel_height + thickness])
                            square([thickness, 3*thickness]);
                    }
                }

            }
        }
    }
}


module led_mark() {
    // led strip position
    for (i = [0: pixels_v-1]) {
        translate([-kerf, thickness + i*pixel_height + (pixel_height-thickness-led_width)/2 - kerf])
            square([led_interval*pixels_h + 2*kerf, led_width + 2*kerf]);
    }
}


module extension_front_panel_veneer() {
    color(cherrywood) {
        linear_extrude(height=veneer_thickness) {
            difference() {
                square([extension_width, board_width]);
                
                // PIR lens hole
                translate([pcb_x + pir_length/2, pcb_y + 58.4 + pir_width/2])
                    circle(pir_lens_radius + 0.1);
            }
        }
    }
}


module front_panel_veneer() {
    color(sycomore) {
        linear_extrude(height=veneer_thickness) {
            union() {
                if (!front_panel_bicolor) {
                    square([board_length, board_width]);
                }
                translate([extension_width, 0])
                    square([board_length - extension_width, board_width]);
            }
        }
    }
}

module front_panel_veneer_button() {
    for (i = [0:num_touch_buttons-1]) {
        translate([(extension_width)/(num_touch_buttons+1)*(i+1), 0])
            circle(touch_button_radius);
    }
}

module front_panel_veneer_button_detail() {
    // square
    if (num_touch_buttons > 0) {
        translate([(extension_width)/(num_touch_buttons+1) - 3, -3])
            square([6, 6]);
    }
    // triangle
    if (num_touch_buttons > 1) {
        translate([(extension_width)/(num_touch_buttons+1)*2, 0])
            polygon([[-3,-3], [3,-3], [0,3]], paths=[[0,1,2]]);
    }
    // cross
    if (num_touch_buttons > 2) {
        translate([(extension_width)/(num_touch_buttons+1)*3, 0])
            union() {
                polygon([[-2.9,-3], [-3,-2.9], [2.9,3], [3,2.9]], paths=[[0,1,2,3]]);
                polygon([[-2.9,3], [-3,2.9], [2.9,-3], [3,-2.9]], paths=[[0,1,2,3]]);
            }
    }
    // circle
    if (num_touch_buttons > 3) {
        translate([(extension_width)/(num_touch_buttons+1)*4, 0])
            circle(3);
    }
}

module led_strip() {
    union() {
        for (i = [0:pixels_h-1]) {
            translate([i*led_interval, 0, 0])
                LED_ADA1376();
        }
    }
}

module v_panel_2d() {
    difference() {
        square([board_height, board_width]);
        
        // top & bottom side notches
        for (i = [0:2:side_panel_num_notches-1]) {
            translate([notch_width*i, 0])
                square([notch_width, thickness]);
            translate([notch_width*i, board_width - thickness])
                square([notch_width, thickness]);
        }

        // back panel notches
        for (i = [0:pixels_v]) {
            translate([0, thickness + bp_notch_length + i*pixel_width])
                square([thickness, pixel_height-2*bp_notch_length-thickness]);
        }
    }
}


module left_panel() {
    color(wood) {
        linear_extrude(height=thickness) {
            difference() {
                v_panel_2d();

                // front panel notches
                for (i = [0:pixels_v]) {
                    translate([board_height - thickness,
                                        thickness + bp_notch_length + i*pixel_width, 0])
                        square([thickness, pixel_height-2*bp_notch_length-thickness]);
                }

                // air vents
                for (i = [0:vents_number-1]) {
                    translate([3*thickness+vents_width/2, 
                                                board_width - (2*i+1)*vents_width - 3*thickness])
                        air_vents_2d();
                }

                // power cable hole
                if (power_cable_position == 0 || power_cable_position == 1 ) {
                    translate([thickness + 1.5*power_cable_hole_radius,
                                                        thickness + 1.5*power_cable_hole_radius])
                        circle(power_cable_hole_radius);
                }
            }
        }
    }
}


module right_panel() {
    color(wood) {
        linear_extrude(height=thickness) {
            difference() {
                v_panel_2d();
                // H separator notches
                for (i = [1:pixels_v-1]) {
                    for (j = [1:2:side_panel_num_notches-1]) {
                        translate([notch_width*j, pixel_height*i])
                            square([notch_width, thickness]);
                    }
                }
            }
        }
    }
}

module h_panel_2d() {
    difference() {
        square([board_length, board_height]);

        // back panel notches
        for (i = [-1:pixels_h]) {
            translate([extension_width + thickness + bp_notch_length + i*pixel_width, 0])
                square([pixel_width-2*bp_notch_length-thickness, thickness]);

        }

        // front panel notches
        translate([extension_width + thickness + bp_notch_length - pixel_width,
                                                            board_height - thickness])
                square([pixel_width-2*bp_notch_length-thickness, thickness]);

        // V separator notches
        for (i = [0:pixels_h]) {
            for (j = [1:2:side_panel_num_notches-1]) {
                translate([extension_width + pixel_width*i, notch_width*j])
                    square([thickness, notch_width]);
            }
        }
        
        // left side notches
        for (j = [1:2:side_panel_num_notches-1]) {
            translate([0, notch_width*j])
                square([thickness, notch_width]);
        }
    }
}

module top_panel() {
    color(wood) {
        linear_extrude(height=thickness) {
            h_panel_2d();
        }
    }
}


module bottom_panel() {
    color(wood) {
        linear_extrude(height=thickness) {
            difference() {
                h_panel_2d();
                // air vents
                for (i = [0:vents_number-1]) {
                    translate([thickness + (extension_width - thickness - vents_width*(2*vents_number-1))/2 
                                                                + (2*i+1)*vents_width, 3*thickness+vents_width/2])
                        rotate([0, 0, 90])
                            air_vents_2d();
                }

                // power cable hole
                if (power_cable_position == 0 || power_cable_position == 2 ) {
                    translate([thickness + 1.5*power_cable_hole_radius,
                                                    thickness + 1.5*power_cable_hole_radius])
                        circle(power_cable_hole_radius);
                }
            }
        }
    }
}

module separator_v_2d() {
    difference() {
        square([board_height, board_width]);
        
        // back panel notches
        for (i = [0:pixels_v-1]) {
            translate([0, thickness + bp_notch_length + i*pixel_height])
                square([thickness, pixel_height-2*bp_notch_length-thickness]);
        
        // H separators notches
        for (i = [1:pixels_v-1])
            translate([0, i*pixel_height])
                square([board_height/2, thickness]);
        }

        // top & bottom side notches
        for (i = [0:2:side_panel_num_notches-1]) {
            translate([notch_width*i, 0])
                square([notch_width, thickness]);
            translate([notch_width*i, board_width - thickness])
                square([notch_width, thickness]);
        }

        // led strip notches
        for (i = [0: pixels_v-1]) {
            translate([thickness,
                        thickness + i*pixel_height + (pixel_height-thickness-led_width)/2])
                square([led_height, led_width]);
        }
    }
}

module separator_v() {
    color(wood) {
        linear_extrude(height=thickness) {
            separator_v_2d();
        }
    }
}

module separator_v0() {
    color(wood) {
        linear_extrude(height=thickness) {
            difference() {
                separator_v_2d();

                // front panel notches
                for (i = [0:pixels_v]) {
                    translate([board_height - thickness,
                                        thickness + bp_notch_length + i*pixel_width, 0])
                        square([thickness, pixel_height-2*bp_notch_length-thickness]);
                }

                // led cable notches
                for (i = [0: pixels_v-1]) {
                    translate([thickness,
                                thickness + i*pixel_height + (pixel_height-thickness-led_width)/2])
                        square([2, led_width]);
                }
            }
        }
    }
}

module separator_h_2d() {
    difference() {
        square([board_length - extension_width, board_height]);
        for (i = [0:pixels_h-1]) {
            // back panel notches
            translate([thickness + bp_notch_length + i*pixel_width, 0])
                square([pixel_width-2*bp_notch_length-thickness, thickness]);
            // V separators notches
            translate([i*pixel_width, board_height/2])
                square([thickness, board_height/2]);
        }
        // right side notches
        for (i = [0:2:side_panel_num_notches]) {
            translate([board_length - extension_width - thickness, notch_width*i])
                square([thickness, notch_width]);
        }        

        // led data cable notch
        hole_size = 1.5;
        translate([board_length - extension_width - thickness - hole_size, thickness])
            square(hole_size);
    }
}
module separator_h() {
    color(wood) {
        linear_extrude(height=thickness) {
            separator_h_2d();
        }
    }
}

module separator_h_hooked() {
    color(wood) {
        linear_extrude(height=thickness) {
            difference() {
                separator_h_2d();

                for (x = [1, pixels_h-2]) {
                    // unmounted support hook hole
                    translate([x*pixel_width + thickness, 2*thickness])
                        square(thickness);
                    // cap notch
                    translate([x*pixel_width + thickness, 0])
                        square(thickness);
                }
            }
        }
    }
}

module touch_button(radius) {
    union() {
        circle(radius);
        translate([-0.5, 0])
            square([1, pixel_height/4]);
    }
}

module touch_buttons_engrave() {
    for (i = [0:num_touch_buttons-1]) {
        translate([(extension_width)/(num_touch_buttons+1)*(i+1), 0])
            touch_button(touch_button_radius + 1);
    }
}



if (render_3d) {

    // back panel
    if (render_back_panel) {
        extension_back_panel();
        translate([extension_width, 0, 0])
            back_panel();
        if (render_mark) {
            translate([extension_width + thickness/2, 0, thickness])
                laser_mark_style()
                    led_mark();
        }
    }

    // unmounted support
    x_umsupport = extension_width + pixel_width + 2*thickness;
    if (render_unmounted_support) {
        for (x = [x_umsupport, x_umsupport + (pixels_h-3)*pixel_width]) {
            translate([x, 0, -explosion])
                rotate([0, -90, 0])
                    unmounted_support();
        }
        translate([x_umsupport - thickness, thickness, -explosion])
            rotate([-90, 0, 0])
                unmounted_support_link();
    }
    else {
        for (x = [x_umsupport, x_umsupport + (pixels_h-3)*pixel_width]) {
            for (y = [1, pixels_v-2]) {
                translate([x - thickness, y*(pixel_height) + thickness, 3*thickness - explosion])
                    rotate([0, 90, 0])
                        unmounted_support_cap();
            }
        }
    }

    // extension front panel
    translate([0, 0, board_height - thickness + explosion*4])
        extension_front_panel();
    if (render_engrave) {
        translate([0, buttons_height, board_height + 4*explosion]) 
            laser_engrave_style() touch_buttons_engrave();
    }

    // side panels
    translate([thickness - explosion, 0, 0])
        rotate([0, -90, 0])
            left_panel();
    translate([board_length + explosion, 0, 0])
        rotate([0, -90, 0])
            right_panel();
    translate([0, board_width + explosion, 0])
        rotate([90, 0, 0])
            top_panel();
    translate([0, thickness - explosion, 0])
        rotate([90, 0, 0])
            bottom_panel();

    // V separators
    translate([extension_width + thickness, 0, 2*explosion])
            rotate([0, -90, 0])
                separator_v0();
    for (i = [1:pixels_h-1]) {
        translate([extension_width + thickness + i*pixel_width, 0, 2*explosion])
            rotate([0, -90, 0])
                separator_v();
    }

    // H separators
    for (i = [1:pixels_v-1]) {
        translate([extension_width, thickness + i*pixel_height, explosion])
            rotate([90, 0, 0])
                if ((i == 1) || (i == pixels_v-2)) {
                    separator_h_hooked();
                }
                else {
                    separator_h();
                }
    }

    // led strips
    if (render_electronics) {
        for (i = [0: pixels_v-1]) {
            translate([extension_width + thickness/2,
                    thickness + i*pixel_height + (pixel_height-thickness-led_width)/2, thickness])
                led_strip();
        }
    }

    // PCBs
    if (render_electronics) {
        translate([pcb_x + pcb_width, pcb_y, board_height - thickness])
            rotate([0, 180, 0])
                PCB_MB2();
        translate([pcb_x, thickness + cable_clearance/2 + 58.4, board_height - pir_lens_height])
            PIR_SBC();
    }

    // front panel veneer
    if (render_front_panel_veneer) {
        translate([0, 0, board_height + 4*explosion])
            if (front_panel_bicolor) {
                extension_front_panel_veneer();
                front_panel_veneer();
            }
            else {
                front_panel_veneer();
            }
        if (render_mark) {
            translate([0, buttons_height, board_height + veneer_thickness + 4*explosion])
                laser_mark_style()
                    front_panel_veneer_button();
            translate([0, buttons_height, 
                            board_height + veneer_thickness + mark_depth + 4*explosion])
                laser_mark_style()
                    front_panel_veneer_button_detail();
        }
        if (render_etch) {
            translate([thickness/2, thickness/2, board_height + veneer_thickness + 4*explosion])
                laser_etch_style()
                    logo(logo_scale_factor);
        }
    }
}
else {
    // position elements for laser cutting
    // each element must be independant otherwise children management removes usefull lines
    // on generate2d.py - this prevents usage of for loops

    laser_mirror() {
        panel_height = 2*(board_width + kerf) + 6*(board_height + kerf);
        projection_renderer(render_index=render_index, render_etch=render_etch, 
                    render_mark=render_mark, render_engrave=render_engrave, kerf_width=kerf,
                    panel_height=panel_height, panel_horizontal=panel_horizontal,
                                        panel_vertical=panel_vertical) {

            // back panel
            if (render_back_panel) {
                extension_back_panel();
            }
            if (render_back_panel) {
                translate([extension_width, 0, 0])
                    back_panel();
            }
            if (render_back_panel && render_mark) {
                translate([extension_width + thickness/2 + kerf, 0, thickness])
                    laser_mark_style()
                        led_mark();
            }
            warn("generate too much paths - better add copyleft on inkscape");
            *if (render_back_panel && render_mark) {
                $fn = 1;
                translate([extension_width/2, (pixels_v-0.5)*pixel_height, thickness])
                    laser_mark_style()
                        copyleft();
            }

            // front panel
            translate([board_length + kerf, 0, 0])
                extension_front_panel();
            if (render_engrave) {
                translate([board_length + kerf, buttons_height, thickness])
                    laser_engrave_style()
                        touch_buttons_engrave();
            }

            // H side panels
            h_offset = board_width + kerf;
            translate([0, h_offset + board_height, thickness])
                rotate([180, 0, 0])
                    bottom_panel();
            translate([0, h_offset + board_height + kerf, 0])
                top_panel();

            // H separators
            if (pixels_v > 1) {
                translate([0, h_offset + 2*(board_height + kerf), 0])
                    separator_h();
            }
            
            // all elements below must be offseted to fit A3 sheet
            
            h_offset_a3 = h_offset + a3_fit_offset;
            // H separators
            if (pixels_v > 2) {
                translate([0, h_offset_a3 + 4*(board_height + kerf) - kerf, thickness])
                    rotate([180, 0, 0])
                        separator_h_hooked();
            }
            if (pixels_v > 3) {
                translate([0, h_offset_a3 + 4*(board_height + kerf), 0])
                    separator_h_hooked();
            }
            if (pixels_v > 4) {
                translate([0, h_offset_a3 + 6*(board_height + kerf) - kerf, thickness])
                    rotate([180, 0, 0])
                        separator_h();
            }
            if (pixels_v > 5) {
                translate([0, h_offset_a3 + 6*(board_height + kerf), 0])
                    separator_h();
            }
            assert(pixels_v <= 6, "Add more H separators !");

                        
            v_offset = h_offset_a3 + (pixels_v+1)*(board_height + kerf);
            // V separators
            translate([board_height, v_offset, thickness])
                rotate([0, 180, 0])
                    separator_v0();
            if (pixels_h > 1) {
                translate([1*(board_height+kerf), v_offset, 0])
                    separator_v();
            }
            if (pixels_h > 2) {
                translate([2*(board_height+kerf) + board_height, v_offset, thickness])
                    rotate([0, 180, 0])
                        separator_v();
            }
            if (pixels_h > 3) {
                translate([3*(board_height+kerf), v_offset, 0])
                    separator_v();
            }
            if (pixels_h > 4) {
                translate([4*(board_height+kerf) + board_height, v_offset, thickness])
                    rotate([0, 180, 0])
                        separator_v();
            }
            if (pixels_h > 5) {
                translate([5*(board_height+kerf), v_offset, 0])
                    separator_v();
            }
            if (pixels_h > 6) {
                translate([6*(board_height+kerf) + board_height, v_offset, thickness])
                    rotate([0, 180, 0])
                        separator_v();
            }
            if (pixels_h > 7) {
                translate([7*(board_height+kerf), v_offset, 0])
                    separator_v();
            }
            if (pixels_h > 8) {
                translate([8*(board_height+kerf) + board_height, v_offset, thickness])
                    rotate([0, 180, 0])
                        separator_v();
            }
            if (pixels_h > 9) {
                translate([9*(board_height+kerf) + board_height, v_offset, thickness])
                    rotate([0, 180, 0])
                        separator_v();
            }
            assert(pixels_h <= 10, "Add more V separators !");

            // V side panels
            translate([(pixels_h+1)*(board_height+kerf) - kerf, v_offset, thickness])
                rotate([0, 180, 0])
                    left_panel();
            translate([(pixels_h+1)*(board_height+kerf), v_offset, 0])
                right_panel();
            
            
            // unmounted supports
            umsupport_x = board_length - extension_width + 3*thickness + kerf;
            
            if (render_unmounted_support) {
                translate([(pixels_h+2)*(board_height+kerf), v_offset + board_width, 0])
                    rotate([0, 0, -90])
                        unmounted_support_link();
            }
            if (render_unmounted_support) {
                translate([umsupport_x + kerf, v_offset - kerf, 0])
                    rotate([0, 0, 180])
                        unmounted_support();
            }
            if (render_unmounted_support) {
                translate([umsupport_x + board_height + 3*thickness, 
                                        v_offset - um_support_h - kerf, 0])
                        unmounted_support();
            }
                
            cap_y = 4*thickness + kerf;
            translate([umsupport_x, v_offset - um_support_h + 7*thickness, 0])
                rotate([0, 0, 180])
                    unmounted_support_cap();
            translate([umsupport_x, v_offset - um_support_h + 7*thickness + cap_y, 0])
                rotate([0, 0, 180])
                    unmounted_support_cap();
            translate([umsupport_x, v_offset - um_support_h + 7*thickness + 2*cap_y, 0])
                rotate([0, 0, 180])
                    unmounted_support_cap();
            translate([umsupport_x, v_offset - um_support_h + 7*thickness + 3*cap_y, 0])
                rotate([0, 0, 180])
                    unmounted_support_cap();


            // front panel veneer
            fp_offset = -board_width - kerf - a3_fit_offset;

            if (render_front_panel_veneer && !front_panel_bicolor) {
                translate([0, fp_offset, 0])
                    front_panel_veneer();
            }
            if (render_front_panel_veneer && front_panel_bicolor) {
                translate([0, fp_offset, 0])
                    extension_front_panel_veneer();
            }
            if (render_front_panel_veneer && front_panel_bicolor) {
                translate([kerf, fp_offset, 0])
                    front_panel_veneer();
            }
            if (render_front_panel_veneer && render_etch) {
                translate([thickness/2, thickness/2 + fp_offset, veneer_thickness])
                    laser_etch_style()
                        logo(logo_scale_factor);
            }
            if (render_front_panel_veneer && render_mark) {
                translate([0, buttons_height + fp_offset, veneer_thickness])
                    laser_mark_style()
                        front_panel_veneer_button();
            }
            if (render_front_panel_veneer && render_mark) {
                translate([0, buttons_height + fp_offset, veneer_thickness + mark_depth])
                    laser_mark_style()
                        front_panel_veneer_button_detail();
            }
        }    
    }
}
