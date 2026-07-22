define input        parameter parParentProc    as widget-handle no-undo.
define input-output parameter doc-rec          as recid     no-undo .
define input        parameter doc-mode         as character no-undo .
define input-output parameter next-prev        as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Формирование приказа переоценки".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable g#log     as logical   no-undo .
define variable gds-rec   as recid     no-undo .
define variable line-rec  as recid     no-undo .
define variable line-mode as character no-undo .
define variable notes     as character no-undo .
define variable rep-rec   as recid     no-undo .
define variable ref-rec   as recid     no-undo .
define variable list-mode as character no-undo .
define variable lns-cnt   as integer   no-undo .
define variable g#stat    as character no-undo .
define variable v-qqq     as logical   no-undo .
define variable v-str     as character no-undo .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure ver-modificator-price-is-null :
 do
 on error undo, return error return-value
 :
define input parameter p-artic     like ub.goods.artic no-undo.
define input parameter p-prod-type like ub.goods.prod-type no-undo.
define input parameter p-prod-code like ub.goods.prod-code no-undo.
define input parameter p-obj-type  like ub.clients.obj-type no-undo.
define input parameter p-obj-code  like ub.clients.obj-code no-undo.
define output parameter p-ret as logical no-undo .
define variable v-gds-code  like ub.goods.gds-code no-undo .
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
p-ret = true .
find first buf_fbr-gds-obj no-lock where
            buf_fbr-gds-obj.gds-code = v-gds-code and
            buf_fbr-gds-obj.obj-code = p-obj-code and
            buf_fbr-gds-obj.obj-type = p-obj-type use-index pi no-error .
 if available buf_fbr-gds-obj then
              if buf_fbr-gds-obj.is-modificator = true and
                 buf_fbr-gds-obj.is-null-price = true
                 then  p-ret = false .
 end.
end procedure.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#libbcrcn as handle no-undo .
procedure create-price-list-attr :
 do
 on error undo, return error return-value
 :
define input parameter p-attr-code    like ub.price-list-attr.attr-code  no-undo .
define input parameter p-attr-value   like ub.price-list-attr.attr-value no-undo .
define input parameter p-b-code       like ub.price-list-attr.b-code     no-undo .
define input parameter p-doc-num      like ub.price-list-attr.doc-num    no-undo .
define input parameter p-price-type   like ub.price-list-attr.price-type no-undo .
define buffer buf_price-list-attr for ub.price-list-attr.
find first buf_price-list-attr  exclusive-lock  where
  buf_price-list-attr.attr-code    = p-attr-code    and
  buf_price-list-attr.b-code       = p-b-code       and
  buf_price-list-attr.doc-num      = p-doc-num      and
  buf_price-list-attr.price-type   = p-price-type  no-error .
  if not available  buf_price-list-attr then do:
      create buf_price-list-attr.
      assign
        buf_price-list-attr.attr-code    = p-attr-code
        buf_price-list-attr.attr-value   = p-attr-value
        buf_price-list-attr.b-code       = p-b-code
        buf_price-list-attr.doc-num      = p-doc-num
        buf_price-list-attr.price-type   = p-price-type
      .
  end.
  else do:
        buf_price-list-attr.attr-value   = p-attr-value .
  end.
 end.
end procedure.
procedure view-price-list-attr :
 do
 on error undo, return error return-value
 :
define input  parameter p-attr-code    like ub.price-list-attr.attr-code  no-undo .
define input  parameter p-b-code       like ub.price-list-attr.b-code     no-undo .
define input  parameter p-doc-num      like ub.price-list-attr.doc-num    no-undo .
define input  parameter p-price-type   like ub.price-list-attr.price-type no-undo .
define output parameter p-attr-value   like ub.price-list-attr.attr-value no-undo .
define buffer buf_price-list-attr for ub.price-list-attr.
find first buf_price-list-attr no-lock where
  buf_price-list-attr.attr-code    = p-attr-code    and
  buf_price-list-attr.b-code       = p-b-code       and
  buf_price-list-attr.doc-num      = p-doc-num      and
  buf_price-list-attr.price-type   = p-price-type  no-error .
  if available  buf_price-list-attr then do:
      assign
        p-attr-value = buf_price-list-attr.attr-value
      .
  end.
  else do:
        p-attr-value = ? .
  end.
 end.
end procedure.
procedure pdoc-forming-attr :
define input  parameter p-plt-id       as integer   no-undo .
define input  parameter p-plt-db-num   as integer   no-undo .
define input  parameter p-pdf-id       as integer   no-undo .
define input  parameter p-pdf-db       as integer   no-undo .
define input  parameter p-attr-code    as character no-undo .
define input  parameter p-val          as character no-undo .
  do
  on error undo, return error return-value
  :
  find first  ub.price-doc-forming-attr exclusive-lock where
              ub.price-doc-forming-attr.plt-id       = p-plt-id       and
              ub.price-doc-forming-attr.plt-db-num   = p-plt-db-num   and
              ub.price-doc-forming-attr.pdf-id       = p-pdf-id       and
              ub.price-doc-forming-attr.pdf-db       = p-pdf-db       and
              ub.price-doc-forming-attr.attr-code    = p-attr-code
              no-error .
    if not available  ub.price-doc-forming-attr then create ub.price-doc-forming-attr.
    assign
      ub.price-doc-forming-attr.plt-id       = p-plt-id
      ub.price-doc-forming-attr.plt-db-num   = p-plt-db-num
      ub.price-doc-forming-attr.pdf-id       = p-pdf-id
      ub.price-doc-forming-attr.pdf-db       = p-pdf-db
      ub.price-doc-forming-attr.attr-code    = p-attr-code
      ub.price-doc-forming-attr.attr-value   = p-val
    .
  end.
end procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
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
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  )  .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info37 as character format "X(65)" no-undo
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
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_slt-pc
  ) no-error .
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.
define variable view-text as character no-undo .
define buffer prev-list         for ub.price-list.
define buffer buff-price-list-a for ub.price-list.
define buffer cli-buf           for ub.clients.
define variable arg-price  like ub.price-list.price-sale no-undo.
define variable arg-pc     as decimal                    no-undo.
define variable old-price  like ub.price-list.price-sale no-undo.
define variable old-pc     as decimal                    no-undo.
define variable f-cost-pc  as decimal                    no-undo.
define variable f-pr-pc    as decimal                    no-undo.
define variable f-cost     like ub.price-list.price-sale no-undo.
define variable f-pr       like ub.price-list.price-sale no-undo.
define variable calc-dtl   as character                  no-undo.
define variable calc-name  as character format "x(48)"   no-undo.
define variable root-price like ub.price-list.price-sale no-undo.
define variable ref-list   as character                  no-undo.
define variable sort-clmn-name as character              no-undo.
define variable p-list     as character                  no-undo.
define new shared temp-table temp-gds-list no-undo
field gds-code  like ub.goods.gds-code
field node-code like ub.gds-prt.node-code
field n-n as decimal
index pi is unique primary gds-code node-code .
define variable new-pr-recid as recid no-undo .
define variable v-n-n as decimal no-undo .
define variable cost-base     as decimal no-undo.
define variable cost-rubl     as decimal no-undo.
define variable v-price-base  as decimal no-undo.
define variable v-price-rubl  as decimal no-undo.
define variable tt-price-sale as decimal no-undo.
define variable cur-rt-base   as decimal no-undo.
define variable cur-rt-rubl   as decimal no-undo.
define variable tt-price-prodwihvat as decimal no-undo.
define variable tt-prod-vat         as decimal no-undo.
define variable obj-in-code  like ub.gds-obj.in-code   no-undo.
define variable obj-in-date  like ub.gds-obj.in-date   no-undo.
define variable varschartic  like ub.price-list.artic initial " " no-undo.
define shared variable br-handle as handle no-undo.
define shared buffer  p-doc for ub.price-doc.
define shared query br-docs for p-doc scrolling.
define variable tt-col as logical no-undo .
define variable   rdtaxcdvalue  as character initial ? no-undo.
define variable   rdtaxcdtype   as character initial ? no-undo.
define variable   dor-nal       as character           no-undo.
define buffer buff-goods    for ub.goods.
define buffer l-price-list  for ub.price-list.
define buffer price-list-tt for ub.price-list.
define query br-list for ub.price-list except, ub.bar-code, ub.goods, ub.gds-prt scrolling.
 function func-cost-price return decimal ( input  p-b-code  as integer ,
                                           input  p-gds-code as integer ,
                                           input  p-status_  as character ,
                                           input  p-r-b      as character) .
define variable f-price as decimal no-undo .
run proc-cost-price-fact in this-procedure (
      input  p-b-code   ,
      input  p-gds-code ,
      input  p-status_  ,
      input  p-r-b      ,
      output f-price    )
      .
return (f-price).
end function.
function fnc-alt-pr return logical (buffer local-price-list for ub.price-list).
define variable f-log as logical no-undo .
define buffer o-price-list for ub.price-list.
define buffer o-goods      for ub.goods.
define buffer o-bar-code   for ub.bar-code.
define buffer b-bar-code   for ub.bar-code.
 f-log = false .
case local-price-list.main-price :
  when true  then do:
      for each o-price-list no-lock where
                o-price-list.doc-num    = local-price-list.doc-num and
                o-price-list.artic      = local-price-list.artic and
                o-price-list.prod-type  = local-price-list.prod-type and
                o-price-list.prod-code  = local-price-list.prod-code and
                o-price-list.price-type = '',
          each o-bar-code no-lock where
                o-bar-code.b-code = o-price-list.b-code,
          each o-goods no-lock where
                o-goods.gds-code = o-bar-code.gds-code and
                o-goods.unit-base <> o-bar-code.unit-cli :
                  f-log = true .
                  leave.
      end.
  end.
  otherwise  do:
      find first b-bar-code no-lock where
                  b-bar-code.b-code  = local-price-list.b-code  no-error .
      for each o-price-list no-lock where
                o-price-list.doc-num    = local-price-list.doc-num   and
                o-price-list.artic      = local-price-list.artic     and
                o-price-list.prod-type  = local-price-list.prod-type and
                o-price-list.prod-code  = local-price-list.prod-code and
                o-price-list.price-type = '',
          each o-bar-code no-lock where
                o-bar-code.b-code     = o-price-list.b-code and
                o-bar-code.node-code  = b-bar-code.node-code ,
          each o-goods no-lock where
                o-goods.gds-code   = o-bar-code.gds-code  and
                o-goods.unit-base <> o-bar-code.unit-cli  :
                  f-log = true .
                  leave.
      end.
  end.
end case.
return (f-log).
end function.
function fnc-arg-price return decimal (buffer local-price-list for ub.price-list).
  arg-price = local-price-list.price-calc.
  return (arg-price).
end function.
function fnc-arg-pc return decimal (buffer local-price-list for ub.price-list).
  arg-pc = (local-price-list.price-sale / local-price-list.price-calc - 1) * 100.
  if arg-pc > 9999 then
    arg-pc = ?.
  return (arg-pc).
end function.
function fnc-old-price return decimal (buffer local-price-list for ub.price-list).
define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  local-price-list.obj-type
  ,input  local-price-list.obj-code
  ,input  local-price-list.b-code
  ,input  0
  ,input  local-price-list.fact-order
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  ) no-error .
  old-price = cur-pr.
  return (old-price).
end function.
function fnc-old-pc return decimal (buffer local-price-list for ub.price-list).
define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  local-price-list.obj-type
  ,input  local-price-list.obj-code
  ,input  local-price-list.b-code
  ,input  0
  ,input  local-price-list.fact-order
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  ) no-error .
  old-pc = (local-price-list.price-sale / cur-pr - 1) * 100.
  if old-pc > 9999 then
    old-pc = ?.
  return (old-pc).
end function.
define variable text-i as character   init "" no-undo .
define button b-exit auto-go
     label "&Выход":l
     size 6 by 1 tooltip "Выход из документа с сохранением состояния".
define button b-add
     label "&Добав":l
     size 8 by 1 tooltip "Добавление в переоценку цен на главные коды".
define button b-special
     label "&Осн.":l
     size 8 by 1 tooltip "Добавление в переоценку спеццен на основные коды (шкала, партии)".
define menu m-chg
       menu-item m-one-chg      label "Текущая строка -<<ctrl-o>>"
       menu-item m-lst-chg      label "Список товаров"
       .
define button b-chg
     label "Рас&чет":l
     size 8 by 1 tooltip "Пересчет цен в строке (строках)".
define menu m-del
       menu-item m-one-del      label "Текущая строка"
       menu-item m-lst-del      label "Список товаров"
       .
define button b-del
     label "&Удал":l
     size 8 by 1 tooltip "Удаление строк из переоценки".
define button b-alt
     label "Н&еосн.":l
     size 8 by 1 tooltip "Добавление скидок и цен на неосновные коды".
define button b-notes
     label "П&рим":l
     size 8 by 1 tooltip "Просмотр примечания к переоценке".
define button b-arch
     label "Учет":l
     size 8 by 1 tooltip "Просмотр учетной информации".
define button b-help
     label "Помо&щь":l
     size 8 by 1 tooltip "Помощь".
define button b-quest
     label "&?":l
     size 2 by .9 tooltip "Описание метода расчета".
define button b-history
     label "Ис&тор":l
     size 8 by 1 tooltip "История изменения переоценки".
define button b-calc
     label "Ит&оги":l
     size 14.88 by 1 tooltip "Расчет итогов по переоценке".
define button b-next auto-go
     label "&>>":l
     size 3 by 1 tooltip "Переход к просмотру следующей переоценки списка".
define button b-prev auto-go
     label "&<<":l
     size 3 by 1 tooltip "Переход к просмотру предыдущей переоценки списка".
define variable p-avrg as decimal format "->>,>>>,>>>,>>9.99" label "Цена учет."
view-as text size 12 by 0.79
tooltip "Текущая средняя учетная цена на объекте"
no-undo.
define variable p-avrg-fact as decimal format "->>,>>>,>>>,>>9.99" label "Цена Ср.Уч."
view-as text size 12 by 0.79
tooltip "Средняя учетная цена до момента закрытия переоценки на факт"
FGCOLOR 3
no-undo.
define variable p-last as decimal format "->>,>>>,>>>,>>9.99" label "Цена прих."
view-as text size 12 by 0.79
tooltip "Цена последней внешней ПН "
no-undo.
define variable p-new as decimal format "->>,>>>,>>>,>>9.99" label "Цена новая"
view-as text size 15 by 0.79
tooltip "Цена после переоценки"
fgcolor 4
no-undo.
define variable p-old as decimal format "->>,>>>,>>>,>>9.99" label "Цена старая"
view-as text size 12 by 0.79
tooltip "Цена до переоценки (Цена предыдущей переоценки)"
no-undo.
define variable p-pc-prev as decimal format "->,>>9.<<<%":u label "Разница"
view-as text size 8 by 0.79
tooltip "На сколько изменилась цена после переоценки в процентах"
no-undo.
define variable p-pc-avrg as decimal format "->,>>9.<<<%":u label "Новая/Учет"
view-as text size 15 by 0.79
tooltip "Новая цена по отношению к учетной цене в процентах"
no-undo.
define variable p-pc-avrg-fact as decimal format "->,>>9.<<<%":u label "Новая/Ср.Уч"
view-as text size 15 by 0.79
tooltip "Новая цена по отношению к учетной цене(факт) в процентах"
FGCOLOR 3
no-undo.
define variable p-pc-last as decimal format "->,>>9.<<<%":u label "Новая/Прих"
view-as text size 15 by 0.79
tooltip "Новая цена по отношению к цене последнего прихода в процентах"
no-undo.
define variable p-op-avrg as decimal format "->,>>9.<<<%":u label "Старая/Учет"
view-as text size 12 by 0.79
tooltip "Старая цена по отношению к учетной цене в процентах"
no-undo.
define variable p-op-avrg-fact as decimal format "->,>>9.<<<%":u label "Старая/Ср.Уч"
view-as text size 11 by 0.79
tooltip "Старая цена по отношению к учетной цене(факт) в процентах"
FGCOLOR 3
no-undo.
define variable p-op-last as decimal format "->,>>9.<<<%":u label "Старая/Прих"
view-as text size 12 by 0.79
tooltip "Старая цена по отношению к цене последнего прихода в процентах"
no-undo.
define variable p-pc-op-avrg as decimal format "->,>>9.<<<%":u label "Разница"
view-as text size 8 by 0.79
tooltip "Разница процентов (по отношению к учетной цене)"
no-undo.
define variable p-pc-op-avrg-fact as decimal format "->,>>9.<<<%":u label "Разница"
view-as text size 8 by 0.79
tooltip "Разница процентов (по отношению к учетной цене(факт))"
FGCOLOR 3
no-undo.
define variable p-pc-op-last as decimal format "->,>>9.<<<%":u label "Разница"
view-as text size 8 by 0.79
tooltip "Разница процентов (по отношению к цене последнего прихода)"
no-undo.
define variable p-calc-metod as char format  "x(17)"
view-as text size 17 by 1
tooltip "Метод расчета новой продажной цены товара"
no-undo.
define variable s-new as decimal format "->>,>>>,>>>,>>9.99" label "Сумма новая"
view-as text size 15 by 0.79
tooltip "Сумма остатка после переоценки"
no-undo.
define variable s-old as decimal format "->>,>>>,>>>,>>9.99" label "Сумма старая"
view-as text size 13 by 0.79
tooltip "Сумма остатка до переоценки"
no-undo.
define variable s-new-old as decimal format "->>,>>>,>>>,>>9.99" label "Разница"
view-as text size 15 by 0.79
tooltip "Сумма документа (После переоценки - До переоценки)"
no-undo.
define variable pc-prev as decimal format "->,>>9.<<<%":u label "Разница"
view-as text size 8 by 0.79
tooltip "На сколько изменилась сумма остатка после переоценки в процентах"
no-undo.
define variable pc-avrg as decimal format "->,>>9.<<<%":u label "Новая/Учет"
view-as text size 15 by 0.79
tooltip "Новая сумма остатка по отношению к сумме в учетных ценах в процентах"
no-undo.
define variable pc-last as decimal format "->,>>9.<<<%":u label "Новая/Прих"
view-as text size 15 by 0.79
tooltip "Новая сумма остатка по отношению к сумме в ценах последнего прихода в процентах"
no-undo.
define variable op-avrg as decimal format "->,>>9.<<<%":u label "Старая/Учет"
view-as text size 14 by 0.79
tooltip "Старая сумма остатка по отношению к сумме в учетных ценах в процентах"
no-undo.
define variable op-last as decimal format "->,>>9.<<<%":u label "Старая/Прих"
view-as text size 14 by 0.79
tooltip "Старая сумма остатка по отношению к сумме в ценах последнего прихода в процентах"
no-undo.
define variable pc-op-avrg as decimal format "->,>>9.<<<%":u label "Разница"
view-as text size 15 by 0.79
tooltip "Разница процентов (по отношению к учетным ценам)"
no-undo.
define variable pc-op-last as decimal format "->,>>9.<<<%":u label "Разница"
view-as text size 15 by 0.79
tooltip "Разница процентов (по отношению к ценам последнего прихода)"
no-undo.
define button r-copy
     image-up file "btn-down-arrow"
     image-down file "btn-down-arrow"
     image-insensitive file "btn-down-arrow"
     size 3 by .88 tooltip " ".
define rectangle rect-line  edge-pixels 2 graphic-edge  no-fill    size 98.63 by 5.83.
define rectangle rect-tot  edge-pixels 2 graphic-edge  no-fill   size 98.63 by 3.08     fgcolor 0 .
define variable copy-type    as char
     view-as fill-in
     size 7 by 1 no-undo.
define variable copy-code    as integer
     view-as fill-in
     size 7 by 1 no-undo.
define variable doc-code     like ub.price-doc.doc-num       no-undo.
define variable common-price like ub.price-list.price-sale   no-undo.
define variable calc-method  as char
        format "x(12)" view-as combo-box inner-lines 18 list-items
        'Товар':U,'Учетная':U,'Учет-объект':U,'Учет-резерв':U,'Приходная':U,'Прих-объект':U,'Старая':U,'Новая':U,'Объект':U,'Накладная':U,'Переоценка':U,'Накл-безНДС':U,'Учет-безНДС':U,'Стар-безНДС':U,'Единая':U,'НсП':U,'НсП+накл':U,'Откат_цен':U,'Отсутствует':U,'Не-считать':U,'Производит':U,'Произв-НДС':U,'ПорогПр-НДС':U,'ПорогПр+НДС':U
        size 14 by 1
        no-undo.
define variable increase-pc  as decimal
        label "На&ценка"
        format "->>>9.<<<%" view-as fill-in size 10.25 by 1  no-undo.
define variable round-base   as decimal no-undo.
define variable round-method as char
        format "x(15)" view-as combo-box inner-lines 7 list-items
        '9-окончание':U,
        '9-99окончание':U,
        'Без-дробных':U,
        'Произвольно':U,
        'Вверх':U,
        'Коэффициент':U,
        'Отключено':U size 15 by 1 bgcolor white_color
        label "Окру&гление"
        no-undo.
define variable loc-art  as char  label "Нач.артик" format "x(16)" view-as fill-in size 14 by 1 fgcolor red_color no-undo .
define variable loc-name as char  label "Нач.назв." format "x(40)" view-as fill-in size 14 by 1 fgcolor red_color  no-undo.
define variable loc-code as char  label "Бар-код"   format "x(14)" view-as fill-in  size 14 by 1 fgcolor red_color  no-undo.
define variable conf-par     as char no-undo.
define variable par-type     as char no-undo.
define variable a-n-c as char view-as radio-set horizontal radio-buttons
"&А","art",
"&Н","name",
"&К","code"
size 10 by 1 no-undo.
define browse br-list query br-list no-lock
    display fnc-alt-pr (buffer ub.price-list)  @ tt-col     column-label 'Н' format "*/" if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl   column-label 'Тип'  format "x(3)" ub.bar-code.b-code                column-label 'Код'  format ">>>>>>>>>>>>>>>>9" ub.price-list.artic                column-label 'Артикул'  format "x(16)" if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           ub.goods.gds-name         else            ub.bar-code.part-code  + '  ПН ' + ub.bar-code.in-code       else         '    ' + ub.gds-prt.f-name   @ calc-name  column-label 'Название'  format "x(47)" ub.price-list.price-sale                column-label 'Новая цена'  fnc-old-price (buffer ub.price-list)   @ old-price  column-label 'Старая'  fnc-old-pc  (buffer ub.price-list)   @ old-pc     column-label '%.'  format "->,>>9.<<" fnc-arg-price (buffer ub.price-list)   @ arg-price  column-label 'Исходная'  fnc-arg-pc (buffer ub.price-list)   @ arg-pc     column-label '%'  format "->,>>9.<<" fnc-cost (buffer ub.price-list)  @ f-cost     column-label 'Учетная' fnc-cost-pc (buffer ub.price-list)  @ f-cost-pc  column-label '%' format "->,>>9.<<" fnc-pr (buffer ub.price-list)  @ f-pr       column-label 'Приходная' fnc-pr-pc (buffer ub.price-list)  @ f-pr-pc    column-label '%' format "->,>>9.<<" ub.price-list.calc-method               column-label 'Расчет' format "x(20)" ub.price-list.doc-qnty               column-label 'Количество' format "->>,>>>,>>9.<<<" ub.goods.unit-base               column-label 'Изм' format "x(3)" ub.price-list.road-tax ub.price-list.excise               column-label 'Акциз' ub.price-list.line-num               column-label '№п/п'
    enable ub.price-list.price-sale ub.price-list.excise
    with
    size 98.38 by 12
    bgcolor white_color
    separators.
ub.price-list.price-sale :label-fgcolor in browse br-list = blue_color .
ub.price-list.excise:label-fgcolor in browse br-list = blue_color .
old-price :label-fgcolor in browse br-list = 1 .
old-pc    :label-fgcolor in browse br-list = 1 .
arg-price :label-fgcolor in browse br-list = 4 .
arg-pc    :label-fgcolor in browse br-list = 4 .
f-cost    :label-fgcolor in browse br-list = 2 .
f-cost-pc :label-fgcolor in browse br-list = 2 .
f-pr      :label-fgcolor in browse br-list = 5 .
f-pr-pc   :label-fgcolor in browse br-list = 5 .
define frame d-pr-doc
     b-exit at row 1 col 1
     b-prev at row 1 col 7
     b-next at row 1 col 10
     b-add at row 1 col 13
     b-del at row 1 col 21
     b-chg at row 1 col 29
     b-special at row 1 col 37
     b-alt at row 1 col 45
     b-history at row 1 col 53
     b-arch at row 1 col 61
     b-notes at row 1 col 69
     b-help at row 1 col 77
     a-n-c at row 1 col 85 no-label
     text-i view-as text size 8 by 1
          at row 2 col 1 no-label
     calc-method at row 2 col 7 colon-aligned no-label
     b-quest at row 2 col 23
     common-price at row 2 col 23 colon-aligned no-label
     doc-code at row 2 col 23 colon-aligned no-label
     copy-type at row 2 col 23 colon-aligned no-label
     copy-code at row 2 col 30 colon-aligned no-label
     r-copy at row 2 col 39
     increase-pc at row 2 col 50 colon-aligned
     round-method at row 2 col 73 colon-aligned
     round-base at row 2 col 87.63 colon-aligned no-label
     br-list at row 3.08 col 1
     loc-code at row 15.21 col 10 colon-aligned
     loc-name at row 15.21 col 10 colon-aligned
     loc-art  at row 15.21 col 10 colon-aligned
     b-calc at row 22.96 col 83.88
     p-old at row 16 col 39.75 colon-aligned
     p-new at row 16 col 63.75 colon-aligned
     p-pc-prev at row 16 col 87.75 colon-aligned
     p-avrg-fact       at row 17.42 col 13.88 colon-aligned
     p-op-avrg-fact    at row 17.42 col 39.88 colon-aligned
     p-pc-avrg-fact    at row 17.42 col 63.88 colon-aligned
     p-pc-op-avrg-fact at row 17.42 col 87.88 colon-aligned
     p-avrg at row 18.17 col 13.88 colon-aligned
     p-op-avrg at row 18.17 col 39.88 colon-aligned
     p-pc-avrg at row 18.17 col 63.88 colon-aligned
     p-pc-op-avrg at row 18.17 col 87.88 colon-aligned
     p-last at row 18.96 col 13.63 colon-aligned
     p-op-last at row 18.96 col 39.63 colon-aligned
     p-pc-last at row 18.96 col 63.63 colon-aligned
     p-pc-op-last at row 18.96 col 87.63 colon-aligned
     p-calc-metod at row 19.75 col 79   colon-aligned no-label
     obj-in-code at row 19.79 col 13.88 colon-aligned
     obj-in-date at row 19.79 col 39.88 colon-aligned
     prev-list.doc-num at row 19.79 col 63.88 colon-aligned
           label "Переоценка"
           view-as text
          size 13 by .67 tooltip "Номер переоценки, из которой была взята старая цена продажи"
     s-old at row 21.46 col 13.75 colon-aligned
     s-new at row 21.46 col 39.75 colon-aligned
     s-new-old at row 21.46 col 63.75 colon-aligned
     pc-prev at row 21.46 col 87.75 colon-aligned
     op-avrg at row 22.21 col 13.75 colon-aligned
     pc-avrg at row 22.21 col 39.75 colon-aligned
     pc-op-avrg at row 22.21 col 63.75 colon-aligned
     op-last at row 23.13 col 13.75 colon-aligned
     pc-last at row 23.13 col 39.75 colon-aligned
     pc-op-last at row 23.13 col 63.75 colon-aligned
     " Информация по строке" view-as text
          size 22 by .67 at row 15.29 col 37.5
          fgcolor 4
     rect-line AT ROW 15.13 COL 1
     rect-tot AT ROW 21.04 COL 1
     " Итоги по переоценке" view-as text
          size 20.63 by .67 at row 20.6 col 37.75
          fgcolor 4
     space(41.24) skip(2.91)
    with view-as dialog-box keep-tab-order
         side-labels no-underline three-d  scrollable
         title "Приказ переоценки".
assign
  frame d-pr-doc:scrollable = false
  br-list   :num-locked-columns in frame d-pr-doc = 5
  b-chg     :popup-menu in frame d-pr-doc         = menu m-chg  :handle
  b-chg     :menu-mouse                                = 1
  b-del     :popup-menu in frame d-pr-doc         = menu m-del  :handle
  b-del     :menu-mouse                                = 1
  .
br-list :set-repositioned-row (5, "always").
run str/pr-listv.p
    (input 'Товар,Учетная,Учет-объект,Учет-резерв,Приходная,Прих-объект,Старая,Новая,Объект,Накладная,Переоценка,Накл-безНДС,Учет-безНДС,Стар-безНДС,Единая,НсП,НсП+накл,Откат_цен,Отсутствует,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U ,
     input 'Не-считать':U,
     output p-list
     ) .
calc-method:list-items in frame d-pr-doc  = p-list .
def var sort-labelbr-list   as character no-undo .
def var sort-clmnbr-list    as handle    no-undo .
def var cur-clmnbr-list     as handle    no-undo .
def var cur-clmn-locbr-list as integer   no-undo .
def var re-querybr-list     as logical   initial no no-undo .
on start-search, ctrl-o of br-list in frame d-pr-doc do:
   run sort-brbr-list
     (input (if available ub.price-list
             then recid(ub.price-list)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-list :
  define input parameter p-recid as recid no-undo .
  if re-querybr-list = no then do:
    assign
       cur-clmnbr-list = br-list:current-column in frame d-pr-doc
    .
    if sort-clmnbr-list <> ? then sort-clmnbr-list:column-fgcolor = 0.
    if cur-clmnbr-list = sort-clmnbr-list then do:
      assign
         sort-labelbr-list = ""
         sort-clmnbr-list = ?
      .
     end.
     else do:
       assign
         sort-labelbr-list = cur-clmnbr-list:label
         sort-clmnbr-list  = cur-clmnbr-list
         sort-clmnbr-list:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-list = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-list:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-list then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-list = cur-clmn-locbr-list + 1
    .
  end.
  case sort-labelbr-list:
        when 'Тип'  then DO:   assign     sort-clmn-name = "if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U.   . END.
        when 'Код'  then DO:   assign     sort-clmn-name = "ub.bar-code.b-code"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by ub.bar-code.b-code.   . END.
        when 'Артикул'  then DO:   assign     sort-clmn-name = "ub.price-list.artic"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by ub.price-list.artic.   . END.
        when 'Название'  then DO:   assign     sort-clmn-name = "if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           ub.goods.gds-name         else            ub.bar-code.part-code  + '  ПН ' + ub.bar-code.in-code       else         '    ' + ub.gds-prt.f-name"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           ub.goods.gds-name         else            ub.bar-code.part-code  + '  ПН ' + ub.bar-code.in-code       else         '    ' + ub.gds-prt.f-name.   . END.
        when 'Новая цена'  then DO:   assign     sort-clmn-name = "ub.price-list.price-sale"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by ub.price-list.price-sale.   . END.
        when 'Старая'  then DO:   assign     sort-clmn-name = "fnc-old-price (buffer ub.price-list)"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by fnc-old-price (buffer ub.price-list).   . END.
        when '%.'  then DO:   assign     sort-clmn-name = "fnc-old-pc  (buffer ub.price-list)"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by fnc-old-pc  (buffer ub.price-list).   . END.
        when 'Исходная'  then DO:   assign     sort-clmn-name = "fnc-arg-price (buffer ub.price-list)"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by fnc-arg-price (buffer ub.price-list).   . END.
        when '%'  then DO:   assign     sort-clmn-name = "fnc-arg-pc (buffer ub.price-list)"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by fnc-arg-pc (buffer ub.price-list).   . END.
        when 'Расчет'  then DO:   assign     sort-clmn-name = "ub.price-list.calc-method"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by ub.price-list.calc-method.   . END.
        when 'Количество'  then DO:   assign     sort-clmn-name = "ub.price-list.doc-qnty"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by ub.price-list.doc-qnty.   . END.
        when 'Изм'  then DO:   assign     sort-clmn-name = "ub.goods.unit-base"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by ub.goods.unit-base.   . END.
        when dor-nal  then DO:   assign     sort-clmn-name = "ub.price-list.road-tax"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by ub.price-list.road-tax.   . END.
        when 'Акциз'  then DO:   assign     sort-clmn-name = "ub.price-list.excise"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by ub.price-list.excise.   . END.
        when 'Н'  then DO:   assign     sort-clmn-name = "fnc-alt-pr (buffer ub.price-list) descending"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by fnc-alt-pr (buffer ub.price-list) descending.   . END.
        when 'Учетная'  then DO:   assign     sort-clmn-name = "fnc-cost (buffer ub.price-list)"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by fnc-cost (buffer ub.price-list).   . END.
        when '%'  then DO:   assign     sort-clmn-name = "fnc-cost-pc (buffer ub.price-list)"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by fnc-cost-pc (buffer ub.price-list).   . END.
        when 'Приходная'  then DO:   assign     sort-clmn-name = "fnc-pr (buffer ub.price-list)"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by fnc-pr (buffer ub.price-list).   . END.
        when '%'  then DO:   assign     sort-clmn-name = "fnc-pr-pc (buffer ub.price-list)"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by fnc-pr-pc (buffer ub.price-list).   . END.
        when '№п/п'  then DO:   assign     sort-clmn-name = "ub.price-list.line-num"   .   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by ub.price-list.line-num.   . END.
    otherwise do:
      assign
        sort-clmn-name = ""
      .
      open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by ub.price-list.artic by ub.gds-prt.node-code .
      if sort-labelbr-list <> "" then do:
        assign
          cur-clmnbr-list:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-list = ?
      .
    end.
  end case.
    if cur-clmn-locbr-list <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-list') then do:
        run ch-clmnbr-list in this-procedure (cur-clmn-locbr-list).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-list to recid p-recid no-error.
    apply "value-changed" to br-list in frame d-pr-doc.
  end.
  apply "entry" to br-list in frame d-pr-doc.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-list:
if cur-clmnbr-list = ? then do:
   open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by ub.price-list.artic by ub.gds-prt.node-code .
end.
else do:
   assign re-querybr-list = yes.
   run sort-brbr-list
     (input (if available ub.price-list
             then recid(ub.price-list)
             else ?
            )
     ).
   assign re-querybr-list = no.
end.
end.
define variable vss-include-info51 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-pr-doc anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-pr-doc. END.
  return no-apply.
end.
define variable vss-include-info52 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame d-pr-doc anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame d-pr-doc. END.
  return no-apply.
end.
define variable vss-include-info53 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ALT-F7 of frame d-pr-doc anywhere do:
  if b-calc :sensitive then DO: apply "CHOOSE":U to b-calc in frame d-pr-doc. END.
  return no-apply.
end.
define variable vss-include-info54 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame d-pr-doc anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame d-pr-doc. END.
  return no-apply.
end.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame d-pr-doc anywhere do:
  if not available ub.goods then
    return no-apply.
  gds-rec = recid (ub.goods).
  run ref/gds-form.w ( input parParentProc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-list in frame d-pr-doc.
  return no-apply.
end.
on SHIFT-F9 of frame d-pr-doc anywhere do:
  if not available ub.goods then
    return no-apply.
  gds-rec = recid (ub.goods).
  run ref/gds-form.w ( input parParentProc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-list in frame d-pr-doc.
  return no-apply.
end.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref56 as character no-undo .
define variable varpgscales-pref56 as character no-undo.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type57 as character no-undo.
varscales-pref56  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref56
  ,output varscales-pref-type57
  ) no-error .
if varscales-pref56 = ? then do:
  assign
  varscales-pref56 = '21,23,25':U.
end.
define variable varpgscales-pref-type57 as character no-undo.
varpgscales-pref56  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref56
  ,output varpgscales-pref-type57
  ) no-error .
if varpgscales-pref56 = ? then do:
  assign
  varpgscales-pref56 = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
on value-changed of a-n-c in frame d-pr-doc do:
  run proc-valchg-a-n-c in this-procedure  no-error.
  return no-apply.
end.
on any-printable of br-list in frame d-pr-doc do:
  run proc-any-printable-br-list in this-procedure   no-error.
  return no-apply.
end.
on backspace of br-list in frame d-pr-doc do:
  run proc-backspace-br-list in this-procedure   no-error.
  return no-apply.
end.
ON return OF loc-code IN FRAME d-pr-doc do:
  run proc-mouse-dbl-click-loc-code in this-procedure   no-error.
  return no-apply.
end.
ON return, Ctrl-J OF loc-name IN FRAME d-pr-doc do:
  run proc-mouse-dbl-click-loc-name in this-procedure   no-error.
  return no-apply.
end.
PROCEDURE proc-valchg-a-n-c:
  case input frame d-pr-doc a-n-c :
    when "art" then do:
      apply "entry" to br-list in frame d-pr-doc.
      hide loc-name loc-code
      in frame d-pr-doc.
      loc-art = "".
    end.
    when "name" then do:
      enable loc-name with frame d-pr-doc.
      disp loc-name with frame d-pr-doc.
      hide loc-art loc-code
      in frame d-pr-doc.
      apply "entry" to loc-name in frame d-pr-doc.
    end.
    when "code"
 or when "DataMatrix" then
    do:
      enable loc-code with frame d-pr-doc.
      disp loc-code with frame d-pr-doc.
      hide loc-art loc-name
      in frame d-pr-doc.
      apply "entry" to loc-code in frame d-pr-doc.
    end.
  end CASE.
END PROCEDURE.
PROCEDURE proc-any-printable-br-list :
  if input frame d-pr-doc a-n-c = "art" then do:
    if last-event:label = " " and
       loc-art = "" then
    return error.
    find first l-price-list where
               l-price-list.doc-num = p-doc.doc-num and l-price-list.artic begins (loc-art + last-event:label)
               no-lock no-error.
    if available l-price-list then do:
      loc-art = loc-art + last-event:label.
      disp loc-art with frame d-pr-doc.
      line-rec = recid (l-price-list).
      reposition br-list to recid line-rec no-error.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-backspace-br-list:
  if input frame d-pr-doc a-n-c = "art" then do:
    if loc-art = "" then
      return error.
    loc-art = substr (loc-art, 1, length (loc-art) - 1).
    find first l-price-list where
               l-price-list.doc-num = p-doc.doc-num and l-price-list.artic begins loc-art
               no-lock.
    disp loc-art with frame d-pr-doc.
    line-rec = recid (l-price-list).
    reposition br-list to recid line-rec no-error.
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
  frame d-pr-doc
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
,input  varscales-pref56
,input  varpgscales-pref56
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
     if varresult eq "prod-bc"
     then
        loc-code:screen-value in frame d-pr-doc = buf_prod-bc.b-str.
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
,input  varscales-pref56
,input  varpgscales-pref56
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
        find first l-price-list where l-price-list.doc-num = p-doc.doc-num and
                  l-price-list.artic = l-goods.artic AND
                  l-price-list.prod-type = l-goods.prod-type AND
                  l-price-list.prod-code = l-goods.prod-code no-lock no-error.
    if available l-price-list then do:
      line-rec = recid (l-price-list).
      reposition br-list to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  end.
  else
    message "Бар-код не найден."
            view-as alert-box error.
  apply "entry" to loc-code in frame d-pr-doc.
END PROCEDURE.
PROCEDURE  proc-mouse-dbl-click-loc-name:
  assign
  frame d-pr-doc
  loc-name.
    if last-event:label = "Ctrl-J" then
      find next l-price-list where l-price-list.doc-num = p-doc.doc-num and
                can-find (ub.goods where ub.goods.artic = l-price-list.artic and
                ub.goods.prod-type = l-price-list.prod-type and
                ub.goods.prod-code = l-price-list.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    else
      find first l-price-list where l-price-list.doc-num = p-doc.doc-num and
                can-find (ub.goods where ub.goods.artic = l-price-list.artic and
                ub.goods.prod-type = l-price-list.prod-type and
                ub.goods.prod-code = l-price-list.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if available l-price-list then do:
      line-rec = recid (l-price-list).
      reposition br-list to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  apply "entry" to loc-name in frame d-pr-doc.
END PROCEDURE.
on value-changed of br-list in frame d-pr-doc do:
if not available ub.price-list or recid (ub.price-list) <> line-rec then do:
    hide loc-art in frame d-pr-doc.
    loc-art = "".
end.
end.
on find of ub.goods do: end.
on find of ub.gds-obj do: end.
on mouse-select-dblclick of br-list in frame d-pr-doc
do:
define variable stp-cycl as logical no-undo .
define variable t-r as recid no-undo .
line-mode = 'ИЗМЕНЕНИЕ':U .
  if avail ub.price-list then do:
     t-r = recid( ub.price-list).
     if calc-method =  'Отсутствует':U then do:
        g#log =  session:SET-WAIT-STATE("") .
        run str/pr-form.w (
                      input  parParentProc ,
                      input  line-mode   ,
                      input  doc-rec    ,
                      input t-r,
                      input increase-pc ,
                      input round-method,
                      input round-base,
                      input calc-method,
                      output stp-cycl ) .
         g#log = br-list:REFRESH( )  in frame d-pr-doc.
         apply "value-changed" to br-list in frame d-pr-doc.
         reposition br-list to recid t-r no-error.
     end.
  end.
end.
on end-error of ub.price-list.price-sale, ub.price-list.road-tax, ub.price-list.excise in browse br-list do:
  display fnc-alt-pr (buffer ub.price-list)  @ tt-col     column-label 'Н' format "*/" if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl   column-label 'Тип'  format "x(3)" ub.bar-code.b-code                column-label 'Код'  format ">>>>>>>>>>>>>>>>9" ub.price-list.artic                column-label 'Артикул'  format "x(16)" if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           ub.goods.gds-name         else            ub.bar-code.part-code  + '  ПН ' + ub.bar-code.in-code       else         '    ' + ub.gds-prt.f-name   @ calc-name  column-label 'Название'  format "x(47)" ub.price-list.price-sale                column-label 'Новая цена'  fnc-old-price (buffer ub.price-list)   @ old-price  column-label 'Старая'  fnc-old-pc  (buffer ub.price-list)   @ old-pc     column-label '%.'  format "->,>>9.<<" fnc-arg-price (buffer ub.price-list)   @ arg-price  column-label 'Исходная'  fnc-arg-pc (buffer ub.price-list)   @ arg-pc     column-label '%'  format "->,>>9.<<" fnc-cost (buffer ub.price-list)  @ f-cost     column-label 'Учетная' fnc-cost-pc (buffer ub.price-list)  @ f-cost-pc  column-label '%' format "->,>>9.<<" fnc-pr (buffer ub.price-list)  @ f-pr       column-label 'Приходная' fnc-pr-pc (buffer ub.price-list)  @ f-pr-pc    column-label '%' format "->,>>9.<<" ub.price-list.calc-method               column-label 'Расчет' format "x(20)" ub.price-list.doc-qnty               column-label 'Количество' format "->>,>>>,>>9.<<<" ub.goods.unit-base               column-label 'Изм' format "x(3)" ub.price-list.road-tax ub.price-list.excise               column-label 'Акциз' ub.price-list.line-num               column-label '№п/п' with browse br-list no-error .
  return no-apply.
end.
on row-display of br-list do:
  if sort-clmn-name <> "calc-dtl"  then
    if ub.gds-prt.upper-code = ub.goods.prt-root then
      if ub.bar-code.in-code = '' then
        calc-dtl :fgcolor in browse br-list = black_color.
      else
        calc-dtl :fgcolor in browse br-list = blue_color.
    else
      calc-dtl :fgcolor in browse br-list = dark_green_color.
end.
on entry of br-list in frame d-pr-doc do:
  run value-changed-br-list in this-procedure .
end.
on value-changed of br-list in frame d-pr-doc do:
  run value-changed-br-list in this-procedure .
end.
on leave of ub.price-list.price-sale in browse br-list or
   leave of ub.price-list.road-tax   in browse br-list or
   leave of ub.price-list.excise     in browse br-list do:
  if not available ub.price-list then
    return.
  if decimal  (ub.price-list.price-sale :screen-value in browse br-list) <> round(ub.price-list.price-sale,2)   or
     decimal  (ub.price-list.road-tax   :screen-value in browse br-list) <> round(ub.price-list.road-tax,2)    or
     decimal  (ub.price-list.excise     :screen-value in browse br-list) <> round(ub.price-list.excise,2) then do :
    g#log = yes.
    message "Строка изменена. Записать это изменение?"
            view-as alert-box question buttons yes-no update g#log.
    if g#log then
      run upd-br-field in this-procedure .
  end.
  display fnc-alt-pr (buffer ub.price-list)  @ tt-col     column-label 'Н' format "*/" if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl   column-label 'Тип'  format "x(3)" ub.bar-code.b-code                column-label 'Код'  format ">>>>>>>>>>>>>>>>9" ub.price-list.artic                column-label 'Артикул'  format "x(16)" if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           ub.goods.gds-name         else            ub.bar-code.part-code  + '  ПН ' + ub.bar-code.in-code       else         '    ' + ub.gds-prt.f-name   @ calc-name  column-label 'Название'  format "x(47)" ub.price-list.price-sale                column-label 'Новая цена'  fnc-old-price (buffer ub.price-list)   @ old-price  column-label 'Старая'  fnc-old-pc  (buffer ub.price-list)   @ old-pc     column-label '%.'  format "->,>>9.<<" fnc-arg-price (buffer ub.price-list)   @ arg-price  column-label 'Исходная'  fnc-arg-pc (buffer ub.price-list)   @ arg-pc     column-label '%'  format "->,>>9.<<" fnc-cost (buffer ub.price-list)  @ f-cost     column-label 'Учетная' fnc-cost-pc (buffer ub.price-list)  @ f-cost-pc  column-label '%' format "->,>>9.<<" fnc-pr (buffer ub.price-list)  @ f-pr       column-label 'Приходная' fnc-pr-pc (buffer ub.price-list)  @ f-pr-pc    column-label '%' format "->,>>9.<<" ub.price-list.calc-method               column-label 'Расчет' format "x(20)" ub.price-list.doc-qnty               column-label 'Количество' format "->>,>>>,>>9.<<<" ub.goods.unit-base               column-label 'Изм' format "x(3)" ub.price-list.road-tax ub.price-list.excise               column-label 'Акциз' ub.price-list.line-num               column-label '№п/п' with browse br-list no-error .
  apply "value-changed" to br-list in frame d-pr-doc.
end.
on ctrl-o of br-list in frame d-pr-doc
or  ctrl-j of br-list in frame d-pr-doc
do:
      if b-chg :sensitive then
      if input frame d-pr-doc increase-pc < - 100 then do:
        message "Наценка не может быть меньше - 100 % !"
                view-as alert-box error.
        apply "entry" to br-list in frame d-pr-doc.
        return no-apply.
      end.
      if not available ub.price-list then do:
        message "Неправильно выбрана строка."
                view-as alert-box error.
        return no-apply.
      end.
      line-rec = recid (ub.price-list).
      run calc-pr-list in this-procedure
                       (input ub.price-list.b-code,
                        input p-doc.doc-num,
                        input calc-method,
                        input increase-pc,
                        input round-method,
                        input round-base,
                        input ? ,
                        input ? ,
                        input ? ,
                        input ? ,
                        output line-rec) no-error.
      if error-status:error then
        next.
      if line-rec = recid (ub.price-list) then do:
        display fnc-alt-pr (buffer ub.price-list)  @ tt-col     column-label 'Н' format "*/" if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl   column-label 'Тип'  format "x(3)" ub.bar-code.b-code                column-label 'Код'  format ">>>>>>>>>>>>>>>>9" ub.price-list.artic                column-label 'Артикул'  format "x(16)" if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           ub.goods.gds-name         else            ub.bar-code.part-code  + '  ПН ' + ub.bar-code.in-code       else         '    ' + ub.gds-prt.f-name   @ calc-name  column-label 'Название'  format "x(47)" ub.price-list.price-sale                column-label 'Новая цена'  fnc-old-price (buffer ub.price-list)   @ old-price  column-label 'Старая'  fnc-old-pc  (buffer ub.price-list)   @ old-pc     column-label '%.'  format "->,>>9.<<" fnc-arg-price (buffer ub.price-list)   @ arg-price  column-label 'Исходная'  fnc-arg-pc (buffer ub.price-list)   @ arg-pc     column-label '%'  format "->,>>9.<<" fnc-cost (buffer ub.price-list)  @ f-cost     column-label 'Учетная' fnc-cost-pc (buffer ub.price-list)  @ f-cost-pc  column-label '%' format "->,>>9.<<" fnc-pr (buffer ub.price-list)  @ f-pr       column-label 'Приходная' fnc-pr-pc (buffer ub.price-list)  @ f-pr-pc    column-label '%' format "->,>>9.<<" ub.price-list.calc-method               column-label 'Расчет' format "x(20)" ub.price-list.doc-qnty               column-label 'Количество' format "->>,>>>,>>9.<<<" ub.goods.unit-base               column-label 'Изм' format "x(3)" ub.price-list.road-tax ub.price-list.excise               column-label 'Акциз' ub.price-list.line-num               column-label '№п/п' with browse br-list no-error .
        end.
      else do:
        run open-br in this-procedure .
        run upd-br-field in this-procedure .
      end.
        g#log = br-list:select-next-row ().
        run upd-disp-tot in this-procedure ("clear").
end.
on return of ub.price-list.price-sale in browse br-list or
   return of ub.price-list.road-tax   in browse br-list or
   return of ub.price-list.excise     in browse br-list do:
  if decimal  (ub.price-list.price-sale :screen-value in browse br-list) <> ub.price-list.price-sale or
     decimal  (ub.price-list.road-tax   :screen-value in browse br-list) <> ub.price-list.road-tax or
     decimal  (ub.price-list.excise     :screen-value in browse br-list) <> ub.price-list.excise then
    run upd-br-field in this-procedure .
  display fnc-alt-pr (buffer ub.price-list)  @ tt-col     column-label 'Н' format "*/" if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl   column-label 'Тип'  format "x(3)" ub.bar-code.b-code                column-label 'Код'  format ">>>>>>>>>>>>>>>>9" ub.price-list.artic                column-label 'Артикул'  format "x(16)" if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           ub.goods.gds-name         else            ub.bar-code.part-code  + '  ПН ' + ub.bar-code.in-code       else         '    ' + ub.gds-prt.f-name   @ calc-name  column-label 'Название'  format "x(47)" ub.price-list.price-sale                column-label 'Новая цена'  fnc-old-price (buffer ub.price-list)   @ old-price  column-label 'Старая'  fnc-old-pc  (buffer ub.price-list)   @ old-pc     column-label '%.'  format "->,>>9.<<" fnc-arg-price (buffer ub.price-list)   @ arg-price  column-label 'Исходная'  fnc-arg-pc (buffer ub.price-list)   @ arg-pc     column-label '%'  format "->,>>9.<<" fnc-cost (buffer ub.price-list)  @ f-cost     column-label 'Учетная' fnc-cost-pc (buffer ub.price-list)  @ f-cost-pc  column-label '%' format "->,>>9.<<" fnc-pr (buffer ub.price-list)  @ f-pr       column-label 'Приходная' fnc-pr-pc (buffer ub.price-list)  @ f-pr-pc    column-label '%' format "->,>>9.<<" ub.price-list.calc-method               column-label 'Расчет' format "x(20)" ub.price-list.doc-qnty               column-label 'Количество' format "->>,>>>,>>9.<<<" ub.goods.unit-base               column-label 'Изм' format "x(3)" ub.price-list.road-tax ub.price-list.excise               column-label 'Акциз' ub.price-list.line-num               column-label '№п/п' with browse br-list no-error .
  apply "value-changed" to br-list in frame d-pr-doc.
end.
on return of increase-pc, round-base, doc-code,common-price, copy-type, copy-code in frame d-pr-doc do:
  apply "entry" to br-list in frame d-pr-doc.
  return no-apply.
end.
on end-error, stop of frame d-pr-doc do:
  apply "choose" to b-exit in frame d-pr-doc.
  return no-apply.
end.
on choose of b-arch in frame d-pr-doc do:
define variable vss-include-info58 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
run str/doc-prc.w .
end.
on choose of b-quest in frame d-pr-doc do:
  run run-help in this-procedure .
end.
on choose of b-calc in frame d-pr-doc do:
define variable vss-include-info59 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
run str/pr-tot.p ( input p-doc.doc-num ) no-error.
run upd-disp-tot in this-procedure ( "disp" ).
end.
on choose of b-exit in frame d-pr-doc do:
define variable vss-include-info60 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
   define variable p-err as logical no-undo .
   if doc-mode <> 'ПРОСМОТР':U then do:
     run str/pr-tot.p ( input p-doc.doc-num ) no-error.
     run upd-disp-tot in this-procedure ("disp").
   end.
   run ch-b-exit in this-procedure (output p-err) .
   if p-err = true then return no-apply.
end.
on choose of b-notes in frame d-pr-doc do:
define variable vss-include-info61 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
notes = p-doc.ps.
if doc-mode = 'ПРОСМОТР':U then do:
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
  if return-value = 'false':u
  then do:
    return .
  end.
  if p-doc.PS <> notes then do:
    do transaction on error undo, return no-apply :
      find p-doc where recid (p-doc) = doc-rec exclusive.
      assign
        p-doc.PS = notes.
    end.
  end.
end.
end.
on choose of b-history in frame d-pr-doc do:
define variable vss-include-info62 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
run str/pr-cdoc.w ( parParentProc, p-doc.host-code, p-doc.doc-num ).
end.
on choose of b-add do:
run pro-list in this-procedure ("b-add").
run add-price-line in this-procedure .
doc-rec = recid(p-doc) .
run open-br in this-procedure .
end.
on choose of b-special do:
define variable vss-include-info63 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-special :type in frame d-pr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-pr-doc skip
    "Тип" self :type in frame d-pr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-special in frame d-pr-doc .
  if focus :handle <> b-special :handle in frame d-pr-doc then do:
    return no-apply .
  end.
end.
run add-spec-proc in this-procedure ("gds-all") no-error.
doc-rec = recid(p-doc) .
if error-status :error then
  return no-apply.
end.
on choose of menu-item m-lst-chg do:
define variable vss-include-info64 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-chg :type in frame d-pr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-pr-doc skip
    "Тип" self :type in frame d-pr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-chg in frame d-pr-doc .
  if focus :handle <> b-chg :handle in frame d-pr-doc then do:
    return no-apply .
  end.
end.
if input frame d-pr-doc increase-pc < - 100 then do:
  message "Наценка не может быть меньше - 100 % !"
          view-as alert-box error.
  apply "entry" to br-list in frame d-pr-doc.
  return no-apply.
end.
if not available ub.price-list then do:
  message "Задайте товары клавишей 'ДОБАВИТЬ' ! "
          view-as alert-box error.
  return no-apply.
end.
run pro-list in this-procedure ("b-chg").
line-rec = ?.
doc-mode = 'ИЗМЕНЕНИЕ':U.
run open-br in this-procedure .
run upd-disp-tot in this-procedure ("clear").
end.
on choose of menu-item m-one-chg do:
define variable vss-include-info65 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-chg :type in frame d-pr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-pr-doc skip
    "Тип" self :type in frame d-pr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-chg in frame d-pr-doc .
  if focus :handle <> b-chg :handle in frame d-pr-doc then do:
    return no-apply .
  end.
end.
if input frame d-pr-doc increase-pc < - 100 then do:
  message "Наценка не может быть меньше - 100 % !"
          view-as alert-box error.
  apply "entry" to br-list in frame d-pr-doc.
  return no-apply.
end.
if not available ub.price-list then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
line-rec = recid (ub.price-list).
define variable p-line-mode as character no-undo .
p-line-mode = line-mode .
line-mode = "calc":u.
run calc-pr-list in this-procedure
                 (input ub.price-list.b-code,
                  input p-doc.doc-num,
                  input calc-method,
                  input increase-pc,
                  input round-method,
                  input round-base,
                  input ?,
                  input ?,
                  input ?,
                  input ?,
                  output line-rec) no-error.
if error-status:error then do:
   line-mode = p-line-mode.
   next.
   end.
line-mode = p-line-mode.
if line-rec = recid (ub.price-list) then do:
  display fnc-alt-pr (buffer ub.price-list)  @ tt-col     column-label 'Н' format "*/" if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl   column-label 'Тип'  format "x(3)" ub.bar-code.b-code                column-label 'Код'  format ">>>>>>>>>>>>>>>>9" ub.price-list.artic                column-label 'Артикул'  format "x(16)" if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           ub.goods.gds-name         else            ub.bar-code.part-code  + '  ПН ' + ub.bar-code.in-code       else         '    ' + ub.gds-prt.f-name   @ calc-name  column-label 'Название'  format "x(47)" ub.price-list.price-sale                column-label 'Новая цена'  fnc-old-price (buffer ub.price-list)   @ old-price  column-label 'Старая'  fnc-old-pc  (buffer ub.price-list)   @ old-pc     column-label '%.'  format "->,>>9.<<" fnc-arg-price (buffer ub.price-list)   @ arg-price  column-label 'Исходная'  fnc-arg-pc (buffer ub.price-list)   @ arg-pc     column-label '%'  format "->,>>9.<<" fnc-cost (buffer ub.price-list)  @ f-cost     column-label 'Учетная' fnc-cost-pc (buffer ub.price-list)  @ f-cost-pc  column-label '%' format "->,>>9.<<" fnc-pr (buffer ub.price-list)  @ f-pr       column-label 'Приходная' fnc-pr-pc (buffer ub.price-list)  @ f-pr-pc    column-label '%' format "->,>>9.<<" ub.price-list.calc-method               column-label 'Расчет' format "x(20)" ub.price-list.doc-qnty               column-label 'Количество' format "->>,>>>,>>9.<<<" ub.goods.unit-base               column-label 'Изм' format "x(3)" ub.price-list.road-tax ub.price-list.excise               column-label 'Акциз' ub.price-list.line-num               column-label '№п/п' with browse br-list no-error .
  end.
else do:
  run open-br in this-procedure .
  run upd-br-field in this-procedure .
  end.
run upd-disp-tot in this-procedure ("clear").
apply "value-changed" to br-list in frame d-pr-doc .
end.
on choose of menu-item m-lst-del do:
define variable vss-include-info66 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-del :type in frame d-pr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-pr-doc skip
    "Тип" self :type in frame d-pr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-del in frame d-pr-doc .
  if focus :handle <> b-del :handle in frame d-pr-doc then do:
    return no-apply .
  end.
end.
run pro-list in this-procedure ("b-del").
line-rec = ?.
run upd-disp-tot in this-procedure ("clear").
doc-mode = 'ИЗМЕНЕНИЕ':U.
run open-br in this-procedure .
end.
on choose of menu-item m-one-del do:
define variable vss-include-info67 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-del :type in frame d-pr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-pr-doc skip
    "Тип" self :type in frame d-pr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-del in frame d-pr-doc .
  if focus :handle <> b-del :handle in frame d-pr-doc then do:
    return no-apply .
  end.
end.
if not available ub.price-list then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
assign
  line-rec = recid (ub.price-list)
  g#log = no
  .
message "Удалить строку документа" ub.goods.artic ub.goods.gds-name "?   Вы уверены?"
        view-as alert-box question buttons ok-cancel update g#log.
if not g#log then
  return no-apply.
get next br-list.
if available ub.price-list then
  rep-rec = recid (ub.price-list).
else do:
  reposition br-list to recid line-rec no-error.
  get prev br-list.
  if available ub.price-list then
    rep-rec = recid (ub.price-list).
end.
reposition br-list to recid line-rec no-error.
find ub.price-list where recid (ub.price-list) = line-rec.
find first price-list-tt where
          price-list-tt.artic      = ub.price-list.artic
      and price-list-tt.doc-num    = ub.price-list.doc-num
      and price-list-tt.prod-code  = ub.price-list.prod-code
      and price-list-tt.prod-type  = ub.price-list.prod-type
      and price-list-tt.prod-type  = ub.price-list.prod-type
      no-error .
 if string(if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U ) = 'ПРИЗНАК':U then do :
     if not avail price-list-tt then  return no-apply.
     message "При удаление из переоценки спеццены признака  удаляются.  Цена товара"
     ub.goods.gds-name if ub.gds-prt.upper-code = ub.goods.prt-root then         if ub.bar-code.in-code = '' then           ub.goods.gds-name         else            ub.bar-code.part-code  + '  ПН ' + ub.bar-code.in-code       else         '    ' + ub.gds-prt.f-name  " = " price-list-tt.price-sale
     skip
     "Вы уверены?"
    view-as alert-box question buttons ok-cancel update g#log.
    if not g#log then  return no-apply.
end.
run del-pr-list in this-procedure ( input ub.price-list.b-code,
                   input p-doc.doc-num,
                   input round-method,
                   input round-base) no-error.
if error-status :error then
  return no-apply.
line-rec = rep-rec.
run upd-disp-tot in this-procedure ("clear").
doc-mode = 'ИЗМЕНЕНИЕ':U.
get next br-list .
if available ub.price-list then   g#log = br-list:select-next-row () in frame d-pr-doc.
g#log = br-list:REFRESH( )  in frame d-pr-doc.
end.
on choose of b-alt do:
define variable vss-include-info68 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-alt :type in frame d-pr-doc
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-pr-doc skip
    "Тип" self :type in frame d-pr-doc skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-alt in frame d-pr-doc .
  if focus :handle <> b-alt :handle in frame d-pr-doc then do:
    return no-apply .
  end.
end.
if not available ub.price-list then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
doc-rec = recid(p-doc) .
if ub.price-list.main-price = true then
   run str/pr-alt.w (
              input parParentProc ,
              input doc-rec ,
              input doc-mode ,
              input "code",
              input ub.bar-code.b-code,
              input-output round-method,
              input-output round-base).
else
  run str/pr-alt.w (
              input parParentProc ,
              input doc-rec ,
              input doc-mode ,
              input "scl-gds",
              input ub.bar-code.b-code,
              input-output round-method,
              input-output round-base).
doc-rec = recid(p-doc) .
run ui-on in this-procedure .
end.
on choose of r-copy in frame d-pr-doc do:
define variable vss-include-info69 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
define variable loc-ref-list as character no-undo .
case calc-method:
  when 'Объект':U then do:
    run ref/cli-all.w ( parParentProc
                   , "b-sel"
                   , ?
                   , ?
                   , ?
                   , ?
                   , ?
                   , ?
                   , output ref-list) .
    apply "entry" to copy-type in frame d-pr-doc.
    if ref-list = "" then
      return no-apply.
    ref-rec = integer (ref-list).
    find ub.clients where recid (ub.clients) = ref-rec no-lock.
    if not ( ub.clients.obj-type = 'скл':U or
             ub.clients.obj-type = 'маг':U ) then do:
      message "Объектом для копирования цены может быть только склад или магазин."
              view-as alert-box error.
      return no-apply.
    end.
    assign
      copy-code = ub.clients.obj-code
      copy-type = ub.clients.obj-type
      .
    display copy-type copy-code with frame d-pr-doc.
  end.
  when 'Накладная':U  or
  when 'НсП+накл':U or
  when 'Накл-безНДС':U
       then do:
    assign
      doc-rec = ?  .
    run str/all-docs.w (input parparentproc, input ?, input ?, input ?, input 'работа':U, input ?, input ?, input ?, input ?, input "b-sel":u, input ?, input ?, input ?, output loc-ref-list).
    find ub.trn-doc where recid (ub.trn-doc) = int(loc-ref-list) no-lock no-error .
    g#stat = p-doc.status_ .
    if not available ub.trn-doc then do:
      message "Накладная не выбрана."
              view-as alert-box error.
      return no-apply.
    end.
    doc-code = ub.trn-doc.doc-code.
    display doc-code with frame d-pr-doc.
  end.
  when 'Единая':U then do:
    display common-price with frame d-pr-doc.
  end.
  when 'Переоценка':U then do:
    run str/pr-docs.w (
        input parParentProc ,
        input "b-sel":U ,
        input 'работа':U ,
        input "" ,
        input v-cntxt-obj-type ,
        input v-cntxt-obj-code ,
        input "" ,
        output loc-ref-list ).
    doc-rec = integer ( loc-ref-list ) .
    find ub.price-doc where recid (ub.price-doc) = doc-rec no-lock no-error.
    if not available ub.price-doc then do:
      message "Переоценка не выбрана."
              view-as alert-box error.
      return no-apply.
    end.
    doc-code = ub.price-doc.doc-num.
    display doc-code with frame d-pr-doc.
  end.
end case.
end.
on value-changed of calc-method in frame d-pr-doc do:
assign
  calc-method
  doc-code = ""
  .
run ui-on in this-procedure .
end.
on leave of increase-pc in frame d-pr-doc do:
assign
  increase-pc.
end.
on value-changed of round-method in frame d-pr-doc do:
assign
  round-method.
run ui-on in this-procedure .
end.
on leave of copy-type in frame d-pr-doc do:
define variable v-type as character no-undo .
    v-type =  input frame d-pr-doc copy-type .
    if (v-type = 'скл':U or v-type = 'маг':U ) then
      assign copy-type.
    else
      message "Объектом для копирования цены может быть только склад или магазин."
              view-as alert-box error.
    disp copy-type with frame d-pr-doc.
end.
on leave of copy-code in frame d-pr-doc do:
if can-find (ub.clients where ub.clients.obj-type = copy-type
                       and ub.clients.obj-code = input frame d-pr-doc copy-code no-lock) then
  assign
    copy-code.
else
  message "Нет такого объекта!"
          view-as alert-box error.
disp copy-code with frame d-pr-doc.
end.
on leave of doc-code in frame d-pr-doc do:
if calc-method = 'Накладная':U or
   calc-method = 'НсП+накл':U or
   calc-method = 'Накл-безНДС':U
  then do:
  find ub.trn-doc where ub.trn-doc.doc-code = input frame d-pr-doc doc-code no-lock no-error.
  g#log = available ub.trn-doc.
end.
if calc-method = 'Переоценка':U then do:
  find ub.price-doc where ub.price-doc.doc-num = input frame d-pr-doc doc-code no-lock no-error.
  g#log = available ub.price-doc.
end.
if g#log then
  assign doc-code.
else
  if input doc-code <> "" then
    message "Нет такого документа!"
            view-as alert-box error.
disp doc-code with frame d-pr-doc.
end.
on leave of round-base in frame d-pr-doc do:
if input frame d-pr-doc round-base = 0 then do:
  if input frame d-pr-doc round-method = 'Произвольно':U then
    message "Такое округление невозможно - деление на 0."
            view-as alert-box error.
  else
    message "Пересчет по нулевому коэффициенту невозможен - получится 0."
            view-as alert-box error.
end.
else
  assign
    round-base.
disp round-base with frame d-pr-doc.
end.
on leave of common-price in frame d-pr-doc do:
   assign common-price.
disp common-price with frame d-pr-doc.
end.
ON CHOOSE OF b-next IN FRAME d-pr-doc
DO:
if valid-handle (br-handle) then do:
  g#log = br-handle:select-next-row().
  if not g#log then message "Это последний документ списка.".
end.
doc-rec = recid (p-doc).
next-prev = yes.
END.
ON CHOOSE OF b-prev IN FRAME d-pr-doc
DO:
if valid-handle (br-handle) then do:
  g#log = br-handle:select-prev-row().
  if not g#log then message "Это первый документ списка.".
end.
doc-rec = recid (p-doc).
next-prev = yes.
END.
if valid-handle(active-window) and frame d-pr-doc:parent eq ? then
  frame d-pr-doc:parent = active-window.
on window-close of frame d-pr-doc apply "end-error":u to self.
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-pr-doc
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
on choose of b-help in frame d-pr-doc
do:
  apply "help":u to frame d-pr-doc .
end.
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-pr-doc:width - 0.3
                fh            = frame d-pr-doc:first-child
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
next-prev = yes.
n-p:
do while next-prev :
main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block:
  run ver-conf in this-procedure no-error .
  run mode-on in this-procedure no-error.
  if error-status:error    then do: undo, return error. end.
  if doc-mode <> 'ПРОСМОТР':U then do:
     line-rec = ?.
     text-i = "Исходная" .
     enable b-quest with frame d-pr-doc .
     display text-i with frame d-pr-doc .
     end.
  hide b-quest in frame d-pr-doc .
  run open-br in this-procedure .
  run ui-on in this-procedure .
  run cr-button in this-procedure .
  run tax-name in this-procedure ( input 'rdt':U, output  dor-nal) .
  assign ub.price-list.road-tax :label = dor-nal .
   calc-name:RESIZABLE  in browse br-list  = true .
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-list as INT EXTENT 15 no-undo.
DEF VAR varmvibr-list       as INT no-undo.
DEF VAR varmvjbr-list       as INT no-undo.
DEF VAR varmvkbr-list       as INT no-undo.
DEF VAR varmvlbr-list       as INT no-undo.
DEF VAR move-elementbr-list as INT no-undo.
def var jjbr-list           as int no-undo.
do varmvibr-list = 1 to EXTENT(cur-clmn-numbr-list):
  ASSIGN cur-clmn-numbr-list[varmvibr-list] = varmvibr-list.
END.
RUN start-mv-clmnbr-list.
PROCEDURE start-mv-clmnbr-list:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-list do:
  RUN re-move-clmnbr-list ( 6, 15).
END.
ON ctrl-cursor-left OF BROWSE br-list do:
  RUN re-move-clmnbr-list (15, 6).
END.
PROCEDURE re-move-clmnbr-list:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-list = 1 TO EXTENT(cur-clmn-numbr-list):
    if cur-clmn-numbr-list[varmvibr-list] = source-column THEN cur-clmn-numbr-list[varmvibr-list] = -1.
  END.
  if br-list:MOVE-COLUMN(source-column, target-column) IN FRAME d-pr-doc then.
  if source-column > target-column THEN
  DO varmvjbr-list = source-column - 1 to target-column BY -1:
    DO varmvibr-list = 1 TO EXTENT(cur-clmn-numbr-list):
        if cur-clmn-numbr-list[varmvibr-list] = varmvjbr-list THEN DO:
          cur-clmn-numbr-list[varmvibr-list] = cur-clmn-numbr-list[varmvibr-list] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-list = source-column + 1 to target-column:
    DO varmvibr-list = 1 TO EXTENT(cur-clmn-numbr-list):
      if cur-clmn-numbr-list[varmvibr-list] = varmvjbr-list THEN DO:
        cur-clmn-numbr-list[varmvibr-list] = cur-clmn-numbr-list[varmvibr-list] - 1.
      END.
    END.
  END.
  DO varmvibr-list = 1 TO EXTENT(cur-clmn-numbr-list):
    if cur-clmn-numbr-list[varmvibr-list] = -1 THEN cur-clmn-numbr-list[varmvibr-list] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-list:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 6 then do:
    return .
  end.
  DO varmvibr-list = 1 TO EXTENT(cur-clmn-numbr-list):
    if cur-clmn-numbr-list[varmvibr-list] = cur-clmn-loc THEN move-elementbr-list = varmvibr-list.
  END.
  RUN re-move-clmnbr-list (cur-clmn-loc, 6).
        if CAN-DO("7,8", STRING(move-elementbr-list)) THEN DO:
          ASSIGN varmvkbr-list = 6.
          DO varmvlbr-list = 1 to NUM-ENTRIES("7,8"):
              if move-elementbr-list = INTEGER(ENTRY (varmvlbr-list,"7,8")) THEN NEXT.
              varmvkbr-list = varmvkbr-list + 1.
              RUN re-move-clmnbr-list (cur-clmn-numbr-list[INTEGER(ENTRY(varmvlbr-list,"7,8"))], varmvkbr-list).
          END.
        END.
        if CAN-DO("9,10", STRING(move-elementbr-list)) THEN DO:
          ASSIGN varmvkbr-list = 6.
          DO varmvlbr-list = 1 to NUM-ENTRIES("9,10"):
              if move-elementbr-list = INTEGER(ENTRY (varmvlbr-list,"9,10")) THEN NEXT.
              varmvkbr-list = varmvkbr-list + 1.
              RUN re-move-clmnbr-list (cur-clmn-numbr-list[INTEGER(ENTRY(varmvlbr-list,"9,10"))], varmvkbr-list).
          END.
        END.
        if CAN-DO("11,12", STRING(move-elementbr-list)) THEN DO:
          ASSIGN varmvkbr-list = 6.
          DO varmvlbr-list = 1 to NUM-ENTRIES("11,12"):
              if move-elementbr-list = INTEGER(ENTRY (varmvlbr-list,"11,12")) THEN NEXT.
              varmvkbr-list = varmvkbr-list + 1.
              RUN re-move-clmnbr-list (cur-clmn-numbr-list[INTEGER(ENTRY(varmvlbr-list,"11,12"))], varmvkbr-list).
          END.
        END.
        if CAN-DO("13,14", STRING(move-elementbr-list)) THEN DO:
          ASSIGN varmvkbr-list = 6.
          DO varmvlbr-list = 1 to NUM-ENTRIES("13,14"):
              if move-elementbr-list = INTEGER(ENTRY (varmvlbr-list,"13,14")) THEN NEXT.
              varmvkbr-list = varmvkbr-list + 1.
              RUN re-move-clmnbr-list (cur-clmn-numbr-list[INTEGER(ENTRY(varmvlbr-list,"13,14"))], varmvkbr-list).
          END.
        END.
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-list:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-list = 6 to EXTENT(cur-clmn-numbr-list):
    RUN re-move-clmnbr-list (cur-clmn-numbr-list[varmvlbr-list], varmvlbr-list).
  END.
  RUN start-mv-clmnbr-list.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
    wait-for go of frame d-pr-doc focus br-list.
end.
end.
run disable_ui in this-procedure .
FUNCTION fnc-base-code RETURN integer (local-bc as integer).
define variable local-base-code like ub.bar-code.b-code no-undo.
run prc-base-code in this-procedure ( input local-bc, output local-base-code ).
return (local-base-code).
END FUNCTION.
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      if available ub.trn-doc then do:
        if ub.trn-doc.doc-type = 'при':U and
         ( ub.trn-doc.ext-doc-type = 'ie':U  ) then do:
          find ub.doc-line where ub.doc-line.doc-code = doc-code
                          and ub.doc-line.artic     = buf-price-list.artic
                          and ub.doc-line.prod-type = buf-price-list.prod-type
                          and ub.doc-line.prod-code = buf-price-list.prod-code no-lock no-error.
          if available ub.doc-line then DO:
              run str/gdsnovat.p
                 ('Накл-безНДС':U,
                  buf-price-list.obj-type          ,
                  buf-price-list.obj-code          ,
                  buf-price-doc.host-code         ,
                  buf-price-list.artic             ,
                  buf-price-list.prod-type         ,
                  buf-price-list.prod-code         ,
                  loc-grp-increase-pc                   ,
                  doc-code              ,
                  input p-doc-price-rubl-novat   ,
                  input p-doc-price-base-novat   ,
                  output cost-base      ,
                  output cost-rubl      ,
                  output v-price-base   ,
                  output v-price-rubl   ,
                  output cur-rt-base    ,
                  output cur-rt-rubl   )
                  .
              assign
                cur-rt =  if var-pr-r-b = "rubl" then cur-rt-rubl else cur-rt-base
                buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then  ub.doc-line.price-rubl  else ub.doc-line.price-base
                buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then  v-price-rubl         else  v-price-base
                buf-price-list.road-tax    = cur-rt
                tt-price-sale   =  if var-pr-r-b = "rubl" then  v-price-rubl         else  v-price-base
                .
              End.
          else
            message "Нет строки в накладной :" doc-code "для товара :" buf-price-list.artic buf-goods.gds-name
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
        end.
        else do:
          find ub.doc-line where ub.doc-line.doc-code = doc-code
                          and ub.doc-line.artic     = buf-price-list.artic
                          and ub.doc-line.prod-type = buf-price-list.prod-type
                          and ub.doc-line.prod-code = buf-price-list.prod-code no-lock no-error.
          if available ub.doc-line then DO:
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
              assign
                cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                buf-price-list.road-tax    = cur-rt
                tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                .
              End.
          else
            message "Нет строки в накладной :" doc-code "для товара :" buf-price-list.artic buf-goods.gds-name
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
        end.
      end.
      else
        message "Не прочитана накладная с номером" doc-code
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
    end.
  when 'Откат_цен':U then do:
    run str/gdsnovat.p
      ( 'Откат_цен':U,
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
        output cur-rt-rubl
        ).
      assign
        cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
        buf-price-list.calc-method = 'Откат_цен':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        buf-price-list.road-tax    = cur-rt
        tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
      .
  end.
    when 'Стар-безНДС':U then do:
      run str/gdsnovat.p ( 'Стар-безНДС':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          loc-grp-increase-pc,
          "" ,
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
          buf-price-list.calc-method = 'Стар-безНДС':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
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
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    when 'Старая':U then do:
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      if cur-pr = ? then
        message "Нет Акта переоценки для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет от старой цены продажи невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      else
        assign
          buf-price-list.calc-method = 'Старая':U
          buf-price-list.price-calc  = cur-pr
          buf-price-list.road-tax    = cur-rt
          buf-price-list.excise      = cur-ex
          buf-price-list.price-sale  = cur-pr * (1 + loc-grp-increase-pc / 100)
          tt-price-sale  = cur-pr * (1 + loc-grp-increase-pc / 100)
          .
    end.
    when 'Объект':U then do:
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  copy-type
  ,input  copy-code
  ,input  buf-price-list.b-code
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  )  .
      if cur-pr = ? then
        message "Нет Акта переоценки для товара :" buf-price-list.artic buf-goods.gds-name
                "по" input frame d-pr-doc copy-type
                input frame d-pr-doc copy-code "расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      else
        assign
          buf-price-list.calc-method = 'Объект':U + " " + copy-type + " " + string (copy-code, "99999")
          buf-price-list.price-calc  = cur-pr
          buf-price-list.road-tax    = cur-rt
          buf-price-list.excise      = cur-ex
          buf-price-list.price-sale  = cur-pr * (1 + loc-grp-increase-pc / 100)
          tt-price-sale  = cur-pr * (1 + loc-grp-increase-pc / 100)
          .
    end.
    when 'Накладная':U then do:
        run str/pr-wbil.p
        ( input "pr-doc"              ,
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
        ( input "pr-doc"                ,
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
    when 'Переоценка':U then do:
      find prev-list where
           prev-list.b-code     = buf-price-list.b-code and
           prev-list.price-type = "" and
           prev-list.doc-num    = doc-code no-lock no-error.
      if available prev-list then
        assign
          buf-price-list.calc-method = 'Переоценка':U + " " + doc-code
          buf-price-list.price-calc = prev-list.price-sale
          buf-price-list.road-tax = prev-list.road-tax
          buf-price-list.excise = prev-list.excise
          buf-price-list.price-sale = prev-list.price-sale * (1 + loc-grp-increase-pc / 100)
          tt-price-sale = prev-list.price-sale * (1 + loc-grp-increase-pc / 100)
          .
      else
        message "Нет строки в переоценке :" doc-code "для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
    end.
    when 'Отсутствует':U then do:
      if buf-price-list.price-sale = ? then do:
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    when 'Единая':U then do:
        assign
          buf-price-list.calc-method = 'Единая':U
          buf-price-list.price-sale = common-price
          tt-price-sale = common-price
          .
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
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
              "pr-doc"
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
      if available ub.trn-doc then do:
        if ub.trn-doc.doc-type = 'при':U and
         ( ub.trn-doc.ext-doc-type = 'ie':U  ) then do:
          find ub.doc-line where ub.doc-line.doc-code = doc-code
                          and ub.doc-line.artic     = buf-price-list.artic
                          and ub.doc-line.prod-type = buf-price-list.prod-type
                          and ub.doc-line.prod-code = buf-price-list.prod-code no-lock no-error.
          if available ub.doc-line then DO:
              run str/gdsnovat.p
                 ('Накл-безНДС':U,
                  buf-price-list.obj-type          ,
                  buf-price-list.obj-code          ,
                  buf-price-doc.host-code         ,
                  buf-price-list.artic             ,
                  buf-price-list.prod-type         ,
                  buf-price-list.prod-code         ,
                  loc-increase-pc                   ,
                  doc-code              ,
                  input p-doc-price-rubl-novat   ,
                  input p-doc-price-base-novat   ,
                  output cost-base      ,
                  output cost-rubl      ,
                  output v-price-base   ,
                  output v-price-rubl   ,
                  output cur-rt-base    ,
                  output cur-rt-rubl   )
                  .
              assign
                cur-rt =  if var-pr-r-b = "rubl" then cur-rt-rubl else cur-rt-base
                buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then  ub.doc-line.price-rubl  else ub.doc-line.price-base
                buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then  v-price-rubl         else  v-price-base
                buf-price-list.road-tax    = cur-rt
                tt-price-sale   =  if var-pr-r-b = "rubl" then  v-price-rubl         else  v-price-base
                .
              End.
          else
            message "Нет строки в накладной :" doc-code "для товара :" buf-price-list.artic buf-goods.gds-name
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
        end.
        else do:
          find ub.doc-line where ub.doc-line.doc-code = doc-code
                          and ub.doc-line.artic     = buf-price-list.artic
                          and ub.doc-line.prod-type = buf-price-list.prod-type
                          and ub.doc-line.prod-code = buf-price-list.prod-code no-lock no-error.
          if available ub.doc-line then DO:
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
              assign
                cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                buf-price-list.road-tax    = cur-rt
                tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                .
              End.
          else
            message "Нет строки в накладной :" doc-code "для товара :" buf-price-list.artic buf-goods.gds-name
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
        end.
      end.
      else
        message "Не прочитана накладная с номером" doc-code
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
    end.
  when 'Откат_цен':U then do:
    run str/gdsnovat.p
      ( 'Откат_цен':U,
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
        output cur-rt-rubl
        ).
      assign
        cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
        buf-price-list.calc-method = 'Откат_цен':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        buf-price-list.road-tax    = cur-rt
        tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
      .
  end.
    when 'Стар-безНДС':U then do:
      run str/gdsnovat.p ( 'Стар-безНДС':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          loc-increase-pc,
          "" ,
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
          buf-price-list.calc-method = 'Стар-безНДС':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
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
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    when 'Старая':U then do:
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      if cur-pr = ? then
        message "Нет Акта переоценки для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет от старой цены продажи невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      else
        assign
          buf-price-list.calc-method = 'Старая':U
          buf-price-list.price-calc  = cur-pr
          buf-price-list.road-tax    = cur-rt
          buf-price-list.excise      = cur-ex
          buf-price-list.price-sale  = cur-pr * (1 + loc-increase-pc / 100)
          tt-price-sale  = cur-pr * (1 + loc-increase-pc / 100)
          .
    end.
    when 'Объект':U then do:
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  copy-type
  ,input  copy-code
  ,input  buf-price-list.b-code
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  )  .
      if cur-pr = ? then
        message "Нет Акта переоценки для товара :" buf-price-list.artic buf-goods.gds-name
                "по" input frame d-pr-doc copy-type
                input frame d-pr-doc copy-code "расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      else
        assign
          buf-price-list.calc-method = 'Объект':U + " " + copy-type + " " + string (copy-code, "99999")
          buf-price-list.price-calc  = cur-pr
          buf-price-list.road-tax    = cur-rt
          buf-price-list.excise      = cur-ex
          buf-price-list.price-sale  = cur-pr * (1 + loc-increase-pc / 100)
          tt-price-sale  = cur-pr * (1 + loc-increase-pc / 100)
          .
    end.
    when 'Накладная':U then do:
        run str/pr-wbil.p
        ( input "pr-doc"              ,
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
        ( input "pr-doc"                ,
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
    when 'Переоценка':U then do:
      find prev-list where
           prev-list.b-code     = buf-price-list.b-code and
           prev-list.price-type = "" and
           prev-list.doc-num    = doc-code no-lock no-error.
      if available prev-list then
        assign
          buf-price-list.calc-method = 'Переоценка':U + " " + doc-code
          buf-price-list.price-calc = prev-list.price-sale
          buf-price-list.road-tax = prev-list.road-tax
          buf-price-list.excise = prev-list.excise
          buf-price-list.price-sale = prev-list.price-sale * (1 + loc-increase-pc / 100)
          tt-price-sale = prev-list.price-sale * (1 + loc-increase-pc / 100)
          .
      else
        message "Нет строки в переоценке :" doc-code "для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
    end.
    when 'Отсутствует':U then do:
      if buf-price-list.price-sale = ? then do:
define variable vss-include-info86 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    when 'Единая':U then do:
        assign
          buf-price-list.calc-method = 'Единая':U
          buf-price-list.price-sale = common-price
          tt-price-sale = common-price
          .
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
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
              "pr-doc"
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
      if available ub.trn-doc then do:
        if ub.trn-doc.doc-type = 'при':U and
         ( ub.trn-doc.ext-doc-type = 'ie':U  ) then do:
          find ub.doc-line where ub.doc-line.doc-code = doc-code
                          and ub.doc-line.artic     = buf-price-list.artic
                          and ub.doc-line.prod-type = buf-price-list.prod-type
                          and ub.doc-line.prod-code = buf-price-list.prod-code no-lock no-error.
          if available ub.doc-line then DO:
              run str/gdsnovat.p
                 ('Накл-безНДС':U,
                  buf-price-list.obj-type          ,
                  buf-price-list.obj-code          ,
                  buf-price-doc.host-code         ,
                  buf-price-list.artic             ,
                  buf-price-list.prod-type         ,
                  buf-price-list.prod-code         ,
                  increase-pc                   ,
                  doc-code              ,
                  input p-doc-price-rubl-novat   ,
                  input p-doc-price-base-novat   ,
                  output cost-base      ,
                  output cost-rubl      ,
                  output v-price-base   ,
                  output v-price-rubl   ,
                  output cur-rt-base    ,
                  output cur-rt-rubl   )
                  .
              assign
                cur-rt =  if var-pr-r-b = "rubl" then cur-rt-rubl else cur-rt-base
                buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then  ub.doc-line.price-rubl  else ub.doc-line.price-base
                buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then  v-price-rubl         else  v-price-base
                buf-price-list.road-tax    = cur-rt
                tt-price-sale   =  if var-pr-r-b = "rubl" then  v-price-rubl         else  v-price-base
                .
              End.
          else
            message "Нет строки в накладной :" doc-code "для товара :" buf-price-list.artic buf-goods.gds-name
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
        end.
        else do:
          find ub.doc-line where ub.doc-line.doc-code = doc-code
                          and ub.doc-line.artic     = buf-price-list.artic
                          and ub.doc-line.prod-type = buf-price-list.prod-type
                          and ub.doc-line.prod-code = buf-price-list.prod-code no-lock no-error.
          if available ub.doc-line then DO:
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
              assign
                cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
                buf-price-list.calc-method = 'Накл-безНДС':U + " " + doc-code
                buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then ub.doc-line.price-rubl else ub.doc-line.price-base
                buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                buf-price-list.road-tax    = cur-rt
                tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
                .
              End.
          else
            message "Нет строки в накладной :" doc-code "для товара :" buf-price-list.artic buf-goods.gds-name
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
        end.
      end.
      else
        message "Не прочитана накладная с номером" doc-code
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
    end.
  when 'Откат_цен':U then do:
    run str/gdsnovat.p
      ( 'Откат_цен':U,
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
        output cur-rt-rubl
        ).
      assign
        cur-rt          =  if var-pr-r-b = "rubl" then cur-rt-rubl         else cur-rt-base
        buf-price-list.calc-method = 'Откат_цен':U
        buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
        buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        buf-price-list.road-tax    = cur-rt
        tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
      .
  end.
    when 'Стар-безНДС':U then do:
      run str/gdsnovat.p ( 'Стар-безНДС':U,
          buf-price-list.obj-type,
          buf-price-list.obj-code,
          buf-price-doc.host-code,
          buf-price-list.artic,
          buf-price-list.prod-type,
          buf-price-list.prod-code,
          increase-pc,
          "" ,
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
          buf-price-list.calc-method = 'Стар-безНДС':U
          buf-price-list.price-calc  =  if var-pr-r-b = "rubl" then cost-rubl           else cost-base
          buf-price-list.price-sale  =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
          buf-price-list.road-tax    = cur-rt
          tt-price-sale   =  if var-pr-r-b = "rubl" then v-price-rubl        else v-price-base
        .
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
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    when 'Старая':U then do:
define variable vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      if cur-pr = ? then
        message "Нет Акта переоценки для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет от старой цены продажи невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      else
        assign
          buf-price-list.calc-method = 'Старая':U
          buf-price-list.price-calc  = cur-pr
          buf-price-list.road-tax    = cur-rt
          buf-price-list.excise      = cur-ex
          buf-price-list.price-sale  = cur-pr * (1 + increase-pc / 100)
          tt-price-sale  = cur-pr * (1 + increase-pc / 100)
          .
    end.
    when 'Объект':U then do:
define variable vss-include-info92 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  copy-type
  ,input  copy-code
  ,input  buf-price-list.b-code
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  )  .
      if cur-pr = ? then
        message "Нет Акта переоценки для товара :" buf-price-list.artic buf-goods.gds-name
                "по" input frame d-pr-doc copy-type
                input frame d-pr-doc copy-code "расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
      else
        assign
          buf-price-list.calc-method = 'Объект':U + " " + copy-type + " " + string (copy-code, "99999")
          buf-price-list.price-calc  = cur-pr
          buf-price-list.road-tax    = cur-rt
          buf-price-list.excise      = cur-ex
          buf-price-list.price-sale  = cur-pr * (1 + increase-pc / 100)
          tt-price-sale  = cur-pr * (1 + increase-pc / 100)
          .
    end.
    when 'Накладная':U then do:
        run str/pr-wbil.p
        ( input "pr-doc"              ,
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
        ( input "pr-doc"                ,
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
    when 'Переоценка':U then do:
      find prev-list where
           prev-list.b-code     = buf-price-list.b-code and
           prev-list.price-type = "" and
           prev-list.doc-num    = doc-code no-lock no-error.
      if available prev-list then
        assign
          buf-price-list.calc-method = 'Переоценка':U + " " + doc-code
          buf-price-list.price-calc = prev-list.price-sale
          buf-price-list.road-tax = prev-list.road-tax
          buf-price-list.excise = prev-list.excise
          buf-price-list.price-sale = prev-list.price-sale * (1 + increase-pc / 100)
          tt-price-sale = prev-list.price-sale * (1 + increase-pc / 100)
          .
      else
        message "Нет строки в переоценке :" doc-code "для товара :" buf-price-list.artic buf-goods.gds-name
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
    end.
    when 'Отсутствует':U then do:
      if buf-price-list.price-sale = ? then do:
define variable vss-include-info93 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    when 'Единая':U then do:
        assign
          buf-price-list.calc-method = 'Единая':U
          buf-price-list.price-sale = common-price
          tt-price-sale = common-price
          .
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
define variable vss-include-info94 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
              "pr-doc"
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
define variable vss-include-info96 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info97 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable vss-include-info98 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info99 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info100 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info101 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE VER-PR-EQU-DQ :
define input parameter  l-doc-num    like ub.price-list.doc-num    no-undo .
define input parameter  l-num       as integer no-undo .
define input parameter  l-b-code    as integer   no-undo .
define variable  l-doc-num2    like ub.price-list.doc-num    no-undo .
define buffer l-price-list  for ub.price-list .
define buffer pp_price-list for ub.price-list .
define buffer p2_price-list for ub.price-list .
define buffer main_price-list for ub.price-list .
define buffer alt_price-list  for ub.price-list .
define buffer buf1-bar-code for ub.bar-code .
define buffer buf2-bar-code for ub.bar-code .
define variable v-num as integer init 0 no-undo .
define variable bbb as logical no-undo .
define variable  l-price-sale like ub.price-list.price-sale no-undo .
define variable  l-road-tax   like ub.price-list.road-tax   no-undo .
define variable  l-excise     like ub.price-list.excise     no-undo .
define variable  l-ok         as logical no-undo .
define variable  check-par    as logical no-undo .
for each l-price-list where l-price-list.doc-num = l-doc-num     and
                            l-price-list.main-price = true
                            exclusive-lock  :
  find first ub.goods where ub.goods.artic    = l-price-list.artic and
                        ub.goods.prod-type = l-price-list.prod-type and
                        ub.goods.prod-code = l-price-list.prod-code no-lock   .
      check-par = false .
      if l-num = 2 then do:
        find first buf2-bar-code where buf2-bar-code.b-code = l-b-code no-lock no-error .
        if ub.goods.gds-code <> buf2-bar-code.gds-code then next.
      end.
define variable vss-include-info102 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  l-price-list.obj-type
  ,input  l-price-list.obj-code
  ,input  l-price-list.b-code
  ,input  0
  ,input  0
  ,output l-doc-num2
  ,output l-price-sale
  ,output l-road-tax
  ,output l-excise
  ) no-error .
      if l-doc-num2 <> ? then do :
        if l-price-sale = l-price-list.price-sale
        then do:
          if par-pr-equ-dq >= 2 then do:
            check-par = false .
               for each pp_price-list no-lock where pp_price-list.doc-num = l-doc-num   and
                  pp_price-list.artic       =  l-price-list.artic      and
                  pp_price-list.prod-type   =  l-price-list.prod-type  and
                  pp_price-list.prod-code   =  l-price-list.prod-code  and
                  pp_price-list.main-price  =  no  :
                    check-par = true  .
                    leave.
                end.
            if  check-par = true then NEXT .
            if par-pr-equ-dq = 2 then do:
              if  ( v-num <= 2  and check-par = false ) then
              run gbl/d-askw.w
                (input "Удалить строку?"
                ,input      "Предыдущая цена РАВНА цене по закрываемому документу " + chr(10)
                            + " Объект "  + l-price-list.obj-type + " " + String(l-price-list.obj-code) + chr(10)
                            + " Артикул " + l-price-list.artic    + " " +  ub.goods.gds-name + chr(10)
                            + " Бар-код " + string(l-price-list.b-code)
                            + " Цена по предыдущему документу № " + l-doc-num + " "
                            + string(l-price-sale) + chr(10)
                            + string(l-price-list.price-sale)
                            + " Удалить строку? "
                ,input "|^"
                ,input "Да|Нет|Да для всех^confirm|Нет для всех^confirm"
                ,input "Удалить строку|"
                    + "Не удалять строку|"
                    + "Удалять у всех товаров, цена на которые не изменилась|"
                    + "Не удалять у всех товаров, цена на которые не изменилась"
                ,input 1
                ,input 2
                ,output v-num
                ).
              end.
              else do:
                v-num = 3 .
              end.
                if v-num = 1 then do:
                  run del-pr-list (input l-price-list.b-code,
                                  input l-price-list.doc-num,
                                  input ?,
                                  input ?) no-error.
                                  if error-status :error then do:
                                          message  vss-workfile vss-revision vss-description skip
                                          "Ошибка при удаление строки переоценки "
                                          l-price-list.b-code skip
                                          error-status :get-message(1) .
                                          return error.
                                  end.
                end.
                if v-num = 3  then do:
                   run del-pr-list (input l-price-list.b-code,
                                    input l-price-list.doc-num,
                                    input ?,
                                    input ?)
                                    no-error.
                end.
          end.
        end.
       end.
end.
  if par-pr-equ-dq >= 2 then do:
     for each main_price-list no-lock where
              main_price-list.doc-num         = l-doc-num   and
              main_price-list.main-price      = true ,
        first ub.goods where ub.goods.artic   = main_price-list.artic and
                        ub.goods.prod-type = main_price-list.prod-type and
                        ub.goods.prod-code = main_price-list.prod-code no-lock   :
             if l-num = 2 then do:
                find first buf2-bar-code where buf2-bar-code.b-code = l-b-code no-lock no-error .
                if ub.goods.gds-code <> buf2-bar-code.gds-code then next.
             end.
                for each pp_price-list no-lock where
                  pp_price-list.doc-num         = main_price-list.doc-num    and
                  pp_price-list.artic           = main_price-list.artic      and
                  pp_price-list.prod-type       = main_price-list.prod-type  and
                  pp_price-list.prod-code       = main_price-list.prod-code  and
                  pp_price-list.main-price      = no and
                  pp_price-list.price-sale      = main_price-list.price-sale  ,
                    first buf1-bar-code no-lock where
                      buf1-bar-code.b-code    = pp_price-list.b-code and
                      buf1-bar-code.unit-cli  = ub.goods.unit-base break by buf1-bar-code.b-code :
                          if first-of( buf1-bar-code.b-code ) then do:
                          bbb = false.
                                   for each alt_price-list where
                                          pp_price-list.doc-num         = alt_price-list.doc-num    and
                                          pp_price-list.artic           = alt_price-list.artic      and
                                          pp_price-list.prod-type       = alt_price-list.prod-type  and
                                          pp_price-list.prod-code       = alt_price-list.prod-code  and
                                          pp_price-list.main-price      = no  no-lock :
                                        if pp_price-list.b-code   =  fnc-base-code (alt_price-list.b-code) and
                                          alt_price-list.b-code = pp_price-list.b-code then next.
                                          if fnc-base-code (alt_price-list.b-code) = pp_price-list.b-code
                                          then do:
                                                bbb = true .
                                                leave.
                                           end.
                                   end.
                                    if bbb = false then do:
                                        run del-pr-list ( input pp_price-list.b-code  ,
                                                          input pp_price-list.doc-num ,
                                                          input ? ,
                                                          input ? ) no-error.
                                        if error-status :error then do:
                                          message  vss-workfile vss-revision vss-description skip
                                          " Нельзя удалить " pp_price-list.b-code skip
                                          error-status :get-message(1) .
                                          end.
                                    end.
                          end.
                end.
     end.
 end.
end procedure.
define variable vss-include-info103 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info104 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE write-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-bonus as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
               ub.contract-specif-attr.contract-num = p-contract-num  and
               ub.contract-specif-attr.host-code    = p-host-code     and
               ub.contract-specif-attr.gds-code     = p-gds-code      and
               ub.contract-specif-attr.attr-code    = 'bonus':U
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = 'bonus':U
         .
      end.
      ub.contract-specif-attr.attr-value  = string (v-bonus) .
end.
END PROCEDURE.
PROCEDURE read-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-bonus as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = 'bonus':U
           no-error .
   if available ub.contract-specif-attr then  v-bonus = decimal (ub.contract-specif-attr.attr-value ) .
                                        else  v-bonus = 0 .
end.
END PROCEDURE.
PROCEDURE write-prc-min :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-prc-min        as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = p-contract-num  and
              ub.contract-specif-attr.host-code    = p-host-code     and
              ub.contract-specif-attr.gds-code     = p-gds-code      and
              ub.contract-specif-attr.attr-code    = 'prc-min':U
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = 'prc-min':U
              ub.contract-specif-attr.attr-value  = string (v-prc-min)
         .
      end.
      else do:
         ub.contract-specif-attr.attr-value  = string (v-prc-min) .
      end.
    find first ub.contract-specif exclusive-lock where
        ub.contract-specif.contract-num = p-contract-num and
        ub.contract-specif.host-code    = p-host-code    and
        ub.contract-specif.gds-code     = p-gds-code.
        ub.contract-specif.whole-send-news  = ub.contract-specif.whole-send-news + 1.
end.
END PROCEDURE.
PROCEDURE read-prc-min :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-prc-min as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = 'prc-min':U
           no-error .
   if available ub.contract-specif-attr then  v-prc-min = decimal (ub.contract-specif-attr.attr-value ) .
                                        else  v-prc-min = 0 .
end.
END PROCEDURE.
PROCEDURE write-retro-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-retro-bonus as character   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = p-contract-num  and
              ub.contract-specif-attr.host-code    = p-host-code     and
              ub.contract-specif-attr.gds-code     = p-gds-code      and
              ub.contract-specif-attr.attr-code    = "retro-bonus"
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = "retro-bonus"
         .
         ub.contract-specif-attr.attr-value  = v-retro-bonus no-error.
         if error-status:error then
            message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
      end.
      else do:
         ub.contract-specif-attr.attr-value  = v-retro-bonus no-error.
         if error-status:error then
            message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
      end.
    find first ub.contract-specif exclusive-lock where
        ub.contract-specif.contract-num = p-contract-num and
        ub.contract-specif.host-code    = p-host-code    and
        ub.contract-specif.gds-code     = p-gds-code.
        ub.contract-specif.whole-send-news  = ub.contract-specif.whole-send-news + 1.
end.
END PROCEDURE.
PROCEDURE read-retro-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-retro-bonus as character   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = "retro-bonus"
           no-error .
   if available ub.contract-specif-attr then  v-retro-bonus = ub.contract-specif-attr.attr-value  .
                                        else  v-retro-bonus = "" .
end.
END PROCEDURE.
procedure ver-pr-discn :
define input parameter   p-mode as character no-undo .
define input parameter   p-doc like ub.price-doc.doc-num no-undo.
define input parameter   trn-doc-code like ub.trn-doc.doc-code no-undo .
define output parameter  p-err as logical no-undo .
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
define buffer buf_bar-code for ub.bar-code  .
define buffer b_price-doc  for ub.price-doc .
define buffer b_price-list for ub.price-list .
define buffer b_trn-doc    for ub.trn-doc .
define buffer b_doc-line   for ub.doc-line .
define buffer bl_goods           for ub.goods .
define buffer bl_gds-grp         for ub.gds-grp .
define variable t-prc            as decimal   no-undo .
define variable p-prc-min        as decimal   no-undo .
define variable p-prc-max        as decimal   no-undo .
define variable p-increase-pc    as decimal   no-undo .
define variable p-round-method   as character no-undo .
define variable p-base           as decimal   no-undo .
define variable v-koff           as decimal   no-undo .
define variable p-node-code      as integer   no-undo .
define variable p-host-code      as integer   no-undo .
define variable p-obj-type       as character no-undo .
define variable p-obj-code       as integer   no-undo .
define variable p-value-margin   as integer   no-undo .
define variable p-type-margin    as logical   no-undo .
define variable p-value-increase as integer   no-undo .
define variable p-type-increase  as logical   no-undo .
define variable p-value-rmethod  as integer   no-undo .
define variable p-type-rmethod   as logical   no-undo .
define variable l_price           as decimal   no-undo .
define variable l_pricewithvat    as decimal   no-undo .
define variable l_pricewithoutvat as decimal   no-undo .
define variable l_prod-vat        as decimal   no-undo .
define variable pr-discm          as character no-undo .
define variable pr-gen-margin     as character no-undo .
p-err = false .
define variable cost-base     as decimal  no-undo .
define variable cost-rubl     as decimal  no-undo .
define variable v-price-base  as decimal  no-undo .
define variable v-price-rubl  as decimal  no-undo .
define variable cur-rt-base   as decimal  no-undo .
define variable cur-rt-rubl   as decimal  no-undo .
define variable f-cost as decimal no-undo .
define variable s-cost as decimal no-undo .
define variable f-qnty as decimal no-undo .
define variable s-qnty as decimal no-undo .
define variable p-attr-code    like UB.price-list-attr.attr-code  no-undo .
define variable p-b-code       like ub.price-list-attr.b-code     no-undo .
define variable p-doc-num      like ub.price-list-attr.doc-num    no-undo .
define variable p-price-type   like ub.price-list-attr.price-type no-undo .
define variable p-attr-value   like ub.price-list-attr.attr-value no-undo .
define variable v-bonus as decimal   no-undo .
define variable l_price0 as decimal   no-undo .
define buffer   buf_contract-specif for ub.contract-specif  .
find first b_price-doc where b_price-doc.doc-num    = p-doc no-lock  no-error .
assign
    p-host-code  = b_price-doc.host-code
    p-obj-type   = b_price-doc.obj-type
    p-obj-code   = b_price-doc.obj-code
.
define variable v-ok as logical   no-undo .
define variable vss-include-info105 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_discount':U
    ,input  'object':U
    ,input  p-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-ok
    )  .
end.
if v-ok = true then return .
pr-discm      = par-pr-discm .
if trim(pr-discm) = "" then return .
if pr-discm = 'sale-' then pr-discm = 'sale' .
for each  b_price-list where b_price-list.doc-num    = p-doc no-lock :
    find first bl_goods   where b_price-list.artic     = bl_goods.artic     and
                                b_price-list.prod-code = bl_goods.prod-code and
                                b_price-list.prod-type = bl_goods.prod-type no-lock no-error .
    if error-status :error then return error.
    find first buf_bar-code no-lock where
               buf_bar-code.b-code  = b_price-list.b-code
               no-error .
    if available buf_bar-code then v-koff = buf_bar-code.cli-base-rate .
    else v-koff = 1.
    if v-koff = ? or v-koff = 0 then v-koff = 1.
    assign
    p-node-code  = bl_goods.grp-code
    .
    run gds-attr-margin-value
    (
      input   bl_goods.gds-code,
      input   p-obj-type ,
      input   p-obj-code ,
      output  p-prc-min  ,
      output  p-prc-max  ,
      output  p-increase-pc,
      output  p-round-method,
      output  p-base        ,
      output  p-value-margin    ,
      output  p-type-margin     ,
      output  p-value-increase   ,
      output  p-type-increase   ,
      output  p-value-rmethod   ,
      output  p-type-rmethod
      ) no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "123"
        view-as alert-box error
      .
    if p-type-margin = false  then next.
 if  trn-doc-code = ? or trn-doc-code = "" then do:
        if b_price-list.main-price = true then do :
          case  pr-discm :
              when "prod":u then do:
define variable vss-include-info106 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-list.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_pricewithoutvat
 , output l_price
 , output l_prod-vat
 , output v-str
 , output v-str
        )  .
                  t-prc  =  (b_price-list.price-sale  / l_price - 1) * 100  .
              end.
              when "prod-vat":u then do:
define variable vss-include-info107 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-list.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_price
 , output l_pricewithvat
 , output l_prod-vat
 , output v-str
 , output v-str
        )  .
                  t-prc  =  (b_price-list.price-sale  / l_price - 1) * 100  .
              end.
              when "cost-vat":u then do:
                  run str/gdsnovat.p ('Учет-безНДС':U,
                          b_price-list.obj-type,
                          b_price-list.obj-code,
                          p-host-code,
                          b_price-list.artic,
                          b_price-list.prod-type,
                          b_price-list.prod-code,
                          0 ,
                          ? ,
                          ? ,
                          ? ,
                          output cost-base   ,
                          output cost-rubl   ,
                          output v-price-base  ,
                          output v-price-rubl  ,
                          output cur-rt-base ,
                          output cur-rt-rubl ).
                          l_price =  if var-pr-r-b = "rubl" then v-price-rubl else v-price-base .
                          t-prc = (b_price-list.price-sale / l_price - 1) * 100.
              end.
            when "cost":u       then do:
              t-prc =  fnc-cost-pc (buffer b_price-list) .
            end.
            when "sale":u then do:
              t-prc =  fnc-pr-pc   (buffer b_price-list) .
            end.
          end case.
        end.
        else do:
          case  pr-discm :
              when "prod":u then do:
define variable vss-include-info108 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-list.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_pricewithoutvat
 , output l_price
 , output l_prod-vat
 , output v-str
 , output v-str
        )  .
              end.
              when "prod-vat":u then do:
define variable vss-include-info109 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-list.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_price
 , output l_pricewithvat
 , output l_prod-vat
 , output v-str
 , output v-str
        )  .
            end.
            when "cost":u
            or when "cost-vat":u
            then do:
              l_price =  fnc-cost (buffer b_price-list) .
            end.
            when "sale":u then do:
              l_price =  fnc-pr   (buffer b_price-list) .
            end.
          end case.
          t-prc = (b_price-list.price-sale / (l_price * v-koff) - 1) * 100.
        end.
end.
else do:
    find first b_trn-doc where b_trn-doc.doc-code = trn-doc-code no-lock no-error .
    if available b_trn-doc then do:
     find first b_doc-line where
        b_doc-line.doc-code  = b_trn-doc.doc-code and
        b_doc-line.artic     = bl_goods.artic     and
        b_doc-line.prod-code = bl_goods.prod-code and
        b_doc-line.prod-type = bl_goods.prod-type no-lock no-error .
     end.
     else do:
       return error return-value + "Не найден документ с номером " + trn-doc-code.
     end.
define variable vss-include-info110 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  b_trn-doc.host-code,
    INPUT  b_trn-doc.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = b_trn-doc.host-code
      i-gl-Contract-Code  = b_trn-doc.contract-code
      .
END.
    FIND FIRST buf_contract-specif
           NO-LOCK
           WHERE
               buf_contract-specif.Host-code    = i-gl-Host-Code
           AND buf_contract-specif.Contract-num = i-gl-Contract-Code
           AND buf_contract-specif.Gds-code     = bl_goods.gds-code
           NO-ERROR
           .
    if available buf_contract-specif then do:
        run read-bonus (
            input  buf_contract-specif.contract-num  ,
            input  buf_contract-specif.host-code     ,
            input  buf_contract-specif.gds-code      ,
            output v-bonus  ) .
    end.
    else do:
        v-bonus  = 0 .
    end.
      if b_trn-doc.ext-doc-type = 'ie':U then   pr-gen-margin = par-gen-mrgn-ie.
      if b_trn-doc.ext-doc-type = 'iv':U then   pr-gen-margin = par-gen-mrgn-iv.
      if b_trn-doc.ext-doc-type = 'im':U  then   pr-gen-margin = par-gen-mrgn-im.
      pr-gen-margin = lc(pr-gen-margin).
      if available b_doc-line then do:
      case  pr-discm :
        when "cost":u then do:
                f-qnty = 0.
                find ub.gds-obj no-lock where
                    ub.gds-obj.gds-code = bl_goods.gds-code and
                    ub.gds-obj.obj-type = b_trn-doc.obj-type and
                    ub.gds-obj.obj-code = b_trn-doc.obj-code no-error.
                if  available ub.gds-obj then
                  if bl_goods.gds-type = 'т':U then do:
                          if var-pr-r-b = "rubl" then
                              assign
                                f-cost = if  ub.gds-obj.avrg-rubl = ? then 0 else ub.gds-obj.avrg-rubl
                                f-qnty = ub.gds-obj.avrg-qnty
                                .
                          else
                              assign
                                f-cost = if  ub.gds-obj.avrg-base = ? then 0 else ub.gds-obj.avrg-base
                                f-qnty = ub.gds-obj.avrg-qnty
                                .
                      end.
                    else  f-cost = ?.
                else f-cost = ?.
           if pr-gen-margin = 'before-margin':U then do:
assign
  price-rubl-with-tax-loc = b_doc-line.price-rubl
  price-base-with-tax-loc = b_doc-line.price-base
.
define variable vss-include-info111 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = b_trn-doc.doc-code
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
   find first in-vatp-goods where in-vatp-goods.artic     = b_doc-line.artic     and
                                     in-vatp-goods.prod-type = b_doc-line.prod-type and
                                     in-vatp-goods.prod-code = b_doc-line.prod-code no-lock.
   if (not b_trn-doc.internal and
           b_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = b_doc-line.road-tax
          road-tax-rubl-loc = b_doc-line.road-tax * b_trn-doc.base-rate / b_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = b_doc-line.road-tax
          road-tax-base-loc = b_doc-line.road-tax / b_trn-doc.base-rate * b_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if b_doc-line.transport-base = ? then 0 else b_doc-line.transport-base)
        transport-rubl-loc = (if b_doc-line.transport-rubl = ? then 0 else b_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if b_doc-line.other-base     = ? then 0 else b_doc-line.other-base)
        other-rubl-loc     = (if b_doc-line.other-rubl     = ? then 0 else b_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if b_doc-line.vat-pc         = ? then 0 else b_doc-line.vat-pc)
        slt-pc-loc         = (if b_doc-line.slt-pc         = ? then 0 else b_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = b_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = b_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = b_doc-line.obj-code  and
                                      in-vatp-parts.artic     = b_doc-line.artic     and
                                      in-vatp-parts.prod-type = b_doc-line.prod-type and
                                      in-vatp-parts.prod-code = b_doc-line.prod-code
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
        road-tax-base-loc   = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        transport-base-loc  = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        other-base-loc      = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        other-rubl-loc      = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if b_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b_doc-line.fact-qnty   else 0
        slt-base-loc        = if b_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if b_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if b_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b_doc-line.fact-qnty   else 0
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
             if var-pr-r-b = "rubl" then
                 s-cost = price-rubl-with-tax-loc.
               else
                 s-cost = price-base-with-tax-loc.
             s-qnty = b_doc-line.fact-qnty .
           end.
           else do:
             assign
              s-cost = 0
              s-qnty = 0
             .
           end.
           l_price  =  (f-cost * f-qnty + s-cost * s-qnty ) / (f-qnty + s-qnty)  .
        end.
        when "cost-vat":u then do:
             run str/gdsnovat.p ('Уч+накл-НДС':U,
                     b_trn-doc.obj-type,
                     b_trn-doc.obj-code,
                     b_trn-doc.host-code,
                     b_doc-line.artic,
                     b_doc-line.prod-type,
                     b_doc-line.prod-code,
                     0 ,
                     b_doc-line.doc-code,
                     ?,
                     ?,
                     output cost-base   ,
                     output cost-rubl   ,
                     output v-price-base  ,
                     output v-price-rubl  ,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
                     if var-pr-r-b = "rubl"
                        then l_price = v-price-rubl.
                        else l_price = v-price-base.
        end.
        when "sale":u then do:
              l_price = ( if var-pr-r-b = "rubl"
                             then b_doc-line.price-rubl
                             else b_doc-line.price-base ).
        end.
        when "prod":u then do:
define variable vss-include-info112 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-list.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_pricewithoutvat
 , output l_price
 , output l_prod-vat
 , output v-str
 , output v-str
        )  .
        end.
        when "prod-vat":u then do:
define variable vss-include-info113 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-list.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_price
 , output l_pricewithvat
 , output l_prod-vat
 , output v-str
 , output v-str
        )  .
        end.
      end case.
       run view-price-list-attr (
            input   'full-price-sale':U   ,
            input   b_price-list.b-code       ,
            input   b_price-list.doc-num      ,
            input   b_price-list.price-type   ,
            output  p-attr-value   ).
           if not ( p-attr-value = ? or p-attr-value = "")  then
                   tt-price-sale = decimal(p-attr-value).
              else  tt-price-sale = b_price-list.price-sale .
        if v-bonus <> ? and v-bonus <> 0 then do:
            l_price0 = l_price .
            l_price = l_price + ( l_price * v-bonus / 100 ) .
        end.
        t-prc = ( (tt-price-sale / v-koff)   / l_price - 1) * 100 .
   end.
end.
  if  p-prc-max <> ? then do:
    if  t-prc <> ? and ( p-prc-max < t-prc  or p-prc-min > t-prc)
    then do:
      message (if b_price-list.main-price = true then "По товару :"
          else "По признаку"  )
          b_price-list.artic
          b_price-list.prod-type
          b_price-list.prod-code skip
          "бар-код: " b_price-list.b-code skip
                          skip
               fnc-pr  (buffer b_price-list)
          skip
        "Процент торговой наценки вышел за интервал возможных значений !!! " skip
        "Процент не менее :" p-prc-min "%" skip
        "Процент не более :" p-prc-max "%" skip
        "Процент фактический :" t-prc  "%"  skip
        "переоценка " b_price-list.doc-num
            view-as alert-box error .
              p-err = true .
              undo , return error .
    end.
    else do:
       if  t-prc = ? then  do:
          if pr-discm = "sale"  then do:
          end.
          else do:
            message (if b_price-list.main-price = true then "По товару :"
            else "По признаку"  )
            b_price-list.artic
            b_price-list.prod-type
            b_price-list.prod-code skip
            "бар-код: " b_price-list.b-code skip
            fnc-pr  (buffer b_price-list) skip
            "Нет базовой цены для расчета процента наценки !" skip
            "Процент торговой наценки вышел за интервал возможных значений !!! " skip
            "Процент не менее :" p-prc-min "%" skip
            "Процент не более :" p-prc-max "%" skip
            "Процент фактический :" t-prc  "%"  skip
            "переоценка " b_price-list.doc-num
            view-as alert-box error .
            p-err = true .
            undo , return error .
        end.
       end.
    end.
  end.
end.
end procedure.
define variable vss-include-info114 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure exp-prt :
  define input  parameter  g-code  like ub.goods.gds-code    no-undo.
  define input  parameter  old-num like ub.price-doc.doc-num no-undo.
  define input  parameter  new-num like ub.price-doc.doc-num no-undo.
  define output parameter  new-rec as recid               no-undo.
  do
  on error undo, return error return-value
  :
  define buffer buf-bar-code   for ub.bar-code.
  define buffer buf-goods      for ub.goods.
  define buffer buf-price-list for ub.price-list.
  find buf-goods no-lock where
      buf-goods.gds-code = g-code.
  if par-pr-altex = "yes" and
     par-pr-notls = "yes" then do:
define variable vss-include-info115 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each  buf-price-list where
          buf-price-list.doc-num    = old-num and
          buf-price-list.artic      = buf-goods.artic and
          buf-price-list.prod-type  = buf-goods.prod-type and
          buf-price-list.prod-code  = buf-goods.prod-code and
          buf-price-list.main-price = no,
    first buf-bar-code no-lock where
          buf-bar-code.b-code   = buf-price-list.b-code and
          buf-bar-code.unit-cli <> buf-goods.unit-base:
  run cre-pr-list (input  buf-bar-code.b-code,
                   input  new-num,
                   output new-rec) no-error.
  if error-status:error then do:
    message
      "Ошибка cre-pr-list." skip
      "Код:" buf-bar-code.b-code
      view-as alert-box.
    next.
  end.
end.
  end.
  if par-pr-sclex = "yes" and
    par-pr-notls = "yes" then do:
define variable vss-include-info116 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    define buffer buf_alt-calc_price-doc117 for ub.price-doc .
  find first buf_alt-calc_price-doc117 no-lock
    where buf_alt-calc_price-doc117.doc-num = old-num
    .
  define variable v-ok as logical   no-undo .
define variable vss-include-info118 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_properties':U
    ,input  'object':U
    ,input  buf_alt-calc_price-doc117.host-code
    ,input  buf_alt-calc_price-doc117.obj-type
    ,input  buf_alt-calc_price-doc117.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-ok
    )  .
end.
  if v-ok then do:
for each  buf-price-list where
          buf-price-list.doc-num    = old-num and
          buf-price-list.artic      = buf-goods.artic and
          buf-price-list.prod-type  = buf-goods.prod-type and
          buf-price-list.prod-code  = buf-goods.prod-code and
          buf-price-list.main-price = no,
    first buf-bar-code no-lock where
          buf-bar-code.b-code   = buf-price-list.b-code and
          buf-bar-code.in-code = "" and
          buf-bar-code.unit-cli = buf-goods.unit-base:
  run cre-pr-list (input  buf-bar-code.b-code,
                   input  new-num,
                   output new-rec) no-error.
  if error-status:error then do:
    message
      "Ошибка cre-pr-list." skip
      "Код:" buf-bar-code.b-code
      view-as alert-box.
    next.
  end.
end.
end.
  end.
  end.
end procedure.
procedure disable_ui :
  hide frame d-pr-doc.
end procedure.
procedure mode-on :
define variable v-today as date      no-undo.
define variable new-doc-rec as recid no-undo .
define buffer old-doc for ub.price-doc.
if doc-mode = 'ДОБАВЛЕНИЕ':U then do:
  find last old-doc where old-doc.obj-type = v-cntxt-obj-type
                      and old-doc.obj-code = v-cntxt-obj-code
                      and old-doc.status_ = 'новый':U no-lock no-error.
  if available old-doc then do:
    g#log = yes.
    message "По" v-cntxt-obj-type v-cntxt-obj-code "имеется незакрытый приказ №" old-doc.doc-num "от" old-doc.doc-date
            ". Вы уверены, что Вы хотите создать новый приказ ? ОТКАЗ от создания - cancel."
            view-as alert-box question buttons ok-cancel update g#log.
    if not g#log then   do:
        undo, return error.
        end.
  end.
  run prcreate-new-price-doc in this-procedure
    ( input v-cntxt-db-num ,
      input v-cntxt-obj-type ,
      input v-cntxt-obj-code ,
      ?,?,?,?,
      output new-doc-rec ) no-error .
      if error-status :error then
          message vss-workfile vss-revision vss-description skip
          error-status :get-message(1)
          "Ошибка при создании документа переоценки "
          view-as alert-box error .
   doc-rec = new-doc-rec .
   find first p-doc where recid(p-doc) = doc-rec  exclusive-lock  .
end.
else do:
  if doc-mode = 'ИЗМЕНЕНИЕ':U then do:
    find p-doc where recid (p-doc) = doc-rec no-error.
    if available p-doc then do:
       if lookup ( p-doc.status_ , 'приказ,разрешен,акт':U)  > 0 then do:
         message "Приказ/Акт переоценки №" p-doc.doc-num
                 "для" p-doc.obj-type p-doc.obj-code "от"
                 p-doc.doc-date "закрыт. Изменение невозможно."
                 view-as alert-box error.
         undo, return error.
       end.
     end.
  end.
  if not available p-doc then do:
    message "Неправильный выбор документа."
            view-as alert-box error.
    undo, return error.
  end.
end.
end procedure.
procedure cre-line:
def input param bc    like ub.price-list.b-code no-undo.
define variable v-ret as logical no-undo .
define buffer buf-bar-code  for ub.bar-code.
define buffer buf-goods     for ub.goods.
define buffer buf-gds-prt   for ub.gds-prt.
find  buf-bar-code no-lock where
      buf-bar-code.b-code = bc.
  run check-use-bar-code ( buf-bar-code.b-code ) no-error .
  if error-status :error then do:
    message
      return-value skip
      "Ошибка !"
      view-as alert-box error
    .
    undo, return error.
  end.
find  buf-goods no-lock where
      buf-goods.gds-code = buf-bar-code.gds-code.
find  buf-gds-prt no-lock where
      buf-gds-prt.node-code = buf-bar-code.node-code.
    run ver-modificator-price-is-null in this-procedure (
        input    buf-goods.artic        ,
        input    buf-goods.prod-type    ,
        input    buf-goods.prod-code    ,
        input    p-doc.obj-type   ,
        input    p-doc.obj-code   ,
        output   v-ret ).
    if v-ret = false then do:
    message
      "На модификатор : " skip
      "Артикул : "buf-goods.artic skip
      buf-goods.gds-name skip
      "не должно быть цены! "
      view-as alert-box information .
      undo, return error.
  end.
if par-pr-dpl-q = "yes" then do:
  find first ub.price-list where
             ub.price-list.b-code   = bc and
             ub.price-list.obj-type = p-doc.obj-type and
             ub.price-list.obj-code = p-doc.obj-code and
             ub.price-list.doc-num <> p-doc.doc-num and
             ub.price-list.fact-order = 0
             no-lock   no-error.
  if available ub.price-list then do:
    g#log = yes.
    message "Строка :" ub.price-list.artic buf-goods.gds-name
            "ЕСТЬ в Приказе №" ub.price-list.doc-num
            "для" p-doc.obj-type p-doc.obj-code skip
            "Продолжать?"
            view-as alert-box question buttons ok-cancel update g#log.
    if not g#log then
      undo, return error.
  end.
end.
find  ub.price-list where
      ub.price-list.b-code  = bc and
      ub.price-list.price-type = "" and
      ub.price-list.doc-num = p-doc.doc-num  no-error.
if available ub.price-list then do:
  line-rec = recid (ub.price-list).
  new-pr-recid = line-rec.
  if ub.price-list.calc-method <> "" and
     buf-gds-prt.upper-code = buf-goods.prt-root then do:
        if par-pr-clt-q = "yes" then do:
          g#log = yes.
          message "Строка :" ub.price-list.artic buf-goods.gds-name
                  "уже ЕСТЬ в заполняемом Приказе, цена =" ub.price-list.price-sale skip
                  "Продолжать?"
                  view-as alert-box question buttons ok-cancel update g#log.
          if not g#log then  do:
             undo, return error.
             end.
        end.
  end.
end.
else do:
  run cre-pr-list in this-procedure (input  bc,
                   input  p-doc.doc-num,
                   output line-rec) no-error.
  if error-status :error then do:
    undo, return error.
    end.
   new-pr-recid = line-rec.
end.
end procedure.
procedure pro-list :
def input param fnc as char no-undo.
define variable l-c as integer no-undo.
run waitfram-show in this-procedure ("ЖДИТЕ.  Заполняется список...").
l-c = 0.
if fnc = "b-add" then do:
  if calc-method = 'Накладная':U or
     calc-method = 'НсП+накл':U or
     calc-method = 'Накл-безНДС':U then do:
    for each ub.doc-line no-lock where
             ub.doc-line.doc-code = doc-code,
        each ub.goods no-lock where
             ub.goods.artic = ub.doc-line.artic and
             ub.goods.prod-type = ub.doc-line.prod-type and
             ub.goods.prod-code = ub.doc-line.prod-code:
      l-c = l-c + 1.
      if l-c modulo 25 = 0 then
        run waitfram-show in this-procedure ("Заполнено строк по накладной : " + string (l-c)).
define variable vss-include-info119 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = goods.prod-type
    and gds-list.prod-code = goods.prod-code
    and gds-list.artic     = goods.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last119 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last119 = gds-list.order-num .
  end.
  else do:
    v-last119 = 0 .
  end.
  create gds-list .
  buffer-copy goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last119 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
      process events.
    end.
  end.
  if calc-method = 'Переоценка':U then do:
    for  each prev-list no-lock where
              prev-list.doc-num = doc-code,
         each ub.goods no-lock where
              ub.goods.artic = prev-list.artic and
              ub.goods.prod-type = prev-list.prod-type and
              ub.goods.prod-code = prev-list.prod-code:
      l-c = l-c + 1.
      if l-c modulo 25 = 0 then
        run waitfram-show in this-procedure ( "Заполнено строк по переоценке : " + string (l-c) ).
define variable vss-include-info120 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = goods.prod-type
    and gds-list.prod-code = goods.prod-code
    and gds-list.artic     = goods.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last120 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last120 = gds-list.order-num .
  end.
  else do:
    v-last120 = 0 .
  end.
  create gds-list .
  buffer-copy goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last120 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
      process events.
    end.
  end.
end.
else do:
  for each ub.price-list where
           ub.price-list.doc-num    = p-doc.doc-num and
           ub.price-list.main-price = yes,
      each ub.goods no-lock where
           ub.goods.artic     = ub.price-list.artic and
           ub.goods.prod-type = ub.price-list.prod-type and
           ub.goods.prod-code = ub.price-list.prod-code:
    l-c = l-c + 1.
    if l-c modulo 25 = 0 then
      run waitfram-show in this-procedure ("ЖДИТЕ.  Документ переносится в список : " + string (l-c)).
define variable vss-include-info121 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = goods.prod-type
    and gds-list.prod-code = goods.prod-code
    and gds-list.artic     = goods.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last121 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last121 = gds-list.order-num .
  end.
  else do:
    v-last121 = 0 .
  end.
  create gds-list .
  buffer-copy goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last121 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
    ub.price-list.doc-qnty = 0.
    process events.
  end.
end.
for each gds-list where gds-list.to-del = yes:
  delete gds-list.
end.
run waitfram-hide in this-procedure .
if fnc <> "b-add" then
   run str/gds-list.w
       ( parParentProc, p-doc.host-code, p-doc.obj-type, p-doc.obj-code).
doc-rec = recid (p-doc).
g#log = yes.
case fnc :
  when "b-chg" then
    message "Рассчитать цены по всем строкам списка ?"
            "Вы уверены ?"
            view-as alert-box question buttons ok-cancel update g#log.
  when "b-del" then
    message "В документе будут только те строки, которые оставлены в списке."
            "Вы уверены ?"
            view-as alert-box question buttons ok-cancel update g#log.
end.
if not g#log then
  return.
run waitfram-show in this-procedure ("ЖДИТЕ.  Список переносится в документ...").
lns-cnt = 0.
for each  gds-list,
    first ub.gds-prt no-lock where
          ub.gds-prt.upper-code = gds-list.prt-root,
    first ub.bar-code no-lock where
          ub.bar-code.gds-code  = gds-list.gds-code and
          ub.bar-code.node-code = ub.gds-prt.node-code and
          ub.bar-code.in-code   = "" and
          ub.bar-code.part-code = "" and
          ub.bar-code.unit-cli  = gds-list.unit-base:
  lns-cnt = lns-cnt + 1.
  if lns-cnt modulo 25 = 0 then
    run waitfram-show in this-procedure ("ЖДИТЕ.  Переписано строк : " + string (lns-cnt)).
  if ( calc-method = 'Накладная':U or
       calc-method = 'НсП+накл':U or
       calc-method = 'Накл-безНДС':U or
       calc-method = 'Переоценка':U )
        and  fnc = "b-add" then do:
    run cre-line in this-procedure (ub.bar-code.b-code) no-error.
    if error-status:error then do:  next.  end.
  end.
  find ub.price-list where
       ub.price-list.doc-num    = p-doc.doc-num and
       ub.price-list.b-code     = ub.bar-code.b-code and
       ub.price-list.price-type = "" no-error .
  if available  ub.price-list then do:
    ub.price-list.doc-qnty = ?.
    if lookup (fnc, "b-chg,b-add") > 0 then do:
      define variable p-line-mode as character no-undo .
      p-line-mode = line-mode .
      line-mode = "calc":u.
      run calc-pr-list in this-procedure
                       (input ub.bar-code.b-code,
                        input p-doc.doc-num,
                        input calc-method,
                        input increase-pc,
                        input round-method,
                        input round-base,
                        input ? ,
                        input ? ,
                        input ? ,
                        input ? ,
                        output line-rec) no-error.
      if error-status:error then do:
        line-mode = p-line-mode .
        next.
        end.
      line-mode = p-line-mode .
    end.
  end.
  gds-list.to-del = yes.
  process events.
end.
if fnc = "b-del" then do:
  for each ub.price-list no-lock where
           ub.price-list.doc-num = p-doc.doc-num and
           ub.price-list.main-price = yes and
           ub.price-list.doc-qnty = 0:
    run del-pr-list in this-procedure
                     (input ub.price-list.b-code,
                      input p-doc.doc-num,
                      input round-method,
                      input round-base) no-error.
    if error-status :error then
      next.
  end.
end.
run open-br in this-procedure .
doc-rec = recid(p-doc) .
run waitfram-hide in this-procedure .
end procedure.
procedure ui-on :
doc-rec = recid (p-doc).
hide loc-art  in frame d-pr-doc.
hide loc-art loc-name loc-code in frame d-pr-doc.
loc-art = "".
enable a-n-c b-exit b-help br-list b-history b-notes b-arch b-alt with frame d-pr-doc.
frame d-pr-doc:title = if p-doc.status_ = 'акт':U then "Акт" else "Приказ".
frame d-pr-doc:title = frame d-pr-doc:title + " переоценки № " + p-doc.doc-num +
                            "  для " + p-doc.obj-type + " " + string (p-doc.obj-code) + "  от " +
                            string (p-doc.doc-date) + "      " + doc-mode.
run upd-disp-tot in this-procedure ("disp").
if doc-mode = 'ПРОСМОТР':U then do:
  assign
    ub.price-list.price-sale:read-only in browse br-list = yes
    ub.price-list.excise:read-only in browse br-list = yes
    .
  enable b-prev b-next with frame d-pr-doc.
  hide increase-pc calc-method round-method copy-type copy-code doc-code common-price  r-copy in frame d-pr-doc.
end.
else do:
  assign
    ub.price-list.price-sale:read-only in browse br-list = no
    ub.price-list.excise:read-only in browse br-list = no
    .
  if v-cntxp-doc-prt then
    enable b-special with frame d-pr-doc.
  display round-method increase-pc round-base with frame d-pr-doc.
  if input round-method = "" then do:
    round-method = 'Отключено':U.
    display round-method with frame d-pr-doc.
  end.
  if input calc-method = "" then do:
    calc-method = 'Отсутствует':U.
    display calc-method with frame d-pr-doc.
  end.
  enable b-add b-chg b-del round-method increase-pc calc-method b-calc with frame d-pr-doc.
  if lookup( input frame d-pr-doc round-method, 'Произвольно,Вверх,Коэффициент,9-99окончание':U ) > 0 then do:
    enable round-base with frame d-pr-doc.
    display round-base with frame d-pr-doc.
  end.
  else
    hide round-base in frame d-pr-doc.
  hide copy-type copy-code doc-code common-price r-copy in frame d-pr-doc.
  case calc-method :
    when 'Объект':U then do:
      enable copy-type copy-code r-copy with frame d-pr-doc.
      display copy-type copy-code with frame d-pr-doc.
    end.
    when 'Накладная':U or
    when 'Накл-безНДС':U or
    when 'НсП+накл':U or
    when 'Переоценка':U then do:
      enable doc-code r-copy with frame d-pr-doc.
      display doc-code with frame d-pr-doc.
    end.
    when 'Единая':U then do:
      enable common-price with frame d-pr-doc.
      display common-price with frame d-pr-doc.
    end.
  end case.
end.
if (calc-method = 'Накладная':U or
    calc-method = 'Накл-безНДС':U or
    calc-method = 'НсП+накл':U or
    calc-method = 'Переоценка':U) and
   doc-code = "" then
  apply "entry" to doc-code in frame d-pr-doc.
else do:
   if (calc-method = 'Единая':U ) then apply "entry" to common-price in frame d-pr-doc.
   else
      apply "entry" to br-list in frame d-pr-doc.
end.
end procedure.
procedure open-br :
define variable t-ret as logical no-undo .
define variable t1 as decimal no-undo .
  t1 = time.
 t-ret =  session:SET-WAIT-STATE("GENERAL") .
 open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code by ub.price-list.artic by ub.gds-prt.node-code .
      run value-changed-br-list in this-procedure .
      t-ret =  session:SET-WAIT-STATE("") .
end procedure.
procedure upd-disp-tot :
def input param mode as char no-undo.
if mode = "clear" then
  if s-new = ? then
    return.
  else
    p-doc.sale-base = ?.
assign
  s-new = p-doc.rest-sale + p-doc.sale-base
  s-old = p-doc.rest-sale
  pc-prev = (s-new / s-old - 1) * 100
  s-new-old = s-new - s-old
  pc-avrg = (s-new / p-doc.rest-base - 1) * 100
  op-avrg = (s-old / p-doc.rest-base - 1) * 100
  pc-op-avrg = pc-avrg - op-avrg
  pc-last = (s-new / p-doc.rest-last - 1) * 100
  op-last = (s-old / p-doc.rest-last - 1) * 100
  pc-op-last = pc-last - op-last
  .
  if pc-prev > 9999 then
    pc-prev = ?.
  if pc-avrg > 9999 then
    pc-avrg = ?.
  if op-avrg > 9999 then
   op-avrg = ?.
  if pc-op-avrg > 9999 then
   pc-op-avrg = ?.
  if pc-last > 9999 then
    pc-last = ?.
  if op-last > 9999 then
   op-last = ?.
  if pc-op-last > 9999 then
   pc-op-last = ?.
  if s-new-old > 9999999999 then
   s-new-old = ?.
disp s-new s-old s-new-old pc-prev pc-avrg op-avrg pc-op-avrg pc-last op-last pc-op-last
     with frame d-pr-doc no-error .
end procedure.
procedure upd-br-field:
define variable ff as logical no-undo .
define variable ff1 as logical init true no-undo .
define variable cur-dn as decimal no-undo .
define variable cur-pr as decimal no-undo .
define variable cur-rt as decimal no-undo .
define variable cur-ex as decimal no-undo .
define variable calc-rec as recid no-undo.
  find current ub.price-list.
  if decimal  (ub.price-list.price-sale :screen-value in browse br-list) <> ub.price-list.price-sale then do:
    assign
      ub.price-list.calc-method = 'Отсутствует':U
      ub.price-list.price-calc = ub.price-list.price-sale
      ub.price-list.price-sale = decimal  (ub.price-list.price-sale :screen-value in browse br-list)
      .
    run calc-pr-sub in this-procedure
                     (input  ub.price-list.b-code,
                      input  p-doc.doc-num,
                      input  calc-method,
                      input  increase-pc,
                      input  round-method,
                      input  round-base,
                      output calc-rec) no-error.
    if error-status :error then do:
      undo, return error.
      end.
    run upd-disp-tot in this-procedure ("clear").
  end.
if decimal  (ub.price-list.excise :screen-value in browse br-list) <> ub.price-list.excise then do:
    assign
    ub.price-list.excise     = decimal  (ub.price-list.excise     :screen-value in browse br-list)
    .
end.
if decimal  (ub.price-list.road-tax :screen-value in browse br-list) <> ub.price-list.road-tax then do:
       find first buff-goods no-lock where
            buff-goods.artic     = ub.price-list.artic and
            buff-goods.prod-type = ub.price-list.prod-type and
            buff-goods.prod-code = ub.price-list.prod-code
            no-error .
      if avail buff-goods then do:
              if hvrdtax( recid(buff-goods)) = false  then  do :
                 message "В товаре нет компонента цены '"   ub.price-list.road-tax:label  "' ,  изменять нельзя ! " .
                 ub.price-list.road-tax   = ub.price-list.road-tax.
              end.
              else do:
                  define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info122 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.price-list.obj-type
  ,input  ub.price-list.obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info123 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_update':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  ub.price-list.obj-type
    ,input  ub.price-list.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output ff
    )  .
end.
                    if not ff
                    then do:
                      assign
                        ub.price-list.road-tax   = ub.price-list.road-tax
                      .
                    end.
                    else do :
                      assign
                        ub.price-list.road-tax = dec(ub.price-list.road-tax:screen-value in browse br-list)
                      .
                    end.
              end.
            end.
       end.
end procedure.
procedure add-spec-proc:
def input param bas-mode as char no-undo.
define variable vss-include-info124 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_properties':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if not g#log then return .
define variable rec-list as char no-undo.
define variable num-rec as integer no-undo.
if input frame d-pr-doc increase-pc < - 100 then do:
  message "Наценка не может быть меньше - 100 % !"
          view-as alert-box error.
  apply "entry" to br-list in frame d-pr-doc.
  return no-apply.
end.
if not available ub.price-list or
   ub.gds-prt.upper-code <> ub.goods.prt-root then do:
  message "Неправильно выбрана строка. Должна быть указана главная цена."
          view-as alert-box error.
  return no-apply.
end.
run ref/bas-cds.w (parParentProc, v-cntxt-obj-type, v-cntxt-obj-code, bas-mode, ub.bar-code.gds-code, output rec-list).
apply "entry" to br-list in frame d-pr-doc.
if rec-list = '' then
  return no-apply.
define variable v-11 as integer   no-undo .
v-11 = num-entries (rec-list) .
do num-rec = 1 to v-11 :
  ref-rec = integer (entry (num-rec, rec-list)).
  find ub.bar-code where
       recid (ub.bar-code) = ref-rec no-lock.
  if avail ub.bar-code  and ub.bar-code.part-code = "" and  ub.bar-code.in-code = "" then do:
     run cre-line in this-procedure  (ub.bar-code.b-code) no-error .
      if error-status:error then   next.
  run calc-pr-list in this-procedure
                   (input ub.bar-code.b-code,
                    input p-doc.doc-num,
                    input calc-method,
                    input increase-pc,
                    input round-method,
                    input round-base,
                    input ? ,
                    input ? ,
                    input ? ,
                    input ? ,
                    output line-rec) no-error.
  if error-status:error then do:   next. end.
    if calc-method = 'Отсутствует':U and
      line-mode = 'ПРОСМОТР':U then
    leave.
end.
end.
run upd-disp-tot in this-procedure ("clear").
doc-mode = 'ИЗМЕНЕНИЕ':U.
run open-br in this-procedure .
end procedure.
procedure value-changed-br-list :
define variable rt-old like ub.price-list.road-tax no-undo.
define variable ex-old like ub.price-list.excise   no-undo.
define variable dn-old like ub.price-list.doc-num  no-undo.
if not available ub.price-list then
  return.
if p-doc.status_ = 'акт':U then do:
define variable vss-include-info125 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  ub.price-list.obj-type
  ,input  ub.price-list.obj-code
  ,input  ub.price-list.b-code
  ,input  0
  ,input  ub.price-list.fact-order
  ,output dn-old
  ,output p-old
  ,output rt-old
  ,output ex-old
  )  .
end.
else do:
define variable vss-include-info126 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  ub.price-list.obj-type
  ,input  ub.price-list.obj-code
  ,input  ub.price-list.b-code
  ,input  0
  ,input  0
  ,output dn-old
  ,output p-old
  ,output rt-old
  ,output ex-old
  )  .
end.
disp dn-old @ prev-list.doc-num
     with frame d-pr-doc.
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = p-doc.obj-type and
     ub.gds-obj.obj-code = p-doc.obj-code no-error.
if available ub.gds-obj then
  if ub.goods.gds-type = 'т':U then
    assign
      p-avrg-fact = func-cost-price (ub.price-list.b-code , ub.gds-obj.gds-code , p-doc.status_ , var-pr-r-b)
      p-avrg = if var-pr-r-b = "rubl" then  ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base
      p-last = if var-pr-r-b = "rubl" then  ub.gds-obj.last-rubl else ub.gds-obj.last-base
      obj-in-code = ub.gds-obj.in-code
      obj-in-date = ub.gds-obj.in-date
      .
  else
    assign
      p-avrg-fact = func-cost-price (ub.price-list.b-code , ub.gds-obj.gds-code , p-doc.status_ , var-pr-r-b)
      p-avrg = if var-pr-r-b = "rubl" then  ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base
      p-last = ?
      obj-in-code = ?
      obj-in-date = ?
      .
else
  assign
    p-avrg-fact = ?
    p-avrg      = ?
    p-last      = ?
    obj-in-code = ?
    obj-in-date = ?
    .
assign
  p-new = ub.price-list.price-sale
  p-pc-prev = (p-new / p-old  - 1) * 100
  p-op-avrg = (p-old / p-avrg - 1) * 100
  p-pc-avrg = (p-new / p-avrg - 1) * 100
  p-op-avrg-fact = (p-old / p-avrg-fact - 1) * 100
  p-pc-avrg-fact = (p-new / p-avrg-fact - 1) * 100
  p-op-last = (p-old / p-last - 1) * 100
  p-pc-last = (p-new / p-last - 1) * 100
  p-pc-op-avrg-fact = p-pc-avrg-fact - p-op-avrg-fact
  p-pc-op-avrg = p-pc-avrg - p-op-avrg
  p-pc-op-last = p-pc-last - p-op-last
  p-calc-metod = ub.price-list.calc-method
  .
  if p-pc-prev > 9999 then
    p-pc-prev = ?.
  if p-pc-avrg > 9999 then
    p-pc-avrg = ?.
  if p-op-avrg > 9999 then
    p-op-avrg = ?.
  if p-pc-avrg-fact > 9999 then
    p-pc-avrg-fact = ?.
  if p-op-avrg-fact > 9999 then
    p-op-avrg-fact = ?.
  if p-pc-last > 9999 then
    p-pc-last = ?.
  if p-op-last > 9999 then
    p-op-last = ?.
  if   p-pc-op-avrg > 9999 then
    p-pc-op-avrg = ?.
  if   p-pc-op-avrg-fact > 9999 then
    p-pc-op-avrg-fact = ?.
  if p-pc-op-last > 9999 then
    p-pc-op-last = ?.
disp p-new p-old
    p-last obj-in-code obj-in-date    p-pc-op-last p-calc-metod
     p-pc-prev   p-op-last p-pc-last
     p-avrg
     p-op-avrg
     p-pc-avrg
     p-pc-op-avrg
     p-avrg-fact
     p-op-avrg-fact
     p-pc-avrg-fact
     p-pc-op-avrg-fact
     with frame d-pr-doc no-error .
 if not available ub.price-list or recid (ub.price-list) <> line-rec then do:
    hide loc-art in frame d-pr-doc.
    loc-art = "".
  end.
end procedure.
procedure ch-b-exit.
define output parameter p-err as logical no-undo .
p-err = false .
if doc-mode <> 'ПРОСМОТР':U then do:
doc-rec = recid(p-doc) no-error .
if error-status :error then  doc-rec =  ? .
  if can-find (first ub.price-list where ub.price-list.doc-num = p-doc.doc-num
                                  and ub.price-list.price-sale = ? no-lock) then do:
    g#log = no.
    message "В документе есть нерассчитанные строки. Удалить их ?"
            view-as alert-box question buttons yes-no update g#log.
            if g#log then do:
                      for each ub.price-list no-lock  where
                               ub.price-list.doc-num = p-doc.doc-num and
                               ub.price-list.price-sale = ? :
                        run del-pr-list in this-procedure
                                       (input ub.price-list.b-code,
                                        input p-doc.doc-num,
                                        input round-method,
                                        input round-base) no-error.
                        if error-status :error then do:
                          message  vss-workfile vss-revision vss-description skip
                          "Ошибка при удалении строки переоценки " skip
                          p-doc.doc-num
                          ub.price-list.b-code
                          skip
                          error-status :get-message(1) view-as alert-box error  .
                          undo, return error .
                          end.
                      end.
              p-doc.rest-qnty = ?.
            end.
  end.
  run ver-pr-equ-dq in this-procedure ( input p-doc.doc-num, input 1, input "" ) no-error .
  if error-status :error then do:
        message  vss-workfile vss-revision vss-description skip
            "Ошибка при удалении строки переоценки " skip
            p-doc.doc-num  skip
            error-status :get-message(1) view-as alert-box information .
            undo, return error .
  end.
  if doc-code <> "" and par-pr-discm = 'sale-' then do:
     p-doc.out-code = doc-code .
  end.
  run ver-pr-discn in this-procedure ( input "",  input p-doc.doc-num ,input p-doc.out-code , output p-err ) no-error .
  if error-status :error then
     message "Ошибка при проверки процента наценки!"
     view-as alert-box question
     buttons yes-no
     update v-qqq
     .
     if v-qqq then p-err = true .
     else  p-err = false .
  if not can-find (first ub.price-list where ub.price-list.doc-num = p-doc.doc-num no-lock) then do:
    message "В документе нет ни одной строки. Удалять его ?"
            view-as alert-box question buttons yes-no update g#log.
    if g#log then do:
       delete p-doc.
       doc-rec = ? .
    end.
  end.
end.
next-prev = ?.
end procedure.
 procedure ver-conf :
 define variable l-par as logical   no-undo .
   run chec-par in this-procedure (
         output l-par
        ,input  v-cntxt-host-code-obj
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
      ) no-error .
  assign
    increase-pc  = decimal (par-pr-incpc)
    round-method = par-pr-rndmt
    round-base   = decimal (par-pr-rndbs)
    no-error.
  case par-pr-rndmt:
    when "pr-round-9end" then
      round-method = '9-окончание':U.
    when "pr-round-9-99end" then
      round-method = '9-99окончание':U.
    when "pr-round-integer" then
      round-method = 'Без-дробных':U.
    when "pr-round-select" then
      round-method = 'Произвольно':U.
    when "pr-round-up" then
      round-method = 'Вверх':U.
    when "pr-round-coef" then
      round-method = 'Коэффициент':U.
    when "pr-round-off" then
      round-method = 'Отключено':U.
    otherwise
      round-method = 'Отключено':U.
  end case.
  end procedure.
procedure  cre-line-temp :
define input parameter p-mode as character no-undo .
define input parameter p-gds-code  like ub.bar-code.gds-code    no-undo .
define input parameter p-node-code like ub.bar-code.node-code   no-undo .
if p-mode = "gds-list":u then do:
  for each temp-gds-list : delete temp-gds-list. end.
  for each gds-list no-lock where by  recid(gds-list) :
      find  first ub.gds-prt no-lock where
                ub.gds-prt.upper-code = gds-list.prt-root no-error .
      find  first ub.bar-code no-lock where
                ub.bar-code.gds-code  = gds-list.gds-code and
                ub.bar-code.node-code = ub.gds-prt.node-code and
                ub.bar-code.in-code   = "" and
                ub.bar-code.part-code = "" and
                ub.bar-code.unit-cli  = gds-list.unit-base
                no-error .
    if avail ub.bar-code  and avail ub.gds-prt then do :
        create temp-gds-list.
        assign
            v-n-n = v-n-n + 1
            temp-gds-list.gds-code  = ub.bar-code.gds-code
            temp-gds-list.node-code = ub.bar-code.node-code
            temp-gds-list.n-n = v-n-n.
    end.
  end.
end.
if p-mode = "one":u then do:
    create temp-gds-list.
    assign
        v-n-n = v-n-n + 1
        temp-gds-list.gds-code  = p-gds-code
        temp-gds-list.node-code = p-node-code
        temp-gds-list.n-n = v-n-n.
end.
end procedure.
def var vss-include-info127 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure add-price-line :
find current p-doc no-error .
if error-status:error then return no-apply.
assign
  line-mode = 'ДОБАВЛЕНИЕ':U
  notes = ''
  lns-cnt = 1.
for each gds-list :
   delete gds-list.
end.
if NOT ( calc-method = 'Накладная':U or
      calc-method = 'Накл-безНДС':U or
      calc-method = 'НсП+накл':U or
      calc-method = 'Переоценка':U )
Then do:
    run str/chsgdsls.w (
        parParentProc ,
        input "price-list" ,
        input "Строка пер. № " + p-doc.doc-num + " " + p-doc.status_  , ? , ? ,
        input p-doc.host-code,
        input-output varschartic,
        output ref-list,
        output table tt-gds-list, false ) no-error.
end.
assign lns-cnt = 0.
run cycle-add in this-procedure .
run ui-on in this-procedure .
end procedure.
procedure cycle-add:
define buffer ggg_price-list  for ub.price-list .
define variable stp-cycl as logical no-undo .
stp-cycl = false .
for each tt-gds-list no-lock  by tt-gds-list.nn :
  lns-cnt  =  lns-cnt + 1 .
  if lns-cnt > 1 then assign line-mode = "ЦИКЛ":u.
  find ub.goods where ub.goods.gds-code = tt-gds-list.gds-code no-lock.
  find ub.gds-prt where ub.gds-prt.upper-code = ub.goods.prt-root no-lock.
  find ub.bar-code no-lock where
       ub.bar-code.gds-code  = ub.goods.gds-code and
       ub.bar-code.node-code = ub.gds-prt.node-code and
       ub.bar-code.part-code = "" and
       ub.bar-code.in-code   = "" and
       ub.bar-code.unit-cli  = ub.goods.unit-base.
  run cre-line in this-procedure (ub.bar-code.b-code) no-error.
  if error-status:error then do:   next.     end.
  doc-rec = recid(p-doc) .
  find first ggg_price-list where recid(GGG_price-list) =  new-pr-recid  no-lock no-error .
   if error-status :error then next .
  if avail ggg_price-list then do :
  run calc-pr-list in this-procedure (input ub.bar-code.b-code,
                    input p-doc.doc-num,
                    input calc-method,
                    input increase-pc,
                    input round-method,
                    input round-base,
                    input ? ,
                    input ? ,
                    input ? ,
                    input ? ,
                    output line-rec) no-error.
             if error-status:error then   next.
  end.
  if  ( calc-method = 'Отсутствует':U
        or
      ( calc-method <> 'Отсутствует':U
        and ggg_price-list.price-sale = ?
        and calc-method <> 'Не-считать':U  ))
      then do:
        run str/pr-form.w (
                      input  parParentProc ,
                      input  line-mode   ,
                      input  doc-rec    ,
                      input  new-pr-recid ,
                      input increase-pc ,
                      input round-method,
                      input round-base,
                      input calc-method,
                      output stp-cycl ) no-error .
                      if error-status :error then message error-status :error error-status :get-message(1) 111.
                      if return-value = "error" then do:
                                  find first ggg_price-list where recid(ggg_price-list) = new-pr-recid no-error .
                                  if avail ggg_price-list then
                                     run del-pr-list in this-procedure ( input ggg_price-list.b-code,
                                                        input ggg_price-list.doc-num,
                                                        input round-method,
                                                        input round-base) no-error.
                      end.
        find p-doc where recid(p-doc) = doc-rec no-error .
        if  stp-cycl = true then leave.
  end.
  assign lns-cnt = lns-cnt + 1 .
end.
end procedure.
procedure cr-button :
 do
 on error undo, return error return-value
 :
define variable  but1  as widget-handle.
   create button but1
   assign
      row = 1
      column = 53
      HEIGHT-CHARS = 1
      WIDTH-CHARS = 8
      label = "СортПН"
      tooltip = "Сортировка по порядку ввода накладной"
      frame = frame d-pr-doc:handle
      sensitive = true
      visible = true
        triggers:
          on choose persistent run op.
        end triggers.
 end.
end procedure.
procedure op :
 do
 on error undo, return error return-value
 :
define buffer temp-doc-line   for ub.doc-line .
define buffer temp-price-list for ub.price-list .
define variable number-trn-doc as character no-undo .
define variable t-ok as logical no-undo .
 number-trn-doc  = p-doc.out-code .
 if number-trn-doc = "" or number-trn-doc = ? then do:
    message "Невозможно определить номер ПН для сортировки товаров !!! " .
    return.
    end.
 t-ok = true .
 message "Хотите отсортировать переоценку по порядку ввода накладной № " number-trn-doc
         " ?" view-as alert-box question  buttons yes-no update t-ok .
 if t-ok = false then return.
define variable n-num as integer no-undo .
n-num = 0 .
for each temp-doc-line no-lock where temp-doc-line.doc-code = number-trn-doc by temp-doc-line.line-num :
    for each  temp-price-list  exclusive-lock
                    where temp-price-list.doc-num    = p-doc.doc-num and
                          temp-price-list.price-type = "" and
                          temp-price-list.artic = temp-doc-line.artic and
                          temp-price-list.prod-type = temp-doc-line.prod-type and
                          temp-price-list.prod-code = temp-doc-line.prod-code
                          by temp-price-list.main-price DESCENDIN
                          by temp-price-list.b-code
                          :
        n-num = n-num + 1 .
        assign
          temp-price-list.line-num  = n-num
        .
    end.
end.
 open query br-list         for each ub.price-list no-lock where                  ub.price-list.doc-num = p-doc.doc-num and                  ub.price-list.price-type = '',             each ub.bar-code no-lock where                  ub.bar-code.b-code = ub.price-list.b-code,             each ub.goods no-lock where                  ub.goods.gds-code = ub.bar-code.gds-code and                  ub.goods.unit-base = ub.bar-code.unit-cli,             each ub.gds-prt no-lock where                  ub.gds-prt.node-code = ub.bar-code.node-code
            by ub.price-list.line-num .
run value-changed-br-list.
 end.
end procedure.
procedure run-help :
 do
 on error undo, return error return-value
 :
 define variable v-message-text as character no-undo .
 define variable t-m  as character no-undo .
case calc-method :
  when 'Учетная':U then  assign  t-m =
   chr(10) + "для товара: средняя учетная цена товара на фирме                                " +
   chr(10) + "            (с учетом товара зарезервированного за незакрытыми документами)     " +
   chr(10) + "для услуги: учетная цена услуги на фирме неопределена                           "
  .
  when  'Учет-объект':U  then  assign  t-m =
   chr(10) + "для товара: средняя учетная цена товара на объекте                               " +
   chr(10) + "            (c учетом товара зарезервированного                                  " +
   chr(10) + "            за незакрытыми документами -                                         " +
   chr(10) + "             и партии свободной зоны, и резерв документов)                       " +
   chr(10) + "для услуги: возвращается учетная цена по объекту                                 "
  .
  when 'Учет-резерв':U     then  assign  t-m =
   chr(10) + "для товара: средняя учетная цена товара на объекте                                " +
   chr(10) + "            (без учета товара зарезервированного                                  " +
   chr(10) + "            за незакрытыми документами - только партии свободной зоны)            " +
   chr(10) + "для услуги: возвращается учетная цена по объекту                                  "
  .
  when 'Приходная':U     then  assign  t-m =
   chr(10) + "для товара: цену последнего прихода по фирме                                       " +
   chr(10) + "для услуги: цена последнего прихода услуги по фирме не определена                  "
  .
  when 'Прих-объект':U  then  assign  t-m =
   chr(10) + "для товара: цену последнего прихода по объекту                                     " +
   chr(10) + "для услуги: цена последнего прихода услуги по объекту не определена                "
  .
     otherwise do:
        assign  t-m =  "МЕТОД НЕ ОПИСАН !!!!"       .
     end.
end case.
 v-message-text ="Название метода :  -" + calc-method + "-" + chr(10) +
 "Описание : " + chr(10)   + t-m
   .
 run gbl/d-prompt.w (
    'title=Описание метода расчета\'
  + 'type=editor\'
  + 'fillin_width=96\'
  + 'fillin_height=15\'
  + 'readonly=yes\'
  , input-output v-message-text).
 end.
end procedure.
procedure proc-cost-price-fact :
 do
 on error undo, return error return-value
 :
define input parameter  p-bar-code as integer   no-undo .
define input parameter  p-gds-code as integer   no-undo .
define input parameter  p-status_  as character no-undo .
define input parameter  p-r-b      as character no-undo .
define output parameter par-summa  as decimal   no-undo .
define variable v-total-avrg-base  as decimal no-undo .
define variable v-total-avrg-rubl  as decimal no-undo .
define variable v-total-avrg-qnty  as decimal no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_parts for ub.parts.
define variable p-price-base as decimal no-undo .
define variable p-price-rubl as decimal no-undo .
find first buf_goods no-lock where
           buf_goods.gds-code = p-gds-code no-error .
 if p-status_ <> 'акт':U then do:
      for each buf_parts no-lock
        where  buf_parts.obj-type  = p-doc.obj-type
          and buf_parts.obj-code   = p-doc.obj-code
          and buf_parts.artic      = buf_goods.artic
          and buf_parts.prod-type  = buf_goods.prod-type
          and buf_parts.prod-code  = buf_goods.prod-code
          and buf_parts.status_    = no
          and ( buf_parts.out-code  = 'free-zone':U )
      on error undo, return error
      :
        assign
          v-total-avrg-base = v-total-avrg-base
                            + (buf_parts.price-base * buf_parts.qnty)
          v-total-avrg-rubl = v-total-avrg-rubl
                            + (buf_parts.price-rubl * buf_parts.qnty)
          v-total-avrg-qnty = v-total-avrg-qnty
                            + buf_parts.qnty
        .
      end.
      if v-total-avrg-qnty > 0 then do:
        assign
          p-price-base = ( v-total-avrg-base / v-total-avrg-qnty )
          p-price-rubl = ( v-total-avrg-rubl / v-total-avrg-qnty )
        .
      end.
      else do:
        assign
          p-price-base = ?
          p-price-rubl = ?
        .
      end.
 end.
 else do:
 define variable p-attr-value as character no-undo .
       run view-price-list-attr in this-procedure (
            input   'cost-price-fact':U  ,
            input   p-bar-code          ,
            input   p-doc.doc-num       ,
            input   ""                  ,
            output  p-attr-value   )
            .
           if not ( p-attr-value = ? or p-attr-value = "" )  then
              assign
                p-price-rubl = decimal(p-attr-value)
                p-price-base = decimal(p-attr-value)
              .
 end.
 if p-r-b = "rubl":u then
    par-summa = p-price-rubl.
    else
    par-summa = p-price-base.
 end.
end procedure.
