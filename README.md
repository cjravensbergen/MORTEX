# Matrix ORientation and Texture EXplorer (MORTEX)
**Version October 2024**  
**Mesker lab, Leiden University Medical Center, the Netherlands**  
_C. Ravensbergen (c.j.ravensbergen@lumc.nl)_

---
### Description  
This ImageJ macro facilitates automated processing and analysis of `extracellular matrix (ECM)` microscopy images from **Picrosirius red-stained** tissue sections captured using **fluorescent imaging**.  
<br/>
`MORTEX` provides quantitative output for ten matrix and fiber parameters:
 - `Tortuosity`
 - `Compactness`
 - `Uniformity`
 - `Intersection density`
 - `Fractal dimension`
 - `Fiber bundle density`
 - `Dominant direction`
 - `Branching density`
 - `Average fiber length`
 - `Anisotropy index` 

See the description table in the `instruction manual` for details. 
The macro is optimized for batch processing of multiple images, returning a dataframe with measurements to the user-specified output directory.  
Quantitative metrics (.txt file) are returned to the user in user-specified directories.

**Citation for MORTEX:**  

---
### Installation & Dependencies
#### Requirements
- Windows OS
- [ImageJ](https://imagej.nih.gov/ij/download.html) (version 1.54f or later) or [FIJI](https://fiji.sc/) (preferred software).
#### Plugin Dependencies
_Please install/[update](https://imagej.net/plugins/updater) the following ImageJ plugins for proper_ `CORTEX` _functioning:_
 - [`OrientationJ`](http://bigwww.epfl.ch/demo/orientationj/) (version **2.0.5** or later)
 - [`AnalyzeSkeleton`](https://imagej.net/plugins/analyze-skeleton/) (version 3.4.2 or later)
 - [`GLCM2`](https://github.com/miura/GLCM2) (version 1.0.1 or later)
 - [`Bio-Formats`](https://imagej.net/formats/bio-formats) (version 6.14.0 or later)

#### MORTEX Installation
1. Download [`MORTEX.ijm`](https://github.com/fiji/fiji) file.
2. Copy the `MORTEX.ijm` file to your ImageJ/FIJI.app `plugins` directory.
3. Restart `FIJI`.
4. `MORTEX` is now available in the `Plugins` tab.

---
### How to Use?

Please refer to the [`Instruction Manual`](https://github.com/fiji/fiji) for a detailed guide on how to use `CORTEX` for collagen image analysis.

---
### License

`MORTEX` is available under `GPL3` license.
