/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

"Обрезание" БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/29/01
Author: Dmitry Ukhanov
Creation date: 11/29/01

*/

define stream LogStream .

define variable ttd        as character no-undo .
define variable v-old-time as int64     no-undo .

PROCEDURE write-to-log :

  define input parameter p-msg-str   as character no-undo .
  define input parameter p-call-back as handle    no-undo .

  do
  on error undo, return error
  :
    &if defined(filename) &then
    output stream LogStream to "{&filename}" page-size 0 append.
    &else
    output stream LogStream to "cut-load.log" page-size 0 append.
    &endif
    put stream LogStream unformatted p-msg-str .
    output stream LogStream close.

    if  valid-handle(p-call-back)
    and lookup('callback-write-to-log', p-call-back :internal-entries) > 0
/*    and p-call-back <> this-procedure :handle*/
    then do:
      run callback-write-to-log in p-call-back
        (input p-msg-str
        ) no-error .
    end.
  end.

END PROCEDURE.


FUNCTION format-etime RETURNS CHARACTER
(INPUT p-etime AS INT64  )
:
  if p-etime = ?
  then do:
    return "?????????????" .
  end.
  assign
    p-etime = p-etime / 1000
  .
  return
    string( p-etime, '->>>>>>>9')
    + ' '
    + string( p-etime, 'HH:MM:SS')
  .

END FUNCTION.

/* $Workfile$ e n d  */