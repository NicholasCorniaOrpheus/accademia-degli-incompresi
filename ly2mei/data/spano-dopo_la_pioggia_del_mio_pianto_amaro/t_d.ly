% Tenore Part

% portrait option
#(set-default-paper-size "a4" 'portrait)
% landscape option
%#(set-default-paper-size "a4" 'landscape)



\version "2.24"
\language "english"
% special symbols
\include "../special_symbols.ly"

\include "./metadata.ly"

partname = \markup{\fontsize #2 \bold "TENORE"}
voiceName = \markup{\fontsize #10 \bold "D"}
voiceMusic = \include "./t_music_d.ly"
voiceLyrics = \include "./t_lyrics_d.ly"
  
\include "../part_template_d.ly"


