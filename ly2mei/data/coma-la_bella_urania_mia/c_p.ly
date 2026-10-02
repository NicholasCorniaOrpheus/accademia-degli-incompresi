% Basso Part

% page option
#(set-default-paper-size "a4" orientation)
#(set-global-staff-size page_size)

\version "2.24"
\language "english"
% special symbols
\include "../special_symbols.ly"

\include "./metadata.ly"


voiceName = \markup{\bold "Basso"}
voiceMusic = \include "./b_music_p.ly"
voiceLyrics = \include "./b_lyrics_p.ly"
  
\include "../part_template_p.ly"




