\layout{
  \context {
    \Score
    measureBarType = #"!"
    \override StaffGrouper.staff-staff-spacing.padding = #5
    \override StaffGrouper.staff-staff-spacing.basic-distance = #5
    \override StaffGrouper.staffgroup-staff-spacing.basic-distance = #5
    \override StaffGrouper.staffgroup-staff-spacing.padding = #5
    \override SpacingSpanner.base-shortest-duration = #(ly:make-moment 1/4)
    %\remove "Line_break_engraver"
    
  }
  \context { \Voice \override NoteHead.style = #'baroque }
  \context {      \Dynamics
    \override VerticalAxisGroup.nonstaff-relatedstaff-spacing.basic-distance = #10
   }

  \context {      
    \Dynamics
    \override VerticalAxisGroup.nonstaff-relatedstaff-spacing.basic-distance = #10
    }
  
  
}
 
 

