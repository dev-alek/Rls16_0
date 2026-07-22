block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-doced.p $
$Archive: gbl/rt-doced.p $

Радиотерминал. Зарегистрировать номер документа

Автор: Хныкин Павел Андреевич
Дата создания: 27/02/07
Author: Pavel Khnykin
Creation date: 27/02/07

create: Перваков Михаил Сергеевич
Дата создания: 09/22/05

*/

define input  parameter p-unique-doc-code as character no-undo .
define input  parameter p-user-id         as character no-undo .
define input  parameter p-set-status      as character no-undo .
define input  parameter p-action          as character no-undo .
define input  parameter p-other           as character no-undo .
define output parameter p-status          as character no-undo .
define output parameter p-error-message   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-doced.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-doced.p $":U .
define variable vss-description as character no-undo init "Радиотерминал. Зарегистрировать номер документа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/library.i  }

define buffer buf_batchprocess for ub.batchprocess .

define variable v-user-nik      as character no-undo .


do
on error undo, return error return-value
:

  case p-action
  :
    when 'create':u
    then do:
      find first buf_batchprocess exclusive-lock
        where buf_batchprocess.bp_type     = {&btpr-type-rt-doc}
          and buf_batchprocess.bp_status   = {&btpr-normal}
          and buf_batchprocess.charkey_one = p-unique-doc-code
        no-error .
      if available buf_batchprocess
      then do:
        if buf_batchprocess.user_id <> p-user-id
        then do:
          { gbl/usrfulnm.i
            buf_batchprocess.user_id
            v-user-nik
            no-error
          }
          if error-status :error
          then do:
            assign
              v-user-nik = buf_batchprocess.user_id
            .
          end.
          assign
            p-status        = '3':u
            p-error-message = substitute('Документ &1 редактируется пользователем &2 с &3 в режием &4'
                                        ,p-unique-doc-code
                                        ,v-user-nik
                                        ,string(buf_batchprocess.bp_sysdate, '99/99/9999':u)
                                        ,(if buf_batchprocess.bp_execsystime = '1' then 'факт.количеств' else 'док.количеств')
                                        )
          .
          return. /* --->>>--- */
        end.

        assign
          p-status        = buf_batchprocess.bp_execsystime
          p-error-message = '':u
        .
        return. /* --->>>--- */
      end.

      create buf_batchprocess .

      define variable v-btpr_upd-today as date      no-undo .
      define variable v-btpr_upd-time  as integer   no-undo .
      run cur-time in this-procedure
        (output v-btpr_upd-today
        ,output v-btpr_upd-time
        ).
      assign
        buf_batchprocess.bp_type        = {&btpr-type-rt-doc}
        buf_batchprocess.bp_status      = {&btpr-normal}
        buf_batchprocess.batchprocess#  = next-value(s-btpr, {&db-name_schema})
        buf_batchprocess.user_id        = p-user-id
        buf_batchprocess.bp_sysdate     = v-btpr_upd-today
        buf_batchprocess.bp_systime     = string( v-btpr_upd-time, 'hh:mm' )
        buf_batchprocess.bp_systimeint  = v-btpr_upd-time
        buf_batchprocess.charkey_one    = p-unique-doc-code
        buf_batchprocess.bp_execsystime = p-set-status
        buf_batchprocess.charkey_two    = p-other
      .

      assign
        p-status        = p-set-status
        p-error-message = ''
      .

      return . /* --->>>--- */
    end.

    when 'check':u
    then do:
      find first buf_batchprocess exclusive-lock
        where buf_batchprocess.bp_type     = {&btpr-type-rt-doc}
          and buf_batchprocess.bp_status   = {&btpr-normal}
          and buf_batchprocess.charkey_one = p-unique-doc-code
        no-error .
      if not available buf_batchprocess
      then do:
        assign
          p-status        = '1':u
          p-error-message = substitute('Документ &1 не редактируется'
                                      ,p-unique-doc-code
                                      )
        .
        return. /* --->>>--- */
      end.
      if buf_batchprocess.user_id <> p-user-id
      then do:
        { gbl/usrfulnm.i
          buf_batchprocess.user_id
          v-user-nik
          no-error
        }
        if error-status :error
        then do:
          assign
            v-user-nik = buf_batchprocess.user_id
          .
        end.

        assign
          p-status        = '1':u
          p-error-message = substitute('Документ &1 редактируется пользователем &2 с &3'
                                      ,p-unique-doc-code
                                      ,v-user-nik
                                      ,string(buf_batchprocess.bp_sysdate, '99/99/9999':u)
                                      )
        .
        return. /* --->>>--- */
      end.

      assign
        p-status        = buf_batchprocess.bp_execsystime
        p-error-message = ''
      .
      return. /* --->>>--- */
    end.

    when 'delete':u
    then do:
      find first buf_batchprocess exclusive-lock
        where buf_batchprocess.bp_type     = {&btpr-type-rt-doc}
          and buf_batchprocess.bp_status   = {&btpr-normal}
          and buf_batchprocess.charkey_one = p-unique-doc-code
        no-error .
      if available buf_batchprocess
      then do:
        if buf_batchprocess.user_id <> p-user-id
        then do:
          { gbl/usrfulnm.i
            buf_batchprocess.user_id
            v-user-nik
            no-error
          }
          if error-status :error
          then do:
            assign
              v-user-nik = buf_batchprocess.user_id
            .
          end.

          assign
            p-status        = '1':u
            p-error-message = substitute('Документ &1 редактируется пользователем &2 с &3'
                                        ,p-unique-doc-code
                                        ,v-user-nik
                                        ,string(buf_batchprocess.bp_sysdate, '99/99/9999':u)
                                        )
          .
          return. /* --->>>--- */
        end.
      end.

      assign
        p-status        = '0':u
        p-error-message = ''
      .

      delete buf_batchprocess .
    end.

    otherwise do:
      undo, return error substitute("Неизвестное значение параметра p-action &1", p-action)
        .
    end.
  end.
end.