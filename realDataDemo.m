function [recov,input] = realDataDemo(dataset)
%REALDATADEMO example code for Fourier Ptychography
%   [recov,input] = realDataDemo(dataset)
%   recovers a high resolution image from a series of low resolution inputs
%   saved in dataset.mat. The recovery parameters have been hardcoded to
%   provide the results shown in the paper.
%   NOTE: For real data, the squared magnitude of the recovered image is
%   shown as the recorded input image is also the squared magnitude.
% 
%   - Outputs
%   recov - The recovered m x m complex field, take the inverse fourier
%   transform and view the squared magnitude to compare to the input images
%   
%   input - This is the central view of the N x N sampling grid
% 
%   - Inputs (all necessary parameters have been hard coded)
%   dataset - a string specifying which dataset to use ('USAF',
%   'fingerprint', or 'dasani'). Default ['fingerprint'].

clc, close all force

% make sure the functions are located on MATLAB's path
setupPtych;


if ~exist('dataset','var') || isempty(dataset)
    dataset = 'realData\fingerprint';
end

fprintf('Loading data\n');
data = load([dataset '.mat']);

% get the HDR images
if ndims(data.ims)==5
    fprintf('Forming the HDR images\n');
    data.ims = createHDR(data.ims);
end

fprintf('Recovering the high resolution image\n');
recov = ptychMain(data.ims,data.apDia,data.spacing,data.nIts,[],data.tau);

% compare the input center image and the recovered image
dispRecov = ifft2(ifftshift(recov));
dispRecov = abs(dispRecov).^2;

input = data.ims(:,:,ceil(end/2)); % extract the center image

h = figure(9);
set(h,'name',sprintf('Recovery of %s',dataset),'numbertitle','off');
set(h,'units','normalized','OuterPosition',[0 0 1 1]);
drawnow;
subplot(121)
imagesc(input), colormap(gray), axis image off
title('Center input image')
subplot(122)
imagesc(dispRecov), colormap(gray), axis image off
title('Recovered image')

end