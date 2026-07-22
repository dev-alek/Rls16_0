block-level on error undo, throw.
define input parameter p-caller as character no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-date-start as date no-undo .
define input parameter p-date-end as date no-undo .
define input parameter p-shift-date-start as date no-undo .
define input parameter p-shift-date-end as date no-undo .
define input parameter p-shift-num-start as integer no-undo .
define input parameter p-shift-num-end as integer no-undo .
define input parameter p-inkas-code as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 245fc987699b, 3203, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:28 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rpychk0.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/rpychk0.p $":U .
define variable vss-description as character no-undo init "Проверка размазывания чеков по алгоритму 1 и строке запроса".
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
define temp-table temp-chk-gds no-undo
field doc-code like ub.chk-doc.doc-code
FIELD b-code like ub.chk-gds.b-code
field discnt as decimal
field line-type  as character
field line-sign as logical
field sum as decimal
field line-num as integer
field num-lines as integer
field doc-qnty as decimal
field sign as integer
field rec-type as integer
field gds-type as integer
field density as decimal
field price-base as decimal
field price-service as decimal
field jjp_ as integer
field jjo_ as integer
field jj_ as integer
field flag as logical
field gds-code as integer
index pi iS unique primary
doc-code
rec-type
b-code
line-num
index ijj
jj_
line-num
index ijjp
doc-code
jjp_
line-num
index ijjo
doc-code
jjo_
line-num
index iflag
doc-code
flag
line-num
.
define temp-table temp-chk-pay no-undo
field doc-code like ub.chk-doc.doc-code
field pay-card as character
field pay-code as integer
field curr-code as integer
field sign as integer
field line-num as integer
field pet-good as integer
field is-cash  like ub.cash-pay.is-cash
field register like ub.cash-pay.register
field num-lines as integer
field tot-r-b as decimal
field tot-rubl as decimal
field tot-base as decimal
field flag as logical
field rrn as character
index pi is primary unique
doc-code
pay-code
curr-code
line-num
index isort
doc-code
pet-good  descending
line-num
index ipcard
doc-code
pay-code
curr-code
pay-card
rrn
index iflag
doc-code
flag
.
define temp-table temp-chk-dp no-undo
field doc-code like ub.chk-doc.doc-code
FIELD b-code like ub.chk-gds.b-code
field line-sign as logical
field sum as decimal
field qnty as decimal
field all-sum as decimal
field line-num as integer
field sign as integer
field pay-code as integer
index pi pay-code line-num
.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable pychk_kk as integer no-undo .
define variable pychk_jj as integer no-undo .
define variable pychk_jjp as integer no-undo .
define variable pychk_jjo as integer no-undo .
define variable pychk_pay-sum as decimal no-undo .
DEFINE VARIABLE pychk_No-EXCH as logical no-undo.
DEFINE VARIABLE pychk_No-EXCH-rubl as logical no-undo.
DEFINE VARIABLE pychk_dop-sump as decimal No-UNDO.
DEFINE VARIABLE pychk_dop-sumg as decimal No-UNDO.
DEFINE VARIABLE pychk_dop-sumk as decimal No-UNDO.
DEFINE VARIABLE pychk_exch as decimal No-UNDO.
DEFINE VARIABLE pychk_exch-rubl as decimal No-UNDO.
define variable pychk_rec-type as integer no-undo .
define variable pychk_line-type as integer no-undo .
define variable pychk_create as logical no-undo .
define variable pychk_pays_count as integer no-undo .
define variable pychk_zero-gds as decimal no-undo .
define variable pychk_zero-pay as decimal no-undo .
define variable pychk_zero-n as decimal no-undo .
define variable pychk_value as character no-undo .
define variable pychk_type as character no-undo .
define variable pychk_line-type-chr as character no-undo .
define variable pychk_payline_rrn as character no-undo .
define variable vSum as decimal no-undo.
define variable vSumRound as decimal no-undo.
define variable pychk_sum-promo as decimal no-undo.
define variable vPromoLineNum as integer no-undo.
define temp-table temp-ptrl-goods no-undo
field b-code as integer
field gds-code as integer
field ptrl-good as logical
index pi as unique primary
b-code
.
define buffer buf_temp-chk-gds for temp-chk-gds.
define buffer buf_temp-chk-gds2 for temp-chk-gds.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf2_chk-doc for ub.chk-doc.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_chk-pay-attr for ub.chk-pay-attr .
function ChkGdsPromo returns logical
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromo as logical no-undo.
    vPromo = no.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and buf_chk-gds-attr.attr-value <> "0":
       vPromo = yes.
       leave cspr.
    end.
    return vPromo.
end.
function ChkPromoLine returns logical
    (input iDocCode as character,
    input iLineNum as integer)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromo as logical no-undo.
    vPromo = no.
    find first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = iDocCode
             and buf_chk-gds-attr.line-num  = iLineNum
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and buf_chk-gds-attr.attr-value <> "0"
    no-error.
    if avail buf_chk-gds-attr then vPromo = yes.
    return vPromo.
end.
function ChkPromoSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vSumPromo as decimal no-undo.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromoSum"
      no-error.
   if avail buf_chk-gds-attr then
      vSumPromo = DEC(buf_chk-gds-attr.attr-value) no-error.
   return vSumPromo.
end function.
function ChkPromoPrice returns logical
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable v-is-promo as logical no-undo.
   v-is-promo = no.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr
     and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
   then v-is-promo = yes.
   return v-is-promo.
end function.
function ChkDopLitr returns logical
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable v-is-promo as logical no-undo.
   v-is-promo = no.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr and
     buf_chk-gds-attr.attr-value = "3"
   then v-is-promo = yes.
   return v-is-promo.
end function.
function RoundUp return decimal
    (input iQnty as decimal,
     input iPrice as decimal):
    def var vSum  as decimal no-undo.
    def var vSumR as decimal no-undo.
    vSum = ABSOLUTE(iQnty) * iPrice.
    vSumR = Round(vSum,2).
    if vSumR < vSum then vSumR = vSumR + 0.01.
    if iQnty < 0 then vSumR = - vSumR.
    return vSumR.
end function.
function GetPromoSum returns decimal
    (input iDocCode as character)
    :
    define buffer buf_chk-doc for ub.chk-doc.
    define buffer buf2_chk-doc for ub.chk-doc.
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define buffer buf2_chk-gds for ub.chk-gds.
    define buffer buf2_chk-gds-attr for ub.chk-gds-attr.
    define variable v-price-base as decimal no-undo.
    define variable v-doc-qnty as decimal no-undo.
    define variable v-sum-base as decimal no-undo.
    define variable v-sum-all as decimal no-undo.
    define variable v-sum-promo as decimal no-undo.
    define variable v-sum-chk as decimal no-undo.
    assign
       v-price-base = 0
       v-doc-qnty = 0
       v-sum-all = 0
       v-sum-chk = 0
       v-sum-promo = 0
       .
    for each buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iDocCode,
       first buf_chk-gds-attr no-lock where
             buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
         and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
         and buf_chk-gds-attr.attr-code = "CSPromoSum"
       :
       v-sum-promo = Dec(buf_chk-gds-attr.attr-value).
    end.
    if v-sum-promo = 0 then do:
        for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("1,6", buf_chk-gds-attr.attr-value)
           :
           assign
             v-price-base = buf_chk-gds.price-base
             v-doc-qnty   = if buf_chk-gds.doc-qnty = ? then buf_chk-gds.src-qnty else buf_chk-gds.doc-qnty
             v-sum-base = if buf_chk-gds.sum-base = ? then round(v-doc-qnty * v-price-base, 2) else buf_chk-gds.sum-base
             .
        end.
        for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
           :
           if v-price-base = 0 then do:
              find first buf_chk-doc no-lock where
                         buf_chk-doc.doc-code = iDocCode
                  no-error.
              if avail buf_chk-doc and
                 buf_chk-doc.chk-type = int('6':U) and
                 buf_chk-doc.doc-num2 > ""  and
                 num-entries(buf_chk-doc.doc-num2,":") = 2
              then
              for first buf2_chk-doc no-lock where
                        buf2_chk-doc.obj-code = buf_chk-doc.obj-code
                    and buf2_chk-doc.obj-type = buf_chk-doc.obj-type
                    and buf2_chk-doc.chk-type = int('1':U)
                    and buf2_chk-doc.chk-num = int(entry(1,buf_chk-doc.doc-num2,":"))
                    and buf2_chk-doc.z-number = int(entry(2, buf_chk-doc.doc-num2,":"))
                    :
                for each buf2_chk-gds no-lock where
                         buf2_chk-gds.doc-code = buf2_chk-doc.doc-code,
                   first buf2_chk-gds-attr no-lock where
                         buf2_chk-gds-attr.doc-code = buf2_chk-gds.doc-code
                     and buf2_chk-gds-attr.line-num  = buf2_chk-gds.line-num
                     and buf2_chk-gds-attr.attr-code = "CSPromo"
                     and can-do("1,6", buf2_chk-gds-attr.attr-value)
                   :
                    v-price-base = buf2_chk-gds.price-base.
                end.
              end.
           end.
           if buf_chk-gds.sum-base = ? or buf_chk-gds.src-qnty = 0 then do:
               assign
                  v-sum-all = (buf_chk-gds.src-qnty + v-doc-qnty) * v-price-base
                  v-sum-chk = v-sum-base + RoundUp(buf_chk-gds.src-qnty, buf_chk-gds.src-price)
                  .
           end.
           else do:
              assign
              v-sum-all = (buf_chk-gds.doc-qnty + v-doc-qnty ) * v-price-base
              v-sum-chk = v-sum-base + buf_chk-gds.sum-base
              .
           end.
        end.
        v-sum-promo = Round(v-sum-all, 2) - Round(v-sum-chk, 2).
    end.
    return v-sum-promo.
end function.
function GetUnBaseSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vBaseSum as decimal no-undo.
   define variable vDiscSum as decimal no-undo.
   vDiscSum = 0.
   find first buf_chk-gds-attr no-lock where
                     buf_chk-gds-attr.doc-code = iDocCode
                 and buf_chk-gds-attr.line-num  = iLineNum
                 and buf_chk-gds-attr.attr-code = "CSPromoSum"
          no-error.
   if avail buf_chk-gds-attr then
      vDiscSum = dec(buf_chk-gds-attr.attr-value) no-error.
   vBaseSum = iQnty * iPrice + vDiscSum.
   if vDiscSum = 0 and ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   return vBaseSum.
end function.
function GetRoundSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vBaseSum as decimal no-undo.
   if ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   else vBaseSum = iQnty * iPrice.
   return vBaseSum.
end function.
function GetRoundSumChkDel returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iChipNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer  buf_c-chk-doc-attr for ub.c-chk-doc-attr.
   define variable vBaseSum as decimal no-undo.
   define variable vIsPromo as logical no-undo.
   for each buf_c-chk-doc-attr no-lock where
            buf_c-chk-doc-attr.doc-code = iDocCode
        and buf_c-chk-doc-attr.chip-num = iChipNum
       :
       if num-entries(buf_c-chk-doc-attr.attr-code, chr(4)) > 1
       then do :
         if entry(1, buf_c-chk-doc-attr.attr-code, chr(4)) begins "gds="
         and entry(2, buf_c-chk-doc-attr.attr-code, chr(4)) = "CSPromo"
         and entry(2, entry(1, buf_c-chk-doc-attr.attr-code, chr(4)), "=") = String(iLineNum)
         and can-do("2,4,5,7", buf_c-chk-doc-attr.attr-value)
         then vIsPromo = yes.
       end.
   end.
   if ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   else vBaseSum = iQnty * iPrice.
   return vBaseSum.
end function.
function GetSaleRetDisc returns decimal
    (input iDocCode as character,
     input iSaleCode as character):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf_chk-gds for ub.chk-gds.
   define variable vQntyPromoRet as decimal no-undo.
   define variable vQntyPromoSel as decimal no-undo.
   define variable vDiscSumRet   as decimal no-undo.
   define variable vDiscSumSale  as decimal no-undo.
   vDiscSumRet = 0.
   cspr:
   for each  buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iDocCode,
       first buf_chk-gds-attr no-lock where
             buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
         and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
         and buf_chk-gds-attr.attr-code = "CSPromo"
         and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
       :
       vQntyPromoRet = buf_chk-gds.src-qnty.
       leave cspr.
   end.
   if vQntyPromoRet <> 0 then
   for each  buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iSaleCode:
       find first buf_chk-gds-attr no-lock where
                  buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
              and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
              and buf_chk-gds-attr.attr-code = "CSPromo"
       no-error.
       if avail buf_chk-gds-attr
            and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
       then
         vQntyPromoSel = buf_chk-gds.src-qnty.
       find first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromoSum"
       no-error.
       if avail buf_chk-gds-attr then
          vDiscSumSale = dec(buf_chk-gds-attr.attr-value) no-error.
   end.
   if vQntyPromoRet <> 0 and
      vQntyPromoSel = -1 * vQntyPromoRet
   then vDiscSumRet = -1 * vDiscSumSale.
   return vDiscSumRet.
end function.
function SetPromoDisc return logical
 (input iDocCode as character,
     input iLineNum as integer
     )
    :
   define buffer buf_chk-doc for ub.chk-doc.
   define buffer buf2_chk-doc for ub.chk-doc.
   define buffer buf_chk-gds for ub.chk-gds.
   define buffer buf2_chk-gds for ub.chk-gds.
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf2_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf_chk-discnt for ub.chk-discnt.
   define buffer buf2_chk-discnt for ub.chk-discnt.
   define buffer buf_chk-discnt-attr for ub.chk-discnt-attr.
   define buffer buf2_chk-discnt-attr for ub.chk-discnt-attr.
   define variable v-promo-sum as decimal no-undo.
   define variable v-disc-promo-id as character no-undo.
   define variable var-discnt-id as integer no-undo.
   define variable v-chk-sale as character no-undo.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr
     then do:
     find first buf_chk-discnt no-lock where
                buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
            and buf_chk-discnt.line-num = buf_chk-gds-attr.line-num
            and buf_chk-discnt.record-type = 0
            and buf_chk-discnt.promo-id > ""
            no-error.
     if not avail buf_chk-discnt then do:
        find first buf_chk-doc no-lock where
                   buf_chk-doc.doc-code = iDocCode
           no-error.
        find first buf_chk-gds no-lock where
                   buf_chk-gds.doc-code = iDocCode
              and  buf_chk-gds.line-num = iLineNum
           no-error.
       for first buf2_chk-doc no-lock where
                 buf2_chk-doc.obj-code = buf_chk-doc.obj-code
             and buf2_chk-doc.obj-type = buf_chk-doc.obj-type
             and buf2_chk-doc.pay-desk = buf_chk-doc.pay-desk
             and buf2_chk-doc.chk-type = int('1':U)
             and buf2_chk-doc.chk-num  = int(entry(1,buf_chk-doc.doc-num2,":"))
             and buf2_chk-doc.z-number = int(entry(2, buf_chk-doc.doc-num2,":"))
           :
           find first buf2_chk-gds no-lock where
                      buf2_chk-gds.doc-code = buf2_chk-doc.doc-code
                 and  buf2_chk-gds.b-code   = buf_chk-gds.b-code
           no-error.
           if not avail buf2_chk-gds then return no.
           v-chk-sale = buf2_chk-doc.doc-code.
           find first buf_chk-discnt no-lock where
                      buf_chk-discnt.doc-code =  buf2_chk-doc.doc-code and
                      buf_chk-discnt.record-type = 1 and
                      buf_chk-discnt.object-line-num = buf2_chk-gds.line-num and
                      buf_chk-discnt.promo-id > ""
           no-error .
           if avail buf_chk-discnt
           then do:
              v-disc-promo-id = buf_chk-discnt.promo-id.
              find first buf2_chk-discnt no-lock where
                buf2_chk-discnt.doc-code = iDocCode and
                buf2_chk-discnt.record-type = 5 and
                buf2_chk-discnt.line-num = 0 and
                buf2_chk-discnt.promo-id =  v-disc-promo-id
              no-error.
              find first buf2_chk-discnt-attr no-lock where
                         buf2_chk-discnt-attr.doc-code = iDocCode and
                         buf2_chk-discnt-attr.record-type = 5 and
                         buf2_chk-discnt-attr.line-num = 0 and
                         buf2_chk-discnt-attr.attr-code = "promo-id" and
                         buf2_chk-discnt-attr.attr-value = v-disc-promo-id
                    no-error .
              if not avail buf2_chk-discnt
              then do:
                  for each buf_chk-discnt no-lock where
                           buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
                       and buf_chk-discnt.record-type = 5:
                       var-discnt-id  = var-discnt-id + 1.
                  end.
                  create buf2_chk-discnt.
                  assign
                    buf2_chk-discnt.doc-code = iDocCode
                    buf2_chk-discnt.record-type = 5
                    buf2_chk-discnt.line-num = 0
                    buf2_chk-discnt.promo-id = v-disc-promo-id
                    buf2_chk-discnt.object-sum = 0
                    buf2_chk-discnt.discnt-id = if avail buf2_chk-discnt-attr
                                                   then buf2_chk-discnt-attr.discnt-id
                                                   else (var-discnt-id + 1)
                    var-discnt-id = 0
                    buf2_chk-discnt.object-line-num = 0
                    buf2_chk-discnt.pay-desk = buf_chk-doc.pay-desk
                    buf2_chk-discnt.obj-code = buf_chk-doc.obj-code
                    buf2_chk-discnt.obj-type = buf_chk-doc.obj-type
                    buf2_chk-discnt.chk-date = buf_chk-doc.chk-date
                    buf2_chk-discnt.shift-date = buf_chk-doc.shift-date
                    buf2_chk-discnt.shift-num = buf_chk-doc.shift-num
                    buf2_chk-discnt.chk-time = buf_chk-doc.chk-time
                    .
              end.
              if avail buf2_chk-discnt and
                 not avail buf2_chk-discnt-attr
              then do:
                 create buf2_chk-discnt-attr.
                 assign
                    buf2_chk-discnt-attr.doc-code = iDocCode
                    buf2_chk-discnt-attr.discnt-id = buf2_chk-discnt.discnt-id
                    buf2_chk-discnt-attr.record-type     = 5
                    buf2_chk-discnt-attr.line-num        = 0
                    buf2_chk-discnt-attr.object-line-num = 0
                    buf2_chk-discnt-attr.attr-code       = "promo-id"
                    buf2_chk-discnt-attr.attr-value      = v-disc-promo-id
                    .
              end.
           end.
       end.
        v-promo-sum = 0.
        if can-do("1,6,7", buf_chk-gds-attr.attr-value)
        then do:
           if v-chk-sale <> ? and v-chk-sale <> "" then
              v-promo-sum = GetSaleRetDisc(iDocCode,v-chk-sale).
           v-promo-sum = if v-promo-sum = 0 then GetPromoSum(iDocCode) else v-promo-sum.
           if v-promo-sum <> 0 then do:
               find first buf2_chk-gds-attr no-lock where
                          buf2_chk-gds-attr.doc-code = iDocCode
                      and buf2_chk-gds-attr.line-num  = iLineNum
                      and buf2_chk-gds-attr.attr-code = "CSPromoSum"
                  no-error.
               if not avail buf2_chk-gds-attr then do:
                   create buf2_chk-gds-attr.
                   assign
                      buf2_chk-gds-attr.doc-code = iDocCode
                      buf2_chk-gds-attr.line-num  = iLineNum
                      buf2_chk-gds-attr.attr-code = "CSPromoSum"
                      buf2_chk-gds-attr.attr-value = string(Round(v-promo-sum,2))
                      .
               end.
           end.
        end.
        for each buf_chk-discnt no-lock where
                buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
            and buf_chk-discnt.record-type = 0:
           var-discnt-id  = var-discnt-id + 1.
        end.
        create buf_chk-discnt.
        assign
            buf_chk-discnt.doc-code = iDocCode
            buf_chk-discnt.line-num = iLineNum
            buf_chk-discnt.record-type = 0
            buf_chk-discnt.discnt-id = (var-discnt-id + 1)
            buf_chk-discnt.time-oper = buf_chk-gds.time-oper
            buf_chk-discnt.line-type = integer('1':U)
            buf_chk-discnt.line-sign = no
            buf_chk-discnt.pass-discnt = integer('0':U)
            buf_chk-discnt.value-type = integer('2':U)
            buf_chk-discnt.src-d-card = buf_chk-gds.src-d-card
            buf_chk-discnt.d-card = buf_chk-gds.d-card
            buf_chk-discnt.discnt-value-abs = 0
            buf_chk-discnt.discnt-value-pcnt = 0
            buf_chk-discnt.object-line-num = iLineNum
            buf_chk-discnt.pay-desk = buf_chk-doc.pay-desk
            buf_chk-discnt.obj-code = buf_chk-doc.obj-code
            buf_chk-discnt.obj-type = buf_chk-doc.obj-type
            buf_chk-discnt.chk-date = buf_chk-doc.chk-date
            buf_chk-discnt.chk-time = buf_chk-doc.chk-time
            buf_chk-discnt.shift-date = buf_chk-doc.shift-date
            buf_chk-discnt.shift-num = buf_chk-doc.shift-num
            buf_chk-discnt.object-qnty = buf_chk-gds.src-qnty
            buf_chk-discnt.object-sum = buf_chk-gds.src-sum
            var-discnt-id = var-discnt-id + 1
            buf_chk-discnt.promo-id = v-disc-promo-id
            buf_chk-discnt.discnt-type = integer('7':U)
            .
        find first buf_chk-discnt-attr no-lock where
                   buf_chk-discnt-attr.attr-code = "promo-id"
               and buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
               and buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
               and buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
               no-error.
        if not avail buf_chk-discnt-attr then
        do:
            create buf_chk-discnt-attr .
            assign
                buf_chk-discnt-attr.attr-code = "promo-id"
                buf_chk-discnt-attr.attr-value = buf_chk-discnt.promo-id
                buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
                buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
                buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
                buf_chk-discnt-attr.object-line-num = buf_chk-discnt.object-line-num
                buf_chk-discnt-attr.record-type = buf_chk-discnt.record-type
                .
         end.
     end.
   end.
   return yes.
end function.
function GetPromoPriceSum returns decimal
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromoSum as decimal no-undo.
    vPromoSum = 0.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value):
       vPromoSum = RoundUp(buf_chk-gds.src-qnty, buf_chk-gds.src-price).
       leave cspr.
    end.
    return vPromoSum.
end.
function GetPromoPriceLine returns integer
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromoLine as integer no-undo.
    vPromoLine = 0.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value):
       vPromoLine = buf_chk-gds-attr.line-num.
       leave cspr.
    end.
    return vPromoLine.
end.
define variable v-host-code as integer no-undo .
define variable v-base-code as integer no-undo .
define variable v-curr-r-b as character no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
if v-curr-r-b = 'base':U or
v-base-code = 0 then pychk_NO-exch = yes.
else pychk_No-exch = no.
if v-curr-r-b = 'rubl':U or
v-base-code = 0 then pychk_NO-exch-rubl = yes.
else pychk_No-exch-rubl = no.
case p-caller:
  when "r-shftc2" then do:
    _chk-doc:
    FOR EACH ub.chk-doc No-LOCK WHERE
            ub.chk-doc.obj-type = p-obj-type
        AND ub.chk-doc.obj-code = p-obj-code
        AND ub.chk-doc.shift-date >= p-shift-date-start
        AND ub.chk-doc.shift-date <= p-shift-date-end
        and ub.chk-doc.out-code <> ?,
      EACH ub.chk-pay NO-LOCK WHERE
              ub.chk-pay.doc-code = ub.chk-doc.doc-code
      BREAK
      BY ub.CHK-pay.doc-code
      BY ub.CHK-pay.line-num:
      if ub.chk-doc.shift-date = p-shift-date-start  and ub.chk-doc.shift-num < p-shift-num-start  then next .
      if ub.chk-doc.shift-date = p-shift-date-end and ub.chk-doc.shift-num > p-shift-num-end then next .
      if lookup(string(ub.chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next _chk-doc.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first-of(ub.CHK-pay.DOC-CODE) THEN Do:
  pychk_create = not can-find (first buf_chk-gds-pay
                               where buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code
                                 and buf_chk-gds-pay.algo-num = "1.8") .
  if pychk_create then do:
    for each temp-chk-pay:
      delete temp-chk-pay.
    end.
    for each temp-chk-gds:
      delete temp-chk-gds.
    end.
    for each temp-chk-dp:
      delete temp-chk-dp.
    end.
    assign
    pychk_kk = 0
    pychk_jj = 1
    pychk_jjp = 0
    pychk_jjo = 0
    pychk_pay-sum = ub.chk-doc.netto
    pychk_dop-sumg = 0
    pychk_pays_count = 0
    .
  end .
end.
if pychk_create   then do:
create-block:
do transaction
on stop   undo create-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo create-block, return error substitute( "&1. endkey", vss-workfile )
on error  undo, throw:
  find first buf2_chk-doc exclusive-lock where
         recid(buf2_chk-doc) = recid(ub.chk-doc).
  if first-of(ub.CHK-pay.DOC-CODE) THEN Do:
    FOR EACH ub.chk-gds No-LOCK WHERE
            ub.chk-gds.doc-code = ub.chk-pay.doc-code
    BY ub.chk-gds.line-num:
      if   ub.chk-gds.write-off-code > 0
        or ub.chk-gds.doc-qnty  eq 0
        or ub.chk-gds.doc-qnty  eq ?
      then NEXT.
      find first buf_bar-code no-lock where
                buf_bar-code.b-code = ub.chk-gds.b-code no-error.
      if not available buf_bar-code then do:
        undo create-block, return error substitute("Не найден товар для бар-кода &1: чек &2 &3&4 строка &5"
                                                    , ub.chk-gds.b-code
                                                    , ub.chk-gds.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , ub.chk-gds.line-num).
      end.
      if ub.chk-gds.pump <> 0 then do:
        pychk_rec-type = 1.
        find first temp-ptrl-goods where
                   temp-ptrl-goods.b-code = ub.chk-gds.b-code no-error.
        if not available temp-ptrl-goods then do:
          run gds-attr-value in this-procedure (
                                                 input buf_bar-code.gds-code
                                                ,input 'ptrl-as-good':U
                                                ,output pychk_value
                                                ,output pychk_type) no-error.
          create temp-ptrl-goods.
          assign
          temp-ptrl-goods.gds-code = buf_bar-code.gds-code
          temp-ptrl-goods.b-code = buf_bar-code.b-code
          temp-ptrl-goods.ptrl-good = (not logical(pychk_value))
          no-error.
        end.
        pychk_line-type = if temp-ptrl-goods.ptrl-good then 1 else 0 .
        release temp-ptrl-goods.
      end.
      else do:
        assign
        pychk_rec-type = 0
        pychk_line-type = 0
        .
      end.
      find first temp-chk-gds where
                temp-chk-gds.doc-code = ub.chk-gds.doc-code
            AND temp-chk-gds.rec-type = pychk_rec-type
            and temp-chk-gds.b-code = ub.chk-gds.b-code
            and temp-chk-gds.line-num = 0
            no-error.
      if not available temp-chk-gds then do:
        find first temp-chk-gds use-index ijj where
                temp-chk-gds.jj_ = pychk_jj
            and temp-chk-gds.line-num = 0
                no-error.
        if not available temp-chk-gds then do:
          create temp-chk-gds.
          assign
          temp-chk-gds.jj_ = pychk_jj
          temp-chk-gds.b-code = ub.chk-gds.b-code
          temp-chk-gds.doc-code = ub.chk-gds.doc-code
          temp-chk-gds.line-num = 0
          temp-chk-gds.rec-type = pychk_rec-type
          temp-chk-gds.gds-code = buf_bar-code.gds-code.
          .
        end.
        else do:
          assign
          temp-chk-gds.b-code = ub.chk-gds.b-code
          temp-chk-gds.doc-code = ub.chk-gds.doc-code
          temp-chk-gds.line-num = 0
          temp-chk-gds.rec-type = pychk_rec-type
          temp-chk-gds.sum = 0
          temp-chk-gds.jjp_ = 0
          temp-chk-gds.jjo_ = 0
          temp-chk-gds.line-type = '':U
          temp-chk-gds.num-lines = 0
          temp-chk-gds.doc-qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.flag  = no
          .
        end.
        assign
        temp-chk-gds.line-type = (if pychk_line-type = 1
                                then 'топ':U
                                else entry(1, ub.chk-gds.line-type, chr(4))
                                ) + chr(4) +
                                (if num-entries(ub.chk-gds.line-type, chr(4)) > 1
                                then entry(2, ub.chk-gds.line-type, chr(4))
                                else '')
        temp-chk-gds.line-num = 0
        temp-chk-gds.num-lines = 0
        temp-chk-gds.density   = ub.chk-gds.density
        pychk_jj = pychk_jj + 1
        .
        if pychk_rec-type = 1 then do:
          assign
          temp-chk-gds.jjp_ = pychk_jjp + 1
          pychk_jjp = pychk_jjp + 1
          .
        end.
        else do:
          assign
          temp-chk-gds.jjo_ = pychk_jjo + 1
          pychk_jjo = pychk_jjo + 1
          .
        end.
      end.
      vSumRound = ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt).
      if ChkPromoPrice(ub.chk-gds.doc-code, ub.chk-gds.line-num) then vSumRound = ub.chk-gds.src-sum.
      assign
      temp-chk-gds.doc-qnty = temp-chk-gds.doc-qnty + ub.chk-gds.doc-qnty
      temp-chk-gds.sum = temp-chk-gds.sum + vSumRound
      temp-chk-gds.num-lines = temp-chk-gds.num-lines  + 1
      .
      find first temp-chk-gds use-index ijj where
              temp-chk-gds.jj_ = 0
          and temp-chk-gds.line-num = ub.chk-gds.line-num
              no-error.
      if not available temp-chk-gds then do:
        create temp-chk-gds.
        assign
        temp-chk-gds.jj_ = 0
        temp-chk-gds.line-num = ub.chk-gds.line-num
        temp-chk-gds.doc-code = ub.chk-gds.doc-code
        temp-chk-gds.b-code = ub.chk-gds.b-code
        temp-chk-gds.gds-code = buf_bar-code.gds-code
        temp-chk-gds.rec-type = pychk_rec-type
        temp-chk-gds.line-num = ub.chk-gds.line-num
        .
      end.
      else do:
        assign
        temp-chk-gds.doc-qnty = 0
        temp-chk-gds.doc-code = ub.chk-gds.doc-code
        temp-chk-gds.b-code = ub.chk-gds.b-code
        temp-chk-gds.gds-code = buf_bar-code.gds-code
        temp-chk-gds.rec-type = pychk_rec-type
        temp-chk-gds.line-num = ub.chk-gds.line-num
        temp-chk-gds.jjp_ = 0
        temp-chk-gds.jjo_ = 0
        temp-chk-gds.line-type = '':U
                .
      end.
      assign
      temp-chk-gds.doc-code = ub.chk-gds.doc-code
      temp-chk-gds.b-code = ub.chk-gds.b-code
      temp-chk-gds.doc-qnty = ub.chk-gds.doc-qnty
      temp-chk-gds.price-base = ub.chk-gds.price-base
      temp-chk-gds.price-service = ub.chk-gds.price-service
      temp-chk-gds.line-type = (if pychk_line-type = 1
                              then 'топ':U
                              else entry(1, ub.chk-gds.line-type, chr(4))
                              ) + chr(4) +
                              (if num-entries(ub.chk-gds.line-type, chr(4)) > 1
                              then entry(2, ub.chk-gds.line-type, chr(4))
                              else '')
      temp-chk-gds.line-sign = ub.chk-gds.line-sign
      temp-chk-gds.discnt = ub.chk-gds.discnt
      temp-chk-gds.sum = vSumRound
      temp-chk-gds.rec-type = pychk_rec-type
      temp-chk-gds.line-num = ub.chk-gds.line-num
      temp-chk-gds.num-lines = 1
      temp-chk-gds.density   = ub.chk-gds.density
      .
    END.
    for each chk-discnt no-lock
       where chk-discnt.doc-code = ub.chk-doc.doc-code
         and record-type = 10
         and chk-discnt.discnt-value-abs <> 0,
        first ub.chk-gds of ub.chk-doc where ub.chk-gds.line-num =  chk-discnt.object-line-num :
            if ub.chk-doc.chk-type = 1 and chk-discnt.object-qnty < 0 then do:
                for first temp-chk-dp where temp-chk-dp.doc-code = ub.chk-doc.doc-code
                and temp-chk-dp.b-code = chk-gds.b-code:
                    temp-chk-dp.sum = temp-chk-dp.sum - abs(chk-discnt.discnt-value-abs * chk-discnt.object-qnty).
                end.
            end.
            else do:
                create temp-chk-dp .
                assign
                temp-chk-dp.doc-code = ub.chk-doc.doc-code
                temp-chk-dp.sum = abs(chk-discnt.discnt-value-abs) * chk-discnt.object-qnty
                temp-chk-dp.line-num = chk-discnt.object-line-num
                temp-chk-dp.pay-code = chk-discnt.rank
                temp-chk-dp.b-code = chk-gds.b-code
                temp-chk-dp.qnty   = abs(chk-discnt.discnt-value-pcnt)
                temp-chk-dp.all-sum =  chk-discnt.discnt-value-abs * chk-discnt.discnt-value-pcnt
                .
            end.
    end.
  end.
  FIND FIRST ub.cash-pay No-LOCK WHERE
            ub.cash-pay.cdpay-code = ub.chk-pay.pay-code AND
            ub.cash-pay.curr-code = ub.chk-pay.curr-code No-ERROR.
  if available ub.cash-pay then do:
    pychk_payline_rrn = "" .
    if not ub.cash-pay.is-cash then do :
      for first buf_chk-pay-attr no-lock
          where buf_chk-pay-attr.doc-code  = ub.CHK-pay.DOC-CODE
            and buf_chk-pay-attr.attr-code = "cpdoc":U
            and buf_chk-pay-attr.line-num  = ub.CHK-pay.line-num :
        pychk_payline_rrn = buf_chk-pay-attr.attr-value .
      end .
    end .
      find first temp-chk-pay where
              temp-chk-pay.doc-code = ub.chk-pay.doc-code
          and temp-chk-pay.pay-code = ub.chk-pay.pay-code
          and temp-chk-pay.pay-card = ub.chk-pay.pay-card
          and temp-chk-pay.curr-code = ub.chk-pay.curr-code
          and temp-chk-pay.rrn       = pychk_payline_rrn
                 no-error.
    if not available temp-chk-pay then do:
        find first temp-chk-pay where
                temp-chk-pay.doc-code = ub.chk-pay.doc-code
            and temp-chk-pay.pay-code = ub.chk-pay.pay-code
            and temp-chk-pay.pay-card = ub.chk-pay.pay-card
            and temp-chk-pay.curr-code = ub.chk-pay.curr-code
            and abs(temp-chk-pay.tot-r-b) >= abs(ub.chk-pay.tot-sum)
            and (temp-chk-pay.tot-r-b >=0) NE (ub.chk-pay.tot-sum >=0)
            no-error.
      if not  avail temp-chk-pay then do:
        find first temp-chk-pay where
                  temp-chk-pay.doc-code = ub.chk-pay.doc-code
              and temp-chk-pay.line-num = ub.chk-pay.line-num use-index pi no-error.
        if not available temp-chk-pay then do:
          create temp-chk-pay.
          assign
          temp-chk-pay.line-num = ub.chk-pay.line-num
          temp-chk-pay.doc-code = ub.chk-doc.doc-code
          temp-chk-pay.pay-code = ub.chk-pay.pay-code
          temp-chk-pay.curr-code =  ub.chk-pay.curr-code
          temp-chk-pay.rrn       = pychk_payline_rrn
          pychk_pays_count = pychk_pays_count + 1
          .
        end.
        assign
        temp-chk-pay.doc-code = ub.chk-doc.doc-code
        temp-chk-pay.pet-good = integer(cash-pay.atr64) * 2 + integer(cash-pay.is-cash) + 2 * int(can-find(first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code ))
        temp-chk-pay.pay-code = ub.chk-pay.pay-code
        temp-chk-pay.curr-code =  ub.chk-pay.curr-code
        temp-chk-pay.is-cash  = ub.cash-pay.is-cash
        temp-chk-pay.register = ub.cash-pay.register
        temp-chk-pay.pay-card = ub.chk-pay.pay-card
        temp-chk-pay.tot-rubl = 0
        temp-chk-pay.tot-base = 0
        temp-chk-pay.num-lines = 0
        temp-chk-pay.flag  = no
        .
      end.
    end.
    assign
    temp-chk-pay.tot-r-b = temp-chk-pay.tot-r-b + (if v-curr-r-b = 'rubl':U
                                                   then ub.chk-pay.tot-rubl
                                                   else ub.chk-pay.tot-base)
    temp-chk-pay.tot-rubl = temp-chk-pay.tot-rubl + ub.chk-pay.tot-rubl
    temp-chk-pay.tot-base = temp-chk-pay.tot-base + ub.chk-pay.tot-base
    temp-chk-pay.num-lines = temp-chk-pay.num-lines  + 1
    .
  end.
  if available temp-chk-pay then RELEASE TEMP-CHK-PAY.
  if last-of(ub.chk-pay.doc-code) then do:
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-doc.doc-code:
       if    (temp-chk-pay.tot-r-b  >= 0) NE (ub.chk-doc.netto >= 0)
          and temp-chk-pay.tot-r-b <> 0
          and abs(ub.chk-doc.netto) > 0.00000001
       then do:
          if not g#auto then do:
             message
                substitute("Не могу обработать чек &1&2&3&4 смена &5 пор.&6 касса &7 № на кассе &8"
                          ,ub.chk-doc.doc-code
                          ,chr(10)
                          ,ub.chk-doc.obj-type
                          ,ub.chk-doc.obj-code
                          ,ub.chk-doc.shift-date
                          ,ub.chk-doc.shift-num
                          ,ub.chk-doc.pay-desk
                          ,ub.chk-doc.chk-num)
                view-as alert-box error .
          end.
          next _chk-doc.
       end.
    end.
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-doc.doc-code
    break
    by temp-chk-pay.pet-good descending
    by temp-chk-pay.line-num:
       dp:
       for each temp-chk-dp no-lock
          where temp-chk-dp.pay-code = temp-chk-pay.pay-code
            and temp-chk-dp.doc-code = temp-chk-pay.doc-code
            and temp-chk-dp.sum <> 0 :
            find first buf_temp-chk-gds2 where
                buf_temp-chk-gds2.doc-code = ub.chk-doc.doc-code
            and buf_temp-chk-gds2.line-num  =  temp-chk-dp.line-num no-error.
            if available buf_temp-chk-gds2 then
            for each buf_temp-chk-gds where
                buf_temp-chk-gds.b-code = buf_temp-chk-gds2.b-code
                and buf_temp-chk-gds.line-num ne 0
            no-lock by buf_temp-chk-gds.line-num  ne  temp-chk-dp.line-num :
                 if         temp-chk-dp.all-sum  eq ?
                    or abs(temp-chk-dp.all-sum) <= 0.001
                then
                   next dp.
                find first  temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                    and buf_temp-chk-gds.b-code = temp-chk-gds.b-code
                  and temp-chk-gds.line-num = 0
                no-error .
                if not available temp-chk-gds then next dp.
                case num-entries(buf_temp-chk-gds.line-type, chr(4)):
                    when 1 then do:
                      pychk_line-type-chr = temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
                    end.
                    when 2 then do:
                      pychk_line-type-chr = temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
                    end.
                end case.
                pychk_dop-sumk =  if temp-chk-dp.sum >= 0
                then min(temp-chk-dp.all-sum,temp-chk-dp.sum,buf_temp-chk-gds.sum,temp-chk-pay.tot-r-b)
                else max(temp-chk-dp.all-sum,temp-chk-dp.sum,buf_temp-chk-gds.sum).
                if abs(temp-chk-pay.tot-r-b - pychk_dop-sumk) <= 0.001
                then
                   pychk_dop-sumk = temp-chk-pay.tot-r-b.
                temp-chk-dp.all-sum           = temp-chk-dp.all-sum - pychk_dop-sumk.
                if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                create buf_chk-gds-pay.
                  assign
                  buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                  buf_chk-gds-pay.chk-type = ub.chk-doc.chk-type
                  buf_chk-gds-pay.algo-num = "1.8"
                  buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
                  buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
                  buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                  buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                  buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
                  buf_chk-gds-pay.tot-r-b =  pychk_dop-sumk
                  buf_chk-gds-pay.eff-base-rate = 1
                  buf_chk-gds-pay.eff-doc-qnty = (if (temp-chk-gds.num-lines = 1
                                                  and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                                  and pychk_pays_count = 1)
                                                  or (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt) = 0
                                                  then temp-chk-gds.doc-qnty
                                                  else (buf_chk-gds-pay.tot-r-b / (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt))
                                                  )
                  buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
                  buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
                  buf_chk-gds-pay.price-base = buf_temp-chk-gds.price-base
                  buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
                  buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
                  buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
                  buf_chk-gds-pay.line-type = pychk_line-type-chr
                  buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
                  buf_chk-gds-pay.density  = buf_temp-chk-gds.density
                  buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
                  buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
                  buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
                  buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
                  buf_chk-gds-pay.out-code = ub.chk-doc.out-code
                  buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
                  buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
                  buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
                  .
                assign
                buf_temp-chk-gds.sum = buf_temp-chk-gds.sum - buf_chk-gds-pay.tot-r-b
                temp-chk-gds.sum =  temp-chk-gds.sum - buf_chk-gds-pay.tot-r-b
                buf_temp-chk-gds.doc-qnty = buf_temp-chk-gds.doc-qnty - buf_chk-gds-pay.eff-doc-qnty
                temp-chk-pay.tot-r-b = temp-chk-pay.tot-r-b - buf_chk-gds-pay.tot-r-b
                pychk_dop-sumk = pychk_dop-sumk - buf_chk-gds-pay.tot-r-b
                .
                 if (ub.chk-doc.chk-type = 1 and temp-chk-pay.tot-r-b <= 0) or (ub.chk-doc.chk-type <> 1 and temp-chk-pay.tot-r-b >= 0) then leave dp.
            end.
        end.
      assign
      pychk_dop-sump = temp-chk-pay.tot-r-b
      pychk_exch = if pychk_No-exch then 1
                   else (if temp-chk-pay.tot-base = 0
                         then 0
                         else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base)
      pychk_exch-rubl = if pychk_No-exch-rubl
                        then 1
                        else (if temp-chk-pay.tot-base = 0
                              then 0
                              else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base)
      temp-chk-pay.flag = (if abs(temp-chk-pay.tot-rubl) < 0.001 then no else yes)
      .
      _repeat:
      REPEAT WHILE  abs(pychk_dop-sump) > 0 :
        if pychk_dop-sumg = 0 then do:
          assign
          pychk_kk = pychk_kk + 1
          .
          if pychk_kk >= pychk_jj then LEAVE _repeat.
          if pychk_kk <= pychk_jjp then do:
            find first temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                  and temp-chk-gds.jjp_ = pychk_kk
                  and temp-chk-gds.line-num = 0
                no-error .
          end.
          else do:
            find first temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                  and temp-chk-gds.jjo_ = pychk_kk - pychk_jjp
                  and temp-chk-gds.line-num = 0
                no-error .
          end.
          if not available temp-chk-gds
          or (temp-chk-gds.sum = 0
              or
              (temp-chk-gds.sum <= 0  and ub.chk-doc.netto > 0)
              )
          then do:
            NEXT _repeat.
          end.
          assign
          pychk_dop-sumg = if available temp-chk-gds then temp-chk-gds.sum else 0
          temp-chk-gds.flag = yes
          .
        end.
        assign
        pychk_dop-sumk = min(abs(pychk_dop-sumg), abs(pychk_dop-sump))  * (if pychk_dop-sump > 0 then 1 else -1 ) * (if pychk_dop-sumg < 0 AND ub.chk-doc.chk-type = 1 then -1 else 1 )
        pychk_pay-sum = pychk_pay-sum - pychk_dop-sumk
        pychk_dop-sump = pychk_dop-sump - pychk_dop-sumk
        pychk_dop-sumg = pychk_dop-sumg - pychk_dop-sumk
        pychk_sum-promo = GetPromoPriceSum(ub.chk-doc.doc-code)
        .
        if pychk_sum-promo <> 0 then
           vPromoLineNum = GetPromoPriceLine(ub.chk-doc.doc-code).
        else vPromoLineNum = 0.
        for each buf_temp-chk-gds where
                buf_temp-chk-gds.doc-code = ub.chk-doc.doc-code
            and buf_temp-chk-gds.b-code = temp-chk-gds.b-code
            and buf_temp-chk-gds.line-num  > 0
        by buf_temp-chk-gds.doc-code
        by buf_temp-chk-gds.rec-type descending
        by buf_temp-chk-gds.line-num
         :
          case num-entries(buf_temp-chk-gds.line-type, chr(4)):
            when 1 then do:
              pychk_line-type-chr = buf_temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
            end.
            when 2 then do:
              pychk_line-type-chr = buf_temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
            end.
          end case.
          if  vPromoLineNum <> 0 and
              temp-chk-gds.num-lines > 1 and
              buf_temp-chk-gds.line-num = vPromoLineNum and
              can-find(first buf_chk-gds-pay no-lock where
                             buf_chk-gds-pay.doc-code = buf_temp-chk-gds.doc-code
                         and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num)
          then .
          else
          if not (buf_temp-chk-gds.sum = 0 and can-find (first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code and buf_temp-chk-gds.line-num  =  temp-chk-dp.line-num)) then do:
              if vPromoLineNum <> 0 and
                 buf_temp-chk-gds.line-num = vPromoLineNum
              then do:
                 vSum = RoundUp(buf_temp-chk-gds.doc-qnty, buf_temp-chk-gds.price-base).
              end.
              else if vPromoLineNum <> 0 and
                      temp-chk-gds.num-lines > 1 and
                      pychk_sum-promo <> 0 and
                      ChkPromoLine(buf_temp-chk-gds.doc-code, buf_temp-chk-gds.line-num)
              then do:
                  if can-find(first buf_chk-gds-pay no-lock where
                                    buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                                and buf_chk-gds-pay.line-num = vPromoLineNum
                                )
                   then vSum = (pychk_dop-sumk * buf_temp-chk-gds.sum / (temp-chk-gds.sum - pychk_sum-promo)).
                   else vSum = ((pychk_dop-sumk - pychk_sum-promo) * buf_temp-chk-gds.sum / (temp-chk-gds.sum - pychk_sum-promo)).
              end.
              else
              vSum                     = (if    temp-chk-gds.num-lines = 1
                                            and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                          then pychk_dop-sumk
                                          else (pychk_dop-sumk * buf_temp-chk-gds.sum / temp-chk-gds.sum)
                                         )
              .
              if can-find (first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code) then do:
                  find first buf_chk-gds-pay where buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                  and buf_chk-gds-pay.algo-num = "1.8"
                  and buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
                  and buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
                  and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                  and buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
                  and buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card exclusive-lock no-error.
                  if not available buf_chk-gds-pay then do:
                     if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                     then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                     create buf_chk-gds-pay.
                  end.
              end.
              else do:
                   if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                   then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                   create buf_chk-gds-pay.
              end.
              assign
              buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
              buf_chk-gds-pay.chk-type = ub.chk-doc.chk-type
              buf_chk-gds-pay.algo-num = "1.8"
              buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
              buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
              buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
              buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
              buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
              buf_chk-gds-pay.tot-r-b = buf_chk-gds-pay.tot-r-b  + vSum
              buf_chk-gds-pay.eff-base-rate = pychk_exch
              buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
              buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
              buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
              buf_chk-gds-pay.price-base = buf_temp-chk-gds.price-base
              buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
              buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
              buf_chk-gds-pay.line-type = pychk_line-type-chr
              buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
              buf_chk-gds-pay.density  = buf_temp-chk-gds.density
              buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
              buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
              buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
              buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
              buf_chk-gds-pay.out-code = ub.chk-doc.out-code
              buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
              buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
              buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
              buf_temp-chk-gds.flag = yes
              .
              if buf_temp-chk-gds.line-num = vPromoLineNum
              then do:
                 buf_chk-gds-pay.eff-doc-qnty = buf_temp-chk-gds.doc-qnty.
              end.
              else
              buf_chk-gds-pay.eff-doc-qnty = (if buf_chk-gds-pay.eff-doc-qnty = ? then 0 else buf_chk-gds-pay.eff-doc-qnty) + (if (temp-chk-gds.num-lines = 1
                                              and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                              and pychk_pays_count = 1)
                                              or (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt) = 0
                                              then temp-chk-gds.doc-qnty
                                              else (vSum / (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt))
                                              )
              .
            end.
        end.
      end.
    end.
    if available temp-chk-gds then release temp-chk-gds.
    if available temp-chk-pay then release temp-chk-pay.
    pychk_zero-gds = 0.
    pychk_zero-pay = 0.
    for each temp-chk-gds where
            temp-chk-gds.doc-code = ub.chk-pay.doc-code
        and temp-chk-gds.flag = no
        and temp-chk-gds.line-num  > 0
        :
       pychk_zero-gds = pychk_zero-gds + 1.
    end.
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-pay.doc-code
        and temp-chk-pay.flag = no:
       pychk_zero-pay = pychk_zero-pay + 1.
    end.
    find first temp-chk-pay where temp-chk-pay.doc-code = ub.chk-pay.doc-code
                              and temp-chk-pay.flag = no
    no-lock no-error.
    if not available temp-chk-pay
    then do:
       block-pay:
       for each temp-chk-pay where temp-chk-pay.doc-code = ub.chk-pay.doc-code:
          assign
             pychk_zero-pay = pychk_zero-pay +  1
             temp-chk-pay.flag = no
          .
          leave block-pay.
       end.
    end.
    for each temp-chk-pay
    where   temp-chk-pay.doc-code = ub.chk-pay.doc-code
        and temp-chk-pay.flag = no:
      pychk_zero-n = 0.
      for each buf_temp-chk-gds
      where   buf_temp-chk-gds.doc-code = ub.chk-pay.doc-code
          and buf_temp-chk-gds.flag = no
          and buf_temp-chk-gds.line-num  > 0 :
        pychk_zero-n = pychk_zero-n + 1.
        if  temp-chk-pay.tot-r-b = 0 and buf_temp-chk-gds.discnt = 0 and abs(buf_temp-chk-gds.sum) > 0 then next.
        case num-entries(buf_temp-chk-gds.line-type, chr(4)):
          when 1 then do:
            pychk_line-type-chr = buf_temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
          end.
          when 2 then do:
            pychk_line-type-chr = buf_temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
          end.
        end case.
        if can-find(first buf_chk-gds-pay no-lock where
                          buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                      and buf_chk-gds-pay.algo-num = "1.8"
                      and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                      and buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num)
        then do:
            buf_temp-chk-gds.flag = yes.
        end.
        else do:
            create buf_chk-gds-pay.
            assign
            buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
            buf_chk-gds-pay.algo-num = "1.8"
            buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
            buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
            buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
            buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
            buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
            buf_chk-gds-pay.tot-r-b = 0
            buf_chk-gds-pay.eff-base-rate = pychk_exch
            buf_chk-gds-pay.eff-doc-qnty = buf_temp-chk-gds.doc-qnty
            buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
            buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
            buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
            buf_chk-gds-pay.price-base = (if temp-chk-pay.tot-r-b = 0 and buf_temp-chk-gds.discnt = 0 then 0 else buf_temp-chk-gds.price-base)
            buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
            buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
            buf_chk-gds-pay.line-type = pychk_line-type-chr
            buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
            buf_chk-gds-pay.density  = buf_temp-chk-gds.density
            buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
            buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
            buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
            buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
            buf_chk-gds-pay.out-code = ub.chk-doc.out-code
            buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
            buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
            buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
            buf_temp-chk-gds.flag = yes
            .
        end.
        if pychk_zero-n > pychk_zero-gds / pychk_zero-pay then leave.
      end.
      temp-chk-pay.flag = yes.
    end.
  end.
end.
end.
    end.
  end.
  when "r-shft3f" then do:
    _chk-doc:
    FOR EACH ub.chk-doc No-LOCK WHERE
            ub.chk-doc.obj-type = p-obj-type
        AND ub.chk-doc.obj-code = p-obj-code
        AND ub.chk-doc.shift-date >= p-shift-date-start
        AND ub.chk-doc.shift-date <= p-shift-date-end,
      EACH ub.chk-pay NO-LOCK WHERE
              ub.chk-pay.doc-code = ub.chk-doc.doc-code
      BREAK
      BY ub.CHK-pay.doc-code
      BY ub.CHK-pay.line-num:
      if ub.chk-doc.shift-date = p-shift-date-start  and ub.chk-doc.shift-num < p-shift-num-start  then next .
      if ub.chk-doc.shift-date = p-shift-date-end and ub.chk-doc.shift-num > p-shift-num-end then next .
      if lookup(string(ub.chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next _chk-doc.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first-of(ub.CHK-pay.DOC-CODE) THEN Do:
  pychk_create = not can-find (first buf_chk-gds-pay
                               where buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code
                                 and buf_chk-gds-pay.algo-num = "1.8") .
  if pychk_create then do:
    for each temp-chk-pay:
      delete temp-chk-pay.
    end.
    for each temp-chk-gds:
      delete temp-chk-gds.
    end.
    for each temp-chk-dp:
      delete temp-chk-dp.
    end.
    assign
    pychk_kk = 0
    pychk_jj = 1
    pychk_jjp = 0
    pychk_jjo = 0
    pychk_pay-sum = ub.chk-doc.netto
    pychk_dop-sumg = 0
    pychk_pays_count = 0
    .
  end .
end.
if pychk_create   then do:
create-block:
do transaction
on stop   undo create-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo create-block, return error substitute( "&1. endkey", vss-workfile )
on error  undo, throw:
  find first buf2_chk-doc exclusive-lock where
         recid(buf2_chk-doc) = recid(ub.chk-doc).
  if first-of(ub.CHK-pay.DOC-CODE) THEN Do:
    FOR EACH ub.chk-gds No-LOCK WHERE
            ub.chk-gds.doc-code = ub.chk-pay.doc-code
    BY ub.chk-gds.line-num:
      if   ub.chk-gds.write-off-code > 0
        or ub.chk-gds.doc-qnty  eq 0
        or ub.chk-gds.doc-qnty  eq ?
      then NEXT.
      find first buf_bar-code no-lock where
                buf_bar-code.b-code = ub.chk-gds.b-code no-error.
      if not available buf_bar-code then do:
        undo create-block, return error substitute("Не найден товар для бар-кода &1: чек &2 &3&4 строка &5"
                                                    , ub.chk-gds.b-code
                                                    , ub.chk-gds.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , ub.chk-gds.line-num).
      end.
      if ub.chk-gds.pump <> 0 then do:
        pychk_rec-type = 1.
        find first temp-ptrl-goods where
                   temp-ptrl-goods.b-code = ub.chk-gds.b-code no-error.
        if not available temp-ptrl-goods then do:
          run gds-attr-value in this-procedure (
                                                 input buf_bar-code.gds-code
                                                ,input 'ptrl-as-good':U
                                                ,output pychk_value
                                                ,output pychk_type) no-error.
          create temp-ptrl-goods.
          assign
          temp-ptrl-goods.gds-code = buf_bar-code.gds-code
          temp-ptrl-goods.b-code = buf_bar-code.b-code
          temp-ptrl-goods.ptrl-good = (not logical(pychk_value))
          no-error.
        end.
        pychk_line-type = if temp-ptrl-goods.ptrl-good then 1 else 0 .
        release temp-ptrl-goods.
      end.
      else do:
        assign
        pychk_rec-type = 0
        pychk_line-type = 0
        .
      end.
      find first temp-chk-gds where
                temp-chk-gds.doc-code = ub.chk-gds.doc-code
            AND temp-chk-gds.rec-type = pychk_rec-type
            and temp-chk-gds.b-code = ub.chk-gds.b-code
            and temp-chk-gds.line-num = 0
            no-error.
      if not available temp-chk-gds then do:
        find first temp-chk-gds use-index ijj where
                temp-chk-gds.jj_ = pychk_jj
            and temp-chk-gds.line-num = 0
                no-error.
        if not available temp-chk-gds then do:
          create temp-chk-gds.
          assign
          temp-chk-gds.jj_ = pychk_jj
          temp-chk-gds.b-code = ub.chk-gds.b-code
          temp-chk-gds.doc-code = ub.chk-gds.doc-code
          temp-chk-gds.line-num = 0
          temp-chk-gds.rec-type = pychk_rec-type
          temp-chk-gds.gds-code = buf_bar-code.gds-code.
          .
        end.
        else do:
          assign
          temp-chk-gds.b-code = ub.chk-gds.b-code
          temp-chk-gds.doc-code = ub.chk-gds.doc-code
          temp-chk-gds.line-num = 0
          temp-chk-gds.rec-type = pychk_rec-type
          temp-chk-gds.sum = 0
          temp-chk-gds.jjp_ = 0
          temp-chk-gds.jjo_ = 0
          temp-chk-gds.line-type = '':U
          temp-chk-gds.num-lines = 0
          temp-chk-gds.doc-qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.flag  = no
          .
        end.
        assign
        temp-chk-gds.line-type = (if pychk_line-type = 1
                                then 'топ':U
                                else entry(1, ub.chk-gds.line-type, chr(4))
                                ) + chr(4) +
                                (if num-entries(ub.chk-gds.line-type, chr(4)) > 1
                                then entry(2, ub.chk-gds.line-type, chr(4))
                                else '')
        temp-chk-gds.line-num = 0
        temp-chk-gds.num-lines = 0
        temp-chk-gds.density   = ub.chk-gds.density
        pychk_jj = pychk_jj + 1
        .
        if pychk_rec-type = 1 then do:
          assign
          temp-chk-gds.jjp_ = pychk_jjp + 1
          pychk_jjp = pychk_jjp + 1
          .
        end.
        else do:
          assign
          temp-chk-gds.jjo_ = pychk_jjo + 1
          pychk_jjo = pychk_jjo + 1
          .
        end.
      end.
      vSumRound = ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt).
      if ChkPromoPrice(ub.chk-gds.doc-code, ub.chk-gds.line-num) then vSumRound = ub.chk-gds.src-sum.
      assign
      temp-chk-gds.doc-qnty = temp-chk-gds.doc-qnty + ub.chk-gds.doc-qnty
      temp-chk-gds.sum = temp-chk-gds.sum + vSumRound
      temp-chk-gds.num-lines = temp-chk-gds.num-lines  + 1
      .
      find first temp-chk-gds use-index ijj where
              temp-chk-gds.jj_ = 0
          and temp-chk-gds.line-num = ub.chk-gds.line-num
              no-error.
      if not available temp-chk-gds then do:
        create temp-chk-gds.
        assign
        temp-chk-gds.jj_ = 0
        temp-chk-gds.line-num = ub.chk-gds.line-num
        temp-chk-gds.doc-code = ub.chk-gds.doc-code
        temp-chk-gds.b-code = ub.chk-gds.b-code
        temp-chk-gds.gds-code = buf_bar-code.gds-code
        temp-chk-gds.rec-type = pychk_rec-type
        temp-chk-gds.line-num = ub.chk-gds.line-num
        .
      end.
      else do:
        assign
        temp-chk-gds.doc-qnty = 0
        temp-chk-gds.doc-code = ub.chk-gds.doc-code
        temp-chk-gds.b-code = ub.chk-gds.b-code
        temp-chk-gds.gds-code = buf_bar-code.gds-code
        temp-chk-gds.rec-type = pychk_rec-type
        temp-chk-gds.line-num = ub.chk-gds.line-num
        temp-chk-gds.jjp_ = 0
        temp-chk-gds.jjo_ = 0
        temp-chk-gds.line-type = '':U
                .
      end.
      assign
      temp-chk-gds.doc-code = ub.chk-gds.doc-code
      temp-chk-gds.b-code = ub.chk-gds.b-code
      temp-chk-gds.doc-qnty = ub.chk-gds.doc-qnty
      temp-chk-gds.price-base = ub.chk-gds.price-base
      temp-chk-gds.price-service = ub.chk-gds.price-service
      temp-chk-gds.line-type = (if pychk_line-type = 1
                              then 'топ':U
                              else entry(1, ub.chk-gds.line-type, chr(4))
                              ) + chr(4) +
                              (if num-entries(ub.chk-gds.line-type, chr(4)) > 1
                              then entry(2, ub.chk-gds.line-type, chr(4))
                              else '')
      temp-chk-gds.line-sign = ub.chk-gds.line-sign
      temp-chk-gds.discnt = ub.chk-gds.discnt
      temp-chk-gds.sum = vSumRound
      temp-chk-gds.rec-type = pychk_rec-type
      temp-chk-gds.line-num = ub.chk-gds.line-num
      temp-chk-gds.num-lines = 1
      temp-chk-gds.density   = ub.chk-gds.density
      .
    END.
    for each chk-discnt no-lock
       where chk-discnt.doc-code = ub.chk-doc.doc-code
         and record-type = 10
         and chk-discnt.discnt-value-abs <> 0,
        first ub.chk-gds of ub.chk-doc where ub.chk-gds.line-num =  chk-discnt.object-line-num :
            if ub.chk-doc.chk-type = 1 and chk-discnt.object-qnty < 0 then do:
                for first temp-chk-dp where temp-chk-dp.doc-code = ub.chk-doc.doc-code
                and temp-chk-dp.b-code = chk-gds.b-code:
                    temp-chk-dp.sum = temp-chk-dp.sum - abs(chk-discnt.discnt-value-abs * chk-discnt.object-qnty).
                end.
            end.
            else do:
                create temp-chk-dp .
                assign
                temp-chk-dp.doc-code = ub.chk-doc.doc-code
                temp-chk-dp.sum = abs(chk-discnt.discnt-value-abs) * chk-discnt.object-qnty
                temp-chk-dp.line-num = chk-discnt.object-line-num
                temp-chk-dp.pay-code = chk-discnt.rank
                temp-chk-dp.b-code = chk-gds.b-code
                temp-chk-dp.qnty   = abs(chk-discnt.discnt-value-pcnt)
                temp-chk-dp.all-sum =  chk-discnt.discnt-value-abs * chk-discnt.discnt-value-pcnt
                .
            end.
    end.
  end.
  FIND FIRST ub.cash-pay No-LOCK WHERE
            ub.cash-pay.cdpay-code = ub.chk-pay.pay-code AND
            ub.cash-pay.curr-code = ub.chk-pay.curr-code No-ERROR.
  if available ub.cash-pay then do:
    pychk_payline_rrn = "" .
    if not ub.cash-pay.is-cash then do :
      for first buf_chk-pay-attr no-lock
          where buf_chk-pay-attr.doc-code  = ub.CHK-pay.DOC-CODE
            and buf_chk-pay-attr.attr-code = "cpdoc":U
            and buf_chk-pay-attr.line-num  = ub.CHK-pay.line-num :
        pychk_payline_rrn = buf_chk-pay-attr.attr-value .
      end .
    end .
      find first temp-chk-pay where
              temp-chk-pay.doc-code = ub.chk-pay.doc-code
          and temp-chk-pay.pay-code = ub.chk-pay.pay-code
          and temp-chk-pay.pay-card = ub.chk-pay.pay-card
          and temp-chk-pay.curr-code = ub.chk-pay.curr-code
          and temp-chk-pay.rrn       = pychk_payline_rrn
                 no-error.
    if not available temp-chk-pay then do:
        find first temp-chk-pay where
                temp-chk-pay.doc-code = ub.chk-pay.doc-code
            and temp-chk-pay.pay-code = ub.chk-pay.pay-code
            and temp-chk-pay.pay-card = ub.chk-pay.pay-card
            and temp-chk-pay.curr-code = ub.chk-pay.curr-code
            and abs(temp-chk-pay.tot-r-b) >= abs(ub.chk-pay.tot-sum)
            and (temp-chk-pay.tot-r-b >=0) NE (ub.chk-pay.tot-sum >=0)
            no-error.
      if not  avail temp-chk-pay then do:
        find first temp-chk-pay where
                  temp-chk-pay.doc-code = ub.chk-pay.doc-code
              and temp-chk-pay.line-num = ub.chk-pay.line-num use-index pi no-error.
        if not available temp-chk-pay then do:
          create temp-chk-pay.
          assign
          temp-chk-pay.line-num = ub.chk-pay.line-num
          temp-chk-pay.doc-code = ub.chk-doc.doc-code
          temp-chk-pay.pay-code = ub.chk-pay.pay-code
          temp-chk-pay.curr-code =  ub.chk-pay.curr-code
          temp-chk-pay.rrn       = pychk_payline_rrn
          pychk_pays_count = pychk_pays_count + 1
          .
        end.
        assign
        temp-chk-pay.doc-code = ub.chk-doc.doc-code
        temp-chk-pay.pet-good = integer(cash-pay.atr64) * 2 + integer(cash-pay.is-cash) + 2 * int(can-find(first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code ))
        temp-chk-pay.pay-code = ub.chk-pay.pay-code
        temp-chk-pay.curr-code =  ub.chk-pay.curr-code
        temp-chk-pay.is-cash  = ub.cash-pay.is-cash
        temp-chk-pay.register = ub.cash-pay.register
        temp-chk-pay.pay-card = ub.chk-pay.pay-card
        temp-chk-pay.tot-rubl = 0
        temp-chk-pay.tot-base = 0
        temp-chk-pay.num-lines = 0
        temp-chk-pay.flag  = no
        .
      end.
    end.
    assign
    temp-chk-pay.tot-r-b = temp-chk-pay.tot-r-b + (if v-curr-r-b = 'rubl':U
                                                   then ub.chk-pay.tot-rubl
                                                   else ub.chk-pay.tot-base)
    temp-chk-pay.tot-rubl = temp-chk-pay.tot-rubl + ub.chk-pay.tot-rubl
    temp-chk-pay.tot-base = temp-chk-pay.tot-base + ub.chk-pay.tot-base
    temp-chk-pay.num-lines = temp-chk-pay.num-lines  + 1
    .
  end.
  if available temp-chk-pay then RELEASE TEMP-CHK-PAY.
  if last-of(ub.chk-pay.doc-code) then do:
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-doc.doc-code:
       if    (temp-chk-pay.tot-r-b  >= 0) NE (ub.chk-doc.netto >= 0)
          and temp-chk-pay.tot-r-b <> 0
          and abs(ub.chk-doc.netto) > 0.00000001
       then do:
          if not g#auto then do:
             message
                substitute("Не могу обработать чек &1&2&3&4 смена &5 пор.&6 касса &7 № на кассе &8"
                          ,ub.chk-doc.doc-code
                          ,chr(10)
                          ,ub.chk-doc.obj-type
                          ,ub.chk-doc.obj-code
                          ,ub.chk-doc.shift-date
                          ,ub.chk-doc.shift-num
                          ,ub.chk-doc.pay-desk
                          ,ub.chk-doc.chk-num)
                view-as alert-box error .
          end.
          next _chk-doc.
       end.
    end.
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-doc.doc-code
    break
    by temp-chk-pay.pet-good descending
    by temp-chk-pay.line-num:
       dp:
       for each temp-chk-dp no-lock
          where temp-chk-dp.pay-code = temp-chk-pay.pay-code
            and temp-chk-dp.doc-code = temp-chk-pay.doc-code
            and temp-chk-dp.sum <> 0 :
            find first buf_temp-chk-gds2 where
                buf_temp-chk-gds2.doc-code = ub.chk-doc.doc-code
            and buf_temp-chk-gds2.line-num  =  temp-chk-dp.line-num no-error.
            if available buf_temp-chk-gds2 then
            for each buf_temp-chk-gds where
                buf_temp-chk-gds.b-code = buf_temp-chk-gds2.b-code
                and buf_temp-chk-gds.line-num ne 0
            no-lock by buf_temp-chk-gds.line-num  ne  temp-chk-dp.line-num :
                 if         temp-chk-dp.all-sum  eq ?
                    or abs(temp-chk-dp.all-sum) <= 0.001
                then
                   next dp.
                find first  temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                    and buf_temp-chk-gds.b-code = temp-chk-gds.b-code
                  and temp-chk-gds.line-num = 0
                no-error .
                if not available temp-chk-gds then next dp.
                case num-entries(buf_temp-chk-gds.line-type, chr(4)):
                    when 1 then do:
                      pychk_line-type-chr = temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
                    end.
                    when 2 then do:
                      pychk_line-type-chr = temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
                    end.
                end case.
                pychk_dop-sumk =  if temp-chk-dp.sum >= 0
                then min(temp-chk-dp.all-sum,temp-chk-dp.sum,buf_temp-chk-gds.sum,temp-chk-pay.tot-r-b)
                else max(temp-chk-dp.all-sum,temp-chk-dp.sum,buf_temp-chk-gds.sum).
                if abs(temp-chk-pay.tot-r-b - pychk_dop-sumk) <= 0.001
                then
                   pychk_dop-sumk = temp-chk-pay.tot-r-b.
                temp-chk-dp.all-sum           = temp-chk-dp.all-sum - pychk_dop-sumk.
                if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                create buf_chk-gds-pay.
                  assign
                  buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                  buf_chk-gds-pay.chk-type = ub.chk-doc.chk-type
                  buf_chk-gds-pay.algo-num = "1.8"
                  buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
                  buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
                  buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                  buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                  buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
                  buf_chk-gds-pay.tot-r-b =  pychk_dop-sumk
                  buf_chk-gds-pay.eff-base-rate = 1
                  buf_chk-gds-pay.eff-doc-qnty = (if (temp-chk-gds.num-lines = 1
                                                  and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                                  and pychk_pays_count = 1)
                                                  or (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt) = 0
                                                  then temp-chk-gds.doc-qnty
                                                  else (buf_chk-gds-pay.tot-r-b / (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt))
                                                  )
                  buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
                  buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
                  buf_chk-gds-pay.price-base = buf_temp-chk-gds.price-base
                  buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
                  buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
                  buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
                  buf_chk-gds-pay.line-type = pychk_line-type-chr
                  buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
                  buf_chk-gds-pay.density  = buf_temp-chk-gds.density
                  buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
                  buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
                  buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
                  buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
                  buf_chk-gds-pay.out-code = ub.chk-doc.out-code
                  buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
                  buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
                  buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
                  .
                assign
                buf_temp-chk-gds.sum = buf_temp-chk-gds.sum - buf_chk-gds-pay.tot-r-b
                temp-chk-gds.sum =  temp-chk-gds.sum - buf_chk-gds-pay.tot-r-b
                buf_temp-chk-gds.doc-qnty = buf_temp-chk-gds.doc-qnty - buf_chk-gds-pay.eff-doc-qnty
                temp-chk-pay.tot-r-b = temp-chk-pay.tot-r-b - buf_chk-gds-pay.tot-r-b
                pychk_dop-sumk = pychk_dop-sumk - buf_chk-gds-pay.tot-r-b
                .
                 if (ub.chk-doc.chk-type = 1 and temp-chk-pay.tot-r-b <= 0) or (ub.chk-doc.chk-type <> 1 and temp-chk-pay.tot-r-b >= 0) then leave dp.
            end.
        end.
      assign
      pychk_dop-sump = temp-chk-pay.tot-r-b
      pychk_exch = if pychk_No-exch then 1
                   else (if temp-chk-pay.tot-base = 0
                         then 0
                         else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base)
      pychk_exch-rubl = if pychk_No-exch-rubl
                        then 1
                        else (if temp-chk-pay.tot-base = 0
                              then 0
                              else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base)
      temp-chk-pay.flag = (if abs(temp-chk-pay.tot-rubl) < 0.001 then no else yes)
      .
      _repeat:
      REPEAT WHILE  abs(pychk_dop-sump) > 0 :
        if pychk_dop-sumg = 0 then do:
          assign
          pychk_kk = pychk_kk + 1
          .
          if pychk_kk >= pychk_jj then LEAVE _repeat.
          if pychk_kk <= pychk_jjp then do:
            find first temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                  and temp-chk-gds.jjp_ = pychk_kk
                  and temp-chk-gds.line-num = 0
                no-error .
          end.
          else do:
            find first temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                  and temp-chk-gds.jjo_ = pychk_kk - pychk_jjp
                  and temp-chk-gds.line-num = 0
                no-error .
          end.
          if not available temp-chk-gds
          or (temp-chk-gds.sum = 0
              or
              (temp-chk-gds.sum <= 0  and ub.chk-doc.netto > 0)
              )
          then do:
            NEXT _repeat.
          end.
          assign
          pychk_dop-sumg = if available temp-chk-gds then temp-chk-gds.sum else 0
          temp-chk-gds.flag = yes
          .
        end.
        assign
        pychk_dop-sumk = min(abs(pychk_dop-sumg), abs(pychk_dop-sump))  * (if pychk_dop-sump > 0 then 1 else -1 ) * (if pychk_dop-sumg < 0 AND ub.chk-doc.chk-type = 1 then -1 else 1 )
        pychk_pay-sum = pychk_pay-sum - pychk_dop-sumk
        pychk_dop-sump = pychk_dop-sump - pychk_dop-sumk
        pychk_dop-sumg = pychk_dop-sumg - pychk_dop-sumk
        pychk_sum-promo = GetPromoPriceSum(ub.chk-doc.doc-code)
        .
        if pychk_sum-promo <> 0 then
           vPromoLineNum = GetPromoPriceLine(ub.chk-doc.doc-code).
        else vPromoLineNum = 0.
        for each buf_temp-chk-gds where
                buf_temp-chk-gds.doc-code = ub.chk-doc.doc-code
            and buf_temp-chk-gds.b-code = temp-chk-gds.b-code
            and buf_temp-chk-gds.line-num  > 0
        by buf_temp-chk-gds.doc-code
        by buf_temp-chk-gds.rec-type descending
        by buf_temp-chk-gds.line-num
         :
          case num-entries(buf_temp-chk-gds.line-type, chr(4)):
            when 1 then do:
              pychk_line-type-chr = buf_temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
            end.
            when 2 then do:
              pychk_line-type-chr = buf_temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
            end.
          end case.
          if  vPromoLineNum <> 0 and
              temp-chk-gds.num-lines > 1 and
              buf_temp-chk-gds.line-num = vPromoLineNum and
              can-find(first buf_chk-gds-pay no-lock where
                             buf_chk-gds-pay.doc-code = buf_temp-chk-gds.doc-code
                         and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num)
          then .
          else
          if not (buf_temp-chk-gds.sum = 0 and can-find (first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code and buf_temp-chk-gds.line-num  =  temp-chk-dp.line-num)) then do:
              if vPromoLineNum <> 0 and
                 buf_temp-chk-gds.line-num = vPromoLineNum
              then do:
                 vSum = RoundUp(buf_temp-chk-gds.doc-qnty, buf_temp-chk-gds.price-base).
              end.
              else if vPromoLineNum <> 0 and
                      temp-chk-gds.num-lines > 1 and
                      pychk_sum-promo <> 0 and
                      ChkPromoLine(buf_temp-chk-gds.doc-code, buf_temp-chk-gds.line-num)
              then do:
                  if can-find(first buf_chk-gds-pay no-lock where
                                    buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                                and buf_chk-gds-pay.line-num = vPromoLineNum
                                )
                   then vSum = (pychk_dop-sumk * buf_temp-chk-gds.sum / (temp-chk-gds.sum - pychk_sum-promo)).
                   else vSum = ((pychk_dop-sumk - pychk_sum-promo) * buf_temp-chk-gds.sum / (temp-chk-gds.sum - pychk_sum-promo)).
              end.
              else
              vSum                     = (if    temp-chk-gds.num-lines = 1
                                            and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                          then pychk_dop-sumk
                                          else (pychk_dop-sumk * buf_temp-chk-gds.sum / temp-chk-gds.sum)
                                         )
              .
              if can-find (first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code) then do:
                  find first buf_chk-gds-pay where buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                  and buf_chk-gds-pay.algo-num = "1.8"
                  and buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
                  and buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
                  and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                  and buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
                  and buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card exclusive-lock no-error.
                  if not available buf_chk-gds-pay then do:
                     if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                     then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                     create buf_chk-gds-pay.
                  end.
              end.
              else do:
                   if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                   then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                   create buf_chk-gds-pay.
              end.
              assign
              buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
              buf_chk-gds-pay.chk-type = ub.chk-doc.chk-type
              buf_chk-gds-pay.algo-num = "1.8"
              buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
              buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
              buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
              buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
              buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
              buf_chk-gds-pay.tot-r-b = buf_chk-gds-pay.tot-r-b  + vSum
              buf_chk-gds-pay.eff-base-rate = pychk_exch
              buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
              buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
              buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
              buf_chk-gds-pay.price-base = buf_temp-chk-gds.price-base
              buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
              buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
              buf_chk-gds-pay.line-type = pychk_line-type-chr
              buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
              buf_chk-gds-pay.density  = buf_temp-chk-gds.density
              buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
              buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
              buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
              buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
              buf_chk-gds-pay.out-code = ub.chk-doc.out-code
              buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
              buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
              buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
              buf_temp-chk-gds.flag = yes
              .
              if buf_temp-chk-gds.line-num = vPromoLineNum
              then do:
                 buf_chk-gds-pay.eff-doc-qnty = buf_temp-chk-gds.doc-qnty.
              end.
              else
              buf_chk-gds-pay.eff-doc-qnty = (if buf_chk-gds-pay.eff-doc-qnty = ? then 0 else buf_chk-gds-pay.eff-doc-qnty) + (if (temp-chk-gds.num-lines = 1
                                              and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                              and pychk_pays_count = 1)
                                              or (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt) = 0
                                              then temp-chk-gds.doc-qnty
                                              else (vSum / (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt))
                                              )
              .
            end.
        end.
      end.
    end.
    if available temp-chk-gds then release temp-chk-gds.
    if available temp-chk-pay then release temp-chk-pay.
    pychk_zero-gds = 0.
    pychk_zero-pay = 0.
    for each temp-chk-gds where
            temp-chk-gds.doc-code = ub.chk-pay.doc-code
        and temp-chk-gds.flag = no
        and temp-chk-gds.line-num  > 0
        :
       pychk_zero-gds = pychk_zero-gds + 1.
    end.
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-pay.doc-code
        and temp-chk-pay.flag = no:
       pychk_zero-pay = pychk_zero-pay + 1.
    end.
    find first temp-chk-pay where temp-chk-pay.doc-code = ub.chk-pay.doc-code
                              and temp-chk-pay.flag = no
    no-lock no-error.
    if not available temp-chk-pay
    then do:
       block-pay:
       for each temp-chk-pay where temp-chk-pay.doc-code = ub.chk-pay.doc-code:
          assign
             pychk_zero-pay = pychk_zero-pay +  1
             temp-chk-pay.flag = no
          .
          leave block-pay.
       end.
    end.
    for each temp-chk-pay
    where   temp-chk-pay.doc-code = ub.chk-pay.doc-code
        and temp-chk-pay.flag = no:
      pychk_zero-n = 0.
      for each buf_temp-chk-gds
      where   buf_temp-chk-gds.doc-code = ub.chk-pay.doc-code
          and buf_temp-chk-gds.flag = no
          and buf_temp-chk-gds.line-num  > 0 :
        pychk_zero-n = pychk_zero-n + 1.
        if  temp-chk-pay.tot-r-b = 0 and buf_temp-chk-gds.discnt = 0 and abs(buf_temp-chk-gds.sum) > 0 then next.
        case num-entries(buf_temp-chk-gds.line-type, chr(4)):
          when 1 then do:
            pychk_line-type-chr = buf_temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
          end.
          when 2 then do:
            pychk_line-type-chr = buf_temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
          end.
        end case.
        if can-find(first buf_chk-gds-pay no-lock where
                          buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                      and buf_chk-gds-pay.algo-num = "1.8"
                      and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                      and buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num)
        then do:
            buf_temp-chk-gds.flag = yes.
        end.
        else do:
            create buf_chk-gds-pay.
            assign
            buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
            buf_chk-gds-pay.algo-num = "1.8"
            buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
            buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
            buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
            buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
            buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
            buf_chk-gds-pay.tot-r-b = 0
            buf_chk-gds-pay.eff-base-rate = pychk_exch
            buf_chk-gds-pay.eff-doc-qnty = buf_temp-chk-gds.doc-qnty
            buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
            buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
            buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
            buf_chk-gds-pay.price-base = (if temp-chk-pay.tot-r-b = 0 and buf_temp-chk-gds.discnt = 0 then 0 else buf_temp-chk-gds.price-base)
            buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
            buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
            buf_chk-gds-pay.line-type = pychk_line-type-chr
            buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
            buf_chk-gds-pay.density  = buf_temp-chk-gds.density
            buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
            buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
            buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
            buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
            buf_chk-gds-pay.out-code = ub.chk-doc.out-code
            buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
            buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
            buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
            buf_temp-chk-gds.flag = yes
            .
        end.
        if pychk_zero-n > pychk_zero-gds / pychk_zero-pay then leave.
      end.
      temp-chk-pay.flag = yes.
    end.
  end.
end.
end.
    end.
  end.
  when "r-date" then do:
    _chk-doc:
    FOR EACH ub.chk-doc No-LOCK WHERE
            ub.chk-doc.obj-type = p-obj-type
        AND ub.chk-doc.obj-code = p-obj-code
        AND ub.chk-doc.chk-date >= p-shift-date-start
        AND ub.chk-doc.chk-date <= p-shift-date-end
        and ub.chk-doc.out-code <> ?,
      EACH ub.chk-pay NO-LOCK WHERE
              ub.chk-pay.doc-code = ub.chk-doc.doc-code
      BREAK
      BY ub.CHK-pay.doc-code
      BY ub.CHK-pay.line-num:
      if lookup(string(ub.chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next _chk-doc.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first-of(ub.CHK-pay.DOC-CODE) THEN Do:
  pychk_create = not can-find (first buf_chk-gds-pay
                               where buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code
                                 and buf_chk-gds-pay.algo-num = "1.8") .
  if pychk_create then do:
    for each temp-chk-pay:
      delete temp-chk-pay.
    end.
    for each temp-chk-gds:
      delete temp-chk-gds.
    end.
    for each temp-chk-dp:
      delete temp-chk-dp.
    end.
    assign
    pychk_kk = 0
    pychk_jj = 1
    pychk_jjp = 0
    pychk_jjo = 0
    pychk_pay-sum = ub.chk-doc.netto
    pychk_dop-sumg = 0
    pychk_pays_count = 0
    .
  end .
end.
if pychk_create   then do:
create-block:
do transaction
on stop   undo create-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo create-block, return error substitute( "&1. endkey", vss-workfile )
on error  undo, throw:
  find first buf2_chk-doc exclusive-lock where
         recid(buf2_chk-doc) = recid(ub.chk-doc).
  if first-of(ub.CHK-pay.DOC-CODE) THEN Do:
    FOR EACH ub.chk-gds No-LOCK WHERE
            ub.chk-gds.doc-code = ub.chk-pay.doc-code
    BY ub.chk-gds.line-num:
      if   ub.chk-gds.write-off-code > 0
        or ub.chk-gds.doc-qnty  eq 0
        or ub.chk-gds.doc-qnty  eq ?
      then NEXT.
      find first buf_bar-code no-lock where
                buf_bar-code.b-code = ub.chk-gds.b-code no-error.
      if not available buf_bar-code then do:
        undo create-block, return error substitute("Не найден товар для бар-кода &1: чек &2 &3&4 строка &5"
                                                    , ub.chk-gds.b-code
                                                    , ub.chk-gds.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , ub.chk-gds.line-num).
      end.
      if ub.chk-gds.pump <> 0 then do:
        pychk_rec-type = 1.
        find first temp-ptrl-goods where
                   temp-ptrl-goods.b-code = ub.chk-gds.b-code no-error.
        if not available temp-ptrl-goods then do:
          run gds-attr-value in this-procedure (
                                                 input buf_bar-code.gds-code
                                                ,input 'ptrl-as-good':U
                                                ,output pychk_value
                                                ,output pychk_type) no-error.
          create temp-ptrl-goods.
          assign
          temp-ptrl-goods.gds-code = buf_bar-code.gds-code
          temp-ptrl-goods.b-code = buf_bar-code.b-code
          temp-ptrl-goods.ptrl-good = (not logical(pychk_value))
          no-error.
        end.
        pychk_line-type = if temp-ptrl-goods.ptrl-good then 1 else 0 .
        release temp-ptrl-goods.
      end.
      else do:
        assign
        pychk_rec-type = 0
        pychk_line-type = 0
        .
      end.
      find first temp-chk-gds where
                temp-chk-gds.doc-code = ub.chk-gds.doc-code
            AND temp-chk-gds.rec-type = pychk_rec-type
            and temp-chk-gds.b-code = ub.chk-gds.b-code
            and temp-chk-gds.line-num = 0
            no-error.
      if not available temp-chk-gds then do:
        find first temp-chk-gds use-index ijj where
                temp-chk-gds.jj_ = pychk_jj
            and temp-chk-gds.line-num = 0
                no-error.
        if not available temp-chk-gds then do:
          create temp-chk-gds.
          assign
          temp-chk-gds.jj_ = pychk_jj
          temp-chk-gds.b-code = ub.chk-gds.b-code
          temp-chk-gds.doc-code = ub.chk-gds.doc-code
          temp-chk-gds.line-num = 0
          temp-chk-gds.rec-type = pychk_rec-type
          temp-chk-gds.gds-code = buf_bar-code.gds-code.
          .
        end.
        else do:
          assign
          temp-chk-gds.b-code = ub.chk-gds.b-code
          temp-chk-gds.doc-code = ub.chk-gds.doc-code
          temp-chk-gds.line-num = 0
          temp-chk-gds.rec-type = pychk_rec-type
          temp-chk-gds.sum = 0
          temp-chk-gds.jjp_ = 0
          temp-chk-gds.jjo_ = 0
          temp-chk-gds.line-type = '':U
          temp-chk-gds.num-lines = 0
          temp-chk-gds.doc-qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.flag  = no
          .
        end.
        assign
        temp-chk-gds.line-type = (if pychk_line-type = 1
                                then 'топ':U
                                else entry(1, ub.chk-gds.line-type, chr(4))
                                ) + chr(4) +
                                (if num-entries(ub.chk-gds.line-type, chr(4)) > 1
                                then entry(2, ub.chk-gds.line-type, chr(4))
                                else '')
        temp-chk-gds.line-num = 0
        temp-chk-gds.num-lines = 0
        temp-chk-gds.density   = ub.chk-gds.density
        pychk_jj = pychk_jj + 1
        .
        if pychk_rec-type = 1 then do:
          assign
          temp-chk-gds.jjp_ = pychk_jjp + 1
          pychk_jjp = pychk_jjp + 1
          .
        end.
        else do:
          assign
          temp-chk-gds.jjo_ = pychk_jjo + 1
          pychk_jjo = pychk_jjo + 1
          .
        end.
      end.
      vSumRound = ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt).
      if ChkPromoPrice(ub.chk-gds.doc-code, ub.chk-gds.line-num) then vSumRound = ub.chk-gds.src-sum.
      assign
      temp-chk-gds.doc-qnty = temp-chk-gds.doc-qnty + ub.chk-gds.doc-qnty
      temp-chk-gds.sum = temp-chk-gds.sum + vSumRound
      temp-chk-gds.num-lines = temp-chk-gds.num-lines  + 1
      .
      find first temp-chk-gds use-index ijj where
              temp-chk-gds.jj_ = 0
          and temp-chk-gds.line-num = ub.chk-gds.line-num
              no-error.
      if not available temp-chk-gds then do:
        create temp-chk-gds.
        assign
        temp-chk-gds.jj_ = 0
        temp-chk-gds.line-num = ub.chk-gds.line-num
        temp-chk-gds.doc-code = ub.chk-gds.doc-code
        temp-chk-gds.b-code = ub.chk-gds.b-code
        temp-chk-gds.gds-code = buf_bar-code.gds-code
        temp-chk-gds.rec-type = pychk_rec-type
        temp-chk-gds.line-num = ub.chk-gds.line-num
        .
      end.
      else do:
        assign
        temp-chk-gds.doc-qnty = 0
        temp-chk-gds.doc-code = ub.chk-gds.doc-code
        temp-chk-gds.b-code = ub.chk-gds.b-code
        temp-chk-gds.gds-code = buf_bar-code.gds-code
        temp-chk-gds.rec-type = pychk_rec-type
        temp-chk-gds.line-num = ub.chk-gds.line-num
        temp-chk-gds.jjp_ = 0
        temp-chk-gds.jjo_ = 0
        temp-chk-gds.line-type = '':U
                .
      end.
      assign
      temp-chk-gds.doc-code = ub.chk-gds.doc-code
      temp-chk-gds.b-code = ub.chk-gds.b-code
      temp-chk-gds.doc-qnty = ub.chk-gds.doc-qnty
      temp-chk-gds.price-base = ub.chk-gds.price-base
      temp-chk-gds.price-service = ub.chk-gds.price-service
      temp-chk-gds.line-type = (if pychk_line-type = 1
                              then 'топ':U
                              else entry(1, ub.chk-gds.line-type, chr(4))
                              ) + chr(4) +
                              (if num-entries(ub.chk-gds.line-type, chr(4)) > 1
                              then entry(2, ub.chk-gds.line-type, chr(4))
                              else '')
      temp-chk-gds.line-sign = ub.chk-gds.line-sign
      temp-chk-gds.discnt = ub.chk-gds.discnt
      temp-chk-gds.sum = vSumRound
      temp-chk-gds.rec-type = pychk_rec-type
      temp-chk-gds.line-num = ub.chk-gds.line-num
      temp-chk-gds.num-lines = 1
      temp-chk-gds.density   = ub.chk-gds.density
      .
    END.
    for each chk-discnt no-lock
       where chk-discnt.doc-code = ub.chk-doc.doc-code
         and record-type = 10
         and chk-discnt.discnt-value-abs <> 0,
        first ub.chk-gds of ub.chk-doc where ub.chk-gds.line-num =  chk-discnt.object-line-num :
            if ub.chk-doc.chk-type = 1 and chk-discnt.object-qnty < 0 then do:
                for first temp-chk-dp where temp-chk-dp.doc-code = ub.chk-doc.doc-code
                and temp-chk-dp.b-code = chk-gds.b-code:
                    temp-chk-dp.sum = temp-chk-dp.sum - abs(chk-discnt.discnt-value-abs * chk-discnt.object-qnty).
                end.
            end.
            else do:
                create temp-chk-dp .
                assign
                temp-chk-dp.doc-code = ub.chk-doc.doc-code
                temp-chk-dp.sum = abs(chk-discnt.discnt-value-abs) * chk-discnt.object-qnty
                temp-chk-dp.line-num = chk-discnt.object-line-num
                temp-chk-dp.pay-code = chk-discnt.rank
                temp-chk-dp.b-code = chk-gds.b-code
                temp-chk-dp.qnty   = abs(chk-discnt.discnt-value-pcnt)
                temp-chk-dp.all-sum =  chk-discnt.discnt-value-abs * chk-discnt.discnt-value-pcnt
                .
            end.
    end.
  end.
  FIND FIRST ub.cash-pay No-LOCK WHERE
            ub.cash-pay.cdpay-code = ub.chk-pay.pay-code AND
            ub.cash-pay.curr-code = ub.chk-pay.curr-code No-ERROR.
  if available ub.cash-pay then do:
    pychk_payline_rrn = "" .
    if not ub.cash-pay.is-cash then do :
      for first buf_chk-pay-attr no-lock
          where buf_chk-pay-attr.doc-code  = ub.CHK-pay.DOC-CODE
            and buf_chk-pay-attr.attr-code = "cpdoc":U
            and buf_chk-pay-attr.line-num  = ub.CHK-pay.line-num :
        pychk_payline_rrn = buf_chk-pay-attr.attr-value .
      end .
    end .
      find first temp-chk-pay where
              temp-chk-pay.doc-code = ub.chk-pay.doc-code
          and temp-chk-pay.pay-code = ub.chk-pay.pay-code
          and temp-chk-pay.pay-card = ub.chk-pay.pay-card
          and temp-chk-pay.curr-code = ub.chk-pay.curr-code
          and temp-chk-pay.rrn       = pychk_payline_rrn
                 no-error.
    if not available temp-chk-pay then do:
        find first temp-chk-pay where
                temp-chk-pay.doc-code = ub.chk-pay.doc-code
            and temp-chk-pay.pay-code = ub.chk-pay.pay-code
            and temp-chk-pay.pay-card = ub.chk-pay.pay-card
            and temp-chk-pay.curr-code = ub.chk-pay.curr-code
            and abs(temp-chk-pay.tot-r-b) >= abs(ub.chk-pay.tot-sum)
            and (temp-chk-pay.tot-r-b >=0) NE (ub.chk-pay.tot-sum >=0)
            no-error.
      if not  avail temp-chk-pay then do:
        find first temp-chk-pay where
                  temp-chk-pay.doc-code = ub.chk-pay.doc-code
              and temp-chk-pay.line-num = ub.chk-pay.line-num use-index pi no-error.
        if not available temp-chk-pay then do:
          create temp-chk-pay.
          assign
          temp-chk-pay.line-num = ub.chk-pay.line-num
          temp-chk-pay.doc-code = ub.chk-doc.doc-code
          temp-chk-pay.pay-code = ub.chk-pay.pay-code
          temp-chk-pay.curr-code =  ub.chk-pay.curr-code
          temp-chk-pay.rrn       = pychk_payline_rrn
          pychk_pays_count = pychk_pays_count + 1
          .
        end.
        assign
        temp-chk-pay.doc-code = ub.chk-doc.doc-code
        temp-chk-pay.pet-good = integer(cash-pay.atr64) * 2 + integer(cash-pay.is-cash) + 2 * int(can-find(first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code ))
        temp-chk-pay.pay-code = ub.chk-pay.pay-code
        temp-chk-pay.curr-code =  ub.chk-pay.curr-code
        temp-chk-pay.is-cash  = ub.cash-pay.is-cash
        temp-chk-pay.register = ub.cash-pay.register
        temp-chk-pay.pay-card = ub.chk-pay.pay-card
        temp-chk-pay.tot-rubl = 0
        temp-chk-pay.tot-base = 0
        temp-chk-pay.num-lines = 0
        temp-chk-pay.flag  = no
        .
      end.
    end.
    assign
    temp-chk-pay.tot-r-b = temp-chk-pay.tot-r-b + (if v-curr-r-b = 'rubl':U
                                                   then ub.chk-pay.tot-rubl
                                                   else ub.chk-pay.tot-base)
    temp-chk-pay.tot-rubl = temp-chk-pay.tot-rubl + ub.chk-pay.tot-rubl
    temp-chk-pay.tot-base = temp-chk-pay.tot-base + ub.chk-pay.tot-base
    temp-chk-pay.num-lines = temp-chk-pay.num-lines  + 1
    .
  end.
  if available temp-chk-pay then RELEASE TEMP-CHK-PAY.
  if last-of(ub.chk-pay.doc-code) then do:
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-doc.doc-code:
       if    (temp-chk-pay.tot-r-b  >= 0) NE (ub.chk-doc.netto >= 0)
          and temp-chk-pay.tot-r-b <> 0
          and abs(ub.chk-doc.netto) > 0.00000001
       then do:
          if not g#auto then do:
             message
                substitute("Не могу обработать чек &1&2&3&4 смена &5 пор.&6 касса &7 № на кассе &8"
                          ,ub.chk-doc.doc-code
                          ,chr(10)
                          ,ub.chk-doc.obj-type
                          ,ub.chk-doc.obj-code
                          ,ub.chk-doc.shift-date
                          ,ub.chk-doc.shift-num
                          ,ub.chk-doc.pay-desk
                          ,ub.chk-doc.chk-num)
                view-as alert-box error .
          end.
          next _chk-doc.
       end.
    end.
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-doc.doc-code
    break
    by temp-chk-pay.pet-good descending
    by temp-chk-pay.line-num:
       dp:
       for each temp-chk-dp no-lock
          where temp-chk-dp.pay-code = temp-chk-pay.pay-code
            and temp-chk-dp.doc-code = temp-chk-pay.doc-code
            and temp-chk-dp.sum <> 0 :
            find first buf_temp-chk-gds2 where
                buf_temp-chk-gds2.doc-code = ub.chk-doc.doc-code
            and buf_temp-chk-gds2.line-num  =  temp-chk-dp.line-num no-error.
            if available buf_temp-chk-gds2 then
            for each buf_temp-chk-gds where
                buf_temp-chk-gds.b-code = buf_temp-chk-gds2.b-code
                and buf_temp-chk-gds.line-num ne 0
            no-lock by buf_temp-chk-gds.line-num  ne  temp-chk-dp.line-num :
                 if         temp-chk-dp.all-sum  eq ?
                    or abs(temp-chk-dp.all-sum) <= 0.001
                then
                   next dp.
                find first  temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                    and buf_temp-chk-gds.b-code = temp-chk-gds.b-code
                  and temp-chk-gds.line-num = 0
                no-error .
                if not available temp-chk-gds then next dp.
                case num-entries(buf_temp-chk-gds.line-type, chr(4)):
                    when 1 then do:
                      pychk_line-type-chr = temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
                    end.
                    when 2 then do:
                      pychk_line-type-chr = temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
                    end.
                end case.
                pychk_dop-sumk =  if temp-chk-dp.sum >= 0
                then min(temp-chk-dp.all-sum,temp-chk-dp.sum,buf_temp-chk-gds.sum,temp-chk-pay.tot-r-b)
                else max(temp-chk-dp.all-sum,temp-chk-dp.sum,buf_temp-chk-gds.sum).
                if abs(temp-chk-pay.tot-r-b - pychk_dop-sumk) <= 0.001
                then
                   pychk_dop-sumk = temp-chk-pay.tot-r-b.
                temp-chk-dp.all-sum           = temp-chk-dp.all-sum - pychk_dop-sumk.
                if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                create buf_chk-gds-pay.
                  assign
                  buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                  buf_chk-gds-pay.chk-type = ub.chk-doc.chk-type
                  buf_chk-gds-pay.algo-num = "1.8"
                  buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
                  buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
                  buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                  buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                  buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
                  buf_chk-gds-pay.tot-r-b =  pychk_dop-sumk
                  buf_chk-gds-pay.eff-base-rate = 1
                  buf_chk-gds-pay.eff-doc-qnty = (if (temp-chk-gds.num-lines = 1
                                                  and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                                  and pychk_pays_count = 1)
                                                  or (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt) = 0
                                                  then temp-chk-gds.doc-qnty
                                                  else (buf_chk-gds-pay.tot-r-b / (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt))
                                                  )
                  buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
                  buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
                  buf_chk-gds-pay.price-base = buf_temp-chk-gds.price-base
                  buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
                  buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
                  buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
                  buf_chk-gds-pay.line-type = pychk_line-type-chr
                  buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
                  buf_chk-gds-pay.density  = buf_temp-chk-gds.density
                  buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
                  buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
                  buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
                  buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
                  buf_chk-gds-pay.out-code = ub.chk-doc.out-code
                  buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
                  buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
                  buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
                  .
                assign
                buf_temp-chk-gds.sum = buf_temp-chk-gds.sum - buf_chk-gds-pay.tot-r-b
                temp-chk-gds.sum =  temp-chk-gds.sum - buf_chk-gds-pay.tot-r-b
                buf_temp-chk-gds.doc-qnty = buf_temp-chk-gds.doc-qnty - buf_chk-gds-pay.eff-doc-qnty
                temp-chk-pay.tot-r-b = temp-chk-pay.tot-r-b - buf_chk-gds-pay.tot-r-b
                pychk_dop-sumk = pychk_dop-sumk - buf_chk-gds-pay.tot-r-b
                .
                 if (ub.chk-doc.chk-type = 1 and temp-chk-pay.tot-r-b <= 0) or (ub.chk-doc.chk-type <> 1 and temp-chk-pay.tot-r-b >= 0) then leave dp.
            end.
        end.
      assign
      pychk_dop-sump = temp-chk-pay.tot-r-b
      pychk_exch = if pychk_No-exch then 1
                   else (if temp-chk-pay.tot-base = 0
                         then 0
                         else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base)
      pychk_exch-rubl = if pychk_No-exch-rubl
                        then 1
                        else (if temp-chk-pay.tot-base = 0
                              then 0
                              else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base)
      temp-chk-pay.flag = (if abs(temp-chk-pay.tot-rubl) < 0.001 then no else yes)
      .
      _repeat:
      REPEAT WHILE  abs(pychk_dop-sump) > 0 :
        if pychk_dop-sumg = 0 then do:
          assign
          pychk_kk = pychk_kk + 1
          .
          if pychk_kk >= pychk_jj then LEAVE _repeat.
          if pychk_kk <= pychk_jjp then do:
            find first temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                  and temp-chk-gds.jjp_ = pychk_kk
                  and temp-chk-gds.line-num = 0
                no-error .
          end.
          else do:
            find first temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                  and temp-chk-gds.jjo_ = pychk_kk - pychk_jjp
                  and temp-chk-gds.line-num = 0
                no-error .
          end.
          if not available temp-chk-gds
          or (temp-chk-gds.sum = 0
              or
              (temp-chk-gds.sum <= 0  and ub.chk-doc.netto > 0)
              )
          then do:
            NEXT _repeat.
          end.
          assign
          pychk_dop-sumg = if available temp-chk-gds then temp-chk-gds.sum else 0
          temp-chk-gds.flag = yes
          .
        end.
        assign
        pychk_dop-sumk = min(abs(pychk_dop-sumg), abs(pychk_dop-sump))  * (if pychk_dop-sump > 0 then 1 else -1 ) * (if pychk_dop-sumg < 0 AND ub.chk-doc.chk-type = 1 then -1 else 1 )
        pychk_pay-sum = pychk_pay-sum - pychk_dop-sumk
        pychk_dop-sump = pychk_dop-sump - pychk_dop-sumk
        pychk_dop-sumg = pychk_dop-sumg - pychk_dop-sumk
        pychk_sum-promo = GetPromoPriceSum(ub.chk-doc.doc-code)
        .
        if pychk_sum-promo <> 0 then
           vPromoLineNum = GetPromoPriceLine(ub.chk-doc.doc-code).
        else vPromoLineNum = 0.
        for each buf_temp-chk-gds where
                buf_temp-chk-gds.doc-code = ub.chk-doc.doc-code
            and buf_temp-chk-gds.b-code = temp-chk-gds.b-code
            and buf_temp-chk-gds.line-num  > 0
        by buf_temp-chk-gds.doc-code
        by buf_temp-chk-gds.rec-type descending
        by buf_temp-chk-gds.line-num
         :
          case num-entries(buf_temp-chk-gds.line-type, chr(4)):
            when 1 then do:
              pychk_line-type-chr = buf_temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
            end.
            when 2 then do:
              pychk_line-type-chr = buf_temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
            end.
          end case.
          if  vPromoLineNum <> 0 and
              temp-chk-gds.num-lines > 1 and
              buf_temp-chk-gds.line-num = vPromoLineNum and
              can-find(first buf_chk-gds-pay no-lock where
                             buf_chk-gds-pay.doc-code = buf_temp-chk-gds.doc-code
                         and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num)
          then .
          else
          if not (buf_temp-chk-gds.sum = 0 and can-find (first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code and buf_temp-chk-gds.line-num  =  temp-chk-dp.line-num)) then do:
              if vPromoLineNum <> 0 and
                 buf_temp-chk-gds.line-num = vPromoLineNum
              then do:
                 vSum = RoundUp(buf_temp-chk-gds.doc-qnty, buf_temp-chk-gds.price-base).
              end.
              else if vPromoLineNum <> 0 and
                      temp-chk-gds.num-lines > 1 and
                      pychk_sum-promo <> 0 and
                      ChkPromoLine(buf_temp-chk-gds.doc-code, buf_temp-chk-gds.line-num)
              then do:
                  if can-find(first buf_chk-gds-pay no-lock where
                                    buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                                and buf_chk-gds-pay.line-num = vPromoLineNum
                                )
                   then vSum = (pychk_dop-sumk * buf_temp-chk-gds.sum / (temp-chk-gds.sum - pychk_sum-promo)).
                   else vSum = ((pychk_dop-sumk - pychk_sum-promo) * buf_temp-chk-gds.sum / (temp-chk-gds.sum - pychk_sum-promo)).
              end.
              else
              vSum                     = (if    temp-chk-gds.num-lines = 1
                                            and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                          then pychk_dop-sumk
                                          else (pychk_dop-sumk * buf_temp-chk-gds.sum / temp-chk-gds.sum)
                                         )
              .
              if can-find (first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code) then do:
                  find first buf_chk-gds-pay where buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                  and buf_chk-gds-pay.algo-num = "1.8"
                  and buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
                  and buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
                  and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                  and buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
                  and buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card exclusive-lock no-error.
                  if not available buf_chk-gds-pay then do:
                     if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                     then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                     create buf_chk-gds-pay.
                  end.
              end.
              else do:
                   if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                   then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                   create buf_chk-gds-pay.
              end.
              assign
              buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
              buf_chk-gds-pay.chk-type = ub.chk-doc.chk-type
              buf_chk-gds-pay.algo-num = "1.8"
              buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
              buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
              buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
              buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
              buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
              buf_chk-gds-pay.tot-r-b = buf_chk-gds-pay.tot-r-b  + vSum
              buf_chk-gds-pay.eff-base-rate = pychk_exch
              buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
              buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
              buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
              buf_chk-gds-pay.price-base = buf_temp-chk-gds.price-base
              buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
              buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
              buf_chk-gds-pay.line-type = pychk_line-type-chr
              buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
              buf_chk-gds-pay.density  = buf_temp-chk-gds.density
              buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
              buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
              buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
              buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
              buf_chk-gds-pay.out-code = ub.chk-doc.out-code
              buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
              buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
              buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
              buf_temp-chk-gds.flag = yes
              .
              if buf_temp-chk-gds.line-num = vPromoLineNum
              then do:
                 buf_chk-gds-pay.eff-doc-qnty = buf_temp-chk-gds.doc-qnty.
              end.
              else
              buf_chk-gds-pay.eff-doc-qnty = (if buf_chk-gds-pay.eff-doc-qnty = ? then 0 else buf_chk-gds-pay.eff-doc-qnty) + (if (temp-chk-gds.num-lines = 1
                                              and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                              and pychk_pays_count = 1)
                                              or (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt) = 0
                                              then temp-chk-gds.doc-qnty
                                              else (vSum / (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt))
                                              )
              .
            end.
        end.
      end.
    end.
    if available temp-chk-gds then release temp-chk-gds.
    if available temp-chk-pay then release temp-chk-pay.
    pychk_zero-gds = 0.
    pychk_zero-pay = 0.
    for each temp-chk-gds where
            temp-chk-gds.doc-code = ub.chk-pay.doc-code
        and temp-chk-gds.flag = no
        and temp-chk-gds.line-num  > 0
        :
       pychk_zero-gds = pychk_zero-gds + 1.
    end.
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-pay.doc-code
        and temp-chk-pay.flag = no:
       pychk_zero-pay = pychk_zero-pay + 1.
    end.
    find first temp-chk-pay where temp-chk-pay.doc-code = ub.chk-pay.doc-code
                              and temp-chk-pay.flag = no
    no-lock no-error.
    if not available temp-chk-pay
    then do:
       block-pay:
       for each temp-chk-pay where temp-chk-pay.doc-code = ub.chk-pay.doc-code:
          assign
             pychk_zero-pay = pychk_zero-pay +  1
             temp-chk-pay.flag = no
          .
          leave block-pay.
       end.
    end.
    for each temp-chk-pay
    where   temp-chk-pay.doc-code = ub.chk-pay.doc-code
        and temp-chk-pay.flag = no:
      pychk_zero-n = 0.
      for each buf_temp-chk-gds
      where   buf_temp-chk-gds.doc-code = ub.chk-pay.doc-code
          and buf_temp-chk-gds.flag = no
          and buf_temp-chk-gds.line-num  > 0 :
        pychk_zero-n = pychk_zero-n + 1.
        if  temp-chk-pay.tot-r-b = 0 and buf_temp-chk-gds.discnt = 0 and abs(buf_temp-chk-gds.sum) > 0 then next.
        case num-entries(buf_temp-chk-gds.line-type, chr(4)):
          when 1 then do:
            pychk_line-type-chr = buf_temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
          end.
          when 2 then do:
            pychk_line-type-chr = buf_temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
          end.
        end case.
        if can-find(first buf_chk-gds-pay no-lock where
                          buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                      and buf_chk-gds-pay.algo-num = "1.8"
                      and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                      and buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num)
        then do:
            buf_temp-chk-gds.flag = yes.
        end.
        else do:
            create buf_chk-gds-pay.
            assign
            buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
            buf_chk-gds-pay.algo-num = "1.8"
            buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
            buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
            buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
            buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
            buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
            buf_chk-gds-pay.tot-r-b = 0
            buf_chk-gds-pay.eff-base-rate = pychk_exch
            buf_chk-gds-pay.eff-doc-qnty = buf_temp-chk-gds.doc-qnty
            buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
            buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
            buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
            buf_chk-gds-pay.price-base = (if temp-chk-pay.tot-r-b = 0 and buf_temp-chk-gds.discnt = 0 then 0 else buf_temp-chk-gds.price-base)
            buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
            buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
            buf_chk-gds-pay.line-type = pychk_line-type-chr
            buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
            buf_chk-gds-pay.density  = buf_temp-chk-gds.density
            buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
            buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
            buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
            buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
            buf_chk-gds-pay.out-code = ub.chk-doc.out-code
            buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
            buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
            buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
            buf_temp-chk-gds.flag = yes
            .
        end.
        if pychk_zero-n > pychk_zero-gds / pychk_zero-pay then leave.
      end.
      temp-chk-pay.flag = yes.
    end.
  end.
end.
end.
    end.
  end.
  when "r-ptrsp2" then do:
    _chk-doc:
    for each ub.chk-doc no-lock where
             ub.chk-doc.obj-type    = p-obj-type
         and ub.chk-doc.obj-code    = p-obj-code
         and ub.chk-doc.shift-date  = p-shift-date-start
         and ub.chk-doc.shift-num   = p-shift-num-start
         and ub.chk-doc.out-code   <> ? ,
    EACH ub.chk-pay NO-LOCK WHERE
            ub.chk-pay.doc-code = ub.chk-doc.doc-code
    BREAK
    BY ub.CHK-pay.doc-code
    BY ub.CHK-pay.line-num:
      if lookup( string( ub.chk-doc.chk-type ), '14,15,16,36,8,101,106,108,11,12,13,40,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U ) > 0
      then do:
        next _chk-doc .
      end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first-of(ub.CHK-pay.DOC-CODE) THEN Do:
  pychk_create = not can-find (first buf_chk-gds-pay
                               where buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code
                                 and buf_chk-gds-pay.algo-num = "1.8") .
  if pychk_create then do:
    for each temp-chk-pay:
      delete temp-chk-pay.
    end.
    for each temp-chk-gds:
      delete temp-chk-gds.
    end.
    for each temp-chk-dp:
      delete temp-chk-dp.
    end.
    assign
    pychk_kk = 0
    pychk_jj = 1
    pychk_jjp = 0
    pychk_jjo = 0
    pychk_pay-sum = ub.chk-doc.netto
    pychk_dop-sumg = 0
    pychk_pays_count = 0
    .
  end .
end.
if pychk_create   then do:
create-block:
do transaction
on stop   undo create-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo create-block, return error substitute( "&1. endkey", vss-workfile )
on error  undo, throw:
  find first buf2_chk-doc exclusive-lock where
         recid(buf2_chk-doc) = recid(ub.chk-doc).
  if first-of(ub.CHK-pay.DOC-CODE) THEN Do:
    FOR EACH ub.chk-gds No-LOCK WHERE
            ub.chk-gds.doc-code = ub.chk-pay.doc-code
    BY ub.chk-gds.line-num:
      if   ub.chk-gds.write-off-code > 0
        or ub.chk-gds.doc-qnty  eq 0
        or ub.chk-gds.doc-qnty  eq ?
      then NEXT.
      find first buf_bar-code no-lock where
                buf_bar-code.b-code = ub.chk-gds.b-code no-error.
      if not available buf_bar-code then do:
        undo create-block, return error substitute("Не найден товар для бар-кода &1: чек &2 &3&4 строка &5"
                                                    , ub.chk-gds.b-code
                                                    , ub.chk-gds.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , ub.chk-gds.line-num).
      end.
      if ub.chk-gds.pump <> 0 then do:
        pychk_rec-type = 1.
        find first temp-ptrl-goods where
                   temp-ptrl-goods.b-code = ub.chk-gds.b-code no-error.
        if not available temp-ptrl-goods then do:
          run gds-attr-value in this-procedure (
                                                 input buf_bar-code.gds-code
                                                ,input 'ptrl-as-good':U
                                                ,output pychk_value
                                                ,output pychk_type) no-error.
          create temp-ptrl-goods.
          assign
          temp-ptrl-goods.gds-code = buf_bar-code.gds-code
          temp-ptrl-goods.b-code = buf_bar-code.b-code
          temp-ptrl-goods.ptrl-good = (not logical(pychk_value))
          no-error.
        end.
        pychk_line-type = if temp-ptrl-goods.ptrl-good then 1 else 0 .
        release temp-ptrl-goods.
      end.
      else do:
        assign
        pychk_rec-type = 0
        pychk_line-type = 0
        .
      end.
      find first temp-chk-gds where
                temp-chk-gds.doc-code = ub.chk-gds.doc-code
            AND temp-chk-gds.rec-type = pychk_rec-type
            and temp-chk-gds.b-code = ub.chk-gds.b-code
            and temp-chk-gds.line-num = 0
            no-error.
      if not available temp-chk-gds then do:
        find first temp-chk-gds use-index ijj where
                temp-chk-gds.jj_ = pychk_jj
            and temp-chk-gds.line-num = 0
                no-error.
        if not available temp-chk-gds then do:
          create temp-chk-gds.
          assign
          temp-chk-gds.jj_ = pychk_jj
          temp-chk-gds.b-code = ub.chk-gds.b-code
          temp-chk-gds.doc-code = ub.chk-gds.doc-code
          temp-chk-gds.line-num = 0
          temp-chk-gds.rec-type = pychk_rec-type
          temp-chk-gds.gds-code = buf_bar-code.gds-code.
          .
        end.
        else do:
          assign
          temp-chk-gds.b-code = ub.chk-gds.b-code
          temp-chk-gds.doc-code = ub.chk-gds.doc-code
          temp-chk-gds.line-num = 0
          temp-chk-gds.rec-type = pychk_rec-type
          temp-chk-gds.sum = 0
          temp-chk-gds.jjp_ = 0
          temp-chk-gds.jjo_ = 0
          temp-chk-gds.line-type = '':U
          temp-chk-gds.num-lines = 0
          temp-chk-gds.doc-qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.flag  = no
          .
        end.
        assign
        temp-chk-gds.line-type = (if pychk_line-type = 1
                                then 'топ':U
                                else entry(1, ub.chk-gds.line-type, chr(4))
                                ) + chr(4) +
                                (if num-entries(ub.chk-gds.line-type, chr(4)) > 1
                                then entry(2, ub.chk-gds.line-type, chr(4))
                                else '')
        temp-chk-gds.line-num = 0
        temp-chk-gds.num-lines = 0
        temp-chk-gds.density   = ub.chk-gds.density
        pychk_jj = pychk_jj + 1
        .
        if pychk_rec-type = 1 then do:
          assign
          temp-chk-gds.jjp_ = pychk_jjp + 1
          pychk_jjp = pychk_jjp + 1
          .
        end.
        else do:
          assign
          temp-chk-gds.jjo_ = pychk_jjo + 1
          pychk_jjo = pychk_jjo + 1
          .
        end.
      end.
      vSumRound = ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt).
      if ChkPromoPrice(ub.chk-gds.doc-code, ub.chk-gds.line-num) then vSumRound = ub.chk-gds.src-sum.
      assign
      temp-chk-gds.doc-qnty = temp-chk-gds.doc-qnty + ub.chk-gds.doc-qnty
      temp-chk-gds.sum = temp-chk-gds.sum + vSumRound
      temp-chk-gds.num-lines = temp-chk-gds.num-lines  + 1
      .
      find first temp-chk-gds use-index ijj where
              temp-chk-gds.jj_ = 0
          and temp-chk-gds.line-num = ub.chk-gds.line-num
              no-error.
      if not available temp-chk-gds then do:
        create temp-chk-gds.
        assign
        temp-chk-gds.jj_ = 0
        temp-chk-gds.line-num = ub.chk-gds.line-num
        temp-chk-gds.doc-code = ub.chk-gds.doc-code
        temp-chk-gds.b-code = ub.chk-gds.b-code
        temp-chk-gds.gds-code = buf_bar-code.gds-code
        temp-chk-gds.rec-type = pychk_rec-type
        temp-chk-gds.line-num = ub.chk-gds.line-num
        .
      end.
      else do:
        assign
        temp-chk-gds.doc-qnty = 0
        temp-chk-gds.doc-code = ub.chk-gds.doc-code
        temp-chk-gds.b-code = ub.chk-gds.b-code
        temp-chk-gds.gds-code = buf_bar-code.gds-code
        temp-chk-gds.rec-type = pychk_rec-type
        temp-chk-gds.line-num = ub.chk-gds.line-num
        temp-chk-gds.jjp_ = 0
        temp-chk-gds.jjo_ = 0
        temp-chk-gds.line-type = '':U
                .
      end.
      assign
      temp-chk-gds.doc-code = ub.chk-gds.doc-code
      temp-chk-gds.b-code = ub.chk-gds.b-code
      temp-chk-gds.doc-qnty = ub.chk-gds.doc-qnty
      temp-chk-gds.price-base = ub.chk-gds.price-base
      temp-chk-gds.price-service = ub.chk-gds.price-service
      temp-chk-gds.line-type = (if pychk_line-type = 1
                              then 'топ':U
                              else entry(1, ub.chk-gds.line-type, chr(4))
                              ) + chr(4) +
                              (if num-entries(ub.chk-gds.line-type, chr(4)) > 1
                              then entry(2, ub.chk-gds.line-type, chr(4))
                              else '')
      temp-chk-gds.line-sign = ub.chk-gds.line-sign
      temp-chk-gds.discnt = ub.chk-gds.discnt
      temp-chk-gds.sum = vSumRound
      temp-chk-gds.rec-type = pychk_rec-type
      temp-chk-gds.line-num = ub.chk-gds.line-num
      temp-chk-gds.num-lines = 1
      temp-chk-gds.density   = ub.chk-gds.density
      .
    END.
    for each chk-discnt no-lock
       where chk-discnt.doc-code = ub.chk-doc.doc-code
         and record-type = 10
         and chk-discnt.discnt-value-abs <> 0,
        first ub.chk-gds of ub.chk-doc where ub.chk-gds.line-num =  chk-discnt.object-line-num :
            if ub.chk-doc.chk-type = 1 and chk-discnt.object-qnty < 0 then do:
                for first temp-chk-dp where temp-chk-dp.doc-code = ub.chk-doc.doc-code
                and temp-chk-dp.b-code = chk-gds.b-code:
                    temp-chk-dp.sum = temp-chk-dp.sum - abs(chk-discnt.discnt-value-abs * chk-discnt.object-qnty).
                end.
            end.
            else do:
                create temp-chk-dp .
                assign
                temp-chk-dp.doc-code = ub.chk-doc.doc-code
                temp-chk-dp.sum = abs(chk-discnt.discnt-value-abs) * chk-discnt.object-qnty
                temp-chk-dp.line-num = chk-discnt.object-line-num
                temp-chk-dp.pay-code = chk-discnt.rank
                temp-chk-dp.b-code = chk-gds.b-code
                temp-chk-dp.qnty   = abs(chk-discnt.discnt-value-pcnt)
                temp-chk-dp.all-sum =  chk-discnt.discnt-value-abs * chk-discnt.discnt-value-pcnt
                .
            end.
    end.
  end.
  FIND FIRST ub.cash-pay No-LOCK WHERE
            ub.cash-pay.cdpay-code = ub.chk-pay.pay-code AND
            ub.cash-pay.curr-code = ub.chk-pay.curr-code No-ERROR.
  if available ub.cash-pay then do:
    pychk_payline_rrn = "" .
    if not ub.cash-pay.is-cash then do :
      for first buf_chk-pay-attr no-lock
          where buf_chk-pay-attr.doc-code  = ub.CHK-pay.DOC-CODE
            and buf_chk-pay-attr.attr-code = "cpdoc":U
            and buf_chk-pay-attr.line-num  = ub.CHK-pay.line-num :
        pychk_payline_rrn = buf_chk-pay-attr.attr-value .
      end .
    end .
      find first temp-chk-pay where
              temp-chk-pay.doc-code = ub.chk-pay.doc-code
          and temp-chk-pay.pay-code = ub.chk-pay.pay-code
          and temp-chk-pay.pay-card = ub.chk-pay.pay-card
          and temp-chk-pay.curr-code = ub.chk-pay.curr-code
          and temp-chk-pay.rrn       = pychk_payline_rrn
                 no-error.
    if not available temp-chk-pay then do:
        find first temp-chk-pay where
                temp-chk-pay.doc-code = ub.chk-pay.doc-code
            and temp-chk-pay.pay-code = ub.chk-pay.pay-code
            and temp-chk-pay.pay-card = ub.chk-pay.pay-card
            and temp-chk-pay.curr-code = ub.chk-pay.curr-code
            and abs(temp-chk-pay.tot-r-b) >= abs(ub.chk-pay.tot-sum)
            and (temp-chk-pay.tot-r-b >=0) NE (ub.chk-pay.tot-sum >=0)
            no-error.
      if not  avail temp-chk-pay then do:
        find first temp-chk-pay where
                  temp-chk-pay.doc-code = ub.chk-pay.doc-code
              and temp-chk-pay.line-num = ub.chk-pay.line-num use-index pi no-error.
        if not available temp-chk-pay then do:
          create temp-chk-pay.
          assign
          temp-chk-pay.line-num = ub.chk-pay.line-num
          temp-chk-pay.doc-code = ub.chk-doc.doc-code
          temp-chk-pay.pay-code = ub.chk-pay.pay-code
          temp-chk-pay.curr-code =  ub.chk-pay.curr-code
          temp-chk-pay.rrn       = pychk_payline_rrn
          pychk_pays_count = pychk_pays_count + 1
          .
        end.
        assign
        temp-chk-pay.doc-code = ub.chk-doc.doc-code
        temp-chk-pay.pet-good = integer(cash-pay.atr64) * 2 + integer(cash-pay.is-cash) + 2 * int(can-find(first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code ))
        temp-chk-pay.pay-code = ub.chk-pay.pay-code
        temp-chk-pay.curr-code =  ub.chk-pay.curr-code
        temp-chk-pay.is-cash  = ub.cash-pay.is-cash
        temp-chk-pay.register = ub.cash-pay.register
        temp-chk-pay.pay-card = ub.chk-pay.pay-card
        temp-chk-pay.tot-rubl = 0
        temp-chk-pay.tot-base = 0
        temp-chk-pay.num-lines = 0
        temp-chk-pay.flag  = no
        .
      end.
    end.
    assign
    temp-chk-pay.tot-r-b = temp-chk-pay.tot-r-b + (if v-curr-r-b = 'rubl':U
                                                   then ub.chk-pay.tot-rubl
                                                   else ub.chk-pay.tot-base)
    temp-chk-pay.tot-rubl = temp-chk-pay.tot-rubl + ub.chk-pay.tot-rubl
    temp-chk-pay.tot-base = temp-chk-pay.tot-base + ub.chk-pay.tot-base
    temp-chk-pay.num-lines = temp-chk-pay.num-lines  + 1
    .
  end.
  if available temp-chk-pay then RELEASE TEMP-CHK-PAY.
  if last-of(ub.chk-pay.doc-code) then do:
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-doc.doc-code:
       if    (temp-chk-pay.tot-r-b  >= 0) NE (ub.chk-doc.netto >= 0)
          and temp-chk-pay.tot-r-b <> 0
          and abs(ub.chk-doc.netto) > 0.00000001
       then do:
          if not g#auto then do:
             message
                substitute("Не могу обработать чек &1&2&3&4 смена &5 пор.&6 касса &7 № на кассе &8"
                          ,ub.chk-doc.doc-code
                          ,chr(10)
                          ,ub.chk-doc.obj-type
                          ,ub.chk-doc.obj-code
                          ,ub.chk-doc.shift-date
                          ,ub.chk-doc.shift-num
                          ,ub.chk-doc.pay-desk
                          ,ub.chk-doc.chk-num)
                view-as alert-box error .
          end.
          next _chk-doc.
       end.
    end.
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-doc.doc-code
    break
    by temp-chk-pay.pet-good descending
    by temp-chk-pay.line-num:
       dp:
       for each temp-chk-dp no-lock
          where temp-chk-dp.pay-code = temp-chk-pay.pay-code
            and temp-chk-dp.doc-code = temp-chk-pay.doc-code
            and temp-chk-dp.sum <> 0 :
            find first buf_temp-chk-gds2 where
                buf_temp-chk-gds2.doc-code = ub.chk-doc.doc-code
            and buf_temp-chk-gds2.line-num  =  temp-chk-dp.line-num no-error.
            if available buf_temp-chk-gds2 then
            for each buf_temp-chk-gds where
                buf_temp-chk-gds.b-code = buf_temp-chk-gds2.b-code
                and buf_temp-chk-gds.line-num ne 0
            no-lock by buf_temp-chk-gds.line-num  ne  temp-chk-dp.line-num :
                 if         temp-chk-dp.all-sum  eq ?
                    or abs(temp-chk-dp.all-sum) <= 0.001
                then
                   next dp.
                find first  temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                    and buf_temp-chk-gds.b-code = temp-chk-gds.b-code
                  and temp-chk-gds.line-num = 0
                no-error .
                if not available temp-chk-gds then next dp.
                case num-entries(buf_temp-chk-gds.line-type, chr(4)):
                    when 1 then do:
                      pychk_line-type-chr = temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
                    end.
                    when 2 then do:
                      pychk_line-type-chr = temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
                    end.
                end case.
                pychk_dop-sumk =  if temp-chk-dp.sum >= 0
                then min(temp-chk-dp.all-sum,temp-chk-dp.sum,buf_temp-chk-gds.sum,temp-chk-pay.tot-r-b)
                else max(temp-chk-dp.all-sum,temp-chk-dp.sum,buf_temp-chk-gds.sum).
                if abs(temp-chk-pay.tot-r-b - pychk_dop-sumk) <= 0.001
                then
                   pychk_dop-sumk = temp-chk-pay.tot-r-b.
                temp-chk-dp.all-sum           = temp-chk-dp.all-sum - pychk_dop-sumk.
                if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                create buf_chk-gds-pay.
                  assign
                  buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                  buf_chk-gds-pay.chk-type = ub.chk-doc.chk-type
                  buf_chk-gds-pay.algo-num = "1.8"
                  buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
                  buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
                  buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                  buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                  buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
                  buf_chk-gds-pay.tot-r-b =  pychk_dop-sumk
                  buf_chk-gds-pay.eff-base-rate = 1
                  buf_chk-gds-pay.eff-doc-qnty = (if (temp-chk-gds.num-lines = 1
                                                  and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                                  and pychk_pays_count = 1)
                                                  or (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt) = 0
                                                  then temp-chk-gds.doc-qnty
                                                  else (buf_chk-gds-pay.tot-r-b / (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt))
                                                  )
                  buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
                  buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
                  buf_chk-gds-pay.price-base = buf_temp-chk-gds.price-base
                  buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
                  buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
                  buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
                  buf_chk-gds-pay.line-type = pychk_line-type-chr
                  buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
                  buf_chk-gds-pay.density  = buf_temp-chk-gds.density
                  buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
                  buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
                  buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
                  buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
                  buf_chk-gds-pay.out-code = ub.chk-doc.out-code
                  buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
                  buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
                  buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
                  .
                assign
                buf_temp-chk-gds.sum = buf_temp-chk-gds.sum - buf_chk-gds-pay.tot-r-b
                temp-chk-gds.sum =  temp-chk-gds.sum - buf_chk-gds-pay.tot-r-b
                buf_temp-chk-gds.doc-qnty = buf_temp-chk-gds.doc-qnty - buf_chk-gds-pay.eff-doc-qnty
                temp-chk-pay.tot-r-b = temp-chk-pay.tot-r-b - buf_chk-gds-pay.tot-r-b
                pychk_dop-sumk = pychk_dop-sumk - buf_chk-gds-pay.tot-r-b
                .
                 if (ub.chk-doc.chk-type = 1 and temp-chk-pay.tot-r-b <= 0) or (ub.chk-doc.chk-type <> 1 and temp-chk-pay.tot-r-b >= 0) then leave dp.
            end.
        end.
      assign
      pychk_dop-sump = temp-chk-pay.tot-r-b
      pychk_exch = if pychk_No-exch then 1
                   else (if temp-chk-pay.tot-base = 0
                         then 0
                         else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base)
      pychk_exch-rubl = if pychk_No-exch-rubl
                        then 1
                        else (if temp-chk-pay.tot-base = 0
                              then 0
                              else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base)
      temp-chk-pay.flag = (if abs(temp-chk-pay.tot-rubl) < 0.001 then no else yes)
      .
      _repeat:
      REPEAT WHILE  abs(pychk_dop-sump) > 0 :
        if pychk_dop-sumg = 0 then do:
          assign
          pychk_kk = pychk_kk + 1
          .
          if pychk_kk >= pychk_jj then LEAVE _repeat.
          if pychk_kk <= pychk_jjp then do:
            find first temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                  and temp-chk-gds.jjp_ = pychk_kk
                  and temp-chk-gds.line-num = 0
                no-error .
          end.
          else do:
            find first temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                  and temp-chk-gds.jjo_ = pychk_kk - pychk_jjp
                  and temp-chk-gds.line-num = 0
                no-error .
          end.
          if not available temp-chk-gds
          or (temp-chk-gds.sum = 0
              or
              (temp-chk-gds.sum <= 0  and ub.chk-doc.netto > 0)
              )
          then do:
            NEXT _repeat.
          end.
          assign
          pychk_dop-sumg = if available temp-chk-gds then temp-chk-gds.sum else 0
          temp-chk-gds.flag = yes
          .
        end.
        assign
        pychk_dop-sumk = min(abs(pychk_dop-sumg), abs(pychk_dop-sump))  * (if pychk_dop-sump > 0 then 1 else -1 ) * (if pychk_dop-sumg < 0 AND ub.chk-doc.chk-type = 1 then -1 else 1 )
        pychk_pay-sum = pychk_pay-sum - pychk_dop-sumk
        pychk_dop-sump = pychk_dop-sump - pychk_dop-sumk
        pychk_dop-sumg = pychk_dop-sumg - pychk_dop-sumk
        pychk_sum-promo = GetPromoPriceSum(ub.chk-doc.doc-code)
        .
        if pychk_sum-promo <> 0 then
           vPromoLineNum = GetPromoPriceLine(ub.chk-doc.doc-code).
        else vPromoLineNum = 0.
        for each buf_temp-chk-gds where
                buf_temp-chk-gds.doc-code = ub.chk-doc.doc-code
            and buf_temp-chk-gds.b-code = temp-chk-gds.b-code
            and buf_temp-chk-gds.line-num  > 0
        by buf_temp-chk-gds.doc-code
        by buf_temp-chk-gds.rec-type descending
        by buf_temp-chk-gds.line-num
         :
          case num-entries(buf_temp-chk-gds.line-type, chr(4)):
            when 1 then do:
              pychk_line-type-chr = buf_temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
            end.
            when 2 then do:
              pychk_line-type-chr = buf_temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
            end.
          end case.
          if  vPromoLineNum <> 0 and
              temp-chk-gds.num-lines > 1 and
              buf_temp-chk-gds.line-num = vPromoLineNum and
              can-find(first buf_chk-gds-pay no-lock where
                             buf_chk-gds-pay.doc-code = buf_temp-chk-gds.doc-code
                         and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num)
          then .
          else
          if not (buf_temp-chk-gds.sum = 0 and can-find (first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code and buf_temp-chk-gds.line-num  =  temp-chk-dp.line-num)) then do:
              if vPromoLineNum <> 0 and
                 buf_temp-chk-gds.line-num = vPromoLineNum
              then do:
                 vSum = RoundUp(buf_temp-chk-gds.doc-qnty, buf_temp-chk-gds.price-base).
              end.
              else if vPromoLineNum <> 0 and
                      temp-chk-gds.num-lines > 1 and
                      pychk_sum-promo <> 0 and
                      ChkPromoLine(buf_temp-chk-gds.doc-code, buf_temp-chk-gds.line-num)
              then do:
                  if can-find(first buf_chk-gds-pay no-lock where
                                    buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                                and buf_chk-gds-pay.line-num = vPromoLineNum
                                )
                   then vSum = (pychk_dop-sumk * buf_temp-chk-gds.sum / (temp-chk-gds.sum - pychk_sum-promo)).
                   else vSum = ((pychk_dop-sumk - pychk_sum-promo) * buf_temp-chk-gds.sum / (temp-chk-gds.sum - pychk_sum-promo)).
              end.
              else
              vSum                     = (if    temp-chk-gds.num-lines = 1
                                            and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                          then pychk_dop-sumk
                                          else (pychk_dop-sumk * buf_temp-chk-gds.sum / temp-chk-gds.sum)
                                         )
              .
              if can-find (first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code) then do:
                  find first buf_chk-gds-pay where buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                  and buf_chk-gds-pay.algo-num = "1.8"
                  and buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
                  and buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
                  and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                  and buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
                  and buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card exclusive-lock no-error.
                  if not available buf_chk-gds-pay then do:
                     if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                     then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                     create buf_chk-gds-pay.
                  end.
              end.
              else do:
                   if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                   then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                   create buf_chk-gds-pay.
              end.
              assign
              buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
              buf_chk-gds-pay.chk-type = ub.chk-doc.chk-type
              buf_chk-gds-pay.algo-num = "1.8"
              buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
              buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
              buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
              buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
              buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
              buf_chk-gds-pay.tot-r-b = buf_chk-gds-pay.tot-r-b  + vSum
              buf_chk-gds-pay.eff-base-rate = pychk_exch
              buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
              buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
              buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
              buf_chk-gds-pay.price-base = buf_temp-chk-gds.price-base
              buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
              buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
              buf_chk-gds-pay.line-type = pychk_line-type-chr
              buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
              buf_chk-gds-pay.density  = buf_temp-chk-gds.density
              buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
              buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
              buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
              buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
              buf_chk-gds-pay.out-code = ub.chk-doc.out-code
              buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
              buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
              buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
              buf_temp-chk-gds.flag = yes
              .
              if buf_temp-chk-gds.line-num = vPromoLineNum
              then do:
                 buf_chk-gds-pay.eff-doc-qnty = buf_temp-chk-gds.doc-qnty.
              end.
              else
              buf_chk-gds-pay.eff-doc-qnty = (if buf_chk-gds-pay.eff-doc-qnty = ? then 0 else buf_chk-gds-pay.eff-doc-qnty) + (if (temp-chk-gds.num-lines = 1
                                              and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                              and pychk_pays_count = 1)
                                              or (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt) = 0
                                              then temp-chk-gds.doc-qnty
                                              else (vSum / (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt))
                                              )
              .
            end.
        end.
      end.
    end.
    if available temp-chk-gds then release temp-chk-gds.
    if available temp-chk-pay then release temp-chk-pay.
    pychk_zero-gds = 0.
    pychk_zero-pay = 0.
    for each temp-chk-gds where
            temp-chk-gds.doc-code = ub.chk-pay.doc-code
        and temp-chk-gds.flag = no
        and temp-chk-gds.line-num  > 0
        :
       pychk_zero-gds = pychk_zero-gds + 1.
    end.
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-pay.doc-code
        and temp-chk-pay.flag = no:
       pychk_zero-pay = pychk_zero-pay + 1.
    end.
    find first temp-chk-pay where temp-chk-pay.doc-code = ub.chk-pay.doc-code
                              and temp-chk-pay.flag = no
    no-lock no-error.
    if not available temp-chk-pay
    then do:
       block-pay:
       for each temp-chk-pay where temp-chk-pay.doc-code = ub.chk-pay.doc-code:
          assign
             pychk_zero-pay = pychk_zero-pay +  1
             temp-chk-pay.flag = no
          .
          leave block-pay.
       end.
    end.
    for each temp-chk-pay
    where   temp-chk-pay.doc-code = ub.chk-pay.doc-code
        and temp-chk-pay.flag = no:
      pychk_zero-n = 0.
      for each buf_temp-chk-gds
      where   buf_temp-chk-gds.doc-code = ub.chk-pay.doc-code
          and buf_temp-chk-gds.flag = no
          and buf_temp-chk-gds.line-num  > 0 :
        pychk_zero-n = pychk_zero-n + 1.
        if  temp-chk-pay.tot-r-b = 0 and buf_temp-chk-gds.discnt = 0 and abs(buf_temp-chk-gds.sum) > 0 then next.
        case num-entries(buf_temp-chk-gds.line-type, chr(4)):
          when 1 then do:
            pychk_line-type-chr = buf_temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
          end.
          when 2 then do:
            pychk_line-type-chr = buf_temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
          end.
        end case.
        if can-find(first buf_chk-gds-pay no-lock where
                          buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                      and buf_chk-gds-pay.algo-num = "1.8"
                      and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                      and buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num)
        then do:
            buf_temp-chk-gds.flag = yes.
        end.
        else do:
            create buf_chk-gds-pay.
            assign
            buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
            buf_chk-gds-pay.algo-num = "1.8"
            buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
            buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
            buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
            buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
            buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
            buf_chk-gds-pay.tot-r-b = 0
            buf_chk-gds-pay.eff-base-rate = pychk_exch
            buf_chk-gds-pay.eff-doc-qnty = buf_temp-chk-gds.doc-qnty
            buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
            buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
            buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
            buf_chk-gds-pay.price-base = (if temp-chk-pay.tot-r-b = 0 and buf_temp-chk-gds.discnt = 0 then 0 else buf_temp-chk-gds.price-base)
            buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
            buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
            buf_chk-gds-pay.line-type = pychk_line-type-chr
            buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
            buf_chk-gds-pay.density  = buf_temp-chk-gds.density
            buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
            buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
            buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
            buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
            buf_chk-gds-pay.out-code = ub.chk-doc.out-code
            buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
            buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
            buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
            buf_temp-chk-gds.flag = yes
            .
        end.
        if pychk_zero-n > pychk_zero-gds / pychk_zero-pay then leave.
      end.
      temp-chk-pay.flag = yes.
    end.
  end.
end.
end.
    end.
  end.
  when "r-pychk2"
  or
  when "bgepych2"
  or
  when "r-accor2"
  or
  when "r-pychk0"
  or
  when "salevza2"
  or
  when "exp-elc2"
  or
  when "r-trg29d"
  then do:
    _chk-doc:
    FOR EACH ub.chk-doc No-LOCK WHERE
            ub.chk-doc.obj-type = p-obj-type
        and ub.chk-doc.obj-code = p-obj-code
        and ub.chk-doc.out-code = p-inkas-code,
      EACH ub.chk-pay NO-LOCK WHERE
              ub.chk-pay.doc-code = ub.chk-doc.doc-code
    BREAK
    BY CHK-pay.DOC-CODE
    BY CHK-pay.LINE-NUM:
      if lookup(string(chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next _chk-doc.
      if p-caller = "r-accor2" and
            not ( ub.chk-doc.chk-type = 1 or
                 ub.chk-doc.chk-type = 6 ) then next _chk-doc.
      if p-caller = "exp-elc2" and ub.chk-doc.d-card = "":U then next _chk-doc.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first-of(ub.CHK-pay.DOC-CODE) THEN Do:
  pychk_create = not can-find (first buf_chk-gds-pay
                               where buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code
                                 and buf_chk-gds-pay.algo-num = "1.8") .
  if pychk_create then do:
    for each temp-chk-pay:
      delete temp-chk-pay.
    end.
    for each temp-chk-gds:
      delete temp-chk-gds.
    end.
    for each temp-chk-dp:
      delete temp-chk-dp.
    end.
    assign
    pychk_kk = 0
    pychk_jj = 1
    pychk_jjp = 0
    pychk_jjo = 0
    pychk_pay-sum = ub.chk-doc.netto
    pychk_dop-sumg = 0
    pychk_pays_count = 0
    .
  end .
end.
if pychk_create   then do:
create-block:
do transaction
on stop   undo create-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo create-block, return error substitute( "&1. endkey", vss-workfile )
on error  undo, throw:
  find first buf2_chk-doc exclusive-lock where
         recid(buf2_chk-doc) = recid(ub.chk-doc).
  if first-of(ub.CHK-pay.DOC-CODE) THEN Do:
    FOR EACH ub.chk-gds No-LOCK WHERE
            ub.chk-gds.doc-code = ub.chk-pay.doc-code
    BY ub.chk-gds.line-num:
      if   ub.chk-gds.write-off-code > 0
        or ub.chk-gds.doc-qnty  eq 0
        or ub.chk-gds.doc-qnty  eq ?
      then NEXT.
      find first buf_bar-code no-lock where
                buf_bar-code.b-code = ub.chk-gds.b-code no-error.
      if not available buf_bar-code then do:
        undo create-block, return error substitute("Не найден товар для бар-кода &1: чек &2 &3&4 строка &5"
                                                    , ub.chk-gds.b-code
                                                    , ub.chk-gds.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , ub.chk-gds.line-num).
      end.
      if ub.chk-gds.pump <> 0 then do:
        pychk_rec-type = 1.
        find first temp-ptrl-goods where
                   temp-ptrl-goods.b-code = ub.chk-gds.b-code no-error.
        if not available temp-ptrl-goods then do:
          run gds-attr-value in this-procedure (
                                                 input buf_bar-code.gds-code
                                                ,input 'ptrl-as-good':U
                                                ,output pychk_value
                                                ,output pychk_type) no-error.
          create temp-ptrl-goods.
          assign
          temp-ptrl-goods.gds-code = buf_bar-code.gds-code
          temp-ptrl-goods.b-code = buf_bar-code.b-code
          temp-ptrl-goods.ptrl-good = (not logical(pychk_value))
          no-error.
        end.
        pychk_line-type = if temp-ptrl-goods.ptrl-good then 1 else 0 .
        release temp-ptrl-goods.
      end.
      else do:
        assign
        pychk_rec-type = 0
        pychk_line-type = 0
        .
      end.
      find first temp-chk-gds where
                temp-chk-gds.doc-code = ub.chk-gds.doc-code
            AND temp-chk-gds.rec-type = pychk_rec-type
            and temp-chk-gds.b-code = ub.chk-gds.b-code
            and temp-chk-gds.line-num = 0
            no-error.
      if not available temp-chk-gds then do:
        find first temp-chk-gds use-index ijj where
                temp-chk-gds.jj_ = pychk_jj
            and temp-chk-gds.line-num = 0
                no-error.
        if not available temp-chk-gds then do:
          create temp-chk-gds.
          assign
          temp-chk-gds.jj_ = pychk_jj
          temp-chk-gds.b-code = ub.chk-gds.b-code
          temp-chk-gds.doc-code = ub.chk-gds.doc-code
          temp-chk-gds.line-num = 0
          temp-chk-gds.rec-type = pychk_rec-type
          temp-chk-gds.gds-code = buf_bar-code.gds-code.
          .
        end.
        else do:
          assign
          temp-chk-gds.b-code = ub.chk-gds.b-code
          temp-chk-gds.doc-code = ub.chk-gds.doc-code
          temp-chk-gds.line-num = 0
          temp-chk-gds.rec-type = pychk_rec-type
          temp-chk-gds.sum = 0
          temp-chk-gds.jjp_ = 0
          temp-chk-gds.jjo_ = 0
          temp-chk-gds.line-type = '':U
          temp-chk-gds.num-lines = 0
          temp-chk-gds.doc-qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.flag  = no
          .
        end.
        assign
        temp-chk-gds.line-type = (if pychk_line-type = 1
                                then 'топ':U
                                else entry(1, ub.chk-gds.line-type, chr(4))
                                ) + chr(4) +
                                (if num-entries(ub.chk-gds.line-type, chr(4)) > 1
                                then entry(2, ub.chk-gds.line-type, chr(4))
                                else '')
        temp-chk-gds.line-num = 0
        temp-chk-gds.num-lines = 0
        temp-chk-gds.density   = ub.chk-gds.density
        pychk_jj = pychk_jj + 1
        .
        if pychk_rec-type = 1 then do:
          assign
          temp-chk-gds.jjp_ = pychk_jjp + 1
          pychk_jjp = pychk_jjp + 1
          .
        end.
        else do:
          assign
          temp-chk-gds.jjo_ = pychk_jjo + 1
          pychk_jjo = pychk_jjo + 1
          .
        end.
      end.
      vSumRound = ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt).
      if ChkPromoPrice(ub.chk-gds.doc-code, ub.chk-gds.line-num) then vSumRound = ub.chk-gds.src-sum.
      assign
      temp-chk-gds.doc-qnty = temp-chk-gds.doc-qnty + ub.chk-gds.doc-qnty
      temp-chk-gds.sum = temp-chk-gds.sum + vSumRound
      temp-chk-gds.num-lines = temp-chk-gds.num-lines  + 1
      .
      find first temp-chk-gds use-index ijj where
              temp-chk-gds.jj_ = 0
          and temp-chk-gds.line-num = ub.chk-gds.line-num
              no-error.
      if not available temp-chk-gds then do:
        create temp-chk-gds.
        assign
        temp-chk-gds.jj_ = 0
        temp-chk-gds.line-num = ub.chk-gds.line-num
        temp-chk-gds.doc-code = ub.chk-gds.doc-code
        temp-chk-gds.b-code = ub.chk-gds.b-code
        temp-chk-gds.gds-code = buf_bar-code.gds-code
        temp-chk-gds.rec-type = pychk_rec-type
        temp-chk-gds.line-num = ub.chk-gds.line-num
        .
      end.
      else do:
        assign
        temp-chk-gds.doc-qnty = 0
        temp-chk-gds.doc-code = ub.chk-gds.doc-code
        temp-chk-gds.b-code = ub.chk-gds.b-code
        temp-chk-gds.gds-code = buf_bar-code.gds-code
        temp-chk-gds.rec-type = pychk_rec-type
        temp-chk-gds.line-num = ub.chk-gds.line-num
        temp-chk-gds.jjp_ = 0
        temp-chk-gds.jjo_ = 0
        temp-chk-gds.line-type = '':U
                .
      end.
      assign
      temp-chk-gds.doc-code = ub.chk-gds.doc-code
      temp-chk-gds.b-code = ub.chk-gds.b-code
      temp-chk-gds.doc-qnty = ub.chk-gds.doc-qnty
      temp-chk-gds.price-base = ub.chk-gds.price-base
      temp-chk-gds.price-service = ub.chk-gds.price-service
      temp-chk-gds.line-type = (if pychk_line-type = 1
                              then 'топ':U
                              else entry(1, ub.chk-gds.line-type, chr(4))
                              ) + chr(4) +
                              (if num-entries(ub.chk-gds.line-type, chr(4)) > 1
                              then entry(2, ub.chk-gds.line-type, chr(4))
                              else '')
      temp-chk-gds.line-sign = ub.chk-gds.line-sign
      temp-chk-gds.discnt = ub.chk-gds.discnt
      temp-chk-gds.sum = vSumRound
      temp-chk-gds.rec-type = pychk_rec-type
      temp-chk-gds.line-num = ub.chk-gds.line-num
      temp-chk-gds.num-lines = 1
      temp-chk-gds.density   = ub.chk-gds.density
      .
    END.
    for each chk-discnt no-lock
       where chk-discnt.doc-code = ub.chk-doc.doc-code
         and record-type = 10
         and chk-discnt.discnt-value-abs <> 0,
        first ub.chk-gds of ub.chk-doc where ub.chk-gds.line-num =  chk-discnt.object-line-num :
            if ub.chk-doc.chk-type = 1 and chk-discnt.object-qnty < 0 then do:
                for first temp-chk-dp where temp-chk-dp.doc-code = ub.chk-doc.doc-code
                and temp-chk-dp.b-code = chk-gds.b-code:
                    temp-chk-dp.sum = temp-chk-dp.sum - abs(chk-discnt.discnt-value-abs * chk-discnt.object-qnty).
                end.
            end.
            else do:
                create temp-chk-dp .
                assign
                temp-chk-dp.doc-code = ub.chk-doc.doc-code
                temp-chk-dp.sum = abs(chk-discnt.discnt-value-abs) * chk-discnt.object-qnty
                temp-chk-dp.line-num = chk-discnt.object-line-num
                temp-chk-dp.pay-code = chk-discnt.rank
                temp-chk-dp.b-code = chk-gds.b-code
                temp-chk-dp.qnty   = abs(chk-discnt.discnt-value-pcnt)
                temp-chk-dp.all-sum =  chk-discnt.discnt-value-abs * chk-discnt.discnt-value-pcnt
                .
            end.
    end.
  end.
  FIND FIRST ub.cash-pay No-LOCK WHERE
            ub.cash-pay.cdpay-code = ub.chk-pay.pay-code AND
            ub.cash-pay.curr-code = ub.chk-pay.curr-code No-ERROR.
  if available ub.cash-pay then do:
    pychk_payline_rrn = "" .
    if not ub.cash-pay.is-cash then do :
      for first buf_chk-pay-attr no-lock
          where buf_chk-pay-attr.doc-code  = ub.CHK-pay.DOC-CODE
            and buf_chk-pay-attr.attr-code = "cpdoc":U
            and buf_chk-pay-attr.line-num  = ub.CHK-pay.line-num :
        pychk_payline_rrn = buf_chk-pay-attr.attr-value .
      end .
    end .
      find first temp-chk-pay where
              temp-chk-pay.doc-code = ub.chk-pay.doc-code
          and temp-chk-pay.pay-code = ub.chk-pay.pay-code
          and temp-chk-pay.pay-card = ub.chk-pay.pay-card
          and temp-chk-pay.curr-code = ub.chk-pay.curr-code
          and temp-chk-pay.rrn       = pychk_payline_rrn
                 no-error.
    if not available temp-chk-pay then do:
        find first temp-chk-pay where
                temp-chk-pay.doc-code = ub.chk-pay.doc-code
            and temp-chk-pay.pay-code = ub.chk-pay.pay-code
            and temp-chk-pay.pay-card = ub.chk-pay.pay-card
            and temp-chk-pay.curr-code = ub.chk-pay.curr-code
            and abs(temp-chk-pay.tot-r-b) >= abs(ub.chk-pay.tot-sum)
            and (temp-chk-pay.tot-r-b >=0) NE (ub.chk-pay.tot-sum >=0)
            no-error.
      if not  avail temp-chk-pay then do:
        find first temp-chk-pay where
                  temp-chk-pay.doc-code = ub.chk-pay.doc-code
              and temp-chk-pay.line-num = ub.chk-pay.line-num use-index pi no-error.
        if not available temp-chk-pay then do:
          create temp-chk-pay.
          assign
          temp-chk-pay.line-num = ub.chk-pay.line-num
          temp-chk-pay.doc-code = ub.chk-doc.doc-code
          temp-chk-pay.pay-code = ub.chk-pay.pay-code
          temp-chk-pay.curr-code =  ub.chk-pay.curr-code
          temp-chk-pay.rrn       = pychk_payline_rrn
          pychk_pays_count = pychk_pays_count + 1
          .
        end.
        assign
        temp-chk-pay.doc-code = ub.chk-doc.doc-code
        temp-chk-pay.pet-good = integer(cash-pay.atr64) * 2 + integer(cash-pay.is-cash) + 2 * int(can-find(first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code ))
        temp-chk-pay.pay-code = ub.chk-pay.pay-code
        temp-chk-pay.curr-code =  ub.chk-pay.curr-code
        temp-chk-pay.is-cash  = ub.cash-pay.is-cash
        temp-chk-pay.register = ub.cash-pay.register
        temp-chk-pay.pay-card = ub.chk-pay.pay-card
        temp-chk-pay.tot-rubl = 0
        temp-chk-pay.tot-base = 0
        temp-chk-pay.num-lines = 0
        temp-chk-pay.flag  = no
        .
      end.
    end.
    assign
    temp-chk-pay.tot-r-b = temp-chk-pay.tot-r-b + (if v-curr-r-b = 'rubl':U
                                                   then ub.chk-pay.tot-rubl
                                                   else ub.chk-pay.tot-base)
    temp-chk-pay.tot-rubl = temp-chk-pay.tot-rubl + ub.chk-pay.tot-rubl
    temp-chk-pay.tot-base = temp-chk-pay.tot-base + ub.chk-pay.tot-base
    temp-chk-pay.num-lines = temp-chk-pay.num-lines  + 1
    .
  end.
  if available temp-chk-pay then RELEASE TEMP-CHK-PAY.
  if last-of(ub.chk-pay.doc-code) then do:
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-doc.doc-code:
       if    (temp-chk-pay.tot-r-b  >= 0) NE (ub.chk-doc.netto >= 0)
          and temp-chk-pay.tot-r-b <> 0
          and abs(ub.chk-doc.netto) > 0.00000001
       then do:
          if not g#auto then do:
             message
                substitute("Не могу обработать чек &1&2&3&4 смена &5 пор.&6 касса &7 № на кассе &8"
                          ,ub.chk-doc.doc-code
                          ,chr(10)
                          ,ub.chk-doc.obj-type
                          ,ub.chk-doc.obj-code
                          ,ub.chk-doc.shift-date
                          ,ub.chk-doc.shift-num
                          ,ub.chk-doc.pay-desk
                          ,ub.chk-doc.chk-num)
                view-as alert-box error .
          end.
          next _chk-doc.
       end.
    end.
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-doc.doc-code
    break
    by temp-chk-pay.pet-good descending
    by temp-chk-pay.line-num:
       dp:
       for each temp-chk-dp no-lock
          where temp-chk-dp.pay-code = temp-chk-pay.pay-code
            and temp-chk-dp.doc-code = temp-chk-pay.doc-code
            and temp-chk-dp.sum <> 0 :
            find first buf_temp-chk-gds2 where
                buf_temp-chk-gds2.doc-code = ub.chk-doc.doc-code
            and buf_temp-chk-gds2.line-num  =  temp-chk-dp.line-num no-error.
            if available buf_temp-chk-gds2 then
            for each buf_temp-chk-gds where
                buf_temp-chk-gds.b-code = buf_temp-chk-gds2.b-code
                and buf_temp-chk-gds.line-num ne 0
            no-lock by buf_temp-chk-gds.line-num  ne  temp-chk-dp.line-num :
                 if         temp-chk-dp.all-sum  eq ?
                    or abs(temp-chk-dp.all-sum) <= 0.001
                then
                   next dp.
                find first  temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                    and buf_temp-chk-gds.b-code = temp-chk-gds.b-code
                  and temp-chk-gds.line-num = 0
                no-error .
                if not available temp-chk-gds then next dp.
                case num-entries(buf_temp-chk-gds.line-type, chr(4)):
                    when 1 then do:
                      pychk_line-type-chr = temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
                    end.
                    when 2 then do:
                      pychk_line-type-chr = temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
                    end.
                end case.
                pychk_dop-sumk =  if temp-chk-dp.sum >= 0
                then min(temp-chk-dp.all-sum,temp-chk-dp.sum,buf_temp-chk-gds.sum,temp-chk-pay.tot-r-b)
                else max(temp-chk-dp.all-sum,temp-chk-dp.sum,buf_temp-chk-gds.sum).
                if abs(temp-chk-pay.tot-r-b - pychk_dop-sumk) <= 0.001
                then
                   pychk_dop-sumk = temp-chk-pay.tot-r-b.
                temp-chk-dp.all-sum           = temp-chk-dp.all-sum - pychk_dop-sumk.
                if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                create buf_chk-gds-pay.
                  assign
                  buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                  buf_chk-gds-pay.chk-type = ub.chk-doc.chk-type
                  buf_chk-gds-pay.algo-num = "1.8"
                  buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
                  buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
                  buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                  buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                  buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
                  buf_chk-gds-pay.tot-r-b =  pychk_dop-sumk
                  buf_chk-gds-pay.eff-base-rate = 1
                  buf_chk-gds-pay.eff-doc-qnty = (if (temp-chk-gds.num-lines = 1
                                                  and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                                  and pychk_pays_count = 1)
                                                  or (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt) = 0
                                                  then temp-chk-gds.doc-qnty
                                                  else (buf_chk-gds-pay.tot-r-b / (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt))
                                                  )
                  buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
                  buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
                  buf_chk-gds-pay.price-base = buf_temp-chk-gds.price-base
                  buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
                  buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
                  buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
                  buf_chk-gds-pay.line-type = pychk_line-type-chr
                  buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
                  buf_chk-gds-pay.density  = buf_temp-chk-gds.density
                  buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
                  buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
                  buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
                  buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
                  buf_chk-gds-pay.out-code = ub.chk-doc.out-code
                  buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
                  buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
                  buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
                  .
                assign
                buf_temp-chk-gds.sum = buf_temp-chk-gds.sum - buf_chk-gds-pay.tot-r-b
                temp-chk-gds.sum =  temp-chk-gds.sum - buf_chk-gds-pay.tot-r-b
                buf_temp-chk-gds.doc-qnty = buf_temp-chk-gds.doc-qnty - buf_chk-gds-pay.eff-doc-qnty
                temp-chk-pay.tot-r-b = temp-chk-pay.tot-r-b - buf_chk-gds-pay.tot-r-b
                pychk_dop-sumk = pychk_dop-sumk - buf_chk-gds-pay.tot-r-b
                .
                 if (ub.chk-doc.chk-type = 1 and temp-chk-pay.tot-r-b <= 0) or (ub.chk-doc.chk-type <> 1 and temp-chk-pay.tot-r-b >= 0) then leave dp.
            end.
        end.
      assign
      pychk_dop-sump = temp-chk-pay.tot-r-b
      pychk_exch = if pychk_No-exch then 1
                   else (if temp-chk-pay.tot-base = 0
                         then 0
                         else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base)
      pychk_exch-rubl = if pychk_No-exch-rubl
                        then 1
                        else (if temp-chk-pay.tot-base = 0
                              then 0
                              else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base)
      temp-chk-pay.flag = (if abs(temp-chk-pay.tot-rubl) < 0.001 then no else yes)
      .
      _repeat:
      REPEAT WHILE  abs(pychk_dop-sump) > 0 :
        if pychk_dop-sumg = 0 then do:
          assign
          pychk_kk = pychk_kk + 1
          .
          if pychk_kk >= pychk_jj then LEAVE _repeat.
          if pychk_kk <= pychk_jjp then do:
            find first temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                  and temp-chk-gds.jjp_ = pychk_kk
                  and temp-chk-gds.line-num = 0
                no-error .
          end.
          else do:
            find first temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                  and temp-chk-gds.jjo_ = pychk_kk - pychk_jjp
                  and temp-chk-gds.line-num = 0
                no-error .
          end.
          if not available temp-chk-gds
          or (temp-chk-gds.sum = 0
              or
              (temp-chk-gds.sum <= 0  and ub.chk-doc.netto > 0)
              )
          then do:
            NEXT _repeat.
          end.
          assign
          pychk_dop-sumg = if available temp-chk-gds then temp-chk-gds.sum else 0
          temp-chk-gds.flag = yes
          .
        end.
        assign
        pychk_dop-sumk = min(abs(pychk_dop-sumg), abs(pychk_dop-sump))  * (if pychk_dop-sump > 0 then 1 else -1 ) * (if pychk_dop-sumg < 0 AND ub.chk-doc.chk-type = 1 then -1 else 1 )
        pychk_pay-sum = pychk_pay-sum - pychk_dop-sumk
        pychk_dop-sump = pychk_dop-sump - pychk_dop-sumk
        pychk_dop-sumg = pychk_dop-sumg - pychk_dop-sumk
        pychk_sum-promo = GetPromoPriceSum(ub.chk-doc.doc-code)
        .
        if pychk_sum-promo <> 0 then
           vPromoLineNum = GetPromoPriceLine(ub.chk-doc.doc-code).
        else vPromoLineNum = 0.
        for each buf_temp-chk-gds where
                buf_temp-chk-gds.doc-code = ub.chk-doc.doc-code
            and buf_temp-chk-gds.b-code = temp-chk-gds.b-code
            and buf_temp-chk-gds.line-num  > 0
        by buf_temp-chk-gds.doc-code
        by buf_temp-chk-gds.rec-type descending
        by buf_temp-chk-gds.line-num
         :
          case num-entries(buf_temp-chk-gds.line-type, chr(4)):
            when 1 then do:
              pychk_line-type-chr = buf_temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
            end.
            when 2 then do:
              pychk_line-type-chr = buf_temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
            end.
          end case.
          if  vPromoLineNum <> 0 and
              temp-chk-gds.num-lines > 1 and
              buf_temp-chk-gds.line-num = vPromoLineNum and
              can-find(first buf_chk-gds-pay no-lock where
                             buf_chk-gds-pay.doc-code = buf_temp-chk-gds.doc-code
                         and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num)
          then .
          else
          if not (buf_temp-chk-gds.sum = 0 and can-find (first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code and buf_temp-chk-gds.line-num  =  temp-chk-dp.line-num)) then do:
              if vPromoLineNum <> 0 and
                 buf_temp-chk-gds.line-num = vPromoLineNum
              then do:
                 vSum = RoundUp(buf_temp-chk-gds.doc-qnty, buf_temp-chk-gds.price-base).
              end.
              else if vPromoLineNum <> 0 and
                      temp-chk-gds.num-lines > 1 and
                      pychk_sum-promo <> 0 and
                      ChkPromoLine(buf_temp-chk-gds.doc-code, buf_temp-chk-gds.line-num)
              then do:
                  if can-find(first buf_chk-gds-pay no-lock where
                                    buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                                and buf_chk-gds-pay.line-num = vPromoLineNum
                                )
                   then vSum = (pychk_dop-sumk * buf_temp-chk-gds.sum / (temp-chk-gds.sum - pychk_sum-promo)).
                   else vSum = ((pychk_dop-sumk - pychk_sum-promo) * buf_temp-chk-gds.sum / (temp-chk-gds.sum - pychk_sum-promo)).
              end.
              else
              vSum                     = (if    temp-chk-gds.num-lines = 1
                                            and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                          then pychk_dop-sumk
                                          else (pychk_dop-sumk * buf_temp-chk-gds.sum / temp-chk-gds.sum)
                                         )
              .
              if can-find (first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code) then do:
                  find first buf_chk-gds-pay where buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                  and buf_chk-gds-pay.algo-num = "1.8"
                  and buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
                  and buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
                  and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                  and buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
                  and buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card exclusive-lock no-error.
                  if not available buf_chk-gds-pay then do:
                     if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                     then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                     create buf_chk-gds-pay.
                  end.
              end.
              else do:
                   if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                   then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                   create buf_chk-gds-pay.
              end.
              assign
              buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
              buf_chk-gds-pay.chk-type = ub.chk-doc.chk-type
              buf_chk-gds-pay.algo-num = "1.8"
              buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
              buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
              buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
              buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
              buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
              buf_chk-gds-pay.tot-r-b = buf_chk-gds-pay.tot-r-b  + vSum
              buf_chk-gds-pay.eff-base-rate = pychk_exch
              buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
              buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
              buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
              buf_chk-gds-pay.price-base = buf_temp-chk-gds.price-base
              buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
              buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
              buf_chk-gds-pay.line-type = pychk_line-type-chr
              buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
              buf_chk-gds-pay.density  = buf_temp-chk-gds.density
              buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
              buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
              buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
              buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
              buf_chk-gds-pay.out-code = ub.chk-doc.out-code
              buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
              buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
              buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
              buf_temp-chk-gds.flag = yes
              .
              if buf_temp-chk-gds.line-num = vPromoLineNum
              then do:
                 buf_chk-gds-pay.eff-doc-qnty = buf_temp-chk-gds.doc-qnty.
              end.
              else
              buf_chk-gds-pay.eff-doc-qnty = (if buf_chk-gds-pay.eff-doc-qnty = ? then 0 else buf_chk-gds-pay.eff-doc-qnty) + (if (temp-chk-gds.num-lines = 1
                                              and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                              and pychk_pays_count = 1)
                                              or (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt) = 0
                                              then temp-chk-gds.doc-qnty
                                              else (vSum / (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt))
                                              )
              .
            end.
        end.
      end.
    end.
    if available temp-chk-gds then release temp-chk-gds.
    if available temp-chk-pay then release temp-chk-pay.
    pychk_zero-gds = 0.
    pychk_zero-pay = 0.
    for each temp-chk-gds where
            temp-chk-gds.doc-code = ub.chk-pay.doc-code
        and temp-chk-gds.flag = no
        and temp-chk-gds.line-num  > 0
        :
       pychk_zero-gds = pychk_zero-gds + 1.
    end.
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-pay.doc-code
        and temp-chk-pay.flag = no:
       pychk_zero-pay = pychk_zero-pay + 1.
    end.
    find first temp-chk-pay where temp-chk-pay.doc-code = ub.chk-pay.doc-code
                              and temp-chk-pay.flag = no
    no-lock no-error.
    if not available temp-chk-pay
    then do:
       block-pay:
       for each temp-chk-pay where temp-chk-pay.doc-code = ub.chk-pay.doc-code:
          assign
             pychk_zero-pay = pychk_zero-pay +  1
             temp-chk-pay.flag = no
          .
          leave block-pay.
       end.
    end.
    for each temp-chk-pay
    where   temp-chk-pay.doc-code = ub.chk-pay.doc-code
        and temp-chk-pay.flag = no:
      pychk_zero-n = 0.
      for each buf_temp-chk-gds
      where   buf_temp-chk-gds.doc-code = ub.chk-pay.doc-code
          and buf_temp-chk-gds.flag = no
          and buf_temp-chk-gds.line-num  > 0 :
        pychk_zero-n = pychk_zero-n + 1.
        if  temp-chk-pay.tot-r-b = 0 and buf_temp-chk-gds.discnt = 0 and abs(buf_temp-chk-gds.sum) > 0 then next.
        case num-entries(buf_temp-chk-gds.line-type, chr(4)):
          when 1 then do:
            pychk_line-type-chr = buf_temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
          end.
          when 2 then do:
            pychk_line-type-chr = buf_temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
          end.
        end case.
        if can-find(first buf_chk-gds-pay no-lock where
                          buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                      and buf_chk-gds-pay.algo-num = "1.8"
                      and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                      and buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num)
        then do:
            buf_temp-chk-gds.flag = yes.
        end.
        else do:
            create buf_chk-gds-pay.
            assign
            buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
            buf_chk-gds-pay.algo-num = "1.8"
            buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
            buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
            buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
            buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
            buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
            buf_chk-gds-pay.tot-r-b = 0
            buf_chk-gds-pay.eff-base-rate = pychk_exch
            buf_chk-gds-pay.eff-doc-qnty = buf_temp-chk-gds.doc-qnty
            buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
            buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
            buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
            buf_chk-gds-pay.price-base = (if temp-chk-pay.tot-r-b = 0 and buf_temp-chk-gds.discnt = 0 then 0 else buf_temp-chk-gds.price-base)
            buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
            buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
            buf_chk-gds-pay.line-type = pychk_line-type-chr
            buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
            buf_chk-gds-pay.density  = buf_temp-chk-gds.density
            buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
            buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
            buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
            buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
            buf_chk-gds-pay.out-code = ub.chk-doc.out-code
            buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
            buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
            buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
            buf_temp-chk-gds.flag = yes
            .
        end.
        if pychk_zero-n > pychk_zero-gds / pychk_zero-pay then leave.
      end.
      temp-chk-pay.flag = yes.
    end.
  end.
end.
end.
    end.
  end.
  when "r-autocu"
  then do:
    _chk-doc:
    FOR EACH ub.chk-doc No-LOCK WHERE
            ub.chk-doc.obj-type = p-obj-type
        and ub.chk-doc.obj-code = p-obj-code
        and ub.chk-doc.chk-date >= p-date-start
        and ub.chk-doc.chk-date <= p-date-end,
      EACH ub.chk-pay NO-LOCK WHERE
              ub.chk-pay.doc-code = ub.chk-doc.doc-code
    BREAK
    BY CHK-pay.DOC-CODE
    BY CHK-pay.LINE-NUM:
      if lookup(string(chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next _chk-doc.
      if replace(replace(replace(replace(ub.chk-doc.office, 'у':U, ''), 'т':U, ''), 'смн-ош':U, ''), chr(44), '') <> '' then next _chk-doc.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first-of(ub.CHK-pay.DOC-CODE) THEN Do:
  pychk_create = not can-find (first buf_chk-gds-pay
                               where buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code
                                 and buf_chk-gds-pay.algo-num = "1.8") .
  if pychk_create then do:
    for each temp-chk-pay:
      delete temp-chk-pay.
    end.
    for each temp-chk-gds:
      delete temp-chk-gds.
    end.
    for each temp-chk-dp:
      delete temp-chk-dp.
    end.
    assign
    pychk_kk = 0
    pychk_jj = 1
    pychk_jjp = 0
    pychk_jjo = 0
    pychk_pay-sum = ub.chk-doc.netto
    pychk_dop-sumg = 0
    pychk_pays_count = 0
    .
  end .
end.
if pychk_create   then do:
create-block:
do transaction
on stop   undo create-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo create-block, return error substitute( "&1. endkey", vss-workfile )
on error  undo, throw:
  find first buf2_chk-doc exclusive-lock where
         recid(buf2_chk-doc) = recid(ub.chk-doc).
  if first-of(ub.CHK-pay.DOC-CODE) THEN Do:
    FOR EACH ub.chk-gds No-LOCK WHERE
            ub.chk-gds.doc-code = ub.chk-pay.doc-code
    BY ub.chk-gds.line-num:
      if   ub.chk-gds.write-off-code > 0
        or ub.chk-gds.doc-qnty  eq 0
        or ub.chk-gds.doc-qnty  eq ?
      then NEXT.
      find first buf_bar-code no-lock where
                buf_bar-code.b-code = ub.chk-gds.b-code no-error.
      if not available buf_bar-code then do:
        undo create-block, return error substitute("Не найден товар для бар-кода &1: чек &2 &3&4 строка &5"
                                                    , ub.chk-gds.b-code
                                                    , ub.chk-gds.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , ub.chk-gds.line-num).
      end.
      if ub.chk-gds.pump <> 0 then do:
        pychk_rec-type = 1.
        find first temp-ptrl-goods where
                   temp-ptrl-goods.b-code = ub.chk-gds.b-code no-error.
        if not available temp-ptrl-goods then do:
          run gds-attr-value in this-procedure (
                                                 input buf_bar-code.gds-code
                                                ,input 'ptrl-as-good':U
                                                ,output pychk_value
                                                ,output pychk_type) no-error.
          create temp-ptrl-goods.
          assign
          temp-ptrl-goods.gds-code = buf_bar-code.gds-code
          temp-ptrl-goods.b-code = buf_bar-code.b-code
          temp-ptrl-goods.ptrl-good = (not logical(pychk_value))
          no-error.
        end.
        pychk_line-type = if temp-ptrl-goods.ptrl-good then 1 else 0 .
        release temp-ptrl-goods.
      end.
      else do:
        assign
        pychk_rec-type = 0
        pychk_line-type = 0
        .
      end.
      find first temp-chk-gds where
                temp-chk-gds.doc-code = ub.chk-gds.doc-code
            AND temp-chk-gds.rec-type = pychk_rec-type
            and temp-chk-gds.b-code = ub.chk-gds.b-code
            and temp-chk-gds.line-num = 0
            no-error.
      if not available temp-chk-gds then do:
        find first temp-chk-gds use-index ijj where
                temp-chk-gds.jj_ = pychk_jj
            and temp-chk-gds.line-num = 0
                no-error.
        if not available temp-chk-gds then do:
          create temp-chk-gds.
          assign
          temp-chk-gds.jj_ = pychk_jj
          temp-chk-gds.b-code = ub.chk-gds.b-code
          temp-chk-gds.doc-code = ub.chk-gds.doc-code
          temp-chk-gds.line-num = 0
          temp-chk-gds.rec-type = pychk_rec-type
          temp-chk-gds.gds-code = buf_bar-code.gds-code.
          .
        end.
        else do:
          assign
          temp-chk-gds.b-code = ub.chk-gds.b-code
          temp-chk-gds.doc-code = ub.chk-gds.doc-code
          temp-chk-gds.line-num = 0
          temp-chk-gds.rec-type = pychk_rec-type
          temp-chk-gds.sum = 0
          temp-chk-gds.jjp_ = 0
          temp-chk-gds.jjo_ = 0
          temp-chk-gds.line-type = '':U
          temp-chk-gds.num-lines = 0
          temp-chk-gds.doc-qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.flag  = no
          .
        end.
        assign
        temp-chk-gds.line-type = (if pychk_line-type = 1
                                then 'топ':U
                                else entry(1, ub.chk-gds.line-type, chr(4))
                                ) + chr(4) +
                                (if num-entries(ub.chk-gds.line-type, chr(4)) > 1
                                then entry(2, ub.chk-gds.line-type, chr(4))
                                else '')
        temp-chk-gds.line-num = 0
        temp-chk-gds.num-lines = 0
        temp-chk-gds.density   = ub.chk-gds.density
        pychk_jj = pychk_jj + 1
        .
        if pychk_rec-type = 1 then do:
          assign
          temp-chk-gds.jjp_ = pychk_jjp + 1
          pychk_jjp = pychk_jjp + 1
          .
        end.
        else do:
          assign
          temp-chk-gds.jjo_ = pychk_jjo + 1
          pychk_jjo = pychk_jjo + 1
          .
        end.
      end.
      vSumRound = ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt).
      if ChkPromoPrice(ub.chk-gds.doc-code, ub.chk-gds.line-num) then vSumRound = ub.chk-gds.src-sum.
      assign
      temp-chk-gds.doc-qnty = temp-chk-gds.doc-qnty + ub.chk-gds.doc-qnty
      temp-chk-gds.sum = temp-chk-gds.sum + vSumRound
      temp-chk-gds.num-lines = temp-chk-gds.num-lines  + 1
      .
      find first temp-chk-gds use-index ijj where
              temp-chk-gds.jj_ = 0
          and temp-chk-gds.line-num = ub.chk-gds.line-num
              no-error.
      if not available temp-chk-gds then do:
        create temp-chk-gds.
        assign
        temp-chk-gds.jj_ = 0
        temp-chk-gds.line-num = ub.chk-gds.line-num
        temp-chk-gds.doc-code = ub.chk-gds.doc-code
        temp-chk-gds.b-code = ub.chk-gds.b-code
        temp-chk-gds.gds-code = buf_bar-code.gds-code
        temp-chk-gds.rec-type = pychk_rec-type
        temp-chk-gds.line-num = ub.chk-gds.line-num
        .
      end.
      else do:
        assign
        temp-chk-gds.doc-qnty = 0
        temp-chk-gds.doc-code = ub.chk-gds.doc-code
        temp-chk-gds.b-code = ub.chk-gds.b-code
        temp-chk-gds.gds-code = buf_bar-code.gds-code
        temp-chk-gds.rec-type = pychk_rec-type
        temp-chk-gds.line-num = ub.chk-gds.line-num
        temp-chk-gds.jjp_ = 0
        temp-chk-gds.jjo_ = 0
        temp-chk-gds.line-type = '':U
                .
      end.
      assign
      temp-chk-gds.doc-code = ub.chk-gds.doc-code
      temp-chk-gds.b-code = ub.chk-gds.b-code
      temp-chk-gds.doc-qnty = ub.chk-gds.doc-qnty
      temp-chk-gds.price-base = ub.chk-gds.price-base
      temp-chk-gds.price-service = ub.chk-gds.price-service
      temp-chk-gds.line-type = (if pychk_line-type = 1
                              then 'топ':U
                              else entry(1, ub.chk-gds.line-type, chr(4))
                              ) + chr(4) +
                              (if num-entries(ub.chk-gds.line-type, chr(4)) > 1
                              then entry(2, ub.chk-gds.line-type, chr(4))
                              else '')
      temp-chk-gds.line-sign = ub.chk-gds.line-sign
      temp-chk-gds.discnt = ub.chk-gds.discnt
      temp-chk-gds.sum = vSumRound
      temp-chk-gds.rec-type = pychk_rec-type
      temp-chk-gds.line-num = ub.chk-gds.line-num
      temp-chk-gds.num-lines = 1
      temp-chk-gds.density   = ub.chk-gds.density
      .
    END.
    for each chk-discnt no-lock
       where chk-discnt.doc-code = ub.chk-doc.doc-code
         and record-type = 10
         and chk-discnt.discnt-value-abs <> 0,
        first ub.chk-gds of ub.chk-doc where ub.chk-gds.line-num =  chk-discnt.object-line-num :
            if ub.chk-doc.chk-type = 1 and chk-discnt.object-qnty < 0 then do:
                for first temp-chk-dp where temp-chk-dp.doc-code = ub.chk-doc.doc-code
                and temp-chk-dp.b-code = chk-gds.b-code:
                    temp-chk-dp.sum = temp-chk-dp.sum - abs(chk-discnt.discnt-value-abs * chk-discnt.object-qnty).
                end.
            end.
            else do:
                create temp-chk-dp .
                assign
                temp-chk-dp.doc-code = ub.chk-doc.doc-code
                temp-chk-dp.sum = abs(chk-discnt.discnt-value-abs) * chk-discnt.object-qnty
                temp-chk-dp.line-num = chk-discnt.object-line-num
                temp-chk-dp.pay-code = chk-discnt.rank
                temp-chk-dp.b-code = chk-gds.b-code
                temp-chk-dp.qnty   = abs(chk-discnt.discnt-value-pcnt)
                temp-chk-dp.all-sum =  chk-discnt.discnt-value-abs * chk-discnt.discnt-value-pcnt
                .
            end.
    end.
  end.
  FIND FIRST ub.cash-pay No-LOCK WHERE
            ub.cash-pay.cdpay-code = ub.chk-pay.pay-code AND
            ub.cash-pay.curr-code = ub.chk-pay.curr-code No-ERROR.
  if available ub.cash-pay then do:
    pychk_payline_rrn = "" .
    if not ub.cash-pay.is-cash then do :
      for first buf_chk-pay-attr no-lock
          where buf_chk-pay-attr.doc-code  = ub.CHK-pay.DOC-CODE
            and buf_chk-pay-attr.attr-code = "cpdoc":U
            and buf_chk-pay-attr.line-num  = ub.CHK-pay.line-num :
        pychk_payline_rrn = buf_chk-pay-attr.attr-value .
      end .
    end .
      find first temp-chk-pay where
              temp-chk-pay.doc-code = ub.chk-pay.doc-code
          and temp-chk-pay.pay-code = ub.chk-pay.pay-code
          and temp-chk-pay.pay-card = ub.chk-pay.pay-card
          and temp-chk-pay.curr-code = ub.chk-pay.curr-code
          and temp-chk-pay.rrn       = pychk_payline_rrn
                 no-error.
    if not available temp-chk-pay then do:
        find first temp-chk-pay where
                temp-chk-pay.doc-code = ub.chk-pay.doc-code
            and temp-chk-pay.pay-code = ub.chk-pay.pay-code
            and temp-chk-pay.pay-card = ub.chk-pay.pay-card
            and temp-chk-pay.curr-code = ub.chk-pay.curr-code
            and abs(temp-chk-pay.tot-r-b) >= abs(ub.chk-pay.tot-sum)
            and (temp-chk-pay.tot-r-b >=0) NE (ub.chk-pay.tot-sum >=0)
            no-error.
      if not  avail temp-chk-pay then do:
        find first temp-chk-pay where
                  temp-chk-pay.doc-code = ub.chk-pay.doc-code
              and temp-chk-pay.line-num = ub.chk-pay.line-num use-index pi no-error.
        if not available temp-chk-pay then do:
          create temp-chk-pay.
          assign
          temp-chk-pay.line-num = ub.chk-pay.line-num
          temp-chk-pay.doc-code = ub.chk-doc.doc-code
          temp-chk-pay.pay-code = ub.chk-pay.pay-code
          temp-chk-pay.curr-code =  ub.chk-pay.curr-code
          temp-chk-pay.rrn       = pychk_payline_rrn
          pychk_pays_count = pychk_pays_count + 1
          .
        end.
        assign
        temp-chk-pay.doc-code = ub.chk-doc.doc-code
        temp-chk-pay.pet-good = integer(cash-pay.atr64) * 2 + integer(cash-pay.is-cash) + 2 * int(can-find(first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code ))
        temp-chk-pay.pay-code = ub.chk-pay.pay-code
        temp-chk-pay.curr-code =  ub.chk-pay.curr-code
        temp-chk-pay.is-cash  = ub.cash-pay.is-cash
        temp-chk-pay.register = ub.cash-pay.register
        temp-chk-pay.pay-card = ub.chk-pay.pay-card
        temp-chk-pay.tot-rubl = 0
        temp-chk-pay.tot-base = 0
        temp-chk-pay.num-lines = 0
        temp-chk-pay.flag  = no
        .
      end.
    end.
    assign
    temp-chk-pay.tot-r-b = temp-chk-pay.tot-r-b + (if v-curr-r-b = 'rubl':U
                                                   then ub.chk-pay.tot-rubl
                                                   else ub.chk-pay.tot-base)
    temp-chk-pay.tot-rubl = temp-chk-pay.tot-rubl + ub.chk-pay.tot-rubl
    temp-chk-pay.tot-base = temp-chk-pay.tot-base + ub.chk-pay.tot-base
    temp-chk-pay.num-lines = temp-chk-pay.num-lines  + 1
    .
  end.
  if available temp-chk-pay then RELEASE TEMP-CHK-PAY.
  if last-of(ub.chk-pay.doc-code) then do:
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-doc.doc-code:
       if    (temp-chk-pay.tot-r-b  >= 0) NE (ub.chk-doc.netto >= 0)
          and temp-chk-pay.tot-r-b <> 0
          and abs(ub.chk-doc.netto) > 0.00000001
       then do:
          if not g#auto then do:
             message
                substitute("Не могу обработать чек &1&2&3&4 смена &5 пор.&6 касса &7 № на кассе &8"
                          ,ub.chk-doc.doc-code
                          ,chr(10)
                          ,ub.chk-doc.obj-type
                          ,ub.chk-doc.obj-code
                          ,ub.chk-doc.shift-date
                          ,ub.chk-doc.shift-num
                          ,ub.chk-doc.pay-desk
                          ,ub.chk-doc.chk-num)
                view-as alert-box error .
          end.
          next _chk-doc.
       end.
    end.
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-doc.doc-code
    break
    by temp-chk-pay.pet-good descending
    by temp-chk-pay.line-num:
       dp:
       for each temp-chk-dp no-lock
          where temp-chk-dp.pay-code = temp-chk-pay.pay-code
            and temp-chk-dp.doc-code = temp-chk-pay.doc-code
            and temp-chk-dp.sum <> 0 :
            find first buf_temp-chk-gds2 where
                buf_temp-chk-gds2.doc-code = ub.chk-doc.doc-code
            and buf_temp-chk-gds2.line-num  =  temp-chk-dp.line-num no-error.
            if available buf_temp-chk-gds2 then
            for each buf_temp-chk-gds where
                buf_temp-chk-gds.b-code = buf_temp-chk-gds2.b-code
                and buf_temp-chk-gds.line-num ne 0
            no-lock by buf_temp-chk-gds.line-num  ne  temp-chk-dp.line-num :
                 if         temp-chk-dp.all-sum  eq ?
                    or abs(temp-chk-dp.all-sum) <= 0.001
                then
                   next dp.
                find first  temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                    and buf_temp-chk-gds.b-code = temp-chk-gds.b-code
                  and temp-chk-gds.line-num = 0
                no-error .
                if not available temp-chk-gds then next dp.
                case num-entries(buf_temp-chk-gds.line-type, chr(4)):
                    when 1 then do:
                      pychk_line-type-chr = temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
                    end.
                    when 2 then do:
                      pychk_line-type-chr = temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
                    end.
                end case.
                pychk_dop-sumk =  if temp-chk-dp.sum >= 0
                then min(temp-chk-dp.all-sum,temp-chk-dp.sum,buf_temp-chk-gds.sum,temp-chk-pay.tot-r-b)
                else max(temp-chk-dp.all-sum,temp-chk-dp.sum,buf_temp-chk-gds.sum).
                if abs(temp-chk-pay.tot-r-b - pychk_dop-sumk) <= 0.001
                then
                   pychk_dop-sumk = temp-chk-pay.tot-r-b.
                temp-chk-dp.all-sum           = temp-chk-dp.all-sum - pychk_dop-sumk.
                if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                create buf_chk-gds-pay.
                  assign
                  buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                  buf_chk-gds-pay.chk-type = ub.chk-doc.chk-type
                  buf_chk-gds-pay.algo-num = "1.8"
                  buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
                  buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
                  buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                  buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                  buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
                  buf_chk-gds-pay.tot-r-b =  pychk_dop-sumk
                  buf_chk-gds-pay.eff-base-rate = 1
                  buf_chk-gds-pay.eff-doc-qnty = (if (temp-chk-gds.num-lines = 1
                                                  and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                                  and pychk_pays_count = 1)
                                                  or (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt) = 0
                                                  then temp-chk-gds.doc-qnty
                                                  else (buf_chk-gds-pay.tot-r-b / (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt))
                                                  )
                  buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
                  buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
                  buf_chk-gds-pay.price-base = buf_temp-chk-gds.price-base
                  buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
                  buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
                  buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
                  buf_chk-gds-pay.line-type = pychk_line-type-chr
                  buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
                  buf_chk-gds-pay.density  = buf_temp-chk-gds.density
                  buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
                  buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
                  buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
                  buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
                  buf_chk-gds-pay.out-code = ub.chk-doc.out-code
                  buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
                  buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
                  buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
                  .
                assign
                buf_temp-chk-gds.sum = buf_temp-chk-gds.sum - buf_chk-gds-pay.tot-r-b
                temp-chk-gds.sum =  temp-chk-gds.sum - buf_chk-gds-pay.tot-r-b
                buf_temp-chk-gds.doc-qnty = buf_temp-chk-gds.doc-qnty - buf_chk-gds-pay.eff-doc-qnty
                temp-chk-pay.tot-r-b = temp-chk-pay.tot-r-b - buf_chk-gds-pay.tot-r-b
                pychk_dop-sumk = pychk_dop-sumk - buf_chk-gds-pay.tot-r-b
                .
                 if (ub.chk-doc.chk-type = 1 and temp-chk-pay.tot-r-b <= 0) or (ub.chk-doc.chk-type <> 1 and temp-chk-pay.tot-r-b >= 0) then leave dp.
            end.
        end.
      assign
      pychk_dop-sump = temp-chk-pay.tot-r-b
      pychk_exch = if pychk_No-exch then 1
                   else (if temp-chk-pay.tot-base = 0
                         then 0
                         else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base)
      pychk_exch-rubl = if pychk_No-exch-rubl
                        then 1
                        else (if temp-chk-pay.tot-base = 0
                              then 0
                              else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base)
      temp-chk-pay.flag = (if abs(temp-chk-pay.tot-rubl) < 0.001 then no else yes)
      .
      _repeat:
      REPEAT WHILE  abs(pychk_dop-sump) > 0 :
        if pychk_dop-sumg = 0 then do:
          assign
          pychk_kk = pychk_kk + 1
          .
          if pychk_kk >= pychk_jj then LEAVE _repeat.
          if pychk_kk <= pychk_jjp then do:
            find first temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                  and temp-chk-gds.jjp_ = pychk_kk
                  and temp-chk-gds.line-num = 0
                no-error .
          end.
          else do:
            find first temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                  and temp-chk-gds.jjo_ = pychk_kk - pychk_jjp
                  and temp-chk-gds.line-num = 0
                no-error .
          end.
          if not available temp-chk-gds
          or (temp-chk-gds.sum = 0
              or
              (temp-chk-gds.sum <= 0  and ub.chk-doc.netto > 0)
              )
          then do:
            NEXT _repeat.
          end.
          assign
          pychk_dop-sumg = if available temp-chk-gds then temp-chk-gds.sum else 0
          temp-chk-gds.flag = yes
          .
        end.
        assign
        pychk_dop-sumk = min(abs(pychk_dop-sumg), abs(pychk_dop-sump))  * (if pychk_dop-sump > 0 then 1 else -1 ) * (if pychk_dop-sumg < 0 AND ub.chk-doc.chk-type = 1 then -1 else 1 )
        pychk_pay-sum = pychk_pay-sum - pychk_dop-sumk
        pychk_dop-sump = pychk_dop-sump - pychk_dop-sumk
        pychk_dop-sumg = pychk_dop-sumg - pychk_dop-sumk
        pychk_sum-promo = GetPromoPriceSum(ub.chk-doc.doc-code)
        .
        if pychk_sum-promo <> 0 then
           vPromoLineNum = GetPromoPriceLine(ub.chk-doc.doc-code).
        else vPromoLineNum = 0.
        for each buf_temp-chk-gds where
                buf_temp-chk-gds.doc-code = ub.chk-doc.doc-code
            and buf_temp-chk-gds.b-code = temp-chk-gds.b-code
            and buf_temp-chk-gds.line-num  > 0
        by buf_temp-chk-gds.doc-code
        by buf_temp-chk-gds.rec-type descending
        by buf_temp-chk-gds.line-num
         :
          case num-entries(buf_temp-chk-gds.line-type, chr(4)):
            when 1 then do:
              pychk_line-type-chr = buf_temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
            end.
            when 2 then do:
              pychk_line-type-chr = buf_temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
            end.
          end case.
          if  vPromoLineNum <> 0 and
              temp-chk-gds.num-lines > 1 and
              buf_temp-chk-gds.line-num = vPromoLineNum and
              can-find(first buf_chk-gds-pay no-lock where
                             buf_chk-gds-pay.doc-code = buf_temp-chk-gds.doc-code
                         and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num)
          then .
          else
          if not (buf_temp-chk-gds.sum = 0 and can-find (first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code and buf_temp-chk-gds.line-num  =  temp-chk-dp.line-num)) then do:
              if vPromoLineNum <> 0 and
                 buf_temp-chk-gds.line-num = vPromoLineNum
              then do:
                 vSum = RoundUp(buf_temp-chk-gds.doc-qnty, buf_temp-chk-gds.price-base).
              end.
              else if vPromoLineNum <> 0 and
                      temp-chk-gds.num-lines > 1 and
                      pychk_sum-promo <> 0 and
                      ChkPromoLine(buf_temp-chk-gds.doc-code, buf_temp-chk-gds.line-num)
              then do:
                  if can-find(first buf_chk-gds-pay no-lock where
                                    buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                                and buf_chk-gds-pay.line-num = vPromoLineNum
                                )
                   then vSum = (pychk_dop-sumk * buf_temp-chk-gds.sum / (temp-chk-gds.sum - pychk_sum-promo)).
                   else vSum = ((pychk_dop-sumk - pychk_sum-promo) * buf_temp-chk-gds.sum / (temp-chk-gds.sum - pychk_sum-promo)).
              end.
              else
              vSum                     = (if    temp-chk-gds.num-lines = 1
                                            and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                          then pychk_dop-sumk
                                          else (pychk_dop-sumk * buf_temp-chk-gds.sum / temp-chk-gds.sum)
                                         )
              .
              if can-find (first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code) then do:
                  find first buf_chk-gds-pay where buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                  and buf_chk-gds-pay.algo-num = "1.8"
                  and buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
                  and buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
                  and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                  and buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
                  and buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card exclusive-lock no-error.
                  if not available buf_chk-gds-pay then do:
                     if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                     then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                     create buf_chk-gds-pay.
                  end.
              end.
              else do:
                   if can-find (first buf_chk-gds-pay no-lock where
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                               and buf_chk-gds-pay.algo-num = "1.8"
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                                   )
                   then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , buf_temp-chk-gds.line-num
                                                    , temp-chk-pay.line-num).
                   create buf_chk-gds-pay.
              end.
              assign
              buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
              buf_chk-gds-pay.chk-type = ub.chk-doc.chk-type
              buf_chk-gds-pay.algo-num = "1.8"
              buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
              buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
              buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
              buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
              buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
              buf_chk-gds-pay.tot-r-b = buf_chk-gds-pay.tot-r-b  + vSum
              buf_chk-gds-pay.eff-base-rate = pychk_exch
              buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
              buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
              buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
              buf_chk-gds-pay.price-base = buf_temp-chk-gds.price-base
              buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
              buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
              buf_chk-gds-pay.line-type = pychk_line-type-chr
              buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
              buf_chk-gds-pay.density  = buf_temp-chk-gds.density
              buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
              buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
              buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
              buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
              buf_chk-gds-pay.out-code = ub.chk-doc.out-code
              buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
              buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
              buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
              buf_temp-chk-gds.flag = yes
              .
              if buf_temp-chk-gds.line-num = vPromoLineNum
              then do:
                 buf_chk-gds-pay.eff-doc-qnty = buf_temp-chk-gds.doc-qnty.
              end.
              else
              buf_chk-gds-pay.eff-doc-qnty = (if buf_chk-gds-pay.eff-doc-qnty = ? then 0 else buf_chk-gds-pay.eff-doc-qnty) + (if (temp-chk-gds.num-lines = 1
                                              and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                              and pychk_pays_count = 1)
                                              or (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt) = 0
                                              then temp-chk-gds.doc-qnty
                                              else (vSum / (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt))
                                              )
              .
            end.
        end.
      end.
    end.
    if available temp-chk-gds then release temp-chk-gds.
    if available temp-chk-pay then release temp-chk-pay.
    pychk_zero-gds = 0.
    pychk_zero-pay = 0.
    for each temp-chk-gds where
            temp-chk-gds.doc-code = ub.chk-pay.doc-code
        and temp-chk-gds.flag = no
        and temp-chk-gds.line-num  > 0
        :
       pychk_zero-gds = pychk_zero-gds + 1.
    end.
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-pay.doc-code
        and temp-chk-pay.flag = no:
       pychk_zero-pay = pychk_zero-pay + 1.
    end.
    find first temp-chk-pay where temp-chk-pay.doc-code = ub.chk-pay.doc-code
                              and temp-chk-pay.flag = no
    no-lock no-error.
    if not available temp-chk-pay
    then do:
       block-pay:
       for each temp-chk-pay where temp-chk-pay.doc-code = ub.chk-pay.doc-code:
          assign
             pychk_zero-pay = pychk_zero-pay +  1
             temp-chk-pay.flag = no
          .
          leave block-pay.
       end.
    end.
    for each temp-chk-pay
    where   temp-chk-pay.doc-code = ub.chk-pay.doc-code
        and temp-chk-pay.flag = no:
      pychk_zero-n = 0.
      for each buf_temp-chk-gds
      where   buf_temp-chk-gds.doc-code = ub.chk-pay.doc-code
          and buf_temp-chk-gds.flag = no
          and buf_temp-chk-gds.line-num  > 0 :
        pychk_zero-n = pychk_zero-n + 1.
        if  temp-chk-pay.tot-r-b = 0 and buf_temp-chk-gds.discnt = 0 and abs(buf_temp-chk-gds.sum) > 0 then next.
        case num-entries(buf_temp-chk-gds.line-type, chr(4)):
          when 1 then do:
            pychk_line-type-chr = buf_temp-chk-gds.line-type + chr(4) + chr(4) + string(temp-chk-pay.num-lines).
          end.
          when 2 then do:
            pychk_line-type-chr = buf_temp-chk-gds.line-type +                chr(4) + string(temp-chk-pay.num-lines).
          end.
        end case.
        if can-find(first buf_chk-gds-pay no-lock where
                          buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                      and buf_chk-gds-pay.algo-num = "1.8"
                      and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                      and buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num)
        then do:
            buf_temp-chk-gds.flag = yes.
        end.
        else do:
            create buf_chk-gds-pay.
            assign
            buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
            buf_chk-gds-pay.algo-num = "1.8"
            buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
            buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
            buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
            buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
            buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
            buf_chk-gds-pay.tot-r-b = 0
            buf_chk-gds-pay.eff-base-rate = pychk_exch
            buf_chk-gds-pay.eff-doc-qnty = buf_temp-chk-gds.doc-qnty
            buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
            buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
            buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
            buf_chk-gds-pay.price-base = (if temp-chk-pay.tot-r-b = 0 and buf_temp-chk-gds.discnt = 0 then 0 else buf_temp-chk-gds.price-base)
            buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
            buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
            buf_chk-gds-pay.line-type = pychk_line-type-chr
            buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
            buf_chk-gds-pay.density  = buf_temp-chk-gds.density
            buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
            buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
            buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
            buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
            buf_chk-gds-pay.out-code = ub.chk-doc.out-code
            buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
            buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
            buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
            buf_temp-chk-gds.flag = yes
            .
        end.
        if pychk_zero-n > pychk_zero-gds / pychk_zero-pay then leave.
      end.
      temp-chk-pay.flag = yes.
    end.
  end.
end.
end.
    end.
  end.
  otherwise do:
    message
    substitute("&1&2&3Неверное значение p-caller=&4"
               ,vss-workfile
               ,vss-revision
               ,vss-description
               , p-caller)
    view-as alert-box error .
  end.
end case.
define variable v-err-msg as character no-undo .
catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
       v-err-msg = exAppErrors:GetMessage(1) .
      if v-err-msg > ""
      then v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\gbl\catcherr.i" + v-err-msg.
      else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\gbl\catcherr.i" .
    end .
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) .
    if v-err-msg > ""
    then v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\gbl\catcherr.i" + v-err-msg.
    else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\gbl\catcherr.i" .
    return error v-err-msg.
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\gbl\catcherr.i " + exAnyErrors:GetMessage(1).
    return error v-err-msg.
end catch .
