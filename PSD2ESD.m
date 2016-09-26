%
% Release date: 2016/09/26
% Author: M. Bawaj
%

% The function converts Power Spectral Density [dBm/Hz] to Energy Spectral
% Density [V^2/Hz] on the specified Rload.
function ESDarray = PSD2ESD(PSDarray, Rload)

ESDarray = Rload * 10.^((PSDarray-30)/10);
