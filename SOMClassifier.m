function [DE, ACC, ERR, AUC, SC] = SOMClassifier(F,labelRange,trainingRange,testRange,channel)

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
 
    expected=labelRange(testRange);
    
    H = [DE.C(1).M DE.C(2).M];
    red = newsom(H, [50,50],'gridtop','linkdist',1000);
    red.trainParam.showWindow=0;
    red.trainParam.epochs = 5000;
    red = train(red, H);
    R = sim(red, H(:,:));    
    %plotsompos(red, DE.C(1).M) 
    %plotsompos(red, DE.C(2).M)


    classes=[ones(size(DE.C(1).M,2),1);zeros(size(DE.C(2).M,2),1)];
    myClassifier = ClassificationDiscriminant.fit(R', classes,'discrimType','pseudoLinear');
    predicted =  myClassifier.predict(R');
    
    R = sim(red, TM(:,:));
    predicted = myClassifier.predict(R');

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