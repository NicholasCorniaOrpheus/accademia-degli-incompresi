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
    
    % --- CANTO ---
    \new Staff \with { 
      \include "../voice_options_score.ly" 
      \omit Stem.direction
      instrumentName = "Canto"
      shortInstrumentName = "C."
      midiInstrument = "choir aahs"
    } <<
      \new Voice = "canto" {  \include "./c_music_p.ly" }
    >>
    \new Lyrics \lyricsto "canto" { \include "./c_lyrics_p.ly" }
    
    % --- QUINTO ---
    \new Staff \with { 
      \include "../voice_options_score.ly" 
      \omit Stem.direction
      instrumentName = "Quinto"
      shortInstrumentName = "Q."
      midiInstrument = "choir aahs"
    } <<
      \new Voice = "quinto" {  \include "./q_music_p.ly" }
    >>
    \new Lyrics \lyricsto "quinto" { \include "./q_lyrics_p.ly" }
    
    % --- ALTO ---
    \new Staff \with { 
      \include "../voice_options_score.ly"
      \omit Stem.direction
      instrumentName = "Alto"
      shortInstrumentName = "A."
      midiInstrument = "choir aahs"
    } <<
      \new Voice = "alto" { \include "./a_music_p.ly" }
    >>
    \new Lyrics \lyricsto "alto" { \include "./a_lyrics_p.ly" }
    
    % --- TENORE ---
    \new Staff \with { 
      \include "../voice_options_score.ly" 
      \omit Stem.direction
      instrumentName = "Tenore"
      shortInstrumentName = "T."
      midiInstrument = "choir aahs"
    } <<
      \new Voice = "tenore" { \include "./t_music_p.ly" }
    >>
    \new Lyrics \lyricsto "tenore" { \include "./t_lyrics_p.ly" }

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
 
  >> 
 
  \midi {
    \tempo 2 = 60
  }
 
    \include "../layout_score.ly"

}

\include "./stanzas.ly"
