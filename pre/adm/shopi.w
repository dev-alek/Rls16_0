DEFINE BUFFER locked_clients FOR ub.clients.
DEFINE BUFFER locked_shop FOR ub.shop.
DEFINE NEW SHARED TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE NEW SHARED TEMP-TABLE tt-shop NO-UNDO LIKE ub.shop.
DEFINE INPUT        PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input        parameter p-host-code    like ub.sysconf.host-code no-undo.
define input        parameter p-obj-code     like ub.shop.obj-code no-undo.
define input        parameter p-mode         as character no-undo .
define input-output parameter p-rid          as recid     no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Редактирование и просмотр записи таблицы магазин" .
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
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1)).
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-b-attr :
define input parameter p-mode as character no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define variable v-sts as integer no-undo .
define variable vattr-codes as character no-undo .
define variable vattr-labels as character no-undo .
define variable ii as integer no-undo .
define variable v-attr-code like ub.clients-attr.attr-code no-undo .
define variable attr-label as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
define variable v-global as logical no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-db as logical   no-undo .
define variable attr-value as char no-undo .
define variable v-spr as character no-undo .
define variable v-title as character no-undo .
define variable v-ii as integer no-undo .
define variable v-ok as integer no-undo .
define variable v-rid-list as character no-undo .
define variable v-rec as recid no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-firm-code as integer   no-undo .
define variable v-from-obj-code  as integer no-undo .
define variable v-found as decimal no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.
define buffer buf_db for ub.db.
do
on error undo, return error
:
assign
vattr-codes = "":U
vattr-labels = "":U
.
_II:
DO ii = 1 to num-entries('autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-autotank,cd-type-maria,arh-global,nakl_par,contr-in,rt-trn-doc,overval,inv-obj,rezerv-obj,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,report-glob,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U):
  run thbjattr_code (
                       input entry(ii, 'autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-autotank,cd-type-maria,arh-global,nakl_par,contr-in,rt-trn-doc,overval,inv-obj,rezerv-obj,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,report-glob,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U)
                      ,input   '':U
                      ,output  attr-label
                      ,output  attr-user-can-edit
                      ,output  attr-output-display
                      ,output  attr-other
                      ,output v-prop-list
                      ,output v-prop-type-list
                      ,output v-prop-label-list
                      ,output v-global
                      ,output v-host
                      ,output v-shop
                      ,output v-store
                      ,output v-db
                    ) no-error.
    .
    if NOT error-status:error
    and attr-user-can-edit
    and index(attr-other, "spr-ext=") > 0
    anD (if p-obj-type = 'маг':U
         then v-shop
         else (if p-obj-type = 'скл':U
               then v-store
               else (if p-obj-type = 'орг':U
                     then v-host
                     else (if p-obj-type = 'БД':U
                          then v-db
                          else v-global)
                    )
               )
         ) then do:
      if entry(ii, 'autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-autotank,cd-type-maria,arh-global,nakl_par,contr-in,rt-trn-doc,overval,inv-obj,rezerv-obj,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,report-glob,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U) = 'alias-tpsi':U then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'tpsi'
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
        or (conf-par <> "yes") then next _ii.
      end.
      assign
      vattr-codes = vattr-codes + chr(44) + entry(ii, 'autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-autotank,cd-type-maria,arh-global,nakl_par,contr-in,rt-trn-doc,overval,inv-obj,rezerv-obj,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,report-glob,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U)
      vattr-labels = vattr-labels + chr(44) + attr-label
      .
    end.
end.
CASE p-mode:
  when 'ПРОСМОТР':U then do:
    assign
    v-title = "Выберите типы параметров для просмотра".
  end.
  when 'ИЗМЕНЕНИЕ':U then do:
    assign
    v-title = "Выберите типы параметров для редактирования".
  end.
  when  'КОПИРОВАНИЕ':U then do:
    assign
    v-title = "Выберите типы параметров для копирования".
  end.
END CASE.
run gbl/d-list.w (
               INPUT (if p-mode = 'КОПИРОВАНИЕ':U then "b-sel,b-mark":U else "b-sel":U)
              ,INPUT v-title
              ,INPUT vattr-codes
              ,INPUT vattr-labels
              ,INPUT chr(44)
              ,INPUT "":U
              ,output v-attr-code).
IF v-attr-code = "":u THEN do:
  RETURN ''.
end.
if p-mode = 'ПРОСМОТР':U
or p-mode = 'ИЗМЕНЕНИЕ':U then do:
  run thbjattr_code  in this-procedure (
       input   v-attr-code
      ,input   '':U
      ,output  attr-label
      ,output  attr-user-can-edit
      ,output  attr-output-display
      ,output  attr-other
      ,output v-prop-list
      ,output v-prop-type-list
      ,output v-prop-label-list
      ,output v-global
      ,output v-host
      ,output v-shop
      ,output v-store
      ,output v-db
  ).
  do ii = 1 to num-entries(attr-other, chr(47)):
    if entry(ii, attr-other, chr(47)) begins "spr-ext=":U then do:
      assign
      v-spr = entry(2, entry(ii, attr-other, chr(47)), "=").
    end.
  end.
  run value(v-spr) (
                   input parparentproc
                  ,input p-mode
                  ,input p-obj-type
                  ,input p-obj-code
                  ).
end.
else do:
   if p-obj-type = 'маг':U then do:
    message
    "Выберите магазин для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
      run adm/shops.w ( input parparentproc
                       ,input "b-sel"
                       ,input-output v-rid-list
                       ,no ).
     if v-rid-list = "":U then return.
     find first buf_shop no-lock where
              recid(buf_shop) = integer(v-rid-list) .
     v-from-obj-code = buf_shop.obj-code.
   end.
   if p-obj-type = 'орг':U then do:
      message
      "Выберите ФИРМУ для копирования ПАРАМЕТРОВ"
      view-as alert-box WARNING.
      run adm/sconfs.w (
            input parParentProc
          , input "b-sel":U
          , input no
          , input 0
          , output v-firm-code
          , input-output v-rid-list
      ) no-error.
      if v-rid-list = "":U then return.
    find first buf_sysconf no-lock
                      where recid(buf_sysconf) = integer(entry(1, v-rid-list)).
    v-from-obj-code = buf_sysconf.host-code.
   end.
   if p-obj-type = 'скл':U then do:
    message
    "Выберите склад для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
      run adm/stores.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output v-rid-list
                        ,input no ).
     if v-rid-list = "":U then return.
     find first buf_store no-lock where
              recid(buf_store) = integer(v-rid-list) .
     v-from-obj-code = buf_store.obj-code.
   end.
   if p-obj-type = 'БД':U then do:
      message
      "Выберите БД для копирования ПАРАМЕТРОВ"
      view-as alert-box WARNING.
      run adm/dbs.w (
            input parParentProc
          , input 'ПРОСМОТР':U
          , output v-rec
      ) no-error.
      if v-rec = ? then return.
    find first buf_db no-lock
                      where recid(buf_db) = v-rec.
    v-from-obj-code = buf_db.db-num.
   end.
   if (p-obj-type = 'маг':U
   AND p-obj-code = buf_shop.obj-code )
   or (p-obj-type = 'скл':U
   AND p-obj-code = buf_store.obj-code )
   or (p-obj-type = 'орг':U
   AND p-obj-code = buf_sysconf.host-code )
   or (p-obj-type = 'БД':U
   AND p-obj-code = buf_db.db-num )
   or (p-obj-type = '':U
   AND p-obj-code = 0 )
   then do:
     message "Нельзя копировать ПАРАМЕТРЫ самих в себя"
     view-as alert-box error .
     return error .
   end.
   run waitfram-show in this-procedure ( input "Ждите..." ).
   DO ii = 1 to num-entries(v-attr-code):
      for each thbjattr_thbj-attr:
        delete thbjattr_thbj-attr.
      end.
      assign
      v-ii = v-ii + 1.
      run thbjattr_get-section  in this-procedure (
           input  p-obj-type
          ,input  v-from-obj-code
          ,input  entry(ii, v-attr-code)
          ,input '':U
          ,input-output table thbjattr_thbj-attr
          ,output v-found
                                              ) no-error .
      if not error-status:error then do:
        run thbjattr_set-section in this-procedure (
                                               input p-obj-type
                                              ,input p-obj-code
                                              ,input entry(ii, v-attr-code)
                                              ,input table thbjattr_thbj-attr ) no-error .
        if not error-status:error then
        assign
        v-ok = v-ok + 1
        .
      end.
   end.
   run waitfram-hide in this-procedure .
   if v-ii = v-ok then do:
      message
      substitute("Скопировано &1 параметров с &4&5 на &2&3"
                 , v-ok
                 , p-obj-type
                 , p-obj-code
                 , p-obj-type
                 , v-from-obj-code
                 )
      view-as alert-box .
   end.
   else do:
      message
      substitute("Из &1 параметров удалось скопировать &2 параметров с &3&4 на &5&6"
                 , v-ii
                 , v-ok
                 , p-obj-type
                 , p-obj-code
                 , p-obj-type
                 , v-from-obj-code
                 )
      view-as alert-box WARNING.
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_cli-grp for ub.cli-grp .
define buffer buf_cli-host for ub.clients .
define variable v-db-num like ub.db.db-num no-undo .
define variable all-prt_ like ub.shop.all-prt no-undo.
define variable cd-bc-alt_ like ub.shop.cd-bc-alt no-undo.
define variable cd-bc-base_ like ub.shop.cd-bc-base no-undo.
define variable cd-loc-alt_ like ub.shop.cd-loc-alt no-undo.
define variable cd-loc-base_ like ub.shop.cd-loc-base no-undo.
define variable cd-parts-all_ like ub.shop.cd-parts-all no-undo.
define variable cd-parts-not-blank_ like ub.shop.cd-parts-not-blank no-undo.
define variable cd-parts-ser_ like ub.shop.cd-parts-ser no-undo.
define variable cd-pb-alt_ like ub.shop.cd-pb-alt no-undo.
define variable cd-pb-base_ like ub.shop.cd-pb-base no-undo.
define variable cd-sc-base_ like ub.shop.cd-sc-base no-undo.
define variable ref-list as character no-undo .
define variable new-host-code as integer no-undo .
DEFINE VARIABLE v-envd AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-kpp AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-pharm AS CHARACTER NO-UNDO.
define variable var-type as CHARACTER no-undo .
define variable v-shopi-have-holdfirm    as logical      no-undo.
DEFINE MENU MENU-obj-code
       MENU-ITEM m-choose       LABEL "Подобрать свободный код".
DEFINE BUTTON B-attr
     LABEL "&Параметры"
     SIZE 10 BY 1.
DEFINE BUTTON b-db
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-fbrpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-holdfirm
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-db"
     SIZE 3 BY .86.
DEFINE BUTTON b-host
     LABEL "&Фирма"
     SIZE 10 BY 1.
DEFINE BUTTON b-inpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-invpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-kitchen-store
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-outpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-realpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-reset
     LABEL "&Уст.Сист.":L
     SIZE 10 BY 1.
DEFINE BUTTON b-retpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-spipay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-sub-store
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-suppay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .91.
DEFINE BUTTON b-tocd
     LABEL "&На кассу"
     SIZE 10 BY 1.
DEFINE BUTTON Btn_trn-reason
     LABEL "Коды оснований"
     SIZE 18 BY 1 TOOLTIP "Код оснований (причин) создания документов по умолчанию на складе".
DEFINE BUTTON CliPS
     LABEL "&Доп. инф."
     SIZE 10 BY 1.
DEFINE VARIABLE varpurch-code-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип приобретения"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 26 BY 1 NO-UNDO.
DEFINE VARIABLE fi-holdfirm-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Фирма для накладных"
      VIEW-AS TEXT
     SIZE 6.6 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-holdfirm-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 18.6 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE KPP AS CHARACTER FORMAT "X(25)":U NO-UNDO
          LABEL "КПП"
          VIEW-AS FILL-IN
          SIZE 19.2 BY .91
          BGCOLOR 15  .
DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 31.2 BY 9.33
     BGCOLOR 8 .
DEFINE RECTANGLE RECT-kitchen-store
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 31.8 BY 1.29.
DEFINE RECTANGLE RECT-sub-store
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 31.8 BY 1.52.
DEFINE VARIABLE varenvd AS LOGICAL INITIAL no
     LABEL "Без НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 11.2 BY .81 NO-UNDO.
DEFINE VARIABLE varpharm AS LOGICAL INITIAL no
     LABEL "Аптека"
     VIEW-AS TOGGLE-BOX
     SIZE 11.2 BY .81 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-shop,
      locked_clients,
      tt-clients SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-reset AT ROW 1 COL 31
     CliPS AT ROW 1 COL 41
     b-tocd AT ROW 1 COL 51
     b-host AT ROW 1 COL 61
     tt-clients.db-num AT ROW 1 COL 80 COLON-ALIGNED
          LABEL "Номер БД" FORMAT ">>>>>>>>9"
          VIEW-AS FILL-IN
          SIZE 6 BY .91
          BGCOLOR 15
     b-db AT ROW 1 COL 88.6
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-shop.obj-code AT ROW 2 COL 5.2 COLON-ALIGNED
          LABEL " Код" format ">>>>>>>>9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
          BGCOLOR 15 FGCOLOR 0
     tt-clients.obj-name AT ROW 2 COL 22 COLON-ALIGNED
          LABEL "Название"
          VIEW-AS FILL-IN
          SIZE 46.6 BY 1
          BGCOLOR 15
     B-attr AT ROW 2 COL 71
     Btn_trn-reason AT ROW 2 COL 81
     tt-shop.director AT ROW 3.1 COL 7 COLON-ALIGNED
          LABEL "Дир-р" FORMAT "X(50)"
          VIEW-AS FILL-IN
          SIZE 64 BY 1
          BGCOLOR 15
     KPP AT ROW 3.29 COL 78 COLON-ALIGNED WIDGET-ID 6
     tt-shop.addres1 AT ROW 4.19 COL 7 COLON-ALIGNED
          LABEL "Адрес" FORMAT "X(80)"
          VIEW-AS FILL-IN
          SIZE 64 BY 1
          BGCOLOR 15
     tt-shop.phone AT ROW 4.29 COL 78 COLON-ALIGNED
          LABEL "Тел-н"
          VIEW-AS FILL-IN
          SIZE 19.2 BY .91
          BGCOLOR 15
     tt-shop.addres2 AT ROW 5.29 COL 7 COLON-ALIGNED NO-LABEL WIDGET-ID 2 FORMAT "X(80)"
          VIEW-AS FILL-IN
          SIZE 64 BY 1
          BGCOLOR 15
     tt-shop.fax AT ROW 5.29 COL 78 COLON-ALIGNED
          LABEL "Факс"
          VIEW-AS FILL-IN
          SIZE 19.2 BY 1
          BGCOLOR 15
     tt-shop.rsrv-time AT ROW 6.29 COL 38.5 COLON-ALIGNED
          LABEL "Период ре&зерв-ния (дней)"
          VIEW-AS FILL-IN
          SIZE 4 BY .91
          BGCOLOR 15
     tt-shop.doc-prt AT ROW 7.29 COL 55
          LABEL "Учет по шкалам"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.price-calc AT ROW 8.1 COL 55
          LABEL "Запрещен приход при неравенстве цен"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.in-pay AT ROW 8.19 COL 18.8 COLON-ALIGNED
          LABEL "Оплата п&рихода"
          VIEW-AS FILL-IN
          SIZE 6 BY .91
          BGCOLOR 15
     b-inpay AT ROW 8.19 COL 27.6
     tt-shop.no-eq AT ROW 9 COL 55
          LABEL "Запрещен приход при отсутствии цен"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.out-pay AT ROW 9.19 COL 18.8 COLON-ALIGNED
          LABEL "рас&хода"
          VIEW-AS FILL-IN
          SIZE 6 BY .91
          BGCOLOR 15
     b-outpay AT ROW 9.19 COL 27.6
     tt-shop.unit-cli-perm AT ROW 9.91 COL 55
          LABEL "&Изменение ед. изм. поставщика"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.ret-pay AT ROW 10.19 COL 18.8 COLON-ALIGNED
          LABEL "во&зврата"
          VIEW-AS FILL-IN
          SIZE 6 BY .91
          BGCOLOR 15
     b-retpay AT ROW 10.19 COL 27.6
     tt-shop.out-rate AT ROW 10.81 COL 55
          LABEL "Изменение &курса РН"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.in-perm AT ROW 10.91 COL 55
          LABEL "Переме&щение по цене магазина"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     tt-shop.ret-sup-pay AT ROW 11.19 COL 18.8 COLON-ALIGNED
          LABEL "возвра&та пост."
          VIEW-AS FILL-IN
          SIZE 6 BY .91
          BGCOLOR 15
     b-suppay AT ROW 11.19 COL 27.6
     tt-shop.out-line-discnt AT ROW 11.71 COL 55
          LABEL "&Скидка по строке РН"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.down-pay AT ROW 12.19 COL 18.8 COLON-ALIGNED
          LABEL "списани&я"
          VIEW-AS FILL-IN
          SIZE 6 BY .91
          BGCOLOR 15
     b-spipay AT ROW 12.19 COL 27.6
     tt-shop.in-ov AT ROW 12.57 COL 55
          LABEL "Запрет движения без переоценки после ПН"
          VIEW-AS TOGGLE-BOX
          SIZE 42 BY .81
     tt-shop.inv-pay AT ROW 13.19 COL 18.8 COLON-ALIGNED
          LABEL "и&нвентаризации"
          VIEW-AS FILL-IN
          SIZE 6 BY .91
          BGCOLOR 15
     b-invpay AT ROW 13.19 COL 27.6
     tt-shop.inout-price AT ROW 13.52 COL 55
          LABEL "Изменение налогов в ПН"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.chk-pay AT ROW 14.19 COL 18.8 COLON-ALIGNED
          LABEL "прода&жи"
          VIEW-AS FILL-IN
          SIZE 6 BY .91
          BGCOLOR 15
     b-realpay AT ROW 14.19 COL 27.6
     tt-shop.day-only AT ROW 14.43 COL 55
          LABEL "В кассовом отчете чеки смены одного дня"
          VIEW-AS TOGGLE-BOX
          SIZE 42.6 BY .81
     tt-shop.fbr-pay AT ROW 15.19 COL 18.8 COLON-ALIGNED
          LABEL "производства"
          VIEW-AS FILL-IN
          SIZE 6 BY .91
     b-fbrpay AT ROW 15.19 COL 27.6
     tt-shop.buy-goods AT ROW 15.29 COL 55
          LABEL "Приоритетная продажа выкупного товара"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.with-serv AT ROW 16.19 COL 55
          LABEL "Магазин реализует услуги"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.pr-cash AT ROW 17.19 COL 55
          LABEL "Разрешить переоценку без блокировки"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.sub-store-type AT ROW 17.95 COL 2.4 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 7.6 BY 1
     tt-shop.sub-store-code AT ROW 17.95 COL 15 COLON-ALIGNED
          LABEL " Код"
          VIEW-AS FILL-IN
          SIZE 9.2 BY 1
     b-sub-store AT ROW 17.95 COL 28.6
     tt-shop.discaloc AT ROW 18.1 COL 55
          LABEL "~"Размазывать~" скидку на итог"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.shift-on AT ROW 19 COL 55
          LABEL "Включены смены"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.kitchen-store-code AT ROW 19.71 COL 17.4 COLON-ALIGNED
          LABEL "Склад кухни"
          VIEW-AS FILL-IN
          SIZE 9.2 BY 1
     b-kitchen-store AT ROW 19.76 COL 28.8
     tt-shop.sub-store-on AT ROW 19.81 COL 55
          LABEL "Склад-подсобка"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.is-catering AT ROW 20.52 COL 55
          LABEL "Ресторан"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     varpurch-code-name AT ROW 21 COL 18.8 COLON-ALIGNED
     tt-shop.is-kitchen AT ROW 21.29 COL 55
          LABEL "Кухня(объект производства)"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     b-holdfirm AT ROW 22.5 COL 30.5
     tt-shop.is-kitchen-store AT ROW 22.05 COL 55
          LABEL "Склад для кухни"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .79
     varenvd AT ROW 23.5 COL 55
     varpharm AT ROW 23.5 COL 65.5 WIDGET-ID 4
     fi-holdfirm-code AT ROW 22.5 COL 22 COLON-ALIGNED
     fi-holdfirm-name AT ROW 22.5 COL 32 COLON-ALIGNED NO-LABEL
     "Склад-подсобка" VIEW-AS TEXT
          SIZE 31.38 BY .67 AT ROW 17 COL 1
     "Оплаты :" VIEW-AS TEXT
          SIZE 8.5 BY .92 AT ROW 7.21 COL 3.38
          FGCOLOR 4
     RECT-10 AT ROW 7.42 COL 1.25
     RECT-kitchen-store AT ROW 19.5 COL 1
     RECT-sub-store AT ROW 17.75 COL 1
     SPACE(66.57) SKIP(5.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки магазина"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       tt-shop.obj-code:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-obj-code:HANDLE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-attr IN FRAME Dialog-Frame
DO:
   RUN proc-b-attr IN THIS-PROCEDURE ('ПРОСМОТР':U, 'маг':U, locked_shop.obj-code) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-db IN FRAME Dialog-Frame
DO:
define variable ri as recid no-undo.
define buffer buf_db for ub.db.
  run adm/dbs.w (
                input parparentproc
               ,input 'ПРОСМОТР':U
               ,output ri).
  if ri <> ?
  then do:
    find buf_db where recid (buf_db) = ri .
    display
    buf_db.db-num @ tt-clients.db-num
    with frame Dialog-Frame.
  end.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  run proc-save in this-procedure(yes) no-error.
    if error-status:error then return no-apply.
END.
ON CHOOSE OF b-fbrpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = integer(ref-rec) NO-LOCK .
        assign
        tt-shop.fbr-pay = buf_pay-type.obj-code .
        display
        tt-shop.fbr-pay
        with frame Dialog-Frame.
    end.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo .
     run ref/cclihist.w (
                      input parparentproc
                    , input 0
                    , input "":U
                    , input 0
                    , input "":U
                    , "one":U
                    , input 'маг':U
                    , input tt-shop.obj-code
                    , input ?
                    , input ?
                    , input "":U
                    , input "":U
                    , input v-cntxt-db-num
                    , input-output v-rid-list  ) no-error .
END.
ON CHOOSE OF b-holdfirm IN FRAME Dialog-Frame
DO:
    define variable v-ref-list  as character    no-undo.
    define variable v-firm-code as integer    no-undo.
    assign
        fi-holdfirm-code
    .
    run adm/sconfs.w (
          input parParentProc
        , input "b-sel":U
        , input no
        , input fi-holdfirm-code
        , output v-firm-code
        , input-output ref-list
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка выбора фирмы."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-firm-code = ?
    or v-firm-code = 0
    then do:
        message "Фирма не выбрана."
        view-as alert-box warning.
        return no-apply.
    end.
    else do:
        define buffer buf_clients for ub.clients.
        find first buf_clients no-lock
             where buf_clients.obj-type = 'орг':U
               and buf_clients.obj-code = v-firm-code
        no-error.
        if available buf_clients
        then do:
            assign
                fi-holdfirm-code = v-firm-code
                fi-holdfirm-name = buf_clients.obj-name
            .
        end.
        else do:
            assign
                fi-holdfirm-code = 0
                fi-holdfirm-name = "":U
            .
        end.
        display
            fi-holdfirm-code
            fi-holdfirm-name
        with frame Dialog-Frame.
    end.
END.
ON CHOOSE OF b-host IN FRAME Dialog-Frame
DO:
define variable ref-list as char no-undo.
define variable glog as logical no-undo .
IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
  run adm/sconfs.w (
                 input parParentProc
                ,input "b-sel":U
                ,input no
                ,input p-host-code
                ,output new-host-code
                ,input-output ref-list ) .
  .
  if new-host-code = ?
  or new-host-code = 0
  then do:
    message "Фирма не выбрана."
            view-as alert-box error.
    return no-apply.
  end.
  if tt-shop.host-code <> 0 then do:
    message
    "Проставить коды оплат для типов документов, параметры отсылки на кассу и др. согласно настройкам выбранной фирмы?"
    view-as alert-box question buttons yes-no update glog.
  end.
  else do:
    glog = yes.
  end.
  tt-shop.host-code = new-host-code.
  find first buf_cli-host where
            buf_cli-host.obj-type = 'орг':U
        and buf_cli-host.obj-code = tt-shop.host-code no-lock.
  CASE p-mode:
    when 'ПРОСМОТР':U then
    frame Dialog-Frame:title = "МАГАЗИН  фирмы : " + buf_cli-host.obj-name + "               " + "ПРОСМОТР".
    when 'ДОБАВЛЕНИЕ':U then
    frame Dialog-Frame:title = "МАГАЗИН  фирмы : " + buf_cli-host.obj-name + "               " + "ДОБАВЛЕНИЕ".
    when 'ИЗМЕНЕНИЕ':U then
    frame Dialog-Frame:title = "МАГАЗИН  фирмы : " + buf_cli-host.obj-name + "               " + "ИЗМЕНЕНИЕ".
  END CASE.
  if glog then do:
    run reset-from-sysconf in this-procedure ( input yes
                                              , input tt-shop.host-code
                                                      ).
  end.
END.
ELSE DO:
      run adm/config.w (
                          input parparentproc
                         ,input tt-shop.host-code
                         ,input  'ПРОСМОТР':U
                         ,input no
                         ) no-error.
    if error-status:error then return no-apply.
END.
END.
ON CHOOSE OF b-inpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                recid( buf_pay-type ) = integer(ref-rec) NO-LOCK .
        assign
        tt-shop.in-pay = buf_pay-type.obj-code .
        display tt-shop.in-pay with frame Dialog-Frame.
   end.
END.
ON CHOOSE OF b-invpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then  return no-apply.
    else do:
        FIND buf_pay-type WHERE
               recid( buf_pay-type ) = integer(ref-rec) NO-LOCK .
        assign
        tt-shop.inv-pay = buf_pay-type.obj-code .
        display
              tt-shop.inv-pay with frame Dialog-Frame.
    end.
END.
ON CHOOSE OF b-kitchen-store IN FRAME Dialog-Frame
DO:
  define variable v-user-select as logical   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .
  define variable rid-list as character no-undo .
  define buffer buf_clients for ub.clients.
  run ref/cli-all.w (   input parparentproc
                  ,input "b-sel"
                  ,input 'маг':U
                  ,input 'все':U
                  ,input 'текущие':U
                  ,input ?
                  ,input ",,,,,,NO,,"
                  ,input "lock-cli-type":U
                  ,output rid-list) no-error.
  if rid-list = '':U then return no-apply.
  find first buf_clients where recid (buf_clients) = integer (rid-list) no-lock no-error.
  if available buf_clients
  then do:
    if input frame Dialog-Frame tt-clients.db-num <> buf_clients.db-num
    then do:
      message
        "Нельзя в качестве склада объекта КУХНЯ указать объект другой БД!" skip
        view-as alert-box ERROR.
      return no-apply.
    end.
    display
      buf_clients.obj-code @ tt-shop.kitchen-store-code
      with frame Dialog-Frame .
  end.
  else do:
    return no-apply.
  end.
END.
ON CHOOSE OF b-outpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        tt-shop.out-pay = buf_pay-type.obj-code .
        display
        tt-shop.out-pay
        with frame Dialog-Frame.
    end.
END.
ON CHOOSE OF b-realpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = ? then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        tt-shop.chk-pay = buf_pay-type.obj-code .
        display
        tt-shop.chk-pay
        with frame Dialog-Frame.
    end.
END.
ON CHOOSE OF b-reset IN FRAME Dialog-Frame
DO:
  if p-mode = 'ДОБАВЛЕНИЕ':U and tt-shop.host-code = 0 then do:
    message
    "Фирма для магазина еще не определена" skip
    "Скопировать настройки с настроек по умолчанию невозможно"
    view-as alert-box error .
    return no-apply.
  end.
  message
  "Скопировать настройки для данного магазина" skip
  "из аналогичных настроек для всей системы?" view-as alert-box question
  buttons yes-no set OK as log .
  if OK then do:
    run reset-from-sysconf in this-procedure ( input yes
                                             , input tt-shop.host-code
                                                      ).
  end.
END.
ON CHOOSE OF b-retpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        tt-shop.ret-pay = buf_pay-type.obj-code .
        display
        tt-shop.ret-pay
        with frame Dialog-Frame.
   end.
END.
ON CHOOSE OF b-spipay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        tt-shop.down-pay = buf_pay-type.obj-code .
        display
        tt-shop.down-pay
        with frame Dialog-Frame.
   end.
END.
ON CHOOSE OF b-sub-store IN FRAME Dialog-Frame
DO:
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .
  define variable rid-list as character no-undo .
  define buffer buf_clients for ub.clients.
  run ref/cli-all.w (   input parparentproc
                  ,input "b-sel"
                  ,input 'объект':U
                  ,input 'все':U
                  ,input 'текущие':U
                  ,input ?
                  ,input ",,,,,,NO,,"
                  ,input "lock-cli-type":U
                  ,output rid-list) no-error.
  if rid-list = '':U then return no-apply.
  find first buf_clients where recid (buf_clients) = integer (rid-list) no-lock no-error.
  if available buf_clients
  then do:
    if input frame Dialog-Frame tt-clients.db-num <> buf_clients.db-num
    then do:
        message "Нельзя в качестве склада подсобки указать объект другой БД!"
        view-as alert-box error.
        return no-apply.
    end.
    display
    buf_clients.obj-type @ tt-shop.sub-store-type
    buf_Clients.obj-code @ tt-shop.sub-store-code
    with frame Dialog-Frame .
  end.
  else do:
    return no-apply.
  end.
END.
ON CHOOSE OF b-suppay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        tt-shop.ret-sup-pay = buf_pay-type.obj-code .
        display
               tt-shop.ret-sup-pay with frame Dialog-Frame.
    end.
END.
ON CHOOSE OF b-tocd IN FRAME Dialog-Frame
DO:
  if  tt-shop.host-code = 0
  or tt-shop.host-code = ?
  then do:
    message "Фирма не выбрана ! "
            view-as alert-box error.
    return no-apply.
  end.
    assign
    all-prt_ = tt-shop.all-prt
    cd-bc-alt_ = tt-shop.cd-bc-alt
    cd-bc-base_ = tt-shop.cd-bc-base
    cd-loc-alt_ = tt-shop.cd-loc-alt
    cd-loc-base_ = tt-shop.cd-loc-base
    cd-parts-all_ = tt-shop.cd-parts-all
    cd-parts-not-blank_ = tt-shop.cd-parts-not-blank
    cd-parts-ser_ = tt-shop.cd-parts-ser
    cd-pb-alt_ = tt-shop.cd-pb-alt
    cd-pb-base_ = tt-shop.cd-pb-base
    cd-sc-base_ = tt-shop.cd-sc-base.
    run adm/to-cd.w (
                   INPUT p-mode
                  ,INPUT tt-shop.host-code
                  ,INPUT 'маг':U
                  ,INPUT tt-shop.obj-code
                  ,INPUT ("Параметры отсылки товаров на кассу для магазина " +
                  string(tt-shop.obj-code) + " фирмы " + string(tt-shop.host-code))
                  ,INPUT-OUTPUT all-prt_
                  ,INPUT-OUTPUT cd-bc-alt_
                  ,INPUT-OUTPUT cd-bc-base_
                  ,INPUT-OUTPUT cd-loc-alt_
                  ,INPUT-OUTPUT cd-loc-base_
                  ,INPUT-OUTPUT cd-parts-all_
                  ,INPUT-OUTPUT cd-parts-not-blank_
                  ,INPUT-OUTPUT cd-parts-ser_
                  ,INPUT-OUTPUT cd-pb-alt_
                  ,INPUT-OUTPUT cd-pb-base_
                  ,INPUT-OUTPUT cd-sc-base_) no-error.
    if error-status:error then return no-apply.
    assign
    tt-shop.all-prt             = all-prt_
    tt-shop.cd-bc-alt           = cd-bc-alt_
    tt-shop.cd-bc-base          = cd-bc-base_
    tt-shop.cd-loc-alt          = cd-loc-alt_
    tt-shop.cd-loc-base         = cd-loc-base_
    tt-shop.cd-parts-all        = cd-parts-all_
    tt-shop.cd-parts-not-blank  = cd-parts-not-blank_
    tt-shop.cd-parts-ser        = cd-parts-ser_
    tt-shop.cd-pb-alt           = cd-pb-alt_
    tt-shop.cd-pb-base          = cd-pb-base_
    tt-shop.cd-sc-base          = cd-sc-base_
    .
END.
ON CHOOSE OF Btn_trn-reason IN FRAME Dialog-Frame
DO:
  run str/obj-rsn.w ( input parparentproc
                , input 'маг':U
                , input p-obj-code
                , input ( if p-mode = 'ПРОСМОТР':U then 'ПРОСМОТР':U else 'работа':U )
                ) .
END.
ON CHOOSE OF CliPS IN FRAME Dialog-Frame
DO:
    run proc-save in this-procedure (no).
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      find first tt-shop.
      find first tt-clients.
    end.
    run adm/shop-ps.w (
                  input parparentproc
                , input p-mode
                , input tt-shop.obj-code
                 ) no-error .
    if error-status:error then do:
      return no-apply.
    end.
 END.
ON CTRL-enter OF tt-clients.db-num IN FRAME Dialog-Frame
DO:
  define variable  ri as recid no-undo.
  define buffer buf_db for ub.db .
  run adm/dbs.w (
                input parparentproc
               ,input 'ПРОСМОТР':U
               ,output ri).
  if ri <> ? then  do:
    FIND first buf_db where recid( ub.db ) = ri .
    display
    buf_db.db-num @ tt-clients.db-num
    with frame Dialog-Frame.
  end.
END.
ON RETURN OF tt-clients.db-num IN FRAME Dialog-Frame
DO:
  RUN chk-db no-error.
  if error-status:error  THEN do:
    apply "ctrl-enter":U to self.
    return no-apply.
  end.
END.
ON VALUE-CHANGED OF tt-shop.doc-prt IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
  if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
    if (tt-shop.doc-prt:checked ) <> tt-shop.doc-prt
    then do:
      run trg/objatchk.p
        (input 'маг':U
        ,input tt-shop.obj-code
        ,input "doc-prt":u
        ,input tt-shop.doc-prt :checked in frame Dialog-Frame
        ) no-error .
      if error-status :error then do:
        assign
        tt-shop.doc-prt :checked in frame Dialog-Frame = tt-shop.doc-prt
        .
        return no-apply .
      end.
    end.
  end.
END.
ON VALUE-CHANGED OF tt-shop.is-kitchen IN FRAME Dialog-Frame
DO:
assign tt-shop.is-kitchen.
  run on-off-kitchen in this-procedure(tt-shop.is-kitchen) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m-choose
DO:
   DEFINE VARIABLE v-obj-code LIKE ub.clients.obj-code NO-UNDO.
  run ref/chs-code.w ('маг':U, v-cntxt-db-num, OUTPUT v-obj-code) no-error .
  if not error-status:error
  and v-obj-code <> ? then do:
    display
    v-obj-code @ tt-shop.obj-code
    with frame Dialog-Frame .
  end.
END.
ON LEAVE OF tt-shop.obj-code IN FRAME Dialog-Frame
DO:
 define variable choice as integer no-undo .
 define variable glog as logical no-undo .
 if input frame Dialog-Frame tt-shop.obj-code > 999
 and  p-mode = 'ДОБАВЛЕНИЕ':U then do:
  glog = no.
  run gbl/d-askw.w (input "Рекомендация",
                        input  ("Код нового магазина рекомендуется сделать меньшим 1000," + chr(10)
                                + "иначе у Вас могут возникнуть проблемы при работе с кассой IBM"),
                        input "|",
                        input "Продолжить с выбранным номером магазина|Отменить",
                        input "|",
                        input 1,
                        input 2,
                        output choice).
    if choice = 2
    then do:
        apply "ENTRY":U to tt-shop.obj-code IN frame Dialog-Frame.
        return no-apply.
    end.
  end.
END.
ON VALUE-CHANGED OF tt-shop.shift-on IN FRAME Dialog-Frame
DO:
  if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
    if tt-shop.shift-on :checked in frame Dialog-Frame <> tt-shop.shift-on
    then do:
      run trg/objatchk.p
        (input 'маг':U
        ,input tt-shop.obj-code
        ,input "shift-on":u
        ,input tt-shop.shift-on :checked in frame Dialog-Frame
        ) no-error .
      if error-status :error
      then do:
        assign
        tt-shop.shift-on :checked in frame Dialog-Frame = tt-shop.shift-on
        .
        return no-apply .
      end.
    end.
  end.
END.
ON VALUE-CHANGED OF tt-shop.sub-store-on IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-shop.sub-store-on = yes
  then do:
    ENABLE
    b-sub-store
    with frame Dialog-Frame.
  end.
  else do:
    DISABLE
    b-sub-store
    with frame Dialog-Frame.
  end.
END.
ON VALUE-CHANGED OF varenvd IN FRAME Dialog-Frame
DO:
  ASSIGN FRAME Dialog-Frame
    varenvd.
END.
ON VALUE-CHANGED OF varpharm IN FRAME Dialog-Frame
DO:
  ASSIGN FRAME Dialog-Frame
    VARpharm.
END.
ON VALUE-CHANGED OF varpurch-code-name IN FRAME Dialog-Frame
DO:
  ASSIGN FRAME Dialog-Frame varpurch-code-name.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 if p-mode  <> 'ДОБАВЛЕНИЕ':U
 and p-mode <> 'ИЗМЕНЕНИЕ':U
 and p-mode <> 'ПРОСМОТР':U
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
if p-mode <> 'ПРОСМОТР':U then do:
  if v-db-num <> 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode - нельзя изменять/добавлять записи МАГАЗИН в УБД"
    view-as alert-box ERROR.
    undo, return error.
  end.
end.
for each tt-shop:
  delete tt-shop.
end.
for each tt-clients:
  delete tt-clients.
end.
if p-mode = 'ДОБАВЛЕНИЕ':U  then do:
    message
    "Вам следует выбрать группу," skip
    "к которой будет относиться магазин."
    view-as alert-box.
    ref-list = "".
    run ref/cli-grps.w ( input parparentproc, "b-sel", input-output ref-list ) .
    if ref-list <> "" then  do:
      FIND buf_cli-grp where
          recid( buf_cli-grp ) = integer( ref-list ) .
      if can-find( FIRST ub.cli-grp where ub.cli-grp.upper-code = buf_cli-grp.node-code )
      then do:
        message
        "Добавлять можно только в группы," skip
        "у которых нет подгрупп." skip
        "Выбирайте другую группу !".
        return .
      end.
    end.
    else return .
    create tt-clients.
    create tt-shop.
    assign
    tt-clients.grp-code = buf_cli-grp.node-code
    tt-clients.obj-type = 'маг':U
    tt-shop.discaloc = yes
    tt-shop.doc-prt = false
    tt-shop.work-hours = if tt-shop.work-hours <> "" then tt-shop.work-hours else "08.00,20.00"
    .
  end.
  else do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      do transaction
      ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
      ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
        FIND first locked_clients exclusive-lock where
                recid( locked_clients ) = p-rid no-error .
        if not available locked_clients then do:
          FIND first locked_clients exclusive-lock where
                  locked_clients.obj-type = 'маг':U
                AND locked_clients.obj-code = p-obj-code no-wait no-error .
        if locked locked_clients then do:
          message
          vss-workfile vss-revision vss-description skip
          "Запись КЛИЕНТ для МАГАЗИНА" p-obj-code "занята"
          view-as alert-box error .
          undo, return error.
        end.
        end.
        FIND first locked_shop exclusive-lock where
                  locked_shop.obj-code = locked_clients.obj-code .
      end.
    end.
    if p-mode = 'ПРОСМОТР':U then do:
      FIND first locked_clients no-lock where
              recid( locked_clients ) = p-rid.
      FIND first locked_shop no-lock where
                locked_shop.obj-code = locked_clients.obj-code .
    end.
    create tt-clients.
    create tt-shop.
    buffer-copy locked_clients to tt-clients.
    buffer-copy locked_shop to tt-shop.
    FIND FIRST buf_cli-host NO-LOCK WHERE
               buf_cli-host.obj-code = locked_shop.host-code AND
               buf_cli-host.obj-type = 'орг':U NO-ERROR.
      if avail buf_cli-host then do:
        assign
        frame Dialog-Frame:title =
        "Настройки магазина фирмы ~"" + buf_cli-host.obj-name +
        "~" ("   + string( tt-shop.host-code )   + ").".
      end.
    end.
    assign
    tt-shop.work-hours = if tt-shop.work-hours <> "" then tt-shop.work-hours else "08.00,20.00"
    .
    assign
    all-prt_ = tt-shop.all-prt
    cd-bc-alt_ = tt-shop.cd-bc-alt
    cd-bc-base_ = tt-shop.cd-bc-base
    cd-loc-alt_ = tt-shop.cd-loc-alt
    cd-loc-base_ = tt-shop.cd-loc-base
    cd-parts-all_ = tt-shop.cd-parts-all
    cd-parts-not-blank_ = tt-shop.cd-parts-not-blank
    cd-parts-ser_ = tt-shop.cd-parts-ser
    cd-pb-alt_ = tt-shop.cd-pb-alt
    cd-pb-base_ = tt-shop.cd-pb-base
    cd-sc-base_ = tt-shop.cd-sc-base
    .
 ASSIGN
    varpurch-code-name:LIST-ITEMS = "по настройкам фирмы" + "," + 'выкуп,консигнация,ответственное хранение,старая консигнация':U.
  IF tt-shop.purch-code = ? THEN DO:
    ASSIGN
      varpurch-code-name = "по настройкам фирмы".
  END.
  ELSE DO:
        assign
      varpurch-code-name = entry (lookup (string(tt-shop.purch-code), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
  END.
  RUN clntattr-value IN THIS-PROCEDURE
    (INPUT 'маг':U,
     INPUT tt-shop.obj-code,
     input 'pharm':U,
     OUTPUT v-pharm,
     OUTPUT var-type).
  IF v-pharm = "yes":u THEN DO:
    ASSIGN
      varpharm = YES.
  END.
  ELSE DO:
    ASSIGN
      varpharm = NO.
  END.
  RUN clntattr-value IN THIS-PROCEDURE
    (INPUT 'маг':U,
     INPUT tt-shop.obj-code,
     input 'envd':U,
     OUTPUT v-envd,
     OUTPUT var-type).
  IF v-envd = "yes":u THEN DO:
    ASSIGN
      varenvd = YES.
  END.
  ELSE DO:
    ASSIGN
      varenvd = NO.
  END.
  RUN clntattr-value IN THIS-PROCEDURE
    (INPUT 'маг':U,
     INPUT tt-shop.obj-code,
     input 'kpp':U,
     OUTPUT v-kpp,
     OUTPUT var-type).
   kpp:screen-value = v-kpp.
   run init-firmhold in this-procedure.
  RUN Myenable.
  if p-mode = 'ДОБАВЛЕНИЕ':U then
      WAIT-FOR GO OF FRAME Dialog-Frame FOCUS tt-shop.obj-code.
  else
      WAIT-FOR GO OF FRAME Dialog-Frame FOCUS tt-clients.obj-name .
END.
RUN disable_UI.
PROCEDURE chk-db :
   if ( not can-find( ub.db where ub.db.db-num = input FRAME Dialog-Frame tt-clients.db-num ))
  then do:
      message "Неверный номер. Номер может быть:" skip
                      "    0, 1, ... -- номер существующей БД" skip
                      " CTRL-ENTER  -- вызов справочника."  view-as alert-box.
      apply "ENTRY":U  to tt-clients.db-num IN FRAME Dialog-Frame.
      return error.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY KPP varpurch-code-name varenvd varpharm fi-holdfirm-code
          fi-holdfirm-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-clients THEN
    DISPLAY tt-clients.db-num tt-clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-shop THEN
    DISPLAY tt-shop.obj-code tt-shop.director tt-shop.addres1 tt-shop.phone
          tt-shop.addres2 tt-shop.fax tt-shop.rsrv-time tt-shop.doc-prt
          tt-shop.price-calc tt-shop.in-pay tt-shop.no-eq tt-shop.out-pay
          tt-shop.unit-cli-perm tt-shop.ret-pay tt-shop.out-rate tt-shop.in-perm
          tt-shop.ret-sup-pay tt-shop.out-line-discnt tt-shop.down-pay
          tt-shop.in-ov tt-shop.inv-pay tt-shop.inout-price tt-shop.chk-pay
          tt-shop.day-only tt-shop.fbr-pay tt-shop.buy-goods tt-shop.with-serv
          tt-shop.pr-cash tt-shop.sub-store-type tt-shop.sub-store-code
          tt-shop.discaloc tt-shop.shift-on tt-shop.kitchen-store-code
          tt-shop.sub-store-on tt-shop.is-catering tt-shop.is-kitchen
          tt-shop.is-kitchen-store
      WITH FRAME Dialog-Frame.
  ENABLE B-exit RECT-10 RECT-kitchen-store RECT-sub-store b-quit b-reset CliPS
         b-tocd b-host tt-clients.db-num b-db B-hist B-Help tt-shop.obj-code
         tt-clients.obj-name B-attr Btn_trn-reason tt-shop.director
         tt-shop.addres1 tt-shop.phone tt-shop.addres2 tt-shop.fax
         tt-shop.rsrv-time tt-shop.doc-prt tt-shop.price-calc tt-shop.in-pay
         b-inpay tt-shop.no-eq tt-shop.out-pay b-outpay tt-shop.unit-cli-perm
         tt-shop.ret-pay b-retpay tt-shop.out-rate tt-shop.in-perm
         tt-shop.ret-sup-pay b-suppay tt-shop.out-line-discnt tt-shop.down-pay
         b-spipay tt-shop.in-ov tt-shop.inv-pay b-invpay tt-shop.inout-price
         tt-shop.chk-pay b-realpay tt-shop.day-only tt-shop.fbr-pay b-fbrpay
         tt-shop.buy-goods tt-shop.with-serv tt-shop.pr-cash
         tt-shop.sub-store-type tt-shop.sub-store-code b-sub-store
         tt-shop.discaloc tt-shop.shift-on tt-shop.kitchen-store-code
         b-kitchen-store tt-shop.sub-store-on tt-shop.is-catering
         tt-shop.is-kitchen b-holdfirm tt-shop.is-kitchen-store
         varenvd varpharm
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-firmhold :
    define variable v-outhold       as character    no-undo.
    define variable v-par-type      as character    no-undo.
    define variable v-firm-code-str as character    no-undo.
    define variable v-firm-code     as integer      no-undo.
    define buffer buf_clients   for ub.clients.
    define buffer buf_shop      for ub.shop.
do
for buf_clients
  , buf_shop
on error undo, return error
:
    if available tt-shop
    and tt-shop.host-code <> 0
    then do:
        find first buf_shop no-lock
             where buf_shop.obj-code = tt-shop.obj-code
        no-error.
        if available buf_shop
        then do:
            run gbl/conf-rd.p (
                input "outhold":U
                , input tt-shop.host-code
                , input 'маг':U
                , input tt-shop.obj-code
                , input "":U
                , input "":U
                , input "":U
                , input no
                , output v-outhold
                , output v-par-type
            ) no-error.
            if error-status :error
            then do:
                assign
                    v-outhold            = ""
                .
            end.
            if v-outhold <> "":U
            then do:
                assign
                    v-shopi-have-holdfirm                              = yes
                .
                run clntattr-value in this-procedure (
                    input 'маг':U
                    , input tt-shop.obj-code
                    , input 'holdfirm-code':U
                    , output v-firm-code-str
                    , output v-par-type
                ).
                assign
                    v-firm-code = integer( v-firm-code-str )
                no-error.
                if error-status :error
                then do:
                    assign
                        v-firm-code = 0
                    .
                end.
                else do:
                    if v-firm-code = 0
                    then do:
                        assign
                            fi-holdfirm-code = 0
                            fi-holdfirm-name = "":U
                        .
                    end.
                    else do:
                        find first buf_clients no-lock
                            where buf_clients.obj-type = 'орг':U
                            and buf_clients.obj-code = v-firm-code
                        no-error.
                        if available buf_clients
                        then do:
                            assign
                                fi-holdfirm-code = v-firm-code
                                fi-holdfirm-name = buf_clients.obj-name
                            .
                        end.
                        else do:
                            assign
                                fi-holdfirm-code = 0
                                fi-holdfirm-name = "":U
                            .
                        end.
                    end.
                end.
            end.
            else do:
                assign
                    v-shopi-have-holdfirm                              = no
                .
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE MyENable :
IF AVAILABLE tt-clients THEN
    DISPLAY tt-clients.obj-name tt-clients.db-num
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-shop THEN
    DISPLAY
    tt-shop.obj-code
    tt-shop.director
    tt-shop.phone
    tt-shop.addres1
    tt-shop.addres2
    tt-shop.fax
    tt-shop.rsrv-time
    tt-shop.doc-prt
    tt-shop.price-calc
    tt-shop.in-pay
    tt-shop.no-eq
    tt-shop.out-pay
    tt-shop.unit-cli-perm
    tt-shop.in-perm
    tt-shop.ret-pay
    tt-shop.out-rate
    tt-shop.ret-sup-pay
    tt-shop.fbr-pay
    tt-shop.out-line-discnt
    tt-shop.down-pay
    tt-shop.in-ov
    tt-shop.inv-pay
    tt-shop.inout-price
    tt-shop.chk-pay
    tt-shop.day-only
    tt-shop.buy-goods
    tt-shop.with-serv
    tt-shop.pr-cash
    tt-shop.discaloc
    tt-shop.shift-on
    tt-shop.sub-store-on
    tt-shop.sub-store-type
    tt-shop.sub-store-code
    tt-shop.is-catering
    tt-shop.is-kitchen
    tt-shop.is-kitchen-store
    tt-shop.kitchen-store-code when tt-shop.is-kitchen = yes
    varpurch-code-name
    VARenvd
    varpharm
    WITH FRAME Dialog-Frame.
  ENABLE
  RECT-sub-store
  RECT-10
  RECT-kitchen-store
  b-quit
  b-tocd
  CliPS
  B-Help
  b-hist WHEN p-mode <> 'ДОБАВЛЕНИЕ':U
  b-attr WHEN p-mode <> 'ДОБАВЛЕНИЕ':U
  b-host
  Btn_trn-reason WHEN p-mode <> 'ДОБАВЛЕНИЕ':U
  WITH FRAME Dialog-Frame.
  if p-mode = 'ПРОСМОТР':U then do:
    hide
    b-exit in frame Dialog-Frame.
    assign
    b-quit:label = "&Выход".
  end.
  else do:
    ENABLE
    B-exit
    b-reset
    CliPS
    tt-shop.obj-code    when p-mode = 'ДОБАВЛЕНИЕ':U
    tt-clients.obj-name
    tt-shop.director
    tt-shop.phone
    tt-shop.addres1
    tt-shop.addres2
    tt-shop.fax
    tt-shop.rsrv-time
    tt-shop.doc-prt
    tt-shop.price-calc
    tt-shop.in-pay
    b-inpay
    tt-shop.no-eq
    tt-shop.out-pay
    b-outpay
    tt-shop.unit-cli-perm
    tt-shop.in-perm
    tt-shop.ret-pay
    b-retpay
    tt-shop.out-rate
    tt-shop.ret-sup-pay
    b-suppay
    tt-shop.fbr-pay
    b-fbrpay
    tt-shop.out-line-discnt
    tt-shop.down-pay
    b-spipay
    tt-shop.in-ov
    tt-shop.inv-pay
    b-invpay
    tt-shop.inout-price
    tt-shop.chk-pay
    b-realpay
    tt-shop.day-only
    tt-clients.db-num when p-mode = 'ДОБАВЛЕНИЕ':U
    b-db when p-mode = 'ДОБАВЛЕНИЕ':U
    tt-shop.with-serv
    tt-shop.pr-cash
    tt-shop.shift-on
    tt-shop.sub-store-on
    tt-shop.sub-store-type
    tt-shop.sub-store-code
    b-sub-store when tt-shop.sub-store-on
    tt-shop.is-catering
    tt-shop.is-kitchen
    tt-shop.is-kitchen-store
    b-kitchen-store  when tt-shop.is-kitchen
    varpurch-code-name
    varenvd
    varpharm
    KPP
    WITH FRAME Dialog-Frame .
  end.
  if p-mode <> 'ДОБАВЛЕНИЕ':U then  do:
     run reset-from-sysconf in this-procedure ( input  no
                                               ,input p-host-code).
     MENU-ITEM m-choose:SENSITIVE IN MENU MENU-obj-code = NO .
  end.
  VIEW FRAME Dialog-Frame.
    if v-shopi-have-holdfirm = yes
    then do:
        assign
            fi-holdfirm-code :visible   in frame Dialog-Frame    = yes
            fi-holdfirm-name :visible   in frame Dialog-Frame    = yes
            b-holdfirm       :visible   in frame Dialog-Frame    = yes
            fi-holdfirm-code :sensitive in frame Dialog-Frame    = no
            fi-holdfirm-name :sensitive in frame Dialog-Frame    = no
        .
        if p-mode = 'ПРОСМОТР':U
        then do:
            assign
                b-holdfirm       :sensitive in frame Dialog-Frame    = no
            .
        end.
        else do:
            assign
                b-holdfirm       :sensitive in frame Dialog-Frame    = yes
            .
        end.
        display
            fi-holdfirm-code
            fi-holdfirm-name
        with frame Dialog-Frame.
    end.
    else do:
        assign
            fi-holdfirm-code :visible in frame Dialog-Frame    = no
            fi-holdfirm-name :visible in frame Dialog-Frame    = no
            b-holdfirm       :visible in frame Dialog-Frame    = no
        .
    end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    message
    "Вам следует выбрать фирму," skip
    "к которой будет относиться магазин"
    view-as alert-box .
    apply "CHOOSE" to b-host in frame Dialog-Frame .
  end.
END PROCEDURE.
PROCEDURE on-off-kitchen :
define input parameter p-is-kitchen like ub.shop.is-kitchen no-undo.
case p-is-kitchen :
    when no then do:
        disable
        b-kitchen-store
        tt-shop.kitchen-store-code
        with frame Dialog-Frame
        .
        hide
        b-kitchen-store
        tt-shop.kitchen-store-code
        rect-kitchen-store
        in frame Dialog-Frame.
        .
    end.
    when yes then do:
            enable
        b-kitchen-store
        tt-shop.kitchen-store-code
        with frame Dialog-Frame
        .
        display
        b-kitchen-store
        tt-shop.kitchen-store-code
        rect-kitchen-store
        with frame Dialog-Frame.
    end.
END CASE.
END PROCEDURE.
PROCEDURE proc-save :
define input parameter p-save as logical no-undo .
    define buffer buf_clients       for ub.clients.
do
for buf_clients
on error undo, return error
:
if p-mode =  'ДОБАВЛЕНИЕ':U
and (new-host-code = ?
     or
     new-host-code = 0)
then do:
  message "Фирма не выбрана."
  view-as alert-box error.
  return error.
end.
assign
frame Dialog-Frame
tt-shop.obj-code
tt-clients.obj-code         = tt-shop.obj-code
tt-clients.obj-type         = 'маг':U
tt-clients.db-num
tt-clients.obj-name
tt-shop.addres1
tt-shop.addres2
tt-shop.all-prt             = all-prt_
tt-shop.buy-goods
tt-shop.is-catering
tt-shop.is-kitchen
tt-shop.is-kitchen-store
tt-shop.cd-bc-alt           = cd-bc-alt_
tt-shop.cd-bc-base          = cd-bc-base_
tt-shop.cd-loc-alt          = cd-loc-alt_
tt-shop.cd-loc-base         = cd-loc-base_
tt-shop.cd-parts-all        = cd-parts-all_
tt-shop.cd-parts-not-blank  = cd-parts-not-blank_
tt-shop.cd-parts-ser        = cd-parts-ser_
tt-shop.cd-pb-alt           = cd-pb-alt_
tt-shop.cd-pb-base          = cd-pb-base_
tt-shop.cd-sc-base          = cd-sc-base_
tt-shop.chk-pay
tt-shop.day-only
tt-shop.director
tt-shop.discaloc            = yes
tt-shop.doc-prt
tt-shop.down-pay
tt-shop.fax
tt-shop.host-code           =  if  tt-shop.host-code = 0
                               or tt-shop.host-code = ?
                               then p-host-code
                               else tt-shop.host-code
tt-shop.in-ov
tt-shop.in-pay
tt-shop.in-perm
tt-shop.inout-price
tt-shop.inv-pay
tt-shop.kitchen-store-code
tt-shop.kitchen-store-code                    =  (if tt-shop.is-kitchen then tt-shop.kitchen-store-code else 0)
tt-shop.kitchen-store-type                    = (if tt-shop.is-kitchen then 'маг':U else "":U)
tt-shop.no-eq
tt-shop.out-line-discnt
tt-shop.out-pay
tt-shop.out-rate
tt-shop.phone
tt-shop.pr-cash
tt-shop.price-calc
tt-shop.ret-pay
tt-shop.ret-sup-pay
tt-shop.fbr-pay
tt-shop.rsrv-time
tt-shop.shift-on
tt-shop.sub-store-on
tt-shop.sub-store-code
tt-shop.sub-store-type
tt-shop.unit-cli-perm
tt-shop.with-serv
.
assign
frame Dialog-Frame
    KPP
.
if not p-save then return.
if tt-shop.all-prt then do:
  message
    "Передача на кассу ВСЕХ признаков товаров" skip
    "может привести к ПЕРЕПОЛНЕНИЮ базы данных КАССЫ." skip
    view-as alert-box information .
end.
if varpharm = true and  tt-shop.doc-prt = true  then do:
   message "Нельзя на объекте вести сразу учет по шкалам и по партиям. Если Вы уверены что нужно использовать режим АПТЕКА, не используйте шкальный товар !"
   view-as alert-box information .
end.
run adm/shop01.p (
              input-output p-rid
             ,input        p-mode
             ,input    tt-shop.obj-code
             ,input    tt-clients.db-num
             ,input    tt-shop.host-code
             ,input    tt-clients.grp-code
             ,input    tt-clients.obj-name
             ,input    tt-clients.PS
             ,input    tt-shop.acct
             ,input    tt-shop.addres1
             ,input    tt-shop.addres2
             ,input    tt-shop.all-prt
             ,input    tt-shop.buy-goods
             ,input    tt-shop.cd-bc-alt
             ,input    tt-shop.cd-bc-base
             ,input    tt-shop.cd-loc-alt
             ,input    tt-shop.cd-loc-base
             ,input    tt-shop.cd-parts-all
             ,input    tt-shop.cd-parts-not-blank
             ,input    tt-shop.cd-parts-ser
             ,input    tt-shop.cd-pb-alt
             ,input    tt-shop.cd-pb-base
             ,input    tt-shop.cd-sc-base
             ,input    tt-shop.chk-pay
             ,input    tt-shop.day-only
             ,input    tt-shop.director
             ,input    tt-shop.discaloc
             ,input    tt-shop.doc-prt
             ,input    tt-shop.down-pay
             ,input    tt-shop.fax
             ,input    tt-shop.goods-man
             ,input    tt-shop.in-ov
             ,input    tt-shop.in-pay
             ,input    tt-shop.in-perm
             ,input    tt-shop.inout-price
             ,input    tt-shop.inv-pay
             ,input    tt-shop.is-catering
             ,input    tt-shop.is-kitchen
             ,input    tt-shop.is-kitchen-store
             ,input    tt-shop.kitchen-store-code
             ,input    tt-shop.kitchen-store-type
             ,input    tt-shop.no-eq
             ,input    tt-shop.out-line-discnt
             ,input    tt-shop.out-pay
             ,input    tt-shop.out-rate
             ,input    tt-shop.phone
             ,input    tt-shop.pr-cash
             ,input    tt-shop.price-calc
             ,input    tt-shop.ret-pay
             ,input    tt-shop.ret-sup-pay
             ,input    tt-shop.fbr-pay
             ,input    tt-shop.rsrv-time
             ,input    tt-shop.shift-on
             ,input    tt-shop.store-boss
             ,input    tt-shop.store-man
             ,input    tt-shop.sub-store-on
             ,input    tt-shop.sub-store-code
             ,input    tt-shop.sub-store-type
             ,input    tt-shop.unit-cli-perm
             ,input    tt-shop.with-serv
             ,input    tt-shop.work-hours
             ,input    (if varpurch-code-name = "по настройкам фирмы" then ? else lookup (varpurch-code-name, 'выкуп,консигнация,ответственное хранение,старая консигнация':U))
             ,INPUT    varenvd
             ,INPUT    varpharm
             ,input    KPP
            )
             no-error .
if error-status:error then do:
  define variable l-ret-widg as character no-undo .
  define variable l-ret-text as character no-undo .
  assign
    l-ret-widg = entry(1, return-value, chr(4))
    l-ret-text = entry(2, return-value, chr(4))
  .
  message l-ret-text view-as alert-box error .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return error.
end.
    assign
        fi-holdfirm-code
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = 'орг':U
           and buf_clients.obj-code = fi-holdfirm-code
    no-error.
    if available buf_clients
    then do:
        run clntattr-write in this-procedure (
              input 'маг':U
            , input tt-shop.obj-code
            , input 'holdfirm-code':U
            , input string( fi-holdfirm-code )
        ).
    end.
end.
END PROCEDURE.
PROCEDURE reset-from-sysconf :
define  input parameter p-reset as logical no-undo.
define input parameter p-host-code as integer no-undo .
define buffer buf_sysconf for ub.sysconf.
if p-reset then   do:
    FIND first buf_sysconf where
            buf_sysconf.host-code = p-host-code.
    assign
        tt-shop.unit-cli-perm = buf_sysconf.unit-cli-perm
        tt-shop.in-ov = buf_sysconf.in-ov
        tt-shop.in-perm = buf_sysconf.in-perm
        tt-shop.inout-price = buf_sysconf.inout-price
        tt-shop.no-eq = buf_sysconf.no-eq
        tt-shop.out-line-discnt = buf_sysconf.out-line-discnt
        tt-shop.out-rate = buf_sysconf.out-rate
        tt-shop.price-calc = buf_sysconf.price-calc
        tt-shop.chk-pay = buf_sysconf.chk-pay
        tt-shop.down-pay = buf_sysconf.down-pay
        tt-shop.in-pay  = buf_sysconf.in-pay
        tt-shop.inv-pay  = buf_sysconf.inv-pay
        tt-shop.out-pay  = buf_sysconf.out-pay
        tt-shop.ret-pay = buf_sysconf.ret-pay
        tt-shop.ret-sup-pay = buf_sysconf.ret-sup-pay
        tt-shop.fbr-pay = buf_sysconf.fbr-pay
        tt-shop.rsrv-time  = buf_sysconf.rsrv-time
        tt-shop.cd-bc-alt  = buf_sysconf.cd-bc-alt
        tt-shop.cd-bc-base = buf_sysconf.cd-bc-base
        tt-shop.cd-loc-alt = buf_sysconf.cd-loc-alt
        tt-shop.cd-loc-base = buf_sysconf.cd-loc-base
        tt-shop.cd-parts-all = buf_sysconf.cd-parts-all
        tt-shop.cd-parts-not-blank = buf_sysconf.cd-parts-not-blank
        tt-shop.cd-parts-ser = buf_sysconf.cd-parts-ser
        tt-shop.cd-pb-alt = buf_sysconf.cd-pb-alt
        tt-shop.cd-pb-base = buf_sysconf.cd-pb-base
        tt-shop.cd-sc-base = buf_sysconf.cd-sc-base
        tt-shop.all-prt = buf_sysconf.all-prt
        .
end.
display
tt-shop.unit-cli-perm
tt-shop.in-ov
tt-shop.in-perm
tt-shop.inout-price
tt-shop.no-eq
tt-shop.out-line-discnt
tt-shop.out-rate
tt-shop.price-calc
tt-shop.chk-pay
tt-shop.down-pay
tt-shop.in-pay
tt-shop.out-pay
tt-shop.inv-pay
tt-shop.ret-pay
tt-shop.ret-sup-pay
tt-shop.fbr-pay
tt-shop.rsrv-time
with frame Dialog-Frame.
END PROCEDURE.
