dosyaAdi = 'output_txt/hist1.txt';
dosya = fopen(dosyaAdi, 'r');
veriler = fscanf(dosya, '%d');

% Metin dosyasını kapat
fclose(dosya);

% Değerlerin sayısını bul
sayilar = unique(veriler);
sayiSayisi = numel(sayilar);

% Matrisi oluştur
matris = zeros(sayiSayisi, sayiSayisi);
for i = 1:length(veriler)-1
    satir = find(sayilar == veriler(i));
    sutun = find(sayilar == veriler(i+1));
    matris(satir, sutun) = matris(satir, sutun) + 1;
end

% Sonucu ekrana yazdır
disp(matris);