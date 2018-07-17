function [morphed_im, imMorph_pts] = morph(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac)

    imMorph_pts =  (1-warp_frac)*im1_pts + (warp_frac)*im2_pts;  
    
    numTriangle = size(tri, 1);
    affineWrap1 = zeros(3,3,numTriangle);
    affineWrap2 = zeros(3,3,numTriangle);
    
    for indT = 1: numTriangle
        affineWrap1(:,:,indT) = computeAffine(im1_pts(tri(indT,:),:), imMorph_pts(tri(indT,:),:));
        affineWrap2(:,:,indT) = computeAffine(im2_pts(tri(indT,:),:), imMorph_pts(tri(indT,:),:));
    end
    
     
    img1_wraped = imWrap(im1, imMorph_pts, tri, affineWrap1);
    img2_wraped = imWrap(im2, imMorph_pts, tri, affineWrap2);
    

    imgW = 96;
    
    img1_wraped = img1_wraped(:, 1:imgW,:);
    img2_wraped = img2_wraped(:, 1:imgW,:);
    
    morphed_im = uint8((1-dissolve_frac)*double(img1_wraped) + (dissolve_frac)*double(img2_wraped));
    
end




