block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.ord-line OLD BUFFER old_ord-line.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение строки заказа".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define buffer buf_ord-doc for ub.ord-doc  .
define buffer buf_c-ord-line for ub.c-ord-line  .
define buffer buf_goods for ub.goods  .
define variable v-today     as date      no-undo.
define variable start-time  as integer   no-undo .
define variable var-r-b as character no-undo .
define variable     varprice-cli                    like ub.doc-line.price-base no-undo .
define variable     varprice-cli-unit-base          like ub.doc-line.price-base no-undo .
define variable     varprice-road-tax               like ub.doc-line.price-base no-undo .
define variable     varprice-other-exp              like ub.doc-line.price-base no-undo .
define variable     varprice-transport-exp          like ub.doc-line.price-base no-undo .
define variable     varprice-without-abs            like ub.doc-line.price-base no-undo .
define variable     varprice-slt                    like ub.doc-line.price-base no-undo .
define variable     varprice-no-slt                 like ub.doc-line.price-base no-undo .
define variable     varprice-vat                    like ub.doc-line.price-base no-undo .
define variable     varprice-no-vat-slt             like ub.doc-line.price-base no-undo .
define variable     varprice-rubl                   like ub.doc-line.price-base no-undo .
define variable     varprice-road-tax-rubl          like ub.doc-line.price-base no-undo .
define variable     varprice-other-exp-rubl         like ub.doc-line.price-base no-undo .
define variable     varprice-transport-exp-rubl     like ub.doc-line.price-base no-undo .
define variable     varprice-without-abs-rubl       like ub.doc-line.price-base no-undo .
define variable     varprice-slt-rubl               like ub.doc-line.price-base no-undo .
define variable     varprice-no-slt-rubl            like ub.doc-line.price-base no-undo .
define variable     varprice-vat-rubl               like ub.doc-line.price-base no-undo .
define variable     varprice-no-vat-slt-rubl        like ub.doc-line.price-base no-undo .
define variable     varprice-base                   like ub.doc-line.price-base no-undo .
define variable     varprice-road-tax-base          like ub.doc-line.price-base no-undo .
define variable     varprice-other-exp-base         like ub.doc-line.price-base no-undo .
define variable     varprice-transport-exp-base     like ub.doc-line.price-base no-undo .
define variable     varprice-without-abs-base       like ub.doc-line.price-base no-undo .
define variable     varprice-slt-base               like ub.doc-line.price-base no-undo .
define variable     varprice-no-slt-base            like ub.doc-line.price-base no-undo .
define variable     varprice-vat-base               like ub.doc-line.price-base no-undo .
define variable     varprice-no-vat-slt-base        like ub.doc-line.price-base no-undo .
main-block :
do transaction
on error undo main-block, return error
:
run cur-time in this-procedure(output v-today, output start-time).
find first buf_ord-doc no-lock   where  buf_ord-doc.doc-code  =  ub.ord-line.doc-code no-error .
if available buf_ord-doc then do:
    if not  g#news
    and not g#auto
    and not g#esys
    then do:
        find first ub.units no-lock where
                    ub.units.unit-name = ub.ord-line.unit-cli  and
                    lookup('шту':U, ub.units.type) > 0 no-error .
        if available ub.units then do:
            if ub.ord-line.cli-qnty - truncate(ub.ord-line.cli-qnty,0) > 0 then do:
                message "Количество в единицах поставщика " ub.ord-line.unit-cli
                "получилось дробным ! Исправить в меньшую сторону ? " view-as alert-box question
                buttons  yes-no
                update trg-ok as logical
                .
                if trg-ok then ub.ord-line.cli-qnty = truncate(ub.ord-line.cli-qnty,0) .
                else return .
            end.
        end.
    end.
    assign
      ub.ord-line.qnty       =   ub.ord-line.cli-qnty * ub.ord-line.cli-base-rate
      ub.ord-line.price-base =   ub.ord-line.price-rubl / buf_ord-doc.base-rate * buf_ord-doc.base-scale
      ub.ord-line.sum-rubl   =   ub.ord-line.price-rubl * ub.ord-line.qnty
      ub.ord-line.sum-base   =   ub.ord-line.price-base * ub.ord-line.qnty
      ub.ord-line.sum-cli    =   ub.ord-line.price-cli  * ub.ord-line.cli-qnty
    .
    if ub.ord-line.sum-vat = ? then ub.ord-line.sum-vat = 0.
    if buf_ord-doc.vat-type = 'без':U then  do:
       if ub.ord-line.vat-pc <> 0 then ub.ord-line.vat-pc = 0.
    end.
    if buf_ord-doc.slt-type = 'без':U then  do:
       if ub.ord-line.slt-pc <> 0 then ub.ord-line.slt-pc = 0.
    end.
   if buf_ord-doc.vat-type <> 'без':U and
      ub.ord-line.vat-pc <> 0 and
      ub.ord-line.sum-vat = 0 and
      ub.ord-line.qnty <> 0
   then do:
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-r-b
  )  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   'zakaz':u
  ,input   buf_ord-doc.base-rate
  ,input   buf_ord-doc.base-scale
  ,input   buf_ord-doc.exch-rate
  ,input   buf_ord-doc.exch-scale
  ,input   buf_ord-doc.vat-type
  ,input   buf_ord-doc.slt-type
  ,input   ub.ord-line.artic
  ,input   ub.ord-line.prod-type
  ,input   ub.ord-line.prod-code
  ,input   ub.ord-line.price-cli
  ,input   ub.ord-line.cli-base-rate
  ,input   ub.ord-line.price-rubl
  ,input   ub.ord-line.vat-pc
  ,input   ub.ord-line.slt-pc
  ,input   ub.ord-line.road-tax
  ,input   ub.ord-line.transport-rubl
  ,input   ub.ord-line.other-rubl
  ,output  varprice-cli
  ,output  varprice-cli-unit-base
  ,output  varprice-road-tax
  ,output  varprice-other-exp
  ,output  varprice-transport-exp
  ,output  varprice-without-abs
  ,output  varprice-slt
  ,output  varprice-no-slt
  ,output  varprice-vat
  ,output  varprice-no-vat-slt
  ,output  varprice-rubl
  ,output  varprice-road-tax-rubl
  ,output  varprice-other-exp-rubl
  ,output  varprice-transport-exp-rubl
  ,output  varprice-without-abs-rubl
  ,output  varprice-slt-rubl
  ,output  varprice-no-slt-rubl
  ,output  varprice-vat-rubl
  ,output  varprice-no-vat-slt-rubl
  ,output  varprice-base
  ,output  varprice-road-tax-base
  ,output  varprice-other-exp-base
  ,output  varprice-transport-exp-base
  ,output  varprice-without-abs-base
  ,output  varprice-slt-base
  ,output  varprice-no-slt-base
  ,output  varprice-vat-base
  ,output  varprice-no-vat-slt-base
  ) no-error.
        ub.ord-line.sum-vat    = if var-r-b = "rubl" then round(varprice-vat-rubl,2)
                                                     else round(varprice-vat-base,2)
        .
   end.
end.
find first buf_goods no-lock where
           buf_goods.artic = ub.ord-line.artic and
           buf_goods.prod-type = ub.ord-line.prod-type  and
           buf_goods.prod-code = ub.ord-line.prod-code no-error .
if available buf_goods then
assign
  ub.ord-line.gds-code = buf_goods.gds-code
.
  if new(ub.ORD-line) then do:
      create ub.c-ord-line.
      BUFFER-COPY ub.ord-line  TO ub.c-ord-line
      assign
        ub.c-ord-line.chip-num           = next-value (s-corr-chip, ub)
        ub.c-ord-line.corr-time          = start-time
        ub.c-ord-line.corr-user-db-num   = g#db-num
        ub.c-ord-line.corr-user-name     = g#userid
        ub.c-ord-line.corr-date          = v-today
    .
  end.
define buffer old_c-ord-doc for ub.c-ord-doc.
  find first old_c-ord-doc no-lock  where
             old_c-ord-doc.doc-code  =  old_ord-line.doc-code
             no-error .
  if not error-status :error  then do:
  if old_ord-line.qnty <> ub.ord-line.qnty or
     old_ord-line.cli-qnty <> ub.ord-line.cli-qnty or
     old_ord-line.cli-base-rate <> ub.ord-line.cli-base-rate or
     old_ord-line.price-base <> ub.ord-line.price-base or
     old_ord-line.price-rubl <> ub.ord-line.price-rubl or
     old_ord-line.price-cli <> ub.ord-line.price-cli
     then do:
        run cur-time in this-procedure ( output v-today
                                       , output start-time ) .
          create ub.c-ord-line.
          BUFFER-COPY old_ord-line  TO ub.c-ord-line
          assign
            ub.c-ord-line.chip-num           = next-value (s-corr-chip, ub)
            ub.c-ord-line.corr-time          = start-time
            ub.c-ord-line.corr-user-db-num   = g#db-num
            ub.c-ord-line.corr-user-name     = g#userid
            ub.c-ord-line.corr-date          = v-today
        .
         if available buf_ord-doc then do:
          create ub.c-ord-doc.
          BUFFER-COPY buf_ord-doc  TO ub.c-ord-doc
          assign
            ub.c-ord-doc.chip-num           = ub.c-ord-line.chip-num
            ub.c-ord-doc.corr-time          = start-time
            ub.c-ord-doc.corr-user-db-num   = g#db-num
            ub.c-ord-doc.corr-user-name     = g#userid
            ub.c-ord-doc.corr-date          = v-today
        .
        end.
        else do:
          create ub.c-ord-doc.
          BUFFER-COPY old_ord-line TO ub.c-ord-doc
          assign
            ub.c-ord-doc.chip-num           = ub.c-ord-line.chip-num
            ub.c-ord-doc.corr-time          = start-time
            ub.c-ord-doc.corr-user-db-num   = g#db-num
            ub.c-ord-doc.corr-user-name     = g#userid
            ub.c-ord-doc.corr-date          = v-today
        .
        end.
     end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'update':U
        , input 'ord-line':U
        , input ( buffer ub.ord-line:handle )
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
