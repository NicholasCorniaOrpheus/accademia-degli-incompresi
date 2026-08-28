%WOIS - PartBooks Project Template

% Variables

% Page

\include "./page.ly"
\pointAndClickOff
% Header

\header{
 %title= \title
 %subtitle =\madrigal_book
 %opus=\year
 composer=\partname
 %composer =\composer
 %arranger =\publisher
 %piece=\collection
 %poet = \poet
 tagline = ##f
}


% Voice 

\score{
  <<
 \new MensuralVoice = "voice" <<
    \voiceMusic
   \set Staff.instrumentName = \voiceName
 >>
 \new Lyrics \lyricsto voice \voiceLyrics
 
  >>
  
  
  \midi{\tempo 2 = 60}
  
  % Layout

  \include "./layout.ly"
  
}



