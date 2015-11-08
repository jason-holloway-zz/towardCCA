function y = forwardModel(im,opts)

ROW = opts.imHeight;
COL = opts.imWidth;

[samplingIndices,pupil,hROW,hCOL] = getSampling(opts);


X = fftshift(fft2(im)); % need to center the FFT
X = padarray(X,floor([(hROW-ROW)/2 (hCOL-COL)/2]));
% X = imresize(X,[hROW hCOL],'nearest');

y = F_LENS2SENSOR(X(samplingIndices),pupil,ROW,COL);

y = abs(y).^2;


end