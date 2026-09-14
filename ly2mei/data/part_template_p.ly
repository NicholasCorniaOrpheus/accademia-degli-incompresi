%Performance Edition Part Template

% Variables

% Page

\include "./page.ly"
\pointAndClickOff
% Header

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


% Voice 

\score{
  <<
 \new Voice = "voice" \with {
    \consists "Ambitus_engraver" \consists "Bar_engraver"} <<
   %\override Staff.StaffSymbol.ledger-line-thickness = #'(1.0 . 1.0)
   \transpose c c{
    \autoBeamOff
    \voiceMusic
   }
   \set Staff.instrumentName = \voiceName
 >>
 \new Lyrics \lyricsto voice \voiceLyrics
 
  >>
  
  
  \midi{\tempo 2 = 60}
  
  % Layout

  \include "./layout_p.ly"
  
  
  
}



