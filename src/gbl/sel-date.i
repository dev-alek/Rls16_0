/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура вызова календаря для подключения к кнопке выбора даты

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/16/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure sel-date :

  define input  parameter p-date-handle as handle    no-undo .
  define input  parameter p-description as character no-undo .

  do
  on error undo, return error return-value
  :
    if (can-query (p-date-handle, "sensitive")
      and
      p-date-handle :sensitive = true
      )
    or (can-query (p-date-handle, "read-only")
      and
      p-date-handle :read-only = false
      )
    then do:
      if p-date-handle :handle <> focus :handle
      then do:
        apply "entry":u to p-date-handle .
      end.

      define variable v-ok            as logical no-undo .
      define variable v-curr-sv-date as date no-undo .

      assign
        v-curr-sv-date = date(p-date-handle :screen-value) no-error
      .
      if v-curr-sv-date = ?
      then do:
        run gbl/getcurdt.p
          (output v-curr-sv-date
          ) .
      end.
      if v-curr-sv-date <> ?
      then do:
        run gbl/d-inpday.w
          (input ?                       /* h-callback    */
          ,input "Выбор даты"            /* p-title       */
          ,input p-description           /* p-description */
          ,input ""                      /* p-mode        */
          ,input-output v-curr-sv-date   /* p-date        */
          ,output v-ok                   /* p-ok          */
          ).
        if v-ok = true
        then do:
          assign
            p-date-handle :screen-value = string(v-curr-sv-date) .
          .
        end.
      end.
    end.
  end.

end procedure. /* sel-date */

/* $Workfile$ */