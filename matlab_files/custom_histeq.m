function outputImage = custom_histeq(inputImage)
    % Giriş görüntü boyutunu alın
    [height, width] = size(inputImage);
    
    % Görüntü histogramını hesaplayın
    histogram = zeros(256, 1);
    for i = 1:height
        for j = 1:width
            pixelValue = inputImage(i, j);
            histogram(pixelValue + 1) = histogram(pixelValue + 1) + 1;
        end
    end
    
    % Histogramı normalleştirin
    histogram = histogram / (height * width);
    
    % Kumulatif histogramu hesaplayın
    cumulativeHist = cumsum(histogram);
    
    % Histogram eşitleme işlemini uygulayın
    outputImage = zeros(height, width);
    for i = 1:height
        for j = 1:width
            pixelValue = inputImage(i, j);
            outputImage(i, j) = round(255 * cumulativeHist(pixelValue + 1));
        end
    end
    outputImage = uint8(outputImage); % Görüntüyü 8-bit unsigned integer'a dönüştürün
end
