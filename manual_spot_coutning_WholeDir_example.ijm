w = 4096;
h = 2160;
var xpoints = (0);
var ypoints = (0);
var count =(0);

var fileExtension = ".jpg"; //sets the default file type

setDialogImageFileFilter();


run("Bio-Formats Macro Extensions");

setBatchMode(true);

     dir = getDirectory("Choose Source Directory ");
     list = getFileList(dir);
     for (i=0; i<list.length; i++) {
        //showProgress(i+1, list.length);
		//print("processing ... "+i+1+"/"+list.length+"\n         "+list[i]);
		filename = dir + list[i];
		if (endsWith(filename, fileExtension)){
 //       	showProgress(i+1, list.length);
        	path=dir+list[i];

	//how many series in this file?
			Ext.setId(path);//-- Initializes the given path (filename).
			Ext.getSeriesCount(seriesCount); //-- Gets the number of image series in the active dataset.
	
			for (j=1; j<=seriesCount; j++) {
		
//				run("Bio-Formats", "open=path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+j);
	
       		 open(dir+list[i]);
	   		   run("Canvas Size...", "width=&w height=&h position=Center zero");
      		  run("Maximize");
   		     setLocation(0,0);
 //    		   type = selectionType(10); 
      		  run("Unsharp Mask...", "radius=1 mask=0.60");
                  run("Grid...", "grid=Crosses area=85700 color=green bold center");
     		   run("Set... ", "zoom=50");
    		    setTool("multipoint");
   		     run("Point Tool...", "type=Dot color=Red size=[Extra Large] label show counter=0");
   		     name=File.nameWithoutExtension;
 //       getSelectionCoordinates( xpoints, ypoints );
 //           x = xpoints[0];
 //   y = ypoints[0];
//        count = xpoints.length;
        row = nResults;
//        setResult("Label", row, getTitle());
		setResult("Label", row, filename);
        setResult("Count", row, count);
        waitForUser("Your Action Required", "Double click when center point of cross is inside,\n one click when on border or when have doubt.\n Then press OK");
		          getSelectionCoordinates( xpoints, ypoints );
		   if (selectionType() == -1) { // In case there might be zero points selected by the user
		     count = 0;
		   } else {
		     getSelectionCoordinates(xpoints, ypoints);
		     count = xpoints.length;
				   }
   row = nResults;
   setResult("Label", row, getTitle());
   setResult("Count", row, count);
       close();
     	}
     }
saveAs("Results", dir+File.separator+name+"_"+j+"_countResults".csv");


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
Dialog.addMessage("This macro will make a new folder with a TIFF suffix where converted files are saved");
Dialog.show();
fileExtension = Dialog.getString();
//for (i = 0; i < filterStrings.length; i++) {
//	filterStrings[i] = Dialog.getString();	
//	filterTerms[i] = Dialog.getChoice();	
//	}
//displayFileList = Dialog.getCheckbox();
}
//End of function filetype
