function y = F_LENS2SENSOR(x,pupil,ROW,COL)
 %induces phase shift on y, but we don't care about the phase of y
if isequal(size(x),size(pupil))
    y = ifft2(x.*pupil);
else
    y = ifft2(bsxfun(@times,x,pupil));
end
y = y*sqrt(ROW*COL);
end