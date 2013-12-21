function libName = jDAQmx()

	libName = 'libnidaqmx';
	libFile = [libName,'.so'];
	headerFile = '/usr/local/include/NIDAQmx.h';

	if ~libisloaded(libName)
		warning('off','MATLAB:loadlibrary:parsewarnings');
		fList = loadlibrary(libFile,headerFile);
		warning('on','MATLAB:loadlibrary:parsewarnings');
	end
end

