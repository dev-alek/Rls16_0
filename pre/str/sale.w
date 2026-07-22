DEFINE INPUT PARAMETER PARPARENTPROC AS WIDGET-HANDLE NO-UNDO .
define input parameter p-mode        as character no-undo .
define input-output parameter p-doc-rec     as recid no-undo .
define input-output parameter p-call-prog as handle no-undo .
define input-output parameter p-next-prev as character no-undo .
define parameter buffer ink-doc for ub.inkas.
define variable vss-revision    as character no-undo initial "$Revision$":u .
define variable vss-author      as character no-undo initial "$Author$":u .
define variable vss-date        as character no-undo initial "$Date$":u .
define variable vss-workfile    as character no-undo initial "$Workfile$":u .
define variable vss-archive     as character no-undo initial "$Archive$":u .
define variable vss-description as character no-undo initial "Главная форма интерфейса продаж" .
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
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
DEFINE TEMP-TABLE temp-pl NO-UNDO
FIELD pl-code like ub.bar-code.b-code
FIELD IS-OUT as integer
FIELD Doc-qnty like ub.doc-prts.doc-qnty
FIELD fact-qnty like ub.doc-prts.fact-qnty
field new-fact-qnty like ub.doc-pl.fact-qnty
INDEX pi is UNIQUE PRIMARY is-out
                           pl-code
index qnty doc-qnty
.
DEFINE TEMP-TABLE temp-prts NO-UNDO
FIELD b-code like ub.bar-code.b-code
FIELD IS-OUT as integer
FIELD Doc-qnty like ub.doc-prts.doc-qnty
FIELD fact-qnty like ub.doc-prts.fact-qnty
field new-fact-qnty like ub.doc-prts.fact-qnty
FIELD RC as character
FIELD twounit as logical
FIELD compensed as logical
INDEX pi is UNIQUE PRIMARY is-out
                           b-code
                           rc
index qnty compensed
           doc-qnty
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table tt0-info no-undo
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
define NEW SHARED temp-table tt0-doc-line no-undo like lib-trn_ret-line.
define NEW SHARED temp-table tt0-gds-dtl  no-undo like ub.gds-dtl.
define NEW SHARED temp-table tt0-parts    no-undo like ub.parts.
define NEW SHARED temp-table temp-tpsi-clients  no-undo like ub.clients.
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tpsi-gds-fill-tpsi-obj-table :
define input parameter p-db-num like ub.db.db-num no-undo .
define variable v-is-tpsi-obj as logical no-undo .
define buffer buf_clients for ub.clients.
  do
  on error undo, return error return-value
  :
    for each temp-tpsi-clients :
      delete temp-tpsi-clients.
    end.
    _clients:
    for each buf_clients no-lock where
          buf_clients.db-num = p-db-num:
      assign
      v-is-tpsi-obj = no.
      run gbl/tpsi-obj.p (
                      input buf_clients.obj-type
                    ,input buf_clients.obj-code
                    ,output v-is-tpsi-obj) .
      if not v-is-tpsi-obj then NEXT _clients.
      create temp-tpsi-clients.
      buffer-copy
      buf_clients to
      temp-tpsi-clients.
    end.
  end.
end procedure.
procedure tpsi-gds-proprietor :
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-db-num   like ub.db.db-num      no-undo .
define output parameter p-proprietor-host-code like ub.clients.host-code no-undo .
define output parameter p-proprietor-obj-type like ub.clients.obj-type no-undo .
define output parameter p-proprietor-obj-code like ub.clients.obj-code no-undo .
define variable v-is-tpsi-obj as logical no-undo .
do
on error undo, return error return-value
:
    define buffer buf_clients for ub.clients.
    define buffer buf_gds-obj-attr for ub.gds-obj-attr.
    assign
    p-proprietor-obj-type = "":U
    p-proprietor-obj-code = ?
    p-proprietor-host-code = ?
    .
    _gds-obj-attr:
    for each buf_clients no-lock where
            buf_clients.db-num = p-db-num,
      each buf_gds-obj-attr no-lock where
          buf_gds-obj-attr.obj-type = buf_Clients.obj-type
      AND buf_gds-obj-attr.obj-code = buf_clients.obj-code
      AND buf_gds-obj-attr.gds-code = p-gds-code
      AND buf_gds-obj-attr.attr-code = 'proprietor':U:
      if logical(buf_gds-obj-attr.attr-value) = yes then do:
        assign
        v-is-tpsi-obj = no.
        run gbl/tpsi-obj.p (
                        input buf_gds-obj-attr.obj-type
                      ,input buf_gds-obj-attr.obj-code
                      ,output v-is-tpsi-obj) .
        if not v-is-tpsi-obj then NEXT _gds-obj-attr.
        assign
        p-proprietor-obj-type = buf_gds-obj-attr.obj-type
        p-proprietor-obj-code = buf_gds-obj-attr.obj-code
        p-proprietor-host-code = buf_clients.host-code
        .
        LEAVE.
      end.
    end.
end.
end procedure.
procedure tpsi-preselect-gds-proprietor :
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-db-num   like ub.db.db-num      no-undo .
define output parameter p-proprietor-host-code like ub.clients.host-code no-undo .
define output parameter p-proprietor-obj-type like ub.clients.obj-type no-undo .
define output parameter p-proprietor-obj-code like ub.clients.obj-code no-undo .
do
on error undo, return error return-value
:
    define buffer buf_clients for ub.clients.
    define buffer buf_gds-obj-attr for ub.gds-obj-attr.
    assign
    p-proprietor-obj-type = "":U
    p-proprietor-obj-code = ?
    p-proprietor-host-code = ?
    .
    _gds-obj-attr:
    for each temp-tpsi-clients no-lock where
            temp-tpsi-clients.db-num = p-db-num,
      each buf_gds-obj-attr no-lock where
          buf_gds-obj-attr.obj-type = temp-tpsi-clients.obj-type
      AND buf_gds-obj-attr.obj-code = temp-tpsi-clients.obj-code
      AND buf_gds-obj-attr.gds-code = p-gds-code
      AND buf_gds-obj-attr.attr-code = 'proprietor':U:
      if logical(buf_gds-obj-attr.attr-value) = yes then do:
        assign
        p-proprietor-obj-type = buf_gds-obj-attr.obj-type
        p-proprietor-obj-code = buf_gds-obj-attr.obj-code
        p-proprietor-host-code = temp-tpsi-clients.host-code
        .
        LEAVE.
      end.
    end.
end.
end procedure.
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function shift-name-no-err return char (
                                        buffer loc-inkas for ub.inkas
 ).
define variable varshift-name as character no-undo.
define variable varshift-name-num as character no-undo.
  varshift-name = loc-inkas.shift-name.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnme in g#lib-trn3 ( input  loc-inkas.obj-type,
                       input  loc-inkas.obj-code,
                       input  loc-inkas.shift-date,
                       input  loc-inkas.shift-num,
                       input-output varshift-name,
                       output varshift-name-num
                       ) no-error .
  if error-status:error then do:
    return "":u.
  end.
  return varshift-name-num.
end function.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    def var log-file-name as char no-undo.
    assign
        log-file-name = 'fbr-rsrv-errors-sale.txt'
    .
    if log-file-name <> "":U
    then do:
        if search( 'fbr-rsrv-errors-sale.txt' ) = ?
        then do:
            output to value( 'fbr-rsrv-errors-sale.txt' ).
            output close.
        end.
    end.
    DEF STREAM stm-log.
    PROCEDURE writelog:
    DEF INPUT PARAMETER p-file-name AS CHAR     NO-UNDO.
    DEF INPUT PARAMETER p-log-level AS INTEGER  NO-UNDO.
    DEF INPUT PARAMETER p-log-string  AS CHAR     NO-UNDO.
    if p-file-name <> ""
    then do:
    OUTPUT STREAM stm-log TO VALUE(p-file-name) APPEND.
        PUT STREAM stm-log UNFORMATTED chr(10).
        PUT STREAM stm-log UNFORMATTED (IF (p-log-level = 0 OR p-log-string = "&DLine"
                                        OR p-log-string = "&Line") THEN "" ELSE
                                        cur-time-string-sec() + " ").
        PUT STREAM stm-log UNFORMATTED
                (IF p-log-string = "&Line" THEN FILL("-", 80)
                ELSE IF p-log-string = "&DLine" THEN FILL("=", 80)
                ELSE fill(" ", p-log-level * 2) + p-log-string).
    OUTPUT STREAM stm-log CLOSE.
    end.
    END PROCEDURE.
def var vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info20 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info20, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info20, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info20, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info20, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info20 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info20, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info20 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info20, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info20, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info20, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info20, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info20, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info20, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info20 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info20 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info20, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info20, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info20, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info20 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info20 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info20, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info20, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE verify-ini-entry:
DEFINE INPUT  PARAMETER ini-key-name     as character no-undo.
DEFINE INPUT  PARAMETER ini-section-name as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text   as character no-undo.
DEFINE INPUT  PARAMETER silence          as logical no-undo.
DEFINE OUTPUT PARAMETER ini-entry-value  as character no-undo INIt ?.
define variable v-mess as character no-undo .
get-key-value section ini-section-name key ini-key-name value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "spl"
then
get-key-value section ini-section-name key "splall" value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "sav"
then
get-key-value section ini-section-name key "savall" value ini-entry-value.
if ini-entry-value = ? then do:
  assign
  v-mess = substitute("Ошибка ini - файла:&1Секция &2&1Ключ &3&1&4"
                    , chr(10)
                    , ini-section-name
                    , ini-key-name
                    , error-msg-text).
    if not silence then do:
      message
      v-mess
      view-as alert-box ERROR  .
      return error.
    end.
    else do:
      return error v-mess.
    end.
end.
END PROCEDURE.
PROCEDURE verify-file:
DEFINE INPUT  PARAMETER filename       as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text as character no-undo.
DEFINE INPUT  PARAMETER silence        as logical no-undo.
DEFINE OUTPUT PARAMETER found          as logical no-undo.
file-info:file-name = filename.
found = NOT (file-info:full-pathname = ?).
if NOT found  then do:
  if not silence then do:
    message error-msg-text
    view-as alert-box ERROR.
    return error.
  end.
  else return error error-msg-text.
end.
END PROCEDURE.
os-delete value (search ('fbr-rsrv-errors-sale.txt')) no-error.
DEFINE NEW SHARED BUFFER t-doc     FOR ub.trn-doc.
DEFINE NEW SHARED BUFFER ret-doc   FOR ub.trn-doc.
DEFINE BUFFER l-out-dtl FOR ub.gds-dtl.
DEFINE BUFFER l-goods   FOR ub.goods.
DEFINE NEW SHARED BUFFER out-dtl   FOR ub.gds-dtl.
DEFINE NEW SHARED BUFFER ret-dtl   FOR ub.gds-dtl.
DEFINE NEW SHARED BUFFER out-prt   FOR ub.gds-prt.
DEFINE NEW SHARED BUFFER ret-prt   FOR ub.gds-prt.
DEFINE NEW SHARED BUFFER out-goods FOR ub.goods.
DEFINE NEW SHARED BUFFER ret-goods FOR ub.goods.
DEFINE NEW SHARED BUFFER out-bar   FOR ub.bar-code.
DEFINE NEW SHARED BUFFER ret-bar   FOR ub.bar-code.
DEFINE NEW SHARED BUFFER out-tt0-dtl   FOR tt0-gds-dtl.
DEFINE NEW SHARED BUFFER ret-tt0-dtl   FOR tt0-gds-dtl.
define variable sort-column-name-out as character no-undo .
define variable sort-column-name-ret as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable bh-out-dtl as handle no-undo .
define variable bh-ret-dtl as handle no-undo .
define variable bh-out-goods as handle no-undo .
define variable bh-ret-goods as handle no-undo .
define variable brwh-out-dtl as widget-handle no-undo .
define variable brwh-ret-dtl as widget-handle no-undo .
define variable bh as handle no-undo .
define variable bhg as handle no-undo .
define variable bhb as handle no-undo .
define variable brwh as widget-handle no-undo .
define variable qh as handle no-undo .
define variable v-doc-code as character no-undo .
define variable v-artic as character no-undo .
define variable v-prod-type as character no-undo .
define variable v-prod-code as integer no-undo .
define variable v-gds-code as integer no-undo .
define variable v-recid as recid no-undo .
define variable v-b-code as integer no-undo .
define variable v-node-code as integer no-undo .
define variable p-auto  as integer no-undo init 0.
define variable v-parameter as character no-undo .
define variable p-parent-handle as handle no-undo .
define variable p-log-handle as handle no-undo .
define variable b-close-enabled as logical no-undo initial no.
define variable BadTrans as logical no-undo .
define variable t-code like ub.trn-doc.out-code no-undo.
define variable ret-code like ub.trn-doc.out-code no-undo.
define variable rdoc-line as recid.
define variable br-2-mode as character no-undo .
define variable br-2-doc-code as character no-undo .
define variable v-list-item-pairs as character no-undo .
define variable r-or-v as character no-undo.
define variable r-office as character no-undo .
define variable num_resv as integer no-undo.
define variable num_resv_res as integer no-undo.
define variable autoclose as logical no-undo initial no.
define variable autocalc as logical no-undo initial no.
define variable just-entered as logical no-undo initial yes.
define variable v-is-tpsi-obj as logical no-undo .
define variable resttpsi as logical no-undo .
define variable neg-tpsi-weight as logical no-undo .
define variable neg-tpsi-oper as logical no-undo .
define variable neg-tpsi-qnty as decimal no-undo .
define variable close-in-rfsl as integer no-undo .
define variable pay-gds-algo as character no-undo .
define variable autofbr as logical no-undo initial no.
define variable restdish as logical no-undo initial no.
define variable restingr as logical no-undo initial no.
define variable conf-attr as character no-undo.
define variable conf-par as character no-undo.
define variable par-type as character no-undo.
define variable cas-shft as logical no-undo initial no.
define variable one-curs as logical no-undo initial no.
define variable from-menu as logical initial no.
define variable b-mail-pressed as logical initial no.
define variable auto-mail as logical no-undo.
define variable auto-get-res as logical no-undo.
define variable auto-comp as logical no-undo.
define variable prcl-spl as logical no-undo initial no.
define variable ptwounit as logical no-undo initial yes.
define variable v-to-reserv as logical no-undo initial no.
define variable compensed as logical no-undo.
define variable from-compense as logical no-undo.
define variable p-obj-type like ub.clients.obj-type no-undo.
define variable p-obj-code like ub.clients.obj-code no-undo.
define variable current-browser as widget-handle no-undo.
define variable not-all-saled-chk as logical initial no.
define variable not-all-normal-chk as logical initial no.
define variable not-all-inkas-closed as logical no-undo initial no.
define variable glog as logical no-undo .
define variable g#log as logical no-undo .
define variable v-base-type like ub.currency.curr-abbr no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-db-num  like ub.db.db-num no-undo .
define variable v-gds-dtl-prop-doc-qnty like ub.gds-dtl.doc-qnty no-undo .
define variable v-ret-dtl-prop-doc-qnty like ub.gds-dtl.doc-qnty no-undo .
define variable v-gds-proprietor as character no-undo .
define variable v-ret-gds-proprietor as character no-undo .
define variable line-rec as recid no-undo .
define variable gds-rec as recid no-undo .
define variable v-empty as character no-undo .
define variable v-prt-name as character no-undo .
define variable v-is-inquiry as logical no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable v-log-handle as handle no-undo .
define variable v-sys-key as character no-undo .
define variable varpar-type as character no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define temp-table wh no-undo
field mi-reserv as widget-handle
field mi-unreserv as widget-handle
field mi-parts as widget-handle
field mi-arch as widget-handle
field doc-kind like ub.sale-doc.doc-kind
field chr-office like ub.sale-doc.chr-office
field doc-code like ub.sale-doc.doc-code
index pi is unique primary
doc-code doc-kind.
define buffer buf_currency for ub.currency.
define buffer buf_sale-doc for ub.sale-doc.
define buffer tpsi_sale-doc for ub.sale-doc.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table dtl-rests-mark no-undo
field artic like ub.gds-dtl.artic
field prod-type like ub.gds-dtl.prod-type
field prod-code like ub.gds-dtl.prod-code
index   pi  is primary
artic
prod-type
prod-code
.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new SHARED temp-table dtl-rests no-undo
field b-code like ub.bar-code.b-code
field artic like ub.gds-dtl.artic
field prod-type like ub.gds-dtl.prod-type
field prod-code like ub.gds-dtl.prod-code
field gds-code like ub.goods.gds-code
field prt-code like ub.gds-dtl.prt-code
field unit-base like ub.goods.unit-base
field rest-fact-qnty as decimal
field maybe-qnty as decimal
field prt-qnty as decimal
field free-qnty as decimal
field need-qnty as decimal
field gds-name like ub.goods.gds-name
field OK as logical column-label "ОК"
FIELD fbr as integer
field prop as integer
field is-neg-tpsi-oper as logical
field weight as logical
field is-neg-tpsi-qnty as logical
field is-neg-tpsi-weight as logical
field ok-prop as logical
field is-neg-rest as logical
field to-view as logical
index   pi  is primary
gds-code
prt-code ASCENDING
index   bc
b-code ASCENDING
index ifbr fbr
index iprop prop
index iok ok
index iokprop ok-prop
index iview to-view
.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable gdsgrp_recids      as character no-undo.
define new shared variable fin-schet-recid    as character no-undo.
define new shared variable v-d-report-handle  as handle    no-undo .
define new shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
new shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define new shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define new shared variable str1   as character  no-undo.
define new shared variable str2   as character  no-undo.
define new shared variable str3   as character  no-undo.
define new shared variable str4   as character  no-undo.
define new shared variable ReportNAme   as character  no-undo.
define new shared variable ReportProc   as character  no-undo.
define new shared variable ReportHeader as character  no-undo.
define new shared variable ReportPageWidth  as integer no-undo.
define new shared variable ReportPageHeight as integer no-undo.
define new shared variable ReportFontNum    as integer no-undo.
define new shared variable my-request as logical  init false no-undo.
define new shared variable v-delim as character no-undo .
define new shared variable v-sdate as character no-undo initial "/":U.
define new shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define new shared variable my-handle  as handle no-undo .
define new shared variable parent-handle  as handle no-undo .
define new shared variable v-show-all-goods as logical  no-undo .
define new shared variable params-only      as logical   no-undo .
define new shared variable params-only-mode as character no-undo .
define new shared variable place-call       as character no-undo .
define new shared variable x-Goods-Editor   as character  no-undo .
define new shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define new shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define new shared variable x-Shift-End      as integer format ">9":u         no-undo .
define new shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define new shared variable x-SelectGood     as integer                      no-undo .
define new shared variable x-SelectObject   as character                          no-undo .
define new shared variable x-SET_PAY_TYPE   as integer  no-undo .
define new shared variable x-SET_val_TYPE   as integer  no-undo .
define new shared variable x-TOG-Shift      as logical  no-undo .
define new shared variable x-Radio-Task     as integer  no-undo .
define new shared variable x-TOG-Excel      as logical  no-undo .
define new shared variable x-TOG-list-hist  as logical  no-undo .
define new shared variable x-text-1 as character  no-undo .
define new shared variable x-text-2 as character  no-undo .
define new shared variable x-text-3 as character  no-undo .
define new shared variable x-text-4 as character  no-undo .
define new shared variable init-date-start  like x-date-start  no-undo .
define new shared variable init-date-end    like x-date-end    no-undo .
define new shared variable init-date-alone  like x-date-alone  no-undo .
define new shared variable init-shift-alone like x-shift-alone no-undo .
define new shared variable init-shift-start like x-shift-start no-undo .
define new shared variable init-shift-end   like x-shift-end   no-undo .
define new shared variable init-set_pay_type like x-set_pay_type   no-undo .
define new shared variable init-set_val_type like x-set_val_type   no-undo .
define new shared variable ref_date-start    as character   no-undo .
define new shared variable ref_date-end      as character   no-undo .
define new shared variable ref_date-alone    as character   no-undo .
define new shared work-table TDEDT  no-undo
  field id as char
  field name as character  format "x(40)"
  field n as character
  .
define variable tempstr as character  no-undo.
define variable b1-name as character  no-undo.
define variable b2-name as character  no-undo.
define variable source-str   as character no-undo .
define variable I#           as integer    no-undo.
define variable p-price-med  as decimal init 0 no-undo .
define new shared variable str-obj-type as character  no-undo.
define new shared variable str-obj-code as character  no-undo.
define new shared variable str-obj-name as character  no-undo.
define new shared variable str-obj      as character  no-undo.
define new shared variable link#        as logical  no-undo init false.
define new shared variable  Verify-Arc-ot      as logical  no-undo init false.
define new shared variable  Verify-Arc-stk     as logical  no-undo init false.
define new shared variable  Verify-Arc-supp    as logical  no-undo init false.
define new shared variable  Verify-Arc-hold    as logical  no-undo init false.
define new shared variable  Verify-Arc-aht     as logical  no-undo init false.
define new shared variable  Verify-send-check  as logical  no-undo init false.
define new shared variable  Verify-Arc-fin     as logical  no-undo init false.
define new shared variable  Verify-Arc-strong  as logical  no-undo init false.
define new shared variable  Show-Crsa         as logical  no-undo init false.
define new shared variable  Show-Cost         as logical  no-undo init false.
define new shared variable  Show-Sale         as logical  no-undo init false.
define new shared variable  Name-Sale-price   as character no-undo .
define new shared variable  Format-Folder     as logical no-undo .
define new shared variable  Print-List-Hist   as logical no-undo init false.
define new shared variable Make-Excel     as logical  no-undo init false.
define new shared variable Make-Excel-com as logical  no-undo init false.
define new shared stream ForExcel.
define new shared variable Use-column   as logical extent 256 no-undo .
define new shared variable right-column as logical extent 256 no-undo .
define new shared temp-table Sheetf no-undo
field Excel-Column-Lable as character
field Excel-Row-Heder    as integer
field Excel-Row-Title    as integer
field Sizes              as character
field Make-correct       as character
field Rights-column      as character
field MergeCellsH        as character
field MergeCellsV        as character
field sheet-num          as integer
field ColFormat          as character
field Bas-FIle           as character
field Bas-Params         as character
field Bas-Param-Add      as logical
field File-name          as character
field Silent-save        as logical
index pi as primary unique
      sheet-num
.
  create Sheetf.
  assign
  sheetf.sheet-num = 1.
define variable l-stroka as character no-undo .
define new shared  variable ch#ExcelApplication as com-handle no-undo .
define new shared  variable ch#Workbook         as com-handle no-undo .
define new shared  variable ch#Worksheet        as com-handle no-undo .
define new shared  variable Num#Str#            as integer no-undo.
define new shared  variable Number-List         as integer no-undo init 1.
define new shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
define variable v-del-1 as character no-undo .
if  v-delim = " " or v-delim = ? or v-delim = ""  then do:
    run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message(1)
              v-delim v-del-1.
        v-delim = ','  .
    end.
end.
procedure proc-page0-assign :
 do
 on error undo, return error return-value
 :
Assign
  Col-name[1] = 'A':U
  Col-name[2] = 'B':U
  Col-name[3] = 'C':U
  Col-name[4] = 'D':U
  Col-name[5] = 'E':U
  Col-name[6] = 'F':U
  Col-name[7] = 'G':U
  Col-name[8] = 'H':U
  Col-name[9] = 'I':U
  Col-name[10]= 'J':U
  Col-name[11]= 'K':U
  Col-name[12]= 'L':U
  Col-name[13]= 'M':U
  Col-name[14]= 'N':U
  Col-name[15]= 'O':U
  Col-name[16]= 'P':U
  Col-name[17]= 'Q':U
  Col-name[18]= 'R':U
  Col-name[19]= 'S':U
  Col-name[20]= 'T':U
  Col-name[21]= 'U':U
  Col-name[22]= 'V':U
  Col-name[23]= 'W':U
  Col-name[24]= 'X':U
  Col-name[25]= 'Y':U
  Col-name[26]= 'Z':U
  Col-name[27]= 'AA':U
  Col-name[28]= 'AB':U
  Col-name[29]= 'AC':U
  Col-name[30]= 'AD':U
  Col-name[31]= 'AE':U
  Col-name[32]= 'AF':U
  Col-name[33]= 'AG':U
  Col-name[34]= 'AH':U
  Col-name[35]= 'AI':U
  Col-name[36]= 'AJ':U
  Col-name[37]= 'AK':U
  Col-name[38]= 'AL':U
  Col-name[39]= 'AM':U
  Col-name[40]= 'AN':U
  Col-name[41]= 'AO':U
  Col-name[42]= 'AP':U
  Col-name[43]= 'AQ':U
  Col-name[44]= 'AR':U
  Col-name[45]= 'AS':U
  Col-name[46]= 'AT':U
  Col-name[47]= 'AU':U
  Col-name[48]= 'AV':U
  Col-name[49]= 'AW':U
  Col-name[50]= 'AX':U
  Col-name[51]= 'AY':U
  Col-name[52]= 'AZ':U
  Col-name[53]= 'BA':U
  Col-name[54]= 'BB':U
  Col-name[55]= 'BC':U
  Col-name[56]= 'BD':U
  Col-name[57]= 'BE':U
  Col-name[58]= 'BF':U
  Col-name[59]= 'BG':U
  Col-name[60]= 'BH':U
  Col-name[61]= 'BI':U
  Col-name[62]= 'BJ':U
  Col-name[63]= 'BK':U
  Col-name[64]= 'BL':U
  Col-name[65]= 'BM':U
  Col-name[66]= 'BN':U
  Col-name[67]= 'BO':U
  Col-name[68]= 'BP':U
  Col-name[69]= 'BQ':U
  Col-name[70]= 'BR':U
  Col-name[71]= 'BS':U
  Col-name[72]= 'BT':U
  Col-name[73]= 'BU':U
  Col-name[74]= 'BV':U
  Col-name[75]= 'BW':U
  Col-name[76]= 'BX':U
  Col-name[77]= 'BY':U
  Col-name[78]= 'BZ':U
  Col-name[79]= 'CA':U
  Col-name[80]= 'CB':U
  Col-name[81]= 'CC':U
  Col-name[82]= 'CD':U
  Col-name[83]= 'CE':U
  Col-name[84]= 'CF':U
  Col-name[85]= 'CG':U
  Col-name[86]= 'CH':U
  Col-name[87]= 'CI':U
  Col-name[88]= 'CJ':U
  Col-name[89]= 'CK':U
  Col-name[90]= 'CL':U
  Col-name[91]= 'CM':U
  Col-name[92]= 'CN':U
  Col-name[93]= 'CO':U
  Col-name[94]= 'CP':U
  Col-name[95]= 'CQ':U
  Col-name[96]= 'CR':U
  Col-name[97]= 'CS':U
  Col-name[98]= 'CT':U
  Col-name[99]= 'CU':U
  Col-name[100]= 'CV':U
Col-name[101]= 'CW':U
Col-name[102]= 'CX':U
Col-name[103]= 'CY':U
Col-name[104]= 'CZ':U
Col-name[105]= 'DA':U
Col-name[106]= 'DB':U
Col-name[107]= 'DC':U
Col-name[108]= 'DD':U
Col-name[109]= 'DE':U
Col-name[110]= 'DF':U
Col-name[111]= 'DG':U
Col-name[112]= 'DH':U
Col-name[113]= 'DI':U
Col-name[114]= 'DJ':U
Col-name[115]= 'DK':U
Col-name[116]= 'DL':U
Col-name[117]= 'DM':U
Col-name[118]= 'DN':U
Col-name[119]= 'DO':U
Col-name[120]= 'DP':U
Col-name[121]= 'DQ':U
Col-name[122]= 'DR':U
Col-name[123]= 'DS':U
Col-name[124]= 'DT':U
Col-name[125]= 'DU':U
Col-name[126]= 'DV':U
Col-name[127]= 'DW':U
Col-name[128]= 'DX':U
Col-name[129]= 'DY':U
Col-name[130]= 'DZ':U
Col-name[131]= 'EA':U
Col-name[132]= 'EB':U
Col-name[133]= 'EC':U
Col-name[134]= 'ED':U
Col-name[135]= 'EE':U
Col-name[136]= 'EF':U
Col-name[137]= 'EG':U
Col-name[138]= 'EH':U
Col-name[139]= 'EI':U
Col-name[140]= 'EJ':U
Col-name[141]= 'EK':U
Col-name[142]= 'EL':U
Col-name[143]= 'EM':U
Col-name[144]= 'EN':U
Col-name[145]= 'EO':U
Col-name[146]= 'EP':U
Col-name[147]= 'EQ':U
Col-name[148]= 'ER':U
Col-name[149]= 'ES':U
Col-name[150]= 'ET':U
Col-name[151]= 'EU':U
Col-name[152]= 'EV':U
Col-name[153]= 'EW':U
Col-name[154]= 'EX':U
Col-name[155]= 'EY':U
Col-name[156]= 'EZ':U
Col-name[157]= 'FA':U
.
assign
  Col-name[158]= 'FB':U
  Col-name[159]= 'FC':U
  Col-name[160]= 'FD':U
  Col-name[161]= 'FE':U
  Col-name[162]= 'FF':U
  Col-name[163]= 'FG':U
  Col-name[164]= 'FH':U
  Col-name[165]= 'FI':U
  Col-name[166]= 'FJ':U
  Col-name[167]= 'FK':U
  Col-name[168]= 'FL':U
  Col-name[169]= 'FM':U
  Col-name[170]= 'FN':U
  Col-name[171]= 'FO':U
  Col-name[172]= 'FP':U
  Col-name[173]= 'FQ':U
  Col-name[174]= 'FR':U
  Col-name[175]= 'FS':U
  Col-name[176]= 'FT':U
  Col-name[177]= 'FU':U
  Col-name[178]= 'FV':U
  Col-name[179]= 'FW':U
  Col-name[180]= 'FX':U
  Col-name[181]= 'FY':U
  Col-name[182]= 'FZ':U
  Col-name[183]= 'GA':U
  Col-name[184]= 'GB':U
  Col-name[185]= 'GC':U
  Col-name[186]= 'GD':U
  Col-name[187]= 'GE':U
  Col-name[188]= 'GF':U
  Col-name[189]= 'GG':U
  Col-name[190]= 'GH':U
  Col-name[191]= 'GI':U
  Col-name[192]= 'GJ':U
  Col-name[193]= 'GK':U
  Col-name[194]= 'GL':U
  Col-name[195]= 'GM':U
  Col-name[196]= 'GN':U
  Col-name[197]= 'GO':U
  Col-name[198]= 'GP':U
  Col-name[199]= 'GQ':U
  Col-name[200]=   'GR':U
  Col-name[201]=   'GS':U
  Col-name[202]=   'GT':U
  Col-name[203]=   'GU':U
  Col-name[204]=   'GV':U
  Col-name[205]=   'GW':U
  Col-name[206]=   'GX':U
  Col-name[207]=   'GY':U
  Col-name[208]=   'GZ':U
  Col-name[209]=   'HA':U
  Col-name[210]=   'HB':U
  Col-name[211]=   'HC':U
  Col-name[212]=   'HD':U
  Col-name[213]=   'HE':U
  Col-name[214]=   'HF':U
  Col-name[215]=   'HG':U
  Col-name[216]=   'HH':U
  Col-name[217]=   'HI':U
  Col-name[218]=   'HJ':U
  Col-name[219]=   'HK':U
  Col-name[220]=   'HL':U
  Col-name[221]=   'HM':U
  Col-name[222]=   'HN':U
  Col-name[223]=   'HO':U
  Col-name[224]=   'HP':U
  Col-name[225]=   'HQ':U
  Col-name[226]=   'HR':U
  Col-name[227]=   'HS':U
  Col-name[228]=   'HT':U
  Col-name[229]=   'HU':U
  Col-name[230]=   'HV':U
  Col-name[231]=   'HW':U
  Col-name[232]=   'HX':U
  Col-name[233]=   'HY':U
  Col-name[234]=   'HZ':U
  Col-name[235]=   'IA':U
  Col-name[236]=   'IB':U
  Col-name[237]=   'IC':U
  Col-name[238]=   'ID':U
  Col-name[239]=   'IE':U
  Col-name[240]=   'IF':U
  Col-name[241]=   'IG':U
  Col-name[242]=   'IH':U
  Col-name[243]=   'II':U
  Col-name[244]=   'IJ':U
  Col-name[245]=   'IK':U
  Col-name[246]=   'IL':U
  Col-name[247]=   'IM':U
  Col-name[248]=   'IN':U
  Col-name[249]=   'IO':U
  Col-name[250]=   'IP':U
  Col-name[251]=   'IQ':U
  Col-name[252]=   'IR':U
  Col-name[253]=   'IS':U
  Col-name[254]=   'IT':U
  Col-name[255]=   'IU':U
  Col-name[256]=   'IV':U
  .
 end.
end procedure.
define variable var-report-r-b as character no-undo .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define new global shared variable g#lib-farh as handle no-undo .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function get-OK returns CHARACTER (input p-is-tpsi-obj as logical
                                ,input p-artic   as character
                                ,input p-prod-type as character
                                ,input p-prod-code  as integer
                                ,input p-prt-code   as integer
                                ,input p-doc-qnty as decimal
                                ,input p-fact-qnty as decimal
                                ):
define buffer buf_tt0-gds-dtl for tt0-gds-dtl.
CASE p-is-tpsi-obj:
when yes then do:
  find first buf_tt0-gds-dtl no-lock where
            buf_tt0-gds-dtl.artic     = p-artic
        AND buf_tt0-gds-dtl.prod-type = p-prod-type
        AND buf_tt0-gds-dtl.prod-code = p-prod-code
        AND buf_tt0-gds-dtl.prt-code = p-prt-code no-error .
  if p-fact-qnty = p-doc-qnty
  or (available buf_tt0-gds-dtl and (buf_tt0-gds-dtl.doc-qnty + p-doc-qnty) = p-fact-qnty)
  then do:
    return "++":U.
  end.
  if available buf_tt0-gds-dtl   then do:
    return "+-":U.
  end.
  else do:
    return "--":U.
  end.
end.
when no then do:
  if p-fact-qnty = p-doc-qnty then do:
    return "+":U.
  end.
  else return "-":U.
end.
END CASE.
END FUNCTION.
function get-name returns CHARACTER (
                                      input p-node-name as character
                                     ,input p-upper-code as integer
                                     ,input p-prt-root as integer
                                     ,input p-gds-name as character ) :
define variable v-name as character no-undo .
assign
v-name  =  if p-node-name <> '_Пустая шкала':U
           and p-upper-code <> p-prt-root
           then (p-gds-name + " - " + p-node-name)
           else p-gds-name
no-error
.
return v-name.
END FUNCTION.
function get-prt-name returns character ( input p-node-name as character
                                          ,input p-upper-code as integer
                                          ,input p-prt-root as integer
                                          ,input p-f-name as character  ):
define variable v-name as character no-undo .
assign
v-name = if p-node-name = '_Пустая шкала':U
         then "-"
         else (if p-upper-code = p-prt-root
               then "-------------------"
               else p-f-name).
return v-name.
END FUNCTION.
FUNCTION get-pcnt returns decimal ( input p-price-base as decimal
                                   ,input p-price-rubl as decimal
                                   ,input p-discnt-base as decimal
                                   ,input p-discnt-rubl as decimal ) :
define variable v-pcnt as decimal no-undo .
assign
v-pcnt = (if v-curr-r-b = 'base':U
         then (p-discnt-base / p-price-base * 100)
         else (p-discnt-rubl / p-price-rubl * 100 ))
.
return v-pcnt.
END FUNCTION.
DEFINE VARIABLE mImagePath     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageDir      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImagePreDir   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageTrash    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mPhotomgd      AS LOGICAL     NO-UNDO.
DEFINE VARIABLE mImagePh       AS LOGICAL     NO-UNDO.
define variable v-param-types   as character  no-undo.
define variable v-value-char    as character  no-undo.
define variable v-val-date      as date       no-undo.
define variable v-val-decimal   as decimal    no-undo.
define variable v-val-integer   as integer    no-undo.
define variable v-val-logical   as logical    no-undo.
define variable v-tthd          as handle     no-undo.
RUN imagelist_loaddef IN THIS-PROCEDURE NO-ERROR.
PROCEDURE imagelist_loaddef:
    DEFINE VARIABLE vPar-val       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vPar-type      AS CHARACTER   NO-UNDO.
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'photo':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output vPar-val
  ,output vPar-type
  ) no-error .
        mImagePh = LOOKUP (vPar-val, "true,yes":U) > 0.
    IF mImagePh THEN .
    ELSE RETURN.
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'ph-dir':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  NO
  ,output vPar-val
  ,output vPar-type
  ) no-error .
    IF LENGTH (vPar-val) = 0 THEN
        RUN verify-ini-entry("ph-dir":U, "REP-SETS":U, "":U, YES, OUTPUT vPar-val) NO-ERROR.
    IF LENGTH (vPar-val) = 0 THEN vPar-val = "c:\temp\":U.
    ASSIGN
        mImagePath   = RIGHT-TRIM (vPar-val, "~\~/":U)
        mImagePath   = mImagePath + (IF LENGTH (mImagePath) > 0 THEN "\":U ELSE "":U)
        mImagePreDir = mImagePath
        mImageDir    = mImagePreDir
        mImageTrash  = mImagePath + "trash\":U
        .
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
            run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  'shema-foto':U
        ,output v-value-char
        ,output v-val-date
        ,output v-val-decimal
        ,output v-val-integer
        ,output v-val-logical
        ,output v-param-types
        ,INPUT-OUTPUT table-handle v-tthd
        ) no-error.
        delete object v-tthd.
        mPhotomgd = IF v-val-integer = 2 then yes else no.
END PROCEDURE.
PROCEDURE imagelist_decode:
    DEFINE INPUT  PARAMETER iImageList AS LONGCHAR  NO-UNDO.
    DEFINE INPUT  PARAMETER iImageGdsCode AS int    NO-UNDO.
    DEFINE OUTPUT PARAMETER oImageList AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt               AS INTEGER   NO-UNDO.
    ASSIGN
        oImageList = iImageList
        .
    DO vInt = 1 TO NUM-ENTRIES (iImageList, ",":U):
        vCh =ENTRY (vInt, iImageList, ",":U).
        IF SUBSTRING (vCh, 1, 2) = "~\~\":U THEN .
        ELSE
        DO:
            ASSIGN
                vCh = REPLACE (vCh, "~/":U, "\":U)
                vCh = REPLACE (vCh, "~\":U, "\":U)
                .
            IF SUBSTRING (vCh, 2, 2) = ":\":U OR vCh BEGINS mImageDir THEN .
            ELSE vCh = mImagePreDir + (if mPhotomgd then string(iImageGdsCode) + "\":U else '':U ) +  vCh.
            ENTRY (vInt, oImageList, ",":U) = vCh.
        END.
    END.
END PROCEDURE.
PROCEDURE imagelist_encode:
    DEFINE INPUT  PARAMETER iImageList AS LONGCHAR  NO-UNDO.
    DEFINE OUTPUT PARAMETER oImageList AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt               AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vLen               AS INTEGER   NO-UNDO.
    ASSIGN
        oImageList = iImageList
        vLen       = LENGTH (mImageDir)
        .
    DO vInt = 1 TO NUM-ENTRIES (iImageList, ",":U):
        vCh =ENTRY (vInt, iImageList, ",":U).
        IF LENGTH (vCh) > 0 AND vLen > 0 AND vCh BEGINS mImageDir THEN
            ENTRY (vInt, oImageList, ",":U) =
                SUBSTRING (vCh, vLen + 1).
    END.
END PROCEDURE.
DEFINE NEW SHARED QUERY br-out FOR out-dtl, out-prt, out-goods, out-bar, out-tt0-dtl SCROLLING.
DEFINE NEW SHARED QUERY br-ret FOR ret-dtl, ret-prt, ret-goods, ret-bar, ret-tt0-dtl SCROLLING.
DEFINE IMAGE g-image
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 11.00 BY 2.
DEFINE BUTTON b-notes
     LABEL "П&рим":L
     SIZE 8.5 BY 1.
DEFINE BUTTON b-arch
     LABEL "&Учет":L
     SIZE 8.5 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-close AUTO-GO
     LABEL "&Закрыть":L
     SIZE 10 BY 1.
DEFINE BUTTON b-res
     LABEL "Резервы&+":L
     SIZE 10 BY 1.
DEFINE BUTTON b-unres
     LABEL "Резервы&-":L
     SIZE 10 BY 1.
DEFINE BUTTON b-cash
     LABEL "В&ыручка":L
     SIZE 10 BY 1.
DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.
DEFINE BUTTON b-chk
     LABEL "Ч&еки  ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-mail
     LABEL "Прием чек&ов":L
     SIZE 12 BY 1.
DEFINE BUTTON b-troubl
     LABEL "-остатки":L
     SIZE 8.5 BY 1.
DEFINE BUTTON b-troublp
     LABEL "-партии":L
     SIZE 8.5 BY 1.
DEFINE BUTTON b-troublc
     LABEL "-чеки":L
     SIZE 8.5 BY 1.
DEFINE BUTTON b-parts
     LABEL "&Партии(товар)":L
     SIZE 14 BY 1.
DEFINE BUTTON r-trn
     LABEL "Чеки(&товар)":L
     SIZE 14 BY 1.
DEFINE BUTTON b-places
     LABEL "&Места хранения":L
     SIZE 15 BY 1.
DEFINE BUTTON b-next AUTO-GO
     LABEL ">&>":L
     SIZE 3 BY 1.
DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<":L
     SIZE 3 BY 1.
DEFINE VARIABLE auto-close AS LOGICAL INITIAL no
     LABEL "Авто"
     VIEW-AS TOGGLE-BOX
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE auto-fbr AS LOGICAL INITIAL no
     LABEL "Автопр-во"
     VIEW-AS TOGGLE-BOX
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE rest-dish AS LOGICAL INITIAL no
     LABEL "Ост-ки блюд"
     VIEW-AS TOGGLE-BOX
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE rest-ingr AS LOGICAL INITIAL no
     LABEL "Ост-ки ингр."
     VIEW-AS TOGGLE-BOX
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE rest-tpsi AS LOGICAL INITIAL no
     LABEL "Остатки ЧУЖИХ товаров"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY 1 NO-UNDO.
DEFINE VARIABLE s-pc AS DECIMAL FORMAT "->>9.<%"
     VIEW-AS FILL-IN
     SIZE 8 BY 1
     NO-UNDO.
DEFINE VARIABLE s-netto AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99"
     LABEL "Нетто"
     VIEW-AS FILL-IN
     SIZE 19 BY 1
     FGCOLOR 4  NO-UNDO.
define variable rs-sort AS CHARACTER VIEW-AS RADIO-SET HORIZONTAL RADIO-BUTTONS
"Выкл&юч.","off":U,
"Ко&лич.","quantity":U,
"&Цена","price":U,
"Ск&идка","discount":U,
"&Сумма","summa":U
SIZE 43 BY 1 NO-UNDO.
DEFINE VARIABLE prod-name-r LIKE ub.clients.obj-name
      VIEW-AS TEXT
     SIZE 50 BY 1 NO-UNDO.
DEFINE VARIABLE prod-name-v LIKE ub.clients.obj-name
      VIEW-AS TEXT
     SIZE 35 BY 1 NO-UNDO.
DEFINE VARIABLE for-discnt-chr as character
      VIEW-AS TEXT
     SIZE 19 BY 1 NO-UNDO FORMAT "X(42)".
DEFINE VARIABLE Cb-doc-kind AS CHARACTER FORMAT "X(256)":U
    VIEW-AS COMBO-BOX INNER-LINES 5
    LIST-ITEM-PAIRS "Item 1","Item 2",
                    "Item 2","Item 3"
    DROP-DOWN-LIST
    SIZE 20 BY 1
    BGCOLOR 15  NO-UNDO.
DEFINE MENU m-recs
       MENU-ITEM m-recs-1  LABEL "Все товары"                ACCELERATOR "ALT-1".
DEFINE MENU m-unrecs
       MENU-ITEM m-unrecs-1  LABEL "Все товары"                ACCELERATOR "ALT-1".
DEFINE MENU m-arch
      MENU-ITEM m-arch-i LABEL "Все документы" ACCELERATOR "ALT-1".
DEFINE MENU m-parts
      MENU-ITEM m-parts-i LABEL "По всем документам" ACCELERATOR "ALT-1".
define variable loc-art AS CHARACTER VIEW-AS fill-in size 14 by 1 fgcolor 12 no-undo.
define variable loc-name AS CHARACTER VIEW-AS fill-in size 20 by 1 fgcolor 12 no-undo.
define variable loc-code AS CHARACTER VIEW-AS fill-in size 20 by 1 fgcolor 12 no-undo.
define variable a-n-c AS CHARACTER VIEW-AS RADIO-SET HORIZONTAL RADIO-BUTTONS
"&А","art",
"&Н","name",
"&К","code"
SIZE 12 BY 1 NO-UNDO.
DEFINE BROWSE br-out QUERY br-out NO-LOCK DISPLAY
get-ok(input v-is-tpsi-obj, out-dtl.artic, out-dtl.prod-type, out-dtl.prod-code, out-dtl.prt-code, out-dtl.doc-qnty, out-dtl.fact-qnty) column-label 'OK' format "X(2)"
out-bar.b-code column-label 'Бар-код' format ">>>>>>>>>9"
out-dtl.artic column-label 'Артикул'
( get-name (input out-prt.node-name, input out-prt.upper-code, input out-goods.prt-root, input out-goods.gds-name)) column-label 'Название' format "x(35)"
out-dtl.fact-qnty column-label 'Продано' format "->>>,>>9.<<<"
out-dtl.doc-qnty column-label 'Зарезерв.' format "->>>,>>9.<<<"
out-tt0-dtl.doc-qnty column-label 'Чужих' format "->>>,>>9.<<<"
(out-tt0-dtl.obj-type + string(out-tt0-dtl.obj-code)) column-label 'Хозяин' format "X(8)"
(if v-curr-r-b = 'base':U then out-dtl.price-base else out-dtl.price-rubl) column-label 'Цена' format "->>>,>>>,>>9.<<"
(if v-curr-r-b = 'base':U then out-dtl.discnt-base else out-dtl.discnt-rubl) column-label 'Скидка'
(get-pcnt(input out-dtl.price-base,input out-dtl.price-rubl,input out-dtl.discnt-base,input out-dtl.discnt-rubl)) column-label '%' FORMAT "->>>>>9.<%"
out-goods.unit-base column-label 'Изм'
out-goods.grp-name @ v-prt-name column-label 'Название группы'
(get-prt-name (input out-prt.node-name, input out-prt.upper-code, input out-goods.prt-root, input out-prt.f-name )) column-label 'Признак' FORMAT "x(80)" width 10
out-goods.engl-name column-label 'Название англ.'
ENABLE out-goods.engl-name
WITH SIZE 98 BY 11 SEPARATORS TITLE "Продажи".
DEFINE BROWSE br-ret QUERY br-ret NO-LOCK DISPLAY
get-ok(input v-is-tpsi-obj, ret-dtl.artic, ret-dtl.prod-type, ret-dtl.prod-code, ret-dtl.prt-code, ret-dtl.doc-qnty, ret-dtl.fact-qnty) column-label 'OK' format "X(2)"
ret-bar.b-code column-label 'Бар-код' format ">>>>>>>>>9"
ret-dtl.artic column-label 'Артикул'
( get-name ( input ret-prt.node-name, input ret-prt.upper-code, input ret-goods.prt-root, input ret-goods.gds-name )) column-label 'Название' format "x(35)"
ret-dtl.fact-qnty column-label 'По чекам' format "->>>,>>9.<<<"
ret-dtl.doc-qnty column-label 'Зарезерв.' format "->>>,>>9.<<<"
v-empty column-label 'Зарезерв.' format "X(12)"
(if v-curr-r-b = 'base':U then ret-dtl.price-base else ret-dtl.price-rubl) column-label 'Цена' format "->>>,>>>,>>9.<<"
(if v-curr-r-b = 'base':U then ret-dtl.discnt-base else ret-dtl.discnt-rubl) column-label 'Скидка'
( get-pcnt(input ret-dtl.price-base,input ret-dtl.price-rubl,input ret-dtl.discnt-base,input ret-dtl.discnt-rubl)) column-label '%' FORMAT "->>>>>9.<%"
ret-goods.unit-base column-label 'Изм'
ret-goods.grp-name @ v-prt-name column-label 'Название группы'
(get-prt-name ( input ret-prt.node-name, input ret-prt.upper-code, input ret-goods.prt-root, input ret-prt.f-name )) column-label 'Признак' FORMAT "x(80)" width 10
ret-goods.engl-name column-label 'Название англ.'
ENABLE ret-goods.engl-name
WITH SIZE 98 BY 5.5 SEPARATORS TITLE "Возвраты".
DEFINE FRAME d-sale
b-exit at row 1 col 1
b-prev at row 1 col 11
b-next at row 1 col 14
b-mail at row 1 col 17
b-res     at row 1 col 29
b-unres     at row 1 col 39
b-close at row 1 col 49
b-chk at row 1 col 59
b-cash at row 1 col 69
b-print at row 1 col 79
b-help at row 1 col 89
"Поиск :" view-as text SIZE 8 BY 1 at row 2 col 2
a-n-c at row 2 col 10 no-label
auto-close AT ROW 2 COL 64  FGCOLOR 4
ink-doc.qnty AT ROW 2 COL 84 COLON-ALIGNED label "Кол-во"
ink-doc.num-chk AT ROW 3 COL 84 COLON-ALIGNED label "Чеков"
ink-doc.tot-doc AT ROW 3 COL 13 COLON-ALIGNED label "Сумма тов."
ink-doc.discnt AT ROW 3 COL 44 COLON-ALIGNED label "Общая скидка"
s-pc AT ROW 3 COL 65 COLON-ALIGNED no-label
g-image AT ROW 4 COL 88.1
for-discnt-chr AT ROW 4 COL 65 COLON-ALIGNED no-label
FGCOLOR 4
ink-doc.sub-discnt  AT ROW 4 COL 13 COLON-ALIGNED label "Списания"
s-netto AT ROW 4 COL 44 COLON-ALIGNED
rest-tpsi AT ROW 4 COL 64  FGCOLOR 4
auto-fbr AT ROW 5 COL 58  FGCOLOR 4
rest-dish AT ROW 5 COL 70  FGCOLOR 4
rest-ingr AT ROW 5 COL 84  FGCOLOR 4
br-out AT ROW 6 COL 1
b-places at row 17 col 56
r-trn at row 17 col 71
b-parts at row 17 col 85
prod-name-r AT ROW 5 COL 1  NO-LABEL
prod-name-v AT ROW 17 COL 1 NO-LABEL
cb-doc-kind at row 17 col 36 NO-LABEL
br-ret AT ROW 18 COL 1
rs-sort at row 23.5 col 1 label "Сортировка" fgcolor 4 bgcolor 8
b-troubl AT ROW 23.5 COL 55 COLON-ALIGNED
b-troublp AT ROW 23.5 COL 63.5 COLON-ALIGNED
b-troublc AT ROW 23.5 COL 72 COLON-ALIGNED
b-arch at row 23.5 col 82.5
b-notes at row 23.5 col 91
loc-art AT ROW 2 COL 37 COLON-ALIGNED label "Начало артикула"
loc-name AT ROW 2 COL 37 COLON-ALIGNED label "Начало названия" format "x(40)"
loc-code AT ROW 2 COL 37 COLON-ALIGNED label "Бар-код (весь)" format "x(13)"
SPACE(0) SKIP(0)
WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
TITLE "ПРОДАЖИ и ВОЗВРАТЫ".
def var sort-labelbr-out   as character no-undo .
def var sort-clmnbr-out    as handle    no-undo .
def var cur-clmnbr-out     as handle    no-undo .
def var cur-clmn-locbr-out as integer   no-undo .
def var re-querybr-out     as logical   initial no no-undo .
on start-search, ctrl-o of br-out in frame d-sale do:
   run sort-brbr-out
     (input (if available out-dtl
             then recid(out-dtl)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-out :
  define input parameter p-recid as recid no-undo .
  if re-querybr-out = no then do:
    assign
       cur-clmnbr-out = br-out:current-column in frame d-sale
    .
    if sort-clmnbr-out <> ? then sort-clmnbr-out:column-fgcolor = 0.
    if cur-clmnbr-out = sort-clmnbr-out then do:
      assign
         sort-labelbr-out = ""
         sort-clmnbr-out = ?
      .
     end.
     else do:
       assign
         sort-labelbr-out = cur-clmnbr-out:label
         sort-clmnbr-out  = cur-clmnbr-out
         sort-clmnbr-out:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-out = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-out:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-out then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-out = cur-clmn-locbr-out + 1
    .
  end.
  case sort-labelbr-out:
        when 'OK'  then DO:   assign       sort-column-name-out = substitute('dynamic-function(&1get-ok&1, &1&2&1, out-dtl.artic, out-dtl.prod-type, out-dtl.prod-code, out-dtl.prt-code, out-dtl.doc-qnty, out-dtl.fact-qnty)', chr(34), v-is-tpsi-obj)     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'out').   . END.
        when 'Бар-код'  then DO:    assign       sort-column-name-out = "out-bar.b-code"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'out').   . END.
        when 'Артикул'  then DO:    assign       sort-column-name-out = "out-dtl.artic"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'out').   . END.
        when 'Название'  then DO:   assign       sort-column-name-out = substitute('dynamic-function(&1GET-NAME&1, out-prt.node-name, out-prt.upper-code, out-goods.prt-root, out-goods.gds-name)', chr(34))     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'out').   . END.
        when 'Продано'  then DO:    assign       sort-column-name-out = "out-dtl.fact-qnty"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'out').   . END.
        when 'Зарезерв.'  then DO:    assign       sort-column-name-out = "out-dtl.doc-qnty"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'out').   . END.
        when 'Чужих'  then DO:    assign       sort-column-name-out = "out-tt0-dtl.doc-qnty"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'out').   . END.
        when 'Хозяин'  then DO:    assign       sort-column-name-out = "(out-tt0-dtl.obj-type + string(out-tt0-dtl.obj-code))"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'out').   . END.
        when 'Цена'  then DO:   assign       sort-column-name-out = substitute('(if &1&2&1 = &1&3&1 then out-dtl.price-base else out-dtl.price-rubl)', chr(34), v-curr-r-b,  'base':U)     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'out').   . END.
        when 'Скидка'  then DO:   assign       sort-column-name-out = substitute('(if &1&2&1 = &1&3&1 then out-dtl.discnt-base else out-dtl.discnt-rubl)', chr(34), v-curr-r-b, 'base':U)     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'out').   . END.
        when '%'  then DO:   assign       sort-column-name-out = substitute('dynamic-function(&1get-pcnt&1, out-dtl.price-base, out-dtl.price-rubl, out-dtl.discnt-base, out-dtl.discnt-rubl)', chr(34))     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'out').   . END.
        when 'Изм'  then DO:    assign       sort-column-name-out = "out-goods.unit-base"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'out').   . END.
        when 'Название группы'  then DO:    assign       sort-column-name-out = "out-goods.grp-name"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'out').   . END.
        when 'Признак'  then DO:   assign       sort-column-name-out = substitute('dynamic-function(&1get-prt-name&1, input out-prt.node-name, input out-prt.upper-code, input out-goods.prt-root, input out-prt.f-name)', chr(34))     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'out').   . END.
        when 'Название англ.'  then DO:    assign       sort-column-name-out = "out-goods.engl-name"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'out').   . END.
    otherwise do:
      assign
        sort-column-name-out = ""
      .
      run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input '':U).
      if sort-labelbr-out <> "" then do:
        assign
          cur-clmnbr-out:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-out = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-out to recid p-recid no-error.
    apply "value-changed" to br-out in frame d-sale.
  end.
  apply "entry" to br-out in frame d-sale.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-out:
if cur-clmnbr-out = ? then do:
   run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input '':U).
end.
else do:
   assign re-querybr-out = yes.
   run sort-brbr-out
     (input (if available out-dtl
             then recid(out-dtl)
             else ?
            )
     ).
   assign re-querybr-out = no.
end.
end.
def var sort-labelbr-ret   as character no-undo .
def var sort-clmnbr-ret    as handle    no-undo .
def var cur-clmnbr-ret     as handle    no-undo .
def var cur-clmn-locbr-ret as integer   no-undo .
def var re-querybr-ret     as logical   initial no no-undo .
on start-search, ctrl-o of br-ret in frame d-sale do:
   run sort-brbr-ret
     (input (if available ret-dtl
             then recid(ret-dtl)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-ret :
  define input parameter p-recid as recid no-undo .
  if re-querybr-ret = no then do:
    assign
       cur-clmnbr-ret = br-ret:current-column in frame d-sale
    .
    if sort-clmnbr-ret <> ? then sort-clmnbr-ret:column-fgcolor = 0.
    if cur-clmnbr-ret = sort-clmnbr-ret then do:
      assign
         sort-labelbr-ret = ""
         sort-clmnbr-ret = ?
      .
     end.
     else do:
       assign
         sort-labelbr-ret = cur-clmnbr-ret:label
         sort-clmnbr-ret  = cur-clmnbr-ret
         sort-clmnbr-ret:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-ret = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-ret:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-ret then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-ret = cur-clmn-locbr-ret + 1
    .
  end.
  case sort-labelbr-ret:
        when 'OK'  then DO:   assign       sort-column-name-ret = substitute('dynamic-function(&1get-ok&1, &1&2&1, ret-dtl.artic, ret-dtl.prod-type, ret-dtl.prod-code, ret-dtl.prt-code, ret-dtl.doc-qnty, ret-dtl.fact-qnty)', chr(34), v-is-tpsi-obj)     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'ret':U).   . END.
        when 'Бар-код'  then DO:    assign       sort-column-name-ret = "ret-bar.b-code"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'ret':U).   . END.
        when 'Артикул'  then DO:    assign       sort-column-name-ret = "ret-dtl.artic"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'ret':U).   . END.
        when 'Название'  then DO:   assign       sort-column-name-ret = substitute('dynamic-function(&1get-name&1, ret-prt.node-name, ret-prt.upper-code, ret-goods.prt-root, ret-goods.gds-name)', chr(34))     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'ret':U).   . END.
        when 'По чекам'  then DO:    assign       sort-column-name-ret = "ret-dtl.fact-qnty"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'ret':U).   . END.
        when 'Зарезерв.'  then DO:    assign       sort-column-name-ret = "ret-dtl.doc-qnty"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'ret':U).   . END.
        when 'Зарезерв.'  then DO:    assign       sort-column-name-ret = "v-empty"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'ret':U).   . END.
        when 'Цена'  then DO:   assign       sort-column-name-ret = substitute('(if &1&2&1 = &1&3&1 then ret-dtl.price-base else ret-dtl.price-rubl)',  chr(34), v-curr-r-b, 'base':U)     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'ret':U).   . END.
        when 'Скидка'  then DO:   assign       sort-column-name-ret = substitute('(if &1&2&1 = &1&3&1 then ret-dtl.discnt-base else ret-dtl.discnt-rubl)', chr(34), v-curr-r-b, 'base':U)     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'ret':U).   . END.
        when '%'  then DO:   assign       sort-column-name-ret = substitute('dynamic-function(&1get-pcnt&1, input ret-dtl.price-base, input ret-dtl.price-rubl, input ret-dtl.discnt-base, input ret-dtl.discnt-rubl)', chr(34))     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'ret':U).   . END.
        when 'Изм'  then DO:    assign       sort-column-name-ret = "ret-goods.unit-base"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'ret':U).   . END.
        when 'Название группы'  then DO:    assign       sort-column-name-ret = "ret-goods.grp-name"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'ret':U).   . END.
        when 'Признак'  then DO:   assign       sort-column-name-ret = substitute('dynamic-function(&1get-prt-name&1, ret-prt.node-name, ret-prt.upper-code, ret-goods.prt-root, ret-prt.f-name)', chr(34))     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'ret':U).   . END.
        when 'Название англ.'  then DO:    assign       sort-column-name-ret = "ret-goods.engl-name"     .     run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'ret':U).   . END.
    otherwise do:
      assign
        sort-column-name-ret = ""
      .
      run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input '':U).
      if sort-labelbr-ret <> "" then do:
        assign
          cur-clmnbr-ret:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-ret = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-ret to recid p-recid no-error.
    apply "value-changed" to br-ret in frame d-sale.
  end.
  apply "entry" to br-ret in frame d-sale.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-ret:
if cur-clmnbr-ret = ? then do:
   run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input '':U).
end.
else do:
   assign re-querybr-ret = yes.
   run sort-brbr-ret
     (input (if available ret-dtl
             then recid(ret-dtl)
             else ?
            )
     ).
   assign re-querybr-ret = no.
end.
end.
ASSIGN FRAME d-sale:SCROLLABLE       = FALSE
             br-out:NUM-LOCKED-COLUMNS IN FRAME d-sale = 2
             br-ret:NUM-LOCKED-COLUMNS IN FRAME d-sale = 2.
ASSIGN b-res:POPUP-MENU IN FRAME d-sale = MENU m-recs:HANDLE.
ASSIGN b-res:MENU-MOUSE = 1.
ASSIGN b-unres:POPUP-MENU IN FRAME d-sale = MENU m-unrecs:HANDLE.
ASSIGN b-unres:MENU-MOUSE = 1.
ASSIGN b-arch:POPUP-MENU IN FRAME d-sale = MENU m-arch:HANDLE.
ASSIGN b-arch:MENU-MOUSE = 1.
ASSIGN b-troublp:POPUP-MENU IN FRAME d-sale = MENU m-parts:HANDLE.
ASSIGN b-troublp:MENU-MOUSE = 1.
ON MOUSE-SELECT-DBLCLICK OF g-image IN FRAME d-sale
DO:
    RUN ref/imagelist.w (PARPARENTPROC, "":U, v-gds-code,'ПРОСМОТР':U).
END.
ON ENTRY OF
br-out,
BR-RET
IN FRAME d-sale DO:
  assign
  current-browser = self
  qh = current-browser:query
  bh = qh:get-buffer-handle(1)
  brwh = self
  .
END.
ON choose OF MENU-ITEM m-arch-i in menu m-arch DO:
    apply "choose" to b-arch in frame d-sale.
END.
ON choose OF MENU-ITEM m-parts-i in menu m-parts DO:
    apply "choose" to b-troublp in frame d-sale.
END.
ON choose OF MENU-ITEM m-recs-1 in menu m-recs DO:
assign
rdoc-line = ?
rgds-dtl = ?
r-or-v = ?
r-office = ?
r-qnty = ?
r-b-code = ?
r-pl-code = ?
r-doc-prts-qnty = ?
from-menu = yes.
assign
auto-close = input frame d-sale auto-close
auto-fbr
rest-dish
rest-ingr
rest-tpsi
.
if auto-close then do:
  glog = no.
  message
  (IF not b-mail-pressed then "В течение данного сеанса работы с продажей вы не докачивали новые чеки!"
                          else "")
  "ВНИМАНИЕ!!! Включен режим автоматического закрытия продажи по результатам резервирования!"
  skip "Вы уверены, что хотите закрыть продажу?" view-as alert-box WARNING
  buttons YES-NO update glog.
  if not glog then return no-apply.
end.
    run b-res-proc in this-procedure (
                                       buffer ink-doc
                                     , buffer t-doc
                                     , buffer ret-doc
                                     , input no
                                     , input auto-close
                                     , input no
                                     , input rest-dish
                                     , input "":U
                                     , input v-is-tpsi-obj
                                     , input rest-tpsi) no-error .
    if error-status:error  or return-value = "error" then do:
      run waitfram-hide in this-procedure .
      return no-apply.
    end.
    if auto-close and b-close:sensitive in frame d-sale then do:
      assign
      v-parameter =     v-curr-r-b                     + chr(4) +
                        ink-doc.inkas-code             + chr(4) +
                      string(0)              + chr(4) +
                      string(auto-close)               + chr(4) +
                      string(b-mail-pressed)           + chr(4) +
                      string(auto-comp)                + chr(4) +
                      string(auto-fbr)                 + chr(4) +
                      string(one-curs)                 + chr(4) +
                      string(ub.shop.is-catering)      + chr(4) +
                      string(v-is-tpsi-obj)            + chr(4) +
                      string(rest-dish)                + chr(4) +
                      string(rest-ingr)                + chr(4) +
                      string(rest-tpsi)                + chr(4) +
                      string(neg-tpsi-weight)          + chr(4) +
                      string(neg-tpsi-qnty)            + chr(4) +
                      string(neg-tpsi-oper)            + chr(4) +
                      string(close-in-rfsl)            + chr(4) +
                      pay-gds-algo
     .
        run str/diallog.w (
              input parParentProc
            , input this-procedure
            , input ("str/saleclos.p":U + chr(4) + "1":U +
                    "1":U  + chr(4) +
                    "1":U + chr(4) +
                    "1":U)
            , input v-parameter
            , input no
            , input "":U
            , input substitute("Закрытие продажи &1", Ink-doc.inkas-code)
        ) no-error.
        if error-status:error
        or return-value = "error":U
        then do:
            run close-error-processing in this-procedure.
            return no-apply.
        end.
        else do:
          assign
          p-next-prev = ?.
          APPLY "CHOOSE" to b-exit.
        end.
    end.
    APPLY "ENTRY" to br-out.
END.
ON choose OF MENU-ITEM m-unrecs-1 in menu m-unrecs DO:
assign
rdoc-line = ?
rgds-dtl = ?
r-or-v = ?
r-office = ?
r-qnty = ?
r-b-code = ?
r-pl-code = ?
r-doc-prts-qnty = ?
from-menu = yes.
apply "choose" to b-unres in frame d-sale.
APPLY "ENTRY" to br-out.
END.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref33 as character no-undo .
define variable varpgscales-pref33 as character no-undo.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type34 as character no-undo.
varscales-pref33  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref33
  ,output varscales-pref-type34
  ) no-error .
if varscales-pref33 = ? then do:
  assign
  varscales-pref33 = '21,23,25':U.
end.
define variable varpgscales-pref-type34 as character no-undo.
varpgscales-pref33  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref33
  ,output varpgscales-pref-type34
  ) no-error .
if varpgscales-pref33 = ? then do:
  assign
  varpgscales-pref33 = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
on value-changed of a-n-c in frame d-sale do:
  run proc-valchg-a-n-c in this-procedure  no-error.
  return no-apply.
end.
on any-printable of br-out in frame d-sale do:
  run proc-any-printable-br-out in this-procedure   no-error.
  return no-apply.
end.
on backspace of br-out in frame d-sale do:
  run proc-backspace-br-out in this-procedure   no-error.
  return no-apply.
end.
ON return OF loc-code IN FRAME d-sale do:
  run proc-mouse-dbl-click-loc-code in this-procedure   no-error.
  return no-apply.
end.
ON return, Ctrl-J OF loc-name IN FRAME d-sale do:
  run proc-mouse-dbl-click-loc-name in this-procedure   no-error.
  return no-apply.
end.
PROCEDURE proc-valchg-a-n-c:
  case input frame d-sale a-n-c :
    when "art" then do:
      apply "entry" to br-out in frame d-sale.
      hide loc-name loc-code
      in frame d-sale.
      loc-art = "".
    end.
    when "name" then do:
      enable loc-name with frame d-sale.
      disp loc-name with frame d-sale.
      hide loc-art loc-code
      in frame d-sale.
      apply "entry" to loc-name in frame d-sale.
    end.
    when "code"
 or when "DataMatrix" then
    do:
      enable loc-code with frame d-sale.
      disp loc-code with frame d-sale.
      hide loc-art loc-name
      in frame d-sale.
      apply "entry" to loc-code in frame d-sale.
    end.
  end CASE.
END PROCEDURE.
PROCEDURE proc-any-printable-br-out :
  if input frame d-sale a-n-c = "art" then do:
    if last-event:label = " " and
       loc-art = "" then
    return error.
    find first l-out-dtl where
               (l-out-dtl.doc-code = ink-doc.inkas-code) and l-out-dtl.artic begins (loc-art + last-event:label)
               no-lock no-error.
    if available l-out-dtl then do:
      loc-art = loc-art + last-event:label.
      disp loc-art with frame d-sale.
      line-rec = recid (l-out-dtl).
      reposition br-out to recid line-rec no-error.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-backspace-br-out:
  if input frame d-sale a-n-c = "art" then do:
    if loc-art = "" then
      return error.
    loc-art = substr (loc-art, 1, length (loc-art) - 1).
    find first l-out-dtl where
               (l-out-dtl.doc-code = ink-doc.inkas-code) and l-out-dtl.artic begins loc-art
               no-lock.
    disp loc-art with frame d-sale.
    line-rec = recid (l-out-dtl).
    reposition br-out to recid line-rec no-error.
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
  frame d-sale
  loc-code
  a-n-c.
  if a-n-c = "datamatrix"
  then do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_dm-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  p-obj-type
,input  p-obj-code
,input  yes
,input  no
,input  varscales-pref33
,input  varpgscales-pref33
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
     if varresult eq "prod-bc"
     then
        loc-code:screen-value in frame d-sale = buf_prod-bc.b-str.
  end.
  else do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  p-obj-type
,input  p-obj-code
,input  yes
,input  no
,input  varscales-pref33
,input  varpgscales-pref33
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
        find first l-out-dtl where (l-out-dtl.doc-code = ink-doc.inkas-code) and
                  l-out-dtl.artic = l-goods.artic AND
                  l-out-dtl.prod-type = l-goods.prod-type AND
                  l-out-dtl.prod-code = l-goods.prod-code no-lock no-error.
    if available l-out-dtl then do:
      line-rec = recid (l-out-dtl).
      reposition br-out to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  end.
  else
    message "Бар-код не найден."
            view-as alert-box error.
  apply "entry" to loc-code in frame d-sale.
END PROCEDURE.
PROCEDURE  proc-mouse-dbl-click-loc-name:
  assign
  frame d-sale
  loc-name.
    if last-event:label = "Ctrl-J" then
      find next l-out-dtl where (l-out-dtl.doc-code = ink-doc.inkas-code) and
                can-find (ub.goods where ub.goods.artic = l-out-dtl.artic and
                ub.goods.prod-type = l-out-dtl.prod-type and
                ub.goods.prod-code = l-out-dtl.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    else
      find first l-out-dtl where (l-out-dtl.doc-code = ink-doc.inkas-code) and
                can-find (ub.goods where ub.goods.artic = l-out-dtl.artic and
                ub.goods.prod-type = l-out-dtl.prod-type and
                ub.goods.prod-code = l-out-dtl.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if available l-out-dtl then do:
      line-rec = recid (l-out-dtl).
      reposition br-out to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  apply "entry" to loc-name in frame d-sale.
END PROCEDURE.
on value-changed of br-out in frame d-sale do:
if not available out-dtl or recid (out-dtl) <> line-rec then do:
    hide loc-art in frame d-sale.
    loc-art = "".
end.
end.
on choose of b-cash in frame d-sale
do:
    run str/ink-oth.w ( input parparentproc, ink-doc.inkas-code).
    apply "entry" to br-out in frame d-sale.
end.
on choose of b-print in frame d-sale
do:
DEFINE VARIABLE v-frame-width as integer no-undo .
define buffer t-clients for ub.clients.
    run rep/sale-prn.p (
                     input parparentproc
                    ,input recid(ink-doc)
                    ,input yes).
    apply "entry" to br-out in frame d-sale.
end.
ON RIGHT-MOUSE-CLICK OF br-out
or RIGHT-MOUSE-CLICK OF BR-ret
IN FRAME d-sale
DO:
define buffer buf_tt0-info for tt0-info.
assign
current-browser = self.
qh = current-browser:query.
bh = qh:get-buffer-handle(1).
brwh = self .
if not bh:available then return no-apply.
assign
v-artic    = bh:buffer-field('artic':U):buffer-value
v-prod-type  = bh:buffer-field('prod-type':U):buffer-value
v-node-code  = bh:buffer-field('prt-code':U):buffer-value
.
FIND FIRST buf_tt0-info WHERE
          buf_tt0-info.artic = v-artic
      and buf_tt0-info.prod-type = v-prod-type
      and buf_tt0-info.prod-code = v-prod-code
      and buf_tt0-info.prt-code = v-node-code no-error .
 if available buf_tt0-info then do:
   message
   buf_tt0-info.error-message
   view-as alert-box .
 end.
END.
on choose of b-troubl in frame d-sale
do:
define buffer buf_tt0-gds-dtl for tt0-gds-dtl.
define buffer buf_tt0-doc-line for tt0-doc-line.
    RUN neg-rests in this-procedure (
                   input no
                  , input ink-doc.status_
                  , input ink-doc.inkas-code
                  , input (if ink-doc.status_ = 'факт':U
                          or ink-doc.status_ = 'запрос':U
                          then 'ПРОСМОТР':U else 'ИЗМЕНЕНИЕ':U)
                  , input ub.shop.is-catering
                  , input v-is-tpsi-obj
                  , input neg-tpsi-weight
                  , input neg-tpsi-qnty
                  , input neg-tpsi-oper
                  ).
    IF can-find (first dtl-rests) then do:
        run str/badsale.w (
              input parparentproc
            , input p-mode
            , input ink-doc.inkas-code
            , input shop.is-catering
            , input v-is-tpsi-obj
            , input neg-tpsi-oper
          ).
apply "entry" to br-out in frame d-sale.
for each dtl-rests:
    if t-doc.status_ <> 'факт':U
    and t-doc.status_ <> 'запрос':U
    and p-mode = 'ИЗМЕНЕНИЕ':U
    and v-is-tpsi-obj
    and dtl-rests.is-neg-tpsi-oper then do:
      find first dtl-rests-mark where
                dtl-rests-mark.artic = dtl-rests.artic
            and dtl-rests-mark.prod-type = dtl-rests.prod-type
            and dtl-rests-mark.prod-code = dtl-rests.prod-code no-error .
      if not available dtl-rests-mark then do:
        create dtl-rests-mark.
        buffer-copy dtl-rests to dtl-rests-mark.
        release dtl-rests-mark.
      end.
    end.
    delete dtl-rests.
  end.
  if can-do( 'ИЗМЕНЕНИЕ':U, p-mode ) then do:
    disable b-close
    with frame d-sale .
    b-close-enabled = no.
    RUN button-close in this-procedure (
                                            buffer t-doc
                                            ,buffer ret-doc
                                            ,input v-is-tpsi-obj
                                            ,input auto-fbr
                                            ,input neg-tpsi-weight
                                            ,input neg-tpsi-qnty
                                            ,input neg-tpsi-oper
                                            ,Output b-close-enabled).
    ENABLE
    b-close when ((auto-comp
                  and can-find(first ub.sale-doc where
                                    ub.sale-doc.inkas-code = ink-doc.inkas-code
                                and ub.sale-doc.doc-kind = 'rs':U)
                  )
                  OR b-close-enabled)
    with frame d-sale .
  end.
end.
else do:
    message "Не найдено ошибок для товаров, по которым недопустимы отрицательные остатки!"
    view-as alert-box.
    apply "entry" to br-out in frame d-sale.
end.
end.
on choose of b-troublp in frame d-sale
do:
define buffer buf_sale-doc for ub.sale-doc.
for each buf_sale-doc where
       buf_Sale-doc.inkas-code = ink-doc.inkas-code:
  if buf_sale-doc.doc-kind = 'rwo':U then NEXT.
  FIND FIRST ub.parts where
          ub.parts.out-code = buf_sale-doc.doc-code
      AND ub.parts.out-code = ub.parts.in-code NO-LOCK NO-ERROR.
  if available parts then do:
    LEAVE.
  end.
end.
if not available parts then do:
  message
  "Нет отрицательных партий, порожденных данной продажей!"
  view-as alert-box .
  return no-apply.
end.
run str/badsalp.w ( input parparentproc
                  , input recid(ink-doc)
                  , input recid(ub.goods)).
apply "entry" to br-out in frame d-sale.
end.
on choose of b-parts in frame d-sale
do:
    run proc-parts-tovar in this-procedure no-error.
    if error-status:error then return no-apply.
end.
on choose of b-chk in frame d-sale do:
define variable r-rec as recid.
define variable v-rec as recid.
DEFINE VARIABLE varrid-list as character no-undo .
define buffer t-clients for ub.clients.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
glog = yes.
FIND FIRST t-clients NO-LOCK WHERE
                    t-clients.obj-code = ink-doc.obj-code AND
                    t-clients.obj-type = ink-doc.obj-type
    No-ERROR.
IF t-clients.db-num <> g#db-num and g#db-num <> 0 then do:
    if YES then
    message "Нельзя получить информацию по чекам объекта "  ink-doc.obj-code ink-doc.obj-type
    "в базе данных N " g#db-num
    view-as alert-box.
    glog = no.
end.
else if g#db-num = 0 AND t-clients.db-num <> g#db-num then do:
    FIND FIRST ub.db No-LOCK WHERE ub.db.db-num = t-clients.db-num No-ERROR.
    if NOT ub.db.send-check then do:
        if YES then
        message "Нельзя получить информацию по чекам объекта "  ink-doc.obj-code ink-doc.obj-type
        "в базе данных N " g#db-num
        view-as alert-box.
        glog = no.
    end.
end.
    if NOT glog then return no-apply.
    assign
    r-rec = bh-out-dtl:recid
    v-rec = bh-ret-dtl:recid
    .
    run str/chk-docs.w (
                     input parparentproc
                    ,input  (if p-mode = 'ПРОСМОТР':U then '':U else "b-del":U)
                    ,input 'продажа':U
                    ,input ?
                    ,input ink-doc.obj-type
                    ,input ink-doc.obj-code
                    ,input ink-doc.inkas-code
                    ,input '':U
                    ,input 0
                    ,input  ?
                    ,input  ?
                    ,input 0
                    ,output varrid-list) no-error.
  if p-mode = 'ИЗМЕНЕНИЕ':U and return-value = "deleted" then do:
    run reget-br-2 in this-procedure .
    run UI-on in this-procedure .
  end.
  apply "entry" to br-out in frame d-sale.
end.
on end-error, stop of frame d-sale
do:
  run waitfram-hide in this-procedure .
  apply "CHOOSE" to b-exit in frame d-sale.
  return no-apply.
end.
ON CHOOSE OF b-exit IN FRAME d-sale
DO:
    p-next-prev = ?.
END.
ON CHOOSE OF b-close IN FRAME d-sale
DO:
    assign
    auto-close
    auto-fbr
    rest-dish
    rest-ingr
    rest-tpsi
    .
    assign
    v-parameter =     v-curr-r-b                     + chr(4) +
                      ink-doc.inkas-code             + chr(4) +
                    string(0)              + chr(4) +
                    string(auto-close)               + chr(4) +
                    string(b-mail-pressed)           + chr(4) +
                    string(auto-comp)                + chr(4) +
                    string(auto-fbr)                 + chr(4) +
                    string(one-curs)                 + chr(4) +
                    string(ub.shop.is-catering)      + chr(4) +
                    string(v-is-tpsi-obj)            + chr(4) +
                    string(rest-dish)                + chr(4) +
                    string(rest-ingr)                + chr(4) +
                    string(rest-tpsi)                + chr(4) +
                    string(neg-tpsi-weight)          + chr(4) +
                    string(neg-tpsi-qnty)            + chr(4) +
                    string(neg-tpsi-oper)            + chr(4) +
                    string(close-in-rfsl)            + chr(4) +
                    pay-gds-algo
    .
    run str/diallog.w (
          input parParentProc
        , input this-procedure
        , input ("str/saleclos.p":U + chr(4) + "1":U +
                "1":U  + chr(4) +
                "1":U + chr(4) +
                "1":U)
        , input v-parameter
        , input no
        , input "":U
        , input substitute("Закрытие продажи &1", Ink-doc.inkas-code)
    ) no-error.
    if error-status:error
    or return-value = "error":U
    then do:
       run close-error-processing in this-procedure.
       return no-apply.
    end.
    else do:
      assign
      p-next-prev = ?.
    end.
END.
ON CHOOSE OF b-res IN FRAME d-sale
DO:
    assign
    auto-close
    auto-fbr
    rest-dish
    rest-ingr
    rest-tpsi
    .
    if auto-close then do:
        glog = no.
        message
        (IF not b-mail-pressed then "В течение данного сеанса работы с продажей вы не докачивали новые чеки!"
                            else "")
        "ВНИМАНИЕ!!! Включен режим автоматического закрытия продажи по результатам резервирования!"
        skip "Вы уверены, что хотите закрыть продажу?" view-as alert-box WARNING
        buttons YES-NO update glog.
        if not glog then return no-apply.
    end.
    run b-res-proc in this-procedure (
                                      buffer ink-doc
                                     , buffer t-doc
                                     , buffer ret-doc
                                    , input no
                                    , input auto-close
                                    , input no
                                    , input rest-dish
                                    , input "":U
                                    , input v-is-tpsi-obj
                                    , input rest-tpsi) no-error.
    if error-status:error or return-value = "error" then do:
      run waitfram-hide in this-procedure .
      return no-apply.
    end.
    if auto-close and b-close:sensitive then do:
      assign
      v-parameter =     v-curr-r-b                     + chr(4) +
                        ink-doc.inkas-code             + chr(4) +
                      string(0)              + chr(4) +
                      string(auto-close)               + chr(4) +
                      string(b-mail-pressed)           + chr(4) +
                      string(auto-comp)                + chr(4) +
                      string(auto-fbr)                 + chr(4) +
                      string(one-curs)                 + chr(4) +
                      string(ub.shop.is-catering)      + chr(4) +
                      string(v-is-tpsi-obj)            + chr(4) +
                      string(rest-dish)                + chr(4) +
                      string(rest-ingr)                + chr(4) +
                      string(rest-tpsi)                + chr(4) +
                      string(neg-tpsi-weight)          + chr(4) +
                      string(neg-tpsi-qnty)            + chr(4) +
                      string(neg-tpsi-oper)            + chr(4) +
                      string(close-in-rfsl)            + chr(4) +
                      pay-gds-algo
      .
      run str/diallog.w (
            input parParentProc
          , input this-procedure
          , input ("str/saleclos.p":U + chr(4) + "1":U +
                  "1":U  + chr(4) +
                  "1":U + chr(4) +
                  "1":U)
          , input v-parameter
          , input no
          , input "":U
          , input substitute("Закрытие продажи &1", Ink-doc.inkas-code)
      ) no-error.
        if error-status:error
        or return-value = "error":U
        then do:
            run close-error-processing in this-procedure.
            return no-apply.
        end.
        else do:
          assign
          p-next-prev = ?.
          APPLY "CHOOSE" to b-exit.
        end.
    end.
END.
ON CHOOSE OF b-unres IN FRAME d-sale
DO:
assign
rest-tpsi
.
run b-unres-proc (
                    buffer ink-doc
                  , buffer t-doc
                  , buffer ret-doc
                  , input v-is-tpsi-obj
                  , input no  ) No-error.
if error-status:error then do:
   run waitfram-hide in this-procedure .
   return no-apply.
 end.
END.
ON return, MOUSE-SELECT-DBLCLICK OF br-out
or return, MOUSE-SELECT-DBLCLICK OF br-ret IN FRAME d-sale
DO:
  if self:sensitive then do:
    apply "choose" to r-trn in frame d-sale.
  end.
  return no-apply.
END.
ON choose OF r-trn IN FRAME d-sale
DO:
define buffer t-clients for ub.clients.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
glog = yes.
FIND FIRST t-clients NO-LOCK WHERE
                    t-clients.obj-code = ink-doc.obj-code AND
                    t-clients.obj-type = ink-doc.obj-type
    No-ERROR.
IF t-clients.db-num <> g#db-num and g#db-num <> 0 then do:
    if YES then
    message "Нельзя получить информацию по чекам объекта "  ink-doc.obj-code ink-doc.obj-type
    "в базе данных N " g#db-num
    view-as alert-box.
    glog = no.
end.
else if g#db-num = 0 AND t-clients.db-num <> g#db-num then do:
    FIND FIRST ub.db No-LOCK WHERE ub.db.db-num = t-clients.db-num No-ERROR.
    if NOT ub.db.send-check then do:
        if YES then
        message "Нельзя получить информацию по чекам объекта "  ink-doc.obj-code ink-doc.obj-type
        "в базе данных N " g#db-num
        view-as alert-box.
        glog = no.
    end.
end.
    if NOT glog then return no-apply.
    run proc-chek-tovar in this-procedure no-error.
    IF error-status:error then return no-apply.
END.
ON choose OF b-places IN FRAME d-sale
DO:
    run proc-places in this-procedure no-error.
    IF error-status:error then return no-apply.
    if v-to-reserv then do :
        assign
            auto-close
            auto-fbr
            rest-dish
            rest-ingr
            rest-tpsi
        .
        if auto-close then do:
            glog = no.
            message
            (IF not b-mail-pressed then "В течение данного сеанса работы с продажей вы не докачивали новые чеки!"
                                else "")
            "ВНИМАНИЕ!!! Включен режим автоматического закрытия продажи по результатам резервирования!"
            skip "Вы уверены, что хотите закрыть продажу?" view-as alert-box WARNING
            buttons YES-NO update glog.
            if not glog then return no-apply.
        end.
        run b-res-proc in this-procedure (
                                          buffer ink-doc
                                         , buffer t-doc
                                         , buffer ret-doc
                                        , input no
                                        , input auto-close
                                        , input no
                                        , input rest-dish
                                        , input "":U
                                        , input v-is-tpsi-obj
                                        , input rest-tpsi) no-error.
        if error-status:error or return-value = "error" then do:
          run waitfram-hide in this-procedure .
          return no-apply.
        end.
        if auto-close and b-close:sensitive then do:
          assign
          v-parameter =     v-curr-r-b                     + chr(4) +
                            ink-doc.inkas-code             + chr(4) +
                          string(0)              + chr(4) +
                          string(auto-close)               + chr(4) +
                          string(b-mail-pressed)           + chr(4) +
                          string(auto-comp)                + chr(4) +
                          string(auto-fbr)                 + chr(4) +
                          string(one-curs)                 + chr(4) +
                          string(ub.shop.is-catering)      + chr(4) +
                          string(v-is-tpsi-obj)            + chr(4) +
                          string(rest-dish)                + chr(4) +
                          string(rest-ingr)                + chr(4) +
                          string(rest-tpsi)                + chr(4) +
                          string(neg-tpsi-weight)          + chr(4) +
                          string(neg-tpsi-qnty)            + chr(4) +
                          string(neg-tpsi-oper)            + chr(4) +
                          string(close-in-rfsl)            + chr(4) +
                          pay-gds-algo
          .
          run str/diallog.w (
                input parParentProc
              , input this-procedure
              , input ("str/saleclos.p":U + chr(4) + "1":U +
                      "1":U  + chr(4) +
                      "1":U + chr(4) +
                      "1":U)
              , input v-parameter
              , input no
              , input "":U
              , input substitute("Закрытие продажи &1", Ink-doc.inkas-code)
          ) no-error.
            if error-status:error
            or return-value = "error":U
            then do:
                run close-error-processing in this-procedure.
                return no-apply.
            end.
            else do:
              assign
              p-next-prev = ?.
              APPLY "CHOOSE" to b-exit.
            end.
        end.
    end.
END.
ON choose OF b-notes IN FRAME d-sale
DO:
define variable notes as character no-undo .
define variable v-recid as recid no-undo .
notes = substr(ink-doc.PS, index(ink-doc.PS, "@") + 1).
v-recid = recid(ink-doc).
run gbl/notes.w ( input p-mode, input-output notes ).
if ink-doc.PS <> notes then  do:
    do on stop undo, return no-apply:
        FIND FIRST ink-doc WHERE recid (ink-doc) = p-doc-rec exclusive.
        ink-doc.PS = substr(ink-doc.PS, 1, index(ink-doc.PS, "@")) +  notes.
    end.
end.
END.
ON choose OF b-troublc IN FRAME d-sale
DO:
define variable r-rec as recid.
define variable v-rec as recid.
define variable glog as logical no-undo .
define buffer t-clients for ub.clients.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
glog = yes.
FIND FIRST t-clients NO-LOCK WHERE
                    t-clients.obj-code = ink-doc.obj-code AND
                    t-clients.obj-type = ink-doc.obj-type
    No-ERROR.
IF t-clients.db-num <> g#db-num and g#db-num <> 0 then do:
    if YES then
    message "Нельзя получить информацию по чекам объекта "  ink-doc.obj-code ink-doc.obj-type
    "в базе данных N " g#db-num
    view-as alert-box.
    glog = no.
end.
else if g#db-num = 0 AND t-clients.db-num <> g#db-num then do:
    FIND FIRST ub.db No-LOCK WHERE ub.db.db-num = t-clients.db-num No-ERROR.
    if NOT ub.db.send-check then do:
        if YES then
        message "Нельзя получить информацию по чекам объекта "  ink-doc.obj-code ink-doc.obj-type
        "в базе данных N " g#db-num
        view-as alert-box.
        glog = no.
    end.
end.
  if NOT glog then return no-apply.
  assign
  r-rec = recid(out-dtl)
  v-rec= recid(ret-dtl)
  .
  run str/badcheck.w (
                    input parparentproc
                  , input p-mode
                  , buffer ink-doc
                  , input prcl-spl
                  , input v-curr-r-b) no-error .
  if return-value = "yes" then do:
      run UI-on in this-procedure .
      apply "entry" to br-out in frame d-sale.
      reposition br-out to recid r-rec no-error.
  end.
  apply "entry" to br-out in frame d-sale.
END.
ON CHOOSE OF b-mail IN FRAME d-sale
or Right-Mouse-CLICK OF b-mail IN FRAME d-sale
DO:
  if last-event:lABEL = "CHOOSE"
  or last-event:lABEL = "ENTER"
  then do:
    run str/diallog.w (
                  input parparentproc
                , input this-procedure
                , input 'str/get-chkf.p':U
                , input (p-obj-type + chr(4) + string(p-obj-code) + chr(4) + string(0))
                , input (if auto-get-res then yes else no)
                , input '':U
                , input 'Прием чеков с касс') no-error .
    if error-status:error then return no-apply.
  end.
  p-doc-rec = recid (ink-doc).
  DO TRANSACTION on ERROR undo, return no-apply
                        on STOP undo, return no-apply :
    run str/inc-sale.w (
                      input parparentproc
                    , input 'ИЗМЕНЕНИЕ':U
                    , input ink-doc.host-code
                    , input ink-doc.obj-type
                    , input ink-doc.obj-code
                    , input auto-get-res
                    , input no
                    , buffer ink-doc
                    ) NO-ERROR.
    if return-value = "cancell":U then undo, return no-apply .
    run reget-br-2 in this-procedure .
  END.
  RUN UI-on in this-procedure .
  b-mail-pressed = yes.
  if auto-get-res then do:
    assign
    auto-close
    auto-fbr
    rest-dish
    rest-ingr
    rest-tpsi
    .
    if auto-close then do:
            glog = no.
        message
        "ВНИМАНИЕ!!! Включен режим автоматического закрытия продажи по результатам резервирования!"
        skip "Вы уверены, что хотите закрыть продажу?" view-as alert-box WARNING
        buttons YES-NO update glog.
        if not glog then return no-apply.
    end.
    run b-res-proc in this-procedure (
                                      buffer ink-doc
                                    , buffer t-doc
                                    , buffer ret-doc
                                    , input no
                                    , input auto-close
                                    , input no
                                    , input rest-dish
                                    , input "":U
                                    , input v-is-tpsi-obj
                                    , input rest-tpsi) no-error.
    if error-status:error or return-value = "error" then do:
      run waitfram-hide in this-procedure .
      return no-apply.
    end.
    if auto-close and b-close:sensitive then do:
      assign
      v-parameter =     v-curr-r-b                     + chr(4) +
                        ink-doc.inkas-code             + chr(4) +
                      string(0)              + chr(4) +
                      string(auto-close)               + chr(4) +
                      string(b-mail-pressed)           + chr(4) +
                      string(auto-comp)                + chr(4) +
                      string(auto-fbr)                 + chr(4) +
                      string(one-curs)                 + chr(4) +
                      string(ub.shop.is-catering)      + chr(4) +
                      string(v-is-tpsi-obj)            + chr(4) +
                      string(rest-dish)                + chr(4) +
                      string(rest-ingr)                + chr(4) +
                      string(rest-tpsi)                + chr(4) +
                      string(neg-tpsi-weight)          + chr(4) +
                      string(neg-tpsi-qnty)            + chr(4) +
                      string(neg-tpsi-oper)            + chr(4) +
                      string(close-in-rfsl)            + chr(4) +
                      pay-gds-algo
      .
      run str/diallog.w (
            input parParentProc
          , input this-procedure
          , input ("str/saleclos.p":U + chr(4) + "1":U +
                  "1":U  + chr(4) +
                  "1":U + chr(4) +
                  "1":U)
          , input v-parameter
          , input no
          , input "":U
          , input substitute("Закрытие продажи &1", Ink-doc.inkas-code)
      ) no-error.
      if error-status:error
      or return-value = "error":U
        then do:
          run close-error-processing in this-procedure.
          return no-apply.
      end.
      else do:
        assign
        p-next-prev = ?.
        APPLY "CHOOSE" to b-exit.
      end.
    end.
  end.
END.
ON VALUE-CHANGED OF Cb-doc-kind IN FRAME d-sale
DO:
define buffer buf_sale-doc for ub.sale-doc.
ASSIGN
CB-doc-kind
br-2-mode = CB-doc-kind
.
find first buf_sale-doc where
          buf_sale-doc.inkas-code = ink-doc.inkas-code
      and buf_sale-doc.doc-kind = entry(1, br-2-mode, chr(4))
      and buf_sale-doc.chr-office = entry(2, br-2-mode, chr(4)).
br-2-doc-code = buf_sale-doc.doc-code.
run openbr in this-procedure ( input ink-doc.inkas-code,  input br-2-doc-code, input yes, input no, input '':U, input '':U).
APPLY "value-changed" to br-out.
APPLY "value-changed" to br-ret.
run enable-menu-items in this-procedure .
END.
ON value-changed OF rs-sort IN FRAME d-sale
DO:
  rs-sort = input frame d-sale rs-sort.
  assign
  sort-column-name-out = '':U
  sort-column-name-ret = '':U
  .
  RUN UI-on in this-procedure .
END.
ON value-changed OF auto-fbr IN FRAME d-sale
DO:
  assign
  auto-fbr.
  case auto-fbr:
    when yes then do:
      display
      rest-dish
      rest-ingr
      with frame d-sale .
      enable
      rest-dish
      rest-ingr
      with frame d-sale .
    end.
    when no then do:
      disable
      rest-dish
      rest-ingr
      with frame d-sale .
      hide
      rest-dish
      rest-ingr
      in frame d-sale .
    end.
  END.
END.
ON value-changed OF rest-tpsi IN FRAME d-sale
DO:
    assign rest-tpsi.
END.
ON value-changed OF
br-out,
br-ret IN FRAME d-sale DO:
qh = self:query.
bhg = qh:get-buffer-handle(3).
gds-rec = bhg:recid.
if not bhg:available then return no-apply.
assign
v-prod-type = bhg:buffer-field('prod-type':U):buffer-value
v-prod-code = bhg:buffer-field('prod-code':U):buffer-value
v-gds-code = bhg:buffer-field('gds-code':U):buffer-value
.
 FIND FIRST ub.clients where
          ub.clients.obj-type = v-prod-type
      AND ub.clients.obj-code = v-prod-code NO-LOCK NO-ERROR.
if self = brwh-out-dtl then do:
    assign
    prod-name-r = (if available ub.clients
                   then substitute("Пр-ль: &1", ub.clients.obj-name)
                   else '':U).
end.
if self = brwh-ret-dtl then do:
    assign
    prod-name-v = (if available ub.clients
                   then substitute("Пр-ль: &1", ub.clients.obj-name)
                   else '':U).
end.
display
prod-name-r
prod-name-v
with frame d-sale.
IF mImagePh THEN
DO:
    DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
    RUN gds-attr-value ( v-gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
    RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, v-gds-code, OUTPUT vImageList).
    vCh = ENTRY (1, vImageList, ",":U).
    g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
END.
ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
END.
ON CHOOSE OF b-arch IN FRAME d-sale
DO:
define variable v-notes as character no-undo .
define variable v-inkas-base as decimal no-undo .
define variable v-cost-sum as decimal no-undo .
define buffer buf_inkas-pay for ub.inkas-pay.
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf_trn-doc for ub.trn-doc.
if t-doc.status_ = 'факт':U
or ink-doc.status_ = 'запрос':U
then do:
define variable vss-include-info38 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
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
if NOT glog then return no-apply.
if v-curr-r-b = 'base':U then do:
  assign
  v-inkas-base = ink-doc.netto
  .
end.
else do:
  for each buf_inkas-pay no-lock where
          buf_inkas-pay.inkas-code = ink-doc.inkas-code:
    assign
    v-inkas-base = v-inkas-base + buf_inkas-pay.tot-base
    .
  end.
end.
 for each buf_sale-doc no-lock where
          buf_sale-doc.inkas-code = ink-doc.inkas-code
      and buf_sale-doc.in-inkas = yes,
         first buf_trn-doc no-lock where
              buf_trn-doc.doc-code = buf_sale-doc.doc-code:
    assign
    v-cost-sum = v-cost-sum + buf_trn-doc.fact-base  * buf_sale-doc.dir
    .
  end.
  message
  "Оборот товара в учетных ценах:" skip
  string(v-cost-sum , "->>,>>>,>>9.99") v-base-type skip (2)
  "Оборот товара в продажных ценах с учетом скидки:" skip
  string (v-inkas-base, "->>,>>>,>>9.99") v-base-type skip (2)
  "Разница:" skip
  string (v-inkas-base - v-cost-sum, "->>,>>>,>>9.99") v-base-type skip (2)
  "Наценка:"
  string ((v-inkas-base - v-cost-sum) / v-cost-sum * 100, "->>9.9<%")
  view-as alert-box title "Док-т №: " + string (t-doc.doc-code) + "  от: " + string (t-doc.doc-date)
    + (IF cas-shft then (" смена N " + shift-name-no-err(buffer ink-doc)) else "")
    + (IF one-curs then (" чеки по курсу " + string(t-doc.base-rate / t-doc.base-scale)) else "") .
end.
else do:
    run str/chk-inf.p (
                      input parparentproc
                    ,input v-host-code
                    ,input ink-doc.obj-type
                    ,input ink-doc.obj-code
                    ,input yes
                    ,input yes
                    ,recid (ink-doc)
                    ,output v-notes
                    ,output not-all-saled-chk
                    ,output not-all-normal-chk
                    ,output not-all-inkas-closed
                    ).
  end.
END.
ON CHOOSE OF b-next IN FRAME d-sale
DO:
run reposition-inkas in this-procedure
  (input 'next':U
  ).
END.
ON CHOOSE OF b-prev IN FRAME d-sale
DO:
run reposition-inkas in this-procedure
  (input 'prev':U
  ).
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-sale:PARENT eq ? THEN
FRAME d-sale:PARENT = ACTIVE-WINDOW.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-sale
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
on choose of b-help in frame d-sale
do:
  apply "help":u to frame d-sale .
end.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-sale:width - 0.3
                fh            = frame d-sale:first-child
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
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-sale :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-sale :height-chars)
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
    if frame d-sale :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-sale :height-chars)
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
            frame d-sale :height = v-frame-height
          .
          if frame d-sale :scrollable = true
          then do:
            assign
              frame d-sale :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-sale :scrollable = true
          then do:
            assign
              frame d-sale :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-sale :height = v-frame-height
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
      v-frame-height = frame d-sale :height
      v-frame-virtual-height = frame d-sale :virtual-height
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
      v-field-group-handle = frame d-sale :first-child
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
    do with frame d-sale
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-sale :scrollable = true
      then do:
        assign
          frame d-sale :virtual-height = frame d-sale :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-sale :height = frame d-sale :height + p-change-value
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
        frame d-sale :height = frame d-sale :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-sale :scrollable = true
      then do:
        assign
          frame d-sale :virtual-height = frame d-sale :virtual-height + p-change-value
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
          ,input  string(frame d-sale :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-sale :height)
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
    if frame d-sale :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-sale :width
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
    if frame d-sale :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-sale :width
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
            frame d-sale :width = v-frame-width
          .
          if frame d-sale :scrollable = true
          then do:
            assign
              frame d-sale :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-sale :scrollable = true
          then do:
            assign
              frame d-sale :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-sale :width = v-frame-width
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
      v-frame-width = frame d-sale :width
      v-frame-virtual-width = frame d-sale :virtual-width
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
      v-field-group-handle = frame d-sale :first-child
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
    do with frame d-sale
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-sale :scrollable = true
      then do:
        assign
          frame d-sale :virtual-width = frame d-sale :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-sale :width = v-frame-width + p-change-value
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
        frame d-sale :width = frame d-sale :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-sale :scrollable = true
      then do:
        assign
          frame d-sale :virtual-width = frame d-sale :virtual-width + p-change-value
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
          ,input  string(frame d-sale :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-sale :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-sale
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-sale :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-sale :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-sale :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-sale :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-sale
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
      v-row-delta = v-new-row - frame d-sale :height
      v-col-delta = v-new-col - frame d-sale :width
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
            - frame d-sale :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-sale :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-sale :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-sale :height-chars
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
      v-diasize-current-frame-width  = frame d-sale :width
      v-diasize-current-frame-height = frame d-sale :height
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
    do with frame d-sale
    :
      assign
        v-diasize-orig-frame-height = frame d-sale :height
        v-diasize-orig-frame-width  = frame d-sale :width
        v-diasize-browse-handle     = browse br-out :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-sale :first-child
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
define variable vss-include-info42 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame d-sale anywhere do:
  if b-exit :sensitive then DO: apply "CHOOSE":U to b-exit in frame d-sale. END.
  return no-apply.
end.
define variable vss-include-info43 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame d-sale anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame d-sale. END.
  return no-apply.
end.
define variable vss-include-info44 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-F7 of frame d-sale anywhere do:
  if b-close :sensitive then DO: apply "CHOOSE":U to b-close in frame d-sale. END.
  return no-apply.
end.
ON WINDOW-CLOSE OF FRAME d-sale APPLY "END-ERROR":U TO SELF.
rs-sort = "off":U.
p-next-prev = '':U.
assign
p-obj-type = ink-doc.obj-type
p-obj-code = ink-doc.obj-code
.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'autosale':U
    ,input  "":U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF error-status:error then do:
  message
  substitute("Ошибка при получении опций продажи НА ОБЪЕКТЕ &1&2:&3&4 &5"
            , p-obj-type
            , p-obj-code
            , chr(10)
            , error-status:get-message(1)
            , return-value )
  view-as alert-box error .
  return error.
end.
for each  thbjattr_thbj-attr where
          thbjattr_thbj-attr.obj-type = p-obj-type
      and thbjattr_thbj-attr.obj-code = p-obj-code
      and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
  case thbjattr_thbj-attr.prop-code:
    when 'autoclos':U then do:
      autoclose = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'autocalc':U then do:
      autocalc = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'automail':U then do:
      auto-mail = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'augetres':U then do:
      auto-get-res = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'autocomp':U then do:
      auto-comp = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'autofbr':U then do:
      autofbr = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'one-curs':U then do:
      one-curs = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'restdish':U then do:
      restdish = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'restingr':U then do:
      restingr = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'resttpsi':U then do:
      resttpsi = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'prcl-spl':U then do:
      prcl-spl = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'neg-tpsi-weight':U then do:
      neg-tpsi-weight = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'neg-tpsi-oper':U then do:
      neg-tpsi-oper = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'neg-tpsi-qnty':U then do:
      neg-tpsi-qnty = thbjattr_thbj-attr.property-value-decimal.
    end.
    when 'close-in-rfsl':U then do:
      close-in-rfsl = thbjattr_thbj-attr.property-value-integer.
    end.
    when 'pay-gds-algo':U then do:
      pay-gds-algo = thbjattr_thbj-attr.property-value-character.
    end.
  end case.
  assign
  restdish = restdish and autofbr
  restingr = restingr and autofbr
  resttpsi = resttpsi and v-is-tpsi-obj
  .
end.
btltaxcd = integer('3':U).
if btltaxcd > 0 then do:
    FIND FIRST ub.tax No-LOCK WHERE ub.tax.tax-code = btltaxcd No-ERROR.
    if not available ub.tax then do:
        message "Не найден налог (доп.компонента для цены) стеклопосуды!" view-as alert-box ERROR.
        return error.
    end.
end.
on f6 anywhere do:
  run str/inc-sale.w (
                  input parparentproc
                , input 'ПРОСМОТР':U
                , input ink-doc.host-code
                , input ink-doc.obj-type
                , input ink-doc.obj-code
                , input auto-get-res
                , input yes
                , buffer ink-doc
                ) NO-ERROR.
end.
n-p: do while p-next-prev = '':U:
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-ret :handle
    ) .
    run diasize_init in this-procedure .
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame d-sale anywhere do:
  run get-gds-rec.
  if gds-rec = ? then
    return no-apply.
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-out in frame d-sale.
  return no-apply.
end.
    p-doc-rec = recid (ink-doc).
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    find first ub.shop no-lock where
               ub.shop.obj-code = ink-doc.obj-code.
    FIND FIRST t-doc WHERE t-doc.doc-code = ink-doc.inkas-code NO-LOCK.
    FIND FIRST ret-doc WHERE ret-doc.doc-code = t-doc.out-code NO-LOCK no-error.
    assign
    t-code = t-doc.doc-code
    ret-code = (if available ret-doc then ret-doc.doc-code else '':U)
    bh-out-dtl = buffer out-dtl:handle
    bh-ret-dtl = buffer ret-dtl:handle
    bh-out-goods = buffer out-goods:handle
    bh-ret-goods = buffer ret-goods:handle
    brwh-out-dtl = browse br-out:handle
    brwh-ret-dtl = browse br-ret:handle
    v-is-inquiry = (t-doc.status_ = 'запрос':U)
    v-log-handle = this-procedure.
    .
    if available ret-doc and ret-doc.out-code <> t-doc.doc-code then   do:
      message
      "Данный расходный документ не является отчетом о продаже."
      view-as alert-box INFORMATION .
      p-next-prev = ?.
      return error.
    end.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  'маг':U
  ,input  ub.shop.obj-code
  ,output v-db-num
  )  .
    find first buf_currency no-lock where
              buf_currency.curr-code = v-base-code.
    assign
    v-base-type = buf_currency.curr-abbr
    .
    define variable v-h as handle no-undo .
    define variable v-h-out as handle no-undo extent 30.
    define variable v-ii as integer no-undo init 1.
    v-h = br-out:FIRST-COLUMN IN FRAME d-sale.
    v-ii = 1.
    DO while valid-handle(v-h) :
       v-h-out[v-ii] = v-h.
       v-h = v-h:NEXT-COLUMN.
       v-ii = v-ii + 1.
    END.
    if (can-do( 'ИЗМЕНЕНИЕ':U, p-mode )
    or ink-doc.status_ = 'новый':U)
    then do:
      run gbl/tpsi-obj.p (
                           input p-obj-type
                         , input p-obj-code
                         , output v-is-tpsi-obj) no-error .
      if v-is-tpsi-obj then
      br-out:num-locked-columns = 3.
      else do:
        assign
        v-h-out[7]:visible = no
        v-h-out[8]:visible = no
        .
      end.
    end.
    else do:
      assign
      v-h-out[7]:visible = no
      v-h-out[8]:visible = no
      .
       assign
       neg-tpsi-weight = no
       neg-tpsi-qnty = 0
       neg-tpsi-oper = no
       resttpsi = no
       .
    end.
    run reget-br-2 in this-procedure .
    if can-find(first tpsi_sale-doc where
                     tpsi_sale-doc.inkas-code = ink-doc.inkas-code
                 and tpsi_sale-doc.tpsidoc = yes)
    then v-is-tpsi-obj = yes.
    if v-is-tpsi-obj then do:
      run tpsi-gds-fill-tpsi-obj-table in this-procedure ( input v-db-num) no-error .
      if error-status:error then do:
        message
        substitute("Ошибки при заполнении врем. таблицы объектов-членов ТПСИ на БД &1", v-db-num) skip
        error-status:get-message(1) skip
        return-value
        view-as alert-box error .
        undo main-block, return error .
      end.
    end.
    if (v-is-tpsi-obj)
    and can-do( 'ИЗМЕНЕНИЕ':U, p-mode )
    or ink-doc.status_ = 'новый':U
    then do:
      if not v-is-inquiry then do:
        run waitfram-show in this-procedure ("Ждите.. получение информации по резервированию ЧУЖИХ товаров" ).
        run fill-tt-tpsi-table  in this-procedure ( input ink-doc.inkas-code
                                                  , input ink-doc.host-code
                                                  , input ink-doc.obj-type
                                                  , input ink-doc.obj-code).
        run waitfram-hide in this-procedure .
      end.
    end.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type51 as character no-undo .
define variable v-value-character51 as character no-undo .
define variable v-value-date51 as date no-undo .
define variable v-value-decimal51 as decimal no-undo .
define variable v-value-integer51 as INTEGER no-undo .
define variable v-tth51 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'get-chk':U
    ,input  'cas-shft':U
    ,output v-value-character51
    ,output v-value-date51
    ,output v-value-decimal51
    ,output v-value-integer51
    ,output cas-shft
    ,output v-param-type51
    ,INPUT-OUTPUT table-handle v-tth51
    )  .
delete object v-tth51.
    RUN UI-on in this-procedure .
    APPLY "ENTRY" to br-out.
    if can-do( 'ИЗМЕНЕНИЕ':U, p-mode ) and not auto-mail then do:
        message "Докачка чеков в продажу осуществляется нажатием" skip
        "              на кнопку ПРИЕМ ЧЕКОВ!"
        view-as alert-box WARNING.
    END.
    if can-do( 'ИЗМЕНЕНИЕ':U, p-mode ) AND auto-mail then do:
      run str/diallog.w (
                    input parparentproc
                  , input this-procedure
                  , input 'str/get-chkf.p':U
                  , input (p-obj-type + chr(4) + string(p-obj-code) + chr(4) + string(0))
                  , input yes
                  , input '':U
                  , input 'Прием чеков с касс') no-error .
      if error-status:error then return error.
      p-doc-rec = recid (ink-doc).
      DO TRANSACTION on ERROR undo, leave
                            on STOP undo, leave:
          run str/inc-sale.w (
                          input parparentproc
                        , input 'ИЗМЕНЕНИЕ':U
                        , input ink-doc.host-code
                        , input ink-doc.obj-type
                        , input ink-doc.obj-code
                        , input auto-get-res
                        , input no
                        , buffer ink-doc
                        ) NO-ERROR.
      END.
      if (auto-get-res
      or auto-mail)
      and not return-value = "cancell":U
      and not v-is-inquiry then do:
        run reget-br-2 in this-procedure .
        run openbr in this-procedure ( input ink-doc.inkas-code,  input br-2-doc-code, input yes, input no, input '':U, input '':U).
      END.
      if auto-get-res
      and not return-value = "cancell":U then do:
        assign
        auto-close
        auto-fbr
        rest-dish
        rest-ingr
        rest-tpsi
        .
        if auto-close then do:
            glog = no.
            message
            "ВНИМАНИЕ!!! Включен режим автоматического закрытия продажи по результатам резервирования!"
            skip "Вы уверены, что хотите закрыть продажу?" view-as alert-box WARNING
            buttons YES-NO update glog.
            if not glog then return no-apply.
        end.
      FIND FIRST ret-doc WHERE ret-doc.doc-code = t-doc.out-code NO-LOCK no-error.
      run b-res-proc in this-procedure (
                                          buffer ink-doc
                                        , buffer t-doc
                                        , buffer ret-doc
                                        , input no
                                        , input auto-close
                                        , input no
                                        , input rest-dish
                                        , input "":U
                                        , input v-is-tpsi-obj
                                        , input rest-tpsi) no-error.
      if not error-status:error then do:
        if auto-close and b-close:sensitive then do:
        assign
        v-parameter =     v-curr-r-b                     + chr(4) +
                          ink-doc.inkas-code             + chr(4) +
                        string(0)              + chr(4) +
                        string(auto-close)               + chr(4) +
                        string(b-mail-pressed)           + chr(4) +
                        string(auto-comp)                + chr(4) +
                        string(auto-fbr)                 + chr(4) +
                        string(one-curs)                 + chr(4) +
                        string(ub.shop.is-catering)      + chr(4) +
                        string(v-is-tpsi-obj)            + chr(4) +
                        string(rest-dish)                + chr(4) +
                        string(rest-ingr)                + chr(4) +
                        string(rest-tpsi)                + chr(4) +
                        string(neg-tpsi-weight)          + chr(4) +
                        string(neg-tpsi-qnty)            + chr(4) +
                        string(neg-tpsi-oper)            + chr(4) +
                        string(close-in-rfsl)            + chr(4) +
                        pay-gds-algo
        .
        run str/diallog.w (
              input parParentProc
            , input this-procedure
            , input ("str/saleclos.p":U + chr(4) + "1":U +
                    "1":U  + chr(4) +
                    "1":U + chr(4) +
                    "1":U)
            , input v-parameter
            , input no
            , input "":U
            , input substitute("Закрытие продажи &1", Ink-doc.inkas-code)
        ) no-error.
        if error-status:error
        or return-value = "error":U
        then do:
            run close-error-processing in this-procedure.
            return no-apply.
        end.
        else do:
          assign
          p-next-prev = ? .
          leave n-p.
        end.
      end.
    end.
    else do:
      run waitfram-hide in this-procedure .
    end.
  end.
  RUN UI-on in this-procedure .
  b-mail-pressed = yes.
end.
WAIT-FOR GO OF FRAME d-sale focus br-out.
END.
end.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-sale.
END PROCEDURE.
PROCEDURE UI-on :
assign
v-prt-name:resizable in browse br-out = yes
v-prt-name:resizable in browse br-ret = yes
out-goods.engl-name:read-only in browse br-out = yes
ret-goods.engl-name:read-only in browse br-ret = yes
.
disable all with frame d-sale.
assign
auto-close
auto-fbr
rest-dish
rest-ingr
rest-tpsi
.
run enable-menu-items in this-procedure .
if v-list-item-pairs <> '':U then do:
assign
cb-doc-kind:list-item-pairs in frame d-sale =  trim(v-list-item-pairs).
cb-doc-kind = br-2-mode.
display
cb-doc-kind
with frame d-sale .
end.
run frame-title in this-procedure .
assign
s-pc = ink-doc.discnt / ink-doc.tot-doc * 100
loc-art = ""
auto-close = if just-entered then autoclose else auto-close
auto-fbr =  if just-entered and ub.shop.is-catering then autofbr else auto-fbr
rest-dish =  if just-entered and autofbr then restdish else rest-dish
rest-ingr =  if just-entered and autofbr then restingr else rest-ingr
rest-tpsi =  if just-entered and v-is-tpsi-obj then resttpsi else rest-tpsi
just-entered = no.
hide loc-art in frame d-sale loc-name loc-code in frame d-sale.
DISPLAY
auto-close
auto-fbr when shop.is-catering and can-do( 'ИЗМЕНЕНИЕ':U, p-mode )
rest-tpsi
with frame d-sale.
ENABLE b-exit
              b-prev WHEN NOT can-do( 'ИЗМЕНЕНИЕ':U, p-mode )
              b-next WHEN NOT can-do( 'ИЗМЕНЕНИЕ':U, p-mode )
              b-cash b-arch
              b-notes b-help a-n-c br-out br-ret
              b-chk r-trn
              b-troubl when (NOT t-doc.status_ = 'факт':U  and not v-is-inquiry)
              b-troublp  when not v-is-inquiry
              b-troublc
              b-places when (NOT t-doc.status_ = 'факт':U and can-do( 'ИЗМЕНЕНИЕ':U, p-mode ))
              b-parts when NOT v-is-inquiry
              prod-name-r
              cb-doc-kind when v-list-item-pairs <> '':U and num-entries(cb-doc-kind:list-item-pairs) > 2
              prod-name-v
              b-print
              with frame d-sale.
  if can-do( 'ИЗМЕНЕНИЕ':U, p-mode ) then do:
    disable b-close
    with frame d-sale .
    b-close-enabled = no.
    RUN button-close in this-procedure (
                                            buffer t-doc
                                           ,buffer ret-doc
                                           ,input v-is-tpsi-obj
                                           ,input auto-fbr
                                           ,input neg-tpsi-weight
                                           ,input neg-tpsi-qnty
                                           ,input neg-tpsi-oper
                                           ,Output b-close-enabled).
    ENABLE
    b-close when ((auto-comp
                and can-find(first ub.sale-doc where
                                  ub.sale-doc.inkas-code = ink-doc.inkas-code
                              and ub.sale-doc.doc-kind = 'rs':U)
                )
                OR b-close-enabled)
    b-res when not v-is-inquiry
    b-unres when not v-is-inquiry
    b-mail
    auto-close when not v-is-inquiry
    auto-fbr when (shop.is-catering and not v-is-inquiry)
    rest-tpsi when (v-is-tpsi-obj and not v-is-inquiry)
    with frame d-sale.
    if not shop.is-catering then do:
      hide
      auto-fbr
      in frame d-sale .
    end.
    apply "VALUE-CHANGED" to auto-fbr.
end.
if can-do( 'ПРОСМОТР':U, p-mode ) then do:
    ENABLE rs-sort with frame d-sale.
    hide
    auto-fbr rest-dish rest-ingr rest-tpsi
    in frame d-sale .
end.
apply "VALUE-CHANGED" to br-out.
apply "VALUE-CHANGED" to br-ret.
IF NOT (t-doc.status_ = 'факт':U
or ink-doc.status_ = 'запрос':U)
then do:
    assign
    menu-item m-arch-i:label in menu m-arch = "Чеки-продажи"
    b-arch:label = "Ин&фор."
    .
end.
display
ink-doc.qnty ink-doc.num-chk rs-sort ink-doc.tot-doc ink-doc.discnt
ink-doc.netto @ s-netto
s-pc WHEN abs( s-pc ) < 1000
ink-doc.sub-discnt
        with frame d-sale.
if s-pc = ? or s-pc > 1000 and s-pc:visible in frame d-sale then do:
hide s-pc.
end.
run shapka in this-procedure .
FIND FIRST t-doc WHERE t-doc.doc-code= ink-doc.inkas-code NO-LOCK.
FIND FIRST ret-doc WHERE ret-doc.doc-code = t-doc.out-code NO-LOCK no-error.
run openbr in this-procedure ( input t-doc.doc-code, input br-2-doc-code, input yes, input no, input '':U, input '':U).
APPLY "value-changed" to br-out.
APPLY "value-changed" to br-ret.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-sys-key
  ) no-error .
if v-sys-key begins "Rosneft-" or v-sys-key eq "ibs" or v-sys-key eq "yukos"  then hide b-places in frame d-sale.
run waitfram-hide in this-procedure .
END PROCEDURE.
procedure OpenBr :
define input parameter p-br1-doc-code like ub.trn-doc.doc-code no-undo .
define input parameter p-br2-doc-code like ub.trn-doc.doc-code no-undo .
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define input parameter p-caller as character no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-open-query as logical   no-undo .
define variable l-query-was-opened as logical no-undo .
define variable v-sort-phrase1 as character no-undo .
define variable v-sort-phrase2 as character no-undo .
if br-2-mode = chr(4) then browse br-ret:title  = "[Нет второго документа по продаже для просмотра]" no-error .
else
assign
browse br-ret:title  = substitute("&1 &2 &3", entry (lookup (entry(1, br-2-mode, chr(4)), 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ), entry(2, br-2-mode, chr(4)), br-2-doc-code) no-error .
run waitfram-show in this-procedure ( input "Ждите...").
if lookup( 'ИЗМЕНЕНИЕ':U, p-mode ) > 0 then  do:
  assign
  v-sort-phrase1 = " by ( out-dtl.doc-qnty = out-dtl.fact-qnty ) "
  v-sort-phrase2 = " by ( ret-dtl.doc-qnty = ret-dtl.fact-qnty ) "
  .
end.
else do:
  CASE rs-sort :
    when "discount":U then  do:
      assign
      v-sort-phrase1 = " by ( out-dtl.discnt-base / out-dtl.price-base ) "
      v-sort-phrase2 = " by ( ret-dtl.discnt-base / ret-dtl.price-base ) "
      .
    end.
    when "quantity":U then do:
      assign
      v-sort-phrase1 = " by ( out-dtl.fact-qnty ) "
      v-sort-phrase2 = " by ( ret-dtl.fact-qnty ) "
      .
    end.
    when "price":U then do:
      assign
      v-sort-phrase1 = " by ( out-dtl.price-base ) "
      v-sort-phrase2 = " by ( ret-dtl.price-base ) "
      .
    end.
    when "summa":U then do:
      assign
      v-sort-phrase1 = " by ( out-dtl.fact-qnty * out-dtl.price-base ) "
      v-sort-phrase2 = " by ( ret-dtl.fact-qnty * ret-dtl.price-base ) "
      .
    end.
    when "off":U then do:
      assign
      v-sort-phrase1 = "  "
      v-sort-phrase2 = "  "
      .
    end.
  END CASE .
end.
case sort-column-name-out :
  when "" then do:
  assign
    sort-column-phrase = v-sort-phrase1
  .
  end.
  otherwise do:
  assign
    sort-column-phrase = " by " + sort-column-name-out
  .
  end.
end case.
if p-caller <> 'ret':U then do:
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-54  as logical   no-undo .
define variable  l-filter-open-54    as logical   .
define variable  flt-rec-54       as recid     no-undo .
define variable  filter-name-54      as character no-undo .
define variable  where-phrase-54     as character no-undo .
define variable  sort-phrase-54      as character no-undo .
define variable  where-phrase-rus-54 as character no-undo .
define variable  sort-phrase-rus-54  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input 'sale'
  ,output flt-rec-54
  ,output filter-name-54
  ,output where-phrase-54
  ,output sort-phrase-54
  ,output where-phrase-rus-54
  ,output sort-phrase-rus-54
  ).
if p-open-query then do:
  assign
    l-filter-open-54 = false
  .
  if flt-rec-54 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-54 as character no-undo .
    define variable  parameter-3-54 as character no-undo .
    define variable  parameter-4-54 as character no-undo .
    define variable  parameter-5-54 as character no-undo .
    define variable  parameter-6-54 as character no-undo .
    define variable  parameter-7-54 as character no-undo .
      assign
      parameter-3-54 =
                              "FOR EACH out-dtl NO-LOCK"
      parameter-4-54 =
        (
          if (" out-dtl.doc-code = p-br1-doc-code , " + " " + where-phrase-54) <> ""
          then  substitute('out-dtl.doc-code = &1&2&1 , ', chr(34), p-br1-doc-code)  + " " + where-phrase-54
          else "true"
        )
      parameter-5-54 = (" " + "" + " " + substitute('   FIRST out-prt NO-LOCK WHERE out-prt.node-code = out-dtl.prt-code , FIRST out-goods NO-LOCK WHERE out-goods.artic = out-dtl.artic AND out-goods.prod-code = out-dtl.prod-code AND out-goods.prod-type = out-dtl.prod-type ,  FIRST out-bar NO-LOCK WHERE out-bar.gds-code = out-goods.gds-code AND out-bar.node-code = out-dtl.prt-code AND out-bar.in-code = &1&1 AND out-bar.part-code = &1&1 AND out-bar.unit-cli = out-goods.unit-base, first out-tt0-dtl where out-tt0-dtl.artic = out-dtl.artic and out-tt0-dtl.prod-type = out-dtl.prod-type and out-tt0-dtl.prod-code = out-dtl.prod-code and out-tt0-dtl.prt-code = out-dtl.prt-code outer-join ', chr(34)))
      parameter-6-54 = if sort-phrase-54 = ''
                           then
        (
        " " + "" +
          " " + sort-column-phrase +
        " " + ""
        )
                           else
        (
        " " + "" +
          " " + sort-column-phrase +
        " " + sort-phrase-54
        )
      parameter-7-54 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-54 =
          (" out-dtl.doc-code = p-br1-doc-code , " + " " + where-phrase-54 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-out:handle
                          ,input parameter-3-54
                          ,input parameter-4-54
                          ,input parameter-5-54
                          ,input parameter-6-54
                          ,input parameter-7-54
                          )
      .
      assign
        l-filter-open-54 = true
      .
    end.
    if l-filter-open-54 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-54 = false then do:
    OPEN QUERY br-out FOR EACH out-dtl NO-LOCK
      where  out-dtl.doc-code = p-br1-doc-code ,
    FIRST out-prt NO-LOCK WHERE out-prt.node-code = out-dtl.prt-code , FIRST out-goods NO-LOCK WHERE out-goods.artic = out-dtl.artic AND out-goods.prod-code = out-dtl.prod-code AND out-goods.prod-type = out-dtl.prod-type ,  FIRST out-bar NO-LOCK WHERE out-bar.gds-code = out-goods.gds-code AND out-bar.node-code = out-dtl.prt-code AND out-bar.in-code = v-empty AND out-bar.part-code = v-empty AND out-bar.unit-cli = out-goods.unit-base, first out-tt0-dtl where out-tt0-dtl.artic = out-dtl.artic and out-tt0-dtl.prod-type = out-dtl.prod-type and out-tt0-dtl.prod-code = out-dtl.prod-code and out-tt0-dtl.prt-code = out-dtl.prt-code outer-join
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( out-dtl )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-out:handle:get-buffer-handle(1) = (buffer out-dtl:handle) then do:
      assign
      parameter-2-54 = (if p-find-next then "true":u else "false":u )
      parameter-4-54 =
        "where ":u +  substitute('out-dtl.doc-code = &1&2&1 , ', chr(34), p-br1-doc-code)  + " ":u + where-phrase-54 + " ":u + p-find-condition + " " + ""
      parameter-5-54 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-out:handle
                          ,input rowid(out-dtl)
                          ,input logical(parameter-2-54)
                          ,input no-lock
                          ,input (buffer out-dtl:handle)
                          ,input parameter-4-54
                          ,input parameter-5-54
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-54 = (if p-find-next then "true":u else "false":u )
      parameter-3-54 =  "FOR EACH out-dtl NO-LOCK"
      parameter-4-54 =
        (
          if (" out-dtl.doc-code = p-br1-doc-code , " + " " + where-phrase-54) <> ""
          then  substitute('out-dtl.doc-code = &1&2&1 , ', chr(34), p-br1-doc-code)  + " " + where-phrase-54
          else "true"
        )
      parameter-5-54 = (" " + "" + " " + substitute('   FIRST out-prt NO-LOCK WHERE out-prt.node-code = out-dtl.prt-code , FIRST out-goods NO-LOCK WHERE out-goods.artic = out-dtl.artic AND out-goods.prod-code = out-dtl.prod-code AND out-goods.prod-type = out-dtl.prod-type ,  FIRST out-bar NO-LOCK WHERE out-bar.gds-code = out-goods.gds-code AND out-bar.node-code = out-dtl.prt-code AND out-bar.in-code = &1&1 AND out-bar.part-code = &1&1 AND out-bar.unit-cli = out-goods.unit-base, first out-tt0-dtl where out-tt0-dtl.artic = out-dtl.artic and out-tt0-dtl.prod-type = out-dtl.prod-type and out-tt0-dtl.prod-code = out-dtl.prod-code and out-tt0-dtl.prt-code = out-dtl.prt-code outer-join ', chr(34)) + " " + p-find-condition)
      parameter-6-54 = if sort-phrase-54 = ''
                           then
        (
        " " + "" +
          " " + sort-column-phrase +
        " " + ""
        )
                           else
        (
        " " + "" +
          " " + sort-column-phrase +
        " " + sort-phrase-54
        )
      parameter-7-54 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-out:handle
                          ,input logical(parameter-2-54)
                          ,input no-lock
                          ,input parameter-3-54
                          ,input parameter-4-54
                          ,input parameter-5-54
                          ,input parameter-6-54
                          ,input parameter-7-54
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
end.
case sort-column-name-ret :
  when "" then do:
  assign
    sort-column-phrase = v-sort-phrase2
  .
  end.
  otherwise do:
  assign
    sort-column-phrase = "by " + sort-column-name-ret
  .
  end.
end case.
if p-caller <> 'out' then do:
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-56  as logical   no-undo .
define variable  l-filter-open-56    as logical   .
define variable  flt-rec-56       as recid     no-undo .
define variable  filter-name-56      as character no-undo .
define variable  where-phrase-56     as character no-undo .
define variable  sort-phrase-56      as character no-undo .
define variable  where-phrase-rus-56 as character no-undo .
define variable  sort-phrase-rus-56  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input 'sale'
  ,output flt-rec-56
  ,output filter-name-56
  ,output where-phrase-56
  ,output sort-phrase-56
  ,output where-phrase-rus-56
  ,output sort-phrase-rus-56
  ).
if p-open-query then do:
  assign
    l-filter-open-56 = false
  .
  if flt-rec-56 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-56 as character no-undo .
    define variable  parameter-3-56 as character no-undo .
    define variable  parameter-4-56 as character no-undo .
    define variable  parameter-5-56 as character no-undo .
    define variable  parameter-6-56 as character no-undo .
    define variable  parameter-7-56 as character no-undo .
      assign
      parameter-3-56 =
                              "FOR EACH ret-dtl NO-LOCK"
      parameter-4-56 =
        (
          if (" ret-dtl.doc-code = p-br2-doc-code , " + " " + where-phrase-56) <> ""
          then  substitute('ret-dtl.doc-code = &1&2&1 , ', chr(34), p-br2-doc-code) + " " + where-phrase-56
          else "true"
        )
      parameter-5-56 = (" " + "" + " " + substitute('  FIRST ret-prt NO-LOCK WHERE ret-prt.node-code = ret-dtl.prt-code, FIRST ret-goods NO-LOCK WHERE ret-goods.artic = ret-dtl.artic AND ret-goods.prod-code = ret-dtl.prod-code AND ret-goods.prod-type = ret-dtl.prod-type , FIRST ret-bar NO-LOCK WHERE ret-bar.gds-code = ret-goods.gds-code AND ret-bar.node-code = ret-dtl.prt-code AND ret-bar.in-code = &1&1 AND ret-bar.part-code = &1&1 AND ret-bar.unit-cli = ret-goods.unit-base , first ret-tt0-dtl where ret-tt0-dtl.artic = ret-dtl.artic and ret-tt0-dtl.prod-type = ret-dtl.prod-type and ret-tt0-dtl.prod-code = ret-dtl.prod-code and ret-tt0-dtl.prt-code = ret-dtl.prt-code outer-join ', chr(34)))
      parameter-6-56 = if sort-phrase-56 = ''
                           then
        (
        " " + "" +
          " " + sort-column-phrase +
        " " + ""
        )
                           else
        (
        " " + "" +
          " " + sort-column-phrase +
        " " + sort-phrase-56
        )
      parameter-7-56 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-56 =
          (" ret-dtl.doc-code = p-br2-doc-code , " + " " + where-phrase-56 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-ret:handle
                          ,input parameter-3-56
                          ,input parameter-4-56
                          ,input parameter-5-56
                          ,input parameter-6-56
                          ,input parameter-7-56
                          )
      .
      assign
        l-filter-open-56 = true
      .
    end.
    if l-filter-open-56 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-56 = false then do:
    OPEN QUERY br-ret FOR EACH ret-dtl NO-LOCK
      where  ret-dtl.doc-code = p-br2-doc-code ,
    FIRST ret-prt NO-LOCK WHERE ret-prt.node-code = ret-dtl.prt-code, FIRST ret-goods NO-LOCK WHERE ret-goods.artic = ret-dtl.artic AND ret-goods.prod-code = ret-dtl.prod-code AND ret-goods.prod-type = ret-dtl.prod-type , FIRST ret-bar NO-LOCK WHERE ret-bar.gds-code = ret-goods.gds-code AND ret-bar.node-code = ret-dtl.prt-code AND ret-bar.in-code = v-empty AND ret-bar.part-code = v-empty AND ret-bar.unit-cli = ret-goods.unit-base, first ret-tt0-dtl where ret-tt0-dtl.artic = ret-dtl.artic and ret-tt0-dtl.prod-type = ret-dtl.prod-type and ret-tt0-dtl.prod-code = ret-dtl.prod-code and ret-tt0-dtl.prt-code = ret-dtl.prt-code outer-join
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ret-dtl )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-ret:handle:get-buffer-handle(1) = (buffer ret-dtl:handle) then do:
      assign
      parameter-2-56 = (if p-find-next then "true":u else "false":u )
      parameter-4-56 =
        "where ":u +  substitute('ret-dtl.doc-code = &1&2&1 , ', chr(34), p-br2-doc-code) + " ":u + where-phrase-56 + " ":u + p-find-condition + " " + ""
      parameter-5-56 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-ret:handle
                          ,input rowid(ret-dtl)
                          ,input logical(parameter-2-56)
                          ,input no-lock
                          ,input (buffer ret-dtl:handle)
                          ,input parameter-4-56
                          ,input parameter-5-56
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-56 = (if p-find-next then "true":u else "false":u )
      parameter-3-56 =  "FOR EACH ret-dtl NO-LOCK"
      parameter-4-56 =
        (
          if (" ret-dtl.doc-code = p-br2-doc-code , " + " " + where-phrase-56) <> ""
          then  substitute('ret-dtl.doc-code = &1&2&1 , ', chr(34), p-br2-doc-code) + " " + where-phrase-56
          else "true"
        )
      parameter-5-56 = (" " + "" + " " + substitute('  FIRST ret-prt NO-LOCK WHERE ret-prt.node-code = ret-dtl.prt-code, FIRST ret-goods NO-LOCK WHERE ret-goods.artic = ret-dtl.artic AND ret-goods.prod-code = ret-dtl.prod-code AND ret-goods.prod-type = ret-dtl.prod-type , FIRST ret-bar NO-LOCK WHERE ret-bar.gds-code = ret-goods.gds-code AND ret-bar.node-code = ret-dtl.prt-code AND ret-bar.in-code = &1&1 AND ret-bar.part-code = &1&1 AND ret-bar.unit-cli = ret-goods.unit-base , first ret-tt0-dtl where ret-tt0-dtl.artic = ret-dtl.artic and ret-tt0-dtl.prod-type = ret-dtl.prod-type and ret-tt0-dtl.prod-code = ret-dtl.prod-code and ret-tt0-dtl.prt-code = ret-dtl.prt-code outer-join ', chr(34)) + " " + p-find-condition)
      parameter-6-56 = if sort-phrase-56 = ''
                           then
        (
        " " + "" +
          " " + sort-column-phrase +
        " " + ""
        )
                           else
        (
        " " + "" +
          " " + sort-column-phrase +
        " " + sort-phrase-56
        )
      parameter-7-56 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-ret:handle
                          ,input logical(parameter-2-56)
                          ,input no-lock
                          ,input parameter-3-56
                          ,input parameter-4-56
                          ,input parameter-5-56
                          ,input parameter-6-56
                          ,input parameter-7-56
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
end.
if entry(1, br-2-mode, chr(4)) = 'rwo':U then do:
  assign
  v-empty:column-fgcolor = GREY_COLOR
  v-empty:column-bgcolor = GREY_COLOR
  v-empty:visible = yes
  ret-dtl.doc-qnty:visible = no
  v-empty:width = out-dtl.doc-qnty:width in browse br-out
  .
end.
else do:
  assign
  v-empty:visible = no
  ret-dtl.doc-qnty:visible = yes
  .
end.
APPLY "value-changed" to br-out in frame d-sale .
APPLY "value-changed" to br-ret in frame d-sale .
run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE shapka:
define variable for-discnt as  decimal no-undo.
if NOT (autocalc AND prcl-spl AND can-do( 'ИЗМЕНЕНИЕ':U, p-mode ) ) then return.
IF NOT (t-doc.status_ = 'факт':U
and ink-doc.status_ = 'запрос':U)
then do:
    run waitfram-show in this-procedure ("Ждите...").
    run gbl/calc-trn.p ( input parparentproc, input recid(t-doc)).
    if available ret-doc then
    run gbl/calc-trn.p ( input parparentproc, input recid(ret-doc)).
    run waitfram-hide in this-procedure .
end.
for-discnt = (if v-curr-r-b = 'rubl':U
                then t-doc.discnt-rubl
                else t-doc.tot-calc
                - (if available ret-doc
                    then (if v-curr-r-b = 'rubl':U
                          then ret-doc.discnt-rubl
                          else  ret-doc.tot-calc)
                    ELSE 0)
                )
    .
if ABS(for-discnt - ink-doc.discnt) > 0.015 then do:
  assign
  for-discnt-chr = "Скидка по док-там: " + string(for-discnt, "->>>,>>9.99")
  for-discnt-chr:BGCOLOR IN FRAME d-sale = 10
  .
  DISPLAY
  for-discnt-chr
  WITH FRAME d-sale.
end.
else do:
  assign
  for-discnt-chr = ""
  for-discnt-chr:BGCOLOR IN FRAME d-sale = ?
  .
  HIDE
  for-discnt-chr
  IN FRAME d-sale.
end.
END PROCEDURE.
PROCEDURE close-error-processing.
if NOT return-value = ""
and NOT return-value = "error"
then
message
return-value
view-as alert-box ERROR.
if compensed then  run UI-on in this-procedure .
run frame-title in this-procedure .
END PROCEDURE.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE RSRv-line:
define input parameter p-r-v                as integer no-undo .
define input parameter p-auto-fbr           as logical no-undo .
define input parameter p-rsrv-prop-goods    as logical no-undo .
define input parameter p-auto-fbr-on        as logical no-undo .
define input parameter p-rest-dish          as logical no-undo .
define input parameter p-fbr-income-doc-code like ub.trn-doc.doc-code no-undo .
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
define buffer buf_dtl-rests for dtl-rests.
if buf_sale-doc.in-inkas = no
and not can-find(first dtl-rests no-lock where dtl-rests.gds-code = gdscode) then do:
   v-dop-sale-negative-check = ',' + 'negative-check':U + "=1".
end.
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
  if p-tpsi-obj
  and p-rsrv-prop-goods = yes then do:
    find first buf_dtl-rests no-lock where
              buf_dtl-rests.gds-code = gdscode no-error .
    if available buf_dtl-rests
    and buf_dtl-rests.prop > 0
    and buf_dtl-rests.ok-prop then do:
      assign
      v-nc-option = "=1":U.
      assign
      rsrv-option = rsrv-option + ',' + 'negative-check':U + v-nc-option
      .
    end.
  end.
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
run waitfram-show in this-procedure (input substitute("&1 - обработано &2, из них успешно - &3"                                                         , rsrv-title                                                                 , num_rec                                                                    , num_rec_res) ).
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
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
run waitfram-show in this-procedure (input substitute("&1 - обработано &2, из них успешно - &3"                                                         , rsrv-title                                                                 , num_rec                                                                    , num_rec_res) ).
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
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
run waitfram-show in this-procedure (input substitute("&1 - обработано &2, из них успешно - &3"                                                         , rsrv-title                                                                 , num_rec                                                                    , num_rec_res) ).
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
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE INV-CHK:
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter v-curr-r-b   as character no-undo .
define parameter buffer buf_inkas   for ub.inkas.
define parameter buffer buf_trn-doc for ub.trn-doc.
define input parameter r-or-v as character no-undo .
define input parameter r-office as character no-undo .
define input parameter rdoc-line as recid no-undo .
define variable accum-inkas-pay-tot-r-b as decimal no-undo.
define variable accum-inkas-pay-desk-tot-r-b as decimal no-undo.
define variable l-inv-on as logical no-undo .
define variable v-in-inv as logical no-undo .
define variable v-inkas-qnty-r as decimal no-undo .
define variable v-inkas-qnty-v as decimal no-undo .
define buffer buf_doc-line for ub.doc-line.
define buffer buf_goods    for ub.goods.
define buffer buf_inkas-pay for ub.inkas-pay.
define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.
define buffer buf_sale-doc for ub.sale-doc.
if buf_trn-doc.status_ = 'запрос':U then do:
end.
else do:
    run waitfram-show in this-procedure ("Проверка товаров продажи на присутствие в незакрытой инвентаризации..." ).
  _buf_sale-doc:
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = p-inkas-code
      and buf_sale-doc.order > 0
    on error undo _buf_sale-doc, next _buf_sale-doc:
    if buf_sale-doc.in-inkas = yes
    and buf_sale-doc.dir = 1 then do:
       assign
       v-inkas-qnty-r = v-inkas-qnty-r + buf_sale-doc.fact-qnty.
    end.
    if buf_sale-doc.in-inkas = yes
    and buf_sale-doc.dir = -1 then do:
       assign
       v-inkas-qnty-v = v-inkas-qnty-v + buf_sale-doc.fact-qnty.
    end.
    if buf_sale-doc.doc-kind = 'rwo':U then next _buf_sale-doc.
    if r-or-v <> ?
    and (buf_sale-doc.doc-kind <> r-or-v
         or
         buf_sale-doc.chr-office <> r-office
          ) then NEXT _buf_sale-doc.
    _buf_doc-line:
    FOR EACH buf_doc-line WHERE
            buf_doc-line.doc-code = buf_sale-doc.doc-code
        AND (rdoc-line = ? or recid(buf_doc-line) = rdoc-line) NO-LOCK :
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  'inv-on=request'
  ,output l-inv-on
  ) no-error .
      if error-status :error then do:
        undo, return error substitute("&1 &2 &3 Ошибка получения признака товара на объекте:&4&5 &6"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      , chr(10)
                                      , error-status:error
                                      , return-value
                                        ).
      end.
      if l-inv-on then do:
        FIND FIRST buf_goods WHERE
                  buf_doc-line.prod-type = buf_goods.prod-type
              and buf_doc-line.prod-code = buf_goods.prod-code
              and buf_doc-line.artic = buf_goods.artic NO-LOCK .
        run waitfram-hide in this-procedure .
          MESSAGE substitute("Артикул :&1 &2- товар в инвентаризации.&3&3" +                   (if p-auto = 0 then "Резервирование и/или закрытие отчета невозможно" else "":U)                                   ,buf_doc-line.artic                                                            ,buf_goods.gds-name                                                            , chr(10)) view-as alert-box.
        if p-auto = 0 then do:
          undo, return error.
        end.
        else do:
          assign
          v-in-inv = yes
          .
        end.
      end.
    END.
  end.
  if v-in-inv then do:
        undo,  return error substitute("Имеются товары в инвентаризации.&2&2Закрытие отчета невозможно."
                                , chr(10)).
  end.
  run waitfram-hide in this-procedure .
end.
run waitfram-show in this-procedure ("Сравнение сумм по товарам и выручке......" ).
assign
accum-inkas-pay-tot-r-b = 0
.
FOR EACH buf_inkas-pay WHERE
         buf_inkas-pay.inkas-code = buf_inkas.inkas-code NO-LOCK
:
  accum-inkas-pay-tot-r-b = accum-inkas-pay-tot-r-b + (if v-curr-r-b = 'base':U
                                                       then buf_inkas-pay.tot-base
                                                       else buf_inkas-pay.tot-rubl)
                                                       .
  accum-inkas-pay-desk-tot-r-b = 0.
  FOR EACH buf_inkas-pay-desk WHERE
           buf_inkas-pay-desk.inkas-code = buf_inkas.inkas-code AND
           buf_inkas-pay-desk.pay-code   = buf_inkas-pay.pay-code AND
           buf_inkas-pay-desk.curr-code  = buf_inkas-pay.curr-code NO-LOCK
  :
      accum-inkas-pay-desk-tot-r-b = accum-inkas-pay-desk-tot-r-b +
                                     (if v-curr-r-b = 'base':U
                                      then buf_inkas-pay-desk.tot-base
                                      else buf_inkas-pay-desk.tot-rubl).
  END .
  if (v-curr-r-b = 'base':U and abs( buf_inkas-pay.tot-base -  accum-inkas-pay-desk-tot-r-b ) > 0.015)
  OR (v-curr-r-b = 'rubl':U and abs( buf_inkas-pay.tot-rubl -  accum-inkas-pay-desk-tot-r-b ) > 0.015)
  then do:
    run waitfram-hide in this-procedure .
    undo, return error substitute("&1 Ошибка оплат по чекам&2По оплатам &3&2По оплатам по кассе &4"
                            , vss-description
                            , chr(10)
                            , (if v-curr-r-b = 'base':U then buf_inkas-pay.tot-base else buf_inkas-pay.tot-rubl )
                            , accum-inkas-pay-desk-tot-r-b).
  end.
END .
if abs( buf_inkas.netto -  accum-inkas-pay-tot-r-b ) > 0.015 then do:
  run waitfram-hide in this-procedure .
  undo, return error substitute("&1 Ошибка оплат по чекам&2По отчету &3&2По оплатам &4"
                          , vss-description
                          , chr(10)
                          , buf_inkas.netto
                          , accum-inkas-pay-tot-r-b).
end.
if buf_inkas.qnty <> v-inkas-qnty-r - v-inkas-qnty-v then do:
  run waitfram-hide in this-procedure .
  undo, return error substitute("&1 Несоответствие накладных и документа продажи&2" +
                           "Количество товара в продаже &3&2"  +
                           "Количество товара в расходной накладной &4&2" +
                           "Количество товара в возвратной накладной &5&2"
                           ,vss-description
                           , chr(10)
                           , buf_inkas.qnty
                           , v-inkas-qnty-r
                           , v-inkas-qnty-v).
end.
run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE neg-rests:
define input parameter from-close as logical.
define input parameter p-status_ like ub.inkas.status_ no-undo .
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-mode       as character no-undo .
define input parameter p-is-catering as logical no-undo .
define input parameter p-is-tpsi-obj  as logical no-undo .
define input parameter p-neg-tpsi-weight as logical no-undo .
define input parameter p-neg-tpsi-qnty as decimal no-undo .
define input parameter p-neg-tpsi-oper as logical no-undo .
run waitfram-show in this-procedure ("Проверка возможности появления недопустимых отрицательных остатков..." ).
if not p-mode = 'ПРОСМОТР':U then do:
  run str/dtlrests.p (
                 input p-inkas-code
                ,input from-close
                ,input "all":U
                ,input no
                ,input p-is-catering
                ,input p-is-tpsi-obj
                ,input p-neg-tpsi-weight
                ,input p-neg-tpsi-qnty
                ,input p-neg-tpsi-oper
                ).
  if not from-close then do:
    for each dtl-rests :
      if p-status_ <> 'факт':U
      and p-mode = 'ИЗМЕНЕНИЕ':U
      and p-is-tpsi-obj
      and dtl-rests.is-neg-tpsi-oper then do:
        find first dtl-rests-mark where
                  dtl-rests-mark.artic = dtl-rests.artic
              and dtl-rests-mark.prod-type = dtl-rests.prod-type
              and dtl-rests-mark.prod-code = dtl-rests.prod-code no-error .
        if not available dtl-rests-mark then do:
          create dtl-rests-mark.
          buffer-copy dtl-rests to dtl-rests-mark.
          release dtl-rests-mark.
        end.
      end.
      if dtl-rests.OK then delete dtl-rests.
    end.
  end.
end.
run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE b-res-proc:
define parameter buffer buf_inkas for ub.inkas.
define parameter buffer buf_trn-doc for ub.trn-doc.
define parameter buffer buf_ret-doc for ub.trn-doc.
define input parameter p-auto-fbr as logical no-undo .
define input parameter auto-close as logical no-undo .
define input parameter p-rsrv-prop-goods as logical no-undo .
define input parameter p-rest-dish as logical no-undo .
define input parameter p-fbr-income-doc-code like ub.trn-doc.doc-code no-undo .
define input parameter p-is-tpsi-obj as logical no-undo .
define input parameter p-rest-tpsi as logical no-undo .
define buffer locked_trn-doc for ub.trn-doc.
define buffer locked_inkas for ub.inkas.
define buffer buf_sale-doc for ub.sale-doc.
define variable glog as logical no-undo .
do
on error undo, return error return-value
:
  if buf_trn-doc.status_ = 'запрос':U then return.
  if not from-menu then
  assign
  rdoc-line = ?
  rgds-dtl = ?
  r-or-v = (if r-or-v = 'rwo':U then r-or-v else ?)
  r-office = ?
  r-qnty = ?
  r-b-code = ?
  r-pl-code = ?
  r-doc-prts-qnty = ?
  .
  from-menu = no.
  assign
  num_resv = 0
  num_resv_res = 0
  num_rec = 0
  num_rec_res = 0
  .
define variable vss-include-info64 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_sale_fact':U
    ,input  'object':U
    ,input  buf_inkas.host-code
    ,input  buf_inkas.obj-type
    ,input  buf_inkas.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if NOT glog then undo, return error.
  if NOT can-find( first ub.chk-doc No-LOCK where ub.chk-doc.out-code = buf_inkas.inkas-code ) then do:
    undo, return error substitute("&1 Отчет о продаже пуст. Резервирование невозможно.", vss-description).
  end.
  FIND FIRST locked_trn-doc WHERE
          locked_trn-doc.doc-code = buf_inkas.inkas-code NO-LOCK .
  glog = no.
  RUN Inv-chk in this-procedure  (input buf_Inkas.inkas-code
                                , input v-curr-r-b
                                , buffer buf_inkas
                                , buffer buf_trn-doc
                                , input r-or-v
                                , input r-office
                                , input rdoc-line) no-error .
  IF error-status:error  then do:
    message
    substitute("&1 Были ошибки при проверке документов на возможность резервирования:&2&3&2&4"
                , vss-description
                , chr(10)
                , error-status:get-message(1)
                , return-value)
    view-as alert-box error .
    undo, return "error".
  end.
  BadTrans = FALSE .
  FIND FIRST locked_inkas WHERE recid( locked_inkas ) = recid( buf_Inkas ) .
  FIND FIRST locked_trn-doc WHERE
            locked_trn-doc.doc-code = buf_inkas.inkas-code .
  assign
  locked_inkas.is-auto-rsrv = no
  .
  RUN RESERV in this-procedure (
             buffer locked_inkas
            ,buffer locked_trn-doc
            ,input p-auto-fbr
            ,input p-rsrv-prop-goods
            ,input p-rest-dish
            ,input p-fbr-income-doc-code
            ,input p-is-tpsi-obj
            ,input p-rest-tpsi) no-error.
  IF error-status:error  then do:
    message
    substitute("&1 Были ошибки при резервировании:&2&3 &4"
                , vss-description
                , chr(10)
                , error-status:get-message(1)
                , return-value)
    view-as alert-box error .
    if p-is-tpsi-obj then run UI-on in this-procedure .
    return "error".
  end.
    if p-is-tpsi-obj then run UI-on in this-procedure .
  IF num_resv = 0  then do:
    if NOT auto-close
    and not p-auto-fbr
    then do:
      message
      "Не найдено товара для резервирования."
      view-as alert-box INFORMATION .
    end.
  end.
    p-next-prev = ?.
    run UI-on in this-procedure .
    if rgds-dtl <> ? then do:
      if r-or-v = 'es':U
      and r-office = 'т':U
      then
      reposition br-out to recid rgds-dtl no-error.
      else
      reposition br-ret to recid rgds-dtl no-error.
    end.
  if p-auto-fbr then do:
    assign
    error-status:error = no
    .
  end.
end.
END PROCEDURE.
PROCEDURE b-unres-proc:
define parameter buffer buf_inkas for ub.inkas.
define parameter buffer buf_trn-doc for ub.trn-doc.
define parameter buffer buf_ret-doc for ub.trn-doc.
define input parameter p-is-tpsi-obj  as logical no-undo .
define input parameter p-from-compense as logical no-undo .
define variable glog as logical no-undo .
define buffer locked_inkas for ub.inkas.
define buffer locked_trn-doc for ub.trn-doc.
if buf_trn-doc.status_ = 'запрос':U then return.
if not from-menu then
assign
rdoc-line = ?
rgds-dtl = ?
r-or-v = ?
r-office = ?
r-qnty = ?
.
assign
num_resv = 0
num_resv_res = 0
num_rec = 0
num_rec_res = 0
.
from-menu = no.
define variable vss-include-info65 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_sale_fact':U
    ,input  'object':U
    ,input  buf_inkas.host-code
    ,input  buf_inkas.obj-type
    ,input  buf_inkas.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if NOT glog then undo, return error.
if NOT can-find( first ub.chk-doc No-LOCK where ub.chk-doc.out-code = buf_inkas.inkas-code ) then do:
  undo, return error substitute("&1 Отчет о продаже пуст. Снять резервы невозможно.", vss-description).
end.
FIND FIRST locked_trn-doc WHERE
         locked_trn-doc.doc-code = buf_trn-doc.doc-code NO-LOCK .
glog = no.
RUN Inv-chk  in this-procedure (  input buf_Inkas.inkas-code
              , input v-curr-r-b
              , buffer buf_inkas
              , buffer buf_trn-doc
              , input r-or-v
              , input r-office
              , input rdoc-line) no-error .
IF error-status:error  then do:
 run waitfram-hide in this-procedure.
  message
  substitute("&1 Были ошибки при проверке документов на возможность разрезервирования:&2&3&2&4"
              , vss-description
              , chr(10)
              , error-status:get-message(1)
              , return-value)
  view-as alert-box error .
  undo, return "error".
end.
BadTrans = FALSE .
FIND FIRST locked_inkas WHERE recid( locked_inkas ) = recid( buf_Inkas ) .
FIND FIRST locked_trn-doc WHERE
           locked_trn-doc.doc-code = buf_inkas.inkas-code .
RUN UNRESERV in this-procedure (input p-is-tpsi-obj
                              , buffer locked_inkas
                              ) no-error .
IF error-status:error  then do:
 run waitfram-hide in this-procedure.
  message
  substitute("&1 Были ошибки при снятии резервов:&2&3 &4"
              , vss-description
              , chr(10)
              , error-status:get-message(1)
              , return-value)
  view-as alert-box error .
  undo, return error.
end.
IF num_resv = 0
and not p-from-compense
then do:
  message
  "Не найдено товара для снятия резервов."
  view-as alert-box INFORMATION .
end.
  p-next-prev = ?.
  run UI-on in this-procedure .
  if rgds-dtl <> ? then reposition br-out to recid rgds-dtl no-error.
  if error-status:error then
  reposition br-ret to recid rgds-dtl no-error.
END PROCEDURE.
PROCEDURE RESERV:
define parameter buffer buf_inkas for ub.inkas.
define parameter buffer buf_trn-doc for ub.trn-doc.
define input parameter p-auto-fbr as logical no-undo .
define input parameter p-rsrv-prop-goods as logical no-undo .
define input parameter p-rest-dish as logical no-undo .
define input parameter p-fbr-income-doc-code like ub.trn-doc.doc-code no-undo .
define input parameter p-is-tpsi-obj  as logical no-undo .
define input parameter p-rest-tpsi as logical no-undo .
DEFINE VARIABLE vat-value like ub.doc-line.vat-pc no-undo .
DEFINE VARIABLE slt-value like ub.doc-line.slt-pc no-undo .
define variable v-is-dish as character no-undo .
define variable v-is-modificator as character no-undo .
define variable v-run-tpsi-line as logical no-undo .
define variable v-run-tpsi as logical no-undo .
define buffer buf_sale-doc for ub.sale-doc.
define buffer dop_trn-doc for ub.trn-doc.
define variable v-user-action  as character no-undo .
define variable v-printed      as logical   no-undo .
define variable v-old-num_rec as integer no-undo .
define variable v-attr-value              as character no-undo .
define variable v-type                   as character no-undo .
if buf_trn-doc.status_ = 'запрос':U then return.
assign
num_rec = 0
num_rec_res = 0
num_resv = 0
num_resv_res = 0
num_rec_other = 0
num_rec_other_res = 0
r-artic =      "":U
r-prod-type = "":U
r-prod-code = 0
r-prt-code = 0
.
for each tt0-info:
  delete tt0-info.
end.
_buf_sale-doc:
for each buf_sale-doc where
       buf_sale-doc.inkas-code = buf_inkas.inkas-code
   and buf_sale-doc.order > 0
by buf_sale-doc.order
on error undo _buf_sale-doc, next _buf_sale-doc:
  if r-or-v <> ?
  and  (buf_sale-doc.doc-kind <> r-or-v
       or
       buf_sale-doc.chr-office <> r-office
       )
  then NEXT _buf_sale-doc.
  if not (buf_sale-doc.doc-kind = 'es':U
         and
         buf_sale-doc.chr-office = 'т':U) then do:
    find first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = buf_sale-doc.doc-code.
  end.
  if buf_sale-doc.doc-kind = 'rwo':U
  and r-or-v <> 'rwo':U then next _buf_sale-doc.
run waitfram-show in this-procedure (substitute("Резервирование товаров. &1", entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )) ).
  _doc-line:
  FOR EACH ub.doc-line EXCLUSIVE-LOCK WHERE
            ub.doc-line.doc-code = buf_trn-doc.doc-code,
      FIRST ub.goods WHERE
                ub.goods.artic = ub.doc-line.artic AND
                ub.goods.prod-type = ub.doc-line.prod-type AND
                ub.goods.prod-code = ub.doc-line.prod-code NO-LOCK
   on error undo _doc-line, next _doc-line :
    IF ub.doc-line.fact-qnty = ub.doc-line.doc-qnty then NEXT _doc-line.
    if buf_sale-doc.doc-kind = 'rs':U
    then do :
      find first ub.doc-fbr-gds no-lock where ub.doc-fbr-gds.out-code = replace(ub.doc-line.doc-code, "=", "-")
                                          and ub.doc-fbr-gds.gds-code = ub.goods.gds-code
                                          no-error.
      if available ub.doc-fbr-gds and ub.doc-fbr-gds.fact-qnty < 0
      then do :
        if ub.doc-line.doc-qnty = abs(ub.doc-fbr-gds.fact-qnty) then NEXT _doc-line.
      end.
    end.
    IF NOT (rdoc-line = ?) then do:
      if  NOT recid(ub.doc-line) = rdoc-line THEN NEXT _doc-line.
      assign
      r-artic = ub.doc-line.artic
      r-prod-type = ub.doc-line.prod-type
      r-prod-code = ub.doc-line.prod-code
      .
    end.
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  buf_inkas.shift-date
  ,input  buf_inkas.host-code
  ,input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output vat-value
  ) no-error .
    find first dop_trn-doc no-lock where
              dop_trn-doc.doc-code  = buf_sale-doc.doc-code.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_st-sltpc in g#lib-trn
(
 input  recid(ub.goods)
,input  recid(dop_trn-doc)
,input  buf_sale-doc.pay-code
,output slt-value
)
.
    assign
    doc-line.VAT-pc = vat-value
    doc-line.slt-pc = slt-value
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
    if can-find(first ub.tax-units where
                      ub.tax-units.tax-code = btltaxcd AND
                      LOOKUP(ub.tax-units.type, units.type) > 0) then  do:
        assign
        bottle = yes.
    end.
    else do:
        bottle = no.
    end.
    IF CAN-FIND(FIRST ub.doc-fbr-gds No-LOCK WHERE
                      ub.doc-fbr-gds.out-code = ub.doc-line.doc-code AND
                      ub.doc-fbr-gds.gds-code = ub.goods.gds-code)
    then do:
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run fgdsobjt in g#library
  (input  ub.doc-line.obj-type
  ,input  ub.doc-line.obj-code
  ,input  ub.goods.gds-code
  ,input  'is-dish=request,is-modificator=request'
  ,output v-is-dish
  )  .
      if not error-status:error
      then assign
      cashfbr = lookup('1':U, v-is-dish) > 0
      no-error .
    end.
    else cashfbr = no.
    rsrv-title = substitute("Резервирование. &1. Строк ", entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )).
    if buf_sale-doc.dir = 1 then do:
      assign
        v-old-num_rec = num_rec.
      run RSRV-line in this-procedure (
                    input 1,
                    input p-auto-fbr,
                    input p-rsrv-prop-goods,
                    input auto-fbr,
                    input p-rest-dish,
                    input p-fbr-income-doc-code,
                    input p-is-tpsi-obj,
                    input p-rest-tpsi,
                    input yes,
                    input ub.goods.gds-code,
                    input (if available ub.gds-prt then ub.gds-prt.node-code else ?),
                    output v-run-tpsi-line,
                    buffer ub.doc-line,
                    buffer buf_trn-doc,
                    buffer buf_sale-doc
                    ) no-error.
      if ub.doc-line.fact-qnty <> ub.doc-line.doc-qnty and v-log-handle <> ?
          and v-old-num_rec <> num_rec
      then do:
        run write-log-and-file in v-log-handle (
                            input 1
                          , input log-file-name
                          , input 1
                          , input substitute("Ошибка при резервировании товара артикул &1: требуемое кол-во &2 зарезервировано &3"
                                        ,ub.doc-line.artic
                                        ,ub.doc-line.fact-qnty
                                        ,ub.doc-line.doc-qnty
                                        )
                          ).
      end.
    end.
    else do:
      RUN gds-attr-value (
                          INPUT ub.goods.gds-code,
                          INPUT 'mark-type':U,
                          OUTPUT v-attr-value,
                          OUTPUT v-type
                          ).
      if v-attr-value > ""
      and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType(v-attr-value)
      then do :
        next _doc-line .
      end .
      run RSRV-line in this-procedure (
                    input -1,
                    input no,
                    input no ,
                    input auto-fbr,
                    input p-rest-dish,
                    input p-fbr-income-doc-code,
                    input p-is-tpsi-obj,
                    input p-rest-tpsi,
                    input yes,
                    input ub.goods.gds-code,
                    input (if available ub.gds-prt then ub.gds-prt.node-code else ?),
                    output v-run-tpsi-line,
                    buffer ub.doc-line,
                    buffer buf_trn-doc,
                    buffer buf_sale-doc
                    ) no-error.
    end.
    if error-status:error then do:
      if rdoc-line <> ? then do:
        run waitfram-hide in this-procedure .
        return error substitute("Ошибка при резервировании товаров:&1&2 &3"
                              , chr(10)
                              , error-status:get-message(1)
                              , return-value ).
      end.
      else next _doc-line.
    end.
    assign
    doc-line.price-base = cost-base
    doc-line.price-rubl = cost-rubl .
    if buf_sale-doc.doc-kind = 'es':U
    then do:
      assign
      v-run-tpsi = v-run-tpsi or v-run-tpsi-line.
    end.
  END.
  if buf_sale-doc.doc-kind = 'es':U then do:
    run waitfram-hide in this-procedure .
    if not p-rsrv-prop-goods
    and (p-is-tpsi-obj and v-run-tpsi)  then do:
    run waitfram-show in this-procedure ("Ждите... Идет резервирование ЧУЖИХ товаров." ).
      run str/tpsirsrv.p (
                      input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input p-auto
                      ,INPUT V-CURR-R-B
                      ,input buf_inkas.inkas-code
                      ,input buf_trn-doc.host-code
                      ,input buf_trn-doc.obj-type
                      ,input buf_trn-doc.obj-code
                      ,input r-artic
                      ,input r-prod-type
                      ,input r-prod-code
                      ,input r-prt-code
                      ,input yes
                      ,input "Резервирование ЧУЖИХ товаров. Расход. Строк "
                      ,input-output num_rec_res
                      ,output num_rec_other
                      ,output num_rec_other_res
                      ,buffer buf_trn-doc
                    ) no-error .
      if error-status:error then do:
        if p-rsrv-prop-goods
        or rdoc-line <> ? then do:
          run waitfram-hide in this-procedure .
          return error substitute("Ошибка при резервировании ЧУЖИХ товаров:&1&2 &3"
                                  , chr(10)
                                  , error-status:get-message(1)
                                  , return-value ).
        end.
        else do:
        end.
        run waitfram-hide in this-procedure .
      end.
    end.
  end.
  assign
  num_resv = num_resv + num_rec
  num_resv_res = num_resv_res + num_rec_res
  num_rec = 0
  num_rec_res = 0
  .
END.
if num_resv = num_resv_res and num_resv > 0 then do:
  if NOT auto-close and r-qnty = ? and not p-auto-fbr then do:
MESSAGE "Резервирование прошло успешно" view-as alert-box.
  end.
end.
else do:
  if auto-fbr then do:
  end.
  if  num_resv > 0 then do:
MESSAGE substitute("Из &1 позиций, подлежащих резервированию, успешно зарезервировано &2 (не зарезервировано &3)"                         , num_resv                                                                                      , num_resv_res                         , num_resv - num_resv_res) view-as alert-box.
    if search (log-file-name) <> ? and not (auto-close or p-auto-fbr or g#auto) then do:
      run gbl/prnfilen.w (
            input "Список не зарезервированных товаров":U
          , input 8
          , input search (log-file-name)
          , input 7
          , output v-user-action
          , output v-printed
      ).
      os-delete value(log-file-name) .
    end.
        if search ("alc-rsrv.log") <> ? and not (auto-close or p-auto-fbr or g#auto)  then do:
            run gbl/prnfilen.w (
                  input "Замечания по резервированию алкоголя":U
                , input 8
                , input search ("alc-rsrv.log")
                , input 7
                , output v-user-action
                , output v-printed
            ).
            os-delete value("alc-rsrv.log") .
        end.
  end.
  if num_resv > 0
  and (auto-close or p-auto-fbr) then return error "Не все товары, подлежащие резервированию, зарезервированы".
end.
END PROCEDURE.
PROCEDURE button-close:
define parameter buffer buf_trn-doc for ub.trn-doc.
define parameter buffer buf_ret-doc for ub.trn-doc.
define input parameter p-is-tpsi-obj as logical no-undo .
define input parameter auto-fbr as logical no-undo .
define input parameter p-neg-tpsi-weight as logical no-undo .
define input parameter p-neg-tpsi-qnty as decimal no-undo .
define input parameter p-neg-tpsi-oper as logical no-undo .
define output parameter b-close-enabled as logical no-undo .
define variable v-is-dish as character no-undo .
define variable v-doc-ii as integer no-undo .
define variable v-curr-doc-code like ub.trn-doc.doc-code no-undo .
define variable v-attr-value              as character no-undo .
define variable v-type                   as character no-undo .
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_goods for ub.goods.
define buffer buf_doc-line for ub.doc-line.
define buffer dop_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf_units for ub.units.
if buf_trn-doc.status_ = 'запрос':U then do:
    run waitfram-show in this-procedure ("Проверка отсутствия зарезервированного товара..." ).
end.
else do:
    run waitfram-show in this-procedure ("Проверка количества зарезервированного товара..." ).
  if auto-fbr then do:
    _buf_sale-doc:
    for each buf_sale-doc where
            buf_sale-doc.inkas-code = buf_trn-doc.doc-code
        and buf_sale-doc.order > 0
    by buf_sale-doc.order:
      if buf_sale-doc.doc-kind = 'es':U
      or buf_sale-doc.doc-kind = 'rs':U then do:
        for each buf_gds-dtl no-lock where
                  buf_gds-dtl.doc-code = buf_sale-doc.doc-code
            AND buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty,
          first buf_goods no-lock where
                buf_goods.artic = buf_gds-dtl.artic
            AND buf_goods.prod-type = buf_gds-dtl.prod-type
            AND buf_goods.prod-code = buf_gds-dtl.prod-code:
          if is-gas(buf_goods.gds-code) then next.
          RUN gds-attr-value (
                              INPUT buf_goods.gds-code,
                              INPUT 'mark-type':U,
                              OUTPUT v-attr-value,
                              OUTPUT v-type
                              ).
          if v-attr-value > ""
          and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType(v-attr-value)
          then do :
            next .
          end .
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run fgdsobjt in g#library
  (input  buf_gds-dtl.obj-type
  ,input  buf_gds-dtl.obj-code
  ,input  buf_goods.gds-code
  ,input  'is-dish=request,is-modificator=request'
  ,output v-is-dish
  ) no-error .
          if error-status:error or lookup('1':U, v-is-dish) = 0 then do:
            assign
            b-close-enabled = no
            .
            run waitfram-hide in this-procedure .
            return.
          end.
        end.
      end.
      else do:
        if buf_sale-doc.doc-kind = 'rwo':U then do:
          NEXT _buf_sale-doc.
        end.
        if buf_sale-doc.doc-kind = 'trf':U then do:
          find first buf_gds-dtl NO-LOCK where
                          buf_gds-dtl.doc-code = buf_sale-doc.doc-code
                      AND buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty USE-INDEX pi no-error .
          if available buf_gds-dtl
          then do:
            find first buf_goods no-lock where
                  buf_goods.artic = buf_gds-dtl.artic
              AND buf_goods.prod-type = buf_gds-dtl.prod-type
              AND buf_goods.prod-code = buf_gds-dtl.prod-code .
            RUN gds-attr-value (
                                INPUT buf_goods.gds-code,
                                INPUT 'mark-type':U,
                                OUTPUT v-attr-value,
                                OUTPUT v-type
                                ).
            if v-attr-value > ""
            and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType(v-attr-value)
            then do :
            end .
            else
            if not is-gas(buf_goods.gds-code)
            then do :
              assign
              b-close-enabled = no
              .
              run waitfram-hide in this-procedure .
              return.
            end.
          end.
        end.
      end.
    end.
  end.
  else do:
    _buf_sale-doc2:
    for each buf_sale-doc where
           buf_sale-doc.inkas-code = buf_trn-doc.doc-code
       and buf_sale-doc.order > 0
    by buf_sale-doc.order:
      if buf_sale-doc.doc-kind = 'rwo':U then do:
        next _buf_sale-doc2.
      end.
      if buf_sale-doc.doc-code = buf_trn-doc.doc-code
      and p-is-tpsi-obj
      then do:
        _tt:
        for each buf_Doc-line no-lock where
                buf_doc-line.doc-code = buf_trn-doc.doc-code:
          find first tt0-doc-line no-lock where
                tt0-doc-line.artic     = buf_doc-line.artic
            AND tt0-doc-line.prod-type = buf_doc-line.prod-type
            AND tt0-doc-line.prod-code = buf_doc-line.prod-code no-error .
          if p-neg-tpsi-oper
          and available tt0-doc-line
          and not (tt0-doc-line.obj-type = buf_doc-line.obj-type
              and tt0-doc-line.obj-code = buf_doc-line.obj-code)
          and can-find(first dtl-rests-mark where
                            dtl-rests-mark.artic = buf_doc-line.artic
                        and dtl-rests-mark.prod-type = buf_doc-line.prod-type
                        and dtl-rests-mark.prod-code = buf_doc-line.prod-code) then do:
            next  _tt.
          END.
          if  buf_doc-line.fact-qnty <= buf_doc-line.doc-qnty + (if available tt0-doc-line
                                                                then (tt0-doc-line.doc-qnty +  p-neg-tpsi-qnty)
                                                                else 0)
                                                                then do:
            next  _tt.
          end.
          if p-neg-tpsi-weight then do:
            find first buf_goods no-lock where
                    buf_goods.artic = buf_doc-line.artic
                AND buf_goods.prod-type = buf_doc-line.prod-type
                AND buf_goods.prod-code = buf_doc-line.prod-code .
            find first buf_units no-lock where
                        buf_units.unit-name = buf_goods.unit-base.
            if lookup('вес':U, buf_units.type) > 0 then do:
              next _tt.
            end.
          end.
          b-close-enabled = no.
          run waitfram-hide in this-procedure .
          return.
        end.
      end.
      else do:
        _gds-dtl:
        for each buf_gds-dtl NO-LOCK where
                    buf_gds-dtl.doc-code = buf_sale-doc.doc-code
                AND buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty USE-INDEX pi :
          find first goods no-lock where goods.artic = buf_gds-dtl.artic
                                     and goods.prod-type = buf_gds-dtl.prod-type
                                     and goods.prod-code = buf_gds-dtl.prod-code
                                     .
          RUN gds-attr-value (
                              INPUT goods.gds-code,
                              INPUT 'mark-type':U,
                              OUTPUT v-attr-value,
                              OUTPUT v-type
                              ).
          if v-attr-value > ""
          and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType(v-attr-value)
          then do :
            next _gds-dtl .
          end .
          if buf_sale-doc.doc-kind = 'rs':U
          then do :
            find first doc-fbr-gds no-lock where doc-fbr-gds.out-code = replace(buf_gds-dtl.doc-code, "=", "-")
                                             and doc-fbr-gds.gds-code = goods.gds-code
                                             no-error .
          end.
          if buf_sale-doc.doc-kind = 'es':U
          then do :
            find first doc-fbr-gds no-lock where doc-fbr-gds.out-code = buf_gds-dtl.doc-code
                                             and doc-fbr-gds.gds-code = goods.gds-code
                                             no-error .
          end.
          if available doc-fbr-gds
          then do :
            next.
          end.
          assign
          b-close-enabled = no
          .
          run waitfram-hide in this-procedure .
          return.
        end.
      end.
    END.
  end.
end.
assign
b-close-enabled = yes.
run waitfram-hide in this-procedure .
END.
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
run waitfram-show in this-procedure (substitute("Снятие резервов. &1.", entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )) ).
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
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  buf_inkas.shift-date
  ,input  buf_inkas.host-code
  ,input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output vat-value
  ) no-error .
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                    input no,
                    input "":U,
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
          run waitfram-hide in this-procedure.
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
    run waitfram-hide in this-procedure.
    if p-is-tpsi-obj
    and v-run-tpsi
    then do:
    run waitfram-show in this-procedure ("Ждите... Идет снятие резервов ЧУЖИХ товаров" ).
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
        run waitfram-hide in this-procedure.
        if rdoc-line <> ? then do:
        return error substitute("Ошибка при снятии резервов ЧУЖИХ товаров:&1&2 &3"
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value ).
        end.
      end.
      run waitfram-hide in this-procedure.
    end.
  end.
  assign
  num_resv = num_resv + num_rec
  num_resv_res = num_resv_res + num_rec_res
  num_rec = 0
  num_rec_res = 0
  .
  run waitfram-hide in this-procedure.
  release buf_trn-doc.
end.
if num_resv = 0 then.
else do:
  if num_resv_res = num_resv and  num_resv > 0 and r-qnty = ? then do:
MESSAGE "Снятие резервов прошло успешно" view-as alert-box.
  end.
  else do:
    if r-qnty = ? then do:
MESSAGE substitute("Из &1 позиций для снятия резервов,&2" +                         "успешно сняты резервы с &3"                                         , num_resv                                                           , chr(10)                                                        , num_resv_res) view-as alert-box.
    end.
  end.
end.
END PROCEDURE.
PROCEDURE get-gds-rec:
  CASE CURRENT-BROWSER:
      WHEN br-out:handle IN FRAME d-sale  then do:
          IF AVAILABLE out-goods then
          gds-rec = recid(out-goods).
          ELSE IF AVAILABLE ret-goods then
          gds-rec = recid(ret-goods).
          ELSE BELL.
      END.
      WHEN br-ret:handle  IN FRAME d-sale then do:
          IF AVAILABLE ret-goods then
          gds-rec = recid(ret-goods).
          ELSE IF AVAILABLE out-goods then
          gds-rec = recid(out-goods).
          ELSE BELL.
      END.
  END CASE.
END PROCEDURE.
PROCEDURE proc-places :
    define variable v-is-petrol as logical no-undo.
    define variable v-is-pieces as logical no-undo.
    IF error-status:error then return no-apply.
    IF (CURRENT-BROWSER = brwh-out-dtl
    and bh-out-dtl:available )
    or (CURRENT-BROWSER = brwh-ret-dtl
    and bh-ret-dtl:available )
    then do:
    end.
    else do:
      case current-browser:
        when brwh-out-dtl then do:
          if bh-ret-dtl:available then
          assign
          current-browser = brwh-ret-dtl.
          else  do:
            bell.
            APPLY "ENTRY" to brwh-out-dtl.
            return error.
          end.
        end.
        when brwh-ret-dtl then do:
          if bh-out-dtl:available then
          assign
          current-browser = brwh-out-dtl.
          else  do:
            bell.
            APPLY "ENTRY" to brwh-ret-dtl.
            return error.
          end.
        end.
      END CASE.
    end.
    assign
        bhg = current-browser:query:get-buffer-handle(3)
        bhb = current-browser:query:get-buffer-handle(4)
    .
    assign
        v-gds-code  = bhg:buffer-field('gds-code':U):buffer-value
        v-artic     = bhg:buffer-field('artic':U):buffer-value
        v-prod-type = bhg:buffer-field('prod-type':U):buffer-value
        v-prod-code = bhg:buffer-field('prod-code':U):buffer-value
        v-b-code    = bhb:buffer-field('b-code':U):buffer-value
    .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input v-artic
  ,  input v-prod-type
  ,  input v-prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) no-error.
    if not v-is-petrol then do :
        message "Выбран нетопливный товар!" view-as alert-box.
        return no-apply.
    end.
    assign v-to-reserv = no .
    DO TRANSACTION on ERROR undo, return no-apply
                        on STOP undo, return no-apply :
        run  str/sale-plc.w (input parparentproc,
                             input v-gds-code,
                             input v-b-code,
                             buffer ink-doc,
                             output v-to-reserv) .
        if return-value = "cancell":U then undo, return no-apply .
    END.
END PROCEDURE.
PROCEDURE proc-chek-tovar:
DEFINE VARIABLE rid-list as character no-undo .
IF (CURRENT-BROWSER = brwh-out-dtl
and bh-out-dtl:available )
or (CURRENT-BROWSER = brwh-ret-dtl
and bh-ret-dtl:available )
then do:
end.
else do:
  case current-browser:
    when brwh-out-dtl then do:
      if bh-ret-dtl:available then
      assign
      current-browser = brwh-ret-dtl.
      else  do:
        bell.
        APPLY "ENTRY" to brwh-out-dtl.
        return error.
      end.
    end.
    when brwh-ret-dtl then do:
      if bh-out-dtl:available then
      assign
      current-browser = brwh-out-dtl.
      else  do:
        bell.
        APPLY "ENTRY" to brwh-ret-dtl.
        return error.
      end.
    end.
  END CASE.
end.
assign
bh = current-browser:query:get-buffer-handle(1)
bhg = current-browser:query:get-buffer-handle(3)
bhb = current-browser:query:get-buffer-handle(4)
.
assign
v-doc-code = bh:buffer-field ('doc-code':U):buffer-value
v-gds-code = bhg:buffer-field('gds-code':U):buffer-value
v-recid = bhg:recid
v-b-code = bhb:buffer-field('b-code':U):buffer-value
.
FIND FIRST ub.doc-prts No-LOCK WHERE
          ub.doc-prts.out-code = v-doc-code
      AND ub.doc-prts.gds-code = v-gds-code No-ERROR.
IF AVAILABLE ub.doc-prts then cashparts = yes.
else cashparts = no.
if cashparts
then   run ref/gds-chks.w (
                      input parparentproc
                    ,input v-recid
                    ,input (if p-mode = 'ПРОСМОТР':U then "":U else "b-del":U)
                    ,input 'продажа':U
                    ,input ?
                    ,input ink-doc.obj-type
                    ,input ink-doc.obj-code
                    ,input ink-doc.inkas-code
                    ,input "":U
                    ,output rid-list
                      ).
ELSE run ref/gds-chk.w (
                      input parparentproc
                    ,input v-b-code
                    ,input (if p-mode = 'ПРОСМОТР':U then "":U else "b-del":U)
                    ,input 'продажа':U
                    ,input ?
                    ,input ink-doc.obj-type
                    ,input ink-doc.obj-code
                    ,input ink-doc.inkas-code
                    ,input "":U
                    ,output rid-list
                    ).
if return-value = "deleted" then run ui-on in this-procedure .
apply "entry" to current-browser .
END PROCEDURE.
PROCEDURE proc-parts-tovar:
define buffer b-doc-line for ub.doc-line.
define variable what-mode as logical no-undo initial yes.
define variable v-doc-qnty like ub.doc-line.doc-qnty no-undo .
define variable v-prt-rec as recid no-undo .
define variable rgds-dtl as rowid no-undo .
if v-is-inquiry then return .
IF (CURRENT-BROWSER = brwh-out-dtl
and bh-out-dtl:available )
or (CURRENT-BROWSER = brwh-ret-dtl
and bh-ret-dtl:available )
then do:
end.
else do:
  case current-browser:
    when brwh-out-dtl then do:
      if bh-ret-dtl:available then
      assign
      current-browser = brwh-ret-dtl.
      else  do:
        bell.
        APPLY "ENTRY" to brwh-out-dtl.
        return error.
      end.
    end.
    when brwh-ret-dtl then do:
      if bh-out-dtl:available then
      assign
      current-browser = brwh-out-dtl.
      else  do:
        bell.
        APPLY "ENTRY" to brwh-ret-dtl.
        return error.
      end.
    end.
  END CASE.
end.
bh = current-browser:query:get-buffer-handle(1).
bhg = current-browser:query:get-buffer-handle(3).
assign
rgds-dtl = bh:rowid
v-doc-code = bh:buffer-field('doc-code':U):buffer-value
v-artic = bh:buffer-field('artic':U):buffer-value
v-prod-type = bh:buffer-field('prod-type':U):buffer-value
v-prod-code = bh:buffer-field('prod-code':U):buffer-value
v-gds-code = bhg:buffer-field('gds-code':U):buffer-value
.
FIND FIRST b-doc-line No-LOCK WHERE
            b-doc-line.doc-code = v-doc-code
       AND  b-doc-line.artic = v-artic
       AND  b-doc-line.prod-type = v-prod-type
       AND  b-doc-line.prod-code = v-prod-code No-ERROR.
assign
v-doc-qnty = b-doc-line.doc-qnty
.
if can-find(first ub.doc-prts where
                  ub.doc-prts.gds-code = v-gds-code
              AND ub.doc-prts.out-code = v-doc-code)
OR
can-find(first ub.doc-pl where
              ub.doc-pl.gds-code = v-gds-code
         AND  ub.doc-pl.out-code = v-doc-code)
OR
can-find(first ub.doc-pl-pump where
              ub.doc-pl-pump.gds-code = v-gds-code
        AND   ub.doc-pl-pump.out-code = v-doc-code)
or
can-find(first ub.doc-fbr-gds where
              ub.doc-fbr-gds.gds-code = v-gds-code
          AND ub.doc-fbr-gds.out-code = v-doc-code)
then
what-mode = no.
apply "Value-CHAnged" to current-browser.
run str/parts-l.w (
              input parparentproc
              ,input ink-doc.obj-type
              ,input ink-doc.obj-code
              ,input v-gds-code
              ,input v-doc-code
              ,input (if  (p-mode = 'ИЗМЕНЕНИЕ':U
                            and what-mode
                            )
                      then 'ИЗМЕНЕНИЕ':U
                      else 'ПРОСМОТР':U
                      )
              ,input (if ink-doc.status_ = 'факт':U
                      then 'все':U
                      else 'документ':U
                      )
              ,input 'текущий':U
              ,input 'документ':U
              ,output v-prt-rec
              ).
apply "entry" to current-browser.
FIND FIRST b-doc-line No-LOCK WHERE
          b-doc-line.doc-code = v-doc-code
      AND b-doc-line.artic = v-artic
      AND b-doc-line.prod-type = v-prod-type
      AND b-doc-line.prod-code = v-prod-code No-ERROR.
if b-doc-line.doc-qnty <> v-doc-qnty then do:
  run UI-on in this-procedure .
  if rgds-dtl <> ? then qh:reposition-to-rowid( rgds-dtl) no-error.
  apply "entry" to current-browser.
end.
END PROCEDURE.
procedure frame-title :
  do
  on error undo, return error
  :
    assign
    frame d-sale:title = (if t-doc.status_ = 'запрос':U
                                 then t-doc.status_
                                 else '':U) + chr(32) +
                                  substitute("&1 №&2  Дата: &3  Факт&4: &5 &6 &7"
                                            , (t-doc.obj-type + string(t-doc.obj-code))
                                            , t-doc.doc-code
                                            , string (t-doc.doc-date, "99/99/9999")
                                            , (if ink-doc.status_ <> 'факт':U
                                             and
                                             ink-doc.status_ <> 'запрос':U
                                             then "(ожидается)" else "":U)
                                            , string ( t-doc.fact-date, "99/99/9999" )
                                            , (IF cas-shft then (" смена N " + shift-name-no-err(buffer ink-doc)) else "" )
                                            , (IF one-curs then (" чеки по курсу " + string(t-doc.base-rate / t-doc.base-scale)) else "")
                                          ).
   browse br-out:title = substitute("Продажи &1 &2", 'т':U, t-doc.doc-code)
  .
  end.
end procedure.
procedure ui-2 :
  do
  on error undo, return error
  :
    apply "entry" to br-out in frame d-sale.
    reposition br-out to row 1 no-error.
  end.
end procedure.
procedure enable-menu-items :
define variable v-chr-office as character no-undo .
define variable v-doc-kind as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
do
on error undo, return error
:
assign
v-doc-kind = entry(1, br-2-mode, chr(4) )
v-chr-office = entry(2, br-2-mode, chr(4) )
.
for each wh:
  if valid-handle(wh.mi-reserv) then do:
    delete widget wh.mi-reserv.
  end.
  if valid-handle(wh.mi-unreserv) then do:
    delete widget wh.mi-unreserv.
  end.
  if valid-handle(wh.mi-parts) then do:
    delete widget wh.mi-parts.
  end.
  if valid-handle(wh.mi-arch) then do:
    delete widget wh.mi-arch.
  end.
  delete wh.
end.
_sale-doc:
for each buf_sale-doc no-lock where
        buf_Sale-doc.inkas-code = ink-doc.inkas-code:
  create wh.
  buffer-copy buf_sale-doc to wh
  .
  if buf_sale-doc.order <= 0 then next _sale-doc.
  create menu-item wh.mi-reserv
  assign
  name = substitute("m-res-&1", buf_sale-doc.doc-kind, buf_sale-doc.chr-office)
  label = substitute("&1 &2 - Выбранный товар", entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ), buf_sale-doc.chr-office)
  parent = menu m-recs:handle
  triggers:
    on choose
      persistent run mi-res ( input  wh.doc-kind, input wh.chr-office) .
  end triggers.
  create menu-item wh.mi-unreserv
  assign
  name = substitute("m-unres-&1", buf_sale-doc.doc-kin, buf_sale-doc.chr-office)
  label = substitute("&1 &2 - Выбранный товар", entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ), buf_sale-doc.chr-office)
  parent = menu m-unrecs:handle
  triggers:
    on choose
      persistent run mi-unres ( input  wh.doc-kind, input wh.chr-office) .
  end triggers.
  create menu-item wh.mi-parts
  assign
  name = substitute("m-parts-&1", buf_sale-doc.doc-kin, buf_sale-doc.chr-office)
  label = substitute("&1 &2", entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ), buf_sale-doc.chr-office)
  parent = menu m-parts:handle
  triggers:
    on choose
      persistent run mi-parts ( input  wh.doc-kind, input wh.chr-office) .
  end triggers.
  create menu-item wh.mi-arch
  assign
  name = substitute("m-arch-&1", buf_sale-doc.doc-kin, buf_sale-doc.chr-office)
  label = substitute("&1 &2", entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ), buf_sale-doc.chr-office)
  parent = menu m-arch:handle
  triggers:
    on choose
      persistent run mi-arch ( input  wh.doc-kind, input wh.chr-office) .
  end triggers.
  assign
  wh.mi-reserv:sensitive = (if wh.doc-kind = v-doc-kind
                      and wh.chr-office = v-chr-office
                      and wh.doc-kind = buf_sale-doc.doc-kind
                      and wh.chr-office = buf_sale-doc.chr-office
                      then yes
                      else wh.mi-reserv:sensitive)
  wh.mi-unreserv:sensitive = (if wh.doc-kind = v-doc-kind
                      and wh.chr-office = v-chr-office
                      and wh.doc-kind = buf_sale-doc.doc-kind
                      and wh.chr-office = buf_sale-doc.chr-office
                      then yes
                      else wh.mi-unreserv:sensitive)
  wh.mi-arch:sensitive = (if wh.doc-kind = buf_sale-doc.doc-kind
                      and wh.chr-office = buf_sale-doc.chr-office
                      then yes
                      else wh.mi-arch:sensitive)
  wh.mi-parts:sensitive = (if wh.doc-kind = buf_sale-doc.doc-kind
                      and wh.chr-office = buf_sale-doc.chr-office
                      then yes
                      else wh.mi-arch:sensitive)
 .
 if wh.mi-parts:name =  "m-parts-rw" then do:
   if buf_sale-doc.doc-kind = 'rwo':U
   and (ink-doc.status_ = 'факт':U or ink-doc.status_ = 'запрос':U) then
   wh.mi-parts:sensitive = yes.
   else wh.mi-parts:sensitive = no.
 end.
end.
end.
end procedure.
procedure reget-br-2 :
define variable v-found as logical no-undo .
define variable old-br-2-mode as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf2_sale-doc for ub.sale-doc.
do
on error undo, return error
:
assign
old-br-2-mode = br-2-mode
br-2-doc-code = '':U
br-2-mode = chr(4)
v-found = no
v-list-item-pairs = '':U
.
for each buf_sale-doc no-lock where
        buf_sale-doc.inkas-code = ink-doc.inkas-code
    and buf_sale-doc.order > 0:
  if (buf_sale-doc.doc-kind = 'es':U
      and buf_sale-doc.chr-office = 'т':U)
  or buf_sale-doc.order <= 0
  then next.
  assign
  br-2-mode = (if br-2-mode = chr(4)
               then (buf_sale-doc.doc-kind  + chr(4) + buf_sale-doc.chr-office)
               else br-2-mode)
  br-2-doc-code  = (if entry(1, br-2-mode, chr(4)) = buf_sale-doc.doc-kind
                    and entry(2, br-2-mode, chr(4)) = buf_sale-doc.chr-office
                    then buf_sale-doc.doc-code
                    else br-2-doc-code)
  .
  if buf_sale-doc.doc-kind = old-br-2-mode then do:
    assign
    v-found = yes
    br-2-doc-code = buf_sale-doc.doc-code + chr(4) + buf_sale-doc.chr-office
    .
  end.
  v-list-item-pairs = v-list-item-pairs + (if v-list-item-pairs = '':U then '':U else chr(44)) +
                    entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ) + chr(32) + buf_sale-doc.chr-office + chr(44) +
                    buf_sale-doc.doc-kind  + chr(4) + buf_sale-doc.chr-office.
end.
br-2-mode = (if old-br-2-mode = chr(4)
              or not v-found
              then br-2-mode else old-br-2-mode)
.
end.
end procedure.
procedure set-compensed :
define input parameter p-compensed as logical no-undo .
  do
  on error undo, return error
  :
     assign
     compensed = p-compensed.
  end.
end procedure.
procedure reposition-inkas :
define input parameter p-direction as character no-undo .
define variable v-new-inkas-recid as recid no-undo .
do
on error undo, return error
:
  if valid-handle(p-call-prog)
  then do:
    run reposition-inkas in p-call-prog
      (input  p-direction
      ,output v-new-inkas-recid
      ).
    if v-new-inkas-recid <> ?
    then do:
      define buffer buf_inkas for ub.inkas .
      find first buf_inkas no-lock
        where recid(buf_inkas) = v-new-inkas-recid
        no-error .
      assign
      p-doc-rec = v-new-inkas-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список документов не определен." view-as alert-box INFORMATION .
    return no-apply.
  end.
end.
end procedure.
procedure mi-arch :
define input parameter p-doc-kind as character no-undo .
define input parameter p-chr-office as character no-undo .
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
do
on error undo, return error
:
  find first buf_sale-doc where
            buf_sale-doc.inkas-code = ink-doc.inkas-code
        and buf_sale-doc.doc-kind = p-doc-kind
        and buf_sale-doc.chr-office = p-chr-office  no-error .
  if not available buf_sale-doc then return error.
  find first buf_trn-doc no-lock where
          buf_trn-doc.doc-code = buf_sale-doc.doc-code no-error.
  if not available buf_trn-doc then do:
      message
    substitute("Не найдено: &1 &2", entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ), buf_sale-doc.doc-code).
  end.
    run str/docisupp.p
      (input  parparentproc
      ,input  recid(buf_trn-doc)
      ).
end.
end procedure.
procedure mi-parts :
define input parameter p-doc-kind as character no-undo .
define input parameter p-chr-office as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
define variable v-recid as recid no-undo .
define buffer buf_trn-doc for ub.trn-doc.
do
on error undo, return error
:
  find first buf_sale-doc where
            buf_sale-doc.inkas-code = ink-doc.inkas-code
        and buf_sale-doc.doc-kind = p-doc-kind
        and buf_sale-doc.chr-office = p-chr-office no-error .
  if not available buf_sale-doc
  then do:
    return error.
  end.
  find first buf_trn-doc no-lock where
          buf_trn-doc.doc-code = buf_sale-doc.doc-code no-error.
  if not available buf_trn-doc then do:
      message
    substitute("Не найдено: &1 &2", entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ), buf_sale-doc.doc-code).
  end.
    run str/partsneg.w (
      input parParentProc
      ,input buf_sale-doc.doc-code
      ,input (if p-mode = 'ИЗМЕНЕНИЕ':U
              and ink-doc.status_ = 'новый':U
              then 'ИЗМЕНЕНИЕ':U
              else 'ПРОСМОТР':U)
      ,input-output v-recid
      ).
end.
end procedure.
procedure mi-res :
define input parameter p-doc-kind as character no-undo .
define input parameter p-chr-office as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
do
on error undo, return error
:
  if p-doc-kind = 'es':U
  and p-chr-office = 'т':U then do:
    assign
    bh = bh-out-dtl
    brwh = brwh-out-dtl
    .
  end.
  else do:
    if entry(1, br-2-mode, chr(4)) = 'rwo':U  then return error.
    assign
    bh = bh-ret-dtl
    brwh = brwh-ret-dtl
    .
  end.
  if not bh:available then return no-apply.
  assign
  v-doc-code = (bh:buffer-field('doc-code':U):buffer-value)
  v-artic = (bh:buffer-field('artic':U):buffer-value)
  v-prod-type = (bh:buffer-field('prod-type':U):buffer-value)
  v-prod-code = (bh:buffer-field('prod-code':U):buffer-value)
  .
  FIND FIRST ub.doc-line NO-LOCK WHERE
          ub.doc-line.doc-code  =  v-doc-code
      and ub.doc-line.artic     =  v-artic
      and ub.doc-line.prod-type =  v-prod-type
      and ub.doc-line.prod-code =  v-prod-code  No-ERROR.
  IF NOT available ub.doc-line then return no-apply.
  assign
  rdoc-line = recid (ub.doc-line)
  rgds-dtl = bh:recid
  r-or-v = p-doc-kind
  r-office = p-chr-office
  r-qnty = ?
  r-b-code = ?
  r-pl-code = ?
  r-doc-prts-qnty = ?
  from-menu = yes.
  run b-res-proc in this-procedure (
                                      buffer ink-doc
                                    , buffer t-doc
                                    , buffer ret-doc
                                    , input no
                                    , input auto-close
                                    , input no
                                    , input rest-dish
                                    , input "":U
                                    , input v-is-tpsi-obj
                                    , input rest-tpsi) no-error.
  if error-status:error or return-value = "error" then do:
    run waitfram-hide in this-procedure .
    return no-apply.
  end.
  APPLY "ENTRY" to brwh  .
end.
end procedure.
procedure mi-unres :
define input parameter p-doc-kind as character no-undo .
define input parameter p-chr-office as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
do
on error undo, return error
:
  if p-doc-kind = 'es':U
  and p-chr-office = 'т':U
  then do:
    assign
    bh = bh-out-dtl
    brwh = brwh-out-dtl
    .
  end.
  else do:
    if entry(1, br-2-mode, chr(4)) = 'rwo':U then return error.
    assign
    bh = bh-ret-dtl
    brwh = brwh-ret-dtl
    .
  end.
  if not bh:available then return error.
  assign
  v-doc-code = (bh:buffer-field('doc-code':U):buffer-value)
  v-artic = (bh:buffer-field('artic':U):buffer-value)
  v-prod-type = (bh:buffer-field('prod-type':U):buffer-value)
  v-prod-code = (bh:buffer-field('prod-code':U):buffer-value)
  .
  FIND FIRST ub.doc-line NO-LOCK WHERE
          ub.doc-line.doc-code = v-doc-code
      and ub.doc-line.artic    =  v-artic
      and ub.doc-line.prod-type = v-prod-type
      and ub.doc-line.prod-code = v-prod-code  No-ERROR.
  IF NOT available ub.doc-line then return no-apply.
  assign
  rdoc-line = recid (ub.doc-line)
  rgds-dtl = bh:recid
  r-or-v = p-doc-kind
  r-office = p-chr-office
  r-qnty = ?
  r-b-code = ?
  r-pl-code = ?
  r-doc-prts-qnty = ?
  from-menu = yes
  .
  apply "choose" to b-unres in frame d-sale.
  APPLY "ENTRY" to brwh.
end.
end procedure.
PROCEDURE write-log-and-file :
define input parameter p-tab-position as integer   no-undo.
define input parameter p-file-name    as character no-undo .
define input parameter p-log-level    as integer   no-undo .
define input parameter p-log-string   as character no-undo .
    run writelog in this-procedure (
          input log-file-name
        , input p-log-level
        , input p-log-string
    ).
END PROCEDURE.
