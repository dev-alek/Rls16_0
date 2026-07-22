/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура чтения директории в диалоге ожидани

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/03/05
Author: Bakhtadze Natalya
Creation date: 03/03/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


PROCEDURE proc-read-dir :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-dir-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-fn-add-mask AS CHARACTER NO-UNDO.
DEFINE output PARAMETER p-elapsed-time AS INTEGER NO-UNDO.
DEFINE output PARAMETER p-appear AS logical NO-UNDO.
define variable v-start-time as int64   no-undo.
define variable file as character no-undo.
define variable path as character no-undo.
define variable atr  as character no-undo.
define variable v-ext-split as integer   no-undo .
define variable v-ext-split-mask as integer   no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext as character no-undo .
define variable v-mask-no-ext as character no-undo .
define variable v-mask-ext as character no-undo .

assign
v-start-time = etime.
input stream DirStream from os-dir (p-dir-name) .
REPEAT :
  import stream DirStream file path atr.
  /*todo*/
  /*надо написать функцию проверки по маске*/
  if can-do( "f", atr )  /* see "os-dir" help : f - Regular file or FIFO pipe */  then do:
    if file matches p-fn-add-mask then do:
      p-appear = yes.
      leave.
    end.
    assign
    v-ext-split = r-index(file, '.':u)
    v-ext-split-mask = r-index(p-fn-add-mask, '.':u)
    .
    if v-ext-split > 0 then do:
      assign
        v-file-name-no-ext = substring(file, 1, v-ext-split - 1)
        v-file-name-ext    = substring(file, v-ext-split + 1)
      .
    end.
    else do:
      assign
        v-file-name-no-ext = file
        v-file-name-ext    = ""
      .
    end.
    if v-ext-split-mask > 0 then do:
      assign
        v-mask-no-ext = substring(p-fn-add-mask, 1, v-ext-split-mask - 1)
        v-mask-ext    = substring(p-fn-add-mask, v-ext-split-mask + 1)
      .
    end.
    else do:
      assign
        v-mask-no-ext = p-fn-add-mask
        v-mask-ext    = ""
      .
    end.
    if v-file-name-no-ext matches v-mask-no-ext
    and v-file-name-ext matches v-mask-ext
    then do:
      p-appear = yes.
      leave.
    end.
  end.
END.
assign
p-elapsed-time = etime - v-start-time.
END PROCEDURE.


/* $Workfile$ e n d */