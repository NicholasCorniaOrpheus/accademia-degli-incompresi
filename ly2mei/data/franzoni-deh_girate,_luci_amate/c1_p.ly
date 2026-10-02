% Canto 1 Part

\version "2.24"
\language "english"
% special symbols
\include "../special_symbols.ly"

\include "./metadata.ly"

% page option
#(set-default-paper-size "a4" orientation)
#(set-global-staff-size page_size)

voiceName = \markup{\bold "Canto I"}
voiceMusic = \include "./c1_music_p.ly"
voiceLyrics = \include "./c1_lyrics_p.ly"
  
\include "../part_template_p.ly"

\include "stanzas.ly"
