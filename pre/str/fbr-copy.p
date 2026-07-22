block-level on error undo, throw.
define input parameter parparentproc            as handle           no-undo.
define input parameter p-fbr-doc-doc-code       as character        no-undo.
define input parameter p-trn-doc-doc-code       as character        no-undo.
define input parameter p-fbr-doc-obj-type       as character        no-undo.
define input parameter p-fbr-doc-obj-code       as integer          no-undo.
define input parameter p-price-sale-obj-type    as character        no-undo.
define input parameter p-price-sale-obj-code    as integer          no-undo.
define input parameter p-fbrhist-handle         as handle           no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Копирование накладной в документ производства.".
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
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    def var log-file-name as char no-undo.
    if search('fbr.log') = ?
    then do:
        assign
            log-file-name = ""
        .
    end.
    else do:
        assign
            log-file-name = 'fbr.log'
        .
    end.
    DEF STREAM stm-log.
    PROCEDURE writelog:
    DEF INPUT PARAMETER p-file-name AS CHAR     NO-UNDO.
    DEF INPUT PARAMETER p-log-level AS INTEGER  NO-UNDO.
    DEF INPUT PARAMETER p-log-string  AS CHAR     NO-UNDO.
    if p-file-name <> ""
    then do:
    OUTPUT STREAM stm-log TO VALUE(p-file-name) APPEND.
        PUT STREAM stm-log UNFORMATTED chr(10).
        PUT STREAM stm-log UNFORMATTED (IF (p-log-level = 0 OR p-log-string = "&DLine"
                                        OR p-log-string = "&Line") THEN "" ELSE
                                        cur-time-string-sec() + " ").
        PUT STREAM stm-log UNFORMATTED
                (IF p-log-string = "&Line" THEN FILL("-", 80)
                ELSE IF p-log-string = "&DLine" THEN FILL("=", 80)
                ELSE fill(" ", p-log-level * 2) + p-log-string).
    OUTPUT STREAM stm-log CLOSE.
    end.
    END PROCEDURE.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table tt0-info no-undo
field doc-code   like ub.trn-doc.doc-code
field artic      like ub.doc-line.artic
field prod-type  like ub.doc-line.prod-type
field prod-code  like ub.doc-line.prod-code
field prt-code  like ub.gds-dtl.prt-code
field obj-type   like ub.doc-line.obj-type
field obj-code   like ub.doc-line.obj-code
field error-message as character
field a-to-res as decimal
field was-res as decimal
field to-res as decimal
field is-res as decimal
field o-was-res as decimal
field o-to-res as decimal
field o-is-res as decimal
index pi is unique primary
obj-type
obj-code
artic
prod-type
prod-code
index iartic
artic
prod-type
prod-code
.
define NEW SHARED temp-table tt0-doc-line no-undo like lib-trn_ret-line.
define NEW SHARED temp-table tt0-gds-dtl  no-undo like ub.gds-dtl.
define NEW SHARED temp-table tt0-parts    no-undo like ub.parts.
define NEW SHARED temp-table temp-tpsi-clients  no-undo like ub.clients.
FUNCTION set-tpsi-doc-PS returns character( buffer buf_sale-doc for ub.sale-doc):
define variable v-ps as character no-undo .
assign
v-PS = substitute('@&1 для закрытия продажи &2 на &3&4&5товаров &6&5признаков &7'
                  , entry (lookup (buf_sale-doc.ext-doc-type, 'ee,ev,ie,es,iv':U), 'Межфирм.расход по ТПСИ,Внутр.расход по ТПСИ,Межфирм.приход по ТПСИ,Внутр.приход по ТПСИ':U)
                  , buf_sale-doc.out-code
                  , buf_sale-doc.obj-type
                  , buf_sale-doc.obj-code
                  , chr(4)
                  , buf_sale-doc.tot-lines
                  , buf_sale-doc.tot-dtl
                  ).
return v-Ps.
END FUNCTION.
procedure create-tt0-doc-line-gds-dtl :
define input parameter p-proprietor-obj-type like ub.trn-doc.obj-type no-undo .
define input parameter p-proprietor-obj-code like ub.trn-doc.obj-code no-undo .
define input parameter p-ext-doc-type        as character no-undo .
define input parameter p-doc-code            like ub.trn-doc.doc-code no-undo .
define input parameter p-artic               like ub.gds-dtl.artic no-undo .
define input parameter p-prod-type           like ub.gds-dtl.prod-type no-undo .
define input parameter p-prod-code           like ub.gds-dtl.prod-code no-undo .
define input parameter p-prt-code            like ub.gds-dtl.prt-code  no-undo .
define input parameter p-fact-qnty           like ub.gds-dtl.fact-qnty no-undo .
define output parameter p-was-gds-dtl-doc-qnty  like ub.gds-dtl.fact-qnty no-undo .
define output parameter p-gds-dtl-fact-qnty  like ub.gds-dtl.fact-qnty no-undo .
define parameter buffer b-doc-line           for ub.doc-line.
define parameter buffer b-gds-dtl            for ub.gds-dtl.
define parameter buffer buf_sale-doc for ub.sale-doc.
define variable old-qnty like ub.doc-line.fact-qnty no-undo .
define buffer other_doc-line for ub.doc-line.
define buffer other_gds-dtl for ub.gds-dtl.
  do
  on error undo, return error return-value
  :
    find first tt0-doc-line where
              tt0-doc-line.obj-type = p-proprietor-obj-type
          AND tt0-doc-line.obj-code = p-proprietor-obj-code
          AND tt0-doc-line.prod-type = p-prod-type
          AND tt0-doc-line.prod-code = p-prod-code
          AND tt0-doc-line.artic     = p-artic
          AND tt0-doc-line.ext-doc-type = p-ext-doc-type
          AND tt0-doc-line.status_      = 'нередакт':U no-error .
    if not available tt0-doc-line then do:
      create tt0-doc-line.
      buffer-copy b-doc-line
      except
      obj-type obj-code doc-code status_ ext-doc-type doc-qnty fact-qnty
      to tt0-doc-line
      assign
      tt0-doc-line.status_ = 'нередакт':U
      tt0-doc-line.ext-doc-type = p-ext-doc-type
      tt0-doc-line.obj-type = p-proprietor-obj-type
      tt0-doc-line.obj-code = p-proprietor-obj-code
      tt0-doc-line.doc-code = p-doc-code
      .
    end.
    if p-doc-code <> "":U then do:
      find first other_doc-line no-lock where
              other_doc-line.doc-code = p-doc-code
          AND  other_doc-line.artic    = p-artic
          AND  other_doc-line.prod-type = p-prod-type
          AND  other_doc-line.prod-code = p-prod-code no-error .
      if available other_doc-line then do:
        find first buf_sale-doc where buf_sale-doc.doc-code = other_doc-line.doc-code.
        assign
        tt0-doc-line.doc-qnty = other_doc-line.doc-qnty
        .
      end.
      else do:
        assign
        tt0-doc-line.doc-code = '':U
        .
      end.
    end.
    find first tt0-gds-dtl where
            tt0-gds-dtl.obj-type = p-proprietor-obj-type
        AND tt0-gds-dtl.obj-code = p-proprietor-obj-code
        AND tt0-gds-dtl.prod-type = p-prod-type
        AND tt0-gds-dtl.prod-code = p-prod-code
        AND tt0-gds-dtl.artic     = p-artic
        AND tt0-gds-dtl.prt-code  = p-prt-code  no-error .
    if not available tt0-gds-dtl then do:
      create tt0-gds-dtl.
      buffer-copy b-gds-dtl
      except
      obj-type obj-code doc-code doc-qnty fact-qnty
      to tt0-gds-dtl
      assign
      tt0-gds-dtl.obj-type = p-proprietor-obj-type
      tt0-gds-dtl.obj-code = p-proprietor-obj-code
      tt0-gds-dtl.doc-code = p-doc-code
      .
    end.
    if p-doc-code <> "":U then do:
        find first other_gds-dtl no-lock where
                other_gds-dtl.doc-code = p-doc-code
            AND  other_gds-dtl.artic    = p-artic
            AND  other_gds-dtl.prod-type    = p-prod-type
            AND  other_gds-dtl.prod-code    = p-prod-code
            AND  other_gds-dtl.prt-code    = p-prt-code no-error .
        if available other_gds-dtl then do:
          assign
          tt0-gds-dtl.doc-qnty = other_gds-dtl.doc-qnty
          .
        end.
        else do:
          assign
          tt0-gds-dtl.doc-code = '':U
          .
        end.
    end.
    assign
    old-qnty = tt0-gds-dtl.doc-qnty
    tt0-gds-dtl.fact-qnty = (if p-fact-qnty = ? then (- old-qnty) else (p-fact-qnty - tt0-gds-dtl.doc-qnty))
    tt0-doc-line.fact-qnty = tt0-doc-line.fact-qnty + (if p-fact-qnty = ? then (- old-qnty) else p-fact-qnty)
    p-gds-dtl-fact-qnty = tt0-gds-dtl.fact-qnty
    p-was-gds-dtl-doc-qnty = tt0-gds-dtl.doc-qnty
    .
  end.
end procedure.
procedure fill-tt-tpsi-table :
define input parameter p-doc-code  like ub.trn-doc.doc-code  no-undo .
define input parameter p-host-code like ub.trn-doc.host-code no-undo .
define input parameter p-obj-type  like ub.trn-doc.obj-type  no-undo .
define input parameter p-obj-code  like ub.trn-doc.obj-code  no-undo .
define variable v-proprietor-host-code      like ub.clients.host-code no-undo .
define variable v-proprietor-obj-type       like ub.clients.obj-type no-undo .
define variable v-proprietor-obj-code       like ub.clients.obj-code no-undo .
define variable v-ext-doc-type              like ub.trn-doc.ext-doc-type no-undo .
define variable v-gds-dtl-fact-qnty         like ub.gds-dtl.fact-qnty no-undo .
define variable v-was-gds-dtl-fact-qnty     like ub.gds-dtl.fact-qnty no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_sale-doc for ub.sale-doc.
  do
  on error undo, return error
  :
    _doc-line:
    for each buf_Doc-line no-lock where
          buf_doc-line.doc-code = p-doc-code,
      first buf_goods no-lock where
          buf_goods.artic = buf_doc-line.artic
     AND  buf_goods.prod-type  = buf_doc-line.prod-type
     AND  buf_goods.prod-code  = buf_doc-line.prod-code,
        each buf_gds-dtl no-lock where
          buf_gds-dtl.doc-code = buf_doc-line.doc-code
      AND  buf_gds-dtl.artic    = buf_doc-line.artic
      AND  buf_gds-dtl.prod-type = buf_doc-line.prod-type
      AND  buf_gds-dtl.prod-code = buf_doc-line.prod-code:
      assign
      v-ext-doc-type = "":U.
      run tpsi-preselect-gds-proprietor in this-procedure (
                                                  input buf_goods.gds-code
                                                ,input g#db-num
                                                ,output v-proprietor-host-code
                                                ,output v-proprietor-obj-type
                                                ,output v-proprietor-obj-code ) no-error .
      if v-proprietor-host-code = p-host-code then do:
        assign
        v-ext-doc-type = 'ev':U .
      end.
      else do:
        assign
        v-ext-doc-type =  'ee':U .
      end.
      if  (v-proprietor-obj-type = p-obj-type
      AND v-proprietor-obj-code = p-obj-code)
      OR (v-proprietor-obj-type = "":U
      AND v-proprietor-obj-code = 0)
      OR v-proprietor-obj-code = ?
      then next _doc-line.
      find first buf_sale-doc no-lock where
                buf_sale-doc.inkas-code = p-doc-code
           AND buf_sale-doc.obj-type = v-proprietor-obj-type
           AND buf_sale-doc.obj-code = v-proprietor-obj-code
           AND buf_sale-doc.ext-doc-type = v-ext-doc-type
           no-error .
      run create-tt0-doc-line-gds-dtl  in this-procedure (
                                                           input v-proprietor-obj-type
                                                          ,input v-proprietor-obj-code
                                                          ,input v-ext-doc-type
                                                          ,input (if available buf_sale-doc then buf_sale-doc.doc-code else "":U)
                                                          ,input buf_doc-line.artic
                                                          ,input buf_Doc-line.prod-type
                                                          ,input buf_doc-line.prod-code
                                                          ,input buf_gds-dtl.prt-code
                                                          ,input 0
                                                          ,output v-was-gds-dtl-fact-qnty
                                                          ,output v-gds-dtl-fact-qnty
                                                          ,buffer buf_doc-line
                                                          ,buffer buf_gds-dtl
                                                          ,buffer buf_sale-doc
                                                        ).
    end.
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure get-alias-type-price-obj :
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-prop-host-code like ub.sysconf.host-code no-undo .
define input parameter p-prop-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-prop-obj-code  like ub.clients.obj-code no-undo .
define output parameter p-ext-doc-type like ub.trn-doc.ext-doc-type no-undo .
define output parameter p-alias-type-price as character no-undo .
define output parameter p-price-obj-type like ub.clients.obj-type no-undo .
define output parameter p-price-obj-code like ub.clients.obj-code no-undo .
define variable v-mediat-obj-type           like ub.trn-doc.obj-type no-undo .
define variable v-mediat-obj-code           like ub.trn-doc.obj-code no-undo .
define variable v-mediat-objf               as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define buffer buf_trn-doc for ub.trn-doc.
  _main:
  do
  on error undo, return error return-value
  :
    run adm/shattri.p (
      input "get":U
      ,input  p-prop-obj-type
      ,input  p-prop-obj-code
      ,input  'alias-tpsi':U
      ,input  '':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
    if error-status:error
    then do:
      undo _main, return error substitute("Не удалось определить настройки МЕЖФИРМЕННОГО ИЛИ ВНУТРЕННЕГО ПЕРЕМЕЩЕНИЯ ЧУЖИХ ТОВАРОВ для &1&2"
                              , p-prop-obj-type
                              , p-prop-obj-code).
    end.
    find first thbjattr_thbj-attr where
              thbjattr_thbj-attr.obj-type = p-prop-obj-type
          and thbjattr_thbj-attr.obj-code = p-prop-obj-code
          and thbjattr_thbj-attr.upper-prop-code = 'alias-tpsi':U
          and thbjattr_thbj-attr.prop-code = 'alias-type-price':U no-error.
    if not available thbjattr_thbj-attr
    or thbjattr_thbj-attr.property-value-integer = 0 then do:
      undo _main, return error substitute("Не задано значение атрибута ТИП ЦЕНЫ МЕЖФИРМЕННОГО ИЛИ ВНУТРЕННЕГО ПЕРЕМЕЩЕНИЯ ЧУЖИХ ТОВАРОВ для &1&2"
                              , p-prop-obj-type
                              , p-prop-obj-code).
    end.
    assign
    p-alias-type-price = string(thbjattr_thbj-attr.property-value-integer).
    if p-prop-host-code = p-host-code
    and (p-alias-type-price = '':U
    or   p-alias-type-price <> '5':U)
    then  do:
      assign
      p-ext-doc-type = 'ev':U
      p-price-obj-type = p-obj-type
      p-price-obj-code = p-obj-code
      p-alias-type-price = '3':U
      .
    end.
    else do:
      if p-prop-host-code = p-host-code  then do:
        assign
        p-ext-doc-type = 'ev':U
        p-price-obj-type = p-obj-type
        p-price-obj-code = p-obj-code
        .
      end.
      else do:
        assign
        p-ext-doc-type = 'ee':U.
        assign
        v-mediat-obj-type = "":U
        v-mediat-obj-code = 0
        v-mediat-objf = "":U
        .
        if p-alias-type-price = '4':U then do:
          find first thbjattr_thbj-attr where
                    thbjattr_thbj-attr.obj-type = p-prop-obj-type
                and thbjattr_thbj-attr.obj-code = p-prop-obj-code
                and thbjattr_thbj-attr.upper-prop-code = 'alias-tpsi':U
                and thbjattr_thbj-attr.prop-code = 'alias-object-price':U no-error.
          if not available thbjattr_thbj-attr
          or thbjattr_thbj-attr.property-value-character = "":U then do:
            undo _main, return error substitute("Не найден объект-посредник для межфирменного перемещения ЧУЖИХ товаров с &1&2"
                                    , p-prop-obj-type
                                    , p-prop-obj-code).
          end.
          assign
          v-mediat-objf     = thbjattr_thbj-attr.property-value-character
          v-mediat-obj-type = entry(1, v-mediat-objf)
          v-mediat-obj-code = integer(entry(2, v-mediat-objf))
          no-error
          .
          if error-status:error then do:
            undo _main, return error substitute("Неверный формат атрибута ОБЪЕКТ-ПОСРЕДНИК для межфирменного перемещения ЧУЖИХ товаров для &1&2"
                                    , p-prop-obj-type
                                    , p-prop-obj-code).
          end.
        end.
        CASE p-alias-type-price:
          when '1':U then do:
            assign
            p-price-obj-type = p-prop-obj-type
            p-price-obj-code = p-prop-obj-code
            .
          end.
          when '2':U then do:
            assign
            p-price-obj-type = p-prop-obj-type
            p-price-obj-code = p-prop-obj-code
            .
          end.
          when '3':U
          or
          when '5':U
          then do:
            assign
            p-price-obj-type = p-obj-type
            p-price-obj-code = p-obj-code
            .
          end.
          when '4':U then do:
            assign
            p-price-obj-type = v-mediat-obj-type
            p-price-obj-code = v-mediat-obj-code
            .
          end.
        END CASE.
      end.
    end.
  end.
end procedure.
procedure write-tt0-info:
define input parameter p-artic as character no-undo .
define input parameter p-prod-type as character no-undo .
define input parameter p-prod-code as integer no-undo .
define input parameter p-prt-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-from-tpsi as logical no-undo .
define input parameter p-all-qnty as decimal no-undo .
define input parameter p-was-res as decimal no-undo .
define input parameter p-to-res as decimal no-undo .
define input parameter p-is-res as decimal no-undo .
define input parameter p-o-was-res as decimal no-undo .
define input parameter p-o-to-res as decimal no-undo .
define input parameter p-o-is-res as decimal no-undo .
define input parameter p-mess   as character no-undo .
define buffer buf_tt0-info for tt0-info.
  do
  on error undo, return error return-value
  :
    find first buf_tt0-info where
             buf_tt0-info.artic = p-artic
         and buf_tt0-info.prod-type = p-prod-type
         and buf_tt0-info.prod-code = p-prod-code
         and buf_tt0-info.prt-code = p-prt-code
         no-error .
    if not available buf_tt0-info then do:
      create buf_tt0-info.
      assign
      buf_tt0-info.artic = p-artic
      buf_tt0-info.prod-type = p-prod-type
      buf_tt0-info.prod-code = p-prod-code
      buf_tt0-info.prt-code  = p-prt-code
      buf_tt0-info.obj-type  = p-obj-type
      buf_tt0-info.obj-code  = p-obj-code
      buf_tt0-info.a-to-res  = ?
      buf_tt0-info.to-res    = ?
      buf_tt0-info.was-res   = ?
      buf_tt0-info.o-was-res = ?
      buf_tt0-info.o-to-res  = ?
      buf_tt0-info.o-is-res  = ?
      buf_tt0-info.is-res    = ?
      .
    end.
    assign
    buf_tt0-info.a-to-res  =
                              (if buf_tt0-info.a-to-res <> ?
                              and p-all-qnty = ?
                              then buf_tt0-info.a-to-res
                              else p-all-qnty)
    buf_tt0-info.was-res   = (if buf_tt0-info.was-res <> ?
                              and p-was-res = ?
                              then buf_tt0-info.was-res
                              else p-was-res)
    buf_tt0-info.to-res    = (if buf_tt0-info.to-res <> ?
                              and p-to-res = ?
                              then buf_tt0-info.to-res
                              else p-to-res)
    buf_tt0-info.is-res    = (if buf_tt0-info.is-res <> ?
                              and p-is-res = ?
                              then buf_tt0-info.is-res
                              else p-is-res)
    buf_tt0-info.o-was-res   = (if buf_tt0-info.o-was-res <> ?
                              and p-o-was-res = ?
                              then buf_tt0-info.o-was-res
                              else p-o-was-res)
    buf_tt0-info.o-to-res    = (if buf_tt0-info.o-to-res <> ?
                              and p-o-to-res = ?
                              then buf_tt0-info.o-to-res
                              else p-o-to-res)
    buf_tt0-info.o-is-res    = (if buf_tt0-info.o-is-res <> ?
                              and p-o-is-res = ?
                              then buf_tt0-info.o-is-res
                              else p-o-is-res)
    .
    assign
    buf_tt0-info.doc-code  = p-doc-code
    buf_tt0-info.error-message   = p-mess
    .
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new SHARED temp-table dtl-rests no-undo
field b-code like ub.bar-code.b-code
field artic like ub.gds-dtl.artic
field prod-type like ub.gds-dtl.prod-type
field prod-code like ub.gds-dtl.prod-code
field gds-code like ub.goods.gds-code
field prt-code like ub.gds-dtl.prt-code
field unit-base like ub.goods.unit-base
field rest-fact-qnty as decimal
field maybe-qnty as decimal
field prt-qnty as decimal
field free-qnty as decimal
field need-qnty as decimal
field gds-name like ub.goods.gds-name
field OK as logical column-label "ОК"
FIELD fbr as integer
field prop as integer
field is-neg-tpsi-oper as logical
field weight as logical
field is-neg-tpsi-qnty as logical
field is-neg-tpsi-weight as logical
field ok-prop as logical
field is-neg-rest as logical
field to-view as logical
index   pi  is primary
gds-code
prt-code ASCENDING
index   bc
b-code ASCENDING
index ifbr fbr
index iprop prop
index iok ok
index iokprop ok-prop
index iview to-view
.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table dtl-rests-mark no-undo
field artic like ub.gds-dtl.artic
field prod-type like ub.gds-dtl.prod-type
field prod-code like ub.gds-dtl.prod-code
index   pi  is primary
artic
prod-type
prod-code
.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-parts no-undo   like ub.parts   field free-qnty as decimal   field free-cli-qnty as decimal .
procedure partslib-clear-temp-parts :
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error
  :
    for each buf_temp-parts
    on error undo, return error
    :
      delete buf_temp-parts .
    end.
  end.
end procedure.
procedure partslib-create-temp-parts :
  define parameter buffer buf_parts       for ub.parts .
  define parameter buffer buf_temp-parts  for temp-parts .
  define input  parameter p-goods-twounit as logical   no-undo .
  define variable v-base-part-code as character no-undo .
  do
  on error undo, return error
  :
    if p-goods-twounit = true
    then do:
      assign
        v-base-part-code = entry(1, buf_parts.part-code, '#':U)
      .
    end.
    else do:
      assign
        v-base-part-code = buf_parts.part-code
      .
    end.
    find first buf_temp-parts exclusive-lock
      where buf_temp-parts.obj-type  = buf_parts.obj-type
        and buf_temp-parts.obj-code  = buf_parts.obj-code
        and buf_temp-parts.artic     = buf_parts.artic
        and buf_temp-parts.prod-type = buf_parts.prod-type
        and buf_temp-parts.prod-code = buf_parts.prod-code
        and buf_temp-parts.in-code   = buf_parts.in-code
        and buf_temp-parts.out-code  = 'free-zone':U
        and buf_temp-parts.part-code = v-base-part-code
      no-error.
    if not available buf_temp-parts
    then do:
      create buf_temp-parts .
      buffer-copy buf_parts to buf_temp-parts
      assign
        buf_temp-parts.out-code  = 'free-zone':U
        buf_temp-parts.part-code = v-base-part-code
        buf_temp-parts.rsrv-free = yes
        buf_temp-parts.status_   = no
        buf_temp-parts.qnty      = 0
        buf_temp-parts.fact-qnty = 0
        buf_temp-parts.real-qnty = 0
        buf_temp-parts.cli-qnty  = 0
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run partslib-clear-temp-parts in this-procedure .
    for each buf_parts
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.rsrv-free = yes
        and buf_parts.status_   = no
        and buf_parts.in-code   <> buf_parts.out-code
    on error undo, return error
    :
      run partslib-create-temp-parts in this-procedure
        (buffer buf_parts
        ,buffer buf_temp-parts
        ,input  v-goods-twounit
        ) .
      define variable v-parts-qnty          as decimal   no-undo .
      define variable v-parts-cli-qnty      as decimal   no-undo .
      define variable v-parts-free-qnty     as decimal   no-undo .
      define variable v-parts-free-cli-qnty as decimal   no-undo .
      if buf_parts.out-code = 'free-zone':U
      then do:
        assign
          v-parts-qnty          = buf_parts.qnty
          v-parts-cli-qnty      = buf_parts.cli-qnty
          v-parts-free-qnty     = buf_parts.qnty
          v-parts-free-cli-qnty = buf_parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty          = abs(buf_parts.qnty)
          v-parts-cli-qnty      = abs(buf_parts.cli-qnty)
          v-parts-free-qnty     = 0
          v-parts-free-cli-qnty = 0
        .
      end.
      assign
        buf_temp-parts.qnty          = buf_temp-parts.qnty          + v-parts-qnty
        buf_temp-parts.fact-qnty     = buf_temp-parts.fact-qnty     + v-parts-qnty
        buf_temp-parts.real-qnty     = 0
        buf_temp-parts.cli-qnty      = buf_temp-parts.cli-qnty      + v-parts-cli-qnty
        buf_temp-parts.free-qnty     = buf_temp-parts.free-qnty     + v-parts-free-qnty
        buf_temp-parts.free-cli-qnty = buf_temp-parts.free-cli-qnty + v-parts-free-cli-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  do
  on error undo, return error
  :
    do transaction
    on error undo, return error
    :
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info9 skip
          "Невозможно найти товар на объекте" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run partslib-init-temp-parts in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-include-fact-order = true
    then do:
      assign
        p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    define variable v-max-fact-order as character no-undo .
    run factord-max-fact-order in this-procedure
      (output v-max-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-update-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input p-fact-order
      ,input v-max-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при вызове процедуры partslib-update-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        "v-max-fact-order" v-max-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-update-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-start-fact-order   as decimal   no-undo .
  define input parameter p-end-fact-order     as decimal   no-undo .
  define input parameter p-lock-gds-obj       as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .
  define variable v-total-parts-qnty as decimal   no-undo .
  define variable v-goods-gds-goods  as logical   no-undo .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
    if p-start-fact-order > p-end-fact-order
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка задания входных параметров" skip
        "Начало интервала превышает конец интервала" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-start-fact-order" p-start-fact-order skip
        "p-end-fact-order"   p-end-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-lock-gds-obj = true
    then do:
      do transaction
      on error undo, return error
      :
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info9 skip
            "Невозможно найти gds-obj" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        find current buf_gds-obj exclusive-lock .
      end.
    end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'gds-goods=request':u
  ,output v-goods-gds-goods
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-goods=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order > p-start-fact-order
        and buf_doc-line.fact-order <= p-end-fact-order
    on error undo, return error
    :
      run partslib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,input  v-goods-gds-goods
        ,input  v-goods-twounit
        ,output v-total-parts-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info9 skip
          "Ошибка при вызове процедуры partslib-process-document" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-start-fact-order" p-start-fact-order skip
          "p-end-fact-order" p-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure partslib-process-document :
  define input  parameter p-doc-code         as character no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-artic            as character no-undo .
  define input  parameter p-prod-type        as character no-undo .
  define input  parameter p-prod-code        as integer   no-undo .
  define input  parameter p-goods-gds-goods  as logical   no-undo .
  define input  parameter p-goods-twounit    as logical   no-undo .
  define output parameter p-total-parts-qnty as decimal   no-undo .
  define variable v-parts-sign as integer   no-undo .
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      undo, return error substitute("Ошибка при поиске документа. Документ &1"
                                   ,p-doc-code
                                   ) .
    end.
    case buf_trn-doc.doc-type
    :
      when 'при':U or
      when 'возврат':U or
      when 'инв':U
      then do:
        assign
          v-parts-sign = -1
        .
      end.
      when 'рас':U or
      when 'спи':U
      then do:
        assign
          v-parts-sign = 1
        .
      end.
      otherwise do:
        undo, return error substitute("Неизвестный тип документа &1"
                                    ,buf_trn-doc.doc-type
                                    ) .
      end.
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      undo, return error substitute("Ошибка при поиске строки документа. Документ &1. Артикул &2 &3 &4"
                                   ,p-doc-code
                                   ,artic
                                   ,prod-type
                                   ,prod-code
                                   ) .
    end.
    assign
      p-total-parts-qnty = 0
    .
    if p-goods-gds-goods = true
    then do:
      for each buf_parts no-lock
        where buf_parts.out-code  = p-doc-code
          and buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
      on error undo, return error
      :
        run partslib-create-temp-parts in this-procedure
          (buffer buf_parts
          ,buffer buf_temp-parts
          ,input  p-goods-twounit
          ) .
        assign
          p-total-parts-qnty        = p-total-parts-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.qnty       = buf_temp-parts.qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.fact-qnty  = buf_temp-parts.fact-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.cli-qnty   = buf_temp-parts.cli-qnty
                                    + v-parts-sign * buf_parts.cli-qnty
        .
        if buf_temp-parts.qnty = 0
        then do:
          delete buf_temp-parts .
        end.
      end.
    end.
    else do:
      assign
        p-total-parts-qnty = p-total-parts-qnty
                           + v-parts-sign * buf_doc-line.fact-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-date :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define input parameter p-fact-date       as date      no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-date: определение партий свободной зоны на любую дату".
  do
  on error undo, return error
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-init-temp-parts-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при вызове метода partslib-init-temp-parts-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-calc-cost :
  define output parameter p-fact-qnty      as decimal   no-undo .
  define output parameter p-vat-pc         as decimal   no-undo .
  define output parameter p-slt-pc         as decimal   no-undo .
  define output parameter p-sum-base       as decimal   no-undo .
  define output parameter p-sum-rubl       as decimal   no-undo .
  define output parameter p-vat-base       as decimal   no-undo .
  define output parameter p-vat-rubl       as decimal   no-undo .
  define output parameter p-slt-base       as decimal   no-undo .
  define output parameter p-slt-rubl       as decimal   no-undo .
  define output parameter p-road-tax-base  as decimal   no-undo .
  define output parameter p-road-tax-rubl  as decimal   no-undo .
  define output parameter p-transport-base as decimal   no-undo .
  define output parameter p-transport-rubl as decimal   no-undo .
  define output parameter p-other-base     as decimal   no-undo .
  define output parameter p-other-rubl     as decimal   no-undo .
  define output parameter p-excise-base    as decimal   no-undo .
  define output parameter p-excise-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "partslib-calc-cost: расчет сумм в учетных ценах".
  do
  on error undo, return error return-value
  :
    define buffer buf_temp-parts for temp-parts .
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    for each buf_temp-parts
    on error undo, return error
    :
assign
  price-rubl-with-tax-loc = buf_temp-parts.price-rubl
  price-base-with-tax-loc = buf_temp-parts.price-base
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_temp-parts.out-code = 'free-zone':U     or
     buf_temp-parts.out-code = 'out-zone':U   or
     buf_temp-parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_temp-parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_temp-parts.price-cli
   cli-base-rate          = buf_temp-parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_temp-parts.road-tax-base  = ? then 0 else buf_temp-parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_temp-parts.road-tax-rubl  = ? then 0 else buf_temp-parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_temp-parts.transport-base = ? then 0 else buf_temp-parts.transport-base)
          transport-rubl-loc = (if buf_temp-parts.transport-rubl = ? then 0 else buf_temp-parts.transport-rubl)
          other-base-loc     = (if buf_temp-parts.other-base     = ? then 0 else buf_temp-parts.other-base)
          other-rubl-loc     = (if buf_temp-parts.other-rubl     = ? then 0 else buf_temp-parts.other-rubl)
          vat-pc-loc         = (if buf_temp-parts.vat-pc         = ? then 0 else buf_temp-parts.vat-pc)
          slt-pc-loc         = (if buf_temp-parts.slt-pc         = ? then 0 else buf_temp-parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_temp-parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_temp-parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_temp-parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_temp-parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
      assign
        p-fact-qnty      = p-fact-qnty      + buf_temp-parts.fact-qnty
        p-vat-pc         = p-vat-pc         + vat-pc-loc
        p-slt-pc         = p-slt-pc         + slt-pc-loc
        p-sum-base       = p-sum-base       + price-base-with-tax-loc * buf_temp-parts.fact-qnty
        p-sum-rubl       = p-sum-rubl       + price-rubl-with-tax-loc * buf_temp-parts.fact-qnty
        p-vat-base       = p-vat-base       + vat-base-loc            * buf_temp-parts.fact-qnty
        p-vat-rubl       = p-vat-rubl       + vat-rubl-loc            * buf_temp-parts.fact-qnty
        p-slt-base       = p-slt-base       + slt-base-loc            * buf_temp-parts.fact-qnty
        p-slt-rubl       = p-slt-rubl       + slt-rubl-loc            * buf_temp-parts.fact-qnty
        p-road-tax-base  = p-road-tax-base  + road-tax-base-loc       * buf_temp-parts.fact-qnty
        p-road-tax-rubl  = p-road-tax-rubl  + road-tax-rubl-loc       * buf_temp-parts.fact-qnty
        p-transport-base = p-transport-base + transport-base-loc      * buf_temp-parts.fact-qnty
        p-transport-rubl = p-transport-rubl + transport-rubl-loc      * buf_temp-parts.fact-qnty
        p-other-base     = p-other-base     + other-base-loc          * buf_temp-parts.fact-qnty
        p-other-rubl     = p-other-rubl     + other-rubl-loc          * buf_temp-parts.fact-qnty
        p-excise-base    = p-excise-base    + 0
        p-excise-rubl    = p-excise-rubl    + 0
      .
    end.
    if p-fact-qnty      = ?
    or p-sum-base       = ?
    or p-sum-rubl       = ?
    or p-vat-base       = ?
    or p-vat-rubl       = ?
    or p-slt-base       = ?
    or p-slt-rubl       = ?
    or p-road-tax-base  = ?
    or p-road-tax-rubl  = ?
    or p-transport-base = ?
    or p-transport-rubl = ?
    or p-other-base     = ?
    or p-other-rubl     = ?
    or p-excise-base    = ?
    or p-excise-rubl    = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Программа in-vatp.i вернула неопределенные значения" skip
        "p-fact-qnty"      p-fact-qnty      skip
        "p-sum-base"       p-sum-base       skip
        "p-sum-rubl"       p-sum-rubl       skip
        "p-vat-base"       p-vat-base       skip
        "p-vat-rubl"       p-vat-rubl       skip
        "p-slt-base"       p-slt-base       skip
        "p-slt-rubl"       p-slt-rubl       skip
        "p-road-tax-base"  p-road-tax-base  skip
        "p-road-tax-rubl"  p-road-tax-rubl  skip
        "p-transport-base" p-transport-base skip
        "p-transport-rubl" p-transport-rubl skip
        "p-other-base"     p-other-base     skip
        "p-other-rubl"     p-other-rubl     skip
        "p-excise-base"    p-excise-base    skip
        "p-excise-rubl"    p-excise-rubl    skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
define temp-table tt-utd like ub.utd
  field stts        as character
  field stts-edi    as character
  field cli-name    as character
  field EDoTypeName as character
  field ModifyTime_ as character
  field orig-code   as character
  field GrayZone    as logical
  field obj-name    as character
  field is-initial  as character
  field scan-qnty   as decimal
  field free-qnty   as decimal
  .
define temp-table tt-sert-utd
  field doc-id like ub.utd.doc-id
  field db-num like ub.utd.db-num
  field DocumentDate like ub.utd.DocumentDate
  field DocumentNumber like ub.utd.DocumentNumber
  field cli-code as integer
  field cli-type as character
  index pi  db-num doc-id
  .
define temp-table tt-utd-lines-filtr no-undo
    field db-num  as integer
    field doc-id  as integer
    field linenum as integer
    field bar-code as character
    index pi  db-num doc-id LineNum
    index bar-code bar-code db-num doc-id LineNum
.
define temp-table tt-utd-lines like ub.utd-lines
  field qnty-scan as decimal
  field qnty-mark as integer
  field stts      as character
  field gds-name  as character
  field TaxRate_  as character
  field fact-qnty as decimal
  field free-qnty as decimal
  field sts_err   as logical
  field DelivCodeMis   as logical
  field UnitCli   as character
  field UnitCliQnty as decimal
  field isMarking   as logical
  field isArtic     as logical
  field isWeight    as logical
  field isVarWeight as logical
  field isSelect    as logical
  field markType    as character
  field PieceTTH    as character
  field PieceFact   as character
  index pi  db-num doc-id LineNum
  index gds-code gds-code
  index sts stts sts
  .
define temp-table tt-marking-lines no-undo like ub.marking-lines
  field mark-parent like ub.marking.mark-parent
  field stts        as character
  field sts-utd     as integer
  field stts-utd    as character
  field unit        as character
  field unit-ext    as character
  field site        as character
  field box-qnty    as decimal
  field gds-name    as character
  field db-num      as integer
  field doc-id      as integer
  field LineNum     as integer
  field GrayZone    as logical
  field isMark      as logical
  field isWeight    as logical
  field marking-string as character
  field old-sts     as integer
  field weight      as character
  index pi  doc-level   sts
  index pi2 mark-parent sts
  index pi3 unit-ext
  index pi4 mark obj-type obj-code gds-code in-code out-code part-code prt-code
  index part gds-code obj-type obj-code in-code out-code part-code prt-code
  index gds-code gds-code
  index obj obj-code obj-type
  .
define temp-table tt-mark-line like ub.marking-lines
  field date_    as date
  field doc-type as character
  field type     as integer
  field doc-id   as integer
  field db-num   as integer
  field EdocType as integer
  index pi mark out-code doc-type .
define temp-table tt-marking like ub.marking
  .
define temp-table tt-utd-marking-lines like ub.utd-marking-lines
  .
define temp-table tt-inv-marking no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty          as decimal
  field qnty-scan     as decimal
  field qnty-confirm  as integer
  field qnty-scan-not as integer
  field qnty-not      as integer
  index pi gds-code
  .
define temp-table tt-tech-mark no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty-fact     as integer
  field qnty-doc      as integer
  field doc-code      as character
  field line-num      as integer
  index pi as UNIQUE doc-code line-num gds-code
  .
define temp-table tt-utd-err like ub.utd-err
  field descr as character
  field gds-code as integer
  field LineNum  as integer
  field type     as integer
  .
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable vss-include-info16 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_fbrcode-doc-code no-undo
    field rec-type      as character
    field doc-code      as character
    field obj-type      as character
    field obj-code      as integer
    field cli-type      as character
    field cli-code      as integer
    field ext-doc-type  as character
    field doc-type      as character
    field order         as integer
    index pi is primary unique rec-type doc-code
    index od order
.
procedure fbrcode-gen-recipe-code :
do
on error undo, return error
:
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define output parameter p-recipe-code       as character    no-undo.
    assign
        p-recipe-code   = string( next-value( s-recipe, ub ) )
                            + "-"
                            + trim( string( p-obj-code, ">>>>9" ) )
                            + substring( p-obj-type, ( if g#language = "RUS" then 1 else 2 ), 1 )
    .
end.
end procedure.
procedure fbrcode-is-from-object :
do
on error undo, return error
:
define input parameter p-doc-code           as character    no-undo.
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define output parameter p-is-from-object    as logical      no-undo.
    if num-entries( p-doc-code, "-" ) < 2
    or entry( 2, p-doc-code, "-" ) <> trim (string (p-obj-code, ">>>>9"))
                                    + substring( p-obj-type, ( if g#language = "RUS" then 1 else 2 ), 1 )
    then do:
        assign
            p-is-from-object = no
        .
    end.
    else do:
        assign
            p-is-from-object = yes
        .
    end.
end.
end procedure.
procedure fbrcode-trn-doc :
do
on error undo, return error
:
    define input parameter p-out-doc-type       as character    no-undo.
    define input parameter p-out-code           as character    no-undo.
    define input parameter p-trn-doc-out-type   as character    no-undo.
    define output parameter p-trn-doc-doc-code  as character   no-undo.
    case p-out-doc-type:
        when 'производство':U
        then do:
            case p-trn-doc-out-type :
                when 'рас':U
                then do:
                    assign
                        p-trn-doc-doc-code = p-out-code
                    .
                end.
                when 'при':U
                then do:
                    assign
                        p-trn-doc-doc-code = replace ( p-out-code, "-", "=" )
                    .
                end.
                when 'спи':U
                then do:
                    assign
                        p-trn-doc-doc-code = replace ( p-out-code, "-", "*" )
                    .
                end.
                otherwise do:
                    assign
                        p-trn-doc-doc-code = ""
                    .
                    undo, return error "Не может быть обработан тип складского документа '"
                                        + p-trn-doc-out-type + "' во входных параметрах".
                end.
            end case.
        end.
        otherwise do:
            assign
                p-trn-doc-doc-code = ""
            .
            undo, return error "Не может быть обработан тип внешнего документа '"
                                + p-out-doc-type + "' во входных параметрах".
        end.
    end case.
end.
end procedure.
procedure fbrcode-fill-fbr-by-sale-or-pln :
define input parameter p-main-doc-code      as character        no-undo.
    define variable v-order    as integer      no-undo.
    define buffer buf_fbr-doc               for ub.fbr-doc.
    define buffer buf_trn-doc               for ub.trn-doc.
    define buffer buf_temp_fbrcode-doc-code for temp_fbrcode-doc-code.
do
for buf_fbr-doc
  , buf_trn-doc
  , buf_temp_fbrcode-doc-code
on error undo, return error
:
    for each buf_temp_fbrcode-doc-code
    on error undo, return error
    :
        delete buf_temp_fbrcode-doc-code.
    end.
    assign
        v-order = 0
    .
    for each buf_fbr-doc no-lock
       where buf_fbr-doc.out-code = p-main-doc-code
    on error undo, return error
    :
        create buf_temp_fbrcode-doc-code.
        assign
            buf_temp_fbrcode-doc-code.rec-type      = 'производство':U
            buf_temp_fbrcode-doc-code.doc-code      = buf_fbr-doc.doc-code
            buf_temp_fbrcode-doc-code.ext-doc-type  = "":U
            buf_temp_fbrcode-doc-code.obj-type      = buf_fbr-doc.obj-type
            buf_temp_fbrcode-doc-code.obj-code      = buf_fbr-doc.obj-code
            buf_temp_fbrcode-doc-code.cli-type      = buf_fbr-doc.obj-type
            buf_temp_fbrcode-doc-code.cli-code      = buf_fbr-doc.obj-code
            buf_temp_fbrcode-doc-code.doc-type      = buf_fbr-doc.doc-type
        .
        for each buf_trn-doc no-lock
           where buf_trn-doc.out-code = buf_fbr-doc.doc-code
        by buf_trn-doc.fact-order
        on error undo, return error
        :
            if buf_trn-doc.ext-doc-type = 'em':U
            or buf_trn-doc.ext-doc-type = 'im':U
            or buf_trn-doc.ext-doc-type = 'wm':U
            or buf_trn-doc.ext-doc-type = 'ev':U
            then do:
                assign
                    v-order = v-order + 1
                .
                create buf_temp_fbrcode-doc-code.
                assign
                    buf_temp_fbrcode-doc-code.doc-code      = buf_trn-doc.doc-code
                    buf_temp_fbrcode-doc-code.rec-type      = 'скл':U
                    buf_temp_fbrcode-doc-code.ext-doc-type  = buf_trn-doc.ext-doc-type
                    buf_temp_fbrcode-doc-code.obj-type      = buf_trn-doc.obj-type
                    buf_temp_fbrcode-doc-code.obj-code      = buf_trn-doc.obj-code
                    buf_temp_fbrcode-doc-code.cli-type      = buf_trn-doc.cli-type
                    buf_temp_fbrcode-doc-code.cli-code      = buf_trn-doc.cli-code
                    buf_temp_fbrcode-doc-code.doc-type      = buf_trn-doc.doc-type
                    buf_temp_fbrcode-doc-code.order         = v-order
                .
            end.
        end.
        assign
            v-order  = v-order + 1
        .
        find first buf_temp_fbrcode-doc-code
             where buf_temp_fbrcode-doc-code.rec-type = 'производство':U
               and buf_temp_fbrcode-doc-code.doc-code = buf_fbr-doc.doc-code
        .
        assign
            buf_temp_fbrcode-doc-code.order = v-order
        .
    end.
    for each buf_trn-doc no-lock
       where buf_trn-doc.out-code = p-main-doc-code
    by buf_trn-doc.fact-order
    on error undo, return error
    :
        assign
            v-order = v-order + 1
        .
        create buf_temp_fbrcode-doc-code.
        assign
            buf_temp_fbrcode-doc-code.doc-code      = buf_trn-doc.doc-code
            buf_temp_fbrcode-doc-code.rec-type      = 'маг':U
            buf_temp_fbrcode-doc-code.ext-doc-type  = buf_trn-doc.ext-doc-type
            buf_temp_fbrcode-doc-code.obj-type      = buf_trn-doc.obj-type
            buf_temp_fbrcode-doc-code.obj-code      = buf_trn-doc.obj-code
            buf_temp_fbrcode-doc-code.cli-type      = buf_trn-doc.cli-type
            buf_temp_fbrcode-doc-code.cli-code      = buf_trn-doc.cli-code
            buf_temp_fbrcode-doc-code.doc-type      = buf_trn-doc.doc-type
            buf_temp_fbrcode-doc-code.order         = v-order
        .
    end.
end.
end procedure.
procedure fbrcode-get-final-doc :
define input parameter p-main-doc-code      as character        no-undo.
define output parameter p-income-doc-code   as character        no-undo.
    define variable v-main-obj-type    as character    no-undo.
    define variable v-main-obj-code    as integer      no-undo.
    define buffer buf_trn-doc               for ub.trn-doc.
    define buffer buf_temp_fbrcode-doc-code for temp_fbrcode-doc-code.
do
for buf_trn-doc
on error undo, return error
:
    run fbrcode-fill-fbr-by-sale-or-pln in this-procedure (
        input p-main-doc-code
    ).
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-main-doc-code
    .
    assign
        v-main-obj-type = buf_trn-doc.obj-type
        v-main-obj-code = buf_trn-doc.obj-code
    .
    find first buf_temp_fbrcode-doc-code
         where buf_temp_fbrcode-doc-code.ext-doc-type = 'ev':U
           and buf_temp_fbrcode-doc-code.cli-type     = v-main-obj-type
           and buf_temp_fbrcode-doc-code.cli-code     = v-main-obj-code
    no-error.
    if available buf_temp_fbrcode-doc-code
    then do:
        find first buf_trn-doc no-lock
             where buf_trn-doc.out-code     = buf_temp_fbrcode-doc-code.doc-code
               and buf_trn-doc.ext-doc-type = 'iv':U
        .
        assign
            p-income-doc-code = buf_trn-doc.doc-code
        .
    end.
    else do:
        find first buf_temp_fbrcode-doc-code
             where buf_temp_fbrcode-doc-code.ext-doc-type = 'im':U
               and buf_temp_fbrcode-doc-code.obj-type     = v-main-obj-type
               and buf_temp_fbrcode-doc-code.obj-code     = v-main-obj-code
        no-error.
        if available buf_temp_fbrcode-doc-code
        then do:
            assign
                p-income-doc-code = buf_temp_fbrcode-doc-code.doc-code
            .
        end.
        else do:
            assign
                p-income-doc-code = "":U
            .
        end.
    end.
end.
end procedure.
define variable vss-include-info17 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_fbrlib_recipe no-undo
    field recipe-code                   as character
    field fbr-doc-code                  as character
    field income-goods-doc-code         as character
    field count-income                  as integer
    field qnty-income                   as decimal
    field sum-income-sale               as decimal
    field sum-income-cost-base          as decimal
    field sum-income-cost-rubl          as decimal
    field sum-income-vat-cost-base      as decimal
    field sum-income-vat-cost-rubl      as decimal
    field write-off-goods-doc-code      as character
    field write-off-office-doc-code     as character
    field count-write-off               as integer
    field qnty-write-off                as decimal
    field sum-write-off-sale            as decimal
    field sum-write-off-cost-base       as decimal
    field sum-write-off-cost-rubl       as decimal
    field sum-write-off-vat-cost-base   as decimal
    field sum-write-off-vat-cost-rubl   as decimal
index pi is primary unique recipe-code
index income income-goods-doc-code
index wogds write-off-goods-doc-code
index wooff write-off-office-doc-code
.
define temp-table temp_dressing-ingr no-undo
    field recipe-code   as character
    field gds-code      as integer
    field line-qnty     as decimal
    field used-qnty     as decimal
    field recipe-qnty   as decimal
    index pi is primary unique recipe-code gds-code
.
define temp-table temp_recipe-order no-undo
    field recipe-code   as character
    field order         as integer
    index pi is primary unique order
.
define temp-table temp_recipe-childs-qnty no-undo
    field recipe-code   as character
    field childs-qnty   as integer
    field order         as integer
    index pi is primary unique recipe-code
.
define temp-table temp_recipe-childs no-undo
    field recipe-code       as character
    field child-code        as integer
    field child-recipe-code as character
    index pi is primary unique recipe-code child-code
.
define variable v-fbrlib-recipe-order               as integer  no-undo.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fbrlib_create-fbr-doc :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-userid as character no-undo .
define output parameter p-fbr-doc-code as character no-undo .
define output parameter p-recid as recid no-undo .
define variable v-host-code as integer no-undo .
define variable v-base-code as integer no-undo .
define variable v-obj-db-num as integer no-undo .
define variable v-db-num as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-doc-code as character no-undo .
define variable fi-pay-code as integer no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_curr-accnt for ub.curr-accnt.
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile )
:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  )  .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
if v-obj-db-num <> v-db-num then do:
  return error substitute("Запрещено создание документа производства в чужой БД:&1БД &2&3 - &4&1текущая БД - &5"
                          , chr(10)
                          , p-obj-type
                          , p-obj-code
                          , v-obj-db-num
                          , v-db-num).
end.
run cur-time in this-procedure ( output v-today, output v-time).
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-today
  )  .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
find last buf_curr-accnt no-lock
    where buf_curr-accnt.curr-code = v-base-code
      and buf_curr-accnt.exch-date <= v-today use-index pi
no-error.
if not available buf_curr-accnt
then do:
  undo, return error substitute("На дату &1 неизвестен курс базовой валюты с кодом &2"
                                  , string(v-today, "99/99/9999")
                                  , v-base-code).
end.
run doc-code in this-procedure (
      input  "main"
    , input  p-obj-type
    , input  p-obj-code
    , input  ?
    , output v-doc-code
) no-error.
if error-status:error
then do:
  undo, return error substitute("Ошибка при генерации номера документа производства&1&2&1&3"
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value ).
end.
run trg/chkdocnm.p (
      input v-doc-code
    , input 'fbr-doc':U
    , input ?
) no-error.
if error-status:error
then do:
  undo, return error substitute("Ошибка при проверке номера для нового документа производства&1&2&1&3"
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value ).
end.
create buf_fbr-doc.
assign
buf_fbr-doc.doc-code  = v-doc-code
buf_fbr-doc.creid     = p-userid
buf_fbr-doc.doc-date  = v-today
buf_fbr-doc.doc-type  = 'производство':U
buf_fbr-doc.host-code = v-host-code
buf_fbr-doc.obj-code  = p-obj-code
buf_fbr-doc.obj-type  = p-obj-type
buf_fbr-doc.PS        = "@"
buf_fbr-doc.status_   = 'новый':U
buf_fbr-doc.user-db-num = v-obj-db-num
buf_fbr-doc.user-name   = p-userid
.
run fbrlib_get-default-pay-code in this-procedure (
      input buf_fbr-doc.obj-type
    , input buf_fbr-doc.obj-code
    , output fi-pay-code
).
buf_fbr-doc.pay-code = fi-pay-code.
p-recid = recid(buf_fbr-doc).
p-fbr-doc-code = buf_fbr-doc.doc-code.
end.
end procedure.
procedure fbrlib_get-default-pay-code :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define output parameter p-pay-code  as integer          no-undo.
define variable v-host-code as integer no-undo .
define buffer buf_shop          for ub.shop.
define buffer buf_store         for ub.store.
define buffer buf_sysconf       for ub.sysconf.
do
for buf_shop
  , buf_store
  , buf_sysconf
on error undo, return error
:
  case p-obj-type  :
    when 'маг':U then do:
        find first buf_shop no-lock
              where buf_shop.obj-code = p-obj-code
        no-error.
        if available buf_shop
        then do:
            assign
                p-pay-code = buf_shop.fbr-pay
            .
        end.
    end.
    when 'скл':U then do:
        find first buf_store no-lock
              where buf_store.obj-code = p-obj-code
        no-error.
        if available buf_store
        then do:
            assign
                p-pay-code = buf_store.fbr-pay
            .
        end.
    end.
  end case.
  if p-pay-code = ?
  or p-pay-code = 0
  then do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
      find first buf_sysconf no-lock
            where buf_sysconf.host-code = v-host-code
      no-error.
      if available buf_sysconf
      then do:
          assign
              p-pay-code = buf_sysconf.fbr-pay
          .
      end.
  end.
  if p-pay-code = ?
  or p-pay-code = 0
  then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdnpay in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output p-pay-code
  )  .
  end.
end.
end procedure.
procedure fbrlib-fill-and-check-temp_fbrlib_recipe :
do
on error undo, return error
:
define input parameter p-fbr-doc-code as character    no-undo.
    define variable vss-description as character    no-undo init "fbrlib-fill-and-check-temp_fbrlib_recipe: ".
    define variable v-gds-name      as character    no-undo.
    define buffer buf_fbr-doc               for ub.fbr-doc.
    define buffer buf_fbr-line              for ub.fbr-line.
    define buffer buf_temp_fbrlib_recipe    for temp_fbrlib_recipe.
    define buffer buf_out_temp_fbrlib_recipe    for temp_fbrlib_recipe.
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-fbr-doc-code
    .
    for each buf_temp_fbrlib_recipe
    :
        delete buf_temp_fbrlib_recipe.
    end.
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-fbr-doc-code
    :
        find first buf_temp_fbrlib_recipe
             where buf_temp_fbrlib_recipe.recipe-code = buf_fbr-line.recipe-code
        no-error.
        if not available buf_temp_fbrlib_recipe
        then do:
            create buf_temp_fbrlib_recipe.
            assign
                buf_temp_fbrlib_recipe.recipe-code = buf_fbr-line.recipe-code
                buf_temp_fbrlib_recipe.fbr-doc-code = buf_fbr-line.doc-code
            .
        end.
    end.
    for each buf_temp_fbrlib_recipe
    :
        assign
            buf_temp_fbrlib_recipe.count-income                = 0
            buf_temp_fbrlib_recipe.qnty-income                 = 0
            buf_temp_fbrlib_recipe.sum-income-sale             = 0
            buf_temp_fbrlib_recipe.sum-income-cost-base        = 0
            buf_temp_fbrlib_recipe.sum-income-cost-rubl        = 0
            buf_temp_fbrlib_recipe.sum-income-vat-cost-base    = 0
            buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl    = 0
            buf_temp_fbrlib_recipe.count-write-off             = 0
            buf_temp_fbrlib_recipe.qnty-write-off              = 0
            buf_temp_fbrlib_recipe.sum-write-off-sale          = 0
            buf_temp_fbrlib_recipe.sum-write-off-cost-base     = 0
            buf_temp_fbrlib_recipe.sum-write-off-cost-rubl     = 0
            buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base = 0
            buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl = 0
        .
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code     = p-fbr-doc-code
             and buf_fbr-line.trn-type     = 'при':U
             and buf_fbr-line.recipe-code  = buf_temp_fbrlib_recipe.recipe-code
        :
            if ( buf_fbr-line.price-base   = ?
                or buf_fbr-line.price-rubl = ?
                or buf_fbr-line.price-base <= 0
                or buf_fbr-line.price-rubl <= 0 )
            and buf_fbr-line.fact-qnty <> 0
            and buf_fbr-line.rsrv-qnty <> ?
            and buf_fbr-doc.is-free    = no
            then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-arnm in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output v-gds-name
  ) no-error .
                if error-status :error
                then do:
                    assign
                        v-gds-name = ""
                    .
                end.
                undo, return error  substitute("&1 В документе пр-ва &2 учетная цена не определена или нулевая!&3Рецепт &4&3Товар: &5 &6"
                                              ,vss-description
                                              ,buf_fbr-doc.doc-code
                                              ,chr(10)
                                              ,buf_fbr-line.recipe-code
                                              ,buf_fbr-line.artic
                                              ,v-gds-name).
            end.
            assign
                buf_temp_fbrlib_recipe.count-income             = buf_temp_fbrlib_recipe.count-income + 1
                buf_temp_fbrlib_recipe.qnty-income              = buf_temp_fbrlib_recipe.qnty-income
                                                                + buf_fbr-line.fact-qnty
                buf_temp_fbrlib_recipe.sum-income-sale          = buf_temp_fbrlib_recipe.sum-income-sale
                                                                + buf_fbr-line.price-sale * buf_fbr-line.fact-qnty
            .
            if buf_fbr-line.is-waste = no
            then do:
                assign
                    buf_temp_fbrlib_recipe.sum-income-cost-base     = buf_temp_fbrlib_recipe.sum-income-cost-base
                                                                    + buf_fbr-line.price-sum-base
                    buf_temp_fbrlib_recipe.sum-income-cost-rubl     = buf_temp_fbrlib_recipe.sum-income-cost-rubl
                                                                    + buf_fbr-line.price-sum-rubl
                    buf_temp_fbrlib_recipe.sum-income-vat-cost-base = buf_temp_fbrlib_recipe.sum-income-vat-cost-base
                                                                    + buf_fbr-line.price-sum-vat-base
                    buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl = buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl
                                                                    + buf_fbr-line.price-sum-vat-rubl
                .
            end.
        end.
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code     = p-fbr-doc-code
             and buf_fbr-line.trn-type     = 'спи':U
             and buf_fbr-line.recipe-code  = buf_temp_fbrlib_recipe.recipe-code
        :
            if ( buf_fbr-line.price-base   = ?
                or buf_fbr-line.price-rubl = ?
                or buf_fbr-line.price-base <= 0
                or buf_fbr-line.price-rubl <= 0 )
            and buf_fbr-line.fact-qnty <> 0
            and buf_fbr-line.rsrv-qnty <> ?
            and buf_fbr-doc.is-free    = no
            and buf_fbr-doc.status_    = 'разрешен':U
            then do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-arnm in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output v-gds-name
  ) no-error .
                if error-status :error
                then do:
                    assign
                        v-gds-name = ""
                    .
                end.
                undo, return error  substitute("&1 В документе пр-ва &2 учетная цена не определена или нулевая!&3Рецепт &4&3Товар: &5 &6"
                                              ,vss-description
                                              ,buf_fbr-doc.doc-code
                                              ,chr(10)
                                              ,buf_fbr-line.recipe-code
                                              ,buf_fbr-line.artic
                                              ,v-gds-name).
            end.
            assign
                buf_temp_fbrlib_recipe.count-write-off             = buf_temp_fbrlib_recipe.count-write-off + 1
                buf_temp_fbrlib_recipe.qnty-write-off              = buf_temp_fbrlib_recipe.qnty-write-off
                                                                + buf_fbr-line.fact-qnty
                buf_temp_fbrlib_recipe.sum-write-off-sale          = buf_temp_fbrlib_recipe.sum-write-off-sale
                                                                + buf_fbr-line.price-sale * buf_fbr-line.fact-qnty
            .
            if buf_fbr-line.is-waste = no
            then do:
                assign
                    buf_temp_fbrlib_recipe.sum-write-off-cost-base     = buf_temp_fbrlib_recipe.sum-write-off-cost-base
                                                                    + buf_fbr-line.price-sum-base
                    buf_temp_fbrlib_recipe.sum-write-off-cost-rubl     = buf_temp_fbrlib_recipe.sum-write-off-cost-rubl
                                                                    + buf_fbr-line.price-sum-rubl
                    buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base = buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base
                                                                    + buf_fbr-line.price-sum-vat-base
                    buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl = buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl
                                                                    + buf_fbr-line.price-sum-vat-rubl
                .
            end.
        end.
        if buf_fbr-doc.status_    = 'разрешен':U
        and ( abs( buf_temp_fbrlib_recipe.sum-write-off-cost-base     - buf_temp_fbrlib_recipe.sum-income-cost-base     ) > 0.01
        or abs( buf_temp_fbrlib_recipe.sum-write-off-cost-rubl     - buf_temp_fbrlib_recipe.sum-income-cost-rubl     ) > 0.01
        or abs( buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base - buf_temp_fbrlib_recipe.sum-income-vat-cost-base ) > 0.01
        or abs( buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl - buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl ) > 0.01
            )
        then do:
         undo, return error
            substitute("В документе пр-ва &1 Не совпадают суммы учетных цен для списанного и оприходованного по рецепту товара.&2" +
                        "Рецепт: &3&2&4&4по списанному товару&4по оприходованному товару&2"  +
                        "Сумма в баз.вал.&4&5&4&4&6&2" +
                        "Сумма в &9.&4&7&4&4&8&2"
                       , buf_fbr-doc.doc-code
                       , chr(10)
                       , buf_temp_fbrlib_recipe.recipe-code
                       , chr(9)
                       , buf_temp_fbrlib_recipe.sum-write-off-cost-base
                       , buf_temp_fbrlib_recipe.sum-income-cost-base
                       , buf_temp_fbrlib_recipe.sum-write-off-cost-rubl
                       , buf_temp_fbrlib_recipe.sum-income-cost-rubl
                       , "руб"
                       )
           +
           substitute("НДС в баз.вал.&1&2&1&1&3&4" +
                      "НДС в &7.&1&5&1&1&6&4"
                     ,  chr(9)
                     ,buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base
                     ,buf_temp_fbrlib_recipe.sum-income-vat-cost-base
                     ,chr(10)
                     ,buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl
                     ,buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl
                     ,"руб"
                     )       .
        end.
    end.
end.
end procedure.
procedure fbrlib-fill-sum-fbr-doc :
do
on error undo, return error
:
define input parameter p-fbr-doc-recid  as recid        no-undo.
define input parameter p-mode           as character    no-undo.
    define variable vss-description as character init "fbrlib-fill-sum-fbr-doc: "  no-undo.
    define buffer buf_fbr-doc           for ub.fbr-doc.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_temp_fbrlib_recipe   for temp_fbrlib_recipe.
    define variable v-in-count          as integer       no-undo.
    define variable v-out-count         as integer       no-undo.
    find first buf_fbr-doc exclusive-lock
         where recid ( buf_fbr-doc ) = p-fbr-doc-recid
    .
    find first buf_temp_fbrlib_recipe no-error.
    if not available buf_temp_fbrlib_recipe
    then do:
        run fbrlib-fill-and-check-temp_fbrlib_recipe in this-procedure (
            input buf_fbr-doc.doc-code
        ) no-error.
        if error-status :error
        then do:
            undo, return error substitute("&1 Ошибка расчета сумм при заполнении шапки документа производства.&2&3&2&4"
                                           , vss-description
                                           , chr(10)
                                           , error-status:get-message(1)
                                           , return-value ).
        end.
    end.
    assign
        v-in-count                  = 0
        buf_fbr-doc.in-qnty         = 0
        buf_fbr-doc.in-sale         = 0
        buf_fbr-doc.in-base         = 0
        buf_fbr-doc.in-rubl         = 0
        buf_fbr-doc.in-vat-base     = 0
        buf_fbr-doc.in-vat-rubl     = 0
        v-out-count                 = 0
        buf_fbr-doc.out-qnty        = 0
        buf_fbr-doc.out-sale        = 0
        buf_fbr-doc.out-base        = 0
        buf_fbr-doc.out-rubl        = 0
        buf_fbr-doc.out-vat-base    = 0
        buf_fbr-doc.out-vat-rubl    = 0
    .
    for each buf_temp_fbrlib_recipe
    :
        assign
            v-in-count                  = v-in-count                + buf_temp_fbrlib_recipe.count-income
            buf_fbr-doc.in-qnty         = buf_fbr-doc.in-qnty       + buf_temp_fbrlib_recipe.qnty-income
            buf_fbr-doc.in-sale         = buf_fbr-doc.in-sale       + buf_temp_fbrlib_recipe.sum-income-sale
            buf_fbr-doc.in-base         = buf_fbr-doc.in-base       + buf_temp_fbrlib_recipe.sum-income-cost-base
            buf_fbr-doc.in-rubl         = buf_fbr-doc.in-rubl       + buf_temp_fbrlib_recipe.sum-income-cost-rubl
            buf_fbr-doc.in-vat-base     = buf_fbr-doc.in-vat-base   + buf_temp_fbrlib_recipe.sum-income-vat-cost-base
            buf_fbr-doc.in-vat-rubl     = buf_fbr-doc.in-vat-rubl   + buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl
            v-out-count                 = v-out-count               + buf_temp_fbrlib_recipe.count-write-off
            buf_fbr-doc.out-qnty        = buf_fbr-doc.out-qnty      + buf_temp_fbrlib_recipe.qnty-write-off
            buf_fbr-doc.out-sale        = buf_fbr-doc.out-sale      + buf_temp_fbrlib_recipe.sum-write-off-sale
            buf_fbr-doc.out-base        = buf_fbr-doc.out-base      + buf_temp_fbrlib_recipe.sum-write-off-cost-base
            buf_fbr-doc.out-rubl        = buf_fbr-doc.out-rubl      + buf_temp_fbrlib_recipe.sum-write-off-cost-rubl
            buf_fbr-doc.out-vat-base    = buf_fbr-doc.out-vat-base  + buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base
            buf_fbr-doc.out-vat-rubl    = buf_fbr-doc.out-vat-rubl  + buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl
        .
    end.
    if ( abs (buf_fbr-doc.in-rubl - buf_fbr-doc.out-rubl) <= 0.01
    and   abs (buf_fbr-doc.in-base - buf_fbr-doc.out-base) <= 0.01 )
    or p-mode <> 'факт':U
    then do:
        if substring( buf_fbr-doc.PS, 1, 1 ) = "@"
        then do:
            assign
                buf_fbr-doc.PS = "@ Строк полученных товаров : "
                                + string( v-out-count, ">>>,>>9" )
                                + chr(10) + "Строк исходных товаров : "
                                + string( v-in-count, ">>>,>>9" )
            .
        end.
    end.
    else do:
      undo, return error substitute("В док-те пр-ва &1 не совпадают суммы списанных и оприходованных товаров.&2" +
                                    "Сумма списанных товаров в &3 - &4&2" +
                                    "Сумма оприходованных товаров в &3 - &5&2" +
                                    "Сумма оприходованных товаров в &3 - &6&2" +
                                    "Сумма списанных товаров в баз.вал. - &7&2" +
                                    "Сумма оприходованных товаров в баз.вал. - &8&2"
                                    , buf_fbr-doc.doc-code
                                    , chr(10)
                                    , "рублях"
                                    , round( buf_fbr-doc.out-rubl, 2 )
                                    , round( buf_fbr-doc.in-rubl,  2 )
                                    , round( buf_fbr-doc.in-rubl,  2 )
                                    , round( buf_fbr-doc.out-base, 2 )
                                    , round( buf_fbr-doc.in-base,  2 )).
    end.
end.
end procedure.
procedure fbrlib-calc-prices :
do
on error undo, return error
:
define input parameter p-fbr-line-recid as recid        no-undo.
define input parameter p-price-obj-type as character    no-undo.
define input parameter p-price-obj-code as integer      no-undo.
define output parameter p-current-price as decimal      no-undo.
    define variable v-void          as decimal       no-undo.
    define variable v-void-char     as character     no-undo.
    define variable v-gds-code      as integer       no-undo.
    define variable v-b-code        as integer       no-undo.
    define buffer buf_fbr-doc   for ub.fbr-doc.
    define buffer buf_fbr-line  for ub.fbr-line.
    define buffer buf_gds-prt   for ub.gds-prt.
    define buffer buf_bar-code  for ub.bar-code.
    find first buf_fbr-line no-lock
        where recid( buf_fbr-line ) = p-fbr-line-recid
    .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output v-gds-code
  ) no-error .
    if error-status :error
    then do:
      undo, return error substitute("&1 &2 &3&4Ошибка определения кода товара (артикул &7).&4&5&4&6"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      ,chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      , buf_fbr-line.artic
                                      ).
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  v-gds-code
  ,input  ?
  ,output v-b-code
  ) no-error .
    if error-status :error
    then do:
      undo, return error substitute("&1 &2 &3&4Ошибка определения основного бар-кода товара (код товара) &7.&4&5&4&6"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      ,chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      , v-gds-code
                                      ).
    end.
    if buf_fbr-line.is-calc = no
    then do:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-price-obj-type
  ,input  p-price-obj-code
  ,input  v-b-code
  ,input  0
  ,input  0
  ,output v-void-char
  ,output p-current-price
  ,output v-void
  ,output v-void
  ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("&1 &2 &3&4Ошибка определения продажной цены основного бар-кода товара (код товара) &7.&4&5&4&6"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,chr(10)
                                          , error-status:get-message(1)
                                          , return-value
                                          , v-gds-code
                                          ).
        end.
    end.
    else do:
        assign
            p-current-price = buf_fbr-line.price-sale
        .
    end.
end.
end procedure.
procedure fbrlib-put-in-order-recipe :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code   as character    no-undo.
    define variable v-recipe-counter    as integer          no-undo.
    define variable v-recipe-amount     as integer init 0   no-undo.
    define variable v-child-counter     as integer          no-undo.
    define variable v-is-call-cycle     as logical          no-undo.
    define variable v-str as character     no-undo.
    define buffer buf_in_fbr-line       for ub.fbr-line.
    define buffer buf_dress_fbr-line    for ub.fbr-line.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_recipe-gds        for ub.recipe-gds.
    define buffer buf_recipe            for ub.recipe.
    for each temp_recipe-childs-qnty
    :
        delete temp_recipe-childs-qnty.
    end.
    for each temp_recipe-childs
    :
        delete temp_recipe-childs.
    end.
    for each temp_recipe-order
    :
        delete temp_recipe-order.
    end.
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-fbr-doc-doc-code
    on error undo, return error
    :
        find first temp_recipe-childs-qnty
             where temp_recipe-childs-qnty.recipe-code = buf_fbr-line.recipe-code
        no-error.
        if not available temp_recipe-childs-qnty
        then do:
            create temp_recipe-childs-qnty.
            assign
                v-recipe-amount                     = v-recipe-amount + 1
                temp_recipe-childs-qnty.recipe-code = buf_fbr-line.recipe-code
                temp_recipe-childs-qnty.order       = v-recipe-amount
                temp_recipe-childs-qnty.childs-qnty = 0
                v-child-counter                     = 0
            .
        end.
    end.
    for each buf_in_fbr-line no-lock
       where buf_in_fbr-line.doc-code = p-fbr-doc-doc-code
         and buf_in_fbr-line.trn-type = 'спи':U
    on error undo, return error
    :
        for each buf_dress_fbr-line no-lock
           where buf_dress_fbr-line.doc-code    = p-fbr-doc-doc-code
             and buf_dress_fbr-line.trn-type    = 'при':U
             and buf_dress_fbr-line.artic       = buf_in_fbr-line.artic
             and buf_dress_fbr-line.prod-type   = buf_in_fbr-line.prod-type
             and buf_dress_fbr-line.prod-code   = buf_in_fbr-line.prod-code
        on error undo, return error
        :
            find first buf_recipe no-lock
                 where buf_recipe.recipe-code = buf_dress_fbr-line.recipe-code
            .
            if buf_in_fbr-line.is-comp = yes
            then do:
                find last temp_recipe-childs-qnty
                    where temp_recipe-childs-qnty.recipe-code = buf_in_fbr-line.recipe-code
                .
                assign
                    temp_recipe-childs-qnty.childs-qnty = temp_recipe-childs-qnty.childs-qnty + 1
                .
                create temp_recipe-childs.
                assign
                    temp_recipe-childs.recipe-code          = buf_in_fbr-line.recipe-code
                    temp_recipe-childs.child-code           = temp_recipe-childs-qnty.childs-qnty
                    temp_recipe-childs.child-recipe-code    = buf_dress_fbr-line.recipe-code
                .
            end.
            else do:
            end.
        end.
    end.
    for each buf_in_fbr-line no-lock
       where buf_in_fbr-line.doc-code = p-fbr-doc-doc-code
         and buf_in_fbr-line.trn-type = 'при':U
    on error undo, return error
    :
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = buf_in_fbr-line.recipe-code
        no-error.
        if buf_in_fbr-line.is-comp = no
        then do:
        end.
        else do:
            for each buf_recipe-gds no-lock
            where buf_recipe-gds.recipe-code = buf_in_fbr-line.recipe-code
            :
                for each buf_fbr-line no-lock
                where buf_fbr-line.doc-code    = p-fbr-doc-doc-code
                    and buf_fbr-line.trn-type    = 'при':U
                    and buf_fbr-line.artic       = buf_recipe-gds.artic
                    and buf_fbr-line.prod-type   = buf_recipe-gds.prod-type
                    and buf_fbr-line.prod-code   = buf_recipe-gds.prod-code
                on error undo, return error
                :
                    find first buf_recipe no-lock
                         where buf_recipe.recipe-code = buf_fbr-line.recipe-code
                    .
                    if buf_recipe.recipe-type = 'разделка':U
                    then do:
                    end.
                    else do:
                        find last temp_recipe-childs-qnty
                            where temp_recipe-childs-qnty.recipe-code = buf_in_fbr-line.recipe-code
                        .
                        assign
                            temp_recipe-childs-qnty.childs-qnty = temp_recipe-childs-qnty.childs-qnty + 1
                        .
                        create temp_recipe-childs.
                        assign
                            temp_recipe-childs.recipe-code          = buf_in_fbr-line.recipe-code
                            temp_recipe-childs.child-code           = temp_recipe-childs-qnty.childs-qnty
                            temp_recipe-childs.child-recipe-code    = buf_fbr-line.recipe-code
                        .
                    end.
                end.
            end.
        end.
    end.
    for each temp_recipe-order
    on error undo, return error
    :
        delete temp_recipe-order.
    end.
    assign
        v-fbrlib-recipe-order = 0
    .
    do v-recipe-counter = 1 to v-recipe-amount
    on error undo, return error
    :
        run fbrlib-add-recipe-in-tmp-order in this-procedure (
              input v-recipe-counter
            , input 0
            , output v-is-call-cycle
        ).
        if v-is-call-cycle = yes
        then do:
            message
                    "Достигнут максимальный уровень вложенности рецептов."
                skip(1)
                skip "Невозможно упорядочить рецепты."
                skip(1)
                skip "Необходимо изменить структуру рецептов,"
                skip "используемых при формировании"
                skip "данного документа производства."
            view-as alert-box error
            title "Невозможно рассчитать документ производства".
            for each temp_recipe-childs-qnty
            :
                delete temp_recipe-childs-qnty.
            end.
            for each temp_recipe-childs
            :
                delete temp_recipe-childs.
            end.
            for each temp_recipe-order
            :
                delete temp_recipe-order.
            end.
            for each temp_recipe-order
            on error undo, return error
            :
                delete temp_recipe-order.
            end.
            for each temp_fbrlib_recipe
            on error undo, return error
            :
                delete temp_recipe-order.
            end.
            undo, return error.
        end.
    end.
end.
end procedure.
procedure fbrlib-add-recipe-in-tmp-order :
do
on error undo, return error
:
define input parameter p-order              as integer      no-undo.
define input parameter p-call-counter       as integer      no-undo.
define output parameter p-is-call-cycle     as logical      no-undo.
    define variable v-nodes-counter     as integer       no-undo.
    define buffer buf_c_temp_recipe-childs-qnty for temp_recipe-childs-qnty.
    define buffer buf_temp_recipe-childs-qnty   for temp_recipe-childs-qnty.
    define buffer buf_temp_recipe-childs        for temp_recipe-childs     .
    define buffer buf_temp_recipe-order         for temp_recipe-order.
    assign
        p-call-counter = p-call-counter + 1
    .
    if p-call-counter > 50
    then do:
        assign
            p-is-call-cycle = yes
        .
    end.
    else do:
        find first buf_temp_recipe-childs-qnty
             where buf_temp_recipe-childs-qnty.order = p-order
        .
        find first buf_temp_recipe-order
             where buf_temp_recipe-order.recipe-code = buf_temp_recipe-childs-qnty.recipe-code
        no-error.
        if not available buf_temp_recipe-order
        then do:
            do v-nodes-counter = 1 to buf_temp_recipe-childs-qnty.childs-qnty
            :
                find first buf_temp_recipe-childs
                     where buf_temp_recipe-childs.recipe-code = buf_temp_recipe-childs-qnty.recipe-code
                       and buf_temp_recipe-childs.child-code  = v-nodes-counter
                .
                find first buf_c_temp_recipe-childs-qnty
                     where buf_c_temp_recipe-childs-qnty.recipe-code = buf_temp_recipe-childs.child-recipe-code
                .
                run fbrlib-add-recipe-in-tmp-order in this-procedure (
                      input buf_c_temp_recipe-childs-qnty.order
                    , input p-call-counter
                    , output p-is-call-cycle
                ).
                if p-is-call-cycle = yes
                then do:
                    return.
                end.
            end.
            assign
                v-fbrlib-recipe-order = v-fbrlib-recipe-order + 1
            .
            create buf_temp_recipe-order.
            assign
                buf_temp_recipe-order.recipe-code   = buf_temp_recipe-childs-qnty.recipe-code
                buf_temp_recipe-order.order         = v-fbrlib-recipe-order
            .
        end.
    end.
end.
end procedure.
procedure fbrlib-get-trn-type :
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-goods-recid    as recid        no-undo.
define input parameter p-is-integration as logical      no-undo.
define output parameter p-is-comp       as logical      no-undo.
define output parameter p-trn-type      as character    no-undo.
define buffer buf_recipe    for ub.recipe.
define buffer buf_goods     for ub.goods.
do
for buf_recipe
  , buf_goods
on error undo, return error
:
    find first buf_goods no-lock
         where recid( buf_goods ) = p-goods-recid
    .
    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    no-error.
    if not available buf_recipe
    then do:
        assign
            p-is-comp = no
            p-trn-type = "":U
        .
        undo, return.
    end.
    if  buf_recipe.artic        = buf_goods.artic
    and buf_recipe.prod-type    = buf_goods.prod-type
    and buf_recipe.prod-code    = buf_goods.prod-code
    then do:
        assign
            p-is-comp = yes
        .
    end.
    else do:
        assign
            p-is-comp = no
        .
    end.
    case buf_recipe.recipe-type
    :
        when 'производство':U
        then do:
            if p-is-comp = yes
            then do:
                assign
                    p-trn-type = 'при':U
                .
            end.
            else do:
                assign
                    p-trn-type = 'спи':U
                .
            end.
        end.
        when 'альтернатива':U
        then do:
            if p-is-comp = yes
            then do:
                assign
                    p-trn-type = 'при':U
                .
            end.
            else do:
                assign
                    p-trn-type = 'спи':U
                .
            end.
        end.
        when 'разделка':U
        then do:
            if p-is-comp = no
            then do:
                assign
                    p-trn-type = 'при':U
                .
            end.
            else do:
                assign
                    p-trn-type = 'спи':U
                .
            end.
        end.
        when 'комплектация':U
        then do:
            if p-is-integration = ?
            then do:
                message
                    "Выберите тип операции по рецепту комплектации:"
                    skip (2) "YES - комплектация"
                    skip     "NO - разукомплектация"
                view-as alert-box question
                buttons YES-NO
                update p-is-integration.
            end.
            if p-is-integration = yes
            then do:
                if p-is-comp = yes
                then do:
                    assign
                        p-trn-type = 'при':U
                    .
                end.
                else do:
                    assign
                        p-trn-type = 'спи':U
                    .
                end.
            end.
            else do:
                if p-is-comp = yes
                then do:
                    assign
                        p-trn-type = 'спи':U
                    .
                end.
                else do:
                    assign
                        p-trn-type = 'при':U
                    .
                end.
            end.
        end.
    end case.
end.
end procedure.
procedure fbrlib-get-mark :
define input parameter p-recipe-code    as character    no-undo.
define output parameter p-mark          as logical    no-undo.
define buffer buf_goods-attr     for ub.goods-attr.
define buffer buf_recipe-gds for ub.recipe-gds .
    for each buf_recipe-gds no-lock where buf_recipe-gds.recipe-code = p-recipe-code,
         first buf_goods-attr no-lock where buf_goods-attr.gds-code = buf_recipe-gds.gds-code and
                                            buf_goods-attr.attr-code = 'mark-type':U:
         if buf_goods-attr.attr-value <> "" and buf_goods-attr.attr-value <> "not-type" then do:
            p-mark = true .
            return .
         end.
    end.
end procedure.
procedure fbrlib-check-temp-tables :
do
on error undo, return error
:
define input parameter p-title  as character    no-undo.
    define variable v-str               as character        no-undo.
    assign
        v-str = v-str + chr(10) + "temp_recipe-childs-qnty:" + chr(10)
    .
    for each temp_recipe-childs-qnty
    on error undo, return error
    :
        assign
            v-str   = v-str + string( temp_recipe-childs-qnty.recipe-code )
                    + "   " + string( temp_recipe-childs-qnty.childs-qnty )
                    + "   " + string( temp_recipe-childs-qnty.order )
                    + chr(10)
        .
    end.
    assign
        v-str = v-str + "temp_recipe-childs:" + chr(10)
    .
    for each temp_recipe-childs
    on error undo, return error
    :
        assign
            v-str   = v-str + string( temp_recipe-childs.recipe-code )
                    + "   " + string( temp_recipe-childs.child-code )
                    + "   " + string( temp_recipe-childs.child-recipe-code )
                    + chr(10)
        .
    end.
    assign
        v-str = v-str + chr(10) + "temp_recipe-order:" + chr(10)
    .
    for each temp_recipe-order
    on error undo, return error
    :
        assign
            v-str   = v-str + string( temp_recipe-order.recipe-code )
                    + "   " + string( temp_recipe-order.order )
                    + chr(10)
        .
    end.
    assign
        v-str = v-str + chr(10) + "temp_fbrlib_recipe:" + chr(10)
    .
    run writelog in this-procedure ( input "fbr.log", input 0, input p-title ).
    run writelog in this-procedure ( input "fbr.log", input 0, input v-str ).
    for each temp_fbrlib_recipe
    on error undo, return error
    :
        assign
            v-str   = "recipe-code: "                   + string( temp_fbrlib_recipe.recipe-code                 )
                    + "   " + "count-income: "                  + string( temp_fbrlib_recipe.count-income                )
                    + "   " + "qnty-income: "                   + string( temp_fbrlib_recipe.qnty-income                 )
                    + "   " + "sum-income-sale: "               + string( temp_fbrlib_recipe.sum-income-sale             )
                    + "   " + "sum-income-cost-base: "          + string( temp_fbrlib_recipe.sum-income-cost-base        )
                    + "   " + "sum-income-cost-rubl: "          + string( temp_fbrlib_recipe.sum-income-cost-rubl        )
                    + "   " + "sum-income-vat-cost-base: "      + string( temp_fbrlib_recipe.sum-income-vat-cost-base    )
                    + "   " + "sum-income-vat-cost-rubl: "      + string( temp_fbrlib_recipe.sum-income-vat-cost-rubl    )
                    + "   " + "count-write-off: "               + string( temp_fbrlib_recipe.count-write-off             )
                    + "   " + "qnty-write-off: "                + string( temp_fbrlib_recipe.qnty-write-off              )
                    + "   " + "sum-write-off-sale: "            + string( temp_fbrlib_recipe.sum-write-off-sale          )
                    + "   " + "sum-write-off-cost-base: "       + string( temp_fbrlib_recipe.sum-write-off-cost-base     )
                    + "   " + "sum-write-off-cost-rubl: "       + string( temp_fbrlib_recipe.sum-write-off-cost-rubl     )
                    + "   " + "sum-write-off-vat-cost-base: "   + string( temp_fbrlib_recipe.sum-write-off-vat-cost-base )
                    + "   " + "sum-write-off-vat-cost-rubl: "   + string( temp_fbrlib_recipe.sum-write-off-vat-cost-rubl )
                    + chr(10)
        .
        run writelog in this-procedure ( input "fbr.log", input 0, input v-str ).
    end.
end.
end procedure.
procedure fbrlib-s-coeff-value :
define input  parameter p-gds-code    as integer        no-undo.
define input  parameter p-date        as date           no-undo.
define input  parameter p-obj-type    as character      no-undo.
define input  parameter p-obj-code    as integer        no-undo.
define output parameter p-coeff-value as decimal        no-undo.
define variable vss-description as character init "fbrlib-s-coeff-value-01: определяет значение сезонного коэффициента" no-undo.
    define variable v-date          as date         no-undo.
    define variable v-host-code     as integer      no-undo.
    define buffer buf_goods       for ub.goods.
    define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
    define buffer buf_clients     for ub.clients.
    define buffer buf_s-coeff     for ub.s-coeff.
do
for buf_goods
  , buf_fbr-gds-obj
  , buf_clients
  , buf_s-coeff
on error undo, return error return-value
:
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    no-error .
    if not available buf_goods
    then do:
       undo, return error substitute("Ошибка при определении сезонного коэффициента - не найден товар с кодом &1", p-gds-code).
    end.
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    no-error.
    if not available buf_clients
    then do:
       undo, return error substitute("Ошибка при определении сезонного коэффициента - не найден объект &1&2", p-obj-type, p-obj-code).
    end.
    assign
        v-date = date(month(p-date), day(p-date), Year(01/01/1996))
    .
    find first buf_fbr-gds-obj no-lock
         where buf_fbr-gds-obj.gds-code = p-gds-code
           and buf_fbr-gds-obj.obj-type = p-obj-type
           and buf_fbr-gds-obj.obj-code = p-obj-code
    no-error.
    if not available buf_fbr-gds-obj
    or buf_fbr-gds-obj.is-season = no
    then do:
        assign
            p-coeff-value = 0
        .
        return.
    end.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    find last buf_s-coeff no-lock
        where buf_s-coeff.gds-code = p-gds-code
          and buf_s-coeff.host-code = v-host-code
          and buf_s-coeff.obj-type = p-obj-type
          and buf_s-coeff.obj-code = p-obj-code
          and buf_s-coeff.s-date <= v-date
    no-error.
    if available buf_s-coeff
    then do:
        assign
            p-coeff-value = buf_s-coeff.coeff-value
        .
        return.
    end.
    find last buf_s-coeff no-lock
        where buf_s-coeff.gds-code = p-gds-code
          and buf_s-coeff.host-code = v-host-code
          and buf_s-coeff.obj-type = "":U
          and buf_s-coeff.obj-code = 0
          and buf_s-coeff.s-date <= v-date
    no-error.
    if available buf_s-coeff
    then do:
        assign
            p-coeff-value = buf_s-coeff.coeff-value
        .
        return.
    end.
    find last buf_s-coeff no-lock
        where buf_s-coeff.gds-code = p-gds-code
          and buf_s-coeff.host-code = 0
          and buf_s-coeff.obj-type = "":U
          and buf_s-coeff.obj-code = 0
          and buf_s-coeff.s-date <= v-date
    no-error.
    if available buf_s-coeff
    then do:
        assign
            p-coeff-value = buf_s-coeff.coeff-value
        .
    end.
    else do:
        assign
            p-coeff-value = 0
        .
    end.
end.
end procedure.
procedure fbrlib_create-fbr-recipe-gds :
define input parameter p-doc-code         as character      no-undo.
define input parameter p-recipe-code      as character      no-undo.
define input parameter p-prod-type        as character      no-undo.
define input parameter p-prod-code        as integer        no-undo.
define input parameter p-artic            as character      no-undo.
define input parameter p-gds-code         as integer        no-undo.
define input parameter p-is-waste         as logical        no-undo.
define input parameter p-proc-number      as integer        no-undo.
define input parameter p-obj-date         as date           no-undo.
define input parameter p-obj-type         as character      no-undo.
define input parameter p-obj-code         as integer        no-undo.
define input parameter p-calc-method      as decimal        no-undo.
define input parameter p-coeff-waste      as decimal        no-undo.
define input parameter p-orig-qnty        as decimal        no-undo.
define input parameter p-orig-brutto-qnty as decimal        no-undo.
    define variable v-coeff-season  as decimal      no-undo.
    define variable v-void-decimal  as decimal      no-undo.
    define variable v-void-integer  as integer      no-undo.
    define variable v-recipe-type   as character    no-undo.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_goods             for ub.goods.
    define buffer buf_recipe            for ub.recipe.
do
for buf_fbr-recipe-gds
  , buf_recipe
  , buf_goods
on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
    find first buf_fbr-recipe-gds exclusive-lock
         where buf_fbr-recipe-gds.doc-code    = p-doc-code
           and buf_fbr-recipe-gds.recipe-code = p-recipe-code
           and buf_fbr-recipe-gds.prod-type   = p-prod-type
           and buf_fbr-recipe-gds.prod-code   = p-prod-code
           and buf_fbr-recipe-gds.artic       = p-artic
    no-error.
    if not available buf_fbr-recipe-gds
    then do:
        create buf_fbr-recipe-gds.
        assign
            buf_fbr-recipe-gds.doc-code           = p-doc-code
            buf_fbr-recipe-gds.recipe-code        = p-recipe-code
            buf_fbr-recipe-gds.prod-type          = p-prod-type
            buf_fbr-recipe-gds.prod-code          = p-prod-code
            buf_fbr-recipe-gds.artic              = p-artic
            buf_fbr-recipe-gds.gds-code           = p-gds-code
            buf_fbr-recipe-gds.is-waste           = p-is-waste
            buf_fbr-recipe-gds.proc-number        = p-proc-number
            buf_fbr-recipe-gds.recipe-qnty        = p-orig-qnty
            buf_fbr-recipe-gds.recipe-brutto-qnty = p-orig-brutto-qnty
        .
        find first buf_goods no-lock
             where buf_goods.prod-type = buf_fbr-recipe-gds.prod-type
               and buf_goods.prod-code = buf_fbr-recipe-gds.prod-code
               and buf_goods.artic     = buf_fbr-recipe-gds.artic
        .
        run fbrlib-s-coeff-value in this-procedure (
              input buf_goods.gds-code
            , input p-obj-date
            , input p-obj-type
            , input p-obj-code
            , output v-coeff-season
        ) no-error.
        if error-status:error
        then do:
            return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
        end.
        assign
            buf_fbr-recipe-gds.qnty         = p-orig-qnty
            buf_fbr-recipe-gds.coeff-value  = v-coeff-season
            buf_fbr-recipe-gds.coeff-waste  = p-coeff-waste
        .
        run fbrlib-get-recipe-type in this-procedure (
              input buf_fbr-recipe-gds.doc-code
            , input buf_fbr-recipe-gds.recipe-code
            , output v-recipe-type
        ).
        if v-recipe-type <> 'производство':U
        then do:
            assign
                buf_fbr-recipe-gds.coeff-value  = 0
                buf_fbr-recipe-gds.coeff-waste  = 0
                buf_fbr-recipe-gds.calc-method  = 1
                buf_fbr-recipe-gds.brutto-qnty  = buf_fbr-recipe-gds.qnty
            .
        end.
        else do:
            run fbrlib-calc-brutto in this-procedure (
                  input v-recipe-type
                , input buf_fbr-recipe-gds.qnty
                , input buf_fbr-recipe-gds.coeff-value
                , input buf_fbr-recipe-gds.coeff-waste
                , input 0
                , input 3
                , output v-void-decimal
                , output v-void-decimal
                , output buf_fbr-recipe-gds.brutto-qnty
                , output v-void-integer
            ).
            assign
                buf_fbr-recipe-gds.calc-method  = p-calc-method
            .
            run fbrlib-calc-brutto in this-procedure (
                  input v-recipe-type
                , input buf_fbr-recipe-gds.qnty
                , input buf_fbr-recipe-gds.coeff-value
                , input buf_fbr-recipe-gds.coeff-waste
                , input buf_fbr-recipe-gds.brutto-qnty
                , input buf_fbr-recipe-gds.calc-method
                , output buf_fbr-recipe-gds.qnty
                , output v-void-decimal
                , output v-void-decimal
                , output v-void-integer
            ).
        end.
    end.
end.
end procedure.
procedure fbrlib-set-default-recipe :
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-gds-code   as integer      no-undo.
    define variable v-artic             as character    no-undo.
    define variable v-prod-type         as character    no-undo.
    define variable v-prod-code         as character    no-undo.
    define variable v-recipe-code       as character    no-undo.
    define variable v-fbr-gds-obj-recid as recid        no-undo.
    define variable v-recipe-found      as logical      no-undo.
    define buffer buf_recipe        for ub.recipe.
    define buffer buf_other_recipe  for ub.recipe.
    define buffer buf_goods         for ub.goods.
    define buffer buf_fbr-gds-obj   for ub.fbr-gds-obj.
do
for buf_recipe
  , buf_goods
  , buf_fbr-gds-obj
on error undo, return error
:
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    run fbrlib-get-obj-recipe in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-gds-code
        , output v-recipe-code
    ).
    if v-recipe-code <> ""
    then do:
        find first buf_recipe no-lock
            where buf_recipe.recipe-code = v-recipe-code
        no-error.
        if not available buf_recipe
        then do:
            assign
                v-recipe-code = ""
            .
        end.
    end.
    if v-recipe-code = ""
    then do:
        find first buf_fbr-gds-obj exclusive-lock
             where buf_fbr-gds-obj.obj-type = p-obj-type
               and buf_fbr-gds-obj.obj-code = p-obj-code
               and buf_fbr-gds-obj.gds-code = p-gds-code
        no-error.
        if not available buf_fbr-gds-obj
        then do:
            run ref/fgdsobj1.p (
                  input-output v-fbr-gds-obj-recid
                , input 'ДОБАВЛЕНИЕ':U
                , input no
                , input p-gds-code
                , input p-obj-type
                , input p-obj-code
                , input 0
                , input ""
                , input 0
                , input no
                , input no
                , input no
                , input no
                , input no
                , input no
            ) no-error.
            if error-status:error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip "Ошибка изменения атрибутов товара на объекте"
                    skip return-value
                    skip trim(error-status :get-message(1))
                            trim(error-status :get-message(2))
                            trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
            find first buf_fbr-gds-obj exclusive-lock
                 where recid( buf_fbr-gds-obj ) = v-fbr-gds-obj-recid
            .
        end.
        assign
            v-recipe-found = no
        .
        for first buf_recipe no-lock
            where buf_recipe.obj-type    = p-obj-type
              and buf_recipe.obj-code    = p-obj-code
              and buf_recipe.artic       = buf_goods.artic
              and buf_recipe.prod-type   = buf_goods.prod-type
              and buf_recipe.prod-code   = buf_goods.prod-code
              and buf_recipe.recipe-type = 'производство':U
              or (
                  buf_recipe.obj-type    = ""
              and buf_recipe.obj-code    = 0
              and buf_recipe.artic       = buf_goods.artic
              and buf_recipe.prod-type   = buf_goods.prod-type
              and buf_recipe.prod-code   = buf_goods.prod-code
              and buf_recipe.recipe-type = 'производство':U
                  )
        :
            assign
                v-recipe-found = yes
                buf_fbr-gds-obj.default-recipe-code = buf_recipe.recipe-code
            .
        end.
        if v-recipe-found = no
        then do:
            for first buf_recipe no-lock
                where buf_recipe.obj-type    = p-obj-type
                  and buf_recipe.obj-code    = p-obj-code
                  and buf_recipe.artic       = buf_goods.artic
                  and buf_recipe.prod-type   = buf_goods.prod-type
                  and buf_recipe.prod-code   = buf_goods.prod-code
                  and buf_recipe.recipe-type <> 'альтернатива':U
                  or (
                      buf_recipe.obj-type    = ""
                  and buf_recipe.obj-code    = 0
                  and buf_recipe.artic       = buf_goods.artic
                  and buf_recipe.prod-type   = buf_goods.prod-type
                  and buf_recipe.prod-code   = buf_goods.prod-code
                  and buf_recipe.recipe-type <> 'альтернатива':U
                      )
            :
                assign
                    v-recipe-found = yes
                    buf_fbr-gds-obj.default-recipe-code = buf_recipe.recipe-code
                .
            end.
            if v-recipe-found = no
            then do:
                for first buf_recipe no-lock
                    where buf_recipe.obj-type    = p-obj-type
                      and buf_recipe.obj-code    = p-obj-code
                      and buf_recipe.artic       = buf_goods.artic
                      and buf_recipe.prod-type   = buf_goods.prod-type
                      and buf_recipe.prod-code   = buf_goods.prod-code
                      or (
                          buf_recipe.obj-type    = ""
                      and buf_recipe.obj-code    = 0
                      and buf_recipe.artic       = buf_goods.artic
                      and buf_recipe.prod-type   = buf_goods.prod-type
                      and buf_recipe.prod-code   = buf_goods.prod-code
                          )
                :
                    assign
                        v-recipe-found = yes
                        buf_fbr-gds-obj.default-recipe-code = buf_recipe.recipe-code
                    .
                end.
                if v-recipe-found = no
                then do:
                    assign
                        buf_fbr-gds-obj.default-recipe-code = ""
                    .
                end.
            end.
        end.
    end.
end.
end procedure.
procedure fbrlib-get-obj-recipe :
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-gds-code       as integer      no-undo.
define output parameter p-recipe-code   as character    no-undo.
    define buffer buf_fbr-gds-obj   for ub.fbr-gds-obj.
do
for buf_fbr-gds-obj
on error undo, return error
:
    find first buf_fbr-gds-obj no-lock
         where buf_fbr-gds-obj.obj-type = p-obj-type
           and buf_fbr-gds-obj.obj-code = p-obj-code
           and buf_fbr-gds-obj.gds-code = p-gds-code
    no-error.
    if available buf_fbr-gds-obj
    then do:
        assign
            p-recipe-code = buf_fbr-gds-obj.default-recipe-code
        .
    end.
    else do:
        assign
            p-recipe-code = ""
        .
    end.
end.
end procedure.
procedure fbrlib-create-or-update-recipe-gds :
define input parameter p-recipe-code    as character        no-undo.
define input parameter p-gds-code       as integer          no-undo.
define input parameter p-is-waste       as logical          no-undo.
define input parameter p-qnty           as decimal          no-undo.
define input parameter p-proc-number    as integer          no-undo.
define input parameter p-nws-self       as logical          no-undo.
    define variable v-max-proc-num  as integer      no-undo.
    define variable v-recipe-type   as character    no-undo.
    define buffer buf_goods             for ub.goods.
    define buffer buf_recipe-gds        for ub.recipe-gds.
    define buffer buf_recipe            for ub.recipe.
    define buffer buf_proc_recipe-gds   for ub.recipe-gds.
do
for buf_goods
  , buf_recipe-gds
  , buf_recipe
  , buf_proc_recipe-gds
on error undo, return error
:
    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    .
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    find first buf_recipe-gds
         where buf_recipe-gds.recipe-code = p-recipe-code
           and buf_recipe-gds.prod-type   = buf_goods.prod-type
           and buf_recipe-gds.prod-code   = buf_goods.prod-code
           and buf_recipe-gds.artic       = buf_goods.artic
    no-error.
    if not available buf_recipe-gds
    then do:
        create buf_recipe-gds.
        assign
            buf_recipe-gds.recipe-code = p-recipe-code
            buf_recipe-gds.gds-code    = p-gds-code
            buf_recipe-gds.prod-type   = buf_goods.prod-type
            buf_recipe-gds.prod-code   = buf_goods.prod-code
            buf_recipe-gds.artic       = buf_goods.artic
        .
        assign
            buf_recipe-gds.is-waste    = no
            buf_recipe-gds.qnty        = 0
            buf_recipe-gds.coeff-waste = 0
            buf_recipe-gds.brutto-qnty = 0
            buf_recipe-gds.proc-number = 0
            buf_recipe-gds.nws-self    = no
        .
    end.
    assign
        buf_recipe-gds.is-waste    = p-is-waste
    .
    run fbrlib-get-recipe-type in this-procedure (
          input "":U
        , input buf_recipe-gds.recipe-code
        , output v-recipe-type
    ).
    if v-recipe-type <> 'производство':U
    then do:
        assign
            buf_recipe-gds.calc-method = 1
            buf_recipe-gds.qnty        = p-qnty
            buf_recipe-gds.brutto-qnty = p-qnty
            buf_recipe-gds.coeff-waste = 0
        .
    end.
    else do:
        assign
            buf_recipe-gds.calc-method = 1
            buf_recipe-gds.brutto-qnty = p-qnty
        .
        run fbrlib-calc-brutto in this-procedure (
              input v-recipe-type
            , input 0
            , input 0
            , input buf_recipe-gds.coeff-waste
            , input buf_recipe-gds.brutto-qnty
            , input 1
            , output buf_recipe-gds.qnty
            , output buf_recipe-gds.coeff-waste
            , output buf_recipe-gds.brutto-qnty
            , output buf_recipe-gds.calc-method
        ).
    end.
    assign
        buf_recipe-gds.nws-self    = p-nws-self
    .
    if buf_recipe.recipe-type = 'альтернатива':U
    and buf_recipe-gds.proc-number <> 0
    then do:
    end.
    else do:
        if p-proc-number <> 0
        then do:
            assign
                buf_recipe-gds.proc-number = p-proc-number
            .
        end.
        else do:
            assign
                v-max-proc-num = 0
            .
            for each buf_proc_recipe-gds no-lock
               where buf_proc_recipe-gds.recipe-code = p-recipe-code
            :
                if recid( buf_proc_recipe-gds ) <> recid( buf_recipe-gds )
                then do:
                    assign
                        v-max-proc-num = ( if v-max-proc-num < buf_proc_recipe-gds.proc-number then buf_proc_recipe-gds.proc-number else v-max-proc-num )
                    .
                end.
            end.
            assign
                buf_recipe-gds.proc-number = v-max-proc-num + 1
            .
        end.
    end.
end.
end procedure.
PROCEDURE fbrlib-create-or-update-recipe :
define input parameter p-mode               as character    no-undo.
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-recipe-code        as character    no-undo.
define input parameter p-recipe-type        as character    no-undo.
define input parameter p-gds-code           as integer      no-undo.
define input parameter p-name               as character    no-undo.
define input parameter p-design             as character    no-undo.
define input parameter p-order              as integer      no-undo.
define input parameter p-quality            as character    no-undo.
define input parameter p-ref-num            as character    no-undo.
define input parameter p-technique          as character    no-undo.
define input parameter p-template           as character    no-undo.
define input parameter p-qnty               as decimal      no-undo.
define input parameter p-portion-qnty       as integer      no-undo.
define input parameter p-portion-weight     as decimal      no-undo.
define output parameter p-new-recipe-code   as character    no-undo.
    define variable v-host-code         as integer      no-undo.
    define variable v-fbr-gds-obj-recid as recid        no-undo.
    define buffer buf_recipe    for ub.recipe.
    define buffer buf_goods     for ub.goods.
do
for buf_recipe
  , buf_goods
on error undo, return error
:
    if p-mode <> 'ДОБАВЛЕНИЕ':U
    and p-mode <> 'ИЗМЕНЕНИЕ':U
    then do:
        message
            skip "Ошибка задания типа операции для создания или измения рецепта."
            skip (1)
            skip "Задан тип операции:" p-mode
        view-as alert-box error.
        undo, return error .
    end.
    if p-recipe-code = ""
    then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
        find first buf_goods no-lock
             where buf_goods.gds-code = p-gds-code
        .
        create buf_recipe .
        run fbrcode-gen-recipe-code in this-procedure (
              input p-obj-type
            , input p-obj-code
            , output buf_recipe.recipe-code
        ).
        assign
            buf_recipe.artic               = buf_goods.artic
            buf_recipe.prod-type           = buf_goods.prod-type
            buf_recipe.prod-code           = buf_goods.prod-code
            buf_recipe.recipe-type         = p-recipe-type
            buf_recipe.recipe-name         = ( if p-name = "" then buf_goods.gds-name else p-name )
            buf_recipe.gds-code            = p-gds-code
            buf_recipe.host-code           = v-host-code
            buf_recipe.obj-type            = p-obj-type
            buf_recipe.obj-code            = p-obj-code
            buf_recipe.recipe-design       = ""
            buf_recipe.recipe-order        = 0
            buf_recipe.recipe-quality      = ""
            buf_recipe.recipe-ref-num      = ""
            buf_recipe.recipe-technique    = ""
            buf_recipe.recipe-template     = ""
            buf_recipe.qnty                = 1.0
            buf_recipe.portion-qnty        = 1
            buf_recipe.portion-weight      = 0
        .
    end.
    if p-name <> ""
    then do:
        assign
            buf_recipe.recipe-name = p-name
        .
    end.
    assign
        buf_recipe.recipe-design       = p-design
        buf_recipe.recipe-order        = p-order
        buf_recipe.recipe-quality      = p-quality
        buf_recipe.recipe-ref-num      = p-ref-num
        buf_recipe.recipe-technique    = p-technique
        buf_recipe.recipe-template     = p-template
        buf_recipe.qnty                = p-qnty
        buf_recipe.portion-qnty        = p-portion-qnty
        buf_recipe.portion-weight      = p-portion-weight
    .
    assign
        p-new-recipe-code = buf_recipe.recipe-code
    .
    run fbrlib-set-default-recipe in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input buf_goods.gds-code
    ).
end.
END PROCEDURE.
PROCEDURE fbrlib-delete-fact-fbr-doc :
define input parameter parparentproc-handle as widget-handle no-undo .
define input parameter p-doc-code   as character no-undo.
define input parameter p-chip-num   like ub.c-trn-doc.chip-num no-undo .
    define variable v-shift-on      as logical      no-undo.
    define variable v-shift-date    as date         no-undo.
    define variable v-shift-num     as integer      no-undo.
    define variable v-shift-name    as character    no-undo.
    define variable v-obj-date      as date         no-undo.
    define variable v-chip-num      as integer      no-undo.
    define buffer buf_fbr-doc       for ub.fbr-doc.
    define buffer buf_fbr-line      for ub.fbr-line.
    define buffer buf_c-fbr-doc     for ub.c-fbr-doc.
    define buffer buf_fbr-recipe     for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds for ub.fbr-recipe-gds.
    define buffer buf_marking-lines for ub.marking-lines .
    define buffer buf_marking       for ub.marking .
    define buffer buf_goods         for ub.goods .
do
for buf_fbr-doc
  , buf_fbr-line
  , buf_c-fbr-doc
  , buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_goods
  , buf_marking
  , buf_marking-lines
on error undo, return error
:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
    if search ("delfbr.err") <> ?
    then do:
        os-delete "delfbr.err".
    end.
  _del-block:
    do transaction
  on error undo _del-block, return error return-value
  on endkey undo _del-block , return error return-value
  on stop undo _del-block , return error return-value
    :
        find first buf_fbr-doc exclusive-lock
             where buf_fbr-doc.doc-code = p-doc-code
        no-error.
        if not available buf_fbr-doc
        then do:
      undo _del-block, return error substitute("&1 &2 &3&4Не найден документ производства &5 для удаления."
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,chr(10)
                                        , p-doc-code).
        end.
        run fbrlib-delete-fact-trn-doc in this-procedure (
            input parparentproc-handle
           ,input p-doc-code
           ,input 'при':U
           ,input p-chip-num
           ,output v-chip-num
        ) no-error.
        if error-status :error
        then do:
            run fbrlib-print-del-error-message in this-procedure .
      undo _del-block, return error.
        end.
        assign
        p-chip-num = (if p-chip-num = ?
                      then v-chip-num
                      else p-chip-num).
        run fbrlib-delete-fact-trn-doc in this-procedure (
            input parparentproc-handle
           ,input p-doc-code
           ,input 'рас':U
           ,input p-chip-num
           ,output v-chip-num
        ) no-error.
        if error-status :error
        then do:
            run fbrlib-print-del-error-message in this-procedure .
      undo _del-block, return error.
        end.
        run fbrlib-delete-fact-trn-doc in this-procedure (
            input parparentproc-handle
           ,input p-doc-code
           ,input 'спи':U
           ,input p-chip-num
           ,output v-chip-num
        ) no-error.
        if error-status :error
        then do:
            run fbrlib-print-del-error-message in this-procedure .
      undo _del-block, return error.
        end.
        create buf_c-fbr-doc.
        buffer-copy buf_fbr-doc to buf_c-fbr-doc.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
  ,output v-obj-date
  ) no-error .
        if error-status :error
        or v-obj-date = ?
        then do:
      undo _del-block, return error "Нет текущей даты на объекте документа.".
        end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  )  .
        if v-shift-on
        then do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
            if error-status :error
            then do:
        undo _del-block, return error "Ошибка при поиске текущей смены на объекте".
            end.
        end.
        else do:
            assign
                v-shift-date = ?
                v-shift-num  = ?
                v-shift-name = ?
            .
        end.
        define variable v-today       as date         no-undo.
        define variable v-time        as integer      no-undo.
        run cur-time in this-procedure (
              output v-today
            , output v-time
        ).
        assign
            buf_c-fbr-doc.chip-num         = (if p-chip-num <> ? then p-chip-num else next-value( s-corr-chip, ub  ))
            buf_c-fbr-doc.corr-user-name   = v-cntxt-userid
            buf_c-fbr-doc.corr-user-db-num = v-cntxt-db-num
            buf_c-fbr-doc.corr-date        = v-today
            buf_c-fbr-doc.corr-time        = v-time
            buf_c-fbr-doc.corr-shift-date  = v-shift-date
            buf_c-fbr-doc.corr-shift-num   = v-shift-num
            buf_c-fbr-doc.corr-shift-name  = v-shift-name
            buf_c-fbr-doc.is-del           = yes
        .
        assign
            buf_fbr-doc.is-del = yes
        .
        for each buf_fbr-line exclusive-lock
           where buf_fbr-line.doc-code = p-doc-code
    on error  undo _del-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _del-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _del-block, return error substitute( "&1. endkey", vss-workfile )
        :
            for first buf_goods no-lock where buf_goods.artic      = buf_fbr-line.artic
                                          and buf_goods.prod-type  = buf_fbr-line.prod-type
                                          and buf_goods.prod-code  = buf_fbr-line.prod-code,
            each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = buf_goods.gds-code
                                                    and buf_marking-lines.obj-type = buf_fbr-doc.obj-type
                                                    and buf_marking-lines.obj-code = buf_fbr-doc.obj-code
                                                    and buf_marking-lines.in-code  = "manufacturing"
                                                    and buf_marking-lines.out-code = buf_fbr-line.doc-code
                                                    and buf_marking-lines.part-code = buf_fbr-line.recipe-code
                                                    and buf_marking-lines.prt-code = 0
            :
              for first buf_marking exclusive-lock where buf_marking.mark begins buf_marking-lines.mark :
                assign
                  buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB when buf_fbr-line.is-comp
                .
              end .
              delete buf_marking-lines.
            end .
            delete buf_fbr-line.
        end.
        for each buf_fbr-recipe exclusive-lock
           where buf_fbr-recipe.doc-code = p-doc-code
    on error  undo _del-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _del-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _del-block, return error substitute( "&1. endkey", vss-workfile )
        :
            delete buf_fbr-recipe.
        end.
        for each buf_fbr-recipe-gds exclusive-lock
           where buf_fbr-recipe-gds.doc-code = p-doc-code
    on error  undo _del-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _del-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _del-block, return error substitute( "&1. endkey", vss-workfile )
        :
            delete buf_fbr-recipe-gds.
        end.
        delete buf_fbr-doc.
    end.
end.
END PROCEDURE.
PROCEDURE fbrlib-del-trn-doc :
do
on error undo, return error
:
define input parameter parparentproc        as widget-handle no-undo .
define input parameter p-fbr-doc-doc-code   as character    no-undo.
define input parameter p-trn-doc-type       as character    no-undo.
define input parameter p-phchip-num         like ub.c-trn-doc.chip-num no-undo .
define output parameter p-chip-num           like ub.c-trn-doc.chip-num no-undo .
    define variable v-trn-doc-doc-code  as character     no-undo.
    define buffer buf_trn-doc       for ub.trn-doc.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run fbrcode-trn-doc in this-procedure (
          input 'производство':U
        , input p-fbr-doc-doc-code
        , input p-trn-doc-type
        , output v-trn-doc-doc-code
    ).
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = v-trn-doc-doc-code
    no-error.
    if available buf_trn-doc
    then do:
        run str/del-doc.p (
              input parparentproc
            , input buf_trn-doc.doc-code
            , input v-cntxt-db-num
            , input "del-doc.err"
            , input ?
            , input p-fbr-doc-doc-code
            , input v-cntxt-userid
            , input 0
            , input p-phchip-num
            , output p-chip-num
        ) no-error.
        if error-status :error
        then do:
          undo, return error substitute("Не удалось удалить складской документ &1, созданный по документу производства &2.&3&4&3&5"
                                        ,v-trn-doc-doc-code
                                        ,p-fbr-doc-doc-code
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value ).
        end.
    end.
end.
END PROCEDURE.
PROCEDURE fbrlib-delete-fact-trn-doc :
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-fbr-doc-code   as character        no-undo.
define input parameter p-doc-type       as character    no-undo.
define input parameter p-ph-chip-num       like ub.c-trn-doc.chip-num no-undo .
define output parameter p-chip-num      like ub.c-trn-doc.chip-num no-undo .
    define variable v-doc-code          as character        no-undo.
    define variable v-ext-doc-type      as character        no-undo.
    define variable v-trn-doc-recid     as recid            no-undo.
    define variable varchip-code        as integer          no-undo.
    define variable varchip-code2       as integer          no-undo.
    define variable v-chip-counter      as integer          no-undo.
    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_pri_trn-doc   for ub.trn-doc.
    define buffer buf_cons_trn-doc  for ub.trn-doc.
do
for buf_trn-doc
  , buf_pri_trn-doc
  , buf_cons_trn-doc
on error undo, return error
:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run fbrcode-trn-doc in this-procedure (
          input 'производство':U
        , input p-fbr-doc-code
        , input p-doc-type
        , output v-doc-code
    ).
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = v-doc-code
    no-error.
    if not available buf_trn-doc
    then do:
        if p-doc-type <> 'спи':U
        then do:
            message
                "Не найден документ '" p-doc-type "'"
                "по документу производства " p-fbr-doc-code
            view-as alert-box.
            undo, return error.
        end.
        else do:
        end.
    end.
    else do:
        assign
            v-trn-doc-recid = recid( buf_trn-doc )
            v-ext-doc-type  = buf_trn-doc.ext-doc-type
        .
        if v-ext-doc-type = 'ev':U
        then do:
            find first buf_pri_trn-doc no-lock
                 where buf_pri_trn-doc.out-code     = v-doc-code
                   and buf_pri_trn-doc.ext-doc-type = 'iv':U
            no-error.
            if available buf_pri_trn-doc
            then do:
                run str/del-doc.p (
                      input parparentproc
                    , input buf_pri_trn-doc.doc-code
                    , input v-cntxt-db-num
                    , input "delfbr.err"
                    , input ?
                    , input p-fbr-doc-code
                    , input v-cntxt-userid
                    , input 0
                    , input (if p-ph-chip-num <> ?
                            then p-ph-chip-num
                            else (if varchip-code <> 0
                                then varchip-code
                                else ?)
                            )
                    , output varchip-code2
                ) no-error.
                if error-status :error
                then do:
                  undo, return error substitute("Ошибка при удалении складского документа &1, созданный по документу производства &2.&3&4&3&5"
                                                ,buf_pri_trn-doc.doc-code
                                                ,p-fbr-doc-code
                                                , chr(10)
                                                , error-status:get-message(1)
                                                , return-value ).
                end.
            end.
        end.
        define buffer buf_out_trn-doc       for ub.trn-doc.
        if p-doc-type = 'при':U
        then do:
            assign
                v-chip-counter = 0
            .
            for each buf_out_trn-doc exclusive-lock
               where buf_out_trn-doc.out-code = buf_trn-doc.doc-code
            on error undo, return error
            :
                assign
                    v-chip-counter = v-chip-counter + 1
                .
                if v-chip-counter > 1
                then do:
                    assign
                        varchip-code = varchip-code2
                    .
                end.
                run str/del-doc.p (
                      input parparentproc
                    , input buf_out_trn-doc.doc-code
                    , input v-cntxt-db-num
                    , input "delfbr.err"
                    , input ?
                    , input p-fbr-doc-code
                    , input v-cntxt-userid
                    , input 0
                    , input (if p-ph-chip-num <> ?
                            then p-ph-chip-num
                            else (if varchip-code <> 0
                                then varchip-code
                                else ?)
                            )
                    , output varchip-code2
                ) no-error.
                if error-status :error
                then do:
                  undo, return error substitute("Ошибка при удалении складского документа &1, связанного со складским документов прихода &2, созданный по документу производства &3.&4&5&4&6"
                                                ,buf_out_trn-doc.doc-code
                                                ,buf_trn-doc.doc-code
                                                ,p-fbr-doc-code
                                                , chr(10)
                                                , error-status:get-message(1)
                                                , return-value ).
                end.
            end.
        end.
        run str/del-doc.p (
              input parparentproc
            , input buf_trn-doc.doc-code
            , input v-cntxt-db-num
            , input "delfbr.err"
            , input ?
            , input p-fbr-doc-code
            , input v-cntxt-userid
            , input 0
            , input (if p-ph-chip-num <> ?
                     then p-ph-chip-num
                     else (if varchip-code <> 0
                           then varchip-code
                           else ?)
                     )
            , output varchip-code2
        ) no-error.
        if error-status :error
        then do:
            undo, return error substitute("Ошибка при удалении складского документа &1, созданный по документу производства &2.&3&4&3&5"
                                          ,buf_trn-doc.doc-code
                                          ,p-fbr-doc-code
                                          , chr(10)
                                          , error-status:get-message(1)
                                          , return-value ).
        end.
        if p-doc-type = 'рас':U
        or p-doc-type = 'спи':U
        then do:
            assign
                v-chip-counter = 0
            .
            for each buf_cons_trn-doc no-lock
               where buf_cons_trn-doc.out-code      = v-doc-code
                 and buf_cons_trn-doc.ext-doc-type  = 'pc':U
            :
                assign
                    v-trn-doc-recid = recid( buf_cons_trn-doc )
                    v-chip-counter = v-chip-counter + 1
                .
                assign
                varchip-code = if v-chip-counter = 2
                               then varchip-code2
                               else varchip-code.
                run str/del-doc.p (
                      input parparentproc
                    , input buf_cons_trn-doc.doc-code
                    , input v-cntxt-db-num
                    , input "delfbr.err"
                    , input ?
                    , input ?
                    , input v-cntxt-userid
                    , input 0
                    , input (if p-ph-chip-num <> ?
                             then p-ph-chip-num
                             else ( if v-chip-counter = 1
                                    then ?
                                    else varchip-code )
                             )
                    , output varchip-code2
                ) no-error.
                if error-status :error
                then do:
                    undo, return error substitute("Ошибка при удалении складского документа смены типа приобретения &1, созданный по документу производства &2.&3&4&3&5"
                                                  ,buf_cons_trn-doc.doc-code
                                                  ,p-fbr-doc-code
                                                  , chr(10)
                                                  , error-status:get-message(1)
                                                  , return-value ).
                end.
                assign
                    p-chip-num = varchip-code2
                .
            end.
        end.
        assign
            p-chip-num = varchip-code2
        .
    end.
end.
END PROCEDURE.
PROCEDURE fbrlib-print-del-error-message :
do
on error undo, return error
:
    define variable v-user-action   as character    no-undo.
    define variable v-printed       as logical      no-undo.
    message
        vss-workfile vss-revision vss-description
        skip "Ошибка при удалении документа."
        skip return-value
        skip trim(error-status :get-message(1))
        skip trim(error-status :get-message(2))
        skip trim(error-status :get-message(3))
    view-as alert-box error.
    if search ("delfbr.err") <> ?
    then do:
      run gbl/prnfilen.w
        (input  "Ошибки при удалении документа производства"
        ,input  0
        ,input  "delfbr.err"
        ,input  7
        ,output v-user-action
        ,output v-printed
        ).
    end.
end.
END PROCEDURE.
procedure fbrlib-calc-brutto :
define input parameter p-recipe-type        as character        no-undo.
define input parameter p-netto              as decimal          no-undo.
define input parameter p-coeff-value        as decimal          no-undo.
define input parameter p-coeff-waste        as decimal          no-undo.
define input parameter p-brutto             as decimal          no-undo.
define input parameter p-calc-method        as integer          no-undo.
define output parameter p-new-netto         as decimal          no-undo.
define output parameter p-new-coeff-waste   as decimal          no-undo.
define output parameter p-new-brutto        as decimal          no-undo.
define output parameter p-new-calc-method   as integer          no-undo.
do
on error undo, return error
:
    if p-recipe-type <> 'производство':U
    then do:
        assign
            p-new-coeff-waste = 0
            p-new-calc-method = 1
            p-new-netto       = ( if p-calc-method = 1 then p-brutto else p-netto )
            p-new-brutto      = ( if p-calc-method = 1 then p-brutto else p-netto )
        .
    end.
    else do:
        assign
            p-new-calc-method = p-calc-method
        .
        if p-coeff-waste = 0
        then do:
            assign
                p-coeff-value = 0
            .
        end.
        case p-calc-method
        :
            when 1
            then do:
                assign
                    p-new-netto         = p-brutto * ( 100 - p-coeff-value - p-coeff-waste ) / 100
                    p-new-coeff-waste   = p-coeff-waste
                    p-new-brutto        = p-brutto
                .
            end.
            when 2
            then do:
                assign
                    p-new-netto         = p-netto
                    p-new-coeff-waste   = 100 - p-coeff-value - ( 100 * p-netto / p-brutto )
                    p-new-brutto        = p-brutto
                .
            end.
            when 3
            then do:
                assign
                    p-new-netto         = p-netto
                    p-new-coeff-waste   = p-coeff-waste
                    p-new-brutto        = 100 * p-netto / ( 100 - p-coeff-value - p-coeff-waste )
                .
            end.
            otherwise do:
                define variable v-yesno    as logical      no-undo.
                assign
                    v-yesno = yes
                .
                message
                    "Неверный метод для расчета брутто, нетто и процента потерь."
                    skip "Значение метода должно быть 1, 2 или 3."
                    skip(1)
                    skip "Заданное значение:" p-calc-method
                    skip(1)
                    skip "Установить значение метода расчета 1"
                    skip "(расчет нетто по брутто и проценту потерь)?"
                view-as alert-box warning
                buttons yes-no
                title "Неверное значение метода пересчета в строках документа-производства"
                update v-yesno
                .
                if v-yesno = yes
                then do:
                    assign
                        p-new-calc-method   = 1
                        p-new-netto         = p-brutto * ( 100 - p-coeff-value - p-coeff-waste ) / 100
                        p-new-coeff-waste   = p-coeff-waste
                        p-new-brutto        = p-brutto
                    .
                end.
                else do:
                    message
                            vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка расчета брутто, нетто и процента потерь."
                        skip return-value
                        skip trim(error-status :get-message(1))
                            trim(error-status :get-message(2))
                            trim(error-status :get-message(3))
                    view-as alert-box error
                    title "Неверное значение метода расчета"
                    .
                    undo, return error .
                end.
            end.
        end case.
    end.
end.
end procedure.
procedure fbrlib-check-brutto :
define input parameter p-recipe-type        as character        no-undo.
define input parameter p-netto              as decimal          no-undo.
define input parameter p-coeff-value        as decimal          no-undo.
define input parameter p-coeff-waste        as decimal          no-undo.
define input parameter p-brutto             as decimal          no-undo.
define input parameter p-calc-method        as integer          no-undo.
define output parameter p-error-message     as character        no-undo.
define output parameter p-not-good          as logical          no-undo.
do
on error undo, return error
:
    if p-recipe-type <> 'производство':U
    then do:
        if p-netto <> p-brutto
        or p-coeff-waste <> 0
        then do:
            assign
                p-not-good      = yes
                p-error-message = substitute( "Во всех рецептах кроме рецепта производства должно выполняться:&1брутто = нетто и процент потерь = 0.&1&1Тип рецепта: &2&1Брутто: &3&1Нетто: &4&1Процент потерь: &5"
                                        , chr(10), p-recipe-type, p-brutto, p-netto, p-coeff-waste )
            .
        end.
    end.
    else do:
        if p-coeff-waste = 0
        then do:
            assign
                p-coeff-value = 0
            .
        end.
        case p-calc-method
        :
            when 1
            then do:
                if round( p-netto, 9 ) <> round( p-brutto * ( 100 - p-coeff-value - p-coeff-waste ) / 100, 9 )
                then do:
                    assign
                        p-not-good      = yes
                        p-error-message = substitute( "Ошибка расчета нетто ( &2 ) &1 по брутто ( &3 ) &1 и процентам потерь ( &4, &5 )."
                                                , chr(10), p-netto, p-brutto, p-coeff-value, p-coeff-waste )
                    .
                end.
            end.
            when 2
            then do:
                if round( p-coeff-waste, 9 ) <> round( 100 - p-coeff-value - ( 100 * p-netto / p-brutto ), 9 )
                then do:
                    assign
                        p-not-good      = yes
                        p-error-message =  substitute( "Ошибка расчета процента потерь ( &2 ) &1 по нетто ( &3 ) &1 брутто ( &4 ) &1 и cезонному проценту ( &5 )."
                                                , chr(10), p-coeff-waste, p-netto, p-brutto, p-coeff-value )
                    .
                end.
            end.
            when 3
            then do:
                if round( p-brutto, 9 ) <> round( 100 * p-netto / ( 100 - p-coeff-value - p-coeff-waste ), 9 )
                then do:
                    assign
                        p-not-good      = yes
                        p-error-message = substitute( "Ошибка расчета брутто ( &3 ) &1 по нетто ( &2 ) &1 и процентам потерь ( &4, &5 )."
                                                , chr(10), p-netto, p-brutto, p-coeff-value, p-coeff-waste )
                    .
                end.
            end.
            otherwise do:
                assign
                    p-not-good      = yes
                    p-error-message = substitute( "Ошибка ввода метода расчета ( &1 ).", p-calc-method )
                .
            end.
        end case.
    end.
end.
end procedure.
procedure fbrlib-check-fbr-recipe :
define input parameter p-doc-code       as character        no-undo.
define input parameter p-recipe-code    as character        no-undo.
define output parameter p-is-correct    as logical          no-undo.
    define variable v-comp-factor    as decimal      no-undo.
    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_fbr-line          for ub.fbr-line.
do
for buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_fbr-line
on error undo, return error
:
    assign
        p-is-correct = yes
    .
    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code    = p-doc-code
           and buf_fbr-recipe.recipe-code = p-recipe-code no-error
    .
    if not available buf_fbr-recipe then do:
      undo, return error substitute("Не найден рецепт (fbr-recipe) с кодом &1 для  документа пр-ва &2", p-recipe-code, p-doc-code).
    end.
    if buf_fbr-recipe.recipe-type = 'альтернатива':U
    then do:
    end.
    else do:
        find first buf_fbr-line no-lock
             where buf_fbr-line.doc-code    = buf_fbr-recipe.doc-code
               and buf_fbr-line.is-comp     = yes
               and buf_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
               and buf_fbr-line.artic       = buf_fbr-recipe.artic
               and buf_fbr-line.prod-type   = buf_fbr-recipe.prod-type
               and buf_fbr-line.prod-code   = buf_fbr-recipe.prod-code
        .
        assign
            v-comp-factor = buf_fbr-line.fact-qnty / buf_fbr-recipe.qnty
        .
        recipe-line-cycle:
        for each buf_fbr-recipe-gds no-lock
           where buf_fbr-recipe-gds.doc-code    = p-doc-code
             and buf_fbr-recipe-gds.recipe-code = p-recipe-code
        on error undo, return error
        :
            find first buf_fbr-line no-lock
                 where buf_fbr-line.doc-code    = buf_fbr-recipe-gds.doc-code
                   and buf_fbr-line.is-comp     = no
                   and buf_fbr-line.recipe-code = buf_fbr-recipe-gds.recipe-code
                   and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
                   and buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                   and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
            .
            if absolute( buf_fbr-line.fact-qnty / buf_fbr-recipe-gds.brutto-qnty - v-comp-factor ) > 0.000000001
            then do:
                assign
                    p-is-correct = no
                .
                leave recipe-line-cycle.
            end.
        end.
    end.
end.
end procedure.
procedure fbrlib-get-recipe-type :
define input parameter p-fbr-doc-code   as character        no-undo.
define input parameter p-recipe-code    as character        no-undo.
define output parameter p-recipe-type   as character        no-undo.
    define buffer buf_recipe        for ub.recipe.
    define buffer buf_fbr-recipe    for ub.fbr-recipe.
do
for buf_recipe
  , buf_fbr-recipe
on error undo, return error
:
    if p-fbr-doc-code = ""
    then do:
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = p-recipe-code
        no-error.
        if available buf_recipe
        then do:
            assign
                p-recipe-type = buf_recipe.recipe-type
            .
        end.
        else do:
            assign
                p-recipe-type = "":U
            .
        end.
    end.
    else do:
        find first buf_fbr-recipe no-lock
             where buf_fbr-recipe.doc-code      = p-fbr-doc-code
               and buf_fbr-recipe.recipe-code   = p-recipe-code
        no-error.
        if available buf_fbr-recipe
        then do:
            assign
                p-recipe-type = buf_fbr-recipe.recipe-type
            .
        end.
        else do:
            assign
                p-recipe-type = "":U
            .
        end.
    end.
end.
end procedure.
PROCEDURE calc-comp-from-ingr :
define input parameter p-fbr-v-fbr-doc-line-recid           as recid        no-undo.
define input parameter p-fact-qnty                          as decimal      no-undo.
define output parameter p-comp-fbr-v-fbr-doc-line-recid     as recid        no-undo.
define output parameter p-comp-qnty                         as decimal      no-undo.
    define variable v-ingr-qnty     as decimal       no-undo.
    define buffer buf_i_fbr-line    for ub.fbr-line.
    define buffer buf_fbr-line      for ub.fbr-line.
    define buffer buf_recipe        for ub.fbr-recipe.
    define buffer buf_recipe-gds    for ub.fbr-recipe-gds.
do
for buf_i_fbr-line
  , buf_fbr-line
  , buf_recipe
  , buf_recipe-gds
on error undo, return error
:
    find first buf_i_fbr-line no-lock
         where recid( buf_i_fbr-line ) = p-fbr-v-fbr-doc-line-recid
    .
    find first buf_recipe no-lock
         where buf_recipe.doc-code      = buf_i_fbr-line.doc-code
           and buf_recipe.recipe-code   = buf_i_fbr-line.recipe-code
    no-error.
    if not available buf_recipe
    then do:
        message
                vss-workfile vss-revision vss-description
            skip "В строке производства не указан рецепт."
            skip "Невозможно рассчитать количество составного товара."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if buf_recipe.recipe-type = 'альтернатива':U
    then do:
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code    = buf_i_fbr-line.doc-code
             and buf_fbr-line.trn-type    = buf_i_fbr-line.trn-type
             and buf_fbr-line.recipe-code = buf_i_fbr-line.recipe-code
        on error undo, return error
        :
            find first buf_recipe-gds no-lock
                 where buf_recipe-gds.doc-code    = buf_i_fbr-line.doc-code
                   and buf_recipe-gds.recipe-code = buf_i_fbr-line.recipe-code
                   and buf_recipe-gds.artic       = buf_fbr-line.artic
                   and buf_recipe-gds.prod-type   = buf_fbr-line.prod-type
                   and buf_recipe-gds.prod-code   = buf_fbr-line.prod-code
            .
            assign
                p-comp-qnty         = p-comp-qnty       + ( buf_fbr-line.fact-qnty * buf_recipe-gds.brutto-qnty )
            .
        end.
        assign
            p-comp-qnty         = p-comp-qnty       / buf_recipe.qnty
        .
    end.
    else do:
        find first buf_recipe-gds no-lock
             where buf_recipe-gds.doc-code    = buf_i_fbr-line.doc-code
               and buf_recipe-gds.recipe-code = buf_i_fbr-line.recipe-code
               and buf_recipe-gds.artic       = buf_i_fbr-line.artic
               and buf_recipe-gds.prod-type   = buf_i_fbr-line.prod-type
               and buf_recipe-gds.prod-code   = buf_i_fbr-line.prod-code
        .
        assign
            p-comp-qnty = p-fact-qnty / buf_recipe-gds.brutto-qnty * buf_recipe.qnty
        .
    end.
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code    = buf_i_fbr-line.doc-code
           and buf_fbr-line.is-comp     = yes
           and buf_fbr-line.recipe-code = buf_i_fbr-line.recipe-code
    .
    assign
        p-comp-fbr-v-fbr-doc-line-recid = recid( buf_fbr-line )
    .
end.
END PROCEDURE.
PROCEDURE get-temp_dressing-ingr-used-qnty :
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-gds-code       as integer      no-undo.
define output parameter p-line-qnty     as decimal      no-undo.
define output parameter p-used-qnty     as decimal      no-undo.
define output parameter p-recipe-qnty   as decimal      no-undo.
    define buffer buf_temp_dressing-ingr    for temp_dressing-ingr.
do
for buf_temp_dressing-ingr
on error undo, return error
:
    find first buf_temp_dressing-ingr no-lock
         where buf_temp_dressing-ingr.recipe-code = p-recipe-code
           and buf_temp_dressing-ingr.gds-code    = p-gds-code
    no-error.
    if available buf_temp_dressing-ingr
    then do:
        assign
            p-line-qnty     = buf_temp_dressing-ingr.line-qnty
            p-used-qnty     = buf_temp_dressing-ingr.used-qnty
            p-recipe-qnty   = buf_temp_dressing-ingr.recipe-qnty
        .
    end.
    else do:
        assign
            p-line-qnty     = 0
            p-used-qnty     = 0
            p-recipe-qnty   = 0
        .
    end.
end.
END PROCEDURE.
PROCEDURE fbrlib_adjust-recipe :
do
on error undo, return error
:
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-fbrhist-handle as handle no-undo .
define input parameter p-doc-code       as character    no-undo.
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-price-sale-obj-type as character no-undo .
define input parameter p-price-sale-obj-code as integer no-undo .
    define variable v-recipe-qnty       as decimal      no-undo.
    define variable v-comp-qnty         as decimal      no-undo.
    define variable v-recipe-gds-qnty   as decimal      no-undo.
    define variable v-ingr-qnty         as decimal      no-undo.
    define variable v-qnty              as decimal      no-undo.
    define variable v-coeff-waste       as decimal      no-undo.
    define variable v-brutto-qnty       as decimal      no-undo.
    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_el_fbr-recipe-gds for ub.fbr-recipe-gds.
    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code      = p-doc-code
           and buf_fbr-recipe.recipe-code   = p-recipe-code
    .
    assign
        v-recipe-qnty = buf_fbr-recipe.qnty
    .
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code    = p-doc-code
           and buf_fbr-line.is-comp     = yes
           and buf_fbr-line.recipe-code = p-recipe-code
    .
    assign
        v-comp-qnty = buf_fbr-line.fact-qnty
    .
    if buf_fbr-recipe.recipe-type = 'альтернатива':U
    then do:
    end.
    else do:
        for each buf_fbr-recipe-gds no-lock
           where buf_fbr-recipe-gds.doc-code    = p-doc-code
             and buf_fbr-recipe-gds.recipe-code = p-recipe-code
        on error undo, return error
        :
            find first buf_fbr-line no-lock
                 where buf_fbr-line.doc-code    = p-doc-code
                   and buf_fbr-line.is-comp     = no
                   and buf_fbr-line.recipe-code = p-recipe-code
                   and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
                   and buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                   and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
            .
            if buf_fbr-line.fact-qnty / v-comp-qnty <> buf_fbr-recipe-gds.brutto-qnty / v-recipe-qnty
            then do:
                do transaction
                on error undo, return error
                :
                    find first buf_el_fbr-recipe-gds exclusive-lock
                         where recid( buf_el_fbr-recipe-gds ) = recid( buf_fbr-recipe-gds )
                    .
                    assign
                        buf_el_fbr-recipe-gds.calc-method   = 1
                        buf_el_fbr-recipe-gds.brutto-qnty   = buf_fbr-line.fact-qnty * v-recipe-qnty / v-comp-qnty
                    .
                    run fbrlib-calc-brutto in this-procedure (
                          input buf_fbr-recipe.recipe-type
                        , input 0
                        , input buf_el_fbr-recipe-gds.coeff-value
                        , input buf_el_fbr-recipe-gds.coeff-waste
                        , input buf_el_fbr-recipe-gds.brutto-qnty
                        , input 1
                        , output buf_el_fbr-recipe-gds.qnty
                        , output buf_el_fbr-recipe-gds.coeff-waste
                        , output buf_el_fbr-recipe-gds.brutto-qnty
                        , output buf_el_fbr-recipe-gds.calc-method
                    ).
                end.
            end.
        end.
        run fbrlib_adjust-doc-lines in this-procedure (
              input parparentproc
            , input p-fbrhist-handle
            , input p-doc-code
            , input p-recipe-code
            , input p-price-sale-obj-type
            , input p-price-sale-obj-code
        ).
    end.
end.
END PROCEDURE.
PROCEDURE fbrlib_adjust-doc-lines :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-fbrhist-handle as handle no-undo .
define input parameter p-doc-code       as character    no-undo.
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-price-sale-obj-type as character no-undo .
define input parameter p-price-sale-obj-code as integer no-undo .
define variable v-comp-qnty         as decimal      no-undo.
define variable v-trn-type          as character    no-undo.
define variable v-ingr-qnty         as decimal      no-undo.
define variable v-recipe-qnty       as decimal      no-undo.
define variable v-fbr-v-fbr-doc-line-recid    as recid        no-undo.
define buffer buf_fbr-recipe        for ub.fbr-recipe.
define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
define buffer buf_fbr-line          for ub.fbr-line.
define buffer buf_coeff_fbr-line    for ub.fbr-line.
define buffer buf_goods             for ub.goods.
define buffer buf_fbr-doc           for ub.fbr-doc.
do
for buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_fbr-line
  , buf_coeff_fbr-line
  , buf_goods
  , buf_fbr-doc
on error undo, return error
:
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code      = p-doc-code
           and buf_fbr-line.is-comp       = yes
           and buf_fbr-line.recipe-code   = p-recipe-code
    .
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code      = p-doc-code
    .
    assign
        v-comp-qnty = buf_fbr-line.fact-qnty
        v-trn-type  = buf_fbr-line.trn-type
    .
    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code    = p-doc-code
           and buf_fbr-recipe.recipe-code = p-recipe-code
    .
    assign
    v-recipe-qnty = buf_fbr-recipe.qnty
    .
    do transaction
    on error undo, return error
    :
        for each buf_fbr-recipe-gds no-lock
           where buf_fbr-recipe-gds.doc-code      = p-doc-code
             and buf_fbr-recipe-gds.recipe-code   = p-recipe-code
        on error undo, return error
        :
            find first buf_fbr-line no-lock
                 where buf_fbr-line.doc-code    = buf_fbr-recipe-gds.doc-code
                   and buf_fbr-line.recipe-code = buf_fbr-recipe-gds.recipe-code
                   and buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                   and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
                   and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
            no-error.
            if not available buf_fbr-line
            then do:
                find first buf_goods no-lock
                     where buf_goods.artic      = buf_fbr-recipe-gds.artic
                       and buf_goods.prod-type  = buf_fbr-recipe-gds.prod-type
                       and buf_goods.prod-code  = buf_fbr-recipe-gds.prod-code
                .
                run str/fbr-crln.p (
                      input parparentproc
                    , input recid( buf_fbr-doc )
                    , input recid( buf_goods )
                    , input buf_fbr-recipe-gds.recipe-code
                    , input v-trn-type
                    , input no
                    , input no
                    , input buf_fbr-doc.obj-type
                    , input buf_fbr-doc.obj-code
                    , output v-fbr-v-fbr-doc-line-recid
                ).
                find first buf_fbr-line no-lock
                     where buf_fbr-line.doc-code    = buf_fbr-recipe-gds.doc-code
                       and buf_fbr-line.recipe-code = buf_fbr-recipe-gds.recipe-code
                       and buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                       and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
                       and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
                no-error.
                if not available buf_fbr-line
                then do:
                    undo, return error substitute("Не удалось создать строку документа производства &1 &2&3&4"
                                                   , p-doc-code
                                                   , buf_fbr-recipe-gds.artic
                                                   , buf_fbr-recipe-gds.prod-type
                                                   , buf_fbr-recipe-gds.prod-code).
                end.
            end.
            find first buf_coeff_fbr-line exclusive-lock
                 where recid( buf_coeff_fbr-line ) = recid( buf_fbr-line )
            .
            if buf_coeff_fbr-line.calc-method <> buf_fbr-recipe-gds.calc-method
            or buf_coeff_fbr-line.coeff-value <> buf_fbr-recipe-gds.coeff-value
            or buf_coeff_fbr-line.coeff-waste <> buf_fbr-recipe-gds.coeff-waste
            then do:
                assign
                    buf_coeff_fbr-line.calc-method = buf_fbr-recipe-gds.calc-method
                    buf_coeff_fbr-line.coeff-value = buf_fbr-recipe-gds.coeff-value
                    buf_coeff_fbr-line.coeff-waste = buf_fbr-recipe-gds.coeff-waste
                .
            end.
        end.
    end.
    define variable v-need-goods    as logical       no-undo.
    define variable v-need-goods-list       as character     no-undo.
    define variable v-need-goods-qnty-list  as character     no-undo.
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code    = buf_fbr-doc.doc-code
           and buf_fbr-line.is-comp     = yes
           and buf_fbr-line.recipe-code = p-recipe-code
    .
    run str/fbr-qnty.p (
          input parparentproc
        , input p-fbrhist-handle
        , input recid( buf_fbr-doc )
        , input recid( buf_fbr-line )
        , input no
        , input "ingr"
        , input no
        , input p-price-sale-obj-type
        , input p-price-sale-obj-code
        , input no
        , input no
        , input no
        , output v-need-goods
        , output v-need-goods-list
        , output v-need-goods-qnty-list
    ).
end.
END PROCEDURE.
procedure fbrlib_check-before-close :
define input parameter p-doc-code as character no-undo .
define variable same-sale as decimal no-undo .
define variable is-waste as logical no-undo .
define variable fix-price as logical no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_fbr-line for ub.fbr-line.
define buffer buf_goods for ub.goods.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
do
on error undo, return error
:
  for each buf_fbr-line no-lock
      where buf_fbr-line.doc-code = p-doc-code
    , each buf_goods no-lock
      where buf_goods.artic     = buf_fbr-line.artic
        and buf_goods.prod-type = buf_fbr-line.prod-type
        and buf_goods.prod-code = buf_fbr-line.prod-code
  break by buf_fbr-line.prod-type
        by buf_fbr-line.prod-code
        by buf_fbr-line.artic
  :
    if first-of (buf_fbr-line.artic)
    then do:
      assign
      same-sale = buf_fbr-line.price-sale
      is-waste = (buf_fbr-line.rsrv-qnty = ?)
      fix-price = buf_fbr-line.is-calc
      .
    end.
    if same-sale <> buf_fbr-line.price-sale
    then do:
        undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4&4Во всех строках документа с этим товаром должна быть указана одна и та же цена продажи."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,chr(10)).
    end.
    if fix-price <> buf_fbr-line.is-calc then do:
        undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4&4Во всех строках документа с этим товаром цена должна быть фиксирована или нет."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,chr(10)).
    end.
    if is-waste <> (buf_fbr-line.rsrv-qnty = ?)
    then do:
      undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4&4Во всех строках документа этот товар должен быть отходом либо не отходом."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,chr(10)).
    end.
    if buf_fbr-line.rsrv-qnty <> ?
    and buf_goods.gds-type <> 'у':U
    and ( buf_fbr-line.price-sale <= 0 or buf_fbr-line.price-sale = ?  )
    and buf_fbr-line.fact-qnty <> 0
    then do:
      if buf_fbr-line.trn-type     = 'при':U  then for first buf_fbr-doc where buf_fbr-doc.doc-code =  p-doc-code no-lock:
        if  can-find(first buf_fbr-gds-obj no-lock where
                buf_fbr-gds-obj.gds-code = buf_goods.gds-code
            AND buf_fbr-gds-obj.obj-type = buf_fbr-doc.obj-type
            AND buf_fbr-gds-obj.obj-code = buf_fbr-doc.obj-code
            and buf_fbr-gds-obj.is-null-price  )  then .
                  else undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4Рецепт &5&4Неправильная (нулевая) цена продажи."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,chr(10)
                                      ,buf_fbr-line.recipe-code
                                      ).
      end.
      else undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4Рецепт &5&4Неправильная (нулевая) цена продажи."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,chr(10)
                                      ,buf_fbr-line.recipe-code
                                      ).
    end.
  end.
end.
end procedure.
procedure fbrrest-get-free-qnty :
do
on error undo, return error
:
define input parameter p-obj-type       as character            no-undo.
define input parameter p-obj-code       as integer              no-undo.
define input parameter p-gds-code       as integer              no-undo.
define input parameter p-autofbr        as logical              no-undo.
define output parameter p-avail-qnty    as decimal              no-undo.
    define variable v-req-qnty  like ub.fbr-line.fact-qnty no-undo.
    define variable v-free-qnty as decimal       no-undo.
    define buffer buf_goods         for ub.goods.
    define buffer buf_gds-obj       for ub.gds-obj.
    define buffer buf_temp-parts    for temp-parts.
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    assign
        p-avail-qnty = 0
    .
    run partslib-init-temp-parts in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input buf_goods.artic
        , input buf_goods.prod-type
        , input buf_goods.prod-code
    ).
    assign
        v-free-qnty = 0
    .
    for each buf_temp-parts
    on error undo, return error
    :
        if buf_temp-parts.qnty > 0
        then do:
            assign
                v-free-qnty = v-free-qnty + buf_temp-parts.free-qnty
            .
        end.
    end.
    assign
        p-avail-qnty = ( if v-free-qnty > 0 then v-free-qnty else 0 )
    .
end.
end procedure.
procedure fbrrest-get-catering-object :
do
on error undo, return error
:
define input parameter p-obj-code            as integer      no-undo.
define output parameter p-catering-obj-type  as character    no-undo.
define output parameter p-catering-obj-code  as integer      no-undo.
    define buffer buf_shop              for ub.shop.
    find first buf_shop no-lock
         where buf_shop.obj-code = p-obj-code
    .
    assign
        p-catering-obj-type = buf_shop.kitchen-store-type
        p-catering-obj-code = buf_shop.kitchen-store-code
    .
end.
end procedure.
define variable vss-include-info41 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION check-ban-sales-via-cd return logical ( input p-gds-code as integer ) :
    define variable v-upper-code as int no-undo.
    define variable v-value as character no-undo.
    define variable v-type as character no-undo.
    define buffer lc_gds-grp for ub.gds-grp.
    define buffer lc_goods for ub.goods.
   if p-gds-code <> 0 then do:
    find first lc_goods where lc_goods.gds-code = p-gds-code.
    v-upper-code = lc_goods.grp-code.
    do while v-upper-code > 0 :
        find first lc_gds-grp where lc_gds-grp.node-code = v-upper-code.
        run ggoattr-value(
          input lc_gds-grp.node-code,
          input 0,
          input "",
          input 0,
          input 'ban-sales-via-cd':U,
          output v-value,
          output v-type
        ).
       if v-value = "yes" then
          return true.
       else
       do:
          run ggoattr-value(
             input lc_gds-grp.node-code,
             input v-cntxt-host-code-obj,
             input "",
             input 0,
             input 'ban-sales-via-cd':U,
             output v-value,
             output v-type
             ).
          if v-value = "yes" then
             return true.
          else
          do:
             run ggoattr-value(
                input lc_gds-grp.node-code,
                input v-cntxt-host-code-obj,
                input v-cntxt-obj-type,
                input v-cntxt-obj-code,
                input 'ban-sales-via-cd':U,
                output v-value,
                output v-type
                ).
             if v-value = "yes" then
                return true.
             else v-upper-code = lc_gds-grp.upper-code.
          end .
       end.
      end.
    end.
    if v-value = "" or logical(v-value) = false then return false .
end.
FUNCTION check-ban-sales-via-cd-grp return logical ( input p-grp-code as integer ) :
    define variable v-upper-code as int no-undo.
    define variable v-value as character no-undo.
    define variable v-type as character no-undo.
    define buffer lc_gds-grp for ub.gds-grp.
    define buffer lc_goods for ub.goods.
    v-upper-code = p-grp-code.
    do while v-upper-code > 0 :
        find first lc_gds-grp where lc_gds-grp.node-code = v-upper-code.
        run ggoattr-value(
          input lc_gds-grp.node-code,
          input 0,
          input "",
          input 0,
          input 'ban-sales-via-cd':U,
          output v-value,
          output v-type
        ).
       if v-value = "yes" then
          return true.
       else
       do:
          run ggoattr-value(
             input lc_gds-grp.node-code,
             input v-cntxt-host-code-obj,
             input "",
             input 0,
             input 'ban-sales-via-cd':U,
             output v-value,
             output v-type
             ).
          if v-value = "yes" then
             return true.
          else
          do:
             run ggoattr-value(
                input lc_gds-grp.node-code,
                input v-cntxt-host-code-obj,
                input v-cntxt-obj-type,
                input v-cntxt-obj-code,
                input 'ban-sales-via-cd':U,
                output v-value,
                output v-type
                ).
             if v-value = "yes" then
                return true.
             else v-upper-code = lc_gds-grp.upper-code.
          end .
       end.
      end.
end.
define temp-table temp_goods-qnty no-undo
    field gds-code      as integer
    field artic         as character
    field prod-type     as character
    field prod-code     as integer
    field recipe-type   as character
    field recipe-code   as character
    field trn-type      as character
    field need-qnty     as decimal
    field calculated    as logical
    index pi is primary unique gds-code recipe-code
    index cl calculated
.
PROCEDURE create-initial-temp-goods :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code   as character    no-undo.
define input parameter p-artic              as character    no-undo.
define input parameter p-prod-type          as character    no-undo.
define input parameter p-prod-code          as integer      no-undo.
define input parameter p-trn-type           as character    no-undo.
define input parameter p-recipe-type        as character    no-undo.
define input parameter p-recipe-code        as character    no-undo.
define input parameter p-need-qnty          as decimal      no-undo.
define output parameter p-same-good             as logical      no-undo.
define output parameter p-same-good-old-qnty    as decimal      no-undo.
    define variable v-gds-code    as integer      no-undo.
    define buffer buf_fbr-doc               for ub.fbr-doc.
    define buffer buf_fbr-line              for ub.fbr-line.
    define buffer buf_recipe                for ub.fbr-recipe.
    define buffer buf_obj_recipe            for ub.recipe.
    define buffer buf_temp_goods-qnty       for temp_goods-qnty.
    run clear-temp-tables in this-procedure.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
    create buf_temp_goods-qnty.
    assign
        buf_temp_goods-qnty.gds-code    = v-gds-code
        buf_temp_goods-qnty.artic       = p-artic
        buf_temp_goods-qnty.prod-type   = p-prod-type
        buf_temp_goods-qnty.prod-code   = p-prod-code
        buf_temp_goods-qnty.trn-type    = p-trn-type
        buf_temp_goods-qnty.recipe-type = p-recipe-type
        buf_temp_goods-qnty.recipe-code = p-recipe-code
        buf_temp_goods-qnty.need-qnty   = p-need-qnty
        buf_temp_goods-qnty.calculated  = no
    .
    assign
        p-same-good                 = no
        p-same-good-old-qnty        = 0
    .
    find first buf_fbr-doc where buf_fbr-doc.doc-code = p-fbr-doc-doc-code exclusive-lock.
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-fbr-doc-doc-code
         and buf_fbr-line.is-comp  = yes
    on error undo, return error
    :
        find first buf_temp_goods-qnty
             where buf_temp_goods-qnty.artic        = buf_fbr-line.artic
               and buf_temp_goods-qnty.prod-type    = buf_fbr-line.prod-type
               and buf_temp_goods-qnty.prod-code    = buf_fbr-line.prod-code
        no-error.
        if available buf_temp_goods-qnty
        then do:
            assign
                p-same-good                 = yes
                p-same-good-old-qnty        = buf_fbr-line.fact-qnty
                buf_temp_goods-qnty.calculated  = no
            .
        end.
        else do:
            define variable v-recipe-type   as character     no-undo.
            run copy-recipe-in-doc in this-procedure (
                  input p-fbr-doc-doc-code
                , input buf_fbr-line.recipe-code
                , input buf_fbr-doc.doc-date
                , input buf_fbr-doc.obj-type
                , input buf_fbr-doc.obj-code
            ).
            find first buf_recipe no-lock
                 where buf_recipe.doc-code      = p-fbr-doc-doc-code
                   and buf_recipe.recipe-code   = buf_fbr-line.recipe-code
            no-error.
            if available buf_recipe
            then do:
                assign
                    v-recipe-type = buf_recipe.recipe-type
                .
                if v-recipe-type = 'разделка':U
                or ( v-recipe-type = 'комплектация':U
                    and buf_fbr-line.trn-type = 'спи':U )
                then do:
                    run fill-temp-dressing-ingr in this-procedure (
                          input buf_fbr-line.doc-code
                        , input buf_recipe.recipe-code
                    ).
                end.
            end.
            else do:
                assign
                    v-recipe-type = ?
                .
            end.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output v-gds-code
  )  .
            create buf_temp_goods-qnty.
            assign
                buf_temp_goods-qnty.gds-code    = v-gds-code
                buf_temp_goods-qnty.artic       = buf_fbr-line.artic
                buf_temp_goods-qnty.prod-type   = buf_fbr-line.prod-type
                buf_temp_goods-qnty.prod-code   = buf_fbr-line.prod-code
                buf_temp_goods-qnty.trn-type    = buf_fbr-line.trn-type
                buf_temp_goods-qnty.need-qnty   = buf_fbr-line.fact-qnty
                buf_temp_goods-qnty.recipe-type = v-recipe-type
                buf_temp_goods-qnty.recipe-code = buf_fbr-line.recipe-code
                buf_temp_goods-qnty.calculated  = yes
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE calc-not-calculated-goods :
do
on error undo, return error
:
define input parameter p-mainmenu-handle        as handle           no-undo.
define input parameter p-fbrhist-handle         as widget-handle    no-undo.
define input parameter p-fbr-doc-doc-code       as character        no-undo.
define input parameter p-same-good              as logical          no-undo.
define input parameter p-same-good-old-qnty     as decimal          no-undo.
define input parameter p-always-select-recipe   as logical          no-undo.
define input parameter p-add-childs             as logical          no-undo.
define input parameter p-price-sale-obj-type    as character        no-undo.
define input parameter p-price-sale-obj-code    as integer          no-undo.
define input parameter p-autofbr                as logical          no-undo.
define input parameter p-have-store             as logical          no-undo.
    define variable v-counter               as integer       no-undo.
    define variable v-recipe-type           as character     no-undo.
    define variable v-recipe-code           as character     no-undo.
    define variable v-recipe-found          as logical       no-undo.
    define variable v-gds-code              as integer       no-undo.
    define variable v-yesno                 as logical       no-undo.
    define variable v-fbr-line-recid        as recid         no-undo.
    define variable v-recipe-recid-list     as character     no-undo.
    define variable v-need-goods            as logical       no-undo.
    define variable v-need-goods-list       as character     no-undo.
    define variable v-need-goods-qnty-list  as character     no-undo.
    define variable v-have-rights           as logical       no-undo.
    define variable v-trn-type              as character     no-undo.
    define variable v-is-comp               as logical       no-undo.
    define variable v-host-code             as integer       no-undo.
    define variable v-is-manual-input       as logical       no-undo.
    define variable v-add-good              as logical       no-undo.
    define variable v-cancel                as logical       no-undo.
    define variable v-value          as character no-undo .
    define variable v-type           as character no-undo .
    define variable v-attr-value     as character no-undo .
    define variable v-attr-value-rec as character no-undo .
    define variable v-attr-type      as character no-undo .
    define variable v-mark-qnty      as decimal no-undo init ? .
    define buffer buf_obj_recipe            for recipe.
    define buffer buf_obj_recipe-gds        for recipe-gds.
    define buffer buf_fbr-recipe            for fbr-recipe.
    define buffer buf_fbr-recipe-gds        for fbr-recipe-gds.
    define buffer buf_goods                 for goods.
    define buffer buf_fbr-doc               for fbr-doc.
    define buffer buf_fbr-line              for fbr-line.
    define buffer buf_comp_fbr-line         for fbr-line.
    define buffer buf_temp_goods-qnty       for temp_goods-qnty.
    define buffer buf_new_temp_goods-qnty   for temp_goods-qnty.
    define buffer buf_start_temp_goods-qnty for temp_goods-qnty.
    define buffer buf_del_temp_goods-qnty   for temp_goods-qnty.
    define buffer buf_marking-lines         for ub.marking-lines .
    define buffer buf_marking               for ub.marking .
   define variable v-ban-recipes as logical no-undo .
   define variable v-ban-altr    as logical no-undo .
   if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanRecipes then v-ban-recipes = true .
   if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanAltr then v-ban-altr = true .
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-fbr-doc-doc-code
    .
    run test-temp-tables in this-procedure ( "Заполнена временная таблица по товарам документа." ).
    find first buf_start_temp_goods-qnty
         where buf_start_temp_goods-qnty.calculated = no
    no-error.
    calc-not-calculated-goods:
    do while available buf_start_temp_goods-qnty
    :
        run writelog in this-procedure ( log-file-name, 2, substitute( "Расчет товара с артикулом &1", buf_start_temp_goods-qnty.artic ) ).
        find first buf_goods no-lock
             where buf_goods.gds-code = buf_start_temp_goods-qnty.gds-code
        .
        if buf_start_temp_goods-qnty.recipe-code = ?
        then do:
            assign
                v-is-manual-input = yes
            .
        end.
        else do:
            assign
                v-is-manual-input = no
            .
        end.
        if buf_start_temp_goods-qnty.recipe-code = ?
        or p-always-select-recipe = yes
        then do:
            assign
                v-yesno     = ?
                v-add-good  = no
            .
            do while v-yesno = ?
            and v-add-good = no
            :
                run ref/rcp-all.w (
                      input p-mainmenu-handle
                    , input "b-add,b-sel"
                    , input 'все':U
                    , input recid( buf_goods )
                    , input buf_fbr-doc.obj-type
                    , input buf_fbr-doc.obj-code
                    , output v-recipe-recid-list
                ) no-error.
                if error-status :error
                or v-recipe-recid-list = ""
                then do:
                    message
                        "Отменить добавление товара?"
                        skip(1)
                        skip "Товар:" buf_goods.artic buf_goods.gds-name
                        skip(1)
                        skip "Yes - отменить добавление текущего товара"
                        skip "No  - отменить добавление всех товаров списка"
                        skip "Cancel - вернуться к выбору рецепта"
                    view-as alert-box question
                    buttons yes-no-cancel
                    title "Отмена"
                    update v-yesno
                    .
                end.
                else do:
      if v-ban-altr or v-ban-recipes then
      do:
         for each buf_obj_recipe no-lock where recid (buf_obj_recipe) = integer(v-recipe-recid-list):
            if buf_obj_recipe.recipe-type = 'производство':U and v-ban-recipes then
            do:
               for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = buf_obj_recipe.recipe-code:
                  run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
                     , input  'mark-type':U
                     , output v-attr-value
                     , output v-attr-type
                     ) no-error .
                  if v-attr-value <> "" and v-attr-value <> "not-type" then
                  do:
                     message "Рецепт производства " + buf_obj_recipe.recipe-code + " " + buf_obj_recipe.recipe-name + " содержит маркированный товар."
                        view-as alert-box.
                     return .
                  end.
               end.
            end.
            if buf_obj_recipe.recipe-type = 'альтернатива':U and v-ban-altr then
            do:
               if not check-ban-sales-via-cd(buf_goods.gds-code) then
               do:
                  message "Рецепт альтернатива " + buf_obj_recipe.recipe-code + " " + buf_obj_recipe.recipe-name + chr(10) + "входит в группу, у которой не установлен атрибут: " + chr(10) + "Запрет передачи на кассу."
                     view-as alert-box.
                  return .
               end.
            end.
            if buf_obj_recipe.recipe-type = 'комплектация':U and v-ban-recipes then
            do:
               for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = buf_obj_recipe.recipe-code:
                  run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
                     , input  'mark-type':U
                     , output v-attr-value
                     , output v-attr-type
                     ) no-error .
                  if v-attr-value <> "" and v-attr-value <> "not-type" then
                  do:
                     run gds-attr-value in this-procedure  ( input  buf_obj_recipe.gds-code
                        , input  'mark-type':U
                        , output v-attr-value-rec
                        , output v-attr-type
                        ) no-error .
                     if v-attr-value-rec = "" or v-attr-value-rec = "not-type" then
                     do:
                        message "Рецепт комплектации " + buf_obj_recipe.recipe-code + " " + buf_obj_recipe.recipe-name + " должен быть маркированным"
                           view-as alert-box.
                        return .
                     end.
                     else leave.
                  end.
               end.
            end.
         end.
      end.
                    assign
                        v-add-good = yes
                    .
                end.
            end.
            if v-add-good = no
            then do:
                if v-yesno = yes
                then do:
                    for each tt-marking-lines where tt-marking-lines.gds-code = buf_start_temp_goods-qnty.gds-code
                    :
                      for first buf_marking exclusive-lock where buf_marking.mark begins tt-marking-lines.mark :
                        assign
                          buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB
                        .
                      end .
                      delete tt-marking-lines .
                    end .
                    delete buf_start_temp_goods-qnty.
                    find first buf_start_temp_goods-qnty
                            where buf_start_temp_goods-qnty.calculated = no
                    no-error.
                    next calc-not-calculated-goods.
                end.
                else do:
                    undo, return error .
                end.
            end.
            find first buf_obj_recipe no-lock
                 where recid( buf_obj_recipe ) = integer( v-recipe-recid-list )
            no-error.
            if not available buf_obj_recipe
            then do:
                if p-always-select-recipe = yes
                then do:
                    assign
                        buf_start_temp_goods-qnty.calculated = yes
                    .
                    find first buf_start_temp_goods-qnty
                         where buf_start_temp_goods-qnty.calculated = no
                    no-error.
                    next calc-not-calculated-goods.
                end.
                else do:
                    message
                        "Неверно выбран рецепт для товара."
                    view-as alert-box information.
                    undo, return error .
                end.
            end.
            else do:
                run copy-recipe-in-doc in this-procedure (
                      input buf_fbr-doc.doc-code
                    , input buf_obj_recipe.recipe-code
                    , input buf_fbr-doc.doc-date
                    , input buf_fbr-doc.obj-type
                    , input buf_fbr-doc.obj-code
                ).
                find first buf_fbr-recipe no-lock
                     where buf_fbr-recipe.doc-code    = p-fbr-doc-doc-code
                       and buf_fbr-recipe.recipe-code = buf_obj_recipe.recipe-code
                .
                assign
                    buf_start_temp_goods-qnty.recipe-code = buf_fbr-recipe.recipe-code
                    buf_start_temp_goods-qnty.recipe-type = buf_fbr-recipe.recipe-type
                .
            end.
            run writelog in this-procedure ( log-file-name, 3, substitute( "В диалоге выбран рецепт номер &1", buf_start_temp_goods-qnty.recipe-code ) ).
        end.
        else do:
            run copy-recipe-in-doc in this-procedure (
                  input p-fbr-doc-doc-code
                , input buf_start_temp_goods-qnty.recipe-code
                , input buf_fbr-doc.doc-date
                , input buf_fbr-doc.obj-type
                , input buf_fbr-doc.obj-code
            ).
            find first buf_fbr-recipe no-lock
                 where buf_fbr-recipe.doc-code    = p-fbr-doc-doc-code
                   and buf_fbr-recipe.recipe-code = buf_start_temp_goods-qnty.recipe-code
            .
            run writelog in this-procedure ( log-file-name, 3, substitute( "Выбран рецепт номер &1", buf_start_temp_goods-qnty.recipe-code ) ).
        end.
        case buf_fbr-recipe.recipe-type
        :
          when 'производство':U
          then do:
define variable vss-include-info45 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_manufacturing':U
    ,input  'object':U
    ,input  buf_fbr-doc.host-code
    ,input  buf_fbr-doc.obj-type
    ,input  buf_fbr-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-have-rights
    )  .
end.
          end.
          when 'комплектация':U
          then do:
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_gathering':U
    ,input  'object':U
    ,input  buf_fbr-doc.host-code
    ,input  buf_fbr-doc.obj-type
    ,input  buf_fbr-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-have-rights
    )  .
end.
          end.
          when 'разделка':U
          then do:
define variable vss-include-info47 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_dressing':U
    ,input  'object':U
    ,input  buf_fbr-doc.host-code
    ,input  buf_fbr-doc.obj-type
    ,input  buf_fbr-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-have-rights
    )  .
end.
          end.
          when 'альтернатива':U
          then do:
define variable vss-include-info48 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_alternative':U
    ,input  'object':U
    ,input  buf_fbr-doc.host-code
    ,input  buf_fbr-doc.obj-type
    ,input  buf_fbr-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-have-rights
    )  .
end.
          end.
          when 'топливо':U
          then do:
define variable vss-include-info49 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_petrolium-manufacturing':U
    ,input  'object':U
    ,input  buf_fbr-doc.host-code
    ,input  buf_fbr-doc.obj-type
    ,input  buf_fbr-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-have-rights
    )  .
end.
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Неизвестный тип рецепта производства" skip
              "Тип рецепта" buf_fbr-recipe.recipe-type skip
              "Документ производства" buf_fbr-recipe.doc-code skip
              "Код рецепта" buf_fbr-recipe.recipe-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .
        if v-have-rights = no
        then do:
            message
                "Недостаточно прав для производства."
                skip(1) "Обратитесь к администратору."
                skip(1) return-value
            view-as alert-box information.
            run clear-temp-tables in this-procedure .
            undo, return error.
        end.
        find first buf_fbr-line no-lock
             where buf_fbr-line.doc-code    = p-fbr-doc-doc-code
               and buf_fbr-line.is-comp     = yes
               and buf_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
        no-error.
        if available buf_fbr-line
        then do:
            define buffer buf_change_fbr-line      for ub.fbr-line.
            run writelog in this-procedure ( log-file-name, 3, "В документе уже есть выбранный рецепт." ).
            if buf_start_temp_goods-qnty.need-qnty = ?
            and v-is-manual-input = yes
            then do:
                define variable v-old-fact-qnty  as decimal       no-undo.
                define variable v-old-price-sale as decimal       no-undo.
                assign
                    v-old-fact-qnty  = buf_fbr-line.fact-qnty
                    v-old-price-sale = buf_fbr-line.price-sale
                .
                run str/fbr-line.w (
                      input p-fbrhist-handle
                    , input buf_fbr-doc.status_
                    , input p-fbr-doc-doc-code
                    , input recid( buf_fbr-line )
                    , input ?
                    , output v-cancel
                ).
                if error-status :error
                or v-cancel = yes
                then do:
                    find first buf_change_fbr-line exclusive-lock
                         where buf_change_fbr-line.doc-code    = p-fbr-doc-doc-code
                           and buf_change_fbr-line.is-comp     = yes
                           and buf_change_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
                    .
                    message
                             vss-workfile vss-revision vss-description
                        skip "Ошибка изменения строки."
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                        skip buf_change_fbr-line.fact-qnty
                    view-as alert-box error.
                    assign
                        buf_change_fbr-line.fact-qnty  = v-old-fact-qnty
                        buf_change_fbr-line.price-sale = v-old-price-sale
                    .
                    run clear-temp-tables in this-procedure.
                    return.
                end.
                if buf_fbr-line.fact-qnty <= v-old-fact-qnty
                then do:
                    define variable v-gds-name    as character    no-undo.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-arnm in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output v-gds-name
  )  .
                    message
                             "Для производства товаров документа необходимо"
                        skip "большее количество товара, чем было добавлено."
                        skip "Количество товара в документе будет восстановлено."
                        skip(1)
                        skip "Товар: " buf_fbr-line.artic v-gds-name
                        skip "Количество в строке документа производства:" v-old-fact-qnty
                        skip "Новое количество:" buf_fbr-line.fact-qnty
                    view-as alert-box information
                    title "Изменение строки документа производства".
                    find first buf_change_fbr-line exclusive-lock
                         where buf_change_fbr-line.doc-code    = p-fbr-doc-doc-code
                           and buf_change_fbr-line.is-comp     = yes
                           and buf_change_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
                    .
                    assign
                        buf_change_fbr-line.fact-qnty  = v-old-fact-qnty
                        buf_change_fbr-line.price-sale = v-old-price-sale
                    .
                    delete buf_start_temp_goods-qnty.
                end.
                else do:
                    find first buf_change_fbr-line exclusive-lock
                         where buf_change_fbr-line.doc-code    = p-fbr-doc-doc-code
                           and buf_change_fbr-line.is-comp     = yes
                           and buf_change_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
                    .
                    assign
                        buf_start_temp_goods-qnty.need-qnty  = buf_fbr-line.fact-qnty
                        buf_start_temp_goods-qnty.calculated = no
                        buf_change_fbr-line.fact-qnty     = 0
                    .
                end.
                run test-temp-tables in this-procedure ( "Товар добавлять не надо - параметр fbr-frcp=yes, но введенное в диалоге количество меньше необходимого." ).
                find first buf_start_temp_goods-qnty
                     where buf_start_temp_goods-qnty.calculated = no
                no-error.
                next calc-not-calculated-goods.
            end.
            else do:
                find first buf_change_fbr-line exclusive-lock
                     where buf_change_fbr-line.doc-code    = p-fbr-doc-doc-code
                       and buf_change_fbr-line.is-comp     = yes
                       and buf_change_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
                .
                assign
                    buf_start_temp_goods-qnty.need-qnty  = buf_start_temp_goods-qnty.need-qnty + buf_fbr-line.fact-qnty
                    buf_change_fbr-line.fact-qnty        = buf_start_temp_goods-qnty.need-qnty
                .
                if buf_start_temp_goods-qnty.recipe-code <> "":U
                then do:
                    assign
                        buf_start_temp_goods-qnty.calculated = no
                    .
                end.
            end.
            run writelog in this-procedure ( log-file-name, 3, substitute( "Изменена рассчитанная строка документа. Новое количество &1", buf_fbr-line.fact-qnty ) ).
        end.
        run fbrlib-get-trn-type in this-procedure (
              input buf_fbr-recipe.recipe-code
            , input recid( buf_goods )
            , input ( if buf_start_temp_goods-qnty.trn-type = ?
                      then ?
                      else ( if buf_start_temp_goods-qnty.trn-type = 'при':U
                             then yes
                             else no ) )
            , output v-is-comp
            , output v-trn-type
        ).
        assign
            buf_start_temp_goods-qnty.trn-type = v-trn-type
        .
        run str/fbr-crln.p (
              input p-mainmenu-handle
            , input recid( buf_fbr-doc )
            , input recid( buf_goods )
            , input buf_fbr-recipe.recipe-code
            , input v-trn-type
            , input v-is-comp
            , input yes
            , input buf_fbr-doc.obj-type
            , input buf_fbr-doc.obj-code
            , output v-fbr-line-recid
        ).
        if buf_start_temp_goods-qnty.need-qnty = ?
        then do:
            find first tt-marking-lines no-error .
            if available tt-marking-lines
            then do :
              assign v-mark-qnty = 0 .
              for first buf_fbr-line no-lock where recid(buf_fbr-line) = v-fbr-line-recid,
              first buf_goods no-lock where buf_goods.artic     = buf_fbr-line.artic
                                        and buf_goods.prod-type = buf_fbr-line.prod-type
                                        and buf_goods.prod-code = buf_fbr-line.prod-code,
              each tt-marking-lines where tt-marking-lines.gds-code = buf_goods.gds-code
              :
                assign v-mark-qnty = v-mark-qnty + tt-marking-lines.box-qnty .
              end .
            end .
            run str/fbr-line.w (
                  input p-fbrhist-handle
                , input buf_fbr-doc.status_
                , input p-fbr-doc-doc-code
                , input v-fbr-line-recid
                , input v-mark-qnty
                , output v-cancel
            ) no-error.
            if error-status :error
            or v-cancel = yes
            then do:
                find first buf_fbr-line exclusive-lock
                     where recid( buf_fbr-line ) = v-fbr-line-recid
                .
                for first buf_goods no-lock where buf_goods.artic     = buf_fbr-line.artic
                                          and buf_goods.prod-type = buf_fbr-line.prod-type
                                          and buf_goods.prod-code = buf_fbr-line.prod-code,
                each tt-marking-lines where tt-marking-lines.gds-code = buf_goods.gds-code
                :
                  for first buf_marking exclusive-lock where buf_marking.mark begins tt-marking-lines.mark :
                    assign
                      buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB
                    .
                  end .
                end .
                delete buf_fbr-line.
                run clear-temp-tables in this-procedure.
                return.
            end.
            for first buf_fbr-line no-lock where recid(buf_fbr-line) = v-fbr-line-recid,
            first buf_goods no-lock where buf_goods.artic     = buf_fbr-line.artic
                                      and buf_goods.prod-type = buf_fbr-line.prod-type
                                      and buf_goods.prod-code = buf_fbr-line.prod-code,
            each tt-marking-lines where tt-marking-lines.gds-code = buf_goods.gds-code
            :
              create buf_marking-lines .
              assign
                buf_marking-lines.mark      = tt-marking-lines.mark
                buf_marking-lines.obj-type  = buf_fbr-doc.obj-type
                buf_marking-lines.obj-code  = buf_fbr-doc.obj-code
                buf_marking-lines.gds-code  = buf_goods.gds-code
                buf_marking-lines.in-code   = "manufacturing"
                buf_marking-lines.out-code  = buf_fbr-line.doc-code
                buf_marking-lines.part-code = buf_fbr-line.recipe-code
                buf_marking-lines.prt-code  = 0
                buf_marking-lines.doc-level = 1
              .
            end .
            find first buf_fbr-line exclusive-lock
                 where recid( buf_fbr-line ) = v-fbr-line-recid
            .
            if p-same-good = yes
            then do:
                if p-autofbr = yes
                then do:
                    assign
                        v-yesno = yes
                    .
                end.
                else do:
                    message
                             "Товар уже есть в документе."
                        skip "Вы можете добавить введенное количество в строку документа,"
                        skip "изменить количество в документе на введенное"
                        skip "или отменить добавление товара, оставив рецепт без изменений"
                        skip(1)
                        skip "Артикул товара:        " buf_start_temp_goods-qnty.artic
                        skip "Количество в документе:" p-same-good-old-qnty
                        skip(1)
                        skip "Добавить в строку?"
                    view-as alert-box question
                    buttons yes-no-cancel
                    title "Добавление товара"
                    update v-yesno.
                    if v-yesno = ?
                    then do:
                        assign
                            buf_start_temp_goods-qnty.need-qnty   = p-same-good-old-qnty
                            buf_start_temp_goods-qnty.calculated  = yes
                        .
                        run writelog in this-procedure ( log-file-name, 3, substitute( "Товар уже есть в документе. Расчитанная строка документа оставлена без изменений. Количество &1", buf_start_temp_goods-qnty.need-qnty ) ).
                        run test-temp-tables in this-procedure ( "Добавили товар." ).
                        find first buf_start_temp_goods-qnty
                             where buf_start_temp_goods-qnty.calculated = no
                        no-error.
                        next calc-not-calculated-goods.
                    end.
                end.
                assign
                    buf_start_temp_goods-qnty.calculated  = no
                .
                if v-yesno = yes
                then do:
                    assign
                        buf_fbr-line.fact-qnty = buf_fbr-line.fact-qnty + p-same-good-old-qnty
                    .
                end.
                run writelog in this-procedure ( log-file-name, 3, substitute( "Товар уже есть в документе. Количество в рассчитанной строке документа изменено на &1", buf_fbr-line.fact-qnty ) ).
            end.
            assign
                buf_start_temp_goods-qnty.recipe-code = buf_fbr-line.recipe-code
                buf_start_temp_goods-qnty.need-qnty   = buf_fbr-line.fact-qnty
                buf_start_temp_goods-qnty.trn-type    = buf_fbr-line.trn-type
            .
        end.
        run writelog in this-procedure ( log-file-name, 2, "Идем по ингредиентам товара." ).
        for each buf_fbr-recipe-gds no-lock
           where buf_fbr-recipe-gds.doc-code    = buf_fbr-recipe.doc-code
             and buf_fbr-recipe-gds.recipe-code = buf_fbr-recipe.recipe-code
        on error undo, return error
        :
            find first buf_goods no-lock
                 where buf_goods.artic      = buf_fbr-recipe-gds.artic
                   and buf_goods.prod-type  = buf_fbr-recipe-gds.prod-type
                   and buf_goods.prod-code  = buf_fbr-recipe-gds.prod-code
            .
            assign
                v-is-comp = no
                v-trn-type = ( if buf_start_temp_goods-qnty.trn-type = 'при':U then 'спи':U else 'при':U )
            .
            run str/fbr-crln.p (
                  input p-mainmenu-handle
                , input recid( buf_fbr-doc )
                , input recid( buf_goods )
                , input buf_fbr-recipe.recipe-code
                , input v-trn-type
                , input v-is-comp
                , input yes
                , input buf_fbr-doc.obj-type
                , input buf_fbr-doc.obj-code
                , output v-fbr-line-recid
            ).
            find first buf_fbr-line no-lock
                 where recid( buf_fbr-line ) = v-fbr-line-recid
            .
            run writelog in this-procedure ( log-file-name, 3, substitute( "Создана строка ингредиента с артикулом '&1'", buf_fbr-line.artic ) ).
        end.
        run writelog in this-procedure ( log-file-name, 2, substitute( "Упорядочивание рецептов. Идем по рецептам с последнего." ) ).
        run fbrlib-put-in-order-recipe in this-procedure (
            input buf_fbr-doc.doc-code
        ) no-error.
        if error-status :error
        then do:
            for each buf_del_temp_goods-qnty
            :
                delete buf_del_temp_goods-qnty.
            end.
            undo, return error.
        end.
        find last temp_recipe-order.
        calc-all-recipes:
        do while available temp_recipe-order
        :
            run writelog in this-procedure ( log-file-name, 3, substitute( "Обработка рецепта номер: &1", temp_recipe-order.recipe-code ) ).
            find first buf_comp_fbr-line exclusive-lock
                 where buf_comp_fbr-line.doc-code    = p-fbr-doc-doc-code
                   and buf_comp_fbr-line.is-comp     = yes
                   and buf_comp_fbr-line.recipe-code = temp_recipe-order.recipe-code
            .
            find first buf_temp_goods-qnty
                 where buf_temp_goods-qnty.artic        = buf_comp_fbr-line.artic
                   and buf_temp_goods-qnty.prod-type    = buf_comp_fbr-line.prod-type
                   and buf_temp_goods-qnty.prod-code    = buf_comp_fbr-line.prod-code
                   and buf_temp_goods-qnty.recipe-code  = buf_comp_fbr-line.recipe-code
            no-error.
            if not available buf_temp_goods-qnty
            or buf_temp_goods-qnty.calculated = no
            then do:
                run writelog in this-procedure ( log-file-name, 4, "Товар рецепта не рассчитан. Рассчитываем." ).
                if available buf_temp_goods-qnty
                and buf_temp_goods-qnty.need-qnty <> buf_comp_fbr-line.fact-qnty
                then do:
                    assign
                        buf_comp_fbr-line.fact-qnty = buf_temp_goods-qnty.need-qnty
                    .
                    run writelog in this-procedure ( log-file-name, 5, substitute( "Прописываем количество в строку составного товара: &1", buf_comp_fbr-line.fact-qnty  ) ).
                end.
                run str/fbr-qnty.p (
                      input p-mainmenu-handle
                    , input p-fbrhist-handle
                    , input recid( buf_fbr-doc )
                    , input recid( buf_comp_fbr-line )
                    , input no
                    , input "ingr"
                    , input no
                    , input p-price-sale-obj-type
                    , input p-price-sale-obj-code
                    , input yes
                    , input p-autofbr
                    , input p-have-store
                    , output v-need-goods
                    , output v-need-goods-list
                    , output v-need-goods-qnty-list
                ).
                if p-add-childs  = yes
                and v-need-goods = yes
                then do:
                    do v-counter = 1 to num-entries( v-need-goods-list ) / 2
                    :
                        run add-new-recipe in this-procedure (
                              input p-mainmenu-handle
                            , input buf_fbr-doc.doc-code
                            , input entry( 2 * v-counter, v-need-goods-list )
                            , input integer( entry( 2 * v-counter - 1 , v-need-goods-list ) )
                            , input decimal( entry( v-counter, v-need-goods-qnty-list ) )
                            , input p-autofbr
                            , input p-have-store
                        ).
                    end.
                    leave calc-all-recipes.
                end.
            end.
            find prev temp_recipe-order no-error.
        end.
        assign
            buf_start_temp_goods-qnty.calculated = yes
        .
        if buf_start_temp_goods-qnty.recipe-type = 'разделка':U
        or ( buf_start_temp_goods-qnty.recipe-type = 'комплектация':U
             and buf_start_temp_goods-qnty.trn-type = 'спи':U )
        then do:
            run fill-temp-dressing-ingr in this-procedure (
                  input buf_fbr-doc.doc-code
                , input buf_start_temp_goods-qnty.recipe-code
            ).
        end.
        run test-temp-tables in this-procedure ( "Добавили товар." ).
        find first buf_start_temp_goods-qnty
             where buf_start_temp_goods-qnty.calculated = no
        no-error.
    end.
end.
END PROCEDURE.
PROCEDURE clear-temp-tables :
do
on error undo, return error
:
    define buffer buf_temp_goods-qnty       for temp_goods-qnty.
    define buffer buf_temp_dressing-ingr    for temp_dressing-ingr.
    for each buf_temp_goods-qnty
    on error undo, return error
    :
        delete buf_temp_goods-qnty.
    end.
    for each buf_temp_dressing-ingr
    on error undo, return error
    :
        delete buf_temp_dressing-ingr.
    end.
end.
END PROCEDURE.
PROCEDURE copy-recipe-in-doc :
define input parameter p-doc-code       as character             no-undo.
define input parameter p-recipe-code    as character             no-undo.
define input parameter p-obj-date       as date                  no-undo.
define input parameter p-obj-type       like ub.clients.obj-type no-undo.
define input parameter p-obj-code       like ub.clients.obj-code no-undo.
    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_recipe            for ub.recipe.
    define buffer buf_recipe-gds        for ub.recipe-gds.
do
for buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_recipe
  , buf_recipe-gds
on error undo, return error return-value
:
find first buf_recipe no-lock
     where buf_recipe.recipe-code = p-recipe-code
.
find first buf_fbr-recipe exclusive-lock
     where buf_fbr-recipe.doc-code      = p-doc-code
       and buf_fbr-recipe.recipe-code   = p-recipe-code
no-error.
if not available buf_fbr-recipe
then do:
  create buf_fbr-recipe.
  assign
    buf_fbr-recipe.doc-code     = p-doc-code
    buf_fbr-recipe.recipe-code  = p-recipe-code
    buf_fbr-recipe.recipe-type  = buf_recipe.recipe-type
  .
  for each buf_recipe-gds exclusive-lock
     where buf_recipe-gds.recipe-code = p-recipe-code
  on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
        run fbrlib_create-fbr-recipe-gds in this-procedure (
              input p-doc-code
            , input buf_recipe-gds.recipe-code
            , input buf_recipe-gds.prod-type
            , input buf_recipe-gds.prod-code
            , input buf_recipe-gds.artic
            , input buf_recipe-gds.gds-code
            , input buf_recipe-gds.is-waste
            , input buf_recipe-gds.proc-number
            , input p-obj-date
            , input p-obj-type
            , input p-obj-code
            , input buf_recipe-gds.calc-method
            , input buf_recipe-gds.coeff-waste
            , input buf_recipe-gds.qnty
            , input buf_recipe-gds.brutto-qnty
      ) no-error.
      if error-status:error
      then do:
            return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
      end.
  end.
  buffer-copy buf_recipe to buf_fbr-recipe.
end.
end.
END PROCEDURE.
PROCEDURE fill-temp-dressing-ingr :
do
on error undo, return error
:
define input parameter p-doc-code       as character    no-undo.
define input parameter p-recipe-code    as character    no-undo.
    define variable v-free-qnty     as decimal       no-undo.
    define buffer buf_fbr-doc               for ub.fbr-doc.
    define buffer buf_c_fbr-line            for ub.fbr-line.
    define buffer buf_i_fbr-line            for ub.fbr-line.
    define buffer buf_i_other_fbr-line      for ub.fbr-line.
    define buffer buf_goods                 for ub.goods.
    define buffer buf_recipe                for ub.fbr-recipe.
    define buffer buf_recipe-gds            for ub.fbr-recipe-gds.
    define buffer buf_temp_dressing-ingr    for temp_dressing-ingr.
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-doc-code
    .
    find first buf_recipe no-lock
         where buf_recipe.doc-code    = p-doc-code
           and buf_recipe.recipe-code = p-recipe-code
    .
    find first buf_c_fbr-line no-lock
         where buf_c_fbr-line.doc-code    = p-doc-code
           and buf_c_fbr-line.is-comp     = yes
           and buf_c_fbr-line.recipe-code = p-recipe-code
    .
    if buf_recipe.recipe-type <> 'разделка':U
    and ( buf_recipe.recipe-type <> 'комплектация':U
         or buf_c_fbr-line.trn-type <> 'спи':U )
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Процедура fill-temp-dressing-ingr применима только к рецептам разделки и разукомплектации."
            skip return-value
        view-as alert-box error.
        undo, return error .
    end.
    for each buf_temp_dressing-ingr
    :
        delete buf_temp_dressing-ingr.
    end.
    for each buf_i_fbr-line no-lock
       where buf_i_fbr-line.doc-code    = p-doc-code
         and buf_i_fbr-line.is-comp     = no
         and buf_i_fbr-line.recipe-code = p-recipe-code
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.artic      = buf_i_fbr-line.artic
               and buf_goods.prod-type  = buf_i_fbr-line.prod-type
               and buf_goods.prod-code  = buf_i_fbr-line.prod-code
        .
        find first buf_temp_dressing-ingr
             where buf_temp_dressing-ingr.recipe-code = p-recipe-code
               and buf_temp_dressing-ingr.gds-code    = buf_goods.gds-code
        no-error.
        if not available buf_temp_dressing-ingr
        then do:
            create buf_temp_dressing-ingr.
            assign
                buf_temp_dressing-ingr.recipe-code  = p-recipe-code
                buf_temp_dressing-ingr.gds-code     = buf_goods.gds-code
                buf_temp_dressing-ingr.used-qnty    = 0
                buf_temp_dressing-ingr.line-qnty    = 0
                buf_temp_dressing-ingr.recipe-qnty  = 0
            .
        end.
        run fbrrest-get-free-qnty in this-procedure (
              input buf_fbr-doc.obj-type
            , input buf_fbr-doc.obj-code
            , input buf_goods.gds-code
            , input no
            , output v-free-qnty
        ).
        find first buf_recipe-gds no-lock
             where buf_recipe-gds.doc-code    = buf_i_fbr-line.doc-code
               and buf_recipe-gds.recipe-code = p-recipe-code
               and buf_recipe-gds.prod-type   = buf_i_fbr-line.prod-type
               and buf_recipe-gds.prod-code   = buf_i_fbr-line.prod-code
               and buf_recipe-gds.artic       = buf_i_fbr-line.artic
        .
        for each buf_i_other_fbr-line no-lock
           where buf_i_other_fbr-line.doc-code    = p-doc-code
             and buf_i_other_fbr-line.is-comp     = no
             and buf_i_other_fbr-line.recipe-code <> p-recipe-code
             and buf_i_other_fbr-line.artic       = buf_i_fbr-line.artic
             and buf_i_other_fbr-line.prod-type   = buf_i_fbr-line.prod-type
             and buf_i_other_fbr-line.prod-code   = buf_i_fbr-line.prod-code
        :
            assign
                buf_temp_dressing-ingr.line-qnty    = buf_temp_dressing-ingr.line-qnty
                                                        + buf_i_other_fbr-line.fact-qnty
            .
        end.
        if available buf_temp_dressing-ingr
        then do:
            assign
                buf_temp_dressing-ingr.used-qnty = buf_temp_dressing-ingr.line-qnty - v-free-qnty
            .
        end.
    end.
    for each buf_temp_dressing-ingr
       where buf_temp_dressing-ingr.recipe-code = p-recipe-code
    :
        find first buf_goods no-lock
             where buf_goods.gds-code = buf_temp_dressing-ingr.gds-code
        .
        for each buf_i_other_fbr-line no-lock
           where buf_i_other_fbr-line.doc-code    = p-doc-code
             and buf_i_other_fbr-line.is-comp     = no
             and buf_i_other_fbr-line.recipe-code = buf_temp_dressing-ingr.recipe-code
             and buf_i_other_fbr-line.artic       = buf_goods.artic
             and buf_i_other_fbr-line.prod-type   = buf_goods.prod-type
             and buf_i_other_fbr-line.prod-code   = buf_goods.prod-code
        on error undo, return error
        :
            assign
                buf_temp_dressing-ingr.recipe-qnty = buf_temp_dressing-ingr.recipe-qnty
                                                    + buf_i_other_fbr-line.fact-qnty
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE test-temp-tables :
    define buffer buf_temp_goods-qnty       for temp_goods-qnty.
    define buffer buf_temp_dressing-ingr    for temp_dressing-ingr.
do
on error undo, return error
:
define input parameter p-title  as character    no-undo.
define variable v-str               as character        no-undo.
    assign
        v-str = p-title + " temp_goods-qnty:"
    .
    run writelog in this-procedure (  log-file-name, 0, v-str ).
    for each buf_temp_goods-qnty
    on error undo, return error
    :
        assign
            v-str   = string( buf_temp_goods-qnty.gds-code )
                    + "   " + ( if buf_temp_goods-qnty.recipe-type = ? then "?" else string( buf_temp_goods-qnty.recipe-type ) )
                    + "   " + ( if buf_temp_goods-qnty.recipe-code = ? then "?" else string( buf_temp_goods-qnty.recipe-code ) )
                    + "   " + ( if buf_temp_goods-qnty.trn-type = ?    then "?" else string( buf_temp_goods-qnty.trn-type ) )
                    + "   " + ( if buf_temp_goods-qnty.need-qnty = ?   then "?" else string( buf_temp_goods-qnty.need-qnty ) )
                    + "   " + string( buf_temp_goods-qnty.calculated )
        .
        run writelog in this-procedure (  log-file-name, 1, v-str ).
    end.
    assign
        v-str = "        temp_dressing-ingr:"
    .
    run writelog in this-procedure (  log-file-name, 0, v-str ).
    for each buf_temp_dressing-ingr
    on error undo, return error
    :
        assign
            v-str   = string( buf_temp_dressing-ingr.recipe-code  )
                    + "   " + string( buf_temp_dressing-ingr.gds-code )
                    + "   " + ( if buf_temp_dressing-ingr.line-qnty = ?   then "?" else string( buf_temp_dressing-ingr.line-qnty ) )
                    + "   " + ( if buf_temp_dressing-ingr.used-qnty = ?   then "?" else string( buf_temp_dressing-ingr.used-qnty ) )
                    + "   " + ( if buf_temp_dressing-ingr.recipe-qnty = ? then "?" else string( buf_temp_dressing-ingr.recipe-qnty ) )
        .
        run writelog in this-procedure (  log-file-name, 1, v-str ).
    end.
end.
END PROCEDURE.
PROCEDURE add-new-recipe :
do
on error undo, return error
:
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-doc-code           as character        no-undo.
define input parameter p-trn-type           as character        no-undo.
define input parameter p-gds-code           as integer          no-undo.
define input parameter p-need-qnty          as decimal          no-undo.
define input parameter p-autofbr            as logical          no-undo.
define input parameter p-have-store         as logical          no-undo.
    define variable v-comp-gds-code         as integer          no-undo.
    define variable v-comp-trn-type         as character        no-undo.
    define variable v-comp-need-qnty        as decimal          no-undo.
    define variable v-comp-recipe-type      as character        no-undo.
    define variable v-comp-recipe-code      as character        no-undo.
    define variable v-comp-recipe-found     as logical          no-undo.
    define variable v-ext-comp-recipe-type  as character        no-undo.
    define variable v-no-add-good           as logical          no-undo.
    define buffer buf_temp_goods-qnty       for temp_goods-qnty.
    define buffer buf_new_temp_goods-qnty   for temp_goods-qnty.
    define buffer buf_goods                 for ub.goods.
    define buffer buf_fbr-line              for ub.fbr-line.
    define buffer buf_fbr-doc               for ub.fbr-doc.
    define variable v-value          as character no-undo .
    define variable v-type           as character no-undo .
    define variable v-attr-value     as character no-undo .
    define variable v-attr-value-rec as character no-undo .
    define variable v-attr-type      as character no-undo .
    define variable v-ban-recipes as logical no-undo .
    define variable v-ban-altr    as logical no-undo .
    if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanRecipes then v-ban-recipes = true .
    if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanAltr then v-ban-altr = true .
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-doc-code
    .
    run extend-noweight-gds-qnty in this-procedure (
          input p-gds-code
        , input p-need-qnty
        , output p-need-qnty
    ).
    run select-recipe in this-procedure (
          input p-mainmenu-handle
        , input buf_fbr-doc.obj-type
        , input buf_fbr-doc.obj-code
        , input p-gds-code
        , input p-trn-type
        , input p-need-qnty
        , input p-autofbr
        , input p-have-store
        , output v-comp-gds-code
        , output v-comp-trn-type
        , output v-comp-need-qnty
        , output v-comp-recipe-type
        , output v-comp-recipe-code
        , output v-comp-recipe-found
        , output v-no-add-good
    ) no-error.
    if not error-status :error
    and v-comp-recipe-found = yes
    and v-no-add-good       = no
    then do:
        find first buf_goods no-lock
             where buf_goods.gds-code = v-comp-gds-code
        .
        assign
            v-ext-comp-recipe-type = v-comp-recipe-type
        .
        if v-comp-recipe-type = 'комплектация':U
        and v-comp-trn-type   = 'спи':U
        then do:
            assign
                v-ext-comp-recipe-type = 'разделка':U
            .
        end.
        case v-ext-comp-recipe-type
        :
            when 'разделка':U
            then do:
                find first buf_temp_goods-qnty
                     where buf_temp_goods-qnty.gds-code    = v-comp-gds-code
                       and buf_temp_goods-qnty.recipe-code = v-comp-recipe-code
                no-error.
                if not available buf_temp_goods-qnty
                then do:
                    create buf_temp_goods-qnty.
                    assign
                        buf_temp_goods-qnty.gds-code    = v-comp-gds-code
                        buf_temp_goods-qnty.recipe-type = v-comp-recipe-type
                        buf_temp_goods-qnty.recipe-code = v-comp-recipe-code
                        buf_temp_goods-qnty.artic       = buf_goods.artic
                        buf_temp_goods-qnty.prod-type   = buf_goods.prod-type
                        buf_temp_goods-qnty.prod-code   = buf_goods.prod-code
                        buf_temp_goods-qnty.trn-type    = v-comp-trn-type
                        buf_temp_goods-qnty.need-qnty   = v-comp-need-qnty
                        buf_temp_goods-qnty.calculated  = no
                    .
                end.
                else do:
                    find first buf_goods no-lock
                         where buf_goods.gds-code = p-gds-code
                    .
                    find first buf_fbr-line no-lock
                         where buf_fbr-line.doc-code    = p-doc-code
                           and buf_fbr-line.trn-type    = p-trn-type
                           and buf_fbr-line.recipe-code = v-comp-recipe-code
                           and buf_fbr-line.artic       = buf_goods.artic
                           and buf_fbr-line.prod-type   = buf_goods.prod-type
                           and buf_fbr-line.prod-code   = buf_goods.prod-code
                    no-error.
                    if available buf_fbr-line
                    then do:
                        define variable v-line-qnty             as decimal   no-undo.
                        define variable v-used-qnty             as decimal   no-undo.
                        define variable v-free-qnty             as decimal   no-undo.
                        define variable v-recipe-qnty           as decimal   no-undo.
                        define variable v-comp-fbr-line-recid   as recid     no-undo.
                        run get-temp_dressing-ingr-used-qnty in this-procedure (
                              input v-comp-recipe-code
                            , input p-gds-code
                            , output v-line-qnty
                            , output v-used-qnty
                            , output v-recipe-qnty
                        ).
                        run fbrrest-get-free-qnty in this-procedure (
                              input buf_fbr-doc.obj-type
                            , input buf_fbr-doc.obj-code
                            , input p-gds-code
                            , input p-autofbr
                            , output v-free-qnty
                        ).
                        assign
                            p-need-qnty = p-need-qnty + v-recipe-qnty
                        .
                        run calc-comp-from-ingr in this-procedure (
                              input recid( buf_fbr-line )
                            , input p-need-qnty
                            , output v-comp-fbr-line-recid
                            , output v-comp-need-qnty
                        ) .
                    end.
                    assign
                        buf_temp_goods-qnty.need-qnty   = maximum( buf_temp_goods-qnty.need-qnty, v-comp-need-qnty )
                        buf_temp_goods-qnty.calculated  = no
                    .
                end.
            end.
            otherwise do:
      if v-ban-altr or v-ban-recipes then
      do:
          if v-ext-comp-recipe-type = 'производство':U and v-ban-recipes then
          do:
             for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = v-comp-recipe-code:
                run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
                   , input  'mark-type':U
                   , output v-attr-value
                   , output v-attr-type
                   ) no-error .
                if v-attr-value <> "" and v-attr-value <> "not-type" then
                do:
                   message "Рецепт производства " + v-comp-recipe-code + " содержит маркированный товар."
                      view-as alert-box.
                   return .
                end.
             end.
          end.
          if v-ext-comp-recipe-type = 'альтернатива':U and v-ban-altr then
          do:
             if not check-ban-sales-via-cd(buf_goods.gds-code) then
             do:
               message "Рецепт альтернатива " + v-comp-recipe-code + " входит в группу, у которой не установлен атрибут: " + chr(10) + "Запрет передачи на кассу."
                 view-as alert-box.
               return .
             end.
          end.
          if v-ext-comp-recipe-type = 'комплектация':U and v-ban-recipes then
          do:
             for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = v-comp-recipe-code:
                run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
                   , input  'mark-type':U
                   , output v-attr-value
                   , output v-attr-type
                   ) no-error .
                if v-attr-value <> "" and v-attr-value <> "not-type" then
                do:
                   run gds-attr-value in this-procedure  ( input  p-gds-code
                      , input  'mark-type':U
                      , output v-attr-value-rec
                      , output v-attr-type
                      ) no-error .
                   if v-attr-value-rec = "" or v-attr-value-rec = "not-type" then
                   do:
                      message "Рецепт комплектации " + v-comp-recipe-code + " должен быть маркированным"
                         view-as alert-box.
                      return .
                   end.
                   else leave.
                end.
             end.
          end.
      end.
                find first buf_temp_goods-qnty
                     where buf_temp_goods-qnty.gds-code = p-gds-code
                       and buf_temp_goods-qnty.trn-type = p-trn-type
                no-error.
                if available buf_temp_goods-qnty
                then do:
                    assign
                        buf_temp_goods-qnty.need-qnty  = buf_temp_goods-qnty.need-qnty + p-need-qnty
                    .
                    if buf_temp_goods-qnty.recipe-code <> ""
                    then do:
                        assign
                            buf_temp_goods-qnty.calculated = no
                        .
                    end.
                    run writelog in this-procedure ( log-file-name, 5, substitute( "Раскрутка ингредиетнов: добавляем товар '&1' к уже рассчитанному: &2", buf_temp_goods-qnty.artic, buf_temp_goods-qnty.need-qnty  ) ).
                end.
                else do:
                    find first buf_temp_goods-qnty
                         where buf_temp_goods-qnty.gds-code = v-comp-gds-code
                           and buf_temp_goods-qnty.trn-type = v-comp-trn-type
                    no-error.
                    if not available buf_temp_goods-qnty
                    then do:
                        create buf_temp_goods-qnty.
                        find first buf_goods no-lock
                             where buf_goods.gds-code = v-comp-gds-code
                        .
                        assign
                            buf_temp_goods-qnty.gds-code    = v-comp-gds-code
                            buf_temp_goods-qnty.artic       = buf_goods.artic
                            buf_temp_goods-qnty.prod-type   = buf_goods.prod-type
                            buf_temp_goods-qnty.prod-code   = buf_goods.prod-code
                            buf_temp_goods-qnty.trn-type    = v-comp-trn-type
                            buf_temp_goods-qnty.need-qnty   = v-comp-need-qnty
                            buf_temp_goods-qnty.recipe-type = v-comp-recipe-type
                            buf_temp_goods-qnty.recipe-code = v-comp-recipe-code
                            buf_temp_goods-qnty.calculated  = no
                        .
                        run writelog in this-procedure ( log-file-name, 5, "Раскрутка ингредиентов: добавляем товар как не рассчитанный." ).
                    end.
                end.
            end.
        end case.
        if available buf_temp_goods-qnty
        then do:
            run extend-noweight-gds-qnty in this-procedure (
                  input buf_temp_goods-qnty.gds-code
                , input buf_temp_goods-qnty.need-qnty
                , output buf_temp_goods-qnty.need-qnty
            ).
        end.
        find first buf_goods no-lock
             where buf_goods.gds-code = v-comp-gds-code
        .
        if v-ext-comp-recipe-type = 'разделка':U
        then do:
            find first buf_fbr-line exclusive-lock
                where buf_fbr-line.doc-code    = p-doc-code
                and buf_fbr-line.trn-type    = v-comp-trn-type
                and buf_fbr-line.recipe-code = v-comp-recipe-code
                and buf_fbr-line.artic       = buf_goods.artic
                and buf_fbr-line.prod-type   = buf_goods.prod-type
                and buf_fbr-line.prod-code   = buf_goods.prod-code
            no-error.
            if available buf_fbr-line
            then do:
                assign
                    buf_fbr-line.fact-qnty = 0
                .
            end.
        end.
        else do:
            for each buf_fbr-line exclusive-lock
            where buf_fbr-line.doc-code    = p-doc-code
                and buf_fbr-line.recipe-code = v-comp-recipe-code
            on error undo, return error
            :
                delete buf_fbr-line.
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE extend-noweight-gds-qnty :
do
on error undo, return error
:
define input parameter p-gds-code   as integer      no-undo.
define input parameter p-in-qnty    as decimal      no-undo.
define output parameter p-out-qnty  as decimal      no-undo.
    define buffer buf_goods                 for ub.goods.
    define buffer buf_units                 for ub.units.
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    find first buf_units no-lock
         where buf_units.unit-name = buf_goods.unit-base
    .
    assign
        p-out-qnty = p-in-qnty
    .
    if not ( lookup( 'вес':U, buf_units.type ) > 0
             or lookup ('дро':U, buf_units.type) > 0 )
    then do:
        if p-out-qnty <> truncate( p-out-qnty, 0 )
        then do:
            assign
                p-out-qnty = truncate( p-out-qnty, 0 ) + 1
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE select-recipe :
do
on error undo, return error
:
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-gds-code           as integer          no-undo.
define input parameter p-trn-type           as character        no-undo.
define input parameter p-gds-qnty           as decimal          no-undo.
define input parameter p-autofbr            as logical          no-undo.
define input parameter p-have-store         as logical          no-undo.
define output parameter p-out-gds-code      as integer          no-undo.
define output parameter p-out-trn-type      as character        no-undo.
define output parameter p-out-gds-qnty      as decimal          no-undo.
define output parameter p-out-recipe-type   as character        no-undo.
define output parameter p-out-recipe-code   as character        no-undo.
define output parameter p-recipe-found      as logical          no-undo.
define output parameter p-no-need-good      as logical          no-undo.
define variable v-host-code             as integer      no-undo.
define variable v-value-character as character  no-undo .
define variable v-value-date      as date       no-undo .
define variable v-value-decimal   as decimal    no-undo .
define variable v-value-integer   as integer    no-undo .
define variable v-value-logical   as logical    no-undo .
define variable v-tth             as handle     no-undo .
define variable v-param-type            as character no-undo .
define variable v-type                  as character    no-undo.
define variable v-recipe-type           as character    no-undo.
define variable v-recipe-list           as character    no-undo.
define variable v-is-comp               as logical      no-undo.
define variable v-is-integration        as logical      no-undo.
define variable v-cancel                as logical      no-undo.
define variable v-yesno                 as logical      no-undo.
define variable v-default-recipe-code   as character    no-undo.
    define buffer buf_recipe            for ub.recipe.
    define buffer buf_goods             for ub.goods.
    define buffer buf_selected_recipe   for ub.recipe.
    define buffer buf_recipe-gds        for ub.recipe-gds.
    define buffer buf_ingr_goods        for ub.goods.
    run writelog in this-procedure (
        input log-file-name
        , input 0
        , input "******** select-recipe ***************************************"
    ).
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    if p-trn-type = ?
    then do:
        run writelog in this-procedure ( log-file-name, 0, "Не определен тип строки. Добавление невозможно" ).
        undo, return error.
    end.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'fbrattr':U
                      , input  'fbr-frcp':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error then do:
       assign
          v-value-logical = FALSE
       .
    end.
    run writelog in this-procedure (
          input log-file-name
        , input 1
        , input substitute( "fbr-frcp = '&1'", v-value-logical )
    ).
    assign
        p-out-recipe-type = ?
        p-out-recipe-code = ?
        v-recipe-type = ?
    .
    run fbrlib-get-obj-recipe in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-gds-code
        , output v-default-recipe-code
    ).
    comp-recipe:
    for each buf_recipe no-lock
       where ( buf_recipe.obj-type = p-obj-type
           and buf_recipe.obj-code = p-obj-code
           and buf_recipe.artic     = buf_goods.artic
           and buf_recipe.prod-type = buf_goods.prod-type
           and buf_recipe.prod-code = buf_goods.prod-code
           and buf_recipe.stts      <> 2
          )
          or ( buf_recipe.obj-type = ""
           and buf_recipe.obj-code = 0
           and buf_recipe.artic     = buf_goods.artic
           and buf_recipe.prod-type = buf_goods.prod-type
           and buf_recipe.prod-code = buf_goods.prod-code
           and buf_recipe.stts      <> 2
          )
    :
        if  ( p-autofbr = yes or v-value-logical = yes ) and buf_recipe.recipe-code <> v-default-recipe-code
        then do:
            undo comp-recipe, next comp-recipe.
        end.
        run writelog in this-procedure (
              input log-file-name
            , input 3
            , input substitute( "Рецепт: &1. Тип: &2 " , buf_recipe.recipe-code, buf_recipe.recipe-type )
        ).
        if p-autofbr = yes
        and buf_recipe.recipe-type <> 'производство':U
        and buf_recipe.recipe-type <> 'альтернатива':U
        and buf_recipe.recipe-type <> 'комплектация':U
        and buf_recipe.recipe-type <> 'комплектация':U
        then do:
            next comp-recipe.
        end.
        if p-trn-type = 'при':U
        and buf_recipe.recipe-type = 'разделка':U
        then do:
            run writelog in this-procedure (
                  input log-file-name
                , input 4
                , input "Разделка для составного не может дать прихода. Ищем следующий рецепт"
            ).
            next comp-recipe.
        end.
        if p-trn-type = 'спи':U
        and buf_recipe.recipe-type <> 'разделка':U
        and buf_recipe.recipe-type <> 'комплектация':U
        then do:
            run writelog in this-procedure (
                  input log-file-name
                , input 4
                , input "Только разделка или разукомплектация для составного может дать списание. Ищем следующий рецепт"
            ).
            next comp-recipe.
        end.
        if v-recipe-type = ?
        then do:
            assign
                p-out-recipe-type = buf_recipe.recipe-type
                p-out-recipe-code = buf_recipe.recipe-code
                v-recipe-type = "recipe"
                v-is-integration = yes
            .
            run writelog in this-procedure (
                  input log-file-name
                , input 4
                , input "Найден первый подходящий рецепт для составного"
            ).
            if v-value-logical
            then do:
                run writelog in this-procedure (
                    input log-file-name
                    , input 4
                    , input "Включен параметр fbr-frcp. Больше рецепт не ищем"
                ).
                leave comp-recipe.
            end.
            if p-autofbr = yes
            then do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 4
                    , input "Раскрутка для ресторана. Больше рецепт не ищем"
                ).
                leave comp-recipe.
            end.
        end.
        else do:
            run writelog in this-procedure (
                  input log-file-name
                , input 4
                , input "Найден еще один подходящий рецепт"
            ).
            assign
                v-yesno = ?
                p-no-need-good = yes
            .
            do while v-yesno = ?
            and p-no-need-good = yes
            :
                run ref/rcp-all.w (
                      input p-mainmenu-handle
                    , input "b-sel"
                    , input 'все':U
                    , input recid( buf_goods )
                    , input p-obj-type
                    , input p-obj-code
                    , output v-recipe-list
                ) no-error.
                if error-status :error
                or v-recipe-list = ""
                then do:
                    message
                        "Отменить добавление товара?"
                        skip(1)
                        skip "Товар:" buf_goods.artic buf_goods.gds-name
                        skip(1)
                        skip "Yes - отменить добавление текущего товара"
                        skip "No  - отменить добавление товаров"
                        skip "Cancel - вернуться к выбору рецептов"
                    view-as alert-box question
                    buttons yes-no-cancel
                    title "Отмена"
                    update v-yesno
                    .
                end.
                else do:
                    assign
                        p-no-need-good = no
                    .
                end.
            end.
            if p-no-need-good = yes
            then do:
                if v-yesno = no
                then do:
                    undo, return error .
                end.
                else do:
                    return.
                end.
            end.
            find first buf_selected_recipe no-lock
                 where recid( buf_selected_recipe ) = integer( entry( 1, v-recipe-list ) )
            no-error.
            if not available buf_selected_recipe
            then do:
                assign
                    p-out-recipe-type = ?
                    p-out-recipe-code = ?
                    v-is-integration  = ?
                .
            end.
            else do:
                assign
                    p-out-recipe-type   = buf_selected_recipe.recipe-type
                    p-out-recipe-code   = buf_selected_recipe.recipe-code
                    v-recipe-type       = "recipe"
                    v-is-integration    = yes
                .
                leave comp-recipe.
            end.
        end.
    end.
    if v-recipe-type = ?
    and p-autofbr = no
    then do:
        run writelog in this-procedure (
              input log-file-name
            , input 3
            , input "Поиск товара среди ингредиентов рецептов."
        ).
        search-recipe-gds:
        for each buf_recipe-gds
           where buf_recipe-gds.artic       = buf_goods.artic
             and buf_recipe-gds.prod-type   = buf_goods.prod-type
             and buf_recipe-gds.prod-code   = buf_goods.prod-code
        :
            find first buf_recipe no-lock
                 where buf_recipe.recipe-code = buf_recipe-gds.recipe-code
                   and buf_recipe.obj-type    = p-obj-type
                   and buf_recipe.obj-code    = p-obj-code
                 no-error
            .
            if not available buf_recipe then next search-recipe-gds.
            find buf_ingr_goods no-lock
                where buf_ingr_goods.gds-code = buf_recipe.gds-code
            .
            if buf_ingr_goods.stts <> 0 then do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input subst("Рецепт &1 на товар &2 не подходит т.к. товар удален", buf_recipe.recipe-code, buf_ingr_goods.gds-code)
                ).
                next search-recipe-gds.
            end.
            run writelog in this-procedure (
                  input log-file-name
                , input 3
                , input substitute( "Рецепт: &1. Тип: &2 " , buf_recipe.recipe-code, buf_recipe.recipe-type )
            ).
            if p-trn-type = 'при':U
            and buf_recipe.recipe-type <> 'разделка':U
            and buf_recipe.recipe-type <> 'комплектация':U
            then do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input "Тип не подходит. Только разделка или разукомплектация для ингредиента может дать приход"
                ).
                next search-recipe-gds.
            end.
            if p-trn-type = 'спи':U
            and buf_recipe.recipe-type = 'разделка':U
            then do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input "Тип не подходит. Разделка для ингредиента не может дать списания"
                ).
                next search-recipe-gds.
            end.
            if v-recipe-type = ?
            then do:
                assign
                    p-out-recipe-type   = buf_recipe.recipe-type
                    p-out-recipe-code   = buf_recipe.recipe-code
                    v-recipe-type       = "recipe-gds"
                    v-is-integration    = no
                .
                if v-value-logical
                then do:
                    leave search-recipe-gds.
                end.
            end.
            else do:
                assign
                    p-out-recipe-type = ?
                    p-out-recipe-code = p-out-recipe-code + chr(44) + buf_recipe.recipe-code
                    v-is-integration  = ?
                .
            end.
        end.
    end.
    if p-out-recipe-type = ?
    and p-out-recipe-code = ?
    then do:
        assign
            p-recipe-found = no
        .
    end.
    else do:
        if p-out-recipe-type = ?
        then do:
            define variable v-recipe-recid-list as character     no-undo.
            run str/rcp-sel.w (
                  input p-mainmenu-handle
                , input buf_goods.gds-code
                , input 'при':U
                , output p-out-recipe-code
                , output v-is-integration
                , output v-cancel
            ) .
            if v-cancel = yes
            then do:
                assign
                    p-recipe-found = no
                    p-no-need-good = yes
                .
                return.
            end.
        end.
        assign
            p-recipe-found = yes
        .
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = p-out-recipe-code
        .
        find first buf_goods no-lock
             where buf_goods.artic      = buf_recipe.artic
               and buf_goods.prod-type  = buf_recipe.prod-type
               and buf_goods.prod-code  = buf_recipe.prod-code
        .
        assign
            p-out-recipe-type   = buf_recipe.recipe-type
            p-out-gds-code      = buf_goods.gds-code
        .
        run fbrlib-get-trn-type in this-procedure (
              input buf_recipe.recipe-code
            , input recid( buf_goods )
            , input v-is-integration
            , output v-is-comp
            , output p-out-trn-type
        ).
        run writelog in this-procedure (
              input log-file-name
            , input 1
            , input substitute( "Найден рецепт '&1' с is-comp = &2, товаром '&3 &4', типом &5"
                                , p-out-recipe-code
                                , v-is-comp
                                , buf_goods.artic
                                , buf_goods.gds-name
                                , p-out-trn-type )
        ).
        if p-out-gds-code <> p-gds-code
        then do:
            run writelog in this-procedure (
                  input log-file-name
                , input 1
                , input "Необходимый товар является ингредиентом"
            ).
            find first buf_goods no-lock
                 where buf_goods.gds-code = p-gds-code
            .
            find first buf_recipe-gds no-lock
                 where buf_recipe-gds.recipe-code = buf_recipe.recipe-code
                   and buf_recipe-gds.artic       = buf_goods.artic
                   and buf_recipe-gds.prod-type   = buf_goods.prod-type
                   and buf_recipe-gds.prod-code   = buf_goods.prod-code
            .
            if buf_recipe-gds.brutto-qnty = ?
            or buf_recipe-gds.brutto-qnty = 0
            then do:
                message
                    "При раскрутке рецепта обнаружен ингредиент с количеством " buf_recipe-gds.brutto-qnty
                    skip "Продолжение расчета документа невозможно."
                    skip(1) "Код рецепта:      " buf_recipe.recipe-code
                    skip    "Товар ингредиента:" buf_recipe-gds.artic buf_goods.gds-name
                view-as alert-box error.
                undo, return error .
            end.
            assign
                p-out-gds-qnty = p-gds-qnty / buf_recipe-gds.brutto-qnty * buf_recipe.qnty
                p-out-trn-type = ( if p-trn-type = 'спи':U then 'при':U else 'спи':U )
            .
            run writelog in this-procedure (
                input log-file-name
                , input 1
                , input substitute( "Количество товара: &1. Для его производства необходимо: &2 по рецепту: &3. Тип строки составного: &4."
                                    , p-gds-qnty
                                    , p-out-gds-qnty
                                    , p-out-recipe-code
                                    , p-out-trn-type )
            ).
        end.
        else do:
            assign
                p-out-gds-qnty = p-gds-qnty
                p-out-trn-type = p-trn-type
            .
            run writelog in this-procedure (
                  input log-file-name
                , input 1
                , input substitute( "Для производства товара необходимо: &1 по рецепту: &2. Тип строки: &3."
                                    , p-out-gds-qnty
                                    , p-out-recipe-code
                                    , p-out-trn-type )
            ).
        end.
    end.
end.
END PROCEDURE.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdsoattr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ggoattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
    define variable v-copy-qnty             like doc-line.fact-qnty     no-undo.
    define variable v-auto-select-recipes   as logical                  no-undo.
    define variable v-gds-code              as integer       no-undo.
    define variable v-trn-type              as character     no-undo.
    define variable v-need-qnty             as decimal       no-undo.
    define variable v-recipe-type           as character     no-undo.
    define variable v-recipe-code           as character     no-undo.
    define variable v-recipe-found          as logical       no-undo.
    define variable v-same-good             as logical       no-undo.
    define variable v-same-good-old-qnty    as decimal       no-undo.
    define variable v-no-add-good           as logical       no-undo.
    define buffer buf_doc-line          for doc-line.
    define buffer buf_trn-doc           for trn-doc.
    define buffer buf_return_doc-line   for doc-line.
    define buffer buf_goods             for goods.
do
for buf_doc-line
  , buf_trn-doc
  , buf_return_doc-line
  , buf_goods
on error undo, return error
:
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-trn-doc-doc-code
    .
    assign
        v-auto-select-recipes = yes
    .
    message
        "Добавление строк из накладной (продажи) №" buf_trn-doc.doc-code
        skip (2)
        skip "YES - выбирать рецепты автоматически"
        skip "NO - давать выбирать и добавлять рецепты по ходу работы"
        skip "CANCEL - отказ от добавления из документа"
    view-as alert-box question
    buttons YES-NO-CANCEL
    update v-auto-select-recipes.
    if v-auto-select-recipes = ?
    then do:
        return error.
    end.
    if buf_trn-doc.discnt-type = 'касс':U
    then do:
        run str/dtlrests.p (
                        input  buf_trn-doc.doc-code
                        ,input no
                        ,input "parts":U
                        ,input yes
                        ,input yes
                        ,input no
                        ,input no
                        ,input no
                        ,input no
        ).
    end.
    for each buf_doc-line no-lock
       where buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.artic     = buf_doc-line.artic
               and buf_goods.prod-type = buf_doc-line.prod-type
               and buf_goods.prod-code = buf_doc-line.prod-code
        .
        if buf_trn-doc.doc-type = 'рас':U
        or buf_trn-doc.doc-type = 'спи':U
        then do:
            if buf_trn-doc.discnt-type = 'касс':U
            then do:
                find first dtl-rests no-lock
                     where dtl-rests.gds-code = buf_goods.gds-code
                no-error.
                if available dtl-rests
                then do:
                    assign
                        v-copy-qnty = dtl-rests.need-qnty
                    .
                end.
                else do:
                    assign
                        v-copy-qnty = 0
                    .
                end.
            end.
            else do:
                assign
                    v-copy-qnty = buf_doc-line.fact-qnty
                .
            end.
            if v-copy-qnty <> 0
            then do:
                run str/fbrselr.p (
                      input parparentproc
                    , input p-fbr-doc-obj-type
                    , input p-fbr-doc-obj-code
                    , input buf_goods.gds-code
                    , input ( if v-copy-qnty > 0
                            then 'при':U
                            else 'спи':U )
                    , input absolute( v-copy-qnty )
                    , input no
                    , input no
                    , output v-gds-code
                    , output v-trn-type
                    , output v-need-qnty
                    , output v-recipe-type
                    , output v-recipe-code
                    , output v-recipe-found
                    , output v-no-add-good
                ) no-error.
                if not error-status :error
                and v-recipe-found = yes
                and v-no-add-good  = no
                then do:
                    find first buf_goods no-lock
                        where buf_goods.gds-code = v-gds-code
                    .
                    run create-initial-temp-goods in this-procedure (
                          input p-fbr-doc-doc-code
                        , input buf_goods.artic
                        , input buf_goods.prod-type
                        , input buf_goods.prod-code
                        , input v-trn-type
                        , input v-recipe-type
                        , input v-recipe-code
                        , input v-need-qnty
                        , output v-same-good
                        , output v-same-good-old-qnty
                    ).
                    run calc-not-calculated-goods in this-procedure (
                          input parparentproc
                        , input p-fbrhist-handle
                        , input p-fbr-doc-doc-code
                        , input v-same-good
                        , input v-same-good-old-qnty
                        , input NOT( v-auto-select-recipes )
                        , input yes
                        , input p-price-sale-obj-type
                        , input p-price-sale-obj-code
                        , input no
                        , input no
                    ).
                end.
            end.
        end.
        else do:
        end.
    end.
end.
