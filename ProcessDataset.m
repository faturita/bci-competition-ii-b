% Signal Averaging x Selection classification of P300 BCI Competition II
rng(396544);

clear all
close all

globalexperiment='';

globalnumberofepochspertrial=15;
globalaverages= cell(2,1);
globalartifacts = 0;
globalreps=15;
globalnumberofepochs=(2+10)*globalreps-1;

%for globalnumberofsamples=(2+10)*[10 5 1]-1

clear mex;clearvars  -except global*;close all;clc;

nbofclassespertrial=(2+10)*(15/globalreps);
breakonepochlimit=false;

% Clean all the directories where the images are located.
cleanimagedirectory();


% NN.NNNNN

%     'Fz'    'Cz'    'Pz'    'Oz'    'P3'    'P4'    'PO7'    'PO8'

channels={ 'Fz'  ,  'Cz',    'Pz' ,   'Oz'  ,  'P3'  ,  'P4'   , 'PO7'   , 'PO8'};


% Parameters ==========================
epochRange = 1:120*7*5;
channelRange=1:64;
labelRange = zeros(1,4200);
stimRange = zeros(1,4200);


imagescale=4;
timescale=8;
siftscale = [ 3 3];
qKS=32-4:35;
qKS=8;
minimagesize=floor(sqrt(2)*15*siftscale(2)+1);


imagescale=4;
timescale=4;
siftscale = [ 3 3];
qKS=30;
minimagesize=floor(sqrt(2)*15*siftscale(2)+1);


siftdescriptordensity=1;
Fs=240;
windowsize=1;
expcode=2400;
show=0;

%[St Sv timescale imagescale] = CalculateDescriptor(Fs, windowsize, 0.8, 128,256)
%siftscale = [St Sv];

%qKS = floor(128/2);
%minimagesize=floor(sqrt(2)*15*siftscale(2)+1);


% =====================================
classifier=6;

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
            if (processedflashes>globalnumberofepochs)
                if (breakonepochlimit)
                    break;
                end
                [F, rmean, epoch, labelRange, stimRange] = AverageGetFeature(F,subject,epoch,trial,channelRange,Fs,imagescale,timescale,siftscale,minimagesize,siftdescriptordensity,qKS,routput,rcounter,hit,nflash, labelRange,stimRange);
                %[F, rmean, epoch, labelRange, stimRange] = AverageStandardFeature(F,subject,epoch,trial,channelRange,Fs,imagescale,timescale,siftscale,siftdescriptordensity,qKS,routput,rcounter,hit,nflash, labelRange,stimRange);
  
                globalaverages{subject}{trial}{flash}.rmean = rmean;
                processedflashes=0;
                for i=1:12 routput{i}=[]; end
                for i=1:12 rcounter{i}=0; end
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
            
            if (rcounter{stim}<globalnumberofepochspertrial)
                routput{stim} = [routput{stim}; output];
                rcounter{stim}=rcounter{stim}+1;
            end
            
        end
        [F, rmean, epoch, labelRange, stimRange] = AverageGetFeature(F,subject,epoch,trial,channelRange,Fs,imagescale,timescale,siftscale,minimagesize,siftdescriptordensity,qKS,routput,rcounter,hit,nflash, labelRange,stimRange);       
        %[F, rmean, epoch, labelRange, stimRange] = AverageStandardFeature(F,subject,epoch,trial,channelRange,Fs,imagescale,timescale,siftscale,siftdescriptordensity,qKS,routput,rcounter,hit,nflash, labelRange,stimRange);
        globalaverages{subject}{trial}{flash}.rmean = rmean;
        
    end
    toc

    %%
    epochRange=1:epoch;
    trainingRange = 1:nbofclassespertrial*42;
    testRange=nbofclassespertrial*42+1:min(nbofclassespertrial*73,epoch);
    
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
        case 5
            for channel=channelRange
                [DE(channel), ACC, ERR, AUC, SC(channel)] = LDAClassifier(F,labelRange,trainingRange,testRange,channel);
                globalaccij1(subject,channel)=ACC;
                globalsigmaaccij1 = globalaccij1;
                globalaccij2(subject,channel)=AUC;
            end  
        case 4
            for channel=channelRange
                [DE(channel), ACC, ERR, AUC, SC(channel)] = SVMClassifier(F,labelRange,trainingRange,testRange,channel);
                globalaccij1(subject,channel)=ACC;
                globalsigmaaccij1 = globalaccij1;
                globalaccij2(subject,channel)=AUC;
            end            
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
            globalaccijpernumberofsamples(globalnumberofepochs,subject,:) = globalaccij1(subject,:);
        case 3
            for channel=channelRange
                [DE(channel), ACC, ERR, AUC, SC(channel)] = IterativeNBNNClassifier(F,channel,trainingRange,labelRange,testRange,false,false);

                globalaccij1(subject,channel)=1-ERR/size(testRange,2);
                globalaccij2(subject,channel)=AUC;
                globalsigmaaccij1 = globalaccij1;
            end
        case 6
            for channel=channelRange
                DE(channel) = NBNNFeatureExtractor(F,channel,trainingRange,labelRange,[1 2],false); 

                [ACC, ERR, AUC, SC(channel)] = NBMultiClass(F,DE(channel),channel,testRange,labelRange,false);
                                                                        
                globalaccij1(subject,channel)=1-ERR/size(testRange,2);
                globalaccij2(subject,channel)=AUC;
                globalsigmaaccij1 = globalaccij1;
            end

    end

    Speller = SpellMe(F,channelRange,43:73,labelRange,trainingRange,testRange,SC);

    S = 'FOODMOOTHAMPIECAKETUNAZYGOT4567';
    
    SpAcc = [];
    for channel=channelRange
        counter=0;
        for i=1:size(S,2)
            if Speller{channel}{i}==S(i)
                counter=counter+1;
            end
        end
        SpAcc(end+1) = counter/size(S,2);
    end
    
    
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
