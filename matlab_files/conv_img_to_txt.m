close all;
A=imread('output_txt/lenna1.jpg');
B=rgb2gray(A);
disp('Image file read successful');
%figure,imshow(B),title('org');
%[m, n] = size(B);
C=imresize(B,[240 160]);
figure,imshow(C),title('croped');
d=reshape(C.',1,[]);
% Matris boyutlarını alın
[m, n] = size(d);

% Frekans matrisini oluşturma
frekans_matrisi = zeros(max(d(:)), 1);

% Matrisi tarayarak frekansları hesaplama
% for i = 1:m
%     for j = 1:n
%         deger = d(i, j);
%         frekans_matrisi(deger) = frekans_matrisi(deger) + 1;
%     end
% end
fid = fopen('output_txt/img2.txt', 'wt');
fprintf(fid, '%d\n', d);
disp('Text file write done');disp('');
fclose(fid);