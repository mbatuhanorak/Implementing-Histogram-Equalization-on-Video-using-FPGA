clear;
newFolderPath = fullfile(pwd, 'output_txt');
inputImage = imread('output_txt/pout.jpg');

% Resmi gri seviyeye dönüştürün
grayIm = rgb2gray(inputImage);
grayImage=imresize(grayIm,[240 160]);
% Giriş görüntü boyutunu alın
[height, width] = size(grayImage);

% Görüntü histogramını hesaplamak için bir histogram vektörü oluşturun
histogram = zeros(256, 1);
for i = 1:height
    for j = 1:width
        pixelValue = grayImage(i, j);
        histogram(pixelValue+1) = histogram(pixelValue+1) + 1;
    end
end
a=histogram
% Histogramı normalleştirin (piksel sayısına bölün)
%histogram = histogram / (height * width);

% Kumulatif histogramu hesaplamak için bir kumulatif histogram vektörü oluşturun
cumulativeHist = zeros(256, 1);
cumulativeSum = 0;
for i = 1:256
    cumulativeSum = cumulativeSum + histogram(i);
    cumulativeHist(i) = cumulativeSum;
end

% Histogram eşitleme işlemini uygulayın ve çıktı görüntüsü oluşturun
outputImage = zeros(height, width);
for i = 1:height
    for j = 1:width
        pixelValue = grayImage(i, j);
        outputImage(i, j) = (256 * cumulativeHist(pixelValue + 1))/(240*160);
    end
end
a_point=outputImage;
a_point_ceil=ceil(a_point);
a_point_round=round(a_point);
a_point_floor=floor(a_point);

d=reshape(a_point_floor.',1,[]);
fid = fopen('output_txt/hst_eq.txt', 'wt');
fprintf(fid, '%d\n', d);
% outputImage = outputImage + 0.5;
% outputImage = outputImage - mod(outputImage, 1);
% 
% Çıktı değerlerini 0-255 aralığına sıkıştırın
% outputImage(outputImage < 0) = 0;
% outputImage(outputImage > 255) = 255;

outputImage = uint8(outputImage);

% Sonuçları görselleştirin
subplot(2, 2, 1); imshow(grayImage); title('Gri Görüntü');
subplot(2, 2, 2); imhist(grayImage); title('Gri Görüntü Histogramı');
subplot(2, 2, 3); imshow(outputImage); title('Eşitlenmiş Görüntü');
subplot(2, 2, 4); imhist(outputImage); title('Eşitlenmiş Görüntü Histogramı');
