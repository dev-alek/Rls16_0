block-level on error undo, throw.
using ibs.th.gbl.gbl-hndllib from propath.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Библиотека процедур для работы со складскими документами (3)":U .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure plgdsfnd :
  define input  parameter p-chk-and-chs    as logical               no-undo .
  define input  parameter p-obj-type       like ub.gds-obj.obj-type no-undo .
  define input  parameter p-obj-code       like ub.gds-obj.obj-code no-undo .
  define input  parameter p-gds-code       like ub.goods.gds-code   no-undo .
  define output parameter p-reserv-pl-code as   logical             no-undo .
  define output parameter p-pl-code        like ub.pl-gds.pl-code   no-undo .
  define buffer buf_goods         for ub.goods .
  define buffer buf_pl-gds        for ub.pl-gds .
  define buffer buf_second_pl-gds for ub.pl-gds .
  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .
  if not available buf_goods
  then do:
    return error "Не найден товар. Первичный бар-код " + string( p-gds-code ) .
  end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'place-rsrv=request'
  ,output p-reserv-pl-code
  ) no-error .
  if error-status :error
  then do:
    return error substitute("Ошибка при запросе атрибута place-rsrv товара на объекте  &1 &2 " , error-status :get-message(1) , return-value  )  .
  end.
  if p-reserv-pl-code = no
  then do:
    return .
  end.
  if p-chk-and-chs <> yes
  then do:
    return .
  end.
  find first buf_pl-gds no-lock where
             buf_pl-gds.obj-type = p-obj-type and
             buf_pl-gds.obj-code = p-obj-code and
             buf_pl-gds.gds-code = p-gds-code no-error .
  if not available buf_pl-gds
  then do:
    return error "К товару не привязано ни одного места хранения" .
  end.
  find first buf_second_pl-gds no-lock where
             buf_second_pl-gds.obj-type  = p-obj-type          and
             buf_second_pl-gds.obj-code  = p-obj-code          and
             buf_second_pl-gds.gds-code  = p-gds-code          and
             recid( buf_second_pl-gds ) <> recid( buf_pl-gds ) no-error .
  if not available buf_second_pl-gds
  then do:
    assign
      p-pl-code = buf_pl-gds.pl-code
    .
  end.
  else do:
    return error "Не выбрано место хранения " + chr(10) .
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-allsum-line      no-undo
field sum-type           as   character
field fact-qnty          like ub.doc-line.fact-qnty
field cli-qnty           like ub.doc-line.cli-qnty
field sum-dsc-base-doc   like ub.doc-line.price-base
field sum-dsc-rubl-doc   like ub.doc-line.price-base
field dsc-base-doc       like ub.doc-line.price-base
field dsc-rubl-doc       like ub.doc-line.price-base
field vat-base-doc       like ub.doc-line.price-base
field vat-rubl-doc       like ub.doc-line.price-base
field vat-base-buyer-doc like ub.doc-line.price-base
field vat-rubl-buyer-doc like ub.doc-line.price-base
field slt-base-doc       like ub.doc-line.price-base
field slt-rubl-doc       like ub.doc-line.price-base
field road-tax-base-doc  like ub.doc-line.price-base
field road-tax-rubl-doc  like ub.doc-line.price-base
field excise-base-doc    like ub.doc-line.price-base
field excise-rubl-doc    like ub.doc-line.price-base
field sum-dsc-base-acc   like ub.doc-line.price-base
field sum-dsc-rubl-acc   like ub.doc-line.price-base
field sum-dsc-cli-acc    like ub.doc-line.price-cli
field dsc-base-acc       like ub.doc-line.price-base
field dsc-rubl-acc       like ub.doc-line.price-base
field dsc-cli-acc        like ub.doc-line.price-cli
field vat-base-acc       like ub.doc-line.price-base
field vat-rubl-acc       like ub.doc-line.price-base
field vat-cli-acc        like ub.doc-line.price-cli
field slt-base-acc       like ub.doc-line.price-base
field slt-rubl-acc       like ub.doc-line.price-base
field slt-cli-acc        like ub.doc-line.price-cli
field road-tax-base-acc  like ub.doc-line.price-base
field road-tax-rubl-acc  like ub.doc-line.price-base
field road-tax-cli-acc   like ub.doc-line.price-cli
field excise-base-acc    like ub.doc-line.price-base
field excise-rubl-acc    like ub.doc-line.price-base
field excise-cli-acc     like ub.doc-line.price-cli
field transport-base-acc like ub.doc-line.price-base
field transport-rubl-acc like ub.doc-line.price-base
field transport-cli-acc  like ub.doc-line.price-cli
field other-base-acc     like ub.doc-line.price-base
field other-rubl-acc     like ub.doc-line.price-base
field other-cli-acc      like ub.doc-line.price-cli
field sum-dsc-base-cur   like ub.doc-line.price-base
field sum-dsc-rubl-cur   like ub.doc-line.price-base
field dsc-base-cur       like ub.doc-line.price-base
field dsc-rubl-cur       like ub.doc-line.price-base
field vat-base-cur       like ub.doc-line.price-base
field vat-rubl-cur       like ub.doc-line.price-base
field vat-base-buyer-cur like ub.doc-line.price-base
field vat-rubl-buyer-cur like ub.doc-line.price-base
field slt-base-cur       like ub.doc-line.price-base
field slt-rubl-cur       like ub.doc-line.price-base
field road-tax-base-cur  like ub.doc-line.price-base
field road-tax-rubl-cur  like ub.doc-line.price-base
field excise-base-cur    like ub.doc-line.price-base
field excise-rubl-cur    like ub.doc-line.price-base
index sum-type is primary unique sum-type.
.
define temp-table tt-allsum no-undo
field sum-type           as   character
field fact-qnty             as decimal
field cli-qnty              as decimal
field sum-dsc-base-doc      as decimal
field sum-dsc-rubl-doc      as decimal
field dsc-base-doc          as decimal
field dsc-rubl-doc          as decimal
field vat-base-doc          as decimal
field vat-rubl-doc          as decimal
field vat-base-buyer-doc    as decimal
field vat-rubl-buyer-doc    as decimal
field slt-base-doc          as decimal
field slt-rubl-doc          as decimal
field road-tax-base-doc     as decimal
field road-tax-rubl-doc     as decimal
field excise-base-doc       as decimal
field excise-rubl-doc       as decimal
field sum-dsc-base-acc      as decimal
field sum-dsc-rubl-acc      as decimal
field sum-dsc-cli-acc       as decimal
field dsc-base-acc          as decimal
field dsc-rubl-acc          as decimal
field dsc-cli-acc           as decimal
field vat-base-acc          as decimal
field vat-rubl-acc          as decimal
field vat-cli-acc           as decimal
field slt-base-acc          as decimal
field slt-rubl-acc          as decimal
field slt-cli-acc           as decimal
field road-tax-base-acc     as decimal
field road-tax-rubl-acc     as decimal
field road-tax-cli-acc      as decimal
field excise-base-acc       as decimal
field excise-rubl-acc       as decimal
field excise-cli-acc        as decimal
field transport-base-acc    as decimal
field transport-rubl-acc    as decimal
field transport-cli-acc     as decimal
field other-base-acc        as decimal
field other-rubl-acc        as decimal
field other-cli-acc         as decimal
field sum-dsc-base-cur      as decimal
field sum-dsc-rubl-cur      as decimal
field dsc-base-cur          as decimal
field dsc-rubl-cur          as decimal
field vat-base-cur          as decimal
field vat-rubl-cur          as decimal
field vat-base-buyer-cur    as decimal
field vat-rubl-buyer-cur    as decimal
field slt-base-cur          as decimal
field slt-rubl-cur          as decimal
field road-tax-base-cur     as decimal
field road-tax-rubl-cur     as decimal
field excise-base-cur       as decimal
field excise-rubl-cur       as decimal
index sum-type is primary unique sum-type.
define temp-table tt-clcparts no-undo like ub.parts
field part-cur-base like ub.gds-dtl.price-base
field part-cur-road-tax like ub.gds-dtl.price-base
field part-cur-excise like ub.gds-dtl.price-base
.
define variable v-calcbypart as log no-undo.
procedure clcprtsl_calc-parts :
define input parameter parrec-parts        as   recid                   no-undo.
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcurroad-tax      like ub.doc-line.road-tax    no-undo.
define input parameter parcurexcise        like ub.doc-line.excise      no-undo.
define input parameter parcurvat-pc        like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define variable parartic        like ub.parts.artic         no-undo.
define variable parprod-type    like ub.parts.prod-type     no-undo.
define variable parprod-code    like ub.parts.prod-code     no-undo.
define variable pardoc-type     like ub.parts.doc-type      no-undo.
define variable pardoc-code     like ub.parts.out-code      no-undo.
define variable parobj-type     like ub.parts.obj-type      no-undo.
define variable parobj-code     like ub.parts.obj-code      no-undo.
define variable parprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable pardiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable pardiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable pardoc-qnty     like ub.parts.qnty          no-undo.
define variable parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define variable parcurartic        like ub.parts.artic         no-undo.
define variable parcurprod-type    like ub.parts.prod-type     no-undo.
define variable parcurprod-code    like ub.parts.prod-code     no-undo.
define variable parcurdoc-type     like ub.parts.doc-type      no-undo.
define variable parcurdoc-code     like ub.parts.out-code      no-undo.
define variable parcurobj-type     like ub.parts.obj-type      no-undo.
define variable parcurobj-code     like ub.parts.obj-code      no-undo.
define variable parcurprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parcurprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable parcurdiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable parcurdiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parcurfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcurcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable parcurdoc-qnty     like ub.parts.qnty          no-undo.
define variable parcurbase-rate    like ub.trn-doc.base-rate   no-undo.
define variable parcurbase-scale   like ub.trn-doc.base-scale  no-undo.
define variable parcurext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define buffer bf_tt-allsum     for tt-allsum.
define buffer bfs_tt-allsum    for tt-allsum.
define buffer bfpc_tt-allsum   for tt-allsum.
define buffer bfspc_tt-allsum  for tt-allsum.
define buffer bfacc_tt-allsum  for tt-allsum.
define buffer bfsacc_tt-allsum for tt-allsum.
define buffer cl_tt-clcparts   for tt-clcparts.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf_sysconf       for ub.sysconf.
    define buffer   in-vatp-trn-doccl  for ub.trn-doc .
    define buffer   in-vatp-partscl    for ub.parts   .
    define buffer   in-vatp-doccl      for ub.trn-doc .
    define buffer   in-vatp-goodscl    for ub.goods   .
    define buffer   in-vatp-sysconfcl  for ub.sysconf .
    define buffer   in-vatp_doc-attrcl for ub.doc-attr.
    define variable in-vatp-have-vat-sltcl       as   logical initial yes    no-undo.
    define variable vat-pc-loccl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbcl                  as   character              no-undo.
    define variable slt-pc-loccl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-ratecl              as   decimal                no-undo.
    define variable price-rubl-with-tax-loccl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loccl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loccl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loccl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loccl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loccl  like ub.doc-line.price-base no-undo.
    define variable vat-base-loccl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loccl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loccl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loccl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loccl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loccl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loccl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loccl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loccl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loccl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdcl             as   character              no-undo.
    define variable varinvatp-typecl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecl    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecl    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecl like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecl like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercl              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercl              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecl            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecl            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecl            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcl for ub.gds-dtl.
    define buffer out-vatp_partscl       for ub.parts.
    define buffer out-vatp_sysconfcl     for ub.sysconf.
    define buffer out-vatp_doc-linecl    for ub.doc-line.
    define buffer out-vatp_goodscl       for ub.goods.
    define buffer out-vatp_trn-doccl     for ub.trn-doc.
    define buffer out-vatp_doc-attrcl    for ub.doc-attr.
    define variable varprice-base-conscl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecl         as   character                           no-undo.
    define variable varfrm-cnsvcl              as   character                           no-undo.
    define variable varroot-nodecl             as   integer                             no-undo.
    define variable varempty-scalecl           as   logical                             no-undo.
    define variable varis-cons-parts-havecl    as   logical                             no-undo.
    define variable varsum-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcl        as   logical                             no-undo.
    define variable varcurclprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurclprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcl               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococl  for ub.trn-doc .
    define buffer   in-vatp-partsocl    for ub.parts   .
    define buffer   in-vatp-dococl      for ub.trn-doc .
    define buffer   in-vatp-goodsocl    for ub.goods   .
    define buffer   in-vatp-sysconfocl  for ub.sysconf .
    define buffer   in-vatp_doc-attrocl for ub.doc-attr.
    define variable in-vatp-have-vat-sltocl       as   logical initial yes    no-undo.
    define variable vat-pc-lococl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocl                  as   character              no-undo.
    define variable slt-pc-lococl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocl              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococl  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocl             as   character              no-undo.
    define variable varinvatp-typeocl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecur    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecur    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecur like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecur like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercur              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercur              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecur            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecur            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecur            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecur            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcur     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcur for ub.gds-dtl.
    define buffer out-vatp_partscur       for ub.parts.
    define buffer out-vatp_sysconfcur     for ub.sysconf.
    define buffer out-vatp_doc-linecur    for ub.doc-line.
    define buffer out-vatp_goodscur       for ub.goods.
    define buffer out-vatp_trn-doccur     for ub.trn-doc.
    define buffer out-vatp_doc-attrcur    for ub.doc-attr.
    define variable varprice-base-conscur      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscur      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecur         as   character                           no-undo.
    define variable varfrm-cnsvcur              as   character                           no-undo.
    define variable varroot-nodecur             as   integer                             no-undo.
    define variable varempty-scalecur           as   logical                             no-undo.
    define variable varis-cons-parts-havecur    as   logical                             no-undo.
    define variable varsum-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcur        as   logical                             no-undo.
    define variable varcurcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcur               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcur    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococur  for ub.trn-doc .
    define buffer   in-vatp-partsocur    for ub.parts   .
    define buffer   in-vatp-dococur      for ub.trn-doc .
    define buffer   in-vatp-goodsocur    for ub.goods   .
    define buffer   in-vatp-sysconfocur  for ub.sysconf .
    define buffer   in-vatp_doc-attrocur for ub.doc-attr.
    define variable in-vatp-have-vat-sltocur       as   logical initial yes    no-undo.
    define variable vat-pc-lococur                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocur                  as   character              no-undo.
    define variable slt-pc-lococur                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocur              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococur    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococur    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococur     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococur like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococur like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococur  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococur               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococur               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococur           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococur         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococur         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococur          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococur             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococur             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococur              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococur          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocur             as   character              no-undo.
    define variable varinvatp-typeocur             as   character              no-undo.
do on error undo, return error return-value :
find first cl_tt-clcparts where recid(cl_tt-clcparts) = parrec-parts no-lock.
for each bf_tt-allsum on error undo, return error return-value :
  delete bf_tt-allsum.
end.
assign
  price-rubl-with-tax-loccl = cl_tt-clcparts.price-rubl
  price-base-with-tax-loccl = cl_tt-clcparts.price-base
.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbcl
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltcl = yes.
  end.
  else do:
    find first in-vatp_doc-attrcl no-lock
      where in-vatp_doc-attrcl.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrcl then do:
      assign
        in-vatp-have-vat-sltcl = yes.
    end.
    else do:
         in-vatp-have-vat-sltcl = no.
    end.
  end.
  assign
   price-cli-with-tax-loccl = cl_tt-clcparts.price-cli
   cli-base-ratecl          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-loccl  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-loccl  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-loccl = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-loccl = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-loccl     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-loccl     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-loccl         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-loccl         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
    ASSIGN   slt-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
  assign
    exch-rate-cli-loccl = (cl_tt-clcparts.price-rubl - transport-rubl-loccl - other-rubl-loccl - road-tax-rubl-loccl - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-loccl else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-loccl else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-loccl        = slt-rubl-loccl       / exch-rate-cli-loccl
    vat-cli-loccl        = vat-rubl-loccl       / exch-rate-cli-loccl
    road-tax-cli-loccl   = road-tax-rubl-loccl  / exch-rate-cli-loccl
    transport-cli-loccl  = 0
    other-cli-loccl      = 0
  .
ASSIGN
          price-base-without-tax-loccl = price-base-with-tax-loccl - vat-base-loccl - slt-base-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))
    price-rubl-without-tax-loccl = price-rubl-with-tax-loccl - vat-rubl-loccl - slt-rubl-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))
.
if paris-doc then do:
  assign
    parartic     = cl_tt-clcparts.artic
    parprod-type = cl_tt-clcparts.prod-type
    parprod-code = cl_tt-clcparts.prod-code
    pardoc-type  = cl_tt-clcparts.doc-type
    pardoc-code  = cl_tt-clcparts.out-code
    parobj-type  = cl_tt-clcparts.obj-type
    parobj-code  = cl_tt-clcparts.obj-code.
if parext-doc-type = 'ot':U or
   parext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcl = yes.
end.
else do:
  find first out-vatp_doc-attrcl no-lock
    where out-vatp_doc-attrcl.doc-code  = pardoc-code
      and out-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcl then do:
    assign
      out-vatp-have-vat-sltcl = yes.
  end.
  else do:
     out-vatp-have-vat-sltcl = no.
  end.
end.
find first out-vatp_goodscl where out-vatp_goodscl.artic     = parartic     and
                                   out-vatp_goodscl.prod-type = parprod-type and
                                   out-vatp_goodscl.prod-code = parprod-code no-lock.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parartic
  ,input  parprod-type
  ,input  parprod-code
  ,output varroot-nodecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parartic parprod-type parprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecl
  ,input  'empty-scale=request'
  ,output varempty-scalecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parartic parprod-type parprod-code skip
    "Признак" varroot-nodecl skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcl
  )  .
if varoutvprbcl = "base":u then do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax / parbase-rate * parbase-scale)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   / parbase-rate * parbase-scale)
  .
end.
if varoutvprbcl = "rubl":u then do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * parbase-rate / parbase-scale)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * parbase-rate / parbase-scale) .
end.
assign
  varis-cons-parts-havecl =  no.
assign
  varfact-qntycl       = 0
  varcons-qntycl       = 0
  varprice-base-conscl = 0
  varprice-rubl-conscl = 0.
find first out-vatp_doc-linecl where
           out-vatp_doc-linecl.doc-code   = pardoc-code
       and out-vatp_doc-linecl.artic      = parartic
       and out-vatp_doc-linecl.prod-type  = parprod-type
       and out-vatp_doc-linecl.prod-code  = parprod-code no-lock no-error.
if available out-vatp_doc-linecl           and
  (out-vatp_doc-linecl.status_ = 'запрос':U or out-vatp_goodscl.gds-type = 'у':U) then do:
  assign
    varfact-qntycl = out-vatp_doc-linecl.fact-qnty.
end.
else do:
  for each out-vatp_partscl where out-vatp_partscl.out-code   = pardoc-code
                               and out-vatp_partscl.obj-type   = parobj-type
                               and out-vatp_partscl.obj-code   = parobj-code
                               and out-vatp_partscl.artic      = parartic
                               and out-vatp_partscl.prod-type  = parprod-type
                               and out-vatp_partscl.prod-code  = parprod-code no-lock :
    if out-vatp_partscl.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococl = out-vatp_partscl.price-rubl
  price-base-with-tax-lococl = out-vatp_partscl.price-base
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocl
  )  .
  if out-vatp_partscl.out-code = 'free-zone':U     or
     out-vatp_partscl.out-code = 'out-zone':U   or
     out-vatp_partscl.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocl = yes.
  end.
  else do:
    find first in-vatp_doc-attrocl no-lock
      where in-vatp_doc-attrocl.doc-code  = out-vatp_partscl.out-code
        and in-vatp_doc-attrocl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocl then do:
      assign
        in-vatp-have-vat-sltocl = yes.
    end.
    else do:
         in-vatp-have-vat-sltocl = no.
    end.
  end.
  assign
   price-cli-with-tax-lococl = out-vatp_partscl.price-cli
   cli-base-rateocl          = out-vatp_partscl.cli-base-rate.
  ASSIGN   road-tax-base-lococl  = (if out-vatp_partscl.road-tax-base  = ? then 0 else out-vatp_partscl.road-tax-base)
           road-tax-rubl-lococl  = (if out-vatp_partscl.road-tax-rubl  = ? then 0 else out-vatp_partscl.road-tax-rubl).
  ASSIGN  transport-base-lococl = (if out-vatp_partscl.transport-base = ? then 0 else out-vatp_partscl.transport-base)
          transport-rubl-lococl = (if out-vatp_partscl.transport-rubl = ? then 0 else out-vatp_partscl.transport-rubl)
          other-base-lococl     = (if out-vatp_partscl.other-base     = ? then 0 else out-vatp_partscl.other-base)
          other-rubl-lococl     = (if out-vatp_partscl.other-rubl     = ? then 0 else out-vatp_partscl.other-rubl)
          vat-pc-lococl         = (if out-vatp_partscl.vat-pc         = ? then 0 else out-vatp_partscl.vat-pc)
          slt-pc-lococl         = (if out-vatp_partscl.slt-pc         = ? then 0 else out-vatp_partscl.slt-pc).
          ASSIGN   slt-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
    ASSIGN   slt-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
  assign
    exch-rate-cli-lococl = (out-vatp_partscl.price-rubl - transport-rubl-lococl - other-rubl-lococl - road-tax-rubl-lococl - (if out-vatp_partscl.vat-type <> 'в т. ч.':U then vat-rubl-lococl else 0) - (if out-vatp_partscl.slt-type <> 'в т. ч.':U then slt-rubl-lococl else 0)) / out-vatp_partscl.price-cli .
  assign
    slt-cli-lococl        = slt-rubl-lococl       / exch-rate-cli-lococl
    vat-cli-lococl        = vat-rubl-lococl       / exch-rate-cli-lococl
    road-tax-cli-lococl   = road-tax-rubl-lococl  / exch-rate-cli-lococl
    transport-cli-lococl  = 0
    other-cli-lococl      = 0
  .
ASSIGN
          price-base-without-tax-lococl = price-base-with-tax-lococl - vat-base-lococl - slt-base-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))
    price-rubl-without-tax-lococl = price-rubl-with-tax-lococl - vat-rubl-lococl - slt-rubl-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))
.
      assign
        varprice-base-conscl = varprice-base-conscl + (price-base-with-tax-lococl - (if road-tax-base-lococl = ? then 0 else road-tax-base-lococl))* out-vatp_partscl.fact-qnty
        varprice-rubl-conscl = varprice-rubl-conscl + (price-rubl-with-tax-lococl - (if road-tax-rubl-lococl = ? then 0 else road-tax-rubl-lococl))* out-vatp_partscl.fact-qnty.
      assign
        varis-cons-parts-havecl = yes
        varcons-qntycl          = varcons-qntycl + out-vatp_partscl.fact-qnty.
    end.
    assign
      varfact-qntycl = varfact-qntycl + out-vatp_partscl.fact-qnty.
  end.
end.
assign
  varprice-base-conscl = varprice-base-conscl / varcons-qntycl
  varprice-rubl-conscl = varprice-rubl-conscl / varcons-qntycl.
if varprice-base-conscl = ? then do:
  assign
    varprice-base-conscl = 0.
end.
if varprice-rubl-conscl = ? then do:
  assign
    varprice-rubl-conscl = 0.
end.
assign
  varsum-base-factovpcl     = 0
  varslt-base-factovpcl     = 0
  varvat-base-factovpcl     = 0
  varvatcons-base-factovpcl = 0
  vardsc-base-factovpcl     = 0
  varsum-base-docovpcl      = 0
  varslt-base-docovpcl      = 0
  varvat-base-docovpcl      = 0
  varvatcons-base-docovpcl  = 0
  vardsc-base-docovpcl      = 0
  varsum-rubl-factovpcl     = 0
  varslt-rubl-factovpcl     = 0
  varvat-rubl-factovpcl     = 0
  varvatcons-rubl-factovpcl = 0
  vardsc-rubl-factovpcl     = 0
  varsum-rubl-docovpcl      = 0
  varslt-rubl-docovpcl      = 0
  varvat-rubl-docovpcl      = 0
  varvatcons-rubl-docovpcl  = 0
  vardsc-rubl-docovpcl      = 0.
assign
  varis-one-gds-dtlcl = no.
find first out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                     out-vatp_gds-dtlcl.artic     = parartic     and
                                     out-vatp_gds-dtlcl.prod-type = parprod-type and
                                     out-vatp_gds-dtlcl.prod-code = parprod-code no-lock no-error.
if available out-vatp_gds-dtlcl then do:
  find first buf_out-vatp_gds-dtlcl where buf_out-vatp_gds-dtlcl.doc-code  =  pardoc-code                and
                                           buf_out-vatp_gds-dtlcl.artic     =  parartic                   and
                                           buf_out-vatp_gds-dtlcl.prod-type =  parprod-type               and
                                           buf_out-vatp_gds-dtlcl.prod-code =  parprod-code               and
                                           recid(buf_out-vatp_gds-dtlcl)    <> recid(out-vatp_gds-dtlcl) no-lock no-error.
  if not available buf_out-vatp_gds-dtlcl then do:
    assign
      varis-one-gds-dtlcl = yes.
  end.
  if varoutvprbcl = "base":u then do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
  end.
  else do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
  end.
  if varempty-scalecl    = yes or
     varis-one-gds-dtlcl = yes   then do:
    assign
                price-base-with-tax-salecl    = (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)
        slt-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-base-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-base-salecl            = out-vatp_gds-dtlcl.discnt-base
                price-rubl-with-tax-salecl    = (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)
        slt-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-rubl-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-rubl-salecl            = out-vatp_gds-dtlcl.discnt-rubl
        .
    if pardoc-type = 'инв':U then do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
    else do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl ) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                       out-vatp_gds-dtlcl.artic     = parartic     and
                                       out-vatp_gds-dtlcl.prod-type = parprod-type and
                                       out-vatp_gds-dtlcl.prod-code = parprod-code no-lock :
      if varoutvprbcl = "base":u then do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
      end.
      else do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
      end.
      assign
             varsum-base-factovpcl = varsum-base-factovpcl + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-base-factovpcl = varslt-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-base-factovpcl = varvat-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-base-factovpcl = varvatcons-base-factovpcl + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-factovpcl = vardsc-base-factovpcl + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.fact-qnty
       varsum-base-docovpcl  = varsum-base-docovpcl  + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-base-docovpcl  = varslt-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-base-docovpcl  = varvat-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-base-docovpcl  = varvatcons-base-docovpcl  + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-docovpcl  = vardsc-base-docovpcl  + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.doc-qnty
      .
      assign
             varsum-rubl-factovpcl = varsum-rubl-factovpcl + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-rubl-factovpcl = varslt-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-rubl-factovpcl = varvat-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-rubl-factovpcl = varvatcons-rubl-factovpcl + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-factovpcl = vardsc-rubl-factovpcl + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.fact-qnty
       varsum-rubl-docovpcl  = varsum-rubl-docovpcl  + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-rubl-docovpcl  = varslt-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-rubl-docovpcl  = varvat-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-rubl-docovpcl  = varvatcons-rubl-docovpcl  + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-docovpcl  = vardsc-rubl-docovpcl  + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.doc-qnty   .
    end.
    if pardoc-type = 'инв':U then do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-docovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-docovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-docovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-docovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-docovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-docovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-docovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-docovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-docovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-docovpcl / varfact-qntycl.
    end.
    else do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-factovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-factovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-factovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-factovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-factovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-factovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-factovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-factovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-factovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-factovpcl / varfact-qntycl.
    end.
  end.
end.
assign
  price-base-without-tax-salecl = price-base-with-tax-salecl - vat-base-salecl - slt-base-salecl - road-tax-base-salecl
  price-rubl-without-tax-salecl = price-rubl-with-tax-salecl - vat-rubl-salecl - slt-rubl-salecl - road-tax-rubl-salecl.
end.
if paris-cur then do:
  assign
    parcurartic      = cl_tt-clcparts.artic
    parcurprod-type  = cl_tt-clcparts.prod-type
    parcurprod-code  = cl_tt-clcparts.prod-code
    parcurdoc-type   = cl_tt-clcparts.doc-type
    parcurdoc-code   = cl_tt-clcparts.out-code
    parcurobj-type   = cl_tt-clcparts.obj-type
    parcurobj-code   = cl_tt-clcparts.obj-code.
  if parr-b = "base" then do:
    assign
      parcurprice-base = parcur-base
      parcurprice-rubl = parcur-base * parbase-rate / parbase-scale.
  end.
  else do:
    assign
      parcurprice-base = parcur-base / parbase-rate * parbase-scale
      parcurprice-rubl = parcur-base.
  end.
  assign
    parcurbase-rate   = parbase-rate
    parcurbase-scale  = parbase-scale
    parcurdiscnt-base = 0
    parcurdiscnt-rubl = 0
    parcurfact-qnty   = cl_tt-clcparts.fact-qnty
    parcurcli-qnty    = cl_tt-clcparts.cli-qnty
    parcurdoc-qnty    = cl_tt-clcparts.qnty.
if parcurext-doc-type = 'ot':U or
   parcurext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcur = yes.
end.
else do:
  find first out-vatp_doc-attrcur no-lock
    where out-vatp_doc-attrcur.doc-code  = parcurdoc-code
      and out-vatp_doc-attrcur.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcur then do:
    assign
      out-vatp-have-vat-sltcur = yes.
  end.
  else do:
     out-vatp-have-vat-sltcur = no.
  end.
end.
find first out-vatp_goodscur where out-vatp_goodscur.artic     = parcurartic     and
                                   out-vatp_goodscur.prod-type = parcurprod-type and
                                   out-vatp_goodscur.prod-code = parcurprod-code no-lock.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parcurartic
  ,input  parcurprod-type
  ,input  parcurprod-code
  ,output varroot-nodecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecur
  ,input  'empty-scale=request'
  ,output varempty-scalecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    "Признак" varroot-nodecur skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcur
  )  .
if varoutvprbcur = "base":u then do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax / parcurbase-rate * parcurbase-scale)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   / parcurbase-rate * parcurbase-scale)
  .
end.
if varoutvprbcur = "rubl":u then do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * parcurbase-rate / parcurbase-scale)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * parcurbase-rate / parcurbase-scale) .
end.
assign
  varis-cons-parts-havecur =  no.
assign
  varfact-qntycur       = 0
  varcons-qntycur       = 0
  varprice-base-conscur = 0
  varprice-rubl-conscur = 0.
if cl_tt-clcparts.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococur = cl_tt-clcparts.price-rubl
  price-base-with-tax-lococur = cl_tt-clcparts.price-base
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocur
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocur = yes.
  end.
  else do:
    find first in-vatp_doc-attrocur no-lock
      where in-vatp_doc-attrocur.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrocur.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocur then do:
      assign
        in-vatp-have-vat-sltocur = yes.
    end.
    else do:
         in-vatp-have-vat-sltocur = no.
    end.
  end.
  assign
   price-cli-with-tax-lococur = cl_tt-clcparts.price-cli
   cli-base-rateocur          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-lococur  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-lococur  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-lococur = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-lococur = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-lococur     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-lococur     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-lococur         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-lococur         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
    ASSIGN   slt-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
  assign
    exch-rate-cli-lococur = (cl_tt-clcparts.price-rubl - transport-rubl-lococur - other-rubl-lococur - road-tax-rubl-lococur - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-lococur else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-lococur else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-lococur        = slt-rubl-lococur       / exch-rate-cli-lococur
    vat-cli-lococur        = vat-rubl-lococur       / exch-rate-cli-lococur
    road-tax-cli-lococur   = road-tax-rubl-lococur  / exch-rate-cli-lococur
    transport-cli-lococur  = 0
    other-cli-lococur      = 0
  .
ASSIGN
          price-base-without-tax-lococur = price-base-with-tax-lococur - vat-base-lococur - slt-base-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))
    price-rubl-without-tax-lococur = price-rubl-with-tax-lococur - vat-rubl-lococur - slt-rubl-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))
.
  assign
    varprice-base-conscur    = varprice-base-conscur + (price-base-with-tax-lococur - (if road-tax-base-lococur = ? then 0 else road-tax-base-lococur))* cl_tt-clcparts.fact-qnty
    varprice-rubl-conscur    = varprice-rubl-conscur + (price-rubl-with-tax-lococur - (if road-tax-rubl-lococur = ? then 0 else road-tax-rubl-lococur))* cl_tt-clcparts.fact-qnty
    varis-cons-parts-havecur = yes
    varcons-qntycur          = varcons-qntycur + cl_tt-clcparts.fact-qnty.
end.
assign
  varfact-qntycur = cl_tt-clcparts.fact-qnty.
assign
  varprice-base-conscur = varprice-base-conscur / varcons-qntycur
  varprice-rubl-conscur = varprice-rubl-conscur / varcons-qntycur.
if varprice-base-conscur = ? then do:
  assign
    varprice-base-conscur = 0.
end.
if varprice-rubl-conscur = ? then do:
  assign
    varprice-rubl-conscur = 0.
end.
assign
    slt-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-base-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-base-salecur            = parcurdiscnt-base
  price-base-with-tax-salecur    = (parcurprice-base - parcurdiscnt-base)
    slt-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-rubl-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-rubl-salecur            = parcurdiscnt-rubl
  price-rubl-with-tax-salecur    = (parcurprice-rubl - parcurdiscnt-rubl)
  .
if parcurdoc-type = 'инв':U then do:
  assign
    varfact-qntycur = parcurdoc-qnty.
end.
else do:
  assign
    varfact-qntycur = parcurfact-qnty.
end.
if varis-cons-parts-havecur = no then do:
  assign
        vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
        vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc).
end.
else do:
  if parcurdoc-type = 'инв':U then do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
  else do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-base-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-rubl-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
end.
assign
price-base-without-tax-salecur = price-base-with-tax-salecur - vat-base-salecur - slt-base-salecur - road-tax-base-salecur
price-rubl-without-tax-salecur = price-rubl-with-tax-salecur - vat-rubl-salecur - slt-rubl-salecur - road-tax-rubl-salecur.
end.
create bf_tt-allsum.
assign
  bf_tt-allsum.sum-type = 'основная_сумма':U.
assign
  bf_tt-allsum.fact-qnty          =  cl_tt-clcparts.fact-qnty
  bf_tt-allsum.cli-qnty           =  cl_tt-clcparts.cli-qnty
  bf_tt-allsum.sum-dsc-base-doc   =  (if price-base-with-tax-salecl  = ? then 0 else price-base-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-doc   =  (if price-rubl-with-tax-salecl  = ? then 0 else price-rubl-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-doc       =  (if discnt-base-salecl          = ? then 0 else discnt-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-doc       =  (if discnt-rubl-salecl          = ? then 0 else discnt-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-doc       =  (if slt-base-salecl             = ? then 0 else slt-base-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-doc       =  (if slt-rubl-salecl             = ? then 0 else slt-rubl-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-doc =  (if vat-base-buyercl            = ? then 0 else vat-base-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-doc =  (if vat-rubl-buyercl            = ? then 0 else vat-rubl-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-doc  =  (if road-tax-base-salecl        = ? then 0 else road-tax-base-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-doc  =  (if road-tax-rubl-salecl        = ? then 0 else road-tax-rubl-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-doc    =  (if excise-base-salecl          = ? then 0 else excise-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-doc    =  (if excise-rubl-salecl          = ? then 0 else excise-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-base-cur   =  (if price-base-with-tax-salecur = ? then 0 else price-base-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-cur   =  (if price-rubl-with-tax-salecur = ? then 0 else price-rubl-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-cur       =  (if discnt-base-salecur         = ? then 0 else discnt-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-cur       =  (if discnt-rubl-salecur         = ? then 0 else discnt-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-cur       =  (if slt-base-salecur            = ? then 0 else slt-base-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-cur       =  (if slt-rubl-salecur            = ? then 0 else slt-rubl-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-cur =  (if vat-base-buyercur           = ? then 0 else vat-base-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-cur =  (if vat-rubl-buyercur           = ? then 0 else vat-rubl-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-cur  =  (if road-tax-base-salecur       = ? then 0 else road-tax-base-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-cur  =  (if road-tax-rubl-salecur       = ? then 0 else road-tax-rubl-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-cur    =  (if excise-base-salecur         = ? then 0 else excise-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-cur    =  (if excise-rubl-salecur         = ? then 0 else excise-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  .
if cl_tt-clcparts.purch-code = integer('2':U) then do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl  - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl  - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
else do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
if bf_tt-allsum.vat-base-doc = ? then bf_tt-allsum.vat-base-doc = 0.
if bf_tt-allsum.vat-rubl-doc = ? then bf_tt-allsum.vat-rubl-doc = 0.
assign
  bf_tt-allsum.sum-dsc-base-acc     = (if price-base-with-tax-loccl    = ? then 0 else price-base-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-acc     = (if price-rubl-with-tax-loccl    = ? then 0 else price-rubl-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-cli-acc      = (if (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl = ? then 0
                                        else
                                          (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-acc         = 0
  bf_tt-allsum.dsc-rubl-acc         = 0
  bf_tt-allsum.dsc-cli-acc          = 0
  bf_tt-allsum.vat-base-acc         = (if vat-base-loccl      = ? then 0 else vat-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-acc         = (if vat-rubl-loccl      = ? then 0 else vat-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-cli-acc          = (if vat-cli-loccl / cli-base-ratecl      = ? then 0 else vat-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-acc         = (if slt-base-loccl      = ? then 0 else slt-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-acc         = (if slt-rubl-loccl      = ? then 0 else slt-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-cli-acc          = (if slt-cli-loccl / cli-base-ratecl      = ? then 0 else slt-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-acc    = (if road-tax-base-loccl = ? then 0 else road-tax-base-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-acc    = (if road-tax-rubl-loccl = ? then 0 else road-tax-rubl-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-cli-acc     = (if road-tax-cli-loccl / cli-base-ratecl = ? then 0 else road-tax-cli-loccl / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-acc      = 0
  bf_tt-allsum.excise-rubl-acc      = 0
  bf_tt-allsum.excise-cli-acc       = 0
  bf_tt-allsum.transport-base-acc   = (if transport-base-loccl   = ? then 0 else transport-base-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-rubl-acc   = (if transport-rubl-loccl   = ? then 0 else transport-rubl-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-cli-acc    = (if transport-cli-loccl / cli-base-ratecl   = ? then 0 else transport-cli-loccl / cli-base-ratecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-base-acc       = (if other-base-loccl       = ? then 0 else other-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-rubl-acc       = (if other-rubl-loccl       = ? then 0 else other-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-cli-acc        = (if other-cli-loccl / cli-base-ratecl       = ? then 0 else other-cli-loccl     / cli-base-ratecl  * cl_tt-clcparts.fact-qnty).
create bfs_tt-allsum.
assign
  bfs_tt-allsum.sum-type = 'основная_сумма_со_знаком':U.
if pardoc-type = 'инв':U or
   pardoc-type = 'при':U    or
   pardoc-type = 'возврат':U    then do:
   buffer-copy bf_tt-allsum except bf_tt-allsum.sum-type to bfs_tt-allsum.
end.
else do:
  assign
    bfs_tt-allsum.fact-qnty           =  - bf_tt-allsum.fact-qnty
    bfs_tt-allsum.cli-qnty            =  - bf_tt-allsum.cli-qnty
    bfs_tt-allsum.sum-dsc-base-doc    =  - bf_tt-allsum.sum-dsc-base-doc
    bfs_tt-allsum.sum-dsc-rubl-doc    =  - bf_tt-allsum.sum-dsc-rubl-doc
    bfs_tt-allsum.dsc-base-doc        =  - bf_tt-allsum.dsc-base-doc
    bfs_tt-allsum.dsc-rubl-doc        =  - bf_tt-allsum.dsc-rubl-doc
    bfs_tt-allsum.vat-base-doc        =  - bf_tt-allsum.vat-base-doc
    bfs_tt-allsum.vat-rubl-doc        =  - bf_tt-allsum.vat-rubl-doc
    bfs_tt-allsum.vat-base-buyer-doc  =  - bf_tt-allsum.vat-base-buyer-doc
    bfs_tt-allsum.vat-rubl-buyer-doc  =  - bf_tt-allsum.vat-rubl-buyer-doc
    bfs_tt-allsum.slt-base-doc        =  - bf_tt-allsum.slt-base-doc
    bfs_tt-allsum.slt-rubl-doc        =  - bf_tt-allsum.slt-rubl-doc
    bfs_tt-allsum.road-tax-base-doc   =  - bf_tt-allsum.road-tax-base-doc
    bfs_tt-allsum.road-tax-rubl-doc   =  - bf_tt-allsum.road-tax-rubl-doc
    bfs_tt-allsum.excise-base-doc     =  - bf_tt-allsum.excise-base-doc
    bfs_tt-allsum.excise-rubl-doc     =  - bf_tt-allsum.excise-rubl-doc
    bfs_tt-allsum.sum-dsc-base-cur    =  - bf_tt-allsum.sum-dsc-base-cur
    bfs_tt-allsum.sum-dsc-rubl-cur    =  - bf_tt-allsum.sum-dsc-rubl-cur
    bfs_tt-allsum.dsc-base-cur        =  - bf_tt-allsum.dsc-base-cur
    bfs_tt-allsum.dsc-rubl-cur        =  - bf_tt-allsum.dsc-rubl-cur
    bfs_tt-allsum.vat-base-cur        =  - bf_tt-allsum.vat-base-cur
    bfs_tt-allsum.vat-rubl-cur        =  - bf_tt-allsum.vat-rubl-cur
    bfs_tt-allsum.vat-base-buyer-cur  =  - bf_tt-allsum.vat-base-buyer-cur
    bfs_tt-allsum.vat-rubl-buyer-cur  =  - bf_tt-allsum.vat-rubl-buyer-cur
    bfs_tt-allsum.slt-base-cur        =  - bf_tt-allsum.slt-base-cur
    bfs_tt-allsum.slt-rubl-cur        =  - bf_tt-allsum.slt-rubl-cur
    bfs_tt-allsum.road-tax-base-cur   =  - bf_tt-allsum.road-tax-base-cur
    bfs_tt-allsum.road-tax-rubl-cur   =  - bf_tt-allsum.road-tax-rubl-cur
    bfs_tt-allsum.excise-base-cur     =  - bf_tt-allsum.excise-base-cur
    bfs_tt-allsum.excise-rubl-cur     =  - bf_tt-allsum.excise-rubl-cur
    bfs_tt-allsum.sum-dsc-base-acc    =  - bf_tt-allsum.sum-dsc-base-acc
    bfs_tt-allsum.sum-dsc-rubl-acc    =  - bf_tt-allsum.sum-dsc-rubl-acc
    bfs_tt-allsum.sum-dsc-cli-acc     =  - bf_tt-allsum.sum-dsc-cli-acc
    bfs_tt-allsum.dsc-base-acc        =  - bf_tt-allsum.dsc-base-acc
    bfs_tt-allsum.dsc-rubl-acc        =  - bf_tt-allsum.dsc-rubl-acc
    bfs_tt-allsum.dsc-cli-acc         =  - bf_tt-allsum.dsc-cli-acc
    bfs_tt-allsum.vat-base-acc        =  - bf_tt-allsum.vat-base-acc
    bfs_tt-allsum.vat-rubl-acc        =  - bf_tt-allsum.vat-rubl-acc
    bfs_tt-allsum.vat-cli-acc         =  - bf_tt-allsum.vat-cli-acc
    bfs_tt-allsum.slt-base-acc        =  - bf_tt-allsum.slt-base-acc
    bfs_tt-allsum.slt-rubl-acc        =  - bf_tt-allsum.slt-rubl-acc
    bfs_tt-allsum.slt-cli-acc         =  - bf_tt-allsum.slt-cli-acc
    bfs_tt-allsum.road-tax-base-acc   =  - bf_tt-allsum.road-tax-base-acc
    bfs_tt-allsum.road-tax-rubl-acc   =  - bf_tt-allsum.road-tax-rubl-acc
    bfs_tt-allsum.road-tax-cli-acc    =  - bf_tt-allsum.road-tax-cli-acc
    bfs_tt-allsum.excise-base-acc     =  - bf_tt-allsum.excise-base-acc
    bfs_tt-allsum.excise-rubl-acc     =  - bf_tt-allsum.excise-rubl-acc
    bfs_tt-allsum.excise-cli-acc      =  - bf_tt-allsum.excise-cli-acc
    bfs_tt-allsum.transport-base-acc  =  - bf_tt-allsum.transport-base-acc
    bfs_tt-allsum.transport-rubl-acc  =  - bf_tt-allsum.transport-rubl-acc
    bfs_tt-allsum.transport-cli-acc   =  - bf_tt-allsum.transport-cli-acc
    bfs_tt-allsum.other-base-acc      =  - bf_tt-allsum.other-base-acc
    bfs_tt-allsum.other-rubl-acc      =  - bf_tt-allsum.other-rubl-acc
    bfs_tt-allsum.other-cli-acc       =  - bf_tt-allsum.other-cli-acc.
end.
create bfpc_tt-allsum.
create bfspc_tt-allsum.
case cl_tt-clcparts.purch-code :
when 1           then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_выкупу':U
    bfspc_tt-allsum.sum-type = 'сумма_по_выкупу_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 4    then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_старой_консигнации':U
    bfspc_tt-allsum.sum-type = 'сумма_по_старой_консигнации_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 3 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_ответственному_хранению':U
    bfspc_tt-allsum.sum-type = 'сумма_по_ответственному_хранению_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 2 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_консигнации_выгода':U
    bfspc_tt-allsum.sum-type = 'сумма_по_консигнации_выгода_со_знаком':U.
  assign
    bfpc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfpc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfpc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-doc    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-doc    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-doc        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-doc        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-doc        = bf_tt-allsum.vat-base-doc
    bfpc_tt-allsum.vat-rubl-doc        = bf_tt-allsum.vat-rubl-doc
    bfpc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-buyer-doc  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-buyer-doc  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-doc        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-doc        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-doc   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-doc   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-doc
    bfpc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-doc
    bfpc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-cur    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-cur    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-cur        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-cur        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-cur        = bf_tt-allsum.vat-base-cur
    bfpc_tt-allsum.vat-rubl-cur        = bf_tt-allsum.vat-rubl-cur
    bfpc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-buyer-cur  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-buyer-cur  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-cur        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-cur        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-cur   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-cur   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-cur
    bfpc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-cur
    bfpc_tt-allsum.sum-dsc-base-acc    = 0
    bfpc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfpc_tt-allsum.sum-dsc-cli-acc     = 0
    bfpc_tt-allsum.dsc-base-acc        = 0
    bfpc_tt-allsum.dsc-rubl-acc        = 0
    bfpc_tt-allsum.dsc-cli-acc         = 0
    bfpc_tt-allsum.vat-base-acc        = 0
    bfpc_tt-allsum.vat-rubl-acc        = 0
    bfpc_tt-allsum.vat-cli-acc         = 0
    bfpc_tt-allsum.slt-base-acc        = 0
    bfpc_tt-allsum.slt-rubl-acc        = 0
    bfpc_tt-allsum.slt-cli-acc         = 0
    bfpc_tt-allsum.road-tax-base-acc   = 0
    bfpc_tt-allsum.road-tax-rubl-acc   = 0
    bfpc_tt-allsum.road-tax-cli-acc    = 0
    bfpc_tt-allsum.excise-base-acc     = 0
    bfpc_tt-allsum.excise-rubl-acc     = 0
    bfpc_tt-allsum.excise-cli-acc      = 0
    bfpc_tt-allsum.transport-base-acc  = 0
    bfpc_tt-allsum.transport-rubl-acc  = 0
    bfpc_tt-allsum.transport-cli-acc   = 0
    bfpc_tt-allsum.other-base-acc      = 0
    bfpc_tt-allsum.other-rubl-acc      = 0
    bfpc_tt-allsum.other-cli-acc       = 0
    .
  assign
    bfspc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfspc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfspc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-doc    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-doc    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-doc        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-doc        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-doc        = bfs_tt-allsum.vat-base-doc
    bfspc_tt-allsum.vat-rubl-doc        = bfs_tt-allsum.vat-rubl-doc
    bfspc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-buyer-doc  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-buyer-doc  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-doc        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-doc        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-doc   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-doc   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-doc
    bfspc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-doc
    bfspc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-cur    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-cur    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-cur        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-cur        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-cur        = bfs_tt-allsum.vat-base-cur
    bfspc_tt-allsum.vat-rubl-cur        = bfs_tt-allsum.vat-rubl-cur
    bfspc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-buyer-cur  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-buyer-cur  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-cur        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-cur        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-cur   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-cur   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-cur
    bfspc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-cur
    bfspc_tt-allsum.sum-dsc-base-acc    = 0
    bfspc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfspc_tt-allsum.sum-dsc-cli-acc     = 0
    bfspc_tt-allsum.dsc-base-acc        = 0
    bfspc_tt-allsum.dsc-rubl-acc        = 0
    bfspc_tt-allsum.dsc-cli-acc         = 0
    bfspc_tt-allsum.vat-base-acc        = 0
    bfspc_tt-allsum.vat-rubl-acc        = 0
    bfspc_tt-allsum.vat-cli-acc         = 0
    bfspc_tt-allsum.slt-base-acc        = 0
    bfspc_tt-allsum.slt-rubl-acc        = 0
    bfspc_tt-allsum.slt-cli-acc         = 0
    bfspc_tt-allsum.road-tax-base-acc   = 0
    bfspc_tt-allsum.road-tax-rubl-acc   = 0
    bfspc_tt-allsum.road-tax-cli-acc    = 0
    bfspc_tt-allsum.excise-base-acc     = 0
    bfspc_tt-allsum.excise-rubl-acc     = 0
    bfspc_tt-allsum.excise-cli-acc      = 0
    bfspc_tt-allsum.transport-base-acc  = 0
    bfspc_tt-allsum.transport-rubl-acc  = 0
    bfspc_tt-allsum.transport-cli-acc   = 0
    bfspc_tt-allsum.other-base-acc      = 0
    bfspc_tt-allsum.other-rubl-acc      = 0
    bfspc_tt-allsum.other-cli-acc       = 0
    .
  create bfacc_tt-allsum.
  assign
    bfacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка':U.
  create bfsacc_tt-allsum.
  assign
    bfsacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка_со_знаком':U.
  assign
    bfacc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfacc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfacc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-doc        = 0
    bfacc_tt-allsum.vat-rubl-doc        = 0
    bfacc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-cur        = 0
    bfacc_tt-allsum.vat-rubl-cur        = 0
    bfacc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-acc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-acc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.sum-dsc-cli-acc     = bf_tt-allsum.sum-dsc-cli-acc
    bfacc_tt-allsum.dsc-base-acc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-acc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.dsc-cli-acc         = bf_tt-allsum.dsc-cli-acc
    bfacc_tt-allsum.vat-base-acc        = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-acc        = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.vat-cli-acc         = bf_tt-allsum.vat-cli-acc
    bfacc_tt-allsum.slt-base-acc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-acc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.slt-cli-acc         = bf_tt-allsum.slt-cli-acc
    bfacc_tt-allsum.excise-base-acc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-acc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.excise-cli-acc      = bf_tt-allsum.excise-cli-acc
    bfacc_tt-allsum.road-tax-base-acc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-acc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.road-tax-cli-acc    = bf_tt-allsum.road-tax-cli-acc
    bfacc_tt-allsum.transport-base-acc  = bf_tt-allsum.transport-base-acc
    bfacc_tt-allsum.transport-rubl-acc  = bf_tt-allsum.transport-rubl-acc
    bfacc_tt-allsum.transport-cli-acc   = bf_tt-allsum.transport-cli-acc
    bfacc_tt-allsum.other-base-acc      = bf_tt-allsum.other-base-acc
    bfacc_tt-allsum.other-rubl-acc      = bf_tt-allsum.other-rubl-acc
    bfacc_tt-allsum.other-cli-acc       = bf_tt-allsum.other-cli-acc
    .
  assign
    bfsacc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfsacc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfsacc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-doc        = 0
    bfsacc_tt-allsum.vat-rubl-doc        = 0
    bfsacc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-cur        = 0
    bfsacc_tt-allsum.vat-rubl-cur        = 0
    bfsacc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-acc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-acc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.sum-dsc-cli-acc     = bfs_tt-allsum.sum-dsc-cli-acc
    bfsacc_tt-allsum.dsc-base-acc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-acc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.dsc-cli-acc         = bfs_tt-allsum.dsc-cli-acc
    bfsacc_tt-allsum.vat-base-acc        = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-acc        = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.vat-cli-acc         = bfs_tt-allsum.vat-cli-acc
    bfsacc_tt-allsum.slt-base-acc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-acc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.slt-cli-acc         = bfs_tt-allsum.slt-cli-acc
    bfsacc_tt-allsum.excise-base-acc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-acc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.excise-cli-acc      = bfs_tt-allsum.excise-cli-acc
    bfsacc_tt-allsum.road-tax-base-acc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-acc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.road-tax-cli-acc    = bfs_tt-allsum.road-tax-cli-acc
    bfsacc_tt-allsum.transport-base-acc  = bfs_tt-allsum.transport-base-acc
    bfsacc_tt-allsum.transport-rubl-acc  = bfs_tt-allsum.transport-rubl-acc
    bfsacc_tt-allsum.transport-cli-acc   = bfs_tt-allsum.transport-cli-acc
    bfsacc_tt-allsum.other-base-acc      = bfs_tt-allsum.other-base-acc
    bfsacc_tt-allsum.other-rubl-acc      = bfs_tt-allsum.other-rubl-acc
    bfsacc_tt-allsum.other-cli-acc       = bfs_tt-allsum.other-cli-acc
    .
end.
otherwise do:
  return error substitute ("Неизвестный тип приобретения &1 по партии с кодом &2 по документу &3, порожденную документом &4 по товару &5 &6 &7.",
                           cl_tt-clcparts.purch-code,
                           cl_tt-clcparts.part-code,
                           cl_tt-clcparts.out-code,
                           cl_tt-clcparts.in-code,
                           cl_tt-clcparts.artic,
                           cl_tt-clcparts.prod-type,
                           cl_tt-clcparts.prod-code).
end.
end case.
end.
end procedure.
procedure clcprtsl_calc-line :
define input  parameter parrec-line as recid no-undo.
define variable v-tax-date         as   date                     no-undo.
define variable v-vat-pc           like ub.doc-line.vat-pc       no-undo.
define variable varr-b             as   character                no-undo.
define variable varr-btype         as   character                no-undo.
define variable varcur-base        like ub.gds-dtl.price-base    no-undo.
define variable varcur-road-tax    like ub.doc-line.road-tax     no-undo.
define variable varcur-excise      like ub.doc-line.excise       no-undo.
define variable varcur-vat-pc      like ub.doc-line.vat-pc       no-undo.
define variable varcur-cons-vat-pc like ub.doc-line.cons-vat-pc  no-undo.
define variable varcur-slt-pc      like ub.doc-line.slt-pc       no-undo.
define variable varcur-fact-qnty   like ub.gds-dtl.fact-qnty     no-undo.
define variable varb-code          like ub.bar-code.b-code       no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
define variable varlastcur-base        like ub.gds-dtl.price-base no-undo.
define variable varlastcur-road-tax    like ub.gds-dtl.price-base no-undo.
define variable varlastcur-excise      like ub.gds-dtl.price-base     no-undo.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable v-varsum           as decimal                  no-undo.
define variable varprice-salef as decimal   no-undo .
define buffer bf_trn-doc             for ub.trn-doc.
define buffer bf_doc-line            for ub.doc-line.
define buffer bf_gds-dtl             for ub.gds-dtl.
define buffer bf_goods               for ub.goods.
define buffer bf_parts               for ub.parts.
define buffer bf_sysconf             for ub.sysconf.
define buffer bf_tt-allsum-line      for tt-allsum-line.
define buffer bfs_tt-allsum-line     for tt-allsum-line.
define buffer bfo_tt-allsum-line     for tt-allsum-line.
define buffer bfos_tt-allsum-line    for tt-allsum-line.
define buffer buf_parts        for ub.parts.
v-calcbypart = no.
do on error undo, return error return-value :
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
  find first bf_doc-line where recid (bf_doc-line) = parrec-line no-lock.
  find first bf_trn-doc where bf_trn-doc.doc-code = bf_doc-line.doc-code no-lock.
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  if bf_trn-doc.fact-date <> ?        then do:
    assign v-tax-date = bf_trn-doc.fact-date.
  end.
  else do:
    assign v-tax-date = ?.
  end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  v-tax-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output v-vat-pc
  ) no-error .
  if error-status :error
  or v-vat-pc = ? then do:
     return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
  end.
  if bf_goods.gds-type = 'у':U or
     bf_trn-doc.status_ = 'запрос':U then do:
    for each bf_tt-allsum-line
    on error undo, return error return-value
     :
      delete bf_tt-allsum-line.
    end.
    create bf_tt-allsum-line.
    assign
     bf_tt-allsum-line.sum-type = 'основная_сумма':U.
    for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                              bf_gds-dtl.artic     = bf_doc-line.artic     and
                              bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                              bf_gds-dtl.prod-code = bf_doc-line.prod-code no-lock on error undo, return error return-value :
      assign
        bf_tt-allsum-line.fact-qnty            =  bf_tt-allsum-line.fact-qnty        + bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-doc     =  bf_tt-allsum-line.sum-dsc-base-doc + (bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-doc     =  bf_tt-allsum-line.sum-dsc-rubl-doc + (bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-base-doc         =  bf_tt-allsum-line.dsc-base-doc     + bf_gds-dtl.discnt-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-rubl-doc         =  bf_tt-allsum-line.dsc-rubl-doc     + bf_gds-dtl.discnt-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-cur     =  bf_tt-allsum-line.sum-dsc-base-cur + (if varr-b = "base" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base / bf_trn-doc.exch-rate * bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-cur     =  bf_tt-allsum-line.sum-dsc-rubl-cur + (if varr-b = "rubl" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-acc     =  bf_tt-allsum-line.sum-dsc-base-acc + bf_doc-line.price-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-acc     =  bf_tt-allsum-line.sum-dsc-rubl-acc + bf_doc-line.price-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-cli-acc      =  ?
        bf_tt-allsum-line.vat-base-acc         =  bf_tt-allsum-line.vat-base-acc     + bf_doc-line.price-base * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-rubl-acc         =  bf_tt-allsum-line.vat-rubl-acc     + bf_doc-line.price-rubl * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-cli-acc          =  ?
        .
    end.
    assign
      bf_tt-allsum-line.cli-qnty             =  ?
      bf_tt-allsum-line.slt-base-doc         =  bf_tt-allsum-line.sum-dsc-base-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-doc         =  bf_tt-allsum-line.sum-dsc-rubl-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-base-doc - bf_tt-allsum-line.slt-base-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-rubl-doc - bf_tt-allsum-line.slt-rubl-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-doc    =  0
      bf_tt-allsum-line.road-tax-rubl-doc    =  0
      bf_tt-allsum-line.excise-base-doc      =  0
      bf_tt-allsum-line.excise-rubl-doc      =  0
      bf_tt-allsum-line.vat-base-doc         =  bf_tt-allsum-line.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-doc         =  bf_tt-allsum-line.vat-rubl-buyer-doc
      bf_tt-allsum-line.dsc-base-cur         =  0
      bf_tt-allsum-line.dsc-rubl-cur         =  0
      bf_tt-allsum-line.slt-base-cur         =  bf_tt-allsum-line.sum-dsc-base-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-cur         =  bf_tt-allsum-line.sum-dsc-rubl-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-base-cur - bf_tt-allsum-line.slt-base-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-rubl-cur - bf_tt-allsum-line.slt-rubl-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-cur    =  0
      bf_tt-allsum-line.road-tax-rubl-cur    =  0
      bf_tt-allsum-line.excise-base-cur      =  0
      bf_tt-allsum-line.excise-rubl-cur      =  0
      bf_tt-allsum-line.vat-base-cur         =  bf_tt-allsum-line.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-cur         =  bf_tt-allsum-line.vat-rubl-buyer-cur
      bf_tt-allsum-line.dsc-base-acc         =  0
      bf_tt-allsum-line.dsc-rubl-acc         =  0
      bf_tt-allsum-line.dsc-cli-acc          =  0
      bf_tt-allsum-line.slt-base-acc         =  0
      bf_tt-allsum-line.slt-rubl-acc         =  0
      bf_tt-allsum-line.slt-cli-acc          =  0
      bf_tt-allsum-line.road-tax-base-acc    =  0
      bf_tt-allsum-line.road-tax-rubl-acc    =  0
      bf_tt-allsum-line.road-tax-cli-acc     =  0
      bf_tt-allsum-line.excise-base-acc      =  0
      bf_tt-allsum-line.excise-rubl-acc      =  0
      bf_tt-allsum-line.excise-cli-acc       =  0
      bf_tt-allsum-line.transport-base-acc   =  0
      bf_tt-allsum-line.transport-rubl-acc   =  0
      bf_tt-allsum-line.transport-cli-acc    =  0
      bf_tt-allsum-line.other-base-acc       =  0
      bf_tt-allsum-line.other-rubl-acc       =  0
      bf_tt-allsum-line.other-cli-acc        =  0
      .
    create bfs_tt-allsum-line.
    assign
    bfs_tt-allsum-line.sum-type = 'основная_сумма_со_знаком':U.
    if bf_trn-doc.doc-type = 'инв':U or
       bf_trn-doc.doc-type = 'при':U    or
       bf_trn-doc.doc-type = 'возврат':U    then do:
       buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfs_tt-allsum-line.
    end.
    else do:
      assign
        bfs_tt-allsum-line.fact-qnty           =  - bf_tt-allsum-line.fact-qnty
        bfs_tt-allsum-line.cli-qnty            =  - bf_tt-allsum-line.cli-qnty
        bfs_tt-allsum-line.sum-dsc-base-doc    =  - bf_tt-allsum-line.sum-dsc-base-doc
        bfs_tt-allsum-line.sum-dsc-rubl-doc    =  - bf_tt-allsum-line.sum-dsc-rubl-doc
        bfs_tt-allsum-line.dsc-base-doc        =  - bf_tt-allsum-line.dsc-base-doc
        bfs_tt-allsum-line.dsc-rubl-doc        =  - bf_tt-allsum-line.dsc-rubl-doc
        bfs_tt-allsum-line.vat-base-doc        =  - bf_tt-allsum-line.vat-base-doc
        bfs_tt-allsum-line.vat-rubl-doc        =  - bf_tt-allsum-line.vat-rubl-doc
        bfs_tt-allsum-line.vat-base-buyer-doc  =  - bf_tt-allsum-line.vat-base-buyer-doc
        bfs_tt-allsum-line.vat-rubl-buyer-doc  =  - bf_tt-allsum-line.vat-rubl-buyer-doc
        bfs_tt-allsum-line.slt-base-doc        =  - bf_tt-allsum-line.slt-base-doc
        bfs_tt-allsum-line.slt-rubl-doc        =  - bf_tt-allsum-line.slt-rubl-doc
        bfs_tt-allsum-line.road-tax-base-doc   =  - bf_tt-allsum-line.road-tax-base-doc
        bfs_tt-allsum-line.road-tax-rubl-doc   =  - bf_tt-allsum-line.road-tax-rubl-doc
        bfs_tt-allsum-line.excise-base-doc     =  - bf_tt-allsum-line.excise-base-doc
        bfs_tt-allsum-line.excise-rubl-doc     =  - bf_tt-allsum-line.excise-rubl-doc
        bfs_tt-allsum-line.sum-dsc-base-cur    =  - bf_tt-allsum-line.sum-dsc-base-cur
        bfs_tt-allsum-line.sum-dsc-rubl-cur    =  - bf_tt-allsum-line.sum-dsc-rubl-cur
        bfs_tt-allsum-line.dsc-base-cur        =  - bf_tt-allsum-line.dsc-base-cur
        bfs_tt-allsum-line.dsc-rubl-cur        =  - bf_tt-allsum-line.dsc-rubl-cur
        bfs_tt-allsum-line.vat-base-cur        =  - bf_tt-allsum-line.vat-base-cur
        bfs_tt-allsum-line.vat-rubl-cur        =  - bf_tt-allsum-line.vat-rubl-cur
        bfs_tt-allsum-line.vat-base-buyer-cur  =  - bf_tt-allsum-line.vat-base-buyer-cur
        bfs_tt-allsum-line.vat-rubl-buyer-cur  =  - bf_tt-allsum-line.vat-rubl-buyer-cur
        bfs_tt-allsum-line.slt-base-cur        =  - bf_tt-allsum-line.slt-base-cur
        bfs_tt-allsum-line.slt-rubl-cur        =  - bf_tt-allsum-line.slt-rubl-cur
        bfs_tt-allsum-line.road-tax-base-cur   =  - bf_tt-allsum-line.road-tax-base-cur
        bfs_tt-allsum-line.road-tax-rubl-cur   =  - bf_tt-allsum-line.road-tax-rubl-cur
        bfs_tt-allsum-line.excise-base-cur     =  - bf_tt-allsum-line.excise-base-cur
        bfs_tt-allsum-line.excise-rubl-cur     =  - bf_tt-allsum-line.excise-rubl-cur
        bfs_tt-allsum-line.sum-dsc-base-acc    =  - bf_tt-allsum-line.sum-dsc-base-acc
        bfs_tt-allsum-line.sum-dsc-rubl-acc    =  - bf_tt-allsum-line.sum-dsc-rubl-acc
        bfs_tt-allsum-line.sum-dsc-cli-acc     =  - bf_tt-allsum-line.sum-dsc-cli-acc
        bfs_tt-allsum-line.dsc-base-acc        =  - bf_tt-allsum-line.dsc-base-acc
        bfs_tt-allsum-line.dsc-rubl-acc        =  - bf_tt-allsum-line.dsc-rubl-acc
        bfs_tt-allsum-line.dsc-cli-acc         =  - bf_tt-allsum-line.dsc-cli-acc
        bfs_tt-allsum-line.vat-base-acc        =  - bf_tt-allsum-line.vat-base-acc
        bfs_tt-allsum-line.vat-rubl-acc        =  - bf_tt-allsum-line.vat-rubl-acc
        bfs_tt-allsum-line.vat-cli-acc         =  - bf_tt-allsum-line.vat-cli-acc
        bfs_tt-allsum-line.slt-base-acc        =  - bf_tt-allsum-line.slt-base-acc
        bfs_tt-allsum-line.slt-rubl-acc        =  - bf_tt-allsum-line.slt-rubl-acc
        bfs_tt-allsum-line.slt-cli-acc         =  - bf_tt-allsum-line.slt-cli-acc
        bfs_tt-allsum-line.road-tax-base-acc   =  - bf_tt-allsum-line.road-tax-base-acc
        bfs_tt-allsum-line.road-tax-rubl-acc   =  - bf_tt-allsum-line.road-tax-rubl-acc
        bfs_tt-allsum-line.road-tax-cli-acc    =  - bf_tt-allsum-line.road-tax-cli-acc
        bfs_tt-allsum-line.excise-base-acc     =  - bf_tt-allsum-line.excise-base-acc
        bfs_tt-allsum-line.excise-rubl-acc     =  - bf_tt-allsum-line.excise-rubl-acc
        bfs_tt-allsum-line.excise-cli-acc      =  - bf_tt-allsum-line.excise-cli-acc
        bfs_tt-allsum-line.transport-base-acc  =  - bf_tt-allsum-line.transport-base-acc
        bfs_tt-allsum-line.transport-rubl-acc  =  - bf_tt-allsum-line.transport-rubl-acc
        bfs_tt-allsum-line.transport-cli-acc   =  - bf_tt-allsum-line.transport-cli-acc
        bfs_tt-allsum-line.other-base-acc      =  - bf_tt-allsum-line.other-base-acc
        bfs_tt-allsum-line.other-rubl-acc      =  - bf_tt-allsum-line.other-rubl-acc
        bfs_tt-allsum-line.other-cli-acc       =  - bf_tt-allsum-line.other-cli-acc
        .
    end.
    create bfo_tt-allsum-line.
    assign
      bfo_tt-allsum-line.sum-type = 'сумма_по_услуге':U.
    buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfo_tt-allsum-line.
    create bfos_tt-allsum-line.
    assign
      bfos_tt-allsum-line.sum-type = 'сумма_по_услуге_со_знаком':U.
    buffer-copy bfs_tt-allsum-line except bfs_tt-allsum-line.sum-type to bfos_tt-allsum-line.
  end.
  else do:
    assign
      varlastcur-base      = 0
      varlastcur-road-tax  = 0
      varlastcur-excise    = 0
      varcur-base          = 0
      varcur-road-tax      = 0
      varcur-excise        = 0
      varcur-vat-pc        = 0
      varcur-slt-pc        = 0
      varcur-fact-qnty     = 0
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  ?
  ,output varb-code
  )  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcprcex in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  ,output varcur-vat-pc
  ,output varcur-slt-pc
  )  .
    if varprice-sale = ?
    then do:
      assign
        varcur-vat-pc = 0
        varcur-slt-pc = 0
      .
    end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  bf_trn-doc.fact-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output varcur-vat-pc
  ) no-error .
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    v-calcbypart = no.
    if bf_doc-line.whole-send-news = integer('1':U)   then
    v-calcbypart = yes.
    else do:
    for each bf_gds-dtl no-lock
      where bf_gds-dtl.doc-code  = bf_doc-line.doc-code
        and bf_gds-dtl.artic     = bf_doc-line.artic
        and bf_gds-dtl.prod-type = bf_doc-line.prod-type
        and bf_gds-dtl.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-dtl.prt-code
  ,output varb-code
  ) no-error .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  )  .
          if varprice-sale = ?
          then do:
            assign
              varprice-sale = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
            varlastcur-base     = varprice-sale
            varlastcur-road-tax = varroad-tax
            varlastcur-excise   = varexcise
            varcur-base         = varcur-base      + varprice-sale * bf_gds-dtl.fact-qnty
            varcur-road-tax     = varcur-road-tax  + varroad-tax   * bf_gds-dtl.fact-qnty
            varcur-excise       = varcur-excise    + varexcise     * bf_gds-dtl.fact-qnty
            varcur-fact-qnty    = varcur-fact-qnty + bf_gds-dtl.fact-qnty
          .
      end.
    end.
    if varcur-fact-qnty = 0 then do:
      assign
        varcur-base      = varlastcur-base
        varcur-road-tax  = varlastcur-road-tax
        varcur-excise    = varlastcur-excise
      .
    end.
    else do:
      assign
        varcur-base      = varcur-base      / varcur-fact-qnty
        varcur-road-tax  = varcur-road-tax  / varcur-fact-qnty
        varcur-excise    = varcur-excise    / varcur-fact-qnty
      .
    end.
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НДС по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НП по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
    assign
      varcur-cons-vat-pc = bf_sysconf.cons-vat-pc.
    if varcur-cons-vat-pc = ? then do:
      return error substitute ("Нет текущего продажного консигнационного НДС по фирме &1", bf_trn-doc.host-code).
    end.
    define buffer buf_tt-clcparts for tt-clcparts .
    for each buf_tt-clcparts
    on error undo, return error return-value
    :
      delete buf_tt-clcparts.
    end.
    for each bf_parts no-lock
      where bf_parts.out-code  = bf_doc-line.doc-code
        and bf_parts.obj-type  = bf_doc-line.obj-type
        and bf_parts.obj-code  = bf_doc-line.obj-code
        and bf_parts.artic     = bf_doc-line.artic
        and bf_parts.prod-type = bf_doc-line.prod-type
        and bf_parts.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
      create buf_tt-clcparts .
      buffer-copy bf_parts to buf_tt-clcparts .
      if v-calcbypart = yes   then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer bf_parts
  ,output v-b-pcode
  ) no-error .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_parts.obj-type
  ,input  bf_parts.obj-code
  ,input  v-b-pcode
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-salef
  ,output varroad-tax
  ,output varexcise
  ) no-error .
          if varprice-sale = ?
          then do:
            assign
              varprice-salef = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
          part-cur-base  = varprice-salef
          part-cur-road-tax  = varroad-tax
          part-cur-excise = varexcise.
      end.
    end.
    run clcprtsl_calc-ttable in this-procedure
      (input yes,
       input yes,
       input bf_doc-line.road-tax,
       input bf_doc-line.excise,
       input bf_doc-line.vat-pc,
       input bf_doc-line.cons-vat-pc,
       input bf_doc-line.slt-pc,
       input bf_trn-doc.base-rate,
       input bf_trn-doc.base-scale,
       input varr-b,
       input varcur-base,
       input varcur-road-tax,
       input varcur-excise,
       input varcur-vat-pc,
       input varcur-cons-vat-pc,
       input varcur-slt-pc
       ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры clcprtsl_calc-ttable." skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error .
    end.
  end.
end.
end.
procedure clcprtsl_calc-ttable :
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcur-road-tax     like ub.doc-line.road-tax    no-undo.
define input parameter parcur-excise       like ub.doc-line.excise      no-undo.
define input parameter parcur-vat-pc       like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define buffer bf_tt-allsum      for tt-allsum.
define buffer bf_tt-clcparts    for tt-clcparts.
define buffer bf_tt-allsum-line for tt-allsum-line.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
do on error undo, return error return-value :
for each bf_tt-allsum-line
on error undo, return error return-value
 :
  delete bf_tt-allsum-line.
end.
for each bf_tt-allsum
on error undo, return error return-value
:
  delete bf_tt-allsum.
end.
for each bf_tt-clcparts
on error undo, return error return-value
:
if v-calcbypart then do:
          assign
          parcur-base =   bf_tt-clcparts.part-cur-base
          parcur-road-tax = bf_tt-clcparts.part-cur-road-tax
          parcur-excise =   bf_tt-clcparts.part-cur-excise
          .
end.
   run clcprtsl_calc-parts in this-procedure (
     input recid(bf_tt-clcparts),
     input paris-doc,
     input paris-cur,
     input parroad-tax,
     input parexcise,
     input parvat-pc,
     input parcons-vat-pc,
     input parslt-pc,
     input parbase-rate,
     input parbase-scale,
     input parr-b,
     input parcur-base,
     input parcur-road-tax,
     input parcur-excise,
     input parcur-vat-pc,
     input parcurcons-vat-pc,
     input parcurslt-pc
     ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      vss-include-info8 skip
      "Ошибка при обсчете партии" skip
      "Документ партии " bf_tt-clcparts.out-code skip
      "Товар" bf_tt-clcparts.artic bf_tt-clcparts.prod-type bf_tt-clcparts.prod-code skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error .
    undo, return error .
  end.
  for each bf_tt-allsum on error undo, return error return-value :
    find first bf_tt-allsum-line where bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type no-error.
    if not available bf_tt-allsum-line then do:
      create bf_tt-allsum-line.
      assign
        bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type.
    end.
    assign
      bf_tt-allsum-line.fact-qnty              = bf_tt-allsum-line.fact-qnty            + bf_tt-allsum.fact-qnty
      bf_tt-allsum-line.cli-qnty               = bf_tt-allsum-line.cli-qnty             + bf_tt-allsum.cli-qnty
      bf_tt-allsum-line.sum-dsc-base-doc       = bf_tt-allsum-line.sum-dsc-base-doc     + bf_tt-allsum.sum-dsc-base-doc
      bf_tt-allsum-line.sum-dsc-rubl-doc       = bf_tt-allsum-line.sum-dsc-rubl-doc     + bf_tt-allsum.sum-dsc-rubl-doc
      bf_tt-allsum-line.dsc-base-doc           = bf_tt-allsum-line.dsc-base-doc         + bf_tt-allsum.dsc-base-doc
      bf_tt-allsum-line.dsc-rubl-doc           = bf_tt-allsum-line.dsc-rubl-doc         + bf_tt-allsum.dsc-rubl-doc
      bf_tt-allsum-line.vat-base-doc           = bf_tt-allsum-line.vat-base-doc         + bf_tt-allsum.vat-base-doc
      bf_tt-allsum-line.vat-rubl-doc           = bf_tt-allsum-line.vat-rubl-doc         + bf_tt-allsum.vat-rubl-doc
      bf_tt-allsum-line.vat-base-buyer-doc     = bf_tt-allsum-line.vat-base-buyer-doc   + bf_tt-allsum.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-buyer-doc     = bf_tt-allsum-line.vat-rubl-buyer-doc   + bf_tt-allsum.vat-rubl-buyer-doc
      bf_tt-allsum-line.slt-base-doc           = bf_tt-allsum-line.slt-base-doc         + bf_tt-allsum.slt-base-doc
      bf_tt-allsum-line.slt-rubl-doc           = bf_tt-allsum-line.slt-rubl-doc         + bf_tt-allsum.slt-rubl-doc
      bf_tt-allsum-line.road-tax-base-doc      = bf_tt-allsum-line.road-tax-base-doc    + bf_tt-allsum.road-tax-base-doc
      bf_tt-allsum-line.road-tax-rubl-doc      = bf_tt-allsum-line.road-tax-rubl-doc    + bf_tt-allsum.road-tax-rubl-doc
      bf_tt-allsum-line.excise-base-doc        = bf_tt-allsum-line.excise-base-doc      + bf_tt-allsum.excise-base-doc
      bf_tt-allsum-line.excise-rubl-doc        = bf_tt-allsum-line.excise-rubl-doc      + bf_tt-allsum.excise-rubl-doc
      bf_tt-allsum-line.sum-dsc-base-cur       = bf_tt-allsum-line.sum-dsc-base-cur     + bf_tt-allsum.sum-dsc-base-cur
      bf_tt-allsum-line.sum-dsc-rubl-cur       = bf_tt-allsum-line.sum-dsc-rubl-cur     + bf_tt-allsum.sum-dsc-rubl-cur
      bf_tt-allsum-line.dsc-base-cur           = bf_tt-allsum-line.dsc-base-cur         + bf_tt-allsum.dsc-base-cur
      bf_tt-allsum-line.dsc-rubl-cur           = bf_tt-allsum-line.dsc-rubl-cur         + bf_tt-allsum.dsc-rubl-cur
      bf_tt-allsum-line.vat-base-cur           = bf_tt-allsum-line.vat-base-cur         + bf_tt-allsum.vat-base-cur
      bf_tt-allsum-line.vat-rubl-cur           = bf_tt-allsum-line.vat-rubl-cur         + bf_tt-allsum.vat-rubl-cur
      bf_tt-allsum-line.vat-base-buyer-cur     = bf_tt-allsum-line.vat-base-buyer-cur   + bf_tt-allsum.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-buyer-cur     = bf_tt-allsum-line.vat-rubl-buyer-cur   + bf_tt-allsum.vat-rubl-buyer-cur
      bf_tt-allsum-line.slt-base-cur           = bf_tt-allsum-line.slt-base-cur         + bf_tt-allsum.slt-base-cur
      bf_tt-allsum-line.slt-rubl-cur           = bf_tt-allsum-line.slt-rubl-cur         + bf_tt-allsum.slt-rubl-cur
      bf_tt-allsum-line.road-tax-base-cur      = bf_tt-allsum-line.road-tax-base-cur    + bf_tt-allsum.road-tax-base-cur
      bf_tt-allsum-line.road-tax-rubl-cur      = bf_tt-allsum-line.road-tax-rubl-cur    + bf_tt-allsum.road-tax-rubl-cur
      bf_tt-allsum-line.excise-base-cur        = bf_tt-allsum-line.excise-base-cur      + bf_tt-allsum.excise-base-cur
      bf_tt-allsum-line.excise-rubl-cur        = bf_tt-allsum-line.excise-rubl-cur      + bf_tt-allsum.excise-rubl-cur
      bf_tt-allsum-line.sum-dsc-base-acc       = bf_tt-allsum-line.sum-dsc-base-acc     + bf_tt-allsum.sum-dsc-base-acc
      bf_tt-allsum-line.sum-dsc-rubl-acc       = bf_tt-allsum-line.sum-dsc-rubl-acc     + bf_tt-allsum.sum-dsc-rubl-acc
      bf_tt-allsum-line.sum-dsc-cli-acc        = bf_tt-allsum-line.sum-dsc-cli-acc      + bf_tt-allsum.sum-dsc-cli-acc
      bf_tt-allsum-line.dsc-base-acc           = bf_tt-allsum-line.dsc-base-acc         + bf_tt-allsum.dsc-base-acc
      bf_tt-allsum-line.dsc-rubl-acc           = bf_tt-allsum-line.dsc-rubl-acc         + bf_tt-allsum.dsc-rubl-acc
      bf_tt-allsum-line.dsc-cli-acc            = bf_tt-allsum-line.dsc-cli-acc          + bf_tt-allsum.dsc-cli-acc
      bf_tt-allsum-line.vat-base-acc           = bf_tt-allsum-line.vat-base-acc         + bf_tt-allsum.vat-base-acc
      bf_tt-allsum-line.vat-rubl-acc           = bf_tt-allsum-line.vat-rubl-acc         + bf_tt-allsum.vat-rubl-acc
      bf_tt-allsum-line.vat-cli-acc            = bf_tt-allsum-line.vat-cli-acc          + bf_tt-allsum.vat-cli-acc
      bf_tt-allsum-line.slt-base-acc           = bf_tt-allsum-line.slt-base-acc         + bf_tt-allsum.slt-base-acc
      bf_tt-allsum-line.slt-rubl-acc           = bf_tt-allsum-line.slt-rubl-acc         + bf_tt-allsum.slt-rubl-acc
      bf_tt-allsum-line.slt-cli-acc            = bf_tt-allsum-line.slt-cli-acc          + bf_tt-allsum.slt-cli-acc
      bf_tt-allsum-line.road-tax-base-acc      = bf_tt-allsum-line.road-tax-base-acc    + bf_tt-allsum.road-tax-base-acc
      bf_tt-allsum-line.road-tax-rubl-acc      = bf_tt-allsum-line.road-tax-rubl-acc    + bf_tt-allsum.road-tax-rubl-acc
      bf_tt-allsum-line.road-tax-cli-acc       = bf_tt-allsum-line.road-tax-cli-acc     + bf_tt-allsum.road-tax-cli-acc
      bf_tt-allsum-line.excise-base-acc        = bf_tt-allsum-line.excise-base-acc      + bf_tt-allsum.excise-base-acc
      bf_tt-allsum-line.excise-rubl-acc        = bf_tt-allsum-line.excise-rubl-acc      + bf_tt-allsum.excise-rubl-acc
      bf_tt-allsum-line.excise-cli-acc         = bf_tt-allsum-line.excise-cli-acc       + bf_tt-allsum.excise-cli-acc
      bf_tt-allsum-line.transport-base-acc     = bf_tt-allsum-line.transport-base-acc   + bf_tt-allsum.transport-base-acc
      bf_tt-allsum-line.transport-rubl-acc     = bf_tt-allsum-line.transport-rubl-acc   + bf_tt-allsum.transport-rubl-acc
      bf_tt-allsum-line.transport-cli-acc      = bf_tt-allsum-line.transport-cli-acc    + bf_tt-allsum.transport-cli-acc
      bf_tt-allsum-line.other-base-acc         = bf_tt-allsum-line.other-base-acc       + bf_tt-allsum.other-base-acc
      bf_tt-allsum-line.other-rubl-acc         = bf_tt-allsum-line.other-rubl-acc       + bf_tt-allsum.other-rubl-acc
      bf_tt-allsum-line.other-cli-acc          = bf_tt-allsum-line.other-cli-acc        + bf_tt-allsum.other-cli-acc
      .
  end.
end.
end.
end procedure.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
~
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure discfgru-check :
define input parameter p-table-name as character no-undo .
define input parameter p-templ-rl-root as integer no-undo .
define input parameter p-time-templ-rl-root as integer no-undo .
define input parameter p-pos-type as character no-undo .
define output parameter p-disnct-role as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
  do
  on error undo, return error return-value
  :
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.table-name = p-table-name
        and buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
        and (p-time-templ-rl-root = ? or  buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root)
        and buf_dis-cfg-rule.pos-type = p-pos-type no-error.
    if not available buf_dis-cfg-rule
    or p-pos-type = "":U
    then do:
       return error substitute("Для места использования типа &1 не определен тип скидки с шаблоном &2 &3"
                               ,entry (lookup (p-pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)
                               , p-templ-rl-root
                               , (if p-time-templ-rl-root = ?
                                  then '':U
                                  else substitute("с расписанием типа &1", p-time-templ-rl-root)
                                  )
                               ).
    end.
    assign
    p-disnct-role = buf_dis-cfg-rule.discnt-role
    .
  end.
end procedure.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
procedure disgdsru-name :
define buffer buf_dis-rule for ub.dis-rule.
do
  on error undo, return error
  :
  define input  parameter p-templ-rl-root  as integer no-undo .
  define output parameter p-label          as character no-undo .
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-templ-rl-root no-error.
  if available buf_dis-rule
  then do:
    if buf_dis-rule.rule-num > 0 then
    p-label = buf_dis-rule.des.
  end.
  else do:
    p-label = substitute("Неизвестный тип правила скидки &1", p-templ-rl-root).
  end.
end.
end procedure.
function disgdsru-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run disgdsru-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.
function disgdsru-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-rule-label as character no-undo .
return entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u).
end function.
procedure disgdsru-write :
  do
  on error undo, return error
  :
    define input parameter p-obj-type       like ub.dis-gds-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-gds-rule.obj-code   no-undo .
    define input parameter p-gds-code       like ub.dis-gds-rule.gds-code   no-undo .
    define input parameter p-pos-type       like ub.dis-gds-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-gds-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-gds-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-gds-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-gds-rule.rule-num    no-undo .
    define input parameter p-nonunique      like ub.dis-gds-rule.nonunique   no-undo .
    define buffer buf_dis-gds-rule for ub.dis-gds-rule .
    define buffer buf_dis-rule for ub.dis-rule.
    define buffer lock_dis-gds-rule for ub.dis-gds-rule .
    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .
    run discfgru-check in this-procedure (
                                          input 'dis-gds-rule':U
                                         ,input p-templ-rl-root
                                         ,input p-time-templ-rl-root
                                         ,input p-pos-type
                                         ,output v-discnt-role
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-discnt-role = ? then do:
      p-discnt-role = v-discnt-role.
    end.
    if p-discnt-role <> v-discnt-role then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6не может быть по шаблону &7 и расписанию &8"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    if p-pos-type = ? then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type26 as character no-undo .
define variable v-value-date26 as date no-undo .
define variable v-value-decimal26 as decimal no-undo .
define variable v-value-integer26 as INTEGER no-undo .
define variable v-value-logical26 AS LOGICAL no-undo .
define variable v-tth26 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output p-pos-type
    ,output v-value-date26
    ,output v-value-decimal26
    ,output v-value-integer26
    ,output v-value-logical26
    ,output v-param-type26
    ,INPUT-OUTPUT table-handle v-tth26
    )  .
delete object v-tth26 no-error.
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
    if not available buf_Dis-rule then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6не найдено правило скидки &7"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6правило скидки &7 - некорневое"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if not (p-obj-type = buf_dis-rule.obj-type
        and p-obj-code = buf_dis-rule.obj-code)
    and not ( (p-obj-type = 'маг':U or p-obj-type = 'скл':U )
             and
             (buf_dis-rule.obj-type = 'орг':U or buf_dis-rule.obj-type = ""))
     then do:
      undo, return error (substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ) +
                          substitute("Правило скидки &1 определено для &2&3" +
                                     "а привязка к товару для &4"
                                     ,buf_dis-rule.rule-num
                                     ,get-objregion( buf_dis-rule.obj-type, buf_Dis-rule.obj-code)
                                     ,chr(10)
                                     ,get-objregion( p-obj-type, p-obj-code)
                                     ))
                              .
    end.
    find first buf_dis-gds-rule exclusive-lock where
               buf_dis-gds-rule.gds-code  = p-gds-code
           AND buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
           AND buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
           AND buf_dis-gds-rule.pos-type  = p-pos-type
           AND buf_dis-gds-rule.discnt-role = p-discnt-role
           and buf_dis-gds-rule.nonunique = p-nonunique
           no-error .
    if not available buf_dis-gds-rule then do:
      find first buf_dis-gds-rule exclusive-lock where
                buf_dis-gds-rule.gds-code  = p-gds-code
            AND buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
            AND buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
            AND buf_dis-gds-rule.pos-type  = p-pos-type
            AND buf_dis-gds-rule.discnt-role = p-discnt-role
            no-error .
      if available buf_Dis-gds-rule then do:
        if p-nonunique = ''
        and available buf_dis-gds-rule
        then do:
          return error substitute("Скидка типа &1 на товар с кодом &2 &3&4 уже существует (детализ. &3)"
                                   , entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                                   , p-gds-code
                                   , buf_Dis-rule.obj-type
                                   , buf_Dis-rule.obj-code
                                   , p-nonunique
                                  ).
        end.
        if available buf_dis-gds-rule
        and buf_dis-gds-rule.nonunique = ''
        and p-nonunique <> ''then do:
          return error substitute("Скидка типа &1 на товар с кодом &2 &3&4 уже существует"
                                   , entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                                   , p-gds-code
                                   , buf_Dis-rule.obj-type
                                   , buf_Dis-rule.obj-code
                                  ).
        end.
      end.
      create buf_dis-gds-rule .
      assign
      buf_dis-gds-rule.gds-code  = p-gds-code
      buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
      buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
      buf_dis-gds-rule.pos-type = p-pos-type
      buf_dis-gds-rule.discnt-role = v-discnt-role
      buf_dis-gds-rule.rule-num = p-rule-num
      buf_dis-gds-rule.nonunique = p-nonunique
      no-error
      .
    end.
    ASSIGN
    buf_dis-gds-rule.rule-num = p-rule-num
    buf_dis-gds-rule.rl-root = buf_Dis-rule.rl-root
    buf_dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-gds-rule.templ-rl-root = p-templ-rl-root
    buf_dis-gds-rule.nonunique = p-nonunique
    no-error.
  end.
end procedure.
PROCEDURE cmp-disgdsru-write :
do
on error undo, return error
:
  define input parameter p-gds-code like ub.dis-gds-rule.gds-code   no-undo .
  define input parameter p-obj-type like ub.dis-gds-rule.obj-type   no-undo .
  define input parameter p-obj-code like ub.dis-gds-rule.obj-code   no-undo .
  define input parameter p-pos-type like ub.dis-gds-rule.pos-type   no-undo .
  define input parameter p-templ-rl-root     like ub.dis-gds-rule.templ-rl-root  no-undo .
  define input parameter p-time-templ-rl-root     like ub.dis-gds-rule.time-templ-rl-root  no-undo .
  define input parameter p-discnt-role like ub.dis-gds-rule.discnt-role no-undo .
  define input parameter p-rule-num    like ub.dis-gds-rule.rule-num no-undo .
  define input parameter p-nonunique like ub.dis-gds-rule.nonunique no-undo .
  define variable v-rule-label          as character no-undo .
  define buffer buf_tt0-dis-gds-rule for ub.dis-gds-rule .
  define buffer buf_dis-rule     for ub.dis-rule.
  run disgdsru-name in this-procedure (
                                      input  p-templ-rl-root
                                      ,output v-rule-label
                                      ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  find first buf_tt0-dis-gds-rule exclusive-lock where
              buf_tt0-dis-gds-rule.gds-code  = p-gds-code
          AND buf_tt0-dis-gds-rule.obj-type  = p-obj-type
          AND buf_tt0-dis-gds-rule.obj-code  = p-obj-code
          AND buf_tt0-dis-gds-rule.pos-type  = p-pos-type
          AND buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
          AND buf_tt0-dis-gds-rule.nonunique = p-nonunique
          no-error .
  if not available buf_tt0-dis-gds-rule then do:
    create buf_tt0-dis-gds-rule .
    assign
    buf_tt0-dis-gds-rule.gds-code  = p-gds-code
    buf_tt0-dis-gds-rule.obj-type  = p-obj-type
    buf_tt0-dis-gds-rule.obj-code  = p-obj-code
    buf_tt0-dis-gds-rule.pos-type  = p-pos-type
    buf_tt0-dis-gds-rule.nonunique = p-nonunique
    buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
    no-error
    .
  end.
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-rule-num.
  ASSIGN
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rule-num = p-rule-num
  buf_tt0-dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
  buf_tt0-dis-gds-rule.nonunique = p-nonunique
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rl-root = buf_Dis-rule.rl-root
  no-error.
  release buf_tt0-dis-gds-rule no-error .
  if error-status:error then do:
    undo, return error return-value .
  end.
end.
END PROCEDURE.
  define new global shared variable g#lib-rvs as handle no-undo.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable ptrlprop-denstclc      as character no-undo initial 'shft_rvs-inc':U .
define variable ptrlprop-inpptrl       as character no-undo initial 'weight':U .
define variable ptrlprop-expptrl       as character no-undo initial 'volume':U .
define variable ptrlprop-autopump      as logical   no-undo initial false .
define variable ptrlprop-avtinvpm      as logical   no-undo initial false .
define variable ptrlprop-rvsnmter      as logical   no-undo initial false .
define variable ptrlprop-olddens       as logical   no-undo initial false .
define variable ptrlprop-invclipt      as integer   no-undo initial ? .
define variable ptrlprop-algrvspt      as integer   no-undo initial 1 .
define variable ptrlprop-temp-for-pomi as integer   no-undo initial 1 .
define variable ptrlprop-algoincome as integer no-undo init 0.
define variable ptrlprop-mand-choice-autocar as logical no-undo init false.
define variable ptrlprop-Delta-mass-horiz      as character no-undo .
define variable ptrlprop-Delta-mass-vert       as character no-undo .
define variable ptrlprop-calc-free-vol as logical no-undo init false.
define variable ptrlprop-calc-free-vol-sug as logical no-undo init false.
define variable ptrlprop-trn-reas-sug as logical no-undo init true.
define variable ptrlprop-rvd-own-nb as logical no-undo init false.
define variable ptrlprop-qr-scan-time as integer no-undo init 5000 .
define variable ptrlprop-block-nozzle as logical no-undo init false.
define variable ptrlprop-timeout-block-nozzle as integer no-undo init 5 .
define variable ptrlprop-autopump-skip-time as integer no-undo init 0 .
procedure get-ptrl-prop :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (get-ptrl-prop). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-ptrl-prop). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-ptrl-prop). endkey", vss-workfile )
  :
    define variable par-type          as character no-undo.
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    for each thbjattr_thbj-attr
    :
      delete thbjattr_thbj-attr .
    end.
    run adm/shattri.p
      ( input "get":U
      , input p-obj-type
      , input p-obj-code
      , input 'petrol':U
      , input  ""
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output par-type
      , input-output table thbjattr_thbj-attr
      ) no-error .
    for each thbjattr_thbj-attr
    on error undo, return error return-value
    :
      case thbjattr_thbj-attr.prop-code :
        when 'denstclc':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-denstclc = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'expptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-expptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'inpptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-inpptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'autopump':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-autopump = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'rvsnmter':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvsnmter = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'avtinvpm':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-avtinvpm = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'invclipt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-invclipt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'olddens':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-olddens = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'algrvspt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algrvspt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'temp-for-pomi':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-temp-for-pomi = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'algoincome':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algoincome = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'mand-choice-autocar':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-mand-choice-autocar = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-block-nozzle = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'timeout-block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-timeout-block-nozzle = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'Delta-mass-horiz':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-horiz = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'Delta-mass-vert':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-vert = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'calc-free-vol':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'calc-free-vol-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'trn-reas-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-trn-reas-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
              when 'rvd-own-nb':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvd-own-nb = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'qr-scan-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-qr-scan-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'autopump-skip-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-autopump-skip-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
      end case.
      delete thbjattr_thbj-attr .
    end.
  end.
  return .
end procedure.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table temp-tpsi-clients no-undo like ub.clients.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info35 as character no-undo format "x(65)":U initial "@(#)$Workfile$ $Revision$":U.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure valid-ren-art-tbl-list :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-std-list        as character no-undo .
    define variable v-ignore-list     as character no-undo .
    define variable v-special-list    as character no-undo .
    assign
      v-std-list     = "cli-gds,cli-gds-attr,cli-art,cli-art-attr,contract-specif,c-contract-specif,doc-line,c-doc-line,fbr-line,c-fbr-line,fbr-recipe,fbr-recipe-gds,fbr-pln-line,c-fbr-pln-line,gds-dtl,c-gds-dtl,gds-dtl-attr,c-gds-dtl-attr,gds-obj,inv-line,inv-line-attr,c-inv-line,ot-supp-line,ot-supp-line-attr,ot-line-attr,ord-line,c-ord-line,ord-line-rcv,ord-dtl,c-ord-dtl,ord-dtl-attr,ord-dtl-rcv,ord-dtl-cons,ord-gds-cons,prt-obj,prt-obj-attr,parts,c-parts,parts-supp,parts-supp-attr,price-list,c-price-list,price-doc-forming-gds,c-price-doc-forming-gds,price-doc-forming-gds-qnty,c-price-doc-forming-gds-qnty,price-doc-forming-gds-sum,c-price-doc-forming-gds-sum,price-doc-forming-gds-tnv,c-price-doc-forming-gds-tnv,recipe,recipe-gds,c-recipe,c-recipe-gds,c-recipe-hist,stk-supp-line,stk-supp-line-attr,stk-line-attr,tmp-sale-dtl,tmp-sale-dtl-attr,tmp-sale-gds,tmp-sale-gds-attr":U
      v-ignore-list  = "c-goods,c-order-line":U
      v-special-list = "goods,ot-line,stk-line,order-line":U
    .
def var vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-inform      as character no-undo .
    define variable bh_tbl-name   as handle    no-undo .
    define variable v-tbl-not-idx as character no-undo .
    define variable v-idx-avail   as logical   no-undo .
    define variable new-tbl-list  as character no-undo .
    define variable old-tbl-list  as character no-undo .
    define variable old-tbl-avail as logical   no-undo .
    define variable v-double-tbl  as character no-undo .
    define variable v-tbl-name    as character no-undo .
    define variable v-msg         as character no-undo .
    assign
      v-msg         = "":U
      v-tbl-not-idx = "":U
      new-tbl-list  = "":U
    .
    for each ub._Field no-lock
      where ub._Field._Field-Name = 'artic':U
    ,first ub._File of ub._Field
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      if  lookup( ub._File._File-Name, v-std-list     ) = 0
      and lookup( ub._File._File-Name, v-ignore-list  ) = 0
      and lookup( ub._File._File-Name, v-special-list ) = 0
      then do:
        assign
          new-tbl-list = new-tbl-list + chr(10) + ub._File._File-Name
        .
      end.
      if lookup( ub._File._File-Name, v-std-list ) <> 0
        or lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0
      then do:
        create buffer bh_tbl-name for table substitute( "ub.&1":U, ub._File._File-Name ) .
        assign
          v-idx-avail = false
          v-inform    = bh_tbl-name:index-information(1)
          v-ind       = 2
        .
        block_chk-idx:
        do while v-inform <> ?
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if v-inform <> ?
              and lookup( entry( 5, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
              and lookup( entry( 7, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
              and lookup( entry( 9, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
          then do:
            assign
              v-idx-avail = true
            .
            leave block_chk-idx.
          end.
          assign
            v-inform = bh_tbl-name:index-information( v-ind )
            v-ind    = v-ind + 1
          .
        end.
        if v-idx-avail = false then do:
          if lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0 then do:
            assign
              new-tbl-list = new-tbl-list + " (индекса нет)"
            .
          end.
          else do:
            assign
              v-tbl-not-idx = v-tbl-not-idx + chr(10) + ub._File._File-Name
            .
          end.
        end.
        delete object bh_tbl-name.
      end.
    end.
    assign
      old-tbl-list  = "":U
      v-double-tbl  = "":U
      v-num-entries = num-entries( v-std-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name    = entry( v-ind, v-std-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'artic':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-type"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-code"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > v-ind
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-ignore-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-ignore-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'artic':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-type"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-code"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > v-ind
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-special-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-special-list )
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if available ub._File then do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'artic':U
          no-error .
      end.
      if not available ub._File
        or ( available ub._File
             and not available ub._Field
           )
      then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > v-ind
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    if v-tbl-not-idx <> "" then do:
      assign
        v-msg = v-msg + substitute( "Таблицы не имеют индекса с полями &3 на первом месте и нет спецобработки: &2&1&1", chr(10), v-tbl-not-idx, 'artic, prod-type, prod-code':U )
      .
    end.
    if new-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "Нет обработки таблиц: &2&1&1", chr(10), new-tbl-list )
      .
    end.
    if v-double-tbl <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть задублированные таблицы: &2&1&1", chr(10), v-double-tbl )
      .
    end.
    if old-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть несуществующие таблицы или таблицы в которых отсутствуют переименовываемые поля: &2&1&1", chr(10), old-tbl-list )
      .
    end.
    if v-msg <> "":U then do:
      return error substitute( "Утилита переименования &3 не корректна.&1&1&2", chr(10), v-msg, 'artic, prod-type, prod-code':U ) .
    end.
  end.
end procedure.
procedure check-use-artic :
  define input  parameter p-tbl-name  as   character                      no-undo .
  define input  parameter p-artic     like ub.goods.artic     no-undo .
  define input  parameter p-prod-type like ub.goods.prod-type no-undo .
  define input  parameter p-prod-code like ub.goods.prod-code no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info35, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop",   vss-include-info35 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info35 )
  :
    define buffer buf_goods for ub.goods .
    if lookup( p-tbl-name, "c-goods,c-order-line":U ) = 0 then do:
      find first buf_goods no-lock
        where buf_goods.artic     = p-artic
          and buf_goods.prod-type = p-prod-type
          and buf_goods.prod-code = p-prod-code
        no-error .
      if not available buf_goods then do:
        return error substitute( "&1 (check-use-artic). Не найден товар с артикулом &2 и производителем &3 &4", vss-include-info35, p-artic, p-prod-type, p-prod-code ) .
      end.
      if buf_goods.stts = integer('51':U) then do:
        return error substitute( "&1 (check-use-artic). Нельзя использовать товар с артикулом &2 и производителем &3 &4&5"
                                + "Выполняется переименование артикула и(или) производителя"
                                ,vss-include-info35
                                ,p-artic
                                ,p-prod-type
                                ,p-prod-code
                                ,chr(10)
                              ) .
      end.
    end.
    return .
  end.
end procedure.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable lns-cnt  as integer no-undo.
define variable line-rec as recid   no-undo.
if valid-handle (g#lib-trn3)
and g#lib-trn3 <> this-procedure :handle
and g#lib-trn3 :get-signature('lib-trn3_add-scal':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с документами" skip
    g#lib-trn3 skip
    g#lib-trn3 :type skip
    g#lib-trn3 :file-name skip
    valid-handle( g#lib-trn3 ) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle( this-procedure ) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-trn3 = this-procedure :handle
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-trn3", g#lib-trn3).
  delete object gbl-hndllibObj.
end.
on delete of this-procedure do:
  assign
    g#lib-trn3 = ?
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-trn3", g#lib-trn3).
  delete object gbl-hndllibObj.
end.
define temp-table temp-add-scal no-undo
field artic as character
field prod-type as character
field prod-code as integer
field deadline as integer
field unit-base as character
field doc-code as character
field last-date as date
field b-code  as integer
field grp-code as integer
field gds-code as integer
index pi is unique primary
doc-code
artic
prod-type
prod-code
.
define temp-table ttDump no-undo
   field BegTime as datetime
   field EndTime as datetime
   index bt BegTime
   index et EndTime
   .
define stream out_s.
define temp-table tt-place-volume-loss no-undo
  field pl-code     like ub.place.pl-code
  field volume-loss as decimal
  index pi as primary unique
    pl-code
.
procedure lib-trn3_add-scal :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-obj-type   like ub.clients.obj-type no-undo .
  define input parameter p-obj-code   like ub.clients.obj-code no-undo .
  define input parameter d-c like ub.trn-doc.doc-code no-undo .
  define input parameter p-doc-type as character no-undo .
  define input parameter p-add-scal-handle as   handle           no-undo.
  define buffer as_doc-line   for ub.doc-line.
  define buffer as_price-list for ub.price-list.
  define buffer as_goods      for ub.goods.
  define buffer as_bar-code   for ub.bar-code.
  define buffer as_scales     for ub.scales.
  define buffer as_scales-gds for ub.scales-gds.
  define buffer as_scales-grp for ub.scales-grp.
  define buffer as_units      for ub.units.
  define buffer as_gds-prt    for ub.gds-prt.
  define buffer as_gds-obj    for ub.gds-obj.
  define variable ii as integer no-undo .
  define variable conf-attr as character no-undo .
  define variable conf-par as character no-undo .
  define variable par-type as character no-undo .
  define variable v-obj-db-num like ub.db.db-num no-undo .
  define variable sclin-ld as integer no-undo .
  define variable v-last-date as date no-undo .
  define variable v-b-code like ub.bar-code.b-code no-undo .
  define variable v-param-type as character no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date as date no-undo .
  define variable v-value-decimal as decimal no-undo .
  define variable v-value-integer as INTEGER no-undo .
  define variable v-value-logical AS LOGICAL no-undo .
  define variable v-tth as handle no-undo .
  define variable scallist as character no-undo .
  define buffer buf_trn-doc  for ub.trn-doc.
  define buffer buf_price-doc  for ub.price-doc.
  define buffer buf_parts for ub.parts.
  define buffer buf_temp-add-scal for temp-add-scal.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type39 as character no-undo .
define variable v-value-character39 as character no-undo .
define variable v-value-date39 as date no-undo .
define variable v-value-decimal39 as decimal no-undo .
define variable v-value-logical39 AS LOGICAL no-undo .
define variable v-tth39 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'scale-inf':U
    ,input  'sclin-ld':U
    ,output v-value-character39
    ,output v-value-date39
    ,output v-value-decimal39
    ,output sclin-ld
    ,output v-value-logical39
    ,output v-param-type39
    ,INPUT-OUTPUT table-handle v-tth39
    )  .
delete object v-tth39.
  run adm/shattri.p (
      input "get":U
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  'scale-inf':U
      ,input  'scallist':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  scallist = v-value-character.
  delete object v-tth.
  for each buf_temp-add-scal:
    delete buf_temp-add-scal.
  end.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  )  .
  m-d:
  do transaction on error undo m-d, return error "Ошибка при обновлении информации на весах.":
    if p-doc-type <> 'переоценка':U then do:
      run waitfram-show in p-add-scal-handle  (  "Добавление товаров на весы по привязанным группам товаров." ) .
      find first buf_trn-doc no-lock where
                buf_trn-doc.doc-code = d-c no-error .
      if error-status:error then return error substitute("Не найден документ &1", d-c).
      _doc-line:
      FOR EACH as_doc-line WHERE
               as_doc-line.doc-code = d-c AND
               as_doc-line.fact-qnty > 0    NO-LOCK,
          FIRST as_goods WHERE
                as_goods.artic = as_doc-line.artic AND
                as_goods.prod-type = as_doc-line.prod-type AND
                as_goods.prod-code = as_doc-line.prod-code      NO-LOCK,
         FIRST as_units no-lock where as_units.unit-name = as_goods.unit-base
      on error undo m-d, return error return-value
         :
          if ii modulo 10 = 0 then do:
            run waitfram-show in p-add-scal-handle  ( input "Обработано товаров : " + string( ii )).
          end.
         if lookup( 'у':U, as_goods.gds-type ) > 0 then  NEXT _doc-line.
         if lookup( 'вес':U, as_units.type ) = 0 then  NEXT _doc-line.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  as_goods.gds-code
  ,input  ?
  ,output v-b-code
  )  .
         create buf_temp-add-scal.
         buffer-copy as_doc-line
         to buf_temp-add-scal
         assign
         buf_temp-add-scal.gds-code = as_goods.gds-code
         buf_temp-add-scal.b-code = v-b-code
         buf_temp-add-scal.unit-base = as_goods.unit-base
         buf_temp-add-scal.grp-code = as_goods.grp-code
         buf_temp-add-scal.deadline = as_goods.deadline
         .
       end.
     end.
     if p-doc-type = 'переоценка':U then do:
       _price-list:
       FOR EACH as_price-list no-lock WHERE
               as_price-list.doc-num = d-c
            and as_price-list.main-price = yes,
         FIRST as_goods no-lock WHERE
                as_goods.artic     = as_price-list.artic
            AND as_goods.prod-type = as_price-list.prod-type
            AND as_goods.prod-code = as_price-list.prod-code,
         FIRST as_gds-obj no-lock where
                as_gds-obj.gds-code = as_goods.gds-code
            AND as_gds-obj.obj-type = as_price-list.obj-type
            AND as_gds-obj.obj-code = as_price-list.obj-code,
         FIRST as_units no-lock where as_units.unit-name = as_goods.unit-base
        on error undo m-d, return error return-value  :
        if ii modulo 10 = 0 then do:
          run waitfram-show in p-add-scal-handle  ( input "Обработано товаров : " + string( ii )).
        end.
         if lookup( 'вес':U, as_units.type ) = 0 then  NEXT _price-list.
         if lookup( 'у':U, as_goods.gds-type ) > 0 then  NEXT _price-list.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  as_goods.gds-code
  ,input  ?
  ,output v-b-code
  )  .
         create buf_temp-add-scal.
         buffer-copy as_price-list
         to buf_temp-add-scal
         assign
         buf_temp-add-scal.gds-code = as_goods.gds-code
         buf_temp-add-scal.doc-code = as_gds-obj.in-code
         buf_temp-add-scal.b-code = v-b-code
         buf_temp-add-scal.grp-code = as_goods.grp-code
         buf_temp-add-scal.deadline = as_goods.deadline
         buf_temp-add-scal.unit-base = as_goods.unit-base
         .
        end.
      end.
      if p-doc-type <> 'переоценка':U then do:
        _scales:
        for each buf_temp-add-scal,
            each as_scales-grp exclusive-lock where
                as_scales-grp.node-code = buf_temp-add-scal.grp-code
            and  as_scales-grp.db-num = v-obj-db-num  ,
            first as_scales exclusive-lock where
                as_scales.db-num = v-obj-db-num
            and as_scales.scales-num = as_scales-grp.scales-num
            and as_scales.master = 0
        on error undo m-d, return error return-value :
          if scallist <> "":U and lookup(string(as_scales.scales-num), scallist) = 0 then NEXT _scales.
          if buf_temp-add-scal.unit-base <> as_scales.unit-base then NEXT _scales.
          find first as_scales-gds where
                    as_scales-gds.scales-num = as_scales.scales-num
                and as_scales-gds.db-num = v-obj-db-num
                and as_scales-gds.b-code     = buf_temp-add-scal.b-code  no-lock no-error.
          if not available as_scales-gds then do:
            find first as_bar-code no-lock where
                      as_bar-code.b-code = buf_temp-add-scal.b-code .
                          run ref/ves-pbc.p (
                                          input parparentproc
                                        , input 'ДОБАВЛЕНИЕ':U
                                        , input p-obj-type
                                        , input p-obj-code
                                        , input (if sclin-ld > 0 then ? else buf_temp-add-scal.deadline)
                                        , input (if sclin-ld > 0 then (buf_temp-add-scal.last-date - 01/01/2000 + 1) * 24 else ?)
                                        , input (if sclin-ld > 0 then integer('1':U) else integer('0':U))
                                        , input 0
                                        , buffer as_bar-code
                                        , buffer as_scales) no-error.
            if error-status:error then do:
              run waitfram-hide in p-add-scal-handle  .
              undo m-d, return error .
            end.
          end.
        end.
        if sclin-ld = 0 then return.
      end.
      if sclin-ld > 0 then do:
        _parts:
        for each buf_temp-add-scal,
            each buf_parts no-lock where
                buf_parts.obj-type  = p-obj-type
            and buf_parts.obj-code  = p-obj-code
            and buf_parts.artic     = buf_temp-add-scal.artic
            and buf_parts.prod-type = buf_temp-add-scal.prod-type
            and buf_parts.prod-code = buf_temp-add-scal.prod-code
            and buf_parts.out-code  = buf_temp-add-scal.doc-code
        on error undo m-d, return error return-value :
          if buf_parts.last-date = ? then next _parts.
          assign
          buf_temp-add-scal.last-date = (if buf_temp-add-scal.last-date = ?
                                          or (buf_temp-add-scal.last-date <> ?
                                              and sclin-ld = 1
                                              and buf_temp-add-scal.last-date > buf_parts.last-date)
                                          or (buf_temp-add-scal.last-date <> ?
                                              and sclin-ld = 2
                                              and buf_temp-add-scal.last-date < buf_parts.last-date)
                                              then buf_parts.last-date
                                              else buf_temp-add-scal.last-date)
          .
        end.
      end.
      _scales:
      for each buf_temp-add-scal:
        for each as_scales-gds no-lock WHERE
           as_scales-gds.b-code = buf_temp-add-scal.b-code
        and as_scales-gds.db-num = v-obj-db-num
        and as_scales-gds.obj-type = p-obj-type
        and as_scales-gds.obj-code = p-obj-code  ,
        first as_scales Exclusive-lock where
             as_scales.scales-num = as_scales-gds.scales-num
         and as_scales.db-num = as_scales-gds.db-num,
        first as_bar-code no-lock where
                as_bar-code.b-code = as_scales-gds.b-code
       on error undo m-d, return error return-value :
          run ref/ves-pbc.p (
                          input parparentproc
                        , input 'ИЗМЕНЕНИЕ':U
                        , input p-obj-type
                        , input p-obj-code
                        , input (if sclin-ld > 0 then ? else as_scales-gds.deadline)
                        , input (if sclin-ld > 0 then (buf_temp-add-scal.last-date - 01/01/2000 + 1) * 24 else ?)
                        , input (if sclin-ld > 0 then integer('1':U) else integer('0':U))
                        , input 0
                        , buffer as_bar-code
                        , buffer as_scales) no-error.
          if error-status:error then do:
            run waitfram-hide in p-add-scal-handle  .
            undo m-d, return error .
          end.
        end.
      end.
  end.
  run waitfram-hide in p-add-scal-handle  .
end procedure .
procedure lib-trn3_clr-line :
  define input parameter parmain-menu-handle as   handle                no-undo.
  define input parameter pardoc-code         like ub.doc-line.doc-code  no-undo.
  define input parameter parartic            like ub.doc-line.artic     no-undo.
  define input parameter parprod-type        like ub.doc-line.prod-type no-undo.
  define input parameter parprod-code        like ub.doc-line.prod-code no-undo.
  define input parameter fnc                 as   character             no-undo.
  define variable chg-qnty        as decimal   no-undo.
  define variable pl-chg-qnty     as decimal   no-undo.
  define variable mem-pl-chg-qnty as decimal   no-undo.
  define variable varterminal-prt as logical   no-undo.
  define variable r-rec-inv-line  as recid     no-undo.
  define variable is-petrol       as logical   no-undo.
  define variable is-pieces       as logical   no-undo.
  define variable v-ptrl          as logical   no-undo.
  define variable v-b-code        as integer   no-undo .
  define buffer buf_goods   for ub.goods .
  define buffer bf_doc-line for ub.doc-line.
  define buffer bf_gds-dtl  for ub.gds-dtl.
  define buffer bf_prt-obj  for ub.prt-obj.
  define buffer bf_inv-line for ub.inv-line.
  define buffer bf_pl-gds   for ub.pl-gds.
  define buffer buf_doc-pl  for ub.doc-pl .
  define buffer buf_chk-gds for ub.chk-gds.
  tr:
  do transaction
  on error undo tr, return error return-value
  :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input parartic
  ,  input parprod-type
  ,  input parprod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
    assign
      v-ptrl = ( if not error-status :error and is-petrol = yes and is-pieces = no then yes else no )
    .
    find first bf_doc-line exclusive-lock
      where bf_doc-line.doc-code  = pardoc-code
        and bf_doc-line.artic     = parartic
        and bf_doc-line.prod-type = parprod-type
        and bf_doc-line.prod-code = parprod-code
      .
    find first buf_goods exclusive-lock
      where buf_goods.artic     = bf_doc-line.artic
        and buf_goods.prod-type = bf_doc-line.prod-type
        and buf_goods.prod-code = bf_doc-line.prod-code
      .
    if v-ptrl = yes then do:
      find first bf_inv-line no-lock
        where bf_inv-line.doc-code  = bf_doc-line.doc-code
          and bf_inv-line.artic     = bf_doc-line.artic
          and bf_inv-line.prod-type = bf_doc-line.prod-type
          and bf_inv-line.prod-code = bf_doc-line.prod-code
        no-error.
      if available bf_inv-line then do:
        assign
          r-rec-inv-line = recid( bf_inv-line )
        .
        find first bf_inv-line exclusive-lock where recid( bf_inv-line ) = r-rec-inv-line.
      end.
      else do:
        undo tr, return error substitute( 'Не найдена строка итогов в кг по топливу. Документ "&1", топливо &2 (&3 &4)',
                                          pardoc-code,
                                          parartic,
                                          parprod-type,
                                          parprod-code
                                        ).
      end.
    end.
    run trg/rsrv-del.p
      ( input bf_doc-line.doc-code
      , input bf_doc-line.artic
      , input bf_doc-line.prod-type
      , input bf_doc-line.prod-code
      ) no-error.
    if error-status :error then do:
      undo tr, return error return-value.
    end.
    if fnc = "исх":u then do:
      for each bf_gds-dtl
        where bf_gds-dtl.doc-code  = bf_doc-line.doc-code
          and bf_gds-dtl.artic     = bf_doc-line.artic
          and bf_gds-dtl.prod-type = bf_doc-line.prod-type
          and bf_gds-dtl.prod-code = bf_doc-line.prod-code
      on error undo tr, return error return-value
      :
        delete bf_gds-dtl.
      end.
      if v-ptrl = yes
        and available bf_inv-line
      then do:
        assign
          bf_inv-line.after-cli-qnty = bf_inv-line.before-cli-qnty
          bf_inv-line.wast-cli-qnty  = bf_inv-line.before-cli-qnty
          bf_doc-line.cli-qnty       = 0
        .
      end.
    end.
    if fnc = "ноль":u then do:
      for each bf_prt-obj where
               bf_prt-obj.obj-type  = bf_doc-line.obj-type  and
               bf_prt-obj.obj-code  = bf_doc-line.obj-code  and
               bf_prt-obj.prod-type = bf_doc-line.prod-type and
               bf_prt-obj.prod-code = bf_doc-line.prod-code and
               bf_prt-obj.artic     = bf_doc-line.artic
      on error undo tr, return error return-value
      :
        if bf_prt-obj.fact-qnty = 0
          and v-ptrl <> yes
        then do:
          next.
        end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  bf_prt-obj.prt-code
  ,input  'terminal-prt=request':u
  ,output varterminal-prt
  )  .
        if varterminal-prt <> yes then do:
          next.
        end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input bf_doc-line.obj-code
   ,input bf_doc-line.obj-type
   ,input bf_doc-line.doc-code
   ,input bf_doc-line.artic
   ,input bf_doc-line.prod-code
   ,input bf_doc-line.prod-type
   ,input bf_prt-obj.prt-code
   ,input yes
  ) no-error .
        if error-status :error then do:
            undo tr, return error return-value.
        end.
        find first bf_gds-dtl where
                   bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                   bf_gds-dtl.artic     = bf_doc-line.artic     and
                   bf_gds-dtl.prod-code = bf_doc-line.prod-code and
                   bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                   bf_gds-dtl.prt-code  = bf_prt-obj.prt-code.
        assign
          chg-qnty = - bf_prt-obj.fact-qnty
        .
        if v-ptrl = yes then do:
          assign
            pl-chg-qnty = 0
          .
          for each bf_pl-gds
            where bf_pl-gds.gds-code = buf_goods.gds-code
              and bf_pl-gds.obj-type = bf_gds-dtl.obj-type
              and bf_pl-gds.obj-code = bf_gds-dtl.obj-code
            use-index gds-code
          on error undo tr, return error return-value
          :
            assign
              pl-chg-qnty = pl-chg-qnty + bf_pl-gds.fact-qnty
            .
          end.
          if pl-chg-qnty <> bf_prt-obj.fact-qnty then do:
            undo tr, return error substitute( 'Документ "&1", топливо &2 (&3 &4): факт.кол-во по резервуарам (&5) НЕ СОВПАДАЕТ c факт.кол-вом на объекте &6 &7 (&8)',
                                              pardoc-code,
                                              parartic,
                                              parprod-type,
                                              parprod-code,
                                              pl-chg-qnty,
                                              bf_gds-dtl.obj-type,
                                              bf_gds-dtl.obj-code,
                                              bf_gds-dtl.fact-qnty
                                            ).
          end.
          for each bf_pl-gds exclusive-lock
            where bf_pl-gds.gds-code = buf_goods.gds-code
              and bf_pl-gds.obj-type = bf_gds-dtl.obj-type
              and bf_pl-gds.obj-code = bf_gds-dtl.obj-code
            use-index gds-code
          on error undo tr, return error return-value
          :
            assign
              pl-chg-qnty     = - bf_pl-gds.fact-qnty
              mem-pl-chg-qnty = pl-chg-qnty
            .
            run trg/rsrv-dtl.p
              ( input        parmain-menu-handle
               ,input        'reserv':U + "," + 'plcode':U + "=" + string( bf_pl-gds.pl-code )
               ,buffer       bf_gds-dtl
               ,input-output pl-chg-qnty
               ,input-output bf_doc-line.price-base
               ,input-output bf_doc-line.price-rubl
               ,input        -1
               ,input ""
              ).
            if mem-pl-chg-qnty <> pl-chg-qnty then do:
              undo tr, return error substitute ("Не удалось зарезервировать товар (&1) по месту хранения &2", buf_goods.gds-code, bf_pl-gds.pl-code) .
            end.
            find first buf_doc-pl exclusive-lock
              where buf_doc-pl.obj-type = bf_pl-gds.obj-type
                and buf_doc-pl.obj-code = bf_pl-gds.obj-code
                and buf_doc-pl.pl-code  = bf_pl-gds.pl-code
                and buf_doc-pl.out-code = bf_doc-line.doc-code
                and buf_doc-pl.gds-code = buf_goods.gds-code
              no-error .
            if not available buf_doc-pl then do:
              undo tr, return error substitute ("В документе отсутствует запись о месте хранения &2 товара &1", buf_goods.gds-code, bf_pl-gds.pl-code) .
            end.
            assign
              buf_doc-pl.rest-af-qnty     = 0.0
              buf_doc-pl.cli-rest-af-qnty = 0.0
              buf_doc-pl.fact-qnty        = (- buf_doc-pl.rest-bf-qnty)
              buf_doc-pl.cli-fact-qnty    = (- buf_doc-pl.cli-rest-bf-qnty)
              buf_doc-pl.doc-qnty         = buf_doc-pl.fact-qnty
              buf_doc-pl.cli-doc-qnty     = buf_doc-pl.cli-fact-qnty
              buf_doc-pl.cli-qnty         = buf_doc-pl.cli-doc-qnty
            .
          end.
        end.
        else do:
          run trg/rsrv-dtl.p
            ( input        parmain-menu-handle
             ,input        'reserv':U
             ,buffer       bf_gds-dtl
             ,input-output chg-qnty
             ,input-output bf_doc-line.price-base
             ,input-output bf_doc-line.price-rubl
             ,input        -1
             ,input ""
           ).
        end.
        assign
          bf_gds-dtl.doc-qnty   = chg-qnty
          bf_gds-dtl.fact-qnty  = 0
          bf_doc-line.fact-qnty = bf_doc-line.fact-qnty + chg-qnty
          bf_doc-line.doc-qnty  = 0
          bf_doc-line.prt-ok    = yes
        .
        if v-ptrl = yes
          and available bf_inv-line
        then do:
          assign
            bf_doc-line.cli-qnty       = - bf_inv-line.before-cli-qnty
            bf_inv-line.wast-cli-qnty  = 0
            bf_inv-line.after-cli-qnty = bf_inv-line.wast-cli-qnty
          .
        end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  bf_gds-dtl.prt-code
  ,output v-b-code
  ) no-error .
        if error-status :error then do:
          undo tr, return error return-value.
        end.
        for each buf_chk-gds where
                buf_chk-gds.out-code = bf_gds-dtl.doc-code
           and  buf_chk-gds.b-code   = v-b-code
        on error undo tr, return error return-value :
          assign
          buf_chk-gds.is-error = yes
          .
        end.
      end.
      if error-status :error then do:
        undo tr, return error return-value.
      end.
    end.
    if ( fnc = "исх":u
         or fnc = "ноль":u
       )
      and v-ptrl = yes
      and available bf_inv-line
    then do:
      if bf_doc-line.doc-qnty <> 0.0
        and bf_inv-line.wast-cli-qnty <> 0.0
      then do:
        assign
          bf_doc-line.doc-density = bf_inv-line.wast-cli-qnty / bf_doc-line.doc-qnty
        .
      end.
      else do:
        if valid-density( bf_doc-line.doc-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> true then do:
          assign
            bf_doc-line.doc-density = 1.0 / buf_goods.cli-base-rate
          .
          if valid-density( bf_doc-line.doc-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> true then do:
            undo tr, return error substitute( 'В карточке товара указан некорректный коэффициент единиц измерения поставщика.&1'
                                              + 'Невозможно установить плотность товара.&1'
                                              + 'Документ: &2&1'
                                              + 'Код товара: &3&1'
                                              + 'Плотность: &4&1'
                                              ,chr(10)
                                              ,bf_doc-line.doc-code
                                              ,buf_goods.gds-code
                                              ,bf_doc-line.doc-density
                                            ).
          end.
        end .
      end.
      assign
        bf_doc-line.fact-density = bf_doc-line.doc-density
      .
    end.
  end.
end procedure.
procedure lib-trn3_adinvdoc:
define input  parameter parobj-type like ub.clients.obj-type no-undo.
define input  parameter parobj-code like ub.clients.obj-code no-undo.
define input  parameter paruserid   as   character           no-undo.
define output parameter parrecid    as   recid               no-undo.
define variable vardoc-code   like ub.trn-doc.doc-code       no-undo.
define variable varinv-pay    like ub.shop.inv-pay           no-undo.
define variable varhost-code  like ub.sysconf.host-code      no-undo.
define variable v-today       as date                        no-undo.
define buffer bf_shop       for ub.shop.
define buffer bf_store      for ub.store.
define buffer bf_pay-type   for ub.pay-type.
define buffer bf_trn-doc    for ub.trn-doc.
define buffer bf_curr-accnt for ub.curr-accnt.
define buffer bf_sysconf    for ub.sysconf.
define buffer bf_sys-ctrl   for ub.sys-ctrl.
define buffer bf_clients    for ub.clients.
do on error undo, return error return-value :
find first bf_sys-ctrl no-lock.
case parobj-type:
when 'маг':U then do:
  find first bf_shop where bf_shop.obj-code = parobj-code no-lock.
  assign
    varinv-pay   = bf_shop.inv-pay
    varhost-code = bf_shop.host-code.
end.
when 'скл':U then do:
  find first bf_store where bf_store.obj-code = parobj-code no-lock.
  assign
    varinv-pay   = bf_store.inv-pay
    varhost-code = bf_store.host-code.
end.
otherwise do:
  return error substitute ("Неверный тип объекта учета &1.", parobj-type).
end.
end case.
find first bf_sysconf where bf_sysconf.host-code = varhost-code no-lock.
find first bf_clients where bf_clients.obj-type = 'орг':U               and
                            bf_clients.obj-code = bf_sysconf.host-code no-lock.
if not can-find (bf_pay-type where bf_pay-type.obj-code = varinv-pay no-lock) then do:
  return error "Не задан код оплаты для инвентаризации в настройках по текущему объекту.".
end.
run doc-code
(input  "main",
 input  parobj-type,
 input  parobj-code,
 input  ?,
 output vardoc-code ) no-error.
if error-status:error then do:
  message "Ошибка при генерации номера документа." skip
          return-value
  view-as alert-box.
  return error.
end.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-today
  )  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input 1
,input 1
,input varhost-code
,input 'орг':U
,input bf_clients.obj-name
,input bf_sys-ctrl.db-num
,input paruserid
,input ' '
,input vardoc-code
,input v-today
,input 'инв':U
,input no
,input varhost-code
,input no
,input parobj-code
,input parobj-type
,input no
,input varinv-pay
,input '@  '
,input no
,input ?
,input 'накл':U
,input ?
,input 'vt':U
,input ?
) no-error
.
if error-status:error then do:
  return error return-value.
end.
find bf_trn-doc where bf_trn-doc.doc-code = vardoc-code.
assign
  bf_trn-doc.tot-calc  = ?.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-today
  )  .
find last bf_curr-accnt where bf_curr-accnt.curr-code = bf_sysconf.base-code
                          and bf_curr-accnt.exch-date <= v-today use-index pi no-lock no-error.
if not available bf_curr-accnt then do:
   message "На дату" v-today "неизвестен курс базовой валюты." SKIP
           "Сумма по документу в валюте будет рассчитана при закрытии на факт".
end.
else do:
  assign
    bf_trn-doc.base-rate  = bf_curr-accnt.exch-rate
    bf_trn-doc.base-scale = bf_curr-accnt.exch-scale.
END.
ASSIGN
    bf_trn-doc.exch-code  = 0
    bf_trn-doc.exch-rate  = 1
    bf_trn-doc.exch-scale = 1.
assign
  parrecid = recid(bf_trn-doc).
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_crinvdoc in g#lib-trn2
(input bf_trn-doc.doc-code
) no-error
.
if error-status:error then return error return-value.
end.
end procedure.
procedure lib-trn3_adinvlin:
define  input parameter parmain-menu-handle as   handle                no-undo.
define  input parameter pardoc-code         like ub.doc-line.doc-code  no-undo.
define  input parameter parartic            like ub.doc-line.artic     no-undo.
define  input parameter parprod-type        like ub.doc-line.prod-type no-undo.
define  input parameter parprod-code        like ub.doc-line.prod-code no-undo.
define output parameter parrecid            as   recid                 no-undo.
  do
  on error undo, return error return-value
  :
    define variable v-vat-pc        like ub.doc-line.vat-pc   no-undo.
    define variable v-slt-pc        like ub.doc-line.slt-pc   no-undo.
    define variable v-have-slt-pc   as   logical              no-undo.
    define variable v-host-code     like ub.sysconf.host-code no-undo.
    define buffer bf_goods    for ub.goods.
    define buffer bf_trn-doc  for ub.trn-doc.
    define buffer bf_doc-line for ub.doc-line.
    define buffer bf_sysconf  for ub.sysconf.
    find first bf_trn-doc no-lock
      where bf_trn-doc.doc-code = pardoc-code
      .
    find first bf_sysconf no-lock
      where bf_sysconf.host-code = bf_trn-doc.host-code
      .
    find first bf_goods no-lock
      where bf_goods.artic     = parartic
        and bf_goods.prod-type = parprod-type
        and bf_goods.prod-code = parprod-code
      .
    if bf_goods.gds-type = 'у':U then do:
      return error.
    end.
    find bf_doc-line
      where bf_doc-line.artic     = parartic
        and bf_doc-line.prod-type = parprod-type
        and bf_doc-line.prod-code = parprod-code
        and bf_doc-line.doc-code  = pardoc-code
      no-error.
    if not available bf_doc-line then do:
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output v-vat-pc
  ) no-error .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_st-sltpc in g#lib-trn
(
 input  recid(bf_goods)
,input  recid(bf_trn-doc)
,input  bf_sysconf.cash-pay
,output v-slt-pc
)
.
      if bf_sysconf.cons-vat-pc = ? then do:
        return error "У Вас не установлен НДС для консигнационного товара по фирме.".
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdoclin in g#lib-trn
(input bf_trn-doc.doc-code
,input bf_goods.artic
,input bf_goods.prod-type
,input bf_goods.prod-code
,input bf_trn-doc.obj-type
,input bf_trn-doc.obj-code
,input bf_trn-doc.status_
,input bf_trn-doc.ext-doc-type
,input bf_goods.prt-root
,input v-vat-pc
,input v-slt-pc
,input bf_sysconf.cons-vat-pc
)
.
      find first bf_doc-line exclusive-lock
        where bf_doc-line.doc-code  = bf_trn-doc.doc-code
          and bf_doc-line.artic     = bf_goods.artic
          and bf_doc-line.prod-type = bf_goods.prod-type
          and bf_doc-line.prod-code = bf_goods.prod-code
        .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_clr-line in g#lib-trn3
(input parmain-menu-handle
,input bf_doc-line.doc-code
,input bf_doc-line.artic
,input bf_doc-line.prod-type
,input bf_doc-line.prod-code
,input 'исх':u
) .
    end.
  end.
  assign
    parrecid = recid(bf_doc-line)
  .
end procedure.
procedure lib-trn3_igdstpsi:
define input parameter pargds-code like ub.goods.gds-code   no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define buffer bf_goods   for ub.goods.
define buffer bf_clients for ub.clients.
define variable varproprietor-host-code like ub.clients.host-code no-undo.
define variable varproprietor-obj-type  like ub.clients.obj-type  no-undo.
define variable varproprietor-obj-code  like ub.clients.obj-code  no-undo.
define variable varals-gds              as   character            no-undo.
define variable vartypeals-gds          as   character            no-undo.
do on error undo, return error return-value :
  find first bf_clients where bf_clients.obj-type = parobj-type and
                              bf_clients.obj-code = parobj-code no-lock.
  run clntattr-value in this-procedure
   (input  'орг':U,
    input  bf_clients.host-code,
    input  'als-gds':U,
    output varals-gds,
    output vartypeals-gds
   ).
  if varals-gds = "yes":u then do:
    find first bf_goods where bf_goods.gds-code = pargds-code no-lock.
    run tpsi-gds-fill-tpsi-obj-table in this-procedure (input bf_clients.db-num).
    run tpsi-preselect-gds-proprietor in this-procedure (
      input bf_goods.gds-code,
      input bf_clients.db-num,
      output varproprietor-host-code,
      output varproprietor-obj-type,
      output varproprietor-obj-code
    ).
    if varproprietor-host-code <> ?
       and varproprietor-host-code <> bf_clients.host-code
    then do:
      return error substitute ("Товар &1 &2 &3 &4 на базе данных &5 принадлежит объекту &6 &7 фирмы &8. Наш объект принадлежит фирме &9. Приход товара недопустим.",
                               bf_goods.artic,
                               bf_goods.prod-type,
                               bf_goods.prod-code,
                               bf_goods.gds-name,
                               bf_clients.db-num,
                               varproprietor-obj-type,
                               varproprietor-obj-code,
                               varproprietor-host-code,
                               bf_clients.host-code).
    end.
  end.
end.
end procedure.
procedure lib-trn3_trdcattr-news:
  do
  on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'hold-part-code':U then do:     assign     p-news = true.   end.
            when 'dov':U then do:     assign     p-news = true.   end.
            when 'dids':U then do:     assign     p-news = true.   end.
            when 'nids':U then do:     assign     p-news = true.   end.
            when 'ddog':U then do:     assign     p-news = true.   end.
            when 'ndog':U then do:     assign     p-news = true.   end.
            when 'dsf':U then do:     assign     p-news = true.   end.
            when 'nsf':U then do:     assign     p-news = true.   end.
            when 'addsum':U then do:     assign     p-news = true.   end.
            when 'clcasol':U then do:     assign     p-news = true.   end.
            when 'clcaswt':U then do:     assign     p-news = true.   end.
            when 'scanfile':U then do:     assign     p-news = true.   end.
            when 'indoclnsum':U then do:     assign     p-news = true.   end.
            when 'purchlimit':U then do:     assign     p-news = true.   end.
            when 'purchcodelist':U then do:     assign     p-news = true.   end.
            when 'expense_own':U then do:     assign     p-news = true.   end.
            when 'envd':U then do:     assign     p-news = true.   end.
            when 'acc-ship':U then do:     assign     p-news = true.   end.
            when 'othermoves':U then do:     assign     p-news = true.   end.
      otherwise do:
        undo, return error "неизвестный атрибут документа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure lib-trn3_trdcattr-tooltip :
  do
  on error undo, return error return-value :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'hold-part-code':U then do:     assign     p-tooltip = "Номер партии для документа межфирменного перемещения"     p-label = "Номер партии для документа межфирменного перемещения" .   end.
            when 'dov':U then do:     assign     p-tooltip = "Доверенность"     p-label = "Доверенность" .   end.
            when 'dids':U then do:     assign     p-tooltip = "Дата приходной накладной поставщика"     p-label = "Дата приходной накладной поставщика" .   end.
            when 'nids':U then do:     assign     p-tooltip = "Номер приходной накладной поставщика"     p-label = "Номер приходной накладной поставщика" .   end.
            when 'ddog':U then do:     assign     p-tooltip = "Договор: Дата"     p-label = "Договор: Дата" .   end.
            when 'ndog':U then do:     assign     p-tooltip = "Договор: Номер"     p-label = "Договор: Номер" .   end.
            when 'dsf':U then do:     assign     p-tooltip = "Счет-фактура поставщика: Дата"     p-label = "Счет-фактура поставщика: Дата" .   end.
            when 'nsf':U then do:     assign     p-tooltip = "Счет-фактура поставщика: Номер"     p-label = "Счет-фактура поставщика: Номер" .   end.
            when 'addsum':U then do:     assign     p-tooltip = "Дополнительные суммы посчитанные по документу"     p-label = "Дополнительные суммы посчитанные по документу" .   end.
            when 'clcasol':U then do:     assign     p-tooltip = "On-line расчет дополнительных сумм основных и после документа"     p-label = "On-line расчет дополнительных сумм основных и после документа" .   end.
            when 'clcaswt':U then do:     assign     p-tooltip = "On-line расчет естественной убыли"     p-label = "On-line расчет естественной убыли" .   end.
            when 'scanfile':U then do:     assign     p-tooltip = "Загруженные в документ сканерные файлы"     p-label = "Загруженные в документ сканерные файлы" .   end.
            when 'indoclnsum':U then do:     assign     p-tooltip = "Заводить внешнюю приходную накладную через суммы"     p-label = "Заводить внешнюю приходную накладную через суммы" .   end.
            when 'purchlimit':U then do:     assign     p-tooltip = "Есть в документе ограничение по типам кодов приобретения для резервирования"     p-label = "Есть в документе ограничение по типам кодов приобретения для резервирования" .   end.
            when 'purchcodelist':U then do:     assign     p-tooltip = "Список кодов типов приобретения"     p-label = "Список кодов типов приобретения" .   end.
            when 'expense_own':U then do:     assign     p-tooltip = "Расходы не включаемые в учетную цену"     p-label = "Расходы не включаемые в учетную цену" .   end.
            when 'envd':U then do:     assign     p-tooltip = "Единый налог на вмененный доход"     p-label = "Единый налог на вмененный доход" .   end.
             when 'othermoves':U then do:     assign     p-tooltip = "Признак топливной накладной с прочими перемещениями (для ИС Президентский Мониторинг)"     p-label = "Прочие перемещения НП" .   end.
            when 'acc-ship':U then do:     assign     p-tooltip = "Допустимый % погрешности поставщика"     p-label = "Допустимый % погрешности поставщика" .   end.
      otherwise do:
        undo, return error "неизвестный атрибут документа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure lib-trn3_resv-inqv :
  do
  on error undo, return error return-value
  :
define variable v-nabor as logical   no-undo .
define input  parameter  p-doc-code as character no-undo .
define output parameter  v-exit  as logical   no-undo initial true .
define buffer bf_goods    for ub.goods.
define buffer bf_doc-line for ub.doc-line.
for each bf_doc-line no-lock where bf_doc-line.doc-code = p-doc-code :
   find first bf_goods where bf_goods.artic     = bf_doc-line.artic
                         and bf_goods.prod-type = bf_doc-line.prod-type
                         and bf_goods.prod-code = bf_doc-line.prod-code no-lock.
   run ver-gds-grp-nabor (input bf_goods.gds-code , output v-nabor ) .
   if v-nabor = true then do:
   v-exit = false .
   leave.
   end.
end.
  end.
end procedure.
procedure lib-trn3_grp-nabor :
  do
  on error undo, return error return-value
  :
  define input  parameter  p-gds-code as integer   no-undo .
  define output parameter  p-nabor as logical   no-undo .
    run ver-gds-grp-nabor (input p-gds-code , output p-nabor )  .
  end.
end procedure.
procedure lib-trn3_delnabor :
  do
  on error undo, return error return-value
  :
   define input parameter parmain-menu-handle as   handle                no-undo.
   define input parameter p-doc-code as character no-undo .
   define buffer buf_trn-doc  for ub.trn-doc.
   define buffer buf_doc-line for ub.doc-line.
   define buffer buf_gds-dtl  for ub.gds-dtl.
   define buffer buf_goods    for ub.goods.
   define buffer buf_doc-line-attr for ub.doc-line-attr.
   define buffer new_doc-line-attr for ub.doc-line-attr.
   define variable unrv-qnty as decimal   no-undo .
   define variable v-nabor as logical   no-undo .
   find first buf_trn-doc no-lock where  buf_trn-doc.doc-code = p-doc-code no-error .
   if  buf_trn-doc.is-flora = false then return .
    for each buf_doc-line exclusive-lock where
            buf_doc-line.doc-code = p-doc-code :
    find first  buf_goods no-lock where
                  buf_goods.artic     = buf_doc-line.artic AND
                  buf_goods.prod-type = buf_doc-line.prod-type AND
                  buf_goods.prod-code = buf_doc-line.prod-code no-error .
                  if error-status :error
                  then do:
                    undo, return error.
                  end.
      run ver-gds-grp-nabor (input buf_goods.gds-code , output v-nabor )  .
        if v-nabor = true then do:
            find first buf_gds-dtl no-lock    where
                  buf_gds-dtl.doc-code  = buf_doc-line.doc-code and
                  buf_gds-dtl.artic     = buf_doc-line.artic and
                  buf_gds-dtl.prod-type = buf_doc-line.prod-type and
                  buf_gds-dtl.prod-code = buf_doc-line.prod-code  .
            unrv-qnty = - buf_gds-dtl.fact-qnty .
            run trg/rsrv-dtl.p
              (input        parmain-menu-handle
              ,input        'reserv':U
                        + ",":U + 'no-msg-create':U
                        + ",":U + 'negative-check':U + '=':U + '1':U
              ,buffer       buf_gds-dtl
              ,input-output unrv-qnty
              ,input-output buf_doc-line.price-base
              ,input-output buf_doc-line.price-rubl
              ,input        -1
              ,input ""
              ) no-error.
            if error-status :error
            then do:
              undo, return error return-value .
            end.
            delete buf_doc-line  .
            for each buf_doc-line-attr no-lock where
                     buf_doc-line-attr.doc-code = buf_trn-doc.out-code and
                     buf_doc-line-attr.gds-code = buf_goods.gds-code and
                     buf_doc-line-attr.attr-code = 'flora_ps':U :
                      create    new_doc-line-attr.
                      BUFFER-COPY buf_doc-line-attr TO new_doc-line-attr
                      assign
                        new_doc-line-attr.doc-code = p-doc-code
                      .
            end.
        end.
    end.
  end.
end procedure.
procedure lib-trn3_flornakl :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code as character no-undo .
    define output parameter v-fl as logical   no-undo .
    define buffer buf_trn-doc for ub.trn-doc.
    v-fl = false .
    find first buf_trn-doc  no-lock where buf_trn-doc.doc-code =  p-doc-code no-error .
    if error-status :error then return error  .
    v-fl =  buf_trn-doc.is-flora.
    if v-fl = ? then v-fl = false .
  end.
end procedure.
procedure lib-trn3_ckcntspc :
define input parameter parhost-code     like ub.contract.host-code     no-undo.
define input parameter parcontract-code like ub.contract.contract-code no-undo.
define input parameter pargds-code      like ub.goods.gds-code         no-undo.
define input parameter parprice-check   like ub.doc-line.price-rubl    no-undo.
define input parameter parvat-type      like ub.parts.vat-type    no-undo.
define input parameter parvat-pc        like ub.parts.vat-pc      no-undo.
define variable v-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-has-old-vat as logical no-undo .
define buffer bf_trn-doc              for ub.trn-doc.
define buffer bf_goods             for ub.goods.
define buffer bf_contract          for ub.contract.
define buffer bf_contract-specif   for ub.contract-specif.
define buffer bf_contract-specif-attr for ub.contract-specif-attr.
define buffer bf-f_contract-specif for ub.contract-specif.
do on error undo, return error return-value :
  if num-entries(parvat-type) > 1 then do:
      v-doc-code = entry(2, parvat-type).
      parvat-type = entry(1, parvat-type).
      find first bf_trn-doc where bf_trn-doc.doc-code = v-doc-code no-lock.
  end.
  find first bf_contract where bf_contract.host-code     = parhost-code     and
                               bf_contract.contract-code = parcontract-code no-lock no-error.
  if not available bf_contract then do:
    return error substitute ("Не найден контракт по фирме &1 с номером &2.", parhost-code, parcontract-code).
  end.
  find first bf_goods no-lock where bf_goods.gds-code = pargds-code no-error .
  if not available bf_goods then do:
    return error substitute ("Не найден товар с внутренним кодом &1.", pargds-code).
  end.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  bf_contract.host-code,
    INPUT  bf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = bf_contract.host-code
      i-gl-Contract-Code  = bf_contract.contract-code
      .
END.
    FIND FIRST bf-f_contract-specif
           NO-LOCK
           WHERE
               bf-f_contract-specif.Host-code    = i-gl-Host-Code
           AND bf-f_contract-specif.Contract-num = i-gl-Contract-Code
           NO-ERROR
           .
  if available bf-f_contract-specif then do:
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  bf_contract.host-code,
    INPUT  bf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = bf_contract.host-code
      i-gl-Contract-Code  = bf_contract.contract-code
      .
END.
    FIND FIRST bf_contract-specif
           NO-LOCK
           WHERE
               bf_contract-specif.Host-code    = i-gl-Host-Code
           AND bf_contract-specif.Contract-num = i-gl-Contract-Code
           AND bf_contract-specif.Gds-code     = bf_goods.gds-code
           NO-ERROR
           .
    if not available bf_contract-specif then do:
      if avail bf_trn-doc and bf_trn-doc.is-flora then
        return.
      else
      return error substitute ("В спецификации к договору &1 по фирме &2 в спецификации нет товара &3 &4 &5 &6.",
                               bf_contract.contract-prn-code,
                               bf_contract.host-code,
                               bf_goods.artic,
                               bf_goods.prod-type,
                               bf_goods.prod-code,
                               bf_goods.gds-name).
    end.
    define variable v-unitstore as class ibs.th.gbl.storage.unitmercstr no-undo .
    define variable v-unitsubs  as class ibs.th.str.mercury.unitsubs no-undo .
    define variable v-unitsub   as class ibs.th.str.mercury.unitsub no-undo .
    define variable v-i-counter as integer no-undo .
    define variable v-i-num     as integer no-undo .
    define variable v-stub      as integer no-undo .
    define variable v-unit-k    as decimal no-undo .
    define variable v-contr-price-cli as decimal no-undo .
    if bf_goods.unit-base = bf_contract-specif.unit-cli then do :
        v-contr-price-cli  = bf_contract-specif.price-cli .
    end .
    else do :
        v-unit-k = 1.
        v-unitstore = new ibs.th.gbl.storage.unitmercstr () .
        v-unitsubs = v-unitstore:getunitmercs(bf_goods.gds-code) .
        v-i-counter = v-unitsubs:iCounter .
        do v-i-num = 1 to v-i-counter :
          v-stub = v-unitsubs:Get(v-i-num) . // возвращает кол-во элементов и переключает currItem
          v-unitsub = cast(v-unitsubs:SubjectObjCurr, ibs.th.str.mercury.unitsub) .
          if v-unitsub:UnitName = bf_contract-specif.unit-cli then do :
            v-unit-k = v-unitsub:UnitCoef .
            leave .
          end .
        end .
        v-contr-price-cli = bf_contract-specif.price-cli / v-unit-k .
        if valid-object (v-unitsubs) then delete object v-unitsubs .
        if valid-object (v-unitstore) then delete object v-unitstore .
    end .
    if bf_contract-specif.prc > 0 then do :
      if v-contr-price-cli * (1 + 1 / 100 * bf_contract-specif.prc) < parprice-check THEN DO:
      return error substitute ("В спецификации к договору &1 по фирме &2 по товару &3 &4 &5 указана цена &6 за 1 единицу товара в базовых единицах измерения товара и отклонение в большую сторону &7%. Максимально допустимая цена = &8. В документе указана цена &9.",
                               bf_contract.contract-prn-code,
                               bf_contract.host-code,
                               bf_goods.artic,
                               bf_goods.prod-type,
                               bf_goods.prod-code,
                               v-contr-price-cli,
                               bf_contract-specif.prc,
                               v-contr-price-cli * (1 + 1 / 100 * bf_contract-specif.prc),
                               parprice-check).
      END.
    end .
      for first bf_contract-specif-attr no-lock
         where bf_contract-specif-attr.contract-num = bf_contract-specif.contract-num
           and bf_contract-specif-attr.gds-code     = bf_contract-specif.gds-code
           and bf_contract-specif-attr.host-code    = bf_contract-specif.host-code
           and bf_contract-specif-attr.attr-code    = 'prc-min':U
           and bf_contract-specif-attr.attr-value <> ?
            and decimal(bf_contract-specif-attr.attr-value) > 0 :
       if v-contr-price-cli * (1 - 1 / 100 * decimal(bf_contract-specif-attr.attr-value)) > parprice-check
       then do :
        return error substitute ("В спецификации к договору &1 по фирме &2 по товару &3 &4 &5 указана цена &6 и отклонение &7%. Минимально допустимая цена = &8. В документе указана цена &9.",
                               bf_contract.contract-prn-code,
                               bf_contract.host-code,
                               bf_goods.artic,
                               bf_goods.prod-type,
                               bf_goods.prod-code,
                               v-contr-price-cli,
                               decimal(bf_contract-specif-attr.attr-value),
                               v-contr-price-cli * (1 - 1 / 100 * decimal(bf_contract-specif-attr.attr-value)),
                               parprice-check).
      end.
    END.
    if bf_contract-specif.VAT-type <> ?  and bf_contract-specif.VAT-type <> "" then do:
       if bf_contract-specif.VAT-type <> parvat-type then do:
        return error substitute ("В спецификации к договору &1 по фирме &2 в спецификации по товару &3 &4 &5 указан тип НДС &6. Вы указали в накладной тип НДС &7 .",
                                bf_contract.contract-prn-code,
                                bf_contract.host-code,
                                bf_goods.artic,
                                bf_goods.prod-type,
                                bf_goods.prod-code,
                                bf_contract-specif.vat-type,
                                parvat-type).
       end.
    end.
    if bf_contract-specif.VAT-pc <> ?  then do:
       if bf_contract-specif.VAT-pc <> round ( parvat-pc, 1 ) then do:
         run lib-trn3_vatPrevValue in this-procedure (parvat-pc, bf_contract-specif.VAT-pc, output v-has-old-vat) .
         if not v-has-old-vat then
         return error substitute ("В спецификации к договору &1 по фирме &2 в спецификации по товару &3 &4 &5 указан НДС &6 %. Вы указали в накладной НДС &7 %.",
                                bf_contract.contract-prn-code,
                                bf_contract.host-code,
                                bf_goods.artic,
                                bf_goods.prod-type,
                                bf_goods.prod-code,
                                bf_contract-specif.vat-pc,
                                parvat-pc).
       end.
    end.
  end.
end.
end procedure.
procedure lib-trn3_vatPrevValue private :
define input  parameter p-vat-pc1    as decimal no-undo .
define input  parameter p-vat-pc2    as decimal no-undo .
define output parameter p-is-present as logical initial false no-undo .
define buffer buf_tax-rate-value for ub.tax-rate-value .
  find first buf_tax-rate-value no-lock
       where buf_tax-rate-value.tax-code   = 1
         and buf_tax-rate-value.rate-value = p-vat-pc1 no-error .
  if available buf_tax-rate-value then do :
    p-is-present = can-find (first tax-rate-value
                             where tax-rate-value.tax-code   = buf_tax-rate-value.tax-code
                               and tax-rate-value.rate-code  = buf_tax-rate-value.rate-code
                               and tax-rate-value.rate-value = p-vat-pc2) .
  end .
  else p-is-present = false .
end procedure .
procedure lib-trn3_st-sltyn :
do
on error undo, return error
:
define input  parameter p-trn-doc-recid     as recid   no-undo.
define input  parameter p-cash-pay          as integer no-undo.
define output parameter p-st-sltpc-have-slt as logical no-undo.
define variable varslt-yes as logical no-undo.
define buffer buf_st-sltpc_trn-doc for ub.trn-doc.
find first buf_st-sltpc_trn-doc where recid(buf_st-sltpc_trn-doc)   = p-trn-doc-recid.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_chpsltpc in g#lib-trn
(
 input  buf_st-sltpc_trn-doc.internal
,input  buf_st-sltpc_trn-doc.doc-type
,input  buf_st-sltpc_trn-doc.pay-code
,input  p-cash-pay
,input  buf_st-sltpc_trn-doc.slt-type
,input  buf_st-sltpc_trn-doc.ext-doc-type
,output varslt-yes
)
no-error.
if error-status:error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при проверке установки налога с продаж " skip
    " в документе " buf_st-sltpc_trn-doc.doc-code skip
    return-value skip
    trim(error-status :get-message(1))
    trim(error-status :get-message(2))
    trim(error-status :get-message(3))
    trim(error-status :get-message(4))
    trim(error-status :get-message(5)) skip
    view-as alert-box error.
  undo, return error .
end.
assign
    p-st-sltpc-have-slt = varslt-yes.
end.
end procedure.
procedure lib-trn3_reclcdsc:
define input parameter parrec-line as recid no-undo.
define buffer rd_doc-line for ub.doc-line.
define buffer rd_trn-doc  for ub.trn-doc.
define buffer rd_sysconf  for ub.sysconf.
define buffer rd_gds-dtl  for ub.gds-dtl.
define buffer rd_doc-attr for ub.doc-attr.
do on error undo, return error :
define variable v-sum-deliv as decimal   no-undo initial 0 .
define variable v-sum-delive-rubl  as decimal   no-undo initial 0 .
define variable v-sum-delive-base  as decimal   no-undo initial 0 .
find first rd_doc-line where recid(rd_doc-line) = parrec-line.
find first rd_trn-doc where rd_trn-doc.doc-code = rd_doc-line.doc-code.
find first rd_doc-attr no-lock where rd_doc-attr.doc-code  = rd_trn-doc.doc-code     and
                                     rd_doc-attr.attr-code = 'discnt-other':U and
                                     rd_doc-attr.attr-value = "yes" no-error .
if available  rd_doc-attr then do:
   return .
end.
FIND rd_sysconf WHERE rd_sysconf.host-code = rd_trn-doc.host-code NO-LOCK.
for each rd_gds-dtl where rd_gds-dtl.doc-code  = rd_trn-doc.doc-code
                      and rd_gds-dtl.prod-code = rd_doc-line.prod-code
                      and rd_gds-dtl.prod-type = rd_doc-line.prod-type
                      and rd_gds-dtl.artic     = rd_doc-line.artic :
    if can-do ('процент,сумма,карта,группа':U, rd_trn-doc.discnt-type) then do:
      if rd_trn-doc.discnt-type = 'сумма':U then do:
         assign
         rd_gds-dtl.discnt-pc   = rd_trn-doc.discnt-pc.
         if rd_trn-doc.print-rubl then do:
           assign
           rd_gds-dtl.discnt-base = rd_gds-dtl.price-base * rd_trn-doc.discnt-rubl / rd_trn-doc.tot-rubl
           rd_gds-dtl.discnt-rubl = rd_gds-dtl.price-rubl * rd_trn-doc.discnt-rubl   / rd_trn-doc.tot-rubl.
         end.
         else do:
           assign
           rd_gds-dtl.discnt-base = rd_gds-dtl.price-base * rd_trn-doc.tot-calc / rd_trn-doc.tot-doc
           rd_gds-dtl.discnt-rubl = rd_gds-dtl.price-rubl * rd_trn-doc.tot-calc / rd_trn-doc.tot-doc.
         end.
      end.
      else do:
        assign
        rd_gds-dtl.discnt-pc   = rd_trn-doc.discnt-pc
        rd_gds-dtl.discnt-base = rd_gds-dtl.price-base  * rd_gds-dtl.discnt-pc / 100
        rd_gds-dtl.discnt-rubl = rd_gds-dtl.price-rubl  * rd_gds-dtl.discnt-pc / 100.
      end.
    end.
    if can-do ('строка':U, rd_trn-doc.discnt-type) then do:
      if rd_gds-dtl.discnt-type then do:
        assign
          rd_gds-dtl.discnt-base = rd_gds-dtl.price-base * rd_gds-dtl.discnt-pc / 100
          rd_gds-dtl.discnt-rubl = rd_gds-dtl.price-rubl * rd_gds-dtl.discnt-pc / 100.
      end.
      else do:
        if rd_trn-doc.print-rubl then do:
          assign
            rd_gds-dtl.discnt-pc   = (if rd_gds-dtl.price-rubl = 0
                                      then 0
                                      else rd_gds-dtl.discnt-rubl * 100 / rd_gds-dtl.price-rubl)
            rd_gds-dtl.discnt-base = rd_gds-dtl.discnt-rubl / rd_trn-doc.base-rate * rd_trn-doc.base-scale.
        end.
        else do:
          assign
            rd_gds-dtl.discnt-pc   = (if rd_gds-dtl.price-base = 0
                                      then 0
                                      else rd_gds-dtl.discnt-base * 100 / rd_gds-dtl.price-base)
            rd_gds-dtl.discnt-rubl = rd_gds-dtl.discnt-base * rd_trn-doc.base-rate / rd_trn-doc.base-scale.
        end.
      end.
    end.
end.
end.
end procedure.
procedure lib-trn3_corinvln :
  define input  parameter p-doc-code  like ub.inv-line.doc-code   no-undo.
  define input  parameter p-artic     like ub.inv-line.artic      no-undo.
  define input  parameter p-prod-type like ub.inv-line.prod-type  no-undo.
  define input  parameter p-prod-code like ub.inv-line.prod-code  no-undo.
  define input  parameter p-sale-rubl like ub.gds-dtl.price-rubl  no-undo.
  define input  parameter p-sale-base like ub.gds-dtl.price-base  no-undo.
  define input  parameter p-acc-rubl  like ub.doc-line.price-rubl no-undo.
  define input  parameter p-acc-base  like ub.doc-line.price-base no-undo.
  define input  parameter p-fact-qnty like ub.gds-dtl.fact-qnty   no-undo.
  define input  parameter p-density   like ub.doc-line.fact-density    no-undo.
  define output parameter rec-inv-lin as   recid                  no-undo.
  define variable is-petrol   as logical   no-undo.
  define variable is-pieces   as logical   no-undo.
  define variable last-invlin as recid     no-undo initial ?.
  define variable v-price-rubl like ub.gds-dtl.price-rubl no-undo initial 0.0.
  define variable v-price-base like ub.gds-dtl.price-base no-undo initial 0.0.
  define variable v-qnty       like ub.gds-dtl.fact-qnty  no-undo initial 0.0.
  define variable v-after-qnty like ub.gds-dtl.fact-qnty  no-undo initial 0.0.
  define variable v-new-qnty   like ub.gds-dtl.fact-qnty  no-undo initial 0.0.
  define variable v-tmp-qnty   like ub.gds-dtl.fact-qnty  no-undo initial 0.0.
  define buffer buf_trn-doc  for ub.trn-doc.
  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_gds-dtl  for ub.gds-dtl.
  define buffer buf_goods    for ub.goods.
  define buffer bf_rvs-doc   for ub.rvs-doc.
  define buffer bf_pl-gds    for ub.pl-gds.
  do
  on error undo, return error "lib-trn3_corinvln: ошибка изменения записи inv-line"
  :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input p-artic
  ,  input p-prod-type
  ,  input p-prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
    if is-petrol = yes
      and is-pieces = no
    then do:
      find first buf_trn-doc exclusive-lock
        where buf_trn-doc.doc-code = p-doc-code
        no-error.
      if not available buf_trn-doc then do:
        undo, return error substitute( 'lib-trn3_corinvln: не найдена накладная "&1"', p-doc-code ).
      end.
      find first buf_goods no-lock
        where buf_goods.artic     = p-artic
          and buf_goods.prod-type = p-prod-type
          and buf_goods.prod-code = p-prod-code
        no-error.
      if not available buf_goods then do:
        undo, return error substitute( 'lib-trn3_corinvln: не найден товар: Артикул "&1" (производитель: &2 &3)', p-artic, p-prod-type, p-prod-code ).
      end.
      find first buf_inv-line exclusive-lock
        where buf_inv-line.doc-code  = p-doc-code
          and buf_inv-line.artic     = p-artic
          and buf_inv-line.prod-type = p-prod-type
          and buf_inv-line.prod-code = p-prod-code
        no-error.
      if available buf_inv-line then do:
        assign
          rec-inv-lin = recid( buf_inv-line )
        .
      end.
      else do:
        run check-use-artic in this-procedure
          ( input "inv-line":U
           ,input p-artic
           ,input p-prod-type
           ,input p-prod-code
          ) no-error.
        if error-status :error then do:
          undo, return error substitute( 'lib-trn3_corinvln: &1', return-value ).
        end.
        create buf_inv-line.
        assign
          buf_inv-line.doc-code  = p-doc-code
          buf_inv-line.artic     = p-artic
          buf_inv-line.prod-type = p-prod-type
          buf_inv-line.prod-code = p-prod-code
          rec-inv-lin            = recid( buf_inv-line )
        .
      end.
      find first buf_doc-line exclusive-lock
        where buf_doc-line.doc-code  = p-doc-code
          and buf_doc-line.artic     = p-artic
          and buf_doc-line.prod-type = p-prod-type
          and buf_doc-line.prod-code = p-prod-code
        no-error.
      if not available buf_doc-line then do:
        undo, return error substitute( 'lib-trn3_corinvln: не найдена строка накладной "&1" с товаром: Артикул "&2" (производитель: &3 &4)'
                                      ,p-doc-code
                                      ,p-artic
                                      ,p-prod-type
                                      ,p-prod-code
                                     ).
      end.
      if
  valid-density( p-density, buf_goods.unit-base = buf_goods.unit-cli )
  = true then do:
        if not ( buf_trn-doc.ext-doc-type = 'ie':U
                and ( ( buf_trn-doc.status_ = 'накл':U
                        and buf_trn-doc.flag_ = true
                      )
                      or buf_trn-doc.status_ = 'факт':U
                    )
              )
        then do:
          if p-acc-rubl = ? or p-acc-rubl = 0.0 then do:
            assign
              p-acc-rubl = buf_doc-line.price-rubl / p-density
            .
          end.
          if p-acc-base = ? or p-acc-base = 0.0 then do:
            assign
              p-acc-base = buf_doc-line.price-base / p-density
            .
          end.
        end.
        if ( ( p-sale-rubl = ?
               or p-sale-rubl = 0.0
               or p-sale-base = ?
               or p-sale-base = 0.0
             )
             and not ( buf_trn-doc.ext-doc-type = 'ie':U
                       and ( ( buf_trn-doc.status_      = 'накл':U
                               and buf_trn-doc.flag_        = true
                             )
                             or buf_trn-doc.status_      = 'факт':U
                           )
                     )
           )
           or ( p-fact-qnty = ?
                or p-fact-qnty = 0.0
              )
              and not ( buf_trn-doc.ext-doc-type = 'ie':U
                        and buf_trn-doc.status_      = 'факт':U
                      )
        then do:
          find first buf_gds-dtl exclusive-lock
            where buf_gds-dtl.doc-code  = p-doc-code
              and buf_gds-dtl.artic     = p-artic
              and buf_gds-dtl.prod-code = p-prod-code
              and buf_gds-dtl.prod-type = p-prod-type
            no-error
          .
          if available buf_gds-dtl then do:
            assign
              v-price-rubl = ( if buf_gds-dtl.price-rubl = ? then 0.0 else buf_gds-dtl.price-rubl )
              v-price-base = ( if buf_gds-dtl.price-base = ? then 0.0 else buf_gds-dtl.price-base )
            .
          end.
          if v-price-rubl = ? then do:
            assign
              v-price-rubl = 0.0
            .
          end.
          if v-price-base = ? then do:
            assign
              v-price-base = 0.0
            .
          end.
          if not ( buf_trn-doc.ext-doc-type = 'ie':U
                   and buf_trn-doc.status_      = 'накл':U
                   and buf_trn-doc.flag_        = yes
                 )
          then do:
            if p-sale-rubl = ? or p-sale-rubl = 0.0 then do:
              assign
                p-sale-rubl = v-price-rubl / p-density
              .
            end.
            if p-sale-base = ? or p-sale-base = 0.0 then do:
              assign
                p-sale-base = v-price-base / p-density
              .
            end.
          end.
          if p-fact-qnty = ?
            or p-fact-qnty = 0.0
          then do:
            if buf_trn-doc.doc-type = 'инв':U then do:
              assign
                v-qnty = buf_doc-line.doc-qnty
              .
            end.
            else do:
              if available buf_gds-dtl then do:
                assign
                  v-qnty = ( if buf_gds-dtl.fact-qnty = ?  then 0.0 else buf_gds-dtl.fact-qnty )
                .
              end.
              else do:
                assign
                  v-qnty = buf_doc-line.fact-qnty
                .
              end.
            end.
            assign
              p-fact-qnty = v-qnty * p-density
            .
          end.
        end.
      end.
      if not ( buf_trn-doc.ext-doc-type = 'ie':U
               and ( ( buf_trn-doc.status_      = 'накл':U
                       and buf_trn-doc.flag_        = yes
                     )
                     or buf_trn-doc.status_      = 'факт':U
                   )
             )
      then do:
        if p-sale-rubl = ? then do:
          assign
            p-sale-rubl = 0.0
          .
        end.
        if p-sale-base = ? then do:
          assign
            p-sale-base = 0.0
          .
        end.
        if p-acc-rubl  = ? then do:
          assign
            p-acc-rubl  = 0.0
          .
        end.
        if p-acc-base  = ? then do:
          assign
            p-acc-base  = 0.0
          .
        end.
        assign
          buf_inv-line.wast-rubl      = p-sale-rubl
          buf_inv-line.wast-base      = p-sale-base
          buf_inv-line.unus-wast-rubl = p-acc-rubl
          buf_inv-line.unus-wast-base = p-acc-base
        .
      end.
      if buf_trn-doc.ext-doc-type = 'ie':U
        and buf_trn-doc.status_ = 'факт':U
      then do:
        assign
          p-fact-qnty = buf_inv-line.wast-cli-qnty
        .
      end.
      if p-fact-qnty = ? then do:
        assign
          p-fact-qnty = 0.0
        .
      end.
      if absolute( buf_inv-line.wast-cli-qnty - p-fact-qnty ) > 0
        and ( buf_doc-line.status_ <> 'факт':U
              or buf_trn-doc.ext-doc-type = 'es':U
              or buf_trn-doc.ext-doc-type = 'rs':U
            )
      then do:
        assign
          buf_inv-line.wast-cli-qnty = p-fact-qnty
        .
      end.
      if buf_trn-doc.status_ = 'факт':U then do:
        if buf_trn-doc.doc-type = 'инв':U then do:
          assign
            buf_inv-line.after-cli-qnty = buf_inv-line.wast-cli-qnty
          .
        end.
        else do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_lastinvl in g#lib-trn3
(
   input buf_inv-line.doc-code
,  input buf_inv-line.artic
,  input buf_inv-line.prod-type
,  input buf_inv-line.prod-code
, output v-after-qnty
, output last-invlin
)  .
          if v-after-qnty = ? then do:
            assign
              v-after-qnty = 0.0
            .
            find first buf_goods no-lock
            where buf_goods.artic     = buf_inv-line.artic
              and buf_goods.prod-type = buf_inv-line.prod-type
              and buf_goods.prod-code = buf_inv-line.prod-code
              no-error.
            for each bf_pl-gds no-lock
            where bf_pl-gds.gds-code  = buf_goods.gds-code
              and bf_pl-gds.obj-type  = buf_inv-line.obj-type
              and bf_pl-gds.obj-code  = buf_inv-line.obj-code
            use-index gds-code
              :
              assign v-after-qnty = v-after-qnty + bf_pl-gds.cli-fact-qnty.
            end.
          end.
          assign
            buf_inv-line.before-cli-qnty = v-after-qnty
            v-new-qnty                   = buf_inv-line.wast-cli-qnty
          .
          run lib-trn3_correct-quantity in this-procedure ( input buf_trn-doc.doc-type, input-output v-new-qnty ).
          assign
            buf_inv-line.after-cli-qnty = buf_inv-line.before-cli-qnty + ( if v-new-qnty = ? then 0.0 else v-new-qnty   )
          .
        end.
        if buf_inv-line.after-cli-qnty = ? then do:
          assign
            buf_inv-line.after-cli-qnty = 0.0
          .
        end.
      end.
    end.
  end.
end procedure.
procedure lib-trn3_lastinvl :
  define  input parameter p-doc-code   like ub.inv-line.doc-code       no-undo.
  define  input parameter p-artic      like ub.inv-line.artic          no-undo.
  define  input parameter p-prod-type  like ub.inv-line.prod-type      no-undo.
  define  input parameter p-prod-code  like ub.inv-line.prod-code      no-undo.
  define output parameter p-after-qnty like ub.inv-line.after-cli-qnty no-undo.
  define output parameter p-invlin-rec as   recid                      no-undo initial ?.
  define variable is-petrol    as logical   no-undo.
  define variable is-pieces    as logical   no-undo.
  define variable Fact-Order-0 as decimal   no-undo initial 0.
  define variable v-shift-fo   as decimal   no-undo initial 0.
  define variable v-day-fo     as decimal   no-undo initial 0.
  define variable v-fact-date  as date      no-undo initial ?.
  define variable v-fact-time  as integer   no-undo initial 0.
  define variable v-fact-num   as integer   no-undo initial 0.
  define variable v-shift-date as date      no-undo initial ?.
  define variable v-shift-num  as integer   no-undo initial 0.
  define variable v-shift-on   as logical   no-undo initial no.
  define buffer buf_trn-doc   for ub.trn-doc.
  define buffer buf_doc-line  for ub.doc-line.
  define buffer buf_inv-line  for ub.inv-line.
  define buffer last_inv-line for ub.inv-line.
  define buffer last_doc-line for ub.doc-line.
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      undo, return error substitute( 'lib-trn3_lastinvl: не найден документ "&1"'
                                    ,p-doc-code
                                   ).
    end.
    find first buf_doc-line exclusive-lock
      where buf_doc-line.doc-code  = buf_trn-doc.doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error.
    if not available buf_doc-line then do:
      undo, return error substitute( 'lib-trn3_lastinvl: не найдена строка документа "&1" с товаром: Артикул "&2" (производитель: &3 &4)'
                                    ,buf_trn-doc.doc-code
                                    ,p-artic
                                    ,p-prod-type
                                    ,p-prod-code
                                   ).
    end.
    assign
      p-invlin-rec = ?
      p-after-qnty = 0.0
    .
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
      find first buf_inv-line exclusive-lock
        where buf_inv-line.doc-code  = buf_trn-doc.doc-code
          and buf_inv-line.artic     = buf_doc-line.artic
          and buf_inv-line.prod-type = buf_doc-line.prod-type
          and buf_inv-line.prod-code = buf_doc-line.prod-code
        no-error.
      if not available buf_inv-line then do:
        undo, return error substitute( 'lib-trn3_lastinvl: не найдена строка итогов (кг) накладной "&1" с товаром: Артикул "&2" (производитель: &3 &4)'
                                      ,buf_trn-doc.doc-code
                                      ,buf_doc-line.artic
                                      ,buf_doc-line.prod-type
                                      ,buf_doc-line.prod-code
                                     ).
      end.
      if buf_trn-doc.fact-order = 0
        or buf_trn-doc.fact-order = ?
      then do:
        assign
          v-fact-date  = buf_trn-doc.fact-date
          v-fact-time  = buf_trn-doc.fact-time
          v-fact-num   = buf_trn-doc.fact-num
          v-shift-date = buf_trn-doc.shift-date
          v-shift-num  = buf_trn-doc.shift-num
        .
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
        if error-status :error
          or v-shift-on = ?
        then do:
          assign
            v-shift-date = ?
            v-shift-num  = 0
            v-shift-on   = no
          .
        end.
        if v-fact-date = ? then do:
          assign
            v-fact-date = today
          .
        end.
        if v-fact-time = ?
          or v-fact-time = 0
        then do:
          assign
            v-fact-time = time
          .
        end.
        if v-fact-num = ?
          or v-fact-num = 0
        then do:
          assign
            v-fact-num = current-value( s-trn-fact, ub )
          .
        end.
        if v-shift-on = yes then do:
          if v-shift-date = ? then do:
            assign
              v-shift-date = v-fact-date
            .
          end.
          if v-shift-num = 0
            or v-shift-num = ?
          then do:
            assign
              v-shift-num = 24
            .
          end.
        end.
        run factord in this-procedure
          ( input v-fact-date
           ,input v-fact-time
           ,input v-fact-num
           ,input v-shift-date
           ,input v-shift-num
           ,input v-shift-on
           ,output Fact-Order-0
           ,output v-shift-fo
           ,output v-day-fo
          ).
      end.
      else do:
        assign
          Fact-Order-0 = buf_trn-doc.fact-order
        .
      end.
      if Fact-Order-0 = 0
        or Fact-Order-0 = ?
      then do:
        run factord-max-fact-order in this-procedure
          ( output Fact-Order-0
          ).
      end.
      for each last_doc-line share-lock
        where last_doc-line.obj-type    = buf_trn-doc.obj-type
          and last_doc-line.obj-code    = buf_trn-doc.obj-code
          and last_doc-line.artic       = buf_doc-line.artic
          and last_doc-line.prod-code   = buf_doc-line.prod-code
          and last_doc-line.prod-type   = buf_doc-line.prod-type
          and last_doc-line.status_     = 'факт':U
          and last_doc-line.fact-order  > 0
          and last_doc-line.fact-order  < Fact-Order-0
        use-index fact-order
        by last_doc-line.fact-order descending
      on error undo, return error return-value
      :
        if recid( last_doc-line ) = recid( buf_doc-line ) then do:
          next.
        end.
        find first last_inv-line share-lock
          where last_inv-line.doc-code  = last_doc-line.doc-code
            and last_inv-line.artic     = last_doc-line.artic
            and last_inv-line.prod-code = last_doc-line.prod-code
            and last_inv-line.prod-type = last_doc-line.prod-type
          no-error.
        if available last_inv-line then do:
          if recid( last_inv-line ) = recid( buf_inv-line ) then do:
            next.
          end.
          assign
            p-invlin-rec = recid( last_inv-line )
            p-after-qnty = last_inv-line.after-cli-qnty
          .
          leave.
        end.
      end.
    end.
  end.
end procedure.
procedure lib-trn3_correct-quantity :
  define input        parameter p-doc-type like ub.trn-doc.doc-type  no-undo.
  define input-output parameter p-quantity like ub.trn-doc.fact-qnty no-undo.
  do on error undo, return error "lib-trn3_correct-quantity: неверный тип документа" :
            if lookup( p-doc-type, 'при,рас,спи,возврат,инв':U ) = 0 then do:
      undo, return error substitute( 'lib-trn3_correct-quantity: неверный тип документа - "&1"', p-doc-type ).
    end.
    if lookup( p-doc-type, 'инв,при,возврат':U ) > 0 and p-quantity < 0.0 or
       lookup( p-doc-type, 'спи,рас':U ) > 0 and p-quantity > 0.0 then do:
      assign
        p-quantity = - p-quantity
      .
    end.
  end.
end procedure.
define temp-table tt_trn-doc  no-undo like ub.trn-doc .
define temp-table tt_doc-line no-undo like ub.doc-line
  field gds-code like ub.goods.gds-code
.
define temp-table tt_corr-place no-undo
  field pl-code  like ub.doc-pl.pl-code
  field gds-code like ub.doc-pl.gds-code
  index pi is primary unique gds-code pl-code
.
procedure lib-trn3_reclcptr :
  define input  parameter p-handle-trn-doc  as handle    no-undo .
  define input  parameter p-handle-doc-line as handle    no-undo .
  define input  parameter p-warp-factor     as decimal   no-undo .
  define input  parameter p-ext-doc-type    as character no-undo .
  define input  parameter p-chip-num-main   as integer   no-undo .
  do
  on error  undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "lib-trn3_reclcptr. stop" )
  on endkey undo, return error substitute( "lib-trn3_reclcptr. endkey" )
  :
    define variable v-ok           as logical   no-undo .
    define variable is-petrol      as logical   no-undo .
    define variable is-pieces      as logical   no-undo .
    define variable v-cre-hist     as logical   no-undo .
    define variable v-doc-code     as character no-undo .
    define variable v-ext-doc-type as character no-undo .
    define variable v-doc-cli-qnty as decimal   no-undo .
    define variable v-sign         as decimal   no-undo .
    define buffer buf_goods         for ub.goods .
    define buffer buf_doc-line      for ub.doc-line .
    define buffer buf_inv-line      for ub.inv-line .
    define buffer buf_doc-pl        for ub.doc-pl .
    define buffer buf_rvs-doc       for ub.rvs-doc .
    define buffer buf_rvs-line      for ub.rvs-line .
    define buffer buf-next_inv-line for ub.inv-line .
    define buffer buf-next_trn-doc  for ub.trn-doc .
    define buffer buf-next_rvs-doc  for ub.rvs-doc .
    define buffer buf-next_rvs-line for ub.rvs-line .
    if valid-handle( p-handle-trn-doc )
      and valid-handle( p-handle-doc-line )
    then do:
      undo, return error substitute( "lib-trn3_reclcptr. Ошибка задания входных параметров. Заданы указатели на документ и на строку документа одновременно." ) .
    end.
    if p-warp-factor <> 1.0
      and p-warp-factor <> -1.0
    then do:
      undo, return error substitute( "lib-trn3_reclcptr. Ошибка задания входных параметров. Не задано направление пересчета итогов." ) .
    end.
    for each tt_trn-doc
    on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete tt_trn-doc .
    end.
    for each tt_doc-line
    on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete tt_doc-line .
    end.
    for each tt_corr-place
    on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete tt_corr-place .
    end.
    if valid-handle( p-handle-trn-doc ) then do:
      create tt_trn-doc.
      assign
        v-ok = buffer tt_trn-doc :handle :buffer-copy ( p-handle-trn-doc )
      .
      if tt_trn-doc.status_ <> 'факт':U then do:
        delete tt_trn-doc.
        return .
      end.
      for each buf_doc-line exclusive-lock
        where buf_doc-line.doc-code = tt_trn-doc.doc-code
      on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        find first buf_goods no-lock
          where buf_goods.artic     = buf_doc-line.artic
            and buf_goods.prod-type = buf_doc-line.prod-type
            and buf_goods.prod-code = buf_doc-line.prod-code
          .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrol
  , output is-pieces
  ) .
        if is-petrol = true
          and is-pieces = false
          and buf_doc-line.status_ = 'факт':U
        then do:
          create tt_doc-line .
          buffer-copy buf_doc-line to tt_doc-line
            assign
              tt_doc-line.gds-code = buf_goods.gds-code
          .
        end.
      end.
      assign
        v-doc-code     = tt_trn-doc.doc-code
        v-ext-doc-type = tt_trn-doc.ext-doc-type
      .
    end.
    else do:
      if valid-handle( p-handle-doc-line ) then do:
        create tt_doc-line .
        assign
          v-ok = buffer tt_doc-line :handle :buffer-copy ( p-handle-doc-line )
        .
        find first buf_goods no-lock
          where buf_goods.artic     = tt_doc-line.artic
            and buf_goods.prod-type = tt_doc-line.prod-type
            and buf_goods.prod-code = tt_doc-line.prod-code
          .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrol
  , output is-pieces
  ) .
        if not( is-petrol = true
                and is-pieces = false
              )
          or tt_doc-line.status_ <> 'факт':U
        then do:
          delete tt_doc-line.
        end.
        else do:
          assign
            tt_doc-line.gds-code = buf_goods.gds-code
            v-doc-code           = tt_doc-line.doc-code
            v-ext-doc-type       = tt_doc-line.ext-doc-type
          .
        end.
      end.
      else do:
        undo, return error substitute( "lib-trn3_reclcptr.  Ошибка задания входных параметров. Не задан указатель на документ или на строку документа." ) .
      end.
    end.
    for each tt_doc-line
    on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      if tt_doc-line.doc-code <> v-doc-code then do:
        undo, return error substitute( 'lib-trn3_reclcptr. Пересчет может запускаться только для одного документа, а запускается для "&1" и "&2".', v-doc-code, tt_doc-line.doc-code ).
      end.
      if tt_doc-line.ext-doc-type <> v-ext-doc-type then do:
        undo, return error substitute( 'lib-trn3_reclcptr. В документе &1 есть строки с разным расширенным типом: "&2" и "&3".', v-doc-code, v-ext-doc-type, tt_doc-line.ext-doc-type ).
      end.
      if lookup( tt_doc-line.ext-doc-type, 'ee,ep,es,we,ev,em,wm,eo':U ) > 0 then do:
        assign
          v-sign = p-warp-factor * -1.0
        .
      end.
      else do:
        assign
          v-sign = p-warp-factor
        .
        if lookup( tt_doc-line.ext-doc-type, 'ie,re,rs,vt,vp,ap,mp,pc,iv,rv,im,io':U ) = 0 then do:
          undo, return error substitute( 'lib-trn3_reclcptr. Тип "&1" не внесен в списки документов уменьшающих(увеличивающих) остатки!', tt_doc-line.ext-doc-type).
        end.
      end.
      find first buf_inv-line exclusive-lock
        where buf_inv-line.doc-code  = tt_doc-line.doc-code
          and buf_inv-line.artic     = tt_doc-line.artic
          and buf_inv-line.prod-type = tt_doc-line.prod-type
          and buf_inv-line.prod-code = tt_doc-line.prod-code
        no-error .
      if not available buf_inv-line then do:
        undo, return error substitute( 'lib-trn3_reclcptr. Нет строки и с нарастающим итогом (inv-line).&1Документ &2&1Товар &3', chr(10), tt_doc-line.doc-code, tt_doc-line.artic).
      end.
      if lookup( tt_doc-line.ext-doc-type, 'vt,ap,mp,vp,':U ) > 0 then do:
        assign
          v-doc-cli-qnty = tt_doc-line.cli-qnty
        .
      end.
      else do:
        assign
          v-doc-cli-qnty = buf_inv-line.wast-cli-qnty
        .
      end.
      if buf_inv-line.wast-cli-qnty <> 0.0 then do:
        for each buf-next_inv-line exclusive-lock
          where buf-next_inv-line.obj-type   = tt_doc-line.obj-type
            and buf-next_inv-line.obj-code   = tt_doc-line.obj-code
            and buf-next_inv-line.prod-code  = tt_doc-line.prod-code
            and buf-next_inv-line.prod-type  = tt_doc-line.prod-type
            and buf-next_inv-line.artic      = tt_doc-line.artic
            and buf-next_inv-line.status_    = 'факт':U
            and buf-next_inv-line.fact-order > tt_doc-line.fact-order
          use-index fact-order
        on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          assign
            buf-next_inv-line.before-cli-qnty = buf-next_inv-line.before-cli-qnty + v-doc-cli-qnty * v-sign
            buf-next_inv-line.after-cli-qnty  = buf-next_inv-line.after-cli-qnty  + v-doc-cli-qnty * v-sign
          .
          find first buf-next_trn-doc no-lock
            where buf-next_trn-doc.doc-code = buf-next_inv-line.doc-code
            no-error .
          if not available buf-next_trn-doc then do:
            undo, return error substitute( "lib-trn3_reclcptr. Отсутствует шапка документа &1. Пересчет невозможен!", buf-next_inv-line.doc-code).
          end.
          if buf-next_trn-doc.doc-type = 'инв':U then do:
            assign
              buf-next_inv-line.wast-cli-qnty = buf-next_inv-line.after-cli-qnty
            .
          end.
        end.
      end.
      for each buf-next_rvs-doc
        where buf-next_rvs-doc.obj-type   = tt_doc-line.obj-type
          and buf-next_rvs-doc.obj-code   = tt_doc-line.obj-code
          and buf-next_rvs-doc.status_    = 'факт':U
          and buf-next_rvs-doc.rvs-type  <> 'проверка':U
          and buf-next_rvs-doc.fact-order > tt_doc-line.fact-order
      on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        if buf-next_rvs-doc.out-code = tt_doc-line.doc-code then do:
          next.
        end.
        assign
          v-cre-hist = false
        .
        for each buf_doc-pl no-lock
          where buf_doc-pl.out-code = tt_doc-line.doc-code
            and buf_doc-pl.gds-code = tt_doc-line.gds-code
            and buf_doc-pl.obj-type = tt_doc-line.obj-type
            and buf_doc-pl.obj-code = tt_doc-line.obj-code
          ,first buf-next_rvs-line
            where buf-next_rvs-line.rvs-code = buf-next_rvs-doc.rvs-code
              and buf-next_rvs-line.obj-type = buf_doc-pl.obj-type
              and buf-next_rvs-line.obj-code = buf_doc-pl.obj-code
              and buf-next_rvs-line.pl-code  = buf_doc-pl.pl-code
              and buf-next_rvs-line.gds-code = buf_doc-pl.gds-code
        on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if v-cre-hist = false then do:
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_hstc-rvs in g#lib-rvs
( buffer buf-next_rvs-doc
 ,input integer('3':U)
 ,input tt_doc-line.doc-code
 ,input p-chip-num-main
) no-error.
            if error-status :error then do:
              undo, return error substitute("lib-trn3_reclcptr. Ошибка при вызове процедуры lib-trn_hstc-rvs. &1 &2", error-status :get-message(1), return-value).
            end.
            assign
              v-cre-hist = true
            .
          end.
          assign
            buf-next_rvs-line.system-qnty     = buf-next_rvs-line.system-qnty     + buf_doc-pl.fact-qnty     * v-sign
            buf-next_rvs-doc.system-qnty      = buf-next_rvs-doc.system-qnty      + buf_doc-pl.fact-qnty     * v-sign
            buf-next_rvs-line.system-cli-qnty = buf-next_rvs-line.system-cli-qnty + buf_doc-pl.cli-fact-qnty * v-sign
            buf-next_rvs-doc.system-cli-qnty  = buf-next_rvs-doc.system-cli-qnty  + buf_doc-pl.cli-fact-qnty * v-sign
          .
          find first tt_corr-place
            where tt_corr-place.gds-code = buf_doc-pl.gds-code
              and tt_corr-place.pl-code  = buf_doc-pl.pl-code
            no-error .
          if not available tt_corr-place then do:
            create tt_corr-place.
            assign
              tt_corr-place.gds-code = buf_doc-pl.gds-code
              tt_corr-place.pl-code  = buf_doc-pl.pl-code
            .
          end.
        end.
      end.
    end.
    for each buf_rvs-doc exclusive-lock
      where buf_rvs-doc.out-code = v-doc-code
      ,each tt_corr-place
      ,first buf_rvs-line exclusive-lock
      where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
        and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
        and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
        and buf_rvs-line.pl-code  = tt_corr-place.pl-code
        and buf_rvs-line.gds-code = tt_corr-place.gds-code
    on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        buf_rvs-line.system-qnty     = ?
        buf_rvs-doc.system-qnty      = ?
        buf_rvs-line.system-cli-qnty = ?
        buf_rvs-doc.system-cli-qnty  = ?
      .
    end.
    for each tt_trn-doc
    on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete tt_trn-doc .
    end.
    for each tt_doc-line
    on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete tt_doc-line .
    end.
    for each tt_corr-place
    on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete tt_corr-place .
    end.
    return.
  end.
end procedure.
procedure lib-trn3_invlnprc :
  define  input parameter p-doc-code     like ub.doc-line.doc-code   no-undo.
  define  input parameter p-artic        like ub.doc-line.artic      no-undo.
  define  input parameter p-prod-type    like ub.doc-line.prod-type  no-undo.
  define  input parameter p-prod-code    like ub.doc-line.prod-code  no-undo.
  define  input parameter p-price-type   as   character              no-undo.
  define  input parameter p-print-rubl   as   logical                no-undo.
  define output parameter p-out-price-kg like ub.doc-line.price-rubl no-undo initial 0.0.
  define buffer buf_inv-line for ub.inv-line.
  do on error undo, return error return-value :
    if lookup( p-price-type, "acc,sale" ) = 0 then do:
      undo, return error substitute( 'lib-trn3_invlnprc: неизвестный тип цены - "&1" (допустимо: acc,sale)',
                                     p-price-type ).
    end.
    assign p-price-type = p-price-type + ( if p-print-rubl = yes then "-rubl" else "-base" ).
    find buf_inv-line no-lock where
         buf_inv-line.doc-code  = p-doc-code  and
         buf_inv-line.artic     = p-artic     and
         buf_inv-line.prod-code = p-prod-code and
         buf_inv-line.prod-type = p-prod-type no-error.
    if available buf_inv-line then do:
      case p-price-type :
        when "acc-rubl"  then do: assign p-out-price-kg = buf_inv-line.unus-wast-rubl. end.
        when "acc-base"  then do: assign p-out-price-kg = buf_inv-line.unus-wast-base. end.
        when "sale-rubl" then do: assign p-out-price-kg = buf_inv-line.wast-rubl.      end.
        when "sale-base" then do: assign p-out-price-kg = buf_inv-line.wast-base.      end.
        otherwise             do:
          undo, return error substitute(
            'lib-trn3_invlnprc: неизвестный тип цены - "&1" (допустимо: acc,sale[-rubl/-base])', p-price-type ).
        end.
      end case.
    end.
  end.
end procedure.
procedure lib-trn3_invlnqty :
  define  input parameter p-doc-code     like ub.doc-line.doc-code   no-undo.
  define  input parameter p-artic        like ub.doc-line.artic      no-undo.
  define  input parameter p-prod-type    like ub.doc-line.prod-type  no-undo.
  define  input parameter p-prod-code    like ub.doc-line.prod-code  no-undo.
  define  input parameter p-is-arch-qnty as   logical                no-undo.
  define output parameter p-out-qnty-kg  like ub.doc-line.price-rubl no-undo initial 0.0.
  define buffer buf_inv-line for ub.inv-line.
  do on error undo, return error return-value :
    if p-is-arch-qnty <> yes then do: assign p-is-arch-qnty = no. end.
    find buf_inv-line          no-lock where
         buf_inv-line.doc-code  = p-doc-code  and
         buf_inv-line.artic     = p-artic     and
         buf_inv-line.prod-type = p-prod-type and
         buf_inv-line.prod-code = p-prod-code no-error.
    if available buf_inv-line then do:
      assign p-out-qnty-kg = ( if p-is-arch-qnty = yes then buf_inv-line.after-cli-qnty else buf_inv-line.wast-cli-qnty ).
    end.
  end.
end procedure.
procedure lib-trn3_getwtqty :
  define  input parameter p-doc-code      like ub.doc-line.doc-code  no-undo.
  define  input parameter p-artic         like ub.doc-line.artic     no-undo.
  define  input parameter p-prod-type     like ub.doc-line.prod-type no-undo.
  define  input parameter p-prod-code     like ub.doc-line.prod-code no-undo.
  define output parameter p-before-qnty   like ub.doc-line.fact-qnty no-undo initial 0.0.
  define output parameter p-after-qnty    like ub.doc-line.fact-qnty no-undo initial 0.0.
  define output parameter p-diff-qnty     like ub.doc-line.fact-qnty no-undo initial 0.0.
  define output parameter p-diff-abs-qnty like ub.doc-line.fact-qnty no-undo initial 0.0.
  define variable is-petrol    as logical   no-undo.
  define variable is-pieces    as logical   no-undo.
  define variable v-data-type  as character no-undo.
  define variable rec-doc-line as recid     no-undo.
  define variable rec-inv-line as recid     no-undo.
  define variable rec-goods    as recid     no-undo.
  define buffer buf_trn-doc  for ub.trn-doc.
  define buffer buf_goods    for ub.goods.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_inv-line for ub.inv-line.
  do on error undo, return error return-value :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input p-artic
  ,  input p-prod-type
  ,  input p-prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
    if is-petrol = true
      and is-pieces = false
    then do:
      find buf_trn-doc exclusive-lock
        where buf_trn-doc.doc-code = p-doc-code
        no-error
      .
      if not available buf_trn-doc then do:
        undo, return error substitute( 'lib-trn3_getwtqty: не найден документ "&1"', p-doc-code ).
      end.
      find first buf_goods share-lock
        where buf_goods.artic     = p-artic
          and buf_goods.prod-type = p-prod-type
          and buf_goods.prod-code = p-prod-code
        no-error.
      if not available buf_goods then do:
        undo, return error substitute( 'lib-trn3_getwtqty: не найден товар: Артикул "&1" (производитель: &2 &3)', p-artic, p-prod-type, p-prod-code ).
      end.
      assign
        rec-goods = recid( buf_goods )
      .
      find buf_doc-line        no-lock where
            buf_doc-line.doc-code  = p-doc-code  and
            buf_doc-line.artic     = p-artic     and
            buf_doc-line.prod-type = p-prod-type and
            buf_doc-line.prod-code = p-prod-code no-error.
      if not available buf_doc-line then do:
        undo, return error substitute(
          'lib-trn3_getwtqty: не найдена строка накладной "&1" с товаром: Артикул "&2" (производитель: &3 &4)',
          p-doc-code,
          p-artic,
          p-prod-type,
          p-prod-code                ).
      end.
      assign
        rec-doc-line = recid( buf_doc-line )
      .
      find buf_doc-line exclusive-lock where recid( buf_doc-line ) = rec-doc-line.
      find first buf_inv-line no-lock where
                  buf_inv-line.doc-code  = buf_doc-line.doc-code  and
                  buf_inv-line.artic     = buf_doc-line.artic     and
                  buf_inv-line.prod-type = buf_doc-line.prod-type and
                  buf_inv-line.prod-code = buf_doc-line.prod-code no-error.
      if not available buf_inv-line then do:
        undo, return error substitute(
          'lib-trn3_getwtqty: не найдена строка накладной "&1", товар: Артикул "&2" (производитель: &3 &4)' +
          ' с весовыми итогами по топливу',
          p-doc-code,
          p-artic,
          p-prod-type,
          p-prod-code                ).
      end.
      assign
        rec-inv-line = recid( buf_inv-line )
      .
      find buf_inv-line exclusive-lock where recid( buf_inv-line ) = rec-inv-line.
      if buf_trn-doc.ext-doc-type = 'vt':U      or
          buf_trn-doc.ext-doc-type = 'vp':U then do:
        assign
          p-before-qnty   = buf_inv-line.before-cli-qnty
          p-after-qnty    = buf_inv-line.after-cli-qnty
          p-diff-qnty     = ( p-after-qnty - p-before-qnty )
          p-diff-abs-qnty = abs( p-diff-qnty )
        .
      end.
      else do:
        assign
          p-after-qnty    = buf_inv-line.after-cli-qnty
          p-diff-qnty     = buf_inv-line.wast-cli-qnty
          p-diff-abs-qnty = abs( p-diff-qnty )
        .
        run lib-trn3_correct-quantity in this-procedure ( input buf_trn-doc.doc-type, input-output p-diff-qnty ).
        assign
          p-before-qnty   = ( p-after-qnty - p-diff-qnty )
        .
      end.
      find buf_inv-line        no-lock where recid( buf_inv-line ) = rec-inv-line.
      find buf_doc-line        no-lock where recid( buf_doc-line ) = rec-doc-line.
      find buf_goods           no-lock where recid( buf_goods    ) = rec-goods.
      find buf_trn-doc        no-lock where buf_trn-doc.doc-code = p-doc-code.
    end.
  end.
end procedure.
procedure lib-trn3_vollosan :
  define input  parameter p-gds-code   like ub.goods.gds-code        no-undo .
  define input  parameter p-obj-type   like ub.trn-doc.obj-type      no-undo .
  define input  parameter p-obj-code   like ub.trn-doc.obj-code      no-undo .
  define input  parameter p-pl-list    as character                  no-undo .
  define input  parameter p-shift-date like ub.trn-doc.shift-date    no-undo .
  define input  parameter p-shift-num  like ub.trn-doc.shift-num     no-undo .
  define input  parameter p-fact-date  like ub.trn-doc.fact-date     no-undo .
  define input  parameter p-fact-time  like ub.trn-doc.fact-time     no-undo .
  define output parameter p-pl-code    like ub.pl-gds.pl-code no-undo .
  do
  on error  undo, return error substitute( "&1 (lib-trn3_vollosan). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (lib-trn3_vollosan). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (lib-trn3_vollosan). endkey", vss-workfile )
  :
    define variable is-petrol           as logical   no-undo .
    define variable is-pieces           as logical   no-undo .
    define variable from_fact-order     as decimal   no-undo .
    define variable v-next-fact-order   as decimal   no-undo .
    define variable v-prev-fact-order   as decimal   no-undo .
    define variable v-next-date         as date      no-undo .
    define variable v-prev-date         as date      no-undo .
    define variable v-prev-doc          like ub.rvs-doc.rvs-code      no-undo .
    define variable v-next-time         as integer   no-undo .
    define variable v-prev-time         as integer   no-undo .
    define variable v-num-rvs           as integer   no-undo .
    define variable v-prev-rvs-doc      as character no-undo .
    define variable v-next-rvs-doc      as character no-undo .
    define variable vNeedSkip           as logical   no-undo .
    define variable ii                  as integer   no-undo .
    define variable v-max-volume-loss   as decimal   no-undo init 0.0 .
    define variable v-value             as character no-undo.
    define variable v-ok                as logical no-undo.
    define buffer buf_goods          for ub.goods .
    define buffer buf_rvs-doc        for ub.rvs-doc .
    define buffer buf_rvs-line       for ub.rvs-line .
    define buffer buf-curr_shift-obj for ub.shift-obj .
    define buffer buf-prev_shift-obj for ub.shift-obj .
    define buffer buf-prev_rvs-doc   for ub.rvs-doc .
    define buffer buf-prev_rvs-line  for ub.rvs-line .
    define buffer buf_tt-place-volume-loss for tt-place-volume-loss .
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error.
    if not available buf_goods then do:
      undo, return error substitute( "&1 (lib-trn3_avrgdens). Не найден товар &2 ", vss-workfile, p-gds-code ).
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrol
  , output is-pieces
  ) .
    if is-petrol = yes
      and is-pieces = no
    then do:
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input p-obj-type
  , input p-obj-code
  ) .
      assign
        from_fact-order = 0.0
      .
      find first buf-curr_shift-obj no-lock
        where buf-curr_shift-obj.obj-type   = p-obj-type
          and buf-curr_shift-obj.obj-code   = p-obj-code
          and buf-curr_shift-obj.shift-date = p-shift-date
          and buf-curr_shift-obj.shift-num  = p-shift-num
        no-error .
      if not available buf-curr_shift-obj then do:
        undo, return error substitute( 'lib-trn3_avrgdens: не найдена смена &1 &2 на объекте &3 &4'
                                    , p-shift-num
                                    , p-shift-date
                                    , p-obj-type
                                    , p-obj-code
                                    ) .
      end.
      find last buf-prev_shift-obj no-lock
        where buf-prev_shift-obj.obj-type   = p-obj-type
          and buf-prev_shift-obj.obj-code   = p-obj-code
          and ( ( buf-prev_shift-obj.shift-date = p-shift-date
                  and buf-prev_shift-obj.shift-num  < p-shift-num
                )
                or ( buf-prev_shift-obj.shift-date < p-shift-date
                      and buf-prev_shift-obj.shift-num  > 0
                    )
              )
        use-index pi
        no-error.
      if available buf-prev_shift-obj then do:
        find first buf-prev_rvs-doc no-lock
          where buf-prev_rvs-doc.obj-type   = buf-prev_shift-obj.obj-type
            and buf-prev_rvs-doc.obj-code   = buf-prev_shift-obj.obj-code
            and buf-prev_rvs-doc.shift-date = buf-prev_shift-obj.shift-date
            and buf-prev_rvs-doc.shift-num  = buf-prev_shift-obj.shift-num
            and buf-prev_rvs-doc.status_    = 'факт':U
            and buf-prev_rvs-doc.rvs-type   = 'смена':U
          use-index shift-type
          no-error .
        if available buf-prev_rvs-doc then do:
          find first buf-prev_rvs-line no-lock
            where buf-prev_rvs-line.rvs-code   = buf-prev_rvs-doc.rvs-code
              and buf-prev_rvs-line.obj-type   = buf-prev_rvs-doc.obj-type
              and buf-prev_rvs-line.obj-code   = buf-prev_rvs-doc.obj-code
              and buf-prev_rvs-line.pl-code    = integer(entry(1, p-pl-list))
              and buf-prev_rvs-line.gds-code   = buf_goods.gds-code
            no-error .
          if available buf-prev_rvs-line then do:
            assign
              from_fact-order = buf-prev_rvs-doc.fact-order
            .
          end.
        end.
      end.
      assign
        v-next-fact-order = ?
        v-prev-fact-order = ?
        v-next-date       = ?
        v-prev-date       = ?
        v-next-time       = 0
        v-prev-time       = 0
        v-num-rvs         = 0
        v-prev-rvs-doc    = ""
        v-next-rvs-doc    = ""
      .
      if available buf-prev_rvs-line then do:
        assign
          v-prev-date       = buf-prev_rvs-doc.sys-date
          v-prev-time       = buf-prev_rvs-doc.sys-time-int
          v-prev-fact-order = buf-prev_rvs-doc.fact-order
          v-num-rvs         = 1
        .
      end.
      do ii = 1 to num-entries(p-pl-list) :
        run CrTempDump (p-obj-type,
                        p-obj-code,
                        p-shift-date,
                        p-shift-num,
                        integer(entry(ii, p-pl-list)),
                        buf_goods.gds-code).
      end .
      rvsdoc:
      for each buf_rvs-doc no-lock
        where buf_rvs-doc.obj-type   = p-obj-type
          and buf_rvs-doc.obj-code   = p-obj-code
          and buf_rvs-doc.shift-date = p-shift-date
          and buf_rvs-doc.shift-num  = p-shift-num
          and buf_rvs-doc.status_    = 'факт':U
        ,each buf_rvs-line no-lock
        where buf_rvs-line.rvs-code   = buf_rvs-doc.rvs-code
          and buf_rvs-line.obj-type   = buf_rvs-doc.obj-type
          and buf_rvs-line.obj-code   = buf_rvs-doc.obj-code
          and buf_rvs-line.gds-code   = buf_goods.gds-code
          and can-do(p-pl-list, string(buf_rvs-line.pl-code))
        by buf_rvs-doc.fact-order
      on error undo, return error substitute( "&1 (lib-trn3_vollosan). &2 ", vss-workfile, return-value )
      :
        if buf_rvs-doc.rvs-type  = 'перед_док':U
        or buf_rvs-doc.rvs-type  = 'после_док':U
        or buf_rvs-doc.rvs-type  = 'проверка':U
          then next rvsdoc.
        assign
          v-num-rvs = v-num-rvs + 1
        .
        if buf_rvs-doc.sys-date < p-fact-date
          or ( buf_rvs-doc.sys-date = p-fact-date
              and buf_rvs-doc.sys-time-int < p-fact-time
             )
        then do:
          if v-prev-fact-order = ?
            or ( v-prev-date = ?
                and v-prev-time = 0
              )
            or v-prev-date < buf_rvs-doc.sys-date
            or ( v-prev-date = buf_rvs-doc.sys-date
                and v-prev-time < buf_rvs-doc.sys-time-int
              )
            or ( v-prev-date = buf_rvs-doc.sys-date
                and v-prev-time = buf_rvs-doc.sys-time-int
                and v-prev-fact-order < buf_rvs-doc.fact-order
              )
          then do:
             run ChkRvsSkip(buf_rvs-line.obj-type,
                            buf_rvs-line.obj-code,
                            buf_rvs-line.rvs-code,
                            buf_rvs-line.pl-code,
                            buf_rvs-line.gds-code,
                            buf_rvs-doc.sys-date,
                            buf_rvs-doc.sys-time-int,
                            output vNeedSkip).
             if vNeedSkip then .
             else
               assign
                 v-prev-date       = buf_rvs-doc.sys-date
                 v-prev-time       = buf_rvs-doc.sys-time-int
                 v-prev-fact-order = buf_rvs-doc.fact-order
                 v-prev-rvs-doc    = buf_rvs-doc.rvs-code
               .
          end.
        end.
        if buf_rvs-doc.sys-date > p-fact-date
          or ( buf_rvs-doc.sys-date = p-fact-date
              and buf_rvs-doc.sys-time-int > p-fact-time
            )
        then do:
          if v-next-fact-order = ?
            or ( v-next-date = ?
                 and v-next-time = 0
                )
            or v-next-date > buf_rvs-doc.sys-date
            or ( v-next-date = buf_rvs-doc.sys-date
                  and v-next-time > buf_rvs-doc.sys-time-int
                )
            or ( v-next-date = buf_rvs-doc.sys-date
                  and v-next-time = buf_rvs-doc.sys-time-int
                  and v-next-fact-order > buf_rvs-doc.fact-order
                )
          then do:
             run ChkRvsSkip(buf_rvs-line.obj-type,
                            buf_rvs-line.obj-code,
                            buf_rvs-line.rvs-code,
                            buf_rvs-line.pl-code,
                            buf_rvs-line.gds-code,
                            buf_rvs-doc.sys-date,
                            buf_rvs-doc.sys-time-int,
                            output vNeedSkip).
             if vNeedSkip then .
             else
               assign
                 v-next-date       = buf_rvs-doc.sys-date
                 v-next-time       = buf_rvs-doc.sys-time-int
                 v-next-fact-order = buf_rvs-doc.fact-order
                 v-next-rvs-doc    = buf_rvs-doc.rvs-code
               .
          end.
        end.
      end.
      empty temp-table ttDump.
      if v-num-rvs = 0 then do:
        undo, return error substitute( 'lib-trn3_vollosan: нет ни одной сверки за смену &1 &2 и нет сменной сверки за предыдущую смену на объекте &3 &4 по месту хранения &5'
                                      ,p-shift-num
                                      ,p-shift-date
                                      ,p-obj-type
                                      ,p-obj-code
                                      ,integer(entry(1, p-pl-list))
                                     ) .
      end.
      if v-next-rvs-doc = ""
      and v-prev-rvs-doc > ""
      then do :
        assign v-next-rvs-doc = v-prev-rvs-doc .
      end .
      if v-prev-rvs-doc = ""
      and v-next-rvs-doc > ""
      then do :
        assign v-prev-rvs-doc = v-next-rvs-doc .
      end .
      for first buf_rvs-doc no-lock where buf_rvs-doc.rvs-code = v-next-rvs-doc,
        each buf_rvs-line no-lock
        where buf_rvs-line.rvs-code   = buf_rvs-doc.rvs-code
          and buf_rvs-line.obj-type   = buf_rvs-doc.obj-type
          and buf_rvs-line.obj-code   = buf_rvs-doc.obj-code
          and buf_rvs-line.gds-code   = buf_goods.gds-code
          and can-do(p-pl-list, string(buf_rvs-line.pl-code))
      :
        create tt-place-volume-loss .
        assign
          tt-place-volume-loss.pl-code     = buf_rvs-line.pl-code
          tt-place-volume-loss.volume-loss = buf_rvs-line.state-measure-qnty
        .
      end .
      for first buf_rvs-doc no-lock where buf_rvs-doc.rvs-code = v-prev-rvs-doc,
        each buf_rvs-line no-lock
        where buf_rvs-line.rvs-code   = buf_rvs-doc.rvs-code
          and buf_rvs-line.obj-type   = buf_rvs-doc.obj-type
          and buf_rvs-line.obj-code   = buf_rvs-doc.obj-code
          and buf_rvs-line.gds-code   = buf_goods.gds-code
          and can-do(p-pl-list, string(buf_rvs-line.pl-code))
      :
        find first tt-place-volume-loss where tt-place-volume-loss.pl-code = buf_rvs-line.pl-code no-error .
        if available tt-place-volume-loss
        then do :
          assign
            tt-place-volume-loss.volume-loss = tt-place-volume-loss.volume-loss - buf_rvs-line.state-measure-qnty
          .
        end .
      end .
      for each tt-place-volume-loss :
        if tt-place-volume-loss.volume-loss > 0 then tt-place-volume-loss.volume-loss = 0 .
        if tt-place-volume-loss.volume-loss < 0 then tt-place-volume-loss.volume-loss = abs(tt-place-volume-loss.volume-loss) .
      end .
      for each tt-place-volume-loss :
        v-max-volume-loss = max(v-max-volume-loss, tt-place-volume-loss.volume-loss) .
      end .
      find tt-place-volume-loss where tt-place-volume-loss.volume-loss = v-max-volume-loss no-wait no-error .
      if ambiguous tt-place-volume-loss
      then do :
        for each tt-place-volume-loss :
          run placelib_get-attr(input "place-current"
                               ,input p-obj-code
                               ,input p-obj-type
                               ,input tt-place-volume-loss.pl-code
                               ,output v-value
                               ,output v-ok)
          no-error .
          if v-ok
          and logical(v-value)
          then do :
            p-pl-code = tt-place-volume-loss.pl-code .
            leave .
          end .
        end .
      end .
      else do :
        if available tt-place-volume-loss
        then do :
          p-pl-code = tt-place-volume-loss.pl-code .
          run placelib_write-attr (input "place-current"
                                  ,input p-obj-code
                                  ,input p-obj-type
                                  ,input p-pl-code
                                  ,input "yes"
                                  ,output v-ok      )
          no-error.
          for each buf_tt-place-volume-loss where buf_tt-place-volume-loss.pl-code <> tt-place-volume-loss.pl-code :
            run placelib_write-attr (input "place-current"
                                    ,input p-obj-code
                                    ,input p-obj-type
                                    ,input buf_tt-place-volume-loss.pl-code
                                    ,input "no"
                                    ,output v-ok      )
            no-error.
          end .
        end .
      end .
      empty temp-table tt-place-volume-loss .
    end .
  end .
end procedure .
procedure lib-trn3_avrgdens :
  define input  parameter p-gds-code   like ub.goods.gds-code        no-undo .
  define input  parameter p-obj-type   like ub.trn-doc.obj-type      no-undo .
  define input  parameter p-obj-code   like ub.trn-doc.obj-code      no-undo .
  define input  parameter p-pl-code    like ub.pl-gds.pl-code        no-undo .
  define input  parameter p-shift-date like ub.trn-doc.shift-date    no-undo .
  define input  parameter p-shift-num  like ub.trn-doc.shift-num     no-undo .
  define input  parameter p-fact-date  like ub.trn-doc.fact-date     no-undo .
  define input  parameter p-fact-time  like ub.trn-doc.fact-time     no-undo .
  define output parameter p-density    like ub.doc-line.fact-density no-undo .
  define output parameter p-Reconc-tank-attr as character no-undo .
  do
  on error  undo, return error substitute( "&1 (lib-trn3_avrgdens). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (lib-trn3_avrgdens). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (lib-trn3_avrgdens). endkey", vss-workfile )
  :
    define variable is-petrol       as logical   no-undo .
    define variable is-pieces       as logical   no-undo .
    define variable v-host-code     as integer   no-undo .
    define variable v-avrgdens      as character no-undo .
    define variable v-data-type     as character no-undo .
    define variable from_fact-order as decimal   no-undo .
    define variable v-density-acc   as decimal   no-undo .
    define variable v-num-rvs       as integer   no-undo .
    define variable v-next-fact-order      as decimal   no-undo .
    define variable v-prev-fact-order      as decimal   no-undo .
    define variable v-next-date            as date      no-undo .
    define variable v-prev-date            as date      no-undo .
    define variable v-prev-doc             like ub.rvs-doc.rvs-code      no-undo .
    define variable v-next-time            as integer   no-undo .
    define variable v-prev-time            as integer   no-undo .
    define variable v-next-density         as decimal   no-undo .
    define variable v-prev-density         as decimal   no-undo .
    define variable v-ostatok-kg           as decimal   no-undo .
    define variable v-oboroty-kg           as decimal   no-undo .
    define variable v-ostatok-lt           as decimal   no-undo .
    define variable v-oboroty-lt           as decimal   no-undo .
    define buffer buf_goods          for ub.goods .
    define buffer buf_rvs-doc        for ub.rvs-doc .
    define buffer buf_rvs-line       for ub.rvs-line .
    define buffer buf-curr_shift-obj for ub.shift-obj .
    define buffer buf-prev_shift-obj for ub.shift-obj .
    define buffer buf-prev_rvs-doc   for ub.rvs-doc .
    define buffer buf-prev_rvs-line  for ub.rvs-line .
    define buffer buf_trn-doc        for ub.trn-doc .
    define buffer buf_doc-line       for ub.doc-line .
    define buffer buf_doc-pl         for ub.doc-pl .
    define buffer buf_pl-gds         for ub.pl-gds .
    define buffer buf_doc-attr       for doc-attr.
    define variable v-attr-type            as character  no-undo.
    define variable v-gds-ptrl-densities   as character  no-undo.
    define variable v-min-dens             as   decimal  no-undo.
    define variable v-max-dens             as   decimal  no-undo.
    define variable v-delta             as   decimal  no-undo.
    define variable v-prev-rvs-doc   as character no-undo.
    define variable v-next-rvs-doc   as character no-undo.
    define variable vNeedSkip        as logical   no-undo.
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error.
    if not available buf_goods then do:
      undo, return error substitute( "&1 (lib-trn3_avrgdens). Не найден товар &2 ", vss-workfile, p-gds-code ).
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrol
  , output is-pieces
  ) .
    define variable is-vir as logical no-undo.
    define variable v-value as character no-undo.
    define variable v-ok as logical no-undo.
    define variable vAutoRvd as logical no-undo.
    run placelib_get-attr(input "place-virtual"
                         ,input p-obj-code
                         ,input p-obj-type
                         ,input p-pl-code
                         ,output v-value
                         ,output v-ok) no-error.
    is-vir = if (v-ok and logical(v-value)) then true else false.
    if is-petrol = yes
      and is-pieces = no or is-gas(buf_goods.gds-code) or is-vir
    then do:
      if buf_goods.unit-base = buf_goods.unit-cli then do:
        assign
          p-density = 1.0
        .
      end.
      if is-gas(buf_goods.gds-code) then p-density = 1 / buf_goods.cli-base-rate.
      else do:
        if is-vir then do:
            find first buf_pl-gds no-lock
              where buf_pl-gds.obj-type = p-obj-type
                and buf_pl-gds.obj-code = p-obj-code
                and buf_pl-gds.pl-code = p-pl-code
                and buf_pl-gds.gds-code = buf_goods.gds-code no-error.
            p-density = buf_pl-gds.cli-fact-qnty / buf_pl-gds.fact-qnty.
        end.
        else do:
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input p-obj-type
  , input p-obj-code
  ) .
        assign
          from_fact-order = 0.0
        .
        find first buf-curr_shift-obj no-lock
          where buf-curr_shift-obj.obj-type   = p-obj-type
            and buf-curr_shift-obj.obj-code   = p-obj-code
            and buf-curr_shift-obj.shift-date = p-shift-date
            and buf-curr_shift-obj.shift-num  = p-shift-num
          no-error .
        if not available buf-curr_shift-obj then do:
          undo, return error substitute( 'lib-trn3_avrgdens: не найдена смена &1 &2 на объекте &3 &4'
                                      , p-shift-num
                                      , p-shift-date
                                      , p-obj-type
                                      , p-obj-code
                                      ) .
        end.
        find last buf-prev_shift-obj no-lock
          where buf-prev_shift-obj.obj-type   = p-obj-type
            and buf-prev_shift-obj.obj-code   = p-obj-code
            and ( ( buf-prev_shift-obj.shift-date = p-shift-date
                    and buf-prev_shift-obj.shift-num  < p-shift-num
                  )
                  or ( buf-prev_shift-obj.shift-date < p-shift-date
                        and buf-prev_shift-obj.shift-num  > 0
                      )
                )
          use-index pi
          no-error.
        if available buf-prev_shift-obj then do:
          find first buf-prev_rvs-doc no-lock
            where buf-prev_rvs-doc.obj-type   = buf-prev_shift-obj.obj-type
              and buf-prev_rvs-doc.obj-code   = buf-prev_shift-obj.obj-code
              and buf-prev_rvs-doc.shift-date = buf-prev_shift-obj.shift-date
              and buf-prev_rvs-doc.shift-num  = buf-prev_shift-obj.shift-num
              and buf-prev_rvs-doc.status_    = 'факт':U
              and buf-prev_rvs-doc.rvs-type   = 'смена':U
            use-index shift-type
            no-error .
          if available buf-prev_rvs-doc then do:
            find first buf-prev_rvs-line no-lock
              where buf-prev_rvs-line.rvs-code   = buf-prev_rvs-doc.rvs-code
                and buf-prev_rvs-line.obj-type   = buf-prev_rvs-doc.obj-type
                and buf-prev_rvs-line.obj-code   = buf-prev_rvs-doc.obj-code
                and buf-prev_rvs-line.pl-code    = p-pl-code
                and buf-prev_rvs-line.gds-code   = buf_goods.gds-code
              no-error .
            if available buf-prev_rvs-line then do:
              assign
                from_fact-order = buf-prev_rvs-doc.fact-order
              .
            end.
          end.
        end.
        case ptrlprop-denstclc :
          when 'avrg-chk':U then do:
            assign
              v-next-fact-order = ?
              v-prev-fact-order = ?
              v-next-date       = ?
              v-prev-date       = ?
              v-next-time       = 0
              v-prev-time       = 0
              v-next-density    = ?
              v-prev-density    = ?
              v-num-rvs         = 0
              v-prev-rvs-doc    = ""
              v-next-rvs-doc    = ""
            .
            if available buf-prev_rvs-line then do:
              assign
                v-prev-date       = buf-prev_rvs-doc.sys-date
                v-prev-time       = buf-prev_rvs-doc.sys-time-int
                v-prev-density    = buf-prev_rvs-line.state-density
                v-prev-fact-order = buf-prev_rvs-doc.fact-order
                v-prev-rvs-doc    = buf-prev_rvs-doc.rvs-code
                v-num-rvs         = 1
              .
            end.
            run CrTempDump (p-obj-type,
                            p-obj-code,
                            p-shift-date,
                            p-shift-num,
                            p-pl-code,
                            buf_goods.gds-code).
            rvsdoc:
            for each buf_rvs-doc no-lock
              where buf_rvs-doc.obj-type   = p-obj-type
                and buf_rvs-doc.obj-code   = p-obj-code
                and buf_rvs-doc.shift-date = p-shift-date
                and buf_rvs-doc.shift-num  = p-shift-num
                and buf_rvs-doc.status_    = 'факт':U
              ,first buf_rvs-line no-lock
              where buf_rvs-line.rvs-code   = buf_rvs-doc.rvs-code
                and buf_rvs-line.obj-type   = buf_rvs-doc.obj-type
                and buf_rvs-line.obj-code   = buf_rvs-doc.obj-code
                and buf_rvs-line.pl-code    = p-pl-code
                and buf_rvs-line.gds-code   = buf_goods.gds-code
              by buf_rvs-doc.fact-order
            on error undo, return error substitute( "&1 (lib-trn3_avrgdens). &2 ", vss-workfile, return-value )
            :
              if buf_rvs-doc.rvs-type  = 'перед_док':U
              or buf_rvs-doc.rvs-type  = 'после_док':U
              or buf_rvs-doc.rvs-type  = 'проверка':U
                then next rvsdoc.
              assign
                v-num-rvs = v-num-rvs + 1
              .
              if buf_rvs-doc.sys-date < p-fact-date
                or ( buf_rvs-doc.sys-date = p-fact-date
                    and buf_rvs-doc.sys-time-int < p-fact-time
                   )
              then do:
                if v-prev-fact-order = ?
                  or ( v-prev-date = ?
                      and v-prev-time = 0
                    )
                  or v-prev-date < buf_rvs-doc.sys-date
                  or ( v-prev-date = buf_rvs-doc.sys-date
                      and v-prev-time < buf_rvs-doc.sys-time-int
                    )
                  or ( v-prev-date = buf_rvs-doc.sys-date
                      and v-prev-time = buf_rvs-doc.sys-time-int
                      and v-prev-fact-order < buf_rvs-doc.fact-order
                    )
                then do:
                   run ChkRvsSkip(buf_rvs-line.obj-type,
                                  buf_rvs-line.obj-code,
                                  buf_rvs-line.rvs-code,
                                  buf_rvs-line.pl-code,
                                  buf_rvs-line.gds-code,
                                  buf_rvs-doc.sys-date,
                                  buf_rvs-doc.sys-time-int,
                                  output vNeedSkip).
                   if vNeedSkip then .
                   else
                     assign
                       v-prev-date       = buf_rvs-doc.sys-date
                       v-prev-time       = buf_rvs-doc.sys-time-int
                       v-prev-density    = buf_rvs-line.state-density
                       v-prev-fact-order = buf_rvs-doc.fact-order
                       v-prev-rvs-doc    = buf_rvs-doc.rvs-code
                     .
                end.
              end.
              if buf_rvs-doc.sys-date > p-fact-date
                or ( buf_rvs-doc.sys-date = p-fact-date
                    and buf_rvs-doc.sys-time-int > p-fact-time
                  )
              then do:
                if v-next-fact-order = ?
                  or ( v-next-date = ?
                       and v-next-time = 0
                      )
                  or v-next-date > buf_rvs-doc.sys-date
                  or ( v-next-date = buf_rvs-doc.sys-date
                        and v-next-time > buf_rvs-doc.sys-time-int
                      )
                  or ( v-next-date = buf_rvs-doc.sys-date
                        and v-next-time = buf_rvs-doc.sys-time-int
                        and v-next-fact-order > buf_rvs-doc.fact-order
                      )
                then do:
                   run ChkRvsSkip(buf_rvs-line.obj-type,
                                  buf_rvs-line.obj-code,
                                  buf_rvs-line.rvs-code,
                                  buf_rvs-line.pl-code,
                                  buf_rvs-line.gds-code,
                                  buf_rvs-doc.sys-date,
                                  buf_rvs-doc.sys-time-int,
                                  output vNeedSkip).
                   if vNeedSkip then .
                   else
                     assign
                       v-next-date       = buf_rvs-doc.sys-date
                       v-next-time       = buf_rvs-doc.sys-time-int
                       v-next-density    = buf_rvs-line.state-density
                       v-next-fact-order = buf_rvs-doc.fact-order
                       v-next-rvs-doc    = buf_rvs-doc.rvs-code
                     .
                end.
              end.
            end.
            empty temp-table ttDump.
            if session:debug-alert
            then do:
             OUTPUT STREAM out_s TO "avrgdens.log" APPEND.
               put stream out_s unformatted "Расчет средней плотности чека. Время чека: "
               datetime(p-fact-date, (p-fact-time * 1000 ))
               " Сверка до " v-prev-rvs-doc
               " Время " datetime(v-prev-date, (v-prev-time * 1000 ))
               " Плотность " v-prev-density
               " Сверка после " v-next-rvs-doc
               " Время " datetime(v-next-date, (v-next-time * 1000 ))
               " Плотность " v-next-density
               skip.
               OUTPUT STREAM out_s CLOSE.
            end.
            if v-num-rvs = 0 then do:
              undo, return error substitute( 'lib-trn3_avrgdens: нет ни одной сверки за смену &1 &2 и нет сменной сверки за предыдущую смену на объекте &3 &4 по месту хранения &5'
                                            ,p-shift-num
                                            ,p-shift-date
                                            ,p-obj-type
                                            ,p-obj-code
                                            ,p-pl-code
                                           ) .
            end.
            if v-prev-density = ?
              and v-next-density <> ?
            then do:
              assign
                v-prev-density = v-next-density
              .
            end.
            if v-next-density = ?
              and v-prev-density <> ?
            then do:
              assign
                v-next-density = v-prev-density
              .
            end.
            assign
              p-density = ( v-next-density + v-prev-density ) / 2.0
              p-Reconc-tank-attr = v-prev-rvs-doc + "," + v-next-rvs-doc + "," + string(p-pl-code)
            .
          end.
          when 'avrg-rvs':U then do:
            if available buf-prev_rvs-line then do:
              assign
                v-density-acc = buf-prev_rvs-line.state-density
                v-num-rvs     = 1
              .
            end.
            else do:
              assign
                v-density-acc = 0.0
                v-num-rvs     = 0
              .
            end.
            for each buf_rvs-doc no-lock
              where buf_rvs-doc.obj-type   = p-obj-type
                and buf_rvs-doc.obj-code   = p-obj-code
                and buf_rvs-doc.shift-date = p-shift-date
                and buf_rvs-doc.shift-num  = p-shift-num
                and buf_rvs-doc.status_    = 'факт':U
              ,first buf_rvs-line no-lock
              where buf_rvs-line.rvs-code   = buf_rvs-doc.rvs-code
                and buf_rvs-line.obj-type   = buf_rvs-doc.obj-type
                and buf_rvs-line.obj-code   = buf_rvs-doc.obj-code
                and buf_rvs-line.pl-code    = p-pl-code
                and buf_rvs-line.gds-code   = buf_goods.gds-code
              by buf_rvs-doc.fact-order
            on error undo, return error substitute( "&1 (lib-trn3_avrgdens). &2 ", vss-workfile, return-value )
            :
              if buf_rvs-doc.rvs-type = 'проверка':U then next .
              if buf_rvs-line.state-density <> ?
                and buf_rvs-doc.rvs-type <> 'смена':U
              then do:
                assign
                  v-density-acc = v-density-acc + buf_rvs-line.state-density
                  v-num-rvs     = v-num-rvs + 1
                .
              end.
            end.
            if v-num-rvs = 0 then do:
              undo, return error substitute( 'lib-trn3_avrgdens: нет ни одной сверки за смену &1 &2 и нет сменной сверки за предыдущую смену на объекте &3 &4 по месту хранения &5'
                                            ,p-shift-num
                                            ,p-shift-date
                                            ,p-obj-type
                                            ,p-obj-code
                                            ,p-pl-code
                                           ) .
            end.
            assign
              p-density = v-density-acc / v-num-rvs
            .
          end.
          when 'shft_rvs-inc':U then do:
            assign
              v-ostatok-lt    = 0.0
              v-oboroty-lt    = 0.0
              v-ostatok-kg    = 0.0
              v-oboroty-kg    = 0.0
            .
            if available buf-prev_rvs-doc then do:
              find first buf_rvs-line no-lock
                where buf_rvs-line.rvs-code = buf-prev_rvs-doc.rvs-code
                  and buf_rvs-line.obj-type = buf-prev_rvs-doc.obj-type
                  and buf_rvs-line.obj-code = buf-prev_rvs-doc.obj-code
                  and buf_rvs-line.pl-code  = p-pl-code
                  and buf_rvs-line.gds-code = buf_goods.gds-code
                no-error .
              if available buf_rvs-line then do:
                assign
                  v-ostatok-lt = buf_rvs-line.state-measure-qnty
                  v-ostatok-kg = buf_rvs-line.state-measure-cli-qnty
                .
              end.
            end.
            for each buf_trn-doc no-lock
              where buf_trn-doc.obj-type   = p-obj-type
                and buf_trn-doc.obj-code   = p-obj-code
                and buf_trn-doc.shift-date = p-shift-date
                and buf_trn-doc.shift-num  = p-shift-num
                and buf_trn-doc.status_    = 'факт':U
              ,each buf_doc-line no-lock
              where buf_doc-line.doc-code     = buf_trn-doc.doc-code
                and buf_doc-line.artic        = buf_goods.artic
                and buf_doc-line.prod-type    = buf_goods.prod-type
                and buf_doc-line.prod-code    = buf_goods.prod-code
                and buf_doc-line.ext-doc-type = 'ie':U
            on error undo, return error substitute( "&1 (lib-trn3_avrgdens). &2 ", vss-workfile, return-value )
            :
              find first buf_doc-pl no-lock
                where buf_doc-pl.obj-type = buf_doc-line.obj-type
                  and buf_doc-pl.obj-code = buf_doc-line.obj-code
                  and buf_doc-pl.pl-code  = p-pl-code
                  and buf_doc-pl.out-code = buf_doc-line.doc-code
                  and buf_doc-pl.gds-code = buf_goods.gds-code
                no-error.
              if available buf_doc-pl
                and buf_doc-pl.fact-qnty <> ?
                and buf_doc-pl.cli-fact-qnty <> ?
              then do:
                assign
                  v-oboroty-lt = v-oboroty-lt + buf_doc-pl.fact-qnty
                  v-oboroty-kg = v-oboroty-kg + buf_doc-pl.cli-fact-qnty
                .
              end.
            end.
            if v-ostatok-kg + v-oboroty-kg = 0 or ( v-ostatok-lt + v-oboroty-lt ) = 0 and available buf_rvs-line  then
            assign p-density = buf_rvs-line.state-density.
            else assign
              p-density = abs( ( v-ostatok-kg + v-oboroty-kg ) / ( v-ostatok-lt + v-oboroty-lt ) )
            .
          end.
          when 'shft_sys-inc':U then do:
            assign
              v-ostatok-lt    = 0.0
              v-oboroty-lt    = 0.0
              v-ostatok-kg    = 0.0
              v-oboroty-kg    = 0.0
            .
            if available buf-prev_rvs-doc then do:
              find first buf_rvs-line no-lock
                where buf_rvs-line.rvs-code = buf-prev_rvs-doc.rvs-code
                  and buf_rvs-line.obj-type = buf-prev_rvs-doc.obj-type
                  and buf_rvs-line.obj-code = buf-prev_rvs-doc.obj-code
                  and buf_rvs-line.pl-code  = p-pl-code
                  and buf_rvs-line.gds-code = buf_goods.gds-code
                no-error .
              if available buf_rvs-line then do:
                assign
                  v-ostatok-lt = buf_rvs-line.system-qnty
                  v-ostatok-kg = buf_rvs-line.system-cli-qnty
                .
              end.
            end.
            for each buf_trn-doc no-lock
              where buf_trn-doc.obj-type   = p-obj-type
                and buf_trn-doc.obj-code   = p-obj-code
                and buf_trn-doc.shift-date = p-shift-date
                and buf_trn-doc.shift-num  = p-shift-num
                and buf_trn-doc.status_    = 'факт':U
              ,each buf_doc-line no-lock
              where buf_doc-line.doc-code     = buf_trn-doc.doc-code
                and buf_doc-line.artic        = buf_goods.artic
                and buf_doc-line.prod-type    = buf_goods.prod-type
                and buf_doc-line.prod-code    = buf_goods.prod-code
                and buf_doc-line.ext-doc-type = 'ie':U
            on error undo, return error substitute( "&1 (lib-trn3_avrgdens). &2 ", vss-workfile, return-value )
            :
              find first buf_doc-pl no-lock
                where buf_doc-pl.obj-type = buf_doc-line.obj-type
                  and buf_doc-pl.obj-code = buf_doc-line.obj-code
                  and buf_doc-pl.pl-code  = p-pl-code
                  and buf_doc-pl.out-code = buf_doc-line.doc-code
                  and buf_doc-pl.gds-code = buf_goods.gds-code
                no-error.
              if available buf_doc-pl
                and buf_doc-pl.fact-qnty <> ?
                and buf_doc-pl.cli-fact-qnty <> ?
              then do:
                assign
                  v-oboroty-lt = v-oboroty-lt + buf_doc-pl.fact-qnty
                  v-oboroty-kg = v-oboroty-kg + buf_doc-pl.cli-fact-qnty
                .
              end.
            end.
            if v-ostatok-kg + v-oboroty-kg = 0 or ( v-ostatok-lt + v-oboroty-lt ) = 0 and available buf_rvs-line  then
            assign p-density = buf_rvs-line.state-density.
            else assign
              p-density = abs( ( v-ostatok-kg + v-oboroty-kg ) / ( v-ostatok-lt + v-oboroty-lt ) )
            .
          end.
          when "fact-approx" then do:
              v-min-dens = 0.1.
              v-max-dens = 0.9.
              find last  buf_rvs-doc no-lock
              where buf_rvs-doc.obj-type   = p-obj-type
                and buf_rvs-doc.obj-code   = p-obj-code
                and buf_rvs-doc.shift-date = p-shift-date
                and buf_rvs-doc.shift-num  = p-shift-num
                and buf_rvs-doc.status_    = 'факт':U
                and buf_rvs-doc.rvs-type  = 'контроль':U no-error.
              if available buf_rvs-doc then    v-prev-doc = buf_rvs-doc.rvs-code .
              else  undo, return error substitute( 'lib-trn3_avrgdens: Нет ни одной контрольной сверки в текущей смене.'
                                                                                   ) .
              for first buf_rvs-line no-lock
              where buf_rvs-line.rvs-code   =  v-prev-doc
                and buf_rvs-line.obj-type   = p-obj-type
                and buf_rvs-line.obj-code   = p-obj-code
                and buf_rvs-line.pl-code    = p-pl-code
                and buf_rvs-line.gds-code   = buf_goods.gds-code
              by buf_rvs-doc.fact-order
            on error undo, return error substitute( "&1 (lib-trn3_avrgdens). &2 ", vss-workfile, return-value )
            :
                p-density = abs ((buf_rvs-line.system-cli-qnty  - buf_rvs-line.state-measure-cli-qnty) / (buf_rvs-line.system-qnty - buf_rvs-line.state-measure-qnty)).
                   run gds-attr-value in this-procedure
                   ( input  buf_goods.gds-code
                    ,input  'gds-ptrl-densities':U
                    ,output v-gds-ptrl-densities
                    ,output v-attr-type
                   ) .
                   if v-gds-ptrl-densities <> "" and v-gds-ptrl-densities <> ? then do:
                      assign
                        v-min-dens = decimal(replace(entry(1, v-gds-ptrl-densities, "-":U ), "кг\л", "":U))
                        v-max-dens = decimal(replace(entry(2, v-gds-ptrl-densities, "-":U ), "кг\л":U, "":U))
                      no-error .
                   end.
                if p-density = ? then p-density =  buf_rvs-line.state-density.
                if  p-density >  v-max-dens then p-density = v-max-dens .
                if  p-density <  v-min-dens then p-density = v-min-dens .
            end.
          end.
          otherwise do:
            undo, return error substitute( 'lib-trn3_avrgdens: нет описания алгоритма определения плотности &1'
                                          , ptrlprop-denstclc
                                         ) .
          end.
        end case.
        if
  valid-density( p-density, buf_goods.unit-base = buf_goods.unit-cli )
  <> true then do:
          undo, return error substitute( 'lib-trn3_avrgdens: нет возможности определить плотность для товара "&1" (&2) на объекте &3 &4 за смену &5 &6 по алгоритму &7'
                                      , buf_goods.gds-name
                                      , buf_goods.gds-code
                                      , p-obj-type
                                      , p-obj-code
                                      , p-shift-num
                                      , p-shift-date
                                      , ptrlprop-denstclc
                                      ) .
        end.
      end.
      end.
    end.
  end.
end procedure.
procedure lib-trn3_check-pair:
define input parameter pardoc-code  like ub.trn-doc.doc-code no-undo.
define input parameter parcurdb-num as   integer             no-undo.
define variable varhold      as character no-undo.
define variable varhold-type as character no-undo.
define variable varhold-doc  as character no-undo.
define buffer bf_trn-doc        for ub.trn-doc.
define buffer bf-child_trn-doc  for ub.trn-doc.
define buffer bf-parent_trn-doc for ub.trn-doc.
define buffer bf_clients        for ub.clients.
define buffer bf_doc-line       for ub.doc-line.
define buffer bf-contr_clients  for ub.clients.
do on error undo, return error return-value :
  find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
  if not available bf_trn-doc then do:
    return error substitute ("Не найден документ с номером &1.", bf_trn-doc.doc-code).
  end.
  find first bf_clients where bf_clients.obj-type = bf_trn-doc.obj-type and
                              bf_clients.obj-code = bf_trn-doc.obj-code no-lock.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'holding':u
  ,input  0
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varhold
  ,output varhold-type
  ) no-error .
  if varhold = "yes":u then do:
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  bf_trn-doc.doc-code
  ,output varhold-doc
  )  .
  end.
  case bf_trn-doc.ext-doc-type:
    when 'ev':U then do:
      find first bf-contr_clients where bf-contr_clients.obj-type = bf_trn-doc.cli-type and
                                        bf-contr_clients.obj-code = bf_trn-doc.cli-code no-lock.
      if parcurdb-num       = 0                       or
         bf_clients.db-num  = bf-contr_clients.db-num then do:
        if bf_trn-doc.status_ = 'факт':U then do:
          find first bf-child_trn-doc where bf-child_trn-doc.out-code = bf_trn-doc.doc-code no-lock no-error.
          if not available bf-child_trn-doc then do:
            return error substitute ("Документ &1 внутреннего расхода закрыт до факта. По нему не найдено документа внутреннего прихода.", bf_trn-doc.doc-code).
          end.
          if bf-child_trn-doc.ext-doc-type <> 'iv':U then do:
            return error substitute ("Документ &1 внутреннего расхода закрыт до факта. Связанный с ним документ &2 не является документом внутреннего прихода.", bf_trn-doc.doc-code, bf-child_trn-doc.doc-code).
          end.
        end.
      end.
    end.
    when 'iv':U then do:
      find first bf-contr_clients where bf-contr_clients.obj-type = bf_trn-doc.cli-type and
                                        bf-contr_clients.obj-code = bf_trn-doc.cli-code no-lock.
      if parcurdb-num       = 0                       or
         bf_clients.db-num  = bf-contr_clients.db-num then do:
        find first bf-parent_trn-doc where bf-parent_trn-doc.doc-code = bf_trn-doc.out-code no-lock no-error.
        if not available bf-parent_trn-doc then do:
          return error substitute ("Документ &1 внутреннего прихода со ссылкой на внутренний расход &2. Внутренний расход не найден.", bf_trn-doc.doc-code, bf_trn-doc.out-code).
        end.
        if bf-parent_trn-doc.ext-doc-type <> 'ev':U then do:
          return error substitute ("Документ &1 внутреннего прихода. Родительский документ &2 не является документом внутреннего расхода.", bf_trn-doc.doc-code, bf-parent_trn-doc.doc-code).
        end.
        if bf_trn-doc.status_ = 'факт':U then do:
          find first bf_doc-line where bf_doc-line.doc-code  = bf_trn-doc.doc-code  and
                                       bf_doc-line.fact-qnty < bf_doc-line.doc-qnty no-lock no-error.
          if available bf_doc-line then do:
            find first bf-child_trn-doc where bf-child_trn-doc.out-code = bf_trn-doc.doc-code no-lock no-error.
            if not available bf-child_trn-doc then do:
              return error substitute ("Документ &1 внутреннего прихода закрыт до факта. По нему не найдено документа внутреннего возврата.", bf_trn-doc.doc-code).
            end.
            if bf-child_trn-doc.ext-doc-type <> 'rv':U then do:
              return error substitute ("Документ &1 внутреннего прихода закрыт до факта. Связанный с ним документ &2 не является документом внутреннего возврата.", bf_trn-doc.doc-code, bf-child_trn-doc.doc-code).
            end.
          end.
        end.
      end.
    end.
    when 'rv':U then do:
      find first bf-contr_clients where bf-contr_clients.obj-type = bf_trn-doc.cli-type and
                                        bf-contr_clients.obj-code = bf_trn-doc.cli-code no-lock.
      if parcurdb-num       = 0                       or
         bf_clients.db-num  = bf-contr_clients.db-num then do:
        find first bf-parent_trn-doc where bf-parent_trn-doc.doc-code = bf_trn-doc.out-code no-lock no-error.
        if not available bf-parent_trn-doc then do:
          return error substitute ("Документ &1 внутреннего возврата с ссылкой на внутренний приход &2. Внутренний приход не найден.", bf_trn-doc.doc-code, bf_trn-doc.out-code).
        end.
        if bf-parent_trn-doc.ext-doc-type <> 'iv':U then do:
          return error substitute ("Документ &1 внутреннего возврата. Родительский документ &2 не является документом внутреннего прихода.", bf_trn-doc.doc-code, bf-parent_trn-doc.doc-code).
        end.
      end.
    end.
    when 'ee':U then do:
      if varhold-doc = "yes":u then do:
        find first bf-contr_clients where bf-contr_clients.obj-type = bf_trn-doc.hold-obj-type and
                                          bf-contr_clients.obj-code = bf_trn-doc.hold-obj-code no-lock.
        if parcurdb-num       = 0                       or
           bf_clients.db-num  = bf-contr_clients.db-num then do:
          find first bf-child_trn-doc where bf-child_trn-doc.hold-doc-code-parent = bf_trn-doc.doc-code no-lock no-error.
        end.
      end.
    end.
    when 'ie':U then do:
      if varhold-doc = "yes":u then do:
        find first bf-contr_clients where bf-contr_clients.obj-type = bf_trn-doc.hold-obj-type and
                                          bf-contr_clients.obj-code = bf_trn-doc.hold-obj-code no-lock.
        if parcurdb-num       = 0                       or
           bf_clients.db-num  = bf-contr_clients.db-num then do:
        end.
      end.
    end.
    when 're':U then do:
      if varhold-doc = "yes":u then do:
        find first bf-contr_clients where bf-contr_clients.obj-type = bf_trn-doc.hold-obj-type and
                                          bf-contr_clients.obj-code = bf_trn-doc.hold-obj-code no-lock.
        if parcurdb-num       = 0                       or
           bf_clients.db-num  = bf-contr_clients.db-num then do:
        end.
      end.
    end.
    when 'ep':U then do:
      if varhold-doc = "yes":u then do:
        find first bf-contr_clients where bf-contr_clients.obj-type = bf_trn-doc.hold-obj-type and
                                          bf-contr_clients.obj-code = bf_trn-doc.hold-obj-code no-lock.
        if parcurdb-num       = 0                       or
           bf_clients.db-num  = bf-contr_clients.db-num then do:
        end.
      end.
    end.
  end case.
end.
end procedure.
procedure lib-trn3_chklinst :
  define  input parameter parhandle   as   handle              no-undo .
  define  input parameter pardoc-code like ub.trn-doc.doc-code no-undo .
  define  input parameter parstatus   as   character           no-undo .
  define output parameter parfact-ok  as   logical             no-undo .
  define variable is-err-unit                as   logical              no-undo .
  define variable clspl-code                 like ub.place.pl-code     no-undo .
  define variable varparts-total-doc-qnty    like ub.parts.qnty        no-undo .
  define variable varparts-total-fact-qnty   like ub.parts.fact-qnty   no-undo .
  define variable vargds-dtl-total-doc-qnty  like ub.gds-dtl.doc-qnty  no-undo .
  define variable vargds-dtl-total-fact-qnty like ub.gds-dtl.fact-qnty no-undo .
  define buffer bf_trn-doc  for ub.trn-doc .
  define buffer bf_doc-line for ub.doc-line .
  define buffer bf_goods    for ub.goods .
  define buffer bf_gds-dtl  for ub.gds-dtl .
  define buffer bf_parts    for ub.parts .
  define buffer bfe_parts   for ub.parts .
  do
  on error undo, return error return-value
  :
    assign
      parfact-ok = yes
    .
    find first bf_trn-doc no-lock where
               bf_trn-doc.doc-code = pardoc-code .
    for each  bf_doc-line where
              bf_doc-line.doc-code = pardoc-code
      , first bf_goods no-lock where
              bf_goods.artic     = bf_doc-line.artic     and
              bf_goods.prod-code = bf_doc-line.prod-code and
              bf_goods.prod-type = bf_doc-line.prod-type
    on error undo, return error return-value
    :
      run str/ck-uncli.p
        (
           input bf_doc-line.unit-cli
        ,  input bf_goods.gds-code
        ,  input bf_trn-doc.obj-type
        ,  input bf_trn-doc.obj-code
        ,  input bf_trn-doc.hold-doc-code-parent
        ,  input bf_trn-doc.hold-doc-code-child
        , output is-err-unit
        ) .
      if is-err-unit = yes
      then do:
        run waitfram-hide in parhandle no-error .
        undo, return error substitute( "Ошибочная единица измерения поставщика <<&1>> товара &2 &3 &4 или "
                                     + "нельзя изменять единицу измерения поставщика на данном объекте."
                                     , bf_doc-line.unit-cli
                                     , bf_goods.artic
                                     , bf_goods.prod-type
                                     , bf_goods.prod-code
                                     ) .
      end.
      assign
        vargds-dtl-total-doc-qnty  = 0
        vargds-dtl-total-fact-qnty = 0
      .
      for each bf_gds-dtl where
               bf_gds-dtl.prod-type = bf_doc-line.prod-type and
               bf_gds-dtl.prod-code = bf_doc-line.prod-code and
               bf_gds-dtl.artic     = bf_doc-line.artic     and
               bf_gds-dtl.doc-code  = bf_trn-doc.doc-code
      on error undo, return error return-value
      :
        if bf_gds-dtl.doc-qnty <> bf_gds-dtl.fact-qnty
        then do:
          assign
            parfact-ok = no
          .
        end.
        assign
          vargds-dtl-total-doc-qnty  = vargds-dtl-total-doc-qnty  + bf_gds-dtl.doc-qnty
          vargds-dtl-total-fact-qnty = vargds-dtl-total-fact-qnty + bf_gds-dtl.fact-qnty
        .
      end.
      assign
        varparts-total-doc-qnty  = 0
        varparts-total-fact-qnty = 0
      .
      assign
        varparts-total-doc-qnty  = 0
        varparts-total-fact-qnty = 0
      .
      for each bfe_parts where
               bfe_parts.out-code  = bf_trn-doc.doc-code   and
               bfe_parts.obj-type  = bf_trn-doc.obj-type   and
               bfe_parts.obj-code  = bf_trn-doc.obj-code   and
               bfe_parts.prod-type = bf_doc-line.prod-type and
               bfe_parts.prod-code = bf_doc-line.prod-code and
               bfe_parts.artic     = bf_doc-line.artic
      on error undo, return error return-value
      :
        if bfe_parts.qnty <> bfe_parts.fact-qnty
        then do:
          assign
            parfact-ok = no
          .
        end.
        assign
          varparts-total-doc-qnty  = varparts-total-doc-qnty  + bfe_parts.qnty
          varparts-total-fact-qnty = varparts-total-fact-qnty + bfe_parts.fact-qnty
        .
      end.
      if parstatus               <> 'факт':U                                      and
         varparts-total-doc-qnty <> bf_doc-line.doc-qnty                         and
         varparts-total-doc-qnty <> 0
      then do:
        run waitfram-hide in parhandle no-error .
        undo, return error substitute( "Артикул : &1 &2 &3 &4 По всем партиям : &5 &6."
                                     , bf_doc-line.artic
                                     , bf_goods.gds-name
                                     , bf_doc-line.doc-qnty
                                     , bf_goods.unit-base
                                     , varparts-total-doc-qnty
                                     , bf_goods.unit-base
                                     ) .
      end.
      if parstatus = 'факт':U and
         varparts-total-fact-qnty <> bf_doc-line.fact-qnty
      then do:
        run waitfram-hide in parhandle no-error .
        undo, return error substitute( "Неправильно заполнены ПАРТИИ. Артикул : &1 &2 &3 &4 . По всем партиям : &5 &6. "
                                     + "Эти количества должны совпадать !"
                                     , bf_doc-line.artic
                                     , bf_goods.gds-name
                                     , bf_doc-line.fact-qnty
                                     , bf_goods.unit-base
                                     , varparts-total-fact-qnty
                                     , bf_goods.unit-base
                                     ) .
      end.
      if parstatus          <> 'факт':U and
         bf_doc-line.prt-OK <> ?       and
         vargds-dtl-total-doc-qnty <> bf_doc-line.doc-qnty
      then do:
        run waitfram-hide in parhandle no-error .
        undo, return error substitute( "Неправильно заполнены количества ПО ШКАЛЕ." + chr(10)
                                     + " Артикул : &1 &2 &3 &4"                     + chr(10)
                                     + "По всем признакам : &5 &6. Эти количества должны совпадать ! "
                                     , bf_doc-line.artic
                                     , bf_goods.gds-name
                                     , bf_doc-line.doc-qnty
                                     , bf_goods.unit-base
                                     , vargds-dtl-total-doc-qnty
                                     , bf_goods.unit-base
                                     ) .
      end.
      if parstatus                  = 'факт':U                and
         vargds-dtl-total-fact-qnty <> bf_doc-line.fact-qnty
      then do:
        run waitfram-hide in parhandle no-error .
        undo, return error substitute( "Неправильно заполнены количества ПО ШКАЛЕ. Артикул : &1 &2 &3 &4 "
                                     + "По всем признакам : &5 &6. Эти количества должны совпадать !"
                                     , bf_doc-line.artic
                                     , bf_goods.gds-name
                                     , bf_doc-line.fact-qnty
                                     , bf_goods.unit-base
                                     , vargds-dtl-total-fact-qnty
                                     , bf_goods.unit-base
                                     ) .
      end.
    end.
  end.
end procedure.
define temp-table tt-dis-rule no-undo
field doc-qnty     like ub.dis-rule.doc-qnty
field discnt-value like ub.dis-rule.discnt-value
index pi is unique primary doc-qnty.
procedure lib-trn3_set-pr :
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
define input parameter parrec-dtl         as recid     no-undo.
define input parameter paruse-discnt-qnty as logical   no-undo.
define input parameter pardiscnt-qnty     as decimal   no-undo.
define buffer sp_gds-dtl          for ub.gds-dtl .
define buffer sp_trn-doc          for ub.trn-doc .
define buffer sp_doc-line         for ub.doc-line.
define buffer sp_shop             for ub.shop        .
define buffer sp_goods            for ub.goods       .
define buffer sp_gds-obj-attr     for ub.gds-obj-attr.
define buffer sp-parent_dis-rule  for ub.dis-rule.
define buffer sp-child_dis-rule   for ub.dis-rule.
define buffer sp_tt-dis-rule      for tt-dis-rule.
define buffer sp-prev_tt-dis-rule for tt-dis-rule.
define buffer buf_dis-gds-rule    for ub.dis-gds-rule.
define variable varr-b               as character no-undo.
define variable varis-perm           as logical initial no no-undo.
define variable varprice-target      as character no-undo.
define variable varprice-target-type as character no-undo.
define variable vartype              as character no-undo.
define variable varhave-qnty-discnt  as logical   no-undo.
define variable  v-main-b-code  as integer   no-undo .
define variable  v-sum-doc      as decimal   no-undo .
define variable  v-fact-order   as decimal   no-undo .
define variable  v-plt-id        as integer   no-undo .
define variable  v-plt-db-num    as integer   no-undo .
define variable  v-pdf-id        as integer   no-undo .
define variable  v-pdf-db-num    as integer   no-undo .
define variable  v-sale-price-base  as decimal   no-undo .
define variable  v-sale-price-rubl  as decimal   no-undo .
define variable  v-road-tax-base    as decimal   no-undo .
define variable  v-road-tax-rubl    as decimal   no-undo .
define variable  v-excise-base      as decimal   no-undo .
define variable  v-excise-rubl      as decimal   no-undo .
do on error undo, return error return-value :
assign
  varhave-qnty-discnt = no.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
find first sp_gds-dtl where recid(sp_gds-dtl)   =  parrec-dtl.
find first sp_trn-doc where sp_trn-doc.doc-code = sp_gds-dtl.doc-code.
find first sp_doc-line where sp_doc-line.doc-code   = sp_gds-dtl.doc-code  and
                             sp_doc-line.artic      = sp_gds-dtl.artic     and
                             sp_doc-line.prod-type  = sp_gds-dtl.prod-type and
                             sp_doc-line.prod-code  = sp_gds-dtl.prod-code .
find first sp_goods   where sp_goods.artic      = sp_gds-dtl.artic     and
                            sp_goods.prod-type  = sp_gds-dtl.prod-type and
                            sp_goods.prod-code  = sp_gds-dtl.prod-code .
if ((sp_trn-doc.status_ = 'накл':U or
     sp_trn-doc.status_ = 'разрешен':U) and
     lookup (sp_trn-doc.doc-type, 'рас,спи,возврат':U) > 0 )
     or ( sp_trn-doc.status_ = 'запрос':U )
     or ( sp_trn-doc.status_ = 'разрешен':U and sp_trn-doc.doc-type = 'инв':U )
     then do:
  if sp_trn-doc.ret-supp = no         and
     not sp_gds-dtl.ov                and
     sp_trn-doc.internal              and
     sp_trn-doc.doc-type = 'рас':U and
     sp_trn-doc.status_  = 'накл':U    and
     not sp_trn-doc.flag              then do:
     if sp_trn-doc.cli-type = 'маг':U    then do:
       find sp_shop where sp_shop.obj-code = sp_trn-doc.cli-code no-lock.
       assign
         varis-perm = sp_shop.in-perm.
     end.
     if varis-perm = no then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input sp_trn-doc.doc-code ,
                        input 'price-target':U ,
                       output varprice-target ,
                       output varprice-target-type )  .
       if varprice-target = "yes":u then do:
         assign
           varis-perm = yes.
       end.
     end.
     if varis-perm then do:
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  sp_goods.gds-code
  ,input  sp_gds-dtl.prt-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  sp_trn-doc.cli-type
  ,input  sp_trn-doc.cli-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  sp_trn-doc.cli-type
  ,input  sp_trn-doc.cli-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
       if gp-price-sale <> ? then do:
         if varr-b = "rubl":u then do:
           assign
             sp_gds-dtl.price-rubl = gp-price-sale.
         end.
         else do:
           assign
             sp_gds-dtl.price-base = gp-price-sale.
         end.
         assign
         sp_doc-line.excise      = gp-excise
         sp_doc-line.road-tax    = gp-road-tax
         sp_gds-dtl.ov           = yes.
       end.
       else do:
         message substitute (" Неизвестна цена товара &1 &2 по &3 &4 Товар будет перемещен по цене текущего объекта &5 &6.",
                                  sp_goods.artic,
                                  sp_goods.gds-name,
                                  sp_trn-doc.cli-type,
                                  sp_trn-doc.cli-code,
                                  sp_trn-doc.obj-type,
                                  sp_trn-doc.obj-code)
         view-as alert-box information.
       end.
     end.
  end.
  if sp_trn-doc.ret-supp = yes      then do:
    if not sp_gds-dtl.ov              and
       (sp_trn-doc.status_  = 'накл':U  and
        not sp_trn-doc.flag            or
        sp_trn-doc.status_ = 'разрешен':U) then do:
      if varr-b = "rubl":u then do:
        assign
          sp_gds-dtl.price-rubl = ?.
      end.
      else do:
        assign
          sp_gds-dtl.price-base = ?.
      end.
      IF sp_doc-line.transport-base = ? then ASSIGN sp_doc-line.transport-base = 0.
      IF sp_doc-line.transport-rubl = ? then ASSIGN sp_doc-line.transport-rubl = 0.
      IF sp_doc-line.other-base = ?     then ASSIGN sp_doc-line.other-base     = 0.
      IF sp_doc-line.other-rubl = ?     then ASSIGN sp_doc-line.other-rubl     = 0.
      if varr-b = "rubl":u then do:
        assign sp_gds-dtl.price-rubl = sp_doc-line.price-rubl - sp_doc-line.transport-rubl - sp_doc-line.other-rubl.
      end.
      else do:
        assign sp_gds-dtl.price-base = sp_doc-line.price-base - sp_doc-line.transport-base - sp_doc-line.other-base.
      end.
      assign
        sp_doc-line.excise   = 0
        sp_doc-line.road-tax = 0.
    end.
  end.
  else do:
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  sp_goods.gds-code
  ,input  sp_gds-dtl.prt-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  sp_gds-dtl.obj-type
  ,input  sp_gds-dtl.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  sp_gds-dtl.obj-type
  ,input  sp_gds-dtl.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
    if sp_trn-doc.ext-doc-type = 'ee':U then do:
       run factord-end-day in this-procedure (input sp_trn-doc.doc-date , output v-fact-order ).
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  sp_goods.gds-code
  ,input  ?
  ,output v-main-b-code
  )  .
        run str/set-mppr.p (
           input  true
          ,input  sp_trn-doc.cli-type
          ,input  sp_trn-doc.cli-code
          ,input  v-main-b-code
          ,input  gp-b-code
          ,input  sp_trn-doc.obj-type
          ,input  sp_trn-doc.obj-code
          ,input  ( if pardiscnt-qnty = 0 or pardiscnt-qnty = ? then sp_gds-dtl.fact-qnty else pardiscnt-qnty )
          ,input  0
          ,input  string(sp_trn-doc.pay-code)
          ,input  ""
          ,input  v-fact-order
          ,output sp_gds-dtl.plt-id
          ,output sp_gds-dtl.plt-db-num
          ,output sp_gds-dtl.pdf-id
          ,output sp_gds-dtl.pdf-db
          ,output v-sale-price-base
          ,output v-sale-price-rubl
          ,output v-road-tax-base
          ,output v-road-tax-rubl
          ,output v-excise-base
          ,output v-excise-rubl
          ) .
        if varr-b = "rubl":u then do:
            assign
              gp-excise     = v-excise-rubl
              gp-road-tax   = v-road-tax-rubl
              gp-price-sale = v-sale-price-rubl
            .
        end.
        else do:
            assign
              gp-excise     = v-excise-base
              gp-road-tax   = v-road-tax-base
              gp-price-sale = v-sale-price-base
            .
        end.
    end.
    if sp_trn-doc.ext-doc-type = 'ee':U and
       not sp_gds-dtl.ov                            then do:
      find first buf_dis-gds-rule no-lock where
                buf_dis-gds-rule.obj-type = sp_gds-dtl.obj-type
            and buf_dis-gds-rule.obj-code = sp_gds-dtl.obj-code
            and buf_dis-gds-rule.gds-code = sp_goods.gds-code
            and buf_dis-gds-rule.pos-type = '-':U
            and buf_dis-gds-rule.discnt-role = 'pcnt-qnty':U no-error.
      if available buf_dis-gds-rule then do:
        assign
          varhave-qnty-discnt = yes.
        find first sp-parent_dis-rule where sp-parent_dis-rule.rule-num = buf_dis-gds-rule.rule-num.
        for each sp_tt-dis-rule :
          delete sp_tt-dis-rule.
        end.
        for each sp-child_dis-rule where sp-child_dis-rule.upper-rule-num = sp-parent_dis-rule.rule-num on error undo, return error return-value :
          create sp_tt-dis-rule.
          assign
            sp_tt-dis-rule.doc-qnty     = sp-child_dis-rule.doc-qnty
            sp_tt-dis-rule.discnt-value = sp-child_dis-rule.discnt-value
          .
        end.
        if paruse-discnt-qnty then do:
          find last sp_tt-dis-rule where sp_tt-dis-rule.doc-qnty <= pardiscnt-qnty use-index pi no-error.
        end.
        else do:
          find last sp_tt-dis-rule where sp_tt-dis-rule.doc-qnty <= sp_doc-line.fact-qnty use-index pi no-error.
        end.
        if available sp_tt-dis-rule then do:
          assign
            varhave-qnty-discnt = yes.
            gp-price-sale       = gp-price-sale * (1 - sp_tt-dis-rule.discnt-value / 100 ).
        end.
      end.
    end.
    if not sp_gds-dtl.ov   or
       varhave-qnty-discnt then do:
      if gp-price-sale <> ? then do:
        if varr-b = "rubl":u then do:
          assign
           sp_doc-line.excise    = gp-excise
           sp_doc-line.road-tax  = gp-road-tax
           sp_gds-dtl.price-rubl = gp-price-sale.
        end.
        else do:
          assign
           sp_doc-line.excise    = gp-excise
           sp_doc-line.road-tax  = gp-road-tax
           sp_gds-dtl.price-base = gp-price-sale.
        end.
      end.
    end.
  end.
end.
if varr-b = "base":u then do:
  if sp_gds-dtl.ov and
     sp_trn-doc.print-rubl then do:
    assign
      sp_gds-dtl.price-base = sp_gds-dtl.price-rubl / sp_trn-doc.base-rate * sp_trn-doc.base-scale.
  end.
  else do:
    assign
      sp_gds-dtl.price-rubl = sp_gds-dtl.price-base * sp_trn-doc.base-rate / sp_trn-doc.base-scale.
  end.
end.
else do:
  if sp_gds-dtl.ov and
     not sp_trn-doc.print-rubl then do:
    assign
      sp_gds-dtl.price-rubl = sp_gds-dtl.price-base * sp_trn-doc.base-rate / sp_trn-doc.base-scale.
  end.
  else do:
    assign
      sp_gds-dtl.price-base = sp_gds-dtl.price-rubl / sp_trn-doc.base-rate * sp_trn-doc.base-scale.
  end.
end.
end.
end procedure.
procedure lib-trn3_rsrplgds :
  define input parameter pardoc-code like ub.trn-doc.doc-code no-undo .
  define buffer bf_trn-doc  for ub.trn-doc .
  define buffer bf_doc-line for ub.doc-line .
  define buffer bf_goods    for ub.goods .
  define buffer bf_doc-pl   for ub.doc-pl .
  define buffer bf_parts    for ub.parts .
  define buffer bf_place    for ub.place .
  define buffer bf_pl-gds   for ub.pl-gds .
  define variable clsreserv-pl-code as   logical          no-undo .
  define variable clspl-code        like ub.place.pl-code no-undo .
  do
  on error undo, return error return-value
  :
    find first bf_trn-doc no-lock where
               bf_trn-doc.doc-code = pardoc-code .
    for each bf_doc-line where
             bf_doc-line.doc-code = pardoc-code
    on error undo, return error return-value
    :
      find first bf_goods no-lock where
                 bf_goods.artic      = bf_doc-line.artic     and
                 bf_goods.prod-code  = bf_doc-line.prod-code and
                 bf_goods.prod-type  = bf_doc-line.prod-type .
      run plgdsfnd in this-procedure
        (  input no
        ,  input bf_doc-line.obj-type
        ,  input bf_doc-line.obj-code
        ,  input bf_goods.gds-code
        , output clsreserv-pl-code
        , output clspl-code
        ) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "Ошибка при выборе складского места для товара &1 &2 &3 &4 ."
                                     , bf_goods.artic
                                     , bf_goods.prod-type
                                     , bf_goods.prod-code
                                     , return-value
                                     ) .
      end.
      if clsreserv-pl-code = yes
      then do:
        for each bf_parts where
                 bf_parts.obj-type  = bf_trn-doc.obj-type   and
                 bf_parts.obj-code  = bf_trn-doc.obj-code   and
                 bf_parts.artic     = bf_doc-line.artic     and
                 bf_parts.prod-type = bf_doc-line.prod-type and
                 bf_parts.prod-code = bf_doc-line.prod-code and
                 bf_parts.out-code  = bf_doc-line.doc-code
        on error undo, return error return-value :
          if bf_parts.pl-code = 0 or
             bf_parts.pl-code = ?
          then do:
            undo, return error substitute( "lib-trn3_rsrplgds: Не указан код места хранения в партии по товару: &1 &2 &3."
                                         , bf_goods.artic
                                         , bf_goods.prod-type
                                         , bf_goods.prod-code
                                         ) .
          end.
          find first bf_place no-lock where
                     bf_place.obj-type = bf_parts.obj-type and
                     bf_place.obj-code = bf_parts.obj-code and
                     bf_place.pl-code  = bf_parts.pl-code  no-error .
          if not available bf_place
          then do:
            undo, return error substitute( "lib-trn3_rsrplgds: Неверно указан код места хранения в партии '
                                         + 'по товару: &1 &2 &3."
                                         , bf_goods.artic
                                         , bf_goods.prod-type
                                         , bf_goods.prod-code
                                         ) .
          end.
          find first bf_pl-gds no-lock where
                     bf_pl-gds.obj-type = bf_parts.obj-type and
                     bf_pl-gds.obj-code = bf_parts.obj-code and
                     bf_pl-gds.pl-code  = bf_parts.pl-code  and
                     bf_pl-gds.gds-code = bf_goods.gds-code no-error .
          if not available bf_pl-gds
          then do:
            find first bf_pl-gds no-lock where
                       bf_pl-gds.obj-type = bf_parts.obj-type and
                       bf_pl-gds.obj-code = bf_parts.obj-code and
                       bf_pl-gds.pl-code  = bf_parts.pl-code  no-error .
            undo, return error substitute( "lib-trn3_rsrplgds: Неверно указан код места хранения в партии "
                                         + "по товару: &1 &2 &3. На указанном месте хранится товар с кодом &4."
                                         , bf_goods.artic
                                         , bf_goods.prod-type
                                         , bf_goods.prod-code
                                         , ( if available bf_pl-gds then bf_pl-gds.gds-code else 0 )
                                         ) .
          end.
          find first bf_doc-pl no-lock where
                     bf_doc-pl.obj-type = bf_doc-line.obj-type and
                     bf_doc-pl.obj-code = bf_doc-line.obj-code and
                     bf_doc-pl.pl-code  = bf_parts.pl-code     and
                     bf_doc-pl.out-code = bf_doc-line.doc-code and
                     bf_doc-pl.gds-code = bf_goods.gds-code    no-error .
          if not available bf_doc-pl
          then do:
            undo, return error substitute( "lib-trn3_rsrplgds: Не найден doc-pl по товару: &1 &2 &3, место хранения &4 . "
                                         , bf_goods.artic
                                         , bf_goods.prod-type
                                         , bf_goods.prod-code
                                         , bf_parts.pl-code
                                         ) .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure lib-trn3_purchcon :
  do
  on error undo, return error return-value
  :
define input  parameter p-host-code      as integer   no-undo .
define input  parameter p-contract-code  as integer   no-undo .
define output parameter varpurch-code    as character no-undo .
define output parameter varpurch-code-name as character no-undo .
define buffer bf_contract for ub.contract  .
  find first bf_contract where bf_contract.host-code     = p-host-code     and
                               bf_contract.contract-code = p-contract-code no-lock.
  if lookup (bf_contract.contract-type, 'Купли-продажи,Агентский договор,Давальческого сырья,Продажи через ТПСИ':U) > 0 then do:
        assign
      varpurch-code-name = entry (lookup ('1':U, '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U)
      varpurch-code      = '1':U
      .
  end.
  else do:
    if lookup (bf_contract.contract-type, 'Консигнации':U) > 0 then do:
            assign
        varpurch-code-name = entry (lookup ('2':U, '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U)
        varpurch-code      = '2':U
        .
    end.
    else do:
      if lookup (bf_contract.contract-type, 'Ответственного хранения':U) > 0 then do:
                assign
          varpurch-code-name = entry (lookup ('3':U, '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U)
          varpurch-code      = '3':U
          .
      end.
      else do:
        message "Нельзя определить по договору " bf_contract.contract-prn-code  bf_contract.contract-code " с типом " bf_contract.contract-type " тип приобретения для партий накладной."
        view-as alert-box error.
        return error.
      end.
    end.
  end.
  end.
end procedure.
procedure lib-trn3_ch-amin :
define input parameter p-obj-type  like ub.trn-doc.obj-type no-undo.
define input parameter p-obj-code  like ub.trn-doc.obj-code no-undo.
define input parameter p-gds-code  like ub.goods.gds-code no-undo.
define input parameter p-mess      as logical   no-undo .
define output parameter  v-flag as logical   no-undo init false .
define variable v-flag1 as decimal   no-undo .
define variable v-flag2 as decimal   no-undo .
define buffer buf_gds-obj-prop for ub.gds-obj-prop.
define buffer buf_gds-obj      for ub.gds-obj.
define buffer buf_goods for ub.goods.
  do
  on error undo, return error return-value
  :
  v-flag = false  .
    for each buf_gds-obj-prop no-lock where
            buf_gds-obj-prop.obj-type = p-obj-type and
            buf_gds-obj-prop.obj-code = p-obj-code and
            buf_gds-obj-prop.gds-code = p-gds-code and
            buf_gds-obj-prop.gdop-assort-min = true ,
      first buf_gds-obj no-lock where
            buf_gds-obj.obj-type = p-obj-type and
            buf_gds-obj.obj-code = p-obj-code and
            buf_gds-obj.gds-code = p-gds-code and
            buf_gds-obj-prop.gdop-min-stock > buf_gds-obj.fact-qnty :
         v-flag = true .
         v-flag1 =  buf_gds-obj-prop.gdop-min-stock.
         v-flag2 =  buf_gds-obj.fact-qnty          .
    end.
    if v-flag = true then do:
       if p-mess then do:
         find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
         message
            "В документе есть товары , фактический остаток которых меньше минимального запаса ! " skip
            "Например   :" skip
            "Товар      :" buf_goods.gds-name skip
            "Артикул    :" buf_goods.artic skip
            "На объекте :" p-obj-type p-obj-code skip
            "Минимальный остаток :" v-flag1  skip
            "Фактический остаток :" v-flag2
            view-as alert-box information
            title "ВНИМАНИЕ !!!"
            .
       end.
    end.
  end.
end procedure.
procedure lib-trn3_chkinvln :
  define  input parameter p-doc-code  like ub.inv-line.doc-code   no-undo.
  define  input parameter p-artic     like ub.inv-line.artic      no-undo.
  define  input parameter p-prod-type like ub.inv-line.prod-type  no-undo.
  define  input parameter p-prod-code like ub.inv-line.prod-code  no-undo.
  define  input parameter p-sale-rubl like ub.gds-dtl.price-rubl  no-undo.
  define  input parameter p-sale-base like ub.gds-dtl.price-base  no-undo.
  define  input parameter p-acc-rubl  like ub.doc-line.price-rubl no-undo.
  define  input parameter p-acc-base  like ub.doc-line.price-base no-undo.
  define  input parameter p-fact-qnty like ub.gds-dtl.fact-qnty   no-undo.
  define  input parameter p-density   like ub.doc-line.fact-density    no-undo.
  define output parameter rec-inv-lin as   recid                  no-undo.
  define variable is-petrol as logical no-undo.
  define variable is-pieces as logical no-undo.
  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_trn-doc  for ub.trn-doc.
  define buffer buf_goods    for ub.goods .
  do
  on error undo, return error substitute( 'lib-trn3_chkinvln: ошибка создания записи строки итогов (inv-line) ' +
                                          'по накладной "&1", товар: Артикул &2 (производитель: &3 &4)',
                                          p-doc-code,
                                          p-artic,
                                          p-prod-type,
                                          p-prod-code  )
  :
    find first buf_trn-doc where buf_trn-doc.doc-code = p-doc-code.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input p-artic
  ,  input p-prod-type
  ,  input p-prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
    if error-status :error or is-petrol <> yes or is-pieces <> no then do:
      return.
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error.
    if not available buf_goods then do:
      undo, return error substitute( 'lib-trn3_chkinvln: не найден товар: Артикул "&2" (производитель: &3 &4)',
                                      p-artic, p-prod-type, p-prod-code ).
    end.
    find first buf_inv-line no-lock
      where buf_inv-line.doc-code  = p-doc-code
        and buf_inv-line.artic     = p-artic
        and buf_inv-line.prod-type = p-prod-type
        and buf_inv-line.prod-code = p-prod-code
      no-error.
    if available buf_inv-line then do:
      if p-sale-rubl = ? or p-sale-rubl = 0.0 then do:
        assign
          p-sale-rubl = buf_inv-line.wast-rubl
        .
      end.
      if p-sale-base = ? or p-sale-base = 0.0 then do:
        assign
          p-sale-base = buf_inv-line.wast-base
        .
      end.
      if p-acc-rubl = ? or p-acc-rubl = 0.0 then do:
        assign
          p-acc-rubl = buf_inv-line.unus-wast-rubl
        .
      end.
      if p-acc-base = ? or p-acc-base = 0.0 then do:
        assign
          p-acc-base = buf_inv-line.unus-wast-base
        .
      end.
      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = p-doc-code
          and buf_doc-line.artic     = p-artic
          and buf_doc-line.prod-type = p-prod-type
          and buf_doc-line.prod-code = p-prod-code
        no-error .
      if available buf_doc-line then do:
        if
  valid-density( p-density, buf_goods.unit-base = buf_goods.unit-cli )
  <> yes then do:
          assign
            p-density = buf_doc-line.fact-density
          .
        end.
        if
  valid-density( p-density, buf_goods.unit-base = buf_goods.unit-cli )
  = yes then do:
          if p-fact-qnty = ? then do:
            assign
              p-fact-qnty = (if buf_trn-doc.doc-type = 'инв':U then buf_inv-line.wast-cli-qnty else buf_doc-line.fact-qnty * p-density).
          end.
        end.
      end.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_corinvln in g#lib-trn3
( input  p-doc-code
 ,input  p-artic
 ,input  p-prod-type
 ,input  p-prod-code
 ,input  p-sale-rubl
 ,input  p-sale-base
 ,input  p-acc-rubl
 ,input  p-acc-base
 ,input  p-fact-qnty
 ,input  p-density
 ,output rec-inv-lin
 ) no-error.
    if error-status :error then do:
      undo, return error return-value.
    end.
    find first buf_inv-line no-lock where recid( buf_inv-line ) = rec-inv-lin no-error.
    if not available buf_inv-line then do:
      undo, return error substitute(
        'lib-trn3_chkinvln: ошибка создания записи строки итогов (inv-line) по накладной "&1", ' +
        'товар: Артикул &2 (производитель: &3 &4)',
        p-doc-code,
        p-artic,
        p-prod-type,
        p-prod-code                ).
    end.
  end.
end procedure.
define temp-table tt-doc-line no-undo like ub.doc-line.
procedure lib-trn3_chkgdsd:
define input parameter parrec-doc as recid no-undo.
define input parameter parrec-gds as recid no-undo.
define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_goods   for ub.goods.
define buffer bf_parts   for ub.parts.
define variable l-inv-on as logical no-undo .
do on error undo, return error return-value :
find first bf_trn-doc where recid(bf_trn-doc) = parrec-doc no-lock.
find first bf_goods   where recid(bf_goods)   = parrec-gds no-lock.
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  bf_goods.artic
  ,input  bf_goods.prod-type
  ,input  bf_goods.prod-code
  ,input  'inv-on=request'
  ,output l-inv-on
  ) no-error .
  if error-status :error then do:
    undo, return error "Ошибка получения признака товара на объекте".
  end.
  if l-inv-on then do:
    return error substitute("Артикул : &1 &2 &3 &4  - товар в инвентаризации. Операция невозможна.", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name) .
  end.
  for each tt-doc-line :
    delete tt-doc-line.
  end.
  create tt-doc-line.
  assign
    tt-doc-line.doc-code  = bf_trn-doc.doc-code
    tt-doc-line.obj-type  = bf_trn-doc.obj-type
    tt-doc-line.obj-code  = bf_trn-doc.obj-code
    tt-doc-line.artic     = bf_goods.artic
    tt-doc-line.prod-type = bf_goods.prod-type
    tt-doc-line.prod-code = bf_goods.prod-code.
  bl-inv-on:
  for
 each bf_parts no-lock
        where
            (     bf_parts.prod-type = tt-doc-line.prod-type
              and bf_parts.prod-code = tt-doc-line.prod-code
              and bf_parts.artic     = tt-doc-line.artic
              and bf_parts.obj-type  = tt-doc-line.obj-type
              and bf_parts.obj-code  = tt-doc-line.obj-code
              and bf_parts.rsrv-free = true
              and bf_parts.status_   = false
              and bf_parts.out-code  <> 'free-zone':U
              and bf_parts.out-code  <> bf_trn-doc.doc-code
            )
            or
            (     bf_parts.prod-type = tt-doc-line.prod-type
              and bf_parts.prod-code = tt-doc-line.prod-code
              and bf_parts.artic     = tt-doc-line.artic
              and bf_parts.obj-type  = tt-doc-line.obj-type
              and bf_parts.obj-code  = tt-doc-line.obj-code
              and bf_parts.rsrv-free = false
              and bf_parts.status_   = false
              and bf_parts.out-code  <> 'out-zone':U
              and bf_parts.out-code  <> bf_trn-doc.doc-code
            )
  on error undo bl-inv-on, return error :
    undo bl-inv-on, return error substitute("Включить инвентаризацию нельзя - на товаре есть резервы. Товар &1 &2 &3 Документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_parts.out-code).
  end.
end.
end procedure.
procedure lib-trn3_addcorln:
define input  parameter parrec-doc   as recid no-undo.
define input  parameter parrec-goods as recid no-undo.
define output parameter parrecid     as recid no-undo.
define variable v-vat-pc        like ub.doc-line.vat-pc        no-undo.
define variable v-slt-pc        like ub.doc-line.slt-pc        no-undo.
define variable v-have-slt-pc   as   logical                no-undo.
define variable v-host-code     like ub.sysconf.host-code      no-undo.
define variable varn-c          like ub.gds-prt.node-code   no-undo.
define variable l-inv-on        as   logical                no-undo.
define variable v-cons-vat-pc   like ub.sysconf.cons-vat-pc no-undo.
define buffer bf_goods    for ub.goods.
define buffer bf_doc-line for ub.doc-line.
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_sysconf  for ub.sysconf.
do on error undo, return error return-value :
find first bf_trn-doc where recid(bf_trn-doc)    = parrec-doc           exclusive-lock.
find first bf_goods   where recid(bf_goods)      = parrec-goods         no-lock.
find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
if bf_goods.gds-type = 'у':U then do:
  undo, return error "Услуги нельзя добавлять в данный документ " + bf_goods.artic + " " + bf_goods.prod-type + " " + string(bf_goods.prod-code).
end.
find first bf_doc-line where bf_doc-line.artic     = bf_goods.artic
                         and bf_doc-line.prod-type = bf_goods.prod-type
                         and bf_doc-line.prod-code = bf_goods.prod-code
                         and bf_doc-line.doc-code  = bf_trn-doc.doc-code no-error.
if not available bf_doc-line then do:
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output v-vat-pc
  ) no-error .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_st-sltpc in g#lib-trn
(
 input  recid(bf_goods)
,input  recid(bf_trn-doc)
,input  bf_sysconf.cash-pay
,output v-slt-pc
)
.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcvat in g#library
  (input  bf_trn-doc.host-code
  ,output v-cons-vat-pc
  )  .
  if v-vat-pc = ? then do:
   return error substitute ("Не установлен консигнационный НДС по фирме &1.", bf_trn-doc.host-code).
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdoclin in g#lib-trn
(input bf_trn-doc.doc-code
,input bf_goods.artic
,input bf_goods.prod-type
,input bf_goods.prod-code
,input bf_trn-doc.obj-type
,input bf_trn-doc.obj-code
,input bf_trn-doc.status_
,input bf_trn-doc.ext-doc-type
,input bf_goods.prt-root
,input v-vat-pc
,input v-slt-pc
,input v-cons-vat-pc
)
.
  find first bf_doc-line where bf_doc-line.doc-code  = bf_trn-doc.doc-code and
                               bf_doc-line.artic     = bf_goods.artic      and
                               bf_doc-line.prod-type = bf_goods.prod-type  and
                               bf_doc-line.prod-code = bf_goods.prod-code  exclusive-lock.
  assign
    bf_doc-line.price-base     = 0
    bf_doc-line.price-rubl     = 0
    bf_doc-line.road-tax       = 0
    bf_doc-line.transport-base = 0
    bf_doc-line.transport-rubl = 0
    bf_doc-line.other-base     = 0
    bf_doc-line.other-rubl     = 0
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  bf_goods.prt-root
  ,output varn-c
  )  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input bf_trn-doc.obj-code
   ,input bf_trn-doc.obj-type
   ,input bf_trn-doc.doc-code
   ,input bf_goods.artic
   ,input bf_goods.prod-code
   ,input bf_goods.prod-type
   ,input varn-c
   ,input yes
  ) no-error .
   if error-status:error then do:
      undo, return error substitute ("Ошибка при создании терминального признака по товару: &1 &2 &3 &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, return-value).
   end.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  bf_doc-line.obj-type
  ,input  bf_doc-line.obj-code
  ,input  bf_doc-line.artic
  ,input  bf_doc-line.prod-type
  ,input  bf_doc-line.prod-code
  ,input  'inv-on=true'
  ,output l-inv-on
  ) no-error .
   if error-status :error then do:
     undo, return error substitute ("Ошибка установки атрибута товара на объекте. Документ &1 Объект &2 &3 Артикул &4 &5 &6 l-new-inv-on &7 &8", bf_doc-line.doc-code, bf_doc-line.obj-type, bf_doc-line.obj-code, bf_doc-line.artic, bf_doc-line.prod-type, bf_doc-line.prod-code, l-inv-on, return-value).
   end.
end.
assign parrecid = recid(bf_doc-line).
end.
end procedure.
procedure lib-trn3_trn-rsn :
  define input parameter p-doc-code like ub.trn-doc.doc-code no-undo.
  define variable is_hold-doc as logical no-undo.
  define variable j_rsn-code  as integer no-undo initial ?.
  define buffer buf_trn-doc for ub.trn-doc.
  define buffer src_trn-doc for ub.trn-doc.
  do on error undo, return error "lib-trn3_trn-rsn: ошибка установки кода основания (причины) создания документа" :
    find first buf_trn-doc no-lock where
               buf_trn-doc.doc-code = p-doc-code no-error.
    if not available buf_trn-doc then do:
      undo, return error substitute( 'lib-trn3_trn-rsn: не найдена накладная "&1"', p-doc-code ).
    end.
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  p-doc-code
  ,output is_hold-doc
  )  .
    if is_hold-doc = yes or is_hold-doc = no and
       lookup( buf_trn-doc.ext-doc-type, 'iv,rv':U ) > 0 then do:
      find first src_trn-doc no-lock where
                 src_trn-doc.doc-code = buf_trn-doc.out-code no-error.
      if available src_trn-doc then do:
        assign j_rsn-code = buf_trn-doc.reason-code.
      end.
    end.
    if j_rsn-code = ? then do:
      find first ub.trn-reason-obj no-lock where
                 ub.trn-reason-obj.obj-type     = buf_trn-doc.obj-type     and
                 ub.trn-reason-obj.obj-code     = buf_trn-doc.obj-code     and
                 ub.trn-reason-obj.ext-doc-type = buf_trn-doc.ext-doc-type and
                 ub.trn-reason-obj.hold-doc     = is_hold-doc              no-error.
      if available ub.trn-reason-obj then do:
        assign j_rsn-code = ub.trn-reason-obj.reason-code.
      end.
    end.
    if j_rsn-code = ? then do:
      find first ub.trn-reason-host no-lock where
                 ub.trn-reason-host.host-code    = buf_trn-doc.host-code    and
                 ub.trn-reason-host.ext-doc-type = buf_trn-doc.ext-doc-type and
                 ub.trn-reason-host.hold-doc     = is_hold-doc              no-error.
      if available ub.trn-reason-host then do:
        assign j_rsn-code = ub.trn-reason-host.reason-code.
      end.
    end.
    if j_rsn-code <> ? then do:
      do transaction on error undo, return error :
        find first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = p-doc-code.
        assign buf_trn-doc.reason-code = j_rsn-code.
        find first buf_trn-doc        no-lock where buf_trn-doc.doc-code = p-doc-code.
      end.
    end.
  end.
end procedure.
procedure lib-trn3_canclsee :
  define  input parameter p-doc-code like ub.trn-doc.doc-code no-undo.
  define output parameter p-CanClose as   logical             no-undo initial no.
  define variable v-DataType as character no-undo.
  define variable v-ProxyCrd as character no-undo.
  define buffer bf_trn-doc  for ub.trn-doc.
  define buffer bf_doc-attr for ub.doc-attr.
  do on error undo, return error "canclsee: ошибка определения параметра proxycrd" :
    find first bf_trn-doc no-lock where
               bf_trn-doc.doc-code = p-doc-code no-error.
    if not available bf_trn-doc then do:
      undo, return error substitute( 'canclsee: не найдена накладная "&1"', p-doc-code ).
    end.
    if lookup( bf_trn-doc.ext-doc-type, 'ee,ep':U ) = 0 then do:
      assign p-CanClose = yes.
      return.
    end.
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input bf_trn-doc.obj-type
  ,input bf_trn-doc.obj-code
  ,input 'nakl_par':U
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
    if thbjattr_thbj-attr.prop-code = 'proxycrd'   then v-ProxyCrd = string( thbjattr_thbj-attr.property-value-logical, "yes/no" ) .
end.
empty temp-table thbjattr_thbj-attr.
    if  v-ProxyCrd <> "yes" then do:
      assign p-CanClose = yes.
      return.
    end.
    find first bf_doc-attr no-lock where
               bf_doc-attr.doc-code  = p-doc-code       and
               bf_doc-attr.attr-code = 'ndov':U no-error.
    if not available bf_doc-attr then do:
      undo, return error 'canclsee: не найден атрибут "Номер доверенности"'.
    end.
    if bf_doc-attr.attr-value = ? or bf_doc-attr.attr-value = "":U then do:
      undo, return error 'canclsee: атрибут "Номер доверенности" не заполнен'.
    end.
    find first bf_doc-attr no-lock where
               bf_doc-attr.doc-code  = p-doc-code       and
               bf_doc-attr.attr-code = 'ddov':U no-error.
    if not available bf_doc-attr then do:
      undo, return error 'canclsee: не найден атрибут "Дата доверенности"'.
    end.
    if bf_doc-attr.attr-value = ? or bf_doc-attr.attr-value = "":U then do:
      undo, return error 'canclsee: атрибут "Дата доверенности" не заполнен'.
    end.
    assign p-CanClose = yes.
  end.
end procedure.
procedure lib-trn3_holdcdoc :
  define  input parameter p-doc-code as character no-undo.
  define output parameter p-is-hold  as logical   no-undo initial no.
  define buffer bf_c-trn-doc for ub.c-trn-doc.
  do on error undo, return error substitute( '&1 &2', return-value, error-status :get-message( 1 ) ) :
    find first bf_c-trn-doc no-lock where
               bf_c-trn-doc.doc-code = p-doc-code no-error.
    if not available bf_c-trn-doc then do:
      return error substitute( 'Не найдена история документа (удаленный документ) с номером "&1" .', p-doc-code ).
    end.
    if   ( bf_c-trn-doc.ext-doc-type         =  'ie':U       or
           bf_c-trn-doc.ext-doc-type         =  'ee':U       or
           bf_c-trn-doc.ext-doc-type         =  'ep':U    or
           bf_c-trn-doc.ext-doc-type         =  're':U ) and
       ( ( bf_c-trn-doc.hold-doc-code-child  <> '':U                     and
           bf_c-trn-doc.hold-doc-code-child  <> 'no-hold':U )            or
         ( bf_c-trn-doc.hold-doc-code-parent <> '':U                     and
           bf_c-trn-doc.hold-doc-code-parent <> 'no-hold':U )          ) then do:
      assign
        p-is-hold = yes
      .
    end.
  end.
end procedure.
procedure lib-trn3_shiftnam :
  define input  parameter parobj-type       like ub.clients.obj-type     no-undo.
  define input  parameter parobj-code       like ub.clients.obj-code     no-undo.
  define input  parameter parshift-date     like ub.shift-obj.shift-date no-undo.
  define input  parameter parshift-num      like ub.shift-obj.shift-num  no-undo.
  define output parameter parshift-name     as   character               no-undo.
  define output parameter parshift-name-num as   character               no-undo.
  define buffer bf_shift-obj   for ub.shift-obj.
  define buffer bf_shift-staff for ub.shift-staff.
  do on error undo, return error return-value :
    find first bf_shift-obj where bf_shift-obj.obj-type   = parobj-type   and
                                  bf_shift-obj.obj-code   = parobj-code   and
                                  bf_shift-obj.shift-date = parshift-date and
                                  bf_shift-obj.shift-num  = parshift-num  no-lock no-error.
    if not available bf_shift-obj then do:
      return error substitute ("Нет смены по объекту &1 &2 дата &3 порядок &4.", parobj-type, parobj-code, parshift-date, parshift-num).
    end.
    assign
      parshift-name     = bf_shift-obj.shift-name
      parshift-name-num = (if parshift-num = integer(parshift-num) then parshift-name else bf_shift-obj.shift-name + "(" + string(bf_shift-obj.shift-num) + ")").
  end.
end procedure.
procedure lib-trn3_shiftnme :
  define input  parameter parobj-type       like ub.clients.obj-type     no-undo.
  define input  parameter parobj-code       like ub.clients.obj-code     no-undo.
  define input  parameter parshift-date     like ub.shift-obj.shift-date no-undo.
  define input  parameter parshift-num      like ub.shift-obj.shift-num  no-undo.
  define input-output parameter parshift-name     as   character               no-undo.
  define output parameter parshift-name-num as   character               no-undo.
  define buffer bf_shift-obj   for ub.shift-obj.
  define buffer bf_shift-staff for ub.shift-staff.
  do on error undo, return error return-value :
    find first bf_shift-obj where bf_shift-obj.obj-type   = parobj-type   and
                                  bf_shift-obj.obj-code   = parobj-code   and
                                  bf_shift-obj.shift-date = parshift-date and
                                  bf_shift-obj.shift-num  = parshift-num  no-lock no-error.
    if not available bf_shift-obj then do:
      assign
      parshift-name = parshift-name
      parshift-name-num = (if parshift-num = integer(parshift-name) then parshift-name else (parshift-name + "(" + string(parshift-num) + ")")).
    end.
    else do:
      assign
      parshift-name     = bf_shift-obj.shift-name
      parshift-name-num = (if bf_shift-obj.shift-num = integer(bf_shift-obj.shift-name)
                           then bf_shift-obj.shift-name
                           else bf_shift-obj.shift-name + "(" + string(bf_shift-obj.shift-num) + ")").
    end.
  end.
end procedure.
procedure lib-trn3_rvschtrn :
  define  input parameter p-obj-type   as character no-undo .
  define  input parameter p-obj-code   as integer   no-undo .
  define  input parameter p-shift-date as date      no-undo .
  define  input parameter p-shift-num  as integer   no-undo .
  define  input parameter p-rvs-code   as character no-undo .
  define  input parameter p-talk-on    as logical   no-undo .
  define  input parameter p-ask        as logical   no-undo .
  define output parameter p-found      as logical   no-undo initial yes .
  define variable v_shft-name1 as character no-undo .
  define variable v_shft-name2 as character no-undo .
  define variable v-host-code  as integer   no-undo .
  define variable v_data-type  as character no-undo .
  define variable chk-open-doc as character no-undo .
define variable ext-doc-name as character no-undo .
define variable is_hold-doc  as logical   no-undo .
define variable jj           as integer   no-undo .
define variable string-error as character no-undo .
define variable g-log        as logical   no-undo .
define buffer bf_trn-doc for ub.trn-doc .
  define buffer bf_shift-obj for ub.shift-obj .
  Main-Block:
  do on error undo Main-Block, return error return-value :
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
    if error-status :error or
       v-host-code = ? or
       v-host-code = 0
    then do:
      if p-talk-on = yes then do:
        message "lib-trn3_rvschtrn:" skip( 1 )
                "Невозможно определить фирму для объекта" p-obj-type p-obj-code skip( 1 )
        view-as alert-box error .
      end.
      undo Main-Block, return error substitute( "Невозможно определить фирму для объекта &1 &2"
                                              , p-obj-type
                                              , p-obj-code ) .
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'shopendc':U
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output chk-open-doc
  ,output v_data-type
  ) no-error .
    if error-status :error or
       v_data-type <> "L":U or
       lookup( chk-open-doc, "yes,no":U ) = 0
    then do:
      assign
        chk-open-doc = "no"
      .
    end.
    if chk-open-doc = "no" then do:
      assign
        p-found = no
      .
      return .
    end.
    find first bf_shift-obj no-lock where
               bf_shift-obj.obj-type   = p-obj-type   and
               bf_shift-obj.obj-code   = p-obj-code   and
               bf_shift-obj.shift-date = p-shift-date and
               bf_shift-obj.shift-num  = p-shift-num  use-index pi no-error .
    if not available bf_shift-obj then do:
      find first bf_shift-obj no-lock where
                 bf_shift-obj.obj-type =   p-obj-type   and
                 bf_shift-obj.obj-code =   p-obj-code   and
                 bf_shift-obj.status_  = 'тек':U use-index pi no-error .
      if not available bf_shift-obj then do:
        if p-talk-on = yes then do:
          message "lib-trn3_rvschtrn:" skip( 1 )
                  "Нет открытой смены на объекте" p-obj-type p-obj-code skip( 1 )
          view-as alert-box error .
        end.
        undo Main-Block, return error substitute( "Нет открытой смены на объекте &1 &2"
                                                , p-obj-type
                                                , p-obj-code ) .
      end.
    end.
for each bf_trn-doc no-lock where
         bf_trn-doc.obj-type     =  bf_shift-obj.obj-type   and
         bf_trn-doc.obj-code     =  bf_shift-obj.obj-code   and
         bf_trn-doc.internal     =  no                     and
         bf_trn-doc.status_      <> 'факт':U                 and
         bf_trn-doc.status_      <> 'запрос':U              and
       (
         bf_trn-doc.ext-doc-type =  'ie':U      or
         bf_trn-doc.ext-doc-type =  'ee':U      or
         bf_trn-doc.ext-doc-type =  'ep':U   or
         bf_trn-doc.ext-doc-type =  're':U  or
         bf_trn-doc.ext-doc-type =  'we':U      or
         bf_trn-doc.ext-doc-type =  'vt':U            or
         bf_trn-doc.ext-doc-type =  'vp':U       or
         no
       )
:
  assign
    ext-doc-name = entry( lookup( bf_trn-doc.ext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U )
  .
  if
            bf_trn-doc.ext-doc-type = 'ep':U  or
            bf_trn-doc.ext-doc-type = 're':U or
            no
  then do:
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  bf_trn-doc.doc-code
  ,output is_hold-doc
  ) no-error .
    if error-status :error or
       is_hold-doc = ?
    then do:
      assign
        string-error = "":U
      .
      do jj = 1 to error-status :num-messages
      :
        assign
          string-error = string-error
                       + ( if string-error = "":U then "":U else chr(10) )
                       + error-status :get-message( jj )
        .
      end.
      if p-talk-on = yes then do:
        message "lib-trn3_rvschtrn:" skip( 1 )
                substitute( 'Невозможно определить межфирменный тип для документа "&1" &2 в статусе "&3".'
                          , bf_trn-doc.doc-code
                          , ext-doc-name
                          , bf_trn-doc.status_ ) skip( 0 )
                string-error skip( 0 )
                return-value skip( 1 )
        view-as alert-box error .
      end.
      undo Main-Block, return error substitute( 'Невозможно определить межфирменный тип для документа "&4" &5 '
                                              + 'в статусе "&6".&2&1&2&3'
                                              , string-error
                                              , chr(10)
                                              , return-value
                                              , bf_trn-doc.doc-code
                                              , ext-doc-name
                                              , bf_trn-doc.status_ ) .
    end.
    if is_hold-doc = no then do:
      if ( bf_trn-doc.ext-doc-type = 'ie':U or
           bf_trn-doc.ext-doc-type = 'vt':U       or
           bf_trn-doc.ext-doc-type = 'vp':U  ) and
           bf_trn-doc.status_      = 'накл':U
      then do:
        if bf_trn-doc.out-code = p-rvs-code then do:
          next .
        end.
        if p-talk-on = yes then do:
          if p-ask = yes then do:
            message "lib-trn3_rvschtrn:" skip( 1 )
                    substitute( 'Есть складской документ "&1" "&2" статус "&3" .'
                              , bf_trn-doc.doc-code
                              , ext-doc-name
                              , bf_trn-doc.status_ + string( bf_trn-doc.flag, '+/-':U )
                              ) skip( 1 )
                    chr(9) 'ЗАКРЫТЬ СВЕРКУ?' skip( 1 )
            view-as alert-box question buttons yes-no update g-log .
          end.
          else do:
            assign
              g-log = yes
            .
          end.
        end.
        else do:
          assign
            g-log = no
          .
        end.
        if g-log <> yes then do:
          undo Main-Block, return error substitute( 'Есть складской документ "&1" "&2" статус "&3" .'
                                                  , bf_trn-doc.doc-code
                                                  , ext-doc-name
                                                  , bf_trn-doc.status_ + string( bf_trn-doc.flag, '+/-':U ) ) .
        end.
      end.
      next .
    end.
  end.
  if p-talk-on = yes then do:
    message "lib-trn3_rvschtrn:"                                                  skip( 1 )
            "Объект:" bf_shift-obj.obj-type   bf_shift-obj.obj-code               skip( 0 )
            "Смена:"  bf_shift-obj.shift-date                                     skip( 0 )
            "Порядок смены:" bf_shift-obj.shift-num                               skip( 0 )
            "Номер смены" bf_shift-obj.shift-name                                 skip( 0 )
            "Имеется документ" '"' + bf_trn-doc.doc-code + '"' ext-doc-name
            "в статусе:" '"'       + bf_trn-doc.status_  + '"'                    skip( 1 )
    view-as alert-box error .
  end.
  return substitute( 'Имеется документ "&1" &2 в статусе "&3".&4Объект &5 &6.&4Смена: &7 порядок: &8 номер: &9'
                   , bf_trn-doc.doc-code
                   , ext-doc-name
                   , bf_trn-doc.status_
                   , chr(10)
                   , bf_shift-obj.obj-type
                   , bf_shift-obj.obj-code
                   , bf_shift-obj.shift-date
                   , bf_shift-obj.shift-num
                   , bf_shift-obj.shift-name ) .
end.
for each bf_trn-doc no-lock where
         bf_trn-doc.obj-type     =  bf_shift-obj.obj-type   and
         bf_trn-doc.obj-code     =  bf_shift-obj.obj-code   and
         bf_trn-doc.internal     =  yes                     and
         bf_trn-doc.status_      <> 'факт':U                 and
         bf_trn-doc.status_      <> 'запрос':U              and
       (
         bf_trn-doc.ext-doc-type =  'iv':U      or
         bf_trn-doc.ext-doc-type =  'ev':U      or
         bf_trn-doc.ext-doc-type =  'rv':U  or
         no
       )
:
  assign
    ext-doc-name = entry( lookup( bf_trn-doc.ext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U )
  .
  if bf_trn-doc.ext-doc-type = 'iv':U and
     bf_trn-doc.flag_        = yes                and
     bf_trn-doc.status_      = 'накл':U
  then do:
    if bf_trn-doc.out-code = p-rvs-code then do:
      next .
    end.
    if p-talk-on = yes then do:
      if p-ask = yes then do:
        message "lib-trn3_rvschtrn:" skip( 1 )
                substitute( 'Есть складской документ "&1" "&2" статус "&3" .'
                          , bf_trn-doc.doc-code
                          , ext-doc-name
                          , bf_trn-doc.status_ + string( bf_trn-doc.flag, '+/-':U )
                          ) skip( 1 )
                chr(9) 'ЗАКРЫТЬ СВЕРКУ?' skip( 1 )
        view-as alert-box question buttons yes-no update g-log .
      end.
      else do:
        assign
          g-log = yes
        .
      end.
    end.
    else do:
      assign
        g-log = no
      .
    end.
    if g-log <> yes then do:
      undo Main-Block, return error substitute( 'Есть складской документ "&1" "&2" статус "&3" .'
                                              , bf_trn-doc.doc-code
                                              , ext-doc-name
                                              , bf_trn-doc.status_ + string( bf_trn-doc.flag, '+/-':U ) ) .
    end.
  end.
  if p-talk-on = yes then do:
    message "lib-trn3_rvschtrn:"                                                  skip( 1 )
            "Объект:" bf_shift-obj.obj-type   bf_shift-obj.obj-code               skip( 0 )
            "Смена:"  bf_shift-obj.shift-date                                     skip( 0 )
            "Порядок смены:" bf_shift-obj.shift-num                               skip( 0 )
            "Номер смены" bf_shift-obj.shift-name                                 skip( 0 )
            "Имеется документ" '"' + bf_trn-doc.doc-code + '"' ext-doc-name
            "в статусе:" '"'       + bf_trn-doc.status_  + '"'                    skip( 1 )
    view-as alert-box error .
  end.
  return substitute( 'Имеется документ "&1" &2 в статусе "&3".&4Объект &5 &6.&4Смена: &7 порядок: &8 номер: &9'
                   , bf_trn-doc.doc-code
                   , ext-doc-name
                   , bf_trn-doc.status_
                   , chr(10)
                   , bf_shift-obj.obj-type
                   , bf_shift-obj.obj-code
                   , bf_shift-obj.shift-date
                   , bf_shift-obj.shift-num
                   , bf_shift-obj.shift-name ) .
end.
    assign
      p-found = no
    .
  end.
end procedure.
procedure lib-trn3_invdnull :
  define input parameter p-doc-code like ub.trn-doc.doc-code no-undo.
  define input parameter p-talk-on  as   logical             no-undo.
  define variable r_trn-doc   as recid     no-undo.
  define variable r_trn-lin   as recid     no-undo.
  define variable v_inv-null  as character no-undo.
  define variable v_data-type as character no-undo.
  define variable l-inv-on    as logical   no-undo.
  define buffer bf_trn-doc  for ub.trn-doc.
  define buffer bf_trn-line for ub.doc-line.
  define buffer bf_doc-line for ub.doc-line.
  define buffer bf_gds-dtl  for ub.gds-dtl.
  define buffer bf_inv-line for ub.inv-line.
  define buffer bf_parts    for ub.parts.
  Main-Block:
  do on error undo Main-Block, return error return-value :
    find first bf_trn-doc no-lock where
               bf_trn-doc.doc-code = p-doc-code no-error.
    if not available bf_trn-doc then do:
      if p-talk-on = yes then do:
        message "lib-trn3_invdnull:"                                                  skip( 1 )
                substitute( 'Не найдена инвентаризация с номером "&1".', p-doc-code ) skip( 1 )
        view-as alert-box error.
      end.
      undo Main-Block, return error substitute( 'Не найдена инвентаризация с номером "&1".', p-doc-code ).
    end.
    if bf_trn-doc.ext-doc-type <> 'vt':U then do:
      if p-talk-on = yes then do:
        message "lib-trn3_invdnull:"                                                             skip( 1 )
                substitute( 'Документ с номером "&1" не является инвентаризацией.', p-doc-code ) skip( 1 )
        view-as alert-box error.
      end.
      undo Main-Block, return error substitute( 'Документ с номером "&1" не является инвентаризацией.', p-doc-code ).
    end.
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input bf_trn-doc.obj-type
  ,input bf_trn-doc.obj-code
  ,input 'inv-obj':U
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
        if thbjattr_thbj-attr.prop-code = 'invdnull' then v_inv-null = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
    end.
    empty temp-table thbjattr_thbj-attr.
    if v_inv-null = "no" then do: return. end.
    assign r_trn-doc = recid( bf_trn-doc ).
    find first bf_trn-doc exclusive-lock where
        recid( bf_trn-doc ) = r_trn-doc.
    check-line:
    for each bf_doc-line no-lock where
             bf_doc-line.doc-code = bf_trn-doc.doc-code :
      if bf_doc-line.doc-qnty  <> 0.00 or
         bf_doc-line.fact-qnty <> 0.00 then do:
        next check-line.
      end.
      for each bf_gds-dtl no-lock where
               bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
               bf_gds-dtl.artic     = bf_doc-line.artic     and
               bf_gds-dtl.prod-type = bf_doc-line.prod-type and
               bf_gds-dtl.prod-code = bf_doc-line.prod-code :
        if bf_gds-dtl.doc-qnty  <> 0.00 or
           bf_gds-dtl.fact-qnty <> 0.00 then do:
          next check-line.
        end.
      end.
      for each bf_parts no-lock where
               bf_parts.out-code  = bf_doc-line.doc-code  and
               bf_parts.obj-type  = bf_trn-doc.obj-type   and
               bf_parts.obj-code  = bf_trn-doc.obj-code   and
               bf_parts.artic     = bf_doc-line.artic     and
               bf_parts.prod-type = bf_doc-line.prod-type and
               bf_parts.prod-code = bf_doc-line.prod-code :
        if bf_parts.fact-qnty <> 0.00 then do:
          next check-line.
        end.
      end.
      find first bf_inv-line no-lock where
                 bf_inv-line.doc-code  = bf_doc-line.doc-code  and
                 bf_inv-line.artic     = bf_doc-line.artic     and
                 bf_inv-line.prod-type = bf_doc-line.prod-type and
                 bf_inv-line.prod-code = bf_doc-line.prod-code no-error.
      if available bf_inv-line then do:
        if bf_inv-line.before-cli-qnty <> 0.00 or
           bf_inv-line.after-cli-qnty  <> 0.00 or
           bf_inv-line.wast-cli-qnty   <> 0.00 or
           bf_doc-line.cli-qnty        <> 0.00 then do:
          next check-line.
        end.
      end.
      assign r_trn-lin = recid( bf_doc-line ).
      delete-line:
      do on error undo Main-Block, return error return-value :
        find first bf_trn-line exclusive-lock where
            recid( bf_trn-line ) = r_trn-lin.
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  bf_trn-line.obj-type
  ,input  bf_trn-line.obj-code
  ,input  bf_trn-line.artic
  ,input  bf_trn-line.prod-type
  ,input  bf_trn-line.prod-code
  ,input  'inv-on=false'
  ,output l-inv-on
  ) no-error .
        if error-status :error then do:
          if p-talk-on = yes then do:
            message "lib-trn3_invdnull:"                                                      skip( 1 )
                    "Ошибка установки атрибута товара на объекте"                             skip( 0 )
                    "Документ:" '"' + bf_trn-line.doc-code + '"'                              skip( 0 )
                    "Объект:"   bf_trn-line.obj-type bf_trn-line.obj-code                     skip( 0 )
                    "Товар:"    bf_trn-line.artic bf_trn-line.prod-type bf_trn-line.prod-code skip( 0 )
                    "l-inv-on:" l-inv-on                                                      skip( 1 )
            view-as alert-box error.
          end.
          undo, return error substitute( 'lib-trn3_invdnull: Ошибка установки атрибута товара на объекте.&1'
                                       + 'Документ: "&2".&1Объект: &3 &4.&1Товар: &5 &6 &7.&1l-inv-on: &8.'
                                       , chr(10)
                                       , bf_trn-line.doc-code
                                       , bf_trn-line.obj-type
                                       , bf_trn-line.obj-code
                                       , bf_trn-line.artic
                                       , bf_trn-line.prod-type
                                       , bf_trn-line.prod-code
                                       , l-inv-on ).
        end.
        delete bf_trn-line.
      end.
    end.
    find first bf_trn-doc no-lock where
        recid( bf_trn-doc ) = r_trn-doc.
  end.
end procedure.
procedure lib-trn3_chkslpr :
define input parameter pardoc-code  like ub.doc-line.doc-code  no-undo.
define input parameter parartic     like ub.doc-line.artic     no-undo.
define input parameter parprod-type like ub.doc-line.prod-type no-undo.
define input parameter parprod-code like ub.doc-line.prod-code no-undo.
define buffer bf_doc-line for ub.doc-line.
do on error undo, return error return-value :
  find first bf_doc-line where bf_doc-line.doc-code  = pardoc-code  and
                               bf_doc-line.artic     = parartic     and
                               bf_doc-line.prod-type = parprod-type and
                               bf_doc-line.prod-code = parprod-code no-lock.
  run clcprtsl_calc-line in this-procedure (recid(bf_doc-line)) no-error.
  if error-status:error then do:
    return error return-value.
  end.
  find first tt-allsum-line where tt-allsum-line.sum-type = 'основная_сумма':U.
  if sum-dsc-rubl-doc < sum-dsc-rubl-acc then do:
    return error substitute("Цена реализации товара &1 &2 &3 в национальной валюте &4 ниже цены товара по учетным ценам &5.", bf_doc-line.artic, bf_doc-line.prod-type, bf_doc-line.prod-code, sum-dsc-rubl-doc / bf_doc-line.fact-qnty , sum-dsc-rubl-acc / bf_doc-line.fact-qnty).
  end.
  if sum-dsc-base-doc < sum-dsc-base-acc then do:
    return error substitute("Цена реализации товара &1 &2 &3 в базовой валюте &4 ниже цены товара по учетным ценам &5.", bf_doc-line.artic, bf_doc-line.prod-type, bf_doc-line.prod-code, sum-dsc-base-doc / bf_doc-line.fact-qnty, sum-dsc-base-acc / bf_doc-line.fact-qnty).
  end.
end.
end procedure.
procedure lib-trn3_goods-tr :
  define input parameter parrec-doc   as recid no-undo .
  define input parameter parrec-goods as recid no-undo .
  define variable is-hold-doc        as   logical           no-undo .
  define variable can-process        as   logical           no-undo .
  define variable is-petrol          as   logical           no-undo .
  define variable is-pieces          as   logical           no-undo .
  define variable is-petrolium-gds-b as   logical           no-undo .
  define variable is-pieces-gds-b    as   logical           no-undo .
  define variable varres             as   logical           no-undo .
  define variable var-code-temp      like ub.pl-gds.pl-code no-undo .
  define buffer gds-b       for ub.goods    .
  define buffer cg_trn-doc  for ub.trn-doc  .
  define buffer cg_goods    for ub.goods    .
  define buffer cg_doc-line for ub.doc-line .
  define variable l-inv-on          as logical   no-undo .
  define variable v-can-edit-inv-on as character no-undo .
  do
  on error undo, return error return-value
  :
    find first cg_trn-doc where
        recid( cg_trn-doc ) = parrec-doc .
    find first cg_goods   where
        recid( cg_goods )   = parrec-goods .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run trnat in g#library
  (input  cg_trn-doc.doc-type
  ,input  cg_trn-doc.internal
  ,input  cg_trn-doc.discnt-type
  ,input  cg_trn-doc.status_
  ,input  cg_trn-doc.flag_
  ,input  cg_trn-doc.ext-doc-type
  ,input  'can-edit-inv-on=request':u
  ,output v-can-edit-inv-on
  ) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "Невозможно запросить признак складского документа &1 &2"
                                   , error-status :get-message( 1 )
                                   , return-value
                                   ) .
    end.
    if v-can-edit-inv-on <> "true":u
    then do:
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  cg_trn-doc.obj-type
  ,input  cg_trn-doc.obj-code
  ,input  cg_goods.artic
  ,input  cg_goods.prod-type
  ,input  cg_goods.prod-code
  ,input  'inv-on=request'
  ,output l-inv-on
  ) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "Ошибка получения признака товара на объекте &1 &2."
                                     , error-status :get-message( 1 )
                                     , return-value
                                     ) .
      end.
    end.
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  cg_trn-doc.doc-code
  ,output is-hold-doc
  ) no-error .
    if error-status :error
    then do:
      undo, return error "goods-tr: Ошибка получения признака межфирменного перемещения." .
    end.
    if l-inv-on = yes and
       cg_trn-doc.status_ <> 'запрос':U
    then do:
      return error substitute( 'Артикул : &1 "&2" - товар в инвентаризации. Операция невозможна.'
                             , cg_goods.artic
                             , cg_goods.gds-name
                             ) .
    end.
    if lookup( cg_goods.gds-type, 'у':U ) > 0 and
       ( cg_trn-doc.doc-type <> 'рас':U or
         cg_trn-doc.internal  = yes )
    then do:
      return error substitute( 'Выбрана УСЛУГА из справочника. Для документа с типом "&1", а также для внутренних '
                             + 'перемещений услуги не предусмотрены. Артикул &2'
                             , cg_trn-doc.doc-type
                             ,cg_goods.artic
                             ) .
    end.
    if cg_trn-doc.doc-type = 'рас':U and cg_trn-doc.internal = yes or
       cg_trn-doc.doc-type = 'рас':U and cg_trn-doc.internal = no
                                        and is-hold-doc         = yes
    then do:
      run plgdsfnd in this-procedure
        (  input no
        ,  input cg_trn-doc.obj-type
        ,  input cg_trn-doc.obj-code
        ,  input cg_goods.gds-code
        , output varres
        , output var-code-temp
        ) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "Ошибка при проверке привязки товара к складскому месту: &1 &2 &3 &4"
                                     , cg_goods.artic
                                     , cg_goods.prod-type
                                     , cg_goods.prod-code
                                     , return-value
                                     ) .
      end.
      if varres = yes
      then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input cg_goods.artic
  ,  input cg_goods.prod-type
  ,  input cg_goods.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
        if error-status :error or
           is-petrol <> yes or
           is-pieces <> no
        then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_gdnorsrv in g#lib-trn4
  (  input cg_goods.artic
  ,  input cg_goods.prod-type
  ,  input cg_goods.prod-code
  ,  input cg_trn-doc.doc-code
  , output can-process
  )        no-error .
          if error-status :error or
             can-process <> yes
          then do:
          undo, return error substitute( "Товар &1 &2&3 резервируется по складским местам - "
                                       + "&4&5 недопустим."
                                       , cg_goods.artic
                                       , cg_goods.prod-type
                                       , cg_goods.prod-code
                                       , entry( lookup( cg_trn-doc.ext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U )
                                       , ( if is-hold-doc = yes then "(межфирменные перемещения)" else "":U )
                                       ) .
          end.
        end.
      end.
    end.
    find first cg_doc-line no-lock where
               cg_doc-line.doc-code = cg_trn-doc.doc-code no-error .
    if available cg_doc-line
    then do:
      find first gds-b no-lock where
                 gds-b.artic     = cg_doc-line.artic     and
                 gds-b.prod-type = cg_doc-line.prod-type and
                 gds-b.prod-code = cg_doc-line.prod-code .
                if cg_trn-doc.doc-type <> "рас" then do:
              if gds-b.gds-type <> cg_goods.gds-type
              then do:
                return error "Услуги и товары не могут быть добавлены в один и тот же документ." .
              end.
                end.
    end.
    if cg_goods.stts = integer( '1':U )
    then do:
      return error substitute( "Товар &1 &2 &3 удален. Добавление невозможно."
                             , cg_goods.artic
                             , cg_goods.prod-type
                             , cg_goods.prod-code
                             ) .
    end.
    assign
      cg_trn-doc.office = ( cg_goods.gds-type = 'у':U )
    .
  end.
end procedure.
procedure lib-trn3_chkqnpl :
  define input  parameter p-doc-type like ub.trn-doc.doc-type no-undo .
  define input  parameter p-obj-type like ub.doc-pl.obj-type  no-undo .
  define input  parameter p-obj-code like ub.doc-pl.obj-code  no-undo .
  define input  parameter p-pl-code  like ub.doc-pl.pl-code   no-undo .
  define input  parameter p-gds-code like ub.doc-pl.gds-code  no-undo .
  define input  parameter p-msg-on   as logical   no-undo .
  define input  parameter p-qnty     as decimal   no-undo .
  define output parameter p-new-qnty as decimal   no-undo .
  define variable v-rest-qnty as decimal   no-undo .
  define variable v-rest-av   as logical   no-undo .
  define buffer buf-qnty_pl-gds for ub.pl-gds .
  define buffer buf-qnty_place  for ub.place .
  define buffer buf-qnty_goods  for ub.goods .
  assign
    v-rest-qnty = 0
    v-rest-av   = false
    p-new-qnty  = p-qnty
  .
  if is-sug(p-gds-code) then return .
  if p-doc-type = 'инв':U then do:
    return.
  end.
  find first buf-qnty_pl-gds no-lock
    where buf-qnty_pl-gds.obj-type = p-obj-type
      and buf-qnty_pl-gds.obj-code = p-obj-code
      and buf-qnty_pl-gds.pl-code  = p-pl-code
      and buf-qnty_pl-gds.gds-code = p-gds-code
    no-error .
  if not available buf-qnty_pl-gds then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров." skip
      "Место хранения не найдено" skip
      substitute( "код товара: &1", p-gds-code ) skip
      substitute( "объект: &1 &2", p-obj-type, p-obj-code ) skip
      substitute( "код места хранения: &1", p-pl-code ) skip
      view-as alert-box error .
    return error .
  end.
  else do:
    assign
      v-rest-av   = true
    .
  end.
  if p-qnty >= 0 then do:
    find first buf-qnty_goods no-lock
      where buf-qnty_goods.gds-code = p-gds-code
      .
    if p-doc-type = 'при':U
      or p-doc-type = 'возврат':U
    then do:
      assign
        v-rest-qnty = buf-qnty_pl-gds.fact-qnty
      .
      find first buf-qnty_place no-lock
        where buf-qnty_place.obj-type = p-obj-type
          and buf-qnty_place.obj-code = p-obj-code
          and buf-qnty_place.pl-code  = p-pl-code
        no-error .
      if available buf-qnty_place
        and buf-qnty_place.chk-max-qnty = true
        and buf-qnty_place.max-qnty <> ?
        and buf-qnty_place.max-qnty > 0.0
      then do:
        if p-qnty > buf-qnty_place.max-qnty - v-rest-qnty then do:
          if v-rest-av = false
            or buf-qnty_place.max-qnty - v-rest-qnty < 0.0
          then do:
            assign
              p-new-qnty = 0.0
            .
          end.
          else do:
            assign
              p-new-qnty = buf-qnty_place.max-qnty - v-rest-qnty
            .
          end.
          if p-msg-on = true then do:
            find first buf-qnty_goods no-lock
              where buf-qnty_goods.gds-code = p-gds-code
              .
            message
              substitute( "Невозможно установить количество больше чем доступно на месте хранения." ) skip(1)
              substitute( "Попытка установить: &1 (&2)", p-qnty, buf-qnty_goods.unit-base ) skip
              substitute( "Возможно установить: &1 (&2)", p-new-qnty, buf-qnty_goods.unit-base ) skip(1)
              substitute( "Т.к. максимально допустимое для места хранения: &1 (&2),", buf-qnty_place.max-qnty, buf-qnty_goods.unit-base ) skip
              substitute( "а расчетный остаток по месту хранения: &1 (&2).", (if v-rest-av = true then v-rest-qnty else ?), buf-qnty_goods.unit-base ) skip
              view-as alert-box information.
          end.
        end.
      end.
    end.
    else do:
      assign
        v-rest-qnty = buf-qnty_pl-gds.fact-qnty
      .
      if p-qnty > v-rest-qnty then do:
        if v-rest-av = false
          or v-rest-qnty < 0.0
        then do:
          assign
            p-new-qnty = 0.0
          .
        end.
        else do:
          assign
            p-new-qnty = v-rest-qnty
          .
        end.
        if p-msg-on = true then do:
          find first buf-qnty_goods no-lock
            where buf-qnty_goods.gds-code = p-gds-code
            .
          message
            substitute( "Невозможно установить количество больше чем доступно на месте хранения." ) skip(1)
            substitute( "Попытка установить: &1 (&2)", p-qnty, buf-qnty_goods.unit-base ) skip
            substitute( "Возможно установить: &1 (&2)", p-new-qnty, buf-qnty_goods.unit-base ) skip(1)
            substitute( "Т.к. расчетный остаток по месту хранения: &1 (&2).", (if v-rest-av = true then v-rest-qnty else ?), buf-qnty_goods.unit-base ) skip
            view-as alert-box information.
        end.
      end.
    end.
  end.
  else do:
    if p-msg-on = true then do:
      message
        "Невозможно установить количество < 0." skip
        view-as alert-box information.
    end.
    assign
      p-new-qnty = 0.0
    .
  end.
  return .
end procedure.
procedure lib-trn3_avprpart :
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-bar-code   as integer   no-undo .
define input  parameter p-node-code  as integer   no-undo .
define input  parameter p-fact-order as decimal   no-undo .
define output parameter p-doc-num    as character no-undo .
define output parameter p-price-sale as decimal   no-undo .
define output parameter p-road-tax   as decimal   no-undo .
define output parameter p-excise     as decimal   no-undo .
define variable p-gds-code as integer   no-undo .
define buffer buf_gds-obj for ub.gds-obj  .
define buffer buf_parts for ub.parts  .
define buffer buf_price-list for ub.price-list  .
define variable v-qnty as decimal   no-undo .
define variable main-b-code as integer   no-undo .
define variable k as integer   no-undo .
  do
  on error undo, return error return-value
  :
  define buffer buf_bar-code for ub.bar-code  .
  find first buf_bar-code no-lock where buf_bar-code.b-code = p-bar-code no-error .
  if error-status :error then return .
  p-gds-code = buf_bar-code.gds-code .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  ?
  ,output main-b-code
  ) no-error .
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  main-b-code
  ,input  0
  ,input  p-fact-order
  ,output p-doc-num
  ,output p-price-sale
  ,output p-road-tax
  ,output p-excise
  ) no-error .
 find first buf_gds-obj no-lock where
            buf_gds-obj.obj-type = p-obj-type and
            buf_gds-obj.obj-code = p-obj-code and
            buf_gds-obj.gds-code = p-gds-code and
            buf_gds-obj.cash-parts = true no-error .
if not available buf_gds-obj then return .
assign
  p-price-sale = 0
  p-road-tax   = 0
  p-excise     = 0
  v-qnty       = 0
.
k = 0.
 for each buf_price-list no-lock where
          buf_price-list.doc-num    = p-doc-num and
          buf_price-list.price-type = "" and
          buf_price-list.main-price = false and
          buf_price-list.artic      = buf_gds-obj.artic and
          buf_price-list.prod-type  = buf_gds-obj.prod-type and
          buf_price-list.prod-code  = buf_gds-obj.prod-code and
          buf_price-list.doc-qnty > 0
          :
          k = k + 1.
          p-price-sale = p-price-sale + buf_price-list.price-sale * buf_price-list.doc-qnty.
          p-road-tax   = p-road-tax   + buf_price-list.road-tax * buf_price-list.doc-qnty.
          p-excise     = p-excise     + buf_price-list.excise * buf_price-list.doc-qnty.
          v-qnty       = v-qnty + buf_price-list.doc-qnty.
  end.
  if k = 0 then do:
    for each buf_price-list no-lock where
              buf_price-list.doc-num    = p-doc-num and
              buf_price-list.price-type = "" and
              buf_price-list.b-code     = main-b-code and
              buf_price-list.main-price = true and
              buf_price-list.artic      = buf_gds-obj.artic and
              buf_price-list.prod-type  = buf_gds-obj.prod-type and
              buf_price-list.prod-code  = buf_gds-obj.prod-code
              :
              p-price-sale =  buf_price-list.price-sale .
              p-road-tax   =  buf_price-list.road-tax .
              p-excise     =  buf_price-list.excise.
              v-qnty       =  0 .
      end.
  end.
  else do:
      assign
        p-price-sale = p-price-sale / v-qnty
        p-road-tax   = p-road-tax   / v-qnty
        p-excise     = p-excise     / v-qnty
      .
  end.
  if p-price-sale = ? then p-price-sale = 0.
  if p-road-tax   = ? then p-road-tax = 0.
  if p-excise     = ? then p-excise  = 0.
  end.
end procedure.
procedure CrTempDump:
   define input parameter p-obj-type as character no-undo.
   define input parameter p-obj-code as integer no-undo.
   define input parameter p-shift-date as date no-undo.
   define input parameter p-shift-num as integer no-undo.
   define input parameter p-pl-code as integer no-undo.
   define input parameter p-gds-code as integer no-undo.
   define buffer buf_rvs-doc for ub.rvs-doc.
   define buffer buf_rvs-line for ub.rvs-line.
   define buffer buf_rvs-doc_end for ub.rvs-doc.
   define buffer buf_doc-line-attr  for ub.doc-line-attr.
   define buffer buf_doc-line-attr1 for ub.doc-line-attr.
   define variable vBegTime as datetime no-undo.
   define variable vEndTime as datetime no-undo.
   define variable vTimeAutoSkip as integer no-undo.
   vTimeAutoSkip = if ptrlprop-autopump-skip-time <> ? then ptrlprop-autopump-skip-time else 0.
   rvsdoc:
   for each buf_rvs-doc no-lock
        where buf_rvs-doc.obj-type   = p-obj-type
          and buf_rvs-doc.obj-code   = p-obj-code
          and buf_rvs-doc.shift-date = p-shift-date
          and buf_rvs-doc.shift-num  = p-shift-num
          and buf_rvs-doc.status_    = 'факт':U
          and buf_rvs-doc.rvs-type  = 'перед_док':U
        ,first buf_rvs-line no-lock
        where buf_rvs-line.rvs-code   = buf_rvs-doc.rvs-code
          and buf_rvs-line.obj-type   = buf_rvs-doc.obj-type
          and buf_rvs-line.obj-code   = buf_rvs-doc.obj-code
          and buf_rvs-line.pl-code    = p-pl-code
          and buf_rvs-line.gds-code   = p-gds-code:
      find first  buf_rvs-doc_end no-lock
           where buf_rvs-doc_end.rvs-type = 'после_док':U
          and buf_rvs-doc_end.out-code =  buf_rvs-doc.out-code
          no-error.
      if not avail buf_rvs-doc_end then next  rvsdoc.
      find first buf_doc-line-attr no-lock where
                 buf_doc-line-attr.doc-code = buf_rvs-doc.out-code
             and buf_doc-line-attr.gds-code = buf_rvs-line.gds-code
             and buf_doc-line-attr.attr-code begins "date-start"
         no-error.
      find first buf_doc-line-attr1 no-lock where
                 buf_doc-line-attr1.doc-code = buf_rvs-doc.out-code
             and buf_doc-line-attr1.gds-code = buf_rvs-line.gds-code
             and buf_doc-line-attr1.attr-code begins "time-start"
         no-error.
      if available buf_doc-line-attr and
         available buf_doc-line-attr1
      then  vBegTime = datetime(date(buf_doc-line-attr.attr-value), (int(buf_doc-line-attr1.attr-value) * 1000 )).
      else  vBegTime = datetime(buf_rvs-doc.sys-date, (buf_rvs-doc.sys-time-int * 1000 )).
      find first buf_doc-line-attr no-lock where
                 buf_doc-line-attr.doc-code = buf_rvs-doc.out-code
             and buf_doc-line-attr.gds-code = buf_rvs-line.gds-code
             and buf_doc-line-attr.attr-code begins "date-end"
         no-error.
      find first buf_doc-line-attr1 no-lock where
                 buf_doc-line-attr1.doc-code = buf_rvs-doc.out-code
             and buf_doc-line-attr1.gds-code = buf_rvs-line.gds-code
             and buf_doc-line-attr1.attr-code begins "time-end"
         no-error.
      if available buf_doc-line-attr and
         available buf_doc-line-attr1
      then  vEndTime = datetime(date(buf_doc-line-attr.attr-value), ((int(buf_doc-line-attr1.attr-value) + vTimeAutoSkip * 60) * 1000 )).
      else  vEndTime = datetime(buf_rvs-doc_end.sys-date, ((buf_rvs-doc_end.sys-time-int + vTimeAutoSkip * 60) * 1000 )).
      create ttDump.
      assign
         ttDump.BegTime = vBegTime
         ttDump.EndTime = vEndTime
         .
      if session:debug-alert
      then do:
         OUTPUT STREAM out_s TO "avrgdens.log" APPEND.
         put stream out_s unformatted "Приемка топлива: "
         " Начало слива " ttDump.BegTime
         " Конец слива плюс время пропуска после слива " ttDump.EndTime
         " Время пропуска автосверок после слива " vTimeAutoSkip
         " Топливо " p-pl-code
         " Код товара " p-gds-code
         skip.
         OUTPUT STREAM out_s CLOSE.
      end.
   end.
end procedure.
procedure ChkRvsSkip:
   define input parameter p-obj-type     as character no-undo.
   define input parameter p-obj-code     as integer   no-undo.
   define input parameter p-rvs-code     as character no-undo.
   define input parameter p-pl-code      as integer   no-undo.
   define input parameter p-gds-code     as integer   no-undo.
   define input parameter p-sys-date     as date      no-undo.
   define input parameter p-sys-time-int as integer   no-undo.
   define output parameter vNeedSkip     as logical   no-undo.
   define buffer buf_doc-attr      for ub.doc-attr.
   define buffer buf_rvs-line-attr for ub.rvs-line-attr.
   vNeedSkip = no.
   if can-find(first buf_doc-attr no-lock where
                     buf_doc-attr.doc-code = p-rvs-code
                 and buf_doc-attr.attr-code = "rvs-auto"
                 and buf_doc-attr.attr-value = "Yes")
       and can-find(first buf_rvs-line-attr no-lock where
                          buf_rvs-line-attr.obj-code  = p-obj-code
                      and buf_rvs-line-attr.obj-type  = p-obj-type
                      and buf_rvs-line-attr.gds-code  = p-gds-code
                      and buf_rvs-line-attr.pl-code   = p-pl-code
                      and buf_rvs-line-attr.rvs-code  = p-rvs-code
                      and buf_rvs-line-attr.attr-code = "rvd-on"
                      and buf_rvs-line-attr.attr-value > "")
   then vNeedSkip = yes.
   else do:
      find first ttDump where
                 ttDump.BegTime <= datetime(p-sys-date, (p-sys-time-int * 1000 ))
             and ttDump.EndTime >= datetime(p-sys-date, (p-sys-time-int * 1000 ))
             no-error.
      if available ttDump then do:
         if session:debug-alert
         then do:
            OUTPUT STREAM out_s TO "avrgdens.log" APPEND.
            put stream out_s unformatted "Пропуск автосверки из-за попадания в период слива: "
            " Время сверки " datetime(p-sys-date, (p-sys-time-int * 1000 ))
            " Начало слива " ttDump.BegTime
            " Конец слива плюс время пропуска после слива " ttDump.EndTime
            " Топливо " p-pl-code
            " Код товара " p-gds-code
            skip.
            OUTPUT STREAM out_s CLOSE.
         end.
         vNeedSkip = yes.
      end.
   end.
end procedure.
