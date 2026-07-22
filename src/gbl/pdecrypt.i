/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Белоусов Илья Александрович
Дата создания: 05/16/07
Author: Ilia Belousov
Creation date: 05/16/07

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&if    "{1}" eq "defproc"
    or "{1}" eq "defproc_long" 
&then
&glob defproc_pdecrypt yes 

procedure pdecrypt :
  &if "{1}" eq "defproc_log"
  &then
     define input  parameter ip-value-to-dec as longchar no-undo.
     define output parameter op-char-value   as longchar no-undo.
  &else
     define input  parameter ip-value-to-dec as character no-undo. 
     define output parameter op-char-value   as character no-undo.
  &endif
  
  
  define variable decrypt-value          as raw       no-undo.
  define variable long-char-value        as longchar  no-undo.
  do
  on error undo, return error return-value
  :

   assign
      long-char-value = ip-value-to-dec
      op-char-value   = get-string(decrypt(base64-decode(long-char-value)),1)
      long-char-value = ""
   no-error.
   if error-status:error then op-char-value = ? .
   end.
end procedure. /* pdecrypt */
&else
&if defined( defproc_pdecrypt) ne 0
&then

run pdecrypt in this-procedure (input  {1} /* p-string   */
  ,output {2} /* p-encripted-string */
  ) {3} .
&else
&scop proc-name pdecrypt
{&run_proc_library2}
  (input  {1} /* p-cripted-string   */
  ,output {2} /* p-decripted-string */
  ) {3} .
&ENDIF
&endif
/* $Workfile$ e n d */

