[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% Add src
addpath(genpath(fullfile(cDirThis, '..', 'src')));

% 'u16TcpipPort', 80 ...

model8742 = newfocus.Model8742(...
    'cTcpipHost', '192.168.0.5' ...
);
model8742.init();
model8742.connect();
model8742.getVersion()
model8742.getIdentity()
model8742.disconnect();





