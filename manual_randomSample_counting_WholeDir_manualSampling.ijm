/* Updated March 2020.
 * 
 * Macro to go through a directory of images and open each one of the chosen filetype.
 * It then asks afor a sampling frequency in x and y pixels- defaults to 200x200.
 * These are then scaled to a 4k monitor resolution (think it fails if your image is larger than this)
 * and a grid overlay added.
 * Positive cells at each crosshair can then be counted using the mulitpoint tool
 * 
 * Outputs:
 * An empty textfile with a filename sayign what the imagescaling is and the sampling frequency (requiring user to perform some
 * basic maths).
 * A csv file with each filename and the number of positive cells per sampling site per image
 * 
 * Note:
 * occasionally it decides there are changes to the image to save- seems to want to save it with the ROI overlay once you have added more than 10 dots???.
 * 
 * Could have the samplingfreq and scaling in the results filename if I could guarantee that all images were the same scale.
 */

w = 4096;
h = 2160;
var xpoints = (0);
var ypoints = (0);
var count =(0);

var fileExtension = ".tif"; //sets the default file type
var DistanceSet = (200); //Sets the deault sampling frequency

setDialogImageFileFilter();


run("Bio-Formats Macro Extensions");


//get user to decide sampling frwquency
setSamplingFreq();
SamplingArea= DistanceSet * DistanceSet;
     dir = getDirectory("Choose Source Directory ");
     list = getFileList(dir);
     for (i=0; i<list.length; i++) {
        showProgress(i+1, list.length);
		print("processing ... "+i+1+"/"+list.length+"\n         "+list[i]);
		filename = dir + list[i];
		if (endsWith(filename, fileExtension)) {
        	path=dir+list[i];
//5 commented out lines below are for using raw files with multiple images in them, eg czi, lif etc.
	//how many series in this file?
//			Ext.setId(path);//-- Initializes the given path (filename).
//			Ext.getSeriesCount(seriesCount); //-- Gets the number of image series in the active dataset.
	
//			for (j=1; j<=seriesCount; j++) {
//				run("Bio-Formats", "open=path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+j);		
				run("Bio-Formats", "open=path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_");
	
//       		 open(dir+list[i]);
				name=getTitle();
				getPixelSize(unit, pixelWidth, pixelHeight);
				saveAs("Results", dir+File.separator+name+"_ScalingIs_"+pixelWidth+"_"+unit+"_samplingEvery"+DistanceSet+"pixels.txt");
//				print("image scale is "+pixelWidth+" "+unit+" per pixel.  Sampling is every 200x200 pixels");
				run("Canvas Size...", "width=&w height=&h position=Center zero");
				run("Maximize");
				setLocation(0,0);
				run("Unsharp Mask...", "radius=1 mask=0.60");
				run("Grid...", "grid=Crosses area=SamplingArea color=green bold center");
				run("Set... ", "zoom=50");
    		    setTool("multipoint");
//2 lines below added to allow zeroes to be counted by tricking the counter using the addition of a single count in the xpoints which is then
//subtracted at the point of reporting.
				run("Point Tool...", "type=Dot color=Black size=[Tiny] counter=0");
    		    makePoint(0, 0, "tiny black dot");
				run("Point Tool...", "type=Dot color=Red size=[Extra Large] show counter=0");
 //  		     name=File.nameWithoutExtension;				
				waitForUser("Your Action Required", "Click on all crosshairs that are inside your positive signal area.\n Alt-Click on a spot to remove it.\n Then press OK");
				getSelectionCoordinates( xpoints, ypoints );
				count = (xpoints.length -1);
//The if statement below doesn't work- clicking OK without markign nay points gives an error because the xpoints, ypoints array is empty.
//This also means that the whole macro fails if there are no positives in a field.

//		   if (selectionType() == -1) { // In case there might be zero points selected by the user
//		     count = 0;
//		   } else {
//				getSelectionCoordinates(xpoints, ypoints);
//				count = (xpoints.length -1);
//				   }
			row = nResults;
			setResult("Label", row, getTitle());
			setResult("Count", row, count);
			close();
			count = 0;
     	}
     }
saveAs("Results", dir+File.separator+name+"_AllCountResults.csv");
run("Clear Results");
showMessage(" Well, I think we gave them a damn good thrashing there, what what??");	


//FUNCTION- choose file type
function setDialogImageFileFilter() {
Dialog.create("Image file filter...");  //enable use interactivity
Dialog.addMessage("Define the file types to be processed:");
Dialog.addString("Files should have this extension:", fileExtension);	//add extension
//Dialog.addMessage("Define filter for files:");
//for (i = 0; i < filterStrings.length; i++) {
//	Dialog.addString((i + 1) + ") Filter this text from file list: ", filterStrings[i]);	
//	Dialog.addChoice((i + 1) + ") Files with text are included/excluded?", availableFilterTerms, filterTerms[i]);	
//	}
//Dialog.addCheckbox("Show the file list to check?", displayFileList);	//if check file lists will be displayed
Dialog.addMessage("This macro will sequentially open all these filetypes in the chosen folder");
Dialog.show();
fileExtension = Dialog.getString();
//for (i = 0; i < filterStrings.length; i++) {
//	filterStrings[i] = Dialog.getString();	
//	filterTerms[i] = Dialog.getChoice();	
//	}
//displayFileList = Dialog.getCheckbox();
}
//End of function setDialogImageFileFilter


//FUNCTION- determine sampling frequency
function setSamplingFreq() {
Dialog.create("Set the sampling frequency");  //enable use interactivity
Dialog.addMessage("Define the distance between points (in pixels):");
Dialog.addString("Sampling Frequency should be this far apart:", DistanceSet);	//add extension
Dialog.addMessage("This sets the horizontal and vertical distance between sampling points");
Dialog.show();
StringDistanceSet = Dialog.getString(); //Not sure this is needed in here as it seems to know numbers aren't strings in string boxes.
DistanceSet = parseFloat(StringDistanceSet);
}
//End of function setSamplingFreq