block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 899f5f3721f3, 1951, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jul 26 11:39:33 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-exp-ATD.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-exp-ATD.p $":U .
define variable vss-description as character no-undo init "Выгрузка в систему Анализа Трека Данных".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure findtank:
  define input  parameter p-obj-type     as character no-undo.
  define input  parameter p-obj-code     as integer   no-undo.
  define input  parameter p-pump-code    as integer   no-undo.
  define input  parameter p-nozzle-code  as integer   no-undo .
  define input  parameter p-from-pl-code as integer   no-undo .
  define input  parameter p-gds-code     as integer   no-undo.
  define output parameter p-pl-code      as integer   no-undo .
  define variable v-pl-code            like ub.place.pl-code no-undo .
  define variable v-dopstr             as character no-undo .
  define buffer buf_place for ub.place.
  define buffer buf_pl-gds-pump for ub.pl-gds-pump.
  define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
  define buffer buf_pl-gds for ub.pl-gds.
  do
  on error undo, return error return-value
  :
    assign
      v-pl-code = 0
      p-pl-code = ?
    .
    if p-from-pl-code <> ?
      and p-from-pl-code <> 0
    then do:
      find first buf_pl-gds no-lock
        where buf_pl-gds.obj-type  = p-obj-type
          and buf_pl-gds.obj-code  = p-obj-code
          and buf_pl-gds.pl-code   = p-from-pl-code
          and buf_pl-gds.gds-code  = p-gds-code
        no-error.
      if available buf_pl-gds then do:
        assign
          v-pl-code = buf_pl-gds.pl-code
        .
      end.
    end.
    if v-pl-code <> 0
      and p-nozzle-code <> ?
      and p-nozzle-code <> 0
    then do:
      find first buf_pl-pump-nozzle no-lock
        where buf_pl-pump-nozzle.obj-type    = p-obj-type
          and buf_pl-pump-nozzle.obj-code    = p-obj-code
          and buf_pl-pump-nozzle.pl-code     = v-pl-code
          and buf_pl-pump-nozzle.pump-code   = p-pump-code
          and buf_pl-pump-nozzle.nozzle-code = p-nozzle-code
        no-error .
      if not available buf_pl-pump-nozzle then do:
        return.
      end.
    end.
    if v-pl-code = 0 then do:
      if p-nozzle-code = 0 then do:
        find first buf_pl-gds-pump no-lock
          where buf_pl-gds-pump.obj-type  = p-obj-type
            and buf_pl-gds-pump.obj-code  = p-obj-code
            and buf_pl-gds-pump.pump-code = p-pump-code
            and buf_pl-gds-pump.gds-code  = p-gds-code
            and buf_pl-gds-pump.status_   = 'тек':U
          no-error.
        if available buf_pl-gds-pump then do:
          assign
            v-pl-code = buf_pl-gds-pump.pl-code
          .
        end.
      end.
      else do:
        _ppnz:
        for each buf_pl-pump-nozzle no-lock
          where buf_pl-pump-nozzle.obj-type = p-obj-type
            and buf_pl-pump-nozzle.obj-code = p-obj-code
            and buf_pl-pump-nozzle.pump-code = p-pump-code
            and buf_pl-pump-nozzle.nozzle-code = p-nozzle-code
          ,first buf_pl-gds-pump no-lock
          where buf_pl-gds-pump.obj-type  = p-obj-type
            and buf_pl-gds-pump.obj-code  = p-obj-code
            and buf_pl-gds-pump.pump-code = p-pump-code
            and buf_pl-gds-pump.gds-code  = p-gds-code
            and buf_pl-gds-pump.status_   = 'тек':U
            and buf_pl-gds-pump.pl-code   = buf_pl-pump-nozzle.pl-code
        on error undo, return error return-value
        :
          assign
            v-pl-code = buf_pl-pump-nozzle.pl-code
          .
          leave _ppnz.
        end.
      end.
    end.
    if v-pl-code <> 0 then do:
      assign
        p-pl-code = v-pl-code
      .
    end.
  end.
end procedure.
procedure find-nzl:
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define input  parameter p-pump-code  as integer   no-undo.
define input  parameter p-gds-code   as integer   no-undo.
define input  parameter p-pl-code    as integer no-undo .
define output parameter p-nozzle-code    as integer   no-undo.
define variable v-nozzle-code        like ub.nozzle.nozzle-code no-undo .
define variable v-pl-code            like ub.place.pl-code no-undo .
define variable v-pump-code          like ub.pump.pump-code no-undo .
define variable v-loc1-code          like ub.place.loc1 no-undo .
define variable v-dopstr             as character no-undo .
define buffer buf_place for ub.place.
define buffer buf_pl-gds-pump for ub.pl-gds-pump.
define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
define buffer buf_pl-gds for ub.pl-gds.
do on error undo, return error return-value :
  v-pump-code = p-pump-code.
  find first buf_pl-pump-nozzle no-lock where
                buf_pl-pump-nozzle.obj-type = p-obj-type
            and buf_pl-pump-nozzle.obj-code = p-obj-code
            and buf_pl-pump-nozzle.pump-code = p-pump-code
            and buf_pl-pump-nozzle.pl-code = p-pl-code no-error.
  if not available buf_pl-pump-nozzle then do:
    assign
    p-nozzle-code = ?.
    return .
  end.
  assign
  p-nozzle-code = buf_pl-pump-nozzle.nozzle-code.
  return.
  .
end.
end procedure.
procedure find-nzl-without-pl:
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define input  parameter p-pump-code  as integer   no-undo.
define input  parameter p-gds-code   as integer   no-undo.
define output parameter p-nozzle-code    as integer   no-undo.
define buffer buf_pl-gds-pump for ub.pl-gds-pump.
define buffer buf_pl-gds for ub.pl-gds.
define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
do on error undo, return error return-value :
  for each buf_pl-gds-pump no-lock where
            buf_pl-gds-pump.obj-type  = p-obj-type
        and buf_pl-gds-pump.obj-code  = p-obj-code
        and buf_pl-gds-pump.pump-code = p-pump-code
        and buf_pl-gds-pump.gds-code  = p-gds-code
        and buf_pl-gds-pump.status_   = 'тек':U,
      first buf_pl-gds no-lock where
                buf_pl-gds.obj-type = p-obj-type
            AND buf_pl-gds.obj-code = p-obj-code
            AND buf_pl-gds.pl-code = buf_pl-gds-pump.pl-code
            AND buf_pl-gds.gds-code = p-gds-code
            AND buf_pl-gds.status_ = 'тек':U,
     first buf_pl-pump-nozzle no-lock where
              buf_pl-pump-nozzle.obj-type = p-obj-type
          and buf_pl-pump-nozzle.obj-code = p-obj-code
          and buf_pl-pump-nozzle.pl-code = buf_pl-gds.pl-code
          and buf_pl-pump-nozzle.pump-code = p-pump-code:
    assign
    p-nozzle-code = buf_pl-pump-nozzle.nozzle-code.
    return .
  end.
  assign
  p-nozzle-code = ?.
  return.
  .
end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define temp-table tt_obj no-undo
    field obj-type as character
    field obj-code as integer
.
define variable v-shift-on        as logical   no-undo.
define variable v-user-action     as character no-undo .
define variable v-printed         as logical   no-undo .
define variable v-curr-grp-name   as character no-undo.
define input parameter table for tt_obj.
define input parameter p_path as character no-undo.
define input parameter p_log-handle as handle no-undo.
define input parameter p-d_sht-start as date      no-undo.
define input parameter p-i_sht-start as integer   no-undo.
define input parameter p-d_sht-end   as date      no-undo.
define input parameter p-i_sht-end   as integer   no-undo.
define input parameter p-region      as character no-undo.
define input parameter p-mode as character no-undo.
define stream f1.
define buffer buf_shift-obj   for ub.shift-obj.
define buffer buf_clients     for ub.clients.
define buffer buf_goods       for ub.goods.
define buffer buf_bar-code    for ub.bar-code.
define buffer buf_prod-bc     for ub.prod-bc.
define variable is-petrolium           as logical   no-undo.
define variable is-pieces              as logical   no-undo.
define variable v-prod-bc              as character no-undo.
define variable v-date-file-name as character no-undo.
DEFINE VARIABLE file_name        AS CHARACTER NO-UNDO.
define variable v-time           as integer   no-undo.
define variable v-time-file      as char      no-undo.
DEFINE VARIABLE log-file-name    AS CHARACTER NO-UNDO.
define variable v-date           as date      no-undo.
define variable v-date-end       as character no-undo.
define variable v-sdate-end      as character no-undo.
define variable v-arc   as character no-undo .
define variable v-cmd   as character no-undo .
assign
  v-arc = search( "exe/7z.exe":U )
.
if v-arc = ? then do:
  return error "Не найдена программа 7z.exe, невозможно упаковать выгрузку в zip" .
end.
assign
  log-file-name    = substitute("&1exp-ATD.log", ibs.th.gbl.gbl-inipar:logDir)
  v-time = time
  v-date = today
  v-time-file      = replace(  string(v-time, "HH:MM:SS"), ":", ""  )
  v-date-file-name = STRING(YEAR(v-date), "9999") + STRING(DAY(v-date), "99") + STRING(MONTH(v-date), "99")
  file_name        = substitute("&1HDB_&2_&3_&4.csv", p_path, trim(p-region), v-date-file-name, v-time-file)
.
function format_datetime returns character(
    input v-date as date,
    input v-time as integer
    ):
    return substitute("&1.&2.&3 &4",
        string(day(v-date),"99"),
        string(month(v-date),"99"),
        string(year(v-date),"9999"),
        string(v-time, "HH:MM:SS:000")
        ).
end function.
define variable c-value as char no-undo.
define variable  c-type as char no-undo.
define variable v-st-shift-date as date no-undo .
define variable v-st-shift-num  as integer no-undo .
define variable v-prev-shift-date as date no-undo .
define variable v-prev-shift-num  as integer no-undo .
output to value(file_name) .
for each tt_obj no-lock:
    find first buf_clients no-lock where buf_clients.obj-type = tt_obj.obj-type
                                     and buf_clients.obj-code = tt_obj.obj-code no-error .
  if available buf_clients then
    put unformatted "Store," string(buf_clients.obj-code) "," p-region ",1," buf_clients.obj-name skip .
end.
goods_:
for each buf_goods no-lock where buf_goods.stts = 0 :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrolium
  , output is-pieces
  ) .
    if not is-petrolium
    then next .
    v-prod-bc = ? .
    bar-code_ :
    for each buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code :
        find first buf_prod-bc no-lock where buf_prod-bc.b-code = buf_bar-code.b-code no-error .
        if available buf_prod-bc
        then do :
            v-prod-bc = buf_prod-bc.b-str .
            leave bar-code_ .
        end.
        else do :
            v-prod-bc = ? .
        end.
    end.
    if v-prod-bc = ?
    then next goods_ .
    put unformatted "ItemInfo," p-region "," string(buf_goods.gds-code) "," v-prod-bc ",1,Активный," buf_goods.artic "," buf_goods.gds-name "," string(buf_goods.grp-code) skip .
end.
for each tt_obj no-lock:
       run write-log-and-file in p_log-handle     (input 1, input log-file-name, input 1, input substitute("Объект: &1   &2", tt_obj.obj-type, tt_obj.obj-code )) .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  tt_obj.obj-type
  ,input  tt_obj.obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if v-shift-on then . else next .
    if p-mode = "shd"
    then do:
        run clntattr-value in this-procedure (input tt_obj.obj-type,
            input tt_obj.obj-code,
            input 'bge-exp-last-atd':U,
            output c-value,
            output c-type) NO-ERROR.
        if error-status:error then
        do:
                        run write-log-and-file in p_log-handle     (input 1, input log-file-name, input 1, input substitute("Ошибка в атрибуте объекта. Объект &1&2",tt_obj.obj-type,tt_obj.obj-code)).
            next.
        end.
                        run write-log-and-file in p_log-handle     (input 1, input log-file-name, input 1, input substitute("Последняя выгруженная смена объекта &1&2 (дата, номер): &3 (атрибут объекта &4)", tt_obj.obj-type, tt_obj.obj-code, c-value, 'bge-exp-last-atd':U)).
        if c-value = "" then c-value = "1/1/1900,1".
        assign
          v-prev-shift-date = date(entry(1,c-value,","))
          v-prev-shift-num  = integer(entry(2,c-value,","))
          p-d_sht-start = ?
        .
      for each buf_shift-obj no-lock
         where buf_shift-obj.obj-type = tt_obj.obj-type
           and buf_shift-obj.obj-code = tt_obj.obj-code
           and buf_shift-obj.shift-date >= v-prev-shift-date
           and buf_shift-obj.status_  = 'зкр':U
             by buf_shift-obj.shift-date
             by buf_shift-obj.shift-num:
        if (buf_shift-obj.shift-date = v-prev-shift-date) and
           (buf_shift-obj.shift-num <= v-prev-shift-num) then next.
        assign
          p-d_sht-start = buf_shift-obj.shift-date
          p-i_sht-start = buf_shift-obj.shift-num
        .
        leave.
      end.
      if (p-d_sht-start = ?) then do:
                        run write-log-and-file in p_log-handle     (input 1, input log-file-name, input 1, input substitute("Отсутствуют смены для выгрузки после &1 смена &2. Объект &3&4", v-prev-shift-date, v-prev-shift-num, tt_obj.obj-type, tt_obj.obj-code )).
            next.
      end.
    end.
    else do:
      v-prev-shift-date = ?.
      for each buf_shift-obj no-lock
         where buf_shift-obj.obj-type = tt_obj.obj-type
           and buf_shift-obj.obj-code = tt_obj.obj-code
           and buf_shift-obj.shift-date <= p-d_sht-start
           and buf_shift-obj.status_  = 'зкр':U
             by buf_shift-obj.shift-date descending
             by buf_shift-obj.shift-num descending:
        if (buf_shift-obj.shift-date = p-d_sht-start) and
           (buf_shift-obj.shift-num >= p-i_sht-start) then next.
        assign
          v-prev-shift-date = buf_shift-obj.shift-date
          v-prev-shift-num  = buf_shift-obj.shift-num
        .
        leave.
      end.
      if (v-prev-shift-date = ?) then do:
        c-value = "1/1/1900,1".
        assign
          v-prev-shift-date = date(entry(1,c-value,","))
          v-prev-shift-num  = integer(entry(2,c-value,","))
        .
      end.
    end.
    run write-log-and-file in p_log-handle     (input 1, input log-file-name, input 1, input substitute("Дата начала выгрузки: &1   &2", p-d_sht-start, p-i_sht-start )) .
      assign
        v-sdate-end = ""
      .
      for each buf_shift-obj no-lock
         where buf_shift-obj.obj-type = tt_obj.obj-type
           and buf_shift-obj.obj-code = tt_obj.obj-code
           and buf_shift-obj.shift-date = p-d_sht-start
           and buf_shift-obj.status_  = 'зкр':U
             by buf_shift-obj.shift-num:
        if buf_shift-obj.shift-num < p-i_sht-start then next .
        do
        on error undo, return error return-value
        :
          run shift-output in this-procedure (
            input v-prev-shift-date, input v-prev-shift-num,
            buffer buf_shift-obj) .
        end.
        assign
          v-prev-shift-date = buf_shift-obj.shift-date
          v-prev-shift-num  = buf_shift-obj.shift-num
          v-sdate-end = substitute("&1,&2", buf_shift-obj.shift-date , buf_shift-obj.shift-num)
          v-date-end = substitute("&1   &2", buf_shift-obj.shift-date , buf_shift-obj.shift-num)
        .
      end.
      for each buf_shift-obj no-lock
         where buf_shift-obj.obj-type = tt_obj.obj-type
           and buf_shift-obj.obj-code = tt_obj.obj-code
           and buf_shift-obj.shift-date > p-d_sht-start
           and buf_shift-obj.shift-date <= p-d_sht-end
           and buf_shift-obj.status_  = 'зкр':U
             by buf_shift-obj.shift-date
             by buf_shift-obj.shift-num:
        if buf_shift-obj.shift-date = p-d_sht-end then do:
          if buf_shift-obj.shift-num > p-i_sht-end then leave.
        end.
        do
        on error undo, return error return-value
        :
          run shift-output in this-procedure (
            input v-prev-shift-date, input v-prev-shift-num,
            buffer buf_shift-obj) .
        end.
        assign
          v-prev-shift-date = buf_shift-obj.shift-date
          v-prev-shift-num  = buf_shift-obj.shift-num
          v-sdate-end = substitute("&1,&2", buf_shift-obj.shift-date , buf_shift-obj.shift-num)
          v-date-end = substitute("&1   &2", buf_shift-obj.shift-date , buf_shift-obj.shift-num)
        .
      end.
      if v-sdate-end > "" then
            run clntattr-write in this-procedure (input tt_obj.obj-type,
                input tt_obj.obj-code,
                input 'bge-exp-last-atd':U,
                input v-sdate-end)
            no-error.
                    run write-log-and-file in p_log-handle     (input 1, input log-file-name, input 1, input substitute("Дата конца выгрузки: &1 ", v-date-end)) .
end.
output close .
v-cmd = v-arc + " a -tzip -ssw -mx7 " + '"' + substring(file_name, 1, length(file_name) - 3) + 'zip" '  + '"' +  file_name  + '"'  .
os-command silent value ( v-cmd ) .
os-delete value ( file_name ) .
procedure shift-output private:
define input parameter p-prev-shift-date as date no-undo .
define input parameter p-prev-shift-num  as integer no-undo .
define parameter buffer p-buf_shift-obj for ub.shift-obj .
define variable is-petrolium           as logical   no-undo.
define variable is-pieces              as logical   no-undo.
define variable v-shift-head           as character no-undo .
define variable v-trn-stype            as character no-undo .
define variable v-doc-qnty   as decimal decimals 10 no-undo .
define variable v-pl-code              as integer   no-undo .
define variable v-loc1                 as character no-undo .
define buffer buf_rvs-doc     for ub.rvs-doc.
define buffer buf_rvs-line    for ub.rvs-line.
define buffer buf_rvs-line-pump for ub.rvs-line-pump.
define buffer buf_place       for ub.place.
define buffer buf_chk-doc     for ub.chk-doc.
define buffer buf_chk-gds     for ub.chk-gds.
define buffer buf_bar-code    for ub.bar-code.
define buffer buf_goods       for ub.goods.
define buffer buf_clients     for ub.clients.
define buffer buf_trn-doc     for ub.trn-doc.
define buffer buf_doc-line    for ub.doc-line.
define buffer buf_doc-pl      for ub.doc-pl .
define buffer buf_sale-doc    for ub.sale-doc .
  v-shift-head = substitute (  "&1,&2,&3,&4",
                               p-region,  p-buf_shift-obj.obj-code,
                               string(p-buf_shift-obj.shift-date, "99.99.9999"),  p-buf_shift-obj.shift-num  ) .
  put unformatted "FuelShifts,"
    v-shift-head ","
    format_datetime(p-buf_shift-obj.open-date, p-buf_shift-obj.open-time) ","
    format_datetime(p-buf_shift-obj.close-date, p-buf_shift-obj.close-time) skip
  .
  find first buf_rvs-doc no-lock where buf_rvs-doc.obj-type       = p-buf_shift-obj.obj-type
                                   and buf_rvs-doc.obj-code       = p-buf_shift-obj.obj-code
                                   and buf_rvs-doc.shift-date     = p-prev-shift-date
                                   and buf_rvs-doc.shift-num      = p-prev-shift-num
                                   and buf_rvs-doc.status_        = 'факт':U
                                   and buf_rvs-doc.rvs-type       = 'смена':U
                                       no-error .
  if available buf_rvs-doc
  then
    for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                    and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                                    and buf_rvs-line.obj-code = buf_rvs-doc.obj-code :
      find first buf_place no-lock where buf_place.pl-code = buf_rvs-line.pl-code no-error .
      put unformatted "FuelTankReading,"
        v-shift-head ","
        (if available buf_place then buf_place.loc1 else "0") ","
        string(buf_rvs-line.gds-code) ","
        trim(string(buf_rvs-line.state-measure-qnty, ">>>>>>>>9.99")) skip
      .
      for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code     = buf_rvs-line.rvs-code
                                           and buf_rvs-line-pump.obj-type     = buf_rvs-line.obj-type
                                           and buf_rvs-line-pump.obj-code     = buf_rvs-line.obj-code
                                           and buf_rvs-line-pump.pl-code      = buf_rvs-line.pl-code
                                           and buf_rvs-line-pump.gds-code     = buf_rvs-line.gds-code :
        put unformatted "FuelPumpReading,"
          v-shift-head ","
          string(buf_rvs-line-pump.pump-code) ","
          string(buf_rvs-line.gds-code) ","
          trim(string(buf_rvs-line.state-measure-qnty, ">>>>>>>>9.99")) ","
          string(buf_rvs-line-pump.nozzle-code) ","
          trim(string(buf_rvs-line-pump.state-el-cnt, ">>>>>>>>9.99")) ","
          string(buf_rvs-doc.shift-date, "99.99.9999") skip
        .
      end.
    end.
  chk-doc_ :
  for each buf_chk-doc no-lock where buf_chk-doc.obj-type = p-buf_shift-obj.obj-type
                                 and buf_chk-doc.obj-code = p-buf_shift-obj.obj-code
                                 and buf_chk-doc.shift-date = p-buf_shift-obj.shift-date
                                 and buf_chk-doc.shift-num  = p-buf_shift-obj.shift-num
                                 and (
                                   (buf_chk-doc.chk-type = 1) or
                                   (buf_chk-doc.chk-type = 6) or
                                   (buf_chk-doc.chk-type = 17)
                                     ) :
    v-trn-stype = if buf_chk-doc.chk-type = 6 then "2" else "1" .
    chk-gds_ :
    for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code :
      find first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code no-error.
      if available buf_bar-code then do:
        find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
        if available buf_goods then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrolium
  , output is-pieces
  ) .
          if not is-petrolium
          then next chk-gds_.
        end.
        else next chk-gds_.
      end.
      else next chk-gds_.
      v-doc-qnty = if buf_chk-doc.chk-type = 6 then ( (-1) * buf_chk-gds.doc-qnty ) else buf_chk-gds.doc-qnty .
      if buf_chk-gds.loc1 > ""  then v-loc1 = buf_chk-gds.loc1.
      else do:
             if buf_chk-gds.src-pl-code > 0 then v-pl-code = buf_chk-gds.src-pl-code.
        else if buf_chk-gds.pl-code     > 0 then v-pl-code = buf_chk-gds.pl-code.
        else do:
          run findtank in this-procedure
            (input buf_chk-doc.obj-type,
             input buf_chk-doc.obj-code,
             input buf_chk-gds.pump,
             input buf_chk-gds.nozzle-code,
             input buf_chk-gds.pl-code,
             input buf_bar-code.gds-code,
             output v-pl-code) no-error.
        end.
        if v-pl-code > 0 then do:
          find first buf_place no-lock where buf_place.pl-code = v-pl-code no-error .
          v-loc1 = if available buf_place then buf_place.loc1 else "0" .
        end.
        else v-loc1 = "0" .
      end.
      put unformatted "FuelTransaction,"
        v-shift-head ","
        format_datetime(buf_chk-doc.chk-date, buf_chk-doc.chk-time) ","
        v-trn-stype ","
        string(buf_goods.gds-code) ","
        trim(string(v-doc-qnty, "->>>>>>9.99")) ","
        string(buf_chk-gds.pump) ","
        v-loc1 skip
      .
    end.
  end.
  trn-doc_ :
  for each buf_trn-doc no-lock
     where buf_trn-doc.obj-type     = p-buf_shift-obj.obj-type
       and buf_trn-doc.obj-code     = p-buf_shift-obj.obj-code
       and buf_trn-doc.shift-date   = p-buf_shift-obj.shift-date
       and buf_trn-doc.shift-num    = p-buf_shift-obj.shift-num
       and buf_trn-doc.status_      = 'факт':U
       and can-do ("es,rs,vt":U,
                   buf_trn-doc.ext-doc-type) = false :
    def var v-value as character no-undo.
    def var v-type  as character no-undo.
    def var v-tech-pass as logical no-undo.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'techpass':U ,
                       output v-value ,
                       output v-type ) no-error .
    assign
      v-tech-pass = yes when v-value = "yes".
    if buf_trn-doc.ext-doc-type = 'we':U
       and
       (v-tech-pass or
       (can-find (first buf_clients where buf_clients.obj-type = buf_trn-doc.cli-type
                                     and buf_clients.obj-code = buf_trn-doc.cli-code) and
       can-find (first buf_sale-doc where buf_sale-doc.doc-code = buf_trn-doc.doc-code
                                      and buf_sale-doc.doc-kind = 'trf':U)))
    then next trn-doc_ .
    v-trn-stype = if can-do("при,возврат":U, buf_trn-doc.doc-type) then "2" else "1" .
    doc-line_ :
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_doc-line.artic
  ,  input buf_doc-line.prod-type
  ,  input buf_doc-line.prod-code
  , output is-petrolium
  , output is-pieces
  ) .
      if not is-petrolium then next doc-line_.
      find first buf_goods no-lock where buf_goods.artic      = buf_doc-line.artic
                                     and buf_goods.prod-type  = buf_doc-line.prod-type
                                     and buf_goods.prod-code  = buf_doc-line.prod-code
                                         no-error .
      if not available buf_goods then next doc-line_.
      find first buf_doc-pl no-lock where buf_doc-pl.out-code = buf_trn-doc.doc-code
                                      and buf_doc-pl.gds-code = buf_goods.gds-code
                                      and buf_doc-pl.obj-type = buf_trn-doc.obj-type
                                      and buf_doc-pl.obj-code = buf_trn-doc.obj-code
                                          no-error.
      if available buf_doc-pl then do:
        find first buf_place no-lock where buf_place.pl-code = buf_doc-pl.pl-code no-error .
        v-loc1 = if available buf_place then buf_place.loc1 else "0" .
      end.
      else v-loc1 = "0".
        put unformatted "FuelTransaction,"
          v-shift-head ","
          format_datetime(buf_trn-doc.sys-date, buf_trn-doc.sys-time-int) ","
          v-trn-stype ","
          string(buf_goods.gds-code) ","
          trim(string(buf_doc-line.fact-qnty, "->>>>>>9.99")) ","
          "0,"
          v-loc1 skip
        .
    end.
  end.
end procedure .
