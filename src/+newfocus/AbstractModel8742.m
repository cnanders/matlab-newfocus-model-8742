classdef AbstractModel8742 < handle
    
    
    methods (Abstract)
       
        init(this)  
        connect(this)
        disconnect(this)

        c = getMacAddress(this)
        c = getIpAddress(this)
        c = getVersion(this)
        i32 = getErrorCode(this)
        c = getErrors(this)
        c = getIdentity(this)
            
        % Stop the motion of an axis. The controller uses acceleration
        % specified using AC command to stop motion.
        stop(this, u8Axis)
           
        % The actual position represents the internal number of steps made
        % by the controller relative to its position when controller was
        % powered ON or a system reset occurred or Home (DH) command was
        % received.
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        d = getPosition(this, u8Axis)
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @return {logical 1x1} true if moving, false if done
        l = getMotionDoneStatus(this, u8Axis)
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {uint32 1x1} i32Val - absolute position (steps) value values between
        % -2147483648 and +2147483647 (32-bit signed int)
        moveToTargetPosition(this, u8Axis, i32Val)
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {int8 1x1} i8Direction - negative number negative positive
        % for positive
        moveIndefinitely(this, u8Axis, i8Direction)

        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {uint32 1x1} u32Val - accelleration in steps/sec^2 (1 to 200000)
        setAcceleration(this, u8Axis, u32Val)
          
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {uint32 1x1} u32Val - velocity in steps/sec (1 to 2000)
        setVelocity(this, u8Axis, u32Val)
        
        % Query the acceleration value for an axis
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        d = getAcceleration(this, u8Axis)
        
        
        % Query the velocity value for an axis
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        d = getVelocity(this, u8Axis)
        
        
        % Query the target position of an axis
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @return {int32 1x1} the target position of the axis (steps)
        i32 = getTargetPosition(this, u8Axis)
         
        
        i32 = getHomePosition(this, u8Axis)
        
        
        % @param {uint8 1x1} u8Axis - axis number (1 to 4)
        % @param {uint8 1x1} u8Type - motor typr
        %   0 - no motor connected
        %   1 - motor type unknown
        %   2 - 'tiny' motor
        %   3 - 'standard' motor
        setMotorType(this, u8Axis, u8Type)
        
        % Saves the controller settings in its non-volatile memory. The
        % controller restores or reloads these settings to working
        % registers automatically after system reset or it reboots. The
        % Purge (XX) command is used to clear non-volatile memory and
        % restore to factory settings. Note that the SM saves parameters
        % for all motors.
        save(this)
        
        % Purge all user settings in the controller non-volatile memory and
        % restore them to factory default settings.
        purge(this)
        
       
                    
    end
    
    
    
    
end

