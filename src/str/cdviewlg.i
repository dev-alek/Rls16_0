/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр log при не удавшейся отправке или приемке с кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/16/04
Author: Bakhtadze Natalya
Creation date: 02/16/04

{1} - строка, которая описывает журнал сообщений
{2} - имя файла журнала сообщений

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if v-view-log
and not g#news
and not g#auto
then do:
  message
  {1}  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
   &scop seq {&sequence}
  define variable v-user-action{&seq}   as character no-undo .
  define variable v-printed{&seq}       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ({1})
    ,input  0
    ,input  (string("./":U) + {2})
    ,input  7
    ,output v-user-action{&seq}
    ,output v-printed{&seq}
    ) .

end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
&if "{3}" <> "not-delete" &then
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + {2}).
end.
&endif

/* $Workfile$ e n d */