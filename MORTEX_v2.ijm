// Non-FIJI Dependencies:
// OrientationJ v2.0.5 (https://bigwww.epfl.ch/demo/orientation/)
// GLCM2 v1.0.1 (https://github.com/miura/GLCM2)

// Create the main dialog window
Dialog.create("Matrix ORientation and Texture EXplorer (MORTEX)")
Dialog.addMessage("__________MORTEX__________",20)
Dialog.setInsets(0, 102, 0)
Dialog.addMessage("Specify image file extension:")
Dialog.addString("Input File Extension:", ".xxx");
Dialog.addMessage("___________________________",20)
Dialog.addMessage("https://github.com/cjravensbergen/MORTEX \nCor Ravensbergen \n \nWilma Mesker Lab (c) 2024 \nLeiden University Medical Center, the Netherlands")
Dialog.addHelp("https://github.com/cjravensbergen/MORTEX");
Dialog.show()
  INEXT = Dialog.getString();

	// Set Batch mode
	setBatchMode(true);
	
    // Choose input and output directories
	dirECMin = getDirectory("Choose an image input directory:");
	dirECMout = getDirectory("Choose an image output directory:");
	
	// Create new text file for results
	ECMfile = dirECMout + "ECM_morphometry_results.txt";
	ECMtext = File.open(ECMfile);
	// Add headers to the new text file
	print(ECMtext,"Image\tImage_area_um2\tFiber_bundle_density\tAverage_fiber_length\tBranching_density\tIntersection_density\tCompactness\tTortuosity_index\tDominant_direction\tAnisotropy_index\tFractal_dimension\tUniformity");
	
	/// Create a list of files to be processed that recurses through subdirectories
	processFilesECM(dirECMin);
	function processFilesECM(dirECMin) {
    listECM = getFileList(dirECMin);
    for (i = 0; i < listECM.length; i++) {
        if (endsWith(listECM[i], "/"))
            processFilesECM("" + dirECMin + listECM[i]);
        else {
            pathECM = dirECMin + listECM[i];
            processECM(pathECM);
        	}
    	}
	}
	
	// Loop through each image file  			
    function processECM(pathECM) {
    	if (endsWith(pathECM, INEXT)) {
       		run("Bio-Formats Importer", "open=[" + pathECM + "] autoscale color_mode=Default open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
			images = nImages();
			
			// Run image transformations
       		for (j = 1; j <= images; j++) {
       			
       			// Image pre-processing
  				ECM = getTitle();
  				WithoutExtension = File.nameWithoutExtension;
  				red = "C1-" + ECM;
  				green = "C2-" + ECM;
  				blue = "C3-" + ECM;
  				run("Split Channels");
  				selectWindow(green);
  				close();
  				selectWindow(blue);
  				close();
  		  				
  				// Measure image area and run threshold
  				setOption("BlackBackground", true);
  				selectWindow(red);
  				run("8-bit");
  				// Measure total image area (um)
  				run("Set Measurements...", "area perimeter limit redirect=None decimal=2");
  				run("Measure");
  				Image_area = getResult("Area");
  				// Close the Results table
  				close("Results");
  				
  				// Measure GLCM homogeneity of pixel intensities
  				run("GLCM Texture3", "enter=1 select=0 symmetrical homogeneity");
  				Uniformity = getResult("Homogeneity");
  				close("Results");
  				
  				// Theshold and mask
  				run("Auto Threshold", "method=Default ignore_black ignore_white white");
  				title = getTitle();
  				run("Despeckle");
  				run("Convert to Mask");
  				
            	// Measure total fiber area (um) for fiber thickness estimation
               	run("Analyze Particles...", "summarize");
            	// Rename the results table to copy area and perimeter values
            	IJ.renameResults("Summary", "Results");       	
            	ECMarea = getResult("Total Area");
            	ECMperimeter = getResult("Perim.");
            	// Close the Results table
				close("Results");
				
				// Run OrientationJ Dominant Direction & write results
				run("OrientationJ Dominant Direction");
            	// Rename the results table to copy coherency value
            	IJ.renameResults("Results");
            	Coherency = getResult("Coherency [%]");
            	Orientation = getResult("Orientation [Degrees]");
            	close("Results");
            	close("Log");
            	
            	// Run Fractal Box Count & write results
            	run("Fractal Box Count...", "box=2,3,4,6,8,12,16,32,64 black");
            	// Rename the results table to copy D value
            	IJ.renameResults("Results");
            	Fractal = getResult("D");
            	close("Results");
            	close("Plot");
            	
            	// Skeletonize
            	run("Skeletonize");
				run("Analyze Skeleton (2D/3D)", "prune=none show");
							
				// Sum number of branches
				for (row=0; row<nResults; row++) {
  					branches = getResult("# Branches", row);
  					Total_branches += branches;
        			}	
				
				// Sum number of junctions
				for (row=0; row<nResults; row++) {
  					junctions = getResult("# Junctions", row);
  					Total_junctions += junctions;
        			}
  		        
        		// Sum total fiber lenght
        		close("Results");
        		IJ.renameResults("Branch information", "Results");
        		for (row=0; row<nResults; row++) {
  					fiber_length = getResult("Branch length", row);
  					Total_fiber_length += fiber_length;
        			}
        			  			
				// Calculate Tortuosity
       			for (row=0; row<nResults; row++) {
       				index = getResult("Branch length", row) / getResult("Euclidean distance", row);
    				setResult("Tortuosity", row, index);
       				}
  				updateResults();
  				
  				// Calculate average "Tortuosity index" value, excluding "Infinity" row 
	  			sum = 0;
	  			count = 0;
  				
  				for (row=0; row<nResults; row++) {
  					index = getResult("Tortuosity", row);
    				if (index !="Infinity") {
    					sum += index;
    					count++;
    					}
  					}
  				Tortuosity_index = sum / count;
  				
  				// Calculate ECM parameters
  				Fiber_bundle_density = ECMarea / Total_fiber_length;
  				Average_fiber_length = Total_fiber_length / Total_branches;
  				Branching_density = Total_branches / Total_fiber_length;
  				Intersection_density = Total_junctions / Total_fiber_length;
  				Compactness = ECMarea / ECMperimeter;
  				
  				// Print values to file
				print(ECMtext, WithoutExtension + "\t" + Image_area + "\t" + Fiber_bundle_density + "\t" + Average_fiber_length + "\t" + Branching_density + "\t" + Intersection_density + "\t" + Compactness + "\t" + Tortuosity_index + "\t" + Orientation + "\t" + Coherency + "\t" + Fractal + "\t" + Uniformity + "\n");
            	            	
            	// Close all windows before next image iteration
       			if (isOpen("Results")) {
  					selectWindow("Results"); 
         			run("Close");
         			close("*");
       				}
       		}
    	}
    }
    
// Print message when all images in directory have been processed
Dialog.create("CORTEX complete!")
Dialog.addMessage("Results (.txt) and images can be found in the user-specified output directory.")
Dialog.show()
