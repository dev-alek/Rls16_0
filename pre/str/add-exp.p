block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: add-exp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/add-exp.p $":U .
define variable vss-description as character no-undo init "".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define input parameter parparentproc AS WIDGET-HANDLE        NO-UNDO.
define input parameter pardoc-code   like ub.trn-doc.doc-code   no-undo.
define input parameter partot-other  like ub.trn-doc.tot-transp  no-undo.
define input parameter partot-transp like ub.trn-doc.tot-transp no-undo.
define variable v-insalepr as logical   no-undo .
define variable varhost-code like ub.trn-doc.obj-code no-undo.
define variable v-method as character no-undo .
define variable varvalue as character no-undo .
define variable vartype  as character no-undo .
define variable  partot-other-base  like ub.trn-doc.tot-transp  no-undo.
define variable  partot-transp-base like ub.trn-doc.tot-transp no-undo.
define variable  partot-other-rubl  like ub.trn-doc.tot-transp  no-undo.
define variable  partot-transp-rubl like ub.trn-doc.tot-transp no-undo.
define variable v-ves     as decimal   no-undo  init 0.
define variable v-wt-base as decimal   no-undo init 0 .
define variable g#report-num as integer   no-undo .
define stream  errStream  .
define variable v-old-other as character no-undo .
define variable v-old-other-type as character no-undo .
define variable v-old-other-rubl as decimal   no-undo .
define variable v-old-other-base as decimal   no-undo .
define variable v-old-tr-rubl as decimal   no-undo .
define variable v-old-tr-base as decimal   no-undo .
run get-report-num   in parParentProc ( output g#report-num ) .
define variable v-exis as logical no-undo .
define variable v-txt as character no-undo .
find first ub.trn-doc where ub.trn-doc.doc-code = pardoc-code no-lock no-error.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,output varhost-code
  )  .
if not available ub.trn-doc then do:
   message "Не найден документ с кодом: " pardoc-code
   view-as alert-box.
   return error.
end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 'm_inc':U ,
                       output varvalue ,
                       output vartype )  .
   if int(varvalue) > 0 then do:
     assign
       v-method = varvalue.
   end.
   else do:
     assign
       v-method = "1".
   end.
if v-method = "4" then do:
output stream errStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
    v-exis = false .
   for each ub.doc-line no-lock where ub.doc-line.doc-code = pardoc-code :
       find first ub.goods where ub.goods.artic     = ub.doc-line.artic     and
                              ub.goods.prod-type = ub.doc-line.prod-type and
                              ub.goods.prod-code = ub.doc-line.prod-code no-lock.
       find first ub.units no-lock where ub.units.unit-name = ub.goods.unit-base  .
       if  ub.units.type = 'вес':U then do:
           v-wt-base = ub.doc-line.fact-qnty.
       end.
       else do:
         v-wt-base = ub.goods.wt-base * ub.doc-line.fact-qnty.
         if v-wt-base = ? or v-wt-base = 0 then do:
            Put  stream  errStream
                         ub.goods.artic " " ub.goods.gds-code " " ub.goods.gds-name  skip .
            v-exis = true.
         end.
       end.
       v-ves =  v-ves + v-wt-base  .
   end.
    if v-exis = true then do:
        define variable v-user-action   as character no-undo .
        define variable v-printed       as logical no-undo .
          message
          "Обнаружены товары без проставленного веса за штуку ! " skip
          "Вы можете просмотреть и распечатать их список . "      skip
          "Редактирование веса в карточке товара . "      skip
          view-as alert-box error .
      Output stream errStream   close .
        run gbl/prnfilen.w
          (input  "Товары без веса"
          ,input  0
          ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
          ,input 7
          ,output v-user-action
          ,output v-printed
          ) .
          if not ( lookup( ' экран':L, v-user-action ,";")  > 0 or
                    lookup( ' принтер':L, v-user-action ,";")  > 0  ) then do:
                      message "Внимание , вы не просмотрели список товаров ! "  .
                    end.
          return error.
    end.
end.
if partot-other  = ? then partot-other  = 0.
if partot-transp = ? then partot-transp = 0.
assign
  partot-other-rubl  =  partot-other
  partot-transp-rubl =  partot-transp
  partot-other-base  =  partot-other-rubl   * ub.trn-doc.base-scale / ub.trn-doc.base-rate
  partot-transp-base =  partot-transp-rubl  * ub.trn-doc.base-scale / ub.trn-doc.base-rate
  .
tr:
do transaction
   ON ERROR   UNDO tr, LEAVE
   ON END-KEY UNDO tr, LEAVE
   ON STOP    UNDO tr , LEAVE :
   for each ub.doc-line
     where ub.doc-line.doc-code = pardoc-code
   :
       find first ub.goods where ub.goods.artic     = ub.doc-line.artic     and
                              ub.goods.prod-type = ub.doc-line.prod-type and
                              ub.goods.prod-code = ub.doc-line.prod-code no-lock.
       find first ub.units where ub.units.unit-name = ub.goods.unit-base no-lock.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.doc-line.obj-type
  ,input  ub.doc-line.obj-code
  ,input  ub.doc-line.artic
  ,input  ub.doc-line.prod-type
  ,input  ub.doc-line.prod-code
  ,input  'insalepr=request':U
  ,output v-insalepr
  )  .
       if v-insalepr = true then do:
          undo tr, return error "В накладной " + string(ub.doc-line.doc-code) + " имеется товар " + string(ub.goods.artic) + " "
                                + string(ub.goods.prod-type) + " " + string(ub.goods.prod-code) + " принимаемый по продажной цене." +
                                " Недопустимы транспортные и прочие расходы.".
       end.
       if ub.doc-line.transport-rubl = ? then ub.doc-line.transport-rubl = 0.
       if ub.doc-line.transport-base = ? then ub.doc-line.transport-base = 0.
       if ub.doc-line.other-rubl     = ? then ub.doc-line.other-rubl     = 0.
       if ub.doc-line.other-base     = ? then ub.doc-line.other-base     = 0.
       if ub.units.type = 'вес':U then do:
           v-wt-base = ub.doc-line.fact-qnty.
       end.
       else do:
         v-wt-base = ub.goods.wt-base * ub.doc-line.fact-qnty.
        end.
        run lineattr-value in this-procedure (
            ub.doc-line.doc-code ,
            ub.goods.gds-code    ,
            'old_other-ras':U ,
            output v-old-other       ,
            output v-old-other-type
            ) no-error .
        if error-status :error then do:
          v-old-other-rubl = 0 .
          v-old-other-base = 0 .
          v-old-tr-rubl    = 0 .
          v-old-tr-base    = 0 .
        end.
        else do:
          v-old-other-rubl = decimal ( entry ( 1 , v-old-other,chr(4) )) no-error .
          v-old-other-base = decimal ( entry ( 2 , v-old-other,chr(4) )) no-error .
          v-old-other-rubl = decimal ( entry ( 3 , v-old-other,chr(4) )) no-error .
          v-old-other-base = decimal ( entry ( 4 , v-old-other,chr(4) )) no-error .
        end.
        ub.doc-line.other-rubl = ub.doc-line.other-rubl - v-old-other-rubl .
        ub.doc-line.other-base = ub.doc-line.other-base - v-old-other-base .
        ub.doc-line.transport-rubl = ub.doc-line.transport-rubl - v-old-tr-rubl .
        ub.doc-line.transport-base = ub.doc-line.transport-base - v-old-tr-base .
  case v-method :
  when "1"  then do:
             ub.doc-line.price-rubl     = ub.doc-line.price-rubl - ub.doc-line.transport-rubl - ub.doc-line.other-rubl .
             ub.doc-line.price-base     = ub.doc-line.price-base - ub.doc-line.transport-base - ub.doc-line.other-base .
             ub.doc-line.transport-base = ub.doc-line.price-base * partot-transp / ub.trn-doc.tot-sale              .
             ub.doc-line.transport-rubl = ub.doc-line.price-rubl * partot-transp / ub.trn-doc.tot-sale              .
             ub.doc-line.other-base     = ub.doc-line.price-base * partot-other  / ub.trn-doc.tot-sale              .
             ub.doc-line.other-rubl     = ub.doc-line.price-rubl * partot-other  / ub.trn-doc.tot-sale              .
             ub.doc-line.price-rubl     = ub.doc-line.price-rubl + ub.doc-line.transport-rubl + ub.doc-line.other-rubl .
             ub.doc-line.price-base     = ub.doc-line.price-base + ub.doc-line.transport-base + ub.doc-line.other-base.
  end.
  when "2"  then do:
             ub.doc-line.price-rubl     =  ub.doc-line.price-rubl - ub.doc-line.transport-rubl - ub.doc-line.other-rubl .
             ub.doc-line.price-base     =  ub.doc-line.price-base - ub.doc-line.transport-base - ub.doc-line.other-base .
             ub.doc-line.transport-base = (ub.doc-line.fact-qnty * partot-transp-base / ub.trn-doc.fact-qnty ) / ub.doc-line.fact-qnty .
             ub.doc-line.transport-rubl = (ub.doc-line.fact-qnty * partot-transp-rubl / ub.trn-doc.fact-qnty ) / ub.doc-line.fact-qnty .
             ub.doc-line.other-base     = (ub.doc-line.fact-qnty * partot-other-base  / ub.trn-doc.fact-qnty ) / ub.doc-line.fact-qnty .
             ub.doc-line.other-rubl     = (ub.doc-line.fact-qnty * partot-other-rubl  / ub.trn-doc.fact-qnty ) / ub.doc-line.fact-qnty .
             ub.doc-line.price-rubl     =  ub.doc-line.price-rubl + ub.doc-line.transport-rubl + ub.doc-line.other-rubl .
             ub.doc-line.price-base     =  ub.doc-line.price-base + ub.doc-line.transport-base + ub.doc-line.other-base .
  end.
  when "3"  then do:
       assign
             ub.doc-line.price-rubl     = ub.doc-line.price-rubl - ub.doc-line.transport-rubl - ub.doc-line.other-rubl
             ub.doc-line.price-base     = ub.doc-line.price-base - ub.doc-line.transport-base - ub.doc-line.other-base
             ub.doc-line.transport-base = (ub.doc-line.cli-qnty * partot-transp-base / ub.trn-doc.cli-qnty ) / ub.doc-line.fact-qnty
             ub.doc-line.transport-rubl = (ub.doc-line.cli-qnty * partot-transp-rubl / ub.trn-doc.cli-qnty ) / ub.doc-line.fact-qnty
             ub.doc-line.other-base     = (ub.doc-line.cli-qnty * partot-other-base  / ub.trn-doc.cli-qnty ) / ub.doc-line.fact-qnty
             ub.doc-line.other-rubl     = (ub.doc-line.cli-qnty * partot-other-rubl  / ub.trn-doc.cli-qnty ) / ub.doc-line.fact-qnty
             ub.doc-line.price-rubl     = ub.doc-line.price-rubl + ub.doc-line.transport-rubl + ub.doc-line.other-rubl
             ub.doc-line.price-base     = ub.doc-line.price-base + ub.doc-line.transport-base + ub.doc-line.other-base.
  end.
  when "4"  then do:
       assign
             ub.doc-line.price-rubl     = ub.doc-line.price-rubl - ub.doc-line.transport-rubl - ub.doc-line.other-rubl
             ub.doc-line.price-base     = ub.doc-line.price-base - ub.doc-line.transport-base - ub.doc-line.other-base
             ub.doc-line.transport-base = (v-wt-base *  partot-transp-base / v-ves ) / ub.doc-line.fact-qnty
             ub.doc-line.transport-rubl = (v-wt-base *  partot-transp-rubl / v-ves ) / ub.doc-line.fact-qnty
             ub.doc-line.other-base     = (v-wt-base *  partot-other-base  / v-ves ) / ub.doc-line.fact-qnty
             ub.doc-line.other-rubl     = (v-wt-base *  partot-other-rubl  / v-ves ) / ub.doc-line.fact-qnty
             ub.doc-line.price-rubl     = ub.doc-line.price-rubl + ub.doc-line.transport-rubl + ub.doc-line.other-rubl
             ub.doc-line.price-base     = ub.doc-line.price-base + ub.doc-line.transport-base + ub.doc-line.other-base.
  end.
  end case.
  run lineattr-write in this-procedure (
      ub.doc-line.doc-code ,
      ub.goods.gds-code    ,
      'old_other-ras':U ,
      string(ub.doc-line.other-rubl ) + chr(4) + string(ub.doc-line.other-base ) + chr(4) +
      string(ub.doc-line.transport-rubl ) + chr(4) + string(ub.doc-line.transport-base )
      ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка "
        view-as alert-box error
      .
       run trg/partsupd.p
         (input parparentproc
         ,input ub.trn-doc.doc-code
         ,input ub.trn-doc.obj-type
         ,input ub.trn-doc.obj-code
         ,input ub.doc-line.artic
         ,input ub.doc-line.prod-type
         ,input ub.doc-line.prod-code
         ,input true
         ,input ""
         ) no-error.
      if error-status:error then do:
         undo tr, return error "Ошибка при редактировании партий.".
      end.
   end.
   run gbl/calc-trn.p (input parparentproc, input recid(ub.trn-doc)) no-error.
   if error-status:error then undo tr, return error.
end.
