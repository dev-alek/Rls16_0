/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/15/07
Author: Bakhtadze Natalya
Creation date: 01/15/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(cr-prepc_i_def) = 0 &then

&glob cr-prepc_i_def

define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .

&endif

&IF "{1}" = "1" &THEN
  &scop gd-name {2}
  &scop gd-value {3}
  &scop prefix "{4}"
  &glob bef-{&gd-name} {&gd-value}
  run filwrlib_append-new-line in this-procedure ( input "&global-define bef-{&gd-name} {&bef-{&gd-name}}" ).
  &glob {&gd-name} '{&bef-{&gd-name}}'
  run filwrlib_append-new-line in this-procedure ( input "&global-define {&gd-name} '~{~&bef-{&gd-name}~}':U" ).
  do v-ii = 1 to num-entries("{&gd-value}"):
    run filwrlib_append-new-line in this-procedure ( input substitute("&&global-define bef-&1_&2 &2",  {&PREFIX}, entry(v-ii, "{&gd-value}"))).
    run filwrlib_append-new-line in this-procedure ( input substitute("&&global-define &1_&2 '~{~&&bef-&1_&2~}':U", {&PREFIX}, entry(v-ii, "{&gd-value}"))).
 end.
&ENDIF

&IF "{1}" = "2" &THEN
  &scop gd-name {2}
  &scop gd-value {3}
  &scop prefix "{4}"
  &scop gd-value2 {5}
  &glob bef-{&gd-name} {&gd-value}
  &scop semicolon-char chr(59)
  run filwrlib_append-new-line in this-procedure ( input "&global-define bef-{&gd-name} {&bef-{&gd-name}}" ).
  &glob {&gd-name} '{&bef-{&gd-name}}'
  run filwrlib_append-new-line in this-procedure ( input "&global-define {&gd-name} '~{~&bef-{&gd-name}~}':U" ).
  do v-ii = 1 to num-entries("{&gd-value}"):
    run filwrlib_append-new-line in this-procedure ( input substitute("&&global-define bef-&1_&2 &2",  {&PREFIX}, entry(v-ii, "{&gd-value}"))).
    run filwrlib_append-new-line in this-procedure ( input substitute("&&global-define &1_&2 '~{~&&bef-&1_&2~}':U", {&PREFIX}, entry(v-ii, "{&gd-value}"))).
    run filwrlib_append-new-line in this-procedure ( input substitute("&&global-define bef-{2}_&1 &2", entry(v-ii, "{&gd-value}"), entry(v-ii, "{&gd-value2}", {&semicolon-char}) )).
    run filwrlib_append-new-line in this-procedure ( input substitute("&&global-define {2}_&1 '&2':U", entry(v-ii, "{&gd-value}"), entry(v-ii, "{&gd-value2}", {&semicolon-char}) )).
    do v-jj = 1 to num-entries(entry(v-ii, "{&gd-value2}", {&semicolon-char})):
      run filwrlib_append-new-line in this-procedure ( input substitute("&&global-define bef-&1_&2_&3 &3",  {&PREFIX}, entry(v-ii, "{&gd-value}"), entry(v-jj, entry(v-ii, "{&gd-value2}", {&semicolon-char})) )).
      run filwrlib_append-new-line in this-procedure ( input substitute("&&global-define &1_&2_&3 '~{~&&bef-&1_&2_&3~}':U", {&PREFIX}, entry(v-ii, "{&gd-value}"), entry(v-jj, entry(v-ii, "{&gd-value2}", {&semicolon-char}) ))).
    end.
 end.
&ENDIF


/* $Workfile$ e n d */