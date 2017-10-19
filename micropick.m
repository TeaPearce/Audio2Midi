% open a .wav file and calculates note start time and frequency in noteinfo
% then changes this info into midi notes that are saved as midi file
% programme deals in microtones
% Tim Pearce 2009
clear global; clear;

% standard values ---------------------------------------------------------
% -------------------------------------------------------------------------
Fs=44100;           % sample rate
T=1/Fs;             % sample time
wf='sine';          % synth voice - fm, sine, saw, tim - 
amp=0.3;            % amplitude mod
chunksize=8000;     % size of samples considered per FFT
stepsize=500;       % size of step - some overlap
namew='earth';    % name of .wav file
%namem='jesu.mid';   % name of midi file
tol=10;             % tolerance of individual note pick
cl=chunksize/Fs;    % chunklength (secs)


% open and read .wav file -------------------------------------------------
% -------------------------------------------------------------------------
y=wavread(namew);
% sound(y, Fs);           % plays sound
ns=size(y,1);           % number of samples


% spectrum of whole .wav --------------------------------------------------
%NFFT = 2^nextpow2(ns);              % next power of 2 from length of y
%Y=fft(y(:,1), NFFT)/ns;             % Fast Fourier Transform
%f = Fs/2*linspace(0,1,NFFT/2+1);    % calculate frequency

%subplot(1,1,1)
%plot (f, abs(Y(1:NFFT/2+1 ,1)));    % plot single sided spectrum of whole.wav
%axis([0 20000 0 0.1]);



% split into overlapping chunks of samples and find freq spectrum of each -
% -------------------------------------------------------------------------
% noteinfo = [ frequency(hz), magnitude, starttime(sec), stoptime(sec) ] --
% -------------------------------------------------------------------------
noteinfo = zeros(1,4);
for i = 1:stepsize:ns-chunksize

  % Fast Fourier Transform of chunk
  NFFT = 2^nextpow2(chunksize);            
  Y = fft(y(i:i+chunksize,1), NFFT)/(chunksize);           
  f = Fs/2*linspace(0,1,NFFT/2+1);
  freqmag(:,1) = f; freqmag(:,2) = abs(Y(1:NFFT/2+1));
  
  % work out start and finish time of chunk
  chunkstart = i/Fs;    chunkend = (i + chunksize)/Fs;
  stepend = (i + stepsize)/Fs;              % start of next chunk
  
 % if i==5001
 %   NFFT = 2^nextpow2(chunksize);              % next power of 2 from length of y
 %   Y=fft(y(i:i+chunksize,1), NFFT)/chunksize;             % Fast Fourier Transform
 %   f = Fs/2*linspace(0,1,NFFT/2+1);    % calculate frequency

 %   subplot(1,1,1)
  %  plot (f, abs(Y(1:NFFT/2+1 ,1)));    % plot single sided spectrum of whole.wav
 %   axis([0 20000 0 0.1]);
%  end
  

  if max(freqmag(:,2)>0.02) % only look for notes if there is a frequency spike
    [row, col] = find(freqmag(:,2)>0.02);  % limit of mag detection      %### requires fine tuning ###  0.007 for short? 0.02 for jesus
    limitfreqmag = freqmag(row, :);
     
    sfm = zeros(1,2);                      % ##make sure doesn't block any freq##
    for k=1:size(row,1)
      [row2, col2] = find(limitfreqmag(:,2)==max(limitfreqmag(:,2)));   % find max
      [row5, col5] = find(sfm(:,1)<limitfreqmag(row2,1)+(tol*5) &  sfm(:,1)>limitfreqmag(row2,1)-(tol*5));
      if isempty(row5)==0;                  % if sfm already has a similar freq
        limitfreqmag(row2,:) = [];          % delete
      else                                  % if its far away
        sfm = [sfm; limitfreqmag(row2,:)];  % save
        limitfreqmag(row2,:) = [];          % delete  
      end 
    end  
    sfm=[sfm(2:size(sfm,1),:)];             % ignore 1st row
    
    for p=1:size(sfm,1)                     % now check if all potential saves cropped up before
      [row3, col3] = find(noteinfo(:,1)<sfm(p,1)+tol & noteinfo(:,1)>sfm(p,1)-tol);
      if isempty(row3)==0                       % if had pitch before (so row3 is not empty)
          [row6,col6] = find( noteinfo(row3, 4) == max(noteinfo(row3, 4)) );    % find most recent note of that freq
          if noteinfo(row3(row6),4) < chunkstart        % if old pitch is finished -> new note          
            noteinfo = [noteinfo; sfm(p,:), chunkend-(chunksize/(2*Fs)), chunkend-(chunksize/(2*Fs))];  
          else                                    % if old pitch is not finished -> update
            noteinfo(row3(row6),4) = chunkend-(chunksize/(2*Fs));           % update end time
          end   
      else                                      % if completely new pitch -> new note
        noteinfo = [noteinfo; sfm(p,:), chunkend-(chunksize/(2*Fs)), chunkend-(chunksize/(2*Fs))];
      end
    end    
  end
end
noteinfo=[noteinfo(2:size(noteinfo,1),:)]  % ignore 1st row of zero's

% delete any notes with dur < 0.1 secs
%noteinfo(:,5) = noteinfo(:,4) - noteinfo(:,3);
[r,c] = find(noteinfo(:,4) - noteinfo(:,3) < 0.1);
noteinfo(r,:) = [];


% midi matrix -------------------------------------------------------------
% -------------------------------------------------------------------------
Mmini = freq2midi2([noteinfo(:,1)]); % calculate midi pitch and bend mag.
N = size(noteinfo,1);                % number of notes
M = zeros(N,6);
M(:,1) = 1;                          % all in track 1
M(:,2) = 1;                          % all in channel 1
M(:,3) = Mmini(:,1);                 % nearest whole midi note
M(:,4) = 90;                         % velocity   % ###this will be noteinfo(:,2)### with scaling fac (max vel is 127?)
M(:,5) = noteinfo(:,3);              % time note on (secs)
M(:,6) = noteinfo(:,4);              % time note off(secs)
M(:,7) = Mmini(:,2);        % extra column-how much bend note MSB 
M(:,8) = Mmini(:,3);        % extra column-how much bend note LSB


% save midi file  ---------------------------------------------------------
% -------------------------------------------------------------------------
midi_new = matrix2midi2(M);
writemidi(midi_new, '458.mid');   % save calculated midi
