block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.code-range old buffer old_code-range .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись диапазонов кодов".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
    v-code-range-type-list = 'bcgb':U + chr(44)
                             + 'sclc':U + chr(44)
                             + 'scgb':U + chr(44)
                             + 'pglc':U + chr(44)
                             + 'sslc':U + chr(44)
                             + 'ssgb':U + chr(44)
                             + 'ptlc':U + chr(44)
                             + 'dcgb':U + chr(44)
                             + 'drgb':U + chr(44)
                             + 'ctgb':U + chr(44)
                             + 'fmgb':U + chr(44)
                             + 'pngb':U + chr(44)
                             + 'cagb':U + chr(44)
                             + 'fdgb':U
  .
  if lookup( ub.code-range.range-type, 'sslc,bcgb,sclc,scgb,ssgb,pglc,ptlc':U ) <> 0 then do:
    assign
      v-analogous-type = 'sslc,bcgb,sclc,scgb,ssgb,pglc,ptlc':U
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
    and ub.code-range.range-type <> 'cagb':U
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
    and ub.code-range.range-type = 'scgb':U
  then do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'gds-ref':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'is-scgb':U then v-is-scgb = thbjattr_thbj-attr.property-value-logical .
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
  if not new ub.code-range then do:
    if ub.code-range.stts = "c":U then do:
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
               and ub.code-range.stts = "X->0":U
             )
        then do:
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
    if not g#news then do:
      assign
        ub.code-range.beg-date = today
      .
    end.
    if ub.code-range.db-num <> -1 and ub.code-range.stts = "f" then do:
      assign
        l-need-send-to-news = true
      .
    end.
  end.
  if ub.code-range.db-num <> -1 then do:
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
    if  (ub.code-range.stts = "a":U and old_code-range.stts = "f":U)
    or  (ub.code-range.stts = "u":U and old_code-range.stts = "a":U)
    or  (ub.code-range.stts = "u":U and old_code-range.stts = "f":U)
    then do:
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
    when 'bcgb':U then do:
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
    when 'scgb':U
    or when 'sclc':U
    or when 'pglc':U
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
    when 'ptlc':U then do:
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
  end.
  if l-need-send-to-news = true then do:
    run str/callnews.p
      (input "code-range"
      ,input (buffer ub.code-range:handle)
      ).
  end.
  if g#oxml = yes then do:
    run str/calloxml.p (
          input 'update':U
        , input 'code-range':U
        , input ( buffer ub.code-range:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.
