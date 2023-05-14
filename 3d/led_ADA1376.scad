include<led_ADA1376_dimensions.scad>;

module LED_ADA1376() {

    white = [0.9, 0.9, 0.9];

    module strip() {
        color(white) {
            cube([led_interval, led_width, led_height]);
        }
    }

    module led() {
        color([0.8, 0.8, 0.8]) {
                cube([5, 5, 1]);
        }
    }

    strip();
    translate([(led_interval - 5)/2, (led_width - 5)/2, led_height])
        led();
}

// Example usage:
LED_ADA1376();