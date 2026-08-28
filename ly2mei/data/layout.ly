\layout {
  \context {
    \Score
    \omit BarNumber
    \override StaffGrouper.staff-staff-spacing.padding = #4
    \override StaffGrouper.staff-staff-spacing.basic-distance = #4
    \override StaffGrouper.staffgroup-staff-spacing.basic-distance = #4
\override StaffGrouper.staffgroup-staff-spacing.padding = #4
  \override SpacingSpanner.base-shortest-duration = #(ly:make-moment 1/4)

  }
  \context { 
    \MensuralVoice 
    \override Rest.style = #'neomensural 
    \override NoteHead.style =#'neomensural 
    \override NoteHead.font-size = #4
    \override Stem.font-size = #4
    \override Rest.font-size = #2 }
 

}