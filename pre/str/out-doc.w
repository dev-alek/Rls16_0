using ibs.th.gbl.storage.*.
using ibs.th.str.marking.sts.*.
using ibs.th.str.marking.handlers.*.
DEFINE BUFFER t-doc FOR trn-doc.
define input         parameter parparentproc   as   handle                  no-undo.
define input-output  parameter pardoc-rec      as   recid                   no-undo.
define input         parameter pardoc-mode     as   character               no-undo.
define input         parameter parlist-mode    as   character               no-undo.
define input         parameter partype         as   character               no-undo.
define input         parameter parinternal     as   logical                 no-undo.
define input-output  parameter parnext-prev    as   logical                 no-undo.
define input         parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define input         parameter paris-hold      as   logical                 no-undo.
define input-output  parameter line-rec        as   recid                   no-undo.
define input         parameter br-handle       as   handle                  no-undo.
define input         parameter bf-handle       as   handle                  no-undo.
define input         parameter parstat         as   character               no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Обработка РН (заведение, редактирование)":U .
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable EDOParSec       as class     ibs.th.gbl.env.prmtrs.edo .
def    var      Marking     as class     mark no-undo .
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
      p-vss-parameters = substitute('&1|&2':u,parext-doc-type,paris-hold)
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-bar-code-ne no-undo
field nm            as integer
field mark          as character
field b-c           as integer
field scn-qnty-doc  as decimal
field scn-qnty-file as decimal
field mem-qnty      as decimal
field bef-qnty      as decimal
field artic         like ub.goods.artic
field prod-type     like ub.goods.prod-type
field prod-code     like ub.goods.prod-code
field gds-name      like ub.goods.gds-name
field node-name     like ub.gds-prt.node-name
field part-code     like ub.bar-code.part-code
field in-code       like ub.bar-code.in-code
index pi is primary nm
index b-c is unique b-c.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
procedure check-contract-code :
define input  parameter parmode           as   character                     no-undo.
define input  parameter parhost-code      like ub.trn-doc.host-code          no-undo.
define input  parameter parcli-type       like ub.trn-doc.cli-type           no-undo.
define input  parameter parcli-code       like ub.trn-doc.cli-code           no-undo.
define input  parameter parframe-value    as   character                     no-undo.
define input  parameter parmenu-handle    as   handle                        no-undo.
define input  parameter parobj-date       as   date                          no-undo.
define input  parameter partype-contract  as   character                     no-undo .
define output parameter parcontract-code  like ub.contract.contract-code     no-undo.
define buffer bf_contract     for ub.contract.
define buffer bf-oth_contract for ub.contract.
define variable varrid-list as character no-undo.
define variable varrecid    as recid     no-undo.
define variable varlog      as logical   no-undo.
define variable var-args    as char      no-undo.
define variable var-ext-doc-type as char     no-undo.
do on error undo, return error return-value :
var-args = parmode.
parmode = entry(1, parmode).
run cntrcode-get-arg-val(var-args, "doc-type", output var-ext-doc-type).
if partype-contract = "" or partype-contract = ? then
   partype-contract = 'при':U .
assign
  parcontract-code = 0
.
if parmode = "input":u
then do:
  if parframe-value = ""
  then do:
    assign
      parcontract-code = 0
    .
  end.
  else do:
    find first bf_contract no-lock
      where bf_contract.host-code         = parhost-code
        and bf_contract.cli-type          = parcli-type
        and bf_contract.cli-code          = parcli-code
        and bf_contract.contract-prn-code = parframe-value
      no-error.
    if available bf_contract
    then do:
      find first bf-oth_contract no-lock
        where bf-oth_contract.host-code          = parhost-code
          and bf-oth_contract.contract-prn-code  = parframe-value
          and bf-oth_contract.cli-type           = parcli-type
          and bf-oth_contract.cli-code           = parcli-code
          and rowid(bf_contract)                 <> rowid(bf-oth_contract)
        no-error .
      if available bf-oth_contract
      then do:
        message
          "На фирме " parhost-code skip
          "у контрагента" parcli-type parcli-code skip
          "имеются два контракта с номером" parframe-value skip
        view-as alert-box .
      end.
      else do:
        assign
          parcontract-code = bf_contract.contract-code
        .
      end.
    end.
  end.
end.
if parmode <> "input":u
or parcontract-code = 0
then do:
  run str/cont-all.w (input parmenu-handle,
                  input parhost-code,
                  input "b-sel",
                  input if var-ext-doc-type = 'ee':U then 'фирма':U else "firm-curr" ,
                  input parcli-type,
                  input parcli-code,
                  input ?,
                  input ?,
                  input "current":u,
                  input partype-contract,
                  input-output varrid-list ) no-error.
  if error-status:error then do:
    message "Ошибка при вызове справочника договоров." skip
            return-value                skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    return error.
  end.
  assign
    varrecid = integer(entry(1, varrid-list)).
  find first bf_contract where recid(bf_contract) = varrecid no-lock no-error.
  if available bf_contract then do:
    assign
      parcontract-code = bf_contract.contract-code.
  end.
end.
if parcontract-code <> 0
then do:
  if (bf_contract.status_ = 'зкр':U or
      (bf_contract.contract-date-end <> ? and bf_contract.contract-date-end < parobj-date)) then do:
    if lookup(var-ext-doc-type, 'ep,re,rs,ee') = 0
    then do:
        assign
          varlog = no.
        message "Договор с номером " bf_contract.contract-prn-code " закрыт." skip
        view-as alert-box.
        assign
          parcontract-code = 0
        .
    end.
  end.
  if bf_contract.contract-date-beg > parobj-date then do:
    assign
      varlog = no.
    message "Дата открытия договора " bf_contract.contract-date-beg " . Договор с номером " bf_contract.contract-prn-code " еще не открыт." skip
    view-as alert-box.
    assign
      parcontract-code = 0
    .
  end.
  if parcontract-code <> 0
  then do:
    if bf_contract.cli-type <> parcli-type
    or bf_contract.cli-code <> parcli-code
    then do:
       message "По договору " bf_contract.contract-code
               ( if bf_contract.doc-type =  'при':U
                 then " поставщиком является "
                 else " покупателем является " )
               bf_contract.cli-type " " bf_contract.cli-code " ." skip
               "По документу контрагент " parcli-type " " parcli-code " ." skip
       view-as alert-box error.
       assign
         parcontract-code = 0.
    end.
    if parcontract-code <> ? then do:
      if not ( bf_contract.doc-type =  'при':U or bf_contract.doc-type =  'рас':U ) then do:
        message "Контракт имеет недопустимый тип." view-as alert-box.
        assign
          parcontract-code = 0.
      end.
    end.
  end.
end.
end.
end procedure.
procedure cntrcode-get-arg-val:
    def input param p-args as char no-undo.
    def input param p-key as char no-undo.
    def output param p-val as char no-undo.
    def var i as int no-undo.
    def var nums as int no-undo.
    def var key-val as char no-undo.
    nums = num-entries(p-args).
    do i = 1 to nums:
        key-val = entry(i, p-args).
        if key-val begins (p-key + "=") then do:
            p-val = entry(2, key-val, "=").
            return.
        end.
    end.
    p-val = "".
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-upd-attr no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer
  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .
define temp-table tt-upd-attr-fuel no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer
  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_cgrplib_grp no-undo
    field sel           as character
    field full-name     as character
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field d-pcnt        as decimal
    field name          as character
    field level         as integer
    field mark          as character
    index pi is primary unique sort-name
    index fn full-name
    index nc is unique node-code
    index sl sel
    index uc upper-code
.
define temp-table temp_cgrplib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    field d-pcnt      as decimal
    index pi is primary unique sort-name
    index fn full-name
    index lv level
    index it is-terminal
.
define temp-table temp_cfound-result-nodelist no-undo
    field node-code     as recid
    field processed     as logical
    field full-name     as character
    field sort-name     as character
    index pi is primary unique node-code
    index ps processed
.
procedure cli-grplib-get-sort-name :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_upper_cli-grp for ub.cli-grp.
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error.
    if not available buf_cli-grp
    then do:
        undo, return error "cli-grplib-get-sort-name: Не найдена группа клиентов с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while buf_cli-grp.upper-code <> 0
    on error undo, return error "cli-grplib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_cli-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_cli-grp.upper-code
        .
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = v-upper-code
        no-error.
        if not available buf_cli-grp
        then do:
            undo, return error "cli-grplib-get-sort-name: Не найдена группа клиентов с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cli-grplib-get-full-name :
   define input parameter  p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_upper_cli-grp for ub.cli-grp.
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error.
    if not available buf_cli-grp
    then do:
        undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_cli-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_cli-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_cli-grp.upper-code
        .
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = v-upper-code
        no-error.
        if not available buf_cli-grp
        then do:
            undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure cgrplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_cli-grp       for ub.cli-grp.
do
on error undo, return error
:
  find first buf_cli-grp no-lock
      where buf_cli-grp.upper-code = 0
  no-error .
  if not available buf_cli-grp
  then do:
      undo, return error substitute("Не найдена корневая группа клиентов (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_cli-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_cli-grp no-lock where
              buf_cli-grp.node-name = v-entry
          and buf_cli-grp.upper-code = v-upper-code
          no-error.
    if not available buf_cli-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_cli-grp.node-code.
      v-upper-code = buf_cli-grp.node-code.
    end.
  end.
end.
end .
procedure cgrplib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    find first buf_cli-grp no-lock
        where buf_cli-grp.upper-code = 0
    no-error .
    if not available buf_cli-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_cli-grp.node-code
        .
    end.
end.
end procedure.
procedure cgrplib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-not-found     as logical init yes no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run cgrplib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "cgrplib-expand-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_cgrplib_found-grp
    :
        delete temp_cgrplib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            find first buf_cli-grp no-lock
                 where buf_cli-grp.upper-code = v-upper-code
                   and buf_cli-grp.node-name  = entry( v-counter, p-search-name, chr(2) )
            no-error .
            if not available buf_cli-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "cgrplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + (if v-full-name = "" then "" else chr(47) )         + buf_cli-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_cli-grp.node-name
                    v-upper-code = buf_cli-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_cgrplib_found-grp.
                    assign
                        temp_cgrplib_found-grp.full-name = v-full-name + chr(47)
                        temp_cgrplib_found-grp.sort-name = v-sort-name
                        temp_cgrplib_found-grp.node-code = v-upper-code
                        temp_cgrplib_found-grp.level     = v-counter
                    .
                end.
            end.
        end.
        else do:
            for each buf_cli-grp no-lock
               where buf_cli-grp.upper-code = v-upper-code
                 and buf_cli-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    v-not-found = no
                .
                create temp_cgrplib_found-grp.
                assign
                    temp_cgrplib_found-grp.full-name = v-full-name
                                                        + ( if v-full-name = "" then "" else chr(47) )
                                                        + buf_cli-grp.node-name + chr(47)
                    temp_cgrplib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_cli-grp.node-name
                    temp_cgrplib_found-grp.node-code = buf_cli-grp.node-code
                    temp_cgrplib_found-grp.level     = v-level
                .
            end.
            if v-not-found = yes
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_cgrplib_found-grp
                :
                    delete temp_cgrplib_found-grp.
                end.
                return error "cgrplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
        end.
    end.
end.
end procedure.
procedure cgrplib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define variable v-d-pcnt            as decimal       no-undo.
    define buffer buf_cli-grp           for ub.cli-grp.
    create temp_cfound-result-nodelist.
    assign
        temp_cfound-result-nodelist.node-code = p-start-node-code
        temp_cfound-result-nodelist.processed = no
    .
    run cli-grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-full-name
    ).
    run cli-grplib-get-sort-name in this-procedure (
          input p-start-node-code
        , output v-start-sort-name
    ).
    process-nodes:
    do while yes
    :
        find first temp_cfound-result-nodelist
             where temp_cfound-result-nodelist.node-code = p-start-node-code
        .
        assign
            temp_cfound-result-nodelist.processed = yes
        .
        for each buf_cli-grp no-lock
           where buf_cli-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run cgrplib-is-terminal in this-procedure (
                  input buf_cli-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_cgrplib_found-grp.
                assign
                    temp_cgrplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_cli-grp.node-name + chr(47)
                    temp_cgrplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_cli-grp.node-name + chr(2)
                    temp_cgrplib_found-grp.node-code   = buf_cli-grp.node-code
                    temp_cgrplib_found-grp.is-terminal = yes
                .
               run cgrplib-get-pcnt-value in this-procedure ( input temp_cgrplib_found-grp.node-code , output v-d-pcnt) no-error .
               if not error-status:error then do:
                 temp_cgrplib_found-grp.d-pcnt = v-d-pcnt.
               end.
               else do:
                 temp_cgrplib_found-grp.d-pcnt = ?.
               end.
            end.
            else do:
                create temp_cfound-result-nodelist.
                assign
                    temp_cfound-result-nodelist.node-code = buf_cli-grp.node-code
                    temp_cfound-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_cli-grp.node-name + chr(47)
                    temp_cfound-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_cli-grp.node-name + chr(2)
                    temp_cfound-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_cgrplib_found-grp.
                    assign
                        temp_cgrplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_cli-grp.node-name + chr(47)
                        temp_cgrplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_cli-grp.node-name + chr(2)
                        temp_cgrplib_found-grp.node-code   = buf_cli-grp.node-code
                        temp_cgrplib_found-grp.is-terminal = no
                    .
                end.
            end.
        end.
        find first temp_cfound-result-nodelist
             where temp_cfound-result-nodelist.processed = no
        no-error.
        if not available temp_cfound-result-nodelist
        then do:
            leave process-nodes.
        end.
        else do:
            assign
                p-start-node-code = temp_cfound-result-nodelist.node-code
                v-start-full-name = temp_cfound-result-nodelist.full-name
                v-start-sort-name = temp_cfound-result-nodelist.sort-name
            .
        end.
    end.
end.
end procedure.
procedure cgrplib-expand-name :
do
on error undo, return error
:
define input parameter p-start-name as character        no-undo.
define output parameter p-end-name  as character        no-undo.
    define variable v-is-terminal     as logical           no-undo.
    define buffer buf_temp_cgrplib_found-grp     for temp_cgrplib_found-grp.
    run cgrplib-find-grp-by-full-name in this-procedure (
          input p-start-name
        , input no
    ) no-error.
    run cgrplib-get-max-substring in this-procedure (
                input length( p-start-name )
              , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        find first temp_cgrplib_found-grp
            where temp_cgrplib_found-grp.full-name = p-end-name
        no-error.
        if available temp_cgrplib_found-grp
        then do:
            find first buf_temp_cgrplib_found-grp
                where buf_temp_cgrplib_found-grp.full-name begins p-end-name
                and recid( buf_temp_cgrplib_found-grp ) <> recid( temp_cgrplib_found-grp )
            no-error.
            if not available buf_temp_cgrplib_found-grp
            then do:
                run cgrplib-is-terminal in this-procedure (
                    input temp_cgrplib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure cgrplib-get-max-substring :
do
on error undo, return error
:
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.
        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_cgrplib_found-grp no-error.
        if not available temp_cgrplib_found-grp
        then do:
            undo, return error "cgrplib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string = temp_cgrplib_found-grp.full-name
            .
            counter-block:
            do while yes
            on error undo, return error "cgrplib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_cgrplib_found-grp
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_cgrplib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
                    then do:
                        leave counter-block.
                    end.
                end.
                if v-names-counter = 1
                then do:
                    assign
                        p-substring = v-base-string
                    .
                    return.
                end.
            end.
            assign
                p-substring = substring( v-base-string, 1, v-char-counter - 1 )
            .
        end.
end.
end procedure.
procedure cgrplib-is-terminal :
do
on error undo, return error "Ошибка процедуры cgrplib-is-terminal"
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    find first buf_cli-grp no-lock
        where buf_cli-grp.upper-code = p-node-code
    no-error .
    if not available buf_cli-grp
    then do:
        assign
            p-is-terminal = yes
        .
    end.
    else do:
        assign
            p-is-terminal = no
        .
    end.
end.
end procedure.
procedure cgrplib-have-clients :
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-have-clients   as logical      no-undo.
    define buffer buf_clients         for ub.clients.
    find first buf_clients no-lock
         where buf_clients.grp-code = p-node-code
    no-error .
    if available buf_clients
    then do:
        assign
            p-have-clients = yes
        .
    end.
    else do:
        assign
            p-have-clients = no
        .
    end.
end.
end procedure.
procedure cgrplib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    search-grp:
    for each buf_cli-grp no-lock
        where buf_cli-grp.node-code > p-start-code
    :
        if index( buf_cli-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_cli-grp.node-code
                v-found      = yes
            .
            run cli-grplib-get-full-name in this-procedure (
                  input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "cgrplib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
            end.
            leave search-grp.
        end.
    end.
    if v-found = yes
    then do:
    end.
    else do:
        assign
            p-full-name  = ""
            p-found-code = 0
        .
    end.
end.
end procedure.
procedure cgrplib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
define input parameter p-upper-code     as integer              no-undo.
define output parameter p-error-message as character init ""    no-undo.
    define variable v-char-list     as character    no-undo.
    define variable v-char-counter  as integer      no-undo.
    define variable v-full-name     as character    no-undo.
    if p-grp-name = "" then do:
        assign
            p-error-message = "Название группы не может быть пустым.".
        .
    end.
    else do:
        assign
            v-char-list = "47,92,58,63,34,60,62,171,187,183"
        .
        do v-char-counter = 1 to num-entries( v-char-list )
        :
            if index( p-grp-name, chr( integer( entry( v-char-counter, v-char-list ) ) ) ) <> 0
            then do:
                assign
                    p-error-message = 'Название группы не может содержать символы /\:*?"<>|«»·'
                .
                return.
            end.
        end.
        run cli-grplib-get-full-name in this-procedure (
              input p-upper-code
            , output v-full-name
        ) no-error .
        if error-status :error
        then do:
            undo, return error "cgrplib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
        end.
        if length( v-full-name ) + 1 + length( p-grp-name ) > 120
        then do:
            assign
                p-error-message = 'Полное название группы не может содержать более 120 символов.'
            .
        end.
    end.
end.
end procedure.
procedure cgrplib-get-lvl-num :
define input parameter p-node-code  as integer      no-undo.
define output parameter p-lvl-num   as integer      no-undo.
    define variable v-full-name    as character    no-undo.
do
on error undo, return error
:
    run cli-grplib-get-full-name in this-procedure (
          input p-node-code
        , output v-full-name
    ).
    assign
        p-lvl-num = num-entries( v-full-name, chr(47) ) - 1
    .
    if p-lvl-num = -1
    then do:
        assign
            p-lvl-num = 0
        .
    end.
end.
end procedure.
PROCEDURE cgrplib-get-pcnt-value :
DEFINE INPUT PARAMETER p-node-code AS INTEGER NO-UNDO.
DEFINE output PARAMETER p-pcnt-value AS DECIMAL NO-UNDO.
define buffer buf_dis-grp-rule for ub.dis-grp-rule.
define buffer buf_dis-rule for ub.dis-rule.
find first buf_dis-grp-rule no-lock where
          buf_dis-grp-rule.classif-type = 'cli-grp':U
      and buf_dis-grp-rule.node-code = p-node-code
      and buf_dis-grp-rule.host-code = 0
      and buf_dis-grp-rule.obj-type = '':U
      and buf_dis-grp-rule.obj-code = 0
      and buf_dis-grp-rule.pos-type = '-':U
      and buf_dis-grp-rule.discnt-role = 'cli-grp-pcnt':U no-error.
if available buf_dis-grp-rule then do:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = buf_dis-grp-rule.rule-num no-error.
  if available buf_dis-rule then do:
    assign
    p-pcnt-value        = buf_dis-rule.discnt-value.
    .
  end.
end.
END PROCEDURE.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table tt-gds-list no-undo like ub.goods
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    temp-table tt-gds-list-hist no-undo
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def  new shared  temp-table bb-list no-undo like ub.goods
  field b-code as integer
  field b-str  as character
  field f-name like ub.gds-prt.f-name
  field bc-cli-base-rate like ub.bar-code.cli-base-rate
  field bc-cr-db-num     like ub.bar-code.cr-db-num
  field in-code       like ub.bar-code.in-code
  field node-code     like ub.bar-code.node-code
  field part-code     like ub.bar-code.part-code
  field stts_         like ub.bar-code.stts_
  field bc-unit-cli      like ub.bar-code.unit-cli
  field bc-on-type    like ub.prod-bc.bc-on-type
  field bc-on         like ub.prod-bc.bc-on
  field pbc-cr-db-num     like ub.prod-bc.cr-db-num
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field loc-ean as logical
  index pi  is primary unique b-code b-str
  index art artic prod-type prod-code
  index code gds-code
  index oi order-num
  index ibc-on-type bc-on-type
  index iprt
  gds-code
  node-code
  part-code
  in-code
  unit-cli
  b-str
  index iprt2
  gds-code
  node-code
  unit-cli
  part-code
  in-code
  b-str
  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   new shared   temp-table bb-list-hist no-undo
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fact-bc:
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define variable g-log       as logical              no-undo.
define variable varnum      as integer              no-undo.
define variable varbar-code like ub.bar-code.b-code no-undo.
define variable varrecid    as   recid              no-undo.
define variable is-petrolium as logical no-undo.
define variable is-pieces    as logical no-undo.
define variable v-part-code  as character no-undo.
define variable v-alcohol-prod as logical no-undo .
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_doc-line for ub.doc-line.
define buffer bf_gds-dtl  for ub.gds-dtl.
define buffer bf_goods    for ub.goods.
define buffer bf_gds-prt  for ub.gds-prt.
define buffer bf_units    for ub.units.
define buffer bf_parts    for ub.parts.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code.
for each tt-bar-code-ne:
  delete tt-bar-code-ne.
end.
assign
  g-log = yes.
if bf_trn-doc.doc-qnty <> bf_trn-doc.fact-qnty and
   bf_trn-doc.fact-qnty <> 0 then do:
  message "Начать заполнять фактическое количество с нуля?" view-as alert-box question
  buttons yes-no update g-log.
end.
for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code no-lock by bf_doc-line.line-num :
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_trn-doc.doc-code     and
                            bf_gds-dtl.artic     = bf_goods.artic     and
                            bf_gds-dtl.prod-type = bf_goods.prod-type and
                            bf_gds-dtl.prod-code = bf_goods.prod-code
                            no-lock :
    find first bf_gds-prt where bf_gds-prt.node-code = bf_gds-dtl.prt-code no-lock.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-prt.node-code
  ,output varbar-code
  )  .
    assign
      varnum = varnum + 1.
    create tt-bar-code-ne.
    assign
     tt-bar-code-ne.nm             = varnum
     tt-bar-code-ne.mark           = (if bf_gds-dtl.fact-qnty < bf_gds-dtl.doc-qnty then "<" else "")
     tt-bar-code-ne.b-c            = varbar-code
     tt-bar-code-ne.scn-qnty-doc   = bf_gds-dtl.doc-qnty
     tt-bar-code-ne.scn-qnty-file  = (if g-log = yes then 0 else bf_gds-dtl.fact-qnty)
     tt-bar-code-ne.mem-qnty       = tt-bar-code-ne.scn-qnty-file
     tt-bar-code-ne.bef-qnty       = bf_gds-dtl.fact-qnty
     tt-bar-code-ne.artic          = bf_goods.artic
     tt-bar-code-ne.prod-type      = bf_goods.prod-type
     tt-bar-code-ne.prod-code      = bf_goods.prod-code
     tt-bar-code-ne.gds-name       = bf_goods.gds-name
     tt-bar-code-ne.node-name      = (if bf_gds-prt.node-name = '_Пустая шкала':U then "--------------------" else bf_gds-prt.node-name)
     tt-bar-code-ne.part-code      = ''
     tt-bar-code-ne.in-code        = ''.
  end.
end.
run str/scr-neb.w (input parparentproc, input-output table tt-bar-code-ne, input "in-doc", input yes, input v-cntxt-obj-type, input v-cntxt-obj-code).
for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code no-lock by bf_doc-line.line-num :
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_trn-doc.doc-code     and
                            bf_gds-dtl.artic     = bf_goods.artic     and
                            bf_gds-dtl.prod-type = bf_goods.prod-type and
                            bf_gds-dtl.prod-code = bf_goods.prod-code
                            no-lock on error undo, return error return-value :
    find first bf_gds-prt where bf_gds-prt.node-code = bf_gds-dtl.prt-code no-lock.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-prt.node-code
  ,output varbar-code
  )  .
    find first tt-bar-code-ne where tt-bar-code-ne.b-c = varbar-code.
    if tt-bar-code-ne.scn-qnty-file <> bf_gds-dtl.fact-qnty then do :
      find bf_units where bf_units.unit-name = bf_goods.unit-base no-lock.
      if lookup('сер':U, bf_units.type) > 0 then do:
         message "В серийном товаре нельзя редактировать количество. Пропускаем.".
         next.
      end.
      if tt-bar-code-ne.scn-qnty-file > bf_gds-dtl.doc-qnty then do:
        message "По признаку " bf_gds-dtl.artic " "
                bf_gds-dtl.prod-type " "
                bf_gds-dtl.prod-code " "
                bf_gds-prt.f-name " "
                "количество факт уже больше чем по документу. Устанавливаем по документу."
        view-as alert-box.
        assign
          tt-bar-code-ne.scn-qnty-file = bf_gds-dtl.doc-qnty.
      end.
      assign varrecid = recid(bf_doc-line).
      if bf_trn-doc.doc-type = 'при':U and
         bf_trn-doc.internal = no        then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf_goods.artic
  ,  input bf_goods.prod-type
  ,  input bf_goods.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
        if is-petrolium and not is-pieces then do:
          MESSAGE "В жидком топливе нельзя редактировать фактическое количество" view-as alert-box.
          next.
        end.
        assign
          v-part-code = ?
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  bf_goods.gds-code
  ,input  'alcohol-prod=request':u
  ,output v-alcohol-prod
  )  .
        if v-alcohol-prod then do:
          find first bf_parts no-lock
            where bf_parts.obj-type  = bf_doc-line.obj-type  and
                  bf_parts.obj-code  = bf_doc-line.obj-code  and
                  bf_parts.prod-type = bf_doc-line.prod-type and
                  bf_parts.prod-code = bf_doc-line.prod-code and
                  bf_parts.artic     = bf_doc-line.artic     and
                  bf_parts.out-code  = bf_doc-line.doc-code
            no-error.
          if available bf_parts then do:
            assign
              v-part-code = bf_parts.part-code
            .
          end.
        end.
        run str/cor-line.p
          (input parparentproc
          ,input-output varrecid
          ,input bf_doc-line.doc-code
          ,input bf_doc-line.prod-type
          ,input bf_doc-line.prod-code
          ,input bf_doc-line.artic
          ,input bf_doc-line.cli-qnty
          ,input bf_doc-line.cli-base-rate
          ,input tt-bar-code-ne.scn-qnty-file
          ,input bf_doc-line.doc-qnty
          ,input bf_doc-line.unit-cli
          ,input bf_doc-line.vat-pc
          ,input bf_doc-line.slt-pc
          ,input bf_doc-line.price-cli
          ,input bf_doc-line.price-base
          ,input bf_doc-line.price-rubl
          ,input bf_doc-line.new-price-sale
          ,input bf_doc-line.num-place
          ,input bf_doc-line.wt-brutto
          ,input bf_doc-line.road-tax
          ,input bf_doc-line.excise
          ,input bf_doc-line.doc-density
          ,input bf_doc-line.temperature
          ,input ?
          ,input ?
          ,input ?
          ,input bf_doc-line.fact-density
          ,input ?
          ,input no
          ,input v-part-code
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ) no-error.
        if error-status :error then do:
          return error return-value.
        end.
      end.
      else do:
        run str/out-add.p (parparentproc,
                       recid(bf_trn-doc),
                       recid(bf_doc-line),
                       recid(bf_gds-dtl),
                       recid(bf_goods),
                       "ch-fact-qnty",
                       tt-bar-code-ne.scn-qnty-file) no-error.
        if error-status :error then do:
          return error return-value.
        end.
      end.
    end.
  end.
end.
end.
end procedure.
procedure checkTypeByBarCode:
  define input parameter iBarCode    as integer no-undo.
  define input parameter iExtDocType as character no-undo.
  define variable vValue as character no-undo.
  define variable vType  as character no-undo.
  define buffer buf_bar-code for ub.bar-code.
  define buffer buf_goods    for ub.goods.
  if iExtDocType = ? or
     iExtDocType = 'ee':U or
     iExtDocType = 'ie':U or
     iExtDocType = 'iv':U or
     iExtDocType = 'ev':U or
     iExtDocType = 'we':U then
      find buf_bar-code where buf_bar-code.b-code = iBarCode no-lock.
      find buf_goods where buf_goods.gds-code = buf_bar-code.gds-code no-lock.
      RUN gds-attr-value (
         INPUT buf_goods.gds-code,
         INPUT 'mark-type':U,
         OUTPUT vValue,
         OUTPUT vType
      ).
      if vValue <> "" then
      do:
        message
          substitute("Товар: &1 &2", b-c, buf_goods.gds-name) skip
          "нельзя добавлять в ручном режиме, так как он подлежит маркировке."
          view-as alert-box error buttons ok.
        return error.
      end.
end procedure.
  define new global shared variable g#lib-rvs as handle no-undo.
define variable vss-include-info21 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    PROCEDURE cr-rvs-doc :
      define input  parameter parparentproc as   handle              no-undo .
      define input  parameter p-doc-code    like ub.trn-doc.doc-code no-undo .
      tr:
      do transaction
      on error  undo, return error substitute( "&1 (cr-rvs-doc). &2&3&4", vss-include-info21, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      on stop   undo, return error substitute( "&1 (cr-rvs-doc). stop", vss-include-info21 )
      on endkey undo, return error substitute( "&1 (cr-rvs-doc). endkey", vss-include-info21 )
      :
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        define buffer buf_trn-doc    for ub.trn-doc .
        define buffer buf_doc-line   for ub.doc-line .
        define buffer buf_goods      for ub.goods .
        define buffer buf_rvs-doc    for ub.rvs-doc .
        define buffer cur_shift-obj  for ub.shift-obj.
        define buffer prev_shift-obj for ub.shift-obj.
        define buffer prev_rvs-doc   for ub.rvs-doc.
        define buffer prev_icnt-doc  for ub.icnt-doc.
        define buffer buf_doc-pl     for ub.doc-pl.
        define variable is-petrolium       as logical   no-undo.
        define variable is-pieces          as logical   no-undo.
        define variable v-ptrl-without-rvs as character no-undo .
        define variable v-attr-type        as character no-undo .
        define variable v-ptrl-avail       as logical   no-undo .
        define variable v-doc-pl-avail     as logical   no-undo .
        define variable v-today            as date      no-undo.
        define variable varlog             as logical   no-undo .
        find first buf_trn-doc
          where buf_trn-doc.doc-code = p-doc-code
          .
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-on-doc_cr-revision':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    ) no-error .
end.
        if varlog <> yes then do:
          return error return-value .
        end.
        find first buf_rvs-doc no-lock
          where buf_rvs-doc.out-code = buf_trn-doc.doc-code
          no-error.
        if available buf_rvs-doc then do:
          message "Прототипы документов сверки уже созданы." skip
                  "Можно задавать кол-ва по приборам."       skip
          view-as alert-box error.
          return error.
        end.
        find first cur_shift-obj
          where cur_shift-obj.obj-type = buf_trn-doc.obj-type
            and cur_shift-obj.obj-code = buf_trn-doc.obj-code
            and cur_shift-obj.status_  = 'тек':U
            use-index pi no-lock no-error .
        if not available cur_shift-obj then do:
          message "Нет открытой смены на объекте " buf_trn-doc.obj-type
                                                  buf_trn-doc.obj-code
          view-as alert-box error.
          return error.
        end.
        find last prev_shift-obj no-lock
          where prev_shift-obj.obj-type = cur_shift-obj.obj-type
            and prev_shift-obj.obj-code = cur_shift-obj.obj-code
            and prev_shift-obj.status_  = 'зкр':U
            and ( prev_shift-obj.shift-date < cur_shift-obj.shift-date
                  or prev_shift-obj.shift-date = cur_shift-obj.shift-date
                    and prev_shift-obj.shift-num  < cur_shift-obj.shift-num
                )
          use-index stts
          no-error.
        if available prev_shift-obj then do:
          find first prev_rvs-doc no-lock
            where prev_rvs-doc.obj-type   = prev_shift-obj.obj-type
              and prev_rvs-doc.obj-code   = prev_shift-obj.obj-code
              and prev_rvs-doc.shift-date = prev_shift-obj.shift-date
              and prev_rvs-doc.shift-num  = prev_shift-obj.shift-num
              and prev_rvs-doc.status_    = 'факт':U
              and prev_rvs-doc.rvs-type   = 'смена':U
            no-error.
          if not available prev_rvs-doc then do:
              assign varlog = no.
              message "Объект " buf_trn-doc.obj-type " " buf_trn-doc.obj-code " ." skip
                      "Текущая смена " cur_shift-obj.shift-date " " cur_shift-obj.shift-num " ." skip
                      "Прошлая смена " prev_shift-obj.shift-date " " prev_shift-obj.shift-num " ." skip
                      "Нет сверки типа " 'смена':U " за прошлую смену." skip
                      "Торговли топливом не было. Продолжить?"
              view-as alert-box question buttons yes-no update varlog .
              if varlog <> yes then return error.
          end.
        end.
        find last prev_icnt-doc no-lock
          where prev_icnt-doc.obj-type = buf_trn-doc.obj-type
            and prev_icnt-doc.obj-code = buf_trn-doc.obj-code
            and prev_icnt-doc.doc-type = 'инв-сч-трк':U
            and prev_icnt-doc.status_  = 'факт':U
          use-index fact-order
          no-error.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-today
  )  .
        create buf_rvs-doc.
        run doc-code in this-procedure
          ( input "main":U
          ,input buf_trn-doc.obj-type
          ,input buf_trn-doc.obj-code
          ,input ?
          ,output buf_rvs-doc.rvs-code
          ) no-error.
        if error-status :error then do:
          message
            "Ошибка при генерации номера документа."
            view-as alert-box error.
          return error.
        end.
        assign
          buf_rvs-doc.host-code = buf_trn-doc.host-code
          buf_rvs-doc.obj-type  = buf_trn-doc.obj-type
          buf_rvs-doc.obj-code  = buf_trn-doc.obj-code
          buf_rvs-doc.status_   = 'новый':U
          buf_rvs-doc.rvs-type  = 'перед_док':U
          buf_rvs-doc.out-code  = buf_trn-doc.doc-code
          buf_rvs-doc.creid     = v-cntxt-userid
          buf_rvs-doc.PS        = "@"
          buf_rvs-doc.is-full   = no
          buf_rvs-doc.doc-date  = v-today
        .
        run gbl/factdate.p
          ( input        buf_rvs-doc.obj-type
          ,input        buf_rvs-doc.obj-code
          ,input-output buf_rvs-doc.fact-date
          ,input-output buf_rvs-doc.fact-time
          ,input-output buf_rvs-doc.shift-date
          ,input-output buf_rvs-doc.shift-num
          ,input-output buf_rvs-doc.shift-name
          ,input        yes
          ) no-error.
        if error-status :error then do:
          message
            "Ошибка при установке даты в документе " 'перед_док':U skip
            view-as alert-box error.
          undo tr, return error.
        end.
        create buf_rvs-doc.
        run doc-code in this-procedure
          ( input "main":U
            ,input buf_trn-doc.obj-type
            ,input buf_trn-doc.obj-code
            ,input ?
            ,output buf_rvs-doc.rvs-code
          ) no-error.
        if error-status :error then do:
          message
            "Ошибка при генерации номера документа."
            view-as alert-box error.
          return error.
        end.
        assign
          buf_rvs-doc.host-code = buf_trn-doc.host-code
          buf_rvs-doc.obj-type  = buf_trn-doc.obj-type
          buf_rvs-doc.obj-code  = buf_trn-doc.obj-code
          buf_rvs-doc.status_   = 'новый':U
          buf_rvs-doc.rvs-type  = 'после_док':U
          buf_rvs-doc.out-code  = buf_trn-doc.doc-code
          buf_rvs-doc.creid     = v-cntxt-userid
          buf_rvs-doc.PS        = "@"
          buf_rvs-doc.is-full   = no
          buf_rvs-doc.doc-date  = v-today
        .
        run gbl/factdate.p
          ( input        buf_rvs-doc.obj-type
            ,input        buf_rvs-doc.obj-code
            ,input-output buf_rvs-doc.fact-date
            ,input-output buf_rvs-doc.fact-time
            ,input-output buf_rvs-doc.shift-date
            ,input-output buf_rvs-doc.shift-num
            ,input-output buf_rvs-doc.shift-name
            ,input        yes
          ) no-error.
        if error-status :error then do:
          message
            "Ошибка при установке даты в документе " 'после_док':U skip
            view-as alert-box error.
          undo tr, return error.
        end.
        assign
          v-ptrl-avail = false
        .
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
        ,first buf_goods no-lock
          where buf_goods.artic     = buf_doc-line.artic
            and buf_goods.prod-type = buf_doc-line.prod-type
            and buf_goods.prod-code = buf_doc-line.prod-code
        on error undo tr, return error return-value
        :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_doc-line.artic
  ,  input buf_doc-line.prod-type
  ,  input buf_doc-line.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
          if error-status :error then do:
              message "Ошибка при вызове программы lib-trn_is-petrl." view-as alert-box .
              undo tr, return error .
          end.
          run gds-attr-value in this-procedure
            ( input  buf_goods.gds-code
             ,input  'ptrl-without-rvs':U
             ,output v-ptrl-without-rvs
             ,output v-attr-type
            ) .
          if is-petrolium = true
            and is-pieces = false
            and lookup(v-ptrl-without-rvs, 'true,yes':u) = 0
          then do:
            assign
              v-ptrl-avail   = true
              v-doc-pl-avail = false
            .
            for each buf_doc-pl no-lock
              where buf_doc-pl.obj-type = buf_doc-line.obj-type
                and buf_doc-pl.obj-code = buf_doc-line.obj-code
                and buf_doc-pl.out-code = buf_doc-line.doc-code
                and buf_doc-pl.gds-code = buf_goods.gds-code
            on error undo tr, return error return-value
            :
              for each buf_rvs-doc
                where buf_rvs-doc.out-code = buf_trn-doc.doc-code
              on error undo tr, return error return-value
              :
                assign
                  v-doc-pl-avail = true
                .
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_crrvslin in g#lib-rvs ( input buf_rvs-doc.obj-type ,
                      input buf_rvs-doc.obj-code ,
                      input buf_rvs-doc.rvs-code ,
                      input buf_rvs-doc.rvs-type ,
                      input buf_doc-pl.pl-code ,
                      input buf_doc-pl.gds-code ,
                      input ( if available prev_rvs-doc then prev_rvs-doc.rvs-code else ? ) ,
                      input buf_rvs-doc.shift-date ,
                      input buf_rvs-doc.shift-num )  .
              end.
            end.
            if v-doc-pl-avail = false then do:
              message
                substitute( 'В документе "&1" товар "&2" не распределен по местам хранения.', buf_doc-line.doc-code, buf_goods.gds-code ) skip
                "Сверки не созданны!"
                view-as alert-box information.
              undo tr, leave tr.
            end.
          end.
        end.
        if v-ptrl-avail <> true then do:
          message
            "В документе нет ни одного топливного товара требующего создание сверки."  skip
            "Сверки не созданны!"
            view-as alert-box information.
          undo tr, leave tr.
        end.
        find first buf_rvs-doc
          where buf_rvs-doc.out-code = buf_trn-doc.doc-code
            and buf_rvs-doc.rvs-type = 'перед_док':U
        .
        run str/rvs-stat.p
          ( input parparentproc
          ,input recid(buf_rvs-doc)
          ,input "close":U
          ) no-error.
        if error-status :error then do:
          run waitfram-hide in this-procedure .
          message
            vss-workfile vss-revision vss-description skip
            substitute( 'Ошибка при закрытии документа сверки "&1" номер &2', 'перед_док':U, buf_rvs-doc.rvs-code ) skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo tr, return error.
        end.
        run str/rvs-stat.p
          ( input parparentproc
          ,input recid(buf_rvs-doc)
          ,input "froze":U
          ) no-error.
        if error-status :error then do:
          run waitfram-hide in this-procedure .
          message
            vss-workfile vss-revision vss-description skip
            substitute( 'Ошибка при изменении статуса документа сверки "&1" номер &2', 'перед_док':U, buf_rvs-doc.rvs-code ) skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo tr, return error.
        end.
        find first buf_rvs-doc
          where buf_rvs-doc.out-code = buf_trn-doc.doc-code
            and buf_rvs-doc.rvs-type = 'после_док':U
        .
        run str/rvs-stat.p
          ( input parparentproc
            ,input recid(buf_rvs-doc)
            ,input "close":U
          ) no-error.
        if error-status :error then do:
          run waitfram-hide in this-procedure .
          message
            vss-workfile vss-revision vss-description skip
            substitute( 'Ошибка при закрытии документа сверки "&1" номер &2', 'после_док':U, buf_rvs-doc.rvs-code ) skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo tr, return error.
        end.
        run str/rvs-stat.p
          ( input parparentproc
          ,input recid(buf_rvs-doc)
          ,input "froze":U
          ) no-error.
        if error-status :error then do:
          run waitfram-hide in this-procedure .
          message
            vss-workfile vss-revision vss-description skip
            substitute( 'Ошибка при изменении статуса документа сверки "&1" номер &2', 'после_док':U, buf_rvs-doc.rvs-code ) skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo tr, return error.
        end.
      end.
      return .
    END PROCEDURE.
    PROCEDURE del-rvs-doc :
      define input  parameter parparentproc as   handle              no-undo .
      define input  parameter p-doc-code    like ub.trn-doc.doc-code no-undo .
      tr:
      do transaction
      on error   undo tr, return error
      on end-key undo tr, return error
      on stop    undo tr, return error
      :
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        define buffer buf_trn-doc for ub.trn-doc .
        define buffer bef-rvs-doc for ub.rvs-doc.
        define buffer aft-rvs-doc for ub.rvs-doc.
        define variable varlog           as logical   no-undo .
        find first buf_trn-doc
          where buf_trn-doc.doc-code = p-doc-code
          .
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-on-doc_deletion':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    ) no-error .
end.
        if varlog <> yes then do:
          return error return-value .
        end.
        assign
          varlog = no
          .
        message
          "Вы хотите удалить документы сверки по приходу?"
          view-as alert-box question buttons yes-no update varlog.
        if varlog <> yes then do:
          return .
        end.
        run waitfram-show in this-procedure (input "Удаляем документы сверки по приходной накладной").
        find first bef-rvs-doc
          where bef-rvs-doc.out-code = buf_trn-doc.doc-code
            and bef-rvs-doc.rvs-type = 'перед_док':U
          no-error.
        if available bef-rvs-doc then do:
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(bef-rvs-doc)
            ,input "unfroze":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при изменении статуса документа сверки "&1" номер &2', 'перед_док':U, bef-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(bef-rvs-doc)
            ,input "open":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при открытии документа сверки "&1" номер &2', 'перед_док':U, bef-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          release bef-rvs-doc no-error .
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при открытии документа сверки "&1" номер &2', 'перед_док':U, bef-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          find first bef-rvs-doc
            where bef-rvs-doc.out-code = buf_trn-doc.doc-code
              and bef-rvs-doc.rvs-type = 'перед_док':U
            no-error.
          delete bef-rvs-doc no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при удалении документа сверки "&1"', 'перед_док':U ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
        end.
        find first aft-rvs-doc
          where aft-rvs-doc.out-code = buf_trn-doc.doc-code
            and aft-rvs-doc.rvs-type = 'после_док':U
          no-error.
        if available aft-rvs-doc then do:
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(aft-rvs-doc)
            ,input "unfroze":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при изменении статуса документа сверки "&1" номер &2', 'после_док':U, aft-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(aft-rvs-doc)
            ,input "open":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при открытии документа сверки "&1" номер &2', 'после_док':U, aft-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          release aft-rvs-doc no-error .
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при открытии документа сверки "&1" номер &2', 'после_док':U, aft-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          find first aft-rvs-doc
            where aft-rvs-doc.out-code = buf_trn-doc.doc-code
              and aft-rvs-doc.rvs-type = 'после_док':U
            no-error.
          delete aft-rvs-doc no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при удалении документа сверки "&1"', 'после_док':U ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
        end.
      end.
      run waitfram-hide in this-procedure .
      return .
    END PROCEDURE.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-S_CONTRACT               AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-S_CODE_LAST_MASTER_NUM   AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-DELIM_CHR_3              AS CHARACTER NO-UNDO INITIAL "".
ASSIGN
   v-S_CONTRACT                = "Contract":U
   v-S_CODE_LAST_MASTER_NUM    = "LastMasterNum":U
   v-DELIM_CHR_3               = ","
   .
DEFINE VARIABLE i-gl-Host-Code      AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Contract-Code  AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Extent3        AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
FUNCTION Can-Find-Spec RETURN LOGICAL (
   INPUT iHost-Code    AS INTEGER,
   INPUT iContract-Num AS INTEGER,
   INPUT iGds-Code     AS INTEGER ):
   DEFINE BUFFER buf_Spec FOR ub.Contract-Specif.
   DEFINE VARIABLE iTmp-Host-Code     AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Contract-Num  AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Extent3       AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
   DEFINE VARIABLE lRet               AS LOGICAL NO-UNDO INITIAL FALSE.
   RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
       INPUT  iHost-Code,
       INPUT  iContract-Num,
       OUTPUT iTmp-Extent3
       ).
   IF iTmp-Extent3[1] = 2 THEN DO:
      ASSIGN
         iTmp-Host-Code      = iTmp-Extent3[2]
         iTmp-Contract-Num   = iTmp-Extent3[3]
         .
   END. ELSE DO:
      ASSIGN
         iTmp-Host-Code      = iHost-Code
         iTmp-Contract-Num   = iContract-Num
         .
   END.
   IF iGds-Code = ? THEN DO:
      ASSIGN
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                        ).
   END. ELSE DO:
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                           AND buf_Spec.Gds-Code      = iGds-Code
                         ).
   END.
   RETURN (lRet).
END FUNCTION.
PROCEDURE MS-Contract-EXTENT-3:
   DEFINE INPUT  PARAMETER i-Host-Code     AS INTEGER NO-UNDO.
   DEFINE INPUT  PARAMETER i-Contract-Code AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER i-Ret           AS INTEGER NO-UNDO EXTENT 3 INITIAL 0.
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE BUFFER buf_Cont-2      FOR ub.Contract.
   FIND FIRST buf_Cont-2 WHERE
              buf_Cont-2.Host-Code      = i-Host-Code
          AND buf_Cont-2.Contract-Code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Cont-2 THEN DO:
      RETURN.
   END.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                            STRING(i-Contract-code)
        AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          i-Ret[1] = 1
          i-Ret[2] = buf_Cont.Host-code
          i-Ret[3] = buf_Cont.Contract-code
          .
       LEAVE.
   END.
   IF i-Ret[1] <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                               STRING(i-Contract-code)
           AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             i-Ret[1] = 2
             i-Ret[2] = buf_Cont.Host-code
             i-Ret[3] = buf_Cont.Contract-code
             .
          LEAVE.
      END.
   END.
   RETURN.
END PROCEDURE.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-gl-UVEDOMLENIE as CHARACTER NO-UNDO INITIAL "Uvedomlenie":U.
FUNCTION Get-Contract-Attr RETURN CHARACTER(
         INPUT iHost-Code AS INTEGER,
         INPUT iContract-Code  AS INTEGER,
         INPUT cAttr-code      AS CHARACTER):
   DEFINE BUFFER buf_Contract-Attr FOR ub.Contract-Attr.
   FIND FIRST buf_Contract-Attr WHERE
              buf_Contract-Attr.Host-code     = iHost-Code
          AND buf_Contract-Attr.Contract-code = iContract-Code
          AND buf_Contract-Attr.Attr-code     = cAttr-code
        NO-LOCK NO-ERROR.
   RETURN (IF AVAILABLE buf_Contract-Attr THEN buf_Contract-Attr.Attr-value ELSE ?).
END FUNCTION.
PROCEDURE Modify-Contract-Attr:
   DEFINE INPUT  PARAMETER iHost-Code      AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER iContract-Code  AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-code      AS CHARACTER NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-value     AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError          AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Contract-Attr FOR  ub.Contract-Attr.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции:":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FIND FIRST buf_Contract-Attr WHERE
                 buf_Contract-Attr.Host-Code      = iHost-Code
             AND buf_Contract-Attr.Contract-Code  = iContract-Code
             AND buf_Contract-Attr.Attr-code      = cAttr-code
           NO-LOCK NO-ERROR.
      IF NOT AVAILABLE buf_Contract-Attr THEN DO:
         CREATE buf_Contract-Attr NO-ERROR.
         IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END. ELSE DO:
         FIND CURRENT buf_Contract-Attr EXCLUSIVE-LOCK NO-ERROR.
         IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
      ASSIGN
         buf_Contract-Attr.Host-Code      = iHost-Code
         buf_Contract-Attr.Contract-Code  = iContract-Code
         buf_Contract-Attr.Attr-code      = cAttr-code
         buf_Contract-Attr.Attr-value     = cAttr-value
         NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      RELEASE buf_Contract-Attr NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Create-Contract-Attr:
   DEFINE INPUT  PARAMETER iHost-Code      AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER iContract-Code  AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-code      AS CHARACTER NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-value     AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError          AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Contract-Attr FOR  ub.Contract-Attr.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции:":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      CREATE buf_Contract-Attr NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      ASSIGN
         buf_Contract-Attr.Host-Code      = iHost-Code
         buf_Contract-Attr.Contract-Code  = iContract-Code
         buf_Contract-Attr.Attr-code      = cAttr-code
         buf_Contract-Attr.Attr-value     = cAttr-value
         NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      RELEASE buf_Contract-Attr NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
FUNCTION Is-MS-Contract RETURN LOGICAL(BUFFER buf_Master FOR ub.Contract, BUFFER buf_Slave  FOR ub.Contract) FORWARD.
FUNCTION Is-Master-Slave-Contract RETURN CHARACTER( BUFFER buf_Contract FOR ub.Contract) FORWARD.
FUNCTION Is-MS-Contract-Int RETURN INTEGER (BUFFER buf_Contract FOR ub.Contract) FORWARD.
PROCEDURE Delete-Contract-Specif:
   DEFINE PARAMETER BUFFER buf_Contract FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Specif      FOR ub.Contract-Specif.
   DEFINE BUFFER buf_Specif-Attr FOR ub.Contract-Specif-Attr.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FOR EACH buf_Specif-Attr WHERE
               buf_Specif-Attr.Host-code     = buf_Contract.Host-code
           AND buf_Specif-Attr.Contract-Num  = buf_Contract.Contract-code
          EXCLUSIVE-LOCK:
          DELETE buf_Specif-Attr NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
      FOR EACH buf_Specif WHERE
               buf_Specif.Host-code     = buf_Contract.Host-code
           AND buf_Specif.Contract-Num  = buf_Contract.Contract-code
          EXCLUSIVE-LOCK:
          DELETE buf_Specif NO-ERROR.
         IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Modify-Slave-Contract:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE BUFFER buf_Slave FOR ub.Contract.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FOR EACH buf_Ext-Classif WHERE
               buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
           AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
          NO-LOCK,
          FIRST buf_Slave WHERE
                buf_Slave.Host-Code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
            AND buf_Slave.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
          EXCLUSIVE-LOCK:
          BUFFER-COPY
            buf_Master
          EXCEPT
            Host-code                               Contract-code                           Own-name                                an-uchet-code-out                       cel-nazn-code-out                       cor-acc-out                             cor-acc1-out                            an-uchet-code-in                        cel-nazn-code-in                        cor-acc-in                              cor-acc1-in                             an-uchet-code-out-cash                  cel-nazn-code-out-cash                  cor-acc-out-cash                        cor-acc1-out-cash                       an-uchet-code-in-cash                   cel-nazn-code-in-cash                   cor-acc-in-cash                         cor-acc1-in-cash                        an-uchet-code-out-payoff                cel-nazn-code-out-payoff                cor-acc-out-payoff                      cor-acc1-out-payoff                     an-uchet-code-in-payoff                 cel-nazn-code-in-payoff                 cor-acc-in-payoff                       cor-acc1-in-payoff                      transport-cli-type                      transport-cli-code                      transport-host                          transport-contract                      transport-uslov                         transport-value                         own-code-schet-start                    own-sign-post                           own-sign                                contract-city                           fin-VAT-pc                              srok-opl                                gen-factur-srok                         own-addres                              own-inn                                 own-kpp
          TO buf_Slave
          NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
          RELEASE buf_Slave NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Change-Stat-Slave-Contract:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE INPUT PARAMETER cStatus  AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE BUFFER buf_Slave FOR ub.Contract.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FOR EACH buf_Ext-Classif WHERE
               buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
           AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
          NO-LOCK,
          FIRST buf_Slave WHERE
                buf_Slave.Host-Code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
            AND buf_Slave.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
          EXCLUSIVE-LOCK:
          ASSIGN
             buf_Slave.Status_ = cStatus
             NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
          RELEASE buf_Slave NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Delete-Ref-Master-Slave:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE PARAMETER BUFFER buf_Slave  FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   IF NOT Is-MS-Contract(BUFFER buf_Master, BUFFER buf_Slave) THEN DO:
      cError = PROGRAM-NAME(1) + ":" + "Между договорами нет связи Master->Slave".
      RETURN.
   END.
   Tran:
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
         AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
         AND buf_Ext-Classif.CharKey_Two  = STRING(buf_Slave.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Slave.Contract-code)
         AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
       EXCLUSIVE-LOCK
       TRANSACTION
       ON ENDKEY UNDO Tran, RETRY Tran
       ON ERROR  UNDO Tran, RETRY Tran
       ON QUIT   UNDO Tran, RETRY Tran
       ON STOP   UNDO Tran, RETRY Tran:
       IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
       DELETE buf_Ext-Classif NO-ERROR.
       IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Create-Ref-Master-Slave:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE PARAMETER BUFFER buf_Slave  FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE VARIABLE cKeyRec AS CHARACTER NO-UNDO INITIAL "".
   IF Is-MS-Contract(BUFFER buf_Master, BUFFER buf_Slave) THEN DO:
      cError = PROGRAM-NAME(1) + ":" + "Между договорами  уже есть связь Master->Slave".
      RETURN.
   END.
   RUN gen-key-rec IN THIS-PROCEDURE(
       INPUT  v-S_CONTRACT,
       INPUT  BUFFER buf_Master:HANDLE,
       OUTPUT cKeyRec
       ) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      cError = PROGRAM-NAME(1) + ":" + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.
      RETURN.
   END.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      CREATE buf_Ext-Classif NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      ASSIGN
         buf_Ext-Classif.Classif-name    = v-S_CONTRACT
         buf_Ext-Classif.Classif-subject = v-S_CONTRACT
         buf_Ext-Classif.CharKey_One     = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
         buf_Ext-Classif.CharKey_Two     = STRING(buf_Slave.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Slave.Contract-code)
         buf_Ext-Classif.DB-num          = buf_Master.Db-num
         buf_Ext-Classif.Uniq-key-rec    = cKeyRec
         NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      RELEASE buf_Ext-Classif NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
FUNCTION Is-MS-Contract-Int-2 RETURN INTEGER (
                              i-Host-Code AS INTEGER,
                              i-Contract-Code AS INTEGER):
   DEFINE BUFFER buf_Contract FOR ub.Contract.
   DEFINE VARIABLE iRet AS INTEGER NO-UNDO INITIAL 0.
   FIND FIRST buf_Contract WHERE
              buf_Contract.Host-Code      = i-Host-Code
          AND buf_Contract.Contract-code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF AVAILABLE buf_Contract THEN DO:
      ASSIGN
         iRet = Is-MS-Contract-Int(BUFFER buf_Contract).
   END.
   RETURN (iRet).
END FUNCTION.
FUNCTION Is-MS-Contract-Int RETURN INTEGER (BUFFER buf_Contract FOR ub.Contract):
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE VARIABLE iRet AS INTEGER NO-UNDO INITIAL 0.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                            STRING(buf_Contract.contract-code)
        AND  buf_Ext-classif.db-num       = buf_Contract.db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          iRet = 1.
       LEAVE.
   END.
   IF iRet <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                               STRING(buf_Contract.contract-code)
           AND  buf_Ext-classif.db-num       = buf_Contract.db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             iRet = 2.
          LEAVE.
      END.
   END.
   RETURN (iRet).
END FUNCTION.
FUNCTION Is-Master-Slave-Contract RETURN CHARACTER( BUFFER buf_Contract FOR ub.Contract):
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE VARIABLE cRet AS CHARACTER NO-UNDO INITIAL "".
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                            STRING(buf_Contract.contract-code)
        AND  buf_Ext-classif.db-num       = buf_Contract.db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          cRet = "+".
       LEAVE.
   END.
   IF cRet = "" THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                               STRING(buf_Contract.contract-code)
           AND  buf_Ext-classif.db-num       = buf_Contract.db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             cRet = (IF buf_Cont.Contract-prn-code = "" THEN  STRING(buf_Cont.Contract-code) ELSE buf_Cont.Contract-prn-code).
          LEAVE.
      END.
   END.
   RETURN (cRet).
END FUNCTION.
FUNCTION Is-MS-Contract RETURN LOGICAL(
         BUFFER buf_Master FOR ub.Contract,
         BUFFER buf_Slave  FOR ub.Contract):
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   RETURN CAN-FIND ( FIRST buf_Ext-Classif WHERE
                       buf_Ext-Classif.Classif-name = v-S_CONTRACT
                   AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
                   AND buf_Ext-Classif.CharKey_Two  = STRING(buf_Slave.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Slave.Contract-code)
                   AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
                 NO-LOCK).
END FUNCTION.
FUNCTION Get-Num-Slave-Contract RETURN CHARACTER(
         BUFFER buf_Master FOR ub.Contract,
         INPUT iSlave-Host-Code AS INTEGER
         ):
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE BUFFER buf_Contract    FOR ub.Contract.
   DEFINE VARIABLE cRet AS CHARACTER NO-UNDO INITIAL "".
   FIND FIRST buf_Ext-Classif WHERE
              buf_Ext-Classif.Classif-name = v-S_CONTRACT
          AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
          AND buf_Ext-Classif.CharKey_Two  BEGINS STRING(iSlave-Host-Code) + v-DELIM_CHR_3
          AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
        NO-LOCK NO-ERROR.
   IF AVAILABLE buf_Ext-Classif THEN DO:
      IF CAN-FIND (FIRST buf_Contract WHERE
                         buf_Contract.Host-Code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
                     AND buf_Contract.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
                    NO-LOCK) THEN DO:
         ASSIGN
            cRet = ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3).
      END. ELSE DO:
         ASSIGN
            cRet = "ERROR:" + "Ошибка связи мастер договора " +
                   STRING(buf_Master.Host-Code) + "," + STRING(buf_Master.Contract-code) + " " +
                   "c Host-code=" + STRING(iSlave-Host-Code).
      END.
   END.
   RETURN (cRet).
END FUNCTION.
DEFINE VARIABLE mImagePath     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageDir      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImagePreDir   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageTrash    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mPhotomgd      AS LOGICAL     NO-UNDO.
DEFINE VARIABLE mImagePh       AS LOGICAL     NO-UNDO.
define variable v-param-types   as character  no-undo.
define variable v-value-char    as character  no-undo.
define variable v-val-date      as date       no-undo.
define variable v-val-decimal   as decimal    no-undo.
define variable v-val-integer   as integer    no-undo.
define variable v-val-logical   as logical    no-undo.
define variable v-tthd          as handle     no-undo.
RUN imagelist_loaddef IN THIS-PROCEDURE NO-ERROR.
PROCEDURE imagelist_loaddef:
    DEFINE VARIABLE vPar-val       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vPar-type      AS CHARACTER   NO-UNDO.
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'photo':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output vPar-val
  ,output vPar-type
  ) no-error .
        mImagePh = LOOKUP (vPar-val, "true,yes":U) > 0.
    IF mImagePh THEN .
    ELSE RETURN.
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'ph-dir':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  NO
  ,output vPar-val
  ,output vPar-type
  ) no-error .
    IF LENGTH (vPar-val) = 0 THEN
        RUN verify-ini-entry("ph-dir":U, "REP-SETS":U, "":U, YES, OUTPUT vPar-val) NO-ERROR.
    IF LENGTH (vPar-val) = 0 THEN vPar-val = "c:\temp\":U.
    ASSIGN
        mImagePath   = RIGHT-TRIM (vPar-val, "~\~/":U)
        mImagePath   = mImagePath + (IF LENGTH (mImagePath) > 0 THEN "\":U ELSE "":U)
        mImagePreDir = mImagePath
        mImageDir    = mImagePreDir
        mImageTrash  = mImagePath + "trash\":U
        .
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
            run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  'shema-foto':U
        ,output v-value-char
        ,output v-val-date
        ,output v-val-decimal
        ,output v-val-integer
        ,output v-val-logical
        ,output v-param-types
        ,INPUT-OUTPUT table-handle v-tthd
        ) no-error.
        delete object v-tthd.
        mPhotomgd = IF v-val-integer = 2 then yes else no.
END PROCEDURE.
PROCEDURE imagelist_decode:
    DEFINE INPUT  PARAMETER iImageList AS LONGCHAR  NO-UNDO.
    DEFINE INPUT  PARAMETER iImageGdsCode AS int    NO-UNDO.
    DEFINE OUTPUT PARAMETER oImageList AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt               AS INTEGER   NO-UNDO.
    ASSIGN
        oImageList = iImageList
        .
    DO vInt = 1 TO NUM-ENTRIES (iImageList, ",":U):
        vCh =ENTRY (vInt, iImageList, ",":U).
        IF SUBSTRING (vCh, 1, 2) = "~\~\":U THEN .
        ELSE
        DO:
            ASSIGN
                vCh = REPLACE (vCh, "~/":U, "\":U)
                vCh = REPLACE (vCh, "~\":U, "\":U)
                .
            IF SUBSTRING (vCh, 2, 2) = ":\":U OR vCh BEGINS mImageDir THEN .
            ELSE vCh = mImagePreDir + (if mPhotomgd then string(iImageGdsCode) + "\":U else '':U ) +  vCh.
            ENTRY (vInt, oImageList, ",":U) = vCh.
        END.
    END.
END PROCEDURE.
PROCEDURE imagelist_encode:
    DEFINE INPUT  PARAMETER iImageList AS LONGCHAR  NO-UNDO.
    DEFINE OUTPUT PARAMETER oImageList AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt               AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vLen               AS INTEGER   NO-UNDO.
    ASSIGN
        oImageList = iImageList
        vLen       = LENGTH (mImageDir)
        .
    DO vInt = 1 TO NUM-ENTRIES (iImageList, ",":U):
        vCh =ENTRY (vInt, iImageList, ",":U).
        IF LENGTH (vCh) > 0 AND vLen > 0 AND vCh BEGINS mImageDir THEN
            ENTRY (vInt, oImageList, ",":U) =
                SUBSTRING (vCh, vLen + 1).
    END.
END PROCEDURE.
def var vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info35 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info35, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info35, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info35, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info35, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info35 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info35, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info35 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info35, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info35, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info35, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info35, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info35, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info35, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info35 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info35 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info35, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info35, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info35, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info35 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info35 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info35, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info35, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define temp-table tt-act-header
    field num           as character        label "№ акта"      format "X(30)"
    field date_         as date             label "Дата акта"
    field is-sent       as logical
    field answer_       as character        label "Ответ"       format "X(1500)"
    field type_         as character        label "Основание"   format "X(35)"
    field RegID         as character        label "Рег. номер"  format "X(50)"
    index pi as primary unique
        num
.
define temp-table tt-gds-act
    field num           as character                label "№ акта"
    field position_     as integer                  label "№ пп"                    format ">>>9"
    field gds-code      like ub.goods.gds-code      label "Код товара   "
    field part-code     like ub.parts.part-code     label "Партия"
    field doc-code      as character                label "№ накладной TH"
    field doc-date      like ub.trn-doc.fact-date   label "Дата TH"
    field alc-code      as character                label "Алкогольный код"         format "X(21)"
    field gds-name      like ub.goods.gds-name      label "Наименование товара"     format "X(35)"
    field qnty          as decimal                  label "Количество"
    field inform-A      as character                label "Справка А"               format "X(20)"
    field A-qnty        as decimal                  label "Кол-во в справке"
    field A-bottleDate  as date                     label "Дата розлива"
    field A-ttnNumber   as character                label "№ ТТН справки А"         format "X(15)"
    field A-ttnDate     as date                     label "Дата"
    field A-fixNumber   as character                label "№ фиксации в ЕГАИС"      format "X(20)"
    field A-fixDate     as date                     label "Дата фикс."
    field inform-B      as character                label "Справка Б"               format "X(20)"
    field marks-qnty    as integer                  label "Кол-во марок"
    field egais-name    as character
    index pi as primary unique
        position_
    index code
        gds-code doc-code
.
define new shared temp-table tt-marks
    field num                 as character            label "№ акта"
    field gds-part-position_  as integer
    field mark                as character            label "Марка"          format "X(100)"
    field new_                as logical
    field gds-code            like ub.goods.gds-code  LABEL "Код товара"
    field gds-name            as character            LABEL "Наименование"   FORMAT "X(30)"
    field alc-code            as character            LABEL "Алк. код"       FORMAT "X(20)"
    field impor-full-name     as character            LABEL "Импортер"       FORMAT "X(130)"
    field prod-full-name      as character            LABEL "Производитель"  FORMAT "X(130)"
    field flag                as logical              label "T"
    field reserv              as integer              label "R"
    field parts               as character            label "Партия"         format "X(130)"
    index pi as primary unique
        mark
.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info39 as character format "X(65)" no-undo
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
def var vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function getattrUtdex returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-attr  then iExValue    else  utd-attr.attr-value.
end.
function getattrUtd returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character ):
  return getattrUtdex(idb-num,idoc-id,iattrcode,?).
end.
function setattrUtd returns logical
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-attr
   then do:
      create utd-attr.
      assign
         utd-attr.db-num    = idb-num
         utd-attr.doc-id    = idoc-id
         utd-attr.attr-code = iattrcode
         utd-attr.attr-value = iattrval
      .
   end.
   else do:
      if utd-attr.attr-value ne iattrval
      then do:
         find current utd-attr exclusive-lock no-error.
         if available utd-attr
         then
            utd-attr.attr-value = iattrval.
      end.
   end.
   release utd-attr.
end.
function GetAttrUtdlinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-lines-attr  then iExValue    else  utd-lines-attr.attr-value.
end.
function GetAttrUtdlines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character ):
   return GetAttrUtdlinesex (idb-num,idoc-id,ilinenum,iattrcode,?).
end.
function setattrUtdlines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-lines-attr.
         assign
            utd-lines-attr.db-num    = idb-num
            utd-lines-attr.doc-id    = idoc-id
            utd-lines-attr.lineNum   = ilineNum
            utd-lines-attr.attr-code = iattrcode
            utd-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-lines-attr.attr-value ne iattrval
      then do:
         find current utd-lines-attr exclusive-lock no-error.
         if available utd-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-lines-attr.
            end.
            else do:
               utd-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-lines-attr.
end.
function GetAttrUtdMarkingLinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-marking-lines-attr  then iExValue    else  utd-marking-lines-attr.attr-value.
end.
function GetAttrUtdMarkingLines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character ):
   return GetAttrUtdMarkingLinesEx (idb-num,idoc-id,ilinenum,imark,iattrcode,?).
end.
function setattrUtdMarkingLines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-marking-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.db-num     = idb-num
            utd-marking-lines-attr.doc-id     = idoc-id
            utd-marking-lines-attr.lineNum    = ilineNum
            utd-marking-lines-attr.mark       = imark
            utd-marking-lines-attr.attr-code  = iattrcode
            utd-marking-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-marking-lines-attr.attr-value ne iattrval
      then do:
         find current utd-marking-lines-attr exclusive-lock no-error.
         if available utd-marking-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-marking-lines-attr.
            end.
            else do:
               utd-marking-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-marking-lines-attr.
end.
def var vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function AddUtdErrForTab returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iTab            as character,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   define buffer utd-err for utd-err.
   define buffer utd for utd.
   find first utd where utd.db-num     eq idb-num
                    and utd.doc-id     eq idoc-id
                    and utd.Direction  eq 'Outbound'
   no-lock no-error.
   if available utd
   then
      return no.
   define variable vRecKey as character no-undo.
         run gen-key-rec (input iTab,
                          input  iObj,
                          output vRecKey).
   find first utd-err where utd-err.db-num     eq idb-num
                        and utd-err.doc-id     eq idoc-id
                        and utd-err.CheckType  eq iCheckType
                        and utd-err.CodeErr    eq iCodeErr
                        and utd-err.CheckObj   eq iCheckObj
   exclusive-lock no-error.
   if not available utd-err
   then do:
      create utd-err.
      assign
         utd-err.db-num         = idb-num
         utd-err.doc-id         = idoc-id
         utd-err.CheckType      = iCheckType
         utd-err.CodeErr        = iCodeErr
         utd-err.CheckObj       = if iCheckObj eq ? then "?" else iCheckObj
         utd-err.reckey         = vRecKey
         utd-err.qnty           = 1
      .
   end.
   else
      utd-err.qnty = utd-err.qnty + 1.
   return utd-err.qnty eq 1.
end.
function AddUtdErr returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   AddUtdErrForTab
      (idb-num,
       idoc-id,
       iObj:table,
       iObj,
       iCheckType,
       iCodeErr,
       iCheckObj).
end.
function ClearUtdErrTypeCode returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character,
 iCodeErr        as character
 ):
   define buffer utd-err for utd-err.
   if    iCheckType eq "*"
      or iCheckType eq ?
   then do:
      if     iCodeErr ne ?
         and iCodeErr ne "*"
      then
         message "Задан код ошибки " iCodeErr " для удаления, но не задан тип"
         view-as alert-box.
      else
      for each utd-err where utd-err.db-num  eq idb-num
                         and utd-err.doc-id  eq idoc-id
      exclusive-lock:
         delete utd-err.
      end.
   end.
   else do:
      if    iCodeErr eq ?
         or iCodeErr eq "*"
      then do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
         exclusive-lock:
            delete utd-err.
         end.
      end.
      else do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
                            and ub.utd-err.CodeErr eq iCodeErr
         exclusive-lock:
            delete utd-err.
         end.
      end.
   end.
end.
function ClearUtdErr returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   ClearUtdErrTypeCode(idb-num,idoc-id,iCheckType,?).
end.
function GetMesError returns character
(itxt as character,
 iobj as character ):
 define variable vi as integer no-undo.
 do vi = num-entries(iobj ,chr(4) ) to 1 by -1 :
    itxt = replace(itxt,"&" + string(vi),entry(vi,iobj,chr(4))).
 end.
 return itxt.
end.
function GetTextErrorType returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 iType      as character  ):
   define buffer code    for code.
   define variable vError as character no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if available code
   then do:
      define variable vType as integer no-undo.
      if code.misc3 eq "error"
      then
         vType = 0.
      else if code.misc3 eq "warning"
      then
         vType = 1.
      else if code.misc3 eq "Hiden"
      then
         vType = 2.
      else
         vtype = int(code.misc3) no-error.
      case itype:
         when "error"
         then do:
            if vtype eq 0
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         when "warning"
         then do:
            if vtype <= 1
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         otherwise do:
            vError = GetMesError(Code.CodeValue,iChechObj).
         end.
      end.
   end.
   else
      vError =  iCodeErr + ":" + replace (iChechObj,chr(4),"|").
   return vError.
end.
function GetTypeError returns integer
(iCheckType as character,
 iCodeErr   as character):
   define buffer code    for code.
   define variable vType as integer no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     not available code
      and code.misc3 eq "error"
   then
      vType = 0.
   else if code.misc3 eq "warning"
   then
      vType = 1.
   else if code.misc3 eq "Hiden"
   then
      vType = 2.
   else
      vtype = int(code.misc3) no-error.
   return vtype.
end.
function GetTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character ):
   return GetTextErrortype(iCheckType,iCodeErr,iChechObj,"warning").
end.
function GetErrForUtdStr returns character
(idb-num     as integer ,
 idoc-id     as integer ,
 iCheckType  as character
 ):
   define buffer utd-err for utd-err.
   define buffer code    for code.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable vErrorOne as longchar  no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ""
         and vErrorOne ne ?
      then
         vError = vError + ", " + vErrorOne.
      vHQry:get-next().
   end.
   oError = substring(vError,3,4002).
   return oError.
end.
function GetErrJsonForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектОш":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
      vHQry:get-next().
   end.
   for first utd where utd.db-num eq idb-num
                   and utd.doc-id eq idoc-id
                   and utd.sts    eq ObjSrv:Env:Utd:Sts:th:DeliveryCodeMismatch:KeyIntDB
   no-lock,
      each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                               and utd-marking-lines.doc-id eq idoc-id
                               and utd-marking-lines.doc-level eq 1
   no-lock,
      first marking where marking.mark eq utd-marking-lines.mark
                      and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
   no-lock:
      vErrorOne = GetTextErrortype("CheckShip","NotMark",marking.mark,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + "CheckShip" + "_" + "NotMark"
                         + '","ОбъектОш":"' + marking.mark
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
   end.
   if vError ne ""
   then
      oError = '"Ошибки":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetErrJsonForUtdReturn returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   define variable vi as integer no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Возврат_' + string(vi) +  '":~{"КодВозр":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектВозр":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстВозр":"' + GetTextError(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj) + '"}'.
      end.
      vHQry:get-next().
   end.
   if vError ne ""
   then
      oError = '"Возвраты":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetCodeTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 output oCode as character,
 output ovalue as character ):
   define buffer code    for code.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     available code
   then do:
      define variable vi as integer no-undo init ?.
      vi = int(Code.misc3) no-error.
      if    code.misc3 ne "error"
         and vi ne 0
      then
         oCode = ?.
      else if     Code.misc1 ne ?
              and Code.misc1 ne ""
      then
         assign
            oCode  = GetMesError(Code.misc1,iChechObj)
            ovalue = GetMesError(Code.misc2,iChechObj)
         .
   end.
   return if oCode eq ""
          then ""
          else (oCode + "_" + ovalue).
end.
define temp-table TT-err no-undo
  field code_ as character
  field text_ as character
index code_ code_.
function GetErrTxtForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   for each tt-err :
      delete tt-err.
   end.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   define variable vcode as character no-undo.
   define variable vvalue as character no-undo.
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vi = vi + 1.
      GetCodeTextError (utd-err.CheckType, utd-err.CodeErr, utd-err.CheckObj, output vcode, output vvalue).
      if vcode ne ?
      then do:
         find first tt-err where tt-err.code eq vcode
         no-error.
         if not available tt-err
         then do:
            create tt-err.
            assign
               tt-err.code_ = vcode
               tt-err.text_ = vvalue
            .
         end.
         else
            tt-err.text_ = tt-err.text_ + "||" + vvalue.
      end.
      vHQry:get-next().
   end.
  find first utd where utd.db-num eq idb-num
                      and utd.doc-id eq idoc-id
      no-lock.
   define buffer cancel_utd-lines for utd-lines.
   for each cancel_utd-lines where cancel_utd-lines.db-num eq idb-num
                               and cancel_utd-lines.doc-id eq idoc-id
   no-lock:
      if logical(getattrutdlinesex  (idb-num,idoc-id,cancel_utd-lines.LineNum,"MarkUtdLine"        ,"no"))
      then do:
         for   each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                                     and utd-marking-lines.doc-id eq idoc-id
                                     and utd-marking-lines.LineNum eq cancel_utd-lines.LineNum
         no-lock,
            first marking where marking.mark eq utd-marking-lines.mark
                            and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
         no-lock:
            GetCodeTextError ("CheckShip", "MARKDECLINED", utd-marking-lines.mark + chr(4) + string(utd-marking-lines.LineNum), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
      else do:
         define variable vqnty as decimal no-undo.
         vqnty = decimal(GetAttrUtdlines(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode")).
         if vqnty eq ? then vqnty = 0.
         if vqnty ne cancel_utd-lines.Quantity
         then do:
            GetCodeTextError ("CheckShip", "NotAcceptQuantity", string(cancel_utd-lines.LineNum) + chr(4) + string(cancel_utd-lines.Quantity - vqnty), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
   end.
   for each tt-err:
      oError = oError + substitute("&1|&2|",tt-err.code_ , tt-err.text_ ) + chr(13) + chr(10) .
   end.
   return oError.
end.
define variable mFormatErr as character no-undo init "text".
function GetErrForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iType           as character
 ):
   if mFormatErr eq "text"
   then
      return GetErrTxtForUtd(idb-num,idoc-id,iType).
   else do:
      if itype eq "return"
      then return GetErrJsonForUtdReturn (idb-num,idoc-id,iType).
      else return GetErrJsonForUtd(idb-num,idoc-id,iType).
   end.
end.
function GetErrComText returns longchar
(icomment as character,
 itext    as longchar ):
    define variable vText as longchar no-undo.
   if mFormatErr eq "text"
   then do:
      if icomment ne ""
      then
         icomment = substitute("comment:|&1|",icomment).
      vText = icomment + itext.
   end.
   else do:
      icomment = if icomment begins  '"'
                 then icomment
                 else  if icomment eq "" then "" else ( '"Коментрии":~{"Коментарий":"' + icomment  + '"}') .
      vText = icomment + "," + itext.
      vText = "~{" + trim(vText,",") + "~}".
   end.
   return vText.
end.
function CheckTypeForMarkLineType returns logical
(iObj            as handle,
 iCheckType      as character,
 iCodeErr        as character ,
 iTypeErr        as character ):
   define variable vRecKey-markLine as character no-undo.
   define variable vGoodMark        as logical no-undo.
   define variable vdb-num          as integer no-undo.
   define variable vdoc-id          as integer no-undo.
   define variable vlinenum         as integer no-undo.
   define variable vErrorOne as character no-undo.
   define buffer buf_utd-err for utd-err.
   run gen-key-rec (input "utd-marking-lines",
                    input  iObj,
                    output vRecKey-markLine).
   vGoodMark = yes.
   vdb-num = iObj::db-num.
   vdoc-id = iObj::doc-id.
   vlinenum = iObj::linenum.
   block-mark-err:
   for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                            and buf_utd-err.db-num = vdb-num
                            and buf_utd-err.reckey = vRecKey-markLine
                            and if iCheckType  eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                            and if iCodeErr    eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
   no-lock:
      vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vGoodMark = no.
         leave block-mark-err.
      end.
   end.
   return not vGoodMark.
end.
function CheckErrForMarkLineType returns logical
(iObj            as handle,
 iType           as character  ):
   return CheckTypeForMarkLineType (iObj,iType,"*","error").
end.
function CheckErrForMarkLine returns logical
(iObj            as handle):
   return CheckErrForMarkLineType(iObj,"*").
end.
function CheckErrForLineTypeCode returns logical
(iObj                 as handle,
 iCheckType           as character,
 iCodeErr             as character,
 iTypeErr             as character,
 iOneErr              as logical):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iCheckType eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                               and if iCodeErr   eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            vUtdlineError = yes.
            leave block-err.
         end.
      end.
      if  not vUtdlineError
      then do:
         define variable vGoodMark as logical no-undo.
         vGoodMark = yes.
         block-line-err:
         for each utd-marking-lines where utd-marking-lines.db-num  eq vdb-num
                                      and utd-marking-lines.doc-id  eq vdoc-id
                                      and utd-marking-lines.LineNum eq vLineNum
         no-lock:
            vGoodMark = not CheckTypeForMarkLineType(buffer utd-marking-lines:handle,iCheckType,iCodeErr,iTypeErr).
            if     vGoodMark
               and iOneErr eq no
            then
               leave block-line-err.
            if     iOneErr = yes
               and not vGoodMark
            then
               leave block-line-err.
         end.
         vUtdlineError = not vGoodMark.
      end.
   return vUtdlineError.
end.
function getErrForLineType returns character
(iObj            as handle,
 iType           as character  ):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
   define variable oError as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iType eq "*" or iType eq ? then yes else buf_utd-err.CheckType = iType
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,"error").
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            oError = oError + vErrorOne + " ".
         end.
      end.
   return oError.
end.
function CheckErrForLineType returns logical
(iObj            as handle,
 iType           as character  ):
    return CheckErrForLineTypeCode (iObj,itype,"*","error",no).
end.
function CheckErrForLine returns logical
(iObj            as handle):
   return CheckErrForLineType(iobj,"*").
end.
function CheckErrForUtd returns logical
(idb-num         as integer ,
 idoc-id         as integer ):
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock :
      if not CheckErrForLine (buffer ub.utd-lines:handle)
      then
         return no.
   end.
   return yes.
end.
function CheckMarkUtd-28rel return logical
 (input idb-num as integer,
 input idoc-id as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vgdsNoMark as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num eq idb-num
                              and utd-lines.doc-id eq idoc-id
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               if     EDOParSec:IsEdo
                  and EDOParSec:GetIsEDOForType(v-par-val)
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                                 and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                                 and utd-marking-lines.LineNum eq utd-lines.LineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if     avail utd-marking-lines
                     and not CheckErrForLine(buffer utd-lines:handle)
                  then
                     leave Block-utd-lines.
               end.
               else
                  vgdsNoMark = yes.
            end.
         end.
         setattrutd (utd.db-num,utd.doc-id,"MarkUtd",if vgdsNoMark then string(available utd-lines) else "yes").
         if vgdsNoMark then return available utd-lines . else return yes .
      end.
   end.
   return yes.
end.
function CheckMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  block-line:
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","yes"))
     then
        leave block-line.
  end.
  setattrutd (idb-num, idoc-id,"MarkUtd",string(available utd-lines)).
  return available utd-lines.
end.
function CheckNotMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if not logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
     then
        return yes.
  end.
  return no.
end.
function CheckMarkUtdLine return logical
 (input idb-num  as integer,
  input idoc-id  as integer,
  input iLineNum as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vMarking        as logical no-undo.
 define variable vArtic          as logical no-undo.
 define variable vTransitional   as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num   eq idb-num
                              and utd-lines.doc-id   eq idoc-id
                              and utd-lines.LineNum  eq iLineNum
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               vMarking = EDOParSec:GetIsEDOForType(v-par-val).
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val).
               if vMarking
               then do:
                  block-marking:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isOAD(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = yes
                           vMarking = no
                        .
                        leave block-marking.
                     end.
                  end.
               end.
               if vArtic
               then do:
                  block-artic:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isMark(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = no
                           vMarking = yes
                        .
                        leave block-artic.
                     end.
                  end.
               end.
               vTransitional = (vMarking or vArtic) and EDOParSec:GetIsTransitionalForType(v-par-val).
               if vTransitional
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if not available utd-marking-lines
                  then assign
                     vMarking = no
                     vArtic   = no
                  .
               end.
            end.
            else
               assign
                  vMarking      = yes
                  vArtic        = no
                  vTransitional = no
               .
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"MarkUtdLine"         ,if vMarking      then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"ArticUtdLine"        ,if vArtic        then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"TransitionalUtdLine" ,if vTransitional then "yes" else "").
         end.
      end.
   end.
   return vMarking or vArtic.
end.
function getMarkUtdLine return logical
 (input  idb-num  as integer,
  input  idoc-id  as integer,
  input  iLineNum as integer,
  output oMarking        as logical,
  output oArtic          as logical,
  output oTransitional   as logical):
  oMarking = logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"MarkUtdLine"        ,"no")).
  oArtic        = not oMarking
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"ArticUtdLine"       ,"no")).
  oTransitional = (oMarking or oArtic)
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"TransitionalUtdLine","no")).
end.
function CheckMarking return logical
 (input idb-num as integer,
 input idoc-id as integer,
 input iTypeErr as character ):
  define variable vMarkutd as logical no-undo.
  define variable vCrErr   as logical no-undo.
  define buffer utd-lines         for utd-lines.
  define buffer utd-marking-lines for utd-marking-lines.
  define buffer marking           for marking.
  ClearUtdErrTypeCode(idb-num,idoc-id,iTypeErr,"NotMark").
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      if logical (getAttrUtdLinesEx(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
      then do:
         for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
         no-lock:
            if isMark(utd-marking-lines.mark)
            then do:
               find first marking where marking.mark eq utd-marking-lines.mark
               no-lock no-error.
               if not available marking
               then do:
                  AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iTypeErr,"NotMark",string(utd-lines.LineNum)).
                  vCrErr = yes.
                  next block-line.
               end.
            end.
         end.
      end.
   end.
   return vCrErr.
end.
function CheckMarkForType return logical
 (input idb-num   as integer,
  input idoc-id   as integer):
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define buffer utd-lines         for utd-lines.
   define buffer utd-marking-lines for utd-marking-lines.
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      getMarkUtdLine  (input  utd-lines.db-num , input  utd-lines.doc-id, input  utd-lines.LineNum,
                       output vMarking         , output vArtic          , output vTransitional).
      for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
      no-lock:
         if length(utd-marking-lines.mark) < 14
         then do:
            if (vMarking or vArtic) and not vTransitional
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else if not isMark(utd-marking-lines.mark)
         then do:
            if vMarking
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else do:
         end.
      end.
   end.
end.
function WeighedProd return logical
   ( input p-gds-code as integer) :
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
           if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'weighed-gds':U,
               output v-par-val,
               output v-par-type
            ).
   return logical(v-par-val).
end.
function WghProdVariable return logical
    (input p-obj-type as char,
     input p-obj-code as integer,
     input p-gds-code as integer) :
   define variable v-wgh-val  as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
      if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
        ( p-gds-code,
          'weighed-gds':U,
           output v-wgh-val,
           output v-par-type
        ).
    if logical(v-wgh-val) = yes then do:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'mark-type':U,
               output v-par-val,
               output v-par-type
            ).
        if v-par-val <> "" then do:
            EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(p-obj-type, p-obj-code).
            assign
               vMarking = EDOParSec:GetIsEDOForType(v-par-val)
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val)
               .
        end.
   end.
   if v-wgh-val > "" and (vMarking or vArtic)
   then return yes.
   else return no.
end.
function MarkWeight return decimal
   ( input p-mark as character) :
   define buffer  buf_marking-attr for  ub.marking-attr.
   define variable vMarkWeight as decimal no-undo.
   vMarkWeight = 0.
   if p-mark <> "" and p-mark <> ?
   then do:
       find first buf_marking-attr where buf_marking-attr.mark      eq p-mark
                                     and buf_marking-attr.attr-code eq "weight"
          no-lock no-error.
       if not available buf_marking-attr
       then do :
         find first buf_marking-attr where buf_marking-attr.mark  begins p-mark
                                       and buf_marking-attr.attr-code eq "weight"
            no-lock no-error.
       end .
       if avail buf_marking-attr
       then vMarkWeight = dec(buf_marking-attr.attr-value).
   end.
   return vMarkWeight.
end.
define variable bar-str like ub.prod-bc.b-str  no-undo.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
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
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
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
define variable v-is-flora-ord as logical   no-undo initial false .
if lookup (parlist-mode , 'is-flor':U + ","  + 'is-flor':U + 'объект':U + ","  + 'is-flor':U + 'статус':U   )  > 0 then do:
v-is-flora-ord = true .
end.
define buffer cli-buf    for ub.clients.
define buffer t-d-b      for ub.trn-doc.
define buffer old-line   for ub.doc-line.
define buffer d-l-b      for ub.doc-line.
define buffer l-doc-line for ub.doc-line.
define buffer gds-dtl    for ub.gds-dtl  .
define buffer reas_contract for ub.contract .
define buffer buf_contract-attr for ub.contract-attr .
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION title-mode RETURNS CHARACTER
  ( INPUT pmode as character ) :
DEFINE VARIABLE ptitle-mode as character no-undo.
CASE ENTRY(1, pmode) :
  when 'ДОБАВЛЕНИЕ':U then ptitle-mode = "ДОБАВЛЕНИЕ".
  when 'ИЗМЕНЕНИЕ':U  then ptitle-mode = "ИЗМЕНЕНИЕ".
  when 'ПРОСМОТР':U  then ptitle-mode = "ПРОСМОТР".
END CASE.
  RETURN ptitle-mode.
END FUNCTION.
define variable mark      as character                 no-undo.
define variable del-list  as character                 no-undo.
define variable ref-list  as character                 no-undo.
define variable chg-qnty  like ub.gds-dtl.doc-qnty init ? no-undo.
define variable add-sens  as log                       no-undo.
define variable b-c       as int                       no-undo.
define variable b-c-char  as character                 no-undo.
define variable rate      as dec                       no-undo.
define variable ret-mode  as character                 no-undo.
define variable add-scan  as logical initial no        no-undo.
define variable work-mode as character                 no-undo.
define variable varhold   as character                 no-undo.
define variable varhold-type as character              no-undo.
define variable v-del                as logical   no-undo .
define variable v-add                as logical   no-undo .
define variable bcvalue   as character initial ?       no-undo.
define variable v-reasonm as logical   no-undo init false .
define variable v-reasonme as character no-undo .
define variable v-reasons-for-return as character no-undo .
define variable bctype         as character initial ? no-undo.
define variable prtvalue       as character initial ? no-undo.
define variable prttype        as character initial ? no-undo.
define variable v-is-pharm      as character no-undo .
define variable v-is-pharm-type as character no-undo .
define variable varartic       like ub.doc-line.artic      initial " " no-undo.
define variable is-petrolium   as logical   no-undo.
define variable is-pieces      as logical   no-undo.
define variable v-cond         as character no-undo init ?.
define variable varr-b         as character no-undo.
define variable v-is-tsd       as character no-undo .
define variable v-is-tsd-type  as character no-undo .
define variable v-exist  as logical   no-undo .
define variable v-buket-gds-code as integer   no-undo .
define variable v-param as character no-undo .
define variable v-gds-name as character no-undo .
define variable parext-doc-mode as character no-undo.
define variable prev-pardoc-mode as character no-undo.
define variable varvalue as character no-undo.
define variable vartype  as character no-undo.
define variable is-contract-edo as logical no-undo init no .
define variable v-is-ptrl   as character no-undo.
define variable v-data-type as character no-undo.
define variable is-doc-hold as logical   no-undo.
define variable d-kg-price-rubl like ub.gds-dtl.price-rubl no-undo.
define variable d-kg-price-base like ub.gds-dtl.price-base no-undo.
define variable d-kg-fact-qnty  like ub.gds-dtl.fact-qnty  no-undo.
define variable d-kg-after-qnty like ub.gds-dtl.fact-qnty  no-undo.
define variable varlog         as logical   no-undo.
define variable gds-rec        as recid     no-undo.
define variable ref-rec        as recid     no-undo.
define variable prt-rec        as recid     no-undo.
define variable varline-mode   as character no-undo.
define variable varlns-cnt     as integer   no-undo.
define variable del-rec        as recid     no-undo.
define variable varprt-mode    as character no-undo.
define variable v-mercury-value as character no-undo .
define variable v-mercury-type  as character no-undo .
define variable vsdstrObj as class vsdtostorage no-undo.
define variable bcol as handle extent no-undo.
define variable hBrowse as handle no-undo.
define variable ii as integer no-undo.
define variable ch-vsd as character no-undo .
define variable trn-type as integer no-undo init 0.
define variable Tree                 as class     tree         no-undo .
define variable v-is-return          as logical   no-undo init no .
define variable varpart-rec          as   recid                      no-undo.
define variable vExist as logical no-undo.
define variable vOk    as logical no-undo.
define new shared temp-table tt-doc-pl no-undo
field pl-code as integer format "99999999999"
field pl-code2 as integer format "99999999999"
field whole-send-news like ub.doc-pl.whole-send-news
field obj-type like ub.doc-pl.obj-type
field obj-code like ub.doc-pl.obj-code
field out-code like ub.doc-pl.out-code
field fact-qnty like ub.doc-pl.fact-qnty
field doc-qnty like ub.doc-pl.doc-qnty
field gds-code as integer format "99999999999"
field cli-qnty like ub.doc-pl.cli-qnty
field cli-fact-qnty like ub.doc-pl.cli-fact-qnty
field cli-doc-qnty like ub.doc-pl.cli-doc-qnty
field rest-af-qnty like ub.doc-pl.rest-af-qnty
field cli-rest-af-qnty like ub.doc-pl.cli-rest-af-qnty
field rest-bf-qnty like ub.doc-pl.rest-bf-qnty
field cli-rest-bf-qnty like ub.doc-pl.cli-rest-bf-qnty
index pi obj-type obj-code pl-code out-code gds-code
index doc out-code gds-code obj-code obj-type pl-code
index gds-code gds-code
.
function get-mark return character (buffer local-gds-dtl for ub.gds-dtl ).
   if lookup (string (recid (local-gds-dtl)), del-list) > 0  then return "*".
                                                             else return "".
end function.
function get-kg-sale-rubl returns decimal ( buffer local-gds-dtl for ub.gds-dtl ) :
  define variable d_out-kg-sale-price like ub.gds-dtl.price-rubl no-undo.
  run inv-line_price in this-procedure ( input recid( local-gds-dtl ), input yes, output d_out-kg-sale-price ) no-error.
  return ( if error-status :error then ? else d_out-kg-sale-price ).
end function.
function get-kg-sale-base returns decimal ( buffer local-gds-dtl for ub.gds-dtl ) :
  define variable d_out-kg-sale-price like ub.gds-dtl.price-rubl no-undo.
  run inv-line_price in this-procedure ( input recid( local-gds-dtl ), input  no, output d_out-kg-sale-price ) no-error.
  return ( if error-status :error then ? else d_out-kg-sale-price ).
end function.
function get-kg-fact-qnty returns decimal ( buffer local-gds-dtl for ub.gds-dtl ) :
  define variable d_out-qnty-kg like ub.gds-dtl.fact-qnty no-undo.
  run inv-line_qnty in this-procedure ( input recid( local-gds-dtl ),             output d_out-qnty-kg       ) no-error.
  return ( if error-status :error then ? else d_out-qnty-kg ).
end function.
function get-kg-after-qnty returns decimal ( buffer local-gds-dtl for ub.gds-dtl ) :
  define variable d_out-qnty-kg like ub.gds-dtl.fact-qnty no-undo.
  run after_qnty in this-procedure    ( input recid( local-gds-dtl ),             output d_out-qnty-kg       ) no-error.
  return ( if error-status :error then ? else d_out-qnty-kg ).
end function.
FUNCTION get-vsdsts RETURNS CHARACTER
(buffer local-gds-dtl for ub.gds-dtl ):
  if parext-doc-type <> 'iv':U
  and not v-is-return
    then return "".
  def var v-mercury-prod as logical no-undo.
  def buffer bf_gds for ub.goods.
  find first bf_gds where
        local-gds-dtl.artic = bf_gds.artic
    and local-gds-dtl.prod-type = bf_gds.prod-type
    and local-gds-dtl.prod-code = bf_gds.prod-code.
  if lookup(v-mercury-value, 'no':u) = 0
  then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  bf_gds.gds-code
  ,input  'mercur_FGIS=request':u
  ,output v-mercury-prod
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Код товара" bf_gds.gds-code skip
        'mercur_FGIS=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-mercury-prod
    then do:
      vsdstrObj = new vsdtostorage ().
      if vsdstrObj:exsistvsd( buffer local-gds-dtl )
      then do:
        delete object vsdstrObj no-error.
        return "+".
      end.
      else do with frame d-out-doc:
        delete object vsdstrObj no-error.
        return "-".
      end.
    end.
  end.
  return "".
end function.
define menu m-outs
    menu-item m-outs-1 label "Документы по объекту" accelerator "alt-1"
    menu-item m-outs-5 label "Заказы"               accelerator "alt-1"
    menu-item m-outs-2 label "Мобильный сканер"     accelerator "alt-2"
    menu-item m-outs-3 label "Остатки по списку товаров"    accelerator "alt-3"
    menu-item m-outs-6 label "Остатки по списку партий"     accelerator "alt-6"
    menu-item m-outs-4 label "Сброс"                accelerator "alt-4"
        menu-item m-outs-8 label "Импорт акцизных марок"                accelerator "alt-8"
    menu-item m-outs-9 label "УПД по объекту"                accelerator "alt-9"
    menu-item m-outs-10 label "Немаркированные остатки по списку товаров"                accelerator "alt-0"
.
DEFINE MENU m-marks
  MENU-ITEM m_add-marks          LABEL "Добавить"
  MENU-ITEM m_lookup-marks       LABEL "Просмотр"
  MENU-ITEM m_no-marks           LABEL "Немаркированная продукция"
.
define menu m-acc_price
    menu-item m-ap-1 label "без НДС"              accelerator "alt-1"
    menu-item m-ap-2 label "с НДС"                accelerator "alt-2"
    menu-item m-ap-3 label "без НДС (НДС 0 НП 0)" accelerator "alt-3"
.
define menu m-fixprice
    menu-item m-fp-1 label "Фиксировать цены"     accelerator "alt-1"
    menu-item m-fp-2 label "Расфиксировать цены"  accelerator "alt-2"
.
define menu m-print
    menu-item m-print-1   label "&Ценник"
    menu-item m-print-3   label "&Список кодов"
    .
define temp-table t-d-b-doc-line no-undo like lib-trn_ret-line.
define temp-table t-d-b-gds-dtl  no-undo like ub.gds-dtl.
define temp-table t-d-b-parts    no-undo like ub.parts.
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1.
DEFINE BUTTON b-arch
     LABEL "Уч&ет":L
     SIZE 7 BY 1 TOOLTIP "Просмотр в учетных ценах".
DEFINE BUTTON b-attr
     LABEL "А&тр"
     SIZE 5 BY 1 TOOLTIP "Дополнительные атрибуты по документу".
DEFINE BUTTON b-bc
     LABEL "&БарКод":L
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1.
DEFINE BUTTON b-cnt
     LABEL "&ДогП":L
     SIZE 6 BY 1 TOOLTIP "Просмотр разбивки по договорам поставщиков".
DEFINE BUTTON b-contr-lkp
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Посмотреть договор".
DEFINE BUTTON b-cur
     LABEL "У&Цена"
     SIZE 7 BY 1 TOOLTIP "Простановка учетных цен".
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1.
DEFINE BUTTON b-dopinf
     LABEL "О заказе":L
     SIZE 9 BY 1 TOOLTIP "Дополнительная информация для заказа по наборам - нетоварным позицииям".
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход":L
     SIZE 8 BY 1.
DEFINE BUTTON b-fixprice
     LABEL "&ФиксЦ"
     SIZE 7 BY 1 TOOLTIP "Зафиксировать/расфикcировать цены".
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 2.5 BY 1.
DEFINE BUTTON b-print
     IMAGE-UP FILE "cmp/b-print.bmp":U
     LABEL "&Печать":L
     SIZE 3 BY 1.
DEFINE BUTTON b-history
     LABEL "&История"
     SIZE 3 BY 1.
DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 10 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.
DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>":L
     SIZE 4 BY 1.
DEFINE IMAGE g-image
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 20.00 BY 5.
DEFINE BUTTON b-notes
     LABEL "При&мДок":L
     SIZE 8 BY 1.
DEFINE BUTTON b-notes-line
  LABEL "О наборе":L
  SIZE 10 BY 1 TOOLTIP "Дополнительная информация по набору - нетоварной позиции".
DEFINE BUTTON b-marks
  LABEL "&Марки"
  SIZE 10 BY 1.
DEFINE BUTTON b-parts
     LABEL "Па&ртии":L
     SIZE 10 BY 1.
DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<":L
     SIZE 4 BY 1.
DEFINE BUTTON b-prt
     LABEL "&Шкала":L
     SIZE 10 BY 1.
DEFINE BUTTON b-re-price
     LABEL "ПрсчЦены"
     SIZE 9 BY 1 TOOLTIP "Пересчитать цены по параметрам покупки".
DEFINE BUTTON b-revis DEFAULT
     LABEL "Сверки"
     SIZE 8 BY 1.
DEFINE BUTTON b-rsrv-doc-list
     LABEL "Резерв"
     SIZE 7 BY 1.
DEFINE BUTTON r-acc
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.
DEFINE BUTTON r-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.
DEFINE BUTTON r-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.
DEFINE BUTTON r-clients
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.
DEFINE BUTTON r-outs
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.
DEFINE BUTTON r-pay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.
DEFINE BUTTON r-reas
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1 TOOLTIP "Основание(причина заведения документа)".
DEFINE BUTTON r-sht
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.
DEFINE BUTTON r-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.
DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 11 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE boss-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 11 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fact-base AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "К опл&."
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fact-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 20 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE flora-PS AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 98 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE loc-art AS CHARACTER FORMAT "x(16)"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 TOOLTIP "Начало артикула"
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE loc-code AS CHARACTER FORMAT "x(13)":U
     VIEW-AS FILL-IN
     SIZE 20 BY 1 TOOLTIP "Бар-код (весь)"
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE loc-name AS CHARACTER FORMAT "x(40)":U
     VIEW-AS FILL-IN
     SIZE 20 BY 1 TOOLTIP "Начало названия"
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE pay-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 20 BY .67 NO-UNDO.
DEFINE VARIABLE rsn-name AS CHARACTER FORMAT "x(60)":U
      VIEW-AS TEXT
     SIZE 45.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sum-base AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма"
      VIEW-AS TEXT
     SIZE 17 BY .67 NO-UNDO.
DEFINE VARIABLE sum-rubl AS DECIMAL FORMAT "->>,>>>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 20 BY .67 NO-UNDO.
DEFINE VARIABLE TEXT-RUBL AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 4.5 BY .79
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE varcontract-prn-code AS CHARACTER FORMAT "X(16)"
     LABEL "До&говор"
     VIEW-AS FILL-IN
     SIZE 15 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 11 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE a-n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&А", "art",
"&Н", "name",
"&К", "code"
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE varpurch-chs AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "&Все", 0,
"&Выборочно", 1
     SIZE 12 BY 1 NO-UNDO.
DEFINE RECTANGLE rect-prc
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 18 BY 5.
DEFINE RECTANGLE rect-tot
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 47 BY 5.
DEFINE VARIABLE edo-return    AS LOGICAL INITIAL no
  LABEL "Возврат по ЭДО"
  VIEW-AS TOGGLE-BOX
  SIZE 17 BY .67
  FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE is-cons AS LOGICAL INITIAL no
     LABEL "консигнация"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE is-oldcons AS LOGICAL INITIAL no
     LABEL "ст. консигн."
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE is-repay AS LOGICAL INITIAL no
     LABEL "выкуп"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE is-storage AS LOGICAL INITIAL no
     LABEL "отв.хран."
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY br-dtl FOR
      ub.doc-line,
      ub.gds-dtl,
      ub.gds-prt,
      ub.goods,
      ub.bar-code SCROLLING.
DEFINE BROWSE br-dtl
  QUERY br-dtl DISPLAY
  get-mark(BUFFER ub.gds-dtl)                       column-label '*'  format "x(1)"
  ub.doc-line.line-num                       column-label 'П/П'  format ">>>>>9"
  ub.bar-code.b-code                       column-label 'Бар-код'  format "99999999999"
  ub.gds-dtl.artic                       column-label 'Артикул'
  (if ub.gds-prt.node-name <> '_Пустая шкала':U and ub.gds-prt.upper-code <> ub.goods.prt-root then ub.goods.gds-name + ' - ' + ub.gds-prt.f-name else ub.goods.gds-name)     @ v-gds-name      column-label 'Имя '  format "x(150)"
  ub.gds-dtl.doc-qnty                       column-label 'По документу'  format ">>>,>>>,>>9.999"
  ub.gds-dtl.fact-qnty                       column-label 'Факт'  format ">>>,>>>,>>9.999"
  ub.goods.unit-base                       column-label 'Изм'  format "x(3)"
  ub.gds-dtl.price-base                       column-label 'Цена (вал.)'
  ub.gds-dtl.ov                      column-label '' format "+/-"
  (ub.gds-dtl.price-base * ub.gds-dtl.fact-qnty)                      column-label 'Сумма (вал.)' format "->>,>>>,>>>,>>9.99"
  (ub.gds-dtl.discnt-base * ub.gds-dtl.fact-qnty)                      column-label 'Скидка (вал.)' format "->>,>>>,>>>,>>9.99"
  ((ub.gds-dtl.price-base - ub.gds-dtl.discnt-base) * ub.gds-dtl.fact-qnty)                      column-label 'Итого (вал.).' format "->>,>>>,>>>,>>9.99"
  ub.gds-dtl.discnt-pc                      column-label 'Скидка %' format "->>>9.99"
  ub.gds-dtl.price-rubl                      column-label 'Цена (руб.)'
  (ub.gds-dtl.price-rubl * ub.gds-dtl.fact-qnty)                      column-label 'Сумма (руб.)' format "->,>>>,>>>,>>>,>>9.99"
  (ub.gds-dtl.discnt-rubl * ub.gds-dtl.fact-qnty)                      column-label 'Скидка (руб.)' format "->,>>>,>>>,>>>,>>9.99"
  ((ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) * ub.gds-dtl.fact-qnty)                      column-label 'Итого (руб.)' format "->,>>>,>>>,>>>,>>9.99"
  (if ub.gds-prt.node-name = '_Пустая шкала':U then '-' else if ub.gds-prt.upper-code = ub.goods.prt-root then '-------------------' else ub.gds-prt.f-name)                      column-label 'Признак' format "x(30)"
  get-kg-fact-qnty(  buffer ub.gds-dtl )    @ d-kg-fact-qnty  column-label 'Факт, кг' format ">>>,>>>,>>9.999":U
  get-kg-sale-base(  buffer ub.gds-dtl )    @ d-kg-price-base column-label 'Цена за кг (вал.)' format "->>,>>>,>>>,>>9.999":U
  get-kg-sale-rubl(  buffer ub.gds-dtl )    @ d-kg-price-rubl column-label 'Цена за кг (руб.)' format "->,>>>,>>>,>>>,>>9.999":U
  get-kg-after-qnty( buffer ub.gds-dtl )    @ d-kg-after-qnty column-label 'Итого, кг' format "->,>>>,>>>,>>>,>>9.999":U
  ub.doc-line.vat-sum-rubl * ub.gds-dtl.fact-qnty / ub.doc-line.fact-qnty    @ Vat-sum         column-label 'НДС' format "->,>>>,>>>,>>>,>>9.999":U
  ub.doc-line.vat-pc                      column-label 'НДС' format "->>>,>>9.99999999":U
  enable ub.gds-dtl.doc-qnty ub.gds-dtl.fact-qnty
    WITH SEPARATORS SIZE 106.5 BY 8 ROW-HEIGHT-CHARS .6.
DEFINE FRAME d-out-doc
     b-exit AT ROW 1 COL 1
     b-cur AT ROW 1 COL 9
     b-arch AT ROW 1 COL 16
     b-notes AT ROW 1 COL 23
     b-attr AT ROW 1 COL 31
     b-cnt AT ROW 1 COL 36
     b-fixprice AT ROW 1 COL 42
     b-re-price AT ROW 1 COL 49
     b-rsrv-doc-list AT ROW 1 COL 58
     b-dopinf AT ROW 1 COL 65
     b-revis AT ROW 1 COL 74 WIDGET-ID 8
     b-history AT ROW 1 COL 94.5
     b-print AT ROW 1 COL 93
     b-help AT ROW 1 COL 97.5
     b-prev AT ROW 2 COL 1
     b-next AT ROW 2 COL 5
     t-doc.cli-code AT ROW 2 COL 20 COLON-ALIGNED
          LABEL "Контра&гент"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     t-doc.cli-type AT ROW 2 COL 30.25 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     r-clients AT ROW 2 COL 39.25
     ub.clients.obj-name AT ROW 2 COL 40 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 35 BY 1
          FGCOLOR 4
     t-doc.hold-obj-code AT ROW 2 COL 75.25 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     t-doc.hold-obj-type AT ROW 2 COL 85.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     t-doc.print-rubl AT ROW 2 COL 92
          VIEW-AS TOGGLE-BOX
          SIZE 8 BY 1 TOOLTIP "В какой валюте печатать"
          FGCOLOR 4
     t-doc.doc-date AT ROW 3.04 COL 6.38 COLON-ALIGNED
          LABEL "&Дата"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
          FGCOLOR 4
     t-doc.fact-date AT ROW 3.04 COL 21.38 COLON-ALIGNED
          LABEL "&Факт"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
          FGCOLOR 4
     t-doc.shift-date AT ROW 3.04 COL 37.88 COLON-ALIGNED
          LABEL "&Смена"
          VIEW-AS FILL-IN
          SIZE 9 BY 1 TOOLTIP "Дата смены"
          FGCOLOR 4
     t-doc.shift-name AT ROW 3.04 COL 49.88 COLON-ALIGNED
          LABEL "№"
          VIEW-AS FILL-IN
          SIZE 3 BY 1 TOOLTIP "Номер смены"
          FGCOLOR 4
     t-doc.shift-num AT ROW 3.04 COL 56.88 COLON-ALIGNED
          LABEL "П"
          VIEW-AS FILL-IN
          SIZE 3 BY 1 TOOLTIP "Порядок смены"
          FGCOLOR 4
     r-sht AT ROW 3.04 COL 60.75
     t-doc.d-card AT ROW 3.04 COL 75.5 COLON-ALIGNED
          LABEL "Карта"
          VIEW-AS FILL-IN
          SIZE 23 BY 1 TOOLTIP "Дисконтная карта"
     t-doc.discnt-pc AT ROW 4.04 COL 75.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     t-doc.discnt-type AT ROW 4.04 COL 85.5 COLON-ALIGNED NO-LABEL FORMAT "X(12)"
          VIEW-AS COMBO-BOX INNER-LINES 6
          LIST-ITEMS "процент","карта","группа","сумма","строка","прайс-лист"
          DROP-DOWN-LIST
          SIZE 13 BY 1
     t-doc.out-code AT ROW 4.5 COL 6.5 COLON-ALIGNED
          LABEL "Ист-&к"
          VIEW-AS FILL-IN
          SIZE 15 BY 1 TOOLTIP "Источник"
     r-outs AT ROW 4.5 COL 23.5
     t-doc.base-rate AT ROW 5.88 COL 6.75 COLON-ALIGNED
          LABEL "Кур&с"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     t-doc.base-scale AT ROW 5.88 COL 23.38 COLON-ALIGNED
          LABEL "М-&б"
          VIEW-AS FILL-IN
          SIZE 4 BY 1 TOOLTIP "Масштаб"
          FGCOLOR 4
     r-acc AT ROW 5.88 COL 29.75
     t-doc.tot-calc AT ROW 6.46 COL 47.13 COLON-ALIGNED
          LABEL "Скидка"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .
DEFINE FRAME d-out-doc
     t-doc.discnt-rubl AT ROW 6.46 COL 64.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     varpurch-chs AT ROW 6.5 COL 89 NO-LABEL
     t-doc.pay-code AT ROW 6.88 COL 6.75 COLON-ALIGNED
          LABEL "&Опл"
          VIEW-AS FILL-IN
          SIZE 6 BY 1 TOOLTIP "Оплата"
     r-pay AT ROW 6.88 COL 29.75
     is-repay AT ROW 7.63 COL 89
     t-doc.wrkr AT ROW 8.13 COL 6.88 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     r-wrkr AT ROW 8.13 COL 29.88
     is-cons AT ROW 8.29 COL 89
     is-storage AT ROW 9.04 COL 89
     t-doc.agnt AT ROW 9.13 COL 6.88 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     r-agnt AT ROW 9.13 COL 29.88
     is-storage AT ROW 8.96 COL 89
     is-oldcons AT ROW 9.67 COL 89
     t-doc.boss AT ROW 10.13 COL 5.63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     r-boss AT ROW 10.13 COL 29.88
     varcontract-prn-code AT ROW 11.5 COL 12 COLON-ALIGNED WIDGET-ID 4
     b-contr-lkp AT ROW 11.5 COL 29 WIDGET-ID 2
     r-reas AT ROW 12.75 COL 17.5
     edo-return at row 12.75 col 70
     a-n-c AT ROW 13.75 COL 2 NO-LABEL
     loc-art AT ROW 13.75 COL 12 COLON-ALIGNED NO-LABEL
     loc-code AT ROW 13.75 COL 12.13 COLON-ALIGNED NO-LABEL
     loc-name AT ROW 13.75 COL 12.13 COLON-ALIGNED NO-LABEL
     b-mark AT ROW 15 COL 1
     b-add AT ROW 15 COL 4
     b-bc AT ROW 15 COL 14
     b-prt AT ROW 15 COL 24
     b-parts AT ROW 15 COL 34
     b-lkp AT ROW 15 COL 44
     b-chg AT ROW 15 COL 54
     b-del AT ROW 15 COL 64
     b-notes-line AT ROW 15 COL 74
     br-dtl AT ROW 16 COL 1
     sum-base AT ROW 5.75 COL 47.5 COLON-ALIGNED
     sum-rubl AT ROW 5.75 COL 65 COLON-ALIGNED NO-LABEL
     pay-type.obj-name AT ROW 6.88 COL 13.13 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 15 BY 1
          FGCOLOR 4
     t-doc.VAT-base AT ROW 7.5 COL 47.5 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 17 BY .67
     t-doc.VAT-rubl AT ROW 7.5 COL 65 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 20 BY .67
     wrkr-name AT ROW 8.13 COL 17.25 COLON-ALIGNED NO-LABEL
     fact-base AT ROW 8.13 COL 47.5 COLON-ALIGNED
     fact-rubl AT ROW 8.13 COL 65 COLON-ALIGNED NO-LABEL
     TEXT-RUBL AT ROW 8.79 COL 65.5 COLON-ALIGNED NO-LABEL
     agnt-name AT ROW 9.13 COL 17.25 COLON-ALIGNED NO-LABEL
     t-doc.tot-cli AT ROW 9.58 COL 47.5 COLON-ALIGNED
          LABEL "Счет"
           VIEW-AS TEXT
          SIZE 17 BY .67
     pay-rubl AT ROW 9.58 COL 65.13 COLON-ALIGNED NO-LABEL
     boss-name AT ROW 10.13 COL 17.25 COLON-ALIGNED NO-LABEL
     b-marks AT ROW 15 COL 84 WIDGET-ID 10
     t-doc.reason-code AT ROW 12.75 COL 12 COLON-ALIGNED
          LABEL "Основание" FORMAT ">>>>"
           VIEW-AS TEXT
          SIZE 3.38 BY .67
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .
DEFINE FRAME d-out-doc
     rsn-name AT ROW 12.83 COL 19 COLON-ALIGNED NO-LABEL
     flora-PS AT ROW 24.75 COL 1.5 NO-LABEL
     "Тип приобретения" VIEW-AS TEXT
          SIZE 16 BY .67 AT ROW 5.75 COL 88.63
          FGCOLOR 4
     "Баз.в." VIEW-AS TEXT
          SIZE 6.5 BY .79 AT ROW 8.79 COL 51
          BGCOLOR 3 FGCOLOR 15
     rect-tot AT ROW 5.5 COL 41
     rect-prc AT ROW 5.5 COL 88
     g-image AT ROW 10.75 COL 87.25
     SPACE(0.49) SKIP(10.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>".
ASSIGN
 FRAME d-out-doc:SCROLLABLE = FALSE
 FRAME d-out-doc:HIDDEN     = TRUE
 FRAME d-out-doc:SENSITIVE  = FALSE.
ASSIGN
 b-marks:POPUP-MENU IN FRAME d-out-doc = MENU m-marks:HANDLE.
ASSIGN
 b-marks:MENU-MOUSE = 1.
ASSIGN
       b-revis:HIDDEN IN FRAME d-out-doc           = TRUE.
ON MOUSE-SELECT-DBLCLICK OF g-image IN FRAME d-out-doc
DO:
  RUN ref/imagelist.w (PARPARENTPROC, "":U, ub.goods.gds-code,'ПРОСМОТР':U).
END.
ON WINDOW-CLOSE OF FRAME d-out-doc
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME d-out-doc
DO:
run local-add in this-procedure no-error.
if error-status :error then do:
  message "Ошибка при добавлении." skip
          return-value
  view-as alert-box error.
  return no-apply.
end.
run ui-on ("enable":u).
apply "entry" to b-add in frame d-out-doc.
END.
on choose of menu-item m-print-1 in menu m-print do:
  if not available t-doc then return .
  define variable v-user-action       as character    no-undo.
  define variable v-printed           as logical      no-undo.
  run rep/tick-doc.p (parparentproc , recid(t-doc), 'trn' , 1 , no, no ) .
end.
on choose of menu-item m-print-3 in menu m-print do:
  if not available t-doc then return .
  define variable v-user-action       as character    no-undo.
  define variable v-printed           as logical      no-undo.
  run rep/mbb-doc.p (parparentproc , recid(t-doc), 'trn'  ) no-error .
  if error-status :error then message
    error-status :get-message(1) skip
    return-value skip
    "Вывод в список кодов"
    view-as alert-box error
  .
end.
ON CHOOSE OF MENU-ITEM m_add-marks
  DO:
    define buffer buf_marking-lines for ub.marking-lines .
    define buffer pri_marking-lines for ub.marking-lines .
    define buffer buf_marking       for ub.marking .
    define buffer buf_goods         for ub.goods .
    define buffer buf_doc-line      for ub.doc-line .
    define buffer buf_gds-dtl       for ub.gds-dtl .
    define buffer buf_parts         for ub.parts .
    define buffer bf_parts          for ub.parts .
    define buffer cpl_gds-dtl       for ub.gds-dtl .
    define buffer pri_trn-doc       for ub.trn-doc .
    define variable mark       as character no-undo .
    define variable ii         as integer   no-undo .
    define variable jj         as integer   no-undo .
    define variable v-GTIN     as character no-undo .
    define variable v-gds-code as integer   no-undo .
    define variable ungroup    as logical   no-undo .
    define variable v-message  as character no-undo .
    define variable vIsExemplarGoods as logical no-undo .
    define variable varvalue        as character no-undo .
    define variable vartype         as character no-undo .
    define variable v-mark-weight as decimal no-undo .
    define variable v-isweighed as logical no-undo .
    define variable v-recid as recid no-undo .
    if lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
    and t-doc.ext-doc-type = 'ee':U
    and not v-is-return
    then do :
      if t-doc.out-code = ?
      or t-doc.out-code = ""
      or not can-find(pri_trn-doc no-lock where pri_trn-doc.doc-code = t-doc.out-code)
      then do :
        message "Сначала выберите корректный источник (ПН)" view-as alert-box .
        return no-apply.
      end.
    end .
    v-add = yes .
    if not avail ub.goods then
    do:
      message "Сначала добавьте товар в документ" view-as alert-box .
      return no-apply.
    end.
    v-recid = recid (ub.doc-line) .
    v-isweighed = WghProdVariable(t-doc.obj-type, t-doc.obj-code, ub.goods.gds-code) .
    run isExemplarGoods in this-procedure
       (t-doc.obj-type, t-doc.obj-code, ub.goods.gds-code, output vIsExemplarGoods).
    if not vIsExemplarGoods
    and not v-isweighed
    then do:
      message "Для выбранного товара в документе не требуется ввод марок." skip
              "Выполняется ручное добавление товара и ввод количества." view-as alert-box .
      return no-apply.
    end.
    do while v-add:
    run str/chs-alcmarks.w (
      input parparentproc,
      input t-doc.doc-code,
      input 'ДОБАВЛЕНИЕ':U,
      input ub.goods.gds-code,
      input "",
      output mark) no-error.
    if error-status :error or mark = "" or mark = ? then
    do:
      return no-apply.
    end.
    v-message = "" .
    find first marking where marking.mark begins mark
      no-lock no-error  .
    if available marking then
    do:
        find first buf_goods no-lock where recid(buf_goods) = recid(ub.goods) no-error .
        find first buf_doc-line exclusive-lock where buf_doc-line.doc-code = t-doc.doc-code
          and buf_doc-line.artic = buf_goods.artic and buf_doc-line.prod-code = buf_goods.prod-code
          and buf_doc-line.prod-type = buf_goods.prod-type no-error .
        if not available (buf_doc-line) then
        do:
        find first buf_marking-lines exclusive-lock where buf_marking-lines.out-code = 'free-zone':U and
          buf_marking-lines.gds-code = buf_goods.gds-code and buf_marking-lines.obj-code = t-doc.obj-code and buf_marking-lines.obj-type = t-doc.obj-type
          and buf_marking-lines.mark begins mark no-error .
        if available (buf_marking-lines) then
        do:
          if buf_marking-lines.doc-level > 1 then
          do:
              if tree:UnGroupDoc(buf_marking-lines.mark, buf_marking-lines.in-code, buf_marking-lines.out-code, buf_marking-lines.obj-code, buf_marking-lines.obj-type) then
              do:
            end.
          end.
        end.
          if lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
          and t-doc.ext-doc-type = 'ee':U
          then do :
            if not can-find (pri_marking-lines no-lock where pri_marking-lines.out-code = t-doc.out-code
                                                         and pri_marking-lines.mark begins mark)
            then do :
              message "Марка " mark " не найдена в документе-источнике (" t-doc.out-code ")" view-as alert-box .
              return no-apply.
            end .
            run str/out-add.p (parparentproc,
              recid(t-doc),
              ?,
              ?,
              recid(buf_goods),
              'ДОБАВЛЕНИЕ':U + chr(4) + "return",
              'scan-marks' + chr(3) + mark) no-error.
          end .
          else do :
            run str/out-add.p (parparentproc,
              recid(t-doc),
              ?,
              ?,
              recid(buf_goods),
              'ДОБАВЛЕНИЕ':U,
              'scan-marks' + chr(3) + mark) no-error.
          end .
        end.
        else
        do:
        find first buf_marking-lines exclusive-lock where buf_marking-lines.out-code = 'free-zone':U and
          buf_marking-lines.gds-code = buf_goods.gds-code and buf_marking-lines.obj-code = buf_doc-line.obj-code and buf_marking-lines.obj-type = buf_doc-line.obj-type
          and buf_marking-lines.mark begins mark no-error .
        if available (buf_marking-lines) then
        do:
          if buf_marking-lines.doc-level > 1 then
          do:
              if tree:UnGroupDoc(buf_marking-lines.mark, buf_marking-lines.in-code, buf_marking-lines.out-code, buf_marking-lines.obj-code, buf_marking-lines.obj-type) then
              do:
            end.
          end.
       end.
       else do:
         v-message = "У марки нет свободной зоны" .
       end.
        find first cpl_gds-dtl exclusive-lock where cpl_gds-dtl.doc-code = buf_doc-line.doc-code
          and cpl_gds-dtl.artic = buf_doc-line.artic and buf_doc-line.prod-code = cpl_gds-dtl.prod-code
          and buf_doc-line.prod-type = cpl_gds-dtl.prod-type no-error.
          if lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
          and t-doc.ext-doc-type = 'ee':U
          then do :
            run str/out-add.p
              ( input parparentproc
              ,input recid(t-doc)
              ,input recid(buf_doc-line)
              ,input recid(cpl_gds-dtl)
              ,input recid (buf_goods)
              ,input 'ИЗМЕНЕНИЕ':U + chr(4) + "return"
              ,input 'scan-marks' + chr(3) + mark)
              no-error.
          end .
          else do :
            run str/out-add.p
              ( input parparentproc
              ,input recid(t-doc)
              ,input recid(buf_doc-line)
              ,input recid(cpl_gds-dtl)
              ,input recid (buf_goods)
              ,input 'ИЗМЕНЕНИЕ':U
              ,input 'scan-marks' + chr(3) + mark)
              no-error.
          end .
        end.
    end.
    run ui-on in this-procedure ( input "line" ).
    reposition br-dtl to recid v-recid no-error.
    end.
  END.
ON CHOOSE OF MENU-ITEM m_lookup-marks
  DO:
    define buffer bf_doc-line for ub.doc-line .
    define buffer bf_goods    for ub.goods.
    define variable par-alcohol as character no-undo .
    define variable par-type    as character no-undo .
    define variable p-alcohol   as logical   no-undo .
    define variable v-type      as integer   no-undo .
    define variable v-fact-qnty as decimal   no-undo .
    define variable v-fact-part as decimal   no-undo .
    define variable vGtin       as character no-undo .
    define variable vGtinQnty   as integer   no-undo .
    define variable v-mark-weight as decimal no-undo .
    define variable v-isweighed as logical   no-undo .
    define buffer buf_doc-line for ub.doc-line.
    define buffer buf_gds-dtl  for ub.gds-dtl.
    define buffer buf_parts    for ub.parts.
    if t-doc.ext-doc-type = 'rv':U or t-doc.ext-doc-type = 'ev':U then v-type = 0. else v-type = 2 .
    for each bf_doc-line no-lock where bf_doc-line.doc-code = t-doc.doc-code :
      find first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic
        and bf_goods.prod-type = bf_doc-line.prod-type
        and bf_goods.prod-code = bf_doc-line.prod-code
        no-error .
      run gds-attr-value(
        bf_goods.gds-code,
        'alcohol-prod':U,
        output par-alcohol,
        output par-type
        ).
      if par-alcohol = "yes" then p-alcohol = yes .
    end.
    if p-alcohol then
    do:
      run bge/egais-control-marks.w (input parparentproc).
    end.
    else
    do:
      if available (t-doc) then
      do:
        for each ub.marking-lines no-lock where
          ub.marking-lines.obj-type = t-doc.obj-type
          and ub.marking-lines.obj-code = t-doc.obj-code
          and ub.marking-lines.out-code = t-doc.doc-code
          and ub.marking-lines.gds-code = ub.goods.gds-code:
            find first ub.marking no-lock where ub.marking.mark begins ub.marking-lines.mark and ub.marking.sts <> ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB no-error.
            if available (ub.marking)
              then
            do:
              find first tt-marking-lines no-lock where
                         tt-marking-lines.mark = ub.marking-lines.mark
                   no-error.
              if not avail tt-marking-lines or
                 ub.marking.unit-ext <> "unit" then
              do:
                  if ub.marking.box-qnty = 0 then
                  do:
                    vGtin     = getGtinByDM(ub.marking.mark) .
                    vGtinQnty = getQntyCodeByGtin(vGtin).
                  end.
                  else
                    vGtinQnty = ub.marking.box-qnty.
                  create tt-marking-lines.
                  buffer-copy ub.marking-lines to tt-marking-lines.
                  tt-marking-lines.sts = ub.marking.sts.
                  tt-marking-lines.stts = objSrv:Env:Marking:Sts:Mark:GetLabel(ub.marking.sts).
                  tt-marking-lines.sts-utd = ub.marking-lines.sts.
                  tt-marking-lines.stts-utd = objSrv:Env:Marking:Sts:Mark:GetLabel(ub.marking-lines.sts).
                  tt-marking-lines.box-qnty = vGtinQnty .
                  tt-marking-lines.unit = ub.marking.unit .
                  tt-marking-lines.unit-ext = ub.marking.unit-ext .
                  tt-marking-lines.doc-level = ub.marking-lines.doc-level.
                  tt-marking-lines.mark-parent = ub.marking.mark-parent.
              end.
            end.
        end.
      end.
      if available (tt-marking-lines) then
      do:
        run str/mark_browse.w (input parparentproc,
          input-output table tt-marking-lines by-reference,
          input if t-doc.ext-doc-type = 'iv':U then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U,
          input "Марки по: " + t-doc.doc-code + chr(4) + t-doc.ext-doc-type,
          input v-type,
          input ""
          )  .
          if pardoc-mode <> 'ПРОСМОТР':U and t-doc.ext-doc-type = 'iv':U then
          do:
             v-isweighed = WghProdVariable(t-doc.obj-type, t-doc.obj-code, ub.goods.gds-code) .
             for each buf_parts exclusive-lock where
                      buf_parts.artic = ub.goods.artic
                  and buf_parts.prod-type = ub.goods.prod-type
                  and buf_parts.prod-code = ub.goods.prod-code
                  and buf_parts.obj-type = t-doc.obj-type
                  and buf_parts.obj-code = t-doc.obj-code
                  and buf_parts.out-code = t-doc.doc-code
                 :
               v-fact-part = 0.
               for each tt-marking-lines no-lock where
                        tt-marking-lines.doc-level = 1
                    and tt-marking-lines.in-code = buf_parts.in-code
                    and tt-marking-lines.out-code = buf_parts.out-code
                    and tt-marking-lines.part-code = buf_parts.part-code
                    and tt-marking-lines.prt-code = buf_parts.prt-code
               :
                   if tt-marking-lines.sts-utd <> objSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB and
                      tt-marking-lines.sts-utd <> objSrv:Env:Marking:Sts:Mark:DeliveryControl:KeyIntDB
                   then do :
                     if v-isweighed
                     then do :
                       v-fact-part = v-fact-part + MarkWeight(tt-marking-lines.mark) .
                     end .
                     else do :
                       v-fact-part = v-fact-part + tt-marking-lines.box-qnty.
                     end .
                   end .
               end.
               if buf_parts.fact-qnty <> v-fact-part then
                 buf_parts.fact-qnty = v-fact-part.
               v-fact-qnty = v-fact-qnty + v-fact-part.
             end.
             if ub.gds-dtl.fact-qnty <> v-fact-qnty then
             do:
               find first buf_doc-line where rowid(buf_doc-line) = rowid(ub.doc-line) exclusive-lock.
               find first buf_gds-dtl where rowid(buf_gds-dtl) = rowid(ub.gds-dtl) exclusive-lock.
               assign
                 buf_doc-line.fact-qnty = v-fact-qnty
                 buf_gds-dtl.fact-qnty  = v-fact-qnty
               .
               br-dtl:refresh() in frame d-out-doc.
               for each bf_doc-line no-lock where
                        bf_doc-line.obj-type = t-doc.obj-type
                    and bf_doc-line.obj-code = t-doc.obj-code
                    and bf_doc-line.doc-code = t-doc.doc-code
               :
                 accum bf_doc-line.fact-qnty (total).
               end.
               if t-doc.fact-qnty <> accum total bf_doc-line.fact-qnty then
               do:
                 t-doc.fact-qnty = accum total bf_doc-line.fact-qnty.
                 display t-doc.fact-qnty with frame d-out-doc.
               end.
             end.
          end.
      end.
      else
      do:
        message "Нет марок для просмотра"
          view-as alert-box.
      end.
      for each tt-marking-lines:
        delete tt-marking-lines.
      end.
    end.
  END.
ON CHOOSE OF MENU-ITEM m_no-marks
  DO:
    define buffer bf_doc-line for ub.doc-line .
    define buffer bf_goods    for ub.goods.
    define buffer buf_marking-lines for ub.marking-lines .
    define buffer buf_marking       for ub.marking .
    define buffer buf_goods         for ub.goods .
    define buffer buf_doc-line      for ub.doc-line .
    define buffer buf_gds-dtl       for ub.gds-dtl .
    define buffer buf_parts         for ub.parts .
    define buffer bf_parts          for ub.parts .
    define buffer cpl_gds-dtl       for ub.gds-dtl .
    define variable mark       as character no-undo .
    define variable jj         as integer   no-undo .
    define variable v-GTIN     as character no-undo .
    define variable v-gds-code as integer   no-undo .
    define variable ungroup    as logical   no-undo .
    define variable v-message  as character no-undo .
    define variable qnty-mark-doc as integer no-undo .
    define variable qnty-mark-fact as integer no-undo .
    define variable ii as integer no-undo .
    define variable v-ok as logical no-undo .
      if available (t-doc) then
      do:
       for each bf_doc-line no-lock where bf_doc-line.doc-code = t-doc.doc-code,
        first bf_goods no-lock where bf_goods.artic = bf_doc-line.artic
                                 and bf_goods.prod-code = bf_doc-line.prod-code
                                 and bf_goods.prod-type = bf_doc-line.prod-type:
         qnty-mark-doc = 0 .
         qnty-mark-fact = 0 .
        for each ub.marking-lines no-lock where
          ub.marking-lines.obj-type = t-doc.obj-type
          and ub.marking-lines.obj-code = t-doc.obj-code
          and ub.marking-lines.out-code = t-doc.doc-code
          and ub.marking-lines.gds-code = bf_goods.gds-code
          and ub.marking-lines.mark begins 'tech_':U:
          find first ub.marking no-lock where ub.marking.mark = ub.marking-lines.mark and ub.marking.unit-ext = "UNIT" no-error.
          if available (ub.marking)
            then
          do:
            qnty-mark-doc = qnty-mark-doc + 1 .
            if ub.marking-lines.sts = Marking:Checked_:KeyIntDB then qnty-mark-fact = qnty-mark-fact + 1 .
          end.
        end.
        if qnty-mark-doc > 0 then do:
        create tt-tech-mark.
        assign
          tt-tech-mark.doc-code  = bf_doc-line.doc-code
          tt-tech-mark.line-num  = bf_doc-line.line-num
          tt-tech-mark.gds-code  = bf_goods.gds-code
          tt-tech-mark.gds-name  = bf_goods.gds-name
          tt-tech-mark.qnty-doc  = qnty-mark-doc
          tt-tech-mark.qnty-fact = qnty-mark-fact
          .
          end.
      end.
      if available (tt-tech-mark) then
      do:
        run str/no_mark.w (input parparentproc,
          input-output table tt-tech-mark by-reference,
          input pardoc-mode,
          output v-ok
          )
          .
if v-ok then do:
for each ub.marking-lines exclusive-lock where
          ub.marking-lines.obj-type = t-doc.obj-type
          and ub.marking-lines.obj-code = t-doc.obj-code
          and ub.marking-lines.out-code = t-doc.doc-code
          and ub.marking-lines.mark begins 'tech_':U:
          ub.marking-lines.sts = Marking:PendingVerification:KeyIntDB .
end.
for each tt-tech-mark:
ii = 0 .
for each ub.marking-lines exclusive-lock where
          ub.marking-lines.obj-type = t-doc.obj-type
          and ub.marking-lines.obj-code = t-doc.obj-code
          and ub.marking-lines.out-code = tt-tech-mark.doc-code
          and ub.marking-lines.gds-code = tt-tech-mark.gds-code
          and ub.marking-lines.mark begins 'tech_':U:
          ii = ii + 1 .
          if ii > tt-tech-mark.qnty-fact then leave .
          ub.marking-lines.sts = Marking:Checked_:KeyIntDB .
end.
end.
    ii = 0 .
        for each buf_doc-line exclusive-lock where buf_doc-line.doc-code = t-doc.doc-code,
          first buf_gds-dtl exclusive-lock where buf_gds-dtl.doc-code = buf_doc-line.doc-code and
                                                 buf_gds-dtl.artic = buf_doc-line.artic and
                                                 buf_gds-dtl.prod-code = buf_doc-line.prod-code and
                                                 buf_gds-dtl.prod-type = buf_doc-line.prod-type:
          jj = 0 .
          find first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and
                                             buf_goods.prod-code = buf_doc-line.prod-code and
                                             buf_goods.prod-type = buf_doc-line.prod-type no-error .
          for each buf_marking-lines exclusive-lock where buf_marking-lines.obj-code = buf_doc-line.obj-code and
                                                          buf_marking-lines.obj-type = buf_doc-line.obj-type and
                                                          buf_marking-lines.out-code = buf_doc-line.doc-code and
                                                          buf_marking-lines.gds-code = buf_goods.gds-code,
            first buf_marking no-lock where buf_marking.mark = buf_marking-lines.mark and
                                            buf_marking.obj-code = buf_marking-lines.obj-code and
                                            buf_marking.obj-type = buf_marking-lines.obj-type and buf_marking.unit-ext = "UNIT":
          if buf_marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB then do:
          jj = jj + 1 .
          ii = ii + 1 .
          end.
          buf_doc-line.fact-qnty = jj .
          buf_gds-dtl.fact-qnty = buf_doc-line.fact-qnty .
          for first buf_parts exclusive-lock where buf_parts.out-code = buf_marking-lines.out-code and
                                                   buf_parts.artic = buf_doc-line.artic and
                                                   buf_parts.prod-code = buf_doc-line.prod-code and
                                                   buf_parts.prod-type = buf_doc-line.prod-type and
                                                   buf_parts.obj-code = buf_marking-lines.obj-code and
                                                   buf_parts.obj-type = buf_marking-lines.obj-type and
                                                   buf_parts.part-code = buf_marking-lines.part-code and
                                                   buf_parts.in-code = buf_marking-lines.in-code :
            buf_parts.fact-qnty = buf_doc-line.fact-qnty .
          end.
          end.
        t-doc.fact-qnty = ii .
        end.
 end.
      end.
      else
      do:
        message "Нет технических марок"
          view-as alert-box.
      end.
    end.
    empty temp-table tt-tech-mark .
    run ui-on in this-procedure ( input "line" ).
  END.
ON CHOOSE OF b-arch IN FRAME d-out-doc
DO:
define variable vss-include-info47 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
  if varlog <> yes
  then do:
    return no-apply.
  end.
  run str/docsuppn.w
    (input parparentproc
    ,input recid( t-doc )
    ).
END.
ON CHOOSE OF b-attr IN FRAME d-out-doc
DO:
    run init-attr-general in this-procedure .
    if t-doc.status_ <> 'факт':U then do:
      run str/doc-attr.w (input ParParentproc, input "b-lkp,b-chg,b-add,b-del", input t-doc.doc-code, input table tt-upd-attr) no-error.
    end.
    else do:
      run str/doc-attr.w (input ParParentproc, input "b-lkp,b-chg,b-add", input t-doc.doc-code, input table tt-upd-attr) no-error.
    end.
END.
ON CHOOSE OF b-bc IN FRAME d-out-doc
DO:
  run check-rate no-error.
if error-status :error then return no-apply.
if t-doc.doc-type = 'при':U and
   t-doc.internal = yes       and
   t-doc.status_  = 'накл':U   and
   t-doc.flag_                then do:
   if avail ub.bar-code then
   do:
     run checkTypeByBarCode in this-procedure (ub.bar-code.b-code, t-doc.ext-doc-type) no-error.
     if error-status:error then return no-apply.
   end.
   run fact-bc in this-procedure (t-doc.doc-code)  no-error.
   if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка при редактировании фактических количеств." skip
       return-value skip
       view-as alert-box error.
     undo, return no-apply.
   end.
end.
else do:
  assign
    v-cond = 'свободно':U
    varline-mode = 'ИЗМЕНЕНИЕ':U
    prt-rec = ?
    varlns-cnt = 1
    add-sens = b-add:sensitive
    b-c = 0
    gds-rec = ?.
  do while b-c <> ?:
     run str/chs-bc.w (parparentproc, "Строка накладной № " + t-doc.doc-code, add-sens, no, yes, output b-c-char, output rate, output ret-mode, input-output add-scan, input-output bar-str).
     b-c = integer(b-c-char).
     if b-c <> ? then do:
        run checkTypeByBarCode in this-procedure (b-c, t-doc.ext-doc-type) no-error.
        if error-status:error then next.
        do transaction on error undo, return no-apply :
           if t-doc.flag_ and t-doc.status_ = 'разрешен':U then do:
              run find-gds no-error.
              if error-status :error then undo, return no-apply.
           end.
           if add-scan and t-doc.flag_ and t-doc.status_ = 'разрешен':U then do:
              run add-rate no-error.
              if error-status :error then undo, return no-apply.
define buffer out-dtl for ub.gds-dtl.
if available ub.gds-dtl then do:
    prt-rec = recid(ub.gds-dtl).
    if dec(ub.gds-dtl.fact-qnty:screen-value in browse br-dtl) = ?
    then do:
      message "Не указано количество.".
      disp ub.gds-dtl.fact-qnty with browse br-dtl.
      return no-apply.
    end.
    if (can-do ('при,возврат':U, t-doc.doc-type)
       and t-doc.internal
       and ( ub.gds-prt.upper-code = ub.goods.prt-root  or
         can-find (out-dtl where out-dtl.doc-code = t-doc.out-code and
                                              out-dtl.artic = ub.gds-dtl.artic and
                                              out-dtl.prod-type = ub.gds-dtl.prod-type and
                                              out-dtl.prod-code = ub.gds-dtl.prod-code and
                                              out-dtl.prt-code = ub.gds-dtl.prt-code no-lock))
        or not can-do ('при,возврат':U, t-doc.doc-type)
        or (t-doc.doc-type = 'возврат':U and not t-doc.internal)
        )
        and input browse br-dtl ub.gds-dtl.fact-qnty > ub.gds-dtl.doc-qnty then do:
      message "Фактическое количество товара не может быть больше количества по накладной.".
      disp ub.gds-dtl.fact-qnty with browse br-dtl.
      return no-apply.
    end.
    find ub.units where ub.units.unit-name = ub.goods.unit-base no-lock.
    if lookup('сер':U, ub.units.type) > 0 then do:
       message "В серийном товаре нельзя редактировать количество".
       disp ub.gds-dtl.fact-qnty with browse br-dtl.
       return no-apply.
    end.
    find ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code
                       and ub.doc-line.prod-code = ub.gds-dtl.prod-code
                       and ub.doc-line.prod-type = ub.gds-dtl.prod-type
                       and ub.doc-line.artic         = ub.gds-dtl.artic no-lock no-error.
    find ub.goods where ub.goods.prod-code = ub.gds-dtl.prod-code
               and ub.goods.prod-type = ub.gds-dtl.prod-type
               and ub.goods.artic     = ub.gds-dtl.artic no-lock.
    run str/out-add.p (parparentproc,
                   recid(t-doc),
                   recid(ub.doc-line),
                   recid(ub.gds-dtl),
                   recid(ub.goods),
                   "ch-fact-qnty",
                   string(input browse br-dtl ub.gds-dtl.fact-qnty)) no-error.
    if error-status:error then return no-apply.
    if query br-dtl:GET-BUFFER-HANDLE (1):NAME = "gds-dtl" then
        prt-rec = recid(ub.gds-dtl).
    else
        prt-rec = recid(ub.doc-line).
    run ui-on("line").
    reposition br-dtl to recid prt-rec.
end.
           end.
           else do:
              assign
                varline-mode = 'ИЗМЕНЕНИЕ':U
                prt-rec   = ?
                line-rec  = ?.
              run str/out-add.p (parparentproc,
                             recid(t-doc),
                             ?,
                             ?,
                             ?,
                             "b-c",
                             string(b-c)             + "," +
                             string(rate)            + "," +
                             ret-mode                + "," +
                             string(b-add:sensitive) + "," +
                             string(add-scan)).
           end.
        end.
     end.
  end.
end.
run ui-on ("line").
if prt-rec <> ? then
  reposition br-dtl to recid prt-rec no-error.
return no-apply.
END.
ON CHOOSE OF b-chg IN FRAME d-out-doc
DO:
define buffer bin_parts for ub.parts .
define buffer bout_parts for ub.parts .
define buffer buf_gen-attr for ub.gen-attr .
define variable v-recid as recid no-undo .
  if not available ub.gds-dtl then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  v-recid = recid (ub.doc-line) .
  run check-rate in this-procedure
    no-error.
  if error-status :error then do:
    return no-apply.
  end.
  assign
    varline-mode = 'ИЗМЕНЕНИЕ':U
  .
  run check-inv in this-procedure
    no-error.
  if error-status :error then do:
    return no-apply.
  end.
  find first ub.doc-line
    where ub.doc-line.doc-code  = ub.gds-dtl.doc-code
      and ub.doc-line.artic     = ub.gds-dtl.artic
      and ub.doc-line.prod-type = ub.gds-dtl.prod-type
      and ub.doc-line.prod-code = ub.gds-dtl.prod-code
    .
  if v-is-return
  then do :
    for first bout_parts no-lock where bout_parts.obj-type  = doc-line.obj-type
                                   and bout_parts.obj-code  = doc-line.obj-code
                                   and bout_parts.artic     = doc-line.artic
                                   and bout_parts.prod-type = doc-line.prod-type
                                   and bout_parts.prod-code = doc-line.prod-code
                                   and bout_parts.out-code  = doc-line.doc-code
    :
      find first buf_gen-attr no-lock where buf_gen-attr.table-name = 'parts':U
                                        and buf_gen-attr.p-key      =  "parts"                + chr(3) +
 bout_parts.obj-type           + chr(3) +
 string(bout_parts.obj-code)   + chr(3) +
 bout_parts.artic              + chr(3) +
 bout_parts.prod-type          + chr(3) +
 string(bout_parts.prod-code)  + chr(3) +
 bout_parts.In-code            + chr(3) +
 bout_parts.Out-code           + chr(3) +
 bout_parts.part-Code          + chr(3) +
 string(bout_parts.prt-code)
                                        and buf_gen-attr.attr-code  = "in-part-key"
                                        no-error .
      if available buf_gen-attr
      then do :
        find first bin_parts no-lock where bin_parts.obj-type  = entry(2, buf_gen-attr.attr-value, chr(3))
                                       and bin_parts.obj-code  = integer(entry(3, buf_gen-attr.attr-value, chr(3)))
                                       and bin_parts.artic     = entry(4, buf_gen-attr.attr-value, chr(3))
                                       and bin_parts.prod-type = entry(5, buf_gen-attr.attr-value, chr(3))
                                       and bin_parts.prod-code = integer(entry(6, buf_gen-attr.attr-value, chr(3)))
                                       and bin_parts.in-code   = entry(7, buf_gen-attr.attr-value, chr(3))
                                       and bin_parts.out-code  = entry(8, buf_gen-attr.attr-value, chr(3))
                                       and bin_parts.part-code = entry(9, buf_gen-attr.attr-value, chr(3))
                                       no-error .
      end .
    end .
    if available bin_parts
    then do :
      run str/out-add.p
        ( input parparentproc
        ,input recid(t-doc)
        ,input recid(doc-line)
        ,input recid(gds-dtl)
        ,input recid (goods)
        ,input varline-mode + chr(4) + "return=" + string(recid(bin_parts))
        ,input ?
        ) no-error.
      if error-status :error then
      do:
        return no-apply.
      end.
    end .
    else do :
      run str/out-add.p
       ( input parparentproc
        ,input recid(t-doc)
        ,input recid(doc-line)
        ,input recid(gds-dtl)
        ,input recid (goods)
        ,input varline-mode + chr(4) + "return"
        ,input ?
        ) no-error.
      if error-status :error then
      do:
        return no-apply.
      end.
    end .
  end .
  else
  if (lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
  and t-doc.ext-doc-type = 'ee':U)
  then do :
    run str/out-add.p
      ( input parparentproc
      ,input recid(t-doc)
      ,input recid(ub.doc-line)
      ,input recid(ub.gds-dtl)
      ,input recid (ub.goods)
      ,input varline-mode + chr(4) + "return"
      ,input ?
      ) no-error.
    if error-status :error then do:
      return no-apply.
    end.
  end.
  else do :
    run str/out-add.p
      ( input parparentproc
      ,input recid(t-doc)
      ,input recid(ub.doc-line)
      ,input recid(ub.gds-dtl)
      ,input recid (ub.goods)
      ,input varline-mode
      ,input ?
      ) no-error.
    if error-status :error then do:
      return no-apply.
    end.
  end.
  if t-doc.ext-doc-type = 'ev':U
  then do :
    run local-cur in this-procedure (input 4) no-error.
    if error-status :error then return .
  end .
  run ui-on in this-procedure
    ( input "line"
    ).
  apply "entry" to br-dtl in frame d-out-doc .
  reposition br-dtl to recid v-recid no-error.
END.
ON CHOOSE OF b-cnt IN FRAME d-out-doc
DO:
define variable vss-include-info48 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
  if varlog <> yes then do: return no-apply. end.
  run str/scntdoc.w ( input t-doc.doc-code, input ( v-cntxt-db-num = ub.sysconf.firm-db-num ) ).
END.
ON CHOOSE OF b-contr-lkp IN FRAME d-out-doc
DO:
 define buffer buf_contract for ub.contract  .
 if t-doc.contract-code <> 0 then do:
   if is-doc-hold then do:
      find first buf_contract no-lock where
            buf_contract.contract-code = t-doc.contract-code no-error .
   end.
   else do:
      find first buf_contract no-lock where
            buf_contract.host-code     = t-doc.host-code   and
            buf_contract.contract-code = t-doc.contract-code no-error .
   end.
      if available buf_contract then do:
          run str/sh-contr.p
              ( input parParentProc ,
                input recid(buf_contract)
              ).
      end.
  end.
END.
ON CHOOSE OF b-del IN FRAME d-out-doc
DO:
  run local-del no-error.
if error-status :error then return no-apply.
run ui-on ("enable":u).
apply "entry" to br-dtl in frame d-out-doc .
prt-rec = del-rec.
if prt-rec <> ? then reposition br-dtl to recid prt-rec no-error.
IF mImagePh THEN
DO:
    DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
if AVAILABLE goods then do:
    RUN gds-attr-value ( goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
    RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, goods.gds-code, OUTPUT vImageList).
    vCh = ENTRY (1, vImageList, ",":U).
    g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
end.
else
      ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
END.
ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
apply "value-changed" to br-dtl in frame d-out-doc.
END.
ON CHOOSE OF b-dopinf IN FRAME d-out-doc
DO:
  run init-attr-flora .
  if pardoc-mode <> 'ПРОСМОТР':U then do:
     run str/fl-atu.w (input 'ИЗМЕНЕНИЕ':U, input t-doc.doc-code) no-error.
  end.
  else do:
     run str/fl-atu.w (input 'ПРОСМОТР':U, input t-doc.doc-code) no-error.
  end.
END.
ON CHOOSE OF b-lkp IN FRAME d-out-doc
DO:
  if not available ub.gds-dtl then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.
run local-lookup.
END.
ON CHOOSE OF b-mark IN FRAME d-out-doc
DO:
  run mark-list.
END.
ON CHOOSE OF b-notes-line IN FRAME d-out-doc
DO:
  define variable v-ps as character no-undo.
define variable  p-type     as character no-undo .
if not available t-doc then return .
if not available ub.goods then return .
    run lineattr-value (
      input   t-doc.doc-code ,
      input   ub.goods.gds-code ,
      input   'flora_ps':U,
      output  v-ps ,
      output  p-type      )
    .
run gbl/d-prompt.w (
        'title=':u + "Изменение атрибутов строки документа" + '\':u
      + 'text1=':u + "Примечание по позиции: " + ub.goods.gds-name + '\':u
      + 'format=' + "x(1000)" + '\':u
      + 'type=' + "edit" + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=60\':u
      + 'fillin_height=5\':u
      + 'max-chars=1000\':u
      + 'readonly=' + (if pardoc-mode = 'ИЗМЕНЕНИЕ':U then 'no':u else 'yes':u) + '\':u
      , input-output v-ps
      ) no-error.
  if caps(return-value) = "TRUE"  then do:
  if pardoc-mode = 'ИЗМЕНЕНИЕ':U then do:
    if not error-status :error then do:
      run  lineattr-write (
        input   t-doc.doc-code ,
        input   ub.goods.gds-code ,
        input   'flora_ps':U,
        input   v-ps )
      .
    end.
  end.
end.
apply "value-changed" to br-dtl in frame d-out-doc.
END.
ON CHOOSE OF b-parts IN FRAME d-out-doc
DO:
    define variable varloc-prt-rec as recid no-undo.
  if not available ub.doc-line then do:
    message "Неправильный выбор строки - партии недоступны." view-as alert-box.
    return no-apply.
  end.
  assign
    varloc-prt-rec = recid( ub.doc-line )
  .
  run local-parts in this-procedure no-error.
  if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       ""
       view-as alert-box error
     .
     return no-apply.
  end.
  if t-doc.ext-doc-type = 'ev':U
  then do :
    run local-cur in this-procedure (input 4) no-error.
    if error-status :error then return .
  end .
  run ui-on in this-procedure ( input "line" ) .
  apply "ENTRY":U to br-dtl in frame d-out-doc.
  reposition br-dtl to recid varloc-prt-rec no-error .
  if error-status :error then do: reposition br-dtl to row 1 no-error. end.
END.
ON CHOOSE OF b-prt IN FRAME d-out-doc
DO:
  if not available ub.gds-dtl then do:
  message "Неправильный выбор строки - шкала недоступна.".
  return no-apply.
end.
if pardoc-mode <> 'ПРОСМОТР':U then do:
  run check-rate no-error.
  if error-status :error then return no-apply.
end.
run set-work-mode-prt no-error.
if error-status :error then return no-apply.
if pardoc-mode = 'ПРОСМОТР':U then do:
  find first ub.doc-line where ub.doc-line.doc-code  = ub.gds-dtl.doc-code  and
                            ub.doc-line.artic     = ub.gds-dtl.artic     and
                            ub.doc-line.prod-type = ub.gds-dtl.prod-type and
                            ub.doc-line.prod-code = ub.gds-dtl.prod-code no-lock.
end.
else do:
  find first ub.doc-line where ub.doc-line.doc-code  = ub.gds-dtl.doc-code  and
                            ub.doc-line.artic     = ub.gds-dtl.artic     and
                            ub.doc-line.prod-type = ub.gds-dtl.prod-type and
                            ub.doc-line.prod-code = ub.gds-dtl.prod-code .
end.
prt-rec = recid(ub.doc-line).
find first ub.goods where ub.goods.artic     = ub.gds-dtl.artic     and
                       ub.goods.prod-type = ub.gds-dtl.prod-type and
                       ub.goods.prod-code = ub.gds-dtl.prod-code no-lock.
if lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
and t-doc.ext-doc-type = 'ee':U
then do :
  run str/out-add.p (parparentproc,
                 recid(t-doc),
                 recid(ub.doc-line),
                 recid(ub.gds-dtl),
                 recid (ub.goods),
                 work-mode + chr(4) + "return",
                 ?) no-error.
  if error-status :error then return no-apply.
end.
else do :
  run str/out-add.p (parparentproc,
                 recid(t-doc),
                 recid(ub.doc-line),
                 recid(ub.gds-dtl),
                 recid (ub.goods),
                 work-mode,
                 ?) no-error.
  if error-status :error then return no-apply.
end.
if varprt-mode = 'ШКАЛА':U then run ui-on ("line").
apply "entry" to br-dtl in frame d-out-doc .
reposition br-dtl to recid prt-rec no-error.
END.
ON CHOOSE OF b-re-price IN FRAME d-out-doc
DO:
    if not available ub.gds-dtl then do:
    message "Неправильный выбор строки." view-as alert-box error.
    return no-apply.
  end.
  run proc-b-re-price in this-procedure .
END.
ON CHOOSE OF b-rsrv-doc-list IN FRAME d-out-doc
DO:
    define variable v-rsrv-doc-list      as character no-undo .
  define variable v-rsrv-doc-list-type as character no-undo .
  define variable v-new-rsrv-doc-list  as character no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'rsrv-doc-list':U ,
                       output v-rsrv-doc-list ,
                       output v-rsrv-doc-list-type )  .
  run str/doclsted.p
    (input  parparentproc
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  v-rsrv-doc-list
    ,input  'рас':U
    ,output v-new-rsrv-doc-list
    ) .
  if v-new-rsrv-doc-list = ''
  then do:
    define variable v-attr-delete as logical   no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-del in g#trdcalib (  input t-doc.doc-code ,
                        input 'rsrv-doc-list':U ,
                       output v-attr-delete )  .
  end.
  else do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'rsrv-doc-list':U ,
                       input v-new-rsrv-doc-list )  .
  end.
END.
ON row-display OF br-dtl IN FRAME d-out-doc
DO:
  run proc-row-display in this-procedure.
  run rowdisp .
END.
ON row-leave OF br-dtl IN FRAME d-out-doc
DO:
    define variable var_is-petrol as logical no-undo .
  define variable var_is-pieces as logical no-undo .
  if available ub.gds-dtl  and
     (decimal( ub.gds-dtl.doc-qnty :screen-value in browse br-dtl ) <> ub.gds-dtl.doc-qnty or
      decimal( ub.gds-dtl.fact-qnty :screen-value in browse br-dtl ) <> ub.gds-dtl.fact-qnty ) then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.gds-dtl.artic
  ,  input ub.gds-dtl.prod-type
  ,  input ub.gds-dtl.prod-code
  , output var_is-petrol
  , output var_is-pieces
  ) .
    if var_is-petrol = yes and
       var_is-pieces = no
    then do:
      if decimal( ub.gds-dtl.doc-qnty :screen-value in browse br-dtl ) <> ub.gds-dtl.doc-qnty
      then do:
        display ub.gds-dtl.doc-qnty with browse br-dtl .
        message substitute( 'В жидком топливе нельзя редактировать количество.&1'
                        , ( if b-chg :sensitive in frame d-out-doc
                            then substitute( '&1Воспользуйтесь кнопкой "&2".'
                                           , chr(10)
                                           , replace( b-chg :label in frame d-out-doc, "&", "":U )
                                           )
                            else '':U )
                        )
        view-as alert-box error .
      end.
      else do:
        if decimal( ub.gds-dtl.fact-qnty :screen-value in browse br-dtl ) <> ub.gds-dtl.fact-qnty
        then do:
          display ub.gds-dtl.fact-qnty with browse br-dtl .
          message substitute( 'В жидком топливе нельзя редактировать фактическое количество.&1'
                            , ( if b-chg :sensitive in frame d-out-doc
                                then substitute( '&1Воспользуйтесь кнопкой "&2".'
                                               , chr(10)
                                               , replace( b-chg :label in frame d-out-doc, "&", "":U )
                                               )
                                else '':U )
                            )
          view-as alert-box error .
        end.
      end.
      return no-apply.
    end.
    find first ub.goods no-lock where
               ub.goods.artic     = ub.gds-dtl.artic     and
               ub.goods.prod-type = ub.gds-dtl.prod-type and
               ub.goods.prod-code = ub.gds-dtl.prod-code .
    find first ub.units no-lock where ub.units.unit-name = ub.goods.unit-base .
    if decimal( ub.gds-dtl.doc-qnty :screen-value in browse br-dtl ) <> ub.gds-dtl.doc-qnty and
        lookup( '2ед':U, ub.units.type ) > 0 then do:
       message "Товар с двумя единицами измерения резервируется через партии." view-as alert-box.
       return no-apply.
    end.
    if decimal( ub.gds-dtl.doc-qnty  :screen-value in browse br-dtl ) <> ub.gds-dtl.doc-qnty  then do:
if available ub.gds-dtl then do:
    prt-rec = recid(ub.gds-dtl).
    if dec(ub.gds-dtl.doc-qnty:screen-value in browse br-dtl) = ?
       or dec(ub.gds-dtl.doc-qnty:screen-value in browse br-dtl) = 0
    then do:
      message "Не указано количество.".
      disp ub.gds-dtl.doc-qnty with browse br-dtl.
      return no-apply.
    end.
    find ub.units where ub.units.unit-name = ub.goods.unit-base no-lock.
    if lookup('сер':U, ub.units.type) > 0 then do:
       message "В серийном товаре нельзя редактировать количество".
       disp ub.gds-dtl.doc-qnty with browse br-dtl.
       return no-apply.
    end.
    find ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code
                       and ub.doc-line.prod-code = ub.gds-dtl.prod-code
                       and ub.doc-line.prod-type = ub.gds-dtl.prod-type
                       and ub.doc-line.artic         = ub.gds-dtl.artic no-lock no-error.
    find ub.goods where ub.goods.prod-code = ub.gds-dtl.prod-code
               and ub.goods.prod-type = ub.gds-dtl.prod-type
               and ub.goods.artic     = ub.gds-dtl.artic no-lock.
    run str/out-add.p (parparentproc,
                   recid(t-doc),
                   recid(ub.doc-line),
                   recid(ub.gds-dtl),
                   recid(ub.goods),
                   "ch-doc-qnty",
                   string(input browse br-dtl ub.gds-dtl.doc-qnty)) no-error.
    if error-status:error then return no-apply.
    if query br-dtl:GET-BUFFER-HANDLE (1):NAME = "gds-dtl" then
        prt-rec = recid(ub.gds-dtl).
    else
        prt-rec = recid(ub.doc-line).
    run ui-on("line").
    reposition br-dtl to recid prt-rec.
end.
      if v-is-ptrl = "yes":U then do:
        run inv-line_recalc-qty in this-procedure
          ( input ub.gds-dtl.doc-code
          ,input ub.gds-dtl.artic
          ,input ub.gds-dtl.prod-type
          ,input ub.gds-dtl.prod-code
          ,input false
          ,input decimal( ub.gds-dtl.doc-qnty  :screen-value in browse br-dtl )
          ,input decimal( ub.gds-dtl.fact-qnty :screen-value in browse br-dtl )
          ) no-error.
        if error-status :error then do: return no-apply. end.
      end.
    end.
    if decimal( ub.gds-dtl.fact-qnty :screen-value in browse br-dtl ) <> ub.gds-dtl.fact-qnty then do:
define buffer out-dtl for ub.gds-dtl.
if available ub.gds-dtl then do:
    prt-rec = recid(ub.gds-dtl).
    if dec(ub.gds-dtl.fact-qnty:screen-value in browse br-dtl) = ?
    then do:
      message "Не указано количество.".
      disp ub.gds-dtl.fact-qnty with browse br-dtl.
      return no-apply.
    end.
    if (can-do ('при,возврат':U, t-doc.doc-type)
       and t-doc.internal
       and ( ub.gds-prt.upper-code = ub.goods.prt-root  or
         can-find (out-dtl where out-dtl.doc-code = t-doc.out-code and
                                              out-dtl.artic = ub.gds-dtl.artic and
                                              out-dtl.prod-type = ub.gds-dtl.prod-type and
                                              out-dtl.prod-code = ub.gds-dtl.prod-code and
                                              out-dtl.prt-code = ub.gds-dtl.prt-code no-lock))
        or not can-do ('при,возврат':U, t-doc.doc-type)
        or (t-doc.doc-type = 'возврат':U and not t-doc.internal)
        )
        and input browse br-dtl ub.gds-dtl.fact-qnty > ub.gds-dtl.doc-qnty then do:
      message "Фактическое количество товара не может быть больше количества по накладной.".
      disp ub.gds-dtl.fact-qnty with browse br-dtl.
      return no-apply.
    end.
    find ub.units where ub.units.unit-name = ub.goods.unit-base no-lock.
    if lookup('сер':U, ub.units.type) > 0 then do:
       message "В серийном товаре нельзя редактировать количество".
       disp ub.gds-dtl.fact-qnty with browse br-dtl.
       return no-apply.
    end.
    find ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code
                       and ub.doc-line.prod-code = ub.gds-dtl.prod-code
                       and ub.doc-line.prod-type = ub.gds-dtl.prod-type
                       and ub.doc-line.artic         = ub.gds-dtl.artic no-lock no-error.
    find ub.goods where ub.goods.prod-code = ub.gds-dtl.prod-code
               and ub.goods.prod-type = ub.gds-dtl.prod-type
               and ub.goods.artic     = ub.gds-dtl.artic no-lock.
    run str/out-add.p (parparentproc,
                   recid(t-doc),
                   recid(ub.doc-line),
                   recid(ub.gds-dtl),
                   recid(ub.goods),
                   "ch-fact-qnty",
                   string(input browse br-dtl ub.gds-dtl.fact-qnty)) no-error.
    if error-status:error then return no-apply.
    if query br-dtl:GET-BUFFER-HANDLE (1):NAME = "gds-dtl" then
        prt-rec = recid(ub.gds-dtl).
    else
        prt-rec = recid(ub.doc-line).
    run ui-on("line").
    reposition br-dtl to recid prt-rec.
end.
      if v-is-ptrl = "yes":U then do:
        run inv-line_recalc-qty in this-procedure
          ( input ub.gds-dtl.doc-code
          ,input ub.gds-dtl.artic
          ,input ub.gds-dtl.prod-type
          ,input ub.gds-dtl.prod-code
          ,input true
          ,input decimal( ub.gds-dtl.doc-qnty  :screen-value in browse br-dtl )
          ,input decimal( ub.gds-dtl.fact-qnty :screen-value in browse br-dtl )
          ) no-error.
        if error-status :error then do: return no-apply. end.
      end.
    end.
  end.
END.
ON LEAVE OF ub.gds-dtl.doc-qnty IN BROWSE br-dtl
DO:
  define variable vIsExemplarGoods as logical no-undo .
  define variable vGtin     as character no-undo.
  define variable vGtinQnty as integer no-undo.
  define variable varvalue        as character no-undo .
  define variable vartype         as character no-undo .
  define variable v-mark-weight as decimal no-undo .
  define variable v-isweighed as logical no-undo .
  define buffer buf_marking-lines for ub.marking-lines.
  define buffer buf_marking       for ub.marking.
  define buffer buf_goods         for ub.goods.
  if available ub.gds-dtl
  then do :
    find first buf_goods where
          buf_goods.artic     = ub.gds-dtl.artic
      and buf_goods.prod-type = ub.gds-dtl.prod-type
      and buf_goods.prod-code = ub.gds-dtl.prod-code.
    v-isweighed = WghProdVariable(t-doc.obj-type, t-doc.obj-code, buf_goods.gds-code) .
    run isExemplarGoods in this-procedure
         (t-doc.obj-type, t-doc.obj-code, buf_goods.gds-code, output vIsExemplarGoods).
    if v-isweighed
    then do :
      for each buf_marking-lines no-lock where
               buf_marking-lines.out-code = t-doc.doc-code
           and buf_marking-lines.obj-type = t-doc.obj-type
           and buf_marking-lines.obj-code = t-doc.obj-code
           and buf_marking-lines.gds-code = buf_goods.gds-code
           and buf_marking-lines.doc-level = 1,
          first buf_marking no-lock where
                buf_marking.mark = buf_marking-lines.mark
      :
        v-mark-weight = v-mark-weight + MarkWeight(buf_marking.mark) .
      end.
      if v-mark-weight > decimal(ub.gds-dtl.doc-qnty:screen-value IN BROWSE br-dtl) then
      do:
        message "Нельзя ввести количество меньше, чем просканировано марок по товару" view-as alert-box.
        ub.gds-dtl.doc-qnty:screen-value IN BROWSE br-dtl = string(v-mark-weight).
        return no-apply.
      end.
    end .
    else
    if vIsExemplarGoods
    then do:
      for each buf_marking-lines no-lock where
               buf_marking-lines.out-code = t-doc.doc-code
           and buf_marking-lines.obj-type = t-doc.obj-type
           and buf_marking-lines.obj-code = t-doc.obj-code
           and buf_marking-lines.gds-code = buf_goods.gds-code
           and buf_marking-lines.doc-level = 1,
          first buf_marking no-lock where
                buf_marking.mark = buf_marking-lines.mark
      :
        assign
          vGtin     = getGtinByDM(buf_marking.mark)
          vGtinQnty = vGtinQnty  + getQntyCodeByGtin(vGtin)
        .
      end.
      if vGtinQnty > int(ub.gds-dtl.doc-qnty:screen-value IN BROWSE br-dtl) then
      do:
        message "Нельзя ввести количество меньше, чем просканировано марок по товару" view-as alert-box.
        ub.gds-dtl.doc-qnty:screen-value IN BROWSE br-dtl = string(vGtinQnty).
        return no-apply.
      end.
    end.
  end .
END.
ON LEAVE OF t-doc.discnt-pc IN FRAME d-out-doc
DO:
if input frame d-out-doc t-doc.discnt-pc <> t-doc.discnt-pc then do:
if input frame d-out-doc t-doc.discnt-pc = ? then do:
  message "Ошибка. Установлен неизвестный процент скидки."
  view-as alert-box error.
  display t-doc.discnt-pc with frame d-out-doc.
  return no-apply.
end.
if available t-doc then do transaction:
  assign
    t-doc.discnt-pc = input frame d-out-doc t-doc.discnt-pc.
  run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
  if error-status :error then do:
    undo, return no-apply.
  end.
  run ui-on ("line").
end.
end.
END.
ON LEAVE OF t-doc.fact-date IN FRAME d-out-doc
DO:
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-avail-on-date   as logical   no-undo .
define variable v-avail-on-date-type as character no-undo .
define variable v-tth             as handle no-undo .
  delete object v-tth no-error.
  run adm/shattri.p (
      input "get":U
      ,input t-doc.obj-type
      ,input t-doc.obj-code
      ,input 'nakl_par':U
      ,input  "avail-on-date"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-avail-on-date
      ,output v-avail-on-date-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
      if error-status :error  then v-avail-on-date = false .
      delete object v-tth no-error.
      if v-avail-on-date = true  and not ( t-doc.fact-date:screen-value = "" or t-doc.fact-date:screen-value = string(t-doc.fact-date)) then do:
         if available ub.gds-dtl  then do:
            message " Установлен параметр проверки резервирования не раньше даты прихода, поэтому так как строки документа введены дату менять нельзя "  view-as alert-box information   .
            t-doc.fact-date:screen-value = string(t-doc.fact-date) .
            return no-apply .
         end.
      end.
    if input frame d-out-doc t-doc.fact-date <> t-doc.fact-date then do:
    run chk-upd-date no-error.
    if error-status :error then return no-apply.
    assign frame d-out-doc t-doc.fact-date.
  end.
END.
ON return OF t-doc.fact-date IN FRAME d-out-doc
DO:
    if t-doc.fact-date:sensitive in frame d-out-doc then do:
    apply "entry" to t-doc.shift-date in frame d-out-doc.
  end.
  else do:
    apply "entry" to b-add in frame d-out-doc.
  end.
  return no-apply.
END.
ON VALUE-CHANGED OF edo-return IN FRAME d-out-doc
  DO:
    define variable vLog as logical no-undo .
    define variable vFlgGenAttr as logical no-undo .
    define buffer buf_doc-line  for ub.doc-line.
    define buffer parts         for ub.parts.
    if edo-return:screen-value = "no"
    then do :
      message "По договору с поставщиком осуществляется ЭДО, уверены в возврате без ЭДО?" view-as alert-box question buttons yes-no update vLog .
      if not vLog
      then do :
        edo-return:screen-value = "yes" .
        return no-apply .
      end .
    end .
    if (t-doc.reason-code = 25 or t-doc.reason-code = 23)
        and edo-return:screen-value = "yes"
    then do:
       vFlgGenAttr = yes.
       bdl:
       for each buf_doc-line where buf_doc-line.doc-code eq t-doc.doc-code
           no-lock,
           each parts where parts.out-code  = buf_doc-line.doc-code
                        and parts.obj-type  = buf_doc-line.obj-type
                        and parts.obj-code  = buf_doc-line.obj-code
                        and parts.artic     = buf_doc-line.artic
                        and parts.prod-type = buf_doc-line.prod-type
                        and parts.prod-code = buf_doc-line.prod-code
           no-lock:
           find first gen-attr where gen-attr.table-name = 'parts':U
                                 and gen-attr.p-key      =  "parts"                + chr(3) +
 parts.obj-type           + chr(3) +
 string(parts.obj-code)   + chr(3) +
 parts.artic              + chr(3) +
 parts.prod-type          + chr(3) +
 string(parts.prod-code)  + chr(3) +
 parts.In-code            + chr(3) +
 parts.Out-code           + chr(3) +
 parts.part-Code          + chr(3) +
 string(parts.prt-code)
                                 and gen-attr.attr-code  = "in-part-key"
              no-lock no-error.
           if available gen-attr
              then vFlgGenAttr = yes.
           else do:
              vFlgGenAttr = no.
              leave bdl.
           end.
       end.
       if vFlgGenAttr = yes then
          disable b-bc with frame d-out-doc.
       else do:
          message "Строки документа введены без указания возвращаемой партии."
             skip "Удалите все строки документа, что бы установить признак 'Возврат по ЭДО'."
          view-as alert-box.
          edo-return:screen-value = "no" .
          return no-apply .
       end.
    end.
    assign edo-return .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'edo-return':U ,
                       input string(edo-return) )  .
  END.
ON VALUE-CHANGED OF is-cons IN FRAME d-out-doc
DO:
  run val-chg-is-cons.
END.
ON VALUE-CHANGED OF is-oldcons IN FRAME d-out-doc
DO:
  run val-chg-is-oldcons.
END.
ON VALUE-CHANGED OF is-repay IN FRAME d-out-doc
DO:
  run val-chg-is-repay.
END.
ON VALUE-CHANGED OF is-storage IN FRAME d-out-doc
DO:
  run val-chg-is-storage.
END.
on value-changed of t-doc.discnt-type in frame d-out-doc
do:
define variable g#log as logical   no-undo .
g#log = no.
run check-discnt no-error.
if error-status:error then return no-apply.
do transaction:
   run ch-discnt no-error.
   if return-value = "error" then do:
      if t-doc.discnt-type = 'процент':U then do:
         run ui-on ("enable").
         apply "entry" to t-doc.discnt-pc in frame d-out-doc.
         return no-apply.
      end.
      else undo, leave.
   end.
end.
display t-doc.discnt-type with frame d-out-doc.
run ui-on ("enable").
end.
ON CHOOSE OF r-reas IN FRAME d-out-doc
DO:
  run select-reason in this-procedure.
END.
ON return OF t-doc.shift-date IN FRAME d-out-doc
DO:
  apply "entry" to t-doc.shift-name in frame d-out-doc.
  return no-apply.
end.
on return of t-doc.shift-name in frame d-out-doc do:
  apply "entry" to b-add in frame d-out-doc.
  return no-apply.
end.
on return of t-doc.shift-num in frame d-out-doc do:
  apply "entry" to b-add in frame d-out-doc.
  return no-apply.
end.
on choose of r-sht in frame d-out-doc do:
  run proc-sht.
end.
on leave of t-doc.shift-num  in frame d-out-doc do:
  run proc-shift-num no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.
on leave of t-doc.shift-name in frame d-out-doc do:
  run proc-shift-name no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.
on leave of t-doc.shift-date in frame d-out-doc do:
  if input frame d-out-doc t-doc.shift-date <> t-doc.shift-date then do:
    assign
      t-doc.shift-name = ""
      t-doc.shift-num  = 0.
    display t-doc.shift-name t-doc.shift-num with frame d-out-doc.
    apply "entry" to t-doc.shift-name in frame d-out-doc.
    return no-apply.
  end.
end.
ON VALUE-CHANGED OF varpurch-chs IN FRAME d-out-doc
DO:
    define variable varchs-tg as logical no-undo.
  if varpurch-chs <> input frame d-out-doc varpurch-chs then do:
    assign
      frame d-out-doc varpurch-chs.
    if varpurch-chs = 0 then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'purchlimit':U ,
                       input 'no':U )  .
      assign
        varchs-tg = no.
      if is-repay = no then do:
        assign
          is-repay  = yes
          varchs-tg = yes.
      end.
      if is-cons = no then do:
        assign
          is-cons   = yes
          varchs-tg = yes.
      end.
      if is-storage = no then do:
        assign
          is-storage  = yes
          varchs-tg = yes.
      end.
      if is-oldcons = no then do:
        assign
          is-oldcons  = yes
          varchs-tg = yes.
      end.
      if varchs-tg = yes then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'purchcodelist':U ,
                       input '1,2,3,4':U )  .
        display is-repay is-cons is-storage is-oldcons with frame d-out-doc.
      end.
      disable is-repay is-cons is-storage is-oldcons with frame d-out-doc.
    end.
    else do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'purchlimit':U ,
                       input 'yes':U )  .
      enable is-repay is-cons is-storage is-oldcons with frame d-out-doc.
    end.
    display varpurch-chs with frame d-out-doc.
  end.
END.
define menu m-ptrl
    menu-item m-ptrl-1   label "Создать документы сверки и зафиксировать  книжное кол-во"  accelerator "alt-1"
    menu-item m-ptrl-2   label "Удалить документы сверки и расфиксировать книжное кол-во"  accelerator "alt-2".
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame d-out-doc anywhere do:
  if not available ub.goods then
    return no-apply.
  gds-rec = recid (ub.goods).
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-dtl in frame d-out-doc.
  return no-apply.
end.
define variable vss-include-info50 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame d-out-doc anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame d-out-doc. END.
  return no-apply.
end.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref51 as character no-undo .
define variable varpgscales-pref51 as character no-undo.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type52 as character no-undo.
varscales-pref51  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref51
  ,output varscales-pref-type52
  ) no-error .
if varscales-pref51 = ? then do:
  assign
  varscales-pref51 = '21,23,25':U.
end.
define variable varpgscales-pref-type52 as character no-undo.
varpgscales-pref51  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref51
  ,output varpgscales-pref-type52
  ) no-error .
if varpgscales-pref51 = ? then do:
  assign
  varpgscales-pref51 = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
on value-changed of a-n-c in frame d-out-doc do:
  run proc-valchg-a-n-c in this-procedure  no-error.
  return no-apply.
end.
on any-printable of br-dtl in frame d-out-doc do:
  run proc-any-printable-br-dtl in this-procedure   no-error.
  return no-apply.
end.
on backspace of br-dtl in frame d-out-doc do:
  run proc-backspace-br-dtl in this-procedure   no-error.
  return no-apply.
end.
ON return OF loc-code IN FRAME d-out-doc do:
  run proc-mouse-dbl-click-loc-code in this-procedure   no-error.
  return no-apply.
end.
ON return, Ctrl-J OF loc-name IN FRAME d-out-doc do:
  run proc-mouse-dbl-click-loc-name in this-procedure   no-error.
  return no-apply.
end.
PROCEDURE proc-valchg-a-n-c:
  case input frame d-out-doc a-n-c :
    when "art" then do:
      apply "entry" to br-dtl in frame d-out-doc.
      hide loc-name loc-code
      in frame d-out-doc.
      loc-art = "".
    end.
    when "name" then do:
      enable loc-name with frame d-out-doc.
      disp loc-name with frame d-out-doc.
      hide loc-art loc-code
      in frame d-out-doc.
      apply "entry" to loc-name in frame d-out-doc.
    end.
    when "code"
 or when "DataMatrix" then
    do:
      enable loc-code with frame d-out-doc.
      disp loc-code with frame d-out-doc.
      hide loc-art loc-name
      in frame d-out-doc.
      apply "entry" to loc-code in frame d-out-doc.
    end.
  end CASE.
END PROCEDURE.
PROCEDURE proc-any-printable-br-dtl :
  if input frame d-out-doc a-n-c = "art" then do:
    if last-event:label = " " and
       loc-art = "" then
    return error.
    find first l-doc-line where
               l-doc-line.doc-code = t-doc.doc-code and l-doc-line.artic begins (loc-art + last-event:label)
               no-lock no-error.
    if available l-doc-line then do:
      loc-art = loc-art + last-event:label.
      disp loc-art with frame d-out-doc.
      line-rec = recid (l-doc-line).
      reposition br-dtl to recid line-rec no-error.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-backspace-br-dtl:
  if input frame d-out-doc a-n-c = "art" then do:
    if loc-art = "" then
      return error.
    loc-art = substr (loc-art, 1, length (loc-art) - 1).
    find first l-doc-line where
               l-doc-line.doc-code = t-doc.doc-code and l-doc-line.artic begins loc-art
               no-lock.
    disp loc-art with frame d-out-doc.
    line-rec = recid (l-doc-line).
    reposition br-dtl to recid line-rec no-error.
  end.
END PROCEDURE.
PROCEDURE proc-mouse-dbl-click-loc-code:
def var str-code as integer no-undo.
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
define buffer l-goods for ub.goods.
define buffer l-bar-code for ub.bar-code.
define buffer buf_bar-code for ub.bar-code .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_place for ub.place.
  assign
  frame d-out-doc
  loc-code
  a-n-c.
  if a-n-c = "datamatrix"
  then do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_dm-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  v-cntxt-obj-type
,input  v-cntxt-obj-code
,input  yes
,input  no
,input  varscales-pref51
,input  varpgscales-pref51
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
     if varresult eq "prod-bc"
     then
        loc-code:screen-value in frame d-out-doc = buf_prod-bc.b-str.
  end.
  else do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  v-cntxt-obj-type
,input  v-cntxt-obj-code
,input  yes
,input  no
,input  varscales-pref51
,input  varpgscales-pref51
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
end.
  if available buf_bar-code then do:
        find first l-goods where
                  l-goods.gds-code =
  buf_bar-code.gds-code No-LOCK.
        find first l-doc-line where l-doc-line.doc-code = t-doc.doc-code and
                  l-doc-line.artic = l-goods.artic AND
                  l-doc-line.prod-type = l-goods.prod-type AND
                  l-doc-line.prod-code = l-goods.prod-code no-lock no-error.
    if available l-doc-line then do:
      line-rec = recid (l-doc-line).
      reposition br-dtl to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  end.
  else
    message "Бар-код не найден."
            view-as alert-box error.
  apply "entry" to loc-code in frame d-out-doc.
END PROCEDURE.
PROCEDURE  proc-mouse-dbl-click-loc-name:
  assign
  frame d-out-doc
  loc-name.
    if last-event:label = "Ctrl-J" then
      find next l-doc-line where l-doc-line.doc-code = t-doc.doc-code and
                can-find (ub.goods where ub.goods.artic = l-doc-line.artic and
                ub.goods.prod-type = l-doc-line.prod-type and
                ub.goods.prod-code = l-doc-line.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    else
      find first l-doc-line where l-doc-line.doc-code = t-doc.doc-code and
                can-find (ub.goods where ub.goods.artic = l-doc-line.artic and
                ub.goods.prod-type = l-doc-line.prod-type and
                ub.goods.prod-code = l-doc-line.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if available l-doc-line then do:
      line-rec = recid (l-doc-line).
      reposition br-dtl to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  apply "entry" to loc-name in frame d-out-doc.
END PROCEDURE.
on value-changed of br-dtl in frame d-out-doc do:
if not available ub.doc-line or recid (ub.doc-line) <> line-rec then do:
    hide loc-art in frame d-out-doc.
    loc-art = "".
end.
if available ub.goods
then do :
  define variable  p-type     as character no-undo .
  define variable v-isweighed as logical no-undo .
  define variable vRightChngQntyCode as character no-undo .
  define variable vIsExemplarGoods as logical no-undo .
  define variable vRightChngQnty as logical no-undo .
  define buffer buf_marking-lines for ub.marking-lines.
  run lineattr-value (
    input   t-doc.doc-code ,
    input   ub.goods.gds-code ,
    input   'flora_ps':U,
    output  flora-ps ,
    output  p-type      )
  .
  display flora-ps with frame d-out-doc .
  if t-doc.ext-doc-type = 'ev':U or
     t-doc.ext-doc-type = 'we':U then
  do:
      run isExemplarGoods in this-procedure
        (t-doc.obj-type, t-doc.obj-code, ub.goods.gds-code, output vIsExemplarGoods).
      v-isweighed = WghProdVariable(t-doc.obj-type, t-doc.obj-code, ub.goods.gds-code).
      if vIsExemplarGoods
      or v-isweighed
      then do:
        if t-doc.ext-doc-type = 'ev':U and
           can-find(first buf_marking-lines no-lock where
                            buf_marking-lines.out-code = ub.gds-dtl.doc-code
                        and buf_marking-lines.gds-code = ub.goods.gds-code) then
        do:
          vRightChngQnty = false.
        end.
        else
        do:
            vRightChngQntyCode = if t-doc.ext-doc-type = 'we':U
                then 'actn_write-off_add-no-mark':U
                else 'actn_tdedt-ras-perem_add-no-mark':U.
define variable vss-include-info53 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  vRightChngQntyCode
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output vRightChngQnty
    )  .
end.
        end.
        if not vRightChngQnty then
        assign
          ub.gds-dtl.doc-qnty:read-only  in browse br-dtl = yes
          ub.gds-dtl.fact-qnty:read-only  in browse br-dtl = yes
        .
        else
        assign
          ub.gds-dtl.doc-qnty:read-only  in browse br-dtl = no
          ub.gds-dtl.fact-qnty:read-only  in browse br-dtl = no
        .
      end.
      else do :
        assign
          ub.gds-dtl.doc-qnty:read-only  in browse br-dtl = no
          ub.gds-dtl.fact-qnty:read-only  in browse br-dtl = no
        .
      end .
      case t-doc.status_ :
        when 'накл':U then do:
           if t-doc.flag_ then assign ub.gds-dtl.doc-qnty:read-only  in browse br-dtl = yes.
           assign ub.gds-dtl.fact-qnty:read-only  in browse br-dtl = yes.
        end.
        when 'разрешен':U then assign ub.gds-dtl.doc-qnty:read-only  in browse br-dtl = yes.
        otherwise   assign ub.gds-dtl.doc-qnty:read-only  in browse br-dtl = yes
                          ub.gds-dtl.fact-qnty:read-only in browse br-dtl = yes.
      end case.
  end.
end .
IF mImagePh THEN
DO:
    DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
if AVAILABLE goods then do:
    RUN gds-attr-value ( goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
    RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, goods.gds-code, OUTPUT vImageList).
    vCh = ENTRY (1, vImageList, ",":U).
    g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
end.
END.
ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
end.
on end-error of gds-dtl.doc-qnty in browse br-dtl do:
  display gds-dtl.doc-qnty with browse br-dtl.
  return no-apply.
end.
on end-error of ub.gds-dtl.fact-qnty in browse br-dtl do:
  display ub.gds-dtl.fact-qnty with browse br-dtl.
  return no-apply.
end.
Tree = ObjSrv:Lib:MarkingTree .
  Marking = ObjSrv:Env:Marking:Sts:Mark .
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function func-get-name-from-ext-type   returns char
  ( p-ext-type as character   ,
    p-caps     as logical ).
define variable v-ext-name as character no-undo .
run get-name-from-ext-type in this-procedure (
    input p-ext-type  ,
    input p-caps  ,
    output v-ext-name )
    no-error .
    if error-status :error then do:
       assign
         v-ext-name = p-ext-type
       .
    end.
 return (v-ext-name) .
end.
procedure get-name-from-ext-type :
 do
 on error undo, return error return-value
 :
define input  parameter p-ext-type as character no-undo .
define input  parameter p-caps     as logical no-undo   .
define output parameter p-ext-name as character no-undo .
define variable v-num as integer no-undo .
  if lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) = 0 then do :
    message
      vss-include-info55 skip
      "Неправильно задано значение входящего параметра! "
      "Нет такого типа документов " p-ext-type
      view-as alert-box error .
      undo, return error .
  end.
  v-num      = lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) .
  p-ext-name = entry  ( v-num , 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ) .
  if p-caps  = true then do :
     p-ext-name = caps(substring(p-ext-name,1,1) ) + substring(p-ext-name, 2 , length (p-ext-name) - 1 ) .
  end .
  end.
end procedure.
define variable vss-include-info56 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame d-out-doc anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame d-out-doc. END.
  return no-apply.
end.
define variable vss-include-info57 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-out-doc anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-out-doc. END.
  return no-apply.
end.
define variable vss-include-info58 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame d-out-doc anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame d-out-doc. END.
  return no-apply.
end.
define variable vss-include-info59 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame d-out-doc anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame d-out-doc. END.
  return no-apply.
end.
ON CHOOSE OF b-next IN FRAME d-out-doc
DO:
  RUN step-next in this-procedure .
END.
procedure step-next:
define variable cur-form as char no-undo.
define variable new-form as char no-undo.
define buffer new_trn-doc for ub.trn-doc  .
case t-doc.doc-type:
  when 'при':U then
    cur-form = if t-doc.internal then 'рас':U else 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then
    cur-form = 'рас':U.
  when 'инв':U then cur-form = 'инв':U.
end case.
if bf-handle = ? then return .
if valid-handle (br-handle) then do:
  varlog = br-handle:select-next-row().
  find first new_trn-doc no-lock where  recid( new_trn-doc ) = bf-handle:recid no-error .
  if not varlog then message "Это последний документ списка.".
end.
case new_trn-doc.doc-type:
  when 'при':U then
    new-form = if new_trn-doc.internal then 'рас':U else 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then
    new-form = 'рас':U.
  when 'инв':U then new-form = 'инв':U.
end case.
assign
    pardoc-rec   = bf-handle:recid
    parnext-prev = ( cur-form = new-form ) .
end procedure.
ON CHOOSE OF b-prev IN FRAME d-out-doc
DO:
  run step-prev in this-procedure .
END.
procedure step-prev:
define variable cur-form as char no-undo.
define variable new-form as char no-undo.
define buffer new_trn-doc for ub.trn-doc  .
case t-doc.doc-type:
  when 'при':U then if t-doc.internal then cur-form = 'рас':U. else cur-form = 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then cur-form = 'рас':U.
  when 'инв':U then cur-form = 'инв':U.
end case.
if bf-handle = ? then return .
if valid-handle (br-handle) then do:
  varlog = br-handle:select-prev-row().
  find first new_trn-doc no-lock where  recid( new_trn-doc ) = bf-handle:recid no-error .
  if not varlog then message "Это первый документ списка.".
end.
case new_trn-doc.doc-type :
  when 'при':U then if new_trn-doc.internal then new-form = 'рас':U. else new-form = 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then  new-form = 'рас':U.
  when 'инв':U then new-form = 'инв':U.
end case.
assign
  pardoc-rec   = bf-handle:recid
  parnext-prev = (cur-form = new-form)
.
end procedure.
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure ver-clients :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-error as logical   no-undo .
define variable v-veto-man-doc as character no-undo .
define variable v-type        as character no-undo .
  do
  on error undo, return error return-value
  :
  p-error = false .
run clntattr-value in this-procedure (
 input p-obj-type ,
 input p-obj-code ,
 input 'veto-man-doc':U     ,
 output v-veto-man-doc ,
 output v-type        ) no-error .
 if error-status :error then message
   error-status :get-message(1) skip
   return-value skip
   "Ошибка clntattr-veto-man-doc"
   view-as alert-box error
 .
  if v-veto-man-doc = 'ALL' then do:
      message "Запрещено создание документа на этого контрагента оператору вручную." view-as alert-box error  .
      p-error = true .
  end.
 end.
end procedure.
on end-error, stop of frame d-out-doc do:
  apply "choose" to b-exit in frame d-out-doc.
  return no-apply.
end.
on choose of b-notes in frame d-out-doc run notes-tr.
on choose of b-history   in frame d-out-doc do:
  run proc-history in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-exit  in frame d-out-doc
do:
  run proc-exit no-error.
  if error-status :error then do: return no-apply. end.
end.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON MOUSE-SELECT-DBLCLICK, return OF t-doc.agnt IN FRAME d-out-doc
DO:
  run local-psn-chk ("agnt", "ret-mouse").
  apply "entry" to t-doc.boss in frame d-out-doc.
  return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK, return OF t-doc.boss IN FRAME d-out-doc
DO:
  RUN local-psn-chk ("boss", "ret-mouse").
  apply "entry" to b-exit in frame d-out-doc.
  return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK, return OF t-doc.wrkr IN FRAME d-out-doc
DO:
  RUN local-psn-chk ("wrkr", "ret-mouse").
  apply "entry" to t-doc.agnt in frame d-out-doc.
  return no-apply.
END.
ON CHOOSE OF r-agnt IN FRAME d-out-doc
DO:
  RUN local-psn-chk ("agnt", "button").
  apply "entry" to t-doc.boss in frame d-out-doc.
  return no-apply.
END.
ON CHOOSE OF r-boss IN FRAME d-out-doc
DO:
  RUN local-psn-chk ("boss", "button").
  apply "entry" to b-exit in frame d-out-doc.
  return no-apply.
END.
ON CHOOSE OF r-wrkr IN FRAME d-out-doc
DO:
  run local-psn-chk ("wrkr", "button").
  apply "entry" to t-doc.agnt in frame d-out-doc.
  return no-apply.
END.
on leave of t-doc.agnt in frame d-out-doc  do:
  if not available t-doc then return .
  if input frame d-out-doc t-doc.agnt <> t-doc.agnt then do:
    run local-psn-chk ("agnt", "leave").
  end.
end.
on leave of t-doc.boss in frame d-out-doc   do:
  if not available t-doc then return .
  if input frame d-out-doc t-doc.boss <> t-doc.boss then do:
    run local-psn-chk ("boss", "leave").
  end.
end.
on leave of t-doc.wrkr in frame d-out-doc  do:
  if not available t-doc then return .
  if input frame d-out-doc t-doc.wrkr <> t-doc.wrkr then do:
    run local-psn-chk ("wrkr", "leave").
  end.
end.
procedure local-psn-chk :
  define input parameter parman    as character no-undo.
  define input parameter paraction as character no-undo.
  if parman = "agnt" and paraction = "ret-mouse" then do:
  define variable v-ref-rec63   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-out-doc t-doc.agnt <> ""
       and input frame d-out-doc t-doc.agnt <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec63 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.agnt
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.agnt
            cli-buf.obj-name @ agnt-name with frame d-out-doc.
    assign frame d-out-doc t-doc.agnt.
  end.
  else display ? @ t-doc.agnt
               ? @ agnt-name with frame d-out-doc.
  apply "entry" to t-doc.boss
                            in frame d-out-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-out-doc.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-out-doc.
      return no-apply.
  end.
  if parman = "agnt" and paraction = "button" then do:
  define variable v-ref-rec64   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec64 = ( if available cli-buf then recid( cli-buf ) else ? ).
  ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec64 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.agnt
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.agnt
            cli-buf.obj-name @ agnt-name with frame d-out-doc.
    assign frame d-out-doc t-doc.agnt.
  end.
  else display ? @ t-doc.agnt
               ? @ agnt-name with frame d-out-doc.
  apply "entry" to t-doc.boss
                            in frame d-out-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-out-doc.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-out-doc.
      return no-apply.
  end.
  if parman = "agnt" and paraction = "leave" then do:
  define variable v-ref-rec65   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-out-doc.
          assign frame d-out-doc t-doc.agnt.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-out-doc.
  end.
  if parman = "boss" and paraction = "ret-mouse" then do:
  define variable v-ref-rec66   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-out-doc t-doc.boss <> ""
       and input frame d-out-doc t-doc.boss <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec66 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.boss
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.boss
            cli-buf.obj-name @ boss-name with frame d-out-doc.
    assign frame d-out-doc t-doc.boss.
  end.
  else display ? @ t-doc.boss
               ? @ boss-name with frame d-out-doc.
  apply "entry" to  b-exit in frame d-out-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-out-doc.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-out-doc.
      return no-apply.
  end.
  if parman = "boss" and paraction = "button" then do:
  define variable v-ref-rec67   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec67 = ( if available cli-buf then recid( cli-buf ) else ? ).
  ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec67 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.boss
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.boss
            cli-buf.obj-name @ boss-name with frame d-out-doc.
    assign frame d-out-doc t-doc.boss.
  end.
  else display ? @ t-doc.boss
               ? @ boss-name with frame d-out-doc.
  apply "entry" to  b-exit in frame d-out-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-out-doc.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-out-doc.
      return no-apply.
  end.
  if parman = "boss" and paraction = "leave" then do:
  define variable v-ref-rec68   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-out-doc.
          assign frame d-out-doc t-doc.boss.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-out-doc.
  end.
  if parman = "wrkr" and paraction = "ret-mouse" then do:
  define variable v-ref-rec69   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-out-doc t-doc.wrkr <> ""
       and input frame d-out-doc t-doc.wrkr <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec69 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.wrkr
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.wrkr
            cli-buf.obj-name @ wrkr-name with frame d-out-doc.
    assign frame d-out-doc t-doc.wrkr.
  end.
  else display ? @ t-doc.wrkr
               ? @ wrkr-name with frame d-out-doc.
  apply "entry" to t-doc.agnt in frame d-out-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-out-doc.
  end.
  else display ? @ t-doc.wrkr ? @ wrkr-name with frame d-out-doc.
      return no-apply.
  end.
  if parman = "wrkr" and paraction = "button" then do:
  define variable v-ref-rec70   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec70 = ( if available cli-buf then recid( cli-buf ) else ? ).
  ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec70 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.wrkr
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.wrkr
            cli-buf.obj-name @ wrkr-name with frame d-out-doc.
    assign frame d-out-doc t-doc.wrkr.
  end.
  else display ? @ t-doc.wrkr
               ? @ wrkr-name with frame d-out-doc.
  apply "entry" to t-doc.agnt in frame d-out-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-out-doc.
  end.
  else display ? @ t-doc.wrkr ? @ wrkr-name with frame d-out-doc.
      return no-apply.
  end.
  if parman = "wrkr" and paraction = "leave" then do:
  define variable v-ref-rec71   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-out-doc.
          assign frame d-out-doc t-doc.wrkr.
  end.
  else display ? @ t-doc.wrkr ? @ wrkr-name with frame d-out-doc.
  end.
end procedure.
on entry of t-doc.cli-code, r-clients in frame d-out-doc
DO:
if t-doc.ret-supp = yes and
  can-find (first ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code no-lock) then do:
    message "Уже есть строки возврата. Изменение контрагента невозможно."
    view-as alert-box error buttons ok.
    apply "entry" to browse br-dtl.
    return no-apply.
end.
if t-doc.cli-code <> ? then do:
  pardoc-mode = 'ДОБАВЛЕНИЕ':U.
  run UI-on ("enable").
end.
end.
on leave of t-doc.print-rubl in frame d-out-doc do:
  if input frame d-out-doc t-doc.print-rubl <> t-doc.print-rubl then do:
   run print-rubl.
  end.
END.
procedure print-rubl:
assign frame d-out-doc t-doc.print-rubl.
define variable varbase-code as integer no-undo.
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output varbase-code
  )  .
if t-doc.print-rubl then
  assign
    t-doc.exch-code  = 0
    t-doc.exch-rate  = 1
    t-doc.exch-scale = 1.
  else
  assign
    t-doc.exch-code  = varbase-code
    t-doc.exch-rate  = t-doc.base-rate
    t-doc.exch-scale = t-doc.base-scale.
end procedure.
on leave of t-doc.base-rate  in frame d-out-doc or
   leave of t-doc.base-scale in frame d-out-doc do:
  if input frame d-out-doc t-doc.base-rate  <> t-doc.base-rate  or
     input frame d-out-doc t-doc.base-scale <> t-doc.base-scale then do:
    run check-rate no-error.
    if error-status :error then do:
       message "Ошибка при проверке курса" skip
               return-value
       view-as alert-box error.
       return no-apply.
    end.
    run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
    if error-status :error then undo, return no-apply.
    run ui-on ("line").
  end.
end.
on leave of t-doc.pay-code in frame d-out-doc
do:
if input frame d-out-doc t-doc.pay-code <> t-doc.pay-code then do:
  run leave-pay-code no-error.
  if error-status :error then return no-apply.
end.
end.
on leave of t-doc.doc-date in frame d-out-doc do:
if input frame d-out-doc t-doc.doc-date <> t-doc.doc-date then do:
  assign
    t-doc.doc-date = input frame d-out-doc t-doc.doc-date.
end.
end.
on mouse-select-dblclick, return of t-doc.pay-code in frame d-out-doc
do:
if input frame d-out-doc t-doc.pay-code <> t-doc.pay-code then do:
  run return-pay-code no-error.
  if error-status :error then return no-apply.
end.
apply "entry" to t-doc.wrkr in frame d-out-doc.
return no-apply.
end.
on choose of r-pay in frame d-out-doc
do:
  run choose-r-pay no-error.
  if error-status :error then return no-apply.
end.
on return, mouse-select-dblclick of br-dtl in frame d-out-doc
do:
  if b-chg:sensitive then do:
    apply "choose" to b-chg in frame d-out-doc.
  end.
  else do:
    apply "choose" to b-lkp in frame d-out-doc.
  end.
end.
on choose of r-acc in frame d-out-doc
do:
  run choose-r-acc no-error.
  if error-status :error then return no-apply.
end.
procedure choose-r-acc:
define variable v-today      as date    no-undo.
define variable varbase-code as integer no-undo.
varlog = yes.
message "Подставить курс базовой валюты : из справочника на текущую дату ?"
view-as alert-box question buttons OK-Cancel update varlog.
if varlog <> true then do:
  run UI-on ("line").
  return error.
end.
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-today
  )  .
if v-today <> ? then do:
  find last ub.curr-accnt where ub.curr-accnt.curr-code  = varbase-code and
                             ub.curr-accnt.exch-date <= v-today      use-index pi no-lock no-error.
end.
else do:
  find last ub.curr-accnt where ub.curr-accnt.curr-code  = varbase-code   and
                             ub.curr-accnt.exch-date <= t-doc.doc-date use-index pi no-lock no-error.
end.
if not available ub.curr-accnt then do:
  message "На эту дату неизвестен курс базовой валюты.".
  apply "entry" to t-doc.base-rate in frame d-out-doc.
  return error.
end.
disp ub.curr-accnt.exch-rate  @ t-doc.base-rate
     ub.curr-accnt.exch-scale @ t-doc.base-scale with frame d-out-doc.
run check-rate.
  apply "entry" to b-add in frame d-out-doc.
  return error.
end procedure.
on mouse-select-dblclick, return of t-doc.cli-code, t-doc.cli-type
  in frame d-out-doc
do:
  run choose-cli in this-procedure no-error.
  if error-status :error then do:
    display ? @ t-doc.cli-type ? @ t-doc.cli-code with frame d-out-doc.
  end.
  return no-apply.
end.
on choose of r-clients in frame d-out-doc
do:
define variable varfirm-code like ub.firm.firm-code no-undo.
define variable v-rid-list as character no-undo .
define variable v-types as character no-undo .
define buffer bf_clients for ub.clients.
if t-doc.internal then v-types = 'маг':U.
                  else v-types = 'все':U.
if (t-doc.ext-doc-type = 'ee':U or t-doc.ext-doc-type = 'ep':U) and
   varhold            = "yes"              and
   paris-hold         = yes                then do:
  assign
    varfirm-code = ?.
  run adm/sconfs.w ( input parparentproc
                   , input "b-sel":U
                   , input no
                   , input ?
                   , output varfirm-code
                   , input-output v-rid-list) no-error.
  if error-status :error or
     varfirm-code = ?   then do:
    return no-apply.
  end.
  find first bf_clients where bf_clients.obj-type = 'орг':U       and
                              bf_clients.obj-code = varfirm-code no-lock.
  assign ref-list = string(recid (bf_clients)).
  run check-base-code in this-procedure (recid(bf_clients)).
end.
else do:
  if transaction = yes then do:
    message "Критическая ошибка." skip
            "Вы находитесь в транзакции." skip
            "Работа со справочником клиентов невозможна."
    view-as alert-box error.
    return no-apply.
  end.
  def var supp-type as character no-undo.
  run ref/cli-all.w (parparentproc
                , "b-sel,b-add"
                , v-types
                , ?
                , ?
                , ?
                , ?
                , supp-type
                , output ref-list) .
end.
if ref-list <> "" then do:
  ref-rec = integer (ref-list).
  find ub.clients where recid ( ub.clients ) = ref-rec no-lock.
  disp ub.clients.obj-code @ t-doc.cli-code
          ub.clients.obj-name with frame d-out-doc.
if pardoc-mode = 'ДОБАВЛЕНИЕ':U then
  disp ub.clients.obj-type @ t-doc.cli-type with frame d-out-doc.
end.
if trn-type = 1
then do :
  define variable v-tmp-char like ub.thbj-attr.property-value-character no-undo .
  define variable v-tmp-date      like ub.thbj-attr.property-value-date    no-undo .
  define variable v-tmp-decimal   like ub.thbj-attr.property-value-decimal no-undo .
  define variable v-tmp-integer   like ub.thbj-attr.property-value-integer no-undo .
  define variable v-rvd-own-nb as logical no-undo .
  define variable v-rvd-own-nb-type as   character no-undo .
  find ub.clients where ub.clients.obj-code = input frame d-out-doc t-doc.cli-code
               and ub.clients.obj-type = input frame d-out-doc t-doc.cli-type no-error.
  if not available ub.clients then do:
    if input frame d-out-doc t-doc.cli-code <> ? and input t-doc.cli-type <> ? then
      message "Неправильный код или тип контрагента.".
    apply "entry" to t-doc.cli-code in frame d-out-doc.
    return no-apply .
  end.
  run adm/shattri.p (
      input "get":U
      ,input t-doc.obj-type
      ,input t-doc.obj-code
      ,input 'petrol':U
      ,input  "rvd-own-nb"
      ,output v-tmp-char
      ,output v-tmp-date
      ,output v-tmp-decimal
      ,output v-tmp-integer
      ,output v-rvd-own-nb
      ,output v-rvd-own-nb-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  if error-status :error then v-rvd-own-nb = false .
  if v-rvd-own-nb = false
  then do :
    find first ub.clients-attr no-lock where ub.clients-attr.obj-type = ub.clients.obj-type
                                         and ub.clients-attr.obj-code = ub.clients.obj-code
                                         and ub.clients-attr.attr-code = 'owner-code':U
                                         no-error .
    if available ub.clients-attr
    and ub.clients-attr.attr-value > ""
    then do :
      if ub.clients-attr.attr-value = "орг" + string(t-doc.host-code)
      then do :
        message "Для данного поставщика документ может быть заполнен только в автоматическом режиме путем сканирования 2D кода. Просканируйте код с ТТН, при возникновении проблемы обратитесь в тех. поддержку".
        run str/trnscanqr.w (parparentproc, t-doc.doc-code, "", this-procedure).
        return no-apply .
      end .
    end .
  end .
end .
run check-cli no-error.
if error-status :error then return no-apply.
run fill-mol in this-procedure.
if error-status :error then return no-apply.
end.
procedure check-cli :
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_sysconf      for ub.sysconf.
define buffer buf_firm         for ub.firm.
define buffer in-cli           for ub.trn-doc.
define buffer buf-hold_clients for ub.clients.
define buffer buf-hold_shop    for ub.shop.
define buffer buf-hold_store   for ub.store.
define buffer bf_clients       for ub.clients.
define buffer bf_contract      for ub.contract.
define buffer buf_contract-attr for ub.contract-attr.
define buffer bf_currency      for ub.currency.
define buffer buf_trn-reason   for ub.trn-reason.
define variable varexch-rate     like ub.trn-doc.exch-rate            no-undo.
define variable varexch-scale    like ub.trn-doc.exch-scale           no-undo.
define variable varcurr-abbr     as   character                       no-undo.
define variable parhold-obj-type like ub.firm.main-obj-type           no-undo.
define variable parhold-obj-code like ub.firm.main-obj-code initial ? no-undo.
define variable varcontract-code like ub.contract.contract-code       no-undo.
define variable varr-b           as   character                       no-undo.
define variable varis-fin        as   character                       no-undo.
define variable varis-finby      as   character                       no-undo.
define variable vartype          as   character                       no-undo.
define variable varcontract      as   character                       no-undo.
define variable varcontract-cli  as   character                       no-undo.
define variable varcontract-type  as character no-undo .
define variable v-value-character like ub.thbj-attr.property-value-character no-undo .
define variable v-value-date      like ub.thbj-attr.property-value-date    no-undo .
define variable v-value-decimal   like ub.thbj-attr.property-value-decimal no-undo .
define variable v-value-logical   like ub.thbj-attr.property-value-logical no-undo .
define variable v-value-integer   like ub.thbj-attr.property-value-integer no-undo .
define variable v-tth as handle no-undo .
define variable v-tth1 as handle no-undo .
define variable varintprmvq      as logical   no-undo .
define variable varintprmvq-type as   character                       no-undo.
define variable v-num            as   integer       initial 1         no-undo.
define variable varis-perm       as   logical       initial no        no-undo.
define buffer bf-f_contract-specif    for ub.contract-specif.
define variable v-master as character no-undo.
define variable trn-is-return          as logical   no-undo init no .
define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
define buffer bf_shop for ub.shop.
do on error undo, return error return-value :
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fin'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output varis-fin
  ,output vartype
  ) no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-finby'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output varis-finby
  ,output vartype
  ) no-error .
  run adm/shattri.p (
      input "get":U
      ,input t-doc.obj-type
      ,input t-doc.obj-code
      ,input 'nakl_par':U
      ,input  "intprmvq"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output varintprmvq
      ,output varintprmvq-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then varintprmvq = false .
if input frame d-out-doc t-doc.cli-type = ? or input frame d-out-doc t-doc.cli-type = "" then do:
  if t-doc.internal then do:
    if can-find (ub.clients where ub.clients.obj-code = input frame d-out-doc t-doc.cli-code
                                     and ub.clients.obj-type = 'скл':U no-lock) then do:
      disp 'скл':U @ t-doc.cli-type with frame d-out-doc.
    end.
    else do:
      disp 'маг':U @ t-doc.cli-type with frame d-out-doc.
    end.
  end.
  else do:
    if can-find (ub.clients where ub.clients.obj-code = input frame d-out-doc t-doc.cli-code
                                     and ub.clients.obj-type = 'орг':U no-lock) then do:
      disp 'орг':U @ t-doc.cli-type with frame d-out-doc.
    end.
    else do:
      disp 'чел':U @ t-doc.cli-type with frame d-out-doc.
    end.
  end.
end.
define variable conf-par as character no-undo.
define variable mode-erprn as logical no-undo.
define variable par-type as character no-undo.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-erpRN'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  NO
  ,output conf-par
  ,output par-type
  ) no-error .
if not error-status:error and conf-par = "yes":U then mode-erprn = yes.
  else mode-erprn = no.
find ub.clients where ub.clients.obj-code = input frame d-out-doc t-doc.cli-code
               and ub.clients.obj-type = input frame d-out-doc t-doc.cli-type no-error.
if not available ub.clients then do:
  if input frame d-out-doc t-doc.cli-code <> ? and input t-doc.cli-type <> ? then
    message "Неправильный код или тип контрагента.".
  apply "entry" to t-doc.cli-code in frame d-out-doc.
  return error.
end.
disp ub.clients.obj-type @ t-doc.cli-type with frame d-out-doc.
if (ub.clients.obj-type = v-cntxt-obj-type and ub.clients.obj-code = v-cntxt-obj-code) or
   (ub.clients.obj-type = 'орг':U and ub.clients.obj-code = v-cntxt-host-code-obj) then do:
  release ub.clients no-error.
  message "Запрещенный код и тип контрагента.".
  apply "entry" to t-doc.cli-code in frame d-out-doc.
  return error.
end.
if ub.clients.stts <> 0 then do:
 message "Данный клиент имеет статус 'неактивный'.".
 apply "entry" to t-doc.cli-code in frame d-out-doc.
 return error.
end.
define variable v-err as logical   no-undo .
  run ver-clients  ( ub.clients.obj-type , ub.clients.obj-code , output v-err ) .
  if  v-err then do:
  apply "entry" to t-doc.cli-code in frame d-out-doc.
  return error.
  end.
if lookup(ub.clients.obj-type, 'скл':U + ',' + 'маг':U) > 0
then do:
  if t-doc.internal then do:
    if ub.clients.obj-type = 'скл':U then do:
      find ub.store where ub.store.obj-code = ub.clients.obj-code no-lock.
      if ub.store.host-code <> v-cntxt-host-code-obj then do:
        release ub.clients no-error.
        message "Выбран склад другой фирмы. Используйте внешний документ.".
        apply "entry" to t-doc.cli-code in frame d-out-doc.
        return error.
      end.
    end.
    else do:
      find ub.shop where ub.shop.obj-code = ub.clients.obj-code no-lock.
      if ub.shop.host-code <> v-cntxt-host-code-obj then do:
        release ub.clients no-error.
        message "Выбран магазин другой фирмы. Используйте внешний документ.".
        apply "entry" to t-doc.cli-code in frame d-out-doc.
        return error.
      end.
    end.
  end.
  else do:
    release ub.clients no-error.
    message "Это не внутреннее перемещение. Выберите организацию или человека.".
    apply "entry" to t-doc.cli-code in frame d-out-doc.
    return error.
  end.
end.
else do:
  if t-doc.internal then do:
    release ub.clients no-error.
    message "Вы заполняете внутреннее перемещение. Выберите склад или магазин.".
    apply "entry" to t-doc.cli-code in frame d-out-doc.
    return error.
  end.
end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'trn-is-gds':U ,
                       output varvalue ,
                       output vartype ) no-error .
   if varvalue = "yes" or varvalue = "" then
   do:
      run adm/shattri.p (
         input "get":U
         ,input t-doc.obj-type
         ,input t-doc.obj-code
         ,input 'contr-in':U
         ,input ( if t-doc.ext-doc-type = 'ee':U  then  "contr-in-expense" else "contr-in-income" )
         ,output v-value-character
         ,output v-value-date
         ,output v-value-decimal
         ,output v-value-integer
         ,output v-value-logical
         ,output varcontract-type
         ,INPUT-OUTPUT TABLE-handle v-tth1
         ) no-error .
      if error-status :error then
         message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "adm/shattri.p"
            view-as alert-box error
            .
   end.
   else
   do:
      run adm/shattri.p (
         input "get":U
         ,input t-doc.obj-type
         ,input t-doc.obj-code
         ,input 'contr-in':U
         ,input ( if t-doc.ext-doc-type = 'ee':U  then  "contr-in-expense-NP" else "contr-in-income-NP" )
         ,output v-value-character
         ,output v-value-date
         ,output v-value-decimal
         ,output v-value-integer
         ,output v-value-logical
         ,output varcontract-type
         ,INPUT-OUTPUT TABLE-handle v-tth1
         ) no-error .
      if error-status :error then
         message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "adm/shattri.p"
            view-as alert-box error
            .
   end.
      delete object v-tth1.
      if v-value-logical = true then varcontract = "yes" .
                                else varcontract = "no" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'is-return':U ,
                       output varvalue ,
                       output vartype ) no-error .
if varvalue = "yes"
then do :
  trn-is-return = yes .
end .
if ( varis-fin = "yes":u
 and ( t-doc.ext-doc-type = 'ie':U or
       t-doc.ext-doc-type = 'ep':U or
   ( t-doc.ext-doc-type = 'ee':U and (paris-hold = true or mode-erprn = true or trn-is-return = true) ) or
     ( t-doc.ext-doc-type = 're':U and (paris-hold = true or mode-erprn = true)   )))
  or ( varis-finby = "yes":u
  and ( t-doc.ext-doc-type = 'ee':U      or
        t-doc.ext-doc-type = 'ep':U or
        t-doc.ext-doc-type = 're':U  or
      ( t-doc.ext-doc-type = 'ee':U  and paris-hold = true )))
  then do:
    find first bf_contract where bf_contract.host-code = t-doc.host-code                          and
                                 bf_contract.cli-type  = input frame d-out-doc t-doc.cli-type and
                                 bf_contract.cli-code  = input frame d-out-doc t-doc.cli-code no-lock no-error.
    if not available bf_contract then do:
      if (varcontract <> "yes":u or trn-type = 1) and
         not (t-doc.ext-doc-type = 'ee':U and trn-is-return)
      then do:
        assign
          t-doc.contract-code  = 0.
      end.
      else do:
        message "По клиенту " input frame d-out-doc t-doc.cli-code " " input frame d-out-doc t-doc.cli-type
                " на фирме " t-doc.host-code " нет ни одного договора. "
                func-get-name-from-ext-type ( t-doc.ext-doc-type , true ) " не может быть оформлен."
        view-as alert-box error.
        apply "entry" to t-doc.cli-code in frame d-out-doc.
        return error.
      end.
    end.
    else do:
        run check-contract-code in this-procedure (input  substitute("&1,&2=&3", "choose":u, "doc-type", t-doc.ext-doc-type),
                                                  input  t-doc.host-code,
                                                  input  input frame d-out-doc t-doc.cli-type,
                                                  input  input frame d-out-doc t-doc.cli-code,
                                                  input  ?,
                                                  input  parparentproc,
                                                  input  t-doc.doc-date,
                                                  input if paris-hold = yes then "all" else (if ( t-doc.ext-doc-type = 'ie':U or t-doc.ext-doc-type = 'ep':U or mode-erprn or (t-doc.ext-doc-type = 'ee':U and (logical(varcontract) or trn-is-return))) then 'при':U else 'рас':U) ,
                                                  output varcontract-code) no-error.
      if error-status :error    or
         varcontract-code = ?  or
         varcontract-code = 0  then do:
        if trn-is-return
        then do :
          apply "entry" to t-doc.cli-code in frame d-out-doc.
          return error.
        end .
        if varcontract <> "yes":u or trn-type = 1 then do:
          message "Вы не выбрали договор. Вы хотите оформить "
            func-get-name-from-ext-type ( t-doc.ext-doc-type , false ) " без договора?"
          view-as alert-box question buttons yes-no update varlog.
          if varlog = no then do:
            apply "entry" to t-doc.cli-code in frame d-out-doc.
            return error.
          end.
          else do:
            assign
              t-doc.contract-code = 0.
          end.
        end.
        else do:
          message "Вы не выбрали договор. "
          func-get-name-from-ext-type (t-doc.ext-doc-type, true ) " не может быть оформлен."
          view-as alert-box error.
          apply "entry" to t-doc.cli-code in frame d-out-doc.
          return error.
        end.
      end.
      else do:
        find first bf_contract where bf_contract.host-code     = t-doc.host-code  and
                                     bf_contract.contract-code = varcontract-code no-lock.
        find first bf_currency where bf_currency.curr-code = bf_contract.curr-code no-lock no-error.
        if not available bf_currency then do:
          message "В договоре указана валюта " bf_contract.curr-code "." skip
                  "Но этой валюты нет в справочнике валют."
          view-as alert-box error.
          apply "entry" to t-doc.cli-code in frame d-out-doc.
          return error.
        end.
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  bf_currency.curr-code
  ,input  t-doc.exch-date
  ,output varexch-rate
  ,output varexch-scale
  ,output varcurr-abbr
  ) no-error .
        if error-status :error then do:
          message "Ошибка при поиске курса валюты поставки по договору." skip
                  return-value skip
                  error-status :get-message( 1 ) skip
                  error-status :get-message( 2 )
          view-as alert-box error.
          return error.
        end.
        if t-doc.ext-doc-type = 'ie':U
        then do :
          EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code).
          find first buf_contract-attr no-lock where buf_contract-attr.host-code = bf_contract.host-code
                                                 and buf_contract-attr.contract-code = bf_contract.contract-code
                                                 and buf_contract-attr.attr-code = "contract-edi"
                                                 no-error .
          if EDOParSec:IsEdo
          and available buf_contract-attr
          and logical(buf_contract-attr.attr-value) = true
          then do :
            message "Договор рассчитан на поставки через ЭДО. Ручной приход по нему невозможен!" view-as alert-box error.
            apply "entry" to t-doc.cli-code in frame d-out-doc.
            return error.
          end .
        end .
        if t-doc.ext-doc-type = 'ep':U
        then do :
          EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code).
          find first buf_contract-attr no-lock where buf_contract-attr.host-code = bf_contract.host-code
                                                 and buf_contract-attr.contract-code = bf_contract.contract-code
                                                 and buf_contract-attr.attr-code = "contract-edi"
                                                 no-error .
          if EDOParSec:IsEdo
          and available buf_contract-attr
          and logical(buf_contract-attr.attr-value) = true
          then do :
            message "По договору осуществляется ЭДО. Для возврата используйте документ Расход внешний." view-as alert-box .
            return error.
          end .
          else do :
            find first buf_contract-attr no-lock where buf_contract-attr.host-code = bf_contract.host-code
                                                   and buf_contract-attr.contract-code = bf_contract.contract-code
                                                   and buf_contract-attr.attr-code = "contract-diadoc"
                                                   no-error .
            if EDOParSec:IsEdo
            and available buf_contract-attr
            and logical(buf_contract-attr.attr-value) = true
            then do :
              message "По договору осуществляется ЭДО. Для возврата используйте документ Расход внешний." view-as alert-box .
              return error.
            end .
          end .
        end .
        if t-doc.ext-doc-type = 'ee':U
        and trn-is-return
        then do :
          if (bf_contract.status_ = 'зкр':U
          or (bf_contract.contract-date-end <> ? and bf_contract.contract-date-end < t-doc.doc-date))
          then do:
            message "Выбранный договор поставки закрыт или истёк срок его действия, оформить возврат невозможно. Обратитесь в офис для корректировки договора." view-as alert-box .
            run check-cli no-error.
            if error-status :error
            then return error .
            else return .
          end .
          if bf_contract.spec-check = 0
          then do :
            message "Для выбранного договора поставки не определена схема возврата, оформить возврат невозможно. Обратитесь в офис для корректировки договора." view-as alert-box .
            run check-cli no-error.
            if error-status :error
            then return error .
            else return .
          end .
          if not can-find(first buf_trn-reason no-lock where buf_trn-reason.reason-code = bf_contract.spec-check) then
          do:
            message "Для выбранного договора поставки не определена схема возврата, оформить возврат невозможно. Обратитесь в офис для корректировки договора." view-as alert-box .
            run check-cli no-error.
            if error-status :error
            then return error .
            else return .
          end.
        end .
        assign
          t-doc.contract-code = varcontract-code
          t-doc.exch-code     = bf_contract.curr-code
          t-doc.exch-rate     = varexch-rate
          t-doc.exch-scale    = varexch-scale
        .
        v-master = Is-Master-Slave-Contract( buffer bf_contract) .
        if v-master  = "+" or v-master  = ""  then do :
          find first bf-f_contract-specif no-lock where bf-f_contract-specif.contract-num = bf_contract.contract-code
                                                    and bf-f_contract-specif.host-code = bf_contract.host-code no-error.
        end.
        else do :
          find first bf-f_contract-specif no-lock where bf-f_contract-specif.contract-num =integer(v-master)
                                                    and bf-f_contract-specif.host-code = bf_contract.host-code no-error.
        end.
        if available bf-f_contract-specif then do:
          t-doc.vat-type = bf-f_contract-specif.vat-type .
        end.
        run chg-purch-contract in this-procedure.
      end.
    end.
  end.
else do:
  assign
    t-doc.contract-code  = 0.
end.
if varhold = "yes" then do:
  if paris-hold and
    input frame d-out-doc t-doc.cli-type = 'чел':U then do:
    message "Вы работаете со своими фирмами. Физическое лицо не может являться контрагентом."
    view-as alert-box.
    apply "entry" to t-doc.cli-code in frame d-out-doc.
    return error.
  end.
  if input frame d-out-doc t-doc.cli-type = 'орг':U then do:
    find first buf_sysconf no-lock
         where buf_sysconf.host-code = input frame d-out-doc t-doc.cli-code no-error.
  end.
  case t-doc.ext-doc-type :
    when 'ie':U then do:
      if paris-hold = yes then do:
        message "Критическая ошибка. Внешний приход между своими фирмами должен генериться автоматически."
        view-as alert-box error.
        apply "entry" to t-doc.cli-code in frame d-out-doc.
        return error.
      end.
      else do:
         if available buf_sysconf then do:
           message "Внешний приход оформляется от своей фирмы."
                   "Вы уверены?" view-as alert-box buttons yes-no update varlog.
           if varlog <> yes then do:
             apply "entry" to t-doc.cli-code in frame d-out-doc.
             return error.
           end.
define variable vss-include-info76 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_prepownfirmhold':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
           if varlog <> yes then do:
             apply "entry" to t-doc.cli-code in frame d-out-doc.
             return error.
           end.
           assign
             t-doc.hold-doc-code-child  = "no-hold":u
             t-doc.hold-doc-code-parent = "no-hold":u
           .
         end.
      end.
    end.
    when 'ee':U then do:
      if paris-hold = yes then do:
        if not available buf_sysconf then do:
          message
          "В данном пункте меню можно оформить расход только на свою фирму." skip
          view-as alert-box.
          apply "entry" to t-doc.cli-code in frame d-out-doc.
          return error.
        end.
        find first bf_clients where bf_clients.obj-type = 'орг':U         and
                                    bf_clients.obj-code = input frame d-out-doc t-doc.cli-code no-lock.
        run check-base-code in this-procedure (recid(bf_clients)).
        find first buf_firm where buf_firm.firm-code = buf_sysconf.host-code no-lock.
        run str/chshobj.w (input  input frame d-out-doc t-doc.cli-code,
                       input  buf_firm.main-obj-type,
                       input  buf_firm.main-obj-code,
                       output parhold-obj-type,
                       output parhold-obj-code ) no-error.
        if error-status :error then do:
          message
            "Ошибка при определении объекта при межфирменном перемещении."
            view-as alert-box.
          apply "entry" to t-doc.cli-code in frame d-out-doc.
          return error.
        end.
        if  parhold-obj-type = ""
        and parhold-obj-code = 0
        then do:
          message "Не выбран объект для межфирменного перемещения."
          view-as alert-box information.
          apply "entry" to t-doc.cli-code in frame d-out-doc.
          return error.
        end.
        find first buf-hold_clients where buf-hold_clients.obj-type = parhold-obj-type and
                                          buf-hold_clients.obj-code = parhold-obj-code no-lock no-error.
        if not available buf-hold_clients then do:
          message "Не верный объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения."
          view-as alert-box error.
          apply "entry" to t-doc.cli-code in frame d-out-doc.
          return error.
        end.
        if buf-hold_clients.obj-type <> 'маг':U  and
           buf-hold_clients.obj-type <> 'скл':U then do:
           message "Объект для межфирменном перемещения имеет тип " buf-hold_clients.obj-type " ." skip
                   "Он должен быть склад или магазин."
           view-as alert-box.
           apply "entry" to t-doc.cli-code in frame d-out-doc.
           return error.
        end.
        if buf-hold_clients.obj-type = 'маг':U then do:
          find first buf-hold_shop where buf-hold_shop.obj-code = buf-hold_clients.obj-code no-lock.
          if buf-hold_shop.host-code <> input frame d-out-doc t-doc.cli-code then do:
            message "Объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения не принадлежит фирме " input frame d-out-doc t-doc.cli-code " ."
            view-as alert-box error.
            apply "entry" to t-doc.cli-code in frame d-out-doc.
            return error.
          end.
        end.
        if buf-hold_clients.obj-type = 'скл':U then do:
          find first buf-hold_store where buf-hold_store.obj-code = buf-hold_clients.obj-code no-lock.
          if buf-hold_store.host-code <> input frame d-out-doc t-doc.cli-code then do:
            message "Объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения не принадлежит фирме " input frame d-out-doc t-doc.cli-code " ."
            view-as alert-box error.
            apply "entry" to t-doc.cli-code in frame d-out-doc.
            return error.
          end.
        end.
    run adm/shattri.p (
      input "get":U
      ,input parhold-obj-type
      ,input parhold-obj-code
      ,input 'contr-in':U
      ,input  "contr-in-income"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output varcontract-type
      ,INPUT-OUTPUT TABLE-handle v-tth
      ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "adm/shattri.p"
        view-as alert-box error
      .
      delete object v-tth.
      if v-value-logical = true then varcontract-cli = "yes" .
                                else varcontract-cli = "no" .
        assign
          t-doc.hold-obj-type        = parhold-obj-type
          t-doc.hold-obj-code        = parhold-obj-code
          t-doc.hold-doc-code-child  = "hold":u
          t-doc.hold-doc-code-parent = "hold":u.
        if varis-fin <> "yes" then do:
          assign
            t-doc.contract-code = 0.
        end.
        else do:
          if paris-hold = yes then do:
            if varcontract-code <> 0 then do:
              find first bf_contract where bf_contract.contract-code  = varcontract-code       no-lock no-error.
            end.
            else do:
            find first bf_contract where bf_contract.host-code = t-doc.host-code  and
                                        bf_contract.cli-type  = 'орг':U                                    and
                                        bf_contract.cli-code  = buf_sysconf.host-code                     no-lock no-error.
            end.
          if not available bf_contract then do:
            if varcontract-cli <> "yes" then do:
              assign
                t-doc.contract-code  = 0.
            end.
            else do:
              message "По клиенту " t-doc.host-code " " 'орг':U
                      " на фирме " input frame d-out-doc t-doc.cli-code " нет ни одного договора. Приход не может быть оформлен."
              view-as alert-box error.
              apply "entry" to t-doc.cli-code in frame d-out-doc.
              return error.
            end.
          end.
          else do:
            t-doc.contract-code = bf_contract.contract-code.
          end.
          end.
          else do:
          find first bf_contract where bf_contract.host-code = input frame d-out-doc t-doc.cli-code  and
                                       bf_contract.cli-type  = 'орг':U                                    and
                                       bf_contract.cli-code  = t-doc.host-code                           no-lock no-error.
          if not available bf_contract then do:
            if varcontract-cli <> "yes" then do:
              assign
                t-doc.contract-code  = 0.
            end.
            else do:
              message "По клиенту " t-doc.host-code " " 'орг':U
                      " на фирме " input frame d-out-doc t-doc.cli-code " нет ни одного договора. Приход не может быть оформлен."
              view-as alert-box error.
              apply "entry" to t-doc.cli-code in frame d-out-doc.
              return error.
            end.
          end.
          else do:
            run check-contract-code in this-procedure (input  "choose":u,
                                                       input  input frame d-out-doc t-doc.cli-code,
                                                       input  'орг':U,
                                                       input  t-doc.host-code,
                                                       input  ?,
                                                       input  parparentproc,
                                                       input  t-doc.doc-date,
                                                       input 'при':U,
                                                       output varcontract-code) no-error.
            if error-status :error    or
               varcontract-code = ?  or
               varcontract-code = 0  then do:
              if varcontract-cli <> "yes":u then do:
                message "Вы не выбрали договор. Вы хотите оформить внешний приход без договора?"
                view-as alert-box question buttons yes-no update varlog.
                if varlog = no then do:
                  return error.
                end.
                else do:
                  assign
                    t-doc.contract-code = 0.
                end.
              end.
              else do:
                message "Вы не выбрали договор. Приход не может быть оформлен."
                view-as alert-box error.
                apply "entry" to t-doc.cli-code in frame d-out-doc.
                return error.
              end.
            end.
            else do:
              assign
                t-doc.contract-code = varcontract-code.
            end.
          end.
          end.
        end.
      end.
      else do:
        if available buf_sysconf then do:
          message "В данном пункте меню можно оформить расход только на внешнего контрагента."
          "Вы хотите оформить расход на свою фирму, как на внешнего контрагента, без автоматической генерации прихода?"
          view-as alert-box question buttons yes-no update varlog.
          if varlog <> yes then do:
            apply "entry" to t-doc.cli-code in frame d-out-doc.
            return error.
          end.
          else do:
define variable vss-include-info77 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_prepownfirmhold':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
            if varlog <> yes then do:
              apply "entry" to t-doc.cli-code in frame d-out-doc.
              return error.
            end.
            else do:
              assign
                t-doc.hold-doc-code-child  = "no-hold":u
                t-doc.hold-doc-code-parent = "no-hold":u .
            end.
          end.
        end.
      end.
    end.
    when 're':U then do:
      if available buf_sysconf then do:
        message "Вы хотите оформить возврат от своей фирмы, как от внешнего контрагента?"
        view-as alert-box question buttons yes-no update varlog.
        if varlog <> yes then do:
          apply "entry" to t-doc.cli-code in frame d-out-doc.
          return error.
        end.
        else do:
define variable vss-include-info78 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_prepownfirmhold':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
          if varlog <> yes then do:
            apply "entry" to t-doc.cli-code in frame d-out-doc.
            return error.
          end.
        end.
      end.
    end.
    when 'ep':U then do:
      if paris-hold = yes then do:
        if not available buf_sysconf then do:
          message
          "В данном пункте меню можно оформить возврат поставщику только на свою фирму." skip
          view-as alert-box.
          apply "entry" to t-doc.cli-code in frame d-out-doc.
          return error.
        end.
        find first buf_firm where buf_firm.firm-code = buf_sysconf.host-code no-lock.
        find first bf_clients where bf_clients.obj-type = 'орг':U         and
                                    bf_clients.obj-code = input frame d-out-doc t-doc.cli-code no-lock.
        run check-base-code in this-procedure (recid(bf_clients)).
        run str/chshobj.w (input  input frame d-out-doc t-doc.cli-code,
                       input  buf_firm.main-obj-type,
                       input  buf_firm.main-obj-code,
                       output parhold-obj-type,
                       output parhold-obj-code ) no-error.
        if error-status :error then do:
          message
            "Ошибка при определении объекта при межфирменном перемещении."
            view-as alert-box.
          apply "entry" to t-doc.cli-code in frame d-out-doc.
          return error.
        end.
        if  parhold-obj-type = ""
        and parhold-obj-code = 0
        then do:
          message "Не выбран объект для межфирменного перемещения."
          view-as alert-box information.
          apply "entry" to t-doc.cli-code in frame d-out-doc.
          return error.
        end.
        find first buf-hold_clients where buf-hold_clients.obj-type = parhold-obj-type and
                                          buf-hold_clients.obj-code = parhold-obj-code no-lock no-error.
        if not available buf-hold_clients then do:
          message "Не верный объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения."
          view-as alert-box error.
          apply "entry" to t-doc.cli-code in frame d-out-doc.
          return error.
        end.
        if buf-hold_clients.obj-type <> 'маг':U  and
           buf-hold_clients.obj-type <> 'скл':U then do:
           message "Объект для межфирменном перемещения имеет тип " buf-hold_clients.obj-type " ." skip
                   "Он должен быть склад или магазин."
           view-as alert-box.
           apply "entry" to t-doc.cli-code in frame d-out-doc.
           return error.
        end.
        if buf-hold_clients.obj-type = 'маг':U then do:
          find first buf-hold_shop where buf-hold_shop.obj-code = buf-hold_clients.obj-code no-lock.
          if buf-hold_shop.host-code <> input frame d-out-doc t-doc.cli-code then do:
            message "Объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения не принадлежит фирме " input frame d-out-doc t-doc.cli-code " ."
            view-as alert-box error.
            apply "entry" to t-doc.cli-code in frame d-out-doc.
            return error.
          end.
        end.
        if buf-hold_clients.obj-type = 'скл':U then do:
          find first buf-hold_store where buf-hold_store.obj-code = buf-hold_clients.obj-code no-lock.
          if buf-hold_store.host-code <> input frame d-out-doc t-doc.cli-code then do:
            message "Объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения не принадлежит фирме " input frame d-out-doc t-doc.cli-code " ."
            view-as alert-box error.
            apply "entry" to t-doc.cli-code in frame d-out-doc.
            return error.
          end.
        end.
        assign
          t-doc.hold-obj-type        = parhold-obj-type
          t-doc.hold-obj-code        = parhold-obj-code
          t-doc.hold-doc-code-child  = "hold":u
          t-doc.hold-doc-code-parent = "hold":u.
      end.
      else do:
        if available buf_sysconf then do:
          message "В данном пункте меню можно оформить возврат поставщику только на внешнего контрагента."
          "Вы хотите оформить возврат поставщику на свою фирму, как на внешнего контрагента, без автоматической генерации возврата от покупателя?"
          view-as alert-box question buttons yes-no update varlog.
          if varlog <> yes then do:
            apply "entry" to t-doc.cli-code in frame d-out-doc.
            return error.
          end.
          else do:
define variable vss-include-info79 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_prepownfirmhold':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
            if varlog <> yes then do:
              apply "entry" to t-doc.cli-code in frame d-out-doc.
              return error.
            end.
            else do:
              assign
                t-doc.hold-doc-code-child  = "no-hold":u
                t-doc.hold-doc-code-parent = "no-hold":u .
            end.
          end.
        end.
      end.
    end.
    otherwise do:
    end.
  end case.
end.
assign
  t-doc.cli-code = input frame d-out-doc t-doc.cli-code
  t-doc.cli-type = input frame d-out-doc t-doc.cli-type.
display ub.clients.obj-name with frame d-out-doc.
pardoc-mode = 'ИЗМЕНЕНИЕ':U.
if ub.clients.obj-type = 'орг':U then do:
  find ub.firm where ub.firm.firm-code = ub.clients.obj-code no-lock.
  find ub.clients where ub.clients.obj-type = 'чел':U
                        and ub.clients.obj-code = ub.firm.tobj-code no-lock no-error.
  if available ub.clients then
    display ub.clients.obj-code @ t-doc.boss
            ub.clients.obj-name @ boss-name with frame d-out-doc.
end.
release ub.clients.
if t-doc.internal then do:
  assign
    t-doc.print-rubl = (if varr-b = "base":u then no else yes).
end.
else do:
  assign
    t-doc.print-rubl = yes.
end.
if not(not t-doc.internal and t-doc.doc-type = 'возврат':U) then do:
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-today
  )  .
  ASSIGN
    t-doc.rsrv-date = v-today + v-cntxp-rsrv-time
  .
end.
if t-doc.doc-type = 'рас':U and
   t-doc.internal = no         then do:
  display t-doc.pay-code with frame d-out-doc.
  if t-doc.ret-supp = no then do:
    find first ub.dis-card where ub.dis-card.cli-type = t-doc.cli-type and
                              ub.dis-card.cli-code = t-doc.cli-code and
                              ub.dis-card.emitent-host-code = t-doc.host-code and
                              ub.dis-card.status_           = 'тек':U OR
                              ub.dis-card.cli-type = t-doc.cli-type and
                              ub.dis-card.cli-code = t-doc.cli-code and
                              ub.dis-card.emitent-host-code = 0 and
                              ub.dis-card.status_           = 'тек':U no-lock no-error.
    if available ub.dis-card then do:
      varlog = no.
      message "На выбранного клиента зарегистрирована одна или более дисконтных карт." skip
                      "Первая из них: №" ub.dis-card.d-card "Скидка:" ub.dis-card.d-pcnt "%" skip (2)
                      "Подставить эту скидку в счет ?"
                      view-as alert-box question buttons yes-no update varlog.
      if varlog then do:
        assign
          t-doc.discnt-pc   = ub.dis-card.d-pcnt
          t-doc.discnt-type = 'карта':U
          t-doc.d-card      = ub.dis-card.d-card.
      end.
    end.
  end.
end.
if t-doc.doc-type = 'рас':U and
   t-doc.internal = yes        and
   varintprmvq    = yes    then do:
  if t-doc.cli-type = 'маг':U then do:
     find bf_shop where bf_shop.obj-code = t-doc.cli-code no-lock.
     assign
       varis-perm = bf_shop.in-perm.
  end.
  if varis-perm <> yes then do:
    run gbl/d-askw.w
      (input "Вопрос"
      ,input "По каким ценам будем делать внутренний расход, объекта приемника или объекта источника?"
      ,input "|^"
      ,input "Цена источника|"
           + "Цена приемника|"
           + "Отмена"
      ,input "Исходя из цен объекта " + t-doc.obj-type + " " + string(t-doc.obj-code) + ".|"
           + "Исходя из цен объекта " + t-doc.cli-type + " " + string(t-doc.cli-code) + ".|"
           + "Отменить."
      ,input 1
      ,input 3
      ,output v-num
      ).
    if v-num = 3 then do:
      return error.
    end.
    if v-num = 2 then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'price-target':U ,
                       input 'yes':U ) no-error .
      if error-status :error then do:
        message "Ошибка при записи атрибута документа." skip
                return-value skip
        view-as alert-box error.
        return error.
      end.
    end.
  end.
end.
run UI-on ("enable").
if b-add:sensitive = yes then apply "entry" to b-add in frame d-out-doc.
end.
end procedure.
procedure check-rate :
define variable varbase-code as integer no-undo.
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output varbase-code
  )  .
if input frame d-out-doc t-doc.base-rate = ? or
   input frame d-out-doc t-doc.base-rate = 0 then do:
  message "Не задан курс базовой валюты.".
  apply "entry" to t-doc.base-rate in frame d-out-doc.
  return error.
end.
if input frame d-out-doc t-doc.base-scale = ? or
   input frame d-out-doc t-doc.base-scale = 0 then do:
  message "Не задан масштаб базовой валюты.".
  apply "entry" to t-doc.base-scale in frame d-out-doc.
  return error.
end.
assign frame d-out-doc
  t-doc.base-rate
  t-doc.base-scale.
if t-doc.print-rubl then
  assign
    t-doc.exch-code  = 0
    t-doc.exch-rate  = 1
    t-doc.exch-scale = 1.
else
  assign
    t-doc.exch-code  = varbase-code
    t-doc.exch-rate  = t-doc.base-rate
    t-doc.exch-scale = t-doc.base-scale.
end procedure.
procedure mode-on :
define variable varout-ret-supp like ub.trn-doc.ret-supp no-undo.
define variable varout-pay-code like ub.trn-doc.pay-code no-undo.
define variable vardoc-code     like ub.trn-doc.doc-code no-undo.
define variable v-today         as date                  no-undo.
define buffer cli_clients  for ub.clients.
define buffer cli_firm     for ub.firm.
define buffer main_clients for ub.clients.
define buffer cli_sysconf  for ub.sysconf.
define variable varpurch-code as integer   no-undo.
define variable varbase-code as integer no-undo.
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output varbase-code
  )  .
do on error undo, return error :
case pardoc-mode :
  when 'ДОБАВЛЕНИЕ':U then do:
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
    find last ub.curr-accnt where ub.curr-accnt.curr-code = varbase-code
        and ub.curr-accnt.exch-date <= v-today use-index pi no-lock no-error.
    if not available ub.curr-accnt then do:
      message "На дату" v-today "неизвестен курс базовой валюты.".
      undo, return error.
    end.
    if v-cntxt-db-num-obj <> v-cntxt-db-num and parstat <> 'запрос':U  then do:
      message "Накладная не может быть выписана на пассивной стороне."
                      "Используйте запрос.".
      undo, return error.
    end.
    if parinternal = ? then do:
      message "Неизвестно, внутренний или внешний документ.".
      undo, return error.
    end.
    if parinternal and partype = 'возврат':U then do:
      message "Для внутреннего перемещения можно создать только расход."
                      "Остальные документы создаются автоматически.".
      undo, return error.
    end.
    case partype :
     when 'при':U    then do:
       assign
       varout-ret-supp = no.
       varout-pay-code = v-cntxp-out-pay.
     end.
     when 'рас':U   then do:
        if parext-doc-type = 'ep':U then do:
           assign
           varout-ret-supp = yes
           varout-pay-code = v-cntxp-ret-sup-pay.
        end.
        else do:
          assign
          varout-pay-code = v-cntxp-out-pay.
        end.
     end.
     when 'спи':U then do:
       assign
       varout-ret-supp = no
       varout-pay-code = v-cntxp-down-pay.
     end.
     when 'возврат':U then do:
       assign
       varout-ret-supp = no.
       varout-pay-code = v-cntxp-ret-pay.
     end.
    end case.
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
    run doc-code in this-procedure
      (input  "main",
       input  v-cntxt-obj-type,
       input  v-cntxt-obj-code,
       input  ?,
       output vardoc-code ) no-error.
    if error-status :error then do:
      message "Ошибка при генерации номера документа." return-value view-as alert-box.
      return error.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input ub.curr-accnt.exch-rate
,input ub.curr-accnt.exch-scale
,input ?
,input ?
,input ?
,input v-cntxt-db-num
,input v-cntxt-userid
,input  'процент':U
,input vardoc-code
,input v-today
,input  partype
,input no
,input v-cntxt-host-code-obj
,input parinternal
,input v-cntxt-obj-code
,input v-cntxt-obj-type
,input no
,input  varout-pay-code
,input '@  '
,input  varout-ret-supp
,input  ?
,input  parstat
,input  ?
,input parext-doc-type
,input
        ?
) no-error
.
    if error-status :error then do:
      undo, return error return-value.
    end.
    find t-doc where t-doc.doc-code = vardoc-code.
    assign
      pardoc-rec = recid (t-doc)
      .
       if not can-find(first ub.pay-type where ub.pay-type.obj-code = t-doc.pay-code no-lock) then do:
          case t-doc.doc-type :
            when 'при':U or  when 'рас':U then
               message "В настройках текущего объекта указан вид оплаты: " v-cntxp-out-pay ", которого нет в справочнике!"
                   view-as alert-box error buttons ok.
            when 'спи':U then
              message "В настройках текущего объекта указан вид оплаты списания: " v-cntxp-down-pay ", которого нет в справочнике!"
                   view-as alert-box error buttons ok.
            when 'возврат':U then
             message "В настройках текущего объекта указан вид оплаты возврата: " v-cntxp-ret-pay ", которого нет в справочнике!"
                   view-as alert-box error buttons ok.
          end.
          undo, return error.
       end.
  end.
  when 'ПРОСМОТР':U then do:
    find t-doc no-lock where recid( t-doc ) = pardoc-rec no-error.
    if available t-doc then do:
      if t-doc.internal = ? then do:
        message "Документ был заведен неверно и удаляется!!!" view-as alert-box.
        find t-doc exclusive-lock where recid( t-doc ) = pardoc-rec.
        delete t-doc.
        return.
      end.
      if parext-doc-mode <> "":U then do:
        find t-doc exclusive-lock where recid( t-doc ) = pardoc-rec.
      end.
    end.
  end.
  when 'ИЗМЕНЕНИЕ':U then do:
    find t-doc where recid (t-doc) = pardoc-rec no-error.
    if available t-doc then do:
      if t-doc.cli-code = ? then do:
        message "Документ был заведен неверно и удаляется!!!" view-as alert-box.
        delete t-doc.
        return.
      end.
      if t-doc.flag_ = yes and t-doc.status_ = 'накл':U and t-doc.doc-type <> 'при':U and t-doc.ext-doc-type <> 'eo':U then do:
        find t-doc where recid (t-doc) = pardoc-rec.
        message "Факт. кол-во можно проставлять только в статусе разрешен.".
        undo, return error.
      end.
      if t-doc.status_ = 'касс':U then do:
        find t-doc where recid (t-doc) = pardoc-rec.
        message "Все действия с кассовыми отчетами выполняются из АРМ Магазин.".
        undo, return error.
      end.
      if t-doc.status_ = 'факт':U or
         (t-doc.flag_ = yes and t-doc.status_ = 'запрос':U) then do:
        find t-doc where recid (t-doc) = pardoc-rec.
        message "Документ уже закрыт. Изменение невозможно.".
        undo, return error.
      end.
      if  t-doc.flag_ = yes
      then do:
        define variable v-obj-active  as logical   no-undo .
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,input  'active=request':u
  ,output v-obj-active
  )  .
        if v-obj-active <> true
        then do:
          find t-doc
            where recid (t-doc) = pardoc-rec.
          message
            "Коррекция фактического количества допустима только в базе данных объекта" skip
            "Документ" t-doc.doc-code skip
            "Объект" t-doc.obj-type t-doc.obj-code skip
            view-as alert-box information .
          undo, return error.
        end.
      end.
      find t-doc exclusive-lock
        where recid (t-doc) = pardoc-rec
        .
    end.
  end.
end.
if not available t-doc
then do:
  message "Неправильно выбран документ.".
  undo, return error.
end.
end.
end procedure.
procedure recalc-slt:
def var v-slt-pc        like ub.doc-line.slt-pc    no-undo.
def var v-host-code     like ub.sysconf.host-code  no-undo.
do on error undo, return error return-value :
find ub.sysconf where ub.sysconf.host-code = v-cntxt-host-code-obj no-lock.
if t-doc.pay-code = ub.sysconf.cash-pay then t-doc.slt-type = 'в т. ч.':U.
define variable vss-include-info86 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-host-code
  )  .
for each ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code exclusive,
    each ub.goods where ub.goods.artic     = ub.doc-line.artic and
                     ub.goods.prod-code = ub.doc-line.prod-code and
                     ub.goods.prod-type = ub.doc-line.prod-type no-lock on error undo, return error return-value :
  if t-doc.pay-code = ub.sysconf.cash-pay
     and not t-doc.internal
     and can-do ('рас,возврат':U, t-doc.doc-type)
  then do:
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-slt-pc
  ) no-error .
     assign ub.doc-line.slt-pc =  v-slt-PC.
  end.
  else do:
     assign ub.doc-line.slt-pc =  0.
  end.
end.
run gbl/calc-trn.p (input parparentproc, input recid(t-doc)).
end.
end procedure.
procedure notes-tr:
define variable notes as character no-undo.
assign
  notes = t-doc.PS.
if pardoc-mode = 'ПРОСМОТР':U then do:
  run gbl/d-prompt.w (
      'title=Примечание\'
    + 'type=editor\'
    + 'fillin_width=96\'
    + 'fillin_height=15\'
    + 'readonly=yes\'
    , input-output notes).
end.
else do:
   run gbl/d-prompt.w (
      'title=примечание\'
    + 'type=editor\'
    + 'fillin_width=96\'
    + 'fillin_height=15\'
    , input-output notes).
    if return-value = 'false':u then return .
  if t-doc.PS <> notes then do:
  if pardoc-rec = ? then pardoc-rec = recid (t-doc).
    do transaction on error undo, return error return-value :
      find t-doc where recid (t-doc) = pardoc-rec exclusive.
      assign
        t-doc.PS = notes.
    end.
  end.
end.
end procedure.
procedure choose-cli:
define variable varfirm-code like ub.firm.firm-code no-undo.
define variable v-types as character no-undo .
define buffer bf_clients for ub.clients.
define variable ref-rec as recid no-undo.
define variable v-rid-list as character no-undo .
do on error undo, return error return-value :
run check-cli no-error.
if error-status :error then do:
  if t-doc.internal then v-types = 'маг':U.
                    else v-types = 'все':U.
  if (t-doc.ext-doc-type = 'ee':U or t-doc.ext-doc-type = 'ep':U) and
     varhold            = "yes"              and
     paris-hold         = yes                then do:
    assign
      varfirm-code = ?.
    run adm/sconfs.w ( input parparentproc
                    , input "b-sel":U
                    , input no
                    , input ?
                    , output varfirm-code
                    , input-output v-rid-list) no-error.
    if error-status :error or
       varfirm-code = ?   then do:
      return error.
    end.
    find first bf_clients where bf_clients.obj-type = 'орг':U       and
                                bf_clients.obj-code = varfirm-code no-lock.
    assign ref-list = string(recid (bf_clients)).
    run check-base-code in this-procedure (recid(bf_clients)).
  end.
  else do:
    if transaction = yes then do:
      message "Критическая ошибка." skip
              "Вы находитесь в транзакции." skip
              "Работа со справочником клиентов невозможна."
      view-as alert-box error.
      return error.
    end.
    run ref/cli-all.w ( parparentproc
                   , "b-sel,b-add"
                   , v-types
                   , ?
                   , ?
                   , ?
                   , ?
                   , ?
                  , output ref-list) .
  end.
  if ref-list <> "" then do:
    ref-rec = integer (ref-list).
    find ub.clients where recid ( ub.clients ) = ref-rec no-lock.
    disp ub.clients.obj-code @ t-doc.cli-code
            ub.clients.obj-name with frame d-out-doc.
  if pardoc-mode = 'ДОБАВЛЕНИЕ':U then
    disp ub.clients.obj-type @ t-doc.cli-type with frame d-out-doc.
  end.
  run check-cli no-error.
  if error-status :error then do:
    return error return-value.
  end.
end.
end.
end procedure.
procedure state-pay-code:
do transaction on error undo, return error :
   if input frame d-out-doc t-doc.pay-code = v-cntxp-ret-sup-pay then do:
      message "Нельзя устанавливаться код возврата поставщику." skip
              "Возврат поставщику оформляется из отдельнего пункта меню."
      view-as alert-box error.
      undo, return error.
   end.
   assign t-doc.pay-code = input frame d-out-doc t-doc.pay-code no-error.
   if t-doc.ext-doc-type = 'iv':U
   then do :
     for each ub.parts where ub.parts.out-code = t-doc.doc-code:
       assign ub.parts.pay-code = t-doc.pay-code.
     end.
   end .
   else do :
     run recalc-slt in this-procedure.
   end .
end.
   run ui-on("line").
end procedure.
procedure return-pay-code:
if input frame d-out-doc t-doc.pay-code <> t-doc.pay-code then do:
   if input frame d-out-doc t-doc.pay-code = v-cntxp-ret-sup-pay then do:
      message "Нельзя устанавливаться код возврата поставщику." skip
              "Возврат поставщику оформляется из отдельнего пункта меню."
      view-as alert-box error.
      display t-doc.pay-code with frame d-out-doc.
      return error.
   end.
end.
find ub.pay-type where ub.pay-type.obj-code = input frame d-out-doc t-doc.pay-code no-lock no-error.
if not available ub.pay-type then apply "choose" to r-pay.
end procedure.
procedure choose-r-pay:
define variable varrecid-pay as recid no-undo.
define variable v-rid-list as character no-undo .
run ref/paytype.w (input parparentproc, "b-sel", output v-rid-list ).
find ub.pay-type where recid ( ub.pay-type ) = integer(v-rid-list) no-lock no-error.
if not available ub.pay-type then return no-apply.
if ub.pay-type.obj-code = v-cntxp-ret-sup-pay then do:
   message "Нельзя устанавливаться код возврата поставщику." skip
           "Возврат поставщику оформляется из отдельнего пункта меню."
   view-as alert-box error.
   display t-doc.pay-code with frame d-out-doc.
   return error.
end.
display ub.pay-type.obj-code @ t-doc.pay-code with frame d-out-doc.
assign varrecid-pay = recid(ub.pay-type).
run state-pay-code no-error.
if error-status :error then do:
  display t-doc.pay-code with frame d-out-doc.
  apply "entry" to t-doc.pay-code in frame d-out-doc.
  return error.
end.
find ub.pay-type where recid(ub.pay-type) = varrecid-pay no-lock.
display t-doc.pay-code ub.pay-type.obj-name with frame d-out-doc.
end procedure.
procedure leave-pay-code:
define variable varrecid-pay as recid no-undo.
if input frame d-out-doc t-doc.pay-code = v-cntxp-ret-sup-pay then do:
   message "Нельзя устанавливаться код возврата поставщику." skip
           "Возврат поставщику оформляется из отдельнего пункта меню."
   view-as alert-box error.
   display t-doc.pay-code with frame d-out-doc.
   return error.
end.
find ub.pay-type where ub.pay-type.obj-code = input frame d-out-doc t-doc.pay-code no-lock no-error.
if not available ub.pay-type then do:
  message "Нет вида оплаты с таким кодом.".
  display t-doc.pay-code with frame d-out-doc.
  apply "entry" to t-doc.pay-code in frame d-out-doc.
  return error.
end.
assign varrecid-pay = recid(ub.pay-type).
run state-pay-code no-error.
if error-status :error then do:
  display t-doc.pay-code with frame d-out-doc.
  apply "entry" to t-doc.pay-code in frame d-out-doc.
  return error.
end.
find ub.pay-type where recid(ub.pay-type) = varrecid-pay no-lock.
display ub.pay-type.obj-name with frame d-out-doc.
end procedure.
procedure proc-exit :
  define variable v-vat-pc   as decimal no-undo .
  define variable v-slt-pc   as decimal no-undo .
  define variable v-insalepr as logical no-undo .
  assign parnext-prev = ?.
  if lookup( pardoc-mode, 'ДОБАВЛЕНИЕ':U ) > 0 then do:
    if not can-find (first ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code no-lock) then do:
      delete t-doc.
      assign pardoc-rec = ?.
    end.
    return.
  end.
  if lookup( pardoc-mode, 'ИЗМЕНЕНИЕ':U ) > 0 then do:
    if not can-find (first ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code no-lock) and t-doc.is-flora = false then do:
      assign varlog = true .
      message "В документе нет строк, поэтому он удаляется." view-as alert-box question buttons OK-Cancel update varlog.
      if varlog = yes then do:
        if t-doc.is-flora = false then do:
            define variable varchip-code as decimal   no-undo .
                  run str/del-doc.p
                      ( input  parparentproc,
                        input  t-doc.doc-code,
                        input  v-cntxt-db-num,
                        input  "del-doc.err",
                        input  ?,
                        input  ?,
                        input  v-cntxt-userid,
                        input  t-doc.doc-code,
                        input  ?,
                        output varchip-code )
                        .
          assign pardoc-rec = ?.
          return.
        end.
        else do:
          assign varlog = false .
          message "ВНИМАНИЕ !!! Документ удалится, так как в нем НЕТ ТОВАРОВ!!!"
                     view-as alert-box  question buttons OK-Cancel update varlog .
          if varlog = yes then do:
            delete t-doc.
            assign pardoc-rec = ?.
            return.
          end.
          return error.
        end.
      end.
      else do: return error. end.
    end.
    run check-rate no-error.
    if error-status :error then do: return error. end.
    assign frame d-out-doc t-doc.wrkr t-doc.agnt t-doc.boss .
    define variable v-err as logical   no-undo .
    run str/ver-fl.p ( input pardoc-mode, input t-doc.doc-code , output v-err ) no-error .
    if error-status :error then return error.
  end.
  if t-doc.ext-doc-type = 'ep':U  and pardoc-mode <> 'ПРОСМОТР':U then do:
     run str/ep-corrp.p (input parparentproc , input t-doc.doc-code ) no-error.
  end.
  run fill-mol in this-procedure.
end procedure.
procedure check-base-code :
define input parameter parrec-id as recid no-undo.
define variable varmy-host-code  like ub.sysconf.host-code no-undo.
define variable varmy-base-code  like ub.sysconf.base-code no-undo.
define variable varcli-base-code like ub.sysconf.base-code no-undo.
define buffer bf-my_currency  for ub.currency.
define buffer bf-cli_currency for ub.currency.
define buffer bf_clients for ub.clients.
do on error undo, return error return-value :
  find first bf_clients where recid(bf_clients) = parrec-id no-lock.
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output varmy-host-code
  ) no-error .
  if error-status :error then do:
    message "Ошибка при поиске фирмы для объекта " v-cntxt-obj-type " " v-cntxt-obj-code " ." skip
            return-value skip
            error-status :get-message( 1 )
    view-as alert-box error.
    return no-apply.
  end.
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  varmy-host-code
  ,output varmy-base-code
  ) no-error .
  if error-status :error then do:
    message "Ошибка при поиске базовой валюты для фирмы " varmy-base-code " ." skip
            return-value skip
            error-status :get-message( 1 )
    view-as alert-box error.
    return no-apply.
  end.
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  bf_clients.obj-code
  ,output varcli-base-code
  ) no-error .
  if error-status :error then do:
    message "Ошибка при поиске базовой валюты для фирмы " bf_clients.obj-code " ." skip
            return-value skip
            error-status :get-message( 1 )
    view-as alert-box error.
    return no-apply.
  end.
  if varmy-base-code <> varcli-base-code then do:
    find first bf-my_currency  where bf-my_currency.curr-code  = varmy-base-code  no-lock.
    find first bf-cli_currency where bf-cli_currency.curr-code = varcli-base-code no-lock.
    message "Несоответствие базовых валют фирм при межфирменном перемещении." skip
            "У нашей фирмы " varmy-host-code " базовая валюта " bf-my_currency.curr-abbr " " bf-my_currency.curr-name " с кодом " bf-my_currency.curr-code " ." skip
            "У фирмы контрагента " bf_clients.obj-code " базовая валюта " bf-cli_currency.curr-abbr " " bf-cli_currency.curr-name " с кодом " bf-cli_currency.curr-code " ." skip
            "Межфирменное перемещение невозможно."
    view-as alert-box error.
    return error.
  end.
end.
end procedure.
procedure proc-history :
  define variable loc-ref-list as character no-undo.
  define variable loc-doc-save as recid     no-undo.
  define variable loc-mode     as character no-undo.
  define variable loc#stat     as character no-undo.
  define variable loc#type     as character no-undo.
  define variable loc#internal as logical   no-undo.
  define buffer buffer_trn-doc for ub.trn-doc.
  do on error undo, return error return-value :
    if not available ub.gds-dtl then do:
      message "Неправильный выбор записи." view-as alert-box.
      return error.
    end.
    find buffer_trn-doc no-lock where buffer_trn-doc.doc-code = ub.gds-dtl.doc-code.
    assign pardoc-rec      = recid( ub.gds-dtl ).
define variable vss-include-info91 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_c-documents_all':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
    if varlog <> yes then do: return no-apply. end.
    run str/calldocs.w (  input  parparentproc,
                      input  'doc':U,
                      input  buffer_trn-doc.status_,
                      input  buffer_trn-doc.doc-type,
                      input  buffer_trn-doc.flag_,
                      input  buffer_trn-doc.internal,
                      input  "":U,
                      input  buffer_trn-doc.doc-code,
                      input  paris-hold ,
                      input  recid(buffer_trn-doc),
                      input  ub.gds-dtl.obj-type,
                      input  ub.gds-dtl.obj-code,
                      output loc-ref-list ).
    apply "ENTRY":U to br-dtl in frame d-out-doc.
  end.
  end procedure.
procedure fill-mol:
  if pardoc-mode = 'ИЗМЕНЕНИЕ':U or pardoc-mode = 'ДОБАВЛЕНИЕ':U
  then
  do:
    find first ub.user-account no-lock where ub.user-account.user-id = v-cntxt-userid.
    if ub.user-account.psn-code <> 0 and ub.user-account.psn-code <> ?
      then
    do:
      if t-doc.boss = ? then do:
        t-doc.boss:screen-value in frame d-out-doc = string (ub.user-account.psn-code).
        apply "leave" to t-doc.boss in frame d-out-doc.
      end.
      if t-doc.wrkr = ?
      then do:
        t-doc.wrkr:screen-value in frame d-out-doc = string (ub.user-account.psn-code).
        apply "leave" to t-doc.wrkr in frame d-out-doc.
      end.
      t-doc.agnt:screen-value in frame d-out-doc = string (ub.user-account.psn-code).
      apply "leave" to t-doc.agnt in frame d-out-doc.
    end.
    release ub.user-account.
  end.
end.
on return, leave of t-doc.tot-calc in frame d-out-doc do:
if input frame d-out-doc t-doc.tot-calc <> t-doc.tot-calc then do:
  assign t-doc.tot-calc = input frame d-out-doc t-doc.tot-calc.
  run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
  if error-status :error then undo, return no-apply.
  run ui-on ("line").
end.
end.
on return, leave of t-doc.discnt-rubl in frame d-out-doc do:
  if input frame d-out-doc t-doc.discnt-rubl <> t-doc.discnt-rubl then do:
    assign
      frame d-out-doc t-doc.discnt-rubl.
    run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
    if error-status :error then do:
      undo, return no-apply.
    end.
    run ui-on ("line").
  end.
end.
on mouse-select-dblclick, return of t-doc.out-code in frame d-out-doc
do:
define buffer tdb_doc-line for ub.doc-line.
define buffer tdb_gds-dtl  for ub.gds-dtl.
find t-d-b where t-d-b.doc-code = input frame d-out-doc t-doc.out-code no-lock no-error.
if not available t-d-b then do:
  apply "choose" to r-outs in frame d-out-doc.
  return no-apply.
end.
run ask-copy in this-procedure no-error .
if error-status :error then return no-apply .
end.
on choose of menu-item m-outs-1 do:
if not b-add:sensitive in frame d-out-doc then do:
  message "Добавление строк для этого статуса запрещено.".
  return no-apply.
end.
apply "row-leave" to browse br-dtl.
if t-doc.ext-doc-type = 'ee':U
then do :
  if t-doc.reason-code <> ?
  and t-doc.reason-code > 0
  then do :
    if lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
    and t-doc.ext-doc-type = 'ee':U
    then do :
      if v-is-return
      then do :
        run local-outs-ret-doc no-error.
        if error-status :error then undo, return no-apply.
      end .
      else do :
        run local-m-outs-1-ret no-error.
        if error-status :error then undo, return no-apply.
      end .
    end.
    else do :
      run local-m-outs-1 no-error.
      if error-status :error then undo, return no-apply.
    end.
  end.
  else do :
    if v-reasonm and
    lookup( t-doc.ext-doc-type, v-reasonme) = 0 and
    lookup( t-doc.ext-doc-type, 'es,em,wm,im,ot,rs,mp,pc':U) = 0
    then do:
      message "Сначала укажите Основание" view-as alert-box .
      apply "choose" to r-reas in frame d-out-doc.
    end.
    else do :
      run local-m-outs-1 no-error.
      if error-status :error then undo, return no-apply.
    end.
  end.
end.
else do :
  run local-m-outs-1 no-error.
  if error-status :error then undo, return no-apply.
  if t-doc.ext-doc-type = 'ep':U  then do:
     run str/ep-corrp.p (input parparentproc, input t-doc.doc-code ) no-error.
  end.
end.
run ui-on ("line").
apply "entry" to br-dtl in frame d-out-doc.
end.
on choose of menu-item m-outs-10
  do:
    define variable old-mode     as character no-undo.
    define variable old-handle   as handle    no-undo.
    define variable old-type     as character no-undo.
    define variable old-stat     as character no-undo.
    define variable old-flag     as logical   no-undo.
    define variable old-internal as logical   no-undo.
    if not b-add:sensitive in frame d-out-doc then
    do:
      message "Добавление строк для этого статуса запрещено.".
      return no-apply.
    end.
    apply "row-leave" to browse br-dtl.
    do transaction:
      run check-rate no-error.
      if error-status :error then return no-apply.
      run str/gds-list.w (parparentproc, t-doc.host-code, t-doc.obj-type, t-doc.obj-code).
      pardoc-rec = recid (t-doc).
      run waitfram-show in this-procedure (input "ЖДИТЕ.  Список добавляется в документ...").
      run copy-lst in this-procedure (
        input t-doc.doc-code,
        input ub.sysconf.cash-pay,
        input v-cntxp-doc-prt,
        input table gds-list,
        input "tech-marks")
        no-error.
      if error-status :error then
      do:
        apply "entry" to b-add in frame d-out-doc.
        run waitfram-hide in this-procedure .
        return no-apply.
      end.
      run waitfram-hide in this-procedure .
      run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
      if error-status :error then
      do:
        undo, return no-apply.
      end.
    end.
    pardoc-mode = 'ИЗМЕНЕНИЕ':U.
    run ui-on ("line").
    apply "entry" to br-dtl in frame d-out-doc.
  end.
on choose of menu-item m-outs-5 do:
if not b-add:sensitive in frame d-out-doc then do:
  message "Добавление строк для этого статуса запрещено.".
  return no-apply.
end.
apply "row-leave" to browse br-dtl.
run local-m-outs-5 no-error.
if error-status :error then undo, return no-apply.
if t-doc.ext-doc-type = 'ep':U  then do:
   run str/ep-corrp.p (input parparentproc, input t-doc.doc-code ) no-error.
end.
run ui-on ("line").
apply "entry" to br-dtl in frame d-out-doc.
end.
on choose of menu-item m-outs-2 do:
apply "row-leave" to browse br-dtl.
do transaction :
   if b-add:sensitive in frame d-out-doc then do:
      run check-rate no-error.
      if error-status :error then return no-apply.
   end.
   run str/scan.p (parparentproc, b-add:sensitive , input recid(t-doc)  , input ?) no-error.
   if error-status :error then undo, return no-apply.
   if t-doc.ext-doc-type = 'ep':U  then do:
      run str/ep-corrp.p ( input parparentproc, input t-doc.doc-code ) no-error.
    end.
   else do:
      run gbl/calc-trn.p ( input parparentproc, input recid(t-doc)) no-error.
   end.
   if error-status :error then do:
     undo, return no-apply.
   end.
end.
run ui-on ("line").
if prt-rec <> ? then reposition br-dtl to recid prt-rec no-error.
apply "entry" to br-dtl in frame d-out-doc.
end.
on choose of menu-item m-outs-3 do:
define variable old-mode     as   character         no-undo.
define variable old-handle   as   handle            no-undo.
define variable old-type     as   character         no-undo.
define variable old-stat     as   character         no-undo.
define variable old-flag     as   logical           no-undo.
define variable old-internal as   logical           no-undo.
if not b-add:sensitive in frame d-out-doc then do:
  message "Добавление строк для этого статуса запрещено.".
  return no-apply.
end.
apply "row-leave" to browse br-dtl.
do transaction:
   run check-rate no-error.
   if error-status :error then return no-apply.
   varlog = yes.
   message "Добавить товары из списка в заполняемый документ ?" skip (2)
           "- добавляются, если доступны, ВСЕ ФАКТ количества по списку с текущего объекта;" skip
           "- цены ставятся текущие по объекту (кроме возврата поставщику и перемещения по цене магазина);" skip
           "- если цены нет или количество 0, товар пропускается."
                  view-as alert-box question buttons OK-Cancel update varlog.
   if varlog <> true then return no-apply.
   run str/gds-list.w (parparentproc, t-doc.host-code, t-doc.obj-type, t-doc.obj-code).
   pardoc-rec = recid (t-doc).
   run waitfram-show in this-procedure (input "ЖДИТЕ.  Список добавляется в документ...").
   run copy-lst in this-procedure (
     input t-doc.doc-code,
     input ub.sysconf.cash-pay,
     input v-cntxp-doc-prt,
     input table gds-list,
     input "")
     no-error.
   if error-status :error then do:
     apply "entry" to b-add in frame d-out-doc.
     run waitfram-hide in this-procedure .
     return no-apply.
   end.
   run waitfram-hide in this-procedure .
   run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
   if error-status :error then do:
     undo, return no-apply.
   end.
end.
pardoc-mode = 'ИЗМЕНЕНИЕ':U.
run ui-on ("line").
apply "entry" to br-dtl in frame d-out-doc.
end.
on choose of menu-item m-outs-6 do:
define variable old-mode     as   character         no-undo.
define variable old-handle   as   handle            no-undo.
define variable old-type     as   character         no-undo.
define variable old-stat     as   character         no-undo.
define variable old-flag     as   logical           no-undo.
define variable old-internal as   logical           no-undo.
if not b-add:sensitive in frame d-out-doc then do:
  message "Добавление строк для этого статуса запрещено.".
  return no-apply.
end.
apply "row-leave" to browse br-dtl.
do transaction:
   run check-rate no-error.
   if error-status :error then return no-apply.
   varlog = yes.
   message "Добавить партии из списка кодов  в заполняемый документ ?" skip (2)
           "- добавляются, если доступны, ВСЕ ФАКТ количества по списку с текущего объекта;" skip
           "- цены ставятся текущие по объекту (кроме возврата поставщику и перемещения по цене магазина);" skip
           "- если цены нет или количество 0, товар пропускается."
                  view-as alert-box question buttons OK-Cancel update varlog.
   if varlog <> true then return no-apply.
   run str/bb-list.w (parparentproc, t-doc.obj-type, t-doc.obj-code , "" ).
   pardoc-rec = recid (t-doc).
   run waitfram-show in this-procedure (input "ЖДИТЕ.  Список добавляется в документ...").
   run copy-bb-list in this-procedure no-error .
   if error-status :error then do:
     apply "entry" to b-add in frame d-out-doc.
     run waitfram-hide in this-procedure .
     return no-apply.
   end.
   run waitfram-hide in this-procedure .
end.
pardoc-mode = 'ИЗМЕНЕНИЕ':U.
run ui-on ("line").
apply "entry" to br-dtl in frame d-out-doc.
end.
on choose of menu-item m-outs-4 do:
varlog = no.
 message "Обнулить ФАКТ количества в документе ?"
         view-as alert-box question buttons yes-no update varlog.
if varlog then
do transaction :
   for each ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code:
     ub.doc-line.fact-qnty = 0.
   end.
   for each ub.gds-dtl where ub.gds-dtl.doc-code = t-doc.doc-code:
     ub.gds-dtl.fact-qnty = 0.
   end.
   for each ub.parts where ub.parts.out-code = t-doc.doc-code:
     ub.parts.fact-qnty = 0.
   end.
   for each ub.inv-line where ub.inv-line.doc-code = t-doc.doc-code:
     assign ub.inv-line.after-cli-qnty = ub.inv-line.after-cli-qnty - ub.inv-line.wast-cli-qnty
            ub.inv-line.wast-cli-qnty  = 0.
   end.
   run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
   if error-status :error then do:
     undo, return no-apply.
   end.
end.
else return no-apply.
run ui-on ("line").
apply "entry" to br-dtl in frame d-out-doc.
end.
on choose of menu-item m-outs-8
do:
  if (t-doc.status_ = 'накл':U or t-doc.status_ = 'запрос':U)
  then do:
    run proc-m-outs-8 in this-procedure no-error.
  end.
  else do:
    return no-apply.
  end.
end.
on choose of menu-item m-outs-9
  do:
    if not b-add:sensitive in frame d-out-doc then
    do:
      message "Добавление строк для этого статуса запрещено.".
      return no-apply.
    end.
    apply "row-leave" to browse br-dtl.
    run proc-m-outs-9 in this-procedure no-error.
  end.
on choose of menu-item m-ap-1 in menu m-acc_price
do:
  run local-cur in this-procedure ( input 1 ) no-error.
  if error-status :error then do: return no-apply. end.
  run UI-on in this-procedure ( input "enable" ).
end.
on choose of menu-item m-ap-2 in menu m-acc_price
do:
run local-cur in this-procedure (input 2) no-error.
if error-status :error then return no-apply.
run UI-on ("enable").
end.
on choose of menu-item m-ap-3 in menu m-acc_price
do:
run local-cur in this-procedure (input 3) no-error.
if error-status :error then return no-apply.
run UI-on ("enable").
end.
on choose of menu-item m-fp-1 in menu m-fixprice
do:
 if t-doc.ext-doc-type = 'ep':U then do:
   message "В возврате поставщику цены всегда определяются возвращаемыми партиями." view-as alert-box.
   return no-apply.
 end.
 if available ub.gds-dtl then do:
   assign prt-rec = recid(ub.gds-dtl).
 end.
 else do:
   assign prt-rec = ?.
 end.
 define buffer bf_gds-dtl for ub.gds-dtl.
 assign varlog = no.
 message "Если Вы зафиксируете цены, то при изменении цены в прайс-листе до закрытия документа она не проставится в документ." skip
         "Вы уверены?" view-as alert-box buttons yes-no update varlog.
 if varlog = yes then do:
   for each bf_gds-dtl where bf_gds-dtl.doc-code = t-doc.doc-code on error undo, return no-apply :
     assign
       bf_gds-dtl.ov = yes.
   end.
 end.
 run ui-on ("line").
 if prt-rec <> ?  then do:
   reposition br-dtl to recid prt-rec no-error.
 end.
end.
on choose of menu-item m-fp-2 in menu m-fixprice
do:
 if t-doc.ext-doc-type = 'ep':U then do:
   message "В возврате поставщику цены всегда определяются возвращаемыми партиями." view-as alert-box.
   return no-apply.
 end.
 if available ub.gds-dtl then do:
   assign prt-rec = recid(ub.gds-dtl).
 end.
 else do:
   assign prt-rec = ?.
 end.
 define buffer bf_gds-dtl for ub.gds-dtl.
 assign varlog = no.
 message "Если Вы расфиксируете цены, то при изменении цены в прайс-листе до закрытия документа она проставится в документ." skip
         "Вы уверены?" view-as alert-box buttons yes-no update varlog.
 if varlog = yes then do:
   for each bf_gds-dtl where bf_gds-dtl.doc-code = t-doc.doc-code on error undo, return no-apply :
     assign
       bf_gds-dtl.ov = no.
   end.
 end.
 run ui-on ("line").
 if prt-rec <> ?  then do:
   reposition br-dtl to recid prt-rec no-error.
 end.
end.
on choose of menu-item m-ptrl-1 in menu m-ptrl do:
  apply "row-leave" to browse br-dtl.
  run cr-rvs-doc in this-procedure
    ( input parparentproc
     ,input t-doc.doc-code
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при создании документов сверок.") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  run UI-on in this-procedure ( input "line" ).
end.
on choose of menu-item m-ptrl-2 in menu m-ptrl do:
  apply "row-leave" to browse br-dtl.
  run del-rvs-doc in this-procedure
    ( input parparentproc
     ,input t-doc.doc-code
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при удалении документов сверок.") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  run UI-on in this-procedure ( input "line" ).
end.
assign
  br-dtl :num-locked-columns in frame d-out-doc = 3
  frame d-out-doc :scrollable = no
  r-outs     :popup-menu in frame d-out-doc = menu m-outs :handle
  r-outs     :menu-mouse = 1
  b-cur      :popup-menu in frame d-out-doc = menu m-acc_price :handle
  b-cur      :menu-mouse = 1
  b-fixprice :popup-menu in frame d-out-doc = menu m-fixprice :handle
  b-fixprice :menu-mouse = 1
  b-revis    :popup-menu in frame d-out-doc = menu m-ptrl :handle
  b-revis    :menu-mouse = 1
  b-print:popup-menu in frame d-out-doc   = menu m-print:handle
  b-print:menu-mouse                          = 1
.
assign
  r-reas            :tooltip in frame d-out-doc = "Основание (причина) создания документа"
  t-doc.reason-code :tooltip in frame d-out-doc = "Основание (причина) создания документа"
  rsn-name          :tooltip in frame d-out-doc = "Основание (причина) создания документа"
.
if valid-handle(active-window) and frame d-out-doc:parent eq ?
then frame d-out-doc:parent = active-window.
on window-close of frame d-out-doc apply "end-error":u to self.
define variable vss-include-info92 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-out-doc
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
on choose of b-help in frame d-out-doc
do:
  apply "help":u to frame d-out-doc .
end.
define variable vss-include-info93 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-out-doc:width - 0.3
                fh            = frame d-out-doc:first-child
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
define variable vss-include-info94 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-out-doc :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-out-doc :height-chars)
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
    if frame d-out-doc :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-out-doc :height-chars)
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
            frame d-out-doc :height = v-frame-height
          .
          if frame d-out-doc :scrollable = true
          then do:
            assign
              frame d-out-doc :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-out-doc :scrollable = true
          then do:
            assign
              frame d-out-doc :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-out-doc :height = v-frame-height
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
      v-frame-height = frame d-out-doc :height
      v-frame-virtual-height = frame d-out-doc :virtual-height
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
      v-field-group-handle = frame d-out-doc :first-child
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
    do with frame d-out-doc
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-out-doc :scrollable = true
      then do:
        assign
          frame d-out-doc :virtual-height = frame d-out-doc :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-out-doc :height = frame d-out-doc :height + p-change-value
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
        frame d-out-doc :height = frame d-out-doc :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-out-doc :scrollable = true
      then do:
        assign
          frame d-out-doc :virtual-height = frame d-out-doc :virtual-height + p-change-value
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
          ,input  string(frame d-out-doc :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-out-doc :height)
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
    if frame d-out-doc :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-out-doc :width
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
    if frame d-out-doc :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-out-doc :width
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
            frame d-out-doc :width = v-frame-width
          .
          if frame d-out-doc :scrollable = true
          then do:
            assign
              frame d-out-doc :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-out-doc :scrollable = true
          then do:
            assign
              frame d-out-doc :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-out-doc :width = v-frame-width
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
      v-frame-width = frame d-out-doc :width
      v-frame-virtual-width = frame d-out-doc :virtual-width
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
      v-field-group-handle = frame d-out-doc :first-child
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
    do with frame d-out-doc
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-out-doc :scrollable = true
      then do:
        assign
          frame d-out-doc :virtual-width = frame d-out-doc :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-out-doc :width = v-frame-width + p-change-value
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
        frame d-out-doc :width = frame d-out-doc :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-out-doc :scrollable = true
      then do:
        assign
          frame d-out-doc :virtual-width = frame d-out-doc :virtual-width + p-change-value
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
          ,input  string(frame d-out-doc :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-out-doc :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-out-doc
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-out-doc :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-out-doc :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-out-doc :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-out-doc :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-out-doc
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
      v-row-delta = v-new-row - frame d-out-doc :height
      v-col-delta = v-new-col - frame d-out-doc :width
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
            - frame d-out-doc :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-out-doc :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-out-doc :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-out-doc :height-chars
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
      v-diasize-current-frame-width  = frame d-out-doc :width
      v-diasize-current-frame-height = frame d-out-doc :height
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
    do with frame d-out-doc
    :
      assign
        v-diasize-orig-frame-height = frame d-out-doc :height
        v-diasize-orig-frame-width  = frame d-out-doc :width
        v-diasize-browse-handle     = browse br-dtl :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-out-doc :first-child
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
define variable vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of t-doc.fact-date in frame d-out-doc
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
on delete-character of t-doc.fact-date in frame d-out-doc
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
on ctrl-d of t-doc.fact-date in frame d-out-doc
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
on ctrl-b of t-doc.fact-date in frame d-out-doc
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
on ctrl-e of t-doc.fact-date in frame d-out-doc
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
on ctrl-f of t-doc.fact-date in frame d-out-doc
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
  define MENU m-ed-date96
    MENU-ITEM m-ed-date96-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date96-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date96-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date96-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if t-doc.fact-date :POPUP-MENU in frame d-out-doc = ?
  then do:
    ASSIGN
      t-doc.fact-date :POPUP-MENU in frame d-out-doc = MENU m-ed-date96 :HANDLE
      t-doc.fact-date :MENU-MOUSE in frame d-out-doc = 3
    .
  end.
  define variable v-label-handle96 as handle no-undo .
  assign
    v-label-handle96 = t-doc.fact-date :side-label-handle in frame d-out-doc
  .
  if valid-handle (v-label-handle96)
  then do:
    if v-label-handle96 :tooltip = ""
    or v-label-handle96 :tooltip = ?
    then do:
      assign
        v-label-handle96 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date96-1 in menu m-ed-date96 DO:
    apply "ctrl-b":U to t-doc.fact-date in frame d-out-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date96-2 in menu m-ed-date96 DO:
    apply "ctrl-d":U to t-doc.fact-date in frame d-out-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date96-3 in menu m-ed-date96 DO:
    apply "ctrl-e":U to t-doc.fact-date in frame d-out-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date96-4 in menu m-ed-date96 DO:
    apply "ctrl-f":U to t-doc.fact-date in frame d-out-doc .
  END.
define variable vss-include-info97 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of t-doc.doc-date in frame d-out-doc
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
on delete-character of t-doc.doc-date in frame d-out-doc
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
on ctrl-d of t-doc.doc-date in frame d-out-doc
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
on ctrl-b of t-doc.doc-date in frame d-out-doc
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
on ctrl-e of t-doc.doc-date in frame d-out-doc
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
on ctrl-f of t-doc.doc-date in frame d-out-doc
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
  define MENU m-ed-date98
    MENU-ITEM m-ed-date98-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date98-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date98-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date98-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if t-doc.doc-date :POPUP-MENU in frame d-out-doc = ?
  then do:
    ASSIGN
      t-doc.doc-date :POPUP-MENU in frame d-out-doc = MENU m-ed-date98 :HANDLE
      t-doc.doc-date :MENU-MOUSE in frame d-out-doc = 3
    .
  end.
  define variable v-label-handle98 as handle no-undo .
  assign
    v-label-handle98 = t-doc.doc-date :side-label-handle in frame d-out-doc
  .
  if valid-handle (v-label-handle98)
  then do:
    if v-label-handle98 :tooltip = ""
    or v-label-handle98 :tooltip = ?
    then do:
      assign
        v-label-handle98 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date98-1 in menu m-ed-date98 DO:
    apply "ctrl-b":U to t-doc.doc-date in frame d-out-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date98-2 in menu m-ed-date98 DO:
    apply "ctrl-d":U to t-doc.doc-date in frame d-out-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date98-3 in menu m-ed-date98 DO:
    apply "ctrl-e":U to t-doc.doc-date in frame d-out-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date98-4 in menu m-ed-date98 DO:
    apply "ctrl-f":U to t-doc.doc-date in frame d-out-doc .
  END.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ptrl'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-is-ptrl
  ,output v-data-type
  ) no-error .
if error-status :error or v-data-type <> "L" or lookup( v-is-ptrl, "yes,no" ) = 0 then do:
  assign
    v-is-ptrl = "no"
  .
end.
TEXT-RUBL = "РУБ" .
t-doc.print-rubl:label = "рубли".
display  TEXT-RUBL with frame d-out-doc .
t-doc.discnt-type:list-items in frame d-out-doc  = 'процент,карта,группа,сумма,строка,прайс-лист':U .
define variable only-main-pl as logical   no-undo .
define variable vss-include-info99 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run glstmain in g#library
  (output only-main-pl
  )  .
if only-main-pl = true then do:
   hide b-re-price in frame d-out-doc .
   t-doc.discnt-type:list-items in frame d-out-doc  = "процент,карта,группа,сумма,строка" .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'mercuri':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-mercury-value
  ,output v-mercury-type
  ) no-error .
hbrowse = browse br-dtl:handle.
extent (bcol) = hbrowse:num-columns.
bcol[1] = hbrowse:first-column.
do ii = 1 to extent (bcol).
  bcol[ii] = hbrowse:get-browse-column (ii).
end.
assign
  v-gds-name:resizable in browse br-dtl   = true
  v-gds-name:width     in browse br-dtl   = 40
  d-kg-after-qnty :visible in browse br-dtl = ( v-is-ptrl = "yes" )
  d-kg-fact-qnty  :visible in browse br-dtl = ( v-is-ptrl = "yes" )
  d-kg-price-base :visible in browse br-dtl = ( v-is-ptrl = "yes" )
  d-kg-price-rubl :visible in browse br-dtl = ( v-is-ptrl = "yes" )
.
def var sort-labelbr-dtl   as character no-undo .
def var sort-clmnbr-dtl    as handle    no-undo .
def var cur-clmnbr-dtl     as handle    no-undo .
def var cur-clmn-locbr-dtl as integer   no-undo .
def var re-querybr-dtl     as logical   initial no no-undo .
on start-search, ctrl-o of br-dtl in frame d-out-doc do:
   run sort-brbr-dtl
     (input (if available ub.gds-dtl
             then recid(ub.gds-dtl)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-dtl :
  define input parameter p-recid as recid no-undo .
  if re-querybr-dtl = no then do:
    assign
       cur-clmnbr-dtl = br-dtl:current-column in frame d-out-doc
    .
    if sort-clmnbr-dtl <> ? then sort-clmnbr-dtl:column-fgcolor = 0.
    if cur-clmnbr-dtl = sort-clmnbr-dtl then do:
      assign
         sort-labelbr-dtl = ""
         sort-clmnbr-dtl = ?
      .
     end.
     else do:
       assign
         sort-labelbr-dtl = cur-clmnbr-dtl:label
         sort-clmnbr-dtl  = cur-clmnbr-dtl
         sort-clmnbr-dtl:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-dtl = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-dtl:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-dtl then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-dtl = cur-clmn-locbr-dtl + 1
    .
  end.
  case sort-labelbr-dtl:
        when '*'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by get-mark(BUFFER ub.gds-dtl)     . END.
        when 'П/П'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by ub.doc-line.line-num     . END.
        when 'Бар-код'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by ub.bar-code.b-code     . END.
        when 'Артикул'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by ub.gds-dtl.artic     . END.
        when 'Имя '  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by (if ub.gds-prt.node-name <> '_Пустая шкала':U and ub.gds-prt.upper-code <> ub.goods.prt-root then ub.goods.gds-name + ' - ' + ub.gds-prt.f-name else ub.goods.gds-name)     . END.
        when 'По документу'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by ub.gds-dtl.doc-qnty     . END.
        when 'Факт'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by ub.gds-dtl.fact-qnty     . END.
        when 'Изм'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by ub.goods.unit-base     . END.
        when 'Цена (вал.)'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by ub.gds-dtl.price-base     . END.
        when ''  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by ub.gds-dtl.ov     . END.
        when 'Сумма (вал.)'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by (ub.gds-dtl.price-base * ub.gds-dtl.fact-qnty)     . END.
        when 'Скидка (вал.)'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by (ub.gds-dtl.discnt-base * ub.gds-dtl.fact-qnty)     . END.
        when 'Итого (вал.).'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by ((ub.gds-dtl.price-base - ub.gds-dtl.discnt-base) * ub.gds-dtl.fact-qnty)     . END.
        when 'Скидка %'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by ub.gds-dtl.discnt-pc     . END.
        when 'Цена (руб.)'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by ub.gds-dtl.price-rubl     . END.
        when 'Сумма (руб.)'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by (ub.gds-dtl.price-rubl * ub.gds-dtl.fact-qnty)     . END.
        when 'Скидка (руб.)'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by (ub.gds-dtl.discnt-rubl * ub.gds-dtl.fact-qnty)     . END.
        when 'Итого (руб.)'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by ((ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) * ub.gds-dtl.fact-qnty)     . END.
        when 'Признак'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by (if ub.gds-prt.node-name = '_Пустая шкала':U then '-' else if ub.gds-prt.upper-code = ub.goods.prt-root then '-------------------' else ub.gds-prt.f-name)     . END.
        when 'Факт, кг'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by get-kg-fact-qnty(  buffer ub.gds-dtl )     . END.
        when 'Цена за кг (вал.)'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by get-kg-sale-base(  buffer ub.gds-dtl )     . END.
        when 'Цена за кг (руб.)'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by get-kg-sale-rubl(  buffer ub.gds-dtl )     . END.
        when 'Итого, кг'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by get-kg-after-qnty( buffer ub.gds-dtl )     . END.
        when 'НДС'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by ub.doc-line.vat-sum-rubl * ub.gds-dtl.fact-qnty / ub.doc-line.fact-qnty     . END.
        when 'НДС %'  then DO:   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base  by ub.doc-line.vat-pc     . END.
    otherwise do:
      open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base by ub.doc-line.line-num .
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-dtl') then do:
          run mv-brw-defaultbr-dtl.
        end.
      if sort-labelbr-dtl <> "" then do:
        assign
          cur-clmnbr-dtl:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-dtl = ?
      .
    end.
  end case.
    if cur-clmn-locbr-dtl <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-dtl') then do:
        run ch-clmnbr-dtl in this-procedure (cur-clmn-locbr-dtl).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-dtl to recid p-recid no-error.
    apply "value-changed" to br-dtl in frame d-out-doc.
  end.
  apply "entry" to br-dtl in frame d-out-doc.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-dtl:
if cur-clmnbr-dtl = ? then do:
   open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base by ub.doc-line.line-num .
end.
else do:
   assign re-querybr-dtl = yes.
   run sort-brbr-dtl
     (input (if available ub.gds-dtl
             then recid(ub.gds-dtl)
             else ?
            )
     ).
   assign re-querybr-dtl = no.
end.
end.
define variable vss-include-info100 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-dtl as INT EXTENT 23 no-undo.
DEF VAR varmvibr-dtl       as INT no-undo.
DEF VAR varmvjbr-dtl       as INT no-undo.
DEF VAR varmvkbr-dtl       as INT no-undo.
DEF VAR varmvlbr-dtl       as INT no-undo.
DEF VAR move-elementbr-dtl as INT no-undo.
def var jjbr-dtl           as int no-undo.
do varmvibr-dtl = 1 to EXTENT(cur-clmn-numbr-dtl):
  ASSIGN cur-clmn-numbr-dtl[varmvibr-dtl] = varmvibr-dtl.
END.
RUN start-mv-clmnbr-dtl.
PROCEDURE start-mv-clmnbr-dtl:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-dtl do:
  RUN re-move-clmnbr-dtl ( 4, 23).
END.
ON ctrl-cursor-left OF BROWSE br-dtl do:
  RUN re-move-clmnbr-dtl (23, 4).
END.
PROCEDURE re-move-clmnbr-dtl:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-dtl = 1 TO EXTENT(cur-clmn-numbr-dtl):
    if cur-clmn-numbr-dtl[varmvibr-dtl] = source-column THEN cur-clmn-numbr-dtl[varmvibr-dtl] = -1.
  END.
  if br-dtl:MOVE-COLUMN(source-column, target-column) IN FRAME d-out-doc then.
  if source-column > target-column THEN
  DO varmvjbr-dtl = source-column - 1 to target-column BY -1:
    DO varmvibr-dtl = 1 TO EXTENT(cur-clmn-numbr-dtl):
        if cur-clmn-numbr-dtl[varmvibr-dtl] = varmvjbr-dtl THEN DO:
          cur-clmn-numbr-dtl[varmvibr-dtl] = cur-clmn-numbr-dtl[varmvibr-dtl] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-dtl = source-column + 1 to target-column:
    DO varmvibr-dtl = 1 TO EXTENT(cur-clmn-numbr-dtl):
      if cur-clmn-numbr-dtl[varmvibr-dtl] = varmvjbr-dtl THEN DO:
        cur-clmn-numbr-dtl[varmvibr-dtl] = cur-clmn-numbr-dtl[varmvibr-dtl] - 1.
      END.
    END.
  END.
  DO varmvibr-dtl = 1 TO EXTENT(cur-clmn-numbr-dtl):
    if cur-clmn-numbr-dtl[varmvibr-dtl] = -1 THEN cur-clmn-numbr-dtl[varmvibr-dtl] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-dtl:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 4 then do:
    return .
  end.
  DO varmvibr-dtl = 1 TO EXTENT(cur-clmn-numbr-dtl):
    if cur-clmn-numbr-dtl[varmvibr-dtl] = cur-clmn-loc THEN move-elementbr-dtl = varmvibr-dtl.
  END.
  RUN re-move-clmnbr-dtl (cur-clmn-loc, 4).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-dtl:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-dtl = 4 to EXTENT(cur-clmn-numbr-dtl):
    RUN re-move-clmnbr-dtl (cur-clmn-numbr-dtl[varmvlbr-dtl], varmvlbr-dtl).
  END.
  RUN start-mv-clmnbr-dtl.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
assign
  parext-doc-mode =
    ( if num-entries( pardoc-mode, '*':U ) > 1 then entry( 2, pardoc-mode, '*':U ) else '':U )
  pardoc-mode     = entry( 1, pardoc-mode, '*':U )
.
assign
  parnext-prev = yes
.
n-p:
do while parnext-prev :
main-block:
do on error   undo main-block, leave main-block :
assign
   br-dtl:column-resizable in frame d-out-doc = true.
if available t-doc then do:
  find ub.sysconf where ub.sysconf.host-code = t-doc.host-code no-lock.
end.
else do:
  find ub.sysconf where ub.sysconf.host-code = v-cntxt-host-code-obj no-lock.
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output prtvalue
  ,output prttype
  ) no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'holding'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output varhold
  ,output varhold-type
  ) no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-tsd'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-is-tsd
  ,output v-is-tsd-type
  ) no-error .
define variable vss-include-info101 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    if thbjattr_thbj-attr.prop-code = 'is-bcdoc' then bcvalue = string(thbjattr_thbj-attr.property-value-logical) .
end.
define variable vss-include-info102 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
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
    if thbjattr_thbj-attr.prop-code = 'reasonm':U   then v-reasonm      = thbjattr_thbj-attr.property-value-logical .
    if thbjattr_thbj-attr.prop-code = 'reasonme':U  then v-reasonme     = thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'reasons-for-return':U  then v-reasons-for-return = thbjattr_thbj-attr.property-value-character .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-pharm'
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-is-pharm
  ,output v-is-pharm-type
  ) no-error .
if v-is-pharm <> "yes" then do:
  assign
    v-is-pharm = "no"
  .
end.
else do:
define variable vss-include-info103 as character format "x(65)" no-undo initial "@(#)$workfile: $ $revision: $".
define variable v-o-pharm    as character no-undo .
define variable v-o-var-type as character no-undo .
  run clntattr-value in this-procedure
    ( input   v-cntxt-obj-type ,
      input   v-cntxt-obj-code ,
      input  'pharm':U,
      output v-o-pharm    ,
      output v-o-var-type )
     no-error .
  if v-o-pharm <> "yes":u or error-status :error then do:
     v-is-pharm = "no"  .
  end.
end.
define variable vss-include-info104 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  ) no-error .
 if error-status :error then do:
   assign
     parnext-prev = no.
   return error.
 end.
run mode-on in this-procedure no-error.
if error-status :error then do:
  assign
    parnext-prev = no.
  return error.
end.
define variable vss-include-info105 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  t-doc.doc-code
  ,output is-doc-hold
  ) no-error .
if error-status :error or is-doc-hold = ? then do: assign is-doc-hold = no. end.
if v-is-tsd = "no" then do: menu-item m-outs-2 :sensitive in menu m-outs = no. end.
prev-pardoc-mode = pardoc-mode.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'is-return':U ,
                       output varvalue ,
                       output vartype ) no-error .
if varvalue = "yes" then do:
  v-is-return = yes .
end.
EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code).
run ui-on in this-procedure ( input "enable" ) no-error.
if error-status :error then do:
  assign
    parnext-prev = no.
  return error.
end.
if prt-rec <> ? and pardoc-mode = 'ПРОСМОТР':U then reposition br-dtl to recid prt-rec no-error.
if t-doc.ext-doc-type = 'rv':U
then do :
  disable r-outs with frame d-out-doc .
end .
if t-doc.ext-doc-type = 'iv':U then
do:
  menu-item m_no-marks:sensitive in menu m-marks = yes .
end.
else
do:
  menu-item m_no-marks:sensitive in menu m-marks = no .
end.
      if t-doc.ext-doc-type = 'ep':U or
         t-doc.ext-doc-type = 'iv':U then
      do:
        menu-item m_add-marks:sensitive in menu m-marks = no.
      end .
      if pardoc-mode = 'ПРОСМОТР':U or t-doc.status_  <> 'накл':U and t-doc.status_ <> 'запрос':U then
      do:
        menu-item m_add-marks:sensitive in menu m-marks = no.
      end.
      if pardoc-mode = 'ДОБАВЛЕНИЕ':U
      and t-doc.ext-doc-type = 'ee':U
      then do :
        message "Выполнить возврат поставщику?" view-as alert-box question buttons yes-no update varlog .
        if varlog
        then do :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'is-return':U ,
                       input yes ) no-error .
        end .
      end .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'is-return':U ,
                       output varvalue ,
                       output vartype ) no-error .
      if varvalue = "yes" then do:
        v-is-return = yes .
        disable b-bc with frame d-out-doc .
        gds-dtl.doc-qnty:read-only in browse br-dtl = yes .
        gds-dtl.fact-qnty:read-only in browse br-dtl = yes .
      end.
      if v-is-return
      and pardoc-mode = 'ДОБАВЛЕНИЕ':U
      then do :
        apply "choose" to r-clients in frame d-out-doc .
        if t-doc.cli-code = ?
        then do :
          run proc-exit no-error .
          assign
            parnext-prev = no.
          return error.
        end .
        find first reas_contract where reas_contract.host-code     = t-doc.host-code  and
                                       reas_contract.contract-code = t-doc.contract-code no-lock no-error.
        if available reas_contract
        then do :
          find first trn-reason no-lock where trn-reason.reason-code = reas_contract.spec-check no-error.
          if available trn-reason then
          do trans:
            assign
              rsn-name          = trn-reason.reason-name
              t-doc.reason-code = trn-reason.reason-code
            .
            display t-doc.reason-code rsn-name with frame d-out-doc.
            disable r-reas r-clients t-doc.cli-code b-cur r-outs with frame d-out-doc.
          end .
          find first buf_contract-attr no-lock where buf_contract-attr.host-code = reas_contract.host-code
                                                 and buf_contract-attr.contract-code = reas_contract.contract-code
                                                 and buf_contract-attr.attr-code = "contract-edi"
                                                 no-error .
          if available buf_contract-attr
          and logical(buf_contract-attr.attr-value) = true
          then do :
            is-contract-edo = yes .
          end .
          else do :
            find first buf_contract-attr no-lock where buf_contract-attr.host-code = reas_contract.host-code
                                                   and buf_contract-attr.contract-code = reas_contract.contract-code
                                                   and buf_contract-attr.attr-code = "contract-diadoc"
                                                   no-error .
            if available buf_contract-attr
            and logical(buf_contract-attr.attr-value) = true
            then do :
              is-contract-edo = yes .
            end .
          end .
          if is-contract-edo
          and EDOParSec:IsEdo
          then do :
            edo-return = yes .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'edo-return':U ,
                       input yes ) no-error .
            if error-status :error then
            do:
              message error-status :error error-status :get-message( 1 ) '"' + 'edo-return':U + '"'
                view-as alert-box error.
            end.
          end .
          else do :
            edo-return = no .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'edo-return':U ,
                       input no ) no-error .
            if error-status :error then
            do:
              message error-status :error error-status :get-message( 1 ) '"' + 'edo-return':U + '"'
                view-as alert-box error.
            end.
          end .
        end .
      end .
      if v-is-return
      then do :
        if t-doc.contract-code > 0
        then do :
          find first reas_contract where reas_contract.host-code     = t-doc.host-code  and
                                         reas_contract.contract-code = t-doc.contract-code no-lock no-error.
          if available reas_contract
          then do :
            find first buf_contract-attr no-lock where buf_contract-attr.host-code = reas_contract.host-code
                                                   and buf_contract-attr.contract-code = reas_contract.contract-code
                                                   and buf_contract-attr.attr-code = "contract-edi"
                                                   no-error .
            if available buf_contract-attr
            and logical(buf_contract-attr.attr-value) = true
            then do :
              is-contract-edo = yes .
            end .
            else do :
              find first buf_contract-attr no-lock where buf_contract-attr.host-code = reas_contract.host-code
                                                     and buf_contract-attr.contract-code = reas_contract.contract-code
                                                     and buf_contract-attr.attr-code = "contract-diadoc"
                                                     no-error .
              if available buf_contract-attr
              and logical(buf_contract-attr.attr-value) = true
              then do :
                is-contract-edo = yes .
              end .
            end .
            if is-contract-edo
            and EDOParSec:IsEdo
            then do :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'edo-return':U ,
                       output varvalue ,
                       output vartype ) no-error .
              if varvalue = "yes"
              then do:
                edo-return = yes .
                disable b-bc with frame d-out-doc.
              end.
              else do :
                edo-return = no .
              end .
              display edo-return with frame d-out-doc.
              if pardoc-mode <> 'ПРОСМОТР':U
              then do :
                enable edo-return with frame d-out-doc.
              end .
            end .
            else do :
              edo-return = no .
              display edo-return with frame d-out-doc.
              disable edo-return with frame d-out-doc.
            end .
          end .
        end .
        if pardoc-mode <> 'ДОБАВЛЕНИЕ':U
        then do :
          disable r-reas r-clients t-doc.cli-code b-cur r-outs with frame d-out-doc.
        end .
      end .
  if pardoc-mode = 'ДОБАВЛЕНИЕ':U and
     (t-doc.ext-doc-type = 'iv':U or
      t-doc.ext-doc-type = 'ev':U) then do:
      run create-record in this-procedure (  input t-doc.doc-code
                                           , input 'othermoves':U
                                           , input "yes":U
                                           , output vExist ) .
  end.
if pardoc-mode = 'ДОБАВЛЕНИЕ':U then do:
  wait-for go of frame d-out-doc focus t-doc.cli-code.
end.
else do:
  wait-for go of frame d-out-doc focus br-dtl.
end.
end.
end.
run disable_ui in this-procedure.
PROCEDURE add-doc-line-local :
define buffer bf_contract-specif for ub.contract-specif.
define buffer bf-hv_doc-line     for ub.doc-line.
define buffer bf_goods           for ub.goods.
define variable varschartic like ub.doc-line.artic initial " " no-undo.
define variable v-choice    as   integer                    no-undo.
define variable v-rid       as   integer                    no-undo.
define variable v-rid-list  as   char                       no-undo.
define variable i           as   integer                    no-undo.
do on stop undo, return error return-value :
  run corr-t-doc in this-procedure no-error.
  if error-status:error then do:
    return error return-value.
  end.
  v-choice = 0.
  if t-doc.contract-code <> 0 then do:
    find first bf_contract-specif where bf_contract-specif.host-code    = ( if is-doc-hold then t-doc.cli-code  else t-doc.host-code )      and
                                        bf_contract-specif.contract-num = t-doc.contract-code no-lock no-error.
    if available bf_contract-specif then do:
      run gbl/d-askw.w
        (input "Добавление товаров"
        ,input "Выберите один из пунктов для добавления в накладную" + chr(10)
             + "товаров по спецификации к договору" + chr(10)
        ,input "|"
        ,input "Все|Выборочно|По справочнику|Отказ"
        ,input "Все недобавленные товары по спецификации|"
             + "Выборочно товары по спецификации|"
             + "Выбор товаров из справочника|"
             + "Отказ от выполнения операции"
        ,input 1
        ,input 4
        ,output v-choice
        ).
      if v-choice = 4 then do:
        run UI-on in this-procedure ( input "line" ).
        return.
      end.
    end.
  end.
  if v-choice = 0 then
    v-choice = 3.
define variable  varnotes  as character no-undo .
  assign
    varnotes = '':u
    varlns-cnt = 1.
  case v-choice:
    when 1 then do:
      for each bf_contract-specif where bf_contract-specif.host-code    = ( if is-doc-hold then t-doc.cli-code  else t-doc.host-code )      and
                                        bf_contract-specif.contract-num = t-doc.contract-code no-lock
          on error undo, return error return-value :
        find first bf_goods where bf_goods.gds-code = bf_contract-specif.gds-code no-lock.
        find first bf-hv_doc-line where bf-hv_doc-line.doc-code  = t-doc.doc-code     and
                                        bf-hv_doc-line.artic     = bf_goods.artic     and
                                        bf-hv_doc-line.prod-type = bf_goods.prod-type and
                                        bf-hv_doc-line.prod-code = bf_goods.prod-code no-lock no-error.
        if not available bf-hv_doc-line then do:
          assign
            varnotes = varnotes + (if varnotes = '':u then '':u else ',':u) + string(recid(bf_goods)).
        end.
      end.
      if varnotes = '':u then do:
        message "Вы добавили уже все товары по спецификации."
        view-as alert-box.
      end.
    end.
    when 2 then do:
      run str/contspec.w (input parparentproc,
                      input "b-sel,b-mark",
                      input 'ПРОСМОТР':U,
                      input ( if is-doc-hold then t-doc.cli-code  else t-doc.host-code ) ,
                      input t-doc.contract-code,
                      output v-rid-list) .
      if v-rid-list = '':u then do:
        message "Нет выбранных товаров по спецификации."
          view-as alert-box.
      end.
      do i = 1 to num-entries(v-rid-list):
        v-rid = integer(entry(i, v-rid-list)).
        find bf_contract-specif where recid(bf_contract-specif) = v-rid no-lock no-error.
        if available bf_contract-specif then do:
          find first bf_goods where bf_goods.gds-code = bf_contract-specif.gds-code no-lock.
          assign
            varnotes = varnotes + (if varnotes = '':u then '':u else ',':u) + string(recid(bf_goods)).
        end.
      end.
    end.
    when 3 then do:
      run str/chs-gds.w ( input parparentproc
                    , input v-cntxt-obj-type
                    , input v-cntxt-obj-code
                    , input parlist-mode
                    , input t-doc.status_
                    , input "Строка ПН № " + t-doc.doc-code + " " + t-doc.status_ + " " + string (t-doc.flag_, "+/-")
                    , 'факт':U
                    , input t-doc.cli-type
                    , input t-doc.cli-code
                    , input t-doc.host-code
                    , input t-doc.ext-doc-type
                    , input-output varschartic
                    , output varnotes) no-error.
    end.
  end case.
  run cycle-add in this-procedure.
  run UI-on     in this-procedure ( input "line" ).
end.
END PROCEDURE.
PROCEDURE add-rate :
reposition br-dtl to recid recid(ub.doc-line).
display ub.gds-dtl.fact-qnty + rate @ ub.gds-dtl.fact-qnty with browse br-dtl.
END PROCEDURE.
PROCEDURE after_qnty :
  define  input parameter p-gds-dtl-rec  as   recid                no-undo.
  define output parameter p-out-qnty-kg  like ub.gds-dtl.fact-qnty no-undo initial 0.0.
  define variable p-inv-line-rec as recid   no-undo.
  define variable is-petrol      as logical no-undo.
  define variable is-pieces      as logical no-undo.
  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_gds-dtl  for ub.gds-dtl.
  do on error undo, return error return-value :
    find buf_gds-dtl        no-lock where recid( buf_gds-dtl ) = p-gds-dtl-rec no-error.
    if not available buf_gds-dtl then do:
      assign p-out-qnty-kg = ?.
      undo, return error "after_qnty: не найдена строка накладной".
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_gds-dtl.artic
  ,  input buf_gds-dtl.prod-type
  ,  input buf_gds-dtl.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
    if error-status :error or v-is-ptrl <> "yes" or is-petrol <> yes or is-pieces <> no then do:
      undo, return error substitute( 'inv-line_price: &1 (произв. &2 &3) не топливный товар',
                                     buf_gds-dtl.artic, buf_gds-dtl.prod-type, buf_gds-dtl.prod-code ).
    end.
    find buf_inv-line          no-lock where
         buf_inv-line.doc-code  = buf_gds-dtl.doc-code  and
         buf_inv-line.artic     = buf_gds-dtl.artic     and
         buf_inv-line.prod-code = buf_gds-dtl.prod-code and
         buf_inv-line.prod-type = buf_gds-dtl.prod-type no-error.
    if available buf_inv-line then do:
      assign
        p-inv-line-rec = recid( buf_inv-line )
      .
      find buf_gds-dtl  exclusive-lock where recid( buf_gds-dtl  ) = p-gds-dtl-rec.
      find buf_inv-line exclusive-lock where recid( buf_inv-line ) = p-inv-line-rec.
      assign
        p-out-qnty-kg = buf_inv-line.after-cli-qnty
      .
      find buf_inv-line        no-lock where recid( buf_inv-line ) = p-inv-line-rec.
      find buf_gds-dtl         no-lock where recid( buf_gds-dtl  ) = p-gds-dtl-rec.
      release buf_inv-line.
      release buf_gds-dtl.
    end.
  end.
END PROCEDURE.
PROCEDURE ask-copy :
define buffer tdb_doc-line    for ub.doc-line.
define buffer tdb_gds-dtl     for ub.gds-dtl.
define buffer tdb_parts       for ub.parts .
define buffer buf_parts       for ub.parts .
define buffer buf-cli_clients for ub.clients  .
define variable v-num as integer initial 1 no-undo.
for each t-d-b-doc-line :
  delete t-d-b-doc-line.
end.
for each t-d-b-gds-dtl :
  delete t-d-b-gds-dtl.
end.
for each t-d-b-parts :
  delete t-d-b-parts.
end.
for each tdb_doc-line where tdb_doc-line.doc-code = t-d-b.doc-code on error undo, return no-apply :
  create t-d-b-doc-line.
  buffer-copy tdb_doc-line to t-d-b-doc-line.
end.
for each tdb_gds-dtl where tdb_gds-dtl.doc-code = t-d-b.doc-code on error undo, return no-apply :
  create t-d-b-gds-dtl.
  buffer-copy tdb_gds-dtl to t-d-b-gds-dtl.
end.
if t-doc.ext-doc-type = 'ep':U then do:
  run gbl/d-askw.w
    (input "Вопрос"
    ,input "По каким количествам будем производить копирование?"
            + chr(10) + (if t-d-b.status_ <> 'запрос':U then "Внимание ! Если добавляемое количество какого-либо товара недоступно, оно будет уменьшено." else "":U)
    ,input "|^"
    ,input "Фактическим|"
           + "Документарным|"
           + "Партии источн.|"
           +  "Отмена"
    ,input "Исходя из фактических количеств в строке документа. При этом берутся любые партии от этого поставщика|"
        + "Исходя из документарных количеств в строке документа. При этом берутся любые партии от этого поставщика|"
        + "Исходя из фактических количеств в партиях документа. Если свободное количество данной партии меньше чем в документе источнике, то берется все свободное количество.|"
        + "Отменить копирование."
    ,input 1
    ,input 4
    ,output v-num
    ).
  if v-num = 4 then do:
    return no-apply.
  end.
  if v-num = 3 then do:
    for each t-d-b-doc-line where t-d-b-doc-line.doc-code = t-d-b.doc-code on error undo, return no-apply :
      for each buf_parts
        where buf_parts.obj-type  = t-d-b-doc-line.obj-type
          and buf_parts.obj-code  = t-d-b-doc-line.obj-code
          and buf_parts.artic     = t-d-b-doc-line.artic
          and buf_parts.prod-type = t-d-b-doc-line.prod-type
          and buf_parts.prod-code = t-d-b-doc-line.prod-code
          and buf_parts.out-code  = t-d-b.doc-code
      on error undo, return no-apply
      :
        if buf_parts.supp-type = t-doc.cli-type
          and buf_parts.supp-code = t-doc.cli-code
        then do:
          find first tdb_parts
            where tdb_parts.obj-type  = buf_parts.obj-type
              and tdb_parts.obj-code  = buf_parts.obj-code
              and tdb_parts.artic     = buf_parts.artic
              and tdb_parts.prod-type = buf_parts.prod-type
              and tdb_parts.prod-code = buf_parts.prod-code
              and tdb_parts.in-code   = buf_parts.in-code
              and tdb_parts.out-code  = 'free-zone':U
              and tdb_parts.part-code = buf_parts.part-code
            no-error .
          if available tdb_parts then do:
            create t-d-b-parts.
            if tdb_parts.fact-qnty > buf_parts.fact-qnty then do:
              buffer-copy buf_parts to t-d-b-parts .
            end.
            else do:
              buffer-copy tdb_parts to t-d-b-parts
                assign
                  t-d-b-parts.out-code = t-d-b-doc-line.doc-code
                .
            end.
          end.
        end.
      end.
    end.
  end.
end.
block_copy:
do transaction
on error undo, return error return-value
on stop  undo, return error "stop"
:
  if t-doc.ext-doc-type <> 'ep':U then do:
    run gbl/d-askw.w
      (input "Вопрос"
      ,input "По каким количествам будем производить копирование?"
            + chr(10) + (if t-d-b.status_ <> 'запрос':U then "Внимание ! Если добавляемое количество какого-либо товара недоступно, оно будет уменьшено." else "":U)
      ,input "|^"
      ,input "Фактическим|"
          + "Документарным|"
          + "По Партиям|"
          + "Отмена"
      ,input "Исходя из фактических количеств в признаках.|"
          + "Исходя из документарных количеств в признаках.|"
          + "Копировать партии источника.|"
          + "Отменить копирование."
      ,input 1
      ,input 4
      ,output v-num
      ).
    if v-num = 4 then do:
      undo, leave block_copy .
    end.
  if v-num = 3 then do:
    for each t-d-b-doc-line where t-d-b-doc-line.doc-code = t-d-b.doc-code on error undo, return no-apply :
      for each buf_parts
        where buf_parts.obj-type  = t-d-b-doc-line.obj-type
          and buf_parts.obj-code  = t-d-b-doc-line.obj-code
          and buf_parts.artic     = t-d-b-doc-line.artic
          and buf_parts.prod-type = t-d-b-doc-line.prod-type
          and buf_parts.prod-code = t-d-b-doc-line.prod-code
          and buf_parts.out-code  = t-d-b.doc-code
      on error undo, return no-apply
      :
          find first tdb_parts
            where tdb_parts.obj-type  = buf_parts.obj-type
              and tdb_parts.obj-code  = buf_parts.obj-code
              and tdb_parts.artic     = buf_parts.artic
              and tdb_parts.prod-type = buf_parts.prod-type
              and tdb_parts.prod-code = buf_parts.prod-code
              and tdb_parts.in-code   = buf_parts.in-code
              and tdb_parts.out-code  = 'free-zone':U
              and tdb_parts.part-code = buf_parts.part-code
            no-error .
          if available tdb_parts then do:
            create t-d-b-parts.
            if tdb_parts.fact-qnty > buf_parts.fact-qnty then do:
              buffer-copy buf_parts to t-d-b-parts .
            end.
            else do:
              buffer-copy tdb_parts to t-d-b-parts
                assign
                  t-d-b-parts.out-code = t-d-b-doc-line.doc-code
                .
            end.
        end.
      end.
    end.
  end.
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_copy-ret in g#lib-trn
  (
    input parparentproc
  , input t-d-b.doc-code
  , input t-d-b.doc-type
  , input t-d-b.status_
  , input t-d-b.internal
  , input t-d-b.cli-type
  , input t-d-b.cli-code
  , input t-d-b.discnt-type
  , input t-d-b.tot-calc
  , input t-d-b.discnt-pc
  , input t-d-b.agnt
  , input t-d-b.boss
  , input t-d-b.wrkr
  , input t-d-b.base-rate
  , input t-d-b.base-scale
  , input t-d-b.exch-code
  , input t-d-b.vat-type
  , input t-doc.doc-code
  , input t-doc.discnt-type:sensitive in frame d-out-doc
  , input input frame d-out-doc t-doc.discnt-pc
  , input input frame d-out-doc t-doc.agnt
  , input input frame d-out-doc t-doc.boss
  , input input frame d-out-doc t-doc.wrkr
  , input input frame d-out-doc t-doc.base-rate
  , input input frame d-out-doc t-doc.base-scale
  , input ub.sysconf.cash-pay
  , input ub.sysconf.base-code
  , input-output table t-d-b-doc-line
  , input-output table t-d-b-gds-dtl
  , input-output table t-d-b-parts
  , input (if v-num = 3 then yes else no)
  , input (if v-num = 3 then yes else no)
  , input no
  , input (if v-num = 1 or v-num = 3 then yes else no)
  ) no-error.
  if error-status :error then do:
    message "Ошибка при копировании документа." skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2) skip
            error-status:get-message(3) skip
    view-as alert-box error.
    return error.
  end.
  run str/crdocpl.p
    ( input t-doc.doc-code
     ,input ?
     ,input "dens_doc-line":U
    ) no-error .
  if error-status :error then do:
    message
      "Ошибка при копировании документа (создание информации по складским местам)." skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error.
    return error .
  end.
  run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
  if error-status :error then do:
    message
      "Ошибка при копировании документа (расчет шапки документа)." skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error.
    return error .
  end.
end.
for each t-d-b-doc-line :
  delete t-d-b-doc-line.
end.
for each t-d-b-gds-dtl :
  delete t-d-b-gds-dtl.
end.
for each t-d-b-parts :
  delete t-d-b-parts.
end.
pardoc-mode = 'ИЗМЕНЕНИЕ':U.
run ui-on ("line").
apply "entry" to br-dtl in frame d-out-doc.
END PROCEDURE.
procedure chg-purch-contract :
end procedure.
PROCEDURE ch-discnt :
define variable hist-list as character no-undo.
define buffer buf_c-dis-card for ub.c-dis-card.
define buffer buf_c-dc-hist for ub.c-dc-hist.
if input frame d-out-doc t-doc.discnt-type = 'карта':U then do:
  run ref/discards.w (
                   input parparentproc
                  ,input "b-sel"
                  ,input "client":U
                  ,input t-doc.host-code
                  ,input t-doc.obj-type
                  ,input t-doc.obj-code
                  ,input '':U
                  ,input recid (ub.clients)
                  ,output ref-list).
  if ref-list = "" then do:
    display t-doc.discnt-type with frame d-out-doc.
    return error.
  end.
  find ub.dis-card where recid (ub.dis-card) = integer (ref-list) no-lock.
  if ub.dis-card.status_ = 'неисп':U
  or ub.dis-card.status_ = 'смкли':U
  then do:
    message
    substitute("Нельзя создать докуиент с картой &1&2" +
                "Карта имеет статус &3, &4"
                , ub.dis-card.d-card
                , chr(10)
                , ub.dis-card.status_
                , (if ub.dis-card.status_ = 'неисп':U
                    then "карта должна быть ОКОНЧАТЕЛЬНО удалена"
                    else "карта будет доступна по окончании процесса смены владельца")
                )
    view-as alert-box error .
    return error.
  end.
  assign
    t-doc.d-card    = ub.dis-card.d-card.
  assign varlog = yes.
  message "Текущий процент по дисконтной карте " ub.dis-card.d-card " равен " ub.dis-card.d-pcnt " ." skip
          "Будем оформлять накладную, исходя из данного процента?" view-as alert-box question buttons yes-no update varlog.
  if varlog then do:
    assign
      t-doc.discnt-pc = ub.dis-card.d-pcnt
      t-doc.d-card    = ub.dis-card.d-card.
  end.
  else do:
    run ref/cdchist.w (
                    INPUT  parparentproc
                    ,input t-doc.host-code
                    ,input t-doc.obj-type
                    ,input t-doc.obj-code
                    ,input "b-sel":U
                    ,input "subject":U
                    ,input ub.dis-card.d-card
                    ,input ub.dis-card.card-num
                    ,input t-doc.obj-type
                    ,input t-doc.obj-code
                    ,input t-doc.host-code
                    ,input v-cntxt-db-num
                    ,input "":U
                    ,input 'dis-card':U
                    ,input v-cntxt-db-num
                    ,input-output hist-list
                 ) no-error .
    if error-status :error or
       hist-list = "" then do:
       message "Не смог взять процент из истории. Берем текущий процент."
       view-as alert-box information.
       assign
         t-doc.discnt-pc = ub.dis-card.d-pcnt
         t-doc.d-card    = ub.dis-card.d-card.
    end.
    else do:
      find first buf_c-dc-hist where
              recid(buf_c-dc-hist) = integer(hist-list) no-lock no-error.
      if available buf_c-dc-hist then do:
        find first buf_c-dis-card no-lock where
                  buf_c-dis-card.d-card           = buf_c-dc-hist.d-card
              AND buf_c-dis-card.chip-num         = buf_c-dc-hist.chip-num
              AND buf_c-dis-card.corr-user-db-num = buf_c-dc-hist.corr-user-db-num  no-error .
      end.
      if not available buf_c-dc-hist
      or not available buf_c-dis-card
      then do:
         message "Не смог взять процент из истории. Берем текущий процент."
         view-as alert-box information.
         assign
         t-doc.discnt-pc = ub.dis-card.d-pcnt
         t-doc.d-card    = ub.dis-card.d-card.
      end.
      else do:
        assign
        t-doc.discnt-pc = decimal(buf_c-dis-card.d-pcnt)
        t-doc.d-card    = ub.dis-card.d-card.
      end.
    end.
  end.
end.
else do:
  assign
    t-doc.d-card = ?.
end.
display t-doc.d-card t-doc.discnt-pc with frame d-out-doc.
if input frame d-out-doc t-doc.discnt-type = 'группа':U then do:
  define variable v-d-pcnt as decimal no-undo .
  run cgrplib-get-pcnt-value in this-procedure ( input ub.clients.grp-code , output v-d-pcnt) no-error .
  if error-status:error then do:
    message
    "Ошибка при установлениее скидки для группы клиентов."
    error-status:get-message(1) skip
    return-value
    view-as alert-box.
    display t-doc.discnt-type with frame d-out-doc.
    return error.
  end.
  else do:
    if v-d-pcnt = ?
    or v-d-pcnt = 0 then do:
      message "Скидка для группы клиентов не установлена." view-as alert-box.
      display t-doc.discnt-type with frame d-out-doc.
      return error.
    end.
  end.
  t-doc.discnt-pc = v-d-pcnt.
end.
assign t-doc.discnt-type.
run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
if error-status :error then return "error".
END PROCEDURE.
PROCEDURE check-discnt :
varlog = no.
if input frame d-out-doc t-doc.discnt-type = 'строка':U then
  if not v-cntxp-out-line-discnt then message "Скидки по строкам запрещены.".
  else message "Включение разных скидок по строкам. Вы уверены ?"
                          view-as alert-box question buttons ok-cancel update varlog.
  else message "Включение общей скидки для всего документа."
                        "Все скидки по строкам будут пересчитаны. Вы уверены ?"
                        view-as alert-box question buttons ok-cancel update varlog.
if varlog <> true then do:
  display t-doc.discnt-type with frame d-out-doc.
  return error.
end.
END PROCEDURE.
PROCEDURE check-inv :
find ub.doc-line where ub.doc-line.doc-code         = t-doc.doc-code
                       and ub.doc-line.prod-code = ub.gds-dtl.prod-code
                       and ub.doc-line.prod-type = ub.gds-dtl.prod-type
                       and ub.doc-line.artic     = ub.gds-dtl.artic no-lock.
line-rec = recid (ub.doc-line).
find ub.goods where ub.goods.prod-code = ub.gds-dtl.prod-code
             and ub.goods.prod-type = ub.gds-dtl.prod-type
             and ub.goods.artic     = ub.gds-dtl.artic no-lock.
define variable l-inv-on as logical no-undo .
define variable vss-include-info106 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.doc-line.obj-type
  ,input  ub.doc-line.obj-code
  ,input  ub.doc-line.artic
  ,input  ub.doc-line.prod-type
  ,input  ub.doc-line.prod-code
  ,input  'inv-on=request'
  ,output l-inv-on
  ) no-error .
if error-status :error then do:
  message
    "Ошибка получения признака товара на объекте" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return no-apply .
end.
if l-inv-on = yes and t-doc.status_ <> 'запрос':U then do:
  message "Артикул :" ub.doc-line.artic ub.goods.gds-name "- товар в инвентаризации." skip( 2 )
          "Операция невозможна."
  view-as alert-box error.
  return error.
end.
END PROCEDURE.
PROCEDURE proc-m-outs-8 :
define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_doc-line for ub.doc-line .
define buffer bf_goods for ub.goods .
define variable vardoc-code like ub.trn-doc.doc-code no-undo.
define variable par-alcohol as character no-undo .
define variable par-mark as character no-undo .
define variable par-type as character no-undo .
define variable v-is-alc as logical no-undo .
define variable v-mark-alchol     as logical no-undo .
define variable v-type as character no-undo .
define variable v-tth             as handle no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
delete object v-tth no-error.
run adm/shattri.p (
   input "get":U
  ,input t-doc.obj-type
  ,input t-doc.obj-code
  ,input 'nakl_par':U
  ,input  "mark-alchol"
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-mark-alchol
  ,output v-type
  ,INPUT-OUTPUT table-handle v-tth
  ) no-error .
  delete object v-tth no-error.
if error-status:error then do:
  message "Ошибка при получение параметра mark-alchol"
  view-as alert-box.
  return error.
end.
if not v-mark-alchol
then do :
    message "В системе не включен помарочный учёт. Импорт акцизных марок невозможен." view-as alert-box .
    return.
end.
do transaction:
    run str/imp-marks.p (parparentproc, t-doc.doc-code, "out") .
end.
END PROCEDURE.
PROCEDURE proc-m-outs-9 :
  define variable chg-qnty    like gds-dtl.doc-qnty no-undo.
  define variable legal-node  like gds-prt.node-code no-undo.
  define variable varcount    as integer no-undo.
  define variable varchg-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable vardoc-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable v-is-petrol as logical no-undo.
  define variable v-is-pieces as logical no-undo.
  define variable var-kg-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable rr-inv-line as recid   no-undo.
  define variable v-rec-list as character no-undo .
  define variable ii as integer no-undo .
  define buffer cpl_goods    for ub.goods   .
  define buffer cpl_gds-obj  for ub.gds-obj .
  define buffer cpl_prt-obj  for ub.prt-obj .
  define buffer cpl_gds-prt  for ub.gds-prt .
  define buffer cpl_gds-dtl  for ub.gds-dtl .
  define buffer cpl_doc-line for ub.doc-line.
  define buffer cpl_inv-line for ub.inv-line.
  define buffer buf_utd       for ub.utd  .
  define buffer buf_utd-lines for ub.utd-lines .
  define variable vconnect as com-handle no-undo.
  run str/UPD.w ( parparentproc, 'ВЫБОР':U, 0,"" , input-output vconnect , output v-rec-list)  .
  if trim(v-rec-list) = ""
  or v-rec-list = ?
  then
  return .
  do ii = 1 to num-entries (v-rec-list) :
    find first buf_utd no-lock where recid(buf_utd) = integer(entry(ii,v-rec-list)) no-error .
    if not available buf_utd then next .
    c-l:
    do on error undo c-l, return error :
      r-l:
      for each buf_utd-lines no-lock where buf_utd-lines.db-num = buf_utd.db-num
                                       and buf_utd-lines.doc-id = buf_utd.doc-id,
      first cpl_goods no-lock where cpl_goods.gds-code = buf_utd-lines.gds-code :
        assign
          varcount = varcount + 1
        .
        if varcount modulo 100 = 0 then
        do:
          run waitfram-show in this-procedure (input "ЖДИТЕ.  Обработано строк списка : " + string (varcount)).
        end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdoclno in g#lib-trn
( input t-doc.doc-code
 ,input t-doc.obj-type
 ,input t-doc.obj-code
 ,input cpl_goods.artic
 ,input cpl_goods.prod-type
 ,input cpl_goods.prod-code
 ,input cpl_goods.gds-name
 ,input cpl_goods.prt-root
 ,input ?
 ,input ?
 ,input ub.sysconf.cash-pay
  ) no-error .
        if error-status :error then
        do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании строки." skip
            return-value skip
            trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5)) skip
            view-as alert-box error.
          undo c-l, return error return-value.
        end.
        if return-value = "next" then
        do:
          next r-l.
        end.
        find first cpl_doc-line where cpl_doc-line.doc-code  = t-doc.doc-code and
          cpl_doc-line.artic     = cpl_goods.artic      and
          cpl_doc-line.prod-type = cpl_goods.prod-type  and
          cpl_doc-line.prod-code = cpl_goods.prod-code .
        find first cpl_gds-prt where cpl_gds-prt.upper-code = cpl_goods.prt-root no-lock.
        find first  cpl_prt-obj where cpl_prt-obj.obj-type  = t-doc.obj-type
          and cpl_prt-obj.obj-code  = t-doc.obj-code
          and cpl_prt-obj.artic     = cpl_goods.artic
          and cpl_prt-obj.prod-type = cpl_goods.prod-type
          and cpl_prt-obj.prod-code = cpl_goods.prod-code no-error .
        if error-status :error then
        do:
        end.
        assign
          legal-node = if available cpl_prt-obj then cpl_prt-obj.prt-code else cpl_gds-prt.node-code .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input t-doc.obj-code
   ,input t-doc.obj-type
   ,input t-doc.doc-code
   ,input cpl_goods.artic
   ,input cpl_goods.prod-code
   ,input cpl_goods.prod-type
   ,input legal-node
   ,input yes
  ) no-error .
        find first cpl_gds-dtl where cpl_gds-dtl.doc-code  = t-doc.doc-code and
          cpl_gds-dtl.artic     = cpl_goods.artic      and
          cpl_gds-dtl.prod-code = cpl_goods.prod-code  and
          cpl_gds-dtl.prod-type = cpl_goods.prod-type  and
          cpl_gds-dtl.prt-code  = legal-node.
        assign
          cpl_gds-dtl.ov = no.
define variable vss-include-info107 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(cpl_gds-dtl)
  , input no
  , input ?
  ) no-error.
        if error-status :error then
        do:
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            ""
            view-as alert-box error
            .
        end.
        assign
          chg-qnty = buf_utd-lines.Quantity
        .
        run trg/rsrv-dtl.p (input parparentproc,
                            'reserv':U,
                            buffer cpl_gds-dtl,
                            input-output chg-qnty,
                            input-output cpl_doc-line.price-base,
                            input-output cpl_doc-line.price-rubl,
                            -1,
                            input ("copy-utd-line" + chr(4) + string(recid(buf_utd-lines)))) no-error.
        if error-status:error
        then do :
          message ("Ошибка при копировании товара " + string(cpl_goods.gds-code) + "  " + cpl_goods.gds-name + chr(10) + return-value)
          view-as alert-box .
          undo c-l, return error.
        end .
        assign
          cpl_doc-line.doc-qnty  = cpl_doc-line.doc-qnty + chg-qnty
          cpl_gds-dtl.doc-qnty   = cpl_gds-dtl.doc-qnty  + chg-qnty
          cpl_gds-dtl.fact-qnty  = cpl_gds-dtl.doc-qnty
          cpl_doc-line.fact-qnty = cpl_doc-line.doc-qnty.
        assign
          varchg-qnty = varchg-qnty + chg-qnty
          vardoc-qnty = vardoc-qnty + cpl_gds-dtl.doc-qnty.
        if cpl_gds-dtl.doc-qnty = 0 then delete cpl_gds-dtl.
      end .
    end.
  end.
  run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
  if error-status :error then
  do:
    message
      "Ошибка при копировании документа (расчет шапки документа)." skip
      return-value skip
      error-status:get-message(1) skip
      view-as alert-box error.
    return error .
  end.
  pardoc-mode = 'ИЗМЕНЕНИЕ':U.
  run ui-on ("line").
  apply "entry" to br-dtl in frame d-out-doc.
END PROCEDURE.
PROCEDURE check-reason :
  define variable j_rsn-code like ub.trn-reason.reason-code no-undo.
  assign j_rsn-code = ( input frame d-out-doc t-doc.reason-code ).
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = j_rsn-code no-error.
  if not available ub.trn-reason then do:
    if j_rsn-code <> ? and j_rsn-code <> 0 then do:
      message "Неверно указано основание (причина) создания документа." view-as alert-box error.
    end.
    assign  rsn-name = "".
    display rsn-name with frame d-out-doc.
    if j_rsn-code = ? or j_rsn-code = 0 then do:
      assign t-doc.reason-code = 0.
      return.
    end.
    else do:
      return error.
    end.
  end.
  assign  rsn-name = ub.trn-reason.reason-name.
  display rsn-name with frame d-out-doc.
  assign  frame d-out-doc t-doc.reason-code.
END PROCEDURE.
PROCEDURE chk-upd-date :
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
if t-doc.ext-doc-type <> 'ee':U          and
   t-doc.ext-doc-type <> 'ep':U       and
   t-doc.ext-doc-type <> 're':U      and
   t-doc.ext-doc-type <> 'rs':U and
   t-doc.ext-doc-type <> 'we':U          and
   t-doc.ext-doc-type <> 'eo':U     then do:
   message "Дату факт можно редактировать только во внешнем расходе, внутриобъектном расходе, возврате поставщику, внешнем возврате, внешнем возврате через кассу или списании."
   view-as alert-box.
   display t-doc.fact-date with frame d-out-doc.
   return error.
end.
define variable vss-include-info108 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
if input frame d-out-doc t-doc.fact-date > v-today then do:
   message "Дата больше сегодняшней даты на объекте." view-as alert-box error.
   display t-doc.fact-date with frame d-out-doc.
   return error.
end.
if input frame d-out-doc t-doc.fact-date < v-today - 7 then do:
   varlog = yes.
   message "Заведенная факт дата отличается более чем на 7 дней от сегодняшней даты на объекте."
           "Отказаться от заведения даты?" view-as alert-box question
           buttons yes-no update varlog.
   if varlog then do:
      display t-doc.fact-date with frame d-out-doc.
      return error.
   end.
end.
if input frame d-out-doc t-doc.fact-date <> t-doc.fact-date then do:
define variable v-value-character as character no-undo .
define variable v-value-date      as date no-undo .
define variable v-value-decimal   as decimal no-undo .
define variable v-value-integer   as integer no-undo .
define variable v-value-logical   as logical no-undo .
define variable v-tth             as handle no-undo .
define variable v-back-date as logical   no-undo .
define variable v-back-date-type as character no-undo .
      delete object v-tth no-error.
      run adm/shattri.p (
           input "get":U
          ,input v-cntxt-obj-type
          ,input v-cntxt-obj-code
          ,input 'nakl_par':U
          ,input  "back-date"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-back-date
          ,output v-back-date-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          if error-status :error  then v-back-date = false .
          delete object v-tth no-error.
    if v-back-date <> true then do:
      message "Запрещено работать задним числом !" view-as alert-box information .
      display t-doc.fact-date with frame d-out-doc.
      return error.
    end.
   varlog = no.
   case t-doc.doc-type
   :
     when 'при':U
     then do:
define variable vss-include-info109 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
     end.
     when 'рас':U
     then do:
define variable vss-include-info110 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
     end.
     when 'возврат':U
     then do:
define variable vss-include-info111 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
     end.
     when 'спи':U
     then do:
define variable vss-include-info112 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
     end.
     when 'инв':U
     then do:
define variable vss-include-info113 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
     end.
     otherwise do:
       message
         vss-workfile vss-revision vss-description skip
         "Неизвестный тип документа" t-doc.doc-type skip
         "Документ" t-doc.doc-code skip
         view-as alert-box error .
       undo, return error return-value .
     end.
   end case .
   if varlog = no then do:
      display t-doc.fact-date with frame d-out-doc.
      return error.
   end.
   varlog = no.
   message "Вы хотите изменить фактическую дату?" skip
           "Если дату задать как '?' она при закрытии на факт проставится днем закрытия."
   view-as alert-box question buttons yes-no update varlog.
   if not varlog then do:
      display t-doc.fact-date with frame d-out-doc.
      return error.
   end.
   assign t-doc.fact-time = (24 * 60 * 60).
end.
END PROCEDURE.
PROCEDURE copy-lst :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
  define input parameter parcash-pay like ub.sysconf.cash-pay no-undo.
  define input parameter pardoc-prt  as   logical             no-undo.
  define input parameter table for tt-gds-list.
  define input parameter p-marks-par as character no-undo .
  define variable chg-qnty    like ub.gds-dtl.doc-qnty    no-undo.
  define variable legal-node  like ub.gds-prt.node-code   no-undo.
  define variable varcount    as   integer             no-undo.
  define variable varchg-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable vardoc-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable v-is-petrol as   logical             no-undo.
  define variable v-is-pieces as   logical             no-undo.
  define variable var-kg-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable rr-inv-line as   recid               no-undo.
  define variable v-tech-marks-qnty like gds-dtl.doc-qnty no-undo.
  define buffer cpl_goods    for ub.goods.
  define buffer cpl_gds-obj  for ub.gds-obj.
  define buffer cpl_prt-obj  for ub.prt-obj.
  define buffer cpl_trn-doc  for ub.trn-doc.
  define buffer cpl_gds-prt  for ub.gds-prt.
  define buffer cpl_gds-dtl  for ub.gds-dtl.
  define buffer cpl_doc-line for ub.doc-line.
  define buffer cpl_inv-line for ub.inv-line.
  define buffer buf_marking-lines for ub.marking-lines .
c-l:
do on error undo c-l, return error :
find first cpl_trn-doc where cpl_trn-doc.doc-code = pardoc-code.
r-l:
for each tt-gds-list,
     each cpl_goods where cpl_goods.prod-type = tt-gds-list.prod-type
                      and cpl_goods.prod-code = tt-gds-list.prod-code
                      and cpl_goods.artic     = tt-gds-list.artic     no-lock :
  assign varcount = varcount + 1.
  if varcount modulo 100 = 0 then do:
    run waitfram-show in this-procedure (input "ЖДИТЕ.  Обработано строк списка : " + string (varcount)).
  end.
  if p-marks-par = "tech-marks"
  then do :
    assign
      v-tech-marks-qnty = 0
    .
    for each buf_marking-lines no-lock where buf_marking-lines.gds-code = cpl_goods.gds-code
                                         and buf_marking-lines.obj-type = cpl_trn-doc.obj-type
                                         and buf_marking-lines.obj-code = cpl_trn-doc.obj-code
                                         and buf_marking-lines.out-code = 'free-zone':U
                                         and buf_marking-lines.mark begins 'tech_':U
                                         :
      assign
        v-tech-marks-qnty = v-tech-marks-qnty + 1
      .
    end .
    if v-tech-marks-qnty = 0 then next r-l.
  end .
  find cpl_gds-obj where cpl_gds-obj.obj-type  = cpl_trn-doc.obj-type
                     and cpl_gds-obj.obj-code  = cpl_trn-doc.obj-code
                     and cpl_gds-obj.prod-type = cpl_goods.prod-type
                     and cpl_gds-obj.prod-code = cpl_goods.prod-code
                     and cpl_gds-obj.artic     = cpl_goods.artic    no-lock no-error.
  if not available cpl_gds-obj or cpl_gds-obj.fact-qnty = 0 then next r-l.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdoclno in g#lib-trn
( input cpl_trn-doc.doc-code
 ,input cpl_trn-doc.obj-type
 ,input cpl_trn-doc.obj-code
 ,input cpl_goods.artic
 ,input cpl_goods.prod-type
 ,input cpl_goods.prod-code
 ,input cpl_goods.gds-name
 ,input cpl_goods.prt-root
 ,input ?
 ,input ?
 ,input parcash-pay
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании строки." skip
      return-value skip
      trim(error-status :get-message(1))
      trim(error-status :get-message(2))
      trim(error-status :get-message(3))
      trim(error-status :get-message(4))
      trim(error-status :get-message(5)) skip
      view-as alert-box error.
    undo c-l, return error return-value.
  end.
  if return-value = "next" then do:
    next r-l.
  end.
  find first cpl_doc-line where cpl_doc-line.doc-code  = cpl_trn-doc.doc-code and
                                cpl_doc-line.artic     = cpl_goods.artic      and
                                cpl_doc-line.prod-type = cpl_goods.prod-type  and
                                cpl_doc-line.prod-code = cpl_goods.prod-code .
  find first cpl_gds-prt where cpl_gds-prt.upper-code = cpl_goods.prt-root no-lock.
  for each cpl_prt-obj where cpl_prt-obj.obj-type  = cpl_trn-doc.obj-type
                         and cpl_prt-obj.obj-code  = cpl_trn-doc.obj-code
                         and cpl_prt-obj.artic     = cpl_goods.artic
                         and cpl_prt-obj.prod-type = cpl_goods.prod-type
                         and cpl_prt-obj.prod-code = cpl_goods.prod-code
                         and cpl_prt-obj.fact-qnty > 0              no-lock :
    if (pardoc-prt and not can-find (first cpl_gds-prt where cpl_gds-prt.upper-code = cpl_prt-obj.prt-code no-lock))
        or
       (not pardoc-prt and cpl_prt-obj.prt-code = cpl_gds-prt.node-code)
        then do:
      assign legal-node = cpl_prt-obj.prt-code.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input cpl_trn-doc.obj-code
   ,input cpl_trn-doc.obj-type
   ,input cpl_trn-doc.doc-code
   ,input cpl_goods.artic
   ,input cpl_goods.prod-code
   ,input cpl_goods.prod-type
   ,input legal-node
   ,input yes
  ) no-error .
      if error-status :error then do:
         return error substitute("Ошибка при создании признака &1.", return-value).
      end.
      find first cpl_gds-dtl where cpl_gds-dtl.doc-code  = cpl_trn-doc.doc-code and
                                   cpl_gds-dtl.artic     = cpl_goods.artic      and
                                   cpl_gds-dtl.prod-code = cpl_goods.prod-code  and
                                   cpl_gds-dtl.prod-type = cpl_goods.prod-type  and
                                   cpl_gds-dtl.prt-code  = legal-node.
      assign
        cpl_gds-dtl.ov  = no.
define variable vss-include-info114 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(cpl_gds-dtl)
  , input no
  , input ?
  ) no-error.
      if error-status :error then undo, next r-l.
      assign
        chg-qnty = cpl_prt-obj.fact-qnty
      .
      if p-marks-par = "tech-marks"
      then do :
        assign
          chg-qnty = v-tech-marks-qnty
        .
      end .
      run trg/rsrv-dtl.p (input parparentproc,
                          'reserv':U,
                          buffer cpl_gds-dtl,
                          input-output chg-qnty,
                          input-output cpl_doc-line.price-base,
                          input-output cpl_doc-line.price-rubl,
                          -1,
                          input p-marks-par) no-error.
      if error-status :error then undo c-l, return error.
      assign
        cpl_doc-line.doc-qnty  = cpl_doc-line.doc-qnty + chg-qnty
        cpl_gds-dtl.doc-qnty   = cpl_gds-dtl.doc-qnty  + chg-qnty
        cpl_gds-dtl.fact-qnty  = cpl_gds-dtl.doc-qnty
        cpl_doc-line.fact-qnty = cpl_doc-line.doc-qnty.
      assign
        varchg-qnty = varchg-qnty + chg-qnty
        vardoc-qnty = vardoc-qnty + cpl_gds-dtl.doc-qnty.
      if cpl_gds-dtl.doc-qnty = 0 then delete cpl_gds-dtl.
    end.
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input cpl_goods.artic
  ,  input cpl_goods.prod-type
  ,  input cpl_goods.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) .
  if v-is-petrol = yes
    and v-is-pieces <> yes
  then do:
    find last cpl_inv-line no-lock
      where cpl_inv-line.obj-type   = cpl_gds-obj.obj-type
        and cpl_inv-line.obj-code   = cpl_gds-obj.obj-code
        and cpl_inv-line.prod-type  = cpl_gds-obj.prod-type
        and cpl_inv-line.prod-code  = cpl_gds-obj.prod-code
        and cpl_inv-line.artic      = cpl_gds-obj.artic
        and cpl_inv-line.status_    = 'факт':U
        and cpl_inv-line.fact-order > 0
      use-index fact-order
      no-error.
    if available cpl_inv-line then do:
      assign
        var-kg-qnty = cpl_inv-line.after-cli-qnty
        cpl_doc-line.doc-density  = var-kg-qnty / varchg-qnty
        cpl_doc-line.fact-density = cpl_doc-line.doc-density
      .
      find first cpl_inv-line exclusive-lock
        where cpl_inv-line.doc-code  = cpl_doc-line.doc-code
          and cpl_inv-line.artic     = cpl_doc-line.artic
          and cpl_inv-line.prod-type = cpl_doc-line.prod-type
          and cpl_inv-line.prod-code = cpl_doc-line.prod-code
        no-error.
      if not available cpl_inv-line then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_corinvln in g#lib-trn3
( input  cpl_doc-line.doc-code
 ,input  cpl_doc-line.artic
 ,input  cpl_doc-line.prod-type
 ,input  cpl_doc-line.prod-code
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  vardoc-qnty * cpl_doc-line.doc-density
 ,input  cpl_doc-line.doc-density
 ,output rr-inv-line
 ) .
      end.
      else do:
        assign
          rr-inv-line = recid( cpl_inv-line )
          cpl_inv-line.wast-cli-qnty = vardoc-qnty * cpl_doc-line.doc-density
        .
      end.
    end.
  end.
end.
end.
if varchg-qnty > 0 then do:
  if varchg-qnty = vardoc-qnty then do:
    message "Все ФАКТ количества по списку товаров добавлены в документ успешно !".
  end.
  else do:
    message "Внимание !!!" skip (2)
                    "НЕ ВСЕ ФАКТ количество УДАЛОСЬ добавить в заполняемый документ !" skip (2)
                    "Общее количество в по списку на объекте : " varchg-qnty skip
                    "Удалось добавить в документ : " vardoc-qnty.
  end.
end.
END PROCEDURE.
PROCEDURE cr-tt-upd :
do on error undo, return error return-value :
define variable v-other as character   no-undo.
for each tt-upd-attr : delete tt-upd-attr . end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '1ord_time':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
    if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip     error-status :get-message(1) skip return-value view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '0rsrv-date':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
    if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip     error-status :get-message(1) skip return-value view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '2befpay':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
    if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip     error-status :get-message(1) skip return-value view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '3ord_Nchek':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
    if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip     error-status :get-message(1) skip return-value view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '4dchek':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
    if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip     error-status :get-message(1) skip return-value view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '5deliv':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
    if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip     error-status :get-message(1) skip return-value view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '6sumwrk':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
    if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip     error-status :get-message(1) skip return-value view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '8ord_adr':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
    if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip     error-status :get-message(1) skip return-value view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '9ord_hwo':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
    if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip     error-status :get-message(1) skip return-value view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '22ord_contact':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
    if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip     error-status :get-message(1) skip return-value view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '21ord_phone':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
    if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip     error-status :get-message(1) skip return-value view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '4ord_dl':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
    if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip     error-status :get-message(1) skip return-value view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'delivery-date':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
    if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip     error-status :get-message(1) skip return-value view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'delivery-time':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
    if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip     error-status :get-message(1) skip return-value view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'zakaz-date':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
    if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip     error-status :get-message(1) skip return-value view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'othermoves':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
    if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip     error-status :get-message(1) skip return-value view-as alert-box.    return error.  end.
end.
END PROCEDURE.
PROCEDURE cr-tt-upd-general :
do on error undo, return error return-value :
define variable v-other as character   no-undo.
for each tt-upd-attr : delete tt-upd-attr . end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'QntyPlace':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'PlaceStorage':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'Dispath':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'Packer':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'NFinDoc':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'DFinDoc':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'ddov':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'ndov':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'ndog':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'ddog':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'Recipient':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'Auto':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'Driver':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'print-num':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'idCountryContr':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'nsf':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'dsf':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  't_pass-fname':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  't_pass-position':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  't_accept-fname':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  't_accept-position':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'ndovwho':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'nosn':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'cargo-desc':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'carry-type':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'cargo-mass':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'exp-trans':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'zakaz-number':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'delivery-date':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'delivery-time':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '8ord_adr':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '22ord_contact':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '21ord_phone':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '4ord_dl':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'zakaz-date':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'othermoves':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
if v-is-pharm = "yes":U then do:
    create tt-upd-attr.  assign  tt-upd-attr.code =  'ser_on_pack':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
end.
end.
END PROCEDURE.
PROCEDURE create-record :
define  input parameter p-doc-code   like ub.trn-doc.doc-code    no-undo.
define  input parameter p-attr-code  like ub.doc-attr.attr-code  no-undo.
define  input parameter p-attr-value like ub.doc-attr.attr-value no-undo.
define output parameter p-exist      as   logical                no-undo.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-xst in g#trdcalib (  input p-doc-code ,
                        input p-attr-code ,
                       output p-exist )  .
  if p-exist = no then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input p-attr-code ,
                       input p-attr-value ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message( 1 ) '"' + p-attr-code + '"'
      view-as alert-box error.
    end.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME d-out-doc.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY varpurch-chs is-repay is-cons is-storage is-oldcons a-n-c loc-code
          loc-name loc-art varcontract-prn-code sum-base sum-rubl wrkr-name
          fact-base fact-rubl TEXT-RUBL agnt-name pay-rubl boss-name rsn-name
          flora-PS
      WITH FRAME d-out-doc.
  IF AVAILABLE ub.clients THEN
    DISPLAY ub.clients.obj-name
      WITH FRAME d-out-doc.
  IF AVAILABLE ub.pay-type THEN
    DISPLAY ub.pay-type.obj-name
      WITH FRAME d-out-doc.
  IF AVAILABLE t-doc THEN
    DISPLAY t-doc.cli-code t-doc.cli-type t-doc.hold-obj-code t-doc.hold-obj-type
          t-doc.print-rubl t-doc.doc-date t-doc.fact-date t-doc.shift-date
          t-doc.shift-name t-doc.shift-num t-doc.d-card t-doc.discnt-pc
          t-doc.discnt-type t-doc.out-code t-doc.base-rate t-doc.base-scale
          t-doc.tot-calc t-doc.discnt-rubl t-doc.pay-code t-doc.wrkr t-doc.agnt
          t-doc.boss t-doc.doc-qnty t-doc.fact-qnty t-doc.VAT-base
          t-doc.VAT-rubl t-doc.tot-cli t-doc.reason-code
      WITH FRAME d-out-doc.
  ENABLE b-exit rect-tot rect-prc b-cur b-arch b-notes b-attr b-cnt b-fixprice
         b-re-price b-rsrv-doc-list b-dopinf b-history b-help b-prev b-next
         t-doc.cli-code t-doc.cli-type r-clients ub.clients.obj-name
         t-doc.hold-obj-code t-doc.hold-obj-type t-doc.print-rubl
         t-doc.doc-date t-doc.fact-date t-doc.shift-date t-doc.shift-name
         t-doc.shift-num r-sht t-doc.d-card t-doc.discnt-pc t-doc.discnt-type
         t-doc.out-code r-outs t-doc.base-rate t-doc.base-scale r-acc
         t-doc.tot-calc t-doc.discnt-rubl varpurch-chs t-doc.pay-code r-pay
         is-repay t-doc.wrkr r-wrkr is-cons t-doc.agnt r-agnt is-storage
         is-oldcons t-doc.boss r-boss r-reas a-n-c loc-code loc-name loc-art
         varcontract-prn-code b-contr-lkp b-mark b-add b-prt b-parts b-lkp
         b-chg b-del b-notes-line br-dtl t-doc.doc-qnty t-doc.fact-qnty
         sum-base sum-rubl ub.pay-type.obj-name t-doc.VAT-base t-doc.VAT-rubl
         wrkr-name fact-base fact-rubl TEXT-RUBL agnt-name t-doc.tot-cli
         pay-rubl boss-name t-doc.reason-code rsn-name flora-PS b-marks
      WITH FRAME d-out-doc.
  open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base .
  FRAME d-out-doc:SENSITIVE = NO.
END PROCEDURE.
PROCEDURE find-gds :
find ub.bar-code where ub.bar-code.b-code = b-c no-lock.
find ub.goods where ub.goods.gds-code = ub.bar-code.gds-code no-lock.
assign gds-rec = recid (ub.goods).
find first ub.gds-dtl where
     ub.gds-dtl.doc-code  = t-doc.doc-code     and
     ub.gds-dtl.artic     = ub.goods.artic     and
     ub.gds-dtl.prod-type = ub.goods.prod-type and
     ub.gds-dtl.prod-code = ub.goods.prod-code and
     ub.gds-dtl.prt-code  = ub.bar-code.node-code no-lock no-error.
if not available ub.gds-dtl then do:
   message "В накладной не найден товар по данному бар-коду."
    view-as alert-box error buttons ok.
    return error.
end.
END PROCEDURE.
PROCEDURE init-attr-flora :
do on error undo, return error return-value :
run cr-tt-upd in this-procedure no-error.
define variable varexist                  as logical   no-undo.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '0rsrv-date':U                                                         ,  input  string(today)                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '1ord_time':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '2befpay':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '3ord_Nchek':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '5deliv':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '6sumwrk':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '22ord_contact':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '21ord_phone':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '8ord_adr':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '4ord_dl':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'delivery-date':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'delivery-time':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'zakaz-date':U                                                         ,  input  ""                                                         , output varexist ) no-error.
define buffer buf_clients for ub.clients.
define buffer buf_person  for ub.person.
define buffer buf_firm    for ub.firm.
define variable v-adr as character no-undo init "" .
define variable v-h   as character no-undo init "" .
find first buf_clients no-lock where
           buf_clients.obj-code =  t-doc.cli-code  and
           buf_clients.obj-type =  t-doc.cli-type    no-error .
if  available buf_clients then do:
  v-h = buf_clients.obj-name .
  if t-doc.cli-type = 'орг':U then do:
    find first buf_firm no-lock where buf_firm.firm-code = t-doc.cli-code no-error .
         v-adr = trim ( buf_firm.post-addr1 ) .
    end.
    else do:
        find first buf_person no-lock where buf_person.psn-code = t-doc.cli-code no-error .
        v-adr = string(buf_person.ind) + " " + buf_person.city + " " + buf_person.address .
    end.
end.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '4dchek':U                                                         ,  input  string(t-doc.doc-date)                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '8ord_adr':U                                                         ,  input  v-adr                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '9ord_hwo':U                                                         ,  input  v-h                                                         , output varexist ) no-error.
end.
END PROCEDURE.
PROCEDURE init-attr-general :
do on error undo, return error return-value :
run cr-tt-upd-general .
define variable varexist                  as logical   no-undo.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'QntyPlace':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'PlaceStorage':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'Dispath':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'Packer':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'NFinDoc':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'DFinDoc':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'ddov':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'ndov':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'ndog':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'ddog':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'Recipient':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'Auto':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'Driver':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'print-num':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'idCountryContr':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'nsf':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'dsf':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 't_pass-fname':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 't_pass-position':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 't_accept-fname':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 't_accept-position':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'ndovwho':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'nosn':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'cargo-desc':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'carry-type':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'cargo-mass':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'exp-trans':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'zakaz-number':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '22ord_contact':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '21ord_phone':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '8ord_adr':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '4ord_dl':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'delivery-date':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'delivery-time':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'zakaz-date':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'othermoves':U                                                         ,  input  ""                                                         , output varexist ) no-error.
if v-is-pharm = "yes":U then do:
    run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'ser_on_pack':U                                                         ,  input  ""                                                         , output varexist ) no-error.
end.
end.
END PROCEDURE.
PROCEDURE inv-line_price :
  define  input parameter p-gds-dtl-rec  as   recid                 no-undo.
  define  input parameter p-print-rubl   as   logical               no-undo.
  define output parameter p-out-price-kg like ub.gds-dtl.price-rubl no-undo initial 0.0.
  define variable p-inv-line-rec as recid   no-undo.
  define variable is-petrol      as logical no-undo.
  define variable is-pieces      as logical no-undo.
  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_gds-dtl  for ub.gds-dtl.
  do on error undo, return error return-value :
    find buf_gds-dtl        no-lock where recid( buf_gds-dtl ) = p-gds-dtl-rec no-error.
    if not available buf_gds-dtl then do:
      assign p-out-price-kg = ?.
      undo, return error "inv-line_price: не найдена строка накладной".
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_gds-dtl.artic
  ,  input buf_gds-dtl.prod-type
  ,  input buf_gds-dtl.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
    if error-status :error or v-is-ptrl <> "yes" or is-petrol <> yes or is-pieces <> no then do:
      undo, return error substitute( 'inv-line_price: &1 (произв. &2 &3) не топливный товар',
                                     buf_gds-dtl.artic, buf_gds-dtl.prod-type, buf_gds-dtl.prod-code ).
    end.
    find buf_inv-line no-lock where
         buf_inv-line.doc-code  = buf_gds-dtl.doc-code  and
         buf_inv-line.artic     = buf_gds-dtl.artic     and
         buf_inv-line.prod-code = buf_gds-dtl.prod-code and
         buf_inv-line.prod-type = buf_gds-dtl.prod-type no-error.
    if available buf_inv-line then do:
      assign
        p-inv-line-rec = recid( buf_inv-line )
      .
      find buf_gds-dtl  exclusive-lock where recid( buf_gds-dtl  ) = p-gds-dtl-rec.
      find buf_inv-line exclusive-lock where recid( buf_inv-line ) = p-inv-line-rec.
      assign
        p-out-price-kg = ( if p-print-rubl = yes then buf_inv-line.wast-rubl else buf_inv-line.wast-base )
      .
      find buf_inv-line        no-lock where recid( buf_inv-line ) = p-inv-line-rec.
      find buf_gds-dtl         no-lock where recid( buf_gds-dtl  ) = p-gds-dtl-rec.
      release buf_inv-line.
      release buf_gds-dtl.
    end.
  end.
END PROCEDURE.
PROCEDURE inv-line_qnty :
  define  input parameter p-gds-dtl-rec as   recid                no-undo.
  define output parameter p-out-qnty-kg like ub.gds-dtl.fact-qnty no-undo initial 0.0.
  define variable is-petrol as logical no-undo.
  define variable is-pieces as logical no-undo.
  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_gds-dtl  for ub.gds-dtl.
  do on error undo, return error return-value :
    find buf_gds-dtl no-lock where recid( buf_gds-dtl ) = p-gds-dtl-rec no-error.
    if not available buf_gds-dtl then do:
      assign p-out-qnty-kg = ?.
      undo, return error "inv-line_qnty: не найдена строка накладной".
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_gds-dtl.artic
  ,  input buf_gds-dtl.prod-type
  ,  input buf_gds-dtl.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
    if error-status :error or v-is-ptrl <> "yes" or is-petrol <> yes or is-pieces <> no then do:
      undo, return error substitute( 'inv-line_qnty: &1 (произв. &2 &3) не топливный товар',
                                     buf_gds-dtl.artic, buf_gds-dtl.prod-type, buf_gds-dtl.prod-code ).
    end.
    find buf_inv-line no-lock where
         buf_inv-line.doc-code  = buf_gds-dtl.doc-code  and
         buf_inv-line.artic     = buf_gds-dtl.artic     and
         buf_inv-line.prod-code = buf_gds-dtl.prod-code and
         buf_inv-line.prod-type = buf_gds-dtl.prod-type no-error.
    if available buf_inv-line then do: assign p-out-qnty-kg = buf_inv-line.wast-cli-qnty. end.
  end.
END PROCEDURE.
PROCEDURE inv-line_recalc-qty :
  define input parameter p-doc-code  like ub.gds-dtl.doc-code  no-undo.
  define input parameter p-artic     like ub.gds-dtl.artic     no-undo.
  define input parameter p-prod-type like ub.gds-dtl.prod-type no-undo.
  define input parameter p-prod-code like ub.gds-dtl.prod-code no-undo.
  define input parameter p-is-fact   as   logical              no-undo.
  define input parameter p-doc-qnty  like ub.gds-dtl.doc-qnty  no-undo.
  define input parameter p-fact-qnty like ub.gds-dtl.fact-qnty no-undo.
  define variable is_OK     as logical no-undo.
  define variable is_petrol as logical no-undo.
  define variable is_pieces as logical no-undo.
  define variable r-inv-lin as recid   no-undo.
  define variable r-doc-lin as recid   no-undo.
  define variable d_doc-qty as decimal no-undo.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_gds-dtl  for ub.gds-dtl.
  do on error undo, return return-value :
    if v-is-ptrl <> "yes" then do: undo, return. end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input p-artic
  ,  input p-prod-type
  ,  input p-prod-code
  , output is_petrol
  , output is_pieces
  ) no-error.
    if error-status :error or is_petrol <> yes or is_pieces <> no then do: undo, return. end.
    find first buf_doc-line no-lock where
               buf_doc-line.doc-code  = p-doc-code  and
               buf_doc-line.artic     = p-artic     and
               buf_doc-line.prod-type = p-prod-type and
               buf_doc-line.prod-code = p-prod-code no-error.
    if not available buf_doc-line then do: undo, return error "не найдена строка накладной". end.
    assign r-doc-lin = recid( buf_doc-line ).
    for each buf_gds-dtl no-lock where
             buf_gds-dtl.doc-code  = p-doc-code  and
             buf_gds-dtl.artic     = p-artic     and
             buf_gds-dtl.prod-type = p-prod-type and
             buf_gds-dtl.prod-code = p-prod-code :
      assign d_doc-qty = d_doc-qty + ( if buf_gds-dtl.doc-qnty = ? then 0 else buf_gds-dtl.doc-qnty ).
    end.
    if d_doc-qty * buf_doc-line.doc-density <> buf_doc-line.cli-qnty then do:
      find buf_doc-line exclusive-lock where recid( buf_doc-line ) = r-doc-lin.
      assign buf_doc-line.cli-qnty = d_doc-qty * buf_doc-line.doc-density.
      find buf_doc-line        no-lock where recid( buf_doc-line ) = r-doc-lin.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_corinvln in g#lib-trn3
( input  p-doc-code
 ,input  p-artic
 ,input  p-prod-type
 ,input  p-prod-code
 ,input  0
 ,input  0
 ,input  0
 ,input  0
 ,input  ( if p-is-fact = yes then p-doc-qnty * buf_doc-line.doc-density else p-fact-qnty * buf_doc-line.fact-density )
 ,input  ( if p-is-fact = yes then buf_doc-line.doc-density else buf_doc-line.fact-density )
 ,output r-inv-lin
 ) no-error.
    if error-status :error then do: undo, return. end.
    assign is_OK = br-dtl :refresh( ) in frame d-out-doc.
  end.
END PROCEDURE.
PROCEDURE local-add :
define buffer buf_assortment-matrix for ub.assortment-matrix  .
define buffer bf_contract-specif for ub.contract-specif.
define buffer bf-hv_doc-line     for ub.doc-line.
define buffer bf_goods           for ub.goods.
define buffer bf_parts           for ub.parts .
define buffer bf_doc-line        for ub.doc-line.
define buffer bf_gds-dtl         for ub.gds-dtl .
define buffer bf_marking-lines   for ub.marking-lines .
define buffer bf_gds-obj            for ub.gds-obj .
define variable varlog   as logical   no-undo.
define variable varnotes as character no-undo.
define buffer bbb_goods for ub.goods  .
define variable  var_is-petrol as logical   no-undo .
define variable  var_is-pieces as logical   no-undo .
define variable varvalue        as character no-undo .
define variable vartype         as character no-undo .
define variable vIsExemplarGoods as logical no-undo .
define variable v-type-mode-spr as character no-undo .
define variable varschartic like doc-line.artic initial " " no-undo.
define variable v-choice    as   integer                    no-undo.
define variable v-rid       as   integer                    no-undo.
define variable v-rid-list  as   char                       no-undo.
define variable i           as   integer                    no-undo.
define variable v-mark-weight as decimal no-undo .
define variable v-isweighed as logical no-undo .
do on error undo, return error return-value :
run check-rate no-error.
if error-status :error then do:
  message "Ошибка при проверке курса валют." skip
          return-value
  view-as alert-box error.
  return error return-value.
end.
.
if t-doc.reason-code <> ?
and t-doc.reason-code > 0
then do :
  if (lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
    or v-is-return)
  and t-doc.ext-doc-type = 'ee':U
  then do :
    v-choice = 5.
  end.
  else do :
    v-choice = 0.
  end.
end.
else do :
  v-choice = 0.
  if v-reasonm and
  lookup( t-doc.ext-doc-type, v-reasonme) = 0 and
  lookup( t-doc.ext-doc-type, 'es,em,wm,im,ot,rs,mp,pc':U) = 0
  then do:
    message "Сначала укажите Основание" view-as alert-box .
    apply "choose" to r-reas in frame d-out-doc.
    return .
  end.
end.
if t-doc.contract-code <> 0 and v-choice <> 5 then do:
define variable vss-include-info115 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  t-doc.host-code,
    INPUT  t-doc.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = t-doc.host-code
      i-gl-Contract-Code  = t-doc.contract-code
      .
END.
    FIND FIRST bf_contract-specif
           NO-LOCK
           WHERE
               bf_contract-specif.Host-code    = i-gl-Host-Code
           AND bf_contract-specif.Contract-num = i-gl-Contract-Code
           NO-ERROR
           .
    if available bf_contract-specif and not t-doc.is-flora then do:
      run gbl/d-askw.w
        (input "Добавление товаров"
        ,input "Выберите один из пунктов для добавления в накладную" + chr(10)
             + "товаров по спецификации к договору" + chr(10)
        ,input "|"
        ,input "Все|Выборочно|По справочнику|Отказ"
        ,input "Все недобавленные товары по спецификации|"
             + "Выборочно товары по спецификации|"
             + "Выбор товаров из справочника|"
             + "Отказ от выполнения операции"
        ,input 1
        ,input 4
        ,output v-choice
        ).
      if v-choice = 4 then do:
        run UI-on in this-procedure ( input "line" ).
        return.
      end.
    end.
end.
  if v-choice = 0 then
    v-choice = 3.
   assign
    varnotes = '':u
    varlns-cnt = 1.
  case v-choice:
    when 1 then do:
define variable vss-include-info116 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  t-doc.host-code,
    INPUT  t-doc.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = t-doc.host-code
      i-gl-Contract-Code  = t-doc.contract-code
      .
END.
FOR EACH
    bf_contract-specif
     NO-LOCK
     WHERE
         bf_contract-specif.Host-code    = i-gl-Host-Code
     AND bf_contract-specif.Contract-num = i-gl-Contract-Code
       on error undo, return error return-value :
    find first bf_goods where bf_goods.gds-code = bf_contract-specif.gds-code no-lock.
    find first bf-hv_doc-line where bf-hv_doc-line.doc-code  = t-doc.doc-code     and
                                    bf-hv_doc-line.artic     = bf_goods.artic     and
                                    bf-hv_doc-line.prod-type = bf_goods.prod-type and
                                    bf-hv_doc-line.prod-code = bf_goods.prod-code no-lock no-error.
    if not available bf-hv_doc-line then do:
      assign
        varnotes = varnotes + (if varnotes = '':u then '':u else ',':u) + string(recid(bf_goods)).
    end.
  end.
  if varnotes = '':u then do:
    message "Вы добавили уже все товары по спецификации."
    view-as alert-box.
    return error.
  end.
end.
    when 2 then do:
      run str/contspec.w (input parparentproc,
                      input "b-sel,b-mark",
                      input 'ПРОСМОТР':U,
                  input t-doc.host-code,
                      input t-doc.contract-code,
                      output v-rid-list) .
      if v-rid-list = '':u then do:
        message "Нет выбранных товаров по спецификации."
          view-as alert-box.
      end.
      do i = 1 to num-entries(v-rid-list):
        v-rid = integer(entry(i, v-rid-list)).
        find bf_contract-specif where recid(bf_contract-specif) = v-rid no-lock no-error.
        if available bf_contract-specif then do:
          find first bf_goods where bf_goods.gds-code = bf_contract-specif.gds-code no-lock.
          assign
            varnotes = varnotes + (if varnotes = '':u then '':u else ',':u) + string(recid(bf_goods)).
        end.
      end.
    end.
    when 3 then do:
    find first buf_assortment-matrix no-lock where
               buf_assortment-matrix.obj-code = v-cntxt-obj-code and
               buf_assortment-matrix.obj-type = v-cntxt-obj-type and
               buf_assortment-matrix.asmt-status = integer ('0':U) no-error .
                if available buf_assortment-matrix then do:
                    v-type-mode-spr = 'объект':U .
                end.
                else do:
                    v-type-mode-spr = 'все':U .
                end.
      run str/chs-gds.w ( input parparentproc
                    , input v-cntxt-obj-type
                    , input v-cntxt-obj-code
                    , input parlist-mode
                    , input t-doc.status_
                    , input "Строка ПН № " + t-doc.doc-code + " " + t-doc.status_ + " " + string (t-doc.flag_, "+/-")
                    , input v-type-mode-spr
                    , input t-doc.cli-type
                    , input t-doc.cli-code
                    , input t-doc.host-code
                    , input t-doc.ext-doc-type
                    , input-output varschartic
                    , output varnotes) no-error.
    end.
    when 5 then do:
      if v-is-return
          then do :
            run gbl/d-askw.w
              (input "Добавление товаров"
              ,input "Выберите один из пунктов для добавления в накладную" + chr(10)
              ,input "|"
              ,input "По документам|По справочнику|Отказ"
              ,input "Добавление товаров из конкретной ПН|"
              + "Добавление товаров из справочника|"
              + "Отказ от выполнения операции"
              ,input 1
              ,input 3
              ,output v-choice
              ).
            if v-choice = 3 then
            do:
              run UI-on in this-procedure ( input "line" ).
              return.
            end.
            if v-choice = 1
            then do :
              define variable ret-doc-code as character no-undo .
              run local-outs-ret-doc (output ret-doc-code) no-error .
              if error-status :error then undo, return .
              if ret-doc-code > ""
              and can-find(ub.trn-doc no-lock where ub.trn-doc.doc-code = ret-doc-code)
              then do :
                run ref/nakl-gds-ch.w (input ret-doc-code, input edo-return, output varnotes) .
              end .
            end .
            if v-choice = 2
            then do :
              find first buf_assortment-matrix no-lock where
                buf_assortment-matrix.obj-code = v-cntxt-obj-code and
                buf_assortment-matrix.obj-type = v-cntxt-obj-type and
                buf_assortment-matrix.asmt-status = integer ('0':U) no-error .
              if available buf_assortment-matrix then
              do:
                v-type-mode-spr = 'объект':U .
              end.
              else
              do:
                v-type-mode-spr = 'все':U .
              end.
              run str/chs-gds.w ( input parparentproc
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input parlist-mode
                , input t-doc.status_
                , input "Строка ПН № " + t-doc.doc-code + " " + t-doc.status_ + " " + string (t-doc.flag_, "+/-")
                , input v-type-mode-spr
                , input t-doc.cli-type
                , input t-doc.cli-code
                , input t-doc.host-code
                , input t-doc.ext-doc-type
                , input-output varschartic
                , output varnotes) no-error.
            end .
          end .
          else do :
            if t-doc.out-code = ?
            or t-doc.out-code = ""
            or not can-find(ub.trn-doc no-lock where ub.trn-doc.doc-code = t-doc.out-code)
            then do :
              message "Сначала выберите корректный источник (ПН)" view-as alert-box .
              return.
            end.
            run ref/nakl-gds-ch.w (input t-doc.out-code, input ?, output varnotes) .
          end .
    end.
  end case.
if varnotes = '' then return.
assign
  varline-mode = 'ДОБАВЛЕНИЕ':U
  prt-rec = ?
  varlns-cnt = 1.
 if available ub.gds-dtl then do:
   assign prt-rec = recid(ub.gds-dtl).
 end.
 else do:
   assign prt-rec = ?.
 end.
add-goods_ :
do while varlns-cnt <= num-entries (varnotes):
  assign
    gds-rec = integer (entry (varlns-cnt, varnotes))
    varlns-cnt = varlns-cnt + 1.
  v-param = if v-exist then string(v-buket-gds-code)
              else ? .
  if t-doc.doc-type = 'рас':U and
     t-doc.status_ = 'запрос':U then do:
     find first bbb_goods no-lock where
                recid(bbb_goods) = gds-rec .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bbb_goods.artic
  ,  input bbb_goods.prod-type
  ,  input bbb_goods.prod-code
  , output var_is-petrol
  , output var_is-pieces
  ) .
     if var_is-petrol = true then return error "Топливо нельзя продавать через ЗАПРОС ! " .
  end.
  find first bf_goods where recid(bf_goods) = gds-rec no-lock.
  RUN gds-attr-value (
          INPUT bf_goods.gds-code,
          INPUT 'mark-type':U,
          OUTPUT varvalue,
          OUTPUT vartype
          ).
  if t-doc.ext-doc-type = 'ep':U
  then do :
    if EDOParSec:GetIsEDOForType(varvalue)
    or EDOParSec:GetIsArticForType(varvalue)
    or EDOParSec:GetIsMarkingForType(varvalue)
    then do :
      message "Товар " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " подлежит обязательной маркировке. Для возврата используйте документ Расход внешний"
      view-as alert-box .
      assign
        varlns-cnt = varlns-cnt + 1.
      next.
    end .
  end .
  if varvalue > ""
  and EDOParSec:GetIsMarkingForType(varvalue)
  and not v-is-return
  then do :
    message "Товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " " skip
            "нельзя добавлять в ручном режиме, так как он подлежит маркировке и должен добавляться помарочно."
    view-as alert-box error.
    assign
      varlns-cnt = varlns-cnt + 1.
    next.
  end .
  if v-is-return
  then do :
    find first bf_gds-obj no-lock where bf_gds-obj.obj-type  = t-doc.obj-type
                                    and bf_gds-obj.obj-code  = t-doc.obj-code
                                    and bf_gds-obj.artic     = bf_goods.artic
                                    and bf_gds-obj.prod-type = bf_goods.prod-type
                                    and bf_gds-obj.prod-code = bf_goods.prod-code
                                    no-error .
    if not available bf_gds-obj
    then do:
      message "Критическая ошибка!" skip
              "Не найдена запись товара на объекте (gds-obj) " bf_goods.artic " " bf_goods.gds-name
      view-as alert-box error .
      assign
        varlns-cnt = varlns-cnt + 1.
      next.
    end.
    if bf_gds-obj.free-qnty <= 0
    then do :
      message "Невозможно выполнить возврат товара " bf_goods.artic " " bf_goods.gds-name ", т.к. текущие свободные остатки равны 0."
      view-as alert-box .
      assign
        varlns-cnt = varlns-cnt + 1.
      next.
    end .
    if can-find(first bf_doc-line no-lock where bf_doc-line.doc-code = t-doc.doc-code
                                            and bf_doc-line.artic = bf_goods.artic
                                            and bf_doc-line.prod-code = bf_goods.prod-code
                                            and bf_doc-line.prod-type = bf_goods.prod-type)
    then do :
      message "Товар " bf_goods.artic " " bf_goods.gds-name
              " уже добавлен. Запрещено выбирать более одной партии в рамках одной накладной."
      view-as alert-box .
      assign
        varlns-cnt = varlns-cnt + 1.
      next.
    end .
    if v-choice = 1
    then do :
      run str/parts-l.w
      (  input parparentproc
       ,  input t-doc.obj-type
       ,  input t-doc.obj-code
       ,  input bf_goods.gds-code
       ,  input ret-doc-code
       ,  input 'ПРОСМОТР':U
       ,  input 'документ':U
       ,  input 'текущий':U
       ,  input 'документ':U + chr(4) + "return"
       , output varpart-rec
      ) .
    end .
    if v-choice = 2
    then do :
      run str/parts-l-ret.w
      (input ParParentProc
      ,input t-doc.obj-type
      ,input t-doc.obj-code
      ,input bf_goods.gds-code
      ,input t-doc.doc-code
      ,input 'ПРОСМОТР':U
      ,input 'документ':U
      ,input 'текущий':U
      ,input 'документ':U
      ,output varpart-rec
      ) no-error .
    end .
    find first bf_parts no-lock where recid(bf_parts) = varpart-rec no-error .
    if not available bf_parts
    then do :
      assign
        varlns-cnt = varlns-cnt + 1.
      next.
    end .
    if t-doc.reason-code = 25
    then do :
      if t-doc.out-code = ?
      or t-doc.out-code = ""
      then do :
        t-doc.out-code = bf_parts.in-code .
        display t-doc.out-code with frame d-out-doc.
      end .
      else do :
        if t-doc.out-code <> bf_parts.in-code
        then do :
          message 'Для схемы возврата "Корректировка поступления" нельзя выбрать партии из разных ПН' view-as alert-box .
          assign
            varlns-cnt = varlns-cnt + 1.
          next.
        end .
      end .
    end .
    if EDOParSec:GetIsEDOForType(varvalue)
    or EDOParSec:GetIsArticForType(varvalue)
    or EDOParSec:GetIsMarkingForType(varvalue)
    then do :
      find first bf_marking-lines no-lock where bf_marking-lines.gds-code  = bf_goods.gds-code
                                            and bf_marking-lines.obj-type  = bf_parts.obj-type
                                            and bf_marking-lines.obj-code  = bf_parts.obj-code
                                            and bf_marking-lines.in-code   = bf_parts.in-code
                                            and bf_marking-lines.out-code  = bf_parts.out-code
                                            and bf_marking-lines.part-code = bf_parts.part-code
                                            no-error .
      if available bf_marking-lines
      or (num-entries(bf_parts.part-code, "_") = 2 and length(entry(1, bf_parts.part-code, "_")) = 14)
      then do :
        message "Товар подлежит обязательной маркировке и прослеживаемости, для возврата поставщику необходимо просканировать КМ" view-as alert-box .
        run scanMark in this-procedure (recid(bf_parts), buffer bf_goods, output vOk) no-error.
        if not vOk then
          next add-goods_ .
      end .
      else do :
        if EDOParSec:GetIsTransitionalForType(varvalue)
        then do :
          message "Возвращаем маркированные упаковки товара?" view-as alert-box question buttons yes-no update varlog .
          if varlog
          then do :
            run scanMark in this-procedure (recid(bf_parts), buffer bf_goods, output vOk) no-error.
            if not vOk then
              next add-goods_ .
          end .
          else do :
            run str/out-add.p (parparentproc,
                recid(t-doc),
                ?,
                ?,
                gds-rec,
                'ДОБАВЛЕНИЕ':U + chr(4) + "return=" + string(recid(bf_parts)),
                "Transitional") no-error.
            if error-status :error then
            do:
              next add-goods_ .
            end.
          end .
        end .
        else do :
          message "Товар подлежит обязательной маркировке и прослеживаемости, для возврата поставщику необходимо просканировать КМ" view-as alert-box .
          run scanMark in this-procedure (recid(bf_parts), buffer bf_goods, output vOk) no-error.
          if not vOk then
            next add-goods_ .
        end .
      end .
    end .
    else do :
      run str/out-add.p (parparentproc,
          recid(t-doc),
          ?,
          ?,
          gds-rec,
          'ДОБАВЛЕНИЕ':U + chr(4) + "return=" + string(recid(bf_parts)),
          v-param) no-error.
      if error-status :error then
      do:
        next add-goods_ .
      end.
    end .
  end .
  else
  if v-choice = 5
  then do :
    run str/out-add.p (parparentproc,
                   recid(t-doc),
                   ?,
                   ?,
                   gds-rec,
                   'ДОБАВЛЕНИЕ':U + chr(4) + "return",
                   v-param) no-error.
    if error-status :error then do:
      next.
    end.
  end .
  else do :
    run isExemplarGoods in this-procedure
       (t-doc.obj-type, t-doc.obj-code, bf_goods.gds-code, output vIsExemplarGoods).
    v-isweighed = WghProdVariable(t-doc.obj-type, t-doc.obj-code, bf_goods.gds-code) .
    if vIsExemplarGoods
    or v-isweighed
    then do:
      message "Товар подлежит обязательной маркировке и прослеживаемости, для списания необходимо просканировать КМ" view-as alert-box .
      run scanMark in this-procedure (?, buffer bf_goods, output vOk) no-error.
      if not vOk then
        next add-goods_ .
    end.
    else
    do:
        run str/out-add.p (parparentproc,
                       recid(t-doc),
                       ?,
                       ?,
                       gds-rec,
                       'ДОБАВЛЕНИЕ':U,
                       v-param) no-error.
        if error-status :error then do:
          next.
        end.
    end.
  end.
end.
if t-doc.ext-doc-type = 'ev':U
then do :
  run local-cur in this-procedure (input 4) no-error.
  if error-status :error then return .
end .
run ui-on ("line").
if prt-rec <> ? then do:
  reposition br-dtl to recid prt-rec no-error.
end.
end.
END PROCEDURE.
PROCEDURE local-check-gds :
  define variable l-inv-on as logical no-undo .
define variable vss-include-info117 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.doc-line.obj-type
  ,input  ub.doc-line.obj-code
  ,input  ub.doc-line.artic
  ,input  ub.doc-line.prod-type
  ,input  ub.doc-line.prod-code
  ,input  'inv-on=request'
  ,output l-inv-on
  ) no-error .
  if error-status :error then do:
    message
      "Ошибка получения признака товара на объекте" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply .
  end.
  if l-inv-on then do:
    message "Артикул :" ub.doc-line.artic ub.goods.gds-name
                    "- товар в инвентаризации."
                    skip (2) "Операция невозможна.".
    return error.
  end.
  if t-doc.status_ = 'запрос':U then do:
    message "Документ имеет статус ЗАПРОС. Изменение партий невозможно.".
    return error.
  end.
END PROCEDURE.
PROCEDURE local-cur :
define input parameter parwith-tax as integer no-undo.
define buffer cur-doc-line  for ub.doc-line.
define buffer cur-goods     for ub.goods.
define buffer cur-gds-dtl   for ub.gds-dtl.
define variable varpc       as decimal no-undo.
define variable varflag-ret as logical no-undo.
define variable round-base   as decimal no-undo.
define variable round-method as character    no-undo.
define variable varnew-price like ub.doc-line.price-base no-undo.
define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.
define variable v-host-code     like ub.sysconf.host-code  no-undo.
   if parwith-tax <> 4
   then do :
     case t-doc.doc-type
     :
       when 'рас':U
       then do:
define variable vss-include-info118 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_price':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
       end.
       when 'возврат':U
       then do:
define variable vss-include-info119 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_price':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
       end.
       when 'спи':U
       then do:
define variable vss-include-info120 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_price':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
       end.
       otherwise do:
         message
           vss-workfile vss-revision vss-description skip
           "Неизвестный тип документа" t-doc.doc-type skip
           "Документ" t-doc.doc-code skip
           view-as alert-box error .
         undo, return error return-value .
       end.
     end case .
   end .
   if varlog = no then return error.
   for each cur-doc-line no-lock where
            cur-doc-line.doc-code = t-doc.doc-code
   :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input cur-doc-line.artic
  ,  input cur-doc-line.prod-type
  ,  input cur-doc-line.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
        if error-status :error then do:
          message "Ошибка при вызове процедуры lib-trn_is-petrl из файла out-doc.w."
          view-as alert-box.
          return error.
        end.
        if is-petrolium = yes then do: assign varlog = no. end.
   end.
   if varlog = no then do:
      message "В накладной есть топливо. Запрещено устанавливать учетные цены."
      view-as alert-box.
      return error.
   end.
   assign varpc       = 0.00
          varflag-ret = no.
   if parwith-tax <> 3
   and parwith-tax <> 4
   then do:
     run str/pc-ov.w (input  parwith-tax,
                  output varpc,
                  output varflag-ret,
                  output round-base,
                  output round-method) no-error.
     if error-status :error or
        varflag-ret <> yes then return error.
   end.
   if parwith-tax = 4
   then do :
     assign
       varpc = 0
       varflag-ret = yes
       round-base = 0
       round-method = "Отключено"
     .
     parwith-tax = 2 .
   end .
   run waitfram-show in this-procedure (input "Простановка учетных цен").
   tr:
   do transaction:
   for each  cur-doc-line where cur-doc-line.doc-code   = t-doc.doc-code         ,
       first cur-goods    where cur-goods.artic         = cur-doc-line.artic     and
                                cur-goods.prod-type     = cur-doc-line.prod-type and
                                cur-goods.prod-code     = cur-doc-line.prod-code no-lock,
       each  cur-gds-dtl  where cur-gds-dtl.doc-code    = cur-doc-line.doc-code  and
                                cur-gds-dtl.artic       = cur-doc-line.artic     and
                                cur-gds-dtl.prod-type   = cur-doc-line.prod-type and
                                cur-gds-dtl.prod-code   = cur-doc-line.prod-code no-lock:
       assign
       line-rec = recid(cur-doc-line)
       gds-rec  = recid(cur-goods)
       prt-rec  = recid(cur-gds-dtl).
assign
  price-rubl-with-tax-loc = cur-doc-line.price-rubl
  price-base-with-tax-loc = cur-doc-line.price-base
.
define variable vss-include-info121 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = t-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = cur-doc-line.artic     and
                                     in-vatp-goods.prod-type = cur-doc-line.prod-type and
                                     in-vatp-goods.prod-code = cur-doc-line.prod-code no-lock.
   if (not t-doc.internal and
           t-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = cur-doc-line.road-tax
          road-tax-rubl-loc = cur-doc-line.road-tax * t-doc.base-rate / t-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = cur-doc-line.road-tax
          road-tax-base-loc = cur-doc-line.road-tax / t-doc.base-rate * t-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if cur-doc-line.transport-base = ? then 0 else cur-doc-line.transport-base)
        transport-rubl-loc = (if cur-doc-line.transport-rubl = ? then 0 else cur-doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if cur-doc-line.other-base     = ? then 0 else cur-doc-line.other-base)
        other-rubl-loc     = (if cur-doc-line.other-rubl     = ? then 0 else cur-doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if cur-doc-line.vat-pc         = ? then 0 else cur-doc-line.vat-pc)
        slt-pc-loc         = (if cur-doc-line.slt-pc         = ? then 0 else cur-doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = cur-doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = cur-doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = cur-doc-line.obj-code  and
                                      in-vatp-parts.artic     = cur-doc-line.artic     and
                                      in-vatp-parts.prod-type = cur-doc-line.prod-type and
                                      in-vatp-parts.prod-code = cur-doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if cur-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / cur-doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if cur-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / cur-doc-line.fact-qnty  else 0
        transport-base-loc  = if cur-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / cur-doc-line.fact-qnty  else 0
        transport-rubl-loc  = if cur-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / cur-doc-line.fact-qnty  else 0
        other-base-loc      = if cur-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / cur-doc-line.fact-qnty  else 0
        other-rubl-loc      = if cur-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / cur-doc-line.fact-qnty  else 0
                                        vat-base-loc        = if cur-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / cur-doc-line.fact-qnty   else 0
        slt-base-loc        = if cur-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / cur-doc-line.fact-qnty   else 0
                vat-rubl-loc        = if cur-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / cur-doc-line.fact-qnty   else 0
        slt-rubl-loc        = if cur-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / cur-doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
define variable vss-include-info122 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info123 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  cur-goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-vat-pc
  ) no-error .
       case parwith-tax:
       when 1 then do:
         assign varnew-price = (if t-doc.print-rubl then ((price-rubl-with-tax-loc - road-tax-rubl-loc - vat-rubl-loc) * (100 + varpc) / 100 * (100 + v-vat-pc) / 100 + road-tax-rubl-loc)
                                                    else ((price-base-with-tax-loc - road-tax-base-loc - vat-base-loc) * (100 + varpc) / 100 * (100 + v-vat-pc) / 100 + road-tax-base-loc)).
       end.
       when 2 then do:
         assign varnew-price = (if t-doc.print-rubl then price-rubl-with-tax-loc * (100 + varpc) / 100
                                                    else price-base-with-tax-loc * (100 + varpc) / 100).
       end.
       when 3 then do:
         assign varnew-price = (if t-doc.print-rubl then (price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc)
                                                    else (price-base-with-tax-loc - vat-base-loc - slt-base-loc)).
       end.
       end case.
       if parwith-tax <> 3 then do:
case round-method :
  when '9-окончание':U then do:
    if varnew-price < 29 then do:
      if (varnew-price - truncate (varnew-price, 0)) <> 0 then do:
        assign
          varnew-price = truncate (varnew-price, 0) + 1
        .
      end.
    end.
    else do:
      if (varnew-price modulo 10) < 3 then do:
        assign
          varnew-price = (varnew-price - (varnew-price modulo 100))
              + ( truncate (((varnew-price modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          varnew-price = (varnew-price - (varnew-price modulo 100))
              + ( truncate (((varnew-price modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        varnew-price = round (varnew-price, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if varnew-price < round-base then do:
      assign
        varnew-price = truncate (varnew-price, 0) + 0.99
      .
    end.
    else do:
      assign
        varnew-price = truncate (varnew-price / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      varnew-price = round (varnew-price, 0)
    .
  end.
  when 'Произвольно':U then do:
    if round-base <> 0 then do:
      assign
        varnew-price = round (varnew-price / round-base, 0) * round-base
      .
      if varnew-price = 0 then do:
        assign
          varnew-price = round-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if round-base <> 0 then do:
      if truncate ( varnew-price / round-base, 0 ) <> (varnew-price / round-base) then do:
        assign
          varnew-price = truncate (varnew-price / round-base, 0) * round-base + round-base
        .
      end.
    end.
    if varnew-price = 0 then do:
      assign
        varnew-price = round-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if round-base <> 0 then do:
      assign
        varnew-price = varnew-price * round-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" round-method skip
      "round-base"   round-base   skip
      "price"        varnew-price             skip
      view-as alert-box error .
  end.
end.
       end.
       if lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
       and t-doc.ext-doc-type = 'ee':U
       then do :
         run str/out-add.p (parparentproc,
                        recid(t-doc),
                        recid(cur-doc-line),
                        recid(cur-gds-dtl),
                        recid(cur-goods),
                        "update-sale-price" + chr(4) + "return",
                        string(varnew-price)) no-error.
         if error-status :error then do:
            message "Ошибка при вызове программы out-add.p" view-as alert-box.
            run waitfram-hide in this-procedure .
            undo tr, return error.
         end.
       end.
       else do :
         run str/out-add.p (parparentproc,
                        recid(t-doc),
                        recid(cur-doc-line),
                        recid(cur-gds-dtl),
                        recid(cur-goods),
                        "update-sale-price",
                        string(varnew-price)) no-error.
         if error-status :error then do:
            message "Ошибка при вызове программы out-add.p" view-as alert-box.
            run waitfram-hide in this-procedure .
            undo tr, return error.
         end.
       end.
       if parwith-tax = 3 then do:
         assign
           cur-doc-line.vat-pc = 0
           cur-doc-line.slt-pc = 0.
       end.
       run waitfram-show in this-procedure (input "Простановка учетных цен по товару " + string(cur-goods.artic) + " " +
                        string(cur-goods.prod-type) + " " + string(cur-goods.prod-code)).
   end.
   if parwith-tax = 3 then do:
     run gbl/calc-trn.p (input parparentproc, input recid (t-doc)).
   end.
   end.
   run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE local-del :
do on stop undo, return error:
  if del-list = "" then do:
    if not available ub.gds-dtl then do:
      message "Неправильный выбор строки.".
      return error.
    end.
    varlog = no.
    message "Удалить строку накладной ?   Вы уверены ?"
                    view-as alert-box question buttons ok-cancel update varlog.
    if not varlog then return error.
    assign
      prt-rec = recid (ub.doc-line)
      del-list = string (recid (ub.gds-dtl)).
    get next br-dtl.
    if available ub.doc-line then del-rec = recid (ub.doc-line).
    else do:
      reposition br-dtl to recid prt-rec no-error.
      get prev br-dtl.
      del-rec = recid (ub.doc-line).
    end.
  end.
  else do:
    varlog = no.
    message "УДАЛИТЬ  ВСЕ  ОТМЕЧЕННЫЕ  строки накладной ?   Вы уверены ?"
                    view-as alert-box question buttons ok-cancel update varlog.
    if not varlog then return error.
    del-rec = ?.
  end.
  assign
    varlns-cnt = 1.
  do while varlns-cnt <= num-entries (del-list):
    assign
      prt-rec = integer (entry (varlns-cnt, del-list))
      varlns-cnt = varlns-cnt + 1.
    find ub.gds-dtl where recid (ub.gds-dtl) = prt-rec exclusive.
    find ub.doc-line where ub.doc-line.doc-code = ub.gds-dtl.doc-code
                          and ub.doc-line.prod-code = ub.gds-dtl.prod-code
                          and ub.doc-line.prod-type = ub.gds-dtl.prod-type
                          and ub.doc-line.artic     = ub.gds-dtl.artic exclusive.
    define variable l-inv-on as logical no-undo .
define variable vss-include-info124 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.doc-line.obj-type
  ,input  ub.doc-line.obj-code
  ,input  ub.doc-line.artic
  ,input  ub.doc-line.prod-type
  ,input  ub.doc-line.prod-code
  ,input  'inv-on=request'
  ,output l-inv-on
  ) no-error .
    if error-status :error then do:
      message
        "Ошибка получения признака товара на объекте" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return no-apply .
    end.
    if l-inv-on then do:
      message
        "Товар в инвентаризации." skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        "Операция невозможна.".
      undo, return error.
    end.
    find ub.goods where ub.goods.prod-code = ub.gds-dtl.prod-code
                 and ub.goods.prod-type = ub.gds-dtl.prod-type
                 and ub.goods.artic     = ub.gds-dtl.artic no-lock.
    if lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
    and t-doc.ext-doc-type = 'ee':U
    then do :
      run str/out-add.p (parparentproc,
                     recid(t-doc),
                     recid(ub.doc-line),
                     recid(ub.gds-dtl),
                     recid (ub.goods),
                     "delete" + chr(4) + "return",
                     ?) no-error.
      if error-status :error then return error.
    end.
    else do :
      run str/out-add.p (parparentproc,
                     recid(t-doc),
                     recid(ub.doc-line),
                     recid(ub.gds-dtl),
                     recid (ub.goods),
                     "delete",
                     ?) no-error.
      if error-status :error then return error.
    end.
  end.
end.
END PROCEDURE.
PROCEDURE local-lookup :
assign
varline-mode = 'ПРОСМОТР':U
varprt-mode  = 'ПРОСМОТР':U.
find ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code
                        and ub.doc-line.prod-code = ub.gds-dtl.prod-code
                        and ub.doc-line.prod-type = ub.gds-dtl.prod-type
                        and ub.doc-line.artic         = ub.gds-dtl.artic no-lock.
find ub.goods where ub.goods.prod-code = ub.gds-dtl.prod-code
             and ub.goods.prod-type = ub.gds-dtl.prod-type
             and ub.goods.artic     = ub.gds-dtl.artic no-lock.
run str/out-add.p (
    parparentproc,
    recid(t-doc),
    recid(ub.doc-line),
    recid(ub.gds-dtl),
    recid (ub.goods),
    varline-mode,
    ?)
    no-error.
    if error-status :error then return error return-value .
apply "entry" to br-dtl in frame d-out-doc.
END PROCEDURE.
PROCEDURE local-m-outs-1 :
define variable loc-ref-list     as character no-undo .
define variable v-hold           as logical   no-undo .
define variable v-ext-doc-type   as character no-undo .
define variable v-doc-rec        as recid     no-undo .
define variable v-stat           as character no-undo .
define variable v-type           as character no-undo .
define variable v-internal       as logical   no-undo .
define variable v-list-mode      as character no-undo .
assign
  v-list-mode = 'выбор':U
  v-stat = ?
  v-type = ?
  v-internal = ?
  v-doc-rec = ?
  v-hold = ?
  v-ext-doc-type = ?
  .
run str/all-docs.w
    ( input parparentproc,
      input t-doc.host-code ,
      input t-doc.obj-type ,
      input t-doc.obj-code ,
      input v-list-mode,
      input v-stat     ,
      input v-type     ,
      input     ?      ,
      input v-internal ,
      input "b-sel":u,
      input v-ext-doc-type,
      input v-hold,
      input v-doc-rec,
      output loc-ref-list).
find first t-d-b where recid (t-d-b) = integer (loc-ref-list) no-lock no-error.
if not available t-d-b then do:
  display ? @ t-doc.out-code with frame d-out-doc.
  apply "entry" to b-add in frame d-out-doc.
  return error.
end.
display t-d-b.doc-code @ t-doc.out-code with frame d-out-doc.
run ask-copy in this-procedure no-error .
if error-status :error then return error return-value .
END PROCEDURE.
PROCEDURE local-outs-ret-doc :
  define output parameter ret-doc-code   as character no-undo .
  define variable v-at-value     as character no-undo .
  define variable v-at-type      as character no-undo .
  run str/choose-docs-for-return.w
    ( input t-doc.reason-code ,
      input edo-return,
      input t-doc.doc-code ,
      output ret-doc-code).
  find first t-d-b where t-d-b.doc-code = ret-doc-code no-lock no-error.
  if not available t-d-b then
  do:
    ret-doc-code = "" .
    return error.
  end.
END PROCEDURE.
PROCEDURE local-m-outs-1-ret :
define variable loc-ref-list     as character no-undo .
define variable v-hold           as logical   no-undo .
define variable v-ext-doc-type   as character no-undo .
define variable v-doc-rec        as recid     no-undo .
define variable v-stat           as character no-undo .
define variable v-type           as character no-undo .
define variable v-internal       as logical   no-undo .
define variable v-list-mode      as character no-undo .
define variable v-at-value     as character no-undo .
define variable v-at-type      as character no-undo .
find first ub.clients no-lock where ub.clients.obj-type = t-doc.cli-type
                                and ub.clients.obj-code = t-doc.cli-code .
assign
  v-list-mode = "client-income":u
  v-stat = 'факт':U
  v-type = ?
  v-internal = ?
  v-doc-rec = recid(ub.clients)
  v-hold = ?
  v-ext-doc-type = 'ie':U
.
run str/all-docs.w
    ( input parparentproc,
      input t-doc.host-code ,
      input t-doc.obj-type ,
      input t-doc.obj-code ,
      input v-list-mode,
      input v-stat     ,
      input v-type     ,
      input     ?      ,
      input v-internal ,
      input "b-sel":u,
      input v-ext-doc-type,
      input v-hold,
      input v-doc-rec,
      output loc-ref-list).
find first t-d-b where recid (t-d-b) = integer (loc-ref-list) no-lock no-error.
if not available t-d-b then do:
  display ? @ t-doc.out-code with frame d-out-doc.
  apply "entry" to b-add in frame d-out-doc.
  return error.
end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-d-b.doc-code ,
                        input 'nsf':U ,
                       output v-at-value ,
                       output v-at-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'nsf':U ,
                       input v-at-value ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-d-b.doc-code ,
                        input 'dsf':U ,
                       output v-at-value ,
                       output v-at-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'dsf':U ,
                       input v-at-value ) no-error .
assign t-doc.out-code = t-d-b.doc-code .
display t-doc.out-code with frame d-out-doc.
END PROCEDURE.
PROCEDURE local-m-outs-5 :
define variable loc-ref-list     as character no-undo .
define variable v-hold           as logical   no-undo .
define variable v-ext-doc-type   as character no-undo .
define variable v-doc-rec        as recid     no-undo .
define variable v-stat           as character no-undo .
define variable v-type           as character no-undo .
define variable v-internal       as logical   no-undo .
define variable v-list-mode      as character no-undo .
define variable i as integer   no-undo .
run ref/all-zakz.w
    ( input  parParentProc
    ,input   ?
    ,input   ?
    ,input   "firmord"
    ,input   ""
    ,input   "b-sel,b-mark"
    ,input   ""
    ,output  loc-ref-list ) no-error .
   if loc-ref-list = "" or loc-ref-list = ? then do:
       message "Ни чего не отметили в списке заказов !"
       view-as alert-box information .
        display
            ? @ t-doc.out-code
        with frame d-out-doc.
        apply "entry" to b-add in frame d-out-doc.
        return no-apply.
   end.
    if num-entries( loc-ref-list ) = 0  or  loc-ref-list = ""  or error-status :error
    then do:
        display
            ? @ out-code
        with frame d-out-doc.
        apply "entry" to b-add in frame d-out-doc.
        return no-apply.
    end.
    else do:
     repeat i = 1 to  num-entries( loc-ref-list ) :
        find first ub.ord-doc no-lock
            where recid( ub.ord-doc ) = integer( entry( i , loc-ref-list ) )  no-error.
        display
            ub.ord-doc.doc-code @ t-doc.out-code
        with frame d-out-doc.
             run ask-copy-ord  in this-procedure (
              input ub.ord-doc.doc-code,
              input ub.sysconf.cash-pay,
              input v-cntxp-doc-prt   )
              no-error .
              if error-status :error
              then do:
                  message
                          vss-workfile vss-revision vss-description
                      skip(1)
                      skip "Ошибка копирования заказа в документ ."
                      skip return-value
                      skip trim( error-status :get-message( 1 ) )
                  view-as alert-box error.
                  undo, return error return-value .
              end.
        end.
    end.
END PROCEDURE.
PROCEDURE local-parts :
do
  on error undo, return error return-value
  :
    define variable var_is-petrol as logical no-undo .
    define variable var_is-pieces as logical no-undo .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.gds-dtl.artic
  ,  input ub.gds-dtl.prod-type
  ,  input ub.gds-dtl.prod-code
  , output var_is-petrol
  , output var_is-pieces
  ) .
    if pardoc-mode <> 'ПРОСМОТР':U then do:
      run check-rate.
    end.
    find ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code
                    and ub.doc-line.prod-code = ub.gds-dtl.prod-code
                    and ub.doc-line.prod-type = ub.gds-dtl.prod-type
                    and ub.doc-line.artic     = ub.gds-dtl.artic .
    find ub.goods where ub.goods.prod-code = ub.gds-dtl.prod-code
                and ub.goods.prod-type = ub.gds-dtl.prod-type
                and ub.goods.artic     = ub.gds-dtl.artic      no-lock.
    if pardoc-mode = 'ПРОСМОТР':U or (var_is-petrol = yes and var_is-pieces = no) or t-doc.ext-doc-type = 'rv':U then do:
      assign
        work-mode = "lookup-parts":U
      .
    end.
    else do:
      run local-check-gds.
      assign
        work-mode = "update-parts":U
      .
    end.
    if (lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
    and t-doc.ext-doc-type = 'ee':U)
    or v-is-return
    then do :
      run str/out-add.p
        ( input parparentproc
         ,input recid(t-doc)
         ,input recid(ub.doc-line)
         ,input recid(ub.gds-dtl)
         ,input recid (ub.goods)
         ,input work-mode + chr(4) + "return"
         ,input ?
        ).
    end.
    else do :
      run str/out-add.p
        ( input parparentproc
         ,input recid(t-doc)
         ,input recid(ub.doc-line)
         ,input recid(ub.gds-dtl)
         ,input recid (ub.goods)
         ,input work-mode
         ,input ?
        ).
    end.
    if var_is-petrol = true
      and var_is-pieces = false
      and work-mode <> "lookup-parts"
    then do:
      run inv-line_recalc-qty in this-procedure
        ( input ub.gds-dtl.doc-code
          ,input ub.gds-dtl.artic
          ,input ub.gds-dtl.prod-type
          ,input ub.gds-dtl.prod-code
          ,input true
          ,input ub.gds-dtl.doc-qnty
          ,input ub.gds-dtl.fact-qnty
        ) .
    end.
  end.
END PROCEDURE.
PROCEDURE mark-list :
if not available ub.gds-dtl then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
define variable vss-include-info125 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid126 as character no-undo .
define variable v-num-entry126 as integer   no-undo .
assign
  v-str-recid126 = trim( string( recid( ub.gds-dtl ) , "->>>>>>>>>>>9":U ) )
  v-num-entry126 = lookup( v-str-recid126 , del-list )
.
if v-num-entry126 > 0 then do:
  assign
    entry( v-num-entry126, del-list ) = "":U
    del-list = trim( replace( del-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    del-list = del-list + ( if del-list = "":U then "":U else chr(44) ) + v-str-recid126
  .
end.
  br-dtl:refresh() in frame d-out-doc .
  varlog = br-dtl:select-next-row () in frame d-out-doc.
  apply "entry" to br-dtl in frame d-out-doc.
END PROCEDURE.
PROCEDURE proc-b-re-price :
  do
  on error undo, return error return-value
  :
define buffer bf_gds-dtl for ub.gds-dtl  .
  find first bf_gds-dtl no-lock where bf_gds-dtl.doc-code = t-doc.doc-code and bf_gds-dtl.ov = false  no-error .
  if not available bf_gds-dtl then do:
     message "Цены зафиксированы , пересчет цен невозможен." view-as alert-box information  .
     return .
  end.
define variable p-update as logical   no-undo .
   run str/re-prsum.p
       (input parparentproc,
        input t-doc.doc-code,
        output p-update
       ) no-error .
        if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "re-prsum.p"
          view-as alert-box error
        .
        if  p-update then do:
            run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
            if error-status :error then do:
              undo, return error.
            end.
            run ui-on ("line").
        end.
  end.
END PROCEDURE.
PROCEDURE proc-row-display :
  do
  on error undo, return error return-value
  :
define variable v-ok as logical   no-undo .
define variable vss-include-info127 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_grp-nabor in g#lib-trn3
( input  ub.goods.gds-code ,
  output v-ok
)
.
 if v-ok then  do:
    assign
      ub.bar-code.b-code:fgcolor in browse br-dtl = 2
      ub.gds-dtl.artic:fgcolor in browse br-dtl = 2
      v-gds-name :fgcolor in browse br-dtl = 2
      ub.gds-dtl.doc-qnty:fgcolor in browse br-dtl = 2
      ub.gds-dtl.fact-qnty:fgcolor in browse br-dtl = 2
    .
 end.
  end.
END PROCEDURE.
PROCEDURE proc-shift-name :
define buffer bf_shift-obj   for ub.shift-obj.
  define variable varfind-shift as integer initial 0.
  define variable varshift-date like ub.shift-obj.shift-date no-undo.
  define variable varshift-num  like ub.shift-obj.shift-num  no-undo.
  if input frame d-out-doc t-doc.shift-date <> ? then do:
    for each  bf_shift-obj where bf_shift-obj.obj-type   = t-doc.obj-type                             and
                                 bf_shift-obj.obj-code   = t-doc.obj-code                             and
                                 bf_shift-obj.shift-date = input frame d-out-doc t-doc.shift-date and
                                 bf_shift-obj.shift-name = input frame d-out-doc t-doc.shift-name no-lock on error undo, return error return-value :
      assign
        varfind-shift = varfind-shift + 1
        varshift-date = bf_shift-obj.shift-date
        varshift-num  = bf_shift-obj.shift-num.
    end.
    if varfind-shift = 0 or varfind-shift > 1 then do:
      if varfind-shift = 0 then do:
        message "Не найдена смена: " t-doc.obj-type " " t-doc.obj-code
                " Дата " input frame d-out-doc t-doc.shift-date " Номер смены " input frame d-out-doc t-doc.shift-name " ."
        view-as alert-box error.
      end.
      else do:
        message "Найдено более одной смены с одним номером в сменном дне. Объект: " t-doc.obj-type " " t-doc.obj-code
                " Дата " input frame d-out-doc t-doc.shift-date " Номер смены " input frame d-out-doc t-doc.shift-name " ."
        view-as alert-box error.
      end.
      display t-doc.shift-name with frame d-out-doc.
      run proc-sht no-error.
      if error-status:error then do: return error. end.
    end.
    else do:
      assign frame d-out-doc
        t-doc.shift-name.
      assign
        t-doc.shift-date = varshift-date
        t-doc.shift-num  = varshift-num.
      display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame d-out-doc.
      if t-doc.fact-date = ? then do: assign t-doc.fact-date = t-doc.shift-date t-doc.fact-time = (24 * 60 * 60). display t-doc.fact-date with frame d-out-doc. end.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-shift-num :
  define buffer bf_shift-obj   for ub.shift-obj.
  if input frame d-out-doc t-doc.shift-date <> ? then do:
    find first bf_shift-obj where bf_shift-obj.obj-type   = t-doc.obj-type                             and
                                  bf_shift-obj.obj-code   = t-doc.obj-code                             and
                                  bf_shift-obj.shift-date = input frame d-out-doc t-doc.shift-date and
                                  bf_shift-obj.shift-num  = input frame d-out-doc t-doc.shift-num  no-lock no-error.
    if not available bf_shift-obj then do:
      message "Не найдена смена: " t-doc.obj-type " " t-doc.obj-code
              " Дата " input frame d-out-doc t-doc.shift-date " Порядок смены " input frame d-out-doc t-doc.shift-num " ."
      view-as alert-box error.
      display t-doc.shift-num with frame d-out-doc.
      run proc-sht no-error.
      if error-status:error then do:
        return error.
      end.
    end.
    else do:
      assign
        t-doc.shift-date = bf_shift-obj.shift-date
        t-doc.shift-num  = bf_shift-obj.shift-num
        t-doc.shift-name = bf_shift-obj.shift-name.
      display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame d-out-doc.
      if t-doc.fact-date = ? then do:
        assign
          t-doc.fact-date = t-doc.shift-date
          t-doc.fact-time = (24 * 60 * 60).
        display t-doc.fact-date with frame d-out-doc.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-sht :
  define buffer bf_shift-obj   for ub.shift-obj.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
  run str/sht-all.w (parparentproc, t-doc.obj-type, t-doc.obj-code, 'b-sel', 'obj',t-doc.obj-type, t-doc.obj-code, '':u, input-output varrid-list) no-error.
  if error-status:error or varrid-list = "":u then do:
    return error.
  end.
  else do:
    assign
      varrecid = integer (entry(1, varrid-list)).
    find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
    if available bf_shift-obj then do:
      assign
        t-doc.shift-date = bf_shift-obj.shift-date
        t-doc.shift-num  = bf_shift-obj.shift-num
        t-doc.shift-name = bf_shift-obj.shift-name.
      display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame d-out-doc.
      if t-doc.fact-date = ? then do:
        assign
          t-doc.fact-date = t-doc.shift-date
          t-doc.fact-time = (24 * 60 * 60).
        display t-doc.fact-date with frame d-out-doc.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE select-reason :
  define variable j-rsn-code like ub.trn-reason.reason-code no-undo.
  assign j-rsn-code = ( input frame d-out-doc t-doc.reason-code ).
  run str/trn-reas.w ( input ParParentProc, input 'выбор':U, input-output j-rsn-code ).
  find first ub.trn-reason no-lock where ub.trn-reason.reason-code = j-rsn-code no-error.
  if available ub.trn-reason then do:
    if   t-doc.ext-doc-type = 'ee':U
       and (
            (    lookup( string(     t-doc.reason-code), v-reasons-for-return) gt 0
             and lookup( string(ub.trn-reason.reason-code), v-reasons-for-return) eq 0)
       or   (    lookup( string(     t-doc.reason-code), v-reasons-for-return) eq 0
             and lookup( string(ub.trn-reason.reason-code), v-reasons-for-return) gt 0)
           )
    then do:
      if not v-is-return
      then do :
        message "Данное основание используется для возврата поставщику. Выберите другое основание из списка." view-as alert-box .
        return no-apply.
      end .
      assign
        rsn-name          = ub.trn-reason.reason-name
        t-doc.reason-code = ub.trn-reason.reason-code
      .
      run check-cli in this-procedure no-error.
      if error-status :error then return no-apply.
    end.
    else do:
      assign
        rsn-name          = ub.trn-reason.reason-name
        t-doc.reason-code = ub.trn-reason.reason-code
      .
    end.
    display t-doc.reason-code rsn-name with frame d-out-doc.
  end.
  if lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
  and t-doc.ext-doc-type = 'ee':U
  then do :
    disable b-cur with frame d-out-doc.
  end.
  else do:
    enable b-cur with frame d-out-doc.
  end.
  if (t-doc.reason-code = 23 or t-doc.reason-code = 25)
     and edo-return = yes then
     disable b-bc with frame d-out-doc.
END PROCEDURE.
PROCEDURE set-work-mode-prt :
prt-rec = recid(ub.gds-dtl).
find ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code
                and ub.doc-line.prod-code = ub.gds-dtl.prod-code
                and ub.doc-line.prod-type = ub.gds-dtl.prod-type
                and ub.doc-line.artic     = ub.gds-dtl.artic no-lock.
line-rec = recid (ub.doc-line).
find ub.goods where ub.goods.prod-code = ub.gds-dtl.prod-code
             and ub.goods.prod-type = ub.gds-dtl.prod-type
             and ub.goods.artic     = ub.gds-dtl.artic no-lock.
gds-rec = recid  (ub.goods).
find ub.gds-prt where ub.gds-prt.upper-code = ub.goods.prt-root no-lock.
if ub.gds-prt.node-name = '_Пустая шкала':U then do:
  message "Товар :" ub.goods.artic ub.goods.gds-name "не делится на признаки - шкала недoступна.".
  return error.
end.
if pardoc-mode = 'ПРОСМОТР':U then do:
  assign
    varprt-mode  = 'ПРОСМОТР':U
    varline-mode = 'ПРОСМОТР':U
    work-mode    = "lookup-scale".
end.
else do:
  define variable l-inv-on as logical no-undo .
define variable vss-include-info128 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.doc-line.obj-type
  ,input  ub.doc-line.obj-code
  ,input  ub.doc-line.artic
  ,input  ub.doc-line.prod-type
  ,input  ub.doc-line.prod-code
  ,input  'inv-on=request'
  ,output l-inv-on
  ) no-error .
  if error-status :error then do:
    message
      "Ошибка получения признака товара на объекте" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply .
  end.
  if l-inv-on then do:
    message "Артикул :" ub.doc-line.artic ub.goods.gds-name
                    "- товар в инвентаризации."
                    skip (2) "Операция невозможна.".
    return error.
  end.
  assign
    varprt-mode  = 'ШКАЛА':U
    varline-mode = 'ИЗМЕНЕНИЕ':U
    work-mode = "update-scale".
end.
END PROCEDURE.
PROCEDURE ui-on :
define input parameter fnc as character no-undo.
define variable varexist                  as logical   no-undo.
define variable varpurch-limit            as character no-undo.
define variable varpurch-limit-type       as character no-undo.
define variable varpurch-code-string      as character no-undo.
define variable varpurch-code-string-type as character no-undo.
define buffer bf_doc-line for ub.doc-line.
define buffer bf_contract for ub.contract.
assign
  del-list = "":U
  loc-art  = "":U
.
if fnc = "enable" then do:
  disable all with frame d-out-doc.
  hide loc-art in frame d-out-doc loc-name loc-code in frame d-out-doc.
  enable b-exit b-lkp b-help br-dtl b-arch b-history a-n-c b-notes b-cnt b-attr with frame d-out-doc.
  if  t-doc.status_      = 'накл':U
  and t-doc.flag_        = false
  and t-doc.ext-doc-type = 're':U
  then do:
    enable b-rsrv-doc-list with frame d-out-doc .
  end.
  if t-doc.ext-doc-type = 'ee':U
  then do:
    find first ub.global-state no-lock no-error .
    if pardoc-mode <> 'ПРОСМОТР':U and available ub.global-state and  ub.global-state.pl-use-sum-group then do:
        enable b-re-price with frame d-out-doc .
      end.
  end.
  else do:
    hide b-re-price in frame d-out-doc .
  end.
  if t-doc.status_ = 'готов':U or
     t-doc.status_ = 'отказ':U
  then do:
     enable b-dopinf b-notes-line  with frame d-out-doc.
  end.
  else do:
   if  v-is-flora-ord then  do:
            enable   b-dopinf  b-notes-line  with frame d-out-doc.
       end.
       else hide  b-dopinf  b-notes-line  in frame d-out-doc.
  end.
  enable b-parts b-marks with frame d-out-doc.
  if prtvalue = "yes" and v-cntxp-doc-prt then enable b-prt with frame d-out-doc.
  if t-doc.ext-doc-type = 'ep':U then enable b-parts b-marks with frame d-out-doc.
  if pardoc-mode = 'ДОБАВЛЕНИЕ':U then do:
    run create-record in this-procedure (  input t-doc.doc-code
                                        ,  input 'purchlimit':U
                                        ,  input "no":U
                                        , output varexist ) .
    if varexist = no then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'purchcodelist':U ,
                       input '1,2,3,4':U )  .
    end.
  end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'purchlimit':U ,
                       output varpurch-limit ,
                       output varpurch-limit-type )  .
  if varpurch-limit = "no":u then do:
    assign
      varpurch-chs = 0.
    assign
      is-repay   = yes
      is-cons    = yes
      is-storage = yes
      is-oldcons = yes.
  end.
  else do:
    assign
      varpurch-chs = 1.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'purchcodelist':U ,
                       output varpurch-code-string ,
                       output varpurch-code-string-type )  .
    if lookup ('1':U, varpurch-code-string) > 0 then do:
      assign
        is-repay = yes.
    end.
    if lookup ('2':U, varpurch-code-string) > 0 then do:
      assign
        is-cons = yes.
    end.
    if lookup ('3':U, varpurch-code-string) > 0 then do:
      assign
        is-storage = yes.
    end.
    if lookup ('4':U, varpurch-code-string) > 0 then do:
      assign
        is-oldcons = yes.
    end.
  end.
  case t-doc.status_ :
       when 'накл':U then do:
           if t-doc.flag_ then assign ub.gds-dtl.doc-qnty:read-only  in browse br-dtl = yes.
           assign ub.gds-dtl.fact-qnty:read-only  in browse br-dtl = yes.
       end.
       when 'разрешен':U then assign ub.gds-dtl.doc-qnty:read-only  in browse br-dtl = yes.
       otherwise   assign ub.gds-dtl.doc-qnty:read-only  in browse br-dtl = yes
                          ub.gds-dtl.fact-qnty:read-only in browse br-dtl = yes.
  end case.
  case pardoc-mode :
    when 'ПРОСМОТР':U  then do:
         assign ub.gds-dtl.doc-qnty:read-only  in browse br-dtl = yes
                ub.gds-dtl.fact-qnty:read-only in browse br-dtl = yes.
         if parext-doc-mode = "":U then do:
            if br-handle = ? then hide b-prev b-next in frame d-out-doc .
                             else enable b-prev b-next with frame d-out-doc.
         end.
         if parext-doc-mode = "reason-code" then do:
            enable r-reas t-doc.reason-code with frame d-out-doc.
          end.
    end.
    when 'ДОБАВЛЕНИЕ':U then do: enable t-doc.cli-code t-doc.cli-type r-clients with frame d-out-doc. end.
    when 'ИЗМЕНЕНИЕ':U  then do:
      if t-doc.ext-doc-type = 'rv':U then do:
         assign ub.gds-dtl.doc-qnty:read-only  in browse br-dtl = yes
                ub.gds-dtl.fact-qnty:read-only in browse br-dtl = yes.
      end.
      if lookup(t-doc.doc-type, 'рас,спи':U) > 0
      then do:
        varlog = no.
        case t-doc.doc-type
        :
          when 'рас':U
          then do:
define variable vss-include-info129 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_price':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varlog
    )  .
end.
          end.
          when 'спи':U
          then do:
define variable vss-include-info130 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_price':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varlog
    )  .
end.
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Неизвестный тип документа" t-doc.doc-type skip
              "Документ" t-doc.doc-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .
        if t-doc.ext-doc-type <> 'ep':U    and
         t-doc.status_  = 'накл':U                         and
         not t-doc.flag_                                  and
         varlog = yes                                     and
         (lookup( string(t-doc.reason-code), v-reasons-for-return) = 0
         and t-doc.ext-doc-type <> 'ee':U)
         then do:
           enable b-cur with frame d-out-doc.
         end.
      end.
      if pardoc-mode <> 'ПРОСМОТР':U then do:
        enable r-reas t-doc.reason-code with frame d-out-doc.
      end.
      varlog = yes.
      if prev-pardoc-mode = pardoc-mode
      then do :
define variable vss-include-info131 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_doc-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varlog
    )  .
end.
      end.
      if varlog
      then do :
        enable t-doc.doc-date with frame d-out-doc.
      end.
      else do:
        assign
          t-doc.doc-date :tooltip in frame d-out-doc =  " Для пользователя недоступно право 'actn-expense-doc-date' ."
        .
      end.
      enable b-chg t-doc.wrkr
             t-doc.agnt t-doc.boss r-wrkr r-agnt r-boss
             t-doc.pay-code r-pay
             r-outs b-fixprice with frame d-out-doc.
      if not (t-doc.status_ =  'накл':U  or t-doc.status_ =  'запрос':U )
      then
         disable t-doc.pay-code r-pay with frame d-out-doc .
      varlog = no.
      case t-doc.doc-type
      :
        when 'при':U
        then do:
define variable vss-include-info132 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varlog
    )  .
end.
        end.
        when 'рас':U
        then do:
define variable vss-include-info133 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varlog
    )  .
end.
        end.
        when 'возврат':U
        then do:
define variable vss-include-info134 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varlog
    )  .
end.
        end.
        when 'спи':U
        then do:
define variable vss-include-info135 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varlog
    )  .
end.
        end.
        when 'инв':U
        then do:
define variable vss-include-info136 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varlog
    )  .
end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип документа" t-doc.doc-type skip
            "Документ" t-doc.doc-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
      if t-doc.ext-doc-type = 'iv':U
      then do:
        def var conf-par as character no-undo.
        def var par-type as character no-undo.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-erpRN'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  NO
  ,output conf-par
  ,output par-type
  ) no-error .
        if not error-status:error and conf-par = "yes":U
        then do:
          enable t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame d-out-doc.
        end.
      end.
      if (t-doc.ext-doc-type = 'ee':U           or
          t-doc.ext-doc-type = 'ep':U        or
          t-doc.ext-doc-type = 're':U       or
          t-doc.ext-doc-type = 'rs':U  or
          t-doc.ext-doc-type = 'we':U )  and varlog then do:
          enable t-doc.fact-date with frame d-out-doc.
define variable vss-include-info137 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,input  'shift-on=request'
  ,output varlog
  ) no-error .
         if error-status :error then do:
           message
           vss-workfile vss-revision vss-description skip
           "Ошибка при запуске процедуры objat" skip
           error-status :get-message(1) skip
           return-value skip
           view-as alert-box error .
           return error.
         end.
         if varlog then do:
          enable t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame d-out-doc.
         end.
      end.
      if not t-doc.internal then enable t-doc.print-rubl with frame d-out-doc.
      if t-doc.status_ = 'накл':U and
         t-doc.flag_   = no      then do:
        find first bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code no-lock no-error.
        if varpurch-limit = "no":u then do:
          if not available bf_doc-line then do:
            enable varpurch-chs with frame d-out-doc.
          end.
        end.
        else do:
          if not available bf_doc-line then do:
            enable varpurch-chs is-repay is-cons is-storage is-oldcons with frame d-out-doc.
          end.
        end.
      end.
      if not t-doc.flag_ and t-doc.status_ <> 'разрешен':U then do:
        enable t-doc.out-code with frame d-out-doc.
        if not t-doc.internal or t-doc.doc-type = 'рас':U or t-doc.status_ = 'запрос':U then do:
                    t-doc.is-flora = v-is-flora-ord .
             enable b-add b-del b-mark with frame d-out-doc.
           end.
        if can-do ('рас,спи,возврат':U, t-doc.doc-type) and
           not t-doc.internal then do:
           enable t-doc.discnt-type with frame d-out-doc.
           if t-doc.discnt-type = 'процент':U then
              enable t-doc.discnt-pc with frame d-out-doc.
           if t-doc.discnt-type = 'сумма':U then do:
             if varr-b = "base":u then do:
               enable  t-doc.tot-calc with frame d-out-doc.
             end.
             else do:
               enable t-doc.discnt-rubl with frame d-out-doc.
             end.
           end.
        end.
        if can-do ('рас,спи':U, t-doc.doc-type) then do:
          enable t-doc.cli-code r-clients with frame d-out-doc.
          if v-cntxp-out-rate then do:
             enable t-doc.base-rate t-doc.base-scale r-acc with frame d-out-doc.
          end.
        end.
        if t-doc.doc-type = 'возврат':U and v-cntxp-out-rate then
          enable t-doc.base-rate t-doc.base-scale r-acc with frame d-out-doc.
        if t-doc.status_ = 'запрос':U and
           t-doc.doc-type = 'при':U and
           t-doc.internal then
          enable t-doc.cli-code r-clients with frame d-out-doc.
      end.
    end.
  end case.
  if t-doc.internal = yes then do:
    hide t-doc.tot-calc    in frame d-out-doc
         t-doc.discnt-rubl in frame d-out-doc
         t-doc.discnt-type in frame d-out-doc
         t-doc.discnt-pc   in frame d-out-doc
         t-doc.vat-rubl    in frame d-out-doc
         t-doc.vat-base    in frame d-out-doc
         fact-base         in frame d-out-doc
         fact-rubl         in frame d-out-doc.
    if  t-doc.status_      = 'накл':U
    and t-doc.flag_        = true
    and t-doc.ext-doc-type = 'iv':U
    then do:
      enable b-revis with frame d-out-doc .
    end.
  end.
  if not can-do ('факт,разрешен':U, t-doc.status_) and
     not (t-doc.status_ = 'накл':U and t-doc.flag_ and t-doc.doc-type = 'при':U) then do:
    hide t-doc.fact-qnty t-doc.tot-cli pay-rubl in frame d-out-doc.
    menu-item m-outs-4:sensitive in menu m-outs = no.
  end.
end.
if t-doc.internal then do:
  if can-do ('факт,разрешен':U, t-doc.status_) or
     (t-doc.status_ = 'накл':U and t-doc.flag_ and t-doc.doc-type = 'при':U) then
    display t-doc.tot-fact @ sum-base
            t-doc.tot-sale @ sum-rubl
            t-doc.fact-qnty  t-doc.fact-date t-doc.shift-date t-doc.shift-num t-doc.shift-name t-doc.tot-cli
            t-doc.tot-rubl @ pay-rubl with frame d-out-doc.
  else
    display t-doc.tot-doc  @ sum-base
            t-doc.tot-rubl @ sum-rubl with frame d-out-doc.
end.
else do:
  if can-do ('факт,разрешен':U, t-doc.status_) then do:
    for each ub.gds-dtl where ub.gds-dtl.doc-code = t-doc.doc-code no-lock:
      accumulate (ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) * ub.gds-dtl.doc-qnty (total).
    end.
    display t-doc.tot-fact - t-doc.tot-calc @ fact-base
            t-doc.tot-sale - t-doc.discnt-rubl @ fact-rubl
            t-doc.tot-fact @ sum-base
            t-doc.tot-sale @ sum-rubl
            t-doc.fact-qnty t-doc.fact-date t-doc.shift-date t-doc.shift-num t-doc.shift-name t-doc.tot-cli
            (accum total (ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) * ub.gds-dtl.doc-qnty) @ pay-rubl with frame d-out-doc.
  end.
  else do:
    display t-doc.tot-doc - t-doc.tot-calc @ fact-base
            t-doc.tot-rubl - t-doc.discnt-rubl @ fact-rubl
            t-doc.tot-doc @ sum-base
            t-doc.tot-rubl @ sum-rubl with frame d-out-doc.
  end.
  if t-doc.discnt-type <> 'касс':U then do: display t-doc.discnt-type with frame d-out-doc. end.
  display t-doc.discnt-pc t-doc.d-card t-doc.discnt-rubl t-doc.tot-calc t-doc.vat-base t-doc.vat-rubl with frame d-out-doc.
  if not t-doc.internal             and
     t-doc.doc-type = 'возврат':U then do:
     display t-doc.fact-date t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame d-out-doc.
  end.
end.
if t-doc.out-code <> ? or t-doc.out-code:sensitive then
  display t-doc.out-code with frame d-out-doc.
else hide t-doc.out-code in frame d-out-doc.
find ub.trn-reason no-lock where
     ub.trn-reason.reason-code = t-doc.reason-code no-error.
assign
  rsn-name = ( if available ub.trn-reason then ub.trn-reason.reason-name else "":U )
.
display t-doc.cli-code t-doc.cli-type t-doc.doc-date t-doc.fact-date t-doc.shift-date t-doc.shift-num t-doc.shift-name t-doc.doc-qnty
        t-doc.base-rate t-doc.base-scale t-doc.pay-code varpurch-chs is-repay is-cons is-storage is-oldcons
        t-doc.reason-code rsn-name
with frame d-out-doc.
if paris-hold = yes then do:
  display t-doc.hold-obj-type t-doc.hold-obj-code with frame d-out-doc.
end.
display t-doc.print-rubl with frame d-out-doc.
find ub.clients where ub.clients.obj-type = t-doc.cli-type and ub.clients.obj-code = t-doc.cli-code no-lock no-error.
if available ub.clients then
  display ub.clients.obj-name with frame d-out-doc.
if parlist-mode = 'бух-все':U or parlist-mode = 'бух-без':U then do:
  find ub.clients where ub.clients.obj-type = t-doc.obj-type and ub.clients.obj-code = t-doc.obj-code no-lock.
  frame d-out-doc:title = "(" + substring (ub.clients.obj-name, 1, 35) + ") : ".
end.
else frame d-out-doc:title = t-doc.obj-type + " " + string (t-doc.obj-code, ">>>>9") + "  : ".
frame d-out-doc:title = frame d-out-doc:title + caps (func-get-name-from-ext-type ( t-doc.ext-doc-type, false  )) .
if t-doc.office then frame d-out-doc:title = frame d-out-doc:title + "УСЛУГ ".
frame d-out-doc:title = frame d-out-doc:title + " - " .
frame d-out-doc:title = frame d-out-doc:title
  + t-doc.status_ + " " + string (t-doc.flag_, "+/-") + " № " + t-doc.doc-code + "   - " .
  assign frame d-out-doc :title = frame d-out-doc :title +
    ( if parext-doc-mode = ""            then title-mode( pardoc-mode ) else ( caps( 'редакт-факт':U ) +
    ( if parext-doc-mode = "reason-code" then " кода основания"         else "":U ) ) ).
define variable vss-include-info138 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  t-doc.doc-code
  ,output is-doc-hold
  ) no-error .
if paris-hold = yes then do:
find first bf_contract where bf_contract.contract-code = t-doc.contract-code no-lock no-error.
end.
else do:
find first bf_contract where bf_contract.host-code     = ( if is-doc-hold then t-doc.cli-code  else t-doc.host-code )  and
                             bf_contract.contract-code = t-doc.contract-code no-lock no-error.
end.
if available bf_contract then do:
  assign
    varcontract-prn-code = bf_contract.contract-prn-code.
end.
else do:
  assign
    varcontract-prn-code = "БЕЗ ДОГОВОРА".
end.
display varcontract-prn-code with frame d-out-doc.
enable b-contr-lkp with frame d-out-doc .
b-contr-lkp:column =  varcontract-prn-code:column + length(trim(varcontract-prn-code)) + 1 .
  if t-doc.ext-doc-type = 'we':U or
    t-doc.internal = true
  then do:
    hide varcontract-prn-code b-contr-lkp in frame d-out-doc .
  end.
  if v-is-return
  then do :
    assign gds-dtl.doc-qnty:read-only  in browse br-dtl = yes.
    assign gds-dtl.fact-qnty:read-only  in browse br-dtl = yes.
    disable r-reas r-clients t-doc.cli-code b-cur r-outs with frame d-out-doc.
    if available bf_contract
    then do :
      find first buf_contract-attr no-lock where buf_contract-attr.host-code = bf_contract.host-code
                                             and buf_contract-attr.contract-code = bf_contract.contract-code
                                             and buf_contract-attr.attr-code = "contract-edi"
                                             no-error .
      if available buf_contract-attr
      and logical(buf_contract-attr.attr-value) = true
      then do :
        is-contract-edo = yes .
      end .
      else do :
        find first buf_contract-attr no-lock where buf_contract-attr.host-code = bf_contract.host-code
                                               and buf_contract-attr.contract-code = bf_contract.contract-code
                                               and buf_contract-attr.attr-code = "contract-diadoc"
                                               no-error .
        if available buf_contract-attr
        and logical(buf_contract-attr.attr-value) = true
        then do :
          is-contract-edo = yes .
        end .
      end .
      if is-contract-edo
      and EDOParSec:IsEdo
      then do :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'edo-return':U ,
                       output varvalue ,
                       output vartype ) no-error .
        if varvalue = "yes"
        then do:
          edo-return = yes .
          disable b-bc with frame d-out-doc.
        end.
        else do :
          edo-return = no .
        end .
        display edo-return with frame d-out-doc.
        if pardoc-mode <> 'ПРОСМОТР':U
        then do :
          enable edo-return with frame d-out-doc.
        end .
      end .
      else do :
        edo-return = no .
        display edo-return with frame d-out-doc.
        disable edo-return with frame d-out-doc.
      end .
    end .
    if not can-find(first doc-line no-lock where doc-line.doc-code = t-doc.doc-code)
    then do :
      t-doc.out-code = ? .
      display ? @ t-doc.out-code with frame d-out-doc.
    end .
  end .
if t-doc.ext-doc-type = 'eo':U then do :
    if pardoc-mode <> 'ПРОСМОТР':U then
    assign
        t-doc.cli-type = t-doc.obj-type
        t-doc.cli-code = t-doc.obj-code
    .
    find clients where clients.obj-type = t-doc.cli-type and clients.obj-code = t-doc.cli-code no-lock .
    display clients.obj-name t-doc.cli-type t-doc.cli-code with frame d-out-doc.
    disable t-doc.cli-type t-doc.cli-code r-clients b-fixprice b-cnt with frame d-out-doc.
    enable
        t-doc.reason-code t-doc.doc-date
        t-doc.pay-code
    with frame d-out-doc.
    if pardoc-mode <> 'ПРОСМОТР':U then
    enable
        b-add b-del b-mark b-chg
        t-doc.fact-date t-doc.out-code
        t-doc.wrkr t-doc.agnt t-doc.boss r-wrkr r-agnt r-boss
        r-outs r-pay r-reas
    with frame d-out-doc.
define variable vss-include-info139 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,input  'shift-on=request'
  ,output varlog
  ) no-error .
    if error-status :error then do:
       message
       vss-workfile vss-revision vss-description skip
       "Ошибка при запуске процедуры objat" skip
       error-status :get-message(1) skip
       return-value skip
       view-as alert-box error .
       return error.
    end.
    if varlog and pardoc-mode <> 'ПРОСМОТР':U then do:
      enable t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame d-out-doc.
    end.
    if t-doc.status_ = 'накл':U and t-doc.flag_ and pardoc-mode = 'ИЗМЕНЕНИЕ':U then do :
      disable b-add b-del b-mark r-acc r-pay r-outs with frame d-out-doc.
      hide t-doc.out-code in frame d-out-doc.
    end.
end.
display t-doc.wrkr t-doc.agnt t-doc.boss with frame d-out-doc.
  define variable v-ref-rec140   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display t-doc.wrkr with frame d-out-doc.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-out-doc t-doc.wrkr
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-out-doc.
  end.
  else display ? @ t-doc.wrkr ? @ wrkr-name with frame d-out-doc.
  define variable v-ref-rec141   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display t-doc.agnt with frame d-out-doc.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-out-doc t-doc.agnt
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-out-doc.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-out-doc.
  define variable v-ref-rec142   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display t-doc.boss with frame d-out-doc.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-out-doc t-doc.boss
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-out-doc.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-out-doc.
if t-doc.ext-doc-type = 'ep':U then do:
  disable t-doc.pay-code r-pay with frame d-out-doc.
  if t-doc.discnt-pc = 0 then hide t-doc.discnt-type t-doc.discnt-pc t-doc.tot-calc t-doc.discnt-rubl in frame d-out-doc.
end.
find ub.pay-type where ub.pay-type.obj-code = input frame d-out-doc t-doc.pay-code no-lock no-error.
if available ub.pay-type then do: display     ub.pay-type.obj-name with frame d-out-doc. end.
                      else do: display ? @ ub.pay-type.obj-name with frame d-out-doc. end.
release ub.pay-type no-error.
open query br-dtl  for each ub.doc-line where        ub.doc-line.doc-code = t-doc.doc-code no-lock,   each ub.gds-dtl where        ub.gds-dtl.doc-code  = t-doc.doc-code    and ub.gds-dtl.artic     = ub.doc-line.artic    and ub.gds-dtl.prod-code = ub.doc-line.prod-code    and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock,   each ub.gds-prt where        ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock ,   each ub.goods where        ub.goods.artic = ub.gds-dtl.artic    and ub.goods.prod-code = ub.gds-dtl.prod-code    and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock ,  each ub.bar-code no-lock where       ub.bar-code.gds-code = ub.goods.gds-code   and ub.bar-code.node-code = ub.gds-dtl.prt-code   and ub.bar-code.part-code = ''   and ub.bar-code.in-code = ''   and ub.bar-code.unit-cli = ub.goods.unit-base by ub.doc-line.line-num .
IF mImagePh THEN
DO:
    DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
if AVAILABLE goods then do:
    RUN gds-attr-value ( goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
    RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, goods.gds-code, OUTPUT vImageList).
    vCh = ENTRY (1, vImageList, ",":U).
    g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
end.
else
      ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
END.
ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
apply "value-changed" to br-dtl in frame d-out-doc.
END PROCEDURE.
PROCEDURE val-chg-is-cons :
define variable varstring as character no-undo.
do on error undo, return error return-value :
  if is-cons <> input frame d-out-doc is-cons then do:
    if is-repay = no and
       input frame d-out-doc is-cons = no and
       is-storage = no and
       is-oldcons = no then do:
       message "Не выбран ни один тип приобретения." view-as alert-box.
       display is-cons with frame d-out-doc.
    end.
    assign
      frame d-out-doc is-cons.
    assign
      varstring = "":u
    .
    if is-repay = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + '1':U.
    end.
    if is-cons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + '2':U.
    end.
    if is-storage = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + '3':U.
    end.
    if is-oldcons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + '4':U.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'purchcodelist':U ,
                       input varstring )  .
  end.
end.
END PROCEDURE.
PROCEDURE val-chg-is-oldcons :
define variable varstring as character no-undo.
do on error undo, return error return-value :
  if is-oldcons <> input frame d-out-doc is-oldcons then do:
    if is-repay = no and
       is-cons = no and
       is-storage = no and
       input frame d-out-doc is-oldcons = no then do:
       message "Не выбран ни один тип приобретения." view-as alert-box.
       display is-oldcons with frame d-out-doc.
    end.
    assign
      frame d-out-doc is-oldcons.
    assign
      varstring = "":u
    .
    if is-repay = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + '1':U.
    end.
    if is-cons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + '2':U.
    end.
    if is-storage = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + '3':U.
    end.
    if is-oldcons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + '4':U.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'purchcodelist':U ,
                       input varstring )  .
  end.
end.
END PROCEDURE.
PROCEDURE val-chg-is-repay :
define variable varstring as character no-undo.
do on error undo, return error return-value :
  if is-repay <> input frame d-out-doc is-repay then do:
    if input frame d-out-doc is-repay = no and
       is-cons    = no and
       is-storage = no and
       is-oldcons = no then do:
       message "Не выбран ни один тип приобретения." view-as alert-box.
       display is-repay with frame d-out-doc.
    end.
    assign
      frame d-out-doc is-repay.
    assign
      varstring = "":u
    .
    if is-repay = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + '1':U.
    end.
    if is-cons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + '2':U.
    end.
    if is-storage = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + '3':U.
    end.
    if is-oldcons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + '4':U.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'purchcodelist':U ,
                       input varstring )  .
  end.
end.
END PROCEDURE.
PROCEDURE val-chg-is-storage :
define variable varstring as character no-undo.
do on error undo, return error return-value :
  if is-storage <> input frame d-out-doc is-storage then do:
    if is-repay = no and
       is-cons = no and
       input frame d-out-doc is-storage = no and
       is-oldcons = no then do:
       message "Не выбран ни один тип приобретения." view-as alert-box.
       display is-storage with frame d-out-doc.
    end.
    assign
      frame d-out-doc is-storage.
    assign
      varstring = "":u
    .
    if is-repay = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + '1':U.
    end.
    if is-cons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + '2':U.
    end.
    if is-storage = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + '3':U.
    end.
    if is-oldcons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + '4':U.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'purchcodelist':U ,
                       input varstring )  .
  end.
end.
END PROCEDURE.
PROCEDURE ask-copy-ord :
  define input parameter p-ord-code  as character no-undo .
  define input parameter parcash-pay like ub.sysconf.cash-pay no-undo.
  define input parameter pardoc-prt  as   logical             no-undo.
  define variable chg-qnty    like gds-dtl.doc-qnty    no-undo.
  define variable legal-node  like ub.gds-prt.node-code   no-undo.
  define variable varcount    as   integer             no-undo.
  define variable varchg-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable vardoc-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable v-is-petrol as   logical             no-undo.
  define variable v-is-pieces as   logical             no-undo.
  define variable var-kg-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable rr-inv-line as   recid               no-undo.
  define buffer cpl_goods    for ub.goods   .
  define buffer cpl_gds-obj  for ub.gds-obj .
  define buffer cpl_prt-obj  for ub.prt-obj .
  define buffer cpl_gds-prt  for ub.gds-prt .
  define buffer cpl_gds-dtl  for ub.gds-dtl .
  define buffer cpl_doc-line for ub.doc-line.
  define buffer cpl_inv-line for ub.inv-line.
  define buffer buf_ord-doc  for ub.ord-doc .
  define buffer buf_ord-line for ub.ord-line.
c-l:
do on error undo c-l, return error :
find first buf_ord-doc where buf_ord-doc.doc-code = p-ord-code.
r-l:
for each buf_ord-line where buf_ord-line.doc-code  = p-ord-code ,
     each cpl_goods where cpl_goods.prod-type = buf_ord-line.prod-type
                      and cpl_goods.prod-code = buf_ord-line.prod-code
                      and cpl_goods.artic     = buf_ord-line.artic     no-lock :
  assign varcount = varcount + 1.
  if varcount modulo 100 = 0 then do:
    run waitfram-show in this-procedure (input "ЖДИТЕ.  Обработано строк списка : " + string (varcount)).
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdoclno in g#lib-trn
( input t-doc.doc-code
 ,input t-doc.obj-type
 ,input t-doc.obj-code
 ,input cpl_goods.artic
 ,input cpl_goods.prod-type
 ,input cpl_goods.prod-code
 ,input cpl_goods.gds-name
 ,input cpl_goods.prt-root
 ,input ?
 ,input ?
 ,input parcash-pay
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании строки." skip
      return-value skip
      trim(error-status :get-message(1))
      trim(error-status :get-message(2))
      trim(error-status :get-message(3))
      trim(error-status :get-message(4))
      trim(error-status :get-message(5)) skip
      view-as alert-box error.
    undo c-l, return error return-value.
  end.
  if return-value = "next" then do:
    next r-l.
  end.
  find first cpl_doc-line where cpl_doc-line.doc-code  = t-doc.doc-code and
                                cpl_doc-line.artic     = cpl_goods.artic      and
                                cpl_doc-line.prod-type = cpl_goods.prod-type  and
                                cpl_doc-line.prod-code = cpl_goods.prod-code .
  find first cpl_gds-prt where cpl_gds-prt.upper-code = cpl_goods.prt-root no-lock.
  find first  cpl_prt-obj where cpl_prt-obj.obj-type  = t-doc.obj-type
                         and cpl_prt-obj.obj-code  = t-doc.obj-code
                         and cpl_prt-obj.artic     = cpl_goods.artic
                         and cpl_prt-obj.prod-type = cpl_goods.prod-type
                         and cpl_prt-obj.prod-code = cpl_goods.prod-code no-error .
   if error-status :error then do:
   end.
  assign legal-node = if available cpl_prt-obj then cpl_prt-obj.prt-code else cpl_gds-prt.node-code .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input t-doc.obj-code
   ,input t-doc.obj-type
   ,input t-doc.doc-code
   ,input cpl_goods.artic
   ,input cpl_goods.prod-code
   ,input cpl_goods.prod-type
   ,input legal-node
   ,input yes
  ) no-error .
      find first cpl_gds-dtl where cpl_gds-dtl.doc-code  = t-doc.doc-code and
                                   cpl_gds-dtl.artic     = cpl_goods.artic      and
                                   cpl_gds-dtl.prod-code = cpl_goods.prod-code  and
                                   cpl_gds-dtl.prod-type = cpl_goods.prod-type  and
                                   cpl_gds-dtl.prt-code  = legal-node.
      assign
        cpl_gds-dtl.ov  = no.
define variable vss-include-info143 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(cpl_gds-dtl)
  , input no
  , input ?
  ) no-error.
      if error-status :error then do:
         message
           vss-workfile vss-revision vss-description skip
           error-status :get-message(1) skip
           return-value skip
           ""
           view-as alert-box error
         .
      end.
      assign
        chg-qnty = buf_ord-line.qnty
        .
      run trg/rsrv-dtl.p (input parparentproc, 'reserv':U, buffer cpl_gds-dtl, input-output chg-qnty, input-output cpl_doc-line.price-base, input-output cpl_doc-line.price-rubl, -1) no-error.
      if error-status :error then undo c-l, return error.
      assign
        cpl_doc-line.doc-qnty  = cpl_doc-line.doc-qnty + chg-qnty
        cpl_gds-dtl.doc-qnty   = cpl_gds-dtl.doc-qnty  + chg-qnty
        cpl_gds-dtl.fact-qnty  = cpl_gds-dtl.doc-qnty
        cpl_doc-line.fact-qnty = cpl_doc-line.doc-qnty.
      assign
        varchg-qnty = varchg-qnty + chg-qnty
        vardoc-qnty = vardoc-qnty + cpl_gds-dtl.doc-qnty.
      if cpl_gds-dtl.doc-qnty = 0 then delete cpl_gds-dtl.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input cpl_goods.artic
  ,  input cpl_goods.prod-type
  ,  input cpl_goods.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) .
  if v-is-petrol = yes
    and v-is-pieces <> yes
  then do:
    find last cpl_inv-line no-lock
      where cpl_inv-line.obj-type   = t-doc.obj-type
        and cpl_inv-line.obj-code   = t-doc.obj-code
        and cpl_inv-line.prod-type  = cpl_goods.prod-type
        and cpl_inv-line.prod-code  = cpl_goods.prod-code
        and cpl_inv-line.artic      = cpl_goods.artic
        and cpl_inv-line.status_    = 'факт':U
        and cpl_inv-line.fact-order > 0
      use-index fact-order
      no-error.
    if available cpl_inv-line then do:
      assign
        var-kg-qnty = cpl_inv-line.after-cli-qnty
        cpl_doc-line.doc-density  = var-kg-qnty / varchg-qnty
        cpl_doc-line.fact-density = cpl_doc-line.doc-density
      .
      find first cpl_inv-line exclusive-lock
        where cpl_inv-line.doc-code  = cpl_doc-line.doc-code
          and cpl_inv-line.artic     = cpl_doc-line.artic
          and cpl_inv-line.prod-type = cpl_doc-line.prod-type
          and cpl_inv-line.prod-code = cpl_doc-line.prod-code
        no-error.
      if not available cpl_inv-line then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_corinvln in g#lib-trn3
( input  cpl_doc-line.doc-code
 ,input  cpl_doc-line.artic
 ,input  cpl_doc-line.prod-type
 ,input  cpl_doc-line.prod-code
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  vardoc-qnty * cpl_doc-line.doc-density
 ,input  cpl_doc-line.doc-density
 ,output rr-inv-line
 ) .
      end.
      else do:
        assign
          rr-inv-line = recid( cpl_inv-line )
          cpl_inv-line.wast-cli-qnty = vardoc-qnty * cpl_doc-line.doc-density
        .
      end.
    end.
  end.
end.
end.
  run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
  if error-status :error then do:
    message
      "Ошибка при копировании документа (расчет шапки документа)." skip
      return-value skip
      error-status:get-message(1) skip
      view-as alert-box error.
    return error .
  end.
pardoc-mode = 'ИЗМЕНЕНИЕ':U.
run ui-on ("line").
apply "entry" to br-dtl in frame d-out-doc.
END PROCEDURE.
PROCEDURE copy-bb-list :
define buffer tdb_doc-line    for ub.doc-line.
define buffer tdb_gds-dtl     for ub.gds-dtl.
define buffer tdb_parts       for ub.parts .
define buffer buf_parts       for ub.parts .
define buffer buf-cli_clients for ub.clients  .
define variable v-num as integer initial 1 no-undo.
define variable  v-fact-qnty  as decimal   no-undo .
define variable  v-cli-qnty   as decimal   no-undo .
define variable  v-root-node  as integer   no-undo .
define buffer doc_parts for ub.parts  .
for each t-d-b-doc-line :
  delete t-d-b-doc-line.
end.
for each t-d-b-gds-dtl :
  delete t-d-b-gds-dtl.
end.
for each t-d-b-parts :
  delete t-d-b-parts.
end.
 for each bb-list :
        for each doc_parts no-lock where
                 doc_parts.in-code    = bb-list.in-code and
                 doc_parts.part-code  = bb-list.part-code and
                 doc_parts.obj-type   = t-doc.obj-type and
                 doc_parts.obj-code   = t-doc.obj-code and
                 doc_parts.artic      = bb-list.artic and
                 doc_parts.prod-type  = bb-list.prod-type and
                 doc_parts.prod-code  = bb-list.prod-code and
                 doc_parts.out-code   = 'free-zone':U
        :
        find first  t-d-b-parts where
                 t-d-b-parts.in-code    = bb-list.in-code and
                 t-d-b-parts.part-code  = bb-list.part-code and
                 t-d-b-parts.obj-type   = t-doc.obj-type and
                 t-d-b-parts.obj-code   = t-doc.obj-code and
                 t-d-b-parts.artic      = bb-list.artic and
                 t-d-b-parts.prod-type  = bb-list.prod-type and
                 t-d-b-parts.prod-code  = bb-list.prod-code and
                 t-d-b-parts.out-code   = t-doc.doc-code no-error .
       if not available t-d-b-parts then do:
          create t-d-b-parts.
          buffer-copy doc_parts to t-d-b-parts
          assign
            t-d-b-parts.out-code   = t-doc.doc-code
          .
       end.
   end.
 end.
  for each t-d-b-parts :
      find first t-d-b-doc-line where
                t-d-b-doc-line.doc-code  =  t-doc.doc-code and
                t-d-b-doc-line.artic     =  t-d-b-parts.artic and
                t-d-b-doc-line.prod-type =  t-d-b-parts.prod-type and
                t-d-b-doc-line.prod-code =  t-d-b-parts.prod-code no-error .
      if not available t-d-b-doc-line then do:
        create t-d-b-doc-line.
        v-fact-qnty = 0.
        v-cli-qnty  = 0.
      end.
      else do:
        v-fact-qnty = t-d-b-doc-line.fact-qnty.
        v-cli-qnty  = t-d-b-doc-line.cli-qnty.
      end.
      buffer-copy t-d-b-parts except status_ to t-d-b-doc-line
      assign
          t-d-b-doc-line.doc-code   = t-doc.doc-code
          t-d-b-doc-line.doc-qnty   = t-d-b-parts.fact-qnty + v-fact-qnty
          t-d-b-doc-line.fact-qnty  = t-d-b-parts.fact-qnty + v-fact-qnty
          t-d-b-doc-line.cli-qnty   = t-d-b-parts.cli-qnty  + v-cli-qnty
      .
  end.
  for each  t-d-b-doc-line where
                t-d-b-doc-line.doc-code  =  t-doc.doc-code :
      find first t-d-b-gds-dtl where
                t-d-b-gds-dtl.doc-code  =  t-doc.doc-code and
                t-d-b-gds-dtl.artic     =  t-d-b-doc-line.artic and
                t-d-b-gds-dtl.prod-type =  t-d-b-doc-line.prod-type and
                t-d-b-gds-dtl.prod-code =  t-d-b-doc-line.prod-code no-error .
      if not available t-d-b-gds-dtl then do:
        create t-d-b-gds-dtl.
      end.
define variable vss-include-info144 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  t-d-b-doc-line.artic
  ,input  t-d-b-doc-line.prod-type
  ,input  t-d-b-doc-line.prod-code
  ,output v-root-node
  )  .
      buffer-copy t-d-b-doc-line to t-d-b-gds-dtl
      assign
        t-d-b-gds-dtl.doc-code  = t-doc.doc-code
        t-d-b-gds-dtl.prt-code  = v-root-node
      .
  end.
block_copy:
do transaction
on error undo, return error return-value
on stop  undo, return error "stop"
:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_copy-ret in g#lib-trn
  (
    input parparentproc
  , input t-doc.doc-code
  , input t-doc.doc-type
  , input t-doc.status_
  , input t-doc.internal
  , input t-doc.cli-type
  , input t-doc.cli-code
  , input t-doc.discnt-type
  , input t-doc.tot-calc
  , input t-doc.discnt-pc
  , input t-doc.agnt
  , input t-doc.boss
  , input t-doc.wrkr
  , input t-doc.base-rate
  , input t-doc.base-scale
  , input t-doc.exch-code
  , input t-doc.vat-type
  , input t-doc.doc-code
  , input t-doc.discnt-type:sensitive in frame d-out-doc
  , input input frame d-out-doc t-doc.discnt-pc
  , input input frame d-out-doc t-doc.agnt
  , input input frame d-out-doc t-doc.boss
  , input input frame d-out-doc t-doc.wrkr
  , input input frame d-out-doc t-doc.base-rate
  , input input frame d-out-doc t-doc.base-scale
  , input ub.sysconf.cash-pay
  , input ub.sysconf.base-code
  , input-output table t-d-b-doc-line
  , input-output table t-d-b-gds-dtl
  , input-output table t-d-b-parts
  , input yes
  , input yes
  , input yes
  , input yes
  ) no-error.
  if error-status :error then do:
    message "Ошибка при копировании документа." skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2) skip
            error-status:get-message(3) skip
    view-as alert-box error.
    return error.
  end.
  run str/crdocpl.p
    ( input t-doc.doc-code
     ,input ?
     ,input "dens_doc-line":U
    ) no-error .
  if error-status :error then do:
    message
      "Ошибка при копировании документа (создание информации по складским местам)." skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error.
    return error .
  end.
  run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
  if error-status :error then do:
    message
      "Ошибка при копировании документа (расчет шапки документа)." skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error.
    return error .
  end.
end.
for each t-d-b-doc-line :
  delete t-d-b-doc-line.
end.
for each t-d-b-gds-dtl :
  delete t-d-b-gds-dtl.
end.
for each t-d-b-parts :
  delete t-d-b-parts.
end.
pardoc-mode = 'ИЗМЕНЕНИЕ':U.
run ui-on ("line").
apply "entry" to br-dtl in frame d-out-doc.
END PROCEDURE.
procedure rowdisp :
  do ii = 1 to extent (bcol).
    if valid-handle (bcol[ii])
    then do:
      assign
        bcol[ii]:bgcolor = RED_COLOR when get-vsdsts(buffer ub.gds-dtl) = "-".
    end.
  end.
end procedure.
procedure scanMark :
  define input parameter iRecidParts as recid no-undo.
  define parameter buffer iBufGoods for goods.
  define output parameter oOk as logical no-undo init true.
  define variable vRightChngQntyCode as character no-undo .
  define variable vRightChngQnty     as logical   no-undo .
  define buffer buf_doc-line for ub.doc-line.
  define buffer bf_gds-dtl   for ub.gds-dtl.
  v-add = yes .
  do while v-add :
    run str/chs-alcmarks.w (
      input parparentproc,
      input t-doc.doc-code,
      input 'ДОБАВЛЕНИЕ':U,
      input iBufGoods.gds-code,
      input if iRecidParts <> ? then string(iRecidParts) else "",
      output mark) no-error.
    if error-status :error or mark = "" or mark = ? then
    do:
      oOk = false.
      find first buf_doc-line no-lock where
                 buf_doc-line.doc-code = t-doc.doc-code
             and buf_doc-line.artic = iBufGoods.artic
             and buf_doc-line.prod-code = iBufGoods.prod-code
             and buf_doc-line.prod-type = iBufGoods.prod-type
           no-error .
      release bf_gds-dtl.
      if avail buf_doc-line then
          find first bf_gds-dtl no-lock where
                     bf_gds-dtl.doc-code = buf_doc-line.doc-code
                 and bf_gds-dtl.artic = buf_doc-line.artic
                 and bf_gds-dtl.prod-type = buf_doc-line.prod-type
                 and bf_gds-dtl.prod-code = buf_doc-line.prod-code
               no-error.
      if not avail bf_gds-dtl and
         (t-doc.ext-doc-type = 'ev':U or t-doc.ext-doc-type = 'we':U) then
      do:
          vRightChngQntyCode = if t-doc.ext-doc-type = 'we':U
                               then 'actn_write-off_add-no-mark':U
                               else 'actn_tdedt-ras-perem_add-no-mark':U.
define variable vss-include-info145 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  vRightChngQntyCode
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output vRightChngQnty
    )  .
end.
          if not vRightChngQnty then
          do:
            message "Товар не добавлен, т.к. не просканировано ни одой марки."
              view-as alert-box.
            return.
          end.
      end.
      run str/out-add.p (parparentproc,
          recid(t-doc),
          input recid(buf_doc-line),
          input (if available bf_gds-dtl then recid(bf_gds-dtl) else ?),
          gds-rec,
          (if available bf_gds-dtl then 'ИЗМЕНЕНИЕ':U else 'ДОБАВЛЕНИЕ':U) +
          if iRecidParts <> ? then (chr(4) + "return=" + string(iRecidParts)) else "",
          '') no-error.
      return.
    end.
    find first buf_doc-line exclusive-lock where buf_doc-line.doc-code = t-doc.doc-code
                                            and buf_doc-line.artic = iBufGoods.artic
                                            and buf_doc-line.prod-code = iBufGoods.prod-code
                                            and buf_doc-line.prod-type = iBufGoods.prod-type
                                            no-error .
    if not available (buf_doc-line)
    then do:
      run str/out-add.p (parparentproc,
          recid(t-doc),
          ?,
          ?,
          gds-rec,
          'ДОБАВЛЕНИЕ':U +
          if iRecidParts <> ? then (chr(4) + "return=" + string(iRecidParts)) else "",
          'scan-marks' + chr(3) + mark) no-error.
      if error-status :error then
      do:
        next .
      end.
      if return-value = "stop-add-marks"
      then do :
        v-add = no .
      end .
    end .
    else do :
      find first bf_gds-dtl exclusive-lock where bf_gds-dtl.doc-code = buf_doc-line.doc-code
                                             and bf_gds-dtl.artic = buf_doc-line.artic
                                             and bf_gds-dtl.prod-type = buf_doc-line.prod-type
                                             and bf_gds-dtl.prod-code = buf_doc-line.prod-code
                                             no-error.
      run str/out-add.p
        ( input parparentproc
        ,input recid(t-doc)
        ,input recid(buf_doc-line)
        ,input (if available bf_gds-dtl then recid(bf_gds-dtl) else ?)
        ,input gds-rec
        ,input 'ИЗМЕНЕНИЕ':U +
               if iRecidParts <> ? then (chr(4) + "return=" + string(iRecidParts)) else ""
        ,input 'scan-marks' + chr(3) + mark)
      no-error.
      if error-status :error then
      do:
        return error.
      end.
      if return-value = "stop-add-marks"
      then do :
        v-add = no .
      end .
    end .
  end .
end procedure.
