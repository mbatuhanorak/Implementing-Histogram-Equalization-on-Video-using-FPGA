
dosya = fopen('output_txt/hist1.txt', 'r');
formatSpec = '%d %d';
A = fscanf(dosya, formatSpec, [2 Inf]);
fclose(dosya);
B = zeros(max(A(1,:)), max(A(2,:)));
for i = 1:size(A, 2)
    if B(A(1,i), A(2,i)) == 0
        B(A(1,i), A(2,i)) = 1;
    else
        B(A(1,i), A(2,i)) = B(A(1,i), A(2,i)) + 1;
    end
end