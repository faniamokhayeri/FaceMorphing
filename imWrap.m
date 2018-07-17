function imgT = imWrap(imgS, imgT_pts, tri, affineWrap)
    
    numT = size(tri,1); 

    imgTR = imgS(:,:,1);
%     imgTG = imgS(:,:,2);
%     imgTB = imgS(:,:,3);
    
    imgSR = imgS(:,:,1);
%     imgSG = imgS(:,:,2);
%     imgSB = imgS(:,:,3);


    [imgHeight, imgWidth] = size(imgTR);
    
    idxMat = ones(imgHeight, imgWidth);
    [rows, cols] = (find(idxMat));
 
    T = pointLocation(tri, cols, rows);
    indInvalid = isnan(T);
    indValid = ~indInvalid;
    
    TValid = T(indValid);
    colsValid = cols(indValid);
    rowsValid = rows(indValid);
    
    for indT = 1: numT
        affineCurrT = affineWrap(:,:,indT);
        indCurrT = find(TValid==indT);
        numPinT = length(indCurrT);
        
        b = [colsValid(indCurrT)'; rowsValid(indCurrT)'; ones(1, numPinT)];
        x = round(affineCurrT\b);
        
        validInd = (x(1,:)>0 & x(1,:)<=imgWidth & x(2,:)>0 & x(2,:)<=imgHeight);
        x = x(:,validInd);
        b = b(:,validInd);
        
        indPtTargetCurrT = sub2ind([imgHeight, imgWidth], b(2,:), b(1,:)); indPtTargetCurrT = round(indPtTargetCurrT);
        indPtSourceCurrT = sub2ind([imgHeight, imgWidth], x(2,:), x(1,:)); indPtSourceCurrT = round(indPtSourceCurrT);


        imgTR(indPtTargetCurrT) = imgSR(indPtSourceCurrT);
%         imgTG(indPtTargetCurrT) = imgSG(indPtSourceCurrT);
%         imgTB(indPtTargetCurrT) = imgSB(indPtSourceCurrT);

    end
    imgT = cat(3, imgTR);
end