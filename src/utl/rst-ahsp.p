block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rst-ahsp.p $
$Archive: utl/rst-ahsp.p $

Восстановление складского архива по поставщикам

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
define variable vss-workfile    as character no-undo init "$Workfile: rst-ahsp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/rst-ahsp.p $":U .
define variable vss-description as character no-undo init "Восстановление складского архива по поставщикам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ trg/factord.i  }
{ gbl/clntattr.i }
{ trg/doclslib.i }
{ gbl/ah-csp.i   }
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

{&def-temp-stk-supp-tot}
{&def-temp-stk-supp-line}
{&def-temp-shift-stk-supp-tot}
{&def-temp-shift-stk-supp-line}

define temp-table temp-import-ot-supp-tot no-undo like ub.ot-supp-tot
  .
define temp-table temp-import-ot-supp-line no-undo like ub.ot-supp-line
  field gds-code as integer
  .
define temp-table temp-import-stk-supp-tot no-undo like ub.stk-supp-tot
  .
define temp-table temp-import-stk-supp-line no-undo like ub.stk-supp-line
  field gds-code as integer
  .

define temp-table temp-create-stk-supp-tot no-undo
   field obj-type as character
   field obj-code as integer
   field cli-type as character
   field cli-code as integer
   field sum-type as character
   field need-create as logical
   index xpk is primary unique obj-type obj-code cli-type cli-code sum-type
   index xie1 need-create
.
define temp-table temp-create-stk-supp-line no-undo
   field obj-type  as character
   field obj-code  as integer
   field cli-type  as character
   field cli-code  as integer
   field artic     as character
   field prod-type as character
   field prod-code as integer
   field sum-type  as character
   field need-create as logical
   index xpk is primary unique obj-type obj-code cli-type cli-code artic prod-type prod-code sum-type
   index xie1 need-create
   index xie2 obj-type obj-code artic prod-type prod-code sum-type
.
define temp-table doclslib-clients no-undo
  field cli-type  as character
  field cli-code  as integer
  index xpk is primary unique cli-type cli-code
  .
define temp-table doclslib-clients-goods no-undo
  field cli-type  as character
  field cli-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer

  index xpk is primary unique cli-type cli-code artic prod-type prod-code
  index xie1 artic prod-type prod-code
  .

define stream slog .
define stream sinp .
define stream sout .

define buffer calc-supp-arh-lock_batchprocess for ub.batchprocess .

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

  define buffer restore-ahsp-lock_batchprocess for ub.batchprocess .
  /* блокировка процедуры восстановления складского архива по поставщикам*/
  run gbl/lock-prc.p
    (input {&lock-prc-restore-ahsp}
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Восстановление складского архива по поставщикам"
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
        "Невозможно произвести восстановлением складского архива по поставщикам" skip
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
        "Невозможно произвести расчёт складского архива по поставщикам" skip
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

  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .

  define variable v-ahsp-calc          as logical   no-undo .
  define variable v-ahsp-del           as logical   no-undo .
  define variable v-ahsp-start-date    as date      no-undo .
  define variable v-ahsp-detail-date   as date      no-undo .
  define variable v-ahsp-recalc-date   as date      no-undo .

  run clntattr-value in this-procedure
    (input  v-obj-type              /* p-obj-type */
    ,input  v-obj-code              /* p-obj-code */
    ,input  {&attr-ahsp-calc}        /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-ahsp-calc = (lookup(v-attr-value, 'yes,true') > 0)
  .

  run clntattr-value in this-procedure
    (input  v-obj-type              /* p-obj-type */
    ,input  v-obj-code              /* p-obj-code */
    ,input  {&attr-ahsp-del}         /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-ahsp-del = (lookup(v-attr-value, 'yes,true') > 0)
  .

  run clntattr-value in this-procedure
    (input  v-obj-type              /* p-obj-type */
    ,input  v-obj-code              /* p-obj-code */
    ,input  {&attr-ahsp-start-date}  /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-ahsp-start-date = date(v-attr-value)
  .

  run clntattr-value in this-procedure
    (input  v-obj-type              /* p-obj-type */
    ,input  v-obj-code              /* p-obj-code */
    ,input  {&attr-ahsp-detail-date} /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-ahsp-detail-date = date(v-attr-value)
  .

  run clntattr-value in this-procedure
    (input  v-obj-type              /* p-obj-type */
    ,input  v-obj-code              /* p-obj-code */
    ,input  {&attr-ahsp-recalc-date} /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .
  assign
    v-ahsp-recalc-date = date(v-attr-value)
  .

  if (v-ahsp-start-date <> ?
     and v-ahsp-detail-date = ?)
  or (v-ahsp-start-date = ?
     and v-ahsp-detail-date <> ?)
  then do:
    message
      "Складской архив по поставщикам" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести восстановление складского архива по поставщикам" skip
      "Противоречивая информация в датах инициализации складского архива по поставщикам" skip
      "Дата начала складского архива по поставщикам" string(v-ahsp-start-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по поставщикам" string(v-ahsp-detail-date, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if v-ahsp-detail-date = ?
  then do:
    message
      "Складской архив по поставщикам" skip
      "Объект" v-obj-type v-obj-code skip
      "На объекте рассчитан складской архив по поставщикам за все даты" skip
      "Операция восстановления не может быть произведена" skip
      view-as alert-box information .
    return .
  end.

  /* автоматически создаем имя файла для считывания складского архива по поставщикам */
  define variable v-year  as integer   no-undo .
  define variable v-month as integer   no-undo .
  define variable v-day   as integer   no-undo .

  assign
    v-year  = year(v-ahsp-detail-date)
    v-month = month(v-ahsp-detail-date)
    v-day   = day(v-ahsp-detail-date)
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

  assign
    v-backup-file-name = entry(1, v-file-name, '.') + '.rst':u
  .

  define variable v-full-file-name as character no-undo .
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
           + "Произвести восстановление подробного складского архива по поставщикам" + {&new-line}
           + "Дата начала подробного складского архива по поставщикам " + string(v-ahsp-detail-date, '99/99/9999':U) + {&new-line}
           + "Сегодня " + string(v-today, '99/99/9999':U) + {&new-line}
    ,input '|^':u /* Символы разделители для кодирования двух следующих параметров */
                  /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                  /* второй символ - разделитель атрибутов в описании кнопок */
    ,input "Из файла" + '^confirm':u + (if v-restore-from-file = true then '':u else '^disable':u)
    + '|':u + "Резервная копия" + '^confirm':u + (if v-restore-backup = true then '':u else '^disable':u)
    + '|':u + "Документы" + '^confirm':u + (if v-ahsp-del = true then '^disable':u else '':u)
    + '|':u + "Отказ" /* список названий кнопок  */
                      /* каждая кнопка может иметь необязательный */
                      /* список атрибутов, влияющих на поведение кнопки */
    ,input (if v-restore-from-file then substitute("Восстановить из файла &1", v-full-file-name)
            else substitute("Файл с сохраненным архивом &1 не найден", v-file-name ) )
        + "|":u +
           (if v-restore-from-file then substitute("Восстановить из резервной копии &1", v-backup-file-name)
            else substitute("Файл резервной копии &1 не найден", v-backup-file-name) )
        + "|":u + (if v-ahsp-del
                   then "Была ошибка при предыдущем Удалении/Восстановлении" + {&new-line}
                        + "Складской архив по поставщикам можно восстановить только из файла"
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
        ,input  {&btpr-type-ahsp}
        ,input  v-file-name
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Складской архив по поставщикам" skip
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
        ,input  v-ahsp-detail-date     /* p-cut-date            */
        ,input  v-file-name           /* p-file-name           */
        ,output v-restore-start-date  /* p-restore-start-date  */
        ,output v-restore-detail-date /* p-restore-detail-date */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Складской архив по поставщикам" skip
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
        ,input  {&btpr-type-ahsp}
        ,input  v-file-name
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Складской архив по поставщикам" skip
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
        ,input  v-ahsp-detail-date    /* p-cut-date            */
        ,input  v-file-name           /* p-file-name           */
        ,output v-restore-start-date  /* p-restore-start-date  */
        ,output v-restore-detail-date /* p-restore-detail-date */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Складской архив по поставщикам" skip
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
    when 3
    then do:
      /* восстановление на основании документов */
      if v-ahsp-del = true
      then do:
        message
          "Складской архив по поставщикам" skip
          "Объект" v-obj-type v-obj-code skip
          "Невозможно произвести восстановление на основании документов" skip
          "Остатки по архивам не рассчитаны" skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if  v-ahsp-recalc-date <> ?
      and v-ahsp-recalc-date <= v-ahsp-detail-date
      then do:
        message
          "Складской архив по поставщикам" skip
          "Объект" v-obj-type v-obj-code skip
          "Невозможно произвести восстановление на основании документов" skip
          "Дата перерасчета меньше даты начала подробного складского архива по поставщикам" skip
          "Дата перерасчета" string(v-ahsp-recalc-date, '99/99/9999':u) skip
          "Дата начала подробного складского архива по поставщикам" string(v-ahsp-detail-date, '99/99/9999':u) skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      assign
        v-restore-from-file = false
        v-restore-backup    = false
      .

      /* отступаем на месяц от текущей даты начала подробного складского архива по поставщикам*/
      assign
        v-month = month(v-ahsp-detail-date)
        v-year  = year(v-ahsp-start-date)
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
        /* отказ от расчета складского архива */
        message
          "Складской архив по поставщикам" skip
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
          "Складской архив по поставщикам" skip
          "Объект" v-obj-type v-obj-code skip
          "Ошибка при выборе даты" skip
          "Месяц" v-month skip
          "Год" v-year skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if v-restore-detail-date >= v-ahsp-detail-date
      then do:
        message
          "Складской архив по поставщикам" skip
          "Объект" v-obj-type v-obj-code skip
          "Неправильная дата расчета складского архива по поставщикам" skip
          "Дата расчета архива не может быть больше, чем дата на которую" skip
          "имеется рассчитанный складской архив по поставщикам" skip
          "Дата на которую запрошено восстановление подробного складского архива по поставщикам" string(v-restore-detail-date, '99/99/9999':u) skip
          "Дата начала подробного складского архива по поставщикам" string(v-ahsp-detail-date, '99/99/9999':u) skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if v-restore-detail-date >= v-ahsp-start-date
      then do:
        /* производится перерасчет без удаления первоначального остатка */
        assign
          v-clear-start = false
          v-restore-start-date = v-ahsp-start-date
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
      /* отказ от расчета складского архива по поставщикам */
      return .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по поставщикам" skip
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
  define variable v-ahsp-source as character no-undo .
  if v-restore-from-file = true
  then do:
    assign
      v-ahsp-source = "Будет восстановлен складской архив по поставщикам из файла " + v-file-name
    .
  end.
  else do:
    assign
      v-ahsp-source = "Складской архив по поставщикам будет рассчитан на основании первичных документов"
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
      "Складской архив по поставщикам" skip
      "Объект" v-obj-type v-obj-code skip
      "Внутренняя ошибка" skip
      "Противоречивая информация в датах начала складского архива и начала подробного складского архива" skip
      "Дата начала складского архива" string(v-restore-start-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива" string(v-restore-detail-date, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  message
    "Складской архив по поставщикам" skip
    "Объект" v-obj-type v-obj-code skip
    "ВНИМАНИЕ!" skip
    "Последнее предупреждение перед восстановлением складского архива по поставщикам." skip
    "Дата с которой существует складской архив по поставщикам" string(v-ahsp-start-date, '99/99/9999':u) skip
    "Дата с которой имеются подробный складской архив по поставщикам" string(v-ahsp-detail-date, '99/99/9999':u) skip
    "" skip
    "Дата с которой будет начинаться складской архив по поставщикам после восстановления" string(v-restore-start-date, '99/99/9999':u) skip
    "Дата с которой будет начинаться подробный складской архив по поставщикам после восстановления" string(v-restore-detail-date, '99/99/9999':u) skip
    ""
    "" skip
    "Сегодня" string(v-today, '99/99/9999':u) skip
    "" v-ahsp-source skip
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
    title "Расчет складского архива по поставщикам"
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
    (input  v-ahsp-detail-date - 1   /* p-fact-date            */
    ,output v-day-end-fact-order    /* p-day-end-fact-order   */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Складской архив по поставщикам" skip
      "Объект" v-obj-type v-obj-code skip
      "Ошибка при вызове процедуры factord"
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if  v-ahsp-del       = false
  and v-restore-backup = false
  then do:
    /* создаем файл для резервного копирования складского архива */
    run create-log-file in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input v-ahsp-start-date
      ,input v-ahsp-detail-date
      ,input v-ahsp-start-date
      ,input v-ahsp-detail-date
      ,input v-backup-file-name
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по поставщикам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при создании файла архивации" skip
        "Имя файла архивации" v-file-name skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* сохраняем складской архив по поставщикам */
    run trg/ah-clicl.p
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
        "Складской архив по поставщикам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при cохранении складского архива по поставщикам"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* закрываем файл архивации */
    run close-log-file in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input v-ahsp-start-date
      ,input v-ahsp-detail-date
      ,input v-ahsp-start-date
      ,input v-ahsp-detail-date
      ,input v-backup-file-name
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по поставщикам" skip
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
      ,input  {&btpr-type-ahsp}     /* p-archive-type          */
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
      ,input  {&btpr-type-ahsp}     /* p-archive-type          */
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
        "Складской архив по поставщикам" skip
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
    /* помечаем складской архив как удаленый */
    run clntattr-write in this-procedure
      (input v-obj-type       /* p-obj-type */
      ,input v-obj-code       /* p-obj-code */
      ,input {&attr-ahsp-del} /* p-code     */
      ,input 'true':u         /* p-value    */
      ) .

    /* удаляем складской архив по поставщикам */
    run trg/ah-clicl.p
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
        "Складской архив по поставщикам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при удалении складского архива по поставщикам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* импорт складского архива из файла */
    input stream sinp from value(v-file-name) .

    /* проверка правильного формата файла */
    run validate-file-name in this-procedure
      (input  v-obj-type            /* p-obj-type            */
      ,input  v-obj-code            /* p-obj-code            */
      ,input  v-ahsp-detail-date    /* p-cut-date            */
      ,input  v-file-name           /* p-file-name           */
      ,output v-restore-start-date  /* p-restore-start-date  */
      ,output v-restore-detail-date /* p-restore-detail-date */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по поставщикам" skip
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
      ,input  v-ahsp-detail-date           /* p-cut-date     */
      ,input  v-file-name                 /* p-file-name    */
      ,output v-close-restore-start-date  /* p-restore-start-date  */
      ,output v-close-restore-detail-date /* p-restore-detail-date */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по поставщикам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при закрытии файла архивации" skip
        "Имя файла архивации" v-file-name skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if v-close-restore-start-date  <> v-restore-start-date
    or v-close-restore-detail-date <> v-restore-detail-date
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по поставщикам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при закрытии файла архивации" skip
        "Не соответствие дат начала архива и начала подробнго архива в конце и в начала файла" skip
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
      ,input {&attr-ahsp-start-date}                     /* p-code     */
      ,input string(v-restore-start-date, '99/99/9999':u) /* p-value    */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала складского архива по поставщикам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run clntattr-write in this-procedure
      (input v-obj-type                                  /* p-obj-type */
      ,input v-obj-code                                  /* p-obj-code */
      ,input {&attr-ahsp-detail-date}                     /* p-code     */
      ,input string(v-restore-detail-date, '99/99/9999':u) /* p-value    */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала подробного складского архива по поставщикам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    define variable v-delete-ahsp-del as logical   no-undo .

    /* восстановление складского архив прошло успешно */
    /* удаляем признак того, что была ошибка при удалении складского архива */
    run clntattr-delete in this-procedure
      (input  v-obj-type       /* p-obj-type */
      ,input  v-obj-code       /* p-obj-code */
      ,input  {&attr-ahsp-del}  /* p-code     */
      ,output v-delete-ahsp-del /* p-deleted  */
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
      (input v-ahsp-detail-date
      ) .

    /* составление списка товаров */
    run doclslib-init-goods in this-procedure .

    /* составление списка поставщиков и товаров на основании оборота */
    run rst-ahsp-init-clients-goods in this-procedure .

    /* составление списка поставщиков на основании оборота */
    run rst-ahsp-init-clients in this-procedure .

    /* складской архив помечается как восстанавливающийся */
    run clntattr-write in this-procedure
      (input v-obj-type /* p-obj-type */
      ,input v-obj-code /* p-obj-code */
      ,input {&attr-ahsp-rest} /* p-code     */
      ,input 'true':u   /* p-value    */
      ) .

    /* инициализируем список поставщиков и поставщиков-товаров на основании остатка */
    run temp-supp-gds-fill in this-procedure
      (input v-obj-type           /* p-obj-type   */
      ,input v-obj-code           /* p-obj-code   */
      ,input v-day-end-fact-order /* p-fact-order */
      ) .

    /* обновляем список поставщиков и поставщиков товаров на основании оборота */
    run temp-supp-gds-from-doclslib in this-procedure .

    /* считываем старые остатки на конец рассчитываемого диапазона */
    run ahrstutl-init in this-procedure
      (input  v-obj-type             /* p-obj-type  */
      ,input  v-obj-code             /* p-obj-code  */
      ,input  v-ahsp-detail-date - 1 /* p-fact-date */
      ,input  false                  /* p-save-new  */
      ) .

    /* создание остатков на текущую дату начала складского архива */
    /* по тем поставщикам и поставщикам-товарам, по которым может имется оборот */
    run ahrstutl-create-stk in this-procedure
      (input  v-obj-type            /* p-obj-type  */
      ,input  v-obj-code            /* p-obj-code  */
      ,input  v-ahsp-detail-date - 1 /* p-fact-date */
      ) .

    /* удаление складского архива до текущей даты */
    /* следует независимо удалять складской архив по дням и складской архив по сменам */
    run ahrstutl-clear-ahsp in this-procedure
      (input  v-obj-type                 /* p-obj-type  */
      ,input  v-obj-code                 /* p-obj-code  */
      ,input  v-start-day-end-fact-order /* p-start-fact-order */
      ,input  v-ahsp-detail-date - 1     /* p-fact-date */
      ) .

    /* снятие блокировки на расчёт складского архива по поставщикам*/
    find current calc-supp-arh-lock_batchprocess no-lock .

    if v-clear-start = true
    then do:
      run show-action in this-procedure
        (input "Инициализация остатка на дату нового начала складского архива"
        ).
      /* инициализация остатков на дату нового начала складского архива */
      run trg/inahsp.p
        (input  this-procedure :handle   /* p-handle-callback    */
        ,input  v-obj-type               /* p-obj-type           */
        ,input  v-obj-code               /* p-obj-code           */
        ,input  v-restore-start-date - 1 /* p-new-start-date     */
        ,input  v-ahsp-detail-date - 1   /* p-current-start-date */
        ) .
    end.

    run show-action in this-procedure
      (input "Расчёт складского архива по поставщикам"
      ).

    /* расчет складского архива с ограничением на обновление остатков */
    run doclslib-calc-ahsp in this-procedure
      (input this-procedure         /* p-log-handle    */
      ,input v-obj-type             /* p-obj-type      */
      ,input v-obj-code             /* p-obj-code      */
      ,input v-ahsp-detail-date - 1 /* p-cut-date      */
      ,input false                  /* p-update-recalc */
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
        (input v-obj-type             /* p-obj-type  */
        ,input v-obj-code             /* p-obj-code  */
        ,input v-ahsp-detail-date - 1 /* p-fact-date */
        ,input true                   /* p-save-new  */
        ) .

      /* происходит обновление накопительных остатков */
      /* на основании новых рассчитанных остатков и старых остатков */
      run ahrstutl-update in this-procedure
        (input v-obj-type                /* p-obj-type       */
        ,input v-obj-code                /* p-obj-code       */
        ,input v-restore-detail-date - 1 /* p-first-cut-date */
        ,input v-ahsp-detail-date - 1    /* p-last-cut-date  */
        ) .
    end.

    run show-action in this-procedure
      (input "Блокировка расчёта складского архива по поставщикам"
      ).

    /* блокировка расчёта складского архива */
    define variable v-need-stop-ahsp as logical   no-undo .

    assign
      v-need-stop-ahsp = false
    .

    run gbl/lock-prc.p
      (input {&lock-prc-calc-supp-arh}
      ,input v-obj-code
      ,input 0
      ,input 0
      ,input v-obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
      ,input false
      ,buffer calc-supp-arh-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры блокировки расчета складского архива по поставщикам" skip
          "Невозможно продолжить восстановление складского архива по поставщикам" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error "Ошибка при вызове процедуры блокировки расчёта складского архива по поставщикам" .
      end.
      assign
        v-need-stop-ahsp = true
      .
    end.

    define buffer stop-ahsp-restore-lock_btpr for batchprocess .

    if v-need-stop-ahsp = true
    then do:
      /* если расчёт складского архива заблокирован, */
      /* отправить команду на остановку процесса расчёта складского архива */
      do transaction
      on error undo, return error return-value
      :
        create stop-ahsp-restore-lock_btpr .
        assign
          stop-ahsp-restore-lock_btpr.bp_type       = {&btpr-type-lock} + {&lock-prc-stop-ahsp-restore}
          stop-ahsp-restore-lock_btpr.bp_status     = {&btpr-normal}
          stop-ahsp-restore-lock_btpr.Key#_One      = v-obj-code
          stop-ahsp-restore-lock_btpr.Key#_Two      = 0
          stop-ahsp-restore-lock_btpr.Key#_Three    = 0
          stop-ahsp-restore-lock_btpr.CharKey_One   = v-obj-type
          stop-ahsp-restore-lock_btpr.CharKey_Two   = ""
          stop-ahsp-restore-lock_btpr.CharKey_Three = ""
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
            (input {&lock-prc-calc-supp-arh}
            ,input v-obj-code
            ,input 0
            ,input 0
            ,input v-obj-type
            ,input ""
            ,input ""
            ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
            ,input false
            ,buffer calc-supp-arh-lock_batchprocess
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры блокировки расчета складского архива по поставщикам" skip
                "Невозможно продолжить восстановление складского архива по поставщикам" skip
                view-as alert-box error .
              undo, return error "В данный момент рассчитывается складской архив по поставщикам" .
            end.
          end.
          else do:
            run waitfram-hide in this-procedure .
            leave wait_block .
          end.
          pause 1 no-message .
        end.

        delete stop-ahsp-restore-lock_btpr .
      end.
    end.

    run show-action in this-procedure
      (input "Удаление повторных записей остатков"
      ).

    /* удаление ненужных повторных записей старых остатков и новых остатков */
    run ahrstutl-delete-copy in this-procedure
      (input v-obj-type             /* p-obj-type  */
      ,input v-obj-code             /* p-obj-code  */
      ,input v-ahsp-detail-date - 1 /* p-fact-date */
      ) .

    run show-action in this-procedure
      (input "Обновление атрибутов складского архива"
      ).

    run clntattr-write in this-procedure
      (input v-obj-type                                   /* p-obj-type */
      ,input v-obj-code                                   /* p-obj-code */
      ,input {&attr-ahsp-start-date}                      /* p-code     */
      ,input string(v-restore-start-date, '99/99/9999':u) /* p-value    */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала складского архива по поставщикам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run clntattr-write in this-procedure
      (input v-obj-type                                    /* p-obj-type */
      ,input v-obj-code                                    /* p-obj-code */
      ,input {&attr-ahsp-detail-date}                      /* p-code     */
      ,input string(v-restore-detail-date, '99/99/9999':u) /* p-value    */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала подробного складского архива по поставщикам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    define variable v-delete-ahsp-rest as logical   no-undo .

    /* восстановление складского архива прошло успешно */
    /* удаляем признак того, что была ошибка при удалении складского архива */
    run clntattr-delete in this-procedure
      (input  v-obj-type         /* p-obj-type */
      ,input  v-obj-code         /* p-obj-code */
      ,input  {&attr-ahsp-rest}  /* p-code     */
      ,output v-delete-ahsp-rest /* p-deleted  */
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
      v-action-type = {&archive-history-rstfil-stop}
    .
  end.

  run utl/arhiscr.p
    (input  v-obj-type            /* p-obj-type              */
    ,input  v-obj-code            /* p-obj-code              */
    ,input  {&btpr-type-ahsp}     /* p-archive-type          */
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
    ,input  {&btpr-type-ahsp} /* p-archive-type */
    ,input  v-file-name       /* p-file-name    */
    ,input  v-create-chip-num /* p-chip-num     */
    ) .

  run invalidate-md5-signature in this-procedure
    (input  v-obj-type         /* p-obj-type     */
    ,input  v-obj-code         /* p-obj-code     */
    ,input  {&btpr-type-ahsp}  /* p-archive-type */
    ,input  v-backup-file-name /* p-file-name    */
    ,input  v-create-chip-num  /* p-chip-num     */
    ) .

  message
    "Восстановление складского архива по поставщикам успешно закончилось" skip
    "Объект" v-obj-type v-obj-code skip
    "" + (if v-restore-detail-date <> ?
         then substitute("На объекте существуют подробный складской архив с даты &1", string(v-restore-detail-date, '99/99/9999':u))
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
        when {&table_ot-supp-tot}
        then do:
          define buffer buf_temp-import-ot-supp-tot for temp-import-ot-supp-tot .
          create buf_temp-import-ot-supp-tot .
          import stream sinp buf_temp-import-ot-supp-tot no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при импорте таблицы temp-import-ot-supp-tot" skip
              "Строка" v-line-num skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-line-num = v-line-num + 1
          .

          define buffer buf_ot-supp-tot for ub.ot-supp-tot .
          create buf_ot-supp-tot .
          buffer-copy buf_temp-import-ot-supp-tot to buf_ot-supp-tot .

          delete buf_temp-import-ot-supp-tot .
        end.

        when {&table_ot-supp-line}
        then do:
          define buffer buf_temp-import-ot-supp-line for temp-import-ot-supp-line .
          create buf_temp-import-ot-supp-line .
          import stream sinp buf_temp-import-ot-supp-line except artic prod-type prod-code
            no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при импорте таблицы temp-import-ot-supp-line" skip
              "Строка" v-line-num skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-line-num = v-line-num + 1
          .

          run fill-artic in this-procedure
            (input  buf_temp-import-ot-supp-line.gds-code  /* p-gds-code  */
            ,output buf_temp-import-ot-supp-line.artic     /* p-artic     */
            ,output buf_temp-import-ot-supp-line.prod-type /* p-prod-type */
            ,output buf_temp-import-ot-supp-line.prod-code /* p-prod-code */
            ) .

          define buffer buf_ot-supp-line for ub.ot-supp-line .
          create buf_ot-supp-line .
          buffer-copy buf_temp-import-ot-supp-line to buf_ot-supp-line .

          delete buf_temp-import-ot-supp-line .
        end.

        when {&table_stk-supp-tot}
        then do:
          define buffer buf_temp-import-stk-supp-tot for temp-import-stk-supp-tot .
          create buf_temp-import-stk-supp-tot .
          import stream sinp buf_temp-import-stk-supp-tot no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при импорте таблицы temp-import-stk-supp-tot" skip
              "Строка" v-line-num skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-line-num = v-line-num + 1
          .

          define buffer buf_stk-supp-tot for ub.stk-supp-tot .
          create buf_stk-supp-tot .
          buffer-copy buf_temp-import-stk-supp-tot to buf_stk-supp-tot .

          delete buf_temp-import-stk-supp-tot .
        end.

        when {&table_stk-supp-line}
        then do:
          define buffer buf_temp-import-stk-supp-line for temp-import-stk-supp-line .
          create buf_temp-import-stk-supp-line .
          import stream sinp buf_temp-import-stk-supp-line except artic prod-type prod-code
            no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при импорте таблицы temp-import-stk-supp-line" skip
              "Строка" v-line-num skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-line-num = v-line-num + 1
          .

          run fill-artic in this-procedure
            (input  buf_temp-import-stk-supp-line.gds-code  /* p-gds-code  */
            ,output buf_temp-import-stk-supp-line.artic     /* p-artic     */
            ,output buf_temp-import-stk-supp-line.prod-type /* p-prod-type */
            ,output buf_temp-import-stk-supp-line.prod-code /* p-prod-code */
            ) .

          define buffer buf_stk-supp-line for ub.stk-supp-line .
          create buf_stk-supp-line .
          buffer-copy buf_temp-import-stk-supp-line to buf_stk-supp-line .

          delete buf_temp-import-stk-supp-line .
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
            "Складской архив по поставщикам" skip
            "Объект" v-obj-type v-obj-code skip
            "Неизвестный код таблицы" v-key-value skip
            "Строка" v-line-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
    end.

    if v-data-finished = false
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по поставщикам" skip
        "Объект" v-obj-type v-obj-code skip
        "Не найден признак окончания данных" skip
        "Неправильный формат файла" v-file-name skip
        "Строка" v-line-num skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

end procedure. /* restore-from-file */


procedure validate-file-name :

  define input parameter  p-obj-type            as character no-undo .
  define input parameter  p-obj-code            as integer   no-undo .
  define input parameter  v-ahsp-detail-date     as date      no-undo .
  define input parameter  p-file-name           as character no-undo .
  define output parameter p-restore-start-date  as date      no-undo .
  define output parameter p-restore-detail-date as date      no-undo .

  do
  on error undo, return error return-value
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
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'obj-type':u
    or v-param-value <> p-obj-type
    then do:
      message
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'obj-code':u
    or v-param-value <> string(p-obj-code)
    then do:
      message
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'old-start-date':u
    then do:
      message
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error return-value .
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
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error return-value .
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
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'new-detail-date':u
    then do:
      message
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if v-ahsp-detail-date <> date(v-param-value)
    then do:
      message
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Несоответствие текущей даты начала подробного складского архива по поставщикам" skip
        "и даты начала подробного архива в файле" p-file-name skip
        "Строка" v-line-num skip
        "Текущая дата начала подробного архива" string(v-ahsp-detail-date) skip
        "Дата начала подробного архива в файле" v-param-value skip
        "Восстановление складского архива по поставщикам невозможно" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

end procedure. /* validate-file-name */

procedure show-action :
  do
  on error undo, return error return-value
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
  on error undo, return error return-value
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

procedure store-temp :

  define buffer buf_temp-stk-supp-tot         for temp-stk-supp-tot .
  define buffer buf_temp-stk-supp-line        for temp-stk-supp-line .
  define buffer buf_temp-shift-stk-supp-tot   for temp-shift-stk-supp-tot .
  define buffer buf_temp-shift-stk-supp-line  for temp-shift-stk-supp-line .
  define buffer buf_temp-supp                 for temp-supp .
  define buffer buf_temp-supp-gds             for temp-supp-gds .
  define buffer buf_temp-create-stk-supp-tot  for temp-create-stk-supp-tot .
  define buffer buf_temp-create-stk-supp-line for temp-create-stk-supp-line .
  define buffer buf_doclslib-clients          for doclslib-clients .
  define buffer buf_doclslib-clients-goods    for doclslib-clients-goods .
  define buffer buf_doclslib-goods            for doclslib-goods .

  do
  on error undo, return error return-value
  :

    output stream sout to value ("rst-ahsp.txt") append .

    export stream sout 'export':u string(today, '99/99/9999':u) string(time, 'hh:mm:ss':u) .

    for each buf_temp-stk-supp-tot
    on error undo, return error return-value
    :
      export stream sout 'temp-stk-supp-tot':u .
      export stream sout buf_temp-stk-supp-tot .
    end.

    for each buf_temp-stk-supp-line
    on error undo, return error return-value
    :
      export stream sout 'temp-stk-supp-line':u .
      export stream sout buf_temp-stk-supp-line .
    end.

    for each buf_temp-shift-stk-supp-tot
    on error undo, return error return-value
    :
      export stream sout 'temp-shift-stk-supp-tot':u .
      export stream sout buf_temp-shift-stk-supp-tot .
    end.

    for each buf_temp-shift-stk-supp-line
    on error undo, return error return-value
    :
      export stream sout 'temp-shift-stk-supp-line':u .
      export stream sout buf_temp-shift-stk-supp-line .
    end.

    for each buf_temp-supp
    on error undo, return error return-value
    :
      export stream sout 'temp-supp':u .
      export stream sout buf_temp-supp .
    end.

    for each buf_temp-supp-gds
    on error undo, return error return-value
    :
      export stream sout 'temp-supp-gds':u .
      export stream sout buf_temp-supp-gds .
    end.

    for each buf_temp-create-stk-supp-tot
    on error undo, return error return-value
    :
      export stream sout 'temp-create-stk-supp-tot':u .
      export stream sout buf_temp-create-stk-supp-tot .
    end.

    for each buf_temp-create-stk-supp-line
    on error undo, return error return-value
    :
      export stream sout 'temp-create-stk-supp-line':u .
      export stream sout buf_temp-create-stk-supp-line .
    end.

    for each buf_doclslib-clients
    on error undo, return error return-value
    :
      export stream sout 'doclslib-clients':u .
      export stream sout buf_doclslib-clients.
    end.

    for each buf_doclslib-clients-goods
    on error undo, return error return-value
    :
      export stream sout 'doclslib-clients-goods':u .
      export stream sout buf_doclslib-clients-goods.
    end.

    for each buf_doclslib-goods
    on error undo, return error return-value
    :
      export stream sout 'doclslib-goods':u .
      export stream sout buf_doclslib-goods.
    end.

    output stream sout close .
  end.

end procedure. /* store-temp */

procedure temp-supp-clear :

  define buffer buf_temp-supp for temp-supp .

  do
  on error undo, return error return-value
  :
    for each buf_temp-supp
    on error undo, return error return-value
    :
      delete buf_temp-supp .
    end.
  end.

end procedure. /* temp-supp-clear */


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
    if not available buf_temp-supp
    then do:
      create buf_temp-supp .
      assign
        buf_temp-supp.cli-type  = p-cli-type
        buf_temp-supp.cli-code  = p-cli-code
      .
    end.
  end.

end procedure. /* temp-supp-create */


procedure temp-supp-gds-clear :

  define buffer buf_temp-supp-gds for temp-supp-gds .

  do
  on error undo, return error return-value
  :
    for each buf_temp-supp-gds
    on error undo, return error return-value
    :
      delete buf_temp-supp-gds .
    end.
  end.

end procedure. /* temp-supp-gds-clear */


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
    if not available buf_temp-supp-gds
    then do:
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
    on error undo, return error return-value
    :
      run temp-supp-create in this-procedure
        (input buf_stk-supp-line.cli-type
        ,input buf_stk-supp-line.cli-code
        ) .

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


procedure temp-supp-gds-from-doclslib :

  define buffer buf_doclslib-clients for doclslib-clients .
  define buffer buf_doclslib-clients-goods for doclslib-clients-goods .
  define buffer buf_temp-supp for temp-supp .
  define buffer buf_temp-supp-gds for temp-supp-gds .

  do
  on error undo, return error return-value
  :
    for each buf_doclslib-clients
    on error undo, return error return-value
    :
      run temp-supp-create in this-procedure
        (input buf_doclslib-clients.cli-type
        ,input buf_doclslib-clients.cli-code
        ) .
    end.

    for each buf_doclslib-clients-goods
    on error undo, return error return-value
    :
      run temp-supp-gds-create in this-procedure
        (input buf_doclslib-clients-goods.cli-type
        ,input buf_doclslib-clients-goods.cli-code
        ,input buf_doclslib-clients-goods.artic
        ,input buf_doclslib-clients-goods.prod-type
        ,input buf_doclslib-clients-goods.prod-code
        ) .
    end.
  end.

end procedure. /* temp-supp-gds-from-doclslib */


procedure ahrstutl-init :

  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-fact-date          as date      no-undo .
  define input  parameter p-save-new           as logical   no-undo .

  define buffer buf_doclslib-clients for doclslib-clients .
  define buffer buf_doclslib-clients-goods for doclslib-clients-goods .

  define variable v-shift-on                as logical   no-undo .
  define variable v-shift-date              as date      no-undo .
  define variable v-shift-num               as integer   no-undo .
  define variable v-day-end-fact-order      as decimal   no-undo .
  define variable v-shift-end-fact-order    as decimal   no-undo .
  define variable v-create-fact-order       as decimal   no-undo .
  define variable v-shift-create-fact-order as decimal   no-undo .

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

    run ahrstutl-supp-tot-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .

    run show-action in this-procedure
      (input "Остаток по поставщикам. Считывание"
      ).

    /* считываем значение остатка по объекту на определенный момент времени */
    define variable v-ind as integer   no-undo .

    do v-ind = 1 to num-entries(v-sum-type-list)
    :
      for each buf_doclslib-clients
      on error undo, return error return-value
      :
        run ahrstutl-init-supp-tot in this-procedure
          (input p-obj-type                    /* p-obj-type                      */
          ,input p-obj-code                    /* p-obj-code                      */
          ,input buf_doclslib-clients.cli-type /* p-cli-type                      */
          ,input buf_doclslib-clients.cli-code /* p-cli-code                      */
          ,input entry(v-ind, v-sum-type-list) /* p-root-sum-type                 */
          ,input p-fact-date                   /* p-fact-date                     */
          ,input v-day-end-fact-order          /* p-stk-supp-tot-fact-order       */
          ,input v-create-fact-order           /* p-create-tot-fact-order         */
          ,input v-shift-on                    /* p-shift-on                      */
          ,input v-shift-date                  /* p-shift-date                    */
          ,input v-shift-num                   /* p-shift-num                     */
          ,input v-shift-end-fact-order        /* p-shift-stk-supp-tot-fact-order */
          ,input v-shift-create-fact-order     /* p-shift-create-tot-fact-order   */
          ,input p-save-new                    /* p-save-new                      */
          ) .
      end.
    end.

    run ahrstutl-supp-line-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .

    run show-action in this-procedure
      (input "Остаток по поставщикам и товарам. Считывание"
      ).

    define variable v-total-count as integer   no-undo .

    for each buf_doclslib-clients-goods
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + string(buf_doclslib-clients-goods.artic)
          ).
      end.

      do v-ind = 1 to num-entries(v-sum-type-list)
      :
        run ahrstutl-init-supp-line in this-procedure
          (input p-obj-type                           /* p-obj-type                       */
          ,input p-obj-code                           /* p-obj-code                       */
          ,input buf_doclslib-clients-goods.cli-type  /* p-cli-type                       */
          ,input buf_doclslib-clients-goods.cli-code  /* p-cli-code                       */
          ,input buf_doclslib-clients-goods.artic     /* p-artic                          */
          ,input buf_doclslib-clients-goods.prod-type /* p-prod-type                      */
          ,input buf_doclslib-clients-goods.prod-code /* p-prod-code                      */
          ,input entry(v-ind, v-sum-type-list)        /* p-root-sum-type                  */
          ,input p-fact-date                          /* p-fact-date                      */
          ,input v-day-end-fact-order                 /* p-stk-supp-line-fact-order       */
          ,input v-create-fact-order                  /* p-create-line-fact-order         */
          ,input v-shift-on                           /* p-shift-on                       */
          ,input v-shift-date                         /* p-shift-date                     */
          ,input v-shift-num                          /* p-shift-num                      */
          ,input v-shift-end-fact-order               /* p-shift-stk-supp-line-fact-order */
          ,input v-shift-create-fact-order            /* p-shift-create-line-fact-order   */
          ,input p-save-new                           /* p-save-new                       */
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
  define input  parameter p-create-tot-fact-order         as decimal   no-undo .
  define input  parameter p-shift-on                      as logical   no-undo .
  define input  parameter p-shift-date                    as date      no-undo .
  define input  parameter p-shift-num                     as integer   no-undo .
  define input  parameter p-shift-stk-supp-tot-fact-order as decimal   no-undo .
  define input  parameter p-shift-create-tot-fact-order   as decimal   no-undo .
  define input  parameter p-save-new                      as logical   no-undo .

  define buffer buf_stk-supp-tot for ub.stk-supp-tot .
  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .
  define buffer buf_temp-shift-stk-supp-tot for temp-shift-stk-supp-tot .
  define buffer buf_temp-create-stk-supp-tot for temp-create-stk-supp-tot .

  define variable v-prev-stk-supp-tot-fact-order  like ub.stk-supp-tot.fact-order no-undo .
  define variable v-create-stk as logical   no-undo .

  do
  on error undo, return error return-value
  :
    find last buf_stk-supp-tot no-lock
      where buf_stk-supp-tot.obj-type   = p-obj-type
        and buf_stk-supp-tot.obj-code   = p-obj-code
        and buf_stk-supp-tot.cli-type   = p-cli-type
        and buf_stk-supp-tot.cli-code   = p-cli-code
        and buf_stk-supp-tot.sum-type   = p-root-sum-type
        and buf_stk-supp-tot.cat-id     = {&single-cat-id}
        and buf_stk-supp-tot.fact-order <= p-stk-supp-tot-fact-order
      use-index category
      no-error .
    if available buf_stk-supp-tot
    then do:
      assign
        v-prev-stk-supp-tot-fact-order = buf_stk-supp-tot.fact-order
      .

      if v-prev-stk-supp-tot-fact-order <> p-stk-supp-tot-fact-order
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
      for each buf_stk-supp-tot no-lock
        where buf_stk-supp-tot.obj-type   = p-obj-type
          and buf_stk-supp-tot.obj-code   = p-obj-code
          and buf_stk-supp-tot.cli-type   = p-cli-type
          and buf_stk-supp-tot.cli-code   = p-cli-code
          and buf_stk-supp-tot.fact-order = v-prev-stk-supp-tot-fact-order
          and buf_stk-supp-tot.sum-type   begins p-root-sum-type
      on error undo, return error return-value
      :
        find first buf_temp-stk-supp-tot
          where buf_temp-stk-supp-tot.obj-type   = buf_stk-supp-tot.obj-type
            and buf_temp-stk-supp-tot.obj-code   = buf_stk-supp-tot.obj-code
            and buf_temp-stk-supp-tot.cli-type   = buf_stk-supp-tot.cli-type
            and buf_temp-stk-supp-tot.cli-code   = buf_stk-supp-tot.cli-code
            and buf_temp-stk-supp-tot.fact-order = p-create-tot-fact-order
            and buf_temp-stk-supp-tot.sum-type   = buf_stk-supp-tot.sum-type
            and buf_temp-stk-supp-tot.cat-id     = buf_stk-supp-tot.cat-id
          no-error .
        if not available buf_temp-stk-supp-tot
        then do:
          create buf_temp-stk-supp-tot .
          assign
            &scop fp1 buf_temp-stk-supp-tot.
            &scop fp2 = buf_stk-supp-tot.
            {&stk-supp-tot-pair-list}
            buf_temp-stk-supp-tot.fact-order = p-create-tot-fact-order
            buf_temp-stk-supp-tot.fact-date  = p-fact-date
            buf_temp-stk-supp-tot.shift-num  = 0
            buf_temp-stk-supp-tot.shift-date = ?
          .
        end.

        if p-save-new = true
        then do:
          assign
            &scop fp1   buf_temp-stk-supp-tot.new-
            &scop fps1
            &scop fp2   = buf_stk-supp-tot.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
        else do:
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
        if p-shift-on
        then do:
          find first buf_temp-shift-stk-supp-tot
            where buf_temp-shift-stk-supp-tot.obj-type   = buf_stk-supp-tot.obj-type
              and buf_temp-shift-stk-supp-tot.obj-code   = buf_stk-supp-tot.obj-code
              and buf_temp-shift-stk-supp-tot.cli-type   = buf_stk-supp-tot.cli-type
              and buf_temp-shift-stk-supp-tot.cli-code   = buf_stk-supp-tot.cli-code
              and buf_temp-shift-stk-supp-tot.fact-order = p-shift-create-tot-fact-order
              and buf_temp-shift-stk-supp-tot.sum-type   = buf_stk-supp-tot.sum-type
              and buf_temp-shift-stk-supp-tot.cat-id     = buf_stk-supp-tot.cat-id
            no-error .
          if not available buf_temp-shift-stk-supp-tot
          then do:
            create buf_temp-shift-stk-supp-tot .
            assign
              &scop fp1 buf_temp-shift-stk-supp-tot.
              &scop fp2 = buf_stk-supp-tot.
              {&stk-supp-tot-pair-list}
              buf_temp-shift-stk-supp-tot.fact-order = p-shift-create-tot-fact-order
              buf_temp-shift-stk-supp-tot.fact-date  = p-fact-date
              buf_temp-shift-stk-supp-tot.shift-date = p-shift-date
              buf_temp-shift-stk-supp-tot.shift-num  = p-shift-num
            .
          end.
          if p-save-new = true
          then do:
            assign
              &scop fp1   buf_temp-shift-stk-supp-tot.new-
              &scop fps1
              &scop fp2   = buf_stk-supp-tot.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.
          else do:
            assign
              &scop fp1   buf_temp-shift-stk-supp-tot.
              &scop fps1
              &scop fp2   = buf_stk-supp-tot.
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

      find first buf_temp-stk-supp-tot
        where buf_temp-stk-supp-tot.obj-type   = p-obj-type
          and buf_temp-stk-supp-tot.obj-code   = p-obj-code
          and buf_temp-stk-supp-tot.cli-type   = p-cli-type
          and buf_temp-stk-supp-tot.cli-code   = p-cli-code
          and buf_temp-stk-supp-tot.fact-order = p-create-tot-fact-order
          and buf_temp-stk-supp-tot.sum-type   = p-root-sum-type
          and buf_temp-stk-supp-tot.cat-id     = {&single-cat-id}
        no-error .
      if not available buf_temp-stk-supp-tot
      then do:
        create buf_temp-stk-supp-tot .
        assign
          buf_temp-stk-supp-tot.obj-type   = p-obj-type
          buf_temp-stk-supp-tot.obj-code   = p-obj-code
          buf_temp-stk-supp-tot.cli-type   = p-cli-type
          buf_temp-stk-supp-tot.cli-code   = p-cli-code
          buf_temp-stk-supp-tot.sum-type   = p-root-sum-type
          buf_temp-stk-supp-tot.cat-id     = {&single-cat-id}
          buf_temp-stk-supp-tot.fact-order = p-create-tot-fact-order
          buf_temp-stk-supp-tot.fact-date  = p-fact-date
          buf_temp-stk-supp-tot.shift-num  = 0
          buf_temp-stk-supp-tot.shift-date = ?
        .
      end.
      if p-shift-on = true
      then do:
        find first buf_temp-shift-stk-supp-tot
          where buf_temp-shift-stk-supp-tot.obj-type   = p-obj-type
            and buf_temp-shift-stk-supp-tot.obj-code   = p-obj-code
            and buf_temp-shift-stk-supp-tot.cli-type   = p-cli-type
            and buf_temp-shift-stk-supp-tot.cli-code   = p-cli-code
            and buf_temp-shift-stk-supp-tot.fact-order = p-shift-create-tot-fact-order
            and buf_temp-shift-stk-supp-tot.sum-type   = p-root-sum-type
            and buf_temp-shift-stk-supp-tot.cat-id     = {&single-cat-id}
          no-error .
        if not available buf_temp-shift-stk-supp-tot
        then do:
          create buf_temp-shift-stk-supp-tot .
          assign
            buf_temp-shift-stk-supp-tot.obj-type   = p-obj-type
            buf_temp-shift-stk-supp-tot.obj-code   = p-obj-code
            buf_temp-shift-stk-supp-tot.cli-type   = p-cli-type
            buf_temp-shift-stk-supp-tot.cli-code   = p-cli-code
            buf_temp-shift-stk-supp-tot.sum-type   = p-root-sum-type
            buf_temp-shift-stk-supp-tot.cat-id     = {&single-cat-id}
            buf_temp-shift-stk-supp-tot.fact-order = p-shift-create-tot-fact-order
            buf_temp-shift-stk-supp-tot.fact-date  = p-fact-date
            buf_temp-shift-stk-supp-tot.shift-date = p-shift-date
            buf_temp-shift-stk-supp-tot.shift-num  = p-shift-num
          .
        end.
      end.
    end.

    if p-save-new = false
    then do:
      create buf_temp-create-stk-supp-tot .
      assign
        buf_temp-create-stk-supp-tot.obj-type    = p-obj-type
        buf_temp-create-stk-supp-tot.obj-code    = p-obj-code
        buf_temp-create-stk-supp-tot.cli-type    = p-cli-type
        buf_temp-create-stk-supp-tot.cli-code    = p-cli-code
        buf_temp-create-stk-supp-tot.sum-type    = p-root-sum-type
        buf_temp-create-stk-supp-tot.need-create = v-create-stk
      .
    end.
  end.

end procedure. /* ahrstutl-init-supp-tot */


procedure ahrstutl-init-supp-line :

  define input  parameter p-obj-type                       like ub.stk-supp-line.obj-type  no-undo .
  define input  parameter p-obj-code                       like ub.stk-supp-line.obj-code  no-undo .
  define input  parameter p-cli-type                       like ub.stk-supp-line.cli-type  no-undo .
  define input  parameter p-cli-code                       like ub.stk-supp-line.cli-code  no-undo .
  define input  parameter p-artic                          like ub.stk-supp-line.artic     no-undo .
  define input  parameter p-prod-type                      like ub.stk-supp-line.prod-type no-undo .
  define input  parameter p-prod-code                      like ub.stk-supp-line.prod-code no-undo .
  define input  parameter p-root-sum-type                  as character no-undo .
  define input  parameter p-fact-date                      as date      no-undo .
  define input  parameter p-stk-supp-line-fact-order       as decimal   no-undo .
  define input  parameter p-create-line-fact-order         as decimal   no-undo .
  define input  parameter p-shift-on                       as logical   no-undo .
  define input  parameter p-shift-date                     as date      no-undo .
  define input  parameter p-shift-num                      as integer   no-undo .
  define input  parameter p-shift-stk-supp-line-fact-order as decimal   no-undo .
  define input  parameter p-shift-create-line-fact-order   as decimal   no-undo .
  define input  parameter p-save-new                       as logical   no-undo .

  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-shift-stk-supp-line for temp-shift-stk-supp-line .
  define buffer buf_temp-create-stk-supp-line for temp-create-stk-supp-line .

  define variable v-prev-stk-supp-line-fact-order like ub.stk-line.fact-order no-undo .
  define variable v-create-stk as logical   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-create-stk = false
    .

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
    then do:
      assign
        v-prev-stk-supp-line-fact-order = buf_stk-supp-line.fact-order
      .

      if v-prev-stk-supp-line-fact-order <> p-stk-supp-line-fact-order
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
      on error undo, return error return-value
      :
        find first buf_temp-stk-supp-line
          where buf_temp-stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
            and buf_temp-stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
            and buf_temp-stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
            and buf_temp-stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
            and buf_temp-stk-supp-line.artic      = buf_stk-supp-line.artic
            and buf_temp-stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
            and buf_temp-stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
            and buf_temp-stk-supp-line.fact-order = p-create-line-fact-order
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
            buf_temp-stk-supp-line.fact-order = p-create-line-fact-order
            buf_temp-stk-supp-line.fact-date  = p-fact-date
            buf_temp-stk-supp-line.shift-num  = 0
            buf_temp-stk-supp-line.shift-date = ?
          .
        end.
        if p-save-new = true
        then do:
          assign
            &scop fp1   buf_temp-stk-supp-line.new-
            &scop fps1
            &scop fp2   = buf_stk-supp-line.
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
        else do:
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
        if p-shift-on
        then do:
          find first buf_temp-shift-stk-supp-line
            where buf_temp-shift-stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
              and buf_temp-shift-stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
              and buf_temp-shift-stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
              and buf_temp-shift-stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
              and buf_temp-shift-stk-supp-line.artic      = buf_stk-supp-line.artic
              and buf_temp-shift-stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
              and buf_temp-shift-stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
              and buf_temp-shift-stk-supp-line.fact-order = p-shift-create-line-fact-order
              and buf_temp-shift-stk-supp-line.sum-type   = buf_stk-supp-line.sum-type
              and buf_temp-shift-stk-supp-line.cat-id     = buf_stk-supp-line.cat-id
            no-error .
          if not available buf_temp-shift-stk-supp-line
          then do:
            create buf_temp-shift-stk-supp-line .
            assign
              &scop fp1 buf_temp-shift-stk-supp-line.
              &scop fp2 = buf_stk-supp-line.
              {&stk-supp-line-pair-list}
              buf_temp-shift-stk-supp-line.fact-order = p-shift-create-line-fact-order
              buf_temp-shift-stk-supp-line.fact-date  = p-fact-date
              buf_temp-shift-stk-supp-line.shift-date = p-shift-date
              buf_temp-shift-stk-supp-line.shift-num  = p-shift-num
            .
          end.
          if p-save-new = true
          then do:
            assign
              &scop fp1   buf_temp-shift-stk-supp-line.new-
              &scop fps1
              &scop fp2   = buf_stk-supp-line.
              &scop fps2
              &scop fp3
              &scop fp4
              {&price-pair-list}
            .
          end.
          else do:
            assign
              &scop fp1   buf_temp-shift-stk-supp-line.
              &scop fps1
              &scop fp2   = buf_stk-supp-line.
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

      find first buf_temp-stk-supp-line
        where buf_temp-stk-supp-line.obj-type   = p-obj-type
          and buf_temp-stk-supp-line.obj-code   = p-obj-code
          and buf_temp-stk-supp-line.cli-type   = p-cli-type
          and buf_temp-stk-supp-line.cli-code   = p-cli-code
          and buf_temp-stk-supp-line.artic      = p-artic
          and buf_temp-stk-supp-line.prod-type  = p-prod-type
          and buf_temp-stk-supp-line.prod-code  = p-prod-code
          and buf_temp-stk-supp-line.fact-order = p-create-line-fact-order
          and buf_temp-stk-supp-line.sum-type   = p-root-sum-type
          and buf_temp-stk-supp-line.cat-id     = {&single-cat-id}
        no-error .
      if not available buf_temp-stk-supp-line
      then do:
        create buf_temp-stk-supp-line .
        assign
          buf_temp-stk-supp-line.obj-type   = p-obj-type
          buf_temp-stk-supp-line.obj-code   = p-obj-code
          buf_temp-stk-supp-line.cli-type   = p-cli-type
          buf_temp-stk-supp-line.cli-code   = p-cli-code
          buf_temp-stk-supp-line.artic      = p-artic
          buf_temp-stk-supp-line.prod-type  = p-prod-type
          buf_temp-stk-supp-line.prod-code  = p-prod-code
          buf_temp-stk-supp-line.sum-type   = p-root-sum-type
          buf_temp-stk-supp-line.cat-id     = {&single-cat-id}
          buf_temp-stk-supp-line.fact-order = p-create-line-fact-order
          buf_temp-stk-supp-line.fact-date  = p-fact-date
          buf_temp-stk-supp-line.shift-num  = 0
          buf_temp-stk-supp-line.shift-date = ?
        .
      end.

      if p-shift-on = true
      then do:
        find first buf_temp-shift-stk-supp-line
          where buf_temp-shift-stk-supp-line.obj-type   = p-obj-type
            and buf_temp-shift-stk-supp-line.obj-code   = p-obj-code
            and buf_temp-shift-stk-supp-line.cli-type   = p-cli-type
            and buf_temp-shift-stk-supp-line.cli-code   = p-cli-code
            and buf_temp-shift-stk-supp-line.artic      = p-artic
            and buf_temp-shift-stk-supp-line.prod-type  = p-prod-type
            and buf_temp-shift-stk-supp-line.prod-code  = p-prod-code
            and buf_temp-shift-stk-supp-line.fact-order = p-shift-create-line-fact-order
            and buf_temp-shift-stk-supp-line.sum-type   = p-root-sum-type
            and buf_temp-shift-stk-supp-line.cat-id     = {&single-cat-id}
          no-error .
        if not available buf_temp-shift-stk-supp-line
        then do:
          create buf_temp-shift-stk-supp-line .
          assign
            buf_temp-shift-stk-supp-line.obj-type   = p-obj-type
            buf_temp-shift-stk-supp-line.obj-code   = p-obj-code
            buf_temp-shift-stk-supp-line.cli-type   = p-cli-type
            buf_temp-shift-stk-supp-line.cli-code   = p-cli-code
            buf_temp-shift-stk-supp-line.artic      = p-artic
            buf_temp-shift-stk-supp-line.prod-type  = p-prod-type
            buf_temp-shift-stk-supp-line.prod-code  = p-prod-code
            buf_temp-shift-stk-supp-line.sum-type   = p-root-sum-type
            buf_temp-shift-stk-supp-line.cat-id     = {&single-cat-id}
            buf_temp-shift-stk-supp-line.fact-order = p-shift-create-line-fact-order
            buf_temp-shift-stk-supp-line.fact-date  = p-fact-date
            buf_temp-shift-stk-supp-line.shift-date = p-shift-date
            buf_temp-shift-stk-supp-line.shift-num  = p-shift-num
          .
        end.
      end.
    end.

    if p-save-new = false
    then do:
      create buf_temp-create-stk-supp-line .
      assign
        buf_temp-create-stk-supp-line.obj-type    = p-obj-type
        buf_temp-create-stk-supp-line.obj-code    = p-obj-code
        buf_temp-create-stk-supp-line.cli-type    = p-cli-type
        buf_temp-create-stk-supp-line.cli-code    = p-cli-code
        buf_temp-create-stk-supp-line.artic       = p-artic
        buf_temp-create-stk-supp-line.prod-type   = p-prod-type
        buf_temp-create-stk-supp-line.prod-code   = p-prod-code
        buf_temp-create-stk-supp-line.sum-type    = p-root-sum-type
        buf_temp-create-stk-supp-line.need-create = v-create-stk
      .
    end.
  end.

end procedure. /* ahrstutl-init-supp-line */


procedure ahrstutl-create-stk :

  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .

  define variable v-shift-on                as logical   no-undo .
  define variable v-shift-date              as date      no-undo .
  define variable v-shift-num               as integer   no-undo .
  define variable v-day-end-fact-order      as decimal   no-undo .
  define variable v-shift-end-fact-order    as decimal   no-undo .

  define buffer buf_temp-create-stk-supp-tot  for temp-create-stk-supp-tot .
  define buffer buf_temp-create-stk-supp-line for temp-create-stk-supp-line .
  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .
  define buffer buf_stk-supp-tot for ub.stk-supp-tot .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_stk-supp-line for ub.stk-supp-line .

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

    for each buf_temp-create-stk-supp-tot
      where buf_temp-create-stk-supp-tot.need-create = true
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

      for each buf_temp-stk-supp-tot
        where buf_temp-stk-supp-tot.obj-type   = buf_temp-create-stk-supp-tot.obj-type
          and buf_temp-stk-supp-tot.obj-code   = buf_temp-create-stk-supp-tot.obj-code
          and buf_temp-stk-supp-tot.cli-type   = buf_temp-create-stk-supp-tot.cli-type
          and buf_temp-stk-supp-tot.cli-code   = buf_temp-create-stk-supp-tot.cli-code
          and buf_temp-stk-supp-tot.fact-order = v-day-end-fact-order
          and buf_temp-stk-supp-tot.sum-type   begins buf_temp-create-stk-supp-tot.sum-type
      on error undo, return error return-value
      :
        create buf_stk-supp-tot .
        buffer-copy buf_temp-stk-supp-tot to buf_stk-supp-tot
        .
      end.

      if v-shift-on = true
      then do:
        for each buf_temp-stk-supp-tot
          where buf_temp-stk-supp-tot.obj-type   = buf_temp-create-stk-supp-tot.obj-type
            and buf_temp-stk-supp-tot.obj-code   = buf_temp-create-stk-supp-tot.obj-code
            and buf_temp-stk-supp-tot.cli-type   = buf_temp-create-stk-supp-tot.cli-type
            and buf_temp-stk-supp-tot.cli-code   = buf_temp-create-stk-supp-tot.cli-code
            and buf_temp-stk-supp-tot.fact-order = v-shift-end-fact-order
            and buf_temp-stk-supp-tot.sum-type   begins buf_temp-create-stk-supp-tot.sum-type
        on error undo, return error return-value
        :
          create buf_stk-supp-tot .
          buffer-copy buf_temp-stk-supp-tot to buf_stk-supp-tot
          .
        end.
      end.
    end.

    assign
      v-total-count = 0
    .

    for each buf_temp-create-stk-supp-line
      where buf_temp-create-stk-supp-line.need-create = true
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + buf_temp-create-stk-supp-line.artic
          ).
      end.

      for each buf_temp-stk-supp-line
        where buf_temp-stk-supp-line.obj-type   = buf_temp-create-stk-supp-line.obj-type
          and buf_temp-stk-supp-line.obj-code   = buf_temp-create-stk-supp-line.obj-code
          and buf_temp-stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
          and buf_temp-stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
          and buf_temp-stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
          and buf_temp-stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
          and buf_temp-stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
          and buf_temp-stk-supp-line.fact-order = v-day-end-fact-order
          and buf_temp-stk-supp-line.sum-type   begins buf_temp-create-stk-supp-line.sum-type
      on error undo, return error return-value
      :
        create buf_stk-supp-line .
        buffer-copy buf_temp-stk-supp-line to buf_stk-supp-line
        .
      end.

      if v-shift-on = true
      then do:
        for each buf_temp-stk-supp-line
          where buf_temp-stk-supp-line.obj-type   = buf_temp-create-stk-supp-line.obj-type
            and buf_temp-stk-supp-line.obj-code   = buf_temp-create-stk-supp-line.obj-code
            and buf_temp-stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
            and buf_temp-stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
            and buf_temp-stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
            and buf_temp-stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
            and buf_temp-stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
            and buf_temp-stk-supp-line.fact-order = v-shift-end-fact-order
            and buf_temp-stk-supp-line.sum-type   begins buf_temp-create-stk-supp-line.sum-type
        on error undo, return error return-value
        :
          create buf_stk-supp-line .
          buffer-copy buf_temp-stk-supp-line to buf_stk-supp-line
          .
        end.
      end.
    end.
  end.

end procedure. /* ahrstutl-create-stk */


procedure ahrstutl-clear-ahsp :

  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-start-fact-order as decimal   no-undo .
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
        and buf_ot-supp-tot.fact-order > p-start-fact-order
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
        and buf_ot-supp-line.fact-order > p-start-fact-order
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
        and buf_stk-supp-tot.fact-order > p-start-fact-order
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
        and buf_stk-supp-line.fact-order > p-start-fact-order
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

end procedure. /* ahrstutl-clear-ahsp */


procedure ahrstutl-delete-copy :

  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .

  define buffer buf_stk-supp-tot  for ub.stk-supp-tot .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_temp-create-stk-supp-tot for temp-create-stk-supp-tot .
  define buffer buf_temp-create-stk-supp-line for temp-create-stk-supp-line .

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

    for each buf_temp-create-stk-supp-tot
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

      find last buf_stk-supp-tot no-lock
        where buf_stk-supp-tot.obj-type   = buf_temp-create-stk-supp-tot.obj-type
          and buf_stk-supp-tot.obj-code   = buf_temp-create-stk-supp-tot.obj-code
          and buf_stk-supp-tot.cli-type   = buf_temp-create-stk-supp-tot.cli-type
          and buf_stk-supp-tot.cli-code   = buf_temp-create-stk-supp-tot.cli-code
          and buf_stk-supp-tot.fact-order = v-day-end-fact-order - {&arh-delta}
          and buf_stk-supp-tot.sum-type   = buf_temp-create-stk-supp-tot.sum-type
          and buf_stk-supp-tot.cat-id     = {&single-cat-id}
        no-error .
      if available buf_stk-supp-tot
      then do:
        for each buf_stk-supp-tot exclusive-lock
          where buf_stk-supp-tot.obj-type   = buf_temp-create-stk-supp-tot.obj-type
            and buf_stk-supp-tot.obj-code   = buf_temp-create-stk-supp-tot.obj-code
            and buf_stk-supp-tot.cli-type   = buf_temp-create-stk-supp-tot.cli-type
            and buf_stk-supp-tot.cli-code   = buf_temp-create-stk-supp-tot.cli-code
            and buf_stk-supp-tot.fact-order = v-day-end-fact-order - {&arh-delta}
            and buf_stk-supp-tot.sum-type   begins buf_temp-create-stk-supp-tot.sum-type
        on error undo, return error return-value
        :
          /* todo - сравнить с информацией в buf_temp-stk-supp-tot */
          delete buf_stk-supp-tot .
        end.
      end.
      else do:
        for each buf_stk-supp-tot exclusive-lock
          where buf_stk-supp-tot.obj-type   = buf_temp-create-stk-supp-tot.obj-type
            and buf_stk-supp-tot.obj-code   = buf_temp-create-stk-supp-tot.obj-code
            and buf_stk-supp-tot.cli-type   = buf_temp-create-stk-supp-tot.cli-type
            and buf_stk-supp-tot.cli-code   = buf_temp-create-stk-supp-tot.cli-code
            and buf_stk-supp-tot.fact-order = v-day-end-fact-order
            and buf_stk-supp-tot.sum-type   begins buf_temp-create-stk-supp-tot.sum-type
        on error undo, return error return-value
        :
          /* todo - провести поиск предыдущего stk-supp-tot и проверить отсутствие оборотов */
          delete buf_stk-supp-tot .
        end.
      end.

      if v-shift-on = true
      then do:
        find last buf_stk-supp-tot no-lock
          where buf_stk-supp-tot.obj-type   = buf_temp-create-stk-supp-tot.obj-type
            and buf_stk-supp-tot.obj-code   = buf_temp-create-stk-supp-tot.obj-code
            and buf_stk-supp-tot.cli-type   = buf_temp-create-stk-supp-tot.cli-type
            and buf_stk-supp-tot.cli-code   = buf_temp-create-stk-supp-tot.cli-code
            and buf_stk-supp-tot.fact-order = v-shift-end-fact-order - {&arh-delta}
            and buf_stk-supp-tot.sum-type   = buf_temp-create-stk-supp-tot.sum-type
            and buf_stk-supp-tot.cat-id     = {&single-cat-id}
          no-error .
        if available buf_stk-supp-tot
        then do:
          for each buf_stk-supp-tot exclusive-lock
            where buf_stk-supp-tot.obj-type   = buf_temp-create-stk-supp-tot.obj-type
              and buf_stk-supp-tot.obj-code   = buf_temp-create-stk-supp-tot.obj-code
              and buf_stk-supp-tot.cli-type   = buf_temp-create-stk-supp-tot.cli-type
              and buf_stk-supp-tot.cli-code   = buf_temp-create-stk-supp-tot.cli-code
              and buf_stk-supp-tot.fact-order = v-shift-end-fact-order - {&arh-delta}
              and buf_stk-supp-tot.sum-type   begins buf_temp-create-stk-supp-tot.sum-type
          on error undo, return error return-value
          :
            /* todo - сравнить с информацией в buf_temp-stk-supp-tot */
            delete buf_stk-supp-tot .
          end.
        end.
        else do:
          for each buf_stk-supp-tot exclusive-lock
            where buf_stk-supp-tot.obj-type   = buf_temp-create-stk-supp-tot.obj-type
              and buf_stk-supp-tot.obj-code   = buf_temp-create-stk-supp-tot.obj-code
              and buf_stk-supp-tot.cli-type   = buf_temp-create-stk-supp-tot.cli-type
              and buf_stk-supp-tot.cli-code   = buf_temp-create-stk-supp-tot.cli-code
              and buf_stk-supp-tot.fact-order = v-shift-end-fact-order
              and buf_stk-supp-tot.sum-type   begins buf_temp-create-stk-supp-tot.sum-type
          on error undo, return error return-value
          :
            /* todo - провести поиск предыдущего stk-supp-tot и проверить отсутствие оборотов */
            delete buf_stk-supp-tot .
          end.
        end.
      end.
    end.

    assign
      v-total-count = 0
    .

    for each buf_temp-create-stk-supp-line
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + buf_temp-create-stk-supp-line.artic
          ).
      end.

      find first buf_stk-supp-line no-lock
        where buf_stk-supp-line.obj-type   = buf_temp-create-stk-supp-line.obj-type
          and buf_stk-supp-line.obj-code   = buf_temp-create-stk-supp-line.obj-code
          and buf_stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
          and buf_stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
          and buf_stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
          and buf_stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
          and buf_stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
          and buf_stk-supp-line.fact-order = v-day-end-fact-order - {&arh-delta}
          and buf_stk-supp-line.sum-type   = buf_temp-create-stk-supp-line.sum-type
          and buf_stk-supp-line.cat-id     = {&single-cat-id}
        no-error .
      if available buf_stk-supp-line
      then do:
        for each buf_stk-supp-line exclusive-lock
          where buf_stk-supp-line.obj-type   = buf_temp-create-stk-supp-line.obj-type
            and buf_stk-supp-line.obj-code   = buf_temp-create-stk-supp-line.obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
            and buf_stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
            and buf_stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
            and buf_stk-supp-line.fact-order = v-day-end-fact-order - {&arh-delta}
            and buf_stk-supp-line.sum-type   begins buf_temp-create-stk-supp-line.sum-type
        on error undo, return error return-value
        :
          /* todo - сравнить с информацией в buf_temp-stk-supp-line */
          delete buf_stk-supp-line .
        end.
      end.
      else do:
        for each buf_stk-supp-line exclusive-lock
          where buf_stk-supp-line.obj-type   = buf_temp-create-stk-supp-line.obj-type
            and buf_stk-supp-line.obj-code   = buf_temp-create-stk-supp-line.obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
            and buf_stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
            and buf_stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
            and buf_stk-supp-line.fact-order = v-day-end-fact-order
            and buf_stk-supp-line.sum-type   begins buf_temp-create-stk-supp-line.sum-type
        on error undo, return error return-value
        :
          /* todo - провести поиск предыдущего stk-supp-line и проверить отсутствие оборотов */
          delete buf_stk-supp-line .
        end.
      end.

      if v-shift-on = true
      then do:
        find first buf_stk-supp-line no-lock
          where buf_stk-supp-line.obj-type   = buf_temp-create-stk-supp-line.obj-type
            and buf_stk-supp-line.obj-code   = buf_temp-create-stk-supp-line.obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
            and buf_stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
            and buf_stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
            and buf_stk-supp-line.fact-order = v-shift-end-fact-order - {&arh-delta}
            and buf_stk-supp-line.sum-type   = buf_temp-create-stk-supp-line.sum-type
            and buf_stk-supp-line.cat-id     = {&single-cat-id}
          no-error .
        if available buf_stk-supp-line
        then do:
          for each buf_stk-supp-line exclusive-lock
            where buf_stk-supp-line.obj-type   = buf_temp-create-stk-supp-line.obj-type
              and buf_stk-supp-line.obj-code   = buf_temp-create-stk-supp-line.obj-code
              and buf_stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
              and buf_stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
              and buf_stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
              and buf_stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
              and buf_stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
              and buf_stk-supp-line.fact-order = v-shift-end-fact-order - {&arh-delta}
              and buf_stk-supp-line.sum-type   begins buf_temp-create-stk-supp-line.sum-type
          on error undo, return error return-value
          :
            /* todo - сравнить с информацией в buf_temp-stk-supp-line */
            delete buf_stk-supp-line .
          end.
        end.
        else do:
          for each buf_stk-supp-line exclusive-lock
            where buf_stk-supp-line.obj-type   = buf_temp-create-stk-supp-line.obj-type
              and buf_stk-supp-line.obj-code   = buf_temp-create-stk-supp-line.obj-code
              and buf_stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
              and buf_stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
              and buf_stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
              and buf_stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
              and buf_stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
              and buf_stk-supp-line.fact-order = v-shift-end-fact-order
              and buf_stk-supp-line.sum-type   begins buf_temp-create-stk-supp-line.sum-type
          on error undo, return error return-value
          :
            /* todo - провести поиск предыдущего stk-supp-line и проверить отсутствие оборотов */
            delete buf_stk-supp-line .
          end.
        end.
      end.
    end.

    define buffer buf_doclslib-clients-goods for doclslib-clients-goods .

    for each buf_temp-create-stk-supp-line
    on error undo, return error return-value
    :
      /* для всех товаров, у которых не было оборота в течение периода */
      /* удаляем остатки на конец периода */
      find first buf_doclslib-clients-goods
        where buf_doclslib-clients-goods.cli-type  = buf_temp-create-stk-supp-line.cli-type
          and buf_doclslib-clients-goods.cli-code  = buf_temp-create-stk-supp-line.cli-code
          and buf_doclslib-clients-goods.artic     = buf_temp-create-stk-supp-line.artic
          and buf_doclslib-clients-goods.prod-type = buf_temp-create-stk-supp-line.prod-type
          and buf_doclslib-clients-goods.prod-code = buf_temp-create-stk-supp-line.prod-code
        no-error .
      if not available buf_doclslib-clients-goods
      then do:
        for each buf_stk-supp-line exclusive-lock
          where buf_stk-supp-line.obj-type   = p-obj-type
            and buf_stk-supp-line.obj-code   = p-obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
            and buf_stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
            and buf_stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
            and buf_stk-supp-line.fact-order = v-day-end-fact-order
        on error undo, return error return-value
        :
          delete buf_stk-supp-line .
        end.

        if v-shift-on = true
        then do:
          for each buf_stk-supp-line exclusive-lock
            where buf_stk-supp-line.obj-type   = p-obj-type
              and buf_stk-supp-line.obj-code   = p-obj-code
              and buf_stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
              and buf_stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
              and buf_stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
              and buf_stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
              and buf_stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
              and buf_stk-supp-line.fact-order = v-shift-end-fact-order
          on error undo, return error return-value
          :
            delete buf_stk-supp-line .
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

  define buffer buf_temp-supp for temp-supp .
  define buffer buf_temp-supp-gds for temp-supp-gds .

  define variable v-shift-on                   as logical   no-undo .
  define variable v-first-shift-date           as date      no-undo .
  define variable v-first-shift-num            as integer   no-undo .
  define variable v-first-day-end-fact-order   as decimal   no-undo .
  define variable v-first-shift-end-fact-order as decimal   no-undo .
  define variable v-last-shift-date            as date      no-undo .
  define variable v-last-shift-num             as integer   no-undo .
  define variable v-last-day-end-fact-order    as decimal   no-undo .
  define variable v-last-shift-end-fact-order  as decimal   no-undo .

  define variable v-sum-type-list as character no-undo .
  define variable v-ind as integer   no-undo .

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
      (input "Пересчитываем остаток по поставщикам"
      ).

    run ahrstutl-supp-tot-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .

    do v-ind = 1 to num-entries(v-sum-type-list)
    :
      for each buf_temp-supp
      on error undo, return error return-value
      :
        run ahrstutl-store-supp-tot in this-procedure
          (input p-obj-type                    /* p-obj-type                   */
          ,input p-obj-code                    /* p-obj-code                   */
          ,input buf_temp-supp.cli-type        /* p-cli-type                   */
          ,input buf_temp-supp.cli-code        /* p-cli-code                   */
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
            "Ошибка при вызове процедуры" 'ahrstutl-store-supp-tot':u skip
            "Клиент" buf_temp-supp.cli-type buf_temp-supp.cli-code skip
            "v-ind" v-ind skip
            "sum-type" entry(v-ind, v-sum-type-list) skip
            return-value skip
            error-status :get-message(1) skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.

    run show-action in this-procedure
      (input "Пересчитываем остаток по поставщикам, товарам"
      ).

    run ahrstutl-supp-line-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .

    define variable v-total-count as integer   no-undo .

    for each buf_temp-supp-gds
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + string(buf_temp-supp-gds.artic)
          ).
      end.

      do v-ind = 1 to num-entries(v-sum-type-list)
      :
        run ahrstutl-store-supp-line in this-procedure
          (input p-obj-type                    /* p-obj-type                   */
          ,input p-obj-code                    /* p-obj-code                   */
          ,input buf_temp-supp-gds.cli-type    /* p-cli-type                   */
          ,input buf_temp-supp-gds.cli-code    /* p-cli-code                   */
          ,input buf_temp-supp-gds.artic       /* p-artic                      */
          ,input buf_temp-supp-gds.prod-type   /* p-prod-type                  */
          ,input buf_temp-supp-gds.prod-code   /* p-prod-code                  */
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
            "Ошибка при вызове процедуры" 'ahrstutl-store-supp-line':u skip
            "Объект" p-obj-type p-obj-code skip
            "Клиент" buf_temp-supp-gds.cli-type buf_temp-supp-gds.cli-code skip
            "Артикул" buf_temp-supp-gds.artic buf_temp-supp-gds.prod-type buf_temp-supp-gds.prod-code skip
            return-value skip
            error-status :get-message(1) skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
  end.
end procedure. /* ahrstutl-update */


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

end procedure. /* ahrstutl-tot-sum-type-list */


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

end procedure. /* ahrstutl-line-sum-type-list */


procedure ahrstutl-store-supp-tot :

  define input  parameter p-obj-type                   as character no-undo .
  define input  parameter p-obj-code                   as integer   no-undo .
  define input  parameter p-cli-type                   as character no-undo .
  define input  parameter p-cli-code                   as integer   no-undo .
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

  define buffer buf_stk-supp-tot            for ub.stk-supp-tot .
  define buffer buf_temp-stk-supp-tot       for temp-stk-supp-tot .
  define buffer buf_temp-shift-stk-supp-tot for temp-shift-stk-supp-tot .
  define buffer sub_temp-stk-supp-tot       for temp-stk-supp-tot .
  define buffer sub_stk-supp-tot            for ub.stk-supp-tot .
  define buffer sub_temp-shift-stk-supp-tot for temp-stk-supp-tot .

  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-supp-tot
      where buf_temp-stk-supp-tot.obj-type = p-obj-type
        and buf_temp-stk-supp-tot.obj-code = p-obj-code
        and buf_temp-stk-supp-tot.cli-type = p-cli-type
        and buf_temp-stk-supp-tot.cli-code = p-cli-code
        and buf_temp-stk-supp-tot.sum-type = p-sum-type
    on error undo, return error return-value
    :
      if
      &scop fp1   buf_temp-stk-supp-tot.
      &scop fps1
      &scop fp2   <> buf_temp-stk-supp-tot.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
      then do:
        /* ищем первоначальную корневую запись */
        /* если ее нет, то создаем ее */
        find first buf_stk-supp-tot exclusive-lock
          where buf_stk-supp-tot.obj-type   = buf_temp-stk-supp-tot.obj-type
            and buf_stk-supp-tot.obj-code   = buf_temp-stk-supp-tot.obj-code
            and buf_stk-supp-tot.cli-type   = buf_temp-stk-supp-tot.cli-type
            and buf_stk-supp-tot.cli-code   = buf_temp-stk-supp-tot.cli-code
            and buf_stk-supp-tot.sum-type   = buf_temp-stk-supp-tot.sum-type
            and buf_stk-supp-tot.cat-id     = buf_temp-stk-supp-tot.cat-id
            and buf_stk-supp-tot.fact-order <= p-first-day-end-fact-order
            and buf_stk-supp-tot.shift-date = ?
          no-error .
        if not available buf_stk-supp-tot
        then do:
          create buf_stk-supp-tot .
          assign
            buf_stk-supp-tot.obj-type   = buf_temp-stk-supp-tot.obj-type
            buf_stk-supp-tot.obj-code   = buf_temp-stk-supp-tot.obj-code
            buf_stk-supp-tot.cli-type   = buf_temp-stk-supp-tot.cli-type
            buf_stk-supp-tot.cli-code   = buf_temp-stk-supp-tot.cli-code
            buf_stk-supp-tot.fact-order = p-first-day-end-fact-order
            buf_stk-supp-tot.sum-type   = buf_temp-stk-supp-tot.sum-type
            buf_stk-supp-tot.cat-id     = buf_temp-stk-supp-tot.cat-id
            buf_stk-supp-tot.fact-date  = p-first-cut-date
            buf_stk-supp-tot.shift-num  = 0
            buf_stk-supp-tot.shift-date = ?
          .
        end.

        for each buf_stk-supp-tot exclusive-lock
          where buf_stk-supp-tot.obj-type   = buf_temp-stk-supp-tot.obj-type
            and buf_stk-supp-tot.obj-code   = buf_temp-stk-supp-tot.obj-code
            and buf_stk-supp-tot.cli-type   = buf_temp-stk-supp-tot.cli-type
            and buf_stk-supp-tot.cli-code   = buf_temp-stk-supp-tot.cli-code
            and buf_stk-supp-tot.sum-type   = buf_temp-stk-supp-tot.sum-type
            and buf_stk-supp-tot.cat-id     = buf_temp-stk-supp-tot.cat-id
            and buf_stk-supp-tot.fact-order <= p-last-day-end-fact-order - {&arh-delta}
            and buf_stk-supp-tot.shift-date = ?
        on error undo, return error return-value
        :
          for each sub_temp-stk-supp-tot
            where sub_temp-stk-supp-tot.obj-type   = buf_temp-stk-supp-tot.obj-type
              and sub_temp-stk-supp-tot.obj-code   = buf_temp-stk-supp-tot.obj-code
              and sub_temp-stk-supp-tot.cli-type   = buf_temp-stk-supp-tot.cli-type
              and sub_temp-stk-supp-tot.cli-code   = buf_temp-stk-supp-tot.cli-code
              and sub_temp-stk-supp-tot.fact-order = buf_temp-stk-supp-tot.fact-order
              and sub_temp-stk-supp-tot.sum-type   begins buf_temp-stk-supp-tot.sum-type
          on error undo, return error return-value
          :
            if
            &scop fp1   sub_temp-stk-supp-tot.
            &scop fps1
            &scop fp2   <> sub_temp-stk-supp-tot.new-
            &scop fps2
            &scop fp3
            &scop fp4   or
            {&price-pair-list}
            then do:
              find first sub_stk-supp-tot exclusive-lock
                where sub_stk-supp-tot.obj-type   = buf_stk-supp-tot.obj-type
                  and sub_stk-supp-tot.obj-code   = buf_stk-supp-tot.obj-code
                  and sub_stk-supp-tot.cli-type   = buf_stk-supp-tot.cli-type
                  and sub_stk-supp-tot.cli-code   = buf_stk-supp-tot.cli-code
                  and sub_stk-supp-tot.fact-order = buf_stk-supp-tot.fact-order
                  and sub_stk-supp-tot.sum-type   = sub_temp-stk-supp-tot.sum-type
                  and sub_stk-supp-tot.cat-id     = sub_temp-stk-supp-tot.cat-id
                no-error .
              if not available sub_stk-supp-tot
              then do:
                create sub_stk-supp-tot .
                assign
                  sub_stk-supp-tot.obj-type   = buf_stk-supp-tot.obj-type
                  sub_stk-supp-tot.obj-code   = buf_stk-supp-tot.obj-code
                  sub_stk-supp-tot.cli-type   = buf_stk-supp-tot.cli-type
                  sub_stk-supp-tot.cli-code   = buf_stk-supp-tot.cli-code
                  sub_stk-supp-tot.fact-order = buf_stk-supp-tot.fact-order
                  sub_stk-supp-tot.sum-type   = sub_temp-stk-supp-tot.sum-type
                  sub_stk-supp-tot.cat-id     = sub_temp-stk-supp-tot.cat-id
                  sub_stk-supp-tot.fact-date  = buf_stk-supp-tot.fact-date
                  sub_stk-supp-tot.shift-num  = buf_stk-supp-tot.shift-num
                  sub_stk-supp-tot.shift-date = buf_stk-supp-tot.shift-date
                .
              end.
              assign
                &scop fq1    sub_stk-supp-tot.
                &scop fqs1
                &scop fq2    = sub_stk-supp-tot.
                &scop fqs2
                &scop fq3    + sub_temp-stk-supp-tot.
                &scop fqs3
                &scop fq4    - sub_temp-stk-supp-tot.new-
                &scop fqs4
                &scop fq5
                &scop fq6
                {&price-quadro-list}
              .
            end.
          end.
        end.
      end.
    end.

    if p-shift-on = true
    then do:
      for each buf_temp-shift-stk-supp-tot
        where buf_temp-shift-stk-supp-tot.obj-type = p-obj-type
          and buf_temp-shift-stk-supp-tot.obj-code = p-obj-code
          and buf_temp-shift-stk-supp-tot.cli-type = p-cli-type
          and buf_temp-shift-stk-supp-tot.cli-code = p-cli-code
          and buf_temp-shift-stk-supp-tot.sum-type = p-sum-type
      on error undo, return error return-value
      :
        if
        &scop fp1   buf_temp-shift-stk-supp-tot.
        &scop fps1
        &scop fp2   <> buf_temp-shift-stk-supp-tot.new-
        &scop fps2
        &scop fp3
        &scop fp4   or
        {&price-pair-list}
        then do:
          /* ищем первоначальную корневую запись */
          /* если ее нет, то создаем ее */
          find first buf_stk-supp-tot exclusive-lock
            where buf_stk-supp-tot.obj-type   = buf_temp-shift-stk-supp-tot.obj-type
              and buf_stk-supp-tot.obj-code   = buf_temp-shift-stk-supp-tot.obj-code
              and buf_stk-supp-tot.cli-type   = buf_temp-shift-stk-supp-tot.cli-type
              and buf_stk-supp-tot.cli-code   = buf_temp-shift-stk-supp-tot.cli-code
              and buf_stk-supp-tot.sum-type   = buf_temp-shift-stk-supp-tot.sum-type
              and buf_stk-supp-tot.cat-id     = buf_temp-shift-stk-supp-tot.cat-id
              and buf_stk-supp-tot.fact-order <= p-first-shift-end-fact-order
              and buf_stk-supp-tot.shift-date <> ?
            no-error .
          if not available buf_stk-supp-tot
          then do:
            create buf_stk-supp-tot .
            assign
              buf_stk-supp-tot.obj-type   = buf_temp-shift-stk-supp-tot.obj-type
              buf_stk-supp-tot.obj-code   = buf_temp-shift-stk-supp-tot.obj-code
              buf_stk-supp-tot.cli-type   = buf_temp-shift-stk-supp-tot.cli-type
              buf_stk-supp-tot.cli-code   = buf_temp-shift-stk-supp-tot.cli-code
              buf_stk-supp-tot.fact-order = p-first-shift-end-fact-order
              buf_stk-supp-tot.sum-type   = buf_temp-shift-stk-supp-tot.sum-type
              buf_stk-supp-tot.cat-id     = buf_temp-shift-stk-supp-tot.cat-id
              buf_stk-supp-tot.fact-date  = p-first-cut-date
              buf_stk-supp-tot.shift-num  = p-first-shift-num
              buf_stk-supp-tot.shift-date = p-first-shift-date
            .
          end.

          for each buf_stk-supp-tot exclusive-lock
            where buf_stk-supp-tot.obj-type   = buf_temp-shift-stk-supp-tot.obj-type
              and buf_stk-supp-tot.obj-code   = buf_temp-shift-stk-supp-tot.obj-code
              and buf_stk-supp-tot.cli-type   = buf_temp-shift-stk-supp-tot.cli-type
              and buf_stk-supp-tot.cli-code   = buf_temp-shift-stk-supp-tot.cli-code
              and buf_stk-supp-tot.sum-type   = buf_temp-shift-stk-supp-tot.sum-type
              and buf_stk-supp-tot.cat-id     = buf_temp-shift-stk-supp-tot.cat-id
              and buf_stk-supp-tot.fact-order <= p-last-shift-end-fact-order - {&arh-delta}
              and buf_stk-supp-tot.shift-date <> ?
          on error undo, return error return-value
          :
            for each sub_temp-shift-stk-supp-tot
              where sub_temp-shift-stk-supp-tot.obj-type   = buf_temp-shift-stk-supp-tot.obj-type
                and sub_temp-shift-stk-supp-tot.obj-code   = buf_temp-shift-stk-supp-tot.obj-code
                and sub_temp-shift-stk-supp-tot.cli-type   = buf_temp-shift-stk-supp-tot.cli-type
                and sub_temp-shift-stk-supp-tot.cli-code   = buf_temp-shift-stk-supp-tot.cli-code
                and sub_temp-shift-stk-supp-tot.fact-order = buf_temp-shift-stk-supp-tot.fact-order
                and sub_temp-shift-stk-supp-tot.sum-type   begins buf_temp-shift-stk-supp-tot.sum-type
            on error undo, return error return-value
            :
              if
              &scop fp1   sub_temp-shift-stk-supp-tot.
              &scop fps1
              &scop fp2   <> sub_temp-shift-stk-supp-tot.new-
              &scop fps2
              &scop fp3
              &scop fp4   or
              {&price-pair-list}
              then do:
                find first sub_stk-supp-tot exclusive-lock
                  where sub_stk-supp-tot.obj-type   = buf_stk-supp-tot.obj-type
                    and sub_stk-supp-tot.obj-code   = buf_stk-supp-tot.obj-code
                    and sub_stk-supp-tot.cli-type   = buf_stk-supp-tot.cli-type
                    and sub_stk-supp-tot.cli-code   = buf_stk-supp-tot.cli-code
                    and sub_stk-supp-tot.fact-order = buf_stk-supp-tot.fact-order
                    and sub_stk-supp-tot.sum-type   = sub_temp-shift-stk-supp-tot.sum-type
                    and sub_stk-supp-tot.cat-id     = sub_temp-shift-stk-supp-tot.cat-id
                  no-error .
                if not available sub_stk-supp-tot
                then do:
                  create sub_stk-supp-tot .
                  assign
                    sub_stk-supp-tot.obj-type   = buf_stk-supp-tot.obj-type
                    sub_stk-supp-tot.obj-code   = buf_stk-supp-tot.obj-code
                    sub_stk-supp-tot.cli-type   = buf_stk-supp-tot.cli-type
                    sub_stk-supp-tot.cli-code   = buf_stk-supp-tot.cli-code
                    sub_stk-supp-tot.fact-order = buf_stk-supp-tot.fact-order
                    sub_stk-supp-tot.sum-type   = sub_temp-shift-stk-supp-tot.sum-type
                    sub_stk-supp-tot.cat-id     = sub_temp-shift-stk-supp-tot.cat-id
                    sub_stk-supp-tot.fact-date  = buf_stk-supp-tot.fact-date
                    sub_stk-supp-tot.shift-num  = buf_stk-supp-tot.shift-num
                    sub_stk-supp-tot.shift-date = buf_stk-supp-tot.shift-date
                  .
                end.
                assign
                  &scop fq1    sub_stk-supp-tot.
                  &scop fqs1
                  &scop fq2    = sub_stk-supp-tot.
                  &scop fqs2
                  &scop fq3    + sub_temp-shift-stk-supp-tot.
                  &scop fqs3
                  &scop fq4    - sub_temp-shift-stk-supp-tot.new-
                  &scop fqs4
                  &scop fq5
                  &scop fq6
                  {&price-quadro-list}
                .
              end.
            end.
          end.
        end.
      end.
    end.
  end.

end procedure. /* ahrstutl-store-supp-tot */


procedure ahrstutl-store-supp-line :

  define input  parameter p-obj-type                   as character no-undo .
  define input  parameter p-obj-code                   as integer   no-undo .
  define input  parameter p-cli-type                   as character no-undo .
  define input  parameter p-cli-code                   as integer   no-undo .
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


  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-shift-stk-supp-line for temp-shift-stk-supp-line .
  define buffer sub_temp-stk-supp-line for temp-stk-supp-line .
  define buffer sub_stk-supp-line for ub.stk-supp-line .
  define buffer sub_temp-shift-stk-supp-line for temp-shift-stk-supp-line .

  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-supp-line
      where buf_temp-stk-supp-line.obj-type   = p-obj-type
        and buf_temp-stk-supp-line.obj-code   = p-obj-code
        and buf_temp-stk-supp-line.cli-type   = p-cli-type
        and buf_temp-stk-supp-line.cli-code   = p-cli-code
        and buf_temp-stk-supp-line.artic      = p-artic
        and buf_temp-stk-supp-line.prod-type  = p-prod-type
        and buf_temp-stk-supp-line.prod-code  = p-prod-code
        and buf_temp-stk-supp-line.sum-type   = p-sum-type
    on error undo, return error return-value
    :
      if
      &scop fp1   buf_temp-stk-supp-line.
      &scop fps1
      &scop fp2   <> buf_temp-stk-supp-line.new-
      &scop fps2
      &scop fp3
      &scop fp4   or
      {&price-pair-list}
      then do:
        /* ищем первоначальную корневую запись */
        /* если ее нет, то создаем ее */
        find first buf_stk-supp-line exclusive-lock
          where buf_stk-supp-line.obj-type   = buf_temp-stk-supp-line.obj-type
            and buf_stk-supp-line.obj-code   = buf_temp-stk-supp-line.obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-stk-supp-line.cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-stk-supp-line.cli-code
            and buf_stk-supp-line.artic      = buf_temp-stk-supp-line.artic
            and buf_stk-supp-line.prod-type  = buf_temp-stk-supp-line.prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-stk-supp-line.prod-code
            and buf_stk-supp-line.sum-type   = buf_temp-stk-supp-line.sum-type
            and buf_stk-supp-line.cat-id     = buf_temp-stk-supp-line.cat-id
            and buf_stk-supp-line.fact-order <= p-first-day-end-fact-order
            and buf_stk-supp-line.shift-date = ?
          no-error .
        if not available buf_stk-supp-line
        then do:
          create buf_stk-supp-line .
          assign
            buf_stk-supp-line.obj-type   = buf_temp-stk-supp-line.obj-type
            buf_stk-supp-line.obj-code   = buf_temp-stk-supp-line.obj-code
            buf_stk-supp-line.cli-type   = buf_temp-stk-supp-line.cli-type
            buf_stk-supp-line.cli-code   = buf_temp-stk-supp-line.cli-code
            buf_stk-supp-line.artic      = buf_temp-stk-supp-line.artic
            buf_stk-supp-line.prod-type  = buf_temp-stk-supp-line.prod-type
            buf_stk-supp-line.prod-code  = buf_temp-stk-supp-line.prod-code
            buf_stk-supp-line.fact-order = p-first-day-end-fact-order
            buf_stk-supp-line.sum-type   = buf_temp-stk-supp-line.sum-type
            buf_stk-supp-line.cat-id     = buf_temp-stk-supp-line.cat-id
            buf_stk-supp-line.fact-date  = p-first-cut-date
            buf_stk-supp-line.shift-num  = 0
            buf_stk-supp-line.shift-date = ?
          .
        end.

        for each buf_stk-supp-line exclusive-lock
          where buf_stk-supp-line.obj-type   = buf_temp-stk-supp-line.obj-type
            and buf_stk-supp-line.obj-code   = buf_temp-stk-supp-line.obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-stk-supp-line.cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-stk-supp-line.cli-code
            and buf_stk-supp-line.artic      = buf_temp-stk-supp-line.artic
            and buf_stk-supp-line.prod-type  = buf_temp-stk-supp-line.prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-stk-supp-line.prod-code
            and buf_stk-supp-line.sum-type   = buf_temp-stk-supp-line.sum-type
            and buf_stk-supp-line.cat-id     = buf_temp-stk-supp-line.cat-id
            and buf_stk-supp-line.fact-order <= p-last-day-end-fact-order - {&arh-delta}
            and buf_stk-supp-line.shift-date = ?
        on error undo, return error return-value
        :

          for each sub_temp-stk-supp-line
            where sub_temp-stk-supp-line.obj-type   = buf_temp-stk-supp-line.obj-type
              and sub_temp-stk-supp-line.obj-code   = buf_temp-stk-supp-line.obj-code
              and sub_temp-stk-supp-line.cli-type   = buf_temp-stk-supp-line.cli-type
              and sub_temp-stk-supp-line.cli-code   = buf_temp-stk-supp-line.cli-code
              and sub_temp-stk-supp-line.artic      = buf_temp-stk-supp-line.artic
              and sub_temp-stk-supp-line.prod-type  = buf_temp-stk-supp-line.prod-type
              and sub_temp-stk-supp-line.prod-code  = buf_temp-stk-supp-line.prod-code
              and sub_temp-stk-supp-line.fact-order = buf_temp-stk-supp-line.fact-order
              and sub_temp-stk-supp-line.sum-type   begins buf_temp-stk-supp-line.sum-type
          on error undo, return error return-value
          :
            if
            &scop fp1   sub_temp-stk-supp-line.
            &scop fps1
            &scop fp2   <> sub_temp-stk-supp-line.new-
            &scop fps2
            &scop fp3
            &scop fp4   or
            {&price-pair-list}
            then do:
              find first sub_stk-supp-line exclusive-lock
                where sub_stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
                  and sub_stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
                  and sub_stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
                  and sub_stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
                  and sub_stk-supp-line.artic      = buf_stk-supp-line.artic
                  and sub_stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
                  and sub_stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
                  and sub_stk-supp-line.fact-order = buf_stk-supp-line.fact-order
                  and sub_stk-supp-line.sum-type   = sub_temp-stk-supp-line.sum-type
                  and sub_stk-supp-line.cat-id     = sub_temp-stk-supp-line.cat-id
                no-error .
              if not available sub_stk-supp-line
              then do:
                create sub_stk-supp-line .
                assign
                  sub_stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
                  sub_stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
                  sub_stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
                  sub_stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
                  sub_stk-supp-line.artic      = buf_stk-supp-line.artic
                  sub_stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
                  sub_stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
                  sub_stk-supp-line.fact-order = buf_stk-supp-line.fact-order
                  sub_stk-supp-line.sum-type   = sub_temp-stk-supp-line.sum-type
                  sub_stk-supp-line.cat-id     = sub_temp-stk-supp-line.cat-id
                  sub_stk-supp-line.fact-date  = buf_stk-supp-line.fact-date
                  sub_stk-supp-line.shift-num  = buf_stk-supp-line.shift-num
                  sub_stk-supp-line.shift-date = buf_stk-supp-line.shift-date
                .
              end.
              assign
                &scop fq1    sub_stk-supp-line.
                &scop fqs1
                &scop fq2    = sub_stk-supp-line.
                &scop fqs2
                &scop fq3    + sub_temp-stk-supp-line.
                &scop fqs3
                &scop fq4    - sub_temp-stk-supp-line.new-
                &scop fqs4
                &scop fq5
                &scop fq6
                {&price-quadro-list}
              .
            end.
          end.
        end.
      end.
    end.

    if p-shift-on = true
    then do:
      for each buf_temp-shift-stk-supp-line
        where buf_temp-shift-stk-supp-line.obj-type  = p-obj-type
          and buf_temp-shift-stk-supp-line.obj-code  = p-obj-code
          and buf_temp-shift-stk-supp-line.cli-type  = p-cli-type
          and buf_temp-shift-stk-supp-line.cli-code  = p-cli-code
          and buf_temp-shift-stk-supp-line.artic     = p-artic
          and buf_temp-shift-stk-supp-line.prod-type = p-prod-type
          and buf_temp-shift-stk-supp-line.prod-code = p-prod-code
          and buf_temp-shift-stk-supp-line.sum-type  = p-sum-type
      on error undo, return error return-value
      :
        if
        &scop fp1   buf_temp-shift-stk-supp-line.
        &scop fps1
        &scop fp2   <> buf_temp-shift-stk-supp-line.new-
        &scop fps2
        &scop fp3
        &scop fp4   or
        {&price-pair-list}
        then do:
          /* ищем первоначальную корневую запись */
          /* если ее нет, то создаем ее */
          find first buf_stk-supp-line exclusive-lock
            where buf_stk-supp-line.obj-type   = buf_temp-shift-stk-supp-line.obj-type
              and buf_stk-supp-line.obj-code   = buf_temp-shift-stk-supp-line.obj-code
              and buf_stk-supp-line.cli-type   = buf_temp-shift-stk-supp-line.cli-type
              and buf_stk-supp-line.cli-code   = buf_temp-shift-stk-supp-line.cli-code
              and buf_stk-supp-line.artic      = buf_temp-shift-stk-supp-line.artic
              and buf_stk-supp-line.prod-type  = buf_temp-shift-stk-supp-line.prod-type
              and buf_stk-supp-line.prod-code  = buf_temp-shift-stk-supp-line.prod-code
              and buf_stk-supp-line.sum-type   = buf_temp-shift-stk-supp-line.sum-type
              and buf_stk-supp-line.cat-id     = buf_temp-shift-stk-supp-line.cat-id
              and buf_stk-supp-line.fact-order <= p-first-shift-end-fact-order
              and buf_stk-supp-line.shift-date <> ?
            no-error .
          if not available buf_stk-supp-line
          then do:
            create buf_stk-supp-line .
            assign
              buf_stk-supp-line.obj-type   = buf_temp-shift-stk-supp-line.obj-type
              buf_stk-supp-line.obj-code   = buf_temp-shift-stk-supp-line.obj-code
              buf_stk-supp-line.cli-type   = buf_temp-shift-stk-supp-line.cli-type
              buf_stk-supp-line.cli-code   = buf_temp-shift-stk-supp-line.cli-code
              buf_stk-supp-line.artic      = buf_temp-shift-stk-supp-line.artic
              buf_stk-supp-line.prod-type  = buf_temp-shift-stk-supp-line.prod-type
              buf_stk-supp-line.prod-code  = buf_temp-shift-stk-supp-line.prod-code
              buf_stk-supp-line.fact-order = p-first-shift-end-fact-order
              buf_stk-supp-line.sum-type   = buf_temp-shift-stk-supp-line.sum-type
              buf_stk-supp-line.cat-id     = buf_temp-shift-stk-supp-line.cat-id
              buf_stk-supp-line.fact-date  = p-first-cut-date
              buf_stk-supp-line.shift-num  = p-first-shift-num
              buf_stk-supp-line.shift-date = p-first-shift-date
            .
          end.

          for each buf_stk-supp-line exclusive-lock
            where buf_stk-supp-line.obj-type   = buf_temp-shift-stk-supp-line.obj-type
              and buf_stk-supp-line.obj-code   = buf_temp-shift-stk-supp-line.obj-code
              and buf_stk-supp-line.cli-type   = buf_temp-shift-stk-supp-line.cli-type
              and buf_stk-supp-line.cli-code   = buf_temp-shift-stk-supp-line.cli-code
              and buf_stk-supp-line.artic      = buf_temp-shift-stk-supp-line.artic
              and buf_stk-supp-line.prod-type  = buf_temp-shift-stk-supp-line.prod-type
              and buf_stk-supp-line.prod-code  = buf_temp-shift-stk-supp-line.prod-code
              and buf_stk-supp-line.sum-type   = buf_temp-shift-stk-supp-line.sum-type
              and buf_stk-supp-line.cat-id     = buf_temp-shift-stk-supp-line.cat-id
              and buf_stk-supp-line.fact-order <= p-last-shift-end-fact-order - {&arh-delta}
              and buf_stk-supp-line.shift-date <> ?
          on error undo, return error return-value
          :

            for each sub_temp-shift-stk-supp-line
              where sub_temp-shift-stk-supp-line.obj-type   = buf_temp-shift-stk-supp-line.obj-type
                and sub_temp-shift-stk-supp-line.obj-code   = buf_temp-shift-stk-supp-line.obj-code
                and sub_temp-shift-stk-supp-line.cli-type   = buf_temp-shift-stk-supp-line.cli-type
                and sub_temp-shift-stk-supp-line.cli-code   = buf_temp-shift-stk-supp-line.cli-code
                and sub_temp-shift-stk-supp-line.artic      = buf_temp-shift-stk-supp-line.artic
                and sub_temp-shift-stk-supp-line.prod-type  = buf_temp-shift-stk-supp-line.prod-type
                and sub_temp-shift-stk-supp-line.prod-code  = buf_temp-shift-stk-supp-line.prod-code
                and sub_temp-shift-stk-supp-line.fact-order = buf_temp-shift-stk-supp-line.fact-order
                and sub_temp-shift-stk-supp-line.sum-type   begins buf_temp-shift-stk-supp-line.sum-type
            on error undo, return error return-value
            :
              if
              &scop fp1   sub_temp-shift-stk-supp-line.
              &scop fps1
              &scop fp2   <> sub_temp-shift-stk-supp-line.new-
              &scop fps2
              &scop fp3
              &scop fp4   or
              {&price-pair-list}
              then do:
                find first sub_stk-supp-line exclusive-lock
                  where sub_stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
                    and sub_stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
                    and sub_stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
                    and sub_stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
                    and sub_stk-supp-line.artic      = buf_stk-supp-line.artic
                    and sub_stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
                    and sub_stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
                    and sub_stk-supp-line.fact-order = buf_stk-supp-line.fact-order
                    and sub_stk-supp-line.sum-type   = sub_temp-shift-stk-supp-line.sum-type
                    and sub_stk-supp-line.cat-id     = sub_temp-shift-stk-supp-line.cat-id
                  no-error .
                if not available sub_stk-supp-line
                then do:
                  create sub_stk-supp-line .
                  assign
                    sub_stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
                    sub_stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
                    sub_stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
                    sub_stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
                    sub_stk-supp-line.artic      = buf_stk-supp-line.artic
                    sub_stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
                    sub_stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
                    sub_stk-supp-line.fact-order = buf_stk-supp-line.fact-order
                    sub_stk-supp-line.sum-type   = sub_temp-shift-stk-supp-line.sum-type
                    sub_stk-supp-line.cat-id     = sub_temp-shift-stk-supp-line.cat-id
                    sub_stk-supp-line.fact-date  = buf_stk-supp-line.fact-date
                    sub_stk-supp-line.shift-num  = buf_stk-supp-line.shift-num
                    sub_stk-supp-line.shift-date = buf_stk-supp-line.shift-date
                  .
                end.
                assign
                  &scop fq1    sub_stk-supp-line.
                  &scop fqs1
                  &scop fq2    = sub_stk-supp-line.
                  &scop fqs2
                  &scop fq3    + sub_temp-shift-stk-supp-line.
                  &scop fqs3
                  &scop fq4    - sub_temp-shift-stk-supp-line.new-
                  &scop fqs4
                  &scop fq5
                  &scop fq6
                  {&price-quadro-list}
                .
              end.
            end.
          end.
        end.
      end.
    end.
  end.
end procedure. /* ahrstutl-store-supp-line */


procedure cb_rst-ahsp_overturn-exist :

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

procedure cb_rst-ahsp_get-temp-supp-gds :

  define input  parameter p-callback-handle as handle    no-undo .
  define input  parameter p-procedure-name  as character no-undo .

  define buffer buf_temp-supp-gds for temp-supp-gds .

  do
  on error undo, return error return-value
  :
    for each buf_temp-supp-gds
    on error undo, return error return-value
    :
      run value(p-procedure-name) in p-callback-handle
        (input  buf_temp-supp-gds.cli-type
        ,input  buf_temp-supp-gds.cli-code
        ,input  buf_temp-supp-gds.artic
        ,input  buf_temp-supp-gds.prod-type
        ,input  buf_temp-supp-gds.prod-code
        ) .
    end.
  end.

end procedure. /* cb_rst-ahsp_process-temp-supp-gds */


procedure rst-ahsp-init-clients :

  define buffer buf_doclslib-clients for doclslib-clients .
  define buffer buf_doclslib-clients-goods for doclslib-clients-goods .

  do
  on error undo, return error return-value
  :

    for each buf_doclslib-clients
    on error undo, return error return-value
    :
      delete buf_doclslib-clients .
    end.

    for each buf_doclslib-clients-goods
    on error undo, return error return-value
    :
      find first buf_doclslib-clients
        where buf_doclslib-clients.cli-type = buf_doclslib-clients-goods.cli-type
          and buf_doclslib-clients.cli-code = buf_doclslib-clients-goods.cli-code
        no-error .
      if not available buf_doclslib-clients
      then do:
        create buf_doclslib-clients .
        assign
          buf_doclslib-clients.cli-type = buf_doclslib-clients-goods.cli-type
          buf_doclslib-clients.cli-code = buf_doclslib-clients-goods.cli-code
        .
      end.
    end.
  end.
end procedure. /* rst-ahsp-init-clients */


procedure rst-ahsp-init-clients-goods :

  define buffer buf_doclslib-clients-goods for doclslib-clients-goods .
  define buffer buf_doc-list       for doc-list .
  define buffer buf_parts          for ub.parts .

  define variable v-gds-code as integer   no-undo .

  do
  on error undo, return error return-value
  :

    for each buf_doclslib-clients-goods
    on error undo, return error return-value
    :
      delete buf_doclslib-clients-goods .
    end.

    for each buf_doc-list
    on error undo, return error return-value
    :
      for each buf_parts no-lock
        where buf_parts.out-code = buf_doc-list.doc-code
      on error undo, return error return-value
      :
        { gbl/gds-code.i
          buf_parts.artic
          buf_parts.prod-type
          buf_parts.prod-code
          v-gds-code
        }

        find first buf_doclslib-clients-goods
          where buf_doclslib-clients-goods.cli-type  = buf_parts.supp-type
            and buf_doclslib-clients-goods.cli-code  = buf_parts.supp-code
            and buf_doclslib-clients-goods.artic     = buf_parts.artic
            and buf_doclslib-clients-goods.prod-type = buf_parts.prod-type
            and buf_doclslib-clients-goods.prod-code = buf_parts.prod-code
          no-error .
        if not available buf_doclslib-clients-goods
        then do:
          create buf_doclslib-clients-goods .
          assign
            buf_doclslib-clients-goods.cli-type  = buf_parts.supp-type
            buf_doclslib-clients-goods.cli-code  = buf_parts.supp-code
            buf_doclslib-clients-goods.artic     = buf_parts.artic
            buf_doclslib-clients-goods.prod-type = buf_parts.prod-type
            buf_doclslib-clients-goods.prod-code = buf_parts.prod-code
          .
        end.
      end.
    end.
  end.

end procedure. /* rst-ahsp-init-clients-goods */


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
        "Складской архив по поставщикам" skip
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
        "Складской архив по поставщикам" skip
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