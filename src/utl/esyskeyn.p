block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: esyskeyn.p $
$Archive: utl/esyskeyn.p $

Рыба утилиты переименования типа ВС в значениях параметра вызова машины правил

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/13/10
Author: Bakhtadze Natalya
Creation date: 05/13/10

для вставления в u p d a t e . p

*/

define input parameter p-profile-id-list as character no-undo .
define input parameter p-new-esys-type as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: esyskeyn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/esyskeyn.p $":U .
define variable vss-description as character no-undo init "Рыба утилиты переименования типа ВС в значениях машины правил".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }


define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_ext-system for ub.ext-system.

main-block:
for each buf_rule-call-param no-lock
where lookup(string(buf_rule-call-param.profile_id), p-profile-id-list) > 0
on error  undo main-block, retry main-block
on stop   undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    message
    substitute("Ошибка при выполнении переименования типа ВС в значениях параметра вызова машины правил:&1&2&1" +
               "Список профайлов для переименования параметров - &3&1" +
               "Новое значение типа ВС - &4&1"
               , {&new-line}
               , error-status:get-message(1)
               , p-profile-id-list
               , p-new-esys-type
               )
    view-as alert-box error .
    return error.
  end.
  if buf_rule-call-param.param-2-data-type begins {&table_ext-system}
  and buf_rule-call-param.param-value-integer <> 0
  then do:
    find first buf_ext-system share-lock where
            buf_ext-system.esys-id = buf_rule-call-param.param-value-integer
        and buf_ext-system.db-num = 0 no-error.

    if available buf_ext-system
    and buf_ext-system.esys-type = integer({&openxml-type-special}) then do:
      assign
      buf_ext-system.esys-type = p-new-esys-type
      .
    end.
  end.
end.