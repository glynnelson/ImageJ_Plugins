
macro "measure and label" {

if (nImages==0) {
	exit("No images are open");
}

imageTitle = getTitle();
type = selectionType();

// in case the user forgot to make a selection
if (type == -1) {
	waitForUser("Draw a ROI on the image " + imageTitle + " and press OK");
}

type = selectionType();

// check selection type and measure to perform
if (type==1 || type==2) {
    field = "Area";
} else if (type==5) {
    field = "Length";
} else if (type==8) {
    field = "Angle";
} else {
    exit("I don't know what to do");
}

run("Measure");
label = "" + getResult(field, nResults-1);

// get top left coordinates of bounding box
getSelectionBounds(x, y, width, height);

// add selection and measure as overlays
Overlay.addSelection;
Overlay.drawString(label, x, y)

}
