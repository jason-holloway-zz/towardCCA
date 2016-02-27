function setupPtych()
%SETUPPTYCH check to make sure files are on the current path
%   setupPtych may be called prior to running the demo codes, but it is not
%   necessary, as each demo code will make a call to setupPtych prior to
%   using any dependencies. This code must be run before calling ptychMain
%   directly (i.e. not using a demo file)

dirSetupPtych = which('setupPtych');
dirSetupPtych = dirSetupPtych(1:end-12); % strip off 'setupPtych.m' from result
Folder = [dirSetupPtych,filesep,'functions'];

% ~~~~~~~~~~~~~
% borrowed from http://www.mathworks.com/matlabcentral/answers/86740-how-can-i-determine-if-a-directory-is-on-the-matlab-path-programmatically
pathCell = regexp(path, pathsep, 'split');
if ispc  % Windows is not case-sensitive
    onPath = any(strcmpi(Folder, pathCell));
else
    onPath = any(strcmp(Folder, pathCell));
end
% ~~~~~~~~~~~~~

if ~onPath
    addpath(Folder);
end


end