classdef Model8742Virtual < newfocus.AbstractModel8742
    
    %Model8742 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    properties (Access = private)
        
        % {char 1xm} tcp/ip host
        cTcpipHost = '192.168.0.2'
        
        lMovingPositive = [false false false false]
        lMovingNegative = [false false false false]
        
        % {double 1x4}
        i32Val = int32([0 0 0 0]);
        
        u32Accel = uint32([5 5 5 5]);
        
        % {uint32  1x4} steps/sec
        u32Velocity = uint32([10 10 10 10]);
        
        % {double 1x1} - time to wait between increasing / decreasing
        % during indefinite moves
        dPeriod = 0.25
        
        % {timer 1x1}
        t
    end
    
    methods
        
        function this = Model8742Virtual(varargin)
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    % this.msg(sprintf('settting %s', varargin{k}));
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
        end
        
        function init(this)
            
        end
        
        function connect(this)
           
        end
        

        function disconnect(this)         
        end
        
        function delete(this)
            if ~isempty(this.t) && ...
                isvalid(this.t)
                stop(this.t)
                delete(this.t)
            end
            
        end
        
        function c = getMacAddress(this)
            c = 'virtual getMacAddress()';
        end
        
        function c = getIpAddress(this)
            c = this.cTcpipHost;
        end
        
        % Controller firmware version
        function c = getVersion(this)
            c = 'virtual getVersion()';
        end
        
        % Return the first error code in the buffer.  May need to 
        % call repeatedly if multiple errors are in the buffer
        function i32 = getErrorCode(this)
            i32 = 0;
        end
        
        function c = getErrors(this)
            c = 'no errors';
        end
        
        function c = getIdentity(this)
            c = 'virtual getIdentity()';
        end
        
        % Stop the motion of an axis. The controller uses acceleration
        % specified using AC command to stop motion.
        function stop(this, u8Axis)
            this.lMovingNegative(u8Axis) = false;
            this.lMovingPositive(u8Axis) = false;
        end
        
        % The actual position represents the internal number of steps made
        % by the controller relative to its position when controller was
        % powered ON or a system reset occurred or Home (DH) command was
        % received.
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        function d = getPosition(this, u8Axis)
            d = this.i32Val(u8Axis);
        end
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @return {logical 1x1} true if moving, false if done
        function l = getMotionDoneStatus(this, u8Axis)
           l = ~(this.lMovingNegative(u8Axis) || this.lMovingPositive(u8Axis));
        end
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {uint32 1x1} i32Val - absolute position (steps) value values between
        % -2147483648 and +2147483647 (32-bit signed int)
        function moveToTargetPosition(this, u8Axis, i32Val)
            this.i32Val(u8Axis) = i32Val;
        end
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {int8 1x1} i8Direction - negative number negative positive
        % for positive
        function moveIndefinitely(this, u8Axis, i8Direction)
            
           if i8Direction < 0
                this.lMovingNegative(u8Axis) = true;
                this.lMovingPositive(u8Axis) = false;
           else
                this.lMovingNegative(u8Axis) = false;
                this.lMovingPositive(u8Axis) = true;
           end
           
           this.move(u8Axis, i8Direction);
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
            this.u32Velocity(u8Axis) = u32Val;
            
        end
        
        % Query the acceleration value for an axis
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        function d = getAcceleration(this, u8Axis)
            d = double(this.u32Accel(u8Axis));
        end
        
        % Query the velocity value for an axis
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        function d = getVelocity(this, u8Axis)
            d = double(this.u32Velocity(u8Axis));
        end
        
        % Query the target position of an axis
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @return {int32 1x1} the target position of the axis (steps)
        function i32 = getTargetPosition(this, u8Axis)
            i32 = this.i32Val(u8Axis);
        end
        
        
        function i32 = getHomePosition(this, u8Axis)
            i32 = int32(0);
        end
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {uint8 1x1} u8Type - motor typr
        %   0 - no motor connected
        %   1 - motor type unknown
        %   2 - 'tiny' motor
        %   3 - 'standard' motor
        function setMotorType(this, u8Axis, u8Type)
            
        end
        
        % Saves the controller settings in its non-volatile memory. The
        % controller restores or reloads these settings to working
        % registers automatically after system reset or it reboots. The
        % Purge (XX) command is used to clear non-volatile memory and
        % restore to factory settings. Note that the SM saves parameters
        % for all motors.
        function save(this)
            
        end
        
        % Purge all user settings in the controller non-volatile memory and
        % restore them to factory default settings.
        function purge(this)
            
        end
        
        
        
                    
    end
    
    
    methods (Access = protected)
      
        function move(this, u8Axis, i8Direction)
            
            if ~isempty(this.t) && ...
                isvalid(this.t)
                stop(this.t)
                delete(this.t)
            end
            
            if  ~this.lMovingPositive(u8Axis) && ...
                ~this.lMovingNegative(u8Axis)
                return
            end
            
            i32Step = i8Direction * int32(double(this.u32Velocity(u8Axis)) * this.dPeriod);
            this.i32Val(u8Axis) = this.i32Val(u8Axis) + i32Step;
            
            % Call move again 
            this.t = timer( ...
                'TimerFcn', @(src, evt) this.move(u8Axis, i8Direction), ...
                'StartDelay', this.dPeriod, ...
                'ExecutionMode', 'singleShot' ...
            );
            start(this.t);
            
        end
        
        function l = hasProp(this, c)
            
            l = false;
            if ~isempty(findprop(this, c))
                l = true;
            end
            
        end
        
        
    end
    
end

