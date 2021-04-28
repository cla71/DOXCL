/*
 * Macro template to process multiple images in a folder
 */

input = getDirectory("Choose input directory");
output = getDirectory("Choose output directory");
suffix = ".tif";

// See also Process_Folder.py for a version of this code
// in the Python scripting language.

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]))
			processFolder(input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
//spotDiam = getNumber(label = "Spot Diameter (pixels)",value=20)
//numSpots = getNumber(label = "Number of spots",value=2)
spotDiam=75;//parseInt(spotDiam);
numSpots=200;//parseInt(numSpots);
verbose=1;
run("Overlay Options...", "stroke=red width=1 fill=none");

setBatchMode("show");
//-- Clear workspace
//print("\\Clear");
//close("*");

//-- load the example image and convert the overlay to a selection
open(input + file);
title=getTitle();
print(title);
getDimensions(w,h,c,z,f);
getPixelSize(unit, pixelWidth, pixelHeight);
//-- Strip calibration (we'll add it back later)
run("Properties...", "unit=pixel pixel_width=1.0000 pixel_height=1.0000");

//-- check to see if there's an overlay in the image
run("List Elements"); //-- does nothing if there are no overlays, opens a results table if there is
if (isOpen("Overlay Elements of "+title)){
selectWindow("Overlay Elements of "+title);
run("Close");
}else{
selectWindow("Overlay Elements of "+title);
run("Close");
exit("Image needs to have an overlay");
}

roiManager("reset");
run("To ROI Manager");
run("Remove Overlay");
roiManager("select", 0);

//-- Calculate the bounding box
List.clear;
List.setMeasurements;
//-- position of top left
bX=List.getValue("BX");
bY=List.getValue("BY");
//-- dimensions of box
bW=List.getValue("Width");
bH=List.getValue("Height");
List.clear;

//-- keep track of tries
numTries_inside=0;
numTries_overlap=0;

for (i=0;i<numSpots;i++){
	//-- make sure the loop doesn't run forever
	if (numTries_inside>200 || numTries_overlap>200){exit("Reached maximum number of tries without finding a solution. Try reducing the spot diameter or enlarging the original ROI.");}
	
if (verbose>0){print("-------------------------------");}
if (verbose>1){print("     Spot index (i) = "+i+" | ROI count = "+roiManager("count"));}
//-- Pick a random coordinate taking into account the ROI radius
randX=(bX+(spotDiam/2))+(random()*(bW-(spotDiam/2)));
randY=(bY+(spotDiam/2))+(random()*(bH-(spotDiam/2)));

if (verbose>0){print("ROI #"+IJ.pad(i+1,2)+": Coordinates: "+d2s(randX,0)+" / "+d2s(randY,0));}

//-- create a mask image with which to test overlaps
newImage("mask", "8-bit black", w, h, 1);
roiManager("select", 0);
setForegroundColor(255, 255, 255);
run("Fill");
run("Select None");

//-- measure the area of original shape (only need to do this once)
if (i==0){
List.clear;
List.setMeasurements;
originalShapeArea=List.getValue("RawIntDen")/255;
List.clear;
}

//-- Create the ROI and check to see whether it is within the boundary
run("Specify...", "width="+spotDiam+" height="+spotDiam+" x="+randX+" y="+randY+" oval centered");
roiManager("add");
run("Fill");
run("Select None");
List.clear;
List.setMeasurements;
newRoiArea=List.getValue("RawIntDen")/255;
List.clear;

if (verbose>0){print("ROI #"+IJ.pad(i+1,2)+" Total Area = "+newRoiArea+" Original shape = "+originalShapeArea);}

if (newRoiArea>originalShapeArea){
//-- Shape falls outside original shape
if (verbose>0){print("     ROI outside original shape");}
roiManager("select", i+1);
roiManager("Delete");
i--;
numTries_inside++;
}else{
numTries_inside=0;	
//-- newly created selection is within original ROI bounds
if (verbose>0){print("     ROI within original shape");}
numTries_inside=0;
//-- check if the newly created selection overlaps previous ROI selections (only on second selection and higher)
if (i>0){
	//-- make a list of all ROIs not counting the first (original) one
	roiList=Array.getSequence(i+2);
	//Array.print(roiList);
	roiList=Array.rotate(roiList, -1);
	//Array.print(roiList);
	roiList=Array.trim(roiList,i+1);
	if (verbose>1){Array.print(roiList);}

//-- Select all added ROIs
roiManager("Select",roiList);
	
roiManager("Combine"); //-- combine all selections
List.clear;
List.setMeasurements;
roiBothArea=List.getValue("Area");
List.clear;
if (verbose>0){print("ROI #"+IJ.pad(i+1,2)+" Total Area = "+roiBothArea+" Expected = "+((i+1)*sSpotArea));}

if (roiBothArea<(i+1)*sSpotArea){
	//-- we have overlap so remove the ROI and go back a step
	if (verbose>0){print("     ROI overlap found!: Expected area = "+((i+1)*sSpotArea)+" Found Area = "+roiBothArea);}
	roiManager("Deselect");
	roiManager("Select", i+1);
	roiManager("Delete");
	i--;
	numTries_overlap++;
}else{
numTries_overlap=0;
}

}else{
//-- This is the first loop (i==0) so record the single spot area
roiManager("select", 1);
List.clear;
List.setMeasurements;
sSpotArea=List.getValue("Area");
List.clear;
}

	
}	//-- ROI is within original loop
close("mask");

//run("Select None");
} //-- NumSpots loop

//-- all done, return the calibration
run("Properties...", "unit="+unit+" pixel_width="+pixelWidth+" pixel_height="+pixelHeight);

//setBatchMode("exit and display");
roiManager("show all with labels");
numROIs=roiManager("count");
for (i = 1; i < numROIs; i++) 
{
roiManager("select", i);
run("Duplicate...","duplicate");
dtitle=getTitle();
run("Split Channels");
selectWindow(dtitle+" (red)");
close();
selectWindow(dtitle+" (blue)");
close();
selectWindow(dtitle+" (green)");
saveAs("TIFF", output+i+"_"+dtitle);
close();
}
close(title);
roiManager("reset")
print("-------------------------------");
print("   done");
}