%% 
%		digitalInput()
%
%		A class for NI DAQmx data acquisition from the libraries.
%
%		JSB 12/2013
%%
classdef digitalInput < handle

	properties
		taskHandle
	end

	methods
		function DI = digitalInput(deviceName)
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
		function data = getData()
		end
	end

end	
