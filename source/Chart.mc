//using Toybox.Math as Math;
//using Toybox.Application as App;

//! @author vovan-
class Chart {



//    var ignore_sd = null;

    //var current = null;
    var values;
    var range_mult;
    var range_mult_max;
//    var range_expand = false;
    var range_mult_count = 0;
    var range_mult_count_not_null = 0;
    var next = 0;
    var min = 200;
    var max = 10;
//    var min_i;
//    var max_i;
//    var mean;
//    var sd;

    function initialize() {
        set_range_minutes(2);
    }

    function set_range_minutes(range) {
        var values_size = 40; // Must be even
        var new_mult = range * 60 / values_size;
        if (new_mult != range_mult) {
            range_mult = new_mult;
            values = new [values_size];
//            update_stats();
        }
    }

    function set_max_range_minutes(range) {
        range_mult_max = range * 60 / values.size();
    }


    function new_value(new_value) {
        if (new_value != null) {
            next += new_value;
            range_mult_count_not_null++;
            if (new_value < min && new_value > 0) {
                // min_i = i;
                min = new_value;
            }

            if (new_value > max) {
                //  max_i = i;
                max = new_value;
            }
        }
        range_mult_count++;
        if (range_mult_count >= range_mult) {
//            var expand = range_expand && range_mult < range_mult_max &&
//                values[0] == null && values[1] != null;

            for (var i = 1; i < values.size(); i++) {
                values[i-1] = values[i];
            }
            values[values.size() - 1] = range_mult_count_not_null == 0 ?
                null : (next / range_mult_count_not_null);
            next = 0;
            range_mult_count = 0;
            range_mult_count_not_null = 0;



//            if (expand) {
//                do_range_expand();
 //           }

//            update_stats();
        }
    }

//    function do_range_expand() {
//        var sz = values.size();
//        for (var i = sz - 1; i >= sz / 2; i--) {
//            var old_i = i * 2 - sz;
//            var total = 0;
//            var n = 0;
//            for (var j = old_i; j < old_i + 2; j++) {
//                if (values[j] != null) {
//                    total += values[j];
//                    n++;
//                }
//            }
//            values[i] = (n > 0) ? total / n : null;
//        }
//        for (var i = 0; i < sz / 2; i++) {
//            values[i] = null;
//        }
//        range_mult *= 2;
//    }

//    function update_stats() {
//        min = 99999999;
//        max = -99999999;
//        min_i = 0;
//        max_i = 0;
//
//        var m = 0f;
//        var s = 0f;
//        var total = 0f;
//        var n = 0;
//
//        for (var i = 0; i < values.size(); i++) {
//            var item = values[i];
//            if (item != null) {
//                // Welford
//                n++;
//                var m2 = m;
//                m += (item - m2) / n;
//                s += (item - m2) * (item - m);
//                total += item;
//            }
//        }
//        if (n == 0) {
//            mean = null;
//            sd = null;
//        }
//        else {
//            mean = total / n;
//            sd = Math.sqrt(s / n);
//        }
//
//        var ignore = null;
//        if (sd != null && ignore_sd != null) {
//            ignore = ignore_sd * sd;
//        }
//
//        for (var i = 0; i < values.size(); i++) {
//            var item = values[i];
//            if (item != null) {
//                if (ignore != null &&
//                    (item > mean + ignore || item < mean - ignore)) {
//                    continue;
//                }
//                if (item < min) {
//                    min_i = i;
//                    min = item;
//                }
//
//                if (item > max) {
//                    max_i = i;
//                    max = item;
//                }
//            }
//        }
//    }


    function item_x(i, orig_x, width, size) {
        return orig_x + i * width / (size - 1);
    }

    function x_item(x, orig_x, width, size) {
        return (x - orig_x) * (size - 1) / width;
    }

    function item_y(item, orig_y, height, min, max) {
        return orig_y - height * (item - min) / (max - min);
    }

    function draw(dc, x1y1x2y2,
                  line_color, block_color,
                  range_min_size, draw_min_max, draw_axes,
                  strict_min_max_bounding) {
        // Work around 10 arg limit!
        var x1 = x1y1x2y2[0];
        var y1 = x1y1x2y2[1];
        var x2 = x1y1x2y2[2];
        var y2 = x1y1x2y2[3];

        var range_border = 5;

        var width = x2 - x1;
        var height = y2 - y1;
//        var x = x1;
//        var x_next;
        var item;

        //var min = 40;//model.min;
        //var max = 150;//model.max;

        var range_min = min - range_border;
        var range_max = max + range_border;
        if (range_max - range_min < range_min_size) {
            range_max = range_min + range_min_size;
        }

        var x_old = null;
        var y_old = null;
        for (var x = x1; x <= x2; x++) {
            item = values[x_item(x, x1, width, values.size())];
            if (item != null && item > range_max) {
                dc.setColor(block_color, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x, y1, x, y2);
                x_old = null;
                y_old = null;
            }
            else if (item != null && item >= range_min) {
                var y = item_y(item, y2, height, range_min, range_max);
                dc.setColor(block_color, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x, y, x, y2);
                if (x_old != null) {
                    dc.setColor(line_color, Graphics.COLOR_TRANSPARENT);
                    dc.drawLine(x_old, y_old, x, y);
                    // TODO is the below line needed due to a CIQ bug
                    // or some subtlety I don't understand?
                    dc.drawPoint(x, y);
                }
                x_old = x;
                y_old = y;
            }
            else {
                x_old = null;
                y_old = null;
            }
        }
    }
}
