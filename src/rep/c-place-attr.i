/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение истории по резервуару и атрибутам

Автор: Шкляр Елена
Дата создания: 05/23/06
Author: Andrew Bulgakoff
Creation date: 05/23/06

*/


procedure c-place_get-attr :
  define input parameter attr-code as character no-undo .
  define input parameter obj-code as integer no-undo .
  define input parameter obj-type as character no-undo .
  define input parameter pl-code as integer no-undo .
  define input parameter endDate as date no-undo .
  define input parameter endTime as integer no-undo .
  define output parameter attr-value as character no-undo .
  
  define buffer bf_c-place-attr for ub.c-place-attr .
  define variable is-place-attr as logical no-undo .
  
  find last bf_c-place-attr no-lock where bf_c-place-attr.pl-code = pl-code and
    bf_c-place-attr.obj-code = obj-code and
    bf_c-place-attr.obj-type = obj-type and
    bf_c-place-attr.attr-code = attr-code and
    ((bf_c-place-attr.corr-date = endDate and 
    bf_c-place-attr.corr-time < endTime) or 
    bf_c-place-attr.corr-date < endDate) no-error .
  if available (bf_c-place-attr) then attr-value = bf_c-place-attr.attr-value .
  else attr-value = "true" .

end procedure. 

FUNCTION get_max-qnty returns decimal (
  input obj-code as integer, 
  input obj-type as character,
  input pl-code as integer,
  input endDate as date,
  input endTime as integer ):

  define buffer bf_c-place     for ub.c-place .
  define buffer buf_c-place    for ub.c-place .
  define buffer bf_place       for ub.place .
  define buffer curr_c-place   for c-place .
  define buffer buf_c-plc-hist for ub.c-plc-hist .
  define variable ii      as integer no-undo init 0.
  define variable is-max-qnty as logical no-undo .
  define variable is-true as logical no-undo .
  
  find last curr_c-place no-lock where curr_c-place.pl-code = pl-code and
    curr_c-place.obj-code = obj-code and
    curr_c-place.obj-type = obj-type and
    ((curr_c-place.corr-date = endDate and 
    curr_c-place.corr-time < endTime) or 
    curr_c-place.corr-date < endDate) no-error .
  if available (curr_c-place) then 
  do:
    find first buf_c-plc-hist no-lock where
      buf_c-plc-hist.obj-type = obj-type
      AND buf_c-plc-hist.obj-code = obj-code
      AND buf_c-plc-hist.pl-code = pl-code
      AND buf_c-plc-hist.subject  = "place" 
      and buf_c-plc-hist.chip-num = curr_c-place.chip-num no-error .
    if available (buf_c-plc-hist) then 
    do:
&scop fields-name-list  "max-qnty"

      define variable v-label-param as character no-undo .

      v-label-param =
        "max-qnty" + {&delim-par} + "Максимальное количество" + {&delim-par} + "" .
      run proc-full-temp-changes in this-procedure (
        input buf_c-plc-hist.action = integer({&hn-create})
        ,input buf_c-plc-hist.action = integer({&hn-delete})
        ,input  buffer curr_c-place:handle
        ,input  {&table_place}
        ,input  {&fields-name-list}
        ,input  v-label-param).

    end.
  end.
  for each with-action:
    return decimal(with-action.v_new) .
  end.
  if available (curr_c-place) then 
  do:
    return curr_c-place.max-qnty .
  end.  
  find first bf_place no-lock where bf_place.pl-code = pl-code and                   
    bf_place.obj-code = obj-code and                                                 
    bf_place.obj-type = obj-type no-error .                                          
  return bf_place.max-qnty . 

end function. 

FUNCTION get_meas returns logical (
  input obj-code as integer, 
  input obj-type as character,
  input pl-code as integer,
  input endDate as date,
  input endTime as integer ):

  define buffer bf_c-place     for ub.c-place .
  define buffer buf_c-place    for ub.c-place .
  define buffer bf_place       for ub.place .
  define buffer curr_c-place   for c-place .
  define buffer buf_c-plc-hist for ub.c-plc-hist .
  define variable ii      as integer no-undo init 0.
  define variable is-meas as logical no-undo .
  define variable is-true as logical no-undo .
  
  find last curr_c-place no-lock where curr_c-place.pl-code = pl-code and
    curr_c-place.obj-code = obj-code and
    curr_c-place.obj-type = obj-type and
    ((curr_c-place.corr-date = endDate and 
    curr_c-place.corr-time < endTime) or 
    curr_c-place.corr-date < endDate) no-error .
  if available (curr_c-place) then 
  do:
    find first buf_c-plc-hist no-lock where
      buf_c-plc-hist.obj-type = obj-type
      AND buf_c-plc-hist.obj-code = obj-code
      AND buf_c-plc-hist.pl-code = pl-code
      AND buf_c-plc-hist.subject  = "place" 
      and buf_c-plc-hist.chip-num = curr_c-place.chip-num no-error .
    if available (buf_c-plc-hist) then 
    do:
&scop fields-name-list  "is-meas"

      define variable v-label-param as character no-undo .

      v-label-param =
        "is-meas" + {&delim-par} + "Измеряется приборами" + {&delim-par} + "" .
      run proc-full-temp-changes in this-procedure (
        input buf_c-plc-hist.action = integer({&hn-create})
        ,input buf_c-plc-hist.action = integer({&hn-delete})
        ,input  buffer curr_c-place:handle
        ,input  {&table_place}
        ,input  {&fields-name-list}
        ,input  v-label-param).

    end.
  end.
  for each with-action:
    return logical (with-action.v_new) .
  end.
  find first bf_place no-lock where bf_place.pl-code = pl-code and                   
    bf_place.obj-code = obj-code and                                                 
    bf_place.obj-type = obj-type no-error .                                          
  return bf_place.is-meas . 

end function. 

FUNCTION get_com-vessel returns logical (
  input obj-code as integer, 
  input obj-type as character,
  input attr-code as character,
  input pl-code as integer,
  input openDate as date,
  input endDate as date,
  input openTime as integer,
  input endTime as integer ):
     
  define buffer current_c-place-attr for c-place-attr .
  define buffer buf_c-plc-hist       for ub.c-plc-hist .
  define variable ii      as integer   no-undo init 0.
  define variable is-meas as logical   no-undo .
  define variable is-true as logical   no-undo .
  define variable v-label as character no-undo .
  define variable p-ok    as logical   no-undo .

  find last current_c-place-attr no-lock where
    current_c-place-attr.obj-type = obj-type
    AND current_c-place-attr.obj-code = obj-code
    AND current_c-place-attr.pl-code = pl-code  
    and current_c-place-attr.attr-code = attr-code
    and ((current_c-place-attr.corr-date = endDate 
    and current_c-place-attr.corr-time < endTime) or
    current_c-place-attr.corr-date < endDate)
    
    no-error .
  if avail current_c-place-attr then 
  do:

    find first buf_c-plc-hist no-lock where
      buf_c-plc-hist.obj-type = obj-type
      AND buf_c-plc-hist.obj-code = obj-code
      AND buf_c-plc-hist.pl-code = pl-code
      AND buf_c-plc-hist.subject  = "place-attr" 
      and buf_c-plc-hist.chip-num = current_c-place-attr.chip-num no-error .
    if available (buf_c-plc-hist) then 
    do:
        
&scop fields-name-list  "attr-code,attr-value,PS,status_"

      define variable v-label-param as character no-undo .

      if current_c-place-attr.attr-code = "place-SI"
        or current_c-place-attr.attr-code = "place-SI-temp"
        or current_c-place-attr.attr-code = "place-SI-dens"
        or current_c-place-attr.attr-code = "place-SI-level"
        then 
      do :
        v-label-param =
          "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + "getSIname" + {&delim-flf}
          + "attr-code" + {&delim-par} + "Код атрибута" + {&delim-par} + "getPlaceAttrCode"   .
      end .
      else 
      do :
        v-label-param =
          "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + "getPlaceAttrValue" + {&delim-flf}
          + "attr-code" + {&delim-par} + "Код атрибута" + {&delim-par} + "getPlaceAttrCode" + {&delim-flf}
          + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
          + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
      end . 

      run proc-full-temp-changes in this-procedure (
        input buf_c-plc-hist.action = integer({&hn-create})
        ,input buf_c-plc-hist.action = integer({&hn-delete})
        ,input  buffer current_c-place-attr:handle
        ,input  {&table_place-attr}
        ,input  {&fields-name-list}
        ,input  v-label-param).

    end.
  end.

  for each with-action:
    p-ok = logical (with-action.v_new) no-error .
    if error-status:error then p-ok = false .
    return   p-ok .

  end.

  return no .

end function. 

FUNCTION get_com-tanks returns character (
  input obj-code as integer, 
  input obj-type as character,
  input attr-code as character,
  input pl-code as integer,
  input openDate as date,
  input endDate as date,
  input openTime as integer,
  input endTime as integer ):
     
  define buffer current_c-place-attr for ub.c-place-attr .
    define buffer buf_c-plc-hist       for ub.c-plc-hist .
  define variable ii        as integer   no-undo init 0.
  define variable is-meas   as logical   no-undo .
  define variable is-true   as logical   no-undo .
  define variable v-label   as character no-undo .
  define variable p-ok as character no-undo .
/*  define buffer curr_c-place-attr for ub.c-place-attr .*/
/*  define buffer buf_place-attr for ub.place-attr .     */
/*  define buffer buf_place for ub.place .               */
/*  define variable com-tanks as character no-undo .     */
/*  define variable p-ok as logical no-undo .            */
/*  define variable ii as integer no-undo .              */

  find last current_c-place-attr no-lock where
    current_c-place-attr.obj-type = obj-type
    AND current_c-place-attr.obj-code = obj-code
    AND current_c-place-attr.pl-code = pl-code  
    and current_c-place-attr.attr-code = attr-code
    and ((current_c-place-attr.corr-date = endDate 
    and current_c-place-attr.corr-time < endTime) or
    current_c-place-attr.corr-date < endDate)
    
    no-error .
  if avail current_c-place-attr then 
  do:

    find first buf_c-plc-hist no-lock where
      buf_c-plc-hist.obj-type = obj-type
      AND buf_c-plc-hist.obj-code = obj-code
      AND buf_c-plc-hist.pl-code = pl-code
      AND buf_c-plc-hist.subject  = "place-attr" 
      and buf_c-plc-hist.chip-num = current_c-place-attr.chip-num no-error .
    if available (buf_c-plc-hist) then 
    do:
        
&scop fields-name-list  "attr-code,attr-value,PS,status_"

      define variable v-label-param as character no-undo .

      if current_c-place-attr.attr-code = "place-SI"
        or current_c-place-attr.attr-code = "place-SI-temp"
        or current_c-place-attr.attr-code = "place-SI-dens"
        or current_c-place-attr.attr-code = "place-SI-level"
        then 
      do :
        v-label-param =
          "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + "getSIname" + {&delim-flf}
          + "attr-code" + {&delim-par} + "Код атрибута" + {&delim-par} + "getPlaceAttrCode"   .
      end .
      else 
      do :
        v-label-param =
          "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + "getPlaceAttrValue" + {&delim-flf}
          + "attr-code" + {&delim-par} + "Код атрибута" + {&delim-par} + "getPlaceAttrCode" + {&delim-flf}
          + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
          + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
      end . 

      run proc-full-temp-changes in this-procedure (
        input buf_c-plc-hist.action = integer({&hn-create})
        ,input buf_c-plc-hist.action = integer({&hn-delete})
        ,input  buffer current_c-place-attr:handle
        ,input  {&table_place-attr}
        ,input  {&fields-name-list}
        ,input  v-label-param).

    end.
  end.

  for each with-action:
     p-ok = with-action.v_new no-error .
     if error-status:error then p-ok = "" .
    return   p-ok .

  end.

  return "" .
end function. 

function getSIname returns character (si-code as char) :
  for first sr-izmerenia no-lock where sr-izmerenia.node-code = integer(si-code) :
    return sr-izmerenia.sr-model .
  end .
end .

function  getPlaceAttrCode returns character (istr as char ):
  define variable OStr as character no-undo.
  if istr eq "disable-level-alarm"
    then
    OStr = "Сообщения о переполнении".
  else if istr eq "disable-water-alarm"
      then
      OStr = "Сообщения по воде".
    else if istr eq "place-need-RVD-rvs"
        then
        OStr = "Необходимо сделать сверку с РВД".
      else if istr eq "place-SI-level"
          then
          OStr = "Доп. средство измерения уровня".  
        else if istr eq "place-SI-dens"
            then
            OStr = "Доп. средство измерения плотности".
          else if istr eq "place-SI-temp"
              then
              OStr = "Доп. средство измерения температуры". 
            else if istr eq "place-SI"
                then
                OStr = "Основное средство измерения".
              else
                OStr = istr.
  return OStr.
end.

function  getPlaceAttrValue returns character (istr as char ):
  define variable OStr  as character no-undo.
  define variable vFlag as logical   no-undo.
  if    entry(1,istr,{&delim-par}) eq "enable"
    then
    assign
      OStr  = "Включено"
      vFlag = yes
      .
  else if    entry(1,istr,{&delim-par}) eq "disable"
      then
      assign
        OStr  = "Выключено"
        vFlag = yes
        .
    else
      OStr = istr.
  if     vFlag
    and num-entries (istr,{&delim-par}) > 2
    then
    OStr = OStr + " для смены № " + entry(3,istr,{&delim-par}) + " Дата " + entry(2,istr,{&delim-par}).
  return OStr.
end.

PROCEDURE proc-full-temp-changes :


  define input  parameter p-act-create as logical   no-undo .
  define input  parameter p-act-delete as logical   no-undo .
  define input  parameter p-hst-handle as handle    no-undo .
  define input  parameter p-main-table as character no-undo .
  define input  parameter p-field-list as character no-undo .
  define input  parameter p-label-form as character no-undo .

  define variable h-new-buf         as handle    no-undo .
  define variable h-main-buf        as handle    no-undo .
  define variable h-for-comp        as handle    no-undo .
  define variable v-inform          as character no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-idx-field-qnty  as integer   no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable fh                as handle    no-undo .
  define variable fh-main           as handle    no-undo .
  define variable fh-old            as handle    no-undo .
  define variable fh-new            as handle    no-undo .
  define variable v-field-name      as character no-undo .
  define variable v-field-lvl       as character no-undo .
  define variable v-field-form      as character no-undo .
  define variable v-search-exp      as character no-undo .
  define variable v-srch-main       as character no-undo .
  define variable v-word-link       as character no-undo .
  define variable v-av-chip-num     as logical   no-undo .
  define variable v-main-pi-fld-lst as character no-undo .
  define variable v-main-fld-lst    as character no-undo .
  define variable v-delim-list      as character no-undo .
  define variable v-label           as character no-undo .
  define variable v-old-value       as character no-undo case-sensitive.
  define variable v-new-value       as character no-undo case-sensitive.

  define variable v-chg-fields      as character no-undo.

  for each with-action:
    delete with-action.
  end.

  if not p-hst-handle:available then 
  do:
    return .
  end.

  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .

  /* проход по основной таблице с целью создания списка                      */
  /* полей первичного индекса, оставшихся полей и запроса к основной таблице */
  assign
    v-inform = h-main-buf:index-information(1)
    v-ind    = 2
    .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
    assign
      v-inform = h-main-buf:index-information( v-ind )
      v-ind    = v-ind + 1
      .
  end.

  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
    then 
  do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.

  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
    .
  if v-idx-field-qnty < 2 then 
  do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, h-main-buf:name ).
  end.

  assign
    v-srch-main   = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    v-delim-list  = "":U
    .
  do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
    assign
      v-field-name      = entry( 4 + v-ind, v-inform, ",":U )
      fh                = p-hst-handle:buffer-field( v-field-name ) /* значения для выборки берем из записи истории */
      fh-main           = h-main-buf:buffer-field( v-field-name )
      v-srch-main       = substitute( "&1 &2 &3.&4 =", v-srch-main, v-word-link, fh-main:table, v-field-name )
      v-main-pi-fld-lst = v-main-pi-fld-lst + v-delim-list + v-field-name
      .
    if fh:data-type ="character":U then 
    do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
        .
    end.
    else 
    do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
        .
    end.
    if v-delim-list = "":U then 
    do:
      assign
        v-delim-list = ",":U
        .
    end.
    if v-word-link = "":U then 
    do:
      assign
        v-word-link = "and":U
        .
    end.
  end.
  assign
    v-delim-list = "":U
    .
  do v-ind = 1 to h-main-buf:num-fields
    on error undo, return error
    :
    assign
      fh-main      = h-main-buf:buffer-field( v-ind )
      v-field-name = fh-main:name
      .
    /*    if lookup( v-field-name, v-main-pi-fld-lst, ",":U ) = 0 then do:*/
    assign
      v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
    if v-delim-list = "":U then 
    do:
      assign
        v-delim-list = ",":U
        .
    end.
  /*    end.*/
  end.
  /* это проход по исторической таблице для создания запроса */
  assign
    v-inform = p-hst-handle:index-information(1)
    v-ind    = 2
    .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
    assign
      v-inform = p-hst-handle:index-information( v-ind )
      v-ind    = v-ind + 1
      .
  end.

  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
    then 
  do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.

  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
    .
  if v-idx-field-qnty < 2 then 
  do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, p-hst-handle:name ).
  end.

  assign
    v-search-exp  = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    .
  do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh           = p-hst-handle:buffer-field( v-field-name )
      v-search-exp = substitute( "&1 &2 &3.&4", v-search-exp, v-word-link, fh:table, v-field-name )
      .
    if v-field-name = "chip-num":U then 
    do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
        .
    end.
    else 
    do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
        .
    end.
    if fh:data-type ="character":U then 
    do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
        .
    end.
    else 
    do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
        .
    end.
    if v-word-link = "":U then 
    do:
      assign
        v-word-link = "and":U
        .
    end.
  end.

  if v-av-chip-num = false then 
  do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.

  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then 
  do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then 
    do:
      assign
        h-for-comp = ?
        .
    end.
    else 
    do:
      assign
        h-for-comp = h-main-buf
        .
    end.
  end.
  else 
  do:
    assign
      h-for-comp = h-new-buf
      .
  end.
  assign
    v-num-entries = num-entries( v-main-fld-lst, ",":U )
    .
  do v-ind = 1 to v-num-entries
    on error undo, return error return-value
    :
    assign
      v-field-name = entry( v-ind, v-main-fld-lst )
      fh-old       = p-hst-handle:buffer-field( v-field-name )
      v-old-value  = fh-old:buffer-value()
      v-label      = trim( fh-old:label )
      .
    if ( trim( p-field-list ) <> "":U
      and lookup( v-field-name, p-field-list ) > 0
      )
      or trim( p-field-list ) = "":U
      then 
    do:
      if h-for-comp <> ? then 
      do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
          .
      end.
      else 
      do:
        assign
          v-new-value = "":U
          .
      end.

      if p-act-create = true then 
      do:
        assign
          v-old-value = "":U
          .
      end.
      if p-act-delete = true then 
      do:
        assign
          v-new-value = "":U
          .
      end.


      if v-old-value <> v-new-value
        &if defined(VisibleKeyField) ne 0
        &then
        or lookup(v-field-name,v-main-pi-fld-lst) ne 0
        &endif 
        then 
      do:
        create with-action.
        assign
          with-action.t_name     = p-main-table
          with-action.f_name     = v-field-name
          with-action.l_name     = replace( v-label, "&":U, "":U )
          with-action.v_old      = trim( v-old-value )
          with-action.v_new      = trim( v-new-value )
          with-action.num_       = 0
          with-action.fNotChange = v-old-value eq v-new-value
          .
      end.
    end.
  end.

  assign
    v-num-entries = num-entries( p-label-form, {&delim-flf} )
    .
  &if defined( myChangeAdd) ne 0
  &then
  run {&myChangeAdd} (if p-act-create = true then ? else p-hst-handle,
    if p-act-delete = true then ? else h-for-comp).
  &endif
  do v-ind = 1 to v-num-entries
    on error undo, return error return-value
    :
    if num-entries( entry( v-ind, p-label-form, {&delim-flf} ), {&delim-par} ) = 3 then 
    do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, {&delim-flf} ), {&delim-par} )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, {&delim-flf} ), {&delim-par} )
        v-field-form = entry( 3, entry( v-ind, p-label-form, {&delim-flf} ), {&delim-par} )
        .
      find first with-action
        where with-action.f_name = v-field-name
        no-error .
      if available with-action then 
      do:
        if trim( v-field-lvl ) <> "":U then 
        do:
          assign
            with-action.l_name = v-field-lvl
            .
        end.
        if trim( v-field-form ) <> "":U then 
        do:
          assign
            with-action.v_old = dynamic-function( v-field-form, with-action.v_old )
            .
          if h-for-comp <> ? then 
          do:
            assign
              with-action.v_new = dynamic-function( v-field-form, with-action.v_new )
              .
          end.
        end.
      end.
    end.
    else 
    do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка! Список должен содержать три поля с разделителем delim-par!" skip
        substitute( "список для поля '&1': '&2'"
        ,entry( 1, entry( v-ind, p-label-form, {&delim-flf} ), {&delim-par} )
        ,entry( v-ind, p-label-form, {&delim-flf} )
        ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.

  delete object h-new-buf .
  delete object h-main-buf .

END PROCEDURE. /* proc-full-temp-changes */
