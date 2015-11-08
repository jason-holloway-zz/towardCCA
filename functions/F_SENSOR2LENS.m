function x = F_SENSOR2LENS(y,samplingIndices,hROW,hCOL,ROW,COL,pupil)
subs = [VEC(samplingIndices);hROW*hCOL];
if ~ismatrix(pupil)
    val = [VEC( (fft2(y)/sqrt(ROW*COL)) .* conj(pupil) ); 0];
else
    val = [VEC(bsxfun(@times,fft2(y)/sqrt(ROW*COL),conj(pupil)));0];
end
x = reshape(accumarray(subs,val),hROW,hCOL);
end