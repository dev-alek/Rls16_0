block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo .
define input  parameter p-doc-code as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: addsuper.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/addsuper.p $":U .
define variable vss-description as character no-undo init "Вкручивание Дополнительных расходов в учетную цену".
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
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
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
define variable v-insalepr as logical   no-undo .
define variable v-method as character no-undo .
define variable varvalue as character no-undo .
define variable vartype  as character no-undo .
define variable v-ves     as decimal   no-undo  init 0.
define variable v-wt-base as decimal   no-undo init 0 .
define variable g#report-num as integer   no-undo .
define stream  errStream  .
define variable v-gds-code as integer   no-undo .
define variable v-old-other as character no-undo .
define variable v-old-other-type as character no-undo .
define variable v-NEW-other as character no-undo .
define variable v-NEW-other-type as character no-undo .
define variable v-old-other-rubl as decimal   no-undo .
define variable v-old-other-base as decimal   no-undo .
define variable v-old-tr-rubl as decimal   no-undo .
define variable v-old-tr-base as decimal   no-undo .
define variable v-NEW-other-rubl as decimal   no-undo .
define variable v-NEW-other-base as decimal   no-undo .
define variable v-delta-base  as decimal   no-undo .
define variable v-delta-rubl  as decimal   no-undo .
run get-report-num   in parParentProc ( output g#report-num ) .
define variable v-exis as logical no-undo .
define variable v-txt as character no-undo .
find first ub.add-doc no-lock where
           ub.add-doc.doc-code = p-doc-code no-error .
if error-status :error then return error substitute("Нет документа ДопРасхода  &1" ,p-doc-code ) .
define variable v-method-4 as logical   no-undo .
v-method-4 = false .
for each  ub.add-line no-lock where
          ub.add-line.doc-code = ub.add-doc.doc-code :
    find first ub.gds-add-charges no-lock where
               ub.gds-add-charges.gds-code = ub.add-line.gds-code and
               ub.gds-add-charges.algoritm = '4' no-error .
     if available ub.gds-add-charges then  do:
        v-method-4 = true .
        leave.
     end.
end.
define variable   v-tot-sale  as decimal   no-undo .
define variable   v-fact-qnty  as decimal   no-undo .
define variable   v-cli-qnty  as decimal   no-undo .
define variable vv-dl as decimal   no-undo .
assign
  v-tot-sale  = 0
  v-fact-qnty = 0
  v-cli-qnty  = 0
  vv-dl = 0
.
for each ub.add-trn no-lock where ub.add-trn.doc-code = p-doc-code :
  for each ub.trn-doc no-lock where
           ub.trn-doc.doc-code = ub.add-trn.trn-doc-code :
           vv-dl = 0 .
           for each ub.doc-line no-lock where
                    ub.doc-line.doc-code = ub.trn-doc.doc-code :
             vv-dl = vv-dl + ( ub.doc-line.price-cli * ub.doc-line.cli-qnty) * ub.trn-doc.exch-rate  / ub.trn-doc.exch-scale .
           end.
    v-tot-sale  = v-tot-sale  + vv-dl  .
    v-fact-qnty = v-fact-qnty + ub.trn-doc.fact-qnty  .
    v-cli-qnty  = v-cli-qnty  + ub.trn-doc.cli-qnty   .
  end.
end.
if v-method-4 = true then do:
output stream errStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
    v-exis = false .
   for each ub.add-trn no-lock where ub.add-trn.doc-code = p-doc-code,
       each ub.doc-line no-lock where ub.doc-line.doc-code = ub.add-trn.trn-doc-code :
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
tr:
do transaction
   ON ERROR   UNDO tr, LEAVE
   ON END-KEY UNDO tr, LEAVE
   ON STOP    UNDO tr , LEAVE :
  for each ub.add-trn no-lock where ub.add-trn.doc-code = p-doc-code,
      each ub.doc-line exclusive-lock   where ub.doc-line.doc-code = ub.add-trn.trn-doc-code :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  ub.doc-line.artic
  ,input  ub.doc-line.prod-type
  ,input  ub.doc-line.prod-code
  ,output v-gds-code
  )  .
        run lineattr-value in this-procedure (
            ub.doc-line.doc-code ,
            v-gds-code    ,
            'new_other-ras':U ,
            output v-NEW-other       ,
            output v-NEW-other-type
            ) no-error .
        v-NEW-other-rubl = decimal ( entry(1,v-NEW-other,chr(4))) no-error .
        v-NEW-other-base = decimal ( entry(2,v-NEW-other,chr(4))) no-error .
        run lineattr-value in this-procedure (
            ub.doc-line.doc-code ,
            v-gds-code    ,
            'old_other-ras':U ,
            output v-old-other       ,
            output v-old-other-type
            ) no-error .
         if error-status :error or v-old-other = "" then
         assign
            v-old-other-rubl = 0
            v-old-other-base = 0
            v-old-tr-rubl = 0
            v-old-tr-base = 0
         .
         else do:
            v-old-other-rubl = decimal ( entry(1,v-old-other,chr(4))) no-error .
            v-old-other-base = decimal ( entry(2,v-old-other,chr(4))) no-error .
            v-old-tr-rubl    = decimal ( entry(3,v-old-other,chr(4))) no-error .
            v-old-tr-base    = decimal ( entry(4,v-old-other,chr(4))) no-error .
            if v-old-other-rubl = ? then v-old-other-rubl = 0 .
            if v-old-other-base = ? then v-old-other-base = 0 .
            if v-old-tr-rubl    = ? then v-old-tr-rubl = 0 .
            if v-old-tr-base    = ? then v-old-tr-base = 0 .
        end.
      assign
        ub.doc-line.transport-rubl = ub.doc-line.transport-rubl  -  v-old-tr-rubl
        ub.doc-line.transport-base = ub.doc-line.transport-base  -  v-old-tr-base
        ub.doc-line.other-rubl = ub.doc-line.other-rubl  -  v-NEW-other-rubl -  v-old-other-rubl
        ub.doc-line.other-base = ub.doc-line.other-base  -  v-NEW-other-base -  v-old-other-base
        ub.doc-line.price-rubl = ub.doc-line.price-rubl  -  v-NEW-other-rubl -  v-old-other-rubl -  v-old-tr-rubl
        ub.doc-line.price-base = ub.doc-line.price-base  -  v-NEW-other-base -  v-old-other-base -  v-old-tr-base
      .
  end.
  for each ub.add-line no-lock where
           ub.add-line.doc-code = p-doc-code ,
           first ub.gds-add-charges no-lock where
                 ub.gds-add-charges.gds-code = ub.add-line.gds-code and
                 ub.gds-add-charges.cost-include = true
           :
   for each ub.add-trn no-lock where
            ub.add-trn.doc-code = p-doc-code ,
       each ub.doc-line exclusive-lock where
            ub.doc-line.doc-code = ub.add-trn.trn-doc-code
            :
       find first ub.goods where ub.goods.artic     = ub.doc-line.artic     and
                              ub.goods.prod-type = ub.doc-line.prod-type and
                              ub.goods.prod-code = ub.doc-line.prod-code no-lock.
       find ub.units where ub.units.unit-name = ub.goods.unit-base no-lock.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                                " Недопустимы  прочие расходы.".
       end.
       if ub.doc-line.other-rubl     = ? then ub.doc-line.other-rubl     = 0.
       if ub.doc-line.other-base     = ? then ub.doc-line.other-base     = 0.
       if  ub.units.type = 'вес':U then do:
           v-wt-base = ub.doc-line.fact-qnty.
          end.
          else do:
            v-wt-base = ub.goods.wt-base * ub.doc-line.fact-qnty.
          end.
        assign
          v-delta-base = 0
          v-delta-rubl = 0
        .
        case ub.gds-add-charges.algoritm :
            when "1"  then do:
                  assign
                        ub.doc-line.other-base = ub.doc-line.other-base + ( ub.doc-line.price-base * ub.add-line.sum-rubl  / v-tot-sale)
                        ub.doc-line.other-rubl = ub.doc-line.other-rubl + ( ub.doc-line.price-rubl * ub.add-line.sum-rubl  / v-tot-sale)
                        v-delta-base =  ub.doc-line.price-base * ub.add-line.sum-rubl  / v-tot-sale
                        v-delta-rubl =  ub.doc-line.price-rubl * ub.add-line.sum-rubl  / v-tot-sale
                    .
            end.
            when "2"  then do:
                  assign
                        ub.doc-line.other-base = ub.doc-line.other-base + ( ub.add-line.sum-base  / v-fact-qnty )
                        ub.doc-line.other-rubl = ub.doc-line.other-rubl + ( ub.add-line.sum-rubl  / v-fact-qnty )
                        v-delta-base =  ub.add-line.sum-base  / v-fact-qnty
                        v-delta-rubl =  ub.add-line.sum-rubl  / v-fact-qnty
                        .
            end.
            when "3"  then do:
                  assign
                        ub.doc-line.other-base = ub.doc-line.other-base + (( ub.doc-line.cli-qnty * ub.add-line.sum-base  / v-cli-qnty ) / ub.doc-line.fact-qnty )
                        ub.doc-line.other-rubl = ub.doc-line.other-rubl + (( ub.doc-line.cli-qnty * ub.add-line.sum-rubl  / v-cli-qnty ) / ub.doc-line.fact-qnty )
                        v-delta-base = ( ub.doc-line.cli-qnty * ub.add-line.sum-base  / v-cli-qnty ) / ub.doc-line.fact-qnty
                        v-delta-rubl = ( ub.doc-line.cli-qnty * ub.add-line.sum-rubl  / v-cli-qnty ) / ub.doc-line.fact-qnty
                        .
            end.
            when "4"  then do:
                  assign
                        ub.doc-line.other-base = ub.doc-line.other-base + ( v-wt-base * ub.add-line.sum-base  / v-ves) / ub.doc-line.fact-qnty
                        ub.doc-line.other-rubl = ub.doc-line.other-rubl + ( v-wt-base * ub.add-line.sum-rubl  / v-ves) / ub.doc-line.fact-qnty
                        v-delta-base = ( v-wt-base * ub.add-line.sum-base  / v-ves ) / ub.doc-line.fact-qnty
                        v-delta-rubl = ( v-wt-base * ub.add-line.sum-rubl  / v-ves ) / ub.doc-line.fact-qnty
                    .
            end.
        end case.
        run add-d-part
          (input ub.doc-line.doc-code
          ,input p-doc-code
          ,input ub.goods.gds-code
          ,input ub.gds-add-charges.gds-code
          ,input ub.add-line.cli-type
          ,input ub.add-line.cli-code
          ,input ub.add-line.contract-code
          ,input ub.add-line.host-code
          ,input ub.add-line.vat-pc
          ,input v-delta-base
          ,input v-delta-rubl
          ) no-error.
        if error-status:error then do:
          undo tr, return error substitute(" Ошибка создания партий по дополнительному расходу в учетной цене &1 &2" , return-value , error-status :get-message(1)   ) .
        end.
  end.
 end.
   for each ub.add-trn no-lock where ub.add-trn.doc-code = p-doc-code,
       first ub.trn-doc no-lock  where
             ub.trn-doc.doc-code = ub.add-trn.trn-doc-code :
       for each ub.doc-line exclusive-lock where
                ub.doc-line.doc-code = ub.trn-doc.doc-code :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  ub.doc-line.artic
  ,input  ub.doc-line.prod-type
  ,input  ub.doc-line.prod-code
  ,output v-gds-code
  )  .
            run lineattr-write in this-procedure (
                ub.doc-line.doc-code ,
                v-gds-code    ,
                'new_other-ras':U ,
                string(ub.doc-line.other-rubl) + chr(4) + string(ub.doc-line.other-base)
                ) .
            run lineattr-value in this-procedure (
                ub.doc-line.doc-code ,
                v-gds-code    ,
                'old_other-ras':U ,
                output v-old-other       ,
                output v-old-other-type
                ) no-error .
                if error-status :error or  v-old-other = ""  then
                assign
                  v-old-other-rubl = 0
                  v-old-other-base = 0
                  v-old-tr-rubl = 0
                  v-old-tr-base = 0
                .
                else do:
                  v-old-other-rubl = decimal ( entry(1,v-old-other,chr(4))) no-error .
                  v-old-other-base = decimal ( entry(2,v-old-other,chr(4))) no-error .
                  v-old-tr-rubl = decimal ( entry(3,v-old-other,chr(4))) no-error .
                  v-old-tr-base = decimal ( entry(4,v-old-other,chr(4))) no-error .
                  if v-old-other-rubl = ? then v-old-other-rubl = 0 .
                  if v-old-other-base = ? then v-old-other-base = 0 .
                  if v-old-tr-rubl    = ? then v-old-tr-rubl = 0 .
                  if v-old-tr-base    = ? then v-old-tr-base = 0 .
                end.
            ub.doc-line.price-rubl = ub.doc-line.price-rubl + ub.doc-line.other-rubl + v-old-other-rubl + v-old-tr-rubl.
            ub.doc-line.price-base = ub.doc-line.price-base + ub.doc-line.other-base + v-old-other-base + v-old-tr-base.
            ub.doc-line.other-rubl = ub.doc-line.other-rubl + v-old-other-rubl.
            ub.doc-line.other-base = ub.doc-line.other-base + v-old-other-base.
            ub.doc-line.transport-rubl = ub.doc-line.transport-rubl  +  v-old-tr-rubl .
            ub.doc-line.transport-base = ub.doc-line.transport-base  +  v-old-tr-base .
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
end.
procedure add-d-part :
define input  parameter p-trn-doc-code  as character no-undo .
define input  parameter p-add-doc-code  as character no-undo .
define input  parameter p-gds-code      as integer   no-undo .
define input  parameter p-add-gds-code  as integer   no-undo .
define input  parameter p-cli-type      as character no-undo .
define input  parameter p-cli-code      as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-vat-pc        as decimal   no-undo .
define input  parameter p-delta-base    as decimal   no-undo .
define input  parameter p-delta-rubl    as decimal   no-undo .
define buffer buf_parts-add for ub.parts-add .
define buffer buf_add-doc   for ub.add-doc   .
define buffer buf_add-line  for ub.add-line  .
define buffer buf_add-trn   for ub.add-trn   .
define buffer buf_contract for ub.contract  .
define variable varcr-incfo as logical   no-undo .
define variable varundef as logical   no-undo .
  do
  on error undo, return error return-value
  :
find first buf_parts-add exclusive-lock where
          buf_parts-add.in-code      =  p-trn-doc-code  and
          buf_parts-add.gds-code     =  p-gds-code      and
          buf_parts-add.part-code    =  ''              and
          buf_parts-add.add-doc-code =  p-add-doc-code  and
          buf_parts-add.add-gds-code =  p-add-gds-code  and
          buf_parts-add.cli-type     =  p-cli-type      and
          buf_parts-add.cli-code     =  p-cli-code      and
          buf_parts-add.host-code    =  p-host-code     and
          buf_parts-add.contract-code = p-contract-code no-error .
      if not available buf_parts-add then do:
        create buf_parts-add .
      end.
      assign
        buf_parts-add.in-code      =  p-trn-doc-code
        buf_parts-add.gds-code     =  p-gds-code
        buf_parts-add.part-code    =  ''
        buf_parts-add.add-doc-code =  p-add-doc-code
        buf_parts-add.add-gds-code =  p-add-gds-code
        buf_parts-add.cli-type     =  p-cli-type
        buf_parts-add.cli-code     =  p-cli-code
        buf_parts-add.host-code    =  p-host-code
        buf_parts-add.contract-code = p-contract-code
        buf_parts-add.sum-base      = p-delta-base
        buf_parts-add.sum-rubl      = p-delta-rubl
        buf_parts-add.sum-other-base = p-vat-pc
        buf_parts-add.sum-other-rubl = p-delta-rubl
      .
      find first buf_contract no-lock where
                buf_contract.host-code     = p-host-code    and
                buf_contract.contract-code = p-contract-code
                no-error .
      if available buf_contract then do:
          if lookup (buf_contract.usl-opl, 'По факту поставки,Отсрочка платежа (по поставке)') > 0 then do:
            assign
              varcr-incfo = yes.
          end.
          if buf_contract.usl-opl = 'Не определено':U then do:
            assign
              varundef = yes.
          end.
        find first buf_add-doc exclusive-lock where
                  buf_add-doc.doc-code = p-add-doc-code no-error .
        if varcr-incfo = yes then do:
          assign
            buf_add-doc.need-incfo = 1
            .
        end.
        else do:
          if varundef = yes  and buf_add-doc.need-incfo <> 1 then do:
            assign
              buf_add-doc.need-incfo = 2
              .
          end.
        end.
     if (buf_contract.gen-factur = 1  or
         buf_contract.gen-factur = 11 or
         buf_contract.gen-factur = 101 or
         buf_contract.gen-factur = 111 ) then do:
       assign  buf_add-doc.need-factur = 1 .
     end.
    end.
  end.
end procedure.
