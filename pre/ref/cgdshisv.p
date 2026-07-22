block-level on error undo, throw.
define input parameter p-gds-code like ub.c-gds-hist.gds-code no-undo .
define input parameter p-chip-num like ub.c-gds-hist.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-gds-hist.corr-user-db-num no-undo .
define input parameter p-host-code like ub.c-gds-hist.host-code no-undo .
define input parameter p-obj-type like ub.c-gds-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-gds-hist.obj-code no-undo .
define input parameter p-subject like ub.c-gds-hist.subject no-undo .
define input parameter p-action   like ub.c-gds-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define input parameter p-log-file as character no-undo .
define output parameter p-description as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: fe7a405e2efa, 1410, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Jun 28 15:24:34 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cgdshisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cgdshisv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории товара".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdshattr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-name in g#attr-lib
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
procedure gdshattr-tooltip :
define input  parameter p-code    as character no-undo .
define output parameter p-tooltip as character no-undo .
define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-tooltip in g#attr-lib
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
procedure gdshattr-value :
define input  parameter p-code as character no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as int no-undo .
define input  parameter p-gds-code as int no-undo .
define output parameter p-value as character no-undo .
define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-value in g#attr-lib
    (input  p-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  p-gds-code
    ,output p-value
    ,output p-type
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure gdshattr-h-value :
define input  parameter p-code as character no-undo .
define input  parameter p-host-code as integer no-undo .
define input  parameter p-gds-code as int no-undo .
define output parameter p-value as character no-undo .
define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-h-value in g#attr-lib
    (input  p-code
    ,input  p-host-code
    ,input  p-gds-code
    ,output p-value
    ,output p-type
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure gdshattr-write :
define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type   no-undo .
define input parameter p-obj-code like ub.clients.obj-code   no-undo .
define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
define input parameter p-value    like ub.gds-host-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-write in g#attr-lib
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
end procedure.
procedure gdshattr-EXIST :
define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type   no-undo .
define input parameter p-obj-code like ub.clients.obj-code   no-undo .
define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
define OUTPUT parameter p-EXIST   AS LOGICAL no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-exist in g#attr-lib
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
end procedure.
procedure gdshattr-DELETE :
define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type   no-undo .
define input parameter p-obj-code like ub.clients.obj-code   no-undo .
define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
define output parameter p-DELETED  AS LOGICAL no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-delete in g#attr-lib
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
end procedure.
procedure gdshattr-news :
define input  parameter p-code           as character no-undo .
define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-news in g#attr-lib
      (
       input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdshattr-copy :
define input  parameter p-code           as character no-undo .
define output parameter p-copy           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdspoatr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-name in g#attr-lib
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
procedure gdspoatr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-tooltip in g#attr-lib
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
procedure gdspoatr-value :
  define input  parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-prop-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-value in g#attr-lib
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
end procedure.
procedure gdspoatr-write :
  define input parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-prop-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-write in g#attr-lib
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
end procedure.
procedure gdspoatr-exist :
  define input  parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-exist in g#attr-lib
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
end procedure.
procedure gdspoatr-delete :
  define input  parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-delete in g#attr-lib
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
end procedure.
procedure gdspoatr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type8 as character no-undo .
define variable v-value-date8 as date no-undo .
define variable v-value-decimal8 as decimal no-undo .
define variable v-value-integer8 as INTEGER no-undo .
define variable v-value-logical8 AS LOGICAL no-undo .
define variable v-tth8 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output p-pos-type
    ,output v-value-date8
    ,output v-value-decimal8
    ,output v-value-integer8
    ,output v-value-logical8
    ,output v-param-type8
    ,INPUT-OUTPUT table-handle v-tth8
    )  .
delete object v-tth8 no-error.
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure plgdattr-name :
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
      otherwise do:
        undo, return error substitute("Неизвестный атрибут товара на складском месте &1",  p-code ).
      end.
    end.
  end.
end procedure.
procedure plgdattr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
      otherwise do:
        undo, return error substitute("Неизвестный атрибут товара складском месте &1" , p-code ).
      end.
    end.
  end.
end procedure.
procedure plgdattr-value :
 do
  on error undo, return error
  :
    define input  parameter p-code     like ub.pl-gds-attr.attr-code  no-undo .
    define input  parameter p-obj-type like ub.pl-gds-attr.obj-type   no-undo .
    define input  parameter p-obj-code like ub.pl-gds-attr.obj-code   no-undo .
    define input  parameter p-pl-code  like ub.pl-gds-attr.pl-code    no-undo .
    define input  parameter p-gds-code like ub.pl-gds-attr.gds-code   no-undo .
    define output parameter p-value    like ub.pl-gds-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_pl-gds-attr for ub.pl-gds-attr .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run plgdattr-name in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_pl-gds-attr no-lock where
               buf_pl-gds-attr.obj-type  = p-obj-type
           AND buf_pl-gds-attr.obj-code  = p-obj-code
           AND buf_pl-gds-attr.pl-code  = p-pl-code
           AND buf_pl-gds-attr.gds-code  = p-gds-code
           AND buf_pl-gds-attr.attr-code = p-code
      no-error .
    if avail buf_pl-gds-attr then do:
      assign
        p-value =  buf_pl-gds-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure plgdattr-write :
  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.pl-gds-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.pl-gds-attr.obj-code   no-undo .
    define input parameter p-pl-code  like ub.pl-gds-attr.pl-code    no-undo .
    define input parameter p-gds-code like ub.pl-gds-attr.gds-code   no-undo .
    define input parameter p-code     like ub.pl-gds-attr.attr-code  no-undo .
    define input parameter p-value    like ub.pl-gds-attr.attr-value no-undo .
    define buffer buf_pl-gds-attr for ub.pl-gds-attr .
    define buffer lock_pl-gds-attr for ub.pl-gds-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run plgdattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_pl-gds-attr exclusive-lock where
               buf_pl-gds-attr.obj-type  = p-obj-type
           AND buf_pl-gds-attr.obj-code  = p-obj-code
           AND buf_pl-gds-attr.pl-code  = p-pl-code
           AND buf_pl-gds-attr.gds-code  = p-gds-code
           AND buf_pl-gds-attr.attr-code = p-code no-error .
    if not available buf_pl-gds-attr then do:
      create buf_pl-gds-attr .
      assign
      buf_pl-gds-attr.obj-type  = p-obj-type
      buf_pl-gds-attr.obj-code  = p-obj-code
      buf_pl-gds-attr.pl-code  = p-pl-code
      buf_pl-gds-attr.gds-code  = p-gds-code
      buf_pl-gds-attr.attr-code = p-code
      buf_pl-gds-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    ASSIGN
    buf_pl-gds-attr.attr-value = p-value no-error.
  end.
end procedure.
procedure plgdattr-exist :
  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.pl-gds-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.pl-gds-attr.obj-code   no-undo .
    define input parameter p-pl-code  like ub.pl-gds-attr.pl-code    no-undo .
    define input parameter p-gds-code like ub.pl-gds-attr.gds-code   no-undo .
    define input parameter p-code     like ub.pl-gds-attr.attr-code  no-undo .
    define output parameter p-exist    as logical no-undo .
    define buffer buf_pl-gds-attr for ub.pl-gds-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run plgdattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_pl-gds-attr no-lock where
               buf_pl-gds-attr.obj-type  = p-obj-type
           AND buf_pl-gds-attr.obj-code  = p-obj-code
           AND buf_pl-gds-attr.pl-code  = p-pl-code
           AND buf_pl-gds-attr.gds-code  = p-gds-code
           AND buf_pl-gds-attr.attr-code = p-code no-error .
    if available buf_pl-gds-attr then do:
      P-EXIST = YES.
    end.
  end.
end procedure.
procedure plgdattr-delete :
  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.pl-gds-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.pl-gds-attr.obj-code   no-undo .
    define input parameter p-pl-code  like ub.pl-gds-attr.pl-code    no-undo .
    define input parameter p-gds-code like ub.pl-gds-attr.gds-code   no-undo .
    define input parameter p-code     like ub.pl-gds-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo .
    define buffer buf_pl-gds-attr for ub.pl-gds-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run plgdattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_pl-gds-attr exclusive-lock where
               buf_pl-gds-attr.obj-type  = p-obj-type
           AND buf_pl-gds-attr.obj-code  = p-obj-code
           AND buf_pl-gds-attr.gds-code  = p-gds-code
           AND buf_pl-gds-attr.pl-code  = p-pl-code
           AND buf_pl-gds-attr.attr-code = p-code no-error .
    if not available buf_pl-gds-attr then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_pl-gds-attr.
       P-DELETED = YES.
    END.
  end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info14 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info14, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info14, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info14, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info14, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info14 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info14, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info14 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info14, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info14, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info14, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info14, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info14, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info14, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info14 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info14 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info14, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info14, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info14, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info14 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info14 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info14, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info14, v-inform, v-tbl-name ).
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure bc-oattr_name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-range          as integer   no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-range
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
procedure bc-oattr_tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_tooltip in g#attr-lib
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
procedure bc-oattr_value :
  define input  parameter p-b-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_value in g#attr-lib
      (input  p-b-code
      ,input  p-code
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
end procedure.
procedure bc-oattr_write :
  define input parameter p-b-code like ub.bar-code-obj-attr.b-code   no-undo .
  define input parameter p-code     like ub.bar-code-obj-attr.attr-code  no-undo .
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-value    like ub.bar-code-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_write in g#attr-lib
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-oattr_exist :
  define input  parameter p-b-code like ub.bar-code-obj-attr.b-code   no-undo .
  define input  parameter p-code     like ub.bar-code-obj-attr.attr-code  no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_exist in g#attr-lib
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-oattr_delete :
  define input  parameter p-b-code like ub.bar-code-obj-attr.b-code   no-undo .
  define input  parameter p-code     like ub.bar-code-obj-attr.attr-code  no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_delete in g#attr-lib
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-oattr_manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-oattr_batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure bc-attr_name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-range          as integer   no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-attr_name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-range
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
procedure bc-attr_tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-attr_tooltip in g#attr-lib
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
procedure bc-attr_value :
  define input  parameter p-b-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-attr_value in g#attr-lib
      (input  p-b-code
      ,input  p-code
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
end procedure.
procedure bc-attr_write :
  define input parameter p-b-code like ub.bar-code-attr.b-code   no-undo .
  define input parameter p-code     like ub.bar-code-attr.attr-code  no-undo .
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-value    like ub.bar-code-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-attr_write in g#attr-lib
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-attr_exist :
  define input  parameter p-b-code like ub.bar-code-attr.b-code   no-undo .
  define input  parameter p-code     like ub.bar-code-attr.attr-code  no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-attr_exist in g#attr-lib
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-attr_delete :
  define input  parameter p-b-code like ub.bar-code-attr.b-code   no-undo .
  define input  parameter p-code     like ub.bar-code-attr.attr-code  no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-attr_delete in g#attr-lib
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-attr_manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-attr_manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-attr_batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-attr_batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable v-chg-fields as character no-undo.
define variable v-chg-fields-name as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .
define buffer buf_c-gds-hist for ub.c-gds-hist.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
FUNCTION get-all-fields returns character (p-file-name as character ):
define variable v-dop as character no-undo .
  find first _file no-lock where _file._file-name = p-file-name no-error .
  if not available _file then return "":U.
  for each _field no-lock where
           _field._file-recid = recid(_file) :
    assign
    v-dop = v-dop + _field._field-name + chr(44)
    .
  end.
  return trim(v-dop).
END FUNCTION.
PROCEDURE proc-full-temp-changes :
  define input  parameter p-act-create as logical   no-undo .
  define input  parameter p-act-delete as logical   no-undo .
  define input  parameter p-hst-handle as handle    no-undo .
  define input  parameter p-main-table as character no-undo .
  define input  parameter p-field-list as character no-undo .
  define input  parameter p-label-form as character no-undo .
  define variable h-new-buf         as handle    no-undo .
  define variable h-main-buf        as handle    no-undo .
  define variable h-for-comp        as handle    no-undo .
  define variable v-inform          as character no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-idx-field-qnty  as integer   no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable fh                as handle    no-undo .
  define variable fh-main           as handle    no-undo .
  define variable fh-old            as handle    no-undo .
  define variable fh-new            as handle    no-undo .
  define variable v-field-name      as character no-undo .
  define variable v-field-lvl       as character no-undo .
  define variable v-field-form      as character no-undo .
  define variable v-search-exp      as character no-undo .
  define variable v-srch-main       as character no-undo .
  define variable v-word-link       as character no-undo .
  define variable v-av-chip-num     as logical   no-undo .
  define variable v-main-pi-fld-lst as character no-undo .
  define variable v-main-fld-lst    as character no-undo .
  define variable v-delim-list      as character no-undo .
  define variable v-label           as character no-undo .
  define variable v-old-value       as character no-undo case-sensitive.
  define variable v-new-value       as character no-undo case-sensitive.
  define variable v-chg-fields as character no-undo.
  for each temp-changes:
    delete temp-changes.
  end.
  if not p-hst-handle:available then do:
    return .
  end.
  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .
  assign
    v-inform = h-main-buf:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = h-main-buf:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, h-main-buf:name ).
  end.
  assign
    v-srch-main   = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    v-delim-list  = "":U
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name      = entry( 4 + v-ind, v-inform, ",":U )
      fh                = p-hst-handle:buffer-field( v-field-name )
      fh-main           = h-main-buf:buffer-field( v-field-name )
      v-srch-main       = substitute( "&1 &2 &3.&4 =", v-srch-main, v-word-link, fh-main:table, v-field-name )
      v-main-pi-fld-lst = v-main-pi-fld-lst + v-delim-list + v-field-name
    .
    if fh:data-type ="character":U then do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
      .
    end.
    if v-delim-list = "":U then do:
      assign
        v-delim-list = ",":U
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  assign
    v-delim-list  = "":U
  .
  do v-ind = 1 to h-main-buf:num-fields
  on error undo, return error
  :
    assign
      fh-main      = h-main-buf:buffer-field( v-ind )
      v-field-name = fh-main:name
    .
      assign
        v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
      if v-delim-list = "":U then do:
        assign
          v-delim-list = ",":U
        .
      end.
  end.
  assign
    v-inform = p-hst-handle:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = p-hst-handle:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, p-hst-handle:name ).
  end.
  assign
    v-search-exp  = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh           = p-hst-handle:buffer-field( v-field-name )
      v-search-exp = substitute( "&1 &2 &3.&4", v-search-exp, v-word-link, fh:table, v-field-name )
    .
    if v-field-name = "chip-num":U then do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
      .
    end.
    else do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
      .
    end.
    if fh:data-type ="character":U then do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  if v-av-chip-num = false then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.
  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then do:
      assign
        h-for-comp = ?
      .
    end.
    else do:
      assign
        h-for-comp = h-main-buf
      .
    end.
  end.
  else do:
    assign
      h-for-comp = h-new-buf
    .
  end.
  assign
    v-num-entries = num-entries( v-main-fld-lst, ",":U )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    assign
      v-field-name = entry( v-ind, v-main-fld-lst )
      fh-old       = p-hst-handle:buffer-field( v-field-name )
      v-old-value  = fh-old:buffer-value()
      v-label      = trim( fh-old:label )
    .
    if ( trim( p-field-list ) <> "":U
         and lookup( v-field-name, p-field-list ) > 0
       )
       or trim( p-field-list ) = "":U
    then do:
      if h-for-comp <> ? then do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
        .
      end.
      else do:
        assign
          v-new-value = "":U
        .
      end.
        if p-act-create = true then do:
          assign
            v-old-value = "":U
          .
        end.
        if p-act-delete = true then do:
          assign
            v-new-value = "":U
          .
        end.
      if v-old-value <> v-new-value
      then do:
        create temp-changes.
        assign
          temp-changes.t_name = p-main-table
          temp-changes.f_name = v-field-name
          temp-changes.l_name = replace( v-label, "&":U, "":U )
          temp-changes.v_old  = trim( v-old-value )
          temp-changes.v_new  = trim( v-new-value )
          temp-changes.num_   = 0
          temp-changes.fNotChange = v-old-value eq v-new-value
        .
      end.
    end.
  end.
  assign
    v-num-entries = num-entries( p-label-form, chr(8) )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    if num-entries( entry( v-ind, p-label-form, chr(8) ), chr(4) ) = 3 then do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-form = entry( 3, entry( v-ind, p-label-form, chr(8) ), chr(4) )
      .
      find first temp-changes
        where temp-changes.f_name = v-field-name
        no-error .
      if available temp-changes then do:
        if trim( v-field-lvl ) <> "":U then do:
          assign
            temp-changes.l_name = v-field-lvl
          .
        end.
        if trim( v-field-form ) <> "":U then do:
          assign
            temp-changes.v_old = dynamic-function( v-field-form, temp-changes.v_old )
          .
          if h-for-comp <> ? then do:
            assign
              temp-changes.v_new = dynamic-function( v-field-form, temp-changes.v_new )
            .
          end.
        end.
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка! Список должен содержать три поля с разделителем delim-par!" skip
        substitute( "список для поля '&1': '&2'"
                    ,entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
                    ,entry( v-ind, p-label-form, chr(8) )
                  ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.
  delete object h-new-buf .
  delete object h-main-buf .
END PROCEDURE.
find first buf_c-gds-hist no-lock where
          buf_c-gds-hist.gds-code = p-gds-code
      AND buf_c-gds-hist.chip-num = p-chip-num
      AND buf_c-gds-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-gds-hist.obj-type = p-obj-type
      AND buf_c-gds-hist.obj-code = p-obj-code
      AND buf_c-gds-hist.subject  = p-subject no-error .
if not available buf_c-gds-hist then do:
  return error .
end.
CASE p-subject:
  when 'goods':U then do:
    run goods-proc in this-procedure(output p-description) no-error .
  end.
  when 'gds-obj-attr':U then do:
    run gds-obj-attr-proc in this-procedure(output p-description) no-error .
  end.
  when 'gds-host-attr':U then do:
    run gds-host-attr-proc in this-procedure(output p-description) no-error .
  end.
  when 'goods-attr':U then do:
    run goods-attr-proc in this-procedure(output p-description) no-error  .
  end.
  when 'fbr-gds-obj':U then do:
    run fbr-gds-obj-proc in this-procedure(output p-description) no-error  .
  end.
  when 's-coeff':U then do:
    run s-coeff-proc in this-procedure(output p-description) no-error  .
  end.
  when 'prod-bc':U then do:
    run prod-bc-proc in this-procedure(output p-description) no-error  .
  end.
  when 'bar-code':U then do:
    run bar-code-proc in this-procedure(output p-description) no-error  .
  end.
  when 'bar-code-attr':U then do:
    run bar-code-attr-proc in this-procedure(output p-description) no-error  .
  end.
  when 'bar-code-obj-attr':U then do:
    run bar-code-obj-attr-proc in this-procedure(output p-description) no-error  .
  end.
  when 'varianty-delivery-gds-obj':U then do:
    run varianty-delivery-gds-obj-proc in this-procedure(output p-description) no-error  .
  end.
  when 'gds-season':U then do:
    run gds-season-proc in this-procedure(output p-description) no-error  .
  end.
  when 'tax-rate-gds':U then do:
    run tax-rate-gds-proc in this-procedure(output p-description) no-error  .
  end.
  when 'assortment-matrix-goods':U then do:
    run ass-matr-proc in this-procedure(output p-description) no-error  .
  end.
  when 'gds-obj-prop':U then do:
    run izt-proc in this-procedure(output p-description) no-error  .
  end.
  when 'pl-gds':U then do:
    run pl-gds-proc in this-procedure(output p-description) no-error  .
  end.
  when 'pl-gds-attr':U then do:
    run pl-gds-attr-proc in this-procedure(output p-description) no-error  .
  end.
  when 'pl-gds-pump':U then do:
    run pl-gds-pump-proc in this-procedure(output p-description) no-error  .
  end.
  when 'dis-gds-rule':U then do:
    run dis-gds-rule-proc in this-procedure(output p-description) no-error  .
  end.
  when 'ext-artic':U then do:
    run ext-artic-proc in this-procedure(output p-description) no-error  .
  end.
  when 'sert-join':U then do:
    run sert-join-proc in this-procedure(output p-description) no-error  .
  end.
  when 'recipe':U then do:
    run recipe-proc in this-procedure(output p-description) no-error  .
  end.
  when 'recipe-gds':U then do:
    run recipe-gds-proc in this-procedure(output p-description) no-error  .
  end.
  when 'ext-classif':U then do:
    run ext-classif-proc in this-procedure(output p-description) no-error  .
  end.
  when 'gds-obj-prop-attr':U then do:
    run gds-obj-prop-attr-proc in this-procedure(output p-description) no-error .
  end.
  when 'gds-obj':U then do:
    run gds-obj-ref-proc in this-procedure(output p-description) no-error  .
  end.
END CASE.
if error-status:error then do:
  return error .
end.
procedure goods-proc :
define output parameter p-description as character no-undo .
define buffer current_c-goods for ub.c-goods  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  find first current_c-goods no-lock where
              current_c-goods.gds-code = p-gds-code
          AND current_c-goods.chip-num = p-chip-num
          AND current_c-goods.corr-user-db-num = p-corr-user-db-num no-error .
  if not avail current_c-goods then do:
    v-mess = "Неверная ссылка на c-goods в таблице c-gds-hist".
    run err-mess in this-procedure ( input-output v-mess).
    return error v-mess.
  end.
define variable v-label-param as character no-undo .
v-label-param =
  "prod-type" + chr(4) + "Тип производителя" + chr(4) + "" + chr(8)
 + "prod-code" + chr(4) + "Производитель" + chr(4) + "" + chr(8)
 + "artic" + chr(4) + "Артикул" + chr(4) + "" + chr(8)
 + "gds-name" + chr(4) + "Название товара" + chr(4) + "" + chr(8)
 + "unit-base" + chr(4) + "Основная единица измер" + chr(4) + "" + chr(8)
 + "prt-root" + chr(4) + "Корень шкалы" + chr(4) + "" + chr(8)
 + "grp-code" + chr(4) + "Код группы" + chr(4) + "" + chr(8)
 + "unit-cli" + chr(4) + "Единица измерения пост" + chr(4) + "" + chr(8)
 + "cli-base-rate" + chr(4) + "Коэффициент" + chr(4) + "" + chr(8)
 + "calc-method" + chr(4) + "Способ расчета" + chr(4) + "" + chr(8)
 + "increase-pc" + chr(4) + "Процент наценки" + chr(4) + "" + chr(8)
 + "stts" + chr(4) + "Статус" + chr(4) + "" + chr(8)
 + "qnty-cart" + chr(4) + "Кол. в упак." + chr(4) + "" + chr(8)
 + "wt-cart" + chr(4) + "Вес упаковки" + chr(4) + "" + chr(8)
 + "ms-cart" + chr(4) + "Об'ем упаковки" + chr(4) + "" + chr(8)
 + "engl-name" + chr(4) + "Название англ." + chr(4) + "" + chr(8)
 + "grp-name" + chr(4) + "Название группы" + chr(4) + "" + chr(8)
 + "gds-type" + chr(4) + "Тип" + chr(4) + "" + chr(8)
 + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
 + "okdp" + chr(4) + "ОКДП" + chr(4) + "" + chr(8)
 + "destin" + chr(4) + "Назначение" + chr(4) + "" + chr(8)
 + "attrib" + chr(4) + "Характеристики" + chr(4) + "" + chr(8)
 + "user-rule" + chr(4) + "Правила эксплутации" + chr(4) + "" + chr(8)
 + "sert" + chr(4) + "Сертификация" + chr(4) + "" + chr(8)
 + "struct" + chr(4) + "Состав (комплектность)" + chr(4) + "" + chr(8)
 + "sort" + chr(4) + "Сорт" + chr(4) + "" + chr(8)
 + "deadline" + chr(4) + "Срок хранения" + chr(4) + "" + chr(8)
 + "negative-rest" + chr(4) + "Разр. отриц.остатки" + chr(4) + "" + chr(8)
 + "cost-calc" + chr(4) + "Расчет учетных цен" + chr(4) + "" + chr(8)
 + "unit-cst" + chr(4) + "Таможенная единица изм" + chr(4) + "" + chr(8)
 + "cst-base-rate" + chr(4) + "Коэффициент" + chr(4) + "" + chr(8)
 + "TNVED" + chr(4) + "Код ТНВЭД" + chr(4) + "" + chr(8)
 + "min-stock" + chr(4) + "Мин. остаток" + chr(4) + "" + chr(8)
 + "nationality" + chr(4) + "Национальность" + chr(4) + "" + chr(8)
 + "label-name" + chr(4) + "Название на ценнике" + chr(4) + "" + chr(8)
 + "alpha1" + chr(4) + "Код страны" + chr(4) + "" + chr(8)
 + "normal-wastage" + chr(4) + "Норма естественной убыли" + chr(4) + "" + chr(8)
 + "normal-waste" + chr(4) + "Норма отходов" + chr(4) + "" + chr(8)
 + "chk-name" + chr(4) + "Название на чеке" + chr(4) + "" + chr(8)
 + "min-rate" + chr(4) + "Мин. кол-во дробн./шт" + chr(4) + "" + chr(8)
 + "max-rate" + chr(4) + "Макс. кол-во дробн./шт" + chr(4) + "" + chr(8)
 + "cr-db-num" + chr(4) + "Номер БД где создан" + chr(4) + "" + chr(8)
 + "cond-keep-code" + chr(4) + "Код условий хранения" + chr(4) + "" + chr(8)
 + "wt-cart" + chr(4) + "Вес штуки" + chr(4) + "" + chr(8)
 + "ms-cart" + chr(4) + "Объем штуки" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer current_c-goods:handle
                                            ,input  'goods':U
                                            ,input  "prod-type,prod-code,artic,gds-name,unit-base,prt-root,"  + "grp-code,unit-cli,cli-base-rate,calc-method,increase-pc,stts,qnty-cart,wt-cart,ms-cart," + "engl-name,grp-name,gds-type,PS.okdp,destin,attrib,user-rule,sert,struct," + "sort,deadline,negative-rest,cost-calc,unit-cst,cst-base-rate,TNVED,min-stock,nationality,label-name," + "alpha1,normal-wastage,normal-waste,chk-name,min-rate,max-rate,cr-db-num,cond-keep-code,wt-cart,ms-cart"
                                            ,input  v-label-param).
end.
end procedure.
procedure gds-obj-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-gds-obj-attr for ub.c-gds-obj-attr  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
find first current_c-gds-obj-attr no-lock where
            current_c-gds-obj-attr.gds-code = p-gds-code
        AND current_c-gds-obj-attr.chip-num = p-chip-num
        AND current_c-gds-obj-attr.corr-user-db-num = p-corr-user-db-num
        AND current_c-gds-obj-attr.obj-type = p-obj-type
        AND current_c-gds-obj-attr.obj-code = p-obj-code
        AND current_c-gds-obj-attr.attr-code = buf_c-gds-hist.attr-code
        no-error .
define variable v-label-param as character no-undo .
v-label-param =
  "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "attr-code" + chr(4) + "Атрибут" + chr(4) + "" + chr(8)
 + "gds-code" + chr(4) + "Код товара" + chr(4) + "" + chr(8)
 + "attr-value" + chr(4) + "Значение атрибута" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer current_c-gds-obj-attr:handle
                                            ,input  'gds-obj-attr':U
                                            ,input  "obj-type,obj-code,attr-code,gds-code,attr-value"
                                            ,input  v-label-param).
    run gdsoattr-tooltip in this-procedure (
                input  current_c-gds-obj-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + chr(32) + v-label
    .
end.
end procedure.
procedure gds-host-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-gds-host-attr for ub.c-gds-host-attr  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first current_c-gds-host-attr no-lock where
               current_c-gds-host-attr.gds-code = p-gds-code
           AND current_c-gds-host-attr.chip-num = p-chip-num
           AND current_c-gds-host-attr.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-gds-host-attr then do:
      v-mess = "Неверная ссылка на c-gds-host-attr в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    run gdshattr-tooltip in this-procedure (
                input  string(current_c-gds-host-attr.attr-code)
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + chr(32) + v-label
    .
define variable v-label-param as character no-undo .
v-label-param =
  "host-code" + chr(4) + "Код фирмы" + chr(4) + "" + chr(8)
 + "attr-code" + chr(4) + "Атрибут" + chr(4) + "" + chr(8)
 + "gds-code" + chr(4) + "Код товара" + chr(4) + "" + chr(8)
 + "attr-value" + chr(4) + "Значение атрибута" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer current_c-gds-host-attr:handle
                                            ,input  'gds-host-attr':U
                                            ,input  "host-code,attr-code,gds-code,attr-value"
                                            ,input  v-label-param).
end.
end procedure.
procedure goods-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-goods-attr for ub.c-goods-attr  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first current_c-goods-attr no-lock where
               current_c-goods-attr.gds-code = p-gds-code
           AND current_c-goods-attr.chip-num = p-chip-num
           AND current_c-goods-attr.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-goods-attr then do:
      v-mess = "Неверная ссылка на c-goods-attr в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    run gds-attr-tooltip in this-procedure (
                input  string(current_c-goods-attr.attr-code)
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + chr(32) + v-label
    .
    define variable v-label-param as character no-undo .
v-label-param =
  "attr-code" + chr(4) + "Атрибут" + chr(4) + "" + chr(8)
 + "gds-code" + chr(4) + "Код товара" + chr(4) + "" + chr(8)
 + "attr-value" + chr(4) + "Значение атрибута" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer current_c-goods-attr:handle
                                            ,input  'goods-attr':U
                                            ,input  "attr-code,gds-code,attr-value"
                                            ,input  v-label-param).
end.
end procedure.
procedure fbr-gds-obj-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-is-created as logical no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .
define variable jj as integer no-undo .
define buffer current_c-fbr-gds-obj for ub.c-fbr-gds-obj  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first current_c-fbr-gds-obj no-lock where
               current_c-fbr-gds-obj.gds-code = p-gds-code
           AND current_c-fbr-gds-obj.chip-num = p-chip-num
           AND current_c-fbr-gds-obj.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-fbr-gds-obj then do:
      v-mess  = "Неверная ссылка на c-fbr-gds-obj в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "is-menu" + chr(4) + "Блюдо меню" + chr(4) + "" + chr(8)
 + "is-cd" + chr(4) + "На кассу" + chr(4) + "" + chr(8)
 + "is-season" + chr(4) + "Использ.Сезон.коэф." + chr(4) + "" + chr(8)
 + "calc-code" + chr(4) + "Номер калк.карты" + chr(4) + "" + chr(8)
 + "cfact-date" + chr(4) + "Факт-дата" + chr(4) + "" + chr(8)
 + "is-semi-finished" + chr(4) + "Полуфабрикат" + chr(4) + "" + chr(8)
 + "is-modificator" + chr(4) + "Модификатор блюда" + chr(4) + "" + chr(8)
 + "is-modified" + chr(4) + "Модифицируемое блюдо" + chr(4) + "" + chr(8)
 + "is-null-price" + chr(4) + "Без цены" + chr(4) + "" + chr(8)
 + "is-tarified" + chr(4) + "Тарифицируемое блюдо" + chr(4) + "" + chr(8)
 + "fbr-grp-code" + chr(4) + "Код группы меню" + chr(4) + "" + chr(8)
 + "fbr-obj-type" + chr(4) + "Тип объекта-кухни" + chr(4) + "" + chr(8)
 + "fbr-obj-code" + chr(4) + "Код объекта-кухни" + chr(4) + "" + chr(8)
 + "mand-modif-code" + chr(4) + "Группа обяз. модиф-ров" + chr(4) + "" + chr(8)
 + "non-mand-modif-code" + chr(4) + "Группа необяз. модиф-ров" + chr(4) + "" + chr(8)
 + "modif-qnty" + chr(4) + "Кол-ов обяза. модиф-ров" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer current_c-fbr-gds-obj:handle
                                            ,input  'fbr-gds-obj':U
                                            ,input  "is-menu,is-cd,is-season,calc-code,cfact-date,is-semi-finished,is-modificator,is-modified,"  + "is-null-price,is-tarified,fbr-grp-code,fbr-obj-type,fbr-obj-code,mand-modif-code,non-mand-modif-code,modif-qnty"
                                            ,input  v-label-param).
end.
end procedure.
procedure s-coeff-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-s-coeff for ub.c-s-coeff  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first current_c-s-coeff no-lock where
               current_c-s-coeff.gds-code = p-gds-code
           AND current_c-s-coeff.chip-num = p-chip-num
           AND current_c-s-coeff.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-s-coeff then do:
      v-mess = "Неверная ссылка на c-s-coeff в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    assign
    p-description = "Начало действия" + chr(32) +
                    entry(1, string(current_c-s-coeff.s-date, "99/99/9999":U), chr(47)) + chr(47) +
                    entry(2, string(current_c-s-coeff.s-date, "99/99/9999":U), chr(47))
    .
define variable v-label-param as character no-undo .
v-label-param =
  "coeff-value" + chr(4) + "Значение коэфф" + chr(4) + "" + chr(8)
 + "credate" + chr(4) + "Дата создания" + chr(4) + "" + chr(8)
 + "creid" + chr(4) + "Создал" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer current_c-s-coeff:handle
                                            ,input  's-coeff':U
                                            ,input  "coeff-value,credate,creid"
                                            ,input  v-label-param).
end.
end procedure.
function get-node-code-name returns character ( input p-node-code as integer):
define variable v-prt-name as character no-undo .
v-prt-name = "(":U + string(p-node-code) + ")".
define buffer buf_gds-prt for ub.gds-prt.
find first buf_gds-prt no-lock where
          buf_gds-prt.node-code = p-node-code no-error.
if available buf_gds-prt then do:
  assign
  v-prt-name =  (if buf_gds-prt.f-name <> "":U
                then buf_gds-prt.f-name
                else buf_gds-prt.node-name) + "(":U + string(p-node-code) + ")"
  .
end.
return v-prt-name.
end function.
procedure bar-code-proc :
define output parameter p-description as character no-undo .
define buffer current_c-bar-code for ub.c-bar-code  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first current_c-bar-code no-lock where
               current_c-bar-code.gds-code = p-gds-code
           AND current_c-bar-code.b-code   = buf_c-gds-hist.b-code
           AND current_c-bar-code.chip-num = p-chip-num
           AND current_c-bar-code.corr-user-db-num = p-corr-user-db-num no-error .
    if not avail current_c-bar-code
    and buf_c-gds-hist.action = integer('9':U)
    then do:
      find first current_c-bar-code no-lock where
                current_c-bar-code.gds-code = p-gds-code
            AND current_c-bar-code.chip-num = p-chip-num
            AND current_c-bar-code.corr-user-db-num = p-corr-user-db-num no-error .
    end.
    if not avail current_c-bar-code then do:
      v-mess = "Неверная ссылка на c-bar-code в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "b-code" + chr(4) + "Бар-код" + chr(4) + "" + chr(8)
 + "cli-base-rate" + chr(4) + "Коэффициент" + chr(4) + "" + chr(8)
 + "cr-db-num" + chr(4) + "Создан в БД №" + chr(4) + "" + chr(8)
 + "in-code" + chr(4) + "ПН" + chr(4) + "" + chr(8)
 + "node-code" + chr(4) + "узел шкалы (вн.№)" + chr(4) + "get-node-code-name" + chr(8)
 + "part-code" + chr(4) + "№ партии" + chr(4) + "" + chr(8)
 + "stts_" + chr(4) + "Статус" + chr(4) + "" + chr(8)
 + "unit-cli" + chr(4) + "Ед.изм" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer current_c-bar-code:handle
                                            ,input  'bar-code':U
                                            ,input  "b-code,cli-base-rate,cr-db-num,in-code,node-code,part-code,stts_,unit-cli"
                                            ,input  v-label-param).
end.
end procedure.
procedure bar-code-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-bar-code-attr for ub.c-bar-code-attr  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first current_c-bar-code-attr no-lock where
               current_c-bar-code-attr.gds-code = p-gds-code
           AND current_c-bar-code-attr.b-code   = buf_c-gds-hist.b-code
           AND current_c-bar-code-attr.chip-num = p-chip-num
           AND current_c-bar-code-attr.corr-user-db-num = p-corr-user-db-num no-error .
    if not avail current_c-bar-code-attr
    and buf_c-gds-hist.action = integer('9':U)
    then do:
      find first current_c-bar-code-attr no-lock where
                current_c-bar-code-attr.gds-code = p-gds-code
            AND current_c-bar-code-attr.chip-num = p-chip-num
            AND current_c-bar-code-attr.corr-user-db-num = p-corr-user-db-num no-error .
    end.
    if not avail current_c-bar-code-attr then do:
      v-mess = "Неверная ссылка на c-bar-code-attr в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
run bc-attr_tooltip in this-procedure (
            input  string(current_c-bar-code-attr.attr-code)
            ,output v-tooltip
            ,output v-label
            ) no-error .
assign
p-description = "Атрибут" + chr(32) + v-label
.
define variable v-label-param as character no-undo .
v-label-param =
  "b-code" + chr(4) + "Бар-код" + chr(4) + "" + chr(8)
 + "attr-code" + chr(4) + "Атрибут" + chr(4) + "" + chr(8)
 + "attr-value" + chr(4) + "Знач.атр-та" + chr(4) + "" + chr(8)
 + "gds-code" + chr(4) + "Код товара" + chr(4) + ""
 .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer current_c-bar-code-attr:handle
                                            ,input  'bar-code-attr':U
                                            ,input  "b-code,attr-code,attr-value,gds-code"
                                            ,input  v-label-param).
end.
end procedure.
procedure bar-code-obj-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-bar-code-obj-attr for ub.c-bar-code-obj-attr  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first current_c-bar-code-obj-attr no-lock where
               current_c-bar-code-obj-attr.gds-code = p-gds-code
           AND current_c-bar-code-obj-attr.b-code   = buf_c-gds-hist.b-code
           AND current_c-bar-code-obj-attr.chip-num = p-chip-num
           AND current_c-bar-code-obj-attr.corr-user-db-num = p-corr-user-db-num no-error .
    if not avail current_c-bar-code-obj-attr
    and buf_c-gds-hist.action = integer('9':U)
    then do:
      find first current_c-bar-code-obj-attr no-lock where
                current_c-bar-code-obj-attr.gds-code = p-gds-code
            AND current_c-bar-code-obj-attr.chip-num = p-chip-num
            AND current_c-bar-code-obj-attr.corr-user-db-num = p-corr-user-db-num no-error .
    end.
    if not avail current_c-bar-code-obj-attr then do:
      v-mess = "Неверная ссылка на c-bar-code-obj-attr в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
run bc-oattr_tooltip in this-procedure (
            input  string(current_c-bar-code-obj-attr.attr-code)
            ,output v-tooltip
            ,output v-label
            ) no-error .
assign
p-description = "Атрибут" + chr(32) + v-label
.
define variable v-label-param as character no-undo .
v-label-param =
  "b-code" + chr(4) + "Бар-код" + chr(4) + "" + chr(8)
 + "attr-code" + chr(4) + "Атрибут" + chr(4) + "" + chr(8)
 + "attr-value" + chr(4) + "Знач.атр-та" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "gds-code" + chr(4) + "Код товара" + chr(4) + ""
 .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer current_c-bar-code-obj-attr:handle
                                            ,input  'bar-code-obj-attr':U
                                            ,input  "b-code,attr-code,attr-value,gds-code"
                                            ,input  v-label-param).
end.
end procedure.
procedure prod-bc-proc :
define output parameter p-description as character no-undo .
define buffer current_c-prod-bc for ub.c-prod-bc  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first current_c-prod-bc no-lock where
               current_c-prod-bc.b-code   = buf_c-gds-hist.b-code
           AND current_c-prod-bc.b-str   = buf_c-gds-hist.b-str
           AND current_c-prod-bc.chip-num = p-chip-num
           AND current_c-prod-bc.corr-user-db-num = p-corr-user-db-num no-error .
    if not avail current_c-prod-bc then do:
      v-mess = "Неверная ссылка на c-prod-bc в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    assign
    p-description = substitute("Бар-код &1", current_c-prod-bc.b-str)
    .
define variable v-label-param as character no-undo .
v-label-param =
  "b-str" + chr(4) + "ДопБК" + chr(4) + "" + chr(8)
 + "bc-on" + chr(4) + "Включен" + chr(4) + "" + chr(8)
 + "cr-db-num" + chr(4) + "Создан в БД №" + chr(4) + "" + chr(8)
 + "bc-on-type" + chr(4) + "Тип активности" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer current_c-prod-bc:handle
                                            ,input  'prod-bc':U
                                            ,input  "b-str,bc-on,cr-db-num,bc-on-type"
                                            ,input  v-label-param).
end.
end procedure.
procedure varianty-delivery-gds-obj-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-varianty-delivery-gds-obj for ub.c-varianty-delivery-gds-obj  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first curr_c-varianty-delivery-gds-obj no-lock where
               curr_c-varianty-delivery-gds-obj.gds-code = p-gds-code
           AND curr_c-varianty-delivery-gds-obj.chip-num = p-chip-num
           AND curr_c-varianty-delivery-gds-obj.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail curr_c-varianty-delivery-gds-obj then do:
       v-mess = "Неверная ссылка на c-varianty-delivery-gds-obj в таблице c-gds-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "cond-keep-code" + chr(4) + "Код условия хранения" + chr(4) + "" + chr(8)
 + "deliv-subj-code" + chr(4) + "Код субъекта доставки" + chr(4) + "" + chr(8)
 + "deliv-type-code" + chr(4) + "Код типа доставки" + chr(4) + "" + chr(8)
 + "des" + chr(4) + "Описание" + chr(4) + "" + chr(8)
 + "gr-per-val-code" + chr(4) + "Код группы сроков хранения" + chr(4) + "" + chr(8)
 + "sts" + chr(4) + "Статус" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer curr_c-varianty-delivery-gds-obj:handle
                                            ,input  'varianty-delivery-gds-obj':U
                                            ,input  "cond-keep-code,deliv-subj-code,deliv-type-code,des,gr-per-val-code,sts"
                                            ,input  v-label-param).
end.
end procedure.
procedure gds-season-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-gds-season for ub.c-gds-season  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first curr_c-gds-season no-lock where
               curr_c-gds-season.gds-code = p-gds-code
           AND curr_c-gds-season.chip-num = p-chip-num
           AND curr_c-gds-season.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail curr_c-gds-season then do:
       v-mess = "Неверная ссылка на c-gds-season в таблице c-gds-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "sea-code" + chr(4) + "Код сезона" + chr(4) + "" + chr(8)
 + "min-stock" + chr(4) + "Минимальный запас" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer curr_c-gds-season:handle
                                            ,input  'gds-season':U
                                            ,input  "sea-code,min-stock"
                                            ,input  v-label-param).
end.
end procedure.
procedure tax-rate-gds-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label as character no-undo .
define variable v-field-name as character no-undo .
define variable v-old-rate-code like ub.tax-rate-gds.rate-code no-undo .
define variable v-old-fact-order like ub.tax-rate-gds.fact-order no-undo .
define variable v-old-fact-date as date no-undo .
define variable v-new-rate-code like ub.tax-rate-gds.rate-code no-undo .
define variable v-new-fact-order like ub.tax-rate-gds.fact-order no-undo .
define variable v-new-fact-date as date no-undo .
define buffer buf_next_tax-rate-gds for ub.tax-rate-gds.
define buffer buf_tax for ub.tax.
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first buf_tax no-lock where
              buf_tax.tax-code = buf_c-gds-hist.tax-code no-error .
    if available buf_tax then do:
      assign
      p-description = buf_tax.tax-name.
    end.
    assign
    v-old-rate-code = buf_c-gds-hist.rate-code
    v-old-fact-order = buf_c-gds-hist.fact-order
    .
    run factord-to-date in this-procedure (
                                            input v-old-fact-order
                                           ,output v-old-fact-date) no-error .
    assign
    v-chg-fields = "rate-code,fact-date"
    .
    find first buf_next_tax-rate-gds no-lock where
            buf_next_tax-rate-gds.gds-code = p-gds-code
        AND buf_next_tax-rate-gds.host-code        = 0
        AND buf_next_tax-rate-gds.obj-type         = "":U
        AND buf_next_tax-rate-gds.obj-code         = 0
        AND buf_next_tax-rate-gds.tax-code         = buf_c-gds-hist.tax-code
        AND buf_next_tax-rate-gds.fact-order       > buf_c-gds-hist.fact-order no-error .
    if available buf_next_tax-rate-gds then do:
      assign
      v-new-rate-code = buf_next_tax-rate-gds.rate-code
      v-new-fact-order = buf_next_tax-rate-gds.fact-order
      .
      run factord-to-date in this-procedure (
                                              input v-new-fact-order
                                            ,output v-new-fact-date) no-error .
    end.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "rate-code,fact-date").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Код ставки,Начало действия")
    .
    create temp-changes.
    assign
    temp-changes.f_name = v-field-name
    temp-changes.l_name = v-field-label
    temp-changes.v_old = (if temp-changes.f_name = "rate-code"
                          then string(v-old-rate-code)
                          else string(v-old-fact-date, "99/99/9999")
                          )
    temp-changes.v_new = (if temp-changes.f_name = "rate-code"
                          then string(v-new-rate-code)
                          else string(v-new-fact-date, "99/99/9999")
                          )
    .
  end.
end.
end procedure.
procedure ass-matr-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-assortment-matrix-goods for ub.c-assortment-matrix-goods  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  find first curr_c-assortment-matrix-goods no-lock where
              curr_c-assortment-matrix-goods.gds-code        = p-gds-code
          AND curr_c-assortment-matrix-goods.chip-num        = p-chip-num
          AND curr_c-assortment-matrix-goods.corr-user-db-num = p-corr-user-db-num
          no-error .
  if not avail curr_c-assortment-matrix-goods then do:
    v-mess = "Неверная ссылка на c-assortment-matrix-goods в таблице c-gds-hist".
    run err-mess in this-procedure ( input-output v-mess).
    return error v-mess.
  end.
define variable v-label-param as character no-undo .
v-label-param =
  "asmg-status" + chr(4) + "Статус в а.матрице" + chr(4) + "" + chr(8)
 + "asmg-des" + chr(4) + "Описание" + chr(4) + "" + chr(8)
 + "asmt-id" + chr(4) + "Код матрицы" + chr(4) + "" + chr(8)
 + "db-num" + chr(4) + "БД" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer curr_c-assortment-matrix-goods:handle
                                            ,input  'assortment-matrix-goods':U
                                            ,input  "asmg-status,asmg-des,asmt-id,db-num"
                                            ,input  v-label-param).
end.
end procedure.
procedure izt-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-gds-obj-prop for ub.c-gds-obj-prop  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first curr_c-gds-obj-prop no-lock where
               curr_c-gds-obj-prop.gds-code        = p-gds-code
           AND curr_c-gds-obj-prop.chip-num        = p-chip-num
           AND curr_c-gds-obj-prop.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail curr_c-gds-obj-prop then do:
       v-mess = "Неверная ссылка на c-gds-obj-prop в таблице c-gds-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "gdop-assort-min" + chr(4) + "Асс.минимум" + chr(4) + "" + chr(8)
 + "gdop-igt" + chr(4) + "ИЖТ" + chr(4) + "" + chr(8)
 + "gdop-min-stock" + chr(4) + "Мин.остаток" + chr(4) + "" + chr(8)
 + "grop-level-always-presence" + chr(4) + "Уровень постоян.присут." + chr(4) + "" + chr(8)
 + "grop-max-stock" + chr(4) + "Макс.остаток" + chr(4) + "" + chr(8)
 + "grop-min-order" + chr(4) + "Мин.заказ" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer curr_c-gds-obj-prop:handle
                                            ,input  'gds-obj-prop':U
                                            ,input  "obj-type,obj-code,gdop-assort-min,gdop-igt,gdop-min-stock,grop-level-always-presence,grop-max-stock,grop-min-order"
                                            ,input  v-label-param).
end.
end procedure.
procedure pl-gds-proc :
define output parameter p-description as character no-undo .
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_c-pl-gds for ub.c-pl-gds  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-gds-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = 'c-gds-hist':U
          AND buf_c-table-bind.chip-num-rec     = buf_c-gds-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first curr_c-pl-gds no-lock where
               curr_c-pl-gds.gds-code = p-gds-code
           AND curr_c-pl-gds.corr-user-db-num = buf_c-table-bind.corr-user-db-num
           AND curr_c-pl-gds.chip-num = buf_c-table-bind.chip-num-src  no-error .
    if not avail curr_c-pl-gds then do:
      v-mess = "Неверная ссылка на c-pl-gds в таблице c-table-bind".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "gdop-assort-min" + chr(4) + "Асс.минимум" + chr(4) + "" + chr(8)
 + "gdop-igt" + chr(4) + "ИЖТ" + chr(4) + "" + chr(8)
 + "gdop-min-stock" + chr(4) + "Мин.остаток" + chr(4) + "" + chr(8)
 + "grop-level-always-presence" + chr(4) + "Уровень постоян.присут." + chr(4) + "" + chr(8)
 + "grop-max-stock" + chr(4) + "Макс.остаток" + chr(4) + "" + chr(8)
 + "grop-min-order" + chr(4) + "Мин.заказ" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer curr_c-pl-gds:handle
                                            ,input  'pl-gds':U
                                            ,input  "max-qnty,obj-code,obj-type,pl-code,PS,status_,tolerance"
                                            ,input  v-label-param).
end.
end procedure.
procedure pl-gds-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-pl-gds-attr for ub.c-pl-gds-attr  .
define buffer buf_c-table-bind for ub.c-table-bind.
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-gds-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = 'c-gds-hist':U
          AND buf_c-table-bind.chip-num-rec     = buf_c-gds-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first current_c-pl-gds-attr no-lock where
               current_c-pl-gds-attr.gds-code = p-gds-code
           AND current_c-pl-gds-attr.corr-user-db-num = buf_c-table-bind.corr-user-db-num
           AND current_c-pl-gds-attr.chip-num = buf_c-table-bind.chip-num-src  no-error .
    if not avail current_c-pl-gds-attr then do:
      v-mess = "Неверная ссылка на c-pl-gds-attr в таблице c-table-bind".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    run plgdattr-tooltip in this-procedure (
                input  current_c-pl-gds-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + chr(32) + v-label
    .
define variable v-label-param as character no-undo .
v-label-param =
  "attr-code" + chr(4) + "Атрибут" + chr(4) + "" + chr(8)
 + "attr-value" + chr(4) + "Значение атрибута" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer current_c-pl-gds-attr:handle
                                            ,input  'pl-gds-attr':U
                                            ,input  "attr-code,attr-value"
                                            ,input  v-label-param).
end.
end procedure.
procedure pl-gds-pump-proc :
define output parameter p-description as character no-undo .
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_c-pl-gds-pump for ub.c-pl-gds-pump  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-gds-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = 'c-gds-hist':U
          AND buf_c-table-bind.chip-num-rec     = buf_c-gds-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
       v-mess = "Неверная ссылка на c-table-bind в таблице c-gds-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
    find first curr_c-pl-gds-pump no-lock where
               curr_c-pl-gds-pump.gds-code = p-gds-code
           AND curr_c-pl-gds-pump.corr-user-db-num = buf_c-table-bind.corr-user-db-num
           AND curr_c-pl-gds-pump.chip-num = buf_c-table-bind.chip-num-src  no-error .
    if not avail curr_c-pl-gds-pump then do:
       v-mess = "Неверная ссылка на c-pl-gds-pump в таблице c-table-bind".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "pl-code" + chr(4) + "Код скласдкого места" + chr(4) + "" + chr(8)
 + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
 + "pump-code" + chr(4) + "Номер ТРК" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer curr_c-pl-gds-pump:handle
                                            ,input  'pl-gds-pump':U
                                            ,input  "obj-code,obj-type,pl-code,PS,pump-code,status_"
                                            ,input  v-label-param).
end.
end procedure.
procedure dis-gds-rule-proc :
define output parameter p-description as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-dis-gds-rule for ub.c-dis-gds-rule  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first current_c-dis-gds-rule no-lock where
               current_c-dis-gds-rule.gds-code = p-gds-code
           AND current_c-dis-gds-rule.chip-num = p-chip-num
           AND current_c-dis-gds-rule.corr-user-db-num = p-corr-user-db-num    no-error .
    if not avail current_c-dis-gds-rule then do:
       v-mess = "Неверная ссылка на c-dis-gds-rule в таблице c-gds-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
    run disgdsru-name in this-procedure (
                input  current_c-dis-gds-rule.templ-rl-root
                ,output v-label
                ) no-error .
    assign
    p-description = substitute("Тип скидки &1", v-label)
    .
define variable v-label-param as character no-undo .
v-label-param =
  "rule-num" + chr(4) + "Номер правила скидки" + chr(4) + "" + chr(8)
 + "pos-type" + chr(4) + "Место использ." + chr(4) + "" + chr(8)
 + "templ-rl-root" + chr(4) + "Шаблон скидки" + chr(4) + "disgdsru-get-disc-label" + chr(8)
 + "discnt-role" + chr(4) + "Тип скидки" + chr(4) + "disgdsru-get-disc-role-label" + chr(8)
 + "time-templ-rl-root" + chr(4) +  "Тип расписания" + chr(4) +  "":U
 .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer current_c-dis-gds-rule:handle
                                            ,input  'dis-gds-rule':U
                                            ,input  "rule-num,pos-type,templ-rl-root,discnt-role,time-templ-rl-root"
                                            ,input  v-label-param).
end.
end procedure.
procedure ext-artic-proc :
define output parameter p-description as character no-undo .
define buffer current_c-ext-artic for ub.c-ext-artic.
define buffer buf_clients         for ub.clients.
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  if buf_c-gds-hist.action <> integer('99':U) then do:
    find first current_c-ext-artic no-lock  where
           current_c-ext-artic.gds-code = buf_c-gds-hist.gds-code
        and current_c-ext-artic.corr-user-db-num = buf_c-gds-hist.corr-user-db-num
        and current_c-ext-artic.chip-num = buf_c-gds-hist.chip-num
    no-error .
    if not available current_c-ext-artic then do:
      v-mess = "Неверная ссылка на c-ext-artic в таблице c-gds-hist"  .
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "ext-artic" + chr(4) + "Внешний артикул" + chr(4) + "" + chr(8)
 + "ps" + chr(4) + "Описание" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer current_c-ext-artic:handle
                                            ,input  'ext-artic':U
                                            ,input  "ext-artic,ps,status_"
                                            ,input  v-label-param).
    find first buf_clients no-lock
      where buf_clients.obj-type = current_c-ext-artic.cli-type
        and buf_clients.obj-code = current_c-ext-artic.cli-code
    no-error .
    assign
      p-description = substitute( "Внешний артикул &1/&2 '&3'"
                                , current_c-ext-artic.cli-code
                                , current_c-ext-artic.cli-type
                                , if available buf_clients then
                                    buf_clients.obj-name
                                  else
                                    "":U
                                )
    .
  end.
end.
end procedure.
procedure sert-join-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .
define variable v-field-list as character no-undo .
define buffer curr_sert-join   for ub.sert-join  .
define buffer curr_c-sert for ub.c-sert  .
define buffer new_c-sert  for ub.c-sert  .
define buffer buf_c-table-bind for ub.c-table-bind.
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-gds-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = 'c-gds-hist':U
          AND buf_c-table-bind.chip-num-rec     = buf_c-gds-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
  find first curr_c-sert no-lock where
            curr_c-sert.b-code        = buf_c-gds-hist.b-code
        AND curr_c-sert.corr-user-db-num = buf_c-table-bind.corr-user-db-num
        AND curr_c-sert.chip-num        = buf_c-table-bind.chip-num-src   no-error .
  if not avail curr_c-sert then do:
    v-mess = "Неверная ссылка на c-sert-join в таблице c-gds-hist".
    run err-mess in this-procedure ( input-output v-mess).
    return error v-mess.
  end.
  find first new_c-sert no-lock where
              new_c-sert.b-code = buf_c-gds-hist.b-code
          AND new_c-sert.cli-type = curr_c-sert.cli-type
          AND new_c-sert.cli-code = curr_c-sert.cli-code
          AND new_c-sert.sert-code = curr_c-sert.sert-code
          AND new_c-sert.chip-num > p-chip-num
          AND new_c-sert.corr-user-db-num = p-corr-user-db-num
          no-error.
  if not available new_c-sert then do:
    find first curr_sert-join no-lock where
                curr_sert-join.b-code = buf_c-gds-hist.b-code
            AND curr_sert-join.cli-type  = curr_c-sert.cli-type
            AND curr_sert-join.cli-code  = curr_c-sert.cli-code
            AND curr_sert-join.sert-code = curr_c-sert.sert-code
            no-error.
    if not available curr_sert-join then do:
        return error.
    end.
    buffer-compare curr_sert-join to curr_c-sert
    case-sensitive
    save result in v-chg-fields.
  end.
  else do:
    buffer-compare new_c-sert
    except chip-num corr-date corr-user-name corr-user-db-num corr-time
    to curr_c-sert
    case-sensitive
    save result in v-chg-fields.
  end.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "b-code,cli-code,cli-type,sert-code").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Бар-код,Код контрагента,Тип контрагента,№ сертификата")
    v-field-function = entry(jj, ",,,")
    .
    create temp-changes.
    assign
    temp-changes.f_name = v-field-name
    temp-changes.l_name = v-field-label
    temp-changes.v_old = (if buf_c-gds-hist.action = integer('1':U)
                          then "":U
                          else string(buffer curr_c-sert:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new =  (if available new_c-sert
                                then string(buffer new_c-sert:buffer-field(v-field-name):buffer-value)
                                else string(buffer curr_sert-join:buffer-field(v-field-name):buffer-value)
                           )
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
  end.
end.
end procedure.
procedure recipe-gds-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-is-created as logical no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_recipe-gds for ub.recipe-gds  .
define buffer curr_c-recipe-gds for ub.c-recipe-gds  .
define buffer new_c-recipe-gds for ub.c-recipe-gds  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-gds-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = 'c-gds-hist':U
          AND buf_c-table-bind.chip-num-rec     = buf_c-gds-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first curr_c-recipe-gds no-lock where
               curr_c-recipe-gds.gds-code = p-gds-code
           AND curr_c-recipe-gds.corr-user-db-num = buf_c-table-bind.corr-user-db-num
           AND curr_c-recipe-gds.chip-num = buf_c-table-bind.chip-num-src  no-error .
    if not avail curr_c-recipe-gds then do:
      v-mess = "Неверная ссылка на c-recipe-gds в таблице c-table-bind".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first new_c-recipe-gds no-lock where
                new_c-recipe-gds.gds-code = buf_c-gds-hist.gds-code
            AND new_c-recipe-gds.chip-num > buf_c-table-bind.chip-num-src
            AND new_c-recipe-gds.corr-user-db-num = buf_c-table-bind.corr-user-db-num  no-error.
    if not available new_c-recipe-gds then do:
        find first curr_recipe-gds no-lock where
                    curr_recipe-gds.gds-code = buf_c-gds-hist.gds-code
                no-error.
        if not available curr_recipe-gds then do:
            return error.
        end.
        buffer-compare curr_recipe-gds to curr_c-recipe-gds
        case-sensitive
        save result in v-chg-fields.
    end.
    else do:
        buffer-compare new_c-recipe-gds except chip-num corr-date corr-user-name corr-user-db-num corr-time
        to curr_c-recipe-gds
        case-sensitive
        save result in v-chg-fields.
    end.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "artic,brutto-qnty,calc-method,coeff-waste,is-waste,proc-number,prod-code,prod-type,qnty,recipe-code").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Артикул,Кол-во брутто,Метод расчета брутто,Коэфф.отходов,Флаг ОТХОДЫ,Пор.№ при обработке,Код пр-ля,Тип пр-ля,Кол-во по рецепту,Номер рецепта")
    v-field-function = entry(jj, ",,,,,,,,,")
    .
    create temp-changes.
    assign
    temp-changes.f_name = v-field-name
    temp-changes.l_name = v-field-label
    temp-changes.v_old = (if v-is-created
                          then "":U
                          else string(buffer curr_c-recipe-gds:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new = (if available new_c-recipe-gds
                          then string(buffer new_c-recipe-gds:buffer-field(v-field-name):buffer-value)
                          else string(buffer curr_recipe-gds:buffer-field(v-field-name):buffer-value)
                          )
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
  end.
end.
end procedure.
procedure recipe-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-is-created as logical no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_recipe for ub.recipe  .
define buffer curr_c-recipe for ub.c-recipe  .
define buffer new_c-recipe for ub.c-recipe  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-gds-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = 'c-gds-hist':U
          AND buf_c-table-bind.chip-num-rec     = buf_c-gds-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first curr_c-recipe no-lock where
               curr_c-recipe.gds-code = p-gds-code
           AND curr_c-recipe.corr-user-db-num = buf_c-table-bind.corr-user-db-num
           AND curr_c-recipe.chip-num = buf_c-table-bind.chip-num-src  no-error .
    if not avail curr_c-recipe then do:
      v-mess = "Неверная ссылка на c-recipe в таблице c-table-bind".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first new_c-recipe no-lock where
                new_c-recipe.gds-code = buf_c-gds-hist.gds-code
            AND new_c-recipe.chip-num > buf_c-table-bind.chip-num-src
            AND new_c-recipe.corr-user-db-num = buf_c-table-bind.corr-user-db-num  no-error.
    if not available new_c-recipe then do:
        find first curr_recipe no-lock where
                    curr_recipe.gds-code = buf_c-gds-hist.gds-code
                no-error.
        if not available curr_recipe then do:
            return error.
        end.
        buffer-compare curr_recipe to curr_c-recipe
        case-sensitive
        save result in v-chg-fields.
    end.
    else do:
        buffer-compare new_c-recipe except chip-num corr-date corr-user-name corr-user-db-num corr-time
        to curr_c-recipe
        case-sensitive
        save result in v-chg-fields.
    end.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "host-code,obj-code,obj-type,portion-qnty,portion-weight,recipe-design,recipe-name,recipe-order,recipe-quality,recipe-ref-num,recipe-technique,recipe-template,recipe-type,sale-factor,artic,brutto-qnty,prod-code,prod-type,qnty,recipe-code").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Фирма,Код объекта,Тип объекта,Кол-во порций,Вес порции,Способ оформления,Название,Порядок при обработке,Показатели качества,Номер в справочнике рецептур,Технология,Ссылка на спр.рецептур,Тип рецепта,Кратность при продаже,Артикул,Кол-во брутто,Код пр-ля,Тип пр-ля,Кол-во по рецепту,Номер рецепта")
    v-field-function = entry(jj, ",,,,,,,,,,,,,,,,,,,")
    .
    create temp-changes.
    assign
    temp-changes.f_name = v-field-name
    temp-changes.l_name = v-field-label
    temp-changes.v_old = (if v-is-created
                          then "":U
                          else string(buffer curr_c-recipe:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new = (if available new_c-recipe
                          then string(buffer new_c-recipe:buffer-field(v-field-name):buffer-value)
                          else string(buffer curr_recipe:buffer-field(v-field-name):buffer-value)
                          )
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
  end.
end.
end procedure.
define temp-table temp-goods no-undo like ub.goods.
procedure ext-classif-proc :
define output parameter p-description as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable v-label-param as character no-undo .
define buffer curr_c-ext-classif for ub.c-ext-classif  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    create temp-goods.
    buffer-copy buf_c-gds-hist to temp-goods.
    run gen-key-rec in this-procedure ( input 'goods':U
                                       ,input (buffer temp-goods:handle)
                                       ,output v-uniq-key-rec).
    delete temp-goods.
    find first curr_c-ext-classif no-lock where
           curr_c-ext-classif.uniq-key-rec = v-uniq-key-rec
           AND curr_c-ext-classif.chip-num = p-chip-num
           AND curr_c-ext-classif.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail curr_c-ext-classif then do:
       v-mess = "Неверная ссылка на c-ext-classif в таблице c-gds-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
case curr_c-ext-classif.classif-name:
  when 'exp-accor-gds-code':U then do:
   assign
   v-label-param = "key#_one" + chr(4) + "Код топлива " + chr(4) + ""
   p-description = "Классификатор АККОР"
   .
  end.
end case.
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer curr_c-ext-classif:handle
                                            ,input  'ext-classif':U
                                            ,input  "key#_one"
                                            ,input  v-label-param).
end.
end procedure.
procedure gds-obj-prop-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-gds-obj-prop-attr for ub.c-gds-obj-attr .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
find first current_c-gds-obj-prop-attr no-lock where
            current_c-gds-obj-prop-attr.gds-code = p-gds-code
        AND current_c-gds-obj-prop-attr.chip-num = p-chip-num
        AND current_c-gds-obj-prop-attr.corr-user-db-num = p-corr-user-db-num
        AND current_c-gds-obj-prop-attr.obj-type = p-obj-type
        AND current_c-gds-obj-prop-attr.obj-code = p-obj-code
        AND current_c-gds-obj-prop-attr.attr-code = buf_c-gds-hist.attr-code
        no-error .
define variable v-label-param as character no-undo .
v-label-param =
  "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "attr-code" + chr(4) + "Атрибут" + chr(4) + "" + chr(8)
 + "gds-code" + chr(4) + "Код товара" + chr(4) + "" + chr(8)
 + "attr-value" + chr(4) + "Значение атрибута" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-hist.action = integer('99':U))
                                            ,input  buffer current_c-gds-obj-prop-attr:handle
                                            ,input  'gds-obj-prop-attr':U
                                            ,input  "obj-type,obj-code,attr-code,gds-code,attr-value"
                                            ,input  v-label-param).
    run gdspoatr-tooltip in this-procedure (
                input  current_c-gds-obj-prop-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + chr(32) + v-label
    .
end.
end procedure.
procedure gds-obj-ref-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-is-created as logical no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define buffer current_c-gds-obj-ref for ub.c-gds-obj-ref  .
define buffer curr_gds-obj for ub.gds-obj .
define buffer new_c-gds-obj-ref for ub.c-gds-obj-ref  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first current_c-gds-obj-ref no-lock where
               current_c-gds-obj-ref.gds-code = p-gds-code
           AND current_c-gds-obj-ref.chip-num = p-chip-num
           AND current_c-gds-obj-ref.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-gds-obj-ref then do:
      v-mess  = "Неверная ссылка на c-gds-obj-ref в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first new_c-gds-obj-ref no-lock where
                new_c-gds-obj-ref.gds-code = p-gds-code
            AND new_c-gds-obj-ref.chip-num > p-chip-num
            AND new_c-gds-obj-ref.corr-user-db-num = p-corr-user-db-num  no-error.
    if not available new_c-gds-obj-ref then do:
      find first curr_gds-obj no-lock where
                  curr_gds-obj.gds-code = buf_c-gds-hist.gds-code
              and curr_gds-obj.obj-type = buf_c-gds-hist.obj-type
              and curr_gds-obj.obj-code = buf_c-gds-hist.obj-code
              no-error.
      if not available curr_gds-obj then do:
          return error.
      end.
      buffer-compare curr_gds-obj to current_c-gds-obj-ref
      case-sensitive
      save result in v-chg-fields.
    end.
    else do:
      buffer-compare new_c-gds-obj-ref except chip-num corr-date corr-user-name corr-user-db-num corr-time
      to current_c-gds-obj-ref
      case-sensitive
      save result in v-chg-fields.
    end.
v-is-created = (buf_c-gds-hist.action = integer('1':U)).
if v-chg-fields = '' and
v-is-created = yes then do:
  v-chg-fields = "obj-type,obj-code".
end.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "cash-parts,insalepr,place-rsrv,obj-type,obj-code").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Продажа по партиям,Приход по продаж цене,Мин.запас,Резервирование по скл.местам,Тип объекта,Код объекта")
    v-field-function = entry(jj, ",,,,")
    .
    create temp-changes.
    assign
    temp-changes.f_name = v-field-name
    temp-changes.l_name = v-field-label
    temp-changes.v_old = (if v-is-created
                          then "":U
                          else string(buffer current_c-gds-obj-ref:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new = (if available new_c-gds-obj-ref
                          then string(buffer new_c-gds-obj-ref:buffer-field(v-field-name):buffer-value)
                          else string(buffer curr_gds-obj:buffer-field(v-field-name):buffer-value)
                          )
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
  end.
end.
end procedure.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =  substitute("История товара с кодом &1: щепка &2 БД:&3 фирма: &4 объект: &5&6 Предмет изменений &7&8&9"
                            ,p-gds-code
                            ,p-chip-num
                            ,p-corr-user-db-num
                            ,p-host-code
                            ,p-obj-type
                            ,p-obj-code
                            ,p-subject
                            ,chr(10)
                            ,p-mess).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
