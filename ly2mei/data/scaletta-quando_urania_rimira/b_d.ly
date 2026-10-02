% Basso Part

\version "2.24"
\language "english"
% special symbols
\include "../special_symbols.ly"

\include "./metadata.ly"

% page option
#(set-default-paper-size "a4" orientation)
#(set-global-staff-size page_size)

partname = \markup{\fontsize #2 \bold "BASSO"}
voiceName = \markup{\fontsize #10 \bold \incipit}
voiceMusic = \include "./b_music_d.ly"
voiceLyrics = \include "./b_lyrics_d.ly"
  
\include "../part_template_d.ly"

\include "stanzas.ly"


