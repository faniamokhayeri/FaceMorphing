function T = computeSimilarityT(ptSource, ptTarget)

   x1_s = ptSource(1,1);    y1_s = ptSource(1,2);
   x2_s = ptSource(2,1);    y2_s = ptSource(2,2);
   
   x1_t = ptTarget(1,1);    y1_t = ptTarget(1,2);
   x2_t = ptTarget(2,1);    y2_t = ptTarget(2,2);

   
   b= [x1_t, x2_t, y1_t, y2_t]';
   A= [x1_s -y1_s 1 0; x2_s -y2_s 1 0; y1_s x1_s 0 1;y2_s x2_s 0 1];
   
   x = A\b;
   
   T = [x(1) -x(2) x(3); x(2) x(1) x(4); 0 0 1];

end