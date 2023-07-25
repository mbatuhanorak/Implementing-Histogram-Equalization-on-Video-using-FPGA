newFolderPath = fullfile(pwd, 'output_txt');
inputImage = imread('output_txt/lenna1.jpg');
currentDir = pwd;
grayImage = rgb2gray(inputImage);
[height, width] = size(grayImage);
histogram = zeros(256, 1);
for i = 1:height
       for j = 1:width
           pixelValue = grayImage(i, j);
           histogram(pixelValue + 1) = histogram(pixelValue + 1) + 1;
       end
end
histogram = histogram / (height * width);
cumulativeHist = cumsum(histogram);
eqImage = zeros(height, width);
for i = 1:height
    for j = 1:width
        pixelValue = grayImage(i, j);
        eqImage(i, j) = round(255 * cumulativeHist(pixelValue + 1));
    end
end
eqImage = uint8(eqImage);
d = reshape(eqImage.', 1, []);
disp('Reshapping done');
fid = fopen('output_txt/custom_hist_eq_im1.txt', 'wt');
fprintf(fid, '%d\n', d);
disp('Text file write done');
fclose(fid);
figure
% Sonuçları görselleştirin
subplot(2, 2, 1); imshow(grayImage); title('Gri Görüntü');
subplot(2, 2, 2); imhist(grayImage); title('Gri Görüntü Histogramı');
subplot(2, 2, 3); imshow(eqImage); title('Eşitlenmiş Görüntü');
subplot(2, 2, 4); imhist(eqImage); title('Eşitlenmiş Görüntü Histogramı');

