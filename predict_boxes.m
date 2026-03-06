function prediction = predict_boxes(im, detector)
    [bboxes, scores, labels] = detect(detector, im);
    [bboxes,scores,ind] = selectStrongestBbox(bboxes, scores, OverlapThreshold=0);
    labels = labels(ind);

    prediction = table();
    prediction.Boxes = bboxes;
    prediction.Scores = scores;
    prediction.Labels = labels;
end