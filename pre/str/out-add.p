block-level on error undo, throw.
define input parameter ParParentProc as handle    no-undo .
define input parameter pardoc-rec    as recid     no-undo .
define input parameter parline-rec   as recid     no-undo .
define input parameter parprt-rec    as recid     no-undo .
define input parameter pargds-rec    as recid     no-undo .
define input parameter work-mode     as character no-undo format "x(30)":U .
define input parameter parvalue      as character no-undo .
define variable vss-revision    as character no-undo initial "$Revision: 91c8196f6fee, 3209, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2022/12/27 12:54:28 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: out-add.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/out-add.p $":U .
define variable vss-description as character no-undo initial "Добавление строк в РН, СН, ВН при заданном товаре":U .
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
    assign
      p-vss-parameters = substitute('&1|&2':u,work-mode,parvalue)
    .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
  define temp-table  tt-tax no-undo
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
index tax-code is unique primary tax-code.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
define new global shared variable g#libbcrcn as handle no-undo .
function cross-list returns logical (
  input parfirst-stream  as character,
  input parsecond-stream as character,
  input pardelim         as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  define variable vari            as integer no-undo .
  define variable varresult-cross as logical no-undo .
  assign
    varresult-cross = no
  .
  def var v-num-parfirst-stream as integer no-undo .
  assign
    v-num-parfirst-stream = num-entries(parfirst-stream, pardelim)
  .
  do vari = 1 to v-num-parfirst-stream
  :
    if lookup(entry(vari, parfirst-stream, pardelim)
             ,parsecond-stream
             ,pardelim
             ) > 0 then do:
      assign
        varresult-cross = yes
      .
      leave.
    end.
  end.
  return varresult-cross .
end function.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure lineattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value =  buf_doc-line-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure lineattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code = p-gds-code
        buf_doc-line-attr.attr-code = p-code
      .
    end.
    assign
      buf_doc-line-attr.attr-value = p-value
    .
     release buf_doc-line-attr.
  end.
end procedure.
procedure lineattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if  available buf_doc-line-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure lineattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-fillin_width   as integer   no-undo .
    define output parameter p-fillin_height  as integer   no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'parts_price-sale':U then do:     assign     p-label          = "Продажная цена партии"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Продажная цена партии"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'fl_gds-code':U then do:     assign     p-label          = "Количество по букету"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Количество по букету"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'old_other-ras':U then do:     assign     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'new_other-ras':U then do:     assign     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'flora_ps':U then do:     assign     p-label          = "Описание не товарной позиции"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Описание не товарной позиции"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'country-code':U then do:     assign     p-label          = "Страна"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Страна"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'add-line-cli':U then do:     assign     p-label          = "Курс . шкала . сумма . НДС "     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Курс . шкала . сумма . НДС "     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'corr-price-sale':U then do:     assign     p-label          = "Продажная цена в строке ПН"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Продажная цена в строке ПН"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'reason-code':U then do:     assign     p-label          = "Причина отклонения"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Причина отклонения"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prod':U then do:     assign     p-label          = "Цена производителя Без НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя Без НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prodvat':U then do:     assign     p-label          = "Цена производителя c НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя c НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки документа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure lineattr-value-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
procedure lineattr-delete-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-delete-flora-all :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    for each buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code begins 'fl_gds-code':U + chr(44) + string(p-prt-code)  + chr(44)
     :
      delete buf_doc-line-attr.
    end.
 end.
end procedure.
procedure lineattr-exist-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define output parameter p-exist as logical   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    p-exist = false .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'fl_gds-code':U  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
       p-exist = true
      .
    end.
  end.
end procedure.
procedure lineattr-write-add-line-cli :
define input  parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input  parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input  parameter p-cli-type      as character no-undo .
define input  parameter p-cli-code      as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-exch-code     as integer   no-undo .
define input  parameter p-exch-rate     as decimal   no-undo .
define input  parameter p-exch-scale    as integer   no-undo .
define input  parameter p-sum-cli       as decimal   no-undo .
define input  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = 'add-line-cli':U  +
                                      chr(4) + p-cli-type +
                                      chr(4) + string(p-cli-code) +
                                      chr(4) + string(p-contract-code) +
                                      chr(4) + string(p-host-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value =
      string(p-exch-code)  + chr(4) +
      string(p-exch-rate)  + chr(4) +
      string(p-exch-scale) + chr(4) +
      string(p-sum-cli)    + chr(4) +
      string(p-sum-vat)
      .
  end.
end procedure.
procedure lineattr-value-add-line-cli :
define input   parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input   parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input   parameter p-cli-type      as character no-undo .
define input   parameter p-cli-code      as integer   no-undo .
define input   parameter p-contract-code as integer   no-undo .
define input   parameter p-host-code     as integer   no-undo .
define output  parameter p-exch-code     as integer   no-undo .
define output  parameter p-exch-rate     as decimal   no-undo .
define output  parameter p-exch-scale    as integer   no-undo .
define output  parameter p-sum-cli       as decimal   no-undo .
define output  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if available buf_doc-line-attr then do:
     assign
        p-exch-code  = integer ( entry (1 , buf_doc-line-attr.attr-value,  chr(4) ))
        p-exch-rate  = decimal ( entry (2 , buf_doc-line-attr.attr-value, chr(4) ))
        p-exch-scale = integer ( entry (3 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-cli    = decimal ( entry (4 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-vat    = decimal ( entry (5 , buf_doc-line-attr.attr-value, chr(4) ))
       .
     end.
  end.
end procedure.
function lineattr-get-reason returns character ( buffer local-doc-line for ub.doc-line ) :
  define variable v-code as character no-undo .
  define variable v-type as character no-undo .
  define variable v-gds-code as integer   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  local-doc-line.artic
  ,input  local-doc-line.prod-type
  ,input  local-doc-line.prod-code
  ,output v-gds-code
  )  .
  run lineattr-value (
      input   local-doc-line.doc-code ,
      input   v-gds-code              ,
      input   'reason-code':U ,
      output  v-code                  ,
      output  v-type ) .
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = integer ( v-code ) no-error.
  if not available ub.trn-reason then do:
     return "" .
  end.
  else do:
     return ub.trn-reason.reason-name .
  end.
end function.
procedure lineattr-value-parts :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-part-code   as character no-undo .
    define input  parameter p_in-code     as character no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(4) + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-parts :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-part-code  as character no-undo .
    define input parameter p_in-code    as character no-undo .
    define input parameter p-code       like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value      as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
function IS-NeedMark returns logical
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
function repTegforDm return char
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo.
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
function repSpecSimbforDm return char
(iDM as char ):
    define variable oDM as character no-undo.
  run
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
function CheckGtin return logical
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else
      vGtin = no.
   return vgtin.
end.
function repSpecSimbforXlm return char
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
function getGtinByDM return char
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7
      then
         vGtin = substring(vtxt,1,14).
   end.
   if not checkGtin(vGtin)
   then
      vGtin = "".
   return vgtin.
end.
function getGdsCodeByGtin return int
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
function getQntyCodeByGtin return decimal
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
function getGdsCodeByDM return int
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
function ChekTypeMarkByGds return logical
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code
                           and goods-attr.attr-code  = 'mark-type':U
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp
        .
   end.
   else
      return no.
end.
function ChekTypeMarkByDm return logical
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
function ChekTypeMarkByGtin return logical
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
function GetNextElement return character
  (input iAllTeg        as logical
  ,output oteg          as character
  ,output otegval       as character
  ,input-output pstr    as character
   ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)".
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006".
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)".
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code.
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
     if iAllTeg
     then
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.
function GetCodeIdent return character
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   for first marking no-lock where
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     return iDm.
   end.
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins 'tech_':U
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else
         oCodeIdent = iDM.
   end.
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.
end.
function GetTegCod return character
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21"
      then
         oTeg = substring(icodeIdent,15,7).
   end.
   else do:
      ChekTypeMarkByDm(icodeIdent).
      block-teg:
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")"
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.
end.
function isOAD return logical
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
function isMark return logical
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
function addBracketForCode return character
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define buffer marking for ub.marking.
   find first marking no-lock where
              marking.mark begins icodeIdent no-error.
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.
   else do:
      if (  icodeIdent begins "01"
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14))
         and substring (icodeIdent,17,2) eq "21"
      then do:
         mMRCCode = yes.
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.
   return oTeg.
end.
function getlevelByCodId return int
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then
      Vlevel = 4.
   else if vLength eq 21
   then
      Vlevel = 1.
   else if vLength eq 25
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11"
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.
   else
      Vlevel = ?.
   return Vlevel.
end.
function getLevelMotpBycodid return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByLevelMotp return character
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.
function getLevelMotpByDM return character
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
function getLevelUTDByCodId return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByDM return character
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
function getQntyUTDByCodId return decimal
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.
function getQntyUTDByDM return decimal
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25
      and length (iDm) ne 29
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.
function getMRC4 return decimal
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.
function getMRCByDM return decimal
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.
function MoveDate return Date
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.
end.
procedure checkEMRC:
define input  parameter iDm as character no-undo.
define output parameter vok as logical   no-undo init yes.
   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code.
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).
            if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
         (
          input   vgds-code
         ,input   'emrc-type':U
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + chr(4) + v-value-emrc.
          find last code where Code.parent      eq vparent
                           and Code.code        le vDateIso
                           and code.status_  eq 0
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq 0 no-lock no-error.
              if available code
              then
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq 0
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq 0
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  chr(10),
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  chr(10),
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
          end.
       end.
   end.
end.
function addGs2Mark return character
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
   if index(iMark,chr(29),1) > 0
   then return iMark.
   if substring(iMark,26,4) = "8005" then
   do:
     vIdx = index(iMark,"93",26 + 4 + 5).
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.
     end.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "91" then
   do:
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
   return if vDM <> "" then vDm else iMark.
end.
define buffer t-doc      for ub.trn-doc .
define buffer p-doc-line for ub.doc-line .
define buffer p-goods    for ub.goods .
define buffer bf_gds-obj for ub.gds-obj .
define buffer bf-parts   for ub.parts .
define buffer bf_doc-pl  for ub.doc-pl .
define buffer bf_parts   for ub.parts.
define buffer bf_marking-lines for ub.marking-lines .
define buffer in_parts   for ub.parts.
define variable part-list                                 as   character initial ""       no-undo.
define variable add-sens                                  as   logical                    no-undo.
define variable g-type                                    as   character initial ?        no-undo.
define variable qnty-str                                  as   character                  no-undo.
define variable rate                                      as   decimal                    no-undo.
define variable is-all                                    as   logical                    no-undo.
define variable b-c                                       as   integer                    no-undo.
define variable line-mode                                 as   character                  no-undo.
define variable v-is-return                               as   logical                    no-undo.
def var mess as char no-undo.
procedure proc-code.
define input parameter pl-str as char no-undo.
DEFine INPUT PARAMeter mode-proc as CHAR NO-UNDO.
define input parameter parscales-pref as character no-undo.
define input parameter parpgscales-pref as character no-undo.
define buffer b-bar-code for ub.bar-code.
DEFINE VARIABLE mode-create      as LOGICAL NO-UNDO.
DEFINE VARIABLE rec-old          as RECID NO-UNDO.
define variable varres        as logical         no-undo.
define variable var-code-temp like ub.place.pl-code no-undo.
define buffer pc-goods for ub.goods.
define variable g-log-char as character no-undo.
define variable varprice-cli-old        like ub.doc-line.price-cli no-undo.
define variable varprice-rubl-old       like ub.doc-line.price-cli no-undo.
define variable varprice-base-old       like ub.doc-line.price-cli no-undo.
define variable varcli-qnty-old         like ub.doc-line.cli-qnty  no-undo.
define variable varcli-base-rate-old    like ub.doc-line.cli-qnty  no-undo.
define variable varfact-qnty-old        like ub.doc-line.cli-qnty  no-undo.
define variable vardoc-qnty-old         like ub.doc-line.cli-qnty  no-undo.
define variable varvat-pc-old           like ub.doc-line.vat-pc    no-undo.
define variable varslt-pc-old           like ub.doc-line.vat-pc    no-undo.
define variable varroad-tax-old         like ub.doc-line.price-cli no-undo.
define variable varexcise-old           like ub.doc-line.price-cli no-undo.
define variable vartransport-rubl-old   like ub.doc-line.price-cli no-undo.
define variable varother-rubl-old       like ub.doc-line.price-cli no-undo.
define variable lns-cnt                 as   integer               no-undo.
IF mode-proc = "PLACE" THEN DO:
    do lns-cnt = 1 to num-entries (part-list):
      find ub.bar-code where ub.bar-code.b-code  = integer (entry (lns-cnt, part-list)) no-lock.
      find first pc-goods where pc-goods.gds-code  = ub.bar-code.gds-code no-lock.
      RUN plgdsfnd (input  no,
                    input  v-cntxt-obj-type,
                    input  v-cntxt-obj-code,
                    input  pc-goods.gds-code,
                    output varres,
                    output var-code-temp) no-error.
     if varres = yes or error-status:error then do:
          MESSAGE "Нельзя перемещать партии товара по складским местам "
          pc-goods.artic " " pc-goods.prod-type " " pc-goods.prod-code
          " по объкту " v-cntxt-obj-type " " v-cntxt-obj-code " "
        VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      end.
      else
      for each ub.parts where ub.parts.obj-type  = v-cntxt-obj-type
                       and ub.parts.obj-code  = v-cntxt-obj-code
                       and ub.parts.artic     = pc-goods.artic
                       and ub.parts.prod-type = pc-goods.prod-type
                       and ub.parts.prod-code = pc-goods.prod-code
                       and ub.parts.in-code   = ub.bar-code.in-code
                       and ub.parts.part-code = ub.bar-code.part-code
                       and ub.parts.rsrv-free = yes:
        ub.parts.pl-code = ub.place.pl-code.
      end.
    end.
    part-list = "".
END.
ELSE DO:
  if add-sens = ? then part-list = if part-list = "" then string (b-c) else part-list + "," + string (b-c).
  else do:
    if ub.goods.gds-type <> 'т':U and (t-doc.doc-type <> 'рас':U or t-doc.internal) then do:
      MESSAGE "Услуга не соответствует типу данной накладной."
        VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      return error.
    end.
    if g-type = ? then g-type = ub.goods.gds-type.
    if g-type <> ub.goods.gds-type then do:
      MESSAGE "Тип товара не соответствует типу данной накладной."
        VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      return error.
    end.
    assign g-log-char = "yes".
    do transaction on error undo , leave:
       define variable tempmess as character no-undo.
       define buffer bf_doc-line for ub.doc-line.
       find first ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code  and
                                 ub.doc-line.artic     = ub.goods.artic     and
                                 ub.doc-line.prod-type = ub.goods.prod-type and
                                 ub.doc-line.prod-code = ub.goods.prod-code no-error.
       if available ub.doc-line then do:
          assign
          mode-create = no
          varprice-cli-old       = ub.doc-line.price-cli
          varprice-rubl-old      = ub.doc-line.price-rubl
          varprice-base-old      = ub.doc-line.price-base
          varcli-qnty-old        = ub.doc-line.cli-qnty
          varcli-base-rate-old   = ub.doc-line.cli-base-rate
          varfact-qnty-old       = ub.doc-line.fact-qnty
          vardoc-qnty-old        = ub.doc-line.doc-qnty
          varvat-pc-old          = ub.doc-line.vat-pc
          varslt-pc-old          = ub.doc-line.slt-pc
          varroad-tax-old        = ub.doc-line.road-tax
          varexcise-old          = ub.doc-line.excise
          vartransport-rubl-old  = ub.doc-line.transport-rubl
          varother-rubl-old      = ub.doc-line.other-rubl.
       end.
       else mode-create = yes.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_copy-scn in g#lib-trn
  ( input  parparentproc
   ,input  recid(t-doc)
   ,input  bar-code.b-code
   ,input  decimal(qnty-str) * rate
   ,input  is-all
   ,input  add-sens
   ,input  line-mode
   ,output tempmess
   ,output g-log-char
  ) no-error .
       assign
       mess = mess + tempmess.
       if error-status:error then do:
         assign
         mess = mess + return-value.
         MESSAGE "Ошибка"
           VIEW-AS ALERT-BOX ERROR BUTTONS OK.
         return error.
       end.
       else do:
         if pl-str <> "" then run store-place in this-procedure ( input pl-str
                                                                 ,input parscales-pref
                                                                 ,input parpgscales-pref
                                                                 ).
       end.
       find first ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code  and
                                 ub.doc-line.artic     = ub.goods.artic     and
                                 ub.doc-line.prod-type = ub.goods.prod-type and
                                 ub.doc-line.prod-code = ub.goods.prod-code no-error.
       if t-doc.doc-type = 'при':U then do:
         if mode-create then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcintrn in g#lib-trn
  (
   input parparentproc
  ,input recid(doc-line)
  ,input t-doc.doc-code
  ,input ub.doc-line.artic
  ,input ub.doc-line.prod-type
  ,input ub.doc-line.prod-code
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 'create'
  ,input ''
  ) no-error.
            if error-status:error then return error return-value.
         end.
         else do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcintrn in g#lib-trn
  (
   input parparentproc
  ,input recid(doc-line)
  ,input ub.doc-line.doc-code
  ,input ub.doc-line.artic
  ,input ub.doc-line.prod-type
  ,input ub.doc-line.prod-code
  ,input varprice-cli-old
  ,input varprice-rubl-old
  ,input varprice-base-old
  ,input varcli-qnty-old
  ,input varcli-base-rate-old
  ,input varfact-qnty-old
  ,input vardoc-qnty-old
  ,input varvat-pc-old
  ,input varslt-pc-old
  ,input varroad-tax-old
  ,input varexcise-old
  ,input vartransport-rubl-old
  ,input varother-rubl-old
  ,input 'update'
  ,input ''
  ) no-error.
            if error-status:error then return error return-value.
         end.
       end.
    end.
    if substring(g-log-char, 1, 4) = "qnty" then do:
    end.
  end.
end.
end procedure.
procedure store-place:
DEFine INPUT PARAMETER pl-str as CHAR NO-UNDO.
define input parameter parscales-pref as character no-undo.
define input parameter parpgscales-pref as character no-undo.
define variable pl-c as int no-undo.
define variable varres        as logical         no-undo.
define variable var-code-temp like ub.place.pl-code no-undo.
define variable varresult   as character       no-undo.
define variable vartype-bc  as character       no-undo.
define variable varweight   as decimal         no-undo.
define buffer pc-goods for ub.goods.
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  pl-str
,input  ?
,input  v-cntxt-obj-type
,input  v-cntxt-obj-code
,input  yes
,input  no
,input  parscales-pref
,input  parpgscales-pref
,output varresult
,output vartype-bc
,output varweight
,buffer ub.bar-code
,buffer ub.prod-bc
,buffer ub.place
) no-error.
if error-status:error then do:
  return error "Ошибка при разборе бар-кода: " + pl-str.
end.
if available place then do:
  find ub.bar-code where ub.bar-code.b-code  = b-c no-lock.
  find first pc-goods where pc-goods.gds-code  = ub.bar-code.gds-code no-lock.
  RUN plgdsfnd (input  no,
                input  v-cntxt-obj-type,
                input  v-cntxt-obj-code,
                input  pc-goods.gds-code,
                output varres,
                output var-code-temp) no-error.
  if varres = yes or error-status:error then do:
      MESSAGE "Нельзя перемещать партии товара по складским местам "
          pc-goods.artic " " pc-goods.prod-type " " pc-goods.prod-code
          " по объкту " v-cntxt-obj-type " " v-cntxt-obj-code " "
        VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  end.
  else
  for each ub.parts where ub.parts.obj-type  = v-cntxt-obj-type
                   and ub.parts.obj-code  = v-cntxt-obj-code
                   and ub.parts.artic     = pc-goods.artic
                   and ub.parts.prod-type = pc-goods.prod-type
                   and ub.parts.prod-code = pc-goods.prod-code
                   and ub.parts.in-code   = ub.bar-code.in-code
                   and ub.parts.part-code = ub.bar-code.part-code:
    if ub.parts.rsrv-free or
       ub.parts.out-code = t-doc.doc-code then ub.parts.pl-code = ub.place.pl-code.
  end.
end.
end procedure.
procedure plgdsfnd :
  define input  parameter p-chk-and-chs    as logical               no-undo .
  define input  parameter p-obj-type       like ub.gds-obj.obj-type no-undo .
  define input  parameter p-obj-code       like ub.gds-obj.obj-code no-undo .
  define input  parameter p-gds-code       like ub.goods.gds-code   no-undo .
  define output parameter p-reserv-pl-code as   logical             no-undo .
  define output parameter p-pl-code        like ub.pl-gds.pl-code   no-undo .
  define buffer buf_goods         for ub.goods .
  define buffer buf_pl-gds        for ub.pl-gds .
  define buffer buf_second_pl-gds for ub.pl-gds .
  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .
  if not available buf_goods
  then do:
    return error "Не найден товар. Первичный бар-код " + string( p-gds-code ) .
  end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'place-rsrv=request'
  ,output p-reserv-pl-code
  ) no-error .
  if error-status :error
  then do:
    return error substitute("Ошибка при запросе атрибута place-rsrv товара на объекте  &1 &2 " , error-status :get-message(1) , return-value  )  .
  end.
  if p-reserv-pl-code = no
  then do:
    return .
  end.
  if p-chk-and-chs <> yes
  then do:
    return .
  end.
  find first buf_pl-gds no-lock where
             buf_pl-gds.obj-type = p-obj-type and
             buf_pl-gds.obj-code = p-obj-code and
             buf_pl-gds.gds-code = p-gds-code no-error .
  if not available buf_pl-gds
  then do:
    return error "К товару не привязано ни одного места хранения" .
  end.
  find first buf_second_pl-gds no-lock where
             buf_second_pl-gds.obj-type  = p-obj-type          and
             buf_second_pl-gds.obj-code  = p-obj-code          and
             buf_second_pl-gds.gds-code  = p-gds-code          and
             recid( buf_second_pl-gds ) <> recid( buf_pl-gds ) no-error .
  if not available buf_second_pl-gds
  then do:
    assign
      p-pl-code = buf_pl-gds.pl-code
    .
  end.
  else do:
    run str/plgdssel.p
      (
         input parparentproc
      ,  input p-obj-type
      ,  input p-obj-code
      ,  input p-gds-code
      , output p-pl-code
      ) no-error .
    if error-status :error
    then do:
      return error substitute( 'Ошибка при вызове программы &1&2&3&2&4&2'
                             , 'plgdssel.p':U
                             , chr(10)
                             , error-status :get-message( 1 )
                             , return-value
                             ) .
    end.
    if p-pl-code = ? or
       p-pl-code = 0
    then do:
      return error "Не выбрано место хранения " + chr(10) .
    end.
  end.
end procedure.
define variable o-total-doc-line_tot-ovnew                like ub.trn-doc.tot-ov          no-undo.
define variable o-total-doc-line_fact-rublnew             like ub.trn-doc.fact-rubl       no-undo.
define variable o-total-doc-line_fact-basenew             like ub.trn-doc.fact-base       no-undo.
define variable o-total-doc-line_fact-qntynew             like ub.trn-doc.fact-qnty       no-undo.
define variable o-total-doc-line_doc-qntynew              like ub.trn-doc.doc-qnty        no-undo.
define variable o-total-doc-line_cli-qntynew              like ub.trn-doc.cli-qnty        no-undo.
define variable o-total-doc-line_tot-ovold                like ub.trn-doc.tot-ov          no-undo.
define variable o-total-doc-line_fact-rublold             like ub.trn-doc.fact-rubl       no-undo.
define variable o-total-doc-line_fact-baseold             like ub.trn-doc.fact-base       no-undo.
define variable o-total-doc-line_fact-qntyold             like ub.trn-doc.fact-qnty       no-undo.
define variable o-total-doc-line_doc-qntyold              like ub.trn-doc.doc-qnty        no-undo.
define variable o-total-doc-line_cli-qntyold              like ub.trn-doc.cli-qnty        no-undo.
define variable varagsum-base-docnew                      like ub.gds-dtl.price-base      no-undo.
define variable varagsum-rubl-docnew                      like ub.gds-dtl.price-rubl      no-undo.
define variable varagsum-base-factnew                     like ub.gds-dtl.price-base      no-undo.
define variable varagsum-rubl-factnew                     like ub.gds-dtl.price-rubl      no-undo.
define variable varagsum-doc-qntynew                      like ub.gds-dtl.doc-qnty        no-undo.
define variable varagsum-fact-qntynew                     like ub.gds-dtl.fact-qnty       no-undo.
define variable varagcountnew                             as   integer                    no-undo.
define variable varagsum-base-docold                      like ub.gds-dtl.price-base      no-undo.
define variable varagsum-rubl-docold                      like ub.gds-dtl.price-rubl      no-undo.
define variable varagsum-base-factold                     like ub.gds-dtl.price-base      no-undo.
define variable varagsum-rubl-factold                     like ub.gds-dtl.price-rubl      no-undo.
define variable varagsum-doc-qntyold                      like ub.gds-dtl.doc-qnty        no-undo.
define variable varagsum-fact-qntyold                     like ub.gds-dtl.fact-qnty       no-undo.
define variable varagcountold                             as   integer                    no-undo.
define variable varroad-tax-fact-baseold                  like ub.gds-dtl.price-base      no-undo.
define variable varexcise-fact-baseold                    like ub.gds-dtl.price-base      no-undo.
define variable varslt-fact-baseold                       like ub.gds-dtl.price-base      no-undo.
define variable varvat-fact-baseold                       like ub.gds-dtl.price-base      no-undo.
define variable varslt-doc-baseold                        like ub.gds-dtl.price-base      no-undo.
define variable varvat-doc-baseold                        like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-out-dsv-baseold               like ub.gds-dtl.price-base      no-undo.
define variable varroad-tax-fact-rublold                  like ub.gds-dtl.price-base      no-undo.
define variable varexcise-fact-rublold                    like ub.gds-dtl.price-base      no-undo.
define variable varslt-fact-rublold                       like ub.gds-dtl.price-base      no-undo.
define variable varvat-fact-rublold                       like ub.gds-dtl.price-base      no-undo.
define variable varslt-doc-rublold                        like ub.gds-dtl.price-base      no-undo.
define variable varvat-doc-rublold                        like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-out-dsv-rublold               like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-out-dsc-baseold               like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-out-dsc-rublold               like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-curold                        like ub.gds-dtl.price-base      no-undo.
define variable varov-fact-baseold                        like ub.gds-dtl.price-base      no-undo.
define variable varov-vat-fact-baseold                    like ub.gds-dtl.price-base      no-undo.
define variable varsum-doc-curold                         like ub.gds-dtl.price-base      no-undo.
define variable varov-doc-baseold                         like ub.gds-dtl.price-base      no-undo.
define variable varov-vat-doc-baseold                     like ub.gds-dtl.price-base      no-undo.
define variable varsum-doc-baseold                        like ub.gds-dtl.price-base      no-undo.
define variable varsum-doc-rublold                        like ub.gds-dtl.price-base      no-undo.
define variable varroad-tax-factold                       like ub.gds-dtl.price-base      no-undo.
define variable varexcise-factold                         like ub.gds-dtl.price-base      no-undo.
define variable varroad-tax-docold                        like ub.gds-dtl.price-base      no-undo.
define variable varexcise-docold                          like ub.gds-dtl.price-base      no-undo.
define variable vardiscnt-base-docold                     like ub.gds-dtl.price-base      no-undo.
define variable vardiscnt-rubl-docold                     like ub.gds-dtl.price-base      no-undo.
define variable vardiscnt-base-factold                    like ub.gds-dtl.price-base      no-undo.
define variable vardiscnt-rubl-factold                    like ub.gds-dtl.price-base      no-undo.
define variable varroad-tax-fact-basenew                  like ub.gds-dtl.price-base      no-undo.
define variable varexcise-fact-basenew                    like ub.gds-dtl.price-base      no-undo.
define variable varslt-fact-basenew                       like ub.gds-dtl.price-base      no-undo.
define variable varvat-fact-basenew                       like ub.gds-dtl.price-base      no-undo.
define variable varslt-doc-basenew                        like ub.gds-dtl.price-base      no-undo.
define variable varvat-doc-basenew                        like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-out-dsv-basenew               like ub.gds-dtl.price-base      no-undo.
define variable varroad-tax-fact-rublnew                  like ub.gds-dtl.price-base      no-undo.
define variable varexcise-fact-rublnew                    like ub.gds-dtl.price-base      no-undo.
define variable varslt-fact-rublnew                       like ub.gds-dtl.price-base      no-undo.
define variable varvat-fact-rublnew                       like ub.gds-dtl.price-base      no-undo.
define variable varslt-doc-rublnew                        like ub.gds-dtl.price-base      no-undo.
define variable varvat-doc-rublnew                        like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-out-dsv-rublnew               like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-out-dsc-basenew               like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-out-dsc-rublnew               like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-curnew                        like ub.gds-dtl.price-base      no-undo.
define variable varov-fact-basenew                        like ub.gds-dtl.price-base      no-undo.
define variable varov-vat-fact-basenew                    like ub.gds-dtl.price-base      no-undo.
define variable varsum-doc-curnew                         like ub.gds-dtl.price-base      no-undo.
define variable varov-doc-basenew                         like ub.gds-dtl.price-base      no-undo.
define variable varov-vat-doc-basenew                     like ub.gds-dtl.price-base      no-undo.
define variable varsum-doc-basenew                        like ub.gds-dtl.price-base      no-undo.
define variable varsum-doc-rublnew                        like ub.gds-dtl.price-base      no-undo.
define variable varroad-tax-factnew                       like ub.gds-dtl.price-base      no-undo.
define variable varexcise-factnew                         like ub.gds-dtl.price-base      no-undo.
define variable varroad-tax-docnew                        like ub.gds-dtl.price-base      no-undo.
define variable varexcise-docnew                          like ub.gds-dtl.price-base      no-undo.
define variable vardiscnt-base-docnew                     like ub.gds-dtl.price-base      no-undo.
define variable vardiscnt-rubl-docnew                     like ub.gds-dtl.price-base      no-undo.
define variable vardiscnt-base-factnew                    like ub.gds-dtl.price-base      no-undo.
define variable vardiscnt-rubl-factnew                    like ub.gds-dtl.price-base      no-undo.
define variable vartotal-road-tax-fact-base               like ub.gds-dtl.price-base      no-undo.
define variable vartotal-excise-fact-base                 like ub.gds-dtl.price-base      no-undo.
define variable vartotal-slt-fact-base                    like ub.gds-dtl.price-base      no-undo.
define variable vartotal-vat-fact-base                    like ub.gds-dtl.price-base      no-undo.
define variable vartotal-slt-doc-base                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-vat-doc-base                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-sum-fact-out-dsv-base            like ub.gds-dtl.price-base      no-undo.
define variable vartotal-road-tax-fact-rubl               like ub.gds-dtl.price-base      no-undo.
define variable vartotal-excise-fact-rubl                 like ub.gds-dtl.price-base      no-undo.
define variable vartotal-slt-fact-rubl                    like ub.gds-dtl.price-base      no-undo.
define variable vartotal-vat-fact-rubl                    like ub.gds-dtl.price-base      no-undo.
define variable vartotal-slt-doc-rubl                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-vat-doc-rubl                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-sum-fact-out-dsv-rubl            like ub.gds-dtl.price-base      no-undo.
define variable vartotal-sum-fact-out-dsc-base            like ub.gds-dtl.price-base      no-undo.
define variable vartotal-sum-fact-out-dsc-rubl            like ub.gds-dtl.price-base      no-undo.
define variable vartotal-sum-fact-cur                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-ov-fact-base                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-ov-vat-fact-base                 like ub.gds-dtl.price-base      no-undo.
define variable vartotal-sum-doc-cur                      like ub.gds-dtl.price-base      no-undo.
define variable vartotal-ov-doc-base                      like ub.gds-dtl.price-base      no-undo.
define variable vartotal-ov-vat-doc-base                  like ub.gds-dtl.price-base      no-undo.
define variable vartotal-sum-doc-base                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-sum-doc-rubl                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-road-tax-fact                    like ub.gds-dtl.price-base      no-undo.
define variable vartotal-excise-fact                      like ub.gds-dtl.price-base      no-undo.
define variable vartotal-road-tax-doc                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-excise-doc                       like ub.gds-dtl.price-base      no-undo.
define variable vartotal-discnt-base-doc                  like ub.gds-dtl.price-base      no-undo.
define variable vartotal-discnt-rubl-doc                  like ub.gds-dtl.price-base      no-undo.
define variable vartotal-discnt-base-fact                 like ub.gds-dtl.price-base      no-undo.
define variable vartotal-discnt-rubl-fact                 like ub.gds-dtl.price-base      no-undo.
define variable flag-incr-disc-vat                        as   logical initial no         no-undo.
define variable flag-update                               as   logical initial no         no-undo.
define variable chg-qnty                                  like ub.gds-dtl.doc-qnty        no-undo initial ?.
define variable no-end-all-operation                      as   logical   initial yes      no-undo.
define variable varrep                                    as   logical   initial no       no-undo.
define variable unrv-qnty                                 like ub.gds-dtl.doc-qnty        no-undo.
define variable vartwo-value                              as   logical                    no-undo.
define variable v-vat-pc                                  like ub.doc-line.vat-pc         no-undo.
define variable v-slt-pc                                  like ub.doc-line.slt-pc         no-undo.
define variable v-host-code                               like sysconf.host-code          no-undo.
define variable v-tax-date                                as   date                       no-undo.
define variable is-petrol                                 as   logical                    no-undo.
define variable is-pieces                                 as   logical                    no-undo.
define variable doc-qnty-lt                               as   decimal                    no-undo.
define variable doc-qnty-kg                               as   decimal                    no-undo.
define variable fact-qnty-lt                              as   decimal                    no-undo.
define variable fact-qnty-kg                              as   decimal                    no-undo.
define variable varlog                                    as   logical                    no-undo.
define variable varpart-rec                               as   recid                      no-undo.
define variable varinv-rec                                as   recid                      no-undo.
define variable prt-mode                                  as   character                  no-undo.
define variable vardoc-qnty-doc-pl                        as   decimal                    no-undo.
define variable varfact-qnty-doc-pl                       as   decimal                    no-undo.
define variable varcli-doc-qnty-doc-pl                    as   decimal                    no-undo.
define variable varcli-fact-qnty-doc-pl                   as   decimal                    no-undo.
define variable v-round-vat-sum                           as   logical                    no-undo.
define variable v-sum-vat                                 as   decimal                    no-undo.
define variable v-node-type                               as   character                  no-undo.
define variable varvalue        as character no-undo .
define variable vartype         as character no-undo .
define variable v-message       as character no-undo .
define variable mark            as character no-undo .
define variable v-stop          as logical   no-undo init no .
define variable EDOParSec       as class     ibs.th.gbl.env.prmtrs.edo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type14 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type14
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type14 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type14
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
define temp-table old-gds-dtl no-undo like ub.gds-dtl.
do
on error undo, return error return-value
:
  find first t-doc where recid(t-doc) = pardoc-rec exclusive-lock.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input t-doc.obj-type
  ,input t-doc.obj-code
  ,input 'nakl_par':U
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
        if thbjattr_thbj-attr.prop-code = 'round-vat-sum' then v-round-vat-sum = thbjattr_thbj-attr.property-value-logical .
    end.
  assign
    work-mode = trim(work-mode)
    v-is-return = false
  .
  if num-entries(work-mode, chr(4)) = 2
  then do :
    if entry(2, work-mode, chr(4)) begins "return"
    then do :
      v-is-return = true .
      varpart-rec = integer(trim(entry(2, work-mode, chr(4)), "return=")) no-error .
    end .
    work-mode = entry(1, work-mode, chr(4)) .
  end.
  do while no-end-all-operation
  :
    assign
      no-end-all-operation = no
    .
    if can-do ('процент,карта,группа,сумма,строка,прайс-лист':U, t-doc.discnt-type) and
        not
        (t-doc.discnt-type = 'сумма':U and
        not t-doc.flag_             and
        t-doc.status_ <> 'разрешен':U    )
    then do:
       assign
         flag-incr-disc-vat = yes
       .
    end.
    if work-mode = "b-c"
    then do:
      assign
        b-c      = int(entry(1, parvalue))
        rate     = dec(entry(2, parvalue))
        add-sens = (if entry(4, parvalue) = "yes" then yes else no)
        qnty-str = (if entry(5, parvalue) = "yes" then "1" else "0")
      .
      find ub.bar-code where ub.bar-code.b-code = b-c no-lock.
      find p-goods where p-goods.gds-code  = ub.bar-code.gds-code no-lock.
      assign
        pargds-rec = recid(p-goods)
      .
      find first ub.gds-dtl where
                ub.gds-dtl.doc-code  = t-doc.doc-code     and
                ub.gds-dtl.artic     = p-goods.artic        and
                ub.gds-dtl.prod-type = p-goods.prod-type    and
                ub.gds-dtl.prod-code = p-goods.prod-code    and
                ub.gds-dtl.prt-code  = ub.bar-code.node-code no-lock no-error.
      if available ub.gds-dtl
      then do:
        if not varrep
        then do:
          varlog = no.
          message "Такой признак уже есть в этой накладной. Вы хотите изменить его ?"
          view-as alert-box question buttons yes-no update varlog.
          if not varlog
          then do:
            return .
          end.
        end.
        assign
          parprt-rec = recid(ub.gds-dtl)
        .
        find first p-doc-line no-lock
          where p-doc-line.doc-code = t-doc.doc-code
            and ub.gds-dtl.artic     = p-doc-line.artic
            and ub.gds-dtl.prod-type = p-doc-line.prod-type
            and ub.gds-dtl.prod-code = p-doc-line.prod-code
          .
        assign
          parline-rec = recid(p-doc-line)
        .
        if entry(5, parvalue) = "no"
        then do:
          assign
            work-mode = 'ИЗМЕНЕНИЕ':U
          .
        end.
      end.
      else do:
        assign
          parprt-rec = ?
        .
      end.
    end.
    if work-mode = 'ДОБАВЛЕНИЕ':U
    or work-mode = "ЦИКЛ"
    or work-mode = "b-c"
    then do:
        find p-goods no-lock
          where recid(p-goods) = pargds-rec
          .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_goods-tr in g#lib-trn3
(input recid(t-doc)
,input recid(p-goods)
) no-error
.
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры goods-tr"
            error-status :get-message(1) skip
            return-value
            view-as alert-box.
          return error.
        end.
        find p-doc-line exclusive-lock
          where p-doc-line.prod-code = p-goods.prod-code
            and p-doc-line.prod-type = p-goods.prod-type
            and p-doc-line.artic     = p-goods.artic
            and p-doc-line.doc-code  = t-doc.doc-code
          no-error .
        if available p-doc-line
        then do:
          if work-mode <> "b-c"
          then do:
            varlog = no.
            message "Такой товар уже есть в этой накладной. Вы хотите изменить его ?"
                            view-as alert-box question buttons yes-no update varlog.
            if not varlog then do:
              return error.
            end.
          end.
          assign
            parline-rec = recid(p-doc-line)
          .
        end.
        find ub.gds-prt where ub.gds-prt.upper-code = p-goods.prt-root no-lock.
    end.
    else do:
      if work-mode = 'ПРОСМОТР':U
      or work-mode = "lookup-scale"
      or work-mode = "lookup-parts"
      then do:
        find p-doc-line no-lock
          where recid(p-doc-line) = parline-rec
          .
        find ub.gds-dtl no-lock
          where recid(ub.gds-dtl) = parprt-rec
          .
      end.
      else do:
        find p-doc-line exclusive-lock
          where recid(p-doc-line) = parline-rec
          .
        find ub.gds-dtl exclusive-lock
          where recid(ub.gds-dtl) = parprt-rec
          .
      end.
      find p-goods no-lock
        where recid(p-goods) = pargds-rec
        .
      find ub.gds-prt no-lock
        where ub.gds-prt.node-code = ub.gds-dtl.prt-code
        .
    end.
    find first units no-lock
      where units.unit-name = p-goods.unit-base
      .
    if lookup('2ед':U, units.type) > 0
    then do:
      assign
        vartwo-value = yes
      .
    end.
    else do:
      assign
        vartwo-value  = no
      .
    end.
    if available p-doc-line
    then do:
      if  work-mode <> 'ПРОСМОТР':U
      and work-mode <> "lookup-scale"
      and work-mode <> "lookup-parts"
      then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_acc-cost in g#lib-trn
(
 input  p-doc-line.obj-type
,input  p-doc-line.obj-code
,input  p-doc-line.doc-code
,input  p-doc-line.artic
,input  p-doc-line.prod-type
,input  p-doc-line.prod-code
,input  p-doc-line.cli-qnty
,input  p-doc-line.doc-qnty
,input  p-doc-line.fact-qnty
,input  p-doc-line.price-base
,input  p-doc-line.price-rubl
,input  'old'
,output o-total-doc-line_tot-ovold
,output o-total-doc-line_fact-rublold
,output o-total-doc-line_fact-baseold
,output o-total-doc-line_fact-qntyold
,output o-total-doc-line_doc-qntyold
,output o-total-doc-line_cli-qntyold
)
no-error.
        if error-status :error
        then do:
          return error return-value.
        end.
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_accgdspr in g#lib-calc
(
 input  recid(p-doc-line)
,input  no
,output varagsum-base-docold
,output varagsum-rubl-docold
,output varagsum-base-factold
,output varagsum-rubl-factold
,output varagcountold
) no-error.
        if error-status :error
        then do:
          undo, return error return-value.
        end.
        if flag-incr-disc-vat
        then do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_acsupacc in g#lib-calc
  (
   input  recid(p-doc-line)
  ,output varroad-tax-fact-baseold
  ,output varexcise-fact-baseold
  ,output varslt-fact-baseold
  ,output varvat-fact-baseold
  ,output varslt-doc-baseold
  ,output varvat-doc-baseold
  ,output varsum-fact-out-dsv-baseold
  ,output varroad-tax-fact-rublold
  ,output varexcise-fact-rublold
  ,output varslt-fact-rublold
  ,output varvat-fact-rublold
  ,output varslt-doc-rublold
  ,output varvat-doc-rublold
  ,output varsum-fact-out-dsv-rublold
  ,output varsum-fact-out-dsc-baseold
  ,output varsum-fact-out-dsc-rublold
  ,output varsum-fact-curold
  ,output varov-fact-baseold
  ,output varov-vat-fact-baseold
  ,output varsum-doc-curold
  ,output varov-doc-baseold
  ,output varov-vat-doc-baseold
  ,output varsum-doc-baseold
  ,output varsum-doc-rublold
  ,output varroad-tax-factold
  ,output varexcise-factold
  ,output varroad-tax-docold
  ,output varexcise-docold
  ,output vardiscnt-base-docold
  ,output vardiscnt-rubl-docold
  ,output vardiscnt-base-factold
  ,output vardiscnt-rubl-factold
  ) no-error.
          if error-status :error
          then do:
            return error return-value.
          end.
        end.
        if parprt-rec <> ?
        then do:
          find ub.gds-dtl exclusive-lock
            where recid(ub.gds-dtl) = parprt-rec
            .
        end.
      end.
      assign
        flag-update = yes
      .
      assign
        parline-rec = recid(p-doc-line)
      .
    end.
    else do:
      if work-mode <> "b-c"
      then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-host-code
  )  .
        if
              t-doc.fact-date <> ?
        then do:
          assign
            v-tax-date = t-doc.fact-date
          .
        end.
        else do:
          assign
            v-tax-date = ?
          .
        end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  p-goods.gds-code
  ,input  '1':U
  ,input  v-tax-date
  ,input  v-host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-vat-pc
  ) no-error .
        find first sysconf where sysconf.host-code = t-doc.host-code.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_st-sltpc in g#lib-trn
(
 input  recid(p-goods)
,input  recid(t-doc)
,input  sysconf.cash-pay
,output v-slt-pc
)
.
        if sysconf.cons-vat-pc = ?
        then do:
          message "У Вас не установлен НДС для консигнационного товара по фирме."
          view-as alert-box error.
          return error.
        end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdoclin in g#lib-trn
(input t-doc.doc-code
,input p-goods.artic
,input p-goods.prod-type
,input p-goods.prod-code
,input t-doc.obj-type
,input t-doc.obj-code
,input t-doc.status_
,input t-doc.ext-doc-type
,input p-goods.prt-root
,input v-vat-pc
,input v-slt-pc
,input sysconf.cons-vat-pc
) no-error
.
        if error-status :error
        then do:
          message "Ошибка при создании линии товара " p-goods.artic " "  p-goods.prod-type " " p-goods.prod-code skip
                  return-value skip
                  error-status:get-message(1)
          view-as alert-box error.
          return error.
        end.
        find first p-doc-line exclusive-lock
          where p-doc-line.doc-code  = t-doc.doc-code
            and p-doc-line.artic     = p-goods.artic
            and p-doc-line.prod-type = p-goods.prod-type
            and p-doc-line.prod-code = p-goods.prod-code
          .
        assign
          p-doc-line.doc-qnty       = 0
          p-doc-line.unit-cli       = p-goods.unit-cli
          p-doc-line.cli-base-rate  = p-goods.cli-base-rate
          parline-rec                = recid(p-doc-line)
        .
        if v-is-return
        and t-doc.reason-code = 25
        and varpart-rec > 0
        then do :
          find first in_parts no-lock where recid(in_parts) = varpart-rec no-error .
          if available in_parts
          then do :
            assign
              p-doc-line.VAT-pc = in_parts.VAT-pc
              p-doc-line.SLT-pc = in_parts.SLT-pc
            .
          end .
        end .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input p-doc-line.artic
  ,  input p-doc-line.prod-type
  ,  input p-doc-line.prod-code
  , output is-petrol
  , output is-pieces
  ) .
      end.
      assign
        flag-update = no
      .
    end.
    case work-mode
    :
      when 'ДОБАВЛЕНИЕ':U       or
      when "ЦИКЛ":u         or
      when 'ИЗМЕНЕНИЕ':U        or
      when 'ПРОСМОТР':U        or
      when "update-scale":u or
      when "lookup-scale":u or
      when "update-parts":u or
      when "lookup-parts":u
      then do:
        if      t-doc.ext-doc-type eq 'ep':U
            and parvalue begins 'scan-marks'
        then do:
           Find first marking where marking.mark begins entry(2,parvalue,chr(3))
           no-lock no-error.
        end.
        if (
                t-doc.ext-doc-type eq 'ep':U
            and not avail Marking
            and t-doc.status_ <> 'запрос':U
            and work-mode <> "update-scale":u
            and work-mode <> "lookup-scale":u
           )
        or work-mode    =  "lookup-parts":u
        or work-mode    =  "update-parts":u
        or vartwo-value =  yes
        then do:
          if  ub.gds-prt.node-name <> '_Пустая шкала':U
          and v-cntxp-doc-prt
          and work-mode <> "lookup-parts":u
          and work-mode <> "update-parts":u
          then do:
            define variable v-prt-doc-mode as character no-undo .
            define variable v-update-doc   as logical   no-undo .
            define variable v-node-code    as integer   no-undo .
            define buffer buf_reposition_gds-dtl for ub.gds-dtl .
            if work-mode <> 'ПРОСМОТР':U
            then do:
              assign
                v-prt-doc-mode = 'ШКАЛА':U
              .
            end.
            else do:
              assign
                v-prt-doc-mode = 'ПРОСМОТР':U
              .
            end.
            if  t-doc.flag_   <> true
            and t-doc.status_ <> 'разрешен':U
            and t-doc.status_ <> 'факт':U
            then do:
              assign
                v-update-doc = true
              .
            end.
            else do:
              assign
                v-update-doc = false
              .
            end.
            find first buf_reposition_gds-dtl no-lock
              where recid(buf_reposition_gds-dtl) = parprt-rec
              no-error .
            if available buf_reposition_gds-dtl
            then do:
              assign
                v-node-code = buf_reposition_gds-dtl.prt-code
              .
            end.
            else do:
              assign
                v-node-code = ?
              .
            end.
            run str/prt-doc.w
              (input  ParParentProc
              ,input  t-doc.doc-code
              ,input  p-goods.gds-code
              ,input  v-node-code
              ,input  v-prt-doc-mode
              ,input  v-update-doc
              ) .
          end.
          else do:
            run str/parts-l.w
              (input ParParentProc
              ,input t-doc.obj-type
              ,input t-doc.obj-code
              ,input p-goods.gds-code
              ,input t-doc.doc-code
              ,input (if v-is-return then "vsd" else if work-mode = 'ПРОСМОТР':U or  work-mode = "lookup-parts" then 'ПРОСМОТР':U else 'ИЗМЕНЕНИЕ':U)
              ,input 'документ':U
              ,input 'текущий':U
              ,input 'документ':U
              ,output varpart-rec
              ) no-error .
          end.
          if work-mode = "lookup-parts":u
          or v-is-return
          then do:
            assign
              work-mode = 'ПРОСМОТР':U
            .
          end.
          if work-mode = "update-parts":u
          then do:
            assign
              work-mode = 'ИЗМЕНЕНИЕ':U
            .
          end.
          if work-mode = "ЦИКЛ":u
          then do:
            assign
              work-mode = 'ДОБАВЛЕНИЕ':U
            .
          end.
          if work-mode <> 'ПРОСМОТР':U then do:
            assign
              line-mode = 'ИЗМЕНЕНИЕ':U.
          end.
          else do:
            assign
              line-mode = 'ИЗМЕНЕНИЕ':U.
          end.
          if  ( t-doc.ext-doc-type = 'ep':U
                and t-doc.status_ <> 'запрос':U
              )
          and work-mode <> "update-scale":u
          and work-mode <> "lookup-scale":u
          and work-mode <> 'ПРОСМОТР':U
          then do:
            find first parts no-lock
              where parts.obj-type  = t-doc.obj-type
                and parts.obj-code  = t-doc.obj-code
                and parts.artic     = p-doc-line.artic
                and parts.prod-type = p-doc-line.prod-type
                and parts.prod-code = p-doc-line.prod-code
                and parts.out-code  = t-doc.doc-code
              no-error .
            if available parts then do:
              find first bf-parts no-lock
                where bf-parts.obj-type  = parts.obj-type
                  and bf-parts.obj-code  = parts.obj-code
                  and bf-parts.out-code  = parts.out-code
                  and bf-parts.artic     = p-doc-line.artic
                  and bf-parts.prod-type = p-doc-line.prod-type
                  and bf-parts.prod-code = p-doc-line.prod-code
                  and bf-parts.vat-pc    <> parts.vat-pc
                no-error .
              if available bf-parts
              then do:
                message "При возврате нельзя выбирать партии с разными НДС, следует сделать разные документы возврата."
                  view-as alert-box error buttons ok.
                undo, return error.
              end.
              find first bf-parts no-lock
                where bf-parts.obj-type  = parts.obj-type
                  and bf-parts.obj-code  = parts.obj-code
                  and bf-parts.out-code  = parts.out-code
                  and bf-parts.artic     = p-doc-line.artic
                  and bf-parts.prod-type = p-doc-line.prod-type
                  and bf-parts.prod-code = p-doc-line.prod-code
                  and bf-parts.slt-pc    <> parts.slt-pc
                no-error.
              if available bf-parts then do:
                message "При возврате нельзя выбирать партии, которые мы приняли с разными налогами с продаж, следует сделать разные документы возврата."
                  view-as alert-box error buttons ok.
                undo, return error.
              end.
              assign
                p-doc-line.vat-pc = parts.vat-pc
                p-doc-line.slt-pc = parts.slt-pc
              .
            end.
          end.
        end.
        else do:
          if ub.gds-prt.node-name <> '_Пустая шкала':U and v-cntxp-doc-prt
          then do:
            if  work-mode <> 'ПРОСМОТР':U
            and work-mode <> "lookup-scale":u
            then do:
              assign
                v-prt-doc-mode = 'ШКАЛА':U
              .
            end.
            else do:
              assign
                v-prt-doc-mode = 'ПРОСМОТР':U
              .
            end.
            if work-mode = 'ДОБАВЛЕНИЕ':U
            or work-mode = "ЦИКЛ":u
            or work-mode = "update-scale":u
            or work-mode = "lookup-scale":u
            then do:
              if  t-doc.flag_   <> true
              and t-doc.status_ <> 'разрешен':U
              and t-doc.status_ <> 'факт':U
              then do:
                assign
                  v-update-doc = true
                .
              end.
              else do:
                assign
                  v-update-doc = false
                .
              end.
              find first buf_reposition_gds-dtl no-lock
                where recid(buf_reposition_gds-dtl) = parprt-rec
                no-error .
              if available buf_reposition_gds-dtl
              then do:
                assign
                  v-node-code = buf_reposition_gds-dtl.prt-code
                .
              end.
              else do:
                assign
                  v-node-code = ?
                .
              end.
              run str/prt-doc.w
                (input  ParParentProc
                ,input  t-doc.doc-code
                ,input  p-goods.gds-code
                ,input  v-node-code
                ,input  v-prt-doc-mode
                ,input  v-update-doc
                ) .
            end.
            else do:
              if work-mode = 'ИЗМЕНЕНИЕ':U
              or work-mode = 'ПРОСМОТР':U
              then do:
                if parvalue begins 'scan-marks' then v-node-type = parvalue. else v-node-type = 'терм':U.
                run str/out-prt.w (
                  ParParentProc ,
                  pardoc-rec    ,
                  parline-rec   ,
                  pargds-rec       ,
                  (if work-mode = 'ИЗМЕНЕНИЕ':U then 'ШКАЛА':U else 'ПРОСМОТР':U) + (if v-is-return then (chr(4) + "return") else "") ,
                  recid(ub.gds-prt),
                  v-node-type) no-error.
              end.
            end.
          end.
          else do:
            if parvalue begins 'scan-marks' then v-node-type = parvalue. else v-node-type = 'корн':U.
            if parvalue = "Transitional" then v-node-type = parvalue.
            find first bf_gds-obj no-lock where bf_gds-obj.obj-type  = t-doc.obj-type
                                            and bf_gds-obj.obj-code  = t-doc.obj-code
                                            and bf_gds-obj.artic     = p-goods.artic
                                            and bf_gds-obj.prod-type = p-goods.prod-type
                                            and bf_gds-obj.prod-code = p-goods.prod-code
                                            no-error .
            if error-status :error
            then do:
                  return error return-value.
            end.
            run str/out-prt.w (
              ParParentProc ,
              pardoc-rec    ,
              parline-rec   ,
              pargds-rec       ,
              (if work-mode <> 'ПРОСМОТР':U then 'БЕЗ_ПРИЗНАКОВ':U else 'ПРОСМОТР':U) + (if v-is-return then (chr(4) + "return=" + string(varpart-rec)) else "") ,
              recid(ub.gds-prt),
              v-node-type) no-error.
            if error-status :error
            then do:
                  return error return-value.
            end.
            if (return-value = "no-add-marks" and parvalue begins 'scan-marks')
            or bf_gds-obj.free-qnty < 0
            then do :
              v-stop = yes .
            end .
            if v-is-return
            and parvalue begins 'scan-marks'
            and not v-stop
            then do :
              EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code).
              RUN gds-attr-value (
              INPUT p-goods.gds-code,
              INPUT 'mark-type':U,
              OUTPUT varvalue,
              OUTPUT vartype
              ).
              if EDOParSec:GetIsEDOForType(varvalue)
              or EDOParSec:GetIsArticForType(varvalue)
              or EDOParSec:GetIsMarkingForType(varvalue)
              then do :
                EACH_PARTS:
                for each bf_parts no-lock where bf_parts.obj-type  = t-doc.obj-type
                                             and bf_parts.obj-code  = t-doc.obj-code
                                             and bf_parts.artic     = p-goods.artic
                                             and bf_parts.prod-type = p-goods.prod-type
                                             and bf_parts.prod-code = p-goods.prod-code
                                             and bf_parts.out-code  = t-doc.doc-code
                  , first bf_marking-lines no-lock where bf_marking-lines.obj-type = bf_parts.obj-type
                                                          and bf_marking-lines.obj-code = bf_parts.obj-code
                                                          and bf_marking-lines.gds-code = p-goods.gds-code
                                                          and bf_marking-lines.in-code  = bf_parts.in-code
                                                          and bf_marking-lines.out-code = bf_parts.out-code
                                                          and bf_marking-lines.part-code = bf_parts.part-code
                                                          and bf_marking-lines.mark begins entry(2,parvalue,chr(3))
                  :
                  leave EACH_PARTS.
                end .
                if not available bf_marking-lines
                then do :
                  create bf_marking-lines .
                  assign
                    bf_marking-lines.obj-type = t-doc.obj-type
                    bf_marking-lines.obj-code = t-doc.obj-code
                    bf_marking-lines.gds-code = p-goods.gds-code
                    bf_marking-lines.in-code  = bf_parts.in-code
                    bf_marking-lines.out-code = t-doc.doc-code
                    bf_marking-lines.part-code = bf_parts.part-code
                    bf_marking-lines.prt-code = bf_parts.prt-code
                    bf_marking-lines.doc-level = 1
                    bf_marking-lines.mark = entry(2,parvalue,chr(3))
                  .
                  validate bf_marking-lines .
                end .
              end .
            end .
            if bf_gds-obj.free-qnty <= 0
            then do :
              v-stop = yes .
            end .
          end.
        end.
        if parvalue begins 'scan-marks' or parvalue = "Transitional" then. else do:
        if parvalue <> ? then do:
           if num-entries(parvalue) = 1 then
                run str/florline.p (
                    input ParParentProc ,
                    input work-mode ,
                    input v-node-code ,
                    input t-doc.doc-code ,
                    input p-goods.gds-code ,
                    input integer(parvalue)  ) .
        end.
        end.
      end.
      when "ch-doc-qnty"
      then do:
          find first doc-line exclusive-lock where
                     recid(doc-line)  = parline-rec no-error .
         if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              ""
              view-as alert-box error
            .
         end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  chg-qnty = dec(parvalue) - ub.gds-dtl.doc-qnty
.
  run trg/rsrv-dtl.p
    ( input        ParParentProc
    , input        'reserv':U
    , buffer       ub.gds-dtl
    , input-output chg-qnty
    , input-output ub.doc-line.price-base
    , input-output ub.doc-line.price-rubl
    , input        -1
    , input         "" ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "rsrv-dtl.p doc"
      view-as alert-box error
.
    undo, return error return-value .
  end.
  if lookup( t-doc.doc-type, 'рас,спи,возврат':U ) > 0 or
     ( t-doc.doc-type = 'при':U and
       t-doc.internal = yes )
  then do:
    assign
      ub.doc-line.doc-qnty  = ub.doc-line.doc-qnty + chg-qnty
      ub.doc-line.fact-qnty = ub.doc-line.doc-qnty
    .
    if ub.doc-line.doc-density <> ? and ub.doc-line.doc-density <> 0 then do:
      assign
        ub.doc-line.cli-qnty = ub.doc-line.doc-qnty * ub.doc-line.doc-density
      .
    end.
    else do:
      assign
        ub.doc-line.cli-qnty = ub.doc-line.doc-qnty / ub.doc-line.cli-base-rate
      .
    end.
  end.
  assign
    ub.gds-dtl.doc-qnty  = ub.gds-dtl.doc-qnty + chg-qnty
    ub.gds-dtl.fact-qnty = ub.gds-dtl.doc-qnty
  .
      end.
      when "ch-fact-qnty"
      then do:
          find first doc-line exclusive-lock where
                     recid(doc-line)  = parline-rec no-error .
         if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              ""
              view-as alert-box error
            .
         end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  chg-qnty = dec(parvalue) - ub.gds-dtl.fact-qnty
.
  run trg/rsrv-dtl.p
    ( input        ParParentProc
    , input        'reserv':U
    , buffer       ub.gds-dtl
    , input-output chg-qnty
    , input-output ub.doc-line.price-base
    , input-output ub.doc-line.price-rubl
    , input        -1
    , input         "" ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "rsrv-dtl.p fact"
      view-as alert-box error
.
    undo, return error return-value .
  end.
  if lookup( t-doc.doc-type, 'рас,спи,возврат':U ) > 0 or
     ( t-doc.doc-type = 'при':U and
       t-doc.internal = yes )
  then do:
    assign
      ub.doc-line.fact-qnty = ub.doc-line.fact-qnty + chg-qnty
    .
  end.
  assign
    ub.gds-dtl.fact-qnty = ub.gds-dtl.fact-qnty + chg-qnty
  .
      end.
      when "update-sale-price"
      then do:
        if t-doc.print-rubl
        then do:
          assign
            ub.gds-dtl.price-rubl = decimal(parvalue)
            ub.gds-dtl.price-base = ub.gds-dtl.price-rubl / t-doc.base-rate * t-doc.base-scale
          .
        end.
        else do:
          assign
            ub.gds-dtl.price-base = decimal(parvalue)
            ub.gds-dtl.price-rubl = ub.gds-dtl.price-base * t-doc.base-rate / t-doc.base-scale
          .
        end.
        assign
          ub.gds-dtl.ov = yes
        .
      end.
      when "delete"
      then do:
        assign
          unrv-qnty = - ub.gds-dtl.doc-qnty
        .
        if is-petrol = yes and
           is-pieces = no
        then do:
          define variable d_unrv-qty as decimal no-undo .
          for each bf_doc-pl exclusive-lock
            where bf_doc-pl.obj-type = ub.gds-dtl.obj-type
              and bf_doc-pl.obj-code = ub.gds-dtl.obj-code
              and bf_doc-pl.out-code = ub.gds-dtl.doc-code
              and bf_doc-pl.gds-code = p-goods.gds-code
          on error undo, return error return-value
          :
            assign
              d_unrv-qty = ( - bf_doc-pl.doc-qnty )
            .
            run trg/rsrv-dtl.p
              ( input        ParParentProc
              , input        'reserv':U + ',' + 'plcode':U + '=' + string( bf_doc-pl.pl-code )
              , buffer       ub.gds-dtl
              , input-output d_unrv-qty
              , input-output p-doc-line.price-base
              , input-output p-doc-line.price-rubl
              , input        -1
              , input       if parvalue begins 'scan-mark' then entry(2,parvalue,chr(3)) else ""
              ) no-error .
            if error-status :error
            then do:
              undo, return error .
            end.
            if d_unrv-qty <> - bf_doc-pl.doc-qnty then do:
              message
                "Не удается разрезервировать все количество по резервуару" bf_doc-pl.pl-code
                "для удаления строки" p-goods.artic p-goods.prod-type p-goods.prod-code "."
                view-as alert-box error .
              undo, return error .
            end.
          end.
        end.
        else do:
          run trg/rsrv-dtl.p
            ( input        ParParentProc
            , input        'reserv':U
            , buffer       ub.gds-dtl
            , input-output unrv-qnty
            , input-output p-doc-line.price-base
            , input-output p-doc-line.price-rubl
            , input        -1
            , input        if parvalue begins 'scan-mark' then entry(2,parvalue,chr(3)) else ""
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              "trg/rsrv-dtl.p"
              view-as alert-box error
            .
            undo, return error .
          end.
          if unrv-qnty <> - ub.gds-dtl.doc-qnty
          then do:
            message "Не удается разрезервировать все кол-во по признаку для удаления строки."
              view-as alert-box error buttons ok .
              undo, return error .
          end.
        end.
        assign
          p-doc-line.doc-qnty  = p-doc-line.doc-qnty + unrv-qnty
          p-doc-line.fact-qnty = p-doc-line.doc-qnty
        .
        for each old-gds-dtl
        on error undo, return error return-value
        :
          delete old-gds-dtl .
        end.
        create old-gds-dtl .
        buffer-copy ub.gds-dtl to old-gds-dtl .
        run lineattr-delete-flora-all (
              ub.gds-dtl.doc-code ,
              p-goods.gds-code     ,
              ub.gds-dtl.prt-code   ).
        delete ub.gds-dtl .
      end.
      when "b-c"
      then do:
        assign
          line-mode = "b-c"
        .
        find first goods where recid(goods) = recid(p-goods).
        run proc-code in this-procedure
          (input ?
          ,input entry(3,parvalue)
          ,input varscales-pref
          ,input varpgscales-pref
          ) no-error .
        if error-status :error
        then do:
          return error return-value.
        end.
        find p-doc-line exclusive-lock
          where p-doc-line.prod-code = p-goods.prod-code
            and p-doc-line.prod-type = p-goods.prod-type
            and p-doc-line.artic     = p-goods.artic
            and p-doc-line.doc-code  = t-doc.doc-code
          .
        assign
          parline-rec = recid(p-doc-line)
        .
        if entry(5, parvalue) = "no"
        then do:
          assign
            varrep = yes
            no-end-all-operation = yes
          .
        end.
      end.
    end case.
    find p-doc-line
      where recid(p-doc-line) = parline-rec
      .
    find p-goods no-lock
      where p-doc-line.prod-code = p-goods.prod-code
        and p-doc-line.prod-type = p-goods.prod-type
        and p-doc-line.artic     = p-goods.artic
      .
    if v-round-vat-sum then do:
        if (
            t-doc.ext-doc-type = 'ep':U
            and t-doc.status_ <> 'запрос':U
            and work-mode <> "update-scale":u
            and work-mode <> "lookup-scale":u
           )
        or work-mode    =  "lookup-parts":u
        or work-mode    =  "update-parts":u
        or vartwo-value =  yes
        then do:
        end.
        else do:
          find first ub.gds-dtl no-lock
               where ub.gds-dtl.artic     = p-doc-line.artic
                 and ub.gds-dtl.prod-type = p-doc-line.prod-type
                 and ub.gds-dtl.prod-code = p-doc-line.prod-code
                 and ub.gds-dtl.doc-code  = p-doc-line.doc-code
                no-error.
          if available ub.gds-dtl then do:
            assign v-sum-vat = round(((ub.gds-dtl.price-rubl - ub.gds-dtl.price-rubl * p-doc-line.slt-pc / (100 + p-doc-line.slt-pc) ) * p-doc-line.vat-pc / (100 + p-doc-line.vat-pc) ) * p-doc-line.cli-qnty, 2 ) .
            if v-sum-vat <> 0 and v-sum-vat <> ?
            then
              assign p-doc-line.vat-pc = (v-sum-vat / ( p-doc-line.cli-qnty * ub.gds-dtl.price-rubl
                    * ( 1 - (p-doc-line.slt-pc / (100 + p-doc-line.slt-pc)))
                    - v-sum-vat )) * 100.
          end.
        end.
    end.
    if work-mode = "lookup-scale":u
    or work-mode = "lookup-parts":u
    then do:
      assign
        work-mode = 'ПРОСМОТР':U
      .
    end.
    if  work-mode <> "delete":u
    and work-mode <> 'ДОБАВЛЕНИЕ':U
    and work-mode <> "ЦИКЛ":u
    and work-mode <> 'ПРОСМОТР':U
    and work-mode <> "b-c":u
    then do:
      assign
        work-mode = 'ИЗМЕНЕНИЕ':U
      .
    end.
    if (work-mode = 'ДОБАВЛЕНИЕ':U or
        work-mode = "ЦИКЛ":u       )
    and flag-update = yes
    then do:
      assign
        work-mode = 'ИЗМЕНЕНИЕ':U
      .
    end.
    if work-mode <> 'ПРОСМОТР':U
    then do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_accgdspr in g#lib-calc
(
 input  recid(p-doc-line)
,input  yes
,output varagsum-base-docnew
,output varagsum-rubl-docnew
,output varagsum-base-factnew
,output varagsum-rubl-factnew
,output varagcountnew
) no-error.
      if error-status :error
      then do:
        undo, return error return-value.
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_acc-cost in g#lib-trn
(
 input  p-doc-line.obj-type
,input  p-doc-line.obj-code
,input  p-doc-line.doc-code
,input  p-doc-line.artic
,input  p-doc-line.prod-type
,input  p-doc-line.prod-code
,input  p-doc-line.cli-qnty
,input  p-doc-line.doc-qnty
,input  p-doc-line.fact-qnty
,input  p-doc-line.price-base
,input  p-doc-line.price-rubl
,input  'new'
,output o-total-doc-line_tot-ovnew
,output o-total-doc-line_fact-rublnew
,output o-total-doc-line_fact-basenew
,output o-total-doc-line_fact-qntynew
,output o-total-doc-line_doc-qntynew
,output o-total-doc-line_cli-qntynew
)
no-error.
      if error-status :error
      then do:
        return error return-value.
      end.
      case work-mode:
        when 'ИЗМЕНЕНИЕ':U
        then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcdocpr in g#lib-trn
(
 input  recid(t-doc)
,input  varagsum-base-docnew
,input  varagsum-rubl-docnew
,input  varagsum-base-factnew
,input  varagsum-rubl-factnew
,input  varagcountnew
,input  varagsum-base-docold
,input  varagsum-rubl-docold
,input  varagsum-base-factold
,input  varagsum-rubl-factold
,input  varagcountold
  ) no-error.
        end.
        when "delete"
        then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcdocpr in g#lib-trn
(
 input  recid(t-doc)
,input  varagsum-base-docnew
,input  varagsum-rubl-docnew
,input  varagsum-base-factnew
,input  varagsum-rubl-factnew
,input  varagcountnew
,input  varagsum-base-docold
,input  varagsum-rubl-docold
,input  varagsum-base-factold
,input  varagsum-rubl-factold
,input  varagcountold
  ) no-error.
        end.
        when 'ДОБАВЛЕНИЕ':U or
        when "ЦИКЛ"
        then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcdocpr in g#lib-trn
(
 input  recid(t-doc)
,input  varagsum-base-docnew
,input  varagsum-rubl-docnew
,input  varagsum-base-factnew
,input  varagsum-rubl-factnew
,input  varagcountnew
,input  0
,input  0
,input  0
,input  0
,input  0
  ) no-error.
        end.
        when "b-c"
        then do:
          if flag-update = yes
          then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcdocpr in g#lib-trn
(
 input  recid(t-doc)
,input  varagsum-base-docnew
,input  varagsum-rubl-docnew
,input  varagsum-base-factnew
,input  varagsum-rubl-factnew
,input  varagcountnew
,input  varagsum-base-docold
,input  varagsum-rubl-docold
,input  varagsum-base-factold
,input  varagsum-rubl-factold
,input  varagcountold
  ) no-error.
          end.
          else do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcdocpr in g#lib-trn
(
 input  recid(t-doc)
,input  varagsum-base-docnew
,input  varagsum-rubl-docnew
,input  varagsum-base-factnew
,input  varagsum-rubl-factnew
,input  varagcountnew
,input  0
,input  0
,input  0
,input  0
,input  0
  ) no-error.
          end.
        end.
        otherwise do:
          message
            "Неизвестный режим:" work-mode skip
            view-as alert-box error buttons ok.
          return error.
        end.
      end case.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_ass-cost in g#lib-trn
(
 input recid(t-doc)
,input o-total-doc-line_tot-ovnew
,input o-total-doc-line_fact-rublnew
,input o-total-doc-line_fact-basenew
,input o-total-doc-line_fact-qntynew
,input o-total-doc-line_doc-qntynew
,input o-total-doc-line_cli-qntynew
,input o-total-doc-line_tot-ovold
,input o-total-doc-line_fact-rublold
,input o-total-doc-line_fact-baseold
,input o-total-doc-line_fact-qntyold
,input o-total-doc-line_doc-qntyold
,input o-total-doc-line_cli-qntyold
)
no-error.
      if error-status :error
      then do:
        undo, return error .
      end.
      if not flag-incr-disc-vat
      then do:
        for each p-doc-line exclusive-lock
          where p-doc-line.doc-code = t-doc.doc-code
        on error undo, return error return-value
        :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_reclcdsc in g#lib-trn3
  (input recid(p-doc-line)
  ) no-error.
          if error-status :error
          then do:
            return error return-value .
          end.
        end.
        for each p-doc-line exclusive-lock
          where p-doc-line.doc-code = t-doc.doc-code
        on error undo, return error return-value
        :
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_acsupacc in g#lib-calc
  (
   input  recid(p-doc-line)
  ,output varroad-tax-fact-basenew
  ,output varexcise-fact-basenew
  ,output varslt-fact-basenew
  ,output varvat-fact-basenew
  ,output varslt-doc-basenew
  ,output varvat-doc-basenew
  ,output varsum-fact-out-dsv-basenew
  ,output varroad-tax-fact-rublnew
  ,output varexcise-fact-rublnew
  ,output varslt-fact-rublnew
  ,output varvat-fact-rublnew
  ,output varslt-doc-rublnew
  ,output varvat-doc-rublnew
  ,output varsum-fact-out-dsv-rublnew
  ,output varsum-fact-out-dsc-basenew
  ,output varsum-fact-out-dsc-rublnew
  ,output varsum-fact-curnew
  ,output varov-fact-basenew
  ,output varov-vat-fact-basenew
  ,output varsum-doc-curnew
  ,output varov-doc-basenew
  ,output varov-vat-doc-basenew
  ,output varsum-doc-basenew
  ,output varsum-doc-rublnew
  ,output varroad-tax-factnew
  ,output varexcise-factnew
  ,output varroad-tax-docnew
  ,output varexcise-docnew
  ,output vardiscnt-base-docnew
  ,output vardiscnt-rubl-docnew
  ,output vardiscnt-base-factnew
  ,output vardiscnt-rubl-factnew
  ) no-error.
        end.
        assign
          vartotal-road-tax-fact-base    = vartotal-road-tax-fact-base    + varroad-tax-fact-basenew
          vartotal-excise-fact-base      = vartotal-excise-fact-base      + varexcise-fact-basenew
          vartotal-slt-fact-base         = vartotal-slt-fact-base         + varslt-fact-basenew
          vartotal-vat-fact-base         = vartotal-vat-fact-base         + varvat-fact-basenew
          vartotal-slt-doc-base          = vartotal-slt-doc-base          + varslt-doc-basenew
          vartotal-vat-doc-base          = vartotal-vat-doc-base          + varvat-doc-basenew
          vartotal-sum-fact-out-dsv-base = vartotal-sum-fact-out-dsv-base + varsum-fact-out-dsv-basenew
          vartotal-road-tax-fact-rubl    = vartotal-road-tax-fact-rubl    + varroad-tax-fact-rublnew
          vartotal-excise-fact-rubl      = vartotal-excise-fact-rubl      + varexcise-fact-rublnew
          vartotal-slt-fact-rubl         = vartotal-slt-fact-rubl         + varslt-fact-rublnew
          vartotal-vat-fact-rubl         = vartotal-vat-fact-rubl         + varvat-fact-rublnew
          vartotal-slt-doc-rubl          = vartotal-slt-doc-rubl          + varslt-doc-rublnew
          vartotal-vat-doc-rubl          = vartotal-vat-doc-rubl          + varvat-doc-rublnew
          vartotal-sum-fact-out-dsv-rubl = vartotal-sum-fact-out-dsv-rubl + varsum-fact-out-dsv-rublnew
          vartotal-sum-fact-out-dsc-base = vartotal-sum-fact-out-dsc-base + varsum-fact-out-dsc-basenew
          vartotal-sum-fact-out-dsc-rubl = vartotal-sum-fact-out-dsc-rubl + varsum-fact-out-dsc-rublnew
          vartotal-sum-fact-cur          = vartotal-sum-fact-cur          + varsum-fact-curnew
          vartotal-ov-fact-base          = vartotal-ov-fact-base          + varov-fact-basenew
          vartotal-ov-vat-fact-base      = vartotal-ov-vat-fact-base      + varov-vat-fact-basenew
          vartotal-sum-doc-cur           = vartotal-sum-doc-cur           + varsum-doc-curnew
          vartotal-ov-doc-base           = vartotal-ov-doc-base           + varov-doc-basenew
          vartotal-ov-vat-doc-base       = vartotal-ov-vat-doc-base       + varov-vat-doc-basenew
          vartotal-sum-doc-base          = vartotal-sum-doc-base          + varsum-doc-basenew
          vartotal-sum-doc-rubl          = vartotal-sum-doc-rubl          + varsum-doc-rublnew
          vartotal-road-tax-fact         = vartotal-road-tax-fact         + varroad-tax-factnew
          vartotal-excise-fact           = vartotal-excise-fact           + varexcise-factnew
          vartotal-road-tax-doc          = vartotal-road-tax-doc          + varroad-tax-docnew
          vartotal-excise-doc            = vartotal-excise-doc            + varexcise-docnew
          vartotal-discnt-base-doc       = vartotal-discnt-base-doc       + vardiscnt-base-docnew
          vartotal-discnt-rubl-doc       = vartotal-discnt-rubl-doc       + vardiscnt-rubl-docnew
          vartotal-discnt-base-fact      = vartotal-discnt-base-fact      + vardiscnt-base-factnew
          vartotal-discnt-rubl-fact      = vartotal-discnt-rubl-fact      + vardiscnt-rubl-factnew
        .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcpttrn in g#lib-trn
  (
   input recid(t-doc)
  ,input vartotal-discnt-base-fact
  ,input vartotal-discnt-rubl-fact
  ,input vartotal-road-tax-fact
  ,input vartotal-excise-fact
  ,input vartotal-slt-fact-base
  ,input vartotal-vat-fact-base
  ,input vartotal-slt-fact-rubl
  ,input vartotal-vat-fact-rubl
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ) no-error.
        if error-status :error
        then do:
          return error return-value.
        end.
      end.
      else do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_reclcdsc in g#lib-trn3
  (input recid(p-doc-line)
  ) no-error.
        if error-status :error
        then do:
          return error return-value.
        end.
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_acsupacc in g#lib-calc
  (
   input  recid(p-doc-line)
  ,output varroad-tax-fact-basenew
  ,output varexcise-fact-basenew
  ,output varslt-fact-basenew
  ,output varvat-fact-basenew
  ,output varslt-doc-basenew
  ,output varvat-doc-basenew
  ,output varsum-fact-out-dsv-basenew
  ,output varroad-tax-fact-rublnew
  ,output varexcise-fact-rublnew
  ,output varslt-fact-rublnew
  ,output varvat-fact-rublnew
  ,output varslt-doc-rublnew
  ,output varvat-doc-rublnew
  ,output varsum-fact-out-dsv-rublnew
  ,output varsum-fact-out-dsc-basenew
  ,output varsum-fact-out-dsc-rublnew
  ,output varsum-fact-curnew
  ,output varov-fact-basenew
  ,output varov-vat-fact-basenew
  ,output varsum-doc-curnew
  ,output varov-doc-basenew
  ,output varov-vat-doc-basenew
  ,output varsum-doc-basenew
  ,output varsum-doc-rublnew
  ,output varroad-tax-factnew
  ,output varexcise-factnew
  ,output varroad-tax-docnew
  ,output varexcise-docnew
  ,output vardiscnt-base-docnew
  ,output vardiscnt-rubl-docnew
  ,output vardiscnt-base-factnew
  ,output vardiscnt-rubl-factnew
  ) no-error.
        case work-mode:
          when 'ИЗМЕНЕНИЕ':U
          then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcpttrn in g#lib-trn
  (
   input recid(t-doc)
  ,input vardiscnt-base-factnew
  ,input vardiscnt-rubl-factnew
  ,input varroad-tax-factnew
  ,input varexcise-factnew
  ,input varslt-fact-basenew
  ,input varvat-fact-basenew
  ,input varslt-fact-rublnew
  ,input varvat-fact-rublnew
  ,input vardiscnt-base-factold
  ,input vardiscnt-rubl-factold
  ,input varroad-tax-factold
  ,input varexcise-factold
  ,input varslt-fact-baseold
  ,input varvat-fact-baseold
  ,input varslt-fact-rublold
  ,input varvat-fact-rublold
  ) no-error.
            if error-status :error
            then do:
              return error return-value.
            end.
          end.
          when "delete"
          then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcpttrn in g#lib-trn
  (
   input recid(t-doc)
  ,input vardiscnt-base-factnew
  ,input vardiscnt-rubl-factnew
  ,input varroad-tax-factnew
  ,input varexcise-factnew
  ,input varslt-fact-basenew
  ,input varvat-fact-basenew
  ,input varslt-fact-rublnew
  ,input varvat-fact-rublnew
  ,input vardiscnt-base-factold
  ,input vardiscnt-rubl-factold
  ,input varroad-tax-factold
  ,input varexcise-factold
  ,input varslt-fact-baseold
  ,input varvat-fact-baseold
  ,input varslt-fact-rublold
  ,input varvat-fact-rublold
  ) no-error.
            if error-status :error
            then do:
              return error return-value.
            end.
          end.
          when 'ДОБАВЛЕНИЕ':U or
          when "ЦИКЛ"
          then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcpttrn in g#lib-trn
  (
   input recid(t-doc)
  ,input vardiscnt-base-factnew
  ,input vardiscnt-rubl-factnew
  ,input varroad-tax-factnew
  ,input varexcise-factnew
  ,input varslt-fact-basenew
  ,input varvat-fact-basenew
  ,input varslt-fact-rublnew
  ,input varvat-fact-rublnew
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ) no-error.
            if error-status :error
            then do:
              return error return-value.
            end.
          end.
          when "b-c"
          then do:
            if flag-update = yes
            then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcpttrn in g#lib-trn
  (
   input recid(t-doc)
  ,input vardiscnt-base-factnew
  ,input vardiscnt-rubl-factnew
  ,input varroad-tax-factnew
  ,input varexcise-factnew
  ,input varslt-fact-basenew
  ,input varvat-fact-basenew
  ,input varslt-fact-rublnew
  ,input varvat-fact-rublnew
  ,input vardiscnt-base-factold
  ,input vardiscnt-rubl-factold
  ,input varroad-tax-factold
  ,input varexcise-factold
  ,input varslt-fact-baseold
  ,input varvat-fact-baseold
  ,input varslt-fact-rublold
  ,input varvat-fact-rublold
  ) no-error.
              if error-status :error
              then do:
                return error return-value.
              end.
            end.
            else do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcpttrn in g#lib-trn
  (
   input recid(t-doc)
  ,input vardiscnt-base-factnew
  ,input vardiscnt-rubl-factnew
  ,input varroad-tax-factnew
  ,input varexcise-factnew
  ,input varslt-fact-basenew
  ,input varvat-fact-basenew
  ,input varslt-fact-rublnew
  ,input varvat-fact-rublnew
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ) no-error.
              if error-status :error
              then do:
                return error return-value.
              end.
            end.
          end.
          otherwise do:
            message
              "Неизвестный режим:" work-mode skip
              view-as alert-box error buttons ok.
            return error.
          end.
        end case.
      end.
    end.
  end.
  if  work-mode <> 'ПРОСМОТР':U
  and available p-doc-line
  and p-doc-line.doc-qnty = 0
  and p-doc-line.fact-qnty = 0
  then do:
    delete p-doc-line.
  end.
  if v-stop
  then do :
    return "stop-add-marks" .
  end .
end.
