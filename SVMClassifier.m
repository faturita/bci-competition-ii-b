function [DE, ACC, ERR, AUC, SC] = SVMClassifier(F,labelRange,trainingRange,testRange,channel)
fprintf('Channel %d\n', channel);
fprintf('Building Test Matrix M for Channel %d:', channel);
[TM, TIX] = BuildDescriptorMatrix(F,channel,labelRange,testRange);
fprintf('%d\n', size(TM,2));

fprintf('Building Training Matrix M for Channel %d:', channel);
[M, IX] = BuildDescriptorMatrix(F,channel,labelRange,trainingRange);
fprintf('%d\n', size(M,2));


DE = NBNNFeatureExtractor(F,channel,trainingRange,labelRange,[1 2],false);

%fprintf('Bag Sizes %d vs %d \n', size(DE.C(1).IX,1),size(DE.C(2).IX,1)); 

expected=labelRange(testRange);

% OJO si hay mas de un descriptor por imagen.

lbs= labelRange(trainingRange);
H = double(M);
TH = double(TM);

% Go SVM
svmStruct = svmtrain(H',lbs,'ShowPlot',true,'kernel_function','linear'); %, 'method','QP');
group = svmclassify(svmStruct,H');

% Check Regularizaton
diffs=group'-lbs;

if (size(find(diffs~=0),2)~=0)
    warning('SVM Regularization is not perfect');
    size(find(diffs~=0),2)
end

group = svmclassify(svmStruct,TH');

predicted = group';

C=confusionmat(labelRange(testRange), predicted)

[X,Y,T,AUC] = perfcurve(expected,predicted,2);

ACC = (C(1,1)+C(2,2)) / size(predicted,2);


SC.CLSF = {};

ERR = size(predicted,2) - (C(1,1)+C(2,2));

SC.FP = C(2,1);
SC.TP = C(2,2);
SC.FN = C(1,2);
SC.TN = C(1,1);

[ACC, (SC.TP/(SC.TP+SC.FP))]

SC.expected = expected;
SC.predicted = predicted;  



end