block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rst-arh.p $
$Archive: utl/rst-arh.p $

Восстановление складского архива по товарам

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 01/09/04

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rst-arh.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/rst-arh.p $":U .
define variable vss-description as character no-undo init "Восстановление складского архива по товарам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ trg/factord.i  }
{ gbl/clntattr.i }
{ trg/doclslib.i }
{ gbl/arh.i      }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define temp-table temp-goods no-undo
  field gds-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer
  index xpk is primary unique artic prod-type prod-code
  index xie gds-code
  .

{&def-temp-stk-tot}
{&def-temp-stk-line}
{&def-temp-shift-stk-tot}
{&def-temp-shift-stk-line}

define temp-table temp-import-ot-tot no-undo like ub.ot-tot
  .
define temp-table temp-import-ot-line no-undo like ub.ot-line
  field gds-code as integer
  .
define temp-table temp-import-stk-tot no-undo like ub.stk-tot
  .
define temp-table temp-import-stk-line no-undo like ub.stk-line
  field gds-code as integer
  .

define temp-table temp-create-stk-tot no-undo
   field obj-type as character
   field obj-code as integer
   field sum-type as character
   field need-create as logical
   index xpk is primary unique obj-type obj-code sum-type
   index xie1 need-create
.
define temp-table temp-create-stk-line no-undo
   field obj-type  as character
   field obj-code  as integer
   field artic     as character
   field prod-type as character
   field prod-code as integer
   field sum-type  as character
   field need-create as logical
   index xpk is primary unique obj-type obj-code artic prod-type prod-code sum-type
   index xie1 need-create
.

define stream slog .
define stream sinp .
define stream sout .

define buffer calc-arh-lock_batchprocess for ub.batchprocess .

define variable v-user-select         as logical   no-undo .
define variable v-obj-type            as character no-undo .
define variable v-obj-code            as integer   no-undo .
define variable v-file-name           as character no-undo .
define variable v-backup-file-name    as character no-undo .
define variable v-today               as date      no-undo .
define variable v-restore-start-date  as date      no-undo .
define variable v-restore-detail-date as date      no-undo .
define variable v-ok                  as logical   no-undo .
define variable v-line-num            as integer   no-undo .

do
on error undo, return error return-value
:

  /* выбираем объект */
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
    return . /* --->>>--- */
  end.

  /* определяем текущую дату на объекте */
  { gbl/curobjdt.i
    v-obj-type
    v-obj-code
    v-today
  }

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
    ,input "Объект,,, ,,,Восстановление складского архива по товарам"
    ,input true
    ,buffer restore-arh-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по товарам" skip
        "Объект" v-obj-type v-obj-code skip
        "В данный момент восстанавливается складской архив по товарам" skip
        "Невозможно произвести восстановлением складского архива по товарам" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент восстанавливается складской архив по товарам" .
  end.

  /* блокировка процедуры расчета складского архива */
  run gbl/lock-prc.p
    (input {&lock-prc-calc-arh}
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Расчет складского архива по товарам"
    ,input true
    ,buffer calc-arh-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по товарам" skip
        "Объект" v-obj-type v-obj-code skip
        "В данный момент рассчитывается складской архив по товарам" skip
        "Невозможно произвести расчет складского архива по товарам" skip
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

  if (v-arh-start-date <> ?
     and v-arh-detail-date = ?)
  or (v-arh-start-date = ?
     and v-arh-detail-date <> ?)
  then do:
    message
      "Невозможно произвести восстановление складского архива по товарам" skip
      "Складской архив по товарам" skip
      "Объект" v-obj-type v-obj-code skip
      "Противоречивая информация в датах инициализации архива" skip
      "Дата начала складского архива по товарам" string(v-arh-start-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по товарам" string(v-arh-detail-date, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.


  if v-arh-detail-date = ?
  then do:
    message
      "Складской архив по товарам" skip
      "Объект" v-obj-type v-obj-code skip
      "На объекте рассчитан складской архив по товарам за все даты" skip
      "Операция восстановления не может быть произведена" skip
      view-as alert-box information .
    return .
  end.

  /* автоматически создаем имя файла для считывания складского архива по товарам */
  define variable v-year  as integer   no-undo .
  define variable v-month as integer   no-undo .
  define variable v-day   as integer   no-undo .

  assign
    v-year  = year(v-arh-detail-date)
    v-month = month(v-arh-detail-date)
    v-day   = day(v-arh-detail-date)
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

  assign
    v-backup-file-name = entry(1, v-file-name, '.') + '.rst':u
  .

  define variable v-full-file-name    as character no-undo .
  define variable v-full-backup-name  as character no-undo .
  define variable v-restore-from-file as logical   no-undo .
  define variable v-restore-backup    as logical   no-undo .

  assign
    v-full-file-name = search(v-file-name)
  .

  if v-full-file-name = ?
  or v-full-file-name = ""
  then do:
    assign
      v-restore-from-file = false
    .
  end.
  else do:
    assign
      v-restore-from-file = true
    .
  end.

  assign
    v-full-backup-name = search(v-backup-file-name)
  .

  if v-full-backup-name = ?
  or v-full-backup-name = ""
  then do:
    assign
      v-restore-backup = false
    .
  end.
  else do:
    assign
      v-restore-backup = true
    .
  end.

  define variable v-num as integer   no-undo .

  run gbl/d-askw.w
    (input "Вопрос" /* Заголовок окна */
    ,input substitute("Объект &1 &2", v-obj-type, v-obj-code) + {&new-line} /* Общее сообщение */
           + "Восстановление подробного складского архива по товарам" + {&new-line}
           + "Дата начала подробного складского архива по товарам " + string(v-arh-detail-date, '99/99/9999':U) + {&new-line}
           + substitute("Сегодня &1", string(v-today, '99/99/9999':U)) + {&new-line}
    ,input '|^':u /* Символы разделители для кодирования двух следующих параметров */
                  /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                  /* второй символ - разделитель атрибутов в описании кнопок */
    ,input "Из файла" + '^confirm':u + (if v-restore-from-file = true then '':u else '^disable':u)
    + '|':u + "Резервная копия" + '^confirm':u + (if v-restore-backup = true then '':u else '^disable':u)
    + '|':u + "Документы" + '^confirm':u + (if v-arh-del = true then '^disable':u else '':u)
    + '|':u + "Отказ" /* список названий кнопок  */
                      /* каждая кнопка может иметь необязательный */
                      /* список атрибутов, влияющих на поведение кнопки */
    ,input (if v-restore-from-file then substitute("Восстановить из файла &1", v-full-file-name)
            else substitute("Файл с сохраненным складским архивом по товарам &1 не найден", v-file-name ) )
        + "|":u +
           (if v-restore-from-file then substitute("Восстановить из резервной копии &1", v-backup-file-name)
            else substitute("Файл резервной копии &1 не найден", v-backup-file-name) )
        + "|":u + (if v-arh-del
                   then "Была ошибка при предыдущем Удалении/Восстановлении" + {&new-line}
                        + "Складской архив по товарам можно восстановить только из файла"
                   else "Рассчитать на основании документов"
                   )
        + "|":u + ""
    ,input 1 /* значение возвращаемое при нажатии enter */
    ,input 4 /* значение возвращаемое при нажатии escape */
    ,output v-num /* выбор пользователя */
    ).

  define variable v-clear-start as logical   no-undo .
  assign
    v-clear-start = true
  .

  case v-num :
    when 1
    then do:
      /* восстановление из файла */
      assign
        v-restore-from-file = true
        v-restore-backup    = false
      .

      run check-md5-signature in this-procedure
        (input  v-obj-type
        ,input  v-obj-code
        ,input  {&btpr-type-arh}
        ,input  v-file-name
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Складской архив по товарам" skip
            "Объект" v-obj-type v-obj-code skip
            "Ошибка при проверке контрольной суммы файла" skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        undo, return error return-value .
      end.

      input stream sinp from value(v-file-name) .

      /* проверка правильного формата файла */
      run validate-file-name in this-procedure
        (input  v-obj-type            /* p-obj-type            */
        ,input  v-obj-code            /* p-obj-code            */
        ,input  v-arh-detail-date     /* p-cut-date            */
        ,input  v-file-name           /* p-file-name           */
        ,output v-restore-start-date  /* p-restore-start-date  */
        ,output v-restore-detail-date /* p-restore-detail-date */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Складской архив по товарам" skip
          "Объект" v-obj-type v-obj-code skip
          "Ошибка при проверке данных файла архивации" skip
          "Имя файла архивации" v-file-name skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      input stream sinp close .
    end.
    when 2
    then do:
      /* восстановление из файла */
      assign
        v-restore-from-file = true
        v-restore-backup    = true
      .
      assign
        v-file-name = v-backup-file-name
      .

      run check-md5-signature in this-procedure
        (input  v-obj-type
        ,input  v-obj-code
        ,input  {&btpr-type-arh}
        ,input  v-file-name
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Складской архив по товарам" skip
            "Объект" v-obj-type v-obj-code skip
            "Ошибка при проверке контрольной суммы файла" skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        undo, return error return-value .
      end.

      input stream sinp from value(v-file-name) .

      /* проверка правильного формата файла */
      run validate-file-name in this-procedure
        (input  v-obj-type            /* p-obj-type            */
        ,input  v-obj-code            /* p-obj-code            */
        ,input  v-arh-detail-date     /* p-cut-date            */
        ,input  v-file-name           /* p-file-name           */
        ,output v-restore-start-date  /* p-restore-start-date  */
        ,output v-restore-detail-date /* p-restore-detail-date */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Складской архив по товарам" skip
          "Объект" v-obj-type v-obj-code skip
          "Ошибка при проверке данных файла архивации" skip
          "Имя файла архивации" v-file-name skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      input stream sinp close .
    end.
    when 3
    then do:
      /* восстановление на основании документов */
      if v-arh-del = true
      then do:
        message
          "Складской архив по товарам" skip
          "Объект" v-obj-type v-obj-code skip
          "Невозможно произвести восстановление на основании документов" skip
          "Остатки по складскому архиву по товарам не рассчитаны" skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if  v-arh-recalc-date <> ?
      and v-arh-recalc-date <= v-arh-detail-date
      then do:
        message
          "Складской архив по товарам" skip
          "Объект" v-obj-type v-obj-code skip
          "Невозможно произвести восстановление на основании документов" skip
          "Дата перерасчета меньше даты начала подробного складского архива по товарам" skip
          "Дата перерасчета" string(v-arh-recalc-date, '99/99/9999':u) skip
          "Дата начала подробного складского архива по товарам" string(v-arh-detail-date, '99/99/9999':u) skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      assign
        v-restore-from-file = false
        v-restore-backup    = false
      .

      /* отступаем на месяц от текущей даты начала подробного складского архива по товарам */
      assign
        v-month = month(v-arh-detail-date)
        v-year  = year(v-arh-start-date)
      .
      assign
        v-month = v-month - 1
      .
      if v-month < 1
      then do:
        assign
          v-month = 12
          v-year  = v-year - 1
        .
      end.

      run gbl/d-inpmnt.w
        (input "Введите месяц и год"
        ,input ?
        ,input-output v-month
        ,input-output v-year
        ,output v-ok
        ).

      if v-ok <> true
      then do:
        /* отказ от расчета складского архива по товарам */
        message
          "Складской архив по товарам" skip
          "Объект" v-obj-type v-obj-code skip
          "Дата расчета складского архива по товарам не задана" skip
          "Восстановление архива не было произведено" skip
          view-as alert-box information .
        undo, return error return-value . /* --->>>--- */
      end.
      assign
        v-restore-detail-date = date(v-month, 1, v-year)
      .
      if v-restore-detail-date = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Складской архив по товарам" skip
          "Объект" v-obj-type v-obj-code skip
          "Ошибка при выборе даты" skip
          "Месяц" v-month skip
          "Год" v-year skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if v-restore-detail-date >= v-arh-detail-date
      then do:
        message
          "Складской архив по товарам" skip
          "Объект" v-obj-type v-obj-code skip
          "Неправильная дата расчета архива по товарам" skip
          "Дата расчета архива не может быть больше, чем дата на которую" skip
          "имеется рассчитанный архив по товарам" skip
          "Дата на которую запрошено восстановление подробного архива" string(v-restore-detail-date, '99/99/9999':u) skip
          "Дата начала подробного архива" string(v-arh-detail-date, '99/99/9999':u) skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if v-restore-detail-date >= v-arh-start-date
      then do:
        /* производится перерасчет без удаления первоначального остатка */
        assign
          v-clear-start        = false
          v-restore-start-date = v-arh-start-date
        .
      end.
      else do:
        assign
          v-restore-start-date = v-restore-detail-date
        .
      end.
    end.
    when 4
    then do:
      /* отказ от расчета складского архива по товарам */
      return .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по товарам" skip
        "Объект" v-obj-type v-obj-code skip
        "Внутрення ошибка" skip
        "Неизвестное значение" v-num skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .

  assign
    v-ok = false
  .
  define variable v-arh-source as character no-undo .
  if v-restore-from-file = true
  then do:
    assign
      v-arh-source = "Будет восстановлен складской архив из файла " + v-file-name
    .
  end.
  else do:
    assign
      v-arh-source = "Складской архив будет рассчитан на основании первичных документов"
    .
  end.

  if (v-restore-start-date = ?
      and v-restore-detail-date <> ?
     )
  or (v-restore-start-date <> ?
      and v-restore-detail-date = ?
     )
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Складской архив по товарам" skip
      "Объект" v-obj-type v-obj-code skip
      "Внутренняя ошибка" skip
      "Противоречивая информация в датах начала архива и начала подробного архива" skip
      "Дата начала архива" v-restore-start-date skip
      "Дата начала подробного архива" v-restore-detail-date skip
      view-as alert-box error .
    undo, return error return-value .
  end.


  message
    "Складской архив по товарам" skip
    "Объект" v-obj-type v-obj-code skip
    "Последнее предупреждение перед восстановлением складского архива по товарам" skip
    "Дата с которой существует складской архив по товарам" string(v-arh-start-date, '99/99/9999':u) skip
    "Дата с которой имеется подробный складской архив по товарам" string(v-arh-detail-date, '99/99/9999':u) skip
    "" skip
    "Дата с которой будет начинаться складской архив по товарам после восстановления" string(v-restore-start-date, '99/99/9999':u) skip
    "Дата с которой будет начинаться подробный складской архив по товарам после восстановления" string(v-restore-detail-date, '99/99/9999':u) skip
    ""
    "" skip
    "Сегодня" string(v-today, '99/99/9999':u) skip
    "" v-arh-source skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    return .
  end.

  define variable v-start-time     as int64     no-undo .
  define variable v-current-time   as character no-undo .
  define variable v-current-action as character no-undo .
  define variable v-count          as integer   no-undo .
  define variable v-sub-action     as character no-undo .

  def frame a
    v-obj-type       label "Объект"
    v-obj-code       no-label skip
    v-current-action format "x(40)" no-label skip
    v-current-time   format "x(8)"  label "Время расчета складского архива" skip
    v-count          format ">>>,>>>,>>9" no-label skip
    v-sub-action     format "x(40)" no-label skip
    with view-as dialog-box side-labels three-d
    title "Расчет складского архива по товарам"
    .
  assign
    v-start-time = etime
  .
  view frame a .
  display
    v-obj-type
    v-obj-code
    with frame a .

  define variable v-day-end-fact-order   as decimal   no-undo .

  /* определяем fact-order конца дня рассчитываемого диапазона */
  run factord-end-day in this-procedure
    (input  v-arh-detail-date - 1   /* p-fact-date            */
    ,output v-day-end-fact-order    /* p-day-end-fact-order   */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Складской архив по товарам" skip
      "Объект" v-obj-type v-obj-code skip
      "Ошибка при вызове процедуры factord"
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if  v-arh-del        = false
  and v-restore-backup = false
  then do:
    /* создаем файл для резервного копирования складского архива по товарам */
    run create-log-file in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input v-arh-start-date
      ,input v-arh-detail-date
      ,input v-arh-start-date
      ,input v-arh-detail-date
      ,input v-backup-file-name
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по товарам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при создании файла архивации" skip
        "Имя файла архивации" v-file-name skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* сохраняем складской архив по товарам */
    run trg/arhclr.p
      (input v-obj-type
      ,input v-obj-code
      ,input 0
      ,input v-day-end-fact-order
      ,input v-backup-file-name
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по товарам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при cохранении складского архива по товарам"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* закрываем файл архивации */
    run close-log-file in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input v-arh-start-date
      ,input v-arh-detail-date
      ,input v-arh-start-date
      ,input v-arh-detail-date
      ,input v-backup-file-name
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по товарам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при закрытии файла архивации" skip
        "Имя файла архивации" v-file-name skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* определяем контрольную сумму файла */
    define variable v-md5-signature as character no-undo .
    run gbl/md5.p
      (input  v-backup-file-name /* p-file-name     */
      ,output v-md5-signature    /* p-md5-signature */
      ) .

    define variable v-create-chip-num as integer   no-undo .
    define variable v-action-type     as character no-undo .

    if v-restore-from-file = true
    then do:
      assign
        v-action-type = {&archive-history-rstfil-start}
      .
    end.
    else do:
      assign
        v-action-type = {&archive-history-rstdoc-start}
      .
    end.

    run utl/arhiscr.p
      (input  v-obj-type            /* p-obj-type              */
      ,input  v-obj-code            /* p-obj-code              */
      ,input  {&btpr-type-arh}      /* p-archive-type          */
      ,input  v-action-type         /* p-action-type           */
      ,input  v-backup-file-name    /* p-file-name             */
      ,input  v-md5-signature       /* p-file-md5              */
      ,input  0                     /* p-file-invalid-chip-num */
      ,input  ""                    /* p-source-type           */
      ,input  ""                    /* p-source-ref            */
      ,input  v-restore-detail-date /* p-source-date           */
      ,output v-create-chip-num     /* p-create-chip-num       */
      ) .
  end.
  else do:
    if v-restore-from-file = true
    then do:
      assign
        v-action-type = {&archive-history-rstfil-start}
      .
    end.
    else do:
      assign
        v-action-type = {&archive-history-rstdoc-start}
      .
    end.

    run utl/arhiscr.p
      (input  v-obj-type            /* p-obj-type              */
      ,input  v-obj-code            /* p-obj-code              */
      ,input  {&btpr-type-arh}      /* p-archive-type          */
      ,input  v-action-type         /* p-action-type           */
      ,input  ""                    /* p-file-name             */
      ,input  ""                    /* p-file-md5              */
      ,input  0                     /* p-file-invalid-chip-num */
      ,input  ""                    /* p-source-type           */
      ,input  ""                    /* p-source-ref            */
      ,input  v-restore-detail-date /* p-source-date           */
      ,output v-create-chip-num     /* p-create-chip-num       */
      ) .
  end.


  define variable v-start-fact-order           as decimal   no-undo .
  define variable v-start-shift-end-fact-order as decimal   no-undo .
  define variable v-start-day-end-fact-order   as decimal   no-undo .
  if v-clear-start = true
  then do:
    assign
      v-start-day-end-fact-order = 0
    .
  end.
  else do:
    run factord in this-procedure
      (input  v-restore-detail-date - 1    /* p-fact-date            */
      ,input  1                            /* p-fact-time            */
      ,input  1                            /* p-fact-num             */
      ,input  ?                            /* p-shift-date           */
      ,input  0                            /* p-shift-num            */
      ,input  false                        /* p-shift-on             */
      ,output v-start-fact-order           /* p-fact-order           */
      ,output v-start-shift-end-fact-order /* p-shift-end-fact-order */
      ,output v-start-day-end-fact-order   /* p-day-end-fact-order   */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по товарам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

  if v-restore-from-file = true
  then do:
    /* помечаем складской архив по товарам как удаленный */
    run clntattr-write in this-procedure
      (input v-obj-type      /* p-obj-type */
      ,input v-obj-code      /* p-obj-code */
      ,input {&attr-arh-del} /* p-code     */
      ,input 'true':u        /* p-value    */
      ) .

    /* удаляем складской архив по товарам */
    run trg/arhclr.p
      (input v-obj-type
      ,input v-obj-code
      ,input v-start-day-end-fact-order
      ,input v-day-end-fact-order
      ,input ""
      )  no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по товарам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при удалении складского архива по товарам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* импорт складского архива по товарам из файла */
    input stream sinp from value(v-file-name) .

    /* проверка правильного формата файла */
    run validate-file-name in this-procedure
      (input  v-obj-type            /* p-obj-type            */
      ,input  v-obj-code            /* p-obj-code            */
      ,input  v-arh-detail-date     /* p-cut-date            */
      ,input  v-file-name           /* p-file-name           */
      ,output v-restore-start-date  /* p-restore-start-date  */
      ,output v-restore-detail-date /* p-restore-detail-date */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по товарам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при закрытии файла архивации" skip
        "Имя файла архивации" v-file-name skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* восстановление складского архива из файла */
    run restore-from-file in this-procedure .

    define variable v-close-restore-start-date  as date      no-undo .
    define variable v-close-restore-detail-date as date      no-undo .

    run validate-file-name in this-procedure
      (input  v-obj-type                  /* p-obj-type     */
      ,input  v-obj-code                  /* p-obj-code     */
      ,input  v-arh-detail-date           /* p-cut-date     */
      ,input  v-file-name                 /* p-file-name    */
      ,output v-close-restore-start-date  /* p-restore-start-date  */
      ,output v-close-restore-detail-date /* p-restore-detail-date */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по товарам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при закрытии файла архивации" skip
        "Имя файла архивации" v-file-name skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    if v-close-restore-start-date  <> v-restore-start-date
    or v-close-restore-detail-date <> v-restore-detail-date
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по товарам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при закрытии файла архивации" skip
        "Не соответствие дат начала архива и начала подробного архива в конце и в начале файла" skip
        "Дата начала архива в начале файла" v-restore-start-date skip
        "Дата начала подробного архива в началей файла" v-restore-detail-date skip
        "Дата начала архива в конце файла" v-close-restore-start-date skip
        "Дата начала подробного архива в конца файла" v-close-restore-detail-date skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    input stream sinp close .

    run clntattr-write in this-procedure
      (input v-obj-type                                 /* p-obj-type */
      ,input v-obj-code                                 /* p-obj-code */
      ,input {&attr-arh-start-date}                     /* p-code     */
      ,input string(v-restore-start-date, '99/99/9999':u) /* p-value    */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала складского архива по товарам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run clntattr-write in this-procedure
      (input v-obj-type                                  /* p-obj-type */
      ,input v-obj-code                                  /* p-obj-code */
      ,input {&attr-arh-detail-date}                     /* p-code     */
      ,input string(v-restore-detail-date, '99/99/9999':u) /* p-value    */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по товарам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при записи даты начала подробного складского архива по товарам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    define variable v-delete-arh-del as logical   no-undo .

    /* восстановление складского архива прошло успешно */
    /* удаляем признак того, что была ошибка при удалении складского архива */
    run clntattr-delete in this-procedure
      (input  v-obj-type       /* p-obj-type */
      ,input  v-obj-code       /* p-obj-code */
      ,input  {&attr-arh-del}  /* p-code     */
      ,output v-delete-arh-del /* p-deleted  */
      ) .
  end.
  else do:
    /* на сменном объекте необходимо заблокировать смену */
    define buffer lock_shift-obj for ub.shift-obj .
    run factord-lock-shift in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-restore-start-date - 1
      ,buffer lock_shift-obj
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при блокировке смены на объекте" skip
        "Объект" v-obj-type v-obj-code skip
        "Дата" v-restore-detail-date skip
        return-value
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* составление списка документов */
    run doclslib-clear-doc-list in this-procedure .

    run doclslib-init-trn-doc in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-restore-detail-date
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при заполнении списка документов" skip
        "Объект" v-obj-type v-obj-code skip
        "Дата" v-restore-detail-date skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run doclslib-init-price-doc in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-restore-detail-date
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при заполнении списка переоценок" skip
        "Объект" v-obj-type v-obj-code skip
        "Дата" v-restore-detail-date skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run doclslib-clear-rst in this-procedure
      (input v-arh-detail-date
      ) .

    /* составление списка товаров */
    run doclslib-init-goods in this-procedure .

    /* складской архив помечается как восстанавливающийся */
    run clntattr-write in this-procedure
      (input v-obj-type       /* p-obj-type */
      ,input v-obj-code       /* p-obj-code */
      ,input {&attr-arh-rest} /* p-code     */
      ,input 'true':u         /* p-value    */
      ) .

    /* сохраняем остатки на конец рассчитываемого диапазона */
    run ahrstutl-init in this-procedure
      (input v-obj-type            /* p-obj-type  */
      ,input v-obj-code            /* p-obj-code  */
      ,input v-arh-detail-date - 1 /* p-fact-date */
      ,input false                 /* p-save-new  */
      ) .

    /* создание остатков на текущую дату начала складского архива */
    run ahrstutl-create-stk in this-procedure
      (input  v-obj-type            /* p-obj-type  */
      ,input  v-obj-code            /* p-obj-code  */
      ,input  v-arh-detail-date - 1 /* p-fact-date */
      ) .

    /* удаление складского архива до текущей даты */
    /* следует независимо удалять складской архив по дням и складской архив по сменам */
    run ahrstutl-clear-arh in this-procedure
      (input  v-obj-type                 /* p-obj-type  */
      ,input  v-obj-code                 /* p-obj-code  */
      ,input  v-start-day-end-fact-order /* p-start-fact-order */
      ,input  v-arh-detail-date - 1      /* p-fact-date */
      ) .

    /* снятие блокировки на расчёт складского архива */
    find current calc-arh-lock_batchprocess no-lock .

    if v-clear-start = true
    then do:
      run show-action in this-procedure
        (input "Инициализация остатка на дату нового начала складского архива"
        ).
      /* инициализация остатков на дату нового начала складского архива */
      run trg/inarh.p
        (input  this-procedure :handle   /* p-handle-callback    */
        ,input  v-obj-type               /* p-obj-type           */
        ,input  v-obj-code               /* p-obj-code           */
        ,input  v-restore-start-date - 1 /* p-new-start-date     */
        ,input  v-arh-detail-date - 1    /* p-current-start-date */
        ) .
    end.

    run show-action in this-procedure
      (input "Расчёт складского архива по товарам"
      ).

    /* расчет складского архива с ограничением на обновление остатков */
    run doclslib-calc-arh in this-procedure
      (input this-procedure        /* p-log-handle    */
      ,input v-obj-type            /* p-obj-type      */
      ,input v-obj-code            /* p-obj-code      */
      ,input v-arh-detail-date - 1 /* p-cut-date      */
      ,input false                 /* p-update-recalc */
      ) .

    /* обновление накопительных остатков */
    /* на основании новых рассчитанных остатков и старых остатков */
    if v-clear-start = true
    then do:
      run show-action in this-procedure
        (input "Обновление накопительных остатков"
        ).
      /* считываются новые остатки и сравниваются со старыми */
      run ahrstutl-init in this-procedure
        (input v-obj-type            /* p-obj-type  */
        ,input v-obj-code            /* p-obj-code  */
        ,input v-arh-detail-date - 1 /* p-fact-date */
        ,input true                  /* p-save-new  */
        ) .

      /* происходит обновление накопительных остатков */
      /* на основании новых рассчитанных остатков и старых остатков */
      run ahrstutl-update in this-procedure
        (input v-obj-type                /* p-obj-type       */
        ,input v-obj-code                /* p-obj-code       */
        ,input v-restore-detail-date - 1 /* p-first-cut-date */
        ,input v-arh-detail-date - 1     /* p-last-cut-date  */
        ) .
    end.

    run show-action in this-procedure
      (input "Блокировка расчёта складского архива по товарам"
      ).

    /* блокировка расчёта складского архива */
    define variable v-need-stop-arh as logical   no-undo .

    assign
      v-need-stop-arh = false
    .

    run gbl/lock-prc.p
      (input {&lock-prc-calc-arh}
      ,input v-obj-code
      ,input 0
      ,input 0
      ,input v-obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского архива по товарам"
      ,input false
      ,buffer calc-arh-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры блокировки расчета складского архива по товарам" skip
          "Невозможно продолжить восстановление складского архива по товарам" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error "Ошибка при вызове процедуры блокировки расчёта складского архива по товарам" .
      end.
      assign
        v-need-stop-arh = true
      .
    end.

    define buffer stop-arh-restore-lock_btpr for batchprocess .

    if v-need-stop-arh = true
    then do:
      /* если расчёт складского архива заблокирован, */
      /* отправить команду на остановку процесса расчёта складского архива */
      do transaction
      on error undo, return error return-value
      :
        create stop-arh-restore-lock_btpr .
        assign
          stop-arh-restore-lock_btpr.bp_type       = {&btpr-type-lock} + {&lock-prc-stop-arh-restore}
          stop-arh-restore-lock_btpr.bp_status     = {&btpr-normal}
          stop-arh-restore-lock_btpr.Key#_One      = v-obj-code
          stop-arh-restore-lock_btpr.Key#_Two      = 0
          stop-arh-restore-lock_btpr.Key#_Three    = 0
          stop-arh-restore-lock_btpr.CharKey_One   = v-obj-type
          stop-arh-restore-lock_btpr.CharKey_Two   = ""
          stop-arh-restore-lock_btpr.CharKey_Three = ""
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
            (input waitfram-join-function("Складской архив рассчитывается на другой машине"
                                         ,"Отправлено сообщение о необходимости остановки расчёта складского архива"
                                         ,substitute("Ожидание освобождения ресурса расчёта складского архива &1", string(v-start-lock-second, 'HH:MM:SS':U))
                                         )
            ) .
          run gbl/lock-prc.p
            (input {&lock-prc-calc-arh}
            ,input v-obj-code
            ,input 0
            ,input 0
            ,input v-obj-type
            ,input ""
            ,input ""
            ,input "Объект,,, ,,,Расчет складского архива по товарам"
            ,input false
            ,buffer calc-arh-lock_batchprocess
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры блокировки расчета складского архива по товарам" skip
                "Невозможно продолжить восстановление складского архива по товарам" skip
                view-as alert-box error .
              undo, return error "В данный момент рассчитывается складской архив по товарам" .
            end.
          end.
          else do:
            run waitfram-hide in this-procedure .
            leave wait_block .
          end.
          pause 1 no-message .
        end.

        delete stop-arh-restore-lock_btpr .
      end.
    end.

    run show-action in this-procedure
      (input "Удаление повторных записей остатков"
      ).

    /* удаление ненужных повторных записей старых остатков и новых остатков */
    run ahrstutl-delete-copy in this-procedure
      (input v-obj-type            /* p-obj-type  */
      ,input v-obj-code            /* p-obj-code  */
      ,input v-arh-detail-date - 1 /* p-fact-date */
      ) .

    run show-action in this-procedure
      (input "Обновление атрибутов складского архива по товарам"
      ).

    run clntattr-write in this-procedure
      (input v-obj-type                                 /* p-obj-type */
      ,input v-obj-code                                 /* p-obj-code */
      ,input {&attr-arh-start-date}                     /* p-code     */
      ,input string(v-restore-start-date, '99/99/9999':u) /* p-value    */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала складского архива по товарам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run clntattr-write in this-procedure
      (input v-obj-type                                  /* p-obj-type */
      ,input v-obj-code                                  /* p-obj-code */
      ,input {&attr-arh-detail-date}                     /* p-code     */
      ,input string(v-restore-detail-date, '99/99/9999':u) /* p-value    */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала подробного архива по товарам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    define variable v-delete-arh-rest as logical   no-undo .

    /* восстановление складского архива прошло успешно */
    /* удаляем признак того, что была ошибка при удалении складского архива */
    run clntattr-delete in this-procedure
      (input  v-obj-type        /* p-obj-type */
      ,input  v-obj-code        /* p-obj-code */
      ,input  {&attr-arh-rest}  /* p-code     */
      ,output v-delete-arh-rest /* p-deleted  */
      ) .
  end.

  if v-restore-from-file = true
  then do:
    assign
      v-action-type = {&archive-history-rstfil-stop}
    .
  end.
  else do:
    assign
      v-action-type = {&archive-history-rstdoc-stop}
    .
  end.

  run utl/arhiscr.p
    (input  v-obj-type            /* p-obj-type              */
    ,input  v-obj-code            /* p-obj-code              */
    ,input  {&btpr-type-arh}      /* p-archive-type          */
    ,input  v-action-type         /* p-action-type           */
    ,input  ""                    /* p-file-name             */
    ,input  ""                    /* p-file-md5              */
    ,input  0                     /* p-file-invalid-chip-num */
    ,input  ""                    /* p-source-type           */
    ,input  ""                    /* p-source-ref            */
    ,input  v-restore-detail-date /* p-source-date           */
    ,output v-create-chip-num     /* p-create-chip-num       */
    ) .

  run invalidate-md5-signature in this-procedure
    (input  v-obj-type        /* p-obj-type     */
    ,input  v-obj-code        /* p-obj-code     */
    ,input  {&btpr-type-arh}  /* p-archive-type */
    ,input  v-file-name       /* p-file-name    */
    ,input  v-create-chip-num /* p-chip-num     */
    ) .

  run invalidate-md5-signature in this-procedure
    (input  v-obj-type         /* p-obj-type     */
    ,input  v-obj-code         /* p-obj-code     */
    ,input  {&btpr-type-arh}   /* p-archive-type */
    ,input  v-backup-file-name /* p-file-name    */
    ,input  v-create-chip-num  /* p-chip-num     */
    ) .

  message
    "Складской архив по товарам" skip
    "Объект" v-obj-type v-obj-code skip
    "Восстановление складского архива по товарам успешно закончилось" skip
    "" + (if v-restore-detail-date <> ?
         then substitute("На объекте существует подробный складской архив с даты &1", string(v-restore-detail-date, '99/99/9999':u))
         else "На объекте существует складской архив с даты открытия объекта"
         ) skip
    view-as alert-box information .
end.


procedure restore-from-file :

  do
  on error undo, return error return-value
  :
    define variable v-key-value as character no-undo .

    run show-action in this-procedure
      (input "Импорт данных из файла " + v-file-name
      ) .

    define variable v-data-finished as logical   no-undo .
    assign
      v-data-finished = false
    .

    assign
      v-line-num = 0
    .

    define variable v-total-count as integer   no-undo .

    assign
      v-total-count = 0
    .

    repeat
    :
      import stream sinp v-key-value .
      assign
        v-line-num = v-line-num + 1
      .

      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Чтение файла"
          ) .
      end.

      case v-key-value :
        when {&table_ot-tot}
        then do:
          define buffer buf_temp-import-ot-tot for temp-import-ot-tot .
          create buf_temp-import-ot-tot .
          import stream sinp buf_temp-import-ot-tot no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при импорте таблицы ot-tot" skip
              "Строка" v-line-num skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo, return error .
          end.
          assign
            v-line-num = v-line-num + 1
          .

          define buffer buf_ot-tot for ub.ot-tot .
          create buf_ot-tot .
          buffer-copy buf_temp-import-ot-tot to buf_ot-tot .

          delete buf_temp-import-ot-tot .
        end.
        when {&table_ot-line}
        then do:
          define buffer buf_temp-import-ot-line for temp-import-ot-line .
          create buf_temp-import-ot-line .
          import stream sinp buf_temp-import-ot-line except artic prod-type prod-code
            no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при импорте таблицы ot-line" skip
              "Строка" v-line-num skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo, return error .
          end.
          assign
            v-line-num = v-line-num + 1
          .

          run fill-artic in this-procedure
            (input  buf_temp-import-ot-line.gds-code  /* p-gds-code  */
            ,output buf_temp-import-ot-line.artic     /* p-artic     */
            ,output buf_temp-import-ot-line.prod-type /* p-prod-type */
            ,output buf_temp-import-ot-line.prod-code /* p-prod-code */
            ) .

          define buffer buf_ot-line for ub.ot-line .
          create buf_ot-line .
          buffer-copy buf_temp-import-ot-line to buf_ot-line .

          delete buf_temp-import-ot-line .
        end.
        when {&table_stk-tot}
        then do:
          define buffer buf_temp-import-stk-tot for temp-import-stk-tot .
          create buf_temp-import-stk-tot .
          import stream sinp buf_temp-import-stk-tot no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при импорте таблицы stk-tot" skip
              "Строка" v-line-num skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo, return error .
          end.
          assign
            v-line-num = v-line-num + 1
          .

          define buffer buf_stk-tot for ub.stk-tot .
          create buf_stk-tot .
          buffer-copy buf_temp-import-stk-tot to buf_stk-tot .

          delete buf_temp-import-stk-tot .
        end.
        when {&table_stk-line}
        then do:
          define buffer buf_temp-import-stk-line for temp-import-stk-line .
          create buf_temp-import-stk-line .
          import stream sinp buf_temp-import-stk-line except artic prod-type prod-code
            no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при импорте таблицы stk-line" skip
              "Строка" v-line-num skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo, return error .
          end.
          assign
            v-line-num = v-line-num + 1
          .

          run fill-artic in this-procedure
            (input  buf_temp-import-stk-line.gds-code  /* p-gds-code  */
            ,output buf_temp-import-stk-line.artic     /* p-artic     */
            ,output buf_temp-import-stk-line.prod-type /* p-prod-type */
            ,output buf_temp-import-stk-line.prod-code /* p-prod-code */
            ) .

          define buffer buf_stk-line for ub.stk-line .
          create buf_stk-line .
          buffer-copy buf_temp-import-stk-line to buf_stk-line .

          delete buf_temp-import-stk-line .
        end.
        when 'end-of-log':u
        then do:
          assign
            v-data-finished = true
          .
          leave .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный код таблицы" v-key-value skip
            "Строка" v-line-num skip
            view-as alert-box error .
          undo, return error .
        end.
      end case .
    end.

    if v-data-finished = false
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по товарам" skip
        "Объект" v-obj-type v-obj-code skip
        "Не найден признак окончания данных в файле" skip
        "Неправильный формат файла" v-file-name skip
        "Строка" v-line-num skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* restore-from-file */


procedure validate-file-name :

  define input parameter  p-obj-type            as character no-undo .
  define input parameter  p-obj-code            as integer   no-undo .
  define input parameter  v-arh-detail-date     as date      no-undo .
  define input parameter  p-file-name           as character no-undo .
  define output parameter p-restore-start-date  as date      no-undo .
  define output parameter p-restore-detail-date as date      no-undo .

  do
  on error undo, return error
  :

    define variable v-param-code  as character no-undo .
    define variable v-param-value as character no-undo .

    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'archive-log-version':u
    or v-param-value <> '2.1':u
    then do:
      message
        "Складской архив по товарам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error .
    end.

    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'obj-type':u
    or v-param-value <> p-obj-type
    then do:
      message
        "Складской архив по товарам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error .
    end.

    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'obj-code':u
    or v-param-value <> string(p-obj-code)
    then do:
      message
        "Складской архив по товарам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error .
    end.

    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'old-start-date':u
    then do:
      message
        "Складской архив по товарам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-restore-start-date = date(v-param-value)
    .

    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'old-detail-date':u
    then do:
      message
        "Складской архив по товарам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-restore-detail-date = date(v-param-value)
    .

    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'new-start-date':u
    then do:
      message
        "Складской архив по товарам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error .
    end.

    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'new-detail-date':u
    then do:
      message
        "Складской архив по товарам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error .
    end.

    if v-arh-detail-date <> date(v-param-value)
    then do:
      message
        "Складской архив по товарам" skip
        "Объект" p-obj-type p-obj-code skip
        "Несоответствие текущей даты начала подробного архива" skip
        "и даты начала подробного архива в файле" p-file-name skip
        "Строка" v-line-num skip
        "Текущая дата начала подробного архива" string(v-arh-detail-date) skip
        "Дата начала подробного архива в файле" v-param-value skip
        "Восстановление архива невозможно" skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* validate-file-name */


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


procedure create-log-file :

  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-old-start-date  as date      no-undo .
  define input  parameter p-old-detail-date as date      no-undo .
  define input  parameter p-new-start-date  as date      no-undo .
  define input  parameter p-new-detail-date as date      no-undo .
  define input  parameter p-file-name       as character no-undo .

  do
  on error undo, return error return-value
  :
    if search('.' + '/':u + p-file-name) <> ?
    then do:
      define variable v-ok as logical   no-undo .

      message
        "ВНИМАНИЕ!" skip
        "Файл" p-file-name "существует и будет перезаписан" skip
        "Продолжить?"
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        undo, return error return-value .
      end.
    end.

    output stream slog to value(p-file-name) .
    export stream slog 'archive-log-version':u '2.1':u .
    export stream slog 'obj-type':u            p-obj-type .
    export stream slog 'obj-code':u            string(p-obj-code) .
    export stream slog 'old-start-date':u      string(p-old-start-date, '99/99/9999':u ) .
    export stream slog 'old-detail-date':u     string(p-old-detail-date, '99/99/9999':u ) .
    export stream slog 'new-start-date':u      string(p-new-start-date, '99/99/9999':u ) .
    export stream slog 'new-detail-date':u     string(p-new-detail-date, '99/99/9999':u ) .
    output stream slog close .
  end.

end procedure. /* create-log-file */


procedure close-log-file :

  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-old-start-date  as date      no-undo .
  define input  parameter p-old-detail-date as date      no-undo .
  define input  parameter p-new-start-date  as date      no-undo .
  define input  parameter p-new-detail-date as date      no-undo .
  define input  parameter p-file-name       as character no-undo .

  do
  on error undo, return error return-value
  :
    output stream slog to value(p-file-name) append .
    export stream slog 'end-of-log':u .
    export stream slog 'archive-log-version':u '2.1':u .
    export stream slog 'obj-type':u            p-obj-type .
    export stream slog 'obj-code':u            string(p-obj-code) .
    export stream slog 'old-start-date':u      string(p-old-start-date, '99/99/9999':u ) .
    export stream slog 'old-detail-date':u     string(p-old-detail-date, '99/99/9999':u ) .
    export stream slog 'new-start-date':u      string(p-new-start-date, '99/99/9999':u ) .
    export stream slog 'new-detail-date':u     string(p-new-detail-date, '99/99/9999':u ) .
    export stream slog '.':u                   .
    output stream slog close .
  end.

end procedure. /* create-log-file */

procedure store-temp :

  define buffer buf_temp-stk-tot         for temp-stk-tot        .
  define buffer buf_temp-stk-line        for temp-stk-line       .
  define buffer buf_temp-shift-stk-tot   for temp-shift-stk-tot  .
  define buffer buf_temp-shift-stk-line  for temp-shift-stk-line .
  define buffer buf_temp-create-stk-tot  for temp-create-stk-tot .
  define buffer buf_temp-create-stk-line for temp-create-stk-line .

  do
  on error undo, return error return-value
  :

    output stream sout to value ("rst-arh.txt") append .

    export stream sout 'export':u string(today, '99/99/9999':u) string(time, 'hh:mm:ss':u) .

    for each buf_temp-stk-tot
    on error undo, return error return-value
    :
      export stream sout 'temp-stk-tot':u .
      export stream sout buf_temp-stk-tot .
    end.

    for each buf_temp-stk-line
    on error undo, return error return-value
    :
      export stream sout 'temp-stk-line':u .
      export stream sout buf_temp-stk-line .
    end.

    for each buf_temp-shift-stk-tot
    on error undo, return error return-value
    :
      export stream sout 'temp-shift-stk-tot':u .
      export stream sout buf_temp-shift-stk-tot .
    end.

    for each buf_temp-shift-stk-line
    on error undo, return error return-value
    :
      export stream sout 'temp-shift-stk-line':u .
      export stream sout buf_temp-shift-stk-line .
    end.

    for each buf_temp-create-stk-tot
    on error undo, return error return-value
    :
      export stream sout 'temp-create-stk-tot':u .
      export stream sout buf_temp-create-stk-tot .
    end.

    for each buf_temp-create-stk-line
    on error undo, return error return-value
    :
      export stream sout 'temp-create-stk-line':u .
      export stream sout buf_temp-create-stk-line .
    end.

    output stream sout close .
  end.

end procedure. /* store-temp */

procedure ahrstutl-init :

  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define input  parameter p-save-new  as logical   no-undo .

  define variable v-shift-on                as logical   no-undo .
  define variable v-shift-date              as date      no-undo .
  define variable v-shift-num               as integer   no-undo .
  define variable v-day-end-fact-order      as decimal   no-undo .
  define variable v-shift-end-fact-order    as decimal   no-undo .
  define variable v-search-end-fact-order   as decimal   no-undo .
  define variable v-create-fact-order       as decimal   no-undo .
  define variable v-shift-create-fact-order as decimal   no-undo .

  define variable v-gds-goods     as logical   no-undo .
  define variable v-sum-type-list as character no-undo .

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
      v-create-fact-order       = v-day-end-fact-order
      v-shift-create-fact-order = v-shift-end-fact-order
    .

    if p-save-new = true
    then do:
      assign
        v-day-end-fact-order   = v-day-end-fact-order - {&arh-delta}
        v-shift-end-fact-order = v-shift-end-fact-order - {&arh-delta}
      .
    end.

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
        (input p-obj-type                    /* p-obj-type                    */
        ,input p-obj-code                    /* p-obj-code                    */
        ,input entry(v-ind, v-sum-type-list) /* p-root-sum-type               */
        ,input p-fact-date                   /* p-fact-date                   */
        ,input v-day-end-fact-order          /* p-stk-tot-fact-order          */
        ,input v-create-fact-order           /* p-create-tot-fact-order       */
        ,input v-shift-on                    /* p-shift-on                    */
        ,input v-shift-date                  /* p-shift-date                  */
        ,input v-shift-num                   /* p-shift-num                   */
        ,input v-shift-end-fact-order        /* p-shift-stk-tot-fact-order    */
        ,input v-shift-create-fact-order     /* p-shift-create-tot-fact-order */
        ,input p-save-new                    /* p-save-new                    */
        ) .
    end.

    run show-action in this-procedure
      (input "Остаток по товарам"
      ).

    /* считываем предыдущее (текущее) и все более поздние значения оборота по строке */
    define variable v-total-count as integer   no-undo .

    define buffer buf_doclslib-goods for doclslib-goods.

    for each buf_doclslib-goods no-lock
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + string(buf_doclslib-goods.artic)
          ).
      end.

      { gbl/gdscdat.i
        buf_doclslib-goods.gds-code
        "'gds-goods=request':u"
        v-gds-goods
        no-error
      }

      run ahrstutl-line-sum-type-list in this-procedure
        (input  v-gds-goods     /* p-gds-goods     */
        ,output v-sum-type-list /* p-sum-type-list */
        ) .
      do v-ind = 1 to num-entries(v-sum-type-list)
      :
        run ahrstutl-init-line in this-procedure
          (input p-obj-type                    /* p-obj-type                     */
          ,input p-obj-code                    /* p-obj-code                     */
          ,input buf_doclslib-goods.artic      /* p-artic                        */
          ,input buf_doclslib-goods.prod-type  /* p-prod-type                    */
          ,input buf_doclslib-goods.prod-code  /* p-prod-code                    */
          ,input entry(v-ind, v-sum-type-list) /* p-root-sum-type                */
          ,input p-fact-date                   /* p-fact-date                    */
          ,input v-day-end-fact-order          /* p-stk-line-fact-order          */
          ,input v-create-fact-order           /* p-create-line-fact-order       */
          ,input v-shift-on                    /* p-shift-on                     */
          ,input v-shift-date                  /* p-shift-date                   */
          ,input v-shift-num                   /* p-shift-num                    */
          ,input v-shift-end-fact-order        /* p-shift-stk-line-fact-order    */
          ,input v-shift-create-fact-order     /* p-shift-create-line-fact-order */
          ,input p-save-new                    /* p-save-new                     */
          ) .
      end.
    end.
  end.
end procedure. /* ahrstutl-init */

procedure ahrstutl-init-tot :

  define input  parameter p-obj-type                    as character no-undo .
  define input  parameter p-obj-code                    as integer   no-undo .
  define input  parameter p-root-sum-type               as character no-undo .
  define input  parameter p-fact-date                   as date      no-undo .
  define input  parameter p-stk-tot-fact-order          as decimal   no-undo .
  define input  parameter p-create-tot-fact-order       as decimal   no-undo .
  define input  parameter p-shift-on                    as logical   no-undo .
  define input  parameter p-shift-date                  as date      no-undo .
  define input  parameter p-shift-num                   as integer   no-undo .
  define input  parameter p-shift-stk-tot-fact-order    as decimal   no-undo .
  define input  parameter p-shift-create-tot-fact-order as decimal   no-undo .
  define input  parameter p-save-new                    as logical   no-undo .

  define buffer buf_stk-tot for ub.stk-tot .
  define buffer buf_temp-stk-tot for temp-stk-tot .
  define buffer buf_temp-shift-stk-tot for temp-shift-stk-tot .
  define buffer buf_temp-create-stk-tot for temp-create-stk-tot .

  define variable v-prev-stk-tot-fact-order        like ub.stk-tot.fact-order no-undo .
  define variable v-create-stk as logical   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-create-stk = false
    .

    find last buf_stk-tot no-lock
      where buf_stk-tot.obj-type   = p-obj-type
        and buf_stk-tot.obj-code   = p-obj-code
        and buf_stk-tot.sum-type   = p-root-sum-type
        and buf_stk-tot.cat-id     = {&root-cat-id}
        and buf_stk-tot.fact-order <= p-stk-tot-fact-order
      use-index category
      no-error .
    if available buf_stk-tot
    then do:
      assign
        v-prev-stk-tot-fact-order = buf_stk-tot.fact-order
      .

      if v-prev-stk-tot-fact-order <> p-stk-tot-fact-order
      then do:
        assign
          v-create-stk = true
        .
      end.
      else do:
        assign
          v-create-stk = false
        .
      end.

      /* считывание текущего или предыдущего остатка */
      for each buf_stk-tot no-lock
        where buf_stk-tot.obj-type   = p-obj-type
          and buf_stk-tot.obj-code   = p-obj-code
          and buf_stk-tot.fact-order = v-prev-stk-tot-fact-order
          and buf_stk-tot.sum-type   begins p-root-sum-type
      on error undo, return error return-value
      :
        find first buf_temp-stk-tot
          where buf_temp-stk-tot.obj-type   = buf_stk-tot.obj-type
            and buf_temp-stk-tot.obj-code   = buf_stk-tot.obj-code
            and buf_temp-stk-tot.fact-order = p-create-tot-fact-order
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
            buf_temp-stk-tot.fact-order = p-create-tot-fact-order
            buf_temp-stk-tot.fact-date  = p-fact-date
            buf_temp-stk-tot.shift-num  = 0
            buf_temp-stk-tot.shift-date = ?
          .
        end.

        if p-save-new = true
        then do:
          assign
            &scop fp1   buf_temp-stk-tot.new-
            &scop fps1
            &scop fp2   = buf_stk-tot.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
        else do:
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
        if p-shift-on = true
        then do:
          find first buf_temp-shift-stk-tot
            where buf_temp-shift-stk-tot.obj-type   = buf_stk-tot.obj-type
              and buf_temp-shift-stk-tot.obj-code   = buf_stk-tot.obj-code
              and buf_temp-shift-stk-tot.fact-order = p-shift-create-tot-fact-order
              and buf_temp-shift-stk-tot.sum-type   = buf_stk-tot.sum-type
              and buf_temp-shift-stk-tot.cat-id     = buf_stk-tot.cat-id
            no-error .
          if not available buf_temp-shift-stk-tot
          then do:
            create buf_temp-shift-stk-tot .
            assign
              &scop fp1 buf_temp-shift-stk-tot.
              &scop fp2 = buf_stk-tot.
              {&stk-tot-pair-list}
              buf_temp-shift-stk-tot.fact-order = p-shift-create-tot-fact-order
              buf_temp-shift-stk-tot.fact-date  = p-fact-date
              buf_temp-shift-stk-tot.shift-date = p-shift-date
              buf_temp-shift-stk-tot.shift-num  = p-shift-num
            .
          end.

          if p-save-new = true
          then do:
            assign
              &scop fp1   buf_temp-shift-stk-tot.new-
              &scop fps1
              &scop fp2   = buf_stk-tot.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.
          else do:
            assign
              &scop fp1   buf_temp-shift-stk-tot.
              &scop fps1
              &scop fp2   = buf_stk-tot.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.
        end.
      end.
    end.
    else do:
      assign
        v-create-stk = true
      .
      find first buf_temp-stk-tot
        where buf_temp-stk-tot.obj-type   = p-obj-type
          and buf_temp-stk-tot.obj-code   = p-obj-code
          and buf_temp-stk-tot.fact-order = p-create-tot-fact-order
          and buf_temp-stk-tot.sum-type   = p-root-sum-type
          and buf_temp-stk-tot.cat-id     = {&root-cat-id}
        no-error .
      if not available buf_temp-stk-tot
      then do:
        create buf_temp-stk-tot .
        assign
          buf_temp-stk-tot.obj-type   = p-obj-type
          buf_temp-stk-tot.obj-code   = p-obj-code
          buf_temp-stk-tot.sum-type   = p-root-sum-type
          buf_temp-stk-tot.cat-id     = {&root-cat-id}
          buf_temp-stk-tot.fact-order = p-create-tot-fact-order
          buf_temp-stk-tot.fact-date  = p-fact-date
          buf_temp-stk-tot.shift-num  = 0
          buf_temp-stk-tot.shift-date = ?
        .
      end.
      if p-shift-on = true
      then do:
        find first buf_temp-shift-stk-tot
          where buf_temp-shift-stk-tot.obj-type   = p-obj-type
            and buf_temp-shift-stk-tot.obj-code   = p-obj-code
            and buf_temp-shift-stk-tot.fact-order = p-shift-create-tot-fact-order
            and buf_temp-shift-stk-tot.sum-type   = p-root-sum-type
            and buf_temp-shift-stk-tot.cat-id     = {&root-cat-id}
          no-error .
        if not available buf_temp-shift-stk-tot
        then do:
          create buf_temp-shift-stk-tot .
          assign
            buf_temp-shift-stk-tot.obj-type   = p-obj-type
            buf_temp-shift-stk-tot.obj-code   = p-obj-code
            buf_temp-shift-stk-tot.sum-type   = p-root-sum-type
            buf_temp-shift-stk-tot.cat-id     = {&root-cat-id}
            buf_temp-shift-stk-tot.fact-order = p-shift-create-tot-fact-order
            buf_temp-shift-stk-tot.fact-date  = p-fact-date
            buf_temp-shift-stk-tot.shift-date = p-shift-date
            buf_temp-shift-stk-tot.shift-num  = p-shift-num
          .
        end.
      end.
    end.

    if p-save-new = false
    then do:
      create buf_temp-create-stk-tot .
      assign
        buf_temp-create-stk-tot.obj-type    = p-obj-type
        buf_temp-create-stk-tot.obj-code    = p-obj-code
        buf_temp-create-stk-tot.sum-type    = p-root-sum-type
        buf_temp-create-stk-tot.need-create = v-create-stk
      .
    end.
  end.

end procedure. /* ahrstutl-init-tot */


procedure ahrstutl-init-line :

  define input  parameter p-obj-type                     like ub.gds-obj.obj-type  no-undo .
  define input  parameter p-obj-code                     like ub.gds-obj.obj-code  no-undo .
  define input  parameter p-artic                        like ub.gds-obj.artic     no-undo .
  define input  parameter p-prod-type                    like ub.gds-obj.prod-type no-undo .
  define input  parameter p-prod-code                    like ub.gds-obj.prod-code no-undo .
  define input  parameter p-root-sum-type                as character no-undo .
  define input  parameter p-fact-date                    as date      no-undo .
  define input  parameter p-stk-line-fact-order          as decimal   no-undo .
  define input  parameter p-create-line-fact-order       as decimal   no-undo .
  define input  parameter p-shift-on                     as logical   no-undo .
  define input  parameter p-shift-date                   as date      no-undo .
  define input  parameter p-shift-num                    as integer   no-undo .
  define input  parameter p-shift-stk-line-fact-order    as decimal   no-undo .
  define input  parameter p-shift-create-line-fact-order as decimal   no-undo .
  define input  parameter p-save-new                     as logical   no-undo .

  define buffer buf_stk-line for ub.stk-line .
  define buffer buf_temp-stk-line for temp-stk-line .
  define buffer buf_temp-shift-stk-line for temp-shift-stk-line .
  define buffer buf_temp-create-stk-line for temp-create-stk-line .

  define variable v-prev-stk-line-fact-order       like ub.stk-line.fact-order no-undo .
  define variable v-prev-shift-stk-line-fact-order like ub.stk-line.fact-order no-undo .

  define variable v-create-stk as logical   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-create-stk = false
    .

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
    then do:
      assign
        v-prev-stk-line-fact-order = buf_stk-line.fact-order
      .

      if v-prev-stk-line-fact-order <> p-stk-line-fact-order
      then do:
        assign
          v-create-stk = true
        .
      end.
      else do:
        assign
          v-create-stk = false
        .
      end.

      /* считывание текущего или предыдущего остатка */
      for each buf_stk-line no-lock
        where buf_stk-line.obj-type   = p-obj-type
          and buf_stk-line.obj-code   = p-obj-code
          and buf_stk-line.artic      = p-artic
          and buf_stk-line.prod-type  = p-prod-type
          and buf_stk-line.prod-code  = p-prod-code
          and buf_stk-line.fact-order = v-prev-stk-line-fact-order
          and buf_stk-line.sum-type   begins p-root-sum-type
      on error undo, return error return-value
      :
        find first buf_temp-stk-line
          where buf_temp-stk-line.obj-type   = buf_stk-line.obj-type
            and buf_temp-stk-line.obj-code   = buf_stk-line.obj-code
            and buf_temp-stk-line.artic      = buf_stk-line.artic
            and buf_temp-stk-line.prod-type  = buf_stk-line.prod-type
            and buf_temp-stk-line.prod-code  = buf_stk-line.prod-code
            and buf_temp-stk-line.fact-order = p-create-line-fact-order
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
            buf_temp-stk-line.fact-order = p-create-line-fact-order
            buf_temp-stk-line.fact-date  = p-fact-date
            buf_temp-stk-line.shift-num  = 0
            buf_temp-stk-line.shift-date = ?
          .
        end.
        if p-save-new = true
        then do:
          assign
            &scop fp1   buf_temp-stk-line.new-
            &scop fps1
            &scop fp2   = buf_stk-line.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
        else do:
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
        if p-shift-on = true
        then do:
          find first buf_temp-shift-stk-line
            where buf_temp-shift-stk-line.obj-type   = buf_stk-line.obj-type
              and buf_temp-shift-stk-line.obj-code   = buf_stk-line.obj-code
              and buf_temp-shift-stk-line.artic      = buf_stk-line.artic
              and buf_temp-shift-stk-line.prod-type  = buf_stk-line.prod-type
              and buf_temp-shift-stk-line.prod-code  = buf_stk-line.prod-code
              and buf_temp-shift-stk-line.fact-order = p-shift-create-line-fact-order
              and buf_temp-shift-stk-line.sum-type   = buf_stk-line.sum-type
              and buf_temp-shift-stk-line.cat-id     = buf_stk-line.cat-id
            no-error .
          if not available buf_temp-shift-stk-line
          then do:
            create buf_temp-shift-stk-line .
            assign
              &scop fp1 buf_temp-shift-stk-line.
              &scop fp2 = buf_stk-line.
              {&stk-line-pair-list}
              buf_temp-shift-stk-line.fact-order = p-shift-create-line-fact-order
              buf_temp-shift-stk-line.fact-date  = p-fact-date
              buf_temp-shift-stk-line.shift-date = p-shift-date
              buf_temp-shift-stk-line.shift-num  = p-shift-num
            .
          end.
          if p-save-new = true
          then do:
            assign
              &scop fp1   buf_temp-shift-stk-line.new-
              &scop fps1
              &scop fp2   = buf_stk-line.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.
          else do:
            assign
              &scop fp1   buf_temp-shift-stk-line.
              &scop fps1
              &scop fp2   = buf_stk-line.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.
        end.
      end.
    end.
    else do:
      assign
        v-create-stk = true
      .

      find first buf_temp-stk-line
        where buf_temp-stk-line.obj-type   = p-obj-type
          and buf_temp-stk-line.obj-code   = p-obj-code
          and buf_temp-stk-line.artic      = p-artic
          and buf_temp-stk-line.prod-type  = p-prod-type
          and buf_temp-stk-line.prod-code  = p-prod-code
          and buf_temp-stk-line.fact-order = p-create-line-fact-order
          and buf_temp-stk-line.sum-type   = p-root-sum-type
          and buf_temp-stk-line.cat-id     = {&root-cat-id}
        no-error .
      if not available buf_temp-stk-line
      then do:
        create buf_temp-stk-line .
        assign
          buf_temp-stk-line.obj-type   = p-obj-type
          buf_temp-stk-line.obj-code   = p-obj-code
          buf_temp-stk-line.artic      = p-artic
          buf_temp-stk-line.prod-type  = p-prod-type
          buf_temp-stk-line.prod-code  = p-prod-code
          buf_temp-stk-line.sum-type   = p-root-sum-type
          buf_temp-stk-line.cat-id     = {&root-cat-id}
          buf_temp-stk-line.fact-order = p-create-line-fact-order
          buf_temp-stk-line.fact-date  = p-fact-date
          buf_temp-stk-line.shift-num  = 0
          buf_temp-stk-line.shift-date = ?
        .
      end.

      if p-shift-on = true
      then do:
        find first buf_temp-shift-stk-line
          where buf_temp-shift-stk-line.obj-type   = p-obj-type
            and buf_temp-shift-stk-line.obj-code   = p-obj-code
            and buf_temp-shift-stk-line.artic      = p-artic
            and buf_temp-shift-stk-line.prod-type  = p-prod-type
            and buf_temp-shift-stk-line.prod-code  = p-prod-code
            and buf_temp-shift-stk-line.fact-order = p-shift-create-line-fact-order
            and buf_temp-shift-stk-line.sum-type   = p-root-sum-type
            and buf_temp-shift-stk-line.cat-id     = {&root-cat-id}
          no-error .
        if not available buf_temp-shift-stk-line
        then do:
          create buf_temp-shift-stk-line .
          assign
            buf_temp-shift-stk-line.obj-type   = p-obj-type
            buf_temp-shift-stk-line.obj-code   = p-obj-code
            buf_temp-shift-stk-line.artic      = p-artic
            buf_temp-shift-stk-line.prod-type  = p-prod-type
            buf_temp-shift-stk-line.prod-code  = p-prod-code
            buf_temp-shift-stk-line.sum-type   = p-root-sum-type
            buf_temp-shift-stk-line.cat-id     = {&root-cat-id}
            buf_temp-shift-stk-line.fact-order = p-shift-create-line-fact-order
            buf_temp-shift-stk-line.fact-date  = p-fact-date
            buf_temp-shift-stk-line.shift-date = p-shift-date
            buf_temp-shift-stk-line.shift-num  = p-shift-num
          .
        end.
      end.
    end.

    if p-save-new = false
    then do:
      create buf_temp-create-stk-line .
      assign
        buf_temp-create-stk-line.obj-type    = p-obj-type
        buf_temp-create-stk-line.obj-code    = p-obj-code
        buf_temp-create-stk-line.artic       = p-artic
        buf_temp-create-stk-line.prod-type   = p-prod-type
        buf_temp-create-stk-line.prod-code   = p-prod-code
        buf_temp-create-stk-line.sum-type    = p-root-sum-type
        buf_temp-create-stk-line.need-create = v-create-stk
      .
    end.
  end.

end procedure. /* ahrstutl-init-line */


procedure ahrstutl-create-stk :

  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .

  define variable v-shift-on                as logical   no-undo .
  define variable v-shift-date              as date      no-undo .
  define variable v-shift-num               as integer   no-undo .
  define variable v-day-end-fact-order      as decimal   no-undo .
  define variable v-shift-end-fact-order    as decimal   no-undo .

  define buffer buf_temp-create-stk-tot  for temp-create-stk-tot .
  define buffer buf_temp-create-stk-line for temp-create-stk-line .
  define buffer buf_temp-stk-tot for temp-stk-tot .
  define buffer buf_stk-tot for ub.stk-tot .
  define buffer buf_temp-stk-line for temp-stk-line .
  define buffer buf_stk-line for ub.stk-line .

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
      (input "Создание остатка на текущую дату"
      ).
    define variable v-total-count as integer   no-undo .

    for each buf_temp-create-stk-tot
      where buf_temp-create-stk-tot.need-create = true
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input ""
          ).
      end.

      for each buf_temp-stk-tot
        where buf_temp-stk-tot.obj-type   = buf_temp-create-stk-tot.obj-type
          and buf_temp-stk-tot.obj-code   = buf_temp-create-stk-tot.obj-code
          and buf_temp-stk-tot.fact-order = v-day-end-fact-order
          and buf_temp-stk-tot.sum-type   begins buf_temp-create-stk-tot.sum-type
      on error undo, return error return-value
      :
        create buf_stk-tot .
        buffer-copy buf_temp-stk-tot to buf_stk-tot
        .
      end.

      if v-shift-on = true
      then do:
        for each buf_temp-stk-tot
          where buf_temp-stk-tot.obj-type   = buf_temp-create-stk-tot.obj-type
            and buf_temp-stk-tot.obj-code   = buf_temp-create-stk-tot.obj-code
            and buf_temp-stk-tot.fact-order = v-shift-end-fact-order
            and buf_temp-stk-tot.sum-type   begins buf_temp-create-stk-tot.sum-type
        on error undo, return error return-value
        :
          create buf_stk-tot .
          buffer-copy buf_temp-stk-tot to buf_stk-tot
          .
        end.
      end.
    end.

    assign
      v-total-count = 0
    .

    for each buf_temp-create-stk-line
      where buf_temp-create-stk-line.need-create = true
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + buf_temp-create-stk-line.artic
          ).
      end.

      for each buf_temp-stk-line
        where buf_temp-stk-line.obj-type   = buf_temp-create-stk-line.obj-type
          and buf_temp-stk-line.obj-code   = buf_temp-create-stk-line.obj-code
          and buf_temp-stk-line.artic      = buf_temp-create-stk-line.artic
          and buf_temp-stk-line.prod-type  = buf_temp-create-stk-line.prod-type
          and buf_temp-stk-line.prod-code  = buf_temp-create-stk-line.prod-code
          and buf_temp-stk-line.fact-order = v-day-end-fact-order
          and buf_temp-stk-line.sum-type   begins buf_temp-create-stk-line.sum-type
      on error undo, return error return-value
      :
        create buf_stk-line .
        buffer-copy buf_temp-stk-line to buf_stk-line
        .
      end.

      if v-shift-on = true
      then do:
        for each buf_temp-stk-line
          where buf_temp-stk-line.obj-type   = buf_temp-create-stk-line.obj-type
            and buf_temp-stk-line.obj-code   = buf_temp-create-stk-line.obj-code
            and buf_temp-stk-line.artic      = buf_temp-create-stk-line.artic
            and buf_temp-stk-line.prod-type  = buf_temp-create-stk-line.prod-type
            and buf_temp-stk-line.prod-code  = buf_temp-create-stk-line.prod-code
            and buf_temp-stk-line.fact-order = v-shift-end-fact-order
            and buf_temp-stk-line.sum-type   begins buf_temp-create-stk-line.sum-type
        on error undo, return error return-value
        :
          create buf_stk-line .
          buffer-copy buf_temp-stk-line to buf_stk-line
          .
        end.
      end.
    end.
  end.

end procedure. /* ahrstutl-create-stk */


procedure ahrstutl-clear-arh :

  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-start-fact-order as decimal   no-undo .
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
        and buf_ot-tot.fact-order > p-start-fact-order
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
        and buf_ot-line.fact-order > p-start-fact-order
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
        and buf_stk-tot.fact-order > p-start-fact-order
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
        and buf_stk-line.fact-order > p-start-fact-order
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


procedure ahrstutl-delete-copy :

  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .

  define buffer buf_stk-tot  for ub.stk-tot .
  define buffer buf_stk-line for ub.stk-line .
  define buffer buf_temp-create-stk-tot for temp-create-stk-tot .
  define buffer buf_temp-create-stk-line for temp-create-stk-line .

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

    run show-action in this-procedure
      (input "Удаление повторных остатков"
      ).
    define variable v-total-count as integer   no-undo .
    assign
      v-total-count = 0
    .

    for each buf_temp-create-stk-tot
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Остатки по объекту"
          ).
      end.

      find last buf_stk-tot no-lock
        where buf_stk-tot.obj-type   = buf_temp-create-stk-tot.obj-type
          and buf_stk-tot.obj-code   = buf_temp-create-stk-tot.obj-code
          and buf_stk-tot.fact-order = v-day-end-fact-order - {&arh-delta}
          and buf_stk-tot.sum-type   = buf_temp-create-stk-tot.sum-type
          and buf_stk-tot.cat-id     = {&root-cat-id}
        no-error .
      if available buf_stk-tot
      then do:
        for each buf_stk-tot exclusive-lock
          where buf_stk-tot.obj-type   = buf_temp-create-stk-tot.obj-type
            and buf_stk-tot.obj-code   = buf_temp-create-stk-tot.obj-code
            and buf_stk-tot.fact-order = v-day-end-fact-order - {&arh-delta}
            and buf_stk-tot.sum-type   begins buf_temp-create-stk-tot.sum-type
        on error undo, return error return-value
        :
          /* todo - сравнить с информацией в buf_temp-stk-tot */
          delete buf_stk-tot .
        end.
      end.
      else do:
        for each buf_stk-tot exclusive-lock
          where buf_stk-tot.obj-type   = buf_temp-create-stk-tot.obj-type
            and buf_stk-tot.obj-code   = buf_temp-create-stk-tot.obj-code
            and buf_stk-tot.fact-order = v-day-end-fact-order
            and buf_stk-tot.sum-type   begins buf_temp-create-stk-tot.sum-type
        on error undo, return error return-value
        :
          /* todo - провести поиск предыдущего stk-tot и проверить отсутствие оборотов */
          delete buf_stk-tot .
        end.
      end.

      if v-shift-on = true
      then do:
        find last buf_stk-tot no-lock
          where buf_stk-tot.obj-type   = buf_temp-create-stk-tot.obj-type
            and buf_stk-tot.obj-code   = buf_temp-create-stk-tot.obj-code
            and buf_stk-tot.fact-order = v-shift-end-fact-order - {&arh-delta}
            and buf_stk-tot.sum-type   = buf_temp-create-stk-tot.sum-type
            and buf_stk-tot.cat-id     = {&root-cat-id}
          no-error .
        if available buf_stk-tot
        then do:
          for each buf_stk-tot exclusive-lock
            where buf_stk-tot.obj-type   = buf_temp-create-stk-tot.obj-type
              and buf_stk-tot.obj-code   = buf_temp-create-stk-tot.obj-code
              and buf_stk-tot.fact-order = v-shift-end-fact-order - {&arh-delta}
              and buf_stk-tot.sum-type   begins buf_temp-create-stk-tot.sum-type
          on error undo, return error return-value
          :
            /* todo - сравнить с информацией в buf_temp-stk-tot */
            delete buf_stk-tot .
          end.
        end.
        else do:
          for each buf_stk-tot exclusive-lock
            where buf_stk-tot.obj-type   = buf_temp-create-stk-tot.obj-type
              and buf_stk-tot.obj-code   = buf_temp-create-stk-tot.obj-code
              and buf_stk-tot.fact-order = v-shift-end-fact-order
              and buf_stk-tot.sum-type   begins buf_temp-create-stk-tot.sum-type
          on error undo, return error return-value
          :
            /* todo - провести поиск предыдущего stk-tot и проверить отсутствие оборотов */
            delete buf_stk-tot .
          end.
        end.
      end.
    end.

    assign
      v-total-count = 0
    .

    for each buf_temp-create-stk-line
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + buf_temp-create-stk-line.artic
          ).
      end.

      find first buf_stk-line no-lock
        where buf_stk-line.obj-type   = buf_temp-create-stk-line.obj-type
          and buf_stk-line.obj-code   = buf_temp-create-stk-line.obj-code
          and buf_stk-line.artic      = buf_temp-create-stk-line.artic
          and buf_stk-line.prod-type  = buf_temp-create-stk-line.prod-type
          and buf_stk-line.prod-code  = buf_temp-create-stk-line.prod-code
          and buf_stk-line.fact-order = v-day-end-fact-order - {&arh-delta}
          and buf_stk-line.sum-type   = buf_temp-create-stk-line.sum-type
          and buf_stk-line.cat-id     = {&root-cat-id}
        no-error .
      if available buf_stk-line
      then do:
        for each buf_stk-line exclusive-lock
          where buf_stk-line.obj-type   = buf_temp-create-stk-line.obj-type
            and buf_stk-line.obj-code   = buf_temp-create-stk-line.obj-code
            and buf_stk-line.artic      = buf_temp-create-stk-line.artic
            and buf_stk-line.prod-type  = buf_temp-create-stk-line.prod-type
            and buf_stk-line.prod-code  = buf_temp-create-stk-line.prod-code
            and buf_stk-line.fact-order = v-day-end-fact-order - {&arh-delta}
            and buf_stk-line.sum-type   begins buf_temp-create-stk-line.sum-type
        on error undo, return error return-value
        :
          /* todo - сравнить с информацией в buf_temp-stk-line */
          delete buf_stk-line .
        end.
      end.
      else do:
        for each buf_stk-line exclusive-lock
          where buf_stk-line.obj-type   = buf_temp-create-stk-line.obj-type
            and buf_stk-line.obj-code   = buf_temp-create-stk-line.obj-code
            and buf_stk-line.artic      = buf_temp-create-stk-line.artic
            and buf_stk-line.prod-type  = buf_temp-create-stk-line.prod-type
            and buf_stk-line.prod-code  = buf_temp-create-stk-line.prod-code
            and buf_stk-line.fact-order = v-day-end-fact-order
            and buf_stk-line.sum-type   begins buf_temp-create-stk-line.sum-type
        on error undo, return error return-value
        :
          /* todo - провести поиск предыдущего stk-line и проверить отсутствие оборотов */
          delete buf_stk-line .
        end.
      end.

      if v-shift-on = true
      then do:
        find first buf_stk-line no-lock
          where buf_stk-line.obj-type   = buf_temp-create-stk-line.obj-type
            and buf_stk-line.obj-code   = buf_temp-create-stk-line.obj-code
            and buf_stk-line.artic      = buf_temp-create-stk-line.artic
            and buf_stk-line.prod-type  = buf_temp-create-stk-line.prod-type
            and buf_stk-line.prod-code  = buf_temp-create-stk-line.prod-code
            and buf_stk-line.fact-order = v-shift-end-fact-order - {&arh-delta}
            and buf_stk-line.sum-type   = buf_temp-create-stk-line.sum-type
            and buf_stk-line.cat-id     = {&root-cat-id}
          no-error .
        if available buf_stk-line
        then do:
          for each buf_stk-line exclusive-lock
            where buf_stk-line.obj-type   = buf_temp-create-stk-line.obj-type
              and buf_stk-line.obj-code   = buf_temp-create-stk-line.obj-code
              and buf_stk-line.artic      = buf_temp-create-stk-line.artic
              and buf_stk-line.prod-type  = buf_temp-create-stk-line.prod-type
              and buf_stk-line.prod-code  = buf_temp-create-stk-line.prod-code
              and buf_stk-line.fact-order = v-shift-end-fact-order - {&arh-delta}
              and buf_stk-line.sum-type   begins buf_temp-create-stk-line.sum-type
          on error undo, return error return-value
          :
            /* todo - сравнить с информацией в buf_temp-stk-line */
            delete buf_stk-line .
          end.
        end.
        else do:
          for each buf_stk-line exclusive-lock
            where buf_stk-line.obj-type   = buf_temp-create-stk-line.obj-type
              and buf_stk-line.obj-code   = buf_temp-create-stk-line.obj-code
              and buf_stk-line.artic      = buf_temp-create-stk-line.artic
              and buf_stk-line.prod-type  = buf_temp-create-stk-line.prod-type
              and buf_stk-line.prod-code  = buf_temp-create-stk-line.prod-code
              and buf_stk-line.fact-order = v-shift-end-fact-order
              and buf_stk-line.sum-type   begins buf_temp-create-stk-line.sum-type
          on error undo, return error return-value
          :
            /* todo - провести поиск предыдущего stk-line и проверить отсутствие оборотов */
            delete buf_stk-line .
          end.
        end.
      end.
    end.

    define buffer buf_gds-obj for ub.gds-obj .
    define buffer buf_doclslib-goods for doclslib-goods .

    for each buf_gds-obj no-lock
      where buf_gds-obj.obj-type = p-obj-type
        and buf_gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      /* для всех товаров, у которых не было оборота в течение периода */
      /* удаляем остатки на конец периода */
      find first buf_doclslib-goods
        where buf_doclslib-goods.artic     = buf_gds-obj.artic
          and buf_doclslib-goods.prod-type = buf_gds-obj.prod-type
          and buf_doclslib-goods.prod-code = buf_gds-obj.prod-code
        no-error .
      if not available buf_doclslib-goods
      then do:
        for each buf_stk-line exclusive-lock
          where buf_stk-line.obj-type   = buf_gds-obj.obj-type
            and buf_stk-line.obj-code   = buf_gds-obj.obj-code
            and buf_stk-line.artic      = buf_gds-obj.artic
            and buf_stk-line.prod-type  = buf_gds-obj.prod-type
            and buf_stk-line.prod-code  = buf_gds-obj.prod-code
            and buf_stk-line.fact-order = v-day-end-fact-order
        on error undo, return error return-value
        :
          delete buf_stk-line .
        end.

        if v-shift-on = true
        then do:
          for each buf_stk-line exclusive-lock
            where buf_stk-line.obj-type   = buf_gds-obj.obj-type
              and buf_stk-line.obj-code   = buf_gds-obj.obj-code
              and buf_stk-line.artic      = buf_gds-obj.artic
              and buf_stk-line.prod-type  = buf_gds-obj.prod-type
              and buf_stk-line.prod-code  = buf_gds-obj.prod-code
              and buf_stk-line.fact-order = v-shift-end-fact-order
          on error undo, return error return-value
          :
            delete buf_stk-line .
          end.
        end.
      end.
    end.
  end.

end procedure. /* ahrstutl-delete-copy */



procedure ahrstutl-update :

  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-first-cut-date     as date      no-undo .
  define input  parameter p-last-cut-date      as date      no-undo .

  define buffer buf_doclslib-goods for doclslib-goods .

  define variable v-shift-on                   as logical   no-undo .
  define variable v-first-shift-date           as date      no-undo .
  define variable v-first-shift-num            as integer   no-undo .
  define variable v-first-day-end-fact-order   as decimal   no-undo .
  define variable v-first-shift-end-fact-order as decimal   no-undo .
  define variable v-last-shift-date            as date      no-undo .
  define variable v-last-shift-num             as integer   no-undo .
  define variable v-last-day-end-fact-order    as decimal   no-undo .
  define variable v-last-shift-end-fact-order  as decimal   no-undo .

  define variable v-gds-goods     as logical   no-undo .
  define variable v-sum-type-list as character no-undo .
  define variable v-ind           as integer   no-undo .

  do
  on error undo, return error return-value
  :
    run factord-cut-archive in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-first-cut-date
      ,output v-shift-on
      ,output v-first-shift-date
      ,output v-first-shift-num
      ,output v-first-day-end-fact-order
      ,output v-first-shift-end-fact-order
      ) .
    run factord-cut-archive in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-last-cut-date
      ,output v-shift-on
      ,output v-last-shift-date
      ,output v-last-shift-num
      ,output v-last-day-end-fact-order
      ,output v-last-shift-end-fact-order
      ) .

    run show-action in this-procedure
      (input "Пересчитываем остаток по объекту"
      ).

    run ahrstutl-tot-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .

    do v-ind = 1 to num-entries(v-sum-type-list)
    :
      run ahrstutl-store-tot in this-procedure
        (input p-obj-type                    /* p-obj-type                   */
        ,input p-obj-code                    /* p-obj-code                   */
        ,input entry(v-ind, v-sum-type-list) /* p-sum-type                   */
        ,input v-shift-on                    /* p-shift-on                   */
        ,input p-first-cut-date              /* p-first-cut-date             */
        ,input p-last-cut-date               /* p-last-cut-date              */
        ,input v-first-day-end-fact-order    /* p-first-day-end-fact-order   */
        ,input v-first-shift-end-fact-order  /* p-first-shift-end-fact-order */
        ,input v-first-shift-date            /* p-first-shift-date           */
        ,input v-first-shift-num             /* p-first-shift-num            */
        ,input v-last-day-end-fact-order     /* p-last-day-end-fact-order    */
        ,input v-last-shift-end-fact-order   /* p-last-shift-end-fact-order  */
        ,input v-last-shift-date             /* p-last-shift-date            */
        ,input v-last-shift-num              /* p-last-shift-num             */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры" 'ahrstutl-store-tot':u skip
          "v-ind" v-ind skip
          "sum-type" entry(v-ind, v-sum-type-list) skip
          return-value skip
          error-status :get-message(1) skip
          view-as alert-box error .
        undo, return error .
      end.
    end.

    run show-action in this-procedure
      (input "Пересчитываем остаток по товару"
      ).
    /* считываем предыдущее (текущее) и все более поздние значения оборота по строке */
    define variable v-total-count as integer   no-undo .

    for each buf_doclslib-goods no-lock
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + string(buf_doclslib-goods.artic)
          ).
      end.

      { gbl/gdscdat.i
        buf_doclslib-goods.gds-code
        "'gds-goods=request':u"
        v-gds-goods
        no-error
      }

      run ahrstutl-line-sum-type-list in this-procedure
        (input  v-gds-goods     /* p-gds-goods     */
        ,output v-sum-type-list /* p-sum-type-list */
        ) .
      do v-ind = 1 to num-entries(v-sum-type-list)
      :
        run ahrstutl-store-line in this-procedure
          (input p-obj-type                    /* p-obj-type                   */
          ,input p-obj-code                    /* p-obj-code                   */
          ,input buf_doclslib-goods.artic      /* p-artic                      */
          ,input buf_doclslib-goods.prod-type  /* p-prod-type                  */
          ,input buf_doclslib-goods.prod-code  /* p-prod-code                  */
          ,input entry(v-ind, v-sum-type-list) /* p-sum-type                   */
          ,input v-shift-on                    /* p-shift-on                   */
          ,input p-first-cut-date              /* p-first-cut-date             */
          ,input p-last-cut-date               /* p-last-cut-date              */
          ,input v-first-day-end-fact-order    /* p-first-day-end-fact-order   */
          ,input v-first-shift-end-fact-order  /* p-first-shift-end-fact-order */
          ,input v-first-shift-date            /* p-first-shift-date           */
          ,input v-first-shift-num             /* p-first-shift-num            */
          ,input v-last-day-end-fact-order     /* p-last-day-end-fact-order    */
          ,input v-last-shift-end-fact-order   /* p-last-shift-end-fact-order  */
          ,input v-last-shift-date             /* p-last-shift-date            */
          ,input v-last-shift-num              /* p-last-shift-num             */
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры" 'ahrstutl-store-line':u skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" buf_doclslib-goods.artic buf_doclslib-goods.prod-type buf_doclslib-goods.prod-code skip
            return-value skip
            error-status :get-message(1) skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
  end.

end procedure. /* ahrstutl-update */

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


procedure ahrstutl-store-tot :

  define input  parameter p-obj-type                   as character no-undo .
  define input  parameter p-obj-code                   as integer   no-undo .
  define input  parameter p-sum-type                   as character no-undo .
  define input  parameter p-shift-on                   as logical   no-undo .
  define input  parameter p-first-cut-date             as date      no-undo .
  define input  parameter p-last-cut-date              as date      no-undo .
  define input  parameter p-first-day-end-fact-order   as decimal   no-undo .
  define input  parameter p-first-shift-end-fact-order as decimal   no-undo .
  define input  parameter p-first-shift-date           as date      no-undo .
  define input  parameter p-first-shift-num            as integer   no-undo .
  define input  parameter p-last-day-end-fact-order    as decimal   no-undo .
  define input  parameter p-last-shift-end-fact-order  as decimal   no-undo .
  define input  parameter p-last-shift-date            as date      no-undo .
  define input  parameter p-last-shift-num             as integer   no-undo .

  define buffer buf_stk-tot for ub.stk-tot .
  define buffer buf_temp-stk-tot for temp-stk-tot .
  define buffer buf_temp-shift-stk-tot for temp-shift-stk-tot .
  define buffer sub_temp-stk-tot for temp-stk-tot .
  define buffer sub_stk-tot for ub.stk-tot .
  define buffer sub_temp-shift-stk-tot for temp-stk-tot .

  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-tot
      where buf_temp-stk-tot.obj-type = p-obj-type
        and buf_temp-stk-tot.obj-code = p-obj-code
        and buf_temp-stk-tot.sum-type = p-sum-type
    on error undo, return error return-value
    :
      if
      &scop fp1   buf_temp-stk-tot.
      &scop fps1
      &scop fp2   <> buf_temp-stk-tot.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
      then do:
        /* ищем первоначальную корневую запись */
        /* если ее нет, то создаем ее */
        find first buf_stk-tot exclusive-lock
          where buf_stk-tot.obj-type   = buf_temp-stk-tot.obj-type
            and buf_stk-tot.obj-code   = buf_temp-stk-tot.obj-code
            and buf_stk-tot.sum-type   = buf_temp-stk-tot.sum-type
            and buf_stk-tot.cat-id     = buf_temp-stk-tot.cat-id
            and buf_stk-tot.fact-order <= p-first-day-end-fact-order
            and buf_stk-tot.shift-date = ?
          no-error .
        if not available buf_stk-tot
        then do:
          create buf_stk-tot .
          assign
            buf_stk-tot.obj-type   = buf_temp-stk-tot.obj-type
            buf_stk-tot.obj-code   = buf_temp-stk-tot.obj-code
            buf_stk-tot.fact-order = p-first-day-end-fact-order
            buf_stk-tot.sum-type   = buf_temp-stk-tot.sum-type
            buf_stk-tot.cat-id     = buf_temp-stk-tot.cat-id
            buf_stk-tot.fact-date  = p-first-cut-date
            buf_stk-tot.shift-num  = 0
            buf_stk-tot.shift-date = ?
          .
        end.

        for each buf_stk-tot exclusive-lock
          where buf_stk-tot.obj-type   = buf_temp-stk-tot.obj-type
            and buf_stk-tot.obj-code   = buf_temp-stk-tot.obj-code
            and buf_stk-tot.sum-type   = buf_temp-stk-tot.sum-type
            and buf_stk-tot.cat-id     = buf_temp-stk-tot.cat-id
            and buf_stk-tot.fact-order <= p-last-day-end-fact-order - {&arh-delta}
            and buf_stk-tot.shift-date = ?
        on error undo, return error return-value
        :
          for each sub_temp-stk-tot
            where sub_temp-stk-tot.obj-type   = buf_temp-stk-tot.obj-type
              and sub_temp-stk-tot.obj-code   = buf_temp-stk-tot.obj-code
              and sub_temp-stk-tot.fact-order = buf_temp-stk-tot.fact-order
              and sub_temp-stk-tot.sum-type   begins buf_temp-stk-tot.sum-type
          on error undo, return error return-value
          :
            if
            &scop fp1   sub_temp-stk-tot.
            &scop fps1
            &scop fp2   <> sub_temp-stk-tot.new-
            &scop fps2
            &scop fp3
            &scop fp4   or
            {&price-pair-list}
            then do:
              find first sub_stk-tot exclusive-lock
                where sub_stk-tot.obj-type   = buf_stk-tot.obj-type
                  and sub_stk-tot.obj-code   = buf_stk-tot.obj-code
                  and sub_stk-tot.fact-order = buf_stk-tot.fact-order
                  and sub_stk-tot.sum-type   = sub_temp-stk-tot.sum-type
                  and sub_stk-tot.cat-id     = sub_temp-stk-tot.cat-id
                no-error .
              if not available sub_stk-tot
              then do:
                create sub_stk-tot .
                assign
                  sub_stk-tot.obj-type   = buf_stk-tot.obj-type
                  sub_stk-tot.obj-code   = buf_stk-tot.obj-code
                  sub_stk-tot.fact-order = buf_stk-tot.fact-order
                  sub_stk-tot.sum-type   = sub_temp-stk-tot.sum-type
                  sub_stk-tot.cat-id     = sub_temp-stk-tot.cat-id
                  sub_stk-tot.fact-date  = buf_stk-tot.fact-date
                  sub_stk-tot.shift-num  = buf_stk-tot.shift-num
                  sub_stk-tot.shift-date = buf_stk-tot.shift-date
                .
              end.
              assign
                &scop fq1    sub_stk-tot.
                &scop fqs1
                &scop fq2    = sub_stk-tot.
                &scop fqs2
                &scop fq3    + sub_temp-stk-tot.
                &scop fqs3
                &scop fq4    - sub_temp-stk-tot.new-
                &scop fqs4
                &scop fq5
                &scop fq6
                {&price-quadro-list}
              .
            end.
          end.
        end.
      end.
    end. /*each tt-stk-tot*/

    if p-shift-on = true
    then do:
      for each buf_temp-shift-stk-tot
        where buf_temp-shift-stk-tot.obj-type = p-obj-type
          and buf_temp-shift-stk-tot.obj-code = p-obj-code
          and buf_temp-shift-stk-tot.sum-type = p-sum-type
      on error undo, return error return-value
      :
        if
        &scop fp1   buf_temp-shift-stk-tot.
        &scop fps1
        &scop fp2   <> buf_temp-shift-stk-tot.new-
        &scop fps2
        &scop fp3
        &scop fp4   or
        {&price-pair-list}
        then do:
          /* ищем первоначальную корневую запись */
          /* если ее нет, то создаем ее */
          find first buf_stk-tot exclusive-lock
            where buf_stk-tot.obj-type   = buf_temp-shift-stk-tot.obj-type
              and buf_stk-tot.obj-code   = buf_temp-shift-stk-tot.obj-code
              and buf_stk-tot.sum-type   = buf_temp-shift-stk-tot.sum-type
              and buf_stk-tot.cat-id     = buf_temp-shift-stk-tot.cat-id
              and buf_stk-tot.fact-order <= p-first-shift-end-fact-order
              and buf_stk-tot.shift-date <> ?
            no-error .
          if not available buf_stk-tot
          then do:
            create buf_stk-tot .
            assign
              buf_stk-tot.obj-type   = buf_temp-shift-stk-tot.obj-type
              buf_stk-tot.obj-code   = buf_temp-shift-stk-tot.obj-code
              buf_stk-tot.fact-order = p-first-shift-end-fact-order
              buf_stk-tot.sum-type   = buf_temp-shift-stk-tot.sum-type
              buf_stk-tot.cat-id     = buf_temp-shift-stk-tot.cat-id
              buf_stk-tot.fact-date  = p-first-cut-date
              buf_stk-tot.shift-num  = p-first-shift-num
              buf_stk-tot.shift-date = p-first-shift-date
            .
          end.

          for each buf_stk-tot exclusive-lock
            where buf_stk-tot.obj-type   = buf_temp-shift-stk-tot.obj-type
              and buf_stk-tot.obj-code   = buf_temp-shift-stk-tot.obj-code
              and buf_stk-tot.sum-type   = buf_temp-shift-stk-tot.sum-type
              and buf_stk-tot.cat-id     = buf_temp-shift-stk-tot.cat-id
              and buf_stk-tot.fact-order <= p-last-shift-end-fact-order - {&arh-delta}
              and buf_stk-tot.shift-date <> ?
          on error undo, return error return-value
          :
            for each sub_temp-shift-stk-tot
              where sub_temp-shift-stk-tot.obj-type   = buf_temp-shift-stk-tot.obj-type
                and sub_temp-shift-stk-tot.obj-code   = buf_temp-shift-stk-tot.obj-code
                and sub_temp-shift-stk-tot.fact-order = buf_temp-shift-stk-tot.fact-order
                and sub_temp-shift-stk-tot.sum-type   begins buf_temp-shift-stk-tot.sum-type
            on error undo, return error return-value
            :
              if
              &scop fp1   sub_temp-shift-stk-tot.
              &scop fps1
              &scop fp2   <> sub_temp-shift-stk-tot.new-
              &scop fps2
              &scop fp3
              &scop fp4   or
              {&price-pair-list}
              then do:
                find first sub_stk-tot exclusive-lock
                  where sub_stk-tot.obj-type   = buf_stk-tot.obj-type
                    and sub_stk-tot.obj-code   = buf_stk-tot.obj-code
                    and sub_stk-tot.fact-order = buf_stk-tot.fact-order
                    and sub_stk-tot.sum-type   = sub_temp-shift-stk-tot.sum-type
                    and sub_stk-tot.cat-id     = sub_temp-shift-stk-tot.cat-id
                  no-error .
                if not available sub_stk-tot
                then do:
                  create sub_stk-tot .
                  assign
                    sub_stk-tot.obj-type   = buf_stk-tot.obj-type
                    sub_stk-tot.obj-code   = buf_stk-tot.obj-code
                    sub_stk-tot.fact-order = buf_stk-tot.fact-order
                    sub_stk-tot.sum-type   = sub_temp-shift-stk-tot.sum-type
                    sub_stk-tot.cat-id     = sub_temp-shift-stk-tot.cat-id
                    sub_stk-tot.fact-date  = buf_stk-tot.fact-date
                    sub_stk-tot.shift-num  = buf_stk-tot.shift-num
                    sub_stk-tot.shift-date = buf_stk-tot.shift-date
                  .
                end.
                assign
                  &scop fq1    sub_stk-tot.
                  &scop fqs1
                  &scop fq2    = sub_stk-tot.
                  &scop fqs2
                  &scop fq3    + sub_temp-shift-stk-tot.
                  &scop fqs3
                  &scop fq4    - sub_temp-shift-stk-tot.new-
                  &scop fqs4
                  &scop fq5
                  &scop fq6
                  {&price-quadro-list}
                .
              end.
            end.
          end.
        end.
      end. /*each tt-stk-tot*/
    end.
  end.

end procedure. /* ahrstutl-store-tot */


procedure ahrstutl-store-line :

  define input  parameter p-obj-type                   as character no-undo .
  define input  parameter p-obj-code                   as integer   no-undo .
  define input  parameter p-artic                      as character no-undo .
  define input  parameter p-prod-type                  as character no-undo .
  define input  parameter p-prod-code                  as integer   no-undo .
  define input  parameter p-sum-type                   as character no-undo .
  define input  parameter p-shift-on                   as logical   no-undo .
  define input  parameter p-first-cut-date             as date      no-undo .
  define input  parameter p-last-cut-date              as date      no-undo .
  define input  parameter p-first-day-end-fact-order   as decimal   no-undo .
  define input  parameter p-first-shift-end-fact-order as decimal   no-undo .
  define input  parameter p-first-shift-date           as date      no-undo .
  define input  parameter p-first-shift-num            as integer   no-undo .
  define input  parameter p-last-day-end-fact-order    as decimal   no-undo .
  define input  parameter p-last-shift-end-fact-order  as decimal   no-undo .
  define input  parameter p-last-shift-date            as date      no-undo .
  define input  parameter p-last-shift-num             as integer   no-undo .


  define buffer buf_stk-line for ub.stk-line .
  define buffer buf_temp-stk-line for temp-stk-line .
  define buffer buf_temp-shift-stk-line for temp-shift-stk-line .
  define buffer sub_temp-stk-line for temp-stk-line .
  define buffer sub_stk-line for ub.stk-line .
  define buffer sub_temp-shift-stk-line for temp-shift-stk-line .

  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-line
      where buf_temp-stk-line.obj-type  = p-obj-type
        and buf_temp-stk-line.obj-code  = p-obj-code
        and buf_temp-stk-line.artic     = p-artic
        and buf_temp-stk-line.prod-type = p-prod-type
        and buf_temp-stk-line.prod-code = p-prod-code
        and buf_temp-stk-line.sum-type  = p-sum-type
    on error undo, return error return-value
    :
      if
      &scop fp1   buf_temp-stk-line.
      &scop fps1
      &scop fp2   <> buf_temp-stk-line.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
      then do:
        /* ищем первоначальную корневую запись */
        /* если ее нет, то создаем ее */
        find first buf_stk-line exclusive-lock
          where buf_stk-line.obj-type   = buf_temp-stk-line.obj-type
            and buf_stk-line.obj-code   = buf_temp-stk-line.obj-code
            and buf_stk-line.artic      = buf_temp-stk-line.artic
            and buf_stk-line.prod-type  = buf_temp-stk-line.prod-type
            and buf_stk-line.prod-code  = buf_temp-stk-line.prod-code
            and buf_stk-line.sum-type   = buf_temp-stk-line.sum-type
            and buf_stk-line.cat-id     = buf_temp-stk-line.cat-id
            and buf_stk-line.fact-order <= p-first-day-end-fact-order
            and buf_stk-line.shift-date = ?
          no-error .
        if not available buf_stk-line
        then do:
          create buf_stk-line .
          assign
            buf_stk-line.obj-type   = buf_temp-stk-line.obj-type
            buf_stk-line.obj-code   = buf_temp-stk-line.obj-code
            buf_stk-line.artic      = buf_temp-stk-line.artic
            buf_stk-line.prod-type  = buf_temp-stk-line.prod-type
            buf_stk-line.prod-code  = buf_temp-stk-line.prod-code
            buf_stk-line.fact-order = p-first-day-end-fact-order
            buf_stk-line.sum-type   = buf_temp-stk-line.sum-type
            buf_stk-line.cat-id     = buf_temp-stk-line.cat-id
            buf_stk-line.fact-date  = p-first-cut-date
            buf_stk-line.shift-num  = 0
            buf_stk-line.shift-date = ?
          .
        end.

        for each buf_stk-line exclusive-lock
          where buf_stk-line.obj-type   = buf_temp-stk-line.obj-type
            and buf_stk-line.obj-code   = buf_temp-stk-line.obj-code
            and buf_stk-line.artic      = buf_temp-stk-line.artic
            and buf_stk-line.prod-type  = buf_temp-stk-line.prod-type
            and buf_stk-line.prod-code  = buf_temp-stk-line.prod-code
            and buf_stk-line.sum-type   = buf_temp-stk-line.sum-type
            and buf_stk-line.cat-id     = buf_temp-stk-line.cat-id
            and buf_stk-line.fact-order <= p-last-day-end-fact-order - {&arh-delta}
            and buf_stk-line.shift-date = ?
        on error undo, return error return-value
        :

          for each sub_temp-stk-line
            where sub_temp-stk-line.obj-type   = buf_temp-stk-line.obj-type
              and sub_temp-stk-line.obj-code   = buf_temp-stk-line.obj-code
              and sub_temp-stk-line.artic      = buf_temp-stk-line.artic
              and sub_temp-stk-line.prod-type  = buf_temp-stk-line.prod-type
              and sub_temp-stk-line.prod-code  = buf_temp-stk-line.prod-code
              and sub_temp-stk-line.fact-order = buf_temp-stk-line.fact-order
              and sub_temp-stk-line.sum-type   begins buf_temp-stk-line.sum-type
          on error undo, return error return-value
          :
            if
            &scop fp1   sub_temp-stk-line.
            &scop fps1
            &scop fp2   <> sub_temp-stk-line.new-
            &scop fps2
            &scop fp3
            &scop fp4   or
            {&price-pair-list}
            then do:
              find first sub_stk-line exclusive-lock
                where sub_stk-line.obj-type   = buf_stk-line.obj-type
                  and sub_stk-line.obj-code   = buf_stk-line.obj-code
                  and sub_stk-line.artic      = buf_stk-line.artic
                  and sub_stk-line.prod-type  = buf_stk-line.prod-type
                  and sub_stk-line.prod-code  = buf_stk-line.prod-code
                  and sub_stk-line.fact-order = buf_stk-line.fact-order
                  and sub_stk-line.sum-type   = sub_temp-stk-line.sum-type
                  and sub_stk-line.cat-id     = sub_temp-stk-line.cat-id
                no-error .
              if not available sub_stk-line
              then do:
                create sub_stk-line .
                assign
                  sub_stk-line.obj-type   = buf_stk-line.obj-type
                  sub_stk-line.obj-code   = buf_stk-line.obj-code
                  sub_stk-line.artic      = buf_stk-line.artic
                  sub_stk-line.prod-type  = buf_stk-line.prod-type
                  sub_stk-line.prod-code  = buf_stk-line.prod-code
                  sub_stk-line.fact-order = buf_stk-line.fact-order
                  sub_stk-line.sum-type   = sub_temp-stk-line.sum-type
                  sub_stk-line.cat-id     = sub_temp-stk-line.cat-id
                  sub_stk-line.fact-date  = buf_stk-line.fact-date
                  sub_stk-line.shift-num  = buf_stk-line.shift-num
                  sub_stk-line.shift-date = buf_stk-line.shift-date
                .
              end.

              assign
                &scop fq1    sub_stk-line.
                &scop fqs1
                &scop fq2    = sub_stk-line.
                &scop fqs2
                &scop fq3    + sub_temp-stk-line.
                &scop fqs3
                &scop fq4    - sub_temp-stk-line.new-
                &scop fqs4
                &scop fq5
                &scop fq6
                {&price-quadro-list}
              .
            end.
          end.
        end.
      end.
    end. /*each tt-stk-line*/

    if p-shift-on = true
    then do:
      for each buf_temp-shift-stk-line
        where buf_temp-shift-stk-line.obj-type  = p-obj-type
          and buf_temp-shift-stk-line.obj-code  = p-obj-code
          and buf_temp-shift-stk-line.artic     = p-artic
          and buf_temp-shift-stk-line.prod-type = p-prod-type
          and buf_temp-shift-stk-line.prod-code = p-prod-code
          and buf_temp-shift-stk-line.sum-type  = p-sum-type
      on error undo, return error return-value
      :
        if
        &scop fp1   buf_temp-shift-stk-line.
        &scop fps1
        &scop fp2   <> buf_temp-shift-stk-line.new-
        &scop fps2
        &scop fp3
        &scop fp4   or
        {&price-pair-list}
        then do:
          /* ищем первоначальную корневую запись */
          /* если ее нет, то создаем ее */
          find first buf_stk-line exclusive-lock
            where buf_stk-line.obj-type   = buf_temp-shift-stk-line.obj-type
              and buf_stk-line.obj-code   = buf_temp-shift-stk-line.obj-code
              and buf_stk-line.artic      = buf_temp-shift-stk-line.artic
              and buf_stk-line.prod-type  = buf_temp-shift-stk-line.prod-type
              and buf_stk-line.prod-code  = buf_temp-shift-stk-line.prod-code
              and buf_stk-line.sum-type   = buf_temp-shift-stk-line.sum-type
              and buf_stk-line.cat-id     = buf_temp-shift-stk-line.cat-id
              and buf_stk-line.fact-order <= p-first-shift-end-fact-order
              and buf_stk-line.shift-date <> ?
            no-error .
          if not available buf_stk-line
          then do:
            create buf_stk-line .
            assign
              buf_stk-line.obj-type   = buf_temp-shift-stk-line.obj-type
              buf_stk-line.obj-code   = buf_temp-shift-stk-line.obj-code
              buf_stk-line.artic      = buf_temp-shift-stk-line.artic
              buf_stk-line.prod-type  = buf_temp-shift-stk-line.prod-type
              buf_stk-line.prod-code  = buf_temp-shift-stk-line.prod-code
              buf_stk-line.fact-order = p-first-shift-end-fact-order
              buf_stk-line.sum-type   = buf_temp-shift-stk-line.sum-type
              buf_stk-line.cat-id     = buf_temp-shift-stk-line.cat-id
              buf_stk-line.fact-date  = p-first-cut-date
              buf_stk-line.shift-num  = p-first-shift-num
              buf_stk-line.shift-date = p-first-shift-date
            .
          end.

          for each buf_stk-line exclusive-lock
            where buf_stk-line.obj-type   = buf_temp-shift-stk-line.obj-type
              and buf_stk-line.obj-code   = buf_temp-shift-stk-line.obj-code
              and buf_stk-line.artic      = buf_temp-shift-stk-line.artic
              and buf_stk-line.prod-type  = buf_temp-shift-stk-line.prod-type
              and buf_stk-line.prod-code  = buf_temp-shift-stk-line.prod-code
              and buf_stk-line.sum-type   = buf_temp-shift-stk-line.sum-type
              and buf_stk-line.cat-id     = buf_temp-shift-stk-line.cat-id
              and buf_stk-line.fact-order <= p-last-shift-end-fact-order - {&arh-delta}
              and buf_stk-line.shift-date <> ?
          on error undo, return error return-value
          :

            for each sub_temp-shift-stk-line
              where sub_temp-shift-stk-line.obj-type   = buf_temp-shift-stk-line.obj-type
                and sub_temp-shift-stk-line.obj-code   = buf_temp-shift-stk-line.obj-code
                and sub_temp-shift-stk-line.artic      = buf_temp-shift-stk-line.artic
                and sub_temp-shift-stk-line.prod-type  = buf_temp-shift-stk-line.prod-type
                and sub_temp-shift-stk-line.prod-code  = buf_temp-shift-stk-line.prod-code
                and sub_temp-shift-stk-line.fact-order = buf_temp-shift-stk-line.fact-order
                and sub_temp-shift-stk-line.sum-type   begins buf_temp-shift-stk-line.sum-type
            on error undo, return error return-value
            :
              if
              &scop fp1   sub_temp-shift-stk-line.
              &scop fps1
              &scop fp2   <> sub_temp-shift-stk-line.new-
              &scop fps2
              &scop fp3
              &scop fp4   or
              {&price-pair-list}
              then do:
                find first sub_stk-line exclusive-lock
                  where sub_stk-line.obj-type   = buf_stk-line.obj-type
                    and sub_stk-line.obj-code   = buf_stk-line.obj-code
                    and sub_stk-line.artic      = buf_stk-line.artic
                    and sub_stk-line.prod-type  = buf_stk-line.prod-type
                    and sub_stk-line.prod-code  = buf_stk-line.prod-code
                    and sub_stk-line.fact-order = buf_stk-line.fact-order
                    and sub_stk-line.sum-type   = sub_temp-shift-stk-line.sum-type
                    and sub_stk-line.cat-id     = sub_temp-shift-stk-line.cat-id
                  no-error .
                if not available sub_stk-line
                then do:
                  create sub_stk-line .
                  assign
                    sub_stk-line.obj-type   = buf_stk-line.obj-type
                    sub_stk-line.obj-code   = buf_stk-line.obj-code
                    sub_stk-line.artic      = buf_stk-line.artic
                    sub_stk-line.prod-type  = buf_stk-line.prod-type
                    sub_stk-line.prod-code  = buf_stk-line.prod-code
                    sub_stk-line.fact-order = buf_stk-line.fact-order
                    sub_stk-line.sum-type   = sub_temp-shift-stk-line.sum-type
                    sub_stk-line.cat-id     = sub_temp-shift-stk-line.cat-id
                    sub_stk-line.fact-date  = buf_stk-line.fact-date
                    sub_stk-line.shift-num  = buf_stk-line.shift-num
                    sub_stk-line.shift-date = buf_stk-line.shift-date
                  .
                end.
                assign
                  &scop fq1    sub_stk-line.
                  &scop fqs1
                  &scop fq2    = sub_stk-line.
                  &scop fqs2
                  &scop fq3    + sub_temp-shift-stk-line.
                  &scop fqs3
                  &scop fq4    - sub_temp-shift-stk-line.new-
                  &scop fqs4
                  &scop fq5
                  &scop fq6
                  {&price-quadro-list}
                .
              end.
            end.
          end.
        end.
      end. /*each tt-stk-line*/
    end.
  end.

end procedure. /* ahrstutl-store-line */


procedure cb_rst-arh_overturn-exist :

  define input  parameter p-artic          as character no-undo .
  define input  parameter p-prod-type      as character no-undo .
  define input  parameter p-prod-code      as integer   no-undo .
  define output parameter p-overturn-exist as logical   no-undo .

  define buffer buf_doclslib-goods for doclslib-goods .

  do
  on error undo, return error return-value
  :
    find first buf_doclslib-goods
      where buf_doclslib-goods.artic     = p-artic
        and buf_doclslib-goods.prod-type = p-prod-type
        and buf_doclslib-goods.prod-code = p-prod-code
      no-error .
    if available buf_doclslib-goods
    then do:
      assign
        p-overturn-exist = true
      .
    end.
    else do:
      assign
        p-overturn-exist = false
      .
    end.
  end.

end procedure. /* cb_rst-arh_overturn-exist */


procedure check-md5-signature :

  define input  parameter p-obj-type     as character no-undo .
  define input  parameter p-obj-code     as integer   no-undo .
  define input  parameter p-archive-type as character no-undo .
  define input  parameter p-file-name    as character no-undo .

  define buffer buf_archive-history for ub.archive-history .

  do
  on error undo, return error return-value
  :
    find first buf_archive-history exclusive-lock
      where buf_archive-history.obj-type     = p-obj-type
        and buf_archive-history.obj-code     = p-obj-code
        and buf_archive-history.archive-type = p-archive-type
        and buf_archive-history.file-valid   = true
        and buf_archive-history.file-name    = p-file-name
      no-error .
    if not available buf_archive-history
    then do:
      message
        "Складской архив по товарам" skip
        "Объект" p-obj-type p-obj-code skip
        "Отсутствует информация о выгрузке файла" skip
        "Файл" p-file-name skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    define variable v-md5-signature as character no-undo .

    run gbl/md5.p
      (input  p-file-name     /* p-file-name     */
      ,output v-md5-signature /* p-md5-signature */
      ) .

    if v-md5-signature <> buf_archive-history.file-md5
    then do:
      message
        "Складской архив по товарам" skip
        "Объект" p-obj-type p-obj-code skip
        "Контрольная сумма файла не совпадает с информацией о выгрузке файла" skip
        "Файл" p-file-name skip
        "Контрольная сумма" v-md5-signature skip
        "Информация о выгрузке файла" buf_archive-history.file-md5 skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

end procedure. /* check-md5-signature */


procedure invalidate-md5-signature :

  define input  parameter p-obj-type     as character no-undo .
  define input  parameter p-obj-code     as integer   no-undo .
  define input  parameter p-archive-type as character no-undo .
  define input  parameter p-file-name    as character no-undo .
  define input  parameter p-chip-num     as integer   no-undo .

  define buffer buf_archive-history for ub.archive-history .

  do
  on error undo, return error return-value
  :
    find first buf_archive-history exclusive-lock
      where buf_archive-history.obj-type     = p-obj-type
        and buf_archive-history.obj-code     = p-obj-code
        and buf_archive-history.archive-type = p-archive-type
        and buf_archive-history.file-valid   = true
        and buf_archive-history.file-name    = p-file-name
      no-error .
    if available buf_archive-history
    then do:
      assign
        buf_archive-history.file-valid            = false
        buf_archive-history.file-invalid-chip-num = p-chip-num
      .
    end.

  end.

end procedure. /* invalidate-md5-signature */


procedure fill-artic :

  define input  parameter p-gds-code  as integer   no-undo .
  define output parameter p-artic     as character no-undo .
  define output parameter p-prod-type as character no-undo .
  define output parameter p-prod-code as integer   no-undo .

  define buffer buf_temp-goods for temp-goods .
  define buffer buf_goods for ub.goods .

  do
  on error undo, return error return-value
  :
    find first buf_temp-goods
      where buf_temp-goods.gds-code = p-gds-code
      no-error .
    if not available buf_temp-goods
    then do:
      find first buf_goods no-lock
        where buf_goods.gds-code = p-gds-code
        no-error .
      if not available buf_goods
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден товар" skip
          "Код товара" p-gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      create buf_temp-goods .
      assign
        buf_temp-goods.gds-code  = p-gds-code
        buf_temp-goods.artic     = buf_goods.artic
        buf_temp-goods.prod-type = buf_goods.prod-type
        buf_temp-goods.prod-code = buf_goods.prod-code
      .
    end.

    assign
      p-artic     = buf_temp-goods.artic
      p-prod-type = buf_temp-goods.prod-type
      p-prod-code = buf_temp-goods.prod-code
    .
  end.

end procedure. /* fill-artic */