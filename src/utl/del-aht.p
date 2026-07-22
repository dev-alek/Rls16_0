block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: del-aht.p $
$Archive: utl/del-aht.p $

Удаление складского архива по типам приобретени

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 12/22/03

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-aht.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/del-aht.p $":U .
define variable vss-description as character no-undo init "Удаление складского архива по типам приобретения".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ gbl/clntattr.i }
{ gbl/aht.i      }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define stream slog .

define buffer calc-aht-lock_batchprocess for ub.batchprocess .

define variable v-obj-type        like ub.gds-obj.obj-type no-undo .
define variable v-obj-code        like ub.gds-obj.obj-code no-undo .
define variable v-clear-archive   as logical   no-undo .
define variable v-new-start-date  as date      no-undo .
define variable v-new-detail-date as date      no-undo .
define variable v-file-name       as character no-undo .
define variable v-today           as date      no-undo .
define variable v-ok              as logical   no-undo .

do
on error undo, return error
:
  /* выбираем объект */
  define variable v-user-select as logical   no-undo .

  { gbl/getcntxt.i get }

  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
    v-obj-type
    v-obj-code
  }
  if v-user-select <> true
  then do:
    message
      "Объект не выбран"
      view-as alert-box information .
    return .
  end.

  define buffer restore-aht-lock_batchprocess for ub.batchprocess .
  /* блокировка процедуры восстановления складского архива */
  run gbl/lock-prc.p
    (input {&lock-prc-restore-aht}
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Восстановление складского архива по типам приобретения"
    ,input true
    ,buffer restore-aht-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент восстанавливается складской архив по типам приобретения" skip
        "Невозможно произвести восстановление складского архива по типам приобретения" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент восстанавливается складской архив по типам приобретения" .
  end.

  /* блокировка процедуры расчета складского архива по типам приобретения */
  run gbl/lock-prc.p
    (input {&lock-prc-calc-aht}
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
    ,input true
    ,buffer calc-aht-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент рассчитывается складской архив по типам приобретения" skip
        "Невозможно произвести удаление складского архива по типам приобретения" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент рассчитывается складской архив по типам приобретения" .
  end.

  define buffer buf_lock_gdsrenart_batchprocess for ub.batchprocess .

  run gbl/lockrngd.p
    (input  {&lock-prc-goods-rename-artic}  /* p-lock-gds-type   */
    ,input  {&lock-prc-subtype-disable}     /* p-sub-type        */
    ,buffer buf_lock_gdsrenart_batchprocess /* lock_batchprocess */
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при блокировании функции переименования артикула товара" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.

  define buffer buf_lock_gdsrengc_batchprocess for ub.batchprocess .

  run gbl/lockrngd.p
    (input  {&lock-prc-goods-rename-gds-code} /* p-lock-gds-type   */
    ,input  {&lock-prc-subtype-disable}       /* p-sub-type        */
    ,buffer buf_lock_gdsrengc_batchprocess    /* lock_batchprocess */
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при блокировании функции переименования кода товара" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.

  /* определяем текущую дату на объекте */
  { gbl/curobjdt.i
    v-obj-type
    v-obj-code
    v-today
  }

  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .

  define variable v-aht-calc          as logical   no-undo .
  define variable v-aht-del           as logical   no-undo .
  define variable v-aht-start-date    as date      no-undo .
  define variable v-aht-detail-date   as date      no-undo .
  define variable v-aht-recalc-date   as date      no-undo .

  run clntattr-value in this-procedure
    (input  v-obj-type              /* p-obj-type */
    ,input  v-obj-code              /* p-obj-code */
    ,input  {&attr-aht-calc}        /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-aht-calc = (lookup(v-attr-value, 'yes,true') > 0)
  .

  run clntattr-value in this-procedure
    (input  v-obj-type              /* p-obj-type */
    ,input  v-obj-code              /* p-obj-code */
    ,input  {&attr-aht-del}         /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-aht-del = (lookup(v-attr-value, 'yes,true') > 0)
  .

  run clntattr-value in this-procedure
    (input  v-obj-type              /* p-obj-type */
    ,input  v-obj-code              /* p-obj-code */
    ,input  {&attr-aht-start-date}  /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-aht-start-date = date(v-attr-value)
  .

  run clntattr-value in this-procedure
    (input  v-obj-type              /* p-obj-type */
    ,input  v-obj-code              /* p-obj-code */
    ,input  {&attr-aht-detail-date} /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-aht-detail-date = date(v-attr-value)
  .

  run clntattr-value in this-procedure
    (input  v-obj-type              /* p-obj-type */
    ,input  v-obj-code              /* p-obj-code */
    ,input  {&attr-aht-recalc-date} /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-aht-recalc-date = date(v-attr-value)
  .

  /* запрашиваем новую дату инициализации складского архива по типам приобретения */
  /* todo - показывать более подробную информацию о состоянии складского архива по типам приобретения */
  define variable v-month     as integer   no-undo .
  define variable v-new-month as integer   no-undo .
  define variable v-day       as integer   no-undo .
  define variable v-year      as integer   no-undo .

  assign
    v-month = month(v-aht-detail-date)
    v-year  = year(v-aht-detail-date)
  .
  assign
    v-month = v-month + 1
  .
  if v-month > 12
  then do:
    assign
      v-month = 1
      v-year  = v-year + 1
    .
  end.

  run gbl/d-inpmnt.w
    (input        "Введите месяц и год" /* p-title    */
    ,input        ?                     /* h-callback */
    ,input-output v-month               /* p-month    */
    ,input-output v-year                /* p-year     */
    ,output       v-ok                  /* p-ok       */
    ).

  if v-ok <> true
  then do:
    /* отказ от расчета складского архива */
    message
      "Дата очистки складского архива не задана" skip
      view-as alert-box information .
    undo, return error . /* --->>>--- */
  end.
  assign
    v-new-detail-date = date(v-month, 1, v-year)
  .

  /* запрашиваем у пользователя способ удаления складского архива */
  /* полная очистка или удаление подробной информации */
  define variable v-num as integer   no-undo .

  run gbl/d-askw.w
    (input "Вопрос" /* Заголовок окна */
    ,input "Выберите способ удаления складского архива по типам приобретения." + {&new-line}  /* Общее сообщение */
          + "Новая дата начала подробного складского архива по типам приобретения " + string(v-new-detail-date, '99/99/9999':u) + {&new-line}
          + "Сегодня " + string(v-today, '99/99/9999':u) + {&new-line}
    ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                /* второй символ - разделитель атрибутов в описании кнопок */
    ,input "Удаление подробной информации" + '^confirm|':u /* список названий кнопок  */
        + "Полная очистка складского архива" + '^confirm|':u
        + "Отказ"
    ,input "" + '|':u /* список описаний кнопок */
        + "" + '|':u
        + ""
    ,input 1 /* значение возвращаемое при нажатии enter */
    ,input 3 /* значение возвращаемое при нажатии escape */
    ,output v-num /* выбор пользователя */
    ).
  case v-num :
    when 1
    then do:
      assign
        v-clear-archive = false
      .
    end.
    when 2
    then do:
      assign
        v-clear-archive = true
      .
    end.
    when 3
    then do:
      /* */
      return .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при выборе способа очистки складского архива" skip
        view-as alert-box error .
      undo, return error .
    end.
  end case .


  if v-aht-calc = true
  then do:
    message
      "Складкой архив по типам приобретения" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Складской архив не рассчитан" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if v-aht-del = true
  then do:
    message
      "Складской архив по типам приобретения" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Остатки имеют неопределенное значение" skip
      "Возможные пути решения: повторная инициализация складского архива" skip
      "или восстановление складского архива из файла в случае ошибки удаления" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if (v-aht-start-date <> ?
     and v-aht-detail-date = ?)
  or (v-aht-start-date = ?
     and v-aht-detail-date <> ?)
  then do:
    message
      "Складской архив по типам приобретения" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Противоречивая информация в датах инициализации складского архива" skip
      "Дата начала складского архива по типам приобретения" string(v-aht-start-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по типам приобретения" string(v-aht-detail-date, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if  v-aht-recalc-date <> ?
  and v-aht-detail-date <> ?
  and v-aht-recalc-date < v-aht-detail-date
  then do:
    message
      "Складской архив по типам приобретения" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Дата перерасчета складского архива по товарам раньше, чем начало подробного складского архива" skip
      "Возможные пути решения: повторная инициализация складского архива" skip
      "Дата перерасчета складского архива по типам приобретения" string(v-aht-recalc-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по типам приобретения" v-aht-detail-date skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if v-clear-archive = true
  then do:
    assign
      v-new-start-date = v-new-detail-date
    .
  end.
  else do:
    if v-aht-start-date <> ?
    then do:
      assign
        v-new-start-date = v-aht-start-date
      .
    end.
    else do:
      run find-aht-start-date in this-procedure
        (input  v-obj-type        /* p-obj-type        */
        ,input  v-obj-code        /* p-obj-code        */
        ,input  v-new-detail-date /* p-new-detail-date */
        ,output v-new-start-date  /* p-new-start-date  */
        ) .
    end.
  end.

  /* проверяем, что складской архив по типам приобретения рассчитан до указанной даты */
  run trg/bt_aht.p
    (input v-obj-type        /* p-obj-type          */
    ,input v-obj-code        /* p-obj-code          */
    ,input v-new-detail-date /* p-last-date         */
    ,input true              /* p-check-act         */
    ,input v-cntxt-db-num    /* p-check-act-db-num  */
    ,input v-cntxt-userid    /* p-check-act-user-id */
    ) .

  /* создаем имя файла для сохранения удаляемого складского архива по типам приобретения */
  assign
    v-year  = year(v-new-detail-date)
    v-month = month(v-new-detail-date)
    v-day   = day(v-new-detail-date)
  .

  assign
    v-file-name = 'ahtdel':u
                + '_':u
                + (if v-obj-type = {&stock} then 'stock':u else 'shop':u)
                + '_':u
                + string(v-obj-code)
                + '_':u
                + string(v-year, '9999':u)
                + string(v-month, '99':u)
                + string(v-day, '99':u)
                + '.txt'
  .


  /* запрашиваем подтверждение пользователя */
  assign
    v-ok = false
  .
  message
    "ВНИМАНИЕ!" skip
    "Последнее предупреждение перед удалением складского архива по типам приобретения." skip
    "" (if v-clear-archive = true then "ПОЛНАЯ ОЧИСТКА АРХИВОВ" else "УДАЛЕНИЕ ПОДРОБНОЙ ИНФОРМАЦИИ" ) skip
    "Старая дата начала складского архива по типам приобретения" string(v-aht-start-date, '99/99/9999':u) skip
    "Старая дата начала подробного складского архива по типам приобретения" string(v-aht-detail-date, '99/99/9999':u) skip
    "" skip
    "Новая дата начала складского архива по типам приобретения" string(v-new-start-date, '99/99/9999':u) skip
    "Новая дата начала подробного складского архива по типам приобретения" string(v-new-detail-date, '99/99/9999':u) skip
    "Сегодня" string(v-today, '99/99/9999':u) skip
    "Удаленные данные будут сохранены в файле" v-file-name skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    return .
  end.

  define variable v-start-time     as integer   no-undo .
  define variable v-current-time   as character no-undo .
  define variable v-current-action as character no-undo .
  define variable v-count          as integer   no-undo .
  define variable v-sub-action     as character no-undo .

  define frame a
    v-obj-type       label "Объект"
    v-obj-code       no-label skip
    v-current-action format "x(40)" no-label skip
    v-current-time   format "x(8)"  label "Время очистки складского архива" skip
    v-count          format ">>>,>>>,>>9" no-label skip
    v-sub-action     format "x(40)" no-label skip
    with view-as dialog-box side-labels three-d
    title "Удаление складского архива по типам приобретения"
    .

  assign
    v-start-time = time
  .
  view frame a .
  display
    v-obj-type
    v-obj-code
    with frame a .


  define variable v-fact-order           as decimal   no-undo .
  define variable v-shift-end-fact-order as decimal   no-undo .
  define variable v-day-end-fact-order   as decimal   no-undo .
  define variable v-archive-date         as date      no-undo .

  /* определяем fact-order для новых начальных остатков складского архива по типам приобретения */
  assign
    v-archive-date = v-new-detail-date - 1
  .
  run factord in this-procedure
    (input  v-archive-date          /* p-fact-date            */
    ,input  1                       /* p-fact-time            */
    ,input  1                       /* p-fact-num             */
    ,input  ?                       /* p-shift-date           */
    ,input  0                       /* p-shift-num            */
    ,input  false                   /* p-shift-on             */
    ,output v-fact-order            /* p-fact-order           */
    ,output v-shift-end-fact-order  /* p-shift-end-fact-order */
    ,output v-day-end-fact-order    /* p-day-end-fact-order   */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры factord"
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* создаем файл для резервного копирования складского архива по типам приобретения */
  run create-log-file in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input v-aht-start-date
    ,input v-aht-detail-date
    ,input v-new-start-date
    ,input v-new-detail-date
    ,input v-file-name
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании файла архивации" skip
      "Имя файла архивации" v-file-name skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* сохраняем складской архив по типам приобретения */
  run trg/ahtclr.p
    (input v-obj-type           /* p-obj-type         */
    ,input v-obj-code           /* p-obj-code         */
    ,input 0                    /* p-last-fact-order  */
    ,input v-day-end-fact-order /* p-cut-fact-order   */
    ,input v-file-name          /* v-export-file-name */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при cохранении складского архива по типам приобретения"
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* закрываем файл архивации */
  run close-log-file in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input v-aht-start-date
    ,input v-aht-detail-date
    ,input v-new-start-date
    ,input v-new-detail-date
    ,input v-file-name
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при закрытии файла архивации" skip
      "Имя файла архивации" v-file-name skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* определяем контрольную сумму файла */
  define variable v-md5-signature as character no-undo .
  run gbl/md5.p
    (input  v-file-name     /* p-file-name     */
    ,output v-md5-signature /* p-md5-signature */
    ) .

  define variable v-create-chip-num as integer   no-undo .
  define variable v-action-type     as character no-undo .

  if v-clear-archive = true
  then do:
    assign
      v-action-type = {&archive-history-delall-start}
    .
  end.
  else do:
    assign
      v-action-type = {&archive-history-deldet-start}
    .
  end.

  run utl/arhiscr.p
    (input  v-obj-type        /* p-obj-type              */
    ,input  v-obj-code        /* p-obj-code              */
    ,input  {&btpr-type-aht}  /* p-archive-type          */
    ,input  v-action-type     /* p-action-type           */
    ,input  v-file-name       /* p-file-name             */
    ,input  v-md5-signature   /* p-file-md5              */
    ,input  0                 /* p-file-invalid-chip-num */
    ,input  ""                /* p-source-type           */
    ,input  ""                /* p-source-ref            */
    ,input  v-new-detail-date /* p-source-date           */
    ,output v-create-chip-num /* p-create-chip-num       */
    ) .

  /* на сменном объекте необходимо заблокировать смену */
  define buffer lock_shift-obj for ub.shift-obj .
  run factord-lock-shift in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  v-archive-date
    ,buffer lock_shift-obj
    ) no-error .
  if error-status :error
  then do:
   define variable v-err as character no-undo .
   v-err = substitute("Ошибка при блокировке смены на объекте &2&3 дата &1" , v-archive-date, v-obj-type , v-obj-code ) .
   run create-log-err in this-procedure
      ( v-obj-type  ,
        v-obj-code  ,
        v-file-name ,
        v-err ).
    undo, return error v-err .
  end.

  /* считываем недостающие остатки по складскому архиву на новую дату */
  run ahrstutl-init in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input v-archive-date
    ) .

  /* создаём остатки на новую дату */
  run ahrstutl-store in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input v-archive-date
    ) .

  do transaction
  on error undo, return error return-value
  :
    /* записываем дату, с которой существует складской архив по типам приобретения */
    run clntattr-write in this-procedure
      (input v-obj-type                               /* p-obj-type */
      ,input v-obj-code                               /* p-obj-code */
      ,input {&attr-aht-start-date}                   /* p-code     */
      ,input string(v-new-start-date, '99/99/9999':u) /* p-value    */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты инициализации складского архива" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    /* записываем дату, с которой существует подробный складской архив по типам приобретения */
    run clntattr-write in this-procedure
      (input v-obj-type                                /* p-obj-type */
      ,input v-obj-code                                /* p-obj-code */
      ,input {&attr-aht-detail-date}                   /* p-code     */
      ,input string(v-new-detail-date, '99/99/9999':u) /* p-value    */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты инициализации складского архива" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    /* складской архив помечается как восстанавливающийся */
    run clntattr-write in this-procedure
      (input v-obj-type       /* p-obj-type */
      ,input v-obj-code       /* p-obj-code */
      ,input {&attr-aht-rest} /* p-code     */
      ,input 'true':u         /* p-value    */
      ) .
  end.

  /* разрешаем расчёт складского архива */
  find current calc-aht-lock_batchprocess no-lock .

  if v-clear-archive = true
  then do:
    /* удаление складского архива до новой текущей даты */
    /* следует независимо удалять складской архив по дням и складской архив по сменам */
    run ahrstutl-clear-aht in this-procedure
      (input  v-obj-type     /* p-obj-type  */
      ,input  v-obj-code     /* p-obj-code  */
      ,input  v-archive-date /* p-fact-date */
      ) .
  end.
  else do:
    /* процедура сжатия складского архива по типам приобретения */
    run utl/cmpraht.p
      (input v-obj-type
      ,input v-obj-code
      ,input 0
      ,input v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при удалении складского архива по товару" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

  define variable v-delete-attr-aht-del as logical   no-undo .

  /* восстановление складского архива прошло успешно */
  /* удаляем признак того, что была ошибка при восстановлении/удалении складского архива */
  run clntattr-delete in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input {&attr-aht-rest}
    ,output v-delete-attr-aht-del
    ) .

  if v-clear-archive = true
  then do:
    assign
      v-action-type = {&archive-history-delall-stop}
    .
  end.
  else do:
    assign
      v-action-type = {&archive-history-deldet-stop}
    .
  end.

  run utl/arhiscr.p
    (input  v-obj-type        /* p-obj-type              */
    ,input  v-obj-code        /* p-obj-code              */
    ,input  {&btpr-type-arh}  /* p-archive-type          */
    ,input  v-action-type     /* p-action-type           */
    ,input  ""                /* p-file-name             */
    ,input  ""                /* p-file-md5              */
    ,input  0                 /* p-file-invalid-chip-num */
    ,input  ""                /* p-source-type           */
    ,input  ""                /* p-source-ref            */
    ,input  v-new-detail-date /* p-source-date           */
    ,output v-create-chip-num /* p-create-chip-num       */
    ) .

  message
    "Складской архив по типам приобретения" skip
    "Объект" v-obj-type v-obj-code skip
    "Удаление складского архива успешно закончилось" skip
    "Сохраните файл" v-file-name "в надёжном месте" skip
    "Затем вы можете восстановить складской архив на основании файла" skip
    "На объекте существует складской архив по типам приобретения с даты" string(v-new-start-date, '99/99/9999':u) skip
    "На объекте существуют подробный складской архив по типам приобретения с даты" string(v-new-detail-date, '99/99/9999':u) skip
    view-as alert-box information .
end.

procedure create-log-file :

  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-aht-start-date  as date      no-undo .
  define input  parameter p-aht-detail-date as date      no-undo .
  define input  parameter p-new-start-date  as date      no-undo .
  define input  parameter p-new-detail-date as date      no-undo .
  define input  parameter p-file-name       as character no-undo .

  do
  on error undo, return error
  :
    output stream slog to value(p-file-name) .
    export stream slog 'archive-log-version':u '2.1':u .
    export stream slog 'obj-type':u            p-obj-type .
    export stream slog 'obj-code':u            string(p-obj-code) .
    export stream slog 'old-start-date':u      string(p-aht-start-date, '99/99/9999':u ) .
    export stream slog 'old-detail-date':u     string(p-aht-detail-date, '99/99/9999':u ) .
    export stream slog 'new-start-date':u      string(p-new-start-date, '99/99/9999':u ) .
    export stream slog 'new-detail-date':u     string(p-new-detail-date, '99/99/9999':u ) .
    output stream slog close .
  end.

end procedure. /* create-log-file */

procedure close-log-file :

  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-aht-start-date  as date      no-undo .
  define input  parameter p-aht-detail-date as date      no-undo .
  define input  parameter p-new-start-date  as date      no-undo .
  define input  parameter p-new-detail-date as date      no-undo .
  define input  parameter p-file-name       as character no-undo .

  do
  on error undo, return error
  :
    output stream slog to value(p-file-name) append .
    export stream slog 'end-of-log':u .
    export stream slog 'archive-log-version':u '2.1':u .
    export stream slog 'obj-type':u            p-obj-type .
    export stream slog 'obj-code':u            string(p-obj-code) .
    export stream slog 'old-start-date':u      string(p-aht-start-date, '99/99/9999':u ) .
    export stream slog 'old-detail-date':u     string(p-aht-detail-date, '99/99/9999':u ) .
    export stream slog 'new-start-date':u      string(p-new-start-date, '99/99/9999':u ) .
    export stream slog 'new-detail-date':u     string(p-new-detail-date, '99/99/9999':u ) .
    export stream slog '.':u                   .
    output stream slog close .
  end.

end procedure. /* create-log-file */

procedure find-aht-start-date :

  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-new-detail-date as date      no-undo .
  define output parameter p-new-start-date  as date      no-undo .

  do
  on error undo, return error return-value
  :

    assign
      p-new-start-date = p-new-detail-date
    .

    define buffer buf_aht-stk for ub.aht-stk .
    find first buf_aht-stk no-lock
      where buf_aht-stk.obj-type  = p-obj-type
        and buf_aht-stk.obj-code  = p-obj-code
        and buf_aht-stk.stk-type  = {&aht-stk-normal}
      use-index pi
      no-error .
    if  available buf_aht-stk
    and buf_aht-stk.fact-date < p-new-start-date
    then do:
      assign
        p-new-start-date = buf_aht-stk.fact-date
      .
    end.
  end.

end procedure. /* find-aht-start-date */


procedure show-action :
  do
  on error undo, return error
  :
    define input parameter p-action as character no-undo .

    assign
      v-current-time = string(time - v-start-time, "HH:MM:SS")
      v-current-action = p-action
    .
    display
      v-current-time
      v-current-action
      with frame a.
  end.
end procedure. /* show-action */


procedure show-count :
  define input  parameter p-count      as integer   no-undo .
  define input  parameter p-sub-action as character no-undo .

  do
  on error undo, return error
  :
    assign
      v-current-time = string(time - v-start-time, "HH:MM:SS")
      v-count        = p-count
      v-sub-action   = p-sub-action
    .
    display
      v-current-time
      v-count
      v-sub-action
      with frame a.
  end.
end procedure. /* show-action */


procedure ahrstutl-init :

  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .

  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_goods   for ub.goods .

  define variable v-shift-on             as logical   no-undo .
  define variable v-shift-date           as date      no-undo .
  define variable v-shift-num            as integer   no-undo .
  define variable v-day-end-fact-order   as decimal   no-undo .
  define variable v-shift-end-fact-order as decimal   no-undo .

  define variable v-sum-type-list as character no-undo .

  do
  on error undo, return error
  :
    run factord-cut-archive in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-fact-date
      ,output v-shift-on
      ,output v-shift-date
      ,output v-shift-num
      ,output v-day-end-fact-order
      ,output v-shift-end-fact-order
      ) .

    define variable v-ind as integer   no-undo .

    run show-action in this-procedure
      (input "Остаток по объекту"
      ).

    run ahrstutl-tot-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .

    /* считываем значение остатка по объекту на определенный момент времени */
    do v-ind = 1 to num-entries(v-sum-type-list)
    :
      run ahrstutl-init-tot in this-procedure
        (input p-obj-type                    /* p-obj-type               */
        ,input p-obj-code                    /* p-obj-code               */
        ,input entry(v-ind, v-sum-type-list) /* p-sum-type               */
        ,input v-day-end-fact-order          /* p-aht-stk-tot-fact-order */
        ) .
    end.

    run show-action in this-procedure
      (input "Остаток по товарам"
      ).

    /* считываем предыдущее (текущее) и все более поздние значения оборота по строке */
    define variable v-total-count as integer   no-undo .

    for each buf_gds-obj no-lock
      where buf_gds-obj.obj-type = p-obj-type
        and buf_gds-obj.obj-code = p-obj-code
    on error undo, return error
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + string(buf_gds-obj.artic)
          ).
      end.

      find first buf_goods no-lock
        where buf_goods.artic     = buf_gds-obj.artic
          and buf_goods.prod-type = buf_gds-obj.prod-type
          and buf_goods.prod-code = buf_gds-obj.prod-code
        .
      run ahrstutl-line-sum-type-list in this-procedure
        (input buf_goods.gds-type = {&gds-goods}
        ,output v-sum-type-list
        ) .
      do v-ind = 1 to num-entries(v-sum-type-list)
      :
        run ahrstutl-init-line in this-procedure
          (input p-obj-type                    /* p-obj-type                */
          ,input p-obj-code                    /* p-obj-code                */
          ,input buf_gds-obj.gds-code          /* p-gds-code                */
          ,input entry(v-ind, v-sum-type-list) /* p-sum-type                */
          ,input v-day-end-fact-order          /* p-aht-stk-line-fact-order */
          ) .
      end.
    end.
  end.
end procedure. /* ahrstutl-init */


procedure ahrstutl-init-tot :

  define input  parameter p-obj-type                 as character no-undo .
  define input  parameter p-obj-code                 as integer   no-undo .
  define input  parameter p-sum-type                 as character no-undo .
  define input  parameter p-aht-stk-tot-fact-order   as decimal   no-undo .

  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  define buffer buf_temp-aht-stk-tot for temp-aht-stk-tot .

  do
  on error undo, return error return-value
  :
    find last buf_aht-stk-tot no-lock
      where buf_aht-stk-tot.obj-type   = p-obj-type
        and buf_aht-stk-tot.obj-code   = p-obj-code
        and buf_aht-stk-tot.sum-type   = p-sum-type
        and buf_aht-stk-tot.fact-order <= p-aht-stk-tot-fact-order
      use-index category
      no-error .
    if available buf_aht-stk-tot
    and buf_aht-stk-tot.fact-order <> p-aht-stk-tot-fact-order
    then do:
      find first buf_temp-aht-stk-tot
        where buf_temp-aht-stk-tot.obj-type   = buf_aht-stk-tot.obj-type
          and buf_temp-aht-stk-tot.obj-code   = buf_aht-stk-tot.obj-code
          and buf_temp-aht-stk-tot.fact-order = p-aht-stk-tot-fact-order
          and buf_temp-aht-stk-tot.sum-type   = buf_aht-stk-tot.sum-type
        no-error .
      if not available buf_temp-aht-stk-tot
      then do:
        create buf_temp-aht-stk-tot .
        assign
          &scop fp1 buf_temp-aht-stk-tot.
          &scop fp2 = buf_aht-stk-tot.
          {&aht-stk-tot-pair-list}
          buf_temp-aht-stk-tot.fact-order = p-aht-stk-tot-fact-order
        .
      end.

      assign
        buf_temp-aht-stk-tot.fact-qnty = buf_temp-aht-stk-tot.fact-qnty
                                       + buf_aht-stk-tot.fact-qnty
        &scop FT1    buf_temp-aht-stk-tot.cost-
        &scop FTs1
        &scop FT2    = buf_temp-aht-stk-tot.cost-
        &scop FTs2
        &scop FT3    + buf_aht-stk-tot.cost-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
        &scop FT1    buf_temp-aht-stk-tot.crsa-
        &scop FTs1
        &scop FT2    = buf_temp-aht-stk-tot.crsa-
        &scop FTs2
        &scop FT3    + buf_aht-stk-tot.crsa-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
        &scop FT1    buf_temp-aht-stk-tot.sale-
        &scop FTs1
        &scop FT2    = buf_temp-aht-stk-tot.sale-
        &scop FTs2
        &scop FT3    + buf_aht-stk-tot.sale-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
      .
    end.
  end.

end procedure. /* ahrstutl-init-tot */


procedure ahrstutl-init-line :

  define input  parameter p-obj-type                as character no-undo .
  define input  parameter p-obj-code                as integer   no-undo .
  define input  parameter p-gds-code                as integer   no-undo .
  define input  parameter p-sum-type                as character no-undo .
  define input  parameter p-aht-stk-line-fact-order as decimal   no-undo .

  define buffer buf_aht-stk-line for ub.aht-stk-line .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .

  do
  on error undo, return error return-value
  :
    find last buf_aht-stk-line no-lock
      where buf_aht-stk-line.obj-type   = p-obj-type
        and buf_aht-stk-line.obj-code   = p-obj-code
        and buf_aht-stk-line.gds-code   = p-gds-code
        and buf_aht-stk-line.sum-type   = p-sum-type
        and buf_aht-stk-line.fact-order <= p-aht-stk-line-fact-order
      use-index category
      no-error .
    if available buf_aht-stk-line
    and buf_aht-stk-line.fact-order <> p-aht-stk-line-fact-order
    then do:
      find first buf_temp-aht-stk-line
        where buf_temp-aht-stk-line.obj-type   = buf_aht-stk-line.obj-type
          and buf_temp-aht-stk-line.obj-code   = buf_aht-stk-line.obj-code
          and buf_temp-aht-stk-line.gds-code   = buf_aht-stk-line.gds-code
          and buf_temp-aht-stk-line.fact-order = p-aht-stk-line-fact-order
          and buf_temp-aht-stk-line.sum-type   = buf_aht-stk-line.sum-type
        no-error .
      if not available buf_temp-aht-stk-line
      then do:
        create buf_temp-aht-stk-line .
        assign
          &scop fp1 buf_temp-aht-stk-line.
          &scop fp2 = buf_aht-stk-line.
          {&aht-stk-line-pair-list}
          buf_temp-aht-stk-line.fact-order = p-aht-stk-line-fact-order
        .
      end.

      assign
        buf_temp-aht-stk-line.fact-qnty = buf_temp-aht-stk-line.fact-qnty
                                        + buf_aht-stk-line.fact-qnty
        &scop FT1    buf_temp-aht-stk-line.cost-
        &scop FTs1
        &scop FT2    = buf_temp-aht-stk-line.cost-
        &scop FTs2
        &scop FT3    + buf_aht-stk-line.cost-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
        &scop FT1    buf_temp-aht-stk-line.crsa-
        &scop FTs1
        &scop FT2    = buf_temp-aht-stk-line.crsa-
        &scop FTs2
        &scop FT3    + buf_aht-stk-line.crsa-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
        &scop FT1    buf_temp-aht-stk-line.sale-
        &scop FTs1
        &scop FT2    = buf_temp-aht-stk-line.sale-
        &scop FTs2
        &scop FT3    + buf_aht-stk-line.sale-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
      .
    end.
  end.

end procedure. /* ahrstutl-init-line */



procedure ahrstutl-store :

  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .

  define buffer buf_temp-aht-stk-tot  for temp-aht-stk-tot .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  define buffer buf_aht-stk-tot       for ub.aht-stk-tot .
  define buffer buf_aht-stk-line      for ub.aht-stk-line .

  define variable v-shift-on             as logical   no-undo .
  define variable v-shift-date           as date      no-undo .
  define variable v-shift-num            as integer   no-undo .
  define variable v-day-end-fact-order   as decimal   no-undo .
  define variable v-shift-end-fact-order as decimal   no-undo .

  do
  on error undo, return error return-value
  :
    run factord-cut-archive in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-fact-date
      ,output v-shift-on
      ,output v-shift-date
      ,output v-shift-num
      ,output v-day-end-fact-order
      ,output v-shift-end-fact-order
      ) .

    run show-action in this-procedure
      (input "Создание остатка"
      ).

    /* считываем предыдущее (текущее) и все более поздние значения оборота по строке */
    define variable v-total-count as integer   no-undo .

    for each buf_temp-aht-stk-tot
    on error undo, return error
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Остаток по объекту"
          ).
      end.

       create buf_aht-stk-tot .
      assign
        &scop fp1   buf_aht-stk-tot.
        &scop fp2   = buf_temp-aht-stk-tot.
        {&aht-stk-tot-pair-list}
        buf_aht-stk-tot.fact-qnty = buf_temp-aht-stk-tot.fact-qnty
        &scop fp1   buf_aht-stk-tot.cost-
        &scop fps1
        &scop fp2   = buf_temp-aht-stk-tot.cost-
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
        &scop fp1   buf_aht-stk-tot.crsa-
        &scop fps1
        &scop fp2   = buf_temp-aht-stk-tot.crsa-
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
        &scop fp1   buf_aht-stk-tot.sale-
        &scop fps1
        &scop fp2   = buf_temp-aht-stk-tot.sale-
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
      .
    end.

    assign
      v-total-count = 0
    .

    for each buf_temp-aht-stk-line
    on error undo, return error
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Код товара" + string(buf_temp-aht-stk-line.gds-code)
          ).
      end.

      create buf_aht-stk-line .
      assign
        &scop fp1   buf_aht-stk-line.
        &scop fp2   = buf_temp-aht-stk-line.
        {&aht-stk-line-pair-list}
        buf_aht-stk-line.fact-qnty = buf_temp-aht-stk-line.fact-qnty
        &scop fp1   buf_aht-stk-line.cost-
        &scop fps1
        &scop fp2   = buf_temp-aht-stk-line.cost-
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
        &scop fp1   buf_aht-stk-line.crsa-
        &scop fps1
        &scop fp2   = buf_temp-aht-stk-line.crsa-
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
        &scop fp1   buf_aht-stk-line.sale-
        &scop fps1
        &scop fp2   = buf_temp-aht-stk-line.sale-
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
      .
    end.
  end.

end procedure. /* ahrstutl-store */


procedure ahrstutl-clear-aht :

  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-fact-date        as date      no-undo .

  define buffer buf_aht-ot-tot   for ub.aht-ot-tot .
  define buffer buf_aht-ot-line  for ub.aht-ot-line .
  define buffer buf_aht-stk-tot  for ub.aht-stk-tot .
  define buffer buf_aht-stk-line for ub.aht-stk-line .

  define variable v-shift-on                as logical   no-undo .
  define variable v-shift-date              as date      no-undo .
  define variable v-shift-num               as integer   no-undo .
  define variable v-day-end-fact-order      as decimal   no-undo .
  define variable v-shift-end-fact-order    as decimal   no-undo .
  define variable v-ind as integer no-undo .

  do
  on error undo, return error return-value
  :

    run factord-cut-archive in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-fact-date
      ,output v-shift-on
      ,output v-shift-date
      ,output v-shift-num
      ,output v-day-end-fact-order
      ,output v-shift-end-fact-order
      ) .

    assign
      v-day-end-fact-order   = v-day-end-fact-order   - {&arh-delta}
      v-shift-end-fact-order = v-shift-end-fact-order - {&arh-delta}
    .

    run show-action in this-procedure
      (input "Удаление оборота по документам"
      ).
    assign
      v-ind = 0
    .

    for each buf_aht-ot-tot
      where buf_aht-ot-tot.obj-type   = p-obj-type
        and buf_aht-ot-tot.obj-code   = p-obj-code
        and buf_aht-ot-tot.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_aht-ot-tot.doc-code)
          ).
      end.

      delete buf_aht-ot-tot .
    end.

    run show-action in this-procedure
      (input "Удаление оборота по строкам документов"
      ).
    assign
      v-ind = 0
    .

    for each buf_aht-ot-line
      where buf_aht-ot-line.obj-type   = p-obj-type
        and buf_aht-ot-line.obj-code   = p-obj-code
        and buf_aht-ot-line.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_aht-ot-line.doc-code)
                  + " Код товара " + string(buf_aht-ot-line.gds-code)
          ).
      end.

      delete buf_aht-ot-line .
    end.

    run show-action in this-procedure
      (input "Удаление остатка по объекту"
      ).
    assign
      v-ind = 0
    .

    for each buf_aht-stk-tot
      where buf_aht-stk-tot.obj-type   = p-obj-type
        and buf_aht-stk-tot.obj-code   = p-obj-code
        and buf_aht-stk-tot.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        define variable v-fact-date as date      no-undo .

        run factord-to-date in this-procedure
          (input  buf_aht-stk-tot.fact-order
          ,output v-fact-date
          ) .
        run show-count in this-procedure
          (input v-ind
          ,input "Дата " + string(v-fact-date, '99/99/9999':U )
          ).
      end.

      delete buf_aht-stk-tot .
    end.

    run show-action in this-procedure
      (input "Удаление остатка по товарам на объекте"
      ).
    assign
      v-ind = 0
    .

    for each buf_aht-stk-line
      where buf_aht-stk-line.obj-type   = p-obj-type
        and buf_aht-stk-line.obj-code   = p-obj-code
        and buf_aht-stk-line.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Код товара " + string(buf_aht-stk-line.gds-code)
          ).
      end.

      delete buf_aht-stk-line .
    end.
  end.

end procedure. /* ahrstutl-clear-aht */


procedure ahrstutl-tot-sum-type-list :

  define output parameter p-sum-type-list as character no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-ind                    as integer   no-undo .
    define variable v-num-entries-TDEDT_List as integer   no-undo .

    assign
      v-num-entries-TDEDT_List = num-entries({&TDEDT_List})
    .

    assign
      p-sum-type-list =                 {&aht-repayment}
                      + {&comma-char} + {&aht-cons_acc}
                      + {&comma-char} + {&aht-cons_benf}
                      + {&comma-char} + {&aht-resp_stor}
                      + {&comma-char} + {&aht-old_cons}
                      + {&comma-char} + {&aht-service}
    .

    define variable v-ext-sum-type as character no-undo .

    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      run aht_get-stk-sum-type in this-procedure
        (input  {&aht-repayment}
        ,input  entry(v-ind, {&TDEDT_List})
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + v-ext-sum-type
      .

      run aht_get-stk-sum-type in this-procedure
        (input  {&aht-cons_acc}
        ,input  entry(v-ind, {&TDEDT_List})
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + v-ext-sum-type
      .

      run aht_get-stk-sum-type in this-procedure
        (input  {&aht-cons_benf}
        ,input  entry(v-ind, {&TDEDT_List})
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + v-ext-sum-type
      .

      run aht_get-stk-sum-type in this-procedure
        (input  {&aht-resp_stor}
        ,input  entry(v-ind, {&TDEDT_List})
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + v-ext-sum-type
      .

      run aht_get-stk-sum-type in this-procedure
        (input  {&aht-old_cons}
        ,input  entry(v-ind, {&TDEDT_List})
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + v-ext-sum-type
      .

      run aht_get-stk-sum-type in this-procedure
        (input  {&aht-service}
        ,input  entry(v-ind, {&TDEDT_List})
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + v-ext-sum-type
      .
    end.
  end.

end procedure. /* ahrstutl-tot-sum-type-list */


procedure ahrstutl-line-sum-type-list :

  define input  parameter p-gds-goods     as logical   no-undo .
  define output parameter p-sum-type-list as character no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-ind                    as integer   no-undo .
    define variable v-num-entries-TDEDT_List as integer   no-undo .

    assign
      v-num-entries-TDEDT_List = num-entries({&TDEDT_List})
    .

    assign
      p-sum-type-list =                 {&aht-repayment}
                      + {&comma-char} + {&aht-cons_acc}
                      + {&comma-char} + {&aht-cons_benf}
                      + {&comma-char} + {&aht-resp_stor}
                      + {&comma-char} + {&aht-old_cons}
                      + {&comma-char} + {&aht-service}
    .

    define variable v-ext-sum-type as character no-undo .

    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      run aht_get-stk-sum-type in this-procedure
        (input  {&aht-repayment}
        ,input  entry(v-ind, {&TDEDT_List})
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + v-ext-sum-type
      .

      run aht_get-stk-sum-type in this-procedure
        (input  {&aht-cons_acc}
        ,input  entry(v-ind, {&TDEDT_List})
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + v-ext-sum-type
      .

      run aht_get-stk-sum-type in this-procedure
        (input  {&aht-cons_benf}
        ,input  entry(v-ind, {&TDEDT_List})
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + v-ext-sum-type
      .

      run aht_get-stk-sum-type in this-procedure
        (input  {&aht-resp_stor}
        ,input  entry(v-ind, {&TDEDT_List})
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + v-ext-sum-type
      .

      run aht_get-stk-sum-type in this-procedure
        (input  {&aht-old_cons}
        ,input  entry(v-ind, {&TDEDT_List})
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + v-ext-sum-type
      .

      run aht_get-stk-sum-type in this-procedure
        (input  {&aht-service}
        ,input  entry(v-ind, {&TDEDT_List})
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + v-ext-sum-type
      .
    end.
  end.

end procedure. /* ahrstutl-line-sum-type-list */

procedure create-log-err :

  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-file-name as character no-undo .
  define input  parameter p-err       as character no-undo .

  do
  on error undo, return error
  :
    output stream slog to value(p-file-name) .
    export stream slog 'archive-log-version':u '2.1':u .
    export stream slog 'obj-type':u            p-obj-type .
    export stream slog 'obj-code':u            string(p-obj-code) .
    export stream slog  string(p-err) .

    output stream slog close .
  end.

end procedure. /* create-log-err */