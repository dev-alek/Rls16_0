block-level on error undo, throw.
define input parameter p-silent   as logical no-undo .
define input parameter pardoc-code like ub.wth-doc.doc-code no-undo .
define input parameter parhost-code like ub.wth-doc.host-code no-undo .
define input parameter parobj-type like ub.wth-doc.obj-type no-undo .
define input parameter parobj-code like ub.wth-doc.obj-code no-undo .
define input parameter parcli-type like ub.wth-doc.cli-type no-undo .
define input parameter parcli-code like ub.wth-doc.cli-code no-undo .
define input parameter par-operator like ub.wth-doc.operator no-undo .
define input parameter par-deliver like ub.wth-doc.deliver no-undo .
define input parameter par-receiver like ub.wth-doc.receiver no-undo .
define input parameter pardoc-type like ub.wth-doc.doc-type no-undo .
define input parameter parauto-fill like ub.wth-doc.auto-fill no-undo .
define input parameter par-exter_ like ub.wth-doc.exter_ no-undo .
define input parameter par-inter_ like ub.wth-doc.inter_ no-undo .
define input parameter parsource-ref like ub.wth-doc.source-ref no-undo .
define input parameter parsource-type like ub.wth-doc.source-type no-undo .
define input parameter par-borned like ub.wth-doc.borned no-undo .
define input parameter parlines-exist as logical no-undo .
define input parameter parext-type as character no-undo.
define output parameter parcli-name like ub.clients.obj-name no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка корректности данных в документе МЦ не инвент".
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
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message (1)).
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
DEFINE VARIABLE var-entry as character no-undo .
define variable v-mes     as character no-undo .
define variable v-file    as logical no-undo .
define variable v-type as character no-undo .
define buffer buf_clients for ub.clients .
define buffer buf_wth-line for ub.wth-line .
define buffer current-place for ub.wth-place .
define buffer out-place for ub.wth-place .
define buffer buf_operator for ub.clients .
define buffer buf_deliver for ub.clients .
define buffer buf_receiver for ub.clients .
define buffer bind_wth-doc for ub.wth-doc .
define buffer bind_inkas for ub.inkas .
define variable v-chk-wth-prs  as logical   no-undo.
define variable conf-par as character no-undo.
define variable par-type as character no-undo.
_main:
do
on error undo, return error
:
FIND FIRST ub.sysconf No-LOCK WHERE
           ub.sysconf.host-code = parhost-code No-ERROR.
IF NOT AVAIL ub.sysconf THEN DO:
  v-mes = substitute("Не найдена фирма &1", parhost-code).
  run err-mess(input-output v-mes).
  undo _main, return error v-mes.
END.
if lookup(parext-type,'rj,rf,rp':U) > 0 and pardoc-type <> 'возврат':U or
   lookup(parext-type,'we,dc,dp,df':U) > 0 and pardoc-type <> 'спи':U or
   lookup(parext-type,'ee,ei,ej,jj,oj,ce,ef,ep':U) > 0 and pardoc-type <> 'рас':U or
   lookup(parext-type,'ie,ii,ij,fj,pj,ip,ff,pc,ps,pz,ci':U) > 0 and pardoc-type <> 'при':U then do:
     v-mes = substitute("Расширенный тип документа &1 не соответствует типу документа &2",parext-type, pardoc-type).
     run err-mess(input-output v-mes).
     undo _main, return error (v-mes).
end.
if parauto-fill and parobj-type = 'скл':U then do:
  v-mes = substitute("Для автоматического документа объект документа &1&2 должен быть магазином", parobj-type, parobj-code).
  run err-mess(input-output v-mes).
  var-entry = "obj-code":U.
  undo _main, return error (if p-silent then v-mes else var-entry).
end.
if parauto-fill and pardoc-type = 'спи':U then do:
  v-mes = substitute("Не бывает автоматических документов с типом", pardoc-type).
  run err-mess(input-output v-mes).
  undo _main, return error (v-mes).
end.
if parauto-fill and parlines-exist then do:
  if (
      (parcli-type = ub.sysconf.sale-type AND
       parcli-code = ub.sysconf.sale-code) AND
       can-find(first ub.chk-doc No-LOCK WHERE
                      ub.chk-doc.obj-type = parobj-type
                  and ub.chk-doc.obj-code = parobj-code
                  and ub.chk-doc.out-code = pardoc-code)
     ) then do:
    v-mes = substitute("К автодокументу МЦ для контрагента &1&2 не могут быть привязаны чеки МЦ", parcli-type, parcli-code).
    run err-mess(input-output v-mes).
    undo _main, return error (v-mes).
  end.
  if ( not par-borned and
       NOT (parcli-type = ub.sysconf.sale-type AND
           parcli-code = ub.sysconf.sale-code) AND
       NOT can-find(first ub.chk-doc No-LOCK WHERE
                          ub.chk-doc.out-code = pardoc-code)
    ) then do:
    v-mes = substitute("К данному автодокументу должны быть привязаны чеки МЦ").
    run err-mess(input-output v-mes).
    undo _main, return error (v-mes).
  end.
end.
FIND FIRST buf_clients No-LOCK WHERE
          buf_clients.obj-type = parcli-type AND
          buf_clients.obj-code = parcli-code NO-ERROR.
IF NOT AVAIL buf_clients THEN DO:
  v-mes = substitute("Не найден клиент &1&2 в справочнике клиентов", parcli-type, parcli-code).
  run err-mess(input-output v-mes).
  var-entry = "cli-type":U.
  undo _main, return error (if p-silent then v-mes else var-entry).
END.
if buf_clients.stts <> 0 then do:
  v-mes = substitute( "Нельзя создавать документ для удаленного контрагента &1&2", parcli-type, parcli-code).
  run err-mess(input-output v-mes).
  var-entry = "cli-type":U.
  undo _main, return error (if p-silent then v-mes else var-entry).
end.
parcli-name = buf_clients.obj-name.
IF par-inter_ AND
 NOT ( parcli-type = parobj-type AND
       parcli-code = parobj-code) then do:
  v-mes = substitute( "Для документа внутриобъектного перемещения МЦ неверно определен клиент &1&2", parcli-type, parcli-code).
  run err-mess(input-output v-mes).
  var-entry = "cli-type":U.
  undo _main, return error (if p-silent then v-mes else var-entry).
end.
IF par-exter_ and not parext-type = 'ps':U then do:
  IF
  (parcli-type = parobj-type AND
  parcli-code = parobj-code) OR
  parcli-type = 'маг':U OR
  parcli-type = 'скл':U
  then do:
    v-mes = substitute( "Для документа внешнего перемещения МЦ неверно определен клиент &1&2", parcli-type, parcli-code).
    run err-mess(input-output v-mes).
    var-entry = "cli-code":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
end.
else if  parext-type = 'ps':U then do:
 IF NOT ( parcli-type = 'маг':U OR
          parcli-type = 'скл':U) then do:
    message "Для документа погашения МЦ неверно определен клиент"
    view-as alert-box error .
    var-entry =  "cli-type":U.
    RETURN ERROR var-entry.
  END.
end.
else do:
 IF NOT ( parcli-type = 'маг':U OR
          parcli-type = 'скл':U) then do:
    message "Для документа внутренного перемещения МЦ неверно определен клиент"
    view-as alert-box error .
    var-entry =  "cli-type":U.
    RETURN ERROR var-entry.
  END.
  CASE parcli-type:
    when 'маг':U then do:
      FIND FIRST ub.shop no-LOCK WHERE
                 ub.shop.obj-code = parcli-code No-ERROR.
      if not avail ub.shop or ub.shop.host-code <> parhost-code then do:
        message "Для документа внутренного перемещения МЦ неверно определен клиент" SKIP
                "магазин принадлежит другой фирме"
        view-as alert-box .
        var-entry =  "cli-code":U.
      end.
    end.
    when 'скл':U then do:
      FIND FIRST ub.store no-LOCK WHERE
                 ub.store.obj-code = parcli-code No-ERROR.
      if not avail ub.store or ub.store.host-code <> parhost-code then do:
        message "Для документа внутренного перемещения МЦ неверно определен клиент" SKIP
                "склад принадлежит другой фирме"
        view-as alert-box .
        var-entry =  "cli-code":U.
      end.
    end.
  END CASE.
end.
if pardoc-type = 'спи':U and
   (par-inter_ or
    (par-exter_ AND NOT (parcli-type = 'орг':U AND parcli-code = parhost-code))
   ) then do:
  v-mes = substitute( "Для документа внутреннего перемещения МЦ типа &1 неверно определен клиент &2&3&4склад принадлежит другой фирме"
                     , pardoc-type
                     , parcli-type
                     , parcli-code
                     , chr(10)
                     ).
  run err-mess(input-output v-mes).
  var-entry = "cli-code":U.
  undo _main, return error (if p-silent then v-mes else var-entry).
end.
FIND FIRST buf_wth-line No-LOCK WHERE
           buf_wth-line.doc-code = pardoc-code No-ERROR.
IF AVAIL buf_wth-line then do:
  if parext-type <> 'dc':U then do:
    FIND FIRST current-place NO-LOCK WHERE
        current-place.host-code   = parhost-code AND
        current-place.obj-type    = parobj-type AND
        current-place.obj-code    = parobj-code AND
        current-place.w-p-code    = buf_wth-line.w-p-code  NO-ERROR.
    IF NOT AVAIL current-place and
        not (buf_wth-line.w-p-code = 0 or buf_wth-line.w-p-code = ?)
    THEN DO:
      v-mes = substitute( "Не найдено место хранения МЦ &1 в справочнике!"
                          ,buf_wth-line.w-p-code
                        ).
      run err-mess(input-output v-mes).
      var-entry = "current-w-p-code":U.
      undo _main, return error (if p-silent then v-mes else var-entry).
    END.
  end.
  if parauto-fill and current-place.cash-desk = 0 and not par-borned  then do:
    v-mes = substitute( "Для автоматического документа МХ МЦ &1 должно быть кассой"
                        ,buf_wth-line.w-p-code
                      ).
    run err-mess(input-output v-mes).
    var-entry = "current-w-p-code":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
  if parobj-type = parcli-type AND
     parobj-code = parcli-code and
     par-inter_  = yes         and
    (buf_wth-line.out-code = 0 or buf_wth-line.out-code = ?) THEN DO:
    v-mes = substitute( "Для внутриобъектного перемещения не указано место хранения!"
                        ,buf_wth-line.out-code
                      ).
    run err-mess(input-output v-mes).
    var-entry = "out-w-p-code":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
  FIND FIRST out-place NO-LOCK WHERE
            out-place.host-code   = parhost-code AND
            out-place.obj-type    = parcli-type AND
            out-place.obj-code    = parcli-code AND
            out-place.w-p-code    = buf_wth-line.out-code  NO-ERROR.
  IF NOT AVAIL out-place AND
     buf_wth-line.out-code <> 0 AND
     buf_wth-line.out-code <> ? AND
     pardoc-type <> 'возврат':U and
     pardoc-type <> 'при':U and
     par-exter_ = no  and
     par-inter_ = no THEN DO:
    v-mes = substitute( "Не найдено место хранения МЦ &1 в справочнике!"
                        ,buf_wth-line.out-code
                      ).
    run err-mess(input-output v-mes).
    var-entry = "out-w-p-code":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  END.
  if parauto-fill and par-borned and out-place.cash-desk = 0 then do:
    v-mes = substitute( "Для автоматического документа МХ МЦ &1 должно быть кассой"
                        ,buf_wth-line.out-code
                      ).
    run err-mess(input-output v-mes).
    var-entry = "out-w-p-code":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
  IF parobj-type = parcli-type AND
     parobj-code = parcli-code and
     par-inter_ = yes THEN DO:
    IF current-place.w-p-code = out-place.w-p-code THEN DO:
      v-mes = substitute( "Нельзя перемещать МЦ в место их хранения!"
                          ,buf_wth-line.out-code
                        ).
      run err-mess(input-output v-mes).
      var-entry = "out-w-p-code":U.
      undo _main, return error (if p-silent then v-mes else var-entry).
    END.
    if pardoc-type = 'рас':U then parcli-name = out-place.w-p-name.
    else if pardoc-type = 'при':U then parcli-name = current-place.w-p-name.
  END.
end.
else do:
  if parlines-exist then do:
    v-mes = substitute( "Нет строк в документе!" ).
    run err-mess(input-output v-mes).
    var-entry = "b-add":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
end.
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-stfactpref as character no-undo .
define variable v-numsfact   as integer no-undo .
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
run adm/shattri.p (
    input "get":U
    ,input  parobj-type
    ,input  parobj-code
    ,input  'wthdoc_obj':U
    ,input  'prsdoc':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error  then do:
    v-chk-wth-prs =  v-value-logical.
end.
if par-operator  <> ? or v-chk-wth-prs then do:
  FIND FIRST buf_operator NO-LOCK WHERE
    buf_operator.obj-type = 'чел':U         AND
    buf_operator.obj-code = par-operator NO-ERROR.
  IF NOT AVAIL buf_operator THEN DO:
    v-mes = substitute( "Не найдено физ.лицо &1 в справочнике клиентов!", par-operator ).
    run err-mess(input-output v-mes).
    var-entry = "operator":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  END.
end.
if par-deliver  <> ? or v-chk-wth-prs then do:
  FIND FIRST buf_deliver NO-LOCK WHERE
    buf_deliver.obj-type = 'чел':U         AND
    buf_deliver.obj-code = par-deliver NO-ERROR.
  IF NOT AVAIL buf_deliver THEN DO:
    v-mes = substitute( "Не найдено физ.лицо &1 в справочнике клиентов!", par-deliver ).
    run err-mess(input-output v-mes).
    var-entry = "deliver":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  END.
end.
if par-receiver <> ? or
   (v-chk-wth-prs and
    lookup(parext-type, "ie,ee,pz,xc") = 0)
then do:
  FIND FIRST buf_receiver NO-LOCK WHERE
    buf_receiver.obj-type = 'чел':U         AND
    buf_receiver.obj-code = par-receiver NO-ERROR.
  IF NOT AVAIL buf_receiver THEN DO:
    v-mes = substitute( "Не найдено физ.лицо &1 в справочнике клиентов!", par-receiver ).
    run err-mess(input-output v-mes).
    var-entry = "receiver":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  END.
end.
if parsource-ref <> '':U and parsource-ref <> ? then do:
  if parsource-ref = pardoc-code and parsource-type = 'док.МЦ':U then do:
    v-mes = substitute( "Нельзя связать документ с самим собой!" ).
    run err-mess(input-output v-mes).
    var-entry = "source-ref":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
  CASE parsource-type:
    when 'док.МЦ':U then do:
      IF par-inter_ then do:
        find first bind_wth-doc No-LOCK WHERE
                  bind_wth-doc.doc-code = parsource-ref No-ERROR.
        if not avail bind_wth-doc then do:
          v-mes = substitute("Не найден документ &1 для связи!", parsource-ref ).
          run err-mess(input-output v-mes).
          var-entry = "source-ref":U.
          undo _main, return error (if p-silent then v-mes else var-entry).
        end.
      end.
    end.
    when 'касса':U then do:
      find first bind_inkas No-LOCK WHERE
                bind_inkas.inkas-code = parsource-ref No-ERROR.
      if not avail bind_inkas then do:
        v-mes = substitute("Не найден документ &1 для связи!", parsource-ref ).
        run err-mess(input-output v-mes).
        var-entry = "source-ref":U.
        undo _main, return error (if p-silent then v-mes else var-entry).
      end.
    end.
    OTHERWISE do:
        v-mes = substitute("Неверный тип документа &1 для связи", parsource-type ).
        run err-mess(input-output v-mes).
        var-entry = "source-type":U.
        undo _main, return error (if p-silent then v-mes else var-entry).
    end.
  END CASE.
end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mes as character No-UNDO.
  p-mes = substitute("Документ МЦ №&1: &2&3&4&5", pardoc-code, parobj-type, parobj-code, chr(10), p-mes).
  if not p-silent then
  message
  p-mes
  view-as alert-box error .
END PROCEDURE.
