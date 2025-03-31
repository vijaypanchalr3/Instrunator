Voltage = [-1,1,0.1];
T = Voltage(1):Voltage(3):Voltage(2);


function new = savettt(filename)
    count = 1;
    
    % Check if the file exists and modify the filename
    while isfile(filename)
        newfilename = split(filename,".");
        newfilename = newfilename(1);
        extend =  sprintf('%d.asc', count);
        filename = append(newfilename, extend);
        filename = strjoin(filename);
        count = count + 1;
    end
    
    % Check if obj has the data field
    % if ~isfield(obj, 'finaldata')
    %     error('The input object does not contain a "data" field.');
    % end
    new = filename;
end

savettt('Z:\\data\\vijay\\test.asc')