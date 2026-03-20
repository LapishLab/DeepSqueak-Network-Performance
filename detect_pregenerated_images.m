function [score, details] = detect_pregenerated_images(detector,image_table, opts)
arguments
    detector yoloxObjectDetector  
    image_table struct   
    opts.plot logical = false % should I plot each box?
end
t = image_table.TTable;
num_images = height(t);


img_peformance = cell(num_images,1);

% Loop through images
for i=1:num_images
    im = imread(t.imageFilename(i));

    prediction = predict_boxes(im, detector);
    img_peformance{i} = get_confusion_from_overlap(t.Boxes{i}, prediction.Box);
    
    if opts.plot
        figure(1); clf;
        % plot real (green) and predicted (blue)
        real_color = "green";
        predicted_color = "blue";
        all_color = [repmat(real_color, size(t.Labels{i}));
            repmat(predicted_color, size(prediction.Labels))];
        all_box = [ t.Boxes{i} ; prediction.Boxes];
        all_label = [t.Labels{i} ; prediction.Labels];
        annotated_img = insertObjectAnnotation(im, "Rectangle", all_box, ...
            all_label, AnnotationColor=all_color);
        imshow(annotated_img)
    end
    fprintf("completed %i/%i\n",i,num_images)
end

details = struct2table(cat(1,img_peformance{:}));

% calculate final score
score = struct();
score.TP = sum(cellfun(@height, details.TP));% total true positive
score.FN = sum(cellfun(@height, details.FN));% total false negative
score.FP = sum(cellfun(@height, details.FP));% total false positive
score.recall = score.TP / (score.TP + score.FN);
score.precision = score.TP / (score.TP + score.FP);
score.F1 = 2*score.precision*score.recall/(score.precision+score.recall);

end

