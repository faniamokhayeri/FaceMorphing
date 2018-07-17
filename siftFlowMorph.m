function imMorph = siftFlowMorph(img1, img2, vx, vy, warp_frac, dissolve_frac)

    patchsize = 8;
    img1=img1(patchsize/2:end-patchsize/2+1,patchsize/2:end-patchsize/2+1,:);
    img2=img2(patchsize/2:end-patchsize/2+1,patchsize/2:end-patchsize/2+1,:);
    
    warpI1=warpImage(img1, -warp_frac*vx, -warp_frac*vy);
    warpI2=warpImage(img2,(1-warp_frac)*vx, (1-warp_frac)*vy);

    imMorph = (1-dissolve_frac)*warpI1 + (dissolve_frac)*warpI2;
    imMorph = imMorph/96;
end