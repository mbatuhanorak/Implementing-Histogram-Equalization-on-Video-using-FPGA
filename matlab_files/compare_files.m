% Read the contents of the first text file
file1 = 'output_txt/img.txt';
contents1 = fileread(file1);

% Read the contents of the second text file
file2 = 'output_txt/w_im1.txt';
contents2 = fileread(file2);
data = dlmread(file2);
cdata =reshape(data,[],24)';
cdata=uint8(cdata)
figure,imshow(cdata),title('txt');
disp(cdata == C);

% Compare the contents
if strcmp(contents1, contents2)
    disp('The text files are identical.');
else
    disp('The text files are different.');
end