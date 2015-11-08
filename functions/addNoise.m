function y = addNoise(y,SNR)
if isinf(SNR)
    return
end

[h,w,nY,nX] = size(y);

for ii = 1:nY*nX
    tmp = y(:,:,ii);
    v = var(tmp(:)) / 10^(SNR/10);
    sig = sqrt(v);
    y(:,:,ii) = y(:,:,ii)+randn(h,w)*sig;
end

end