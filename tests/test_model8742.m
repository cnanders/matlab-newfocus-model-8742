[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% Add src
addpath(genpath(fullfile(cDirThis, '..', 'src')));

% 'u16TcpipPort', 80 ...

cHost = '192.168.0.3';
cHost = '192.168.10.23';

comm = newfocus.Model8742(...
    'cTcpipHost', cHost ...
);
comm.init();
comm.connect();
comm.getVersion()
comm.getIdentity()


% comm.disconnect();





