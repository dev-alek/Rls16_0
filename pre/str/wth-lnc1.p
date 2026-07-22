block-level on error undo, throw.
define temp-table tt-par-dtl  no-undo like ub.wth-par
FIELD q-ty-doc     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во по!документу"
FIELD q-ty-fact    AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Количество!факт"
FIELD doc-sum      like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по!документу"
FIELD fact-sum     like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма!факт"
FIELD sum-gds-rubl like ub.wth-line.sum-gds-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам ()"
FIELD sum-gds-base like ub.wth-line.sum-gds-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам (баз.вал.)"
FIELD price-rubl   like ub.wth-line.price-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!()"
FIELD price-base   like ub.wth-line.price-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!(баз.вал.)"
FIELD w-p-code     like ub.wth-dtl.w-p-code
FIELD doc-code     like ub.wth-dtl.doc-code
FIELD gds-code     like ub.wth-gds.gds-code
INDEX tt-pi    IS   PRIMARY UNIQUE par-code  w-p-code doc-code  wth-code
INDEX tt-i1                        par-feat par-unit par-val
INDEX tt-i2                        doc-sum  q-ty-doc
.
define input-output parameter par-rid as recid no-undo .
define input parameter par-mode    as character no-undo .
define input parameter p-silent    as logical no-undo .
define input parameter pardoc-code like ub.wth-line.doc-code no-undo .
define input parameter parwth-code like ub.wth-line.wth-code no-undo .
define input parameter parw-p-code like ub.wth-line.w-p-code no-undo .
define input parameter parout-code like ub.wth-line.out-code no-undo .
define input parameter pardoc-sum  like ub.wth-line.doc-sum no-undo .
define input parameter parfact-sum  like ub.wth-line.doc-sum no-undo .
define input parameter table for tt-par-dtl.
define input parameter parline-exist as logical no-undo .
define input parameter parext-type like ub.wth-doc.ext-doc-type no-undo.
define input parameter parsum-gds-rubl  like ub.wth-line.sum-gds-rubl no-undo .
define input parameter parsum-gds-base  like ub.wth-line.sum-gds-base no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-lnc1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wth-lnc1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке ставки налога".
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
DEFINE VARIABLE var-entry as character no-undo .
define variable v-mes     as character no-undo .
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE vardtl-rec as recid no-undo .
DEFINE VARIABLE varis-dtl as logical no-undo .
DEFINE VARIABLE vardtl-doc-sum as decimal no-undo .
DEFINE VARIABLE vardtl-fact-sum as decimal no-undo .
DEFINE VARIABLE varline-doc-sum as decimal no-undo .
DEFINE VARIABLE varline-fact-sum as decimal no-undo .
DEFINE VARIABLE end-doc-sum like ub.wth-line.doc-sum no-undo .
DEFINE VARIABLE end-fact-sum like ub.wth-line.fact-sum no-undo .
DEFINE VARIABLE v-is-deletion as logical no-undo .
DEFINE VARIABLE v-stts like ub.wealth.wth-code no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_wth-doc for ub.wth-doc .
define buffer buf_wth-line for ub.wth-line .
define buffer inv_wth-doc for ub.wth-doc.
define buffer check_chk-doc for ub.chk-doc .
define buffer buf_wealth for ub.wealth.
_main:
do
on error undo, return error
:
if NOT (par-mode = 'ДОБАВЛЕНИЕ':U OR par-mode = 'ИЗМЕНЕНИЕ':U or par-mode = 'удаление':U) then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр вызова par-mode" par-mode
  view-as alert-box ERROR.
  return error '':U.
end.
if par-mode = 'удаление':U then do:
  assign
  par-mode = 'ИЗМЕНЕНИЕ':U
  v-is-deletion = yes
  .
end.
FIND FIRST buf_wth-doc EXCLUSIVE-LOCK WHERE
           buf_wth-doc.doc-code = pardoc-code No-ERROR No-WAIT.
IF LOCKED buf_wth-doc then do:
  assign
  v-mes = "Запись документа МЦ занята, добавление/изменение строки невозможно".
  run err-mess(input-output v-mes).
  undo _main, return error v-mes.
end.
IF NOT available buf_wth-doc then do:
  assign
  v-mes = "Не найден документ МЦ".
  run err-mess(input-output v-mes).
  undo _main, return error v-mes.
end.
if buf_wth-doc.status_ = 'факт':U then do:
  assign
  v-mes = substitute("Документ имеет статус &1, добавление/изменение строки невозможно", buf_wth-doc.status_).
  run err-mess(input-output v-mes).
  undo _main, return error v-mes.
end.
if buf_wth-doc.status_ = 'разрешен':U
and par-mode = 'ДОБАВЛЕНИЕ':U then dO:
  assign
  v-mes = substitute("Документ имеет статус &1, добавление строки невозможно", buf_wth-doc.status_).
  run err-mess(input-output v-mes).
  undo _main, return error v-mes.
end.
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
  par-rid = ?.
  if  parline-exist = yes then do:
    FIND FIRST ub.wth-line No-LOCK WHERE
              ub.wth-line.doc-code = pardoc-code AND
              ub.wth-line.wth-code = parwth-code AND
              ub.wth-line.w-p-code = parw-p-code No-ERROR.
    if available ub.wth-line then do:
      par-rid = recid(ub.wth-line).
      assign
      pardoc-sum = pardoc-sum + ub.wth-line.doc-sum
      parfact-sum = parfact-sum + ub.wth-line.fact-sum
      .
    end.
  end.
end.
if not v-is-deletion then do:
  run trg/wth-lnc2.p (
                input pardoc-code,
                input buf_wth-doc.host-code,
                input buf_wth-doc.obj-type,
                input buf_wth-doc.obj-code,
                input buf_wth-doc.cli-type,
                input buf_wth-doc.cli-code,
                input buf_wth-doc.auto-fill,
                input buf_wth-doc.borned,
                input buf_wth-doc.exter_,
                input par-rid,
                input parwth-code,
                input parw-p-code,
                input parout-code,
                input pardoc-sum,
                input parfact-sum,
                output v-stts ) no-error.
  if error-status:error then return error return-value.
  if par-mode = 'ДОБАВЛЕНИЕ':U and buf_wth-doc.auto-fill = no
     and v-stts <> 0 then do:
    assign
    v-mes = substitute("МЦ &1 удалена, добавление строки невозможно", parwth-code).
    run err-mess(input-output v-mes).
    undo _main, return error v-mes.
  end.
end.
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
  FIND FIRST buf_wth-line NO-LOCK WHERE
            buf_wth-line.obj-type    = buf_wth-doc.obj-type   AND
            buf_wth-line.obj-code    = buf_wth-doc.obj-code   AND
            buf_wth-line.w-p-code    = parw-p-code   AND
            buf_wth-line.shift-date  = buf_wth-doc.shift-date AND
            buf_wth-line.shift-num   = buf_wth-doc.shift-num  AND
            buf_wth-line.wth-code    = parwth-code   AND
            buf_wth-line.status_    <> 'факт':U           AND
            RECID( buf_wth-line )   <>  par-rid  NO-ERROR.
  IF AVAIL buf_wth-line THEN DO:
    FIND FIRST inv_wth-doc NO-LOCK WHERE
                inv_wth-doc.doc-code = buf_wth-line.doc-code No-ERROR.
    IF inv_wth-doc.doc-type = 'инв':U THEN DO:
    FIND FIRST check_chk-doc No-LOCK WHERE
              check_chk-doc.out-code = inv_wth-doc.doc-code NO-ERROR.
    if avail check_chk-doc and string(check_chk-doc.chk-type) = '4':U then.
      else do:
        assign
        v-mes = substitute("Материальная ценность &1 есть в незакрытой инвентаризации &2 по МХ &3&4добавление строки невозможно"
                          , parwth-code
                          , buf_wth-line.doc-code
                          , parw-p-code
                          , chr(10)
                          ).
        run err-mess(input-output v-mes).
        undo _main, return error v-mes.
      END.
    END.
  END.
end.
DO ON ERROR UNDO, return '':U
   On STOP UNDO, return '':U:
  if par-mode = 'ДОБАВЛЕНИЕ':U and par-rid = ? then do:
  run cur-time in this-procedure(output v-today, output v-time).
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CREATE wth-line.
ASSIGN
  wth-line.doc-code     = buf_wth-doc.doc-code
  wth-line.w-p-code     = parw-p-code
  wth-line.out-code     = parout-code
  wth-line.obj-type     = buf_wth-doc.obj-type
  wth-line.obj-code     = buf_wth-doc.obj-code
  wth-line.shift-date   = buf_wth-doc.shift-date
  wth-line.shift-num    = buf_wth-doc.shift-num
  wth-line.shift-name   = buf_wth-doc.shift-name
  wth-line.creid        = g#userid
  wth-line.credate      = v-today
.
    assign par-rid = recid(ub.wth-line).
  end.
  else do:
    FIND FIRST ub.wth-line EXCLUSIVE-LOCK WHERE
              recid(ub.wth-line) = par-rid No-WAIT No-ERROR.
    if locked ub.wth-line then do:
      assign
      v-mes = substitute("Строка документа занята").
      run err-mess(input-output v-mes).
      undo _main, return error v-mes.
    end.
    if not avail ub.wth-line then do:
      assign
      v-mes = substitute("Не найжена строка документа").
      run err-mess(input-output v-mes).
      undo _main, return error v-mes.
    end.
    if buf_wth-doc.status_ = 'разрешен':U and
      (ub.wth-line.doc-code <> pardoc-code OR
      ub.wth-line.wth-code <> parwth-code OR
      ub.wth-line.w-p-code <> parw-p-code OR
      ub.wth-line.out-code <> parout-code OR
      ub.wth-line.doc-sum <> pardoc-sum ) then dO:
      assign
      v-mes = substitute("Документ МЦ имеет статус &1, можно изменить только сумму факт", buf_wth-doc.status_).
      run err-mess(input-output v-mes).
      undo _main, return error v-mes.
    end.
  end.
  assign
  ub.wth-line.doc-code = pardoc-code
  ub.wth-line.wth-code = parwth-code
  ub.wth-line.w-p-code = parw-p-code
  ub.wth-line.out-code = parout-code
  ub.wth-line.ext-doc-type = parext-type
  buf_wth-doc.doc-sum = buf_wth-doc.doc-sum - ub.wth-line.doc-sum + pardoc-sum
  ub.wth-line.doc-sum = pardoc-sum
  buf_wth-doc.sum-gds-rubl = buf_wth-doc.sum-gds-rubl - ub.wth-line.sum-gds-rubl + parsum-gds-rubl
  buf_wth-doc.sum-gds-base = buf_wth-doc.sum-gds-base - ub.wth-line.sum-gds-base + parsum-gds-base
  ub.wth-line.sum-gds-base = parsum-gds-base
  ub.wth-line.sum-gds-rubl = parsum-gds-rubl
  buf_wth-doc.fact-sum = buf_wth-doc.fact-sum - ub.wth-line.fact-sum + parfact-sum
  ub.wth-line.fact-sum = parfact-sum
  end-doc-sum  = ub.wth-line.doc-sum
  end-fact-sum = ub.wth-line.fact-sum
  ub.wth-line.price-rubl = ub.wth-line.sum-gds-rubl / ub.wth-line.fact-sum
  ub.wth-line.price-base = ub.wth-line.sum-gds-base / ub.wth-line.fact-sum
  .
  assign
  varline-doc-sum = (IF buf_wth-doc.doc-type = 'инв':U
                    THEN ub.wth-line.bef-sum
                    ELSE ub.wth-line.doc-sum
                    )
  varline-fact-sum = (IF buf_wth-doc.doc-type = 'инв':U
                    THEN ub.wth-line.aft-sum
                    ELSE ub.wth-line.fact-sum
                    )
  .
  if par-mode = 'ДОБАВЛЕНИЕ':U then dO:
    release ub.wth-line no-error.
    if error-status:error then do:
            v-mes = return-value.
            run err-mess(input-output v-mes).
            return error (if p-silent = yes then v-mes else '':U).
    end.
  end.
  if not v-is-deletion then do:
    for each tt-par-dtl:
      if tt-par-dtl.wth-code <> parwth-code then next.
      varis-dtl = yes.
      run str/wth-dtl1.p (output vardtl-rec,
                    input par-mode,
                    input pardoc-code,
                    input parwth-code,
                    input parw-p-code,
                    input tt-par-dtl.par-code,
                    input tt-par-dtl.doc-sum,
                    input tt-par-dtl.fact-sum,
                    input tt-par-dtl.sum-gds-rubl ,
                    input tt-par-dtl.sum-gds-base ,
                    input parline-exist
                    ) no-error.
      if error-status:error or vardtl-rec = ? then do:
        var-entry = "b-par":U.
        return error var-entry.
      end.
      assign
      vardtl-doc-sum = vardtl-doc-sum + tt-par-dtl.doc-sum
      vardtl-fact-sum = vardtl-fact-sum + tt-par-dtl.fact-sum
      .
    END.
    if varis-dtl then dO:
      case buf_wth-doc.status_ :
        when 'накл':U then dO:
          if varline-doc-sum <> vardtl-doc-sum and
            NOT (vardtl-doc-sum  = 0 and
                  not can-find(first ub.wth-dtl No-LOCK WHERE
                                      ub.wth-dtl.doc-code = pardoc-code AND
                                      ub.wth-dtl.wth-code = parwth-code AND
                                      ub.wth-dtl.w-p-code = parw-p-code)
                  )
              then dO:
            assign
            v-mes = substitute("Сумма по номиналам &1 не совпадает с суммой движения материального средства &2"
                             , vardtl-doc-sum
                             , varline-doc-sum
                             ).
            run err-mess(input-output v-mes).
            return error (if p-silent = yes then v-mes else 'doc-sum':U).
          end.
        end.
        when 'разрешен':U then do:
          if varline-fact-sum <> vardtl-fact-sum and
            NOT (vardtl-fact-sum  = 0 and
                  not can-find(first ub.wth-dtl No-LOCK WHERE
                                     ub.wth-dtl.doc-code = pardoc-code AND
                                     ub.wth-dtl.wth-code = parwth-code AND
                                     ub.wth-dtl.w-p-code = parw-p-code)
                  )
              then dO:
            assign
            v-mes = substitute("Сумма по номиналам &1 не совпадает с суммой движения материального средства &2"
                             , vardtl-fact-sum
                             , varline-fact-sum
                             ).
            run err-mess(input-output v-mes).
            return error (if p-silent = yes then v-mes else 'wth-dtl':U).
          end.
        end.
      END CASE.
    end.
    else do:
      if can-find(first ub.wth-dtl No-LOCK WHERE
                        ub.wth-dtl.doc-code = pardoc-code AND
                        ub.wth-dtl.wth-code = parwth-code AND
                        ub.wth-dtl.w-p-code = parw-p-code) then do:
        FOR EACH ub.wth-dtl No-LOCK WHERE
                  wth-dtl.doc-code = ub.wth-line.doc-code AND
                  wth-dtl.wth-code = ub.wth-line.wth-code AND
                  wth-dtl.w-p-code = ub.wth-line.w-p-code:
          assign
          vardtl-doc-sum = vardtl-doc-sum + wth-dtl.doc-sum
          vardtl-fact-sum = vardtl-fact-sum + wth-dtl.fact-sum
          .
        END.
        if varline-doc-sum <> vardtl-doc-sum or
          varline-fact-sum <> vardtl-fact-sum then dO:
          if varline-doc-sum <> vardtl-doc-sum then
          assign
          v-mes = substitute("Сумма по номиналам &1 не совпадает с суммой движения материального средства &2"
                            , vardtl-doc-sum
                            , varline-doc-sum
                            ).
          else
          assign
          v-mes = substitute("Сумма по номиналам &1 не совпадает с суммой движения материального средства &2"
                            , vardtl-fact-sum
                            , varline-fact-sum
                            ).
          run err-mess(input-output v-mes).
          return error (if p-silent = yes then v-mes else 'wth-dtl':U).
        end.
      end.
    end.
  end.
  if v-is-deletion then do:
  assign
    buf_wth-doc.doc-sum      = buf_wth-doc.doc-sum - ub.wth-line.doc-sum
    buf_wth-doc.sum-gds-rubl = buf_wth-doc.sum-gds-rubl - ub.wth-line.sum-gds-rubl
    buf_wth-doc.sum-gds-base = buf_wth-doc.sum-gds-base - ub.wth-line.sum-gds-base
    buf_wth-doc.fact-sum     = buf_wth-doc.fact-sum - ub.wth-line.fact-sum
  .
  end.
  if parline-exist and
  end-doc-sum = 0 AND
  end-fact-sum = 0
  then do:
    FIND FIRSt ub.wth-line exclusive-lock where
               recid(ub.wth-line) = par-rid.
    delete ub.wth-line no-error.
    if error-status:error then do:
      v-mes = return-value .
      run err-mess(input-output v-mes).
      return error (if p-silent = yes then v-mes else '':U).
    end.
    par-rid = ?.
  end.
END.
return '':U.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
    p-mess = substitute("Документ МЦ №&1 строка с МЦ &2 МЗ &3: &4&5"
                   , pardoc-code
                   , parwth-code
                   , parw-p-code
                   , chr(10)
                   , p-mess).
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
