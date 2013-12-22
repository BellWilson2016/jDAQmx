function libName = jDAQmx()

	libName = 'libnidaqmx';
	libFile = [libName,'.so'];
	headerFile = '/usr/local/include/NIDAQmx.h';

	if ~libisloaded(libName)
		warning('off','all');
		disp(['Loading ', libName, '...']);
		fList = loadlibrary(libFile,headerFile);
		warning('on','all');
	end
end

