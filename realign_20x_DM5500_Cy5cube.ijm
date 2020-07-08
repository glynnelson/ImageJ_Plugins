//To relaign the Y5 cube to the new Cy3 cube on the DM5500 20x, by moving the 4th channel up 4 pixels. 
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


			originalImage = getTitle();
			selectWindow(originalImage);
//Make a copy of each channel since the Translate option will move all channels in a multichannel image
			run("Duplicate...", "title=green duplicate channels=1"); 
			selectWindow(originalImage);
			run("Duplicate...", "title=red duplicate channels=2"); 
			selectWindow(originalImage);
			run("Duplicate...", "title=blue duplicate channels=3"); 
			selectWindow(originalImage);
			run("Duplicate...", "title=farred duplicate channels=4"); 
//Assuming that channel 1 is green, 2 is red, 3 is blue and 4 is far red
			selectWindow("farred");
//Translate Cy5 image relative to the red (Cy3 cube) image:
			run("Translate...", "x=0 y=3 interpolation=None stack");

//Re-merge the channels:
			run("Merge Channels...", "c1=green c2=red c3=blue c4=farred create");

//Save image out as tiff:
			saveAs("TIFF", dir2+File.separator+name+"_"+seriesname+".tif");
			run("Close All");
		
	}

}
showMessage(" Well, I think we gave them a damn good thrashing there, what what??");	
run("Close All");
setBatchMode(false);



