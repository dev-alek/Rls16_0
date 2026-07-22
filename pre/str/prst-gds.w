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
define temp-table tt-gds-dtl no-undo
field gds-code like ub.goods.gds-code
field prt-code like ub.gds-dtl.prt-code
field qnty     as   decimal
index pi is unique primary gds-code prt-code.
define temp-table tt-gds-dtl-plus no-undo
field gds-code like ub.goods.gds-code
field prt-code like ub.gds-dtl.prt-code
field qnty     as   decimal
index pi is unique primary gds-code prt-code.
define temp-table tt-pl-qty no-undo
field pl-code like ub.place.pl-code
field qnty-l  as   decimal
field qnty-kg as   decimal
index pi is unique primary pl-code.
define temp-table tt-pl-qty-plus no-undo
field pl-code like ub.place.pl-code
field qnty-l  as   decimal
field rsrv-l  as   decimal
field qnty-kg as   decimal
index pi is unique primary pl-code.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define input  parameter parparentproc       as   handle              no-undo.
define input  parameter pardoc-code         like ub.trn-doc.doc-code no-undo.
define input  parameter parmode             as   character           no-undo.
define input  parameter parobj-type         as   character           no-undo.
define input  parameter parobj-code         as   integer             no-undo.
define input  parameter pargds-code         like ub.goods.gds-code   no-undo.
define input  parameter pargds-code-plus    like ub.goods.gds-code   no-undo.
define input  parameter parqnty             as   decimal             no-undo.
define input  parameter parqnty-kg          as   decimal             no-undo.
define input  parameter parqnty-plus        as   decimal             no-undo.
define input  parameter parqnty-kg-plus     as   decimal             no-undo.
define input  parameter parpstunqtn-log     as   logical             no-undo.
define input  parameter parpstunit          as   logical             no-undo.
define input  parameter parmxpcicp-dec      as   decimal             no-undo.
define input  parameter parmxpcdcp-dec      as   decimal             no-undo.
define input  parameter parmxsmicp-dec      as   decimal             no-undo.
define input  parameter parmxsmdcp-dec      as   decimal             no-undo.
define output parameter paroutgds-code      like ub.goods.gds-code initial ?  no-undo.
define output parameter paroutgds-code-plus like ub.goods.gds-code initial ?  no-undo.
define output parameter table for tt-gds-dtl.
define output parameter table for tt-pl-qty.
define output parameter paroutqnty          as   decimal           initial ?  no-undo.
define output parameter paroutqnty-plus     as   decimal           initial ?  no-undo.
define output parameter paroutqnty-kg       as   decimal           initial ?  no-undo.
define output parameter paroutqnty-kg-plus  as   decimal           initial ?  no-undo.
define output parameter table for tt-gds-dtl-plus.
define output parameter table for tt-pl-qty-plus.
define output parameter parset              as   logical           initial no no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Экран определения строки пересортицы":U .
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
DEFINE BUFFER bf_goods        FOR ub.goods.
DEFINE BUFFER bf_goods-plus   FOR ub.goods.
DEFINE BUFFER bf_units        FOR ub.units.
DEFINE BUFFER bf_units-plus   FOR ub.units.
DEFINE BUFFER bf_clients      FOR ub.clients.
DEFINE BUFFER bf_clients-plus FOR ub.clients.
define buffer bf_clients-host for ub.clients.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure grp-attr-name :
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
            when 'gds-grp-nabor':U then do:     assign     p-label = "Набор"     p-type = 'L':U      p-format = "yes/no"     p-label = "Набор"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
      otherwise do:
        undo, return error "Неизвестный атрибут группы товаров на фирме" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure grp-attr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'gds-grp-nabor':U then do:     assign     p-tooltip = "Набор - не товарные позиции"     p-label = "Набор" .   end.
      otherwise do:
            undo, return error "Неизвестный атрибут группы товаров на фирме" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure grp-attr-value :
do
on error undo, return error
:
define input  parameter p-node-code   as integer    no-undo.
define input  parameter p-code        as character  no-undo.
define input  parameter p-host-code   as integer    no-undo.
define input  parameter p-obj-type    as character  no-undo.
define input  parameter p-obj-code    as integer    no-undo.
define output parameter p-value       as character  no-undo.
define output parameter p-type        as character  no-undo.
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define buffer buf_gds-grp-attr for ub.gds-grp-attr.
    run grp-attr-name in this-procedure (
          input  p-code
        , output p-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    find first buf_gds-grp-attr no-lock
         where buf_gds-grp-attr.node-code = p-node-code
           and buf_gds-grp-attr.attr-code = p-code
           and buf_gds-grp-attr.host-code = p-host-code
           and buf_gds-grp-attr.obj-type  = p-obj-type
           and buf_gds-grp-attr.obj-code  = p-obj-code
    no-error .
    if available buf_gds-grp-attr
    then do:
        assign
            p-value = buf_gds-grp-attr.attr-value
        .
    end.
    else do:
        assign
            p-value = if p-type = 'L':U then "no":U else ""
        .
    end.
end.
end procedure.
procedure grp-attr-write :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-attr.node-code      no-undo.
define input parameter p-code       like ub.gds-grp-attr.attr-code      no-undo.
define input parameter p-host-code  as integer                          no-undo.
define input parameter p-obj-type   like ub.clients.obj-type            no-undo.
define input parameter p-obj-code   like ub.clients.obj-code            no-undo.
define input parameter p-value      like ub.gds-grp-attr.attr-value     no-undo.
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    define buffer buf_gds-grp-attr for ub.gds-grp-attr .
    run grp-attr-name in this-procedure (
                      input  p-code
                    , output v-type
                    , output v-format
                    , output v-label
                    , output v-user-can-edit
                    , output v-output-display
                    , output v-other
    ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.
    find first buf_gds-grp-attr exclusive-lock
         where buf_gds-grp-attr.node-code  = p-node-code
           and buf_gds-grp-attr.attr-code  = p-code
           and buf_gds-grp-attr.host-code  = p-host-code
           and buf_gds-grp-attr.obj-type   = p-obj-type
           and buf_gds-grp-attr.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-attr
    then do:
        create buf_gds-grp-attr.
        assign
                buf_gds-grp-attr.node-code  = p-node-code
                buf_gds-grp-attr.attr-code  = p-code
                buf_gds-grp-attr.host-code  = p-host-code
                buf_gds-grp-attr.obj-type   = p-obj-type
                buf_gds-grp-attr.obj-code   = p-obj-code
                buf_gds-grp-attr.attr-value = p-value
        .
    end.
    else do:
        assign
            buf_gds-grp-attr.attr-value = p-value
        .
    end.
end.
end procedure.
procedure grp-attr-delete :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-attr.node-code  no-undo.
define input parameter p-code       like ub.gds-grp-attr.attr-code  no-undo.
define input parameter p-host-code  as integer                      no-undo.
define input parameter p-obj-type   like ub.clients.obj-type        no-undo.
define input parameter p-obj-code   like ub.clients.obj-code        no-undo.
define output parameter p-deleted   as logical                      no-undo.
    define buffer buf_gds-grp-attr for ub.gds-grp-attr .
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    run grp-attr-name in this-procedure
    ( input  p-code
    , output v-type
    , output v-format
    , output v-label
    , output v-user-can-edit
    , output v-output-display
    , output v-other
    ) no-error .
    if error-status :error then do:
        undo, return error return-value .
    end.
    find first buf_gds-grp-attr exclusive-lock
         where buf_gds-grp-attr.node-code  = p-node-code
           and buf_gds-grp-attr.attr-code  = p-code
           and buf_gds-grp-attr.host-code  = p-host-code
           and buf_gds-grp-attr.obj-type   = p-obj-type
           and buf_gds-grp-attr.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-attr
    then do:
        assign
            p-deleted = no
        .
    end.
    else do:
       delete buf_gds-grp-attr.
       assign
            p-deleted = yes
        .
    end.
end.
end procedure.
procedure grp-attr-news :
do
on error undo, return error
:
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'gds-grp-nabor':U then do:     assign     p-news = true.   end.
      otherwise do:
        undo, return error "неизвестный атрибут товара на фирме" + " " + p-code .
      end.
    end.
end.
end procedure.
procedure grp-attr-obj-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define input parameter p-attr-code as character    no-undo .
define output parameter p-attr-value     as character   no-undo.
define output parameter p-range     as integer      no-undo.
define output parameter p-exists    as logical      no-undo.
define variable v-host-code as integer      no-undo.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_gds-grp-attr      for ub.gds-grp-attr.
find first buf_gds-grp-attr no-lock
     where buf_gds-grp-attr.node-code = p-node-code
       and buf_gds-grp-attr.attr-code = p-attr-code
       and buf_gds-grp-attr.host-code = v-host-code
       and buf_gds-grp-attr.obj-type  = p-obj-type
       and buf_gds-grp-attr.obj-code  = p-obj-code
no-error .
if not available buf_gds-grp-attr
then do:
    find first buf_gds-grp-attr no-lock
         where buf_gds-grp-attr.node-code = p-node-code
           and buf_gds-grp-attr.attr-code = p-attr-code
           and buf_gds-grp-attr.host-code = v-host-code
           and buf_gds-grp-attr.obj-type  = ""
           and buf_gds-grp-attr.obj-code  = 0
    no-error .
    if not available buf_gds-grp-attr
    then do:
        find first buf_gds-grp-attr no-lock
            where buf_gds-grp-attr.node-code = p-node-code
            and buf_gds-grp-attr.attr-code = p-attr-code
            and buf_gds-grp-attr.host-code = 0
            and buf_gds-grp-attr.obj-type  = ""
            and buf_gds-grp-attr.obj-code  = 0
        no-error .
        if not available buf_gds-grp-attr
        then do:
            assign
                p-exists = no
            .
        end.
        else do:
            assign
                p-exists = yes
                p-range  = 1
            .
        end.
    end.
    else do:
        assign
            p-exists = yes
            p-range  = 2
        .
    end.
end.
else do:
    assign
        p-exists = yes
        p-range  = 3
    .
end.
if available buf_gds-grp-attr
then do:
  assign
  p-attr-value = buf_gds-grp-attr.attr-value
  .
end.
end.
end procedure.
procedure ver-gds-grp-nabor :
do
on error undo, return error return-value
:
define input  parameter p-gds-code as integer   no-undo .
define output parameter p-nabor as logical   no-undo .
define buffer buf_goods for ub.goods.
p-nabor = false .
find first  buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
if error-status :error then return error .
define variable v-value       as character  no-undo.
define variable v-type        as character  no-undo.
  run grp-attr-value (
     input   buf_goods.grp-code
    ,input   'gds-grp-nabor':U
    ,input   0
    ,input   ""
    ,input   0
    ,output  v-value
    ,output  v-type       ) no-error .
    if error-status :error then return error .
  if v-value = "yes" then p-nabor = true  .
end.
end procedure.
define new shared temp-table tt-gds-prt no-undo
field prt-code like ub.gds-dtl.prt-code
field prt-name as character
field write-off-before-qnty as decimal format ">,>>>,>>>,>>9.9999"
field income-before-qnty    as decimal format ">,>>>,>>>,>>9.9999"
field write-off-qnty        as decimal format ">,>>>,>>>,>>9.9999"
field income-qnty           as decimal format ">,>>>,>>>,>>9.9999"
field fact-qnty             as decimal format ">,>>>,>>>,>>9.9999"
index pi is unique primary prt-code.
define new shared temp-table tt-place no-undo
field pl-code             like ub.place.pl-code
field loc1                like ub.place.loc1
field pl-name             like ub.place.pl-name
field before-l            as   decimal format ">,>>>,>>>,>>9.9999"
field before-kg           as   decimal format ">,>>>,>>>,>>9.9999"
field write-off-l         as   decimal format ">,>>>,>>>,>>9.9999"
field income-l            as   decimal format ">,>>>,>>>,>>9.9999"
field write-off-kg        as   decimal format ">,>>>,>>>,>>9.9999"
field income-kg           as   decimal format ">,>>>,>>>,>>9.9999"
field write-off-doc-l     as   decimal format ">,>>>,>>>,>>9.9999"
field income-doc-l        as   decimal format ">,>>>,>>>,>>9.9999"
field write-off-doc-kg    as   decimal format ">,>>>,>>>,>>9.9999"
field income-doc-kg       as   decimal format ">,>>>,>>>,>>9.9999"
index pi is unique primary pl-code.
define variable is-petrol      as logical no-undo.
define variable is-pieces      as logical no-undo.
define variable is-petrol-plus as logical no-undo.
define variable is-pieces-plus as logical no-undo.
define variable vargds-dtl-qnty          as decimal no-undo.
define variable varmem-gds-dtl-qnty      as decimal no-undo.
define variable vargds-dtl-qnty-plus     as decimal no-undo.
define variable varmem-gds-dtl-qnty-plus as decimal no-undo.
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-prt-in
     LABEL "Шкала оп."
     SIZE 10 BY 1.
DEFINE BUTTON b-prt-wr
     LABEL "Шкала сп."
     SIZE 10 BY 1.
DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-goods
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON r-goods-plus
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON r-list
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON r-list-plus
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE VARIABLE varartic AS CHARACTER FORMAT "X(256)":U
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varartic-plus AS CHARACTER FORMAT "X(256)":U
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE varfull-scale-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Шкала"
     VIEW-AS FILL-IN
     SIZE 57 BY 1 NO-UNDO.
DEFINE VARIABLE varfull-scale-name-plus AS CHARACTER FORMAT "X(256)":U
     LABEL "Шкала"
     VIEW-AS FILL-IN
     SIZE 57.5 BY 1 NO-UNDO.
DEFINE VARIABLE vargds-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 57 BY 1 NO-UNDO.
DEFINE VARIABLE vargds-name-plus AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 57.5 BY 1 NO-UNDO.
DEFINE VARIABLE varprod-code AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     LABEL "Производитель"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varprod-code-plus AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     LABEL "Производитель"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varprod-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE varprod-type-plus AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE varqnty AS DECIMAL FORMAT ">>>,>>>,>>9.999":U INITIAL 0
     LABEL "Списываемое количество"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varqnty-kg AS DECIMAL FORMAT ">>>,>>>,>>9.999":U INITIAL 0
     LABEL "Кг"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varqnty-kg-plus AS DECIMAL FORMAT ">>>,>>>,>>9.999":U INITIAL 0
     LABEL "Кг"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varqnty-plus AS DECIMAL FORMAT ">>>,>>>,>>9.999":U INITIAL 0
     LABEL "Приходуемое количество"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varunit-name AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE varunit-name-plus AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.5 BY .08.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.5 BY .08.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-prt-wr AT ROW 1 COL 21
     varqnty-kg AT ROW 5.5 COL 45 COLON-ALIGNED
     varartic AT ROW 3 COL 14 COLON-ALIGNED
     b-help AT ROW 1 COL 88.5
     r-goods AT ROW 3 COL 33.5
     r-list AT ROW 3 COL 37
     vargds-name AT ROW 3 COL 39.5 COLON-ALIGNED NO-LABEL
     varprod-code AT ROW 4.25 COL 14 COLON-ALIGNED
     varprod-type AT ROW 4.25 COL 28 COLON-ALIGNED NO-LABEL
     varfull-scale-name AT ROW 4.25 COL 34.5
     varqnty AT ROW 5.5 COL 23 COLON-ALIGNED
     varunit-name AT ROW 5.5 COL 36.5 COLON-ALIGNED NO-LABEL
     varartic-plus AT ROW 7.5 COL 14.5 COLON-ALIGNED
     r-goods-plus AT ROW 7.5 COL 34
     r-list-plus AT ROW 7.5 COL 37
     vargds-name-plus AT ROW 7.5 COL 39 COLON-ALIGNED NO-LABEL
     varprod-code-plus AT ROW 8.75 COL 14.5 COLON-ALIGNED
     varprod-type-plus AT ROW 8.75 COL 28 COLON-ALIGNED NO-LABEL
     varfull-scale-name-plus AT ROW 8.75 COL 34
     varqnty-plus AT ROW 10 COL 23.5 COLON-ALIGNED
     varunit-name-plus AT ROW 10 COL 36.5 COLON-ALIGNED NO-LABEL
     varqnty-kg-plus AT ROW 10 COL 45 COLON-ALIGNED
     b-prt-in AT ROW 1 COL 31
     RECT-1 AT ROW 6.75 COL 1
     RECT-2 AT ROW 2.5 COL 1
     SPACE(0.00) SKIP(8.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Обработка связок товаров в документе пересортицы"
         CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       varfull-scale-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varfull-scale-name-plus:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varqnty-kg:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varqnty-kg-plus:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  define buffer bf_goods      for ub.goods.
  define buffer bf_goods-plus for ub.goods.
  define buffer bf_gds-prt    for ub.gds-prt.
  define variable varprice-goods      as decimal no-undo.
  define variable varprice-goods-plus as decimal no-undo.
  if parmode <> 'ПРОСМОТР':U then do:
    find first bf_goods where bf_goods.artic     = varartic     and
                              bf_goods.prod-type = varprod-type and
                              bf_goods.prod-code = varprod-code no-lock no-error.
    if not available bf_goods then do:
      message "Не найден товар " varartic " " varprod-type " " varprod-code
      view-as alert-box.
      apply "entry" to varartic in frame Dialog-Frame.
      return no-apply.
    end.
    find first bf_goods-plus where bf_goods-plus.artic     = varartic-plus     and
                                   bf_goods-plus.prod-type = varprod-type-plus and
                                   bf_goods-plus.prod-code = varprod-code-plus no-lock no-error.
    if not available bf_goods-plus then do:
      message "Не найден товар " varartic-plus " " varprod-type-plus " " varprod-code-plus
      view-as alert-box.
      apply "entry" to varartic-plus in frame Dialog-Frame.
      return no-apply.
    end.
    if recid(bf_goods) = recid(bf_goods-plus) then do:
      message "Вы выбрали один и тот же товар для списания и оприходования." view-as alert-box error.
      apply "entry" to varartic-plus in frame Dialog-Frame.
      return no-apply.
    end.
    if bf_goods.unit-base <> bf_goods-plus.unit-base
    and parpstunit
    then do:
      message "У выбранных товаров разные единицы измерения!" skip
              "Пересорт товаров с разными единицами измерения является недопустимым (параметр pstunit)."
      view-as alert-box error.
      return no-apply.
    end.
    if bf_goods.unit-base =  bf_goods-plus.unit-base and
       varqnty            <> varqnty-plus       and
       parpstunqtn-log    <> yes                then do:
      message "У товаров одна и та же единица измерения но разные количества." skip
              "Это недопустимо (параметр pstunqtn)."
       view-as alert-box error.
       apply "entry" to varqnty-plus in frame Dialog-Frame.
       return no-apply.
    end.
    if can-find(first ub.units where ub.units.unit-name = bf_goods-plus.unit-base
                                and lookup('шту':U, ub.units.type) > 0 )  and
       trunc(varqnty-plus, 0) <>   varqnty-plus then do:
      message "У товара " bf_goods-plus.gds-name " штучная единица измерения." skip
              "Количество должно быть целым."
       view-as alert-box error.
       apply "entry" to varqnty-plus in frame Dialog-Frame.
       return no-apply.
    end.
    if can-find(first ub.units where ub.units.unit-name = bf_goods.unit-base
                                and lookup('шту':U, ub.units.type) > 0 )  and
       trunc(varqnty, 0) <>   varqnty then do:
      message "У товара " bf_goods.gds-name " штучная единица измерения." skip
              "Количество должно быть целым."
       view-as alert-box error.
       apply "entry" to varqnty in frame Dialog-Frame.
       return no-apply.
    end.
    if parmxpcicp-dec <> ? or
       parmxpcdcp-dec <> ? or
       parmxsmicp-dec <> ? or
       parmxsmdcp-dec <> ? then do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  ?
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return no-apply.
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  parobj-type
  ,input  parobj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return no-apply.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  parobj-type
  ,input  parobj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return no-apply.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
      if error-status:error then do:
        message "Ошибка при поиске цены для товара: " bf_goods.artic bf_goods.prod-type bf_goods.prod-code bf_goods.gds-name " ." skip
                return-value
        view-as alert-box error.
        apply "entry" to varartic.
        return no-apply.
      end.
      if gp-price-sale = ? then do:
        message "Есть конфигурационные ограничения на цену товара в пересортице." skip
                "Для товара: " bf_goods.artic bf_goods.prod-type bf_goods.prod-code bf_goods.gds-name " цена не установлена."
        view-as alert-box error.
        apply "entry" to varartic.
        return no-apply.
      end.
      assign
        varprice-goods = gp-price-sale.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods-plus.gds-code
  ,input  ?
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return no-apply.
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  parobj-type
  ,input  parobj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return no-apply.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  parobj-type
  ,input  parobj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return no-apply.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
      if error-status:error then do:
        message "Ошибка при поиске цены для товара: " bf_goods-plus.artic bf_goods-plus.prod-type bf_goods-plus.prod-code bf_goods-plus.gds-name " ." skip
                return-value
        view-as alert-box error.
        apply "entry" to varartic-plus.
        return no-apply.
      end.
      if gp-price-sale = ? then do:
        message "Есть конфигурационные ограничения на цену товара в пересортице." skip
                "Для товара: " bf_goods-plus.artic bf_goods-plus.prod-type bf_goods-plus.prod-code bf_goods-plus.gds-name " цена не установлена."
        view-as alert-box error.
        apply "entry" to varartic-plus.
        return no-apply.
      end.
      assign
        varprice-goods-plus = gp-price-sale * varqnty-plus / varqnty.
      if parmxpcicp-dec <> ? then do:
        if (varprice-goods-plus - varprice-goods) / varprice-goods * 100 > parmxpcicp-dec then do:
          message "Максимальное процентное отклонение увеличения цены в документе пересортица: " parmxpcicp-dec skip
                  "Приведенная цена приходуемого товара: " varprice-goods-plus skip
                  "Увеличение цены: " (varprice-goods-plus - varprice-goods) / varprice-goods * 100 "%"
          view-as alert-box error.
          apply "entry" to varqnty-plus in frame Dialog-Frame.
          return no-apply.
        end.
      end.
      if parmxpcdcp-dec <> ? then do:
        if (varprice-goods - varprice-goods-plus) / varprice-goods * 100 > parmxpcdcp-dec then do:
          message "Максимальное процентное отклонение уменьшения цены в документе пересортица: "parmxpcdcp-dec skip
                  "Приведенная цена приходуемого товара: " varprice-goods-plus skip
                  "Уменьшение цены: " (varprice-goods - varprice-goods-plus) / varprice-goods * 100 "%"
          view-as alert-box error.
          apply "entry" to varqnty-plus in frame Dialog-Frame.
          return no-apply.
        end.
      end.
      if parmxsmicp-dec <> ? then do:
        if varprice-goods-plus - varprice-goods > parmxsmicp-dec then do:
          message "Максимальное абсолютное отклонение увеличения цены в документе пересортица: " parmxsmicp-dec skip
                  "Приведенная цена приходуемого товара: " varprice-goods-plus skip
                  "Увеличение цены: " varprice-goods-plus - varprice-goods
          view-as alert-box error.
          apply "entry" to varqnty-plus in frame Dialog-Frame.
          return no-apply.
        end.
      end.
      if parmxsmdcp-dec <> ? then do:
        if varprice-goods - varprice-goods-plus > parmxsmdcp-dec then do:
          message "Максимальное абсолютное отклонение уменьшения цены в документе пересортица: " parmxsmdcp-dec skip
                  "Приведенная цена приходуемого товара: " varprice-goods-plus skip
                  "Уменьшение цены: " varprice-goods - varprice-goods-plus
          view-as alert-box error.
          apply "entry" to varqnty-plus in frame Dialog-Frame.
          return no-apply.
        end.
      end.
    end.
    assign
      paroutgds-code      = bf_goods.gds-code
      paroutgds-code-plus = bf_goods-plus.gds-code
      paroutqnty          = varqnty
      paroutqnty-plus     = varqnty-plus
      paroutqnty-kg       = varqnty-kg
      paroutqnty-kg-plus  = varqnty-kg-plus
      parset              = YES
     .
    find first bf_gds-prt where bf_gds-prt.upper-code = bf_goods.prt-root no-lock.
    if bf_gds-prt.node-name = '_Пустая шкала':U then do:
      for each tt-gds-dtl :
        delete tt-gds-dtl.
      end.
      create tt-gds-dtl.
      assign
        tt-gds-dtl.gds-code = bf_goods.gds-code
        tt-gds-dtl.prt-code = bf_gds-prt.node-code
        tt-gds-dtl.qnty     = (if parmode = 'ДОБАВЛЕНИЕ':U then varqnty else vargds-dtl-qnty + (varqnty - varmem-gds-dtl-qnty)).
    end.
    find first bf_gds-prt where bf_gds-prt.upper-code = bf_goods-plus.prt-root no-lock.
    if bf_gds-prt.node-name = '_Пустая шкала':U then do:
      for each tt-gds-dtl-plus :
        delete tt-gds-dtl-plus.
      end.
      create tt-gds-dtl-plus.
      assign
        tt-gds-dtl-plus.gds-code = bf_goods-plus.gds-code
        tt-gds-dtl-plus.prt-code = bf_gds-prt.node-code
        tt-gds-dtl-plus.qnty     = (if parmode = 'ДОБАВЛЕНИЕ':U then varqnty-plus else vargds-dtl-qnty-plus + (varqnty-plus - varmem-gds-dtl-qnty-plus)).
    end.
  end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-prt-in IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER bf_goods FOR ub.goods.
  define buffer bf-another_goods for ub.goods.
  DEFINE VARIABLE varis-petrol AS LOGICAL NO-UNDO.
  DEFINE VARIABLE varis-pieces AS LOGICAL NO-UNDO.
  DEFINE VARIABLE varstate     AS LOGICAL NO-UNDO.
  FIND FIRST bf_goods WHERE bf_goods.artic     = INPUT FRAME Dialog-Frame varartic-plus     AND
                            bf_goods.prod-type = INPUT FRAME Dialog-Frame varprod-type-plus AND
                            bf_goods.prod-code = INPUT FRAME Dialog-Frame varprod-code-plus NO-LOCK NO-ERROR.
  IF NOT AVAILABLE bf_goods THEN DO:
    MESSAGE "Не найден товар: " INPUT FRAME Dialog-Frame varartic-plus " " INPUT FRAME Dialog-Frame varprod-type-plus " " INPUT FRAME Dialog-Frame varprod-code-plus
    VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  if parmode <> 'ДОБАВЛЕНИЕ':U then do:
    FIND FIRST bf-another_goods WHERE bf-another_goods.artic     = INPUT FRAME Dialog-Frame varartic     AND
                                      bf-another_goods.prod-type = INPUT FRAME Dialog-Frame varprod-type AND
                                      bf-another_goods.prod-code = INPUT FRAME Dialog-Frame varprod-code no-lock.
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf_goods.artic
  ,  input bf_goods.prod-type
  ,  input bf_goods.prod-code
  , output varis-petrol
  , output varis-pieces
  ) .
  IF varis-petrol     AND
     NOT varis-pieces THEN DO:
    run str/prstptrl.w (BUFFER bf_goods,
                    (if parmode = 'ДОБАВЛЕНИЕ':U then ? else bf-another_goods.gds-code),
                    INPUT  pardoc-code,
                    INPUT  parobj-type,
                    INPUT  parobj-code,
                    INPUT  NO,
                    INPUT  parmode,
                    OUTPUT varstate)   no-error.
  END.
  ELSE DO:
    for each tt-gds-prt :
      delete tt-gds-prt.
    end.
    run str/prt-prst.w (buffer bf_goods,
                    input  pardoc-code,
                    input  parobj-type,
                    input  parobj-code,
                    input  no,
                    INPUT  parmode,
                    output varstate) no-error.
    if not(error-status:error or varstate <> yes) then do:
      for each tt-gds-dtl-plus :
        delete tt-gds-dtl-plus.
      end.
      assign
        varqnty-plus = 0.00.
      for each tt-gds-prt where tt-gds-prt.income-qnty > 0 :
        create tt-gds-dtl-plus.
        assign
          tt-gds-dtl-plus.gds-code = bf_goods.gds-code
          tt-gds-dtl-plus.prt-code = tt-gds-prt.prt-code
          tt-gds-dtl-plus.qnty     = tt-gds-prt.income-qnty.
        assign
          varqnty-plus = varqnty-plus + tt-gds-dtl-plus.qnty.
        display varqnty-plus with frame Dialog-Frame.
      end.
    end.
  END.
END.
ON CHOOSE OF b-prt-wr IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER bf_goods FOR ub.goods.
  define buffer bf-another_goods for ub.goods.
  DEFINE VARIABLE varis-petrol AS LOGICAL NO-UNDO.
  DEFINE VARIABLE varis-pieces AS LOGICAL NO-UNDO.
  DEFINE VARIABLE varstate     AS LOGICAL NO-UNDO.
  FIND FIRST bf_goods WHERE bf_goods.artic     = INPUT FRAME Dialog-Frame varartic     AND
                            bf_goods.prod-type = INPUT FRAME Dialog-Frame varprod-type AND
                            bf_goods.prod-code = INPUT FRAME Dialog-Frame varprod-code NO-LOCK NO-ERROR.
  IF NOT AVAILABLE bf_goods THEN DO:
    MESSAGE "Не найден товар: " INPUT FRAME Dialog-Frame varartic " " INPUT FRAME Dialog-Frame varprod-type " " INPUT FRAME Dialog-Frame varprod-code
    VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  if parmode <> 'ДОБАВЛЕНИЕ':U then do:
    FIND FIRST bf-another_goods WHERE bf-another_goods.artic     = INPUT FRAME Dialog-Frame varartic-plus     AND
                                      bf-another_goods.prod-type = INPUT FRAME Dialog-Frame varprod-type-plus AND
                                      bf-another_goods.prod-code = INPUT FRAME Dialog-Frame varprod-code-plus no-lock.
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf_goods.artic
  ,  input bf_goods.prod-type
  ,  input bf_goods.prod-code
  , output varis-petrol
  , output varis-pieces
  ) .
  IF varis-petrol     AND
     NOT varis-pieces THEN DO:
    run str/prstptrl.w (BUFFER bf_goods,
                    input  (if parmode = 'ДОБАВЛЕНИЕ':U then ? else bf-another_goods.gds-code),
                    INPUT  pardoc-code,
                    INPUT  parobj-type,
                    INPUT  parobj-code,
                    INPUT  yes,
                    INPUT  parmode,
                    OUTPUT varstate)   no-error.
  END.
  ELSE DO:
    for each tt-gds-prt :
      delete tt-gds-prt.
    end.
    run str/prt-prst.w (buffer bf_goods,
                    input  pardoc-code,
                    input  parobj-type,
                    input  parobj-code,
                    input  yes,
                    INPUT  parmode,
                    output varstate) no-error.
    if error-status:error or varstate <> yes then do:
    end.
    else do:
      for each tt-gds-dtl :
        delete tt-gds-dtl.
      end.
      assign
        varqnty = 0.00.
      for each tt-gds-prt where tt-gds-prt.write-off-qnty > 0 :
        create tt-gds-dtl.
        assign
          tt-gds-dtl.gds-code = bf_goods.gds-code
          tt-gds-dtl.prt-code = tt-gds-prt.prt-code
          tt-gds-dtl.qnty     = tt-gds-prt.write-off-qnty.
        assign
          varqnty = varqnty + tt-gds-dtl.qnty.
        display varqnty with frame Dialog-Frame.
      end.
    end.
  END.
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
END.
ON CHOOSE OF r-goods IN FRAME Dialog-Frame
DO:
  RUN run-ref IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF r-goods-plus IN FRAME Dialog-Frame
DO:
  RUN run-ref-plus IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF r-list IN FRAME Dialog-Frame
DO:
  RUN ref-list IN THIS-PROCEDURE no-error.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF r-list-plus IN FRAME Dialog-Frame
DO:
  RUN ref-list-plus IN THIS-PROCEDURE no-error.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN NO-APPLY.
  END.
END.
ON MOUSE-SELECT-DBLCLICK OF varartic IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
     not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) and
     not (last-event:event-type = "progress":u and last-event:widget-enter = r-goods:handle)  and
     not (last-event:event-type = "progress":u and last-event:widget-enter = r-list:handle)
     then do:
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref in this-procedure.
  end.
end.
END.
ON return OF varartic IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
     not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) and
     not (last-event:event-type = "progress":u and last-event:widget-enter = r-goods:handle)  and
     not (last-event:event-type = "progress":u and last-event:widget-enter = r-list:handle)   then do:
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref in this-procedure.
  end.
end.
END.
ON MOUSE-SELECT-DBLCLICK OF varartic-plus IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle)     and
  not (last-event:event-type = "progress":u and last-event:widget-enter = r-goods-plus:handle) and
  not (last-event:event-type = "progress":u and last-event:widget-enter = r-list-plus:handle)
then do:
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref-plus in this-procedure.
  end.
end.
END.
ON return OF varartic-plus IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle)     and
   not (last-event:event-type = "progress":u and last-event:widget-enter = r-goods-plus:handle) and
   not (last-event:event-type = "progress":u and last-event:widget-enter = r-list-plus:handle)
then do:
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref-plus in this-procedure.
  end.
end.
END.
ON MOUSE-SELECT-DBLCLICK OF varprod-code IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) and
  not (last-event:event-type = "progress":u and last-event:widget-enter = r-goods:handle)  and
  not (last-event:event-type = "progress":u and last-event:widget-enter = r-list:handle)
then do:
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref in this-procedure.
  end.
end.
END.
ON return OF varprod-code IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) and
  not (last-event:event-type = "progress":u and last-event:widget-enter = r-goods:handle)  and
  not (last-event:event-type = "progress":u and last-event:widget-enter = r-list:handle)
then do:
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref in this-procedure.
  end.
end.
END.
ON MOUSE-SELECT-DBLCLICK OF varprod-code-plus IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref-plus in this-procedure.
  end.
end.
END.
ON return OF varprod-code-plus IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref-plus in this-procedure.
  end.
end.
END.
ON LEAVE OF varprod-type IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref in this-procedure.
  end.
  RETURN NO-APPLY.
end.
END.
ON MOUSE-SELECT-DBLCLICK OF varprod-type IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
     not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref in this-procedure.
  end.
end.
END.
ON return OF varprod-type IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref in this-procedure.
  end.
end.
END.
ON LEAVE OF varprod-type-plus IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref-plus in this-procedure.
  end.
  RETURN NO-APPLY.
end.
END.
ON MOUSE-SELECT-DBLCLICK OF varprod-type-plus IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref-plus in this-procedure.
  end.
end.
END.
ON return OF varprod-type-plus IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
     not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    run run-ref-plus in this-procedure.
  end.
end.
END.
ON LEAVE OF varqnty IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  run set-qnty in this-procedure no-error.
end.
END.
ON return OF varqnty IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  run set-qnty in this-procedure no-error.
  apply "entry" to varartic-plus in frame Dialog-Frame.
  return no-apply.
end.
END.
ON LEAVE OF varqnty-plus IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  run set-qnty-plus in this-procedure no-error.
end.
END.
ON return OF varqnty-plus IN FRAME Dialog-Frame
DO:
if keyfunction(lastkey) <> "end-error" and
  not (last-event:event-type = "progress":u and last-event:widget-enter = b-cancel:handle) then do:
  run set-qnty-plus in this-procedure no-error.
  apply "entry" to b-save in frame Dialog-Frame.
  return no-apply.
end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 frame Dialog-Frame :title = frame Dialog-Frame :title + " " + pardoc-code.
  RUN enable_UI in this-procedure.
  run mode-on   in this-procedure.
  run ui-on     in this-procedure.
  find first bf_clients-host where bf_clients-host.obj-type = parobj-type and
                                   bf_clients-host.obj-code = parobj-code no-lock.
  wait-for go of frame Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY varqnty-kg varartic vargds-name varprod-code varprod-type varqnty
          varunit-name varartic-plus vargds-name-plus varprod-code-plus
          varprod-type-plus varqnty-plus varunit-name-plus varqnty-kg-plus
      WITH FRAME Dialog-Frame.
  ENABLE b-cancel b-help RECT-1 RECT-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE mode-on :
DEFINE BUFFER bf_goods        FOR ub.goods.
DEFINE BUFFER bf_goods-plus   FOR ub.goods.
DEFINE BUFFER bf_gds-prt      FOR ub.gds-prt.
DEFINE BUFFER bf_gds-prt-plus FOR ub.gds-prt.
define buffer bf-w_gds-dtl for ub.gds-dtl.
define buffer bf-i_gds-dtl for ub.gds-dtl.
DEFINE VARIABLE varis-petrol      AS LOGICAL NO-UNDO.
DEFINE VARIABLE varis-pieces      AS LOGICAL NO-UNDO.
DEFINE VARIABLE varis-petrol-plus AS LOGICAL NO-UNDO.
DEFINE VARIABLE varis-pieces-plus AS LOGICAL NO-UNDO.
do on error undo, return error RETURN-VALUE :
if parmode = 'ИЗМЕНЕНИЕ':U or
   parmode = 'ПРОСМОТР':U then do:
  FIND FIRST bf_goods WHERE bf_goods.gds-code = pargds-code NO-LOCK NO-ERROR.
  IF NOT AVAILABLE bf_goods THEN DO:
    MESSAGE "Не найден товар с внутренним кодом: " pargds-code " ." VIEW-AS ALERT-BOX ERROR.
    RETURN ERROR.
  END.
  FIND FIRST bf_gds-prt WHERE bf_gds-prt.upper-code = bf_goods.prt-root no-lock.
  FIND FIRST bf_goods-plus WHERE bf_goods-plus.gds-code = pargds-code-plus NO-LOCK NO-ERROR.
  IF NOT AVAILABLE bf_goods-plus THEN DO:
    MESSAGE "Не найден товар с внутренним кодом: " pargds-code-plus " ." VIEW-AS ALERT-BOX ERROR.
    RETURN ERROR.
  END.
  FIND FIRST bf_gds-prt-plus WHERE bf_gds-prt-plus.upper-code = bf_goods-plus.prt-root no-lock.
  ASSIGN
    varartic                = bf_goods.artic
    varprod-type            = bf_goods.prod-type
    varprod-code            = bf_goods.prod-code
    vargds-name             = bf_goods.gds-name
    varfull-scale-name      = (IF bf_gds-prt.node-name = '_Пустая шкала':U THEN "":u ELSE bf_gds-prt.f-name)
    varartic-plus           = bf_goods-plus.artic
    varprod-type-plus       = bf_goods-plus.prod-type
    varprod-code-plus       = bf_goods-plus.prod-code
    vargds-name-plus        = bf_goods-plus.gds-name
    varfull-scale-name-plus = (IF bf_gds-prt-plus.node-name = '_Пустая шкала':U THEN "":u ELSE bf_gds-prt-plus.f-name)
  .
  DISPLAY varartic      varprod-type      varprod-code      vargds-name
          varartic-plus varprod-type-plus varprod-code-plus vargds-name-plus WITH FRAME Dialog-Frame.
  assign
    varqnty                  = parqnty
    varmem-gds-dtl-qnty      = parqnty
    varqnty-kg               = parqnty-kg
    varqnty-plus             = parqnty-plus
    varmem-gds-dtl-qnty-plus = parqnty-plus
    varqnty-kg-plus          = parqnty-kg-plus.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input varartic
  ,  input varprod-type
  ,  input varprod-code
  , output varis-petrol
  , output varis-pieces
  ) .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input varartic-plus
  ,  input varprod-type-plus
  ,  input varprod-code-plus
  , output varis-petrol-plus
  , output varis-pieces-plus
  ) .
  if parmode = 'ИЗМЕНЕНИЕ':U or
     parmode = 'ПРОСМОТР':U then do:
    display varqnty varqnty-plus with frame Dialog-Frame.
    if varis-petrol     and
       not varis-pieces then do:
      display varqnty-kg with frame Dialog-Frame.
    end.
    if varis-petrol-plus     and
       not varis-pieces-plus then do:
      display varqnty-kg-plus with frame Dialog-Frame.
    end.
  end.
  if parmode = 'ИЗМЕНЕНИЕ':U then do:
    for each bf-w_gds-dtl where bf-w_gds-dtl.doc-code  = pardoc-code            and
                                bf-w_gds-dtl.artic     = bf_goods.artic     and
                                bf-w_gds-dtl.prod-type = bf_goods.prod-type and
                                bf-w_gds-dtl.prod-code = bf_goods.prod-code on error undo, return error return-value :
      create tt-gds-dtl.
      assign
        tt-gds-dtl.gds-code =   bf_goods.gds-code
        tt-gds-dtl.prt-code =   bf-w_gds-dtl.prt-code
        tt-gds-dtl.qnty     = - bf-w_gds-dtl.doc-qnty.
      IF bf_gds-prt.node-name = '_Пустая шкала':U THEN DO:
        assign
          vargds-dtl-qnty = - bf-w_gds-dtl.doc-qnty.
      end.
    end.
    for each bf-i_gds-dtl where bf-i_gds-dtl.doc-code  = pardoc-code             and
                                bf-i_gds-dtl.artic     = bf_goods-plus.artic     and
                                bf-i_gds-dtl.prod-type = bf_goods-plus.prod-type and
                                bf-i_gds-dtl.prod-code = bf_goods-plus.prod-code on error undo, return error return-value :
      create tt-gds-dtl-plus.
      assign
        tt-gds-dtl-plus.gds-code = bf_goods-plus.gds-code
        tt-gds-dtl-plus.prt-code = bf-i_gds-dtl.prt-code
        tt-gds-dtl-plus.qnty     = bf-i_gds-dtl.doc-qnty.
      IF bf_gds-prt-plus.node-name = '_Пустая шкала':U THEN DO:
        assign
          vargds-dtl-qnty-plus = bf-i_gds-dtl.doc-qnty.
      end.
    end.
  end.
  IF bf_gds-prt.node-name <> '_Пустая шкала':U THEN DO:
   DISPLAY varfull-scale-name WITH FRAME Dialog-Frame.
   ASSIGN b-prt-wr:LABEL = "Шкала сп.".
   if parmode = 'ИЗМЕНЕНИЕ':U or parmode = 'ПРОСМОТР':U then do:
     ENABLE b-prt-wr WITH FRAME Dialog-Frame.
   end.
  END.
  ELSE DO:
    IF varis-petrol AND
       NOT varis-pieces THEN DO:
      ASSIGN b-prt-wr:LABEL = "Рез-р сп.".
      if parmode = 'ИЗМЕНЕНИЕ':U or parmode = 'ПРОСМОТР':U then do:
        ENABLE b-prt-wr WITH FRAME Dialog-Frame.
      end.
    END.
    ELSE DO:
      HIDE b-prt-wr IN FRAME Dialog-Frame.
      if parmode = 'ИЗМЕНЕНИЕ':U then do:
        enable varqnty with frame Dialog-Frame.
      end.
    END.
  END.
  IF bf_gds-prt-plus.node-name <> '_Пустая шкала':U THEN DO:
    DISPLAY varfull-scale-name-plus WITH FRAME Dialog-Frame.
    ASSIGN b-prt-in:LABEL = "Шкала оп.".
    if parmode = 'ИЗМЕНЕНИЕ':U or parmode = 'ПРОСМОТР':U then do:
      ENABLE b-prt-in WITH FRAME Dialog-Frame.
    end.
  END.
  ELSE DO:
    IF varis-petrol-plus     AND
       NOT varis-pieces-plus THEN DO:
      ASSIGN b-prt-in:LABEL = "Рез-р оп.".
      if parmode = 'ИЗМЕНЕНИЕ':U or parmode = 'ПРОСМОТР':U then do:
        ENABLE b-prt-in WITH FRAME Dialog-Frame.
      end.
    END.
    ELSE DO:
      HIDE b-prt-in IN FRAME Dialog-Frame.
      if parmode = 'ИЗМЕНЕНИЕ':U then do:
        enable varqnty-plus with frame Dialog-Frame.
      end.
    END.
  END.
  if not(is-petrol and not is-pieces) then do:
      HIDE varqnty-kg IN FRAME Dialog-Frame.
  END.
  ELSE DO:
      VIEW varqnty-kg IN FRAME Dialog-Frame.
  END.
  if not(is-petrol-plus and not is-pieces-plus) then do:
    HIDE varqnty-kg-plus IN FRAME Dialog-Frame.
  END.
  ELSE DO:
    VIEW varqnty-kg-plus IN FRAME Dialog-Frame.
  END.
end.
IF parmode = 'ДОБАВЛЕНИЕ':U THEN DO:
  HIDE b-prt-wr b-prt-in varqnty-kg varqnty-kg-plus IN FRAME Dialog-Frame.
END.
end.
END PROCEDURE.
PROCEDURE ref-list :
DEFINE BUFFER bf_goods FOR ub.goods.
DEFINE BUFFER bf_units FOR ub.units.
run str/gds-list.w (input parparentproc, input bf_clients-host.host-code, input parobj-type, input parobj-code).
FIND FIRST gds-list NO-ERROR.
IF AVAILABLE gds-list THEN DO:
  FIND FIRST bf_goods WHERE bf_goods.artic     = gds-list.artic     AND
                            bf_goods.prod-type = gds-list.prod-type AND
                            bf_goods.prod-code = gds-list.prod-code NO-LOCK.
  ASSIGN
    varartic     = bf_goods.artic
    varprod-type = bf_goods.prod-type
    varprod-code = bf_goods.prod-code
    varunit-name = bf_goods.unit-base.
  DISPLAY varartic varprod-type varprod-code varunit-name WITH FRAME Dialog-Frame.
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN ERROR.
  END.
END.
END PROCEDURE.
PROCEDURE ref-list-plus :
DEFINE BUFFER bf_goods FOR ub.goods.
run str/gds-list.w (input parparentproc, input bf_clients-host.host-code, input parobj-type, input parobj-code).
FIND FIRST gds-list NO-ERROR.
IF AVAILABLE gds-list THEN DO:
  FIND FIRST bf_goods WHERE bf_goods.artic     = gds-list.artic     AND
                            bf_goods.prod-type = gds-list.prod-type AND
                            bf_goods.prod-code =
 gds-list.prod-code NO-LOCK.
  ASSIGN
    varartic-plus     = bf_goods.artic
    varprod-type-plus = bf_goods.prod-type
    varprod-code-plus = bf_goods.prod-code
    varunit-name      = bf_goods.unit-base.
  DISPLAY varartic-plus varprod-type-plus varprod-code-plus varunit-name WITH FRAME Dialog-Frame.
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN ERROR.
  END.
END.
END PROCEDURE.
PROCEDURE run-ref :
define variable v-stat as character no-undo init ?.
define variable v-list as character no-undo init ?.
define variable v-prod-type like ub.clients.obj-type no-undo .
define variable v-prod-code like ub.clients.obj-code no-undo .
define variable ref-list     as character no-undo init "" .
define variable new-ref-list as character no-undo init "" .
DEFINE VARIABLE v-erase AS LOGICAL NO-UNDO.
DEFINE BUFFER bf_clients FOR ub.clients.
DEFINE BUFFER bf_goods   FOR ub.goods.
find FIRST bf_clients where bf_clients.obj-type = input frame Dialog-Frame varprod-type
                        and bf_clients.obj-code = input frame Dialog-Frame varprod-code NO-LOCK NO-ERROR.
IF AVAILABLE bf_clients then do:
  ASSIGN
    v-list = "производитель".
end.
ELSE DO:
  ASSIGN
    v-list = 'все':U.
END.
ASSIGN
  v-stat = 'текущие':U.
run ref/gds-ref.p
  ( parparentproc
  , "b-sel,b-add"
  , v-stat
  , v-list
  , ?
  , ?
  , ?
  , (if available bf_clients then bf_clients.obj-type else ?)
  , (if available bf_clients then bf_clients.obj-code else ?)
  , parobj-type
  , parobj-code
  , ?
  , output ref-list)
  NO-ERROR.
IF ref-list <> "":u THEN DO:
  find first bf_goods where recid (bf_goods) = integer (entry(1, ref-list)) no-lock  .
  run ver-gds in this-procedure (bf_goods.gds-code, output v-erase) no-error  .
  if error-status:error
  then do:
     message return-value VIEW-AS ALERT-BOX.
     return  error.
  end.
  if v-erase = TRUE then do:
    MESSAGE "Вы выбрали нетоварную позицию." VIEW-AS ALERT-BOX.
    RETURN ERROR.
  end.
  IF bf_goods.gds-type = 'у':U THEN DO:
    MESSAGE "Вы выбрали услугу." VIEW-AS ALERT-BOX.
    RETURN ERROR.
  END.
  ASSIGN
    varartic     = bf_goods.artic
    varprod-type = bf_goods.prod-type
    varprod-code = bf_goods.prod-code
    VARunit-name = bf_goods.unit-base.
  DISPLAY varartic varprod-type varprod-code varunit-name WITH FRAME Dialog-Frame.
  RUN set-goods IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN ERROR.
  END.
END.
END PROCEDURE.
PROCEDURE run-ref-plus :
define variable v-stat as character no-undo init ?.
define variable v-list as character no-undo init ?.
define variable v-prod-type like ub.clients.obj-type no-undo .
define variable v-prod-code like ub.clients.obj-code no-undo .
define variable ref-list     as character no-undo init "" .
define variable new-ref-list as character no-undo init "" .
DEFINE VARIABLE v-erase AS LOGICAL NO-UNDO.
DEFINE BUFFER bf_clients FOR ub.clients.
DEFINE BUFFER bf_goods   FOR ub.goods.
find FIRST bf_clients where bf_clients.obj-type = input frame Dialog-Frame varprod-type-plus
                        and bf_clients.obj-code = input frame Dialog-Frame varprod-code-plus NO-LOCK NO-ERROR.
IF AVAILABLE bf_clients then do:
  ASSIGN
    v-list = "производитель".
end.
ELSE DO:
  ASSIGN
    v-list = 'все':U.
END.
ASSIGN
  v-stat = 'текущие':U.
run ref/gds-ref.p
  ( parparentproc
  , "b-sel,b-add"
  , v-stat
  , v-list
  , ?
  , ?
  , ?
  , (if available bf_clients then bf_clients.obj-type else ?)
  , (if available bf_clients then bf_clients.obj-code else ?)
  , parobj-type
  , parobj-code
  , ?
  , output ref-list)
  NO-ERROR.
IF ref-list <> "":u THEN DO:
  find first bf_goods where recid (bf_goods) = integer (entry(1, ref-list)) no-lock  .
  run ver-gds (bf_goods.gds-code, output v-erase) no-error  .
  if error-status:error
  then do:
     message return-value VIEW-AS ALERT-BOX.
     return  error.
  end.
  if v-erase = TRUE  then do:
    MESSAGE "Вы выбрали нетоварную позицию." VIEW-AS ALERT-BOX.
    RETURN ERROR.
  end.
  IF bf_goods.gds-type = 'у':U THEN DO:
    MESSAGE "Вы выбрали услугу." VIEW-AS ALERT-BOX.
    RETURN ERROR.
  END.
  ASSIGN
    varartic-plus     = bf_goods.artic
    varprod-type-plus = bf_goods.prod-type
    varprod-code-plus = bf_goods.prod-code
    varunit-name-plus = bf_goods.unit-base.
  DISPLAY varartic-plus varprod-type-plus varprod-code-plus varunit-name-plus WITH FRAME Dialog-Frame.
  RUN set-goods-plus IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN ERROR.
  END.
END.
END PROCEDURE.
PROCEDURE set-goods :
define buffer bf-chk_goods     for ub.goods.
define buffer bf-chk-two_goods for ub.goods.
define buffer bf_gds-prt       for ub.gds-prt.
define buffer bf_clients       for ub.clients.
define variable varnabor as logical no-undo.
define variable varstate as logical no-undo.
if input frame Dialog-Frame varartic = '' then return error.
find first bf-chk_goods where bf-chk_goods.artic  = input frame Dialog-Frame varartic no-lock no-error.
if not available bf-chk_goods then do:
  message "Неправильный Артикул - такого товара нет.".
  apply "entry" to varartic in frame Dialog-Frame.
  return.
end.
else do:
  find first bf-chk-two_goods where bf-chk-two_goods.artic    = input frame Dialog-Frame varartic
                                and recid (bf-chk-two_goods) <> recid (bf-chk_goods)
                                and bf-chk-two_goods.stts     = 0 no-lock no-error.
  if input frame Dialog-Frame varprod-code <> 0 then do:
    find first bf-chk_goods where bf-chk_goods.prod-code  = input frame Dialog-Frame varprod-code
                              and bf-chk_goods.artic      = input frame Dialog-Frame varartic no-lock no-error.
    if not available bf-chk_goods then do:
      message "Неправильный Код производителя - такого товара нет.".
      apply "entry" to varprod-code in frame Dialog-Frame.
      return.
    end.
    find first bf-chk-two_goods where bf-chk-two_goods.artic     = input frame Dialog-Frame varartic
                                  and bf-chk-two_goods.prod-code = input frame Dialog-Frame varprod-code
                                  and recid (bf-chk-two_goods)  <> recid (bf-chk_goods)
                                  and bf-chk-two_goods.stts      = 0 no-lock no-error.
  end.
  else do:
    if available bf-chk-two_goods then do:
      message "С артикулом :" input frame Dialog-Frame varartic
              "несколько товаров." skip (2)
               "Укажите Производителя или выберите товар из справочника.".
      apply "entry" to varprod-code in frame Dialog-Frame.
      return.
    end.
  end.
  if input frame Dialog-Frame varprod-code <> 0  and
     input frame Dialog-Frame varprod-type <> "" then do:
     find bf-chk_goods where bf-chk_goods.prod-type = input frame Dialog-Frame varprod-type and
                             bf-chk_goods.prod-code = input frame Dialog-Frame varprod-code and
                             bf-chk_goods.artic     = input frame Dialog-Frame varartic no-lock no-error.
     if not available bf-chk_goods then do:
      message "Неправильный Тип производителя - такого товара нет.".
      apply "entry" to varprod-type in frame Dialog-Frame.
      return.
     end.
  end.
  else do:
    if available bf-chk-two_goods then do:
        message "С артикулом :" input frame Dialog-Frame varartic
                        "несколько товаров." skip (2)
                        "Укажите Производителя или выберите товар из справочника.".
        apply "entry" to varprod-type in frame Dialog-Frame.
        return.
    end.
  end.
  run ver-gds in this-procedure (bf-chk_goods.gds-code, output varnabor) no-error .
  if error-status:error
  then do:
     message return-value VIEW-AS ALERT-BOX.
     return  error.
  end.
  if varnabor = true then do:
    message "Это не товарная позиция - имеет атрибут НАБОР !!!".
    apply "entry" to varartic in frame Dialog-Frame.
    return.
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf-chk_goods.artic
  ,  input bf-chk_goods.prod-type
  ,  input bf-chk_goods.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
  find first bf_units where bf_units.unit-name = bf-chk_goods.unit-base no-lock.
  if lookup('2ед':U, bf_units.type) <> 0 then do:
    message substitute ("В документе пересортица недопускается товар с двумя единицами измерения. Товар: &1 &2 &3", bf-chk_goods.artic, bf-chk_goods.prod-type, bf-chk_goods.prod-code) view-as alert-box error.
    apply "entry" to varartic in frame Dialog-Frame.
    assign
      varartic     = ""
      varprod-type = ""
      varprod-code = 0.
    display varartic varprod-type varprod-code with frame Dialog-Frame.
    return error.
  end.
  if lookup( bf-chk_goods.gds-type, 'у':U ) > 0 then do:
    message "В документе пересортица недопустимы услуги." view-as alert-box error.
    apply "entry" to varartic in frame Dialog-Frame.
    assign
      varartic     = ""
      varprod-type = ""
      varprod-code = 0.
    display varartic varprod-type varprod-code with frame Dialog-Frame.
    return error.
  end.
  find first bf_gds-prt where bf_gds-prt.upper-code = bf-chk_goods.prt-root no-lock no-error.
  find first bf_clients where bf_clients.obj-type = bf-chk_goods.prod-type and
                              bf_clients.obj-code = bf-chk_goods.prod-code no-lock.
  assign
    varartic           = bf-chk_goods.artic
    varprod-type       = bf-chk_goods.prod-type
    varprod-code       = bf-chk_goods.prod-code
    vargds-name        = bf-chk_goods.gds-name
    varunit-name       = bf-chk_goods.unit-base
    varfull-scale-name = (if bf_gds-prt.node-name = '_Пустая шкала':U then "":u else bf_gds-prt.f-name)
  .
  display varartic varprod-type varprod-code vargds-name varunit-name with frame Dialog-Frame.
  if varfull-scale-name <> "":u then do:
    display varfull-scale-name with frame Dialog-Frame.
  end.
  else do:
    hide varfull-scale-name in frame Dialog-Frame.
  end.
  if not(is-petrol and not is-pieces) then do:
    HIDE varqnty-kg IN FRAME Dialog-Frame.
  END.
  ELSE DO:
    VIEW varqnty-kg IN FRAME Dialog-Frame.
  END.
  if bf_gds-prt.node-name = '_Пустая шкала':U then do:
    if is-petrol and not is-pieces then do:
      for each tt-pl-qty :
        delete tt-pl-qty.
      end.
      assign
        varqnty    = 0.00
        varqnty-kg = 0.00.
      run str/prstptrl.w (BUFFER bf-chk_goods,
                      input  ?,
                      INPUT  pardoc-code,
                      INPUT  parobj-type,
                      INPUT  parobj-code,
                      INPUT  yes,
                      INPUT  'ДОБАВЛЕНИЕ':U,
                      OUTPUT varstate)   no-error.
      if error-status:error or varstate <> yes then do:
        assign
          varartic             = "":u
          varprod-type         = "":u
          varprod-code         = ?
          vargds-name          = "":u
          varunit-name         = "":u
          varfull-scale-name   = "":u
        .
        display varartic varprod-type varprod-code vargds-name varunit-name with frame Dialog-Frame.
        if varfull-scale-name:visible in frame Dialog-Frame then do:
          display varfull-scale-name with frame Dialog-Frame.
        end.
        apply "entry" to varartic in frame Dialog-Frame.
        return error.
      end.
      else do:
        for each tt-place :
          if tt-place.write-off-doc-l <> 0 then do:
            create tt-pl-qty.
            assign
              tt-pl-qty.pl-code = tt-place.pl-code
              tt-pl-qty.qnty-l  = tt-place.write-off-l
              tt-pl-qty.qnty-kg = tt-place.write-off-kg
            .
            assign
              varqnty    = varqnty    + tt-pl-qty.qnty-l
              varqnty-kg = varqnty-kg + tt-pl-qty.qnty-kg.
          end.
        end.
        display varqnty varqnty-kg with frame Dialog-Frame.
      end.
    end.
    else do:
      HIDE b-prt-wr IN FRAME Dialog-Frame.
      enable varqnty with frame Dialog-Frame.
      assign
        parmode = "first-goods":u.
      run ui-on in this-procedure.
    end.
  end.
  else do:
    hide varqnty in frame Dialog-Frame.
    for each tt-gds-prt on error undo, return error return-value :
      delete tt-gds-prt.
    end.
    run str/prt-prst.w (buffer bf-chk_goods,
                    input  pardoc-code,
                    input  parobj-type,
                    input  parobj-code,
                    input  yes,
                    INPUT  parmode,
                    output varstate) no-error.
    if error-status:error or varstate <> yes then do:
      assign
        varartic             = "":u
        varprod-type         = "":u
        varprod-code         = ?
        vargds-name          = "":u
        varunit-name         = "":u
        varfull-scale-name   = "":u
      .
      display varartic varprod-type varprod-code vargds-name varunit-name with frame Dialog-Frame.
      if varfull-scale-name:visible in frame Dialog-Frame then do:
        display varfull-scale-name with frame Dialog-Frame.
      end.
      apply "entry" to varartic in frame Dialog-Frame.
      return error.
    end.
    else do:
      for each tt-gds-dtl on error undo, return error return-value :
        delete tt-gds-dtl.
      end.
      assign
        varqnty = 0.00.
      for each tt-gds-prt where tt-gds-prt.write-off-qnty > 0 on error undo, return error return-value :
        create tt-gds-dtl.
        assign
          tt-gds-dtl.gds-code = bf-chk_goods.gds-code
          tt-gds-dtl.prt-code = tt-gds-prt.prt-code
          tt-gds-dtl.qnty     = tt-gds-prt.write-off-qnty.
        assign
          varqnty = varqnty + tt-gds-dtl.qnty.
        display varqnty with frame Dialog-Frame.
      end.
      apply "entry" to varartic-plus in frame Dialog-Frame.
    end.
  end.
end.
END PROCEDURE.
PROCEDURE set-goods-plus :
define buffer bf-chk_goods     for ub.goods.
define buffer bf-chk-two_goods for ub.goods.
define buffer bf_gds-prt       for ub.gds-prt.
define buffer bf_clients       for ub.clients.
define variable varnabor  as logical no-undo.
define variable varstate  as logical no-undo.
if input frame Dialog-Frame varartic-plus = '' then do:
  return error.
end.
find first bf-chk_goods where bf-chk_goods.artic  = input frame Dialog-Frame varartic-plus no-lock no-error.
if not available bf-chk_goods then do:
  message "Неправильный Артикул - такого товара нет.".
  apply "entry" to varartic-plus in frame Dialog-Frame.
  return error.
end.
else do:
  find first bf-chk-two_goods where bf-chk-two_goods.artic    = input frame Dialog-Frame varartic-plus
                                and recid (bf-chk-two_goods) <> recid (bf-chk_goods)
                                and bf-chk-two_goods.stts     = 0 no-lock no-error.
  if input frame Dialog-Frame varprod-code-plus <> 0 then do:
    find first bf-chk_goods where bf-chk_goods.prod-code  = input frame Dialog-Frame varprod-code-plus
                              and bf-chk_goods.artic      = input frame Dialog-Frame varartic-plus     no-lock no-error.
    if not available bf-chk_goods then do:
      message "Неправильный Код производителя - такого товара нет.".
      apply "entry" to varprod-code-plus in frame Dialog-Frame.
      return.
    end.
    find first bf-chk-two_goods where bf-chk-two_goods.artic     = input frame Dialog-Frame varartic-plus
                                  and bf-chk-two_goods.prod-code = input frame Dialog-Frame varprod-code-plus
                                  and recid (bf-chk-two_goods)  <> recid (bf-chk_goods)
                                  and bf-chk-two_goods.stts      = 0 no-lock no-error.
  end.
  else do:
    if available bf-chk-two_goods then do:
      message "С артикулом :" input frame Dialog-Frame varartic-plus
              "несколько товаров." skip (2)
               "Укажите Производителя или выберите товар из справочника.".
      apply "entry" to varprod-code in frame Dialog-Frame.
      return.
    end.
  end.
  if input frame Dialog-Frame varprod-code-plus <> 0  and
     input frame Dialog-Frame varprod-type-plus <> "" then do:
     find bf-chk_goods where bf-chk_goods.prod-type = input frame Dialog-Frame varprod-type-plus and
                             bf-chk_goods.prod-code = input frame Dialog-Frame varprod-code-plus and
                             bf-chk_goods.artic     = input frame Dialog-Frame varartic-plus     no-lock no-error.
     if not available bf-chk_goods then do:
      message "Неправильный Тип производителя - такого товара нет.".
      apply "entry" to varprod-type-plus in frame Dialog-Frame.
      return.
     end.
  end.
  else do:
    if available bf-chk-two_goods then do:
        message "С артикулом :" input frame Dialog-Frame varartic-plus
                        "несколько товаров." skip (2)
                        "Укажите Производителя или выберите товар из справочника.".
        apply "entry" to varprod-type-plus in frame Dialog-Frame.
        return.
    end.
  end.
  if bf-chk_goods.artic     = input frame Dialog-Frame varartic     and
     bf-chk_goods.prod-type = input frame Dialog-Frame varprod-type and
     bf-chk_goods.prod-code = input frame Dialog-Frame varprod-code then do:
    message "Для списания и приходывания вы выбрали один и тот же товар." view-as alert-box error.
    apply "entry" to varartic-plus in frame Dialog-Frame.
    assign
      varartic-plus     = ""
      varprod-type-plus = ""
      varprod-code-plus = 0.
    display varartic-plus varprod-type-plus varprod-code-plus with frame Dialog-Frame.
    return error.
  end.
  run ver-gds IN THIS-PROCEDURE (bf-chk_goods.gds-code, output varnabor) no-error .
  if error-status:error
  then do:
     message return-value VIEW-AS ALERT-BOX.
     return  error.
  end.
  if varnabor = true then do:
    message "Это не товарная позиция - имеет атрибут НАБОР !!!".
    apply "entry" to varartic-plus in frame Dialog-Frame.
    return.
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf-chk_goods.artic
  ,  input bf-chk_goods.prod-type
  ,  input bf-chk_goods.prod-code
  , output is-petrol-plus
  , output is-pieces-plus
  ) no-error.
  find first bf_units where bf_units.unit-name = bf-chk_goods.unit-base no-lock.
  if lookup('2ед':U, bf_units.type) <> 0 then do:
    MESSAGE substitute ("В документе пересортица недопускается товар с двумя единицами измерения. Товар: &1 &2 &3", bf-chk_goods.artic, bf-chk_goods.prod-type, bf-chk_goods.prod-code) VIEW-AS ALERT-BOX ERROR.
    apply "entry" to varartic-plus in frame Dialog-Frame.
    assign
      varartic-plus     = ""
      varprod-type-plus = ""
      varprod-code-plus = 0.
    display varartic-plus varprod-type-plus varprod-code-plus with frame Dialog-Frame.
    return error.
  end.
  FIND FIRST bf_gds-prt WHERE bf_gds-prt.upper-code = bf-chk_goods.prt-root NO-LOCK NO-ERROR.
  IF lookup( bf-chk_goods.gds-type, 'у':U ) > 0 THEN DO:
    MESSAGE "В документе пересортица недопустимы услуги." VIEW-AS ALERT-BOX ERROR.
    apply "entry" to varartic-plus in frame Dialog-Frame.
    assign
      varartic-plus     = "":u
      varprod-type-plus = "":u
      varprod-code-plus = 0.
    display varartic-plus varprod-type-plus varprod-code-plus with frame Dialog-Frame.
    return error.
  end.
  find first bf_clients where bf_clients.obj-type = bf-chk_goods.prod-type and
                              bf_clients.obj-code = bf-chk_goods.prod-code no-lock.
  assign
    varartic-plus           = bf-chk_goods.artic
    varprod-type-plus       = bf-chk_goods.prod-type
    varprod-code-plus       = bf-chk_goods.prod-code
    vargds-name-plus        = bf-chk_goods.gds-name
    varunit-name-plus       = bf-chk_goods.unit-base
    varfull-scale-name-plus = (if bf_gds-prt.node-name = '_Пустая шкала':U then "":u else bf_gds-prt.f-name)
  .
  display varartic-plus varprod-type-plus varprod-code-plus vargds-name-plus varunit-name-plus with frame Dialog-Frame.
  if varfull-scale-name-plus <> "":u then do:
    display varfull-scale-name-plus with frame Dialog-Frame.
  end.
  else do:
    hide varfull-scale-name-plus in frame Dialog-Frame.
  end.
  if not(is-petrol-plus and not is-pieces-plus) then do:
    HIDE varqnty-kg-plus IN FRAME Dialog-Frame.
  END.
  ELSE DO:
    VIEW varqnty-kg-plus IN FRAME Dialog-Frame.
  END.
  if bf_gds-prt.node-name = '_Пустая шкала':U then do:
    if is-petrol-plus and not is-pieces-plus then do:
      for each tt-pl-qty-plus :
        delete tt-pl-qty-plus.
      end.
      assign
        varqnty-plus    = 0.00
        varqnty-kg-plus = 0.00.
      run str/prstptrl.w (BUFFER bf-chk_goods,
                      input  ?,
                      INPUT  pardoc-code,
                      INPUT  parobj-type,
                      INPUT  parobj-code,
                      INPUT  no,
                      INPUT  'ДОБАВЛЕНИЕ':U,
                      OUTPUT varstate)   no-error.
      if error-status:error or varstate <> yes then do:
        assign
          varartic-plus             = "":u
          varprod-type-plus         = "":u
          varprod-code-plus         = ?
          vargds-name-plus          = "":u
          varunit-name-plus         = "":u
          varfull-scale-name-plus   = "":u
        .
        display varartic-plus varprod-type-plus varprod-code-plus vargds-name-plus varunit-name with frame Dialog-Frame.
        if varfull-scale-name-plus:visible in frame Dialog-Frame then do:
          display varfull-scale-name-plus with frame Dialog-Frame.
        end.
        apply "entry" to varartic-plus in frame Dialog-Frame.
        return error.
      end.
      else do:
        for each tt-place :
          if tt-place.write-off-doc-l <> 0 then do:
            create tt-pl-qty-plus.
            assign
              tt-pl-qty-plus.pl-code = tt-place.pl-code
              tt-pl-qty-plus.qnty-l  = tt-place.income-l
              tt-pl-qty-plus.qnty-kg = tt-place.income-kg
            .
            assign
              varqnty-plus    = varqnty-plus    + tt-pl-qty-plus.qnty-l
              varqnty-kg-plus = varqnty-kg-plus + tt-pl-qty-plus.qnty-kg.
          end.
        end.
        display varqnty-plus varqnty-kg-plus with frame Dialog-Frame.
      end.
    end.
    else do:
      HIDE b-prt-in IN FRAME Dialog-Frame.
      assign
        parmode = "second-goods":u.
      enable varqnty-plus with frame Dialog-Frame.
      run ui-on in this-procedure.
    end.
  end.
  else do:
    hide varqnty-plus in frame Dialog-Frame.
    for each tt-gds-prt on error undo, return error return-value :
      delete tt-gds-prt.
    end.
    run str/prt-prst.w (buffer bf-chk_goods,
                    input  pardoc-code,
                    input  parobj-type,
                    input  parobj-code,
                    input  no,
                    INPUT  parmode,
                    output varstate) no-error.
    if error-status:error or varstate <> yes then do:
      assign
        varartic-plus           = "":u
        varprod-type-plus       = "":u
        varprod-code-plus       = ?
        vargds-name-plus        = "":u
        varunit-name-plus       = "":u
        varfull-scale-name-plus = "":u
      .
      display varartic-plus varprod-type-plus varprod-code-plus vargds-name-plus varunit-name-plus with frame Dialog-Frame.
      if varfull-scale-name-plus:visible in frame Dialog-Frame then do:
        display varfull-scale-name-plus with frame Dialog-Frame.
      end.
      apply "entry" to varartic-plus in frame Dialog-Frame.
      return error.
    end.
    else do:
      for each tt-gds-dtl-plus on error undo, return error return-value :
        delete tt-gds-dtl-plus.
      end.
      assign
        varqnty-plus = 0.00.
      for each tt-gds-prt where tt-gds-prt.income-qnty > 0 on error undo, return error return-value :
        create tt-gds-dtl-plus.
        assign
          tt-gds-dtl-plus.gds-code = bf-chk_goods.gds-code
          tt-gds-dtl-plus.prt-code = tt-gds-prt.prt-code
          tt-gds-dtl-plus.qnty     = tt-gds-prt.income-qnty.
        assign
          varqnty-plus = varqnty-plus + tt-gds-dtl-plus.qnty.
        display varqnty-plus with frame Dialog-Frame.
      end.
      apply "entry" to b-save in frame Dialog-Frame.
    end.
  end.
END.
END PROCEDURE.
PROCEDURE set-qnty :
IF INPUT FRAME Dialog-Frame varqnty = ?    OR
     INPUT FRAME Dialog-Frame varqnty = 0.00 THEN DO:
    MESSAGE "Вы не установили количество." VIEW-AS ALERT-BOX.
    return error.
  END.
ASSIGN FRAME Dialog-Frame
   varqnty.
RUN ui-on IN THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE set-qnty-plus :
IF INPUT FRAME Dialog-Frame varqnty-plus = ?    OR
   INPUT FRAME Dialog-Frame varqnty-plus = 0.00 THEN DO:
    MESSAGE "Вы не установили количество." VIEW-AS ALERT-BOX.
    return error.
END.
ASSIGN FRAME Dialog-Frame
   varqnty-plus.
RUN ui-on IN THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE ui-on :
DO ON ERROR UNDO, RETURN ERROR RETURN-VALUE:
  IF parmode = 'ДОБАВЛЕНИЕ':U THEN DO:
    ENABLE b-save varartic varprod-type varprod-code r-goods r-list
           varartic-plus varprod-type-plus varprod-code-plus r-goods-plus r-list-plus WITH FRAME Dialog-Frame.
  END.
  if parmode = 'ИЗМЕНЕНИЕ':U then do:
    ENABLE b-save WITH FRAME Dialog-Frame.
  end.
  CASE parmode:
    WHEN 'ПРОСМОТР':U THEN DO:
    END.
    WHEN 'ДОБАВЛЕНИЕ':U THEN DO:
      APPLY "entry" TO varartic IN FRAME Dialog-Frame.
    END.
    WHEN "first-goods":u THEN DO:
        APPLY "entry" TO varqnty IN FRAME Dialog-Frame.
    END.
    WHEN "second-goods":u THEN DO:
      APPLY "entry" TO varqnty-plus.
    END.
  END CASE.
END.
END PROCEDURE.
PROCEDURE ver-gds :
define input  parameter p-gds-code as integer   no-undo .
define output parameter  v-nabor   as logical   no-undo .
define variable varvalue        as character no-undo .
define variable vartype         as character no-undo .
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable EDOParSec       as class     ibs.th.gbl.env.prmtrs.edo .
define buffer buf_goods-attr for goods-attr.
 do
 on error undo, return error return-value
 :
  EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(parobj-type, parobj-code).
  RUN gds-attr-value (
          INPUT p-gds-code,
          INPUT 'mark-type':U,
          OUTPUT varvalue,
          OUTPUT vartype
          ).
  if varvalue > ""
  and EDOParSec:GetIsMarkingForType(varvalue)
  then
    return error substitute("Товар &1 с маркировкой нельзя добавлять.",p-gds-code).
  v-nabor = false .
  run ver-gds-grp-nabor in this-procedure ( input p-gds-code, output v-nabor) .
 END.
END PROCEDURE.
