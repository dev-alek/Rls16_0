block-level on error undo, throw.
using ibs.th.str.ptrl.*.
using ibs.th.gbl.storage.*.
using ibs.th.str.*.
using ibs.th.gbl.logging.*.
using ibs.th.ref.*.
define input  parameter parparentproc as handle    no-undo.
define input  parameter p-rvs-rowid   as rowid     no-undo .
define output parameter p-docs-info   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 94114751b278, 3560, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/11/27 08:31:19 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rvscrdcs.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rvscrdcs.p $":U .
define variable vss-description as character no-undo init "создание топливных документов по документу сверки".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable ptrlprop-denstclc      as character no-undo initial 'shft_rvs-inc':U .
define variable ptrlprop-inpptrl       as character no-undo initial 'weight':U .
define variable ptrlprop-expptrl       as character no-undo initial 'volume':U .
define variable ptrlprop-autopump      as logical   no-undo initial false .
define variable ptrlprop-avtinvpm      as logical   no-undo initial false .
define variable ptrlprop-rvsnmter      as logical   no-undo initial false .
define variable ptrlprop-olddens       as logical   no-undo initial false .
define variable ptrlprop-invclipt      as integer   no-undo initial ? .
define variable ptrlprop-algrvspt      as integer   no-undo initial 1 .
define variable ptrlprop-temp-for-pomi as integer   no-undo initial 1 .
define variable ptrlprop-algoincome as integer no-undo init 0.
define variable ptrlprop-mand-choice-autocar as logical no-undo init false.
define variable ptrlprop-Delta-mass-horiz      as character no-undo .
define variable ptrlprop-Delta-mass-vert       as character no-undo .
define variable ptrlprop-calc-free-vol as logical no-undo init false.
define variable ptrlprop-calc-free-vol-sug as logical no-undo init false.
define variable ptrlprop-trn-reas-sug as logical no-undo init true.
define variable ptrlprop-rvd-own-nb as logical no-undo init false.
define variable ptrlprop-qr-scan-time as integer no-undo init 5000 .
define variable ptrlprop-block-nozzle as logical no-undo init false.
define variable ptrlprop-timeout-block-nozzle as integer no-undo init 5 .
define variable ptrlprop-autopump-skip-time as integer no-undo init 0 .
procedure get-ptrl-prop :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (get-ptrl-prop). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-ptrl-prop). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-ptrl-prop). endkey", vss-workfile )
  :
    define variable par-type          as character no-undo.
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    for each thbjattr_thbj-attr
    :
      delete thbjattr_thbj-attr .
    end.
    run adm/shattri.p
      ( input "get":U
      , input p-obj-type
      , input p-obj-code
      , input 'petrol':U
      , input  ""
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output par-type
      , input-output table thbjattr_thbj-attr
      ) no-error .
    for each thbjattr_thbj-attr
    on error undo, return error return-value
    :
      case thbjattr_thbj-attr.prop-code :
        when 'denstclc':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-denstclc = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'expptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-expptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'inpptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-inpptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'autopump':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-autopump = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'rvsnmter':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvsnmter = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'avtinvpm':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-avtinvpm = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'invclipt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-invclipt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'olddens':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-olddens = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'algrvspt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algrvspt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'temp-for-pomi':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-temp-for-pomi = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'algoincome':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algoincome = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'mand-choice-autocar':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-mand-choice-autocar = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-block-nozzle = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'timeout-block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-timeout-block-nozzle = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'Delta-mass-horiz':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-horiz = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'Delta-mass-vert':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-vert = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'calc-free-vol':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'calc-free-vol-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'trn-reas-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-trn-reas-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
              when 'rvd-own-nb':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvd-own-nb = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'qr-scan-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-qr-scan-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'autopump-skip-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-autopump-skip-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
      end case.
      delete thbjattr_thbj-attr .
    end.
  end.
  return .
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gdsoattr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
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
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
function is-sug returns logical
        (input p-gds-code as integer):
define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.
do on error undo, return error:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  'fuel-type':U
      ,output c-value
      ,output c-type) no-error.
end.
result = logical(c-value = 'lgas':U) no-error.
return result.
end function.
function is-gas returns logical
        (input p-gds-code as integer):
define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.
do on error undo, return error:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  'fuel-type':U
      ,output c-value
      ,output c-type) no-error.
end.
result = logical(c-value = 'metan':U) no-error.
return result.
end function.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info11, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info11, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
  define buffer buf_rvs-doc       for ub.rvs-doc .
  define buffer buf_rvs-line      for ub.rvs-line .
  define buffer com_rvs-line      for ub.rvs-line .
  define buffer buf_rvs-line-attr for ub.rvs-line-attr .
  define buffer buf-add_clients   for ub.clients .
  define buffer buf_sysconf       for ub.sysconf .
  define buffer buf_goods         for ub.goods .
  define buffer buf_gds-prt       for ub.gds-prt .
  define buffer buf_prt-obj       for ub.prt-obj .
  define buffer buf_pl-gds        for ub.pl-gds .
  define buffer buf_trn-doc       for ub.trn-doc .
  define buffer buf_doc-line      for ub.doc-line .
  define buffer buf_inv-line      for ub.inv-line .
  define buffer buf_gds-dtl       for ub.gds-dtl .
  define buffer buf_doc-pl        for ub.doc-pl .
  define buffer buf_doc-line-sum  for ub.doc-line-sum .
  define buffer bf_doc-line       for ub.doc-line.
  define buffer bf_inv-line       for ub.inv-line.
  define buffer bf-prev_doc-line  for ub.doc-line.
  define buffer bf-prev_trn-doc   for ub.trn-doc.
  define buffer bf-prev_doc-pl    for ub.doc-pl.
  define buffer bf-wst_trn-doc    for ub.trn-doc.
  define buffer bf-wst_doc-line   for ub.doc-line.
  define buffer bf-wst_inv-line   for ub.inv-line.
  define buffer bf-wst_doc-pl     for ub.doc-pl.
  define buffer buf_sale-doc      for ub.sale-doc .
  define buffer buf_place         for ub.place .
  define buffer buf2_place        for ub.place .
  define temp-table tt-line-for-doc no-undo
    field gds-code      like ub.rvs-line.gds-code
    field pl-code       like ub.rvs-line.pl-code
    field fact-qnty     like ub.doc-pl.fact-qnty
    field fact-cli-qnty like ub.doc-pl.fact-qnty
    index pi is unique primary gds-code pl-code
    .
  define buffer buf_tt-line-for-doc for tt-line-for-doc .
  define buffer buf-spi_trn-doc     for ub.trn-doc .
  define buffer buf-spi_doc-line    for ub.doc-line .
  define buffer buf-spi_inv-line    for ub.inv-line .
  define buffer buf-spi_gds-dtl     for ub.gds-dtl .
  define buffer buf-spi_parts       for ub.parts .
  define buffer buf-spi_doc-pl      for ub.doc-pl .
  define variable chs-gds-inv                   as logical   no-undo.
  define variable vartot-docold                 like ub.trn-doc.tot-doc no-undo.
  define variable vartot-rublold                like ub.trn-doc.tot-rubl no-undo.
  define variable i-total-doc-line_tot-ovold    like ub.trn-doc.tot-ov no-undo.
  define variable i-total-doc-line_fact-rublold like ub.trn-doc.fact-rubl no-undo.
  define variable i-total-doc-line_fact-baseold like ub.trn-doc.fact-base no-undo.
  define variable i-total-doc-line_fact-qntyold like ub.trn-doc.fact-qnty no-undo.
  define variable i-total-doc-line_doc-qntyold  like ub.trn-doc.doc-qnty no-undo.
  define variable i-total-doc-line_cli-qntyold  like ub.trn-doc.cli-qnty no-undo.
  define variable i-total-parts_fact-baseold    as decimal   no-undo.
  define variable i-total-parts_fact-rublold    as decimal   no-undo.
  define variable i-total-parts_fact-qntyold    as decimal   no-undo.
  define variable stfactplvalue                 as character no-undo.
  define variable stfactpltype                  as character no-undo.
  define variable v-reserv-qnty-base            like ub.doc-line.fact-qnty no-undo.
  define variable v-reserv-qnty-cli             like ub.doc-line.cli-qnty no-undo.
  define variable v-chg-qnty                    like ub.doc-line.fact-qnty no-undo.
  define variable v-fact-qnty                   like ub.doc-line.fact-qnty no-undo.
  define variable v-fact-cli-qnty               like ub.doc-line.cli-qnty no-undo.
  define variable varupdate                     as logical   no-undo initial yes.
  define variable varrevision                   as logical   no-undo initial no.
  define variable varpercrev                    as decimal   no-undo initial ?.
  define variable varauto-tank                  as logical   no-undo initial no.
  define variable varpercauto                   as decimal   no-undo initial ?.
  define variable varinv                        as logical   no-undo initial no.
  define variable varpercinv                    as decimal   no-undo initial ?.
  define variable varinv-set                    as logical   no-undo initial no.
  define variable varvalue                      as character no-undo.
  define variable vartype                       as character no-undo.
  define variable v-lgas-gds                    as logical   no-undo.
  define variable O_PKH                         as decimal   no-undo.
  define variable O_FACT                        as decimal   no-undo.
  define variable v-metering-error              as decimal   no-undo.
  define variable v-normal-wastage              as decimal   no-undo.
  define variable v-normal-tp                   as decimal   no-undo.
  define variable v-normal-tp-auto              as decimal   no-undo.
  define variable v-normal-tp-pl                as decimal   no-undo.
  define variable v-normal-wastage-winter       as decimal   no-undo init ?.
  define variable v-normal-wastage-summer       as decimal   no-undo init ?.
  define variable v-norm-wast-decomm            as decimal   no-undo init 0.
  define variable v-rsrv-qnty                   like ub.doc-line.fact-qnty no-undo.
  define variable v-value                       as character no-undo.
  define variable v-ok                          as logical   no-undo.
  define variable logstr                        as character no-undo.
  define variable O_PKH-base                    as decimal   no-undo.
  define variable O_FACT-base                   as decimal   no-undo.
  define variable O_PKH-cli                     as decimal   no-undo.
  define variable O_FACT-cli                    as decimal   no-undo.
  define variable K1                            as decimal   no-undo.
  define variable v-metering-error-base         as decimal   no-undo.
  define variable v-metering-error-cli          as decimal   no-undo.
  define variable v-metering-error-dens         as decimal   no-undo.
  define variable v-metering-qnty-base          as decimal   no-undo .
  define variable v-metering-qnty-cli           as decimal   no-undo .
  define variable K2                            as decimal   no-undo.
  define variable v-normal-wastage-base         as decimal   no-undo.
  define variable v-normal-wastage-cli          as decimal   no-undo.
  define variable v-normal-wastage-dens         as decimal   no-undo .
  define variable K3                            as decimal   no-undo.
  define variable v-metering-pipe-error-base    as decimal   no-undo.
  define variable v-metering-pipe-error-cli     as decimal   no-undo.
  define variable v-metering-pipe-qnty-cli      as decimal   no-undo .
  define variable oNormWast                     as class     ibs.th.ref.normwastsub no-undo.
  define variable v-wastage-qnty-base           as decimal   no-undo .
  define variable v-wastage-qnty-cli            as decimal   no-undo .
  define variable WST-base                      as decimal   no-undo.
  define variable WST-cli                       as decimal   no-undo.
  define variable varfact-order-prev-inv        like ub.trn-doc.fact-order no-undo.
  define variable InfoSecsObj                   as class     InfoSectionsTotal      no-undo.
  define variable v-all-state-measure-qnty as decimal no-undo .
  define variable v-all-state-measure-cli-qnty as decimal no-undo .
  define variable v-avg-state-density as decimal no-undo .
  define variable v-num-tanks as integer no-undo .
  define variable v-all-state-add-cli-qnty as decimal no-undo .
  define variable dM                            as decimal   no-undo.
  define variable dMMBd                         as decimal   no-undo.
  define variable MKN                           as decimal   no-undo.
  define variable MKKN                          as decimal   no-undo.
  define variable MFO                           as decimal   no-undo.
  define variable beta1                         as decimal   no-undo.
  define variable beta2                         as decimal   no-undo.
  define variable MFOT                          as decimal   no-undo.
  define variable MFOR                          as decimal   no-undo.
  define variable MI                            as decimal   no-undo.
  define variable dMPT                          as decimal   no-undo.
  define variable dMPOT                         as decimal   no-undo.
  define variable MPOT                          as decimal   no-undo.
  define variable MNED                          as decimal   no-undo.
  define variable v-par-type                    as character no-undo.
  define variable ii                            as integer   no-undo.
  define variable v-cre-add-docs                as logical   no-undo .
  define variable v-without-mt-err              as logical   no-undo .
  define variable rvsinvsubObj                  as class     rvsinvsub              no-undo.
  define variable rvsinvstrObj                  as class     rvsinvstr              no-undo.
  define variable v-inv-code                    as character no-undo .
  define variable v-spi-code                    as character no-undo .
  define variable v-host-code                   as integer   no-undo .
  define variable v-prt-root                    as integer   no-undo .
  define variable v-recid                       as recid     no-undo .
  define variable v-log                         as logical   no-undo .
  define variable v-type                        as character no-undo .
  define variable v-input-type-p                as character no-undo .
  define variable v-input-type-T                as character no-undo .
  define variable v-input-type-l                as character no-undo .
  define variable v-input-type-err-msg          as character no-undo .
  define variable pl-rvd-dens                   as logical   no-undo .
  define variable pl-rvd-lvl                    as logical   no-undo .
  define variable pl-rvd-temp                   as logical   no-undo .
  define variable rdc-value                     as character no-undo .
  define variable rdc-type                      as character no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  find first buf_rvs-doc
    where rowid( buf_rvs-doc ) = p-rvs-rowid
    .
  if v-cntxt-obj-type <> buf_rvs-doc.obj-type
    or v-cntxt-obj-code <> buf_rvs-doc.obj-code
    then
  do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Сверка &1 резервуаров на объекте &2 &3", buf_rvs-doc.rvs-code, buf_rvs-doc.obj-type, buf_rvs-doc.obj-code ) skip
      substitute("На текущем объекте нельзя создать инвентаризацию по данной сверке." ) skip
      view-as alert-box error .
    return error .
  end.
  logger:Path = "log-rvsinv.log".
  logger:StrLogPut =
    chr(10) +
    "-----------------------------------------------" + chr(10) +
    string (now) + chr(10).
  assign
    v-log = no
    .
  message
    "Вы хотите сделать инвентаризацию по сверке?"    skip
    "ДА     - по всем товарам из сверки"             skip
    "НЕТ    - не делать инвентаризацию"              skip
    "ОТМЕНА - опционально по товарам и резервуарам"
    view-as alert-box buttons yes-no-cancel update v-log.
  if v-log = no then
  do:
    return no-apply.
  end.
  assign
    chs-gds-inv = v-log
    p-docs-info = "":U
    .
  RUN gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", no, output rdc-value, output rdc-type) no-error .
  v-input-type-err-msg = "" .
  if chs-gds-inv
    and rdc-value = "pomi-rn"
    then
  do :
    for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code,
      first buf_place no-lock where buf_place.obj-type = buf_rvs-doc.obj-type
      and buf_place.obj-code = buf_rvs-doc.obj-code
      and buf_place.pl-code = buf_rvs-line.pl-code,
      first buf_goods no-lock where buf_goods.gds-code = buf_rvs-line.gds-code :
      if is-sug(buf_goods.gds-code)
        or is-gas(buf_goods.gds-code)
        then next .
      assign
        v-input-type-p = ""
        v-input-type-T = ""
        v-input-type-l = ""
        .
      for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
        and buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
        and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
        and buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
        and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
        and buf_rvs-line-attr.attr-code = "input-type-p"
        :
        v-input-type-p = buf_rvs-line-attr.attr-value .
      end .
      for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
        and buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
        and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
        and buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
        and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
        and buf_rvs-line-attr.attr-code = "input-type-T"
        :
        v-input-type-T = buf_rvs-line-attr.attr-value .
      end .
      for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
        and buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
        and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
        and buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
        and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
        and buf_rvs-line-attr.attr-code = "input-type-l"
        :
        v-input-type-l = buf_rvs-line-attr.attr-value .
      end .
      run placelib_get-attr  ( input "place-rvd-dnsty"
        ,input buf_rvs-line.obj-code
        ,input buf_rvs-line.obj-type
        ,input buf_rvs-line.pl-code
        ,output v-value
        ,output v-ok      ) no-error.
      if not v-ok then pl-rvd-dens = no.
      else pl-rvd-dens = logical(v-value) .
      run placelib_get-attr  ( input "place-rvd-lvl"
        ,input buf_rvs-line.obj-code
        ,input buf_rvs-line.obj-type
        ,input buf_rvs-line.pl-code
        ,output v-value
        ,output v-ok      ) no-error.
      if not v-ok then pl-rvd-lvl = no.
      else pl-rvd-lvl = logical(v-value) .
      run placelib_get-attr  ( input "place-rvd-tmp"
        ,input buf_rvs-line.obj-code
        ,input buf_rvs-line.obj-type
        ,input buf_rvs-line.pl-code
        ,output v-value
        ,output v-ok      ) no-error.
      if not v-ok then pl-rvd-temp = no.
      else pl-rvd-temp = logical(v-value) .
      if ((v-input-type-p = "р" or v-input-type-p = "ак" or v-input-type-p = "фк" or (v-input-type-p = "а" and not pl-rvd-dens))
        and (v-input-type-T = "р" or v-input-type-T = "ак" or v-input-type-T = "фк" or (v-input-type-T = "а" and not pl-rvd-temp))
        and (v-input-type-l = "р" or v-input-type-l = "ак" or v-input-type-l = "фк" or (v-input-type-l = "а" and not pl-rvd-lvl)))
        then
      do :
      end .
      else
      do:
        v-input-type-err-msg = v-input-type-err-msg + " Резервуар " + string(buf_place.pl-code) + " " + buf_place.pl-name + " с " + buf_goods.gds-name + chr(10) .
        if not (v-input-type-p = "р" or v-input-type-p = "ак" or v-input-type-p = "фк")
          then
        do :
          v-input-type-err-msg = v-input-type-err-msg + "   - Плотность" + chr(10) .
        end .
        if not (v-input-type-T = "р" or v-input-type-T = "ак" or v-input-type-T = "фк")
          then
        do :
          v-input-type-err-msg = v-input-type-err-msg + "   - Температура" + chr(10) .
        end .
        if not (v-input-type-l = "р" or v-input-type-l = "ак" or v-input-type-l = "фк")
          then
        do :
          v-input-type-err-msg = v-input-type-err-msg + "   - Уровень" + chr(10) .
        end .
      end .
    end .
  end .
  if v-input-type-err-msg > ""
    then
  do :
    v-input-type-err-msg = "Невозможно создать инвентаризацию по сверке. Отсутствуют ручные замеры по резервуарам:" + chr(10) + v-input-type-err-msg .
    message v-input-type-err-msg view-as alert-box .
    return no-apply .
  end .
  block_cre-inv :
  do transaction
    on error  undo block_cre-inv, retry block_cre-inv
    on stop   undo block_cre-inv, retry block_cre-inv
    on endkey undo block_cre-inv, retry block_cre-inv
    :
    if retry then
    do:
      assign
        p-docs-info = "":U
        .
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании документа" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo block_cre-inv, leave block_cre-inv .
    end.
    for each tt-line-for-doc
      on error undo block_cre-inv, retry block_cre-inv
      :
      delete tt-line-for-doc .
    end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input buf_rvs-doc.obj-type
  , input buf_rvs-doc.obj-code
  ) .
    if not error-status :error then
    do:
      assign
        v-without-mt-err = ptrlprop-rvsnmter
        .
    end.
    logger:StrLogPut =
      "Настройки секции для " + buf_rvs-doc.obj-type + " " + string(buf_rvs-doc.obj-code) + ": " + chr(10) +
      " - Расхождение в инвентаризации по сверке делать без учета погрешности измерения: " + string(ptrlprop-rvsnmter) + chr(10) +
      " - Настройки инвентаризации по сверке: " + string(ptrlprop-algoincome) + chr(10) +
      " - Температура к которой приводится плотность и объем (°С): " + string(ptrlprop-temp-for-pomi) + chr(10) +
      " - Алгоритм принятия топлива к учету: " + string(ptrlprop-algrvspt) + chr(10) +
      " - Обязательный выбор автотранспорта из справочника: " + string(ptrlprop-mand-choice-autocar) + chr(10) +
      " - Погрешность изм массы для горизонтальных резер: " + string(ptrlprop-Delta-mass-horiz) + chr(10) +
      " - Погрешность изм массы для вертикальных резер: " + string(ptrlprop-Delta-mass-vert) + chr(10) .
    assign
      v-cre-add-docs = false
      .
    if ptrlprop-invclipt <> ? then
    do:
      find first buf-add_clients
        where buf-add_clients.obj-type = 'орг':U
        and buf-add_clients.obj-code = ptrlprop-invclipt
        no-error .
      if available buf-add_clients then
      do:
        assign
          v-cre-add-docs = true
          .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
        find first buf_sysconf no-lock
          where buf_sysconf.host-code = v-host-code
          .
        if buf_sysconf.cons-vat-pc = ? then
        do:
          message
            vss-workfile vss-revision vss-description skip
            "У Вас не установлен НДС для консигнационного товара по фирме." skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo block_cre-inv, retry block_cre-inv .
        end.
      end.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_adinvdoc in g#lib-trn3
(input  v-cntxt-obj-type
,input  v-cntxt-obj-code
,input  v-cntxt-userid
,output v-recid
) .
    find first buf_trn-doc exclusive-lock
      where recid( buf_trn-doc ) = v-recid
      .
    assign
      v-inv-code           = buf_trn-doc.doc-code
      buf_trn-doc.agnt     = buf_rvs-doc.agnt
      buf_trn-doc.wrkr     = buf_rvs-doc.wrkr
      buf_trn-doc.boss     = buf_rvs-doc.boss
      buf_trn-doc.out-code = buf_rvs-doc.rvs-code
      .
    logger:StrLogPut =
      "Создается инвентаризация: " + string(v-inv-code) + chr(10) .
    create ub.inv-doc-attr .
    assign
    ub.inv-doc-attr.doc-code = buf_rvs-doc.rvs-code
    ub.inv-doc-attr.attr-code = "create_date"
    ub.inv-doc-attr.attr-value = string(today)
    .
    create ub.inv-doc-attr .
    assign
    ub.inv-doc-attr.doc-code = buf_rvs-doc.rvs-code
    ub.inv-doc-attr.attr-code = "create_time"
    ub.inv-doc-attr.attr-value = string(time)
    .
    block_rvs-line:
    for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code,
      first buf_place no-lock where buf_place.obj-type = buf_rvs-doc.obj-type
      and buf_place.obj-code = buf_rvs-doc.obj-code
      and buf_place.pl-code = buf_rvs-line.pl-code,
      first buf_goods no-lock where buf_goods.gds-code = buf_rvs-line.gds-code
      on error undo block_cre-inv, retry block_cre-inv
      :
      if is-gas(buf_goods.gds-code)
        then
      do :
        next block_rvs-line.
      end .
      run placelib_get-attr  ( input "place-com-tanks"
        ,input buf_place.obj-code
        ,input buf_place.obj-type
        ,input buf_place.pl-code
        ,output v-value
        ,output v-ok      ) no-error.
      if  v-ok
      and v-value > ""
      then do :
        do ii = 1 to num-entries(v-value) :
          find first buf2_place no-lock where buf2_place.obj-type = buf_rvs-doc.obj-type
                                          and buf2_place.obj-code = buf_rvs-doc.obj-code
                                          and buf2_place.loc1     = entry(ii, v-value)
                                          and buf2_place.status_  = ""
                                          no-error .
          if available buf2_place
          then do :
            find first com_rvs-line where com_rvs-line.gds-code = buf_goods.gds-code
                                      and com_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                      and com_rvs-line.obj-type = buf_rvs-doc.obj-type
                                      and com_rvs-line.obj-code = buf_rvs-doc.obj-code
                                      and com_rvs-line.pl-code  = buf2_place.pl-code
                                      no-error .
            if not available com_rvs-line
            then do :
              message substitute ("Внимание! Не сделана сверка по резервуару №&1, включенному в связку сообщающихся резервуаров! Документ инвентаризации не создан!", buf2_place.loc1)
                view-as alert-box error .
              undo block_cre-inv, leave block_cre-inv .
            end .
          end .
        end .
        run placelib_get-attr  ( input "place-is-main"
          ,input buf_place.obj-code
          ,input buf_place.obj-type
          ,input buf_place.pl-code
          ,output v-value
          ,output v-ok      ) no-error.
        if v-ok and logical(v-value)
          then
        do :
        end .
        else
        do :
          next block_rvs-line.
        end .
      end .
      if chs-gds-inv <> yes then
      do:
        assign
          v-log = no
          .
        message
          substitute( 'Будем проводить инвентаризацию по товару (&1 &2 &3) "&4"', buf_goods.artic, buf_goods.prod-type, buf_goods.prod-code, buf_goods.gds-name ) skip
          substitute( " на месте хранения &1", buf_rvs-line.pl-code ) skip
          substitute( " системное количество &1", buf_rvs-line.system-qnty ) skip
          substitute( " фактический остаток &1?", buf_rvs-line.state-measure-qnty )
          view-as alert-box buttons yes-no update v-log.
        if v-log <> yes then
        do:
          next block_rvs-line.
        end.
        else
        do :
          if rdc-value = "pomi-rn"
            and not is-sug(buf_goods.gds-code)
            then
          do :
            assign
              v-input-type-p = ""
              v-input-type-T = ""
              v-input-type-l = ""
              .
            for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
              and buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
              and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
              and buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
              and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
              and buf_rvs-line-attr.attr-code = "input-type-p"
              :
              v-input-type-p = buf_rvs-line-attr.attr-value .
            end .
            for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
              and buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
              and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
              and buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
              and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
              and buf_rvs-line-attr.attr-code = "input-type-T"
              :
              v-input-type-T = buf_rvs-line-attr.attr-value .
            end .
            for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
              and buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
              and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
              and buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
              and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
              and buf_rvs-line-attr.attr-code = "input-type-l"
              :
              v-input-type-l = buf_rvs-line-attr.attr-value .
            end .
            run placelib_get-attr  ( input "place-rvd-dnsty"
              ,input buf_rvs-line.obj-code
              ,input buf_rvs-line.obj-type
              ,input buf_rvs-line.pl-code
              ,output v-value
              ,output v-ok      ) no-error.
            if not v-ok then pl-rvd-dens = no.
            else pl-rvd-dens = logical(v-value) .
            run placelib_get-attr  ( input "place-rvd-lvl"
              ,input buf_rvs-line.obj-code
              ,input buf_rvs-line.obj-type
              ,input buf_rvs-line.pl-code
              ,output v-value
              ,output v-ok      ) no-error.
            if not v-ok then pl-rvd-lvl = no.
            else pl-rvd-lvl = logical(v-value) .
            run placelib_get-attr  ( input "place-rvd-tmp"
              ,input buf_rvs-line.obj-code
              ,input buf_rvs-line.obj-type
              ,input buf_rvs-line.pl-code
              ,output v-value
              ,output v-ok      ) no-error.
            if not v-ok then pl-rvd-temp = no.
            else pl-rvd-temp = logical(v-value) .
            if ((v-input-type-p = "р" or v-input-type-p = "ак" or v-input-type-p = "фк" or (v-input-type-p = "а" and not pl-rvd-dens))
              and (v-input-type-T = "р" or v-input-type-T = "ак" or v-input-type-T = "фк" or (v-input-type-T = "а" and not pl-rvd-temp))
              and (v-input-type-l = "р" or v-input-type-l = "ак" or v-input-type-l = "фк" or (v-input-type-l = "а" and not pl-rvd-lvl)))
              then
            do :
            end .
            else
            do :
              v-input-type-err-msg = "Невозможно добавить строку. Отсутствуют данные ручных замеров резервуара "
                + string(buf_place.pl-code) + " " + buf_place.pl-name + " с " + buf_goods.gds-name
                + " по параметрам:" + chr(10) .
              if not (v-input-type-p = "р" or v-input-type-p = "ак" or v-input-type-p = "фк")
                then
              do :
                v-input-type-err-msg = v-input-type-err-msg + "   - Плотность" + chr(10) .
              end .
              if not (v-input-type-T = "р" or v-input-type-T = "ак" or v-input-type-T = "фк")
                then
              do :
                v-input-type-err-msg = v-input-type-err-msg + "   - Температура" + chr(10) .
              end .
              if not (v-input-type-l = "р" or v-input-type-l = "ак" or v-input-type-l = "фк")
                then
              do :
                v-input-type-err-msg = v-input-type-err-msg + "   - Уровень" + chr(10) .
              end .
              v-input-type-err-msg = v-input-type-err-msg + chr(10)
                + "Продолжить создание инвентаризации?"
                .
              message
                v-input-type-err-msg
                view-as alert-box buttons yes-no update v-log.
              if not v-log
                then
              do :
                undo block_cre-inv, return .
              end .
              else
              do :
                next block_rvs-line .
              end .
            end .
          end .
        end .
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_adinvlin in g#lib-trn3
(input  parparentproc
,input  v-inv-code
,input  buf_goods.artic
,input  buf_goods.prod-type
,input  buf_goods.prod-code
,output v-recid
) no-error.
      if error-status :error then
      do:
        undo block_cre-inv, retry block_cre-inv.
      end.
      find first buf_doc-line exclusive-lock
        where recid( buf_doc-line ) = v-recid
        .
      assign
        buf_doc-line.doc-density  = buf_rvs-line.state-density
        buf_doc-line.fact-density = buf_doc-line.doc-density
        .
    end.
    find first buf_doc-line no-lock where buf_doc-line.doc-code = v-inv-code no-error .
    if not available buf_doc-line
      then
    do :
      message "В инвентаризацию не добавлен ни один товар!" view-as alert-box .
      undo block_cre-inv, leave block_cre-inv .
    end .
    run close-doc in this-procedure
      ( input v-inv-code
      , input recid( buf_trn-doc )
      ) no-error .
    if error-status :error then
    do:
      undo block_cre-inv, leave block_cre-inv .
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'stfactpl'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output stfactplvalue
  ,output stfactpltype
  ) no-error .
    if not error-status :error
      and stfactplvalue <> ?
      and stfactplvalue <> "?"
      then
    do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_chkqtpl in g#lib-calc
  (  input stfactplvalue
  , output varupdate
  , output varrevision
  , output varpercrev
  , output varauto-tank
  , output varpercauto
  , output varinv
  , output varpercinv
  , output varinv-set
  ) no-error .
      if error-status :error then
      do:
        message
          return-value skip
          error-status :get-message( 1 )
          view-as alert-box.
        undo block_cre-inv, retry block_cre-inv .
      end.
      logger:StrLogPut =
        "Конфигурационный параметр: " + chr(10) +
        " - Определение работы с фактическим количеством бензина во внешнем приходе: " + stfactplvalue + chr(10).
      if varrevision = yes then
      do:
        assign
          K1 = varpercrev.
      end.
      if varauto-tank = yes then
      do:
        assign
          K1 = varpercauto.
      end.
      if varinv = yes then
      do:
        assign
          K1 = varpercinv.
      end.
    end.
    if K1 = ? then
    do:
      assign
        K1 = 0.0
        .
    end.
    define variable K1-all as decimal no-undo.
    K1-all = K1.
    for each buf_doc-line exclusive-lock
      where buf_doc-line.doc-code = v-inv-code
      ,first buf_inv-line exclusive-lock
      where buf_inv-line.doc-code  = buf_doc-line.doc-code
      and buf_inv-line.artic     = buf_doc-line.artic
      and buf_inv-line.prod-type = buf_doc-line.prod-type
      and buf_inv-line.prod-code = buf_doc-line.prod-code
      ,first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
      and buf_goods.prod-type = buf_doc-line.prod-type
      and buf_goods.prod-code = buf_doc-line.prod-code
      on error undo block_cre-inv, retry block_cre-inv
      :
      run gds-attr-value in this-procedure
        (  input buf_goods.gds-code
        ,input 'fuel-type':U
        ,output varvalue
        ,output vartype
        ) .
      if varvalue = "lgas" then
      do:
        v-lgas-gds = true.
      end.
      logger:StrLogPut =
        "Товар: " + string(buf_goods.gds-code) + " " + buf_goods.gds-name .
      K1 = K1-all.
      find first buf_rvs-line no-lock
        where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
        and buf_goods.gds-code = buf_rvs-line.gds-code no-error.
      find first buf_rvs-line-attr where buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
        and buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
        and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
        and buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
        and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
        and buf_rvs-line-attr.attr-code = "delta-mass-qnty" no-lock no-error.
      if available (buf_rvs-line-attr)
        then
      do:
        decimal (buf_rvs-line-attr.attr-value) no-error.
        if not error-status:error
          then
        do:
          if not decimal (buf_rvs-line-attr.attr-value) = 0
            then K1 = decimal (buf_rvs-line-attr.attr-value) no-error.
        end.
      end.
      oNormWast = new normwastsub ().
      oNormWast:ParGdsOAttr:GdsCode = buf_goods.gds-code.
      oNormWast:ParGdsOAttr:ObjType = buf_trn-doc.obj-type.
      oNormWast:ParGdsOAttr:ObjCode = buf_trn-doc.obj-code.
      oNormWast:ParGdsOAttr:OnDate = if buf_trn-doc.fact-date <> ? then buf_trn-doc.fact-date else buf_trn-doc.doc-date.
      oNormWast:FillNormWast().
      if error-status:error
        and not v-lgas-gds
        and not is-gas(buf_goods.gds-code)
        then
      do:
        message
          "ОШИБКА при определние нормы естественной убыли." skip
          "По строке товара : " buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code " " buf_goods.gds-name skip
          "на объекте: " buf_trn-doc.obj-type " " buf_trn-doc.obj-code
          skip
          view-as alert-box error.
        undo block_cre-inv, retry block_cre-inv.
      end.
      v-normal-wastage = oNormWast:NormalWastageDate.
      logger:StrLogPut =
        " Норма естественной убыли = " + string(v-normal-wastage) .
      if v-normal-wastage = ? then
      do:
        assign
          K2 = 0.0
          .
      end.
      else
      do:
        assign
          K2 = v-normal-wastage
          .
      end.
      run placelib_get-attr  (
        input "place-error-mass"
        ,input buf_rvs-line.obj-code
        ,input buf_rvs-line.obj-type
        ,input buf_rvs-line.pl-code
        ,output v-value
        ,output v-ok      ) no-error.
      if v-ok then
      do:
        K3 = decimal(v-value).
        logger:StrLogPut =
          " Погрешность измерения массы = " + string(K3) .
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclcinv in g#lib-trn2
(
input        'old':U,
input        recid(buf_doc-line),
input        v-inv-code,
input-output vartot-docold,
input-output vartot-rublold,
input-output i-total-doc-line_tot-ovold,
input-output i-total-doc-line_fact-rublold,
input-output i-total-doc-line_fact-baseold,
input-output i-total-doc-line_fact-qntyold,
input-output i-total-doc-line_doc-qntyold,
input-output i-total-doc-line_cli-qntyold,
input-output i-total-parts_fact-baseold,
input-output i-total-parts_fact-rublold,
input-output i-total-parts_fact-qntyold
) no-error.
      if error-status :error then
      do:
        undo block_cre-inv, retry block_cre-inv.
      end.
      assign
        buf_inv-line.wast-cli-qnty  = buf_inv-line.before-cli-qnty
        buf_inv-line.after-cli-qnty = buf_inv-line.before-cli-qnty
        .
      logger:StrLogPut =
        " Количество естеств. убыли в единицах клиента = " + string(buf_inv-line.wast-cli-qnty) + chr(10) +
        " Количество после инвентаризации в единицах клиента = " + string(buf_inv-line.after-cli-qnty) + chr(10).
      find first buf_gds-prt no-lock
        where buf_gds-prt.upper-code = buf_goods.prt-root
        .
      if not v-cntxp-doc-prt
        or buf_gds-prt.node-name = '_Пустая шкала':U
        then
      do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsdtlcr in g#library
  (input  buf_gds-prt.node-code
  ,buffer buf_doc-line
  ,buffer buf_gds-dtl
  ) no-error .
        if error-status :error then
        do:
          undo block_cre-inv, retry block_cre-inv.
        end.
        find first buf_prt-obj no-lock
          where buf_prt-obj.prt-code  = buf_gds-prt.node-code
          and buf_prt-obj.prod-code = buf_goods.prod-code
          and buf_prt-obj.prod-type = buf_goods.prod-type
          and buf_prt-obj.artic     = buf_goods.artic
          and buf_prt-obj.obj-code  = buf_trn-doc.obj-code
          and buf_prt-obj.obj-type  = buf_trn-doc.obj-type
          no-error.
        assign
          buf_gds-dtl.doc-qnty  = 0
          buf_gds-dtl.fact-qnty = ( if available buf_prt-obj then buf_prt-obj.fact-qnty else 0 )
          .
        if buf_doc-line.doc-qnty <> buf_gds-dtl.fact-qnty then
        do:
          message
            "ОШИБКА" skip
            "Кол-во товара по строке : " buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code " " buf_goods.gds-name skip
            "на объекте: " buf_trn-doc.obj-type " " buf_trn-doc.obj-code " , равное " buf_doc-line.doc-qnty skip
            " не совпадает с кол-ом по корневому признаку, равном " buf_gds-dtl.fact-qnty "." skip
            view-as alert-box error.
          undo block_cre-inv, retry block_cre-inv.
        end.
        block_doc-pl:
        for each buf_doc-pl exclusive-lock
          where buf_doc-pl.out-code = v-inv-code
          and buf_doc-pl.gds-code = buf_goods.gds-code
          and buf_doc-pl.obj-type = buf_trn-doc.obj-type
          and buf_doc-pl.obj-code = buf_trn-doc.obj-code
          ,each buf_rvs-line no-lock
          where buf_rvs-line.gds-code = buf_doc-pl.gds-code
          and buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
          and buf_rvs-line.obj-type = buf_doc-pl.obj-type
          and buf_rvs-line.obj-code = buf_doc-pl.obj-code
          and buf_rvs-line.pl-code  = buf_doc-pl.pl-code
          on error undo block_cre-inv, retry block_cre-inv
          :
          find first buf_pl-gds no-lock
            where buf_pl-gds.obj-type = buf_rvs-line.obj-type
            and buf_pl-gds.obj-code = buf_rvs-line.obj-code
            and buf_pl-gds.pl-code  = buf_rvs-line.pl-code
            and buf_pl-gds.gds-code = buf_rvs-line.gds-code
            no-error.
          if available buf_pl-gds then
          do:
            assign
              v-fact-qnty     = buf_pl-gds.fact-qnty
              v-fact-cli-qnty = buf_pl-gds.cli-fact-qnty
              .
          end.
          else
          do:
            assign
              v-fact-qnty     = 0.0
              v-fact-cli-qnty = 0.0
              .
          end.
          assign
            v-all-state-measure-qnty = 0.0
            v-all-state-measure-cli-qnty = 0.0
            v-avg-state-density = 0.0
            v-all-state-add-cli-qnty = 0.0
            v-num-tanks = 1
          .
          assign
            O_PKH-base            = v-fact-qnty
            O_FACT-base           = buf_rvs-line.state-measure-qnty + buf_rvs-line.state-add-qnty
            O_PKH-cli             = v-fact-cli-qnty
            O_FACT-cli            = buf_rvs-line.state-measure-cli-qnty + buf_rvs-line.state-add-qnty * buf_rvs-line.state-density
            v-all-state-measure-qnty = buf_rvs-line.state-measure-qnty
            v-all-state-measure-cli-qnty = buf_rvs-line.state-measure-cli-qnty
            v-all-state-add-cli-qnty = buf_rvs-line.state-add-qnty * buf_rvs-line.state-density
            v-avg-state-density   = buf_rvs-line.state-density
            v-metering-qnty-base  = 0.0
            v-metering-qnty-cli   = 0.0
            v-normal-wastage-base = 0.0
            v-normal-wastage-cli  = 0.0
            v-normal-wastage-dens = 1 / buf_goods.cli-base-rate
            v-wastage-qnty-base   = 0.0
            v-wastage-qnty-cli    = 0.0
            v-reserv-qnty-base    = 0.0
            v-reserv-qnty-cli     = 0.0
            v-normal-tp           = 0.0
            v-normal-tp-auto      = 0.0
            v-normal-tp-pl        = 0.0
            .
          logger:StrLogPut =
            " Складское место - " + string(buf_doc-pl.pl-code) + chr(10) +
            "  - Объем расчетно-книжный (л) = " + string(if O_PKH-base <> ? then O_PKH-base else 0) + chr(10) +
            "  - Объем НП, включая трубопровод (л) = " + string(if O_FACT-base <> ? then O_FACT-base else 0) + chr(10) +
            "  - Масса расчетно-книжная (кг) = " + string(if O_PKH-cli <> ? then O_PKH-cli else 0) + chr(10) +
            "  - Масса НП, включая трубопровод (кг) = " + string(if O_FACT-cli <> ? then O_FACT-cli else 0) + chr(10)
            .
          run placelib_get-attr  ( input "place-com-tanks"
            ,input buf_doc-pl.obj-code
            ,input buf_doc-pl.obj-type
            ,input buf_doc-pl.pl-code
            ,output v-value
            ,output v-ok      ) no-error.
          if v-ok
          and v-value > ""
          then do :
            do ii = 1 to num-entries(v-value) :
              find first buf_place no-lock where buf_place.obj-type = buf_pl-gds.obj-type
                and buf_place.obj-code = buf_pl-gds.obj-code
                and buf_place.loc1     = entry(ii, v-value)
                and buf_place.status_  = ""
                no-error .
              if available buf_place
              then do :
                find first com_rvs-line where com_rvs-line.gds-code = buf_doc-pl.gds-code
                  and com_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                  and com_rvs-line.obj-type = buf_doc-pl.obj-type
                  and com_rvs-line.obj-code = buf_doc-pl.obj-code
                  and com_rvs-line.pl-code  = buf_place.pl-code
                  no-error .
                if not available com_rvs-line
                then do :
                  message substitute ("Внимание! Не сделана сверка по резервуару №&1, включенному в связку сообщающихся резервуаров! Документ инвентаризации не создан!", buf_place.loc1)
                    view-as alert-box error .
                  undo block_cre-inv, leave block_cre-inv .
                end .
                else do :
                  assign
                    O_FACT-base = O_FACT-base + (com_rvs-line.state-measure-qnty + com_rvs-line.state-add-qnty)
                    O_FACT-cli  = O_FACT-cli + (com_rvs-line.state-measure-cli-qnty + com_rvs-line.state-add-qnty * com_rvs-line.state-density)
                    v-all-state-measure-qnty      = v-all-state-measure-qnty + com_rvs-line.state-measure-qnty
                    v-all-state-measure-cli-qnty  = v-all-state-measure-cli-qnty + com_rvs-line.state-measure-cli-qnty
                    v-avg-state-density           = v-avg-state-density + com_rvs-line.state-density
                    v-all-state-add-cli-qnty      = v-all-state-add-cli-qnty + (buf_rvs-line.state-add-qnty * buf_rvs-line.state-density)
                    v-num-tanks = v-num-tanks + 1
                  .
                end .
              end .
            end .
            assign v-avg-state-density = v-avg-state-density / v-num-tanks .
          end .
          if not v-lgas-gds
            and not is-gas(buf_goods.gds-code)
            then
          do:
            assign
              v-metering-error-base = K1 / 100 * v-all-state-measure-qnty
              v-metering-error-cli  = K1 / 100 * v-all-state-measure-cli-qnty
              v-metering-error-dens = v-avg-state-density
              .
          end.
          else
          do:
            assign
              v-metering-error-base = 0
              v-metering-error-cli  = 0
              v-metering-error-dens = 0
              .
          end.
          logger:StrLogPut =
            "    Погрешность:" + chr(10) +
            "    - в литрах: " + string(if v-metering-error-base <> ? then v-metering-error-base else 0) + chr(10) +
            "    - в кг: " + string(if v-metering-error-cli <> ? then v-metering-error-cli else 0) + chr(10)
            .
          if ptrlprop-expptrl = 'weight':U then
          do:
            assign
              O_FACT           = O_FACT-cli
              O_PKH            = O_PKH-cli
              v-metering-error = v-metering-error-cli
              .
            logger:StrLogPut =
              "Работаем относительно килограммов" + chr(10)
              .
          end.
          else
          do:
            assign
              O_FACT           = O_FACT-base
              O_PKH            = O_PKH-base
              v-metering-error = v-metering-error-base
              .
            logger:StrLogPut =
              "Работаем относительно литров" + chr(10)
              .
          end.
          if not v-lgas-gds
            and not is-gas(buf_goods.gds-code)
            and not ptrlprop-algrvspt = 4
            then
          do:
            if (O_PKH - O_FACT) <= 0  then
            do:
              logger:StrLogPut =
                "Излишки" + chr(10)
                .
              if (O_FACT - O_PKH) - v-metering-error <= 0 then
              do:
                assign
                  v-rsrv-qnty          = 0
                  v-metering-qnty-base = v-metering-error-base
                  v-metering-qnty-cli  = v-metering-error-cli
                  .
                logger:StrLogPut =
                  "Все укладывается в погрешность " + string(if v-metering-error <> ? then v-metering-error else 0) + chr(10) +
                  "погрешность в кг   " + string(if v-metering-qnty-base <> ? then v-metering-qnty-base else 0) + chr(10) +
                  "погрешность в литрах   " + string(if v-metering-qnty-cli <> ? then v-metering-qnty-cli else 0) + chr(10).
                case ptrlprop-algrvspt :
                  when 1 then
                    do:
                    end.
                  when 2 then
                    do:
                      if v-metering-error > (O_FACT - O_PKH) then
                      do:
                        if ptrlprop-expptrl = 'weight':U then
                        do:
                          assign
                            v-metering-error-cli  = (O_FACT-cli - O_PKH-cli)
                            v-metering-error-base = v-metering-error-cli / v-metering-error-dens
                            .
                          logger:StrLogPut =
                            "Алгоритм №2 для литров" + chr(10) +
                            "погрешность в кг   " + string(if v-metering-qnty-base <> ? then v-metering-qnty-base else 0) + chr(10) +
                            "погрешность в литрах   " + string(if v-metering-qnty-cli <> ? then v-metering-qnty-cli else 0) + chr(10) .
                        end.
                        else
                        do:
                          assign
                            v-metering-error-base = (O_FACT-base - O_PKH-base)
                            v-metering-error-cli  = v-metering-error-base * v-metering-error-dens
                            .
                          logger:StrLogPut =
                            "Алгоритм №2 для кг" + chr(10) +
                            "погрешность в кг   " + string(if v-metering-qnty-base <> ? then v-metering-qnty-base else 0) + chr(10) +
                            "погрешность в литрах   " + string(if v-metering-qnty-cli <> ? then v-metering-qnty-cli else 0) + chr(10) .
                        end.
                      end.
                    end.
                  when 4 then
                    do:
                    end.
                end case.
              end.
              else
              do:
                assign
                  v-rsrv-qnty          = (O_FACT - O_PKH) - (if v-without-mt-err = true then 0 else v-metering-error)
                  v-metering-qnty-base = (if v-without-mt-err = true then 0 else v-metering-error-base)
                  v-metering-qnty-cli  = (if v-without-mt-err = true then 0 else v-metering-error-cli )
                  .
                logger:StrLogPut =
                  "В погрешность не укладывается, пересчитываем по алгоритму" + chr(10) +
                  "кол-во   " + string(if v-rsrv-qnty <> ? then v-rsrv-qnty else 0) + chr(10) +
                  "погрешность в кг   " + string(if v-metering-qnty-base <> ? then v-metering-qnty-base else 0) + chr(10) +
                  "погрешность в литрах   " + string(if v-metering-qnty-cli <> ? then v-metering-qnty-cli else 0) + chr(10) .
              end.
            end.
            else
            do:
              if K2 <> 0 then
              do:
                assign
                  WST-base = 0.0
                  WST-cli  = 0.0
                  .
                logger:StrLogPut =
                  "Недостача" + chr(10) +
                  "Ищем предыдущую инвентарзацию" + chr(10)
                  .
                find last bf-prev_doc-line no-lock
                  where bf-prev_doc-line.obj-type     = buf_doc-line.obj-type
                  and bf-prev_doc-line.obj-code     = buf_doc-line.obj-code
                  and bf-prev_doc-line.prod-type    = buf_doc-line.prod-type
                  and bf-prev_doc-line.prod-code    = buf_doc-line.prod-code
                  and bf-prev_doc-line.artic        = buf_doc-line.artic
                  and bf-prev_doc-line.ext-doc-type = 'vt':U
                  and bf-prev_doc-line.status_      = 'факт':U
                  use-index dt-fo
                  no-error.
                if available bf-prev_doc-line then
                do:
                  assign
                    varfact-order-prev-inv = bf-prev_doc-line.fact-order
                    .
                  find first bf-prev_doc-pl no-lock
                    where bf-prev_doc-pl.obj-type = bf-prev_doc-line.obj-type
                    and bf-prev_doc-pl.obj-code = bf-prev_doc-line.obj-code
                    and bf-prev_doc-pl.pl-code  = buf_rvs-line.pl-code
                    and bf-prev_doc-pl.out-code = bf-prev_doc-line.doc-code
                    and bf-prev_doc-pl.gds-code = buf_rvs-line.gds-code
                    no-error.
                  if ptrlprop-algrvspt = 3 and oNormWast:IsDecommissioned
                    then
                  do:
                    find first bf-prev_trn-doc no-lock where bf-prev_trn-doc.doc-code = bf-prev_doc-line.doc-code.
                    oNormWast:ParGdsOAttr:ToInvDate = buf_rvs-doc.fact-date.
                    oNormWast:ParGdsOAttr:FromInvDate =  if bf-prev_trn-doc.fact-date <> ? then bf-prev_trn-doc.fact-date else bf-prev_trn-doc.doc-date.
                    oNormWast:ParGdsOAttr:FromInvFQKg = bf-prev_doc-pl.cli-rest-af-qnty.
                    oNormWast:ParGdsOAttr:PlCode = buf_rvs-line.pl-code.
                    oNormWast:FillNormWast().
                  end.
                  logger:StrLogPut =
                    "Алгоритм " + string(ptrlprop-algrvspt) + chr(10) +
                    "Естественная убыль - " + string(oNormWast:IsDecommissioned) + chr(10)
                    .
                end.
                else
                do:
                  assign
                    varfact-order-prev-inv = 0
                    .
                end.
                if ptrlprop-algrvspt = 3
                  then
                do:
                  logger:StrLogPut =
                    "Технологические потери по документам ПН в межинвентаризационный период (если есть)" +
                    "Объект: " + buf_rvs-line.obj-type + string (buf_rvs-line.obj-code) + chr(10) +
                    "Товар: " + string (buf_goods.gds-code) + " - " + buf_goods.gds-name
                    .
                  for each bf-wst_doc-line no-lock
                    where ( bf-wst_doc-line.obj-type         = buf_doc-line.obj-type
                    and bf-wst_doc-line.obj-code     = buf_doc-line.obj-code
                    and bf-wst_doc-line.prod-type    = buf_doc-line.prod-type
                    and bf-wst_doc-line.prod-code    = buf_doc-line.prod-code
                    and bf-wst_doc-line.artic        = buf_doc-line.artic
                    and
                    (
                    (bf-wst_doc-line.ext-doc-type <> 'vt':U and bf-wst_doc-line.ext-doc-type <> 'vp':U and oNormWast:IsDecommissioned)
                    or
                    (bf-wst_doc-line.ext-doc-type = 'ie':U and not oNormWast:IsDecommissioned)
                    )
                    and bf-wst_doc-line.status_      = 'факт':U
                    and bf-wst_doc-line.fact-order   > varfact-order-prev-inv
                    )
                    on error undo block_cre-inv, retry block_cre-inv
                    :
                    if oNormWast:IsDecommissioned
                      then
                    do:
                      find first bf-wst_trn-doc no-lock where bf-wst_trn-doc.doc-code = bf-wst_doc-line.doc-code.
                      find first bf-wst_doc-pl no-lock
                        where bf-wst_doc-pl.obj-type = bf-wst_doc-line.obj-type
                        and bf-wst_doc-pl.obj-code = bf-wst_doc-line.obj-code
                        and bf-wst_doc-pl.pl-code  = buf_rvs-line.pl-code
                        and bf-wst_doc-pl.out-code = bf-wst_doc-line.doc-code
                        and bf-wst_doc-pl.gds-code = buf_rvs-line.gds-code
                        no-error.
                      if available (bf-wst_doc-pl)
                        then
                      do:
                        if bf-wst_trn-doc.doc-type = 'при':U
                          then oNormWast:NormalWastageHdnler:RegDoc(bf-wst_trn-doc.fact-date, bf-wst_doc-pl.cli-fact-qnty).
                        else oNormWast:NormalWastageHdnler:RegDoc(bf-wst_trn-doc.fact-date, - bf-wst_doc-pl.cli-fact-qnty).
                      end.
                    end.
                    if  bf-wst_doc-line.ext-doc-type = 'ie':U
                      then
                    do:
                      InfoSecsObj = new InfoSectionsTotal ().
                      find first ub.place no-lock where ub.place.pl-code = buf_rvs-line.pl-code
                        and ub.place.obj-code = buf_rvs-line.obj-code and ub.place.obj-type = buf_rvs-line.obj-type no-error.
                      def var listSecLoc as char no-undo.
                      if available (ub.place)
                        then
                      do:
                        InfoSecsObj:Initialization(bf-wst_doc-line.doc-code, buf_goods.gds-code).
                        InfoSecsObj:GetDBAllAttr().
                        InfoSecsObj:CalculateTotal().
                        listSecLoc = InfoSecsObj:GetInfoSectionProp(ub.place.loc1).
                        if listSecLoc <> ""
                          then
                        do:
                          do ii = 1 to num-entries (listSecLoc, chr(4)):
                            InfoSecsObj:GetInfoSectionProp(integer (entry (ii, listSecLoc, chr(4) ))).
                            logger:StrLogPut =
                              "Номер ПН: " + bf-wst_doc-line.doc-code + chr(10) +
                              "Место хранения:" + string (ub.place.pl-code) + " - " + ub.place.pl-name + chr(10) +
                              "Потери при сливе в резервуар: " + string (InfoSecsObj:InfoSectionCurr:TPNormPL) + chr(10) +
                              "Потери при сливе из АЦ: " + string (InfoSecsObj:InfoSectionCurr:TPNormAuto) + chr(10) +
                              "Сумма технолог. потерь: " + string (InfoSecsObj:InfoSectionCurr:TPNorm) + chr(10)
                              .
                            v-normal-tp = v-normal-tp + InfoSecsObj:InfoSectionCurr:TPNorm.
                            v-normal-tp-auto = v-normal-tp-auto + round (InfoSecsObj:InfoSectionCurr:TPNormAuto, 0).
                            v-normal-tp-pl = v-normal-tp-pl + round (InfoSecsObj:InfoSectionCurr:TPNormPL, 0).
                          end.
                        end.
                      end.
                    end.
                  end.
                  if oNormWast:IsDecommissioned
                    then
                  do:
                    oNormWast:CalcWastNorm().
                    logger:StrLogPut =
                      "Норма естественной убыли хранения " + string (oNormWast:NormWastDays)
                      .
                  end.
                end.
                else
                do:
                  for each bf-wst_doc-line no-lock
                    where ( bf-wst_doc-line.obj-type         = buf_doc-line.obj-type
                    and bf-wst_doc-line.obj-code     = buf_doc-line.obj-code
                    and bf-wst_doc-line.prod-type    = buf_doc-line.prod-type
                    and bf-wst_doc-line.prod-code    = buf_doc-line.prod-code
                    and bf-wst_doc-line.artic        = buf_doc-line.artic
                    and bf-wst_doc-line.ext-doc-type = 'ie':U
                    and bf-wst_doc-line.status_      = 'факт':U
                    and bf-wst_doc-line.fact-order   > varfact-order-prev-inv
                    and (not can-find (first buf_sale-doc
                    where buf_sale-doc.doc-code = bf-wst_doc-line.doc-code
                    and buf_sale-doc.doc-kind = 'itr':U))
                    )
                    or
                    ( bf-wst_doc-line.obj-type         = buf_doc-line.obj-type
                    and bf-wst_doc-line.obj-code     = buf_doc-line.obj-code
                    and bf-wst_doc-line.prod-type    = buf_doc-line.prod-type
                    and bf-wst_doc-line.prod-code    = buf_doc-line.prod-code
                    and bf-wst_doc-line.artic        = buf_doc-line.artic
                    and bf-wst_doc-line.ext-doc-type = 'ep':U
                    and bf-wst_doc-line.status_      = 'факт':U
                    and bf-wst_doc-line.fact-order   > varfact-order-prev-inv
                    )
                    on error undo block_cre-inv, retry block_cre-inv
                    :
                    find first bf-wst_doc-pl no-lock
                      where bf-wst_doc-pl.obj-type = bf-wst_doc-line.obj-type
                      and bf-wst_doc-pl.obj-code = bf-wst_doc-line.obj-code
                      and bf-wst_doc-pl.pl-code  = buf_rvs-line.pl-code
                      and bf-wst_doc-pl.out-code = bf-wst_doc-line.doc-code
                      and bf-wst_doc-pl.gds-code = buf_rvs-line.gds-code
                      no-error.
                    if available bf-wst_doc-pl then
                    do:
                      assign
                        WST-base = WST-base + (if bf-wst_doc-line.ext-doc-type = 'ie':U then bf-wst_doc-pl.fact-qnty else - bf-wst_doc-pl.fact-qnty)
                        WST-cli  = WST-cli + (if bf-wst_doc-line.ext-doc-type = 'ie':U then bf-wst_doc-pl.cli-fact-qnty else - bf-wst_doc-pl.cli-fact-qnty )
                        .
                    end.
                  end.
                end.
                assign
                  v-normal-wastage-base = WST-base * K2 / 1000
                  v-normal-wastage-cli  = WST-cli  * K2 / 1000
                  v-normal-wastage-dens = WST-cli / WST-base
                  .
                logger:StrLogPut =
                  "Норма естественной убыли" + chr(10) +
                  "в килограммах: " + string(if v-normal-wastage-cli <> ? then v-normal-wastage-cli else 0) + chr(10) +
                  "в литрах: " + string(if v-normal-wastage-base <> ? then v-normal-wastage-base else 0) + chr(10) +
                  "плотность: " + string(if v-normal-wastage-dens <> ? then v-normal-wastage-dens else 0) + chr(10)
                  .
              end.
              if ptrlprop-expptrl = 'weight':U then
              do:
                if v-normal-wastage-cli <= 0.0 then
                do:
                  assign
                    v-normal-wastage-base = 0.0
                    v-normal-wastage-cli  = 0.0
                    .
                end.
                else
                do:
                  if v-normal-wastage-cli > (O_PKH-cli - O_FACT-cli) then
                  do:
                    assign
                      v-normal-wastage-cli  = (O_PKH-cli - O_FACT-cli)
                      v-normal-wastage-base = v-normal-wastage-cli / v-normal-wastage-dens
                      .
                  end.
                end.
                assign
                  v-normal-wastage = v-normal-wastage-cli
                  .
              end.
              else
              do:
                if v-normal-wastage-base <= 0.0 then
                do:
                  assign
                    v-normal-wastage-base = 0.0
                    v-normal-wastage-cli  = 0.0
                    .
                end.
                else
                do:
                  if v-normal-wastage-base > (O_PKH-base - O_FACT-base) then
                  do:
                    assign
                      v-normal-wastage-base = (O_PKH-base - O_FACT-base)
                      v-normal-wastage-cli  = v-normal-wastage-base * v-normal-wastage-dens
                      .
                  end.
                end.
                assign
                  v-normal-wastage = v-normal-wastage-base
                  .
              end.
              assign
                v-wastage-qnty-base = v-normal-wastage-base
                v-wastage-qnty-cli  = v-normal-wastage-cli
                .
              case ptrlprop-algrvspt :
                when 1 then
                  do:
                    if (O_PKH - O_FACT) - v-metering-error - v-normal-wastage <= 0 then
                    do:
                      logger:StrLogPut =
                        "Все укладывается в погрешность " + string(if v-metering-error <> ? then v-metering-error else 0) + " + естественную убыль: "
                        +  string(if v-normal-wastage <> ? then v-normal-wastage else 0) + chr(10) .
                      .
                      assign
                        v-rsrv-qnty          = 0.0
                        v-metering-qnty-base = v-metering-error-base
                        v-metering-qnty-cli  = v-metering-error-cli
                        .
                      if v-normal-wastage > 0 then
                      do:
                        if (O_PKH - O_FACT) - v-metering-error > 0 then
                        do:
                          logger:StrLogPut =
                            "В погрешность не укладывается, поэтому учитываем естественную убыль " +  string(if v-normal-wastage <> ? then v-normal-wastage else 0) + chr(10) .
                          .
                          if v-normal-wastage > (O_PKH - O_FACT) - v-metering-error then
                          do:
                            logger:StrLogPut =
                              "Уменьшим естественную убыль, чтобы дельта РКН и ФАКТ была равна погрешности измерения " + chr(10) .
                            if ptrlprop-expptrl = 'weight':U then
                            do:
                              assign
                                v-normal-wastage-cli  = (O_PKH-cli - O_FACT-cli) - v-metering-error-cli
                                v-normal-wastage-base = v-normal-wastage-cli / v-normal-wastage-dens
                                .
                              logger:StrLogPut =
                                "Естественная убыль: " + string(if v-normal-wastage-cli <> ? then v-normal-wastage-cli else 0) + " "
                                + string(if v-normal-wastage-base <> ? then v-normal-wastage-base else 0) + chr(10) .
                            end.
                            else
                            do:
                              assign
                                v-normal-wastage-base = (O_PKH-base - O_FACT-base) - v-metering-error-base
                                v-normal-wastage-cli  = v-normal-wastage-base * v-normal-wastage-dens
                                .
                              logger:StrLogPut =
                                "Естественная убыль: " + string(if v-normal-wastage-cli <> ? then v-normal-wastage-cli else 0) + " "
                                + string(if v-normal-wastage-base <> ? then v-normal-wastage-base else 0) + chr(10) .
                            end.
                          end.
                        end.
                        else
                        do:
                          logger:StrLogPut =
                            "Все укладывается в погрешность" + chr(10) .
                          assign
                            v-normal-wastage-cli  = 0.0
                            v-normal-wastage-base = 0.0
                            .
                        end.
                      end.
                    end.
                    else
                    do:
                      logger:StrLogPut =
                        "В погрешность не укладывается, пересчитываем по алгоритму" .
                      assign
                        v-rsrv-qnty          = - ( (O_PKH - O_FACT)
                                                  - (if v-cre-add-docs   = true then v-normal-wastage else 0.0)
                                                  - (if v-without-mt-err = true then 0.0 else v-metering-error)
                                                )
                        v-metering-qnty-base = (if v-without-mt-err = true then 0 else v-metering-error-base)
                        v-metering-qnty-cli  = (if v-without-mt-err = true then 0 else v-metering-error-cli )
                        .
                      logger:StrLogPut =
                        "Кол-во: v-rsrv-qnty " + string(if v-rsrv-qnty <> ? then v-rsrv-qnty else 0) + chr(10) +
                        "Погрешность v-metering-qnty-base " + string(if v-metering-qnty-base <> ? then v-metering-qnty-base else 0) + chr(10) +
                        "Погрешность v-metering-qnty-cli" + string(if v-metering-qnty-cli <> ? then v-metering-qnty-cli else 0) + chr(10)
                        .
                    end.
                  end.
                when 2 then
                  do:
                    if v-normal-wastage = (O_PKH - O_FACT) then
                    do:
                      assign
                        v-rsrv-qnty          = - ( (O_PKH - O_FACT)
                                        - (if v-cre-add-docs = true then v-normal-wastage else 0.0)
                                      )
                        v-metering-qnty-base = 0.0
                        v-metering-qnty-cli  = 0.0
                        .
                      logger:StrLogPut =
                        "Естественная убыль покрыла разницу" + string(if v-normal-wastage <> ? then v-normal-wastage else 0) + chr(10) +
                        "Кол-во: v-rsrv-qnty " + string(if v-rsrv-qnty <> ? then v-rsrv-qnty else 0) + chr(10) +
                        "Погрешность v-metering-qnty-base " + string(if v-metering-qnty-base <> ? then v-metering-qnty-base else 0) + chr(10) +
                        "Погрешность v-metering-qnty-cli " + string(if v-metering-qnty-cli <> ? then v-metering-qnty-cli else 0) + chr(10)
                        .
                    end.
                    else
                    do:
                      if (O_PKH - O_FACT) - v-metering-error - v-normal-wastage <= 0 then
                      do:
                        logger:StrLogPut =
                          "Все укладывается в погрешность " + string(if v-metering-error <> ? then v-metering-error else 0) + " + естественную убыль: " +
                          string(if v-normal-wastage <> ? then v-normal-wastage else 0) + chr(10) .
                        if v-metering-error > (O_PKH - O_FACT) - v-normal-wastage  then
                        do:
                          if ptrlprop-expptrl = 'weight':U then
                          do:
                            assign
                              v-metering-error-cli  = (O_PKH-cli - O_FACT-cli) - v-normal-wastage-cli
                              v-metering-error-base = v-metering-error-cli / v-metering-error-dens
                              v-metering-error      = v-metering-error-cli
                              .
                          end.
                          else
                          do:
                            assign
                              v-metering-error-base = (O_PKH-base - O_FACT-base) - v-normal-wastage-base
                              v-metering-error-cli  = v-metering-error-base * v-metering-error-dens
                              v-metering-error      = v-metering-error-base
                              .
                          end.
                          logger:StrLogPut =
                            "уменьшим погрешность измерения, чтобы она была не больше дельты РКН и ФАКТ с учетом ЕУ" + chr(10) +
                            "Погрешность v-metering-error-base " + string(if v-metering-error-base <> ? then v-metering-error-base else 0) + chr(10) +
                            "Погрешность v-metering-error-cli " + string(if v-metering-error-cli <> ? then v-metering-error-cli else 0) + chr(10) +
                            "Погрешность v-metering-error " + string(if v-metering-error <> ? then v-metering-error else 0) + chr(10)
                            .
                        end.
                        assign
                          v-rsrv-qnty          = - ( (O_PKH - O_FACT)
                                          - (if v-cre-add-docs = true then v-normal-wastage else 0.0)
                                          - v-metering-error
                                        )
                          v-metering-qnty-base = v-metering-error-base
                          v-metering-qnty-cli  = v-metering-error-cli
                          .
                        logger:StrLogPut =
                          "Кол-во: v-rsrv-qnty " + string(if v-rsrv-qnty <> ? then v-rsrv-qnty else 0) + chr(10) +
                          "Погрешность v-metering-qnty-base " + string(if v-metering-qnty-base <> ? then v-metering-qnty-base else 0) + chr(10) +
                          "Погрешность v-metering-qnty-cli" + string(if v-metering-qnty-cli <> ? then v-metering-qnty-cli else 0) + chr(10)
                          .
                      end.
                      else
                      do:
                        assign
                          v-rsrv-qnty          = - ( (O_PKH - O_FACT)
                                                    - (if v-cre-add-docs   = true then v-normal-wastage else 0.0)
                                                    - (if v-without-mt-err = true then 0.0 else v-metering-error)
                                                  )
                          v-metering-qnty-base = (if v-without-mt-err = true then 0 else v-metering-error-base)
                          v-metering-qnty-cli  = (if v-without-mt-err = true then 0 else v-metering-error-cli )
                          .
                        logger:StrLogPut =
                          "в погрешность не укладывается, пересчитываем по алгоритму " + chr(10) +
                          "Кол-во: v-rsrv-qnty " + string(if v-rsrv-qnty <> ? then v-rsrv-qnty else 0) + chr(10) +
                          "Погрешность v-metering-qnty-base " + string(if v-metering-qnty-base <> ? then v-metering-qnty-base else 0) + chr(10) +
                          "Погрешность v-metering-qnty-cli" + string(if v-metering-qnty-cli <> ? then v-metering-qnty-cli else 0) + chr(10)
                          .
                      end.
                    end.
                  end.
                when 2 then
                  do:
                  end.
              end case.
              if v-cre-add-docs   = true
                and v-normal-wastage-base <> 0.0
                and v-normal-wastage-cli <> 0.0
                then
              do:
                create tt-line-for-doc.
                assign
                  tt-line-for-doc.gds-code      = buf_rvs-line.gds-code
                  tt-line-for-doc.pl-code       = buf_rvs-line.pl-code
                  tt-line-for-doc.fact-qnty     = v-normal-wastage-base
                  tt-line-for-doc.fact-cli-qnty = v-normal-wastage-cli
                  .
              end.
            end.
            if ptrlprop-algrvspt = 3
              then
            do:
              rvsinvsubObj = new rvsinvsub ().
              rvsinvsubObj:RvsCode  = buf_rvs-line.rvs-code.
              rvsinvsubObj:ObjType  = buf_rvs-line.obj-type.
              rvsinvsubObj:ObjCode  = buf_rvs-line.obj-code.
              rvsinvsubObj:PlCode   = buf_rvs-line.pl-code.
              rvsinvsubObj:GdsCode  = buf_rvs-line.gds-code.
              MKN = O_PKH-cli.
              MFO = O_FACT-cli.
              MFOR = v-all-state-measure-cli-qnty.
              MFOT = v-all-state-add-cli-qnty.
              beta1 = K1.
              beta2 = K3.
              dMMBd = (beta1 * MFOR + beta2 * MFOT) / 100.
              rvsinvsubObj:Diff = MFO - MKN.
              dM = MFO - MKN.
              logger:StrLogPut =
                "Алгоритм: " + string(ptrlprop-algrvspt) + chr(10) +
                "Номер сверки: " + string(rvsinvsubObj:RvsCode) + chr(10) +
                "Номер резервуара: " + string(rvsinvsubObj:PlCode) + chr(10) +
                "Код товара: " + string(rvsinvsubObj:GdsCode) + chr(10) +
                "MKN: " + string(MKN) + chr(10) +
                "MFO: " + string(MFO) + chr(10)  +
                "MFOR: " + string(MFOR) + chr(10)  +
                "MFOT: " + string(MFOT) + chr(10)   +
                "beta1: " + string(beta1) + chr(10) +
                "beta2: " + string(beta2) + chr(10) +
                "dMMBd: " + string(dMMBd) + chr(10)  +
                "rvsinvsubObj:Diff: " + string(beta2) + chr(10) +
                "dM: " + string(dMMBd) + chr(10)   .
              if absolute (dM) <= dMMBd
                then
              do:
                v-rsrv-qnty = 0.
                v-reserv-qnty-cli = 0.
              end.
              else
              do:
                if MFO > MKN
                  then
                do:
                  dM = MFO - MKN.
                  MI = dM - dMMBd.
                  MKKN = MKN + MI.
                  v-rsrv-qnty = (MI) / v-avg-state-density.
                  logger:StrLogPut =
                    "Излишки: " + chr(10) +
                    "MI: " + string(MI) + chr(10) +
                    "MKKN: " + string(MKKN) + chr(10) +
                    "v-rsrv-qnty: " + string(v-rsrv-qnty) + chr(10)
                    .
                end.
                else
                do:
                  dMPT = v-normal-tp.
                  dMPOT = oNormWast:NormWastDays + dMPT.
                  MPOT = MKN - MFO - dMMBd.
                  if absolute (dM) <= dMMBd + dMPOT
                    then
                  do:
                    MKKN = MFO + dMMBd.
                  end.
                  else
                  do:
                    MKKN = MFO + dMMBd.
                  end.
                  v-rsrv-qnty = (MKKN - MKN) / v-avg-state-density.
                  logger:StrLogPut =
                    "Недостача: " + chr(10) +
                    "dMPT: " + string(dMPT) + chr(10) +
                    "dMPOT: " + string(dMPOT) + chr(10) +
                    "MPOT: " + string(MPOT) + chr(10) +
                    "MKKN: " + string(MKKN) + chr(10) +
                    "v-rsrv-qnty: " + string(v-rsrv-qnty) + chr(10)
                    .
                end.
              end.
              if v-rsrv-qnty >= 0
                then
              do:
                rvsinvsubObj:Diff = absolute (rvsinvsubObj:Diff).
              end.
              else
              do:
                rvsinvsubObj:Diff = - absolute (rvsinvsubObj:Diff).
              end.
              rvsinvsubObj:MeteringErr = dMMBd.
              if rvsinvsubObj:Diff < 0
                then
              do:
                rvsinvsubObj:TPNormalAuto = v-normal-tp-auto.
                rvsinvsubObj:TPNormalPl = v-normal-tp-pl.
                rvsinvsubObj:NormalWastage = oNormWast:NormWastDays.
              end.
              else
              do:
                rvsinvsubObj:NormalWastage = 0.
                rvsinvsubObj:TPNormalAuto = 0.
                rvsinvsubObj:TPNormalPl = 0.
              end.
              rvsinvstrObj = new rvsinvstr ().
              rvsinvstrObj:insertDB(rvsinvsubObj).
              logger:StrLogPut =
                "--------------" + chr(10) +
                "Данные для инвентаризации:" +
                chr(10) +
                rvsinvsubObj:ObjType + string (rvsinvsubObj:ObjCode) + chr(10) +
                "Сверка:" + rvsinvsubObj:RvsCode + chr(10) +
                "Место хранения:" + string (rvsinvsubObj:PlCode) + chr(10) +
                "Расчетно-книжный остаток (включая трубопровод) MKN: " + string (MKN) + chr(10) +
                "Факт. остаток по рез. изм. в резер. MFOR: " + string (MFOR) + chr(10) +
                "Факт. остаток по рез. изм. в трубопроводе MFOT: " + string (MFOT) + chr(10) +
                "Факт. остаток по рез. изм. MFO: " + string (MFO) + chr(10) +
                "Погр.изм. резер. beta1, %: " + string (beta1) + chr(10) +
                "Погр.изм. трубопровод beta2, %: " + string (beta2) + chr(10) +
                "Допускаемый небаланс dMMBd = (beta1 * MFOR + beta2 * MFOT) / 100: " + string(dMMBd) + chr(10) +
                "Сумма по ПН технол. потерь в резервуаре: " + string (v-normal-tp-pl) + chr(10) +
                "Сумма по ПН технол. потерь при сливе из АЦ: " + string (v-normal-tp-auto) + chr(10) +
                "Общая сумма по ПН технол. потерь dMPT: " + string (v-normal-tp) + chr(10) +
                "Общая сумма ест. убыли при хр. dMHREY : " + string (oNormWast:NormWastDays) + chr(10) +
                "Небаланс |dM|: " + string (absolute (dM)) + chr(10) +
                "Недостача MNED : " + string (absolute (MNED)) + chr(10) +
                "Излишки MI : " + string (absolute (MI)) + chr(10) +
                "Скорректированный расчетно-книжный остаток (включая трубопровод) MKKN: " + string (MKKN) + chr(10)
                .
              def var v-infom-mess as char no-undo.
              if absolute (rvsinvsubObj:Diff) > rvsinvsubObj:MeterErrWast
                then
              do:
                v-infom-mess = v-infom-mess + substitute ("Назв. товара - &2&1Скл.место - &3, РКО,кг - &4, Факт., кг - &5&1&6, кг - &7&1"
                  , chr(10)
                  ,buf_goods.gds-name
                  ,string(rvsinvsubObj:PlCode)
                  ,string(round (MKN, 3))
                  ,string(round (MFO, 3))
                  ,(if rvsinvsubObj:Diff < 0 then "Недостача" else "Излишки")
                  ,string (round (rvsinvsubObj:DeficitOver, 3))
                  ).
              end.
            end.
            if not ptrlprop-algrvspt = 3
              then
              if ptrlprop-expptrl = 'weight':U then
              do:
                assign
                  v-reserv-qnty-cli = v-rsrv-qnty
                  .
                if varinv-set = true then
                do:
                  assign
                    v-reserv-qnty-base = ( v-fact-cli-qnty + v-reserv-qnty-cli - (if v-cre-add-docs = true then v-normal-wastage-cli else 0.0)
                                          ) / buf_rvs-line.state-density - ( v-fact-qnty - (if v-cre-add-docs = true then v-normal-wastage-base else 0.0) )
                    .
                  logger:StrLogPut =
                    "Установлен параметр, выставляем кол-ва по плотности" + chr(10) +
                    "Кол-во : " + string(if v-reserv-qnty-base <> ? then v-reserv-qnty-base else 0) + chr(10)
                    .
                end.
                else
                do:
                  assign
                    v-reserv-qnty-base = v-reserv-qnty-cli / v-avg-state-density
                    .
                  logger:StrLogPut =
                    "Кол-во : " + string(if v-reserv-qnty-base <> ? then v-reserv-qnty-base else 0) + chr(10)
                    .
                end.
              end.
              else
              do:
                assign
                  v-reserv-qnty-base = v-rsrv-qnty
                  .
                if varinv-set = true then
                do:
                  assign
                    v-reserv-qnty-cli = ( v-fact-qnty + v-reserv-qnty-base - (if v-cre-add-docs = true then v-normal-wastage-base else 0.0)
                                        ) * buf_rvs-line.state-density - ( v-fact-cli-qnty - (if v-cre-add-docs = true then v-normal-wastage-cli else 0.0) )
                    .
                  logger:StrLogPut =
                    "Установлен параметр, выставляем кол-ва по плотности" + chr(10) +
                    "Кол-во : " + string(if v-reserv-qnty-cli <> ? then v-reserv-qnty-cli else 0) + chr(10)
                    .
                end.
                else
                do:
                  assign
                    v-reserv-qnty-cli = v-reserv-qnty-base * v-avg-state-density
                    .
                  logger:StrLogPut =
                    "Кол-во : " + string(if v-reserv-qnty-cli <> ? then v-reserv-qnty-cli else 0) + chr(10)
                    .
                end.
              end.
            else
            do:
              v-reserv-qnty-base = v-rsrv-qnty.
              assign
                v-reserv-qnty-cli = v-reserv-qnty-base * v-avg-state-density
                .
              logger:StrLogPut =
                "Кол-во : " + string(v-reserv-qnty-cli) + chr(10)
                .
            end.
          end.
          else do:
            assign
              v-reserv-qnty-cli  = O_FACT-cli - O_PKH-cli
              v-reserv-qnty-base = O_FACT-base - O_PKH-base
              .
            logger:StrLogPut =
              "Кол-во кг: " + string(v-reserv-qnty-cli) + chr(10) +
              "Кол-во литры: " + string(v-reserv-qnty-base) + chr(10)
              .
          end.
          if v-reserv-qnty-cli = ? then v-reserv-qnty-cli = 0 .
          if v-reserv-qnty-base = ? then v-reserv-qnty-base = 0 .
          if v-reserv-qnty-base <> 0 then
          do:
            assign
              v-chg-qnty = v-reserv-qnty-base
              .
            run trg/rsrv-dtl.p
              ( input parparentproc
              , input 'reserv':U + "," + 'plcode':U + "=" + string(buf_rvs-line.pl-code)
              , buffer buf_gds-dtl
              , input-output v-chg-qnty
              , input-output buf_doc-line.price-base
              , input-output buf_doc-line.price-rubl
              , input -1
              , input ""
              ) no-error.
            if error-status :error then
            do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка резервирования." skip
                error-status:get-message(1)      skip
                error-status:get-message(2)      skip
                return-value
                view-as alert-box error.
              undo block_cre-inv, retry block_cre-inv.
            end.
            if v-chg-qnty <> v-reserv-qnty-base then
            do:
              message
                vss-workfile vss-revision vss-description skip
                "Не удалось произвести автоматическое резервирование на все кол-во." skip
                substitute( "Для документа инвентаризации по месту хранения &1", buf_rvs-line.pl-code ) skip
                "Инвентаризация не может быть сделана автоматически."
                view-as alert-box.
              undo block_cre-inv, retry block_cre-inv.
            end.
          end.
          if v-reserv-qnty-base <> 0
            or v-reserv-qnty-cli <> 0
            then
          do:
            assign
              buf_gds-dtl.fact-qnty       = buf_gds-dtl.fact-qnty       + v-reserv-qnty-base
              buf_gds-dtl.doc-qnty        = buf_gds-dtl.doc-qnty        + v-reserv-qnty-base
              buf_doc-line.doc-qnty       = buf_doc-line.doc-qnty       + v-reserv-qnty-base
              buf_doc-line.fact-qnty      = buf_doc-line.fact-qnty      + v-reserv-qnty-base
              buf_doc-line.cli-qnty       = buf_doc-line.cli-qnty       + v-reserv-qnty-cli
              buf_inv-line.wast-cli-qnty  = buf_inv-line.wast-cli-qnty  + v-reserv-qnty-cli
              buf_doc-pl.doc-qnty         = buf_doc-pl.doc-qnty         + v-reserv-qnty-base
              buf_doc-pl.cli-qnty         = buf_doc-pl.cli-qnty         + v-reserv-qnty-cli
              buf_doc-pl.rest-af-qnty     = buf_doc-pl.rest-af-qnty     + v-reserv-qnty-base
              buf_doc-pl.cli-rest-af-qnty = buf_doc-pl.cli-rest-af-qnty + v-reserv-qnty-cli
              buf_doc-pl.fact-qnty        = buf_doc-pl.doc-qnty
              buf_doc-pl.cli-doc-qnty     = buf_doc-pl.cli-qnty
              buf_doc-pl.cli-fact-qnty    = buf_doc-pl.cli-qnty
              .
          end.
          create buf_doc-line-sum .
          assign
            buf_doc-line-sum.doc-code  = v-inv-code
            buf_doc-line-sum.gds-code  = buf_rvs-line.gds-code
            buf_doc-line-sum.sum-type  = substitute( "&1&2&3&2&4", 'wst':U, chr(4), "base":U, buf_rvs-line.pl-code )
            buf_doc-line-sum.fact-qnty = v-wastage-qnty-base
            .
          create buf_doc-line-sum .
          assign
            buf_doc-line-sum.doc-code  = v-inv-code
            buf_doc-line-sum.gds-code  = buf_rvs-line.gds-code
            buf_doc-line-sum.sum-type  = substitute( "&1&2&3&2&4", "mterr":U, chr(4), "base":U, buf_rvs-line.pl-code )
            buf_doc-line-sum.fact-qnty = v-metering-qnty-base
            .
          create buf_doc-line-sum .
          assign
            buf_doc-line-sum.doc-code  = v-inv-code
            buf_doc-line-sum.gds-code  = buf_rvs-line.gds-code
            buf_doc-line-sum.sum-type  = substitute( "&1&2&3&2&4", 'wst':U, chr(4), "cli":U, buf_rvs-line.pl-code )
            buf_doc-line-sum.fact-qnty = v-wastage-qnty-cli
            .
          create buf_doc-line-sum .
          assign
            buf_doc-line-sum.doc-code  = v-inv-code
            buf_doc-line-sum.gds-code  = buf_rvs-line.gds-code
            buf_doc-line-sum.sum-type  = substitute( "&1&2&3&2&4", "mterr":U, chr(4), "cli":U, buf_rvs-line.pl-code )
            buf_doc-line-sum.fact-qnty = v-metering-qnty-cli
            .
        end.
        assign
          buf_inv-line.after-cli-qnty = buf_inv-line.wast-cli-qnty
          buf_doc-line.doc-density    = buf_inv-line.wast-cli-qnty / buf_doc-line.doc-qnty
          .
        if buf_doc-line.doc-density = ? then
        do:
          assign
            buf_doc-line.doc-density = 1 / buf_goods.cli-base-rate
            .
        end.
        assign
          buf_doc-line.fact-density = buf_doc-line.doc-density
          .
      end.
      else
      do:
        message
          "Режим инвентаризации по сверке работает только в товарах без признаков." skip
          "Откатываем создание инвентаризации."
          view-as alert-box error.
        undo block_cre-inv, retry block_cre-inv.
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclcinv in g#lib-trn2
(
input        'update':U,
input        recid(buf_doc-line),
input        v-inv-code,
input-output vartot-docold,
input-output vartot-rublold,
input-output i-total-doc-line_tot-ovold,
input-output i-total-doc-line_fact-rublold,
input-output i-total-doc-line_fact-baseold,
input-output i-total-doc-line_fact-qntyold,
input-output i-total-doc-line_doc-qntyold,
input-output i-total-doc-line_cli-qntyold,
input-output i-total-parts_fact-baseold,
input-output i-total-parts_fact-rublold,
input-output i-total-parts_fact-qntyold
) no-error.
      if error-status :error then
      do:
        undo block_cre-inv, retry block_cre-inv.
      end.
    end.
    run gbl/calc-trn.p
      ( input parparentproc
      , recid( buf_trn-doc )
      ) no-error.
    if error-status :error then
    do:
      undo block_cre-inv, retry block_cre-inv.
    end.
    if v-cre-add-docs = true then
    do:
      find first tt-line-for-doc no-lock
        where tt-line-for-doc.fact-qnty > 0
        no-error.
      if available tt-line-for-doc then
      do:
        run doc-code in this-procedure
          ( input  "pair"
          , input  v-cntxt-obj-type
          , input  v-cntxt-obj-code
          , input  v-inv-code
          , output v-spi-code
          ) no-error.
        if error-status:error then
        do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка вычисления номера документа списания." skip
            return-value skip
            trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box error.
          undo block_cre-inv, retry block_cre-inv.
        end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input buf_trn-doc.base-rate
,input buf_trn-doc.base-scale
,input buf-add_clients.obj-code
,input buf-add_clients.obj-type
,input buf-add_clients.obj-name
,input v-cntxt-db-num
,input v-cntxt-userid
,input 'процент':U
,input v-spi-code
,input buf_trn-doc.doc-date
,input 'спи':U
,input no
,input buf_trn-doc.host-code
,input no
,input buf_trn-doc.obj-code
,input buf_trn-doc.obj-type
,input no
,input buf_trn-doc.pay-code
,input substitute( '@  Списание к документу инвентаризации &1', v-inv-code )
,input no
,input 'без':U
,input 'накл':U
,input 'в т. ч.':U
,input 'we':U
,input ?
) no-error
.
        if error-status:error then
        do:
          message
            vss-workfile vss-revision vss-description skip
            substitute("Ошибка при генерации документа списания по инвентаризации &1", v-inv-code ) skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo block_cre-inv, retry block_cre-inv.
        end.
        find buf-spi_trn-doc
          where buf-spi_trn-doc.doc-code = v-spi-code
          .
        assign
          buf-spi_trn-doc.shift-date = buf_trn-doc.shift-date
          buf-spi_trn-doc.shift-num  = buf_trn-doc.shift-num
          buf-spi_trn-doc.out-code   = v-inv-code
          buf-spi_trn-doc.exch-code  = buf_trn-doc.exch-code
          buf-spi_trn-doc.exch-rate  = buf_trn-doc.exch-rate
          buf-spi_trn-doc.exch-scale = buf_trn-doc.exch-scale
          buf-spi_trn-doc.print-rubl = buf_trn-doc.print-rubl
          buf-spi_trn-doc.agnt       = buf_trn-doc.agnt
          buf-spi_trn-doc.wrkr       = buf_trn-doc.wrkr
          buf-spi_trn-doc.boss       = buf_trn-doc.boss
          .
        for each tt-line-for-doc no-lock
          ,first buf_goods no-lock
          where buf_goods.gds-code = tt-line-for-doc.gds-code
          break by tt-line-for-doc.gds-code
          on error undo block_cre-inv, retry block_cre-inv
          :
          find first buf-spi_doc-line no-lock
            where buf-spi_doc-line.doc-code  = v-spi-code
            and buf-spi_doc-line.artic     = buf_goods.artic
            and buf-spi_doc-line.prod-type = buf_goods.prod-type
            and buf-spi_doc-line.prod-code = buf_goods.prod-code
            no-error .
          if not available buf-spi_doc-line then
          do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_adinvlin in g#lib-trn3
(input  parparentproc
,input  v-spi-code
,input  buf_goods.artic
,input  buf_goods.prod-type
,input  buf_goods.prod-code
,output v-recid
) .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  buf_goods.prt-root
  ,output v-prt-root
  )  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input buf_trn-doc.obj-code
   ,input buf_trn-doc.obj-type
   ,input v-spi-code
   ,input buf_goods.artic
   ,input buf_goods.prod-code
   ,input buf_goods.prod-type
   ,input v-prt-root
   ,input yes
  )  .
          end.
          create buf-spi_doc-pl.
          assign
            buf-spi_doc-pl.obj-type      = buf_trn-doc.obj-type
            buf-spi_doc-pl.obj-code      = buf_trn-doc.obj-code
            buf-spi_doc-pl.pl-code       = tt-line-for-doc.pl-code
            buf-spi_doc-pl.out-code      = v-spi-code
            buf-spi_doc-pl.gds-code      = buf_goods.gds-code
            buf-spi_doc-pl.doc-qnty      = tt-line-for-doc.fact-qnty
            buf-spi_doc-pl.fact-qnty     = tt-line-for-doc.fact-qnty
            buf-spi_doc-pl.cli-qnty      = tt-line-for-doc.fact-cli-qnty
            buf-spi_doc-pl.cli-doc-qnty  = tt-line-for-doc.fact-cli-qnty
            buf-spi_doc-pl.cli-fact-qnty = tt-line-for-doc.fact-cli-qnty
            .
          find first buf-spi_gds-dtl exclusive-lock
            where buf-spi_gds-dtl.doc-code    = v-spi-code
            and buf-spi_gds-dtl.artic       = buf_goods.artic
            and buf-spi_gds-dtl.prod-type   = buf_goods.prod-type
            and buf-spi_gds-dtl.prod-code   = buf_goods.prod-code
            and buf-spi_gds-dtl.prt-code    = v-prt-root
            .
          find first buf_doc-line exclusive-lock
            where buf_doc-line.doc-code  = v-inv-code
            and buf_doc-line.artic     = buf_goods.artic
            and buf_doc-line.prod-type = buf_goods.prod-type
            and buf_doc-line.prod-code = buf_goods.prod-code
            .
          find first buf-spi_doc-line exclusive-lock
            where buf-spi_doc-line.doc-code  = v-spi-code
            and buf-spi_doc-line.artic     = buf_goods.artic
            and buf-spi_doc-line.prod-type = buf_goods.prod-type
            and buf-spi_doc-line.prod-code = buf_goods.prod-code
            .
          find first buf-spi_inv-line exclusive-lock
            where buf-spi_inv-line.doc-code  = v-spi-code
            and buf-spi_inv-line.artic     = buf_goods.artic
            and buf-spi_inv-line.prod-type = buf_goods.prod-type
            and buf-spi_inv-line.prod-code = buf_goods.prod-code
            .
          if first-of( tt-line-for-doc.gds-code ) then
          do:
            assign
              v-fact-qnty     = 0.0
              v-fact-cli-qnty = 0.0
              .
            for each buf_tt-line-for-doc
              where buf_tt-line-for-doc.gds-code = buf_goods.gds-code
              on error undo block_cre-inv, retry block_cre-inv
              :
              assign
                v-fact-qnty     = v-fact-qnty     + buf_tt-line-for-doc.fact-qnty
                v-fact-cli-qnty = v-fact-cli-qnty + buf_tt-line-for-doc.fact-cli-qnty
                .
            end.
            assign
              buf-spi_doc-line.doc-density   = v-fact-cli-qnty / v-fact-qnty
              buf-spi_doc-line.fact-density  = buf-spi_doc-line.doc-density
              buf-spi_doc-line.cli-base-rate = 1.0 / buf-spi_doc-line.doc-density
              buf-spi_doc-line.cli-qnty      = 0.0
              buf-spi_doc-line.doc-qnty      = 0.0
              buf-spi_doc-line.fact-qnty     = 0.0
              buf-spi_doc-line.price-rubl    = buf_doc-line.price-rubl
              buf-spi_doc-line.price-base    = buf_doc-line.price-base
              buf-spi_doc-line.price-cli     = buf_doc-line.price-cli
              buf-spi_gds-dtl.doc-qnty       = 0.0
              buf-spi_gds-dtl.fact-qnty      = 0.0
              .
          end.
          if tt-line-for-doc.fact-qnty <> 0 then
          do:
            assign
              v-chg-qnty = tt-line-for-doc.fact-qnty
              .
            run trg/rsrv-dtl.p
              ( input parparentproc
              , input 'reserv':U + "," + 'plcode':U + "=" + string(tt-line-for-doc.pl-code)
              , buffer buf-spi_gds-dtl
              , input-output v-chg-qnty
              , input-output buf-spi_doc-line.price-base
              , input-output buf-spi_doc-line.price-rubl
              , input -1
              , input ""
              ) no-error.
            if error-status :error then
            do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка резервирования." skip
                error-status:get-message(1)      skip
                error-status:get-message(2)      skip
                return-value
                view-as alert-box error.
              undo block_cre-inv, retry block_cre-inv.
            end.
            if v-chg-qnty <> tt-line-for-doc.fact-qnty then
            do:
              message
                vss-workfile vss-revision vss-description skip
                "Не удалось произвести автоматическое резервирование на все кол-во." skip
                substitute( "Для списания естественной убыли по месту хранения &1", tt-line-for-doc.pl-code ) skip
                "Инвентаризация не может быть сделана автоматически."
                view-as alert-box.
              undo block_cre-inv, retry block_cre-inv.
            end.
            assign
              buf-spi_gds-dtl.fact-qnty      = buf-spi_gds-dtl.fact-qnty      + tt-line-for-doc.fact-qnty
              buf-spi_gds-dtl.doc-qnty       = buf-spi_gds-dtl.doc-qnty       + tt-line-for-doc.fact-qnty
              buf-spi_doc-line.doc-qnty      = buf-spi_doc-line.doc-qnty      + tt-line-for-doc.fact-qnty
              buf-spi_doc-line.fact-qnty     = buf-spi_doc-line.fact-qnty     + tt-line-for-doc.fact-qnty
              buf-spi_doc-line.cli-qnty      = buf-spi_doc-line.cli-qnty      + tt-line-for-doc.fact-cli-qnty
              buf-spi_inv-line.wast-cli-qnty = buf-spi_inv-line.wast-cli-qnty + tt-line-for-doc.fact-cli-qnty
              .
          end.
        end.
        run gbl/calc-trn.p
          ( input parparentproc
          , recid( buf-spi_trn-doc )
          ) no-error.
        if error-status :error then
        do:
          undo block_cre-inv, retry block_cre-inv.
        end.
        for each buf-spi_doc-line exclusive-lock
          where buf-spi_doc-line.doc-code = v-spi-code
          ,each buf-spi_inv-line exclusive-lock
          where buf-spi_inv-line.doc-code  = buf-spi_doc-line.doc-code
          and buf-spi_inv-line.artic     = buf-spi_doc-line.artic
          and buf-spi_inv-line.prod-type = buf-spi_doc-line.prod-type
          and buf-spi_inv-line.prod-code = buf-spi_doc-line.prod-code
          on error undo block_cre-inv, retry block_cre-inv
          :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_corinvln in g#lib-trn3
( input  buf-spi_doc-line.doc-code
 ,input  buf-spi_doc-line.artic
 ,input  buf-spi_doc-line.prod-type
 ,input  buf-spi_doc-line.prod-code
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  buf-spi_inv-line.wast-cli-qnty
 ,input  buf-spi_doc-line.fact-density
 ,output v-recid
 ) no-error.
          if error-status :error
            then
          do:
            message
              "Ошибка создания топливной строки накладной." skip( 0 )
              return-value skip( 0 )
              error-status :get-message( 1 )
              view-as alert-box error .
            undo block_cre-inv, retry block_cre-inv.
          end.
        end.
        run close-doc in this-procedure
          ( input v-spi-code
          , recid( buf-spi_trn-doc )
          ) no-error.
        if error-status :error then
        do:
          undo block_cre-inv, retry block_cre-inv.
        end.
      end.
    end.
    assign
      buf_trn-doc.status_ = 'нередакт':U
      buf_trn-doc.flag_   = yes
      p-docs-info         = substitute( "Документ инвентаризации &1", v-inv-code )
      .
    if available buf-spi_trn-doc then
    do:
      assign
        buf-spi_trn-doc.status_ = 'нередакт':U
        buf-spi_trn-doc.flag_   = yes
        p-docs-info             = p-docs-info + chr(10) + substitute( "Документ списания &1", v-spi-code )
        .
    end.
  end.
  run init-attr-general in this-procedure .
      find first buf_doc-line no-lock where buf_doc-line.doc-code = v-inv-code no-error .
    if available buf_doc-line
      then
    do :
    run str/inv-attr.w (input ParParentproc, input "b-lkp,b-chg", input v-inv-code, input table tt-upd-attr) no-error.
    end .
  if v-infom-mess <> ""
    then
  do:
    message "В результате произведенных замеров были выявлены следующие расхождения, превышающие погрешность измерения:" skip v-infom-mess view-as alert-box information title "Сообщение".
  end.
  for each tt-line-for-doc
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
    delete tt-line-for-doc .
  end.
end.
procedure close-doc :
  define input  parameter p-doc-code  like ub.trn-doc.doc-code no-undo .
  define input  parameter p-doc-recid as   recid               no-undo .
  do
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1. stop", vss-workfile )
    on endkey undo, return error substitute( "&1. endkey", vss-workfile )
    :
    define variable varchg-inv as logical no-undo.
    run str/trn-stat.p
      ( input parparentproc
      ,input this-procedure
      ,input '<закрытие документа>':U
      ,input p-doc-code
      ,input ?
      ,input v-cntxt-db-num
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input yes
      ,output varchg-inv
      ,output table gds-list
      ) no-error.
    if error-status :error then
    do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при переводе документа &1 из статуса накл- в накл+.", p-doc-code ) skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error return-value .
    end.
    run str/trn-stat.p
      ( input parparentproc
      ,input this-procedure
      ,input '<закрытие документа>':U
      ,input p-doc-code
      ,input ?
      ,input v-cntxt-db-num
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input yes
      ,output varchg-inv
      ,output table gds-list
      ) no-error.
    if error-status :error then
    do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при переводе документа &1 из статуса накл+ в разр+.", p-doc-code ) skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error return-value .
    end.
    run gbl/calc-trn.p
      ( input parparentproc
      ,input p-doc-recid
      ) no-error.
  end.
end procedure.
PROCEDURE cr-tt-upd :
do on error undo, return error return-value :
define variable v-other as character   no-undo.
for each tt-upd-attr: delete tt-upd-attr. end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-prikaz-number':U  .
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
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-prikaz-date':U  .
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
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-inv-date':U  .
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
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-fio-agent':U  .
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
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-pos-agent':U  .
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
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-fio-player1':U  .
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
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-pos-player1':U  .
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
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-fio-player2':U  .
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
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-pos-player2':U  .
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
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-fio-player3':U  .
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
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-pos-player3':U  .
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
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
end.
end procedure.
PROCEDURE init-attr-general :
do on error undo, return error return-value :
run cr-tt-upd .
define variable varexist                  as logical   no-undo.
  run create-record in this-procedure (  input v-inv-code                                                         ,  input 'trdcattr-prikaz-number':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input v-inv-code                                                         ,  input 'trdcattr-prikaz-date':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input v-inv-code                                                         ,  input 'trdcattr-inv-date':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input v-inv-code                                                         ,  input 'trdcattr-fio-agent':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input v-inv-code                                                         ,  input 'trdcattr-pos-agent':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input v-inv-code                                                         ,  input 'trdcattr-fio-player1':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input v-inv-code                                                         ,  input 'trdcattr-pos-player1':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input v-inv-code                                                         ,  input 'trdcattr-fio-player2':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input v-inv-code                                                         ,  input 'trdcattr-pos-player2':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input v-inv-code                                                         ,  input 'trdcattr-fio-player3':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input v-inv-code                                                         ,  input 'trdcattr-pos-player3':U                                                         ,  input  ""                                                         , output varexist ) no-error.
end.
END PROCEDURE.
