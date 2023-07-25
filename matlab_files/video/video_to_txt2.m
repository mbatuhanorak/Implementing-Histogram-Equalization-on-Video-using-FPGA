% Replace 'input_video.mp4' with the name of your video file
inputVideoFile = 'my_video.mp4';

% Read the video file
videoObj = VideoReader(inputVideoFile);

% Create a VideoWriter object to save the reduced video
outputVideoFile = 'reduced_video.avi';
outputVideoObj = VideoWriter(outputVideoFile, 'Motion JPEG AVI'); % Change the compression method if needed, e.g., 'MPEG-4'
open(outputVideoObj);

% Reduce the resolution to 240x160 and convert to grayscale
while hasFrame(videoObj)
    frame = readFrame(videoObj);
    resizedFrame = imresize(frame, [160, 240]);
    grayscaleFrame = rgb2gray(resizedFrame);
    writeVideo(outputVideoObj, grayscaleFrame);
end

% Close the output video file
close(outputVideoObj);

disp('Video processing completed and saved as "reduced_video.avi"');
