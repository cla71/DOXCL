/*
 * Macro template to process multiple images in a folder
 */

input = getDirectory("Choose input directory");
output = getDirectory("Choose output directory");
suffix = ".tif";

// See also Process_Folder.py for a version of this code
// in the Python scripting language.

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]))
			processFolder(input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	print("Processing: " + input + file);
	setBatchMode("show");
	open(input + file);
	title=getTitle();
	selectWindow(title);
	setTool("freehand");
	waitForUser("Select CL by tracing around it");
	run("Add Selection...");
	run("To ROI Manager");
	saveAs(".tif", output+file+"selection");
	print("Saving to: " + output);
	close();
	
}
