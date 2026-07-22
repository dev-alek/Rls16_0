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
&glob defproc_pencrypt yes 
procedure pencrypt :
   &if "{1}" eq "defproc_log"
   &then
       define input parameter ip-value-to-enc as longchar no-undo.
       define output parameter op-char-value  as longchar no-undo.
   &else
       define input parameter ip-value-to-enc as character no-undo.
       define output parameter op-char-value  as character no-undo.
   &endif
  define variable crypto-value           as raw       no-undo.
  do
  on error undo, return error return-value
  :

   assign
      crypto-value  = encrypt(ip-value-to-enc)
      op-char-value = base64-encode(crypto-value)
   no-error.
   if error-status:error then op-char-value = ? .
   end.
end procedure. /* pencrypt */
&else
&if  defined(defproc_pencrypt) ne 0
&then

run pencrypt in this-procedure (input  {1} /* p-string   */
  ,output {2} /* p-encripted-string */
  ) {3} .
&else
  &scop proc-name pencrypt
{&run_proc_library2}
  (input  {1} /* p-string   */
  ,output {2} /* p-encripted-string */
  ) {3} .

&endif
&endif

/* $Workfile$ e n d */