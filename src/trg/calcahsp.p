block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет складского архива по поставщикам

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 07/03/02

*/

define input  parameter p-obj-type          as character no-undo .
define input  parameter p-obj-code          as integer   no-undo .
define input  parameter p-check-doc         as logical   no-undo .
define input  parameter p-message-on        as logical   no-undo .
define input  parameter p-last-fact-date    as date      no-undo .
define input  parameter p-check-act         as logical   no-undo .
define input  parameter p-check-act-db-num  as integer   no-undo .
define input  parameter p-check-act-user-id as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Расчет складского архива по поставщикам".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4',p-obj-type,p-obj-code,p-message-on,p-check-doc,p-last-fact-date)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/clntattr.i }
{ cmp/operlist.i }
{ trg/factord.i  }
{ trg/doclslib.i }

define stream slog .

do
on error undo, return error return-value
:
  define variable v-today as date      no-undo .

  define variable v-action as character no-undo .
  def frame a
    "Объект" p-obj-type no-label p-obj-code no-label skip
    v-action format "x(50)" no-label skip
    with view-as dialog-box side-labels three-d
    title "Расчет складского архива по поставщикам"
    .
  view frame a .

  define buffer calc-supp-arh-lock_batchprocess for ub.batchprocess .

  run gbl/lock-prc.p
    (input {&lock-prc-calc-supp-arh}
    ,input p-obj-code
    ,input 0
    ,input 0
    ,input p-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
    ,input p-message-on
    ,buffer calc-supp-arh-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if p-message-on = true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "В данный момент рассчитывается складской архив по поставщикам" skip
        "Невозможно произвести расчет складского архива по поставщикам" skip
        view-as alert-box error .
    end.
    undo, return error "Складской архив по поставщикам рассчитывается" . /* --->>>--- */
  end.

  run log-information in this-procedure
    (input p-obj-type /* p-obj-type */
    ,input p-obj-code /* p-obj-code */
    ,input "start"    /* p-message  */
    ) .

  run cb-doclslib-log in this-procedure
    (input substitute("Начало расчёта архива. Проверять документы &1. Сообщения &2. Дата перерасчёта &3"
                     ,p-check-doc
                     ,p-message-on
                     ,string(p-last-fact-date, '99/99/9999':U)
                     )
    ) .

  /* признак того, что на объекте имеется рассчитанный складской архив по поставщикам */
  define variable v-archive-exist as logical no-undo .

  /* определяем дату с которой в системе существуют правильные документы */
  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .

  define variable v-ahsp-del as logical   no-undo .

  run clntattr-value in this-procedure
    (input  p-obj-type              /* p-obj-type */
    ,input  p-obj-code              /* p-obj-code */
    ,input  {&attr-ahsp-del}         /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-ahsp-del = (lookup(v-attr-value, 'yes,true') > 0)
  .
  if v-ahsp-del = true
  then do:
    if p-message-on = true
    then do:
      run cb-doclslib-log in this-procedure
        (input "На объекте отсутствуют рассчитанные остатки"
        ) .
      message
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "На объекте отсутствуют рассчитанные остатки" skip
        "Расчет складского архива по поставщикам невозможен" skip
        view-as alert-box error .
    end.
    undo, return error "Складской архив по поставщикам: отсутствуют остатки" .
  end.

  run clntattr-value in this-procedure
    (input  p-obj-type               /* p-obj-type */
    ,input  p-obj-code               /* p-obj-code */
    ,input  {&attr-ahsp-detail-date} /* p-code     */
    ,output v-attr-value             /* p-value    */
    ,output v-attr-type              /* p-type     */
    ) .

  /* считается, что все документы с датой фактического закрытия */
  /* больше или равной v-ahsp-detail-date являются правильными и целостными */
  define variable v-ahsp-detail-date       as date    no-undo .
  define variable v-ahsp-detail-fact-order as decimal no-undo .

  assign
    v-ahsp-detail-date = date(v-attr-value)
  .

  display
    p-obj-type p-obj-code
    with frame a.

  define variable v-last-fact-date  as date    no-undo .

  if p-check-doc = false
  then do:
    if p-last-fact-date = ?
    then do:
      if p-message-on = true
      then do:
        run cb-doclslib-log in this-procedure
          (input "Ошибка задания входных параметров. Не задана дата перерасчёта"
          ) .
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не задана дата перерасчета" skip
          "Складской архив по поставщикам" skip
          "Объект" p-obj-type p-obj-code skip
          "Проверять наличие документов" p-check-doc skip
          "Выводить сообщение" p-message-on skip
          "Дата перерасчета" p-last-fact-date skip
          view-as alert-box error .
      end.
      undo, return error "Не задана дата перерасчета складского архива по поставщикам" .
    end.
    else do:
      assign
        v-last-fact-date = p-last-fact-date
      .
    end.
  end.
  else do:
    run show-action in this-procedure
      (input "Составление списка документов"
      ) .

    run day-begin-fact-order in this-procedure
      (input  v-ahsp-detail-date       /* p-fact-date            */
      ,output v-ahsp-detail-fact-order /* p-day-begin-fact-order */
      ).

    run doclslib-check-ahsp-exist in this-procedure
      (input  p-obj-type               /* p-obj-type       */
      ,input  p-obj-code               /* p-obj-code       */
      ,input  v-ahsp-detail-fact-order /* p-cut-fact-order */
      ,output v-archive-exist          /* p-archive-exist  */
      ).

    run doclslib-clear-doc-list in this-procedure .

    run doclslib-init-trn-doc in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input v-ahsp-detail-date
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Ошибка при вызове процедуры doclslib-init-trn-doc" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.

    run doclslib-clear-ahsp-doc-list in this-procedure
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Ошибка при вызове процедуры doclslib-clear-ahsp-doc-list" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.

    if v-archive-exist = true
    then do:
      /* на выбранном объекте уже есть складской архив по поставщикам */

      /* определяем документы, для которых есть складской архив по поставщикам */
      run doclslib-check-doc-ahsp-exist in this-procedure
        .

      define variable v-last-fact-date-reason as character no-undo .

      /* определяем дату и номер последнего правильно рассчитанного дня */
      run doclslib-find-last-fact-date in this-procedure
        (output v-last-fact-date        /* p-last-fact-date  */
        ,output v-last-fact-date-reason /* p-reason          */
        ) .

      /* считываем дату перерасчета архива */
      define variable v-ahsp-recalc      as character no-undo .
      define variable v-ahsp-recalc-date as date      no-undo .

      run clntattr-value in this-procedure
        (input  p-obj-type               /* p-obj-type */
        ,input  p-obj-code               /* p-obj-code */
        ,input  {&attr-ahsp-recalc-date} /* p-code     */
        ,output v-ahsp-recalc            /* p-value    */
        ,output v-attr-type              /* p-type     */
        ) .
      assign
        v-ahsp-recalc-date = date(v-ahsp-recalc)
      .

      if  v-ahsp-recalc-date <> ?
      then do:
        if v-last-fact-date = ?
        or (v-last-fact-date <> ?
            and
            v-last-fact-date > v-ahsp-recalc-date
           )
        then do:
          assign
            v-last-fact-date        = v-ahsp-recalc-date
            v-last-fact-date-reason = "Складской архив по поставщикам требует перерасчета из-за удаления или закрытия документа задним числом"
          .
        end.
      end.

      if  v-ahsp-detail-date <> ?
      and v-last-fact-date   <> ?
      and v-last-fact-date   < v-ahsp-detail-date
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Складской архив по поставщикам" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата последнего рассчитанного документа" skip
          "не может быть меньше чем дата начала подробного складского архива по поставщикам" skip
          "Дата последнего рассчитанного документ" v-last-fact-date skip
          "Дата начала подробного складского архива по поставщикам" v-ahsp-detail-date skip
          view-as alert-box error .
        undo, return error return-value . /* --->>>--- */
      end.

      if p-message-on = true
      then do:
        define variable v-num as integer   no-undo .
        run gbl/d-askw.w
          (input "Вопрос"
          ,input "На объекте уже есть рассчитанный складской архив по поставщикам" + {&new-line}
              + substitute("Объект &1 &2", p-obj-type, p-obj-code) + {&new-line}
          ,input "|^"
          ,input "С последней" + (if v-last-fact-date = ? then "^disable" else "") + "|"
              + "С выбранной|Весь архив^confirm|Отмена"
          ,input "Пересчитать складской архив по поставщикам начиная с даты " +
                  (if v-last-fact-date <> ? then string(v-last-fact-date, '99/99/9999':u)
                                                  + {&new-line} + v-last-fact-date-reason
                    else "?"
                  ) + "|"
              + "Выбрать дату и пересчитать складской архив по поставщикам начиная с выбранной даты" + "|"
              + "Удалить складской архив по поставщикам и рассчитать их на основе документов" + {&new-line}
              + (if v-ahsp-detail-date <> ?
                then "Будут рассмотрены документы с даты " + string(v-ahsp-detail-date, '99/99/9999')
                else ""
                )
              + "|"
              + "Отказаться от расчета складского архива по поставщикам"
          ,input 1
          ,input 4
          ,output v-num
          ).

        case v-num :
          when 1
          then do:
            /* пересчитать складской архив по поставщикам начиная с v-last-fact-date */
            run cb-doclslib-log in this-procedure
              (input substitute("Выбор пользователя 1. Пересчитать с последней даты &1"
                               ,string(v-last-fact-date, '99/99/9999':u)
                               )
              ) .
          end.
          when 2
          then do:
            /* пересчитать с выбранной даты */
            update-block:
            do while true
            :
              if v-ahsp-recalc-date <> ?
              then do:
                assign
                  v-today = v-ahsp-recalc-date
                .
              end.
              else do:
                { gbl/curobjdt.i
                  p-obj-type
                  p-obj-code
                  v-today
                }
              end.

              define variable v-string-last-fact-date as character no-undo .
              assign
                v-string-last-fact-date = string(v-today, '99/99/9999':u)
              .
              run gbl/d-prompt.w
                ( 'title=':u + "Введите дату" + '\':u
                + 'text1=':u + "Введите дату, начиная с которой надо рассчитать" + '\':u
                + 'text2=':u + "складской архив по поставщикам" + '\':u
                + 'type=date\':u
                ,input-output v-string-last-fact-date
                ).
              if return-value = 'false':u
              then do:
                /* отказ от расчета складского архива по поставщикам */
                undo, return error return-value . /* --->>>--- */
              end.
              assign
                v-last-fact-date = date(v-string-last-fact-date)
              .

              if  v-last-fact-date = ?
              then do:
                message
                  "Складской архив по поставщикам" skip
                  "Объект" p-obj-type p-obj-code skip
                  "Вы не задали дату"
                  view-as alert-box information .
                next update-block .
              end.

              if  v-ahsp-recalc-date <> ?
              and v-last-fact-date   > v-ahsp-recalc-date
              then do:
                message
                  "Складской архив по поставщикам" skip
                  "Объект" p-obj-type p-obj-code skip
                  "На объекте требуется перерасчет складского архива по поставщикам с указанной даты" skip
                  "Введенная дата не может быть больше даты" v-ahsp-recalc-date skip
                  "Вы ввели дату" v-last-fact-date skip
                  view-as alert-box information .
                next update-block .
              end.

              if  v-ahsp-detail-date <> ?
              and v-last-fact-date   <> ?
              and v-last-fact-date   < v-ahsp-detail-date
              then do:
                message
                  "Складской архив по поставщикам" skip
                  "Объект" p-obj-type p-obj-code skip
                  "Введенная дата не может быть меньше даты" v-ahsp-detail-date skip
                  "Вы ввели дату" v-last-fact-date skip
                  view-as alert-box information .
                next update-block .
              end.

              leave update-block .
            end.

            run cb-doclslib-log in this-procedure
              (input substitute("Выбор пользователя 2. Пересчитать с даты &1"
                               ,string(v-last-fact-date, '99/99/9999':u)
                               )
              ) .
          end.
          when 3
          then do:
            /* удалить и пересчитать весь складской архив по поставщикам */
            assign
              v-last-fact-date = v-ahsp-detail-date
            .

            run cb-doclslib-log in this-procedure
              (input substitute("Выбор пользователя 3. Пересчитать весь архив &1"
                               ,string(v-last-fact-date, '99/99/9999':u)
                               )
              ) .
          end.
          when 4
          then do:
            /* отказ от расчета складского архива по поставщикам */
            run cb-doclslib-log in this-procedure
              (input "Выбор пользователя 4. Отказ от расчёта архива"
              ) .
            undo, return error return-value . /* --->>>--- */
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Складской архив по поставщикам" skip
              "Объект" p-obj-type p-obj-code skip
              "Неизвестное значение v-num" v-num skip
              view-as alert-box error .
            undo, return error return-value . /* --->>>--- */
          end.
        end case .
      end.
    end.
    else do:
      /* удалить и пересчитать складской архив по поставщикам */
      assign
        v-last-fact-date = v-ahsp-detail-date
      .
    end.

    if v-last-fact-date <> ?
    then do:
      if  p-last-fact-date = ?
      and p-message-on     = true
      then do:
        define variable lok as logical no-undo .
        assign
          lok = false
        .
        message
          "Складской архив по поставщикам" skip
          "Объект" p-obj-type p-obj-code skip
          "Частичный расчет складского архива по поставщикам" skip
          "Складской архив по поставщикам за дату" string(v-last-fact-date, '99/99/9999':u) "и за более позднием будет удален" skip
          "и рассчитан на основании документов" skip
          "Продолжить?" skip
          view-as alert-box question buttons yes-no update lok .
        if lok <> true
        then do:
          undo, return error return-value . /* --->>>--- */
        end.
      end.
    end.
  end.

  /* перерассчитать переоценки */
  run cb-doclslib-log in this-procedure
    (input "Перерасчёт переоценок"
    ) .
  run show-action in this-procedure
    (input "Перерасчет переоценок"
    ) .
  run trg/bt_prc.p
    (input p-obj-type          /* p-obj-type          */
    ,input p-obj-code          /* p-obj-code          */
    ,input p-check-act         /* p-check-act         */
    ,input p-check-act-db-num  /* p-check-act-db-num  */
    ,input p-check-act-user-id /* p-check-act-user-id */
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при перасчете переоценок" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.

  define variable v-create-chip-num as integer   no-undo .
  run utl/arhiscr.p
    (input  p-obj-type                    /* p-obj-type              */
    ,input  p-obj-code                    /* p-obj-code              */
    ,input  {&btpr-type-ahsp}             /* p-archive-type          */
    ,input  {&archive-history-calc-start} /* p-action-type           */
    ,input  ""                            /* p-file-name             */
    ,input  ""                            /* p-file-md5              */
    ,input  0                             /* p-file-invalid-chip-num */
    ,input  ""                            /* p-source-type           */
    ,input  ""                            /* p-source-ref            */
    ,input  p-last-fact-date              /* p-source-date           */
    ,output v-create-chip-num             /* p-create-chip-num       */
    ) .

  run cb-doclslib-log in this-procedure
    (input substitute("Начало перерасчёта с даты &1"
                     ,string(v-last-fact-date, '99/99/9999':u)
                     )
    ) .

  define variable v-last-fact-order as decimal no-undo .

  run day-begin-fact-order in this-procedure
    (input  v-last-fact-date  /* p-fact-date            */
    ,output v-last-fact-order /* p-day-begin-fact-order */
    ).

  run show-action in this-procedure
    (input "Составление списка документов"
    ) .

  run doclslib-clear-doc-list in this-procedure .

  run doclslib-init-trn-doc in this-procedure
    (input p-obj-type
    ,input p-obj-code
    ,input v-last-fact-date
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Складской архив по поставщикам" skip
      "Объект" p-obj-type p-obj-code skip
      "Ошибка при вызове процедуры doclslib-init-trn-doc" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value . /* --->>>--- */
  end.

  if v-last-fact-date <> ?
  then do:
    /* устанавливаем дату, с которой производится перерасчет архива */
    run clntattr-write in this-procedure
      (input p-obj-type                               /* p-obj-type */
      ,input p-obj-code                               /* p-obj-code */
      ,input {&attr-ahsp-recalc-date}                 /* p-code     */
      ,input string(v-last-fact-date, '99/99/9999':U) /* p-value    */
      ) .

    run cb-doclslib-log in this-procedure
      (input substitute("Устанавливается дата перерасчёта &1"
                      ,string(v-last-fact-date, '99/99/9999':U)
                      )
      ) .
  end.
  else do:
    run clntattr-write in this-procedure
      (input p-obj-type        /* p-obj-type */
      ,input p-obj-code        /* p-obj-code */
      ,input {&attr-ahsp-calc} /* p-code     */
      ,input string(true)      /* p-value    */
      ) .

    run cb-doclslib-log in this-procedure
      (input substitute("Архив помечается, как требующей расчета")
      ) .

    /* удаляем информацию о том, что требуется перерасчет складского архива по товарам */
    define variable v-attr-deleted as logical   no-undo .
    run clntattr-delete in this-procedure
      (input  p-obj-type               /* p-obj-type */
      ,input  p-obj-code               /* p-obj-code */
      ,input  {&attr-ahsp-recalc-date} /* p-code     */
      ,output v-attr-deleted           /* p-deleted  */
      ) .
    if v-attr-deleted = true
    then do:
      run cb-doclslib-log in this-procedure
        (input "Удалена дата перерасчёта"
        ) .
    end.
  end.

  run show-action in this-procedure
    (input "Очистка складского архива по поставщикам"
    ) .

  /* очистка складского архива по поставщикам, начиная с выбранной даты */
  run cb-doclslib-log in this-procedure
    (input substitute("Очистка архива по товарам начиная с номера &1"
                     ,v-last-fact-order
                     )
    ) .
  run trg/ah-clicl.p
    (input p-obj-type        /* p-obj-type        */
    ,input p-obj-code        /* p-obj-code        */
    ,input v-last-fact-order /* p-last-fact-order */
    ,input 0                 /* p-cut-fact-order  */
    ,input ""                /* p-file-name       */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Складской архив по поставщикам" skip
      "Объект" p-obj-type p-obj-code skip
      "Ошибка при вызове процедуры clear-archives" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value . /* --->>>--- */
  end.

  run show-action in this-procedure
    (input "Очистка отложенных заданий"
    ) .

  run doclslib-clear-batch-process in this-procedure
    (input {&btpr-type-ahsp} /* p-bp_type */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Складской архив по поставщикам" skip
      "Объект" p-obj-type p-obj-code skip
      "Ошибка при вызове процедуры doclslib-clear-batch-process" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value . /* --->>>--- */
  end.

  /* выводим документы, по которым будет вести расчет в текстовый файл */
  run doclslib-export-doc-list in this-procedure
    (input p-obj-type  /* p-obj-type        */
    ,input p-obj-code  /* p-obj-code        */
    ,input substitute('calcahsp_&1_&2_doc_list.txt', p-obj-type, p-obj-code)
    ,input "Расчет складского архива по поставщикам"
    ) .

  run show-action in this-procedure
    (input "Расчет складского архива по поставщикам"
    ) .

  /* расчет складского архива по поставщикам */
  run doclslib-calc-ahsp in this-procedure
    (input this-procedure /* p-log-handle    */
    ,input p-obj-type     /* p-obj-type      */
    ,input p-obj-code     /* p-obj-code      */
    ,input ?              /* p-cut-date      */
    ,input true           /* p-update-recalc */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Складской архив по поставщикам" skip
      "Объект" p-obj-type p-obj-code skip
      "Ошибка при вызове процедуры process-doc-list" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value . /* --->>>--- */
  end.

  /* сохраняем информацию о том, что объект рассчитан */
  run clntattr-delete in this-procedure
    (input  p-obj-type        /* p-obj-type */
    ,input  p-obj-code        /* p-obj-code */
    ,input  {&attr-ahsp-calc} /* p-code     */
    ,output v-attr-deleted    /* p-deleted  */
    ) .
  if v-attr-deleted = true
  then do:
    run cb-doclslib-log in this-procedure
      (input "Удалён признак необходимости перерасчёта"
      ) .
  end.

  /* удаляем информацию о том, что требуется перерасчет архива */
  run clntattr-delete in this-procedure
    (input  p-obj-type               /* p-obj-type */
    ,input  p-obj-code               /* p-obj-code */
    ,input  {&attr-ahsp-recalc-date} /* p-code     */
    ,output v-attr-deleted           /* p-deleted  */
    ) .
  if v-attr-deleted = true
  then do:
    run cb-doclslib-log in this-procedure
      (input "Удалена дата перерасчёта"
      ) .
  end.

  run cb-doclslib-log in this-procedure
    (input substitute("Окончание перерасчёта архива с даты &1"
                     ,string(v-last-fact-date, '99/99/9999':u)
                     )
    ) .
  run show-action in this-procedure
    (input "Расчет складского архива по поставщикам закончен"
    ) .

  /* записываем в протокол информацию о том, что объект рассчитан */
  run log-information in this-procedure
    (input p-obj-type /* p-obj-type */
    ,input p-obj-code /* p-obj-code */
    ,input "stop"     /* p-message  */
    ) .

  run utl/arhiscr.p
    (input  p-obj-type                   /* p-obj-type              */
    ,input  p-obj-code                   /* p-obj-code              */
    ,input  {&btpr-type-ahsp}            /* p-archive-type          */
    ,input  {&archive-history-calc-stop} /* p-action-type           */
    ,input  ""                           /* p-file-name             */
    ,input  ""                           /* p-file-md5              */
    ,input  0                            /* p-file-invalid-chip-num */
    ,input  ""                           /* p-source-type           */
    ,input  ""                           /* p-source-ref            */
    ,input  p-last-fact-date             /* p-source-date           */
    ,output v-create-chip-num            /* p-create-chip-num       */
    ) .
end.

procedure cb-doclslib-log :

  define input parameter p-message  as character no-undo .

  define variable v-log-file-name as character no-undo .

  assign
    v-log-file-name = substitute("calcahsp_&1_&2.txt", p-obj-type, p-obj-code)
  .

  do
  on error undo, return error return-value
  :
    output stream slog to value(v-log-file-name) append .
    export stream slog
      p-obj-type
      p-obj-code
      cur-time-string-sec()
      p-message .
    output stream slog close .
  end.

end procedure. /* cb-doclslib-log */


procedure show-action :

  define input parameter p-message  as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-action = p-message
    .
    display
      v-action with frame a .
  end.

end procedure. /* show-action */


procedure log-information :

  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-message  as character no-undo .

  do
  on error undo, return error return-value
  :
    output stream slog to objahsp.log append .
    export stream slog
      p-obj-type
      p-obj-code
      cur-time-string()
      p-message .
    output stream slog close .
  end.

end procedure. /* log-information */