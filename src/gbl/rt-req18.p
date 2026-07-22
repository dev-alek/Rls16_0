block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-req18.p $
$Archive: gbl/rt-req18.p $

Обрабока запроса радиотерминала 18. Инвентаризация. Настройка

Автор: Хныкин Павел Андреевич
Дата создания: 27/02/07
Author: Pavel Khnykin
Creation date: 27/02/07

create: Перваков Михаил Сергеевич
Дата создания: 10/19/05

*/

define input  parameter p-directory-out  as character no-undo .
define input  parameter p-file-name      as character no-undo .
define input  parameter p-obj-type       as character no-undo .
define input  parameter p-obj-code       as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req18.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req18.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 18. Инвентаризация. Настройка".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/integerm.i }
{ cmp/library.i  }
{ gbl/rtencode.i }

define stream sout .

define variable v-data-valid    as logical   no-undo .
define variable v-error-message as character no-undo .

do
on error undo, return error return-value
:
  run check-data in this-procedure
    (output  v-data-valid
    ,output  v-error-message
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute("ошибка при вызове функции check-data. &1, &2"
                                ,error-status :get-message(1)
                                ,return-value
                                ) .
  end.

  define variable v-temp-file-name as character no-undo .

  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .

  if v-data-valid = true
  then do:
    /* пароль правильный */
    put stream sout unformatted 'status:0' + {&new-line} .
    put stream sout unformatted 'message:' + {&new-line} .
  end.
  else do:
    /* пароль неправильный */
    put stream sout unformatted 'status:1' + {&new-line} .
    put stream sout unformatted substitute('message:&1', rtencode(v-error-message)) + {&new-line} .
  end.
  output stream sout close .

  os-delete value(p-directory-out + '/':u + p-file-name) .
  os-rename value(p-directory-out + '/':u + v-temp-file-name)
            value(p-directory-out + '/':u + p-file-name)
            .
end.

procedure check-data :

  define output parameter p-data-valid    as logical   no-undo .
  define output parameter p-error-message as character no-undo .

  define buffer buf_clients  for ub.clients .
  define buffer buf_sysconf  for ub.sysconf .

  do
  on error undo, return error return-value
  :
    define variable v-obj-code      as integer   no-undo .
    define variable v-data-valid    as logical   no-undo .
    define variable v-error-message as character no-undo .

    if p-obj-code = ""
    then do:
      assign
        p-data-valid    = false
        p-error-message = "Не задан код объекта"
      .
      return . /* --->>>--- */
    end.

    run integerm in this-procedure
      (input  p-obj-code      /* p-string      */
      ,input  false           /* p-allow-sign  */
      ,input  false           /* p-allow-comma */
      ,output v-obj-code      /* p-value       */
      ,output v-data-valid    /* p-data-valid  */
      ,output v-error-message /* p-message     */
      ) .

    if v-data-valid <> true
    then do:
      assign
        p-data-valid    = false
        p-error-message = substitute("Ошибка преобразования кода объекта &1. &2"
                                    ,p-obj-code
                                    ,v-error-message
                                    )
      .
      return . /* --->>>--- */
    end.

    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if not available buf_clients
    then do:
      assign
        p-data-valid    = false
        p-error-message = substitute("Не найден объект &1 &2"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    if  p-obj-type <> {&shop}
    and p-obj-type <> {&stock}
    then do:
      assign
        p-data-valid    = false
        p-error-message = substitute("Неправильный тип объекта &1 &2"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    assign
      p-data-valid    = true
      p-error-message = ""
    .
  end.


end procedure. /* check-data */