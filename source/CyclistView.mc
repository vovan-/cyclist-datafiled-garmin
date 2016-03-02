using Toybox.WatchUi as Ui;
using Toybox.Graphics as Graphics;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.System as System;

var model;

//! Cyclist DataField with different parameters and some charts. All on single screen.
//!
//! @author vovan-
class CyclistView extends Ui.DataField {

    hidden const CENTER = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
    hidden const HEADER_FONT = Graphics.FONT_XTINY;
    hidden const VALUE_FONT = Graphics.FONT_NUMBER_MEDIUM;

    // Config
    hidden var is24Hour = true;
    hidden var isDistMetric = true;
    hidden var isElevMetric = true;
    hidden var isSpdMetric = true;
    hidden var cad = 0;
    hidden var cal = 0;
    hidden var speed = 0.0;
    hidden var avgSpeed = 0.0;
    hidden var avgHR = 0;
    hidden var avgPWR = 0;
    hidden var elev = "0.0";
    hidden var hr = 0;
    hidden var distance = "0.00";
    hidden var elapsedTime = "0:00";
    hidden var gpsSignal = 0; //Signal 0 not avail ... 4 good
    hidden var x;
    hidden var y;
    hidden var y1;
    hidden var y2;
    var chartHR;
    var chartCAD;
    var chartCustom;

    var upperRightValue = 0;
    var bottomValue = 0;

    //! The given info object contains all the current workout
    function compute(info) {
    	speed = calcNullable(info.currentSpeed, 0.0);
    	avgSpeed = calcNullable(info.averageSpeed, 0.0);
    	cad = calcNullable(info.currentCadence, 0);
    	cal = calcNullable(info.calories, 0);
    	hr = calcNullable(info.currentHeartRate, 0);
    	avgHR = calcNullable(info.averageHeartRate, 0);
    	avgPWR = calcNullable(info.averagePower, 0);
        distance = calcUnit(calcNullable(info.elapsedDistance, 0.0), isDistMetric, 1.0/1000, 1.0/1610);
        elev = calcUnit(calcNullable(info.altitude, 0.0), isElevMetric, 1, 3.28084);
        calculateElapsedTime(info);
        gpsSignal = info.currentLocationAccuracy;
        chartHR.new_value(hr);
        chartCAD.new_value(cad);
        var value = null;
        if (upperRightValue == 0 || upperRightValue == 1) {
            value = elev.toFloat();
        } else if (upperRightValue == 2) {
            value = avgHR;
        } else if (upperRightValue == 3) {
            value = avgPWR;
        }
        chartCustom.new_value(value);
    }
    
    function onUpdate(dc) {
        onUpdateCharts(dc);
        draw(dc);
        drawGrid(dc);
        drawGps(dc);
        drawBattery(dc);
    }

 	function initialize()
    {
        bottomValue = Application.getApp().getProperty("bottomValue");
        if (bottomValue == null) {
            bottomValue = 0;
        }
        upperRightValue = Application.getApp().getProperty("upperRightValue");
        if (upperRightValue == null) {
            upperRightValue = 4;
        }
        chartHR = new Chart();
        chartHR.set_max_range_minutes(2);
        chartCAD = new Chart();
        chartCAD.set_max_range_minutes(2);
        chartCustom = new Chart();
        chartCustom.set_max_range_minutes(2);
    }

    //! Update the view
    function onUpdateCharts(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        chartHR.draw(dc, [0, 53, dc.getWidth() - 138, dc.getHeight() - 120],
                   Graphics.COLOR_BLACK, Graphics.COLOR_DK_RED, 0,
                   true, false, true);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        chartCAD.draw(dc, [dc.getWidth() - 135, 53, dc.getWidth() - 84, dc.getHeight() - 120],
                   Graphics.COLOR_BLACK, Graphics.COLOR_ORANGE, 0,
                   true, false, true);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        chartCustom.draw(dc, [dc.getWidth() - 81, 53, dc.getWidth() - 1, dc.getHeight() - 120],
                   Graphics.COLOR_BLACK, Graphics.COLOR_DK_GREEN, 0,
                   true, false, true);
    }

    function onLayout(dc) {
        populateConfigFromDeviceSettings();
        // calculate values for grid
        y = dc.getHeight() / 2 + 5;
        y1 = dc.getHeight() / 4.7 + 5;
        y2 = dc.getHeight() - y1 + 10;
        x = dc.getWidth() / 2;
    }

    function populateConfigFromDeviceSettings() {
        isDistMetric = System.getDeviceSettings().distanceUnits == System.UNIT_METRIC;
        isElevMetric = System.getDeviceSettings().elevationUnits == System.UNIT_METRIC;
        isSpdMetric = System.getDeviceSettings().paceUnits == System.UNIT_METRIC;
        is24Hour = System.getDeviceSettings().is24Hour;
    }
    //! API functions
    
    //! function setLayout(layout) {}
    //! function onShow() {}
    //! function onHide() {}

    function drawGrid(dc) {
        setColor(dc, Graphics.COLOR_LT_GRAY);
        dc.setPenWidth(2);
        dc.drawLine(0, y1, dc.getWidth(), y1);
        dc.drawLine(0, y, dc.getWidth(), y);
        dc.drawLine(x+27, y, x+27, y2);
        dc.drawLine(x-27, y1, x-27, y); 
        dc.drawLine(x+27, y1, x+27, y); 
        dc.drawLine(0, y2, dc.getWidth(), y2);  
        dc.setPenWidth(1);    
    }

    function draw(dc) {
        setColor(dc, Graphics.COLOR_DK_GRAY);
        dc.drawText(x, 8, HEADER_FONT, "TOD", CENTER);
        dc.drawText(dc.getWidth() * 0.80, y2 - 10, HEADER_FONT, "TIMER", CENTER);
        
        setColor(dc, Graphics.COLOR_BLACK);

        var clockTime = System.getClockTime();
        var time, ampm, timeX;
        if (is24Hour) {
            time = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%.2d")]);
            ampm = "";
            timeX = x;
        } else {
            time = Lang.format("$1$:$2$", [calculateAmPmHour(clockTime.hour), clockTime.min.format("%.2d")]);
            ampm = (clockTime.hour < 12) ? "am" : "pm";
            timeX = x - 10;
        }
        dc.drawText(timeX, 38, Graphics.FONT_MEDIUM, time, CENTER);
        dc.drawText(timeX + 35, 42, HEADER_FONT, ampm, CENTER);
        dc.drawText(dc.getWidth() * 0.79, y + 21, VALUE_FONT, elapsedTime, CENTER);
        dc.drawText(dc.getWidth() * 0.26 + 48, y + 21, VALUE_FONT, calculateSpeed(speed).format("%2.1f"), CENTER);
        dc.drawText(dc.getWidth() * 0.28 + 40, y2 - 10, HEADER_FONT, "SPD (" +  (isSpdMetric ? "km" : "mi")  + "/h)", CENTER);

        txtVsOutline(x, y1 + 21, VALUE_FONT, cad.format("%d"), CENTER, Graphics.COLOR_BLACK, dc, 1);
        setColor(dc, Graphics.COLOR_ORANGE);
        dc.drawText(x, y - 10, HEADER_FONT, "CAD", CENTER);
        setColor(dc, Graphics.COLOR_DK_BLUE);

        dc.drawText(dc.getWidth() * 0.28 - 16, y2 - 10, HEADER_FONT, "AVG", CENTER);
        dc.drawText(dc.getWidth() * 0.2, y + 21, VALUE_FONT, calculateSpeed(avgSpeed).format("%2.1f"), CENTER);
        txtVsOutline(dc.getWidth() / 4.7, y1 + 21, VALUE_FONT, hr.format("%d"), CENTER, Graphics.COLOR_BLACK, dc, 1);
        setColor(dc, Graphics.COLOR_DK_RED);
        dc.drawText(dc.getWidth() / 4.7 - 2, y - 10, HEADER_FONT, "HR " + ((hr > 0) ? (chartHR.min.format("%d") + "-" + chartHR.max.format("%d")) : ""), CENTER);
        setColor(dc, Graphics.COLOR_DK_GREEN);
        var value = "N/A";
        var text = "N/A";

        if (upperRightValue == 0) {
            value = distance;
            text = "DIST (" + (isDistMetric ? "km" : "mi") + ")";
        } else if (upperRightValue == 1) {
            value = elev;
            text = "ALT (" + (isElevMetric ? "m" : "ft") + ")";
        } else if (upperRightValue == 2) {
            value = avgHR.toString();
            text = "AVG HR";
        } else if (upperRightValue == 3) {
            value = avgPWR.toString();
            text = "AVG PWR";
        }
        
        txtVsOutline(dc.getWidth() * 0.79, y1 + 21, VALUE_FONT, value, CENTER, Graphics.COLOR_BLACK, dc, 1);
        setColor(dc, Graphics.COLOR_DK_GREEN);
        dc.drawText(dc.getWidth() * 0.80, y - 10, HEADER_FONT, text, CENTER);


        if (bottomValue == 0) {
	     	value = distance;
            text = "DIST (" + (isDistMetric ? "km" : "mi") + ")";
        } else if (bottomValue == 1) {
            value = elev;
            text = "ALT (" + (isDistMetric ? "m" : "ft") + ")";
        } else if (bottomValue == 2) {
            value = avgHR.toString();
            text = "AVG HR";
        } else if (bottomValue == 3) {
            value = avgPWR.toString();
            text = "AVG PWR";
        } else if (bottomValue == 4) {
            value = cal.toString();
            text = "CAL";
        }
        setColor(dc, Graphics.COLOR_GREEN);
        dc.drawText(x, y2 + 13, Graphics.FONT_MEDIUM, value, CENTER);
        dc.drawText(x, y2 + 31, HEADER_FONT, text, CENTER);
    }

    function txtVsOutline(x, y, font, text, pos, color, dc, delta) {
        setColor(dc, Graphics.COLOR_WHITE);
        dc.drawText(x + delta, y, font, text, pos);
        dc.drawText(x - delta, y, font, text, pos);
        dc.drawText(x, y + delta, font, text, pos);
        dc.drawText(x, y - delta, font, text, pos);
        setColor(dc, color);
        dc.drawText(x, y, font, text, pos);
    }

    function setColor(dc, color) {
    	dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    }


    function drawGps(dc) {
        if (gpsSignal < 2) {
            drawGpsSign(dc, 165, 29, Graphics.COLOR_BLUE, Graphics.COLOR_LT_GRAY, Graphics.COLOR_LT_GRAY);
        } else if (gpsSignal == 2) {
            drawGpsSign(dc, 165, 29, Graphics.COLOR_BLUE, Graphics.COLOR_LT_GRAY, Graphics.COLOR_LT_GRAY);
        } else if (gpsSignal == 3) {
            drawGpsSign(dc, 165, 29, Graphics.COLOR_BLUE, Graphics.COLOR_BLUE, Graphics.COLOR_LT_GRAY);
        } else {
            drawGpsSign(dc, 165, 29, Graphics.COLOR_BLUE, Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
        }
    }


    function drawGpsSign(dc, xStart, yStart, color1, color2, color3) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(xStart - 1, yStart + 11, 8, 10);
        dc.setColor(color1, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(xStart, yStart + 12, 6, 8);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(xStart + 6, yStart + 7, 8, 14);
        dc.setColor(color2, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(xStart + 7, yStart + 8, 6, 12);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(xStart + 13, yStart + 3, 8, 18);
        dc.setColor(color3, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(xStart + 14, yStart + 4, 6, 16);
    }
    
    function drawBattery(dc) {
        var yStart = 34;
        var xStart = x - 78;

        setColor(dc, Graphics.COLOR_BLACK);
        dc.drawRectangle(xStart, yStart, 29, 15);
        dc.drawRectangle(xStart + 1, yStart + 1, 27, 13);
        dc.fillRectangle(xStart + 29, yStart + 3, 2, 9);
        setColor(dc, Graphics.COLOR_BLUE);
        for (var i = 0; i < (24 * System.getSystemStats().battery / 100); i = i + 3) {
            dc.fillRectangle(xStart + 3 + i, yStart + 3, 2, 9);    
        }
    }
    	
	function calcNullable(nullableValue, defaultValue) {
	   if (nullableValue != null) {
	   	return nullableValue;
	   } else {
	   	return defaultValue;
   	   }	
	}

    function calcUnit(value, isMetric, metricCf, nonMetricCf) {
        var valInUnit =  (isMetric ? value * metricCf : value * nonMetricCf);
        var valHigh = valInUnit >= 100.0;
        var valFullString = valInUnit.toString();
        var commaPos = valFullString.find(".");
        var floatNumber = 3;
        if (valHigh) {
            floatNumber = 2;
        }
        return valFullString.substring(0, commaPos + floatNumber);
    }

    function calculateElapsedTime(info) {
        if (info.elapsedTime != null && info.elapsedTime > 0) {
            var hours = null;
            var minutes = info.elapsedTime / 1000 / 60;
            var seconds = info.elapsedTime / 1000 % 60;
            
            if (minutes >= 60) {
                hours = minutes / 60;
                minutes = minutes % 60;
            }
            
            if (hours == null) {
                elapsedTime = minutes.format("%d") + ":" + seconds.format("%02d");
            } else {
                elapsedTime = hours.format("%d") + ":" + minutes.format("%02d");// + ":" + seconds.format("%02d");
            }
//            var options = {:seconds => (info.elapsedTime / 1000)};
        }
    }

    function calculateSpeed(speedMetersPerSecond) {
        var kmOrMilesPerHour = speedMetersPerSecond * 3600.0 / (isSpdMetric ? 1000 : 1610);
        return kmOrMilesPerHour;
    }

    function calculateAmPmHour(hour) {
        if (hour == 0) {
            return 12;
        } else if (hour > 12) {
            return hour - 12;
        }
        return hour;
    }
}