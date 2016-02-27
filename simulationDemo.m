function [recov,input,gt] = simulationDemo(dataset,apDia,overlap,N,SNR,nIts)
%SIMULATIONDEMO example code for Fourier Ptychography
%   [recov,input,gt] = simulationDemo(dataset,apDia,overlap,N,SNR)
%   simulates capturing the test image saved in dataset.mat with the
%   parameters supplied in apDia, overlap, N, and SNR. After nIts 
%   iterations, the function returns the recovered complex field, the 
%   center input images, and the ground truth high resolution image. All 
%   parameters are optional and will be set to the default if not provided
%   or if they are empty.
%   NOTE: In simulation, the magnitude of the input image is shown (not the
%   squared magnitude) to make direct comparisons between the three
%   outputs.
% 
%   - Outputs
%   recov - The recovered m x m complex field, take the inverse fourier
%   transform and view the magnitude to compare to the input and gt images
%   
%   input - This is the central view of the N x N sampling grid (the
%   magnitude, not the squared magnitude)
%   
%   gt - The magnitude of the ground truth image. For simplicity we assume
%   an amplitude only object (zero phase)
% 
%   - Inputs (all optional)
%   dataset - a string specifying which dataset to use either 'resChart' or
%   'lena'. Default ['resChart']
%   
%   apDia - The diameter of the aperture in pixels. A 60 pixel diameter
%   roughly corresponds to an aperture of f/32 (for a 512x512 input image).
%   Default [60]
% 
%   overlap - Desired overlap as a fraction in the range [0,1]. If the
%   amount of overlap is less than .5 the reconstruction quality may be
%   poor. Default [.61]
% 
%   N - The number of images along one dimension of the N x N sampling
%   grid. Default [17]
%   
%   SNR - Desired SNR (dB) for each input image. Gaussian noise is added to
%   create the desired SNR. Inputting a value of inf will result in a
%   noiseless run. Default [30]
% 
%   nIts - The number of iterations in the phase retreival loop. The number
%   of iterations depends on the ground truth image and the number of
%   inputs. Small values of N converge more rapidily than large values of
%   N. The default value is conservative, decrease this number to reduce 
%   running time. Default [1000]


clc, close all force

% make sure the functions are located on MATLAB's path
setupPtych;

% check to see which input parameters have been provided
if ~exist('dataset','var') || isempty(dataset)
    dataset = 'resChart';
end

if ~exist('apDia','var') || isempty(apDia)
    apDia = 60;
end

if ~exist('overlap','var') || isempty(overlap)
    overlap = .61;
end

if ~exist('N','var') || isempty(N)
    N = 17;
end

if ~exist('SNR','var') || isempty(SNR)
    SNR = 30;
end

if ~exist('nIts','var') || isempty(nIts)
    nIts = 1000;
end


% load the ground truth image
try
    load([dataset '.mat'],'im');
catch
    error('Dataset must contain a variable called ''im''');
end

% convert to floating point (use singles to save memory)
im = im2single(im); %#ok<NODEF>
if ~ismatrix(im) % provided images are grayscale, just to double check
    im = rgb2gray(im);
end
[h,w] = size(im);
gt = im;

% determine the spacing between adjacent apertures (in pixels)
spacing = apDia * (1-overlap);

% set up the options necessary to create the sampled images see
% "getSampling.m" for more details
opts = struct();
opts.imHeight = h;
opts.imWidth = w; 
opts.nX = N; 
opts.nY = N;
opts.apertureShift = spacing; 
opts.apDia = apDia;
opts.pupilType = 'circle';
opts.samplingPattern = ones(opts.nY,opts.nX);


% create the observed images
fprintf('Creating the input data cube\n');
y = forwardModel(im,opts); % y is the squared magnitude

fprintf('Adding noise\n');
% add noise
if ~isinf(SNR)
    y = addNoise(y,SNR);
end
y(y<0)=0; % input cannot be negative (avoid noise causing a negative signal)

% % resize input images IFF the aperture diameter is at most 1/4 the size
% % of the input images
% if apDia/h <= .25
%     y = imresize(y,.5,'bilinear');
% end

fprintf('Recovering high resolution image');
% recover the high resolution image
recov = ptychMain(y,apDia,spacing,nIts,opts.samplingPattern);


% display the ground truth, input, and recovered magnitudes
dispRecov = ifft2(ifftshift(recov));
dispRecov = abs(dispRecov);

input = y(:,:,ceil(end/2)); % extract the center image
input = sqrt(input); % display the magnitude of the observation (not the squared magnitude)

h = figure(10);
set(h,'name',sprintf('Simulation of %s',dataset),'numbertitle','off');
set(h,'units','normalized','OuterPosition',[0 0 1 1]);
drawnow;
subplot(131)
imagesc(gt), colormap(gray), axis image off
title('Ground truth image')
subplot(132)
imagesc(input), colormap(gray), axis image off
title('Center input image')
subplot(133)
imagesc(dispRecov), colormap(gray), axis image off
title('Recovered image')


end