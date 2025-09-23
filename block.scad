/*
Uses the gridfinity-rebuilt library.
Supply vectors for the socket diameters (sockets), the socket names, the socket height, socket orientation (90 = flat, 0 = vertical), your desired spacing, then use the Adjust parameters to get the titles where you'd like them on the body. 

This does not adjust the base size, you should handle that in the gridfinity setup parameters (below the socket parameters).
*/

include <src/core/bin.scad>
use <src/core/gridfinity-rebuilt-utility.scad>
use <src/core/gridfinity-rebuilt-holes.scad>
use <src/helpers/generic-helpers.scad>

//socket constants

sockets =     [22.20,   23.35,   23.35,   23.35,   23.35,   23.15,   24.20,   25.20,   26.15,   27.13];
socketNames = [ "10",    "12",    "13",    "14",    "15",    "16",    "17",    "18",    "19",    "20"];

BinTitle = "1/2\"     -     METRIC     -     6-POINT     -     DEEP";
Spacing = 0.6;
SocketHeight = 83.1;
Orientation = 0;
AdjustSocket_X = 0;
AdjustSocket_Z = 5;

AdjustLabel_Y = 6.0;
AdjustTitle_Y = 0.5;
AdjustAllText_Z = 43;
TextSize = 5;
TextEngraved = true; //engraved (negative) if true and embossed (positive) if false

/* gridfinity constants */

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;
gridx = 6;
gridy = 1;
gridz = 3;
gridz_define = 0;

/* [Height] */
// determine what the variable "gridz" applies to based on your use case gridz_define = 0; // [0:gridz is the height of bins in units of 7mm increments - Zack's method,1:gridz is the internal height in millimeters, 2:gridz is the overall external height of the bin in millimeters]
// overrides internal block height of bin (for solid containers). Leave zero for default height. Units: mm
height_internal = 37;
// snap gridz height to nearest 7mm increment
enable_zsnap = false;
// If the top lip should exist.  Not included in height calculations.
include_lip = false;

/* [Base Hole Options] */
// only cut magnet/screw holes at the corners of the bin to save uneccesary print time
only_corners = true;
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

function getSpacing(n) = n == 0 ? 0 : (Spacing + sockets[n] + getSpacing(n - 1));

module posLabels(yPos) {
  translate([-(getSpacing(len(sockets) - 1))/2 - Spacing, yPos, AdjustAllText_Z]) {
    for (i = [0 : len(sockets) - 1] ) {
      translate([getSpacing(i), 0, 0]) {
        linear_extrude(2) 
        text(socketNames[i], TextSize, halign="center");
      }
    }
  }  
}

module sizeLabels() {
  if (Orientation != 90) {
    posLabels(-(max(sockets)/2) - AdjustLabel_Y);
  } else {
    posLabels(-SocketHeight/2 - AdjustLabel_Y);
  }
}

module posTrayLabel(yPos) {
  translate([0, yPos, AdjustAllText_Z]) {
    linear_extrude(2)
    text(BinTitle, TextSize, halign="center");
  }  
}

module trayLabel() {
  if (Orientation != 90) {
    posTrayLabel(max(sockets)/2 + AdjustTitle_Y);
  } else {
    posTrayLabel(SocketHeight/2 + AdjustTitle_Y);
  }
}

module posSocketBodies(rotation, sPos) {
  translate(sPos) {
    rotate( [rotation, 0, 0] ) {
      for (i = [0 : len(sockets) - 1]) {
        translate([getSpacing(i) + AdjustSocket_X, 0, 0]) {
          cylinder(h = SocketHeight, d = sockets[i]);
        }
      }
    }
  }
}

module socketBodies() {
  if (Orientation != 90) {
    posSocketBodies(0, [-(getSpacing(len(sockets) - 1))/2 - Spacing, 0, 6]);
  } else {
    posSocketBodies(90, [-(getSpacing(len(sockets) - 1))/2 - Spacing, SocketHeight/2, (max(sockets)/2 + AdjustSocket_Z)]);
  }
}

module main() {
    if (TextEngraved == true) {
        difference() {
        gridBase();
        socketBodies();
        sizeLabels();
        trayLabel();
        }
    } else {
        sizeLabels();
        trayLabel();
        difference() {
        gridBase();
        socketBodies();
        }
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
