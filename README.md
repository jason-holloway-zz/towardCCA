# towardCCA
Code and data from "Toward Long Distance, Sub-diffraction Imaging Using Coherent Camera Arrays"

### Toward Coherent Camera Arrays
The files presented here offer a more general framework for our reconstruction methods than described in the paper. In the paper, we assume a square grid of evenly spaced apertures.
In the provided codes the square evenly spaced grid is still assumed, but we introduce a sampling pattern option which allows users to create non-square grids with arbitrary sampling patterns. This is not meant to be a truly flexible framework for ptychography, but a useful launching point to allow for direct comparisons of our method with other implementations. In order to recreate the results in our paper, the sampling pattern option may be ignored.

Limitations and caveats about the output size:
For the sake of simplicity, our codes require observed image to be square, and with an even number of pixels in each spatial dimension. If the inputs are not square, we will pad the images with zeros to make it so.
The output of the phase retreival algorithm is the high resolution complex field at the aperture (or Fourier) plane. The spatial dimensions of the output are determined by the aperture diameter (provided in pixels), the amount of overlap (in pixels), and the number of underlying images in the sampling grid, which taken together yields the Synthetic Aperture Ratio (SAR). The output is also padded with a buffer zone to avoid clipping the Fourier reconstruction, this buffer can safely be ignored either by cropping the complex field or leaving it in place. Because the size of the output is dependent on the SAR, it will, in general, not be the same size as the input images. One may simply pad (or crop) the m x m output to the same size as the n x n input images to see a direct comparison. If the output has Fourier information that is larger than n x n, you will be losing information by cropping the output. (Except for simulations, then there is no information outside of the n x n region as we do not downsample the images.)

Code structure:
The codes are written in a decentralized fashion to keep the main file clean and to make the codes (hopefully) easier to follow. Functions in all capital letters are helper functions which are called using function handles inside of the main solver.

NOTE: The provided codes are soley dependent on the number of iterations provided by the user. In general there is a backprojection critera which stops the algorithm once the solution has converged, but this is not present here to allow the user more flexibility when experimenting with the codes.

### Data
Alignment:
In our experimental setup, data is collected by translating a camera using a 2D stage. The change in perspective between each viewpoint induces a depth-based disparity which must be corrected for. As the targets are planar, homographies can be used to warp each of the images to align with the center viewpoint. We compute these homographies by finding fiducial markers in the scene. These features are taken to be the corners of a chessboard pattern which is affixed around the target within the field of view of the camera. The datasets provided here have already been aligned and cropped to remove the checkerboard pattern (this both reduces the file size and ensures repeatability).

Dyanmic range:
For natural images, and the data collected for this paper, the energy in the Fourier transform is concentrated in low frequences. As we scan the camera aperture away from the center, the energy falls off which in turn causes the intensity of the captured image to fall off as well. We account for the difference in intensity by capturing a set of images with varying exposure times at each camera position. From the 5D data cube (2 image spatial dimensions, 2 camera translation dimensions, 1 temporal/exposure dimension) we run a naive HDR algorithm to acquire the final input data. The approach we take is that for each pixel location, select the exposure where the intensity is closest to 175 (in order to avoid non-linearities in the camera response when the intensity rises above 230). We also explicity set pixel intensities below 20 to 0 (to suppress noise for underexposed regions) and set pixels above 230 to 255 (to avoid non-linearities). The full 5D data cubes are included in this repository along with the code to form the HDR images.

Noise:
During image acquisition we use image averaging to reduce image noise. We record 10 images for each camera position and exposure level. These images are immediately averaged and the final image is saved as the observation for that camera position and exposure level. No intermediate images are saved, and the data presented here is the result of using this image acquisition scheme.

### Additional information and details
For more information, see the project webpages [webpage 1](http://jrholloway.com/projects/towardCCA) and [project page at Northwestern](http://compphotolab.northwestern.edu/project/towardcca/). Our paper may be viewed on [Arxive.org](http://arxiv.org/abs/1510.08470), though some compression artifacts may be present in some images due to file size constraints. Full resolution images are available on the project web pages.