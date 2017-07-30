clc
load(sprintf('%s/BCI.Competition.II.Dataset.2b/data/%s',getdatasetpath(),'AAS011R06.mat'));

ff=diff(Flashing);
fprintf('Trials found: %d\n', size(find(ff==1),1)/(15*12));


flash=1;
noflashing=true;
trial=0;
stim=[];
startsample=0;
for sample=1:min(size(Flashing,1),size(StimulusTime,1))

    if (Flashing(sample)==1) 
        if (noflashing)
            if (trial==1 && sample==5329)
                noflashing=false;
                continue;
            end
            %[trial sample flash StimulusCode(sample)]
            
            stim(end+1) = StimulusCode(sample);
            noflashing =false;
            flash=flash+1;

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
st=zeros(1,12);
for trial=1:1
    for rep=1:15
        for i=1:12
            st(stim((trial-1)*(15*12)+(rep-1)*(12)+i)) = st(stim((trial-1)*(15*12)+(rep-1)*(12)+i))+1;
        end
        rep
        st
        assert( size(unique(st),2)==1, 'PtP Averages were calculated from different sizes.');
        st=zeros(1,12);
    end
end
stim(181)

            