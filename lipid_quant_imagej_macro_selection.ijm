imageTitle= getTitle();
run("Subtract Background...", "rolling=50");
setAutoThreshold("Otsu dark");
//run("Threshold...");
//setThreshold();
setOption("BlackBackground", false);
run("Convert to Mask");
run("Watershed");
saveAs("Jpeg", "//nas.vet.uga.edu/Departmental/Physiology/YeLab/Christian/DOX/DOX CL/Expression/IF/Ovary/Lipid Droplet/Nile Red/Final Analysis/binary images/"+imageTitle+".jpg");
run("Analyze Particles...", "size=2-2000 pixel circularity=0.5-1.00 display exclude summarize add");
close();
