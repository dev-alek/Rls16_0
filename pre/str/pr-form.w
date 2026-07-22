define input  parameter parParentProc as widget-handle no-undo.
define input  parameter line-mode as character no-undo .
define input  parameter doc-rec as recid no-undo .
define input param p-doc-rec as recid no-undo.
define input param p-disc as decimal no-undo.
define input param r-m  as char no-undo.
define input param r-b as decimal no-undo.
define input param  c-m  as char no-undo.
define output param stp-cycle as log no-undo.
define variable g#log as logical   no-undo .
define variable line-rec as recid no-undo .
define variable cost-base    like ub.gds-obj.avrg-base no-undo.
define variable cost-rubl    like ub.gds-obj.avrg-rubl no-undo.
define variable v-price-base like ub.gds-obj.avrg-base no-undo.
define variable v-price-rubl like ub.gds-obj.avrg-rubl no-undo.
define variable cur-rt-base  like ub.gds-obj.avrg-base no-undo.
define variable cur-rt-rubl  like ub.gds-obj.avrg-rubl no-undo.
define variable doc-code     as char    no-undo.
define variable old-price-sale as decimal no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Формирование приказа переоценки".
define variable tt-price-sale as decimal no-undo.
define variable tt-price-prodwihvat as decimal no-undo.
define variable tt-prod-vat         as decimal no-undo.
define variable v-str as character no-undo .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
function cross-list returns logical (
  input parfirst-stream  as character,
  input parsecond-stream as character,
  input pardelim         as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  define variable vari            as integer no-undo .
  define variable varresult-cross as logical no-undo .
  assign
    varresult-cross = no
  .
  def var v-num-parfirst-stream as integer no-undo .
  assign
    v-num-parfirst-stream = num-entries(parfirst-stream, pardelim)
  .
  do vari = 1 to v-num-parfirst-stream
  :
    if lookup(entry(vari, parfirst-stream, pardelim)
             ,parsecond-stream
             ,pardelim
             ) > 0 then do:
      assign
        varresult-cross = yes
      .
      leave.
    end.
  end.
  return varresult-cross .
end function.
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure grp-obj-write :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-obj.node-code      no-undo.
define input parameter p-host-code  as integer                          no-undo.
define input parameter p-obj-type   like ub.clients.obj-type            no-undo.
define input parameter p-obj-code   like ub.clients.obj-code            no-undo.
define input parameter p-min-increase like ub.gds-grp-obj.min-increase  no-undo.
define input parameter p-max-increase like ub.gds-grp-obj.max-increase  no-undo.
define input parameter p-increase-pc like ub.gds-grp-obj.increase-pc  no-undo.
define input parameter p-calc-method like ub.gds-grp-obj.calc-method no-undo .
define input parameter p-round-method like ub.gds-grp-obj.round-method no-undo .
define input parameter p-round-coef like ub.gds-grp-obj.round-coef no-undo .
define input parameter p-cli-type   like ub.clients.obj-type            no-undo.
define input parameter p-cli-code   like ub.clients.obj-code            no-undo.
define buffer buf_gds-grp-obj for ub.gds-grp-obj.
    find first buf_gds-grp-obj exclusive-lock
         where buf_gds-grp-obj.node-code  = p-node-code
           and buf_gds-grp-obj.host-code  = p-host-code
           and buf_gds-grp-obj.obj-type   = p-obj-type
           and buf_gds-grp-obj.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-obj
    then do:
        create buf_gds-grp-obj.
        assign
                buf_gds-grp-obj.node-code  = p-node-code
                buf_gds-grp-obj.host-code  = p-host-code
                buf_gds-grp-obj.obj-type   = p-obj-type
                buf_gds-grp-obj.obj-code   = p-obj-code
        .
    end.
    assign
    buf_gds-grp-obj.min-increase = p-min-increase
    buf_gds-grp-obj.max-increase = p-max-increase
    buf_gds-grp-obj.increase-pc = p-increase-pc
    buf_gds-grp-obj.calc-method = p-calc-method
    buf_gds-grp-obj.round-method = p-round-method
    buf_gds-grp-obj.round-coef = p-round-coef
    buf_gds-grp-obj.cli-type   = p-cli-type
    buf_gds-grp-obj.cli-code   = p-cli-code
    .
end.
end procedure.
procedure grp-obj-margin-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define output parameter p-min-value as decimal      no-undo init ?.
define output parameter p-max-value as decimal      no-undo init ?.
define output parameter p-increase-pc as decimal      no-undo init ?.
define output parameter p-round-method as character no-undo init "":U.
define output parameter p-base as decimal no-undo init ?.
define output parameter p-range-margin     as integer      no-undo.
define output parameter p-exists-margin    as logical      no-undo.
define output parameter p-range-increase     as integer      no-undo.
define output parameter p-exists-increase    as logical      no-undo.
define output parameter p-range-rmethod     as integer no-undo .
define output parameter p-exists-rmethod    as logical no-undo .
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-margin-found as logical no-undo .
DEFINE VARIABLE v-increase-found as logical no-undo .
DEFINE VARIABLE v-min-value as decimal      no-undo.
DEFINE VARIABLE v-max-value as decimal      no-undo.
DEFINE VARIABLE v-increase-pc as decimal      no-undo.
define variable v-round-method as character no-undo .
define variable v-base as decimal no-undo .
define variable v-print-code as character no-undo .
define buffer buf_gds-grp for ub.gds-grp.
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
if p-obj-type <> '' then do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
  if error-status :error
  then do:
      message
        vss-workfile vss-revision vss-description
        skip "Не удалось найти фирму объекта"
        skip p-obj-type p-obj-code
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
      view-as alert-box error.
      undo, return error .
  end.
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    assign
    v-min-value    = buf_gds-grp-obj.min-increase
    v-max-value    = buf_gds-grp-obj.max-increase
    v-increase-pc  = buf_gds-grp-obj.increase-pc
    v-round-method = buf_gds-grp-obj.round-method
    v-base         = buf_gds-grp-obj.round-coef
    .
    assign
    p-exists-margin = (if v-min-value <> ? and v-max-value <> ? and p-min-value = ?
                        then yes
                        else p-exists-margin)
    p-range-margin = if p-exists-margin and p-min-value = ?
                      then v-range
                      else p-range-margin
    p-min-value   =  if p-exists-margin and  p-min-value = ?
                      then v-min-value
                      else p-min-value
    p-max-value   =  if p-exists-margin and  p-max-value = ?
                      then v-max-value
                      else p-max-value
    p-exists-increase = (if v-increase-pc <> ? and p-increase-pc = ?
                        then yes
                        else p-exists-increase)
    p-range-increase = if p-exists-increase and p-increase-pc = ?
                      then v-range
                      else p-range-increase
    p-increase-pc = (if p-exists-increase and p-increase-pc = ?
                      then v-increase-pc
                      else p-increase-pc)
    p-exists-rmethod = if v-round-method <> "":U and p-round-method = "":U
                        then yes
                        else p-exists-rmethod
    p-range-rmethod = (if p-exists-rmethod and p-round-method = "":U
                        then v-range
                        else p-range-rmethod)
    p-round-method  = (if p-exists-rmethod and p-round-method = "":U
                        then v-round-method
                        else p-round-method)
    p-base          = (if p-exists-rmethod and p-base = ?
                        then v-base
                        else p-base)
    v-found =  (p-exists-margin and p-exists-increase and p-exists-rmethod) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-margin and p-exists-increase and p-exists-rmethod ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
procedure grp-obj-income-cli-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define output parameter p-cli-type as character    no-undo init ?.
define output parameter p-cli-code as integer      no-undo init ?.
define output parameter p-range-income-cli     as integer      no-undo.
define output parameter p-exists-income-cli    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-income-cli-found as logical no-undo .
DEFINE VARIABLE v-cli-type-value as char      no-undo.
DEFINE VARIABLE v-cli-code-value as int      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    assign
    v-cli-type-value    = buf_gds-grp-obj.cli-type
    v-cli-code-value    = buf_gds-grp-obj.cli-code
    .
    assign
    p-exists-income-cli = (if v-cli-type-value <> ? and v-cli-code-value <> ? and p-cli-type = ?
                        then yes
                        else p-exists-income-cli)
    p-range-income-cli = if p-exists-income-cli and p-cli-type = ?
                      then v-range
                      else p-range-income-cli
    p-cli-type   =  if p-exists-income-cli and  p-cli-type = ?
                      then v-cli-type-value
                      else p-cli-type
    p-cli-code   =  if p-exists-income-cli and  p-cli-code = ?
                      then v-cli-code-value
                      else p-cli-code
    v-found =  (p-exists-income-cli ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-income-cli  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
function hvrdtax return logical (input parrecid as recid):
define variable varresult as logical no-undo.
run hvrdtax-proc (input parrecid, output varresult).
return varresult.
end function.
procedure hvrdtax-proc:
define input  parameter parrecid  as recid   no-undo.
define output parameter parresult as logical no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_units for ub.units.
define buffer rt_tax   for ub.tax.
find first rt_tax   where rt_tax.tax-code    = integer('3':U) no-lock no-error.
find first bf_goods where recid(bf_goods)    = parrecid              no-lock.
find first bf_units where bf_units.unit-name = bf_goods.unit-base    no-lock.
if available rt_tax and
    can-find(first ub.tax-units No-LOCK WHERE
                   ub.tax-units.tax-code = rt_tax.tax-code AND
                   LOOKUP(ub.tax-units.type, bf_units.type) > 0) then assign parresult = yes.
                                                    else assign parresult = no.
end procedure.
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
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
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-use-bar-code :
  define input  parameter p-b-code    like ub.bar-code.b-code no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info10, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info10 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info10 )
  :
    define buffer buf_bar-code for ub.bar-code .
    find first buf_bar-code no-lock
      where buf_bar-code.b-code     = p-b-code
      no-error .
    if not available buf_bar-code then do:
      return error substitute( "&1 (check-use-bar-code). Не найден бар-код &2", vss-include-info10, p-b-code ) .
    end.
    if buf_bar-code.stts = integer('99':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Выполняется удаление бар-кода"
                              ,vss-include-info10
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    if buf_bar-code.stts = integer('79':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Бар-код выключен"
                              ,vss-include-info10
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    return .
  end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable var-pr-r-b as character no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-pr-r-b
  )  .
function fnc-cost-pc return decimal (buffer local-price-list for ub.price-list).
define variable f-cost     as decimal no-undo .
define variable f-cost-pc  as decimal no-undo .
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = local-price-list.obj-type and
     ub.gds-obj.obj-code = local-price-list.obj-code no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = 'т':U then
    assign
      f-cost = ( if var-pr-r-b = "rubl" then ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base)
      .
    else  f-cost = ?.
else f-cost = ?.
 f-cost-pc = (round(local-price-list.price-sale / f-cost , 2) - 1) * 100.
  if f-cost-pc > 9999 then
    f-cost-pc = ?.
  return (f-cost-pc).
end function.
function fnc-pr-pc return decimal (buffer local-price-list for ub.price-list).
define variable f-pr     as decimal no-undo .
define variable f-pr-pc  as decimal no-undo.
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = local-price-list.obj-type and
     ub.gds-obj.obj-code = local-price-list.obj-code  no-error .
if  available ub.gds-obj then do:
  if ub.goods.gds-type = 'т':U then
    assign
      f-pr = (if var-pr-r-b = "rubl" then ub.gds-obj.last-rubl else ub.gds-obj.last-base)
      .
    else f-pr = ?.
end.
else f-pr = ?.
  f-pr-pc = ( local-price-list.price-sale / f-pr - 1 ) * 100.
  if f-pr-pc > 9999 then
    f-pr-pc = ?.
  return (f-pr-pc).
end function.
function fnc-cost return decimal (buffer local-price-list for ub.price-list).
define variable f-cost   as decimal no-undo .
find first ub.goods where
           ub.goods.artic = local-price-list.artic and
           ub.goods.prod-type = local-price-list.prod-type and
           ub.goods.prod-code = local-price-list.prod-code no-lock
           no-error .
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = local-price-list.obj-type and
     ub.gds-obj.obj-code = local-price-list.obj-code no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = 'т':U then
    assign
      f-cost = if var-pr-r-b = "rubl" then ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base
      .
    else  f-cost = ?.
else f-cost = ?.
  return ( f-cost ).
end function.
function fnc-pr return decimal (buffer local-price-list for ub.price-list).
define variable f-pr   as decimal no-undo .
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = local-price-list.obj-type and
     ub.gds-obj.obj-code = local-price-list.obj-code no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = 'т':U then
    assign
      f-pr = if var-pr-r-b = "rubl" then ub.gds-obj.last-rubl  else ub.gds-obj.last-base
      .
    else  f-pr = ?.
else f-pr = ?.
   return ( f-pr ).
end function.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION fnc-base-price RETURN decimal (local-bc      as integer,
                                        local-doc-num as char).
define buffer base-price        for ub.price-list.
define variable local-main-code like ub.bar-code.b-code no-undo.
define variable local-base-code like ub.bar-code.b-code no-undo.
  run prc-base-code (input local-bc, output local-base-code).
  find base-price no-lock where
       base-price.doc-num = local-doc-num and
       base-price.b-code  = local-base-code and
       base-price.price-type = "" no-error.
  if not available base-price then do:
    run prc-main-code (input local-bc, output local-main-code).
    find  base-price no-lock where
          base-price.doc-num = local-doc-num and
          base-price.b-code  = local-main-code and
          base-price.price-type = "" no-error.
  end.
  if available base-price then
    return (base-price.price-sale).
  else
    return (?).
END FUNCTION.
procedure prc-main-code:
define input  parameter local-bc        like ub.bar-code.b-code no-undo.
define output parameter local-main-code like ub.bar-code.b-code no-undo.
define buffer local-bar-code        for ub.bar-code.
define buffer local-goods           for ub.goods.
define buffer main-code             for ub.bar-code.
define buffer main-prt              for ub.gds-prt.
  local-main-code = ?.
  find local-bar-code no-lock where
       local-bar-code.b-code = local-bc no-error.
  if not available local-bar-code then
    return.
  find local-goods no-lock where
       local-goods.gds-code = local-bar-code.gds-code.
  find first  main-prt no-lock where
              main-prt.upper-code = local-goods.prt-root.
  find  main-code no-lock where
        main-code.gds-code  = local-bar-code.gds-code and
        main-code.in-code   = "" and
        main-code.part-code = "" and
        main-code.unit-cli  = local-goods.unit-base and
        main-code.node-code = main-prt.node-code.
  local-main-code = main-code.b-code.
end procedure.
procedure prc-base-code:
define input  parameter local-bc        like ub.bar-code.b-code no-undo.
define output parameter local-base-code like ub.bar-code.b-code no-undo.
define buffer local-bar-code for ub.bar-code.
define buffer local-goods    for ub.goods.
define buffer base-code      for ub.bar-code.
  local-base-code = ?.
  find local-bar-code no-lock where
       local-bar-code.b-code = local-bc no-error.
  if not available local-bar-code then
    return.
  find local-goods no-lock where
       local-goods.gds-code = local-bar-code.gds-code.
  find base-code no-lock where
       base-code.gds-code  = local-bar-code.gds-code and
       base-code.node-code = local-bar-code.node-code and
       base-code.in-code   = local-bar-code.in-code and
       base-code.part-code = local-bar-code.part-code and
       base-code.unit-cli  = local-goods.unit-base.
  local-base-code = base-code.b-code.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prcreate-new-price-doc :
do
on error undo, return error return-value
:
define input  parameter p-curr-db-num  as integer   no-undo .
define input  parameter p-obj-type     like ub.price-doc.obj-type no-undo.
define input  parameter p-obj-code     like ub.price-doc.obj-code no-undo.
define input  parameter p-plt-id       as integer   no-undo .
define input  parameter p-plt-db-num   as integer   no-undo .
define input  parameter p-pdf-id       as integer   no-undo .
define input  parameter p-pdf-db-num   as integer   no-undo .
define output parameter p-price-doc-recid  as recid                no-undo.
define variable v-host-code         like ub.sysconf.host-code        no-undo.
define variable v-obj-current-date  like ub.price-doc.doc-date      no-undo.
define variable v-base-rate    like ub.price-doc-forming.base-rate   no-undo .
define variable v-base-scale   like ub.price-doc-forming.base-scale  no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming.
define buffer buf_price-doc         for ub.price-doc.
find first buf_price-doc-forming no-lock where
           buf_price-doc-forming.pdf-db     = p-pdf-db-num and
           buf_price-doc-forming.pdf-id     = p-pdf-id     and
           buf_price-doc-forming.plt-db-num = p-plt-db-num and
           buf_price-doc-forming.plt-id     = p-plt-id
           no-error .
if not available buf_price-doc-forming and p-plt-id = ? then do:
   run create_new_price-doc-forming
        ( input p-obj-type ,
          input p-obj-code ,
          output p-pdf-db-num ,
          output p-pdf-id ,
          output p-plt-db-num ,
          output p-plt-id
          ).
    find first buf_price-doc-forming no-lock where
              buf_price-doc-forming.pdf-db     = p-pdf-db-num and
              buf_price-doc-forming.pdf-id     = p-pdf-id     and
              buf_price-doc-forming.plt-db-num = p-plt-db-num and
              buf_price-doc-forming.plt-id     = p-plt-id
              no-error .
end.
    create buf_price-doc .
    run doc-code in this-procedure
    (input  "main",
     input  p-obj-type  ,
     input  p-obj-code  ,
     input  ?,
     output buf_price-doc.doc-num) no-error.
    if error-status:error then do:
      message vss-workfile vss-revision vss-description skip
             error-status :get-message(1)
            "Ошибка при генерации номера документа." return-value view-as alert-box error.
      return error.
    end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    v-obj-current-date  = today .
    if not (buf_price-doc-forming.base-rate = 0 or buf_price-doc-forming.base-rate = ?) then do:
        v-base-rate   =  buf_price-doc-forming.base-rate  .
        v-base-scale  =  buf_price-doc-forming.base-scale .
    end.
    else do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  v-obj-current-date
  ,output v-base-rate
  ,output v-base-scale
  )  .
    end.
   assign
    buf_price-doc.base-rate      = v-base-rate
    buf_price-doc.base-scale     = v-base-scale
    buf_price-doc.cr-db-num      = p-curr-db-num
    buf_price-doc.doc-date       = v-obj-current-date
    buf_price-doc.fact-num       = 0
    buf_price-doc.host-code      = v-host-code
    buf_price-doc.is-corr        = false
    buf_price-doc.is-del         = false
    buf_price-doc.obj-code       = p-obj-code
    buf_price-doc.obj-type       = p-obj-type
    buf_price-doc.out-code       = ""
    buf_price-doc.pdf-db         = p-pdf-db-num
    buf_price-doc.pdf-id         = p-pdf-id
    buf_price-doc.plt-db-num     = p-plt-db-num
    buf_price-doc.plt-id         = p-plt-id
    buf_price-doc.PS             = "@ "
    buf_price-doc.rest-base      = 0
    buf_price-doc.rest-last      = 0
    buf_price-doc.rest-qnty      = 0
    buf_price-doc.rest-sale      = 0
    buf_price-doc.sale-base      = 0
    buf_price-doc.status_        = 'новый':U
    .
    buf_price-doc.doc-num-es     = entry(1, buf_price-doc-forming.des, chr(4)) no-error.
    buf_price-doc.uid-es         = entry(2, buf_price-doc-forming.des, chr(4)) no-error.
    buf_price-doc.doc-date       = date(entry(3, buf_price-doc-forming.des, chr(4))) no-error.
    if buf_price-doc.uid-es = "_" then buf_price-doc.uid-es = "" .
    assign
        p-price-doc-recid = recid ( buf_price-doc )
    .
end.
end procedure.
procedure prcreate-new-price-list :
do
on error undo, return error return-value
:
define input parameter p-price-doc-recid   as recid                    no-undo.
define input parameter p-gds-code          like ub.goods.gds-code         no-undo.
define input parameter p-price-sale        like ub.price-list.price-sale  no-undo.
define output parameter p-update           as logical                  no-undo.
define variable kk as integer no-undo .
define var v-b-code    like ub.bar-code.b-code     no-undo.
define variable p-hostcode as int no-undo .
define variable local_vat-pc like ub.price-list.vat-pc    no-undo.
define variable local_slt-pc like ub.price-list.slt-pc    no-undo.
define buffer buf_price-doc        for ub.price-doc.
define buffer buf_price-list       for ub.price-list.
define buffer buf_bar-code         for ub.bar-code.
define buffer buf_goods            for ub.goods.
define buffer buf_root_gds-prt     for ub.gds-prt.
define buffer buf_gds-prt          for ub.gds-prt.
find first buf_price-doc no-lock
     where recid( buf_price-doc ) = p-price-doc-recid
.
find first buf_goods no-lock
     where buf_goods.gds-code = p-gds-code
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  ?
  ,output v-b-code
  ) no-error .
if error-status :error
then do:
    message
        "Не найден основной бар-код"
        skip "для товара "
        skip string(buf_goods.artic)
        skip buf_goods.gds-name
    view-as alert-box
    title "Ошибка при выполнении prcreate.i".
    undo, return error .
end.
find first buf_bar-code no-lock
     where buf_bar-code.b-code = v-b-code
no-error.
if error-status :error
then do:
    message
        "Не найдена запись bar-code"
        skip "для товара "
        skip string(buf_goods.artic)
        skip buf_goods.gds-name
        skip "С основным бар-кодом"
        skip string(v-b-code)
    view-as alert-box
    title "Ошибка при выполнении prcreate.i".
    undo, return error .
end.
find first buf_root_gds-prt no-lock
     where buf_root_gds-prt.upper-code = buf_goods.prt-root
.
if buf_root_gds-prt.node-name <> '_Пустая шкала':U
  and buf_bar-code.in-code <> ""
then do:
    message
        "Не допускается создавать спец. цены на партии для товаров с непустой шкалой!" skip (2)
        "Артикул:" buf_goods.artic "Код:" buf_goods.gds-code buf_goods.gds-name
        view-as alert-box error.
    undo, return error.
end.
find first buf_gds-prt no-lock
     where buf_gds-prt.node-code = buf_bar-code.node-code
.
find first buf_price-list
     where buf_price-list.doc-num = buf_price-doc.doc-num
       and buf_price-list.b-code  = v-b-code
no-error.
if available buf_price-list
then do:
    message "Строка с товаром арт." buf_price-list.artic " уже есть в данной переоценке."
       skip "  Цена:   " buf_price-list.price-sale
       skip "Цена будет изменена"
    view-as alert-box warning.
    assign
        p-update = yes
    .
end.
else do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_slt-pc
  ) no-error .
    kk = kk + 1.
define variable v-main-bar-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-bar-code
  )  .
    create buf_price-list.
    assign
        buf_price-list.line-num    = kk
        buf_price-list.doc-num     = buf_price-doc.doc-num
        buf_price-list.b-code      = buf_bar-code.b-code
        buf_price-list.artic       = buf_goods.artic
        buf_price-list.prod-type   = buf_goods.prod-type
        buf_price-list.prod-code   = buf_goods.prod-code
        buf_price-list.main-price  = (buf_bar-code.b-code = v-main-bar-code )
        buf_price-list.calc-method = 'Отсутствует':U
        buf_price-list.obj-type    = buf_price-doc.obj-type
        buf_price-list.obj-code    = buf_price-doc.obj-code
        buf_price-list.price-sale  = p-price-sale
        buf_price-list.vat-pc      = local_vat-pc
        buf_price-list.slt-pc      = local_slt-pc
        p-update                   = no
    .
end.
end.
end procedure.
procedure create_new_price-doc-forming :
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-plt-db-num as integer   no-undo .
define output parameter p-plt-id     as integer   no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
define variable v-host-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as integer   no-undo .
define variable v-base as logical   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  )  .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplobj in g#library2
  (input  ?
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  yes
  ,output p-plt-id
  ,output p-plt-db-num
  )  .
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id       = p-plt-id
      ub.price-doc-forming.plt-db-num   = p-plt-db-num
      ub.price-doc-forming.pdf-id       = next-value ( s-pdf , ub)
      ub.price-doc-forming.pdf-db       = v-cntxt-db-num
      ub.price-doc-forming.base-rate    = v-base-rate
      ub.price-doc-forming.base-scale   = v-base-scale
      ub.price-doc-forming.db-num-chg   = v-cntxt-db-num
      ub.price-doc-forming.exch-rate    = if v-base then v-base-rate else 1
      ub.price-doc-forming.exch-scale   = if v-base then v-base-scale else 1
      ub.price-doc-forming.stts         = 0
      ub.price-doc-forming.sys-date     = today
      ub.price-doc-forming.sys-time     = time
      ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who          = v-cntxt-userid
      ub.price-doc-forming.name         = "автосоздание"
   .
   assign
    p-pdf-db-num  = ub.price-doc-forming.pdf-db
    p-pdf-id      = ub.price-doc-forming.pdf-id
    p-plt-db-num  = ub.price-doc-forming.plt-db-num
    p-plt-id      = ub.price-doc-forming.plt-id
   .
  end.
end procedure.
procedure prcreate-new-price-doc-forming-gds :
define input  parameter p-price-doc-forming-recid as recid  no-undo.
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter par-pr-notls as character no-undo .
define input  parameter par-pr-altex as character no-undo .
define input  parameter par-pr-sclex as character no-undo .
define input  parameter p-line-num    as integer   no-undo .
define input  parameter p-gds-code    as integer   no-undo .
define input  parameter p-price-sale  as decimal   no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
define buffer main_bar-code for ub.bar-code  .
define variable main-b-code as integer   no-undo .
define variable v-sec as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal   no-undo .
define variable v-cur-rt as decimal   no-undo .
define variable v-cur-ex as decimal   no-undo .
find first buf_price-doc-forming no-lock where
           recid(buf_price-doc-forming) = p-price-doc-forming-recid  no-error .
           if error-status :error then return error .
find first buf_goods no-lock where
           buf_goods.gds-code  = p-gds-code no-error .
           if error-status :error then return error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output main-b-code
  ) no-error .
run check-use-bar-code (main-b-code) no-error .
if error-status :error then return .
run create-line-pdf-mpl-lib (
     input buf_price-doc-forming.plt-db-num
    ,input buf_price-doc-forming.plt-id
    ,input buf_price-doc-forming.pdf-db
    ,input buf_price-doc-forming.pdf-id
    ,input p-line-num
    ,input main-b-code
    ,input buf_goods.artic
    ,input buf_goods.prod-type
    ,input buf_goods.prod-code
    ,input ""
    ,input 0
    ,input p-price-sale
    ,input ""
    ,input 0
   ,input-output v-sec ) no-error .
   if error-status :error  then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "2"
       view-as alert-box error
     .
   end.
define buffer old_price-list for ub.price-list  .
if par-pr-notls = "yes" then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  main-b-code
  ,input  0
  ,input  0
  ,output v-cur-dn
  ,output v-cur-pr
  ,output v-cur-rt
  ,output v-cur-ex
  )  .
end.
if par-pr-altex = "yes" and
   par-pr-notls = "yes" then do:
    if v-cur-dn <> "" then do:
        for each old_price-list no-lock where
                 old_price-list.doc-num = v-cur-dn and
                 old_price-list.artic      = buf_goods.artic and
                 old_price-list.prod-type  = buf_goods.prod-type and
                 old_price-list.prod-code  = buf_goods.prod-code and
                 old_price-list.main-price = no,
                first buf_bar-code no-lock where
                      buf_bar-code.b-code   = old_price-list.b-code and
                      buf_bar-code.unit-cli <> buf_goods.unit-base
                      :
                       run check-use-bar-code (buf_bar-code.b-code) no-error .
                       if error-status :error then next.
                 run create-line-pdf-mpl-lib (
                       input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input p-line-num
                      ,input old_price-list.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input old_price-list.price-sale
                      ,input ""
                      ,input 0
                     ,input-output v-sec ) no-error .
        end.
    end.
end.
if par-pr-sclex = "yes" and
   par-pr-notls = "yes" then do:
    if v-cur-dn <> "" then do:
        for each old_price-list no-lock where
                 old_price-list.doc-num    = v-cur-dn and
                 old_price-list.artic      = buf_goods.artic and
                 old_price-list.prod-type  = buf_goods.prod-type and
                 old_price-list.prod-code  = buf_goods.prod-code and
                 old_price-list.main-price = no,
                first buf_bar-code no-lock where
                      buf_bar-code.b-code   = old_price-list.b-code and
                      buf_bar-code.in-code  = "" and
                      buf_bar-code.unit-cli = buf_goods.unit-base
                      :
                       run check-use-bar-code (buf_bar-code.b-code) no-error .
                       if error-status :error then next.
                 run create-line-pdf-mpl-lib (
                       input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input p-line-num
                      ,input old_price-list.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input old_price-list.price-sale
                      ,input ""
                      ,input 0
                    ,input-output v-sec ) no-error .
        end.
    end.
end.
end.
end procedure.
procedure copy_new_price-doc-forming :
define input  parameter       p-recid      as recid no-undo .
define input-output parameter p-plt-db-num as integer   no-undo .
define input-output parameter p-plt-id     as integer   no-undo .
define output parameter       p-pdf-db-num as integer   no-undo .
define output parameter       p-pdf-id     as integer   no-undo .
define buffer buf_price-list-type        for ub.price-list-type  .
define buffer buf_price-doc-forming      for ub.price-doc-forming .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr .
define buffer buf_price-doc-forming-gds  for ub.price-doc-forming-gds .
define buffer buf_pd-forming-gds-attr    for ub.price-doc-forming-gdsattr .
define variable v-host-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as integer   no-undo .
define variable v-base as logical   no-undo .
define variable v-name as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
find first buf_price-list-type no-lock where
           buf_price-list-type.plt-db-num = p-plt-db-num and
           buf_price-list-type.plt-id     = p-plt-id no-error .
if error-status :error then return error "Не найден ТПЛ".
if buf_price-list-type.stts <> 0 then return error "ТПЛ удален" .
find first buf_price-doc-forming  no-lock where recid(buf_price-doc-forming )  = p-recid no-error .
    if available buf_price-doc-forming then do :
        assign
          v-base-rate  = buf_price-doc-forming.base-rate
          v-base-scale = buf_price-doc-forming.base-scale
          v-name       =  substitute("Скопировано с ДНЦ &1 &2",  buf_price-doc-forming.pdf-id , trim(buf_price-doc-forming.name)  )
        .
    end.
    else do:
        assign
          v-base-rate  = 1
          v-base-scale = 1
          v-name       = "Автосоздание"
        .
    end.
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id       = p-plt-id
      ub.price-doc-forming.plt-db-num   = p-plt-db-num
      ub.price-doc-forming.pdf-id       = next-value ( s-pdf , ub)
      ub.price-doc-forming.pdf-db       = v-cntxt-db-num
      ub.price-doc-forming.base-rate    = v-base-rate
      ub.price-doc-forming.base-scale   = v-base-scale
      ub.price-doc-forming.db-num-chg   = v-cntxt-db-num
      ub.price-doc-forming.exch-rate    = if v-base then v-base-rate else 1
      ub.price-doc-forming.exch-scale   = if v-base then v-base-scale else 1
      ub.price-doc-forming.stts         = 0
      ub.price-doc-forming.sys-date     = today
      ub.price-doc-forming.sys-time     = time
      ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who          = v-cntxt-userid
      ub.price-doc-forming.name         = v-name
   .
   assign
    p-pdf-db-num  = ub.price-doc-forming.pdf-db
    p-pdf-id      = ub.price-doc-forming.pdf-id
    p-plt-db-num  = ub.price-doc-forming.plt-db-num
    p-plt-id      = ub.price-doc-forming.plt-id
   .
  end.
  if not available buf_price-doc-forming then return .
for each buf_price-doc-forming-attr no-lock where
         buf_price-doc-forming-attr.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_price-doc-forming-attr.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_price-doc-forming-attr.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_price-doc-forming-attr.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-attr.
    buffer-copy buf_price-doc-forming-attr to ub.price-doc-forming-attr
    assign
      ub.price-doc-forming-attr.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-attr.plt-id      = p-plt-id
      ub.price-doc-forming-attr.pdf-db     = p-pdf-db-num
      ub.price-doc-forming-attr.pdf-id      = p-pdf-id
      .
end.
for each buf_price-doc-forming-gds no-lock where
         buf_price-doc-forming-gds.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_price-doc-forming-gds.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_price-doc-forming-gds.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_price-doc-forming-gds.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-gds.
    buffer-copy buf_price-doc-forming-gds to ub.price-doc-forming-gds
    assign
      ub.price-doc-forming-gds.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-gds.plt-id      = p-plt-id
      ub.price-doc-forming-gds.pdf-db      = p-pdf-db-num
      ub.price-doc-forming-gds.pdf-id      = p-pdf-id
    .
end.
for each buf_pd-forming-gds-attr no-lock where
         buf_pd-forming-gds-attr.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_pd-forming-gds-attr.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_pd-forming-gds-attr.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_pd-forming-gds-attr.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-gdsattr.
    buffer-copy buf_pd-forming-gds-attr to ub.price-doc-forming-gdsattr
    assign
      ub.price-doc-forming-gdsattr.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-gdsattr.plt-id      = p-plt-id
      ub.price-doc-forming-gdsattr.pdf-db      = p-pdf-db-num
      ub.price-doc-forming-gdsattr.pdf-id      = p-pdf-id
    .
end.
end procedure.
define variable par-pr-incpc as character no-undo.
define variable par-pr-rndmt as character no-undo.
define variable par-pr-rndbs as character no-undo.
define variable par-pr-clt-q as character no-undo.
define variable par-pr-dpl-q as character no-undo.
define variable par-pr-rdc-q as character no-undo.
define variable par-pr-abs-d as character no-undo.
define variable par-pr-altex as character no-undo.
define variable par-pr-parex as character no-undo.
define variable par-pr-sclex as character no-undo.
define variable par-pr-notls as character no-undo.
define variable par-pr-equ-dq as integer  no-undo.
define variable par-pr-discm as character no-undo .
define variable par-pr-dscnt as character no-undo .
define variable par-pr-print as character no-undo .
define variable par-pr-sigma as character no-undo .
define variable par-pr-goods as character no-undo.
define variable par-pr-nogds as character no-undo.
define variable par-alcohol  as character no-undo.
define variable par-gen-mrgn-ie as character no-undo .
define variable par-gen-mrgn-iv as character no-undo .
define variable par-gen-mrgn-im as character no-undo .
define variable par-pr-nakl-ie  as logical   no-undo .
define variable par-pr-nakl-iv  as logical   no-undo .
define variable par-pr-nakl-im  as logical   no-undo .
define variable par-pr-nogds-long as longchar no-undo .
define temp-table tmp-proof-price no-undo
  field node-code like ub.gds-grp.node-code
  field proof as decimal
  field price as decimal
index pi node-code proof descending .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ggoattr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
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
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
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
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
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
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
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
end procedure.
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
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
end procedure.
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info31 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
procedure  chec-par :
define output parameter l-par as logical no-undo .
define input parameter l-host like ub.clients.obj-code no-undo .
define input parameter l-type like ub.clients.obj-type no-undo .
define input parameter l-code like ub.clients.obj-code no-undo .
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'alcohol'
  ,input  l-host
  ,input  l-type
  ,input  l-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-alcohol
  ,output par-type
  ) no-error .
 .
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input l-type
  ,input l-code
  ,input 'overval':U
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
    if thbjattr_thbj-attr.prop-code = 'pr-clt-q':U then par-pr-clt-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-dpl-q':U then par-pr-dpl-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-rdc-q':U then par-pr-rdc-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-equ-dq':U then par-pr-equ-dq = thbjattr_thbj-attr.property-value-integer .
    if thbjattr_thbj-attr.prop-code = 'pr-abs-d':U then par-pr-abs-d = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-altex':U then par-pr-altex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-parex':U then par-pr-parex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-sclex':U then par-pr-sclex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-discm':U then par-pr-discm =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'pr-dscnt':U then par-pr-dscnt  = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-print':U then par-pr-print  = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-sigma':U then par-pr-sigma  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-incpc':U then par-pr-incpc  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-rndmt':U then par-pr-rndmt  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'pr-rndbs':U then par-pr-rndbs  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-notls':U then par-pr-notls = string ( thbjattr_thbj-attr.property-value-logical) .
    if v-cntxt-db-num = 0 then do:
      if thbjattr_thbj-attr.prop-code = 'pr-nogds0':U then par-pr-nogds =  thbjattr_thbj-attr.property-value-character.
      if thbjattr_thbj-attr.prop-code = 'pr-goods0':U then par-pr-goods =  thbjattr_thbj-attr.property-value-character.
    end.
    else do:
      if thbjattr_thbj-attr.prop-code = 'pr-nogds':U then par-pr-nogds =  thbjattr_thbj-attr.property-value-character.
      if thbjattr_thbj-attr.prop-code = 'pr-goods':U then par-pr-goods =  thbjattr_thbj-attr.property-value-character.
    end.
end.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplmrgn in g#library2
  (input  ?
  ,input  l-type
  ,input  l-code
  ,output par-gen-mrgn-ie
  ,output par-gen-mrgn-iv
  ,output par-gen-mrgn-im
  ) no-error .
   IF error-status :error THEN message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "gbl/gtplmrgn.i"
     view-as alert-box error
   .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplpnakl in g#library2
  (input  ?
  ,input  l-type
  ,input  l-code
  ,output par-pr-nakl-ie
  ,output par-pr-nakl-iv
  ,output par-pr-nakl-im
  ) no-error .
   define variable ii as integer   no-undo .
   define variable nn as integer   no-undo .
   define variable v-fullname as character no-undo .
   nn = num-entries ( par-pr-nogds ).
   par-pr-nogds-long = "".
   if par-pr-nogds <> "0" and par-pr-nogds <> ""  then do:
      repeat ii = 1 to nn :
        run grplib-get-full-name  ( input integer(entry(ii,par-pr-nogds)) , output v-fullname ) .
        par-pr-nogds-long = par-pr-nogds-long + v-fullname + chr(4) .
      end.
      par-pr-nogds-long = trim (par-pr-nogds-long,chr(4)) .
   end.
l-par = true .
end procedure.
PROCEDURE cre-pr-list:
define input  parameter bc      like ub.price-list.b-code no-undo.
define input  parameter new-num like ub.price-doc.doc-num no-undo.
define output parameter new-rec as recid             no-undo.
define buffer buf-price-list for ub.price-list.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer buf-gds-prt    for ub.gds-prt.
define buffer root-gds-prt   for ub.gds-prt.
define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable local_vat-pc like ub.price-list.vat-pc    no-undo.
define variable local_slt-pc like ub.price-list.slt-pc    no-undo.
define variable cur-rt-base as decimal no-undo .
define variable cur-rt-rubl as decimal no-undo .
define variable p-hostcode as int no-undo .
define variable v-line-num as integer no-undo .
define variable v-skip-del-gds as logical no-undo initial no .
cre-pr:
do on error undo cre-pr, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  run check-use-bar-code ( buf-bar-code.b-code ) no-error .
  if error-status :error then do:
    message
      return-value skip
      "Ошибка !"
      view-as alert-box error
    .
    undo cre-pr, return.
  end.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find first root-gds-prt no-lock where
            root-gds-prt.upper-code = buf-goods.prt-root.
  if root-gds-prt.node-name <> '_Пустая шкала':U and
    buf-bar-code.in-code <> "" then do:
    message
      "Не допускается создавать спец. цены на партии для товаров с непустой шкалой!" skip (2)
      "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
      view-as alert-box error.
    undo cre-pr, return.
  end.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  if buf-goods.stts <> 0 and not v-skip-del-gds then do:
    message
      "Не допускается создавать цены на удаленные товары!" skip (2)
      "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
      view-as alert-box error.
    undo cre-pr, return.
  end.
  find  buf-price-doc where
        buf-price-doc.doc-num = new-num.
define variable v-ret as logical no-undo .
   run ver-modificator-price-is-null (
          input    buf-goods.artic        ,
          input    buf-goods.prod-type    ,
          input    buf-goods.prod-code    ,
          input    buf-price-doc.obj-type   ,
          input    buf-price-doc.obj-code   ,
          output   v-ret ).
      if v-ret = false then dO:
          message
            "Не допускается создавать цены на модификаторы с нулевой ценой !" skip (2)
            "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
            view-as alert-box error.
          undo cre-pr, return.
        end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_slt-pc
  ) no-error .
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,input  bc
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  ) no-error .
  find first buf-price-list where
            buf-price-list.b-code  = buf-bar-code.b-code and
            buf-price-list.doc-num = new-num  and
            buf-price-list.price-type = ""    no-error .
  if not available buf-price-list then do:
    run calc-price-line-num (input  new-num , output v-line-num) .
    create buf-price-list.
    assign
      buf-price-list.line-num  = v-line-num
      buf-price-list.b-code    = buf-bar-code.b-code
      buf-price-list.doc-num   = buf-price-doc.doc-num
      buf-price-list.prod-type = buf-goods.prod-type
      buf-price-list.prod-code = buf-goods.prod-code
      buf-price-list.artic     = buf-goods.artic
      buf-price-list.obj-type  = buf-price-doc.obj-type
      buf-price-list.obj-code  = buf-price-doc.obj-code
      buf-price-list.vat-pc    = local_vat-pc
      buf-price-list.slt-pc    = local_slt-pc
      buf-price-list.price-prev = cur-pr
      .
    if  buf-gds-prt.upper-code = buf-goods.prt-root and
        buf-bar-code.in-code   = "" and
        buf-bar-code.part-code = "" and
        buf-bar-code.unit-cli  = buf-goods.unit-base then do:
      buf-price-list.main-price = yes.
      if cur-pr <> ? then do:
        run exp-prt (input buf-goods.gds-code,
                    input cur-dn,
                    input new-num,
                    output new-rec) no-error.
        if error-status :error then do:
          message
            "Ошибка вызова процедуры разворота специальных и неосновных цен."
            view-as alert-box error.
          undo cre-pr, return error.
        end.
      end.
    end.
    else do:
      if buf-bar-code.unit-cli <> buf-goods.unit-base then do:
        buf-price-list.d-pcnt = ?.
      end.
      buf-price-list.main-price = no.
    end.
  end.
end.
new-rec = recid (buf-price-list).
END PROCEDURE.
procedure calc-price-line-num :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-doc-num as character no-undo .
define output parameter p-num  as integer no-undo .
define variable v-fact as integer no-undo .
define buffer buf_1_price-list for ub.price-list .
p-num = 1 .
find last  buf_1_price-list no-lock where
           buf_1_price-list.doc-num = p-doc-num use-index line-num no-error .
           if available buf_1_price-list then
                assign
                  v-fact = buf_1_price-list.line-num
                .
v-fact = v-fact + 1.
if v-fact <> ? then if p-num < v-fact then p-num = v-fact .
 end.
end procedure.
PROCEDURE del-pr-list:
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter round-method as character         no-undo.
define input parameter round-base   as decimal      no-undo.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define variable l-ov-on as logical no-undo .
del-pr:
do on error undo del-pr, return error:
  find first  buf-price-list no-lock where
              buf-price-list.doc-num    = d-num and
              buf-price-list.b-code     = bc and
              buf-price-list.price-type = "" no-error.
  if not available buf-price-list then
    undo del-pr, return error.
  find  buf-goods no-lock where
        buf-goods.prod-type = buf-price-list.prod-type and
        buf-goods.prod-code = buf-price-list.prod-code and
        buf-goods.artic     = buf-price-list.artic.
  if buf-price-list.main-price then do:
    for each  buf-price-list exclusive-lock where
              buf-price-list.doc-num   = d-num and
              buf-price-list.artic     = buf-goods.artic and
              buf-price-list.prod-type = buf-goods.prod-type and
              buf-price-list.prod-code = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code = buf-price-list.b-code
    on error undo del-pr, return error:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.buf-price-list.obj-type
  ,input  ub.buf-price-list.obj-code
  ,input  ub.buf-price-list.artic
  ,input  ub.buf-price-list.prod-type
  ,input  ub.buf-price-list.prod-code
  ,input  'ov-on=request:exclusive'
  ,output l-ov-on
  ) no-error .
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка получения признака товара на объекте" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      if l-ov-on then do:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.buf-price-list.obj-type
  ,input  ub.buf-price-list.obj-code
  ,input  ub.buf-price-list.artic
  ,input  ub.buf-price-list.prod-type
  ,input  ub.buf-price-list.prod-code
  ,input  'ov-on=false'
  ,output l-ov-on
  ) no-error .
        if error-status :error then do:
        end.
       end.
      delete buf-price-list.
    end.
  end.
  else do:
    find  buf-bar-code no-lock where
          buf-bar-code.b-code = buf-price-list.b-code.
    if buf-bar-code.unit-cli <> buf-goods.unit-base then do:
      message
        "Нельзя удалить неосновную цену." skip
        "Неосновная цена (скидка) не может быть неопределенной." skip
        "Код:" bc skip
        "Переоценка:" d-num
        view-as alert-box error.
      undo del-pr, return error.
    end.
    find current buf-price-list exclusive-lock no-error .
    delete buf-price-list.
    run calc-base-upd (input buf-bar-code.b-code,
                      input d-num,
                      input round-method,
                      input round-base) no-error.
    if error-status :error then
      undo del-pr, return error.
  end.
end.
END PROCEDURE.
PROCEDURE calc-base-upd:
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter round-method as character         no-undo.
define input parameter round-base   as decimal      no-undo.
define buffer alt-bar-code   for ub.bar-code.
define buffer alt-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
calc-base:
do on error undo calc-base, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  for each  alt-bar-code no-lock where
            alt-bar-code.gds-code  = buf-bar-code.gds-code and
            alt-bar-code.node-code = buf-bar-code.node-code and
            alt-bar-code.part-code = buf-bar-code.part-code and
            alt-bar-code.in-code   = buf-bar-code.in-code and
            alt-bar-code.unit-cli <> buf-goods.unit-base,
      each  alt-price-list where
            alt-price-list.doc-num    = d-num and
            alt-price-list.b-code     = alt-bar-code.b-code and
            alt-price-list.price-type = ""
      on error undo calc-base, return error:
    run calc-pr-alt (input d-num,
                    input alt-bar-code.b-code,
                    input round-method,
                    input round-base) no-error.
    if error-status:error then
      undo calc-base, return error.
  end.
end.
END PROCEDURE.
PROCEDURE calc-pr-alt:
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter r-method as character             no-undo.
define input parameter r-base   as decimal              no-undo.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer old-price-list for ub.price-list.
define variable pr-rec   as   recid                  no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.
pr-alt:
do on error undo pr-alt, return error:
  if r-method = ? or
     r-base = ? then do:
    message
      "Нельзя удалить основную цену." skip
      "Не задан способ округления для расчета зависящих от нее неосновных цен." skip
      "Код:" bc skip
      "Переоценка:" d-num
      view-as alert-box error.
    undo pr-alt, return error.
  end.
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-list where
        buf-price-list.doc-num = buf-price-doc.doc-num and
        buf-price-list.b-code  = bc.
  if buf-price-list.d-pcnt = ? then do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,input  bc
  ,input  0
  ,input  0
  ,output pr-rec
  ,output pr-c-b-r
  )  .
    find old-price-list no-lock where
        recid (old-price-list) = pr-rec no-error.
    if available old-price-list and
      old-price-list.b-code = bc then
      buf-price-list.d-pcnt = old-price-list.d-pcnt.
    else
      buf-price-list.d-pcnt = 0.
  end.
   if buf-price-list.d-pcnt = ? then do:
      assign
        buf-price-list.price-sale =   if available old-price-list then old-price-list.price-sale else 0
        buf-price-list.calc-method =  'Не-считать':U + 'Основная':U
        .
  end.
  else do:
      assign
        buf-price-list.price-sale =   fnc-base-price (buf-bar-code.b-code, buf-price-list.doc-num) *
                                      buf-bar-code.cli-base-rate *
                                      (1 - buf-price-list.d-pcnt / 100)
        buf-price-list.calc-method =  'Основная':U
        .
case r-method :
  when '9-окончание':U then do:
    if buf-price-list.price-sale < 29 then do:
      if (buf-price-list.price-sale - truncate (buf-price-list.price-sale, 0)) <> 0 then do:
        assign
          buf-price-list.price-sale = truncate (buf-price-list.price-sale, 0) + 1
        .
      end.
    end.
    else do:
      if (buf-price-list.price-sale modulo 10) < 3 then do:
        assign
          buf-price-list.price-sale = (buf-price-list.price-sale - (buf-price-list.price-sale modulo 100))
              + ( truncate (((buf-price-list.price-sale modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          buf-price-list.price-sale = (buf-price-list.price-sale - (buf-price-list.price-sale modulo 100))
              + ( truncate (((buf-price-list.price-sale modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        buf-price-list.price-sale = round (buf-price-list.price-sale, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if buf-price-list.price-sale < r-base then do:
      assign
        buf-price-list.price-sale = truncate (buf-price-list.price-sale, 0) + 0.99
      .
    end.
    else do:
      assign
        buf-price-list.price-sale = truncate (buf-price-list.price-sale / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      buf-price-list.price-sale = round (buf-price-list.price-sale, 0)
    .
  end.
  when 'Произвольно':U then do:
    if r-base <> 0 then do:
      assign
        buf-price-list.price-sale = round (buf-price-list.price-sale / r-base, 0) * r-base
      .
      if buf-price-list.price-sale = 0 then do:
        assign
          buf-price-list.price-sale = r-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if r-base <> 0 then do:
      if truncate ( buf-price-list.price-sale / r-base, 0 ) <> (buf-price-list.price-sale / r-base) then do:
        assign
          buf-price-list.price-sale = truncate (buf-price-list.price-sale / r-base, 0) * r-base + r-base
        .
      end.
    end.
    if buf-price-list.price-sale = 0 then do:
      assign
        buf-price-list.price-sale = r-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if r-base <> 0 then do:
      assign
        buf-price-list.price-sale = buf-price-list.price-sale * r-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" r-method skip
      "round-base"   r-base   skip
      "price"        buf-price-list.price-sale             skip
      view-as alert-box error .
  end.
end.
  end.
end.
END PROCEDURE.
PROCEDURE calc-pr-discnt:
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter bc    like ub.bar-code.b-code   no-undo.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer old-price-list for ub.price-list.
define variable pr-rec   as   recid                  no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.
pr-discnt:
do on error undo pr-discnt, return error:
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-list where
        buf-price-list.doc-num = buf-price-doc.doc-num and
        buf-price-list.b-code  = bc.
  buf-price-list.d-pcnt = (1 -
                           buf-price-list.price-sale /
                           fnc-base-price (buf-bar-code.b-code, buf-price-list.doc-num) /
                           buf-bar-code.cli-base-rate) *
                           100
                           .
end.
END PROCEDURE.
PROCEDURE calc-pr-sub :
define  input  parameter bc             like ub.price-list.b-code no-undo.
define  input  parameter d-num          like ub.price-doc.doc-num no-undo.
define  input  parameter calc-method  as character    no-undo.
define  input  parameter increase-pc  as decimal      no-undo.
define  input  parameter round-method as character    no-undo.
define  input  parameter round-base   as decimal      no-undo.
define  output parameter calc-rec     as recid        no-undo.
define  buffer buf-price-list for ub.price-list.
define  buffer buf-bar-code   for ub.bar-code.
define  buffer buf-goods      for ub.goods.
define  buffer buf-gds-prt    for ub.gds-prt.
define  buffer buf-gds-grp    for ub.gds-grp.
define  buffer buf-price-doc  for ub.price-doc.
calc-sub:
do on error undo calc-sub, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find  buf-price-list where
        buf-price-list.doc-num    = d-num and
        buf-price-list.b-code     = bc and
        buf-price-list.price-type = "".
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  calc-rec = recid (buf-price-list).
  if buf-price-list.main-price then do:
    for each  buf-price-list where
              buf-price-list.doc-num    = buf-price-doc.doc-num and
              buf-price-list.main-price = no and
              buf-price-list.artic      = buf-goods.artic and
              buf-price-list.prod-type  = buf-goods.prod-type and
              buf-price-list.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code   = buf-price-list.b-code and
              buf-bar-code.unit-cli = buf-goods.unit-base
        on error undo calc-sub, return error:
      run calc-pr-list (input  buf-bar-code.b-code,
                        input  buf-price-list.doc-num,
                        input  calc-method,
                        input  increase-pc,
                        input  round-method,
                        input  round-base,
                        input ? ,
                        input ? ,
                        input ? ,
                        input ? ,
                        output calc-rec) no-error.
      if error-status :error then
        undo calc-sub, return error.
      calc-rec = recid (buf-price-list).
    end.
    for each  buf-price-list where
              buf-price-list.doc-num    = buf-price-doc.doc-num and
              buf-price-list.main-price = no and
              buf-price-list.artic      = buf-goods.artic and
              buf-price-list.prod-type  = buf-goods.prod-type and
              buf-price-list.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code    = buf-price-list.b-code and
              buf-bar-code.unit-cli <> buf-goods.unit-base
        on error undo calc-sub, return error:
      run calc-pr-alt (input buf-price-doc.doc-num,
                      input buf-bar-code.b-code,
                      input round-method,
                      input round-base) no-error.
      if error-status :error then
        undo calc-sub, return error.
    end.
  end.
  else do:
    run calc-base-upd (input buf-bar-code.b-code,
                      input buf-price-doc.doc-num,
                      input round-method,
                      input round-base) no-error.
    if error-status :error then
      undo calc-sub, return error.
  end.
end.
END PROCEDURE.
procedure ver-pr-nogds :
define input  parameter p-gds-code      as integer   no-undo .
define input  parameter p-par-pr-nogds  as character no-undo .
define output parameter p-not           as logical   no-undo .
define output parameter p-str           as character no-undo .
define buffer buf_goods for ub.goods  .
define variable nn as integer   no-undo .
define variable ii as integer   no-undo .
define variable v-namegrp as character no-undo .
  do
  on error undo, return error return-value
  :
  if p-par-pr-nogds = "1" then do:
     assign
      p-not = true
      p-str = ""
     .
     return .
  end.
  assign
    p-not = false
    p-str = ""
  .
  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .
  nn = num-entries(par-pr-nogds-long,chr(4)) .
  repeat ii = 1 to nn:
     v-namegrp = entry(ii , par-pr-nogds-long , chr(4) ) no-error .
     if buf_goods.grp-name  begins v-namegrp  then do:
        assign
          p-not = true
          p-str = substitute ( "Товар &1 &2 &3  может быть включен в ДНЦ из-за исключения запрета по группе : &4"  , buf_goods.artic, buf_goods.gds-name , buf_goods.grp-name , v-namegrp )
        .
        leave .
     end.
  end.
  end.
end procedure.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE calc-pr-list :
define input  parameter bc          like ub.price-list.b-code   no-undo .
define input  parameter d-num       like ub.price-doc.doc-num   no-undo .
define input  parameter calc-method             as character    no-undo .
define input  parameter increase-pc             as decimal      no-undo .
define input  parameter round-method            as character    no-undo .
define input  parameter round-base              as decimal      no-undo .
define input  parameter p-doc-price-rubl        as decimal      no-undo .
define input  parameter p-doc-price-base        as decimal      no-undo .
define input  parameter p-doc-price-rubl-novat  as decimal      no-undo .
define input  parameter p-doc-price-base-novat  as decimal      no-undo .
define output parameter calc-rec                as recid        no-undo .
define buffer buf-price-list for ub.price-list.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer buf-gds-prt    for ub.gds-prt.
define buffer buf-gds-grp    for ub.gds-grp.
define buffer buf_contract   for ub.contract .
define buffer buf_contract-specif for ub.contract-specif .
define variable cur-pr like ub.price-list.price-sale no-undo .
define variable cur-rt like ub.price-list.road-tax   no-undo .
define variable cur-ex like ub.price-list.excise     no-undo .
define variable cur-dn like ub.price-list.doc-num    no-undo .
define variable loc-ret        as logical            no-undo .
define variable old-price-sale as decimal            no-undo .
define variable v-bonus        as decimal            no-undo .
assign
  loc-ret = true
.
calc-pr:
do on error undo calc-pr, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find  buf-price-list where
        buf-price-list.doc-num    = d-num and
        buf-price-list.b-code     = bc and
        buf-price-list.price-type = "".
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  g#log = yes.
  define variable loc-increase-pc      like  ub.goods.increase-pc no-undo .
  define variable loc-grp-increase-pc  like  ub.goods.increase-pc no-undo .
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-increase-pc in g#library
  (input  buf-goods.gds-code
  ,input  buf-price-list.obj-type
  ,input  buf-price-list.obj-code
  ,output  loc-increase-pc
  ) no-error .
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка метода поиска наценки товара на объекте" skip
     error-status :get-message(1) .
  end.
define variable p-prc-min        as decimal   no-undo .
define variable p-prc-max        as decimal   no-undo .
define variable p-round-method   as character no-undo .
define variable p-base           as decimal   no-undo .
define variable p-value-margin   as integer   no-undo .
define variable p-type-margin    as logical   no-undo .
define variable p-value-increase as integer   no-undo .
define variable p-type-increase  as logical   no-undo .
define variable p-value-rmethod  as integer   no-undo .
define variable p-type-rmethod   as logical   no-undo .
run gds-attr-margin-value
(
  input   buf-goods.gds-code ,
  input   buf-price-list.obj-type  ,
  input   buf-price-list.obj-code  ,
  output  p-prc-min  ,
  output  p-prc-max  ,
  output  loc-grp-increase-pc,
  output  p-round-method   ,
  output  p-base           ,
  output  p-value-margin    ,
  output  p-type-margin     ,
  output  p-value-increase    ,
  output  p-type-increase   ,
  output  p-value-rmethod    ,
  output  p-type-rmethod
  ) no-error .
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка процедуры поиска наценки по группе товара на объекте" skip
     error-status :get-message(1) skip
     return-value .
  end.
  define variable g-g as logical no-undo .
  g-g = false .
  case calc-method:
    when 'Товар':U then do:
      case buf-goods.calc-method:
        when 'Группа':U then do:
          find buf-gds-grp no-lock where
              buf-gds-grp.node-code = buf-goods.grp-code.
          case buf-gds-grp.calc-method:
   when 'Накл-безНДС':U  then do:
      if ub.trn-doc.doc-type = 'при':U and
         ( ub.trn-doc.ext-doc-type = 'ie':U  ) then do:
              run str/gdsnovat.p ('Накл-безНДС':U,
                      buf-price-list.obj-type,
                      buf-price-list.obj-code,
                      buf-price-doc.host-code,
                      buf-price-list.artic,
                      buf-price-list.prod-type,
                      buf-price-list.prod-code,
                      loc-grp-increase-pc,
                      doc-code,
                      input p-doc-price-rubl-novat   ,
                      input p-doc-price-base-novat   ,
                      output cost-base   ,
                      output cost-rubl   ,
                      output v-price-base  ,
                      output v-price-rubl  ,
                      output cur-rt-base ,
                      output cur-rt-rubl )
                      .
                      if available ub.doc-line then do:
                          assign
                            cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                            buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                            buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                            buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                            buf-price-list.road-tax    = cur-rt
                            tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                          .
                      end.
                      else do:
                          assign
                            cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                            buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                            buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then p-doc-price-rubl-novat else p-doc-price-base-novat
                            buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                            buf-price-list.road-tax    = cur-rt
                            tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                          .
                      end.
                End.
      else do:
          run str/gdsnovat.p ('Накл-безНДС':U + "Other":U ,
              buf-price-list.obj-type,
              buf-price-list.obj-code,
              buf-price-doc.host-code,
              buf-price-list.artic,
              buf-price-list.prod-type,
              buf-price-list.prod-code,
              loc-grp-increase-pc,
              doc-code,
              input p-doc-price-rubl-novat   ,
              input p-doc-price-base-novat   ,
              output cost-base   ,
              output cost-rubl   ,
              output v-price-base  ,
              output v-price-rubl  ,
              output cur-rt-base ,
              output cur-rt-rubl ).
              if available ub.doc-line then do:
                  assign
                    cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                    buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                    buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                    buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                    buf-price-list.road-tax    = cur-rt
                    tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                  .
              end.
              else do:
                  assign
                    cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl             else cur-rt-base
                    buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                    buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then p-doc-price-rubl-novat else p-doc-price-base-novat
                    buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl           else v-price-base
                    buf-price-list.road-tax    = cur-rt
                    tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl            else v-price-base
                  .
              end.
          End.
    end.
    when 'НсП':U then do:
      run str/gdsnovat.p ( 'НсП':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          loc-grp-increase-pc,
          "",
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'НсП':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учет-безНДС':U then do:
      run str/gdsnovat.p ('Учет-безНДС':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          loc-grp-increase-pc,
          doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'Учет-безНДС':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учет+накл':U then do:
      run str/gdsnovat.p
         (input 'Учет+накл':U,
          input buf-price-list.obj-type,
          input buf-price-list.obj-code,
          input buf-price-doc.host-code,
          input buf-price-list.artic,
          input buf-price-list.prod-type,
          input buf-price-list.prod-code,
          input loc-grp-increase-pc,
          input doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'Учет+накл':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Уч+накл-НДС':U then do:
      run str/gdsnovat.p ('Уч+накл-НДС':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          loc-grp-increase-pc,
          doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl )
          .
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method =  'Уч+накл-НДС':U  + " " + doc-code
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учетная':U then do:
      run trg/gdsavrg.p ('Учетная':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
        assign
          buf-price-list.calc-method =  'Учетная':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
          tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
          buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
    end.
    when 'Учет-объект':U then do:
      run trg/gdsavrg.p ('Учет-объект':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      assign
        buf-price-list.calc-method = 'Учет-объект':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
        .
    end.
    when 'Учет-резерв':U then do:
      run trg/gdsavrg.p
        ('Учет-резерв':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          output cost-base,
          output cost-rubl,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
      assign
        buf-price-list.calc-method = 'Учет-резерв':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
        .
    end.
    when 'Приходная':U then do:
      run trg/gdsavrg.p ('Приходная':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      if
        ( var-pr-r-b = "rubl" and
         (
         cost-rubl = 0
      or cost-rubl = ? ))
      or
        ( var-pr-r-b = "base" and
         (
         cost-base = 0
      or cost-base = ? ))
      then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет от последней приходной цены невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      end.
      else do:
        assign
        buf-price-list.calc-method = 'Приходная':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
      end.
    end.
    when 'Прих-объект':U then do:
      run trg/gdsavrg.p ('Прих-объект':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      if
        ( var-pr-r-b = "rubl" and
         (
         cost-rubl = 0
      or cost-rubl = ? ))
      or
        ( var-pr-r-b = "base" and
         (
         cost-base = 0
      or cost-base = ? ))   then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет от последней приходной цены невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Прих-объект':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
          tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-grp-increase-pc / 100) else  cost-base * (1 + loc-grp-increase-pc / 100)
          buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
      end.
    end.
    when 'Производит':U then do:
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  buf-price-list.b-code
 , input  buf-price-list.obj-type
 , input  buf-price-list.obj-code
 , output tt-price-prodwihvat
 , output cost-rubl
 , output tt-prod-vat
 , output v-str
 , output v-str
        )  .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#1" update g#log .
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Производит':U
          buf-price-list.price-calc  =  cost-rubl
          buf-price-list.price-sale  =  cost-rubl * (1 + loc-grp-increase-pc / 100)
          tt-price-sale   =  cost-rubl * (1 + loc-grp-increase-pc / 100)
          buf-price-list.road-tax    = 0
          .
      end.
    end.
    when 'ПорогПр-НДС':U then do:
          run calc-price-levelprod (
            input 2            ,
            input var-pr-r-b   ,
            input buf-price-list.b-code     ,
            input buf-price-list.obj-type ,
            input buf-price-list.obj-code ,
            output cost-rubl ,
            output v-str
          ) .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          buf-price-list.price-calc = cost-rubl .
          buf-price-list.calc-method = 'ПорогПр-НДС':U + chr(4) + v-str.
          buf-price-list.road-tax    = 0 .
          buf-price-list.price-sale  =  cost-rubl * (1 + buf-price-list.vat-pc / 100) .
          tt-price-sale   =  cost-rubl * (1 + buf-price-list.vat-pc / 100) .
      end.
    end.
    when 'ПорогПр+НДС':U then do:
          run calc-price-levelprod (
            input 1            ,
            input var-pr-r-b   ,
            input buf-price-list.b-code     ,
            input buf-price-list.obj-type ,
            input buf-price-list.obj-code ,
            output cost-rubl,
            output v-str
          ) .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          buf-price-list.price-calc = cost-rubl .
          buf-price-list.calc-method = 'ПорогПр+НДС':U + chr(4) + v-str.
          buf-price-list.road-tax    = 0 .
          buf-price-list.price-sale  =  cost-rubl  .
          tt-price-sale   =  cost-rubl  .
      end.
    end.
    when 'Произв-НДС':U then do:
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  buf-price-list.b-code
 , input  buf-price-list.obj-type
 , input  buf-price-list.obj-code
 , output cost-rubl
 , output tt-price-prodwihvat
 , output tt-prod-vat
 , output v-str
 , output v-str
        )  .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#1" update g#log .
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Произв-НДС':U
          buf-price-list.price-calc  = cost-rubl
          buf-price-list.price-sale  =  cost-rubl * (1 + loc-grp-increase-pc / 100)
                                       * (1 + buf-price-list.vat-pc / 100 )
          tt-price-sale   =  cost-rubl * (1 + loc-grp-increase-pc / 100)
                                       * (1 + buf-price-list.vat-pc / 100 )
          buf-price-list.road-tax    = 0
          .
      end.
    end.
    when 'Новая':U then
      if buf-price-list.price-sale = ? then
        message "Неизвестна новая цена для товара :"
                buf-price-list.artic buf-goods.gds-name
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      else
        assign
          buf-price-list.calc-method = 'Новая':U
          buf-price-list.price-calc = buf-price-list.price-sale
          buf-price-list.price-sale = buf-price-list.price-sale * (1 + loc-grp-increase-pc / 100)
          tt-price-sale = buf-price-list.price-sale * (1 + loc-grp-increase-pc / 100)
          .
    when 'Накладная':U then do:
        run str/pr-wbil.p
        ( input ""              ,
          input 'Накладная':U   ,
          input recid(ub.trn-doc)     ,
          input recid(ub.doc-line)    ,
          input recid( ub.gds-dtl)     ,
          input doc-code           ,
          input buf-goods.gds-name       ,
          input buf-goods.gds-code       ,
          input buf-price-list.artic          ,
          input buf-price-list.prod-type      ,
          input buf-price-list.prod-code      ,
          input buf-bar-code.node-code      ,
          input loc-grp-increase-pc                ,
          input p-doc-price-rubl   ,
          input p-doc-price-base   ,
          output v-price-base      ,
          output v-price-rubl
          ) no-error  .
      if not error-status :error then do:
          assign
            buf-price-list.calc-method = 'Накладная':U + " " + doc-code
            buf-price-list.price-calc  = v-price-base
            buf-price-list.price-sale  = v-price-rubl
            tt-price-sale   = v-price-rubl
        .
      end.
      else do:
         message
           vss-workfile vss-revision vss-description skip
           error-status :get-message(1) skip
           return-value skip
           "444"
           view-as alert-box error
         .
      end.
    end.
    when 'НсП+накл':U then do:
        run str/pr-wbil.p
        ( input ""                ,
          input 'НсП+накл':U ,
          input recid(ub.trn-doc)       ,
          input recid(ub.doc-line)    ,
          input recid( ub.gds-dtl)     ,
          input doc-code             ,
          input buf-goods.gds-name         ,
          input buf-goods.gds-code         ,
          input buf-price-list.artic            ,
          input buf-price-list.prod-type        ,
          input buf-price-list.prod-code        ,
          input buf-bar-code.node-code        ,
          input 0                    ,
          input p-doc-price-rubl     ,
          input p-doc-price-base     ,
          output v-price-base        ,
          output v-price-rubl
          ) no-error  .
      if not error-status :error then
          assign
            buf-price-list.calc-method = 'НсП+накл':U + " " + doc-code
            buf-price-list.price-calc  = v-price-base
            buf-price-list.price-sale  = v-price-rubl
            tt-price-sale   = v-price-rubl
        .
    end.
    when 'Отсутствует':U then do:
      if buf-price-list.price-sale = ? then do:
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf-price-list.obj-type
  ,input  buf-price-list.obj-code
  ,input  buf-price-list.b-code
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  )  .
        if cur-pr <> ? then
          assign
            buf-price-list.calc-method = 'Отсутствует':U
            buf-price-list.price-calc  = cur-pr
            buf-price-list.price-sale  = cur-pr
            tt-price-sale   = cur-pr
            buf-price-list.road-tax    = cur-rt
            buf-price-list.excise      = cur-ex
            .
      end.
      line-rec = recid (buf-price-list).
    end.
    when 'Не-считать':U then do:
      if buf-price-list.price-sale = ? then do:
        assign
          buf-price-list.calc-method = 'Не-считать':U
          buf-price-list.price-calc = ?
          .
      end.
      line-rec = recid (buf-price-list).
    end.
    when 'Спецификация':U then do:
      if available ub.trn-doc
      then do:
        if ub.trn-doc.contract-code <> 0 then do:
          find first buf_contract no-lock
          where buf_contract.host-code     = buf-price-doc.host-code
            and buf_contract.contract-code = ub.trn-doc.contract-code
          no-error.
          if available buf_contract then do:
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
FOR EACH
    buf_contract-specif
     NO-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
            :
              if buf_contract-specif.gds-code     = buf-goods.gds-code then do:
                run read-bonus (
                    input  buf_contract-specif.contract-num  ,
                    input  buf_contract-specif.host-code     ,
                    input  buf_contract-specif.gds-code      ,
                    output v-bonus  ) .
                if v-bonus <> ? and v-bonus <> 0 then do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )
                    buf-price-list.price-sale = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + loc-grp-increase-pc / 100)
                    tt-price-sale  = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + loc-grp-increase-pc / 100)
                  .
                end.
                else do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli
                    buf-price-list.price-sale  = buf_contract-specif.price-cli * (1 + loc-grp-increase-pc / 100)
                    tt-price-sale   = buf_contract-specif.price-cli * (1 + loc-grp-increase-pc / 100)
                  .
                end.
              end.
            end.
          end.
          else do:
            message "Не найден договор с кодом :"
                    ub.trn-doc.contract-code
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
          end.
        end.
        else do:
          find first buf_contract no-lock
          where buf_contract.host-code     = buf-price-doc.host-code
            and buf_contract.cli-type      = ub.trn-doc.cli-type
            and buf_contract.cli-code      = ub.trn-doc.cli-code
            and buf_contract.status_       = 'тек':U
            and buf_contract.contract-date-beg   <= ub.trn-doc.doc-date
            and ( buf_contract.contract-date-end >= ub.trn-doc.doc-date
              or buf_contract.contract-date-end   = date('') )
          no-error.
          if available buf_contract then do:
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
FOR EACH
    buf_contract-specif
     NO-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
            :
              if buf_contract-specif.gds-code     = buf-goods.gds-code then do:
                run read-bonus (
                    input  buf_contract-specif.contract-num  ,
                    input  buf_contract-specif.host-code     ,
                    input  buf_contract-specif.gds-code      ,
                    output v-bonus  ) .
                if v-bonus <> ? and v-bonus <> 0 then do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )
                    buf-price-list.price-sale = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + loc-grp-increase-pc / 100)
                    tt-price-sale  = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + loc-grp-increase-pc / 100)
                  .
                end.
                else do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli
                    buf-price-list.price-sale  = buf_contract-specif.price-cli * (1 + loc-grp-increase-pc / 100)
                    tt-price-sale   = buf_contract-specif.price-cli * (1 + loc-grp-increase-pc / 100)
                  .
                end.
              end.
            end.
          end.
          else do:
            message "Не найден ни один текущий договор для поставщика:"
                    ub.trn-doc.cli-type ub.trn-doc.cli-code
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
          end.
        end.
      end.
    end.
    otherwise do:
      message "Не задан способ вычисления цены : " skip
              "Артикул:" buf-price-list.artic buf-goods.gds-name skip
              ""
              view-as alert-box error.
      g#log = no.
      return error .
    end.
          end case.
           assign
            round-method = p-round-method
            round-base   = p-base
            g-g = true
           .
        end.
   when 'Накл-безНДС':U  then do:
      if ub.trn-doc.doc-type = 'при':U and
         ( ub.trn-doc.ext-doc-type = 'ie':U  ) then do:
              run str/gdsnovat.p ('Накл-безНДС':U,
                      buf-price-list.obj-type,
                      buf-price-list.obj-code,
                      buf-price-doc.host-code,
                      buf-price-list.artic,
                      buf-price-list.prod-type,
                      buf-price-list.prod-code,
                      loc-increase-pc,
                      doc-code,
                      input p-doc-price-rubl-novat   ,
                      input p-doc-price-base-novat   ,
                      output cost-base   ,
                      output cost-rubl   ,
                      output v-price-base  ,
                      output v-price-rubl  ,
                      output cur-rt-base ,
                      output cur-rt-rubl )
                      .
                      if available ub.doc-line then do:
                          assign
                            cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                            buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                            buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                            buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                            buf-price-list.road-tax    = cur-rt
                            tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                          .
                      end.
                      else do:
                          assign
                            cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                            buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                            buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then p-doc-price-rubl-novat else p-doc-price-base-novat
                            buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                            buf-price-list.road-tax    = cur-rt
                            tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                          .
                      end.
                End.
      else do:
          run str/gdsnovat.p ('Накл-безНДС':U + "Other":U ,
              buf-price-list.obj-type,
              buf-price-list.obj-code,
              buf-price-doc.host-code,
              buf-price-list.artic,
              buf-price-list.prod-type,
              buf-price-list.prod-code,
              loc-increase-pc,
              doc-code,
              input p-doc-price-rubl-novat   ,
              input p-doc-price-base-novat   ,
              output cost-base   ,
              output cost-rubl   ,
              output v-price-base  ,
              output v-price-rubl  ,
              output cur-rt-base ,
              output cur-rt-rubl ).
              if available ub.doc-line then do:
                  assign
                    cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                    buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                    buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                    buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                    buf-price-list.road-tax    = cur-rt
                    tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                  .
              end.
              else do:
                  assign
                    cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl             else cur-rt-base
                    buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                    buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then p-doc-price-rubl-novat else p-doc-price-base-novat
                    buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl           else v-price-base
                    buf-price-list.road-tax    = cur-rt
                    tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl            else v-price-base
                  .
              end.
          End.
    end.
    when 'НсП':U then do:
      run str/gdsnovat.p ( 'НсП':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          loc-increase-pc,
          "",
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'НсП':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учет-безНДС':U then do:
      run str/gdsnovat.p ('Учет-безНДС':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          loc-increase-pc,
          doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'Учет-безНДС':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учет+накл':U then do:
      run str/gdsnovat.p
         (input 'Учет+накл':U,
          input buf-price-list.obj-type,
          input buf-price-list.obj-code,
          input buf-price-doc.host-code,
          input buf-price-list.artic,
          input buf-price-list.prod-type,
          input buf-price-list.prod-code,
          input loc-increase-pc,
          input doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'Учет+накл':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Уч+накл-НДС':U then do:
      run str/gdsnovat.p ('Уч+накл-НДС':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          loc-increase-pc,
          doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl )
          .
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method =  'Уч+накл-НДС':U  + " " + doc-code
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учетная':U then do:
      run trg/gdsavrg.p ('Учетная':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
        assign
          buf-price-list.calc-method =  'Учетная':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
          tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
          buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
    end.
    when 'Учет-объект':U then do:
      run trg/gdsavrg.p ('Учет-объект':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      assign
        buf-price-list.calc-method = 'Учет-объект':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
        .
    end.
    when 'Учет-резерв':U then do:
      run trg/gdsavrg.p
        ('Учет-резерв':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          output cost-base,
          output cost-rubl,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
      assign
        buf-price-list.calc-method = 'Учет-резерв':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
        .
    end.
    when 'Приходная':U then do:
      run trg/gdsavrg.p ('Приходная':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      if
        ( var-pr-r-b = "rubl" and
         (
         cost-rubl = 0
      or cost-rubl = ? ))
      or
        ( var-pr-r-b = "base" and
         (
         cost-base = 0
      or cost-base = ? ))
      then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет от последней приходной цены невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      end.
      else do:
        assign
        buf-price-list.calc-method = 'Приходная':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
      end.
    end.
    when 'Прих-объект':U then do:
      run trg/gdsavrg.p ('Прих-объект':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      if
        ( var-pr-r-b = "rubl" and
         (
         cost-rubl = 0
      or cost-rubl = ? ))
      or
        ( var-pr-r-b = "base" and
         (
         cost-base = 0
      or cost-base = ? ))   then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет от последней приходной цены невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Прих-объект':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
          tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + loc-increase-pc / 100) else  cost-base * (1 + loc-increase-pc / 100)
          buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
      end.
    end.
    when 'Производит':U then do:
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  buf-price-list.b-code
 , input  buf-price-list.obj-type
 , input  buf-price-list.obj-code
 , output tt-price-prodwihvat
 , output cost-rubl
 , output tt-prod-vat
 , output v-str
 , output v-str
        )  .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#1" update g#log .
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Производит':U
          buf-price-list.price-calc  =  cost-rubl
          buf-price-list.price-sale  =  cost-rubl * (1 + loc-increase-pc / 100)
          tt-price-sale   =  cost-rubl * (1 + loc-increase-pc / 100)
          buf-price-list.road-tax    = 0
          .
      end.
    end.
    when 'ПорогПр-НДС':U then do:
          run calc-price-levelprod (
            input 2            ,
            input var-pr-r-b   ,
            input buf-price-list.b-code     ,
            input buf-price-list.obj-type ,
            input buf-price-list.obj-code ,
            output cost-rubl ,
            output v-str
          ) .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          buf-price-list.price-calc = cost-rubl .
          buf-price-list.calc-method = 'ПорогПр-НДС':U + chr(4) + v-str.
          buf-price-list.road-tax    = 0 .
          buf-price-list.price-sale  =  cost-rubl * (1 + buf-price-list.vat-pc / 100) .
          tt-price-sale   =  cost-rubl * (1 + buf-price-list.vat-pc / 100) .
      end.
    end.
    when 'ПорогПр+НДС':U then do:
          run calc-price-levelprod (
            input 1            ,
            input var-pr-r-b   ,
            input buf-price-list.b-code     ,
            input buf-price-list.obj-type ,
            input buf-price-list.obj-code ,
            output cost-rubl,
            output v-str
          ) .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          buf-price-list.price-calc = cost-rubl .
          buf-price-list.calc-method = 'ПорогПр+НДС':U + chr(4) + v-str.
          buf-price-list.road-tax    = 0 .
          buf-price-list.price-sale  =  cost-rubl  .
          tt-price-sale   =  cost-rubl  .
      end.
    end.
    when 'Произв-НДС':U then do:
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  buf-price-list.b-code
 , input  buf-price-list.obj-type
 , input  buf-price-list.obj-code
 , output cost-rubl
 , output tt-price-prodwihvat
 , output tt-prod-vat
 , output v-str
 , output v-str
        )  .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#1" update g#log .
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Произв-НДС':U
          buf-price-list.price-calc  = cost-rubl
          buf-price-list.price-sale  =  cost-rubl * (1 + loc-increase-pc / 100)
                                       * (1 + buf-price-list.vat-pc / 100 )
          tt-price-sale   =  cost-rubl * (1 + loc-increase-pc / 100)
                                       * (1 + buf-price-list.vat-pc / 100 )
          buf-price-list.road-tax    = 0
          .
      end.
    end.
    when 'Новая':U then
      if buf-price-list.price-sale = ? then
        message "Неизвестна новая цена для товара :"
                buf-price-list.artic buf-goods.gds-name
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      else
        assign
          buf-price-list.calc-method = 'Новая':U
          buf-price-list.price-calc = buf-price-list.price-sale
          buf-price-list.price-sale = buf-price-list.price-sale * (1 + loc-increase-pc / 100)
          tt-price-sale = buf-price-list.price-sale * (1 + loc-increase-pc / 100)
          .
    when 'Накладная':U then do:
        run str/pr-wbil.p
        ( input ""              ,
          input 'Накладная':U   ,
          input recid(ub.trn-doc)     ,
          input recid(ub.doc-line)    ,
          input recid( ub.gds-dtl)     ,
          input doc-code           ,
          input buf-goods.gds-name       ,
          input buf-goods.gds-code       ,
          input buf-price-list.artic          ,
          input buf-price-list.prod-type      ,
          input buf-price-list.prod-code      ,
          input buf-bar-code.node-code      ,
          input loc-increase-pc                ,
          input p-doc-price-rubl   ,
          input p-doc-price-base   ,
          output v-price-base      ,
          output v-price-rubl
          ) no-error  .
      if not error-status :error then do:
          assign
            buf-price-list.calc-method = 'Накладная':U + " " + doc-code
            buf-price-list.price-calc  = v-price-base
            buf-price-list.price-sale  = v-price-rubl
            tt-price-sale   = v-price-rubl
        .
      end.
      else do:
         message
           vss-workfile vss-revision vss-description skip
           error-status :get-message(1) skip
           return-value skip
           "444"
           view-as alert-box error
         .
      end.
    end.
    when 'НсП+накл':U then do:
        run str/pr-wbil.p
        ( input ""                ,
          input 'НсП+накл':U ,
          input recid(ub.trn-doc)       ,
          input recid(ub.doc-line)    ,
          input recid( ub.gds-dtl)     ,
          input doc-code             ,
          input buf-goods.gds-name         ,
          input buf-goods.gds-code         ,
          input buf-price-list.artic            ,
          input buf-price-list.prod-type        ,
          input buf-price-list.prod-code        ,
          input buf-bar-code.node-code        ,
          input 0                    ,
          input p-doc-price-rubl     ,
          input p-doc-price-base     ,
          output v-price-base        ,
          output v-price-rubl
          ) no-error  .
      if not error-status :error then
          assign
            buf-price-list.calc-method = 'НсП+накл':U + " " + doc-code
            buf-price-list.price-calc  = v-price-base
            buf-price-list.price-sale  = v-price-rubl
            tt-price-sale   = v-price-rubl
        .
    end.
    when 'Отсутствует':U then do:
      if buf-price-list.price-sale = ? then do:
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf-price-list.obj-type
  ,input  buf-price-list.obj-code
  ,input  buf-price-list.b-code
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  )  .
        if cur-pr <> ? then
          assign
            buf-price-list.calc-method = 'Отсутствует':U
            buf-price-list.price-calc  = cur-pr
            buf-price-list.price-sale  = cur-pr
            tt-price-sale   = cur-pr
            buf-price-list.road-tax    = cur-rt
            buf-price-list.excise      = cur-ex
            .
      end.
      line-rec = recid (buf-price-list).
    end.
    when 'Не-считать':U then do:
      if buf-price-list.price-sale = ? then do:
        assign
          buf-price-list.calc-method = 'Не-считать':U
          buf-price-list.price-calc = ?
          .
      end.
      line-rec = recid (buf-price-list).
    end.
    when 'Спецификация':U then do:
      if available ub.trn-doc
      then do:
        if ub.trn-doc.contract-code <> 0 then do:
          find first buf_contract no-lock
          where buf_contract.host-code     = buf-price-doc.host-code
            and buf_contract.contract-code = ub.trn-doc.contract-code
          no-error.
          if available buf_contract then do:
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
FOR EACH
    buf_contract-specif
     NO-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
            :
              if buf_contract-specif.gds-code     = buf-goods.gds-code then do:
                run read-bonus (
                    input  buf_contract-specif.contract-num  ,
                    input  buf_contract-specif.host-code     ,
                    input  buf_contract-specif.gds-code      ,
                    output v-bonus  ) .
                if v-bonus <> ? and v-bonus <> 0 then do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )
                    buf-price-list.price-sale = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + loc-increase-pc / 100)
                    tt-price-sale  = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + loc-increase-pc / 100)
                  .
                end.
                else do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli
                    buf-price-list.price-sale  = buf_contract-specif.price-cli * (1 + loc-increase-pc / 100)
                    tt-price-sale   = buf_contract-specif.price-cli * (1 + loc-increase-pc / 100)
                  .
                end.
              end.
            end.
          end.
          else do:
            message "Не найден договор с кодом :"
                    ub.trn-doc.contract-code
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
          end.
        end.
        else do:
          find first buf_contract no-lock
          where buf_contract.host-code     = buf-price-doc.host-code
            and buf_contract.cli-type      = ub.trn-doc.cli-type
            and buf_contract.cli-code      = ub.trn-doc.cli-code
            and buf_contract.status_       = 'тек':U
            and buf_contract.contract-date-beg   <= ub.trn-doc.doc-date
            and ( buf_contract.contract-date-end >= ub.trn-doc.doc-date
              or buf_contract.contract-date-end   = date('') )
          no-error.
          if available buf_contract then do:
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
FOR EACH
    buf_contract-specif
     NO-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
            :
              if buf_contract-specif.gds-code     = buf-goods.gds-code then do:
                run read-bonus (
                    input  buf_contract-specif.contract-num  ,
                    input  buf_contract-specif.host-code     ,
                    input  buf_contract-specif.gds-code      ,
                    output v-bonus  ) .
                if v-bonus <> ? and v-bonus <> 0 then do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )
                    buf-price-list.price-sale = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + loc-increase-pc / 100)
                    tt-price-sale  = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + loc-increase-pc / 100)
                  .
                end.
                else do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli
                    buf-price-list.price-sale  = buf_contract-specif.price-cli * (1 + loc-increase-pc / 100)
                    tt-price-sale   = buf_contract-specif.price-cli * (1 + loc-increase-pc / 100)
                  .
                end.
              end.
            end.
          end.
          else do:
            message "Не найден ни один текущий договор для поставщика:"
                    ub.trn-doc.cli-type ub.trn-doc.cli-code
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
          end.
        end.
      end.
    end.
    otherwise do:
      message "Не задан способ вычисления цены : " skip
              "Артикул:" buf-price-list.artic buf-goods.gds-name skip
              ""
              view-as alert-box error.
      g#log = no.
      return error .
    end.
      end case.
         if g-g = false then do:
              define variable loc-rez as character no-undo .
              define variable t-type  as character no-undo .
              run gdsoattr-value (input 'round-method':U,
                                  input buf-goods.gds-code,
                                  input buf-price-list.obj-type,
                                  input buf-price-list.obj-code,
                                  output loc-rez ,
                                  output t-type)  no-error  .
              if error-status :error then message
                    vss-workfile vss-revision vss-description skip
                    error-status :get-message(1) skip
                    "gdsoattr-value"
                    view-as alert-box error .
              case NUM-ENTRIES (loc-rez," ") :
                  when 0 then do:
                  end.
                  when 1 then do:
                    round-method = loc-rez .
                    round-base   = 0 .
                  end.
                  when 2 then do:
                    round-method = entry(1 , loc-rez, " " ).
                    round-base   = decimal(entry(2 , loc-rez, " " )) .
                  end.
                  otherwise do:
                    round-method = entry(1 , loc-rez, " " ).
                    round-base   = decimal(entry(NUM-ENTRIES (loc-rez," ") , loc-rez, " " )) .
                  end.
              end case.
         end.
    end.
   when 'Накл-безНДС':U  then do:
      if ub.trn-doc.doc-type = 'при':U and
         ( ub.trn-doc.ext-doc-type = 'ie':U  ) then do:
              run str/gdsnovat.p ('Накл-безНДС':U,
                      buf-price-list.obj-type,
                      buf-price-list.obj-code,
                      buf-price-doc.host-code,
                      buf-price-list.artic,
                      buf-price-list.prod-type,
                      buf-price-list.prod-code,
                      increase-pc,
                      doc-code,
                      input p-doc-price-rubl-novat   ,
                      input p-doc-price-base-novat   ,
                      output cost-base   ,
                      output cost-rubl   ,
                      output v-price-base  ,
                      output v-price-rubl  ,
                      output cur-rt-base ,
                      output cur-rt-rubl )
                      .
                      if available ub.doc-line then do:
                          assign
                            cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                            buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                            buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                            buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                            buf-price-list.road-tax    = cur-rt
                            tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                          .
                      end.
                      else do:
                          assign
                            cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                            buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                            buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then p-doc-price-rubl-novat else p-doc-price-base-novat
                            buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                            buf-price-list.road-tax    = cur-rt
                            tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                          .
                      end.
                End.
      else do:
          run str/gdsnovat.p ('Накл-безНДС':U + "Other":U ,
              buf-price-list.obj-type,
              buf-price-list.obj-code,
              buf-price-doc.host-code,
              buf-price-list.artic,
              buf-price-list.prod-type,
              buf-price-list.prod-code,
              increase-pc,
              doc-code,
              input p-doc-price-rubl-novat   ,
              input p-doc-price-base-novat   ,
              output cost-base   ,
              output cost-rubl   ,
              output v-price-base  ,
              output v-price-rubl  ,
              output cur-rt-base ,
              output cur-rt-rubl ).
              if available ub.doc-line then do:
                  assign
                    cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                    buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                    buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                    buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                    buf-price-list.road-tax    = cur-rt
                    tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                  .
              end.
              else do:
                  assign
                    cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl             else cur-rt-base
                    buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                    buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then p-doc-price-rubl-novat else p-doc-price-base-novat
                    buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl           else v-price-base
                    buf-price-list.road-tax    = cur-rt
                    tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl            else v-price-base
                  .
              end.
          End.
    end.
    when 'НсП':U then do:
      run str/gdsnovat.p ( 'НсП':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          increase-pc,
          "",
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'НсП':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учет-безНДС':U then do:
      run str/gdsnovat.p ('Учет-безНДС':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          increase-pc,
          doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'Учет-безНДС':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учет+накл':U then do:
      run str/gdsnovat.p
         (input 'Учет+накл':U,
          input buf-price-list.obj-type,
          input buf-price-list.obj-code,
          input buf-price-doc.host-code,
          input buf-price-list.artic,
          input buf-price-list.prod-type,
          input buf-price-list.prod-code,
          input increase-pc,
          input doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl ).
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method = 'Учет+накл':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Уч+накл-НДС':U then do:
      run str/gdsnovat.p ('Уч+накл-НДС':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          increase-pc,
          doc-code,
          input p-doc-price-rubl-novat ,
          input p-doc-price-base-novat ,
          output cost-base   ,
          output cost-rubl   ,
          output v-price-base  ,
          output v-price-rubl  ,
          output cur-rt-base ,
          output cur-rt-rubl )
          .
        assign
          cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
          buf-price-list.calc-method =  'Уч+накл-НДС':U  + " " + doc-code
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
    end.
    when 'Учетная':U then do:
      run trg/gdsavrg.p ('Учетная':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
        assign
          buf-price-list.calc-method =  'Учетная':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
          tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
          buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
    end.
    when 'Учет-объект':U then do:
      run trg/gdsavrg.p ('Учет-объект':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      assign
        buf-price-list.calc-method = 'Учет-объект':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
        .
    end.
    when 'Учет-резерв':U then do:
      run trg/gdsavrg.p
        ('Учет-резерв':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          output cost-base,
          output cost-rubl,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
      assign
        buf-price-list.calc-method = 'Учет-резерв':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
        .
    end.
    when 'Приходная':U then do:
      run trg/gdsavrg.p ('Приходная':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      if
        ( var-pr-r-b = "rubl" and
         (
         cost-rubl = 0
      or cost-rubl = ? ))
      or
        ( var-pr-r-b = "base" and
         (
         cost-base = 0
      or cost-base = ? ))
      then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет от последней приходной цены невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      end.
      else do:
        assign
        buf-price-list.calc-method = 'Приходная':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
        tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
        buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
      end.
    end.
    when 'Прих-объект':U then do:
      run trg/gdsavrg.p ('Прих-объект':U,
                     buf-price-list.obj-type,
                     buf-price-list.obj-code,
                     buf-price-doc.host-code,
                     buf-price-list.artic,
                     buf-price-list.prod-type,
                     buf-price-list.prod-code,
                     output cost-base,
                     output cost-rubl,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
      if
        ( var-pr-r-b = "rubl" and
         (
         cost-rubl = 0
      or cost-rubl = ? ))
      or
        ( var-pr-r-b = "base" and
         (
         cost-base = 0
      or cost-base = ? ))   then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет от последней приходной цены невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Прих-объект':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then   cost-rubl                   else  cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
          tt-price-sale   =  if var-pr-r-b = "rubl" then   cost-rubl * (1 + increase-pc / 100) else  cost-base * (1 + increase-pc / 100)
          buf-price-list.road-tax    =  if var-pr-r-b = "rubl" then cur-rt-rubl                   else  cur-rt-base
          .
      end.
    end.
    when 'Производит':U then do:
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  buf-price-list.b-code
 , input  buf-price-list.obj-type
 , input  buf-price-list.obj-code
 , output tt-price-prodwihvat
 , output cost-rubl
 , output tt-prod-vat
 , output v-str
 , output v-str
        )  .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#1" update g#log .
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Производит':U
          buf-price-list.price-calc  =  cost-rubl
          buf-price-list.price-sale  =  cost-rubl * (1 + increase-pc / 100)
          tt-price-sale   =  cost-rubl * (1 + increase-pc / 100)
          buf-price-list.road-tax    = 0
          .
      end.
    end.
    when 'ПорогПр-НДС':U then do:
          run calc-price-levelprod (
            input 2            ,
            input var-pr-r-b   ,
            input buf-price-list.b-code     ,
            input buf-price-list.obj-type ,
            input buf-price-list.obj-code ,
            output cost-rubl ,
            output v-str
          ) .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          buf-price-list.price-calc = cost-rubl .
          buf-price-list.calc-method = 'ПорогПр-НДС':U + chr(4) + v-str.
          buf-price-list.road-tax    = 0 .
          buf-price-list.price-sale  =  cost-rubl * (1 + buf-price-list.vat-pc / 100) .
          tt-price-sale   =  cost-rubl * (1 + buf-price-list.vat-pc / 100) .
      end.
    end.
    when 'ПорогПр+НДС':U then do:
          run calc-price-levelprod (
            input 1            ,
            input var-pr-r-b   ,
            input buf-price-list.b-code     ,
            input buf-price-list.obj-type ,
            input buf-price-list.obj-code ,
            output cost-rubl,
            output v-str
          ) .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          buf-price-list.price-calc = cost-rubl .
          buf-price-list.calc-method = 'ПорогПр+НДС':U + chr(4) + v-str.
          buf-price-list.road-tax    = 0 .
          buf-price-list.price-sale  =  cost-rubl  .
          tt-price-sale   =  cost-rubl  .
      end.
    end.
    when 'Произв-НДС':U then do:
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  buf-price-list.b-code
 , input  buf-price-list.obj-type
 , input  buf-price-list.obj-code
 , output cost-rubl
 , output tt-price-prodwihvat
 , output tt-prod-vat
 , output v-str
 , output v-str
        )  .
      if cost-rubl = 0 or cost-rubl = ?  then do:
        message "Нет ПН для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#1" update g#log .
      end.
      else do:
        assign
          buf-price-list.calc-method = 'Произв-НДС':U
          buf-price-list.price-calc  = cost-rubl
          buf-price-list.price-sale  =  cost-rubl * (1 + increase-pc / 100)
                                       * (1 + buf-price-list.vat-pc / 100 )
          tt-price-sale   =  cost-rubl * (1 + increase-pc / 100)
                                       * (1 + buf-price-list.vat-pc / 100 )
          buf-price-list.road-tax    = 0
          .
      end.
    end.
    when 'Новая':U then
      if buf-price-list.price-sale = ? then
        message "Неизвестна новая цена для товара :"
                buf-price-list.artic buf-goods.gds-name
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      else
        assign
          buf-price-list.calc-method = 'Новая':U
          buf-price-list.price-calc = buf-price-list.price-sale
          buf-price-list.price-sale = buf-price-list.price-sale * (1 + increase-pc / 100)
          tt-price-sale = buf-price-list.price-sale * (1 + increase-pc / 100)
          .
    when 'Накладная':U then do:
        run str/pr-wbil.p
        ( input ""              ,
          input 'Накладная':U   ,
          input recid(ub.trn-doc)     ,
          input recid(ub.doc-line)    ,
          input recid( ub.gds-dtl)     ,
          input doc-code           ,
          input buf-goods.gds-name       ,
          input buf-goods.gds-code       ,
          input buf-price-list.artic          ,
          input buf-price-list.prod-type      ,
          input buf-price-list.prod-code      ,
          input buf-bar-code.node-code      ,
          input increase-pc                ,
          input p-doc-price-rubl   ,
          input p-doc-price-base   ,
          output v-price-base      ,
          output v-price-rubl
          ) no-error  .
      if not error-status :error then do:
          assign
            buf-price-list.calc-method = 'Накладная':U + " " + doc-code
            buf-price-list.price-calc  = v-price-base
            buf-price-list.price-sale  = v-price-rubl
            tt-price-sale   = v-price-rubl
        .
      end.
      else do:
         message
           vss-workfile vss-revision vss-description skip
           error-status :get-message(1) skip
           return-value skip
           "444"
           view-as alert-box error
         .
      end.
    end.
    when 'НсП+накл':U then do:
        run str/pr-wbil.p
        ( input ""                ,
          input 'НсП+накл':U ,
          input recid(ub.trn-doc)       ,
          input recid(ub.doc-line)    ,
          input recid( ub.gds-dtl)     ,
          input doc-code             ,
          input buf-goods.gds-name         ,
          input buf-goods.gds-code         ,
          input buf-price-list.artic            ,
          input buf-price-list.prod-type        ,
          input buf-price-list.prod-code        ,
          input buf-bar-code.node-code        ,
          input 0                    ,
          input p-doc-price-rubl     ,
          input p-doc-price-base     ,
          output v-price-base        ,
          output v-price-rubl
          ) no-error  .
      if not error-status :error then
          assign
            buf-price-list.calc-method = 'НсП+накл':U + " " + doc-code
            buf-price-list.price-calc  = v-price-base
            buf-price-list.price-sale  = v-price-rubl
            tt-price-sale   = v-price-rubl
        .
    end.
    when 'Отсутствует':U then do:
      if buf-price-list.price-sale = ? then do:
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf-price-list.obj-type
  ,input  buf-price-list.obj-code
  ,input  buf-price-list.b-code
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  )  .
        if cur-pr <> ? then
          assign
            buf-price-list.calc-method = 'Отсутствует':U
            buf-price-list.price-calc  = cur-pr
            buf-price-list.price-sale  = cur-pr
            tt-price-sale   = cur-pr
            buf-price-list.road-tax    = cur-rt
            buf-price-list.excise      = cur-ex
            .
      end.
      line-rec = recid (buf-price-list).
    end.
    when 'Не-считать':U then do:
      if buf-price-list.price-sale = ? then do:
        assign
          buf-price-list.calc-method = 'Не-считать':U
          buf-price-list.price-calc = ?
          .
      end.
      line-rec = recid (buf-price-list).
    end.
    when 'Спецификация':U then do:
      if available ub.trn-doc
      then do:
        if ub.trn-doc.contract-code <> 0 then do:
          find first buf_contract no-lock
          where buf_contract.host-code     = buf-price-doc.host-code
            and buf_contract.contract-code = ub.trn-doc.contract-code
          no-error.
          if available buf_contract then do:
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
FOR EACH
    buf_contract-specif
     NO-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
            :
              if buf_contract-specif.gds-code     = buf-goods.gds-code then do:
                run read-bonus (
                    input  buf_contract-specif.contract-num  ,
                    input  buf_contract-specif.host-code     ,
                    input  buf_contract-specif.gds-code      ,
                    output v-bonus  ) .
                if v-bonus <> ? and v-bonus <> 0 then do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )
                    buf-price-list.price-sale = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + increase-pc / 100)
                    tt-price-sale  = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + increase-pc / 100)
                  .
                end.
                else do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli
                    buf-price-list.price-sale  = buf_contract-specif.price-cli * (1 + increase-pc / 100)
                    tt-price-sale   = buf_contract-specif.price-cli * (1 + increase-pc / 100)
                  .
                end.
              end.
            end.
          end.
          else do:
            message "Не найден договор с кодом :"
                    ub.trn-doc.contract-code
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
          end.
        end.
        else do:
          find first buf_contract no-lock
          where buf_contract.host-code     = buf-price-doc.host-code
            and buf_contract.cli-type      = ub.trn-doc.cli-type
            and buf_contract.cli-code      = ub.trn-doc.cli-code
            and buf_contract.status_       = 'тек':U
            and buf_contract.contract-date-beg   <= ub.trn-doc.doc-date
            and ( buf_contract.contract-date-end >= ub.trn-doc.doc-date
              or buf_contract.contract-date-end   = date('') )
          no-error.
          if available buf_contract then do:
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
FOR EACH
    buf_contract-specif
     NO-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
            :
              if buf_contract-specif.gds-code     = buf-goods.gds-code then do:
                run read-bonus (
                    input  buf_contract-specif.contract-num  ,
                    input  buf_contract-specif.host-code     ,
                    input  buf_contract-specif.gds-code      ,
                    output v-bonus  ) .
                if v-bonus <> ? and v-bonus <> 0 then do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )
                    buf-price-list.price-sale = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + increase-pc / 100)
                    tt-price-sale  = (buf_contract-specif.price-cli + ( buf_contract-specif.price-cli * v-bonus / 100 )) * (1 + increase-pc / 100)
                  .
                end.
                else do:
                  assign
                    buf-price-list.calc-method = 'Спецификация':U
                    buf-price-list.price-calc  = buf_contract-specif.price-cli
                    buf-price-list.price-sale  = buf_contract-specif.price-cli * (1 + increase-pc / 100)
                    tt-price-sale   = buf_contract-specif.price-cli * (1 + increase-pc / 100)
                  .
                end.
              end.
            end.
          end.
          else do:
            message "Не найден ни один текущий договор для поставщика:"
                    ub.trn-doc.cli-type ub.trn-doc.cli-code
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
          end.
        end.
      end.
    end.
    otherwise do:
      message "Не задан способ вычисления цены : " skip
              "Артикул:" buf-price-list.artic buf-goods.gds-name skip
              ""
              view-as alert-box error.
      g#log = no.
      return error .
    end.
  end case.
run main-road-tax
  ( input buf-price-list.obj-type ,
    input buf-price-list.obj-code ,
    input buf-price-list.artic    ,
    input buf-price-list.prod-type,
    input buf-price-list.prod-code,
    input-output cur-rt-base,
    input-output cur-rt-rubl )
    .
    if var-pr-r-b = "rubl" then do:
        if ( cur-rt-rubl <> ? )   then
          assign
            buf-price-list.road-tax  = cur-rt-rubl
            .
            else
                assign
                  buf-price-list.road-tax  = 0
                  .
   end.
   else do:
        if ( cur-rt-base <> ? )   then
          assign
            buf-price-list.road-tax  = cur-rt-base
            .
            else
                assign
                  buf-price-list.road-tax  = 0
                  .
   end.
case round-method :
  when '9-окончание':U then do:
    if buf-price-list.price-sale < 29 then do:
      if (buf-price-list.price-sale - truncate (buf-price-list.price-sale, 0)) <> 0 then do:
        assign
          buf-price-list.price-sale = truncate (buf-price-list.price-sale, 0) + 1
        .
      end.
    end.
    else do:
      if (buf-price-list.price-sale modulo 10) < 3 then do:
        assign
          buf-price-list.price-sale = (buf-price-list.price-sale - (buf-price-list.price-sale modulo 100))
              + ( truncate (((buf-price-list.price-sale modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          buf-price-list.price-sale = (buf-price-list.price-sale - (buf-price-list.price-sale modulo 100))
              + ( truncate (((buf-price-list.price-sale modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        buf-price-list.price-sale = round (buf-price-list.price-sale, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if buf-price-list.price-sale < round-base then do:
      assign
        buf-price-list.price-sale = truncate (buf-price-list.price-sale, 0) + 0.99
      .
    end.
    else do:
      assign
        buf-price-list.price-sale = truncate (buf-price-list.price-sale / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      buf-price-list.price-sale = round (buf-price-list.price-sale, 0)
    .
  end.
  when 'Произвольно':U then do:
    if round-base <> 0 then do:
      assign
        buf-price-list.price-sale = round (buf-price-list.price-sale / round-base, 0) * round-base
      .
      if buf-price-list.price-sale = 0 then do:
        assign
          buf-price-list.price-sale = round-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if round-base <> 0 then do:
      if truncate ( buf-price-list.price-sale / round-base, 0 ) <> (buf-price-list.price-sale / round-base) then do:
        assign
          buf-price-list.price-sale = truncate (buf-price-list.price-sale / round-base, 0) * round-base + round-base
        .
      end.
    end.
    if buf-price-list.price-sale = 0 then do:
      assign
        buf-price-list.price-sale = round-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if round-base <> 0 then do:
      assign
        buf-price-list.price-sale = buf-price-list.price-sale * round-base
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
      "price"        buf-price-list.price-sale             skip
      view-as alert-box error .
  end.
end.
  calc-rec = recid (buf-price-list).
  run calc-pr-sub (input  buf-bar-code.b-code,
                   input  buf-price-list.doc-num,
                   input  calc-method,
                   input  increase-pc,
                   input  round-method,
                   input  round-base,
                   output calc-rec) no-error.
  if error-status :error then
    undo calc-pr, return error.
    old-price-sale = buf-price-list.price-sale .
   if line-mode = "calc":u then do:
        run calc-sigma (input buf-price-list.b-code,
                        input-output buf-price-list.price-sale,
                        input buf-price-doc.host-code,
                        input buf-price-doc.obj-code,
                        input buf-price-doc.obj-type,
                        output loc-ret).
        if loc-ret = false then
          message "Цена товара :" SKIP
          "артикул :" buf-price-list.artic buf-price-list.prod-type buf-price-list.prod-code skip
          "бар-код :" buf-price-list.b-code skip
            "не изменилась из-за заданного максимально допустимого отклонения! " skip
            " Рассчитанная цена "  old-price-sale skip
            " Действующая цена "   buf-price-list.price-sale
            view-as alert-box .
   end.
end.
END PROCEDURE.
procedure calc-sigma :
 do
 on error undo, return error return-value
 :
define input parameter l-bcode like ub.price-list.b-code no-undo .
define input-output parameter new-price as decimal no-undo .
define input parameter l-host as integer no-undo .
define input parameter l-code as integer no-undo .
define input parameter l-type as character no-undo .
define output parameter p-ret as logical no-undo .
define variable conf-par     as character no-undo.
define variable par-type     as character no-undo.
define variable i-sigma as decimal no-undo .
define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable old-price as decimal no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
p-ret = true  .
if par-pr-sigma <> ? and par-pr-sigma <> "" and par-pr-sigma <> "0" then do:
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  l-type
  ,input  l-code
  ,input  l-bcode
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  )  .
old-price = cur-pr .
if old-price =  new-price then do:
   p-ret = true .
   return.
end.
   i-sigma = decimal(par-pr-sigma) .
   if ( 100 * ABSOLUTE( old-price - new-price ) / old-price ) <= i-sigma then do:
       assign
         p-ret = false
         new-price = old-price
       .
       end.
   else p-ret = true .
  end.
 end.
end procedure.
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure main-road-tax :
define input parameter p-obj-type  like ub.gds-obj.obj-type  no-undo .
define input parameter p-obj-code  like ub.gds-obj.obj-code  no-undo .
define input parameter p-artic     like ub.gds-obj.artic     no-undo .
define input parameter p-prod-type like ub.gds-obj.prod-type no-undo .
define input parameter p-prod-code like ub.gds-obj.prod-code no-undo .
define input-output parameter p-road-tax-base as decimal no-undo .
define input-output parameter p-road-tax-rubl as decimal no-undo .
define variable v-doc-code as character no-undo .
define buffer     buff-goods    for ub.goods      .
define buffer     buf_gds-obj   for ub.gds-obj .
define buffer     buf_parts     for ub.parts   .
define buffer b-td_trn-doc for ub.trn-doc  .
define buffer b-dl_doc-line for ub.doc-line .
define variable is-petrolium              as logical no-undo .
define variable is-pieces                 as logical no-undo .
define variable is-hold-td                as logical no-undo .
define variable v-rec                     as recid   no-undo .
define variable t-ret                     as logical no-undo .
define variable v-total-avrg-base         as decimal no-undo .
define variable v-total-avrg-rubl         as decimal no-undo .
define variable v-total-avrg-qnty         as decimal no-undo .
define variable v-total-road-tax-base     as decimal no-undo .
define variable v-total-road-tax-rubl     as decimal no-undo .
define variable v-all-total-road-tax-base as decimal no-undo .
define variable v-all-total-road-tax-rubl as decimal no-undo .
assign
  p-road-tax-base = ?
  p-road-tax-rubl = ?
  .
  Find first buff-goods no-lock where
        buff-goods.artic     = p-artic and
        buff-goods.prod-type = p-prod-type and
        buff-goods.prod-code = p-prod-code
        no-error .
      If avail buff-goods Then DO:
           v-rec = recid (buff-goods).
           t-ret =  session:SET-WAIT-STATE("GENERAL") .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input p-artic
  ,  input p-prod-type
  ,  input p-prod-code
  , output is-petrolium
  , output is-pieces
  ) .
           t-ret =  session:set-wait-state("") .
           if not ( hvrdtax( v-rec ) = true and  is-petrolium = false  )   then  do:
                assign
                  p-road-tax-base = ?
                  p-road-tax-rubl = ?
                  .
                return.
           end.
      end.
      assign
          v-total-avrg-qnty = 0
          v-total-road-tax-base =  0
          v-total-road-tax-rubl =  0
          v-all-total-road-tax-base =  0
          v-all-total-road-tax-rubl =  0
          .
      for each buf_parts no-lock
        where buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.status_   = no
          and buf_parts.out-code  = 'free-zone':U
          and buf_parts.qnty      > 0
      on error undo, return error
      :
         v-total-avrg-qnty = v-total-avrg-qnty + buf_parts.fact-qnty.
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
          v-all-total-road-tax-base =  v-all-total-road-tax-base + (road-tax-base-loc * buf_parts.fact-qnty)
          v-all-total-road-tax-rubl =  v-all-total-road-tax-rubl + (road-tax-rubl-loc * buf_parts.fact-qnty)
         .
      end.
          if v-total-avrg-qnty > 0 then  do :
              assign
                  p-road-tax-base =  v-all-total-road-tax-base  / v-total-avrg-qnty
                  p-road-tax-rubl =  v-all-total-road-tax-rubl  / v-total-avrg-qnty
                  .
           end.
            if v-total-avrg-qnty <= 0 then do :
              find first buf_gds-obj no-lock
                where buf_gds-obj.obj-type  = p-obj-type
                  and buf_gds-obj.obj-code  = p-obj-code
                  and buf_gds-obj.artic     = p-artic
                  and buf_gds-obj.prod-type = p-prod-type
                  and buf_gds-obj.prod-code = p-prod-code
                no-error .
                    if available buf_gds-obj then do :
                      if buf_gds-obj.in-code <> "" then
                           v-doc-code = buf_gds-obj.in-code.
                      else do:
                        if available ub.price-doc then  v-doc-code = ub.price-doc.out-code.
                      end.
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  v-doc-code
  ,output is-hold-td
  )  .
                      if is-hold-td = true then do:
                        assign
                            p-road-tax-rubl = 0
                            p-road-tax-base = 0
                            .
                      end.
                      else do:
                          find b-td_trn-doc  where b-td_trn-doc.doc-code   = v-doc-code no-lock no-error .
                          find b-dl_doc-line where b-dl_doc-line.doc-code  = b-td_trn-doc.doc-code
                                          and b-dl_doc-line.artic     = p-artic
                                          and b-dl_doc-line.prod-type = p-prod-type
                                          and b-dl_doc-line.prod-code = p-prod-code no-lock no-error.
                                if available b-dl_doc-line then do :
assign
  price-rubl-with-tax-loc = b-dl_doc-line.price-rubl
  price-base-with-tax-loc = b-dl_doc-line.price-base
.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = b-td_trn-doc.doc-code
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
   find first in-vatp-goods where in-vatp-goods.artic     = b-dl_doc-line.artic     and
                                     in-vatp-goods.prod-type = b-dl_doc-line.prod-type and
                                     in-vatp-goods.prod-code = b-dl_doc-line.prod-code no-lock.
   if (not b-td_trn-doc.internal and
           b-td_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = b-dl_doc-line.road-tax
          road-tax-rubl-loc = b-dl_doc-line.road-tax * b-td_trn-doc.base-rate / b-td_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = b-dl_doc-line.road-tax
          road-tax-base-loc = b-dl_doc-line.road-tax / b-td_trn-doc.base-rate * b-td_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if b-dl_doc-line.transport-base = ? then 0 else b-dl_doc-line.transport-base)
        transport-rubl-loc = (if b-dl_doc-line.transport-rubl = ? then 0 else b-dl_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if b-dl_doc-line.other-base     = ? then 0 else b-dl_doc-line.other-base)
        other-rubl-loc     = (if b-dl_doc-line.other-rubl     = ? then 0 else b-dl_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if b-dl_doc-line.vat-pc         = ? then 0 else b-dl_doc-line.vat-pc)
        slt-pc-loc         = (if b-dl_doc-line.slt-pc         = ? then 0 else b-dl_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = b-dl_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = b-dl_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = b-dl_doc-line.obj-code  and
                                      in-vatp-parts.artic     = b-dl_doc-line.artic     and
                                      in-vatp-parts.prod-type = b-dl_doc-line.prod-type and
                                      in-vatp-parts.prod-code = b-dl_doc-line.prod-code
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
        road-tax-base-loc   = if b-dl_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / b-dl_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if b-dl_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / b-dl_doc-line.fact-qnty  else 0
        transport-base-loc  = if b-dl_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / b-dl_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if b-dl_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / b-dl_doc-line.fact-qnty  else 0
        other-base-loc      = if b-dl_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / b-dl_doc-line.fact-qnty  else 0
        other-rubl-loc      = if b-dl_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / b-dl_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if b-dl_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b-dl_doc-line.fact-qnty   else 0
        slt-base-loc        = if b-dl_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b-dl_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if b-dl_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b-dl_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if b-dl_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b-dl_doc-line.fact-qnty   else 0
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
                                    assign
                                        p-road-tax-rubl =  road-tax-rubl-loc
                                        p-road-tax-base =  road-tax-base-loc
                                        .
                                end.
                      end.
                     end.
            end.
end procedure.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-level-dis-attr no-undo
      field attr-code   like global-state-attr.attr-code
      field attr-value  like global-state-attr.attr-value
      index pi   attr-value descending
      index pi1 is unique attr-value
            attr-code .
procedure lvldsc-byattr :
define input  parameter p-attr-code  as character no-undo .
define input  parameter p-attr-value as character no-undo .
define output parameter p-val1       as decimal   no-undo .
define output parameter p-val2       as decimal   no-undo .
define output parameter p-prc        as decimal   no-undo .
  do
  on error undo, return error return-value
  :
  define variable v-str1 as character no-undo .
  v-str1 = trim ( p-attr-code , 'level-discnt':U ) .
  v-str1 = trim ( v-str1 , chr(4) ) .
 run lvldsc-bytt (
      input   v-str1
    , input   p-attr-value
    , output  p-val1
    , output  p-val2
    , output  p-prc )
      no-error .
  end.
end procedure.
procedure lvldsc-bytt :
define input  parameter p-attr-code as character no-undo .
define input  parameter p-attr-value as character no-undo .
define output parameter p-val1 as decimal   no-undo .
define output parameter p-val2 as decimal   no-undo .
define output parameter p-prc  as decimal   no-undo .
define variable v-str1 as character no-undo .
  do
  on error undo, return error return-value
  :
  assign
     v-str1 = trim ( p-attr-code , "[]()" )
     p-val1 = decimal(entry(1,v-str1, ";"))
     p-val2 = decimal(entry(2,v-str1, ";"))
     p-prc  = decimal(p-attr-value)
     no-error
  .
  end.
end procedure.
procedure level-dis-value :
define input  parameter p-price-prod as decimal   no-undo .
define input  parameter p-b-code     as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-prc as decimal   no-undo .
define variable v-level-dis-attr as character no-undo .
define variable v-type as character no-undo .
define variable v-val1 as decimal   no-undo .
define variable v-val2 as decimal   no-undo .
define variable v-prc  as decimal   no-undo .
define variable ix     as integer   no-undo .
do
 on error undo, return error return-value
 :
define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .
run ggoattr-value (
   input   buf_goods.grp-code
  ,input   v-cntxt-host-code-obj
  ,input   p-obj-type
  ,input   p-obj-code
  ,input   'level-dis':U
  ,output  v-level-dis-attr
  ,output  v-type ) no-error .
repeat ix = 1 to num-entries (v-level-dis-attr, chr(4)) - 1 :
  create
    tt-level-dis-attr
  .
  tt-level-dis-attr.attr-code = entry (1, entry (ix, v-level-dis-attr, chr(4)), chr(44)) .
  tt-level-dis-attr.attr-value = entry (2, entry (ix, v-level-dis-attr, chr(4)), chr(44)) .
end.
p-prc = 0 .
  if p-price-prod = 0 then do:
      for each tt-level-dis-attr no-lock
              :
            run lvldsc-bytt (
              input   tt-level-dis-attr.attr-code
            , input   tt-level-dis-attr.attr-value
            , output  v-val1
            , output  v-val2
            , output  v-prc  )
            .
            if v-val1  = 0  then do:
               p-prc = v-prc .
              leave.
            end.
      end.
  end.
  else do:
      for each tt-level-dis-attr no-lock
              :
            run lvldsc-bytt (
              input   tt-level-dis-attr.attr-code
            , input   tt-level-dis-attr.attr-value
            , output  v-val1
            , output  v-val2
            , output  v-prc  )
            .
            if p-price-prod   > v-val1 and
               p-price-prod  <= v-val2 then do:
               p-prc = v-prc .
              leave.
            end.
      end.
  end.
for each tt-level-dis-attr no-lock. delete tt-level-dis-attr. end.
 end.
end procedure.
procedure calc-price-levelprod :
define input  parameter p-mode     as integer   no-undo .
define input  parameter p-rb       as character no-undo .
define input  parameter p-b-code   as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-price-sale as decimal   no-undo .
define output parameter p-descript-calc as character no-undo .
define variable  v-PriceWithoutVat as decimal   no-undo init 0.
define variable  v-PriceWithVat    as decimal   no-undo init 0.
define variable  v-prod-vat        as decimal   no-undo init 0.
define variable  v-discnt          as decimal   no-undo init 0.
define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_parts for ub.parts  .
define variable v-part-code as character no-undo .
define variable v-in-code   as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  p-b-code
 , input  p-obj-type
 , input  p-obj-code
 , output v-PriceWithoutVat
 , output v-PriceWithVat
 , output v-prod-vat
 , output v-part-code
 , output v-in-code
        ) no-error .
      if error-status :error then do:
        return error "Нет цены производителя!".
      end.
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .
find first buf_parts no-lock where
           buf_parts.artic      = buf_goods.artic        and
           buf_parts.prod-type  = buf_goods.prod-type    and
           buf_parts.prod-code  = buf_goods.prod-code    and
           buf_parts.in-code    = buf_bar-code.in-code   and
           buf_parts.out-code   = buf_bar-code.in-code   and
           buf_parts.part-code  = buf_bar-code.part-code
           no-error .
            if error-status :error then do:
                find first buf_parts no-lock where
                          buf_parts.artic      = buf_goods.artic        and
                          buf_parts.prod-type  = buf_goods.prod-type    and
                          buf_parts.prod-code  = buf_goods.prod-code    and
                          buf_parts.in-code    = v-in-code              and
                          buf_parts.out-code   = v-in-code              and
                          buf_parts.part-code  = v-part-code
                          no-error .
                if error-status :error then do:
                   message
                    substitute("Нет цены производителя !  &1 &2&3&4&5"  ,
                                v-in-code,
                                v-part-code ,
                                buf_goods.artic   ,
                                buf_goods.prod-type,
                                buf_goods.prod-code ) .
                   return error "Нет цены производителя !!!".
                end.
            end.
run level-dis-value ( input (if p-mode = 2 then v-PriceWithoutVat else v-PriceWithVat) , input p-b-code, input p-obj-type, input p-obj-code, output v-discnt ) no-error .
define variable v-postWithoutVat-rubl as decimal   no-undo .
define variable v-postWithoutVat-base as decimal   no-undo .
   case p-mode :
    when 1 then do:
       if p-rb = "rubl" then do:
          p-price-sale = buf_parts.price-rubl + ( MINIMUM ( buf_parts.price-rubl , v-PriceWithVat ) * v-discnt / 100 ).
       end.
       else do:
          p-price-sale = buf_parts.price-base + ( MINIMUM ( v-PriceWithVat , buf_parts.price-base ) * v-discnt / 100 ).
       end.
    end.
    when 2 then do:
      if p-rb = "rubl" then do:
        v-postWithoutVat-rubl =  buf_parts.price-rubl - (buf_parts.price-rubl * buf_parts.vat-pc / (100 + buf_parts.vat-pc) ).
        p-price-sale = v-postWithoutVat-rubl + ( MINIMUM ( v-PriceWithoutVat , v-postWithoutVat-rubl ) * v-discnt / 100 ) .
      end.
      else do:
        v-postWithoutVat-base = buf_parts.price-base - (buf_parts.price-base * buf_parts.vat-pc / ( 100 + buf_parts.vat-pc) ) .
        p-price-sale = v-postWithoutVat-base + ( MINIMUM ( v-PriceWithoutVat, v-postWithoutVat-base) * v-discnt / 100 ) .
      end.
    end.
   end case.
p-descript-calc =
  string(p-mode) + '_Элементы расчета: ' +  chr(10)  +
  buf_goods.gds-name                  +  chr(10) +
  buf_goods.artic +
  buf_goods.prod-type +
  string(buf_goods.prod-code)         + chr(10) +
  "бар-код " +  string(p-b-code)      + chr(10)  +
  'ПН    ' + v-in-code  +
  ' серия ' + v-part-code             +  chr(10)  + chr(10) +
  'Цена поставщика без ндс    '  + string((buf_parts.price-rubl - (buf_parts.price-rubl * buf_parts.vat-pc / (100 + buf_parts.vat-pc) ) ))  + chr(10) +
  'Цена поставщика   c ндс    '  + string ( buf_parts.price-rubl )  + chr(10) +
  'Цена производителя без ндс ' +  string( v-PriceWithoutVat)       + chr(10) +
  'Цена производителя   c ндс ' +  string( v-PriceWithVat  )        + chr(10) +
  chr(10) +
  "% пороговой наценки        "  + string(v-discnt)                 + chr(10) +
  chr(10) +
  "сумма наценки от произв без ндс "  + string( v-PriceWithoutVat * v-discnt / 100 ) +  chr(10) +
  "сумма наценки от произв   с ндс "  + string( v-PriceWithVat * v-discnt / 100 )    +  chr(10)  +
  chr(10) +
  string(p-price-sale)                                                               +  chr(10) +
  (if p-mode = 1 then substitute("ПорогПр+НДС  &1 + ( min(&2или &1) * &3 / 100 )  = &4 " , buf_parts.price-rubl , v-PriceWithVat , v-discnt , p-price-sale)
  else                substitute("ПорогПр-НДС  &1 - ( &1 * &2 / 100 ) + ( min(&3 или &6 ) * &4 / 100 ) = &5 и еще накручивается НДС " , buf_parts.price-rubl , buf_parts.vat-pc , v-PriceWithoutVat , v-discnt , p-price-sale , v-postWithoutVat-rubl))
.
  end.
end procedure.
define buffer bb-price-list for ub.price-list .
define buffer p-doc for ub.price-doc .
DEFINE BUTTON b-calc
     LABEL "Рас&чет":L
     SIZE 8.75 BY 1.08.
DEFINE BUTTON b-exit-cycl AUTO-GO
     LABEL "СтопЦикл"
     SIZE 9 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 9 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 9 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-save AUTO-GO
     LABEL "Со&хр"
     SIZE 9 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE akt-date AS DATE FORMAT "99/99/99"
      VIEW-AS TEXT
     SIZE 14.88 BY 1.
DEFINE VARIABLE akt-num AS CHARACTER FORMAT "X(8)"
      VIEW-AS TEXT
     SIZE 14 BY 1.
DEFINE VARIABLE b-curr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 4.63 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE info AS CHARACTER FORMAT "X(256)"
      VIEW-AS TEXT
     SIZE 75.13 BY .67
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE loc-gds-obg-last AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE loc-gds-obj-avrg AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE loc-in-code AS CHARACTER FORMAT "X(8)"
      VIEW-AS TEXT
     SIZE 14 BY 1.
DEFINE VARIABLE loc-in-date AS DATE FORMAT "99/99/99"
      VIEW-AS TEXT
     SIZE 15.13 BY 1.
DEFINE VARIABLE new-avrg AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE new-last AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE new-old AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE old-avrg AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE old-last AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE old-price AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14 BY 1 TOOLTIP "Предыдущая переоценка" NO-UNDO.
DEFINE VARIABLE op-avrg AS DECIMAL FORMAT "->,>>9.<<<%":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE op-last AS DECIMAL FORMAT "->,>>9.<<<%":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14.63 BY 1 NO-UNDO.
DEFINE VARIABLE pc-avrg AS DECIMAL FORMAT "->,>>9.<<<%":U INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pc-last AS DECIMAL FORMAT "->,>>9.<<<%":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14.75 BY 1 NO-UNDO.
DEFINE VARIABLE pc-prev AS DECIMAL FORMAT "->,>>9.<<<%":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE s-new AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE s-new-old AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE s-old AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE v-dis AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Наценка"
      VIEW-AS TEXT
     SIZE 9.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 83.25 BY 2.17
     BGCOLOR 8 .
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 76.25 BY 10.21.
DEFINE QUERY Dialog-Frame FOR
      ub.price-list,
      ub.goods SCROLLING.
DEFINE FRAME Dialog-Frame
     info AT ROW 13.54 COL 4 COLON-ALIGNED NO-LABEL
     ub.price-list.price-sale AT ROW 4.25 COL 33.13 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 15 BY 1
          FGCOLOR 4
     ub.price-list.road-tax AT ROW 14.54 COL 19.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          FGCOLOR 4
     ub.price-list.excise AT ROW 14.54 COL 45.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          FGCOLOR 4
     b-calc AT ROW 15.75 COL 32.88
     B-save AT ROW 15.83 COL 7.38
     b-quit AT ROW 15.83 COL 47.75
     b-exit-cycl AT ROW 15.83 COL 18.88
     B-Help AT ROW 15.75 COL 61.5
     ub.price-list.doc-num AT ROW 1.13 COL 1.75 NO-LABEL
           VIEW-AS TEXT
          SIZE 14.13 BY .67
          FGCOLOR 4
     ub.price-list.artic AT ROW 1.13 COL 15.25 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 17.5 BY .67
          BGCOLOR 3 FGCOLOR 15
     ub.price-list.prod-code AT ROW 1.13 COL 33.25 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 9.25 BY .67
          BGCOLOR 3 FGCOLOR 15
     ub.price-list.prod-type AT ROW 1.13 COL 43.38 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 9 BY .67
          BGCOLOR 3 FGCOLOR 15
     ub.price-list.b-code AT ROW 1.13 COL 61.88 COLON-ALIGNED
          LABEL "Бар-код"
           VIEW-AS TEXT
          SIZE 10 BY .67
          BGCOLOR 3 FGCOLOR 15
     b-curr AT ROW 1.13 COL 77 COLON-ALIGNED NO-LABEL
     ub.goods.gds-name AT ROW 2 COL 1.75 NO-LABEL
           VIEW-AS TEXT
          SIZE 82.25 BY 1
          FGCOLOR 4
     old-price AT ROW 4.25 COL 18.13 COLON-ALIGNED NO-LABEL
     new-old AT ROW 4.25 COL 48.13 COLON-ALIGNED NO-LABEL
     pc-prev AT ROW 4.25 COL 63.13 COLON-ALIGNED NO-LABEL
     loc-gds-obj-avrg AT ROW 6.21 COL 5.13 NO-LABEL
     op-avrg AT ROW 6.21 COL 18.13 COLON-ALIGNED NO-LABEL
     pc-avrg AT ROW 6.21 COL 33.13 COLON-ALIGNED NO-LABEL
     old-avrg AT ROW 6.21 COL 48.13 COLON-ALIGNED NO-LABEL
     new-avrg AT ROW 6.21 COL 63.13 COLON-ALIGNED NO-LABEL
     loc-gds-obg-last AT ROW 8.21 COL 5.13 NO-LABEL
     op-last AT ROW 8.21 COL 18.13 COLON-ALIGNED NO-LABEL
     pc-last AT ROW 8.21 COL 33.13 COLON-ALIGNED NO-LABEL
     old-last AT ROW 8.21 COL 48.13 COLON-ALIGNED NO-LABEL
     new-last AT ROW 8.21 COL 63.13 COLON-ALIGNED NO-LABEL
     loc-in-code AT ROW 10.13 COL 5.13 NO-LABEL
     loc-in-date AT ROW 10.13 COL 18.13 COLON-ALIGNED NO-LABEL
     akt-num AT ROW 10.13 COL 48.13 COLON-ALIGNED NO-LABEL
     akt-date AT ROW 10.13 COL 63.13 COLON-ALIGNED NO-LABEL
     s-old AT ROW 12.29 COL 18.13 COLON-ALIGNED NO-LABEL
     s-new AT ROW 12.29 COL 33.13 COLON-ALIGNED NO-LABEL
     s-new-old AT ROW 12.29 COL 48.13 COLON-ALIGNED NO-LABEL
     ub.price-list.doc-qnty AT ROW 12.29 COL 63.13 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 15 BY 1
     v-dis AT ROW 14.67 COL 72.5 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
     RECT-2 AT ROW 3.17 COL 4.5
     "РАЗНИЦА стар." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 5.21 COL 50.13
          BGCOLOR 3 FGCOLOR 15
     "РАЗНИЦА стар." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 7.21 COL 50.13
          BGCOLOR 3 FGCOLOR 15
     "ПРОЦЕНТ стар." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 5.21 COL 20.13
          BGCOLOR 3 FGCOLOR 15
.
DEFINE FRAME Dialog-Frame
     "Новая" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 11.21 COL 35.13
          BGCOLOR 3 FGCOLOR 15
     "Учетная" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 5.21 COL 5.13
          BGCOLOR 3 FGCOLOR 15
     "ПРОЦЕНТ" VIEW-AS TEXT
          SIZE 15 BY .96 AT ROW 3.21 COL 65.13
          BGCOLOR 3 FGCOLOR 15
     "РАЗНИЦА" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 3.21 COL 50.13
          BGCOLOR 3 FGCOLOR 15
     "Новая" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 3.21 COL 35.13
          BGCOLOR 3 FGCOLOR 15
     "КОЛИЧЕСТВО" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 11.21 COL 65.13
          BGCOLOR 3 FGCOLOR 15
     "РАЗНИЦА" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 11.21 COL 50.13
          BGCOLOR 3 FGCOLOR 15
     "Старая" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 11.21 COL 20.13
          BGCOLOR 3 FGCOLOR 15
     "Накладная" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 9.21 COL 5.13
          BGCOLOR 3 FGCOLOR 15
     "СУММА" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 11.21 COL 5.13
          BGCOLOR 3 FGCOLOR 15
     "Дата" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 9.21 COL 65.13
          BGCOLOR 3 FGCOLOR 15
     "Старая" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 3.21 COL 20.13
          BGCOLOR 3 FGCOLOR 15
     "Старый акт" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 9.21 COL 50.13
          BGCOLOR 3 FGCOLOR 15
     "" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 9.21 COL 35.13
          BGCOLOR 3 FGCOLOR 15
     "Дата" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 9.21 COL 20.13
          BGCOLOR 3 FGCOLOR 15
     "РАЗНИЦА нов." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 7.21 COL 65.13
          BGCOLOR 3 FGCOLOR 15
     "ПРОЦЕНТ нов." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 5.21 COL 35.13
          BGCOLOR 3 FGCOLOR 15
     "Цена" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 3.21 COL 5.13
          BGCOLOR 3 FGCOLOR 15
     "РАЗНИЦА нов." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 5.21 COL 65.13
          BGCOLOR 3 FGCOLOR 15
     "Последняя" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 7.21 COL 5.13
          BGCOLOR 3 FGCOLOR 15
     "ПРОЦЕНТ стар." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 7.21 COL 20.13
          BGCOLOR 3 FGCOLOR 15
     "ПРОЦЕНТ нов." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 7.21 COL 35.13
          BGCOLOR 3 FGCOLOR 15
     SPACE(34.12) SKIP(8.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Строка переоценки"
         DEFAULT-BUTTON B-save CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       ub.price-list.excise:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       ub.price-list.road-tax:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-calc IN FRAME Dialog-Frame
DO:
run calc-pr in this-procedure .
END.
ON CHOOSE OF b-exit-cycl IN FRAME Dialog-Frame
DO:
assign frame  Dialog-Frame
     ub.price-list.price-sale
     .
     assign
     ub.price-list.d-pcnt       = p-disc
     ub.price-list.calc-method  = c-m
     ub.price-list.price-calc = ub.price-list.price-sale
     .
     assign
     stp-cycle  =  true
     .
END.
ON CHOOSE OF B-Help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
       stp-cycle  =  false.
       return "error".
END.
ON CHOOSE OF B-save IN FRAME Dialog-Frame
DO:
 run upd-field in this-procedure .
 run calc-pr in this-procedure .
assign frame  Dialog-Frame
     ub.price-list.price-sale
     .
     assign
     ub.price-list.d-pcnt       = p-disc
     ub.price-list.calc-method  = c-m
     ub.price-list.price-calc = ub.price-list.price-sale
     .
     stp-cycle  =  false.
END.
ON LEAVE OF ub.price-list.excise IN FRAME Dialog-Frame
DO:
    run upd-field in this-procedure no-error.
END.
ON LEAVE OF ub.price-list.price-sale IN FRAME Dialog-Frame
DO:
  run upd-field in this-procedure no-error.
  run calc-pr in this-procedure .
END.
ON LEAVE OF ub.price-list.road-tax IN FRAME Dialog-Frame
DO:
    run upd-field in this-procedure no-error.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
find first p-doc where recid(p-doc) = doc-rec no-lock no-error.
find first ub.price-list where recid(ub.price-list) = p-doc-rec .
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run enable_ui in this-procedure .
  run loc-init in this-procedure  .
  if  line-mode = "ЦИКЛ":U then do:
     enable  b-exit-cycl with frame Dialog-Frame.
     display b-exit-cycl  with frame Dialog-Frame.
     end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_ui in this-procedure .
PROCEDURE calc-pr :
if p-doc.status_ <> 'акт':U and available ub.gds-obj then do:
  new-avrg = input frame Dialog-Frame ub.price-list.price-sale - ub.gds-obj.avrg-rubl.
  new-last = input frame Dialog-Frame ub.price-list.price-sale - ub.gds-obj.last-rubl.
  pc-avrg = (input frame Dialog-Frame ub.price-list.price-sale / ub.gds-obj.avrg-rubl - 1) * 100.
  pc-last  = (input frame Dialog-Frame ub.price-list.price-sale / ub.gds-obj.last-rubl - 1) * 100.
  old-avrg = old-price - ub.gds-obj.avrg-rubl.
  old-last = old-price - ub.gds-obj.last-rubl.
  op-avrg = (old-price / ub.gds-obj.avrg-rubl - 1) * 100.
  op-last = (old-price / ub.gds-obj.last-rubl - 1) * 100.
  disp pc-avrg pc-last new-avrg new-last old-avrg old-last op-avrg op-last with frame Dialog-Frame no-error .
end.
new-old = input frame Dialog-Frame ub.price-list.price-sale - old-price.
pc-prev = (input frame Dialog-Frame ub.price-list.price-sale / old-price - 1) * 100.
s-new-old = new-old * ub.price-list.doc-qnty.
s-old = old-price * ub.price-list.doc-qnty.
s-new = input frame Dialog-Frame ub.price-list.price-sale * ub.price-list.doc-qnty.
disp new-old pc-prev s-new-old s-old s-new ub.price-list.doc-qnty with frame Dialog-Frame no-error .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH ub.price-list       WHERE recid(ub.price-list) = p-doc-rec SHARE-LOCK,       EACH ub.goods OF ub.price-list SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY info b-curr old-price new-old pc-prev loc-gds-obj-avrg op-avrg pc-avrg
          old-avrg new-avrg loc-gds-obg-last op-last pc-last old-last new-last
          loc-in-code loc-in-date akt-num akt-date s-old s-new s-new-old v-dis
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.goods THEN
    DISPLAY ub.goods.gds-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.price-list THEN
    DISPLAY ub.price-list.price-sale ub.price-list.doc-num ub.price-list.artic
          ub.price-list.prod-code ub.price-list.prod-type ub.price-list.b-code
          ub.price-list.doc-qnty
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-2 info ub.price-list.price-sale b-calc B-save b-quit B-Help
         ub.price-list.doc-num ub.price-list.artic ub.price-list.prod-code
         ub.price-list.prod-type ub.price-list.b-code b-curr ub.goods.gds-name old-price
         new-old pc-prev loc-gds-obj-avrg op-avrg pc-avrg old-avrg new-avrg
         loc-gds-obg-last op-last pc-last old-last new-last loc-in-code
         loc-in-date akt-num akt-date s-old s-new s-new-old ub.price-list.doc-qnty
         v-dis
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE loc-init :
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable cur-pr like ub.price-list.price-sale    no-undo.
define buffer lp-price-doc for ub.price-doc.
define buffer buff-goods for ub.goods.
define variable dor-nal as character no-undo .
define variable ff as logical no-undo .
define variable   is-petrolium  as logical             no-undo.
define variable   is-pieces     as logical             no-undo.
define variable v-rec as recid no-undo.
define variable t-ret as logical no-undo .
c-m = 'Отсутствует':U .
v-dis =  p-disc.
  frame Dialog-Frame:title = frame Dialog-Frame:title + " -  " + line-mode.
  run tax-name in this-procedure ( input 'rdt':U, output  dor-nal) .
  assign ub.price-list.road-tax :label in frame Dialog-Frame = dor-nal .
  Find first buff-goods no-lock where
        buff-goods.artic     = ub.price-list.artic and
        buff-goods.prod-type = ub.price-list.prod-type and
        buff-goods.prod-code = ub.price-list.prod-code
        no-error .
      If avail buff-goods Then DO:
          v-rec = recid (buff-goods).
           t-ret =  session:SET-WAIT-STATE("GENERAL") .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.price-list.artic
  ,  input ub.price-list.prod-type
  ,  input ub.price-list.prod-code
  , output is-petrolium
  , output is-pieces
  ) .
           t-ret =  session:SET-WAIT-STATE("") .
              IF ( hvrdtax( v-rec ) = true and
                 is-petrolium = true )
                then  DO :
                  define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.price-list.obj-code
  ,input  ub.price-list.obj-type
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info69 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_update':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  ub.price-list.obj-code
    ,input  ub.price-list.obj-type
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output ff
    )  .
end.
                    If ff Then do:
                           enable ub.price-list.road-tax with frame Dialog-Frame .
                    End.
              End.
      End.
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-abbr in g#library
  (input  v-cntxt-host-code-obj
  ,output b-curr
  )  .
find  first ub.gds-obj where
         ub.gds-obj.obj-code = ub.price-list.obj-code and
         ub.gds-obj.obj-type = ub.price-list.obj-type and
         ub.gds-obj.gds-code = ub.goods.gds-code
         no-lock no-error.
  if avail ub.gds-obj then
   assign
        loc-gds-obg-last =  if var-pr-r-b = "rubl" then  ub.gds-obj.last-rubl else ub.gds-obj.last-base
        loc-gds-obj-avrg =  if var-pr-r-b = "rubl" then  ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base
        loc-in-code = ub.gds-obj.in-code
        loc-in-date = ub.gds-obj.in-date
     .
  find first p-doc where recid(p-doc) = doc-rec no-lock no-error.
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  ub.price-list.obj-type
  ,input  ub.price-list.obj-code
  ,input  ub.price-list.b-code
  ,input  0
  ,input  ub.price-list.fact-order
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  ) no-error .
     old-price =  cur-pr.
     akt-num = cur-dn.
     if cur-dn <> ? then find first lp-price-doc where lp-price-doc.doc-num = cur-dn no-lock no-error .
     if avail lp-price-doc then
              akt-date = lp-price-doc.fact-date .
              else akt-date = ?.
   display
     old-price
     v-dis
     loc-gds-obg-last
     loc-gds-obj-avrg
     loc-in-code
     loc-in-date
     b-curr akt-num akt-date
     ub.price-list.road-tax
     ub.price-list.excise
     with frame Dialog-Frame.
   enable
     old-price
     loc-in-code
     loc-in-date
     v-dis
     loc-gds-obg-last
     loc-gds-obj-avrg
     b-curr akt-num akt-date
     with frame Dialog-Frame.
     run calc-pr in this-procedure .
     run sel-info in this-procedure .
END PROCEDURE.
PROCEDURE sel-info :
 do
 on error undo, return error return-value
 :
define variable par-type as character no-undo .
define variable p-node-code like ub.goods.grp-code no-undo .
define variable p-prc-min as decimal no-undo .
define variable p-prc-max as decimal no-undo .
define variable p-increase-pc as decimal no-undo .
define variable p-round-method as character no-undo .
define variable p-base         as decimal no-undo .
define variable p-value-margin   as integer no-undo .
define variable p-type-margin    as logical no-undo .
define variable p-value-increase   as integer no-undo .
define variable p-type-increase    as logical no-undo .
define variable p-value-rmethod   as integer no-undo .
define variable p-type-rmethod    as logical no-undo .
define buffer bl_goods for ub.goods.
define variable l-par as logical   no-undo .
   run chec-par in this-procedure (
         output l-par
        ,input  p-doc.host-code
        ,input  p-doc.obj-type
        ,input  p-doc.obj-code
      ) no-error .
if trim(par-pr-discm) = "" then return .
    find first bl_goods   where ub.price-list.artic     = bl_goods.artic     and
                                ub.price-list.prod-code = bl_goods.prod-code and
                                ub.price-list.prod-type = bl_goods.prod-type no-lock no-error .
                            if error-status :error then return error.
    assign
      p-node-code  = bl_goods.grp-code
    .
    run gds-attr-margin-value in this-procedure
    ( input   bl_goods.gds-code,
      input   p-doc.obj-type ,
      input   p-doc.obj-code ,
      output  p-prc-min  ,
      output  p-prc-max  ,
      output  p-increase-pc,
      output  p-round-method  ,
      output  p-base          ,
      output  p-value-margin    ,
      output  p-type-margin  ,
      output  p-value-increase    ,
      output  p-type-increase ,
      output  p-value-rmethod   ,
      output  p-type-rmethod
                ) .
    if p-type-margin = false  then return.
     info = "ИНТЕРВАЛ НАЦЕНКИ" .
      case  par-pr-discm :
        when "cost":u then     do: info = info + " от учетной цены " .    end.
        when "cost-vat":u then do: info = info + " от учетной цены без налогов " .       end.
        when "sale":u then     do: info = info + " от продажной цены " .       end.
        when "sale-":u then     do: info = info + " от продажной цены " .       end.
        when "prod":u then     do: info = info + " от цены производителя с НДС" .  end.
        when "prod-vat":u then     do: info = info + " от цены производителя без НДС" .       end.
      end case.
      info = info + " от " + string(p-prc-min) + "% до " + string (p-prc-max) + "% ".
      display info  with frame Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE upd-field :
define variable ff as logical no-undo .
define variable ff1 as logical init true no-undo .
define variable cur-dn as decimal no-undo .
define variable cur-pr as decimal no-undo .
define variable cur-rt as decimal no-undo .
define variable cur-ex as decimal no-undo .
define variable calc-rec as recid no-undo.
define buffer buff-goods for ub.goods .
define buffer p-doc for ub.price-doc.
define variable calc-method    as char    no-undo.
define variable increase-pc    as decimal no-undo.
define variable round-method   as char    no-undo.
define variable round-base     as decimal no-undo.
  find current ub.price-list.
  find first p-doc where p-doc.doc-num = ub.price-list.doc-num no-lock no-error.
    assign
       calc-method    = ub.price-list.calc-method
       increase-pc    = p-disc
       round-method   = r-m
       round-base     = r-b
       .
  if dec (ub.price-list.price-sale :screen-value in frame Dialog-Frame) <> ub.price-list.price-sale then do:
    assign
      ub.price-list.calc-method = c-m
      ub.price-list.price-calc = ub.price-list.price-sale
      ub.price-list.price-sale = dec (ub.price-list.price-sale :screen-value in frame Dialog-Frame)
      .
    assign
       calc-method    = c-m
       increase-pc    = p-disc
       round-method   = r-m
       round-base     = r-b
       .
        run calc-pr-sub in this-procedure  (input  ub.price-list.b-code,
                          input  p-doc.doc-num,
                          input  calc-method,
                          input  increase-pc,
                          input  round-method,
                          input  round-base,
                          output calc-rec) no-error.
        if error-status :error then
          undo, return error.
  end.
If dec (ub.price-list.excise :screen-value in frame Dialog-Frame ) <> ub.price-list.excise then do:
    assign
    ub.price-list.excise     = dec (ub.price-list.excise     :screen-value in frame Dialog-Frame)
    .
End.
If dec (ub.price-list.road-tax :screen-value in frame Dialog-Frame) <> ub.price-list.road-tax then do:
       Find first buff-goods no-lock where
            buff-goods.artic     = ub.price-list.artic and
            buff-goods.prod-type = ub.price-list.prod-type and
            buff-goods.prod-code = ub.price-list.prod-code
            no-error .
      If avail buff-goods Then DO:
              IF hvrdtax( recid(buff-goods)) = false  then  DO :
                 message "В товаре нет компонента цены '"   ub.price-list.road-tax:label  "' ,  изменять нельзя ! " .
              End.
              Else do:
                  define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.price-list.obj-code
  ,input  ub.price-list.obj-type
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info73 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_update':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  ub.price-list.obj-code
    ,input  ub.price-list.obj-type
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output ff
    )  .
end.
                    if not ff then do :
                      assign
                        ub.price-list.road-tax   = ub.price-list.road-tax
                      .
                    end.
                    else do :
                      assign
                        ub.price-list.road-tax = dec(ub.price-list.road-tax:screen-value in frame Dialog-Frame)
                      .
                    end.
              End.
      End.
 end.
 Display ub.price-list.excise ub.price-list.price-sale ub.price-list.road-tax  with frame Dialog-Frame .
end procedure.
