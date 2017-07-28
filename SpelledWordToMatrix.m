%FOOD MOOT HAM PIE CAKE TUNA ZYGOT 4567
function CF = SpelledWordToMatrix()

S = 'FOODMOOTHAMPIECAKETUNAZYGOT4567';

CF = [];

SP = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789_';

SPELLERMATRIX = { { 'A','B','C','D','E','F'},
                { 'G','H','I','J','K','L'},
                { 'M','N','O','P','Q','R'},
                { 'S','T','U','V','W','X'},
                { 'Y','Z','1','2','3','4'},
                { '5','6','7','8','9','_'}};
            
for trial=1:size(S,2)
    letter = S(trial);
    id = find(SP==letter)-1;
    row = floor((id)/6)+1;
    col = mod(id,6)+1;
    CF = [CF [row+6 ; col]]
end
end
    