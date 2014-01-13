function jDAQmxReset(devName)

    import jDAQmx.*;
    
    libName = jDAQmx();
    
	err = calllib(libName, 'DAQmxResetDevice', devName);
    
    if (err ~= 0 )
		disp(['Error: ',num2str(err)]);
	end
