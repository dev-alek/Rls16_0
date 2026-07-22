/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if not available tb-thbj-attr then 
do:
   create tb-thbj-attr.
   assign 
      compare-log = no.
end.
else 
do:
   buffer-compare tb-thbj-attr TO wt-thbj-attr case-sensitive save result in compare-log no-error.
end.
if not compare-log then 
do:
   buffer-copy wt-thbj-attr TO tb-thbj-attr.
   run fill-setting in p-imp-handle ("thbj-attr",
                                     tb-thbj-attr.obj-type,
                                     tb-thbj-attr.obj-code,
                                     tb-thbj-attr.upper-prop-code,
                                     tb-thbj-attr.prop-code).                                     
end.

/* $Workfile$ e n d */