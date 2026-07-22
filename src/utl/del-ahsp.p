block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: del-ahsp.p $
$Archive: utl/del-ahsp.p $

Удаление складского архива по поставщикам за определенный период с выгрузкой в файл

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 12/25/03

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-ahsp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/del-ahsp.p $":U .
define variable vss-description as character no-undo init "Удаление складского архива по поставщикам за определенный период с выгрузкой в файл".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ gbl/clntattr.i }
{ gbl/ah-csp.i   }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

{&def-temp-stk-supp-tot}
{&def-temp-stk-supp-line}
{&def-temp-shift-stk-supp-tot}
{&def-temp-shift-stk-supp-line}


define temp-table temp-supp no-undo
  field cli-type as character
  field cli-code as integer
  index xpk is primary unique cli-type cli-code
  .

define temp-table temp-supp-gds no-undo
  field cli-type  as character
  field cli-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer
  index xpk is primary unique cli-type cli-code artic prod-type prod-code
  .

define stream slog .

define buffer calc-supp-arh-lock_batchprocess for ub.batchprocess .

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

  define buffer restore-ahsp-lock_batchprocess for ub.batchprocess .
  /* блокировка процедуры восстановления складского архива */
  run gbl/lock-prc.p
    (input {&lock-prc-restore-ahsp}
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Восстановление складского архива по товарам"
    ,input true
    ,buffer restore-ahsp-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент восстанавливается складской архив по поставщикам" skip
        "Невозможно произвести восстановление складского архива по поставщикам" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент восстанавливается складской архив по поставщикам" .
  end.

  /* блокировка процедуры расчета складского архива по поставщикам */
  run gbl/lock-prc.p
    (input {&lock-prc-calc-supp-arh}
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
    ,input true
    ,buffer calc-supp-arh-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент рассчитывается складской архив по поставщикам" skip
        "Невозможно произвести удаление складского архива по поставщикам" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент рассчитывается складской архив по поставщикам" .
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

  define variable v-ahsp-calc          as logical   no-undo .
  define variable v-ahsp-del           as logical   no-undo .
  define variable v-ahsp-start-date    as date      no-undo .
  define variable v-ahsp-detail-date   as date      no-undo .
  define variable v-ahsp-recalc-date   as date      no-undo .

  run clntattr-value in this-procedure
    (input  v-obj-type        /* p-obj-type */
    ,input  v-obj-code        /* p-obj-code */
    ,input  {&attr-ahsp-calc} /* p-code     */
    ,output v-attr-value      /* p-value    */
    ,output v-attr-type       /* p-type     */
    ) .
  assign
    v-ahsp-calc = (lookup(v-attr-value, 'yes,true') > 0)
  .

  run clntattr-value in this-procedure
    (input  v-obj-type       /* p-obj-type */
    ,input  v-obj-code       /* p-obj-code */
    ,input  {&attr-ahsp-del} /* p-code     */
    ,output v-attr-value     /* p-value    */
    ,output v-attr-type      /* p-type     */
    ) .
  assign
    v-ahsp-del = (lookup(v-attr-value, 'yes,true') > 0)
  .

  run clntattr-value in this-procedure
    (input  v-obj-type              /* p-obj-type */
    ,input  v-obj-code              /* p-obj-code */
    ,input  {&attr-ahsp-start-date} /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-ahsp-start-date = date(v-attr-value)
  .

  run clntattr-value in this-procedure
    (input  v-obj-type               /* p-obj-type */
    ,input  v-obj-code               /* p-obj-code */
    ,input  {&attr-ahsp-detail-date} /* p-code     */
    ,output v-attr-value             /* p-value    */
    ,output v-attr-type              /* p-type     */
    ) .
  assign
    v-ahsp-detail-date = date(v-attr-value)
  .

  run clntattr-value in this-procedure
    (input  v-obj-type               /* p-obj-type */
    ,input  v-obj-code               /* p-obj-code */
    ,input  {&attr-ahsp-recalc-date} /* p-code     */
    ,output v-attr-value             /* p-value    */
    ,output v-attr-type              /* p-type     */
    ) .
  assign
    v-ahsp-recalc-date = date(v-attr-value)
  .

  /* запрашиваем новую дату инициализации складского архива по поставщикам */
  /* todo - показывать более подробную информацию о состоянии складского архива по поставщикам */
  define variable v-month     as integer   no-undo .
  define variable v-new-month as integer   no-undo .
  define variable v-day       as integer   no-undo .
  define variable v-year      as integer   no-undo .

  assign
    v-month = month(v-ahsp-detail-date)
    v-year  = year(v-ahsp-detail-date)
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
    /* отказ от расчета складского архива по поставщикам */
    message
      "Дата очистки складского архива по поставщикам не задана" skip
      view-as alert-box information .
    undo, return error . /* --->>>--- */
  end.
  assign
    v-new-detail-date = date(v-month, 1, v-year)
  .

  /* запрашиваем у пользователя способ удаления складского архива по поставщикам */
  /* полная очистка или удаление подробной информации */
  define variable v-num as integer   no-undo .

  run gbl/d-askw.w
    (input "Вопрос" /* Заголовок окна */
    ,input "Выберите способ удаления складского архива по поставщикам" + {&new-line}  /* Общее сообщение */
          + "Новая дата начала подробного складского архива по поставщикам " + string(v-new-detail-date, '99/99/9999':u) + {&new-line}
          + "Сегодня " + string(v-today, '99/99/9999':u) + {&new-line}
    ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                /* второй символ - разделитель атрибутов в описании кнопок */
    ,input "Удаление подробной информации" + '^confirm|':u /* список названий кнопок  */
        + "Полная очистка складского архива по поставщикам" + '^confirm|':u
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
        "Ошибка при выборе способа очистки складского архива по поставщикам" skip
        view-as alert-box error .
      undo, return error .
    end.
  end case .


  if v-ahsp-calc = true
  then do:
    message
      "Складской архив по поставщикам" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Складской архив не рассчитан" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if v-ahsp-del = true
  then do:
    message
      "Складской архив по поставщикам" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Остатки имеют неопределенное значение" skip
      "Возможные пути решения: повторная инициализация складского архива поставщикам" skip
      "или восстановление складского архива из файла в случае ошибки удаления" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if (v-ahsp-start-date <> ?
     and v-ahsp-detail-date = ?)
  or (v-ahsp-start-date = ?
     and v-ahsp-detail-date <> ?)
  then do:
    message
      "Складской архив по поставщикам" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Противоречивая информация в датах инициализации складского архива" skip
      "Дата начала складского архива по поставщикам" string(v-ahsp-start-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по поставщикам" string(v-ahsp-detail-date, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if  v-ahsp-recalc-date <> ?
  and v-ahsp-detail-date <> ?
  and v-ahsp-recalc-date < v-ahsp-detail-date
  then do:
    message
      "Складской архив по поставщикам" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести удаление складского архива" skip
      "Дата перерасчета складского архива по поставщикам раньше, чем начало подробного складского архива" skip
      "Возможные пути решения: повторная инициализация складского архива" skip
      "Дата перерасчета складского архива по поставщикам" string(v-ahsp-recalc-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по поставщикам" v-ahsp-detail-date skip
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
    if v-ahsp-start-date <> ?
    then do:
      assign
        v-new-start-date = v-ahsp-start-date
      .
    end.
    else do:
      run find-ahsp-start-date in this-procedure
        (input  v-obj-type        /* p-obj-type        */
        ,input  v-obj-code        /* p-obj-code        */
        ,input  v-new-detail-date /* p-new-detail-date */
        ,output v-new-start-date  /* p-new-start-date  */
        ) .
    end.
  end.

  /* проверяем, что складской архив по поставщикам рассчитан до указанной даты */
  run trg/bt_ahsp.p
    (input v-obj-type        /* p-obj-type          */
    ,input v-obj-code        /* p-obj-code          */
    ,input v-new-detail-date /* p-last-date         */
    ,input true              /* p-check-act         */
    ,input v-cntxt-db-num    /* p-check-act-db-num  */
    ,input v-cntxt-userid    /* p-check-act-user-id */
    ) .

  /* создаем имя файла для сохранения удаляемого складского архива по поставщикам */
  assign
    v-year  = year(v-new-detail-date)
    v-month = month(v-new-detail-date)
    v-day   = day(v-new-detail-date)
  .

  assign
    v-file-name = 'ahspdel':u
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
    "Последнее предупреждение перед удалением складского архива по поставщикам" skip
    "" (if v-clear-archive = true then "ПОЛНАЯ ОЧИСТКА АРХИВОВ" else "УДАЛЕНИЕ ПОДРОБНОЙ ИНФОРМАЦИИ" ) skip
    "Старая дата начала складского архива по поставщикам" string(v-ahsp-start-date, '99/99/9999':u) skip
    "Старая дата начала подробного складского архива по поставщикам" string(v-ahsp-detail-date, '99/99/9999':u) skip
    "" skip
    "Новая дата начала складского архива по поставщикам" string(v-new-start-date, '99/99/9999':u) skip
    "Новая дата начала подробного складского архива по поставщикам" string(v-new-detail-date, '99/99/9999':u) skip
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

  def frame a
    v-obj-type       label "Объект"
    v-obj-code       no-label skip
    v-current-action format "x(40)" no-label skip
    v-current-time   format "x(8)"  label "Время очистки складского архива" skip
    v-count          format ">>>,>>>,>>9" no-label skip
    v-sub-action     format "x(40)" no-label skip
    with view-as dialog-box side-labels three-d
    title "Удаление складского архива по поставщикам"
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

  /* определяем fact-order для новых начальных остатков складского архива по поставщикам */
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

  /* создаем файл для резервного копирования складского архива по поставщикам */
  run create-log-file in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input v-ahsp-start-date
    ,input v-ahsp-detail-date
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

  /* сохраняем складской архив по поставщикам */
  run trg/ah-clicl.p
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
      "Ошибка при cохранении складского архива по поставщикам"
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* закрываем файл архивации */
  run close-log-file in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input v-ahsp-start-date
    ,input v-ahsp-detail-date
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
    ,input  {&btpr-type-ahsp} /* p-archive-type          */
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
   run create-log-err in this-procedure (
        v-obj-type,
        v-obj-code,
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
    /* записываем дату, с которой существует складской архив по поставщикам */
    run clntattr-write in this-procedure
      (input v-obj-type                               /* p-obj-type */
      ,input v-obj-code                               /* p-obj-code */
      ,input {&attr-ahsp-start-date}                  /* p-code     */
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

    /* записываем дату, с которой существует подробный складской архив по поставщикам */
    run clntattr-write in this-procedure
      (input v-obj-type                                /* p-obj-type */
      ,input v-obj-code                                /* p-obj-code */
      ,input {&attr-ahsp-detail-date}                  /* p-code     */
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
      (input v-obj-type        /* p-obj-type */
      ,input v-obj-code        /* p-obj-code */
      ,input {&attr-ahsp-rest} /* p-code     */
      ,input 'true':u          /* p-value    */
      ) .
  end.

  /* разрешаем расчёт складского архива по поставщикам */
  find current calc-supp-arh-lock_batchprocess no-lock .

  if v-clear-archive = true
  then do:
    /* удаление складского архива до новой текущей даты */
    /* следует независимо удалять складской архив по дням и складской архив по сменам */
    run ahrstutl-clear-ahsp in this-procedure
      (input  v-obj-type                 /* p-obj-type  */
      ,input  v-obj-code                 /* p-obj-code  */
      ,input  v-archive-date             /* p-fact-date */
      ) .
  end.
  else do:
    /* процедура сжатия складского архива по поставщикам */
    run utl/cmprahsp.p
      (input v-obj-type
      ,input v-obj-code
      ,input 0
      ,input v-day-end-fact-order
      )  no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при удалении подробного складского архива по поставщикам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

  define variable v-delete-attr-ahsp-del as logical   no-undo .

  /* установка начальных остатков прошла успешно */
  /* удаляем признак того, что производилось восстановление/удаление складского архива по поставщикам */
  run clntattr-delete in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,input {&attr-ahsp-rest}
    ,output v-delete-attr-ahsp-del
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
    ,input  {&btpr-type-ahsp} /* p-archive-type          */
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
    "Удаление складского архива по поставщикам успешно закончилось" skip
    "Сохраните файл" v-file-name "в надёжном месте" skip
    "Затем вы можете восстановить складской архив по поставщикам на основании файла" skip
    "На объекте существует складской архив по поставщикам с даты" string(v-new-start-date, '99/99/9999':u) skip
    "На объекте существуют подробный складской архив по поставщикам с даты" string(v-new-detail-date, '99/99/9999':u) skip
    view-as alert-box information .
end.


procedure create-log-file :

  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-ahsp-start-date  as date      no-undo .
  define input  parameter p-ahsp-detail-date as date      no-undo .
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
    export stream slog 'old-start-date':u      string(p-ahsp-start-date, '99/99/9999':u ) .
    export stream slog 'old-detail-date':u     string(p-ahsp-detail-date, '99/99/9999':u ) .
    export stream slog 'new-start-date':u      string(p-new-start-date, '99/99/9999':u ) .
    export stream slog 'new-detail-date':u     string(p-new-detail-date, '99/99/9999':u ) .
    output stream slog close .
  end.

end procedure. /* create-log-file */

procedure close-log-file :

  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-ahsp-start-date  as date      no-undo .
  define input  parameter p-ahsp-detail-date as date      no-undo .
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
    export stream slog 'old-start-date':u      string(p-ahsp-start-date, '99/99/9999':u ) .
    export stream slog 'old-detail-date':u     string(p-ahsp-detail-date, '99/99/9999':u ) .
    export stream slog 'new-start-date':u      string(p-new-start-date, '99/99/9999':u ) .
    export stream slog 'new-detail-date':u     string(p-new-detail-date, '99/99/9999':u ) .
    export stream slog '.':u                   .
    output stream slog close .
  end.

end procedure. /* create-log-file */

procedure find-ahsp-start-date :

  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-new-detail-date as date      no-undo .
  define output parameter p-new-start-date  as date      no-undo .

  do
  on error undo, return error return-value
  :
    define buffer buf_stk-supp-tot for ub.stk-supp-tot .
    find first buf_stk-supp-tot no-lock
      where buf_stk-supp-tot.obj-type  = p-obj-type
        and buf_stk-supp-tot.obj-code  = p-obj-code
      use-index fact-order
      no-error .
    if  available buf_stk-supp-tot
    and buf_stk-supp-tot.fact-date <= p-new-detail-date
    then do:
      assign
        p-new-start-date = buf_stk-supp-tot.fact-date
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


procedure temp-supp-create :

  define input  parameter p-cli-type                  like ub.stk-supp-line.cli-type  no-undo .
  define input  parameter p-cli-code                  like ub.stk-supp-line.cli-code  no-undo .

  define buffer buf_temp-supp for temp-supp .

  do
  on error undo, return error return-value
  :
    find first buf_temp-supp
      where buf_temp-supp.cli-type  = p-cli-type
        and buf_temp-supp.cli-code  = p-cli-code
      no-error .
    if not available buf_temp-supp then do:
      create buf_temp-supp .
      assign
        buf_temp-supp.cli-type  = p-cli-type
        buf_temp-supp.cli-code  = p-cli-code
      .
    end.
  end.

end procedure. /* temp-supp-create */


procedure temp-supp-fill :

  define input  parameter p-obj-type   as character no-undo .
  define input  parameter p-obj-code   as integer   no-undo .
  define input  parameter p-fact-order as decimal   no-undo .

  define buffer buf_stk-supp-tot for ub.stk-supp-tot .

  do
  on error undo, return error return-value
  :
    for each buf_stk-supp-tot no-lock
      where buf_stk-supp-tot.obj-type   = p-obj-type
        and buf_stk-supp-tot.obj-code   = p-obj-code
        and buf_stk-supp-tot.fact-order <= p-fact-order
    on error undo, return error
    :
      run temp-supp-create in this-procedure
        (input buf_stk-supp-tot.cli-type
        ,input buf_stk-supp-tot.cli-code
        ) .
    end.
  end.

end procedure. /* temp-supp-fill */



procedure temp-supp-gds-create :

  define input  parameter p-cli-type                  like ub.stk-supp-line.cli-type  no-undo .
  define input  parameter p-cli-code                  like ub.stk-supp-line.cli-code  no-undo .
  define input  parameter p-artic                     like ub.stk-supp-line.artic     no-undo .
  define input  parameter p-prod-type                 like ub.stk-supp-line.prod-type no-undo .
  define input  parameter p-prod-code                 like ub.stk-supp-line.prod-code no-undo .

  define buffer buf_temp-supp-gds for temp-supp-gds .

  do
  on error undo, return error return-value
  :
    find first buf_temp-supp-gds
      where buf_temp-supp-gds.cli-type  = p-cli-type
        and buf_temp-supp-gds.cli-code  = p-cli-code
        and buf_temp-supp-gds.artic     = p-artic
        and buf_temp-supp-gds.prod-type = p-prod-type
        and buf_temp-supp-gds.prod-code = p-prod-code
      no-error .
    if not available buf_temp-supp-gds then do:
      create buf_temp-supp-gds .
      assign
        buf_temp-supp-gds.cli-type  = p-cli-type
        buf_temp-supp-gds.cli-code  = p-cli-code
        buf_temp-supp-gds.artic     = p-artic
        buf_temp-supp-gds.prod-type = p-prod-type
        buf_temp-supp-gds.prod-code = p-prod-code
      .
    end.
  end.

end procedure. /* temp-supp-gds-create */


procedure temp-supp-gds-fill :

  define input  parameter p-obj-type   as character no-undo .
  define input  parameter p-obj-code   as integer   no-undo .
  define input  parameter p-fact-order as decimal   no-undo .

  define buffer buf_stk-supp-line for ub.stk-supp-line .

  do
  on error undo, return error return-value
  :
    for each buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type   = p-obj-type
        and buf_stk-supp-line.obj-code   = p-obj-code
        and buf_stk-supp-line.fact-order <= p-fact-order
    on error undo, return error
    :
      run temp-supp-gds-create in this-procedure
        (input buf_stk-supp-line.cli-type
        ,input buf_stk-supp-line.cli-code
        ,input buf_stk-supp-line.artic
        ,input buf_stk-supp-line.prod-type
        ,input buf_stk-supp-line.prod-code
        ) .
    end.
  end.

end procedure. /* temp-supp-gds-fill */


procedure ahrstutl-init :

  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-fact-date          as date      no-undo .

  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_goods   for ub.goods .
  define buffer buf_temp-supp for temp-supp .
  define buffer buf_temp-supp-gds for temp-supp-gds .

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
      (input "Остаток по поставщикам. Анализ"
      ).

    /* просматриваем складской архив и определяем список клиентов */
    run temp-supp-fill in this-procedure
      (input p-obj-type           /* p-obj-type   */
      ,input p-obj-code           /* p-obj-code   */
      ,input v-day-end-fact-order /* p-fact-order */
      ) .

    run ahrstutl-supp-tot-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .

    run show-action in this-procedure
      (input "Остаток по поставщикам. Считывание"
      ).

    /* считываем значение остатка по объекту на определенный момент времени */
    do v-ind = 1 to num-entries(v-sum-type-list)
    :
      for each buf_temp-supp
      on error undo, return error
      :
        run ahrstutl-init-supp-tot in this-procedure
          (input p-obj-type
          ,input p-obj-code
          ,input buf_temp-supp.cli-type
          ,input buf_temp-supp.cli-code
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

    /* просматриваем складской архив и определяем список поставщиков - товаров */

    run show-action in this-procedure
      (input "Остаток по поставщикам и товарам. Анализ"
      ).

    run ahrstutl-supp-line-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .

    run temp-supp-gds-fill in this-procedure
      (input p-obj-type           /* p-obj-type   */
      ,input p-obj-code           /* p-obj-code   */
      ,input v-day-end-fact-order /* p-fact-order */
      ) .

    run show-action in this-procedure
      (input "Остаток по поставщикам и товарам. Считывание"
      ).

    define variable v-total-count as integer   no-undo .

    for each buf_temp-supp-gds
    on error undo, return error
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count mod 10 = 0 then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + string(buf_temp-supp-gds.artic)
          ).
      end.

      do v-ind = 1 to num-entries(v-sum-type-list)
      :
        run ahrstutl-init-supp-line in this-procedure
          (input p-obj-type
          ,input p-obj-code
          ,input buf_temp-supp-gds.cli-type
          ,input buf_temp-supp-gds.cli-code
          ,input buf_temp-supp-gds.artic
          ,input buf_temp-supp-gds.prod-type
          ,input buf_temp-supp-gds.prod-code
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


procedure ahrstutl-init-supp-tot :

  define input  parameter p-obj-type                      as character no-undo .
  define input  parameter p-obj-code                      as integer   no-undo .
  define input  parameter p-cli-type                      as character no-undo .
  define input  parameter p-cli-code                      as integer   no-undo .
  define input  parameter p-root-sum-type                 as character no-undo .
  define input  parameter p-fact-date                     as date      no-undo .
  define input  parameter p-stk-supp-tot-fact-order       as decimal   no-undo .
  define input  parameter p-shift-on                      as logical   no-undo .
  define input  parameter p-shift-date                    as date      no-undo .
  define input  parameter p-shift-num                     as integer   no-undo .
  define input  parameter p-shift-stk-supp-tot-fact-order as decimal   no-undo .

  define buffer buf_stk-supp-tot for ub.stk-supp-tot .
  define buffer buf_shift-stk-supp-tot for ub.stk-supp-tot .
  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .
  define buffer buf_temp-shift-stk-supp-tot for temp-shift-stk-supp-tot .

  define variable v-prev-stk-supp-tot-fact-order as decimal   no-undo .
  define variable v-prev-shift-stk-supp-tot-f-o  as decimal   no-undo .

  do
  on error undo, return error return-value
  :
    find last buf_stk-supp-tot no-lock
      where buf_stk-supp-tot.obj-type   = p-obj-type
        and buf_stk-supp-tot.obj-code   = p-obj-code
        and buf_stk-supp-tot.cli-type   = p-cli-type
        and buf_stk-supp-tot.cli-code   = p-cli-code
        and buf_stk-supp-tot.sum-type   = p-root-sum-type
        and buf_stk-supp-tot.cat-id     = {&root-cat-id}
        and buf_stk-supp-tot.fact-order <= p-stk-supp-tot-fact-order
      use-index category
      no-error .
    if available buf_stk-supp-tot
    and buf_stk-supp-tot.fact-order <> p-stk-supp-tot-fact-order
    then do:
      assign
        v-prev-stk-supp-tot-fact-order = buf_stk-supp-tot.fact-order
      .
      /* считывание текущего или предыдущего остатка */
      for each buf_stk-supp-tot no-lock
        where buf_stk-supp-tot.obj-type   = p-obj-type
          and buf_stk-supp-tot.obj-code   = p-obj-code
          and buf_stk-supp-tot.cli-type   = p-cli-type
          and buf_stk-supp-tot.cli-code   = p-cli-code
          and buf_stk-supp-tot.fact-order = v-prev-stk-supp-tot-fact-order
          and buf_stk-supp-tot.sum-type   begins p-root-sum-type
      on error undo, return error
      :
        find first buf_temp-stk-supp-tot
          where buf_temp-stk-supp-tot.obj-type   = buf_stk-supp-tot.obj-type
            and buf_temp-stk-supp-tot.obj-code   = buf_stk-supp-tot.obj-code
            and buf_temp-stk-supp-tot.cli-type   = buf_stk-supp-tot.cli-type
            and buf_temp-stk-supp-tot.cli-code   = buf_stk-supp-tot.cli-code
            and buf_temp-stk-supp-tot.fact-order = p-stk-supp-tot-fact-order
            and buf_temp-stk-supp-tot.sum-type   = buf_stk-supp-tot.sum-type
            and buf_temp-stk-supp-tot.cat-id     = buf_stk-supp-tot.cat-id
          no-error .
        if not available buf_temp-stk-supp-tot then do:
          create buf_temp-stk-supp-tot .
          assign
            &scop fp1 buf_temp-stk-supp-tot.
            &scop fp2 = buf_stk-supp-tot.
            {&stk-supp-tot-pair-list}
            buf_temp-stk-supp-tot.fact-order = p-stk-supp-tot-fact-order
            buf_temp-stk-supp-tot.fact-date  = p-fact-date
            buf_temp-stk-supp-tot.shift-num  = 0
            buf_temp-stk-supp-tot.shift-date = ?
          .
        end.

        assign
          &scop fp1   buf_temp-stk-supp-tot.
          &scop fps1
          &scop fp2   = buf_stk-supp-tot.
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
        .
      end.
    end.

    if p-shift-on then do:
      /* ищем последнюю смену */
      find last buf_shift-stk-supp-tot no-lock
        where buf_shift-stk-supp-tot.obj-type   = p-obj-type
          and buf_shift-stk-supp-tot.obj-code   = p-obj-code
          and buf_shift-stk-supp-tot.cli-type   = p-cli-type
          and buf_shift-stk-supp-tot.cli-code   = p-cli-code
          and buf_shift-stk-supp-tot.sum-type   = p-root-sum-type
          and buf_shift-stk-supp-tot.cat-id     = {&root-cat-id}
          and buf_shift-stk-supp-tot.fact-order <= p-shift-stk-supp-tot-fact-order
          and buf_shift-stk-supp-tot.shift-date <> ?
        use-index category
        no-error .
      if available buf_shift-stk-supp-tot
      and buf_shift-stk-supp-tot.fact-order <> p-shift-stk-supp-tot-fact-order
      then do:
        assign
          v-prev-shift-stk-supp-tot-f-o = buf_shift-stk-supp-tot.fact-order
        .
        /* считывание текущего или предыдущего остатка */
        for each buf_shift-stk-supp-tot no-lock
          where buf_shift-stk-supp-tot.obj-type   = p-obj-type
            and buf_shift-stk-supp-tot.obj-code   = p-obj-code
            and buf_shift-stk-supp-tot.cli-type   = p-cli-type
            and buf_shift-stk-supp-tot.cli-code   = p-cli-code
            and buf_shift-stk-supp-tot.fact-order = v-prev-shift-stk-supp-tot-f-o
            and buf_shift-stk-supp-tot.sum-type   begins p-root-sum-type
        on error undo, return error
        :
          find first buf_temp-shift-stk-supp-tot
            where buf_temp-shift-stk-supp-tot.obj-type   = buf_shift-stk-supp-tot.obj-type
              and buf_temp-shift-stk-supp-tot.obj-code   = buf_shift-stk-supp-tot.obj-code
              and buf_temp-shift-stk-supp-tot.cli-type   = buf_shift-stk-supp-tot.cli-type
              and buf_temp-shift-stk-supp-tot.cli-code   = buf_shift-stk-supp-tot.cli-code
              and buf_temp-shift-stk-supp-tot.fact-order = p-shift-stk-supp-tot-fact-order
              and buf_temp-shift-stk-supp-tot.sum-type   = buf_shift-stk-supp-tot.sum-type
              and buf_temp-shift-stk-supp-tot.cat-id     = buf_shift-stk-supp-tot.cat-id
            no-error .
          if not available buf_temp-shift-stk-supp-tot then do:
            create buf_temp-shift-stk-supp-tot .
            assign
              &scop fp1 buf_temp-shift-stk-supp-tot.
              &scop fp2 = buf_shift-stk-supp-tot.
              {&stk-supp-tot-pair-list}
              buf_temp-shift-stk-supp-tot.fact-order = p-shift-stk-supp-tot-fact-order
              buf_temp-shift-stk-supp-tot.fact-date  = p-fact-date
              buf_temp-shift-stk-supp-tot.shift-date = p-shift-date
              buf_temp-shift-stk-supp-tot.shift-num  = p-shift-num
            .
          end.

          assign
            &scop fp1   buf_temp-shift-stk-supp-tot.
            &scop fps1
            &scop fp2   = buf_shift-stk-supp-tot.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
      end.
    end.
  end.

end procedure. /* ahrstutl-init-supp-tot */


procedure ahrstutl-init-supp-line :

  define input  parameter p-obj-type                  like ub.stk-supp-line.obj-type  no-undo .
  define input  parameter p-obj-code                  like ub.stk-supp-line.obj-code  no-undo .
  define input  parameter p-cli-type                  like ub.stk-supp-line.cli-type  no-undo .
  define input  parameter p-cli-code                  like ub.stk-supp-line.cli-code  no-undo .
  define input  parameter p-artic                     like ub.stk-supp-line.artic     no-undo .
  define input  parameter p-prod-type                 like ub.stk-supp-line.prod-type no-undo .
  define input  parameter p-prod-code                 like ub.stk-supp-line.prod-code no-undo .
  define input  parameter p-root-sum-type             as character no-undo .
  define input  parameter p-fact-date                 as date      no-undo .
  define input  parameter p-stk-supp-line-fact-order       as decimal   no-undo .
  define input  parameter p-shift-on                  as logical   no-undo .
  define input  parameter p-shift-date                as date      no-undo .
  define input  parameter p-shift-num                 as integer   no-undo .
  define input  parameter p-shift-stk-supp-line-fact-order as decimal   no-undo .

  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_shift-stk-supp-line for ub.stk-supp-line .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-shift-stk-supp-line for temp-shift-stk-supp-line .

  define variable v-prev-stk-supp-line-fact-order as decimal   no-undo .
  define variable v-prev-shift-stk-supp-line-f-o  as decimal   no-undo .

  do
  on error undo, return error return-value
  :
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type   = p-obj-type
        and buf_stk-supp-line.obj-code   = p-obj-code
        and buf_stk-supp-line.cli-type   = p-cli-type
        and buf_stk-supp-line.cli-code   = p-cli-code
        and buf_stk-supp-line.artic      = p-artic
        and buf_stk-supp-line.prod-type  = p-prod-type
        and buf_stk-supp-line.prod-code  = p-prod-code
        and buf_stk-supp-line.sum-type   = p-root-sum-type
        and buf_stk-supp-line.fact-order <= p-stk-supp-line-fact-order
      use-index category
      no-error .
    if available buf_stk-supp-line
    and buf_stk-supp-line.fact-order <> p-stk-supp-line-fact-order
    then do:
      assign
        v-prev-stk-supp-line-fact-order = buf_stk-supp-line.fact-order
      .
      /* считывание текущего или предыдущего остатка */
      for each buf_stk-supp-line no-lock
        where buf_stk-supp-line.obj-type   = p-obj-type
          and buf_stk-supp-line.obj-code   = p-obj-code
          and buf_stk-supp-line.cli-type   = p-cli-type
          and buf_stk-supp-line.cli-code   = p-cli-code
          and buf_stk-supp-line.artic      = p-artic
          and buf_stk-supp-line.prod-type  = p-prod-type
          and buf_stk-supp-line.prod-code  = p-prod-code
          and buf_stk-supp-line.fact-order = v-prev-stk-supp-line-fact-order
          and buf_stk-supp-line.sum-type   begins p-root-sum-type
      on error undo, return error
      :
        find first buf_temp-stk-supp-line
          where buf_temp-stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
            and buf_temp-stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
            and buf_temp-stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
            and buf_temp-stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
            and buf_temp-stk-supp-line.artic      = buf_stk-supp-line.artic
            and buf_temp-stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
            and buf_temp-stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
            and buf_temp-stk-supp-line.fact-order = p-stk-supp-line-fact-order
            and buf_temp-stk-supp-line.sum-type   = buf_stk-supp-line.sum-type
            and buf_temp-stk-supp-line.cat-id     = buf_stk-supp-line.cat-id
          no-error .
        if not available buf_temp-stk-supp-line
        then do:
          create buf_temp-stk-supp-line .
          assign
            &scop fp1 buf_temp-stk-supp-line.
            &scop fp2 = buf_stk-supp-line.
            {&stk-supp-line-pair-list}
            buf_temp-stk-supp-line.fact-order = p-stk-supp-line-fact-order
            buf_temp-stk-supp-line.fact-date  = p-fact-date
            buf_temp-stk-supp-line.shift-num  = 0
            buf_temp-stk-supp-line.shift-date = ?
          .
        end.

        assign
          &scop fp1   buf_temp-stk-supp-line.
          &scop fps1
          &scop fp2   = buf_stk-supp-line.
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
        .
      end.
    end.

    if p-shift-on
    then do:
      find last buf_shift-stk-supp-line no-lock
        where buf_shift-stk-supp-line.obj-type   = p-obj-type
          and buf_shift-stk-supp-line.obj-code   = p-obj-code
          and buf_shift-stk-supp-line.cli-type   = p-cli-type
          and buf_shift-stk-supp-line.cli-code   = p-cli-code
          and buf_shift-stk-supp-line.artic      = p-artic
          and buf_shift-stk-supp-line.prod-type  = p-prod-type
          and buf_shift-stk-supp-line.prod-code  = p-prod-code
          and buf_shift-stk-supp-line.sum-type   = p-root-sum-type
          and buf_shift-stk-supp-line.fact-order <= p-shift-stk-supp-line-fact-order
          and buf_shift-stk-supp-line.shift-date <> ?
        use-index category
        no-error .
      if available buf_shift-stk-supp-line
      and buf_shift-stk-supp-line.fact-order <> p-shift-stk-supp-line-fact-order
      then do:
        assign
          v-prev-shift-stk-supp-line-f-o = buf_shift-stk-supp-line.fact-order
        .
        /* считывание текущего или предыдущего остатка */
        for each buf_shift-stk-supp-line no-lock
          where buf_shift-stk-supp-line.obj-type   = p-obj-type
            and buf_shift-stk-supp-line.obj-code   = p-obj-code
            and buf_shift-stk-supp-line.cli-type   = p-cli-type
            and buf_shift-stk-supp-line.cli-code   = p-cli-code
            and buf_shift-stk-supp-line.artic      = p-artic
            and buf_shift-stk-supp-line.prod-type  = p-prod-type
            and buf_shift-stk-supp-line.prod-code  = p-prod-code
            and buf_shift-stk-supp-line.fact-order = v-prev-shift-stk-supp-line-f-o
            and buf_shift-stk-supp-line.sum-type   begins p-root-sum-type
        on error undo, return error
        :
          find first buf_temp-shift-stk-supp-line
            where buf_temp-shift-stk-supp-line.obj-type   = buf_shift-stk-supp-line.obj-type
              and buf_temp-shift-stk-supp-line.obj-code   = buf_shift-stk-supp-line.obj-code
              and buf_temp-shift-stk-supp-line.cli-type   = buf_shift-stk-supp-line.cli-type
              and buf_temp-shift-stk-supp-line.cli-code   = buf_shift-stk-supp-line.cli-code
              and buf_temp-shift-stk-supp-line.artic      = buf_shift-stk-supp-line.artic
              and buf_temp-shift-stk-supp-line.prod-type  = buf_shift-stk-supp-line.prod-type
              and buf_temp-shift-stk-supp-line.prod-code  = buf_shift-stk-supp-line.prod-code
              and buf_temp-shift-stk-supp-line.fact-order = p-shift-stk-supp-line-fact-order
              and buf_temp-shift-stk-supp-line.sum-type   = buf_shift-stk-supp-line.sum-type
              and buf_temp-shift-stk-supp-line.cat-id     = buf_shift-stk-supp-line.cat-id
            no-error .
          if not available buf_temp-shift-stk-supp-line
          then do:
            create buf_temp-shift-stk-supp-line .
            assign
              &scop fp1 buf_temp-shift-stk-supp-line.
              &scop fp2 = buf_shift-stk-supp-line.
              {&stk-supp-line-pair-list}
              buf_temp-shift-stk-supp-line.fact-order = p-shift-stk-supp-line-fact-order
              buf_temp-shift-stk-supp-line.fact-date  = p-fact-date
              buf_temp-shift-stk-supp-line.shift-date = p-shift-date
              buf_temp-shift-stk-supp-line.shift-num  = p-shift-num
            .
          end.

          assign
            &scop fp1   buf_temp-shift-stk-supp-line.
            &scop fps1
            &scop fp2   = buf_shift-stk-supp-line.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
      end.
    end.
  end.

end procedure. /* ahrstutl-init-supp-line */


procedure ahrstutl-store :

  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-fact-date          as date      no-undo .

  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .
  define buffer buf_temp-shift-stk-supp-tot for temp-shift-stk-supp-tot .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-shift-stk-supp-line for temp-shift-stk-supp-line .
  define buffer buf_stk-supp-tot for ub.stk-supp-tot .
  define buffer buf_stk-supp-line for ub.stk-supp-line .

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

    for each buf_temp-stk-supp-tot
    on error undo, return error
    :
      create buf_stk-supp-tot .
      assign
        &scop fp1   buf_stk-supp-tot.
        &scop fp2   = buf_temp-stk-supp-tot.
        {&stk-supp-tot-pair-list}
        &scop fp1   buf_stk-supp-tot.
        &scop fps1
        &scop fp2   = buf_temp-stk-supp-tot.
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
        buf_stk-supp-tot.fact-order = buf_temp-stk-supp-tot.fact-order
        buf_stk-supp-tot.fact-date  = buf_temp-stk-supp-tot.fact-date
        buf_stk-supp-tot.shift-num  = buf_temp-stk-supp-tot.shift-num
        buf_stk-supp-tot.shift-date = buf_temp-stk-supp-tot.shift-date
      .
    end.

    if v-shift-on = true then do:
      for each buf_temp-shift-stk-supp-tot
      on error undo, return error
      :
        create buf_stk-supp-tot .
        assign
          &scop fp1   buf_stk-supp-tot.
          &scop fp2   = buf_temp-shift-stk-supp-tot.
          {&stk-supp-tot-pair-list}
          &scop fp1   buf_stk-supp-tot.
          &scop fps1
          &scop fp2   = buf_temp-shift-stk-supp-tot.
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
          buf_stk-supp-tot.fact-order = buf_temp-shift-stk-supp-tot.fact-order
          buf_stk-supp-tot.fact-date  = buf_temp-shift-stk-supp-tot.fact-date
          buf_stk-supp-tot.shift-num  = buf_temp-shift-stk-supp-tot.shift-num
          buf_stk-supp-tot.shift-date = buf_temp-shift-stk-supp-tot.shift-date
        .
      end.
    end.

    for each buf_temp-stk-supp-line
    on error undo, return error
    :
      create buf_stk-supp-line .
      assign
        &scop fp1   buf_stk-supp-line.
        &scop fp2   = buf_temp-stk-supp-line.
        {&stk-supp-line-pair-list}
        &scop fp1   buf_stk-supp-line.
        &scop fps1
        &scop fp2   = buf_temp-stk-supp-line.
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
        buf_stk-supp-line.fact-order = buf_temp-stk-supp-line.fact-order
        buf_stk-supp-line.fact-date  = buf_temp-stk-supp-line.fact-date
        buf_stk-supp-line.shift-num  = buf_temp-stk-supp-line.shift-num
        buf_stk-supp-line.shift-date = buf_temp-stk-supp-line.shift-date
      .
    end.

    if v-shift-on = true then do:
      for each buf_temp-shift-stk-supp-line
      on error undo, return error
      :
        create buf_stk-supp-line .
        assign
          &scop fp1   buf_stk-supp-line.
          &scop fp2   = buf_temp-shift-stk-supp-line.
          {&stk-supp-line-pair-list}
          &scop fp1   buf_stk-supp-line.
          &scop fps1
          &scop fp2   = buf_temp-shift-stk-supp-line.
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
          buf_stk-supp-line.fact-order = buf_temp-shift-stk-supp-line.fact-order
          buf_stk-supp-line.fact-date  = buf_temp-shift-stk-supp-line.fact-date
          buf_stk-supp-line.shift-num  = buf_temp-shift-stk-supp-line.shift-num
          buf_stk-supp-line.shift-date = buf_temp-shift-stk-supp-line.shift-date
        .
      end.
    end.

  end.

end procedure. /* ahrstutl-store */


procedure ahrstutl-clear-ahsp :

  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-fact-date        as date      no-undo .

  define buffer buf_ot-supp-tot   for ub.ot-supp-tot .
  define buffer buf_ot-supp-line  for ub.ot-supp-line .
  define buffer buf_stk-supp-tot  for ub.stk-supp-tot .
  define buffer buf_stk-supp-line for ub.stk-supp-line .

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

    for each buf_ot-supp-tot
      where buf_ot-supp-tot.obj-type   = p-obj-type
        and buf_ot-supp-tot.obj-code   = p-obj-code
        and buf_ot-supp-tot.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_ot-supp-tot.doc-code)
          ).
      end.

      delete buf_ot-supp-tot .
    end.

    run show-action in this-procedure
      (input "Удаление оборота по строкам документов"
      ).
    assign
      v-ind = 0
    .

    for each buf_ot-supp-line
      where buf_ot-supp-line.obj-type   = p-obj-type
        and buf_ot-supp-line.obj-code   = p-obj-code
        and buf_ot-supp-line.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_ot-supp-line.doc-code)
                  + " Артикул " + string(buf_ot-supp-line.artic)
          ).
      end.

      delete buf_ot-supp-line .
    end.

    run show-action in this-procedure
      (input "Удаление остатка по объекту"
      ).
    assign
      v-ind = 0
    .

    for each buf_stk-supp-tot
      where buf_stk-supp-tot.obj-type   = p-obj-type
        and buf_stk-supp-tot.obj-code   = p-obj-code
        and buf_stk-supp-tot.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Дата " + string(buf_stk-supp-tot.fact-date, '99/99/9999':U )
          ).
      end.

      if buf_stk-supp-tot.shift-date = ?
      or (buf_stk-supp-tot.shift-date <> ?
          and
          buf_stk-supp-tot.fact-order <= v-shift-end-fact-order
         )
      then do:
        delete buf_stk-supp-tot .
      end.
    end.

    run show-action in this-procedure
      (input "Удаление остатка по товарам на объекте"
      ).
    assign
      v-ind = 0
    .

    for each buf_stk-supp-line
      where buf_stk-supp-line.obj-type   = p-obj-type
        and buf_stk-supp-line.obj-code   = p-obj-code
        and buf_stk-supp-line.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Артикул " + string(buf_stk-supp-line.artic)
          ).
      end.

      if buf_stk-supp-line.shift-date = ?
      or (buf_stk-supp-line.shift-date <> ?
          and
          buf_stk-supp-line.fact-order <= v-shift-end-fact-order
         )
      then do:
        delete buf_stk-supp-line .
      end.
    end.
  end.

end procedure. /* ahrstutl-clear-arh */


procedure ahrstutl-supp-tot-sum-type-list :

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
      p-sum-type-list = {&arh-cost}
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
                        + {&arh-csdt} + entry(v-ind, {&TDEDT_List})
      .
    end.
  end.

end procedure. /* ahrstutl-supp-tot-sum-type-list */


procedure ahrstutl-supp-line-sum-type-list :

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
      p-sum-type-list = {&arh-cost}
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
                        + {&arh-csdt} + entry(v-ind, {&TDEDT_List})
      .
    end.
  end.

end procedure. /* ahrstutl-supp-line-sum-type-list */


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