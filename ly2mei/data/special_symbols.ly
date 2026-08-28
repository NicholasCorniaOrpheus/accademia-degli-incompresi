ficta = { \once \set suggestAccidentals = ##t }
sesquialtera = {s8-\tweak extra-offset #'(0 . -5.5) ^\markup{ \column{ \musicglyph #"three" \musicglyph #"two"} } s8 }
tripla = {s8-\tweak extra-offset #'(0 . -3.5)^\markup{\musicglyph #"three"} s8}
turnBlack = {
  \once \override NoteHead.style = #'blackpetrucci
  \once \override NoteHead.font-size = #2
}
hiddenTime = {\once \omit Staff.TimeSignature}
