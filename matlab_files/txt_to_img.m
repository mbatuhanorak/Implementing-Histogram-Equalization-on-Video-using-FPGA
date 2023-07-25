% Read the contents of the first text file
clear;
newFolderPath = fullfile(pwd, 'output_txt');
% Read the contents of the second text file
inputImage = imread('output_txt/pout.jpg');
grayImage = rgb2gray(inputImage);
grayImage=imresize(grayImage,[240 160]);
eqImage = histeq(grayImage);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file1 = 'output_txt/his1.txt';
contents1 = fileread(file1);
data1 = dlmread(file1);
cdata1 =reshape(data1,[],240)';
cdata1 =uint8(cdata1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file2 = 'output_txt/his2.txt';
contents2 = fileread(file2);
data2 = dlmread(file2);
cdata2 =reshape(data2,[],240)';
cdata2=uint8(cdata2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file3 = 'output_txt/his3.txt';
contents3 = fileread(file3);
data3 = dlmread(file3);
cdata3 =reshape(data3,[],240)';
cdata3=uint8(cdata3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;

% First subplot
subplot(2, 3, 1);
imshow(cdata1),title('txt1');
subplot(2, 3, 2);
imshow(cdata2),title('txt2');
subplot(2, 3, 3);
imshow(cdata3),title('tx3');
subplot(2, 3, 4);
imshow(eqImage),title('matlab');
subplot(2, 3, 5);
imshow(grayImage),title('gray');
