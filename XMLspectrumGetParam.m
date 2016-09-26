%
% Release date: 2016/09/26
% Author: M. Bawaj
%

% 1. Span frequency
% XML node name: Span_Freq
% Unit: Hz
%
% 2. Start frequency
% XML node name: Start_Freq
% Unit: Hz
%
% 3. Stop frequency
% XML node name: Stop_Freq
% Unit: Hz
%
% 4. Center frequency
% XML node name: Center_Freq
% Unit: Hz
%
% 5. Reference level
% XML node name: RefLevel
% Unit: dBm
%
% 6. Attenuator
% XML node name: Atten
% Unit: ?
%
% 7. Preamplifier
% XML node name: PreAmpli
% Unit: 0 = off, 1 = on
%
% 8. Resolution bandwidth
% XML node name: RBW
% Unit: Value from look-up table: RBW_lut
%
% 9. Video bandwidth
% XML node name: VBW
% Unit: Value from look-up table: ?
%
% 10. Trace info
% XML node name: Trace1_Info, Trace2_Info, Trace3_Info, Trace4_Info
% Unit: Array of three values: ?, ?, Averages number

%
% 12	1Meg
% 11	300k
% 10	100k
% 9	30k
% 8	10k
% 7	3k
% 6	1k
% 5	300
% 4	100
% 3	30
% 2	10
% 1
%

function spectParam = XMLspectrumGetParam (XMLfilename)

spectParam = zeros(10, 1);

RBW_lut = [ 0, 10, 30, 100, 300, 1e3, 3e3, 10e3, 30e3, 100e3, 300e3, 1e6 ];

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
    error('XML file does not containt root node.');
end

temp = textscan(char(node.getElementsByTagName('Span_Freq').item(0).getTextContent),'%f');
spectParam(1) = temp{1};

temp = textscan(char(node.getElementsByTagName('Start_Freq').item(0).getTextContent),'%f');
if temp{1} == 0
    temp{1} = 1;
end
spectParam(2) = temp{1};

temp = textscan(char(node.getElementsByTagName('Stop_Freq').item(0).getTextContent),'%f');
spectParam(3) = temp{1};

temp = textscan(char(node.getElementsByTagName('Center_Freq').item(0).getTextContent),'%f');
spectParam(4) = temp{1};

temp = textscan(char(node.getElementsByTagName('RefLevel').item(0).getTextContent),'%f');
spectParam(5) = temp{1};

temp = textscan(char(node.getElementsByTagName('Atten').item(0).getTextContent),'%f');
spectParam(6) = temp{1};

temp = textscan(char(node.getElementsByTagName('PreAmpli').item(0).getTextContent),'%f');
spectParam(7) = temp{1};

temp = textscan(char(node.getElementsByTagName('RBW').item(0).getTextContent),'%f');
spectParam(8) = RBW_lut(temp{1});

temp = textscan(char(node.getElementsByTagName('VBW').item(0).getTextContent),'%f');
spectParam(9) = RBW_lut(temp{1});

C = zeros(3,1);
for i = 1:3
    str = char(node.getElementsByTagName('Trace1_Info').item(0).getTextContent);
    str = strrep(str,',',' ');
    temp = textscan(str,'%f');
    C = temp{1};
end
spectParam(10) = C(3);
%temp = textscan(char(node.getElementsByTagName('Trace1_Info').item(0).getTextContent),'%f');
for i = 1:3
    str = char(node.getElementsByTagName('Trace2_Info').item(0).getTextContent);
    str = strrep(str,',',' ');
    temp = textscan(str,'%f');
    C = temp{1};
end
spectParam(11) = C(3);

for i = 1:3
    str = char(node.getElementsByTagName('Trace3_Info').item(0).getTextContent);
    str = strrep(str,',',' ');
    temp = textscan(str,'%f');
    C = temp{1};
end
spectParam(12) = C(3);

for i = 1:3
    str = char(node.getElementsByTagName('Trace4_Info').item(0).getTextContent);
    str = strrep(str,',',' ');
    temp = textscan(str,'%f');
    C = temp{1};
end
spectParam(13) = C(3);


%disp(Span_Freq{1});

return
