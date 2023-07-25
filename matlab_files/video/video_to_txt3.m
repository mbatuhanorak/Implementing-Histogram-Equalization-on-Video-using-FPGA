% Replace 'input_video.mp4' with the name of your video file
inputVideoFile = 'my_video1.mp4';

% Read the video file
videoObj = VideoReader(inputVideoFile);

% Create a text file to save the reduced video
outputTextFile = 'reduced_video1.txt';
fid = fopen(outputTextFile, 'w');

% Reduce the resolution to 240x160 and convert to grayscale
while hasFrame(videoObj)
    frame = readFrame(videoObj);
    resizedFrame = imresize(frame, [160, 240]);
    grayscaleFrame = rgb2gray(resizedFrame);
    
    % Convert the frame to a 2D array and write it to the text file
    frameData = reshape(grayscaleFrame, [], 1);
    fprintf(fid, '%d\n', frameData);
end

% Close the text file
fclose(fid);

disp('Video processing completed and saved as "reduced_video.txt"');
