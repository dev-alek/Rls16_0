block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: showtext.p $
$Archive: gbl/showtext.p $

Показать на экране текст сообщени

Автор: Перваков Михаил Сергеевич
Дата создания: 06/26/03
Author: Mikhail Pervakov
Creation date: 06/26/03

*/

define input  parameter p-title  as character no-undo .
define input  parameter p-width  as integer   no-undo .
define input  parameter p-height as integer   no-undo .
define input  parameter p-text   as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: showtext.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/showtext.p $":U .
define variable vss-description as character no-undo initial "Показать на экране текст сообщения".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

if p-width = 0
or p-width = ?
then do:
  assign
    p-width = 90
  .
end.

if p-height = 0
or p-height = ?
then do:
  assign
    p-height = 15
  .
end.

/* игнорируем все возможные ошибки */
do
on error undo, leave
on end-key undo, leave
on stop undo, leave
:
  /* показываем текст на экране */
  run gbl/d-prompt.w (
    input substitute('title=&1\':u, p-title)
          + 'type=editor\':u
          + substitute('fillin_width=&1\':u, p-width)
          + substitute('fillin_height=&1\':u, p-height)
          + 'readonly=yes\':u
    ,input-output p-text
    ).
end.