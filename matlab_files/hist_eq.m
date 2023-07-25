% Giriş görüntüsünü yükleyin
inputImage = imread('output_txt/lenna1.jpg');

% Görüntüyü gri seviyeye dönüştürün
grayImage = rgb2gray(inputImage);

% Histogram eşitlemeyi uygulayın
eqImage = histeq(grayImage);
d=reshape(eqImage.',1,[]);
disp('Reshapping done');
fid = fopen('output_txt/hist_eq_im.txt', 'wt');
fprintf(fid, '%d\n', d);
disp('Text file write done');disp('');
fclose(fid);
% Sonuçları görselleştirin
subplot(2,2,1); imshow(grayImage); title('Gri Görüntü');
subplot(2,2,2); imhist(grayImage); title('Gri Görüntü Histogramı');
subplot(2,2,3); imshow(eqImage); title('Eşitlenmiş Görüntü');
subplot(2,2,4); imhist(eqImage); title('Eşitlenmiş Görüntü Histogramı');
