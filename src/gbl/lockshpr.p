block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lockshpr.p $
$Archive: gbl/lockshpr.p $

Программа разделяемой или монопольной блокировки ресурса

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Параметры:
p-process-key    уникальный код ресурса из 4 латинских букв
                 следует использовать препроцессинг с префиксом lock-prc

p-Key#_One       первичный ключ блокируемого ресурса
p-Key#_Two       (для каждого уникального может иметь свой состав)
p-Key#_Three
p-CharKey_One
p-CharKey_Two
p-CharKey_Three

p-lock-type      тип блокировки
                    'share-lock':u       - разделяемая блокировка
                    'exclusive-lock':u   - исключительная блокировка

lock_batchprocess - буфер, который будет хранить блокировку ресурса

*/

define input  parameter p-process-key    as character no-undo .
define input  parameter p-Key#_One       like ub.batchprocess.Key#_One      no-undo .
define input  parameter p-Key#_Two       like ub.batchprocess.Key#_Two      no-undo .
define input  parameter p-Key#_Three     like ub.batchprocess.Key#_Three    no-undo .
define input  parameter p-CharKey_One    like ub.batchprocess.CharKey_One   no-undo .
define input  parameter p-CharKey_Two    like ub.batchprocess.CharKey_Two   no-undo .
define input  parameter p-CharKey_Three  like ub.batchprocess.CharKey_Three no-undo .
define input  parameter p-lock-type      as character no-undo .
define parameter buffer lock_batchprocess for ub.batchprocess .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: lockshpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/lockshpr.p $":U .
define variable vss-description as character no-undo init "Программа блокировки ресурсов".
{ cmp/vssrevis.i "substitute('&1|&2':u,substitute('&1|&2|&3|&4|&5':u,p-process-key,p-Key#_One,p-Key#_Two,p-Key#_Three,p-CharKey_One),substitute('&1|&2|&3':u,p-CharKey_Two,p-CharKey_Three,p-lock-type))" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define buffer buf_batchprocess for ub.batchprocess .
define buffer delete_batchprocess for ub.batchprocess .

do
on error undo, return error return-value
:

  if length(p-process-key) > 4
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания параметров" skip
      "Ключ блокирования процесса не может превышать 4 символа" skip
      "p-process-key"   p-process-key   skip
      "p-Key#_One"      p-Key#_One      skip
      "p-Key#_Two"      p-Key#_Two      skip
      "p-Key#_Three"    p-Key#_Three    skip
      "p-CharKey_One"   p-CharKey_One   skip
      "p-CharKey_Two"   p-CharKey_Two   skip
      "p-CharKey_Three" p-CharKey_Three skip
      "p-lock-type"     p-lock-type     skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if  p-lock-type <> 'share-lock':u
  and p-lock-type <> 'exclusive-lock':u
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания параметров" skip
      "Неизвестный тип блокирования процесса" skip
      "p-process-key"   p-process-key   skip
      "p-Key#_One"      p-Key#_One      skip
      "p-Key#_Two"      p-Key#_Two      skip
      "p-Key#_Three"    p-Key#_Three    skip
      "p-CharKey_One"   p-CharKey_One   skip
      "p-CharKey_Two"   p-CharKey_Two   skip
      "p-CharKey_Three" p-CharKey_Three skip
      "p-lock-type"     p-lock-type     skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  def var v-bp_type like ub.batchprocess.bp_type no-undo .

  assign
    v-bp_type = {&btpr-type-lock} + p-process-key
  .

  find first ub.batchprocess no-lock
    where ub.batchprocess.bp_type       = v-bp_type
      and ub.batchprocess.bp_status     = {&btpr-normal}
      and ub.batchprocess.key#_one      = p-Key#_One
      and ub.batchprocess.key#_two      = p-Key#_Two
      and ub.batchprocess.key#_three    = p-Key#_Three
      and ub.batchprocess.charkey_one   = p-CharKey_One
      and ub.batchprocess.charkey_two   = p-CharKey_Two
      and ub.batchprocess.charkey_three = p-CharKey_Three
    no-error .
  if not available ub.batchprocess
  then do:
    create ub.batchprocess .

    define variable v-btpr_upd-today as date      no-undo.
    define variable v-btpr_upd-time  as integer   no-undo.
    run cur-time in this-procedure
      (output v-btpr_upd-today
      ,output v-btpr_upd-time
      ).
    assign
      ub.batchprocess.batchprocess# = next-value(s-btpr, {&db-name_schema})
      ub.batchprocess.bp_type       = v-bp_type
      ub.batchprocess.bp_status     = {&btpr-normal}
      ub.batchprocess.user_id       = g#userid
      ub.batchprocess.bp_sysdate    = v-btpr_upd-today
      ub.batchprocess.bp_systime    = string( v-btpr_upd-time, 'hh:mm':u )
      ub.batchprocess.bp_systimeint = v-btpr_upd-time
      ub.batchprocess.key#_one      = p-Key#_One
      ub.batchprocess.key#_two      = p-Key#_Two
      ub.batchprocess.key#_three    = p-Key#_Three
      ub.batchprocess.charkey_one   = p-CharKey_One
      ub.batchprocess.charkey_two   = p-CharKey_Two
      ub.batchprocess.charkey_three = p-CharKey_Three
    .
  end.

  validate ub.batchprocess .

  run lock-record in this-procedure
    (buffer ub.batchprocess
    ,buffer lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры lock-record" skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.

  if p-lock-type = 'exclusive-lock':u
  then do:
    define variable v-today as date      no-undo .
    define variable v-time  as integer   no-undo .
    run cur-time in this-procedure
      (output v-today
      ,output v-time
      ).
    assign
      lock_batchprocess.bp_execuser_id    = g#userid
      lock_batchprocess.bp_execsysdate    = v-today
      lock_batchprocess.bp_execsystime    = string(v-time, 'hh:mm':u)
      lock_batchprocess.bp_execsystimeint = v-time
    .
  end.

  /* обрабатываем случай одновременного блокирования ресурса */
  /* попытка одновременного блокирования приводит к конфликту */
  /* и процесс, который одновременно создал запись с большим номером */
  /* должен удалить ее и вернуть ошибку */
  define variable v-lock-success as logical   no-undo .

  assign
    v-lock-success = true
  .

  for each buf_batchprocess no-lock
    where buf_batchprocess.bp_type       = v-bp_type
      and buf_batchprocess.bp_status     = {&btpr-normal}
      and buf_batchprocess.Key#_One      = p-Key#_One
      and buf_batchprocess.Key#_Two      = p-Key#_Two
      and buf_batchprocess.Key#_Three    = p-Key#_Three
      and buf_batchprocess.CharKey_One   = p-CharKey_One
      and buf_batchprocess.CharKey_Two   = p-CharKey_Two
      and buf_batchprocess.CharKey_Three = p-CharKey_Three
      and recid(buf_batchprocess) <> recid(lock_batchprocess)
  on error undo, return error return-value
  :
    /* блокировка была неудачной */
    assign
      v-lock-success = false
    .

    define buffer buf_delete_batchprocess for ub.batchprocess .

    /* в случае, если найдена любая другая запись */
    /* пытаемся по возможности удалить ее */
    find first buf_delete_batchprocess exclusive-lock
      where recid(buf_delete_batchprocess) = recid(buf_batchprocess)
      no-wait
      no-error .
    if available (buf_delete_batchprocess)
    then do:
      delete buf_delete_batchprocess .
    end.
  end.

  /* если не получается пытаемся удалить свою собственную запись */
  /* и возвращаем ошибку */
  if v-lock-success <> true
  then do:
    find current ub.batchprocess exclusive-lock
      no-wait
      no-error .
    if available ub.batchprocess
    then do:
      delete ub.batchprocess .
    end.
    undo, return error substitute("Попытка одновременного захвата ресурса &1", v-bp_type) .
  end.

  return . /* --->>>--- */
end.

procedure lock-record :

  define parameter buffer other_batchprocess for ub.batchprocess .
  define parameter buffer buf_batchprocess for ub.batchprocess .

  def var v-resource-id as character no-undo .

  do
  on error undo, return error return-value
  :
    if p-lock-type = 'exclusive-lock':u
    then do:
      find first buf_batchprocess exclusive-lock
        where recid(buf_batchprocess) = recid(other_batchprocess)
/*        no-wait здесь необходимо ждать, пока ресурс освободится */
        no-error .
    end.
    else do:
      find first buf_batchprocess share-lock
        where recid(buf_batchprocess) = recid(other_batchprocess)
/*        no-wait здесь необходимо ждать, пока ресурс освободится */
        no-error .
    end.
    if not available buf_batchprocess
    then do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка при блокировании ресурса" skip
          "Отсутствует запись о блокировке ресурса" skip
          view-as alert-box error.

      undo, return error substitute("Другой пользователь захватил ресурс &1", v-resource-id) .
    end.
  end.

end procedure. /* lock-record */