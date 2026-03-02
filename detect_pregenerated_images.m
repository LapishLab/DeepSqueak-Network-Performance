function performance = detect_pregenerated_images(detector,image_table, opts)
arguments
    detector yoloxObjectDetector  
    image_table struct   
    opts.plot logical = false % should I plot each box?
end
t = image_table.TTable;
num_images = height(t);

% Prepare an empty table similar to TTable to hold predicted values
predicted = table(size=[num_images,width(t)], ...
    VariableNames=t.Properties.VariableNames, ...
    VariableTypes=t.Properties.VariableTypes);
predicted.imageFilename = t.imageFilename;
predicted.Score = cell(height(predicted),1);

% Loop through images
for i=1:num_images
    im = imread(t.imageFilename(i));

    [bboxes, scores, labels] = detect(detector, im);
    predicted.Boxes{i} = bboxes;
    predicted.Labels{i} = labels;
    predicted.Score{i} = scores;
    
    if opts.plot
        figure(1); clf;
        % plot real (green) and predicted (blue)
        real_color = "green";
        predicted_color = "blue";
        all_color = [repmat(real_color, size(t.Labels{i}));
            repmat(predicted_color, size(labels))];
        all_box = [ t.Boxes{i} ; bboxes];
        all_label = [t.Labels{i} ; labels];
        annotated_img = insertObjectAnnotation(im, "Rectangle", all_box, ...
            all_label, AnnotationColor=all_color);
        imshow(annotated_img)
    end
end

truth_boxes = cat(1, t.Boxes{:});
test_boxes = cat(1, predicted.Boxes{:});
performance = get_confusion_from_overlap(truth_boxes, test_boxes);
end