DEFINE TEMP-TABLE tt-doc-line-attr NO-UNDO LIKE doc-line-attr
       field node-code as int
       field price-rubl as dec
       field price-base as dec.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Доплата по документу (флористы)".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable v-pr-1 as decimal   no-undo .
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter   p-doc-mode  as character no-undo .
define input  parameter   p-doc-code  as character no-undo .
define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
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
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output g#host-code
  ,output g#host-name
  )  .
define buffer nakl_trn-doc for trn-doc.
if p-doc-mode = 'ПРОСМОТР':U then
   find first nakl_trn-doc no-lock  where nakl_trn-doc.doc-code = p-doc-code no-error .
else
  find first nakl_trn-doc exclusive-lock where nakl_trn-doc.doc-code = p-doc-code no-error .
DEF VAR v-sum-deliv AS CHAR NO-UNDO.
define variable v-itogo-base2 like gds-dtl.price-rubl  no-undo .
define variable v-itogo-rubl2 like gds-dtl.price-rubl   no-undo .
define variable v-pr-dl like gds-dtl.price-rubl no-undo .
DEFINE BUTTON B-calc
     LABEL "Пересчитать"
     SIZE 15 BY 1.13 TOOLTIP "Пересчитать % за работу и Сумму к оплате исходя из суммы Предоплата+Доплата".
DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-ok AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE F- AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     LABEL "Получено"
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Предоплата + Доплата" NO-UNDO.
DEFINE VARIABLE f-1 AS CHARACTER FORMAT "X(256)":U INITIAL " По накладной"
      VIEW-AS TEXT
     SIZE 87 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE f-2 AS CHARACTER FORMAT "X(256)":U INITIAL " Доставка"
      VIEW-AS TEXT
     SIZE 87 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE f-3 AS CHARACTER FORMAT "X(256)":U INITIAL " Предоплата"
      VIEW-AS TEXT
     SIZE 87.5 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE f-4 AS CHARACTER FORMAT "X(256)":U INITIAL " Доплата"
      VIEW-AS TEXT
     SIZE 43.5 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE f-5 AS CHARACTER FORMAT "X(256)":U INITIAL "Наценка"
      VIEW-AS TEXT
     SIZE 41.5 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE F-6 AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     LABEL "Взять как доплату"
      VIEW-AS TEXT
     SIZE 15 BY .67
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE v-bef-date AS CHARACTER FORMAT "X(256)":U
     LABEL "Дата чека"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE v-bef-n AS CHARACTER FORMAT "X(256)":U
     LABEL "№ чека"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE v-bef-sum AS CHARACTER FORMAT "X(256)":U
     LABEL "Сумма"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE v-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата чека"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-dis AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "Скидка %"
      VIEW-AS TEXT
     SIZE 12.5 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-dost AS CHARACTER FORMAT "X(256)":U
     LABEL "Доставка"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE v-dost-sum AS CHARACTER FORMAT "X(256)":U
     LABEL "Сумма"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE v-itogo-base AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "По накл (баз.вал)"
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-itogo-rubl AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "По накл abbr-rub"
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-n AS CHARACTER FORMAT "X(256)":U
     LABEL "№ чека"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-pr-new AS DECIMAL FORMAT "->>>9.9999":U INITIAL 0
     LABEL "Наценка за работу %"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-pr-srk AS CHARACTER FORMAT "X(256)":U
     LABEL "Наценка за срочность %"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-pr-wrk AS CHARACTER FORMAT "X(256)":U
     LABEL "Наценка за работу %"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-sum AS DECIMAL FORMAT "->>>>>>>9.99":U INITIAL 0
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Сумма доплаты" NO-UNDO.
DEFINE VARIABLE v-sum-new-base AS DECIMAL FORMAT "->>>>>>>9.99":U INITIAL 0
     LABEL "Сумма к оплате(баз.вал)"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Сумма с наценками и с доставкой"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-sum-new-rubl AS DECIMAL FORMAT "->>>>>>>9.99":U INITIAL 0
     LABEL "Сумма к оплате"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Сумма с наценками и с доставкой"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-sum-with-disc-base AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "Итого (баз.вал)"
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-sum-with-disc-rubl AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "Итого "
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-calc AT ROW 20 COL 39.5
     F- AT ROW 16.5 COL 21 COLON-ALIGNED
     B-ok AT ROW 1 COL 1
     v-sum AT ROW 18.25 COL 12.5 COLON-ALIGNED
     v-n AT ROW 19.5 COL 12.5 COLON-ALIGNED
     v-date AT ROW 20.75 COL 12.5 COLON-ALIGNED
     B-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 81
     f-1 AT ROW 2.25 COL 2 NO-LABEL
     v-pr-wrk AT ROW 4 COL 23 COLON-ALIGNED
     v-itogo-base AT ROW 4 COL 65 COLON-ALIGNED
     v-pr-srk AT ROW 4.75 COL 23 COLON-ALIGNED
     v-itogo-rubl AT ROW 4.75 COL 65 COLON-ALIGNED
     v-dis AT ROW 5.75 COL 23 COLON-ALIGNED
     v-sum-with-disc-base AT ROW 5.75 COL 65 COLON-ALIGNED
     v-sum-with-disc-rubl AT ROW 6.5 COL 65 COLON-ALIGNED
     f-2 AT ROW 7.75 COL 2 NO-LABEL
     v-dost AT ROW 9 COL 12 COLON-ALIGNED
     v-dost-sum AT ROW 10.25 COL 12 COLON-ALIGNED
     f-3 AT ROW 11.25 COL 2 NO-LABEL
     v-bef-sum AT ROW 13 COL 12.5 COLON-ALIGNED
     v-bef-n AT ROW 13 COL 41.5 COLON-ALIGNED
     v-bef-date AT ROW 13 COL 70 COLON-ALIGNED
     f-4 AT ROW 15 COL 2 NO-LABEL
     v-sum-new-rubl AT ROW 19 COL 73 COLON-ALIGNED
     f-5 AT ROW 15 COL 47.5 NO-LABEL
     v-sum-new-base AT ROW 18.25 COL 73 COLON-ALIGNED
     v-pr-new AT ROW 21.5 COL 73 COLON-ALIGNED
     F-6 AT ROW 17.25 COL 21 COLON-ALIGNED
     SPACE(53.12) SKIP(4.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Доплата по документу"
         CANCEL-BUTTON B-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-calc IN FRAME Dialog-Frame
DO:
  run proc-recalc.
  DISPLAY v-pr-new v-sum-new-base v-sum-new-rubl f-6 WITH FRAME Dialog-Frame .
END.
ON CHOOSE OF B-ok IN FRAME Dialog-Frame
DO:
  ASSIGN
      v-date
      v-n
      v-sum
      .
     if v-date <> ? then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input '3postdchek':U ,
                       input v-date )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-oth in g#trdcalib ( input p-doc-code ,
                       input '3postdchek':U ,
                       input v-date ) no-error .
        if error-status :error then do:
           message "Ошибка при обработке атрибута." view-as alert-box.
           undo, return no-apply.
        end.
     end.
     if v-n <> "" then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input '2postNchek':U ,
                       input v-n )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-oth in g#trdcalib ( input p-doc-code ,
                       input '2postNchek':U ,
                       input v-n ) no-error .
        if error-status :error then do:
           message "Ошибка при обработке атрибута." view-as alert-box.
           undo, return no-apply.
        end.
     end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input '1postpay':U ,
                       input v-sum )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-oth in g#trdcalib ( input p-doc-code ,
                       input '1postpay':U ,
                       input v-sum ) no-error .
         if error-status :error then do:
            message "Ошибка при обработке атрибута." view-as alert-box.
            undo, return no-apply.
         end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input nakl_trn-doc.doc-code ,
                       input '6sumwrk':U ,
                       input string(v-pr-dl) )  .
END.
ON LEAVE OF v-sum IN FRAME Dialog-Frame
DO:
  ASSIGN v-sum.
  F- =  DEC(v-bef-sum)  + v-sum .
  DISPLAY  F-  WITH FRAME Dialog-Frame .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of v-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of v-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of v-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of v-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of v-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of v-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date10
    MENU-ITEM m-ed-date10-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date10-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date10-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date10-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date10 :HANDLE
      v-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle10 as handle no-undo .
  assign
    v-label-handle10 = v-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle10)
  then do:
    if v-label-handle10 :tooltip = ""
    or v-label-handle10 :tooltip = ?
    then do:
      assign
        v-label-handle10 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date10-1 in menu m-ed-date10 DO:
    apply "ctrl-b":U to v-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-2 in menu m-ed-date10 DO:
    apply "ctrl-d":U to v-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-3 in menu m-ed-date10 DO:
    apply "ctrl-e":U to v-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-4 in menu m-ed-date10 DO:
    apply "ctrl-f":U to v-date in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run init-proc.
  v-itogo-rubl:label = "По накл (руб)".
  v-sum-new-rubl:label = "Сумма к оплате (руб)".
  v-sum-with-disc-rubl:label = "Итого (руб)".
  run enable_ui.
  hide v-pr-srk in frame Dialog-Frame .
  if p-doc-mode =  'ПРОСМОТР':U then do:
     hide b-ok  in frame Dialog-Frame .
     disable B-calc
             v-sum
             v-n
             v-date
             with frame Dialog-Frame .
     B-exit:label = "Вы&ход".
     B-exit:COLUMN = 1.
  end.
IF nakl_trn-doc.status_ = 'факт':U THEN do:
    HIDE
    F- F-6 v-sum-new-base v-sum-new-rubl
    B-calc
    v-itogo-base
    v-itogo-rubl
    IN FRAME Dialog-Frame.
end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_ui.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY F- v-sum v-n v-date f-1 v-pr-wrk v-itogo-base v-pr-srk v-itogo-rubl
          v-dis v-sum-with-disc-base v-sum-with-disc-rubl f-2 v-dost v-dost-sum
          f-3 v-bef-sum v-bef-n v-bef-date f-4 v-sum-new-rubl f-5 v-sum-new-base
          v-pr-new F-6
      WITH FRAME Dialog-Frame.
  ENABLE B-calc F- B-ok v-sum v-n v-date B-exit B-Help f-1 v-pr-wrk
         v-itogo-base v-pr-srk v-itogo-rubl v-dis v-sum-with-disc-base
         v-sum-with-disc-rubl f-2 v-dost v-dost-sum f-3 v-bef-sum v-bef-n
         v-bef-date f-4 v-sum-new-rubl f-5 v-sum-new-base v-pr-new F-6
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-proc :
define variable  v-type       as character no-undo .
define variable  v-postdchek as character no-undo .
define variable  v-postpay   as character no-undo .
define variable  v-postNchek as character no-undo .
v-bef-date = "" . run attr-read in this-procedure (  input p-doc-code                                  ,  input '4dchek':U                                    , output v-bef-date                                    , output v-type ).
v-bef-sum = "" . run attr-read in this-procedure (  input p-doc-code                                  ,  input '2befpay':U                                    , output v-bef-sum                                    , output v-type ).
v-bef-n = "" . run attr-read in this-procedure (  input p-doc-code                                  ,  input '3ord_Nchek':U                                    , output v-bef-n                                    , output v-type ).
v-dost-sum = "" . run attr-read in this-procedure (  input p-doc-code                                  ,  input '5deliv':U                                    , output v-dost-sum                                    , output v-type ).
v-dost = "" . run attr-read in this-procedure (  input p-doc-code                                  ,  input '4ord_dl':U                                    , output v-dost                                    , output v-type ).
v-pr-wrk = "" . run attr-read in this-procedure (  input p-doc-code                                  ,  input '6sumwrk':U                                    , output v-pr-wrk                                    , output v-type ).
v-postdchek = "" . run attr-read in this-procedure (  input p-doc-code                                  ,  input '3postdchek':U                                    , output v-postdchek                                    , output v-type ).
v-postpay = "" . run attr-read in this-procedure (  input p-doc-code                                  ,  input '1postpay':U                                    , output v-postpay                                    , output v-type ).
v-postNchek = "" . run attr-read in this-procedure (  input p-doc-code                                  ,  input '2postNchek':U                                    , output v-postNchek                                    , output v-type ).
  ASSIGN
      v-date = date(v-postdchek)
      v-n    = v-postNchek
      v-sum  = dec(v-postpay)
      v-dis =  nakl_trn-doc.discnt-pc
      .
  v-pr-1 = decimal (v-pr-wrk)  .
  if v-dost = "yes" then v-dost = "Да"   .
                    else  v-dost = "Нет" .
assign
  v-itogo-base = 0
  v-itogo-rubl = 0
  .
 define buffer buf_goods for goods.
 define variable  v-nab as logical   no-undo .
   for each gds-dtl no-lock where gds-dtl.doc-code = p-doc-code :
        find first buf_goods no-lock
            where buf_goods.artic      = gds-dtl.artic
              and buf_goods.prod-type  = gds-dtl.prod-type
              and buf_goods.prod-code  = gds-dtl.prod-code .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_grp-nabor in g#lib-trn3
( input  buf_goods.gds-code ,
  output v-nab
)
.
      if v-nab = false then do:
          assign
            v-itogo-base = (gds-dtl.price-base * gds-dtl.fact-qnty)  + v-itogo-base
            v-itogo-rubl = (gds-dtl.price-rubl * gds-dtl.fact-qnty)  + v-itogo-rubl
        .
      end.
   end.
  v-itogo-base2 = 0 .
  v-itogo-rubl2 = 0 .
  if LOOKUP ( nakl_trn-doc.status_ , 'факт':U ) > 0  then do:
    v-itogo-base2 =   nakl_trn-doc.tot-fact -  nakl_trn-doc.tot-calc   .
    v-itogo-rubl2 =   nakl_trn-doc.tot-sale -  nakl_trn-doc.discnt-rubl.
  END.
  ELSE DO:
    IF  nakl_trn-doc.status_ = 'разрешен':U THEN DO:
        for each gds-dtl no-lock where gds-dtl.doc-code = p-doc-code :
              v-itogo-base2 = v-itogo-base2 +  ((gds-dtl.price-base - gds-dtl.discnt-base) * gds-dtl.fact-qnty) .
              v-itogo-rubl2 = v-itogo-rubl2 +  ((gds-dtl.price-rubl - gds-dtl.discnt-rubl) * gds-dtl.fact-qnty) .
        end.
    end.
    else do:
        v-itogo-base2 =  nakl_trn-doc.tot-doc  -  nakl_trn-doc.tot-calc     .
        v-itogo-rubl2 =  nakl_trn-doc.tot-rubl -  nakl_trn-doc.discnt-rubl  .
    end.
  END.
IF  nakl_trn-doc.status_ <> 'факт':U THEN DO:
    v-sum-with-disc-base = v-itogo-base2  +  (v-pr-1) * v-itogo-base2 / 100 .
    v-sum-with-disc-rubl = v-itogo-rubl2  +  (v-pr-1) * v-itogo-rubl2 / 100 .
END.
ELSE DO:
    v-sum-with-disc-base = v-itogo-base2   .
    v-sum-with-disc-rubl = v-itogo-rubl2   .
END.
if   nakl_trn-doc.status_ = 'факт':U then
assign
 v-pr-new  = decimal(v-pr-wrk)
 v-sum-new-rubl = v-sum-with-disc-rubl
 v-sum-new-base = v-sum-with-disc-base
.
else
assign
 v-pr-new  = decimal(v-pr-wrk)
 v-sum-new-rubl = v-sum-with-disc-rubl + DEC(v-dost-sum)
 v-sum-new-base = v-sum-with-disc-base + ( DEC(v-dost-sum)  * nakl_trn-doc.base-scale / nakl_trn-doc.base-rate )
.
 v-pr-dl  =  v-pr-new .
 F- =   DEC(v-bef-sum)  + v-sum .
 f-6 = v-sum-new-rubl  - DEC(v-bef-sum) .
display
  f-6
  v-pr-wrk
  v-date
  v-n
  v-sum
  v-sum-with-disc-rubl
  v-sum-with-disc-base
  v-itogo-base
  v-itogo-rubl
  v-dis
  F-
  v-dis
  with frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-recalc :
define variable v-sum-rubl-1 as decimal   no-undo .
define variable v-pr2 as decimal   no-undo .
define variable v-dos as decimal   no-undo .
assign
  v-dos = DECimal(v-dost-sum)
  v-sum-rubl-1   = f-
  v-sum-new-rubl = v-sum-rubl-1
  v-sum-new-base = v-sum-new-rubl * nakl_trn-doc.base-scale / nakl_trn-doc.base-rate
  v-pr-new = (( v-sum-rubl-1  - ( v-itogo-rubl2 + v-dos) ) * 100 / v-itogo-rubl2 )
.
  define variable v1 as decimal   no-undo .
  define variable v2 as decimal   no-undo .
  v-itogo-rubl2 =  v-itogo-rubl * (1 - (nakl_trn-doc.discnt-pc / 100) )    .
  v-pr-new = 100 * ((( v-sum-new-rubl - v-dos ) / ( v-itogo-rubl2) ) - 1) .
  v-pr-dl  = 100 * ((( v-sum-new-rubl - v-dos ) / ( v-itogo-rubl2) ) - 1) .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input nakl_trn-doc.doc-code ,
                       input 'discnt-stop':U ,
                       input string(v-sum-new-rubl) )  .
END PROCEDURE.
procedure attr-read :
  define  input parameter p-doc-code like ub.doc-attr.doc-code   no-undo.
  define  input parameter p-code     like ub.doc-attr.attr-code  no-undo.
  define output parameter p-value    like ub.doc-attr.attr-value no-undo.
  define output parameter p-type     as   character              no-undo.
  do on error undo, return error return-value :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input p-code ,
                       output p-value ,
                       output p-type )  .
  end.
end procedure.
