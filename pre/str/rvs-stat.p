block-level on error undo, throw.
define input parameter parparentproc   as widget-handle no-undo.
define input parameter parrecid        as recid         no-undo.
define input parameter paraction       as character     no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Переход по статусам в документах сверки":U .
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
  define new global shared variable g#lib-rvs as handle no-undo.
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function autorvs return char
    ( input p-rec as recid  ) :
    define variable p-autorvs as char no-undo.
    define buffer Buf_doc-attr for doc-attr.
    define buffer r-d          for rvs-doc.
    find first r-d no-lock where recid(r-d) = p-rec no-error.
    find first buf_doc-attr no-lock where r-d.rvs-code = buf_doc-attr.doc-code and buf_doc-attr.attr-code = "rvs-auto" and buf_doc-attr.attr-value = "Yes" no-error.
    if available buf_doc-attr then
    do :
        p-autorvs = 'а'.
    end.
    else
    do:
        if r-d.is-full = yes then
        do:
            p-autorvs =  "п" .
        end.
        else
        do :
            p-autorvs = " ".
        end.
    end.
    return ( p-autorvs ).
end function.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
tr:
do transaction
    on error  undo tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on stop   undo tr, return error substitute( "&1. stop", vss-workfile )
    on endkey undo tr, return error substitute( "&1. endkey", vss-workfile )
    :
    define variable vardata-type as character no-undo.
    define variable was_found    as logical   no-undo initial no.
    define variable v-auto       as logical   no-undo.
    define buffer buf_rvs-doc  for ub.rvs-doc .
    define buffer buf_rvs-line for ub.rvs-line .
    define buffer buf_doc-pl   for ub.doc-pl .
    define buffer buf_pl-gds   for ub.pl-gds .
    define buffer buf_place    for ub.place .
    define buffer last-rvs-doc for ub.rvs-doc .
    define buffer last-rvs-line for ub.rvs-line .
    define buffer buf_doc-attr for ub.doc-attr .
    define variable v-cardif        as integer   no-undo .
    define variable v-abs-critdif   as decimal   no-undo .
    define variable v-dif-res-count as integer   no-undo .
    define variable v-dif-res       as character no-undo .
    define variable v-ok            as logical   no-undo .
    define variable v-first-volue      as decimal  no-undo .
    define variable v-first-density    as decimal  no-undo .
    define variable v-first-temp       as decimal  no-undo .
    define variable v-first-water      as decimal  no-undo .
    find first buf_rvs-doc exclusive-lock
        where recid(buf_rvs-doc) = parrecid
        .
    if autorvs(recid(buf_rvs-doc)) = "А"
    then do:
      v-auto = yes.
    end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_rvs-doc.obj-type
  ,input buf_rvs-doc.obj-code
  ,input 'petrol':U
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
      if thbjattr_thbj-attr.prop-code = 'CriticalDif':U then assign v-cardif = integer( thbjattr_thbj-attr.property-value-character) .
    end.
    if buf_rvs-doc.rvs-type <> 'смена':U
    and buf_rvs-doc.rvs-type <> 'контроль':U
    and buf_rvs-doc.rvs-type <> 'перед_док':U
    and buf_rvs-doc.rvs-type <> 'после_док':U
    and buf_rvs-doc.rvs-type <> 'проверка':U
    then do:
      undo tr, return error substitute("Смена статуса документа сверки. Неизвестный тип документа сверки &1.", buf_rvs-doc.rvs-type).
    end.
    if buf_rvs-doc.rvs-type = 'проверка':U
    then do :
      for each buf_rvs-line no-lock
          where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
          on error undo, return error return-value
      :
        find first rvs-line-attr no-lock
             where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
               and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
               and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
               and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
               and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
               and rvs-line-attr.attr-code = "test-asi-diff" no-error.
        if not available rvs-line-attr
        or (available rvs-line-attr and  (rvs-line-attr.attr-value = "" or decimal(rvs-line-attr.attr-value) = ?))
        then do :
          undo tr, return error substitute("Закрытие невозможно. Не выполнен расчёт проверки по резервуару &1.", buf_rvs-line.pl-code).
        end.
      end .
      assign
        buf_rvs-doc.status_ = 'факт':U
      .
      return .
    end .
    for last last-rvs-doc no-lock
    where last-rvs-doc.obj-type   = buf_rvs-doc.obj-type
      and last-rvs-doc.obj-code   = buf_rvs-doc.obj-code
      and last-rvs-doc.status_    = 'факт':U
      and last-rvs-doc.rvs-type   = 'смена':U,
      each last-rvs-line  exclusive-lock where last-rvs-line.rvs-code = last-rvs-doc.rvs-code
    :
    end.
    case paraction:
      when "open":U
      then do:
        case buf_rvs-doc.status_:
          when 'разрешен':U
          then do:
            assign
              buf_rvs-doc.status_ = 'новый':U
            .
            for each buf_rvs-line exclusive-lock
                where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                on error undo, return error return-value
            :
              assign
                buf_rvs-line.system-qnty          = 0.0
                buf_rvs-line.system-cli-qnty      = 0.0
                buf_rvs-line.orig-system-qnty     = buf_rvs-line.system-qnty
                buf_rvs-line.orig-system-cli-qnty = buf_rvs-line.system-cli-qnty
              .
              find first rvs-line-attr exclusive-lock
                  where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                  and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                  and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                  and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                  and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                  and rvs-line-attr.attr-code = "CriticalDif" no-error.
              if available rvs-line-attr then
              do :
                delete rvs-line-attr .
              end.
            end.
            release rvs-line-attr no-error .
          end.
          otherwise
          do:
            undo tr, return error "Возможно открытие документа только в статусе: " + 'разрешен':U + " .".
          end.
        end case.
      end.
      when "close":U
      then do:
        case buf_rvs-doc.status_:
          when 'новый':U
          then do:
            if buf_rvs-doc.rvs-type <> 'после_док':U
            then do:
              run trg/lock-rvs.p
                  ( input buf_rvs-doc.rvs-code
                  ,input "assign-rvs-on=true":U
                  ,input "":U
                  ,input false
                  ) no-error.
              if error-status :error then
              do:
                undo tr, return error substitute( "Ошибка при блокировке по документу сверки &2&1&3&1&4", chr(10), buf_rvs-doc.rvs-code, error-status :get-message(1), return-value ) .
              end.
            end.
            for each buf_rvs-line exclusive-lock
                where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                on error undo, return error return-value
            :
              if  v-auto <> yes
              then do:
                find first buf_pl-gds exclusive-lock
                    where buf_pl-gds.obj-type = buf_rvs-doc.obj-type
                    and buf_pl-gds.obj-code = buf_rvs-doc.obj-code
                    and buf_pl-gds.pl-code  = buf_rvs-line.pl-code
                    and buf_pl-gds.gds-code = buf_rvs-line.gds-code
                .
              end.
              else do:
                find first buf_pl-gds no-lock
                    where buf_pl-gds.obj-type = buf_rvs-doc.obj-type
                    and buf_pl-gds.obj-code = buf_rvs-doc.obj-code
                    and buf_pl-gds.pl-code  = buf_rvs-line.pl-code
                    and buf_pl-gds.gds-code = buf_rvs-line.gds-code
                .
              end.
              find first buf_place no-lock
                  where buf_place.obj-type = buf_rvs-doc.obj-type
                  and buf_place.obj-code = buf_rvs-doc.obj-code
                  and buf_place.pl-code  = buf_rvs-line.pl-code
              .
              assign
                buf_rvs-line.tolerance            = buf_pl-gds.tolerance
                buf_rvs-line.add-qnty             = buf_place.add-qnty
                buf_rvs-line.state-add-qnty       = buf_place.add-qnty
                buf_rvs-line.system-qnty          = buf_pl-gds.fact-qnty
                buf_rvs-line.system-cli-qnty      = buf_pl-gds.cli-fact-qnty
                buf_rvs-line.orig-system-qnty     = buf_rvs-line.system-qnty
                buf_rvs-line.orig-system-cli-qnty = buf_rvs-line.system-cli-qnty
              .
              if  v-cardif > 0 and abs(  buf_rvs-line.system-cli-qnty - buf_rvs-line.state-measure-cli-qnty ) > ( buf_rvs-line.state-measure-cli-qnty * v-cardif / 100 )
              then do:
                v-abs-critdif =  abs( buf_rvs-line.system-cli-qnty - buf_rvs-line.state-measure-cli-qnty ) -  ( buf_rvs-line.state-measure-cli-qnty * v-cardif / 100 ).
                if v-abs-critdif <> 0
                then do:
                  find first rvs-line-attr exclusive-lock
                        where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                        and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                        and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                        and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                        and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                        and rvs-line-attr.attr-code = "CriticalDif" no-error.
                  if available rvs-line-attr then
                  do :
                    rvs-line-attr.attr-value = ( string  (abs (  v-abs-critdif)) )  .
                  end.
                  else do :
                    create rvs-line-attr.
                    assign
                      rvs-line-attr.obj-code   = buf_rvs-line.obj-code
                      rvs-line-attr.obj-type   = buf_rvs-line.obj-type
                      rvs-line-attr.gds-code   = buf_rvs-line.gds-code
                      rvs-line-attr.pl-code    = buf_rvs-line.pl-code
                      rvs-line-attr.rvs-code   = buf_rvs-line.rvs-code
                      rvs-line-attr.attr-code  = "CriticalDif"
                      rvs-line-attr.attr-value = string ( v-abs-critdif )
                    .
                  end.
                  release rvs-line-attr no-error .
                end.
              end.
            end.
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_rvsclchd in g#lib-rvs ( input recid(buf_rvs-doc) ,
                      input no ) no-error .
            if error-status :error then
            do:
              undo tr, return error "Ошибка при пересчете документа.".
            end.
            assign
              buf_rvs-doc.status_ = 'разрешен':U
            .
          end.
          when 'разрешен':U
          then do:
            find first buf_doc-attr no-lock where buf_doc-attr.doc-code = buf_rvs-doc.rvs-code
                                              and buf_doc-attr.attr-code = "rvs-auto"
                                              and buf_doc-attr.attr-value = "Yes"
                                              no-error .
            if not available buf_doc-attr
            then do :
              for each buf_rvs-line no-lock
                  where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                  on error undo, return error return-value
              :
                if is-sug(buf_rvs-line.gds-code)
                then do :
                  if buf_rvs-line.state-temperature = ?
                  then do :
                    undo tr, return error substitute( "Не заполнено обязательное поле «Температура средняя». (СУГ &1, резервуар &2)", buf_rvs-line.gds-code, buf_rvs-line.pl-code).
                  end .
                end .
              end .
            end .
            case buf_rvs-doc.rvs-type :
              when 'смена':U
              then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_rvschtrn in g#lib-trn3
  (  input buf_rvs-doc.obj-type
  ,  input buf_rvs-doc.obj-code
  ,  input buf_rvs-doc.shift-date
  ,  input buf_rvs-doc.shift-num
  ,  input buf_rvs-doc.rvs-code
  ,  input no
  ,  input no
  , output was_found
  )        no-error
.
                if error-status :error then
                do:
                  undo tr, return error "Ошибка поиска незакрытых документов (rvschtrn): " + return-value.
                end.
                if was_found = yes then
                do:
                  undo tr, return error "Невозможно закрыть сверку. " + return-value.
                end.
                run str/chkelcnt.p
                    ( input parparentproc
                    ,input rowid(buf_rvs-doc)
                    ,input no
                    ) no-error .
                if error-status :error then
                do:
                  undo tr, return error "Невозможно закрыть сверку. " + return-value.
                end.
              end.
              when 'после_док':U
              then do:
                for each buf_rvs-line exclusive-lock
                    where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                    on error undo, return error return-value
                :
                  find first buf_doc-pl exclusive-lock
                      where buf_doc-pl.obj-type = buf_rvs-doc.obj-type
                      and buf_doc-pl.obj-code = buf_rvs-doc.obj-code
                      and buf_doc-pl.pl-code  = buf_rvs-line.pl-code
                      and buf_doc-pl.out-code = buf_rvs-doc.out-code
                      and buf_doc-pl.gds-code = buf_rvs-line.gds-code
                  no-error .
                  if available buf_doc-pl
                  then do :
                  assign
                    buf_rvs-line.system-qnty          = buf_rvs-line.system-qnty          + buf_doc-pl.fact-qnty
                    buf_rvs-line.system-cli-qnty      = buf_rvs-line.system-cli-qnty      + buf_doc-pl.cli-fact-qnty
                    buf_rvs-line.orig-system-qnty     = buf_rvs-line.orig-system-qnty     + buf_doc-pl.fact-qnty
                    buf_rvs-line.orig-system-cli-qnty = buf_rvs-line.orig-system-cli-qnty + buf_doc-pl.cli-fact-qnty
                  .
                  end .
                end.
              end.
            end case.
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_rvsclchd in g#lib-rvs ( input recid(buf_rvs-doc) ,
                      input no ) no-error .
            if error-status :error then
            do:
              undo tr, return error "Ошибка при пересчете документа.".
            end.
            assign
              buf_rvs-doc.status_ = 'факт':U
            .
            run rep/r-otkl-total.p ( input buf_rvs-doc.rvs-code
              ,input buf_rvs-doc.rvs-type
              ,input buf_rvs-doc.obj-code
              ,input buf_rvs-doc.obj-type
              ,input buf_rvs-doc.shift-date
              ,input buf_rvs-doc.shift-num
              ) .
            if error-status:error then
            do:
            end.
            for each buf_rvs-line exclusive-lock
                where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                on error undo, return error return-value
            :
              if  v-cardif > 0 and abs( buf_rvs-line.system-cli-qnty  - buf_rvs-line.state-measure-cli-qnty ) > ( buf_rvs-line.state-measure-cli-qnty * v-cardif / 100 )
              then do:
                v-abs-critdif = abs  (  buf_rvs-line.system-cli-qnty  - buf_rvs-line.state-measure-cli-qnty ) -  abs ( buf_rvs-line.state-measure-cli-qnty * v-cardif / 100 ).
                if v-abs-critdif <> 0
                then do:
                  find first rvs-line-attr exclusive-lock
                      where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                      and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                      and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                      and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                      and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                      and rvs-line-attr.attr-code = "CriticalDif" no-error.
                  if available rvs-line-attr
                  then do :
                    rvs-line-attr.attr-value = ( string  (abs (  v-abs-critdif)) )  .
                  end.
                  else do :
                    create rvs-line-attr.
                    assign
                      rvs-line-attr.obj-code   = buf_rvs-line.obj-code
                      rvs-line-attr.obj-type   = buf_rvs-line.obj-type
                      rvs-line-attr.gds-code   = buf_rvs-line.gds-code
                      rvs-line-attr.pl-code    = buf_rvs-line.pl-code
                      rvs-line-attr.rvs-code   = buf_rvs-line.rvs-code
                      rvs-line-attr.attr-code  = "CriticalDif"
                      rvs-line-attr.attr-value = string ( v-abs-critdif )
                    .
                  end.
                  release rvs-line-attr no-error .
                end.
              end.
              find first rvs-line-attr no-lock
                    where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                    and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                    and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                    and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                    and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                    and rvs-line-attr.attr-code = "hand-save" no-error.
              if available rvs-line-attr
              and logical(rvs-line-attr.attr-value) = yes
              then do :
                run placelib_write-attr  (input "place-need-RVD-rvs"
                                          ,input buf_rvs-line.obj-code
                                          ,input buf_rvs-line.obj-type
                                          ,input buf_rvs-line.pl-code
                                          ,input string(no)
                                          ,output v-ok      ) no-error.
              end .
              release rvs-line-attr no-error .
              for first rvs-line-attr no-lock
                  where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                    and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                    and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                    and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                    and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                    and rvs-line-attr.attr-code = "rvd-reason"
              :
                run trg/userlog.p (
                      input 'rvd-reasons'
                    , input rvs-line-attr.attr-value
                    , input ?
                    , input ?
                    , input ""
                    ) no-error.
                if error-status :error
                then do:
                  message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
                end.
              end .
            end.
            if buf_rvs-doc.rvs-type =  'смена':U
            then do:
              v-dif-res-count = 0 .
              v-dif-res = "" .
              for each rvs-line-attr no-lock
                  where rvs-line-attr.obj-code  = buf_rvs-doc.obj-code
                  and rvs-line-attr.obj-type  = buf_rvs-doc.obj-type
                  and rvs-line-attr.rvs-code  = buf_rvs-doc.rvs-code
                  and rvs-line-attr.attr-code = "CriticalDif"
              :
                v-dif-res-count = v-dif-res-count + 1 .
                v-dif-res = v-dif-res + (if v-dif-res <> "" then ", " else "") + string(rvs-line-attr.pl-code) .
              end.
              if v-dif-res-count = 1
              then do :
                message "В сменной сверке есть расхождения массы в резервуаре"  v-dif-res  view-as alert-box.
              end.
              if v-dif-res-count > 1
              then do :
                message "В сменной сверке есть расхождения массы в резервуарах"  v-dif-res  view-as alert-box.
              end.
            end.
          end.
          when 'факт':U
          then do:
             undo tr, return error "Невозможно закрыть документ. Документ в статусе " + 'факт':U + " .".
          end.
          otherwise
          do:
            undo tr, return error substitute( "Закрытие документа сверки. Неизвестный статус документа сверки &1", buf_rvs-doc.status_ ).
          end.
        end case.
        find first ub.user-account no-lock where ub.user-account.user-id = ibs.th.gbl.gbl-var:g#userid .
        if ub.user-account.psn-code <> 0 and ub.user-account.psn-code <> ?
        then do:
          if buf_rvs-doc.agnt = ?
          then do:
            buf_rvs-doc.agnt = ub.user-account.psn-code.
          end.
          if buf_rvs-doc.wrkr = ?
          then do:
            buf_rvs-doc.wrkr = ub.user-account.psn-code.
          end.
          buf_rvs-doc.boss = ub.user-account.psn-code.
        end.
        release ub.user-account no-error .
      end.
      when "froze":U
      then do:
        case buf_rvs-doc.status_:
          when 'разрешен':U
          then do:
            assign
              buf_rvs-doc.status_ = 'нередакт':U
            .
          end.
          otherwise
          do:
            undo tr, return error substitute( "Перевести в статус &1 возможно только из статуса &2", 'нередакт':U, 'разрешен':U).
          end.
        end case.
      end.
      when "unfroze":U
      then do:
        case buf_rvs-doc.status_:
          when 'нередакт':U
          then do:
            assign
              buf_rvs-doc.status_ = 'разрешен':U
            .
          end.
          otherwise
          do:
            undo tr, return error substitute( "Перевести в статус &1 возможно только из статуса &2", 'разрешен':U, 'нередакт':U).
          end.
        end case.
      end.
      otherwise
      do:
        undo tr, return error "Неверный статус перехода документа сверки " + paraction + " .".
      end.
    end case.
    run trg/userlog.p (
        input 'update':U
        , input 'rvs-doc':U
        , input ( buffer buf_rvs-doc :handle )
        , input ?
        , input ""
        ) no-error.
    if error-status :error
    then do:
      undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
          , chr(10)
          , vss-workfile
          , return-value
          , error-status :get-message ( 1 ) ).
    end.
end.
