% Canto Part

\version "2.24"
\language "english"
% special symbols
\include "../special_symbols.ly"

\include "./metadata.ly"

% page option
#(set-default-paper-size "a4" orientation)
#(set-global-staff-size page_size)

voiceName = \markup{\bold "Canto"}
voiceMusic = \include "./c_music_p.ly"
voiceLyrics = \include "./c_lyrics_p.ly"
  
\include "../part_template_p.ly"


