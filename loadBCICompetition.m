

% CAT DOG FISH WATER BOWL HAT gAT GLOVE SHOES FISH RAT

% Words
% 10 1 3 CAT
% 10 2 3 DOG
% 10 3 4 FISH
% 10 4 5 WATER
% 10 5 4 BOWL
% 11 1 3 HAT
% 11 2 3 HAT
% 11 3 5 GLOVE
% 11 4 5 SHOES
% 11 5 4 FISH
% 11 6 3 RAT

% 10 + 11 = 42 

% FOOD MOOT HAM PIE CAKE TUNA ZYGOT 4567
% 12 1 4
% 12 2 4
% 12 3 3
% 12 4 3
% 12 5 4
% 12 6 4
% 12 7 5
% 12 8 4

% 12 = 31

% EEG(subject,trial,flash)
function [EEG, stimRange, labelRange] = loadBCICompetition(Fs, windowsize, downsize, flashespertrial, subjectRange,channelRange)
verbose=true;

%EEG = zeros(size(subjectRange,2),size(datatrial,2),flashespertrial);
artifactcount = 0;            
    
stimRange = [];
labelRange = [];
trial=0;
flash=1;

st=zeros(1,12);

CF = SpelledWordToMatrix();

CFG = [[10 5];[11 6];[12 8]];
checktrials=0;
noflashing=true;
for subject=subjectRange
    for i=1:3
        for run=1:CFG(i,2)
            nameoffile=sprintf('AAS%03dR%02d.mat',CFG(i,1),run);
            if (verbose) fprintf('Reading file %s\n',nameoffile);end
            clear StimulusType
            clear Flashing
            clear signal
            clear StimulusCode
            load(sprintf('%s/BCI.Competition.II.Dataset.2b/data/%s',getdatasetpath(),nameoffile));
            ff=diff(Flashing);
            fprintf('Trials found: %d\n', size(find(ff==1),1)/(15*12));
            checktrials=checktrials+size(find(ff==1),1)/(15*12);
            
            dataX = notchsignal(signal, channelRange);
            dataX = bandpasseeg(dataX, channelRange,Fs);
            dataX = decimatesignal(dataX,channelRange,downsize); 

            signal=dataX;            
            
            flash=1;
            for sample=1:min(size(Flashing,1),size(StimulusTime,1))

                if (Flashing(sample)==1) 
                    if (noflashing)
                        if (flash<=180)
                            if (trial==40 && sample==5329)
                                % This sample is 5329 which is 12 samples
                                % length.  It's wrong and has been at
                                % sample 5341 where everything is reset and
                                % restarts ok from there.
                                noflashing=false;
                                continue;
                            end
                            if (mod(flash-1,12)==0)
                                [trial flash 312]
                                st
                            end
                            stimRange(end+1) = StimulusCode(sample);
                            EEG(subject,trial,flash).isartifact = false;
                            %EEG(subject,trial,flash).EEG = signal(sample:sample+240-1,channelRange);
                            EEG(subject,trial,flash).EEG = signal(ceil(sample/downsize):ceil(sample/downsize)+240/downsize-1,channelRange);
                            EEG(subject,trial,flash).stim = StimulusCode(sample);
                            if ((exist('StimulusType')))
                                EEG(subject,trial,flash).label = StimulusType(sample)+1;             
                                labelRange(end+1) = StimulusType(sample)+1;
                            else
                                if ( (StimulusCode(sample)==CF(1,trial-42)) || (StimulusCode(sample)==CF(2,trial-42) ) )
                                    EEG(subject,trial,flash).label = 2;
                                    labelRange(end+1) = 2;
                                else
                                    EEG(subject,trial,flash).label = 1;
                                    labelRange(end+1) = 1;
                                end
                            end
                            noflashing =false;
                            flash=flash+1;
                        else
                            disp('skip');
                        end
                    end
                else
                    noflashing = true;
                end
         

                if (PhaseInSequence(sample)==1)
                    if ( (PhaseInSequence(sample-1)==3) || (PhaseInSequence(sample-1)==0))
                        [trial flash]
                        trial=trial+1;
                        flash=1;
                    end
                end
            end
        end
    end
end

%%
    
    
    
%   for i=1:2  
%     
% 
%     dataX = notchsignal(data.X, channelRange);
%     datatrial = data.trial;
% 
%     %data.X = decimateaveraging(data.X,channelRange,downsize);
%     dataX = bandpasseeg(dataX, channelRange,Fs);
%     dataX = decimatesignal(dataX,channelRange,downsize); 
%     %dataX = downsample(dataX,downsize);
% 
%     %l=randperm(size(data.y,1));
%     %data.y = data.y(l);
%        
%     for trial=1:size(datatrial,2)
%         for flash=1:flashespertrial
%             
%             % Mark this 12 repetition segment as artifact or not.
%             if (mod((flash-1),12)==0)
%                 iteration = extract(dataX, (ceil(data.trial(trial)/downsize)+64/downsize*(flash-1)),64/downsize*12);
%                 artifact=isartifact(iteration, 70);        
%             end         
%             
%             %EEG(subject,trial,flash).EEG = zeros((Fs/downsize)*windowsize,size(channelRange,2));
% 
%             output = baselineremover(dataX,(ceil(datatrial(trial)/downsize)+ceil(64/downsize)*(flash-1)),(Fs/downsize)*windowsize,channelRange,downsize);
% 
%             EEG(subject,trial,flash).label = data.y(data.trial(trial)+64*(flash-1));
%             EEG(subject,trial,flash).stim = data.y_stim(data.trial(trial)+64*(flash-1));
%             
%             % Enrich signal with a previous stored p300 signature.
%             if (EEG(subject,trial,flash).label==20)
%                p300 = dlmread(sprintf('realp300s.%d.t.%d.mat',subject,trial)); 
% 
%                output = output + p300*4;
%                
%                output = zeros((Fs/downsize)*windowsize,size(channelRange,2));
%                output = fakeeegoutput(4, EEG(subject,trial,flash).label, 1:8,16);
%             end
%              
%             
%             EEG(subject,trial,flash).isartifact = false;
%             if (artifact)
%                 artifactcount = artifactcount + 1;
%                 EEG(subject,trial,flash).isartifact = true;
%             end
%             
%             % This is a very important step, do not forget it.
%             % Rest the media from the epoch.
%             [n,m]=size(output);
%             output=output - ones(n,1)*mean(output,1); 
%             
%             %output = zscore(output)*2;
% 
%             EEG(subject,trial,flash).EEG = output;
% 
%         end
%     end
% end

end