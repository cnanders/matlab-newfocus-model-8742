[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% Add src
addpath(genpath(fullfile(cDirThis, '..', 'src')));

% 'u16TcpipPort', 80 ...

comm = newfocus.Model8742(...
    'cTcpipHost', '192.168.0.3' ...
);
comm.init();
comm.connect();
% comm.clearBytesAvailable();
%comm.getVersion()
%comm.getIdentity()


% comm.disconnect();





