block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись code-range

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/97
Author: Dmitry Ukhanov
Creation date: 03/22/97

*/

TRIGGER PROCEDURE FOR WRITE OF ub.code-range old buffer old_code-range .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись диапазонов кодов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

define buffer buf_code-range for ub.code-range .

define variable v-code-range-type-list  as character no-undo .
define variable v-analogous-type        as character no-undo .
define variable ind                     as integer   no-undo .
define variable v-code-range-stts-list  as character no-undo init "f,a,u,c,l,X->0" .
define variable l-need-send-to-news     as logical   no-undo init false .
define variable l-record-the-same       as logical   no-undo .
define variable v-is-scgb               as logical   no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  assign
    v-code-range-type-list = {&gbl-bc-code} + {&comma-char}
                             + {&loc-sc-code} + {&comma-char}
                             + {&gbl-sc-code} + {&comma-char}
                             + {&loc-pg-code} + {&comma-char}
                             + {&loc-ss-code} + {&comma-char}
                             + {&gbl-ss-code} + {&comma-char}
                             + {&loc-pt-code} + {&comma-char}
                             + {&gbl-dc-code} + {&comma-char}
                             + {&gbl-dr-code} + {&comma-char}
                             + {&gbl-ct-code} + {&comma-char}
                             + {&gbl-fm-code} + {&comma-char}
                             + {&gbl-pn-code} + {&comma-char}
                             + {&gbl-ca-code} + {&comma-char}
                             + {&gbl-fd-code}

  .
  if lookup( ub.code-range.range-type, {&grp-bcode} ) <> 0 then do:
    assign
      v-analogous-type = {&grp-bcode}
      .
  end.
  else do:
    assign
      v-analogous-type = ub.code-range.range-type
      .
  end.

  assign
    l-need-send-to-news = false
  .

  if new ub.code-range
    and g#db-num <> 0 
    and ub.code-range.range-type <> {&gbl-ca-code}
    and g#news   <> true
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Создание новых диапазонов кодов допустимо только в БД 0!" skip
      view-as alert-box.
    undo main-block, return error .
  end.

  if new ub.code-range
    and g#db-num = 0
    and ub.code-range.range-type = {&gbl-sc-code}
  then do:
    { gbl/getsect.i def "''" 0 {&attr-gds-ref} }
    { gbl/getsect.i run "''" 0 {&attr-gds-ref} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = {&attr-gds-ref_is-scgb} then v-is-scgb = thbjattr_thbj-attr.property-value-logical .
    end.
    if v-is-scgb <> true then do:
      message
        vss-workfile vss-revision vss-description skip
        "Создание диапазонов глобальных весовых кодов запрещено (is-scgb)!" skip
        "Изменить этот параметр можно в Администратор-Глобальные настройки" skip
        view-as alert-box.
      undo main-block, return error .
    end.
  end.

  /* запрещаем изменение любых полей, кроме статуса */
  if not new ub.code-range then do:
    if ub.code-range.stts = "c":U then do:
      /* при статусе "c" возможны изменения любых полей кроме полей */
      /* перивичного уникального ключа (range-type first-code) */
      if ub.code-range.range-type <> old_code-range.range-type
        or ub.code-range.first-code <> old_code-range.first-code
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Нельзя менять значения типа и(или) начала диапазона" skip
          "новый range-type" ub.code-range.range-type skip
          "новый first-code" ub.code-range.first-code skip
          "старый range-type" old_code-range.range-type skip
          "старый first-code" old_code-range.first-code skip
          view-as alert-box .
        undo main-block, return error .
      end.
    end.
    else do:
      /* это происходит изменение записи */
      /* в этом случае возможно только менять статус */
      buffer-compare
      ub.code-range
      except ub.code-range.db-num ub.code-range.stts ub.code-range.PS ub.code-range.beg-date
      to old_code-range
      save result in l-record-the-same .

      if l-record-the-same <> true then do:
        message
          vss-workfile vss-revision vss-description skip
          "Для диапазона бар-кодов возможно только изменение статуса" skip
          "Или смена номера базы данных с -1 на номер реальной базы данных"
          "db-num"     ub.code-range.db-num     skip
          "stts"       ub.code-range.stts       skip
          "range-type" ub.code-range.range-type skip
          "first-code" ub.code-range.first-code skip
          "last-code"  ub.code-range.last-code  skip
          view-as alert-box .
        undo main-block, return error .
      end.

      if ub.code-range.db-num <> old_code-range.db-num then do:
        if old_code-range.db-num = -1
          or ( ub.code-range.db-num = 0
               and ub.code-range.stts = "X->0":U  /* для перепривязки диапазонов из любой БД в ГБД */
             )
        then do:
          /* часть диапазонов создается с номером базы данных -1 */
          /* это диапазоны, которые могут быть присвоены любой базе данных */
          /* при присваивании к какой-либо из баз данных информация должна быть */
          /* смаршрутизирована в новости */
          /* при смене номера привязки к БД тоже надо отправить в новости */
          assign
            l-need-send-to-news = true
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Для диапазона бар-кодов возможно только изменение статуса" skip
            "Смена номера базы данных допустима только если предыдущий номер БД был -1" skip
            "База данных"   ub.code-range.db-num skip
            "Тип диапазона" ub.code-range.range-type skip
            "Статус"        ub.code-range.stts skip
            "Диапазон"      ub.code-range.first-code  ":" ub.code-range.last-code  skip
            view-as alert-box .
          undo main-block, return error .
        end.
      end.
      if old_code-range.stts = "X->0":U
      then do:
        assign
          l-need-send-to-news = true
        .
      end.
    end.
  end.
  else do:
    /* автоматически заполняем дату создания диапазона */
    if not g#news then do:
      assign
        ub.code-range.beg-date = today
      .
    end.
    if ub.code-range.db-num <> -1 and ub.code-range.stts = "f" then do:
      /* часть диапазонов создается с номером базы данных -1 */
      /* это диапазоны, которые могут быть присвоены любой базе данных */
      /* при создании диапазонов, они должны быть отправлены в новости, */
      /* если они уже привязаны к реальной базе данных */
      assign
        l-need-send-to-news = true
      .
    end.
  end.

  if ub.code-range.db-num <> -1 then do:
    /* Для диапазонов, которые не привязаны к какой-либо базе данных
       ("свободные диапазоны") номер базы данных должен равняться -1
     */
    find first ub.db no-lock
      where ub.db.db-num = ub.code-range.db-num
      no-error .
    if not available ub.db then do:
      message
        vss-workfile vss-revision vss-description skip
        "Диапазон бар-кодов, ссылка на несуществующую базу данных." skip
        "База данных"   ub.code-range.db-num skip
        "Тип диапазона" ub.code-range.range-type skip
        "Статус"        ub.code-range.stts skip
        "Диапазон"      ub.code-range.first-code  ":" ub.code-range.last-code  skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end.


  if lookup(ub.code-range.range-type, v-code-range-type-list) = 0 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Диапазон бар-кодов, неизвестный тип диапазона" skip
      "База данных"   ub.code-range.db-num skip
      "Тип диапазона" ub.code-range.range-type skip
      "Статус"        ub.code-range.stts skip
      "Диапазон"      ub.code-range.first-code  ":" ub.code-range.last-code  skip
      view-as alert-box .
    undo main-block, return error .
  end.

  if length(ub.code-range.range-type) > 4 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Длина типа диапазона бар-кодов не может превышать 4 символа" skip
      "База данных"   ub.code-range.db-num skip
      "Тип диапазона" ub.code-range.range-type skip
      "Статус"        ub.code-range.stts skip
      "Диапазон"      ub.code-range.first-code  ":" ub.code-range.last-code  skip
      view-as alert-box .
    undo main-block, return error .
  end.

  if lookup(ub.code-range.stts, v-code-range-stts-list ) = 0 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Диапазон бар-кодов, неизвестный статус" skip
      "База данных"   ub.code-range.db-num skip
      "Тип диапазона" ub.code-range.range-type skip
      "Статус"        ub.code-range.stts skip
      "Диапазон"      ub.code-range.first-code  ":" ub.code-range.last-code  skip
      view-as alert-box .
    undo main-block, return error .
  end.

  if not new ub.code-range
    and old_code-range.stts <> ub.code-range.stts
    and old_code-range.db-num <> -1
    and ub.code-range.stts <> "c":U
    and old_code-range.stts <> "c":U
    and ub.code-range.stts <> "X->0":U
    and old_code-range.stts <> "X->0":U
  then do:
    /* проверяется граф переходов статуса */
    /* запись создается со статусом f (free) */
    /* далее переводится в состояниее a (active) */
    /* окончательно переводится в состояниее u (used) */
    if  (ub.code-range.stts = "a":U and old_code-range.stts = "f":U)
    or  (ub.code-range.stts = "u":U and old_code-range.stts = "a":U)
    or  (ub.code-range.stts = "u":U and old_code-range.stts = "f":U)
    then do:
      /* это правильная смена статуса */
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Диапазон бар-кодов - неправильная смена статуса" skip
        "База данных"   ub.code-range.db-num skip
        "Тип диапазона" ub.code-range.range-type skip
        "Статус"        ub.code-range.stts skip
        "Диапазон"      ub.code-range.first-code  ":" ub.code-range.last-code  skip
        "Предыдущий статус" old_code-range.stts skip
        view-as alert-box .
      undo main-block, return error .
    end.
  end.

  if ub.code-range.stts = "a" and ub.code-range.db-num = g#db-num then do:
  /* только для своей БД */
    find first buf_code-range
      where buf_code-range.db-num     = ub.code-range.db-num
        and buf_code-range.range-type = ub.code-range.range-type
        and buf_code-range.stts       = ub.code-range.stts
        and recid(buf_code-range)     <> recid(ub.code-range)
      no-error .
    if available buf_code-range then do:
      message
        vss-workfile vss-revision vss-description skip
        "Для базы данных и типа может быть только один активный диапазон" skip
        "Изменение статуса диапазона" skip
        "База данных"   ub.code-range.db-num skip
        "Тип диапазона" ub.code-range.range-type skip
        "Статус"        ub.code-range.stts skip
        "Диапазон"      ub.code-range.first-code  ":" ub.code-range.last-code  skip
        "Существующий диапазон" skip
        "База данных"   buf_code-range.db-num skip
        "Тип диапазона" buf_code-range.range-type skip
        "Статус"        buf_code-range.stts skip
        "Диапазон"      buf_code-range.first-code  ":" buf_code-range.last-code  skip
        view-as alert-box .
      undo main-block, return error .
    end.
  end.

  if ub.code-range.first-code = ?
  or ub.code-range.first-code <= 0 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Диапазон бар-кодов, начальное значение неопределено или отрицательно" skip
      "База данных"   ub.code-range.db-num skip
      "Тип диапазона" ub.code-range.range-type skip
      "Статус"        ub.code-range.stts skip
      "Диапазон"      ub.code-range.first-code  ":" ub.code-range.last-code  skip
      view-as alert-box .
    undo main-block, return error .
  end.

  if ub.code-range.last-code = ?
  or ub.code-range.last-code <= 0 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Диапазон бар-кодов, конечное значение неопределено или отрицательно" skip
      "База данных"   ub.code-range.db-num skip
      "Тип диапазона" ub.code-range.range-type skip
      "Статус"        ub.code-range.stts skip
      "Диапазон"      ub.code-range.first-code  ":" ub.code-range.last-code  skip
      view-as alert-box .
    undo main-block, return error .
  end.

  if ub.code-range.first-code >= ub.code-range.last-code then do:
    message
      vss-workfile vss-revision vss-description skip
      "Диапазон бар-кодов, начальное значение превышает или равно конечному значению" skip
      "База данных"   ub.code-range.db-num skip
      "Тип диапазона" ub.code-range.range-type skip
      "Статус"        ub.code-range.stts skip
      "Диапазон"      ub.code-range.first-code  ":" ub.code-range.last-code  skip
      view-as alert-box .
    undo main-block, return error .
  end.

  case ub.code-range.range-type :
    when {&gbl-bc-code} then do:
      if ub.code-range.first-code < 1 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Начало диапазона собственных кодов должно быть не меньше 100000" skip
          "db-num"     ub.code-range.db-num     skip
          "stts"       ub.code-range.stts       skip
          "range-type" ub.code-range.range-type skip
          "first-code" ub.code-range.first-code skip
          "last-code"  ub.code-range.last-code  skip
          view-as alert-box .
        undo main-block, return error .
      end.
    end.
    when {&gbl-sc-code}
    or when {&loc-sc-code}
    or when {&loc-pg-code}
    then do:
      if ub.code-range.first-code < 100
         or ub.code-range.last-code > 99999 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Диапазон весовых кодов штучных кодов для весов может быть в пределах от 100 до 99999 включительно" skip
          "db-num"     ub.code-range.db-num     skip
          "stts"       ub.code-range.stts       skip
          "range-type" ub.code-range.range-type skip
          "first-code" ub.code-range.first-code skip
          "last-code"  ub.code-range.last-code  skip
          view-as alert-box .
        undo main-block, return error .
      end.
    end.
    when {&loc-pt-code} then do:
      if ub.code-range.last-code > 99 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Диапазон топливных кодов может быть в пределах от 1 до 99 включительно" skip
          "db-num"     ub.code-range.db-num     skip
          "stts"       ub.code-range.stts       skip
          "range-type" ub.code-range.range-type skip
          "first-code" ub.code-range.first-code skip
          "last-code"  ub.code-range.last-code  skip
          view-as alert-box .
        undo main-block, return error .
      end.
    end.
  end case.

  define variable v-check-type as character no-undo .

  do ind = 1 to num-entries( v-analogous-type ) :
    assign
      v-check-type = entry( ind, v-analogous-type )
    .

    for each buf_code-range
      where buf_code-range.first-code >= ub.code-range.first-code
        and buf_code-range.first-code <= ub.code-range.last-code
        and buf_code-range.range-type = v-check-type
        and recid(buf_code-range) <> recid(ub.code-range)
    on error undo main-block, return error
    :
      message
        vss-workfile vss-revision vss-description skip
        "Существует диапазон бар-кодов, который пересекается с создаваемым диапазоном" skip
        "База данных"   ub.code-range.db-num skip
        "Тип диапазона" ub.code-range.range-type skip
        "Статус"        ub.code-range.stts skip
        "Диапазон"      ub.code-range.first-code  ":" ub.code-range.last-code  skip
        "Существует диапазон:" buf_code-range.first-code ":" buf_code-range.last-code skip
        "Тип диапазона" buf_code-range.range-type skip
        view-as alert-box .
      undo main-block, return error .
    end.

    for each buf_code-range
      where buf_code-range.last-code >= ub.code-range.first-code
        and buf_code-range.last-code <= ub.code-range.last-code
        and buf_code-range.range-type = v-check-type
        and recid(buf_code-range) <> recid(ub.code-range)
    on error undo main-block, return error
    :
      message
        vss-workfile vss-revision vss-description skip
        "Существует диапазон бар-кодов, который пересекается с создаваемым диапазоном" skip
        "База данных"   ub.code-range.db-num skip
        "Тип диапазона" ub.code-range.range-type skip
        "Статус"        ub.code-range.stts skip
        "Диапазон"      ub.code-range.first-code  ":" ub.code-range.last-code  skip
        "Существует диапазон:" buf_code-range.first-code ":" buf_code-range.last-code skip
        "Тип диапазона" buf_code-range.range-type skip
        view-as alert-box .
      undo main-block, return error .
    end.

    for each buf_code-range
      where buf_code-range.last-code  >= ub.code-range.first-code
        and buf_code-range.first-code <= ub.code-range.first-code
        and buf_code-range.range-type = v-check-type
        and recid(buf_code-range) <> recid(ub.code-range)
    on error undo main-block, return error
    :
      message
        vss-workfile vss-revision vss-description skip
        "Существует диапазон бар-кодов, который пересекается с создаваемым диапазоном" skip
        "База данных"   ub.code-range.db-num skip
        "Тип диапазона" ub.code-range.range-type skip
        "Статус"        ub.code-range.stts skip
        "Диапазон"      ub.code-range.first-code  ":" ub.code-range.last-code  skip
        "Существует диапазон:" buf_code-range.first-code ":" buf_code-range.last-code skip
        "Тип диапазона" buf_code-range.range-type skip
        view-as alert-box .
      undo main-block, return error .
    end.

    for each buf_code-range
      where buf_code-range.last-code  >= ub.code-range.last-code
        and buf_code-range.first-code <= ub.code-range.last-code
        and buf_code-range.range-type = v-check-type
        and recid(buf_code-range) <> recid(ub.code-range)
    on error undo main-block, return error
    :
      message
        vss-workfile vss-revision vss-description skip
        "Существует диапазон бар-кодов, который пересекается с создаваемым диапазоном" skip
        "База данных"   ub.code-range.db-num skip
        "Тип диапазона" ub.code-range.range-type skip
        "Статус"        ub.code-range.stts skip
        "Диапазон"      ub.code-range.first-code  ":" ub.code-range.last-code  skip
        "Существует диапазон:" buf_code-range.first-code ":" buf_code-range.last-code skip
        "Тип диапазона" buf_code-range.range-type skip
        view-as alert-box .
      undo main-block, return error .
    end.
  end. /* do ind = 1... */

  /* маршрутизация для отправки в новости */
  if l-need-send-to-news = true then do:
    /* отправка в новости происходит только один раз   */
    /* тогда, когда запись привязывается к базе данных */
    /* 1. создании с указанным номером базы данных отличным от -1 */
    /* 2. смена номера -1 на номер реальной базы данных */
    run str/callnews.p
      (input "code-range"
      ,input (buffer ub.code-range:handle)
      ).
  end.
  if g#oxml = yes then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_code-range}
        , input ( buffer ub.code-range:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.