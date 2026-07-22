block-level on error undo, throw.
using Progress.Lang.*.
using ibs.th.gbl.*.
using ibs.th.gbl.sys.*.
define input parameter v-doc-code like ub.trn-doc.doc-code no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Создание документов внутреннего перемещения":U .
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
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
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
define variable same_db as logical   no-undo initial no .
define variable v-today as date      no-undo.
define variable cli_doc-prt as logical   no-undo .
define variable obj_doc-prt as logical   no-undo .
define variable n_str       as integer   no-undo .
define variable v-base-code         like ub.currency.curr-code no-undo .
define variable v-doc-line-chg-qnty like ub.doc-line.doc-qnty  no-undo .
define variable l-goods-twounit     as logical   no-undo .
define variable var-ok-assort-pol   as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-doc-pl-rowid      as rowid     no-undo .
define variable v-event-code as character no-undo .
define variable is-petrolium               as logical   no-undo .
define variable is-pieces                  as logical   no-undo .
    define variable v-gds-attr-value-old as character no-undo .
    define variable v-gds-attr-type      as character no-undo .
define variable v-ext-doc-type as character no-undo .
define variable v-country-code as integer   no-undo .
define buffer buf_trn-doc       for ub.trn-doc .
define buffer buf_doc-line      for ub.doc-line .
define buffer buf_gds-dtl       for ub.gds-dtl .
define buffer buf_parts         for ub.parts .
define buffer buf_parts-attr    for ub.parts-attr .
define buffer new_parts-attr    for ub.parts-attr .
define buffer buf_doc-pl        for ub.doc-pl .
define buffer buf_doc-pl-attr   for ub.doc-pl-attr .
define buffer buf-first_trn-doc for ub.trn-doc .
define buffer buf-first_parts   for ub.parts .
define buffer doc-obj           for ub.clients .
define buffer buf_cliobj        for ub.clients .
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
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
do
for buf_trn-doc, buf_doc-line, buf_gds-dtl, buf_parts, buf_doc-pl, doc-obj, buf_cliobj
transaction
on error undo, return error return-value
:
  find first ub.trn-doc
    where ub.trn-doc.doc-code = v-doc-code
    no-error .
  if not available ub.trn-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ " v-doc-code
      view-as alert-box .
    undo, return error .
  end.
  define variable v-host-code like ub.trn-doc.host-code no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,output v-host-code
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода фирмы для объекта с которого происходит перемещение" skip
      "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      view-as alert-box error .
    undo, return error .
  end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода базовой валюты для фирмы" skip
      "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      view-as alert-box error .
    undo, return error .
  end.
  define variable v-cli-host-code like ub.trn-doc.host-code no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.trn-doc.cli-type
  ,input  ub.trn-doc.cli-code
  ,output v-cli-host-code
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода фирмы для объекта на который происходит перемещение" skip
      "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
      "Объект" ub.trn-doc.cli-type ub.trn-doc.cli-code skip
      view-as alert-box error .
    undo, return error .
  end.
  if v-cli-host-code <> v-host-code then do:
    message
      vss-workfile vss-revision vss-description skip
      "Документ " v-doc-code skip
      "Фирма объекта откуда происходит перемещение" skip
      "не совпадает с фирмой, куда происходит перемещение" skip
      "v-host-code"     v-host-code     skip
      "v-cli-host-code" v-cli-host-code skip
      "Закрытие документа невозможно" skip
      view-as alert-box error .
    undo, return error .
  end.
  find ub.clients no-lock
    where ub.clients.obj-type = ub.trn-doc.cli-type
      and ub.clients.obj-code = ub.trn-doc.cli-code
    no-error .
  if not available ub.clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный клиент" skip
      "Документ " v-doc-code skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      "Клиент" ub.trn-doc.cli-code ub.trn-doc.cli-type skip
      view-as alert-box .
    undo, return error .
  end.
  if  ub.trn-doc.cli-type <> 'скл':U
  and ub.trn-doc.cli-type <> 'маг':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Клиент документа внутреннего перемещения не является объектом"
      "Документ " v-doc-code skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      "Клиент" ub.trn-doc.cli-code ub.trn-doc.cli-type skip
      view-as alert-box error .
    undo, return error .
  end.
  find doc-obj no-lock
    where doc-obj.obj-type = ub.trn-doc.obj-type
      and doc-obj.obj-code = ub.trn-doc.obj-code
    no-error .
  if not available doc-obj then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный объект" skip
      "Документ " v-doc-code skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      "Клиент" ub.trn-doc.cli-code ub.trn-doc.cli-type skip
      view-as alert-box .
    undo, return error .
  end.
  if  ub.trn-doc.obj-type <> 'скл':U
  and ub.trn-doc.obj-type <> 'маг':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Объект документа внутреннего перемещения не является объектом"
      "Документ " v-doc-code skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      "Клиент" ub.trn-doc.cli-code ub.trn-doc.cli-type skip
      view-as alert-box error .
    undo, return error .
  end.
  if doc-obj.db-num = clients.db-num
  and clients.db-num > 0 then do:
    assign
      same_db = yes
    .
  end.
  if  ub.trn-doc.status_  = 'факт':U
  and lookup(ub.trn-doc.doc-type, 'рас,при':U) > 0
  and ub.trn-doc.internal = yes
  and ub.trn-doc.discnt-type <> 'прво':U then do:
  end.
  else do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "В качестве параметра можно передавать только документы" skip
      "внутреннего прихода, внутреннего расход" skip
      "закрытые до статуса" 'факт':U skip
      "Документ" ub.trn-doc.doc-code skip
      "Тип документа" ub.trn-doc.doc-type skip
      "Внутренний" ub.trn-doc.internal skip
      "discnt-type" ub.trn-doc.discnt-type skip
      "Статус" ub.trn-doc.status_ skip
      view-as alert-box error .
    undo, return error .
  end.
  if (g#db-num = 0 and same_db = no )
  or (g#db-num > 0 and same_db = yes)
  then do:
  end.
  else do:
    return.
  end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,input  'doc-prt=request':u
  ,output obj_doc-prt
  ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении атрибута объекта" skip
      "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      'doc-prt=request':u skip
      error-status:get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  ub.trn-doc.cli-type
  ,input  ub.trn-doc.cli-code
  ,input  'doc-prt=request':u
  ,output cli_doc-prt
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении атрибута объекта" skip
      "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
      "Объект" ub.trn-doc.cli-type ub.trn-doc.cli-code skip
      "doc-prt=request" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  if ub.trn-doc.doc-type = 'рас':U  then do:
    define variable vardoc-code as character no-undo .
    run doc-code in this-procedure
      (input  "pair",
      input  ub.trn-doc.obj-type,
      input  ub.trn-doc.obj-code,
      input  ub.trn-doc.doc-code,
      output vardoc-code  ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при генерации номера документа" skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error .
    end.
  end.
  else do:
    run doc-code in this-procedure
      (input  "trio",
      input  ub.trn-doc.obj-type,
      input  ub.trn-doc.obj-code,
      input  ub.trn-doc.doc-code,
      output vardoc-code) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при генерации номера документа." skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error .
    end.
  end.
find first buf_cliobj no-lock
  where buf_cliobj.obj-type = ub.trn-doc.obj-type
    and buf_cliobj.obj-code = ub.trn-doc.obj-code
  .
case ub.trn-doc.ext-doc-type :
    when 'iv':U then v-ext-doc-type = 'rv':U  .
    when 'ev':U then v-ext-doc-type = 'iv':U .
    when 'eo':U then v-ext-doc-type = 'io':U .
end case .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,output v-today
  )  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input ub.trn-doc.base-rate
,input ub.trn-doc.base-scale
,input ub.trn-doc.obj-code
,input ub.trn-doc.obj-type
,input buf_cliobj.obj-name
,input ub.clients.db-num
,input ub.trn-doc.creid
,input ub.trn-doc.discnt-type
,input vardoc-code
,input v-today
,input (if ub.trn-doc.doc-type = 'рас':U then 'при':U else 'возврат':U)
,input false
,input ub.trn-doc.host-code
,input ub.trn-doc.internal
,input ub.trn-doc.cli-code
,input ub.trn-doc.cli-type
,input ub.trn-doc.office
,input ub.trn-doc.pay-code
,input ''
,input no
,input ?
,input 'накл':U
,input ?
,input v-ext-doc-type
,input ?
) no-error
.
  if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании документа внутреннего перемещения" skip
      "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
      "Объект" ub.trn-doc.cli-type ub.trn-doc.cli-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error.
  end.
  find buf_trn-doc where buf_trn-doc.doc-code = vardoc-code.
  assign
    buf_trn-doc.exch-date     = ub.trn-doc.doc-date
    buf_trn-doc.exch-rate     = ub.trn-doc.base-rate
    buf_trn-doc.out-code      = ub.trn-doc.doc-code
    buf_trn-doc.ship-num      = ub.trn-doc.ship-num
    buf_trn-doc.ship-date     = ub.trn-doc.ship-date
    buf_trn-doc.ord-num       = ub.trn-doc.ord-num
    buf_trn-doc.exch-scale    = ub.trn-doc.base-scale
    buf_trn-doc.exch-code     = v-base-code
    buf_trn-doc.fact-num      = 0
    buf_trn-doc.fact-date     = if buf_trn-doc.ext-doc-type = 'io':U then ub.trn-doc.fact-date else ?
    buf_trn-doc.print-rubl    = ub.trn-doc.print-rubl
    buf_trn-doc.wrkr          = if buf_trn-doc.ext-doc-type = 'io':U then ub.trn-doc.wrkr else ?
    buf_trn-doc.agnt          = ub.trn-doc.agnt
    buf_trn-doc.boss          = ub.trn-doc.boss
    buf_trn-doc.reason-code   = ub.trn-doc.reason-code
  .
  if buf_trn-doc.ext-doc-type = 'io':U then do :
      assign
        buf_trn-doc.shift-date = ub.trn-doc.shift-date
        buf_trn-doc.shift-name = ub.trn-doc.shift-name
        buf_trn-doc.shift-num  = ub.trn-doc.shift-num
      .
  end.
  assign
    n_str = 0
  .
  define variable v-attr-exist as logical   no-undo .
  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-xst in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 'purchlimit':U ,
                       output v-attr-exist )  .
  if v-attr-exist = true
  then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 'purchlimit':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input buf_trn-doc.doc-code ,
                       input 'purchlimit':U ,
                       input v-attr-value )  .
  end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-xst in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 'purchcodelist':U ,
                       output v-attr-exist )  .
  if v-attr-exist = true
  then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 'purchcodelist':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input buf_trn-doc.doc-code ,
                       input 'purchcodelist':U ,
                       input v-attr-value )  .
  end.
  if buf_trn-doc.ext-doc-type = 'io':U then do :
        for each buf_doc-pl no-lock where
                 buf_doc-pl.obj-type    = buf_trn-doc.obj-type and
                 buf_doc-pl.obj-code    = buf_trn-doc.obj-code and
                 buf_doc-pl.out-code    = buf_trn-doc.out-code :
            find first  buf_doc-pl-attr exclusive-lock
                  where buf_doc-pl-attr.obj-type    = buf_doc-pl.obj-type
                    and buf_doc-pl-attr.obj-code    = buf_doc-pl.obj-code
                    and buf_doc-pl-attr.pl-code     = buf_doc-pl.pl-code
                    and buf_doc-pl-attr.out-code    = buf_doc-pl.out-code
                    and buf_doc-pl-attr.gds-code    = buf_doc-pl.gds-code
                    and buf_doc-pl-attr.attr-code   = 'place2' no-error .
            if not available buf_doc-pl-attr then do :
                return error return-value .
            end.
            create ub.doc-pl .
            buffer-copy buf_doc-pl to ub.doc-pl
            assign
                ub.doc-pl.out-code = buf_trn-doc.doc-code
                ub.doc-pl.pl-code = integer(buf_doc-pl-attr.attr-value)
            .
        end.
  end.
  for each ub.doc-line
    where ub.doc-line.doc-code = ub.trn-doc.doc-code use-index line-num
  on error undo, return error substitute("&1 (ub.doc-line). &3&2&4", vss-workfile, chr(10), error-status :get-message(1), return-value  )
  :
    find first ub.goods no-lock
      where ub.goods.artic     = ub.doc-line.artic
        and ub.goods.prod-type = ub.doc-line.prod-type
        and ub.goods.prod-code = ub.doc-line.prod-code
      .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  ub.goods.artic
  ,input  ub.goods.prod-type
  ,input  ub.goods.prod-code
  ,input  'twounit=request':u
  ,output l-goods-twounit
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
        "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.goods.artic
  ,  input ub.goods.prod-type
  ,  input ub.goods.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара (petrolium)" skip
        "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
        "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      v-doc-line-chg-qnty = 0
    .
    if ub.doc-line.fact-qnty < 0 then do:
      message
        vss-workfile vss-revision vss-description skip
        "В документе внутреннего перемещения" skip
        "фактическое количество в линии не может быть отрицательным" skip
        "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
        "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
        "Фактическое количество" ub.doc-line.fact-qnty skip
        view-as alert-box error .
      undo, return error .
    end.
    if ub.doc-line.fact-qnty > ub.doc-line.doc-qnty then do:
      message
        vss-workfile vss-revision vss-description skip
        "В документе внутреннего перемещения" skip
        "фактическое количество в линии" skip
        "не может превышать количество по документу" skip
        "Документ внутреннего перемещения" ub.trn-doc.doc-code skip
        "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if ub.trn-doc.doc-type = 'рас':U
    and ub.doc-line.fact-qnty  <> 0
    then do:
      assign
        v-doc-line-chg-qnty = ub.doc-line.fact-qnty
      .
    end.
    if  ub.trn-doc.doc-type = 'при':U
    and ub.doc-line.fact-qnty < ub.doc-line.doc-qnty then do:
      assign
        v-doc-line-chg-qnty = ub.doc-line.doc-qnty - ub.doc-line.fact-qnty
      .
    end.
    if v-doc-line-chg-qnty = 0 then do:
      next.
    end.
    assign
      n_str = n_str + 1
    .
    create buf_doc-line.
    assign
      buf_doc-line.doc-code       = buf_trn-doc.doc-code
      buf_doc-line.obj-type       = buf_trn-doc.obj-type
      buf_doc-line.obj-code       = buf_trn-doc.obj-code
      buf_doc-line.artic          = ub.doc-line.artic
      buf_doc-line.prod-type      = ub.doc-line.prod-type
      buf_doc-line.prod-code      = ub.doc-line.prod-code
      buf_doc-line.fact-qnty      = v-doc-line-chg-qnty
      buf_doc-line.price-rubl     = ub.doc-line.price-rubl
      buf_doc-line.price-base     = ub.doc-line.price-base
      buf_doc-line.price-cli      = ub.doc-line.price-base
      buf_doc-line.SLT-pc         = ub.doc-line.SLT-pc
      buf_doc-line.VAT-pc         = ub.doc-line.VAT-pc
      buf_doc-line.cons-vat-pc    = ub.doc-line.cons-vat-pc
      buf_doc-line.road-tax       = ub.doc-line.road-tax
      buf_doc-line.excise         = ub.doc-line.excise
      buf_doc-line.transport-base = ub.doc-line.transport-base
      buf_doc-line.transport-rubl = ub.doc-line.transport-rubl
      buf_doc-line.other-base     = ub.doc-line.other-base
      buf_doc-line.other-rubl     = ub.doc-line.other-rubl
      buf_doc-line.unit-cli       = ( if ub.doc-line.fact-density > 0.00 and ub.doc-line.fact-density < 1.00
                                      then ub.goods.unit-cli
                                      else ub.goods.unit-base )
      buf_doc-line.doc-qnty       = v-doc-line-chg-qnty
      buf_doc-line.prt-root       = ub.doc-line.prt-root
      buf_doc-line.prt-OK         = yes
      buf_doc-line.fact-order     = 0
      buf_doc-line.cli-qnty       = v-doc-line-chg-qnty * ( if ub.doc-line.fact-density > 0.00 and ub.doc-line.fact-density < 1.00
                                                            then ub.doc-line.fact-density
                                                            else 1 )
      buf_doc-line.doc-density    = ub.doc-line.fact-density
      buf_doc-line.cli-base-rate  = ub.doc-line.cli-base-rate
      buf_doc-line.num-place      = ub.doc-line.num-place * v-doc-line-chg-qnty / ub.doc-line.fact-qnty
      buf_doc-line.wt-brutto      = ub.doc-line.wt-brutto * v-doc-line-chg-qnty / ub.doc-line.fact-qnty
    .
    if buf_doc-line.cli-base-rate = ? then do: assign buf_doc-line.cli-base-rate = 1.00. end.
    if buf_doc-line.doc-density   = ? then do: assign buf_doc-line.doc-density   = 1.00. end.
    assign
      buf_doc-line.fact-density  = buf_doc-line.doc-density
    .
    define variable v-part-chg-qnty as decimal no-undo .
    define variable v-total-parts-cli-qnty as decimal   no-undo .
    assign
      v-total-parts-cli-qnty = 0
    .
    for each ub.parts
      where ub.parts.obj-type  = ub.doc-line.obj-type
        and ub.parts.obj-code  = ub.doc-line.obj-code
        and ub.parts.artic     = ub.doc-line.artic
        and ub.parts.prod-type = ub.doc-line.prod-type
        and ub.parts.prod-code = ub.doc-line.prod-code
        and ub.parts.out-code  = ub.doc-line.doc-code
    on error undo, return error
    :
      assign
        v-part-chg-qnty = 0
      .
      if ub.parts.fact-qnty < 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "В документе внутреннего перемещения" skip
          "фактическое количество в партии не может быть отрицательным" skip
          view-as alert-box error .
        undo, return error .
      end.
      if ub.parts.fact-qnty > ub.parts.qnty then do:
        message
          vss-workfile vss-revision vss-description skip
          "В документе внутреннего перемещения" skip
          "фактическое количество в партии" skip
          "не может превышать количество в партии по документу" skip
          view-as alert-box error .
        undo, return error .
      end.
      if l-goods-twounit = true then do:
        if ub.parts.fact-qnty <> ub.parts.qnty
        and ub.parts.fact-qnty <> 0
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "В документе внутреннего перемещения фактическое количество в партии" skip
            "должно или равняться количеству по документу" skip
            "или быть равным нулю" skip
            view-as alert-box error .
          undo, return error .
        end.
        if ub.parts.cli-qnty <> 1
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "В документе внутреннего перемещения количество в ед.изм. поставщика" skip
            "должно должно равняться единице" skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      if ub.trn-doc.doc-type = 'рас':U
      and ub.parts.fact-qnty  <> 0
      then do:
        assign
          v-part-chg-qnty = ub.parts.fact-qnty
        .
      end.
      if  ub.trn-doc.doc-type = 'при':U
      and ub.parts.fact-qnty < ub.parts.qnty then do:
        assign
          v-part-chg-qnty = ub.parts.qnty - ub.parts.fact-qnty
        .
      end.
      if v-part-chg-qnty = 0 then do:
        next.
      end.
      if buf_trn-doc.ext-doc-type = 'io':U then do :
          find first ub.goods no-lock
               where ub.goods.artic     = ub.doc-line.artic
                 and ub.goods.prod-type = ub.doc-line.prod-type
                 and ub.goods.prod-code = ub.doc-line.prod-code .
          find first buf_doc-pl no-lock
               where buf_doc-pl.obj-type = ub.trn-doc.obj-type
                 and buf_doc-pl.obj-code = ub.trn-doc.obj-code
                 and buf_doc-pl.out-code = ub.trn-doc.doc-code
                 and buf_doc-pl.gds-code = ub.goods.gds-code
                 and buf_doc-pl.pl-code  = ub.parts.pl-code no-error .
          if available buf_doc-pl then do :
              find first  buf_doc-pl-attr exclusive-lock
                    where buf_doc-pl-attr.obj-type    = buf_doc-pl.obj-type
                      and buf_doc-pl-attr.obj-code    = buf_doc-pl.obj-code
                      and buf_doc-pl-attr.pl-code     = buf_doc-pl.pl-code
                      and buf_doc-pl-attr.out-code    = buf_doc-pl.out-code
                      and buf_doc-pl-attr.gds-code    = buf_doc-pl.gds-code
                      and buf_doc-pl-attr.attr-code   = 'place2' no-error .
              if not available buf_doc-pl-attr then do :
                  undo, return error ("Ошибка! " + return-value) .
              end.
          end.
      end.
      find first ub.goods no-lock where ub.goods.artic      = ub.parts.artic
                                    and ub.goods.prod-type  = ub.parts.prod-type
                                    and ub.goods.prod-code  = ub.parts.prod-code .
      find first ub.alc-type-gds no-lock
        where ub.alc-type-gds.gds-code = ub.goods.gds-code and
        ub.alc-type-gds.create-user-db-num = 0 no-error.
      create buf_parts .
      buffer-copy ub.parts to buf_parts
      assign
        buf_parts.out-code  = buf_trn-doc.doc-code
        buf_parts.obj-type  = buf_trn-doc.obj-type
        buf_parts.obj-code  = buf_trn-doc.obj-code
        buf_parts.status_   = no
        buf_parts.rsrv-free = ?
        buf_parts.pl-code   = if available buf_doc-pl-attr then integer(buf_doc-pl-attr.attr-value) else 0
        buf_parts.qnty      = v-part-chg-qnty
        buf_parts.fact-qnty = buf_parts.qnty
        buf_parts.cli-qnty  = 0
        buf_parts.part-code = if available buf_doc-pl-attr then buf_doc-pl-attr.attr-value
          else (if buf_trn-doc.ext-doc-type = 'iv':U and available (ub.alc-type-gds) then buf_parts.out-code + "," + ub.parts.part-code else ub.parts.part-code)
      .
    define buffer buf_marking for ub.marking .
    define buffer buf_marking-lines for ub.marking-lines .
    RUN gds-attr-value (
                        INPUT ub.goods.gds-code,
                        INPUT 'mark-type':U,
                        OUTPUT v-gds-attr-value-old,
                        OUTPUT v-gds-attr-type
                        ).
    if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(ub.parts.obj-type, ub.parts.obj-code):GetIsMarkingForType(v-gds-attr-value-old) then do:
      for each ub.marking-lines no-lock where ub.marking-lines.gds-code = ub.goods.gds-code
                                            and ub.marking-lines.part-code = ub.parts.part-code
                                            and ub.marking-lines.prt-code = ub.parts.prt-code
                                            and ub.marking-lines.in-code = ub.parts.in-code
                                            and ub.marking-lines.out-code = ub.parts.out-code
                                            and ub.marking-lines.obj-code = ub.parts.obj-code
                                            and ub.marking-lines.obj-type = ub.parts.obj-type,
            first buf_marking exclusive-lock where buf_marking.mark = ub.marking-lines.mark:
            find first buf_marking-lines no-lock where buf_marking-lines.in-code    = buf_parts.in-code
                                                   and buf_marking-lines.out-code   = buf_parts.out-code
                                                   and buf_marking-lines.part-code  = buf_parts.part-code
                                                   and buf_marking-lines.prt-code   = buf_parts.prt-code
                                                   and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                   and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                   and buf_marking-lines.gds-code   = ub.marking-lines.gds-code
                                                   and buf_marking-lines.mark       = ub.marking-lines.mark
                                                   no-error .
            if buf_trn-doc.ext-doc-type = 'rv':U then do:
                if not ub.marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB then do:
                    if not available buf_marking-lines then do :
                      create buf_marking-lines .
                      buffer-copy ub.marking-lines to buf_marking-lines
                      assign
                        buf_marking-lines.out-code = buf_parts.out-code
                        buf_marking-lines.obj-code = buf_parts.obj-code
                        buf_marking-lines.obj-type = buf_parts.obj-type
                      .
                    end .
                    assign
                      buf_marking.obj-code = buf_trn-doc.obj-code
                      buf_marking.obj-type = buf_trn-doc.obj-type
                      buf_marking.sts      = ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
                    .
                end.
            end.
            else do:
                if not available buf_marking-lines  then do :
                  create buf_marking-lines .
                  buffer-copy ub.marking-lines to buf_marking-lines
                  assign
                    buf_marking-lines.out-code = buf_parts.out-code
                    buf_marking-lines.obj-code = buf_parts.obj-code
                    buf_marking-lines.obj-type = buf_parts.obj-type
                    buf_marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB
                  .
                end .
                assign
                  buf_marking.obj-code = buf_trn-doc.obj-code
                  buf_marking.obj-type = buf_trn-doc.obj-type
                  buf_marking.sts      = ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
                .
                run str/callnews.p
                  (input 'marking':U
                  ,input (buffer buf_marking :handle)
                  ) no-error .
                if error-status:error then
                do:
                end.
            end.
        end.
    end.
      if buf_trn-doc.ext-doc-type = 'io':U or (buf_trn-doc.ext-doc-type = 'iv':U and available (ub.alc-type-gds)) then do :
          find first ub.goods no-lock where ub.goods.artic      = buf_parts.artic
                                        and ub.goods.prod-type  = buf_parts.prod-type
                                        and ub.goods.prod-code  = buf_parts.prod-code .
          find first buf_parts-attr no-lock
               where buf_parts-attr.in-code   = buf_parts.in-code
                 and buf_parts-attr.gds-code  = ub.goods.gds-code
                 and buf_parts-attr.part-code = buf_parts.part-code
                 no-error .
          if not available buf_parts-attr then do :
                run get-country-code in this-procedure
                  (input  buf_trn-doc.doc-code
                  ,input  buf_trn-doc.ext-doc-type
                  ,input  ub.goods.gds-code
                  ,output v-country-code
                  ) .
                create new_parts-attr .
                assign
                  new_parts-attr.in-code              = buf_parts.in-code
                  new_parts-attr.gds-code             = ub.goods.gds-code
                  new_parts-attr.part-code            = buf_parts.part-code
                  new_parts-attr.orig-in-code         = buf_parts.in-code
                  new_parts-attr.orig-gds-code        = ub.goods.gds-code
                  new_parts-attr.orig-part-code       = buf_parts.part-code
                  new_parts-attr.income-in-code       = buf_parts.in-code
                  new_parts-attr.income-gds-code      = ub.goods.gds-code
                  new_parts-attr.income-part-code     = buf_parts.part-code
                  new_parts-attr.supp-type            = buf_parts.supp-type
                  new_parts-attr.supp-code            = buf_parts.supp-code
                  new_parts-attr.pay-code             = buf_parts.pay-code
                  new_parts-attr.purch-code           = buf_parts.purch-code
                  new_parts-attr.cli-qnty             = buf_parts.cli-qnty
                  new_parts-attr.price-cli            = buf_parts.price-cli
                  new_parts-attr.unit-cli             = buf_doc-line.unit-cli
                  new_parts-attr.exch-code            = buf_parts.exch-code
                  new_parts-attr.exch-rate            = buf_trn-doc.exch-rate
                  new_parts-attr.exch-scale           = buf_trn-doc.exch-scale
                  new_parts-attr.cli-base-rate        = buf_parts.cli-base-rate
                  new_parts-attr.doc-qnty             = buf_parts.qnty
                  new_parts-attr.fact-qnty            = buf_parts.fact-qnty
                  new_parts-attr.real-qnty            = buf_parts.real-qnty
                  new_parts-attr.price-base           = buf_parts.price-base
                  new_parts-attr.price-rubl           = buf_parts.price-rubl
                  new_parts-attr.base-rate            = buf_trn-doc.base-rate
                  new_parts-attr.base-scale           = buf_trn-doc.base-scale
                  new_parts-attr.vat-type             = buf_parts.vat-type
                  new_parts-attr.vat-pc               = buf_parts.vat-pc
                  new_parts-attr.SLT-type             = buf_parts.SLT-type
                  new_parts-attr.SLT-pc               = buf_parts.SLT-pc
                  new_parts-attr.road-tax-base        = buf_parts.road-tax-base
                  new_parts-attr.road-tax-rubl        = buf_parts.road-tax-rubl
                  new_parts-attr.transport-base       = buf_parts.transport-base
                  new_parts-attr.transport-rubl       = buf_parts.transport-rubl
                  new_parts-attr.other-base           = buf_parts.other-base
                  new_parts-attr.other-rubl           = buf_parts.other-rubl
                  new_parts-attr.density              = buf_doc-line.doc-density
                  new_parts-attr.temperature          = buf_doc-line.temperature
                  new_parts-attr.is-supp              = buf_parts.is-supp
                  new_parts-attr.cst-code             = buf_parts.cst-code
                  new_parts-attr.last-date            = buf_parts.last-date
                  new_parts-attr.line-cli-qnty        = buf_doc-line.cli-qnty
                  new_parts-attr.line-doc-qnty        = buf_doc-line.doc-qnty
                  new_parts-attr.line-fact-qnty       = buf_doc-line.fact-qnty
                  new_parts-attr.wt-brutto            = buf_doc-line.wt-brutto
                  new_parts-attr.num-place            = buf_doc-line.num-place
                  new_parts-attr.country-code         = v-country-code
                  new_parts-attr.obj-type             = buf_trn-doc.obj-type
                  new_parts-attr.obj-code             = buf_trn-doc.obj-code
                  new_parts-attr.PS                   = buf_parts.PS
                  new_parts-attr.fact-date            = ub.trn-doc.fact-date
                  new_parts-attr.fact-time            = ub.trn-doc.fact-time
                  new_parts-attr.fact-order           = ub.trn-doc.fact-order
                  new_parts-attr.shift-num            = buf_trn-doc.shift-num
                  new_parts-attr.shift-name           = buf_trn-doc.shift-name
                  new_parts-attr.shift-date           = buf_trn-doc.shift-date
                  new_parts-attr.ext-doc-type         = buf_trn-doc.ext-doc-type
                  new_parts-attr.wrkr                 = buf_trn-doc.wrkr
                  new_parts-attr.agnt                 = buf_trn-doc.agnt
                  new_parts-attr.boss                 = buf_trn-doc.boss
                  new_parts-attr.creid                = buf_trn-doc.creid
                  new_parts-attr.out-code             = buf_trn-doc.out-code
                  new_parts-attr.inv-num              = buf_trn-doc.inv-num
                  new_parts-attr.cli-name             = buf_trn-doc.cli-name
                  new_parts-attr.ord-num              = buf_trn-doc.ord-num
                  new_parts-attr.is-back-date         = buf_trn-doc.is-back-date
                  new_parts-attr.is-corr              = buf_trn-doc.is-corr
                  new_parts-attr.is-del               = buf_trn-doc.is-del
                  new_parts-attr.contract-code        = buf_parts.contract-code
                  new_parts-attr.hold-doc-code-child  = buf_trn-doc.hold-doc-code-child
                  new_parts-attr.hold-doc-code-parent = buf_trn-doc.hold-doc-code-parent
                .
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
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
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
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
                  new_parts-attr.vat-base         = vat-base-loc
                  new_parts-attr.vat-rubl         = vat-rubl-loc
                  new_parts-attr.slt-base         = slt-base-loc
                  new_parts-attr.slt-rubl         = slt-rubl-loc
                  new_parts-attr.discnt-base      = 0
                  new_parts-attr.discnt-rubl      = 0
                .
          end.
      end.
      if l-goods-twounit = true
        or ( is-petrolium = true
             and is-pieces = false
           )
      then do:
        assign
          buf_parts.cli-qnty = ub.parts.cli-qnty
        .
        assign
          v-total-parts-cli-qnty = buf_parts.cli-qnty
        .
      end.
      if buf_trn-doc.ext-doc-type = 'rv':U
        and is-petrolium = true
        and is-pieces = false
      then do:
        if num-entries( buf_parts.part-code, '#':U ) > 1 then do:
          run trg/partjoin.p
            ( input buf_parts.obj-type
             ,input buf_parts.obj-code
             ,input buf_parts.artic
             ,input buf_parts.prod-type
             ,input buf_parts.prod-code
             ,input buf_parts.in-code
             ,input buf_parts.out-code
             ,input buf_parts.part-code
            ) no-error.
          if error-status :error then do:
            undo, return error substitute( "&1 (partjoin). Не удалось объединить партию с номером &2!&3&4&3&5", vss-workfile, buf_parts.part-code, chr(10), return-value, error-status :get-message ( error-status :num-messages ) ).
          end.
        end.
      end.
    end.
    if buf_trn-doc.ext-doc-type = 'rv':U
      and is-petrolium = true
      and is-pieces = false
    then do:
      undo, return error substitute( "&1. Запрещено создание возврата топливного товара.", vss-workfile ).
    end.
    if l-goods-twounit = true then do:
      assign
        buf_doc-line.cli-qnty = v-total-parts-cli-qnty
      .
      if buf_doc-line.cli-qnty <> 0 then do:
        assign
          buf_doc-line.cli-base-rate = buf_doc-line.doc-qnty / buf_doc-line.cli-qnty
        .
      end.
    end.
    define variable v-total-parts-qnty as decimal no-undo .
    define variable v-total-price-base as decimal no-undo .
    define variable v-total-price-rubl as decimal no-undo .
    assign
      v-total-parts-qnty = 0
      v-total-price-base = 0
      v-total-price-rubl = 0
    .
    for each ub.parts
      where ub.parts.obj-type  = buf_doc-line.obj-type
        and ub.parts.obj-code  = buf_doc-line.obj-code
        and ub.parts.artic     = buf_doc-line.artic
        and ub.parts.prod-type = buf_doc-line.prod-type
        and ub.parts.prod-code = buf_doc-line.prod-code
        and ub.parts.out-code  = buf_doc-line.doc-code
    on error undo, return error
    :
      assign
        v-total-parts-qnty = v-total-parts-qnty + parts.fact-qnty
        v-total-price-base = v-total-price-base + parts.fact-qnty * parts.price-base
        v-total-price-rubl = v-total-price-rubl + parts.fact-qnty * parts.price-rubl
      .
    end.
    if v-doc-line-chg-qnty <> v-total-parts-qnty then do:
      message
        vss-workfile vss-revision vss-description skip
        "Количество в партиях не совпадает с количеством в строке документа." skip
        "Количество по документу = " v-doc-line-chg-qnty skip
        "Количество по партиям = " v-total-parts-qnty skip
        view-as alert-box .
      undo, return error.
    end.
    if v-total-parts-qnty <> 0 then do:
      assign
        buf_doc-line.price-rubl = v-total-price-rubl / v-total-parts-qnty
        buf_doc-line.price-base = v-total-price-base / v-total-parts-qnty
        buf_doc-line.price-cli  = v-total-price-base / v-total-parts-qnty
      .
    end.
    define variable v-prt-create-n-c like ub.gds-prt.node-code no-undo .
    if cli_doc-prt <> obj_doc-prt then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  ub.goods.artic
  ,input  ub.goods.prod-type
  ,input  ub.goods.prod-code
  ,output v-prt-create-n-c
  )  .
      if cli_doc-prt = true then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  v-prt-create-n-c
  ,output v-prt-create-n-c
  )  .
      end.
    end.
    define variable v-gds-dtl-chg-qnty   as decimal no-undo .
    define variable v-total-gds-dtl-qnty as decimal no-undo .
    define variable v-create-n-c like ub.gds-prt.node-code no-undo .
    assign
      v-total-gds-dtl-qnty = 0
    .
    for each ub.gds-dtl no-lock
      where ub.gds-dtl.doc-code  = ub.doc-line.doc-code
        and ub.gds-dtl.prod-type = ub.doc-line.prod-type
        and ub.gds-dtl.prod-code = ub.doc-line.prod-code
        and ub.gds-dtl.artic     = ub.doc-line.artic
    on error undo, return error
    :
      assign
        v-gds-dtl-chg-qnty = 0
      .
      if ub.gds-dtl.fact-qnty < 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "В документе внутреннего перемещения в строке признака" skip
          "не может быть задано отрицательное количество" skip
          view-as alert-box error .
        undo, return error .
      end.
      if ub.trn-doc.doc-type = 'рас':U
      and ub.gds-dtl.fact-qnty  <> 0
      then do:
        assign
          v-gds-dtl-chg-qnty = ub.gds-dtl.fact-qnty
        .
      end.
      if ub.trn-doc.doc-type = 'при':U then do:
        if  cli_doc-prt = no
        and obj_doc-prt = yes then do:
          if ub.gds-dtl.fact-qnty <> ub.gds-dtl.doc-qnty then do:
            assign
              v-gds-dtl-chg-qnty = ub.gds-dtl.doc-qnty - ub.gds-dtl.fact-qnty
            .
          end.
        end.
        else do:
          if ub.gds-dtl.fact-qnty > ub.gds-dtl.doc-qnty then do:
            message
              vss-workfile vss-revision vss-description skip
              "В приходном документе в строке признака" skip
              "фактическое количество не может быть больше, чем количество по документу" skip
              view-as alert-box error .
            undo, return error .
          end.
          if ub.gds-dtl.fact-qnty < ub.gds-dtl.doc-qnty then do:
            assign
              v-gds-dtl-chg-qnty = ub.gds-dtl.doc-qnty - ub.gds-dtl.fact-qnty
            .
          end.
        end.
      end.
      if v-gds-dtl-chg-qnty = 0 then do:
        next.
      end.
      if cli_doc-prt = obj_doc-prt then do:
        assign
          v-create-n-c = ub.gds-dtl.prt-code
        .
      end.
      else do:
        assign
          v-create-n-c = v-prt-create-n-c
        .
      end.
      find first buf_gds-dtl
        where buf_gds-dtl.doc-code    = buf_trn-doc.doc-code
          and buf_gds-dtl.artic       = ub.doc-line.artic
          and buf_gds-dtl.prod-type   = ub.doc-line.prod-type
          and buf_gds-dtl.prod-code   = ub.doc-line.prod-code
          and buf_gds-dtl.prt-code    = v-create-n-c
        no-error .
      if not available buf_gds-dtl then do:
        create buf_gds-dtl.
        assign
          buf_gds-dtl.doc-code    = buf_trn-doc.doc-code
          buf_gds-dtl.artic       = ub.doc-line.artic
          buf_gds-dtl.prod-type   = ub.doc-line.prod-type
          buf_gds-dtl.prod-code   = ub.doc-line.prod-code
          buf_gds-dtl.prt-code    = v-create-n-c
          buf_gds-dtl.obj-type    = buf_trn-doc.obj-type
          buf_gds-dtl.obj-code    = buf_trn-doc.obj-code
        .
        if cli_doc-prt = obj_doc-prt then do:
          assign
            buf_gds-dtl.discnt-base = ub.gds-dtl.discnt-base
            buf_gds-dtl.discnt-rubl = ub.gds-dtl.discnt-rubl
            buf_gds-dtl.discnt-pc   = ub.gds-dtl.discnt-pc
            buf_gds-dtl.discnt-type = ub.gds-dtl.discnt-type
          .
        end.
        else do:
          assign
            buf_gds-dtl.discnt-base = 0
            buf_gds-dtl.discnt-rubl = 0
            buf_gds-dtl.discnt-pc   = 0
            buf_gds-dtl.discnt-type = ?
          .
        end.
      end.
      assign
        buf_gds-dtl.price-base     = ( buf_gds-dtl.price-base * buf_gds-dtl.fact-qnty
                                  + ub.gds-dtl.price-base * v-gds-dtl-chg-qnty )
                                  / (buf_gds-dtl.fact-qnty + v-gds-dtl-chg-qnty)
        buf_gds-dtl.price-rubl     = ( buf_gds-dtl.price-rubl * buf_gds-dtl.fact-qnty
                                  + ub.gds-dtl.price-rubl * v-gds-dtl-chg-qnty )
                                  / (buf_gds-dtl.fact-qnty + v-gds-dtl-chg-qnty)
        buf_gds-dtl.new-price-sale = ub.gds-dtl.new-price-sale
        buf_gds-dtl.ov             = yes
        buf_gds-dtl.fact-qnty      = buf_gds-dtl.fact-qnty + v-gds-dtl-chg-qnty
        buf_gds-dtl.doc-qnty       = buf_gds-dtl.doc-qnty  + v-gds-dtl-chg-qnty
        v-total-gds-dtl-qnty       = v-total-gds-dtl-qnty + v-gds-dtl-chg-qnty
      .
    end.
    if v-total-gds-dtl-qnty <> v-doc-line-chg-qnty then do:
      message
        vss-workfile vss-revision vss-description skip
        "Количество в признаках не совпадает с количеством в строке документа." skip
        "Количество по документу = " v-doc-line-chg-qnty skip
        "Количество по признакам = " v-total-gds-dtl-qnty skip
        view-as alert-box .
      undo, return error.
    end.
  end.
  if not can-find(first ub.doc-line
    where ub.doc-line.doc-code = buf_trn-doc.doc-code)
  then do:
    delete buf_trn-doc.
    return .
  end.
  assign
    buf_trn-doc.PS          = '@  Строк в документе : ' + string(n_str) + (if substring(ub.trn-doc.ps, 1, 1) = '@' then '' else chr(10) + ub.trn-doc.ps)
    buf_trn-doc.fact-base   = ?
    buf_trn-doc.fact-rubl   = ?
  .
  run gbl/calc-trn.p (input ? , INPUT RECID(buf_trn-doc)).
  run cus/oo-mkrcv.p (
        buffer ub.trn-doc ,
        buffer buf_trn-doc )
        no-error .
   if error-status :error then
   message vss-workfile vss-revision vss-description skip
          "Ошибка oo-mkrcv.p  " skip
           skip
           error-status :get-message(1) skip
           error-status :get-message(2) skip
           return-value skip
           view-as alert-box error
   .
  assign
    buf_trn-doc.flag_ = yes
  .
  for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code on error undo, return error return-value :
    find first ub.goods where
              ub.goods.artic     = buf_doc-line.artic     and
              ub.goods.prod-type = buf_doc-line.prod-type and
              ub.goods.prod-code = buf_doc-line.prod-code no-lock.
    var-ok-assort-pol = true .
    if buf_trn-doc.ext-doc-type = 'iv':U then do:
       v-event-code = substitute("&1" , buf_trn-doc.ext-doc-type ) .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  ub.goods.gds-code
  ,input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
    end.
    if var-ok-assort-pol = false then do:
        buf_trn-doc.PS = buf_trn-doc.PS + chr(10) + var-mess-assort-pol .
    end.
  end.
  run gbl/calc-trn.p (input ?  , input recid(buf_trn-doc)) no-error.
  if error-status :error then do:
    undo, return error return-value.
  end.
  define variable v-qnty as decimal no-undo .
  if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType(v-gds-attr-value-old) then
  do:
    if buf_trn-doc.ext-doc-type = 'rv':U then
    do:
      for each ub.doc-line no-lock where ub.doc-line.doc-code = buf_trn-doc.doc-code:
        for each ub.marking-lines no-lock where ub.marking-lines.gds-code = ub.goods.gds-code
          and ub.marking-lines.out-code = ub.trn-doc.doc-code
          and ub.marking-lines.obj-code = ub.trn-doc.obj-code
          and ub.marking-lines.obj-type = ub.trn-doc.obj-type,
          first buf_marking exclusive-lock where buf_marking.mark = ub.marking-lines.mark:
          if ub.marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB then
          do:
            assign
              buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB
              .
          end.
        end.
      end.
    end.
    if buf_trn-doc.ext-doc-type = 'iv':U then
    do:
      for each buf_doc-line exclusive-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
        first buf_gds-dtl exclusive-lock where buf_gds-dtl.doc-code = buf_doc-line.doc-code and buf_gds-dtl.artic = buf_doc-line.artic and
        buf_gds-dtl.prod-code = buf_doc-line.prod-code and buf_gds-dtl.prod-type = buf_doc-line.prod-type:
        v-qnty = v-qnty + buf_doc-line.fact-qnty .
        buf_doc-line.fact-qnty = 0 .
        buf_gds-dtl.fact-qnty = buf_doc-line.fact-qnty .
        for first buf_parts exclusive-lock where buf_parts.out-code = buf_doc-line.doc-code and buf_parts.artic = buf_doc-line.artic and
          buf_parts.prod-code = buf_doc-line.prod-code and buf_parts.prod-type = buf_doc-line.prod-type and buf_parts.obj-code = buf_doc-line.obj-code and
          buf_parts.obj-type = buf_doc-line.obj-type:
          buf_parts.fact-qnty = buf_doc-line.fact-qnty .
        end.
      end.
      buf_trn-doc.fact-qnty = buf_trn-doc.fact-qnty - v-qnty .
    end.
  end.
end.
procedure get-country-code :
  define input  parameter p-trn-doc      as character no-undo .
  define input  parameter p-ext-doc-type as character no-undo .
  define input  parameter p-gds-code     as integer   no-undo .
  define output parameter p-country-code as integer   no-undo .
  define buffer buf_goods   for ub.goods .
  define buffer buf_country for ub.country .
  define variable v-read-default-code as logical   no-undo .
  define variable v-attr-value        as character no-undo .
  define variable v-attr-type         as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-read-default-code = true
    .
    if p-ext-doc-type = 'ie':U
    then do:
      run lineattr-value in this-procedure
        (input  p-trn-doc
        ,input  p-gds-code
        ,input  'country-code':U
        ,output v-attr-value
        ,output v-attr-type
        ) .
      if v-attr-value <> ""
      then do:
        assign
          v-read-default-code = false
          p-country-code      = integer(v-attr-value)
        .
      end.
    end.
    if v-read-default-code = true
    then do:
      find first buf_goods no-lock
        where buf_goods.gds-code = p-gds-code
        no-error .
      find first buf_country no-lock
        where buf_country.alpha1 = buf_goods.alpha1
        no-error .
      if available buf_country
      then do:
        assign
          p-country-code = buf_country.num-code
        .
      end.
      else do:
        assign
          p-country-code = 0
        .
      end.
    end.
  end.
end procedure.
