block-level on error undo, throw.
define parameter buffer p-bf_trn-doc for ub.trn-doc .
define input  parameter p-curr-obj-type as character no-undo .
define input  parameter p-curr-obj-code as integer   no-undo .
define input  parameter p-action as character no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: trn-hist.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/trn-hist.p $":U .
define variable vss-description as character no-undo initial "«апись истории по документу":U .
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
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дн€" ] .
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
  return "ƒата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
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
define variable vss-include-info1 as character no-undo format "x(65)":U initial "@(#)$Workfile$ $Revision$":U.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure valid-ren-art-tbl-list :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-std-list        as character no-undo .
    define variable v-ignore-list     as character no-undo .
    define variable v-special-list    as character no-undo .
    assign
      v-std-list     = "cli-gds,cli-gds-attr,cli-art,cli-art-attr,contract-specif,c-contract-specif,doc-line,c-doc-line,fbr-line,c-fbr-line,fbr-recipe,fbr-recipe-gds,fbr-pln-line,c-fbr-pln-line,gds-dtl,c-gds-dtl,gds-dtl-attr,c-gds-dtl-attr,gds-obj,inv-line,inv-line-attr,c-inv-line,ot-supp-line,ot-supp-line-attr,ot-line-attr,ord-line,c-ord-line,ord-line-rcv,ord-dtl,c-ord-dtl,ord-dtl-attr,ord-dtl-rcv,ord-dtl-cons,ord-gds-cons,prt-obj,prt-obj-attr,parts,c-parts,parts-supp,parts-supp-attr,price-list,c-price-list,price-doc-forming-gds,c-price-doc-forming-gds,price-doc-forming-gds-qnty,c-price-doc-forming-gds-qnty,price-doc-forming-gds-sum,c-price-doc-forming-gds-sum,price-doc-forming-gds-tnv,c-price-doc-forming-gds-tnv,recipe,recipe-gds,c-recipe,c-recipe-gds,c-recipe-hist,stk-supp-line,stk-supp-line-attr,stk-line-attr,tmp-sale-dtl,tmp-sale-dtl-attr,tmp-sale-gds,tmp-sale-gds-attr":U
      v-ignore-list  = "c-goods,c-order-line":U
      v-special-list = "goods,ot-line,stk-line,order-line":U
    .
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-inform      as character no-undo .
    define variable bh_tbl-name   as handle    no-undo .
    define variable v-tbl-not-idx as character no-undo .
    define variable v-idx-avail   as logical   no-undo .
    define variable new-tbl-list  as character no-undo .
    define variable old-tbl-list  as character no-undo .
    define variable old-tbl-avail as logical   no-undo .
    define variable v-double-tbl  as character no-undo .
    define variable v-tbl-name    as character no-undo .
    define variable v-msg         as character no-undo .
    assign
      v-msg         = "":U
      v-tbl-not-idx = "":U
      new-tbl-list  = "":U
    .
    for each ub._Field no-lock
      where ub._Field._Field-Name = 'artic':U
    ,first ub._File of ub._Field
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      if  lookup( ub._File._File-Name, v-std-list     ) = 0
      and lookup( ub._File._File-Name, v-ignore-list  ) = 0
      and lookup( ub._File._File-Name, v-special-list ) = 0
      then do:
        assign
          new-tbl-list = new-tbl-list + chr(10) + ub._File._File-Name
        .
      end.
      if lookup( ub._File._File-Name, v-std-list ) <> 0
        or lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0
      then do:
        create buffer bh_tbl-name for table substitute( "ub.&1":U, ub._File._File-Name ) .
        assign
          v-idx-avail = false
          v-inform    = bh_tbl-name:index-information(1)
          v-ind       = 2
        .
        block_chk-idx:
        do while v-inform <> ?
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if v-inform <> ?
              and lookup( entry( 5, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
              and lookup( entry( 7, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
              and lookup( entry( 9, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
          then do:
            assign
              v-idx-avail = true
            .
            leave block_chk-idx.
          end.
          assign
            v-inform = bh_tbl-name:index-information( v-ind )
            v-ind    = v-ind + 1
          .
        end.
        if v-idx-avail = false then do:
          if lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0 then do:
            assign
              new-tbl-list = new-tbl-list + " (индекса нет)"
            .
          end.
          else do:
            assign
              v-tbl-not-idx = v-tbl-not-idx + chr(10) + ub._File._File-Name
            .
          end.
        end.
        delete object bh_tbl-name.
      end.
    end.
    assign
      old-tbl-list  = "":U
      v-double-tbl  = "":U
      v-num-entries = num-entries( v-std-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name    = entry( v-ind, v-std-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'artic':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-type"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-code"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > v-ind
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-ignore-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-ignore-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'artic':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-type"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-code"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > v-ind
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-special-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-special-list )
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if available ub._File then do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'artic':U
          no-error .
      end.
      if not available ub._File
        or ( available ub._File
             and not available ub._Field
           )
      then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > v-ind
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    if v-tbl-not-idx <> "" then do:
      assign
        v-msg = v-msg + substitute( "“аблицы не имеют индекса с пол€ми &3 на первом месте и нет спецобработки: &2&1&1", chr(10), v-tbl-not-idx, 'artic, prod-type, prod-code':U )
      .
    end.
    if new-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "Ќет обработки таблиц: &2&1&1", chr(10), new-tbl-list )
      .
    end.
    if v-double-tbl <> "":U then do:
      assign
        v-msg = v-msg + substitute( "¬ списках есть задублированные таблицы: &2&1&1", chr(10), v-double-tbl )
      .
    end.
    if old-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "¬ списках есть несуществующие таблицы или таблицы в которых отсутствуют переименовываемые пол€: &2&1&1", chr(10), old-tbl-list )
      .
    end.
    if v-msg <> "":U then do:
      return error substitute( "”тилита переименовани€ &3 не корректна.&1&1&2", chr(10), v-msg, 'artic, prod-type, prod-code':U ) .
    end.
  end.
end procedure.
procedure check-use-artic :
  define input  parameter p-tbl-name  as   character                      no-undo .
  define input  parameter p-artic     like ub.goods.artic     no-undo .
  define input  parameter p-prod-type like ub.goods.prod-type no-undo .
  define input  parameter p-prod-code like ub.goods.prod-code no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop",   vss-include-info1 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info1 )
  :
    define buffer buf_goods for ub.goods .
    if lookup( p-tbl-name, "c-goods,c-order-line":U ) = 0 then do:
      find first buf_goods no-lock
        where buf_goods.artic     = p-artic
          and buf_goods.prod-type = p-prod-type
          and buf_goods.prod-code = p-prod-code
        no-error .
      if not available buf_goods then do:
        return error substitute( "&1 (check-use-artic). Ќе найден товар с артикулом &2 и производителем &3 &4", vss-include-info1, p-artic, p-prod-type, p-prod-code ) .
      end.
      if buf_goods.stts = integer('51':U) then do:
        return error substitute( "&1 (check-use-artic). Ќельз€ использовать товар с артикулом &2 и производителем &3 &4&5"
                                + "¬ыполн€етс€ переименование артикула и(или) производител€"
                                ,vss-include-info1
                                ,p-artic
                                ,p-prod-type
                                ,p-prod-code
                                ,chr(10)
                              ) .
      end.
    end.
    return .
  end.
end procedure.
define variable j-chip-num as integer no-undo .
define buffer bf_goods         for ub.goods         .
define variable l-shift-on as logical no-undo .
define variable p-shift-date as date      no-undo initial ? .
define variable p-shift-num  as integer   no-undo initial 0 .
define variable p-shift-name as character no-undo initial ? .
define variable v-today as date      no-undo .
define variable v-time  as integer   no-undo .
define variable v-result-field as character no-undo .
Main-Block:
do
transaction
on error   undo Main-Block, return error return-value
on end-key undo Main-Block, return error return-value
on stop    undo Main-Block, return error return-value
:
  assign
    j-chip-num = next-value( s-corr-chip, ub )
  .
  find first ub.c-trn-doc no-lock where
             ub.c-trn-doc.doc-code         = p-bf_trn-doc.doc-code and
             ub.c-trn-doc.corr-user-db-num = g#db-num and
             ub.c-trn-doc.chip-num         = j-chip-num
             no-error .
  if not available ub.c-trn-doc
  then do:
    create ub.c-trn-doc .
    buffer-copy p-bf_trn-doc to ub.c-trn-doc no-error .
    if error-status :error
    then do:
      undo Main-Block, return error .
    end.
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
  if l-shift-on = true then do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output p-shift-date
  ,output p-shift-num
  ,output p-shift-name
  ) no-error .
    end.
    assign
      ub.c-trn-doc.chip-num  = j-chip-num
      ub.c-trn-doc.corr-date = v-today
      ub.c-trn-doc.corr-time = v-time
      ub.c-trn-doc.corr-user-name  = g#userid
      ub.c-trn-doc.corr-user-db-num = g#db-num
      ub.c-trn-doc.action = p-action
      ub.c-trn-doc.corr-shift-date = p-shift-date
      ub.c-trn-doc.corr-shift-name = p-shift-name
      ub.c-trn-doc.corr-shift-num  = p-shift-num
      .
  end.
define buffer bf_trn-doc-sum    for ub.trn-doc-sum   .
define buffer old_c-trn-doc-sum for ub.c-trn-doc-sum  .
  for each bf_trn-doc-sum no-lock where
           bf_trn-doc-sum.doc-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-trn-doc-sum no-lock where
               old_c-trn-doc-sum.doc-code = bf_trn-doc-sum.doc-code and
               old_c-trn-doc-sum.corr-user-db-num = g#db-num and
               old_c-trn-doc-sum.sum-type = bf_trn-doc-sum.sum-type  and
               old_c-trn-doc-sum.chip-num <= j-chip-num
               no-error .
    if available old_c-trn-doc-sum then do:
        v-result-field = "" .
        buffer-compare ub.c-trn-doc-sum
          except chip-num
                 corr-date
                 corr-time
                 corr-user-db-num
                 corr-user-name
          to  bf_trn-doc-sum
          save result in v-result-field no-error  .
    end.
    if not available old_c-trn-doc-sum  or v-result-field <> ""
    then do:
      create ub.c-trn-doc-sum .
      buffer-copy bf_trn-doc-sum to ub.c-trn-doc-sum .
      assign
        ub.c-trn-doc-sum.chip-num         = j-chip-num
        ub.c-trn-doc-sum.corr-user-db-num = g#db-num
        .
    end.
  end.
define buffer bf_doc-line    for ub.doc-line    .
define buffer old_c-doc-line for ub.c-doc-line  .
  for each bf_doc-line no-lock where
           bf_doc-line.doc-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-doc-line no-lock where
               old_c-doc-line.doc-code         = bf_doc-line.doc-code   and
               old_c-doc-line.artic            = bf_doc-line.artic      and
               old_c-doc-line.prod-type        = bf_doc-line.prod-type  and
               old_c-doc-line.prod-code        = bf_doc-line.prod-code  and
               old_c-doc-line.corr-user-db-num = g#db-num               and
               old_c-doc-line.chip-num        <= j-chip-num
               no-error .
    if available old_c-doc-line then do:
        v-result-field = "" .
        buffer-compare ub.c-doc-line
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_doc-line
          save result in v-result-field no-error  .
    end.
    if not available old_c-doc-line  or v-result-field <> ""
    then do:
      create ub.c-doc-line .
      buffer-copy bf_doc-line to ub.c-doc-line .
      assign
        ub.c-doc-line.chip-num         = j-chip-num
        ub.c-doc-line.corr-user-db-num = g#db-num
        .
    end.
  end.
define buffer bf_inv-line    for ub.inv-line    .
define buffer old_c-inv-line for ub.c-inv-line  .
  for each bf_inv-line no-lock where
           bf_inv-line.doc-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-inv-line no-lock where
               old_c-inv-line.doc-code         = bf_inv-line.doc-code   and
               old_c-inv-line.artic            = bf_inv-line.artic      and
               old_c-inv-line.prod-type        = bf_inv-line.prod-type  and
               old_c-inv-line.prod-code        = bf_inv-line.prod-code  and
               old_c-inv-line.corr-user-db-num = g#db-num               and
               old_c-inv-line.chip-num        <= j-chip-num
               no-error .
    if available old_c-inv-line then do:
        v-result-field = "" .
        buffer-compare ub.c-inv-line
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_inv-line
          save result in v-result-field no-error  .
    end.
    if not available old_c-inv-line  or v-result-field <> ""
    then do:
      create ub.c-inv-line .
      buffer-copy bf_inv-line to ub.c-inv-line .
      assign
        ub.c-inv-line.chip-num         = j-chip-num
        ub.c-inv-line.corr-user-db-num = g#db-num
        .
    end.
  end.
define buffer bf_gds-dtl       for ub.gds-dtl       .
define buffer old_c-gds-dtl for ub.c-gds-dtl  .
  for each bf_gds-dtl no-lock where
           bf_gds-dtl.doc-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-gds-dtl no-lock where
               old_c-gds-dtl.doc-code         = bf_gds-dtl.doc-code   and
               old_c-gds-dtl.artic            = bf_gds-dtl.artic      and
               old_c-gds-dtl.prod-type        = bf_gds-dtl.prod-type  and
               old_c-gds-dtl.prod-code        = bf_gds-dtl.prod-code  and
               old_c-gds-dtl.prt-code         = bf_gds-dtl.prt-code   and
               old_c-gds-dtl.corr-user-db-num = g#db-num              and
               old_c-gds-dtl.chip-num        <= j-chip-num
               no-error .
    if available old_c-gds-dtl then do:
        v-result-field = "" .
        buffer-compare ub.c-gds-dtl
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_gds-dtl
          save result in v-result-field no-error  .
    end.
    if not available old_c-gds-dtl  or v-result-field <> ""
    then do:
      create ub.c-gds-dtl .
      buffer-copy bf_gds-dtl to ub.c-gds-dtl .
      assign
        ub.c-gds-dtl.chip-num         = j-chip-num
        ub.c-gds-dtl.corr-user-db-num = g#db-num
        .
    end.
  end.
define buffer bf_parts         for ub.parts         .
define buffer old_c-parts for ub.c-parts  .
define buffer bf_parts-attr    for ub.parts-attr    .
define buffer old_c-parts-attr for ub.c-parts-attr  .
  for each bf_parts no-lock where
           bf_parts.out-code = p-bf_trn-doc.doc-code
  :
  find first bf_goods no-lock where
             bf_goods.artic     = bf_parts.artic and
             bf_goods.prod-type = bf_parts.prod-type and
             bf_goods.prod-code = bf_parts.prod-code no-error .
    find last  old_c-parts no-lock where
               old_c-parts.out-code         = bf_parts.out-code   and
               old_c-parts.corr-user-db-num = g#db-num              and
               old_c-parts.chip-num        <= j-chip-num
               no-error .
    if available old_c-parts then do:
        v-result-field = "" .
        buffer-compare ub.c-parts
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_parts
          save result in v-result-field no-error  .
    end.
    if not available old_c-parts  or v-result-field <> ""
    then do:
      create ub.c-parts .
      buffer-copy bf_parts to ub.c-parts .
      assign
        ub.c-parts.chip-num         = j-chip-num
        ub.c-parts.corr-user-db-num = g#db-num
        .
    end.
        if available bf_goods then do:
              for each bf_parts-attr no-lock where
                      bf_parts-attr.in-code   = bf_parts.in-code and
                      bf_parts-attr.part-code = bf_parts.part-code and
                      bf_parts-attr.gds-code  = bf_goods.gds-code
              :
                find last  old_c-parts-attr no-lock where
                          old_c-parts-attr.in-code           = bf_parts-attr.in-code   and
                          old_c-parts-attr.part-code         = bf_parts-attr.part-code and
                          old_c-parts-attr.gds-code          = bf_parts-attr.gds-code  and
                          old_c-parts-attr.corr-user-db-num  = g#db-num                and
                          old_c-parts-attr.chip-num         <= j-chip-num
                          no-error .
                if available old_c-parts-attr then do:
                    v-result-field = "" .
                    buffer-compare ub.c-parts-attr
                      except chip-num
                            corr-date
                            corr-time
                            corr-user-name
                            corr-user-db-num
                      to  bf_parts-attr
                      save result in v-result-field no-error  .
                end.
                if not available old_c-parts-attr  or v-result-field <> ""
                then do:
                  create ub.c-parts-attr .
                  buffer-copy bf_parts-attr to ub.c-parts-attr .
                  assign
                    ub.c-parts-attr.chip-num         = j-chip-num
                    ub.c-parts-attr.corr-user-db-num = g#db-num
                    .
                end.
              end.
        end.
  end.
define buffer bf_doc-pl    for ub.doc-pl    .
define buffer old_c-doc-pl for ub.c-doc-pl  .
  for each bf_doc-pl no-lock where
           bf_doc-pl.out-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-doc-pl no-lock where
               old_c-doc-pl.out-code         = bf_doc-pl.out-code and
               old_c-doc-pl.pl-code          = bf_doc-pl.pl-code  and
               old_c-doc-pl.obj-type         = bf_doc-pl.obj-type and
               old_c-doc-pl.obj-code         = bf_doc-pl.obj-code and
               old_c-doc-pl.gds-code         = bf_doc-pl.gds-code and
               old_c-doc-pl.corr-user-db-num = g#db-num           and
               old_c-doc-pl.chip-num        <= j-chip-num
               no-error .
    if available old_c-doc-pl then do:
        v-result-field = "" .
        buffer-compare ub.c-doc-pl
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_doc-pl
          save result in v-result-field no-error  .
    end.
    if not available old_c-doc-pl  or v-result-field <> ""
    then do:
      create ub.c-doc-pl .
      buffer-copy bf_doc-pl to ub.c-doc-pl .
      assign
        ub.c-doc-pl.chip-num         = j-chip-num
        ub.c-doc-pl.corr-user-db-num = g#db-num
        .
    end.
  end.
define buffer bf_doc-pl-pump   for ub.doc-pl-pump   .
define buffer old_c-doc-pl-pump for ub.c-doc-pl-pump  .
  for each bf_doc-pl-pump no-lock where
           bf_doc-pl-pump.out-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-doc-pl-pump no-lock where
               old_c-doc-pl-pump.out-code         = bf_doc-pl-pump.out-code and
               old_c-doc-pl-pump.pump-code        = bf_doc-pl-pump.pump-code  and
               old_c-doc-pl-pump.pl-code          = bf_doc-pl-pump.pl-code  and
               old_c-doc-pl-pump.obj-type         = bf_doc-pl-pump.obj-type and
               old_c-doc-pl-pump.obj-code         = bf_doc-pl-pump.obj-code and
               old_c-doc-pl-pump.gds-code         = bf_doc-pl-pump.gds-code and
               old_c-doc-pl-pump.corr-user-db-num = g#db-num           and
               old_c-doc-pl-pump.chip-num        <= j-chip-num
               no-error .
    if available old_c-doc-pl-pump then do:
        v-result-field = "" .
        buffer-compare ub.c-doc-pl-pump
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_doc-pl-pump
          save result in v-result-field no-error  .
    end.
    if not available old_c-doc-pl-pump  or v-result-field <> ""
    then do:
      create ub.c-doc-pl-pump .
      buffer-copy bf_doc-pl-pump to ub.c-doc-pl-pump .
      assign
        ub.c-doc-pl-pump.chip-num         = j-chip-num
        ub.c-doc-pl-pump.corr-user-db-num = g#db-num
        .
    end.
  end.
define buffer bf_rvs-doc          for ub.rvs-doc .
define buffer old_c-rvs-doc       for ub.c-rvs-doc .
define buffer bf_rvs-line         for ub.rvs-line .
define buffer old_c-rvs-line      for ub.c-rvs-line .
define buffer bf_rvs-line-pump    for ub.rvs-line-pump .
define buffer old_c-rvs-line-pump for ub.c-rvs-line-pump  .
  for each bf_rvs-doc no-lock where
           bf_rvs-doc.out-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-rvs-doc no-lock where
               old_c-rvs-doc.rvs-code         = bf_rvs-doc.rvs-code and
               old_c-rvs-doc.corr-user-db-num = g#db-num           and
               old_c-rvs-doc.chip-num        <= j-chip-num
               no-error .
    if available old_c-rvs-doc then do:
        v-result-field = "" .
        buffer-compare ub.c-rvs-doc
          except chip-num
                 corr-date
                 corr-time
                 out-code
                 corr-user-name
                 corr-user-db-num
          to  bf_rvs-doc
          save result in v-result-field no-error  .
    end.
    if not available old_c-rvs-doc  or v-result-field <> ""
    then do:
      create ub.c-rvs-doc .
      buffer-copy bf_rvs-doc to ub.c-rvs-doc .
      assign
        ub.c-rvs-doc.chip-num         = j-chip-num
        ub.c-rvs-doc.corr-user-db-num = g#db-num
        .
    end.
          for each bf_rvs-line no-lock where
                   bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code
          :
           find last  old_c-rvs-line no-lock where
                      old_c-rvs-line.rvs-code         = bf_rvs-line.rvs-code and
                      old_c-rvs-line.obj-type         = bf_rvs-line.obj-type and
                      old_c-rvs-line.obj-code         = bf_rvs-line.obj-code and
                      old_c-rvs-line.pl-code          = bf_rvs-line.pl-code and
                      old_c-rvs-line.gds-code         = bf_rvs-line.gds-code and
                      old_c-rvs-line.corr-user-db-num = g#db-num           and
                      old_c-rvs-line.chip-num        <= j-chip-num
                      no-error .
            if available old_c-rvs-line then do:
                v-result-field = "" .
                buffer-compare ub.c-rvs-line
                  except chip-num
                        corr-user-db-num
                  to  bf_rvs-line
                  save result in v-result-field no-error  .
            end.
            if not available old_c-rvs-line  or v-result-field <> ""
            then do:
              create ub.c-rvs-line .
              buffer-copy bf_rvs-line to ub.c-rvs-line .
              assign
                ub.c-rvs-line.chip-num         = j-chip-num
                ub.c-rvs-line.corr-user-db-num = g#db-num
                .
            end.
          end.
          for each bf_rvs-line-pump no-lock where
                   bf_rvs-line-pump.rvs-code = bf_rvs-doc.rvs-code
          :
           find last  old_c-rvs-line-pump no-lock where
                      old_c-rvs-line-pump.rvs-code         = bf_rvs-line-pump.rvs-code and
                      old_c-rvs-line-pump.obj-type         = bf_rvs-line-pump.obj-type and
                      old_c-rvs-line-pump.obj-code         = bf_rvs-line-pump.obj-code and
                      old_c-rvs-line-pump.pl-code          = bf_rvs-line-pump.pl-code and
                      old_c-rvs-line-pump.gds-code         = bf_rvs-line-pump.gds-code and
                      old_c-rvs-line-pump.pump-code        = bf_rvs-line-pump.pump-code and
                      old_c-rvs-line-pump.nozzle-code      = bf_rvs-line-pump.nozzle-code and
                      old_c-rvs-line-pump.corr-user-db-num = g#db-num           and
                      old_c-rvs-line-pump.chip-num        <= j-chip-num
                      no-error .
            if available old_c-rvs-line then do:
                v-result-field = "" .
                buffer-compare ub.c-rvs-line-pump
                  except chip-num
                        corr-user-db-num
                  to  bf_rvs-line
                  save result in v-result-field no-error  .
            end.
            if not available old_c-rvs-line-pump  or v-result-field <> ""
            then do:
              create ub.c-rvs-line-pump .
              buffer-copy bf_rvs-line-pump to ub.c-rvs-line-pump .
              assign
                ub.c-rvs-line-pump.chip-num         = j-chip-num
                ub.c-rvs-line-pump.corr-user-db-num = g#db-num
                .
            end.
          end.
  end.
define buffer bf_doc-attr      for ub.doc-attr      .
define buffer old_c-doc-attr for ub.c-doc-attr  .
  for each bf_doc-attr no-lock where
           bf_doc-attr.doc-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-doc-attr no-lock where
               old_c-doc-attr.doc-code         = bf_doc-attr.doc-code   and
               old_c-doc-attr.attr-code        = bf_doc-attr.attr-code  and
               old_c-doc-attr.corr-user-db-num = g#db-num               and
               old_c-doc-attr.chip-num        <= j-chip-num
               no-error .
    if available old_c-doc-attr then do:
        v-result-field = "" .
        buffer-compare ub.c-doc-attr
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_doc-attr
          save result in v-result-field no-error  .
    end.
    if not available old_c-doc-attr  or v-result-field <> ""
    then do:
      create ub.c-doc-attr .
      buffer-copy bf_doc-attr to ub.c-doc-attr .
      assign
        ub.c-doc-attr.chip-num         = j-chip-num
        ub.c-doc-attr.corr-user-db-num = g#db-num
        .
    end.
  end.
define buffer bf_doc-line-sum  for ub.doc-line-sum  .
define buffer old_c-doc-line-sum for ub.c-doc-line-sum  .
  for each bf_doc-line-sum no-lock where
           bf_doc-line-sum.doc-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-doc-line-sum no-lock where
               old_c-doc-line-sum.doc-code         = bf_doc-line-sum.doc-code  and
               old_c-doc-line-sum.gds-code         = bf_doc-line-sum.gds-code  and
               old_c-doc-line-sum.sum-type         = bf_doc-line-sum.sum-type  and
               old_c-doc-line-sum.corr-user-db-num = g#db-num                  and
               old_c-doc-line-sum.chip-num        <= j-chip-num
               no-error .
    if available old_c-doc-line-sum then do:
        v-result-field = "" .
        buffer-compare ub.c-doc-line-sum
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_doc-line-sum
          save result in v-result-field no-error  .
    end.
    if not available old_c-doc-line-sum  or v-result-field <> ""
    then do:
      create ub.c-doc-line-sum .
      buffer-copy bf_doc-line-sum to ub.c-doc-line-sum .
      assign
        ub.c-doc-line-sum.chip-num         = j-chip-num
        ub.c-doc-line-sum.corr-user-db-num = g#db-num
        .
    end.
  end.
define buffer bf_doc-line-attr for ub.doc-line-attr .
define buffer old_c-doc-line-attr for ub.c-doc-line-attr  .
  for each bf_doc-line-attr no-lock where
           bf_doc-line-attr.doc-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-doc-line-attr no-lock where
               old_c-doc-line-attr.doc-code         = bf_doc-line-attr.doc-code   and
               old_c-doc-line-attr.gds-code         = bf_doc-line-attr.gds-code  and
               old_c-doc-line-attr.attr-code        = bf_doc-line-attr.attr-code  and
               old_c-doc-line-attr.corr-user-db-num = g#db-num               and
               old_c-doc-line-attr.chip-num        <= j-chip-num
               no-error .
    if available old_c-doc-line-attr then do:
        v-result-field = "" .
        buffer-compare ub.c-doc-line-attr
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_doc-line-attr
          save result in v-result-field no-error  .
    end.
    if not available old_c-doc-line-attr  or v-result-field <> ""
    then do:
      create ub.c-doc-line-attr .
      buffer-copy bf_doc-line-attr to ub.c-doc-line-attr .
      assign
        ub.c-doc-line-attr.chip-num         = j-chip-num
        ub.c-doc-line-attr.corr-user-db-num = g#db-num
        .
    end.
  end.
end.
