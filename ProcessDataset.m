% Signal Averaging x Selection classification of P300 BCI Competition II
rng(396544);

globalexperiment='';

globalnumberofepochs=15;
globalaverages= cell(2,1);
globalartifacts = 0;
globalnumberofsamples=(2+10)*15-1;

%for globalnumberofsamples=(2+10)*[10 5 1]-1

clear mex;clearvars  -except global*;close all;clc;

nbofclasses=(2+10)*1;
breakonepochlimit=true;

% Clean all the directories where the images are located.
cleanimagedirectory();


% NN.NNNNN
% data.X(sample, channel)
% data.y(sample)  --> 0: no, 1:nohit, 2:hit
% data.y_stim(sample) --> 1-12, 1-6 cols, 7-12 rows

%     'Fz'    'Cz'    'Pz'    'Oz'    'P3'    'P4'    'PO7'    'PO8'

channels={ 'Fz'  ,  'Cz',    'Pz' ,   'Oz'  ,  'P3'  ,  'P4'   , 'PO7'   , 'PO8'};


% Parameters ==========================
epochRange = 1:120*7*5;
channelRange=1:2;
labelRange = zeros(1,4200);
stimRange = zeros(1,4200);


imagescale=4;
timescale=4;
siftscale = [ 3 3];

siftdescriptordensity=1;
Fs=240;
windowsize=1;
expcode=2400;
show=0;
% =====================================
classifier=3;

downsize=16;


Speller = [];

% EEG(subject,trial,flash)
[EEG, stimRange, labelRange] = loadBCICompetition(Fs, windowsize, downsize, 180, 1:1,channelRange);

% CONTROL
%EEG = randomizeEEG(EEG);

stimRange=[];
labelRange=[];

tic
Fs=Fs/downsize;
F(1,1,1) = struct();EP=[];CF=[];
for subject=1:1
    epoch=0;
    for trial=1:73
        for i=1:12 routput{i}=[]; end
        for i=1:12 rcounter{i}=0; end
        processedflashes = 0;
        bpickercounter = 0;
        bwhichone = [0 1];%bwhichone=sort(randperm(10,2)-1);
        for flash=1:180
            
            % Process one epoch if the number of flashes has been reached.
            if (processedflashes>globalnumberofsamples)
                if (breakonepochlimit)
                    break;
                end
                [F, rmean, epoch, labelRange, stimRange] = AverageGetFeature(F,subject,epoch,trial,channelRange,Fs,imagescale,timescale,siftscale,siftdescriptordensity,routput,rcounter,hit,nflash, labelRange,stimRange);

                globalaverages{subject}{trial}{1}.rmean = rmean;
                processedflashes=0;
            end
            
            % Skip artifacts
            if (EEG(subject,trial,flash).isartifact)
                continue;
            end
            
            if (mod(flash-1,12)==0)
                bpickercounter = 0;
                bwhichone = [0 1];%bwhichone=sort(randperm(10,2)-1);
            end
            
            labelh = EEG(subject,trial,flash).label;
            output = EEG(subject,trial,flash).EEG;
            stim = EEG(subject,trial,flash).stim;
            
            processedflashes = processedflashes+1;
            
            hit{stim} = labelh;
            nflash{stim} = flash;
            
            if (rcounter{stim}<globalnumberofepochs)
                routput{stim} = [routput{stim}; output];
                rcounter{stim}=rcounter{stim}+1;
            end
            
        end
        [F, rmean, epoch, labelRange, stimRange] = AverageGetFeature(F,subject,epoch,trial,channelRange,Fs,imagescale,timescale,siftscale,siftdescriptordensity,routput,rcounter,hit,nflash, labelRange,stimRange);
        globalaverages{subject}{trial}{1}.rmean = rmean;
        
    end
    toc

    %%
    epochRange=1:epoch;
    trainingRange = 1:nbofclasses*73;
    testRange=nbofclasses*0+1:min(nbofclasses*73,epoch);
    
    %trainingRange=1:nbofclasses*35;
    
    %trainingRange = 1:nbofclasses*30;
    %testRange=nbofclasses*30+1:nbofclasses*35;
    
    SBJ(subject).F = F;
    SBJ(subject).epochRange = epochRange;
    SBJ(subject).labelRange = labelRange;
    SBJ(subject).trainingRange = trainingRange;
    SBJ(subject).testRange = testRange;
    
    
    %%
    switch classifier
        case 1
            for channel=channelRange
                [DE(channel), ACC, ERR, AUC, SC(channel)] = NNetClassifier(F,labelRange,trainingRange,testRange,channel);
                globalaccij1(subject,channel)=ACC;
                globalsigmaaccij1 = globalaccij1;
                globalaccij2(subject,channel)=AUC;
            end
        case 2
            [AccuracyPerChannel, SigmaPerChannel] = CrossValidated(F,epochRange,labelRange,channelRange, @IterativeNBNNClassifier,1);
            globalaccij1(subject,:)=AccuracyPerChannel
            globalsigmaaccij1(subject,:)=SigmaPerChannel;
            globalaccijpernumberofsamples(globalnumberofsamples,subject,:) = globalaccij1(subject,:);
        case 3
            for channel=channelRange
                [DE, ACC, ERR, AUC, SC] = IterativeNBNNClassifier(F,channel,trainingRange,labelRange,testRange,false);

                globalaccij1(subject,channel)=1-ERR/size(testRange,2);
                globalaccij2(subject,channel)=AUC;
                globalsigmaaccij1 = globalaccij1;
            end

    end
    %SpellerDecoder
    Speller = SpellMe(F,2:2,1:73,labelRange,trainingRange,testRange,SC.predicted)

    SBJ(subject).DE = DE;
    SBJ(subject).SC = SC;
    
    
    %savetemplate(subject,globalaverages,channelRange);
    %save(sprintf('subject.%d.mat', subject));
end

error( globalexperiment );

%%
for subject=1:8
    
    for channel=channelRange
        acce = 0;
        for i=1:20
            ri = globalspeller{subject}{channel};
            if (ri(i,1)==ri(i,5) && ri(i,2)==ri(i,6))
                acce = acce+1;
            end
        end
        globalaccij3(subject,channel)=acce/20;
    end
end

totals = DisplayTotals(globalaccij3,globalaccij3,channels)
totals(:,6)

%%
channel=5;
figure('Name','Class 2 P300','NumberTitle','off')
setappdata(gcf, 'SubplotDefaultAxesLocation', [0, 0, 1, 1]);
fcounter=1;
for i=1:30
    ah=subplot_tight(6,5,fcounter,[0 0]);
    DisplayDescriptorImageFull(F,1,DE.C(2).IX(i,3),DE.C(2).IX(i,2),DE.C(2).IX(i,1),DE.C(2).IX(i,4),true);
    fcounter=fcounter+1;
end
figure('Name','Class 1','NumberTitle','off')
setappdata(gcf, 'SubplotDefaultAxesLocation', [0, 0, 1, 1]);
fcounter=1;
for i=1:30
    ah=subplot_tight(6,5,fcounter,[0 0]);
    DisplayDescriptorImageFull(F,1,DE.C(1).IX(i,3),DE.C(1).IX(i,2),DE.C(1).IX(i,1),DE.C(1).IX(i,4),true);
    fcounter=fcounter+1;
end

%%
for subject=3:3
    for trial=20:20
        for st=1:12
            labelname = { 'No Target','Target P300' };
            figure('Name',sprintf('%d(%d)%s',stimRange((trial-1)*12+st),st,labelname{SBJ(subject).labelRange((trial-1)*12+st)}) ,'NumberTitle','off');
            DisplayDescriptorImageFull(F,subject,(trial-1)*12+st,SBJ(subject).labelRange((trial-1)*12+st),8,1,false);
        end
    end
end
for i=1:12
    figure('Name',sprintf('%d',i));plot(globalaverages{3}{20}{1}.rmean{i}(:,8))
end
figure;
hold on;
for flash=1:120
    if (EEG(subject,trial,flash).label == 2)
        plot(EEG(subject,trial,flash).EEG(:,8));

    end
end
hold off


%%
totals = DisplayTotals(globalaccij1,globalsigmaaccij1,channels)
totals(:,6)

%%

ns = globalaccijpernumberofsamples(11,:,:);
ns = reshape(ns, [8 8]);
totals = DisplayTotals(ns,ns,channels)
totals(:,6)


ns = globalaccijpernumberofsamples(59,:,:);
ns = reshape(ns, [8 8]);
totals = DisplayTotals(ns,ns,channels)
totals(:,6)


ns = globalaccijpernumberofsamples(119,:,:);
ns = reshape(ns, [8 8]);
totals = DisplayTotals(ns,ns,channels)
totals(:,6)


%%
for subject=1:1
    for trial=1:1
        for st=1:12
            labelname = { 'No Target','Target P300' };
            figure('Name',sprintf('%d(%d)%s',stimRange((trial-1)*12+st),st,labelname{SBJ(subject).labelRange((trial-1)*12+st)}) ,'NumberTitle','off');
            DisplayDescriptorImageFull(SBJ(subject).F,subject,(trial-1)*12+st,SBJ(subject).labelRange((trial-1)*12+st),8,1,false);        
        end
    end
end
