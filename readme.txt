Read Me

DOXCL

Below is a summary of each imageJ macro and how they were used.

ImageJ Analysis – LIPID DROPLET
1.	Create folder with “.tif” images
a.	Other image filetypes can be used but conversion to “.tif” is easy in imageJ (Process>Batch>Convert)
2.	Run “roiselector_v2.ijm”
a.	Select the folder with “.tif” images
b.	Create output-folder 1 and select folder
3.	Circle CLs
4.	Run “uniformSelection_largeCL_75_200.ijm”
a.	Select output-folder 1 with circled CL images
b.	Create output-folder 2 and select folder
5.	To perform Quantile Based Normalization:
a.	ImageJ>Plugins>Process>Quantile Based Normalization
b.	Add all images from output-folder 2
c.	Find “Output directory:” and select “Choose…”
d.	Create output-folder 3 and select
e.	Set “Replace each quantile with” to “rank”
f.	Check “Rescale”
g.	Press “OK”
6.	ImageJ>Process>Batch>Macro to run quantification script.
