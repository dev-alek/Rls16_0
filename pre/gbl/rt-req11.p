block-level on error undo, throw.
define input  parameter parparentproc   as widget-handle no-undo .
define input  parameter p-directory-out as character no-undo .
define input  parameter p-file-name     as character no-undo .
define input  parameter p-session-valid as logical   no-undo .
define input  parameter p-error-message as character no-undo .
define input  parameter p-user-login    as character no-undo .
define input  parameter p-obj-type      as character no-undo .
define input  parameter p-obj-code      as character no-undo .
define input  parameter p-host-code     as character no-undo .
define input  parameter p-doc-type      as character no-undo .
define input  parameter p-doc-code      as character no-undo .
define input  parameter p-close-status  as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req11.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req11.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 11. Редактирование фактических количеств. Завершить ввод накладной".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
procedure integerm :
  define input  parameter p-string      as character no-undo .
  define input  parameter p-allow-sign  as logical   no-undo .
  define input  parameter p-allow-comma as logical   no-undo .
  define output parameter p-value       as integer   no-undo .
  define output parameter p-data-valid  as logical   no-undo .
  define output parameter p-message     as character no-undo .
  define variable v-replace-string as character no-undo .
  do
  on error undo, return error return-value
  :
    if p-string = ?
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = "Ошибка задания входных параметров. Не задана строка для преобразования"
      .
      return .
    end.
    if p-string = ""
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = "Ошибка задания входных параметров. Задана пустая строка для преобразования"
      .
      return .
    end.
    assign
      p-value = integer(p-string) no-error
    .
    if error-status :error = true
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'"
                                 ,p-string
                                 )
      .
      return .
    end.
    if index(p-string, ' ':u) > 0
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Строка содержит символы пробела"
                                 ,p-string
                                 )
      .
      return .
    end.
    assign
      v-replace-string = p-string
      v-replace-string = replace(v-replace-string, '0':u, '9':u)
      v-replace-string = replace(v-replace-string, '1':u, '9':u)
      v-replace-string = replace(v-replace-string, '2':u, '9':u)
      v-replace-string = replace(v-replace-string, '3':u, '9':u)
      v-replace-string = replace(v-replace-string, '4':u, '9':u)
      v-replace-string = replace(v-replace-string, '5':u, '9':u)
      v-replace-string = replace(v-replace-string, '6':u, '9':u)
      v-replace-string = replace(v-replace-string, '7':u, '9':u)
      v-replace-string = replace(v-replace-string, '8':u, '9':u)
    .
    if p-allow-sign = true
    then do:
      if index('+-':u, substring(v-replace-string, 1, 1)) > 0
      then do:
        assign
          v-replace-string = substring(v-replace-string, 2)
        .
      end.
    end.
    else do:
      if substring(v-replace-string, 1, 1) = '+':u
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака челого числа. "
                                  + "Строка содержит символ плюс. "
                                  ,p-string
                                  )
        .
        return .
      end.
      if substring(v-replace-string, 1, 1) = '-':u
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака челого числа. "
                                  + "Строка содержит символ минус. "
                                  ,p-string
                                  )
        .
        return .
      end.
    end.
    if p-allow-comma = true
    then do:
      assign
        v-replace-string = replace(v-replace-string, ',', '')
      .
    end.
    else do:
      if index(v-replace-string, ',') > 0
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака разделителя тысяч."
                                  + "Строка содержит знак разделителя тысяч. "
                                  ,p-string
                                  )
        .
        return .
      end.
    end.
    if index(p-string, '.') > 0
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Строка содержит знак десятичной точки"
                                 ,p-string
                                 )
      .
      return .
    end.
    if v-replace-string <> fill('9', length(v-replace-string))
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Встречены символы, недопустимые для целого числа '&2'"
                                 ,p-string
                                 ,replace(v-replace-string, '9', '')
                                 )
      .
      return .
    end.
    assign
      p-data-valid = true
      p-message    = ""
    .
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function rtencode returns character
  ( p-init-string as character
  ) :
  define variable v-encode-string as character no-undo .
  if p-init-string = ?
  then do:
    assign
      v-encode-string = '?':u
    .
    return v-encode-string .
  end.
  if p-init-string = '?':u
  then do:
    assign
      v-encode-string = '~~077':u
    .
    return v-encode-string .
  end.
  assign
    v-encode-string = replace(p-init-string,   '~~':u,      '~~176':u)
    v-encode-string = replace(v-encode-string, ':':u,       '~~072':u)
    v-encode-string = replace(v-encode-string, chr(10), '~~015':u)
  .
  return v-encode-string .
end function .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-rt-cntxt_parparentproc  as handle    no-undo .
define variable v-rt-cntxt_proc-signature as character no-undo .
procedure rt-cntxt_setcntxt :
  define input parameter p-cntxt-db-num        as integer   no-undo .
  define input parameter p-cntxt-user-id       as character no-undo .
  define input parameter p-cntxt-level         as character no-undo .
  define input parameter p-cntxt-host-code-obj as integer   no-undo .
  define input parameter p-cntxt-obj-type      as character no-undo .
  define input parameter p-cntxt-obj-code      as integer   no-undo .
  define input parameter p-cntxt-db-num-obj    as integer   no-undo .
  define input parameter p-cntxt-is-admin      as logical   no-undo .
do
on error undo, return error return-value
:
  run w-reqsrv_setcntxt in parparentproc
    ( input p-cntxt-db-num
    , input p-cntxt-user-id
    , input p-cntxt-level
    , input p-cntxt-host-code-obj
    , input p-cntxt-obj-type
    , input p-cntxt-obj-code
    , input p-cntxt-db-num-obj
    , input p-cntxt-is-admin
    ) .
end.
end procedure.
procedure rt-cntxt_clrcntxt :
do
on error undo, return error return-value
:
  run w-reqsrv_clrcntxt in parparentproc .
end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure rt-cnvdc_decode :
  define input  parameter p-encoded-str as character no-undo .
  define output parameter p-decoded-str as character no-undo .
do
on error undo, return error return-value
:
  define variable v-decoded-str as character no-undo .
  assign
    v-decoded-str = replace(p-encoded-str,  'c':u, 'с':u )
    v-decoded-str = replace(v-decoded-str,  'm':u, 'м':u )
    p-decoded-str = v-decoded-str
  .
end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure strtdate :
  define input  parameter p-str         as character no-undo .
  define output parameter p-value       as date      no-undo .
  define output parameter p-data-valid  as logical   no-undo .
  define output parameter p-message     as character no-undo .
do
on error undo, return error return-value
:
  define variable v-value       as date      no-undo .
  define variable v-i           as integer   no-undo .
  define variable v-num         as integer   no-undo .
  define variable v-delim       as character no-undo .
  define variable v-delim-list  as character no-undo .
  define variable v-day         as integer   no-undo .
  define variable v-month       as integer   no-undo .
  define variable v-year        as integer   no-undo .
  define variable v-day-str     as character no-undo .
  define variable v-month-str   as character no-undo .
  define variable v-year-str    as character no-undo .
  assign
    p-value       = ?
    p-data-valid  = false
  .
  if p-str = ?
  then do:
    assign
      p-message = substitute("Ошибка задания входных параметров. Не задана строка для преобразования. " )
    .
    return .
  end.
  if p-str = ""
  then do:
    assign
      p-message = substitute("Ошибка задания входных параметров. Задана пустая строка для преобразования. " )
    .
    return .
  end.
  if length(p-str)  > 10
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверная длина строки. " )
    .
    return .
  end.
  assign
    v-delim-list = '/,-,.':U
  .
  _delim:
  do v-i = 1 to num-entries( v-delim-list )
  :
    assign
      v-delim = entry( v-i , v-delim-list )
      v-num   = num-entries( p-str , v-delim )
    .
    if v-num <> 3
    then do:
      assign
        v-delim = ''
      .
    end.
    else do:
      leave _delim.
    end.
  end.
  if v-delim = ''
  then do:
    assign
      p-message = substitute( "Ошибка при преобразовании к дате. Неправильный разделитель, либо ошибочное количество разделителей. " )
    .
    return .
  end.
  assign
    v-day-str   = entry( 1, p-str , v-delim)
    v-month-str = entry( 2, p-str , v-delim)
    v-year-str  = entry( 3, p-str , v-delim)
  .
  if  length(v-day-str) > 2   or
      length(v-day-str) < 1   or
      length(v-month-str) > 2 or
      length(v-month-str) < 1 or
      (
        length(v-year-str) <> 2 and
        length(v-year-str) <> 4
      )
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неправильное количество символов числа, месяца, либо года. " )
    .
    return .
  end.
  if length( v-year-str ) = 2
  then do:
    assign
      v-year-str = substring( string( year(today) ), 1 , 2 ) + v-year-str
    .
  end.
  assign
    v-day   = integer( v-day-str )
    v-month = integer( v-month-str)
    v-year  = integer( v-year-str)
  no-error .
  if error-status :error
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверный формат символов числа, месяца, либо года. " )
    .
    return .
  end.
  if v-day < 1  or
     v-day > 31 or
     v-month < 1 or
     v-month > 12 or
     v-year < 0   or
     v-year > 5000
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверный диапозон числа, месяца, года. " )
    .
    return .
  end.
  assign
    v-value = date( v-month, v-day, v-year )
  no-error .
  if error-status :error
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. &1. " , error-status :get-message(1))
    .
    return .
  end.
  assign
    p-value       = v-value
    p-data-valid  = true
  .
end.
end procedure.
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define stream sout .
define temp-table tt-doc-line-gds no-undo
  field artic     like ub.goods.artic
  field prod-type like ub.goods.prod-type
  field prod-code like ub.goods.prod-code
index pi
  artic
  prod-type
  prod-code
.
define variable v-status        as character no-undo .
define variable v-error-message as character no-undo .
define variable varrnd-znk      as integer   no-undo .
define variable v-chk-prs       as logical   no-undo .
define variable v-unique-doc-code as character no-undo .
define variable v-user-id    like ub.user-login.user-id  no-undo .
define new shared buffer   t-doc  for ub.trn-doc.
define buffer buf_trn-doc         for ub.trn-doc .
define buffer buf_ord-doc-rcv     for ub.ord-doc-rcv .
define buffer buf_batchprocess    for ub.batchprocess .
do
on error undo, return error return-value
:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl-glob':U
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
    if thbjattr_thbj-attr.prop-code = 'chk-prs' then v-chk-prs = thbjattr_thbj-attr.property-value-logical .
    if thbjattr_thbj-attr.prop-code = 'rnd-znk' then varrnd-znk = thbjattr_thbj-attr.property-value-integer .
end.
  if p-session-valid = true
  then do:
    run check-data in this-procedure
      (output  v-status
      ,output  v-error-message
      ) no-error .
    if error-status :error
    then do:
      undo, return error substitute("ошибка при вызове функции check-data. &1, &2"
                                  ,error-status :get-message(1)
                                  ,return-value
                                  ) .
    end.
  end.
  else do:
    assign
      v-status        = '1':u
      v-error-message = p-error-message
    .
  end.
  define variable v-temp-file-name as character no-undo .
  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .
  put stream sout unformatted substitute('status:&1', rtencode(v-status))
                              + chr(10) .
  put stream sout unformatted substitute('message:&1',rtencode(v-error-message))
                              + chr(10) .
  output stream sout close .
  os-delete value(p-directory-out + '/':u + p-file-name) .
  os-rename value(p-directory-out + '/':u + v-temp-file-name)
            value(p-directory-out + '/':u + p-file-name)
            .
end.
procedure check-data :
  define output parameter p-status        as character no-undo .
  define output parameter p-error-message as character no-undo .
  define buffer buf_clients    for ub.clients .
  define buffer buf_sysconf    for ub.sysconf .
  define buffer buf_sys-ctrl   for ub.sys-ctrl .
  define buffer buf_user-login for ub.user-login .
  define buffer buf_parts      for ub.parts .
  define buffer buf_gds-dtl    for ub.gds-dtl.
  define variable v-doc-attr        as character  no-undo .
  define variable v-car-time        as character  no-undo .
  define variable v-car-time-int    as integer   no-undo .
  define variable v-old-doc-code       like ub.doc-line.doc-code        no-undo .
  define variable v-old-artic          like ub.doc-line.artic           no-undo .
  define variable v-old-prod-type      like ub.doc-line.prod-type       no-undo .
  define variable v-old-prod-code      like ub.doc-line.prod-code       no-undo .
  define variable v-old-cli-qnty       like ub.doc-line.cli-qnty        no-undo .
  define variable v-old-unit-cli       like ub.doc-line.unit-cli        no-undo .
  define variable v-old-cli-base-rate  like ub.doc-line.cli-base-rate   no-undo .
  define variable v-old-price-cli      like ub.doc-line.price-cli       no-undo .
  define variable v-old-vat-pc         like ub.doc-line.vat-pc          no-undo .
  define variable v-old-slt-pc         like ub.doc-line.slt-pc          no-undo .
  define variable v-old-price-rubl     like ub.doc-line.price-rubl      no-undo .
  define variable v-old-road-tax       like ub.doc-line.road-tax        no-undo .
  define variable v-old-transport-rubl like ub.doc-line.transport-rubl  no-undo .
  define variable v-old-other-rubl     like ub.doc-line.other-rubl      no-undo .
  define variable v-old-doc-qnty       like ub.doc-line.doc-qnty        no-undo .
  define variable v-old-fact-qnty      like ub.doc-line.fact-qnty       no-undo .
  define variable v-old-prt-code       like ub.gds-dtl.prt-code         no-undo .
  define variable v-old-line-number    like ub.doc-line.line-num        no-undo .
  define variable v-node-code          as integer                       no-undo .
  do
  on error undo, return error return-value
  :
  find first buf_sys-ctrl no-lock .
    find first buf_user-login no-lock
      where buf_user-login.db-num     = buf_sys-ctrl.db-num
        and buf_user-login.status_    = 0
        and buf_user-login.user-login = p-user-login
      no-error .
    if not available buf_user-login
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Неизвестный пользователь &1"
                                    ,p-user-login
                                    )
      .
      return .
    end.
    assign
      v-user-id  = buf_user-login.user-id
    .
    define variable v-obj-code      as integer   no-undo .
    define variable v-data-valid    as logical   no-undo .
    define variable v-error-message as character no-undo .
    if p-obj-code = ""
    then do:
      assign
        p-status        = '1':u
        p-error-message = "Не задан код объекта"
      .
      return .
    end.
    run integerm in this-procedure
      (input  p-obj-code
      ,input  false
      ,input  false
      ,output v-obj-code
      ,output v-data-valid
      ,output v-error-message
      ) .
    if v-data-valid <> true
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Ошибка преобразования кода объекта &1. &2"
                                    ,p-obj-code
                                    ,v-error-message
                                    )
      .
      return .
    end.
    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if not available buf_clients
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Не найден объект &1 &2"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return .
    end.
    if  p-obj-type <> 'маг':U
    and p-obj-type <> 'скл':U
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Неправильный тип объекта &1 &2"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return .
    end.
    define variable v-host-code as integer   no-undo .
    run integerm in this-procedure
      (input  p-host-code
      ,input  false
      ,input  false
      ,output v-host-code
      ,output v-data-valid
      ,output v-error-message
      ) .
    if v-data-valid <> true
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Ошибка преобразования кода фирмы &1. &2"
                                    ,p-host-code
                                    ,v-error-message
                                    )
      .
      return .
    end.
    define variable v-obj-host-code as integer   no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,output v-obj-host-code
  )  .
    if v-host-code <> v-obj-host-code
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Заданный код фирмы &1 отличается от кода фирмы &2 объекта &3 &4."
                                    ,p-host-code
                                    ,v-obj-host-code
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
      .
      return .
    end.
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = v-host-code
      no-error .
    if not available buf_sysconf
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Не найдена фирма &1"
                                    ,v-host-code
                                    )
      .
      return .
    end.
    define variable v-search-doc-code as character no-undo .
    run rt-cnvdc_decode in this-procedure ( input   p-doc-code
                                          , output  v-search-doc-code
                                          ) .
    if lookup(p-close-status, 'накл+':u + chr(44) + 'факт':u ) = 0
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Неизвестный статус &1"
                                    ,p-close-status
                                    )
      .
      return .
    end.
    define variable v-object-available as logical   no-undo .
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  buf_sys-ctrl.db-num
  ,input  0
  ,input  buf_user-login.user-id
  ,input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,output v-object-available
  )  .
    if v-object-available <> true
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Пользователю не доступен объект &1 &2"
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
      .
      return .
    end.
    define variable v-valid-act   as logical   no-undo .
    if p-close-status = 'накл+':u
    then do:
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  buf_sys-ctrl.db-num
    ,input  buf_user-login.user-id
    ,input  0
    ,input  'actn_rt-edit-doc_close-doc':U
    ,input  'object':U
    ,input  v-host-code
    ,input  buf_clients.obj-type
    ,input  buf_clients.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-valid-act
    )  .
end.
    end.
    else do:
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  buf_sys-ctrl.db-num
    ,input  buf_user-login.user-id
    ,input  0
    ,input  'actn_rt-edit-doc_close-doc':U
    ,input  'object':U
    ,input  v-host-code
    ,input  buf_clients.obj-type
    ,input  buf_clients.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-valid-act
    )  .
end.
      if v-valid-act <> true
      then do:
        assign
          p-status        = '1':u
          p-error-message = return-value
        .
        return .
      end.
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  buf_sys-ctrl.db-num
    ,input  buf_user-login.user-id
    ,input  0
    ,input  'actn_rt-edit-doc_close-fact':U
    ,input  'object':U
    ,input  v-host-code
    ,input  buf_clients.obj-type
    ,input  buf_clients.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-valid-act
    )  .
end.
    end.
    if v-valid-act <> true
    then do:
      assign
        p-status        = '1':u
        p-error-message = return-value
      .
      return .
    end.
    run rt-cntxt_setcntxt in this-procedure ( input buf_sys-ctrl.db-num
                                            , input buf_user-login.user-id
                                            , input 'object':U
                                            , input v-obj-host-code
                                            , input buf_clients.obj-type
                                            , input buf_clients.obj-code
                                            , input buf_clients.db-num
                                            , input buf_user-login.user-administrator
                                            ) .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    case p-doc-type
    :
      when 'ПТ':u
      then do:
        main_block:
        do transaction
        on error undo main_block, return error return-value
        :
          find first buf_ord-doc-rcv exclusive-lock
            where buf_ord-doc-rcv.rcv-code = v-search-doc-code
            no-error .
          if not available buf_ord-doc-rcv
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Не найден документ &1"
                                          ,v-search-doc-code
                                          )
            .
            undo main_block, return .
          end.
          if buf_ord-doc-rcv.obj-type <> p-obj-type
          or buf_ord-doc-rcv.obj-code <> v-obj-code
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Документ &1 принадлежит объекту &2 &3. Текущий объект &4 &5"
                                          ,v-search-doc-code
                                          ,buf_ord-doc-rcv.obj-type
                                          ,buf_ord-doc-rcv.obj-code
                                          ,p-obj-type
                                          ,v-obj-code
                                          )
            .
            undo main_block, return .
          end.
          if buf_ord-doc-rcv.status_ <> 'поставка':U
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                          ,v-search-doc-code
                                          ,'поставка':U
                                          )
            .
            undo main_block, return .
          end.
          assign
            v-unique-doc-code = p-doc-type + '|':u + buf_ord-doc-rcv.rcv-code
          .
          run gbl/rt-doced.p
            (input  v-unique-doc-code
            ,input  buf_user-login.user-id
            ,input  '':u
            ,input  'check':u
            ,input "":U
            ,output p-status
            ,output p-error-message
            ) .
          if  p-status <> '1':u
          and p-status <> '2':u
          then do:
            assign
              p-status = '1':u
            .
            undo main_block, return .
          end.
        _ord-chain:
        for each ub.ord-chain no-lock where
                  ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                  ub.ord-chain.doc-type = 'rcv'                  and
                  ub.ord-chain.rel-doc-type = 'trn'
                  :
          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code
          no-error .
          if available buf_trn-doc then do:
            leave _ord-chain.
          end.
        end.
        if not available buf_trn-doc
        then do:
          run cus/ord-trn.p
            (input  parparentproc
            ,input  recid(buf_ord-doc-rcv)
            ,input  no).
        end.
        for each ub.ord-chain no-lock where
                  ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                  ub.ord-chain.doc-type = 'rcv'                  and
                  ub.ord-chain.rel-doc-type = 'trn'
                  :
          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code
            no-error .
          if not available buf_trn-doc
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Ошибка при создании складского документа по поставке &1"
                                          ,buf_ord-doc-rcv.rcv-code
                                          )
            .
            undo main_block, return .
          end.
          end.
          run ver-tot-cli no-error .
          run ver-ship-time (output v-car-time-int) no-error .
          if error-status :error
          then do:
            undo main_block , return.
          end.
          assign
            buf_ord-doc-rcv.fact-ship-time = v-car-time-int
          .
          run ver-bma (input v-obj-code )  no-error .
          if error-status :error
          then do:
            undo main_block , return.
          end.
          if buf_trn-doc.flag_ = false
          then do:
            define variable v-chg-inv as logical   no-undo .
            run str/trn-stat.p
              (input  parparentproc
              ,input this-procedure
              ,input  '<закрытие документа>':U
              ,input  buf_trn-doc.doc-code
              ,input  false
              ,input  buf_sys-ctrl.db-num
              ,input  ?
              ,input  ?
              ,input  ?
              ,input  ?
              ,input  false
              ,output v-chg-inv
              ,output table gds-list
              ) no-error .
            if error-status :error
            then do:
              assign
                p-status        = '1':u
                p-error-message = substitute("Ошибка при закрытии документа &1 &2 &3 &4"
                                            ,p-doc-type
                                            ,v-search-doc-code
                                            ,error-status :get-message(1)
                                            ,return-value
                                            )
              .
              undo main_block, return .
            end.
          end.
          define buffer buf_doc-line        for ub.doc-line  .
          define buffer buf_bar-code        for ub.bar-code .
          define buffer buf_goods           for ub.goods .
          define buffer buf_tt-doc-line-gds for tt-doc-line-gds .
          define variable v-b-code    as integer   no-undo .
          define variable v-set-qnty  as decimal   no-undo .
          define variable v-chg-qnty  as decimal   no-undo .
          define variable v-cost-base as decimal   no-undo .
          define variable v-cost-rubl as decimal   no-undo .
          empty temp-table buf_tt-doc-line-gds .
          _bp-line:
          for each buf_batchprocess exclusive-lock
            where buf_batchprocess.bp_type     = 'rt-line':U
              and buf_batchprocess.bp_status   = 'N':U
              and buf_batchprocess.charkey_one = v-unique-doc-code
          on error undo main_block, return error return-value
          :
            assign
              v-b-code   = buf_batchprocess.key#_one
              v-set-qnty = decimal(buf_batchprocess.bp_execsystime)
            .
            find first buf_bar-code no-lock
              where buf_bar-code.b-code = v-b-code
              no-error .
            if not available buf_bar-code
            then do:
              undo main_block, return error substitute( "Не найден бар-код с кодом &1"
                                                      , v-b-code
                                                      ) .
            end.
            find first buf_goods no-lock
              where buf_goods.gds-code = buf_bar-code.gds-code
              no-error .
            if not available buf_goods
            then do:
              undo main_block, return error substitute( "Не найден товар с кодом &1"
                                                      , buf_bar-code.gds-code
                                                      ) .
            end.
            find first buf_doc-line exclusive-lock
              where buf_doc-line.doc-code  = buf_trn-doc.doc-code
                and buf_doc-line.artic     = buf_goods.artic
                and buf_doc-line.prod-type = buf_goods.prod-type
                and buf_doc-line.prod-code = buf_goods.prod-code
              no-error .
            if not available buf_doc-line
            then do:
              next _bp-line.
            end.
            find first buf_tt-doc-line-gds
              where buf_tt-doc-line-gds.artic     = buf_doc-line.artic
                and buf_tt-doc-line-gds.prod-type = buf_doc-line.prod-type
                and buf_tt-doc-line-gds.prod-code = buf_doc-line.prod-code
            no-error .
            if not available buf_tt-doc-line-gds then do:
              create buf_tt-doc-line-gds.
              assign
                buf_tt-doc-line-gds.artic     = buf_doc-line.artic
                buf_tt-doc-line-gds.prod-type = buf_doc-line.prod-type
                buf_tt-doc-line-gds.prod-code = buf_doc-line.prod-code
              .
            end.
            define variable v-gds-code as integer   no-undo .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run doclicod in g#library
  (input  recid(buf_doc-line)
  ,output v-gds-code
  )  .
            define variable v-update-ok   as logical   no-undo .
            define variable v-err-message as character no-undo .
            find first t-doc exclusive-lock
              where rowid(t-doc) = rowid(buf_trn-doc)
            .
            run str/doclinfq.p
              (input  parparentproc
              ,buffer t-doc
              ,buffer buf_doc-line
              ,input  v-set-qnty
              ,output v-update-ok
              ,output v-err-message
              ) no-error .
            if error-status :error
            or v-update-ok = false
            then do:
              if error-status :error
              then do:
                undo main_block, return error substitute("Ошибка при вызове процедуры doclinfq.p. &1 &2"
                                                        ,error-status :get-message(1)
                                                        ,return-value
                                                        )
                .
              end.
              else do:
                undo main_block, return error substitute("Невозможно зарезервировать фактическое количество в документе &1 для товара &2 &3 &4. &5"
                                                        ,buf_doc-line.doc-code
                                                        ,buf_doc-line.artic
                                                        ,buf_doc-line.prod-type
                                                        ,buf_doc-line.prod-code
                                                        ,v-err-message
                                                        )
                .
              end.
            end.
            if buf_doc-line.fact-qnty <> v-set-qnty
            then do:
              undo main_block, return error substitute("Ошибка при резервировании строки документа &1 &2 &3 &4 &5 &6"
                                                      ,buf_doc-line.doc-code
                                                      ,buf_doc-line.artic
                                                      ,buf_doc-line.prod-type
                                                      ,buf_doc-line.prod-code
                                                      ,buf_bar-code.node-code
                                                      ,v-set-qnty
                                                      ) .
            end.
            run set-price-cli (buffer buf_doc-line) no-error .
            if error-status :error then do:
                assign
                  p-status        = '1'
                  p-error-message = substitute("Цены поставщика &1  для товара &2 &3 &4 &5 &6."
                                              ,buf_batchprocess.charkey_three
                                              ,buf_doc-line.artic
                                              ,buf_doc-line.prod-type
                                              ,buf_doc-line.prod-code
                                              ,return-value
                                              ,error-status :get-message(1)
                                              )
                .
                undo main_block, return .
            end.
            run set-srok-last-day ( buffer buf_doc-line ) no-error .
            if error-status :error then do:
               assign
                p-status        = '1'
                p-error-message = substitute(" Срок годности &1 &2" , return-value , error-status :get-message(1) )
               .
               undo main_block, return .
            end.
          end.
          for each buf_doc-line exclusive-lock
            where buf_doc-line.doc-code  = buf_trn-doc.doc-code
          on error undo main_block, return error return-value
          :
            find first buf_tt-doc-line-gds
              where buf_tt-doc-line-gds.artic     = buf_doc-line.artic
                and buf_tt-doc-line-gds.prod-type = buf_doc-line.prod-type
                and buf_tt-doc-line-gds.prod-code = buf_doc-line.prod-code
            no-error .
            if not available buf_tt-doc-line-gds then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcintrn in g#lib-trn
  (
   input parparentproc
  ,input ?
  ,input buf_doc-line.doc-code
  ,input buf_doc-line.artic
  ,input buf_doc-line.prod-type
  ,input buf_doc-line.prod-code
  ,input buf_doc-line.price-cli
  ,input buf_doc-line.price-rubl
  ,input buf_doc-line.price-base
  ,input buf_doc-line.cli-qnty
  ,input buf_doc-line.cli-base-rate
  ,input buf_doc-line.fact-qnty
  ,input buf_doc-line.doc-qnty
  ,input buf_doc-line.vat-pc
  ,input buf_doc-line.slt-pc
  ,input buf_doc-line.road-tax
  ,input buf_doc-line.excise
  ,input buf_doc-line.transport-rubl
  ,input buf_doc-line.other-rubl
  ,input 'delete'
  ,input ''
  ) no-error.
              if error-status :error then do:
                undo main_block, return error substitute( "Ошибка подсчета шапки внешней приходной накладной &1 по строке &2 &3 &4 ."
                                                        , buf_doc-line.doc-code
                                                        , buf_doc-line.artic
                                                        , buf_doc-line.prod-type
                                                        , buf_doc-line.prod-code
                                                        ) .
              end.
              delete buf_doc-line.
            end.
          end.
          find first buf_doc-line
            where buf_doc-line.doc-code  = buf_trn-doc.doc-code
          no-error .
          if not available buf_doc-line
          then do:
            assign
              p-status = '1':u
              p-error-message = substitute("В ПН по &1 не задано ни одной строки"
                                          ,p-doc-type
                                          )
            .
            undo main_block, return .
          end.
          empty temp-table buf_tt-doc-line-gds.
          run gbl/calc-trn.p
            ( input parparentproc
            , input recid( buf_trn-doc )
            ) no-error .
          if error-status :error
          then do:
            undo main_block, return error substitute( "Ошибка персечета накладной &1. &2 "
                                                    , buf_doc-line.doc-code
                                                    , error-status :get-message( 1 )
                                                    ) .
          end.
          run recalc-tot-cli .
          if p-close-status = 'факт':u
          then do:
            find first buf_sys-ctrl no-lock .
            run str/trn-stat.p
              (input  parparentproc
              ,input this-procedure
              ,input  '<закрытие документа>':U
              ,input  buf_trn-doc.doc-code
              ,input  false
              ,input  buf_sys-ctrl.db-num
              ,input  ?
              ,input  ?
              ,input  ?
              ,input  ?
              ,input  false
              ,output v-chg-inv
              ,output table gds-list
              ) no-error .
            if error-status :error
            then do:
              assign
                p-status        = '1':u
                p-error-message = substitute("Ошибка при закрытии документа &1 &2 &3 &4"
                                            ,p-doc-type
                                            ,v-search-doc-code
                                            ,error-status :get-message(1)
                                            ,return-value
                                            )
              .
              undo main_block, return .
            end.
            run cus/rcv-clos.p
              (input  parparentproc
              ,input  buf_ord-doc-rcv.rcv-code
              ,input  true
              ,input  buf_ord-doc-rcv.obj-type
              ,input  buf_ord-doc-rcv.obj-code
              ,input  false
              ) no-error .
            if error-status :error
            then do:
            end.
          end.
          run gbl/rt-docdl.p
            (input v-unique-doc-code
            ) no-error .
          if error-status :error
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute('Ошибка при удалении дополнительной информации &1 &2':u
                                          , error-status :get-message(1)
                                          , return-value
                                          )
            .
            undo main_block, return .
          end.
        end.
        assign
          p-status        = '0':u
          p-error-message = ''
        .
        return .
      end.
      when 'ПН':u
      then do:
        main_block:
        do transaction
        on error undo main_block, return error return-value
        :
          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = v-search-doc-code
            no-error .
          if not available buf_trn-doc
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Не найден документ &1"
                                          ,v-search-doc-code
                                          )
            .
            undo main_block, return .
          end.
          if buf_trn-doc.obj-type <> p-obj-type
          or buf_trn-doc.obj-code <> v-obj-code
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Документ &1 принадлежит объекту &2 &3"
                                          ,v-search-doc-code
                                          ,p-obj-type
                                          ,v-obj-code
                                          )
            .
            undo main_block, return .
          end.
          if buf_trn-doc.ext-doc-type <> 'ie':U
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Документа &1 не является документом внешнего прихода"
                                          ,v-search-doc-code
                                          )
            .
            undo main_block, return .
          end.
          if buf_trn-doc.status_ <> 'накл':U
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                          ,v-search-doc-code
                                          ,'накл':U
                                          )
            .
            undo main_block, return .
          end.
          assign
            v-unique-doc-code = p-doc-type + '|':u + buf_trn-doc.doc-code
          .
          run gbl/rt-doced.p
            (input  v-unique-doc-code
            ,input  buf_user-login.user-id
            ,input  '':u
            ,input  'check':u
            ,input "":U
            ,output p-status
            ,output p-error-message
            ) .
          if  p-status <> '1':u
          and p-status <> '2':u
          then do:
            assign
              p-status = '1':u
            .
            undo main_block, return .
          end.
          define variable v-edit-type as character no-undo .
          if p-status = '1':u
          then do:
            assign
              v-edit-type = 'fact-qnty':u
            .
          end.
          if p-status = '2':u
          then do:
            assign
              v-edit-type = 'doc-qnty':u
            .
          end.
          run ver-bma (input v-obj-code )  no-error .
          if error-status :error
          then do:
            undo main_block , return.
          end.
          if v-edit-type = 'doc-qnty':u
          then do:
            if v-chk-prs
            then do:
              assign
                p-close-status = 'накл-':u
              .
            end.
          end.
          if buf_trn-doc.tot-cli = 0
          and buf_trn-doc.flag_ = false
          then do:
            find first buf_doc-line exclusive-lock
              where buf_doc-line.doc-code = buf_trn-doc.doc-code
              no-error .
            if not available buf_doc-line
            then do:
              assign
                p-status = '1':u
                p-error-message = substitute("В документе ПН по &1 не задано ни одной строки"
                                            ,p-doc-type
                                            )
              .
              undo main_block, return .
            end.
            run ver-tot-cli no-error .
          end.
          run ver-ship-time (output v-car-time-int) no-error .
          if error-status :error
          then do:
            undo main_block , return.
          end.
          if  buf_trn-doc.flag_ = false
          and (p-close-status = 'накл+':u
             or p-close-status = 'факт':u
              )
          then do:
            find first buf_sys-ctrl no-lock .
            run str/trn-stat.p
              (input  parparentproc
              ,input this-procedure
              ,input  '<закрытие документа>':U
              ,input  buf_trn-doc.doc-code
              ,input  false
              ,input  buf_sys-ctrl.db-num
              ,input  ?
              ,input  ?
              ,input  ?
              ,input  ?
              ,input  false
              ,output v-chg-inv
              ,output table gds-list
              ) no-error .
            if error-status :error
            then do:
              assign
                p-status        = '1':u
                p-error-message = substitute("Ошибка при закрытии документа &1 &2 &3 &4"
                                            ,p-doc-type
                                            ,v-search-doc-code
                                            ,error-status :get-message(1)
                                            ,return-value
                                            )
              .
              undo main_block, return .
            end.
          end.
          if v-edit-type = 'fact-qnty':u
          then do:
            _bp-line:
            for each buf_batchprocess exclusive-lock
              where buf_batchprocess.bp_type     = 'rt-line':U
                and buf_batchprocess.bp_status   = 'N':U
                and buf_batchprocess.charkey_one = v-unique-doc-code
            on error undo main_block, return error return-value
            :
              assign
                v-b-code   = buf_batchprocess.key#_one
                v-set-qnty = decimal(buf_batchprocess.bp_execsystime)
              .
              find first buf_bar-code no-lock
                where buf_bar-code.b-code = v-b-code
                no-error .
              if not available buf_bar-code
              then do:
                undo main_block, return error substitute("Не найден бар-код с кодом &1"
                                                        ,v-b-code
                                                        ) .
              end.
              find first buf_goods no-lock
                where buf_goods.gds-code = buf_bar-code.gds-code
                no-error .
              if not available buf_goods
              then do:
                undo main_block, return error substitute("Не найден товар с кодом &1"
                                                        ,buf_bar-code.gds-code
                                                        ) .
              end.
              find first buf_doc-line exclusive-lock
                where buf_doc-line.doc-code  = buf_trn-doc.doc-code
                  and buf_doc-line.artic     = buf_goods.artic
                  and buf_doc-line.prod-type = buf_goods.prod-type
                  and buf_doc-line.prod-code = buf_goods.prod-code
                no-error .
              if not available buf_doc-line
              then do:
                next _bp-line.
              end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run doclicod in g#library
  (input  recid(buf_doc-line)
  ,output v-gds-code
  )  .
              find first t-doc exclusive-lock
                where rowid(t-doc) = rowid(buf_trn-doc)
                .
              run str/doclinfq.p
                (input  parparentproc
                ,buffer t-doc
                ,buffer buf_doc-line
                ,input  v-set-qnty
                ,output v-update-ok
                ,output v-err-message
                ) no-error .
              if error-status :error
              or v-update-ok = false
              then do:
                if error-status :error
                then do:
                  undo main_block, return error substitute("Ошибка при вызове процедуры doclinfq.p. &1 &2"
                                                          ,error-status :get-message(1)
                                                          ,return-value
                                                          )
                  .
                end.
                else do:
                  undo main_block, return error substitute("Невозможно зарезервировать фактическое количество в документе &1 для товара &2 &3 &4. &5"
                                                          ,buf_doc-line.doc-code
                                                          ,buf_doc-line.artic
                                                          ,buf_doc-line.prod-type
                                                          ,buf_doc-line.prod-code
                                                          ,v-err-message
                                                          )
                  .
                end.
              end.
              if buf_doc-line.fact-qnty <> v-set-qnty
              then do:
                undo main_block, return error substitute("Ошибка при резервировании строки документа &1 &2 &3 &4 &5 &6"
                                                        ,buf_doc-line.doc-code
                                                        ,buf_doc-line.artic
                                                        ,buf_doc-line.prod-type
                                                        ,buf_doc-line.prod-code
                                                        ,buf_bar-code.node-code
                                                        ,v-set-qnty
                                                        ) .
              end.
              run set-price-cli (buffer buf_doc-line) no-error .
                if error-status :error then do:
                    assign
                      p-status        = '1'
                      p-error-message = substitute("Цены поставщика &1  для товара &2 &3 &4 &5 &6."
                                                  ,buf_batchprocess.charkey_three
                                                  ,buf_doc-line.artic
                                                  ,buf_doc-line.prod-type
                                                  ,buf_doc-line.prod-code
                                                  ,return-value
                                                  ,error-status :get-message(1)
                                                  )
                    .
                    undo main_block, return .
                end.
              run set-srok-last-day  ( buffer buf_doc-line ) no-error .
              if error-status :error then do:
                  assign
                    p-status        = '1'
                    p-error-message = substitute(" Срок годности &1 &2" , return-value , error-status :get-message(1) )
                  .
                  undo main_block, return .
              end.
            end.
            run gbl/calc-trn.p
              ( input parparentproc
              , input recid( buf_trn-doc )
              ) no-error .
            if error-status :error
            then do:
              undo main_block, return error substitute( "Ошибка персечета накладной &1. &2 "
                                                      , buf_doc-line.doc-code
                                                      , error-status :get-message( 1 )
                                                      ) .
            end.
            run recalc-tot-cli.
          end.
          if p-close-status = 'факт':u
          then do:
            find first buf_sys-ctrl no-lock .
            run str/trn-stat.p
              (input  parparentproc
              ,input  this-procedure
              ,input  '<закрытие документа>':U
              ,input  buf_trn-doc.doc-code
              ,input  false
              ,input  buf_sys-ctrl.db-num
              ,input  ?
              ,input  ?
              ,input  ?
              ,input  ?
              ,input  false
              ,output v-chg-inv
              ,output table gds-list
              ) no-error .
            if error-status :error
            then do:
              assign
                p-status        = '1':u
                p-error-message = substitute("Ошибка при закрытии документа &1 &2 &3 &4"
                                            ,p-doc-type
                                            ,v-search-doc-code
                                            ,error-status :get-message(1)
                                            ,return-value
                                            )
              .
              undo main_block, return .
            end.
          end.
          run gbl/rt-docdl.p
            (input v-unique-doc-code
            ) no-error .
          if error-status :error
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute('Ошибка при удалении дополнительной информации &1 &2':u
                                          , error-status :get-message(1)
                                          , return-value
                                          )
            .
            undo main_block, return .
          end.
        end.
        assign
          p-status        = '0':u
          p-error-message = ''
        .
        return .
      end.
      when 'ОР':u
      then do:
        main_block:
        do transaction
        on error undo main_block, return error return-value
        :
          define buffer buf_ord-doc   for ub.ord-doc.
          define buffer buf_ord-chain for ub.ord-chain.
          find first buf_ord-doc exclusive-lock
               where buf_ord-doc.doc-code = v-search-doc-code
          no-error .
          if not available buf_ord-doc
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Не найден документ &1"
                                          ,v-search-doc-code
                                          )
            .
            undo main_block, return .
          end.
          if buf_ord-doc.cli-type <> p-obj-type
          or buf_ord-doc.cli-code <> v-obj-code
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Документ &1 предназначен объекту &2 &3. Текущий объект &4 &5"
                                          ,v-search-doc-code
                                          ,buf_ord-doc.cli-type
                                          ,buf_ord-doc.cli-code
                                          ,p-obj-type
                                          ,v-obj-code
                                          )
            .
            undo main_block, return .
          end.
          if buf_ord-doc.status_ <> 'запрос':U
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                          ,v-search-doc-code
                                          ,'запрос':U
                                          )
            .
            undo main_block, return .
          end.
          if p-close-status = 'факт':u
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute( "Нельзя закрыть данный документ на &1" , p-close-status )
            .
            undo main_block, return .
          end.
          assign
            v-unique-doc-code = p-doc-type + '|':u + buf_ord-doc.doc-code
          .
          run gbl/rt-doced.p
            (input  v-unique-doc-code
            ,input  buf_user-login.user-id
            ,input  '':u
            ,input  'check':u
            ,input "":U
            ,output p-status
            ,output p-error-message
            ) .
          if  p-status <> '1':u
          and p-status <> '2':u
          then do:
            assign
              p-status = '1':u
            .
            undo main_block, return .
          end.
        define variable v-i as integer   no-undo .
        _ord-chain:
        for each buf_ord-doc-rcv no-lock
          where buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
            , each buf_ord-chain no-lock
                where buf_ord-chain.doc-code     = buf_ord-doc-rcv.rcv-code
                  and buf_ord-chain.doc-type     = 'rcv'
                  and buf_ord-chain.rel-doc-type = 'trn'
        :
          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code
          no-error .
          if available buf_trn-doc then do:
            assign
              v-i = v-i + 1
            .
            if v-i >= 2 then do:
              leave _ord-chain.
            end.
          end.
        end.
        if not available buf_trn-doc
        then do:
          run cus/orcmtrn.p ( input parparentproc
                            , input buf_ord-doc.doc-code
                            ) no-error .
          if error-status :error
          then do:
            assign
              p-error-message = substitute("cus/orcmtrn.p: &1&2&3"
                                          , return-value
                                          , chr(10)
                                          , error-status :get-message(1)
                                          )
            .
            undo main_block, return .
          end.
        end.
        else do:
          if v-i >= 2 then do:
            assign
              p-error-message = substitute("C документом &1 связано более одной накладной. Закрытие документа на РТ невозможно."
                                          , v-search-doc-code
                                          )
            .
            undo main_block, return .
          end.
        end.
        for each buf_ord-doc-rcv no-lock
          where buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
            , each buf_ord-chain no-lock
                where buf_ord-chain.doc-code     = buf_ord-doc-rcv.rcv-code
                  and buf_ord-chain.doc-type     = 'rcv'
                  and buf_ord-chain.rel-doc-type = 'trn'
        :
          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code
          no-error .
          if not available buf_trn-doc
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Ошибка при создании складского документа по поставке &1"
                                          ,buf_ord-doc-rcv.rcv-code
                                          )
            .
            undo main_block, return .
          end.
        end.
        if not available buf_trn-doc
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Ошибка закрытия документа &1. Не могу найти связанную накладную."
                                        , v-search-doc-code
                                        )
          .
          undo main_block, return .
        end.
        find first buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
        no-error .
        if not available buf_doc-line
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("В созданном складском документе отсутствуют строки. Документ удаляется.")
          .
          undo main_block, return .
        end.
          run ver-tot-cli no-error .
          run ver-ship-time (output v-car-time-int) no-error .
          if error-status :error
          then do:
            undo main_block , return.
          end.
          run ver-bma (input v-obj-code )  no-error .
          if error-status :error
          then do:
            undo main_block , return.
          end.
          empty temp-table buf_tt-doc-line-gds .
          run gbl/calc-trn.p
            ( input parparentproc
            , input recid( buf_trn-doc )
            ) no-error .
          if error-status :error
          then do:
            undo main_block, return error substitute( "Ошибка персечета накладной &1. &2 "
                                                    , buf_doc-line.doc-code
                                                    , error-status :get-message( 1 )
                                                    ) .
          end.
          run recalc-tot-cli .
          run gbl/rt-docdl.p
            (input v-unique-doc-code
            ) no-error .
          if error-status :error
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute('Ошибка при удалении дополнительной информации &1 &2':u
                                          , error-status :get-message(1)
                                          , return-value
                                          )
            .
            undo main_block, return .
          end.
        end.
        assign
          p-status        = '0':u
          p-error-message = ''
        .
        return .
      end.
      otherwise do:
        assign
          p-status        = '1':u
          p-error-message = substitute("Неизвестный тип документа &1"
                                      ,p-doc-type
                                      )
        .
        return .
      end.
    end case .
    run rt-cntxt_clrcntxt in this-procedure .
    assign
      p-status        = '1':u
      p-error-message = "Неизвестная ошибка"
    .
    return .
  end.
end procedure.
procedure ver-bma :
define input  parameter p-obj-code as integer   no-undo .
define variable v-agnt   as integer    no-undo .
define variable v-boss   as integer    no-undo .
define variable v-wrkr   as integer    no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input p-obj-type
  ,input p-obj-code
  ,input 'rt-trn-doc':U
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
        if thbjattr_thbj-attr.prop-code = 'wrkr':U  then v-wrkr = thbjattr_thbj-attr.property-value-integer.
        if thbjattr_thbj-attr.prop-code = 'agnt':U  then v-agnt = thbjattr_thbj-attr.property-value-integer.
        if thbjattr_thbj-attr.prop-code = 'boss':U  then v-boss = thbjattr_thbj-attr.property-value-integer.
    end.
          if buf_trn-doc.wrkr = ?
          then do:
            if  v-wrkr <> ?
            then do:
              assign
                buf_trn-doc.wrkr = v-wrkr
              .
            end.
          end.
          if buf_trn-doc.agnt = ?
          then do:
            if  v-agnt <> ?
            then do:
              assign
                buf_trn-doc.agnt = v-agnt
              .
            end.
          end.
          if buf_trn-doc.boss = ?
          then do:
            if  v-boss <> ?
            then do:
              assign
                buf_trn-doc.boss = v-boss
              .
            end.
          end.
  empty temp-table thbjattr_thbj-attr.
  end.
end procedure.
procedure ver-tot-cli :
  do
  on error undo, return error return-value
  :
  assign
    buf_trn-doc.tot-cli = round (buf_trn-doc.tot-calc, (if varrnd-znk = ? then 2 else varrnd-znk ))
  .
  end.
end procedure.
procedure ver-ship-time :
define output parameter  v-car-time-int as integer   no-undo .
define variable v-doc-attr        as character  no-undo .
define variable v-car-time        as character  no-undo .
  do
  on error undo, return error return-value
  :
  run gbl/rt-docgt.p ( input v-unique-doc-code
                      , input  v-user-id
                      , output v-doc-attr
                      , output p-error-message
                      ) .
  if p-error-message <> ""
  then do:
      return error p-error-message .
  end.
  assign
    v-car-time = entry(1, v-doc-attr , chr(1) )
  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input buf_trn-doc.doc-code ,
                       input 'car-time':U ,
                       input v-car-time ) no-error .
  if error-status :error
  then do:
    return error  .
  end.
  assign
    v-car-time-int = integer(mtime(datetime( substitute("01/01/0001 &1" , v-car-time ))) / 1000 )
  no-error .
  if error-status :error
  then do:
    return error  .
  end.
  end.
end procedure.
procedure recalc-tot-cli :
define variable v-tot-calc as decimal   no-undo .
define variable v-tot-qnty as decimal   no-undo .
define buffer buf_doc-line        for ub.doc-line .
  do
  on error undo, return error return-value
  :
    v-tot-calc = 0 .
    v-tot-qnty =0 .
      for each buf_doc-line no-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
      :
        assign
          v-tot-calc = v-tot-calc + buf_doc-line.doc-qnty * buf_doc-line.price-cli
          v-tot-qnty = v-tot-qnty + buf_doc-line.doc-qnty
        .
      end.
      assign
        buf_trn-doc.tot-calc  = round (v-tot-calc, (if varrnd-znk = ? then 2 else varrnd-znk))
        buf_trn-doc.tot-cli   = round (buf_trn-doc.tot-calc, (if varrnd-znk = ? then 2 else varrnd-znk))
      .
  end.
end procedure.
procedure set-srok-last-day :
define parameter buffer buf_doc-line  for ub.doc-line .
define buffer buf_parts for ub.parts  .
define buffer buf_parts-attr for ub.parts-attr  .
define buffer buf_goods for ub.goods  .
define variable v-last-date       as date       no-undo .
define variable v-data-valid    as logical   no-undo .
define variable v-error-message as character no-undo .
  do
  on error undo, return error return-value
  :
    if buf_batchprocess.charkey_two = "" or buf_batchprocess.charkey_two = ? then return.
      run strtdate in this-procedure ( input  buf_batchprocess.charkey_two
                                      , output v-last-date
                                      , output v-data-valid
                                      , output v-error-message
                                      ).
      if v-data-valid <> true then do:
        assign
          v-error-message = substitute("Ошибка преобразования срока годности &1 для товара &2 &3 &4. &5"
                                      ,buf_batchprocess.charkey_two
                                      ,buf_doc-line.artic
                                      ,buf_doc-line.prod-type
                                      ,buf_doc-line.prod-code
                                      ,v-error-message
                                      )
        .
        return error v-error-message .
      end.
      for each buf_parts exclusive-lock
        where buf_parts.obj-type  = buf_doc-line.obj-type
          and buf_parts.obj-code  = buf_doc-line.obj-code
          and buf_parts.artic     = buf_doc-line.artic
          and buf_parts.prod-type = buf_doc-line.prod-type
          and buf_parts.prod-code = buf_doc-line.prod-code
          and buf_parts.in-code   = buf_doc-line.doc-code
      on error undo, return error return-value
      :
        assign
          buf_parts.last-date = v-last-date
        .
        find first buf_goods no-lock
          where buf_goods.artic     = buf_parts.artic
            and buf_goods.prod-type = buf_parts.prod-type
            and buf_goods.prod-code = buf_parts.prod-code
            no-error .
         if error-status :error then do:
            return error  .
         end.
        find first buf_parts-attr exclusive-lock where
                   buf_parts-attr.gds-code = buf_goods.gds-code and
                   buf_parts-attr.in-code  = buf_parts.in-code and
                   buf_parts-attr.part-code  = buf_parts.part-code no-error .
        if available buf_parts-attr then do:
          assign
            buf_parts-attr.last-date = v-last-date
          .
        end.
      end.
  end.
end procedure.
procedure set-price-cli :
define parameter buffer buf_doc-line  for ub.doc-line .
define buffer buf_parts for ub.parts  .
define buffer buf_parts-attr for ub.parts-attr  .
define buffer buf_goods for ub.goods  .
define buffer buf_gds-dtl for ub.gds-dtl  .
define variable v-error-message as character no-undo .
define variable v-new-price-cli as decimal   no-undo .
define variable v-cli-base-rate as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    if buf_batchprocess.charkey_three = "" or buf_batchprocess.charkey_three = ?   or buf_batchprocess.charkey_three = "0"  then return .
        assign
          v-new-price-cli = decimal ( buf_batchprocess.charkey_three )
        no-error .
        if v-new-price-cli = ? or
            v-new-price-cli <= 0
              then do:
                assign
                  v-error-message = substitute("Ошибка преобразования входной цены поставщика &1  для товара &2 &3 &4."
                                              ,buf_batchprocess.charkey_three
                                              ,buf_doc-line.artic
                                              ,buf_doc-line.prod-type
                                              ,buf_doc-line.prod-code
                                              )
                .
                 return error v-error-message .
              end.
              if buf_doc-line.price-cli <> v-new-price-cli
              then do:
              assign
                v-cli-base-rate         =  buf_doc-line.cli-base-rate
                buf_doc-line.price-cli  =  v-new-price-cli * v-cli-base-rate
                buf_doc-line.price-base =  v-new-price-cli / t-doc.base-rate * t-doc.base-scale
                buf_doc-line.price-rubl =  v-new-price-cli
              .
              end.
              for each buf_parts exclusive-lock
                where buf_parts.obj-type  = buf_doc-line.obj-type
                  and buf_parts.obj-code  = buf_doc-line.obj-code
                  and buf_parts.artic     = buf_doc-line.artic
                  and buf_parts.prod-type = buf_doc-line.prod-type
                  and buf_parts.prod-code = buf_doc-line.prod-code
                  and buf_parts.in-code   = buf_doc-line.doc-code
              :
                assign
                  buf_parts.price-cli   =   v-new-price-cli * v-cli-base-rate
                  buf_parts.price-base  = ( v-new-price-cli / t-doc.base-rate * t-doc.base-scale ) / v-cli-base-rate
                  buf_parts.price-rubl  =   v-new-price-cli / v-cli-base-rate
                .
                    find first buf_goods no-lock
                      where buf_goods.artic     = buf_parts.artic
                        and buf_goods.prod-type = buf_parts.prod-type
                        and buf_goods.prod-code = buf_parts.prod-code
                        no-error .
                    if error-status :error then do:
                        return error  .
                    end.
                    find first buf_parts-attr exclusive-lock where
                               buf_parts-attr.gds-code = buf_goods.gds-code and
                               buf_parts-attr.in-code  = buf_parts.in-code and
                               buf_parts-attr.part-code  = buf_parts.part-code no-error .
                    if available buf_parts-attr then do:
                      assign
                        buf_parts-attr.price-cli   = buf_parts.price-cli
                        buf_parts-attr.price-base  = buf_parts.price-base
                        buf_parts-attr.price-rubl  = buf_parts.price-rubl
                      .
                    end.
              end.
              for each buf_gds-dtl exclusive-lock
                where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
                  and buf_gds-dtl.artic     = buf_doc-line.artic
                  and buf_gds-dtl.prod-type = buf_doc-line.prod-type
                  and buf_gds-dtl.prod-code = buf_doc-line.prod-code
              :
                assign
                  buf_gds-dtl.price-base  = ( v-new-price-cli / t-doc.base-rate * t-doc.base-scale ) / v-cli-base-rate
                  buf_gds-dtl.price-rubl  =   v-new-price-cli / v-cli-base-rate
                .
              end.
  end.
end procedure.
