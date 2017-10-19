% creates an arbitary M matrix, bends some notes, 
% then saves as new midi file
% filename is that for the warped midi to be saved as

%midifn = 'octaves.mid';
filename1 = 'octavesplain.mid';          % name to be saved as
filename2 = 'scale.mid';         % name to be saved as


% plain midi matrix -------------------------------------------------------
% -------------------------------------------------------------------------
%M(1,1) = 1;                         % all in track 1
%M(1,2) = 1;                         % all in channel 1
%M(1,3) = freq2midi([419]);           % note pitch (need to go to freq2midi)
%M(1,4) = 60;                        % velocity  
%M(1,5) = [0];  % time note on (secs)
%M(1,6) = [0]+6;% time note off(secs)

%plainmidi = matrix2midi(M);           % converts M -> plainmidi
%writemidi(plainmidi, filename1);      % saves normal file

max=5;
f = [];
for i=1:max
    f = [f; 6.875*( 2^((13 + i) /max ))];
end


% warp midi matrix --------------------------------------------------------
% -------------------------------------------------------------------------
M = zeros(max, 8);

Mmini = freq2midi2([f]);    % note pitch (need to go to freq2midi2)

M(:,1) = 1;                         % all in track 1
M(:,2) = 1;                         % all in channel 1
M(:,3) = Mmini(:,1);        % nearest whole midi note
M(:,4) = 60;                        % velocity  
M(:,5) = [0:0.5:(max-1)/2]';               % time note on (secs)
M(:,6) = M(:,5)+0.4;             % time note off(secs)
M(:,7) = Mmini(:,2);        % extra column-how much bend note MSB 
M(:,8) = Mmini(:,3);        % extra column-how much bend note LSB


warpedmidi = matrix2midi2(M);         % converts M -> warpedmidi (takes in account of col 7 and 8)
%midiInfo(warpedmidi);                 % prints midi data
writemidi(warpedmidi, filename2);     % saves warped file


%midi = readmidi('bent.mid');
%midiInfo(midi);