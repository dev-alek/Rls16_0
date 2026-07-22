block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-req13.p $
$Archive: gbl/rt-req13.p $

Обработка запроса радиотерминала 13. Завершить сессию

Автор: Хныкин Павел Андреевич
Дата создания: 27/02/07
Author: Pavel Khnykin
Creation date: 27/02/07

create: Перваков Михаил Сергеевич
Дата создания: 09/09/05

*/

define input  parameter p-directory-out  as character no-undo .
define input  parameter p-file-name      as character no-undo .
define input  parameter p-session-valid  as logical   no-undo .
define input  parameter p-error-message  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req13.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req13.p $":U .
define variable vss-description as character no-undo init "Обработка запроса радиотерминала 13. Завершить сессию".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/rtencode.i }

define stream sout .

do
on error undo, return error return-value
:
  define variable v-temp-file-name as character no-undo .

  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .

  if p-session-valid = true
  then do:
    /* сессия успешно завершена */
    put stream sout unformatted 'status:0' + {&new-line} .
    put stream sout unformatted 'message:' + {&new-line} .
  end.
  else do:
    /* ошибка завершения сессии */
    put stream sout unformatted 'status:1' + {&new-line} .
    put stream sout unformatted substitute('message:&1', rtencode(p-error-message)) + {&new-line} .
  end.
  output stream sout close .

  os-delete value(p-directory-out + '/':u + p-file-name) .
  os-rename value(p-directory-out + '/':u + v-temp-file-name)
            value(p-directory-out + '/':u + p-file-name)
            .
end.