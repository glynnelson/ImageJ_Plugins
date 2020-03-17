//Short macro to fix an increase in background fluoresnce from a timeseries (probably caused by fluorescence activation of the medium in some widefield
//live cell experiments.

//The macro asks for an input directory and then will run through all Zeiss czi files in there.
//It is currently quite constrained, and only does the first 2 fluorescent channels in the image.  COuld easily extract the number of channels and run through them all.

//Requirements.  Needs bioformats and has been tested in Fiji 2.0.0-rc-69/1.52p with Java 1.8.0_202 [64bit] on MacOS.

//Glyn Nelson. February 2020.


run("Bio-Formats Macro Extensions");

setBatchMode(true);

//Function to use for running bleach correction on image with increasing background fluorescence
function normaliseChannel(){
SingleChannel= getTitle();
run("Reverse");
run("Bleach Correction", "correction=[Exponential Fit]");
selectWindow(SingleChannel);
close();
selectWindow("DUP_"+SingleChannel);
run("Reverse");
rename(SingleChannel+"_Normed");
}
//end of Function

dir1 = getDirectory("Choose Source Directory ");
dir1parent = File.getParent(dir1);
dir1name = File.getName(dir1);
dir2 = dir1parent+File.separator+dir1name+"_NormedTiffs";

if (File.exists(dir2)==false) {
				File.makeDirectory(dir2); // new directory for tiff
		}
		
list = getFileList(dir1);
setBatchMode(true);
for (i=0; i<list.length; i++) {
	 showProgress(i+1, list.length);
 	print("processing ... "+i+1+"/"+list.length+"\n         "+list[i]);
	filename = dir1 + list[i];
	if (endsWith(filename, "czi")){
//	 if (endsWith(filename, "tif")) {
		path=dir1+list[i];
//how many series in this czi file?
		Ext.setId(path);//-- Initializes the given path (filename).
		Ext.getSeriesCount(seriesCount); //-- Gets the number of image series in the active dataset.
	
		for (j=1; j<=seriesCount; j++) {
			run("Bio-Formats Importer", "open=["+filename+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+j);

			name=getTitle();
			SaveName=File.nameWithoutExtension;
			run("Duplicate...", "duplicate channels=1 title=red");
			selectWindow(name);
			run("Duplicate...", "duplicate channels=2 title=green");

			selectWindow("green");
			normaliseChannel();

			selectWindow("red");
			normaliseChannel();

			run("Merge Channels...", "c1=red_Normed c2=green_Normed create");

			saveAs("TIFF", dir2 +File.separator+SaveName+"_NormalisedIntensity"+j+".tif");
			run("Close All");
			}
		 }
	}
showMessage(" Well, I think we gave them a damn good thrashing there, what what??");	
