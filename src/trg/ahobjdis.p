block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запретить или разрешить расчет архива по объекту

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 11/14/05

*/

define input  parameter p-archive-type as character no-undo .
define input  parameter p-obj-type     as character no-undo .
define input  parameter p-obj-code     as integer   no-undo .
define input  parameter p-disable      as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запретить или разрешить расчет архива по объекту".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/clntattr.i }
{ gbl/waitfram.i }

define buffer buf_clients for ub.clients .

define variable v-attr-code-calc           as character no-undo .
define variable v-attr-code-del            as character no-undo .
define variable v-attr-code-disable        as character no-undo .
define variable v-attr-value               as character no-undo .
define variable v-attr-type                as character no-undo .
define variable v-archive-type-description as character no-undo .
define variable v-lock-prc-restore         as character no-undo .
define variable v-lock-prc-calc            as character no-undo .
define variable v-lock-prc-stop-news       as character no-undo .
define variable v-create-chip-num          as character no-undo .

do
on error undo, return error return-value
:
  case p-archive-type
  :
    when {&btpr-type-arh}
    then do:
      assign
        v-attr-code-calc           = {&attr-arh-calc}
        v-attr-code-del            = {&attr-arh-del}
        v-attr-code-disable        = {&attr-arh-disable}
        v-archive-type-description = "по товарам"
        v-lock-prc-restore         = {&lock-prc-restore-arh}
        v-lock-prc-calc            = {&lock-prc-calc-arh}
        v-lock-prc-stop-news       = {&lock-prc-stop-arh-news}
      .
    end.
    when {&btpr-type-ahsp}
    then do:
      assign
        v-attr-code-calc           = {&attr-ahsp-calc}
        v-attr-code-del            = {&attr-ahsp-del}
        v-attr-code-disable        = {&attr-ahsp-disable}
        v-archive-type-description = "по поставщикам"
        v-lock-prc-restore         = {&lock-prc-restore-ahsp}
        v-lock-prc-calc            = {&lock-prc-calc-supp-arh}
        v-lock-prc-stop-news       = {&lock-prc-stop-ahsp-news}
      .
    end.
    when {&btpr-type-aht}
    then do:
      assign
        v-attr-code-calc           = {&attr-aht-calc}
        v-attr-code-del            = {&attr-aht-del}
        v-attr-code-disable        = {&attr-aht-disable}
        v-archive-type-description = "по типам приобретения"
        v-lock-prc-restore         = {&lock-prc-restore-aht}
        v-lock-prc-calc            = {&lock-prc-calc-aht}
        v-lock-prc-stop-news       = {&lock-prc-stop-aht-news}
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестное значение параметра p-archive-type" skip
        "" p-archive-type skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

  find first buf_clients no-lock
    where buf_clients.obj-type = p-obj-type
      and buf_clients.obj-code = p-obj-code
    no-error .
  if not available buf_clients
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден объект" skip
      "Объект" p-obj-type p-obj-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if  p-obj-type <> {&shop}
  and p-obj-type <> {&stock}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неправильный тип объекта" skip
      "Объект" p-obj-type p-obj-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if p-disable = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не задано значение параметра p-disable" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  define buffer restore-arh-lock_batchprocess for ub.batchprocess .
  /* блокировка процедуры восстановления складского архива */
  run gbl/lock-prc.p
    (input v-lock-prc-restore
    ,input p-obj-code
    ,input 0
    ,input 0
    ,input p-obj-type
    ,input ""
    ,input ""
    ,input substitute("Объект,,, ,,,Восстановление складского складского архива &1", v-archive-type-description)
    ,input true
    ,buffer restore-arh-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры блокировки восстановления складского архива" skip
        "Объект" p-obj-type p-obj-code skip
        "Складской архив" v-archive-type-description skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.

  /* блокировка процедуры расчета складского архива */

  define variable v-need-stop-arh as logical   no-undo .

  assign
    v-need-stop-arh = false
  .

  define buffer calc-arh-lock_batchprocess for ub.batchprocess .

  run gbl/lock-prc.p
    (input v-lock-prc-calc
    ,input p-obj-code
    ,input 0
    ,input 0
    ,input p-obj-type
    ,input ""
    ,input ""
    ,input substitute("Объект,,, ,,,Расчет складского архива &1", v-archive-type-description)
    ,input false
    ,buffer calc-arh-lock_batchprocess
    ) no-error .
  if error-status :error then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры блокировки расчета складского архива" skip
        "Объект" p-obj-type p-obj-code skip
        "Складской архив" v-archive-type-description skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute("Ошибка при вызове процедуры блокировки расчёта складского архива &1", v-archive-type-description) .
    end.
    assign
      v-need-stop-arh = true
    .
  end.

  define buffer stop-arh-news-lock_btpr for batchprocess .

  if v-need-stop-arh = true
  then do:
    /* если расчёт складского архива заблокирован, */
    /* отправить команду на остановку процесса расчёта складского архива */
    do transaction
    on error undo, return error return-value
    :
      create stop-arh-news-lock_btpr .
      assign
        stop-arh-news-lock_btpr.bp_type       = {&btpr-type-lock} + v-lock-prc-stop-news
        stop-arh-news-lock_btpr.bp_status     = {&btpr-normal}
        stop-arh-news-lock_btpr.Key#_One      = p-obj-code
        stop-arh-news-lock_btpr.Key#_Two      = 0
        stop-arh-news-lock_btpr.Key#_Three    = 0
        stop-arh-news-lock_btpr.CharKey_One   = p-obj-type
        stop-arh-news-lock_btpr.CharKey_Two   = ""
        stop-arh-news-lock_btpr.CharKey_Three = ""
      .

      define variable v-start-lock-time   as int64     no-undo .
      define variable v-start-lock-second as integer   no-undo .
      assign
        v-start-lock-time = etime
      .
      wait_block:
      do while true
      :
        assign
          v-start-lock-second = integer((etime - v-start-lock-time) / 1000)
        .
        run waitfram-show in this-procedure
          (input waitfram-join-function(substitute("Архив &1 рассчитывается на другой машине", v-archive-type-description)
                                       ,substitute("Отправлено сообщение о необходимости остановки расчёта складского архива &1", v-archive-type-description)
                                       ,substitute("Ожидание освобождение ресурса расчёта складского архива &1", string(v-start-lock-second, 'HH:MM:SS':U))
                                       )
          ) .
        run gbl/lock-prc.p
          (input v-lock-prc-calc
          ,input p-obj-code
          ,input 0
          ,input 0
          ,input p-obj-type
          ,input ""
          ,input ""
          ,input substitute("Объект,,, ,,,Расчет складского архива &1", v-archive-type-description)
          ,input false
          ,buffer calc-arh-lock_batchprocess
          ) no-error .
        if error-status :error
        then do:
          if error-status :get-message(1) <> ""
          then do:
            message
              vss-workfile vss-revision vss-description skip
              substitute("Ошибка при вызове процедуры блокировки расчета складского архива &1", v-archive-type-description) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
        else do:
          leave wait_block .
        end.
        pause 1 no-message .
      end.

      delete stop-arh-news-lock_btpr .

      run waitfram-hide in this-procedure .
    end.
  end.

  if p-disable = true
  then do:
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  v-attr-code-disable
      ,output v-attr-value
      ,output v-attr-type
      ) .
    if lookup(v-attr-value
             ,'yes,true':u
             ) = 0
    then do:
      run utl/arhiscr.p
        (input  p-obj-type                     /* p-obj-type              */
        ,input  p-obj-code                     /* p-obj-code              */
        ,input  p-archive-type                 /* p-archive-type          */
        ,input  {&archive-history-set-disable} /* p-action-type           */
        ,input  ""                             /* p-file-name             */
        ,input  ""                             /* p-file-md5              */
        ,input  0                              /* p-file-invalid-chip-num */
        ,input  ""                             /* p-source-type           */
        ,input  ""                             /* p-source-ref            */
        ,input  ?                              /* p-source-date           */
        ,output v-create-chip-num              /* p-create-chip-num       */
        ) .

      run clntattr-write in this-procedure
        (input  p-obj-type
        ,input  p-obj-code
        ,input  v-attr-code-del
        ,input  'yes':u
        ) .

      run clntattr-write in this-procedure
        (input  p-obj-type
        ,input  p-obj-code
        ,input  v-attr-code-calc
        ,input  'yes':u
        ) .

      run clntattr-write in this-procedure
        (input  p-obj-type
        ,input  p-obj-code
        ,input  v-attr-code-disable
        ,input  'yes':u
        ) .
    end.
  end.
  else do:
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  v-attr-code-disable
      ,output v-attr-value
      ,output v-attr-type
      ) .
    if lookup(v-attr-value
             ,'yes,true':u
             ) > 0
    then do:
      run utl/arhiscr.p
        (input  p-obj-type                       /* p-obj-type              */
        ,input  p-obj-code                       /* p-obj-code              */
        ,input  p-archive-type                   /* p-archive-type          */
        ,input  {&archive-history-clear-disable} /* p-action-type           */
        ,input  ""                               /* p-file-name             */
        ,input  ""                               /* p-file-md5              */
        ,input  0                                /* p-file-invalid-chip-num */
        ,input  ""                               /* p-source-type           */
        ,input  ""                               /* p-source-ref            */
        ,input  ?                                /* p-source-date           */
        ,output v-create-chip-num                /* p-create-chip-num       */
        ) .

      run clntattr-write in this-procedure
        (input  p-obj-type
        ,input  p-obj-code
        ,input  v-attr-code-disable
        ,input  'no':u
        ) .
    end.
  end.

end.