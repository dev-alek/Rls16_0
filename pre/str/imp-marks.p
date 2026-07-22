block-level on error undo, throw.
using ibs.th.bge.egais.*.
define input parameter parparentproc    as handle              no-undo.
define input parameter pardoc-code      like ub.trn-doc.doc-code  no-undo.
define input parameter p-mode as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 616d42daa905, 1424, test $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jun 29 17:59:59 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-marks.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/imp-marks.p $":U .
define variable vss-description as character no-undo init "Импорт доп. БК, внеш. ПН, Документ назначения цены из текстового файла".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION Base2Int64 RETURNS INT64 ( INPUT i-hex AS CHARACTER, INPUT i-base AS INTEGER ) :
  DEFINE VARIABLE j_num AS INT64 NO-UNDO.
  RUN conv-base-to-int64 IN THIS-PROCEDURE ( INPUT i-hex, INPUT i-base, OUTPUT j_num ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_num ).
END FUNCTION.
PROCEDURE conv-base-to-int64 :
  DEFINE  INPUT PARAMETER p-num  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-base AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-int  AS INT64     NO-UNDO.
  DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL '':U.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_sign AS INT64   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    IF p-base > 60 THEN DO:
      ASSIGN p-int = ?.
      UNDO, RETURN ERROR.
    END.
    ASSIGN v_list = '0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,':U +
                    'Б,Г,Д,Ё,Ж,З,И,Й,Л,П,У,Ф,Ц,Ч,Ш,Щ,Ъ,Ы,Ь,Э,Ю,Я,@,$':U
           v_list = SUBSTRING( v_list, 1, p-base * 2 - 1 )
           p-num  = TRIM( p-num ).
    IF SUBSTRING( p-num, 1, 1 ) = "-" THEN DO:
        ASSIGN j_sign = -1
               p-num  = SUBSTRING( p-num, 2 ).
    END.                              ELSE DO: ASSIGN j_sign = 1. END.
    DO jj = 1 TO LENGTH( p-num ) :
      ASSIGN p-int = p-int * p-base + LOOKUP( SUBSTRING( p-num, jj, 1 ), v_list ) - 1.
    END.
    ASSIGN p-int = j_sign * p-int.
  END.
END PROCEDURE.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE ProcAlcCode :
  define input  parameter p-mark-alc as character  no-undo .
  define output parameter p-alc-code as character  no-undo initial ''.
  define output parameter p-error as logical no-undo initial no.
  define output parameter p-error-lang as logical no-undo initial no.
  define variable v-kol              as integer    no-undo .
  define variable v-alc-code as character no-undo .
  define variable v-result as character no-undo .
  define variable ii as integer no-undo .
  DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL '':U.
  ASSIGN
    v_list = '0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,':U .
  v-alc-code = SUBSTRing (p-mark-alc, 8, 12) .
  do ii = 1 to length (v-alc-code):
    if LOOKUP( SUBSTRING( v-alc-code, ii, 1 ), v_list )  < 1 then
    do:
      p-error-lang = yes .
      leave .
    end.
  end.
  p-alc-code = string (Base2Int64 (v-alc-code, 36) ) no-error.
  if (Base2Int64 (v-alc-code, 36) ) < 0 then
  do:
    p-error = yes.
  end.
  else
  do:
    if length(p-alc-code) < 20 then
    do:
      p-alc-code = fill('0', 19 - length(p-alc-code)) + p-alc-code.
    end.
  end.
END PROCEDURE.
PROCEDURE ProcFindGds  :
  define input  parameter p-alc-code as character  no-undo .
  define output parameter p-gds-code as integer    no-undo .
  define buffer x_ext-classif        for ub.ext-classif .
      find first X_ext-classif no-lock where X_ext-classif.classif-subject = 'goods':U
                                               and X_ext-classif.classif-name = 'exp-esys-gds-code':U
                                               AND X_ext-classif.db-num = 0
                                               and X_ext-classif.CharKey_One = p-alc-code
                                               no-error.
      if available x_ext-classif then p-gds-code = X_ext-classif.Key#_One.
END PROCEDURE.
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info5 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info5, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info5, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info5 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info5, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info5 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info5, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info5, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info5, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info5, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info5, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info5 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info5 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info5, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info5 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info5 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define new shared stream inp.
define new shared stream err.
define new shared stream wrn.
define temp-table tt-marks
    field mark                as character            label "Марка"          format "X(100)"
    field alc-code            as character            LABEL "Алк. код"       FORMAT "X(20)"
    field artic        as character
    field prod-type    as character
    field prod-code    as integer
    field obj-type     as character
    field obj-code     as integer
    index pi as primary unique
        mark
.
define temp-table tt-alc-qnty
    field artic        as character
    field prod-type    as character
    field prod-code    as integer
    field alc-code as character
    field qnty as integer
    index pi as primary unique
        artic prod-type prod-code alc-code
.
define variable InputFileName  as character         no-undo.
define variable vartemp-ext as character no-undo.
define variable varlog      as logical   no-undo.
define variable varuser-action as character no-undo.
define variable varis-printed  as logical   no-undo.
define variable i-line      as character no-undo .
define variable v-ean       as logical no-undo .
define variable v-prod-bc   as character no-undo .
define variable v-col-ean   as integer no-undo initial 0 .
define variable v-col-ean-ok as integer no-undo initial 0 .
define variable v-col-marks as integer no-undo initial 0 .
define variable v-col-marks-ok as integer no-undo initial 0 .
define variable v-gds-code    like ub.goods.gds-code     no-undo .
define variable v-gds-name    as character    no-undo .
define variable v-alc-code    as character    no-undo .
define variable v-error-lang  as logical      no-undo .
define variable l-error         as logical   no-undo.
def    var      extGdsObj       as class     extgds.
define variable part-key-rec as character no-undo .
define variable free-part-key-rec as character no-undo .
define buffer buf_trn-doc for ub.trn-doc  .
define buffer buf2_trn-doc for ub.trn-doc  .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_parts for ub.parts .
define buffer free_parts for ub.parts .
define buffer buf_prod-bc for ub.prod-bc .
define buffer buf_bar-code for ub.bar-code .
define buffer buf_goods for ub.goods .
define buffer buf_gen-attr for ub.gen-attr .
define buffer free_gen-attr for ub.gen-attr .
   SYSTEM-DIALOG GET-FILE InputFileName
                 TITLE   "Файл с акцизными марками"
                 FILTERS "Текстовый файл (*.txt)"   "*.txt",
                         "Все файлы (*.*)"          "*.*"
                 MUST-EXIST
                 USE-FILENAME
                 default-extension ".txt"
                 UPDATE varlog.
   if not varlog then return error.
InputFileName = trim (string (InputFileName)) .
assign
vartemp-ext = entry (2, InputFileName, ".") no-error.
if error-status:error then do:
  message "Файл без расширения не может быть обработан. Переименуйте его."
          view-as alert-box error.
  return error.
end.
if entry (2, InputFileName, ".") = "err" then do:
  message "Файл с расширением '.err' не может быть обработан. Переименуйте его."
          view-as alert-box error.
  return error.
end.
if entry (2, InputFileName, ".") = "wrn" then do:
  message "Файл с расширением '.wrn' не может быть обработан. Переименуйте его."
          view-as alert-box error.
  return error.
end.
output stream err TO value (entry (1, InputFileName, ".") + ".err").
find first buf_trn-doc no-lock where buf_trn-doc.doc-code = pardoc-code .
input stream inp FROM value (InputFileName) .
extGdsObj = new ExtGds (true).
file-line_:
repeat :
    import stream  inp unformatted i-line no-error.
    i-line = trim(i-line) .
    if length(i-line) = 13
    then do :
        v-ean = true.
        v-prod-bc = i-line .
        v-gds-code = 0 .
        v-col-ean = v-col-ean + 1 .
        find first buf_prod-bc no-lock where buf_prod-bc.b-str = v-prod-bc no-error.
        if not available buf_prod-bc
        then do :
            put stream err unformatted "Не найден доп. бар-код EAN13 " v-prod-bc skip "Следующие марки не загружены:" skip .
            v-ean = false .
            next file-line_ .
        end.
        find first buf_bar-code no-lock where buf_bar-code.b-code = buf_prod-bc.b-code no-error.
        if not available buf_bar-code
        then do :
            put stream err unformatted "Не найден бар-код для кода EAN13 " v-prod-bc skip "Следующие марки не загружены:" skip .
            v-ean = false .
            next file-line_ .
        end.
        find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
        if not available buf_goods
        then do :
            put stream err unformatted "Не найден товар для кода EAN13 " v-prod-bc skip "Следующие марки не загружены:" skip .
            v-ean = false .
            next file-line_ .
        end.
        v-gds-code = buf_goods.gds-code .
        if p-mode = "in"
        then do :
            find first buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code
                                              and buf_doc-line.artic    = buf_goods.artic
                                              and buf_doc-line.prod-type = buf_goods.prod-type
                                              and buf_doc-line.prod-code = buf_goods.prod-code no-error .
            if not available buf_doc-line
            then do :
                put stream err unformatted "В накладной нет товара (код " buf_goods.gds-code ") " buf_goods.gds-name " с доп. БК EAN13 " v-prod-bc skip "Следующие марки не загружены:" skip .
                v-ean = false .
                next file-line_ .
            end.
            find first buf_parts no-lock where buf_parts.obj-type   = buf_doc-line.obj-type
                                           and buf_parts.obj-code   = buf_doc-line.obj-code
                                           and buf_parts.artic      = buf_doc-line.artic
                                           and buf_parts.prod-type  = buf_doc-line.prod-type
                                           and buf_parts.prod-code  = buf_doc-line.prod-code
                                           and buf_parts.in-code    = pardoc-code
                                           and buf_parts.out-code   = pardoc-code
                                           no-error .
            if not available buf_parts
            then do :
                put stream err unformatted "Не найдена партия товара (код " buf_goods.gds-code ") " buf_goods.gds-name " с доп. БК EAN13 " v-prod-bc skip "Следующие марки не загружены:" skip .
                v-ean = false .
                next file-line_ .
            end.
            else do :
                if num-entries(buf_parts.alc-ref-ab-path) = 4 and trim(entry(3, buf_parts.alc-ref-ab-path)) = ""
                or num-entries(buf_parts.alc-ref-ab-path) <> 4
                then do :
                    put stream err unformatted "В партии товара (код " buf_goods.gds-code ") " buf_goods.gds-name " с доп. БК EAN13 " v-prod-bc " не указан алкогольный код" skip "Следующие марки не загружены:" skip .
                    v-ean = false .
                    next file-line_ .
                end.
            end.
        end.
        v-col-ean-ok = v-col-ean-ok + 1 .
    end.
    else do :
        v-col-marks = v-col-marks + 1 .
        if not v-ean
        then do :
            put stream err unformatted i-line skip .
            next file-line_ .
        end.
        else do :
            if p-mode = "in"
            then do :
                find first buf_gen-attr no-lock where buf_gen-attr.table-name = 'excise-mark':U
                                                  and buf_gen-attr.attr-code = i-line no-error.
                if available buf_gen-attr
                then do :
                    put stream err unformatted "Марка " i-line " уже учтена в системе и привязана к партии " buf_gen-attr.p-key skip .
                    next file-line_ .
                end.
            end.
            find first tt-marks no-lock where tt-marks.mark = i-line no-error.
            if available tt-marks
            then do :
                put stream err unformatted "В файле продублирована марка " i-line skip .
                next file-line_ .
            end.
            run ProcAlcCode  IN THIS-PROCEDURE (input i-line, output v-alc-code, output l-error, output v-error-lang ) no-error.
            if v-error-lang
            then do:
              put stream err unformatted
                "Некорректная акцизная марка, акцизная марка содержит недопустимые символы или русские буквы.  " i-line
                skip .
              v-alc-code = "".
              l-error = yes .
              next file-line_ .
            end.
            extGdsObj:OpenQueryExtGds(v-gds-code, v-alc-code).
            if extGdsObj:NumBundles = 0
            then do :
                put stream err unformatted "Нет связки товара (код " string(v-gds-code) ") с алкокодом " v-alc-code ". Марка " i-line skip .
                next file-line_ .
            end.
            if p-mode = "in"
            then do :
                create tt-marks .
                assign
                    tt-marks.mark           = i-line
                    tt-marks.alc-code       = v-alc-code
                    tt-marks.artic          = buf_doc-line.artic
                    tt-marks.prod-type      = buf_doc-line.prod-type
                    tt-marks.prod-code      = buf_doc-line.prod-code
                    tt-marks.obj-type       = buf_doc-line.obj-type
                    tt-marks.obj-code       = buf_doc-line.obj-code
                .
                find first tt-alc-qnty exclusive-lock where tt-alc-qnty.artic       = tt-marks.artic
                                                        and tt-alc-qnty.prod-type   = tt-marks.prod-type
                                                        and tt-alc-qnty.prod-code   = tt-marks.prod-code
                                                        and tt-alc-qnty.alc-code    = tt-marks.alc-code no-error.
                if not available tt-alc-qnty
                then do :
                    create tt-alc-qnty .
                    assign
                        tt-alc-qnty.artic       = tt-marks.artic
                        tt-alc-qnty.prod-type   = tt-marks.prod-type
                        tt-alc-qnty.prod-code   = tt-marks.prod-code
                        tt-alc-qnty.alc-code    = tt-marks.alc-code
                        tt-alc-qnty.qnty        = 0
                    .
                end.
                tt-alc-qnty.qnty = tt-alc-qnty.qnty + 1 .
            end.
            if p-mode = "out"
            then do :
                if not available buf_goods
                then
                find first buf_goods where buf_goods.gds-code = v-gds-code .
                create tt-marks .
                assign
                    tt-marks.mark           = i-line
                    tt-marks.alc-code       = v-alc-code
                    tt-marks.artic          = buf_goods.artic
                    tt-marks.prod-type      = buf_goods.prod-type
                    tt-marks.prod-code      = buf_goods.prod-code
                    tt-marks.obj-type       = buf_trn-doc.obj-type
                    tt-marks.obj-code       = buf_trn-doc.obj-code
                .
            end.
            v-col-marks-ok = v-col-marks-ok + 1 .
        end.
    end.
end.
delete object extGdsObj no-error .
put stream err unformatted skip .
save_:
for each tt-marks no-lock :
    if p-mode = "in"
    then do :
        find first buf_parts no-lock where buf_parts.obj-type   = tt-marks.obj-type
                                       and buf_parts.obj-code   = tt-marks.obj-code
                                       and buf_parts.artic      = tt-marks.artic
                                       and buf_parts.prod-type  = tt-marks.prod-type
                                       and buf_parts.prod-code  = tt-marks.prod-code
                                       and buf_parts.in-code    = pardoc-code
                                       and buf_parts.out-code   = pardoc-code
                                       no-error .
        if not available buf_parts
        then do :
            put stream err unformatted "Не найдена партия для привязки марки " tt-marks.mark skip .
            v-col-marks-ok = v-col-marks-ok - 1 .
            next save_ .
        end.
        if num-entries(buf_parts.alc-ref-ab-path) <> 4
        or (num-entries(buf_parts.alc-ref-ab-path) = 4 and trim(entry(3, buf_parts.alc-ref-ab-path)) = "")
        then do :
            put stream err unformatted "В партии не заполнен алкокод. Марка " tt-marks.mark skip .
            v-col-marks-ok = v-col-marks-ok - 1 .
            next save_ .
        end.
        if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(3, buf_parts.alc-ref-ab-path) <> tt-marks.alc-code
        then do :
            put stream err unformatted "Алкокод в партии " entry(3, buf_parts.alc-ref-ab-path) " не совпадает с алкокодом марки " tt-marks.alc-code " Марка " tt-marks.mark skip .
            v-col-marks-ok = v-col-marks-ok - 1 .
            next save_ .
        end.
        run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                            ,input (buffer buf_parts:handle)
                                            ,output part-key-rec).
        create buf_gen-attr.
        assign
            buf_gen-attr.table-name = 'excise-mark':U
            buf_gen-attr.p-key      = part-key-rec
            buf_gen-attr.attr-code  = tt-marks.mark
            buf_gen-attr.whole-send-news = 0
        .
    end.
    if p-mode = "out"
    then do :
        for each buf_gen-attr no-lock where buf_gen-attr.table-name = 'excise-mark':U
                                        and buf_gen-attr.attr-code  = tt-marks.mark
                                        and num-entries(buf_gen-attr.p-key, chr(3)) > 8 :
            find first buf2_trn-doc no-lock where buf2_trn-doc.doc-code = entry(8, buf_gen-attr.p-key, chr(3)) no-error .
            if available buf2_trn-doc
            then do :
                if buf2_trn-doc.ext-doc-type = 'ee':U
                then do :
                    put stream err unformatted "Марка " tt-marks.mark " уже учтена в другом расходе. Документ " buf2_trn-doc.doc-code skip .
                    v-col-marks-ok = v-col-marks-ok - 1 .
                    next save_ .
                end.
            end.
        end.
        find first buf_gen-attr no-lock where buf_gen-attr.table-name = 'excise-mark':U
                                          and buf_gen-attr.attr-code  = tt-marks.mark
                                          and buf_gen-attr.p-key      = ("trn-doc" + chr(3) + pardoc-code)
                                          no-error .
        if not available buf_gen-attr
        then do :
            create buf_gen-attr .
            assign
                buf_gen-attr.table-name = 'excise-mark':U
                buf_gen-attr.attr-code  = tt-marks.mark
                buf_gen-attr.p-key      = ("trn-doc" + chr(3) + pardoc-code)
                buf_gen-attr.attr-value = tt-marks.artic + chr(3) + tt-marks.prod-type + chr(3) + string(tt-marks.prod-code)
            .
        end.
    end.
end.
put stream err unformatted skip .
if p-mode = "in"
then
for each tt-alc-qnty no-lock :
    find first buf_doc-line no-lock where buf_doc-line.doc-code = pardoc-code
                                      and buf_doc-line.artic    = tt-alc-qnty.artic
                                      and buf_doc-line.prod-type = tt-alc-qnty.prod-type
                                      and buf_doc-line.prod-code = tt-alc-qnty.prod-code no-error.
    if available buf_doc-line and buf_doc-line.fact-qnty <> tt-alc-qnty.qnty
    then do :
        put stream err unformatted
            "Не совпадает фактическое количество в строке накладной с количеством прочитанных марок. Артикул " buf_doc-line.artic
            ". Кол-во в накладной: " string(buf_doc-line.fact-qnty) "   Кол-во марок: " string(tt-alc-qnty.qnty)
            skip .
    end.
end.
output stream err close.
if p-mode = "in"
then
Message "Импорт завершен."
   skip "Прочитано кодов EAN13: " string(v-col-ean)
   skip "Прочитано марок: " string(v-col-marks)
   skip "Обработано кодов EAN13: " string(v-col-ean-ok)
   skip "Закачано марок: " string(v-col-marks-ok)
   skip(2) "Информация об ошибках находится в файле :" entry (1, InputFileName, ".") + ".err"
   view-as alert-box information .
if p-mode = "out"
then
Message "Импорт завершен."
   skip "Прочитано кодов EAN13: " string(v-col-ean)
   skip "Прочитано марок: " string(v-col-marks)
   skip "Обработано кодов EAN13: " string(v-col-ean-ok)
   skip "Закачано марок: " string(v-col-marks-ok)
   skip(2) "Информация об ошибках находится в файле :" entry (1, InputFileName, ".") + ".err"
   skip(1) "Теперь заполните накладную. Закачанные марки будут привязаны к соответствующим партиям."
   view-as alert-box information .
run gbl/prnfilen.w
    (input  "Ошибки"
    ,input  0
    ,input  entry (1, InputFileName, ".") + ".err"
    ,input  7
    ,output varuser-action
    ,output varis-printed
    ).
