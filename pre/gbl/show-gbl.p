block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: show-gbl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/show-gbl.p $":U .
define variable vss-description as character no-undo init "Показывает глобальные переменные системы".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-ap-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_attr-prop for ub.attr-prop .
  do
  on error undo, return error
  :
    find first buf_attr-prop no-lock where
              buf_attr-prop.node-code = 0
          and buf_attr-prop.table-name = '':U
          and buf_attr-prop.templ-rl-root = 0   no-error.
    if (not available buf_attr-prop
    or buf_attr-prop.property-value <> "v15_1.3" )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_attr-prop.property-value, "."))
      v-dopi2 = integer(entry(2, "v15_1.3", "."))
      v-dopi3 = integer(entry(2, entry(1, buf_attr-prop.property-value, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, "v15_1.3", "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_attr-prop.property-value, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.
end procedure.
procedure get-ap-version :
define output parameter p-ap-version as character no-undo init ?.
define buffer buf_attr-prop for ub.attr-prop .
find first buf_attr-prop no-lock where
          buf_attr-prop.node-code = 0
      and buf_attr-prop.table-name = '':U
      and buf_attr-prop.templ-rl-root = 0   no-error.
if available buf_attr-prop then do:
  p-ap-version = buf_attr-prop.property-value.
end.
end procedure.
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-dr-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule .
  do
  on error undo, return error
  :
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = 0 no-error .
    if (not available buf_dis-rule
    or buf_dis-rule.des <> "v16_0.1" )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_Dis-rule.des, "."))
      v-dopi2 = integer(entry(2, "v16_0.1", "."))
      v-dopi3 = integer(entry(2, entry(1, buf_Dis-rule.des, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, "v16_0.1", "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_Dis-rule.des, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.
end procedure.
procedure get-dr-version :
define output parameter p-dr-version as character no-undo init ?.
define buffer buf_dis-rule for ub.dis-rule .
do
on error undo, return error
:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = 0 no-error .
  if available buf_dis-rule then do:
      p-dr-version = buf_dis-rule.des.
  end.
end.
end procedure.
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
~
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-dtr-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define buffer buf_dis-time-rule for ub.dis-time-rule .
  do
  on error undo, return error
  :
    find first buf_dis-time-rule no-lock where
              buf_dis-time-rule.time-rule-num = 50000  no-error .
    if not available buf_dis-time-rule
    or buf_dis-time-rule.des <> "v16_0.1" then do:
      assign
      v-dopi1 = integer(entry(2, buf_Dis-time-rule.des, "."))
      v-dopi2 = integer(entry(2, "v16_0.1", "."))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or left-trim(entry(1, buf_Dis-time-rule.des, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes .
      end.
    end.
  end.
end procedure.
procedure get-dtr-version :
define output parameter p-dtr-version as character no-undo init ?.
define buffer buf_dis-time-rule for ub.dis-time-rule .
do
on error undo, return error
:
  find first buf_dis-time-rule no-lock where
            buf_dis-time-rule.time-rule-num = 50000 no-error .
  if available buf_dis-time-rule then do:
      p-dtr-version = buf_dis-time-rule.des.
  end.
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-cl-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_custom-labels for ub.custom-labels .
  do
  on error undo, return error
  :
    find first buf_custom-labels no-lock where
              buf_custom-labels.tbl-name = '':U
          and buf_custom-labels.fld-name = '':U
          and buf_custom-labels.call-type = '':U
          and buf_custom-labels.call-point = '':U  no-error.
    if (not available buf_custom-labels
    or buf_custom-labels.custom-tooltip <> "v15_1.12" )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_custom-labels.custom-tooltip, "."))
      v-dopi2 = integer(entry(2, "v15_1.12", "."))
      v-dopi3 = integer(entry(2, entry(1, buf_custom-labels.custom-tooltip, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, "v15_1.12", "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_custom-labels.custom-tooltip, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.
end procedure.
procedure get-cl-version :
define output parameter p-cl-version as character no-undo init ?.
define buffer buf_custom-labels for ub.custom-labels .
do
on error undo, return error
:
  find first buf_custom-labels no-lock where
            buf_custom-labels.tbl-name = '':U
        and buf_custom-labels.fld-name = '':U
        and buf_custom-labels.call-type = '':U
        and buf_custom-labels.call-point = '':U  no-error.
  if available buf_custom-labels then do:
      p-cl-version = buf_custom-labels.custom-tooltip.
  end.
end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-rum-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_ruledict for ub.ruledict .
  do
  on error undo, return error
  :
    find first buf_ruledict no-lock where
              buf_ruledict.entry-id = 0  no-error.
    if (not available buf_ruledict
    or buf_ruledict.documentation <> "v16_0.13" )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_ruledict.documentation,  "."))
      v-dopi2 = integer(entry(2, "v16_0.13", "."))
      v-dopi3 = integer(entry(2, entry(1, buf_ruledict.documentation, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, "v16_0.13", "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_ruledict.documentation, "."), "v":U) < "16"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.
end procedure.
procedure get-rum-version :
define output parameter p-rum-version as character no-undo init ?.
define buffer buf_ruledict for ub.ruledict .
do
on error undo, return error
:
  find first buf_ruledict no-lock where
            buf_ruledict.entry-id = 0  no-error.
  if available buf_ruledict then do:
    p-rum-version = buf_ruledict.documentation.
  end.
end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-gate-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_clob-bind for ub.clob-bind .
  do
  on error undo, return error
  :
    find first buf_clob-bind no-lock where
              buf_clob-bind.db-num = 0
         and  buf_clob-bind.int64-id = 0
              no-error.
    if (not available buf_clob-bind
    or buf_clob-bind.descr <> "v15_1.60" )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_clob-bind.descr,  "."))
      v-dopi2 = integer(entry(2, "v15_1.60", "."))
      v-dopi3 = integer(entry(2, entry(1, buf_clob-bind.descr, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, "v15_1.60", "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_clob-bind.descr, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.
end procedure.
procedure get-gate-version :
define output parameter p-gate-version as character no-undo init ?.
define buffer buf_clob-bind for ub.clob-bind .
do
on error undo, return error
:
  find first buf_clob-bind no-lock where
            buf_clob-bind.db-num = 0
        and  buf_clob-bind.int64-id = 0
            no-error.
  if available buf_clob-bind then do:
    p-gate-version = buf_clob-bind.descr.
  end.
end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-layout-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_layout for ub.layout .
  do
  on error undo, return error
  :
    find first buf_layout no-lock where
              buf_layout.layout-id = '_'  no-error.
    if (not available buf_layout
    or buf_layout.layout-name <> "v15_1.11" )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_layout.layout-name,  "."))
      v-dopi2 = integer(entry(2, "v15_1.11", "."))
      v-dopi3 = integer(entry(2, entry(1, buf_layout.layout-name, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, "v15_1.11", "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_layout.layout-name, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.
end procedure.
procedure get-layout-version :
define output parameter p-layout-version as character no-undo init ?.
define buffer buf_layout for ub.layout .
do
on error undo, return error
:
  find first buf_layout no-lock where
              buf_layout.layout-id = '_'  no-error.
  if available buf_layout then do:
    p-layout-version = buf_layout.layout-name.
  end.
end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-thbj-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_thbj-attr for ub.thbj-attr.
  do
  on error undo, return error
  :
    find first buf_thbj-attr no-lock where
              buf_thbj-attr.obj-type = '':U
          and buf_thbj-attr.obj-code = 0
          and buf_thbj-attr.prop-code = ''
          and buf_thbj-attr.upper-prop-code = '' no-error .
    if (not available buf_thbj-attr
    or buf_thbj-attr.property-value-character <> "v15_1.1" )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_thbj-attr.property-value-character, "."))
      v-dopi2 = integer(entry(2, "v15_1.1", "."))
      v-dopi3 = integer(entry(2, entry(1, buf_thbj-attr.property-value-character, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, "v15_1.1", "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_thbj-attr.property-value-character, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.
end procedure.
procedure get-thbj-version :
define output parameter p-thbj-version as character no-undo init ?.
define buffer buf_thbj-attr for ub.thbj-attr.
do
on error undo, return error
:
  find first buf_thbj-attr no-lock where
            buf_thbj-attr.obj-type = '':U
        and buf_thbj-attr.obj-code = 0
        and buf_thbj-attr.prop-code = ''
        and buf_thbj-attr.upper-prop-code = '' no-error .
  if available buf_thbj-attr then do:
    p-thbj-version = buf_thbj-attr.property-value-character.
  end.
end.
end procedure.
define variable base-type             as character no-undo .
define variable base-code             as integer   no-undo .
define variable g#report-num          as integer   no-undo .
define variable g#gds-engl            as logical   no-undo .
define variable g#quest-print         as logical   no-undo .
define variable g#inp-jewel           as logical   no-undo .
define variable v-cntxt-host-name-obj as character no-undo .
define variable v-host-code-obj       as integer   no-undo .
define variable v-obj-data-name       as character no-undo .
define variable v-curr-r-b            as character no-undo .
define buffer buf_rep_currency for ub.currency.
define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.
def var lok as logical no-undo .
assign
  lok = true
.
if valid-handle(parparentproc)
then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run get-report-num  in parparentproc (output g#report-num ).
  run get-gds-engl    in parparentproc (output g#gds-engl ).
  run get-quest-print in parparentproc (output g#quest-print ).
  run get-inp-jewel   in parparentproc (output g#inp-jewel ).
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  message
    "Параметры системы"                           skip
    "parparentproc"         parparentproc         skip
    "v-cntxt-db-num"        v-cntxt-db-num        skip
    "v-cntxt-userid"        v-cntxt-userid        skip
    "v-cntxt-level"         v-cntxt-level         skip
    "v-cntxt-host-code-obj" v-cntxt-host-code-obj skip
    "v-cntxt-obj-type"      v-cntxt-obj-type      skip
    "v-cntxt-obj-code"      v-cntxt-obj-code      skip
    "v-cntxt-db-num-obj"    v-cntxt-db-num-obj    skip
    "g#report-num"          g#report-num          skip
    "g#gds-engl"            g#gds-engl            skip
    "g#quest-print"         g#quest-print         skip
    "g#inp-jewel"           g#inp-jewel           skip(2)
    "g#userid"              g#userid              skip
    "g#db-num"              g#db-num              skip
    "g#auto"                g#auto                skip
    "g#news"                g#news                skip
    "g#news-souce-db"       g#news-source-db      skip
    "g#oxml"                g#oxml                skip(2)
    "Тип валюты продажи"    v-curr-r-b            skip(2)
    view-as alert-box information buttons yes-no update lok.
  if not lok then do:
    return.
  end.
  if  v-cntxt-obj-code <> 0
  and v-cntxt-obj-code <> ?
  and v-cntxt-obj-type <> ""
  and v-cntxt-obj-type <> ?
  then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code-obj
  ,output base-code
  )  .
    find first buf_rep_currency no-lock
      where buf_rep_currency.curr-code = base-code
      no-error .
    if available buf_rep_currency
    then do:
      assign
        base-type = buf_rep_currency.curr-abbr
      .
    end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    define variable v-ap-version as character no-undo .
    define variable v-dr-version as character no-undo .
    define variable v-dtr-version as character no-undo .
    define variable v-cl-version as character no-undo .
    define variable v-rum-version as character no-undo .
    define variable v-gate-version as character no-undo .
    define variable v-layout-version as character no-undo .
    define variable v-thbj-version as character no-undo .
    run get-ap-version in this-procedure ( output v-ap-version).
    run get-dr-version in this-procedure ( output v-dr-version).
    run get-dtr-version in this-procedure ( output v-dtr-version).
    run get-cl-version in this-procedure ( output v-cl-version).
    run get-rum-version in this-procedure ( output v-rum-version).
    run get-gate-version in this-procedure ( output v-gate-version).
    run get-layout-version in this-procedure ( output v-layout-version).
    run get-thbj-version in this-procedure ( output v-thbj-version).
    message
    v-obj-data-name                                       skip
    "v-cntxt-obj-type"         v-cntxt-obj-type           skip
    "v-cntxt-obj-code"         v-cntxt-obj-code           skip
    "base-code"                base-code                  skip
    "base-type"                base-type                  skip
    "v-cntxp-doc-prt"          v-cntxp-doc-prt            skip
    "v-cntxp-price-calc"       v-cntxp-price-calc         skip
    "v-cntxp-inout-price"      v-cntxp-inout-price        skip
    "v-cntxp-unit-cli-perm"    v-cntxp-unit-cli-perm      skip
    "v-cntxp-out-rate"         v-cntxp-out-rate           skip
    "v-cntxp-out-line-discnt"  v-cntxp-out-line-discnt    skip
    "v-cntxp-in-ov"            v-cntxp-in-ov              skip
    "v-cntxp-in-perm"          v-cntxp-in-perm            skip
    "v-cntxp-no-eq"            v-cntxp-no-eq              skip
    "v-cntxp-rsrv-time"        v-cntxp-rsrv-time          skip
    "v-cntxp-load-time"        v-cntxp-load-time          skip
    "v-cntxp-holidays"         v-cntxp-holidays           skip
    "v-cntxp-in-pay"           v-cntxp-in-pay             skip
    "v-cntxp-out-pay"          v-cntxp-out-pay            skip
    "v-cntxp-ret-pay"          v-cntxp-ret-pay            skip
    "v-cntxp-ret-sup-pay"      v-cntxp-ret-sup-pay        skip
    "v-cntxp-down-pay"         v-cntxp-down-pay           skip
    "v-cntxp-inv-pay"          v-cntxp-inv-pay            skip
    "v-cntxp-chk-pay"          v-cntxp-chk-pay            skip
    "v-cntxp-retail"           v-cntxp-retail             skip
    "v-cntxp-osn-base"         v-cntxp-osn-base           skip(2)
    "v-ap-version"             v-ap-version               skip
    "v-dr-version"             v-dr-version               skip
    "v-dtr-version"            v-dtr-version              skip
    "v-cl-version"             v-cl-version               skip
    "v-rum-version"            v-rum-version              skip
    "v-gate-version"           v-gate-version             skip
    "v-layout-version"         v-layout-version           skip
    "v-thbj-version"           v-thbj-version           skip
    view-as alert-box information buttons yes-no update lok.
    if not lok then return.
  end.
end.
else do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  message
  "Параметры системы" skip
  "g#userid"          g#userid          skip
  "g#db-num"          g#db-num          skip
  "g#auto"            g#auto            skip
  "g#news"            g#news            skip
  "g#news-souce-db"   g#news-source-db  skip(2)
  "Тип валюты продажи"    v-curr-r-b            skip(2)
  "(Контекст текущего объекта и текущей фирмы получить невозможно - запуск НЕ из ГЛАВНОГО МЕНЮ!"
  view-as alert-box information .
end.
if lok <> true then do:
  return .
end.
