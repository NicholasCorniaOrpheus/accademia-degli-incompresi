%add ambitus to the part
\consists "Ambitus_engraver"
%automatic ties between bars
\remove "Note_heads_engraver"
\consists "Completion_heads_engraver"
\remove "Rest_engraver"
\consists "Completion_rest_engraver"