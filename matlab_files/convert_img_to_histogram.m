% Veri dosyasını yükle
%bu dosyanın histogramını oluşturan matlab kodu 
data = dlmread('output_txt/img1.txt');
output_file = fopen('output_txt/sonuc.txt', 'w');
% Her sayı için tekrar sayısını hesapla ve ekrana yazdır
for i = 1:length(data)
    current_number = data(i);
    count = sum(data(1:i) == current_number);
    fprintf(output_file,'%d%d\n', current_number, count);
end

fclose(output_file);