function output = generate_blank_YOLOX(save_path, img_info)

labels = unique(cat(1, img_info.TTable.Labels{:}));

if img_info.image_size(3) ~= 3
    error("3rd dimension of image needs to be size 3 (color image)")
end
in_sz = img_info.image_size;
in_sz([1,2]) = round(in_sz([1,2])/32)*32; %Round XY dimensions to the nearest multiple of 32


% model size options
    % 'nano-coco'
    % 'tiny-coco'
    % 'small-coco'
    % 'medium-coco'
    % 'large-coco'
detector = yoloxObjectDetector('small-coco', labels, InputSize=in_sz);


output = struct();
output.detector = detector;
output.settings = img_info.settings;
save(save_path, '-struct', 'output');
end