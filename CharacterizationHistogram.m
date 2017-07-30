clearvars -except EEG

for i=1:2 amplitudehistogram{i}=[]; end
for i=1:2 locationhistogram{i}=[]; end

channel=20;

for subject=1:1
    for trial=1:73
        for flash=1:180
            [amplitudes,locations] = findpeaks(EEG(subject,trial,flash).EEG(:,channel));
            [maxamplitude,maxamplocation] = max(amplitudes);
            amplitude=maxamplitude;
            location=locations(maxamplocation);
            label=EEG(subject,trial,flash).label;
            %label=randi(2);
            amplitudehistogram{label} = [amplitudehistogram{EEG(subject,trial,flash).label}; amplitude];
            locationhistogram{label} = [locationhistogram{EEG(subject,trial,flash).label}; location];
        end
    end
end
%%
figure('Name','Amplitude NoHit','NumberTitle','off');
[nb,xb]=hist(amplitudehistogram{1},min(amplitudehistogram{1}):0.5:max(amplitudehistogram{1}));
bh=bar(xb,nb);
set(bh,'facecolor',[1 1 0]);
figure('Name','Amplitude P300','NumberTitle','off');
[nb,xb]=hist(amplitudehistogram{2},min(amplitudehistogram{2}):0.5:max(amplitudehistogram{2}));
bh=bar(xb,nb);
set(bh,'facecolor',[1 0 1]);

figure('Name','Location NoHit','NumberTitle','off');
[nb,xb]=hist(locationhistogram{1},0:5:240);
bh=bar(xb,nb);
set(bh,'facecolor',[1 1 0]);
figure('Name','Location P300','NumberTitle','off');
[nb,xb]=hist(locationhistogram{2},0:5:240);
bh=bar(xb,nb);
set(bh,'facecolor',[1 0 1]);