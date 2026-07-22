block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jun 08 18:12:30 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-malinap.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/exp-malinap.p $":U .
define variable vss-description as character no-undo init "Передача данных в Малину".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE temp-table tt_obj no-undo
field obj-type as character
field obj-code as integer.
DEFINE temp-table tt_obj_shift no-undo
field obj-type as character
field obj-code as integer
field shift-attr as CHARACTER
.
DEFINE temp-table tt-location_id no-undo
field old-code as character
field new-code as character.
DEFINE INPUT PARAMETER TABLE FOR tt_obj.
DEFINE INPUT PARAMETER p-company AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-directory AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-prefix AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-goods AS LOGICAL NO-UNDO.
DEFINE INPUT PARAMETER p-chk AS LOGICAL NO-UNDO.
DEFINE INPUT PARAMETER p-category AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-diapmin AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-diapmax AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-log-handle AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-location AS logical NO-UNDO.
DEFINE INPUT PARAMETER p-categ-loc AS char NO-UNDO.
DEFINE variable v-bonus-pay AS char NO-UNDO.
DEFINE VARIABLE i-i AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE i-j AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE i-hh AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE i-mm AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE i-ss AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE c-ch AS CHARACTER NO-UNDO.
DEFINE VARIABLE i-gdscnt AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE i-chkcnt AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE i-numfile AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE i-numline AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE i-tender-code AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE file_name AS CHARACTER NO-UNDO.
DEFINE VARIABLE c-logname AS CHARACTER NO-UNDO.
DEFINE VARIABLE c-value AS CHARACTER NO-UNDO.
DEFINE VARIABLE c-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE c-locid AS CHARACTER NO-UNDO.
DEFINE VARIABLE d-date AS DATE NO-UNDO.
DEFINE VARIABLE i-shift AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE i-op-id AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE b-malina AS LOGICAL NO-UNDO.
DEFINE VARIABLE b-ball-malina AS LOGICAL NO-UNDO.
DEFINE VARIABLE c-locfile AS CHARACTER NO-UNDO.
define variable v-attr-value    as character no-undo .
define variable v-attr-type     as character no-undo .
DEFINE BUFFER buf_gds-grp FOR gds-grp.
DEFINE BUFFER buf_goods FOR goods.
DEFINE BUFFER buf_shift-obj FOR ub.shift-obj.
DEFINE BUFFER buf_previous-shift-obj FOR ub.shift-obj.
DEFINE BUFFER buf_chk-doc FOR ub.chk-doc.
DEFINE BUFFER buf_chk-gds-pay FOR ub.chk-gds-pay.
DEFINE BUFFER buf_chk-gds FOR ub.chk-gds.
DEFINE BUFFER buf_chk-pay FOR ub.chk-pay.
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_sysconf FOR ub.sysconf.
DEFINE BUFFER buf_bar-code FOR ub.bar-code.
DEFINE BUFFER buf_db-attr FOR ub.db-attr.
define BUFFER buf_cash-pay-attr FOR ub.cash-pay-attr.
DEFINE TEMP-TABLE tt_goods NO-UNDO
    FIELD partner_id AS CHARACTER FORMAT "x(3)"
    FIELD sku_id AS CHARACTER FORMAT "x(20)"
    FIELD category_id AS CHARACTER FORMAT "x(20)"
    FIELD parent_category_id AS CHARACTER FORMAT "x(20)"
    FIELD descr AS CHARACTER FORMAT "x(50)"
    FIELD long_descr AS CHARACTER FORMAT "x(150)"
    FIELD error_code AS CHARACTER FORMAT "x(3)"
    FIELD error_message AS CHARACTER FORMAT "x(30)"
    .
DEFINE TEMP-TABLE tt_chk-doc no-undo
    FIELD partner_id AS CHARACTER FORMAT "x(3)"
    FIELD transaction_id AS CHARACTER FORMAT "x(20)"
    FIELD transaction_line_number AS CHARACTER FORMAT "x(3)"
    FIELD transaction_date AS CHARACTER
    FIELD card_number AS CHARACTER FORMAT "x(16)"
    FIELD card_barcode AS CHARACTER FORMAT "x(13)"
    FIELD location_id AS CHARACTER FORMAT "x(20)"
    FIELD tender_code AS CHARACTER FORMAT "x(5)"
    FIELD total_sum AS CHARACTER FORMAT "x(19)"
    FIELD invest_sum AS CHARACTER FORMAT "x(19)"
    FIELD certificate_id AS CHARACTER FORMAT "x(13)"
    FIELD transaction_descr AS CHARACTER FORMAT "x(30)"
    FIELD location_descr AS CHARACTER FORMAT "x(50)"
    FIELD sku_id AS CHARACTER FORMAT "x(20)"
    FIELD sku_qty AS CHARACTER FORMAT "x(20)"
    FIELD sku_price AS CHARACTER FORMAT "x(19)"
    FIELD line_cost AS CHARACTER FORMAT "x(19)"
    FIELD sku_descr AS CHARACTER FORMAT "x(50)"
    FIELD transaction_attrs AS CHARACTER FORMAT "x(550)"
    FIELD standard_points AS CHARACTER FORMAT "x(19)"
    FIELD bonus_points AS CHARACTER FORMAT "x(19)"
    FIELD error_code AS CHARACTER FORMAT "x(3)"
    FIELD error_message AS CHARACTER FORMAT "x(30)"
    .
def buffer  buf-tt_chk-doc for tt_chk-doc.
def var l-cash as log no-undo.
def var l-bank as log no-undo.
def var l-bonus as log no-undo.
def var l-visa as log no-undo.
def var l-master as log no-undo.
def var l-maestro as log no-undo.
def var l-reiff as log no-undo.
def var sum-bonus as dec format '>>>>>>>>9' no-undo.
c-logname = p-directory + "exp-malina.txt".
run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Начало выгрузки данных в Малину")).
IF p-goods THEN DO:
def var i-cg as int no-undo format '>>>>>>>>9'.
        run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Начало выгрузки товарного классификатора")).
    FIND FIRST buf_db-attr WHERE buf_db-attr.db-num = g#db-num AND buf_db-attr.attr-code = 'malina-goods' NO-ERROR.
    IF AVAILABLE buf_db-attr THEN DO:
        IF TODAY = DATE(ENTRY(1,buf_db-attr.attr-value)) THEN do:
            i-numfile = INTEGER(ENTRY(2,buf_db-attr.attr-value)) + 1.
            IF i-numfile < p-diapmin THEN i-numfile = p-diapmin.
        end.
        ELSE
            i-numfile = p-diapmin.
    END.
    ELSE DO:
        CREATE buf_db-attr.
        ASSIGN
            buf_db-attr.db-num = g#db-num
            buf_db-attr.attr-code = 'malina-goods'
            buf_db-attr.attr-value = STRING(TODAY) + ",0"
            i-numfile = p-diapmin.
    END.
    RUN bge/exp-malina-lockattr.p
        ( input g#db-num
        ,input "malina-goods":U
        ,buffer buf_db-attr
        ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        MESSAGE
            vss-workfile vss-revision vss-description SKIP
            SUBSTITUTE( "Ошибка при блокировке атрибута БД" ) SKIP
            RETURN-VALUE SKIP
            ERROR-STATUS:GET-MESSAGE ( ERROR-STATUS:NUM-MESSAGES )
            VIEW-AS ALERT-BOX ERROR
            .
        RETURN ERROR .
    END.
    FOR EACH buf_gds-grp where node-code > 1 NO-LOCK:
        CREATE tt_goods.
        ASSIGN
            tt_goods.partner_id = STRING(p-company,"999")
            tt_goods.sku_id = ''
            tt_goods.category_id = STRING(buf_gds-grp.node-code) + '_' + STRING(p-category)
            tt_goods.parent_category_id = IF buf_gds-grp.upper-code <= 1 THEN STRING(p-categ-loc) ELSE STRING(buf_gds-grp.upper-code) + '_' + STRING(p-category)
            tt_goods.descr = buf_gds-grp.node-name
            tt_goods.long_descr = ''
            tt_goods.error_code = ''
            tt_goods.error_message = ''
            NO-ERROR.
    END.
    FOR EACH buf_goods WHERE buf_goods.stts = 0 NO-LOCK:
        CREATE tt_goods.
        ASSIGN
            tt_goods.partner_id = STRING(p-company,"999")
            tt_goods.sku_id = STRING(buf_goods.gds-code) + '_' + STRING(p-category)
            tt_goods.category_id = STRING(buf_goods.grp-code) + '_' + STRING(p-category)
            tt_goods.parent_category_id = ''
            tt_goods.descr = buf_goods.gds-name
            tt_goods.long_descr = ''
            tt_goods.error_code = ''
            tt_goods.error_message = ''
            NO-ERROR.
    END.
        run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Сохраняем товарный классификатор в файл.")).
    file_name = p-directory + STRING(p-company,"999") + 'cg' + STRING(YEAR(TODAY), "9999") + STRING(MONTH(TODAY), "99") + STRING(DAY(TODAY), "99") + STRING(i-numfile, "999") + '.lsp'.
    OUTPUT TO VALUE(file_name).
    i-i = 0.
    FOR EACH tt_goods NO-LOCK:
        ASSIGN
            i-i = i-i + 1
            i-gdscnt = i-gdscnt + 1
            c-ch = tt_goods.partner_id + CHR(59) +
                tt_goods.sku_id  + CHR(59) +
                tt_goods.category_id + CHR(59) +
                tt_goods.parent_category_id + CHR(59) +
                tt_goods.descr + CHR(59) +
                tt_goods.long_descr + CHR(59) +
                tt_goods.error_code + CHR(59) +
                tt_goods.error_message.
        PUT UNFORMATTED c-ch SKIP.
        i-cg = i-cg + 1.
        IF i-i >= 1000000 THEN DO:
            OUTPUT CLOSE.
            i-numfile = i-numfile + 1.
            IF i-numfile > p-diapmax THEN DO:
                MESSAGE
                    vss-workfile vss-revision vss-description SKIP
                    SUBSTITUTE( "Превышен диапазон при выгрузке товарного классификатора!" ) SKIP
                    RETURN-VALUE SKIP
                    ERROR-STATUS:GET-MESSAGE ( ERROR-STATUS:NUM-MESSAGES )
                    VIEW-AS ALERT-BOX ERROR
                    .
                RETURN ERROR .
            END.
            file_name = p-directory + STRING(p-company,"999") + 'cg' + STRING(YEAR(TODAY), "9999") + STRING(MONTH(TODAY), "99") + STRING(DAY(TODAY), "99") + STRING(i-numfile, "999") + '.lsp'.
            OUTPUT TO VALUE(file_name).
        END.
    END.
    OUTPUT CLOSE.
    file_name = p-directory + STRING(p-company,"999") + 'cg' + STRING(YEAR(TODAY), "9999") + STRING(MONTH(TODAY), "99") + STRING(DAY(TODAY), "99") + STRING(i-numfile, "999") + '.ok'.
    OUTPUT TO VALUE(file_name).
    put UNFORMATTED i-cg skip.
    OUTPUT CLOSE.
    buf_db-attr.attr-value = STRING(TODAY) + "," + string(i-numfile).
    RELEASE db-attr.
        run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Выгрузка товарного классификатора завершена.")).
END.
IF p-location OR p-chk THEN DO:
        run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Начало загрузки мэппинга локаций")).
    c-locfile = p-directory + 'location.inf'.
    FILE-INFO:FILE-NAME = c-locfile.
    IF FILE-INFO:FULL-PATHNAME = ? THEN DO:
                run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Файл локаций не найден. (&1)", c-locfile)).
    END.
    ELSE DO:
        INPUT FROM VALUE (c-locfile).
        REPEAT:
            IMPORT UNFORMATTED c-ch.
            IF NUM-ENTRIES(c-ch,';') = 2 THEN DO:
                CREATE tt-location_id.
                ASSIGN
                    tt-location_id.new-code = ENTRY(1,c-ch,';')
                    tt-location_id.old-code = ENTRY(2,c-ch,';')
                    .
            END.
        END.
        INPUT CLOSE.
                run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Файл локаций загружен. (&1)", c-locfile)).
    END.
END.
IF p-location THEN DO:
    FIND FIRST buf_db-attr WHERE buf_db-attr.db-num = g#db-num AND buf_db-attr.attr-code = 'malina-location':U NO-ERROR.
    IF AVAILABLE buf_db-attr THEN DO:
        IF TODAY = DATE(ENTRY(1,buf_db-attr.attr-value)) THEN do:
            i-numfile = INTEGER(ENTRY(2,buf_db-attr.attr-value)) + 1.
            IF i-numfile < p-diapmin THEN i-numfile = p-diapmin.
        end.
        ELSE
            i-numfile = p-diapmin.
    END.
    ELSE DO:
        CREATE buf_db-attr.
        ASSIGN
            buf_db-attr.db-num = g#db-num
            buf_db-attr.attr-code = 'malina-location':U
            buf_db-attr.attr-value = STRING(TODAY) + ",0"
            i-numfile = p-diapmin.
    END.
    file_name = p-directory + STRING(p-company,"999") + 'co' + STRING(YEAR(TODAY), "9999") + STRING(MONTH(TODAY), "99") + STRING(DAY(TODAY), "99") + STRING(i-numfile, "999") + '.lsp'.
    OUTPUT TO VALUE(file_name).
    RUN bge/exp-malina-lockattr.p
        ( input g#db-num
        ,input "malina-location":U
        ,buffer buf_db-attr
        ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        MESSAGE
            vss-workfile vss-revision vss-description SKIP
            SUBSTITUTE( "Ошибка при блокировке атрибута БД" ) SKIP
            RETURN-VALUE SKIP
            ERROR-STATUS:GET-MESSAGE ( ERROR-STATUS:NUM-MESSAGES )
            VIEW-AS ALERT-BOX ERROR
            .
        RETURN ERROR .
    END.
   def var i-co as int format '>>>>>>>>9'.
    for each ub.clients where obj-type = 'маг':U and ub.clients.stts = 0, first tt_obj where tt_obj.obj-type = clients.obj-type and tt_obj.obj-code = clients.obj-code  no-lock:
        c-locid = p-categ-loc + string(ub.clients.obj-code).
           FIND FIRST tt-location_id WHERE tt-location_id.new-code = c-locid  NO-LOCK NO-ERROR.
                    IF AVAILABLE tt-location_id THEN c-locid = tt-location_id.old-code.
        c-ch = STRING(p-company,"999") + CHR(59) + CHR(59) +
                c-locid  + CHR(59) +
                STRING(p-categ-loc) + CHR(59) +
                clients.obj-name + CHR(59) +  clients.obj-name + CHR(59)  + CHR(59).
        PUT UNFORMATTED c-ch SKIP.
        i-co = i-co + 1.
        for each cash-desk no-lock where
            cash-desk.obj-code = clients.obj-code and
            cash-desk.is-del = no:
            c-locid = string(ub.clients.obj-code) + '_':U + string(cash-desk.cash-num) + '_' + STRING(p-categ-loc).
            FIND FIRST tt-location_id WHERE tt-location_id.new-code = c-locid  NO-LOCK NO-ERROR.
            IF AVAILABLE tt-location_id THEN c-locid = tt-location_id.old-code.
            c-ch = STRING(p-company,"999") + CHR(59) + c-locid  +
                CHR(59) + p-categ-loc + string(ub.clients.obj-code) + CHR(59) + CHR(59) +
                clients.obj-name + ' cassa ' + string(cash-desk.cash-num) + CHR(59) +  CHR(59)  + CHR(59).
            PUT UNFORMATTED c-ch SKIP.
            i-co = i-co + 1.
        end.
    end.
    OUTPUT CLOSE.
file_name = p-directory + STRING(p-company,"999") + 'co' + STRING(YEAR(TODAY), "9999") + STRING(MONTH(TODAY), "99") + STRING(DAY(TODAY), "99") + STRING(i-numfile, "999") + '.ok'.
    OUTPUT TO VALUE(file_name).
    put UNFORMATTED i-co skip.
    OUTPUT CLOSE.
    buf_db-attr.attr-value = STRING(TODAY) + "," + string(i-numfile).
    RELEASE db-attr.
        run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Выгрузка классификатора объектов(локаций) завершена.")).
END.
IF p-chk THEN DO:
        run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Начало выгрузки чеков")).
    FIND FIRST db-attr WHERE db-attr.db-num = g#db-num AND db-attr.attr-code = 'malina-chk' NO-ERROR.
    IF AVAILABLE db-attr THEN DO:
        IF TODAY = DATE(ENTRY(1,db-attr.attr-value)) THEN do:
            i-numfile = INTEGER(ENTRY(2,db-attr.attr-value)) + 1.
            IF i-numfile < p-diapmin THEN i-numfile = p-diapmin.
        end.
        ELSE
            i-numfile = p-diapmin.
    END.
    ELSE DO:
        CREATE db-attr.
        ASSIGN
            db-attr.db-num = g#db-num
            db-attr.attr-code = 'malina-chk'
            db-attr.attr-value = STRING(TODAY) + ",0"
            i-numfile = p-diapmin.
    END.
            FOR EACH buf_cash-pay-attr where buf_cash-pay-attr.attr-code  = "bal_malina" and
                                               buf_cash-pay-attr.attr-value = "yes":
            if v-bonus-pay = "" then do:
                  v-bonus-pay = string(buf_cash-pay-attr.cdpay-code).
                end.
                else v-bonus-pay = v-bonus-pay + "," + string(buf_cash-pay-attr.cdpay-code).
            END.
    for each tt_obj no-lock:
        run clntattr-value in this-procedure (input tt_obj.obj-type,
                                              input tt_obj.obj-code,
                                              input 'bge-exp-malina-last-shift':U,
                                              output c-value,
                                              output c-type) NO-ERROR.
        if c-value = "" then do:
            c-value = "1/1/1900,1,1".
            run clntattr-write in this-procedure (input tt_obj.obj-type,
                                                  input tt_obj.obj-code,
                                                  input 'bge-exp-malina-last-shift':U,
                                                  input c-value) NO-ERROR.
        end.
        if error-status:error then do:
                        run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Ошибка в атрибуте объекта. Объект &1&2",tt_obj.obj-type,tt_obj.obj-code)).
            next.
        end.
        assign
            d-date = date(entry(1,c-value,","))
            i-shift = integer(entry(2,c-value,","))
            i-op-id = integer(entry(3,c-value,",")) NO-ERROR.
        for each buf_shift-obj where buf_shift-obj.obj-type = tt_obj.obj-type
                               and buf_shift-obj.obj-code = tt_obj.obj-code
                               and ((buf_shift-obj.shift-date = d-date
                                        and buf_shift-obj.shift-num > i-shift)
                                    or buf_shift-obj.shift-date > d-date)
                               and buf_shift-obj.status_ = 'зкр':U
                               use-index stts no-lock:
            run rep/rpychk0.p (input "r-ptrsp2",
                               input buf_shift-obj.obj-type,
                               input buf_shift-obj.obj-code,
                               input ?,
                               input ?,
                               input buf_shift-obj.shift-date,
                               input ?,
                               input buf_shift-obj.shift-num,
                               input ?,
                               input ?).
            FIND FIRST buf_clients WHERE buf_clients.obj-type = buf_shift-obj.obj-type
                                     AND buf_clients.obj-code = buf_shift-obj.obj-code NO-LOCK NO-ERROR.
            IF AVAILABLE buf_clients THEN DO:
                FIND FIRST buf_sysconf WHERE buf_sysconf.host-code = buf_clients.host-code NO-LOCK NO-ERROR.
            END.
            FOR EACH buf_chk-doc WHERE buf_chk-doc.obj-type = buf_shift-obj.obj-type
                                       AND buf_chk-doc.obj-code = buf_shift-obj.obj-code
                                       AND buf_chk-doc.shift-date = buf_shift-obj.shift-date
                                       AND buf_chk-doc.shift-num = buf_shift-obj.shift-num
                                       and (string(buf_chk-doc.chk-type)  = '1':U or string(buf_chk-doc.chk-type)  = '6':U) NO-LOCK:
                ASSIGN
                    i-numline = 0
                    b-malina = FALSE
                                        b-ball-malina = FALSE
                    .
                DO i-i = 1 TO NUM-ENTRIES (p-prefix):
                    IF buf_chk-doc.d-card BEGINS ENTRY ( i-i, p-prefix) THEN b-malina = TRUE.
                END.
               DO i-j = 1 TO NUM-ENTRIES (v-bonus-pay):
                    if CAN-FIND (ub.chk-pay where chk-pay.doc-code = buf_chk-doc.doc-code and chk-pay.pay-code = int(ENTRY (i-j,v-bonus-pay,",")) no-lock) then do:
                         b-ball-malina = TRUE.
                    end.
               end.
                IF b-malina  or b-ball-malina THEN DO:
                    ASSIGN
                        i-hh = TRUNCATE(buf_chk-doc.chk-time / 3600, 0)
                        i-mm = TRUNCATE((buf_chk-doc.chk-time - (i-hh * 3600)) / 60, 0)
                        i-ss = TRUNCATE((buf_chk-doc.chk-time - (i-hh * 3600) - (i-mm * 60)) / 60, 0).
                    c-ch = STRING(buf_chk-doc.obj-code) + "_" + STRING(buf_chk-doc.pay-desk) + '_' + STRING(p-categ-loc).
                    FOR FIRST tt-location_id WHERE tt-location_id.new-code = c-ch NO-LOCK:
                        c-ch = tt-location_id.old-code.
                    END.
                    CREATE tt_chk-doc.
                    ASSIGN
                        tt_chk-doc.partner_id = STRING(p-company,"999")
                        tt_chk-doc.transaction_id = STRING(buf_chk-doc.doc-code) + '_' + STRING(p-category)
                        tt_chk-doc.transaction_line_number = "0"
                        tt_chk-doc.transaction_date = STRING(YEAR(buf_chk-doc.chk-date),"9999") + STRING(MONTH(buf_chk-doc.chk-date), "99") + STRING(DAY(buf_chk-doc.chk-date), "99") +
                                                      STRING(i-hh,"99") + STRING(i-mm ,"99") + STRING(i-ss ,"99")
                        tt_chk-doc.card_number = IF LENGTH(buf_chk-doc.src-d-card) = 16 THEN buf_chk-doc.src-d-card ELSE ""
                        tt_chk-doc.card_barcode = IF LENGTH(buf_chk-doc.src-d-card) = 13 THEN buf_chk-doc.src-d-card ELSE ""
                        tt_chk-doc.location_id = c-ch
                        tt_chk-doc.total_sum = STRING(int(buf_chk-doc.netto * 100))
                        tt_chk-doc.invest_sum = string(int(buf_chk-doc.netto))
                        tt_chk-doc.certificate_id = ""
                        tt_chk-doc.transaction_descr = ""
                        tt_chk-doc.location_descr = ""
                        tt_chk-doc.sku_id = ""
                        tt_chk-doc.sku_qty = ""
                        tt_chk-doc.sku_price = ""
                        tt_chk-doc.line_cost = ""
                        tt_chk-doc.sku_descr = ""
                        tt_chk-doc.transaction_attrs = ""
                        tt_chk-doc.standard_points = ""
                        tt_chk-doc.bonus_points = ""
                        tt_chk-doc.error_code = ""
                        tt_chk-doc.error_message = ""
                        .
                    assign
                    l-cash = no
                    l-bank = no
                    l-bonus = no
                    sum-bonus = 0
                    l-visa = no
                    l-master = no
                    l-maestro = no
                    l-reiff = no
                    i-tender-code = 0
                        .
                    FOR EACH buf_chk-gds-pay WHERE buf_chk-gds-pay.doc-code = buf_chk-doc.doc-code NO-LOCK:
                        i-numline = i-numline + 1.
                        FIND FIRST buf_bar-code WHERE buf_bar-code.b-code = buf_chk-gds-pay.b-code NO-LOCK NO-ERROR.
                        run gds-attr-value in this-procedure
                            ( input  buf_bar-code.gds-code
                            , input  'ban-bonus':U
                            , output v-attr-value
                            , output v-attr-type
                            ) .
                        if lookup(v-attr-value, 'true,yes':u) > 0 then do:
                        assign
                            tt_chk-doc.total_sum = STRING(int(tt_chk-doc.total_sum) - int(buf_chk-gds-pay.tot-r-b * 100 ))
                            tt_chk-doc.invest_sum = string(int(tt_chk-doc.invest_sum) - int(buf_chk-gds-pay.tot-r-b))
                            .
                            next .
                        end.
                        CREATE buf-tt_chk-doc.
                        ASSIGN
                            buf-tt_chk-doc.partner_id = STRING(p-company,"999")
                            buf-tt_chk-doc.transaction_id = STRING(buf_chk-doc.doc-code) + '_' + STRING(p-category)
                            buf-tt_chk-doc.transaction_line_number = STRING(i-numline)
                            buf-tt_chk-doc.transaction_date = ""
                            buf-tt_chk-doc.card_number = ""
                            buf-tt_chk-doc.card_barcode = ""
                            buf-tt_chk-doc.location_id = ""
                            buf-tt_chk-doc.tender_code = ""
                            buf-tt_chk-doc.total_sum = ""
                            buf-tt_chk-doc.invest_sum = ""
                            buf-tt_chk-doc.certificate_id = ""
                            buf-tt_chk-doc.transaction_descr = ""
                            buf-tt_chk-doc.location_descr = ""
                            buf-tt_chk-doc.sku_id = IF AVAILABLE buf_bar-code THEN STRING(buf_bar-code.gds-code) + '_' + STRING(p-category) ELSE ""
                            buf-tt_chk-doc.sku_qty = LEFT-TRIM(STRING(buf_chk-gds-pay.eff-doc-qnty, "->>>>>>>>>.9999"))
                            buf-tt_chk-doc.sku_price = STRING(buf_chk-gds-pay.price-base * 100)
                            buf-tt_chk-doc.line_cost = STRING(int(buf_chk-gds-pay.tot-r-b * 100 ))
                            buf-tt_chk-doc.sku_descr = ""
                            buf-tt_chk-doc.transaction_attrs = ""
                            buf-tt_chk-doc.standard_points = ""
                            buf-tt_chk-doc.bonus_points = ""
                            buf-tt_chk-doc.error_code = ""
                            buf-tt_chk-doc.error_message = ""
                            .
                        if buf_chk-gds-pay.pay-code = buf_sysconf.cash-pay then l-cash = yes.
                        else if lookup (string(buf_chk-gds-pay.pay-code), v-bonus-pay) > 0 then do:
                            l-bonus = yes.
                            sum-bonus = sum-bonus + (buf_chk-gds-pay.tot-r-b * 100 / buf_chk-gds-pay.eff-doc-qnty).
                            tt_chk-doc.card_number = IF LENGTH(buf_chk-gds-pay.pay-card) = 16 THEN buf_chk-gds-pay.pay-card ELSE "".
                            tt_chk-doc.card_barcode = IF LENGTH(buf_chk-gds-pay.pay-card) = 13 THEN buf_chk-gds-pay.pay-card ELSE "".
                        end.
                        else l-bank = yes.
                        IF buf_chk-gds-pay.pay-card <> '0' and not  lookup (string(buf_chk-gds-pay.pay-code), v-bonus-pay) > 0 THEN DO:
                            IF buf_chk-gds-pay.pay-card BEGINS '422287' THEN l-reiff = YES.
                            ELSE IF buf_chk-gds-pay.pay-card BEGINS '4' THEN l-visa = YES.
                            ELSE IF buf_chk-gds-pay.pay-card BEGINS '5' THEN l-master = YES.
                            ELSE IF buf_chk-gds-pay.pay-card BEGINS '3' or buf_chk-gds-pay.pay-card BEGINS '6'  THEN l-maestro = YES.
                        END.
                    END.
                    IF l-bank OR l-bonus THEN DO:
                        i-tender-code = i-tender-code + 3.
                        IF l-bonus THEN i-tender-code = i-tender-code + 8192.
                        IF l-reiff THEN i-tender-code = i-tender-code + 2048.
                        IF l-visa THEN i-tender-code = i-tender-code + 4.
                        IF l-master THEN i-tender-code = i-tender-code + 8.
                        IF l-maestro THEN i-tender-code = i-tender-code + 32.
                        IF NOT l-bonus AND NOT l-reiff AND NOT l-visa AND NOT l-master AND NOT l-maestro THEN i-tender-code = i-tender-code + 1024.
                    END.
                    IF l-cash AND i-tender-code <> 0 THEN DO:
                        i-tender-code = i-tender-code + 4096.
                    END.
                    tt_chk-doc.tender_code = STRING(i-tender-code).
                END.
            END.
            if not error-status:error then do:
                FIND FIRST tt_obj_shift WHERE tt_obj_shift.obj-type = tt_obj.obj-type
                                          AND tt_obj_shift.obj-code = tt_obj.obj-code EXCLUSIVE-LOCK NO-ERROR.
                IF NOT AVAILABLE tt_obj_shift THEN DO:
                    CREATE tt_obj_shift.
                    ASSIGN
                        tt_obj_shift.obj-type = tt_obj.obj-type
                        tt_obj_shift.obj-code = tt_obj.obj-code.
                END.
                tt_obj_shift.shift-attr = substitute("&1,&2,&3", buf_shift-obj.shift-date,buf_shift-obj.shift-num,i-op-id).
                                run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Выборка чеков завершена. Объект &1&2, смена &3 за &4",                     tt_obj.obj-type,tt_obj.obj-code,buf_shift-obj.shift-num,buf_shift-obj.shift-date)).
            end.
            else do:
                                run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute( "На объекте &1&2 возникли ошибки. Дата: &3, Смена: &4",                     tt_obj.obj-type,tt_obj.obj-code,buf_shift-obj.shift-date,buf_shift-obj.shift-num)).
                leave.
            end.
        end.
    end.
        run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Сохраняем чеки в файл.")).
    file_name = p-directory + STRING(p-company,"999") + 'tr' + STRING(YEAR(TODAY), "9999") + STRING(MONTH(TODAY), "99") + STRING(DAY(TODAY), "99") + STRING(i-numfile, "999") + '.lsp'.
    OUTPUT TO VALUE(file_name).
    i-i = 0.
    FOR EACH tt_chk-doc where ( tt_chk-doc.transaction_line_number = "0" and int(total_sum) <> 0 and int(total_sum) <> ?) or tt_chk-doc.transaction_line_number <> "0" NO-LOCK:
        IF i-i >= 299990 and int(tt_chk-doc.transaction_line_number) = 0  THEN DO:
            OUTPUT CLOSE.
            file_name = p-directory + STRING(p-company,"999") + 'tr' + STRING(YEAR(TODAY), "9999") + STRING(MONTH(TODAY), "99") + STRING(DAY(TODAY), "99") + STRING(i-numfile, "999") + '.ok'.
            OUTPUT TO VALUE(file_name).
            put unformatted i-i skip.
            OUTPUT CLOSE.
            i-numfile = i-numfile + 1.
            IF i-numfile > p-diapmax THEN DO:
                MESSAGE
                    vss-workfile vss-revision vss-description SKIP
                    SUBSTITUTE( "Превышен диапазон при выгрузке чеков!" ) SKIP
                    RETURN-VALUE SKIP
                    ERROR-STATUS:GET-MESSAGE ( ERROR-STATUS:NUM-MESSAGES )
                    VIEW-AS ALERT-BOX ERROR
                    .
                RETURN ERROR .
            END.
            file_name = p-directory + STRING(p-company,"999") + 'tr' + STRING(YEAR(TODAY), "9999") + STRING(MONTH(TODAY), "99") + STRING(DAY(TODAY), "99") + STRING(i-numfile, "999") + '.lsp'.
            OUTPUT TO VALUE(file_name).
            i-i = 0.
        END.
        ASSIGN
            i-i = i-i + 1
            i-chkcnt = i-chkcnt + 1
            c-ch = tt_chk-doc.partner_id + CHR(59) +
                tt_chk-doc.transaction_id  + CHR(59) +
                tt_chk-doc.transaction_line_number + CHR(59) +
                tt_chk-doc.transaction_date + CHR(59) +
                tt_chk-doc.card_number + CHR(59) +
                tt_chk-doc.card_barcode + CHR(59) +
                tt_chk-doc.location_id + CHR(59) +
                tt_chk-doc.tender_code + CHR(59) +
                tt_chk-doc.total_sum + CHR(59) +
                tt_chk-doc.invest_sum + CHR(59) +
                tt_chk-doc.certificate_id + CHR(59) +
                tt_chk-doc.transaction_descr + CHR(59) +
                tt_chk-doc.location_descr + CHR(59) +
                tt_chk-doc.sku_id + CHR(59) +
                tt_chk-doc.sku_qty + CHR(59) +
                tt_chk-doc.sku_price + CHR(59) +
                tt_chk-doc.line_cost + CHR(59) +
                tt_chk-doc.sku_descr + CHR(59) +
                tt_chk-doc.transaction_attrs + CHR(59) +
                tt_chk-doc.standard_points + CHR(59) +
                tt_chk-doc.bonus_points + CHR(59) +
                tt_chk-doc.error_code + CHR(59) +
                tt_chk-doc.error_message.
        PUT UNFORMATTED c-ch SKIP.
    END.
    OUTPUT CLOSE.
    FOR EACH tt_obj_shift NO-LOCK:
        run clntattr-write in this-procedure (input tt_obj_shift.obj-type,
                                              input tt_obj_shift.obj-code,
                                              input 'bge-exp-malina-last-shift':U,
                                              input tt_obj_shift.shift-attr) NO-ERROR.
        if error-status:error then do:
                        run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Ошибка записи атрибута. Объект &1&2, смена &3 за &4.&5",                 tt_obj_shift.obj-type,tt_obj_shift.obj-code,entry(2,tt_obj_shift.shift-attr,","),date(entry(1,tt_obj_shift.shift-attr,",")),return-value + error-status:get-message(1) )).
        end.
    END.
        run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Формируем файл-флаг.")).
    file_name = p-directory + STRING(p-company,"999") + 'tr' + STRING(YEAR(TODAY), "9999") + STRING(MONTH(TODAY), "99") + STRING(DAY(TODAY), "99") + STRING(i-numfile, "999") + '.ok'.
    OUTPUT TO VALUE(file_name).
    put unformatted i-i skip.
    OUTPUT CLOSE.
    db-attr.attr-value = STRING(TODAY) + "," + string(i-numfile).
    RELEASE db-attr.
        run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Выгрузка чеков завершена.")).
END.
run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Экспорт данных в Малину завершён.")).
run write-log-and-file in p-log-handle     (input 1, input c-logname, input 1, input substitute("Процесс завершён.")).
