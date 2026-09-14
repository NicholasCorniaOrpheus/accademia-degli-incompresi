% Canto 1 Part

% portrait option
#(set-default-paper-size "a4" 'portrait)
% landscape option
%#(set-default-paper-size "a4" 'landscape)



\version "2.24"
\language "english"
% special symbols
\include "../special_symbols.ly"

\include "./metadata.ly"


voiceName = \markup{\bold "Canto I"}
voiceMusic = \include "./c1_music_p.ly"
voiceLyrics = \include "./c1_lyrics_p.ly"
  
\include "../part_template_p.ly"

\include "stanzas.ly"
