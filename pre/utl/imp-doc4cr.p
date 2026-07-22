block-level on error undo, throw.
define temp-table tt-imp-parts no-undo // скопировано из utl/imp-doc4.p
   field artic         as character
           field f02           as character
   field part-code     as character
   field in-code       like ub.parts.in-code
   field gds-code      as int64
   field price-rubl    like ub.parts.price-rubl
   field fact-qnty     like ub.parts.fact-qnty
           field f08           as character
           field f09           as character
           field f10           as character
   field vat-tax-value as decimal
           field f12           as character
           field f13           as character
   field name-gtd      as character
           field f15           as character
           field f16           as character
   field srok-god      as character
           field f18           as character
           field f19           as character
   field supp-code     as integer
   field supp-type     as character
   field cont-prn-code like ub.contract.contract-prn-code
           field imp-row       as character // исходая строка из файла импорта
.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define input  parameter parparentproc    as handle no-undo .
// define input parameter p-parent-handle  as handle no-undo . 24/IX-2018 - не используется
define input  parameter p-log-handle     as handle no-undo .
define input  parameter p-log-filename   as character no-undo .
define input  parameter p-obj-code       as integer no-undo .
define input  parameter p-obj-type       as character no-undo .
define input  parameter p-is-close       as logical no-undo . // true - закрывать созданные документы; ещё не работает: всегда false
define input  parameter p-osn-fname      as character no-undo .
define input  parameter p-art-fname      as character no-undo .
define input  parameter p-retry-fname    as character no-undo .
define input  parameter table for tt-imp-parts .
define output parameter p-count-err      as integer no-undo .
define output parameter p-count-err1     as integer no-undo .
define output parameter p-count-err2     as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: 022d9db987b8, 3255, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/01/27 13:45:26 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-doc4cr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/imp-doc4cr.p $":U .
define variable vss-description as character no-undo init "Импорт накладных. Создание документов.".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure thth150-db-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'thth150-cli-grp':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие групп клиентов"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие групп клиентов"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-gds-grp':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие групп товаров"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие групп товаров"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-clients':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие клиентов"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие клиентов"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-goods':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие товаров"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие товаров"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-dis-card':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ ДК"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ ДК"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-qnty-dis-card':U then do:     assign     p-label = "Ожидаемое кол-во ДК"     p-type = 'I':U      p-format = "999,999,999"     p-label = "Ожидаемое кол-во ДК"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-shop':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие объeктов TH"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие объeктов TH"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-contract':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ договора и спецификации"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ договора и спецификации"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-price-doc':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ переоценки"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ переоценки"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-trn-doc':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ приходные накладные"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ приходные накладные"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure thth150-db-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'thth150-cli-grp':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие групп клиентов для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие групп клиентов" .   end.
            when 'thth150-gds-grp':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие групп товаров для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие групп товаров" .   end.
            when 'thth150-clients':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие клиентов для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие клиентов" .   end.
            when 'thth150-goods':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие товаров для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие товаров" .   end.
            when 'thth150-dis-card':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ ДК"     p-label = "ИМПОРТИРОВАНЫ ДК" .   end.
            when 'thth150-qnty-dis-card':U then do:     assign     p-tooltip = "Ожидаемое кол-во ДК"     p-label = "Ожидаемое кол-во ДК" .   end.
            when 'thth150-shop':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие объeктов TH для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие объeктов TH" .   end.
            when 'thth150-contract':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ договора и спецификации для двух систем IBS TH"     p-label = "ИМПОРТИРОВАНЫ договора и спецификации" .   end.
            when 'thth150-price-doc':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ переоценки"     p-label = "ИМПОРТИРОВАНЫ переоценки" .   end.
            when 'thth150-trn-doc':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ приходные накладные"     p-label = "ИМПОРТИРОВАНЫ приходные накладные" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure thth150-db-attr-value :
  do
  on error undo, return error
  :
    define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
    define output parameter p-value     like ub.db-attr.attr-value no-undo .
    define output parameter p-type      as character no-undo .
    define buffer buf_db-attr for ub.db-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth150-db-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if avail buf_db-attr then do:
      assign
        p-value =  buf_db-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure thth150-db-attr-write :
  do
  on error undo, return error
  :
    define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input parameter p-code      like ub.db-attr.attr-code  no-undo .
    define input parameter p-value     like ub.db-attr.attr-value no-undo .
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth150-db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if not available buf_db-attr then do:
      create buf_db-attr .
      assign
        buf_db-attr.db-num    = p-db-num
        buf_db-attr.attr-code = p-code
      .
    end.
    assign
      buf_db-attr.attr-value = p-value
    .
  end.
end procedure.
procedure thth150-db-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input parameter p-code      like ub.db-attr.attr-code  no-undo .
    define output parameter p-exist    as logical  no-undo .
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth150-db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if  available buf_db-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure thth150-db-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.db-attr.db-num     no-undo .
    define input parameter p-code     like ub.db-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth150-db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_db-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_db-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure thth150-db-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'thth150-cli-grp':U then do:     assign     p-news = no.   end.
            when 'thth150-gds-grp':U then do:     assign     p-news = no.   end.
            when 'thth150-clients':U then do:     assign     p-news = no.   end.
            when 'thth150-goods':U then do:     assign     p-news = no.   end.
            when 'thth150-dis-card':U then do:     assign     p-news = no.   end.
            when 'thth150-qnty-dis-card':U then do:     assign     p-news = no.   end.
            when 'thth150-shop':U then do:     assign     p-news = no.   end.
            when 'thth150-contract':U then do:     assign     p-news = no.   end.
            when 'thth150-price-doc':U then do:     assign     p-news = no.   end.
            when 'thth150-trn-doc':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.
define temp-table temp_parts no-undo like ub.parts
  field new-cli-type  as character
  field new-cli-code  as integer
  index pi is primary
supp-type
supp-code
host-code
contract-code
VAT-type
VAT-PC
prod-type
prod-code
artic
price-cli
part-code
fact-date
.
define temp-table temp-line no-undo
  field num           as integer
  field supp-type     as character
  field supp-code     as integer
  field host-code     as integer
  field contract-code as integer
  field artic         as character
  field prod-type     as character
  field prod-code     as integer
  field part-code     as character
  field vat-type      as character
  field vat-pc        as decimal
  field price-rubl    as decimal
  field fact-qnty     as decimal
  field cli-qnty      as decimal
  field new-cli-type  as character
  field new-cli-code  as integer
  index pi is primary
  supp-type
  supp-code
  host-code
  contract-code
  vat-type
  vat-pc
  artic
  prod-type
  prod-code
  part-code
  price-rubl
  num
.
define temp-table temp-2exists no-undo
  field artic     as character
  field prod-type as character
  field prod-code as integer
  field doc-code  as character
  index pi is unique primary
  doc-code
  artic
  prod-type
  prod-code
.
define temp-table tt-trn-close no-undo
  field trn-code as character
.
define temp-table tt-trn-doc   no-undo like ub.trn-doc .
define temp-table tt2-doc-line no-undo like lib-trn_ret-line .
define temp-table tt-doc-line  no-undo like ub.doc-line .
define temp-table tt-gds-dtl   no-undo like ub.gds-dtl .
define temp-table tt-parts     no-undo like ub.parts.
define temp-table tt-doc-line-attr no-undo like ub.doc-line-attr .
define temp-table gds-list1    no-undo like gds-list .
define variable v-f-cli-code as integer   no-undo .
define variable new_obj-code   as integer   no-undo .
define variable new_obj-type   as character no-undo .
define variable new_host-code  as integer   no-undo .
define variable new_purch-code as integer no-undo .
define variable v-tti as integer   no-undo .
define variable v-print-rubl as logical   no-undo .
define variable v-ii          as integer   no-undo .
define buffer new_ext-classif for ub.ext-classif  .
define buffer new_line        for temp-line  .
define buffer buf2_temp_parts for temp_parts  .
define buffer old_contract-specif for ub.contract-specif  .
define buffer buf_shop        for ub.shop .
define variable local-trace-on as logical no-undo .
local-trace-on = false .
define variable p-from-version as character initial 'v15_0000':U no-undo .
run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("Перенос партий свободной зоны из &1 в 16.0 ...", p-from-version) ).
  define variable v-db-num as integer   no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-db-num
  )  .
  if v-db-num <> ibs.th.gbl.gbl-var:g#db-num then do :
        run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("Накладные разрешается вкачивать только в объект текущей БД. Номер текущей базы данных &1, номер базы данных выбранного объекта &2", ibs.th.gbl.gbl-var:g#db-num, v-db-num) ).
    undo, throw new Progress.Lang.AppError (substitute("Накладные разрешается вкачивать только в объект текущей БД. Номер текущей базы данных &1, номер базы данных выбранного объекта &2", ibs.th.gbl.gbl-var:g#db-num, v-db-num)) .
  end .
  if p-is-close then do :
    if not can-find (first ub.pay-type where ub.pay-type.obj-code = v-cntxp-in-pay) then do:
            run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("В настройках объекта &1 указан вид оплаты прихода &2, который отсутствует в справочнике.", p-obj-code, v-cntxp-in-pay) ).
      undo, throw new Progress.Lang.AppError (substitute("В настройках объекта &1 указан вид оплаты прихода &2, который отсутствует в справочнике.", p-obj-code, v-cntxp-in-pay)) .
    end .
  end .
define stream fosnid.
define temp-table w-osn no-undo
  field supp-type-15_0 as character
  field supp-code-15_0 as integer
  field supp-code-16_0 as integer
.
// 19/IX-2018 сопоставление товаров потребовалось переделать с артикулов на коды товаров
define temp-table w-gds no-undo
  field gds-code-15_0 as int64
  field gds-code-16_0 as integer
.
run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("чтение файла соответствия поставщиков &1", p-osn-fname) ).
  file-info:file-name = p-osn-fname .
  if file-info:file-type = ? then do :
        run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("Отсутствует файл для импорта &1", p-osn-fname) ).
    undo, throw new Progress.Lang.AppError (substitute("Отсутствует файл для импорта &1", p-osn-fname)) .
  end .
input stream fosnid from value (p-osn-fname).
repeat:
  define variable v-osn-15 as character no-undo .
  define variable v-osn-16 as integer no-undo .
  define variable v-error  as logical no-undo .
  import stream fosnid delimiter ';' v-osn-15 v-osn-16.
  create w-osn.
    w-osn.supp-type-15_0 =         substring(v-osn-15, 1, 3) no-error .
    if error-status:error then v-error = true .
    w-osn.supp-code-15_0 = integer(substring(v-osn-15, 4)) no-error .
    if error-status:error then v-error = true .
    w-osn.supp-code-16_0 =                   v-osn-16 no-error .
if v-error then do:
        run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("Не правильная кодировка в файле для импорта &1", p-osn-fname) ).
end.
end.
input stream fosnid close.
run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("чтение файла соответствия товаров &1", p-art-fname) ).
input stream fosnid from value (p-art-fname).
repeat:
  create w-gds.
  import stream fosnid delimiter ';' w-gds.
end.
input stream fosnid close.
find w-gds where w-gds.gds-code-16_0 = 0 and w-gds.gds-code-15_0 = 0 no-error.
if available w-gds then delete w-gds.
  assign
    new_obj-type = p-obj-type
    new_obj-code = p-obj-code
  .
  find first buf_shop no-lock where buf_shop.obj-code = new_obj-code no-error .
  if available buf_shop then do:
    new_purch-code = if buf_shop.purch-code > 0 then buf_shop.purch-code else 1 .
  end .
  else new_purch-code = 1 .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  new_obj-type
  ,input  new_obj-code
  ,output new_host-code
  )  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtget in g#library
  (input  new_obj-type
  ,input  new_obj-code
  ,output to-day
  ) no-error .
    empty temp-table temp-line no-error .
    EMPTY TEMP-TABLE temp_parts no-error .
    empty temp-table tt-parts .
define stream f-err-lines .
if p-retry-fname > '' then . else do :
  p-retry-fname = substitute("&1imp-parts.err", ibs.th.gbl.gbl-inipar:logDir ) .
end .
output stream f-err-lines to value(p-retry-fname) .
run create_temp_parts in this-procedure
   (new_obj-code
  , new_obj-type
  , new_host-code
  , output p-count-err
  , output p-count-err1
  , output p-count-err2
  ).
output stream f-err-lines close .
empty temp-table tt-trn-close .
run import-hed in this-procedure no-error .
    if error-status :error then do:
            run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("ошибка при импорте ПН  &1 &2" , error-status :get-message(1) , return-value ) ).
      return error  .
    end.
  for each tt-trn-close :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input tt-trn-close.trn-code ,
                       input 'is-auto-trn':U ,
                       input yes ) no-error .
        run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute(" Закрытие документа &1 на ФАКТ" , tt-trn-close.trn-code ) ).
    run clos-trn2 in this-procedure (tt-trn-close.trn-code) no-error .
    if not can-find (first trn-doc where trn-doc.doc-code = tt-trn-close.trn-code
                                     and trn-doc.status_  = 'факт':U) then do:
            run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("Не удалось закрыть на факт ПН &1 &2 &3" ,tt-trn-close.trn-code , return-value , error-status :get-message(1) ) ).
     end.
  end .
    run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("При переносе остатков по товарам отвергнуто &1 записей. Из них:", p-count-err ) ).
    run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("  нет соответствий по товарам &1", p-count-err1 ) ).
    run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("  нет соответствий по поставщикам &1", p-count-err2 ) ).
    run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("  прочие ошибки &1", p-count-err - p-count-err2 - p-count-err1 ) ).
define stream f-tgds .
function getImpRow returns character private (buffer buf_tt-parts for tt-imp-parts) :
define variable v-imp-row as character no-undo .
  v-imp-row =
          substitute("&1;", buf_tt-parts.artic) +
          ";" +
          substitute("&1;", buf_tt-parts.part-code) +
          substitute("&1;", buf_tt-parts.in-code) +
          substitute("&1;", buf_tt-parts.gds-code) +
          substitute("&1;", buf_tt-parts.price-rubl) +
          substitute("&1;", buf_tt-parts.fact-qnty) +
          ";" +
          ";" +
          ";" +
          substitute("&1;", buf_tt-parts.vat-tax-value) +
          ";" +
          ";" +
          substitute("&1;", buf_tt-parts.name-gtd) +
          ";" +
          ";" +
          substitute("&1;", buf_tt-parts.srok-god) +
          ";" +
          ";" +
          substitute("&1;", buf_tt-parts.supp-code) +
          substitute("&1;", buf_tt-parts.supp-type) +
          substitute("&1", buf_tt-parts.cont-prn-code)
  .
  return v-imp-row .
end function .
procedure create_temp_parts private :
define input  parameter p-obj-code  as integer no-undo .
define input  parameter p-obj-type  as character no-undo .
define input  parameter p-host-code as integer no-undo .
define output parameter p-count-err as integer no-undo .
define output parameter p-count-err1 as integer no-undo .
define output parameter p-count-err2 as integer no-undo .
define variable v-last-date as date no-undo .
define variable v-artic     as character no-undo .
define variable v-prod-type as character no-undo .
define variable v-prod-code as integer no-undo .
define variable v-contract-code as integer no-undo .
define variable new_cli-type  as character no-undo .
define variable new_cli-code  as integer   no-undo .
define variable new_gds-code  as integer no-undo .
define variable v-is-supp-err as logical no-undo .
define variable v-is-cont-err as logical no-undo .
define variable v-is-good-err as logical no-undo .
define variable v-my-message  as character no-undo .
define variable v-today       as date no-undo .
define buffer buf_tt-parts for tt-imp-parts .
define buffer buf_goods    for ub.goods .
define buffer buf_contract for ub.contract .
define buffer new_clients  for ub.clients .
  assign
    p-count-err  = 0
    p-count-err1 = 0
    p-count-err2 = 0
    v-today = today
  .
  for each buf_tt-parts
  break by buf_tt-parts.supp-code
        by buf_tt-parts.cont-prn-code
        by buf_tt-parts.gds-code
  :
    if first-of (buf_tt-parts.supp-code) then do:
        v-is-supp-err = no.
      if buf_tt-parts.supp-type = ""
      then assign
        v-my-message  = substitute ("Фиктивный контрагент &1 &2", buf_tt-parts.supp-type, buf_tt-parts.supp-code )
        v-is-supp-err = true
      .
      else do :
        find first w-osn where w-osn.supp-code-15_0 = buf_tt-parts.supp-code
                           and w-osn.supp-type-15_0 = buf_tt-parts.supp-type no-error .
        if available w-osn then do:
          assign
            new_cli-type = 'орг':U
            new_cli-code = w-osn.supp-code-16_0
          .
          v-is-supp-err = not can-find (first new_clients no-lock
                                        where new_clients.obj-type = new_cli-type
                                          and new_clients.obj-code = new_cli-code) .
          if v-is-supp-err then v-my-message = substitute("ошибка (новый клиент &1 &2)", new_cli-type , new_cli-code) .
        end .
        else assign
          v-my-message  = substitute ( "Отсутствует код поставщика &1 &2 в файле соответствия &3"
                                     , buf_tt-parts.supp-type, buf_tt-parts.supp-code, p-osn-fname )
          v-is-supp-err = true
        .
      end .
      if v-is-supp-err then do :
        run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, v-my-message ).
      end .
    end .
    if v-is-supp-err then do :
      if buf_tt-parts.imp-row > "" then
        put stream f-err-lines unformatted buf_tt-parts.imp-row skip .
      else
        put stream f-err-lines unformatted getImpRow(buffer buf_tt-parts) skip .
      p-count-err = p-count-err + 1 .
      p-count-err2 = p-count-err2 + 1 .
      next .
    end .
    if first-of (buf_tt-parts.cont-prn-code) then do:
      find first buf_contract no-lock
           where buf_contract.contract-prn-code = buf_tt-parts.cont-prn-code
           and buf_contract.cli-type = new_cli-type
           and buf_contract.cli-code = new_cli-code no-error .
      if available buf_contract then assign
        v-contract-code = buf_contract.contract-code
        v-is-cont-err   = false
      .
      else do :
        v-my-message  = substitute (
          "Предупреждение. Отсутствует договор № &2 (вер.15) по поставщику &3 в вер.16. Товар &1 в вер.15",
          buf_tt-parts.gds-code, buf_tt-parts.cont-prn-code, new_cli-code ) .
        run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, v-my-message ).
        assign
          v-contract-code = 0
          v-is-cont-err   = true
        .
        for each buf_contract no-lock
           where buf_contract.cli-type = new_cli-type
             and buf_contract.cli-code = new_cli-code
              by buf_contract.contract-date-beg descending :
          if buf_contract.contract-date-end < v-today then . else do :
            v-my-message  = substitute (
              "Предупреждение. Вместо договора № &2 (вер.15) по поставщику &3 в вер.16 используется договор &4 (код=&5). Товар &1 в вер.15&6",
              buf_tt-parts.gds-code, buf_tt-parts.cont-prn-code, new_cli-code,
              buf_contract.contract-prn-code, buf_contract.contract-code, chr(10) ) .
            run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, v-my-message ).
            assign
              v-contract-code = buf_contract.contract-code
              v-is-cont-err   = false
            .
            leave .
          end .
        end .
        if v-is-cont-err then do :
          v-my-message  = substitute (
            "Ошибка. Отсутствует действующий договор на дату &3 по поставщику &2 в вер.16. Товар &1 в вер.15&4",
            buf_tt-parts.gds-code, new_cli-code, v-today, chr(10) ) .
          run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, v-my-message ).
        end .
      end .
    end .
    if v-is-cont-err then do :
      if buf_tt-parts.imp-row > "" then
        put stream f-err-lines unformatted buf_tt-parts.imp-row skip .
      else
        put stream f-err-lines unformatted getImpRow(buffer buf_tt-parts) skip .
      p-count-err = p-count-err + 1 .
      p-count-err2 = p-count-err2 + 1 .
      next .
    end .
    if first-of (buf_tt-parts.gds-code) then do:
      find first w-gds where w-gds.gds-code-15_0 = buf_tt-parts.gds-code no-error .
      if available w-gds then do :
        new_gds-code = w-gds.gds-code-16_0 .
        find first buf_goods no-lock
             where buf_goods.gds-code = new_gds-code no-error .
        if available buf_goods then assign
          v-artic     = buf_goods.artic
          v-prod-type = buf_goods.prod-type
          v-prod-code = buf_goods.prod-code
          v-is-good-err = false
        .
        else assign
          v-artic     = ""
          v-prod-type = ""
          v-prod-code = 0
          v-is-good-err = true
          v-my-message  = substitute ("Отсутствует товар с кодом &1 в справочнике товаров БД вер.16. Код в 15 &2", new_gds-code ,buf_tt-parts.gds-code )
        .
      end .
      IF AVAILABLE buf_goods THEN DO:
            run unitqnty (
             input "",
             input buf_goods.artic,
             input buf_goods.prod-type,
             input buf_goods.prod-code,
             input "",
             input buf_tt-parts.fact-qnty )
             no-error.
            if error-status:error then   do:
                 v-is-good-err = TRUE .
                 v-my-message  = RETURN-VALUE .
            end.
      END.
      else assign
        v-my-message  = substitute ("Отсутствует код товара &1 из вер.15 в файле соответствия &2", buf_tt-parts.gds-code, p-art-fname )
        v-is-good-err = true
      .
      if v-is-good-err then do :
        run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, v-my-message ).
      end .
    end .
    if v-is-good-err then do :
      if buf_tt-parts.imp-row > "" then
        put stream f-err-lines unformatted buf_tt-parts.imp-row skip .
      else
        put stream f-err-lines unformatted getImpRow(buffer buf_tt-parts) skip .
      p-count-err = p-count-err + 1 .
      p-count-err1 = p-count-err1 + 1 .
      next .
    end .
    if buf_tt-parts.srok-god = "" then v-last-date = 01/01/2001 .
                                  else v-last-date = date(buf_tt-parts.srok-god) no-error .
    do :
    create temp_parts.
    assign
      temp_parts.artic      = v-artic // 19/IX-2018 поле из импорта buf_tt-parts.artic игнорируется
      temp_parts.prod-type  = v-prod-type
      temp_parts.prod-code  = v-prod-code
      temp_parts.obj-type   = p-obj-type
      temp_parts.obj-code   = p-obj-code
      temp_parts.host-code  = p-host-code
      temp_parts.supp-code  = new_cli-code
      temp_parts.supp-type  = new_cli-type
      temp_parts.new-cli-type = new_cli-type
      temp_parts.new-cli-code = new_cli-code
      temp_parts.contract-code = v-contract-code
//  field cont-prn-code like ub.contract.contract-prn-code
      temp_parts.in-code    = buf_tt-parts.in-code // temp_parts.in-code используется для распределения партий по накладным; далее после записи документа в БД перезатирается номером созданного документа внутри стандартных процедур
//      temp_parts.out-code создаётся пустым и потом заполняется номером документа, в который внесён товар по данной партии
      temp_parts.part-code  = buf_tt-parts.part-code // Код, определяющий конкретную партию внутри одного прихода
//  field gds-code      as integer - в таблице parts не предусмотрено поле gds-code
      temp_parts.price-rubl = buf_tt-parts.price-rubl // вместо price-cli используется price-rubl
      temp_parts.fact-qnty  = buf_tt-parts.fact-qnty
      temp_parts.VAT-type   = 'в т. ч.':U
      temp_parts.VAT-pc     = buf_tt-parts.vat-tax-value
      temp_parts.cst-code   = buf_tt-parts.name-gtd
      temp_parts.last-date  = v-last-date
    .
    end .
    do :
    end .
  end .
// output stream f-tgds close .
  if p-count-err > 0 then do :
    v-my-message  = substitute (
      "Строки с ошибками выведены в файл &1. Файл предназначен для повторного импорта в ручном режиме"
    , p-retry-fname ) .
    run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, v-my-message ).
  end .
if local-trace-on then do:
 define variable dsXmlFileName as character no-undo .
 dsXmlFileName = substitute("&1/&2.xml", ibs.th.gbl.gbl-inipar:logDir, "temp_parts").
 temp-table temp_parts:WRITE-XML ( "FILE", dsXmlFileName, true, "UTF-8").
end .
end procedure .
procedure import-hed :
define variable v-qnty-fact as decimal   no-undo .
define variable v-qnty-cli  as decimal   no-undo .
define variable v-num       as integer   no-undo .
define variable dsXmlFileName as character no-undo .
define variable dsLineCount   as integer no-undo .
// Message "Обработка файла" p-in-file view-as alert-box .
do on error undo, return error substitute("ошибка &1 &2", error-status:get-message(1) , return-value) :
  assign
  v-qnty-fact = 0
  v-qnty-cli  = 0
  dsLineCount = 0
  .
    run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("Подготовка партий..."  ) ).
  for each temp_parts break
   by temp_parts.supp-type
   by temp_parts.supp-code
   by temp_parts.host-code
   by temp_parts.contract-code
   by temp_parts.VAT-type
   by temp_parts.VAT-PC
   by temp_parts.prod-type
   by temp_parts.prod-code
   by temp_parts.artic
   by temp_parts.price-rubl
   :
    dsLineCount = dsLineCount + 1 .
    do on error undo, next :
            run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("Товар &1 " , temp_parts.artic ) ).
    create tt-parts.
    assign
      tt-parts.prod-type      = temp_parts.prod-type
      tt-parts.prod-code      = temp_parts.prod-code
      tt-parts.artic          = temp_parts.artic
      tt-parts.obj-type       = new_obj-type
      tt-parts.obj-code       = new_obj-code
      tt-parts.host-code      = new_host-code
      tt-parts.supp-type      = temp_parts.new-cli-type
      tt-parts.supp-code      = temp_parts.new-cli-code
      tt-parts.price-base     = temp_parts.price-rubl
      tt-parts.price-rubl     = temp_parts.price-rubl
      tt-parts.price-cli      = temp_parts.price-rubl
      tt-parts.cli-base-rate  = 1
      tt-parts.qnty           = temp_parts.fact-qnty
      tt-parts.fact-qnty      = temp_parts.fact-qnty
      tt-parts.cli-qnty       = temp_parts.fact-qnty
      tt-parts.VAT-pc         = temp_parts.vat-pc
      tt-parts.VAT-type       = temp_parts.vat-type
      tt-parts.SLT-pc         = 0
      tt-parts.SLT-type       = 'без':U
      tt-parts.road-tax-base  = 0
      tt-parts.road-tax-rubl  = 0
      tt-parts.transport-base = 0
      tt-parts.transport-rubl = 0
      tt-parts.other-base     = 0
      tt-parts.other-rubl     = 0
      tt-parts.PS             = ""
      tt-parts.fact-date      = ? // источник заполнения new_trn-doc.fact-date отсутствует
      tt-parts.fact-num       = 0
      // tt-parts.pay-code заполняется непосредственно в tt-trn-doc
      tt-parts.rsrv-free      = ?
      tt-parts.pl-code        = 0
      tt-parts.exch-code      = 0
      tt-parts.is-supp        = yes
      tt-parts.last-date      = ?
      tt-parts.purch-code     = ? // источник заполнения new_trn-doc.purch-code отсутствует
      tt-parts.contract-code  = temp_parts.contract-code
      tt-parts.doc-type       = 'при':U
      tt-parts.part-code      = temp_parts.part-code + string(dsLineCount)
      tt-parts.in-code        = temp_parts.in-code   // в исходной версии - new_trn-doc.doc-code
      tt-parts.out-code       = "" // new_trn-doc.doc-code
      tt-parts.cst-code       = ""
      tt-parts.status_        = no
      no-error.
     if error-status:error then do:
         message 'ошибка импорта товара с артикулом' tt-parts.artic temp_parts.in-code temp_parts.out-code view-as alert-box.
         end.
    end .
    v-qnty-fact = v-qnty-fact + temp_parts.fact-qnty  .
    v-qnty-cli  = v-qnty-cli  + temp_parts.cli-qnty  . // - не заполняется
    if last-of ( temp_parts.price-rubl ) then do:
      create temp-line .
      assign
      temp-line.supp-type     = temp_parts.supp-type
      temp-line.supp-code     = temp_parts.supp-code
      temp-line.host-code     = temp_parts.host-code
      temp-line.contract-code = temp_parts.contract-code
      temp-line.vat-type      = temp_parts.vat-type
      temp-line.vat-pc        = temp_parts.vat-pc
      temp-line.prod-type     = temp_parts.prod-type
      temp-line.prod-code     = temp_parts.prod-code
      temp-line.artic         = temp_parts.artic
      temp-line.price-rubl    = temp_parts.price-rubl
// 21/V-2018 temp-line.part-code     = temp_parts.part-code
//  field num           as integer
      temp-line.fact-qnty     = v-qnty-fact
      temp-line.cli-qnty      = v-qnty-cli
      temp-line.new-cli-type  = temp_parts.new-cli-type
      temp-line.new-cli-code  = temp_parts.new-cli-code
      v-qnty-fact = 0
      v-qnty-cli  = 0
      .
    end.
if local-trace-on then do:
 dsXmlFileName = substitute("&1/&2-&3.xml", ibs.th.gbl.gbl-inipar:logDir, "tt_parts", string(dsLineCount, "9999999")).
 temp-table tt-parts:WRITE-XML ( "FILE", dsXmlFileName, true, "UTF-8").
end.
  end.
    run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("обработано &1 партий", dsLineCount  ) ).
  for each temp-line  break
  by temp-line.supp-type
  by temp-line.supp-code
  by temp-line.host-code
  by temp-line.contract-code
  by temp-line.vat-type
  by temp-line.vat-pc
  by temp-line.prod-type
  by temp-line.prod-code
  by temp-line.artic
  :
    if first-of (temp-line.artic) then do:
      v-num = 0 .
    end.
    v-num = v-num + 1 .
    temp-line.num = v-num .
  end.
if local-trace-on then do:
 dsXmlFileName = substitute("&1/&2.xml", ibs.th.gbl.gbl-inipar:logDir, "temp_line").
 temp-table temp-line:WRITE-XML ( "FILE", dsXmlFileName, true, "UTF-8").
end.
  for each temp-line break
  by temp-line.supp-type
  by temp-line.supp-code
  by temp-line.host-code
  by temp-line.contract-code
  by temp-line.vat-type
  by temp-line.vat-pc
  by temp-line.num
  :
    if first-of (temp-line.num) then do:
      empty temp-table tt-trn-doc .
      empty temp-table tt2-doc-line .
      empty temp-table tt-doc-line .
      empty temp-table tt-gds-dtl .
      for each lib-trn_ret-doc :
        delete lib-trn_ret-doc.
      end.
      for each lib-trn_ret-line :
        delete lib-trn_ret-line      .
      end.
      for each lib-trn_ret-line-attr :
        delete lib-trn_ret-line.
      end.
      for each lib-trn_ret-dtl :
        delete lib-trn_ret-dtl.
      end.
      for each lib-trn_ret-parts :
        delete lib-trn_ret-parts .
      end.
                run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("Обработка линий &1 " , temp_parts.artic ) ).
      run create-nakl in this-procedure  ( temp-line.num, temp-line.new-cli-type, temp-line.new-cli-code ) .
    end.
  end.
end.
end procedure.
procedure create-nakl :
define input parameter p-num        as integer no-undo .
define input parameter new_cli-type as character no-undo .
define input parameter new_cli-code as integer no-undo .
define variable n-d as character no-undo .
define variable v-ext-doc-type as character no-undo .
define buffer buf_goods for ub.goods .
define buffer new_trn-doc     for ub.trn-doc  .
do on error undo, return error return-value :
  run doc-code in this-procedure
    (input  "main":u,
     input  new_obj-type,
     input  new_obj-code,
     input  ?,
     output n-d ) no-error.
  if error-status:error then do:
        run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("Ошибка при генерации номера документа &1 &2: &3 | &4" ,new_obj-type, new_obj-code, error-status:get-message(1), return-value ) ).
    undo, throw new Progress.Lang.AppError(substitute("Ошибка при генерации номера документа &1 &2: &3 | &4" ,new_obj-type, new_obj-code, error-status:get-message(1), return-value )) .
  end.
    run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("Создание ПН № &1 объект &2&3 контраг &4&5 &6 Товар " , n-d  , new_obj-type , new_obj-code ,  new_cli-type ,  new_cli-code , temp-line.contract-code ) ).
  assign
    v-ext-doc-type = 'ie':U
  .
  find first temp_parts where
             temp_parts.artic         = temp-line.artic     and
             temp_parts.prod-type     = temp-line.prod-type and
             temp_parts.prod-code     = temp-line.prod-code and
             temp_parts.supp-code     = temp-line.supp-code and
             temp_parts.supp-type     = temp-line.supp-type and
             temp_parts.host-code     = temp-line.host-code and
             temp_parts.vat-type      = temp-line.vat-type  and
             temp_parts.vat-pc        = temp-line.vat-pc    and
             temp_parts.contract-code = temp-line.contract-code  and
             temp_parts.price-rubl    = temp-line.price-rubl no-error .
  if not available temp_parts then do:
    message "Parts not found" skip
 "artic:" temp-line.artic skip
 "prod-type:" temp-line.prod-type skip
 "prod-code:" temp-line.prod-code skip
 "supp-code:" temp-line.supp-code skip
 "supp-type:" temp-line.supp-type skip
 "host-code:" temp-line.host-code skip
 "vat-type:" temp-line.vat-type skip
 "vat-pc:" temp-line.vat-pc skip
 "contract-code:" temp-line.contract-code skip
 "part-code:" temp-line.part-code skip
 "price-rubl:" temp-line.price-rubl skip
    view-as alert-box.
    return.
  end .
  do :
  create  tt-trn-doc.
  buffer-copy temp_parts to tt-trn-doc
  assign
    tt-trn-doc.status_       = "temp"
    tt-trn-doc.doc-code      = n-d
    tt-trn-doc.doc-date      = to-day
    tt-trn-doc.cli-type      = new_cli-type
    tt-trn-doc.cli-code      = new_cli-code
    tt-trn-doc.obj-type      = new_obj-type
    tt-trn-doc.obj-code      = new_obj-code
    tt-trn-doc.host-code     = new_host-code
    tt-trn-doc.contract-code = temp-line.contract-code
    tt-trn-doc.doc-type      = 'при':U
    tt-trn-doc.internal      = false
    tt-trn-doc.cr-db-num     = ibs.th.gbl.gbl-var:g#db-num
    tt-trn-doc.office        = false
    tt-trn-doc.fact-num      = 0
    tt-trn-doc.PS            = "Перенос остатков"
    tt-trn-doc.creid         = ibs.th.gbl.gbl-var:g#userid
    tt-trn-doc.flag_         = false
    tt-trn-doc.ext-doc-type  = v-ext-doc-type
    tt-trn-doc.discnt-type   = ""
    tt-trn-doc.ret-supp      = false
    tt-trn-doc.pay-code      = v-cntxp-in-pay
    tt-trn-doc.purch-code    = new_purch-code
    tt-trn-doc.SLT-type      = 'без':U // ранее это значение присвоилось во все tt-parts.SLT-type, но не в temp_parts
  .
  if tt-trn-doc.exch-code = ? then tt-trn-doc.exch-code = 0 .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  new_host-code
  ,input  temp_parts.fact-date
  ,output tt-trn-doc.base-rate
  ,output tt-trn-doc.base-scale
  ) no-error .
  if tt-trn-doc.base-rate  = ? or tt-trn-doc.base-rate  = 0 then tt-trn-doc.base-rate  = 1 .
  if tt-trn-doc.base-scale = ? or tt-trn-doc.base-scale = 0 then tt-trn-doc.base-scale = 1 .
  if tt-trn-doc.exch-rate  = ? or tt-trn-doc.exch-rate  = 0 then tt-trn-doc.exch-rate  = 1 .
  if tt-trn-doc.exch-scale = ? or tt-trn-doc.exch-scale = 0 then tt-trn-doc.exch-scale = 1 .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input tt-trn-doc.acc-date
,input tt-trn-doc.bge-date
,input tt-trn-doc.base-rate
,input tt-trn-doc.base-scale
,input tt-trn-doc.cli-code
,input tt-trn-doc.cli-type
,input tt-trn-doc.cli-name
,input tt-trn-doc.cr-db-num
,input tt-trn-doc.creid
,input tt-trn-doc.discnt-type
,input tt-trn-doc.doc-code
,input tt-trn-doc.doc-date
,input tt-trn-doc.doc-type
,input tt-trn-doc.flag_
,input tt-trn-doc.host-code
,input tt-trn-doc.internal
,input tt-trn-doc.obj-code
,input tt-trn-doc.obj-type
,input tt-trn-doc.office
,input tt-trn-doc.pay-code
,input tt-trn-doc.ps
,input tt-trn-doc.ret-supp
,input tt-trn-doc.slt-type
,input tt-trn-doc.status_
,input tt-trn-doc.vat-type
,input tt-trn-doc.ext-doc-type
,input tt-trn-doc.purch-code
) no-error
.
  if error-status :error then do:
        run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("Ошибка при генерации  документа1 &1 &2" , return-value , error-status :get-message(1) ) ).
    return error return-value .
  end.
  end .
  find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .
  if error-status :error then do:
        run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("Ошибка при генерации  документа2 &1 &2" , return-value , error-status :get-message(1) ) ).
    return error return-value .
  end.
  assign
   new_trn-doc.contract-code = temp-line.contract-code
   new_trn-doc.exch-rate   = tt-trn-doc.exch-rate
   new_trn-doc.exch-scale  = tt-trn-doc.exch-scale
   new_trn-doc.exch-date   = to-day
   new_trn-doc.exch-code   = tt-trn-doc.exch-code
   new_trn-doc.status_     = 'накл':U
   new_trn-doc.hold-doc-code-child   = "no-hold"
   new_trn-doc.hold-doc-code-parent  = "no-hold"
   new_trn-doc.print-rubl  = v-print-rubl
   new_trn-doc.reason-code = 24
  .
 define variable dsXmlFileName1 as character no-undo .
 define variable dsXmlFileName2 as character no-undo .
 define variable dsXmlFileName3 as character no-undo .
// dsXmlFileName1 = substitute("&1/&2.xml", ibs.th.gbl.gbl-inipar:logDir, "tt-doc-line0").
// dsXmlFileName2 = substitute("&1/&2.xml", ibs.th.gbl.gbl-inipar:logDir, "tt2-doc-line0").
  for each    new_line where
              new_line.supp-type      = temp_parts.supp-type     and
              new_line.supp-code      = temp_parts.supp-code     and
              new_line.host-code      = temp_parts.host-code     and
              new_line.vat-type       = temp_parts.vat-type      and
              new_line.vat-pc         = temp_parts.vat-pc        and
              new_line.contract-code  = temp_parts.contract-code and
              new_line.num            = p-num :
    if new_line.price-rubl <= 0  or new_line.price-rubl = ? then do:
            run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("Цена &2   = &1 Пропускаю " , new_line.price-rubl  , new_line.artic ) ).
      next.
    end.
    if new_line.fact-qnty <= 0 then do:
            run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("Количество &2   = &1 Пропускаю " , new_line.fact-qnty  , new_line.artic ) ).
      next.
    end.
  for each buf2_temp_parts no-lock where
        buf2_temp_parts.host-code      = temp_parts.host-code and
        buf2_temp_parts.price-rubl <> ? and
        buf2_temp_parts.price-rubl <> 0 and
        buf2_temp_parts.vat-type       = temp_parts.vat-type and
        buf2_temp_parts.contract-code  = temp_parts.contract-code and
        buf2_temp_parts.supp-type      = temp_parts.supp-type and
        buf2_temp_parts.supp-code      = temp_parts.supp-code and
        buf2_temp_parts.vat-pc         = temp_parts.vat-pc    and
        buf2_temp_parts.artic          = new_line.artic       and
        buf2_temp_parts.prod-type      = new_line.prod-type   and
        buf2_temp_parts.prod-code      = new_line.prod-code   and
        buf2_temp_parts.price-rubl     = new_line.price-rubl
  :
    find first tt-doc-line exclusive-lock where
              tt-doc-line.doc-code       = n-d and
              tt-doc-line.artic          = buf2_temp_parts.artic   and
              tt-doc-line.prod-type      = buf2_temp_parts.prod-type and
              tt-doc-line.prod-code      = buf2_temp_parts.prod-code no-error .
    if not available tt-doc-line then do:
      find first buf_goods no-lock
           where buf_goods.artic     = buf2_temp_parts.artic
             and buf_goods.prod-type = buf2_temp_parts.prod-type
             and buf_goods.prod-code = buf2_temp_parts.prod-code no-error .
      if not available buf_goods then next .
      create  tt-doc-line.
      assign
      tt-doc-line.doc-code       = n-d
      tt-doc-line.obj-type       = new_obj-type
      tt-doc-line.obj-code       = new_obj-code
      tt-doc-line.line-num       = next-value (s-line-num, ub)
      tt-doc-line.artic          = buf2_temp_parts.artic
      tt-doc-line.prod-type      = buf2_temp_parts.prod-type
      tt-doc-line.prod-code      = buf2_temp_parts.prod-code
      tt-doc-line.prt-root       = buf_goods.prt-root
      tt-doc-line.unit-cli       = buf_goods.unit-base
      tt-doc-line.slt-pc         = buf2_temp_parts.slt-pc
      tt-doc-line.vat-pc         = buf2_temp_parts.vat-pc
      tt-doc-line.ext-doc-type   = v-ext-doc-type
      tt-doc-line.price-base     = buf2_temp_parts.price-rubl
      tt-doc-line.price-cli      = buf2_temp_parts.price-rubl
      tt-doc-line.price-rubl     = buf2_temp_parts.price-rubl
      tt-doc-line.cli-base-rate  = 1
      tt-doc-line.doc-density    = 1 / tt-doc-line.cli-base-rate
      tt-doc-line.fact-density   = 1 / tt-doc-line.cli-base-rate
      tt-doc-line.status_        = "temp"
      tt-doc-line.cli-qnty       = 0
      tt-doc-line.doc-qnty       = 0
      tt-doc-line.fact-qnty      = 0
      .
      create temp-2exists.
      assign
      temp-2exists.artic = buf2_temp_parts.artic
      temp-2exists.prod-type = buf2_temp_parts.prod-type
      temp-2exists.prod-code = buf2_temp_parts.prod-code
      temp-2exists.doc-code = n-d
      .
      release temp-2exists.
    end.
    assign
      tt-doc-line.cli-qnty  = tt-doc-line.cli-qnty  + buf2_temp_parts.fact-qnty
      tt-doc-line.doc-qnty  = tt-doc-line.doc-qnty  + buf2_temp_parts.fact-qnty
      tt-doc-line.fact-qnty = tt-doc-line.fact-qnty + buf2_temp_parts.fact-qnty
    .
    find first tt2-doc-line exclusive-lock where
              tt2-doc-line.doc-code       = n-d and
              tt2-doc-line.artic          = tt-doc-line.artic   and
              tt2-doc-line.prod-code      = tt-doc-line.prod-code and
              tt2-doc-line.prod-type      = tt-doc-line.prod-type  no-error .
    if not available tt2-doc-line then do:
      create  tt2-doc-line .
    end.
    BUFFER-COPY tt-doc-line to tt2-doc-line no-error.
    if error-status:error then do:
      message "buf-copy1 err" skip
      "doc-code:" n-d
      "artic:" tt-doc-line.artic
      view-as alert-box .
    end .
    find first tt-gds-dtl exclusive-lock where
              tt-gds-dtl.doc-code   = n-d and
              tt-gds-dtl.prt-code   = tt-doc-line.prt-root and
              tt-gds-dtl.artic      = tt-doc-line.artic   and
              tt-gds-dtl.prod-code  = tt-doc-line.prod-code and
              tt-gds-dtl.prod-type  = tt-doc-line.prod-type  no-error .
    if not available tt-gds-dtl then do:
      create  tt-gds-dtl .
    end.
    buffer-copy  tt-doc-line  to  tt-gds-dtl
    assign
    tt-gds-dtl.prt-code  =  tt-doc-line.prt-root
    no-error .
    if error-status:error then do:
      message "buf-copy2 err" skip
      "doc-code:" n-d
      "artic:" tt-doc-line.artic
      view-as alert-box .
    end .
// temp-table tt-doc-line:WRITE-XML ( "FILE", dsXmlFileName1, true, "UTF-8").
// temp-table tt2-doc-line:WRITE-XML ( "FILE", dsXmlFileName2, true, "UTF-8").
  end .
  end .
if local-trace-on then do:
 dsXmlFileName1 = substitute("&1/&2-&3.xml", ibs.th.gbl.gbl-inipar:logDir, "tt-doc-line", n-d).
 temp-table tt-doc-line:WRITE-XML ( "FILE", dsXmlFileName1, true, "UTF-8").
 dsXmlFileName2 = substitute("&1/&2-&3.xml", ibs.th.gbl.gbl-inipar:logDir, "tt2-doc-line", n-d).
 temp-table tt2-doc-line:WRITE-XML ( "FILE", dsXmlFileName2, true, "UTF-8").
end .
  for each tt2-doc-line :
    // pi линий:  doc-code artic prod-type prod-code
    // pi партий: obj-type obj-code artic prod-type prod-code in-code out-code part-code prt-code
    for each tt-parts
       where tt-parts.obj-type  = tt2-doc-line.obj-type
         and tt-parts.obj-code  = tt2-doc-line.obj-code
         and tt-parts.artic     = tt2-doc-line.artic
         and tt-parts.prod-type = tt2-doc-line.prod-type
         and tt-parts.prod-code = tt2-doc-line.prod-code
         and tt-parts.supp-type     = new_trn-doc.cli-type
         and tt-parts.supp-code     = new_trn-doc.cli-code
         and tt-parts.contract-code = new_trn-doc.contract-code
         and tt-parts.vat-type      = new_trn-doc.vat-type
         and tt-parts.vat-pc        = tt2-doc-line.vat-pc
         and tt-parts.price-rubl    = tt2-doc-line.price-rubl
    :
      tt-parts.out-code = tt2-doc-line.doc-code no-error .
    end . // end_of for_each tt-parts
  end.
if local-trace-on then do:
 dsXmlFileName3 = substitute("&1/&2-&3.xml", ibs.th.gbl.gbl-inipar:logDir, "tt_parts-2", n-d).
 temp-table tt-parts:WRITE-XML ( "FILE", dsXmlFileName3, true, "UTF-8").
end .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_copy-in in g#lib-trn4
( input parParentProc
 ,input recid(new_trn-doc)
 ,input table tt-trn-doc
 ,input table tt2-doc-line
 ,input table tt-doc-line-attr
 ,input table tt-gds-dtl
 ,input table tt-parts
 ,input yes
 ,input yes
 ,input no
 ,input yes
 ,input this-procedure
  ) no-error .
  if error-status:error then do :
            run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute("Не удалось добавить товар в приходную накладную  (copy-in.i)! &1 &2" , return-value , error-status :get-message(1) ) ).
      return error return-value .
  end.
  v-ii = v-ii + 1.
  run gbl/calc-trn.p ( input parparentproc, input recid(new_trn-doc)) no-error.
  find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .
  assign
  new_trn-doc.tot-cli = new_trn-doc.tot-calc
  .
  if p-is-close then do :
      create tt-trn-close .
      assign tt-trn-close.trn-code = new_trn-doc.doc-code .
  end .
end.
end procedure.
procedure clos-trn2 :
define input parameter p-trn-code as character no-undo .
define variable v-cntxt-rsrv-time  as integer   no-undo .
define variable v-cntxt-load-time  as integer   no-undo .
define variable v-cntxt-holidays  as character no-undo .
define variable varchg-inv as logical no-undo .
do
on error undo, return error return-value
:
  run str/trn-stat.p (
    input  parparentproc  ,
    input  this-procedure ,
    input  '<закрытие документа на факт>':U ,
    input  p-trn-code,
    input  false  ,
    input  ibs.th.gbl.gbl-var:g#db-num,
    input  false ,
    input  v-cntxt-rsrv-time,
    input  v-cntxt-load-time,
    input  v-cntxt-holidays,
    input  false ,
    output varchg-inv ,
    output table gds-list1 )
    no-error.
    if error-status:error then do :
                run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, substitute(" Ошибка при закрытии документа &2 &1" , return-value , p-trn-code ) ).
    end.
end.
end procedure.
procedure unitqnty :
  define input parameter  p-unit-name        like ub.units.unit-name no-undo .
  define input parameter  p-artic            like ub.goods.artic     no-undo .
  define input parameter  p-prod-type        like ub.goods.prod-type no-undo .
  define input parameter  p-prod-code        like ub.goods.prod-code no-undo .
  define input parameter  p-unit-description as character            no-undo .
  define input parameter  p-qnty             as decimal              no-undo .
  define variable vss-description as character no-undo initial "unitqnty-01: Контроль допустимых количеств для данной единицы измерения (товара)".
  define variable message_err as character no-undo .
  define buffer buf_units for ub.units .
  define buffer buf_goods for ub.goods .
  define variable v-artic as character no-undo .
  if p-unit-description = ''
  or p-unit-description = ?
  then do:
    assign
      p-unit-description = "Единица измерения"
    .
  end.
  if  p-unit-name <> ''
  and p-unit-name <> ?
  then do:
    find first buf_units no-lock
      where buf_units.unit-name = p-unit-name
      no-error .
    if not available buf_units
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена единица измерения" skip
        "p-unit-name"   p-unit-name skip
        "p-artic"       p-artic  skip
        "p-prod-type"   p-prod-type skip
        "p-proc-code"   p-prod-code skip
        "p-qnty"        p-qnty skip
        view-as alert-box error .
      message_err = substitute("Не найдена единица измерения &1 &2 &3 &4 &4",p-unit-name, p-artic, p-prod-type, p-prod-code, p-qnty ).
      undo, return error message_err .
    end.
  end.
  else do:
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "p-unit-name"   p-unit-name skip
        "p-artic"       p-artic  skip
        "p-prod-type"   p-prod-type skip
        "p-proc-code"   p-prod-code skip
        "p-qnty"        p-qnty skip
        view-as alert-box error .
        message_err = substitute("Не найден товар &1 &2 &3", p-artic, p-prod-code, p-qnty ).
      undo, return error message_err .
    end.
    find first buf_units no-lock
      where buf_units.unit-name = buf_goods.unit-base
      no-error .
    if not available buf_units
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена единица измерения" skip
        "p-unit-name"   p-unit-name skip
        "p-artic"       p-artic  skip
        "p-prod-type"   p-prod-type skip
        "p-proc-code"   p-prod-code skip
        "p-qnty"        p-qnty skip
        view-as alert-box error .
      message_err = substitute("Не найдена единица измерения &1 &2 &3 &4 &4",p-unit-name, p-artic, p-prod-type, p-prod-code, p-qnty ).
      undo, return error message_err .
    end.
    assign
      v-artic = "Артикул " + string(p-artic) + " " + string(p-prod-type)
              + " " + string(p-prod-code)
      p-unit-description = "Базовая единица измерения"
    .
  end.
  if lookup('шту':U, buf_units.type) > 0
  or lookup('сер':U, buf_units.type) > 0
  then do:
    if p-qnty <> truncate(p-qnty, 0)
    then do:
    message_err = substitute("Ошибка. Для штучного и серийного товаров резервируемое количество должно быть целым &1 &2 &3 Запрошено количество &4", v-artic, p-unit-description, buf_units.unit-name, p-qnty ).
      message
        "Для штучного и серийного товаров резервируемое количество должно быть целым" skip
        v-artic skip
        p-unit-description buf_units.unit-name skip
        "Запрошено количество " p-qnty skip
        view-as alert-box .
      undo, return error message_err .
    end.
  end.
end procedure.
