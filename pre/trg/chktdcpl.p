block-level on error undo, throw.
define input parameter p-doc-code as character no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Проверка всех товаров в накладной на предмет учета по местам хранения и топливного учета.":U.
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define variable v-reserv-pl       as logical   no-undo .
  define variable is-petrol         as logical   no-undo.
  define variable is-pieces         as logical   no-undo.
  define variable v-is-ptrl         as character no-undo.
  define variable v-data-type       as character no-undo.
  define variable v-chk-null-qnty   as logical   no-undo .
  define variable v-sign            as decimal   no-undo .
  define variable v-chk-rvs         as logical   no-undo .
  define variable v-attr-value      as character no-undo .
  define variable v-attr-type       as character no-undo .
  define variable v-pl-fact-qnty        as decimal   no-undo .
  define variable v-pl-doc-qnty         as decimal   no-undo .
  define variable v-pl-cli-qnty         as decimal   no-undo .
  define variable v-pl-cli-fact-qnty    as decimal   no-undo .
  define variable v-pl-cli-doc-qnty     as decimal   no-undo .
  define variable v-pl-rest-bf-qnty     as decimal   no-undo .
  define variable v-pl-cli-rest-bf-qnty as decimal   no-undo .
  define variable v-pl-rest-af-qnty     as decimal   no-undo .
  define variable v-pl-cli-rest-af-qnty as decimal   no-undo .
  define variable v-density         as decimal   no-undo .
  define variable v-before-cli-qnty as decimal   no-undo .
  define variable v-after-qnty      as decimal   no-undo .
  define variable v-after-cli-qnty  as decimal   no-undo .
  define variable v-last-invlin     as recid     no-undo .
  define variable trn-is-lgas-corr  as logical   no-undo.
  define variable is-vir as logical no-undo.
  define variable v-value as character no-undo.
  define variable v-ok as logical no-undo.
  define buffer buf_doc-line      for ub.doc-line.
  define buffer buf_inv-line      for ub.inv-line.
  define buffer buf_trn-doc       for ub.trn-doc.
  define buffer buf_goods         for ub.goods.
  define buffer buf_rvs-doc       for ub.rvs-doc.
  define buffer buf_rvs-line      for ub.rvs-line .
  define buffer buf_doc-pl        for ub.doc-pl .
  define buffer buf_pl-gds        for ub.pl-gds .
  define buffer buf-cre_trn-doc   for ub.trn-doc .
  define buffer buf_gds-obj       for ub.gds-obj .
  define buffer buf-next_doc-line for ub.doc-line .
  define buffer buf-next_inv-line for ub.inv-line .
  define buffer buf-prev_inv-line for ub.inv-line .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ptrl'
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
    or v-data-type <> "L"
    or lookup( v-is-ptrl, "yes,no" ) = 0
    or v-is-ptrl = "no"
  then do:
    return .
  end.
  find buf_trn-doc exclusive-lock
    where buf_trn-doc.doc-code = p-doc-code
  no-error.
  if not available buf_trn-doc then do:
    undo, return error substitute( "&1. Не найден документ &2", vss-workfile, p-doc-code ).
  end.
  if buf_trn-doc.ext-doc-type = 'iv':U
    and buf_trn-doc.status_ = 'накл':U
  then do:
    return .
  end.
  if buf_trn-doc.ext-doc-type = 'io':U
  then do:
    return .
  end.
  else do:
    if lookup( buf_trn-doc.ext-doc-type, 'ee,ep,es,we,ev,em,wm,eo':U ) > 0 then do:
      assign
        v-sign = -1.0
      .
    end.
    else do:
      assign
        v-sign = 1.0
      .
      if lookup( buf_trn-doc.ext-doc-type, 'ie,re,rs,vt,vp,ap,mp,pc,iv,rv,im,io':U ) = 0 then do:
        undo, return error substitute( '&1. Тип "&2" не внесен в списки документов уменьшающих(увеличивающих) остатки!', vss-workfile, buf_trn-doc.ext-doc-type).
      end.
    end.
    assign
      v-chk-null-qnty = true
    .
    if buf_trn-doc.ext-doc-type = 'we':U
      or buf_trn-doc.ext-doc-type = 're':U
    then do:
      find first buf-cre_trn-doc no-lock
        where buf-cre_trn-doc.doc-code = buf_trn-doc.out-code
        no-error .
      if available buf-cre_trn-doc
        and buf-cre_trn-doc.ext-doc-type = 'vt':U
      then do:
        assign
          v-chk-null-qnty = false
        .
      end.
    end.
    assign
      v-chk-rvs = false
    .
    if buf_trn-doc.doc-type = 'при':U then do:
      assign
        v-chk-rvs = true
      .
      if buf_trn-doc.ext-doc-type = 'ie':U then do:
        run clntattr-value in this-procedure
          ( input  buf_trn-doc.cli-type
           ,input  buf_trn-doc.cli-code
           ,input  'shftrep2':U
           ,output v-attr-value
           ,output v-attr-type
          ) .
        if v-attr-value = "yes":U then do:
          assign
            v-chk-rvs = false
          .
        end.
      end.
      if v-chk-rvs = true then do:
        assign
          v-chk-rvs = false
        .
        block_chk_ptrl :
        for each buf_doc-line exclusive-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
        on error undo, return error return-value
        :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_doc-line.artic
  ,  input buf_doc-line.prod-type
  ,  input buf_doc-line.prod-code
  , output is-petrol
  , output is-pieces
  ) .
          if is-petrol = true
            and is-pieces = false
          then do:
            find first buf_goods no-lock
              where buf_goods.artic     = buf_doc-line.artic
                and buf_goods.prod-type = buf_doc-line.prod-type
                and buf_goods.prod-code = buf_doc-line.prod-code
            .
            trn-is-lgas-corr = false.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_doc-line.doc-code ,
                        input 'is-lgas-corr':U ,
                       output v-attr-value ,
                       output v-attr-type ) no-error .
            if v-attr-value = "yes" then do:
            assign
              trn-is-lgas-corr = true.
            end.
            run gds-attr-value in this-procedure
              ( input  buf_goods.gds-code
              ,input  'ptrl-without-rvs':U
              ,output v-attr-value
              ,output v-attr-type
              ) .
            find first buf_doc-pl no-lock
                where buf_doc-pl.obj-type = buf_doc-line.obj-type
                and buf_doc-pl.obj-code = buf_doc-line.obj-code
                and buf_doc-pl.out-code = buf_doc-line.doc-code
                and buf_doc-pl.gds-code = buf_goods.gds-code no-error.
            run placelib_get-attr(input "place-virtual"
                                 ,input buf_doc-pl.obj-code
                                 ,input buf_doc-pl.obj-type
                                 ,input buf_doc-pl.pl-code
                                 ,output v-value
                                 ,output v-ok) no-error.
            is-vir = if (v-ok and logical(v-value)) then true else false.
            if lookup(v-attr-value, 'true,yes':u) = 0 and not is-gas(buf_goods.gds-code) and not is-vir and
              not trn-is-lgas-corr then do:
              assign
                v-chk-rvs = true
              .
              leave block_chk_ptrl.
            end.
          end.
        end.
      end.
      if buf_trn-doc.status_ = 'факт':U
        and v-chk-rvs = true
      then do:
        find first buf_rvs-doc no-lock
          where buf_rvs-doc.out-code = buf_trn-doc.doc-code
            and buf_rvs-doc.rvs-type = 'перед_док':U
          no-error .
        if not available buf_rvs-doc then do:
          undo, return error substitute( 'Вы не сделали сверку перед документом "&1" (тип "&2") .'
                                          , buf_trn-doc.doc-code
                                          , 'перед_док':U
                                        ) .
        end.
        find first buf_rvs-doc no-lock
          where buf_rvs-doc.out-code = buf_trn-doc.doc-code
            and buf_rvs-doc.rvs-type = 'после_док':U
          no-error .
        if not available buf_rvs-doc then do:
          undo, return error substitute( 'Вы не сделали сверку после документа "&1" (тип "&2") .'
                                          , buf_trn-doc.doc-code
                                          , 'после_док':U
                                        ) .
        end.
      end.
    end.
    for each buf_doc-line exclusive-lock
      where buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error undo, return error return-value
    :
      find first buf_goods no-lock
        where buf_goods.artic     = buf_doc-line.artic
          and buf_goods.prod-type = buf_doc-line.prod-type
          and buf_goods.prod-code = buf_doc-line.prod-code
      .
      run gds-attr-value in this-procedure
        (  input buf_goods.gds-code
          ,input 'fuel-type':U
          ,output v-attr-value
          ,output v-attr-type
         ) .
      if v-attr-value = "lgas"
        then next.
      if is-gas(buf_goods.gds-code) then next.
      find first buf_doc-pl no-lock
                where buf_doc-pl.obj-type = buf_doc-line.obj-type
                and buf_doc-pl.obj-code = buf_doc-line.obj-code
                and buf_doc-pl.out-code = buf_doc-line.doc-code
                and buf_doc-pl.gds-code = buf_goods.gds-code no-error.
      run placelib_get-attr(input "place-virtual"
                           ,input buf_doc-pl.obj-code
                           ,input buf_doc-pl.obj-type
                           ,input buf_doc-pl.pl-code
                           ,output v-value
                           ,output v-ok) no-error.
      is-vir = if (v-ok and logical(v-value)) then true else false.
      if is-vir then next.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  'place-rsrv=request'
  ,output v-reserv-pl
  )  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_doc-line.artic
  ,  input buf_doc-line.prod-type
  ,  input buf_doc-line.prod-code
  , output is-petrol
  , output is-pieces
  ) .
      if is-petrol = true
        and is-pieces = false
      then do:
        find first buf_inv-line
          where buf_inv-line.doc-code  = buf_doc-line.doc-code
            and buf_inv-line.artic     = buf_doc-line.artic
            and buf_inv-line.prod-type = buf_doc-line.prod-type
            and buf_inv-line.prod-code = buf_doc-line.prod-code
          no-error.
        if not available buf_inv-line then do:
          undo, return error substitute( "Не найдена строка с информацией о кол-ве (&1) товара в документе &2 для товара &3."
                                        ,buf_goods.unit-cli
                                        ,buf_doc-line.doc-code
                                        ,buf_goods.gds-code
                                      ).
        end.
      end.
      if v-reserv-pl = true
        or ( is-petrol = true
            and is-pieces = false
          )
      then do:
        assign
          v-pl-fact-qnty        = 0.0
          v-pl-doc-qnty         = 0.0
          v-pl-cli-qnty         = 0.0
          v-pl-cli-fact-qnty    = 0.0
          v-pl-cli-doc-qnty     = 0.0
          v-pl-rest-af-qnty     = 0.0
          v-pl-cli-rest-af-qnty = 0.0
          v-pl-rest-bf-qnty     = 0.0
          v-pl-cli-rest-bf-qnty = 0.0
        .
        for each buf_doc-pl
          where buf_doc-pl.obj-type = buf_trn-doc.obj-type
            and buf_doc-pl.obj-code = buf_trn-doc.obj-code
            and buf_doc-pl.out-code = buf_trn-doc.doc-code
            and buf_doc-pl.gds-code = buf_goods.gds-code
        on error undo, return error return-value
        :
          assign
            v-pl-cli-qnty         = v-pl-cli-qnty         + buf_doc-pl.cli-qnty
            v-pl-fact-qnty        = v-pl-fact-qnty        + buf_doc-pl.fact-qnty
            v-pl-doc-qnty         = v-pl-doc-qnty         + buf_doc-pl.doc-qnty
            v-pl-cli-fact-qnty    = v-pl-cli-fact-qnty    + buf_doc-pl.cli-fact-qnty
            v-pl-cli-doc-qnty     = v-pl-cli-doc-qnty     + buf_doc-pl.cli-doc-qnty
            v-pl-rest-bf-qnty     = v-pl-rest-bf-qnty     + buf_doc-pl.rest-bf-qnty
            v-pl-cli-rest-bf-qnty = v-pl-cli-rest-bf-qnty + buf_doc-pl.cli-rest-bf-qnty
            v-pl-rest-af-qnty     = v-pl-rest-af-qnty     + buf_doc-pl.rest-af-qnty
            v-pl-cli-rest-af-qnty = v-pl-cli-rest-af-qnty + buf_doc-pl.cli-rest-af-qnty
          .
          if buf_trn-doc.ext-doc-type <> 'ie':U then do:
            if absolute( buf_doc-pl.cli-qnty - buf_doc-pl.cli-doc-qnty ) > 0.001 then do:
              undo, return error substitute( 'Количество в единицах измерения поставщика по строке накладной: &2 для товара &3&1'
                                              + 'НЕ СОВПАДАЕТ с количеством на месте хранения &4!!!&1'
                                              + 'По ТТН &5 (&7)&1'
                                              + 'В ед. изм. поставщика &6 (&7)&1'
                                              , chr(10)
                                              , buf_trn-doc.doc-code
                                              , buf_doc-pl.gds-code
                                              , buf_doc-pl.pl-code
                                              , buf_doc-pl.cli-qnty
                                              , buf_doc-pl.cli-doc-qnty
                                              , buf_goods.unit-cli
                                            ).
            end.
            if is-petrol = true
              and is-pieces = false
            then do:
              if buf_trn-doc.doc-type = 'инв':U then do:
                if buf_doc-pl.rest-af-qnty <> 0.0
                  and buf_doc-pl.cli-rest-af-qnty <> 0.0
                then do:
                  assign
                    v-density = buf_doc-pl.cli-rest-af-qnty / buf_doc-pl.rest-af-qnty
                  .
                end.
                else do:
                  assign
                    v-density = buf_doc-line.fact-density
                  .
                end.
                if buf_trn-doc.status_ = 'факт':U
                  and valid-density( v-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> true
                then do:
                  undo, return error substitute( 'Плотность "стало" топлива по месту хранения не соответствует ожидаемому.&1'
                                                + 'Документ: &2&1'
                                                + 'Товар: &3&1'
                                                + 'Место хранения: &4&1'
                                                + 'Плотность: &5&1'
                                                + 'Кол-во: &6 (&8) и &7 (&9)&1'
                                                ,chr(10)
                                                ,buf_trn-doc.doc-code
                                                ,buf_goods.gds-code
                                                ,buf_doc-pl.pl-code
                                                ,v-density
                                                ,buf_doc-pl.fact-qnty
                                                ,buf_doc-pl.cli-fact-qnty
                                                ,buf_goods.unit-base
                                                ,buf_goods.unit-cli
                                                ).
                end.
              end.
              else do:
                if buf_doc-pl.cli-doc-qnty <> 0.0
                  and buf_doc-pl.doc-qnty <> 0.0
                then do:
                  assign
                    v-density = buf_doc-pl.cli-doc-qnty / buf_doc-pl.doc-qnty
                  .
                end.
                else do:
                  assign
                    v-density = buf_doc-line.doc-density
                  .
                end.
                if valid-density( v-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> true then do:
                  undo, return error substitute( 'Заявленная плотность топлива по месту хранения не соответствует ожидаемому.&1'
                                                + 'Документ: &2&1'
                                                + 'Товар: &3&1'
                                                + 'Место хранения: &4&1'
                                                + 'Плотность: &5&1'
                                                + 'Кол-во: &6 (&8) и &7 (&9)&1'
                                                ,chr(10)
                                                ,buf_trn-doc.doc-code
                                                ,buf_goods.gds-code
                                                ,buf_doc-pl.pl-code
                                                ,v-density
                                                ,buf_doc-pl.doc-qnty
                                                ,buf_doc-pl.cli-doc-qnty
                                                ,buf_goods.unit-base
                                                ,buf_goods.unit-cli
                                                ).
                end.
                if buf_doc-pl.cli-fact-qnty <> 0.0
                  and buf_doc-pl.fact-qnty <> 0.0
                then do:
                  assign
                    v-density = buf_doc-pl.cli-fact-qnty / buf_doc-pl.fact-qnty
                  .
                end.
                else do:
                  assign
                    v-density = buf_doc-line.fact-density
                  .
                end.
                if buf_trn-doc.status_ <> 'запрос':U
                  and not( buf_trn-doc.status_ = 'накл':U
                          and buf_trn-doc.flag_ = false
                        )
                  and valid-density( v-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> true
                then do:
                  undo, return error substitute( 'Фактическая плотность топлива по месту хранения не соответствует ожидаемому.&1'
                                                + 'Документ: &2&1'
                                                + 'Товар: &3&1'
                                                + 'Место хранения: &4&1'
                                                + 'Плотность: &5&1'
                                                + 'Кол-во: &6 (&8) и &7 (&9)&1'
                                                ,chr(10)
                                                ,buf_trn-doc.doc-code
                                                ,buf_goods.gds-code
                                                ,buf_doc-pl.pl-code
                                                ,v-density
                                                ,buf_doc-pl.fact-qnty
                                                ,buf_doc-pl.cli-fact-qnty
                                                ,buf_goods.unit-base
                                                ,buf_goods.unit-cli
                                                ).
                end.
              end.
            end.
          end.
        end.
        if buf_trn-doc.doc-type = 'инв':U then do:
          if buf_trn-doc.status_ <> 'накл':U
            and ( buf_doc-line.fact-qnty <> v-pl-doc-qnty
                  or buf_doc-line.fact-qnty <> v-pl-fact-qnty
                  or absolute( buf_doc-line.cli-qnty - v-pl-cli-doc-qnty ) > 0.001
                  or absolute( buf_doc-line.cli-qnty - v-pl-cli-fact-qnty ) > 0.001
                )
          then do:
            undo, return error substitute( 'Количество (разница) по строке накладной: &2 для товара &3&1'
                                            + 'НЕ СОВПАДАЕТ с суммарным количеством по местам хранения!!!&1'
                                            + 'По строке &4 (&6) &5 (&7)&1'
                                            , chr(10)
                                            , buf_trn-doc.doc-code
                                            , buf_goods.gds-code
                                            , buf_doc-line.fact-qnty
                                            , buf_doc-line.cli-qnty
                                            , buf_goods.unit-base
                                            , buf_goods.unit-cli
                                          )
                             + substitute( 'По местам хр.(doc)  &2 (&6) &3 (&7)&1'
                                            + 'По местам хр.(fact) &4 (&6) &5 (&7)&1'
                                            , chr(10)
                                            , v-pl-doc-qnty
                                            , v-pl-cli-doc-qnty
                                            , v-pl-fact-qnty
                                            , v-pl-cli-fact-qnty
                                            , buf_goods.unit-base
                                            , buf_goods.unit-cli
                                          )
                                          .
          end.
          if buf_trn-doc.status_ = 'факт':U
            and ( buf_doc-line.doc-qnty <> v-pl-rest-af-qnty
                  or ( absolute( buf_inv-line.wast-cli-qnty - v-pl-cli-rest-af-qnty ) > 0.001
                       and is-petrol = true
                       and is-pieces = false
                     )
                )
          then do:
            undo, return error substitute( 'Количество "после инвентаризации" в строке накладной: &2 для товара &3&1'
                                            + 'НЕ СОВПАДАЕТ с суммарным количеством по местам хранения!!!&1'
                                            + 'По строке &4 (&8) &5 (&9)&1'
                                            + 'По местам хр. &6 (&8) &7 (&9)&1'
                                            , chr(10)
                                            , buf_trn-doc.doc-code
                                            , buf_goods.gds-code
                                            , buf_doc-line.doc-qnty
                                            , buf_inv-line.wast-cli-qnty
                                            , v-pl-rest-af-qnty
                                            , v-pl-cli-rest-af-qnty
                                            , buf_goods.unit-base
                                            , buf_goods.unit-cli
                                          ).
          end.
        end.
        else do:
          if absolute( buf_doc-line.cli-qnty - v-pl-cli-qnty ) > 0.001 then do:
            undo, return error substitute( 'Количество в единицах измерения поставщика в строке накладной: &2 для товара &3&1'
                                          + 'НЕ СОВПАДАЕТ с суммарным количеством по местам хранения!!!&1'
                                          + 'По строке &4 (&6)&1'
                                          + 'По местам хр. &5 (&6)&1'
                                          , chr(10)
                                          , buf_trn-doc.doc-code
                                          , buf_goods.gds-code
                                          , buf_doc-line.cli-qnty
                                          , v-pl-cli-qnty
                                          , buf_doc-line.unit-cli
                                        ).
          end.
          if buf_doc-line.doc-qnty <> v-pl-doc-qnty
            or ( absolute( buf_doc-line.doc-qnty * buf_doc-line.doc-density - v-pl-cli-doc-qnty ) > 0.001
                and is-petrol = true
                and is-pieces = false
                )
          then do:
            undo, return error substitute( 'Заявленное количество в строке накладной: &2 для товара &3&1'
                                          + 'НЕ СОВПАДАЕТ с суммарным количеством по местам хранения!!!&1'
                                          + 'По строке &4 (&8) &5 (&9)&1'
                                          + 'По местам хр. &6 (&8) &7 (&9)&1'
                                          , chr(10)
                                          , buf_trn-doc.doc-code
                                          , buf_goods.gds-code
                                          , buf_doc-line.doc-qnty
                                          , buf_doc-line.doc-qnty * buf_doc-line.doc-density
                                          , v-pl-doc-qnty
                                          , v-pl-cli-doc-qnty
                                          , buf_goods.unit-base
                                          , buf_goods.unit-cli
                                        ).
          end.
          if buf_trn-doc.status_ <> 'запрос':U
            and not( buf_trn-doc.status_ = 'накл':U
                    and buf_trn-doc.flag_ = false
                  )
            and ( buf_doc-line.fact-qnty <> v-pl-fact-qnty
                  or ( absolute( buf_doc-line.fact-qnty * buf_doc-line.fact-density - v-pl-cli-fact-qnty ) > 0.001
                      and is-petrol = true
                      and is-pieces = false
                    )
                )
          then do:
            undo, return error substitute( 'Фактическое количество в строке накладной: &2 для товара &3&1'
                                            + 'НЕ СОВПАДАЕТ с суммарным количеством по местам хранения!!!&1'
                                            + 'По строке &4 (&8) &5 (&9)&1'
                                            + 'По местам хр. &6 (&8) &7 (&9)&1'
                                            , chr(10)
                                            , buf_trn-doc.doc-code
                                            , buf_goods.gds-code
                                            , buf_doc-line.fact-qnty
                                            , buf_doc-line.fact-qnty * buf_doc-line.fact-density
                                            , v-pl-fact-qnty
                                            , v-pl-cli-fact-qnty
                                            , buf_goods.unit-base
                                            , buf_goods.unit-cli
                                          ).
          end.
        end.
        if is-petrol = true
          and is-pieces = false
        then do:
          if ( ( buf_trn-doc.doc-type = 'инв':U
                and buf_trn-doc.status_ = 'факт':U
              )
              or buf_trn-doc.doc-type <> 'инв':U
            )
          then do:
            if valid-density( buf_doc-line.doc-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> true
              or valid-density( buf_doc-line.fact-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> true
            then do:
              undo, return error substitute( 'Плотность товара &1 в строке документа &2 некорректная: &3 (док), &4 (факт)'
                                            ,buf_goods.gds-code
                                            ,buf_trn-doc.doc-code
                                            ,buf_doc-line.doc-density
                                            ,buf_doc-line.fact-density
                                          ).
            end.
          end.
          if buf_trn-doc.doc-type = 'инв':U then do:
            if buf_trn-doc.status_ <> 'накл':U
              and ( absolute( buf_inv-line.wast-cli-qnty - buf_doc-line.cli-qnty - buf_inv-line.before-cli-qnty) > 0.01
                    or buf_inv-line.wast-cli-qnty <> buf_inv-line.after-cli-qnty
                    or absolute( buf_inv-line.before-cli-qnty + buf_doc-line.cli-qnty - buf_inv-line.after-cli-qnty) > 0.01
                  )
            then do:
              undo, return error substitute( 'Ошибка в количествах (&5) "было", "по документу" и "стало"&1'
                                            + 'Документ &2&1'
                                            + 'Товар &3&1'
                                            + '"Было" &6 (&4)&1'
                                            + '"Было" &7 (&5) (inv-line.wast-cli-qnty - doc-line.cli-qnty)&1'
                                            + '"Было" &8 (&5) (inv-line.before-cli-qnty) &1'
                                            ,chr(10)
                                            ,buf_trn-doc.doc-code
                                            ,buf_goods.gds-code
                                            ,buf_goods.unit-base
                                            ,buf_goods.unit-cli
                                            ,buf_doc-line.doc-qnty - buf_doc-line.fact-qnty
                                            ,buf_inv-line.wast-cli-qnty - buf_doc-line.cli-qnty
                                            ,buf_inv-line.before-cli-qnty
                                          )
                              + substitute( 'По документу &4 (&2)&1'
                                            + 'По документу &5 (&3)&1'
                                            + '"Стало" &6 (&2) &1'
                                            + '"Стало" &7 (&3) (inv-line.wast-cli-qnty)&1'
                                            + '"Стало" &8 (&3) (inv-line.after-cli-qnty)&1'
                                            ,chr(10)
                                            ,buf_goods.unit-base
                                            ,buf_goods.unit-cli
                                            ,buf_doc-line.fact-qnty
                                            ,buf_doc-line.cli-qnty
                                            ,buf_doc-line.doc-qnty
                                            ,buf_inv-line.wast-cli-qnty
                                            ,buf_inv-line.after-cli-qnty
                                          ).
            end.
            if buf_trn-doc.status_ = 'факт':U
              and absolute( buf_doc-line.doc-qnty * buf_doc-line.fact-density - buf_inv-line.wast-cli-qnty ) > 0.01
            then do:
              undo, return error substitute( 'Ошибка в количествах "стало"&1'
                                            + 'Документ &2&1'
                                            + 'Товар &3&1'
                                            + '"Стало" &6 (&4)&1'
                                            + '"Стало" &7 (&5)&1'
                                            + '"Стало" (плотность) &8&1'
                                            ,chr(10)
                                            ,buf_trn-doc.doc-code
                                            ,buf_goods.gds-code
                                            ,buf_goods.unit-base
                                            ,buf_goods.unit-cli
                                            ,buf_doc-line.doc-qnty
                                            ,buf_inv-line.after-cli-qnty
                                            ,buf_doc-line.fact-density
                                          ).
            end.
          end.
          else do:
            if absolute( buf_doc-line.fact-qnty * buf_doc-line.fact-density - buf_inv-line.wast-cli-qnty ) > 0.001
              and ( buf_doc-line.fact-qnty <> 0
                    or ( buf_doc-line.fact-qnty = 0
                        and v-chk-null-qnty = true
                      )
                  )
            then do:
              undo, return error substitute( "Несоответствие по товару &2 в строке документа &3&1"
                                              + "Фактическое количество (&4): &6&1"
                                              + "Фактическое количество (&5): &7&1"
                                              + "Плотность: &8"
                                              ,chr(10)
                                              ,buf_goods.gds-code
                                              ,buf_doc-line.doc-code
                                              ,buf_goods.unit-base
                                              ,buf_goods.unit-cli
                                              ,buf_doc-line.fact-qnty
                                              ,buf_inv-line.wast-cli-qnty
                                              ,buf_doc-line.fact-density
                                            ).
            end.
          end.
          if buf_trn-doc.status_ = 'факт':U then do:
            if v-chk-rvs = true then do:
              run gds-attr-value in this-procedure
                ( input  buf_goods.gds-code
                ,input  'ptrl-without-rvs':U
                ,output v-attr-value
                ,output v-attr-type
                ) .
              if lookup(v-attr-value, 'true,yes':u) = 0 then do:
                find first buf_rvs-line no-lock
                  where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                    and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                    and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                    and buf_rvs-line.gds-code = buf_goods.gds-code
                  no-error .
                if not available buf_rvs-doc then do:
                  undo, return error substitute( 'Вы не сделали сверку перед документом "&1" (тип "&2") по товару &3 ("&4").'
                                                , buf_trn-doc.doc-code
                                                , 'перед_док':U
                                                , buf_goods.gds-code
                                                , buf_goods.gds-name
                                                ) .
                end.
                find first buf_rvs-line no-lock
                  where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                    and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                    and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                    and buf_rvs-line.gds-code = buf_goods.gds-code
                  no-error .
                if not available buf_rvs-doc then do:
                  undo, return error substitute( 'Вы не сделали сверку после документа "&1" (тип "&2") по товару &3 ("&4").'
                                                , buf_trn-doc.doc-code
                                                , 'после_док':U
                                                , buf_goods.gds-code
                                                , buf_goods.gds-name
                                                ) .
                end.
              end.
            end.
            if ( buf_trn-doc.doc-type <> 'инв':U
                and buf_inv-line.wast-cli-qnty = ?
              )
              or
              ( buf_trn-doc.doc-type = 'инв':U
                and buf_doc-line.cli-qnty = ?
              )
            then do:
              undo, return error substitute( 'Ошибка в нарастающем итоге&1'
                                              + 'Документ &2&1'
                                              + 'Товар &3&1'
                                              + 'По документу &5 (&4)&1'
                                              ,chr(10)
                                              ,buf_trn-doc.doc-code
                                              ,buf_goods.gds-code
                                              ,buf_goods.unit-cli
                                              ,(if buf_trn-doc.doc-type = 'инв':U then buf_doc-line.cli-qnty else buf_inv-line.wast-cli-qnty )
                                            ).
            end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_lastinvl in g#lib-trn3
(
   input buf_inv-line.doc-code
,  input buf_inv-line.artic
,  input buf_inv-line.prod-type
,  input buf_inv-line.prod-code
, output v-before-cli-qnty
, output v-last-invlin
)  .
            find first buf-prev_inv-line no-lock
              where recid( buf-prev_inv-line ) = v-last-invlin
              no-error .
            IF AVAILABLE buf-prev_inv-line THEN DO :
            case buf_trn-doc.doc-type :
              when 'инв':U then do:
                assign
                  v-after-cli-qnty = v-before-cli-qnty + buf_doc-line.cli-qnty
                .
              end.
              otherwise do:
                assign
                  v-after-cli-qnty = v-before-cli-qnty + buf_inv-line.wast-cli-qnty * v-sign
                .
              end.
            end case.
            if v-before-cli-qnty <> buf_inv-line.before-cli-qnty
              or v-after-cli-qnty <> buf_inv-line.after-cli-qnty
            then do:
              if abs(v-before-cli-qnty - buf_inv-line.before-cli-qnty) <= 0.001
              and abs(v-after-cli-qnty  -  buf_inv-line.after-cli-qnty) <= 0.001
              then do :
                assign
                  buf_inv-line.before-cli-qnty = v-before-cli-qnty
                  buf_inv-line.after-cli-qnty  = v-after-cli-qnty
                .
              end.
              else do :
              undo, return error substitute( 'Ошибка в нарастающем итоге&1'
                                              + 'Документ &2&1'
                                              + 'Товар &3&1'
                                              + '"Было" предыдущий документ (&5) &6 (&4)&1'
                                              + '"Было" текущий документ &7 (&4)&1'
                                              ,chr(10)
                                              ,buf_trn-doc.doc-code
                                              ,buf_goods.gds-code
                                              ,buf_goods.unit-cli
                                              ,(if available buf-prev_inv-line then buf-prev_inv-line.doc-code else "":U)
                                              ,v-before-cli-qnty
                                              ,buf_inv-line.before-cli-qnty
                                            )
                              + substitute( 'По документу &3 (&2)&1'
                                              + '"Стало" текущий документ &4 (&2)&1'
                                              + '"Стало" должно быть &5 (&2)&1'
                                              ,chr(10)
                                              ,buf_goods.unit-cli
                                              ,(if buf_trn-doc.doc-type <> 'инв':U then buf_inv-line.wast-cli-qnty else buf_doc-line.cli-qnty )
                                              ,buf_inv-line.after-cli-qnty
                                              ,v-after-cli-qnty
                                            ).
            end.
            end.
            END.
            find first buf-next_doc-line
              where buf-next_doc-line.obj-type   = buf_doc-line.obj-type
                and buf-next_doc-line.obj-code   = buf_doc-line.obj-code
                and buf-next_doc-line.prod-type  = buf_doc-line.prod-type
                and buf-next_doc-line.prod-code  = buf_doc-line.prod-code
                and buf-next_doc-line.artic      = buf_doc-line.artic
                and buf-next_doc-line.status_    = 'факт':U
                and buf-next_doc-line.fact-order > buf_doc-line.fact-order
              no-error .
            if not available buf-next_doc-line then do:
              assign
                v-after-qnty     = 0.0
                v-after-cli-qnty = 0.0
              .
              for each buf_pl-gds no-lock
                where buf_pl-gds.gds-code = buf_goods.gds-code
                  and buf_pl-gds.obj-type = buf_doc-line.obj-type
                  and buf_pl-gds.obj-code = buf_doc-line.obj-code
              on error undo, return error return-value
              :
                assign
                  v-after-qnty     = v-after-qnty     + buf_pl-gds.fact-qnty
                  v-after-cli-qnty = v-after-cli-qnty + buf_pl-gds.cli-fact-qnty
                .
              end.
              if absolute( v-after-cli-qnty - buf_inv-line.after-cli-qnty ) > 0.001 then do:
                undo, return error substitute( 'Ошибка в нарастающем итоге&1'
                                                + 'Документ &2&1'
                                                + 'Товар &3&1'
                                                + '"Стало" (текущий документ) &5 (&4)&1'
                                                + '"Стало" (по местам хр.) &6 (&4)'
                                                ,chr(10)
                                                ,buf_trn-doc.doc-code
                                                ,buf_goods.gds-code
                                                ,buf_goods.unit-cli
                                                ,buf_inv-line.after-cli-qnty
                                                ,v-after-cli-qnty
                                              ).
              end.
              find first buf_gds-obj no-lock
                where buf_gds-obj.obj-type  = buf_doc-line.obj-type
                  and buf_gds-obj.obj-code  = buf_doc-line.obj-code
                  and buf_gds-obj.artic     = buf_doc-line.artic
                  and buf_gds-obj.prod-type = buf_doc-line.prod-type
                  and buf_gds-obj.prod-code = buf_doc-line.prod-code
              .
              if absolute( v-after-qnty - buf_gds-obj.fact-qnty ) > 0.001 then do:
                undo, return error substitute( 'Ошибка в итоговом кол-ве товара на местах хранения&1'
                                                + 'Документ &2&1'
                                                + 'Товар &3&1'
                                                + '"Стало" (на объекте) &5 (&4)&1'
                                                + '"Стало" (по местам хр.) &6 (&4)'
                                                ,chr(10)
                                                ,buf_trn-doc.doc-code
                                                ,buf_goods.gds-code
                                                ,buf_goods.unit-base
                                                ,buf_gds-obj.fact-qnty
                                                ,v-after-qnty
                                              ).
              end.
            end.
            else do:
              find first buf-next_inv-line
                where buf-next_inv-line.doc-code  = buf-next_doc-line.doc-code
                  and buf-next_inv-line.artic     = buf-next_doc-line.artic
                  and buf-next_inv-line.prod-type = buf-next_doc-line.prod-type
                  and buf-next_inv-line.prod-code = buf-next_doc-line.prod-code
                no-error.
              if not available buf-next_inv-line then do:
                undo, return error substitute( "Не найдена строка с информацией о кол-ве (&1) товара в документе &2 для товара &3."
                                              ,buf_goods.unit-cli
                                              ,buf-next_doc-line.doc-code
                                              ,buf_goods.gds-code
                                              ).
              end.
              if buf_inv-line.after-cli-qnty <> buf-next_inv-line.before-cli-qnty then do:
                undo, return error substitute( 'При закрытии документа задним числом не пересчитан нарастающий итог&1'
                                                + 'Документ &2&1'
                                                + 'Товар &3&1'
                                                + '"Стало" текущего документа &5 (&4)&1'
                                                + '"Было" следующего документа (&6) &7 (&4)'
                                                ,chr(10)
                                                ,buf_trn-doc.doc-code
                                                ,buf_goods.gds-code
                                                ,buf_goods.unit-cli
                                                ,buf_inv-line.after-cli-qnty
                                                ,buf-next_doc-line.doc-code
                                                ,buf-next_inv-line.before-cli-qnty
                                              ).
              end.
            end.
          end.
        end.
      end.
    end.
  end.
  return .
end.
