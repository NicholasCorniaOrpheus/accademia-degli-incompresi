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

voiceName = \markup{\bold "Tenore"}
voiceMusic = \include "./t_music_p.ly"
voiceLyrics = \include "./t_lyrics_p.ly"
  
\include "../part_template_p.ly"


