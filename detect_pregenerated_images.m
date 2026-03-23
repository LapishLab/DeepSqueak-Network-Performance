function [score, details, labels] = detect_pregenerated_images(detector,image_table, opts)
arguments
    detector yoloxObjectDetector  
    image_table struct   
    opts.plot logical = false % should I plot each box?
end
t = image_table.TTable;
num_images = height(t);

labels = string(detector.ClassNames);

img_peformance = cell(num_images,numel(labels));

% Loop through images
for i=1:num_images
    im = imread(t.imageFilename(i));

    val = table();
    val.Box = cell2mat(t.Boxes(i));
    val.Type = string(t.Labels{i});

    prediction = predict_boxes(im, detector);
    for ii=1:numel(labels)
        v_box = val.Box(strcmp(val.Type, labels(ii)), :);
        p_box = prediction.Box(strcmp(string(prediction.Type), labels(ii)), :);

        img_peformance{i,ii} = get_confusion_from_overlap(v_box, p_box);
    
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
    end
    fprintf("completed %i/%i\n",i,num_images)
end


details = cell(numel(labels),1);
score = details;
for i=1:numel(labels)
    details{i} = struct2table(cat(1,img_peformance{:,i}));
    score{i} = calc_total_score(details{i});
end

end


function score = calc_total_score(details)
    % calculate final score
    score = struct();
    score.TP = sum(cellfun(@height, details.TP));% total true positive
    score.FN = sum(cellfun(@height, details.FN));% total false negative
    score.FP = sum(cellfun(@height, details.FP));% total false positive
    score.recall = score.TP / (score.TP + score.FN);
    score.precision = score.TP / (score.TP + score.FP);
    score.F1 = 2*score.precision*score.recall/(score.precision+score.recall);
end

