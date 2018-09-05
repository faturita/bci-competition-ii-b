function DE = NBNNFeatureExtractor(F,channel,trainingRange,labelRange,labels, balancebags)
% Labels should be 1,2,3,... and so on but try to start from one.

DE.CLSTER = [];

for i=1:size(labels,2)
    exclude{i}=[];
end

for label=labels
    [M, IX] = BuildDescriptorMatrix(F,channel,labelRange,trainingRange(find(labelRange(trainingRange)==label)));
    
    a(label) = size(M,2);
end

[val, lb] = max(a);

for label=labels
    fprintf('Building Descriptor Matrix M for Channel %d:', channel);
    [M, IX] = BuildDescriptorMatrix(F,channel,labelRange,trainingRange(find(labelRange(trainingRange)==label)));
    fprintf('%d\n', size(M,2)); 
    
    exclude{label} = sort(exclude{label},'descend');
    
    for i=1:size(exclude{label})
        M(:,exclude{label}(i)) = [];
        IX(exclude{label}(i),:) = [];        
    end
    
    % Unbalance training dataset.
    if (balancebags && label==lb)
        pperm = randperm(size(M,2),min(a));
        M=M(:,pperm);
        IX=IX(pperm,:);
    end
    
    assert ( balancebags == false || (balancebags == true && size(M,2) == min(a) ));
    
    
    % Creating a KDTree.
    kdtree = vl_kdtreebuild(M) ;
    
    DE.C(label).M = M;
    DE.C(label).Label = label;
    DE.C(label).IX = IX;
    DE.C(label).KDTree = kdtree;

    DE.CLSTER = [DE.CLSTER DE.C(label).Label];
end

end