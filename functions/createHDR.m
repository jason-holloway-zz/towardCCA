function hdrIms = createHDR(ims,startExp)

if nargin < 2
    startExp = 1;
end

[h,w,nX,nY,nE] = size(ims);

hdrIms = zeros(h,w,nX,nY);

for ii = 1:nX
    for jj = 1:nY
        hdrIms(:,:,ii,jj) = myHDR(squeeze(ims(:,:,ii,jj,:)), 2.^(startExp+(0:nE-1)) );
    end
end


end

function im = myHDR(ims,exps)

if length(exps)~=size(ims,3)
    error('Must have as many exposures as images');
end

exps = exps/max(exps);

im = zeros(size(ims,1),size(ims,2));

if ~isfloat(ims)
    ims = im2double(ims);
end

satVal = 230/255;
targetVal = 175/255;
minVal = 20/255;

% if length(exps)>1
%     ims(ims>satVal)=-1;
% end

ims(ims<minVal)=0;

err = abs(ims-targetVal);
[~,mask] = min(err,[],3);

% check for saturation in the shortest exposure
tmp = ims(:,:,1);
mask(tmp>satVal)=1;

ims = reshape(ims,[],size(ims,3));

for ii = 1:size(ims,1)
    im(ii) = ims(ii,mask(ii)) / exps(mask(ii));
end



end