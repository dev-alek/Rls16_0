/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица для передачи параметров

Автор: Перваков Михаил Сергеевич
Дата создания: 07/18/02
Author: Mikhail Pervakov
Creation date: 07/18/02

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop def-temp-param define temp-table temp-param no-undo ~
  field param-code     as character ~
  field param-sub-code as character ~
  field param-value    as character ~
  index xpk is primary unique param-code param-sub-code ~
  .

{&def-temp-param}

&global-define paramls-saveas "saveas":U
&global-define paramls-excel-file-name "excel-file-name":U
&global-define paramls-saveas-read-password "read-password":U
&global-define paramls-saveas-write-password "write-password":U
&global-define paramls-charcol "charcol":U
&global-define paramls-option "option":U
&global-define paramls-option-visible "visible":U
&global-define paramls-file "file":U
&global-define paramls-file-no-open "file-no-open":U
&global-define paramls-file-out-list "file-out-list":U
&global-define paramls-command "command":U
&global-define paramls-template "template":U
&global-define paramls-template-file-name "template-file-name":U
&global-define paramls-vb-file-name "vb-file-name":U
&global-define paramls-data "data":U
&global-define paramls-data-header-filename "data-header-filename":U
&global-define paramls-data-filename "data-filename":U


procedure paramls-clear :

  define buffer buf_temp-param for temp-param .

  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.

end procedure. /* paramls-clear */


procedure paramls-write :

  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .

  define buffer buf_temp-param for temp-param .

  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.

end procedure. /* paramls-write */


procedure paramls-read :

  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .

  define buffer buf_temp-param for temp-param .

  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.

end procedure. /* paramls-read */

procedure paramls-append :

  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .

  define buffer buf_temp-param for temp-param .

  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.

end procedure. /* paramls-write */

/* $Workfile$ e n d */