%
% Release date: 2016/09/26
% Author: M. Bawaj
%

function normalizedPSD = normalizePSD (spectData, RBW)

normalizedPSD = spectData - 10*log10(RBW);