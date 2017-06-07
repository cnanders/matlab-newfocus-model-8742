classdef Model8742 < handle
    
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
        
        
        
        u32CommandNum = uint32(1)
        
        % {char 1xm} terminator.  Ethernet uses CR (carriage return)
        % USB uses 'LF' (line feed)
        
        % NOT USED
        cTerminator = 'CR';
        u16InputBufferSize = uint16(2^15);
        u16OutputBufferSize = uint16(2^15);
        
       
        
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
            
            this.comm = tcpip(this.cTcpipHost, this.u16TcpipPort);
            % this.comm.BaudRate = this.u16BaudRate;
            %this.comm.InputBufferSize = this.u16InputBufferSize;
            %this.comm.OutputBufferSize = this.u16OutputBufferSize;
            % this.comm.Terminator = this.cTerminator;

        end
        
        function clearBytesAvailable(this)
            
            this.msg('clearBytesAvailable()');
            
            while this.comm.BytesAvailable > 0
                cMsg = sprintf(...
                    'clearBytesAvailable() clearing %1.0f bytes', ...
                    this.comm.BytesAvailable ...
                );
                this.msg(cMsg);
                fscanf(this.comm, '%c', this.comm.BytesAvailable);
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
            
            this.msg('connect()');
            try
                fopen(this.comm); 
                % Hack to clear initial byest available
                pause(0.01);
                this.clearBytesAvailable();
            catch ME
                
            end
            % this.clearBytesAvailable();
        end
        
        
        
        
        function disconnect(this)
            this.msg('disconnect()');
            try
                fclose(this.comm);
            catch ME
            end
        end
        
        function delete(this)
            this.msg('delete()');
            this.disconnect();
            
        end
        
        function msg(this, cMsg)
            fprintf('Model8742 %s\n', cMsg);
        end
        
        
        function c = getMacAddress(this)
            this.write('MACADDR?');
            c = fscanf(this.comm);
        end
        
        function c = getIpAddress(this)
            this.write('IPADDR?');
            c = fscanf(this.comm);
        end
        
        % Controller firmware version
        function c = getVersion(this)
            this.write('VE?');
            c = fscanf(this.comm);
        end
        
        function c = getIdentity(this)
            this.write('*IDN?');
            c = fscanf(this.comm);
        end
        
        % Stop the motion of an axis. The controller uses acceleration
        % specified using AC command to stop motion.
        function stop(this, u8Axis)
            cCmd = fprintf('%uST', u8Axis);
            this.write(cCmd);
        end
        
        % The actual position represents the internal number of steps made
        % by the controller relative to its position when controller was
        % powered ON or a system reset occurred or Home (DH) command was
        % received.
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        function d = getPosition(this, u8Axis)
            cCmd = fprintf('%uTP', u8Axis);
            d = this.ioDouble(cCmd);
        end
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @return {logical 1x1} true if moving, false if done
        function l = getMotionDoneStatus(this, u8Axis)
           cCmd = fprintf('%ufMD?', u8Axis);
           l = this.ioLogical(cCmd);
        end
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {uint32 1x1} i32Val - absolute position (steps) value values between
        % -2147483648 and +2147483647 (32-bit signed int)
        function moveToTargetPosition(this, u8Axis, i32Val)
            cCmd = fprintf('%uPA%i', u8Axis, i32Val);
            this.write(cCmd);
        end
                 
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {uint32 1x1} u32Val - accelleration in steps/sec^2 (1 to 200000)
        function setAcceleration(this, u8Axis, u32Val)
            cCmd = fprintf('%uAC%u', u8Axis, u32Val);
            this.write(cCmd);
            
        end
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {uint32 1x1} u32Val - velocity in steps/sec (1 to 2000)
        function setVelocity(this, u8Axis, u32Val)
            cCmd = fprintf('%uVA%u', u8Axis, u32Val);
            this.write(cCmd);
            
        end
        
        % Query the acceleration value for an axis
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        function d = getAcceleration(this, u8Axis)
            cCmd = fprintf('%uAC?', u8Axis);
            d = this.ioInt32(cCmd);
        end
        
        % Query the velocity value for an axis
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        function d = getVelocity(this, u8Axis)
            cCmd = fprintf('%uVA?', u8Axis);
            d = this.ioInt32(cCmd);
        end
        
        % Query the target position of an axis
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @return {int32 1x1} the target position of the axis (steps)
        function i32 = getTargetPosition(this, u8Axis)
            cCmd = fprintf('%uPA?', u8Axis);
            i32 = this.ioInt32(cCmd);
        end
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {uint8 1x1} u8Type - motor typr
        %   0 - no motor connected
        %   1 - motor type unknown
        %   2 - 'tiny' motor
        %   3 - 'standard' motor
        function setMotorType(this, u8Axis, u8Type)
            cCmd = fprintf('%uQM%u', u8Axis, u8Type);
            this.write(cCmd);
            
        end
        
        % Saves the controller settings in its non-volatile memory. The
        % controller restores or reloads these settings to working
        % registers automatically after system reset or it reboots. The
        % Purge (XX) command is used to clear non-volatile memory and
        % restore to factory settings. Note that the SM saves parameters
        % for all motors.
        function save(this)
            cCmd = 'SM';
            this.write(cCmd);
            
        end
        
        % Purge all user settings in the controller non-volatile memory and
        % restore them to factory default settings.
        function purge(this)
            cCmd = 'XX';
            this.write(cCmd);
        end
        
        
            
        
    end
    
    
    methods (Access = protected)
        
        % Write a command, read the result and convert to double
        % {char 1xm} cCmd - the command
        function d = ioDouble(cCmd)
            this.write(cCmd);
            c = fscanf(this.comm);
            d = str2double(c);
        end
        
        % Write a command, read the result and convert to logical
        % {char 1xm} cCmd - the command
        function l = ioLogical(cCmd)
            this.write(cCmd);
            c = fscanf(this.comm); % '1' or '0'
            l = logical(str2double(c));
        end
        
        % Write a command, read the result and convert to int32
        % {char 1xm} cCmd - the command
        function i32 = ioInt32(cCmd)
            this.write(cCmd);
            c = fscanf(this.comm);
            i32 = int32(str2double(c));
        end
        
        function l = hasProp(this, c)
            
            l = false;
            if ~isempty(findprop(this, c))
                l = true;
            end
            
        end
        
        % {char 1xm} the command
        function write(this, cCmd)
            %cMsg = sprintf('writeToSerial %u: %s', this.u32CommandNum, cCmd);
            %this.msg(cMsg)
            fprintf(this.comm, cCmd);
            %this.u32CommandNum = this.u32CommandNum + 1;
            
        end
        
        
        function clearInitialBytesAvailable(this, src, evt)
            this.msg('clearInitialBytesAvailable');
            
            % Unset the BytesAvailableFcn so it does not hijack future IO
            % this.comm.BytesAvailableFcn = [];
            
            % Clear available bytes
            this.clearBytesAvailable();
            
        end
        
    end
    
end

