good = load('20241012_091000 2024-11-17 ADDED BOXES #2.mat');
test = load("20241012_091000 Detector New #3 Try.mat");
%uigetfile()

%%
goodBoxes = good.Calls.Box;
testBoxes = test.Calls.Box;


[gx1,gx2,gy1,gy2] = getCorners(goodBoxes);
[tx1,tx2,ty1,ty2] = getCorners(testBoxes);

centGoodx = (gx1+gx2)/2;
centGoody = (gy1+gy2)/2;
centTestx = (tx1+tx2)/2;
centTesty = (ty1+ty2)/2;
% is center point of "Good" box inside the bounds of "Test" box
iscentGoodOverlapped = centGoodx' > tx1 & centGoodx' < tx2 & centGoody' > ty1 & centGoody' < ty2;
% is center point of "Test" box inside the bounds of "Good" box
iscentTestOverlapped = centTestx > gx1' & centTestx < gx2' & centTesty > gy1' & centTesty < gy2';
% if both of the above are true, we consider Test box is same as Good box
isOverlapped = iscentGoodOverlapped & iscentTestOverlapped;

TestMatches = sum(isOverlapped,2);
truePositives = sum(TestMatches > 0);

%% Find accuracy (true positives)
truePositives = size(unique(good2TestBridge(:,1)),1);
totalPositive = size(goodBoxes, 1);
accuracy = truePositives/totalPositive
falsePositives = "to do";
falseNegatives = "to do"


%%
function [x1,x2,y1,y2] = getCorners(box)
    x1 = box(:,1);
    x2 = x1 + box(:,3);
    y1 = box(:,2);
    y2 = y1 + box(:,4);
end