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

    hidden var cad = 0;
    hidden var cal = 0;
    hidden var speed = 0.0;
    hidden var avgSpeed = 0.0;
    hidden var hr = 0;
    hidden var distance = "0:00";
    hidden var elapsedTime = "0:00";
    hidden var gpsSignal = 0; //Signal 0 not avail ... 4 good
    hidden var x;
    hidden var y;
    hidden var y1;
    hidden var y2;
    var chartHR;
    var chartCAD;

    //! The given info object contains all the current workout
    function compute(info) {
    	speed = calcNullable(info.currentSpeed, 0.0) * 3.6;
    	avgSpeed = calcNullable(info.averageSpeed, 0.0) * 3.6;
    	cad = calcNullable(info.currentCadence, 0);
    	cal = calcNullable(info.calories, 0);
    	hr = calcNullable(info.currentHeartRate, 0);
        calculateDistance(info);
        calculateElapsedTime(info);
        gpsSignal = info.currentLocationAccuracy;
        chartHR.new_value(hr);
        chartCAD.new_value(cad);
    }
    
    function onUpdate(dc) {
        onUpdateCharts(dc);
        draw(dc);
        drawGrid(dc);
        drawGps(dc);   
    }

 	function initialize()
    {
        chartHR = new Chart();
        chartHR.set_max_range_minutes(2);
        chartCAD = new Chart();
        chartCAD.set_max_range_minutes(2);
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
    }

    function onLayout(dc) {
        // calculate values for grid
        y = dc.getHeight() / 2 + 5;
        y1 = dc.getHeight() / 4.7 + 5;
        y2 = dc.getHeight() - y1 + 10;
        x = dc.getWidth() / 2;
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
        dc.drawText(dc.getWidth() * 0.28 - 6, y2 - 10, HEADER_FONT, "SPD (km/h)", CENTER);
        
        setColor(dc, Graphics.COLOR_BLACK);
        dc.drawText(x, 38, Graphics.FONT_MEDIUM, getFormattedDate(Time.now()), CENTER);
        dc.drawText(dc.getWidth() * 0.79, y + 21, VALUE_FONT, elapsedTime, CENTER);
        dc.drawText(dc.getWidth() * 0.2, y + 21, VALUE_FONT, speed.format("%2.1f"), CENTER);

        txtVsOutline(x, y1 + 21, VALUE_FONT, cad.format("%d"), CENTER, Graphics.COLOR_BLACK, dc, 1);
        setColor(dc, Graphics.COLOR_ORANGE);
        dc.drawText(x, y - 10, HEADER_FONT, "CAD", CENTER);
        setColor(dc, Graphics.COLOR_DK_BLUE);
        dc.drawText(dc.getWidth() * 0.26 + 48, y + 21, VALUE_FONT, avgSpeed.format("%2.1f"), CENTER);
        dc.drawText(dc.getWidth() * 0.28 + 45, y2 - 10, HEADER_FONT, "AVG", CENTER);
        txtVsOutline(dc.getWidth() / 4.7, y1 + 21, VALUE_FONT, hr.format("%d"), CENTER, Graphics.COLOR_BLACK, dc, 1);
        setColor(dc, Graphics.COLOR_DK_RED);
        dc.drawText(dc.getWidth() / 4.7 - 2, y - 10, HEADER_FONT, "HR " + ((hr > 0) ? (chartHR.min.format("%d") + "-" + chartHR.max.format("%d")) : ""), CENTER);
        setColor(dc, Graphics.COLOR_DK_GREEN);
        dc.drawText(dc.getWidth() * 0.79, y1 + 21, VALUE_FONT, distance, CENTER);
        dc.drawText(dc.getWidth() * 0.80, y - 10, HEADER_FONT, "DIST (km)", CENTER);

        setColor(dc, Graphics.COLOR_GREEN);
        dc.drawText(x, y2 + 13, Graphics.FONT_MEDIUM, cal.format("%d"), CENTER);
        dc.drawText(x, y2 + 31, HEADER_FONT, "CAL", CENTER);
        setColor(dc, Graphics.COLOR_BLACK);
        drawBattery(dc);
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
        if (gpsSignal == 3 || gpsSignal == 4) {
            setColor(dc, Graphics.COLOR_DK_GREEN);
        } else {
            setColor(dc, Graphics.COLOR_DK_RED);
        }
        dc.drawText(x + 50, 37, HEADER_FONT, "GPS", CENTER);
        setColor(dc, Graphics.COLOR_BLACK);
    }
    
    function drawBattery(dc) {
        var yStart = 30;
        var xStart = x - 68;
        
        dc.drawRectangle(xStart, yStart, 29, 15);
        dc.drawRectangle(xStart + 1, yStart + 1, 27, 13);
        dc.fillRectangle(xStart + 29, yStart + 3, 2, 9);
        setColor(dc, Graphics.COLOR_DK_GREEN);
        for (var i = 0; i < (24 * System.getSystemStats().battery / 100); i = i + 3) {
            dc.fillRectangle(xStart + 3 + i, yStart + 3, 2, 9);    
        }
        
     //   setColor(dc, Graphics.COLOR_DK_GREEN);
     //   dc.drawText(xStart+18, yStart+6, HEADER_FONT, format("$1$%", [battery.format("%d")]), CENTER);
             
     //   setColor(dc, Graphics.COLOR_BLACK);
    }
    	
	function calcNullable(nullableValue, defaultValue) {
	   if (nullableValue != null) {
	   	return nullableValue;
	   } else {
	   	return defaultValue;
   	   }	
	}

    function calculateDistance(info) {
        if (info.elapsedDistance != null && info.elapsedDistance > 0) {
            var distanceKm = info.elapsedDistance / 1000;
            var distanceHigh = distanceKm >= 100.0;
            var distanceFullString = distanceKm.toString();
            var commaPos = distanceFullString.find(".");
            var floatNumber = 3;
            if (distanceHigh) {
            	floatNumber = 2;
            }
            distance = distanceFullString.substring(0, commaPos + floatNumber);
        }
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
    
    function getFormattedDate(moment) {
        var date = Calendar.info(moment, 0);
        var formattedDate = format("$1$:$2$",[date.hour, date.min.format("%02d")]);
        return formattedDate;
    }

}