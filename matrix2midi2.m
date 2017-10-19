function midi=matrix2midi(M,ticks_per_quarter_note,timesig)
% midi=matrix2midi(M,ticks_per_quarter_note)
%
% generates a midi matlab structure from a matrix
%  specifying a list of notes.  The structure output
%  can then be used by writemidi.m
%
% M: input matrix:
%   1     2    3  4   5  6  
%  [track chan nn vel t1 t2] !!!!(any more cols ignored...)!!!!
%
% optional arguments:
% - ticks_per_quarter_note: integer (default 300)
% - timesig: a vector of len 4 (default [4,2,24,8])
%

% Copyright (c) 2009 Ken Schutte
% more info at: http://www.kenschutte.com/midi

% TODO options:
%  - note-off vs vel=0
%  - tempo, ticks, etc

if nargin < 2
  ticks_per_quarter_note = 300;
end

if nargin < 3
  timesig = [4,2,24,8];
end

tracks = unique(M(:,1));
Ntracks = length(tracks);

% start building 'midi' struct

if (Ntracks==1)
  midi.format = 0;
else
  midi.format = 1;
end

midi.ticks_per_quarter_note = ticks_per_quarter_note;

tempo = 500000;   % could be set by user, etc...
% (microsec per quarter note)

for i=1:Ntracks
  
  trM = M(i==M(:,1),:);
  
  note_events_onoff = [];
  note_events_n = [];
  note_events_ticktime = [];
 

  % gather all the notes:
  for j=1:size(trM,1)    
    % note bend event:
    note_events_onoff(end+1)    = 2;
    note_events_n(end+1)        = j;
    note_events_ticktime(end+1) = 1e6 * trM(j,5) * ticks_per_quarter_note / tempo;  % ROW 5 WHICH IS TIME OF NOTE BEND ON
    
    % note on event:
    note_events_onoff(end+1)    = 1;
    note_events_n(end+1)        = j;
    note_events_ticktime(end+1) = 1e6 * trM(j,5) * ticks_per_quarter_note / tempo;  % ROW 5 WHICH IS TIME ON
    
    % note off event:
    note_events_onoff(end+1)    = 0;
    note_events_n(end+1)        = j;
    note_events_ticktime(end+1) = 1e6 * trM(j,6) * ticks_per_quarter_note / tempo;  % ROW 6 WHICH IS TIME OFF
  end

  
  msgCtr = 1;
  
  % set tempo...
  midi.track(i).messages(msgCtr).deltatime = 0;
  midi.track(i).messages(msgCtr).type = 81;
  midi.track(i).messages(msgCtr).midimeta = 0;
  midi.track(i).messages(msgCtr).data = encode_int(tempo,3);
  midi.track(i).messages(msgCtr).chan = [];
  msgCtr = msgCtr + 1;
  
  % set time sig...
  midi.track(i).messages(msgCtr).deltatime = 0;
  midi.track(i).messages(msgCtr).type = 88;
  midi.track(i).messages(msgCtr).midimeta = 0;
  midi.track(i).messages(msgCtr).data = timesig(:);
  midi.track(i).messages(msgCtr).chan = [];
  msgCtr = msgCtr + 1;
  
  % unknown meta event, neccessary for pitch bend range?
 % midi.track(i).messages(msgCtr).deltatime = 0;
 % midi.track(i).messages(msgCtr).type = 33;
 % midi.track(i).messages(msgCtr).midimeta = 0;
 % midi.track(i).messages(msgCtr).data = 1;
 % midi.track(i).messages(msgCtr).chan = [];
 % msgCtr = msgCtr + 1;
  
  
  % set pitch bend range...!!!!!!!!                        PITCH BEND RANGE
  %midi.track(i).messages(msgCtr).deltatime = 0;
  %midi.track(i).messages(msgCtr).type = 176;
  %midi.track(i).messages(msgCtr).midimeta = 1;
  %midi.track(i).messages(msgCtr).data = [ 39 ; 5 ];         % was 100;0
  %midi.track(i).messages(msgCtr).chan = [];
  %msgCtr = msgCtr + 1;
  
  % set pitch bend range...!!!!!!!!                        PITCH BEND RANGE
%  midi.track(i).messages(msgCtr).deltatime = 0;
 % midi.track(i).messages(msgCtr).type = 176;
 %% midi.track(i).messages(msgCtr).midimeta = 1;
 % midi.track(i).messages(msgCtr).data = [ 100 ; 0 ];   
 % midi.track(i).messages(msgCtr).chan = [];
%  msgCtr = msgCtr + 1;  
  
  % set pitch bend range...!!!!!!!!                        PITCH BEND RANGE
 % midi.track(i).messages(msgCtr).deltatime = 0;
 % midi.track(i).messages(msgCtr).type = 176;
 % midi.track(i).messages(msgCtr).midimeta = 1;
 % midi.track(i).messages(msgCtr).data = [ 6 ; 24 ];       % 24 for +/- 12 semitones
 % midi.track(i).messages(msgCtr).chan = [];
 % msgCtr = msgCtr + 1;  
  
  % set pitch bend range...!!!!!!!!                        PITCH BEND RANGE
 % midi.track(i).messages(msgCtr).deltatime = 0;
 % midi.track(i).messages(msgCtr).type = 176;
 %midi.track(i).messages(msgCtr).midimeta = 1;
 % midi.track(i).messages(msgCtr).data = [ 38 ; 0 ];
 % midi.track(i).messages(msgCtr).chan = [];
 % msgCtr = msgCtr + 1;  
  
  
  
  
  [junk,ord] = sort(note_events_ticktime);
  
  prevtick = 0;
  for j=1:length(ord)                       
    
    n = note_events_n(ord(j));
    cumticks = note_events_ticktime(ord(j));
    
    midi.track(i).messages(msgCtr).deltatime = cumticks - prevtick;
    midi.track(i).messages(msgCtr).midimeta = 1; 
    midi.track(i).messages(msgCtr).chan = trM(n,2);
    midi.track(i).messages(msgCtr).used_running_mode = 0;

    if (note_events_onoff(ord(j))==1)
      % note on:
      midi.track(i).messages(msgCtr).type = 144;
      midi.track(i).messages(msgCtr).data = [trM(n,3); trM(n,4)];   % PITCH, VELOCITY
    elseif (note_events_onoff(ord(j))==0)
      %-- note off msg:
      %midi.track(i).messages(msgCtr).type = 128;
      %midi.track(i).messages(msgCtr).data = [trM(n,3); trM(n,4)];
      %-- note on vel=0:
      midi.track(i).messages(msgCtr).type = 128;
      midi.track(i).messages(msgCtr).data = [trM(n,3); 0];
    elseif (note_events_onoff(ord(j))==2)
      %-- note bend on msg:        
      midi.track(i).messages(msgCtr).type = 224;
      midi.track(i).messages(msgCtr).data = [trM(n,8); trM(n,7)];    % LOOK AT COLUMN 7    % LSB, MSB
    end
    msgCtr = msgCtr + 1;
    
    prevtick = cumticks;
  end

  % end of track:
  midi.track(i).messages(msgCtr).deltatime = 0;
  midi.track(i).messages(msgCtr).type = 47;
  midi.track(i).messages(msgCtr).midimeta = 0;
  midi.track(i).messages(msgCtr).data = [];
  midi.track(i).messages(msgCtr).chan = [];
  msgCtr = msgCtr + 1;
  
end


% return a _column_ vector
% (copied from writemidi.m)
function A=encode_int(val,Nbytes)

A = zeros(Nbytes,1);  %ensure col vector (diff from writemidi.m...)
for i=1:Nbytes
  A(i) = bitand(bitshift(val, -8*(Nbytes-i)), 255);
end

