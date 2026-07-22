block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/08/07
Author: Bakhtadze Natalya
Creation date: 01/08/07

*/

DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
define input parameter p-language as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ rul/tempstrn.i }
{ rul/fillrule.i }
{ rul/disprule.i }
{ rul/dispscrp.i }
{ rul/disprclp.i }
{ gbl/key-rec.i }
{ gbl/waitfram.i }


define variable v-level as integer no-undo .
define buffer buf_TEMP-STRING  for temp-string.
define variable v-cmdln as character no-undo .
define variable err-file as character no-undo .
define variable res as character no-undo .
define variable v-short-file-name as character no-undo .
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-cmd           as character                no-undo .
DEFINE VARIABLE v-file-name-dot           as character                no-undo .
DEFINE VARIABLE v-file-name-gif           as character                no-undo .
define variable v-file-name-html          as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .

define stream outstream .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  run temp-string_clear in this-procedure .
  run display-rule in this-procedure ( input p-rule-id
                                  , input 0 /*p-upper-rule-id*/
                                  , input substitute("DOT1-&1", p-language)
                                  , input-output v-level).

  run display-rule in this-procedure ( input p-rule-id
                                  , input 0 /*p-upper-rule-id*/
                                  , input substitute("DOT2-&1", p-language)
                                  , input-output v-level).

  output stream outstream to value( substitute( "&1.dot" ,string(p-rule-id, "999999999"))) convert target "UTF-8" .

  for each buf_temp-string
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
  put stream outstream unformatted buf_temp-string.v-string {&new-line}.

  end.
  output stream outstream close.
/*  return.*/
  run gbl/_tmpfile.p ( input ""
                      ,input  ""
                      ,output err-file) .

  assign
  v-short-file-name = string(p-rule-id, "999999999") + ".dot"
  .
  run gbl/filename.p (
                 input  v-short-file-name
                ,output v-file-name-dot
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
  if error-status:error then do:
    message
    return-value
    view-as alert-box ERROR.
    return.
  end.
  run rep/killspac.p ( input-output v-file-name-dot).
  assign
  v-file-name-gif = replace(v-file-name-dot, ".dot", ".gif")
  .
  assign
  v-short-file-name = "exe/graphviz/dot.exe".
  run gbl/filename.p (
                 input  v-short-file-name
                ,output v-file-name-cmd
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
  if error-status:error then do:
    message
    return-value
    view-as alert-box ERROR.
    return.
  end.
  /*run rep/killspac.p ( input-output v-file-name-cmd).*/
  /* формирование командной строки для запуска дополнительной сессии */
  assign
  err-file = err-file + ".err":u
  v-cmdln = substitute('"&1" -Tgif &2 -o &3 -Gcharset=UTF-8 > &4'
                       ,v-file-name-cmd
                       ,v-file-name-dot
                       ,v-file-name-gif
                       ,err-file
                       ).
  .
  /*
  run gbl/syn3.p
    (input v-cmdln
    ,input err-file
    ,input "Ждите! Идет форматирование файла..."
    ,output res
    ) no-error .
  */
  run gbl/syn.p
    (input v-cmdln
    ,input "":U
    ,input "Ждите! Идет форматирование файла..."
    ,output res
    ) no-error .

  run waitfram-hide in this-procedure .
  run gbl/filename.p (
                 input  v-file-name-gif
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
  if error-status:error then do:
    message
    return-value
    view-as alert-box ERROR.
    return.
  end.


  run rep/killspac.p ( input-output v-full-path).
  /*теперь сделаем html страницу*/
  v-file-name-html = replace(v-file-name-dot, ".dot", ".html").
  output stream Outstream to value(v-file-name-html).
  put stream Outstream unformatted
  substitute('<IMG SRC="&1.gif" ALT="ПРАВИЛО &2">', string(p-rule-id, "999999999"), p-rule-id)
  skip.
  output stream Outstream close.

  run gbl/open_url.p ( input  v-file-name-html) no-error .
  if search("grafdisp.dbg") = ? then do:
    os-delete value(v-file-name-dot).
    /*пыталась убивть чтобы не мусорить на диске - не работает так6*/
    /*
    os-delete value(v-file-name-gif).
    os-delete value(v-file-name-html).
    */
  end.
  os-delete value(err-file).
end.