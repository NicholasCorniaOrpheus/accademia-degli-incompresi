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
      instrumentName = "Canto"
      shortInstrumentName = "C."
      midiInstrument = "choir aahs"
    } <<
      \new Voice = "canto" { \clef "treble" \cadenzaOn \autoBeamOff \include "./c_music_d.ly" }
    >>
    \new Lyrics \lyricsto "canto" { \include "./c_lyrics_d.ly" }
    
    % --- CANTO ---
    \new Staff \with { 
      \include "../voice_options_score.ly" 
      instrumentName = "Quinto"
      shortInstrumentName = "Q."
      midiInstrument = "choir aahs"
    } <<
      \new Voice = "quinto" { \clef "treble" \cadenzaOn \autoBeamOff \include "./q_music_d.ly" }
    >>
    \new Lyrics \lyricsto "quinto" { \include "./q_lyrics_d.ly" }
    
    % --- ALTO ---
    \new Staff \with { 
      \include "../voice_options_score.ly" 
      instrumentName = "Alto"
      shortInstrumentName = "A."
      midiInstrument = "choir aahs"
    } <<
      \new Voice = "alto" {\clef "treble" \cadenzaOn \autoBeamOff \include "./a_music_d.ly" }
    >>
    \new Lyrics \lyricsto "alto" { \include "./a_lyrics_d.ly" }
    
    % --- TENORE ---
    \new Staff \with { 
      \include "../voice_options_score.ly" 
      instrumentName = "Tenore"
      shortInstrumentName = "T."
      midiInstrument = "choir aahs"
    } <<
      \new Voice = "tenore" {\clef "treble_8" \cadenzaOn \autoBeamOff \include "./t_music_d.ly" }
    >>
    \new Lyrics \lyricsto "tenore" { \include "./t_lyrics_d.ly" }

    % --- BASSO ---
    \new Staff \with { 
      \include "../voice_options_score.ly" 
      instrumentName = "Basso"
      shortInstrumentName = "B."
      midiInstrument = "choir aahs"
    } <<
      \new Voice = "basso" {\clef "bass" \cadenzaOn \autoBeamOff \include "./b_music_d.ly" }
    >>
    \new Lyrics \lyricsto "basso" { \include "./b_lyrics_d.ly" }
 
  >> 
 
  \midi {
    \tempo 2 = 60
  }
 
    \include "../layout_score.ly"

}

\include "./stanzas.ly"
