block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character        no-undo.
define variable p-auto as integer no-undo .
define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .
DEFINE variable forced as logical NO-UNDO.
define variable p-inkas-code like ub.inkas.inkas-code no-undo .
define variable vss-revision    as character no-undo init "$Revision: 18022dc3b171, 1949, rls $":u .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":u .
define variable vss-date        as character no-undo init "$Date: Fri Jul 26 11:38:58 2019 +0300 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: del-sale.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/del-sale.p $":u .
define variable vss-description as character no-undo init "Безусловное/условное удаление незакрытой продажи" .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable rsrv-title                  as character no-undo .
define variable rgds-dtl                    as recid no-undo .
define variable cashplace                   as logical no-undo .
define variable cashparts                   as logical no-undo .
define variable cashfbr                     as logical no-undo .
define variable btltaxcd                    as INTEGER                  no-undo.
define variable btltaxunittypes             as char no-undo.
DEFINE VARIABLE bottle as logical no-undo .
define variable num_rec                     as integer no-undo .
define variable num_rec_res                 as integer no-undo.
define variable num_rec_other                as integer no-undo .
define variable num_rec_other_res            as integer no-undo.
define variable cost-base                    as decimal no-undo .
define variable cost-rubl                    as decimal no-undo .
define variable r-qnty                      as decimal no-undo .
define variable r-pl-code                   as integer no-undo .
define variable r-b-code                    as integer no-undo .
define variable r-doc-prts-qnty             as decimal no-undo .
define variable r-artic                     like ub.doc-line.artic no-undo .
define variable r-prod-type                 like ub.doc-line.prod-type no-undo .
define variable r-prod-code                 like ub.doc-line.prod-code no-undo .
define variable r-prt-code                  like ub.gds-dtl.prt-code no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   temp-table tt0-info no-undo
field doc-code   like ub.trn-doc.doc-code
field artic      like ub.doc-line.artic
field prod-type  like ub.doc-line.prod-type
field prod-code  like ub.doc-line.prod-code
field prt-code  like ub.gds-dtl.prt-code
field obj-type   like ub.doc-line.obj-type
field obj-code   like ub.doc-line.obj-code
field error-message as character
field a-to-res as decimal
field was-res as decimal
field to-res as decimal
field is-res as decimal
field o-was-res as decimal
field o-to-res as decimal
field o-is-res as decimal
index pi is unique primary
obj-type
obj-code
artic
prod-type
prod-code
index iartic
artic
prod-type
prod-code
.
define   temp-table tt0-doc-line no-undo like lib-trn_ret-line.
define   temp-table tt0-gds-dtl  no-undo like ub.gds-dtl.
define   temp-table tt0-parts    no-undo like ub.parts.
define   temp-table temp-tpsi-clients  no-undo like ub.clients.
FUNCTION set-tpsi-doc-PS returns character( buffer buf_sale-doc for ub.sale-doc):
define variable v-ps as character no-undo .
assign
v-PS = substitute('@&1 для закрытия продажи &2 на &3&4&5товаров &6&5признаков &7'
                  , entry (lookup (buf_sale-doc.ext-doc-type, 'ee,ev,ie,es,iv':U), 'Межфирм.расход по ТПСИ,Внутр.расход по ТПСИ,Межфирм.приход по ТПСИ,Внутр.приход по ТПСИ':U)
                  , buf_sale-doc.out-code
                  , buf_sale-doc.obj-type
                  , buf_sale-doc.obj-code
                  , chr(4)
                  , buf_sale-doc.tot-lines
                  , buf_sale-doc.tot-dtl
                  ).
return v-Ps.
END FUNCTION.
procedure create-tt0-doc-line-gds-dtl :
define input parameter p-proprietor-obj-type like ub.trn-doc.obj-type no-undo .
define input parameter p-proprietor-obj-code like ub.trn-doc.obj-code no-undo .
define input parameter p-ext-doc-type        as character no-undo .
define input parameter p-doc-code            like ub.trn-doc.doc-code no-undo .
define input parameter p-artic               like ub.gds-dtl.artic no-undo .
define input parameter p-prod-type           like ub.gds-dtl.prod-type no-undo .
define input parameter p-prod-code           like ub.gds-dtl.prod-code no-undo .
define input parameter p-prt-code            like ub.gds-dtl.prt-code  no-undo .
define input parameter p-fact-qnty           like ub.gds-dtl.fact-qnty no-undo .
define output parameter p-was-gds-dtl-doc-qnty  like ub.gds-dtl.fact-qnty no-undo .
define output parameter p-gds-dtl-fact-qnty  like ub.gds-dtl.fact-qnty no-undo .
define parameter buffer b-doc-line           for ub.doc-line.
define parameter buffer b-gds-dtl            for ub.gds-dtl.
define parameter buffer buf_sale-doc for ub.sale-doc.
define variable old-qnty like ub.doc-line.fact-qnty no-undo .
define buffer other_doc-line for ub.doc-line.
define buffer other_gds-dtl for ub.gds-dtl.
  do
  on error undo, return error return-value
  :
    find first tt0-doc-line where
              tt0-doc-line.obj-type = p-proprietor-obj-type
          AND tt0-doc-line.obj-code = p-proprietor-obj-code
          AND tt0-doc-line.prod-type = p-prod-type
          AND tt0-doc-line.prod-code = p-prod-code
          AND tt0-doc-line.artic     = p-artic
          AND tt0-doc-line.ext-doc-type = p-ext-doc-type
          AND tt0-doc-line.status_      = 'нередакт':U no-error .
    if not available tt0-doc-line then do:
      create tt0-doc-line.
      buffer-copy b-doc-line
      except
      obj-type obj-code doc-code status_ ext-doc-type doc-qnty fact-qnty
      to tt0-doc-line
      assign
      tt0-doc-line.status_ = 'нередакт':U
      tt0-doc-line.ext-doc-type = p-ext-doc-type
      tt0-doc-line.obj-type = p-proprietor-obj-type
      tt0-doc-line.obj-code = p-proprietor-obj-code
      tt0-doc-line.doc-code = p-doc-code
      .
    end.
    if p-doc-code <> "":U then do:
      find first other_doc-line no-lock where
              other_doc-line.doc-code = p-doc-code
          AND  other_doc-line.artic    = p-artic
          AND  other_doc-line.prod-type = p-prod-type
          AND  other_doc-line.prod-code = p-prod-code no-error .
      if available other_doc-line then do:
        find first buf_sale-doc where buf_sale-doc.doc-code = other_doc-line.doc-code.
        assign
        tt0-doc-line.doc-qnty = other_doc-line.doc-qnty
        .
      end.
      else do:
        assign
        tt0-doc-line.doc-code = '':U
        .
      end.
    end.
    find first tt0-gds-dtl where
            tt0-gds-dtl.obj-type = p-proprietor-obj-type
        AND tt0-gds-dtl.obj-code = p-proprietor-obj-code
        AND tt0-gds-dtl.prod-type = p-prod-type
        AND tt0-gds-dtl.prod-code = p-prod-code
        AND tt0-gds-dtl.artic     = p-artic
        AND tt0-gds-dtl.prt-code  = p-prt-code  no-error .
    if not available tt0-gds-dtl then do:
      create tt0-gds-dtl.
      buffer-copy b-gds-dtl
      except
      obj-type obj-code doc-code doc-qnty fact-qnty
      to tt0-gds-dtl
      assign
      tt0-gds-dtl.obj-type = p-proprietor-obj-type
      tt0-gds-dtl.obj-code = p-proprietor-obj-code
      tt0-gds-dtl.doc-code = p-doc-code
      .
    end.
    if p-doc-code <> "":U then do:
        find first other_gds-dtl no-lock where
                other_gds-dtl.doc-code = p-doc-code
            AND  other_gds-dtl.artic    = p-artic
            AND  other_gds-dtl.prod-type    = p-prod-type
            AND  other_gds-dtl.prod-code    = p-prod-code
            AND  other_gds-dtl.prt-code    = p-prt-code no-error .
        if available other_gds-dtl then do:
          assign
          tt0-gds-dtl.doc-qnty = other_gds-dtl.doc-qnty
          .
        end.
        else do:
          assign
          tt0-gds-dtl.doc-code = '':U
          .
        end.
    end.
    assign
    old-qnty = tt0-gds-dtl.doc-qnty
    tt0-gds-dtl.fact-qnty = (if p-fact-qnty = ? then (- old-qnty) else (p-fact-qnty - tt0-gds-dtl.doc-qnty))
    tt0-doc-line.fact-qnty = tt0-doc-line.fact-qnty + (if p-fact-qnty = ? then (- old-qnty) else p-fact-qnty)
    p-gds-dtl-fact-qnty = tt0-gds-dtl.fact-qnty
    p-was-gds-dtl-doc-qnty = tt0-gds-dtl.doc-qnty
    .
  end.
end procedure.
procedure fill-tt-tpsi-table :
define input parameter p-doc-code  like ub.trn-doc.doc-code  no-undo .
define input parameter p-host-code like ub.trn-doc.host-code no-undo .
define input parameter p-obj-type  like ub.trn-doc.obj-type  no-undo .
define input parameter p-obj-code  like ub.trn-doc.obj-code  no-undo .
define variable v-proprietor-host-code      like ub.clients.host-code no-undo .
define variable v-proprietor-obj-type       like ub.clients.obj-type no-undo .
define variable v-proprietor-obj-code       like ub.clients.obj-code no-undo .
define variable v-ext-doc-type              like ub.trn-doc.ext-doc-type no-undo .
define variable v-gds-dtl-fact-qnty         like ub.gds-dtl.fact-qnty no-undo .
define variable v-was-gds-dtl-fact-qnty     like ub.gds-dtl.fact-qnty no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_sale-doc for ub.sale-doc.
  do
  on error undo, return error
  :
    _doc-line:
    for each buf_Doc-line no-lock where
          buf_doc-line.doc-code = p-doc-code,
      first buf_goods no-lock where
          buf_goods.artic = buf_doc-line.artic
     AND  buf_goods.prod-type  = buf_doc-line.prod-type
     AND  buf_goods.prod-code  = buf_doc-line.prod-code,
        each buf_gds-dtl no-lock where
          buf_gds-dtl.doc-code = buf_doc-line.doc-code
      AND  buf_gds-dtl.artic    = buf_doc-line.artic
      AND  buf_gds-dtl.prod-type = buf_doc-line.prod-type
      AND  buf_gds-dtl.prod-code = buf_doc-line.prod-code:
      assign
      v-ext-doc-type = "":U.
      run tpsi-preselect-gds-proprietor in this-procedure (
                                                  input buf_goods.gds-code
                                                ,input g#db-num
                                                ,output v-proprietor-host-code
                                                ,output v-proprietor-obj-type
                                                ,output v-proprietor-obj-code ) no-error .
      if v-proprietor-host-code = p-host-code then do:
        assign
        v-ext-doc-type = 'ev':U .
      end.
      else do:
        assign
        v-ext-doc-type =  'ee':U .
      end.
      if  (v-proprietor-obj-type = p-obj-type
      AND v-proprietor-obj-code = p-obj-code)
      OR (v-proprietor-obj-type = "":U
      AND v-proprietor-obj-code = 0)
      OR v-proprietor-obj-code = ?
      then next _doc-line.
      find first buf_sale-doc no-lock where
                buf_sale-doc.inkas-code = p-doc-code
           AND buf_sale-doc.obj-type = v-proprietor-obj-type
           AND buf_sale-doc.obj-code = v-proprietor-obj-code
           AND buf_sale-doc.ext-doc-type = v-ext-doc-type
           no-error .
      run create-tt0-doc-line-gds-dtl  in this-procedure (
                                                           input v-proprietor-obj-type
                                                          ,input v-proprietor-obj-code
                                                          ,input v-ext-doc-type
                                                          ,input (if available buf_sale-doc then buf_sale-doc.doc-code else "":U)
                                                          ,input buf_doc-line.artic
                                                          ,input buf_Doc-line.prod-type
                                                          ,input buf_doc-line.prod-code
                                                          ,input buf_gds-dtl.prt-code
                                                          ,input 0
                                                          ,output v-was-gds-dtl-fact-qnty
                                                          ,output v-gds-dtl-fact-qnty
                                                          ,buffer buf_doc-line
                                                          ,buffer buf_gds-dtl
                                                          ,buffer buf_sale-doc
                                                        ).
    end.
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure get-alias-type-price-obj :
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-prop-host-code like ub.sysconf.host-code no-undo .
define input parameter p-prop-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-prop-obj-code  like ub.clients.obj-code no-undo .
define output parameter p-ext-doc-type like ub.trn-doc.ext-doc-type no-undo .
define output parameter p-alias-type-price as character no-undo .
define output parameter p-price-obj-type like ub.clients.obj-type no-undo .
define output parameter p-price-obj-code like ub.clients.obj-code no-undo .
define variable v-mediat-obj-type           like ub.trn-doc.obj-type no-undo .
define variable v-mediat-obj-code           like ub.trn-doc.obj-code no-undo .
define variable v-mediat-objf               as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define buffer buf_trn-doc for ub.trn-doc.
  _main:
  do
  on error undo, return error return-value
  :
    run adm/shattri.p (
      input "get":U
      ,input  p-prop-obj-type
      ,input  p-prop-obj-code
      ,input  'alias-tpsi':U
      ,input  '':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
    if error-status:error
    then do:
      undo _main, return error substitute("Не удалось определить настройки МЕЖФИРМЕННОГО ИЛИ ВНУТРЕННЕГО ПЕРЕМЕЩЕНИЯ ЧУЖИХ ТОВАРОВ для &1&2"
                              , p-prop-obj-type
                              , p-prop-obj-code).
    end.
    find first thbjattr_thbj-attr where
              thbjattr_thbj-attr.obj-type = p-prop-obj-type
          and thbjattr_thbj-attr.obj-code = p-prop-obj-code
          and thbjattr_thbj-attr.upper-prop-code = 'alias-tpsi':U
          and thbjattr_thbj-attr.prop-code = 'alias-type-price':U no-error.
    if not available thbjattr_thbj-attr
    or thbjattr_thbj-attr.property-value-integer = 0 then do:
      undo _main, return error substitute("Не задано значение атрибута ТИП ЦЕНЫ МЕЖФИРМЕННОГО ИЛИ ВНУТРЕННЕГО ПЕРЕМЕЩЕНИЯ ЧУЖИХ ТОВАРОВ для &1&2"
                              , p-prop-obj-type
                              , p-prop-obj-code).
    end.
    assign
    p-alias-type-price = string(thbjattr_thbj-attr.property-value-integer).
    if p-prop-host-code = p-host-code
    and (p-alias-type-price = '':U
    or   p-alias-type-price <> '5':U)
    then  do:
      assign
      p-ext-doc-type = 'ev':U
      p-price-obj-type = p-obj-type
      p-price-obj-code = p-obj-code
      p-alias-type-price = '3':U
      .
    end.
    else do:
      if p-prop-host-code = p-host-code  then do:
        assign
        p-ext-doc-type = 'ev':U
        p-price-obj-type = p-obj-type
        p-price-obj-code = p-obj-code
        .
      end.
      else do:
        assign
        p-ext-doc-type = 'ee':U.
        assign
        v-mediat-obj-type = "":U
        v-mediat-obj-code = 0
        v-mediat-objf = "":U
        .
        if p-alias-type-price = '4':U then do:
          find first thbjattr_thbj-attr where
                    thbjattr_thbj-attr.obj-type = p-prop-obj-type
                and thbjattr_thbj-attr.obj-code = p-prop-obj-code
                and thbjattr_thbj-attr.upper-prop-code = 'alias-tpsi':U
                and thbjattr_thbj-attr.prop-code = 'alias-object-price':U no-error.
          if not available thbjattr_thbj-attr
          or thbjattr_thbj-attr.property-value-character = "":U then do:
            undo _main, return error substitute("Не найден объект-посредник для межфирменного перемещения ЧУЖИХ товаров с &1&2"
                                    , p-prop-obj-type
                                    , p-prop-obj-code).
          end.
          assign
          v-mediat-objf     = thbjattr_thbj-attr.property-value-character
          v-mediat-obj-type = entry(1, v-mediat-objf)
          v-mediat-obj-code = integer(entry(2, v-mediat-objf))
          no-error
          .
          if error-status:error then do:
            undo _main, return error substitute("Неверный формат атрибута ОБЪЕКТ-ПОСРЕДНИК для межфирменного перемещения ЧУЖИХ товаров для &1&2"
                                    , p-prop-obj-type
                                    , p-prop-obj-code).
          end.
        end.
        CASE p-alias-type-price:
          when '1':U then do:
            assign
            p-price-obj-type = p-prop-obj-type
            p-price-obj-code = p-prop-obj-code
            .
          end.
          when '2':U then do:
            assign
            p-price-obj-type = p-prop-obj-type
            p-price-obj-code = p-prop-obj-code
            .
          end.
          when '3':U
          or
          when '5':U
          then do:
            assign
            p-price-obj-type = p-obj-type
            p-price-obj-code = p-obj-code
            .
          end.
          when '4':U then do:
            assign
            p-price-obj-type = v-mediat-obj-type
            p-price-obj-code = v-mediat-obj-code
            .
          end.
        END CASE.
      end.
    end.
  end.
end procedure.
procedure write-tt0-info:
define input parameter p-artic as character no-undo .
define input parameter p-prod-type as character no-undo .
define input parameter p-prod-code as integer no-undo .
define input parameter p-prt-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-from-tpsi as logical no-undo .
define input parameter p-all-qnty as decimal no-undo .
define input parameter p-was-res as decimal no-undo .
define input parameter p-to-res as decimal no-undo .
define input parameter p-is-res as decimal no-undo .
define input parameter p-o-was-res as decimal no-undo .
define input parameter p-o-to-res as decimal no-undo .
define input parameter p-o-is-res as decimal no-undo .
define input parameter p-mess   as character no-undo .
define buffer buf_tt0-info for tt0-info.
  do
  on error undo, return error return-value
  :
    find first buf_tt0-info where
             buf_tt0-info.artic = p-artic
         and buf_tt0-info.prod-type = p-prod-type
         and buf_tt0-info.prod-code = p-prod-code
         and buf_tt0-info.prt-code = p-prt-code
         no-error .
    if not available buf_tt0-info then do:
      create buf_tt0-info.
      assign
      buf_tt0-info.artic = p-artic
      buf_tt0-info.prod-type = p-prod-type
      buf_tt0-info.prod-code = p-prod-code
      buf_tt0-info.prt-code  = p-prt-code
      buf_tt0-info.obj-type  = p-obj-type
      buf_tt0-info.obj-code  = p-obj-code
      buf_tt0-info.a-to-res  = ?
      buf_tt0-info.to-res    = ?
      buf_tt0-info.was-res   = ?
      buf_tt0-info.o-was-res = ?
      buf_tt0-info.o-to-res  = ?
      buf_tt0-info.o-is-res  = ?
      buf_tt0-info.is-res    = ?
      .
    end.
    assign
    buf_tt0-info.a-to-res  =
                              (if buf_tt0-info.a-to-res <> ?
                              and p-all-qnty = ?
                              then buf_tt0-info.a-to-res
                              else p-all-qnty)
    buf_tt0-info.was-res   = (if buf_tt0-info.was-res <> ?
                              and p-was-res = ?
                              then buf_tt0-info.was-res
                              else p-was-res)
    buf_tt0-info.to-res    = (if buf_tt0-info.to-res <> ?
                              and p-to-res = ?
                              then buf_tt0-info.to-res
                              else p-to-res)
    buf_tt0-info.is-res    = (if buf_tt0-info.is-res <> ?
                              and p-is-res = ?
                              then buf_tt0-info.is-res
                              else p-is-res)
    buf_tt0-info.o-was-res   = (if buf_tt0-info.o-was-res <> ?
                              and p-o-was-res = ?
                              then buf_tt0-info.o-was-res
                              else p-o-was-res)
    buf_tt0-info.o-to-res    = (if buf_tt0-info.o-to-res <> ?
                              and p-o-to-res = ?
                              then buf_tt0-info.o-to-res
                              else p-o-to-res)
    buf_tt0-info.o-is-res    = (if buf_tt0-info.o-is-res <> ?
                              and p-o-is-res = ?
                              then buf_tt0-info.o-is-res
                              else p-o-is-res)
    .
    assign
    buf_tt0-info.doc-code  = p-doc-code
    buf_tt0-info.error-message   = p-mess
    .
  end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable v-view-log as logical no-undo .
define variable v-esm as character no-undo .
define variable v-input-error as logical no-undo .
define variable v-found as character no-undo .
define variable log-file-name as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
define buffer tpsi_sale-doc for ub.sale-doc.
define buffer check_sale-doc for ub.sale-doc.
define buffer check_gds-dtl for ub.gds-dtl.
if num-entries(p-parameter, chr(4)) <> 5
then do:
  assign
  v-input-error = yes
  v-esm         = substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 5"
                             , num-entries(p-parameter, chr(4))).
  .
end.
else do:
  assign
  p-auto              = integer(entry(1, p-parameter, chr(4)))
  p-obj-type          = entry(2, p-parameter, chr(4))
  p-obj-code          = integer(entry(3, p-parameter, chr(4)))
  forced              = logical(entry(4, p-parameter, chr(4)))
  p-inkas-code        = entry(5, p-parameter, chr(4))
  no-error .
  if error-status:error then do:
    assign
    v-esm = error-status:get-message(1)
    v-input-error = yes
    .
  end.
end.
if p-auto <= 1 then do:
   log-file-name = 'saleclos.log'.
end.
else do:
   log-file-name = 'ext-sale.log'.
end.
define variable ii         as integer no-undo.
define variable const-str as char       init "Отвязано чеков и строк : " format "x(30)" no-undo.
define variable rdoc-line as recid.
define variable r-or-v as character no-undo.
define variable num_resv as int no-undo.
define variable num_resv_res as int no-undo.
define variable ser-good as logical init no.
define variable found-unres as logical init no.
define variable v-is-tpsi-obj as logical no-undo .
define variable glog as logical no-undo .
define variable autofbr as logical no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-was-gds-moving             as logical no-undo .
define variable varchip-code                as integer no-undo .
define variable varchip-code2               as integer no-undo .
define variable v-mes                       as character no-undo .
define buffer ink-doc for ub.inkas.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_c-inkas for ub.c-inkas.
define buffer buf_c-inkas-pay for ub.c-inkas-pay.
define buffer buf_c-inkas-pay-desk for ub.c-inkas-pay-desk.
define buffer buf_c-inkas-pay-wth for ub.c-inkas-pay-wth.
define buffer buf_c-sale-doc for ub.c-sale-doc.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE UNRESERV:
define input parameter p-is-tpsi-obj  as logical no-undo .
define parameter buffer buf_Inkas for ub.inkas.
DEFINE VARIABLE vat-value like ub.doc-line.vat-pc no-undo .
DEFINE VARIABLE slt-value like ub.doc-line.slt-pc no-undo .
define variable v-is-dish as character no-undo .
define variable v-run-tpsi-line as logical no-undo .
define variable v-run-tpsi      as logical no-undo .
define variable ser-good        as logical no-undo .
define variable v-msg-on as logical   no-undo .
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
assign
num_rec = 0
num_rec_res = 0
num_resv = 0
num_resv_res = 0
r-artic =      "":U
r-prod-type = "":U
r-prod-code = 0
r-prt-code = 0
.
for each tt0-info:
  delete tt0-info.
end.
if rdoc-line = -1 then do:
  assign
  v-msg-on = yes
  rdoc-line = ?.
end.
_buf_sale-doc:
for each buf_sale-doc where
       buf_sale-doc.inkas-code = buf_inkas.inkas-code
   and buf_sale-doc.order > 0
by buf_sale-doc.order:
  if buf_sale-doc.doc-kind = 'rwo':U then NEXT _BUF_sale-doc.
  if r-or-v <> ?
  and buf_sale-doc.doc-kind <> r-or-v then NEXT _BUF_sale-doc.
  FIND FIRST buf_trn-doc WHERE buf_trn-doc.doc-code = buf_sale-doc.doc-code .
.
  _doc-line:
  FOR EACH ub.doc-line WHERE
            ub.doc-line.doc-code = buf_sale-doc.doc-code EXCLUSIVE-LOCK,
    FIRST ub.goods WHERE
          ub.goods.artic = ub.doc-line.artic AND
          ub.goods.prod-type = ub.doc-line.prod-type AND
          ub.goods.prod-code = ub.doc-line.prod-code NO-LOCK :
      if buf_sale-doc.doc-kind = 'es':U then do:
        IF ub.doc-line.doc-qnty = 0 and not p-is-tpsi-obj then NEXT _doc-line.
        IF NOT (rdoc-line = ?) then do:
          if NOT recid(ub.doc-line) = rdoc-line THEN NEXT _doc-line.
          assign
          r-artic = ub.doc-line.artic
          r-prod-type = ub.doc-line.prod-type
          r-prod-code = ub.doc-line.prod-code
          .
        end.
      end.
      else do:
        IF ub.doc-line.doc-qnty = 0 then NEXT _doc-line.
        IF NOT (rdoc-line = ?)
        AND NOT recid(ub.doc-line) = rdoc-line THEN NEXT _doc-line.
     end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  buf_inkas.shift-date
  ,input  buf_inkas.host-code
  ,input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output vat-value
  ) no-error .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '2':U
  ,input  buf_inkas.shift-date
  ,input  buf_inkas.host-code
  ,input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output slt-value
  ) no-error .
      assign
      ub.doc-line.vat-pc = vat-value
      ub.doc-line.slt-pc = slt-value
      .
      IF CAN-FIND(FIRST ub.doc-pl No-LOCK WHERE
                        ub.doc-pl.out-code = ub.doc-line.doc-code AND
                        ub.doc-pl.gds-code = ub.goods.gds-code)
      then do:
          FIND FIRST ub.gds-prt NO-LOCK WHERE
                      ub.gds-prt.upper-code = ub.goods.prt-root NO-ERROR.
          cashplace = yes.
      end.
      else cashplace = no.
      IF NOT cashplace then do:
          IF CAN-FIND(FIRST ub.doc-prts No-LOCK WHERE
                            ub.doc-prts.out-code = ub.doc-line.doc-code AND
                            ub.doc-prts.gds-code = ub.goods.gds-code)
          then do:
              FIND FIRST ub.gds-prt NO-LOCK WHERE
                          ub.gds-prt.upper-code = ub.goods.prt-root NO-ERROR.
              cashparts = yes.
          end.
          else cashparts = no.
      end.
      else cashparts = no.
      FIND FIRST ub.units WHERE
                  ub.units.unit-name = ub.goods.unit-base NO-LOCK .
      if LOOKUP( 'сер':U, ub.units.type ) > 0 then  do:
          assign
          ser-good = yes.
      end.
      else do:
          ser-good = no.
      end.
      IF CAN-FIND(FIRST ub.doc-fbr-gds No-LOCK WHERE
                        ub.doc-fbr-gds.out-code = ub.doc-line.doc-code AND
                        ub.doc-fbr-gds.gds-code = ub.goods.gds-code)
      then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run fgdsobjt in g#library
  (input  ub.doc-line.obj-type
  ,input  ub.doc-line.obj-code
  ,input  ub.goods.gds-code
  ,input  'is-dish=request'
  ,output v-is-dish
  )  .
        if not error-status:error
        then assign
        cashfbr = integer(v-is-dish) > 0
        no-error .
      end.
      else cashfbr = no.
      rsrv-title = substitute("Снятие резервов. &1. Строк ", entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )).
      run RSRV-line(
                    input buf_sale-doc.dir,
                    input no,
                    input no,
                    input no,
                    input p-is-tpsi-obj,
                    input no,
                    input no,
                    input ub.goods.gds-code,
                    input (if avail ub.gds-prt then ub.gds-prt.node-code else ?),
                    output v-run-tpsi-line,
                    buffer ub.doc-line,
                    buffer buf_trn-doc,
                    buffer buf_sale-doc
                    ) no-error.
      if error-status:error then do:
        if rdoc-line <> ?
        or v-msg-on
        then do:
          .
          return error substitute("Ошибка при снятии резервов товаров:&1&2 &3"
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value ).
        end.
        else next.
      end.
      assign
      ub.doc-line.price-base = cost-base
      ub.doc-line.price-rubl = cost-rubl .
      assign
      v-run-tpsi = v-run-tpsi-line or v-run-tpsi.
  END.
  if buf_sale-doc.doc-kind = 'es':U then do:
    .
    if p-is-tpsi-obj
    and v-run-tpsi
    then do:
    .
      run str/tpsirsrv.p (
                      input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input p-auto
                      ,input v-curr-r-b
                      ,input buf_inkas.inkas-code
                      ,input buf_trn-doc.host-code
                      ,input buf_trn-doc.obj-type
                      ,input buf_trn-doc.obj-code
                      ,input r-artic
                      ,input r-prod-type
                      ,input r-prod-code
                      ,input r-prt-code
                      ,input no
                      ,input "Снятие резеров ЧУЖИХ товаров. Расход. Строк "
                      ,input-output num_rec_res
                      ,output num_rec_other
                      ,output num_rec_other_res
                      ,buffer buf_trn-doc
                    ) no-error .
      if error-status:error then do:
        .
        if rdoc-line <> ? then do:
        return error substitute("Ошибка при снятии резервов ЧУЖИХ товаров:&1&2 &3"
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value ).
        end.
      end.
      .
    end.
  end.
  assign
  num_resv = num_resv + num_rec
  num_resv_res = num_resv_res + num_rec_res
  num_rec = 0
  num_rec_res = 0
  .
  .
  release buf_trn-doc.
end.
END PROCEDURE.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE RSRv-line:
define input parameter p-r-v                as integer no-undo .
define input parameter p-auto-fbr           as logical no-undo .
define input parameter p-rsrv-prop-goods    as logical no-undo .
define input parameter p-auto-fbr-on        as logical no-undo .
define variable p-rest-dish                 as logical no-undo .
define variable p-fbr-income-doc-code       like ub.trn-doc.doc-code no-undo.
define input parameter p-tpsi-obj           as logical no-undo .
define input parameter p-rest-tpsi          as logical no-undo .
DEFINE INPUT PARAMETER rz                   as logical no-undo.
DEFINE INPUT PARAMETER gdscode              like ub.goods.gds-code.
DEFINE INPUT PARAMETER nodecode             like ub.gds-prt.node-code.
define output parameter p-run-tpsi          as logical no-undo .
DEFINE parameter buffer b-doc-line for ub.doc-line.
DEFINE parameter buffer b-trn-doc for ub.trn-doc.
define parameter buffer buf_sale-doc for ub.sale-doc.
define buffer loc-doc-prts for ub.doc-prts.
define buffer loc-doc-pl for ub.doc-pl.
define buffer loc-doc-fbr-gds for ub.doc-fbr-gds.
DEFINE BUFFER loc-gds-dtl for ub.gds-dtl.
define buffer buf_parts for ub.parts .
define buffer other_doc-line for ub.doc-line.
define buffer other_gds-dtl  for ub.gds-dtl.
define buffer buf_doc-fbr-gds for ub.doc-fbr-gds .
define variable res-qnty                    as decimal no-undo.
define variable gds-dtl-res-qnty            as decimal no-undo.
define variable no-partion-qnty             as decimal no-undo.
define variable no-place-qnty               as decimal no-undo.
define variable res-parts                   as decimal no-undo.
define variable ser-chg-qnty                as decimal no-undo.
define variable pl-chg-qnty                 as decimal no-undo.
define variable pl-chg-cli-qnty             as decimal no-undo.
define variable old-pl-qnty                 as decimal no-undo.
define variable new-pl-qnty                 as decimal no-undo.
define variable chg-qnty                    as decimal no-undo.
define variable fbr-qnty                    as decimal no-undo .
define variable fbr-chg-qnty                as decimal no-undo .
define variable parts-OK                    as logical no-undo init yes.
define variable place-OK                    as logical no-undo init yes.
define variable rsrv-option                 as character no-undo.
define variable rsrv-option-place           as character no-undo.
define variable v-proprietor-host-code      like ub.clients.host-code no-undo .
define variable v-proprietor-obj-type       like ub.clients.obj-type no-undo .
define variable v-proprietor-obj-code       like ub.clients.obj-code no-undo .
define variable v-is-own                    as logical no-undo .
define variable v-to-reserv                 as logical no-undo .
define variable v-ext-doc-type              like ub.trn-doc.ext-doc-type no-undo .
define variable v-gds-dtl-fact-qnty         like ub.gds-dtl.fact-qnty no-undo .
define variable v-was-gds-dtl-doc-qnty      like ub.gds-dtl.fact-qnty no-undo .
define variable v-return-st-fl              as logical no-undo .
define variable v-return-status             like ub.trn-doc.status_ no-undo .
define variable v-return-flag               like ub.trn-doc.flag    no-undo .
define variable v-dop-sale-negative-check   as character no-undo .
define variable v-nc-option                 as character no-undo .
define variable current-rgds-dtl            as recid no-undo .
define variable v-qnty                      as decimal no-undo .
define variable v-cli-qnty                  as decimal no-undo .
define variable v-err-msg                   as character no-undo .
define buffer tpsi_sale-doc for ub.sale-doc.
define buffer buf_tt0-gds-dtl for tt0-gds-dtl.
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
  if not rz and v-dop-sale-negative-check = '':U then v-dop-sale-negative-check = ',' + 'negative-check':U + "=1".
if not p-rsrv-prop-goods
AND (p-tpsi-obj
and p-r-v = 1
and not cashplace
and not cashparts
and not b-trn-doc.office)
then do:
  run tpsi-gds-proprietor in this-procedure (
                                              input gdscode
                                             ,input g#db-num
                                             ,output v-proprietor-host-code
                                             ,output v-proprietor-obj-type
                                             ,output v-proprietor-obj-code ) no-error .
  if error-status:error then do:
    num_rec = num_rec + 1.
    undo, return error substitute("Ошибки при проверке атрибута товара на объекте ПРИНАДЛЕЖНОСТЬ ТОВАРА для товара с кодом &1 на БД &2:&3&4 &5"
                                  ,gdscode
                                  ,g#db-num
                                  , chr(10)
                                  , error-status:get-message(1)
                                  , return-value
                                  ).
  end.
  if (v-proprietor-obj-type = "":U
      and
      v-proprietor-obj-code = 0)
  or v-proprietor-obj-code = ?
      then do:
    num_rec = num_rec + 1.
    undo, return error substitute("Не установлен атрибут товара на объекте ПРИНАДЛЕЖНОСТЬ ТОВАРА для товара с кодом &1 ни для одного объекта БД &2"
                                  ,gdscode
                                  ,g#db-num
                                  ).
  end.
  if (v-proprietor-obj-type = b-trn-doc.obj-type
  and v-proprietor-obj-code = b-trn-doc.obj-code)
  then do:
    assign
    v-is-own = yes
    .
  end.
  else do:
    assign
    p-run-tpsi = yes.
    if v-proprietor-host-code = v-host-code then do:
      assign
      v-ext-doc-type = 'ev':U .
    end.
    else do:
      assign
      v-ext-doc-type =  'ee':U .
    end.
    find first tpsi_sale-doc no-lock where
              tpsi_sale-doc.inkas-code = buf_sale-doc.inkas-code
          and tpsi_sale-doc.tpsidoc = yes
          and tpsi_sale-doc.obj-type = v-proprietor-obj-type
          AND tpsi_sale-doc.obj-code = v-proprietor-obj-code
          AND tpsi_sale-doc.ext-doc-type = v-ext-doc-type  no-error .
   end.
end.
else v-is-own = yes.
if v-is-own then do:
  assign
  v-to-reserv = yes
  rsrv-option = (if (rgds-dtl = ?) and not p-auto-fbr
                  then 'reserv':U  + ',' + 'no-message':U
                  else 'reserv':U
                  )
  + v-dop-sale-negative-check
  .
  if cashfbr and p-auto-fbr-on and rz and not p-auto-fbr then return.
end.
else do:
  assign
  cashfbr = no.
  if p-rest-tpsi or rz = no then do:
    assign
    v-nc-option = "=2":U.
    assign
    v-to-reserv = yes
    rsrv-option = (if (rgds-dtl = ?) and not p-auto-fbr
                    then 'reserv':U  + ',' + 'no-message':U + ',' + 'negative-check':U + v-nc-option
                    else 'reserv':U  + ',' + 'negative-check':U + v-nc-option
                    )
    .
    if p-rest-tpsi then do:
      assign
      rsrv-option = rsrv-option + ',' + 'sale-negative-check-on':u
      .
    end.
  end.
end.
if cashfbr
and (not p-rest-dish)
and p-auto-fbr-on and rz
and p-fbr-income-doc-code <> "":U
then do:
  _parts:
  for each buf_parts no-lock
      where buf_parts.obj-type  = b-trn-doc.obj-type
        and buf_parts.obj-code  = b-trn-doc.obj-code
        and buf_parts.prod-type = b-doc-line.prod-type
        and buf_parts.prod-code = b-doc-line.prod-code
        and buf_parts.artic     = b-doc-line.artic
        and buf_parts.status_   = yes
        and buf_parts.out-code  = p-fbr-income-doc-code
  on error undo, return error return-value
    :
    assign
    rsrv-option = 'reserv':U
                    + "," + 'rsrv-single-part':U
                    + "," + 'rsrv-in-code':U   + "=":u + str-encode ( buf_parts.in-code  ,  "", ",=":u )
                    + "," + 'rsrv-part-code':U + "=":u + str-encode ( buf_parts.part-code,  "", ",=":u )
    .
    leave _parts.
  end.
end.
if cashplace then do:
  FIND FIRST loc-gds-dtl WHERE
          loc-gds-dtl.doc-code = b-trn-doc.doc-code AND
          loc-gds-dtl.artic = b-doc-line.artic AND
          loc-gds-dtl.prod-type = b-doc-line.prod-type AND
          loc-gds-dtl.prod-code = b-doc-line.prod-code AND
          loc-gds-dtl.prt-code = nodecode
          EXCLUSIVE-LOCK NO-ERROR.
  IF rz  and loc-gds-dtl.fact-qnty <= loc-gds-dtl.doc-qnty then LEAVE.
  IF NOT rz and loc-gds-dtl.doc-qnty = 0 then LEAVE.
  IF NOT (rgds-dtl = ?) AND NOT recid(loc-gds-dtl) = rgds-dtl THEN LEAVE.
  if ( num_rec modulo 10 ) = 0 then
.
  if rz then
  find first buf_tt0-gds-dtl no-lock where
            buf_tt0-gds-dtl.artic = loc-gds-dtl.artic
       AND  buf_tt0-gds-dtl.prod-type = loc-gds-dtl.prod-type
       AND  buf_tt0-gds-dtl.prod-code = loc-gds-dtl.prod-code
       AND  buf_tt0-gds-dtl.prt-code  = loc-gds-dtl.prt-code no-error .
  assign
  chg-qnty   = 0.0
  res-qnty   = 0.0
  cost-base  = 0.0
  cost-rubl  = 0.0
  v-qnty     = 0.0
  v-cli-qnty = 0.0
  gds-dtl-res-qnty = if rz
                    then ((loc-gds-dtl.fact-qnty - loc-gds-dtl.doc-qnty) + (if available buf_tt0-gds-dtl
                                                                            then (buf_tt0-gds-dtl.fact-qnty - buf_tt0-gds-dtl.doc-qnty)
                                                                            else 0))
                    else (if r-qnty = ?
                          then (- loc-gds-dtl.doc-qnty)
                          else r-qnty)
  .
  _docpl:
  FOR EACH loc-doc-pl where
            loc-doc-pl.gds-code = gdscode AND
            loc-doc-pl.out-code = b-doc-line.doc-code ON ERROR UNDO, NEXT:
    assign
    v-qnty                  = v-qnty + loc-doc-pl.doc-qnty
    v-cli-qnty              = v-cli-qnty + loc-doc-pl.cli-doc-qnty
    .
    if rz and loc-doc-pl.fact-qnty <= loc-doc-pl.doc-qnty then NEXT.
    if not rz and loc-doc-pl.doc-qnty = 0 then NEXT.
    if NOT r-pl-code = ? AND r-pl-code <> loc-doc-pl.pl-code then NEXT.
    assign
    v-err-msg       = "":U
    pl-chg-qnty     = (if rz then loc-doc-pl.fact-qnty     else 0.0 ) - loc-doc-pl.doc-qnty
    pl-chg-cli-qnty = (if rz then loc-doc-pl.cli-fact-qnty else 0.0 ) - loc-doc-pl.cli-doc-qnty
    res-qnty = res-qnty + pl-chg-qnty
    no-partion-qnty = gds-dtl-res-qnty - res-qnty
    cost-base = 0
    cost-rubl = 0
    rsrv-option-place = rsrv-option + "," + 'plcode':U + "=" + string(loc-doc-pl.pl-code)
    .
    if b-trn-doc.status_ = 'нередакт':U
    or b-trn-doc.flag <> no
    then do:
      assign
      v-return-status =  b-trn-doc.status_
      v-return-flag = b-trn-doc.flag
      b-trn-doc.status_ = 'накл':U
      b-trn-doc.flag = no
      v-return-st-fl = yes
      .
    end.
    if not (is-gas(gdscode) and buf_sale-doc.doc-kind <> 'rs':U)
    then do :
      if recid(loc-gds-dtl) <> current-rgds-dtl then assign num_rec = num_rec + 1 current-rgds-dtl = recid(loc-gds-dtl).
    end.
    assign
      old-pl-qnty = (- loc-doc-pl.doc-qnty)
    .
    if old-pl-qnty <> 0.0 then do:
      run trg/rsrv-dtl.p (
                      input parparentproc
                      ,input rsrv-option-place
                      ,buffer loc-gds-dtl
                      ,input-output old-pl-qnty
                      ,input-output cost-base
                      ,input-output cost-rubl
                      ,-1, "" ) no-error.
      if error-status :error then do:
        assign
        v-err-msg = substitute( "Ошибка при разрезервировании.&1&2"
                               , chr(10)
                               , return-value
                              )
        .
      end.
      else do:
        if old-pl-qnty <> (- loc-doc-pl.doc-qnty) then do:
          assign
          v-err-msg = substitute( "Не удалось снять резервы по ранее зарезервированному количеству.&1Запрошено: &2&1Удалось разрезервировать: &3&1"
                                , chr(10)
                                , (- loc-doc-pl.doc-qnty)
                                , old-pl-qnty
                                )
          .
        end.
      end.
      if v-err-msg <> "":U then do:
        v-return-st-fl = no.
        undo _docpl, NEXT.
      end.
    end.
    assign
    loc-doc-pl.doc-qnty     = loc-doc-pl.doc-qnty     + pl-chg-qnty
    loc-doc-pl.cli-doc-qnty = loc-doc-pl.cli-doc-qnty + pl-chg-cli-qnty
    loc-doc-pl.cli-qnty     = loc-doc-pl.cli-doc-qnty
    new-pl-qnty             = loc-doc-pl.doc-qnty
    v-qnty                  = v-qnty + pl-chg-qnty
    v-cli-qnty              = v-cli-qnty + pl-chg-cli-qnty
    .
    if new-pl-qnty <> 0.0 then do:
      run trg/rsrv-dtl.p (
                      input parparentproc
                      ,input rsrv-option-place
                      ,buffer loc-gds-dtl
                      ,input-output new-pl-qnty
                      ,input-output cost-base
                      ,input-output cost-rubl
                      ,-1
                      ,"") no-error.
      if error-status :error then do:
        assign
        v-err-msg = substitute( "Ошибка при резервировании.&1&2"
                              , chr(10)
                              , return-value
                              )
        .
      end.
      else do:
        if new-pl-qnty <> loc-doc-pl.doc-qnty then do:
          assign
          v-err-msg = substitute( "Не удалось зарезервировать все запрошенное количество.&1Запрошено: &2&1Удалось разрезервировать: &3&1"
                                , chr(10)
                                , loc-doc-pl.doc-qnty - old-pl-qnty
                                , new-pl-qnty - old-pl-qnty
                                )
          .
        end.
      end.
      if v-err-msg <> "":U then do:
        v-return-st-fl = no.
        undo _docpl, NEXT.
      end.
    end.
    if v-return-st-fl then do:
      assign
      b-trn-doc.status_ = v-return-status
      b-trn-doc.flag = v-return-flag
      v-return-st-fl = no
      .
    end.
    assign
    chg-qnty = chg-qnty + pl-chg-qnty
    .
  END.
  if v-qnty <> 0.0
    and v-cli-qnty <> 0.0
  then do:
    assign
    b-doc-line.doc-density = v-cli-qnty / v-qnty
    .
  end.
  if chg-qnty <> 0 then  do:
      assign
      loc-gds-dtl.doc-qnty = loc-gds-dtl.doc-qnty + chg-qnty
      b-doc-line.doc-qnty = b-doc-line.doc-qnty + chg-qnty
      buf_sale-doc.doc-qnty = buf_sale-doc.doc-qnty  + chg-qnty
      b-trn-doc.doc-qnty = b-trn-doc.doc-qnty  + chg-qnty
      b-doc-line.cli-qnty = v-cli-qnty
      .
      if (loc-gds-dtl.doc-qnty = loc-gds-dtl.fact-qnty and rz) or                           (loc-gds-dtl.doc-qnty = 0 and not  rz)  then do: assign num_rec_res = num_rec_res + 1. end.
      if bottle then do:
assign
  price-rubl-with-tax-loc = b-doc-line.price-rubl
  price-base-with-tax-loc = b-doc-line.price-base
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = b-trn-doc.doc-code
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
   find first in-vatp-goods where in-vatp-goods.artic     = b-doc-line.artic     and
                                     in-vatp-goods.prod-type = b-doc-line.prod-type and
                                     in-vatp-goods.prod-code = b-doc-line.prod-code no-lock.
   if (not b-trn-doc.internal and
           b-trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = b-doc-line.road-tax
          road-tax-rubl-loc = b-doc-line.road-tax * b-trn-doc.base-rate / b-trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = b-doc-line.road-tax
          road-tax-base-loc = b-doc-line.road-tax / b-trn-doc.base-rate * b-trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if b-doc-line.transport-base = ? then 0 else b-doc-line.transport-base)
        transport-rubl-loc = (if b-doc-line.transport-rubl = ? then 0 else b-doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if b-doc-line.other-base     = ? then 0 else b-doc-line.other-base)
        other-rubl-loc     = (if b-doc-line.other-rubl     = ? then 0 else b-doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if b-doc-line.vat-pc         = ? then 0 else b-doc-line.vat-pc)
        slt-pc-loc         = (if b-doc-line.slt-pc         = ? then 0 else b-doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = b-doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = b-doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = b-doc-line.obj-code  and
                                      in-vatp-parts.artic     = b-doc-line.artic     and
                                      in-vatp-parts.prod-type = b-doc-line.prod-type and
                                      in-vatp-parts.prod-code = b-doc-line.prod-code
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
        road-tax-base-loc   = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        transport-base-loc  = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        transport-rubl-loc  = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        other-base-loc      = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        other-rubl-loc      = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
                                        vat-base-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b-doc-line.fact-qnty   else 0
        slt-base-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b-doc-line.fact-qnty   else 0
                vat-rubl-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b-doc-line.fact-qnty   else 0
        slt-rubl-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b-doc-line.fact-qnty   else 0
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
        b-doc-line.road-tax = (if v-curr-r-b = 'rubl':U then road-tax-rubl-loc else road-tax-base-loc).
      end.
      if rz then do:
        if b-trn-doc.print-rubl then
        assign
        loc-gds-dtl.price-base = loc-gds-dtl.price-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
        loc-gds-dtl.discnt-base = loc-gds-dtl.discnt-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
        loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-rubl = 0
                                 then 0
                                 else loc-gds-dtl.discnt-rubl * 100 / loc-gds-dtl.price-rubl) .
        else
        assign
        loc-gds-dtl.price-rubl = loc-gds-dtl.price-base * b-trn-doc.base-rate / b-trn-doc.base-scale
        loc-gds-dtl.discnt-rubl = loc-gds-dtl.discnt-base * b-trn-doc.base-rate / b-trn-doc.base-scale
        loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-base = 0
                                 then 0
                                 else loc-gds-dtl.discnt-base * 100 / loc-gds-dtl.price-base) .
      end.
    end.
    if chg-qnty = res-qnty then place-ok = yes.
    else place-ok = no.
    release loc-gds-dtl.
    if no-place-qnty = 0 then return.
  end.
  if NOT cashplace AND cashparts then do:
    FIND FIRST loc-gds-dtl WHERE
              loc-gds-dtl.doc-code = b-trn-doc.doc-code AND
              loc-gds-dtl.artic = b-doc-line.artic AND
              loc-gds-dtl.prod-type = b-doc-line.prod-type AND
              loc-gds-dtl.prod-code = b-doc-line.prod-code AND
              loc-gds-dtl.prt-code = nodecode
              EXCLUSIVE-LOCK NO-ERROR.
    IF rz  and loc-gds-dtl.fact-qnty <= loc-gds-dtl.doc-qnty then LEAVE.
    IF NOT rz and loc-gds-dtl.doc-qnty = 0 then LEAVE.
    IF NOT (rgds-dtl = ?) AND NOT recid(loc-gds-dtl) = rgds-dtl THEN LEAVE.
  if ( num_rec modulo 10 ) = 0 then
.
    assign
    chg-qnty = 0
    res-qnty = 0
    cost-base = 0
    cost-rubl = 0
    gds-dtl-res-qnty = if rz
                        then (loc-gds-dtl.fact-qnty - loc-gds-dtl.doc-qnty)
                        else (if r-qnty = ?
                              then (- loc-gds-dtl.doc-qnty)
                              else r-qnty)
    .
    _docprts:
    FOR EACH loc-doc-prts where
            loc-doc-prts.gds-code = gdscode AND
            loc-doc-prts.out-code = b-doc-line.doc-code ON ERROR UNDO, NEXT:
      if rz and loc-doc-prts.fact-qnty <= loc-doc-prts.doc-qnty then NEXT.
      if not rz and loc-doc-prts.doc-qnty = 0 then NEXT.
      if NOT r-b-code = ? AND r-b-code <> loc-doc-prts.b-code then NEXT.
      if NOT r-doc-prts-qnty = ? AND r-doc-prts-qnty <> loc-doc-prts.fact-qnty then NEXT.
      assign
      res-parts = if rz
                  then loc-doc-prts.doc-qnty
                  else (if r-qnty = ?
                        then (- loc-doc-prts.doc-qnty)
                        else r-qnty)
      ser-chg-qnty = if rz
                      then loc-doc-prts.fact-qnty - res-parts
                      else (if r-qnty = ?
                            then (- loc-doc-prts.doc-qnty)
                            else r-qnty)
      res-qnty = res-qnty + ser-chg-qnty
      no-partion-qnty = gds-dtl-res-qnty - res-qnty
      cost-base = 0
      cost-rubl = 0
      .
      if b-trn-doc.status_ = 'нередакт':U
      or b-trn-doc.flag <> no
      then do:
        assign
        v-return-status =  b-trn-doc.status_
        v-return-flag = b-trn-doc.flag
        b-trn-doc.status_ = 'накл':U
        b-trn-doc.flag = no
        v-return-st-fl = yes
        .
      end.
      if not (is-gas(gdscode) and buf_sale-doc.doc-kind <> 'rs':U)
      then do :
        if recid(loc-gds-dtl) <> current-rgds-dtl then assign num_rec = num_rec + 1 current-rgds-dtl = recid(loc-gds-dtl).
      end.
      run trg/rsrv-dtl.p (
                         input parparentproc
                        ,input rsrv-option
                        ,buffer loc-gds-dtl
                        ,input-output ser-chg-qnty
                        ,input-output cost-base
                        ,input-output cost-rubl
                        ,input (if loc-doc-prts.b-code < 0 then ? else loc-doc-prts.b-code)
                        , "" ) no-error.
      if error-status:error then  do:
        v-return-st-fl = no.
        undo _docprts, NEXT.
      end.
      if v-return-st-fl then do:
        assign
        b-trn-doc.status_ = v-return-status
        b-trn-doc.flag = v-return-flag
        v-return-st-fl = no
        .
      end.
      assign
      chg-qnty = chg-qnty + ser-chg-qnty
      loc-doc-prts.doc-qnty = loc-doc-prts.doc-qnty + ser-chg-qnty
      .
      if r-doc-prts-qnty <> ? and r-b-code = ? then LEAVE.
    END.
    if chg-qnty <> 0 then  do:
      assign
      loc-gds-dtl.doc-qnty = loc-gds-dtl.doc-qnty + chg-qnty
      b-doc-line.doc-qnty = b-doc-line.doc-qnty + chg-qnty
      buf_sale-doc.doc-qnty = buf_sale-doc.doc-qnty  + chg-qnty
      b-trn-doc.doc-qnty = b-trn-doc.doc-qnty  + chg-qnty
      .
      if (loc-gds-dtl.doc-qnty = loc-gds-dtl.fact-qnty and rz) or                           (loc-gds-dtl.doc-qnty = 0 and not  rz)  then do: assign num_rec_res = num_rec_res + 1. end.
      if bottle then do:
assign
  price-rubl-with-tax-loc = b-doc-line.price-rubl
  price-base-with-tax-loc = b-doc-line.price-base
.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = b-trn-doc.doc-code
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
   find first in-vatp-goods where in-vatp-goods.artic     = b-doc-line.artic     and
                                     in-vatp-goods.prod-type = b-doc-line.prod-type and
                                     in-vatp-goods.prod-code = b-doc-line.prod-code no-lock.
   if (not b-trn-doc.internal and
           b-trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = b-doc-line.road-tax
          road-tax-rubl-loc = b-doc-line.road-tax * b-trn-doc.base-rate / b-trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = b-doc-line.road-tax
          road-tax-base-loc = b-doc-line.road-tax / b-trn-doc.base-rate * b-trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if b-doc-line.transport-base = ? then 0 else b-doc-line.transport-base)
        transport-rubl-loc = (if b-doc-line.transport-rubl = ? then 0 else b-doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if b-doc-line.other-base     = ? then 0 else b-doc-line.other-base)
        other-rubl-loc     = (if b-doc-line.other-rubl     = ? then 0 else b-doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if b-doc-line.vat-pc         = ? then 0 else b-doc-line.vat-pc)
        slt-pc-loc         = (if b-doc-line.slt-pc         = ? then 0 else b-doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = b-doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = b-doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = b-doc-line.obj-code  and
                                      in-vatp-parts.artic     = b-doc-line.artic     and
                                      in-vatp-parts.prod-type = b-doc-line.prod-type and
                                      in-vatp-parts.prod-code = b-doc-line.prod-code
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
        road-tax-base-loc   = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        transport-base-loc  = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        transport-rubl-loc  = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        other-base-loc      = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        other-rubl-loc      = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
                                        vat-base-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b-doc-line.fact-qnty   else 0
        slt-base-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b-doc-line.fact-qnty   else 0
                vat-rubl-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b-doc-line.fact-qnty   else 0
        slt-rubl-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b-doc-line.fact-qnty   else 0
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
        b-doc-line.road-tax = (if v-curr-r-b = 'rubl':U then road-tax-rubl-loc else road-tax-base-loc).
      end.
      if rz then do:
        if b-trn-doc.print-rubl
        then assign
          loc-gds-dtl.price-base = loc-gds-dtl.price-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
          loc-gds-dtl.discnt-base = loc-gds-dtl.discnt-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
          loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-rubl = 0
                                   then 0
                                   else loc-gds-dtl.discnt-rubl * 100 / loc-gds-dtl.price-rubl) .
        else
        assign
        loc-gds-dtl.price-rubl = loc-gds-dtl.price-base * b-trn-doc.base-rate / b-trn-doc.base-scale
        loc-gds-dtl.discnt-rubl = loc-gds-dtl.discnt-base * b-trn-doc.base-rate / b-trn-doc.base-scale
        loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-base = 0
                                 then 0
                                 else loc-gds-dtl.discnt-base * 100 / loc-gds-dtl.price-base ).
      end.
    end.
    if chg-qnty = res-qnty
    then parts-ok = yes.
    else parts-ok = no.
    release loc-gds-dtl.
    if no-partion-qnty = 0 then return.
  end.
  if not cashparts or no-partion-qnty <> 0 or NOT cashplace OR no-place-qnty <> 0 then do:
  if cashplace then no-partion-qnty = no-place-qnty.
  _gdsdtl:
  FOR EACH loc-gds-dtl WHERE
          loc-gds-dtl.doc-code = b-trn-doc.doc-code AND
          loc-gds-dtl.artic = b-doc-line.artic AND
          loc-gds-dtl.prod-type = b-doc-line.prod-type AND
          loc-gds-dtl.prod-code = b-doc-line.prod-code
          EXCLUSIVE-LOCK ON ERROR UNDO, NEXT:
    IF rz AND loc-gds-dtl.fact-qnty <= loc-gds-dtl.doc-qnty then NEXT.
    IF not rz AND loc-gds-dtl.doc-qnty = 0 AND v-is-own then NEXT.
    IF NOT (rgds-dtl = ?) then do:
      if NOT recid(loc-gds-dtl) = rgds-dtl THEN NEXT.
      assign
      r-prt-code = loc-gds-dtl.prt-code.
    end.
if ( num_rec modulo 10 ) = 0 then
.
    assign
    res-qnty = if cashparts
                then (if rz
                      then no-partion-qnty
                      else (if r-qnty = ?
                            then (- loc-gds-dtl.doc-qnty)
                            else no-partion-qnty)
                      )
                else (if rz
                      then (loc-gds-dtl.fact-qnty - loc-gds-dtl.doc-qnty)
                      else (if r-qnty = ?
                            then (- loc-gds-dtl.doc-qnty)
                            else r-qnty
                            )
                      )
    chg-qnty = res-qnty
    cost-base = 0
    cost-rubl = 0 .
    if not v-is-own and rz then do:
      find first buf_tt0-gds-dtl no-lock where
                buf_tt0-gds-dtl.artic     = loc-gds-dtl.artic
            AND buf_tt0-gds-dtl.prod-type = loc-gds-dtl.prod-type
            AND buf_tt0-gds-dtl.prod-code = loc-gds-dtl.prod-code
            AND buf_tt0-gds-dtl.prt-code = loc-gds-dtl.prt-code no-error .
      if available buf_tt0-gds-dtl then do:
        assign
        chg-qnty = chg-qnty - buf_tt0-gds-dtl.doc-qnty.
      end.
    end.
    if not v-is-own and not rz and chg-qnty = 0 then
    assign
    v-to-reserv = no
    .
    if not v-is-own
    and rz
    and (available buf_tt0-gds-dtl and (buf_tt0-gds-dtl.doc-qnty + loc-gds-dtl.doc-qnty) = loc-gds-dtl.fact-qnty)
    then
    assign
    v-to-reserv = no
    .
    if p-auto-fbr-on
    then do :
      find first goods no-lock where goods.artic = loc-gds-dtl.artic
                                 and goods.prod-type = loc-gds-dtl.prod-type
                                 and goods.prod-code = loc-gds-dtl.prod-code
                                 .
      if b-trn-doc.ext-doc-type =  'rs':U
      then do :
        find first buf_doc-fbr-gds no-lock where buf_doc-fbr-gds.out-code = replace(loc-gds-dtl.doc-code, "=", "-")
                                             and buf_doc-fbr-gds.gds-code = goods.gds-code
                                             no-error .
        if available buf_doc-fbr-gds
        then do :
          if buf_doc-fbr-gds.fact-qnty > 0
          then do :
            assign
              v-to-reserv = no
            .
          end.
          else do :
            chg-qnty = if res-qnty >= 0 then abs(buf_doc-fbr-gds.fact-qnty) else buf_doc-fbr-gds.fact-qnty.
          end.
        end.
      end.
      if b-trn-doc.ext-doc-type =  'es':U
      then do :
        find first buf_doc-fbr-gds no-lock where buf_doc-fbr-gds.out-code = loc-gds-dtl.doc-code
                                             and buf_doc-fbr-gds.gds-code = goods.gds-code
                                             no-error .
        if available buf_doc-fbr-gds
        then do :
          if buf_doc-fbr-gds.fact-qnty >= 0
          then do :
            chg-qnty = if res-qnty >= 0 then buf_doc-fbr-gds.fact-qnty else - buf_doc-fbr-gds.fact-qnty .
          end.
          else do :
            assign
              v-to-reserv = no
            .
          end.
        end.
      end.
    end.
    if v-to-reserv and chg-qnty <> 0 then do:
      if b-trn-doc.status_ = 'нередакт':U
      or b-trn-doc.flag <> no
      then do:
        assign
        v-return-status =  b-trn-doc.status_
        v-return-flag = b-trn-doc.flag
        b-trn-doc.status_ = 'накл':U
        b-trn-doc.flag = no
        v-return-st-fl = yes
        .
      end.
      if not (is-gas(gdscode) and buf_sale-doc.doc-kind <> 'rs':U)
      then do :
        if recid(loc-gds-dtl) <> current-rgds-dtl then assign num_rec = num_rec + 1 current-rgds-dtl = recid(loc-gds-dtl).
      end.
      run trg/rsrv-dtl.p (
                       input parparentproc
                      ,input rsrv-option
                      ,buffer loc-gds-dtl
                      ,input-output chg-qnty
                      ,input-output cost-base
                      ,input-output cost-rubl
                      , -1
                      , "" ) no-error.
      if error-status:error then  do:
        v-return-st-fl = no.
        undo _gdsdtl, NEXT.
      end.
    if v-return-st-fl then do:
      assign
      b-trn-doc.status_ = v-return-status
      b-trn-doc.flag = v-return-flag
      v-return-st-fl = no
      .
    end.
      if cashfbr then do:
        assign
        fbr-qnty = chg-qnty
        .
        _fbr:
        for each loc-doc-fbr-gds where
                loc-doc-fbr-gds.gds-code = gdscode:
          assign
          fbr-chg-qnty = min(loc-doc-fbr-gds.fact-qnty - loc-doc-fbr-gds.doc-qnty, fbr-qnty)
          fbr-qnty = fbr-qnty - fbr-chg-qnty
          loc-doc-fbr-gds.doc-qnty = loc-doc-fbr-gds.doc-qnty + fbr-chg-qnty
          .
          if fbr-qnty = 0 then do:
              leave _fbR.
          end.
        end.
      end.
      assign
      loc-gds-dtl.doc-qnty = loc-gds-dtl.doc-qnty + chg-qnty
      b-doc-line.doc-qnty = b-doc-line.doc-qnty + chg-qnty
      buf_sale-doc.doc-qnty = buf_sale-doc.doc-qnty  + chg-qnty
      b-trn-doc.doc-qnty = b-trn-doc.doc-qnty  + chg-qnty
      .
      if available buf_doc-fbr-gds
      then do :
        if rz then do :
          if buf_doc-fbr-gds.fact-qnty > 0
          then do :
            if loc-gds-dtl.doc-qnty = buf_doc-fbr-gds.fact-qnty then assign num_rec_res = num_rec_res + 1 .
          end.
          else
          if buf_doc-fbr-gds.fact-qnty < 0
          then do :
            if loc-gds-dtl.doc-qnty = - buf_doc-fbr-gds.fact-qnty then assign num_rec_res = num_rec_res + 1 .
          end.
          else do :
            if (loc-gds-dtl.doc-qnty = loc-gds-dtl.fact-qnty and rz) or                           (loc-gds-dtl.doc-qnty = 0 and not  rz)  then do: assign num_rec_res = num_rec_res + 1. end.
          end.
        end.
        else do :
          if loc-gds-dtl.doc-qnty = 0 then assign num_rec_res = num_rec_res + 1 .
        end.
      end.
      else do :
        if (loc-gds-dtl.doc-qnty = loc-gds-dtl.fact-qnty and rz) or                           (loc-gds-dtl.doc-qnty = 0 and not  rz)  then do: assign num_rec_res = num_rec_res + 1. end.
      end.
      if bottle then do:
assign
  price-rubl-with-tax-loc = b-doc-line.price-rubl
  price-base-with-tax-loc = b-doc-line.price-base
.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = b-trn-doc.doc-code
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
   find first in-vatp-goods where in-vatp-goods.artic     = b-doc-line.artic     and
                                     in-vatp-goods.prod-type = b-doc-line.prod-type and
                                     in-vatp-goods.prod-code = b-doc-line.prod-code no-lock.
   if (not b-trn-doc.internal and
           b-trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = b-doc-line.road-tax
          road-tax-rubl-loc = b-doc-line.road-tax * b-trn-doc.base-rate / b-trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = b-doc-line.road-tax
          road-tax-base-loc = b-doc-line.road-tax / b-trn-doc.base-rate * b-trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if b-doc-line.transport-base = ? then 0 else b-doc-line.transport-base)
        transport-rubl-loc = (if b-doc-line.transport-rubl = ? then 0 else b-doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if b-doc-line.other-base     = ? then 0 else b-doc-line.other-base)
        other-rubl-loc     = (if b-doc-line.other-rubl     = ? then 0 else b-doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if b-doc-line.vat-pc         = ? then 0 else b-doc-line.vat-pc)
        slt-pc-loc         = (if b-doc-line.slt-pc         = ? then 0 else b-doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = b-doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = b-doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = b-doc-line.obj-code  and
                                      in-vatp-parts.artic     = b-doc-line.artic     and
                                      in-vatp-parts.prod-type = b-doc-line.prod-type and
                                      in-vatp-parts.prod-code = b-doc-line.prod-code
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
        road-tax-base-loc   = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        transport-base-loc  = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        transport-rubl-loc  = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        other-base-loc      = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        other-rubl-loc      = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
                                        vat-base-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b-doc-line.fact-qnty   else 0
        slt-base-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b-doc-line.fact-qnty   else 0
                vat-rubl-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b-doc-line.fact-qnty   else 0
        slt-rubl-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b-doc-line.fact-qnty   else 0
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
        b-doc-line.road-tax = (if v-curr-r-b = 'rubl':U
                                then road-tax-rubl-loc
                                else road-tax-base-loc).
      end.
      if rz then do:
        if b-trn-doc.print-rubl
        then assign
              loc-gds-dtl.price-base = loc-gds-dtl.price-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
              loc-gds-dtl.discnt-base = loc-gds-dtl.discnt-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
              loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-rubl = 0
                                       then 0
                                       else loc-gds-dtl.discnt-rubl * 100 / loc-gds-dtl.price-rubl) .
        else assign
            loc-gds-dtl.price-rubl = loc-gds-dtl.price-base * b-trn-doc.base-rate / b-trn-doc.base-scale
            loc-gds-dtl.discnt-rubl = loc-gds-dtl.discnt-base * b-trn-doc.base-rate / b-trn-doc.base-scale
            loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-base = 0
                                    then 0
                                    else loc-gds-dtl.discnt-base * 100 / loc-gds-dtl.price-base) .
      end.
      if (not v-is-own and res-qnty = 0)
      or (not rz and (loc-gds-dtl.doc-qnty = 0  and res-qnty = 0) and p-tpsi-obj)
        then do:
      end.
      if chg-qnty = res-qnty and chg-qnty <> 0
      AND parts-OK
      AND (v-is-own
          OR ((not v-is-own)
              and v-to-reserv
              and (
                   ((loc-gds-dtl.doc-qnty = loc-gds-dtl.fact-qnty) and (rz))
                   OR
                   (not rz  and (loc-gds-dtl.doc-qnty = 0))
                  )
             )
          )
      then .
    end.
    if not v-is-own then do:
      if cashparts
      or cashplace
      or (chg-qnty = res-qnty
        and  ((loc-gds-dtl.doc-qnty = loc-gds-dtl.fact-qnty) and (rz))
          )
      then do:
        p-run-tpsi = no.
      end.
      else do:
        run create-tt0-doc-line-gds-dtl(
                                         input v-proprietor-obj-type
                                        ,input v-proprietor-obj-code
                                        ,input v-ext-doc-type
                                        ,input (if available tpsi_sale-doc then tpsi_sale-doc.doc-code else "":U)
                                        ,input  b-doc-line.artic
                                        ,input  b-doc-line.prod-type
                                        ,input  b-doc-line.prod-code
                                        ,input  loc-gds-dtl.prt-code
                                        ,input  (if rz
                                                  then (loc-gds-dtl.fact-qnty - loc-gds-dtl.doc-qnty)
                                                  else
                                                  (if r-qnty = ?
                                                  then ?
                                                  else r-qnty
                                                  )
                                                 )
                                        ,output v-was-gds-dtl-doc-qnty
                                        ,output v-gds-dtl-fact-qnty
                                        ,buffer b-doc-line
                                        ,buffer loc-gds-dtl
                                        ,buffer tpsi_sale-doc
                                        ).
        if not v-is-own and p-r-v > 0 and v-gds-dtl-fact-qnty <> 0 then do:
          if not (is-gas(gdscode) and buf_sale-doc.doc-kind <> 'rs':U)
          then do :
            if recid(loc-gds-dtl) <> current-rgds-dtl then assign num_rec = num_rec + 1 current-rgds-dtl = recid(loc-gds-dtl).
          end.
          run write-tt0-info in this-procedure (
                                                input b-doc-line.artic
                                              ,input b-doc-line.prod-type
                                              ,input b-doc-line.prod-code
                                              ,input loc-gds-dtl.prt-code
                                              ,input v-proprietor-obj-type
                                              ,input v-proprietor-obj-code
                                              ,input (if available tpsi_sale-doc then tpsi_sale-doc.doc-code else "":U)
                                              ,input no
                                              ,input loc-gds-dtl.fact-qnty
                                              ,input loc-gds-dtl.doc-qnty
                                              ,input ?
                                              ,input loc-gds-dtl.fact-qnty
                                              ,input v-was-gds-dtl-doc-qnty
                                              ,input v-gds-dtl-fact-qnty
                                              ,input v-was-gds-dtl-doc-qnty
                                              ,input '':u).
        end.
        if v-gds-dtl-fact-qnty = 0 then do:
            p-run-tpsi = no.
        end.
      end.
    end.
  END.
end.
END.
_main:
DO with frame a
ON ERROR   UNDO _main, LEAVE _main
ON END-KEY UNDO _main, LEAVE _main
ON STOP UNDO _main, LEAVE _main :
  FIND FIRST ink-doc WHERE ink-doc.inkas-code = p-inkas-code EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
  if NOT available ink-doc then do:
    IF LOCKED ink-doc then do:
    end.
    else do:
        run write-log-and-file in p-log-handle (                                           input 1                                         , input log-file-name                                         , input 1                                         , input substitute("Не найден незaкрытый отчет о продаже с номером ", p-inkas-code)                                       ).
    end.
    return.
  end.
  if ink-doc.status_ <> 'новый':U then do:
      run write-log-and-file in p-log-handle (                                           input 1                                         , input log-file-name                                         , input 1                                         , input substitute("Отчет о продаже с номером &1 имеет статус &2", p-inkas-code, ink-doc.status_)                                       ).
    return .
  end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  v-host-code = ink-doc.host-code.
  run write-log-and-file in p-log-handle (                                   input 1                                 , input log-file-name                                 , input 1                                 , input "Проверка на наличие зарезервированного товара..."                                                               ).     v-found = '':U.                                                                     for each check_sale-doc where                                                               check_sale-doc.inkas-code = p-inkas-code:                                     if check_sale-doc.doc-kind = 'rwo':U then next.              find first check_gds-dtl no-lock where                                                        check_gds-dtl.doc-code = check_sale-doc.doc-code                              AND   checK_gds-dtl.doc-qnty > 0  no-error .                                    if available check_gds-dtl then do:                                                     v-found = substitute("Документ &1, Товар &2 &3&4"                                                       , check_sale-doc.doc-code                                                           , check_gds-dtl.artic                                                               , check_gds-dtl.prod-type                                                           , check_gds-dtl.prod-code                                                           ).                                                              leave.                                                                          end.                                                                              end.
  if v-found <> '':U then do:
    found-unres = yes.
    if NOT FORCED THEN DO:
      run write-log-and-file in p-log-handle (                                           input 1                                         , input log-file-name                                         , input 1                                         , input substitute("В накладных по продаже &1 имеются неснятые резервы&2" +                               "Удаление невозможно"                                                                 , p-inkas-code                                                                        , chr(10))                                       ).
      return "error" .
    end.
  END.
  if p-auto < 2 then do:
    glog = no.
    message "Удалить незакрытую продажу " ink-doc.inkas-code skip
            "Вы уверены!"
    view-as alert-box QUESTION BUTTONS YES-NO update glog.
    if NOT glog then return.
  end.
  if found-unres then do:
    RUN PUSK-UNRESERV (v-is-tpsi-obj) no-error.
    if error-status:error then do:
        run write-log-and-file in p-log-handle (                                           input 1                                         , input log-file-name                                         , input 1                                         , input substitute("Ошибка при принудительном удалении резервов по продаже&1:&2&3 &4" +                               "Удаление невозможно"                                                                 , p-inkas-code                                                                        , chr(10)                                                                       , error-status:get-message(1)                                                          , return-value)                                       ).
        v-view-log = yes.
        if p-auto = 0 then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе удаления продажи произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action20   as character no-undo .
  define variable v-printed20       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе удаления продажи произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'sale-del.log')
    ,input  7
    ,output v-user-action20
    ,output v-printed20
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'sale-del.log').
end.
                        undo, return "error":U.                  end.
        UNDO _main, return "error".
    end.
    v-found = '':U.
    v-found = '':U.
    for each check_sale-doc where
            check_sale-doc.inkas-code = p-inkas-code
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    :
      if check_sale-doc.doc-kind = 'rwo':U then next.
      IF  can-find (first ub.gds-dtl no-lock where
                        ub.gds-dtl.doc-code = check_sale-doc.doc-code  AND
                        ub.gds-dtl.doc-qnty > 0 USE-INDEX pi) then do:
        v-found = check_sale-doc.doc-code.
        leave.
      end.
    end .
    run write-log-and-file in p-log-handle (                                   input 1                                 , input log-file-name                                 , input 1                                 , input "Проверка на наличие зарезервированного товара..."                                                               ).     v-found = '':U.                                                                     for each check_sale-doc where                                                               check_sale-doc.inkas-code = p-inkas-code:                                     if check_sale-doc.doc-kind = 'rwo':U then next.              find first check_gds-dtl no-lock where                                                        check_gds-dtl.doc-code = check_sale-doc.doc-code                              AND   checK_gds-dtl.doc-qnty > 0  no-error .                                    if available check_gds-dtl then do:                                                     v-found = substitute("Документ &1, Товар &2 &3&4"                                                       , check_sale-doc.doc-code                                                           , check_gds-dtl.artic                                                               , check_gds-dtl.prod-type                                                           , check_gds-dtl.prod-code                                                           ).                                                              leave.                                                                          end.                                                                              end.
    if v-found <> '':U then do:
       run write-log-and-file in p-log-handle (                                           input 1                                         , input log-file-name                                         , input 1                                         , input substitute("В накладных по продаже &1 (&2) ВСЕ ЕЩЕ имеются неснятые резервы&3" +                               "Удаление невозможно"                                                                 , p-inkas-code                                                                        , v-found                                                                             , chr(10))                                       ).
       UNDO _main,  return "error".
    END.
  end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run write-log-and-file in p-log-handle (                                   input 1                                 , input log-file-name                                 , input 1                                 , input "Отвязывание чеков от документа -        "                                                               ).
FOR EACH ub.chk-doc WHERE
          ub.chk-doc.obj-type = ink-doc.obj-type AND
          ub.chk-doc.obj-code = ink-doc.obj-code AND
          ub.chk-doc.out-code = ink-doc.inkas-code
on error undo _main, return error substitute("Ошибка при удалении/отвязывании чеков при удалении документа &1", ink-doc.inkas-code)
          :
    FOR EACH ub.chk-gds WHERE
              ub.chk-gds.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.chk-gds.
      end.
      else do:
        ub.chk-gds.out-code = ? .
        for each ub.marking-chk where ub.marking-chk.doc-code = ub.chk-gds.doc-code
                                  and ub.marking-chk.line-num = ub.chk-gds.line-num :
          ub.marking-chk.sts = 0 .
        end .
      end.
    END .
    FOR EACH ub.chk-pay WHERE
              ub.chk-pay.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.chk-pay.
      end.
      else do:
        ub.chk-pay.out-code = ? .
      end.
    END .
    FOR EACH ub.chk-discnt WHERE
              ub.chk-discnt.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.chk-discnt.
      end.
      else do:
        ub.chk-discnt.out-code = ? .
      end.
    END .
    FOR EACH ub.chk-doc-attr WHERE
              ub.chk-doc-attr.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.chk-doc-attr.
      end.
      else do:
         ub.chk-doc-attr.out-code = ?.
      end.
    END .
    FOR EACH ub.chk-gds-pay WHERE
             ub.chk-gds-pay.doc-code = ub.chk-doc.doc-code :
      delete ub.chk-gds-pay.
    END .
    FOR EACH ub.c-chk-gds WHERE
              ub.c-chk-gds.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-gds.
      end.
      else do:
        ub.c-chk-gds.out-code = ? .
      end.
    END .
    FOR EACH ub.c-chk-pay WHERE
              ub.c-chk-pay.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-pay.
      end.
      else do:
        ub.c-chk-pay.out-code = ? .
      end.
    END .
    FOR EACH ub.c-chk-discnt WHERE
              ub.c-chk-discnt.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-discnt.
      end.
      else do:
        ub.c-chk-discnt.out-code = ? .
      end.
    END .
    FOR EACH ub.c-chk-doc-attr WHERE
              ub.c-chk-doc-attr.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-doc-attr.
      end.
    END .
    FOR EACH ub.c-chk-doc WHERE
              ub.c-chk-doc.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-doc.
      end.
      else do:
        ub.c-chk-doc.out-code = ? .
      end.
    END .
    if g#news then do:
      delete ub.chk-doc.
    end.
    else do:
      assign
      ub.chk-doc.out-code = ?
      ii = ii + 1
      .
    end.
        run write-counter in p-log-handle (input substitute("Отвязывание чеков от документа -       &1", string(ii, "99999"))).
END .
run write-log-and-file in p-log-handle (                                   input 1                                 , input log-file-name                                 , input 1                                 , input "Удаление записей о выручке ..."                                                               ).
FOR EACH ub.inkas-pay WHERE
          ub.inkas-pay.inkas-code = ink-doc.inkas-code :
    delete ub.inkas-pay.
END .
FOR EACH ub.inkas-pay-desk WHERE
          ub.inkas-pay-desk.inkas-code = ink-doc.inkas-code :
    delete ub.inkas-pay-desk.
END .
FOR EACH ub.inkas-pay-wth WHERE
          ub.inkas-pay-wth.inkas-code = ink-doc.inkas-code :
    delete ub.inkas-pay-wth.
END .
  _bts:
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = p-inkas-code
      and buf_sale-doc.order > 0
  by buf_sale-doc.order
  on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)) :
    FIND buf_trn-doc WHERE
         buf_trn-doc.doc-code = buf_sale-doc.doc-code exclusive no-error.
    if not available buf_trn-doc then do:
      FIND buf_trn-doc WHERE
          buf_trn-doc.doc-code = buf_sale-doc.doc-code no-lock no-error.
      if not available buf_trn-doc then do:
        delete buf_sale-doc.
        next _bts.
      end.
    end.
    assign
    buf_trn-doc.doc-date = ink-doc.doc-date.
  run write-log-and-file in p-log-handle (                                   input 1                                 , input log-file-name                                 , input 1                                 , input substitute("Удаление строчек накладной (&1)        ", entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ))                                                               ).
    FOR EACH ub.doc-line WHERE
              ub.doc-line.doc-code = buf_sale-doc.doc-code
    on error undo _main, return error
    substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
      ub.doc-line.doc-qnty = 0 .
      FOR EACH ub.gds-dtl WHERE
          ub.gds-dtl.prod-type = ub.doc-line.prod-type AND
          ub.gds-dtl.prod-code = ub.doc-line.prod-code AND
          ub.gds-dtl.artic     = ub.doc-line.artic AND
          ub.gds-dtl.doc-code  = ub.doc-line.doc-code :
        ub.gds-dtl.doc-qnty = 0 .
        if ub.doc-line.doc-qnty <> 0 or ub.gds-dtl.doc-qnty <> 0 then do:
        run write-log-and-file in p-log-handle (                                   input 1                                 , input log-file-name                                 , input 1                                 , input substitute("Ошибка обнуления товара/признака в отчете продажи &1 ( &5 ):&2&3 &4"  +                              "Удаление продажи невозможно."                                                                             , p-inkas-code                                                                                             , chr(10)                                                                                            , error-status:get-message(1)                                                                              , return-value                                                                                             , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ) )                                                               ).
         v-view-log = yes.
          undo _main, return "error".
        end.
        delete ub.gds-dtl.
        ii = ii + 1.
run write-counter in p-log-handle (input substitute("Удаление строчек накладной (&2) &1", string(ii, "999999"), entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ))).
      END .
      delete doc-line.
    END.
    for each ub.doc-prts WHERE
          ub.doc-prts.out-code = buf_sale-doc.doc-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
      delete ub.doc-prts.
    end.
    for each ub.doc-pl WHERE
            ub.doc-pl.out-code = buf_sale-doc.doc-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
        delete ub.doc-pl.
    end.
    for each ub.doc-fbr-gds WHERE
            ub.doc-fbr-gds.out-code = buf_sale-doc.doc-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
        delete ub.doc-fbr-gds.
    end.
    for each buf_c-inkas where
            buf_c-inkas.inkas-code = ink-doc.inkas-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
      delete buf_c-inkas.
    end.
    for each buf_c-inkas-pay where
            buf_c-inkas-pay.inkas-code = ink-doc.inkas-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
      delete buf_c-inkas-pay.
    end.
    for each buf_c-inkas-pay-desk where
            buf_c-inkas-pay-desk.inkas-code = ink-doc.inkas-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
      delete buf_c-inkas-pay-desk.
    end.
    for each buf_c-inkas-pay-wth where
            buf_c-inkas-pay-wth.inkas-code = ink-doc.inkas-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
      delete buf_c-inkas-pay-wth.
    end.
  end.
  for each buf_sale-doc where buf_sale-doc.inkas-code = p-inkas-code
                          and buf_sale-doc.order = 0:
    delete buf_sale-doc.
  end.
  _tpsi_sale-doc:
  for each tpsi_sale-doc where
          tpsi_sale-doc.inkas-code = ink-doc.inkas-code
      and tpsi_sale-doc.tpsidoc = yes,
      first buf_trn-doc EXCLUSIVE-LOCK where buf_trn-doc.doc-code = tpsi_sale-doc.doc-code
  on error undo, return "error"
  :
    assign
    buf_trn-doc.status_ = 'накл':U
    buf_trn-doc.flag_ = no.
    run str/del-doc.p (
        input  parparentproc,
        input  tpsi_sale-doc.doc-code,
        input  g#db-num,
        input  "del-doc.err",
        input  ?,
        input  ?,
        input  g#userid,
        input  '0',
        input  varchip-code,
        output varchip-code2)
        no-error.
    if error-status:error then do:
      assign
      v-mes =  substitute("Ошибка при удалении ПУСТОГО расходного документа ЧУЖИХ товаров &1 по объекту &2&3 для продажи &4 &5:&3&6 &7"
                              , tpsi_sale-doc.doc-code
                              , (tpsi_sale-doc.obj-type + string(tpsi_sale-doc.obj-code))
                              , chr(10)
                              , ink-doc.inkas-code
                              , (ink-doc.obj-type + string(ink-doc.obj-code))
                              , error-status:get-message(1)
                              , return-value ).
      run write-log-and-file in p-log-handle (                                   input 1                                 , input log-file-name                                 , input 1                                 , input v-mes                                                               ).
      v-view-log = yes.
      if p-auto = 0 then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе удаления продажи произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action23   as character no-undo .
  define variable v-printed23       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе удаления продажи произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'sale-del.log')
    ,input  7
    ,output v-user-action23
    ,output v-printed23
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'sale-del.log').
end.
                        undo, return "error":U.                  end.
      UNDO _main, return "error".
    end.
    else do:
      delete tpsi_sale-doc.
    end.
  end.
  delete ink-doc no-error .
  if error-status:error then do:
     run write-log-and-file in p-log-handle (                                   input 1                                 , input log-file-name                                 , input 1                                 , input substitute("Ошибка при удалении записи документа продажи &1:&2&3 &4"                             , p-inkas-code                                                                        , chr(10)                                                                       , error-status:get-message(1)                                                         , return-value )                                                               ).
     v-view-log = yes.
     if p-auto = 0 then do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе удаления продажи произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action25   as character no-undo .
  define variable v-printed25       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе удаления продажи произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'sale-del.log')
    ,input  7
    ,output v-user-action25
    ,output v-printed25
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'sale-del.log').
end.
                        undo, return "error":U.                  end.
     undo _main, return "error" .
  end.
  FOR EACH BUF_sale-doc where
          buf_sale-doc.inkas-code = p-inkas-code
      and buf_sale-doc.order > 0,
      FIRST BUF_TRN-DOC exclusive-lock where buf_trn-doc.doc-code = buf_sale-doc.doc-code
  on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
       run write-log-and-file in p-log-handle (                                   input 1                                 , input log-file-name                                 , input 1                                 , input substitute("Удаление &1 &2...", entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ), buf_sale-doc.doc-code)                                                               ).
      if buf_sale-doc.in-inkas = no then do:
        assign
        buf_trn-doc.status_ = 'накл':U.
        run str/del-doc.p (
            input  parparentproc,
            input  buf_sale-doc.doc-code,
            input  g#db-num,
            input  "del-doc.err",
            input  ?,
            input  ?,
            input  g#userid,
            input  '0',
            input  varchip-code,
            output varchip-code2)
            no-error.
       END.
       ELSE DO:
         DELETE BUF_TRN-DOC NO-ERROR.
       END.
      if error-status:error then do:
        assign
        v-mes =  substitute("Ошибка при удалении документа &1 &2 для продажи &3:&4&5&4&6"
                                , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                                , buf_sale-doc.doc-code
                                , p-inkas-code
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value ).
                run write-log-and-file in p-log-handle (                                   input 1                                 , input log-file-name                                 , input 1                                 , input v-mes                                                               ).
        v-view-log = yes.
        if p-auto = 0 then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе удаления продажи произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action27   as character no-undo .
  define variable v-printed27       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе удаления продажи произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'sale-del.log')
    ,input  7
    ,output v-user-action27
    ,output v-printed27
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'sale-del.log').
end.
                        undo, return "error":U.                  end.
        undo _main, return "error" .
      end.
      delete buf_sale-doc.
  END.
    run write-log-and-file in p-log-handle (                                   input 1                                 , input log-file-name                                 , input 1                                 , input substitute("Продажа &1 удалена", p-inkas-code)                                                               ).
END .
PROCEDURE PUSK-UNRESERV:
define input parameter p-is-tpsi-obj as logical no-undo .
DEFINE var i-err-count as   integer             no-undo .
assign
rdoc-line = - 1
rgds-dtl = ?
r-or-v = ?
r-qnty = ?
r-b-code = ?
r-doc-prts-qnty = ?
r-pl-code = ?
.
if p-auto < 2
then do:
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_sale_fact':U
    ,input  'object':U
    ,input  ink-doc.host-code
    ,input  ink-doc.obj-type
    ,input  ink-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if NOT glog then return error.
end.
RUN UNRESERV in this-procedure ( input p-is-tpsi-obj, buffer ink-doc) no-error.
IF error-status:error then do:
  run del-lines in this-procedure no-error .
  if error-status:error then do:
      v-view-log = yes.
    run write-log-and-file in p-log-handle (                                   input 1                                 , input log-file-name                                 , input 1                                 , input substitute("Ошибка при форсированном удалении резервов с продажи &1:&2&3&2&4"                              , p-inkas-code                                                                                    , chr(10)                                                                                   , error-status:get-message(1)                                                                     , return-value                                                                                    )                                                               ).
    undo, return error.
  end.
end.
END PROCEDURE.
procedure del-lines :
_main:
do
on error undo, return error
:
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf_trn-doc for ub.trn-doc.
  for each buf_sale-doc where
           buf_sale-doc.inkas-code = p-inkas-code
       and buf_sale-doc.order > 0
  by buf_sale-doc.order
  on error undo, return error substitute("&1&2&1&3", error-status:get-message(1), chr(10), return-value )
  on stop undo, return error substitute("&1&2&1&3", error-status:get-message(1), chr(10), return-value )
  :
    if buf_sale-doc.doc-kind = 'rwo':U then next.
    find first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = buf_sale-doc.doc-code.
    assign
    buf_trn-doc.status_ = 'накл':U.
        run write-log-and-file in p-log-handle (                                   input 1                                 , input log-file-name                                 , input 1                                 , input substitute("УДАЛЕНИЕ резервов с накладной &1 &2...", entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ), buf_sale-doc.doc-code)                                                               ).
    for each ub.doc-line where
            ub.doc-line.doc-code = buf_sale-doc.doc-code
    on error undo _main, return error substitute("&1&2&1&3", error-status:get-message(1), chr(10), return-value )
    :
      run trg/rsrv-del.p
        (input ub.doc-line.doc-code
        ,input ub.doc-line.artic
        ,input ub.doc-line.prod-type
        ,input ub.doc-line.prod-code
        ) no-error .
      if error-status :error then do:
        if p-auto = 0 then do:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе удаления продажи произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action30   as character no-undo .
  define variable v-printed30       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе удаления продажи произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'sale-del.log')
    ,input  7
    ,output v-user-action30
    ,output v-printed30
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'sale-del.log').
end.
                        undo, return "error":U.                  end.
        undo _main, return error substitute("Ошибка при снятии резервов. Документ &1 Артикул: &2 &3 &4",
                                      doc-line.doc-code,
                                      doc-line.artic,
                                      doc-line.prod-type,
                                      doc-line.prod-code).
      end.
    end.
  end.
end.
end procedure.
