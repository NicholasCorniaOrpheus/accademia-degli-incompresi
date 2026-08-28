% WOIS - Partbooks Page Settings

#(set-global-staff-size 23)
%#(set-default-paper-size "a4" 'landscape)

\paper {
   top-system-spacing.basic-distance = #10
  system-system-spacing.basic-distance = #15
  last-bottom-spacing.basic-distance = #10
  %horizontal-shift = #7
  top-margin = 1.5 \cm
  bottom-margin = 1 \cm
  left-margin = 1.5 \cm
  right-margin = 1.5 \cm
  #(define fonts
    (make-pango-font-tree "Linux Libertine O"
                          "Nimbus Sans, Nimbus Sans L"
                          "DejaVu Sans Mono"
                          (/ staff-height pt 20)))
  
}