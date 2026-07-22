block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-lined.p $
$Archive: gbl/rt-lined.p $

Радиотерминал. Зарегистрировать количество по строке документа

Автор: Хныкин Павел Андреевич
Дата создания: 27/02/07
Author: Pavel Khnykin
Creation date: 27/02/07

create: Перваков Михаил Сергеевич
Дата создания: 09/29/05

*/

define input  parameter p-unique-doc-code as character no-undo .
define input  parameter p-b-code          as integer   no-undo .
define input  parameter p-set-qnty        as decimal   no-undo .
define input  parameter p-last-date       as date      no-undo .
define input  parameter p-price-docf      as decimal   no-undo .
define input  parameter p-user-id         as character no-undo .
define input  parameter p-action          as character no-undo .
define output parameter p-status          as character no-undo .
define output parameter p-error-message   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-lined.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-lined.p $":U .
define variable vss-description as character no-undo init "Радиотерминал. Зарегистрировать количество по строке документа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }

define buffer buf_batchprocess for ub.batchprocess .

do
on error undo, return error return-value
:

  case p-action
  :
    when 'create-update':u
    then do:
      find first buf_batchprocess exclusive-lock
        where buf_batchprocess.bp_type     = {&btpr-type-rt-line}
          and buf_batchprocess.bp_status   = {&btpr-normal}
          and buf_batchprocess.charkey_one = p-unique-doc-code
          and buf_batchprocess.key#_one    = p-b-code
        no-error .
      if not available buf_batchprocess
      then do:
        create buf_batchprocess .

        define variable v-btpr_upd-today as date      no-undo .
        define variable v-btpr_upd-time  as integer   no-undo .
        run cur-time in this-procedure
          (output v-btpr_upd-today
          ,output v-btpr_upd-time
          ).
        assign
          buf_batchprocess.bp_type        = {&btpr-type-rt-line}
          buf_batchprocess.bp_status      = {&btpr-normal}
          buf_batchprocess.batchprocess#  = next-value(s-btpr, {&db-name_schema})
          buf_batchprocess.user_id        = p-user-id
          buf_batchprocess.bp_sysdate     = v-btpr_upd-today
          buf_batchprocess.bp_systime     = string( v-btpr_upd-time, 'hh:mm' )
          buf_batchprocess.bp_systimeint  = v-btpr_upd-time
          buf_batchprocess.charkey_one    = p-unique-doc-code
          buf_batchprocess.key#_one       = p-b-code
        .
      end.

      assign
        buf_batchprocess.bp_execsystime = string( p-set-qnty )
      .

      if p-last-date <> ?
      then do:
        assign
          buf_batchprocess.charkey_two    = string( p-last-date , "99/99/9999" )
        .
      end.

      if p-price-docf <> ?
      then do:
        assign
          buf_batchprocess.charkey_three  = string( p-price-docf )
        .
      end.

      assign
        p-status        = '0':u
        p-error-message = ''
      .

      return . /* --->>>--- */
    end.

    otherwise do:
      undo, return error substitute("Неизвестное значение параметра p-action &1", p-action)
        .
    end.
  end.
end.