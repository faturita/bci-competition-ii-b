function [DE, ACC, ERR, AUC, SC] = LDAClassifier(F,labelRange,trainingRange,testRange,channel)
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


% Fit a naive Bayes classifier
%mdlNB = fitcnb(pred,resp);

% Classification based on LDA
%b = stepwisefit(H,lbs');


mdl = stepwiseglm(H', lbs'-1,'constant','upper','linear','distr','binomial');

if (mdl.NumEstimatedCoefficients>1)
   inmodel = [];
   for i=2:mdl.NumEstimatedCoefficients
       inmodel = [inmodel str2num(mdl.CoefficientNames{i}(2:end))];
   end
   H = H(inmodel,:);
   TH = TH(inmodel,:);
end


size(TH)
size(H)
size(lbs)

lbls = classify(TH',H',lbs','linear');

% Classification based on SWLDA
c = cvpartition(lbs,'k',10);
opts = statset('display','iter');
fun = @(XT,yT,Xt,yt)...
      (sum(~strcmp(yt,classify(Xt,XT,yT,'linear'))));

%[fs,history] = sequentialfs(fun,pred,resp,'cv',c,'options',opts);

% 
% size(H')
% size(lbs)
% 
% %[fs,history] = sequentialfs(fun,H,lbs)
% 
% 
% sM = M(:,fs);
% 
% fs
% size(TM)
% size(sM)
% size(lbs)
% 
% %swldalbls = classify(TM,sM,lbs,'linear');

group = lbls;

predicted = group';

size(predicted)
size(labelRange(testRange))

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