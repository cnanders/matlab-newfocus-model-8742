classdef Model8742 < newfocus.AbstractModel8742
    
    %Model8742 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        % {tcpip 1x1} tcpip connection 
        comm
        
    end
    
    properties (Access = private)
        
        % {char 1xm} tcp/ip host
        cTcpipHost = '192.168.0.2'
        
        % {uint16 1x1} tcpip port network control uses telnet port 23
        % DO NOT OVERRIDE UNLESS YOU KNOW WHAT YOU ARE DOING
        u16TcpipPort = uint16(23)
                
        % {uint32 1x1} storage for the number of commands that have been
        % asked since this comm class has been instantiated
        u32CommandNum = uint32(1)        
        
        % NOT USED
        u16InputBufferSize = uint16(2^15);
        u16OutputBufferSize = uint16(2^15);
        
        dTimeout = 5
        
    end
    
    methods
        
        function this = Model8742(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}));
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
        end
        
        function init(this)
            
            this.comm = tcpclient(this.cTcpipHost, this.u16TcpipPort);

            % this.comm = tcpip(this.cTcpipHost, this.u16TcpipPort);
            % this.comm.Terminator = 13; % carriage return
            % Don't use Nagle's algorithm; send data
            % immediately to the newtork
            % this.comm.TransferDelay = 'off'; 

            % this.comm.BaudRate = this.u16BaudRate;
            %this.comm.InputBufferSize = this.u16InputBufferSize;
            %this.comm.OutputBufferSize = this.u16OutputBufferSize;
            % this.comm.Terminator = this.cTerminator;

        end
        
        function clearInitialSixBytesAvailable(this)
            
            this.msg('clearInitialSixBytesAvailable()');
            
            while this.comm.BytesAvailable < 6
                % wait
                this.msg('waiting for initial BytesAvailable == 6'); 
            end
            
            cMsg = sprintf(...
                'clearInitialSixBytesAvailable() clearing %1.0f bytes', ...
                this.comm.BytesAvailable ...
            );
            this.msg(cMsg);
            c = read(this.comm, this.comm.BytesAvailable);
        end
        
        function clearBytesAvailable(this)
            
            this.msg('clearBytesAvailable()');
            
            while this.comm.BytesAvailable > 0
                cMsg = sprintf(...
                    'clearBytesAvailable() clearing %1.0f bytes', ...
                    this.comm.BytesAvailable ...
                );
                this.msg(cMsg);
                % fscanf(this.comm, '%c', this.comm.BytesAvailable);
                read(this.comm, this.comm.BytesAvailable);
            end
        end
        
        function connect(this)
            
            % Hack to clear the six bytes that become available every time
            % I establish a tcpip conneciton with the Model 8742
            
            %{
            this.comm.BytesAvailableFcnCount = 6;
            this.comm.BytesAvailableFcnMode = 'byte';
            this.comm.BytesAvailableFcn = @this.clearInitialBytesAvailable;
            %}
            
            %{
            this.msg('connect()');
            try
                fopen(this.comm); 
                % Hack to clear initial bytes available which contain
                % the following six bytes
                % [ 255   253     3   255   251     1]
                
                % pause(0.1);
                this.clearInitialSixBytesAvailable();
            catch ME
                
            end
            %}
            
            this.clearInitialSixBytesAvailable();
            
            % this.clearBytesAvailable();
        end
        
        
        
        
        function disconnect(this)
            
            %{
            this.msg('disconnect()');
            try
                fclose(this.comm);
            catch ME
            end
            %}
        end
        
        function delete(this)
            this.msg('delete()');
            this.disconnect();
            
        end
        
        function msg(this, cMsg)
            fprintf('Model8742 %s\n', cMsg);
        end
        
        
        function c = getMacAddress(this)
            c = this.queryChar('MACADDR?');
        end
        
        function c = getIpAddress(this)
            c = this.queryChar('IPADDR?');
        end
        
        % Controller firmware version
        function c = getVersion(this)
            c = this.queryChar('VE?');
        end
        
        % Return the first error code in the buffer.  May need to 
        % call repeatedly if multiple errors are in the buffer
        function i32 = getErrorCode(this)
            i32 = this.queryInt32('TE?');
        end
        
        function c = getErrors(this)
            c = this.queryChar('TB?');
        end
        
        function c = getIdentity(this)
            c = this.queryChar('*IDN?');
        end
        
        % Stop the motion of an axis. The controller uses acceleration
        % specified using AC command to stop motion.
        function stop(this, u8Axis)
            cCmd = sprintf('%uST', u8Axis);
            this.command(cCmd);
        end
        
        % The actual position represents the internal number of steps made
        % by the controller relative to its position when controller was
        % powered ON or a system reset occurred or Home (DH) command was
        % received.
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        function d = getPosition(this, u8Axis)
            cCmd = sprintf('%uTP?', u8Axis);
            d = this.queryDouble(cCmd);
        end
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @return {logical 1x1} true if moving, false if done
        function l = getMotionDoneStatus(this, u8Axis)
           cCmd = sprintf('%uMD?', u8Axis);
           l = this.queryLogical(cCmd);
        end
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {uint32 1x1} i32Val - absolute position (steps) value values between
        % -2147483648 and +2147483647 (32-bit signed int)
        function moveToTargetPosition(this, u8Axis, i32Val)
            cCmd = sprintf('%uPA%i', u8Axis, i32Val);
            this.command(cCmd);
        end
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {int8 1x1} i8Direction - negative number negative positive
        % for positive
        function moveIndefinitely(this, u8Axis, i8Direction)
           if i8Direction < 0
                cCmd = sprintf('%uMV-', u8Axis);
           else
               cCmd = sprintf('%uMV+', u8Axis);
           end
           this.command(cCmd);
        end
         

        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {uint32 1x1} u32Val - accelleration in steps/sec^2 (1 to 200000)
        function setAcceleration(this, u8Axis, u32Val)
            cCmd = sprintf('%uAC%u', u8Axis, u32Val);
            this.command(cCmd);
            
        end
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {uint32 1x1} u32Val - velocity in steps/sec (1 to 2000)
        function setVelocity(this, u8Axis, u32Val)
            cCmd = sprintf('%uVA%u', u8Axis, u32Val);
            this.command(cCmd);
            
        end
        
        % Query the acceleration value for an axis
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        function d = getAcceleration(this, u8Axis)
            cCmd = sprintf('%uAC?', u8Axis);
            d = this.queryInt32(cCmd);
        end
        
        % Query the velocity value for an axis
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        function d = getVelocity(this, u8Axis)
            cCmd = sprintf('%uVA?', u8Axis);
            d = this.queryInt32(cCmd);
        end
        
        % Query the target position of an axis
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @return {int32 1x1} the target position of the axis (steps)
        function i32 = getTargetPosition(this, u8Axis)
            cCmd = sprintf('%uPA?', u8Axis);
            i32 = this.queryInt32(cCmd);
        end
        
        
        function i32 = getHomePosition(this, u8Axis)
            cCmd = sprintf('%uDH?', u8Axis);
            i32 = this.queryInt32(cCmd);
        end
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {uint8 1x1} u8Type - motor typr
        %   0 - no motor connected
        %   1 - motor type unknown
        %   2 - 'tiny' motor
        %   3 - 'standard' motor
        function setMotorType(this, u8Axis, u8Type)
            cCmd = sprintf('%uQM%u', u8Axis, u8Type);
            this.command(cCmd);
            
        end
        
        % Saves the controller settings in its non-volatile memory. The
        % controller restores or reloads these settings to working
        % registers automatically after system reset or it reboots. The
        % Purge (XX) command is used to clear non-volatile memory and
        % restore to factory settings. Note that the SM saves parameters
        % for all motors.
        function save(this)
            cCmd = 'SM';
            this.command(cCmd);
            
        end
        
        % Purge all user settings in the controller non-volatile memory and
        % restore them to factory default settings.
        function purge(this)
            cCmd = 'XX';
            this.command(cCmd);
        end
        
        
        
                    
    end
    
    
    methods (Access = protected)
      
        
        % Write a command, read the result and convert to double
        % {char 1xm} cCmd - the command
        function d = queryDouble(this, cCmd)
            this.command(cCmd);
            [c, lError] = this.read();
            if lError
                d = 0;
            else
                d = str2double(c);
            end
        end
        
        % Write a command, read the result and convert to logical
        % {char 1xm} cCmd - the command
        function l = queryLogical(this, cCmd)
            this.command(cCmd);
            [c, lError] = this.read(); % '1' or '0'
            if lError
                l = false;
            else
                l = logical(str2double(c));
            end
        end
        
        % Write a command, read the result and convert to int32
        % {char 1xm} cCmd - the command
        function i32 = queryInt32(this, cCmd)
            this.command(cCmd);
            [c, lError] = this.read();
            if lError
                i32 = int32(0);
            else
                i32 = int32(str2double(c));
            end
        end
        
        % Write a command, read the result
        % {char 1xm} cCmd - the command
        function c = queryChar(this, cCmd)
            this.command(cCmd);
            [c, lError] = this.read();
            if lError
                c = '';
            end
        end
        
        function l = hasProp(this, c)
            
            l = false;
            if ~isempty(findprop(this, c))
                l = true;
            end
            
        end
        
        % {char 1xm} the command
        function command(this, cCmd)
            
            %cMsg = sprintf('command %u: %s', this.u32CommandNum, cCmd);
            %this.msg(cMsg)
            
            % tcpip
            % fprintf(this.comm, cCmd);
            
            % tcpclient
            u8Cmd = [uint8(cCmd) 13];
            write(this.comm, u8Cmd);
            
            %this.u32CommandNum = this.u32CommandNum + 1;
            
        end
        
        % Returns list of bytes (uint8) from the client
        % also returns {logical} error if the terminator is never reached
        
        function [u8, lError] = readToTerminator(this, u8Terminator)
            
            lDebug = false;
            lTerminatorReached = false;
            u8Result = [];
            idTic = tic;
            while(~lTerminatorReached && ...
                   toc(idTic) < this.dTimeout )
                if (this.comm.BytesAvailable > 0)
                    
                    cMsg = sprintf(...
                        'readToTerminator reading %u bytesAvailable', ...
                        this.comm.BytesAvailable ...
                    );
                    lDebug && this.msg(cMsg);
                    % Append available bytes to previously read bytes
                    
                    % {uint8 1xm} 
                    u8Val = read(this.comm, this.comm.BytesAvailable);
                    % {uint8 1x?}
                    u8Result = [u8Result u8Val];
                    % search new data for terminator
                    u8Index = find(u8Val == u8Terminator);
                    if ~isempty(u8Index)
                        lTerminatorReached = true;
                    end
                end
            end
            
            lError = ~lTerminatorReached;
            u8 = u8Result;
            
        end
        
        % Read until the terminator is reached and convert to ASCII if
        % necessary (tcpip and tcpclient transmit and receive binary data).
        % @return {char 1xm} the ASCII result
        
        function [c, lError] = read(this)
            
            % default response
            c = '';
            
            % tcpclient
            [u8Result, lError] = this.readToTerminator(int8(13));
            
            if lError
                this.clearBytesAvailable();
                return;
            end
            
            % remove carriage return and line feed terminator
            u8Result = u8Result(1 : end - 2);
            % convert to ASCII (char)
            c = char(u8Result);
            
            
            
            % tcpip
            % c = fscanf(this.comm)
            
        end
        
        
    end
    
end

