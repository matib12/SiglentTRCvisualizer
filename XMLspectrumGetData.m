%
% Release date: 2016/09/26
% Author: M. Bawaj
%

function spectData = XMLspectrumGetData (XMLfilename)

%XMLfilename = 'E:\virgo\SSA_160912163018.TRC';
%XMLfilename = 'SSA_160912155904.TRC';
%XMLfilename = 'E:\SSA_160926165414.TRC';

try
   tree = xmlread(XMLfilename);
catch
   error('Failed to read XML file %s.',XMLfilename);
end

node = tree.getFirstChild;
while ~isempty(node)
    if strcmpi(node.getNodeName, 'nsp_config')
        break;
    else
        node = node.getNextSibling;
    end
end

if isempty(node)
    error('Input file does not containt root node.');
end

%%node.getElementsByTagName('Traces_data').item(0).getTextContent
Data_node = node.getElementsByTagName('Traces_data').item(0);

%%Iloœæ punktów pomiarowych
points_num = node.getElementsByTagName('Traces_data').item(0).getLength;
%freq_points = logspace(log10(Start_freq),log10(Stop_freq),points_num);

% Sample number of traces in the TRC file
str = char(Data_node.item(1).getTextContent);
str = strrep(str,',',' ');
temp = textscan(str,'%f');
numberOfTraces = length(temp{1});
disp(['Number of traces: ' num2str(numberOfTraces)]); % Debug line

spectData = zeros(points_num, numberOfTraces);
i = points_num-1;

while ~(i < 0)
    str = char(Data_node.item(i).getTextContent);
    str = strrep(str,',',' ');
    temp = textscan(str,'%f');
    spectData(i+1,:) = temp{1};
    i = i-1;
end