function overlap_percentage = calc_box_overlap(A, B)
% calculate the percent overlap of detection boxes
    overlap_area = rectint(A, B);
    A_area = A(:,3) .* A(:,4);
    B_area = B(:,3) .* B(:,4);
    total_area = A_area + B_area' - overlap_area;
    overlap_percentage = overlap_area ./ total_area; 
end