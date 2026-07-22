block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: del-arh.p $
$Archive: utl/del-arh.p $

Удаление складского архива по товарам за определенный период с выгрузкой в файл

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
define variable vss-workfile    as character no-undo init "$Workfile: del-arh.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/del-arh.p $":U .
define variable vss-description as character no-undo init "Удаление складского архива по товарам за определенный период с выгрузкой в файл".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ gbl/clntattr.i }
{ gbl/arh.i      }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define stream slog .

define buffer calc-arh-lock_batchprocess for ub.batchprocess .

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

  define buffer restore-arh-lock_batchprocess for ub.batchprocess .
  /* блокировка процедуры восстановления складского архива */
  run gbl/lock-prc.p
    (input {&lock-prc-restore-arh}
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Восстановление складского складского архива по товарам"
    ,input true
    ,buffer restore-arh-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент восстанавливается складской архив по товарам" skip
        "Невозможно произвести восстановление складского архива по товарам" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент восстанавливается складской архив по товарам" .
  end.

  /* блокировка процедуры расчета складского архива по товарам */
  run gbl/lock-prc.p
    (input {&lock-prc-calc-arh}
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Расчет складского архивов по товарам"
    ,input true
    ,buffer calc-arh-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент рассчитывается складской архив по товарам" skip
        "Невозможно произвести удаление складского архива по товарам" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент рассчитывается складской архив по товарам" .
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

  define variable v-arh-calc          as logical   no-undo .
  define variable v-arh-del           as logical   no-undo .
  define variable v-arh-start-date    as date      no-undo .
  define variable v-arh-detail-date   as date      no-undo .
  define variable v-arh-recalc-date   as date      no-undo .

  run clntattr-value in this-procedure
    (input  v-obj-type              /* p-obj-type */
    ,input  v-obj-code              /* p-obj-code */
    ,input  {&attr-arh-calc}        /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-arh-calc = (lookup(v-attr-value, 'yes,true') > 0)
  .

  run clntattr-value in this-procedure
    (input  v-obj-type              /* p-obj-type */
    ,input  v-obj-code              /* p-obj-code */
    ,input  {&attr-arh-del}         /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-arh-del = (lookup(v-attr-value, 'yes,true') > 0)
  .

  run clntattr-value in this-procedure
    (input  v-obj-type              /* p-obj-type */
    ,input  v-obj-code              /* p-obj-code */
    ,input  {&attr-arh-start-date}  /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-arh-start-date = date(v-attr-value)
  .

  run clntattr-value in this-procedure
    (input  v-obj-type              /* p-obj-type */
    ,input  v-obj-code              /* p-obj-code */
    ,input  {&attr-arh-detail-date} /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-arh-detail-date = date(v-attr-value)
  .

  run clntattr-value in this-procedure
    (input  v-obj-type              /* p-obj-type */
    ,input  v-obj-code              /* p-obj-code */
    ,input  {&attr-arh-recalc-date} /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-arh-recalc-date = date(v-attr-value)
  .

  /* запрашиваем новую дату инициализации складского архива по товарам */
  /* todo - показывать более подробную информацию о состоянии складского архива по товарам */
  define variable v-month     as integer   no-undo .
  define variable v-new-month as integer   no-undo .
  define variable v-day       as integer   no-undo .
  define variable v-year      as integer   no-undo .

  assign
    v-month = month(v-arh-detail-date)
    v-year  = year(v-arh-detail-date)
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
    (input        "Введите месяц и год"
    ,input        ?
    ,input-output v-month
    ,input-output v-year
    ,output       v-ok
    ).

  if v-ok <> true
  then do:
    /* отказ от расчета складского архива по товарам */
    message
      "Дата очистки складского архива по товарам не задана" skip
      view-as alert-box information .
    undo, return error . /* --->>>--- */
  end.
  assign
    v-new-detail-date = date(v-month, 1, v-year)
  .

  /* запрашиваем у пользователя способ удаления складского архива по товарам */
  /* полная очистка или удаление подробной информации */
  define variable v-num as integer   no-undo .

  run gbl/d-askw.w
    (input "Вопрос" /* Заголовок окна */
    ,input "Выберите способ удаления складского архива по товарам" + {&new-line}  /* Общее сообщение */
          + "Новая дата начала подробного складского архива по товарам " + string(v-new-detail-date, '99/99/9999':u) + {&new-line}
          + "Сегодня " + string(v-today, '99/99/9999':u) + {&new-line}
    ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                /* второй символ - разделитель атрибутов в описании кнопок */
    ,input "Удаление подробной информации" + '^confirm|':u /* список названий кнопок  */
        + "Полная очистка складского архива по товарам" + '^confirm|':u
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
        "Ошибка при выборе способа очистки складского архива по товарам" skip
        view-as alert-box error .
      undo, return error .
    end.
  end case .

  if v-arh-calc = true
  then do:
    message
      "Складской архив по товарам" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива по товарам" skip
      "Складской архив не рассчитан" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if v-arh-del = true
  then do:
    message
      "Складской архив по товарам" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Остатки имеют неопределенное значение" skip
      "Возможные пути решения: повторная инициализация складского архива" skip
      "или восстановление складского архива из файла в случае ошибки удаления" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if (v-arh-start-date <> ?
     and v-arh-detail-date = ?)
  or (v-arh-start-date = ?
     and v-arh-detail-date <> ?)
  then do:
    message
      "Невозможно произвести удаление складского архива по товарам" skip
      "Складской архив по товарам" skip
      "Объект" v-obj-type v-obj-code skip
      "Противоречивая информация в датах инициализации складского архива по товарам" skip
      "Дата начала складского архива по товарам" string(v-arh-start-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по товарам" string(v-arh-detail-date, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if  v-arh-recalc-date <> ?
  and v-arh-detail-date <> ?
  and v-arh-recalc-date < v-arh-detail-date
  then do:
    message
      "Невозможно произвести удаление складского архива по товарам" skip
      "Складской архив по товарам" skip
      "Объект" v-obj-type v-obj-code skip
      "Дата перерасчета складского архива по товарам раньше, чем начало подробного складского архива" skip
      "Возможные пути решения: повторная инициализация складского архива по товарам" skip
      "Дата перерасчета складского архива по товарам" string(v-arh-recalc-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по товарам" v-arh-detail-date skip
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
    if v-arh-start-date <> ?
    then do:
      assign
        v-new-start-date = v-arh-start-date
      .
    end.
    else do:
      run find-arh-start-date in this-procedure
        (input  v-obj-type        /* p-obj-type        */
        ,input  v-obj-code        /* p-obj-code        */
        ,input  v-new-detail-date /* p-new-detail-date */
        ,output v-new-start-date  /* p-new-start-date  */
        ) .
    end.
  end.

  /* проверяем, что складской архив по товарам рассчитан до указанной даты */
  run trg/bt_arh.p
    (input v-obj-type        /* p-obj-type          */
    ,input v-obj-code        /* p-obj-code          */
    ,input v-new-detail-date /* p-last-date         */
    ,input true              /* p-check-act         */
    ,input v-cntxt-db-num    /* p-check-act-db-num  */
    ,input v-cntxt-userid    /* p-check-act-user-id */
    ) .

  /* создаем имя файла для сохранения удаляемого складского архива по товарам */
  assign
    v-year  = year(v-new-detail-date)
    v-month = month(v-new-detail-date)
    v-day   = day(v-new-detail-date)
  .

  assign
    v-file-name = 'arhdel':u
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
    "Последнее предупреждение перед удалением складского архива по товарам" skip
    "" (if v-clear-archive = true then "ПОЛНАЯ ОЧИСТКА АРХИВОВ" else "УДАЛЕНИЕ ПОДРОБНОЙ ИНФОРМАЦИИ" ) skip
    "Старая дата начала складского архива по товарам" string(v-arh-start-date, '99/99/9999':u) skip
    "Старая дата начала подробного складского архива по товарам" string(v-arh-detail-date, '99/99/9999':u) skip
    "" skip
    "Новая дата начала складского архива по товарам" string(v-new-start-date, '99/99/9999':u) skip
    "Новая дата начала подробного складского архива по товарам" string(v-new-detail-date, '99/99/9999':u) skip
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
    title "Удаление складского архива по товарам"
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

  /* определяем fact-order для новых начальных остатков складского архива по товарам */
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

  /* создаем файл для резервного копирования складского архива по товарам */
  run create-log-file in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input v-arh-start-date
    ,input v-arh-detail-date
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

  /* сохраняем складской архив по товарам */
  run trg/arhclr.p
    (input v-obj-type
    ,input v-obj-code
    ,input 0
    ,input v-day-end-fact-order
    ,input v-file-name
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при cохранении складского архива по товарам"
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* закрываем файл архивации */
  run close-log-file in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input v-arh-start-date
    ,input v-arh-detail-date
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
    ,input  {&btpr-type-arh}  /* p-archive-type          */
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
   v-err = substitute("Ошибка при блокировке смены на объекте &2&3 дата &1" , v-archive-date, v-obj-type , v-obj-code  ) .
   run create-log-err in this-procedure
      ( v-obj-type ,
        v-obj-code ,
        v-file-name ,
        v-err  ).
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
    /* записываем дату, с которой существует складской архив по товарам */
    run clntattr-write in this-procedure
      (input v-obj-type                               /* p-obj-type */
      ,input v-obj-code                               /* p-obj-code */
      ,input {&attr-arh-start-date}                   /* p-code     */
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

    /* записываем дату, с которой существует подробный складской архив по товарам */
    run clntattr-write in this-procedure
      (input v-obj-type                                /* p-obj-type */
      ,input v-obj-code                                /* p-obj-code */
      ,input {&attr-arh-detail-date}                   /* p-code     */
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
      ,input {&attr-arh-rest} /* p-code     */
      ,input 'true':u         /* p-value    */
      ) .
  end.

  /* разрешаем расчёт складского архива  */
  find current calc-arh-lock_batchprocess no-lock .

  if v-clear-archive = true
  then do:
    /* удаление складского архива до новой текущей даты */
    /* следует независимо удалять складской архив по дням и складской архив по сменам */
    run ahrstutl-clear-arh in this-procedure
      (input  v-obj-type     /* p-obj-type  */
      ,input  v-obj-code     /* p-obj-code  */
      ,input  v-archive-date /* p-fact-date */
      ) .
  end.
  else do:
    /* процедура сжатия складского архива по товарам */
    run utl/cmprarh.p
      (input v-obj-type
      ,input v-obj-code
      ,input 0
      ,input v-day-end-fact-order
      )  no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при удалении складского архива по товарам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

  define variable v-delete-attr-arh-del as logical   no-undo .

  /* установка начальных остатков прошла успешно */
  /* удаляем признак того, что производилось восстановление/удаление складского архива по товарам */
  run clntattr-delete in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input {&attr-arh-rest}
    ,output v-delete-attr-arh-del
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
    "Удаление складского архива по товарам успешно закончилось" skip
    "Сохраните файл" v-file-name "в надёжном месте" skip
    "Затем вы можете восстановить складской архив по товарам на основании файла" skip
    "На объекте существует складской архив по товарам с даты" string(v-new-start-date, '99/99/9999':u) skip
    "На объекте существует подробный складской архив по товарам с даты" string(v-new-detail-date, '99/99/9999':u) skip
    view-as alert-box information .
end.

procedure create-log-file :

  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-arh-start-date  as date      no-undo .
  define input  parameter p-arh-detail-date as date      no-undo .
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
    export stream slog 'old-start-date':u      string(p-arh-start-date, '99/99/9999':u ) .
    export stream slog 'old-detail-date':u     string(p-arh-detail-date, '99/99/9999':u ) .
    export stream slog 'new-start-date':u      string(p-new-start-date, '99/99/9999':u ) .
    export stream slog 'new-detail-date':u     string(p-new-detail-date, '99/99/9999':u ) .
    output stream slog close .
  end.

end procedure. /* create-log-file */

procedure close-log-file :

  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-arh-start-date  as date      no-undo .
  define input  parameter p-arh-detail-date as date      no-undo .
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
    export stream slog 'old-start-date':u      string(p-arh-start-date, '99/99/9999':u ) .
    export stream slog 'old-detail-date':u     string(p-arh-detail-date, '99/99/9999':u ) .
    export stream slog 'new-start-date':u      string(p-new-start-date, '99/99/9999':u ) .
    export stream slog 'new-detail-date':u     string(p-new-detail-date, '99/99/9999':u ) .
    export stream slog '.':u                   .
    output stream slog close .
  end.

end procedure. /* create-log-file */

procedure find-arh-start-date :

  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-new-detail-date as date      no-undo .
  define output parameter p-new-start-date  as date      no-undo .

  do
  on error undo, return error return-value
  :
    define buffer buf_stk-tot for ub.stk-tot .
    find first buf_stk-tot no-lock
      where buf_stk-tot.obj-type  = p-obj-type
        and buf_stk-tot.obj-code  = p-obj-code
        and buf_stk-tot.sum-type  = {&arh-crsa}
        and buf_stk-tot.cat-id    = {&root-cat-id}
        and buf_stk-tot.fact-date <> ?
      use-index category
      no-error .
    if  available buf_stk-tot
    and buf_stk-tot.fact-date <= p-new-detail-date
    then do:
      assign
        p-new-start-date = buf_stk-tot.fact-date
      .
    end.
    else do:
      assign
        p-new-start-date = p-new-detail-date
      .
    end.
  end.

end procedure. /* find-ah-start-date */


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





{&def-temp-stk-tot}
{&def-temp-stk-line}
{&def-temp-shift-stk-tot}
{&def-temp-shift-stk-line}



procedure ahrstutl-init :

  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-fact-date          as date      no-undo .

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
        (input p-obj-type
        ,input p-obj-code
        ,input entry(v-ind, v-sum-type-list)
        ,input p-fact-date
        ,input v-day-end-fact-order
        ,input v-shift-on
        ,input v-shift-date
        ,input v-shift-num
        ,input v-shift-end-fact-order
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
          (input p-obj-type
          ,input p-obj-code
          ,input buf_gds-obj.artic
          ,input buf_gds-obj.prod-type
          ,input buf_gds-obj.prod-code
          ,input entry(v-ind, v-sum-type-list)
          ,input p-fact-date
          ,input v-day-end-fact-order
          ,input v-shift-on
          ,input v-shift-date
          ,input v-shift-num
          ,input v-shift-end-fact-order
          ) .
      end.
    end.
  end.
end procedure. /* ahrstutl-init */


procedure ahrstutl-init-tot :

  define input  parameter p-obj-type                 as character no-undo .
  define input  parameter p-obj-code                 as integer   no-undo .
  define input  parameter p-root-sum-type            as character no-undo .
  define input  parameter p-fact-date                as date      no-undo .
  define input  parameter p-stk-tot-fact-order       as decimal   no-undo .
  define input  parameter p-shift-on                 as logical   no-undo .
  define input  parameter p-shift-date               as date      no-undo .
  define input  parameter p-shift-num                as integer   no-undo .
  define input  parameter p-shift-stk-tot-fact-order as decimal   no-undo .

  define buffer buf_stk-tot for ub.stk-tot .
  define buffer buf_temp-stk-tot for temp-stk-tot .
  define buffer buf_shift-stk-tot for ub.stk-tot .
  define buffer buf_temp-shift-stk-tot for temp-shift-stk-tot .

  define variable v-prev-stk-tot-fact-order       as decimal   no-undo .
  define variable v-prev-shift-stk-tot-fact-order as decimal   no-undo .

  do
  on error undo, return error return-value
  :
    find last buf_stk-tot no-lock
      where buf_stk-tot.obj-type   = p-obj-type
        and buf_stk-tot.obj-code   = p-obj-code
        and buf_stk-tot.sum-type   = p-root-sum-type
        and buf_stk-tot.cat-id     = {&root-cat-id}
        and buf_stk-tot.fact-order <= p-stk-tot-fact-order
      use-index category
      no-error .
    if  available buf_stk-tot
    and buf_stk-tot.fact-order <> p-stk-tot-fact-order
    then do:
      assign
        v-prev-stk-tot-fact-order = buf_stk-tot.fact-order
      .
      /* считывание текущего или предыдущего остатка */
      for each buf_stk-tot no-lock
        where buf_stk-tot.obj-type   = p-obj-type
          and buf_stk-tot.obj-code   = p-obj-code
          and buf_stk-tot.fact-order = v-prev-stk-tot-fact-order
          and buf_stk-tot.sum-type   begins p-root-sum-type
      on error undo, return error
      :
        find first buf_temp-stk-tot
          where buf_temp-stk-tot.obj-type   = buf_stk-tot.obj-type
            and buf_temp-stk-tot.obj-code   = buf_stk-tot.obj-code
            and buf_temp-stk-tot.fact-order = p-stk-tot-fact-order
            and buf_temp-stk-tot.sum-type   = buf_stk-tot.sum-type
            and buf_temp-stk-tot.cat-id     = buf_stk-tot.cat-id
          no-error .
        if not available buf_temp-stk-tot
        then do:
          create buf_temp-stk-tot .
          assign
            &scop fp1 buf_temp-stk-tot.
            &scop fp2 = buf_stk-tot.
            {&stk-tot-pair-list}
            buf_temp-stk-tot.fact-order = p-stk-tot-fact-order
            buf_temp-stk-tot.fact-date  = p-fact-date
            buf_temp-stk-tot.shift-num  = 0
            buf_temp-stk-tot.shift-date = ?
          .
        end.

        assign
          &scop fp1   buf_temp-stk-tot.
          &scop fps1
          &scop fp2   = buf_stk-tot.
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
        .
      end.
    end.

    if p-shift-on = true
    then do:
      find last buf_shift-stk-tot no-lock
        where buf_shift-stk-tot.obj-type   = p-obj-type
          and buf_shift-stk-tot.obj-code   = p-obj-code
          and buf_shift-stk-tot.sum-type   = p-root-sum-type
          and buf_shift-stk-tot.cat-id     = {&root-cat-id}
          and buf_shift-stk-tot.fact-order <= p-shift-stk-tot-fact-order
          and buf_shift-stk-tot.shift-date <> ?
        use-index category
        no-error .
      if  available buf_shift-stk-tot
      and buf_shift-stk-tot.fact-order <> p-shift-stk-tot-fact-order
      then do:
        assign
          v-prev-shift-stk-tot-fact-order = buf_shift-stk-tot.fact-order
        .
        /* считывание текущего или предыдущего остатка */
        for each buf_shift-stk-tot no-lock
          where buf_shift-stk-tot.obj-type   = p-obj-type
            and buf_shift-stk-tot.obj-code   = p-obj-code
            and buf_shift-stk-tot.fact-order = v-prev-shift-stk-tot-fact-order
            and buf_shift-stk-tot.sum-type   begins p-root-sum-type
        on error undo, return error
        :
          find first buf_temp-shift-stk-tot
            where buf_temp-shift-stk-tot.obj-type   = buf_shift-stk-tot.obj-type
              and buf_temp-shift-stk-tot.obj-code   = buf_shift-stk-tot.obj-code
              and buf_temp-shift-stk-tot.fact-order = p-shift-stk-tot-fact-order
              and buf_temp-shift-stk-tot.sum-type   = buf_shift-stk-tot.sum-type
              and buf_temp-shift-stk-tot.cat-id     = buf_shift-stk-tot.cat-id
            no-error .
          if not available buf_temp-shift-stk-tot
          then do:
            create buf_temp-shift-stk-tot .
            assign
              &scop fp1 buf_temp-shift-stk-tot.
              &scop fp2 = buf_shift-stk-tot.
              {&stk-tot-pair-list}
              buf_temp-shift-stk-tot.fact-order = p-shift-stk-tot-fact-order
              buf_temp-shift-stk-tot.fact-date  = p-fact-date
              buf_temp-shift-stk-tot.shift-date = p-shift-date
              buf_temp-shift-stk-tot.shift-num  = p-shift-num
            .
          end.

          assign
            &scop fp1   buf_temp-shift-stk-tot.
            &scop fps1
            &scop fp2   = buf_shift-stk-tot.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
      end.
    end.
  end.

end procedure. /* ahrstutl-init-tot */


procedure ahrstutl-init-line :

  define input  parameter p-obj-type                  like ub.gds-obj.obj-type  no-undo .
  define input  parameter p-obj-code                  like ub.gds-obj.obj-code  no-undo .
  define input  parameter p-artic                     like ub.gds-obj.artic     no-undo .
  define input  parameter p-prod-type                 like ub.gds-obj.prod-type no-undo .
  define input  parameter p-prod-code                 like ub.gds-obj.prod-code no-undo .
  define input  parameter p-root-sum-type             as character no-undo .
  define input  parameter p-fact-date                 as date      no-undo .
  define input  parameter p-stk-line-fact-order       as decimal   no-undo .
  define input  parameter p-shift-on                  as logical   no-undo .
  define input  parameter p-shift-date                as date      no-undo .
  define input  parameter p-shift-num                 as integer   no-undo .
  define input  parameter p-shift-stk-line-fact-order as decimal   no-undo .

  define buffer buf_stk-line for ub.stk-line .
  define buffer buf_temp-stk-line for temp-stk-line .
  define buffer buf_shift-stk-line for ub.stk-line .
  define buffer buf_temp-shift-stk-line for temp-shift-stk-line .

  define variable v-prev-stk-line-fact-order       as decimal   no-undo .
  define variable v-prev-shift-stk-line-fact-order as decimal   no-undo .

  do
  on error undo, return error return-value
  :
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type   = p-obj-type
        and buf_stk-line.obj-code   = p-obj-code
        and buf_stk-line.artic      = p-artic
        and buf_stk-line.prod-type  = p-prod-type
        and buf_stk-line.prod-code  = p-prod-code
        and buf_stk-line.sum-type   = p-root-sum-type
        and buf_stk-line.fact-order <= p-stk-line-fact-order
      use-index category
      no-error .
    if available buf_stk-line
    and buf_stk-line.fact-order <> p-stk-line-fact-order
    then do:
      assign
        v-prev-stk-line-fact-order = buf_stk-line.fact-order
      .
      /* считывание текущего или предыдущего остатка */
      for each buf_stk-line no-lock
        where buf_stk-line.obj-type   = p-obj-type
          and buf_stk-line.obj-code   = p-obj-code
          and buf_stk-line.artic      = p-artic
          and buf_stk-line.prod-type  = p-prod-type
          and buf_stk-line.prod-code  = p-prod-code
          and buf_stk-line.fact-order = v-prev-stk-line-fact-order
          and buf_stk-line.sum-type   begins p-root-sum-type
      on error undo, return error
      :
        find first buf_temp-stk-line
          where buf_temp-stk-line.obj-type   = buf_stk-line.obj-type
            and buf_temp-stk-line.obj-code   = buf_stk-line.obj-code
            and buf_temp-stk-line.artic      = buf_stk-line.artic
            and buf_temp-stk-line.prod-type  = buf_stk-line.prod-type
            and buf_temp-stk-line.prod-code  = buf_stk-line.prod-code
            and buf_temp-stk-line.fact-order = p-stk-line-fact-order
            and buf_temp-stk-line.sum-type   = buf_stk-line.sum-type
            and buf_temp-stk-line.cat-id     = buf_stk-line.cat-id
          no-error .
        if not available buf_temp-stk-line
        then do:
          create buf_temp-stk-line .
          assign
            &scop fp1 buf_temp-stk-line.
            &scop fp2 = buf_stk-line.
            {&stk-line-pair-list}
            buf_temp-stk-line.fact-order = p-stk-line-fact-order
            buf_temp-stk-line.fact-date  = p-fact-date
            buf_temp-stk-line.shift-num  = 0
            buf_temp-stk-line.shift-date = ?
          .
        end.

        assign
          &scop fp1   buf_temp-stk-line.
          &scop fps1
          &scop fp2   = buf_stk-line.
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
        .
      end.
    end.

    if p-shift-on = true
    then do:
      find last buf_shift-stk-line no-lock
        where buf_shift-stk-line.obj-type   = p-obj-type
          and buf_shift-stk-line.obj-code   = p-obj-code
          and buf_shift-stk-line.artic      = p-artic
          and buf_shift-stk-line.prod-type  = p-prod-type
          and buf_shift-stk-line.prod-code  = p-prod-code
          and buf_shift-stk-line.sum-type   = p-root-sum-type
          and buf_shift-stk-line.cat-id     = {&root-cat-id}
          and buf_shift-stk-line.fact-order <= p-shift-stk-line-fact-order
          and buf_shift-stk-line.shift-date <> ?
        use-index category
        no-error .
      if  available buf_shift-stk-line
      and buf_shift-stk-line.fact-order <> p-shift-stk-line-fact-order
      then do:
        assign
          v-prev-shift-stk-line-fact-order = buf_shift-stk-line.fact-order
        .
        /* считывание текущего или предыдущего остатка */
        for each buf_shift-stk-line no-lock
          where buf_shift-stk-line.obj-type   = p-obj-type
            and buf_shift-stk-line.obj-code   = p-obj-code
            and buf_shift-stk-line.artic      = p-artic
            and buf_shift-stk-line.prod-type  = p-prod-type
            and buf_shift-stk-line.prod-code  = p-prod-code
            and buf_shift-stk-line.fact-order = v-prev-shift-stk-line-fact-order
            and buf_shift-stk-line.sum-type   begins p-root-sum-type
        on error undo, return error
        :
          find first buf_temp-shift-stk-line
            where buf_temp-shift-stk-line.obj-type   = buf_shift-stk-line.obj-type
              and buf_temp-shift-stk-line.obj-code   = buf_shift-stk-line.obj-code
              and buf_temp-shift-stk-line.artic      = buf_shift-stk-line.artic
              and buf_temp-shift-stk-line.prod-type  = buf_shift-stk-line.prod-type
              and buf_temp-shift-stk-line.prod-code  = buf_shift-stk-line.prod-code
              and buf_temp-shift-stk-line.fact-order = p-shift-stk-line-fact-order
              and buf_temp-shift-stk-line.sum-type   = buf_shift-stk-line.sum-type
              and buf_temp-shift-stk-line.cat-id     = buf_shift-stk-line.cat-id
            no-error .
          if not available buf_temp-shift-stk-line
          then do:
            create buf_temp-shift-stk-line .
            assign
              &scop fp1 buf_temp-shift-stk-line.
              &scop fp2 = buf_shift-stk-line.
              {&stk-line-pair-list}
              buf_temp-shift-stk-line.fact-order = p-shift-stk-line-fact-order
              buf_temp-shift-stk-line.fact-date  = p-fact-date
              buf_temp-shift-stk-line.shift-date = p-shift-date
              buf_temp-shift-stk-line.shift-num  = p-shift-num
            .
          end.

          assign
            &scop fp1   buf_temp-shift-stk-line.
            &scop fps1
            &scop fp2   = buf_shift-stk-line.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
      end.
    end.
  end.

end procedure. /* ahrstutl-init-line */



procedure ahrstutl-store :

  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .

  define buffer buf_temp-stk-tot for temp-stk-tot .
  define buffer buf_temp-shift-stk-tot for temp-shift-stk-tot .
  define buffer buf_temp-stk-line for temp-stk-line .
  define buffer buf_temp-shift-stk-line for temp-shift-stk-line .
  define buffer buf_stk-tot for ub.stk-tot .
  define buffer buf_stk-line for ub.stk-line .

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

    for each buf_temp-stk-tot
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

      create buf_stk-tot .
      assign
        &scop fp1   buf_stk-tot.
        &scop fp2   = buf_temp-stk-tot.
        {&stk-tot-pair-list}
        &scop fp1   buf_stk-tot.
        &scop fps1
        &scop fp2   = buf_temp-stk-tot.
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
        buf_stk-tot.fact-order = buf_temp-stk-tot.fact-order
        buf_stk-tot.fact-date  = buf_temp-stk-tot.fact-date
        buf_stk-tot.shift-num  = buf_temp-stk-tot.shift-num
        buf_stk-tot.shift-date = buf_temp-stk-tot.shift-date
      .
    end.

    if v-shift-on = true
    then do:
      for each buf_temp-shift-stk-tot
      on error undo, return error
      :
        create buf_stk-tot .
        assign
          &scop fp1   buf_stk-tot.
          &scop fp2   = buf_temp-shift-stk-tot.
          {&stk-tot-pair-list}
          &scop fp1   buf_stk-tot.
          &scop fps1
          &scop fp2   = buf_temp-shift-stk-tot.
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
          buf_stk-tot.fact-order = buf_temp-shift-stk-tot.fact-order
          buf_stk-tot.fact-date  = buf_temp-shift-stk-tot.fact-date
          buf_stk-tot.shift-num  = buf_temp-shift-stk-tot.shift-num
          buf_stk-tot.shift-date = buf_temp-shift-stk-tot.shift-date
        .
      end.
    end.

    assign
      v-total-count = 0
    .

    for each buf_temp-stk-line
    on error undo, return error
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул" + string(buf_temp-stk-line.artic)
          ).
      end.

      create buf_stk-line .
      assign
        &scop fp1   buf_stk-line.
        &scop fp2   = buf_temp-stk-line.
        {&stk-line-pair-list}
        &scop fp1   buf_stk-line.
        &scop fps1
        &scop fp2   = buf_temp-stk-line.
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
        buf_stk-line.fact-order = buf_temp-stk-line.fact-order
        buf_stk-line.fact-date  = buf_temp-stk-line.fact-date
        buf_stk-line.shift-num  = buf_temp-stk-line.shift-num
        buf_stk-line.shift-date = buf_temp-stk-line.shift-date
      .
    end.

    if v-shift-on = true
    then do:
      for each buf_temp-shift-stk-line
      on error undo, return error
      :
        create buf_stk-line .
        assign
          &scop fp1   buf_stk-line.
          &scop fp2   = buf_temp-shift-stk-line.
          {&stk-line-pair-list}
          &scop fp1   buf_stk-line.
          &scop fps1
          &scop fp2   = buf_temp-shift-stk-line.
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
          buf_stk-line.fact-order = buf_temp-shift-stk-line.fact-order
          buf_stk-line.fact-date  = buf_temp-shift-stk-line.fact-date
          buf_stk-line.shift-num  = buf_temp-shift-stk-line.shift-num
          buf_stk-line.shift-date = buf_temp-shift-stk-line.shift-date
        .
      end.
    end.
  end.

end procedure. /* ahrstutl-store */



procedure ahrstutl-clear-arh :

  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-fact-date        as date      no-undo .

  define buffer buf_ot-tot   for ub.ot-tot .
  define buffer buf_ot-line  for ub.ot-line .
  define buffer buf_stk-tot  for ub.stk-tot .
  define buffer buf_stk-line for ub.stk-line .

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

    for each buf_ot-tot
      where buf_ot-tot.obj-type   = p-obj-type
        and buf_ot-tot.obj-code   = p-obj-code
        and buf_ot-tot.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_ot-tot.doc-code)
          ).
      end.

      delete buf_ot-tot .
    end.

    run show-action in this-procedure
      (input "Удаление оборота по строкам документов"
      ).
    assign
      v-ind = 0
    .

    for each buf_ot-line
      where buf_ot-line.obj-type   = p-obj-type
        and buf_ot-line.obj-code   = p-obj-code
        and buf_ot-line.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_ot-line.doc-code)
                  + " Артикул " + string(buf_ot-line.artic)
          ).
      end.

      delete buf_ot-line .
    end.

    run show-action in this-procedure
      (input "Удаление остатка по объекту"
      ).
    assign
      v-ind = 0
    .

    for each buf_stk-tot
      where buf_stk-tot.obj-type   = p-obj-type
        and buf_stk-tot.obj-code   = p-obj-code
        and buf_stk-tot.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Дата " + string(buf_stk-tot.fact-date, '99/99/9999':U )
          ).
      end.

      if buf_stk-tot.shift-date = ?
      or (buf_stk-tot.shift-date <> ?
          and
          buf_stk-tot.fact-order <= v-shift-end-fact-order
         )
      then do:
        delete buf_stk-tot .
      end.
    end.

    run show-action in this-procedure
      (input "Удаление остатка по товарам на объекте"
      ).
    assign
      v-ind = 0
    .

    for each buf_stk-line
      where buf_stk-line.obj-type   = p-obj-type
        and buf_stk-line.obj-code   = p-obj-code
        and buf_stk-line.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Артикул " + string(buf_stk-line.artic)
          ).
      end.

      if buf_stk-line.shift-date = ?
      or (buf_stk-line.shift-date <> ?
          and
          buf_stk-line.fact-order <= v-shift-end-fact-order
         )
      then do:
        delete buf_stk-line .
      end.
    end.
  end.

end procedure. /* ahrstutl-clear-arh */


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
      p-sum-type-list = {&arh-crsa}
                      + {&comma-char}
                      + {&arh-cost}
    .
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + {&arh-sadt} + entry(v-ind, {&TDEDT_List})
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + {&arh-cgdt} + entry(v-ind, {&TDEDT_List})
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + {&arh-csdt} + entry(v-ind, {&TDEDT_List})
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + {&arh-sadt-service} + entry(v-ind, {&TDEDT_List})
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + {&arh-cgdt-service} + entry(v-ind, {&TDEDT_List})
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + {&comma-char}
                        + {&arh-csdt-service} + entry(v-ind, {&TDEDT_List})
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

    if p-gds-goods
    then do:
      assign
        p-sum-type-list = {&arh-crsa}
                        + {&comma-char}
                        + {&arh-cost}
      .
      do v-ind = 1 to v-num-entries-TDEDT_List
      :
        assign
          p-sum-type-list = p-sum-type-list
                          + {&comma-char}
                          + {&arh-sadt} + entry(v-ind, {&TDEDT_List})
        .
      end.
      do v-ind = 1 to v-num-entries-TDEDT_List
      :
        assign
          p-sum-type-list = p-sum-type-list
                          + {&comma-char}
                          + {&arh-cgdt} + entry(v-ind, {&TDEDT_List})
        .
      end.
      do v-ind = 1 to v-num-entries-TDEDT_List
      :
        assign
          p-sum-type-list = p-sum-type-list
                          + {&comma-char}
                          + {&arh-csdt} + entry(v-ind, {&TDEDT_List})
        .
      end.
    end.
    else do:
      assign
        p-sum-type-list = {&arh-crsa-service}
                        + {&comma-char}
                        + {&arh-cost-service}
      .
      do v-ind = 1 to v-num-entries-TDEDT_List
      :
        assign
          p-sum-type-list = p-sum-type-list
                          + {&comma-char}
                          + {&arh-sadt-service} + entry(v-ind, {&TDEDT_List})
        .
      end.
      do v-ind = 1 to v-num-entries-TDEDT_List
      :
        assign
          p-sum-type-list = p-sum-type-list
                          + {&comma-char}
                          + {&arh-cgdt-service} + entry(v-ind, {&TDEDT_List})
        .
      end.
      do v-ind = 1 to v-num-entries-TDEDT_List
      :
        assign
          p-sum-type-list = p-sum-type-list
                          + {&comma-char}
                          + {&arh-csdt-service} + entry(v-ind, {&TDEDT_List})
        .
      end.
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