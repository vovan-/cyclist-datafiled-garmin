# CyclistChartsField

![CyclistChartsField Screenshot](/docs/img/CyclistChartsField-emulator.png)

## Feedback

Any feedback, questions and answers please post on the corresponding forum thread (Garmin users are by default a Garmin Forum user):
https://forums.garmin.com/showthread.php?333992-Data-Field-CyclistChartsField
Developers have no access to provide response for Ratings and Reviews on Garmin App store.

===============================================

CyclistChartsField Data Filed for Garmin Connect IQ store.
This is a free complex Data Field for the Fenix 3 watch that shows multiple values and two charts on a single field. 
CyclistChartsField is open source, its code can be found at github: https://github.com/vovan-/cyclist-datafiled-garmin

The Data Field is based on two other Data Fields. Special thanks for developers of the following ConnectIQ projects:
https://apps.garmin.com/en-US/apps/aacfc2de-b61e-40cc-a83d-52f46f9d263d
https://apps.garmin.com/en-US/apps/dc4c99a1-0886-42f5-8605-f952956e715b

Release versions are published in the [Garmin App Store](https://apps.garmin.com/en-US/apps/82e3141d-9846-4bcf-bf72-f8bda597efc0)

===============================================



## Features
* Speed: speed in km/h or mi/h based on system settings;
* Average speed: average speed over the whole activity;
* Cadence: your current cadence with a chart on the background (last minute data);
* HR: your current heart rate with a chart on the background (last minute data);
* Distance: elapsed distance in km or miles based on system settings;
* Timer: duration of the activity in [hh:]mm:ss;
* GPS: GPS status - antenna bar;
* Battery: visualization of battery percentage as indicator bar;
* Time of the day;
* Unit settings applied only before starting the activity. During activity settings won't apply.

===============================================

## Installation Instructions
A Data Field needs to be set up within the settings for a given activity (like Bike)

* Long Press UP
* Settings
* Apps
* Bike
* Data Screens
* Screen N
* Layout
* Select single field
* Field 1
* Select ConnectIQ Fields
* Select CyclistChartsField
* Long Press DOWN to go back to watch face
FAQ: How to add custom data field to app in fenix 3?
https://www.facebook.com/GarminFenix3/posts/441344592657118

===============================================

## Usage
Start Bike activity.
You should see the CyclistChartsField Data Field.

===============================================

## Changelog 2.0.1 11/02/2016
* Configurable implementation. Two fields are now configurable:
    bottom: distance, elevation, average HR, average PWR, calories
    upper right: distance + elevation chart, elevation chart, average HR chart, average PWR chart

## Changelog 1.1.1
* Fixed a potential issue with km/mi units settings, thanks to "xemoterp" for the comment: https://github.com/vovan-/cyclist-datafiled-garmin/issues/5#issuecomment-158239406
* Now speed and distance units settings may be configured separately.

## Changelog 1.1.0
* Support for 12/24h time format added based on system settings;
* Gps signal changed from text to antenna bar;
* Both km and mi unit settings are now supported based on system settings;

## Changelog 1.0.0b
* Initial commit