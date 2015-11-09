function [samplingIndices,pupil,hROW,hCOL] = getSampling(opts)

ROW = opts.imHeight;
COL = opts.imWidth;
Tx = opts.nX;
Ty = opts.nY;
apShift = opts.apertureShift;
apDia = opts.apDia;
pupilType = opts.pupilType;
samplingPattern = opts.samplingPattern;

% create the pupil
switch lower(pupilType)
    case 'circle'
        pupil = imresize(padarray(fspecial('disk', apDia/2), floor((ROW - apDia)/2)*[1 1]), [ROW COL],'bilinear');
        pupil(pupil~=0)=1;
    case 'disk'
        pupil = imresize(padarray(fspecial('disk', apDia/2), floor((ROW - apDia)/2)*[1 1]), [ROW COL],'bilinear');
        pupil = pupil/max(pupil(:));
    case 'square'
        pupil = ones([ROW COL]);
    otherwise
        error('Pupil type not supported');
end
pupil = single(pupil);

% create the sampling indices
hROW = ROW+floor(apShift*(Tx-1));
hCOL = COL+floor(apShift*(Ty-1));

% % check to make sure hROW and hCOL are correctly sized
% if (apShift-floor(apShift)) > eps
%     if mod(hROW,2)==1
%         hROW = hROW+1;
%     end
%     if mod(hCOL,2)==1
%         hCOL = hCOL+1;
%     end
% end

% check to see if the shift is fractional
if (apShift - floor(apShift)) > eps
    subpixel = true;
    pupil_mask = zeros([size(pupil) sum(samplingPattern(:))],'single');
else
    subpixel = false;
end

samplingIndices = zeros(ROW,COL,sum(samplingPattern(:)));
count = 0;
for tr = 1:Tx
    for tc = 1:Ty
%         rind = repmat(VEC((1:ROW)+(tc-1)*apShift), ROW,1); % no partial shifts allowed
%         cind = VEC(repmat((1:COL)+(tr-1)*apShift+1, COL,1)); % no partial shifts allowed
        if ~samplingPattern(tc,tr)
            continue; % no data was captured here, skip
        end
        count = count+1;
        yi = (tc-1)*apShift;
        xi = (tr-1)*apShift;
        rind = repmat(VEC((1:ROW)+floor(yi)), ROW,1);
        cind = VEC(repmat((1:COL)+floor(xi), COL,1));
        samplingIndices(:,:,count) = reshape(sub2ind([hROW,hCOL],rind,cind),ROW,COL);
        
        if subpixel
            aper = imtranslate(pupil,[yi-floor(yi) xi-floor(xi)],'bilinear');
            pupil_mask(:,:,count) = aper;
        end
    end
end

if subpixel
    pupil = pupil_mask;
end

end