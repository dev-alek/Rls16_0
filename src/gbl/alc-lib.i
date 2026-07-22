/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами алкогольной продукции (акцизная марка и т.д.)

Автор: Хныкин Павел Андреевич
Дата создания: 07/09/07
Author: Pavel Khnykin
Creation date: 07/09/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure alc-lib_mark-name :

  define input  parameter p-mark-db-num   as integer   no-undo .
  define input  parameter p-mark-code     as integer   no-undo .
  define output parameter p-mark-name     as character no-undo .

  define buffer buf_ex-mark for ub.ex-mark .

  do
  on error undo, return error return-value
  :
    if p-mark-db-num = ?
    or p-mark-code   = ?
    then do:
      assign
        p-mark-name = '?':u
      .
      return . /* --->>>--- */
    end.

    if  p-mark-db-num = 0
    and p-mark-code   = 0
    then do:
      assign
        p-mark-name = ""
      .
      return . /* --->>>--- */
    end.

    find first buf_ex-mark no-lock
      where buf_ex-mark.db-num    = p-mark-db-num
        and buf_ex-mark.mark-code = p-mark-code
      no-error .
    if available buf_ex-mark
    then do:
      assign
        p-mark-name = substitute('&1':u
                                ,buf_ex-mark.mark-name
                                )
      .
    end.
  end.

end procedure. /* alc-lib_mark-name */

/* Создает уникальный цифровой код для партии */
procedure alc-lib_get-new-part-code :

  define input  parameter p-obj-type       as character no-undo .
  define input  parameter p-obj-code       as integer   no-undo .
  define input  parameter p-prod-type      as character no-undo .
  define input  parameter p-prod-code      as integer   no-undo .
  define input  parameter p-artic          as character no-undo .
  define input  parameter p-doc-code       as character no-undo .
  define output parameter p-new-part-code  as character no-undo .

  define variable v-cur-part-code as integer no-undo.
  define variable v-max-part-code as integer no-undo.
  define variable i               as integer no-undo.

  define buffer bf_parts for ub.parts .

  do
  on error undo, return error return-value
  :
    assign
      v-max-part-code = 0
    .
    for each bf_parts no-lock
          where bf_parts.obj-type  = p-obj-type  and
                bf_parts.obj-code  = p-obj-code  and
                bf_parts.prod-type = p-prod-type and
                bf_parts.prod-code = p-prod-code and
                bf_parts.artic     = p-artic     and
                bf_parts.out-code  = p-doc-code
      :
      assign
        v-cur-part-code = integer(bf_parts.part-code)
        no-error.
      if error-status:error = no and v-cur-part-code > v-max-part-code then do:
        assign
          v-max-part-code = v-cur-part-code
        .
      end.
    end.

    assign
      p-new-part-code = string (v-max-part-code + 1)
    .
  end.

end procedure. /* alc-lib_get-new-part-code */

/* $Workfile$ e n d */