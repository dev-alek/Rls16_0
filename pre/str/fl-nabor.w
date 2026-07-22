DEFINE TEMP-TABLE tt-doc-line-attr NO-UNDO LIKE ub.doc-line-attr
       field node-code as int
       field price-rubl as dec
       field price-base as dec.
define input  parameter   parParentProc  as widget-handle no-undo.
define input  parameter   p-doc-mode  as character no-undo .
define input  parameter   p-doc-code  as character no-undo .
define input  parameter   p-bk-gds-code as integer   no-undo .
define output parameter   p-make as logical   no-undo .
define output parameter   p-sum1 as decimal   no-undo .
define output parameter   p-sum2 as decimal   no-undo .
define variable g#mainmenu-handle as widget-handle no-undo.
g#mainmenu-handle = parParentProc .
define variable list-mode as character no-undo .
define new shared variable prt-rec   as recid no-undo .
define new shared variable line-mode as character no-undo .
define new shared variable line-rec  as recid no-undo .
define new shared variable gds-rec   as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр и корректировка состава набора".
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
define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
define variable g#report-num as integer   no-undo .
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
run get-report-num  in parParentProc ( output g#report-num ).
define temp-table temp-gds-dtl no-undo
field node-code as integer
field artic     as char
field prod-type     as char
field prod-code     as int
field gds-code  as integer
field rel-bk    as logical
index pi node-code
.
def var chg-qnty like gds-dtl.doc-qnty init ? no-undo.
def shared buffer t-doc for trn-doc.
if t-doc.status_ = 'готов':U  or
   t-doc.status_ = 'отказ':U
then p-doc-mode = 'ПРОСМОТР':U .
p-make = false  .
define buffer tt2-doc-line-attr for tt-doc-line-attr.
DEF VAR v-sum-deliv AS CHAR NO-UNDO.
DEFINE BUTTON B-add
     LABEL "Добавить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-chg
     LABEL "Изменить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-del
     LABEL "Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE v-prim-str AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 89.5 BY 3.5 NO-UNDO.
DEFINE VARIABLE text-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Итого c наценкой и скидкой:"
      VIEW-AS TEXT
     SIZE 28 BY .67 NO-UNDO.
DEFINE VARIABLE v-itogo-base AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "Итого (баз.вал)"
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-itogo-rubl AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "Итого "
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-pr-sk AS DECIMAL FORMAT "->>>>9.99%":U INITIAL 0
     LABEL "Скидка клиента"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-pr-wrk AS DECIMAL FORMAT "->>>>9.99%":U INITIAL 0
     LABEL "Наценка за работу"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-str AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89.5 BY 1.25
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE v-sum-with-disc-base AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "баз.вал."
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-sum-with-disc-rubl AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "."
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY BROWSE-1 FOR
      tt-doc-line-attr,
      ub.goods,
      ub.gds-prt SCROLLING.
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 NO-LOCK DISPLAY
      ub.goods.artic FORMAT "X(16)":U
      (if gds-prt.node-name <> '_Пустая шкала':U and gds-prt.upper-code <> goods.prt-root then goods.gds-name + ' - ' + gds-prt.f-name else goods.gds-name) COLUMN-LABEL "Наименование" FORMAT "x(35)":U
      ub.goods.unit-base COLUMN-LABEL "Ед.!изм." FORMAT "X(3)":U
            WIDTH 3
      tt-doc-line-attr.attr-value COLUMN-LABEL "Количество" FORMAT "X(10)":U
      tt-doc-line-attr.price-base COLUMN-LABEL "Цена в !баз.вал." FORMAT ">>>>>>9.99":U
      tt-doc-line-attr.price-rubl COLUMN-LABEL "Цена в руб" FORMAT ">>>>>>9.99":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 90 BY 10.75 EXPANDABLE.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-add AT ROW 1 COL 11
     B-chg AT ROW 1 COL 21
     B-del AT ROW 1 COL 31
     B-Help AT ROW 1 COL 81
     BROWSE-1 AT ROW 3.75 COL 1
     v-prim-str AT ROW 19 COL 1 NO-LABEL
     v-str AT ROW 2.25 COL 1.5 NO-LABEL
     v-pr-wrk AT ROW 14.5 COL 21.5 COLON-ALIGNED
     v-itogo-base AT ROW 14.5 COL 67 COLON-ALIGNED
     v-pr-sk AT ROW 15.25 COL 21.5 COLON-ALIGNED
     v-itogo-rubl AT ROW 15.25 COL 67 COLON-ALIGNED
     text-1 AT ROW 16.5 COL 50 COLON-ALIGNED NO-LABEL
     v-sum-with-disc-base AT ROW 17.25 COL 67 COLON-ALIGNED
     v-sum-with-disc-rubl AT ROW 18 COL 67 COLON-ALIGNED
     SPACE(0.62) SKIP(3.95)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товары в наборе"
         CANCEL-BUTTON B-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       v-prim-str:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
define variable  v-qnty     as character no-undo .
define variable  v-qnty-old as character no-undo .
define variable v-buket-gds-code as integer   no-undo .
define variable v-gds-code as integer   no-undo .
define variable v-prt-code as integer   no-undo .
define variable varartic      like doc-line.artic      initial " " no-undo.
define variable v-exist as logical   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
define variable s-value as character no-undo .
define variable notes as character no-undo .
define variable lns-cnt as integer   no-undo .
p-make = true .
v-buket-gds-code = p-bk-gds-code .
  run str/chs-gds.w
                ( input parparentproc
                 ,input t-doc.obj-type
                 ,input t-doc.obj-code
                 ,input list-mode
                 ,input t-doc.status_
                 ,input "Для нетоварной позиции" + v-str
                 ,input 'свободно':U
                 ,input t-doc.cli-type
                 ,input t-doc.cli-code
                 ,input t-doc.host-code
                 ,input t-doc.ext-doc-type
                 ,input-output varartic
                 ,output notes
                 ).
if notes = '' then return.
assign
  line-mode = 'ДОБАВЛЕНИЕ':U
  prt-rec = ?
  lns-cnt = 1
  .
do while lns-cnt <= num-entries (notes):
  assign
    gds-rec = integer (entry (lns-cnt, notes))
    lns-cnt = lns-cnt + 1.
find first goods no-lock where recid (goods) = gds-rec no-error .
v-gds-code = goods.gds-code.
find first  gds-prt no-lock where  gds-prt.upper-code = goods.prt-root no-error .
if gds-prt.node-name = '_Пустая шкала':U then do:
   v-prt-code = gds-prt.node-code.
      run lineattr-exist-flora-gds
          ( input   t-doc.doc-code   ,
            input   goods.gds-code   ,
            input   v-prt-code       ,
            input   v-buket-gds-code ,
            output  v-exist          )
            .
        v-exist = false .
        find first gds-dtl no-lock where
                  gds-dtl.doc-code = t-doc.doc-code   and
                  gds-dtl.artic    = goods.artic      and
                  gds-dtl.prod-type = goods.prod-type and
                  gds-dtl.prod-code = goods.prod-code no-error .
        if available gds-dtl then do:
          assign
          v-exist = true
          .
        end.
        if v-exist = false then do:
          run str/out-add.p
          (   parparentproc
             , recid(t-doc)
             , ?
             , ?
             , recid(goods)
             , 'ДОБАВЛЕНИЕ':U
             , string(v-buket-gds-code)
              ) no-error.
          if error-status:error then do: next. end.
        end.
        else do:
        end.
        find first gds-dtl no-lock where gds-dtl.doc-code = t-doc.doc-code   and
                                        gds-dtl.artic     = goods.artic      and
                                        gds-dtl.prod-type = goods.prod-type  and
                                        gds-dtl.prod-code = goods.prod-code  no-error .
        if available gds-dtl then do:
           find first tt-doc-line-attr where
            tt-doc-line-attr.doc-code    = p-doc-code and
            tt-doc-line-attr.gds-code    = v-gds-code and
            tt-doc-line-attr.attr-code   = 'fl_gds-code':U  + chr(44) + string(gds-dtl.prt-code)  + chr(44) + string(v-buket-gds-code )
            no-error .
           if not available tt-doc-line-attr then do:
              CREATE tt-doc-line-attr.
              end.
              else do:
              end.
           assign
            tt-doc-line-attr.doc-code    = p-doc-code
            tt-doc-line-attr.gds-code    = v-gds-code
            tt-doc-line-attr.node-code   = gds-dtl.prt-code
            tt-doc-line-attr.attr-value  = if v-exist = true then "1"  else string (gds-dtl.fact-qnty)
            tt-doc-line-attr.attr-code   = 'fl_gds-code':U  + chr(44) + string(tt-doc-line-attr.node-code)  + chr(44) + string(v-buket-gds-code )
            tt-doc-line-attr.price-rubl  =  gds-dtl.price-rubl
            tt-doc-line-attr.price-base  =  gds-dtl.price-base
            .
           find first doc-line-attr exclusive-lock where
            doc-line-attr.doc-code    = p-doc-code and
            doc-line-attr.gds-code    = v-gds-code and
            doc-line-attr.attr-code   = 'fl_gds-code':U  + chr(44) + string(gds-dtl.prt-code)  + chr(44) + string(v-buket-gds-code )
            no-error .
            if not available doc-line-attr then  create doc-line-attr.
           BUFFER-COPY tt-doc-line-attr  TO doc-line-attr .
        end.
end.
else do:
        v-exist = false .
        find first gds-dtl no-lock where gds-dtl.doc-code = t-doc.doc-code   and
                                        gds-dtl.artic     = goods.artic      and
                                        gds-dtl.prod-type = goods.prod-type and
                                        gds-dtl.prod-code = goods.prod-code no-error .
        if available gds-dtl then do:
          assign
          v-exist = true
          .
        end.
      if v-exist = false then do:
          run str/out-add.p
          (
              parparentproc
             , recid(t-doc)
             , ?
             , ?
             , recid(goods)
             , 'ДОБАВЛЕНИЕ':U
             , string(v-buket-gds-code)
              ) no-error.
        if error-status:error then do: next. end.
        for each  gds-dtl no-lock where gds-dtl.doc-code = t-doc.doc-code   and
                                        gds-dtl.artic     = goods.artic     and
                                        gds-dtl.prod-type = goods.prod-type and
                                        gds-dtl.prod-code = goods.prod-code  :
          CREATE tt-doc-line-attr.
              assign
              tt-doc-line-attr.doc-code    = p-doc-code
              tt-doc-line-attr.gds-code    = v-gds-code
              tt-doc-line-attr.node-code   = gds-dtl.prt-code
              tt-doc-line-attr.attr-value  = string(gds-dtl.fact-qnty)
              tt-doc-line-attr.attr-code  = 'fl_gds-code':U  + chr(44) + string(tt-doc-line-attr.node-code)  + chr(44) + string(v-buket-gds-code )
              tt-doc-line-attr.price-rubl  =  gds-dtl.price-rubl
              tt-doc-line-attr.price-base  =  gds-dtl.price-base
              .
        end.
      end.
      else do:
          run str/out-add.p
          (
              parparentproc
             , recid(t-doc)
             , ?
             , ?
             , recid(goods)
             , 'ДОБАВЛЕНИЕ':U
             , string(v-buket-gds-code)
              ) no-error.
        if error-status:error then do: next. end.
        for each  doc-line-attr no-lock where
          doc-line-attr.doc-code = t-doc.doc-code   and
          doc-line-attr.gds-code = goods.gds-code   and
          lookup ('fl_gds-code':U , doc-line-attr.attr-code)  =  1 and
          lookup ( string(v-buket-gds-code ) , doc-line-attr.attr-code)  =  3 and
          decimal(doc-line-attr.attr-value) <> 0
          :
          find first tt-doc-line-attr where
              tt-doc-line-attr.doc-code    = doc-line-attr.doc-code  and
              tt-doc-line-attr.gds-code    = doc-line-attr.gds-code  and
              tt-doc-line-attr.attr-code   = doc-line-attr.attr-code no-error .
          if not available tt-doc-line-attr then     CREATE tt-doc-line-attr.
          find first gds-dtl no-lock where gds-dtl.doc-code = t-doc.doc-code   and
                                          gds-dtl.prt-code = integer (entry(2, doc-line-attr.attr-code))      and
                                          gds-dtl.artic     = goods.artic      and
                                          gds-dtl.prod-type = goods.prod-type and
                                          gds-dtl.prod-code = goods.prod-code no-error .
              assign
                tt-doc-line-attr.doc-code    = doc-line-attr.doc-code
                tt-doc-line-attr.gds-code    = doc-line-attr.gds-code
                tt-doc-line-attr.node-code   = integer (entry(2, doc-line-attr.attr-code))
                tt-doc-line-attr.attr-value  = doc-line-attr.attr-value
                tt-doc-line-attr.attr-code   = doc-line-attr.attr-code
                tt-doc-line-attr.price-rubl  =  gds-dtl.price-rubl
                tt-doc-line-attr.price-base  =  gds-dtl.price-base
              .
        end.
      end.
end.
end.
OPEN QUERY BROWSE-1 FOR EACH tt-doc-line-attr NO-LOCK,       EACH ub.goods WHERE ub.goods.gds-code = tt-doc-line-attr.gds-code NO-LOCK,       EACH ub.gds-prt WHERE ub.gds-prt.node-code =  tt-doc-line-attr.node-code NO-LOCK INDEXED-REPOSITION.
run re-disp in this-procedure .
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
if not available tt-doc-line-attr then return .
define variable v-qnty as character no-undo .
define variable v-qnty-old as character no-undo .
 v-qnty =  tt-doc-line-attr.attr-value .
 v-qnty-old =  tt-doc-line-attr.attr-value .
run gbl/d-prompt.w
(       'title=':u + "Изменение количества товара" + '\':u
      + 'text1=':u + "Количество" + (if gds-prt.node-name <> '_Пустая шкала':U and gds-prt.upper-code <> goods.prt-root then goods.gds-name + ' - ' + gds-prt.f-name else goods.gds-name) + '\':u
      + 'format=' + ">>>>>>>9.99" + '\':u
      + 'type=' + "decimal" + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=10\':u
      + 'fillin_height=1\':u
      + 'max-chars=10\':u
      + 'readonly=' + (if p-doc-mode <> 'ПРОСМОТР':U then 'no':u else 'yes':u) + '\':u
      , input-output v-qnty
      ) no-error.
   if caps(return-value) = "TRUE" and p-doc-mode <> 'ПРОСМОТР':U  then do:
      tt-doc-line-attr.attr-value  = v-qnty  .
      run re-disp in this-procedure .
     BROWSE-1:refresh() in frame Dialog-Frame .
   end.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
if not available tt-doc-line-attr then return .
   message
   "Удалять товар : " (if gds-prt.node-name <> '_Пустая шкала':U and gds-prt.upper-code <> goods.prt-root then goods.gds-name + ' - ' + gds-prt.f-name else goods.gds-name)
   " из набора : " v-str "?"
   view-as alert-box question
   buttons yes-no
   update v-d as log
   .
   if v-d = true then do:
      delete tt-doc-line-attr.
      run re-disp in this-procedure .
      OPEN QUERY BROWSE-1 FOR EACH tt-doc-line-attr NO-LOCK,       EACH ub.goods WHERE ub.goods.gds-code = tt-doc-line-attr.gds-code NO-LOCK,       EACH ub.gds-prt WHERE ub.gds-prt.node-code =  tt-doc-line-attr.node-code NO-LOCK INDEXED-REPOSITION.
   end.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  run save-proc in this-procedure .
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BROWSE-1 :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    define variable v-ok as logical   no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_grp-nabor in g#lib-trn3
( input  p-bk-gds-code ,
  output v-ok
)
.
    if v-ok = false then do:
      message "Это не набор !" view-as alert-box information .
      return  .
    end.
  v-itogo-rubl:LABEL = "Итого (руб)" .
  v-sum-with-disc-rubl:LABEL = "руб." .
  run init-proc.
  run enable_ui.
  run re-disp.
  if p-doc-mode =  'ПРОСМОТР':U then disable b-add b-chg b-del with frame Dialog-Frame .
  wait-for go of frame Dialog-Frame.
end.
run disable_ui.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-prim-str v-str v-pr-wrk v-itogo-base v-pr-sk v-itogo-rubl text-1
          v-sum-with-disc-base v-sum-with-disc-rubl
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-add B-chg B-del B-Help BROWSE-1 v-prim-str v-str v-pr-wrk
         v-itogo-base v-pr-sk v-itogo-rubl text-1 v-sum-with-disc-base
         v-sum-with-disc-rubl
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-1 FOR EACH tt-doc-line-attr NO-LOCK,       EACH ub.goods WHERE ub.goods.gds-code = tt-doc-line-attr.gds-code NO-LOCK,       EACH ub.gds-prt WHERE ub.gds-prt.node-code =  tt-doc-line-attr.node-code NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE init-proc :
define buffer bk_goods for goods.
find first bk_goods where bk_goods.gds-code  = p-bk-gds-code   no-error .
if error-status :error then return error .
define buffer ready_trn-doc for trn-doc.
define buffer nakl_trn-doc for trn-doc.
define variable p-type     as character no-undo .
v-prim-str = "" .
v-pr-sk = t-doc.discnt-pc.
if t-doc.status_ = 'готов':U  or
   t-doc.status_ = 'отказ':U
  then do:
    run lineattr-value   (
        input  t-doc.doc-code ,
        input  p-bk-gds-code ,
        input  'flora_ps':U     ,
        output v-prim-str    ,
        output p-type     ).
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input '5deliv':U ,
                       output v-sum-deliv ,
                       output p-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input '6sumwrk':U ,
                       output v-pr-wrk ,
                       output p-type )  .
      find first nakl_trn-doc no-lock where nakl_trn-doc.out-code = t-doc.doc-code no-error .
      if error-status :error then return error .
      p-doc-code = nakl_trn-doc.doc-code .
  end.
  else do:
    find first ready_trn-doc no-lock where ready_trn-doc.doc-code = t-doc.doc-code no-error .
    if available ready_trn-doc then do:
        run lineattr-value   (
            input  ready_trn-doc.doc-code ,
            input  p-bk-gds-code ,
            input  'flora_ps':U     ,
            output v-prim-str    ,
            output p-type     ).
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ready_trn-doc.doc-code ,
                        input '5deliv':U ,
                       output v-sum-deliv ,
                       output p-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ready_trn-doc.doc-code ,
                        input '6sumwrk':U ,
                       output v-pr-wrk ,
                       output p-type )  .
   end.
    p-doc-code =  t-doc.doc-code .
  end.
display
  v-prim-str
  v-pr-wrk
with frame Dialog-Frame .
define variable v-ok as logical   no-undo .
define buffer prt_goods for goods.
define buffer b2_doc-line-attr for doc-line-attr.
for each gds-dtl no-lock  where gds-dtl.doc-code  = p-doc-code :
  find first prt_goods no-lock where
            prt_goods.artic     = gds-dtl.artic       and
            prt_goods.prod-type = gds-dtl.prod-type   and
            prt_goods.prod-code = gds-dtl.prod-code   no-error .
   find first b2_doc-line-attr no-lock where b2_doc-line-attr.doc-code = p-doc-code         and
                                             b2_doc-line-attr.gds-code = prt_goods.gds-code  and
                                             num-entries(b2_doc-line-attr.attr-code) = 3    no-error .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_grp-nabor in g#lib-trn3
( input  prt_goods.gds-code ,
  output v-ok
)
.
    if v-ok = true then next.
    create  temp-gds-dtl .
    assign
    temp-gds-dtl.node-code  = gds-dtl.prt-code
    temp-gds-dtl.artic     = prt_goods.artic
    temp-gds-dtl.prod-type = prt_goods.prod-type
    temp-gds-dtl.prod-code = prt_goods.prod-code
    temp-gds-dtl.gds-code  = prt_goods.gds-code
    temp-gds-dtl.rel-bk    = if available b2_doc-line-attr then true else false
    .
end.
v-str = bk_goods.artic + " " + bk_goods.gds-name .
define buffer buf_doc-line-attr for doc-line-attr.
define buffer buf_gds-dtl for gds-dtl.
define buffer buf_goods   for goods.
        for each buf_doc-line-attr no-lock
          where buf_doc-line-attr.doc-code  = p-doc-code
            and lookup ('fl_gds-code':U , buf_doc-line-attr.attr-code ) > 0
            and lookup (string(p-bk-gds-code)      , buf_doc-line-attr.attr-code ) > 0
            :
            if integer (entry( 3 , buf_doc-line-attr.attr-code)) <> p-bk-gds-code then next.
              find first buf_goods no-lock where buf_goods.gds-code = buf_doc-line-attr.gds-code no-error .
              find first  buf_gds-dtl no-lock where
                          buf_gds-dtl.doc-code  = p-doc-code          and
                          buf_gds-dtl.artic     = buf_goods.artic     and
                          buf_gds-dtl.prod-type = buf_goods.prod-type and
                          buf_gds-dtl.prod-code = buf_goods.prod-code and
                          buf_gds-dtl.prt-code  = integer ( entry (2 , buf_doc-line-attr.attr-code))
                          .
              if available buf_gds-dtl then do:
                create tt-doc-line-attr.
                BUFFER-COPY buf_doc-line-attr TO tt-doc-line-attr.
                assign
                  tt-doc-line-attr.node-code  = integer ( entry (2 , buf_doc-line-attr.attr-code))
                  tt-doc-line-attr.price-rubl = buf_gds-dtl.price-rubl
                  tt-doc-line-attr.price-base = buf_gds-dtl.price-base
                .
                if t-doc.status_ = 'факт':U then
                assign
                   tt-doc-line-attr.price-rubl = buf_gds-dtl.price-rubl  -    buf_gds-dtl.discnt-rubl
                   tt-doc-line-attr.price-base = buf_gds-dtl.price-base  -    buf_gds-dtl.discnt-base
                .
              end.
        end.
END PROCEDURE.
PROCEDURE re-disp :
assign
  v-itogo-base = 0
  v-itogo-rubl = 0
.
   for each tt2-doc-line-attr :
      assign
        v-itogo-base = (tt2-doc-line-attr.price-base * dec(tt2-doc-line-attr.attr-value))  + v-itogo-base
        v-itogo-rubl = (tt2-doc-line-attr.price-rubl * dec(tt2-doc-line-attr.attr-value))  + v-itogo-rubl
    .
   end.
define variable v-itogo-base2 as decimal   no-undo .
define variable v-itogo-rubl2 as decimal   no-undo .
v-itogo-base2 = v-itogo-base - (v-itogo-base * t-doc.discnt-pc / 100 ) .
v-itogo-rubl2 = v-itogo-rubl - (v-itogo-rubl * t-doc.discnt-pc / 100 ) .
IF t-doc.status_ = 'факт':U THEN DO:
  v-sum-with-disc-base = v-itogo-base2 .
  v-sum-with-disc-rubl = v-itogo-rubl2 .
END.
ELSE DO:
  v-sum-with-disc-base = v-itogo-base2 +  (v-pr-wrk  ) * v-itogo-base2 / 100 .
  v-sum-with-disc-rubl = v-itogo-rubl2 +  (v-pr-wrk  ) * v-itogo-rubl2 / 100 .
END.
display
  v-prim-str
  v-pr-wrk
  v-sum-with-disc-rubl  when t-doc.status_ <> 'факт':U
  v-sum-with-disc-base  when t-doc.status_ <> 'факт':U
  v-itogo-base
  v-itogo-rubl
  v-pr-sk
  WITH FRAME Dialog-Frame.
  if  t-doc.status_ =  'факт':U then
  hide v-sum-with-disc-rubl
       v-sum-with-disc-base
       text-1
       in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE save-proc :
do
  on error undo, return error return-value
  :
define variable v-ok as logical   no-undo .
define buffer buf_doc-line-attr for doc-line-attr.
if p-doc-mode = 'ПРОСМОТР':U then return .
  for each buf_doc-line-attr exclusive-lock
    where buf_doc-line-attr.doc-code  = p-doc-code
      and lookup ('fl_gds-code':U , buf_doc-line-attr.attr-code ) > 0
      and lookup (string(p-bk-gds-code)      , buf_doc-line-attr.attr-code ) > 0
      :
        if integer (entry( 3 , buf_doc-line-attr.attr-code)) <> p-bk-gds-code then next.
        find first tt-doc-line-attr where
                      tt-doc-line-attr.doc-code = buf_doc-line-attr.doc-code
                  and tt-doc-line-attr.gds-code = buf_doc-line-attr.gds-code
                  and tt-doc-line-attr.attr-code = buf_doc-line-attr.attr-code no-error .
        if available tt-doc-line-attr then do:
          if buf_doc-line-attr.attr-value <> tt-doc-line-attr.attr-value then
          assign
            buf_doc-line-attr.attr-value = tt-doc-line-attr.attr-value
          .
        end.
        else do:
          delete buf_doc-line-attr.
        end.
  end.
define variable v-qnty as decimal   no-undo .
define variable v-qnty-prt as decimal   no-undo .
define buffer buf_goods for goods.
define buffer buf2_goods for goods.
define buffer buf2_doc-line for doc-line.
define buffer ready_trn-doc for trn-doc.
define buffer nakl_trn-doc for trn-doc.
find first nakl_trn-doc  no-lock where nakl_trn-doc.doc-code  = p-doc-code no-error .
if nakl_trn-doc.status_ = 'запрос':U then return .
find first ready_trn-doc no-lock where ready_trn-doc.doc-code = nakl_trn-doc.out-code no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден документ-щепка в статусе ГОТОВ"
      view-as alert-box error .
    return error.
  end.
for each gds-dtl exclusive-lock where gds-dtl.doc-code  = p-doc-code ,
    first temp-gds-dtl where
        temp-gds-dtl.artic     = gds-dtl.artic and
        temp-gds-dtl.prod-type = gds-dtl.prod-type and
        temp-gds-dtl.prod-code = gds-dtl.prod-code and
        temp-gds-dtl.node-code = gds-dtl.prt-code and
        temp-gds-dtl.rel-bk = true
  :
    v-qnty = 0 .
    v-qnty-prt = 0 .
    for each buf2_doc-line no-lock where buf2_doc-line.doc-code  = ready_trn-doc.doc-code :
      find first buf2_goods no-lock where
                buf2_goods.artic     = buf2_doc-line.artic       and
                buf2_goods.prod-type = buf2_doc-line.prod-type   and
                buf2_goods.prod-code = buf2_doc-line.prod-code   no-error .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_grp-nabor in g#lib-trn3
( input  buf2_goods.gds-code ,
  output v-ok
)
.
        if v-ok then do:
            run lineattr-value-flora-gds (
                input   p-doc-code       ,
                input   temp-gds-dtl.gds-code   ,
                input   gds-dtl.prt-code  ,
                input   buf2_goods.gds-code    ,
                input   'fl_gds-code':U        ,
                output  v-qnty       ).
            v-qnty-prt = v-qnty-prt + v-qnty .
         end.
    end.
    if v-qnty-prt <> gds-dtl.fact-qnty then do:
       p-make = true .
       find first doc-line exclusive-lock where
                 doc-line.doc-code   = gds-dtl.doc-code  and
                 doc-line.artic      = gds-dtl.artic     and
                 doc-line.prod-type  = gds-dtl.prod-type and
                 doc-line.prod-code  = gds-dtl.prod-code no-error .
      if not t-doc.flag_ and t-doc.status_ <> 'разрешен':U then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  chg-qnty = v-qnty-prt - ub.gds-dtl.doc-qnty
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
      else do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  chg-qnty = v-qnty-prt - ub.gds-dtl.fact-qnty
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
      find first buf2_goods no-lock where
                buf2_goods.artic     = doc-line.artic       and
                buf2_goods.prod-type = doc-line.prod-type   and
                buf2_goods.prod-code = doc-line.prod-code   no-error .
      if gds-dtl.doc-qnty = 0 then do:
           assign line-mode = 'ИЗМЕНЕНИЕ':U.
            run str/out-add.p
            (  parparentproc
             , recid(t-doc)
             , recid(doc-line)
             , recid(gds-dtl)
             , recid(buf2_goods)
             , "delete"
             , ? ).
         end.
    end.
end.
p-sum1 = v-sum-with-disc-rubl .
p-sum2 = v-sum-with-disc-base .
end.
end procedure.
