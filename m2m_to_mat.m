function varargout = m2m_to_mat(varargin)

% Helper function to return tissue masks
%
% INPUTS: 
%    file_path       - file path of m2m folder
%
% Optional:
%    bone_diff       - set true if cortical/trabecular skull, false if
%                      homogenous skull
%
% OUTPUTS:
%    
%    if bone_diff not defined or set to true:
%    brain_mask             - brain mask
%    cortical_mask          - cortical mask
%    trabecular_mask        - trabecular mask
%    skin_mask              - skin mask
%       
%    if bone_diff set to false:
%    brain_mask             - brain mask
%    skull_mask             - homogenous skull mask
%    skin_mask              - skin mask
%
% NOTES:
%    first, install SimNIBS: 
%       https://simnibs.github.io/simnibs/build/html/installation/simnibs_installer.html
%    then, get a T1 MRI scan, and type in CMD: 
%       charm subject01 *file_path* --forcerun
%    input file path of the new m2m folder as an argument in this function



m2m_path = varargin{1}; % first input arg = file path of m2m folder

label_file = fullfile(m2m_path, 'final_tissues.nii.gz');

labels = niftiread(label_file);
info = niftiinfo(label_file);

if (nargin == 1)

    varargout{1} = uint8(labels == 1 | labels == 2 | labels == 3 | labels == 9 | labels == 12); % brain mask
    varargout{2} = uint8(labels == 7); % cortical mask
    varargout{3} = uint8(labels == 8); % trabecular mask
    varargout{4} = uint8(labels == 5); % skin mask

else

    bone_diff = varargin{2}; % second input arg = bone segmentation

    if (bone_diff == false)

        varargout{1} = uint8(labels == 1 | labels == 2 | labels == 3); % brain mask
        varargout{2} = uint8(labels == 7 | labels == 8); % skull mask
        varargout{3} = uint8(labels == 5); % skin mask
    
    else

        varargout{1} = uint8(labels == 1 | labels == 2 | labels == 3 | labels == 9 | labels == 12); % brain mask
        varargout{2} = uint8(labels == 7); % cortical mask
        varargout{3} = uint8(labels == 8); % trabecular mask
        varargout{4} = uint8(labels == 5); % skin mask

    end

end

end