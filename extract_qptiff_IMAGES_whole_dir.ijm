//Writtent o save qptiff images as a tiff fomrat that will open without biorformats, for example, to import into Zen
//This extratcs the first image in the qptiff, which has a pyramidal structure for fast loading- the first image is the
//full resolution one.
//The macro asks for the input directory and creates an output directory in the same parent folder,
//with the same name plus the suffix _Tiffs

//This will do all qptiff files in that directory for you.

//I cannot get it to remove the filename suffix- I think the 5 char length is confusing the command I have tried.

dir1 = getDirectory("Choose Source Directory ");
dir1parent = File.getParent(dir1);
dir1name = File.getName(dir1);
dir2 = dir1parent+File.separator+dir1name+"_Tiffs";

if (File.exists(dir2)==false) {
				File.makeDirectory(dir2); // new directory for tiff
		}
		
//dir2 = getDirectory("Choose Destination Directory ");
list = getFileList(dir1);
setBatchMode(true);
for (i=0; i<list.length; i++) {
	 showProgress(i+1, list.length);
	 filename = dir1 + list[i];
	 name=File.nameWithoutExtension;
	 if (endsWith(filename, "qptiff")) {
//		 open(filename);
//run("Bio-Formats Importer", "open="+filename+" autoscale color_mode=Custom rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_0_channel_0_red=0 series_0_channel_0_green=0 series_0_channel_0_blue=255 series_0_channel_1_red=0 series_0_channel_1_green=255 series_0_channel_1_blue=0 series_0_channel_2_red=255 series_0_channel_2_green=0 series_0_channel_2_blue=0 series_0_channel_3_red=255 series_0_channel_3_green=255 series_0_channel_3_blue=255 view=Hyperstack stack_order=XYCZT"); 
run("Bio-Formats Importer", "open=["+filename+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
 // INSERT MACRO HERE
title = getTitle();

//	rename("original");
//	Stack.getDimensions(width, height, channels, slices, frames);
//	zstack=slices; 
//wait(2000);
//	run("Z Project...", "start=1 stop=slices projection=[Max Intensity]");

//	selectWindow("MAX_original");
	Stack.setDisplayMode("composite");
//		 saveAs("TIFF", dir2+File.separator+list[i]+".tif");
		  saveAs("TIFF", dir2+File.separator+name+".tif");
//		 close();		
close();
 }
}


print("well, I think we gave them a damn");
print("good thrashing there, what what?");
