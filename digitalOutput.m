%% 
%		digitalOutput()
%
%		A class for NI DAQmx data acquisition from the libraries.
%
%		JSB 12/2013
%%
classdef digitalOutput < handle

	properties
		taskHandle
	end

	methods
		function DO = digitalOutput(deviceName)
		end
		function addChannel(channelList)
		end
		function setSampleRate(aSR)
		end
		function start()
		end
		function trigger()
		end
		function wait()
		end
		function putData(data)
		end
	end

end	
