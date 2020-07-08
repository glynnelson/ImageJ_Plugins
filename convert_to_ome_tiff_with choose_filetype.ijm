//FUNCTION: opens a dialog to set text list for filtering a list
//example: setDialogImageFileFilter();
//this function set interactively the global variables used by the function getFilteredFileList
//it can be set to ask for other text to filter files on.  I didn't get this to work though and have removed them.
//this function needs global variables! (see below)
/*

var fileExtension = ".tif";   												//default definition of extension
var filterStrings = newArray("","","");                                      //default definition of strings to filter
var availableFilterTerms = newArray("no filtering", "include", "exclude");   //dont change this
var filterTerms = newArray(filterStrings.length); for  (i = 0; i < filterStrings.length; i++) {filterTerms[i] = "no filtering";} //default definition of filter types (automatic)
//var filterTerms = newArray("no filtering", "no filtering", "no filtering");  //default definition of filter types (manual)
var displayFileList = false;                                                 //shall array window be shown? 
*/
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
Dialog.addMessage("This macro will make a new folder with a TIFF suffix where converted files are saved");
Dialog.show();
fileExtension = Dialog.getString();
//for (i = 0; i < filterStrings.length; i++) {
//	filterStrings[i] = Dialog.getString();	
//	filterTerms[i] = Dialog.getChoice();	
//	}
//displayFileList = Dialog.getCheckbox();
}


var fileExtension = ".nd2";
//var filterStrings = newArray("MAX","Processed");  
//var availableFilterTerms = newArray("no filtering", "include", "exclude");   //dont change this
//var filterTerms = newArray(filterStrings.length); for  (i = 0; i < filterStrings.length; i++) {filterTerms[i] = "no filtering";} 
//var displayFileList = false;    
  




setDialogImageFileFilter();


run("Bio-Formats Macro Extensions");


dir1 = getDirectory("Choose folder with image files ");
list = getFileList(dir1);

setBatchMode(true);

// create folders for the tifs
	dir1parent = File.getParent(dir1);
	dir1name = File.getName(dir1);
	dir2 = dir1parent+File.separator+dir1name+"_Tiffs";
	if (File.exists(dir2)==false) {
				File.makeDirectory(dir2); // new directory for tiff
		}
 
for (i=0; i<list.length; i++) {
	showProgress(i+1, list.length);
	print("processing ... "+i+1+"/"+list.length+"\n         "+list[i]);
	filename = dir1 + list[i];
		if (endsWith(filename, fileExtension)){
//if (endsWith(filename, "czi")){
		path=dir1+list[i];

	//how many series in this czi file?
		Ext.setId(path);//-- Initializes the given path (filename).
		Ext.getSeriesCount(seriesCount); //-- Gets the number of image series in the active dataset.
	
		for (j=1; j<=seriesCount; j++) {
		
		run("Bio-Formats", "open=path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+j);
	
		name=File.nameWithoutExtension;
		seriesname=name;
	//	saveAs("/Users/glyn_nelson/Desktop/test/cziTest/heart_point3airy_decon_with_measured_PSF-2.tif");
	//	saveAs("TIFF", dir2+File.separator+name+"_"+j+".tif");
		run("OME-TIFF...", "save=" + dir2+File.separator+name+"_"+j+".ome.tif" + " compression=Uncompressed");
		run("Close All");
		
	}

}
run("Close All");
setBatchMode(false);

}
showMessage(" Well, I think we gave them a damn good thrashing there, what what??");	
 // macro





