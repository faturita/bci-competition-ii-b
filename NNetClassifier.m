function [DE, ACC, ERR, AUC, SC] = NNetClassifier(F,labelRange,trainingRange,testRange,channel)

    fprintf('Channel %d\n', channel);
    fprintf('Building Test Matrix M for Channel %d:', channel);
    [TM, TIX] = BuildDescriptorMatrix(F,channel,labelRange,testRange);
    fprintf('%d\n', size(TM,2));

    %fprintf('Building Training Matrix M for Channel %d:', channel);
    %[M, IX] = BuildDescriptorMatrix(F,channel,labelRange,trainingRange);
    %fprintf('%d\n', size(M,2));

    % Cae terriblemente la performance si se balancean los datasets.
    DE = NBNNFeatureExtractor(F,channel,trainingRange,labelRange,[1 2],false);

    fprintf('Bag Sizes %d vs %d \n', size(DE.C(1).IX,1),size(DE.C(2).IX,1)); 
 
    H=[DE.C(1).M DE.C(2).M];
    lbs=[DE.C(1).IX(:,2); DE.C(2).IX(:,2)];

%     mdl = stepwiseglm(H', lbs'-1,'constant','upper','linear','distr','binomial');
% 
%     if (mdl.NumEstimatedCoefficients>1)
%        inmodel = [];
%        for i=2:mdl.NumEstimatedCoefficients
%            inmodel = [inmodel str2num(mdl.CoefficientNames{i}(2:end))];
%        end
%        H = H(inmodel,:);
%        TM = TM(inmodel,:);
%     end
    
    
    expected=labelRange(testRange);
    %try
    %predicted = classify(TM',M',labelRange(trainingRange),'linear');
    %net = feedforwardnet([64],'trainbr');
    %net = fitnet([128 64],'traincgb');%'traingdx');128 64
    net = fitnet([128 64],'traincgb')
    net.trainParam.showWindow=0;
    net.layers{1}.transferFcn = 'logsig';
    net.layers{2}.transferFcn = 'logsig';
    net = train(net, H, lbs');

    predicted = net( TM );

    pd = zeros(size(predicted));

    pd(find(predicted>=1.5)) = 2;
    pd(find(predicted<1.5))  = 1;

    predicted = pd;

    %catch
    %predicted = ones(1,size(expected,2))';
    %end

    predicted=predicted;
    

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