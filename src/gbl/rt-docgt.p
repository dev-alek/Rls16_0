block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-docgt.p $
$Archive: gbl/rt-docgt.p $

Радиотерминал. Получить атрибуты документа зарегистрированного с терминала .

Автор: Хныкин Павел Андреевич
Дата создания: 02/20/08
Author: Pavel Khnykin
Creation date: 02/20/08

*/
define input  parameter p-unique-doc-code as character no-undo .
define input  parameter p-user-id         as character no-undo .
define output parameter p-other           as character no-undo .
define output parameter p-error-message   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-docgt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-docgt.p $":U .
define variable vss-description as character no-undo init "Радиотерминал. Получить атрибуты документа зарегистрированного с терминала .".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define buffer buf_batchprocess for ub.batchprocess .

do
on error undo, return error return-value
:

  find first buf_batchprocess exclusive-lock
    where buf_batchprocess.bp_type     = {&btpr-type-rt-doc}
      and buf_batchprocess.bp_status   = {&btpr-normal}
      and buf_batchprocess.charkey_one = p-unique-doc-code
    no-error .
  if available buf_batchprocess
  then do:
    if buf_batchprocess.user_id <> p-user-id
    then do:
      assign
        p-error-message = substitute('Документ &1 редактируется пользователем &2 с &3 в режием &4'
                                    ,p-unique-doc-code
                                    ,buf_batchprocess.user_id
                                    ,string(buf_batchprocess.bp_sysdate, '99/99/9999':u)
                                    ,(if buf_batchprocess.bp_execsystime = '1' then 'факт.количеств' else 'док.количеств')
                                    )
      .
      return. /* --->>>--- */
    end.
    else do:
      assign
        p-other = buf_batchprocess.charkey_two
      .
      return . /* --->>>--- */
    end.
  end.
end.