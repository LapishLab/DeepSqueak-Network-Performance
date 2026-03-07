function output = generate_blank_YOLOX(save_path, settings, labels)
% Estimate size of training images and round to nearest mult of 32
s=settings;
y_pix = (s.max_frequency-s.min_frequency)/s.step_frequency;
x_pix = (s.wind/s.noverlap)*(s.img_dur/s.wind)-1;
mult32 = @(x) round(x/32)*32;
input_sz = [mult32(y_pix), mult32(x_pix), 3];

% model size options
    % 'nano-coco'
    % 'tiny-coco'
    % 'small-coco'
    % 'medium-coco'
    % 'large-coco'
detector = yoloxObjectDetector('small-coco', labels, InputSize=input_sz);


output = struct();
output.detector = detector;
output.settings = settings;
save(save_path, '-struct', 'output');
end