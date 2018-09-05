function [AccuracyPerChannel, SigmaPerChannel] =   CrossValidated(F,epochRange,labelRange,channelRange, classifyfunction, precvalue)
%% Classification
%print(fig,sprintf('%d-p300averagedpersubject%d.png',expcode,subject),'-dpng')
%clear('fig');

for channel=channelRange
    T=10;
    KFolds=3;
    E = zeros(T,1);

    for t=1:T

        kfolds = fold(KFolds, epochRange);

        N = zeros(KFolds,1);
        EPs = zeros(KFolds,1);

        for f=1:KFolds

            trainingRange=defold(kfolds, f);
            testRange=kfolds{f};

            % --------------------------
            [DE, ACC, ERR, AUC, SC] = classifyfunction(F,channel,trainingRange,labelRange,testRange,false);

            N(f) = ERR;
            
            switch precvalue
                case 1
                    EPs(f) = ERR/size(testRange,2);
                case 2
                    EPs(f) = 1- SC.TP / (SC.TP+SC.FP);
                otherwise
                    error('Not valid eficiency measurement.');
            end
            
            %EPs(f) = 1-AUC;
            

            % -hat -----------------------

        end

        %E(t) = sum(N)/size(epochRange,2);
        E(t) = mean(EPs);

    end

    e= sum(E)/T;
    V = (sum((( E - e ).^2)))  / (T-1);

    sigma = sqrt( V );
    
    ErrorPerChannel(channel)=e;
    SigmaPerChannel(channel)=sigma;
end

AccuracyPerChannel = 1-ErrorPerChannel ;
SigmaPerChannel=SigmaPerChannel.*(1.96/(sqrt(T)));

% This is now the averaged value of error k-fold cross validated.
ACCij=AccuracyPerChannel;
ACCijsigma=SigmaPerChannel;


graphics=false;
if (graphics)
    figure
    bar(AccuracyPerChannel(channelRange));
    %title(sprintf('Exp.%d:k(%d)-fold Cross Validation NBNN: %d, %1.2f',expcode,KFolds,siftdescriptordensity,siftscale));
    xlabel('Channel')
    ylabel('Accuracy')
    axis([0 size(channelRange,2)+1 0 1.3]);
end

%subjectACCij(subjectnumberofsamples,subject,:) = ACCij(:);
%subjectACCijsigma(subjectnumberofsamples,subject,:) = ACCijsigma(:);

end