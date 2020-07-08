/* Macro to count spots inside other spots
 *  Updated March 2020
 *  It now asks whichc hannels the nuclear counterstain and the spots are in (can work with more than 2 channel images)
 *  It still assumes the image is a tif
 *  It looks for nuclei then counts respective spots for each nucleus.
 *  All results get stored in a concatenating results file.
 *  Plus the mask images are stored (all 2 original images converted to masks)
 *  so you can see what it did.
 *  
 *  Input:
 *  Assumes the image is a tif (any number of channels but it has to be 1 z, not a stack) 
 *  It asks for the channel numbers for nuclear counterstain and sub nculear spots
 *  
 *  Note- tifs can be produced via another macro to convert from proprietary file format
 *  
 *  Then you are asked to review the threshold stack it has created and choose the best method.
 *  NOTE- It does NOT work if you choose Huang2!!!!  Some weird choice of 2 different lists in ImageJ.
 *  
 *  Output:
 *  All results get stored in a concatenating results file.
 *  Plus the mask images are stored (all 2 original images converted to masks) so you can check on accuracy.
 *  
 *  To do: convert to python- way easier than this clunky thing, and would be able to deal with 3D datasets.
 *  Add to run from bioformats and only use the chosen filetype (easy enough)
 *  
 *  
 *  Glyn Nelson, Newcastle University Bioimaging Unit
 */

//Variables need to be defined if used between functions and the main macro, not just for sharing between macros.
var fred;
var FociChannel =1;
var DapiChannel = 2;
run("Set Measurements...", "area integrated limit display add redirect=None decimal=0");

setChannelNames();

dir1 = getDirectory("Choose folder with tif files ");
list = getFileList(dir1);

setBatchMode(true);

// create folders for the tifs
	dir1parent = File.getParent(dir1);
	dir1name = File.getName(dir1);
	dir2 = dir1parent+File.separator+dir1name+"_masks";
	if (File.exists(dir2)==false) {
				File.makeDirectory(dir2); // new directory for mask images
		}
for (i=0; i<list.length; i++) {
	showProgress(i+1, list.length);
	print("processing ... "+i+1+"/"+list.length+"\n         "+list[i]);
	filename = dir1 + list[i];
	if (endsWith(filename, "tif")) {
		path=dir1+list[i];
		run("Bio-Formats Importer", "open=["+filename+"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT"); 
		originalImage = getTitle();
		roiManager("Reset");
		selectWindow(originalImage);
		run("Make Composite", "display=Composite");
//		Stack.getDimensions(width, height, channels, slices, frames);
//		run("Stack to Hyperstack...", "order=xyczt(default) channels=channels slices=slices frames=frames display=Color");
		run("Duplicate...", "title=nuc duplicate channels=" +DapiChannel);
		selectWindow("nuc");
		run("Grays");
		BuildThreshStack();  //I am absolutely damned if I can get this to work.  it insists that it the variable ThresholdChoice doesn't exist once I go through this as a function.
		selectWindow("nuc");
		setOption("BlackBackground", true);
		setAutoThreshold(fred);
		run("Threshold");
		run("Watershed");
		run("Analyze Particles...", "size=48-2500 circularity=0.04-1.00 exclude add");
		run("Blue");
		run("16-bit");
//nuclei now added to ROI manager

//next extract h2ax channel
		selectWindow(originalImage);
		run("Duplicate...", "title=h2ax duplicate channels=FociChannel");
		run("16-bit");
		wait(1000);

//next find H2AX foci per nuc
		selectWindow("h2ax");
		rename(originalImage+"_h2ax");
		for(j=0; j<roiManager("count"); j++) {
			roiManager("select", j);
			run("Find Maxima...", "noise=100 output=[Count]");
//	run("Find Maxima...", "noise="+tolerance+" output=[Point Selection]");
			run("Add Selection...");
			}
		saveAs("Results", dir2+File.separator+originalImage+"_h2ax.xls"); //This is saving as it goes along in case it crashes
		selectWindow(originalImage+"_h2ax");
		rename("h2ax2");
		run("Enhance Contrast", "saturated=0.35");
		selectWindow(originalImage);
		wait(1000);
		close();
		run("Merge Channels...", "c1=h2ax2 c2=nuc create");
		rename("masks");
		saveAs("TIFF", dir2+File.separator+originalImage+"_ThresholdMasks.tif");
	close();
	}
setBatchMode(false);
}

showMessage(" Well, I think we gave them a damn good thrashing there, what what??");

// macro 


//FUNCTION- determine channel order
function setChannelNames() {
Dialog.create("Set which channels are which");  //enable use interactivity
Dialog.addMessage("Which channel is DAPI/ nuclear counterstain in?");
Dialog.addString(" DAPI Channel", DapiChannel);	//add extension
Dialog.addMessage("Which channel are the sub-nuclear spots labelled in?");
Dialog.addString("Foci Channel", FociChannel);	//add extension
Dialog.addMessage("Use channel numbers (eg 1,2) to set the channels to use for determining the nuclei and spots");
Dialog.show();
//StringDapiChannel = Dialog.getString(DapiChannel);  ******Apparently don't need to convert a number from a string- it figures it out itself.
//Dapi = parseFloat(StringDapiChannel);
//StringFociChannel = Dialog.getString(FociChannel);
//Foci = parseFloat(StringFociChannel);
}
//need to set var Foci and var Dapi
//End of function setChannelNames




//FUNCTION Choose global Threshold Method
function BuildThreshStack() {
	run("Auto Threshold", "method=[Try all] white show");
selectWindow("Montage"); 
run("Montage to Stack...", "images_per_row=5 images_per_column=4 border=0");
run("RGB Color");
run("Colors...", "foreground=green background=black selection=red");
 style = 4; // Font.BOLD
 call("ij.gui.TextRoi.setFont", "Sans", 32, style) 

//This is nuts, but I've spent so long trying to use arrays or lists to run through this labelling that I've given up.  
//Writting the next 34 lines took less than 10 minutes. Grrrrrrrrr
//run("Label...", "format=0000 x=14 y=20 font=32 text=Method use use_text"); 
setSlice(1);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[Default] range=1-1");
setSlice(2);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[Huang] range=2-2");
setSlice(3);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[Huang2] range=3-3");
setSlice(4);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[Intermodes] range=4-4");
setSlice(5);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[IsoData] range=5-5");
setSlice(6);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[li] range=6-6");
setSlice(7);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[MaxEntropy] range=7-7");
setSlice(8);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[Mean] range=8-8");
setSlice(9);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[MinError] range=9-9");
setSlice(10);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[Minimum] range=10-10");
setSlice(11);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[Moments] range=11-11");
setSlice(12);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[Otsu] range=12-12");
setSlice(13);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[Percentile] range=13-13");
setSlice(14);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[RenyiEntropy] range=14-14");
setSlice(15);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[Shahbhag] range=15-15");
setSlice(16);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[Triangle] range=16-16");
setSlice(17);
run("Label...", "format=Text starting=0 interval=1 x=10 y=30 font=32 text=[Yen] range=17-17");


waitForUser("Browse the Stack to choose the best Method \n then click OK to input your choice");
Dialog.create("Choose your desired threshold");  //enable use interactivity
 Dialog.addChoice("Best threshold is:", newArray("Default", "Huang","Huang2","Intermodes","IsoData","Li","MaxEntropy","Mean","MinError","Minimum","Moments","Otsu","Percentile","RenyiEntropy","Shanbhag","Triangle","Yen"));
Dialog.show();
   fred = Dialog.getChoice();

selectWindow("Stack");
close();

selectWindow("Montage");
close();
}

//ensure var fred is set
//End of function BuildThreshStack


//Neither of the functions belwo are in use in this version.

//FUNCTION- choose autoThreshold method
function choose_me() {
	waitForUser("Browse the Stack to choose the best Method \n then click OK to input your choice");
Dialog.create("Choose your desired threshold");  //enable use interactivity
 Dialog.addChoice("Best threshold is:", newArray("Default", "Huang","Huang2","Intermodes","IsoData","Li","MaxEntropy","Mean","MinError","Minimum","Moments","Otsu","Percentile","RenyiEntropy","Shanbhag","Triangle","Yen"));
Dialog.show();
   fred = Dialog.getChoice();

//print("diaolog gives fred is ", fred);

}
//need to set var fred
//End of function choose_me


//FUNCTION Call_Choice
function Call_Choice(){
	waitForUser("Browse the Stack to choose the best Method \n number then click OK to input your choice");
	Desired_Threshold_Method = getNumber("Choose your Preferred Threshold Number", 0);
	//Stack.getPosition(slice);
	//print ("Your Choice is...", Desired_Threshold_Method);
}
//ensure global var Desired_Threshold_Method is set
//End of Function Call_Choices