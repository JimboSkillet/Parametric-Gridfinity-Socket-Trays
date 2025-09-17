/*
Uses the gridfinity-rebuilt library.
Supply vectors for the socket diameters (sockets), the socket names, the socket height, socket orientation (90 = flat, 0 = vertical), your desired spacing, then use the fineAdjust parameters to get the titles where you'd like them on the body. 

This does not adjust the base size, you should handle that in the gridfinity setup parameters (below the socket parameters).

Includes a number of "presets" for use.
*/

include <src/core/bin.scad>
use <src/core/gridfinity-rebuilt-utility.scad>
use <src/core/gridfinity-rebuilt-holes.scad>
use <src/helpers/generic-helpers.scad>

//socket constants

binTitle = "3/8\" Metric Deep 6 Point Impact Sockets";
sockets = [18, 18, 19, 21, 22.5, 22.5, 24, 24, 26, 27];
socketNames = ["10", "11", "12", "13", "14", "15", "16", "17", "18", "19"];
spacing = 1.5;
socketHeight = 67;
orientation = 90;
fineAdjustLabel = 5;
fineAdjustTitle = 3;
fineAdjustSocket = 5;

/*
binTitle = "3/8\" SAE Deep 12 Point";
sockets = [18, 18, 18, 18, 19, 21, 23, 25, 27, 28, 31];
socketNames = ["1/4", "5/16", "3/8", "7/16", "1/2", "9/16", "5/8", "11/16", "3/4", "13/16", "7/8"];
spacing = 1.5;
socketHeight = 65;
orientation = 90;
fineAdjustLabel = 6;
fineAdjustTitle = 3;
fineAdjustSocket = 5;
*/
/*
binTitle = "1/4\" Metric Deep 6 Point";
sockets = [12.5, 12.5, 12.5, 12.5, 12.5, 13.5, 14.2, 16.2, 17.5, 18.2, 20.5];
socketNames = ["5", "5.5", "6", "7", "8", "9", "10", "11", "12", "13", "14"];
spacing = 1.5;
socketHeight = 52;
orientation = 90;
fineAdjustLabel = 6;
fineAdjustTitle = 3;
fineAdjustSocket = 10.5;
*/

/*
binTitle = "1/4\" Metric 6 Point";
sockets = [12.5, 12.5, 12.5, 12.5, 12.5, 13.5, 14.2, 16.2, 17.5, 18.2, 20.5];
socketNames = ["5", "5.5", "6", "7", "8", "9", "10", "11", "12", "13", "14"];
spacing = 1.5;
socketHeight = 52;
orientation = 0;
fineAdjustLabel = 6;
fineAdjustTitle = 3;
fineAdjustSocket = 10.5;
*/

/* gridfinity constants */


/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

gridx = 6;
gridy = 2;
gridz = 3;

gridz_define = 0;

/* [Height] */
// determine what the variable "gridz" applies to based on your use case gridz_define = 0; // [0:gridz is the height of bins in units of 7mm increments - Zack's method,1:gridz is the internal height in millimeters, 2:gridz is the overall external height of the bin in millimeters]
// overrides internal block height of bin (for solid containers). Leave zero for default height. Units: mm
height_internal = 0;
// snap gridz height to nearest 7mm increment
enable_zsnap = false;
// If the top lip should exist.  Not included in height calculations.
include_lip = false;

/* [Compartments] 
// number of X Divisions (set to zero to have solid bin)
divx = 1;
// number of Y Divisions (set to zero to have solid bin)
divy = 1;
// Leave zero for default. Units: mm
depth = 0;  //.1
*/

/* [Base Hole Options] */
// only cut magnet/screw holes at the corners of the bin to save uneccesary print time
only_corners = false;
//Use gridfinity refined hole style. Not compatible with magnet_holes!
refined_holes = false;
// Base will have holes for 6mm Diameter x 2mm high magnets.
magnet_holes = false;
// Base will have holes for M3 screws.
screw_holes = false;
// Magnet holes will have crush ribs to hold the magnet.
crush_ribs = false;
// Magnet/Screw holes will have a chamfer to ease insertion.
chamfer_holes = false;
// Magnet/Screw holes will be printed so supports are not needed.
printable_hole_top = false;
// Enable "gridfinity-refined" thumbscrew hole in the center of each base: https://www.printables.com/model/413761-gridfinity-refined
enable_thumbscrew = false;

hole_options = bundle_hole_options(refined_holes, magnet_holes, screw_holes, crush_ribs, chamfer_holes, printable_hole_top);

main();

function getSpacing(n) = n == 0 ? 0 : (spacing + sockets[n] + getSpacing(n - 1));

module posLabels(yPos) {
  translate([-(getSpacing(len(sockets) - 1))/2 - spacing, 
             yPos, 
             21]) {
    for (i = [0 : len(sockets) - 1] ) {
      translate([getSpacing(i), 0, 0]) {
        linear_extrude(2) 
        text(socketNames[i], size = 3.5, halign="center");
      }
    }
  }  
}

module sizeLabels() {
  if (orientation != 90) {
    posLabels(-(max(sockets)/2) - fineAdjustLabel);
  } else {
    posLabels(-socketHeight/2 - fineAdjustLabel);
  }
}

module posTrayLabel(yPos) {
  translate([0, yPos, 21]) {
    linear_extrude(2)
    text(binTitle, size = 4, halign="center");
  }  
}

module trayLabel() {
  if (orientation != 90) {
    posTrayLabel(max(sockets)/2 + fineAdjustTitle);
  } else {
    posTrayLabel(socketHeight/2 + fineAdjustTitle);
  }
}

module posSocketBodies(rotation, sPos) {
  translate(sPos) {
    rotate( [rotation, 0, 0] ) {
      for (i = [0 : len(sockets) - 1]) {
        translate([getSpacing(i), 0, 0]) {
          cylinder(h = socketHeight, d = sockets[i]);
        }
      }
    }
  }
}

module socketBodies() {
  if (orientation != 90) {
    posSocketBodies(0, [-(getSpacing(len(sockets) - 1))/2 - spacing,
                        0,
                        6]);
  } else {
    posSocketBodies(90, [-(getSpacing(len(sockets) - 1))/2 - spacing,
                        socketHeight/2,
                        (max(sockets)/2 + fineAdjustSocket)]);
  }
}

module main() {
  sizeLabels();
  trayLabel();
  difference() {
    gridBase();
    socketBodies();
  }
}

module gridBase() {
    bin1 = new_bin(
    grid_size = [gridx, gridy],
    height_mm = height(gridz, gridz_define, enable_zsnap),
    fill_height = height_internal,
    include_lip = include_lip,
    hole_options = hole_options,
    only_corners = only_corners,
    thumbscrew = enable_thumbscrew,
    grid_dimensions = GRID_DIMENSIONS_MM
    );

    bin_render(bin1)

    gridfinityBase(
        [gridx, gridy], 
        hole_options=hole_options, 
        only_corners=only_corners, 
        thumbscrew=enable_thumbscrew
        );
}
