function prediction = predict_boxes(im, detector)
    [bboxes, scores, labels] = detect(detector, im);
    [bboxes,scores,ind] = selectStrongestBbox(bboxes, scores, OverlapThreshold=0);
    labels = labels(ind);

    prediction = table();
    prediction.Box = bboxes;
    prediction.Score = scores;
    prediction.Type = labels;
    prediction.Accept = ones(length(labels),1);
end