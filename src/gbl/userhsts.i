/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для выбора фирмы или списка фирм

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 09/06/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&global-define include_userhsts ok

define temp-table userhsts_temp-user-host no-undo
  field host-code as integer

  index xpk is primary unique host-code
  .

procedure userhsts_clear :

  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .

  do
  on error undo, return error return-value
  :
    for each buf_userhsts_temp-user-host
    on error undo, return error return-value
    :
      delete buf_userhsts_temp-user-host .
    end.
  end.

end procedure. /* userhsts_clear */

procedure userhsts_object-count :

  define output parameter p-total-count as integer   no-undo .

  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .

  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .

    for each buf_userhsts_temp-user-host
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.

end procedure. /* userhsts_object-count */

procedure userhsts_append :

  define input  parameter p-host-code as integer   no-undo .

  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .

  do
  on error undo, return error return-value
  :
    find first buf_userhsts_temp-user-host
      where buf_userhsts_temp-user-host.host-code = p-host-code
      no-error .
    if not available buf_userhsts_temp-user-host
    then do:
      create buf_userhsts_temp-user-host .
      assign
        buf_userhsts_temp-user-host.host-code = p-host-code
      .
    end.
  end.

end procedure. /* userhsts_append */


procedure userhsts_object-exist :

  define output parameter p-object-exist as logical   no-undo .

  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .

  do
  on error undo, return error return-value
  :
    find first buf_userhsts_temp-user-host
      no-error .
    if not available buf_userhsts_temp-user-host
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.

end procedure. /* userhsts_object-exist */


procedure userhsts_transfer :

  define input  parameter p-callback-handle as handle no-undo .

  define variable vss-description as character no-undo init "userhsts_transfer: Передача списка объектов".

  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .

  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userhsts_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userhsts_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    for each buf_userhsts_temp-user-host
    on error undo, return error return-value
    :
      run userhsts_append in p-callback-handle
        (input  buf_userhsts_temp-user-host.host-code
        ) .
    end.
  end.

end procedure. /* userhsts_iterate */


procedure userhsts_select-one :

  define input  parameter parparentproc      as widget-handle no-undo .
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-user-id          as character no-undo .
  define input  parameter p-curr-host-code   as integer   no-undo .
  define output parameter p-user-select      as logical   no-undo .
  define output parameter p-select-host-code as character no-undo .
  /* Для совместимости - список выбранных host-code  */
  DEFINE VARIABLE v-List-select-host-code AS CHARACTER NO-UNDO INITIAL "".

  do
  on error undo, return error return-value
  :
    run gbl/userhsts.w
      (input  parparentproc          /* parparentproc      */
      ,input  this-procedure :handle /* p-callback-handle  */
      ,input  p-db-num               /* p-db-num           */
      ,input  p-user-id              /* p-user-id          */
      ,input  p-curr-host-code       /* p-curr-host-code   */
      ,input  "b-sel"                /* p-bttns            */
      ,output p-user-select          /* p-user-select      */
      ,output p-select-host-code     /* p-select-host-code */
      ,OUTPUT v-List-Select-host-code /* v-List-Select-host-code */
      ) .
  end.

end procedure. /* userhsts_select-one */

procedure userhsts_select-many :

  define input  parameter parparentproc      as widget-handle no-undo .
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-user-id          as character no-undo .
  define input  parameter p-curr-host-code   as integer   no-undo .
  define output parameter p-user-select      as logical   no-undo .

  define variable v-select-host-code as integer   no-undo .
  /* Для совместимости - список выбранных host-code  */
  DEFINE VARIABLE v-List-select-host-code AS CHARACTER NO-UNDO INITIAL "".

  do
  on error undo, return error return-value
  :
    run gbl/userhsts.w
      (input  parparentproc          /* parparentproc      */
      ,input  this-procedure :handle /* p-callback-handle  */
      ,input  p-db-num               /* p-db-num           */
      ,input  p-user-id              /* p-user-id          */
      ,input  p-curr-host-code       /* p-curr-host-code   */
      ,input  "b-sel,b-mark"         /* p-select-one       */
      ,output p-user-select          /* p-user-select      */
      ,output v-select-host-code     /* p-select-host-code */
      ,OUTPUT v-List-Select-host-code /* v-List-Select-host-code */
      ) .
  end.

end procedure. /* userhsts_select-many */




/* $Workfile$ e n d */