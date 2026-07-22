block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character        no-undo.
define variable p-auto         as integer no-undo .
define variable p-inkas-code   like ub.inkas.inkas-code no-undo .
define variable p-filter-on as logical no-undo .
define variable v-curr-r-b  as character no-undo .
define variable is-wth      as logical   no-undo .
define variable cas-shft    as logical no-undo init no.
define variable one-curs    as logical no-undo init no.
define variable cas-curs    as logical no-undo init no.
define variable prcl-spl    as logical no-undo init no.
define variable pay-gds-algo as character no-undo .
define variable rdtaxcd     as INTEGER                  no-undo.
define variable exctaxcd    as INTEGER                  no-undo.
define variable factorrt    as decimal no-undo.
define variable btltaxcd    as INTEGER                  no-undo.
define variable p-day-only  as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Закачка чеков в продажу".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
FUNCTION calc-excise RETURNS DECIMAL(input  parprice-sale as decimal,
                                     input  parroad-tax   as decimal,
                                     input  parvat-pc     as decimal,
                                     input  parfactorrd   as decimal,
                                     output parexcise     as decimal):
ASSIGN parexcise = (parprice-sale - parroad-tax) * parvat-pc / (100 + parvat-pc) -
                   1 / parfactorrd * parroad-tax.
RETURN parexcise.
END FUNCTION.
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION set-inkas-PS returns character(    input p-ps as character,
                                            input p-chk-amount as integer,
                                            input p-gds-amount as integer,
                                            input p-line-out as integer,
                                            input p-dtl-out as integer,
                                            input p-line-ret as integer,
                                            input p-dtl-ret as integer,
                                            input p-nf-chk-amount as integer,
                                            input p-nf-gds-amount as integer,
                                            input p-ps-where-rus as character
                                            ):
define variable v-ps as character no-undo .
define variable v-other as character no-undo .
v-other = p-ps.
entry(1, v-other, "@") = ''.
v-other = trim(v-other, "@").
v-PS = substitute('Кол-во_чеков &2&1строк_чеков &3&1товаров_расход &4&1признаков_расход &5&1товаров_возврат &6&1признаков_возврат &7&1'
                    , chr(4)
                    , p-chk-amount
                    , p-gds-amount
                    , p-line-out
                    , p-dtl-out
                    , p-line-ret
                    , p-dtl-ret).
v-ps = v-ps +  substitute("без_докум_чеков &1&2без_докум_строк_чеков &3&2&4@&5"
                            , p-nf-chk-amount
                            , chr(4)
                            , p-nf-gds-amount
                            , p-ps-where-rus
                            , v-other)
                    .
return v-ps.
END FUNCTION.
FUNCTION set-inkas-PS-simple returns character(
                                            input p-chk-amount as integer,
                                            input p-gds-amount as integer,
                                            input p-line-out as integer,
                                            input p-dtl-out as integer,
                                            input p-line-ret as integer,
                                            input p-dtl-ret as integer,
                                            input p-nf-chk-amount as integer,
                                            input p-nf-gds-amount as integer
                                            ):
define variable v-ps as character no-undo .
define variable v-str1 as character no-undo .
assign
  v-ps = fill( chr(32) +  chr(4), 9).
  v-str1 = ENTRY(1, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-chk-amount).
  ENTRY(1, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(2, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-gds-amount).
  ENTRY(2, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(3, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-line-out).
  ENTRY(3, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(4, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-dtl-out).
  ENTRY(4, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(5, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-line-ret).
  ENTRY(5, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(6, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-dtl-ret).
  ENTRY(5, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(7, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-nf-chk-amount).
  ENTRY(5, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(8, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-nf-gds-amount).
  ENTRY(5, v-PS, chr(4)) = v-str1.
return v-ps.
END FUNCTION.
FUNCTION get-inkas-nf-PS-simple returns logical (
                                             input p-ps as character
                                            ,output p-gds-amount as integer
                                            ,output p-nf-gds-amount as integer
                                            ):
if num-entries(p-ps, chr(4)) >= 8 then do:
  assign
  p-gds-amount = integer(entry(2, ENTRY(2, p-PS, chr(4)), chr(32)))
  p-nf-gds-amount = integer(entry(2, ENTRY(8, p-PS, chr(4)), chr(32)))
  no-error .
end.
return not error-status:error .
END FUNCTION.
PROCEDURE get-inkas-PS:
define parameter buffer buf_inkas for ub.inkas.
define output parameter p-chk-amount as integer no-undo .
define output parameter p-gds-amount as integer no-undo .
define output parameter p-line-out as integer no-undo .
define output parameter p-dtl-out as integer no-undo .
define output parameter p-line-ret as integer no-undo .
define output parameter p-dtl-ret as integer no-undo .
define output parameter p-nf-chk-amount as integer no-undo .
define output parameter p-nf-gds-amount as integer no-undo .
define output parameter p-ps-where-rus as character no-undo .
define variable v-gds-amount as integer no-undo .
define variable v-nf-gds-amount as integer no-undo .
define buffer buf_sale-doc for ub.sale-doc.
for each buf_sale-doc no-lock where
        buf_sale-doc.inkas-code = buf_inkas.inkas-code
    and buf_sale-doc.order > 0:
  assign
  p-gds-amount = p-gds-amount + (if buf_sale-doc.in-inkas = yes
                                 or buf_sale-doc.doc-kind = 'trf':U
                                 then buf_sale-doc.gds-amount
                                 else 0)
  p-line-out = p-line-out  + (if buf_sale-doc.in-inkas = yes
                              and buf_sale-doc.dir = 1
                              then buf_sale-doc.tot-lines
                              else 0)
  p-dtl-out = p-dtl-out + (if buf_sale-doc.in-inkas = yes
                          and buf_sale-doc.dir = 1
                          then buf_sale-doc.tot-dtl
                          else 0)
  p-line-ret = p-line-ret  + (if buf_sale-doc.in-inkas = yes
                              and buf_sale-doc.dir = -1
                              then buf_sale-doc.tot-lines
                              else 0)
  p-dtl-ret = p-dtl-ret + (if buf_sale-doc.in-inkas = yes
                           and buf_sale-doc.dir = -1
                          then buf_sale-doc.tot-dtl
                          else 0)
  .
end.
if get-inkas-nf-PS-simple( input buf_inkas.ps
                          ,output v-gds-amount
                          ,output v-nf-gds-amount) then do:
  assign
  p-gds-amount = v-gds-amount
  p-nf-gds-amount = v-nf-gds-amount
  .
end.
assign
p-ps-where-rus = buf_inkas.sale-filter-rus
p-nf-chk-amount = buf_inkas.num-chk-nf
p-chk-amount = buf_inkas.num-chk
.
END PROCEDURE.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION set-sale-doc-PS returns character( buffer buf_sale-doc for ub.sale-doc):
define variable v-ps as character no-undo .
if available buf_sale-doc then
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , chr(4)
                    , (if buf_sale-doc.chr-office = 'у':U then "УСЛУГИ." else "ТОВАРЫ." )
                    , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                    , buf_sale-doc.chk-amount
                    , buf_sale-doc.gds-amount
                    , buf_sale-doc.tot-lines
                    , buf_sale-doc.tot-dtl
                    ).
else  do:
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , chr(4)
                    , '':U
                    , entry (lookup ('es':U, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                    , 0
                    , 0
                    , 0
                    , 0
                    ).
end.
return v-ps.
END FUNCTION.
FUNCTION get-sale-doc-kind returns character (
                                             input p-doc-kind as character
                                           , input p-ext-doc-type as character
                                           , output p-order as integer
                                           , output p-msign as integer
                                           , output p-main as logical
                                           , output p-in-inkas as logical
                                           , output p-dir_ as integer
                                           ):
define variable v-doc-kind as character no-undo.
define variable v-type as character no-undo .
define variable v-value as character no-undo .
CASE p-doc-kind:
  when 'es':U then do:
    assign
    p-order = 100
    p-msign = 1
    p-main = yes
    p-in-inkas = yes
    p-dir_ = 1
    .
    return p-ext-doc-type.
  end.
  when  'rs':U then do:
    assign
    p-order = 200
    p-msign = - 1
    p-main = no
    p-in-inkas = yes
    p-dir_ = - 1
    .
    return p-ext-doc-type.
  end.
  when 'rwo':U then do:
    assign
    p-msign = - 1
    p-main = no
    p-in-inkas = no
    p-order = 300
    p-dir_ = 1
    .
    return 'rwo':U.
  end.
  when 'trf':U then do:
    assign
    p-msign = 1
    p-main = no
    p-in-inkas = no
    p-order = 400
    p-dir_ = 1
    .
    return 'trf':U.
  end.
  when 'swo':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order =  500
   p-dir_ = 1
   .
   return 'swo':U.
 end.
 when 'vir':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 600
   p-dir_ = 1
   .
   return 'vir':U.
 end.
 when 'itr':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = -1
   p-dir_ = -1
   .
  return 'itr':U.
 end.
 when 'ngs':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 700
   p-dir_ = 1
   .
   return 'ngs':U.
 end.
 when 'rgs':U then do:
   assign
   p-msign = -1
   p-main = no
   p-in-inkas = no
   p-order = 701
   p-dir_ = -1
   .
   return 'rgs':U.
 end.
 otherwise do:
    assign
    p-msign = 1
    p-main = no
    p-in-inkas = no
    p-order = -1.
    return p-ext-doc-type.
  end.
END CASE.
END FUNCTION.
procedure saledoc-create :
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-doc-kind as character no-undo .
define input parameter p-office as character no-undo .
define input parameter p-tpsidoc as logical no-undo .
define input parameter p-alias-type-price as character no-undo .
define input parameter p-price-obj-type as character no-undo .
define input parameter p-price-obj-code as integer no-undo .
define parameter buffer buf_trn-doc for ub.trn-doc.
define variable v-order as integer no-undo.
define variable v-main as logical no-undo .
define variable v-in-inkas as logical no-undo .
define variable v-msign as integer no-undo .
define variable v-dir_ as integer no-undo .
define variable v-trn-doc-code as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
   if available buf_trn-doc then do:
     v-trn-doc-code = buf_trn-doc.doc-code.
   end.
   find first buf_sale-doc where
            buf_sale-doc.inkas-code = p-inkas-code
        and buf_sale-doc.doc-kind = p-doc-kind
        and buf_sale-doc.chr-office = p-office
        and (v-trn-doc-code = '' or buf_sale-doc.doc-code = v-trn-doc-code)
        no-error .
   if not available buf_sale-doc  then do:
      create buf_sale-doc.
      assign
      buf_sale-doc.inkas-code = p-inkas-code
      buf_sale-doc.storage =  'trn-doc':U
      buf_sale-doc.host-code = p-host-code
      buf_sale-doc.obj-type = p-obj-type
      buf_sale-doc.obj-code = p-obj-code
      buf_sale-doc.doc-kind  = p-doc-kind
      buf_sale-doc.order = lookup(p-doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) * 100 + (if p-office = 'у':U then 5 else 0)
      buf_sale-doc.chr-office = p-office
      buf_sale-doc.doc-code = v-trn-doc-code
      .
   end.
   if available buf_trn-doc then
   buffer-copy buf_trn-doc
   to buf_sale-doc
   .
  assign
  buf_sale-doc.doc-kind = get-sale-doc-kind (
                                             input p-doc-kind
                                            ,input buf_sale-doc.ext-doc-type
                                            ,output v-order
                                            ,output v-msign
                                            ,output v-main
                                            ,output v-in-inkas
                                            ,output v-dir_).
  assign
  buf_sale-doc.order = v-order + (if p-office = 'у':U then 5 else 0)
  buf_sale-doc.main-doc = v-main
  buf_sale-doc.in-inkas = v-in-inkas
  buf_sale-doc.msign = v-msign
  buf_sale-doc.dir = v-dir_
  buf_sale-doc.fbrsale = lookup(buf_sale-doc.doc-kind, 'es,swo':U) > 0
  buf_sale-doc.main-receipt-type = integer(entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) + 1, '0,1,6,96,17,69,17,17':U))
  buf_sale-doc.poss-wro-codes = '':U
  buf_sale-doc.chr-office = p-office
  buf_sale-doc.tpsidoc = p-tpsidoc
  buf_sale-doc.alias-type-price = p-alias-type-price
  buf_sale-doc.price-obj-type = (if p-tpsidoc
                                 then p-price-obj-type
                                 else '':U)
  buf_sale-doc.price-obj-code = (if p-tpsidoc
                                 then p-price-obj-code
                                 else 0)
  .
  assign
  buf_sale-doc.poss-wro-codes = (if (v-order > 0 and buf_sale-doc.doc-kind <> 'vir':U) then entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) + 1, '0,2,-2,-6;-3;-9;-4,17,1;3':U) else '':U)
  no-error.
end.
END.
procedure fbr-saledoc-create :
define input parameter p-inkas-code as character no-undo .
define variable v-pri-prvo-doc-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-fact-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-tot-lines like ub.trn-doc.tot-lines no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf2_sale-doc for ub.sale-doc.
define buffer buf2_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-doc for ub.chk-doc.
do
on error undo, return error
:
  for each buf_fbr-doc no-lock where
        buf_fbr-doc.out-code = p-inkas-code:
    for each buf_trn-doc no-lock where
          buf_trn-doc.out-code = buf_fbr-doc.doc-code
    by buf_trn-doc.fact-order
    on error undo, return error:
      if buf_trn-doc.ext-doc-type = 'em':U
      or buf_trn-doc.ext-doc-type = 'im':U
      or buf_trn-doc.ext-doc-type = 'wm':U
      or buf_trn-doc.ext-doc-type = 'ev':U
      or buf_trn-doc.ext-doc-type = 'iv':U
      then do:
        find first buf_sale-doc where
                buf_sale-doc.inkas-code = p-inkas-code
            and buf_sale-doc.doc-code = buf_trn-doc.doc-code
            AND buf_sale-doc.storage  = 'trn-doc':U
                no-error .
        if not available buf_sale-doc then do:
        create buf_sale-doc.                                                                                             buffer-copy buf_trn-doc                                                                                             to buf_sale-doc.                                                                                                assign                                                                                                                  buf_sale-doc.storage  =  'trn-doc':U                                                                          buf_sale-doc.doc-kind = buf_trn-doc.ext-doc-type                                                                buf_sale-doc.order =  - 1                                                                                          buf_sale-doc.main-doc = no                                                                                             buf_sale-doc.in-inkas = no                                                                                         buf_sale-doc.fbrsale = yes                                                                                         buf_sale-doc.msign = 1                                                                                             buf_sale-doc.filled   = buf_sale-doc.fact-qnty <> 0 or buf_sale-doc.tot-lines <> 0                       buf_sale-doc.doc-qnty = (if buf_sale-doc.ext-doc-type = 'pc':U                                                           then ?                                                                                                                  else buf_sale-doc.doc-qnty)                                                          buf_sale-doc.fact-qnty = (if buf_sale-doc.ext-doc-type = 'pc':U                                                          then ?                                                                                                                  else buf_sale-doc.fact-qnty)                                                        buf_sale-doc.inkas-code = p-inkas-code.
        end.
        if buf_trn-doc.ext-doc-type = 'im':U then do:
          assign
          v-pri-prvo-doc-qnty = buf_trn-doc.doc-qnty
          v-pri-prvo-fact-qnty = buf_trn-doc.fact-qnty
          v-pri-prvo-tot-lines = buf_trn-doc.tot-lines
          .
        end.
        for each buf2_trn-doc no-lock where
                buf2_trn-doc.out-code = buf_sale-doc.doc-code:
          find first buf2_sale-doc where
                  buf2_sale-doc.inkas-code = p-inkas-code
              and buf2_sale-doc.doc-code = buf2_trn-doc.doc-code
              AND buf2_sale-doc.storage = 'trn-doc':U no-error .
          if not available buf2_sale-doc then do:
            create buf2_sale-doc.                                                                                             buffer-copy buf2_trn-doc                                                                                             to buf2_sale-doc.                                                                                                assign                                                                                                                  buf2_sale-doc.storage  =  'trn-doc':U                                                                          buf2_sale-doc.doc-kind = buf2_trn-doc.ext-doc-type                                                                buf2_sale-doc.order =  - 1                                                                                          buf2_sale-doc.main-doc = no                                                                                             buf2_sale-doc.in-inkas = no                                                                                         buf2_sale-doc.fbrsale = yes                                                                                         buf2_sale-doc.msign = 1                                                                                             buf2_sale-doc.filled   = buf2_sale-doc.fact-qnty <> 0 or buf2_sale-doc.tot-lines <> 0                       buf2_sale-doc.doc-qnty = (if buf2_sale-doc.ext-doc-type = 'pc':U                                                           then ?                                                                                                                  else buf2_sale-doc.doc-qnty)                                                          buf2_sale-doc.fact-qnty = (if buf2_sale-doc.ext-doc-type = 'pc':U                                                          then ?                                                                                                                  else buf2_sale-doc.fact-qnty)                                                        buf2_sale-doc.inkas-code = p-inkas-code.
          end.
        end.
      end.
    end.
    find first buf_sale-doc where
              buf_sale-doc.inkas-code = p-inkas-code
          AND buf_sale-doc.storage = 'fbr-doc':U
          AND buf_sale-doc.doc-code = buf_fbr-doc.doc-code no-error .
    if not available buf_sale-doc then do:
      create buf_sale-doc.
      assign
      buf_sale-doc.storage       =  'fbr-doc':U
      buf_sale-doc.doc-type      = 'производство':U
      buf_sale-doc.doc-code      = buf_fbr-doc.doc-code
      buf_sale-doc.ext-doc-type  = 'производство':U
      buf_sale-doc.doc-kind      = 'производство':U
      buf_sale-doc.obj-type      = buf_fbr-doc.obj-type
      buf_sale-doc.obj-code      = buf_fbr-doc.obj-code
      buf_sale-doc.cli-type      = buf_fbr-doc.obj-type
      buf_sale-doc.cli-code      = buf_fbr-doc.obj-code
      buf_sale-doc.doc-qnty      = v-pri-prvo-doc-qnty
      buf_sale-doc.fact-qnty     = v-pri-prvo-fact-qnty
      buf_sale-doc.tot-lines     = v-pri-prvo-tot-lines
      buf_sale-doc.tot-dtl       = v-pri-prvo-tot-lines
      buf_sale-doc.fbrsale       = yes
      buf_sale-doc.inkas-code    = p-inkas-code
      .
    end.
  end.
end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table tt0-info no-undo
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
define SHARED temp-table tt0-doc-line no-undo like lib-trn_ret-line.
define SHARED temp-table tt0-gds-dtl  no-undo like ub.gds-dtl.
define SHARED temp-table tt0-parts    no-undo like ub.parts.
define SHARED temp-table temp-tpsi-clients  no-undo like ub.clients.
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var cr as integer no-undo.
DEFINE  TEMP-TABLE t-gds No-UNDO
FIELD b-code like ub.chk-gds.b-code
FIELD gds-code like ub.goods.gds-code
FIELD VAT-sum-rubl like ub.chk-gds.VAT-sum-rubl
FIELD pump like ub.chk-gds.pump
FIELD nozzle-code like ub.chk-gds.nozzle-code
FIELD loc1 like ub.chk-gds.loc1
field pl-code like ub.chk-gds.pl-code
field density as decimal
FIELD fbr-obj-type like ub.clients.obj-type
FIELD fbr-obj-code like ub.clients.obj-code
FIELD artic like ub.goods.artic
FIELD prod-type like ub.goods.prod-type
FIELD prod-code like ub.goods.prod-code
FIELD doc-qnty like ub.chk-gds.doc-qnty
FIELD price-base like ub.chk-gds.price-base
FIELD price-sum like ub.chk-gds.price-base
FIELD discnt like ub.chk-gds.discnt
FIELD discnt-sum like ub.chk-gds.discnt
FIELD price-service like ub.chk-gds.price-service
FIELD service-sum like ub.chk-gds.price-service
FIELD road-tax like ub.chk-gds.road-tax
FIELD road-sum like ub.chk-gds.road-tax
FIELD new-price like ub.chk-gds.price-base
FIELD cashparts as logical
FIELD rdoc-line as recid
FIELD rgds-dtl as recid
FIELD unit-base like ub.goods.unit-base
FIELD unit-cli like ub.goods.unit-cli
FIELD node-code like ub.bar-code.node-code
FIELD num-lines as integer
FIELD vat-pc like ub.doc-line.vat-pc
FIELD SLT-pc like ub.doc-line.slt-pc
FIELD crf as integer
FIELD drc as recid
FIELD grc as recid
FIELD prt-root like ub.goods.prt-root
FIELD excise as decimal
FIELD type like ub.units.type
FIELD is-modificator as logical
FIELD is-null-price as logical
FIELD doc-code like ub.trn-doc.doc-code
FIELD marks as character
index pi is PRIMARY doc-code b-code artic prod-type prod-code node-code pump nozzle-code pl-code
index ifbr b-code fbr-obj-type fbr-obj-code
index crfi crf.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure findtank:
  define input  parameter p-obj-type     as character no-undo.
  define input  parameter p-obj-code     as integer   no-undo.
  define input  parameter p-pump-code    as integer   no-undo.
  define input  parameter p-nozzle-code  as integer   no-undo .
  define input  parameter p-from-pl-code as integer   no-undo .
  define input  parameter p-gds-code     as integer   no-undo.
  define output parameter p-pl-code      as integer   no-undo .
  define variable v-pl-code            like ub.place.pl-code no-undo .
  define variable v-dopstr             as character no-undo .
  define buffer buf_place for ub.place.
  define buffer buf_pl-gds-pump for ub.pl-gds-pump.
  define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
  define buffer buf_pl-gds for ub.pl-gds.
  do
  on error undo, return error return-value
  :
    assign
      v-pl-code = 0
      p-pl-code = ?
    .
    if p-from-pl-code <> ?
      and p-from-pl-code <> 0
    then do:
      find first buf_pl-gds no-lock
        where buf_pl-gds.obj-type  = p-obj-type
          and buf_pl-gds.obj-code  = p-obj-code
          and buf_pl-gds.pl-code   = p-from-pl-code
          and buf_pl-gds.gds-code  = p-gds-code
        no-error.
      if available buf_pl-gds then do:
        assign
          v-pl-code = buf_pl-gds.pl-code
        .
      end.
    end.
    if v-pl-code <> 0
      and p-nozzle-code <> ?
      and p-nozzle-code <> 0
    then do:
      find first buf_pl-pump-nozzle no-lock
        where buf_pl-pump-nozzle.obj-type    = p-obj-type
          and buf_pl-pump-nozzle.obj-code    = p-obj-code
          and buf_pl-pump-nozzle.pl-code     = v-pl-code
          and buf_pl-pump-nozzle.pump-code   = p-pump-code
          and buf_pl-pump-nozzle.nozzle-code = p-nozzle-code
        no-error .
      if not available buf_pl-pump-nozzle then do:
        return.
      end.
    end.
    if v-pl-code = 0 then do:
      if p-nozzle-code = 0 then do:
        find first buf_pl-gds-pump no-lock
          where buf_pl-gds-pump.obj-type  = p-obj-type
            and buf_pl-gds-pump.obj-code  = p-obj-code
            and buf_pl-gds-pump.pump-code = p-pump-code
            and buf_pl-gds-pump.gds-code  = p-gds-code
            and buf_pl-gds-pump.status_   = 'тек':U
          no-error.
        if available buf_pl-gds-pump then do:
          assign
            v-pl-code = buf_pl-gds-pump.pl-code
          .
        end.
      end.
      else do:
        _ppnz:
        for each buf_pl-pump-nozzle no-lock
          where buf_pl-pump-nozzle.obj-type = p-obj-type
            and buf_pl-pump-nozzle.obj-code = p-obj-code
            and buf_pl-pump-nozzle.pump-code = p-pump-code
            and buf_pl-pump-nozzle.nozzle-code = p-nozzle-code
          ,first buf_pl-gds-pump no-lock
          where buf_pl-gds-pump.obj-type  = p-obj-type
            and buf_pl-gds-pump.obj-code  = p-obj-code
            and buf_pl-gds-pump.pump-code = p-pump-code
            and buf_pl-gds-pump.gds-code  = p-gds-code
            and buf_pl-gds-pump.status_   = 'тек':U
            and buf_pl-gds-pump.pl-code   = buf_pl-pump-nozzle.pl-code
        on error undo, return error return-value
        :
          assign
            v-pl-code = buf_pl-pump-nozzle.pl-code
          .
          leave _ppnz.
        end.
      end.
    end.
    if v-pl-code <> 0 then do:
      assign
        p-pl-code = v-pl-code
      .
    end.
  end.
end procedure.
procedure find-nzl:
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define input  parameter p-pump-code  as integer   no-undo.
define input  parameter p-gds-code   as integer   no-undo.
define input  parameter p-pl-code    as integer no-undo .
define output parameter p-nozzle-code    as integer   no-undo.
define variable v-nozzle-code        like ub.nozzle.nozzle-code no-undo .
define variable v-pl-code            like ub.place.pl-code no-undo .
define variable v-pump-code          like ub.pump.pump-code no-undo .
define variable v-loc1-code          like ub.place.loc1 no-undo .
define variable v-dopstr             as character no-undo .
define buffer buf_place for ub.place.
define buffer buf_pl-gds-pump for ub.pl-gds-pump.
define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
define buffer buf_pl-gds for ub.pl-gds.
do on error undo, return error return-value :
  v-pump-code = p-pump-code.
  find first buf_pl-pump-nozzle no-lock where
                buf_pl-pump-nozzle.obj-type = p-obj-type
            and buf_pl-pump-nozzle.obj-code = p-obj-code
            and buf_pl-pump-nozzle.pump-code = p-pump-code
            and buf_pl-pump-nozzle.pl-code = p-pl-code no-error.
  if not available buf_pl-pump-nozzle then do:
    assign
    p-nozzle-code = ?.
    return .
  end.
  assign
  p-nozzle-code = buf_pl-pump-nozzle.nozzle-code.
  return.
  .
end.
end procedure.
procedure find-nzl-without-pl:
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define input  parameter p-pump-code  as integer   no-undo.
define input  parameter p-gds-code   as integer   no-undo.
define output parameter p-nozzle-code    as integer   no-undo.
define buffer buf_pl-gds-pump for ub.pl-gds-pump.
define buffer buf_pl-gds for ub.pl-gds.
define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
do on error undo, return error return-value :
  for each buf_pl-gds-pump no-lock where
            buf_pl-gds-pump.obj-type  = p-obj-type
        and buf_pl-gds-pump.obj-code  = p-obj-code
        and buf_pl-gds-pump.pump-code = p-pump-code
        and buf_pl-gds-pump.gds-code  = p-gds-code
        and buf_pl-gds-pump.status_   = 'тек':U,
      first buf_pl-gds no-lock where
                buf_pl-gds.obj-type = p-obj-type
            AND buf_pl-gds.obj-code = p-obj-code
            AND buf_pl-gds.pl-code = buf_pl-gds-pump.pl-code
            AND buf_pl-gds.gds-code = p-gds-code
            AND buf_pl-gds.status_ = 'тек':U,
     first buf_pl-pump-nozzle no-lock where
              buf_pl-pump-nozzle.obj-type = p-obj-type
          and buf_pl-pump-nozzle.obj-code = p-obj-code
          and buf_pl-pump-nozzle.pl-code = buf_pl-gds.pl-code
          and buf_pl-pump-nozzle.pump-code = p-pump-code:
    assign
    p-nozzle-code = buf_pl-pump-nozzle.nozzle-code.
    return .
  end.
  assign
  p-nozzle-code = ?.
  return.
  .
end.
end procedure.
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
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
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
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
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
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
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
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
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
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
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-chk-gds no-undo
field doc-code like ub.chk-doc.doc-code
FIELD b-code like ub.chk-gds.b-code
field discnt as decimal
field line-type  as character
field line-sign as logical
field sum as decimal
field line-num as integer
field num-lines as integer
field doc-qnty as decimal
field sign as integer
field rec-type as integer
field gds-type as integer
field density as decimal
field price-base as decimal
field price-service as decimal
field jjp_ as integer
field jjo_ as integer
field jj_ as integer
field flag as logical
field gds-code as integer
index pi iS unique primary
doc-code
rec-type
b-code
line-num
index ijj
jj_
line-num
index ijjp
doc-code
jjp_
line-num
index ijjo
doc-code
jjo_
line-num
index iflag
doc-code
flag
line-num
.
define temp-table temp-chk-pay no-undo
field doc-code like ub.chk-doc.doc-code
field pay-card as character
field pay-code as integer
field curr-code as integer
field sign as integer
field line-num as integer
field pet-good as integer
field is-cash  like ub.cash-pay.is-cash
field register like ub.cash-pay.register
field num-lines as integer
field tot-r-b as decimal
field tot-rubl as decimal
field tot-base as decimal
field flag as logical
field rrn as character
index pi is primary unique
doc-code
pay-code
curr-code
line-num
index isort
doc-code
pet-good  descending
line-num
index ipcard
doc-code
pay-code
curr-code
pay-card
rrn
index iflag
doc-code
flag
.
define temp-table temp-chk-dp no-undo
field doc-code like ub.chk-doc.doc-code
FIELD b-code like ub.chk-gds.b-code
field line-sign as logical
field sum as decimal
field qnty as decimal
field all-sum as decimal
field line-num as integer
field sign as integer
field pay-code as integer
index pi pay-code line-num
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
define variable p-ii as integer no-undo .
define variable p-ii-ok as integer no-undo .
define variable p-rid-list as character no-undo .
define variable p-call-handle  as handle no-undo .
define variable p-filter-rus as character no-undo .
define variable p-obj-type  like ub.clients.obj-type no-undo .
define variable p-obj-code  like ub.clients.obj-code no-undo .
define variable cursh       like ub.curr-shop.exch-rate init 0.
define variable cursh-scale like ub.curr-shop.exch-rate.
define variable gds-amount  as integer .
define variable chk-amount  as integer .
define variable line-out    as integer .
define variable line-ret    as integer .
define variable dtl-out     as integer .
define variable dtl-ret     as integer .
define variable nf-gds-amount  as integer .
define variable nf-chk-amount  as integer .
define variable old-doc-date   like ub.inkas.doc-date no-undo .
define variable old-shift-date like ub.inkas.shift-date no-undo .
define variable old-shift-num  like ub.inkas.shift-num  no-undo .
define variable new-doc-date   like ub.inkas.doc-date no-undo .
define variable new-shift-date like ub.inkas.shift-date no-undo .
define variable new-shift-num  like ub.inkas.shift-num  no-undo .
define variable v-no-check     as logical no-undo .
define variable v-dop-where-rus as character no-undo .
define variable log-file-name  as character no-undo .
define buffer ink-doc for ub.inkas.
define buffer trn-doc for ub.trn-doc.
define buffer buf_sysconf for ub.sysconf.
define buffer X_chk-doc for ub.chk-doc.
DEFINE QUERY QUERY-chk-doc FOR X_chk-doc SCROLLING.
define variable v-view-log as logical no-undo .
define variable v-esm as character no-undo .
define variable v-input-error as logical no-undo .
define variable v-db-num  like ub.db.db-num no-undo .
define variable v-filter-name as character no-undo .
define variable v-where-phrase as character no-undo .
define variable v-query-prepare as character no-undo .
define variable glog            as logical no-undo .
define variable v-filter-exist as logical no-undo .
do
on error undo, return error
:
if num-entries(p-parameter, chr(4)) <> 15
then do:
  assign
  v-input-error = yes
  v-esm         = substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 15"
                             ,num-entries(p-parameter, chr(4))).
  .
end.
else do:
  assign
  p-auto              = integer(entry(1, p-parameter, chr(4)))
  p-inkas-code        = entry(2, p-parameter, chr(4))
  p-filter-on         = logical(entry(3, p-parameter, chr(4)))
  v-curr-r-b          = entry(4, p-parameter, chr(4))
  is-wth              = logical(entry(5, p-parameter, chr(4)))
  cas-shft            = logical(entry(6, p-parameter, chr(4)))
  one-curs            = logical(entry(7, p-parameter, chr(4)))
  cas-curs            = logical(entry(8, p-parameter, chr(4)))
  prcl-spl            = logical(entry(9, p-parameter, chr(4)))
  pay-gds-algo        = entry(10, p-parameter, chr(4))
  rdtaxcd             = integer(entry(12, p-parameter, chr(4)))
  exctaxcd            = integer(entry(12, p-parameter, chr(4)))
  factorrt            = decimal(entry(13, p-parameter, chr(4)))
  btltaxcd            = integer(entry(14, p-parameter, chr(4)))
  p-day-only          = logical(entry(15, p-parameter, chr(4)))
  no-error
  .
  if error-status:error then do:
    assign
    v-esm = error-status:get-message(1)
    v-input-error = yes
    .
  end.
end.
if p-auto = 0 then do:
  log-file-name = 'saleincl.log' .
end.
else do:
  log-file-name = 'ext-sale.log'.
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile: inc-salr.i $ $Revision: 5b89e89c1f45, 2641, rls $".
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-inc-sal returns integer(input p-chk-type as character
                                   , input p-netto as decimal
                                   , input p-chk-doc as logical
                                   , input p-office as character
                                   , input p-write-off-code  as character
                                   , output p-add as logical
                                   , output p-office-to-reserv as character
                                   , output p-kind-to-reserv as character
                                   , output p-add-nf-amount as integer
                                   ):
define variable v-docs-to-reserv as integer no-undo.
if lookup(p-chk-type , '14,15,16,36,8,101,106,108,11,12,13,40,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0
then do:
    assign
    v-docS-to-reserv = 0
    p-kind-to-reserv = '':U
    p-add-nf-amount = 1
    .
    return v-docs-to-reserv.
end.
p-add = no.
if p-chk-doc then do:
  if p-chk-type = ? then do:
    if p-netto >= 0 then do:
      assign
      p-chk-type = '1':U.
    end.
    if p-netto < 0 then do:
      assign
      p-chk-type = '6':U.
    end.
  end.
  CASE p-chk-type:
    when '1':U then do:
      assign
      p-kind-to-reserv = 'es':U
      v-docs-to-reserv = 1
      .
    end.
    when '6':U then do:
      assign
      p-kind-to-reserv = 'rs':U
      v-docs-to-reserv = 1
      .
    end.
    when '17':U then do:
      assign
      p-kind-to-reserv = 'trf':U
      v-docs-to-reserv = 1
      .
    end.
    when '96':U then do:
      assign
      p-kind-to-reserv = 'rs':U + chr(44) + 'rwo':U
      v-docs-to-reserv = 2
      .
    end.
    when '69':U then do:
      assign
      p-kind-to-reserv = 'swo':U
      v-docs-to-reserv = 1
      .
    end.
    otherwise do:
      assign
      p-kind-to-reserv = '':U
      v-docs-to-reserv = 0
      .
    End.
  END CASE.
  ASSIGN
  p-add-nf-amount = 0.
  if p-office = 'т':U
  or p-office = 'у':U then do:
    p-office-to-reserv = (if v-docs-to-reserv = 0
                          then '':U
                          else trim(fill((p-office + chr(44)), v-docs-to-reserv), chr(44))).
  end.
  else do:
    assign
    p-office-to-reserv  = (if v-docs-to-reserv = 0
                           then '':U
                           else (trim(fill(entry(1, p-office) + chr(44), v-docs-to-reserv), chr(44)) +
                                chr(44) +
                                 trim(fill(entry(2, p-office) + chr(44), v-docs-to-reserv), chr(44))))
    v-docs-to-reserv = v-docs-to-reserv * 2
    p-kind-to-reserv = (if p-kind-to-reserv = '':U
                        then  '':U
                        else (p-kind-to-reserv + chr(44) + p-kind-to-reserv)) .
  end.
  return v-docs-to-reserv.
end.
else do:
  ASSIGN
  P-kind-to-reserv = '':U
  p-add-nf-amount = 0
  p-add = yes
  p-office-to-reserv = '':U
  .
  if p-write-off-code = '0':U
  or p-write-off-code = ? then do:
    return 0.
  end.
  CASE p-chk-type:
    when '1':U
    then do:
       if p-write-off-code = '1':U
       or p-write-off-code = '3':U
       then do:
          assign
          p-kind-to-reserv = 'swo':U
          v-docs-to-reserv = 1
          p-add = no
          p-office-to-reserv = p-office
          .
       end.
    end.
    when '6':U then do:
       if p-write-off-code = '-6':U
       or p-write-off-code = '-3':U
       then do:
          assign
          p-kind-to-reserv = 'rwo':U
          v-docs-to-reserv = 1
          p-add = no
          p-office-to-reserv = p-office
          .
       end.
    end.
  END CASE.
  return v-docs-to-reserv.
end.
END FUNCTION.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  function valid-density returns logical ( input p-density as decimal, input p-unit-base-cli-eq as logical ) :
    define variable v-answ as logical no-undo .
    if ( p-unit-base-cli-eq = true
         and p-density = 1.0
       )
      or ( p-unit-base-cli-eq = false
           and p-density <> ?
           and p-density > 0.0
           and p-density < 1.0
         )
    then do:
      assign
        v-answ = true
      .
    end.
    else do:
      assign
        v-answ = false
      .
    end.
    return v-answ.
  end function.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable pychk_kk as integer no-undo .
define variable pychk_jj as integer no-undo .
define variable pychk_jjp as integer no-undo .
define variable pychk_jjo as integer no-undo .
define variable pychk_pay-sum as decimal no-undo .
DEFINE VARIABLE pychk_No-EXCH as logical no-undo.
DEFINE VARIABLE pychk_No-EXCH-rubl as logical no-undo.
DEFINE VARIABLE pychk_dop-sump as decimal No-UNDO.
DEFINE VARIABLE pychk_dop-sumg as decimal No-UNDO.
DEFINE VARIABLE pychk_dop-sumk as decimal No-UNDO.
DEFINE VARIABLE pychk_exch as decimal No-UNDO.
DEFINE VARIABLE pychk_exch-rubl as decimal No-UNDO.
define variable pychk_rec-type as integer no-undo .
define variable pychk_line-type as integer no-undo .
define variable pychk_create as logical no-undo .
define variable pychk_pays_count as integer no-undo .
define variable pychk_zero-gds as decimal no-undo .
define variable pychk_zero-pay as decimal no-undo .
define variable pychk_zero-n as decimal no-undo .
define variable pychk_value as character no-undo .
define variable pychk_type as character no-undo .
define variable pychk_line-type-chr as character no-undo .
define variable pychk_payline_rrn as character no-undo .
define variable vSum as decimal no-undo.
define variable vSumRound as decimal no-undo.
define variable pychk_sum-promo as decimal no-undo.
define variable vPromoLineNum as integer no-undo.
define temp-table temp-ptrl-goods no-undo
field b-code as integer
field gds-code as integer
field ptrl-good as logical
index pi as unique primary
b-code
.
define buffer buf_temp-chk-gds for temp-chk-gds.
define buffer buf_temp-chk-gds2 for temp-chk-gds.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf2_chk-doc for ub.chk-doc.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_chk-pay-attr for ub.chk-pay-attr .
function ChkGdsPromo returns logical
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromo as logical no-undo.
    vPromo = no.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and buf_chk-gds-attr.attr-value <> "0":
       vPromo = yes.
       leave cspr.
    end.
    return vPromo.
end.
function ChkPromoLine returns logical
    (input iDocCode as character,
    input iLineNum as integer)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromo as logical no-undo.
    vPromo = no.
    find first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = iDocCode
             and buf_chk-gds-attr.line-num  = iLineNum
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and buf_chk-gds-attr.attr-value <> "0"
    no-error.
    if avail buf_chk-gds-attr then vPromo = yes.
    return vPromo.
end.
function ChkPromoSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vSumPromo as decimal no-undo.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromoSum"
      no-error.
   if avail buf_chk-gds-attr then
      vSumPromo = DEC(buf_chk-gds-attr.attr-value) no-error.
   return vSumPromo.
end function.
function ChkPromoPrice returns logical
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable v-is-promo as logical no-undo.
   v-is-promo = no.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr
     and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
   then v-is-promo = yes.
   return v-is-promo.
end function.
function ChkDopLitr returns logical
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable v-is-promo as logical no-undo.
   v-is-promo = no.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr and
     buf_chk-gds-attr.attr-value = "3"
   then v-is-promo = yes.
   return v-is-promo.
end function.
function RoundUp return decimal
    (input iQnty as decimal,
     input iPrice as decimal):
    def var vSum  as decimal no-undo.
    def var vSumR as decimal no-undo.
    vSum = ABSOLUTE(iQnty) * iPrice.
    vSumR = Round(vSum,2).
    if vSumR < vSum then vSumR = vSumR + 0.01.
    if iQnty < 0 then vSumR = - vSumR.
    return vSumR.
end function.
function GetPromoSum returns decimal
    (input iDocCode as character)
    :
    define buffer buf_chk-doc for ub.chk-doc.
    define buffer buf2_chk-doc for ub.chk-doc.
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define buffer buf2_chk-gds for ub.chk-gds.
    define buffer buf2_chk-gds-attr for ub.chk-gds-attr.
    define variable v-price-base as decimal no-undo.
    define variable v-doc-qnty as decimal no-undo.
    define variable v-sum-base as decimal no-undo.
    define variable v-sum-all as decimal no-undo.
    define variable v-sum-promo as decimal no-undo.
    define variable v-sum-chk as decimal no-undo.
    assign
       v-price-base = 0
       v-doc-qnty = 0
       v-sum-all = 0
       v-sum-chk = 0
       v-sum-promo = 0
       .
    for each buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iDocCode,
       first buf_chk-gds-attr no-lock where
             buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
         and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
         and buf_chk-gds-attr.attr-code = "CSPromoSum"
       :
       v-sum-promo = Dec(buf_chk-gds-attr.attr-value).
    end.
    if v-sum-promo = 0 then do:
        for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("1,6", buf_chk-gds-attr.attr-value)
           :
           assign
             v-price-base = buf_chk-gds.price-base
             v-doc-qnty   = if buf_chk-gds.doc-qnty = ? then buf_chk-gds.src-qnty else buf_chk-gds.doc-qnty
             v-sum-base = if buf_chk-gds.sum-base = ? then round(v-doc-qnty * v-price-base, 2) else buf_chk-gds.sum-base
             .
        end.
        for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
           :
           if v-price-base = 0 then do:
              find first buf_chk-doc no-lock where
                         buf_chk-doc.doc-code = iDocCode
                  no-error.
              if avail buf_chk-doc and
                 buf_chk-doc.chk-type = int('6':U) and
                 buf_chk-doc.doc-num2 > ""  and
                 num-entries(buf_chk-doc.doc-num2,":") = 2
              then
              for first buf2_chk-doc no-lock where
                        buf2_chk-doc.obj-code = buf_chk-doc.obj-code
                    and buf2_chk-doc.obj-type = buf_chk-doc.obj-type
                    and buf2_chk-doc.chk-type = int('1':U)
                    and buf2_chk-doc.chk-num = int(entry(1,buf_chk-doc.doc-num2,":"))
                    and buf2_chk-doc.z-number = int(entry(2, buf_chk-doc.doc-num2,":"))
                    :
                for each buf2_chk-gds no-lock where
                         buf2_chk-gds.doc-code = buf2_chk-doc.doc-code,
                   first buf2_chk-gds-attr no-lock where
                         buf2_chk-gds-attr.doc-code = buf2_chk-gds.doc-code
                     and buf2_chk-gds-attr.line-num  = buf2_chk-gds.line-num
                     and buf2_chk-gds-attr.attr-code = "CSPromo"
                     and can-do("1,6", buf2_chk-gds-attr.attr-value)
                   :
                    v-price-base = buf2_chk-gds.price-base.
                end.
              end.
           end.
           if buf_chk-gds.sum-base = ? or buf_chk-gds.src-qnty = 0 then do:
               assign
                  v-sum-all = (buf_chk-gds.src-qnty + v-doc-qnty) * v-price-base
                  v-sum-chk = v-sum-base + RoundUp(buf_chk-gds.src-qnty, buf_chk-gds.src-price)
                  .
           end.
           else do:
              assign
              v-sum-all = (buf_chk-gds.doc-qnty + v-doc-qnty ) * v-price-base
              v-sum-chk = v-sum-base + buf_chk-gds.sum-base
              .
           end.
        end.
        v-sum-promo = Round(v-sum-all, 2) - Round(v-sum-chk, 2).
    end.
    return v-sum-promo.
end function.
function GetUnBaseSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vBaseSum as decimal no-undo.
   define variable vDiscSum as decimal no-undo.
   vDiscSum = 0.
   find first buf_chk-gds-attr no-lock where
                     buf_chk-gds-attr.doc-code = iDocCode
                 and buf_chk-gds-attr.line-num  = iLineNum
                 and buf_chk-gds-attr.attr-code = "CSPromoSum"
          no-error.
   if avail buf_chk-gds-attr then
      vDiscSum = dec(buf_chk-gds-attr.attr-value) no-error.
   vBaseSum = iQnty * iPrice + vDiscSum.
   if vDiscSum = 0 and ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   return vBaseSum.
end function.
function GetRoundSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vBaseSum as decimal no-undo.
   if ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   else vBaseSum = iQnty * iPrice.
   return vBaseSum.
end function.
function GetRoundSumChkDel returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iChipNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer  buf_c-chk-doc-attr for ub.c-chk-doc-attr.
   define variable vBaseSum as decimal no-undo.
   define variable vIsPromo as logical no-undo.
   for each buf_c-chk-doc-attr no-lock where
            buf_c-chk-doc-attr.doc-code = iDocCode
        and buf_c-chk-doc-attr.chip-num = iChipNum
       :
       if num-entries(buf_c-chk-doc-attr.attr-code, chr(4)) > 1
       then do :
         if entry(1, buf_c-chk-doc-attr.attr-code, chr(4)) begins "gds="
         and entry(2, buf_c-chk-doc-attr.attr-code, chr(4)) = "CSPromo"
         and entry(2, entry(1, buf_c-chk-doc-attr.attr-code, chr(4)), "=") = String(iLineNum)
         and can-do("2,4,5,7", buf_c-chk-doc-attr.attr-value)
         then vIsPromo = yes.
       end.
   end.
   if ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   else vBaseSum = iQnty * iPrice.
   return vBaseSum.
end function.
function GetSaleRetDisc returns decimal
    (input iDocCode as character,
     input iSaleCode as character):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf_chk-gds for ub.chk-gds.
   define variable vQntyPromoRet as decimal no-undo.
   define variable vQntyPromoSel as decimal no-undo.
   define variable vDiscSumRet   as decimal no-undo.
   define variable vDiscSumSale  as decimal no-undo.
   vDiscSumRet = 0.
   cspr:
   for each  buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iDocCode,
       first buf_chk-gds-attr no-lock where
             buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
         and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
         and buf_chk-gds-attr.attr-code = "CSPromo"
         and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
       :
       vQntyPromoRet = buf_chk-gds.src-qnty.
       leave cspr.
   end.
   if vQntyPromoRet <> 0 then
   for each  buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iSaleCode:
       find first buf_chk-gds-attr no-lock where
                  buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
              and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
              and buf_chk-gds-attr.attr-code = "CSPromo"
       no-error.
       if avail buf_chk-gds-attr
            and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
       then
         vQntyPromoSel = buf_chk-gds.src-qnty.
       find first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromoSum"
       no-error.
       if avail buf_chk-gds-attr then
          vDiscSumSale = dec(buf_chk-gds-attr.attr-value) no-error.
   end.
   if vQntyPromoRet <> 0 and
      vQntyPromoSel = -1 * vQntyPromoRet
   then vDiscSumRet = -1 * vDiscSumSale.
   return vDiscSumRet.
end function.
function SetPromoDisc return logical
 (input iDocCode as character,
     input iLineNum as integer
     )
    :
   define buffer buf_chk-doc for ub.chk-doc.
   define buffer buf2_chk-doc for ub.chk-doc.
   define buffer buf_chk-gds for ub.chk-gds.
   define buffer buf2_chk-gds for ub.chk-gds.
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf2_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf_chk-discnt for ub.chk-discnt.
   define buffer buf2_chk-discnt for ub.chk-discnt.
   define buffer buf_chk-discnt-attr for ub.chk-discnt-attr.
   define buffer buf2_chk-discnt-attr for ub.chk-discnt-attr.
   define variable v-promo-sum as decimal no-undo.
   define variable v-disc-promo-id as character no-undo.
   define variable var-discnt-id as integer no-undo.
   define variable v-chk-sale as character no-undo.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr
     then do:
     find first buf_chk-discnt no-lock where
                buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
            and buf_chk-discnt.line-num = buf_chk-gds-attr.line-num
            and buf_chk-discnt.record-type = 0
            and buf_chk-discnt.promo-id > ""
            no-error.
     if not avail buf_chk-discnt then do:
        find first buf_chk-doc no-lock where
                   buf_chk-doc.doc-code = iDocCode
           no-error.
        find first buf_chk-gds no-lock where
                   buf_chk-gds.doc-code = iDocCode
              and  buf_chk-gds.line-num = iLineNum
           no-error.
       for first buf2_chk-doc no-lock where
                 buf2_chk-doc.obj-code = buf_chk-doc.obj-code
             and buf2_chk-doc.obj-type = buf_chk-doc.obj-type
             and buf2_chk-doc.pay-desk = buf_chk-doc.pay-desk
             and buf2_chk-doc.chk-type = int('1':U)
             and buf2_chk-doc.chk-num  = int(entry(1,buf_chk-doc.doc-num2,":"))
             and buf2_chk-doc.z-number = int(entry(2, buf_chk-doc.doc-num2,":"))
           :
           find first buf2_chk-gds no-lock where
                      buf2_chk-gds.doc-code = buf2_chk-doc.doc-code
                 and  buf2_chk-gds.b-code   = buf_chk-gds.b-code
           no-error.
           if not avail buf2_chk-gds then return no.
           v-chk-sale = buf2_chk-doc.doc-code.
           find first buf_chk-discnt no-lock where
                      buf_chk-discnt.doc-code =  buf2_chk-doc.doc-code and
                      buf_chk-discnt.record-type = 1 and
                      buf_chk-discnt.object-line-num = buf2_chk-gds.line-num and
                      buf_chk-discnt.promo-id > ""
           no-error .
           if avail buf_chk-discnt
           then do:
              v-disc-promo-id = buf_chk-discnt.promo-id.
              find first buf2_chk-discnt no-lock where
                buf2_chk-discnt.doc-code = iDocCode and
                buf2_chk-discnt.record-type = 5 and
                buf2_chk-discnt.line-num = 0 and
                buf2_chk-discnt.promo-id =  v-disc-promo-id
              no-error.
              find first buf2_chk-discnt-attr no-lock where
                         buf2_chk-discnt-attr.doc-code = iDocCode and
                         buf2_chk-discnt-attr.record-type = 5 and
                         buf2_chk-discnt-attr.line-num = 0 and
                         buf2_chk-discnt-attr.attr-code = "promo-id" and
                         buf2_chk-discnt-attr.attr-value = v-disc-promo-id
                    no-error .
              if not avail buf2_chk-discnt
              then do:
                  for each buf_chk-discnt no-lock where
                           buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
                       and buf_chk-discnt.record-type = 5:
                       var-discnt-id  = var-discnt-id + 1.
                  end.
                  create buf2_chk-discnt.
                  assign
                    buf2_chk-discnt.doc-code = iDocCode
                    buf2_chk-discnt.record-type = 5
                    buf2_chk-discnt.line-num = 0
                    buf2_chk-discnt.promo-id = v-disc-promo-id
                    buf2_chk-discnt.object-sum = 0
                    buf2_chk-discnt.discnt-id = if avail buf2_chk-discnt-attr
                                                   then buf2_chk-discnt-attr.discnt-id
                                                   else (var-discnt-id + 1)
                    var-discnt-id = 0
                    buf2_chk-discnt.object-line-num = 0
                    buf2_chk-discnt.pay-desk = buf_chk-doc.pay-desk
                    buf2_chk-discnt.obj-code = buf_chk-doc.obj-code
                    buf2_chk-discnt.obj-type = buf_chk-doc.obj-type
                    buf2_chk-discnt.chk-date = buf_chk-doc.chk-date
                    buf2_chk-discnt.shift-date = buf_chk-doc.shift-date
                    buf2_chk-discnt.shift-num = buf_chk-doc.shift-num
                    buf2_chk-discnt.chk-time = buf_chk-doc.chk-time
                    .
              end.
              if avail buf2_chk-discnt and
                 not avail buf2_chk-discnt-attr
              then do:
                 create buf2_chk-discnt-attr.
                 assign
                    buf2_chk-discnt-attr.doc-code = iDocCode
                    buf2_chk-discnt-attr.discnt-id = buf2_chk-discnt.discnt-id
                    buf2_chk-discnt-attr.record-type     = 5
                    buf2_chk-discnt-attr.line-num        = 0
                    buf2_chk-discnt-attr.object-line-num = 0
                    buf2_chk-discnt-attr.attr-code       = "promo-id"
                    buf2_chk-discnt-attr.attr-value      = v-disc-promo-id
                    .
              end.
           end.
       end.
        v-promo-sum = 0.
        if can-do("1,6,7", buf_chk-gds-attr.attr-value)
        then do:
           if v-chk-sale <> ? and v-chk-sale <> "" then
              v-promo-sum = GetSaleRetDisc(iDocCode,v-chk-sale).
           v-promo-sum = if v-promo-sum = 0 then GetPromoSum(iDocCode) else v-promo-sum.
           if v-promo-sum <> 0 then do:
               find first buf2_chk-gds-attr no-lock where
                          buf2_chk-gds-attr.doc-code = iDocCode
                      and buf2_chk-gds-attr.line-num  = iLineNum
                      and buf2_chk-gds-attr.attr-code = "CSPromoSum"
                  no-error.
               if not avail buf2_chk-gds-attr then do:
                   create buf2_chk-gds-attr.
                   assign
                      buf2_chk-gds-attr.doc-code = iDocCode
                      buf2_chk-gds-attr.line-num  = iLineNum
                      buf2_chk-gds-attr.attr-code = "CSPromoSum"
                      buf2_chk-gds-attr.attr-value = string(Round(v-promo-sum,2))
                      .
               end.
           end.
        end.
        for each buf_chk-discnt no-lock where
                buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
            and buf_chk-discnt.record-type = 0:
           var-discnt-id  = var-discnt-id + 1.
        end.
        create buf_chk-discnt.
        assign
            buf_chk-discnt.doc-code = iDocCode
            buf_chk-discnt.line-num = iLineNum
            buf_chk-discnt.record-type = 0
            buf_chk-discnt.discnt-id = (var-discnt-id + 1)
            buf_chk-discnt.time-oper = buf_chk-gds.time-oper
            buf_chk-discnt.line-type = integer('1':U)
            buf_chk-discnt.line-sign = no
            buf_chk-discnt.pass-discnt = integer('0':U)
            buf_chk-discnt.value-type = integer('2':U)
            buf_chk-discnt.src-d-card = buf_chk-gds.src-d-card
            buf_chk-discnt.d-card = buf_chk-gds.d-card
            buf_chk-discnt.discnt-value-abs = 0
            buf_chk-discnt.discnt-value-pcnt = 0
            buf_chk-discnt.object-line-num = iLineNum
            buf_chk-discnt.pay-desk = buf_chk-doc.pay-desk
            buf_chk-discnt.obj-code = buf_chk-doc.obj-code
            buf_chk-discnt.obj-type = buf_chk-doc.obj-type
            buf_chk-discnt.chk-date = buf_chk-doc.chk-date
            buf_chk-discnt.chk-time = buf_chk-doc.chk-time
            buf_chk-discnt.shift-date = buf_chk-doc.shift-date
            buf_chk-discnt.shift-num = buf_chk-doc.shift-num
            buf_chk-discnt.object-qnty = buf_chk-gds.src-qnty
            buf_chk-discnt.object-sum = buf_chk-gds.src-sum
            var-discnt-id = var-discnt-id + 1
            buf_chk-discnt.promo-id = v-disc-promo-id
            buf_chk-discnt.discnt-type = integer('7':U)
            .
        find first buf_chk-discnt-attr no-lock where
                   buf_chk-discnt-attr.attr-code = "promo-id"
               and buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
               and buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
               and buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
               no-error.
        if not avail buf_chk-discnt-attr then
        do:
            create buf_chk-discnt-attr .
            assign
                buf_chk-discnt-attr.attr-code = "promo-id"
                buf_chk-discnt-attr.attr-value = buf_chk-discnt.promo-id
                buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
                buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
                buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
                buf_chk-discnt-attr.object-line-num = buf_chk-discnt.object-line-num
                buf_chk-discnt-attr.record-type = buf_chk-discnt.record-type
                .
         end.
     end.
   end.
   return yes.
end function.
function GetPromoPriceSum returns decimal
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromoSum as decimal no-undo.
    vPromoSum = 0.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value):
       vPromoSum = RoundUp(buf_chk-gds.src-qnty, buf_chk-gds.src-price).
       leave cspr.
    end.
    return vPromoSum.
end.
function GetPromoPriceLine returns integer
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromoLine as integer no-undo.
    vPromoLine = 0.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value):
       vPromoLine = buf_chk-gds-attr.line-num.
       leave cspr.
    end.
    return vPromoLine.
end.
procedure r-pychk0:
define input parameter v-base-code as integer no-undo .
define input parameter p-doc-code as character no-undo .
_chk-doc:
for first ub.chk-doc no-lock where
          ub.chk-doc.doc-code = p-doc-code,
    each ub.chk-pay NO-LOCK WHERE
        ub.chk-pay.doc-code = ub.chk-doc.doc-code
BREAK
BY CHK-pay.DOC-CODE
BY CHK-pay.LINE-NUM:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first-of(ub.CHK-pay.DOC-CODE) THEN Do:
  pychk_create = not can-find (first buf_chk-gds-pay
                               where buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code
                                 and buf_chk-gds-pay.algo-num = "1.8") .
  if pychk_create then do:
    for each temp-chk-pay:
      delete temp-chk-pay.
    end.
    for each temp-chk-gds:
      delete temp-chk-gds.
    end.
    for each temp-chk-dp:
      delete temp-chk-dp.
    end.
    assign
    pychk_kk = 0
    pychk_jj = 1
    pychk_jjp = 0
    pychk_jjo = 0
    pychk_pay-sum = ub.chk-doc.netto
    pychk_dop-sumg = 0
    pychk_pays_count = 0
    .
  end .
end.
if pychk_create   then do:
create-block:
do transaction
on stop   undo create-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo create-block, return error substitute( "&1. endkey", vss-workfile )
on error  undo, throw:
  find first buf2_chk-doc exclusive-lock where
         recid(buf2_chk-doc) = recid(ub.chk-doc).
  if first-of(ub.CHK-pay.DOC-CODE) THEN Do:
    FOR EACH ub.chk-gds No-LOCK WHERE
            ub.chk-gds.doc-code = ub.chk-pay.doc-code
    BY ub.chk-gds.line-num:
      if   ub.chk-gds.write-off-code > 0
        or ub.chk-gds.doc-qnty  eq 0
        or ub.chk-gds.doc-qnty  eq ?
      then NEXT.
      find first buf_bar-code no-lock where
                buf_bar-code.b-code = ub.chk-gds.b-code no-error.
      if not available buf_bar-code then do:
        undo create-block, return error substitute("Не найден товар для бар-кода &1: чек &2 &3&4 строка &5"
                                                    , ub.chk-gds.b-code
                                                    , ub.chk-gds.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , ub.chk-gds.line-num).
      end.
      if ub.chk-gds.pump <> 0 then do:
        pychk_rec-type = 1.
        find first temp-ptrl-goods where
                   temp-ptrl-goods.b-code = ub.chk-gds.b-code no-error.
        if not available temp-ptrl-goods then do:
          run gds-attr-value in this-procedure (
                                                 input buf_bar-code.gds-code
                                                ,input 'ptrl-as-good':U
                                                ,output pychk_value
                                                ,output pychk_type) no-error.
          create temp-ptrl-goods.
          assign
          temp-ptrl-goods.gds-code = buf_bar-code.gds-code
          temp-ptrl-goods.b-code = buf_bar-code.b-code
          temp-ptrl-goods.ptrl-good = (not logical(pychk_value))
          no-error.
        end.
        pychk_line-type = if temp-ptrl-goods.ptrl-good then 1 else 0 .
        release temp-ptrl-goods.
      end.
      else do:
        assign
        pychk_rec-type = 0
        pychk_line-type = 0
        .
      end.
      find first temp-chk-gds where
                temp-chk-gds.doc-code = ub.chk-gds.doc-code
            AND temp-chk-gds.rec-type = pychk_rec-type
            and temp-chk-gds.b-code = ub.chk-gds.b-code
            and temp-chk-gds.line-num = 0
            no-error.
      if not available temp-chk-gds then do:
        find first temp-chk-gds use-index ijj where
                temp-chk-gds.jj_ = pychk_jj
            and temp-chk-gds.line-num = 0
                no-error.
        if not available temp-chk-gds then do:
          create temp-chk-gds.
          assign
          temp-chk-gds.jj_ = pychk_jj
          temp-chk-gds.b-code = ub.chk-gds.b-code
          temp-chk-gds.doc-code = ub.chk-gds.doc-code
          temp-chk-gds.line-num = 0
          temp-chk-gds.rec-type = pychk_rec-type
          temp-chk-gds.gds-code = buf_bar-code.gds-code.
          .
        end.
        else do:
          assign
          temp-chk-gds.b-code = ub.chk-gds.b-code
          temp-chk-gds.doc-code = ub.chk-gds.doc-code
          temp-chk-gds.line-num = 0
          temp-chk-gds.rec-type = pychk_rec-type
          temp-chk-gds.sum = 0
          temp-chk-gds.jjp_ = 0
          temp-chk-gds.jjo_ = 0
          temp-chk-gds.line-type = '':U
          temp-chk-gds.num-lines = 0
          temp-chk-gds.doc-qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.flag  = no
          .
        end.
        assign
        temp-chk-gds.line-type = (if pychk_line-type = 1
                                then 'топ':U
                                else entry(1, ub.chk-gds.line-type, chr(4))
                                ) + chr(4) +
                                (if num-entries(ub.chk-gds.line-type, chr(4)) > 1
                                then entry(2, ub.chk-gds.line-type, chr(4))
                                else '')
        temp-chk-gds.line-num = 0
        temp-chk-gds.num-lines = 0
        temp-chk-gds.density   = ub.chk-gds.density
        pychk_jj = pychk_jj + 1
        .
        if pychk_rec-type = 1 then do:
          assign
          temp-chk-gds.jjp_ = pychk_jjp + 1
          pychk_jjp = pychk_jjp + 1
          .
        end.
        else do:
          assign
          temp-chk-gds.jjo_ = pychk_jjo + 1
          pychk_jjo = pychk_jjo + 1
          .
        end.
      end.
      vSumRound = ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt).
      if ChkPromoPrice(ub.chk-gds.doc-code, ub.chk-gds.line-num) then vSumRound = ub.chk-gds.src-sum.
      assign
      temp-chk-gds.doc-qnty = temp-chk-gds.doc-qnty + ub.chk-gds.doc-qnty
      temp-chk-gds.sum = temp-chk-gds.sum + vSumRound
      temp-chk-gds.num-lines = temp-chk-gds.num-lines  + 1
      .
      find first temp-chk-gds use-index ijj where
              temp-chk-gds.jj_ = 0
          and temp-chk-gds.line-num = ub.chk-gds.line-num
              no-error.
      if not available temp-chk-gds then do:
        create temp-chk-gds.
        assign
        temp-chk-gds.jj_ = 0
        temp-chk-gds.line-num = ub.chk-gds.line-num
        temp-chk-gds.doc-code = ub.chk-gds.doc-code
        temp-chk-gds.b-code = ub.chk-gds.b-code
        temp-chk-gds.gds-code = buf_bar-code.gds-code
        temp-chk-gds.rec-type = pychk_rec-type
        temp-chk-gds.line-num = ub.chk-gds.line-num
        .
      end.
      else do:
        assign
        temp-chk-gds.doc-qnty = 0
        temp-chk-gds.doc-code = ub.chk-gds.doc-code
        temp-chk-gds.b-code = ub.chk-gds.b-code
        temp-chk-gds.gds-code = buf_bar-code.gds-code
        temp-chk-gds.rec-type = pychk_rec-type
        temp-chk-gds.line-num = ub.chk-gds.line-num
        temp-chk-gds.jjp_ = 0
        temp-chk-gds.jjo_ = 0
        temp-chk-gds.line-type = '':U
                .
      end.
      assign
      temp-chk-gds.doc-code = ub.chk-gds.doc-code
      temp-chk-gds.b-code = ub.chk-gds.b-code
      temp-chk-gds.doc-qnty = ub.chk-gds.doc-qnty
      temp-chk-gds.price-base = ub.chk-gds.price-base
      temp-chk-gds.price-service = ub.chk-gds.price-service
      temp-chk-gds.line-type = (if pychk_line-type = 1
                              then 'топ':U
                              else entry(1, ub.chk-gds.line-type, chr(4))
                              ) + chr(4) +
                              (if num-entries(ub.chk-gds.line-type, chr(4)) > 1
                              then entry(2, ub.chk-gds.line-type, chr(4))
                              else '')
      temp-chk-gds.line-sign = ub.chk-gds.line-sign
      temp-chk-gds.discnt = ub.chk-gds.discnt
      temp-chk-gds.sum = vSumRound
      temp-chk-gds.rec-type = pychk_rec-type
      temp-chk-gds.line-num = ub.chk-gds.line-num
      temp-chk-gds.num-lines = 1
      temp-chk-gds.density   = ub.chk-gds.density
      .
    END.
    for each chk-discnt no-lock
       where chk-discnt.doc-code = ub.chk-doc.doc-code
         and record-type = 10
         and chk-discnt.discnt-value-abs <> 0,
        first ub.chk-gds of ub.chk-doc where ub.chk-gds.line-num =  chk-discnt.object-line-num :
            if ub.chk-doc.chk-type = 1 and chk-discnt.object-qnty < 0 then do:
                for first temp-chk-dp where temp-chk-dp.doc-code = ub.chk-doc.doc-code
                and temp-chk-dp.b-code = chk-gds.b-code:
                    temp-chk-dp.sum = temp-chk-dp.sum - abs(chk-discnt.discnt-value-abs * chk-discnt.object-qnty).
                end.
            end.
            else do:
                create temp-chk-dp .
                assign
                temp-chk-dp.doc-code = ub.chk-doc.doc-code
                temp-chk-dp.sum = abs(chk-discnt.discnt-value-abs) * chk-discnt.object-qnty
                temp-chk-dp.line-num = chk-discnt.object-line-num
                temp-chk-dp.pay-code = chk-discnt.rank
                temp-chk-dp.b-code = chk-gds.b-code
                temp-chk-dp.qnty   = abs(chk-discnt.discnt-value-pcnt)
                temp-chk-dp.all-sum =  chk-discnt.discnt-value-abs * chk-discnt.discnt-value-pcnt
                .
            end.
    end.
  end.
  FIND FIRST ub.cash-pay No-LOCK WHERE
            ub.cash-pay.cdpay-code = ub.chk-pay.pay-code AND
            ub.cash-pay.curr-code = ub.chk-pay.curr-code No-ERROR.
  if available ub.cash-pay then do:
    pychk_payline_rrn = "" .
    if not ub.cash-pay.is-cash then do :
      for first buf_chk-pay-attr no-lock
          where buf_chk-pay-attr.doc-code  = ub.CHK-pay.DOC-CODE
            and buf_chk-pay-attr.attr-code = "cpdoc":U
            and buf_chk-pay-attr.line-num  = ub.CHK-pay.line-num :
        pychk_payline_rrn = buf_chk-pay-attr.attr-value .
      end .
    end .
      find first temp-chk-pay where
              temp-chk-pay.doc-code = ub.chk-pay.doc-code
          and temp-chk-pay.pay-code = ub.chk-pay.pay-code
          and temp-chk-pay.pay-card = ub.chk-pay.pay-card
          and temp-chk-pay.curr-code = ub.chk-pay.curr-code
          and temp-chk-pay.rrn       = pychk_payline_rrn
                 no-error.
    if not available temp-chk-pay then do:
        find first temp-chk-pay where
                temp-chk-pay.doc-code = ub.chk-pay.doc-code
            and temp-chk-pay.pay-code = ub.chk-pay.pay-code
            and temp-chk-pay.pay-card = ub.chk-pay.pay-card
            and temp-chk-pay.curr-code = ub.chk-pay.curr-code
            and abs(temp-chk-pay.tot-r-b) >= abs(ub.chk-pay.tot-sum)
            and (temp-chk-pay.tot-r-b >=0) NE (ub.chk-pay.tot-sum >=0)
            no-error.
      if not  avail temp-chk-pay then do:
        find first temp-chk-pay where
                  temp-chk-pay.doc-code = ub.chk-pay.doc-code
              and temp-chk-pay.line-num = ub.chk-pay.line-num use-index pi no-error.
        if not available temp-chk-pay then do:
          create temp-chk-pay.
          assign
          temp-chk-pay.line-num = ub.chk-pay.line-num
          temp-chk-pay.doc-code = ub.chk-doc.doc-code
          temp-chk-pay.pay-code = ub.chk-pay.pay-code
          temp-chk-pay.curr-code =  ub.chk-pay.curr-code
          temp-chk-pay.rrn       = pychk_payline_rrn
          pychk_pays_count = pychk_pays_count + 1
          .
        end.
        assign
        temp-chk-pay.doc-code = ub.chk-doc.doc-code
        temp-chk-pay.pet-good = integer(cash-pay.atr64) * 2 + integer(cash-pay.is-cash) + 2 * int(can-find(first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code ))
        temp-chk-pay.pay-code = ub.chk-pay.pay-code
        temp-chk-pay.curr-code =  ub.chk-pay.curr-code
        temp-chk-pay.is-cash  = ub.cash-pay.is-cash
        temp-chk-pay.register = ub.cash-pay.register
        temp-chk-pay.pay-card = ub.chk-pay.pay-card
        temp-chk-pay.tot-rubl = 0
        temp-chk-pay.tot-base = 0
        temp-chk-pay.num-lines = 0
        temp-chk-pay.flag  = no
        .
      end.
    end.
    assign
    temp-chk-pay.tot-r-b = temp-chk-pay.tot-r-b + (if v-curr-r-b = 'rubl':U
                                                   then ub.chk-pay.tot-rubl
                                                   else ub.chk-pay.tot-base)
    temp-chk-pay.tot-rubl = temp-chk-pay.tot-rubl + ub.chk-pay.tot-rubl
    temp-chk-pay.tot-base = temp-chk-pay.tot-base + ub.chk-pay.tot-base
    temp-chk-pay.num-lines = temp-chk-pay.num-lines  + 1
    .
  end.
  if available temp-chk-pay then RELEASE TEMP-CHK-PAY.
  if last-of(ub.chk-pay.doc-code) then do:
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-doc.doc-code:
       if    (temp-chk-pay.tot-r-b  >= 0) NE (ub.chk-doc.netto >= 0)
          and temp-chk-pay.tot-r-b <> 0
          and abs(ub.chk-doc.netto) > 0.00000001
       then do:
          if not g#auto then do:
             message
                substitute("Не могу обработать чек &1&2&3&4 смена &5 пор.&6 касса &7 № на кассе &8"
                          ,ub.chk-doc.doc-code
                          ,chr(10)
                          ,ub.chk-doc.obj-type
                          ,ub.chk-doc.obj-code
                          ,ub.chk-doc.shift-date
                          ,ub.chk-doc.shift-num
                          ,ub.chk-doc.pay-desk
                          ,ub.chk-doc.chk-num)
                view-as alert-box error .
          end.
          next _chk-doc.
       end.
    end.
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-doc.doc-code
    break
    by temp-chk-pay.pet-good descending
    by temp-chk-pay.line-num:
       dp:
       for each temp-chk-dp no-lock
          where temp-chk-dp.pay-code = temp-chk-pay.pay-code
            and temp-chk-dp.doc-code = temp-chk-pay.doc-code
            and temp-chk-dp.sum <> 0 :
            find first buf_temp-chk-gds2 where
                buf_temp-chk-gds2.doc-code = ub.chk-doc.doc-code
            and buf_temp-chk-gds2.line-num  =  temp-chk-dp.line-num no-error.
            if available buf_temp-chk-gds2 then
            for each buf_temp-chk-gds where
                buf_temp-chk-gds.b-code = buf_temp-chk-gds2.b-code
                and buf_temp-chk-gds.line-num ne 0
            no-lock by buf_temp-chk-gds.line-num  ne  temp-chk-dp.line-num :
                 if         temp-chk-dp.all-sum  eq ?
                    or abs(temp-chk-dp.all-sum) <= 0.001
                then
                   next dp.
                find first  temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                    and buf_temp-chk-gds.b-code = temp-chk-gds.b-code
                  and temp-chk-gds.line-num = 0
                no-error .
                if not available temp-chk-gds then next dp.
                case num-entries(buf_temp-chk-gds.line-type, chr(4)):
                    when 1 then do:
                      pychk_line-type-chr = temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
                    end.
                    when 2 then do:
                      pychk_line-type-chr = temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
                    end.
                end case.
                pychk_dop-sumk =  if temp-chk-dp.sum >= 0
                then min(temp-chk-dp.all-sum,temp-chk-dp.sum,buf_temp-chk-gds.sum,temp-chk-pay.tot-r-b)
                else max(temp-chk-dp.all-sum,temp-chk-dp.sum,buf_temp-chk-gds.sum).
                if abs(temp-chk-pay.tot-r-b - pychk_dop-sumk) <= 0.001
                then
                   pychk_dop-sumk = temp-chk-pay.tot-r-b.
                temp-chk-dp.all-sum           = temp-chk-dp.all-sum - pychk_dop-sumk.
                if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                create buf_chk-gds-pay.
                  assign
                  buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                  buf_chk-gds-pay.chk-type = ub.chk-doc.chk-type
                  buf_chk-gds-pay.algo-num = "1.8"
                  buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
                  buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
                  buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                  buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                  buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
                  buf_chk-gds-pay.tot-r-b =  pychk_dop-sumk
                  buf_chk-gds-pay.eff-base-rate = 1
                  buf_chk-gds-pay.eff-doc-qnty = (if (temp-chk-gds.num-lines = 1
                                                  and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                                  and pychk_pays_count = 1)
                                                  or (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt) = 0
                                                  then temp-chk-gds.doc-qnty
                                                  else (buf_chk-gds-pay.tot-r-b / (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt))
                                                  )
                  buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
                  buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
                  buf_chk-gds-pay.price-base = buf_temp-chk-gds.price-base
                  buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
                  buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
                  buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
                  buf_chk-gds-pay.line-type = pychk_line-type-chr
                  buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
                  buf_chk-gds-pay.density  = buf_temp-chk-gds.density
                  buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
                  buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
                  buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
                  buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
                  buf_chk-gds-pay.out-code = ub.chk-doc.out-code
                  buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
                  buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
                  buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
                  .
                assign
                buf_temp-chk-gds.sum = buf_temp-chk-gds.sum - buf_chk-gds-pay.tot-r-b
                temp-chk-gds.sum =  temp-chk-gds.sum - buf_chk-gds-pay.tot-r-b
                buf_temp-chk-gds.doc-qnty = buf_temp-chk-gds.doc-qnty - buf_chk-gds-pay.eff-doc-qnty
                temp-chk-pay.tot-r-b = temp-chk-pay.tot-r-b - buf_chk-gds-pay.tot-r-b
                pychk_dop-sumk = pychk_dop-sumk - buf_chk-gds-pay.tot-r-b
                .
                 if (ub.chk-doc.chk-type = 1 and temp-chk-pay.tot-r-b <= 0) or (ub.chk-doc.chk-type <> 1 and temp-chk-pay.tot-r-b >= 0) then leave dp.
            end.
        end.
      assign
      pychk_dop-sump = temp-chk-pay.tot-r-b
      pychk_exch = if pychk_No-exch then 1
                   else (if temp-chk-pay.tot-base = 0
                         then 0
                         else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base)
      pychk_exch-rubl = if pychk_No-exch-rubl
                        then 1
                        else (if temp-chk-pay.tot-base = 0
                              then 0
                              else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base)
      temp-chk-pay.flag = (if abs(temp-chk-pay.tot-rubl) < 0.001 then no else yes)
      .
      _repeat:
      REPEAT WHILE  abs(pychk_dop-sump) > 0 :
        if pychk_dop-sumg = 0 then do:
          assign
          pychk_kk = pychk_kk + 1
          .
          if pychk_kk >= pychk_jj then LEAVE _repeat.
          if pychk_kk <= pychk_jjp then do:
            find first temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                  and temp-chk-gds.jjp_ = pychk_kk
                  and temp-chk-gds.line-num = 0
                no-error .
          end.
          else do:
            find first temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                  and temp-chk-gds.jjo_ = pychk_kk - pychk_jjp
                  and temp-chk-gds.line-num = 0
                no-error .
          end.
          if not available temp-chk-gds
          or (temp-chk-gds.sum = 0
              or
              (temp-chk-gds.sum <= 0  and ub.chk-doc.netto > 0)
              )
          then do:
            NEXT _repeat.
          end.
          assign
          pychk_dop-sumg = if available temp-chk-gds then temp-chk-gds.sum else 0
          temp-chk-gds.flag = yes
          .
        end.
        assign
        pychk_dop-sumk = min(abs(pychk_dop-sumg), abs(pychk_dop-sump))  * (if pychk_dop-sump > 0 then 1 else -1 ) * (if pychk_dop-sumg < 0 AND ub.chk-doc.chk-type = 1 then -1 else 1 )
        pychk_pay-sum = pychk_pay-sum - pychk_dop-sumk
        pychk_dop-sump = pychk_dop-sump - pychk_dop-sumk
        pychk_dop-sumg = pychk_dop-sumg - pychk_dop-sumk
        pychk_sum-promo = GetPromoPriceSum(ub.chk-doc.doc-code)
        .
        if pychk_sum-promo <> 0 then
           vPromoLineNum = GetPromoPriceLine(ub.chk-doc.doc-code).
        else vPromoLineNum = 0.
        for each buf_temp-chk-gds where
                buf_temp-chk-gds.doc-code = ub.chk-doc.doc-code
            and buf_temp-chk-gds.b-code = temp-chk-gds.b-code
            and buf_temp-chk-gds.line-num  > 0
        by buf_temp-chk-gds.doc-code
        by buf_temp-chk-gds.rec-type descending
        by buf_temp-chk-gds.line-num
         :
          case num-entries(buf_temp-chk-gds.line-type, chr(4)):
            when 1 then do:
              pychk_line-type-chr = buf_temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
            end.
            when 2 then do:
              pychk_line-type-chr = buf_temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
            end.
          end case.
          if  vPromoLineNum <> 0 and
              temp-chk-gds.num-lines > 1 and
              buf_temp-chk-gds.line-num = vPromoLineNum and
              can-find(first buf_chk-gds-pay no-lock where
                             buf_chk-gds-pay.doc-code = buf_temp-chk-gds.doc-code
                         and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num)
          then .
          else
          if not (buf_temp-chk-gds.sum = 0 and can-find (first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code and buf_temp-chk-gds.line-num  =  temp-chk-dp.line-num)) then do:
              if vPromoLineNum <> 0 and
                 buf_temp-chk-gds.line-num = vPromoLineNum
              then do:
                 vSum = RoundUp(buf_temp-chk-gds.doc-qnty, buf_temp-chk-gds.price-base).
              end.
              else if vPromoLineNum <> 0 and
                      temp-chk-gds.num-lines > 1 and
                      pychk_sum-promo <> 0 and
                      ChkPromoLine(buf_temp-chk-gds.doc-code, buf_temp-chk-gds.line-num)
              then do:
                  if can-find(first buf_chk-gds-pay no-lock where
                                    buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                                and buf_chk-gds-pay.line-num = vPromoLineNum
                                )
                   then vSum = (pychk_dop-sumk * buf_temp-chk-gds.sum / (temp-chk-gds.sum - pychk_sum-promo)).
                   else vSum = ((pychk_dop-sumk - pychk_sum-promo) * buf_temp-chk-gds.sum / (temp-chk-gds.sum - pychk_sum-promo)).
              end.
              else
              vSum                     = (if    temp-chk-gds.num-lines = 1
                                            and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                          then pychk_dop-sumk
                                          else (pychk_dop-sumk * buf_temp-chk-gds.sum / temp-chk-gds.sum)
                                         )
              .
              if can-find (first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code) then do:
                  find first buf_chk-gds-pay where buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                  and buf_chk-gds-pay.algo-num = "1.8"
                  and buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
                  and buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
                  and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                  and buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
                  and buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card exclusive-lock no-error.
                  if not available buf_chk-gds-pay then do:
                     if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                     then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                     create buf_chk-gds-pay.
                  end.
              end.
              else do:
                   if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                   then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                   create buf_chk-gds-pay.
              end.
              assign
              buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
              buf_chk-gds-pay.chk-type = ub.chk-doc.chk-type
              buf_chk-gds-pay.algo-num = "1.8"
              buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
              buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
              buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
              buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
              buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
              buf_chk-gds-pay.tot-r-b = buf_chk-gds-pay.tot-r-b  + vSum
              buf_chk-gds-pay.eff-base-rate = pychk_exch
              buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
              buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
              buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
              buf_chk-gds-pay.price-base = buf_temp-chk-gds.price-base
              buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
              buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
              buf_chk-gds-pay.line-type = pychk_line-type-chr
              buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
              buf_chk-gds-pay.density  = buf_temp-chk-gds.density
              buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
              buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
              buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
              buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
              buf_chk-gds-pay.out-code = ub.chk-doc.out-code
              buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
              buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
              buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
              buf_temp-chk-gds.flag = yes
              .
              if buf_temp-chk-gds.line-num = vPromoLineNum
              then do:
                 buf_chk-gds-pay.eff-doc-qnty = buf_temp-chk-gds.doc-qnty.
              end.
              else
              buf_chk-gds-pay.eff-doc-qnty = (if buf_chk-gds-pay.eff-doc-qnty = ? then 0 else buf_chk-gds-pay.eff-doc-qnty) + (if (temp-chk-gds.num-lines = 1
                                              and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                              and pychk_pays_count = 1)
                                              or (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt) = 0
                                              then temp-chk-gds.doc-qnty
                                              else (vSum / (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt))
                                              )
              .
            end.
        end.
      end.
    end.
    if available temp-chk-gds then release temp-chk-gds.
    if available temp-chk-pay then release temp-chk-pay.
    pychk_zero-gds = 0.
    pychk_zero-pay = 0.
    for each temp-chk-gds where
            temp-chk-gds.doc-code = ub.chk-pay.doc-code
        and temp-chk-gds.flag = no
        and temp-chk-gds.line-num  > 0
        :
       pychk_zero-gds = pychk_zero-gds + 1.
    end.
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-pay.doc-code
        and temp-chk-pay.flag = no:
       pychk_zero-pay = pychk_zero-pay + 1.
    end.
    find first temp-chk-pay where temp-chk-pay.doc-code = ub.chk-pay.doc-code
                              and temp-chk-pay.flag = no
    no-lock no-error.
    if not available temp-chk-pay
    then do:
       block-pay:
       for each temp-chk-pay where temp-chk-pay.doc-code = ub.chk-pay.doc-code:
          assign
             pychk_zero-pay = pychk_zero-pay +  1
             temp-chk-pay.flag = no
          .
          leave block-pay.
       end.
    end.
    for each temp-chk-pay
    where   temp-chk-pay.doc-code = ub.chk-pay.doc-code
        and temp-chk-pay.flag = no:
      pychk_zero-n = 0.
      for each buf_temp-chk-gds
      where   buf_temp-chk-gds.doc-code = ub.chk-pay.doc-code
          and buf_temp-chk-gds.flag = no
          and buf_temp-chk-gds.line-num  > 0 :
        pychk_zero-n = pychk_zero-n + 1.
        if  temp-chk-pay.tot-r-b = 0 and buf_temp-chk-gds.discnt = 0 and abs(buf_temp-chk-gds.sum) > 0 then next.
        case num-entries(buf_temp-chk-gds.line-type, chr(4)):
          when 1 then do:
            pychk_line-type-chr = buf_temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
          end.
          when 2 then do:
            pychk_line-type-chr = buf_temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
          end.
        end case.
        if can-find(first buf_chk-gds-pay no-lock where
                          buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                      and buf_chk-gds-pay.algo-num = "1.8"
                      and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                      and buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num)
        then do:
            buf_temp-chk-gds.flag = yes.
        end.
        else do:
            create buf_chk-gds-pay.
            assign
            buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
            buf_chk-gds-pay.algo-num = "1.8"
            buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
            buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
            buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
            buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
            buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
            buf_chk-gds-pay.tot-r-b = 0
            buf_chk-gds-pay.eff-base-rate = pychk_exch
            buf_chk-gds-pay.eff-doc-qnty = buf_temp-chk-gds.doc-qnty
            buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
            buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
            buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
            buf_chk-gds-pay.price-base = (if temp-chk-pay.tot-r-b = 0 and buf_temp-chk-gds.discnt = 0 then 0 else buf_temp-chk-gds.price-base)
            buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
            buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
            buf_chk-gds-pay.line-type = pychk_line-type-chr
            buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
            buf_chk-gds-pay.density  = buf_temp-chk-gds.density
            buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
            buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
            buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
            buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
            buf_chk-gds-pay.out-code = ub.chk-doc.out-code
            buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
            buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
            buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
            buf_temp-chk-gds.flag = yes
            .
        end.
        if pychk_zero-n > pychk_zero-gds / pychk_zero-pay then leave.
      end.
      temp-chk-pay.flag = yes.
    end.
  end.
end.
end.
end.
end.
procedure proc-main :
define input parameter p-status_ like ub.trn-doc.status_ no-undo .
define variable road as logical no-undo.
define variable for-price as decimal no-undo.
define variable for-excise as decimal no-undo.
define variable for-road as decimal no-undo.
define variable bottle as logical no-undo.
define variable accum-chk-doc-tot-doc as decimal no-undo.
define variable accum-chk-doc-discnt as decimal no-undo.
define variable accum-chk-doc-netto as decimal no-undo.
define variable accum-chk-doc-sub-discnt as decimal no-undo.
define variable accum-chk-pay-tot-sum-by as decimal no-undo.
define variable accum-chk-pay-tot-base-by as decimal no-undo.
define variable accum-chk-pay-tot-rubl-by as decimal no-undo.
define variable KIND-TO-RESERV as character no-undo .
define variable KIND-TO-RESERV-GDS as character no-undo .
define variable cli-type-to-reserv as character no-undo.
define variable cli-code-to-reserv as integer no-undo.
define variable v-real-doc-kind as character no-undo .
define variable office-TO-RESERV as character no-undo .
define variable office-TO-RESERV-GDS as character no-undo .
define variable docs-to-reserv as integer no-undo .
define variable docs-to-reserv-gds as integer no-undo .
define variable v-add as logical no-undo .
define variable dtrg as integer no-undo .
define variable dtrg-start as logical no-undo .
define variable cashparts as logical no-undo.
define variable cashparts-chk as logical no-undo.
define variable serparts as logical no-undo.
define variable plcode like ub.place.pl-code no-undo.
define variable cashfbrs as logical no-undo .
define variable v-is-dish as character no-undo .
define variable v-deleted as logical no-undo .
define variable varchip-code as integer no-undo .
define variable varchip-code2 as integer no-undo .
define variable v-mes as character no-undo .
define variable v-clcdoc-vat-pc                     like ub.doc-line.vat-pc           no-undo.
define variable v-clcdoc-slt-pc                     like ub.doc-line.slt-pc           no-undo.
define variable glog as logical no-undo .
define variable action as character no-undo .
define variable other-doc-code as character no-undo .
define variable v-is-tpsi-obj as logical no-undo .
define variable v-tpsi-mode as integer no-undo .
define variable v-main-tpsi as logical no-undo .
DEFINE VARIABLE var-doc-type like ub.inkas-pay-desk.doc-type no-undo .
define variable v-rc-ii as integer no-undo initial 1.
define variable v-rc-max as integer no-undo .
define variable v-first as logical no-undo init yes .
define variable v-created as logical no-undo .
define variable v-created-dtl as logical no-undo .
define variable add-nf-amount as integer   no-undo .
define variable add-NF-gds-amount as integer   no-undo .
define variable v-dop as character no-undo .
define variable v-rec-inv-line as recid no-undo .
define variable nff-chk-amount as integer no-undo .
define variable v-cash-pay-attr as character no-undo.
define variable par-alcohol as character no-undo .
define variable par-type    as character no-undo .
define variable mark-ii     as integer no-undo .
define variable v-doc-code_fbr as character no-undo .
define variable v-pl-code   like ub.place.pl-code no-undo .
define variable v-pl-list   as character no-undo .
define variable v-pl-ii     as integer   no-undo .
define variable v-value     as character no-undo .
define variable v-ok        as logical   no-undo .
define variable v-Reconc-tank-attr as character no-undo .
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
define buffer buf_c-chk-doc for ub.c-chk-doc.
define buffer buf_c-chk-gds for ub.c-chk-gds.
define buffer buf_c-chk-pay for ub.c-chk-pay.
define buffer buf_c-chk-discnt for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_inkas-pay for ub.inkas-pay.
define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.
define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.
define buffer buf_place       for ub.place.
define buffer com_place       for ub.place.
define buffer dop_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer BUF_sale-doc for ub.sale-doc.
define buffer tpsi_sale-doc for ub.sale-doc.
do
on error undo, return error return-value
:
  if ink-doc.status_ = 'факт':U
  then do:
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Продажа &1 уже закрыта:&2Докачка чеков не может быть произведена"                                , ink-doc.inkas-code                                        , chr(10)                                                )                                       ) .
     UNDO, return error.
  end.
  find first ub.sysconf no-lock where
            ub.sysconf.host-code = ink-doc.host-code .
  if v-curr-r-b = 'base':U or
  ub.sysconf.base-code = 0 then pychk_NO-exch = yes.
  else pychk_No-exch = no.
  if v-curr-r-b = 'rubl':U or
  ub.sysconf.base-code = 0 then pychk_NO-exch-rubl = yes.
  else pychk_No-exch-rubl = no.
  assign
  accum-chk-doc-tot-doc = 0
  accum-chk-doc-discnt = 0
  accum-chk-doc-netto = 0
  accum-chk-doc-sub-discnt = 0
  v-rc-max = (if p-rid-list <> '':U then num-entries(p-rid-list) else 1)
  v-rc-ii = (if p-rid-list <> '':U
             then (if available X_chk-doc
                   then lookup(string(recid(X_chk-doc)), p-rid-list)
                   else v-rc-ii)
             else v-rc-ii)
  .
  run get-inkas-ps in this-procedure (
                                      buffer ink-doc
                                    , output chk-amount
                                    , output gds-amount
                                    , output line-out
                                    , output dtl-out
                                    , output line-ret
                                    , output dtl-ret
                                    , output nf-chk-amount
                                    , output nf-gds-amount
                                    , output p-filter-rus
                                    ).
  run get-tpsi-params in this-procedure (
                                          input ink-doc.obj-type
                                         ,input ink-doc.obj-code
                                         ,output v-is-tpsi-obj
                                         ,output v-tpsi-mode
                                         ,output v-main-tpsi ) no-error.
end.
do
on error undo, return error return-value
:
  for each buf_sale-doc where
           buf_sale-doc.inkas-code = ink-doc.inkas-code
       and buf_sale-doc.order > 0:
    buf_sale-doc.chk-doc-code = '':U.
  end.
  c-d:
  DO WHILE available X_chk-doc or (p-rid-list <> '':U and  v-rc-ii <= v-rc-max) or action = "next"
  on error undo c-d, NEXT c-d
  on stop undo c-d, NEXT c-d:
    action = '':U.
    if not v-first then do:
      if p-rid-list = "":U then do:
        ASSIGN
        glog = QUERY query-chk-doc:GET-next(no-LOCK) NO-ERROR.
        if available X_chk-doc then do:
          ASSIGN
          glog = QUERY query-chk-doc:GET-current(exclusive-LOCK, no-wait) NO-ERROR.
          if locked(X_chk-doc)
          or X_chk-doc.out-code <> ?
          then do:
            error-status:error = no.
            action = "next".
            next c-d.
          end.
        end.
      end.
      else do:
        assign
        v-rc-ii = v-rc-ii + 1.
        _v-rc:
        do while v-rc-ii <= v-rc-max:
          find first X_chk-doc exclusive-lock where
                    recid(X_chk-doc) = integer(entry(v-rc-ii, p-rid-list))  no-error  NO-WAIT.
          if locked X_chk-doc or not available X_chk-doc
          or X_chk-doc.out-code <> ?
          then do:
            assign
            v-rc-ii = v-rc-ii + 1.
            next _v-rc.
          end.
          else LEAVE _v-rc.
        end.
        if v-rc-ii > v-rc-max then release X_chk-doc.
      end.
      if (not available X_chk-doc and action = '':U)
      or (p-rid-list <> "":U and v-rc-ii > v-rc-max) then LEAVE c-d.
    end.
    if v-first then v-first = no.
    cr = 0.
    if lookup(string(X_chk-doc.chk-type), '101,106,108,169,196,114,115,116,136,117,111,112,113':U) > 0
    or lookup(string(X_chk-doc.chk-type), '11,111,201,206':U) > 0
    or X_chk-doc.out-code <> ?
    then do:
      next c-d.
    end.
    if lookup(string(X_chk-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) = 0
    then do:
      next c-d.
    end.
    if lookup(string(X_chk-doc.chk-type), '2,3,4,5,7':U) > 0
    and is-wth = yes then do:
      NEXT c-d .
    end.
    if v-is-tpsi-obj then do:
      if (p-status_ = 'запрос':U
      and index(X_chk-doc.doc-code, '>':U)  > 0 )
      or (p-status_ = 'касс':U
          and v-tpsi-mode = 2
          and index(X_chk-doc.doc-code, '>':U)  = 0
          )
      then next c-d.
    end.
    if cas-shft then do:
      if ink-doc.doc-date <> X_chk-doc.shift-date OR ink-doc.shift-num <> X_chk-doc.shift-num then do:
        NEXT c-d .
      end.
    end.
    else do:
      if p-day-only then do:
        if ink-doc.doc-date <> X_chk-doc.shift-date then do:
          NEXT c-d .
        end.
      end.
      else do:
        if X_chk-doc.shift-date > ink-doc.shift-date
        and ((p-rid-list = "":U and p-filter-on = no)
            or
            p-filter-on = no)
        then do:
          NEXT c-d .
        end.
      end.
    end.
    if replace(replace(replace(X_chk-doc.office
                               , 'т':U
                               , '':U)
                       , 'у':U
                       , '':U)
               , chr(44)
               , '':U) <> '':U
    then do:
      NEXT c-d .
    end.
    if one-curs
    and LOokup(string(X_chk-doc.chk-type), '14,15,16,36,8,101,106,108,11,12,13,40,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) = 0 then do:
      if cas-curs then do:
        find first buf_chk-pay where buf_chk-pay.doc-code = X_chk-doc.doc-code No-LOCK No-ERROR.
        if abs(buf_chk-pay.tot-rubl / buf_chk-pay.tot-base - cursh / cursh-scale) > 0.00005 then NEXT c-d.
      end.
      else do:
        if
        X_chk-doc.cash-rate <> cursh
        or
        X_chk-doc.cash-scale <> cursh-scale  then NEXT c-d.
      end.
    end.
    assign
    p-ii = p-ii + 1
    .
    if p-ii < 10
    or (p-ii < 1000 and chk-amount modulo 10 = 0)
    or (p-ii < 10000 and chk-amount modulo 100 = 0)
    then do:
      run display-chk in p-call-handle (chk-amount, nf-chk-amount).
    end.
    if X_chk-doc.chk-type <> integer('12':U) and X_chk-doc.office <> "" then do:
    docs-to-reserv = get-inc-sal (
                                  input string(X_chk-doc.chk-type)
                                , input X_chk-doc.netto
                                , input yes
                                , input X_chk-doc.office
                                , input ?
                                , output v-add
                                , output office-to-reserv
                                , output kind-to-reserv
                                , output add-nf-amount
                                ) no-error .
    end.
    else docs-to-reserv = 0 .
    v-cash-pay-attr = "".
    cli-type-to-reserv = "".
    cli-code-to-reserv = 0.
    if X_chk-doc.chk-type = integer('17':U) then do:
        for each buf_chk-pay where buf_chk-pay.doc-code = X_chk-doc.doc-code no-lock:
            find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = buf_chk-pay.pay-code
                                         and buf_cash-pay-attr.curr-code = buf_chk-pay.curr-code
                                         and buf_cash-pay-attr.attr-code = "dop-doc" no-lock no-error.
            if not available(buf_cash-pay-attr) then next.
            v-cash-pay-attr = buf_cash-pay-attr.attr-value.
            case entry(1, v-cash-pay-attr, ','):
                when 'swo':U then do:
                    v-add = no.
                    docs-to-reserv = 1.
                    office-to-reserv = 'т':U.
                    kind-to-reserv = entry(1, v-cash-pay-attr, ',').
                    cli-type-to-reserv = entry(2, v-cash-pay-attr, ',').
                    cli-code-to-reserv = int(entry(3, v-cash-pay-attr, ',')).
                end.
                when 'trf':U then do:
                    cli-type-to-reserv = entry(2, v-cash-pay-attr, ',').
                    cli-code-to-reserv = int(entry(3, v-cash-pay-attr, ',')).
                end.
                when 'vir':U then do:
                    kind-to-reserv = 'vir':U.
                    cli-type-to-reserv = entry(2, v-cash-pay-attr, ',').
                    cli-code-to-reserv = int(entry(3, v-cash-pay-attr, ',')).
                end.
                when 'none' then do:
                    docs-to-reserv = 0.
                    kind-to-reserv = 'none'.
                end.
            end case.
        end.
    end.
    if docs-to-reserv > 0
    and not (KIND-TO-RESERV = 'es':U
             and office-to-reserv = 'т':U) then do:
      do dtrg = 1 to docs-to-reserv:
        find first buf_sale-doc where
                  buf_Sale-doc.inkas-code = ink-doc.inkas-code
              and buf_sale-doc.doc-kind = entry(dtrg, kind-to-reserv)
              and buf_sale-doc.chr-office = entry(dtrg, office-to-reserv) no-error .
        if not available buf_sale-doc then do:
          run str/cresalad.p (
                          buffer trn-doc
                        , buffer dop_trn-doc
                        , input entry(dtrg, kind-to-reserv)
                        , input entry(dtrg, office-to-reserv)
                        , input cli-type-to-reserv
                        , input cli-code-to-reserv
                        , output other-doc-code) no-error .
          if error-status:error then do:
            run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("&1 &2 &3&4&5&4&6"                                    , vss-workfile                                                     , vss-revision                                                     , vss-description                                                  , chr(10)                                                    , error-status:get-message(1)                                      , return-value)                                       ) .
            undo c-d, next c-d.
          end.
        end.
      end.
    end.
    _one-check:
    do
    on error undo _one-check, leave _one-check
    on stop undo _one-check, leave _one-check
    :
      _buf_chk-gds:
      FOR EACH buf_chk-gds WHERE buf_chk-gds.doc-code = X_chk-doc.doc-code
      by buf_chk-gds.price-base
      on error undo _one-check, LEAVE _one-check
      on stop undo _one-check, leave _one-check
      :
        buf_chk-gds.out-code = ink-doc.inkas-code .
        if buf_chk-gds.doc-qnty = 0 then do:
          assign
          GDS-AMOUNT = GDS-AMOUNT + 1
          nf-gds-amount = nf-gds-amount  + 1 when (  lookup( string(X_chk-doc.chk-type), '14,15,16,36,8,101,106,108,11,12,13,40,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U )  >  0  )
          .
          NEXT _Buf_chk-gds.
        end.
         if X_chk-doc.chk-type <> integer('12':U) and X_chk-doc.office = "" then
         do:
            run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Чек &1 не имеет тип чека. Чек не будет закачан в продажу&2&3"                                    , X_chk-doc.doc-code                                               , chr(10)                                                    , return-value                                                     )                                       ) .
            undo _one-check, leave _one-check.
         end.
        docs-to-reserv-gds = get-inc-sal(
                                      input string(X_chk-doc.chk-type)
                                    , input X_chk-doc.netto
                                    , input no
                                    , input entry(1, buf_chk-gds.line-type, chr(4))
                                    , input string(BUF_CHK-GDS.WRITE-OFF-CODE)
                                    , output v-add
                                    , output office-to-reserv-gds
                                    , output kind-to-reserv-gds
                                    , output add-nf-gds-amount
                                    ) no-error.
        if X_chk-doc.chk-type = integer('17':U) then do:
            for each buf_chk-pay where buf_chk-pay.doc-code = X_chk-doc.doc-code no-lock:
                find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = buf_chk-pay.pay-code
                                             and buf_cash-pay-attr.curr-code = buf_chk-pay.curr-code
                                             and buf_cash-pay-attr.attr-code = "dop-doc" no-lock no-error.
                if not available(buf_cash-pay-attr) then next.
                v-cash-pay-attr = buf_cash-pay-attr.attr-value.
                case entry(1, v-cash-pay-attr, ','):
                    when 'vir':U then do:
                        assign
                        kind-to-reserv-gds = 'vir':U
                        docs-to-reserv-gds = 1
                        v-add = no
                        office-TO-RESERV-GDS = 'т'.
                    end.
                    when 'none' then do:
                        assign
                        kind-to-reserv-gds = 'none'
                        docs-to-reserv-gds = 0
                        v-add = no
                        office-TO-RESERV-GDS = 'т'.
                        create buf_sale-doc.
                        assign
                        buf_sale-doc.inkas-code = ink-doc.inkas-code
                        buf_sale-doc.storage =  'trn-doc':U
                        buf_sale-doc.host-code = ink-doc.host-code
                        buf_sale-doc.obj-type = ink-doc.obj-type
                        buf_sale-doc.obj-code = ink-doc.obj-code
                        buf_sale-doc.doc-kind  = 'none'
                        buf_sale-doc.order = 0
                        buf_sale-doc.chr-office = 'т'
                        buf_sale-doc.doc-code = ''.
                    end.
                 end case.
            end.
        end.
        assign
        GDS-AMOUNT = GDS-AMOUNT + 1
        nf-gds-amount = nf-gds-amount  + add-nf-gds-amount
        .
        assign
        office-to-reserv-gds = (if v-add
                              then (office-to-reserv + (if kind-to-reserv-gds = '':u
                                                      then '':u
                                                      else chr(44)) +
                                  office-to-reserv-gds)
                              else  office-to-reserv-gds)
        kind-to-reserv-gds = (if v-add
                              then (kind-to-reserv + (if kind-to-reserv-gds = '':u
                                                      then '':u
                                                      else chr(44)) +
                                  kind-to-reserv-gds)
                            else  kind-to-reserv-gds)
          docs-to-reserv-gds = (docs-to-reserv  + docs-to-reserv-gds) when v-add
        .
        FIND FIRST ub.bar-code WHERE ub.bar-code.b-code = buf_chk-gds.b-code NO-LOCK NO-ERROR.
        release ub.goods.
        if avail ub.bar-code then
          FIND FIRST ub.goods WHERE
                     ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK.
        if buf_chk-gds.pump > 0 then do :
          if not avail ub.bar-code then do:
        run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("&1 &2 &3&4Чек &5 строка &6,&4отсутствует в БД бар-код &7&4Чек не будет закачан в продажу"                                      , vss-workfile                                                       , vss-revision                                                       , vss-description                                                    , chr(10)                                                      , X_chk-doc.doc-code                                                 , buf_chk-gds.line-num                                               , buf_chk-gds.b-code)                                       ) .
            undo _one-check, leave _one-check.
          end.
          run findtank in this-procedure
                              (input p-obj-type,
                              input p-obj-code,
                              input buf_chk-gds.pump,
                              input buf_chk-gds.nozzle-code,
                              input buf_chk-gds.pl-code,
                              input ub.bar-code.gds-code,
                              output plcode) no-error.
          if error-status :error or plcode = ? then do:
  run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Чек &1 Бар-код &2 ТРК &3&4Не удается определить танк&4Чек не будет закачан в продажу&4&5"                                , X_chk-doc.doc-code                                           , buf_chk-gds.b-code                                                 , buf_chk-gds.pump                                                   , chr(10)                                                , return-value                                                 )                                       ) .
            UNDO _one-check, leave _one-check.
          end.
          find first buf_place no-lock where buf_place.pl-code = plcode no-error .
          if not available buf_place then do:
  run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Чек &1 Бар-код &2 ТРК &3&4Не удается определить резервуар&4Чек не будет закачан в продажу&4&5"                                , X_chk-doc.doc-code                                           , buf_chk-gds.b-code                                                 , buf_chk-gds.pump                                                   , chr(10)                                                , return-value                                                 )                                       ) .
            UNDO _one-check, leave _one-check.
          end.
          assign
            v-pl-code           = plcode
            buf_chk-gds.pl-code = plcode
            buf_chk-gds.loc1    = buf_place.loc1
          .
          run placelib_get-attr (
            input "place-auto-gate-valve"
            ,input buf_place.obj-code
            ,input buf_place.obj-type
            ,input buf_place.pl-code
            ,output v-value
            ,output v-ok     )
          no-error.
          if v-ok
          and logical(v-value)
          then do :
            v-pl-list = "" .
            run placelib_get-attr (
              input "place-com-tanks"
              ,input buf_place.obj-code
              ,input buf_place.obj-type
              ,input buf_place.pl-code
              ,output v-value
              ,output v-ok     )
            no-error.
            if v-ok
            and v-value > ""
            then do :
              v-pl-list = string(buf_place.pl-code) .
              do v-pl-ii = 1 to num-entries(v-value) :
                for first com_place no-lock where com_place.obj-type = p-obj-type
                                              and com_place.obj-code = p-obj-code
                                              and com_place.loc1 = entry(v-pl-ii, v-value)
                                              and com_place.status_ = ""
                :
                  v-pl-list = v-pl-list + "," + string(com_place.pl-code) .
                end .
              end .
            end .
            if num-entries(v-pl-list) > 1
            then do :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_vollosan in g#lib-trn3
  (  input  goods.gds-code
  ,  input  X_chk-doc.obj-type
  ,  input  X_chk-doc.obj-code
  ,  input  v-pl-list
  ,  input  X_chk-doc.shift-date
  ,  input  X_chk-doc.shift-num
  ,  input  X_chk-doc.chk-date
  ,  input  X_chk-doc.chk-time
  , output  v-pl-code
  ) no-error .
              if error-status:error then do:
                run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Чек &1 Бар-код &2 ТРК &3&4Не удается определить резервуар среди сообщающихся &4&5&4Чек не будет закачан в продажу"                                    , X_chk-doc.doc-code                                               , t-gds.b-code                                                     , t-gds.pump                                                       , chr(10)                                                    , v-pl-list                                                     )                                       ) .
                UNDO _one-check, leave _one-check.
              end.
              if v-pl-code = 0
              or v-pl-code = ?
              then do :
                assign v-pl-code = plcode .
              end .
            end .
          end .
          if valid-density( buf_chk-gds.density, (goods.unit-base = goods.unit-cli)  ) <> true then do:
            v-Reconc-tank-attr = "" .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avrgdens in g#lib-trn3
  (  input  goods.gds-code
  ,  input  X_chk-doc.obj-type
  ,  input  X_chk-doc.obj-code
  ,  input  v-pl-code
  ,  input  X_chk-doc.shift-date
  ,  input  X_chk-doc.shift-num
  ,  input  X_chk-doc.chk-date
  ,  input  X_chk-doc.chk-time
  , output  buf_chk-gds.density
  , output v-Reconc-tank-attr
  ) no-error .
            if error-status:error then do:
              run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Чек &1 Бар-код &2 ТРК &3&4Не удается определить плотность топлива в танке&4&5&4Чек не будет закачан в продажу"                                  , X_chk-doc.doc-code                                             , t-gds.b-code                                                   , t-gds.pump                                                     , chr(10)                                                  , return-value                                                   )                                       ) .
              UNDO _one-check, leave _one-check.
            end.
            if v-Reconc-tank-attr > ""
            then do :
              find first chk-gds-attr exclusive-lock where chk-gds-attr.doc-code = buf_chk-gds.doc-code
                                                       and chk-gds-attr.line-num = buf_chk-gds.line-num
                                                       and chk-gds-attr.attr-code = "Reconc-tank"
                                                       no-error .
              if not available chk-gds-attr
              then do :
                create chk-gds-attr .
                assign
                  chk-gds-attr.doc-code = buf_chk-gds.doc-code
                  chk-gds-attr.line-num = buf_chk-gds.line-num
                  chk-gds-attr.attr-code = "Reconc-tank"
                .
              end .
              assign
                chk-gds-attr.attr-value = v-Reconc-tank-attr
              .
            end .
          end.
        end .
define variable v-chk-gds-line-type-1    as character no-undo .
define variable v-office-to-reserv-gds-n as character no-undo .
define variable v-kind-to-reserv-gds-n   as character no-undo .
        if docs-to-reserv-gds <> 0 then do:
          v-chk-gds-line-type-1 = entry(1, buf_chk-gds.line-type, chr(4)) .
          if docs-to-reserv-gds > 0 then  do:
            if KIND-TO-RESERV-GDS <> 'none' then do :
              _dtrg-gds:
              do dtrg = 1 to docs-to-reserv-gds :
                v-office-to-reserv-gds-n = entry(dtrg, office-to-reserv-gds) .
                if v-office-to-reserv-gds-n <> v-chk-gds-line-type-1 then next _dtrg-gds.
                v-kind-to-reserv-gds-n = entry(dtrg, kind-to-reserv-gds) .
              find first buf_sale-doc where
                        buf_Sale-doc.inkas-code = ink-doc.inkas-code
                    and buf_sale-doc.doc-kind = v-kind-to-reserv-gds-n
                    and buf_sale-doc.chr-office = v-office-to-reserv-gds-n
                    no-error .
              if available buf_sale-doc then next _dtrg-gds .
                run str/cresalad.p (
                                buffer trn-doc
                              , buffer dop_trn-doc
                              , input v-kind-to-reserv-gds-n
                              , input v-office-to-reserv-gds-n
                              , input cli-type-to-reserv
                              , input cli-code-to-reserv
                              , output other-doc-code) no-error .
                if error-status:error then do:
                                    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("&1 &2 &3&4&5&4&6"                                                , vss-workfile                                                                 , vss-revision                                                                 , vss-description                                                              , chr(10)                                                                , error-status:get-message(1)                                                  , return-value)                                       ) .
                  undo c-d, NEXT c-d.
                end.
              end.
            end .
          end.
          dtrg-start = ?.
          v-real-doc-kind = ''.
          _dtrg-gds2:
          do dtrg = 1 to docs-to-reserv-gds:
            v-office-to-reserv-gds-n = entry(dtrg, office-to-reserv-gds) .
            if v-office-to-reserv-gds-n <> v-chk-gds-line-type-1 then next _dtrg-gds2.
            v-kind-to-reserv-gds-n = entry(dtrg, kind-to-reserv-gds) .
            dtrg-start = (dtrg-start = ?) .
            v-real-doc-kind = v-real-doc-kind + v-kind-to-reserv-gds-n.
            find first buf_sale-doc where
                       buf_sale-doc.inkas-code = ink-doc.inkas-code
                   and buf_sale-doc.doc-kind = v-kind-to-reserv-gds-n
                   and buf_sale-doc.chr-office = v-office-to-reserv-gds-n
                   no-error.
            if buf_chk-gds.grp-code = 0 then   do:
              if cr > 0 then do:
                if (buf_chk-gds.pump > 0) and (buf_chk-gds.pl-code = 0 or buf_chk-gds.pl-code = ?) then do:
                  if buf_chk-gds.nozzle-code <> 0 then
find first t-gds
     WHERE t-gds.doc-code    = buf_sale-doc.doc-code
       and t-gds.b-code      = buf_chk-gds.b-code
       and t-gds.drc         = recid(X_chk-doc)
       AND t-gds.pump        = buf_chk-gds.pump
       AND t-gds.nozzle-code = buf_chk-gds.nozzle-code NO-ERROR.
                  else
find first t-gds
     WHERE t-gds.doc-code    = buf_sale-doc.doc-code
       and t-gds.b-code      = buf_chk-gds.b-code
       and t-gds.drc         = recid(X_chk-doc)
       AND t-gds.pump        = buf_chk-gds.pump NO-ERROR.
                end.
                else do:
                  if buf_chk-gds.nozzle-code <> 0 then
find first t-gds
     WHERE t-gds.doc-code    = buf_sale-doc.doc-code
       and t-gds.b-code      = buf_chk-gds.b-code
       and t-gds.drc         = recid(X_chk-doc)
       AND t-gds.pump        = buf_chk-gds.pump
       AND t-gds.nozzle-code = buf_chk-gds.nozzle-code
       AND t-gds.pl-code     = buf_chk-gds.pl-code NO-ERROR.
                  else
find first t-gds
     WHERE t-gds.doc-code    = buf_sale-doc.doc-code
       and t-gds.b-code      = buf_chk-gds.b-code
       and t-gds.drc         = recid(X_chk-doc)
       AND t-gds.pump        = buf_chk-gds.pump
       AND t-gds.pl-code     = buf_chk-gds.pl-code NO-ERROR.
                end.
              end.
              if not avail t-gds
              or cr = 0
              OR (t-gds.grc <> ? AND t-gds.grc <> recid(buf_chk-gds))
              or NOT (t-gds.fbr-obj-type = buf_chk-gds.depart-type
                      AND
                      t-gds.fbr-obj-code = buf_chk-gds.depart-code)
              then  do:
                if dtrg-start = yes then do:
                  assign
                  cashparts-chk = no
                  serparts = no
                  cashfbrs = no
                  .
                  if not avail bar-code then do:
        run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("&1 &2 &3&4Чек &5 строка &6,&4отсутствует в БД бар-код &7&4Чек не будет закачан в продажу"                                      , vss-workfile                                                       , vss-revision                                                       , vss-description                                                    , chr(10)                                                      , X_chk-doc.doc-code                                                 , buf_chk-gds.line-num                                               , buf_chk-gds.b-code)                                       ) .
                    undo _one-check, leave _one-check.
                  end.
                  if ub.bar-code.in-code <> "" then cashparts-chk = yes.
                  else cashparts-chk = no.
                  if buf_chk-gds.price-base = 0
                  and goods.gds-type = 'у':U
                  and (buf_Chk-gds.write-off-code = 0
                      or
                      buf_Chk-gds.write-off-code = ?) then do:
                run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("&1 &2 &3&4Чек &5 строка &6, цена товара-услуги с бар-кодом &7=0&4Чек не будет закачан в продажу"                                      , vss-workfile                                                       , vss-revision                                                       , vss-description                                                    , chr(10)                                                      , X_chk-doc.doc-code                                                 , buf_chk-gds.line-num                                               , buf_chk-gds.b-code)                                       ) .
                    undo _one-check, leave _one-check.
                  end.
                  FIND FIRST ub.units No-LOCK WHERE
                            ub.units.unit-name = ub.goods.unit-base No-ERROR.
                  if lookup('2ед':U, ub.units.type) > 0 then cashparts-chk = yes.
                  if prcl-spl or
                  can-find(first ub.tax-units No-LOCK WHERE
                                ub.tax-units.tax-code = exctaxcd AND
                                lookup(ub.tax-units.type , units.type) > 0 ) or
                  can-find(first ub.tax-units No-LOCK WHERE
                                ub.tax-units.tax-code = btltaxcd AND
                                lookup(ub.tax-units.type , units.type) > 0 )
                                then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  ub.bar-code.b-code
  ,input  0
  ,input  0
  ,output gp-doc-num
  ,output gp-price-sale
  ,output for-road
  ,output for-excise
  ) no-error .
                          if gp-price-sale = ?
                    and not (lookup (STRING(if buf_chk-gds.write-off-code <> ? then buf_chk-gds.write-off-code else 0),  '2,-2,3,-3,-4':U) > 0)
                    then DO:
      run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Чек &1 Строка &2&3Бар-код &4 Артикул &5 &6&3Нет продажной цены&3Чек не будет закачан в продажу"                                    , X_chk-doc.doc-code                                               , Buf_chk-gds.line-num                                             , chr(10)                                                    , ub.bar-code.b-code                                                  , ub.goods.artic                                                      , ub.goods.gds-name)                                       ) .
                      undo _one-check, leave _one-check.
                    END.
                    assign
                    for-price = gp-price-sale
                    for-excise = if can-find(first ub.tax-units No-LOCK WHERE
                                ub.tax-units.tax-code = exctaxcd AND
                                LOOKUP(ub.tax-units.type, units.type) > 0)
                                        then gp-excise
                                        else 0
                    .
                  end.
                  else
                  assign
                  for-price = buf_chk-gds.price-base + buf_chk-gds.price-service
                  for-excise = 0.
                  if can-find(first ub.tax-units No-LOCK WHERE
                                    ub.tax-units.tax-code = rdtaxcd AND
                                    LOOKUP(ub.tax-units.type, units.type) > 0)
                                    then road = yes.
                  else road = no.
                  assign
                  v-is-dish = "":u
                  .
                  if NOT (buf_chk-gds.depart-type = "":U and
                          buf_chk-gds.depart-code = 0)
                  AND NOT (buf_chk-gds.depart-type = ? and
                          buf_chk-gds.depart-code = ?)
                          then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run fgdsobjt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  goods.gds-code
  ,input  'is-dish=request'
  ,output v-is-dish
  ) no-error .
                  end.
                  if not error-status:error then do:
                    assign
                    cashfbrs = (integer(v-is-dish) > 0)
                    no-error .
                  end.
                end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  ink-doc.host-code
  ,input  ink-doc.obj-type
  ,input  ink-doc.obj-code
  ,output v-clcdoc-vat-pc
  ) no-error .
                find first dop_trn-doc no-lock where
                          dop_trn-doc.doc-code = buf_sale-doc.doc-code.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_st-sltpc in g#lib-trn
(
 input  recid(goods)
,input  recid(dop_trn-doc)
,input  buf_sale-doc.pay-code
,output v-clcdoc-slt-pc
)
.
                cr = cr + 1 .
                FIND FIRST t-gds where t-gds.crf = cr use-index crfi No-ERROR.
                if available t-gds then do :
                  t-gds.marks = ''.
                end .
                else do :
                  create t-gds.
                  assign
                    t-gds.crf   = cr
                    t-gds.marks = ''
                  .
                end .
                if avail t-gds then do:
                  assign
                  t-gds.is-modificator = no
                  t-gds.price-base = 0
                  t-gds.price-service = 0
                  t-gds.doc-code = '':U
                  .
                end.
                assign
                t-gds.doc-code = buf_sale-doc.doc-code
                t-gds.b-code = buf_chk-gds.b-code
                t-gds.gds-code = goods.gds-code
                t-gds.artic = goods.artic
                t-gds.prod-type = goods.prod-type
                t-gds.prod-code = goods.prod-code
                t-gds.unit-base = goods.unit-base
                t-gds.cashparts = cashparts-chk
                t-gds.doc-qnty = 0
                t-gds.node-code = bar-code.node-code
                t-gds.drc = recid(X_chk-doc)
                t-gds.new-price = for-price
                t-gds.prt-root = goods.prt-root
                t-gds.price-sum = 0
                t-gds.discnt-sum = 0
                t-gds.service-sum = 0
                t-gds.road-sum = 0
                t-gds.num-lines = 0
                t-gds.pump = buf_chk-gds.pump
                t-gds.nozzle-code = buf_chk-gds.nozzle-code
                t-gds.loc1 = buf_chk-gds.loc1
                t-gds.pl-code = buf_chk-gds.pl-code
                t-gds.slt-pc = v-clcdoc-slt-pc
                t-gds.vat-pc = v-clcdoc-vat-pc
                t-gds.excise = for-excise
                t-gds.grc = (if LOOKUP('2ед':U, units.type) > 0 then recid(t-gds) else ?)
                t-gds.type = units.type
                t-gds.fbr-obj-type = buf_chk-gds.depart-type
                t-gds.fbr-obj-code = buf_chk-gds.depart-code
                t-gds.is-modificator =  if (lookup (STRING(if buf_chk-gds.write-off-code <> ? then buf_chk-gds.write-off-code else 0),  '2,-2,3,-3,-4':U) > 0)
                                        or t-gds.is-modificator
                                        then yes
                                        else t-gds.is-modificator
                .
              end.
              assign
              t-gds.doc-qnty = t-gds.doc-qnty + buf_chk-gds.doc-qnty
              t-gds.num-lines = t-gds.num-lines + 1
              t-gds.price-base = if (buf_chk-gds.price-base + buf_chk-gds.price-service) > 0 then
                                (buf_chk-gds.price-base + buf_chk-gds.price-service)
                                                               else t-gds.price-base
              t-gds.price-service = if (buf_chk-gds.price-base + buf_chk-gds.price-service) > 0 then
                                    buf_chk-gds.price-service
                                                               else t-gds.price-service
              t-gds.discnt        = (if buf_sale-doc.doc-type = 'спи':U
                              then 0
                              else buf_chk-gds.discnt)
              t-gds.price-sum = t-gds.price-sum + GetRoundSum(buf_chk-gds.doc-code, buf_chk-gds.line-num, buf_chk-gds.doc-qnty, (buf_chk-gds.price-base + buf_chk-gds.price-service ))
              t-gds.discnt-sum  = t-gds.discnt-sum + (if buf_sale-doc.doc-type = 'спи':U
                                                      then 0
                                                      else buf_chk-gds.discnt * buf_chk-gds.doc-qnty)
              t-gds.road-sum = t-gds.road-sum + buf_chk-gds.road-tax * buf_chk-gds.doc-qnty
              t-gds.service-sum = t-gds.service-sum + buf_chk-gds.price-service * buf_chk-gds.doc-qnty
              t-gds.density = buf_chk-gds.density
              .
              run gds-attr-value(
                    t-gds.gds-code,
                    'mark':U,
                    output par-alcohol,
                    output par-type
              ).
              if par-alcohol = "yes" then do :
                find first chk-gds-attr exclusive-lock where chk-gds-attr.doc-code = buf_chk-gds.doc-code
                                                  and chk-gds-attr.line-num = buf_chk-gds.line-num
                                                  and chk-gds-attr.attr-code = "mark-code"
                                                  no-error .
                if available chk-gds-attr
                then do :
                  if buf_chk-gds.doc-qnty < 0
                  then do mark-ii = 1 to num-entries(chk-gds-attr.attr-value) :
                      entry(mark-ii, chk-gds-attr.attr-value) = (if entry(mark-ii, chk-gds-attr.attr-value) begins "-" then "" else "-")
                                                              + entry(mark-ii, chk-gds-attr.attr-value) .
                  end.
                  t-gds.marks = t-gds.marks + (if t-gds.marks = '' then '' else ',') + chk-gds-attr.attr-value .
                end.
                release chk-gds-attr no-error .
              end.
            end.
          end.
          if available t-gds then release t-gds .
          assign
          buf_chk-gds.line-type = entry(1, buf_chk-gds.line-type) + chr(4) +
                                  trim(v-real-doc-kind, chr(44))
                                  .
        end.
      end.
      if docs-to-reserv > 0 or KIND-TO-RESERV = 'none' then do:
        FOR EACH t-gds where t-gds.crf <= cr,
                 first buf_sale-doc where
                       buf_sale-doc.inkas-code = ink-doc.inkas-code
                   and buf_sale-doc.doc-code = t-gds.doc-code:
          if t-gds.doc-qnty = 0 AND
              t-gds.price-sum = 0 AND
              t-gds.discnt-sum = 0 then NEXT.
          FIND FIRST buf_doc-line WHERE buf_doc-line.doc-code = t-gds.doc-code
                                and buf_doc-line.artic = t-gds.artic
                                and buf_doc-line.prod-type = t-gds.prod-type
                                and buf_doc-line.prod-code = t-gds.prod-code NO-ERROR .
          if NOT available buf_doc-line then do:
            assign
            v-created = yes
            .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdoclin in g#lib-trn
(input t-gds.doc-code
,input t-gds.artic
,input t-gds.prod-type
,input t-gds.prod-code
,input p-obj-type
,input p-obj-code
,input '':U
,input buf_sale-doc.ext-doc-type
,input t-gds.prt-root
,input t-gds.VAT-pc
,input t-gds.SLT-pc
,input ub.sysconf.cons-vat-pc
) no-error
.
            find first buf_doc-line where
                    buf_doc-line.doc-code = t-gds.doc-code
                AND buf_doc-line.artic = t-gds.artic
                AND buf_doc-line.prod-type = t-gds.prod-type
                AND buf_doc-line.prod-code = t-gds.prod-code .
            assign
            buf_doc-line.doc-qnty = 0
            buf_doc-line.fact-qnty = 0
            buf_doc-line.price-base = 0
            buf_doc-line.price-rubl = 0
            buf_doc-line.prt-OK = yes
            buf_doc-line.unit-cli = (if t-gds.pump > 0
                                     then t-gds.unit-cli
                                     else t-gds.unit-base)
            buf_doc-line.cli-base-rate = 1
            .
          end.
          else v-created = no.
          assign
          buf_doc-line.fact-qnty = buf_doc-line.fact-qnty + abs( t-gds.doc-qnty )
          .
          run gds-attr-value(
                t-gds.gds-code,
                'mark':U,
                output par-alcohol,
                output par-type
            ).
          if t-gds.marks <> '' and par-alcohol = "yes"
          then do :
            find first doc-line-attr exclusive-lock where doc-line-attr.doc-code = buf_doc-line.doc-code
                                                      and doc-line-attr.gds-code = t-gds.gds-code
                                                      and doc-line-attr.attr-code = 'mark-code'
                                                      no-error.
            if not available doc-line-attr
            then do :
              create doc-line-attr .
              assign
                doc-line-attr.doc-code = buf_doc-line.doc-code
                doc-line-attr.gds-code = t-gds.gds-code
                doc-line-attr.attr-code = 'mark-code'
              .
            end.
            doc-line-attr.attr-value = doc-line-attr.attr-value + ',' + t-gds.marks .
            doc-line-attr.attr-value = trim(doc-line-attr.attr-value, ',') .
          end.
          if t-gds.pump > 0 then do:
            define variable v-doc-pl-rowid as rowid no-undo .
            define variable v-qnty as decimal no-undo .
            define variable v-cli-qnty as decimal no-undo .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdocpl in g#lib-trn
(input  t-gds.doc-code
,input  t-gds.gds-code
,input  t-gds.pl-code
,input  X_chk-doc.obj-type
,input  X_chk-doc.obj-code
,output v-doc-pl-rowid
) no-error
.
            if error-status:error then do:
  run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Чек &1 Бар-код &2 скл.место &3&4Не удается создать строку документа для скл.места&4&5&4Чек не будет закачан в продажу"                              , X_chk-doc.doc-code                                         , t-gds.b-code                                               , t-gds.pl-code                                              , chr(10)                                              , return-value                                               )                                       ) .
              UNDO _one-check, leave _one-check.
            end.
            FIND FIRST ub.doc-pl WHERE rowid(ub.doc-pl) = v-doc-pl-rowid.
            assign
            ub.doc-pl.fact-qnty = ub.doc-pl.fact-qnty + abs( t-gds.doc-qnty )
            .
            assign
            ub.doc-pl.cli-fact-qnty = ub.doc-pl.cli-fact-qnty + abs( t-gds.doc-qnty ) * t-gds.density
            .
            release doc-pl.
            assign
            v-qnty     = 0.0
            v-cli-qnty = 0.0
            .
            for each ub.doc-pl no-lock where
                    ub.doc-pl.out-code = t-gds.doc-code
                and ub.doc-pl.gds-code = t-gds.gds-code:
              assign
              v-qnty     = v-qnty + ub.doc-pl.fact-qnty
              v-cli-qnty = v-cli-qnty + ub.doc-pl.cli-fact-qnty
              .
            end.
            assign
            buf_doc-line.fact-density = v-cli-qnty / v-qnty
            buf_doc-line.doc-density = buf_doc-line.fact-density
            .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_corinvln in g#lib-trn3
( input  buf_doc-line.doc-code
 ,input  buf_doc-line.artic
 ,input  buf_doc-line.prod-type
 ,input  buf_doc-line.prod-code
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  ?
 ,input   buf_doc-line.fact-qnty * buf_doc-line.fact-density
 ,input  buf_doc-line.fact-density
 ,output v-rec-inv-line
 ) .
            FIND FIRST ub.doc-pl-pump WHERE ub.doc-pl-pump.out-code = t-gds.doc-code AND
                                        ub.doc-pl-pump.gds-code = t-gds.gds-code AND
                                        ub.doc-pl-pump.pl-code = t-gds.pl-code AND
                                        ub.doc-pl-pump.obj-type = p-obj-type AND
                                        ub.doc-pl-pump.obj-code = p-obj-code AND
                                        ub.doc-pl-pump.pump-code = t-gds.pump
                                        NO-ERROR.
            IF not avail ub.doc-pl-pump THEN do:
              create ub.doc-pl-pump.
              assign
              ub.doc-pl-pump.obj-type = p-obj-type
              ub.doc-pl-pump.obj-code = p-obj-code
              ub.doc-pl-pump.out-code = t-gds.doc-code
              ub.doc-pl-pump.gds-code = t-gds.gds-code
              ub.doc-pl-pump.pl-code = t-gds.pl-code
              ub.doc-pl-pump.doc-qnty = 0
              ub.doc-pl-pump.fact-qnty = 0
              ub.doc-pl-pump.pump-code = t-gds.pump
              .
            end.
            assign
            ub.doc-pl-pump.fact-qnty = ub.doc-pl-pump.fact-qnty + abs( t-gds.doc-qnty ).
          end.
          if not t-gds.pump > 0 then do:
            if t-gds.cashparts then do:
              define variable v-nonunique as integer no-undo .
              if lookup('2ед':U, t-gds.type) > 0 then do:
                FIND FIRST ub.doc-prts WHERE
                            ub.doc-prts.out-code = t-gds.doc-code
                        AND ub.doc-prts.gds-code = t-gds.gds-code  NO-ERROR.
                v-nonunique = if available ub.doc-prts then (ub.doc-prts.b-code - 1) else -1 .
              end.
              else v-nonunique = t-gds.b-code .
              FIND FIRST ub.doc-prts
                   WHERE ub.doc-prts.out-code = t-gds.doc-code
                     AND ub.doc-prts.b-code   = v-nonunique
                     AND ub.doc-prts.gds-code = t-gds.gds-code NO-ERROR.
                IF not avail ub.doc-prts THEN do:
                  create ub.doc-prts.
                  assign
                  ub.doc-prts.out-code = t-gds.doc-code
                  ub.doc-prts.gds-code = t-gds.gds-code
                  ub.doc-prts.b-code =  (if lookup('2ед':U, t-gds.type) > 0
                                      then v-nonunique
                                      else t-gds.b-code)
                  ub.doc-prts.doc-qnty = 0
                  ub.doc-prts.fact-qnty = 0
                  .
                end.
              assign
              ub.doc-prts.fact-qnty = ub.doc-prts.fact-qnty + abs( t-gds.doc-qnty ).
            END.
          end.
          assign
          v-created-dtl = no.
          if not v-created then do:
            FIND FIRST buf_gds-dtl WHERE buf_gds-dtl.doc-code  = buf_doc-line.doc-code
                                  and buf_gds-dtl.artic     = buf_doc-line.artic
                                  and buf_gds-dtl.prod-code = buf_doc-line.prod-code
                                  and buf_gds-dtl.prod-type = buf_doc-line.prod-type
                                  and buf_gds-dtl.prt-code  = t-gds.node-code NO-ERROR .
          end.
          if v-created or NOT available buf_gds-dtl then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input buf_doc-line.obj-code
   ,input buf_doc-line.obj-type
   ,input buf_doc-line.doc-code
   ,input buf_doc-line.artic
   ,input buf_doc-line.prod-code
   ,input buf_doc-line.prod-type
   ,input t-gds.node-code
   ,input no
  ) no-error .
            if error-status:error then do:
  run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Чек &1 Бар-код &2&3Ошибка при создании признака для товара с кодом &4:&3&5&6&3Чек не будет закачан в продажу"                                , X_chk-doc.doc-code                                           , t-gds.b-code                                                 , chr(10)                                                , t-gds.gds-code                                               , error-status:get-message(1)                                  , return-value                                                 )                                       ).
              UNDO _one-check, leave _one-check.
            end.
            assign
            v-created-dtl = yes
            .
            FIND FIRST buf_gds-dtl WHERE buf_gds-dtl.doc-code  = buf_doc-line.doc-code
                                and buf_gds-dtl.artic     = buf_doc-line.artic
                                and buf_gds-dtl.prod-code = buf_doc-line.prod-code
                                and buf_gds-dtl.prod-type = buf_doc-line.prod-type
                                and buf_gds-dtl.prt-code  = t-gds.node-code.
            assign
            buf_gds-dtl.discnt-type = no
            buf_gds-dtl.discnt-base = 0
            buf_gds-dtl.fact-qnty = 0
            buf_gds-dtl.doc-qnty = 0
            buf_gds-dtl.ov = yes.
          end.
          if Not (t-gds.fbr-obj-type = "":U and t-gds.fbr-obj-code = 0)
          and Not (t-gds.fbr-obj-type = ? and t-gds.fbr-obj-code = ?)
          then do:
            if t-gds.doc-qnty < 0
            then do :
              v-doc-code_fbr = replace(t-gds.doc-code, "=", "-") .
            end.
            else do :
              v-doc-code_fbr = t-gds.doc-code .
            end.
            FIND FIRST ub.doc-fbr-gds WHERE ub.doc-fbr-gds.out-code = v-doc-code_fbr AND
                                    ub.doc-fbr-gds.gds-code = t-gds.gds-code AND
                                    ub.doc-fbr-gds.fbr-obj-type = t-gds.fbr-obj-type AND
                                    ub.doc-fbr-gds.fbr-obj-code = t-gds.fbr-obj-code AND
                                    ub.doc-fbr-gds.obj-type = p-obj-type AND
                                    ub.doc-fbr-gds.obj-code = p-obj-code
                                    NO-ERROR.
            IF not avail ub.doc-fbr-gds THEN do:
              create ub.doc-fbr-gds.
              assign
              ub.doc-fbr-gds.obj-type = p-obj-type
              ub.doc-fbr-gds.obj-code = p-obj-code
              ub.doc-fbr-gds.out-code = v-doc-code_fbr
              ub.doc-fbr-gds.gds-code = t-gds.gds-code
              ub.doc-fbr-gds.fbr-obj-type = t-gds.fbr-obj-type
              ub.doc-fbr-gds.fbr-obj-code = t-gds.fbr-obj-code
              ub.doc-fbr-gds.doc-qnty = 0
              ub.doc-fbr-gds.fact-qnty = 0
              .
            end.
            assign
            ub.doc-fbr-gds.fact-qnty = ub.doc-fbr-gds.fact-qnty +  t-gds.doc-qnty .
          end.
      define variable v-discnt-r-b like ub.gds-dtl.discnt-rubl no-undo .
  define variable v-price-r-b like ub.gds-dtl.price-rubl no-undo .
          assign
          v-discnt-r-b = (if (buf_gds-dtl.fact-qnty + abs(t-gds.doc-qnty)) = 0
                          then 0
                          else (if prcl-spl
                                  then
                                  (t-gds.new-price * (buf_gds-dtl.fact-qnty + abs(t-gds.doc-qnty))
                                  - ((if v-curr-r-b = 'base':U then buf_gds-dtl.price-base else buf_gds-dtl.price-rubl) - (if v-curr-r-b = 'base':U then buf_gds-dtl.discnt-base else buf_gds-dtl.discnt-rubl)) * buf_gds-dtl.fact-qnty
                                  - buf_sale-doc.msign * (t-gds.price-sum - t-gds.discnt-sum)
                                  ) / (buf_gds-dtl.fact-qnty + abs(t-gds.doc-qnty))
                                  else
                                  (t-gds.price-base * (buf_gds-dtl.fact-qnty + abs(t-gds.doc-qnty))
                                  - ((if v-curr-r-b = 'base':U then buf_gds-dtl.price-base else buf_gds-dtl.price-rubl) - (if v-curr-r-b = 'base':U then buf_gds-dtl.discnt-base else buf_gds-dtl.discnt-rubl)) * buf_gds-dtl.fact-qnty
                                  - buf_sale-doc.msign * (t-gds.price-sum - t-gds.discnt-sum)
                                  ) / (buf_gds-dtl.fact-qnty + abs(t-gds.doc-qnty))
                                )
                          )
          buf_gds-dtl.fact-qnty = buf_gds-dtl.fact-qnty + abs( t-gds.doc-qnty )
          v-price-r-b =  (if prcl-spl then  t-gds.new-price  else t-gds.price-base )
          buf_gds-dtl.price-base = (if v-curr-r-b = 'rubl':U
                                then  v-price-r-b / trn-doc.base-rate * trn-doc.base-scale
                                else v-price-r-b)
          buf_gds-dtl.discnt-base = (if v-curr-r-b = 'rubl':U
                                  then v-discnt-r-b / trn-doc.base-rate * trn-doc.base-scale
                                  else v-discnt-r-b )
          buf_gds-dtl.price-rubl = (if v-curr-r-b = 'base':U
                                then v-price-r-b * trn-doc.base-rate / trn-doc.base-scale
                                else v-price-r-b)
          buf_gds-dtl.discnt-rubl = (if v-curr-r-b = 'base':U
                                then v-discnt-r-b  * trn-doc.base-rate / trn-doc.base-scale
                                else v-discnt-r-b )
          buf_doc-line.road-tax = (if road
                              then
                              (buf_doc-line.road-tax * (buf_doc-line.fact-qnty - abs(t-gds.doc-qnty) ) +
                                buf_sale-doc.msign * t-gds.road-sum ) / (buf_doc-line.fact-qnty )
                              else 0)
          buf_doc-line.excise = (if road
                            then
                            t-gds.excise
                            else 0)
          buf_gds-dtl.discnt-pc = (if t-gds.is-modificator then 0 else buf_gds-dtl.discnt-pc)
          .
          if X_chk-doc.doc-code <> buf_sale-doc.chk-doc-code
          AND buf_sale-doc.main-receipt-type = X_chk-doc.chk-type
          then do:
            assign
            buf_sale-doc.chk-doc-code = X_chk-doc.doc-code
            buf_sale-doc.chk-amount = buf_sale-doc.chk-amount + 1
            .
          end.
          assign
          buf_sale-doc.tot-lines = buf_sale-doc.tot-lines + (if v-created then 1 else 0)
          line-out = line-out + (if buf_sale-doc.doc-kind = 'es':U
                                 and v-created
                                 then 1
                                 else 0)
          line-ret = line-ret + (if buf_sale-doc.doc-kind = 'rs':U
                                 and v-created
                                 then 1
                                 else 0)
          buf_sale-doc.tot-dtl = buf_sale-doc.tot-dtl + (if v-created-dtl then 1 else 0)
          dtl-out = dtl-out + (if buf_sale-doc.doc-kind = 'es':U
                               and v-created-dtl
                               then 1
                               else 0)
          dtl-ret = dtl-ret + (if buf_sale-doc.doc-kind = 'rs':U
                               and v-created-dtl
                               then 1
                               else 0)
          buf_sale-doc.gds-amount = buf_sale-doc.gds-amount + t-gds.num-lines
          buf_sale-doc.fact-qnty = buf_sale-doc.fact-qnty  + t-gds.doc-qnty * buf_sale-doc.msign.
        END .
        var-doc-type = '':U.
        if kind-to-reserv begins 'es':U then do:
          var-doc-type =  'при':U.
        end.
        if kind-to-reserv begins 'rs':U or v-cash-pay-attr <> "" then do:
          var-doc-type =  'рас':U .
        end.
        FOR  EACH buf_chk-pay WHERE buf_chk-pay.doc-code = X_chk-doc.doc-code
        BREAK
        BY buf_chk-pay.doc-code
        BY buf_chk-pay.pay-code
        BY buf_chk-pay.curr-code :
          if var-doc-type <> '':U
          or (X_chk-doc.chk-type <> integer('7':U)
              and
              lookup(string(X_chk-doc.chk-type), '2,3,4,5,7':U) > 0
              )
          then do:
            find first buf_inkas-pay-wth where
                      buf_inkas-pay-wth.inkas-code = ink-doc.inkas-code
                  and buf_inkas-pay-wth.pay-code = buf_chk-pay.pay-code
                  and buf_inkas-pay-wth.curr-code = buf_chk-pay.curr-code
                  and buf_inkas-pay-wth.wth-code = buf_chk-pay.wth-code
                  and buf_inkas-pay-wth.par-code = buf_chk-pay.par-code
                  and buf_inkas-pay-wth.pay-desk = X_chk-doc.pay-desk
                  and buf_inkas-pay-wth.cashier = X_chk-doc.cashier
                  and buf_inkas-pay-wth.chk-type = X_chk-doc.chk-type no-error.
            if not available  buf_inkas-pay-wth then do:
              create buf_inkas-pay-wth.
              assign
              buf_inkas-pay-wth.inkas-code = ink-doc.inkas-code
              buf_inkas-pay-wth.pay-code = buf_chk-pay.pay-code
              buf_inkas-pay-wth.curr-code = buf_chk-pay.curr-code
              buf_inkas-pay-wth.wth-code = buf_chk-pay.wth-code
              buf_inkas-pay-wth.par-code = buf_chk-pay.par-code
              buf_inkas-pay-wth.pay-desk = X_chk-doc.pay-desk
              buf_inkas-pay-wth.cashier = X_chk-doc.cashier
              buf_inkas-pay-wth.chk-type = X_chk-doc.chk-type
              buf_inkas-pay-wth.par-val = buf_chk-pay.par-val
              .
            end.
            assign
            buf_inkas-pay-wth.tot-sum = buf_inkas-pay-wth.tot-sum + buf_chk-pay.tot-sum
            buf_inkas-pay-wth.tot-base = buf_inkas-pay-wth.tot-base + buf_chk-pay.tot-base
            buf_inkas-pay-wth.tot-rubl = buf_inkas-pay-wth.tot-rubl + buf_chk-pay.tot-rubl
            buf_inkas-pay-wth.doc-qnty = buf_inkas-pay-wth.doc-qnty + buf_chk-pay.doc-qnty
            buf_inkas-pay-wth.tot-lines = buf_inkas-pay-wth.tot-lines + 1
            .
          end.
          IF FIRST-OF(buf_chk-pay.curr-code) then do:
            assign
            accum-chk-pay-tot-sum-by = 0
            accum-chk-pay-tot-base-by = 0
            accum-chk-pay-tot-rubl-by = 0
            .
          end.
          assign
          accum-chk-pay-tot-sum-by = accum-chk-pay-tot-sum-by + buf_chk-pay.tot-sum
          accum-chk-pay-tot-base-by = accum-chk-pay-tot-base-by + buf_chk-pay.tot-base
          accum-chk-pay-tot-rubl-by = accum-chk-pay-tot-rubl-by + buf_chk-pay.tot-rubl
          .
          buf_chk-pay.out-code = ink-doc.inkas-code .
          if last-of( buf_chk-pay.curr-code ) then  do:
            FIND FIRST buf_inkas-pay WHERE
                        buf_inkas-pay.inkas-code = ink-doc.inkas-code AND
                        buf_inkas-pay.pay-code = buf_chk-pay.pay-code AND
                        buf_inkas-pay.curr-code = buf_chk-pay.curr-code NO-ERROR.
            if NOT available buf_inkas-pay then do:
              CREATE buf_inkas-pay.
              assign
              buf_inkas-pay.inkas-code = ink-doc.inkas-code
              buf_inkas-pay.pay-code = buf_chk-pay.pay-code
              buf_inkas-pay.curr-code = buf_chk-pay.curr-code
              buf_inkas-pay.tot-sum = 0
              buf_inkas-pay.tot-base = 0
              buf_inkas-pay.tot-rubl = 0
              .
            end.
            if var-doc-type <> '':U then do:
              FIND FIRST buf_inkas-pay-desk WHERE
                          buf_inkas-pay-desk.inkas-code = ink-doc.inkas-code AND
                          buf_inkas-pay-desk.pay-code = buf_chk-pay.pay-code AND
                          buf_inkas-pay-desk.curr-code = buf_chk-pay.curr-code AND
                          buf_inkas-pay-desk.pay-desk = X_chk-doc.pay-desk AND
                          buf_inkas-pay-desk.doc-type = var-doc-type AND
                          buf_inkas-pay-desk.cashier = X_chk-doc.cashier
                          NO-ERROR.
              if NOT available buf_inkas-pay-desk then do:
                CREATE buf_inkas-pay-desk.
                assign
                buf_inkas-pay-desk.inkas-code = ink-doc.inkas-code
                buf_inkas-pay-desk.pay-code = buf_chk-pay.pay-code
                buf_inkas-pay-desk.curr-code = buf_chk-pay.curr-code
                buf_inkas-pay-desk.pay-desk = X_chk-doc.pay-desk
                buf_inkas-pay-desk.tot-sum = 0
                buf_inkas-pay-desk.tot-base = 0
                buf_inkas-pay-desk.tot-rubl = 0
                buf_inkas-pay-desk.doc-type = var-doc-type
                buf_inkas-pay-desk.cashier = X_chk-doc.cashier
                .
              end.
              assign
              buf_inkas-pay.tot-sum = buf_inkas-pay.tot-sum + accum-chk-pay-tot-sum-by
              buf_inkas-pay.tot-base = buf_inkas-pay.tot-base + accum-chk-pay-tot-base-by
              buf_inkas-pay.tot-rubl = buf_inkas-pay.tot-rubl + accum-chk-pay-tot-rubl-by
              buf_inkas-pay-desk.tot-sum = buf_inkas-pay-desk.tot-sum + accum-chk-pay-tot-sum-by
              buf_inkas-pay-desk.tot-base = buf_inkas-pay-desk.tot-base + accum-chk-pay-tot-base-by
              buf_inkas-pay-desk.tot-rubl = buf_inkas-pay-desk.tot-rubl + accum-chk-pay-tot-rubl-by
              .
            end.
          end.
        END.
        FOR EACH buf_chk-discnt where
                  buf_chk-discnt.doc-code = X_chk-doc.doc-code
        on error undo _one-check, leave _one-check:
          assign
          buf_chk-discnt.out-code = ink-doc.inkas-code
          .
        end.
      end.
     if X_chk-doc.chk-type = integer('12':U)
     or X_chk-doc.chk-type = integer('43':U)
     or X_chk-doc.chk-type = integer('44':U)
     then do:
        for each buf_chk-pay where
               buf_chk-pay.doc-code = X_chk-doc.doc-code
         on error undo c-d, NEXT c-d:
           buf_chk-pay.out-code = ink-doc.inkas-code .
        end.
      end.
      for each buf_c-chk-doc where
              buf_c-chk-doc.doc-code = X_chk-doc.doc-code
      on error undo c-d, NEXT c-d:
        assign
        buf_c-chk-doc.out-code = ink-doc.inkas-code
        .
      end.
      for each buf_c-chk-gds where
              buf_c-chk-gds.doc-code = X_chk-doc.doc-code
      on error undo c-d, NEXT c-d:
        assign
        buf_c-chk-gds.out-code = ink-doc.inkas-code
        .
      end.
      for each buf_c-chk-discnt where
              buf_c-chk-discnt.doc-code = X_chk-doc.doc-code
      on error undo c-d, NEXT c-d:
        assign
        buf_c-chk-discnt.out-code = ink-doc.inkas-code
        .
      end.
      for each buf_c-chk-pay where
              buf_c-chk-pay.doc-code = X_chk-doc.doc-code
      on error undo c-d, NEXT c-d:
        assign
        buf_c-chk-pay.out-code = ink-doc.inkas-code
        .
      end.
      for each buf_c-chk-doc-attr where
              buf_c-chk-doc-attr.doc-code = X_chk-doc.doc-code
      on error undo c-d, NEXT c-d:
        assign
        buf_c-chk-doc-attr.out-code = ink-doc.inkas-code
        .
      end.
      for each buf_chk-gds-pay where
              buf_chk-gds-pay.doc-code = X_chk-doc.doc-code
      on error undo c-d, NEXT c-d:
        assign
        buf_chk-gds-pay.out-code = ink-doc.inkas-code
        .
      end.
      X_chk-doc.out-code = ink-doc.inkas-code.
      if pay-gds-algo <> '' then do:
        if lookup(string(X_chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then do:
        end.
        else do:
          run r-pychk0 in this-procedure ( input ub.sysconf.base-code
                                          ,input X_chk-doc.doc-code) no-error.
          if error-status:error then do:
              run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Чек &1 возникла ошибка при формировании распределения платежей. Чек не будет закачан в продажу&2&3"                                    , X_chk-doc.doc-code                                               , chr(10)                                                    , return-value                                                     )                                       ) .
              undo _one-check, leave _one-check.
          end.
        end.
      end.
      assign
      chk-amount = chk-amount + 1
      nf-chk-amount = nf-chk-amount + add-nf-amount
      nff-chk-amount = nff-chk-amount + (if lookup(string(X_chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then 1 else 0)
      .
      if X_chk-doc.chk-type <> integer('43':U) and X_chk-doc.chk-type <> integer('44':U)
      then
      assign
      accum-chk-doc-tot-doc = accum-chk-doc-tot-doc  + X_chk-doc.tot-doc
      accum-chk-doc-discnt = accum-chk-doc-discnt + X_chk-doc.discnt
      accum-chk-doc-netto = accum-chk-doc-netto + X_chk-doc.netto
      accum-chk-doc-sub-discnt = accum-chk-doc-sub-discnt + X_chk-doc.sub-discnt
      .
      if p-ii < 10
      or (p-ii < 1000 and chk-amount modulo 10 = 0)
      or (p-ii < 10000 and chk-amount modulo 100 = 0)
      then
      run display-ink-doc in p-call-handle(
                                            input gds-amount
                                           ,input nf-gds-amount
                                           ,input line-out
                                           ,input line-ret
                                           ,input dtl-out
                                           ,input dtl-ret
                                            ).
      assign
      p-ii-ok = p-ii-ok + 1
      .
    end.
  END.
  assign
  ink-doc.tot-doc = ink-doc.tot-doc + accum-chk-doc-tot-doc
  ink-doc.discnt = ink-doc.discnt + accum-chk-doc-discnt
  ink-doc.netto = ink-doc.netto + accum-chk-doc-netto
  ink-doc.sub-discnt = ink-doc.sub-discnt + accum-chk-doc-sub-discnt
  ink-doc.num-chk = chk-amount
  ink-doc.num-chk-nf = nf-chk-amount
  ink-doc.num-chk-nff = nff-chk-amount
  .
  assign
  ink-doc.qnty = 0
  .
  for each buf_sale-doc where
           buf_sale-doc.inkas-code = ink-doc.inkas-code
       and buf_sale-doc.order > 0,
      first dop_trn-doc where dop_trn-doc.doc-code = buf_sale-doc.doc-code:
    assign
    dop_trn-doc.fact-qnty = buf_sale-doc.fact-qnty
    dop_trn-doc.tot-lines = buf_sale-doc.tot-lines
    buf_sale-doc.filled = buf_sale-doc.tot-lines <> 0 or buf_sale-doc.fact-qnty <> 0
    .
    dop_trn-doc.ps = set-sale-doc-ps(buffer buf_sale-doc)
    .
    if buf_sale-doc.in-inkas then
    assign
    ink-doc.qnty = ink-doc.qnty + buf_sale-doc.fact-qnty * (if lookup(buf_sale-doc.ext-doc-type, 'vt,vp,rs':U) > 0 then - 1 else 1)
    .
  END.
  assign
  ink-doc.PS = set-inkas-ps (
                          input ink-doc.ps
                        , input chk-amount
                        , input gds-amount
                        , input line-out
                        , input dtl-out
                        , input line-ret
                        , input dtl-ret
                        , input nf-chk-amount
                        , input nf-gds-amount
                        , input p-filter-rus
                        ).
    for each buf_sale-doc where
            buf_sale-doc.inkas-code = ink-doc.inkas-code,
      first dop_trn-doc where dop_trn-doc.doc-code = buf_sale-doc.doc-code:
    if buf_sale-doc.ext-doc-type <> 'es':U
    and not can-find(first buf_doc-line no-lock where
                    buf_doc-line.doc-code = dop_trn-doc.doc-code) then do:
      assign
      dop_trn-doc.status_ = 'накл':U
      dop_trn-doc.flag_ = no.
      run str/del-doc.p (
          input parparentproc,
          input  buf_sale-doc.doc-code,
          input  g#db-num,
          input  "del-doc.err",
          input  ?,
          input  ?,
          input  g#userid,
          input  '0',
          input  varchip-code,
          output varchip-code2)
          no-error.
      if error-status:error then do:
        assign
        v-mes =  substitute("Ошибка при удалении ПУСТОГО документа &1 для продажи &2&3:&3&4&3&5"
                                , buf_sale-doc.doc-code
                                , ink-doc.inkas-code
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value ).
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input v-mes                                       ) .
        next .
      end.
      else do:
        delete buf_sale-doc.
      end.
    end.
  end.
  if can-find(first buf_doc-line no-lock where
                  buf_doc-line.doc-code = trn-doc.doc-code)
  and
  not (old-doc-date = new-doc-date
        AND
        old-shift-date = new-shift-date
        AND
        old-shift-num  = new-shift-num) then do:
    _tpsi_sale-doc:
    for each tpsi_sale-doc where
            tpsi_sale-doc.inkas-code = ink-doc.inkas-code
        and tpsi_sale-doc.tpsidoc = yes,
      first buf_trn-doc EXCLUSIVE-LOCK where
          buf_trn-doc.doc-code = tpsi_sale-doc.doc-code
    on error undo, return error
    :
      assign
      buf_trn-doc.status_ = 'накл':U
      buf_trn-doc.flag_ = no.
      run str/del-doc.p (
          input parparentproc,
          input  tpsi_sale-doc.doc-code,
          input  g#db-num,
          input  "del-doc.err",
          input  ?,
          input  ?,
          input  g#userid,
          input  '0',
          input  varchip-code,
          output varchip-code2)
          no-error.
      if error-status:error then do:
        assign
        v-mes =  substitute("Ошибка при удалении ПУСТОГО расходного документа ЧУЖИХ товаров &1 по объекту &2&3 для продажи &4 &5:&3&6 &7"
                                , tpsi_sale-doc.doc-code
                                , (tpsi_sale-doc.obj-type + string(tpsi_sale-doc.obj-code))
                                , chr(10)
                                , ink-doc.inkas-code
                                , (ink-doc.obj-type + string(ink-doc.obj-code))
                                , error-status:get-message(1)
                                , return-value ).
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input v-mes                                       ) .
        UNDO , return error.
      end.
      else do:
        delete tpsi_sale-doc.
      end.
    end.
    for each tt0-gds-dtl:
      delete tt0-gds-dtl.
    end.
    for each tt0-doc-line:
      delete tt0-doc-line.
    end.
  end.
  run display-chk in p-call-handle (chk-amount, nf-chk-amount).
  run display-ink-doc in p-call-handle(
                                         input gds-amount
                                        ,input nf-gds-amount
                                        ,input line-out
                                        ,input line-ret
                                        ,input dtl-out
                                        ,input dtl-ret
                                        ).
end.
end procedure.
PROCEDURE Get-tpsi-params :
define input  parameter p-obj-type like ub.clients.obj-type no-undo.
define input  parameter p-obj-code like ub.clients.obj-code no-undo.
define output parameter p-is-tpsi-obj as logical no-undo .
define output parameter p-tpsi-mode as integer no-undo .
define output parameter p-main-tpsi as logical no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
run gbl/tpsi-obj.p (
                input p-obj-type
              , input p-obj-code
              , output p-is-tpsi-obj) no-error .
if p-is-tpsi-obj then do:
  run adm/shattri.p (
      input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'autosale':U
    ,input  "":U
    , output v-value-character
    , output v-value-date
    , output v-value-decimal
    , output v-value-integer
    , output v-value-logical
    , output v-param-type
    , INPUT-OUTPUT table-handle v-tth
    ) no-error .
  IF error-status:error then do:
     message
     substitute("Ошибка при получении опций продажи НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , p-obj-type
              , p-obj-code
              , chr(10)
              , error-status:get-message(1)
              , return-value )
     view-as alert-box error .
     undo, return error .
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-obj-type
        and thbjattr_thbj-attr.obj-code = p-obj-code
        and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
        and thbjattr_thbj-attr.prop-code = 'tpsi-mode':U no-error.
  if available thbjattr_thbj-attr then do:
    p-tpsi-mode = thbjattr_thbj-attr.property-value-integer.
  end.
  if p-tpsi-mode = 2 then do:
    find first thbjattr_thbj-attr where
              thbjattr_thbj-attr.obj-type = p-obj-type
          and thbjattr_thbj-attr.obj-code = p-obj-code
          and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
          and thbjattr_thbj-attr.prop-code = 'main-tpsi':U no-error.
    if available thbjattr_thbj-attr then do:
      p-main-tpsi = thbjattr_thbj-attr.property-value-logical.
    end.
  end.
end.
END PROCEDURE.
if v-input-error = yes then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , v-esm
                         , return-value
                         )).
  assign
  v-view-log = yes.
  if p-auto = 0 then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе закачки чеков в продажу произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action23   as character no-undo .
  define variable v-printed23       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе закачки чеков в продажу произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'saleincl.log')
    ,input  7
    ,output v-user-action23
    ,output v-printed23
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'saleincl.log').
end.
                        return "error":U.                  end.
end.
assign
p-call-handle = this-procedure .
find first ink-doc exclusive-lock where
            ink-doc.inkas-code = p-inkas-code no-error no-wait.
if NOT available ink-doc
and not locked ink-doc
then do:
  return error substitute("Не найден отчет о продаже №&1", p-inkas-code).
end.
if locked ink-doc then do:
  if p-auto < 2 then
  return error substitute("Отчет о продаже №&1 занят", p-inkas-code).
  else do:
    return "":U.
  end.
end.
FIND FIRST trn-doc WHERE trn-doc.doc-code = ink-doc.inkas-code exclusive.
assign
p-obj-type = ink-doc.obj-type
p-obj-code = ink-doc.obj-code
.
if (p-auto < 2
and not (ink-doc.status_ = 'новый':U
          or
          ink-doc.status_ = 'нередакт':U ))
then do:
  return error substitute("Отчет о продаже №&1 имеет статус &2", ink-doc.inkas-code, ink-doc.status_).
end.
if p-auto >= 2
and ink-doc.status_ <> 'новый':U
and trn-doc.flag_ <> no
then do:
  return "":U.
end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  'маг':U
  ,input  ink-doc.obj-code
  ,output v-db-num
  )  .
if v-db-num <> g#db-num then do:
  return error substitute("Отчет о продаже №&1 относится к магазину БД &2, текущая БД &3"
                          , ink-doc.inkas-code
                          , v-db-num
                          , g#db-num
                          ).
end.
find first buf_sysconf where
          buf_sysconf.host-code = ink-doc.host-code no-lock.
if not available buf_sysconf then do:
  return error substitute("Не найдена запись о фирме &1", ink-doc.host-code).
end.
run get-inkas-ps in this-procedure (
                                    buffer ink-doc
                                  , output chk-amount
                                  , output gds-amount
                                  , output line-out
                                  , output dtl-out
                                  , output line-ret
                                  , output dtl-ret
                                  , output nf-chk-amount
                                  , output nf-gds-amount
                                  , output v-dop-where-rus
                                  ).
  assign
  ink-doc.PS = set-inkas-ps-simple (
                          input chk-amount
                        , input gds-amount
                        , input line-out
                        , input dtl-out
                        , input line-ret
                        , input dtl-ret
                        , input nf-chk-amount
                        , input nf-gds-amount
                        )
  .
assign
old-doc-date   =  ink-doc.doc-date
old-shift-date =  ink-doc.shift-date
old-shift-num  =  ink-doc.shift-num
new-doc-date   =  ink-doc.doc-date
new-shift-date =  ink-doc.shift-date
new-shift-num  =  ink-doc.shift-num
ink-doc.is-auto-get = (p-auto >= 2)
.
if p-filter-on
or (p-auto >= 2 and (ink-doc.sale-filter <> '':U
                     and ink-doc.sale-filter <> ?)
    )
then do:
  assign
  v-filter-name = ink-doc.sale-filter-name
  v-where-phrase = ink-doc.sale-filter
  p-filter-rus = ink-doc.sale-filter-rus
  .
end.
if one-curs then do:
  assign
  cursh = trn-doc.exch-rate
  cursh-scale = trn-doc.exch-scale
  .
end.
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Обработка продажи &1............"                                                      , p-inkas-code)                                       ).
if cas-shft then do:
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Закачиваются чеки с датой продажи(учета) &1 по смене &2"                                                      , string(old-shift-date, "99/99/9999")                                                                         , old-shift-num)                                       ).
end.
else do:
  if p-day-only then do:
        run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Закачиваются чеки с датой продажи(учета) &1"                                                          , string(old-shift-date, "99/99/9999"))                                       ).
  end.
  else do:
    if p-filter-on then do:
            run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Закачиваются чеки с любой датой продажи(учета)"                                                            )                                       ).
    end.
    else do:
            run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Закачиваются чеки с датой продажи(учета) <= &1"                                                            , string(old-shift-date, "99/99/9999"))                                       ).
    end.
  end.
end.
if p-filter-on then do:
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Закачиваются ТОЛЬКО чеки удовлятворяющие фильтру:&1&2"                                                        , chr(10)                                                                                                , p-filter-rus)                                       ).
end.
ASSIGN
v-query-prepare = substitute("for each X_chk-doc no-lock where ":U +
                          "X_chk-doc.obj-type = '&1'":U +
                          " AND X_chk-doc.obj-code = &2":U +
                          " AND X_chk-doc.out-code = ? ", ink-doc.obj-type, ink-doc.obj-code).
if cas-shft then do:
  ASSIGN
  v-query-prepare = v-query-prepare +
                  substitute(" AND X_chk-doc.shift-date = &1 AND X_chk-doc.shift-num = &2"
                            , string(ink-doc.shift-date, "99/99/9999")
                            , ink-doc.shift-num).
end.
else do:
    if p-day-only then do:
        ASSIGN
        v-query-prepare = v-query-prepare +
                        substitute(" AND X_chk-doc.shift-date = &1", string(ink-doc.shift-date, "99/99/9999")).
                        .
    end.
    else do:
        ASSIGN
        v-query-prepare = v-query-prepare +
                        substitute(" AND X_chk-doc.shift-date <= &1", string(ink-doc.shift-date, "99/99/9999")).
    end.
end.
assign
glog =
QUERY query-chk-doc:QUERY-PREPARE(v-query-prepare + v-where-phrase) No-error.
IF not glog THEN DO:
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Ошибка - неверно выбран или построен ФИЛЬТР:&1&2&1 &3"                            , chr(10)                                                                    , (v-query-prepare + v-where-phrase)                                               , error-status:get-message(1))                                       ).
  UNDO, RETURN ERROR.
END.
assign
glog = QUERY query-chk-doc:query-OPEN() NO-ERROR.
IF not glog THEN DO:
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Ошибка - неверно выбран или построен ФИЛЬТР:&1&2&1 &3"                             , chr(10)                                                                     , (v-query-prepare + v-where-phrase)                                                , error-status:get-message(1))                                       ).
  UNDO, RETURN ERROR.
END.
ASSIGN
glog = QUERY query-chk-doc:GET-FIRST(no-lock) NO-ERROR.
IF not glog THEN DO:
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Нет чеков, удовлетворяющих условиям закачки в продажу &1"                            , p-inkas-code)                                       ).
  assign
  v-no-check = yes
  .
END.
ASSIGN
glog = QUERY query-chk-doc:GET-FIRST(exclusive-LOCK, no-wait) NO-ERROR.
do while locked (X_chk-doc ) and available X_chk-doc:
    p-ii = p-ii + 1.
    glog = QUERY query-chk-doc:GET-NEXT(exclusive-LOCK, no-wait) NO-ERROR.
end.
if not v-no-check then do:
if one-curs then do:
  run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Закачиваются ТОЛЬКО чеки с курсом баз.вал. = &1"                                                        , string(trn-doc.exch-rate / trn-doc.exch-scale, ">>,>>9.9999"))                                       ).
end.
end.
end.
if not v-no-check then do:
  run proc-main in this-procedure ( input trn-doc.status_) no-error .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Ошибка при закачке чеков в продажу &1 &2&3:&4&5 &6"
                          , p-inkas-code
                          , (if p-obj-type <> "":U then p-obj-type else "":U)
                          , (if p-obj-code <> 0 then string(p-obj-code) else "":U)
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value
                          )).
    assign
    v-view-log = yes.
    if p-auto = 0 then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе закачки чеков в продажу произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action26   as character no-undo .
  define variable v-printed26       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе закачки чеков в продажу произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'saleincl.log')
    ,input  7
    ,output v-user-action26
    ,output v-printed26
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'saleincl.log').
end.
                        return "error":U.                  end.
  end.
  else do:
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Просмотрено &1 чеков, успешно закачано в продажу &2", p-ii, p-ii-ok)                                       ).
  end.
end.
if p-auto = 3 then do:
  run str/salestat.p (
                     input parparentproc
                    ,input p-inkas-code
                    ,input '<закрытие документа>':U
                    ,input 'новый':U
                    ,input yes
                    ,input yes ) no-error .
  if not error-status:error then do:
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Продажа &1 помечена как готовая к резервированию", p-inkas-code)                                       ).
  end.
  else do:
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("!!!Ошибка при переводе статуса продажи:&1&2 &3"                  , chr(10)                                                               , error-status:get-message(1)                                                 , return-value )                                       ).
  end.
end.
procedure display-chk :
DEFINE INPUT PARAMETER p-chk-amount AS INTEGER NO-UNDO.
define input parameter p-nf-chk-amount as integer no-undo .
  do
  on error undo, return error
  :
run write-counter in p-log-handle (input substitute("Чеков &1 (&7) Строк &2 Расход: товаров &3 признаков &4 Возврат: товаров &5 признаков &6"                                    , p-chk-amount                                                                                                               , gds-amount                                                                                                                , line-out                                                                                                                  , dtl-out                                                                                                                   , line-ret                                                                                                                  , dtl-ret                                                                                                                   , p-nf-chk-amount)).
  end.
end procedure.
PROCEDURE display-ink-doc :
define input parameter p-gds-amount  as integer no-undo .
define input parameter p-nf-gds-amount  as integer no-undo .
define input parameter p-line-out    as integer no-undo .
define input parameter p-line-ret    as integer no-undo .
define input parameter p-dtl-out     as integer no-undo .
define input parameter p-dtl-ret     as integer no-undo .
run write-counter in p-log-handle (input substitute("Чеков &1 Строк &2 (&7) Расход: товаров &3 признаков &4 Возврат: товаров &5 признаков &6"                                    , chk-amount                                                                                                                  , p-gds-amount                                                                                                                , p-line-out                                                                                                                  , p-dtl-out                                                                                                                   , p-line-ret                                                                                                                  , p-dtl-ret                                                                                                                   , p-nf-gds-amount)).
END PROCEDURE.
