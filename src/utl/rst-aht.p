block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rst-aht.p $
$Archive: utl/rst-aht.p $

Восстановление складского архива по типам приобретения.

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 01/09/04

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: rst-aht.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/rst-aht.p $":U .
define variable vss-description as character no-undo initial "Восстановление складского архива по типам приобретения".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ trg/factord.i  }
{ gbl/clntattr.i }
{ trg/doclslib.i }
{ gbl/aht.i      }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define temp-table temp-create-aht-stk-tot no-undo
   field obj-type as character
   field obj-code as integer
   field sum-type as character
   field need-create as logical
   index xpk is primary unique obj-type obj-code sum-type
   index xie1 need-create
.
define temp-table temp-create-aht-stk-line no-undo
   field obj-type  as character
   field obj-code  as integer
   field gds-code  as integer
   field sum-type  as character
   field need-create as logical
   index xpk is primary unique obj-type obj-code gds-code sum-type
   index xie1 need-create
.

define stream slog .
define stream sinp .
define stream sout .

define buffer calc-aht-lock_batchprocess for ub.batchprocess .

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
  define variable rid-list as character no-undo .

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
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "В данный момент восстанавливается складской архив по типам приобретения" skip
        "Невозможно произвести восстановлением складского архива по типам приобретения" skip
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
    ,input "Объект,,, ,,,Расчёт складского архива по типам приобретения"
    ,input true
    ,buffer calc-aht-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "В данный момент рассчитывается складской архив по типам приобтерения" skip
        "Невозможно произвести восстановление складского архива по типам приобретения" skip
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

  if (v-aht-start-date <> ?
     and v-aht-detail-date = ?)
  or (v-aht-start-date = ?
     and v-aht-detail-date <> ?)
  then do:
    message
      "Складской архив по типам приобретения" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести восстановление складского архива по типам приобретения" skip
      "Противоречивая информация в датах инициализации складского архива" skip
      "Дата начала складского архива по типам приобретения" string(v-aht-start-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по типам приобретения" string(v-aht-detail-date, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if v-aht-detail-date = ?
  then do:
    message
      "Складской архив по типам приобретения" skip
      "Объект" v-obj-type v-obj-code skip
      "На объекте рассчитан складской архив по типам приобретения за все даты" skip
      "Операция восстановления не может быть произведена" skip
      view-as alert-box information .
    return .
  end.

  /* автоматически создаем имя файла для считывания складского архива по типам приобретения */
  define variable v-year  as integer   no-undo .
  define variable v-month as integer   no-undo .
  define variable v-day   as integer   no-undo .

  assign
    v-year  = year(v-aht-detail-date)
    v-month = month(v-aht-detail-date)
    v-day   = day(v-aht-detail-date)
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
           + "Произвести восстановление подробного складского архива по типам приобретения" + {&new-line}
           + "Дата начала подробного складского архива по типам приобретения " + string(v-aht-detail-date, '99/99/9999':U) + {&new-line}
           + "Сегодня " + string(v-today, '99/99/9999':U) + {&new-line}
    ,input '|^':u /* Символы разделители для кодирования двух следующих параметров */
                  /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                  /* второй символ - разделитель атрибутов в описании кнопок */
    ,input "Из файла" + '^confirm':u + (if v-restore-from-file = true then '':u else '^disable':u)
    + '|':u + "Резервная копия" + '^confirm':u + (if v-restore-backup = true then '':u else '^disable':u)
    + '|':u + "Документы" + '^confirm':u + (if v-aht-del = true then '^disable':u else '':u)
    + '|':u + "Отказ" /* список названий кнопок  */
                      /* каждая кнопка может иметь необязательный */
                      /* список атрибутов, влияющих на поведение кнопки */
    ,input (if v-restore-from-file then substitute("Восстановить из файла &1", v-full-file-name)
            else substitute("Файл с сохраненными данными &1 не найден", v-file-name ) )
        + "|":u +
           (if v-restore-from-file then substitute("Восстановить из резервной копии &1", v-backup-file-name)
            else substitute("Файл резервной копии &1 не найден", v-backup-file-name) )
        + "|":u + (if v-aht-del
                   then "Была ошибка при предыдущем Удалении/Восстановлении" + {&new-line}
                        + "Архив по типам приобретения можно восстановить только из файла"
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
        ,input  {&btpr-type-aht}
        ,input  v-file-name
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Складской архив по типам приобретения" skip
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
        ,input  v-aht-detail-date     /* p-cut-date            */
        ,input  v-file-name           /* p-file-name           */
        ,output v-restore-start-date  /* p-restore-start-date  */
        ,output v-restore-detail-date /* p-restore-detail-date */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Складской архив по типам приобретения" skip
          "Объект" v-obj-type v-obj-code skip
          "Ошибка при проверке данных файла архивации" skip
          "Имя файла архивации" v-file-name skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
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
        ,input  {&btpr-type-aht}
        ,input  v-file-name
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Складской архив по типам приобретения" skip
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
        ,input  v-aht-detail-date     /* p-cut-date            */
        ,input  v-file-name           /* p-file-name           */
        ,output v-restore-start-date  /* p-restore-start-date  */
        ,output v-restore-detail-date /* p-restore-detail-date */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Складской архив по типам приобретения" skip
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
      if v-aht-del = true
      then do:
        message
          "Складской архив по типам приобретения" skip
          "Объект" v-obj-type v-obj-code skip
          "Невозможно произвести восстановление на основании документов" skip
          "Остатки складского архива по типам приобретения не рассчитаны" skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if  v-aht-recalc-date <> ?
      and v-aht-recalc-date <= v-aht-detail-date
      then do:
        message
          "Складской архив по типам приобретения" skip
          "Объект" v-obj-type v-obj-code skip
          "Невозможно произвести восстановление на основании документов" skip
          "Дата перерасчета складского архива по типам приобретения меньше даты начала подробного складского архива по типам приобретения" skip
          "Дата перерасчета складского архива по типам приобретения" string(v-aht-recalc-date, '99/99/9999':u) skip
          "Дата начала подробного складского архива по типам приобретени " string(v-aht-detail-date, '99/99/9999':u) skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      assign
        v-restore-from-file = false
        v-restore-backup    = false
      .

      /* отступаем на месяц от текущей даты начала подробного складского архива по типам приобретения */
      assign
        v-month = month(v-aht-detail-date)
        v-year  = year(v-aht-start-date)
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
        /* отказ от восстановления складского архива */
        message
          "Складской архив по типам приобретения" skip
          "Объект" v-obj-type v-obj-code skip
          "Дата расчета складского архива по типам приобретения не задана" skip
          "Восстановление складского архива не было произведено" skip
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
          "Складской архив по типам приобретения" skip
          "Объект" v-obj-type v-obj-code skip
          "Ошибка при выборе даты" skip
          "Месяц" v-month skip
          "Год" v-year skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if v-restore-detail-date >= v-aht-detail-date
      then do:
        message
          "Складской архив по типам приобретения" skip
          "Объект" v-obj-type v-obj-code skip
          "Неправильная дата расчета складского архива по типам приобретения" skip
          "Дата восстановления складского архива не может быть больше, чем дата на которую" skip
          "имеется рассчитанный складской архив" skip
          "Дата восстановление подробного складского архива по типам приобретения" string(v-restore-detail-date, '99/99/9999':u) skip
          "Дата начала подробного складского архива по типам приобретения" string(v-aht-detail-date, '99/99/9999':u) skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if v-restore-detail-date >= v-aht-start-date
      then do:
        /* производится перерасчет без удаления первоначального остатка */
        assign
          v-clear-start = false
          v-restore-start-date = v-aht-start-date
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
      /* отказ от расчета складского архива по типам приобретения */
      return .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "Внутрення ошибка" skip
        "Неизвестное значение v-num" v-num skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .

  assign
    v-ok = false
  .
  define variable v-aht-source as character no-undo .
  if v-restore-from-file = true
  then do:
    assign
      v-aht-source = "Восстановление складского архива по типам приобретения из файла " + v-file-name
    .
  end.
  else do:
    assign
      v-aht-source = "Рассчёт складского архива по типам приобретения на основании первичных документов"
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
      "Складской архив по типам приобретения" skip
      "Объект" v-obj-type v-obj-code skip
      "Внутренняя ошибка" skip
      "Противоречивая информация в датах начала складского архива и начала подробного складского архива" skip
      "Дата начала складского архива" string(v-restore-start-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива" string(v-restore-detail-date, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  message
    "Складской архив по типам приобретения" skip
    "Объект" v-obj-type v-obj-code skip
    "Последнее предупреждение перед восстановлением складского архива по типам приобретения" skip
    "Дата с которой существует складской архив по типам приобретения" string(v-aht-start-date, '99/99/9999':u) skip
    "Дата с которой имеются подробный складской архив по типам приобретения" string(v-aht-detail-date, '99/99/9999':u) skip
    "" skip
    "Дата с которой будет начинаться складской архив по типам приобретения после восстановления" string(v-restore-start-date, '99/99/9999':u) skip
    "Дата с которой будет начинаться подробный складской архив по типам приобретения после восстановления" string(v-restore-detail-date, '99/99/9999':u) skip
    ""
    "" skip
    "Сегодня" string(v-today, '99/99/9999':u) skip
    "" v-aht-source skip
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
    title "Расчет складского архива по типам приобретения"
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
    (input  v-aht-detail-date - 1   /* p-fact-date            */
    ,output v-day-end-fact-order    /* p-day-end-fact-order   */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Складской архив по типам приобретения" skip
      "Объект" v-obj-type v-obj-code skip
      "Ошибка при вызове процедуры factord"
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if  v-aht-del        = false
  and v-restore-backup = false
  then do:
    /* создаем файл для резервного копирования складского архива по типам приобретения */
    run create-log-file in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input v-aht-start-date
      ,input v-aht-detail-date
      ,input v-aht-start-date
      ,input v-aht-detail-date
      ,input v-backup-file-name
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при создании файла архивации" skip
        "Имя файла архивации" v-file-name skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* сохраняем складской архив типам приобретения */
    run trg/ahtclr.p
      (input v-obj-type           /* p-obj-type         */
      ,input v-obj-code           /* p-obj-code         */
      ,input 0                    /* p-last-fact-order  */
      ,input v-day-end-fact-order /* p-cut-fact-order   */
      ,input v-backup-file-name   /* v-export-file-name */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при cохранении складского архива по типам приобретения"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* закрываем файл архивации */
    run close-log-file in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input v-aht-start-date
      ,input v-aht-detail-date
      ,input v-aht-start-date
      ,input v-aht-detail-date
      ,input v-backup-file-name
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
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
      ,input  {&btpr-type-aht}      /* p-archive-type          */
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
      ,input  {&btpr-type-aht}      /* p-archive-type          */
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
        "Складской архив по типам приобретения" skip
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
    /* помечаем складской архив как удаленые */
    run clntattr-write in this-procedure
      (input v-obj-type      /* p-obj-type */
      ,input v-obj-code      /* p-obj-code */
      ,input {&attr-aht-del} /* p-code     */
      ,input 'true':u        /* p-value    */
      ) .

    /* удаляем складской архив по типам приобретения */
    run trg/ahtclr.p
      (input v-obj-type                 /* p-obj-type         */
      ,input v-obj-code                 /* p-obj-code         */
      ,input v-start-day-end-fact-order /* p-last-fact-order  */
      ,input v-day-end-fact-order       /* p-cut-fact-order   */
      ,input ""                         /* v-export-file-name */
      )  no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при удалении складского архива по типам приобретения" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* импорт складского архива из файла */
    input stream slog from value(v-file-name) .

    /* проверка правильного формата файла */
    run validate-file-name in this-procedure
      (input  v-obj-type            /* p-obj-type            */
      ,input  v-obj-code            /* p-obj-code            */
      ,input  v-aht-detail-date     /* p-cut-date            */
      ,input  v-file-name           /* p-file-name           */
      ,output v-restore-start-date  /* p-restore-start-date  */
      ,output v-restore-detail-date /* p-restore-detail-date */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
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
      ,input  v-aht-detail-date           /* p-cut-date     */
      ,input  v-file-name                 /* p-file-name    */
      ,output v-close-restore-start-date  /* p-restore-start-date  */
      ,output v-close-restore-detail-date /* p-restore-detail-date */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
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
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при закрытии файла архивации" skip
        "Не соответствие дат начала архива и начала подробного архива в конце и в начала файла" skip
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
      ,input {&attr-aht-start-date}                     /* p-code     */
      ,input string(v-restore-start-date, '99/99/9999':u) /* p-value    */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала складского архива по типам приобретения" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    run clntattr-write in this-procedure
      (input v-obj-type                                  /* p-obj-type */
      ,input v-obj-code                                  /* p-obj-code */
      ,input {&attr-aht-detail-date}                     /* p-code     */
      ,input string(v-restore-detail-date, '99/99/9999':u) /* p-value    */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала подробного складского архива по типам приобретения" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    define variable v-delete-aht-del as logical   no-undo .

    /* восстановление складского архива прошло успешно */
    /* удаляем признак того, что была ошибка при удалении архива */
    run clntattr-delete in this-procedure
      (input  v-obj-type       /* p-obj-type */
      ,input  v-obj-code       /* p-obj-code */
      ,input  {&attr-aht-del}  /* p-code     */
      ,output v-delete-aht-del /* p-deleted  */
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
      undo, return error .
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
      undo, return error .
    end.

    run doclslib-clear-rst in this-procedure
      (input v-aht-detail-date
      ) .

    /* составление списка товаров */
    run doclslib-init-goods in this-procedure .

    /* складской архив помечается как восстанавливающийся */
    run clntattr-write in this-procedure
      (input v-obj-type       /* p-obj-type */
      ,input v-obj-code       /* p-obj-code */
      ,input {&attr-aht-rest} /* p-code     */
      ,input 'true':u         /* p-value    */
      ) .

    /* считываем старые остатки на конец рассчитываемого диапазона */
    run ahrstutl-init in this-procedure
      (input  v-obj-type            /* p-obj-type  */
      ,input  v-obj-code            /* p-obj-code  */
      ,input  v-aht-detail-date - 1 /* p-fact-date */
      ,input  1                     /* p-sign      */
      ) .

    /* создание остатков на текущую дату начала складского архива */
    run ahrstutl-create-stk in this-procedure
      (input  v-obj-type            /* p-obj-type  */
      ,input  v-obj-code            /* p-obj-code  */
      ,input  v-aht-detail-date - 1 /* p-fact-date */
      ) .

    /* удаление складского архива до текущей даты */
    /* следует независимо удалять складской архив по дням и складской архив по сменам */
    run ahrstutl-clear-aht in this-procedure
      (input  v-obj-type                 /* p-obj-type  */
      ,input  v-obj-code                 /* p-obj-code  */
      ,input  v-start-day-end-fact-order /* p-start-fact-order */
      ,input  v-aht-detail-date - 1      /* p-fact-date */
      ) .

    /* снятие блокировки на расчёт складского архива */
    find current calc-aht-lock_batchprocess no-lock .

    if v-clear-start = true
    then do:
      run show-action in this-procedure
        (input "Инициализация остатка на дату нового начала складского архива по типам приобретения"
        ).
      /* инициализация остатков на дату нового начала складского архива */
      run trg/inaht.p
        (input  this-procedure :handle   /* p-handle-callback    */
        ,input  v-obj-type               /* p-obj-type           */
        ,input  v-obj-code               /* p-obj-code           */
        ,input  v-restore-start-date - 1 /* p-new-start-date     */
        ,input  v-aht-detail-date - 1    /* p-current-start-date */
        ) .
    end.

    run show-action in this-procedure
      (input "Расчёт складского архива по типам приобретения"
      ).

    /* расчет складского архива с ограничением на обновление остатков */
    run doclslib-calc-aht in this-procedure
      (input this-procedure        /* p-log-handle    */
      ,input v-obj-type            /* p-obj-type      */
      ,input v-obj-code            /* p-obj-code      */
      ,input v-aht-detail-date - 1 /* p-cut-date      */
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
        ,input v-aht-detail-date - 1 /* p-fact-date */
        ,input -1                    /* p-save-new  */
        ) .

      /* происходит обновление накопительных остатков */
      /* на основании новых рассчитанных остатков и старых остатков */
      run ahrstutl-update in this-procedure
        (input v-obj-type                /* p-obj-type       */
        ,input v-obj-code                /* p-obj-code       */
        ,input v-restore-detail-date - 1 /* p-first-cut-date */
        ,input v-aht-detail-date - 1     /* p-last-cut-date  */
        ) .
    end.

    run show-action in this-procedure
      (input "Блокировка расчёта складского архива по типам приобретения"
      ).

    /* блокировка расчёта складского архива */
    define variable v-need-stop-aht as logical   no-undo .

    assign
      v-need-stop-aht = false
    .

    run gbl/lock-prc.p
      (input {&lock-prc-calc-aht}
      ,input v-obj-code
      ,input 0
      ,input 0
      ,input v-obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
      ,input false
      ,buffer calc-aht-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры блокировки расчета складского архива по типам приобретения" skip
          "Невозможно продолжить восстановление складского архива по типам приобретения" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error "Ошибка при вызове процедуры блокировки расчёта складского архива по типам приобретения" .
      end.
      assign
        v-need-stop-aht = true
      .
    end.

    define buffer stop-aht-restore-lock_btpr for batchprocess .

    if v-need-stop-aht = true
    then do:
      /* если расчёт складского архива заблокирован, */
      /* отправить команду на остановку процесса расчёта складского архива */
      do transaction
      on error undo, return error return-value
      :
        create stop-aht-restore-lock_btpr .
        assign
          stop-aht-restore-lock_btpr.bp_type       = {&btpr-type-lock} + {&lock-prc-stop-arh-restore}
          stop-aht-restore-lock_btpr.bp_status     = {&btpr-normal}
          stop-aht-restore-lock_btpr.Key#_One      = v-obj-code
          stop-aht-restore-lock_btpr.Key#_Two      = 0
          stop-aht-restore-lock_btpr.Key#_Three    = 0
          stop-aht-restore-lock_btpr.CharKey_One   = v-obj-type
          stop-aht-restore-lock_btpr.CharKey_Two   = ""
          stop-aht-restore-lock_btpr.CharKey_Three = ""
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
            (input waitfram-join-function("Архив рассчитывается на другой машине"
                                         ,"Отправлено сообщение о необходимости остановки расчёта складского архива"
                                         ,substitute("Ожидание освобождения ресурса расчёта складского архива &1", string(v-start-lock-second, 'HH:MM:SS':U))
                                         )
            ) .
          run gbl/lock-prc.p
            (input {&lock-prc-calc-aht}
            ,input v-obj-code
            ,input 0
            ,input 0
            ,input v-obj-type
            ,input ""
            ,input ""
            ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
            ,input false
            ,buffer calc-aht-lock_batchprocess
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры блокировки расчета складского архива по типам приобретения" skip
                "Невозможно продолжить восстановление складского архива по типам приобретения" skip
                view-as alert-box error .
              undo, return error "В данный момент рассчитывается складской архив по типам приобретения" .
            end.
          end.
          else do:
            run waitfram-hide in this-procedure .
            leave wait_block .
          end.
          pause 1 no-message .
        end.

        delete stop-aht-restore-lock_btpr .
      end.
    end.

    run show-action in this-procedure
      (input "Удаление повторных записей остатков"
      ).

    /* удаление ненужных повторных записей старых остатков и новых остатков */
    run ahrstutl-delete-copy in this-procedure
      (input v-obj-type            /* p-obj-type  */
      ,input v-obj-code            /* p-obj-code  */
      ,input v-aht-detail-date - 1 /* p-fact-date */
      ) .

    run show-action in this-procedure
      (input "Обновление атрибутов складского архива"
      ).

    run clntattr-write in this-procedure
      (input v-obj-type                                 /* p-obj-type */
      ,input v-obj-code                                 /* p-obj-code */
      ,input {&attr-aht-start-date}                     /* p-code     */
      ,input string(v-restore-start-date, '99/99/9999':u) /* p-value    */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала складского архива по типам приобретения" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    run clntattr-write in this-procedure
      (input v-obj-type                                  /* p-obj-type */
      ,input v-obj-code                                  /* p-obj-code */
      ,input {&attr-aht-detail-date}                     /* p-code     */
      ,input string(v-restore-detail-date, '99/99/9999':u) /* p-value    */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала подробного складского архива по типам приобретения" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    define variable v-delete-aht-rest as logical   no-undo .

    /* восстановление складского архива прошло успешно */
    /* удаляем признак того, что была ошибка при удалении складского архива */
    run clntattr-delete in this-procedure
      (input  v-obj-type        /* p-obj-type */
      ,input  v-obj-code        /* p-obj-code */
      ,input  {&attr-aht-rest}  /* p-code     */
      ,output v-delete-aht-rest /* p-deleted  */
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
    ,input  {&btpr-type-aht}      /* p-archive-type          */
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
    ,input  {&btpr-type-aht}  /* p-archive-type */
    ,input  v-file-name       /* p-file-name    */
    ,input  v-create-chip-num /* p-chip-num     */
    ) .

  run invalidate-md5-signature in this-procedure
    (input  v-obj-type         /* p-obj-type     */
    ,input  v-obj-code         /* p-obj-code     */
    ,input  {&btpr-type-aht}   /* p-archive-type */
    ,input  v-backup-file-name /* p-file-name    */
    ,input  v-create-chip-num  /* p-chip-num     */
    ) .

  message
    "Складской архив по типам приобретения" skip
    "Объект" v-obj-type v-obj-code skip
    "Восстановление складского архива по типам приобретения успешно закончилось" skip
    "Объект" v-obj-type v-obj-code skip
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

  &glob import-table when '~{&table-name~}':u then do: ~
    define buffer buf_~{&table-name~} for ub.~{&table-name~} . ~
    create buf_~{&table-name~} . ~
    import stream sinp buf_~{&table-name~} no-error . ~
    if error-status :error then do: ~
      message ~
        vss-workfile vss-revision vss-description skip ~
        "Ошибка при импорте таблицы ~{&table-name~}" skip ~
        "Строка" v-line-num skip ~
        error-status :get-message(1) skip ~
        view-as alert-box error . ~
      undo, return error . ~
    end. ~
    assign ~
      v-line-num = v-line-num + 1 ~
    . ~
  end.

      case v-key-value :

  &scop table-name aht-doc
        {&import-table}
  &scop table-name aht-gds
        {&import-table}
  &scop table-name aht-stk
        {&import-table}
  &scop table-name aht-time
        {&import-table}
  &scop table-name aht-ot-tot
        {&import-table}
  &scop table-name aht-ot-line
        {&import-table}
  &scop table-name aht-stk-tot
        {&import-table}
  &scop table-name aht-stk-line
        {&import-table}

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
            "Складской архив по типам приобретения" skip
            "Объект" v-obj-type v-obj-code skip
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
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "Не найден признак окончания данных" skip
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
  define input parameter  v-aht-detail-date     as date      no-undo .
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
        "Складской архив по типам приобретения" skip
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
        "Складской архив по типам приобретения" skip
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
        "Складской архив по типам приобретения" skip
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
        "Складской архив по типам приобретения" skip
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
        "Складской архив по типам приобретения" skip
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
        "Складской архив по типам приобретения" skip
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
        "Складской архив по типам приобретения" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error .
    end.

    if v-aht-detail-date <> date(v-param-value)
    then do:
      message
        "Складской архив по типам приобретения" skip
        "Объект" p-obj-type p-obj-code skip
        "Несоответствие текущей даты начала подробного архива" skip
        "и даты начала подробного архива в файле" p-file-name skip
        "Строка" v-line-num skip
        "Текущая дата начала подробного архива" string(v-aht-detail-date) skip
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
  on error undo, return error
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
  on error undo, return error
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

  define buffer buf_temp-aht-stk-tot  for temp-aht-stk-tot .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  define buffer buf_temp-create-aht-stk-tot  for temp-create-aht-stk-tot .
  define buffer buf_temp-create-aht-stk-line for temp-create-aht-stk-line .

  do
  on error undo, return error return-value
  :

    output stream sout to value ("rst-aht.txt") append .

    export stream sout 'export':u string(today, '99/99/9999':u) string(time, 'hh:mm:ss':u) .

    for each buf_temp-aht-stk-tot
    on error undo, return error return-value
    :
      export stream sout 'temp-aht-stk-tot':u .
      export stream sout buf_temp-aht-stk-tot .
    end.

    for each buf_temp-aht-stk-line
    on error undo, return error return-value
    :
      export stream sout 'temp-aht-stk-line':u .
      export stream sout buf_temp-aht-stk-line .
    end.

    for each buf_temp-create-aht-stk-tot
    on error undo, return error return-value
    :
      export stream sout 'temp-create-aht-stk-tot':u .
      export stream sout buf_temp-create-aht-stk-tot .
    end.

    for each buf_temp-create-aht-stk-line
    on error undo, return error return-value
    :
      export stream sout 'temp-create-aht-stk-line':u .
      export stream sout buf_temp-create-aht-stk-line .
    end.

    output stream sout close .
  end.

end procedure. /* store-temp */

procedure ahrstutl-init :

  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-fact-date          as date      no-undo .
  define input  parameter p-sign               as integer   no-undo .

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

    if p-sign = -1 /* p-save-new = true */
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
        (input p-obj-type                    /* p-obj-type               */
        ,input p-obj-code                    /* p-obj-code               */
        ,input entry(v-ind, v-sum-type-list) /* p-sum-type               */
        ,input v-day-end-fact-order          /* p-aht-stk-tot-fact-order */
        ,input v-create-fact-order           /* p-create-tot-fact-order  */
        ,input p-sign                        /* p-sign                   */
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
        (input  v-gds-goods
        ,output v-sum-type-list
        ) .
      do v-ind = 1 to num-entries(v-sum-type-list)
      :
        run ahrstutl-init-line in this-procedure
          (input p-obj-type                    /* p-obj-type                */
          ,input p-obj-code                    /* p-obj-code                */
          ,input buf_doclslib-goods.gds-code   /* p-gds-code                */
          ,input entry(v-ind, v-sum-type-list) /* p-sum-type                */
          ,input v-day-end-fact-order          /* p-aht-stk-line-fact-order */
          ,input v-create-fact-order           /* p-create-line-fact-order  */
          ,input p-sign                        /* p-sign                    */
          ) .
      end.
    end.
  end.
end procedure. /* ahrstutl-init */


procedure ahrstutl-init-tot :

  define input  parameter p-obj-type               as character no-undo .
  define input  parameter p-obj-code               as integer   no-undo .
  define input  parameter p-sum-type               as character no-undo .
  define input  parameter p-aht-stk-tot-fact-order as decimal   no-undo .
  define input  parameter p-create-tot-fact-order  as decimal   no-undo .
  define input  parameter p-sign                   as integer   no-undo .

  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  define buffer buf_temp-aht-stk-tot for temp-aht-stk-tot .
  define buffer buf_temp-create-aht-stk-tot for temp-create-aht-stk-tot .

  define variable v-prev-stk-tot-fact-order        like ub.stk-tot.fact-order no-undo .

  define variable v-create-stk as logical   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-create-stk = false
    .

    find last buf_aht-stk-tot no-lock
      where buf_aht-stk-tot.obj-type   = p-obj-type
        and buf_aht-stk-tot.obj-code   = p-obj-code
        and buf_aht-stk-tot.sum-type   = p-sum-type
        and buf_aht-stk-tot.fact-order <= p-aht-stk-tot-fact-order
      use-index category
      no-error .
    if available buf_aht-stk-tot
    then do:
      assign
        v-prev-stk-tot-fact-order = buf_aht-stk-tot.fact-order
      .

      if v-prev-stk-tot-fact-order <> p-aht-stk-tot-fact-order
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

      find first buf_temp-aht-stk-tot
        where buf_temp-aht-stk-tot.obj-type   = buf_aht-stk-tot.obj-type
          and buf_temp-aht-stk-tot.obj-code   = buf_aht-stk-tot.obj-code
          and buf_temp-aht-stk-tot.fact-order = p-create-tot-fact-order
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
                                       + p-sign * buf_aht-stk-tot.fact-qnty
        &scop FT1    buf_temp-aht-stk-tot.cost-
        &scop FTs1
        &scop FT2    = buf_temp-aht-stk-tot.cost-
        &scop FTs2
        &scop FT3    + p-sign * buf_aht-stk-tot.cost-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
        &scop FT1    buf_temp-aht-stk-tot.crsa-
        &scop FTs1
        &scop FT2    = buf_temp-aht-stk-tot.crsa-
        &scop FTs2
        &scop FT3    + p-sign * buf_aht-stk-tot.crsa-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
        &scop FT1    buf_temp-aht-stk-tot.sale-
        &scop FTs1
        &scop FT2    = buf_temp-aht-stk-tot.sale-
        &scop FTs2
        &scop FT3    + p-sign * buf_aht-stk-tot.sale-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
      .
    end.
    else do:
      assign
        v-create-stk = true
      .

      find first buf_temp-aht-stk-tot
        where buf_temp-aht-stk-tot.obj-type   = p-obj-type
          and buf_temp-aht-stk-tot.obj-code   = p-obj-code
          and buf_temp-aht-stk-tot.fact-order = p-create-tot-fact-order
          and buf_temp-aht-stk-tot.sum-type   = p-sum-type
        no-error .
      if not available buf_temp-aht-stk-tot
      then do:
        create buf_temp-aht-stk-tot .
        assign
          buf_temp-aht-stk-tot.obj-type   = p-obj-type
          buf_temp-aht-stk-tot.obj-code   = p-obj-code
          buf_temp-aht-stk-tot.fact-order = p-create-tot-fact-order
          buf_temp-aht-stk-tot.sum-type   = p-sum-type
        .
      end.
    end.

    if p-sign = 1
    then do:
      create buf_temp-create-aht-stk-tot .
      assign
        buf_temp-create-aht-stk-tot.obj-type    = p-obj-type
        buf_temp-create-aht-stk-tot.obj-code    = p-obj-code
        buf_temp-create-aht-stk-tot.sum-type    = p-sum-type
        buf_temp-create-aht-stk-tot.need-create = v-create-stk
      .

      /* uncomment next line to debug */
/*      output to rst-aht.log append .*/
/*      export "temp-create-aht-stk-tot" .*/
/*      export buf_temp-create-aht-stk-tot .*/
/*      output close .*/
    end.
  end.

end procedure. /* ahrstutl-init-tot */


procedure ahrstutl-init-line :

  define input  parameter p-obj-type                as character no-undo .
  define input  parameter p-obj-code                as integer   no-undo .
  define input  parameter p-gds-code                as integer   no-undo .
  define input  parameter p-sum-type                as character no-undo .
  define input  parameter p-aht-stk-line-fact-order as decimal   no-undo .
  define input  parameter p-create-line-fact-order  as decimal   no-undo .
  define input  parameter p-sign                    as integer   no-undo .

  define buffer buf_aht-stk-line for ub.aht-stk-line .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  define buffer buf_temp-create-aht-stk-line for temp-create-aht-stk-line .

  define variable v-prev-stk-line-fact-order       like ub.stk-line.fact-order no-undo .
  define variable v-prev-shift-stk-line-fact-order like ub.stk-line.fact-order no-undo .

  define variable v-create-stk as logical   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-create-stk = false
    .

    find last buf_aht-stk-line no-lock
      where buf_aht-stk-line.obj-type   = p-obj-type
        and buf_aht-stk-line.obj-code   = p-obj-code
        and buf_aht-stk-line.gds-code   = p-gds-code
        and buf_aht-stk-line.sum-type   = p-sum-type
        and buf_aht-stk-line.fact-order <= p-aht-stk-line-fact-order
      use-index category
      no-error .
    if available buf_aht-stk-line
    then do:
      assign
        v-prev-stk-line-fact-order = buf_aht-stk-line.fact-order
      .

      if v-prev-stk-line-fact-order <> p-aht-stk-line-fact-order
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

      find first buf_temp-aht-stk-line
        where buf_temp-aht-stk-line.obj-type   = buf_aht-stk-line.obj-type
          and buf_temp-aht-stk-line.obj-code   = buf_aht-stk-line.obj-code
          and buf_temp-aht-stk-line.gds-code   = buf_aht-stk-line.gds-code
          and buf_temp-aht-stk-line.fact-order = p-create-line-fact-order
          and buf_temp-aht-stk-line.sum-type   = buf_aht-stk-line.sum-type
        no-error .
      if not available buf_temp-aht-stk-line
      then do:
        create buf_temp-aht-stk-line .
        assign
          buf_temp-aht-stk-line.obj-type   = buf_aht-stk-line.obj-type
          buf_temp-aht-stk-line.obj-code   = buf_aht-stk-line.obj-code
          buf_temp-aht-stk-line.gds-code   = buf_aht-stk-line.gds-code
          buf_temp-aht-stk-line.fact-order = p-create-line-fact-order
          buf_temp-aht-stk-line.sum-type   = buf_aht-stk-line.sum-type
        .
      end.

      assign
        buf_temp-aht-stk-line.fact-qnty = buf_temp-aht-stk-line.fact-qnty
                                        + p-sign * buf_aht-stk-line.fact-qnty
        &scop FT1    buf_temp-aht-stk-line.cost-
        &scop FTs1
        &scop FT2    = buf_temp-aht-stk-line.cost-
        &scop FTs2
        &scop FT3    + p-sign * buf_aht-stk-line.cost-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
        &scop FT1    buf_temp-aht-stk-line.crsa-
        &scop FTs1
        &scop FT2    = buf_temp-aht-stk-line.crsa-
        &scop FTs2
        &scop FT3    + p-sign * buf_aht-stk-line.crsa-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
        &scop FT1    buf_temp-aht-stk-line.sale-
        &scop FTs1
        &scop FT2    = buf_temp-aht-stk-line.sale-
        &scop FTs2
        &scop FT3    + p-sign * buf_aht-stk-line.sale-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
      .
    end.
    else do:
      assign
        v-create-stk = true
      .

      find first buf_temp-aht-stk-line
        where buf_temp-aht-stk-line.obj-type   = p-obj-type
          and buf_temp-aht-stk-line.obj-code   = p-obj-code
          and buf_temp-aht-stk-line.gds-code   = p-gds-code
          and buf_temp-aht-stk-line.fact-order = p-create-line-fact-order
          and buf_temp-aht-stk-line.sum-type   = p-sum-type
        no-error .
      if not available buf_temp-aht-stk-line
      then do:
        create buf_temp-aht-stk-line .
        assign
          buf_temp-aht-stk-line.obj-type   = p-obj-type
          buf_temp-aht-stk-line.obj-code   = p-obj-code
          buf_temp-aht-stk-line.gds-code   = p-gds-code
          buf_temp-aht-stk-line.sum-type   = p-sum-type
          buf_temp-aht-stk-line.fact-order = p-create-line-fact-order
        .
      end.
    end.

    if p-sign = 1
    then do:
      create buf_temp-create-aht-stk-line .
      assign
        buf_temp-create-aht-stk-line.obj-type    = p-obj-type
        buf_temp-create-aht-stk-line.obj-code    = p-obj-code
        buf_temp-create-aht-stk-line.gds-code    = p-gds-code
        buf_temp-create-aht-stk-line.sum-type    = p-sum-type
        buf_temp-create-aht-stk-line.need-create = v-create-stk
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

  define buffer buf_temp-create-aht-stk-tot  for temp-create-aht-stk-tot .
  define buffer buf_temp-create-aht-stk-line for temp-create-aht-stk-line .
  define buffer buf_temp-aht-stk-tot for temp-aht-stk-tot .
  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  define buffer buf_aht-stk-line for ub.aht-stk-line .

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

    for each buf_temp-create-aht-stk-tot
      where buf_temp-create-aht-stk-tot.need-create = true
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

      for each buf_temp-aht-stk-tot
        where buf_temp-aht-stk-tot.obj-type   = buf_temp-create-aht-stk-tot.obj-type
          and buf_temp-aht-stk-tot.obj-code   = buf_temp-create-aht-stk-tot.obj-code
          and buf_temp-aht-stk-tot.fact-order = v-day-end-fact-order
          and buf_temp-aht-stk-tot.sum-type   = buf_temp-create-aht-stk-tot.sum-type
      on error undo, return error return-value
      :
        create buf_aht-stk-tot .
        buffer-copy buf_temp-aht-stk-tot to buf_aht-stk-tot
        .
      end.
    end.

    assign
      v-total-count = 0
    .

    for each buf_temp-create-aht-stk-line
      where buf_temp-create-aht-stk-line.need-create = true
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Код товара " + string(buf_temp-create-aht-stk-line.gds-code)
          ).
      end.

      for each buf_temp-aht-stk-line
        where buf_temp-aht-stk-line.obj-type   = buf_temp-create-aht-stk-line.obj-type
          and buf_temp-aht-stk-line.obj-code   = buf_temp-create-aht-stk-line.obj-code
          and buf_temp-aht-stk-line.gds-code   = buf_temp-create-aht-stk-line.gds-code
          and buf_temp-aht-stk-line.fact-order = v-day-end-fact-order
          and buf_temp-aht-stk-line.sum-type   = buf_temp-create-aht-stk-line.sum-type
      on error undo, return error return-value
      :
        create buf_aht-stk-line .
        buffer-copy buf_temp-aht-stk-line to buf_aht-stk-line
        .
      end.
    end.
  end.

end procedure. /* ahrstutl-create-stk */


procedure ahrstutl-clear-aht :

  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-start-fact-order as decimal   no-undo .
  define input  parameter p-fact-date        as date      no-undo .

  define buffer buf_aht-doc      for ub.aht-doc .
  define buffer buf_aht-stk      for ub.aht-stk .
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
      (input "Удаление информации о наличии документов"
      ).

    for each buf_aht-doc
      where buf_aht-doc.obj-type   = p-obj-type
        and buf_aht-doc.obj-code   = p-obj-code
        and buf_aht-doc.fact-order > p-start-fact-order
        and buf_aht-doc.fact-order <= v-day-end-fact-order
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_aht-doc.doc-code)
          ).
      end.

      delete buf_aht-doc .
    end.

    run show-action in this-procedure
      (input "Удаление информации о наличии остатков по объекту"
      ).

    for each buf_aht-stk
      where buf_aht-stk.obj-type   = p-obj-type
        and buf_aht-stk.obj-code   = p-obj-code
        and buf_aht-stk.fact-order > p-start-fact-order
        and buf_aht-stk.fact-order <= v-day-end-fact-order
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Дата " + string(buf_aht-stk.fact-date)
          ).
      end.

      delete buf_aht-stk .
    end.


    run show-action in this-procedure
      (input "Удаление оборота по документам"
      ).
    assign
      v-ind = 0
    .

    for each buf_aht-ot-tot
      where buf_aht-ot-tot.obj-type   = p-obj-type
        and buf_aht-ot-tot.obj-code   = p-obj-code
        and buf_aht-ot-tot.fact-order > p-start-fact-order
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
        and buf_aht-ot-line.fact-order > p-start-fact-order
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
        and buf_aht-stk-tot.fact-order > p-start-fact-order
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
        and buf_aht-stk-line.fact-order > p-start-fact-order
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


procedure ahrstutl-delete-copy :

  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .

  define buffer buf_aht-stk-tot  for ub.aht-stk-tot .
  define buffer buf_aht-stk-line for ub.aht-stk-line .
  define buffer buf_temp-create-aht-stk-tot for temp-create-aht-stk-tot .
  define buffer buf_temp-create-aht-stk-line for temp-create-aht-stk-line .

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

    for each buf_temp-create-aht-stk-tot
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

      find last buf_aht-stk-tot exclusive-lock
        where buf_aht-stk-tot.obj-type   = buf_temp-create-aht-stk-tot.obj-type
          and buf_aht-stk-tot.obj-code   = buf_temp-create-aht-stk-tot.obj-code
          and buf_aht-stk-tot.fact-order = v-day-end-fact-order - {&arh-delta}
          and buf_aht-stk-tot.sum-type   = buf_temp-create-aht-stk-tot.sum-type
        no-error .
      if available buf_aht-stk-tot
      then do:
        /* todo - сравнить с информацией в buf_temp-aht-stk-tot */
        delete buf_aht-stk-tot .
      end.
      else do:
        for each buf_aht-stk-tot exclusive-lock
          where buf_aht-stk-tot.obj-type   = buf_temp-create-aht-stk-tot.obj-type
            and buf_aht-stk-tot.obj-code   = buf_temp-create-aht-stk-tot.obj-code
            and buf_aht-stk-tot.fact-order = v-day-end-fact-order
            and buf_aht-stk-tot.sum-type   = buf_temp-create-aht-stk-tot.sum-type
        on error undo, return error return-value
        :
          /* todo - провести поиск предыдущего aht-stk-tot и проверить отсутствие оборотов */
          delete buf_aht-stk-tot .
        end.
      end.
    end.

    assign
      v-total-count = 0
    .

    for each buf_temp-create-aht-stk-line
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Код товара " + string(buf_temp-create-aht-stk-line.gds-code)
          ).
      end.

      find first buf_aht-stk-line exclusive-lock
        where buf_aht-stk-line.obj-type   = buf_temp-create-aht-stk-line.obj-type
          and buf_aht-stk-line.obj-code   = buf_temp-create-aht-stk-line.obj-code
          and buf_aht-stk-line.gds-code   = buf_temp-create-aht-stk-line.gds-code
          and buf_aht-stk-line.fact-order = v-day-end-fact-order - {&arh-delta}
          and buf_aht-stk-line.sum-type   = buf_temp-create-aht-stk-line.sum-type
        no-error .
      if available buf_aht-stk-line
      then do:
        delete buf_aht-stk-line .
      end.
      else do:
        for each buf_aht-stk-line exclusive-lock
          where buf_aht-stk-line.obj-type   = buf_temp-create-aht-stk-line.obj-type
            and buf_aht-stk-line.obj-code   = buf_temp-create-aht-stk-line.obj-code
            and buf_aht-stk-line.gds-code   = buf_temp-create-aht-stk-line.gds-code
            and buf_aht-stk-line.fact-order = v-day-end-fact-order
            and buf_aht-stk-line.sum-type   = buf_temp-create-aht-stk-line.sum-type
        on error undo, return error return-value
        :
          /* todo - провести поиск предыдущего aht-stk-line и проверить отсутствие оборотов */
          delete buf_aht-stk-line .
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
        for each buf_aht-stk-line exclusive-lock
          where buf_aht-stk-line.obj-type   = buf_gds-obj.obj-type
            and buf_aht-stk-line.obj-code   = buf_gds-obj.obj-code
            and buf_aht-stk-line.gds-code   = buf_gds-obj.gds-code
            and buf_aht-stk-line.fact-order = v-day-end-fact-order
        on error undo, return error return-value
        :
          delete buf_aht-stk-line .
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

    define buffer buf_aht-stk-tot for ub.aht-stk-tot .

    run ahrstutl-tot-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .

    do v-ind = 1 to num-entries(v-sum-type-list)
    :
      run ahrstutl-store-tot in this-procedure
        (input p-obj-type                    /* p-obj-type                 */
        ,input p-obj-code                    /* p-obj-code                 */
        ,input entry(v-ind, v-sum-type-list) /* p-sum-type                 */
        ,input v-first-day-end-fact-order    /* p-first-day-end-fact-order */
        ,input v-last-day-end-fact-order     /* p-last-day-end-fact-order  */
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
        undo, return error return-value .
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
          (input p-obj-type                    /* p-obj-type                 */
          ,input p-obj-code                    /* p-obj-code                 */
          ,input buf_doclslib-goods.gds-code   /* p-gds-code                 */
          ,input entry(v-ind, v-sum-type-list) /* p-sum-type                 */
          ,input v-first-day-end-fact-order    /* p-first-day-end-fact-order */
          ,input v-last-day-end-fact-order     /* p-last-day-end-fact-order  */
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры" 'ahrstutl-store-line':u skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" buf_doclslib-goods.artic buf_doclslib-goods.prod-type buf_doclslib-goods.prod-code skip
            "Код товара" buf_doclslib-goods.gds-code skip
            return-value skip
            error-status :get-message(1) skip
            view-as alert-box error .
          undo, return error return-value .
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


procedure ahrstutl-store-tot :

  define input  parameter p-obj-type                   as character no-undo .
  define input  parameter p-obj-code                   as integer   no-undo .
  define input  parameter p-sum-type                   as character no-undo .
  define input  parameter p-first-day-end-fact-order   as decimal   no-undo .
  define input  parameter p-last-day-end-fact-order    as decimal   no-undo .

  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  define buffer buf_temp-aht-stk-tot for temp-aht-stk-tot .

  do
  on error undo, return error return-value
  :
    for each buf_temp-aht-stk-tot
      where buf_temp-aht-stk-tot.obj-type = p-obj-type
        and buf_temp-aht-stk-tot.obj-code = p-obj-code
        and buf_temp-aht-stk-tot.sum-type = p-sum-type
    on error undo, return error return-value
    :
      if buf_temp-aht-stk-tot.fact-qnty <> 0
      or
      &scop fl1  buf_temp-aht-stk-tot.cost-
      &scop fls1
      &scop fl2  <> 0
      &scop fl3  or
      {&price-single-list}
      or
      &scop fl1  buf_temp-aht-stk-tot.crsa-
      &scop fls1
      &scop fl2  <> 0
      &scop fl3  or
      {&price-single-list}
      or
      &scop fl1  buf_temp-aht-stk-tot.sale-
      &scop fls1
      &scop fl2  <> 0
      &scop fl3  or
      {&price-single-list}
      then do:
        /* ищем первоначальную корневую запись */
        /* если ее нет, то создаем ее */
        find first buf_aht-stk-tot exclusive-lock
          where buf_aht-stk-tot.obj-type   = buf_temp-aht-stk-tot.obj-type
            and buf_aht-stk-tot.obj-code   = buf_temp-aht-stk-tot.obj-code
            and buf_aht-stk-tot.sum-type   = buf_temp-aht-stk-tot.sum-type
            and buf_aht-stk-tot.fact-order <= p-first-day-end-fact-order
          no-error .
        if not available buf_aht-stk-tot
        then do:
          create buf_aht-stk-tot .
          assign
            buf_aht-stk-tot.obj-type   = buf_temp-aht-stk-tot.obj-type
            buf_aht-stk-tot.obj-code   = buf_temp-aht-stk-tot.obj-code
            buf_aht-stk-tot.fact-order = p-first-day-end-fact-order
            buf_aht-stk-tot.sum-type   = buf_temp-aht-stk-tot.sum-type
          .
        end.

        for each buf_aht-stk-tot exclusive-lock
          where buf_aht-stk-tot.obj-type   = buf_temp-aht-stk-tot.obj-type
            and buf_aht-stk-tot.obj-code   = buf_temp-aht-stk-tot.obj-code
            and buf_aht-stk-tot.sum-type   = buf_temp-aht-stk-tot.sum-type
            and buf_aht-stk-tot.fact-order <= p-last-day-end-fact-order - {&arh-delta}
        on error undo, return error return-value
        :
          assign
            buf_aht-stk-tot.fact-qnty = buf_aht-stk-tot.fact-qnty
                                      + buf_temp-aht-stk-tot.fact-qnty
            &scop FT1    buf_aht-stk-tot.cost-
            &scop FTs1
            &scop FT2    = buf_aht-stk-tot.cost-
            &scop FTs2
            &scop FT3    + buf_temp-aht-stk-tot.cost-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
            &scop FT1    buf_aht-stk-tot.crsa-
            &scop FTs1
            &scop FT2    = buf_aht-stk-tot.crsa-
            &scop FTs2
            &scop FT3    + buf_temp-aht-stk-tot.crsa-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
            &scop FT1    buf_aht-stk-tot.sale-
            &scop FTs1
            &scop FT2    = buf_aht-stk-tot.sale-
            &scop FTs2
            &scop FT3    + buf_temp-aht-stk-tot.sale-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
          .
        end.
      end.
    end. /*each tt-aht-stk-tot*/
  end.

end procedure. /* ahrstutl-store-tot */


procedure ahrstutl-store-line :

  define input  parameter p-obj-type                 as character no-undo .
  define input  parameter p-obj-code                 as integer   no-undo .
  define input  parameter p-gds-code                 as integer   no-undo .
  define input  parameter p-sum-type                 as character no-undo .
  define input  parameter p-first-day-end-fact-order as decimal   no-undo .
  define input  parameter p-last-day-end-fact-order  as decimal   no-undo .


  define buffer buf_aht-stk-line for ub.aht-stk-line .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .

  do
  on error undo, return error return-value
  :
    for each buf_temp-aht-stk-line
      where buf_temp-aht-stk-line.obj-type  = p-obj-type
        and buf_temp-aht-stk-line.obj-code  = p-obj-code
        and buf_temp-aht-stk-line.gds-code  = p-gds-code
        and buf_temp-aht-stk-line.sum-type  = p-sum-type
    on error undo, return error return-value
    :
      if buf_temp-aht-stk-line.fact-qnty <> 0
      or
      &scop fl1  buf_temp-aht-stk-line.cost-
      &scop fls1
      &scop fl2  <> 0
      &scop fl3  or
      {&price-single-list}
      or
      &scop fl1  buf_temp-aht-stk-line.crsa-
      &scop fls1
      &scop fl2  <> 0
      &scop fl3  or
      {&price-single-list}
      or
      &scop fl1  buf_temp-aht-stk-line.sale-
      &scop fls1
      &scop fl2  <> 0
      &scop fl3  or
      {&price-single-list}
      then do:
        /* ищем первоначальную корневую запись */
        /* если ее нет, то создаем ее */
        find first buf_aht-stk-line exclusive-lock
          where buf_aht-stk-line.obj-type   = buf_temp-aht-stk-line.obj-type
            and buf_aht-stk-line.obj-code   = buf_temp-aht-stk-line.obj-code
            and buf_aht-stk-line.gds-code   = buf_temp-aht-stk-line.gds-code
            and buf_aht-stk-line.sum-type   = buf_temp-aht-stk-line.sum-type
            and buf_aht-stk-line.fact-order <= p-first-day-end-fact-order
          no-error .
        if not available buf_aht-stk-line
        then do:
          create buf_aht-stk-line .
          assign
            buf_aht-stk-line.obj-type   = buf_temp-aht-stk-line.obj-type
            buf_aht-stk-line.obj-code   = buf_temp-aht-stk-line.obj-code
            buf_aht-stk-line.gds-code   = buf_temp-aht-stk-line.gds-code
            buf_aht-stk-line.fact-order = p-first-day-end-fact-order
            buf_aht-stk-line.sum-type   = buf_temp-aht-stk-line.sum-type
          .
        end.

        for each buf_aht-stk-line exclusive-lock
          where buf_aht-stk-line.obj-type   = buf_temp-aht-stk-line.obj-type
            and buf_aht-stk-line.obj-code   = buf_temp-aht-stk-line.obj-code
            and buf_aht-stk-line.gds-code   = buf_temp-aht-stk-line.gds-code
            and buf_aht-stk-line.sum-type   = buf_temp-aht-stk-line.sum-type
            and buf_aht-stk-line.fact-order <= p-last-day-end-fact-order - {&arh-delta}
        on error undo, return error return-value
        :
          assign
            buf_aht-stk-line.fact-qnty = buf_aht-stk-line.fact-qnty
                                      + buf_temp-aht-stk-line.fact-qnty
            &scop FT1    buf_aht-stk-line.cost-
            &scop FTs1
            &scop FT2    = buf_aht-stk-line.cost-
            &scop FTs2
            &scop FT3    + buf_temp-aht-stk-line.cost-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
            &scop FT1    buf_aht-stk-line.crsa-
            &scop FTs1
            &scop FT2    = buf_aht-stk-line.crsa-
            &scop FTs2
            &scop FT3    + buf_temp-aht-stk-line.crsa-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
            &scop FT1    buf_aht-stk-line.sale-
            &scop FTs1
            &scop FT2    = buf_aht-stk-line.sale-
            &scop FTs2
            &scop FT3    + buf_temp-aht-stk-line.sale-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
          .
        end.
      end.
    end. /*each tt-aht-stk-line*/
  end.

end procedure. /* ahrstutl-store-line */


procedure cb_rst-aht_overturn-exist :

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

end procedure. /* cb_rst-aht_overturn-exist */

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
        "Складской архив по типам приобретения" skip
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
        "Складской архив по типам приобретения" skip
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