using ibs.th.str.ptrl.*.
DEFINE BUFFER buf-obj_clients FOR ub.clients.
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER buf_place FOR ub.place.
DEFINE BUFFER buf_rvs-line FOR ub.rvs-line.
DEFINE TEMP-TABLE loc-t-doc-pl NO-UNDO
field pl-code as integer format "99999999999"
field whole-send-news like ub.doc-pl.whole-send-news
field obj-type like ub.doc-pl.obj-type
field obj-code like ub.doc-pl.obj-code
field out-code like ub.doc-pl.out-code
field fact-qnty like ub.doc-pl.fact-qnty
field doc-qnty like ub.doc-pl.doc-qnty
field gds-code like ub.doc-pl.gds-code
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
DEFINE SHARED TEMP-TABLE tt-doc-pl NO-UNDO
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
define input  parameter parparentproc               as   widget-handle              no-undo .
define input  parameter p-mode                      as   character                  no-undo .
define input  parameter p-upd-field                 as   character                  no-undo .
define input  parameter p-upd-units                 as   character                  no-undo .
define input  parameter p-doc-code                  like ub.trn-doc.doc-code        no-undo .
define input  parameter p-gds-code                  like ub.goods.gds-code          no-undo .
define input  parameter p-pl-code                   as   integer                    no-undo .
define input  parameter p-doc-line-unit-cli         like ub.doc-line.unit-cli       no-undo .
define input  parameter p-doc-line-cli-base-rate    like ub.doc-line.cli-base-rate  no-undo .
define input  parameter p-doc-line-doc-density      like ub.doc-line.doc-density    no-undo .
define input  parameter p-doc-line-fact-density     like ub.doc-line.fact-density   no-undo .
define input  parameter p-doc-line-cli-qnty         like ub.doc-line.cli-qnty       no-undo .
define input  parameter p-doc-line-doc-qnty         like ub.doc-line.doc-qnty       no-undo .
define input  parameter p-doc-line-fact-qnty        like ub.doc-line.fact-qnty      no-undo .
define input  parameter p-doc-line-doc-cli-qnty     like ub.doc-line.doc-qnty       no-undo .
define input  parameter p-doc-line-fact-cli-qnty    like ub.doc-line.fact-qnty      no-undo .
define input  parameter p-doc-line-rest-density     like ub.doc-line.fact-density   no-undo .
define input  parameter p-doc-line-rest-af-qnty     like ub.doc-pl.rest-af-qnty     no-undo .
define input  parameter p-doc-line-cli-rest-af-qnty like ub.doc-pl.cli-rest-af-qnty no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Складское место с товарами с указанием количеств":U .
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
  function valid-density returns logical ( input p-density as decimal, input p-unit-base-cli-eq as logical ) :
    define variable v-answ as logical no-undo .
    if ( p-unit-base-cli-eq = true
         and p-density = 1.0
       )
      or ( p-unit-base-cli-eq = false
           and p-density <> ?
           and p-density > 0.0
           and p-density < 1.0
         )
    then do:
      assign
        v-answ = true
      .
    end.
    else do:
      assign
        v-answ = false
      .
    end.
    return v-answ.
  end function.
define buffer buf_trn-doc       for ub.trn-doc .
define buffer buf-upd_tt-doc-pl for tt-doc-pl .
define variable v-is-ptrl as character no-undo .
define variable v-msg-on  as logical   no-undo .
define variable v-is-add  as logical   no-undo .
define variable rvsinvObj as class rvsinvsub no-undo .
DEFINE BUTTON b-exit AUTO-GO DEFAULT
     LABEL "&Ввод "
     SIZE 10 BY 1.
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON b-place
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-qnty DEFAULT
     LABEL "Уст.Кол-ва"
     SIZE 11 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE VARIABLE f-doc-line-cli-doc-qnty LIKE ub.doc-line.cli-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-cli-fact-qnty LIKE ub.doc-line.cli-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-cli-qnty LIKE ub.doc-line.cli-qnty
     LABEL "по ТТН"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-lblpolnebal as character init "Положительный небаланс  :" format "x(30)"
     VIEW-AS FILL-IN
     SIZE 30 BY 1 NO-UNDO.
DEFINE VARIABLE f-lblotrnebal as character init "Отрицательный небаланс  :" format "x(30)"
     VIEW-AS FILL-IN
     SIZE 30 BY 1 NO-UNDO.
DEFINE VARIABLE f-lblnebal as character init "Небаланс,кг" format "x(13)"
     VIEW-AS FILL-IN
     SIZE 13 BY 1
     bgcolor 8
     NO-UNDO.
DEFINE VARIABLE f-polnebal as decimal INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 fgcolor 4 NO-UNDO.
DEFINE VARIABLE f-otrnebal as decimal INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1
     fgcolor 4
     NO-UNDO.
DEFINE VARIABLE f-lblmetrerr as character init "Погр.изм.,кг" format "x(14)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     bgcolor 8
     NO-UNDO.
DEFINE VARIABLE f-polmetrerr as decimal  INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 fgcolor 4 NO-UNDO.
DEFINE VARIABLE f-otrmetrerr as decimal  INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1
     fgcolor 4
     NO-UNDO.
DEFINE VARIABLE f-lblwastcli as character init "Масса ЕУ,кг" format "x(14)"
     VIEW-AS FILL-IN
     SIZE 13 BY 1
     bgcolor 8
     NO-UNDO.
DEFINE VARIABLE f-wastcli as decimal  INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 fgcolor 4 NO-UNDO.
DEFINE VARIABLE f-lblwast-tp as character init "Масса ТП,кг" format "x(14)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     bgcolor 8
     NO-UNDO.
DEFINE VARIABLE f-wast-tp as decimal  INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 fgcolor 4 NO-UNDO.
DEFINE VARIABLE f-lbldiff as character init "Излиш./Недост.,кг" format "x(20)"
     VIEW-AS FILL-IN
     SIZE 20 BY 1
     bgcolor 8
     NO-UNDO.
DEFINE VARIABLE f-izlish as decimal  INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 fgcolor 4 NO-UNDO.
DEFINE VARIABLE f-nedos as decimal  INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1
     fgcolor 4
     NO-UNDO.
DEFINE VARIABLE f-doc-line-cli-rest-af-qnty LIKE ub.inv-line.after-cli-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-doc-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-doc-qnty LIKE ub.doc-line.doc-qnty
     LABEL "Заявлено"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-fact-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-fact-qnty LIKE ub.doc-line.fact-qnty
     LABEL "Фактически"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-rest-af-qnty LIKE ub.doc-line.cli-qnty
     LABEL "Стало"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-rest-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-pl-doc-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-pl-fact-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-pl-rest-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE f-label-density AS CHARACTER FORMAT "x(25)":U INITIAL "Плотность"
     VIEW-AS FILL-IN
     SIZE 10.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-prod-name AS CHARACTER FORMAT "x(45)"
     VIEW-AS FILL-IN
     SIZE 46.5 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE f-rvs-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE f-rvs-measure-cli-qnty LIKE ub.rvs-line.measure-cli-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-rvs-measure-qnty LIKE ub.rvs-line.measure-qnty
     LABEL "Измерено"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-rvs-state-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE f-rvs-state-measure-cli-qnty LIKE ub.rvs-line.state-measure-cli-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-rvs-state-measure-qnty LIKE ub.rvs-line.state-measure-qnty
     LABEL "Фактически"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-tot-doc-label AS CHARACTER FORMAT "X(256)":U INITIAL "Итого по строке документа:"
      VIEW-AS TEXT
     SIZE 27.5 BY .67 NO-UNDO.
DEFINE VARIABLE f-tot-doc-pl-cli-doc-qnty LIKE ub.doc-pl.cli-doc-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-tot-doc-pl-cli-fact-qnty LIKE ub.doc-pl.cli-fact-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-tot-doc-pl-cli-qnty LIKE ub.doc-pl.cli-qnty
     LABEL "по ТТН"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-tot-doc-pl-cli-rest-af-qnty LIKE ub.doc-pl.cli-rest-af-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-tot-doc-pl-doc-qnty LIKE ub.doc-pl.doc-qnty
     LABEL "Заявлено"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-tot-doc-pl-fact-qnty LIKE ub.doc-pl.fact-qnty
     LABEL "Фактически"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-tot-doc-pl-rest-af-qnty LIKE ub.doc-pl.rest-af-qnty
     LABEL "Стало"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-tot-doc-pl-rest-density AS DECIMAL FORMAT "->>9.9999999999" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE f-units-base LIKE ub.goods.unit-base
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE f-units-cli LIKE ub.goods.unit-base
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE v-label-rvs AS CHARACTER FORMAT "x(25)":U INITIAL "По сверкам:"
     VIEW-AS FILL-IN
     SIZE 26 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 97 BY 2.75.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 97 BY 7.
DEFINE RECTANGLE rect-tot
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 97 BY 7.
DEFINE FRAME f-doc-pl
     b-exit AT ROW 1 COL 2 WIDGET-ID 6
     b-quit AT ROW 1 COL 12 WIDGET-ID 18
     b-qnty AT ROW 1 COL 22 WIDGET-ID 16
     b-help AT ROW 1 COL 89 WIDGET-ID 8
     loc-t-doc-pl.pl-code AT ROW 2.5 COL 16 COLON-ALIGNED WIDGET-ID 68 FORMAT "99999999999"
          LABEL "Место хранения"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     b-place AT ROW 2.5 COL 29.5 WIDGET-ID 14
     buf_place.pl-name AT ROW 2.5 COL 30.5 COLON-ALIGNED NO-LABEL WIDGET-ID 70 FORMAT "X(66)"
          VIEW-AS FILL-IN
          SIZE 66 BY 1
          BGCOLOR 8
     buf-obj_clients.obj-type AT ROW 3.75 COL 16 COLON-ALIGNED WIDGET-ID 104
          LABEL "Объект"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     buf-obj_clients.obj-code AT ROW 3.75 COL 20.5 COLON-ALIGNED NO-LABEL WIDGET-ID 52
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     buf-obj_clients.obj-name AT ROW 3.75 COL 30.5 COLON-ALIGNED NO-LABEL WIDGET-ID 56 FORMAT "X(66)"
          VIEW-AS FILL-IN
          SIZE 66 BY 1
          BGCOLOR 8
     buf_place.loc1 AT ROW 5 COL 30 COLON-ALIGNED WIDGET-ID 44
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     buf_place.loc2 AT ROW 5 COL 49 COLON-ALIGNED WIDGET-ID 46
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     buf_place.loc3 AT ROW 5 COL 68 COLON-ALIGNED WIDGET-ID 48
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     buf_place.loc4 AT ROW 5 COL 88 COLON-ALIGNED WIDGET-ID 50
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     buf_goods.gds-code AT ROW 6.75 COL 10 COLON-ALIGNED WIDGET-ID 40 FORMAT "99999999999"
          LABEL "Товар"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     buf_goods.gds-name AT ROW 6.75 COL 20.5 COLON-ALIGNED NO-LABEL WIDGET-ID 42 FORMAT "X(74)"
          VIEW-AS FILL-IN
          SIZE 75.5 BY 1
          BGCOLOR 8
     buf_goods.artic AT ROW 8 COL 10 COLON-ALIGNED WIDGET-ID 4
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     buf_goods.prod-type AT ROW 8 COL 34.5 COLON-ALIGNED WIDGET-ID 106
          LABEL "Пр-ль"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     buf_goods.prod-code AT ROW 8 COL 39 COLON-ALIGNED NO-LABEL WIDGET-ID 72
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     f-prod-name AT ROW 8 COL 49.5 COLON-ALIGNED NO-LABEL WIDGET-ID 54
     f-units-base AT ROW 9.5 COL 45 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 168 FORMAT "X(5)"
     f-units-cli AT ROW 9.5 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 170 FORMAT "X(5)"
     f-label-density AT ROW 9.5 COL 82 NO-LABEL WIDGET-ID 172
     loc-t-doc-pl.cli-qnty AT ROW 10.75 COL 16 COLON-ALIGNED WIDGET-ID 180 FORMAT "->>,>>>,>>9.<<<"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     loc-t-doc-pl.doc-qnty AT ROW 10.75 COL 45 COLON-ALIGNED WIDGET-ID 26
          LABEL "Заявлено"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     loc-t-doc-pl.cli-doc-qnty AT ROW 10.75 COL 61.5 COLON-ALIGNED NO-LABEL WIDGET-ID 20
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     f-doc-pl-doc-density AT ROW 10.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 204
     loc-t-doc-pl.fact-qnty AT ROW 11.75 COL 45 COLON-ALIGNED WIDGET-ID 38
          LABEL "Фактически"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     loc-t-doc-pl.cli-fact-qnty AT ROW 11.75 COL 61.5 COLON-ALIGNED NO-LABEL WIDGET-ID 22
          VIEW-AS FILL-IN
          SIZE 16 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE  WIDGET-ID 100.
DEFINE FRAME f-doc-pl
     f-doc-pl-fact-density AT ROW 11.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 206
     loc-t-doc-pl.rest-af-qnty AT ROW 12.75 COL 45 COLON-ALIGNED WIDGET-ID 198
          LABEL "Стало"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     loc-t-doc-pl.cli-rest-af-qnty AT ROW 12.75 COL 61.5 COLON-ALIGNED NO-LABEL WIDGET-ID 196
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     f-doc-pl-rest-density AT ROW 12.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 208
     v-label-rvs AT ROW 13.75 COL 3 NO-LABEL WIDGET-ID 110
     f-rvs-measure-qnty AT ROW 13.75 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 34
          LABEL "Измерено"
     f-rvs-measure-cli-qnty AT ROW 13.75 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 32
     f-rvs-density AT ROW 13.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 176
     f-rvs-state-measure-qnty AT ROW 14.75 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 36
          LABEL "Фактически"
     f-rvs-state-measure-cli-qnty AT ROW 14.75 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 108
     f-rvs-state-density AT ROW 14.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 178
     f-tot-doc-pl-rest-af-qnty AT ROW 16.5 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 190
          LABEL "Стало"
     f-tot-doc-pl-cli-rest-af-qnty AT ROW 16.5 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 76
     f-tot-doc-pl-rest-density AT ROW 16.5 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 212
     f-tot-doc-pl-cli-qnty AT ROW 17.5 COL 16 COLON-ALIGNED HELP
          "" WIDGET-ID 186
          LABEL "по ТТН" FORMAT "->>,>>>,>>9.<<<"
     f-tot-doc-pl-doc-qnty AT ROW 17.5 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 156
          LABEL "Заявлено"
     f-tot-doc-pl-cli-doc-qnty AT ROW 17.5 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 152
     f-tot-doc-pl-fact-qnty AT ROW 18.5 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 158
          LABEL "Фактически"
     f-tot-doc-pl-cli-fact-qnty AT ROW 18.5 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 154
     f-doc-line-rest-af-qnty AT ROW 19.75 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 82
          LABEL "Стало"
     f-doc-line-cli-rest-af-qnty AT ROW 19.75 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 188
     f-doc-line-rest-density AT ROW 19.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 202
     f-doc-line-cli-qnty AT ROW 20.75 COL 16 COLON-ALIGNED HELP
          "" WIDGET-ID 144
          LABEL "по ТТН"
     f-doc-line-doc-qnty AT ROW 20.75 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 148
          LABEL "Заявлено"
     f-doc-line-cli-doc-qnty AT ROW 20.75 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 140
     f-doc-line-doc-density AT ROW 20.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     f-doc-line-fact-qnty AT ROW 21.75 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 150
          LABEL "Фактически"
     f-lblpolnebal AT ROW 18.5 COL 1 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-lblotrnebal AT ROW 19.5 COL 1 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-lblnebal AT ROW 17.5 COL 27 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-polnebal AT ROW 18.5 COL 27 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-otrnebal AT ROW 19.5 COL 27 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-lblmetrerr AT ROW 17.5 COL 39 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-polmetrerr AT ROW 18.5 COL 39 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-otrmetrerr AT ROW 19.5 COL 39 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-lblwastcli AT ROW 17.5 COL 52 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-wastcli AT ROW 19.5 COL 52 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-lblwast-tp AT ROW 17.5 COL 64 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-wast-tp AT ROW 19.5 COL 64 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-lbldiff AT ROW 17.5 COL 76 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-izlish AT ROW 18.5 COL 76 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-nedos AT ROW 19.5 COL 76 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-doc-line-cli-fact-qnty AT ROW 21.75 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 142
     f-doc-line-fact-density AT ROW 21.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 30
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE  WIDGET-ID 100.
DEFINE FRAME f-doc-pl
     f-tot-doc-label AT ROW 19.75 COL 3 NO-LABEL WIDGET-ID 210
     "Итого по местам хранения:" VIEW-AS TEXT
          SIZE 26 BY .67 AT ROW 16.5 COL 3 WIDGET-ID 174
     "По месту хранения:" VIEW-AS TEXT
          SIZE 19.5 BY .67 AT ROW 9.5 COL 3 WIDGET-ID 166
     RECT-1 AT ROW 6.5 COL 2 WIDGET-ID 78
     RECT-2 AT ROW 9.25 COL 2 WIDGET-ID 80
     rect-tot AT ROW 16.25 COL 2 WIDGET-ID 112
     SPACE(0.87) SKIP(0.80)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>" WIDGET-ID 100.
ASSIGN
       FRAME f-doc-pl:SCROLLABLE       = FALSE.
ASSIGN
       buf_goods.artic:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       b-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE.
ASSIGN
       loc-t-doc-pl.cli-doc-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE.
ASSIGN
       loc-t-doc-pl.cli-fact-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE.
ASSIGN
       loc-t-doc-pl.cli-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       loc-t-doc-pl.cli-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       loc-t-doc-pl.cli-rest-af-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE.
ASSIGN
       loc-t-doc-pl.doc-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE.
ASSIGN
       f-doc-line-cli-doc-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-cli-doc-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-doc-line-cli-fact-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-cli-fact-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-doc-line-cli-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-cli-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-lblpolnebal:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-lblpolnebal:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-lblotrnebal:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-lblotrnebal:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-lblnebal:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-lblnebal:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-polnebal:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-polnebal:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-otrnebal:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-otrnebal:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-lblwastcli:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-lblwastcli:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-wastcli:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-wastcli:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-lblmetrerr:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-lblmetrerr:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-polmetrerr:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-polmetrerr:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-otrmetrerr:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-otrmetrerr:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-lblwast-tp:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-lblwast-tp:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-wast-tp:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-wast-tp:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-lbldiff:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-lbldiff:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-izlish:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-izlish:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-nedos:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-nedos:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-doc-line-cli-rest-af-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-cli-rest-af-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-doc-line-doc-density:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-doc-density:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-doc-line-doc-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-doc-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-doc-line-fact-density:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-fact-density:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-doc-line-fact-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-fact-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-doc-line-rest-af-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-rest-af-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-doc-line-rest-density:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-rest-density:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-doc-pl-doc-density:HIDDEN IN FRAME f-doc-pl           = TRUE.
ASSIGN
       f-doc-pl-fact-density:HIDDEN IN FRAME f-doc-pl           = TRUE.
ASSIGN
       f-doc-pl-rest-density:HIDDEN IN FRAME f-doc-pl           = TRUE.
ASSIGN
       f-label-density:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-label-density:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-prod-name:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-rvs-density:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-rvs-density:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-rvs-measure-cli-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-rvs-measure-cli-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-rvs-measure-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-rvs-measure-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-rvs-state-density:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-rvs-state-density:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-rvs-state-measure-cli-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-rvs-state-measure-cli-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-rvs-state-measure-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-rvs-state-measure-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-label:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-label:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-pl-cli-doc-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-pl-cli-doc-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-pl-cli-fact-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-pl-cli-fact-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-pl-cli-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-pl-cli-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-pl-cli-rest-af-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-pl-cli-rest-af-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-pl-doc-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-pl-doc-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-pl-fact-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-pl-fact-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-pl-rest-af-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-pl-rest-af-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-pl-rest-density:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-pl-rest-density:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-units-base:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       f-units-cli:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-units-cli:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       loc-t-doc-pl.fact-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE.
ASSIGN
       buf_goods.gds-code:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       buf_goods.gds-name:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       buf_place.loc1:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       buf_place.loc2:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       buf_place.loc3:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       buf_place.loc4:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       buf-obj_clients.obj-code:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       buf-obj_clients.obj-name:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       buf-obj_clients.obj-type:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       buf_place.pl-name:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       buf_goods.prod-code:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       buf_goods.prod-type:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN
       loc-t-doc-pl.rest-af-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE.
ASSIGN
       v-label-rvs:HIDDEN IN FRAME f-doc-pl           = TRUE
       v-label-rvs:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ON WINDOW-CLOSE OF FRAME f-doc-pl
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME f-doc-pl
DO:
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-quit as logical   no-undo .
  apply "leave" to loc-t-doc-pl.pl-code in frame f-doc-pl.
  if loc-t-doc-pl.pl-code = ?
    or loc-t-doc-pl.pl-code = 0
  then do:
    message
      "Не указано место хранения." skip
      "Хотите выйти без сохранения?" skip
      view-as alert-box question buttons yes-no update v-quit.
    if v-quit = true then do:
      apply "choose" to b-quit in frame f-doc-pl.
    end.
    return no-apply.
  end.
  if p-upd-field = "rest":U
    or p-upd-field = "rest-fact":U
  then do:
    assign
      loc-t-doc-pl.doc-qnty     = loc-t-doc-pl.fact-qnty
      loc-t-doc-pl.cli-doc-qnty = loc-t-doc-pl.cli-fact-qnty
      loc-t-doc-pl.cli-qnty     = loc-t-doc-pl.cli-doc-qnty
    .
    if f-doc-pl-rest-density :sensitive = true then do:
      if loc-t-doc-pl.rest-af-qnty <> 0.0
        and loc-t-doc-pl.cli-rest-af-qnty <> 0.0
        and absolute( loc-t-doc-pl.cli-rest-af-qnty / loc-t-doc-pl.rest-af-qnty - f-doc-pl-rest-density ) > 0.00001
      then do:
        message
          "Указанная плотность не соответствует расчетной." skip
          substitute( "Расчетная: &1", loc-t-doc-pl.cli-rest-af-qnty / loc-t-doc-pl.rest-af-qnty ) skip
          substitute( "Задана: &1", f-doc-pl-rest-density ) skip
          view-as alert-box error .
        apply "entry" to f-doc-pl-rest-density in frame f-doc-pl.
        return no-apply .
      end.
      if valid-density( f-doc-pl-rest-density, (buf_goods.unit-base = buf_goods.unit-cli)  ) <> true then do:
        message
          "Значение плотности не корректно." skip
          substitute( 'Плотность "стало": &1', f-doc-pl-rest-density ) skip
          view-as alert-box error .
        apply "entry" to f-doc-pl-rest-density in frame f-doc-pl.
        return no-apply .
      end.
    end.
  end.
  if p-upd-field <> "rest":U
    and p-upd-field <> "rest-fact":U
    and p-upd-field <> "fact-doc":U
    and loc-t-doc-pl.cli-doc-qnty = 0.0
    and loc-t-doc-pl.doc-qnty = 0.0
  then do:
    message
      "Указаны нулевые количества, запись будет удалена." skip
      "Хотите продолжить редактирование?" skip
      view-as alert-box question buttons yes-no update v-quit.
    if v-quit = true then do:
      return no-apply.
    end.
    else do:
      if available buf-upd_tt-doc-pl then do:
        delete buf-upd_tt-doc-pl .
      end.
    end.
  end.
  else do:
    if not available buf-upd_tt-doc-pl then do:
      create buf-upd_tt-doc-pl .
    end.
    buffer-copy loc-t-doc-pl to buf-upd_tt-doc-pl .
  end.
END.
ON CHOOSE OF b-place IN FRAME f-doc-pl
DO:
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-rid-list as character no-undo .
  define variable v-pl-code  as integer   no-undo .
  define variable ref-rec    as recid     no-undo .
  define variable v-value    as character no-undo .
  define variable v-value2   as character no-undo .
  define variable v-ok       as logical   no-undo .
  define variable ii         as integer   no-undo .
  define buffer buf_pl-gds for ub.pl-gds .
  define buffer buf_place for ub.place .
  define buffer buf_place-attr for ub.place-attr .
  run ref/pl-gdss.w
    ( input parparentproc
     ,input "b-sel"
     ,input buf-obj_clients.obj-type
     ,input buf-obj_clients.obj-code
     ,input ( if v-is-ptrl = "yes":U then 'топ':U else 'ТОВАР':U )
     ,input recid( buf_goods )
     ,input ?
     ,output v-rid-list
    ) no-error .
  assign
    ref-rec = integer( entry( 1, v-rid-list ) ) no-error
  .
  if error-status :error then do:
    assign
      ref-rec = ?
    .
  end.
  find first buf_pl-gds no-lock
    where recid( buf_pl-gds ) = ref-rec
    no-error .
  if available buf_pl-gds then do:
    v-pl-code = buf_pl-gds.pl-code .
    if loc-t-doc-pl.pl-code = v-pl-code then do:
      return no-apply .
    end.
    run placelib_get-attr  (
       input "place-is-main"
      ,input buf_pl-gds.obj-code
      ,input buf_pl-gds.obj-type
      ,input buf_pl-gds.pl-code
      ,output v-value
      ,output v-ok      )
    no-error.
    if v-ok
    and not logical(v-value)
    then do :
      run placelib_get-attr  (
         input "place-com-tanks"
        ,input buf_pl-gds.obj-code
        ,input buf_pl-gds.obj-type
        ,input buf_pl-gds.pl-code
        ,output v-value
        ,output v-ok      )
      no-error.
      if v-ok
      and v-value > ""
      then do ii = 1 to num-entries(v-value) :
        find first buf_place no-lock where buf_place.obj-type = buf_pl-gds.obj-type
                                       and buf_place.obj-code = buf_pl-gds.obj-code
                                       and buf_place.loc1     = entry(ii, v-value)
                                       and buf_place.status_  = ""
                                       no-error .
        if available buf_place
        then do :
          run placelib_get-attr  (
             input "place-is-main"
            ,input buf_place.obj-code
            ,input buf_place.obj-type
            ,input buf_place.pl-code
            ,output v-value2
            ,output v-ok      )
          no-error.
          if v-ok
          and logical(v-value2)
          then do :
            v-pl-code = buf_place.pl-code .
            leave .
          end .
        end .
      end .
    end .
    if loc-t-doc-pl.pl-code = v-pl-code then do:
      return no-apply .
    end.
    assign
      loc-t-doc-pl.pl-code :screen-value = string( v-pl-code, loc-t-doc-pl.pl-code :format )
    .
    apply "leave" to loc-t-doc-pl.pl-code in frame f-doc-pl .
  end.
  apply "value-changed" to loc-t-doc-pl.pl-code in frame f-doc-pl.
END.
ON CHOOSE OF b-qnty IN FRAME f-doc-pl
DO:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if ( loc-t-doc-pl.cli-doc-qnty :sensitive = true
       and f-doc-line-cli-doc-qnty = f-tot-doc-pl-cli-doc-qnty
     )
     or ( loc-t-doc-pl.doc-qnty :sensitive = true
          and f-doc-line-doc-qnty = f-tot-doc-pl-doc-qnty
        )
     or ( loc-t-doc-pl.cli-fact-qnty :sensitive = true
          and f-doc-line-cli-fact-qnty = f-tot-doc-pl-cli-fact-qnty
        )
     or ( loc-t-doc-pl.fact-qnty :sensitive = true
          and f-doc-line-fact-qnty = f-tot-doc-pl-fact-qnty
        )
  then do:
    message
      "Все количества уже установлены корректно."
      view-as alert-box information.
    return no-apply .
  end.
  if loc-t-doc-pl.cli-doc-qnty :sensitive = true then do:
    assign
      loc-t-doc-pl.cli-doc-qnty = loc-t-doc-pl.cli-doc-qnty + f-doc-line-cli-doc-qnty - f-tot-doc-pl-cli-doc-qnty
    .
    display
      loc-t-doc-pl.cli-doc-qnty
      with frame f-doc-pl.
    apply "leave" to loc-t-doc-pl.cli-doc-qnty in frame f-doc-pl .
  end.
  if loc-t-doc-pl.doc-qnty :sensitive = true then do:
    assign
      loc-t-doc-pl.doc-qnty = loc-t-doc-pl.doc-qnty + f-doc-line-doc-qnty - f-tot-doc-pl-doc-qnty
    .
    display
      loc-t-doc-pl.doc-qnty
      with frame f-doc-pl.
    apply "leave" to loc-t-doc-pl.doc-qnty in frame f-doc-pl .
  end.
  if loc-t-doc-pl.cli-fact-qnty :sensitive = true then do:
    assign
      loc-t-doc-pl.cli-fact-qnty = loc-t-doc-pl.cli-fact-qnty + f-doc-line-cli-fact-qnty - f-tot-doc-pl-cli-fact-qnty
    .
    display
      loc-t-doc-pl.cli-fact-qnty
      with frame f-doc-pl.
    apply "leave" to loc-t-doc-pl.cli-fact-qnty in frame f-doc-pl .
  end.
  if loc-t-doc-pl.fact-qnty :sensitive = true then do:
    assign
      loc-t-doc-pl.fact-qnty = loc-t-doc-pl.fact-qnty + f-doc-line-fact-qnty - f-tot-doc-pl-fact-qnty
    .
    display
      loc-t-doc-pl.fact-qnty
      with frame f-doc-pl.
    apply "leave" to loc-t-doc-pl.fact-qnty in frame f-doc-pl .
  end.
  run calc-qnty in this-procedure .
END.
ON LEAVE OF loc-t-doc-pl.cli-doc-qnty IN FRAME f-doc-pl
or return of loc-t-doc-pl.cli-doc-qnty in frame f-doc-pl
DO:
  define variable v-chg-qnty     like ub.doc-pl.doc-qnty   no-undo .
  define variable v-new-qnty     like ub.doc-pl.doc-qnty   no-undo .
  define variable v-correct-qnty as decimal   no-undo .
  define buffer buf_tt-doc-pl for tt-doc-pl .
  assign
    loc-t-doc-pl.cli-doc-qnty
  .
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input loc-t-doc-pl.cli-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-qnty         else 0.0 )
     ,input loc-t-doc-pl.doc-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.doc-qnty         else 0.0 )
     ,input loc-t-doc-pl.cli-doc-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-doc-qnty     else 0.0 )
     ,input loc-t-doc-pl.fact-qnty        - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.fact-qnty        else 0.0 )
     ,input loc-t-doc-pl.cli-fact-qnty    - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-fact-qnty    else 0.0 )
     ,input loc-t-doc-pl.rest-af-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.rest-af-qnty     else 0.0 )
     ,input loc-t-doc-pl.cli-rest-af-qnty - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-rest-af-qnty else 0.0 )
    ).
  assign
    v-chg-qnty = loc-t-doc-pl.cli-doc-qnty / f-doc-pl-doc-density
  .
  if v-chg-qnty <> 0 then do:
    if loc-t-doc-pl.pl-code <> 0
      and loc-t-doc-pl.pl-code <> ?
    then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_chkqnpl in g#lib-trn3
  (  input buf_trn-doc.doc-type
  ,  input loc-t-doc-pl.obj-type
  ,  input loc-t-doc-pl.obj-code
  ,  input loc-t-doc-pl.pl-code
  ,  input loc-t-doc-pl.gds-code
  ,  input v-msg-on
  ,  input v-chg-qnty
  , output v-new-qnty
  )
  .
    end.
    else do:
      assign
        v-new-qnty = v-chg-qnty
      .
    end.
    assign
      v-correct-qnty = p-doc-line-doc-qnty - v-new-qnty
    .
    for each buf_tt-doc-pl no-lock
      where buf_tt-doc-pl.obj-type = buf_trn-doc.obj-type
        and buf_tt-doc-pl.obj-code = buf_trn-doc.obj-code
        and buf_tt-doc-pl.out-code = buf_trn-doc.doc-code
        and buf_tt-doc-pl.gds-code = p-gds-code
    on error undo, return no-apply
    :
      if buf_tt-doc-pl.pl-code <> loc-t-doc-pl.pl-code then do:
        assign
          v-correct-qnty = v-correct-qnty - buf_tt-doc-pl.doc-qnty
        .
      end.
    end.
    if absolute( v-correct-qnty ) > 0.001 then do:
      assign
        v-correct-qnty = 0.0
      .
    end.
    assign
      loc-t-doc-pl.cli-qnty      = v-new-qnty / p-doc-line-cli-base-rate
      loc-t-doc-pl.doc-qnty      = v-new-qnty + v-correct-qnty
      loc-t-doc-pl.cli-doc-qnty  = v-new-qnty * f-doc-pl-doc-density
      loc-t-doc-pl.fact-qnty     = loc-t-doc-pl.doc-qnty
      loc-t-doc-pl.cli-fact-qnty = loc-t-doc-pl.cli-doc-qnty
    .
  end.
  else do:
    assign
      loc-t-doc-pl.cli-qnty      = 0.0
      loc-t-doc-pl.doc-qnty      = 0.0
      loc-t-doc-pl.fact-qnty     = 0.0
      loc-t-doc-pl.cli-doc-qnty  = 0.0
      loc-t-doc-pl.cli-fact-qnty = 0.0
      .
  end.
  display
    loc-t-doc-pl.cli-qnty      when loc-t-doc-pl.cli-qnty      :visible = true
    loc-t-doc-pl.doc-qnty
    loc-t-doc-pl.cli-doc-qnty  when loc-t-doc-pl.cli-doc-qnty  :visible = true
    loc-t-doc-pl.fact-qnty     when loc-t-doc-pl.fact-qnty     :visible = true
    loc-t-doc-pl.cli-fact-qnty when loc-t-doc-pl.cli-fact-qnty :visible = true
    with frame f-doc-pl.
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input loc-t-doc-pl.cli-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-qnty         else 0.0 )
     ,input loc-t-doc-pl.doc-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.doc-qnty         else 0.0 )
     ,input loc-t-doc-pl.cli-doc-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-doc-qnty     else 0.0 )
     ,input loc-t-doc-pl.fact-qnty        - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.fact-qnty        else 0.0 )
     ,input loc-t-doc-pl.cli-fact-qnty    - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-fact-qnty    else 0.0 )
     ,input loc-t-doc-pl.rest-af-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.rest-af-qnty     else 0.0 )
     ,input loc-t-doc-pl.cli-rest-af-qnty - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-rest-af-qnty else 0.0 )
    ).
END.
ON LEAVE OF loc-t-doc-pl.cli-fact-qnty IN FRAME f-doc-pl
or return of loc-t-doc-pl.cli-fact-qnty in frame f-doc-pl
DO:
  define variable v-chg-qnty     like ub.doc-pl.fact-qnty no-undo .
  define variable v-new-qnty     like ub.doc-pl.fact-qnty no-undo .
  define variable v-correct-qnty as decimal   no-undo .
  define buffer buf_tt-doc-pl for tt-doc-pl .
  assign
    loc-t-doc-pl.cli-fact-qnty
  .
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input loc-t-doc-pl.cli-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-qnty         else 0.0 )
     ,input loc-t-doc-pl.doc-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.doc-qnty         else 0.0 )
     ,input loc-t-doc-pl.cli-doc-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-doc-qnty     else 0.0 )
     ,input loc-t-doc-pl.fact-qnty        - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.fact-qnty        else 0.0 )
     ,input loc-t-doc-pl.cli-fact-qnty    - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-fact-qnty    else 0.0 )
     ,input loc-t-doc-pl.rest-af-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.rest-af-qnty     else 0.0 )
     ,input loc-t-doc-pl.cli-rest-af-qnty - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-rest-af-qnty else 0.0 )
    ).
  if p-upd-field <> "rest-fact":U then do:
    assign
      v-chg-qnty = loc-t-doc-pl.cli-fact-qnty / f-doc-pl-fact-density
    .
    if v-chg-qnty <> 0 then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_chkqnpl in g#lib-trn3
  (  input buf_trn-doc.doc-type
  ,  input loc-t-doc-pl.obj-type
  ,  input loc-t-doc-pl.obj-code
  ,  input loc-t-doc-pl.pl-code
  ,  input loc-t-doc-pl.gds-code
  ,  input v-msg-on
  ,  input v-chg-qnty
  , output v-new-qnty
  )
  .
      assign
        v-correct-qnty = p-doc-line-fact-qnty - v-new-qnty
      .
      for each buf_tt-doc-pl no-lock
        where buf_tt-doc-pl.obj-type = buf_trn-doc.obj-type
          and buf_tt-doc-pl.obj-code = buf_trn-doc.obj-code
          and buf_tt-doc-pl.out-code = buf_trn-doc.doc-code
          and buf_tt-doc-pl.gds-code = p-gds-code
      on error undo, return no-apply
      :
        if buf_tt-doc-pl.pl-code <> loc-t-doc-pl.pl-code then do:
          assign
            v-correct-qnty = v-correct-qnty - buf_tt-doc-pl.fact-qnty
          .
        end.
      end.
      if absolute( v-correct-qnty ) > 0.001 then do:
        assign
          v-correct-qnty = 0.0
        .
      end.
      assign
        loc-t-doc-pl.fact-qnty      = v-new-qnty + v-correct-qnty
        loc-t-doc-pl.cli-fact-qnty  = v-new-qnty * f-doc-pl-fact-density
      .
    end.
    else do:
      assign
        loc-t-doc-pl.fact-qnty     = 0.0
        loc-t-doc-pl.cli-fact-qnty = 0.0
        .
    end.
  end.
  run calc-qnty in this-procedure .
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input loc-t-doc-pl.cli-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-qnty         else 0.0 )
     ,input loc-t-doc-pl.doc-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.doc-qnty         else 0.0 )
     ,input loc-t-doc-pl.cli-doc-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-doc-qnty     else 0.0 )
     ,input loc-t-doc-pl.fact-qnty        - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.fact-qnty        else 0.0 )
     ,input loc-t-doc-pl.cli-fact-qnty    - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-fact-qnty    else 0.0 )
     ,input loc-t-doc-pl.rest-af-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.rest-af-qnty     else 0.0 )
     ,input loc-t-doc-pl.cli-rest-af-qnty - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-rest-af-qnty else 0.0 )
    ).
END.
ON LEAVE OF loc-t-doc-pl.cli-rest-af-qnty IN FRAME f-doc-pl
or return of loc-t-doc-pl.cli-rest-af-qnty in frame f-doc-pl
DO:
  define variable v-chg-qnty     like ub.doc-pl.rest-af-qnty no-undo .
  define variable v-new-qnty     like ub.doc-pl.rest-af-qnty no-undo .
  define buffer buf_tt-doc-pl for tt-doc-pl .
  assign
    loc-t-doc-pl.cli-rest-af-qnty
  .
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input loc-t-doc-pl.cli-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-qnty         else 0.0 )
     ,input loc-t-doc-pl.doc-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.doc-qnty         else 0.0 )
     ,input loc-t-doc-pl.cli-doc-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-doc-qnty     else 0.0 )
     ,input loc-t-doc-pl.fact-qnty        - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.fact-qnty        else 0.0 )
     ,input loc-t-doc-pl.cli-fact-qnty    - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-fact-qnty    else 0.0 )
     ,input loc-t-doc-pl.rest-af-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.rest-af-qnty     else 0.0 )
     ,input loc-t-doc-pl.cli-rest-af-qnty - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-rest-af-qnty else 0.0 )
    ).
  assign
    v-chg-qnty = loc-t-doc-pl.cli-rest-af-qnty / f-doc-pl-rest-density
  .
  if v-chg-qnty <> 0.0 then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_chkqnpl in g#lib-trn3
  (  input buf_trn-doc.doc-type
  ,  input loc-t-doc-pl.obj-type
  ,  input loc-t-doc-pl.obj-code
  ,  input loc-t-doc-pl.pl-code
  ,  input loc-t-doc-pl.gds-code
  ,  input v-msg-on
  ,  input v-chg-qnty
  , output v-new-qnty
  )
  .
    assign
      loc-t-doc-pl.rest-af-qnty     = v-new-qnty
      loc-t-doc-pl.cli-rest-af-qnty = loc-t-doc-pl.rest-af-qnty * f-doc-pl-rest-density
    .
  end.
  else do:
    assign
      loc-t-doc-pl.rest-af-qnty     = 0.0
      loc-t-doc-pl.cli-rest-af-qnty = 0.0
      .
  end.
  run calc-qnty in this-procedure .
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input loc-t-doc-pl.cli-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-qnty         else 0.0 )
     ,input loc-t-doc-pl.doc-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.doc-qnty         else 0.0 )
     ,input loc-t-doc-pl.cli-doc-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-doc-qnty     else 0.0 )
     ,input loc-t-doc-pl.fact-qnty        - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.fact-qnty        else 0.0 )
     ,input loc-t-doc-pl.cli-fact-qnty    - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-fact-qnty    else 0.0 )
     ,input loc-t-doc-pl.rest-af-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.rest-af-qnty     else 0.0 )
     ,input loc-t-doc-pl.cli-rest-af-qnty - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-rest-af-qnty else 0.0 )
    ).
END.
ON LEAVE OF loc-t-doc-pl.doc-qnty IN FRAME f-doc-pl
or return of loc-t-doc-pl.doc-qnty in frame f-doc-pl
DO:
  define variable v-chg-qnty      like ub.doc-pl.doc-qnty     no-undo .
  define variable v-new-qnty      like ub.doc-pl.doc-qnty     no-undo .
  define variable v-correct-qnty  as decimal   no-undo .
  define variable v-corr-cli-qnty as decimal   no-undo .
  define buffer buf_tt-doc-pl for tt-doc-pl .
  assign
    loc-t-doc-pl.doc-qnty
  .
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input loc-t-doc-pl.cli-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-qnty         else 0.0 )
     ,input loc-t-doc-pl.doc-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.doc-qnty         else 0.0 )
     ,input loc-t-doc-pl.cli-doc-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-doc-qnty     else 0.0 )
     ,input loc-t-doc-pl.fact-qnty        - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.fact-qnty        else 0.0 )
     ,input loc-t-doc-pl.cli-fact-qnty    - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-fact-qnty    else 0.0 )
     ,input loc-t-doc-pl.rest-af-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.rest-af-qnty     else 0.0 )
     ,input loc-t-doc-pl.cli-rest-af-qnty - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-rest-af-qnty else 0.0 )
    ).
  assign
    v-chg-qnty = loc-t-doc-pl.doc-qnty
  .
  if v-chg-qnty <> 0 then do:
    if loc-t-doc-pl.pl-code <> 0
      and loc-t-doc-pl.pl-code <> ?
    then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_chkqnpl in g#lib-trn3
  (  input buf_trn-doc.doc-type
  ,  input loc-t-doc-pl.obj-type
  ,  input loc-t-doc-pl.obj-code
  ,  input loc-t-doc-pl.pl-code
  ,  input loc-t-doc-pl.gds-code
  ,  input v-msg-on
  ,  input v-chg-qnty
  , output v-new-qnty
  )
  .
    end.
    else do:
      assign
        v-new-qnty = v-chg-qnty
      .
    end.
    assign
      v-correct-qnty  = p-doc-line-doc-cli-qnty - v-new-qnty * f-doc-pl-doc-density
      v-corr-cli-qnty = p-doc-line-cli-qnty     - v-new-qnty / p-doc-line-cli-base-rate
    .
    for each buf_tt-doc-pl no-lock
      where buf_tt-doc-pl.obj-type = buf_trn-doc.obj-type
        and buf_tt-doc-pl.obj-code = buf_trn-doc.obj-code
        and buf_tt-doc-pl.out-code = buf_trn-doc.doc-code
        and buf_tt-doc-pl.gds-code = p-gds-code
    on error undo, return no-apply
    :
      if buf_tt-doc-pl.pl-code <> loc-t-doc-pl.pl-code then do:
        assign
          v-correct-qnty  = v-correct-qnty  - buf_tt-doc-pl.cli-doc-qnty
          v-corr-cli-qnty = v-corr-cli-qnty - buf_tt-doc-pl.cli-qnty
        .
      end.
    end.
    if absolute( v-corr-cli-qnty ) > 0.001 then do:
      assign
        v-corr-cli-qnty = 0.0
      .
    end.
    if absolute( v-correct-qnty ) > 0.001 then do:
      assign
        v-correct-qnty = 0.0
      .
    end.
    assign
      loc-t-doc-pl.cli-qnty      = v-new-qnty / p-doc-line-cli-base-rate + v-corr-cli-qnty
      loc-t-doc-pl.doc-qnty      = v-new-qnty
      loc-t-doc-pl.cli-doc-qnty  = v-new-qnty * f-doc-pl-doc-density + v-correct-qnty
      loc-t-doc-pl.fact-qnty     = loc-t-doc-pl.doc-qnty
      loc-t-doc-pl.cli-fact-qnty = loc-t-doc-pl.cli-doc-qnty
      .
  end.
  else do:
    assign
      loc-t-doc-pl.cli-qnty      = 0.0
      loc-t-doc-pl.doc-qnty      = 0.0
      loc-t-doc-pl.fact-qnty     = 0.0
      loc-t-doc-pl.cli-doc-qnty  = 0.0
      loc-t-doc-pl.cli-fact-qnty = 0.0
      .
  end.
  display
    loc-t-doc-pl.cli-qnty      when loc-t-doc-pl.cli-qnty      :visible = true
    loc-t-doc-pl.doc-qnty
    loc-t-doc-pl.cli-doc-qnty  when loc-t-doc-pl.cli-doc-qnty  :visible = true
    loc-t-doc-pl.fact-qnty     when loc-t-doc-pl.fact-qnty     :visible = true
    loc-t-doc-pl.cli-fact-qnty when loc-t-doc-pl.cli-fact-qnty :visible = true
    with frame f-doc-pl.
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input loc-t-doc-pl.cli-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-qnty         else 0.0 )
     ,input loc-t-doc-pl.doc-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.doc-qnty         else 0.0 )
     ,input loc-t-doc-pl.cli-doc-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-doc-qnty     else 0.0 )
     ,input loc-t-doc-pl.fact-qnty        - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.fact-qnty        else 0.0 )
     ,input loc-t-doc-pl.cli-fact-qnty    - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-fact-qnty    else 0.0 )
     ,input loc-t-doc-pl.rest-af-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.rest-af-qnty     else 0.0 )
     ,input loc-t-doc-pl.cli-rest-af-qnty - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-rest-af-qnty else 0.0 )
    ).
END.
ON LEAVE OF f-doc-pl-rest-density IN FRAME f-doc-pl
or return of f-doc-pl-rest-density in frame f-doc-pl
DO:
  assign
    f-doc-pl-rest-density
  .
  if loc-t-doc-pl.cli-rest-af-qnty :sensitive = true then do:
    assign
      loc-t-doc-pl.rest-af-qnty = loc-t-doc-pl.cli-rest-af-qnty / f-doc-pl-rest-density
    .
  end.
  else do:
    assign
      loc-t-doc-pl.cli-rest-af-qnty = loc-t-doc-pl.rest-af-qnty * f-doc-pl-rest-density
    .
  end.
  run calc-qnty in this-procedure .
def var vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input loc-t-doc-pl.cli-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-qnty         else 0.0 )
     ,input loc-t-doc-pl.doc-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.doc-qnty         else 0.0 )
     ,input loc-t-doc-pl.cli-doc-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-doc-qnty     else 0.0 )
     ,input loc-t-doc-pl.fact-qnty        - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.fact-qnty        else 0.0 )
     ,input loc-t-doc-pl.cli-fact-qnty    - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-fact-qnty    else 0.0 )
     ,input loc-t-doc-pl.rest-af-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.rest-af-qnty     else 0.0 )
     ,input loc-t-doc-pl.cli-rest-af-qnty - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-rest-af-qnty else 0.0 )
    ).
END.
ON LEAVE OF loc-t-doc-pl.fact-qnty IN FRAME f-doc-pl
or return of loc-t-doc-pl.fact-qnty in frame f-doc-pl
DO:
  define variable v-chg-qnty     like ub.doc-pl.fact-qnty     no-undo .
  define variable v-new-qnty     like ub.doc-pl.fact-qnty     no-undo .
  define variable v-correct-qnty as decimal   no-undo .
  define buffer buf_tt-doc-pl for tt-doc-pl .
  assign
    loc-t-doc-pl.fact-qnty
  .
def var vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input loc-t-doc-pl.cli-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-qnty         else 0.0 )
     ,input loc-t-doc-pl.doc-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.doc-qnty         else 0.0 )
     ,input loc-t-doc-pl.cli-doc-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-doc-qnty     else 0.0 )
     ,input loc-t-doc-pl.fact-qnty        - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.fact-qnty        else 0.0 )
     ,input loc-t-doc-pl.cli-fact-qnty    - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-fact-qnty    else 0.0 )
     ,input loc-t-doc-pl.rest-af-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.rest-af-qnty     else 0.0 )
     ,input loc-t-doc-pl.cli-rest-af-qnty - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-rest-af-qnty else 0.0 )
    ).
  if p-upd-field <> "rest-fact":U then do:
    assign
      v-chg-qnty = loc-t-doc-pl.fact-qnty
    .
    if v-chg-qnty <> 0 then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_chkqnpl in g#lib-trn3
  (  input buf_trn-doc.doc-type
  ,  input loc-t-doc-pl.obj-type
  ,  input loc-t-doc-pl.obj-code
  ,  input loc-t-doc-pl.pl-code
  ,  input loc-t-doc-pl.gds-code
  ,  input v-msg-on
  ,  input v-chg-qnty
  , output v-new-qnty
  )
  .
      assign
        v-correct-qnty = p-doc-line-fact-cli-qnty - v-new-qnty * f-doc-pl-fact-density
      .
      for each buf_tt-doc-pl no-lock
        where buf_tt-doc-pl.obj-type = buf_trn-doc.obj-type
          and buf_tt-doc-pl.obj-code = buf_trn-doc.obj-code
          and buf_tt-doc-pl.out-code = buf_trn-doc.doc-code
          and buf_tt-doc-pl.gds-code = p-gds-code
      on error undo, return no-apply
      :
        if buf_tt-doc-pl.pl-code <> loc-t-doc-pl.pl-code then do:
          assign
            v-correct-qnty = v-correct-qnty - buf_tt-doc-pl.cli-fact-qnty
          .
        end.
      end.
      if absolute( v-correct-qnty ) > 0.001 then do:
        assign
          v-correct-qnty = 0.0
        .
      end.
      assign
        loc-t-doc-pl.fact-qnty      = v-new-qnty
        loc-t-doc-pl.cli-fact-qnty  = loc-t-doc-pl.fact-qnty * f-doc-pl-fact-density + v-correct-qnty
      .
    end.
    else do:
      assign
        loc-t-doc-pl.fact-qnty     = 0.0
        loc-t-doc-pl.cli-fact-qnty = 0.0
        .
    end.
  end.
  run calc-qnty in this-procedure .
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input loc-t-doc-pl.cli-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-qnty         else 0.0 )
     ,input loc-t-doc-pl.doc-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.doc-qnty         else 0.0 )
     ,input loc-t-doc-pl.cli-doc-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-doc-qnty     else 0.0 )
     ,input loc-t-doc-pl.fact-qnty        - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.fact-qnty        else 0.0 )
     ,input loc-t-doc-pl.cli-fact-qnty    - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-fact-qnty    else 0.0 )
     ,input loc-t-doc-pl.rest-af-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.rest-af-qnty     else 0.0 )
     ,input loc-t-doc-pl.cli-rest-af-qnty - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-rest-af-qnty else 0.0 )
    ).
END.
ON LEAVE OF loc-t-doc-pl.pl-code IN FRAME f-doc-pl
or return of loc-t-doc-pl.pl-code in frame f-doc-pl
DO:
  define buffer buf_pl-gds for ub.pl-gds .
  define buffer buf-old_parts  for ub.parts .
  define buffer buf-new_parts  for ub.parts .
  if input frame f-doc-pl loc-t-doc-pl.pl-code <> loc-t-doc-pl.pl-code then do:
    find first buf_pl-gds no-lock
      where buf_pl-gds.obj-type = buf_trn-doc.obj-type
        and buf_pl-gds.obj-code = buf_trn-doc.obj-code
        and buf_pl-gds.pl-code  = input frame f-doc-pl loc-t-doc-pl.pl-code
        and buf_pl-gds.gds-code = p-gds-code
      no-error .
    if not available buf_pl-gds then do:
      apply "choose" to b-place in frame f-doc-pl .
      return no-apply .
    end.
    else do:
      find first tt-doc-pl no-lock
        where tt-doc-pl.obj-type = buf_trn-doc.obj-type
          and tt-doc-pl.obj-code = buf_trn-doc.obj-code
          and tt-doc-pl.pl-code  = buf_pl-gds.pl-code
          and tt-doc-pl.out-code = buf_trn-doc.doc-code
          and tt-doc-pl.gds-code = buf_pl-gds.gds-code
        no-error .
      if available tt-doc-pl then do:
        if not available buf-upd_tt-doc-pl
          or ( available buf-upd_tt-doc-pl
               and buf-upd_tt-doc-pl.pl-code <> buf_pl-gds.pl-code
             )
        then do:
          assign
            loc-t-doc-pl.pl-code :screen-value = string( loc-t-doc-pl.pl-code, loc-t-doc-pl.pl-code :format )
          .
          message
            substitute( "Строка по месту хранения &1 уже существует.", buf_pl-gds.pl-code ) skip
            view-as alert-box information .
          return no-apply .
        end.
      end.
      if buf_trn-doc.doc-type = 'при':U then do:
        for each buf-old_parts
          where buf-old_parts.obj-type  = buf_trn-doc.obj-type
            and buf-old_parts.obj-code  = buf_trn-doc.obj-code
            and buf-old_parts.artic     = buf_goods.artic
            and buf-old_parts.prod-type = buf_goods.prod-type
            and buf-old_parts.prod-code = buf_goods.prod-code
            and buf-old_parts.in-code   = buf_trn-doc.doc-code
            and buf-old_parts.out-code  = buf_trn-doc.doc-code
        on error undo, return no-apply
        :
          if buf-old_parts.pl-code = loc-t-doc-pl.pl-code then do:
            find first buf-new_parts
              where buf-new_parts.obj-type  = buf_trn-doc.obj-type
                and buf-new_parts.obj-code  = buf_trn-doc.obj-code
                and buf-new_parts.artic     = buf_goods.artic
                and buf-new_parts.prod-type = buf_goods.prod-type
                and buf-new_parts.prod-code = buf_goods.prod-code
                and buf-new_parts.in-code   = buf_trn-doc.doc-code
                and buf-new_parts.out-code  = buf_trn-doc.doc-code
                and buf-new_parts.part-code = string( buf_pl-gds.pl-code )
              no-error .
            if available buf-new_parts then do:
              assign
                buf-new_parts.pl-code   = buf-old_parts.pl-code
                buf-new_parts.part-code = buf-old_parts.part-code
              .
            end.
            assign
              buf-old_parts.pl-code   = buf_pl-gds.pl-code
              buf-old_parts.part-code = string( buf_pl-gds.pl-code )
            .
          end.
        end.
      end.
      assign
        loc-t-doc-pl.pl-code
      .
      if loc-t-doc-pl.cli-doc-qnty :sensitive = true then do:
        apply "leave" to loc-t-doc-pl.cli-doc-qnty in frame f-doc-pl .
      end.
      if loc-t-doc-pl.doc-qnty :sensitive = true then do:
        apply "leave" to loc-t-doc-pl.doc-qnty in frame f-doc-pl .
      end.
      if loc-t-doc-pl.cli-fact-qnty :sensitive = true then do:
        apply "leave" to loc-t-doc-pl.cli-fact-qnty in frame f-doc-pl .
      end.
      if loc-t-doc-pl.fact-qnty :sensitive = true then do:
        apply "leave" to loc-t-doc-pl.fact-qnty in frame f-doc-pl .
      end.
    end.
  end.
END.
ON VALUE-CHANGED OF loc-t-doc-pl.pl-code IN FRAME f-doc-pl
DO:
  assign
    frame f-doc-pl :title = substitute( 'Место хранения &1 товар &2 документ &3 (объект &4 &5) с кол-вами -- &6'
                                            ,loc-t-doc-pl.pl-code
                                            ,buf_goods.gds-code
                                            ,buf_trn-doc.doc-code
                                            ,buf-obj_clients.obj-type
                                            ,buf-obj_clients.obj-code
                                            ,p-mode
                                            )
  .
  if loc-t-doc-pl.pl-code <> ? then do:
    run get-from-rvs in this-procedure
      ( input  loc-t-doc-pl.out-code
       ,input  loc-t-doc-pl.gds-code
       ,input  loc-t-doc-pl.pl-code
       ,output f-rvs-state-measure-qnty
       ,output f-rvs-measure-qnty
       ,output f-rvs-state-measure-cli-qnty
       ,output f-rvs-measure-cli-qnty
       ,output f-rvs-state-density
       ,output f-rvs-density
       ,output v-label-rvs
      ) no-error .
    if v-is-ptrl = "no":U
      or v-label-rvs = "":U
    then do:
      hide
        v-label-rvs
        f-rvs-density
        f-rvs-measure-qnty
        f-rvs-measure-cli-qnty
        f-rvs-state-density
        f-rvs-state-measure-qnty
        f-rvs-state-measure-cli-qnty
        in frame f-doc-pl
        .
    end.
    else do:
      display
        v-label-rvs
        f-rvs-state-measure-qnty
        f-rvs-measure-qnty
        with frame f-doc-pl.
      if buf_goods.unit-cli = buf_goods.unit-base then do:
        hide
          f-rvs-density
          f-rvs-measure-cli-qnty
          f-rvs-state-density
          f-rvs-state-measure-cli-qnty
          in frame f-doc-pl
          .
      end.
      else do:
        display
          f-rvs-density
          f-rvs-measure-cli-qnty
          f-rvs-state-density
          f-rvs-state-measure-cli-qnty
          with frame f-doc-pl.
      end.
    end.
    find first buf_place no-lock
      where buf_place.obj-type = buf-obj_clients.obj-type
        and buf_place.obj-code = buf-obj_clients.obj-code
        and buf_place.pl-code  = loc-t-doc-pl.pl-code
        and buf_place.status_ <> 'удал':U
      no-error .
    if available buf_place then do:
      display
        buf_place.pl-name
        buf_place.loc1
        buf_place.loc2
        buf_place.loc3
        buf_place.loc4
        with frame f-doc-pl.
    end.
  end.
END.
ON LEAVE OF loc-t-doc-pl.rest-af-qnty IN FRAME f-doc-pl
or return of loc-t-doc-pl.rest-af-qnty in frame f-doc-pl
DO:
  define variable v-chg-qnty like ub.doc-pl.rest-af-qnty no-undo .
  define variable v-new-qnty like ub.doc-pl.rest-af-qnty no-undo .
  assign
    loc-t-doc-pl.rest-af-qnty
  .
def var vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input loc-t-doc-pl.cli-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-qnty         else 0.0 )
     ,input loc-t-doc-pl.doc-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.doc-qnty         else 0.0 )
     ,input loc-t-doc-pl.cli-doc-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-doc-qnty     else 0.0 )
     ,input loc-t-doc-pl.fact-qnty        - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.fact-qnty        else 0.0 )
     ,input loc-t-doc-pl.cli-fact-qnty    - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-fact-qnty    else 0.0 )
     ,input loc-t-doc-pl.rest-af-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.rest-af-qnty     else 0.0 )
     ,input loc-t-doc-pl.cli-rest-af-qnty - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-rest-af-qnty else 0.0 )
    ).
  assign
    v-chg-qnty = loc-t-doc-pl.rest-af-qnty
  .
  if v-chg-qnty <> 0 then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_chkqnpl in g#lib-trn3
  (  input buf_trn-doc.doc-type
  ,  input loc-t-doc-pl.obj-type
  ,  input loc-t-doc-pl.obj-code
  ,  input loc-t-doc-pl.pl-code
  ,  input loc-t-doc-pl.gds-code
  ,  input v-msg-on
  ,  input v-chg-qnty
  , output v-new-qnty
  )
  .
    assign
      loc-t-doc-pl.rest-af-qnty      = v-new-qnty
      loc-t-doc-pl.cli-rest-af-qnty  = loc-t-doc-pl.rest-af-qnty * f-doc-pl-rest-density
    .
  end.
  else do:
    assign
      loc-t-doc-pl.rest-af-qnty     = 0.0
      loc-t-doc-pl.cli-rest-af-qnty = 0.0
      .
  end.
  run calc-qnty in this-procedure .
def var vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input loc-t-doc-pl.cli-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-qnty         else 0.0 )
     ,input loc-t-doc-pl.doc-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.doc-qnty         else 0.0 )
     ,input loc-t-doc-pl.cli-doc-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-doc-qnty     else 0.0 )
     ,input loc-t-doc-pl.fact-qnty        - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.fact-qnty        else 0.0 )
     ,input loc-t-doc-pl.cli-fact-qnty    - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-fact-qnty    else 0.0 )
     ,input loc-t-doc-pl.rest-af-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.rest-af-qnty     else 0.0 )
     ,input loc-t-doc-pl.cli-rest-af-qnty - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-rest-af-qnty else 0.0 )
    ).
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME f-doc-pl:PARENT eq ?
THEN FRAME f-doc-pl:PARENT = ACTIVE-WINDOW.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame f-doc-pl
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
on choose of b-help in frame f-doc-pl
do:
  apply "help":u to frame f-doc-pl .
end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame f-doc-pl:width - 0.3
                fh            = frame f-doc-pl:first-child
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
def var vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  procedure disp-total :
    define input  parameter p-add-cli-qnty         like ub.doc-pl.cli-qnty         no-undo .
    define input  parameter p-add-doc-qnty         like ub.doc-pl.doc-qnty         no-undo .
    define input  parameter p-add-cli-doc-qnty     like ub.doc-pl.cli-doc-qnty     no-undo .
    define input  parameter p-add-fact-qnty        like ub.doc-pl.fact-qnty        no-undo .
    define input  parameter p-add-cli-fact-qnty    like ub.doc-pl.cli-fact-qnty    no-undo .
    define input  parameter p-add-rest-af-qnty     like ub.doc-pl.rest-af-qnty     no-undo .
    define input  parameter p-add-cli-rest-af-qnty like ub.doc-pl.cli-rest-af-qnty no-undo .
    assign
      f-tot-doc-pl-cli-qnty         = p-add-cli-qnty
      f-tot-doc-pl-doc-qnty         = p-add-doc-qnty
      f-tot-doc-pl-cli-doc-qnty     = p-add-cli-doc-qnty
      f-tot-doc-pl-fact-qnty        = p-add-fact-qnty
      f-tot-doc-pl-cli-fact-qnty    = p-add-cli-fact-qnty
      f-tot-doc-pl-rest-af-qnty     = p-add-rest-af-qnty
      f-tot-doc-pl-cli-rest-af-qnty = p-add-cli-rest-af-qnty
    .
    for each tt-doc-pl no-lock
    :
      assign
        f-tot-doc-pl-cli-qnty         = f-tot-doc-pl-cli-qnty         + tt-doc-pl.cli-qnty
        f-tot-doc-pl-doc-qnty         = f-tot-doc-pl-doc-qnty         + tt-doc-pl.doc-qnty
        f-tot-doc-pl-cli-doc-qnty     = f-tot-doc-pl-cli-doc-qnty     + tt-doc-pl.cli-doc-qnty
        f-tot-doc-pl-fact-qnty        = f-tot-doc-pl-fact-qnty        + tt-doc-pl.fact-qnty
        f-tot-doc-pl-cli-fact-qnty    = f-tot-doc-pl-cli-fact-qnty    + tt-doc-pl.cli-fact-qnty
        f-tot-doc-pl-rest-af-qnty     = f-tot-doc-pl-rest-af-qnty     + tt-doc-pl.rest-af-qnty
        f-tot-doc-pl-cli-rest-af-qnty = f-tot-doc-pl-cli-rest-af-qnty + tt-doc-pl.cli-rest-af-qnty
      .
    end.
    if f-tot-doc-pl-rest-af-qnty <> 0.0
      and f-tot-doc-pl-cli-rest-af-qnty <> 0.0
    then do:
      assign
        f-tot-doc-pl-rest-density = f-tot-doc-pl-cli-rest-af-qnty / f-tot-doc-pl-rest-af-qnty
      .
    end.
    else do:
      assign
        f-tot-doc-pl-rest-density = p-doc-line-rest-density
      .
    end.
    display
      f-tot-doc-pl-cli-qnty         when f-tot-doc-pl-cli-qnty         :visible = true
      f-tot-doc-pl-doc-qnty         when f-tot-doc-pl-doc-qnty         :visible = true
      f-tot-doc-pl-cli-doc-qnty     when f-tot-doc-pl-cli-doc-qnty     :visible = true
      f-tot-doc-pl-fact-qnty        when f-tot-doc-pl-fact-qnty        :visible = true
      f-tot-doc-pl-cli-fact-qnty    when f-tot-doc-pl-cli-fact-qnty    :visible = true
      f-tot-doc-pl-rest-af-qnty     when f-tot-doc-pl-rest-af-qnty     :visible = true
      f-tot-doc-pl-cli-rest-af-qnty when f-tot-doc-pl-cli-rest-af-qnty :visible = true
      f-tot-doc-pl-rest-density     when f-tot-doc-pl-rest-density     :visible = true
      with frame f-doc-pl
    .
    if f-tot-doc-pl-doc-qnty :visible = true
      and f-doc-line-doc-qnty :visible = true
    then do:
      if ( p-upd-units = "base":U
          and f-tot-doc-pl-doc-qnty <> f-doc-line-doc-qnty
        )
        or
        ( p-upd-units = "cli":U
          and absolute( f-tot-doc-pl-doc-qnty - f-doc-line-doc-qnty ) > 0.001
        )
      then do:
        assign
          f-tot-doc-pl-doc-qnty :fgcolor = 12
          f-doc-line-doc-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-doc-qnty :fgcolor = ?
          f-doc-line-doc-qnty   :fgcolor = ?
        .
      end.
    end.
    if f-tot-doc-pl-cli-doc-qnty :visible = true
      and f-doc-line-cli-doc-qnty :visible = true
    then do:
      if ( p-upd-units = "base":U
          and absolute( f-tot-doc-pl-cli-doc-qnty - f-doc-line-cli-doc-qnty ) > 0.001
         )
         or
         ( p-upd-units = "cli":U
           and f-tot-doc-pl-cli-doc-qnty <> f-doc-line-cli-doc-qnty
         )
      then do:
        assign
          f-tot-doc-pl-cli-doc-qnty :fgcolor = 12
          f-doc-line-cli-doc-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-cli-doc-qnty :fgcolor = ?
          f-doc-line-cli-doc-qnty   :fgcolor = ?
        .
      end.
    end.
    if f-tot-doc-pl-cli-qnty :visible = true
      and f-doc-line-cli-qnty :visible = true
    then do:
      if ( p-upd-units = "base":U
          and absolute( f-tot-doc-pl-cli-qnty - f-doc-line-cli-qnty ) > 0.001
         )
         or
         ( p-upd-units = "cli":U
           and f-tot-doc-pl-cli-qnty <> f-doc-line-cli-qnty
         )
      then do:
        assign
          f-tot-doc-pl-cli-qnty :fgcolor = 12
          f-doc-line-cli-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-cli-qnty :fgcolor = ?
          f-doc-line-cli-qnty   :fgcolor = ?
        .
      end.
    end.
    if f-tot-doc-pl-fact-qnty :visible = true
      and f-doc-line-fact-qnty :visible = true
    then do:
      if f-tot-doc-pl-fact-qnty <> f-doc-line-fact-qnty then do:
        assign
          f-tot-doc-pl-fact-qnty :fgcolor = 12
          f-doc-line-fact-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-fact-qnty :fgcolor = ?
          f-doc-line-fact-qnty   :fgcolor = ?
        .
      end.
    end.
    if f-tot-doc-pl-cli-fact-qnty :visible = true
      and f-doc-line-cli-fact-qnty :visible = true
    then do:
      if absolute( f-tot-doc-pl-cli-fact-qnty - f-doc-line-cli-fact-qnty ) > 0.001 then do:
        assign
          f-tot-doc-pl-cli-fact-qnty :fgcolor = 12
          f-doc-line-cli-fact-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-cli-fact-qnty :fgcolor = ?
          f-doc-line-cli-fact-qnty   :fgcolor = ?
        .
      end.
    end.
    if f-tot-doc-pl-rest-af-qnty :visible = true
      and f-doc-line-rest-af-qnty :visible = true
    then do:
      if f-tot-doc-pl-rest-af-qnty <> f-doc-line-rest-af-qnty then do:
        assign
          f-tot-doc-pl-rest-af-qnty :fgcolor = 12
          f-doc-line-rest-af-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-rest-af-qnty :fgcolor = ?
          f-doc-line-rest-af-qnty   :fgcolor = ?
        .
      end.
    end.
    if f-tot-doc-pl-cli-rest-af-qnty :visible = true
      and f-doc-line-cli-rest-af-qnty :visible = true
    then do:
      if absolute( f-tot-doc-pl-cli-rest-af-qnty - f-doc-line-cli-rest-af-qnty ) > 0.001 then do:
        assign
          f-tot-doc-pl-cli-rest-af-qnty :fgcolor = 12
          f-doc-line-cli-rest-af-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-cli-rest-af-qnty :fgcolor = ?
          f-doc-line-cli-rest-af-qnty   :fgcolor = ?
        .
      end.
    end.
  end procedure.
  procedure get-from-rvs :
    define input  parameter p-doc-code               like ub.trn-doc.doc-code                no-undo .
    define input  parameter p-gds-code               like ub.rvs-line.gds-code               no-undo .
    define input  parameter p-pl-code                like ub.rvs-line.pl-code                no-undo .
    define output parameter p-state-measure-qnty     like ub.rvs-line.state-measure-qnty     no-undo .
    define output parameter p-measure-qnty           like ub.rvs-line.measure-qnty           no-undo .
    define output parameter p-state-measure-cli-qnty like ub.rvs-line.state-measure-cli-qnty no-undo .
    define output parameter p-measure-cli-qnty       like ub.rvs-line.measure-cli-qnty       no-undo .
    define output parameter p-state-density          like ub.rvs-line.state-density          no-undo .
    define output parameter p-measure-density        like ub.rvs-line.density                no-undo .
    define output parameter p-label                  as   character                          no-undo .
    do
    on error  undo, return error substitute( "&1 (disp-from-rvs). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1 (disp-from-rvs). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (disp-from-rvs). endkey", vss-workfile )
    :
      define buffer rvs_trn-doc  for ub.trn-doc .
      define buffer bef_rvs-doc  for ub.rvs-doc  .
      define buffer aft_rvs-doc  for ub.rvs-doc  .
      define buffer bef_rvs-line for ub.rvs-line .
      define buffer aft_rvs-line for ub.rvs-line .
      assign
        p-state-measure-qnty     = 0
        p-measure-qnty           = 0
        p-state-measure-cli-qnty = 0
        p-measure-cli-qnty       = 0
        p-label                  = "":U
      .
      case buf_trn-doc.doc-type :
        when 'при':U then do:
          for each bef_rvs-doc no-lock
            where bef_rvs-doc.out-code  = p-doc-code
              and bef_rvs-doc.rvs-type  = 'перед_док':U
          :
            for each bef_rvs-line no-lock
              where bef_rvs-line.rvs-code = bef_rvs-doc.rvs-code
                and bef_rvs-line.obj-type = bef_rvs-doc.obj-type
                and bef_rvs-line.obj-code = bef_rvs-doc.obj-code
                and bef_rvs-line.pl-code  = p-pl-code
                and bef_rvs-line.gds-code = p-gds-code
            :
              assign
                p-state-measure-qnty     = p-state-measure-qnty     - bef_rvs-line.state-measure-qnty
                p-measure-qnty           = p-measure-qnty           - bef_rvs-line.measure-qnty
                p-state-measure-cli-qnty = p-state-measure-cli-qnty - bef_rvs-line.state-measure-cli-qnty
                p-measure-cli-qnty       = p-measure-cli-qnty       - bef_rvs-line.measure-cli-qnty
              .
            end .
          end .
          for each aft_rvs-doc no-lock
            where aft_rvs-doc.out-code  = p-doc-code
              and aft_rvs-doc.rvs-type  = 'после_док':U
          :
            for each aft_rvs-line no-lock
              where aft_rvs-line.rvs-code = aft_rvs-doc.rvs-code
                and aft_rvs-line.obj-type = aft_rvs-doc.obj-type
                and aft_rvs-line.obj-code = aft_rvs-doc.obj-code
                and aft_rvs-line.pl-code  = p-pl-code
                and aft_rvs-line.gds-code = p-gds-code
            :
              assign
                p-state-measure-qnty     = p-state-measure-qnty     + aft_rvs-line.state-measure-qnty
                p-measure-qnty           = p-measure-qnty           + aft_rvs-line.measure-qnty
                p-state-measure-cli-qnty = p-state-measure-cli-qnty + aft_rvs-line.state-measure-cli-qnty
                p-measure-cli-qnty       = p-measure-cli-qnty       + aft_rvs-line.measure-cli-qnty
              .
            end.
          end .
          assign
            p-state-density          = p-state-measure-cli-qnty / p-state-measure-qnty
            p-measure-density        = p-measure-cli-qnty / p-measure-qnty
          .
          assign
            p-label = "По сверкам":U
          .
        end.
        when 'инв':U then do:
          find first rvs_trn-doc no-lock
            where rvs_trn-doc.doc-code = p-doc-code
            .
          find first bef_rvs-doc no-lock
            where bef_rvs-doc.rvs-code = rvs_trn-doc.out-code
            no-error .
          if available bef_rvs-doc then do:
            assign
              p-label = "По сверке":U
            .
            find first bef_rvs-line no-lock
              where bef_rvs-line.rvs-code = bef_rvs-doc.rvs-code
                and bef_rvs-line.obj-type = bef_rvs-doc.obj-type
                and bef_rvs-line.obj-code = bef_rvs-doc.obj-code
                and bef_rvs-line.pl-code  = p-pl-code
                and bef_rvs-line.gds-code = p-gds-code
              no-error .
            if available bef_rvs-line then do:
              assign
                p-state-measure-qnty     = bef_rvs-line.state-measure-qnty
                p-measure-qnty           = bef_rvs-line.measure-qnty
                p-state-measure-cli-qnty = bef_rvs-line.state-measure-cli-qnty
                p-measure-cli-qnty       = bef_rvs-line.measure-cli-qnty
                p-state-density          = bef_rvs-line.state-density
                p-measure-density        = bef_rvs-line.density
              .
            end.
          end.
        end.
      end case.
    end.
  end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define buffer buf_clients for ub.clients .
  define buffer buf_rvs-doc for ub.rvs-doc .
  define buffer buf_tt-doc-pl for tt-doc-pl .
  if p-upd-field = "doc":U then do:
    assign
      p-doc-line-fact-cli-qnty = p-doc-line-doc-cli-qnty
      p-doc-line-fact-qnty     = p-doc-line-doc-qnty
    .
  end.
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
  .
  find first buf-upd_tt-doc-pl
    where buf-upd_tt-doc-pl.obj-type = buf_trn-doc.obj-type
      and buf-upd_tt-doc-pl.obj-code = buf_trn-doc.obj-code
      and buf-upd_tt-doc-pl.pl-code  = p-pl-code
      and buf-upd_tt-doc-pl.out-code = buf_trn-doc.doc-code
      and buf-upd_tt-doc-pl.gds-code = p-gds-code
    no-error .
  if not available buf-upd_tt-doc-pl then do:
    if p-mode = 'ПРОСМОТР':U then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Нет записи о редактируемом резервуаре" skip
        view-as alert-box error .
      return error .
    end.
  end.
def var vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-data-type as character no-undo .
  define variable is-petrol   as logical   no-undo .
  define variable is-pieces   as logical   no-undo .
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
  .
  assign
    f-units-base = "(" + trim( buf_goods.unit-base ) + ")"
    f-units-cli  = "(" + trim( buf_goods.unit-cli ) + ")"
    f-label-density = "Плотность"
  .
  assign
    f-doc-line-doc-density      = p-doc-line-doc-density
    f-doc-line-fact-density     = p-doc-line-fact-density
    f-doc-line-rest-density     = p-doc-line-rest-density
    f-doc-line-cli-qnty         = p-doc-line-cli-qnty
    f-doc-line-doc-qnty         = p-doc-line-doc-qnty
    f-doc-line-cli-doc-qnty     = p-doc-line-doc-cli-qnty
    f-doc-line-fact-qnty        = p-doc-line-fact-qnty
    f-doc-line-cli-fact-qnty    = p-doc-line-fact-cli-qnty
    f-doc-line-rest-af-qnty     = p-doc-line-rest-af-qnty
    f-doc-line-cli-rest-af-qnty = p-doc-line-cli-rest-af-qnty
  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ptrl':U
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
  if error-status :error
    or v-data-type <> "L":U
    or lookup( v-is-ptrl, "yes,no":U ) = 0
  then do:
    assign
      v-is-ptrl = "no":U
    .
  end.
  if v-is-ptrl = "yes":U then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
    if error-status :error
      or v-is-ptrl <> "yes"
      or is-petrol <>  yes
      or is-pieces <>  no
    then do:
      assign
        v-is-ptrl = "no":U
      .
    end.
    else do:
      assign
        v-is-ptrl = "yes":U
      .
    end.
  end.
  find first buf_clients no-lock
    where buf_clients.obj-type = buf_goods.prod-type
      and buf_clients.obj-code = buf_goods.prod-code
    .
  assign
    f-prod-name = buf_clients.obj-name
  .
  find first buf-obj_clients no-lock
    where buf-obj_clients.obj-type = buf_trn-doc.obj-type
      and buf-obj_clients.obj-code = buf_trn-doc.obj-code
    .
  create loc-t-doc-pl .
  if available buf-upd_tt-doc-pl then do:
    assign
      v-is-add = false
    .
    buffer-copy buf-upd_tt-doc-pl to loc-t-doc-pl .
  end.
  else do:
    assign
      v-is-add                            = true
      loc-t-doc-pl.obj-type               = buf_trn-doc.obj-type
      loc-t-doc-pl.obj-code               = buf_trn-doc.obj-code
      loc-t-doc-pl.out-code               = buf_trn-doc.doc-code
      loc-t-doc-pl.gds-code               = p-gds-code
    .
    if p-pl-code = ?
      or p-pl-code = 0
    then do:
      assign
        loc-t-doc-pl.pl-code = ?
      .
    end.
    else do:
      assign
        loc-t-doc-pl.pl-code = p-pl-code
      .
    end.
    assign
      loc-t-doc-pl.cli-qnty         = p-doc-line-cli-qnty
      loc-t-doc-pl.cli-doc-qnty     = p-doc-line-doc-cli-qnty
      loc-t-doc-pl.doc-qnty         = p-doc-line-doc-qnty
      loc-t-doc-pl.cli-fact-qnty    = p-doc-line-fact-cli-qnty
      loc-t-doc-pl.fact-qnty        = p-doc-line-fact-qnty
      loc-t-doc-pl.rest-af-qnty     = p-doc-line-rest-af-qnty
      loc-t-doc-pl.cli-rest-af-qnty = p-doc-line-cli-rest-af-qnty
    .
    for each buf_tt-doc-pl no-lock
      where buf_tt-doc-pl.obj-type = buf_trn-doc.obj-type
        and buf_tt-doc-pl.obj-code = buf_trn-doc.obj-code
        and buf_tt-doc-pl.out-code = buf_trn-doc.doc-code
        and buf_tt-doc-pl.gds-code = p-gds-code
    on error undo, return error return-value
    :
      assign
        loc-t-doc-pl.cli-qnty         = loc-t-doc-pl.cli-qnty         - buf_tt-doc-pl.cli-qnty
        loc-t-doc-pl.cli-doc-qnty     = loc-t-doc-pl.cli-doc-qnty     - buf_tt-doc-pl.cli-doc-qnty
        loc-t-doc-pl.doc-qnty         = loc-t-doc-pl.doc-qnty         - buf_tt-doc-pl.doc-qnty
        loc-t-doc-pl.cli-fact-qnty    = loc-t-doc-pl.cli-fact-qnty    - buf_tt-doc-pl.cli-fact-qnty
        loc-t-doc-pl.fact-qnty        = loc-t-doc-pl.fact-qnty        - buf_tt-doc-pl.fact-qnty
        loc-t-doc-pl.rest-af-qnty     = loc-t-doc-pl.rest-af-qnty     - buf_tt-doc-pl.rest-af-qnty
        loc-t-doc-pl.cli-rest-af-qnty = loc-t-doc-pl.cli-rest-af-qnty - buf_tt-doc-pl.cli-rest-af-qnty
      .
    end.
  end.
  assign
    f-doc-pl-doc-density  = p-doc-line-doc-density
    f-doc-pl-fact-density = p-doc-line-fact-density
  .
  if p-upd-field = "rest":U
    or p-upd-field = "rest-fact":U
  then do:
    if loc-t-doc-pl.rest-af-qnty <> 0.0
      and loc-t-doc-pl.cli-rest-af-qnty <> 0.0
    then do:
      assign
        f-doc-pl-rest-density = loc-t-doc-pl.cli-rest-af-qnty / loc-t-doc-pl.rest-af-qnty
      .
    end.
    else do:
      assign
        f-doc-pl-rest-density = p-doc-line-rest-density
      .
    end.
  end.
  RUN enable_UI.
  if v-is-add = true then do:
def var vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input loc-t-doc-pl.cli-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-qnty         else 0.0 )
     ,input loc-t-doc-pl.doc-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.doc-qnty         else 0.0 )
     ,input loc-t-doc-pl.cli-doc-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-doc-qnty     else 0.0 )
     ,input loc-t-doc-pl.fact-qnty        - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.fact-qnty        else 0.0 )
     ,input loc-t-doc-pl.cli-fact-qnty    - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-fact-qnty    else 0.0 )
     ,input loc-t-doc-pl.rest-af-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.rest-af-qnty     else 0.0 )
     ,input loc-t-doc-pl.cli-rest-af-qnty - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-rest-af-qnty else 0.0 )
    ).
  end.
  else do:
def var vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
    ).
  end.
def var vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if buf_goods.unit-base <> buf_goods.unit-cli then do:
    display
      f-units-cli
      with frame f-doc-pl.
    if v-is-ptrl = "yes":U then do:
      display
        f-label-density
        with frame f-doc-pl.
    end.
  end.
  if buf_trn-doc.doc-type = 'при':U
    and buf_trn-doc.internal = false
  then do:
    assign
      f-doc-line-cli-qnty :label in frame f-doc-pl = substitute( "по ТТН (&1)", p-doc-line-unit-cli )
      f-tot-doc-pl-cli-qnty :label in frame f-doc-pl = substitute( "по ТТН (&1)", p-doc-line-unit-cli )
    .
    display
      f-doc-line-cli-qnty
      f-tot-doc-pl-cli-qnty
      with frame f-doc-pl
    .
  end.
  case p-upd-field :
    when "rest":U
    or when "rest-fact":U
    then do:
      if p-upd-field = "rest":U then do:
        assign
          f-tot-doc-pl-rest-af-qnty     :bgcolor = 8
          f-tot-doc-pl-cli-rest-af-qnty :bgcolor = 8
          f-tot-doc-pl-rest-density     :bgcolor = 8
        .
      end.
      else do:
        assign
          f-tot-doc-pl-fact-qnty     :bgcolor = 8
          f-tot-doc-pl-cli-fact-qnty :bgcolor = 8
        .
      end.
      assign
        f-tot-doc-pl-fact-qnty        :label in frame f-doc-pl = substitute( "Разница" )
        f-tot-doc-pl-rest-af-qnty     :row in frame f-doc-pl   = f-tot-doc-pl-doc-qnty :row in frame f-doc-pl
        f-tot-doc-pl-rest-af-qnty     :handle :side-label-handle :row in frame f-doc-pl = f-tot-doc-pl-doc-qnty :row in frame f-doc-pl
        f-tot-doc-pl-cli-rest-af-qnty :row in frame f-doc-pl   = f-tot-doc-pl-rest-af-qnty :row in frame f-doc-pl
        f-tot-doc-pl-rest-density     :row in frame f-doc-pl   = f-tot-doc-pl-rest-af-qnty :row in frame f-doc-pl
        rect-tot :height-chars in frame f-doc-pl = 3.5
        frame f-doc-pl :height-chars = frame f-doc-pl :height-chars - 3.5
      .
      display
        f-tot-doc-pl-fact-qnty
        f-tot-doc-pl-cli-fact-qnty    when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-pl-rest-af-qnty
        f-tot-doc-pl-cli-rest-af-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-pl-rest-density     when buf_goods.unit-base <> buf_goods.unit-cli
        with frame f-doc-pl.
        .
    end.
    when "doc":U then do:
      assign
        f-tot-doc-pl-doc-qnty     :bgcolor = 8
        f-tot-doc-pl-cli-doc-qnty :bgcolor = 8
        f-doc-line-doc-qnty       :bgcolor = 8
        f-doc-line-cli-doc-qnty   :bgcolor = 8
        f-doc-line-doc-density    :bgcolor = 8
      .
      display
        f-tot-doc-pl-doc-qnty
        f-tot-doc-pl-cli-doc-qnty  when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-label
        f-doc-line-doc-qnty
        f-doc-line-cli-doc-qnty    when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-line-doc-density     when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame f-doc-pl
        .
    end.
    when "fact":U then do:
      assign
        f-tot-doc-pl-fact-qnty     :bgcolor = 8
        f-tot-doc-pl-cli-fact-qnty :bgcolor = 8
        f-doc-line-fact-qnty       :bgcolor = 8
        f-doc-line-cli-fact-qnty   :bgcolor = 8
        f-doc-line-fact-density    :bgcolor = 8
      .
      display
        f-tot-doc-pl-doc-qnty
        f-tot-doc-pl-fact-qnty
        f-tot-doc-pl-cli-doc-qnty  when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-pl-cli-fact-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-label
        f-doc-line-doc-qnty
        f-doc-line-fact-qnty
        f-doc-line-cli-doc-qnty    when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-line-cli-fact-qnty   when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-line-doc-density     when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-line-fact-density    when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame f-doc-pl
        .
    end.
    when "fact-doc":U then do:
      assign
        f-tot-doc-pl-fact-qnty     :bgcolor = 8
        f-tot-doc-pl-cli-fact-qnty :bgcolor = 8
        f-doc-line-fact-qnty       :bgcolor = 8
        f-doc-line-cli-fact-qnty   :bgcolor = 8
        f-doc-line-fact-density    :bgcolor = 8
      .
      display
        f-tot-doc-pl-fact-qnty
        f-tot-doc-pl-cli-fact-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-label
        f-doc-line-fact-qnty
        f-doc-line-cli-fact-qnty   when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-line-fact-density    when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame f-doc-pl
        .
    end.
  end case.
  if v-is-ptrl = "yes"
  then do:
    rvsinvObj = new rvsinvsub ().
    assign
      rvsinvObj:RvsCode = buf_trn-doc.out-code
      rvsinvObj:ObjCode = loc-t-doc-pl.obj-code
      rvsinvObj:ObjType = loc-t-doc-pl.obj-type
      rvsinvObj:PlCode = loc-t-doc-pl.pl-code
      rvsinvObj:GdsCode = loc-t-doc-pl.gds-code
    .
    if rvsinvObj:RvsInvStrObj:FillSub(rvsinvObj)
    then do:
        assign
          f-tot-doc-pl-rest-af-qnty     :row in frame f-doc-pl   = f-tot-doc-pl-doc-qnty :row in frame f-doc-pl - 1
          f-tot-doc-pl-rest-af-qnty     :handle :side-label-handle :row in frame f-doc-pl = f-tot-doc-pl-doc-qnty :row in frame f-doc-pl - 1
          f-tot-doc-pl-cli-rest-af-qnty :row in frame f-doc-pl   = f-tot-doc-pl-rest-af-qnty :row in frame f-doc-pl
          f-tot-doc-pl-rest-density     :row in frame f-doc-pl   = f-tot-doc-pl-rest-af-qnty :row in frame f-doc-pl
        .
        assign
          frame f-doc-pl :height-chars = frame f-doc-pl :height-chars + 1
          rect-tot :height-chars in frame f-doc-pl = 4.5
        .
        if rvsinvObj:Diff < 0
        then do:
          assign
            f-otrnebal = absolute (rvsinvObj:Diff)
            f-otrmetrerr = rvsinvObj:MeterErrWast
            f-nedos = rvsinvObj:DeficitOver
            f-wastcli = rvsinvObj:NaturWast
            f-wast-tp = rvsinvObj:TPWast
          .
        end.
        else do:
          assign
            f-polnebal = absolute (rvsinvObj:Diff)
            f-polmetrerr = rvsinvObj:MeterErrWast
            f-izlish = rvsinvObj:DeficitOver
          .
        end.
        display
        f-otrnebal
        f-polnebal
        f-lblnebal
        f-lblpolnebal
        f-lblotrnebal
        f-lblmetrerr
        f-polmetrerr
        f-otrmetrerr
        f-lblwastcli
        f-wastcli
        f-lblwast-tp
        f-wast-tp
        f-lbldiff
        f-izlish
        f-nedos
          with frame f-doc-pl
        .
        hide
          f-tot-doc-pl-fact-qnty
          f-tot-doc-pl-cli-fact-qnty
        in frame f-doc-pl
        .
      if rvsinvObj:Diff < 0
      then do:
        f-otrnebal = rvsinvObj:Diff.
      end.
      else do:
      end.
    end.
  end.
  if buf_trn-doc.doc-type = 'при':U
    and buf_trn-doc.internal = false
  then do:
    assign
      loc-t-doc-pl.cli-qnty   :label in frame f-doc-pl = substitute( "по ТТН (&1)", p-doc-line-unit-cli )
    .
    display
      loc-t-doc-pl.cli-qnty
      with frame f-doc-pl.
      .
  end.
  case p-upd-field :
    when "rest":U
    or when "rest-fact":U
    then do:
      assign
        loc-t-doc-pl.fact-qnty        :label in frame f-doc-pl = substitute( "Разница" )
        loc-t-doc-pl.rest-af-qnty     :row in frame f-doc-pl   = loc-t-doc-pl.doc-qnty :row in frame f-doc-pl
        loc-t-doc-pl.rest-af-qnty     :handle :side-label-handle :row in frame f-doc-pl = loc-t-doc-pl.rest-af-qnty :row in frame f-doc-pl
        loc-t-doc-pl.cli-rest-af-qnty :row in frame f-doc-pl   = loc-t-doc-pl.rest-af-qnty :row in frame f-doc-pl
        f-doc-pl-rest-density         :row in frame f-doc-pl   = loc-t-doc-pl.rest-af-qnty :row in frame f-doc-pl
      .
      display
        loc-t-doc-pl.fact-qnty
        loc-t-doc-pl.rest-af-qnty
        loc-t-doc-pl.cli-fact-qnty    when buf_goods.unit-base <> buf_goods.unit-cli
        loc-t-doc-pl.cli-rest-af-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-pl-rest-density         when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame f-doc-pl.
        .
    end.
    when "doc":U then do:
      display
        loc-t-doc-pl.doc-qnty
        loc-t-doc-pl.cli-doc-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-pl-doc-density      when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame f-doc-pl
        .
    end.
    when "fact":U then do:
      display
        loc-t-doc-pl.doc-qnty
        loc-t-doc-pl.fact-qnty
        loc-t-doc-pl.cli-doc-qnty  when buf_goods.unit-base <> buf_goods.unit-cli
        loc-t-doc-pl.cli-fact-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-pl-doc-density       when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-pl-fact-density      when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame f-doc-pl
        .
    end.
    when "fact-doc":U then do:
      display
        loc-t-doc-pl.fact-qnty
        loc-t-doc-pl.cli-fact-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-pl-fact-density      when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame f-doc-pl
        .
    end.
  end case.
  if p-mode = 'ПРОСМОТР':U
    or buf_trn-doc.status_ = 'факт':U
  then do:
    disable
      all
      with frame f-doc-pl
    .
    enable
      b-quit
      b-help
      with frame f-doc-pl
    .
  end.
  else do:
    if p-mode = 'АВТОИЗМЕНЕНИЕ':U then do:
      assign
        v-msg-on = true
      .
    end.
    else do:
      assign
        v-msg-on = false
      .
    end.
    find first buf_rvs-doc no-lock
      where buf_rvs-doc.out-code = buf_trn-doc.doc-code
        and ( buf_rvs-doc.rvs-type = 'перед_док':U
              or buf_rvs-doc.rvs-type = 'после_док':U
            )
      no-error .
    if p-upd-field = "doc":U
      or p-upd-field = "fact":U
      or p-upd-field = "fact-doc":U
    then do:
      enable
        b-qnty
        with frame f-doc-pl.
      if ( ( buf_trn-doc.doc-type = 'при':U
            and not available buf_rvs-doc
          )
          or buf_trn-doc.doc-type <> 'при':U
        )
      then do:
        enable
          loc-t-doc-pl.pl-code
          b-place
          with frame f-doc-pl.
        if loc-t-doc-pl.pl-code = ? then do:
          apply "choose" to b-place in frame f-doc-pl .
        end.
      end.
    end.
    case p-upd-field :
      when "rest":U then do:
        if buf_goods.unit-base <> buf_goods.unit-cli then do:
          enable
            f-doc-pl-rest-density
            with frame f-doc-pl.
        end.
        if p-upd-units = "cli":U
          and loc-t-doc-pl.cli-rest-af-qnty :visible = true
        then do:
          enable
            loc-t-doc-pl.cli-rest-af-qnty
            with frame f-doc-pl.
        end.
        else do:
          enable
            loc-t-doc-pl.rest-af-qnty
            with frame f-doc-pl.
        end.
      end.
      when "rest-fact":U then do:
        if loc-t-doc-pl.cli-fact-qnty :visible = true then do:
          enable
            loc-t-doc-pl.cli-fact-qnty
            with frame f-doc-pl.
        end.
        if loc-t-doc-pl.fact-qnty :visible = true then do:
          enable
            loc-t-doc-pl.fact-qnty
            with frame f-doc-pl.
        end.
      end.
      when "doc":U then do:
        if p-upd-units = "cli":U
          and loc-t-doc-pl.cli-doc-qnty :visible = true
        then do:
          enable
            loc-t-doc-pl.cli-doc-qnty
            with frame f-doc-pl.
          apply "leave" to loc-t-doc-pl.cli-doc-qnty in frame f-doc-pl .
        end.
        else do:
          enable
            loc-t-doc-pl.doc-qnty
            with frame f-doc-pl.
          apply "leave" to loc-t-doc-pl.doc-qnty in frame f-doc-pl .
        end.
      end.
      when "fact":U
      or when "fact-doc":U
      then do:
        if p-upd-units = "cli":U
          and loc-t-doc-pl.cli-fact-qnty :visible = true
        then do:
          enable
            loc-t-doc-pl.cli-fact-qnty
            with frame f-doc-pl.
          apply "leave" to loc-t-doc-pl.cli-fact-qnty in frame f-doc-pl .
        end.
        else do:
          enable
            loc-t-doc-pl.fact-qnty
            with frame f-doc-pl.
          apply "leave" to loc-t-doc-pl.fact-qnty in frame f-doc-pl .
        end.
      end.
    end case.
    assign
      v-msg-on = true
    .
  end.
  apply "value-changed" to loc-t-doc-pl.pl-code in frame f-doc-pl.
  WAIT-FOR GO OF FRAME f-doc-pl.
END.
RUN disable_UI.
delete loc-t-doc-pl .
PROCEDURE calc-qnty :
do
  on error undo, return error return-value
  :
    case p-upd-field :
      when "rest":U then do:
        assign
          loc-t-doc-pl.fact-qnty     = loc-t-doc-pl.rest-af-qnty - loc-t-doc-pl.rest-bf-qnty
          loc-t-doc-pl.cli-fact-qnty = loc-t-doc-pl.cli-rest-af-qnty - loc-t-doc-pl.cli-rest-bf-qnty
        .
      end.
      when "rest-fact":U then do:
        assign
          loc-t-doc-pl.rest-af-qnty     = loc-t-doc-pl.rest-bf-qnty + loc-t-doc-pl.fact-qnty
          loc-t-doc-pl.cli-rest-af-qnty = loc-t-doc-pl.cli-rest-bf-qnty + loc-t-doc-pl.cli-fact-qnty
        .
        if loc-t-doc-pl.rest-af-qnty <> 0.0
          and loc-t-doc-pl.cli-rest-af-qnty <> 0.0
        then do:
          assign
            f-doc-pl-rest-density = loc-t-doc-pl.cli-rest-af-qnty / loc-t-doc-pl.rest-af-qnty
          .
        end.
        else do:
          assign
            f-doc-pl-rest-density = p-doc-line-rest-density
          .
        end.
      end.
    end case.
    display
      loc-t-doc-pl.cli-qnty         when loc-t-doc-pl.cli-qnty :visible = true
      loc-t-doc-pl.doc-qnty         when loc-t-doc-pl.doc-qnty :visible = true
      loc-t-doc-pl.cli-doc-qnty     when loc-t-doc-pl.cli-doc-qnty :visible = true
      loc-t-doc-pl.fact-qnty        when loc-t-doc-pl.fact-qnty :visible = true
      loc-t-doc-pl.cli-fact-qnty    when loc-t-doc-pl.cli-fact-qnty :visible = true
      loc-t-doc-pl.rest-af-qnty     when loc-t-doc-pl.rest-af-qnty :visible = true
      loc-t-doc-pl.cli-rest-af-qnty when loc-t-doc-pl.cli-rest-af-qnty :visible = true
      f-doc-pl-rest-density         when f-doc-pl-rest-density :visible = true
      with frame f-doc-pl.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME f-doc-pl.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-prod-name f-units-base
      WITH FRAME f-doc-pl.
  IF AVAILABLE buf-obj_clients THEN
    DISPLAY buf-obj_clients.obj-type buf-obj_clients.obj-code
          buf-obj_clients.obj-name
      WITH FRAME f-doc-pl.
  IF AVAILABLE buf_goods THEN
    DISPLAY buf_goods.gds-code buf_goods.gds-name buf_goods.artic
          buf_goods.prod-type buf_goods.prod-code
      WITH FRAME f-doc-pl.
  IF AVAILABLE buf_place THEN
    DISPLAY buf_place.pl-name buf_place.loc1 buf_place.loc2 buf_place.loc3
          buf_place.loc4
      WITH FRAME f-doc-pl.
  IF AVAILABLE loc-t-doc-pl THEN
    DISPLAY loc-t-doc-pl.pl-code
      WITH FRAME f-doc-pl.
  ENABLE b-exit b-quit b-help
      WITH FRAME f-doc-pl.
END PROCEDURE.
