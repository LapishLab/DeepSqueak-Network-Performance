good = load('20241012_091000 2024-11-17 ADDED BOXES #2.mat');
test = load("20241012_091000 Detector New #3 Try.mat");
%uigetfile()

%%
goodBoxes = good.Calls.Box;
testBoxes = test.Calls.Box;


%%
good2TestBridge = [];

numGood = size(goodBoxes, 1);
numTest = size(testBoxes, 1);
for i = 1:numGood
    oneGoodBox = goodBoxes(i, :);
    for ii = 1:numTest
        oneTestBox = testBoxes(ii, :);
        
        [gx1,gx2,gy1,gy2] = getCorners(oneGoodBox);
        [tx1,tx2,ty1,ty2] = getCorners(oneTestBox);
        % centGood = [(gx1+gx2)/2 , (gy1+gy2)/2]
        % centTest = [(tx1+tx2)/2 , (ty1+ty2)/2]
        centGoodx = (gx1+gx2)/2;
        centGoody = (gy1+gy2)/2;
        centTestx = (tx1+tx2)/2;
        centTesty = (ty1+ty2)/2;

        iscentGoodOverlapped = centGoodx > tx1 & centGoodx < tx2 & centGoody > ty1 & centGoody < ty2;
        iscentTestOverlapped = centTestx > gx1 & centTestx < gx2 & centTesty > gy1 & centTesty < gy2;
        isOverlapped = iscentGoodOverlapped & iscentTestOverlapped;

        if isOverlapped
            good2TestBridge = [good2TestBridge; i,ii];
        end
    end
end
%% Find accuracy (true positives)


truePositives = size(unique(good2TestBridge(:,1)),1);
totalPositive = size(goodBoxes, 1);
accuracy = truePositives/totalPositive
falsePositives = "to do";
falseNegatives = "to do"


%%
function [x1,x2,y1,y2] = getCorners(box)
    x1 = box(1);
    x2 = x1 + box(3);
    y1 = box(2);
    y2 = y1 + box(4);
end