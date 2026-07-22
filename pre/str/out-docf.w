define input parameter parParentProc   as widget-handle no-undo.
define input parameter doc-mode        as character no-undo    .
define input parameter g#stat          as character no-undo    .
define input parameter br-handle       as   handle                  no-undo.
define input parameter bf-handle       as   handle                  no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Обработка РН (заведение, редактирование)":U .
define variable  paris-hold      as   logical   no-undo .
define variable  g#type          as   character no-undo .
define variable  parext-doc-type like ub.trn-doc.ext-doc-type no-undo .
define variable  parext-doc-mode as character no-undo .
define variable parstat           as character no-undo .
define variable partype           as character no-undo .
define variable parinternal       as logical   no-undo .
define variable g#mainmenu-handle as handle no-undo .
define variable varlog as logical   no-undo .
define variable rep-rec as recid no-undo .
define variable prt-mode as character no-undo .
define variable v-cntxp-cash-pay as integer   no-undo .
define variable is-doc-hold as logical   no-undo init false .
define variable varvalue as character no-undo.
define variable vartype  as character no-undo.
parext-doc-mode = doc-mode.
parstat = g#stat .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prescan:
define input parameter parrec-doc as recid no-undo.
define buffer ps_trn-doc  for ub.trn-doc.
define buffer ps_doc-line for ub.doc-line.
define buffer ps_gds-dtl  for ub.gds-dtl.
define buffer ps_parts    for ub.parts.
define variable to-null as logical no-undo.
define variable g-log   as logical no-undo.
do on error undo, return error return-value :
find first ps_trn-doc where recid (ps_trn-doc) = parrec-doc.
if (ps_trn-doc.doc-type = 'при':U and
    ps_trn-doc.status_  = 'накл':U   and
    ps_trn-doc.flag_)                     or
   (can-do ('рас,спи,возврат':U, ps_trn-doc.doc-type) and
    ps_trn-doc.status_ = 'разрешен':U                            ) then do:
  if can-find (first ps_doc-line where ps_doc-line.doc-code   = ps_trn-doc.doc-code and
                                       ps_doc-line.fact-qnty <> 0 no-lock)          then do:
    assign
      to-null = yes.
  end.
  else do:
    assign
      to-null = no.
  end.
  assign
    g-log = no.
  if to-null then do:
    message "Для приемки товара с использованием мобильного сканера"
            "фактические количества товара в документе должны быть обнулены." skip
            "При повторном использовании сканера для того же документа обнуление не требуется." skip (2)
            "Обнулить ФАКТ количества в документе ?"
    view-as alert-box question buttons yes-no update g-log.
  end.
  else do:
    message "В документе все ФАКТ количества нулевые."
             "Сделать их равными количествам товара по документу ?"
    view-as alert-box question buttons yes-no update g-log.
  end.
  if g-log then do:
    for each ps_doc-line where ps_doc-line.doc-code = ps_trn-doc.doc-code on error undo, return error return-value :
      assign
        ps_doc-line.fact-qnty = (if to-null then 0 else ps_doc-line.doc-qnty).
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_lnfactqt in g#lib-calc
(
 input parparentproc
,input recid(ps_doc-line)
,input no
,input ps_trn-doc.status_
,input ps_trn-doc.flag_       )
no-error.
      if error-status:error then do:
        undo, return error substitute("Ошибка при изменении &1 фактического количества по товару: &2 &3 &4 ",
                                      return-value,
                                      ps_doc-line.artic,
                                      ps_doc-line.prod-type,
                                      ps_doc-line.prod-code).
      end.
    end.
    for each ps_gds-dtl where ps_gds-dtl.doc-code = ps_trn-doc.doc-code:
      assign
        ps_gds-dtl.fact-qnty  = (if to-null then 0 else ps_gds-dtl.doc-qnty).
    end.
    for each ps_parts where ps_parts.out-code = ps_trn-doc.doc-code:
      assign
        ps_parts.fact-qnty = if to-null then 0 else ps_parts.qnty.
    end.
  end.
end.
end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "X(65)" no-undo
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable list-mode          as character no-undo .
define variable line-mode          as character no-undo .
define variable varline-mode          as character no-undo .
define variable gds-rec            as recid no-undo .
define variable line-rec           as recid no-undo .
define variable doc-rec            as recid no-undo .
define variable pardoc-rec         as recid no-undo .
define variable prt-rec            as recid no-undo .
define variable ref-rec            as recid no-undo .
define variable g#internal         as logical   no-undo .
define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define shared variable next-prev   as logical no-undo .
define variable parnext-prev   as logical no-undo .
define variable pardoc-mode as character no-undo .
define variable parline-mode          as character no-undo .
define new shared buffer gds-dtl  for ub.gds-dtl.
define new shared buffer gds-prt  for ub.gds-prt.
define new shared buffer goods    for ub.goods.
define new shared buffer bar-code for ub.bar-code.
define variable  notes       as   character no-undo .
define variable  lns-cnt     as   integer   no-undo .
define variable trn-type as integer no-undo init 0.
define variable g#host-name  as character no-undo .
define variable g#host-code  as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log        as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
assign
  store-type        = v-cntxt-obj-type
  store-code        = v-cntxt-obj-code
  g#mainmenu-handle = parParentProc
.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output g#host-code
  ,output g#host-name
  )  .
run get-report-num  in parParentProc ( output g#report-num ).
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define buffer buf_rep_currency for ub.currency  .
find first buf_rep_currency no-lock
     where buf_rep_currency.curr-code = base-code
     no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
               else base-type = "б.в." .
parext-doc-type =  'ee':U .
g#type = 'рас':U .
paris-hold = false .
g#internal = false .
partype = 'рас':U .
parinternal = false .
define variable bar-str like ub.prod-bc.b-str  no-undo.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer cli-buf   for ub.clients.
define buffer t-d-b     for ub.trn-doc.
define buffer old-line  for ub.doc-line.
define buffer d-l-b     for ub.doc-line.
define buffer l-gds-dtl for ub.gds-dtl.
define shared buffer t-doc for  ub.trn-doc.
define query br-docs for t-doc scrolling.
define temp-table tt-1 no-undo
field gds-code  as integer
field prt-code as integer
field fact-qnty as decimal
index code is primary
gds-code
prt-code
.
define temp-table tt-posy no-undo
field gds-code       as integer
field gds-name       as character
field gds-dopinf     as character
field sum-rubl       as decimal
field sum-base       as decimal
index pi is primary gds-code
.
define new shared temp-table tt-flor no-undo
field gds-code-posy  as integer
field gds-code       as integer
field prt-code       as integer
field fact-qnty      as decimal
index pi             is primary gds-code-posy gds-code prt-code
.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable add-sens  as logical                   no-undo.
define variable b-c       as integer                   no-undo.
define variable b-c-char  as character                 no-undo.
define variable rate      as decimal                   no-undo.
define variable ret-mode  as character                 no-undo.
define variable add-scan  as logical initial no        no-undo.
define variable work-mode like line-mode               no-undo.
define variable varhold   as character                 no-undo.
define variable varhold-type  as character             no-undo.
define variable bcvalue       as character initial ?   no-undo.
define variable bctype        as character initial ?   no-undo.
define variable prtvalue      as character initial ?   no-undo.
define variable prttype       as character initial ?   no-undo.
define variable conf-par      as character             no-undo.
define variable varartic      like ub.doc-line.artic      initial " " no-undo.
define variable is-pieces     as logical               no-undo.
define variable v-cond        as character initial ?   no-undo.
define variable is-repay      as logical               no-undo.
define variable is-cons       as logical               no-undo.
define variable is-storage    as logical               no-undo.
define variable is-oldcons    as logical               no-undo.
define variable varr-b        as character             no-undo.
define variable v-is-tsd      as character             no-undo.
define variable v-is-tsd-type as character             no-undo.
define variable v-exist       as logical               no-undo.
define variable v-buket-gds-code as integer            no-undo.
define variable v-param       as character             no-undo.
define variable v-gds-name    as character             no-undo.
define variable pr-wrk as character no-undo .
define variable pr-srk as character no-undo .
define variable v-pr-wrk as decimal   no-undo .
define variable v-pr-srk as decimal   no-undo .
define variable p-type as character no-undo .
define variable ii-sum-rubl as decimal   no-undo .
define variable ii-sum-base as decimal   no-undo .
DEFINE VARIABLE i-sum-rubl AS CHARACTER FORMAT "X(256)"
     VIEW-AS TEXT
     SIZE 14 BY 1
     FGCOLOR 4 FONT 4 NO-UNDO.
DEFINE VARIABLE i-sum-base AS CHARACTER FORMAT "X(256)"
     VIEW-AS TEXT
     SIZE 14 BY 1
     FGCOLOR 4 FONT 4 NO-UNDO.
function get-mark return character (buffer local-gds-dtl for gds-dtl ).
   if lookup (string (recid (local-gds-dtl)), del-list) > 0  then return "*".
                                                             else return  "".
end function.
define            query br-posy for tt-posy scrolling.
define new shared buffer buf_tt-flor for tt-flor.
define new shared query br-dtl  for buf_tt-flor, gds-dtl, gds-prt, goods, bar-code scrolling.
define browse br-posy query br-posy no-lock display
tt-posy.gds-code column-label "Бар-код"  format "999999999"
tt-posy.gds-name column-label "Нетоварная позиция" format "x(38)"
tt-posy.sum-base column-label "Итого (баз.вал)"        format  "->>>>>>>>>>>>>>>>>>>9.99"
tt-posy.sum-rubl column-label "Итого (руб)"    format  "->>>>>>>>>>>>>9.99"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 80 BY 3
         FONT 4 ROW-HEIGHT-CHARS .49 EXPANDABLE.
.
define new shared browse br-dtl query br-dtl no-lock display
  get-mark  (BUFFER gds-dtl)  column-label '*'  format "x(1)"
  bar-code.b-code  column-label 'Бар-код'
  gds-dtl.artic  column-label 'Артикул'
  (if gds-prt.node-name <> '_Пустая шкала':U and gds-prt.upper-code <> goods.prt-root then goods.gds-name + ' - ' + gds-prt.f-name else goods.gds-name) @ v-gds-name column-label 'Имя '  format "x(38)"
  buf_tt-flor.fact-qnty  column-label 'Количество'  format ">>>>>>>>9.999"
  goods.unit-base  column-label 'Изм'  format "x(3)"
  gds-dtl.price-base  column-label 'Цена (вал.)'
  gds-dtl.ov  column-label ''  format "+/-"
  (gds-dtl.price-base * buf_tt-flor.fact-qnty) column-label 'Сумма (вал.)' format "->>>>>>>>>>9.99"
  (gds-dtl.discnt-base * buf_tt-flor.fact-qnty) column-label 'Скидка (вал.)' format "->>>>>>>>>>9.99"
  ((gds-dtl.price-base - gds-dtl.discnt-base) * buf_tt-flor.fact-qnty) column-label 'Итого (вал.).' format "->>>>>>>>>>9.99"
  gds-dtl.discnt-pc column-label 'Скидка %' format "->>>9.99"
  gds-dtl.price-rubl column-label 'Цена (руб.)'
  (gds-dtl.price-rubl * buf_tt-flor.fact-qnty) column-label 'Сумма (руб.)' format "->>>>>>>>>>>>9.99"
  (gds-dtl.discnt-rubl * buf_tt-flor.fact-qnty) column-label 'Скидка (руб.)' format "->>>>>>>>>>>>9.99"
  ((gds-dtl.price-rubl - gds-dtl.discnt-rubl) * buf_tt-flor.fact-qnty) column-label 'Итого (руб.)' format "->>>>>>>>>>>>9.99"
  (if gds-prt.node-name = '_Пустая шкала':U then '-' else if gds-prt.upper-code = goods.prt-root then '-------------------' else gds-prt.f-name) column-label 'Признак' format "x(30)"
  gds-dtl.doc-qnty  column-label 'Всего По документу'  format ">>>>>>>>9.999"
  gds-dtl.fact-qnty                                           format ">>>>>>>>9.999"
  enable gds-dtl.doc-qnty  gds-dtl.fact-qnty
  with size 98 by 5 separators.
define variable agnt-name as character format "x(256)":u
      view-as text
     size 10.5 by 1 no-undo.
define variable wrkr-name as character format "x(256)":u
      view-as text
     size 10.5 by 1 no-undo.
define variable boss-name as character format "x(256)":u
      view-as text
     size 10.5 by 1 no-undo.
define variable flora-PS as character format "x(256)":u
      view-as editor SCROLLBAR-VERTICAL
     size 89 by 2 fgcolor 9 no-undo.
define button b-mark
     label "&*":l
     size 3 by 1.
define button b-prt
     label "&Шкала":l
     size 7 by 1.
define button b-parts
     label "Па&рт":l
     size 7 by 1.
define button b-lkp
     label "&Просм":l
     size 7 by 1.
define button b-chg
     label "&Изм":l
     size 1 by 1.
define button b-del
     label "&Удал":l
     size 1 by 1.
define button b-notes
     label "При&м":l
     TOOLTIP "Дополнительная информация по документу в целом"
     size 7 by 1.
define button b-notes-line
     label "О наборе":l
     TOOLTIP "Дополнительная информация по набору"
     size 9 by 1.
define button b-arch
     label "Уч&ет":l
     size 7 by 1.
define button b-cnt
     label "&ДогП":l
     size 7 by 1.
define button b-history
     label "&Истор"
     size 7 by 1.
define button b-cur
    label  "У&Цена"
    size 7 by 1.
define button b-help
     label "Помо&щь":l
     size 7 by 1.
define button b-dopinf
     label "Параметры заказа":l
     TOOLTIP "Дополнительная информация для заказа на исполнение"
     size 17 by 1.
define button b-nabor
    label "Состав набора":l
    TOOLTIP "Корректировка товаров , входящий в набор"
    size 17 by 1.
define button b-dopl
     label "Оплата":l
     TOOLTIP "Окончательная оплата заказа на исполнение"
     size 7 by 1.
define button b-exit auto-go
     label "&Выход":l
     size 8 by 1.
define button b-next auto-go
     label "&>>":l
     size 4 by 1.
define button b-prev auto-go
     label "&<<":l
     size 4 by 1.
define button b-dov
    label "&Довер"
    size 7 by 1.
define button b-attr
    label "А&тр"
    size 7 by 1.
define button b-fixprice
    label "&ФиксЦ"
    size 7 by 1.
define button b-nabor2
    label "Наборы"
    TOOLTIP "В какие наборы входит товар"
    size 7 by 1.
define menu m-acc_price
    menu-item m-ap-1 label "без НДС"              accelerator "alt-1"
    menu-item m-ap-2 label "с НДС"                accelerator "alt-2"
    menu-item m-ap-3 label "без НДС (НДС 0 НП 0)" accelerator "alt-3"
.
define menu m-fixprice
    menu-item m-fp-1 label "Фиксировать цены"     accelerator "alt-1"
    menu-item m-fp-2 label "Расфиксировать цены"  accelerator "alt-2".
define variable fact-rubl as decimal format "->,>>>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 20 by 1 no-undo.
define variable fact-base as decimal format "->>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 17 by 1 no-undo.
define variable sum-base-n as decimal format "->,>>>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 20 by 1
     no-undo.
define variable sum-rubl-n as decimal format "->,>>>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 20 by 1
     no-undo.
define variable d-sum-rubl as decimal format "->,>>>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 20 by 1
     no-undo.
define variable d-sum-base as decimal format "->,>>>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 20 by 1
     no-undo.
define variable sum-base as decimal format "->>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 17 by 1 no-undo.
define variable sum-rubl as decimal format "->>,>>>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 20 by 1 no-undo.
define button r-acc
     image-up file "btn-down-arrow"
     image-down file "btn-down-arrow"
     image-insensitive file "btn-down-arrow"
     size 3 by .88.
define button b-add
    label ""
    size 1 by 1.
define button r-agnt    like r-acc.
define button r-boss    like r-acc.
define button r-clients like r-acc.
define button r-outs    like r-acc.
define button r-pay     like r-acc.
define button r-wrkr    like r-acc.
define button r-sht     like r-acc.
define variable loc-art  as char format "x(16)" view-as fill-in size 14 by 1 fgcolor 12 no-undo.
define variable loc-name as char view-as fill-in size 20 by 1 fgcolor 12 no-undo.
define variable loc-code as char view-as fill-in size 20 by 1 fgcolor 12 no-undo.
define variable a-n-c as char view-as radio-set horizontal  radio-buttons
"&А","art",
"&Н","name",
"&К","code"
size 10 by 1 no-undo.
define variable varpurch-chs as integer view-as radio-set vertical radio-buttons
"&Все", 0,
"&Выборочно", 1
size 12 by 1 bgcolor 8 no-undo.
define rectangle rect-tot edge-pixels 2 graphic-edge size 47 by 5.9  bgcolor 8 .
define rectangle rect-prc edge-pixels 2 graphic-edge size 17 by 5.9  bgcolor 8 .
define frame d-out-doc
     t-doc.cli-code    at row 2   col 8 colon-aligned label "Контр." view-as fill-in size 10 by 1 format ">>>>>>>>9"
     t-doc.cli-type    at row 2   col 19 colon-aligned no-label view-as fill-in size 7.13 by 1
     r-clients         at row 2   col 28 no-label
     ub.clients.obj-name  at row 2   col 29 colon-aligned no-label view-as fill-in size 35 by 1 fgcolor 4
     t-doc.hold-obj-code at row 2 col 79 colon-aligned no-label view-as fill-in size 10 by 1 format ">>>>>>>>9"
     t-doc.hold-obj-type at row 2 col 90 colon-aligned no-label
     t-doc.out-code    at row 3   col 14 colon-aligned label "Ист&-к" format "x(21)" view-as fill-in size 15 by 1
     t-doc.doc-qnty    at row 3   col 42 colon-aligned label "Кол-во" view-as fill-in size 17 by 1 fgcolor 4
     t-doc.fact-qnty   at row 3   col 59 colon-aligned label "Факт" view-as fill-in size 17 by 1 fgcolor 4
     t-doc.discnt-pc   at row 3   col 58 colon-aligned label "&Скидка" format "->>>9.99%" view-as fill-in size 10 by 1 fgcolor 4
     t-doc.discnt-type at row 3   col 68 colon-aligned no-label view-as combo-box INNER-LINES 6 LIST-ITEMS 'процент':U, 'карта':U, 'группа':U, 'сумма':U, 'строка':U, 'прайс-лист':U size 10.5 by 1
     t-doc.d-card      at row 3   col 75 colon-aligned label "Карта" format "x(19)"
     t-doc.print-rubl  at row 4   col 85 label "Рубли" view-as toggle-box size 8 by .77 fgcolor 4
     "Баз.в."                  view-as text size 6 by 0.7 at row 5.1 col 50 fgcolor 4   bgcolor 8
     "РУБ"    view-as text size 6 by 0.7 at row 5.1 col 69 fgcolor 4   bgcolor 8
     sum-base          at row 6 col 52 colon-aligned label "Сумма без наценки"  bgcolor 8
     sum-rubl          at row 6 col 64 colon-aligned no-label
     sum-base-n        at row 6.8 col 52 colon-aligned label "Сумма с наценкой"  bgcolor 8
     sum-rubl-n        at row 6.8 col 64 colon-aligned no-label
     t-doc.tot-calc    at row 7.6 col 52 colon-aligned label "Скидка клиента" view-as fill-in size 17 by 1 bgcolor 8
     t-doc.discnt-rubl at row 7.6 col 64 colon-aligned no-label view-as fill-in size 20       by 1
     fact-base         at row 8.4 col 52 colon-aligned label "С нац и скидкой" fgcolor 4       bgcolor 8
     fact-rubl         at row 8.4 col 64 colon-aligned no-label fgcolor 4
     d-sum-base        at row 9.7 col 52 colon-aligned label "Итого с доставкой" view-as fill-in size 17 by 1
     d-sum-rubl        at row 9.7 col 64 colon-aligned no-label
     "Тип приобретения" view-as text size 16 by 0.7 at row 4.7 col 82.5 fgcolor 4
     varpurch-chs at row 5.5 col 83 no-label
     is-repay at row 6.7 col 83 label "выкуп"          view-as toggle-box size 15 by .77 fgcolor 4  bgcolor 8
     is-cons at row 7.7 col 83 label "консигнация"     view-as toggle-box size 15 by .77 fgcolor 4  bgcolor 8
     is-storage at row 8.7 col 83 label "отв.хран."    view-as toggle-box size 15 by .77 fgcolor 4  bgcolor 8
     is-oldcons at row 9.7 col 83 label "ст. консигн." view-as toggle-box size 15 by .77 fgcolor 4  bgcolor 8
     rect-tot at row 5 col 34.5
     rect-prc at row 5 col 82
.
define frame d-out-doc
     t-doc.base-rate   at row 5 col 8 colon-aligned label "Кур&с" view-as fill-in size 10 by 1 fgcolor 4
     t-doc.base-scale  at row 5 col 23 colon-aligned label "М&-б" view-as fill-in size 3.5 by 1 fgcolor 4
     r-acc             at row 5 col 31 no-label
     t-doc.pay-code    at row 6 col 8 colon-aligned label "&Опл" view-as fill-in size 6.25 by 1
     ub.pay-type.obj-name at row 6 col 14 colon-aligned no-label view-as text size 14.5 by 1 fgcolor 4
     r-pay             at row 6 col 31 no-label
     t-doc.wrkr        format "999999999" at row 7 col 8  colon-aligned view-as fill-in size 10 by 1
     wrkr-name         at row 7 col 18 colon-aligned no-label  fgcolor 4
     r-wrkr            at row 7 col 31 no-label
     t-doc.agnt        format "999999999" at row 8 col 8 colon-aligned view-as fill-in size 10 by 1
     agnt-name         at row 8 col 18 colon-aligned no-label fgcolor 4
     r-agnt            at row 8 col 31 no-label
     t-doc.boss        format "999999999" at row 9 col 8 colon-aligned view-as fill-in size 10 by 1
     boss-name         at row 9 col 18 colon-aligned no-label fgcolor 4
     r-boss            at row 9 col 31 no-label
     a-n-c             at row 10 col 1 no-label
     t-doc.doc-date    at row 4 col 5  colon-aligned label "&Дата" view-as fill-in size 9 by 1 fgcolor 4
     t-doc.fact-date   at row 4 col 20 colon-aligned label "&Факт" view-as fill-in size 9 by 1 fgcolor 4
     t-doc.shift-date  at row 4 col 36 colon-aligned label "&Смена" view-as fill-in size 9 by 1 fgcolor 4
     t-doc.shift-name     at row 4 col 48.3 colon-aligned label "№" view-as fill-in size 3 by 1 fgcolor 4
     t-doc.shift-num   at row 4 col 54.6 colon-aligned label "П" view-as fill-in size 3 by 1 fgcolor 4
     r-sht             at row 4 col 57.6 colon-aligned
     b-exit         at row 1 col 1
     b-prev         at row 1 col 9
     b-next         at row 1 col 13
     b-dopinf       at row 1 col 17
     b-dov          at row 1 col 34
     b-notes        at row 1 col 41
     b-cnt          at row 1 col 48
     b-dopl          at row 1 col 55
     b-attr          at row 1 col 62
     b-history           at row 1 col 69
     b-help          at row 1 col 76
     loc-art       at row 10   col 30  colon-aligned label "Начало артикула"
     loc-name      at row 10   col 30  colon-aligned label  "Начало названия" format "x(40)"
     loc-code      at row 10   col 30  colon-aligned label  "Бар-код (весь)" format "x(13)"
     i-sum-base    at row 11.3  col 44  no-label
     i-sum-rubl    at row 11.3  col 61  no-label
     b-nabor       at row 11 col 1
     br-posy       at row 12 col 1
     flora-PS      at row 15 col 1   no-label
     b-mark     at row 17 col 1
     b-lkp      at row 17 col 4
     b-prt      at row 17 col 11
     b-parts    at row 17 col 18
     b-cur      at row 17 col 25
     b-arch     at row 17 col 32
     b-fixprice      at row 17 col 39
     b-nabor2        at row 17 col 46
     b-notes-line    at row 17 col 74
     br-dtl        at row 18  col 1
     b-add         at row 21  col 1   no-label
     b-chg         at row 21  col 1   no-label
     b-del         at row 21  col 1   no-label
     space(0) skip(0) with view-as dialog-box side-labels three-d scrollable keep-tab-order.
assign
       br-dtl:num-locked-columns in frame d-out-doc = 3
       frame d-out-doc:scrollable       = false
       b-cur:POPUP-MENU IN FRAME d-out-doc = MENU m-acc_price:HANDLE
       b-cur:MENU-MOUSE = 1
       b-fixprice:POPUP-MENU IN FRAME d-out-doc = MENU m-fixprice:HANDLE
       b-fixprice:MENU-MOUSE = 1
       .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-dtl as INT EXTENT 18 no-undo.
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
  RUN re-move-clmnbr-dtl ( 4, 18).
END.
ON ctrl-cursor-left OF BROWSE br-dtl do:
  RUN re-move-clmnbr-dtl (18, 4).
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
def var sort-labelbr-dtl   as character no-undo .
def var sort-clmnbr-dtl    as handle    no-undo .
def var cur-clmnbr-dtl     as handle    no-undo .
def var cur-clmn-locbr-dtl as integer   no-undo .
def var re-querybr-dtl     as logical   initial no no-undo .
on start-search, ctrl-o of br-dtl in frame d-out-doc do:
   run sort-brbr-dtl
     (input (if available gds-dtl
             then recid(gds-dtl)
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
        when '*'  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by get-mark  (BUFFER gds-dtl) .   . END.
        when 'Бар-код'  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by bar-code.b-code .   . END.
        when 'Артикул'  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by gds-dtl.artic .   . END.
        when 'Имя '  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by (if gds-prt.node-name <> '_Пустая шкала':U and gds-prt.upper-code <> goods.prt-root then goods.gds-name + ' - ' + gds-prt.f-name else goods.gds-name) .   . END.
        when 'Всего По документу'  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by gds-dtl.doc-qnty .   . END.
        when 'Количество'  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by buf_tt-flor.fact-qnty .   . END.
        when 'Изм'  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by goods.unit-base .   . END.
        when 'Цена (вал.)'  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by gds-dtl.price-base .   . END.
        when ''  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by gds-dtl.ov .   . END.
        when 'Сумма (вал.)'  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by (gds-dtl.price-base * buf_tt-flor.fact-qnty) .   . END.
        when 'Скидка (вал.)'  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by (gds-dtl.discnt-base * buf_tt-flor.fact-qnty) .   . END.
        when 'Итого (вал.).'  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by ((gds-dtl.price-base - gds-dtl.discnt-base) * buf_tt-flor.fact-qnty) .   . END.
        when 'Скидка %'  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by gds-dtl.discnt-pc .   . END.
        when 'Цена (руб.)'  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by gds-dtl.price-rubl .   . END.
        when 'Сумма (руб.)'  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by (gds-dtl.price-rubl * buf_tt-flor.fact-qnty) .   . END.
        when 'Скидка (руб.)'  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by (gds-dtl.discnt-rubl * buf_tt-flor.fact-qnty) .   . END.
        when 'Итого (руб.)'  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by ((gds-dtl.price-rubl - gds-dtl.discnt-rubl) * buf_tt-flor.fact-qnty) .   . END.
        when 'Признак'  then DO:   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock by (if gds-prt.node-name = '_Пустая шкала':U then '-' else if gds-prt.upper-code = goods.prt-root then '-------------------' else gds-prt.f-name) .   . END.
    otherwise do:
      open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock.
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
   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock.
end.
else do:
   assign re-querybr-dtl = yes.
   run sort-brbr-dtl
     (input (if available gds-dtl
             then recid(gds-dtl)
             else ?
            )
     ).
   assign re-querybr-dtl = no.
end.
end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame d-out-doc anywhere do:
  if not available ub.goods then
    return no-apply.
  gds-rec = recid (ub.goods).
  run ref/gds-form.w ( input parParentProc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-dtl in frame d-out-doc.
  return no-apply.
end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref29 as character no-undo .
define variable varpgscales-pref29 as character no-undo.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type30 as character no-undo.
varscales-pref29  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref29
  ,output varscales-pref-type30
  ) no-error .
if varscales-pref29 = ? then do:
  assign
  varscales-pref29 = '21,23,25':U.
end.
define variable varpgscales-pref-type30 as character no-undo.
varpgscales-pref29  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref29
  ,output varpgscales-pref-type30
  ) no-error .
if varpgscales-pref29 = ? then do:
  assign
  varpgscales-pref29 = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
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
    find first l-gds-dtl where
               l-gds-dtl.doc-code = t-doc.doc-code and l-gds-dtl.artic begins (loc-art + last-event:label)
               no-lock no-error.
    if available l-gds-dtl then do:
      loc-art = loc-art + last-event:label.
      disp loc-art with frame d-out-doc.
      line-rec = recid (l-gds-dtl).
      reposition br-dtl to recid line-rec no-error.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-backspace-br-dtl:
  if input frame d-out-doc a-n-c = "art" then do:
    if loc-art = "" then
      return error.
    loc-art = substr (loc-art, 1, length (loc-art) - 1).
    find first l-gds-dtl where
               l-gds-dtl.doc-code = t-doc.doc-code and l-gds-dtl.artic begins loc-art
               no-lock.
    disp loc-art with frame d-out-doc.
    line-rec = recid (l-gds-dtl).
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
,input  store-type
,input  store-code
,input  yes
,input  no
,input  varscales-pref29
,input  varpgscales-pref29
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
,input  store-type
,input  store-code
,input  yes
,input  no
,input  varscales-pref29
,input  varpgscales-pref29
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
        find first l-gds-dtl where l-gds-dtl.doc-code = t-doc.doc-code and
                  l-gds-dtl.artic = l-goods.artic AND
                  l-gds-dtl.prod-type = l-goods.prod-type AND
                  l-gds-dtl.prod-code = l-goods.prod-code no-lock no-error.
    if available l-gds-dtl then do:
      line-rec = recid (l-gds-dtl).
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
      find next l-gds-dtl where l-gds-dtl.doc-code = t-doc.doc-code and
                can-find (ub.goods where ub.goods.artic = l-gds-dtl.artic and
                ub.goods.prod-type = l-gds-dtl.prod-type and
                ub.goods.prod-code = l-gds-dtl.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    else
      find first l-gds-dtl where l-gds-dtl.doc-code = t-doc.doc-code and
                can-find (ub.goods where ub.goods.artic = l-gds-dtl.artic and
                ub.goods.prod-type = l-gds-dtl.prod-type and
                ub.goods.prod-code = l-gds-dtl.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if available l-gds-dtl then do:
      line-rec = recid (l-gds-dtl).
      reposition br-dtl to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  apply "entry" to loc-name in frame d-out-doc.
END PROCEDURE.
on value-changed of br-dtl in frame d-out-doc do:
if not available ub.gds-dtl or recid (ub.gds-dtl) <> line-rec then do:
    hide loc-art in frame d-out-doc.
    loc-art = "".
end.
end.
on end-error of gds-dtl.doc-qnty in browse br-dtl do:
   disp gds-dtl.doc-qnty with browse br-dtl.
   return no-apply.
end.
on end-error of gds-dtl.fact-qnty in browse br-dtl do:
   disp gds-dtl.fact-qnty with browse br-dtl.
   return no-apply.
end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      vss-include-info32 skip
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
define variable vss-include-info33 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame d-out-doc anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame d-out-doc. END.
  return no-apply.
end.
define variable vss-include-info34 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-out-doc anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-out-doc. END.
  return no-apply.
end.
define variable vss-include-info35 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame d-out-doc anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame d-out-doc. END.
  return no-apply.
end.
define variable vss-include-info36 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-ref-rec40   as recid no-undo .
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
    assign v-ref-rec40 = integer( ref-list ).
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
  define variable v-ref-rec41   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec41 = ( if available cli-buf then recid( cli-buf ) else ? ).
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
    assign v-ref-rec41 = integer( ref-list ).
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
  define variable v-ref-rec42   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-out-doc.
          assign frame d-out-doc t-doc.agnt.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-out-doc.
  end.
  if parman = "boss" and paraction = "ret-mouse" then do:
  define variable v-ref-rec43   as recid no-undo .
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
    assign v-ref-rec43 = integer( ref-list ).
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
  define variable v-ref-rec44   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec44 = ( if available cli-buf then recid( cli-buf ) else ? ).
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
    assign v-ref-rec44 = integer( ref-list ).
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
  define variable v-ref-rec45   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-out-doc.
          assign frame d-out-doc t-doc.boss.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-out-doc.
  end.
  if parman = "wrkr" and paraction = "ret-mouse" then do:
  define variable v-ref-rec46   as recid no-undo .
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
    assign v-ref-rec46 = integer( ref-list ).
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
  define variable v-ref-rec47   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-out-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec47 = ( if available cli-buf then recid( cli-buf ) else ? ).
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
    assign v-ref-rec47 = integer( ref-list ).
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
  define variable v-ref-rec48   as recid no-undo .
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
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
define buffer bf_shop for ub.shop.
do on error undo, return error return-value :
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info53 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info54 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info55 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info56 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output varbase-code
  )  .
do on error undo, return error :
case pardoc-mode :
  when 'ДОБАВЛЕНИЕ':U then do:
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info68 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
on row-leave of browse br-dtl do:
if available gds-dtl then do:
   find first goods where goods.artic     = gds-dtl.artic     and
                          goods.prod-type = gds-dtl.prod-type and
                          goods.prod-code = gds-dtl.prod-code no-lock.
   find first ub.units where ub.units.unit-name = goods.unit-base no-lock.
   if dec(gds-dtl.doc-qnty:screen-value in browse br-dtl) <> gds-dtl.doc-qnty and
      lookup('2ед':U, ub.units.type) > 0 then do:
      message "Товар с двумя единицами измерения резервируется через партии." view-as alert-box.
      return no-apply.
   end.
   if dec(gds-dtl.doc-qnty:screen-value in browse br-dtl) <> gds-dtl.doc-qnty then do:
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
   end.
   if dec(gds-dtl.fact-qnty:screen-value in browse br-dtl) <> gds-dtl.fact-qnty then do:
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
end.
end.
on choose of b-arch in frame d-out-doc
do:
define variable vss-include-info69 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    ,output g#log
    )  .
end.
if not g#log then return no-apply.
run str/docsuppn.w
  (input  parparentproc
  ,input  recid(t-doc)
  ).
end.
on choose of b-cnt in frame d-out-doc
do:
define variable vss-include-info70 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    ,output g#log
    )  .
end.
if not g#log then return no-apply.
run str/scntdoc.w (t-doc.doc-code, v-cntxt-db-num = ub.sysconf.firm-db-num).
end.
on leave of t-doc.fact-date in frame d-out-doc do:
  if input frame d-out-doc t-doc.fact-date <> t-doc.fact-date then do:
    run chk-upd-date no-error.
    if error-status:error then return no-apply.
    assign frame d-out-doc t-doc.fact-date.
  end.
end.
on return of t-doc.shift-date in frame d-out-doc do:
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
  run proc-sht in this-procedure .
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
      t-doc.shift-name   = ""
      t-doc.shift-num = 0.
    display t-doc.shift-name t-doc.shift-num with frame d-out-doc.
    apply "entry" to t-doc.shift-name in frame d-out-doc.
    return no-apply.
  end.
end.
on choose of b-dopinf in frame d-out-doc do:
  run init-attr-flora in this-procedure .
  if doc-mode <> 'ПРОСМОТР':U then do:
        run str/fl-atu.w (input 'ИЗМЕНЕНИЕ':U, input t-doc.doc-code) no-error.
  end.
  else do:
     run str/fl-atu.w (input 'ПРОСМОТР':U, input t-doc.doc-code) no-error.
  end.
end.
on choose of b-nabor in frame d-out-doc do:
define variable v-make as logical   no-undo .
if not available t-doc then return .
if not available tt-posy then return .
define variable v1 as decimal   no-undo .
define variable v2 as decimal   no-undo .
define variable l-g#stat  like g#stat    no-undo .
define variable dost-rubl as   decimal   no-undo .
define variable dost-base as   decimal   no-undo .
define variable p-type    as   character no-undo .
define variable v-dost    as   character no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input '5deliv':U ,
                       output v-dost ,
                       output p-type )  .
     dost-rubl = decimal(v-dost).
     if dost-rubl = ? then dost-rubl = 0.
     dost-base = dost-rubl  * t-doc.base-scale / t-doc.base-rate.
assign
l-g#stat     = g#stat
g#stat       = t-doc.status_ .
if doc-mode <> 'ПРОСМОТР':U then do:
   run str/fl-nabor.w (
        input parParentProc,
        input doc-mode         ,
        input t-doc.doc-code   ,
        input tt-posy.gds-code ,
        output v-make,
        output tt-posy.sum-rubl ,
        output tt-posy.sum-base
        ) .
     g#stat = l-g#stat .
      assign
        ii-sum-base = 0
        ii-sum-rubl = 0
      .
      for each tt-posy :
          assign
            ii-sum-base = tt-posy.sum-base + ii-sum-base
            ii-sum-rubl = tt-posy.sum-rubl + ii-sum-rubl
          .
      end.
      if t-doc.status_ = 'факт':U then do:
          display string(ii-sum-rubl , ">>>,>>>,>>9.99")  @ i-sum-rubl
                  string(ii-sum-base , ">>>,>>>,>>9.99")  @ i-sum-base
                 with frame d-out-doc .
      end.
      else DO:
         display string(ii-sum-rubl , ">>>,>>>,>>9.99")  @ i-sum-rubl
              string(ii-sum-base , ">>>,>>>,>>9.99")  @ i-sum-base
              with frame d-out-doc .
       end.
  if v-make then do:
      run cr-tt-flor in this-procedure .
      run re-disp in this-procedure  .
      run gbl/calc-trn.p (input parParentProc, input recid(t-doc)) no-error.
      br-dtl:refresh() in frame d-out-doc no-error .
      br-posy:refresh() in frame d-out-doc no-error .
      run ui-on ("line").
      apply "entry" to br-posy in frame d-out-doc .
      reposition br-dtl to recid prt-rec no-error.
  end.
 end.
else
   run str/fl-nabor.w (
        input parParentProc,
        input doc-mode         ,
        input t-doc.doc-code   ,
        input tt-posy.gds-code ,
        output v-make,
        output v1 ,
        output v2  ) .
        run re-disp in this-procedure  .
define buffer bb_gds-dtl for ub.gds-dtl.
end.
on choose of b-nabor2 in frame d-out-doc do:
define variable v-make as logical   no-undo .
if not available t-doc then return .
if not available goods then return .
   run str/fl-nabo2.w (
        input parParentProc,
        input doc-mode  ,
        input t-doc.doc-code ,
        input goods.gds-code ,
        input gds-dtl.prt-code ,
        output v-make)
   .
  if v-make then do:
      run cr-tt-flor in this-procedure .
      run re-disp in this-procedure  .
      run gbl/calc-trn.p (input parParentProc, input recid(t-doc)) no-error.
      br-dtl:refresh() in frame d-out-doc no-error .
      run ui-on ("line").
  end.
end.
on choose of b-dopl in frame d-out-doc do:
  define variable p-return-attribute as character no-undo .
  define variable p-db-num as integer   no-undo .
  define buffer nn_trn-doc for ub.trn-doc.
  case t-doc.status_
  :
  when 'факт':U
  then do:
     run str/fl-dopl.w (parParentProc , input 'ПРОСМОТР':U, input t-doc.doc-code) no-error.
  end.
  when 'готов':U
  then do:
     find first nn_trn-doc no-lock where nn_trn-doc.out-code = t-doc.doc-code no-error .
     if available nn_trn-doc then do:
        run str/fl-dopl.w (parParentProc , input 'ПРОСМОТР':U, input nn_trn-doc.doc-code) no-error.
     end.
   end.
  otherwise do:
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,input  'active=request'
  ,output p-return-attribute
  )  .
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output p-db-num
  )  .
      if p-return-attribute = "no" or  p-db-num <> v-cntxt-db-num then
           run str/fl-dopl.w (parParentProc , input 'ПРОСМОТР':U, input t-doc.doc-code) no-error.
      else run str/fl-dopl.w (parParentProc , input doc-mode , input t-doc.doc-code) no-error.
      if doc-mode <> 'ПРОСМОТР':U then do:
         run re-disp in this-procedure  .
      end.
  end.
  end case.
end.
on choose of menu-item m-fp-1 in menu m-fixprice
do:
 if available gds-dtl then do:
   assign prt-rec = recid(gds-dtl).
 end.
 else do:
   assign prt-rec = ?.
 end.
 define buffer bf_gds-dtl for ub.gds-dtl.
 assign g#log = no.
 message "Если Вы зафиксируете цены, то при изменении цены в прайс-листе до закрытия документа она не проставится в документ." skip
         "Вы уверены?" view-as alert-box buttons yes-no update g#log.
 if g#log = yes then do:
   for each bf_gds-dtl where bf_gds-dtl.doc-code = t-doc.doc-code on error undo, return no-apply :
     assign
       bf_gds-dtl.ov = yes.
   end.
 end.
 run ui-on ("line").
 if prt-rec <> ? then do:
   reposition br-dtl to recid prt-rec no-error.
 end.
end.
on choose of menu-item m-fp-2 in menu m-fixprice
do:
 if available gds-dtl then do:
   assign prt-rec = recid(gds-dtl).
 end.
 else do:
   assign prt-rec = ?.
 end.
 define buffer bf_gds-dtl for ub.gds-dtl.
 assign g#log = no.
 message "Если Вы расфиксируете цены, то при изменении цены в прайс-листе до закрытия документа она проставится в документ." skip
         "Вы уверены?" view-as alert-box buttons yes-no update g#log.
 if g#log = yes then do:
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
on choose of b-mark in frame d-out-doc do:
 run mark-list in this-procedure .
end.
on choose of b-del in frame d-out-doc  do:
run local-del in this-procedure  no-error.
if error-status:error then return no-apply.
run ui-on ("enable":u).
apply "entry" to br-dtl in frame d-out-doc .
prt-rec = rep-rec.
if prt-rec <> ? then reposition br-dtl to recid prt-rec no-error.
end.
on choose of b-lkp in frame d-out-doc
do:
if not available gds-dtl then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.
run local-lookup in this-procedure .
end.
on choose of b-prt in frame d-out-doc
do:
if not available gds-dtl then do:
  message "Неправильный выбор строки - шкала недоступна.".
  return no-apply.
end.
if doc-mode <> 'ПРОСМОТР':U then do:
  run check-rate in this-procedure  no-error.
  if error-status:error then return no-apply.
end.
run set-work-mode-prt in this-procedure  no-error.
if error-status:error then return no-apply.
if pardoc-mode = 'ПРОСМОТР':U then do:
  find first ub.doc-line where ub.doc-line.doc-code  = gds-dtl.doc-code  and
                            ub.doc-line.artic     = gds-dtl.artic     and
                            ub.doc-line.prod-type = gds-dtl.prod-type and
                            ub.doc-line.prod-code = gds-dtl.prod-code no-lock.
end.
else do:
  find first ub.doc-line where ub.doc-line.doc-code  = gds-dtl.doc-code  and
                            ub.doc-line.artic     = gds-dtl.artic     and
                            ub.doc-line.prod-type = gds-dtl.prod-type and
                            ub.doc-line.prod-code = gds-dtl.prod-code .
end.
find first goods where goods.artic     = gds-dtl.artic     and
                       goods.prod-type = gds-dtl.prod-type and
                       goods.prod-code = gds-dtl.prod-code no-lock.
run str/out-add.p
  (input parparentproc,
    input recid(t-doc),
    input recid(doc-line),
    input recid(gds-dtl),
    input recid(goods),
    input work-mode,
    input ?
    ) no-error.
if error-status:error then return no-apply.
if prt-mode = 'ШКАЛА':U then
   run ui-on ("line").
apply "entry" to br-dtl in frame d-out-doc .
reposition br-dtl to recid prt-rec no-error.
end.
ON CHOOSE OF b-exit IN FRAME d-out-doc
DO:
  next-prev = ?.
  apply "WINDOW-CLOSE" TO SELF.
  Return .
END.
on choose of b-parts in frame d-out-doc
do:
define variable varloc-prt-rec as recid no-undo.
if not available gds-dtl then do:
  message "Неправильный выбор строки - партии недоступны.".
  return no-apply.
end.
assign
  varloc-prt-rec = recid(gds-dtl).
run local-parts in this-procedure  no-error.
if error-status:error then return no-apply.
run ui-on ("line").
apply "entry" to br-dtl in frame d-out-doc .
reposition br-dtl to recid varloc-prt-rec no-error.
end.
on choose of menu-item m-ap-1 in menu m-acc_price
do:
run local-cur in this-procedure (input 1) no-error.
if error-status:error then return no-apply.
run UI-on ("enable").
end.
on choose of menu-item m-ap-2 in menu m-acc_price
do:
run local-cur in this-procedure (input 2) no-error.
if error-status:error then return no-apply.
run UI-on ("enable").
end.
on choose of menu-item m-ap-3 in menu m-acc_price
do:
run local-cur in this-procedure (input 3) no-error.
if error-status:error then return no-apply.
run UI-on ("enable").
end.
on value-changed of br-posy in frame d-out-doc
do:
   open query br-dtl   for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code ,       each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and                              gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock,           each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock,           each goods where goods.artic = gds-dtl.artic                        and goods.prod-code = gds-dtl.prod-code                        and goods.prod-type = gds-dtl.prod-type                        and goods.gds-code  = buf_tt-flor.gds-code no-lock,           each bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock.
if available tt-posy then flora-ps = tt-posy.gds-dopinf .
                     else flora-ps = "".
  display flora-ps with frame d-out-doc .
end.
on value-changed of t-doc.discnt-type in frame d-out-doc
do:
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
disp t-doc.discnt-type with frame d-out-doc.
run ui-on ("enable").
end.
on leave of t-doc.discnt-pc in frame d-out-doc do:
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
  run gbl/calc-trn.p (input parParentProc, input recid(t-doc)) no-error.
  if error-status:error then do:
    undo, return no-apply.
  end.
  run ui-on ("line").
end.
end.
end.
on return, leave of t-doc.tot-calc in frame d-out-doc do:
if input frame d-out-doc t-doc.tot-calc <> t-doc.tot-calc then do:
  assign t-doc.tot-calc = input frame d-out-doc t-doc.tot-calc.
  run gbl/calc-trn.p (input parParentProc, input recid(t-doc)) no-error.
  if error-status:error then undo, return no-apply.
  run ui-on ("line").
end.
end.
on return, leave of t-doc.discnt-rubl in frame d-out-doc do:
  if input frame d-out-doc t-doc.discnt-rubl <> t-doc.discnt-rubl then do:
    assign
      frame d-out-doc t-doc.discnt-rubl.
    run gbl/calc-trn.p (input parParentProc, input recid(t-doc)) no-error.
    if error-status:error then do:
      undo, return no-apply.
    end.
    run ui-on ("line").
  end.
end.
define temp-table t-d-b-doc-line no-undo like lib-trn_ret-line.
define temp-table t-d-b-gds-dtl  no-undo like ub.gds-dtl.
define temp-table t-d-b-parts    no-undo like ub.parts.
on mouse-select-dblclick, return of t-doc.out-code in frame d-out-doc
do:
define buffer tdb_doc-line for ub.doc-line.
define buffer tdb_gds-dtl  for ub.gds-dtl.
find t-d-b where t-d-b.doc-code = input frame d-out-doc t-doc.out-code no-lock no-error.
if not available t-d-b then do:
  return no-apply.
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
for each tdb_doc-line where tdb_doc-line.doc-code = t-d-b.doc-code on error undo, return no-apply :
  create t-d-b-doc-line.
  buffer-copy tdb_doc-line to t-d-b-doc-line.
end.
for each tdb_gds-dtl where tdb_gds-dtl.doc-code = t-d-b.doc-code on error undo, return no-apply :
  create t-d-b-gds-dtl.
  buffer-copy tdb_gds-dtl to t-d-b-gds-dtl.
end.
do transaction on error undo, return no-apply :
  define variable v-num as integer initial 1 no-undo.
  run gbl/d-askw.w
    (input "Вопрос"
    ,input "По каким количествам будем производить копирование?"
           + chr(10) + (if t-d-b.status_ <> 'запрос':U then "Внимание ! Если добавляемое количество какого-либо товара недоступно, оно будет уменьшено." else "":U)
    ,input "|^"
    ,input "Фактическим|"
         + "Документарным|"
         + "Отмена"
    ,input "Исходя из фактических количеств в признаках.|"
         + "Исходя из документарных количеств в признаках.|"
         + "Отменить копирование."
    ,input 1
    ,input 3
    ,output v-num
    ).
    if v-num = 3 then do:
      return no-apply.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_copy-ret in g#lib-trn
  (
    input parParentProc
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
  , input v-cntxp-cash-pay
  , input base-code
  , input-output table t-d-b-doc-line
  , input-output table t-d-b-gds-dtl
  , input-output table t-d-b-parts
  , input no
  , input no
  , input no
  , input (if v-num = 1 then yes else no)
  ) no-error.
   if error-status:error then do:
     message "Ошибка при копировании документа." skip
             return-value skip
             error-status:get-message(1) skip
             error-status:get-message(2) skip
             error-status:get-message(3) skip
     view-as alert-box error.
     return no-apply.
   end.
   doc-mode = 'ИЗМЕНЕНИЕ':U.
   run gbl/calc-trn.p (input parParentProc, input recid(t-doc)) no-error.
   if error-status:error then do:
     undo, return no-apply.
   end.
end.
run ui-on ("line").
apply "entry" to br-dtl in frame d-out-doc.
return no-apply.
end.
on choose of b-attr do:
  run init-attr-general .
  if doc-mode <> 'ПРОСМОТР':U then do:
     run str/doc-attr.w (input ParParentProc , input "b-lkp,b-chg,b-add,b-del", input t-doc.doc-code, input table tt-upd-attr) no-error.
  end.
  else do:
     run str/doc-attr.w (input ParParentProc , input "b-lkp", input t-doc.doc-code, input table tt-upd-attr) no-error.
  end.
end.
on choose of b-dov do:
define variable vardov as character no-undo.
find first ub.doc-attr  where ub.doc-attr.doc-code  = t-doc.doc-code and
                          ub.doc-attr.attr-code = 'dov':U         no-lock no-error.
if available ub.doc-attr then do:
  assign vardov = ub.doc-attr.attr-value.
end.
run gbl/d-prompt.w (
        'title=':u + "Изменение атрибутов документа" + '\':u
      + 'text1=':u + "Доверенность" + '\':u
      + 'format=' + "x(300)" + '\':u
      + 'type=' + "edit" + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=60\':u
      + 'fillin_height=3\':u
      + 'max-chars=70\':u
      + 'readonly=' + (if doc-mode = 'ИЗМЕНЕНИЕ':U then 'no':u else 'yes':u) + '\':u
      , input-output vardov
      ) no-error.
if doc-mode = 'ИЗМЕНЕНИЕ':U and caps(return-value) = "TRUE"  then do:
  if not error-status:error then do:
    find first ub.doc-attr where ub.doc-attr.doc-code  = t-doc.doc-code and
                              ub.doc-attr.attr-code = 'dov':U          no-error.
    if not available ub.doc-attr then do:
      create ub.doc-attr.
      assign
      ub.doc-attr.doc-code  = t-doc.doc-code
      ub.doc-attr.attr-code = 'dov':U.
    end.
    assign
    ub.doc-attr.attr-value = vardov.
  end.
end.
run ui-on ("line").
end.
on choose of b-notes-line do:
define variable v-ps as character no-undo.
if not available t-doc then return .
if not available goods then return .
    run lineattr-value (
      input   t-doc.doc-code ,
      input   goods.gds-code ,
      input   'flora_ps':U,
      output  v-ps ,
      output  p-type      )
    .
run gbl/d-prompt.w (
        'title=':u + "Изменение атрибутов строки документа" + '\':u
      + 'text1=':u + "Примечание по позиции: " + goods.gds-name + '\':u
      + 'format=' + "x(1000)" + '\':u
      + 'type=' + "edit" + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=60\':u
      + 'fillin_height=5\':u
      + 'max-chars=1000\':u
      + 'readonly=' + (if doc-mode = 'ИЗМЕНЕНИЕ':U then 'no':u else 'yes':u) + '\':u
      , input-output v-ps
      ) no-error.
  if caps(return-value) = "TRUE"  then do:
  if doc-mode = 'ИЗМЕНЕНИЕ':U then do:
    if not error-status:error then do:
      run lineattr-write (
        input   t-doc.doc-code ,
        input   goods.gds-code ,
        input   'flora_ps':U,
        input   v-ps )
      .
    end.
  end.
end.
apply "value-changed" to br-dtl in frame d-out-doc.
end.
on return of t-doc.fact-date in frame d-out-doc do:
  if t-doc.fact-date:sensitive in frame d-out-doc then do:
    apply "entry" to t-doc.shift-date in frame d-out-doc.
  end.
  return no-apply.
end.
on value-changed of varpurch-chs in frame d-out-doc do:
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
end.
on value-changed of is-repay in frame d-out-doc do:
  run val-chg-is-repay.
end.
on value-changed of is-cons in frame d-out-doc do:
  run val-chg-is-cons.
end.
on value-changed of is-storage in frame d-out-doc do:
  run val-chg-is-storage.
end.
on value-changed of is-oldcons in frame d-out-doc do:
  run val-chg-is-oldcons.
end.
if valid-handle(active-window) and frame d-out-doc:parent eq ?
then frame d-out-doc:parent = active-window.
on window-close of frame d-out-doc apply "end-error":u to self.
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of t-doc.doc-date,t-doc.fact-date,t-doc.shift-date in frame d-out-doc
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
on delete-character of t-doc.doc-date,t-doc.fact-date,t-doc.shift-date in frame d-out-doc
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
on ctrl-d of t-doc.doc-date,t-doc.fact-date,t-doc.shift-date in frame d-out-doc
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
on ctrl-b of t-doc.doc-date,t-doc.fact-date,t-doc.shift-date in frame d-out-doc
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
on ctrl-e of t-doc.doc-date,t-doc.fact-date,t-doc.shift-date in frame d-out-doc
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
on ctrl-f of t-doc.doc-date,t-doc.fact-date,t-doc.shift-date in frame d-out-doc
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
next-prev = yes.
n-p: do while next-prev :
main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block
   on stop undo main-block, leave main-block:
find ub.sysconf where ub.sysconf.host-code = v-cntxt-host-code-obj no-lock.
v-cntxp-cash-pay = ub.sysconf.cash-pay.
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
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
hide b-add b-chg b-del t-doc.out-code in frame d-out-doc .
if doc-mode <> 'ПРОСМОТР':U then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_delnabor in g#lib-trn3
( input parParentProc ,
  input t-doc.doc-code
) no-error
.
    if error-status:error then return error.
    run gbl/calc-trn.p (input parParentProc, input recid(t-doc)) no-error. if error-status:error then return error.
end.
run cr-tt-posy no-error . if error-status:error then return error.
run cr-tt-flor no-error . if error-status :error then return error.
run mode-on no-error. if error-status:error then return error.
run re-disp .
run ui-on ("enable").
if prt-rec <> ? and doc-mode = 'ПРОСМОТР':U then reposition br-dtl to recid prt-rec no-error.
if doc-mode = 'ДОБАВЛЕНИЕ':U then wait-for go of frame d-out-doc focus t-doc.cli-code.
else wait-for go of frame d-out-doc focus br-dtl.
end.
end.
run disable_ui.
procedure disable_ui :
  hide frame d-out-doc.
end procedure.
procedure ui-on :
define input param fnc as char no-undo.
define variable varexist                  as logical   no-undo.
define variable varpurch-limit            as character no-undo.
define variable varpurch-limit-type       as character no-undo.
define variable varpurch-code-string      as character no-undo.
define variable varpurch-code-string-type as character no-undo.
define buffer bf_doc-line for ub.doc-line.
del-list = "" .
loc-art = ""  .
if fnc = "enable" then do:
  disable all with frame d-out-doc.
  hide loc-art in frame d-out-doc loc-name loc-code in frame d-out-doc.
  enable b-exit b-lkp b-help br-dtl br-posy b-arch b-history a-n-c b-notes b-cnt b-attr with frame d-out-doc.
   define variable v-flor as logical   no-undo .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_flornakl in g#lib-trn3
( input t-doc.doc-code ,
  output v-flor
)
.
   if v-flor = false   then do:
    message "Ошибка !!! Не верный документ " .
   end.
enable  b-dopl b-dopinf b-nabor2 b-nabor flora-PS with frame d-out-doc.
flora-PS:READ-ONLY = true .
hide  b-notes-line in frame d-out-doc .
  enable b-parts with frame d-out-doc.
  if prtvalue = "yes" and  v-cntxp-doc-prt then enable b-prt with frame d-out-doc.
  if t-doc.ext-doc-type = 'ep':U then enable b-parts with frame d-out-doc.
  if doc-mode = 'ДОБАВЛЕНИЕ':U then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-xst in g#trdcalib (  input t-doc.doc-code ,
                        input 'purchlimit':U ,
                       output varexist )  .
    if varexist = no then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'purchlimit':U ,
                       input 'no':U )  .
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
           assign gds-dtl.doc-qnty:read-only  in browse br-dtl = yes.
           assign gds-dtl.fact-qnty:read-only  in browse br-dtl = yes.
       end.
       when 'разрешен':U then assign
            gds-dtl.doc-qnty:read-only  in browse br-dtl = yes
            gds-dtl.fact-qnty:read-only in browse br-dtl = yes
       .
       otherwise   assign gds-dtl.doc-qnty:read-only  in browse br-dtl = yes
                          gds-dtl.fact-qnty:read-only in browse br-dtl = yes.
  end case.
  case doc-mode :
    when 'ПРОСМОТР':U then do:
         assign gds-dtl.doc-qnty:read-only  in browse br-dtl = yes
                gds-dtl.fact-qnty:read-only in browse br-dtl = yes.
         enable b-prev b-next with frame d-out-doc.
    end.
    when 'ДОБАВЛЕНИЕ':U then enable t-doc.cli-code t-doc.cli-type r-clients with frame d-out-doc.
    when 'ИЗМЕНЕНИЕ':U then do:
      g#log = no.
define variable vss-include-info79 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    ,output g#log
    )  .
end.
      if t-doc.ext-doc-type <> 'ep':U      and
         t-doc.status_  = 'накл':U                         and
         not t-doc.flag_                                  and
         g#log = yes
         then enable b-cur with frame d-out-doc.
      enable t-doc.wrkr
             t-doc.agnt t-doc.boss r-wrkr r-agnt r-boss
             t-doc.pay-code r-pay  t-doc.doc-date with frame d-out-doc.
      g#log = no.
define variable vss-include-info80 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    ,output g#log
    )  .
end.
      if g#log then do:
          enable t-doc.fact-date with frame d-out-doc.
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,input  'shift-on=request'
  ,output g#log
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
         if g#log then do:
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
        if not t-doc.internal or t-doc.doc-type = 'рас':U or t-doc.status_ = 'запрос':U then
          enable  b-mark b-fixprice with frame d-out-doc.
        if not t-doc.internal then do:
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
        enable t-doc.cli-code r-clients with frame d-out-doc.
            if v-cntxp-out-rate then
              enable t-doc.base-rate t-doc.base-scale r-acc with frame d-out-doc.
      end.
    end.
  end.
end.
  if t-doc.discnt-type <> 'касс':U then disp t-doc.discnt-type with frame d-out-doc.
  disp t-doc.discnt-pc t-doc.d-card t-doc.discnt-rubl t-doc.tot-calc with frame d-out-doc.
enable b-dov with frame d-out-doc.
disp t-doc.cli-code t-doc.cli-type t-doc.doc-date t-doc.fact-date t-doc.shift-date t-doc.shift-num t-doc.shift-name t-doc.doc-qnty
     t-doc.base-rate t-doc.base-scale t-doc.pay-code varpurch-chs is-repay is-cons is-storage is-oldcons with frame d-out-doc.
display t-doc.print-rubl with frame d-out-doc.
find ub.clients where ub.clients.obj-type = t-doc.cli-type and ub.clients.obj-code = t-doc.cli-code no-lock no-error.
if available ub.clients then
  disp ub.clients.obj-name with frame d-out-doc.
frame d-out-doc:title = t-doc.obj-type + " " + string (t-doc.obj-code, ">>>>9") + "  : ЗАКАЗ на ИСПОЛНЕНИЕ ".
if t-doc.office then frame d-out-doc:title = frame d-out-doc:title + "УСЛУГ ".
frame d-out-doc:title = frame d-out-doc:title
  + if t-doc.internal then "внутр - " else "внеш - ".
frame d-out-doc:title = frame d-out-doc:title
  + t-doc.status_ + " " + string (t-doc.flag_, "+/-") + " № " + t-doc.doc-code + "   - " + title-mode(doc-mode).
display t-doc.wrkr t-doc.agnt t-doc.boss with frame d-out-doc.
  define variable v-ref-rec82   as recid no-undo .
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
  define variable v-ref-rec83   as recid no-undo .
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
  define variable v-ref-rec84   as recid no-undo .
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
if available ub.pay-type then disp ub.pay-type.obj-name with frame d-out-doc.
else disp ? @ ub.pay-type.obj-name with frame d-out-doc.
release ub.pay-type no-error.
run re-disp .
open query br-posy  for each tt-posy.
apply "value-changed" to br-posy in frame d-out-doc.
apply "value-changed" to br-dtl in frame d-out-doc.
end procedure.
procedure ch-discnt:
define variable hist-list as character no-undo.
define buffer buf_c-dis-card for ub.c-dis-card.
define buffer buf_c-dc-hist for ub.c-dc-hist.
if input frame d-out-doc t-doc.discnt-type = 'карта':U then do:
  run ref/discards.w ( input parParentProc
                      ,input "b-sel"
                      ,input "client":U
                      ,input t-doc.host-code
                      ,input t-doc.obj-type
                      ,input t-doc.obj-code
                      ,input '':U
                      ,input recid (ub.clients)
                      ,output ref-list).
  if ref-list = "" then do:
    disp t-doc.discnt-type with frame d-out-doc.
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
  assign g#log = yes.
  message "Текущий процент по дисконтной карте " ub.dis-card.d-card " равен " ub.dis-card.d-pcnt " ." skip
          "Будем оформлять накладную, исходя из данного процента?" view-as alert-box question buttons yes-no update g#log.
  if g#log then do:
    assign
      t-doc.discnt-pc = ub.dis-card.d-pcnt
      t-doc.d-card    = ub.dis-card.d-card.
  end.
  else do:
    run ref/cdchist.w
               (     input parparentproc
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
    if error-status:error or
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
run gbl/calc-trn.p (input parParentProc, input recid(t-doc)) no-error.
if error-status:error then return "error".
end procedure.
procedure mark-list:
  if not available gds-dtl then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid86 as character no-undo .
define variable v-num-entry86 as integer   no-undo .
assign
  v-str-recid86 = trim( string( recid( gds-dtl ) , "->>>>>>>>>>>9":U ) )
  v-num-entry86 = lookup( v-str-recid86 , del-list )
.
if v-num-entry86 > 0 then do:
  assign
    entry( v-num-entry86, del-list ) = "":U
    del-list = trim( replace( del-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    del-list = del-list + ( if del-list = "":U then "":U else chr(44) ) + v-str-recid86
  .
end.
  br-dtl:refresh() in frame d-out-doc no-error .
  g#log = br-dtl:select-next-row () in frame d-out-doc.
  apply "entry" to br-dtl in frame d-out-doc.
end procedure.
procedure local-del:
do on stop undo, return error:
  if del-list = "" then do:
    if not available gds-dtl then do:
      message "Неправильный выбор строки.".
      return error.
    end.
    g#log = no.
    message "Удалить строку накладной ?   Вы уверены ?"
                    view-as alert-box question buttons ok-cancel update g#log.
    if not g#log then return error.
    assign
      prt-rec = recid (gds-dtl)
      del-list = string (recid (gds-dtl)).
    get next br-dtl.
    if available gds-dtl then rep-rec = recid (gds-dtl).
    else do:
      reposition br-dtl to recid prt-rec no-error.
      get prev br-dtl.
      rep-rec = recid (gds-dtl).
    end.
  end.
  else do:
    g#log = no.
    message "УДАЛИТЬ  ВСЕ  ОТМЕЧЕННЫЕ  строки накладной ?   Вы уверены ?"
                    view-as alert-box question buttons ok-cancel update g#log.
    if not g#log then return error.
    rep-rec = ?.
  end.
  lns-cnt = 1.
  do while lns-cnt <= num-entries (del-list):
    assign
      prt-rec = integer (entry (lns-cnt, del-list))
      lns-cnt = lns-cnt + 1.
    find gds-dtl where recid (gds-dtl) = prt-rec exclusive.
    find ub.doc-line where ub.doc-line.doc-code = gds-dtl.doc-code
                          and ub.doc-line.prod-code = gds-dtl.prod-code
                          and ub.doc-line.prod-type = gds-dtl.prod-type
                          and ub.doc-line.artic     = gds-dtl.artic exclusive.
    define variable l-inv-on as logical no-undo .
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    find goods where goods.prod-code = gds-dtl.prod-code
                 and goods.prod-type = gds-dtl.prod-type
                 and goods.artic     = gds-dtl.artic no-lock.
    run str/out-add.p
      (input parparentproc,
        input recid(t-doc),
        input recid(doc-line),
        input recid(gds-dtl),
        input recid(goods),
        input "delete",
        input ?
        ) no-error.
    if error-status:error then return error.
  end.
end.
end procedure.
procedure local-lookup:
assign
line-mode = 'ПРОСМОТР':U
prt-mode  = 'ПРОСМОТР':U.
find ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code
                        and ub.doc-line.prod-code = gds-dtl.prod-code
                        and ub.doc-line.prod-type = gds-dtl.prod-type
                        and ub.doc-line.artic         = gds-dtl.artic no-lock.
find goods where goods.prod-code = gds-dtl.prod-code
                     and goods.prod-type = gds-dtl.prod-type
                     and goods.artic         = gds-dtl.artic no-lock.
run str/out-add.p (
    input parparentproc,
    input recid(t-doc),
    input recid(doc-line),
    input recid(gds-dtl),
    input recid(goods),
    input varline-mode,
    input ?
    )no-error.
    if error-status :error then return error return-value .
apply "entry" to br-dtl in frame d-out-doc.
end procedure.
procedure set-work-mode-prt:
prt-rec = recid(gds-dtl).
find ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code
                and ub.doc-line.prod-code = gds-dtl.prod-code
                and ub.doc-line.prod-type = gds-dtl.prod-type
                and ub.doc-line.artic     = gds-dtl.artic no-lock.
line-rec = recid (doc-line).
find goods where goods.prod-code = gds-dtl.prod-code
             and goods.prod-type = gds-dtl.prod-type
             and goods.artic     = gds-dtl.artic no-lock.
gds-rec = recid (goods).
find gds-prt where gds-prt.upper-code = goods.prt-root no-lock.
if gds-prt.node-name = '_Пустая шкала':U then do:
  message "Товар :" goods.artic goods.gds-name "не делится на признаки - шкала недoступна.".
  return error.
end.
if doc-mode = 'ПРОСМОТР':U then
  assign
    prt-mode  = 'ПРОСМОТР':U
    line-mode = 'ПРОСМОТР':U
    work-mode = "lookup-scale".
else do:
  define variable l-inv-on as logical no-undo .
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    message "Артикул :" ub.doc-line.artic goods.gds-name
                    "- товар в инвентаризации."
                    skip (2) "Операция невозможна.".
    return error.
  end.
  assign
    prt-mode  = 'ШКАЛА':U
    line-mode = 'ИЗМЕНЕНИЕ':U
    work-mode = "update-scale".
end.
end procedure.
procedure local-check-gds:
  define variable l-inv-on as logical no-undo .
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    message "Артикул :" ub.doc-line.artic goods.gds-name
                    "- товар в инвентаризации."
                    skip (2) "Операция невозможна.".
    return error.
  end.
  if t-doc.status_ = 'запрос':U then do:
    message "Документ имеет статус ЗАПРОС. Изменение партий невозможно.".
    return error.
  end.
end procedure.
procedure find-gds:
find bar-code where bar-code.b-code = b-c no-lock.
find goods where goods.gds-code = bar-code.gds-code no-lock.
assign gds-rec = recid(goods).
find first gds-dtl where
     gds-dtl.doc-code  = t-doc.doc-code     and
     gds-dtl.artic     = goods.artic     and
     gds-dtl.prod-type = goods.prod-type and
     gds-dtl.prod-code = goods.prod-code and
     gds-dtl.prt-code  = bar-code.node-code no-lock no-error.
if not available gds-dtl then do:
   message "В накладной не найден товар по данному бар-коду."
    view-as alert-box error buttons ok.
    return error.
end.
end procedure.
procedure add-rate:
reposition br-dtl to recid recid(gds-dtl).
display gds-dtl.fact-qnty + rate @ gds-dtl.fact-qnty with browse br-dtl.
end procedure.
procedure check-inv:
find ub.doc-line where ub.doc-line.doc-code         = t-doc.doc-code
                       and ub.doc-line.prod-code = gds-dtl.prod-code
                       and ub.doc-line.prod-type = gds-dtl.prod-type
                       and ub.doc-line.artic     = gds-dtl.artic no-lock.
line-rec = recid (doc-line).
find goods where goods.prod-code = gds-dtl.prod-code
             and goods.prod-type = gds-dtl.prod-type
             and goods.artic     = gds-dtl.artic no-lock.
define variable l-inv-on as logical no-undo .
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  message "Артикул :" ub.doc-line.artic goods.gds-name
                  "- товар в инвентаризации."
                  skip (2) "Операция невозможна.".
  return error.
end.
end procedure.
procedure check-discnt:
g#log = no.
if input frame d-out-doc t-doc.discnt-type = 'строка':U then
  if not v-cntxp-out-line-discnt then message "Скидки по строкам запрещены.".
  else message "Включение разных скидок по строкам. Вы уверены ?"
                          view-as alert-box question buttons ok-cancel update g#log.
  else message "Включение общей скидки для всего документа."
                        "Все скидки по строкам будут пересчитаны. Вы уверены ?"
                        view-as alert-box question buttons ok-cancel update g#log.
if g#log <> true then do:
  disp t-doc.discnt-type with frame d-out-doc.
  return error.
end.
end procedure.
procedure local-parts:
do on error undo, return error return-value :
if doc-mode <> 'ПРОСМОТР':U then do:
  run check-rate.
end.
find ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code
                and ub.doc-line.prod-code = gds-dtl.prod-code
                and ub.doc-line.prod-type = gds-dtl.prod-type
                and ub.doc-line.artic     = gds-dtl.artic .
find goods where goods.prod-code = gds-dtl.prod-code
             and goods.prod-type = gds-dtl.prod-type
             and goods.artic     = gds-dtl.artic      no-lock.
if doc-mode = 'ПРОСМОТР':U then do:
  assign
    work-mode = "lookup-parts".
end.
else do:
  run local-check-gds.
  assign
    work-mode = "update-parts".
end.
run str/out-add.p
    (input parparentproc,
      input recid(t-doc),
      input recid(doc-line),
      input recid(gds-dtl),
      input recid(goods),
      input work-mode,
      input ?
      ).
end.
end procedure.
procedure chk-upd-date:
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  store-type
  ,input  store-code
  ,output v-today
  )  .
if input frame d-out-doc t-doc.fact-date > v-today then do:
   message "Дата больше сегодняшней даты на объекте." view-as alert-box error.
   display t-doc.fact-date with frame d-out-doc.
   return error.
end.
if input frame d-out-doc t-doc.fact-date < v-today - 7 then do:
   g#log = yes.
   message "Заведенная факт дата отличается более чем на 7 дней от сегодняшней даты на объекте."
           "Отказаться от заведения даты?" view-as alert-box question
           buttons yes-no update g#log.
   if g#log then do:
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
   g#log = no.
define variable vss-include-info92 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    ,output g#log
    )  .
end.
   if g#log = no then do:
      display t-doc.fact-date with frame d-out-doc.
      return error.
   end.
   g#log = no.
   message "Вы хотите изменить фактическую дату?" skip
           "Если дату задать как '?' она при закрытии на факт проставится днем закрытия."
   view-as alert-box question buttons yes-no update g#log.
   if not g#log then do:
      display t-doc.fact-date with frame d-out-doc.
      return error.
   end.
   assign t-doc.fact-time = (24 * 60 * 60).
end.
end procedure.
procedure local-cur:
define input parameter parwith-tax as integer no-undo.
define buffer cur-doc-line  for ub.doc-line.
define buffer cur-goods     for ub.goods.
define buffer cur-gds-dtl   for ub.gds-dtl.
define variable varpc       as decimal no-undo.
define variable varflag-ret as logical no-undo.
define variable round-base   as decimal no-undo.
define variable round-method as char    no-undo.
define variable varnew-price like ub.doc-line.price-base no-undo.
define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.
define variable v-host-code     like ub.sysconf.host-code  no-undo.
define variable vss-include-info93 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    ,output g#log
    )  .
end.
   if g#log = no then return error.
   assign varpc       = 0.00
          varflag-ret = no
          .
   if parwith-tax <> 3 then do:
     run str/pc-ov.w (input  parwith-tax,
                  output varpc,
                  output varflag-ret,
                  output round-base,
                  output round-method) no-error.
     if error-status:error or
        varflag-ret <> yes then return error.
   end.
   run waitfram-show in this-procedure  ("Простановка учетных цен").
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
define variable vss-include-info94 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info96 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
       run str/out-add.p
            (input parparentproc,
            input recid(t-doc),
            input recid(cur-doc-line),
            input recid(cur-gds-dtl),
            input recid(cur-goods),
            input "update-sale-price",
            input string(varnew-price)
            ) no-error.
       if error-status:error then do:
          message "Ошибка при вызове программы out-add.p" view-as alert-box.
          run waitfram-hide in this-procedure  .
          undo tr, return error.
       end.
       if parwith-tax = 3 then do:
         assign
           cur-doc-line.vat-pc = 0
           cur-doc-line.slt-pc = 0.
       end.
       run waitfram-show in this-procedure  ("Простановка учетных цен по товару " + string(cur-goods.artic) + " " +
                        string(cur-goods.prod-type) + " " + string(cur-goods.prod-code)).
   end.
   if parwith-tax = 3 then do:
     run gbl/calc-trn.p (input parParentProc, input recid (t-doc)).
     run ui-on ("line").
   end.
   end.
   run waitfram-hide .
end procedure.
define variable vss-include-info97 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info98 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure copy-lst :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define input parameter parcash-pay like ub.sysconf.cash-pay no-undo.
define input parameter pardoc-prt  as   logical             no-undo.
define input parameter table for tt-gds-list.
define variable chg-qnty     like ub.gds-dtl.doc-qnty  no-undo.
define variable legal-node   like ub.gds-prt.node-code no-undo.
define buffer cpl_goods    for ub.goods.
define buffer cpl_gds-obj  for ub.gds-obj.
define buffer cpl_prt-obj  for ub.prt-obj.
define buffer cpl_trn-doc  for ub.trn-doc.
define buffer cpl_gds-prt  for ub.gds-prt.
define buffer cpl_gds-dtl  for ub.gds-dtl.
define buffer cpl_doc-line for ub.doc-line.
define variable varcount    as integer no-undo.
define variable varchg-qnty like ub.gds-dtl.doc-qnty no-undo.
define variable vardoc-qnty like ub.gds-dtl.doc-qnty no-undo.
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
    run waitfram-show in this-procedure  ("ЖДИТЕ.  Обработано строк списка : " + string (varcount)).
  end.
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
  if error-status:error then do:
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
      if error-status:error then do:
         return error substitute("Ошибка при создании признака &1.", return-value).
      end.
      find first cpl_gds-dtl where cpl_gds-dtl.doc-code  = cpl_trn-doc.doc-code and
                                   cpl_gds-dtl.artic     = cpl_goods.artic      and
                                   cpl_gds-dtl.prod-code = cpl_goods.prod-code  and
                                   cpl_gds-dtl.prod-type = cpl_goods.prod-type  and
                                   cpl_gds-dtl.prt-code  = legal-node.
      assign
        cpl_gds-dtl.ov  = no.
define variable vss-include-info99 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(cpl_gds-dtl)
  , input no
  , input ?
  ) no-error.
      if error-status:error then undo, next r-l.
      assign
        chg-qnty = cpl_prt-obj.fact-qnty.
      run trg/rsrv-dtl.p (input parParentProc, 'reserv':U, buffer cpl_gds-dtl, input-output chg-qnty, input-output cpl_doc-line.price-base, input-output cpl_doc-line.price-rubl, -1, "") no-error.
      if error-status:error then undo c-l, return error.
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
end procedure.
procedure local-add :
define buffer bf_contract-specif for ub.contract-specif.
define buffer bf-hv_doc-line     for ub.doc-line.
define buffer bf_goods           for ub.goods.
define variable varlog      as   logical                    no-undo.
do on error undo, return error return-value
:
run check-rate no-error.
if error-status:error then do:
  message "Ошибка при проверке курса валют." skip
          return-value
  view-as alert-box error.
  return error return-value.
end.
v-cond       = 'свободно':U
.
if t-doc.contract-code <> 0 then do:
  find first bf_contract-specif where bf_contract-specif.host-code    = t-doc.cli-code      and
                                      bf_contract-specif.contract-num = t-doc.contract-code no-lock no-error.
end.
if t-doc.contract-code <> 0     and
   available bf_contract-specif then do:
   assign
     varlog = yes.
   message "Вы хотите добавить все недобавленые товары по спецификации?"
   view-as alert-box question buttons yes-no update varlog.
end.
if t-doc.contract-code <> 0     and
   available bf_contract-specif and
   varlog                       then do:
  for each bf_contract-specif where bf_contract-specif.host-code    = t-doc.cli-code      and
                                    bf_contract-specif.contract-num = t-doc.contract-code no-lock on error undo, return error return-value :
    find first bf_goods where bf_goods.gds-code = bf_contract-specif.gds-code no-lock.
    find first bf-hv_doc-line where bf-hv_doc-line.doc-code  = t-doc.doc-code     and
                                    bf-hv_doc-line.artic     = bf_goods.artic     and
                                    bf-hv_doc-line.prod-type = bf_goods.prod-type and
                                    bf-hv_doc-line.prod-code = bf_goods.prod-code no-lock no-error.
    if not available bf-hv_doc-line then do:
      assign
        notes = notes + (if notes = '':u then '':u else ',':u) + string(recid(bf_goods)).
    end.
  end.
  if notes = '':u then do:
    message "Вы добавили уже все товары по спецификации."
    view-as alert-box.
    return error.
  end.
end.
else do:
  run str/flornakl.p (input parParentProc ,  input "", input t-doc.doc-code , output v-exist , output v-buket-gds-code ) .
  run str/chs-gds.w ( input parparentproc
                 ,input t-doc.obj-type
                 ,input t-doc.obj-code
                 ,input '':U
                 ,input '':U
                 ,input (if v-exist
                  then "Для нетоварной позиции"
                  else "Строка накладной № " + t-doc.doc-code)
                 ,input v-cond
                 ,input t-doc.cli-type
                 ,input t-doc.cli-code
                 ,input t-doc.host-code
                 ,input t-doc.ext-doc-type
                 ,input-output varartic
                 ,output notes).
end.
if notes = '' then return.
assign
  line-mode = 'ДОБАВЛЕНИЕ':U
  lns-cnt = 1.
do while lns-cnt <= num-entries (notes):
  assign
    gds-rec = integer (entry (lns-cnt, notes))
    lns-cnt = lns-cnt + 1.
  v-param = if v-exist then string(v-buket-gds-code)
              else ? .
  run str/out-add.p
     (input parparentproc,
      input recid(t-doc),
      input ?,
      input ?,
      input gds-rec,
      input 'ДОБАВЛЕНИЕ':U,
      input v-param
      ) no-error.
  if error-status:error then do:
    next.
  end.
end.
run ui-on ("line").
if prt-rec <> ? then do:
  reposition br-dtl to recid prt-rec no-error.
end.
end.
end procedure.
procedure val-chg-is-repay :
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
end procedure.
procedure val-chg-is-cons :
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
end procedure.
procedure val-chg-is-storage :
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
end procedure.
procedure val-chg-is-oldcons :
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
end procedure.
procedure cr-tt-upd:
do on error undo, return error return-value :
define variable v-other as character   no-undo.
for each tt-upd-attr : delete tt-upd-attr . end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '1ord_time':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '0rsrv-date':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '2befpay':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '3ord_Nchek':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '4dchek':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '5deliv':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '6sumwrk':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '8ord_adr':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '9ord_hwo':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '22ord_contact':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '21ord_phone':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  '4ord_dl':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'print-num':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'idCountryContr':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'Auto':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'cargo-desc':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'carry-type':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'cargo-mass':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'exp-trans':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'zakaz-number':U  .                                         run attr-property in this-procedure (  input  tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
end.
end procedure.
procedure init-attr-flora:
do on error undo, return error return-value :
run cr-tt-upd in this-procedure no-error.
define variable varexist                  as logical   no-undo.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '0rsrv-date':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '1ord_time':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '2befpay':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '3ord_Nchek':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '5deliv':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '6sumwrk':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '22ord_contact':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '21ord_phone':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '4ord_dl':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'print-num':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'idCountryContr':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'Auto':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'cargo-desc':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'carry-type':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'cargo-mass':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'exp-trans':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'zakaz-number':U                                                         ,  input ""                                                         , output varexist ).
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
     v-adr = buf_firm.post-addr1 + " " + buf_firm.contact-psn.
    end.
    else do:
    find first buf_person no-lock where buf_person.psn-code = t-doc.cli-code no-error .
    v-adr = string(buf_person.ind) + " " + buf_person.city + " " + buf_person.address .
    end.
end.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '4dchek':U                                                         ,  input string(t-doc.doc-date)                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '8ord_adr':U                                                         ,  input v-adr                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input '9ord_hwo':U                                                         ,  input v-h                                                         , output varexist ).
end.
end procedure.
procedure init-attr-general:
do on error undo, return error return-value :
run cr-tt-upd-general .
define variable varexist                  as logical   no-undo.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'QntyPlace':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'Auto':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'cargo-desc':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'carry-type':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'cargo-mass':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'exp-trans':U                                                         ,  input ""                                                         , output varexist ).
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'zakaz-number':U                                                         ,  input ""                                                         , output varexist ).
end.
end procedure.
procedure cr-tt-upd-general:
do on error undo, return error return-value :
define variable v-other as character   no-undo.
for each tt-upd-attr : delete tt-upd-attr . end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'QntyPlace':U  .                                         run attr-property in this-procedure (   input tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'Auto':U  .                                         run attr-property in this-procedure (   input tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'cargo-desc':U  .                                         run attr-property in this-procedure (   input tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'carry-type':U  .                                         run attr-property in this-procedure (   input tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'cargo-mass':U  .                                         run attr-property in this-procedure (   input tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'exp-trans':U  .                                         run attr-property in this-procedure (   input tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'zakaz-number':U  .                                         run attr-property in this-procedure (   input tt-upd-attr.code          ,    output tt-upd-attr.type-attr     ,    output tt-upd-attr.format-attr   ,    output tt-upd-attr.fillin_width  ,    output tt-upd-attr.fillin_height ,    output tt-upd-attr.label-attr    ,    output tt-upd-attr.user-can-edit ,    output tt-upd-attr.output-display,    output v-other                   ,    output tt-upd-attr.proc-attr          ) no-error.                           if error-status :error then do:         return error.  end.
end.
end procedure.
procedure cr-tt-posy:
do on error undo, return error return-value :
for each tt-posy : delete tt-posy . end.
define buffer buf_doc-line-attr for ub.doc-line-attr.
define buffer buf_goods         for ub.goods.
 for each buf_doc-line-attr no-lock where
          buf_doc-line-attr.doc-code = t-doc.doc-code and
          buf_doc-line-attr.attr-code = 'flora_ps':U :
          find first buf_goods no-lock where buf_goods.gds-code = buf_doc-line-attr.gds-code no-error .
     if available buf_goods then do:
          create tt-posy.
          assign
            tt-posy.gds-code   = buf_doc-line-attr.gds-code
            tt-posy.gds-name   = buf_goods.gds-name
            tt-posy.gds-dopinf = buf_doc-line-attr.attr-value
          .
     end.
 end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input '6sumwrk':U ,
                       output pr-wrk ,
                       output p-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input '7sumsrk':U ,
                       output pr-srk ,
                       output p-type )  .
assign
v-pr-wrk = decimal(pr-wrk)
v-pr-srk = decimal(pr-srk)
.
end.
end procedure.
procedure cr-tt-flor:
do on error undo, return error return-value :
define buffer buf_doc-line-attr for ub.doc-line-attr.
for each tt-flor : delete tt-flor . end.
 for each buf_doc-line-attr no-lock where
          buf_doc-line-attr.doc-code = t-doc.doc-code and
          buf_doc-line-attr.gds-code > 0 and
          entry ( 1 , buf_doc-line-attr.attr-code) = 'fl_gds-code':U
          :
          if int(entry ( 3 , buf_doc-line-attr.attr-code)) > 0 then do:
              create tt-flor.
              assign
                tt-flor.gds-code-posy = int(entry ( 3 , buf_doc-line-attr.attr-code))
                tt-flor.gds-code      = buf_doc-line-attr.gds-code
                tt-flor.prt-code      = int(entry ( 2 , buf_doc-line-attr.attr-code))
                tt-flor.fact-qnty     = decimal(buf_doc-line-attr.attr-value)
              .
          end.
 end.
end.
end procedure.
procedure re-disp :
  do
  on error undo, return error return-value
  :
define variable v-itogo-base as decimal   no-undo .
define variable v-itogo-rubl as decimal   no-undo .
define variable v-itogo-base2 as decimal   no-undo .
define variable v-itogo-rubl2 as decimal   no-undo .
define variable v-sum-with-disc-rubl as decimal   no-undo .
define variable v-sum-with-disc-base as decimal   no-undo .
define buffer tt2-goods   for ub.goods   .
define buffer tt2-gds-dtl for ub.gds-dtl .
define variable pr-srk     as character no-undo .
define variable dost-rubl  as decimal   no-undo .
define variable dost-base  as decimal   no-undo .
define variable p-type     as character no-undo   .
define variable v-dost     as character no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input '5deliv':U ,
                       output v-dost ,
                       output p-type )  .
     dost-rubl = decimal(v-dost).
     if dost-rubl = ? then dost-rubl = 0.
     dost-base = dost-rubl  * t-doc.base-scale / t-doc.base-rate.
define variable v-pr as decimal   no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input '6sumwrk':U ,
                       output pr-srk ,
                       output p-type )  .
v-pr-wrk = decimal(pr-srk).
v-pr = v-pr-wrk + v-pr-srk .
  assign
    ii-sum-rubl = 0
    ii-sum-base = 0
  .
for each  tt-posy :
assign
  v-itogo-base = 0
  v-itogo-rubl = 0
.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer b_doc-line for ub.doc-line.
   for each  b_doc-line  where b_doc-line.doc-code         = t-doc.doc-code :
    find first  buf_gds-dtl  where buf_gds-dtl.doc-code  = t-doc.doc-code
                              and b_doc-line.prod-code = buf_gds-dtl.prod-code
                              and b_doc-line.prod-type = buf_gds-dtl.prod-type
                              and b_doc-line.artic     = buf_gds-dtl.artic no-lock no-error .
              if not available  buf_gds-dtl then do:
                  message 123 "bed".
                  delete b_doc-line .
              end.
   end.
   for each tt-flor where tt-flor.gds-code-posy  = tt-posy.gds-code :
       find first tt2-goods no-lock where tt2-goods.gds-code = tt-flor.gds-code no-error .
       find first tt2-gds-dtl no-lock where
                  tt2-gds-dtl.doc-code  = t-doc.doc-code and
                  tt2-gds-dtl.artic     = tt2-goods.artic and
                  tt2-gds-dtl.prod-type = tt2-goods.prod-type and
                  tt2-gds-dtl.prod-code = tt2-goods.prod-code and
                  tt2-gds-dtl.prt-code  = tt-flor.prt-code  no-error .
    IF t-doc.status_ = 'факт':U THEN DO:
      if  available tt2-gds-dtl then
      assign
        v-itogo-base = ((tt2-gds-dtl.price-base  - tt2-gds-dtl.discnt-base) * tt-flor.fact-qnty )  + v-itogo-base
        v-itogo-rubl = ((tt2-gds-dtl.price-rubl  - tt2-gds-dtl.discnt-rubl) * tt-flor.fact-qnty )  + v-itogo-rubl
    .
    end.
    else do:
      if  available tt2-gds-dtl then
      assign
        v-itogo-base = (tt2-gds-dtl.price-base      * tt-flor.fact-qnty)  + v-itogo-base
        v-itogo-rubl = (tt2-gds-dtl.price-rubl      * tt-flor.fact-qnty)  + v-itogo-rubl
    .
    end.
   end.
    assign
      v-itogo-base2 = v-itogo-base - (v-itogo-base * t-doc.discnt-pc / 100 )
      v-itogo-rubl2 = v-itogo-rubl - (v-itogo-rubl * t-doc.discnt-pc / 100 )
    .
    IF t-doc.status_ = 'факт':U THEN DO:
      assign
        v-sum-with-disc-base = v-itogo-base
        v-sum-with-disc-rubl = v-itogo-rubl
      .
    END.
    ELSE DO:
      assign
        v-sum-with-disc-base = v-itogo-base2 +  ( v-pr * v-itogo-base2 / 100 )
        v-sum-with-disc-rubl = v-itogo-rubl2 +  ( v-pr * v-itogo-rubl2 / 100 )
      .
    END.
    assign
      tt-posy.sum-base = v-sum-with-disc-base
      tt-posy.sum-rubl = v-sum-with-disc-rubl
      ii-sum-base = tt-posy.sum-base + ii-sum-base
      ii-sum-rubl = tt-posy.sum-rubl + ii-sum-rubl
    .
end.
open query br-posy  for each tt-posy.
apply "value-changed" to br-posy in frame d-out-doc.
define variable var-sym-i-s-dost-rubl as decimal   no-undo .
define variable var-sym-i-s-dost-base as decimal   no-undo .
 if t-doc.status_ = 'факт':U then do:
    display
      string(t-doc.tot-fact - (t-doc.discnt-rubl * t-doc.base-scale / t-doc.base-rate) , ">>>,>>>,>>9.99")  @ i-sum-base
      string(t-doc.tot-sale - t-doc.discnt-rubl                                        , ">>>,>>>,>>9.99")  @ i-sum-rubl
      with frame d-out-doc .
      var-sym-i-s-dost-base = t-doc.tot-fact - (t-doc.discnt-rubl * t-doc.base-scale / t-doc.base-rate) .
      var-sym-i-s-dost-rubl = t-doc.tot-sale - t-doc.discnt-rubl .
      end.
else  do:
      display
      string(ii-sum-rubl , ">>>,>>>,>>9.99") @ i-sum-rubl
      string(ii-sum-base, ">>>,>>>,>>9.99") @ i-sum-base
      with frame d-out-doc .
      var-sym-i-s-dost-base = (ii-sum-base) + dost-base .
      var-sym-i-s-dost-rubl = (ii-sum-rubl) + dost-rubl .
  if doc-mode <> 'ПРОСМОТР':U then do:
     define variable vv1 as character no-undo .
     define variable vv2 as character no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'discnt-stop':U ,
                       output vv1 ,
                       output vv2 )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'discnt-stop':U ,
                       input string( ii-sum-rubl + dost-rubl ) )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'discnt-stop':U ,
                       output vv1 ,
                       output vv2 )  .
  end.
end.
define variable v-var-t1 as decimal   no-undo .
define variable v-var-t2 as decimal   no-undo .
v-var-t1 = var-sym-i-s-dost-base - dost-base         .
v-var-t2 = var-sym-i-s-dost-rubl - dost-rubl         .
define variable v-var-s1 as decimal   no-undo .
define variable v-var-s2 as decimal   no-undo .
v-var-s1 = t-doc.discnt-pc * v-var-t1 / ( 100 - t-doc.discnt-pc ).
v-var-s2 = t-doc.discnt-pc * v-var-t2 / ( 100 - t-doc.discnt-pc ) .
display
(v-var-s1 + v-var-t1) * 100 / ( 100 + v-pr )   @  sum-base
(v-var-s2 + v-var-t2) * 100 / ( 100 + v-pr )   @  sum-rubl
v-var-s1 + v-var-t1  @  sum-base-n
v-var-s2 + v-var-t2  @  sum-rubl-n
v-var-s1  @  t-doc.tot-calc
v-var-s2  @  t-doc.discnt-rubl
v-var-t1  @  fact-base
v-var-t2  @  fact-rubl
var-sym-i-s-dost-base   @  d-sum-base
var-sym-i-s-dost-rubl   @  d-sum-rubl
with frame d-out-doc .
run re-ver in this-procedure .
end.
end procedure.
procedure re-ver :
  do
  on error undo, return error return-value
  :
  if doc-mode = 'ПРОСМОТР':U then return .
    define buffer buf_line-attr for ub.doc-line-attr.
    define buffer buf_doc-line  for ub.doc-line.
    define buffer buf_gds-dtl   for ub.gds-dtl.
    define buffer buf_goods     for ub.goods.
    for each tt-1 : delete tt-1. end.
    for each buf_line-attr no-lock where
             buf_line-attr.doc-code  = t-doc.doc-code    and
             buf_line-attr.attr-code begins 'fl_gds-code':U + chr(44)
             :
    if  entry ( 1 , buf_line-attr.attr-code ) <> 'fl_gds-code':U  then next.
    find first tt-1 where
       tt-1.gds-code = buf_line-attr.gds-code and
       tt-1.prt-code = int(entry ( 2 , buf_line-attr.attr-code )  )     no-error .
       if available tt-1 then do:
        assign
          tt-1.gds-code = buf_line-attr.gds-code
          tt-1.prt-code = int(entry ( 2 , buf_line-attr.attr-code ))
          tt-1.fact-qnty = tt-1.fact-qnty + decimal(buf_line-attr.attr-value )
        .
       end.
       else do:
        create tt-1.
          assign
            tt-1.gds-code  = buf_line-attr.gds-code
            tt-1.prt-code  =int( entry ( 2 , buf_line-attr.attr-code ))
            tt-1.fact-qnty = decimal(buf_line-attr.attr-value )
          .
       end.
    end.
for each  buf_doc-line exclusive-lock where
          buf_doc-line.doc-code = t-doc.doc-code :
          find first buf_gds-dtl no-lock  where
                    buf_gds-dtl.artic      = buf_doc-line.artic
                and buf_gds-dtl.prod-code  = buf_doc-line.prod-code
                and buf_gds-dtl.prod-type  = buf_doc-line.prod-type
                and buf_gds-dtl.doc-code  = t-doc.doc-code no-error .
  if not available buf_gds-dtl then message "bed" .
end.
for each  buf_gds-dtl exclusive-lock where
          buf_gds-dtl.doc-code = t-doc.doc-code :
     find first buf_goods no-lock  where
                buf_goods.artic       = buf_gds-dtl.artic
            and buf_goods.prod-code  = buf_gds-dtl.prod-code
            and buf_goods.prod-type  = buf_gds-dtl.prod-type no-error .
    if buf_gds-dtl.fact-qnty > buf_gds-dtl.doc-qnty and t-doc.status_ = 'разрешен':U then do:
       message "Фактическое количество товара не может быть больше количества по накладной."skip
                "Артикул :" buf_goods.artic    skip
                "Товар   :" buf_goods.gds-name   skip
                "Количество Фактическое  :" buf_gds-dtl.fact-qnty skip
                "Количество по документу :" buf_gds-dtl.doc-qnty skip
                view-as alert-box error .
    end.
       find first buf_doc-line no-lock  where
                              buf_goods.artic   = buf_doc-line.artic
                       and buf_goods.prod-code  = buf_doc-line.prod-code
                       and buf_goods.prod-type  = buf_doc-line.prod-type
                       and buf_doc-line.doc-code = t-doc.doc-code no-error .
      find first tt-1 where
                 tt-1.gds-code = buf_goods.gds-code no-error .
      if not available tt-1 then do:
            assign prt-rec   = recid(buf_gds-dtl)
                   line-mode = 'ИЗМЕНЕНИЕ':U
                   line-rec  = recid(buf_doc-line)
                   gds-rec   = recid(buf_goods).
            run str/out-add.p
             (input parparentproc,
              input recid(t-doc),
              input recid(buf_doc-line),
              input recid(buf_gds-dtl),
              input recid(buf_goods),
              input "delete",
              input ?
              ) no-error.
              if error-status :error then return error return-value .
      end.
end.
   for each tt-1 ,
       first buf_goods no-lock where buf_goods.gds-code = tt-1.gds-code :
       find first buf_doc-line no-lock  where
                              buf_goods.artic   = buf_doc-line.artic
                       and buf_goods.prod-code  = buf_doc-line.prod-code
                       and buf_goods.prod-type  = buf_doc-line.prod-type
                       and buf_doc-line.doc-code = t-doc.doc-code no-error .
       find first buf_gds-dtl no-lock  where
                           buf_gds-dtl.prt-code = tt-1.prt-code
                       and buf_goods.artic      = buf_gds-dtl.artic
                       and buf_goods.prod-code  = buf_gds-dtl.prod-code
                       and buf_goods.prod-type  = buf_gds-dtl.prod-type
                       and buf_gds-dtl.doc-code = t-doc.doc-code no-error .
        if available buf_gds-dtl then do:
            if buf_gds-dtl.fact-qnty <> tt-1.fact-qnty then do:
            assign prt-rec   = recid(buf_gds-dtl)
                  line-mode = 'ИЗМЕНЕНИЕ':U
                  line-rec  = recid(buf_doc-line)
                  gds-rec   = recid(buf_goods).
            run str/out-add.p
             (input parparentproc,
              input recid(t-doc),
              input recid(buf_doc-line),
              input recid(buf_gds-dtl),
              input recid(buf_goods),
              input "ch-doc-qnty",
              input string(tt-1.fact-qnty)
             ) no-error.
            if error-status :error then next.
            if tt-1.fact-qnty > buf_gds-dtl.fact-qnty then message
             "По товару " buf_goods.gds-name "возможно расходывать только " buf_gds-dtl.fact-qnty skip
             "Введено" tt-1.fact-qnty
             view-as alert-box information .
            if tt-1.fact-qnty < buf_gds-dtl.fact-qnty then message
             "По товару " buf_goods.gds-name "несовпадение количеств" buf_gds-dtl.fact-qnty skip
             "Введено" tt-1.fact-qnty
             view-as alert-box information .
             if tt-1.fact-qnty <> buf_gds-dtl.fact-qnty then
                run pr-corr-flor in this-procedure (
                 buf_goods.gds-code ,
                 buf_gds-dtl.prt-code ,
                 tt-1.fact-qnty - buf_gds-dtl.fact-qnty
                 ) .
           end.
        end.
   end.
  end.
end procedure.
procedure pr-corr-flor :
  do
  on error undo, return error return-value
  :
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-prt-code as integer   no-undo .
define input  parameter p-delta as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr.
define variable v-i as integer   no-undo init 0 .
define variable v-buket as character no-undo .
define variable v-sum as decimal   no-undo .
      for each buf_doc-line-attr no-lock  where
               buf_doc-line-attr.doc-code = t-doc.doc-code and
               buf_doc-line-attr.gds-code = p-gds-code and
               buf_doc-line-attr.attr-code  begins 'fl_gds-code':U + chr(44) + string(p-prt-code)  + chr(44)
      :
        v-i = v-i + 1 .
        v-buket = entry (3, buf_doc-line-attr.attr-code ) .
        v-sum = decimal(buf_doc-line-attr.attr-value) .
      end.
   if v-i > 1 then do:
      message "Товар находится в нескольких наборах (" v-i ") Уменьшите количество на = " p-delta  .
      return.
   end.
run lineattr-write-flora-gds in this-procedure (
     t-doc.doc-code  ,
     p-gds-code      ,
     p-prt-code      ,
     v-buket         ,
     'fl_gds-code':U  ,
     string( v-sum - p-delta)
     ).
    run cr-tt-flor in this-procedure .
    run re-disp in this-procedure  .
  end.
end procedure.
procedure ver-qnty :
  do
  on error undo, return error return-value
  :
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_goods   for ub.goods.
if not  t-doc.status_ = 'разрешен':U then return .
for each  buf_gds-dtl  no-lock  where
          buf_gds-dtl.doc-code = t-doc.doc-code :
     find first buf_goods no-lock  where
                buf_goods.artic       = buf_gds-dtl.artic
            and buf_goods.prod-code  = buf_gds-dtl.prod-code
            and buf_goods.prod-type  = buf_gds-dtl.prod-type no-error .
    if buf_gds-dtl.fact-qnty > buf_gds-dtl.doc-qnty  then do:
       message "Фактическое количество товара не может быть больше количества по накладной."skip
                "Артикул :" buf_goods.artic    skip
                "Товар   :" buf_goods.gds-name   skip
                "Количество Фактическое  :" buf_gds-dtl.fact-qnty skip
                "Количество по документу :" buf_gds-dtl.doc-qnty skip
                view-as alert-box error .
    end.
end.
  end.
end procedure.
procedure proc-sht:
  define buffer bf_shift-obj   for ub.shift-obj.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
  run str/sht-all.w (parparentproc, t-doc.obj-type, t-doc.obj-code, 'b-sel', 'obj', t-doc.obj-type, t-doc.obj-code, '':u, input-output varrid-list) no-error.
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
          t-doc.fact-date = t-doc.shift-date.
        display t-doc.fact-date with frame d-out-doc.
      end.
    end.
  end.
end procedure.
procedure proc-shift-num :
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
          t-doc.fact-date = t-doc.shift-date.
        display t-doc.fact-date with frame d-out-doc.
      end.
    end.
  end.
end procedure.
procedure proc-shift-name :
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
      if t-doc.fact-date = ? then do: assign t-doc.fact-date = t-doc.shift-date. display t-doc.fact-date with frame d-out-doc. end.
    end.
  end.
end procedure.
define variable vss-include-info100 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure create-record :
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
end procedure.
procedure attr-property :
  define  input parameter p-code           as character no-undo.
  define output parameter p-type           as character no-undo.
  define output parameter p-format         as character no-undo.
  define output parameter p-fillin_width   as integer   no-undo.
  define output parameter p-fillin_height  as integer   no-undo.
  define output parameter p-label          as character no-undo.
  define output parameter p-user-can-edit  as logical   no-undo.
  define output parameter p-output-display as logical   no-undo.
  define output parameter p-other          as character no-undo.
  define output parameter p-proc-attr      as character no-undo.
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .
  do on error undo, return error return-value :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input p-code ,
                       output p-type ,
                       output p-format ,
                       output p-fillin_width ,
                       output p-fillin_height ,
                       output p-label ,
                       output p-user-can-edit ,
                       output p-output-display ,
                       output p-other  ,
                       output p-proc-attr ,
                       output v-full-screen-val ,
                       output v-sort
                       ) no-error .
    if error-status :error then do:
      message "Ошибка при установке атрибутов-флористов документа." skip
              error-status :get-message( 1 ) skip
              return-value
      view-as alert-box error.
      return error.
    end.
  end.
end procedure.
procedure chg-purch-contract :
  message  "Проверка договора ?"  view-as alert-box .
end procedure.
