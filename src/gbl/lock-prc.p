block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lock-prc.p $
$Archive: gbl/lock-prc.p $

Программа исключительной блокировки ресурсов

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

p-key-descr-list список из 7 элементов
                 первые 6 элементов используются для описания ключевых полей
                 если элемент списка отличен от нуля, то в сообщении
                 появится описание поля ключа вместе с его значением

                 последний элемент задает название ресурса на языке,
                 понятном пользователю

p-message-on     выводить сообщение на экран

lock_batchprocess - буфер, который будет хранить блокировку ресурса

*/

define input parameter  p-process-key    as character no-undo .
define input parameter  p-Key#_One       like ub.batchprocess.Key#_One      no-undo .
define input parameter  p-Key#_Two       like ub.batchprocess.Key#_Two      no-undo .
define input parameter  p-Key#_Three     like ub.batchprocess.Key#_Three    no-undo .
define input parameter  p-CharKey_One    like ub.batchprocess.CharKey_One   no-undo .
define input parameter  p-CharKey_Two    like ub.batchprocess.CharKey_Two   no-undo .
define input parameter  p-CharKey_Three  like ub.batchprocess.CharKey_Three no-undo .
define input parameter  p-key-descr-list as character no-undo .
define input parameter  p-message-on     as logical no-undo .
define parameter buffer lock_batchprocess for ub.batchprocess .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: lock-prc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/lock-prc.p $":U .
define variable vss-description as character no-undo init "Программа блокировки ресурсов".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9':u,p-process-key,p-Key#_One,p-Key#_Two,p-Key#_Three,p-CharKey_One,p-CharKey_Two,p-CharKey_Three,p-key-descr-list,p-message-on)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define buffer buf_batchprocess for ub.batchprocess .
define buffer delete_batchprocess for ub.batchprocess .

do
on error undo, return error return-value
:
  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .

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
      "p-message-on"    p-message-on    skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if g#auto = true then do:
    assign
      p-message-on = false
    .
  end.

  def var v-bp_type like ub.batchprocess.bp_type no-undo .

  assign
    v-bp_type = {&btpr-type-lock} + p-process-key
  .

  { trg/btpr_upd.i
    &btpr-status="create"
    &btpr-type=v-bp_type
    &Key#_One=p-Key#_One
    &Key#_Two=p-Key#_Two
    &Key#_Three=p-Key#_Three
    &CharKey_One=p-CharKey_One
    &CharKey_Two=p-CharKey_Two
    &CharKey_Three=p-CharKey_Three
  }

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

  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).

  assign
    lock_batchprocess.bp_execuser_id    = g#userid
    lock_batchprocess.bp_execsysdate    = v-today
    lock_batchprocess.bp_execsystime    = string(v-time, 'hh:mm')
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
    run lock-record in this-procedure
      (buffer buf_batchprocess
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

      delete ub.batchprocess .
      undo, return error return-value .
    end.
  end.

  find current lock_batchprocess share-lock .

  return . /* --->>>--- */
end.

procedure lock-record :
  define parameter buffer other_batchprocess for ub.batchprocess .
  define parameter buffer buf_batchprocess for ub.batchprocess .

  def var v-resource-id as character no-undo .

  do
  on error undo, return error return-value
  :
    find buf_batchprocess exclusive-lock
      where recid(buf_batchprocess) = recid(other_batchprocess)
      no-wait
      no-error .
    if not available buf_batchprocess
    then do:
      if locked buf_batchprocess
      then do:
        define variable v-message as character no-undo .

        assign
          p-key-descr-list = p-key-descr-list + ",,,,,,":u
        .
        assign
          v-resource-id = "Код ресурса " + string(p-process-key) + {&new-line}
                        + (if entry(7, p-key-descr-list) > ""
                          then entry(7, p-key-descr-list) + {&new-line}
                          else ""
                          )
                        + (if p-Key#_One <> 0
                          then entry(1, p-key-descr-list) + " "
                              + string(p-Key#_One) + {&new-line}
                          else ""
                          )
                        + (if p-Key#_Two <> 0
                          then entry(2, p-key-descr-list) + " "
                              + string(p-Key#_Two) + {&new-line}
                          else ""
                          )
                        + (if p-Key#_Three <> 0
                          then entry(3, p-key-descr-list) + " "
                              + string(p-Key#_Three) + {&new-line}
                          else ""
                          )
                        + (if p-CharKey_One <> ""
                          then entry(4, p-key-descr-list) + " "
                              + string(p-CharKey_One) + {&new-line}
                          else ""
                          )
                        + (if p-CharKey_Two <> ""
                          then entry(5, p-key-descr-list) + " "
                              + string(p-CharKey_Two) + {&new-line}
                          else ""
                          )
                        + (if p-CharKey_Three <> ""
                          then entry(6, p-key-descr-list) + " "
                              + string(p-CharKey_Three) + {&new-line}
                          else ""
                          )
        .

        assign
          v-message = "Другой пользователь уже захватил ресурс" + {&new-line}
                    + substitute("Пользователь &1", other_batchprocess.bp_execuser_id) + {&new-line}
                    + substitute("Дата начала работы &1", other_batchprocess.bp_execsysdate) + {&new-line}
                    + substitute("Время начала работы &1", other_batchprocess.bp_execsystime) + {&new-line}
                    + substitute('&1':u, v-resource-id)
        .

        if p-message-on
        then do:
          message
            v-message
            view-as alert-box error .
        end.
      end.
      else do:
        assign
          v-message = substitute('&1 &2 &3':u, vss-workfile, vss-revision, vss-description) + {&new-line}
                    + "Внутренняя ошибка при блокировании ресурса" + {&new-line}
                    + "Отсутствует запись о блокировке ресурса" + {&new-line}
        .
        if p-message-on
        then do:
          message
            v-message
            view-as alert-box error.
        end.
      end.

      undo, return error v-message .
    end.
  end.

end procedure. /* lock-record */