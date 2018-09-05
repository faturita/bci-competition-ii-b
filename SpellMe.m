function Speller = SpellMe(F,channelRange,trialRange,labelRange, trainingRange,testRange,SC)
% Esta funcion me retorna las letras seleccionadas en testRange

show=false;

SPELLERMATRIX = { { 'A','B','C','D','E','F'},
                { 'G','H','I','J','K','L'},
                { 'M','N','O','P','Q','R'},
                { 'S','T','U','V','W','X'},
                { 'Y','Z','1','2','3','4'},
                { '5','6','7','8','9','_'}};


%%
Speller = cell(size(channelRange,2),40);

% Vamos a ver primero los 30 descriptores que est?n en la bolsa de P300
if (show)
    figure;
    setappdata(gcf, 'SubplotDefaultAxesLocation', [0, 0, 1, 1]);
    fcounter=1;
    for i=1:30
        ah=subplot_tight(6,5,fcounter,[0 0]);
        DisplayDescriptorImageFull(F,DE.C(2).IX(i,3),DE.C(2).IX(i,2),DE.C(2).IX(i,1),DE.C(2).IX(i,4),true);
        fcounter=fcounter+1;
    end


    trial=16+1;
    figure;DisplayDescriptorImageFull(F,180+12+1,labelRange(180+12+1),4,1,false);

    figure;DisplayDescriptorImageFull(F,180+12+2,labelRange(180+12+2),4,1,false);
    figure;DisplayDescriptorImageFull(F,180+12+3,labelRange(180+12+3),4,1,false);
    figure;DisplayDescriptorImageFull(F,180+12+4,labelRange(180+12+4),4,1,false);
    figure;DisplayDescriptorImageFull(F,180+12+5,labelRange(180+12+5),4,1,false);
    figure;DisplayDescriptorImageFull(F,180+12+6,labelRange(180+12+6),4,1,false);

    figure;DisplayDescriptorImageFull(F,180+12+7,labelRange(180+12+7),4,1,false);

    figure;DisplayDescriptorImageFull(F,180+12+8,labelRange(180+12+8),4,1,false);
    figure;DisplayDescriptorImageFull(F,180+12+9,labelRange(180+12+9),4,1,false);
    figure;DisplayDescriptorImageFull(F,180+12+10,labelRange(180+12+10),4,1,false);
    figure;DisplayDescriptorImageFull(F,180+12+11,labelRange(180+12+11),4,1,false);
    figure;DisplayDescriptorImageFull(F,180+12+12,labelRange(180+12+12),4,1,false);
end

for channel=channelRange
    predicted=SC(channel).predicted;
    AF = [];
    mind = 1;
    maxd = 6;
    for trial=trialRange
        Mx = zeros(1,2);
        
        % Show predicted value for this repetition.
        predicted(mind:mind+12-1);
        for i=1:12
            if (1<=i && i<=6 && predicted(mind+i-1)==2)
                Mx(1) = i;
            elseif (7 <=i && i<=12 && predicted(mind+i-1)==2)
                Mx(2) = i;
            end
        end       
        
        % @FIXME Try not to produce an error but it should fail here.
        if (Mx(1) == 0) Mx(1) = randi(6);end
        if (Mx(2) == 0) Mx(2) = randi(6)+6;end
        
        Speller{channel}{end+1} = SPELLERMATRIX{Mx(2)-6}{Mx(1)};
        
        mind=mind+12;
        maxd=maxd+12;        
    end
end


% for channel=channelRange
%     AF = [];
%     mind = 1;
%     maxd = 6;
%     for trial=trialRange
%         % Primero se conforma TM que es la matriz con los descriptores
%         % de las imagenes que surgieron para test set.
%         fprintf('Channel %d\n', channel);
%         fprintf('Building Test Matrix M for Channel %d:', channel);
%         [TM, TIX] = BuildDescriptorMatrix(F,channel,labelRange,testRange);
%         fprintf('%d\n', size(TM,2)); 
% 
%         % DE es la base de datos que va a surgir con las dos "bolsas" de
%         % descriptores para las dos clases (hit 2 vs. nohit 1).
%         DE = NBNNFeatureExtractor(F,channel,trainingRange,labelRange,[1 2],false); 
%         fprintf('Bag Sizes %d vs %d \n', size(DE.C(1).IX,1),size(DE.C(2).IX,1));
% 
%         % Extraigo los primeros 6 descriptores de mind:maxd y busco los
%         % vecinos mas cercanos de TM (que son 6) para cada uno de los
%         % descriptores de hit que tengo en la bolsa (2)
%         [IDX,D] = knnsearch((TM(:,mind:maxd)'),DE.C(2).M');
% 
%         % Los reagrupo armando los bines correspondientes y fijandome los
%         % histogramas (el descriptor 3 de la bolsa tiene un vecino mas
%         % cercano que es el 5) (como que vota por el 5).
%         m = histcounts(IDX,0.5:1:6.5);
% 
%         % m tengo los conteos para cada uno de los bines.  Me quedo con el
%         % maximo y de ese saco cual es el indice, lo que es el row.
%         [r, row2] = max(m);
% 
%         % Idem para la columna
%         [IDX,D] = knnsearch((TM(:,mind+6:maxd+6)'),DE.C(2).M');
% 
%         m = histcounts(IDX,0.5:1:6.5);
% 
% 
%         [r, col2] = max(m);
%         col2 = col2+6;
% 
%         % Segundo metodo.  Se calcula la matriz de distancia entre los
%         % descriptores de la bolsa de hit y los 12 de este trial.
%         Z = dist((TM(:,mind:maxd+6)'),DE.C(2).M);
% 
%         Z=Z';
% 
%         % Para el row, sumo en la primera direccion (along 30) para cada
%         % uno.   Tanto para los 6 primeros (fila) como los otros 6
%         % (columnas).
%         sumsrow = sum(Z(1:size(Z,1),1:6),1);
%         sumscol = sum(Z(1:size(Z,1),7:12),1);
% 
%         % Me quedo con aquel que la suma contra todos, dio menor.
%         [c, row] = min(sumsrow);
%         [c, col] = min(sumscol);
%         col=col+6;
%         AF = [AF; [row,col,row2,col2]];
% 
%         Speller{end+1} = SPELLERMATRIX{row}{col-6};
% 
%         mind=mind+12;
%         maxd=maxd+12;
% 
%     end
%     %globalspeller{subject}{channel}=[CF(16:35,:) AF];
% end




end