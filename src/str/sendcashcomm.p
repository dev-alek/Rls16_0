/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отсылка данных по справочнику ОСС

Автор: Морозов Александр Сергеевич
Дата создания: 02/14/14
Author: Alexandr Morozov
Creation date: 02/14/14

Input:

Output:

*/
block-level on error undo, throw.

define input parameter parparentproc   as widget-handle no-undo .
define input parameter p-parent-handle as widget-handle no-undo .
define input parameter p-log-handle    as handle no-undo .
define input parameter p-parameter     as character no-undo .
define input parameter iCommandType    as character no-undo.
define input parameter iCommandValue   as character no-undo.
define input parameter iRECLIST        as character no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отсылка данных команды ".
{ cmp/vssrevis.i }
&glob xml-cd-doc-name 'control'
{str/sendtocash.i def }

assign
mPostType      = {&cd-type-IBM-XML}
mTitle         = "Передача сигнала "
mTitle-add     = "Передача 'сигнала резервнго копирования базы чеков и очистки базы чеков' "
mTitle-del     = "Передача 'сигнала резервнго копирования базы чеков и очистки базы чеков' "
mObj-type      =         entry(1, p-parameter, {&delim-par})
mObj-code      = integer(entry(2, p-parameter, {&delim-par}))
action         =         entry(3, p-parameter, {&delim-par})
mListrec       = iRECLIST
no-error
.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         )).
  v-view-log = yes.
  undo, return error .
end .
{str/sendtocash.i }

procedure putc-obj :
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-version like ub.cash-desk.version no-undo .
define input parameter p-cash-os like ub.cash-desk.cash-os no-undo .
define input parameter p-cash-num like ub.cash-desk.cash-num  no-undo .
define input parameter p-is-del as logical no-undo .

define buffer buf_ext-classif for ub.ext-classif.

define variable ii as integer no-undo.

  do
  on error undo, return error
  :
    run bgelib-tag-open in this-procedure  ( input 2, input "Command", input substitute("ctrl='&1'", "ADD":u)).
    run bgelib-tag-put in this-procedure   ( input 3, input "CommType":U,  iCommandType , input 1 ).
    run bgelib-tag-put in this-procedure   ( input 3, input "CommValue":U, iCommandValue, input 1 ).
    run bgelib-tag-close in this-procedure ( input 2, input "Command").

  end.

end procedure.
