// -------------------------------------------------------------------
// Written by: Patrice Mascalchi
// Date: 2020-02
// DRVision Technologies LLC
// -------------------------------------------------------------------

// **** manual parameters ****
nCh = 2;

// ********************************

// Get image directory ---------------
path = getDirectory("Choose the directory containing your files");
flist = SortFileList(path, ".tif");
if (!endsWith(path, File.separator)) path = path + File.separator;

// Get name of selected folder
tmp = File.getParent(path);
parentDir = substring(path, lengthOf(tmp)+1);
if (!endsWith(parentDir, File.separator)) parentDir = parentDir + File.separator;
if (lengthOf(parentDir) > 20) parentDir = substring(parentDir, 0, 20);

// Defining output directory
outdirs = newArray(nCh);
for (o=0; o<nCh; o++) {
    outdirs[o] = path + "C" + o+1 + "-" + parentDir;
    if (!File.exists(outdirs[o])) File.makeDirectory(outdirs[o]);
}

setBatchMode(true);

// Processing the files
for (f=0; f<flist.length; f++) {
    fname = flist[f];
    // run("Bio-Formats Importer", "open=[" + path + flist[f] +"] autoscale color_mode=Composite view=Hyperstack stack_order=Default);
    open(path + fname);
    print("Processing "+ f+1 +"/"+ flist.length +": "+ fname);

    nSl = nSlices / nCh;

    run("Stack to Hyperstack...", "order=xyczt(default) channels="+nCh+" slices="+nSl+" frames=1 display=Color");

    run("Split Channels");
    
    for (c=1; c<=nCh; c++) {
        selectWindow("C"+ c +"-"+ fname); 
        saveAs(outdirs[c-1] +"C"+ c +"-"+ fname);
    }
    run("Close All");
}
setBatchMode(false);
print("Done!");

// --------------------------------------------------
function SortFileList(path, filter) {		// Sort with endsWith
	flist = getFileList(path);
	OutAr = newArray(flist.length);
	ind = 0;
	for (f=0; f<flist.length; f++) {
		//print(flist[f] + " : "+endsWith(flist[f], filter));
		if (endsWith(flist[f], filter)) {
			OutAr[ind] = flist[f];
			ind++;
		}
	}
	return Array.trim(OutAr, ind);
}
