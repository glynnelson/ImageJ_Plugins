// Wrote this to duplicate work done in Starling et al EMBO Reports 2016 paper:
// ‘Folliculin directs the formation of a Rab34–RILP complex to control the nutrient‐dependent dynamic distribution of lysosome’
// It creates ROIs that shrink by 10 % in size each time, and then reports the results for each ROI.
// I've used the minor axis from shape descriptors- I tried Ferets, but it didn't work very well with odd shapes.
// Secondly, it creates a new image of the first 10% ring (the near-membrane portion) for downstream analysis.
// It doesn't save the reuslts currently.
// It requires an image with an ROI drawn in it.
// It saves the ring tif image in the same directory that the original image was opened from (haven't tested with lifs etc though!)

// Glyn Nelson, Bioimaging Unit, Newcastle University.  July 2019.

//Requirements: An open image with an ROI drawn in it.  
//  If it is a hyperstack, then ensure the channel you wish to analyse is selected.

dir = getDirectory("image");
name=File.nameWithoutExtension
run("ROI Manager...");
nROIs = roiManager("count");
if (nROIs >0){
	roiManager("Delete");
	}
roiManager("Add");
roiManager("Select", 0);
roiManager("Rename", "Outside");
run("Set Measurements...", "area mean min fit shape feret's integrated display redirect=None decimal=3");
run("Measure");
Ferets = getResult("Minor");
//Ferets = getResult("Feret");
ShrinkFactor = (Ferets*0.1);
//print (ShrinkFactor);
for (i = 1; i < 10; i++){
	Shrink = (Ferets-(i*ShrinkFactor));
//	getResult("Frame", i) + 1;
//	Ferets = getResult("Feret", i);
//	Min = getResult("Min", i);
//	print(frame + ", " + Ferets + ", " + Min);
	Scale = (Shrink/Ferets);
	run("Scale... ", "x=Scale y=Scale centered");
	roiManager("Add");
	roiManager("Select", i);
	roiManager("Rename", i);
//	print(Ferets + ", " + ShrinkFactor + ", " + Shrink);
}
roiManager("Deselect");
// Need to reset scaling back to original image here  **UPDATE-NO NEED- IT WORKS FINE REGARDLESS OF IMAGE SCALING
run("Set Measurements...", "area mean integrated display redirect=None decimal=3");
roiManager("multi-measure measure_all");
saveAs("Results", dir+File.separator+name+"Decile_Areas100to10pct.csv");
run("Duplicate...", "title=ForColoc duplicate");
//rename("ForColoc");
selectWindow("ForColoc");
roiManager("Select", 2);
setBackgroundColor(0, 0, 0);
run("Clear");
//run("Clear", "slice");
roiManager("Select", 1);
run("Clear Outside");
saveAs("TIFF", dir +File.separator+name+"MembraneRing10pct.tif");

//Now also get ring values
rename("10pctRing");

selectWindow(name);
run("Duplicate...", "title=100pctRing duplicate");
selectWindow("100pctRing");
roiManager("Select", 9);
roiManager("Rename", "100");
run ("Clear Outside");
roiManager("multi-measure measure_all");
close ("100pctRing");

selectWindow("name);
run("Duplicate...", "title=90pctRing duplicate");
selectWindow("90pctRing");
roiManager("Select", 100);
run("Clear");
roiManager("Select", 8);
roiManager("Rename", "90");
run ("Clear Outside");
roiManager("multi-measure measure_all append");
close ("90pctRing");

selectWindow("name);
run("Duplicate...", "title=80pctRing duplicate");
selectWindow("80pctRing");
roiManager("Select", 90);
run("Clear");
roiManager("Select", 7);
roiManager("Rename", "80");
run ("Clear Outside");
roiManager("multi-measure measure_all append");
close ("80pctRing");

selectWindow("name);
run("Duplicate...", "title=70pctRing duplicate");
selectWindow("70pctRing");
roiManager("Select", 80);
run("Clear");
roiManager("Select", 6);
roiManager("Rename", "70");
run ("Clear Outside");
roiManager("multi-measure measure_all append");
close ("70pctRing");

selectWindow("name);
run("Duplicate...", "title=60pctRing duplicate");
selectWindow("60pctRing");
roiManager("Select", 70);
run("Clear");
roiManager("Select", 5);
roiManager("Rename", "60");
run ("Clear Outside");
roiManager("multi-measure measure_all append");
close ("60pctRing");

selectWindow("name);
run("Duplicate...", "title=50pctRing duplicate");
selectWindow("50pctRing");
roiManager("Select", 60);
run("Clear");
roiManager("Select", 4);
roiManager("Rename", "50");
run ("Clear Outside");
roiManager("multi-measure measure_all append");
close ("50pctRing");

selectWindow("name);
run("Duplicate...", "title=40pctRing duplicate");
selectWindow("40pctRing");
roiManager("Select", 50);
run("Clear");
roiManager("Select", 3);
roiManager("Rename", "40");
run ("Clear Outside");
roiManager("multi-measure measure_all append");
close ("40pctRing");

selectWindow("name);
run("Duplicate...", "title=30pctRing duplicate");
selectWindow("30pctRing");
roiManager("Select", 40);
run("Clear");
roiManager("Select", 2);
roiManager("Rename", "30");
run ("Clear Outside");
roiManager("multi-measure measure_all append");
close ("30pctRing");

selectWindow("name);
run("Duplicate...", "title=20pctRing duplicate");
selectWindow("20pctRing");
roiManager("Select", 30);
run("Clear");
roiManager("Select", 1);
roiManager("Rename", "20");
run ("Clear Outside");
roiManager("multi-measure measure_all append");
close ("20pctRing");

selectWindow("10pctRing");
roiManager("Select", Outside);
roiManager("Rename", "10");
roiManager("multi-measure measure_all append");
close ("10pctRing");

showMessage(" Well, I think we gave them a damn good thrashing there, what what??");	
