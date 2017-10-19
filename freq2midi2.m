function mmsblsb = freq2midi2(f)
% f = freq2midi(m)
%     
% Convert frequency, f,  in Hz to 
% MIDI note number (m=0-127) and values to bend by
% (m can also be a vector or matrix)
%

% Copyright (c) 2009 Tim Pearce

m = ((log(f*32/440)/log(2))*12)+9;  % finds closest midi value
dif = round(m) - m;                 % find dif. between closest and act Hz
m = round(m);
decval = round(8192 - (dif * 4096));% this is 14bit dec must bend by
                                    % convert to 2 7bit dec numbers
msb = bitshift(decval, -7);         % MostSigBit
lsb = decval - (msb*(2^7));         % LeastSigBit

mmsblsb = [m, msb, lsb];
