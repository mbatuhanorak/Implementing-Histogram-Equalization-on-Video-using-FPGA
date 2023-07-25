% Replace 'reduced_video.txt' with the name of your text file
inputTextFile = 'reduced_video1.txt';

% Read the text file
data = dlmread(inputTextFile);

% Determine the video dimensions (240x160) - change if needed
videoHeight = 160;
videoWidth = 240;

% Calculate the number of frames in the text file
numFrames = size(data, 1) / (videoHeight * videoWidth);

% Create a VideoWriter object to save the reconstructed video
outputVideoFile = 'sa_video.avi';  % Change the output format if needed, e.g., 'reconstructed_video.mp4'
outputVideoObj = VideoWriter(outputVideoFile, 'Motion JPEG AVI'); % Change the compression method if needed, e.g., 'MPEG-4'
open(outputVideoObj);

% Convert each frame and write to the video
for frameIdx = 1:numFrames
    frameData = data((frameIdx - 1) * videoHeight * videoWidth + 1 : frameIdx * videoHeight * videoWidth);
    frame = reshape(frameData, videoHeight, videoWidth);
    frame = uint8(frame); % Convert back to uint8 for video writing
    
    % Expand grayscale to RGB format (required by VideoWriter)
    frameRGB = cat(3, frame, frame, frame);
    writeVideo(outputVideoObj, frameRGB);
end

% Close the output video file
close(outputVideoObj);

disp('Video reconstruction completed and saved as "reconstructed_video.avi"');
