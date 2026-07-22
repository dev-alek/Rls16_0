block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lock-swi.p $
$Archive: gbl/lock-swi.p $

Программа разделяемой блокировки глобального ресурса

Автор: Перваков Михаил Сергеевич
Дата создания: 11/09/05
Author: Mikhail Pervakov
Creation date: 11/09/05

Данная процедура должна вызываться при неактивной транзакции
Если транзакция будет активна в момент вызова, то процедура
позволит заблокировать ресурс только одному процессу.
Остальные процессы будут ожидать завершения процесса, заблокировавшего ресурс.

Параметры:
p-process-key    уникальный код ресурса из 4 латинских букв
                 следует использовать препроцессинг с префиксом lock-prc
p-sub-key        подтип блокировки
                 позволяет организовывать совместный захват ресурса
                 для указанного подтипа
p-timeout        Максимальное время ожидания в секундах

p-key-descr      Описание ресурса

p-Key#_One       первичный ключ блокируемого ресурса
p-Key#_Two       (для каждого уникального может иметь свой состав)
p-Key#_Three
p-CharKey_One
p-CharKey_Two
p-CharKey_Three

lock_batchprocess - буфер, который будет хранить блокировку ресурса

*/

define input  parameter p-process-key    as character no-undo .
define input  parameter p-sub-key        as character no-undo .
define input  parameter p-timeout        as integer   no-undo .
define input  parameter p-key-descr      as character no-undo .
define input  parameter p-Key#_One       as integer   no-undo .
define input  parameter p-Key#_Two       as integer   no-undo .
define input  parameter p-Key#_Three     as integer   no-undo .
define input  parameter p-CharKey_One    as character no-undo .
define input  parameter p-CharKey_Two    as character no-undo .
define input  parameter p-CharKey_Three  as character no-undo .
define parameter buffer lock_batchprocess for ub.batchprocess .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: lock-swi.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/lock-swi.p $":U .
define variable vss-description as character no-undo init "Программа блокировки ресурсов".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9':u,p-process-key + '|':u + p-sub-key,p-timeout,p-key-descr,p-Key#_One,p-Key#_Two,p-Key#_Three,p-CharKey_One,p-CharKey_Two,p-CharKey_Three)" }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }

define buffer buf_batchprocess for ub.batchprocess .
define buffer delete_batchprocess for ub.batchprocess .

define variable v-string-01 as character no-undo .
define variable v-string-02 as character no-undo .
define variable v-string-03 as character no-undo .
define variable v-string-04 as character no-undo .
define variable v-string-05 as character no-undo .
define variable v-string-06 as character no-undo .
define variable v-string-07 as character no-undo .

define frame frame-showinf
  v-string-01 format "x(72)" no-label skip
  v-string-02 format "x(72)" no-label skip
  v-string-03 format "x(72)" no-label skip
  v-string-04 format "x(72)" no-label skip
  v-string-05 format "x(72)" no-label skip
  v-string-06 format "x(72)" no-label skip
  v-string-07 format "x(72)" no-label skip
  with view-as dialog-box side-labels three-d
  .

do
on error undo, return error return-value
:
  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .

  if p-process-key = ""
  or p-process-key = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение параметра p-process-key" skip
      "p-process-key"   p-process-key   skip
      "p-sub-key"       p-sub-key       skip
      "p-timeout"       p-timeout       skip
      "p-key-descr"     p-key-descr     skip
      "p-Key#_One"      p-Key#_One      skip
      "p-Key#_Two"      p-Key#_Two      skip
      "p-Key#_Three"    p-Key#_Three    skip
      "p-CharKey_One"   p-CharKey_One   skip
      "p-CharKey_Two"   p-CharKey_Two   skip
      "p-CharKey_Three" p-CharKey_Three skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if length(p-process-key) > 4
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания параметров" skip
      "Ключ блокирования процесса не может превышать 4 символа" skip
      "p-process-key"   p-process-key   skip
      "p-sub-key"       p-sub-key       skip
      "p-timeout"       p-timeout       skip
      "p-key-descr"     p-key-descr     skip
      "p-Key#_One"      p-Key#_One      skip
      "p-Key#_Two"      p-Key#_Two      skip
      "p-Key#_Three"    p-Key#_Three    skip
      "p-CharKey_One"   p-CharKey_One   skip
      "p-CharKey_Two"   p-CharKey_Two   skip
      "p-CharKey_Three" p-CharKey_Three skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if p-sub-key = ""
  or p-sub-key = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение параметра p-sub-key" skip
      "p-process-key"   p-process-key   skip
      "p-sub-key"       p-sub-key       skip
      "p-timeout"       p-timeout       skip
      "p-key-descr"     p-key-descr     skip
      "p-Key#_One"      p-Key#_One      skip
      "p-Key#_Two"      p-Key#_Two      skip
      "p-Key#_Three"    p-Key#_Three    skip
      "p-CharKey_One"   p-CharKey_One   skip
      "p-CharKey_Two"   p-CharKey_Two   skip
      "p-CharKey_Three" p-CharKey_Three skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if p-timeout = ?
  or p-timeout < 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неправильное значение параметра p-timeout" skip
      "p-process-key"   p-process-key   skip
      "p-sub-key"       p-sub-key       skip
      "p-timeout"       p-timeout       skip
      "p-key-descr"     p-key-descr     skip
      "p-Key#_One"      p-Key#_One      skip
      "p-Key#_Two"      p-Key#_Two      skip
      "p-Key#_Three"    p-Key#_Three    skip
      "p-CharKey_One"   p-CharKey_One   skip
      "p-CharKey_Two"   p-CharKey_Two   skip
      "p-CharKey_Three" p-CharKey_Three skip
      view-as alert-box error .
    undo, return error return-value .

  end.

  define variable v-bp_type like ub.batchprocess.bp_type no-undo .

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

  if not available ub.BatchProcess
  then do:
    do transaction
    on error undo, return error return-value
    :
      create ub.BatchProcess .

      define variable v-btpr_upd-today as date      no-undo .
      define variable v-btpr_upd-time  as integer   no-undo .

      run cur-time in this-procedure
        (output v-btpr_upd-today
        ,output v-btpr_upd-time
        ).

      assign
        ub.BatchProcess.BP_Type       = v-bp_type
        ub.BatchProcess.BP_Status     = {&btpr-normal}
        ub.BatchProcess.BatchProcess# = next-value(s-btpr, {&db-name_schema})
        ub.BatchProcess.BP_SysDate    = v-btpr_upd-today
        ub.BatchProcess.BP_SysTime    = string( v-btpr_upd-time, 'HH:MM':u )
        ub.BatchProcess.BP_SysTimeInt = v-btpr_upd-time
      .

      assign
        ub.batchprocess.key#_one      = p-Key#_One
        ub.batchprocess.key#_two      = p-Key#_Two
        ub.batchprocess.key#_three    = p-Key#_Three
        ub.batchprocess.charkey_one   = p-CharKey_One
        ub.batchprocess.charkey_two   = p-CharKey_Two
        ub.batchprocess.charkey_three = p-CharKey_Three
      .

      assign
        ub.batchprocess.user_id = p-sub-key
      .
      validate ub.batchprocess .
    end.
  end.

  run lock-record in this-procedure
    (input  rowid(ub.batchprocess)
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
      (input  rowid(buf_batchprocess)
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

      do transaction
      on error undo, return error return-value
      :
        delete ub.batchprocess .
      end.
      undo, return error return-value .
    end.
  end.

  find current lock_batchprocess share-lock .

  return . /* --->>>--- */
end.

procedure lock-record :

  define input  parameter p-block-rowid    as rowid     no-undo .
  define parameter buffer buf_batchprocess for ub.batchprocess .

  define variable v-resource-id as character no-undo .
  define variable v-current-subkey as character no-undo .

  define variable v-count       as integer   no-undo .
  define variable v-pause       as integer   no-undo .
  define variable v-start-etime as int64     no-undo .
  define variable v-time-second as integer   no-undo .

  do
  on error undo, return error return-value
  :

    assign
      v-count = 0
    .
    assign
      v-start-etime = etime
    .

    define variable v-trasaction-active as logical   no-undo .

    assign
      v-trasaction-active = transaction
    .

    do while true
    on endkey undo, return error "Ожидание освобождения ресурса прервано пользователем"
/*    on end-error undo, return error "Ожидание освобождения ресурса прервано пользователем"*/
    :
      do transaction
      on error undo, return error return-value
      :
        if v-trasaction-active = true
        then do:
          find buf_batchprocess exclusive-lock
            where rowid(buf_batchprocess) = p-block-rowid
            no-wait
            no-error .
          if available (buf_batchprocess)
          then do:
            assign
              buf_batchprocess.user_id = p-sub-key
            .
            /* успешное завершение */
            return . /* --->>>--- */
          end.
        end.
        else do:
          find buf_batchprocess share-lock
            where rowid(buf_batchprocess) = p-block-rowid
            no-wait
            no-error .
          if available (buf_batchprocess)
          then do:
            assign
              v-current-subkey = buf_batchprocess.user_id
            .
            if buf_batchprocess.user_id = p-sub-key
            then do:
              /* успешное завершение */
              return . /* --->>>--- */
            end.
          end.
        end.
      end.

      find buf_batchprocess no-lock
        where rowid(buf_batchprocess) = p-block-rowid
        no-error .

      assign
        v-pause = 5 + random(1, 9)
      .
      pause v-pause no-message .

      do transaction
      on error undo, return error return-value
      :
        find buf_batchprocess exclusive-lock
          where rowid(buf_batchprocess) = p-block-rowid
          no-wait
          no-error .
        if available (buf_batchprocess)
        then do:
          assign
            buf_batchprocess.user_id = p-sub-key
          .
          /* успешное завершение */
          return . /* --->>>--- */
        end.
      end.

      assign
        v-pause = 5 + random(1, 9)
      .
      pause v-pause no-message .

      assign
        v-count       = v-count + 1
        v-time-second = integer((etime - v-start-etime) / 1000)
      .

      if  p-timeout     > 0
      and v-time-second > p-timeout
      then do:
        /* истекло отпущенное время */
        undo, return error substitute("Превышено время ожидания ресурса &1", p-process-key) .
      end.

      if frame frame-showinf :visible = false
      then do:
        view frame frame-showinf .
      end.

      assign
        v-string-01 = substitute("Ожидание возможности доступа к глобальному ресурсу")
        v-string-02 = substitute("Глобальный ресурс: &1"
                                ,p-process-key
                                )
        v-string-03 = substitute("Текущее значение ресурса: &1"
                                ,v-current-subkey
                                )
        v-string-04 = substitute("Новое значение ресурса: &1"
                                ,p-sub-key
                                )
        v-string-05 = substitute("Ресурс ожидается в течение: &1"
                                ,string(v-time-second, 'HH:MM:SS':u)
                                )
        v-string-06 = (if   p-timeout > 0
                       then substitute("Оставшееся время ожидания ресурса: &1"
                                      ,string(max(0
                                                 ,p-timeout - v-time-second
                                                 )
                                             ,'HH:MM:SS':u
                                             )
                                      )
                       else "Бесконечное время ожидания ресурса"
                      )
        v-string-07 = substitute("Произведено попыток захвата ресурса: &1"
                                ,v-count
                                )
      .

      display
        v-string-01
        v-string-02
        v-string-03
        v-string-04
        v-string-05
        v-string-06
        v-string-07
        with frame frame-showinf .
    end.
  end.

end procedure. /* lock-record */