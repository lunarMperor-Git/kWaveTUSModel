function mask_rs = resizeMask(mask, scale, sigma, n)

% Helper function to resize masks
%
% INPUTS: 
%   mask       - tissue mask to resize
%   scale      - scale to resize the tissue
%   sigma      - standard deviation for the gaussian smoothing, larger =
%                stronger smoothing
%   n          - value for Signed Distance Field to be mask, larger than 0 
%                = stronger smoothing
%
% OUTPUTS:
%   mask_rs    - resized and smoothed mask
%
% REQUIREMENTS:
%   Image Processing Toolbox, MathWorks (REQUIRES LICENSE)



mask = logical(mask); % turn mask into logical matrix

mask_rs = imresize3(mask, scale, 'nearest'); % resize
D = bwdist(mask_rs) - bwdist(~mask_rs); % get mask SDF
D = imgaussfilt3(D, sigma); % gaussian smoothing

mask_rs = D <= n; % turn SDF back into logical mask
mask_rs = imclose(mask_rs, strel('sphere', 2*scale)); % prevent retrusion
mask_rs = bwareaopen(mask_rs, 50, 26); % prevent small objects in mask

end