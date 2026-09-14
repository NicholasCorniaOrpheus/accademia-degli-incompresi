\version "2.24"
\language "english"
ficta = { \once \set suggestAccidentals = ##t }

\include "../page_score.ly"

\include "./metadata.ly"

\header{
 title= \title
 subtitle =\madrigal_book
 opus=\year
 composer =\composer
 arranger =\publisher
 piece=\collection
 poet = \poet
 tagline ="Nicholas Cornia, 2026"
}

% special symbols
\include "../special_symbols.ly"


\score {
  \new StaffGroup << 
    
    % --- CANTO I ---
    \new Staff \with { 
      \include "../voice_options_score.ly" 
      \omit Stem.direction
      instrumentName = "Canto I"
      shortInstrumentName = "C.I"
      midiInstrument = "choir aahs"
    } <<
      \new Voice = "canto_primo" {  \include "./c1_music_p.ly" }
    >>
    \new Lyrics \lyricsto "canto_primo" { \include "./c1_lyrics_p.ly" }
    
    % --- CANTO II ---
    \new Staff \with { 
      \include "../voice_options_score.ly" 
      \omit Stem.direction
      instrumentName = "Canto II"
      shortInstrumentName = "C.II"
      midiInstrument = "choir aahs"
    } <<
      \new Voice = "canto_secondo" {  \include "./c2_music_p.ly" }
    >>
    \new Lyrics \lyricsto "canto_secondo" { \include "./c2_lyrics_p.ly" }
    
    % --- BASSO ---
    \new Staff \with { 
      \include "../voice_options_score.ly" 
      \omit Stem.direction
      instrumentName = "Basso"
      shortInstrumentName = "B."
      midiInstrument = "choir aahs"
    } <<
      \new Voice = "basso" { \include "./b_music_p.ly" }
    >>
    \new Lyrics \lyricsto "basso" { \include "./b_lyrics_p.ly" }
 
 % --- BASSO CONTINUO ---
    \new Staff \with { 
      %\include "../voice_options_score.ly" 
      \omit Stem.direction
      instrumentName = "Continuo"
      shortInstrumentName = "Bc."
      midiInstrument = "choir aahs"
    } <<
      \new Voice = "basso_continuo" { \include "./bc_music_p.ly" }
    >>
    \new Lyrics \lyricsto "basso_continuo" { \include "./bc_lyrics_p.ly" }
 
 
  >>
  
  
  \midi {
    \tempo 2 = 60
  }
 
    \include "../layout_score.ly"

}

\include "./stanzas.ly"
