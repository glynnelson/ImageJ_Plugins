macro 'convert LIF tiff' {

/*
 * - converts LIF files into TIFF. 
 * - the macro ask for an input folder that should contain 1 or more lif files. Nothing else.
 * - each series is saved as one tiff. The name of the series is appended to the file name.
 * - if the series has more than one frame, a Max Intensity projection is also performed 
 * - before saving. The TIFFs are saved in a folder generated by the macro in the same 
 * - parent folder as the lifs, with the same prefix for the folder name, with TIFF suffix.
 * 
 * Martin Hoehne, August 2015
 * 
 *  Update October 2015: works for Multichannel images as well
 *
 * Update Jan2016 (Glyn Nelson).  Now also saves z stack as well as mip if it is a z stack.
 *  This works with SP8 images as long as they aren't in subfolders, such as Mark and Find: these
 *  images have a '/' in their name, so it throws an error when trying to save. 
 * Update Jan2016 (Glyn Nelson).  Fixed.  It will now remove '/' if it exists in the imagename before saving. 
 * 
 * Update Feb 2016 (Glyn Nelson).  Now ignores other files in the folder with lifs (although it will give multiple finished
 *  messages for each extra file it finds...)
 */

run("Bio-Formats Macro Extensions");


dir1 = getDirectory("Choose folder with lif files ");
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
		if (endsWith(filename, "lif")){
		path=dir1+list[i];

	//how many series in this lif file?
		Ext.setId(path);//-- Initializes the given path (filename).
		Ext.getSeriesCount(seriesCount); //-- Gets the number of image series in the active dataset.
	
		for (j=1; j<=seriesCount; j++) {
		
		run("Bio-Formats", "open=path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+j);
	
		name=File.nameWithoutExtension;

	//retrieve name of the series from metadata
		text=getMetadata("Info");
		n1=indexOf(text," Name = ")+8;// the Line in the Metadata reads "Series 0 Name = ". Complete line cannot be taken, because
									  // The number changes of course. But at least in the current version of Metadata this line is the 
									  // only occurence of " Name ="
		n2=indexOf(text,"SizeC = ");  // this is the next line in the Metadata
		extractedname=substring(text,n1,n2-2);
		cleanname=split(extractedname,"/");  // this is done here to remove the forward slash that is found in the image name 
					// if it is part of a mark and find subfolder, for example 

//We still want both parts of the filenename.  So if there are two parts to the array, then stick them together, otherwise just take the first:
			if (cleanname.length==2){
			seriesname=cleanname[0]+cleanname[1];
			}		
			else seriesname=cleanname[0];
	//project and save
				if (nSlices>1) {
				run("Z Project...", "projection=[Max Intensity]");
				if (nSlices>1) Stack.setDisplayMode("composite");
				saveAs("Tiff", dir2+File.separator+name+"_"+seriesname+"_MIP.tif");
				close();
				Stack.setDisplayMode("composite");
				saveAs("TIFF", dir2+File.separator+name+"_"+seriesname+".tif");
			}	
			else Stack.setDisplayMode("composite");
			saveAs("TIFF", dir2+File.separator+name+"_"+seriesname+".tif");
			run("Close All");
//		run("Collect Garbage");
		
	}

}
//showMessage(" Well, I think we gave them a damn good thrashing there, what what??");	
run("Close All");
setBatchMode(false);

}
showMessage(" Well, I think we gave them a damn good thrashing there, what what??");	
 // macro
