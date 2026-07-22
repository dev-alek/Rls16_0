block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lock-usr.p $
$Archive: gbl/lock-usr.p $

Программа захвата ресурса и возвращения количества пользователей, захвативших ресурс

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Параметры:
p-user-id
p-resource-key   уникальный код ресурса из 4 латинских букв
                 следует использовать препроцессинг с префиксом lock-prc

p-key-descr-list список из 7 элементов
                 первые 6 элементов используются для описания ключевых полей
                 если элемент списка отличен от нуля, то в сообщении
                 появится описание поля ключа вместе с его значением

                 последний элемент задает название ресурса на языке,
                 понятном пользователю

p-message-on     выводить сообщение на экран

p-message-txt

p-max-user-lock  максимальное количество пользователей

lock_batchprocess - буфер, который будет хранить блокировку ресурса

*/

define input  parameter p-user-id         as character no-undo .
define input  parameter p-resource-key    as character no-undo .
define input  parameter p-message-on      as logical   no-undo .
define input  parameter p-message-txt     as character no-undo .
define input  parameter p-max-user-lock   as integer   no-undo .
define parameter buffer lock_batchprocess for ub.batchprocess .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: lock-usr.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/lock-usr.p $":U .
def var vss-description as character no-undo init "Программа блокировки ресурсов".
{ cmp/vssrevis.i "substitute('':u,p-user-id,p-resource-key,p-message-on,p-max-user-lock)" }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }

def buffer buf_batchprocess for ub.batchprocess .
def buffer delete_batchprocess for ub.batchprocess .
define buffer trylock_batchprocess for ub.batchprocess .

define variable g#userid as character no-undo .
assign
  g#userid = p-user-id
.

do
on error undo, return error
:
  if p-resource-key = ?
  or p-resource-key = ""
  or length(p-resource-key) > 4
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания параметров" skip
      "Код ресурса должен быть задан"
      "и не может превышать 4 символа" skip
      "Код ресурса" p-resource-key skip
      view-as alert-box error .
    undo, return error .
  end.

  def var v-bp_type like ub.batchprocess.bp_type no-undo .

  assign
    v-bp_type = 'lusr':u + p-resource-key
  .

  define variable v-count-lock as integer   no-undo .

  assign
    v-count-lock = 0
  .

  define variable v-Key#_One as integer   no-undo .
  define variable v-prev-Key#_One as integer   no-undo .

  assign
    v-Key#_One = 0
    v-prev-Key#_One = 1
  .

  /* просматриваем все записи с данным ресурсом */
  /* находим захваченные записи */
  for each buf_batchprocess no-lock
    where buf_batchprocess.bp_type = v-bp_type
      and buf_batchprocess.bp_status = {&btpr-normal}
  by buf_batchprocess.Key#_One
  on error undo, return error return-value
  :
    do transaction
    on error undo, return error return-value
    :
      find first trylock_batchprocess exclusive-lock
        where recid(trylock_batchprocess) = recid(buf_batchprocess)
        no-error
        no-wait
        .
      if available trylock_batchprocess then do:
        delete trylock_batchprocess .
        next . /* --->>>--- */
      end.
      else do:
        assign
          v-count-lock = v-count-lock + 1
        .
      end.

      /* определяем свободный номер ключа */
      if buf_batchprocess.Key#_one > v-prev-Key#_One + 1
      then do:
        assign
          v-Key#_One = v-prev-Key#_One + 1
        .
      end.
      assign
        v-prev-Key#_One = buf_batchprocess.Key#_one
      .

      /* проверяем превышение количества блокировок в процессе */
      if p-max-user-lock < v-count-lock + 1 then do:
        if p-message-on
        then do:
          message
            substitute(p-message-txt, p-max-user-lock) skip
            view-as alert-box error .
        end.
        undo, return error .
      end.
    end.
  end.

  if v-key#_one = 0
  then do:
    assign
      v-Key#_One = v-prev-Key#_One + 1
    .
  end.

  do transaction
  on error undo, return error return-value
  :
    /* создаем запись */
    { trg/btpr_upd.i
      &btpr-status="create"
      &btpr-type=v-bp_type
      &Key#_One=v-Key#_One
    }
    validate ub.batchprocess .
  end.

  /* блокируем запись */
  run lock-record in this-procedure
    (buffer ub.batchprocess
    ,buffer lock_batchprocess
    ) no-error .
  if error-status :error then do:
    if error-status :get-message(1) <> "" then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры lock-record" skip
        view-as alert-box error .
    end.
    undo, return error .
  end.
end.

procedure lock-record :
  define parameter buffer other_batchprocess for ub.batchprocess .
  define parameter buffer buf_batchprocess for ub.batchprocess .

  def var v-resource-id as character no-undo .

  do
  on error undo, return error
  :
    find buf_batchprocess exclusive-lock
      where recid(buf_batchprocess) = recid(other_batchprocess)
      no-wait
      no-error .
    if not available buf_batchprocess then do:
      if locked buf_batchprocess then do:
        if p-message-on then do:
          message
            "Другой пользователь уже захватил ресурс" skip
            "Пользователь" other_batchprocess.bp_execuser_id skip
            "Дата начала работы " other_batchprocess.bp_execsysdate skip
            "Время начала работы " other_batchprocess.bp_execsystime skip
            v-resource-id skip
            view-as alert-box error .
        end.
      end.
      else do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка при блокировании ресурса" skip
          "Отсутствует запись о блокировке ресурса" skip
          view-as alert-box error.
      end.

      undo, return error.
    end.

    assign
      lock_batchprocess.bp_execuser_id    = g#userid
      lock_batchprocess.bp_execsysdate    = today
      lock_batchprocess.bp_execsystime    = string(time, 'hh:mm')
    .

  end.

end procedure. /* lock-record */