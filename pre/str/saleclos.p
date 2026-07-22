block-level on error undo, throw.
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character        no-undo.
define variable v-curr-r-b     as character no-undo .
define variable p-inkas-code   like ub.inkas.inkas-code no-undo .
define variable p-auto         as integer no-undo .
define variable auto-close     as logical no-undo .
define variable b-mail-pressed as logical no-undo .
define variable auto-comp      as logical no-undo .
define variable auto-fbr       as logical no-undo .
define variable one-curs       as logical no-undo .
define variable p-is-catering  as logical no-undo .
define variable p-is-tpsi-obj  as logical no-undo .
define variable rest-dish      as logical no-undo .
define variable rest-ingr      as logical no-undo .
define variable rest-tpsi      as logical no-undo .
define variable neg-tpsi-weight as logical no-undo .
define variable neg-tpsi-qnty   as decimal no-undo .
define variable neg-tpsi-oper   as logical no-undo .
define variable close-in-rfsl as integer no-undo .
define variable pay-gds-algo    as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Закрытие продажи".
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
    assign
      p-vss-parameters = substitute('&1':u,p-inkas-code)
    .
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
define variable v-view-log as logical no-undo .
define variable v-esm as character no-undo .
define variable v-input-error as logical no-undo .
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
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_fbr-history no-undo like ub.fbr-history .
define variable v-fbrhist-history-level     as integer      no-undo.
define variable v-fbrhist-upper-obj-type    as character    no-undo.
define variable v-fbrhist-upper-obj-code    as integer      no-undo.
define variable v-fbrhist-upper-code        as integer      no-undo.
define variable v-fbrhist-current-obj-type  as character    no-undo.
define variable v-fbrhist-current-obj-code  as integer      no-undo.
define variable v-fbrhist-current-code      as integer      no-undo.
define variable v-fbrhist-saved-obj-type    as character    no-undo.
define variable v-fbrhist-saved-obj-code    as integer      no-undo.
define variable v-fbrhist-saved-code        as integer      no-undo.
procedure fbrhist-write :
define input parameter p-userid                 as character        no-undo.
define input parameter p-obj-type               as character        no-undo.
define input parameter p-obj-code               as integer          no-undo.
define input parameter p-hst-type               as character        no-undo.
define input parameter p-hst-level              as integer          no-undo.
define input parameter p-procedure-name         as character        no-undo.
define input parameter p-procedure-parameters   as character        no-undo.
define input parameter p-doc-code               as character        no-undo.
define input parameter p-doc-type               as character        no-undo.
define input parameter p-status_                as character        no-undo.
define input parameter p-is-free                as logical          no-undo.
define input parameter p-recipe-code            as character        no-undo.
define input parameter p-recipe-type            as character        no-undo.
define input parameter p-gds-code               as integer          no-undo.
define input parameter p-trn-type               as character        no-undo.
define input parameter p-qnty                   as decimal          no-undo.
define input parameter p-PS                     as character        no-undo.
define input parameter p-is-error               as logical          no-undo.
    define variable v-today                         as date         no-undo.
    define variable v-obj-date                      as date         no-undo.
    define variable v-time                          as integer      no-undo.
    define variable v-host-code                     as integer      no-undo.
    define variable v-db-num                        as integer      no-undo.
    define buffer buf_temp_fbr-history       for temp_fbr-history.
    define buffer buf_upper_temp_fbr-history for temp_fbr-history.
do
for buf_temp_fbr-history
  , buf_upper_temp_fbr-history
on error undo, return error
:
    if v-fbrhist-history-level = 0
    or v-fbrhist-history-level < p-hst-level
    then do:
        undo, return .
    end.
    if v-fbrhist-upper-code <> 0
    then do:
        find first buf_upper_temp_fbr-history no-lock
             where buf_upper_temp_fbr-history.obj-type = v-fbrhist-upper-obj-type
               and buf_upper_temp_fbr-history.obj-code = v-fbrhist-upper-obj-code
               and buf_upper_temp_fbr-history.hst-code = v-fbrhist-upper-code
        no-error.
    end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-date
  )  .
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
    create buf_temp_fbr-history.
    assign
        buf_temp_fbr-history.obj-type                = p-obj-type
        buf_temp_fbr-history.obj-code                = p-obj-code
        buf_temp_fbr-history.hst-code                = next-value( s-fbr-num, ub)
        buf_temp_fbr-history.hst-type                = p-hst-type
        buf_temp_fbr-history.hst-level               = p-hst-level
        buf_temp_fbr-history.hst-upper-code          = v-fbrhist-upper-code
        buf_temp_fbr-history.procedure-name          = p-procedure-name
        buf_temp_fbr-history.procedure-parameters    = p-procedure-parameters
        buf_temp_fbr-history.doc-code                = p-doc-code
        buf_temp_fbr-history.doc-type                = p-doc-type
        buf_temp_fbr-history.status_                 = p-status_
        buf_temp_fbr-history.is-free                 = p-is-free
        buf_temp_fbr-history.recipe-code             = p-recipe-code
        buf_temp_fbr-history.recipe-type             = p-recipe-type
        buf_temp_fbr-history.gds-code                = p-gds-code
        buf_temp_fbr-history.trn-type                = p-trn-type
        buf_temp_fbr-history.qnty                    = p-qnty
        buf_temp_fbr-history.PS                      = p-ps
        buf_temp_fbr-history.is-error                = p-is-error
        buf_temp_fbr-history.db-num                  = v-db-num
        buf_temp_fbr-history.user-name               = p-userid
        buf_temp_fbr-history.sys-date                = v-today
        buf_temp_fbr-history.sys-time-int            = v-time
        buf_temp_fbr-history.sys-time                = string( v-time, "HH:MM:SS" )
        buf_temp_fbr-history.obj-date                = v-obj-date
        buf_temp_fbr-history.host-code               = v-host-code
    .
    assign
        v-fbrhist-current-obj-type                   = p-obj-type
        v-fbrhist-current-obj-code                   = p-obj-code
        v-fbrhist-current-code                       = buf_temp_fbr-history.hst-code
    .
    if available buf_upper_temp_fbr-history
    then do:
        assign
            buf_temp_fbr-history.hst-node-path = buf_temp_fbr-history.hst-node-path
                    + chr(2)  + string( buf_temp_fbr-history.obj-type )
                                            + "-":U + string( buf_temp_fbr-history.obj-code )
                                            + "-":U + string( buf_temp_fbr-history.hst-code )
        .
    end.
    else do:
        assign
            buf_temp_fbr-history.hst-node-path = string( buf_temp_fbr-history.obj-type )
                               + "-":U + string( buf_temp_fbr-history.obj-code )
                               + "-":U + string( buf_temp_fbr-history.hst-code )
        .
    end.
end.
end procedure.
procedure fbrhist-read-conf :
do
on error undo, return error
:
   define variable v-value-character as character  no-undo .
   define variable v-value-date      as date       no-undo .
   define variable v-value-decimal   as decimal    no-undo .
   define variable v-value-logical   as logical    no-undo .
   define variable v-tth             as handle     no-undo .
   define variable v-param-type            as character no-undo .
   run adm/shattri.p ( input "get":U
                     , input  '':u
                     , input  0
                     , input  'fbrattr':U
                     , input  'fbrhstlv':U
                     , output v-value-character
                     , output v-value-date
                     , output v-value-decimal
                     , output v-fbrhist-history-level
                     , output v-value-logical
                     , output v-param-type
                     , input-output table-handle v-tth
                     ) no-error .
   if error-status :error then do:
      assign
         v-fbrhist-history-level = 0
      .
   end.
end.
end procedure.
procedure fbrhist-table-to-base :
    define buffer buf_fbr-history       for ub.fbr-history.
    define buffer buf_temp_fbr-history  for temp_fbr-history.
do
for buf_fbr-history
  , buf_temp_fbr-history
on error undo, return error
:
    for each buf_temp_fbr-history
    on error undo, return error
    :
        create buf_fbr-history.
        buffer-copy buf_temp_fbr-history to buf_fbr-history.
    end.
end.
end procedure.
procedure fbrhist-init :
    define buffer buf_temp_fbr-history      for temp_fbr-history.
do
for buf_temp_fbr-history
on error undo, return error
:
    for each buf_temp_fbr-history
    :
        delete buf_temp_fbr-history.
    end.
    assign
        v-fbrhist-upper-obj-type    = ""
        v-fbrhist-upper-obj-code    = 0
        v-fbrhist-upper-code        = 0
        v-fbrhist-current-obj-type  = ""
        v-fbrhist-current-obj-code  = 0
        v-fbrhist-current-code      = 0
        v-fbrhist-saved-obj-type    = ""
        v-fbrhist-saved-obj-code    = 0
        v-fbrhist-saved-code        = 0
    .
end.
end procedure.
procedure fbrhist-set-upper-code :
do
on error undo, return error
:
    assign
        v-fbrhist-upper-obj-type    = v-fbrhist-current-obj-type
        v-fbrhist-upper-obj-code    = v-fbrhist-current-obj-code
        v-fbrhist-upper-code        = v-fbrhist-current-code
    .
end.
end procedure.
procedure fbrhist-save-current-code :
do
on error undo, return error
:
    assign
        v-fbrhist-saved-obj-type    = v-fbrhist-current-obj-type
        v-fbrhist-saved-obj-code    = v-fbrhist-current-obj-code
        v-fbrhist-saved-code        = v-fbrhist-current-code
    .
end.
end procedure.
procedure fbrhist-set-upper-from-saved-code :
do
on error undo, return error
:
    assign
        v-fbrhist-upper-obj-type    = v-fbrhist-saved-obj-type
        v-fbrhist-upper-obj-code    = v-fbrhist-saved-obj-code
        v-fbrhist-upper-code        = v-fbrhist-saved-code
    .
end.
end procedure.
procedure fbrhist-set-zero-upper-code :
do
on error undo, return error
:
    assign
        v-fbrhist-upper-obj-type    = ""
        v-fbrhist-upper-obj-code    = 0
        v-fbrhist-upper-code        = 0
    .
end.
end procedure.
define new global shared variable g#libtfarh as handle no-undo .
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_fbrcode-doc-code no-undo
    field rec-type      as character
    field doc-code      as character
    field obj-type      as character
    field obj-code      as integer
    field cli-type      as character
    field cli-code      as integer
    field ext-doc-type  as character
    field doc-type      as character
    field order         as integer
    index pi is primary unique rec-type doc-code
    index od order
.
procedure fbrcode-gen-recipe-code :
do
on error undo, return error
:
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define output parameter p-recipe-code       as character    no-undo.
    assign
        p-recipe-code   = string( next-value( s-recipe, ub ) )
                            + "-"
                            + trim( string( p-obj-code, ">>>>9" ) )
                            + substring( p-obj-type, ( if g#language = "RUS" then 1 else 2 ), 1 )
    .
end.
end procedure.
procedure fbrcode-is-from-object :
do
on error undo, return error
:
define input parameter p-doc-code           as character    no-undo.
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define output parameter p-is-from-object    as logical      no-undo.
    if num-entries( p-doc-code, "-" ) < 2
    or entry( 2, p-doc-code, "-" ) <> trim (string (p-obj-code, ">>>>9"))
                                    + substring( p-obj-type, ( if g#language = "RUS" then 1 else 2 ), 1 )
    then do:
        assign
            p-is-from-object = no
        .
    end.
    else do:
        assign
            p-is-from-object = yes
        .
    end.
end.
end procedure.
procedure fbrcode-trn-doc :
do
on error undo, return error
:
    define input parameter p-out-doc-type       as character    no-undo.
    define input parameter p-out-code           as character    no-undo.
    define input parameter p-trn-doc-out-type   as character    no-undo.
    define output parameter p-trn-doc-doc-code  as character   no-undo.
    case p-out-doc-type:
        when 'производство':U
        then do:
            case p-trn-doc-out-type :
                when 'рас':U
                then do:
                    assign
                        p-trn-doc-doc-code = p-out-code
                    .
                end.
                when 'при':U
                then do:
                    assign
                        p-trn-doc-doc-code = replace ( p-out-code, "-", "=" )
                    .
                end.
                when 'спи':U
                then do:
                    assign
                        p-trn-doc-doc-code = replace ( p-out-code, "-", "*" )
                    .
                end.
                otherwise do:
                    assign
                        p-trn-doc-doc-code = ""
                    .
                    undo, return error "Не может быть обработан тип складского документа '"
                                        + p-trn-doc-out-type + "' во входных параметрах".
                end.
            end case.
        end.
        otherwise do:
            assign
                p-trn-doc-doc-code = ""
            .
            undo, return error "Не может быть обработан тип внешнего документа '"
                                + p-out-doc-type + "' во входных параметрах".
        end.
    end case.
end.
end procedure.
procedure fbrcode-fill-fbr-by-sale-or-pln :
define input parameter p-main-doc-code      as character        no-undo.
    define variable v-order    as integer      no-undo.
    define buffer buf_fbr-doc               for ub.fbr-doc.
    define buffer buf_trn-doc               for ub.trn-doc.
    define buffer buf_temp_fbrcode-doc-code for temp_fbrcode-doc-code.
do
for buf_fbr-doc
  , buf_trn-doc
  , buf_temp_fbrcode-doc-code
on error undo, return error
:
    for each buf_temp_fbrcode-doc-code
    on error undo, return error
    :
        delete buf_temp_fbrcode-doc-code.
    end.
    assign
        v-order = 0
    .
    for each buf_fbr-doc no-lock
       where buf_fbr-doc.out-code = p-main-doc-code
    on error undo, return error
    :
        create buf_temp_fbrcode-doc-code.
        assign
            buf_temp_fbrcode-doc-code.rec-type      = 'производство':U
            buf_temp_fbrcode-doc-code.doc-code      = buf_fbr-doc.doc-code
            buf_temp_fbrcode-doc-code.ext-doc-type  = "":U
            buf_temp_fbrcode-doc-code.obj-type      = buf_fbr-doc.obj-type
            buf_temp_fbrcode-doc-code.obj-code      = buf_fbr-doc.obj-code
            buf_temp_fbrcode-doc-code.cli-type      = buf_fbr-doc.obj-type
            buf_temp_fbrcode-doc-code.cli-code      = buf_fbr-doc.obj-code
            buf_temp_fbrcode-doc-code.doc-type      = buf_fbr-doc.doc-type
        .
        for each buf_trn-doc no-lock
           where buf_trn-doc.out-code = buf_fbr-doc.doc-code
        by buf_trn-doc.fact-order
        on error undo, return error
        :
            if buf_trn-doc.ext-doc-type = 'em':U
            or buf_trn-doc.ext-doc-type = 'im':U
            or buf_trn-doc.ext-doc-type = 'wm':U
            or buf_trn-doc.ext-doc-type = 'ev':U
            then do:
                assign
                    v-order = v-order + 1
                .
                create buf_temp_fbrcode-doc-code.
                assign
                    buf_temp_fbrcode-doc-code.doc-code      = buf_trn-doc.doc-code
                    buf_temp_fbrcode-doc-code.rec-type      = 'скл':U
                    buf_temp_fbrcode-doc-code.ext-doc-type  = buf_trn-doc.ext-doc-type
                    buf_temp_fbrcode-doc-code.obj-type      = buf_trn-doc.obj-type
                    buf_temp_fbrcode-doc-code.obj-code      = buf_trn-doc.obj-code
                    buf_temp_fbrcode-doc-code.cli-type      = buf_trn-doc.cli-type
                    buf_temp_fbrcode-doc-code.cli-code      = buf_trn-doc.cli-code
                    buf_temp_fbrcode-doc-code.doc-type      = buf_trn-doc.doc-type
                    buf_temp_fbrcode-doc-code.order         = v-order
                .
            end.
        end.
        assign
            v-order  = v-order + 1
        .
        find first buf_temp_fbrcode-doc-code
             where buf_temp_fbrcode-doc-code.rec-type = 'производство':U
               and buf_temp_fbrcode-doc-code.doc-code = buf_fbr-doc.doc-code
        .
        assign
            buf_temp_fbrcode-doc-code.order = v-order
        .
    end.
    for each buf_trn-doc no-lock
       where buf_trn-doc.out-code = p-main-doc-code
    by buf_trn-doc.fact-order
    on error undo, return error
    :
        assign
            v-order = v-order + 1
        .
        create buf_temp_fbrcode-doc-code.
        assign
            buf_temp_fbrcode-doc-code.doc-code      = buf_trn-doc.doc-code
            buf_temp_fbrcode-doc-code.rec-type      = 'маг':U
            buf_temp_fbrcode-doc-code.ext-doc-type  = buf_trn-doc.ext-doc-type
            buf_temp_fbrcode-doc-code.obj-type      = buf_trn-doc.obj-type
            buf_temp_fbrcode-doc-code.obj-code      = buf_trn-doc.obj-code
            buf_temp_fbrcode-doc-code.cli-type      = buf_trn-doc.cli-type
            buf_temp_fbrcode-doc-code.cli-code      = buf_trn-doc.cli-code
            buf_temp_fbrcode-doc-code.doc-type      = buf_trn-doc.doc-type
            buf_temp_fbrcode-doc-code.order         = v-order
        .
    end.
end.
end procedure.
procedure fbrcode-get-final-doc :
define input parameter p-main-doc-code      as character        no-undo.
define output parameter p-income-doc-code   as character        no-undo.
    define variable v-main-obj-type    as character    no-undo.
    define variable v-main-obj-code    as integer      no-undo.
    define buffer buf_trn-doc               for ub.trn-doc.
    define buffer buf_temp_fbrcode-doc-code for temp_fbrcode-doc-code.
do
for buf_trn-doc
on error undo, return error
:
    run fbrcode-fill-fbr-by-sale-or-pln in this-procedure (
        input p-main-doc-code
    ).
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-main-doc-code
    .
    assign
        v-main-obj-type = buf_trn-doc.obj-type
        v-main-obj-code = buf_trn-doc.obj-code
    .
    find first buf_temp_fbrcode-doc-code
         where buf_temp_fbrcode-doc-code.ext-doc-type = 'ev':U
           and buf_temp_fbrcode-doc-code.cli-type     = v-main-obj-type
           and buf_temp_fbrcode-doc-code.cli-code     = v-main-obj-code
    no-error.
    if available buf_temp_fbrcode-doc-code
    then do:
        find first buf_trn-doc no-lock
             where buf_trn-doc.out-code     = buf_temp_fbrcode-doc-code.doc-code
               and buf_trn-doc.ext-doc-type = 'iv':U
        .
        assign
            p-income-doc-code = buf_trn-doc.doc-code
        .
    end.
    else do:
        find first buf_temp_fbrcode-doc-code
             where buf_temp_fbrcode-doc-code.ext-doc-type = 'im':U
               and buf_temp_fbrcode-doc-code.obj-type     = v-main-obj-type
               and buf_temp_fbrcode-doc-code.obj-code     = v-main-obj-code
        no-error.
        if available buf_temp_fbrcode-doc-code
        then do:
            assign
                p-income-doc-code = buf_temp_fbrcode-doc-code.doc-code
            .
        end.
        else do:
            assign
                p-income-doc-code = "":U
            .
        end.
    end.
end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
def var vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION set-inkas-PS returns character(    input p-ps as character,
                                            input p-chk-amount as integer,
                                            input p-gds-amount as integer,
                                            input p-line-out as integer,
                                            input p-dtl-out as integer,
                                            input p-line-ret as integer,
                                            input p-dtl-ret as integer,
                                            input p-nf-chk-amount as integer,
                                            input p-nf-gds-amount as integer,
                                            input p-ps-where-rus as character
                                            ):
define variable v-ps as character no-undo .
define variable v-other as character no-undo .
v-other = p-ps.
entry(1, v-other, "@") = ''.
v-other = trim(v-other, "@").
v-PS = substitute('Кол-во_чеков &2&1строк_чеков &3&1товаров_расход &4&1признаков_расход &5&1товаров_возврат &6&1признаков_возврат &7&1'
                    , chr(4)
                    , p-chk-amount
                    , p-gds-amount
                    , p-line-out
                    , p-dtl-out
                    , p-line-ret
                    , p-dtl-ret).
v-ps = v-ps +  substitute("без_докум_чеков &1&2без_докум_строк_чеков &3&2&4@&5"
                            , p-nf-chk-amount
                            , chr(4)
                            , p-nf-gds-amount
                            , p-ps-where-rus
                            , v-other)
                    .
return v-ps.
END FUNCTION.
FUNCTION set-inkas-PS-simple returns character(
                                            input p-chk-amount as integer,
                                            input p-gds-amount as integer,
                                            input p-line-out as integer,
                                            input p-dtl-out as integer,
                                            input p-line-ret as integer,
                                            input p-dtl-ret as integer,
                                            input p-nf-chk-amount as integer,
                                            input p-nf-gds-amount as integer
                                            ):
define variable v-ps as character no-undo .
define variable v-str1 as character no-undo .
assign
  v-ps = fill( chr(32) +  chr(4), 9).
  v-str1 = ENTRY(1, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-chk-amount).
  ENTRY(1, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(2, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-gds-amount).
  ENTRY(2, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(3, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-line-out).
  ENTRY(3, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(4, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-dtl-out).
  ENTRY(4, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(5, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-line-ret).
  ENTRY(5, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(6, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-dtl-ret).
  ENTRY(5, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(7, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-nf-chk-amount).
  ENTRY(5, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(8, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-nf-gds-amount).
  ENTRY(5, v-PS, chr(4)) = v-str1.
return v-ps.
END FUNCTION.
FUNCTION get-inkas-nf-PS-simple returns logical (
                                             input p-ps as character
                                            ,output p-gds-amount as integer
                                            ,output p-nf-gds-amount as integer
                                            ):
if num-entries(p-ps, chr(4)) >= 8 then do:
  assign
  p-gds-amount = integer(entry(2, ENTRY(2, p-PS, chr(4)), chr(32)))
  p-nf-gds-amount = integer(entry(2, ENTRY(8, p-PS, chr(4)), chr(32)))
  no-error .
end.
return not error-status:error .
END FUNCTION.
PROCEDURE get-inkas-PS:
define parameter buffer buf_inkas for ub.inkas.
define output parameter p-chk-amount as integer no-undo .
define output parameter p-gds-amount as integer no-undo .
define output parameter p-line-out as integer no-undo .
define output parameter p-dtl-out as integer no-undo .
define output parameter p-line-ret as integer no-undo .
define output parameter p-dtl-ret as integer no-undo .
define output parameter p-nf-chk-amount as integer no-undo .
define output parameter p-nf-gds-amount as integer no-undo .
define output parameter p-ps-where-rus as character no-undo .
define variable v-gds-amount as integer no-undo .
define variable v-nf-gds-amount as integer no-undo .
define buffer buf_sale-doc for ub.sale-doc.
for each buf_sale-doc no-lock where
        buf_sale-doc.inkas-code = buf_inkas.inkas-code
    and buf_sale-doc.order > 0:
  assign
  p-gds-amount = p-gds-amount + (if buf_sale-doc.in-inkas = yes
                                 or buf_sale-doc.doc-kind = 'trf':U
                                 then buf_sale-doc.gds-amount
                                 else 0)
  p-line-out = p-line-out  + (if buf_sale-doc.in-inkas = yes
                              and buf_sale-doc.dir = 1
                              then buf_sale-doc.tot-lines
                              else 0)
  p-dtl-out = p-dtl-out + (if buf_sale-doc.in-inkas = yes
                          and buf_sale-doc.dir = 1
                          then buf_sale-doc.tot-dtl
                          else 0)
  p-line-ret = p-line-ret  + (if buf_sale-doc.in-inkas = yes
                              and buf_sale-doc.dir = -1
                              then buf_sale-doc.tot-lines
                              else 0)
  p-dtl-ret = p-dtl-ret + (if buf_sale-doc.in-inkas = yes
                           and buf_sale-doc.dir = -1
                          then buf_sale-doc.tot-dtl
                          else 0)
  .
end.
if get-inkas-nf-PS-simple( input buf_inkas.ps
                          ,output v-gds-amount
                          ,output v-nf-gds-amount) then do:
  assign
  p-gds-amount = v-gds-amount
  p-nf-gds-amount = v-nf-gds-amount
  .
end.
assign
p-ps-where-rus = buf_inkas.sale-filter-rus
p-nf-chk-amount = buf_inkas.num-chk-nf
p-chk-amount = buf_inkas.num-chk
.
END PROCEDURE.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table tt0-info no-undo
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
define SHARED temp-table tt0-doc-line no-undo like lib-trn_ret-line.
define SHARED temp-table tt0-gds-dtl  no-undo like ub.gds-dtl.
define SHARED temp-table tt0-parts    no-undo like ub.parts.
define SHARED temp-table temp-tpsi-clients  no-undo like ub.clients.
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION set-sale-doc-PS returns character( buffer buf_sale-doc for ub.sale-doc):
define variable v-ps as character no-undo .
if available buf_sale-doc then
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , chr(4)
                    , (if buf_sale-doc.chr-office = 'у':U then "УСЛУГИ." else "ТОВАРЫ." )
                    , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                    , buf_sale-doc.chk-amount
                    , buf_sale-doc.gds-amount
                    , buf_sale-doc.tot-lines
                    , buf_sale-doc.tot-dtl
                    ).
else  do:
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , chr(4)
                    , '':U
                    , entry (lookup ('es':U, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                    , 0
                    , 0
                    , 0
                    , 0
                    ).
end.
return v-ps.
END FUNCTION.
FUNCTION get-sale-doc-kind returns character (
                                             input p-doc-kind as character
                                           , input p-ext-doc-type as character
                                           , output p-order as integer
                                           , output p-msign as integer
                                           , output p-main as logical
                                           , output p-in-inkas as logical
                                           , output p-dir_ as integer
                                           ):
define variable v-doc-kind as character no-undo.
define variable v-type as character no-undo .
define variable v-value as character no-undo .
CASE p-doc-kind:
  when 'es':U then do:
    assign
    p-order = 100
    p-msign = 1
    p-main = yes
    p-in-inkas = yes
    p-dir_ = 1
    .
    return p-ext-doc-type.
  end.
  when  'rs':U then do:
    assign
    p-order = 200
    p-msign = - 1
    p-main = no
    p-in-inkas = yes
    p-dir_ = - 1
    .
    return p-ext-doc-type.
  end.
  when 'rwo':U then do:
    assign
    p-msign = - 1
    p-main = no
    p-in-inkas = no
    p-order = 300
    p-dir_ = 1
    .
    return 'rwo':U.
  end.
  when 'trf':U then do:
    assign
    p-msign = 1
    p-main = no
    p-in-inkas = no
    p-order = 400
    p-dir_ = 1
    .
    return 'trf':U.
  end.
  when 'swo':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order =  500
   p-dir_ = 1
   .
   return 'swo':U.
 end.
 when 'vir':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 600
   p-dir_ = 1
   .
   return 'vir':U.
 end.
 when 'itr':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = -1
   p-dir_ = -1
   .
  return 'itr':U.
 end.
 when 'ngs':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 700
   p-dir_ = 1
   .
   return 'ngs':U.
 end.
 when 'rgs':U then do:
   assign
   p-msign = -1
   p-main = no
   p-in-inkas = no
   p-order = 701
   p-dir_ = -1
   .
   return 'rgs':U.
 end.
 otherwise do:
    assign
    p-msign = 1
    p-main = no
    p-in-inkas = no
    p-order = -1.
    return p-ext-doc-type.
  end.
END CASE.
END FUNCTION.
procedure saledoc-create :
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-doc-kind as character no-undo .
define input parameter p-office as character no-undo .
define input parameter p-tpsidoc as logical no-undo .
define input parameter p-alias-type-price as character no-undo .
define input parameter p-price-obj-type as character no-undo .
define input parameter p-price-obj-code as integer no-undo .
define parameter buffer buf_trn-doc for ub.trn-doc.
define variable v-order as integer no-undo.
define variable v-main as logical no-undo .
define variable v-in-inkas as logical no-undo .
define variable v-msign as integer no-undo .
define variable v-dir_ as integer no-undo .
define variable v-trn-doc-code as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
   if available buf_trn-doc then do:
     v-trn-doc-code = buf_trn-doc.doc-code.
   end.
   find first buf_sale-doc where
            buf_sale-doc.inkas-code = p-inkas-code
        and buf_sale-doc.doc-kind = p-doc-kind
        and buf_sale-doc.chr-office = p-office
        and (v-trn-doc-code = '' or buf_sale-doc.doc-code = v-trn-doc-code)
        no-error .
   if not available buf_sale-doc  then do:
      create buf_sale-doc.
      assign
      buf_sale-doc.inkas-code = p-inkas-code
      buf_sale-doc.storage =  'trn-doc':U
      buf_sale-doc.host-code = p-host-code
      buf_sale-doc.obj-type = p-obj-type
      buf_sale-doc.obj-code = p-obj-code
      buf_sale-doc.doc-kind  = p-doc-kind
      buf_sale-doc.order = lookup(p-doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) * 100 + (if p-office = 'у':U then 5 else 0)
      buf_sale-doc.chr-office = p-office
      buf_sale-doc.doc-code = v-trn-doc-code
      .
   end.
   if available buf_trn-doc then
   buffer-copy buf_trn-doc
   to buf_sale-doc
   .
  assign
  buf_sale-doc.doc-kind = get-sale-doc-kind (
                                             input p-doc-kind
                                            ,input buf_sale-doc.ext-doc-type
                                            ,output v-order
                                            ,output v-msign
                                            ,output v-main
                                            ,output v-in-inkas
                                            ,output v-dir_).
  assign
  buf_sale-doc.order = v-order + (if p-office = 'у':U then 5 else 0)
  buf_sale-doc.main-doc = v-main
  buf_sale-doc.in-inkas = v-in-inkas
  buf_sale-doc.msign = v-msign
  buf_sale-doc.dir = v-dir_
  buf_sale-doc.fbrsale = lookup(buf_sale-doc.doc-kind, 'es,swo':U) > 0
  buf_sale-doc.main-receipt-type = integer(entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) + 1, '0,1,6,96,17,69,17,17':U))
  buf_sale-doc.poss-wro-codes = '':U
  buf_sale-doc.chr-office = p-office
  buf_sale-doc.tpsidoc = p-tpsidoc
  buf_sale-doc.alias-type-price = p-alias-type-price
  buf_sale-doc.price-obj-type = (if p-tpsidoc
                                 then p-price-obj-type
                                 else '':U)
  buf_sale-doc.price-obj-code = (if p-tpsidoc
                                 then p-price-obj-code
                                 else 0)
  .
  assign
  buf_sale-doc.poss-wro-codes = (if (v-order > 0 and buf_sale-doc.doc-kind <> 'vir':U) then entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) + 1, '0,2,-2,-6;-3;-9;-4,17,1;3':U) else '':U)
  no-error.
end.
END.
procedure fbr-saledoc-create :
define input parameter p-inkas-code as character no-undo .
define variable v-pri-prvo-doc-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-fact-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-tot-lines like ub.trn-doc.tot-lines no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf2_sale-doc for ub.sale-doc.
define buffer buf2_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-doc for ub.chk-doc.
do
on error undo, return error
:
  for each buf_fbr-doc no-lock where
        buf_fbr-doc.out-code = p-inkas-code:
    for each buf_trn-doc no-lock where
          buf_trn-doc.out-code = buf_fbr-doc.doc-code
    by buf_trn-doc.fact-order
    on error undo, return error:
      if buf_trn-doc.ext-doc-type = 'em':U
      or buf_trn-doc.ext-doc-type = 'im':U
      or buf_trn-doc.ext-doc-type = 'wm':U
      or buf_trn-doc.ext-doc-type = 'ev':U
      or buf_trn-doc.ext-doc-type = 'iv':U
      then do:
        find first buf_sale-doc where
                buf_sale-doc.inkas-code = p-inkas-code
            and buf_sale-doc.doc-code = buf_trn-doc.doc-code
            AND buf_sale-doc.storage  = 'trn-doc':U
                no-error .
        if not available buf_sale-doc then do:
        create buf_sale-doc.                                                                                             buffer-copy buf_trn-doc                                                                                             to buf_sale-doc.                                                                                                assign                                                                                                                  buf_sale-doc.storage  =  'trn-doc':U                                                                          buf_sale-doc.doc-kind = buf_trn-doc.ext-doc-type                                                                buf_sale-doc.order =  - 1                                                                                          buf_sale-doc.main-doc = no                                                                                             buf_sale-doc.in-inkas = no                                                                                         buf_sale-doc.fbrsale = yes                                                                                         buf_sale-doc.msign = 1                                                                                             buf_sale-doc.filled   = buf_sale-doc.fact-qnty <> 0 or buf_sale-doc.tot-lines <> 0                       buf_sale-doc.doc-qnty = (if buf_sale-doc.ext-doc-type = 'pc':U                                                           then ?                                                                                                                  else buf_sale-doc.doc-qnty)                                                          buf_sale-doc.fact-qnty = (if buf_sale-doc.ext-doc-type = 'pc':U                                                          then ?                                                                                                                  else buf_sale-doc.fact-qnty)                                                        buf_sale-doc.inkas-code = p-inkas-code.
        end.
        if buf_trn-doc.ext-doc-type = 'im':U then do:
          assign
          v-pri-prvo-doc-qnty = buf_trn-doc.doc-qnty
          v-pri-prvo-fact-qnty = buf_trn-doc.fact-qnty
          v-pri-prvo-tot-lines = buf_trn-doc.tot-lines
          .
        end.
        for each buf2_trn-doc no-lock where
                buf2_trn-doc.out-code = buf_sale-doc.doc-code:
          find first buf2_sale-doc where
                  buf2_sale-doc.inkas-code = p-inkas-code
              and buf2_sale-doc.doc-code = buf2_trn-doc.doc-code
              AND buf2_sale-doc.storage = 'trn-doc':U no-error .
          if not available buf2_sale-doc then do:
            create buf2_sale-doc.                                                                                             buffer-copy buf2_trn-doc                                                                                             to buf2_sale-doc.                                                                                                assign                                                                                                                  buf2_sale-doc.storage  =  'trn-doc':U                                                                          buf2_sale-doc.doc-kind = buf2_trn-doc.ext-doc-type                                                                buf2_sale-doc.order =  - 1                                                                                          buf2_sale-doc.main-doc = no                                                                                             buf2_sale-doc.in-inkas = no                                                                                         buf2_sale-doc.fbrsale = yes                                                                                         buf2_sale-doc.msign = 1                                                                                             buf2_sale-doc.filled   = buf2_sale-doc.fact-qnty <> 0 or buf2_sale-doc.tot-lines <> 0                       buf2_sale-doc.doc-qnty = (if buf2_sale-doc.ext-doc-type = 'pc':U                                                           then ?                                                                                                                  else buf2_sale-doc.doc-qnty)                                                          buf2_sale-doc.fact-qnty = (if buf2_sale-doc.ext-doc-type = 'pc':U                                                          then ?                                                                                                                  else buf2_sale-doc.fact-qnty)                                                        buf2_sale-doc.inkas-code = p-inkas-code.
          end.
        end.
      end.
    end.
    find first buf_sale-doc where
              buf_sale-doc.inkas-code = p-inkas-code
          AND buf_sale-doc.storage = 'fbr-doc':U
          AND buf_sale-doc.doc-code = buf_fbr-doc.doc-code no-error .
    if not available buf_sale-doc then do:
      create buf_sale-doc.
      assign
      buf_sale-doc.storage       =  'fbr-doc':U
      buf_sale-doc.doc-type      = 'производство':U
      buf_sale-doc.doc-code      = buf_fbr-doc.doc-code
      buf_sale-doc.ext-doc-type  = 'производство':U
      buf_sale-doc.doc-kind      = 'производство':U
      buf_sale-doc.obj-type      = buf_fbr-doc.obj-type
      buf_sale-doc.obj-code      = buf_fbr-doc.obj-code
      buf_sale-doc.cli-type      = buf_fbr-doc.obj-type
      buf_sale-doc.cli-code      = buf_fbr-doc.obj-code
      buf_sale-doc.doc-qnty      = v-pri-prvo-doc-qnty
      buf_sale-doc.fact-qnty     = v-pri-prvo-fact-qnty
      buf_sale-doc.tot-lines     = v-pri-prvo-tot-lines
      buf_sale-doc.tot-dtl       = v-pri-prvo-tot-lines
      buf_sale-doc.fbrsale       = yes
      buf_sale-doc.inkas-code    = p-inkas-code
      .
    end.
  end.
end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table dtl-rests-mark no-undo
field artic like ub.gds-dtl.artic
field prod-type like ub.gds-dtl.prod-type
field prod-code like ub.gds-dtl.prod-code
index   pi  is primary
artic
prod-type
prod-code
.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#lib-farh as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-goods no-undo
field doc-code like ub.chk-gds.doc-code
field line-num like ub.chk-gds.line-num
field object-sum like ub.chk-discnt.object-sum
index pi is unique primary
doc-code
line-num.
define temp-table temp-chk-doc no-undo
field orig-doc-code like ub.chk-doc.doc-code
field doc-code like ub.chk-doc.doc-code
field obj-type like ub.chk-doc.obj-type
field obj-code like ub.chk-doc.obj-code
field netto    like ub.chk-doc.netto
index pi is unique primary
doc-code
index idoc-code orig-doc-code
.
procedure chksplin :
define parameter buffer buf_chk-doc for ub.chk-doc.
define input  parameter p-d-card-mode   as integer no-undo .
define output parameter p-nf-gds-amount as integer no-undo .
DEFINE VARIABLE current-line-num like ub.chk-discnt.line-num no-undo .
DEFINE VARIABLE current-line-num-bonus like ub.chk-discnt.line-num no-undo .
define variable v-proprietor-host-code as integer no-undo .
define variable v-proprietor-obj-code as integer no-undo .
define variable v-proprietor-obj-type as character no-undo .
define variable v-gran as integer no-undo .
define variable v-new-doc-code as character no-undo .
define variable v-ratio as decimal no-undo .
define variable v-ratio-bonus as decimal no-undo .
define variable v-object-sum as decimal no-undo .
define variable v-object-sum-bonus as decimal no-undo .
define variable v-object-sump as decimal no-undo .
define variable v-object-sump-bonus as decimal no-undo .
define variable v-num-docs  as integer no-undo .
define variable v-ii as integer no-undo .
define buffer bufp_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer bufp_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
define buffer bufp_chk-pay for ub.chk-pay.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer bufp_chk-discnt for ub.chk-discnt.
define buffer buf_bar-code for ub.bar-code.
define buffer bufp_temp-goods for temp-goods.
_main:
do
on error undo, return error return-value
:
  if not buf_chk-doc.office = 'т':U
  and not buf_chk-doc.office = 'у':U then do:
     return substitute("чек &1 не может быть разбит на по отделам(магазинам)&2имеются ошибки в чеке&3"
                      ,buf_chk-doc.doc-code
                      ,chr(10)
                      ,buf_chk-doc.office).
  end.
  for each buf_chk-gds where
          buf_chk-gds.doc-code = buf_chk-doc.doc-code
  on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    find first buf_bar-code no-lock where
              buf_bar-code.b-code = buf_chk-gds.b-code no-error .
    if not available buf_bar-code then do:
      undo _main, return error substitute("Не найден бар-код &1&2строка &3 чек &4 дата &5 касса &6 № на кассе&7"
                                          , buf_chk-gds.b-code
                                          , chr(10)
                                          , buf_chk-gds.line-num
                                          , buf_chk-doc.doc-code
                                          , buf_Chk-doc.chk-date
                                          , buf_chk-doc.pay-desk
                                          , buf_chk-doc.chk-num).
    end.
    run tpsi-gds-proprietor in this-procedure (
                                                input buf_bar-code.gds-code
                                              ,input g#db-num
                                              ,output v-proprietor-host-code
                                              ,output v-proprietor-obj-type
                                              ,output v-proprietor-obj-code ) no-error.
    if error-status:error then do:
      undo _main, return error (substitute("Ошибка при получении принадлежности товара с кодом &1&2строка &3 чек &4 дата &5 касса &6 № на кассе&7&2"
                                          , buf_bar-code.gds-code
                                          , chr(10)
                                          , buf_chk-gds.line-num
                                          , buf_chk-doc.doc-code
                                          , buf_Chk-doc.chk-date
                                          , buf_chk-doc.pay-desk
                                          , buf_chk-doc.chk-num) +
                                substitute("&1&2&3&2"
                                            , error-status:get-message(1)
                                            , chr(10)
                                            , return-value ))
                                          .
    end.
    if v-proprietor-obj-code = 0
    or v-proprietor-obj-code = ?
    then do:
      assign
      v-proprietor-obj-type = buf_chk-doc.obj-type
      v-proprietor-obj-code = buf_chk-doc.obj-code
      .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-proprietor-obj-type
  ,input  v-proprietor-obj-code
  ,output v-proprietor-host-code
  )  .
    end.
    assign
    v-gran = 0
    v-gran = if r-index(buf_chk-gds.doc-code, '-':U) > 0
             then r-index(buf_chk-gds.doc-code, '-':U)
             else 0
    v-new-doc-code = (if v-gran > 0
                     then substring(buf_chk-gds.doc-code, 1, v-gran - 1)
                     else buf_chk-gds.doc-code) + '>' + string(v-proprietor-obj-code).
    find first temp-chk-doc where
              temp-chk-doc.doc-code = v-new-doc-code
          and temp-chk-doc.obj-type = v-proprietor-obj-type
          and temp-chk-doc.obj-code = v-proprietor-obj-code no-error .
    if not available temp-chk-doc then do:
      create temp-chk-doc.
      assign
      temp-chk-doc.orig-doc-code = buf_chk-doc.doc-code
      temp-chk-doc.doc-code = v-new-doc-code
      temp-chk-doc.obj-type = v-proprietor-obj-type
      temp-chk-doc.obj-code = v-proprietor-obj-code
      v-num-docs            = v-num-docs + 1
      .
      create bufp_chk-doc.
      buffer-copy buf_chk-doc
      except
      obj-type obj-code doc-code
      netto tot-doc discnt sub-discnt out-code
      d-card src-d-card cli-type src-cli-type cli-code src-cli-code
      to bufp_chk-doc
      assign
      bufp_chk-doc.doc-code = v-new-doc-code
      bufp_chk-doc.obj-type = v-proprietor-obj-type
      bufp_chk-doc.obj-code = v-proprietor-obj-code
      bufp_chk-doc.PS = buf_chk-doc.ps + "@":U + "split":U
      .
      if p-d-card-mode = 2
      or p-d-card-mode = 3
      then do:
        assign
        bufp_chk-doc.d-card       = buf_chk-doc.d-card
        bufp_chk-doc.src-d-card   = buf_chk-doc.src-d-card
        bufp_chk-doc.cli-type     = buf_chk-doc.cli-type
        bufp_chk-doc.src-cli-type = buf_chk-doc.src-cli-type
        bufp_chk-doc.cli-code     = buf_chk-doc.cli-code
        bufp_chk-doc.src-cli-code = buf_chk-doc.src-cli-code
        .
      end.
    end.
    else do:
      find first bufp_chk-doc where
                bufp_chk-doc.doc-code = v-new-doc-code
            and bufp_chk-doc.obj-type = v-proprietor-obj-type
            and bufp_chk-doc.obj-code = v-proprietor-obj-code no-error .
    end.
    create bufp_chk-gds .
    create temp-goods.
    create bufp_temp-goods.
    buffer-copy buf_chk-gds
    except doc-code out-code
    d-card src-d-card cli-type src-cli-type cli-code src-cli-code
    to bufp_chk-gds
    assign
    bufp_chk-gds.doc-code = v-new-doc-code
    bufp_chk-doc.netto    = bufp_chk-doc.netto + (bufp_chk-gds.price-base - bufp_chk-gds.discnt ) * bufp_chk-gds.doc-qnty
    temp-chk-doc.netto    = bufp_chk-doc.netto
    bufp_chk-doc.tot-doc  = bufp_chk-doc.tot-doc + bufp_chk-gds.price-base * bufp_chk-gds.doc-qnty
    bufp_chk-doc.discnt   = bufp_chk-doc.discnt + bufp_chk-gds.discnt * bufp_chk-gds.doc-qnty
    bufp_chk-doc.sub-discnt   = bufp_chk-doc.sub-discnt +  (if bufp_chk-gds.write-off-code <> 0
                                                        and bufp_chk-gds.write-off-code <> ?
                                                        then ((if bufp_chk-gds.write-off-code > 0 then 1 else - 1) *
                                                                bufp_chk-gds.src-qnty * (bufp_chk-gds.src-price - bufp_chk-gds.src-discnt)
                                                              )
                                                        else 0)
    temp-goods.line-num    = buf_chk-gds.line-num
    temp-goods.doc-code    = buf_chk-gds.doc-code
    temp-goods.object-sum  = buf_chk-gds.src-price * buf_chk-gds.src-qnty
    bufp_temp-goods.line-num    = buf_chk-gds.line-num
    bufp_temp-goods.doc-code    = bufp_chk-gds.doc-code
    bufp_temp-goods.object-sum  = bufp_chk-gds.src-price * bufp_chk-gds.src-qnty
    .
    if p-d-card-mode = 2
    or p-d-card-mode = 3
    then do:
      assign
      bufp_chk-gds.d-card       = buf_chk-gds.d-card
      bufp_chk-gds.src-d-card   = buf_chk-gds.src-d-card
      bufp_chk-gds.cli-type     = buf_chk-gds.cli-type
      bufp_chk-gds.src-cli-type = buf_chk-gds.src-cli-type
      bufp_chk-gds.cli-code     = buf_chk-gds.cli-code
      bufp_chk-gds.src-cli-code = buf_chk-gds.src-cli-code
      .
    end.
    if p-d-card-mode = 2 then do:
      assign
      buf_chk-gds.d-card       = '':U
      buf_chk-gds.src-d-card   = '':U
      buf_chk-gds.cli-type     = '':U
      buf_chk-gds.src-cli-type = '':U
      buf_chk-gds.cli-code     = 0
      buf_chk-gds.src-cli-code = 0
      .
    end.
    release bufP_chk-doc.
    release bufp_chk-gds.
    release temp-chk-doc.
    p-nf-gds-amount = p-nf-gds-amount + 1.
  end.
  for each buf_chk-pay where
              buf_chk-pay.doc-code = buf_chk-doc.doc-code,
    each temp-chk-doc where temp-chk-doc.orig-doc-code = buf_chk-doc.doc-code
  on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    :
    v-ratio = temp-chk-doc.netto / buf_chk-doc.netto.
    if v-ratio <> 0 then do:
      find first bufP_chk-pay where
                bufp_chk-pay.doc-code = temp-chk-doc.doc-code
          and  bufp_chk-pay.line-num = buf_chk-pay.line-num no-error.
      if not available bufp_chk-pay then do:
        create bufp_chk-pay.
        buffer-copy buf_chk-pay
        except doc-code obj-type obj-code tot-sum tot-rubl tot-base out-code
        to
        bufp_chk-pay
        assign
        bufp_chk-pay.doc-code = temp-chk-doc.doc-code
        bufp_chk-pay.obj-type = temp-chk-doc.obj-type
        bufp_chk-pay.obj-code = temp-chk-doc.obj-code
        bufp_chk-pay.tot-sum =  buf_chk-pay.tot-sum  * v-ratio
        bufp_chk-pay.tot-rubl =  buf_chk-pay.tot-rubl * v-ratio
        bufp_chk-pay.tot-base =  buf_chk-pay.tot-base  * v-ratio
        .
      end.
    end.
  end.
  for each bufp_chk-doc where
         bufp_chk-doc.doc-code begins (buf_chk-doc.doc-code + '>')
  on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign
    current-line-num = 0
    current-line-num-bonus = 0
    v-object-sum  = 0
    v-object-sump = 0
    v-ii = v-ii + 1
    .
    _buf_chk-discnt:
    for each buf_chk-discnt where
              buf_chk-discnt.doc-code = buf_chk-doc.doc-code
    by buf_chk-discnt.line-num
    by buf_chk-discnt.discnt-id
    by abs(buf_chk-discnt.object-line-num)
    by buf_chk-discnt.object-line-num
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    :
      CASE buf_chk-discnt.record-type:
        when 0 then do:
          for each temp-goods no-lock where
                  abs(temp-goods.line-num) > abs(current-line-num)
              and abs(temp-goods.line-num) <= abs(buf_chk-discnt.line-num):
            assign
            v-object-sum = v-object-sum + temp-goods.object-sum
            .
            if temp-goods.doc-code = bufp_chk-doc.doc-code
            then do:
              assign
              v-object-sump = v-object-sump + temp-goods.object-sum
              .
            end.
          end.
          assign
          v-ratio = v-object-sump / v-object-sum
          .
          assign
          current-line-num = buf_chk-discnt.line-num
          .
          if buf_chk-discnt.line-type = integer('1':U)
          and can-find(first temp-goods where
                              temp-goods.doc-code = bufp_chk-doc.doc-code
                          and temp-goods.line-num = buf_chk-discnt.object-line-num) then do:
            create bufp_chk-discnt.
            buffer-copy buf_chk-discnt except doc-code out-code to bufp_chk-discnt
            assign
            bufp_chk-discnt.doc-code = bufp_chk-doc.doc-code
            .
          end.
          else do:
            create bufp_chk-discnt.
            buffer-copy buf_chk-discnt except doc-code out-code to bufp_chk-discnt
            assign
            bufp_chk-discnt.doc-code = bufp_chk-doc.doc-code
            .
            CASE buf_chk-discnt.line-type:
              when integer('2':U)
              or
              when integer('3':U) then do:
                assign
                bufp_chk-discnt.object-sum = v-ratio * buf_chk-discnt.object-sum
                bufp_chk-discnt.discnt-value-abs = v-ratio * buf_chk-discnt.discnt-value-abs
                bufp_chk-discnt.discnt-value-pcnt =  if bufp_chk-discnt.object-sum <> 0
                                                    then bufp_chk-discnt.discnt-value-abs / bufp_chk-discnt.object-sum * 100
                                                    else 0
                .
              end.
              when integer('4':U)
              or
              when integer('5':U) then do:
                assign
                bufp_chk-discnt.discnt-value-abs = buf_chk-discnt.discnt-value-abs * bufp_chk-doc.netto / buf_chk-doc.netto
                bufp_chk-discnt.object-sum       = buf_chk-discnt.discnt-value-abs * bufp_chk-doc.netto / buf_chk-doc.netto
                bufp_chk-discnt.discnt-value-pcnt =  if bufp_chk-discnt.object-sum <> 0
                                                      then bufp_chk-discnt.discnt-value-abs / bufp_chk-discnt.object-sum * 100
                                                      else 0
                .
              end.
            END CASE.
          end.
        end.
        when 1
        or
        when 2
        then do:
          if can-find(first temp-goods where
                            temp-goods.doc-code = bufp_chk-doc.doc-code
                        and temp-goods.line-num = buf_chk-discnt.object-line-num) then do:
            create bufp_chk-discnt.
            buffer-copy buf_chk-discnt except doc-code out-code to bufp_chk-discnt
            assign
            bufp_chk-discnt.doc-code = bufp_chk-doc.doc-code
            .
          end.
        end.
        when 4 then do:
          for each temp-goods no-lock where
                  abs(temp-goods.line-num) > abs(current-line-num-bonus)
              and abs(temp-goods.line-num) <= abs(buf_chk-discnt.line-num):
            assign
            v-object-sum-bonus = v-object-sum-bonus + temp-goods.object-sum
            .
            if temp-goods.doc-code = bufp_chk-doc.doc-code
            then do:
              assign
              v-object-sump-bonus = v-object-sump-bonus + temp-goods.object-sum
              .
            end.
          end.
          assign
          v-ratio-bonus = v-object-sump-bonus / v-object-sum-bonus
          .
          assign
          current-line-num-bonus = buf_chk-discnt.line-num
          .
          if buf_chk-discnt.line-type = integer('1':U)
          and can-find(first temp-goods where
                              temp-goods.doc-code = bufp_chk-doc.doc-code
                          and temp-goods.line-num = buf_chk-discnt.object-line-num) then do:
            create bufp_chk-discnt.
            buffer-copy buf_chk-discnt except doc-code out-code to bufp_chk-discnt
            assign
            bufp_chk-discnt.doc-code = bufp_chk-doc.doc-code
            .
          end.
          else do:
            create bufp_chk-discnt.
            buffer-copy buf_chk-discnt except doc-code out-code to bufp_chk-discnt
            assign
            bufp_chk-discnt.doc-code = bufp_chk-doc.doc-code
            .
            CASE buf_chk-discnt.line-type:
              when integer('2':U)
              or
              when integer('3':U) then do:
                assign
                bufp_chk-discnt.object-sum = v-ratio-bonus * buf_chk-discnt.object-sum
                bufp_chk-discnt.discnt-value-abs = v-ratio-bonus * buf_chk-discnt.discnt-value-abs
                bufp_chk-discnt.discnt-value-pcnt =  if bufp_chk-discnt.object-sum <> 0
                                                    then bufp_chk-discnt.discnt-value-abs / bufp_chk-discnt.object-sum * 100
                                                    else 0
                .
              end.
              when integer('4':U)
              or
              when integer('5':U) then do:
                assign
                bufp_chk-discnt.discnt-value-abs = buf_chk-discnt.discnt-value-abs * bufp_chk-doc.netto / buf_chk-doc.netto
                bufp_chk-discnt.object-sum       = buf_chk-discnt.discnt-value-abs * bufp_chk-doc.netto / buf_chk-doc.netto
                bufp_chk-discnt.discnt-value-pcnt =  if bufp_chk-discnt.object-sum <> 0
                                                      then bufp_chk-discnt.discnt-value-abs / bufp_chk-discnt.object-sum * 100
                                                      else 0
                .
              end.
            END CASE.
          end.
        end.
        when 5  then do:
          if can-find(first temp-goods where
                            temp-goods.doc-code = bufp_chk-doc.doc-code
                        and temp-goods.line-num = buf_chk-discnt.object-line-num) then do:
            create bufp_chk-discnt.
            buffer-copy buf_chk-discnt except doc-code out-code to bufp_chk-discnt
            assign
            bufp_chk-discnt.doc-code = bufp_chk-doc.doc-code
            .
          end.
        end.
      END CASE.
      if available bufp_chk-discnt then do:
        if p-d-card-mode = 2
        or p-d-card-mode = 3
        then do:
          assign
          bufp_chk-discnt.d-card       = buf_chk-discnt.d-card
          bufp_chk-discnt.src-d-card   = buf_chk-discnt.src-d-card
          .
        end.
        if p-d-card-mode = 2
        and v-ii = v-num-docs
        then do:
          assign
          buf_chk-discnt.d-card       = '':U
          buf_chk-discnt.src-d-card   = '':U
          .
        end.
      end.
    end.
  end.
  if p-d-card-mode = 2 then do:
    assign
    buf_chk-doc.d-card       = '':U
    buf_chk-doc.src-d-card   = '':U
    buf_chk-doc.cli-type     = '':U
    buf_chk-doc.src-cli-type = '':U
    buf_chk-doc.cli-code     = 0
    buf_chk-doc.src-cli-code = 0
    .
  end.
  assign
  buf_chk-doc.chk-type = (if buf_chk-doc.chk-type > 0 and buf_chk-doc.chk-type < 100
                         then (buf_chk-doc.chk-type + 100)
                         else buf_chk-doc.chk-type)
  .
  return ''.
end.
end procedure.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info24, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info24, return-value, chr(10), error-status :get-message (1)).
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
def var vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info27 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
function IS-NeedMark returns logical
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
function repTegforDm return char
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo.
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
function repSpecSimbforDm return char
(iDM as char ):
    define variable oDM as character no-undo.
  run
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
function CheckGtin return logical
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else
      vGtin = no.
   return vgtin.
end.
function repSpecSimbforXlm return char
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
function getGtinByDM return char
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7
      then
         vGtin = substring(vtxt,1,14).
   end.
   if not checkGtin(vGtin)
   then
      vGtin = "".
   return vgtin.
end.
function getGdsCodeByGtin return int
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
function getQntyCodeByGtin return decimal
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
function getGdsCodeByDM return int
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
function ChekTypeMarkByGds return logical
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code
                           and goods-attr.attr-code  = 'mark-type':U
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp
        .
   end.
   else
      return no.
end.
function ChekTypeMarkByDm return logical
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
function ChekTypeMarkByGtin return logical
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
function GetNextElement return character
  (input iAllTeg        as logical
  ,output oteg          as character
  ,output otegval       as character
  ,input-output pstr    as character
   ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)".
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006".
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)".
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code.
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
     if iAllTeg
     then
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.
function GetCodeIdent return character
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   for first marking no-lock where
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     return iDm.
   end.
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins 'tech_':U
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else
         oCodeIdent = iDM.
   end.
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.
end.
function GetTegCod return character
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21"
      then
         oTeg = substring(icodeIdent,15,7).
   end.
   else do:
      ChekTypeMarkByDm(icodeIdent).
      block-teg:
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")"
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.
end.
function isOAD return logical
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
function isMark return logical
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
function addBracketForCode return character
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define buffer marking for ub.marking.
   find first marking no-lock where
              marking.mark begins icodeIdent no-error.
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.
   else do:
      if (  icodeIdent begins "01"
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14))
         and substring (icodeIdent,17,2) eq "21"
      then do:
         mMRCCode = yes.
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.
   return oTeg.
end.
function getlevelByCodId return int
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then
      Vlevel = 4.
   else if vLength eq 21
   then
      Vlevel = 1.
   else if vLength eq 25
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11"
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.
   else
      Vlevel = ?.
   return Vlevel.
end.
function getLevelMotpBycodid return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByLevelMotp return character
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.
function getLevelMotpByDM return character
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
function getLevelUTDByCodId return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByDM return character
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
function getQntyUTDByCodId return decimal
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.
function getQntyUTDByDM return decimal
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25
      and length (iDm) ne 29
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.
function getMRC4 return decimal
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.
function getMRCByDM return decimal
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.
function MoveDate return Date
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.
end.
procedure checkEMRC:
define input  parameter iDm as character no-undo.
define output parameter vok as logical   no-undo init yes.
   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code.
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).
            if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
         (
          input   vgds-code
         ,input   'emrc-type':U
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + chr(4) + v-value-emrc.
          find last code where Code.parent      eq vparent
                           and Code.code        le vDateIso
                           and code.status_  eq 0
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq 0 no-lock no-error.
              if available code
              then
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq 0
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq 0
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  chr(10),
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  chr(10),
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
          end.
       end.
   end.
end.
function addGs2Mark return character
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
   if index(iMark,chr(29),1) > 0
   then return iMark.
   if substring(iMark,26,4) = "8005" then
   do:
     vIdx = index(iMark,"93",26 + 4 + 5).
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.
     end.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "91" then
   do:
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
   return if vDM <> "" then vDm else iMark.
end.
define variable v-obj-type like ub.inkas.obj-type no-undo .
define variable v-obj-code like ub.inkas.obj-code no-undo .
define variable cre-pay   like ub.cash-pay.cdpay-code no-undo.
define variable v-doc-date as date no-undo .
define variable v-db-num  like ub.db.db-num no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable l-shift-on as logical no-undo .
DEFINE VARIABLE sys-today as date no-undo .
define variable v-back-date as logical no-undo .
define variable force-auto-fbr as logical no-undo .
define variable force-tpsi-obj as logical no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo.
define variable v-notes as character no-undo .
define variable case-num as integer no-undo .
define variable v-fbr-income-doc-code like ub.trn-doc.doc-code no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable glog     as logical no-undo .
define variable b-close-enabled as logical no-undo initial no.
define variable BadTrans as logical no-undo .
define variable rdoc-line as recid.
define variable r-or-v as character no-undo.
define variable r-office as character no-undo .
define variable from-menu as logical initial no.
define variable num_resv as integer no-undo.
define variable num_resv_res as integer no-undo.
define variable not-all-saled-chk as logical initial no .
define variable not-all-normal-chk as logical initial no .
define variable not-all-inkas-closed as logical no-undo initial no .
define variable note-compense as character no-undo.
define variable compensed     as logical no-undo .
define variable v-is-ptrl as logical no-undo .
define variable log-file-name as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-close-day-period AS LOGICAL no-undo .
define variable v-log-handle as handle no-undo .
define variable v-vid-action      as integer   no-undo .
define variable v-vid-param       as longchar  no-undo .
define variable varoldstatus      like ub.trn-doc.status_ no-undo .
define variable varoldflag        like ub.trn-doc.flag_ no-undo .
define variable varobj-shift-date as date      no-undo .
define variable varobj-shift-num  as integer   no-undo .
define variable varobj-shift-name as character no-undo .
define variable v-mess            as character no-undo .
define variable v-gas-income-created as character no-undo .
define variable v-gas-compensed as logical no-undo .
define variable v-gas-cli-type as character no-undo .
define variable v-gas-cli-code as integer no-undo .
define variable v-new_doc-code as character no-undo .
define variable v-root-node as integer no-undo .
define variable v-initiator  as character no-undo.
case true:
  when g#auto then v-initiator = "Auto".
  when g#news then v-initiator = "Nws".
  when g#esys then v-initiator = "Esys".
  otherwise v-initiator = "User".
end case.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_inkas for ub.inkas.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_ret-doc for ub.trn-doc.
define buffer buf_spis-doc for ub.trn-doc.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer locked_inkas for ub.inkas.
define buffer locked_trn-doc for ub.trn-doc.
define buffer buf_prt-obj for ub.prt-obj.
define buffer bf_clients for ub.clients.
define buffer buf-new_trn-doc for ub.trn-doc.
if num-entries(p-parameter, chr(4)) <> 18
then do:
  assign
  v-input-error = yes
  v-esm         = substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 18"
                             , num-entries(p-parameter, chr(4))).
  .
end.
else do:
  assign
  v-curr-r-b          = entry(1, p-parameter, chr(4))
  p-inkas-code        = entry(2, p-parameter, chr(4))
  p-auto              = integer(entry(3, p-parameter, chr(4)))
  auto-close          = logical(entry(4, p-parameter, chr(4)))
  b-mail-pressed      = logical(entry(5, p-parameter, chr(4)))
  auto-comp           = logical(entry(6, p-parameter, chr(4)))
  auto-fbr            = logical(entry(7, p-parameter, chr(4)))
  one-curs            = logical(entry(8, p-parameter, chr(4)))
  p-is-catering       = logical(entry(9, p-parameter, chr(4)))
  p-is-tpsi-obj       = logical(entry(10, p-parameter, chr(4)))
  rest-dish           = logical(entry(11, p-parameter, chr(4)))
  rest-ingr           = logical(entry(12, p-parameter, chr(4)))
  rest-tpsi           = logical(entry(13, p-parameter, chr(4)))
  neg-tpsi-weight     = logical(entry(14, p-parameter, chr(4)))
  neg-tpsi-qnty       = decimal(entry(15, p-parameter, chr(4)))
  neg-tpsi-oper       = logical(entry(16, p-parameter, chr(4)))
  close-in-rfsl       = integer(entry(17, p-parameter, chr(4)))
  pay-gds-algo        = entry(18, p-parameter, chr(4))
  no-error .
  if error-status:error then do:
    assign
    v-esm = error-status:get-message(1)
    v-input-error = yes
    .
  end.
end.
if p-auto = 0 then do:
  log-file-name = 'saleclos.log' .
end.
else do:
  log-file-name = 'ext-sale.log'.
end.
for each chk-doc no-lock where chk-doc.out-code = p-inkas-code :
  if lookup(string(chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next .
  find first chk-gds no-lock where chk-gds.doc-code = chk-doc.doc-code no-error.
  if not available chk-gds
  then do :
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("В чеке &1 нет строк!&2&3&4"
                           , chk-doc.doc-code
                           , chr(10)
                           , v-esm
                           , return-value
                           )).
    assign
    v-view-log = yes.
    if p-auto = 0 then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе закрытия продажи произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action29   as character no-undo .
  define variable v-printed29       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе закрытия продажи произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'saleclos.log')
    ,input  7
    ,output v-user-action29
    ,output v-printed29
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
  OS-DELETE value(string("./":U) + 'saleclos.log').
end.
                        return "error":U.                  end.
  end.
end.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "Проверка товаров продажи на присутствие в незакрытой инвентаризации..."                                       ).
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
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
          run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Артикул :&1 &2- товар в инвентаризации.&3&3" +                   (if p-auto = 0 then "Резервирование и/или закрытие отчета невозможно" else "":U)                                   ,buf_doc-line.artic                                                            ,buf_goods.gds-name                                                            , chr(10))                                       ).
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
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "Сравнение сумм по товарам и выручке......"                                       ).
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
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "Проверка возможности появления недопустимых отрицательных остатков..."                                       ).
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
      undo, return error substitute("&1 Были ошибки при проверке документов на возможность резервирования:&2&3&2&4"
                              , vss-description
                              , chr(10)
                              , error-status:get-message(1)
                              , return-value).
  end.
  BadTrans = FALSE .
  FIND FIRST locked_inkas WHERE recid( locked_inkas ) = recid( buf_Inkas ) .
  FIND FIRST locked_trn-doc WHERE
            locked_trn-doc.doc-code = buf_inkas.inkas-code .
  assign
  locked_inkas.is-auto-rsrv = (p-auto >= 2)
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
      undo, return error substitute("&1 Были ошибки при резервировании:&2&3 &4"
                              , vss-description
                              , chr(10)
                              , error-status:get-message(1)
                              , return-value).
  end.
  IF num_resv = 0  then do:
    if NOT auto-close
    and not p-auto-fbr
    then do:
        undo, return substitute("&1 Не найдено товара для резервирования." , vss-description).
    end.
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
if not p-from-compense then
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
    undo, return error substitute("&1 Были ошибки при проверке документов на возможность разрезервирования:&2&3&2&4"
                            , vss-description
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value).
end.
BadTrans = FALSE .
FIND FIRST locked_inkas WHERE recid( locked_inkas ) = recid( buf_Inkas ) .
FIND FIRST locked_trn-doc WHERE
           locked_trn-doc.doc-code = buf_inkas.inkas-code .
RUN UNRESERV in this-procedure (input p-is-tpsi-obj
                              , buffer locked_inkas
                              ) no-error .
IF error-status:error  then do:
    undo, return error substitute("&1 Были ошибки при снятии резервов:&2&3 &4"
                            , vss-description
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value).
end.
IF num_resv = 0
and not p-from-compense
then do:
    undo, return error substitute("&1 Не найдено товара для снятия резервов." , vss-description).
end.
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
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Резервирование товаров. &1", entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ))                                       ).
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
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "Ждите... Идет резервирование ЧУЖИХ товаров."                                       ).
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
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "Резервирование прошло успешно"                                       ).
  end.
end.
else do:
  if auto-fbr then do:
  end.
  if  num_resv > 0 then do:
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Из &1 позиций, подлежащих резервированию, успешно зарезервировано &2 (не зарезервировано &3)"                         , num_resv                                                                                      , num_resv_res                         , num_resv - num_resv_res)                                       ).
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
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "Проверка отсутствия зарезервированного товара..."                                       ).
end.
else do:
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "Проверка количества зарезервированного товара..."                                       ).
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
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   rsrv-option =  (if (rgds-dtl = ?) and not p-auto-fbr
                  then 'reserv':U  + ',' + 'no-msg-no-chk-acta-cr':U
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
    rsrv-option =  'reserv':U  + ',' + 'no-msg-no-chk-acta-cr':U + ',' + 'negative-check':U + v-nc-option
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
    rsrv-option = rsrv-option  + ',' + 'no-msg-no-chk-acta-cr':U
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
run write-counter in p-log-handle (input substitute("&1 - обработано &2, из них успешно - &3"                                                         , rsrv-title                                                                 , num_rec                                                                    , num_rec_res)).
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
   rsrv-option  = rsrv-option  + ',' + 'no-msg-no-chk-acta-cr':U
                               + ',' + 'negative-check':U + "=1"
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
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input v-err-msg                                       ).
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
if not is-gas(gdscode)
then do :
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input v-err-msg                                       ).
end.
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
if pl-chg-qnty <> new-pl-qnty - old-pl-qnty then do:
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input return-value                                       ).
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
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
run write-counter in p-log-handle (input substitute("&1 - обработано &2, из них успешно - &3"                                                         , rsrv-title                                                                 , num_rec                                                                    , num_rec_res)).
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
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input return-value                                       ).
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
if ser-chg-qnty <> res-parts then do:
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input return-value                                       ).
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
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
run write-counter in p-log-handle (input substitute("&1 - обработано &2, из них успешно - &3"                                                         , rsrv-title                                                                 , num_rec                                                                    , num_rec_res)).
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
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input return-value                                       ).
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
if chg-qnty <> res-qnty and not available buf_doc-fbr-gds then do:
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input return-value                                       ).
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
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Снятие резервов. &1.", entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ))                                       ).
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
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  buf_inkas.shift-date
  ,input  buf_inkas.host-code
  ,input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output vat-value
  ) no-error .
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
          run hide-counter in p-log-handle.
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
    run hide-counter in p-log-handle.
    if p-is-tpsi-obj
    and v-run-tpsi
    then do:
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "Ждите... Идет снятие резервов ЧУЖИХ товаров"                                       ).
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
        run hide-counter in p-log-handle.
        if rdoc-line <> ? then do:
        return error substitute("Ошибка при снятии резервов ЧУЖИХ товаров:&1&2 &3"
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value ).
        end.
      end.
      run hide-counter in p-log-handle.
    end.
  end.
  assign
  num_resv = num_resv + num_rec
  num_resv_res = num_resv_res + num_rec_res
  num_rec = 0
  num_rec_res = 0
  .
  run hide-counter in p-log-handle.
  release buf_trn-doc.
end.
if num_resv = 0 then.
else do:
  if num_resv_res = num_resv and  num_resv > 0 and r-qnty = ? then do:
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "Снятие резервов прошло успешно"                                       ).
  end.
  else do:
    if r-qnty = ? then do:
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Из &1 позиций для снятия резервов,&2" +                         "успешно сняты резервы с &3"                                         , num_resv                                                           , chr(10)                                                        , num_resv_res)                                       ).
    end.
  end.
end.
END PROCEDURE.
if v-input-error = yes then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , v-esm
                         , return-value
                         )).
  assign
  v-view-log = yes.
  if p-auto = 0 then do:
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе закрытия продажи произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action45   as character no-undo .
  define variable v-printed45       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе закрытия продажи произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'saleclos.log')
    ,input  7
    ,output v-user-action45
    ,output v-printed45
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
  OS-DELETE value(string("./":U) + 'saleclos.log').
end.
                        return "error":U.                  end.
end.
run proc-main in this-procedure no-error .
if error-status:error then do:
  v-mess = substitute("Ошибка при закрытии продажи &1 &2&3:&4&5 &6"
                         , p-inkas-code
                         , (if v-obj-type <> "":U then v-obj-type else "":U)
                         , (if v-obj-code <> 0 then string(v-obj-code) else "":U)
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         ).
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input v-mess).
  assign
  v-view-log = yes.
  if p-auto = 0 then do:
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе закрытия продажи произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action47   as character no-undo .
  define variable v-printed47       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе закрытия продажи произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'saleclos.log')
    ,input  7
    ,output v-user-action47
    ,output v-printed47
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
  OS-DELETE value(string("./":U) + 'saleclos.log').
end.
                        return "error":U.                  end.
  for each dtl-rests:
    delete dtl-rests.
  end.
  run fbrhist-table-to-base in this-procedure no-error.
  if error-status:error
  then do:
    v-mess = substitute("Ошибка при закрытии продажи &1:&2Ошибка записи истории производства в базу данных.&2&3 &4"
                          , p-inkas-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value
                          ).
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input v-mess).
    assign
    v-view-log = yes.
    if p-auto = 0 then do:
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе закрытия продажи произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action49   as character no-undo .
  define variable v-printed49       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе закрытия продажи произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'saleclos.log')
    ,input  7
    ,output v-user-action49
    ,output v-printed49
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
  OS-DELETE value(string("./":U) + 'saleclos.log').
end.
                        return "error":U.                  end.
  end.
  if v-view-log
  and p-auto = 0
  then do:
    message
    "!!!При закрытии продажи произошли ошибки!!!" skip
    "!!!Внимательно прочитайте Log-file!!"
    view-as alert-box error .
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical   no-undo .
    run gbl/prnfilen.w
      (input  "Ошибки, возникшие при закрытии продажи"
      ,input  0
      ,input  "./saleclos.log":U
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
  end.
  find first buf_inkas no-lock where
                buf_inkas.inkas-code = p-inkas-code no-error.
  find first buf_trn-doc no-lock where
    buf_trn-doc.doc-code = p-inkas-code no-error.
  find last ub.c-inkas no-lock where ub.c-inkas.inkas-code = buf_inkas.inkas-code and ub.c-inkas.corr-user-db-num = v-db-num no-error.
  if available (buf_inkas) and available (ub.c-inkas )
  then do:
    find first bf_clients no-lock where bf_clients.obj-type = 'чел':U and  bf_clients.obj-code = buf_trn-doc.boss no-error.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output varobj-shift-date
  ,output varobj-shift-num
  ,output varobj-shift-name
  ) no-error .
    v-vid-action = 57 .
    v-vid-param = "Initiator=" + v-initiator + chr(4) +
                  "ResponsiblePerson=" + (if available (bf_clients) then bf_clients.obj-name else "") + chr(4) +
                  "SHOP_NUM=" + string(buf_inkas.obj-code) + chr(4) +
                  "Contractor=" + buf_trn-doc.cli-name + chr(4) +
                  "DocNum=" + string(buf_inkas.inkas-code) + chr(4) +
                  "FactDate=" + (if string(buf_inkas.fact-date) = ? then '' else string(buf_inkas.fact-date)) + chr(4) +
                  "DocType=" + "Продажа" + chr(4) +
                  "SHIFT_NUM_DOC=" + (if string(buf_inkas.shift-num) = ? then '' else string(buf_inkas.shift-num)) + (if string(buf_inkas.shift-date) = ? then '' else string(buf_inkas.shift-date, "99999999")) + chr(4) +
                  "SHIFT_NUM=" + (if string(varobj-shift-num) = ? then '' else string(varobj-shift-num)) + (if string(varobj-shift-date) = ? then '' else string(varobj-shift-date, "99999999")) + chr(4) +
                  "Status=" + string(buf_inkas.status_) + chr(4) +
                  "RESULT=1" + chr(4) +
                  "Description=" + v-mess no-error.
    run trg/userlog.p (
          input 'update':U
        , input 'c-inkas':U
        , input ( buffer ub.c-inkas:handle )
        , input v-vid-action
        , input v-vid-param
    ) no-error.
  end.
end.
else do:
  find first buf_inkas no-lock where
                buf_inkas.inkas-code = p-inkas-code no-error.
  find first buf_trn-doc no-lock where
    buf_trn-doc.doc-code = p-inkas-code no-error.
  find last ub.c-inkas no-lock where ub.c-inkas.inkas-code = buf_inkas.inkas-code and ub.c-inkas.corr-user-db-num = v-db-num no-error.
  if available (buf_inkas) and available (ub.c-inkas )
  then do:
    find first bf_clients no-lock where bf_clients.obj-type = 'чел':U and  bf_clients.obj-code = buf_trn-doc.boss no-error.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output varobj-shift-date
  ,output varobj-shift-num
  ,output varobj-shift-name
  ) no-error .
    v-vid-action = 57 .
    v-vid-param = "Initiator=" + v-initiator + chr(4) +
                  "ResponsiblePerson=" + (if available (bf_clients) then bf_clients.obj-name else "") + chr(4) +
                  "SHOP_NUM=" + string(buf_inkas.obj-code) + chr(4) +
                  "Contractor=" + buf_trn-doc.cli-name + chr(4) +
                  "DocNum=" + string(buf_inkas.inkas-code) + chr(4) +
                  "FactDate=" + (if string(buf_inkas.fact-date) = ? then '' else string(buf_inkas.fact-date)) + chr(4) +
                  "DocType=" + "Продажа" + chr(4) +
                  "SHIFT_NUM_DOC=" + (if string(buf_inkas.shift-num) = ? then '' else string(buf_inkas.shift-num)) + (if string(buf_inkas.shift-date) = ? then '' else string(buf_inkas.shift-date, "99999999")) + chr(4) +
                  "SHIFT_NUM=" + (if string(varobj-shift-num) = ? then '' else string(varobj-shift-num)) + (if string(varobj-shift-date) = ? then '' else string(varobj-shift-date, "99999999")) + chr(4) +
                  "StatusOld=" + varoldstatus + (if varoldflag then "+" else "-" ) + chr(4) +
                  "StatusNew=" + string(buf_inkas.status_) + chr(4) +
                  "RESULT=0" + chr(4) +
                  "Description=" no-error.
    run trg/userlog.p (
          input 'update':U
        , input 'c-inkas':U
        , input ( buffer ub.c-inkas:handle )
        , input v-vid-action
        , input v-vid-param
    ) no-error.
  end.
end.
procedure proc-main :
define variable v-prichina as character no-undo .
define variable my-mes     as character no-undo .
define variable v-is-neg-rests as logical no-undo .
define variable v-is-inquiry as logical no-undo .
define variable v-shift-date as date no-undo .
define variable v-shift-num as integer no-undo .
define variable v-shift-name as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-found as decimal no-undo.
define variable v-tth as handle no-undo .
define variable v-entry as character no-undo.
define variable v-run-tpsi-line as logical no-undo.
define variable v-old-shift-obj as handle no-undo  .
define variable v-new-shift-obj as handle no-undo  .
define buffer buf_shift-obj for ub.shift-obj.
define buffer tpsi_sale-doc for ub.sale-doc.
define buffer buf_goods for ub.goods.
define buffer buf_doc-line for ub.doc-line.
define buffer spis_doc-line for ub.doc-line.
define buffer buf_sale-doc for ub.sale-doc.
define buffer spis_sale-doc for ub.sale-doc.
define buffer bf_doc-fbr-gds for ub.doc-fbr-gds .
define buffer out-dtl   for ub.gds-dtl.
define buffer ret-dtl   for ub.gds-dtl.
do
on error undo, return error return-value
:
  find first buf_inkas exclusive-lock
       where buf_inkas.inkas-code = p-inkas-code no-error no-wait.
  if locked buf_inkas then do:
    if p-auto < 2 then return error substitute("Отчет о продаже №&1 занят", p-inkas-code).
                  else return "":U.
  end.
  if NOT available buf_inkas then do:
    return error substitute("Не найден отчет о продаже №&1", p-inkas-code).
  end.
  if p-auto = 2 and buf_inkas.status_ <> 'нередакт':U then do:
    return "":U.
  end.
  if p-auto < 2 then do:
    if not (buf_inkas.status_ = 'новый':U or buf_inkas.status_ = 'нередакт':U) then do:
      return error substitute("Отчет о продаже №&1 имеет статус &2", buf_inkas.inkas-code, buf_inkas.status_).
    end.
define variable vss-include-info52 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
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
    if NOT glog then return error.
  end.
  if NOT can-find (first ub.chk-doc where ub.chk-doc.out-code = buf_inkas.inkas-code) then do:
    return error substitute("Отчет о продаже N&1 пуст. Закрытие невозможно.", buf_inkas.inkas-code).
  end.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  'маг':U
  ,input  buf_inkas.obj-code
  ,output v-db-num
  )  .
  if v-db-num <> g#db-num then do:
    return error substitute("Отчет о продаже №&1 относится к магазину БД &2, текущая БД &3"
                            , buf_inkas.inkas-code
                            , v-db-num
                            , g#db-num
                            ).
  end.
  assign
    varoldstatus = buf_inkas.status_
    varoldflag   = buf_inkas.flag_
    v-obj-type = buf_inkas.obj-type
    v-obj-code = buf_inkas.obj-code
  .
  FIND FIRST buf_trn-doc WHERE
            buf_trn-doc.doc-code = buf_inkas.inkas-code NO-LOCK.
  FIND FIRST buf_ret-doc WHERE
            buf_ret-doc.doc-code = buf_trn-doc.out-code NO-LOCK no-error.
   v-is-inquiry = buf_trn-doc.status_ = 'запрос':U.
  find first buf_sysconf where
           buf_sysconf.host-code = buf_inkas.host-code no-lock.
  if not available buf_sysconf then do:
    return error substitute("Не найдена запись о фирме &1", buf_inkas.host-code).
  end.
  assign
  v-host-code = buf_inkas.host-code.
  find first buf_Cash-pay no-lock where
            buf_cash-pay.cdpay-code = buf_sysconf.credit-pay no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'iscredit'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
  if error-status:error
  or not available buf_cash-pay
  or buf_cash-pay.is-credit = no
  or conf-par <> "yes"
  then do:
      assign
      cre-pay = 0
      .
  end.
  else do:
    assign
    cre-pay = buf_sysconf.credit-pay
    .
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ptrl'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
  if not error-status :error
  and par-type = 'L':U then do:
     assign
     v-is-ptrl = logical(conf-par)
     no-error
     .
  end.
  run fbrhist-read-conf in this-procedure .
  if p-auto < 2 then do:
    if NOT auto-close then do:
      if p-auto = 0 and NOT b-mail-pressed  then do:
        glog = no.
        message
        "В течение данного сеанса работы с продажей вы не докачивали новые чеки!" skip
        "Вы уверены, что хотите закрыть продажу?"
        view-as alert-box WARNING  buttons YES-NO update glog.
        if not glog then return error.
      end.
    end.
    if NOT auto-close
    or p-auto = 1 then do:
      run str/chk-inf.p (
                 input parparentproc
                ,input buf_inkas.host-code
                ,input buf_inkas.obj-type
                ,input buf_inkas.obj-code
                ,input no
                ,input yes
                ,input recid(buf_inkas)
                ,output v-notes
                ,output not-all-saled-chk
                ,output not-all-normal-chk
                ,output not-all-inkas-closed
                 ).
      run gbl/d-askw.w
      (input substitute("Закрытие отчета о продаже&1",
                        ( if g#db-num > 0 then " и отправка его в офис" else "" )
                      )
      ,input v-notes
      ,input "|^"
      ,input "Закрыть|Не закрывать"
      ,input "Закрытый отчет нельзя исправить|"
          +  "Проверить документ еще раз"
      ,input 1
      ,input 2
      ,output case-num
      ).
      if case-num = 2 then do:
        return error.
      end.
    end.
  end.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
  if not l-shift-on then do:
    run adm/shattri.p (
        input "get":U
        ,input buf_inkas.obj-type
        ,input buf_inkas.obj-code
        ,input  'autosale':U
        ,input  'close-day-period':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-close-day-period
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    delete object v-tth no-error.
  end.
  if v-close-day-period then do:
    define variable v-continue as logical no-undo .
    run str/salechpe.p ( input parparentproc
                        ,input p-log-handle
                        ,input p-auto
                        ,input buf_inkas.inkas-code
                        ,output v-continue
                        ) no-error.
    if not v-continue then do:
      return error ''.
    end.
  end.
  glog = no.
  RUN Inv-chk in this-procedure  (
                input buf_inkas.inkas-code
              , input v-curr-r-b
              , buffer buf_inkas
              , buffer buf_trn-doc
              , input ?
              , input ?
              , input ? ) no-error .
  IF error-status:error  then undo, return error return-value .
  run fbrhist-init in this-procedure.
  assign
  BadTrans = no
  compensed = no
  .
  if p-auto <> 0 then do:
    if can-find(first tpsi_sale-doc where
                     tpsi_sale-doc.inkas-code = buf_inkas.inkas-code
                 and tpsi_sale-doc.tpsidoc = yes )
    then p-is-tpsi-obj = yes.
    if p-is-tpsi-obj then do:
      run tpsi-gds-fill-tpsi-obj-table in this-procedure (input v-db-num) no-error .
      if error-status:error then do:
      undo, return error
        substitute("Ошибки при заполнении врем. таблицы объектов-членов ТПСИ на БД &1:&2&3 &4"
                  , v-db-num
                  , chr(10)
                  , error-status:get-message(1)
                  , return-value ).
      end.
    end.
    if (p-is-tpsi-obj)
    and not v-is-inquiry
    then do:
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "Ждите.. получение информации по резервированию ЧУЖИХ товаров"                                       ).
      run fill-tt-tpsi-table  in this-procedure (
                                                    buf_inkas.inkas-code
                                                  , buf_Inkas.host-code
                                                  , buf_inkas.obj-type
                                                  , buf_Inkas.obj-code).
      run waitfram-hide in this-procedure .
    end.
  end.
  f-close:
  DO  on ERROR undo, return error return-value
      on STOP undo, return error return-value :
    if auto-fbr
    then do :
      doc-fbr-gds_ :
      for each bf_doc-fbr-gds no-lock where bf_doc-fbr-gds.out-code = p-inkas-code,
        first buf_goods no-lock where buf_goods.gds-code = bf_doc-fbr-gds.gds-code,
        first out-dtl no-lock where out-dtl.doc-code  = bf_doc-fbr-gds.out-code
                                and out-dtl.artic     = buf_goods.artic
                                and out-dtl.prod-type = buf_goods.prod-type
                                and out-dtl.prod-code = buf_goods.prod-code
      :
        if out-dtl.doc-qnty <> out-dtl.fact-qnty
        then do :
          find first ret-dtl no-lock where ret-dtl.doc-code  = replace(out-dtl.doc-code, "-", "=")
                                       and ret-dtl.artic     = out-dtl.artic
                                       and ret-dtl.prod-type = out-dtl.prod-type
                                       and ret-dtl.prod-code = out-dtl.prod-code
                                       and ret-dtl.prt-code  = out-dtl.prt-code
                                       no-error .
          if available ret-dtl
          and ret-dtl.fact-qnty > 0
          and ret-dtl.fact-qnty = ret-dtl.doc-qnty
          then do :
            find first buf_doc-line no-lock where buf_doc-line.doc-code   = ret-dtl.doc-code
                                              and buf_doc-line.artic      = ret-dtl.artic
                                              and buf_doc-line.prod-type  = ret-dtl.prod-type
                                              and buf_doc-line.prod-code  = ret-dtl.prod-code
                                              no-error .
            if available buf_doc-line
            then do :
              assign
                rdoc-line = recid (buf_doc-line)
                rgds-dtl = recid(ret-dtl)
                r-qnty =  - ret-dtl.fact-qnty
                r-b-code = ?
                r-or-v = 'rs':U
                r-office = 'т':U
                from-menu = yes
              .
              run b-unres-proc in this-procedure (
                                    buffer buf_inkas
                                  , buffer buf_trn-doc
                                  , buffer buf_ret-doc
                                  , input p-is-tpsi-obj
                                  , input yes) no-error.
              if error-status:error then do:
                undo doc-fbr-gds_, return error.
              end.
            end .
          end .
        end .
      end .
    end .
    if auto-comp
    and not v-is-inquiry
    and can-find(first ub.sale-doc where
                      ub.sale-doc.inkas-code = p-inkas-code
                   and ub.sale-doc.doc-kind = 'rs':U
                   and ub.sale-doc.chr-office = 'т':U
                   )
    then do:
        RUN compense in this-procedure ( input p-inkas-code
                                        ,input p-is-tpsi-obj
                                        ,input rest-tpsi) no-error.
       if error-status:error then undo f-close, return error.
       compensed = yes.
    end.
    run set-compensed in p-parent-handle(input compensed) no-error .
    run compense-tabak in this-procedure (input p-inkas-code) no-error .
    if error-status:error then undo f-close, return error.
    v-gas-income-created = "" .
    if buf_trn-doc.ext-doc-type = 'es':U then do:
        run thbjattr_value in this-procedure (input v-obj-type
                                             ,input v-obj-code
                                             ,input 'autosale':U
                                             ,input 'sale-add':U
                                             ,output v-value-character
                                             ,output v-value-date
                                             ,output v-value-decimal
                                             ,output v-value-integer
                                             ,output v-value-logical
                                             ,output v-param-type
                                             ,output v-found) no-error.
        assign
        v-gas-cli-type = ""
        v-gas-cli-code = 0.
        jj:
        do jj = 1 to num-entries(v-value-character, ';':U):
            v-entry = entry(jj, v-value-character, ';':U).
            if entry(1, v-entry) = 'ngs':U and integer(entry(3, v-entry)) > 0 then do:
                assign
                v-gas-cli-type = entry(2, v-entry)
                v-gas-cli-code = integer(entry(3, v-entry)).
                leave jj.
            end.
        end.
        if v-gas-cli-code > 0 then do:
            for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code:
                find first buf_goods where buf_goods.prod-code = buf_doc-line.prod-code
                                       and buf_goods.prod-type = buf_doc-line.prod-type
                                       and buf_goods.artic = buf_doc-line.artic no-lock.
                if is-gas(buf_goods.gds-code) then do:
                    find first buf_sale-doc where buf_sale-doc.inkas-code = p-inkas-code.
                    run str/gas-autosl.p (input parparentproc,
                                          input p-log-handle,
                                          input log-file-name,
                                          input p-auto,
                                          input p-inkas-code,
                                          input v-curr-r-b,
                                          input v-gas-cli-type,
                                          input v-gas-cli-code,
                                          output v-new_doc-code,
                                          output v-root-node,
                                          buffer buf_trn-doc,
                                          buffer buf_doc-line,
                                          buffer buf-new_trn-doc).
                    assign
                    r-qnty = 0
                    r-b-code = ?
                    r-pl-code = ?
                    rgds-dtl = ?.
                    find current buf_trn-doc exclusive-lock .
                    run RSRV-line in this-procedure (input 1,
                                                     input no,
                                                     input no,
                                                     input yes,
                                                     input no,
                                                     input v-new_doc-code,
                                                     input no,
                                                     input no,
                                                     input yes,
                                                     input buf_goods.gds-code,
                                                     input v-root-node,
                                                     output v-run-tpsi-line,
                                                     buffer buf_doc-line,
                                                     buffer buf_trn-doc,
                                                     buffer buf_sale-doc).
                    find current buf_trn-doc no-lock .
                    find first buf_spis-doc exclusive-lock where buf_spis-doc.doc-code = replace(buf_trn-doc.doc-code, "-", "^") no-error.
                    find first spis_sale-doc exclusive-lock where spis_sale-doc.inkas-code = p-inkas-code
                                                              and spis_sale-doc.doc-kind =  'trf':U
                                                              no-error .
                    find first spis_doc-line exclusive-lock where spis_doc-line.doc-code  = replace(buf_doc-line.doc-code, "-", "^")
                                                              and spis_doc-line.artic     = buf_doc-line.artic
                                                              and spis_doc-line.prod-type = buf_doc-line.prod-type
                                                              and spis_doc-line.prod-code = buf_doc-line.prod-code
                                                              no-error .
                    if available buf_spis-doc
                    and available spis_sale-doc
                    and available spis_doc-line
                    then do :
                      run RSRV-line in this-procedure (input 1,
                                                       input no,
                                                       input no,
                                                       input yes,
                                                       input no,
                                                       input v-new_doc-code,
                                                       input no,
                                                       input no,
                                                       input yes,
                                                       input buf_goods.gds-code,
                                                       input v-root-node,
                                                       output v-run-tpsi-line,
                                                       buffer spis_doc-line,
                                                       buffer buf_spis-doc,
                                                       buffer spis_sale-doc).
                    end.
                    find first buf_spis-doc exclusive-lock where buf_spis-doc.doc-code = replace(buf_trn-doc.doc-code, "-", "`") no-error.
                    find first spis_sale-doc exclusive-lock where spis_sale-doc.inkas-code = p-inkas-code
                                                              and spis_sale-doc.doc-kind =  'swo':U
                                                              no-error .
                    find first spis_doc-line exclusive-lock where spis_doc-line.doc-code  = replace(buf_doc-line.doc-code, "-", "`")
                                                              and spis_doc-line.artic     = buf_doc-line.artic
                                                              and spis_doc-line.prod-type = buf_doc-line.prod-type
                                                              and spis_doc-line.prod-code = buf_doc-line.prod-code
                                                              no-error .
                    if available buf_spis-doc
                    and available spis_sale-doc
                    and available spis_doc-line
                    then do :
                      run RSRV-line in this-procedure (input 1,
                                                       input no,
                                                       input no,
                                                       input yes,
                                                       input no,
                                                       input v-new_doc-code,
                                                       input no,
                                                       input no,
                                                       input yes,
                                                       input buf_goods.gds-code,
                                                       input v-root-node,
                                                       output v-run-tpsi-line,
                                                       buffer spis_doc-line,
                                                       buffer buf_spis-doc,
                                                       buffer spis_sale-doc).
                    end.
                    v-gas-income-created = v-gas-income-created + "," + string(buf_goods.gds-code) .
                end.
            end.
            for each spis_doc-line exclusive-lock where spis_doc-line.doc-code  = replace(buf_trn-doc.doc-code, "-", "^") :
              find first buf_goods where buf_goods.prod-code = spis_doc-line.prod-code
                                     and buf_goods.prod-type = spis_doc-line.prod-type
                                     and buf_goods.artic = spis_doc-line.artic no-lock.
              if is-gas(buf_goods.gds-code)
              and not can-do(v-gas-income-created, string(buf_goods.gds-code))
              then do:
                find first buf_spis-doc exclusive-lock where buf_spis-doc.doc-code = replace(buf_trn-doc.doc-code, "-", "^") no-error.
                find first spis_sale-doc exclusive-lock where spis_sale-doc.inkas-code = p-inkas-code
                                                          and spis_sale-doc.doc-kind =  'trf':U
                                                          no-error .
                if available buf_spis-doc
                and available spis_sale-doc
                then do :
                  run str/gas-autosl.p (input parparentproc,
                                        input p-log-handle,
                                        input log-file-name,
                                        input p-auto,
                                        input p-inkas-code,
                                        input v-curr-r-b,
                                        input v-gas-cli-type,
                                        input v-gas-cli-code,
                                        output v-new_doc-code,
                                        output v-root-node,
                                        buffer buf_trn-doc,
                                        buffer spis_doc-line,
                                        buffer buf-new_trn-doc).
                  run RSRV-line in this-procedure (input 1,
                                                   input no,
                                                   input no,
                                                   input yes,
                                                   input no,
                                                   input v-new_doc-code,
                                                   input no,
                                                   input no,
                                                   input yes,
                                                   input buf_goods.gds-code,
                                                   input v-root-node,
                                                   output v-run-tpsi-line,
                                                   buffer spis_doc-line,
                                                   buffer buf_spis-doc,
                                                   buffer spis_sale-doc).
                  v-gas-income-created = v-gas-income-created + "," + string(buf_goods.gds-code) .
                end.
              end.
            end.
            for each spis_doc-line exclusive-lock where spis_doc-line.doc-code  = replace(buf_trn-doc.doc-code, "-", "`") :
              find first buf_goods where buf_goods.prod-code = spis_doc-line.prod-code
                                     and buf_goods.prod-type = spis_doc-line.prod-type
                                     and buf_goods.artic = spis_doc-line.artic no-lock.
              if is-gas(buf_goods.gds-code)
              and not can-do(v-gas-income-created, string(buf_goods.gds-code))
              then do:
                find first buf_spis-doc exclusive-lock where buf_spis-doc.doc-code = replace(buf_trn-doc.doc-code, "-", "`") no-error.
                find first spis_sale-doc exclusive-lock where spis_sale-doc.inkas-code = p-inkas-code
                                                          and spis_sale-doc.doc-kind =  'swo':U
                                                          no-error .
                if available buf_spis-doc
                and available spis_sale-doc
                then do :
                  run str/gas-autosl.p (input parparentproc,
                                        input p-log-handle,
                                        input log-file-name,
                                        input p-auto,
                                        input p-inkas-code,
                                        input v-curr-r-b,
                                        input v-gas-cli-type,
                                        input v-gas-cli-code,
                                        output v-new_doc-code,
                                        output v-root-node,
                                        buffer buf_trn-doc,
                                        buffer spis_doc-line,
                                        buffer buf-new_trn-doc).
                  run RSRV-line in this-procedure (input 1,
                                                   input no,
                                                   input no,
                                                   input yes,
                                                   input no,
                                                   input v-new_doc-code,
                                                   input no,
                                                   input no,
                                                   input yes,
                                                   input buf_goods.gds-code,
                                                   input v-root-node,
                                                   output v-run-tpsi-line,
                                                   buffer spis_doc-line,
                                                   buffer buf_spis-doc,
                                                   buffer spis_sale-doc).
                  v-gas-income-created = v-gas-income-created + "," + string(buf_goods.gds-code) .
                end.
              end.
            end.
        end.
    end.
    RUN button-close in this-procedure (
                                             buffer buf_trn-doc
                                            ,buffer buf_ret-doc
                                            ,input p-is-tpsi-obj
                                            ,input auto-fbr
                                            ,input neg-tpsi-weight
                                            ,input neg-tpsi-qnty
                                            ,input neg-tpsi-oper
                                            ,Output b-close-enabled).
    IF NOT b-close-enabled
    and not v-is-inquiry
    then do:
      undo f-close, return error substitute("Не все товары зарезервированы, закрытие невозможно!"
                            ).
    end.
    IF NOT b-close-enabled
    and v-is-inquiry
    then do:
      undo f-close, return error substitute("Некоторые товары зарезервированы, закрытие невозможно!"
                            ).
    end.
    if not v-is-inquiry then do:
      do while ii < 2:
        RUN neg-rests in this-procedure (
                    input yes
                  , input buf_inkas.status_
                  , input buf_inkas.inkas-code
                  , input 'ИЗМЕНЕНИЕ':U
                  , input p-is-catering
                  , input p-is-tpsi-obj
                  , input neg-tpsi-weight
                  , input neg-tpsi-qnty
                  , input neg-tpsi-oper
                  ).
        _dtl-rests:
        for each dtl-rests no-LOCK:
          if NOT dtl-rests.ok
          or (ii = 0 AND dtl-rests.fbr > 0 and auto-fbr)
          or (ii = 0 AND dtl-rests.prop > 0 and p-is-tpsi-obj)
          then do:
            if (not auto-fbr or dtl-rests.fbr = 0)
            AND (not p-is-tpsi-obj or dtl-rests.prop = 0)
            then do:
              assign
              my-mes =  substitute("В результате данной продажи&1" +
                                    "на текущем объекте (&2&3)&1" +
                                    "появятся недопустимые ОТРИЦАТЕЛЬНЫE ОСТАТКИ&1" +
                                    "по товару  с артикулом : &4&1" +
                                    "производителя : &5&1" +
                                    "&6&1" +
                                    (if p-auto = 0 then "Закрытие продажи невозможнo !" else "":U)
                          , chr(10)
                          , buf_inkas.obj-type
                          , buf_inkas.obj-code
                          , dtl-rests.artic
                          , (trim( dtl-rests.prod-type ) + " " + string(dtl-rests.prod-code))
                          ,  (if dtl-rests.b-code > 0
                            then ("по коду : " + string( dtl-rests.b-code, ">>>>>>>>>9" ))
                            else "")
                          ).
              if p-auto = 0 then do:
                undo f-close,  return error my-mes.
              end.
              else do:
                assign
                v-is-neg-rests = yes.
                  run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input my-mes                                       ).
              end.
            end.
            else do:
              assign
              force-auto-fbr = ( auto-fbr and dtl-rests.fbr > 0)
              force-tpsi-obj = ( p-is-tpsi-obj and dtl-rests.prop > 0)
              .
              if (force-auto-fbr and force-tpsi-obj)
              or (force-auto-fbr and not p-is-tpsi-obj)
              or (force-tpsi-obj and not auto-fbr)
              then
              LEAVE _dtl-rests.
            end.
          end.
        end.
        if p-auto > 0
        and v-is-neg-rests then do:
                  run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "Закрытие продажи невозможно"                                       ).
          undo f-close,  return error my-mes.
        end.
        if force-tpsi-obj and ii = 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Автоматическое перемещение товаров в пределах ТПСИ,&1 необходимых для резервирования в продаже &2"
                              , chr(10))
                                ).
          run str/tpsisale.p (
                        input parparentproc
                        ,input p-parent-handle
                        ,input p-log-handle
                        ,input (string(buf_inkas.host-code) + chr(4) +
                                buf_Inkas.obj-type + chr(4) +
                                string(buf_inkas.obj-code) + chr(4) +
                                buf_inkas.inkas-code + chr(4) +
                                log-file-name
                                )
                        ) no-error .
          if error-status:error then do:
            undo f-close, return error  substitute(("Ошибка при попытке перемещения товаров, необходимых для резервирования в продаже &1:&2&3 &4" +
                                    "Закрытие продажи невозможнo !")
                                    , buf_inkas.inkas-code
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value ).
          end.
          ASSIGN
          FROM-MENU = NO
          .
          run b-res-proc in this-procedure (
                                            buffer buf_inkas
                                          , buffer buf_trn-doc
                                          , buffer buf_ret-doc
                                          , input yes
                                          , input auto-close
                                          , input yes
                                          , input rest-dish
                                          , input v-fbr-income-doc-code
                                          , input p-is-tpsi-obj
                                          , input rest-tpsi) no-error.
          if error-status:error or return-value = "error" then do:
            undo f-close, return error  substitute("Ошибка при попытке резервирования товаров, перемещенных для данной продажи:&1&2 &3" +
                                    "Закрытие продажи невозможнo !"
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value
                                      ).
          end.
          if not force-auto-fbr then
          assign
          ii = ii + 1
          .
        end.
        if force-auto-fbr and ii = 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Автоматическое производство товаров, необходимых для резервирования в продаже &1", buf_inkas.inkas-code
                                , chr(10))
                                ).
          run str/fbrsale.p (
                        input parparentproc
                        ,input this-procedure
                        ,input p-log-handle
                        ,input (buf_inkas.inkas-code + chr(4) +
                                (if rest-dish then "yes" else "no") + chr(4) +
                                (if rest-ingr then "yes" else "no")
                                )
                      ) no-error .
          if error-status:error then do:
            undo f-close, return error substitute(("Ошибка при попытке производства товаров, необходимых для резервирования в продаже &1:&2&3 &4" +
                                    "Закрытие продажи невозможнo !")
                                    , buf_inkas.inkas-code
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value ).
          end.
          if not rest-dish then do:
            run fbrcode-get-final-doc in  this-procedure (
                                                          input buf_inkas.inkas-code
                                                          ,output v-fbr-income-doc-code
                                                          ) no-error .
            if error-status:error then do:
              undo f-close, return error substitute("Ошибка при получении кода документа ВН товаров, произведенных для резервирования в продаже:&1&2 &3"
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value ).
            end.
          end.
          ASSIGN
          FROM-MENU = NO
          .
          run b-res-proc in this-procedure (
                                              buffer buf_Inkas
                                            , buffer buf_trn-doc
                                            , buffer buf_ret-doc
                                            , input yes
                                            , input auto-close
                                            , input yes
                                            , input rest-dish
                                            , input v-fbr-income-doc-code
                                            , input p-is-tpsi-obj
                                            , input rest-tpsi) no-error.
          if error-status:error or return-value = "error" then do:
            undo f-close, return error  substitute("Ошибка при попытке резервирования товаров, произведенных для данной продажи&1" +
                                    "Закрытие продажи невозможнo !"
                                    ,chr(10)).
          end.
          else do:
            run fbr-saledoc-create in this-procedure ( input buf_inkas.inkas-code).
          end.
        end.
        assign
        ii = ii + 1
        .
      end.
    end.
    FIND FIRST locked_inkas WHERE recid( locked_inkas ) = recid( buf_inkas ) .
    FIND FIRST locked_trn-doc WHERE locked_trn-doc.doc-code = buf_inkas.inkas-code .
    assign
    locked_inkas.is-auto-close = (p-auto >= 2)
    locked_inkas.auto-fbr   = force-auto-fbr
    locked_Inkas.rest-dish  = rest-dish
    locked_Inkas.rest-ingr  = rest-ingr
    locked_inkas.auto-tpsi  = force-tpsi-obj
    locked_inkas.rest-tpsi  = rest-tpsi
    locked_Inkas.auto-comp  = auto-comp
    .
    if l-shift-on then do:
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  locked_inkas.obj-type
  ,input  locked_inkas.obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
      if error-status:error
      or not (v-shift-date = locked_inkas.shift-date
              and
              v-shift-num = locked_inkas.shift-num) then do:
        find first buf_shift-obj no-lock where
                  buf_shift-obj.obj-type = locked_inkas.obj-type
              and buf_shift-obj.obj-code = locked_inkas.obj-code
              and buf_shift-obj.shift-date = locked_inkas.shift-date
              and buf_shift-obj.shift-num = locked_inkas.shift-num no-error.
        if not available buf_shift-obj then do:
            undo f-close, return error  substitute("Не найдена смена с пор.№ &1 от &2 для &3&4&5" +
                                                  "Закрытие продажи невозможнo !"
                                                   ,locked_inkas.shift-num
                                                   ,locked_inkas.shift-date
                                                   ,locked_inkas.obj-type
                                                   ,locked_inkas.obj-code
                                                   ,chr(10)).
        end.
        if buf_shift-obj.status_ <> 'зкр':U then do:
            undo f-close, return error  substitute("Смена с пор.№ &1 от &2 для &3&4 имеет статус &5&6" +
                                                  "Закрытие продажи невозможнo !"
                                                   ,locked_inkas.shift-num
                                                   ,locked_inkas.shift-date
                                                   ,locked_inkas.obj-type
                                                   ,locked_inkas.obj-code
                                                   ,locked_inkas.status_
                                                   ,chr(10)).
        end.
        assign
        v-back-date = yes
        locked_inkas.fact-date = buf_shift-obj.close-date
        v-old-shift-obj = buffer buf_shift-obj:handle
        v-new-shift-obj = v-old-shift-obj
        .
      end.
    end.
    else .
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  locked_inkas.obj-type
  ,input  locked_inkas.obj-code
  ,output sys-today
  ) no-error .
   if not v-back-date then do:
    if p-auto > 1 then do:
      assign
      locked_inkas.fact-date = sys-today
      .
    end.
    else do:
        if locked_inkas.doc-date = sys-today then do:
            locked_inkas.fact-date = sys-today.
        end.
        else  do:
          if p-auto < 2 then do:
            assign
            v-doc-date = locked_inkas.doc-date
            .
            if not can-find(first tpsi_sale-doc where
                                tpsi_sale-doc.inkas-code = locked_inkas.inkas-code
                            and tpsi_sale-doc.tpsidoc = yes) then  do:
              run str/sale-fd.w ( input sys-today, input-output v-doc-date, input l-shift-on ) no-error.
              if not error-status:error then do:
                 run str/chk-back.p (
                                      input locked_inkas.inkas-code
                                    , input v-doc-date
                                     ) no-error.
                 if error-status:error then do:
                    undo f-close, return error
                   substitute("НЕЛЬЗЯ закрыть продажу с выбранной датой факт, равной &1&2&3"
                                    , string(v-doc-date, "99/99/9999")
                                    , chr(10)
                                    , return-value
                                    ).
                 end.
              end.
              if not error-status:error then
              assign
              locked_inkas.fact-date = v-doc-date
              v-back-date = (v-doc-date < sys-today)
              .
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute("Дата факт закрытия продажи выбрана равной &1&2"
                                    , string(v-doc-date, "99/99/9999")
                                    , chr(10))
                                    ).
            end.
            else do:
              assign
              locked_inkas.fact-date = sys-today
              .
            end.
          end.
          else
          assign
          locked_inkas.fact-date = sys-today
          .
        end.
      end.
    end.
    if p-auto = 0 then run frame-title in p-parent-handle .
    RUN INKAS-CLOSING in this-procedure ( input v-back-date, input v-is-inquiry, buffer locked_inkas) no-error.
    if error-status:error then do:
        run waitfram-hide in this-procedure .
        undo f-close,  return error return-value .
    end.
    glog = no.
    if not v-is-inquiry then do:
      _dtl:
      FOR EACH dtl-rests where
            dtl-rests.prt-code >=0
        and dtl-rests.ok-prop = no ,
        FIRST buf_prt-obj WHERE
            buf_prt-obj.obj-type = buf_inkas.obj-type
        AND buf_prt-obj.obj-code = buf_inkas.obj-code
        AND buf_prt-obj.artic = dtl-rests.artic
        AND buf_prt-obj.prod-type = dtl-rests.prod-type
        AND buf_prt-obj.prod-code = dtl-rests.prod-code
        AND buf_prt-obj.prt-code = dtl-rests.prt-code  NO-LOCK:
          if p-is-tpsi-obj
          and dtl-rests.prop > 0 then do:
            find first dtl-rests-mark where
                      dtl-rests-mark.artic = dtl-rests.artic
                  and dtl-rests-mark.prod-type = dtl-rests.prod-type
                  and dtl-rests-mark.prod-code = dtl-rests.prod-code no-error .
            if available dtl-rests-mark then next _dtl.
          end.
          IF buf_prt-obj.fact-qnty < 0 then do:
            v-prichina =  substitute("В результате данной продажи&1" +
                                  "на текущем объекте (&2&3)&1" +
                                  "появятся недопустимые ОТРИЦАТЕЛЬНЫE ОСТАТКИ&1" +
                                  "по товару  с артикулом : &4&1" +
                                  "производителя : &5&1" +
                                  "&6&1" +
                                  "Закрытие продажи невозможнo !&1" +
                                  "Исправьте эту ситуацию путем выполнения на кассе&1" +
                                  "последовательных возвратов и расходов."
                        , chr(10)
                        , buf_inkas.obj-type
                        , buf_inkas.obj-code
                        , dtl-rests.artic
                        , (trim( dtl-rests.prod-type ) + " " + string(dtl-rests.prod-code))
                        ,  (if dtl-rests.b-code > 0
                          then ("по коду : " + string( dtl-rests.b-code, ">>>>>>>>>9" ))
                          else "")
                        ).
              BadTrans = TRUE .
          END.
          LEAVE.
        END.
      if BadTrans then do:
          run waitfram-hide in this-procedure .
          UNDO f-close, return error v-prichina.
      end.
  end.
  if not v-is-inquiry then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Создание накладных МЦ...")
                          ).
    run str/salewth.p (
                    input parparentproc
                    ,buffer buf_Inkas
                    ,buf_trn-doc.cli-type
                    ,buf_trn-doc.cli-code
                    ,buf_trn-doc.doc-code
                    ,(if available buf_ret-doc then buf_ret-doc.doc-code else '':U)
                  ) no-error.
    if error-status:error then do:
      undo f-close, return error return-value .
    end.
    release locked_inkas no-error .
    if error-status:error then do:
      undo f-close, return error return-value .
    end.
    if can-find( first ub.chk-doc NO-LOCK WHERE
                    ub.chk-doc.out-code = buf_inkas.inkas-code
                AND ub.chk-doc.d-card <> "" ) then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Подсчет итогов продаж по дисконтным картам...")
                            ).
      run str/saledc.p
        (
        input parparentproc
        ,input this-procedure :handle
        ,input p-log-handle
        ,input 'sale-close':U
        ,input ?
        ,input ""
        ,input 0
        ,input 0
        ,input 0
        ,input g#db-num
        ,input buf_Inkas.inkas-code
        ,input buf_Inkas.doc-date
        ,input buf_Inkas.fact-date
        ,input cre-pay
        ,input 1
        ,input ?
        ,input yes
        ) no-error .
      if error-status:error then do:
        undo f-close, return error return-value .
      end.
    end.
  end.
END.
  if l-shift-on then do:
    if v-back-date and v-new-shift-obj <> ? and v-new-shift-obj:available then do :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_shift':U
  ,input v-old-shift-obj
  ,input v-new-shift-obj
  ,input ''
  ,input ''
  ) no-error .
      if error-status :error then do:
        run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("&1Ошибка маршрутизации записи в машину правил&1&2&1&3"
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value
                            )).
        v-view-log = yes.
      end.
    end .
  end.
if not v-is-inquiry then do:
  run fbrhist-table-to-base in this-procedure no-error.
  if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Ошибка записи истории производства в базу данных&1&2 &3"
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value
                            )).
      assign
      v-view-log = yes.
      if p-auto = 0 then do:
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе закрытия продажи произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action58   as character no-undo .
  define variable v-printed58       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе закрытия продажи произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'saleclos.log')
    ,input  7
    ,output v-user-action58
    ,output v-printed58
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
  OS-DELETE value(string("./":U) + 'saleclos.log').
end.
                        return "error":U.                  end.
  end.
end.
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Закрытие продажи &1: Отчет о продаже закрыт успешно.", p-inkas-code)                                       ).
FOR EACH dtl-rests:
  delete dtl-rests.
END.
end.
end procedure.
procedure compense-tabak :
  define input parameter p-inkas-code as character no-undo .
  define variable cv as decimal no-undo.
  define variable unresv as decimal no-undo.
  define variable unresr as decimal no-undo.
  define buffer b-goods for goods.
  define buffer b-gds-dtl for gds-dtl.
  define buffer brw-gds-dtl for gds-dtl.
  define buffer br-gds-dtl for gds-dtl.
  define buffer b-doc-line for doc-line.
  define buffer br-doc-line for doc-line.
  define buffer brw-doc-line for doc-line.
  define buffer b-doc for trn-doc.
  define buffer b-doc-prts for doc-prts.
  define buffer brw-doc-prts for doc-prts.
  define buffer b-doc-pl for doc-pl.
  define buffer brw-doc-pl for doc-pl.
  define buffer b-gds-prt for gds-prt.
  define variable qnty-compense as decimal no-undo.
  define variable qnty-compense-abs as decimal no-undo.
  define variable tsall as decimal no-undo.
  define variable v-type as character no-undo .
  define variable v-attr-value as character no-undo .
  define variable vCodeIdent as character no-undo .
  define buffer buf_marking for ub.marking .
  define buffer buf_gds-prt for ub.gds-prt.
  define buffer buf_doc-prts  for ub.doc-prts.
  define buffer buf_sale-doc for ub.sale-doc.
  define buffer b_marking-chk for ub.marking-chk .
  define buffer br_marking-chk for ub.marking-chk .
  define buffer b_chk-doc for ub.chk-doc .
  define buffer br_chk-doc for ub.chk-doc .
  define buffer b_chk-gds for ub.chk-gds .
  define buffer br_chk-gds for ub.chk-gds .
  find first buf_sale-doc NO-lock where
            buf_Sale-doc.inkas-code = p-inkas-code
        and buf_sale-doc.doc-kind = 'rs':U no-error .
  if not available buf_sale-doc then return.
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "Проведем компенсацию незарезервированных маркированных товаров"                                       ).
  _docline:
  for each br-doc-line where
         br-doc-line.doc-code = buf_ret-doc.doc-code
  on error  undo _docline, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo _docline, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _docline, return error substitute( "&1. endkey", vss-workfile )
  :
    assign
      cv = 0
    .
    FIND FIRST b-doc-line where
               b-doc-line.artic = br-doc-line.artic AND
               b-doc-line.prod-type = br-doc-line.prod-type AND
               b-doc-line.prod-code = br-doc-line.prod-code and
               b-doc-line.doc-code = buf_trn-doc.doc-code NO-ERROR.
    IF NOT AVAILABLE b-doc-line then NEXT _docline.
    if b-doc-line.doc-qnty = b-doc-line.fact-qnty then next _docline .
    find first goods no-lock where goods.artic = br-doc-line.artic
                               and goods.prod-type = br-doc-line.prod-type
                               and goods.prod-code = br-doc-line.prod-code
                               .
    RUN gds-attr-value (
                        INPUT goods.gds-code,
                        INPUT 'mark-type':U,
                        OUTPUT v-attr-value,
                        OUTPUT v-type
                        ).
    if v-attr-value > ""
    and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(b-doc-line.obj-type, b-doc-line.obj-code):GetIsMarkingForType(v-attr-value)
    then do :
      find first bar-code no-lock where bar-code.gds-code = goods.gds-code
                                    and bar-code.unit-cli = b-doc-line.unit-cli
                                    no-error .
      if available bar-code
      then do :
        for each b_chk-doc no-lock where b_chk-doc.out-code = b-doc-line.doc-code
                                     and b_chk-doc.chk-type = integer ('1':U)
                                     :
          for each b_chk-gds no-lock where b_chk-gds.doc-code = b_chk-doc.doc-code
                                       and b_chk-gds.b-code = bar-code.b-code
                                       and b_chk-gds.doc-qnty < 0 :
            for each b_marking-chk exclusive-lock where b_marking-chk.doc-code = b_chk-gds.doc-code
                                                     and b_marking-chk.line-num = b_chk-gds.line-num
                                                     and b_marking-chk.sts = 0
                                                     :
              for first br_marking-chk exclusive-lock where br_marking-chk.mark = b_marking-chk.mark
                                                        and br_marking-chk.doc-code = b_marking-chk.doc-code
                                                        and br_marking-chk.line-num <> b_marking-chk.line-num
                                                        and br_marking-chk.sts = 0,
              first br_chk-gds no-lock where br_chk-gds.doc-code = b_chk-gds.doc-code
                                         and br_chk-gds.line-num = br_marking-chk.line-num
                                         and br_chk-gds.doc-qnty = - b_chk-gds.doc-qnty
                                         :
                assign
                  b_marking-chk.sts = 2
                  br_marking-chk.sts = 2
                .
              end .
            end .
          end .
        end .
        for each br_chk-doc no-lock where br_chk-doc.out-code = b-doc-line.doc-code
                                      and br_chk-doc.chk-type = integer ('6':U)
                                       :
          for each br_chk-gds no-lock where br_chk-gds.doc-code = br_chk-doc.doc-code
                                        and br_chk-gds.b-code = bar-code.b-code:
            mark_ :
            for each br_marking-chk exclusive-lock where br_marking-chk.doc-code = br_chk-gds.doc-code
                                                     and br_marking-chk.line-num = br_chk-gds.line-num
                                                     and br_marking-chk.sts = 0
                                                     :
              for each b_chk-doc no-lock where b_chk-doc.out-code = b-doc-line.doc-code
                                           and b_chk-doc.chk-type = integer ('1':U),
              each b_chk-gds no-lock where b_chk-gds.doc-code = b_chk-doc.doc-code
                                       and b_chk-gds.b-code = bar-code.b-code,
              first b_marking-chk exclusive-lock where b_marking-chk.mark = br_marking-chk.mark
                                                   and b_marking-chk.doc-code = b_chk-gds.doc-code
                                                   and b_marking-chk.line-num = b_chk-gds.line-num
                                                   and b_marking-chk.sts = 0
                                                   and rowid(b_marking-chk) <> rowid(br_marking-chk)
                                                   :
                assign vCodeIdent = GetCodeIdent(b_marking-chk.mark) .
                find first buf_marking no-lock where buf_marking.mark begins vCodeIdent no-error .
                if not available buf_marking then next .
                assign
                  b_marking-chk.sts = 2
                  br_marking-chk.sts = 2
                  cv = cv + buf_marking.box-qnty
                .
                next mark_ .
              end .
            end .
          end .
        end .
      end .
      FIND FIRST buf_gds-prt NO-LOCK WHERE
                 buf_gds-prt.upper-code = goods.prt-root NO-ERROR.
      FIND FIRST b-gds-dtl where
                  b-gds-dtl.doc-code = buf_ret-doc.doc-code AND
                  b-gds-dtl.artic = b-doc-line.artic AND
                  b-gds-dtl.prod-type = b-doc-line.prod-type AND
                  b-gds-dtl.prod-code = b-doc-line.prod-code AND
                  b-gds-dtl.prt-code = buf_gds-prt.node-code No-ERROR.
      FIND FIRST br-gds-dtl where
                  br-gds-dtl.doc-code = buf_trn-doc.doc-code AND
                  br-gds-dtl.artic = br-doc-line.artic AND
                  br-gds-dtl.prod-type = br-doc-line.prod-type AND
                  br-gds-dtl.prod-code = br-doc-line.prod-code AND
                  br-gds-dtl.prt-code = buf_gds-prt.node-code  No-ERROR.
      assign
        tsall =  if v-curr-r-b = 'base':U
                 then  (br-gds-dtl.fact-qnty * (br-gds-dtl.price-base - br-gds-dtl.discnt-base) -
                        b-gds-dtl.fact-qnty * (b-gds-dtl.price-base - b-gds-dtl.discnt-base)
                       )
                 else   (br-gds-dtl.fact-qnty * (br-gds-dtl.price-rubl - br-gds-dtl.discnt-rubl) -
                        b-gds-dtl.fact-qnty * (b-gds-dtl.price-rubl - b-gds-dtl.discnt-rubl)
                       )
        b-gds-dtl.fact-qnty = b-gds-dtl.fact-qnty - cv
        br-gds-dtl.fact-qnty = br-gds-dtl.fact-qnty - cv
        br-doc-line.fact-qnty = br-doc-line.fact-qnty - cv
        b-doc-line.fact-qnty = b-doc-line.fact-qnty - cv
        qnty-compense = qnty-compense + cv
        qnty-compense-abs = qnty-compense-abs + abs(cv)
      .
      if (v-curr-r-b = 'base':U and b-gds-dtl.discnt-base <> br-gds-dtl.discnt-base)
      OR (v-curr-r-b = 'rubl':U and b-gds-dtl.discnt-rubl <> br-gds-dtl.discnt-rubl)
      then do:
        if v-curr-r-b = 'base':U then do:
          assign
          br-gds-dtl.discnt-base = (if br-gds-dtl.fact-qnty <> 0
                                    then (br-gds-dtl.price-base - ( b-gds-dtl.fact-qnty * (b-gds-dtl.price-base - b-gds-dtl.discnt-base) +
                                                                 tsall )  / br-gds-dtl.fact-qnty )
                                    else br-gds-dtl.discnt-base )
          b-gds-dtl.discnt-base = (if br-gds-dtl.fact-qnty = 0 and b-gds-dtl.fact-qnty <> 0
                                    then (b-gds-dtl.price-base - ( br-gds-dtl.fact-qnty * (br-gds-dtl.price-base - br-gds-dtl.discnt-base) -
                                                                 tsall ) / b-gds-dtl.fact-qnty  )
                                    else b-gds-dtl.discnt-base )
          br-gds-dtl.discnt-rubl =  br-gds-dtl.discnt-BASE * (buf_trn-doc.base-rate / buf_trn-doc.base-scale)
          b-gds-dtl.discnt-rubl =   b-gds-dtl.discnt-BASE * (buf_trn-doc.base-rate / buf_trn-doc.base-scale)
          .
        end.
        else do:
          assign
          br-gds-dtl.discnt-rubl = (if br-gds-dtl.fact-qnty <> 0
                                    then (br-gds-dtl.price-rubl -
                                                                ( b-gds-dtl.fact-qnty * (b-gds-dtl.price-rubl - b-gds-dtl.discnt-rubl) +
                                                               tsall )  / br-gds-dtl.fact-qnty
                                                                 )
                                   else br-gds-dtl.discnt-rubl
                                   )
          b-gds-dtl.discnt-rubl = (if br-gds-dtl.fact-qnty = 0 and b-gds-dtl.fact-qnty <> 0
                                   then (b-gds-dtl.price-rubl -
                                                             ( br-gds-dtl.fact-qnty * (br-gds-dtl.price-rubl - br-gds-dtl.discnt-rubl) -
                                                           tsall ) / b-gds-dtl.fact-qnty
                                         )
                                  else b-gds-dtl.discnt-rubl
                                  )
          br-gds-dtl.discnt-base =  br-gds-dtl.discnt-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
          b-gds-dtl.discnt-base =   b-gds-dtl.discnt-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
          .
        end.
      end.
      release b-gds-dtl.
      release br-gds-dtl.
    end .
  end .
  FIND FIRST b-doc where b-doc.doc-code = buf_trn-doc.doc-code No-ERROR.
    assign
      b-doc.fact-qnty = b-doc.fact-qnty - qnty-compense
    .
  FIND FIRST b-doc where b-doc.doc-code = buf_ret-doc.doc-code No-ERROR.
  if available b-doc then do:
    assign
      b-doc.fact-qnty = b-doc.fact-qnty - qnty-compense
    .
  end.
  run waitfram-hide in this-procedure .
  if p-auto = 0 then do:
    run UI-on in p-parent-handle.
    run ui-2 in p-parent-handle.
  end.
end procedure .
PROCEDURE compense:
define input parameter p-inkas-code as character no-undo .
define input parameter p-is-tpsi-obj  as logical no-undo .
define input parameter p-rest-tpsi as logical no-undo .
define variable cv as decimal no-undo.
define variable cvp as decimal no-undo.
define variable cvpl as decimal no-undo.
define variable res-parts as decimal.
define variable res-places as decimal.
define variable unresv as decimal no-undo.
define variable unresr as decimal no-undo.
define buffer b-goods for ub.goods.
define buffer b-gds-dtl for ub.gds-dtl.
define buffer brw-gds-dtl for ub.gds-dtl.
define buffer br-gds-dtl for ub.gds-dtl.
define buffer b-doc-line for ub.doc-line.
define buffer br-doc-line for ub.doc-line.
define buffer brw-doc-line for ub.doc-line.
define buffer b-doc for ub.trn-doc.
define buffer b-doc-prts for ub.doc-prts.
define buffer brw-doc-prts for ub.doc-prts.
define buffer b-doc-pl for ub.doc-pl.
define buffer brw-doc-pl for ub.doc-pl.
define buffer b-gds-prt for ub.gds-prt.
define variable qnty-compense as decimal no-undo.
define variable qnty-compense-abs as decimal no-undo.
define variable tsall as decimal no-undo.
define variable old-doc-line-fact-qnty-r as decimal no-undo.
define variable old-doc-line-fact-qnty-v as decimal no-undo.
define variable old-doc-line-fact-qnty-rw as decimal no-undo.
define variable saled-by-place-r as decimal no-undo.
define variable saled-by-parts-r as decimal no-undo.
define variable saled-by-place-v as decimal no-undo.
define variable saled-by-parts-v as decimal no-undo.
define variable saled-by-place-rw as decimal no-undo.
define variable saled-by-parts-rw as decimal no-undo.
define variable v-retur-write-off-code as character no-undo .
define variable v-type as character no-undo .
define variable v-return-write-off-code like ub.trn-doc.doc-code no-undo .
define variable v-attr-value as character no-undo .
define buffer b-temp-prts for temp-prts.
define buffer b-temp-pl for temp-pl.
define buffer buf_units for ub.units.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_doc-pl  for ub.doc-pl.
define buffer buf_doc-prts  for ub.doc-prts.
define buffer buf_sale-doc for ub.sale-doc.
assign
note-compense = ""
.
find first buf_sale-doc NO-lock where
          buf_Sale-doc.inkas-code = p-inkas-code
      and buf_sale-doc.doc-kind = 'rs':U no-error .
if not available buf_sale-doc then return.
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "Проведем компенсацию незарезервированных расходов-возвратов..."                                       ).
find first buf_sale-doc NO-lock where
          buf_sale-doc.inkas-code = p-inkas-code
      and buf_sale-doc.doc-kind = 'rwo':U no-error .
if available buf_sale-doc then
v-return-write-off-code = buf_sale-doc.doc-code.
_docline:
for each b-doc-line where
       b-doc-line.doc-code = buf_ret-doc.doc-code
on error  undo _docline, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _docline, return error substitute( "&1. stop", vss-workfile )
on endkey undo _docline, return error substitute( "&1. endkey", vss-workfile )
:
    assign
    cv = 0
    cashparts = no
    cashplace = no
    cashfbr   = no
    old-doc-line-fact-qnty-v = b-doc-line.fact-qnty
    .
    FIND FIRST br-doc-line where
               br-doc-line.artic = b-doc-line.artic AND
               br-doc-line.prod-type = b-doc-line.prod-type AND
               br-doc-line.prod-code = b-doc-line.prod-code AND
               br-doc-line.doc-code = buf_trn-doc.doc-code NO-ERROR.
    IF NOT AVAILABLE br-doc-line then NEXT _docline.
    find first goods no-lock where goods.artic = br-doc-line.artic
                               and goods.prod-type = br-doc-line.prod-type
                               and goods.prod-code = br-doc-line.prod-code
                               .
    RUN gds-attr-value (
                        INPUT goods.gds-code,
                        INPUT 'mark-type':U,
                        OUTPUT v-attr-value,
                        OUTPUT v-type
                        ).
    if v-attr-value > ""
    and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(br-doc-line.obj-type, br-doc-line.obj-code):GetIsMarkingForType(v-attr-value)
    then do :
      next _docline .
    end .
    FIND FIRST brw-doc-line where
               brw-doc-line.artic = b-doc-line.artic AND
               brw-doc-line.prod-type = b-doc-line.prod-type AND
               brw-doc-line.prod-code = b-doc-line.prod-code AND
               brw-doc-line.doc-code = v-return-write-off-code NO-ERROR.
    assign
    old-doc-line-fact-qnty-r = br-doc-line.fact-qnty
    old-doc-line-fact-qnty-v = b-doc-line.fact-qnty
    old-doc-line-fact-qnty-rw = (if available brw-doc-line then brw-doc-line.fact-qnty else 0)
    saled-by-place-v = 0
    saled-by-place-r = 0
    saled-by-place-rw = 0
    saled-by-parts-v = 0
    saled-by-parts-r = 0
    saled-by-parts-rw = 0
    .
    find first b-goods where
               b-goods.artic = b-doc-line.artic AND
               b-goods.prod-type = b-doc-line.prod-type AND
               b-goods.prod-code = b-doc-line.prod-code NO-ERROR.
    IF NOT AVAILABLE b-goods then NEXT _docline.
    if is-gas(b-goods.gds-code) then v-gas-compensed = false .
    FIND FIRST buf_units NO-LOCK WHERE
               buf_units.unit-name = b-goods.unit-base No-ERROR.
    IF NOT AVAILABLE buf_units then NEXT _docline.
    if can-find(first ub.doc-fbr-gds no-lOCK where
                      ub.doc-fbr-gds.gds-code = b-goods.gds-code AND
                      ub.doc-fbr-gds.out-code = buf_ret-doc.doc-code)
      or
       can-find(first ub.doc-fbr-gds no-lOCK where
                      ub.doc-fbr-gds.gds-code = b-goods.gds-code AND
                      ub.doc-fbr-gds.out-code = buf_trn-doc.doc-code)
                      then do:
      NEXT _docline.
    end.
    if can-find(first ub.doc-pl No-LOCK WHERE
                      ub.doc-pl.gds-code = b-goods.gds-code AND
                      ub.doc-pl.out-code = buf_ret-doc.doc-code) then do:
        FIND FIRST buf_gds-prt NO-LOCK WHERE
                   buf_gds-prt.upper-code = b-goods.prt-root NO-ERROR.
        assign
        cashplace = yes
        cvpl = 0
        .
        for each temp-pl:
          delete temp-pl.
        end.
        for each b-doc-pl NO-LOCK WHERE
                 b-doc-pl.gds-code = b-goods.gds-code AND
                 b-doc-pl.out-code = buf_ret-doc.doc-code:
          saled-by-place-v = saled-by-place-v + b-doc-pl.fact-qnty.
          find first brw-doc-pl no-lock where
                 brw-doc-pl.gds-code = b-goods.gds-code
            AND  brw-doc-pl.pl-code = b-doc-pl.pl-code
            AND brw-doc-pl.out-code = v-return-write-off-code no-error .
          if available brw-doc-pl then do:
            saled-by-place-rw = saled-by-place-rw + brw-doc-pl.fact-qnty.
          end.
          create
          temp-pl.
          assign
          temp-pl.is-out = -1
          temp-pl.pl-code = if b-doc-pl.pl-code <> ?
                                then b-doc-pl.pl-code
                                else -1
          temp-pl.doc-qnty = b-doc-pl.doc-qnty
          temp-pl.fact-qnty = b-doc-pl.fact-qnty - (if available brw-doc-pl
                                                    then brw-doc-pl.fact-qnty
                                                    else 0)
          .
        end.
        for each buf_doc-pl NO-LOCK WHERE
                 buf_doc-pl.gds-code = b-goods.gds-code AND
                 buf_doc-pl.out-code = buf_trn-doc.doc-code:
                 saled-by-place-r = saled-by-place-r + buf_doc-pl.fact-qnty.
          create
          temp-pl.
          assign
          temp-pl.is-out = 1
          temp-pl.pl-code = if buf_doc-pl.pl-code <> ?
                                then buf_doc-pl.pl-code
                                else -1
          temp-pl.doc-qnty = buf_doc-pl.doc-qnty
          temp-pl.fact-qnty = buf_doc-pl.fact-qnty
          .
        end.
        for each b-temp-pl  WHERE
                 b-temp-pl.is-out = -1:
            find first temp-pl WHERE
                       temp-pl.pl-code = b-temp-pl.pl-code AND
                       temp-pl.is-out  = 1 No-ERROR.
            if not available temp-pl or
              (temp-pl.fact-qnty = temp-pl.doc-qnty AND b-temp-pl.fact-qnty = b-temp-pl.doc-qnty) then
            NEXT.
            assign
            res-places = MAXIMUM(b-temp-pl.fact-qnty - b-temp-pl.doc-qnty , temp-pl.fact-qnty - temp-pl.doc-qnty)
            res-places = if b-temp-pl.fact-qnty < res-places then b-temp-pl.fact-qnty else res-places
            res-places = if temp-pl.fact-qnty < res-places then temp-pl.fact-qnty else res-places
            unresv = res-places - (b-temp-pl.fact-qnty - b-temp-pl.doc-qnty)
            unresr = res-places - (temp-pl.fact-qnty - temp-pl.doc-qnty)
            b-temp-pl.new-fact-qnty = b-temp-pl.fact-qnty - res-places
            temp-pl.new-fact-qnty = temp-pl.fact-qnty - res-places
            cvpl = cvpl + res-places
            .
            FIND FIRST b-gds-dtl where
                        b-gds-dtl.doc-code = buf_ret-doc.doc-code AND
                      b-gds-dtl.artic = b-doc-line.artic AND
                      b-gds-dtl.prod-type = b-doc-line.prod-type AND
                      b-gds-dtl.prod-code = b-doc-line.prod-code AND
                      b-gds-dtl.prt-code = buf_gds-prt.node-code No-ERROR.
            FIND FIRST br-gds-dtl where
                        br-gds-dtl.doc-code = buf_trn-doc.doc-code AND
                        br-gds-dtl.artic = br-doc-line.artic AND
                        br-gds-dtl.prod-type = br-doc-line.prod-type AND
                        br-gds-dtl.prod-code = br-doc-line.prod-code AND
                        br-gds-dtl.prt-code = buf_gds-prt.node-code No-ERROR.
            if unresv > 0 or unresr > 0 then do:
                if (v-curr-r-b = 'base':U and  (br-gds-dtl.price-base <> b-gds-dtl.price-base))
                OR (v-curr-r-b = 'rubl':U and  (br-gds-dtl.price-rubl <> b-gds-dtl.price-rubl))
                then NEXT _docline.
                if
                b-gds-dtl.fact-qnty - cvpl = 0 AND
                br-gds-dtl.fact-qnty - cvpl = 0 AND
                ((v-curr-r-b = 'base':U and  b-gds-dtl.discnt-base <> br-gds-dtl.discnt-base)
                 OR
                 (v-curr-r-b = 'rubl':U and  b-gds-dtl.discnt-rubl <> br-gds-dtl.discnt-rubl)
                )
                 then do:
                    if cvpl > 1 then
                    assign
                    cvpl = cvpl - 1
                    unresv = unresv - 1
                    unresr = unresr - 1
                    b-temp-pl.new-fact-qnty = b-temp-pl.new-fact-qnty + 1
                    temp-pl.new-fact-qnty = temp-pl.new-fact-qnty + 1
                    .
                    else NEXT _docline.
                end.
                assign
                rdoc-line = recid (b-doc-line)
                rgds-dtl = recid(b-gds-dtl)
                r-qnty = - unresv
                r-b-code = ?
                r-pl-code = if b-temp-pl.pl-code = - 1 then ? else b-temp-pl.pl-code
                r-or-v = 'rs':U
                r-office = 'т':U
                from-menu = yes.
                if unresv > 0 then do:
                    run b-unres-proc in this-procedure (
                                      buffer buf_inkas
                                    , buffer buf_trn-doc
                                    , buffer buf_ret-doc
                                    , input  p-is-tpsi-obj
                                    , input yes) no-error.
                    if error-status:error then do:
                      undo _docline, return error.
                    end.
                end.
            end.
            if unresr > 0 then do:
                assign
                rdoc-line = recid (br-doc-line)
                rgds-dtl = recid(br-gds-dtl)
                r-qnty = - unresr
                r-b-code = ?
                r-doc-prts-qnty = ?
                r-pl-code = if temp-pl.pl-code = - 1 then ? else temp-pl.pl-code
                r-or-v = 'es':U
                r-office = 'т':U
                from-menu = yes.
                run b-unres-proc in this-procedure (
                                      buffer buf_inkas
                                    , buffer buf_trn-doc
                                    , buffer buf_ret-doc
                                    , input p-is-tpsi-obj
                                    , input yes) no-error.
                if error-status:error then do:
                  undo _docline, return error.
                end.
            end.
        end.
        if cvpl <> 0 then do:
            for each temp-pl,
                first ub.doc-pl where
                      ub.doc-pl.out-code = (if temp-pl.is-out = 1
                                            then br-gds-dtl.doc-code
                                            else b-gds-dtl.doc-code)
                  and ub.doc-pl.gds-code = b-goods.gds-code
                  and ub.doc-pl.pl-code = temp-pl.pl-code
             on error  undo _docline, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
             on stop   undo _docline, return error substitute( "&1. stop", vss-workfile )
             on endkey undo _docline, return error substitute( "&1. endkey", vss-workfile )
             :
              assign
              ub.doc-pl.cli-fact-qnty = temp-pl.new-fact-qnty * ub.doc-pl.cli-fact-qnty / ub.doc-pl.fact-qnty
              ub.doc-pl.fact-qnty = temp-pl.new-fact-qnty
              .
            end.
            assign
            tsall = (if v-curr-r-b = 'base':U
                      then (br-gds-dtl.fact-qnty * (br-gds-dtl.price-base - br-gds-dtl.discnt-base) -
                            b-gds-dtl.fact-qnty * (b-gds-dtl.price-base - b-gds-dtl.discnt-base))
                       else (br-gds-dtl.fact-qnty * (br-gds-dtl.price-rubl - br-gds-dtl.discnt-rubl) -
                            b-gds-dtl.fact-qnty * (b-gds-dtl.price-rubl - b-gds-dtl.discnt-rubl))
                     )
            b-gds-dtl.fact-qnty = b-gds-dtl.fact-qnty - cvpl
            br-gds-dtl.fact-qnty = br-gds-dtl.fact-qnty - cvpl
            br-doc-line.fact-qnty = br-doc-line.fact-qnty - cvpl
            b-doc-line.fact-qnty = b-doc-line.fact-qnty - cvpl
            qnty-compense = qnty-compense + cvpl
            qnty-compense-abs = qnty-compense-abs + abs(cvpl)
            no-error .
            if (v-curr-r-b = 'base':U and b-gds-dtl.discnt-base <> br-gds-dtl.discnt-base)
            OR (v-curr-r-b = 'rubl':U and b-gds-dtl.discnt-rubl <> br-gds-dtl.discnt-rubl)
            then do:
            if v-curr-r-b = 'base':U
            then do:
             assign
             br-gds-dtl.discnt-base = (if br-gds-dtl.fact-qnty <> 0
                                       then (br-gds-dtl.price-base - ( b-gds-dtl.fact-qnty * (b-gds-dtl.price-base - b-gds-dtl.discnt-base) +
                                                                                 tsall )  / br-gds-dtl.fact-qnty
                                            )
                                       else br-gds-dtl.discnt-base
                                       )
             b-gds-dtl.discnt-base = (if br-gds-dtl.fact-qnty = 0 and b-gds-dtl.fact-qnty <> 0
                                      then (b-gds-dtl.price-base -  ( br-gds-dtl.fact-qnty * (br-gds-dtl.price-base - br-gds-dtl.discnt-base) -
                                             tsall ) / b-gds-dtl.fact-qnty
                                           )
                                      else b-gds-dtl.discnt-base
                                      )
             br-gds-dtl.discnt-rubl = br-gds-dtl.discnt-base * (buf_trn-doc.base-rate / buf_trn-doc.base-scale)
             b-gds-dtl.discnt-rubl = b-gds-dtl.discnt-base * (buf_trn-doc.base-rate / buf_trn-doc.base-scale)
             .
            end.
            else do:
              assign
              br-gds-dtl.discnt-rubl = (if br-gds-dtl.fact-qnty <> 0
                                       then (br-gds-dtl.price-rubl -
                                                                    ( b-gds-dtl.fact-qnty * (b-gds-dtl.price-rubl - b-gds-dtl.discnt-rubl) +
                                                                    tsall )  / br-gds-dtl.fact-qnty
                                            )
                                       else br-gds-dtl.discnt-rubl
                                       )
             b-gds-dtl.discnt-rubl = (if br-gds-dtl.fact-qnty = 0 and b-gds-dtl.fact-qnty <> 0
                                      then (b-gds-dtl.price-rubl -
                                                                  ( br-gds-dtl.fact-qnty * (br-gds-dtl.price-rubl - br-gds-dtl.discnt-rubl) -
                                                                    tsall ) / b-gds-dtl.fact-qnty
                                            )
                                      else b-gds-dtl.discnt-rubl
                                      )
              br-gds-dtl.discnt-base = br-gds-dtl.discnt-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
              b-gds-dtl.discnt-base = b-gds-dtl.discnt-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
            end.
          end.
          release b-gds-dtl.
          release br-gds-dtl.
        end.
    end.
    if NOT cashplace AND can-find(first ub.doc-prts No-LOCK WHERE
                                        ub.doc-prts.gds-code = b-goods.gds-code AND
                                        ub.doc-prts.out-code = buf_ret-doc.doc-code) then do:
        FIND FIRST buf_gds-prt NO-LOCK WHERE
                 buf_gds-prt.upper-code = b-goods.prt-root NO-ERROR.
        assign
        cashparts = yes
        cvp = 0
        .
        for each temp-prts:
          delete temp-prts.
        end.
        for each b-doc-prts NO-LOCK WHERE
                 b-doc-prts.gds-code = b-goods.gds-code AND
                 b-doc-prts.out-code = buf_ret-doc.doc-code:
                 saled-by-parts-v = saled-by-parts-v + b-doc-prts.fact-qnty.
          find first brw-doc-prts no-lock where
                    brw-doc-prts.gds-code = b-goods.gds-code
               AND  brw-doc-prts.out-code = v-return-write-off-code
               AND  brw-doc-prts.b-code = b-doc-prts.b-code no-error .
          if available brw-doc-prts then do:
            saled-by-parts-rw = saled-by-parts-rw + brw-doc-prts.fact-qnty.
          end.
          create
          temp-prts.
          assign
          temp-prts.is-out = -1
          temp-prts.b-code = if b-doc-prts.b-code <> ?
                                then b-doc-prts.b-code
                                else -1
          temp-prts.doc-qnty = b-doc-prts.doc-qnty
          temp-prts.fact-qnty = b-doc-prts.fact-qnty - (if available brw-doc-prts
                                                        then brw-doc-prts.fact-qnty
                                                        else 0)
          temp-prts.rc = string(recid(b-doc-prts))
          temp-prts.twounit = IF lookup('2ед':U, buf_units.type) > 0 AND
                                 lookup('дро':U, buf_units.type) > 0 then yes
                                 else no
          .
        end.
        for each buf_doc-prts NO-LOCK WHERE
                 buf_doc-prts.gds-code = b-goods.gds-code AND
                 buf_doc-prts.out-code = buf_trn-doc.doc-code:
                 saled-by-parts-r = saled-by-parts-r + buf_doc-prts.fact-qnty.
          create
          temp-prts.
          assign
          temp-prts.is-out = 1
          temp-prts.b-code = if buf_doc-prts.b-code <> ?
                                then buf_doc-prts.b-code
                                else -1
          temp-prts.doc-qnty = buf_doc-prts.doc-qnty
          temp-prts.fact-qnty = buf_doc-prts.fact-qnty
          temp-prts.rc = string(recid(buf_doc-prts))
          temp-prts.twounit = IF lookup('2ед':U, buf_units.type) > 0 AND
                                 lookup('дро':U, buf_units.type) > 0 then yes
                                 else no
          .
        end.
        FOR EACH b-temp-prts WHERE
                 b-temp-prts.is-out = -1 AND
                 b-temp-prts.compensed = no use-index qnty:
            if b-temp-prts.twounit then do:
              FOR EACH temp-prts WHERE
                       temp-prts.is-out = 1 AND
                       temp-prts.b-code = b-temp-prts.b-code AND
                       temp-prts.fact-qnty = b-temp-prts.fact-qnty AND
                       temp-prts.compensed = no use-index qnty:
                  IF (temp-prts.fact-qnty = temp-prts.doc-qnty AND b-temp-prts.fact-qnty = b-temp-prts.doc-qnty) then
                  NEXT.
                  LEAVE.
              END.
            end.
            ELSE do:
              find first temp-prts WHERE
                         temp-prts.b-code = b-temp-prts.b-code AND
                         temp-prts.is-out = 1 No-ERROR.
            END.
            if not available temp-prts or
              (temp-prts.fact-qnty = temp-prts.doc-qnty AND b-temp-prts.fact-qnty = b-temp-prts.doc-qnty) then
            NEXT.
            assign
            res-parts = MAXIMUM(b-temp-prts.fact-qnty - b-temp-prts.doc-qnty , temp-prts.fact-qnty - temp-prts.doc-qnty)
            res-parts = if b-temp-prts.fact-qnty < res-parts then b-temp-prts.fact-qnty else res-parts
            res-parts = if temp-prts.fact-qnty < res-parts then temp-prts.fact-qnty else res-parts
            unresv = res-parts - (b-temp-prts.fact-qnty - b-temp-prts.doc-qnty)
            unresr = res-parts - (temp-prts.fact-qnty - temp-prts.doc-qnty)
            b-temp-prts.new-fact-qnty = b-temp-prts.fact-qnty - res-parts
            temp-prts.new-fact-qnty = temp-prts.fact-qnty - res-parts
            cvp = cvp + res-parts
            .
            IF b-temp-prts.twounit and res-parts > 0 then DO:
              assign
              temp-prts.compensed = yes
              .
            end.
            FIND FIRST b-gds-dtl where
                        b-gds-dtl.doc-code = buf_ret-doc.doc-code AND
                        b-gds-dtl.artic = b-doc-line.artic AND
                        b-gds-dtl.prod-type = b-doc-line.prod-type AND
                        b-gds-dtl.prod-code = b-doc-line.prod-code AND
                        b-gds-dtl.prt-code = buf_gds-prt.node-code No-ERROR.
            FIND FIRST br-gds-dtl where
                        br-gds-dtl.doc-code = buf_trn-doc.doc-code AND
                        br-gds-dtl.artic = br-doc-line.artic AND
                        br-gds-dtl.prod-type = br-doc-line.prod-type AND
                        br-gds-dtl.prod-code = br-doc-line.prod-code AND
                        br-gds-dtl.prt-code = buf_gds-prt.node-code  No-ERROR.
            if unresv > 0 or unresr > 0 then do:
                if
                b-gds-dtl.fact-qnty - cvp = 0 AND
                br-gds-dtl.fact-qnty - cvp = 0 AND
                (
                (v-curr-r-b = 'base':U and  b-gds-dtl.discnt-base <> br-gds-dtl.discnt-base)
                OR
                (v-curr-r-b = 'rubl':U and  b-gds-dtl.discnt-rubl <> br-gds-dtl.discnt-rubl)
                )
                then do:
                    if cvp > 1 AND b-temp-prts.twounit <> yes then
                    assign
                    cvp = cvp - 1
                    unresv = unresv - 1
                    unresr = unresr - 1
                    b-temp-prts.new-fact-qnty = b-temp-prts.new-fact-qnty + 1
                    temp-prts.new-fact-qnty = temp-prts.new-fact-qnty + 1
                    .
                    else do:
                      temp-prts.compensed = no.
                      NEXT _docline.
                    end.
                end.
                assign
                rdoc-line = recid (b-doc-line)
                rgds-dtl = recid(b-gds-dtl)
                r-qnty = - unresv
                r-b-code = if b-temp-prts.b-code = - 1 then ? else b-temp-prts.b-code
                r-doc-prts-qnty = (if lookup('2ед':U, buf_units.type) > 0 AND
                                      lookup('дро':U, buf_units.type) > 0
                                   then b-temp-prts.fact-qnty
                                   else ?
                                   )
                r-pl-code = ?
                r-or-v = 'rs':U
                r-office = 'т':U
                from-menu = yes.
                if unresv > 0 then do:
                    run b-unres-proc in this-procedure (
                                      buffer buf_inkas
                                    , buffer buf_trn-doc
                                    , buffer buf_ret-doc
                                    , input p-is-tpsi-obj
                                    , input yes) no-error.
                    if error-status:error then do:
                      undo _docline, return error.
                    end.
                end.
            end.
            if unresr > 0 then do:
                assign
                rdoc-line = recid (br-doc-line)
                rgds-dtl = recid(br-gds-dtl)
                r-qnty = - unresr
                r-b-code = if temp-prts.b-code = - 1 then ? else temp-prts.b-code
                r-doc-prts-qnty = (if lookup('2ед':U, buf_units.type) > 0 AND
                                      lookup('дро':U, buf_units.type) > 0
                                   then temp-prts.fact-qnty
                                   else ?
                                   )
                r-pl-code = ?
                r-or-v = 'es':U
                r-office = 'т':U
                from-menu = yes.
                run b-unres-proc in this-procedure (
                                      buffer buf_inkas
                                    , buffer buf_trn-doc
                                    , buffer buf_ret-doc
                                    , input p-is-tpsi-obj
                                    , input yes) no-error.
                if error-status:error then do:
                  undo _docline, return error.
                end.
            end.
        end.
        if cvp = 0 then NEXT _docline.
        for each temp-prts,
            first ub.doc-prts where
                  recid(ub.doc-prts) = integer(temp-prts.rc)
        on error  undo _docline, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo _docline, return error substitute( "&1. stop", vss-workfile )
        on endkey undo _docline, return error substitute( "&1. endkey", vss-workfile )
        :
          assign
          ub.doc-prts.fact-qnty = temp-prts.new-fact-qnty
          .
        end.
        assign
        tsall =  if v-curr-r-b = 'base':U
                 then  (br-gds-dtl.fact-qnty * (br-gds-dtl.price-base - br-gds-dtl.discnt-base) -
                        b-gds-dtl.fact-qnty * (b-gds-dtl.price-base - b-gds-dtl.discnt-base)
                       )
                 else   (br-gds-dtl.fact-qnty * (br-gds-dtl.price-rubl - br-gds-dtl.discnt-rubl) -
                        b-gds-dtl.fact-qnty * (b-gds-dtl.price-rubl - b-gds-dtl.discnt-rubl)
                       )
        b-gds-dtl.fact-qnty = b-gds-dtl.fact-qnty - cvp
        br-gds-dtl.fact-qnty = br-gds-dtl.fact-qnty - cvp
        br-doc-line.fact-qnty = br-doc-line.fact-qnty - cvp
        b-doc-line.fact-qnty = b-doc-line.fact-qnty - cvp
        qnty-compense = qnty-compense + cvp
        qnty-compense-abs = qnty-compense-abs + abs(cvp)
        no-error .
        if (v-curr-r-b = 'base':U and b-gds-dtl.discnt-base <> br-gds-dtl.discnt-base)
        OR (v-curr-r-b = 'rubl':U and b-gds-dtl.discnt-rubl <> br-gds-dtl.discnt-rubl)
        then do:
          if v-curr-r-b = 'base':U then do:
            assign
            br-gds-dtl.discnt-base = (if br-gds-dtl.fact-qnty <> 0
                                      then (br-gds-dtl.price-base - ( b-gds-dtl.fact-qnty * (b-gds-dtl.price-base - b-gds-dtl.discnt-base) +
                                                                   tsall )  / br-gds-dtl.fact-qnty )
                                      else br-gds-dtl.discnt-base )
            b-gds-dtl.discnt-base = (if br-gds-dtl.fact-qnty = 0 and b-gds-dtl.fact-qnty <> 0
                                      then (b-gds-dtl.price-base - ( br-gds-dtl.fact-qnty * (br-gds-dtl.price-base - br-gds-dtl.discnt-base) -
                                                                   tsall ) / b-gds-dtl.fact-qnty  )
                                      else b-gds-dtl.discnt-base )
            br-gds-dtl.discnt-rubl =  br-gds-dtl.discnt-BASE * (buf_trn-doc.base-rate / buf_trn-doc.base-scale)
            b-gds-dtl.discnt-rubl =   b-gds-dtl.discnt-BASE * (buf_trn-doc.base-rate / buf_trn-doc.base-scale)
            .
          end.
          else do:
            assign
            br-gds-dtl.discnt-rubl = (if br-gds-dtl.fact-qnty <> 0
                                      then (br-gds-dtl.price-rubl -
                                                                  ( b-gds-dtl.fact-qnty * (b-gds-dtl.price-rubl - b-gds-dtl.discnt-rubl) +
                                                                 tsall )  / br-gds-dtl.fact-qnty
                                                                   )
                                     else br-gds-dtl.discnt-rubl
                                     )
            b-gds-dtl.discnt-rubl = (if br-gds-dtl.fact-qnty = 0 and b-gds-dtl.fact-qnty <> 0
                                     then (b-gds-dtl.price-rubl -
                                                               ( br-gds-dtl.fact-qnty * (br-gds-dtl.price-rubl - br-gds-dtl.discnt-rubl) -
                                                             tsall ) / b-gds-dtl.fact-qnty
                                           )
                                    else b-gds-dtl.discnt-rubl
                                    )
            br-gds-dtl.discnt-base =  br-gds-dtl.discnt-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
            b-gds-dtl.discnt-base =   b-gds-dtl.discnt-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
            .
          end.
      end.
      release b-gds-dtl.
      release br-gds-dtl.
    end.
    IF lookup('2ед':U, buf_units.type) = 0 then do:
      for each b-gds-dtl where
               b-gds-dtl.doc-code = buf_ret-doc.doc-code AND
               b-gds-dtl.artic = b-doc-line.artic AND
               b-gds-dtl.prod-type = b-doc-line.prod-type AND
               b-gds-dtl.prod-code = b-doc-line.prod-code:
          find first br-gds-dtl where
                     br-gds-dtl.doc-code = buf_trn-doc.doc-code AND
                     br-gds-dtl.artic = b-gds-dtl.artic AND
                     br-gds-dtl.prod-type = b-gds-dtl.prod-type AND
                     br-gds-dtl.prod-code = b-gds-dtl.prod-code AND
                     br-gds-dtl.prt-code = b-gds-dtl.prt-code NO-ERROR.
          find first brw-gds-dtl where
                     brw-gds-dtl.doc-code = v-return-write-off-code AND
                     brw-gds-dtl.artic = b-gds-dtl.artic AND
                     brw-gds-dtl.prod-type = b-gds-dtl.prod-type AND
                     brw-gds-dtl.prod-code = b-gds-dtl.prod-code AND
                     brw-gds-dtl.prt-code = b-gds-dtl.prt-code NO-ERROR.
          IF AVAILABLE br-gds-dtl then do:
              if b-gds-dtl.doc-qnty = b-gds-dtl.fact-qnty AND br-gds-dtl.doc-qnty = br-gds-dtl.fact-qnty then NEXT _docline.
              if (v-curr-r-b = 'base':U and br-gds-dtl.price-base <> b-gds-dtl.price-base)
              OR (v-curr-r-b = 'rubl':U and br-gds-dtl.price-rubl <> b-gds-dtl.price-rubl)
              then NEXT _docline.
              assign
              cv = MAXIMUM(b-gds-dtl.fact-qnty - b-gds-dtl.doc-qnty - (if available brw-gds-dtl then brw-gds-dtl.fact-qnty else 0)
                         , br-gds-dtl.fact-qnty - br-gds-dtl.doc-qnty)
              cv = if b-gds-dtl.fact-qnty < cv then b-gds-dtl.fact-qnty else cv
              cv = if (br-gds-dtl.fact-qnty  - (if available brw-gds-dtl then brw-gds-dtl.fact-qnty else 0)) < cv
                   then br-gds-dtl.fact-qnty
                   else cv
              cv = MINIMUM(cv, old-doc-line-fact-qnty-r - (saled-by-place-r + saled-by-parts-r))
              cv = MINIMUM(cv, old-doc-line-fact-qnty-v - (saled-by-place-v + saled-by-parts-v) -
                               (old-doc-line-fact-qnty-rw - (saled-by-place-rw + saled-by-parts-rw))
                           )
              unresv = cv - (b-gds-dtl.fact-qnty - b-gds-dtl.doc-qnty)
              unresr = cv - (br-gds-dtl.fact-qnty - br-gds-dtl.doc-qnty)
              .
              if
              b-gds-dtl.fact-qnty - cv = 0 AND
              br-gds-dtl.fact-qnty - cv = 0 AND
              ((v-curr-r-b = 'base':U and b-gds-dtl.discnt-base <> br-gds-dtl.discnt-base)
              OR
               (v-curr-r-b = 'rubl':U and b-gds-dtl.discnt-rubl <> br-gds-dtl.discnt-rubl)
              )
               then do:
                  if cv > 1 then
                  assign
                  cv = cv - 1
                  unresv = unresv - 1
                  unresr = unresr - 1
                  .
                  else NEXT _docline.
              end.
              if unresv > 0 then do:
                  assign
                  rdoc-line = recid (b-doc-line)
                  rgds-dtl = recid(b-gds-dtl)
                  r-qnty =  - unresv
                  r-b-code = ?
                  r-doc-prts-qnty = ?
                  r-or-v = 'rs':U
                  r-office = 'т':U
                  from-menu = yes.
                  run b-unres-proc in this-procedure (
                                        buffer buf_inkas
                                      , buffer buf_trn-doc
                                      , buffer buf_ret-doc
                                      , input p-is-tpsi-obj
                                      , input yes) no-error.
                  if error-status:error then do:
                    undo _docline, return error.
                  end.
              end.
              if unresr > 0 then do:
                  assign
                  rdoc-line = recid (br-doc-line)
                  rgds-dtl = recid(br-gds-dtl)
                  r-qnty =  - unresr
                  r-b-code = ?
                  r-doc-prts-qnty = ?
                  r-or-v = 'es':U
                  r-office = 'т':U
                  from-menu = yes.
                  run b-unres-proc in this-procedure (
                                        buffer buf_inkas
                                      , buffer buf_trn-doc
                                      , buffer buf_ret-doc
                                      , input p-is-tpsi-obj
                                      , input yes) no-error.
                  if error-status:error then do:
                    undo _docline, return error.
                  end.
              end.
              assign
              tsall = (if v-curr-r-b = 'base':U
                       then (br-gds-dtl.fact-qnty * (br-gds-dtl.price-base - br-gds-dtl.discnt-base) -
                             b-gds-dtl.fact-qnty * (b-gds-dtl.price-base - b-gds-dtl.discnt-base))
                       else (br-gds-dtl.fact-qnty * (br-gds-dtl.price-rubl - br-gds-dtl.discnt-rubl) -
                             b-gds-dtl.fact-qnty * (b-gds-dtl.price-rubl - b-gds-dtl.discnt-rubl))
                       )
              b-gds-dtl.fact-qnty = b-gds-dtl.fact-qnty - cv
              br-gds-dtl.fact-qnty = br-gds-dtl.fact-qnty - cv
              br-doc-line.fact-qnty = br-doc-line.fact-qnty - cv
              b-doc-line.fact-qnty = b-doc-line.fact-qnty - cv
              qnty-compense = qnty-compense + cv
              qnty-compense-abs = qnty-compense-abs + abs(cv)
              .
              if (v-curr-r-b = 'base':U and b-gds-dtl.discnt-base <> br-gds-dtl.discnt-base)
              OR (v-curr-r-b = 'rubl':U and b-gds-dtl.discnt-rubl <> br-gds-dtl.discnt-rubl)
                then do:
              if v-curr-r-b = 'base':U then do:
                assign
                br-gds-dtl.discnt-base = (if br-gds-dtl.fact-qnty <> 0
                                          then (br-gds-dtl.price-base - ( b-gds-dtl.fact-qnty * (b-gds-dtl.price-base - b-gds-dtl.discnt-base) +
                                                                         tsall )  / br-gds-dtl.fact-qnty )
                                          else br-gds-dtl.discnt-base )
                br-gds-dtl.discnt-rubl = br-gds-dtl.discnt-base * (buf_trn-doc.base-rate / buf_trn-doc.base-scale )
                b-gds-dtl.discnt-rubl =  b-gds-dtl.discnt-base * (buf_trn-doc.base-rate / buf_trn-doc.base-scale)
                .
              end.
              else do:
                assign
                br-gds-dtl.discnt-rubl = (if br-gds-dtl.fact-qnty <> 0
                                          then (br-gds-dtl.price-rubl - ( b-gds-dtl.fact-qnty * (b-gds-dtl.price-rubl - b-gds-dtl.discnt-rubl) +
                                                                        tsall )  / br-gds-dtl.fact-qnty )
                                          else br-gds-dtl.discnt-rubl )
                b-gds-dtl.discnt-rubl = (if br-gds-dtl.fact-qnty = 0 and b-gds-dtl.fact-qnty <> 0
                                         then (b-gds-dtl.price-rubl -  ( br-gds-dtl.fact-qnty * (br-gds-dtl.price-rubl - br-gds-dtl.discnt-rubl) -
                                                                        tsall ) / b-gds-dtl.fact-qnty )
                                        else b-gds-dtl.discnt-rubl)
                br-gds-dtl.discnt-base = br-gds-dtl.discnt-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
                b-gds-dtl.discnt-base =  b-gds-dtl.discnt-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
                .
              end.
            end.
          end.
      end.
    end.
    if is-gas(b-goods.gds-code) then v-gas-compensed = true .
end.
FIND FIRST b-doc where b-doc.doc-code = buf_trn-doc.doc-code No-ERROR.
assign
b-doc.fact-qnty = b-doc.fact-qnty - qnty-compense.
FIND FIRST b-doc where b-doc.doc-code = buf_ret-doc.doc-code No-ERROR.
if available b-doc then do:
  assign
  b-doc.fact-qnty = b-doc.fact-qnty - qnty-compense
  .
end.
if qnty-compense-abs <> 0 then
note-compense = chr(10) + "Проведено компенсирование расхода/возврата".
run waitfram-hide in this-procedure .
if p-auto = 0 then do:
  run UI-on in p-parent-handle.
  run ui-2 in p-parent-handle.
end.
END PROCEDURE.
PROCEDURE INKAS-CLOSING:
define input parameter p-back-date as logical no-undo .
define input parameter p-is-inquiry as logical no-undo .
define parameter buffer locked_inkas for ub.inkas.
define variable for-netto as  decimal no-undo.
define variable for-write-off as  decimal no-undo.
define variable ps-where-rus as character no-undo .
define variable v-rec-id as recid no-undo .
define variable line-out as integer no-undo.
define variable line-ret as integer no-undo.
define variable dtl-out as integer no-undo.
define variable dtl-ret as integer no-undo.
define variable gds-amount  as integer .
define variable chk-amount  as integer .
define variable nf-gds-amount  as integer .
define variable nf-chk-amount  as integer .
define variable varminus-parts as logical   no-undo .
define variable varminus-parts-type as character no-undo .
define variable v-sale-sum as decimal no-undo .
define variable v-discnt-sum as decimal no-undo .
define variable v-curr-tot-dtl  as integer no-undo .
define variable v-curr-tot-lines as integer no-undo .
define variable v-ps-label as character no-undo .
define variable v-note-compense as character no-undo .
define variable v-exch-rate as decimal no-undo .
define variable v-dont-touch as logical no-undo .
define variable v-doc-ii as integer no-undo .
define variable v-chr-office-ii as integer no-undo .
define variable v-docs-sum as character no-undo .
define variable current-netto as decimal no-undo .
define variable current-write-off as decimal no-undo .
define variable varchip-code as integer   no-undo .
define variable varchip-code2 as integer   no-undo .
define variable v-gds-amount as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-attr-value as character no-undo .
define variable v-type as character no-undo .
define variable v-run-tpsi-line as logical no-undo .
define variable v-is-petrol as logical   no-undo .
define variable v-is-pieces as logical   no-undo .
define variable chk-prs  as   logical no-undo.
define variable v-param-type as character no-undo .
define variable v-value-character as date no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-tth as handle no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_goods for ub.goods.
define buffer buf_sale-doc for ub.sale-doc.
define buffer locked_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer upd_doc-line for ub.doc-line.
define buffer buf_gds-dtl  for ub.gds-dtl.
define buffer buf-in for ub.trn-doc.
define buffer buf_chk-doc for ub.chk-doc .
define buffer buf_inkas-pay for ub.inkas-pay.
define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.
define buffer buf_doc-fbr-gds for ub.doc-fbr-gds .
_main:
DO ON ERROR undo _main, return error:
    run get-inkas-ps in this-procedure (
                                        buffer locked_inkas
                                      , output chk-amount
                                      , output gds-amount
                                      , output line-out
                                      , output dtl-out
                                      , output line-ret
                                      , output dtl-ret
                                      , output nf-chk-amount
                                      , output nf-gds-amount
                                      , output ps-where-rus
                                      ).
  run adm/shattri.p (
      input "get":U
      ,input ''
      ,input 0
      ,input 'nakl-glob':U
      ,input 'chk-prs':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output chk-prs
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  delete object v-tth no-error.
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = locked_inkas.inkas-code
       and buf_sale-doc.order > 0
  by buf_sale-doc.order
  :
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Считаем итоги по док-ту &1 (&2 &3) ...", buf_sale-doc.doc-code, entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ), buf_sale-doc.chr-office)                                       ).
    find first locked_trn-doc where
              locked_trn-doc.doc-code = buf_sale-doc.doc-code.
    if chk-prs = yes then do:
      find first buf_clients where buf_clients.obj-type = 'чел':U          and
                                  buf_clients.obj-code = locked_trn-doc.boss no-lock no-error.
      if not available buf_clients then do:
        undo _main, return error substitute("Не указан или неправильный менеджер в &1", locked_trn-doc.doc-code).
      end.
      find first buf_clients where buf_clients.obj-type = 'чел':U          and
                                  buf_clients.obj-code = locked_trn-doc.agnt no-lock no-error.
      if not available buf_clients then do:
          undo _main, return error substitute("Не указан или неправильный исполнитель в &1", locked_trn-doc.doc-code).
      end.
    end.
    run gbl/calc-trn.p ( input parparentproc, input recid(locked_trn-doc)).
    if buf_sale-doc.doc-kind = 'trf':U or buf_sale-doc.doc-kind = 'vir':U
        or buf_sale-doc.doc-kind = 'none' or ( buf_sale-doc.doc-kind = 'swo':U) then do:
    end.
    else do:
      if buf_sale-doc.in-inkas then
      assign
      current-netto = if v-curr-r-b = 'rubl':U
                  then locked_trn-doc.tot-sale - locked_trn-doc.discnt-rubl
                  else locked_trn-doc.tot-fact - locked_trn-doc.tot-calc
      for-netto = for-netto + current-netto * buf_sale-doc.dir
      v-docs-sum = v-docs-sum + (if v-docs-sum = '':U then '':U else chr(10)) +
                            substitute("&1 = &2"
                              , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                              , current-netto
                            ).
            .
      if buf_sale-doc.doc-type = 'спи':U then do:
      assign
      current-write-off = if v-curr-r-b = 'rubl':U
                  then locked_trn-doc.tot-sale - locked_trn-doc.discnt-rubl
                  else locked_trn-doc.tot-fact - locked_trn-doc.tot-calc
      for-write-off = for-write-off + current-write-off
      v-docs-sum = v-docs-sum + (if v-docs-sum = '':U then '':U else chr(10)) +
                            substitute("&1 = &2"
                              , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                              , current-write-off
                            ).
    end.
    end.
  end.
  if abs(locked_inkas.netto - (for-netto  - (locked_inkas.sub-discnt - for-write-off))) > 0.015
  then do:
    undo _main, return error substitute("Невозможно закрыть продажу&1" +
                            "Несовпадение суммы нетто по продаже и накладным &2&1" +
                            "Сумма выручки по продаже - &3&1" +
                            "Сумма списания - &4&1" +
                           "Суммы по накладным (с учетом направления движения товара) - &5:&1&6"
                          , chr(10)
                          , abs(locked_inkas.netto - (for-netto - (locked_inkas.sub-discnt - for-write-off)))
                          , locked_inkas.netto
                          , locked_inkas.sub-discnt
                          , (for-netto  - (locked_inkas.sub-discnt - for-write-off))
                          , v-docs-sum
                          ).
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  locked_inkas.PS = ''.
  _v-doc-ii:
    do v-doc-ii = 1 to num-entries('es,rs,rwo,trf,swo,ngs,rgs,vir':U)
    on error undo _main, return error:
      do v-chr-office-ii = 1 to 2
      on error undo _main, return error:
        find first buf_sale-doc where
                buf_sale-doc.inkas-code = locked_inkas.inkas-code
            and  buf_sale-doc.order = v-doc-ii * 100  + (if v-chr-office-ii = 1 then 0 else 5) no-error .
        if available buf_sale-doc  then do:
          find first locked_trn-doc where locked_trn-doc.doc-code = buf_sale-doc.doc-code.
          if not (buf_sale-doc.doc-kind = 'es':U
                 and
                 buf_sale-doc.chr-office = 'т':U
                 )
          then do:
            if (if v-curr-r-b = 'base':U
              then locked_trn-doc.tot-fact
              else  locked_trn-doc.tot-sale) = 0
            and not can-find(first ub.doc-line no-lock where ub.doc-line.doc-code = locked_trn-doc.doc-code) then do:
              assign
              locked_trn-doc.status_ = 'накл':U.
              run str/del-doc.p (
                  input  parparentproc,
                  input  locked_trn-doc.doc-code,
                  input  g#db-num,
                  input  "del-doc.err",
                  input  ?,
                  input  ?,
                  input  g#userid,
                  input  '0',
                  input  varchip-code,
                  output varchip-code2)
                  no-error.
              if error-status :error then do:
                  undo _main, return error  substitute("Ошибка при удалении ПУСТОГО документа &1 &2 &3 по продаже &4&5&6&5&7" +
                                        "Закрытие продажи невозможнo !"
                                        , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                                        , buf_sale-doc.chr-office
                                        , buf_sale-doc.doc-code
                                        , p-inkas-code
                                        ,chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
              end.
              delete buf_sale-doc.
            end.
          end.
        end.
        if available buf_sale-doc  then do:
          find first locked_trn-doc where locked_trn-doc.doc-code = buf_sale-doc.doc-code.
          if not (buf_sale-doc.doc-kind = 'es':U
                  and
                  buf_sale-doc.chr-office = 'т':U)
          then do:
            if (if v-curr-r-b = 'base':U
              then locked_trn-doc.tot-fact
              else  locked_trn-doc.tot-sale) = 0
            and not can-find(first doc-line no-lock where doc-line.doc-code = locked_trn-doc.doc-code) then do:
              assign
              locked_trn-doc.status_ = 'накл':U.
              run str/del-doc.p (
                  input  parparentproc,
                  input  locked_trn-doc.doc-code,
                  input  g#db-num,
                  input  "del-doc.err",
                  input  ?,
                  input  ?,
                  input  g#userid,
                  input  '0',
                  input  varchip-code,
                  output varchip-code2)
                  no-error.
              if error-status :error then do:
                  undo _main, return error  substitute("Ошибка при удалении ПУСТОГО документа &1 &2 &3 по продаже &4&5&6&5&7" +
                                        "Закрытие продажи невозможнo !"
                                        , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                                        , buf_sale-doc.chr-office
                                        , buf_sale-doc.doc-code
                                        , p-inkas-code
                                        ,chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
              end.
              delete buf_sale-doc.
            end.
          end.
        end.
        if not available buf_sale-doc then do:
                assign
          v-curr-tot-dtl = 0
          v-curr-tot-lines = 0
          v-ps-label = entry (lookup (entry(v-doc-ii, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U), 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
          v-sale-sum = 0
          v-discnt-sum = 0
          .
        end.
        else do:
                    for each buf_doc-line no-lock where
                  buf_Doc-line.doc-code = buf_sale-doc.doc-code
          on error undo _main, return error :
            find first goods no-lock where goods.artic = buf_doc-line.artic
                                       and goods.prod-type = buf_doc-line.prod-type
                                       and goods.prod-code = buf_doc-line.prod-code
                                       .
            RUN gds-attr-value (
                                INPUT goods.gds-code,
                                INPUT 'mark-type':U,
                                OUTPUT v-attr-value,
                                OUTPUT v-type
                                ).
            if v-attr-value > ""
            and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType(v-attr-value)
            and buf_doc-line.doc-qnty <> buf_doc-line.fact-qnty
            and (buf_sale-doc.doc-kind = 'rs':U or buf_sale-doc.doc-kind = 'es':U)
            then do:
              find first upd_doc-line exclusive-lock where rowid(upd_doc-line) = rowid(buf_doc-line) .
              FIND FIRST gds-prt NO-LOCK WHERE
                        gds-prt.upper-code = goods.prt-root NO-ERROR.
              if buf_sale-doc.doc-kind = 'es':U
              then do :
                run RSRV-line in this-procedure (
                      input 1,
                      input no,
                      input no ,
                      input no,
                      input no,
                      input "",
                      input no,
                      input no,
                      input yes,
                      input goods.gds-code,
                      input (if available gds-prt then gds-prt.node-code else ?),
                      output v-run-tpsi-line,
                      buffer upd_doc-line,
                      buffer buf_trn-doc,
                      buffer buf_sale-doc
                      ) no-error.
              end .
              else do :
                run RSRV-line in this-procedure (
                      input -1,
                      input no,
                      input no ,
                      input no,
                      input no,
                      input "",
                      input no,
                      input no,
                      input yes,
                      input goods.gds-code,
                      input (if available gds-prt then gds-prt.node-code else ?),
                      output v-run-tpsi-line,
                      buffer upd_doc-line,
                      buffer buf_ret-doc,
                      buffer buf_sale-doc
                      ) no-error.
              end .
              if error-status:error
              then do :
                                run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("&1 (&2) Не все товары зарезервированы... &3 &4&5"                                         , buf_sale-doc.doc-code                                                                   , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )                                                                   , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code                                         )                                       ).
                undo _main, return error.
              end .
              release upd_doc-line no-error .
            end .
            else do :
            if buf_sale-doc.doc-kind = 'es':U
            then do :
              find first buf_doc-fbr-gds no-lock where buf_doc-fbr-gds.out-code = buf_Doc-line.doc-code
                                                   and buf_doc-fbr-gds.gds-code = goods.gds-code
                                                   no-error.
            end.
            if buf_sale-doc.doc-kind = 'rs':U
            then do :
              find first buf_doc-fbr-gds no-lock where buf_doc-fbr-gds.out-code = replace(buf_Doc-line.doc-code, "=", "-")
                                                   and buf_doc-fbr-gds.gds-code = goods.gds-code
                                                   no-error.
            end.
            if available buf_doc-fbr-gds
            then do :
              if buf_doc-fbr-gds.fact-qnty >= 0
              then do :
                if buf_doc-line.doc-qnty <> buf_doc-fbr-gds.fact-qnty
                and buf_doc-line.doc-qnty <> buf_doc-line.fact-qnty
                and  buf_sale-doc.doc-kind = 'es':U then do:
                                    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("&1 (&2) Не все товары производства зарезервированы... &3 &4&5"                                           , buf_sale-doc.doc-code                                                                     , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )                                                                     , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code                                           )                                       ).
                  undo _main, return error.
                end.
                if buf_doc-line.doc-qnty <> 0
                and buf_doc-line.doc-qnty <> buf_doc-line.fact-qnty
                and buf_sale-doc.doc-kind = 'rs':U then do :
                                    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("&1 (&2) Возврат в производстве не резервируем! &3 &4&5"                                           , buf_sale-doc.doc-code                                                                     , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )                                                                     , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code                                           )                                       ).
                  undo _main, return error.
                end.
              end.
              else do :
                if buf_doc-line.doc-qnty <> abs(buf_doc-fbr-gds.fact-qnty)
                and buf_doc-line.doc-qnty <> buf_doc-line.fact-qnty
                and  buf_sale-doc.doc-kind = 'rs':U then do:
                                    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("&1 (&2) Не все товары производства зарезервированы... &3 &4&5"                                           , buf_sale-doc.doc-code                                                                     , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )                                                                     , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code                                           )                                       ).
                  undo _main, return error.
                end.
                if buf_doc-line.doc-qnty <> 0
                and buf_doc-line.doc-qnty <> buf_doc-line.fact-qnty
                and buf_sale-doc.doc-kind = 'es':U then do :
                                    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("&1 (&2) Возврат в производстве не резервируем! &3 &4&5"                                           , buf_sale-doc.doc-code                                                                     , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )                                                                     , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code                                           )                                       ).
                  undo _main, return error.
                end.
              end.
            end .
            else do :
              if buf_doc-line.doc-qnty <> buf_doc-line.fact-qnty and  buf_sale-doc.doc-kind <> 'rwo':U then do:
                                run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("&1 (&2) Не все товары зарезервированы... &3 &4&5"                                         , buf_sale-doc.doc-code                                                                   , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )                                                                   , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code                                         )                                       ).
                undo _main, return error.
              end.
            end.
            end .
          end.
          for each buf_gds-dtl no-lock where
                  buf_gds-dtl.doc-code = buf_sale-doc.doc-code
          on error undo _main, return error :
            find first goods no-lock where goods.artic = buf_gds-dtl.artic
                                       and goods.prod-type = buf_gds-dtl.prod-type
                                       and goods.prod-code = buf_gds-dtl.prod-code
                                       .
            if buf_sale-doc.doc-kind = 'es':U
            then do :
              find first buf_doc-fbr-gds no-lock where buf_doc-fbr-gds.out-code = buf_gds-dtl.doc-code
                                                   and buf_doc-fbr-gds.gds-code = goods.gds-code
                                                   no-error.
            end.
            if buf_sale-doc.doc-kind = 'rs':U
            then do :
              find first buf_doc-fbr-gds no-lock where buf_doc-fbr-gds.out-code = replace(buf_gds-dtl.doc-code, "=", "-")
                                                   and buf_doc-fbr-gds.gds-code = goods.gds-code
                                                   no-error.
            end.
            if available buf_doc-fbr-gds
            then do :
              if buf_doc-fbr-gds.fact-qnty >= 0
              then do :
                if buf_gds-dtl.doc-qnty <> buf_doc-fbr-gds.fact-qnty
                and buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty
                and buf_sale-doc.doc-kind = 'es':U then do:
                                    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("&1 (&2) Не все товары производства зарезервированы... &3 &4&5"                                           , buf_sale-doc.doc-code                                                                     , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )                                                                     , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code                                           )                                       ).
                  undo _main, return error.
                end.
                if buf_gds-dtl.doc-qnty <> 0
                and buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty
                and buf_sale-doc.doc-kind = 'rs':U then do :
                                    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("&1 (&2) Возврат в производстве не резервируем! &3 &4&5"                                           , buf_sale-doc.doc-code                                                                     , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )                                                                     , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code                                           )                                       ).
                  undo _main, return error.
                end.
              end.
              else do :
                if buf_gds-dtl.doc-qnty <> abs(buf_doc-fbr-gds.fact-qnty)
                and buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty
                and buf_sale-doc.doc-kind = 'rs':U then do:
                                    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("&1 (&2) Не все товары производства зарезервированы... &3 &4&5"                                           , buf_sale-doc.doc-code                                                                     , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )                                                                     , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code                                           )                                       ).
                  undo _main, return error.
                end.
                if buf_gds-dtl.doc-qnty <> 0
                and buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty
                and buf_sale-doc.doc-kind = 'es':U then do :
                                    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("&1 (&2) Возврат в производстве не резервируем! &3 &4&5"                                           , buf_sale-doc.doc-code                                                                     , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )                                                                     , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code                                           )                                       ).
                  undo _main, return error.
                end.
              end.
            end .
            else do :
              if buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty  and  buf_sale-doc.doc-kind <> 'rwo':U then do:
                                run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("&1 (&2) Не все товары зарезервированы...  &3 &4&5"                                         , buf_sale-doc.doc-code                                         , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )                                         , buf_gds-dtl.artic, buf_gds-dtl.prod-type, buf_gds-dtl.prod-code                                         )                                       ).
                undo _main, return error.
              end.
            end.
          end.
                    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Закрываем &1 (&2 &3) ...", buf_sale-doc.doc-code, entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ), buf_sale-doc.chr-office)                                       ).
          find first locked_trn-doc where locked_trn-doc.doc-code = buf_sale-doc.doc-code.
          if not v-dont-touch then
          assign
          v-exch-rate = locked_trn-doc.base-rate / locked_trn-doc.base-scale
          v-dont-touch = yes
          .
        end.
        if p-is-inquiry then do:
          NEXT _v-doc-ii.
        end.
        if available buf_sale-doc
        and buf_sale-doc.doc-kind = 'es':U then do:
          assign
          v-curr-tot-dtl = dtl-out
          v-curr-tot-lines = line-out
          v-ps-label = substitute("Продажа &1", buf_sale-doc.chr-office)
          v-note-compense = note-compense
          v-sale-sum = (if v-curr-r-b = 'base':U
                        then locked_trn-doc.tot-fact
                        else  locked_trn-doc.tot-sale)
          v-discnt-sum = (if v-curr-r-b = 'base':U
                          then locked_trn-doc.tot-calc
                          else locked_trn-doc.discnt-rubl)
          .
          if buf_sale-doc.chr-office = 'т':U then do:
                run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "Преобразование товара на ответственном хранении в выкупной..."                                       ).
            run str/parts-pc.p (
                          input parparentproc
                          ,input buf_sale-doc.doc-code
                          ,integer('3':U)
                          ,integer('1':U)
                          ,input 'факт':U
                          ,input locked_inkas.fact-date
                          ,input v-time
                          ,input locked_inkas.shift-date
                          ,input locked_inkas.shift-num
                          ,input locked_inkas.shift-name
                          ) no-error .
            if error-status:error then do:
              undo _Main, return error  substitute("Невозможно закрыть продажу&1" +
                                    "не удается преобразовать товар на ответственном хранении в выкупной:&1&2 &3"
                                  ,  chr(10)
                                  , error-status:get-message(1)
                                  , return-value
                                  ).
            end.
            define buffer dop_trn-doc for ub.trn-doc.
            find first dop_trn-doc no-lock where
                      dop_trn-doc.out-code = locked_inkas.inkas-code
                  and dop_trn-doc.ext-doc-type = 'pc':U no-error.
            if available dop_trn-doc then do:
              run saledoc-create  in this-procedure (
                                                      input locked_inkas.inkas-code
                                                      ,input locked_inkas.host-code
                                                      ,input locked_inkas.obj-type
                                                      ,input locked_inkas.obj-code
                                                      ,input 'pc':U
                                                      ,input no
                                                      ,input no
                                                      ,input '':U
                                                      ,input '':U
                                                      ,input 0
                                                      ,buffer dop_trn-doc ) no-error .
              if error-status:error then do:
                undo _main, return error substitute("Ошибка записи данных автодокумента вида &5 для продажи &4 в таблицу связанных док-тов по продаже:&1&2 &3"
                                              , chr(10)
                                              , error-status:get-message(1)
                                              , return-value
                                              , locked_inkas.inkas-code
                                              , 'pc':U
                                              ).
              end.
            end.
          end.
        end.
        if available buf_sale-doc
        and not (buf_sale-doc.doc-kind = 'es':U
                and
                buf_sale-doc.chr-office = 'т':U)
        then do:
          if (if v-curr-r-b = 'base':U
            then locked_trn-doc.tot-fact
            else  locked_trn-doc.tot-sale) = 0
          and not can-find(first doc-line no-lock where doc-line.doc-code = locked_trn-doc.doc-code) then do:
            assign
            locked_trn-doc.status_ = 'накл':U.
            run str/del-doc.p (
                input  parparentproc,
                input  locked_trn-doc.doc-code,
                input  g#db-num,
                input  "del-doc.err",
                input  ?,
                input  ?,
                input  g#userid,
                input  '0',
                input  varchip-code,
                output varchip-code2)
                no-error.
            if error-status :error then do:
                undo _main, return error  substitute("Ошибка при удалении ПУСТОГО документа &1 &2 &3 по продаже &4&5&6&5&7" +
                                      "Закрытие продажи невозможнo !"
                                      , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                                      , buf_sale-doc.chr-office
                                      , buf_sale-doc.doc-code
                                      , p-inkas-code
                                      ,chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      ).
            end.
            delete buf_sale-doc.
          end.
        end.
        if available buf_sale-doc
        and buf_sale-doc.doc-kind = 'rs':U then do:
          assign
          v-sale-sum = (if v-curr-r-b = 'base':U
                        then locked_trn-doc.tot-fact
                        else  locked_trn-doc.tot-sale)
          v-discnt-sum = (if v-curr-r-b = 'base':U
                          then locked_trn-doc.tot-calc
                          else locked_trn-doc.discnt-rubl)
          v-curr-tot-dtl = dtl-ret
          v-curr-tot-lines = line-ret
          v-ps-label = substitute("Возврат &1", buf_sale-doc.chr-office)
          v-note-compense = note-compense
          .
        end.
        if available buf_sale-doc
        and buf_sale-doc.doc-kind = 'rwo':U then do:
          ASSIGN
          FROM-MENU = yes
          rdoc-line = ?
          rgds-dtl = ?
          r-or-v = 'rwo':U
          r-office = buf_sale-doc.chr-office
          r-qnty = ?
          r-b-code = ?
          r-pl-code = ?
          r-doc-prts-qnty = ?
          .
          run b-res-proc in this-procedure (
                                              buffer buf_Inkas
                                            , buffer buf_trn-doc
                                            , buffer buf_ret-doc
                                            , input yes
                                            , input auto-close
                                            , input yes
                                            , input rest-dish
                                            , input v-fbr-income-doc-code
                                            , input p-is-tpsi-obj
                                            , input rest-tpsi) no-error.
          if error-status:error or return-value = "error" then do:
            undo _main, return error  substitute("Ошибка при попытке резервирования в акте списания товаров, возвращенных по данной продажи&1" +
                                    "Закрытие продажи невозможнo !"
                                    ,chr(10)).
          end.
              run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Считаем итоги по док-ту &1 (&2 &3) ...", buf_sale-doc.doc-code, buf_sale-doc.chr-office, entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ))                                       ).
          run gbl/calc-trn.p ( input parparentproc, input recid(locked_trn-doc)).
          assign
          v-ps-label = substitute("Списание по возврату &1", buf_sale-doc.chr-office)
          v-note-compense = '':U
          .
        end.
        if available buf_sale-doc then do:
            if buf_sale-doc.doc-kind = 'trf':U then do:
          assign
          v-ps-label = "Техпролив"
              v-note-compense = '':U.
            end.
            if buf_sale-doc.doc-kind = 'vir':U then do:
              assign
              v-ps-label = "Перемещение в виртуальный резервуар"
              v-note-compense = '':U.
            end.
        end.
        if available buf_sale-doc
        and buf_sale-doc.doc-kind = 'swo':U then do:
          assign
          v-ps-label = substitute("Списание &1", buf_sale-doc.chr-office)
          v-note-compense = '':U
          .
        end.
        if available buf_sale-doc then  do:
          assign
          locked_trn-doc.discnt-pc =  ( if locked_trn-doc.print-rubl
                                        then ( locked_trn-doc.discnt-rubl * 100 / locked_trn-doc.tot-sale )
                                        else ( locked_trn-doc.tot-calc * 100 / locked_trn-doc.tot-fact ) ).
          assign
          locked_trn-doc.status_ = 'накл':U.
          assign
          locked_trn-doc.is-back-date = p-back-date
          locked_trn-doc.fact-date = locked_inkas.fact-date
          locked_trn-doc.shift-date = locked_inkas.shift-date
          locked_trn-doc.flag_ = yes
          locked_trn-doc.status_ = 'факт':U
          locked_trn-doc.fact-time = v-time
          locked_trn-doc.PS = substitute("&1 &8 за &2 Количество: &3&4" +
                                          "Сумма &5 Скид. &6  Нетто &7&4"
                              ,(if locked_trn-doc.office
                                then "@УСЛУГИ."
                                else "@ТОВАРЫ.")
                              , string( locked_trn-doc.doc-date, "99/99/9999" )
                              , string( locked_trn-doc.fact-qnty , "->>,>>>,>>>,>>9.<<<" )
                              , chr(10)
                              , string( if v-curr-r-b = 'rubl':U
                                then locked_trn-doc.tot-sale
                                else locked_trn-doc.tot-fact, "->>,>>>,>>>,>>9.99" )
                              , string ( if v-curr-r-b = 'rubl':U
                                then locked_trn-doc.discnt-rubl
                                else locked_trn-doc.tot-calc , "->>,>>>,>>>,>>9.99")
                              ,  string ( if v-curr-r-b = 'rubl':U
                                          then  (locked_trn-doc.tot-sale - locked_trn-doc.discnt-rubl)
                                          else  (locked_trn-doc.tot-fact - locked_trn-doc.tot-calc), "->>,>>>,>>>,>>9.99" )
                              , v-ps-label
                              )
                              + substitute(" товаров &1  признаков &2&3&4"
                                          , buf_sale-doc.tot-lines
                                          , buf_sale-doc.tot-dtl
                                          , chr(10)
                                          , v-note-compense)
          locked_trn-doc.creid = g#userid
          .
          assign
          locked_inkas.PS = locked_inkas.PS + (if not (buf_sale-doc.doc-kind = 'es':U
                                                       and
                                                       buf_sale-doc.chr-office = 'т':U)
                                              then chr(10)
                                              else '':U) +
                            if v-curr-r-b = 'base':U
                            then  substitute( "&1 : сумма пр.цен &2; сумма скидок &3; товаров &4; признаков &5&6"
                                            , v-ps-label
                                            , v-sale-sum
                                            , v-discnt-sum
                                            , buf_sale-doc.tot-lines
                                            , buf_sale-doc.tot-dtl
                                            , chr(10))
                            else  substitute("&1 : сумма пр.цен &2; сумма скидок &3; товаров &4; признаков &5&6"
                                              , v-ps-label
                                              , v-sale-sum
                                              , v-discnt-sum
                                              , buf_sale-doc.tot-lines
                                              , buf_sale-doc.tot-dtl) .
        end.
        if v-doc-ii = num-entries('es,rs,rwo,trf,swo,ngs,rgs,vir':U)
        and v-chr-office-ii = 2
        then do:
          assign
          locked_inkas.PS = right-trim(locked_inkas.PS, chr(10)) + chr(10) +
                                (IF one-curs
                                then substitute(" чеки по курсу &1", v-exch-rate)
                                else "") +
                                note-compense  +
          (if auto-fbr then (chr(10) + "Режим автомат.пр-ва.") else "":U) +
          (if rest-dish then ( chr(32) + "С учетом остатков блюд на объекте РЕСТОРАН.") else "":U) +
          (if rest-ingr then ( chr(32) + "С учетом остатков ингридиентов на объекте КУХНЯ.") else "":U) +
          (if p-is-tpsi-obj then (chr(10) + "Режим автомат.резервир. чужих товаров.") else "":U) +
          (if rest-tpsi then ( chr(32) + "С учетом остатков чужих товаров.") else "":U) +
          (if rest-tpsi then ( chr(32) + "С учетом остатков чужих товаров.") else "":U) +
          (if neg-tpsi-weight then ( chr(32) + "Уводить в отрицательные отстатки чужие весовые товары.") else "":U) +
          (if neg-tpsi-qnty > 0 then substitute(" Уводить в отрицательные отстатки чужие товары, если остатки < &1.", neg-tpsi-qnty) else "":U)  +
          (if neg-tpsi-oper then ( chr(32) + "Уводить в отрицательные отстатки чужие товары с отметкой оператора.") else "":U)
          .
        end.
        if available buf_sale-doc then do:
          assign
          buf_sale-doc.status_ = locked_trn-doc.status_.
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libtfarh) <> true) then do:   run str/libtfarh.p persistent no-error .   if error-status :error or (valid-handle(g#libtfarh) <> true) then do:     message       "Error starting libtfarh.p" skip       g#libtfarh skip       g#libtfarh :type skip       g#libtfarh :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libtfarh_st-fo in g#libtfarh
(input  locked_trn-doc.doc-code
) no-error.
          if error-status:error then do:
            undo _main, return error return-value .
          end.
          assign
          v-rec-id = recid(locked_trn-doc).
          if buf_sale-doc.doc-kind = 'swo':U
          then do:
            _cpa:
            for each buf_cash-pay-attr where buf_cash-pay-attr.attr-code = "dop-doc" no-lock:
              if entry(1, buf_cash-pay-attr.attr-value, ',') = 'swo':U
              then do:
                if entry(2, buf_cash-pay-attr.attr-value, ',') = locked_trn-doc.cli-type and integer (entry(3, buf_cash-pay-attr.attr-value, ',')) = locked_trn-doc.cli-code
                then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input locked_trn-doc.doc-code ,
                       input 'techpass':U ,
                       input yes ) no-error .
                  leave _cpa.
                end.
              end.
            end.
          end.
          if v-is-ptrl = yes then do:
                run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "           Обработка топливных товаров..."                                       ).
            for each buf_doc-line
              where buf_doc-line.doc-code = locked_trn-doc.doc-code
            on error undo _main, return error
            :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_doc-line.artic
  ,  input buf_doc-line.prod-type
  ,  input buf_doc-line.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) no-error.
              if error-status :error then do:
                undo _main, return error return-value.
              end.
              if v-is-petrol = yes
                and v-is-pieces = no
              then do:
                define variable inv-rec as recid no-undo .
                assign
                inv-rec = ?
                .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_corinvln in g#lib-trn3
( input  buf_doc-line.doc-code
 ,input  buf_doc-line.artic
 ,input  buf_doc-line.prod-type
 ,input  buf_doc-line.prod-code
 ,input  ?
 ,input  ?
 ,input  buf_doc-line.price-rubl * buf_doc-line.fact-density
 ,input  buf_doc-line.price-base * buf_doc-line.fact-density
 ,input  buf_doc-line.fact-qnty  * buf_doc-line.fact-density
 ,input  buf_doc-line.fact-density
 ,output inv-rec
 ) no-error.
                if error-status :error
                or inv-rec = ? then do:
                  undo _main, return error return-value.
                end.
              end.
            end.
          end.
          RELEASE locked_trn-doc no-error .
          if error-status:error then do:
               undo _main, return error return-value + error-status:get-message(1) .
          end.
          find first locked_trn-doc where recid(locked_trn-doc) = v-rec-id no-lock.
        end.
        if available buf_sale-doc
        and buf_sale-doc.doc-kind = 'rs':U then do:
            run adm/shattri.p (
                 input "get":U
                ,input locked_trn-doc.obj-type
                ,input locked_trn-doc.obj-code
                ,input 'nakl_par':U
                ,input  "minusprt"
                ,output v-value-character
                ,output v-value-date
                ,output v-value-decimal
                ,output v-value-integer
                ,output varminus-parts
                ,output varminus-parts-type
                ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
               ) no-error .
          if error-status :error  then varminus-parts = false .
          if varminus-parts = yes then do:
            run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input "           Автоматическая коррекция отрицательных партий..."                                       ).
            run str/deadprts.p ( locked_trn-doc.doc-code, parparentproc) no-error .
            if error-status:error then do:
              undo _main, return error return-value .
            end.
          end.
          if v-gas-cli-code > 0 then do:
            for each buf_doc-line exclusive-lock where buf_doc-line.doc-code  = replace(locked_trn-doc.doc-code, "-", "=") :
              find first buf_goods where buf_goods.prod-code = buf_doc-line.prod-code
                                     and buf_goods.prod-type = buf_doc-line.prod-type
                                     and buf_goods.artic = buf_doc-line.artic no-lock.
              if is-gas(buf_goods.gds-code)
              and not v-gas-compensed
              then do:
                  run str/gas-autort.p (input parparentproc,
                                        input p-log-handle,
                                        input log-file-name,
                                        input p-auto,
                                        input p-inkas-code,
                                        input v-curr-r-b,
                                        input v-gas-cli-type,
                                        input v-gas-cli-code,
                                        output v-new_doc-code,
                                        output v-root-node,
                                        buffer locked_trn-doc,
                                        buffer buf_doc-line,
                                        buffer buf-new_trn-doc)
                                        no-error .
              end.
            end.
          end.
        end.
        if available buf_sale-doc
        and (buf_sale-doc.doc-kind = 'trf':U or buf_sale-doc.doc-kind = 'vir':U) then do:
                    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Создание приходной накладной по Техпроливу в статусе &1...", 'накл':U)                                       ).
          run str/techrfsl.p (input parparentproc
                        ,input p-log-handle
                        ,input log-file-name
                        ,input p-auto
                        ,input v-curr-r-b
                        ,input close-in-rfsl
                        ,input buf_sale-doc.doc-kind
                        ,buffer locked_trn-doc
                        ,buffer buf-in
                        ) no-error .
          if error-status:error then do:
            undo _Main, return error  substitute("Невозможно закрыть продажу&1" +
                                  "не удается создать приходную накладную по Техпроливу в статусе &2&1:&3&1&4"
                                , chr(10)
                                , 'накл':U
                                , error-status:get-message(1)
                                , return-value
                                ).
          end.
                    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Создана приходная накладная по Техпроливу &1 в статусе &2...", buf-in.doc-code, 'накл':U)                                       ).
        end.
        if available locked_trn-doc and  locked_trn-doc.is-back-date and locked_trn-doc.ext-doc-type = 'es':U
        and available buf_sale-doc and buf_sale-doc.doc-kind = 'es':U then do:
                run str/vtrecalc.p ( input parparentproc
                            , input recid (locked_trn-doc)
                            ) no-error .
          if error-status :error then do:
          end.
        end.
      end.
    END.
    if p-is-inquiry then do:
      run get-inkas-ps in this-procedure (
                                          buffer locked_inkas
                                        , output chk-amount
                                        , output gds-amount
                                        , output line-out
                                        , output dtl-out
                                        , output line-ret
                                        , output dtl-ret
                                        , output nf-chk-amount
                                        , output nf-gds-amount
                                        , output ps-where-rus
                                        ).
      for each buf_chk-doc  where
              buf_chk-doc.out-code = locked_inkas.inkas-code
      on error  undo _main, return error substitute( "Ошибка при разбивке чека по объектам ТПСИ&2&1&2&3", return-value, chr(10), error-status :get-message (1))
      on stop   undo _main, return error substitute( "stop при разбивке чека по объектам ТПСИ&2&1&2&3", return-value, chr(10), error-status :get-message (1))
      on endkey undo _main, return error substitute( "endkey при разбивке чека по объектам ТПСИ&2&1&2&3", return-value, chr(10), error-status :get-message (1)):
        RUN chksplin in this-procedure ( buffer buf_chk-doc
                                     , input 2
                                     , output v-gds-amount) NO-ERROR.
        if error-status:error then do:
      run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Ошибка при разбивке чека &1 по объектам:&2" +                              "&3&2&4&3"                                                                       , buf_chk-doc.doc-code                                                           , chr(10)                                                                  , error-status:get-message(1)                                                    , return-value )                                       ).
          UNDO _main,  return "error".
        end.
      if lookup(string(buf_chk-doc.chk-type), '14,15,16,36,8,101,106,108,11,12,13,40,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) = 0
      then
      assign
      chk-amount    = chk-amount    - 1
      gds-amount    = gds-amount    - v-gds-amount
      nf-chk-amount = nf-chk-amount + 1
      nf-gds-amount = nf-gds-amount + v-gds-amount
      .
    end.
    FOR EACH buf_inkas-pay WHERE
            buf_inkas-pay.inkas-code = locked_inkas.inkas-code
    on error  undo _main, return error substitute( "Ошибка при удалении записи выручки&2&1&2&3", return-value, chr(10), error-status :get-message (1))
    on stop   undo _main, return error substitute( "stop при удалении записи выручки&2&1&2&3", return-value, chr(10), error-status :get-message (1))
    on endkey undo _main, return error substitute( "endkey при удалении записи выручки&2&1&2&3", return-value, chr(10), error-status :get-message (1)):
        delete buf_inkas-pay.
    END .
    FOR EACH buf_inkas-pay-desk WHERE
            buf_inkas-pay-desk.inkas-code = locked_inkas.inkas-code
    on error  undo _main, return error substitute( "Ошибка при удалении записи выручки по кассе&2&1&2&3", return-value, chr(10), error-status :get-message (1))
    on stop   undo _main, return error substitute( "stop при удалении записи выручки по кассе&2&1&2&3", return-value, chr(10), error-status :get-message (1))
    on endkey undo _main, return error substitute( "endkey при удалении записи выручки по кассе&2&1&2&3", return-value, chr(10), error-status :get-message (1)):
      delete buf_inkas-pay-desk.
    END .
    assign
    locked_inkas.PS = set-inkas-ps(input locked_inkas.ps
                          , input chk-amount
                          , input gds-amount
                          , input line-out
                          , input dtl-out
                          , input line-ret
                          , input dtl-ret
                          , input nf-chk-amount
                          , input nf-gds-amount
                          , input ps-where-rus
                          ).
    assign
    locked_inkas.tot-doc = 0
    locked_inkas.netto  = 0
    locked_inkas.discnt = 0
    locked_inkas.sub-discnt = 0
    locked_inkas.qnty = 0
    .
    assign
    locked_inkas.status_ = 'запрос':U
    .
  end.
  else do:
    assign
    locked_inkas.status_ = 'факт':U .
      if v-close-day-period then do:
                run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Согласно настройкам закрытие продажи ведет к закрытию периода до даты &1...", (locked_inkas.doc-date + 1))                                       ).
        run thbjattr_write in this-procedure (
                                                input locked_trn-doc.obj-type
                                                ,input locked_trn-doc.obj-code
                                                ,input 'nakl_par':U
                                                ,input 'date-close-period':U
                                                ,input ''
                                                ,input (locked_inkas.doc-date + 1)
                                                ,input 0.0
                                                ,input 0
                                                ,input no
                                              ) .
      end.
  end.
END.
run waitfram-hide in this-procedure .
END PROCEDURE.
