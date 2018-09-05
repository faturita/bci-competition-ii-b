plot(EEG(1,5,100).EEG)

output = EEG(1,5,100).EEG;


output = fastica(output);

figure;
plot(output)