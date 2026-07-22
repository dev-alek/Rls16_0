block-level on error undo, throw.
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer   no-undo .
define input parameter p-log-handle  as handle no-undo .
define output parameter p-kol-zakz as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-cyc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-cyc.p $":U .
define variable vss-description as character no-undo init "Расчет  повторяющихся заказов по всей фирме".
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
define variable to-day       as date no-undo .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-ord-code :
define input  parameter  p-type as character no-undo .
define input  parameter  v-cntxt-db-num   as integer   no-undo .
define input  parameter  v-cntxt-obj-type as character no-undo .
define input  parameter  v-cntxt-obj-code as integer   no-undo .
define input  parameter  p-i-doc    as character no-undo .
define output parameter  p-ord-doc  as character no-undo .
define variable          v-idop     as character no-undo .
  do
  on error undo, return error return-value
  :
case p-type :
    when "main-no-ver" then do:
      if  (v-cntxt-db-num <> 0) then
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
      else
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
    end.
    when "main" then do:
          do while true:
          if  (v-cntxt-db-num <> 0) then
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
          else
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
          if not can-find (ub.ord-doc where ub.ord-doc.doc-code = p-ord-doc no-lock) then leave.
          End.
    end.
    when "chip" then do:
      assign
        v-idop = p-i-doc .
      do while true :
        if index (v-idop , ".") = 0 then
          v-idop  = replace (v-idop , "-", "-1.").
        else
          v-idop  =
          substring (v-idop , 1, index (v-idop, "-")) +
          string (integer (substring (v-idop, index (v-idop, "-") + 1, index (v-idop, ".") - index (v-idop, "-") - 1)) + 1) +
          substring (v-idop, index (v-idop, ".")).
        if not can-find (ub.ord-doc where ub.ord-doc.doc-code = v-idop no-lock) then leave.
      end.
      assign
        p-ord-doc = v-idop.
    end.
end case.
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info3, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info3, return-value, chr(10), error-status :get-message (1)).
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure orddocattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.ord-doc-attr.doc-code   no-undo .
    define input  parameter p-code     like ub.ord-doc-attr.attr-code  no-undo .
    define output parameter p-value    like ub.ord-doc-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_ord-doc-attr for ub.ord-doc-attr .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run orddocattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-doc-attr no-lock
      where buf_ord-doc-attr.doc-code  = p-doc-code
        and buf_ord-doc-attr.attr-code = p-code
      no-error .
    if avail buf_ord-doc-attr then do:
      assign
        p-value =  buf_ord-doc-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure orddocattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.ord-doc-attr.attr-code  no-undo .
    define input parameter p-value    like ub.ord-doc-attr.attr-value no-undo .
    define buffer buf_ord-doc-attr for ub.ord-doc-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run orddocattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-doc-attr exclusive-lock
      where buf_ord-doc-attr.doc-code  = p-doc-code
        and buf_ord-doc-attr.attr-code = p-code
      no-error .
    if not available buf_ord-doc-attr then do:
      create buf_ord-doc-attr .
      assign
        buf_ord-doc-attr.doc-code  = p-doc-code
        buf_ord-doc-attr.attr-code = p-code
      .
    end.
    assign
      buf_ord-doc-attr.attr-value = p-value
    .
end.
end procedure.
procedure orddocattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.ord-doc-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_ord-doc-attr for ub.ord-doc-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run orddocattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-doc-attr no-lock
      where buf_ord-doc-attr.doc-code  = p-doc-code
        and buf_ord-doc-attr.attr-code = p-code
      no-error .
    if  available buf_ord-doc-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure orddocattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.ord-doc-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_ord-doc-attr for ub.ord-doc-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    define variable v-other          as character no-undo .
    run orddocattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-doc-attr exclusive-lock
      where buf_ord-doc-attr.doc-code  = p-doc-code
        and buf_ord-doc-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_ord-doc-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_ord-doc-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure orddocattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-fillin_width   as integer   no-undo .
    define output parameter p-fillin_height  as integer   no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-proc           as character no-undo .
    define output parameter p-func           as character no-undo .
    define output parameter p-sort           as integer   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'cycle-doc-code':U then do:     assign     p-label          = "Номер заказа цикличного"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Номер заказа цикличного"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-day':U then do:     assign     p-label          = "период цикличности"     p-type           = 'I':U      p-format         = ">>>>>>9"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "период цикличности"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-done':U then do:     assign     p-label          = "Заказ рассчитан"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Заказ рассчитан"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'exch-code':U then do:     assign     p-label          = "Валюта Заказа"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Валюта Заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'exch-rate':U then do:     assign     p-label          = "Валюта Заказа"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Валюта Заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'exch-scale':U then do:     assign     p-label          = "Валюта Заказа"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Валюта Заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'base-rate':U then do:     assign     p-label          = "Валюта Заказа"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Валюта Заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'base-scale':U then do:     assign     p-label          = "Валюта Заказа"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Валюта Заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-contract-code':U then do:     assign     p-label          = "договор"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "договор"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-ship-date':U then do:     assign     p-label          = "дата доставки"     p-type           = 'T':U      p-format         = "99/99/9999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "дата доставки"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-ship-time':U then do:     assign     p-label          = "время доставки"     p-type           = 'I':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "время доставки"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-date1':U then do:     assign     p-label          = "период продаж"     p-type           = 'T':U      p-format         = "99/99/9999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "период продаж"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-date2':U then do:     assign     p-label          = "период продаж"     p-type           = 'T':U      p-format         = "99/99/9999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "период продаж"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-doc-date':U then do:     assign     p-label          = "дата заказа"     p-type           = 'T':U      p-format         = "99/99/9999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "дата заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'ora-exp-seq-num':U then do:     assign     p-label          = "Номер выгрузки в Oracle Retail"     p-type           = 'I':U      p-format         = "999999999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Номер выгрузки в Oracle Retail"     p-user-can-edit  = false     p-output-display = false     p-sort           = 100     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки заказа" + " " + p-code .
      end.
    end.
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ordlineattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input  parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define output parameter p-value    like ub.ord-line-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-line-attr no-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code  = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error .
    if avail buf_ord-line-attr then do:
      assign
        p-value =  buf_ord-line-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure ordlineattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define input parameter p-value    like ub.ord-line-attr.attr-value no-undo .
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
      undo, return error return-value .
    end.
    find first buf_ord-line-attr exclusive-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code  = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error .
    if not available buf_ord-line-attr then do:
      create buf_ord-line-attr .
      assign
        buf_ord-line-attr.doc-code   = p-doc-code
        buf_ord-line-attr.gds-code   = p-gds-code
        buf_ord-line-attr.attr-code  = p-code
      .
    end.
    assign
      buf_ord-line-attr.attr-value = p-value
    .
end.
end procedure.
procedure ordlineattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-line-attr no-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error .
    if  available buf_ord-line-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure ordlineattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    define variable v-other          as character no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-line-attr exclusive-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code  = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_ord-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_ord-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure ordlineattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-fillin_width   as integer   no-undo .
    define output parameter p-fillin_height  as integer   no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-proc           as character no-undo .
    define output parameter p-func           as character no-undo .
    define output parameter p-sort           as integer   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'cycle-cli-qnty':U then do:     assign     p-label          = "Количество"     p-type           = 'D':U      p-format         = ">>>>>>>>>>>>>>>9.999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Количество"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'ord-EAN13':U then do:     assign     p-label          = "EAN в EDI"     p-type           = 'C':U      p-format         = "X(13)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "EAN в EDI"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки заказа" + " " + p-code .
      end.
    end.
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable log-file-name   as character no-undo init "ord-cycle.txt".
define variable v-error         as logical   no-undo .
define variable v-message       as character no-undo .
define variable v-contract-curr as integer   no-undo .
function string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date =  date(integer(substring(p-string, 4, 2))
                ,integer(substring(p-string, 1, 2))
                , year(date(p-string))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
define variable g#host-name    as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable g#db-remote    as logical   no-undo .
define variable v-value-character like ub.thbj-attr.property-value-character no-undo .
define variable v-value-date      like ub.thbj-attr.property-value-date no-undo .
define variable v-value-decimal   like ub.thbj-attr.property-value-decimal no-undo .
define variable v-value-logical   like ub.thbj-attr.property-value-logical no-undo .
define variable v-value-integer   like ub.thbj-attr.property-value-integer no-undo .
define variable v-type     as character no-undo .
define variable v-ordcyclg as logical   no-undo .
define variable kk         as integer   no-undo .
define temp-table tt-ord-doc no-undo like  ub.ord-doc.
define temp-table tt-ord-line no-undo like ub.ord-line.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output g#host-code
  ,output g#host-name
  )  .
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    run adm/shattri.p (
       input "get":U
      ,input ""
      ,input 0
      ,input 'ord-global':U
      ,input  "ordcyclg"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-ordcyclg
      ,output v-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then v-ordcyclg = false .
define buffer newb_ord-doc  for ub.ord-doc.
define buffer newb_ord-line for ub.ord-line.
define buffer grpb_contract-specif for ub.contract-specif  .
define buffer grpb_goods for ub.goods  .
define buffer buf_goods  for ub.goods  .
define variable i as integer no-undo init 0 .
define variable loc-ord-num1 as char no-undo  .
define variable loc-ord-num  as char no-undo  .
define variable loc-date-ship as date no-undo  .
define variable v-i-doc as character no-undo .
define variable v-make-from-specif as logical   no-undo .
 if g#auto = false then do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output to-day
  ) no-error .
end.
else do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtget in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output to-day
  ) no-error .
end.
if error-status :error then do:
v-message = substitute("&3&4 Ошибка при проверке даты на объекте: &2 &1" , error-status :get-message(1) , return-value ,p-obj-type, p-obj-code) .
       if g#auto = false then do:
          message v-message  view-as alert-box information .
       end.
       else do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-message ) no-error .
       end.
      return.
end.
for each ub.ord-doc where ub.ord-doc.cycle-day > 0
                       and ub.ord-doc.host-code = G#host-code
                       and ub.ord-doc.obj-type  = p-obj-type
                       and ub.ord-doc.obj-code  = p-obj-code
                       and (integer(to-day - ub.ord-doc.doc-date) >= ub.ord-doc.cycle-day)
                       and ub.ord-doc.order-type = 1
                       and ub.ord-doc.status_ <> 'новый':U
                         exclusive-lock   :
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   g#db-num ,
  input   ub.ord-doc.obj-type ,
  input   ub.ord-doc.obj-code ,
  input   v-i-doc ,
  output  loc-ord-num
 ) .
    if g#auto then do:
      v-message = substitute("&3&4 Создание нового заказа № &1 по заказу &2 " , loc-ord-num , ub.ord-doc.doc-code , ub.ord-doc.obj-type, ub.ord-doc.obj-code ) .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input v-message ) no-error .
    end.
    Assign
    i = i + 1
    loc-date-ship = ub.ord-doc.ship-date
    no-error.
    if i = 1 then loc-ord-num1 = loc-ord-num .
    create newb_ord-doc.
    buffer-copy ub.ord-doc except ub.ord-doc.doc-code to newb_ord-doc
           Assign newb_ord-doc.doc-code  = loc-ord-num
                  newb_ord-doc.doc-date  = to-day
                  newb_ord-doc.ship-date = if ( (loc-date-ship + ub.ord-doc.cycle-day) < to-day ) then  to-day
                                       else (loc-date-ship + ub.ord-doc.cycle-day)
                  newb_ord-doc.status_  = 'новый':U
                  newb_ord-doc.ord-int1 = 0
                  newb_ord-doc.ord-int2 = 0
                  newb_ord-doc.fact-date = ?
                  newb_ord-doc.fact-order = 0
                  newb_ord-doc.date-sale-1 = ub.ord-doc.date-sale-1 + ub.ord-doc.cycle-day
                  newb_ord-doc.date-sale-2 = ub.ord-doc.date-sale-2 + ub.ord-doc.cycle-day
                  newb_ord-doc.PS         =  substitute("по &1 " , ub.ord-doc.doc-code  )
           .
           kk = 0.
           run current-contract (input ub.ord-doc.doc-code , output v-contract-curr ) .
           newb_ord-doc.contract-code = v-contract-curr.
           for each ub.ord-line no-lock where
                    ub.ord-line.doc-code  = ub.ord-doc.doc-code ,
              first buf_goods no-lock where
                    buf_goods.gds-code = ub.ord-line.gds-code
                    by ub.ord-line.line-num :
              if v-ordcyclg then do:
                  if  v-contract-curr <> 0 and
                      Can-Find-Spec  ( ub.ord-doc.host-code,
                                       v-contract-curr,
                                       ub.ord-line.gds-code)
                  then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  ub.ord-doc.host-code,
    INPUT  v-contract-curr,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = ub.ord-doc.host-code
      i-gl-Contract-Code  = v-contract-curr
      .
END.
FOR EACH
    grpb_contract-specif
     NO-LOCK
     WHERE
         grpb_contract-specif.Host-code    = i-gl-Host-Code
     AND grpb_contract-specif.Contract-num = i-gl-Contract-Code
                       ,
                               first grpb_goods no-lock where
                                     grpb_goods.gds-code = grpb_contract-specif.gds-code and
                                     grpb_goods.grp-code  = buf_goods.grp-code :
                                 find first newb_ord-line no-lock where
                                            newb_ord-line.doc-code = loc-ord-num and
                                            newb_ord-line.gds-code =  grpb_contract-specif.gds-code no-error .
                                        if not available  newb_ord-line then do:
                                            run ver-izt (
                                              input newb_ord-doc.doc-type ,
                                              input grpb_goods.gds-code ,
                                              input newb_ord-doc.obj-type ,
                                              input newb_ord-doc.obj-code ,
                                              output v-error) .
                                            if not v-error then do:
                                            kk = kk + 1 .
                                            create newb_ord-line.
                                            assign
                                              newb_ord-line.doc-code      = loc-ord-num
                                              newb_ord-line.artic         = grpb_goods.artic
                                              newb_ord-line.prod-type     = grpb_goods.prod-type
                                              newb_ord-line.prod-code     = grpb_goods.prod-code
                                              newb_ord-line.gds-code      = grpb_goods.gds-code
                                              newb_ord-line.cli-qnty      =  ?
                                              newb_ord-line.price-cli     = grpb_contract-specif.price-cli
                                              newb_ord-line.vat-pc        = grpb_contract-specif.vat-pc
                                              newb_ord-line.cli-base-rate = grpb_contract-specif.cli-base-rate
                                              newb_ord-line.unit-cli      = grpb_contract-specif.unit-base
                                              newb_ord-line.price-rubl    = grpb_contract-specif.price-cli * ub.ord-doc.exch-rate / ub.ord-doc.exch-scale / newb_ord-line.cli-base-rate
                                              newb_ord-line.price-base    = newb_ord-line.price-rubl / ub.ord-doc.base-rate * ub.ord-doc.base-scale
                                              newb_ord-line.qnty          = newb_ord-line.cli-qnty * newb_ord-line.cli-base-rate
                                              newb_ord-line.sum-rubl      = newb_ord-line.qnty * newb_ord-line.price-rubl
                                              newb_ord-line.sum-base      = newb_ord-line.qnty * newb_ord-line.price-base
                                              newb_ord-line.sum-cli       = newb_ord-line.cli-qnty * newb_ord-line.price-cli
                                              newb_ord-line.line-num      = kk
                                           .
                                            find first ub.ext-artic no-lock  where ub.ext-artic.cli-type = ub.ord-doc.cli-type
                                                      and ub.ext-artic.cli-code = ub.ord-doc.cli-code
                                                      and ub.ext-artic.gds-code = grpb_goods.gds-code
                                                      and ub.ext-artic.status_  = 'тек':U
                                                      no-error .
                                            if available ub.ext-artic then do:
                                              newb_ord-line.cli-art = ub.ext-artic.ext-artic.
                                            end.
                                            else do:
                                              newb_ord-line.cli-art = ''.
                                            end.
                                        end.
                                        end.
                      end.
                  end.
                  else do:
                  end.
              end.
              else do:
                run ver-izt (ub.ord-doc.doc-type , ub.ord-line.gds-code ,ub.ord-doc.obj-type , ub.ord-doc.obj-code , output v-error) .
                if not v-error then do:
                  create newb_ord-line.
                  buffer-copy ub.ord-line except ub.ord-line.doc-code to newb_ord-line
                  assign
                    newb_ord-line.doc-code = loc-ord-num
                    .
                end.
              end.
           end.
    assign ub.ord-doc.order-type = 0.
end.
define variable flag-all as logical   no-undo .
for each ub.ord-doc exclusive-lock where
      ub.ord-doc.host-code = G#host-code
  and ub.ord-doc.obj-type  = p-obj-type
  and ub.ord-doc.obj-code  = p-obj-code
  and ub.ord-doc.order-type = 4
  and ub.ord-doc.status_ <> 'новый':U :
  run make-tt-doc (buffer ub.ord-doc ).
    flag-all = true .
    for each tt-ord-doc :
        if not ( integer(to-day - tt-ord-doc.doc-date) >= tt-ord-doc.cycle-day ) then do:
           flag-all = false .
           next.
        end.
        run orddocattr-write (
              input ub.ord-doc.doc-code + chr(4) + tt-ord-doc.doc-code
            , input 'cycle-done':U
            , input "yes") no-error .
            if error-status :error then do:
            if g#auto = false then
                message
                  vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value skip
                  "Ошибка из orddocattr-write"
                  view-as alert-box error
                .
           end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   g#db-num ,
  input   tt-ord-doc.obj-type ,
  input   tt-ord-doc.obj-code ,
  input   v-i-doc ,
  output  loc-ord-num
 ) .
    if g#auto then do:
      v-message = substitute("&3&4 Создание нового заказа № &1 по совокупному заказу № &2 (№ &5) " , loc-ord-num , ub.ord-doc.doc-code , tt-ord-doc.obj-type, tt-ord-doc.obj-code , tt-ord-doc.doc-code) .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input v-message ) no-error .
    end.
    Assign
    i = i + 1
    loc-date-ship = tt-ord-doc.ship-date
    no-error.
    if i = 1 then loc-ord-num1 = loc-ord-num .
    create newb_ord-doc.
    buffer-copy tt-ord-doc except tt-ord-doc.doc-code to newb_ord-doc
           Assign newb_ord-doc.doc-code   = loc-ord-num
                  newb_ord-doc.order-type = 1
                  newb_ord-doc.doc-date   = to-day
                  newb_ord-doc.ship-date  = if ( (loc-date-ship + tt-ord-doc.cycle-day) < to-day ) then  to-day
                                       else (loc-date-ship + tt-ord-doc.cycle-day)
                  newb_ord-doc.status_  = 'новый':U
                  newb_ord-doc.fact-date = ?
                  newb_ord-doc.fact-order = 0
                  newb_ord-doc.ord-int1 = 0
                  newb_ord-doc.ord-int2 = 0
                  newb_ord-doc.date-sale-1 = tt-ord-doc.date-sale-1  + tt-ord-doc.cycle-day
                  newb_ord-doc.date-sale-2 = tt-ord-doc.date-sale-2  + tt-ord-doc.cycle-day
                  newb_ord-doc.PS         =  substitute("по &1 " ,  tt-ord-doc.doc-code   )
           .
           kk = 0.
           run current-contract (input tt-ord-doc.doc-code , output v-contract-curr ) .
           newb_ord-doc.contract-code = v-contract-curr.
           for each ub.ord-line no-lock where
                    ub.ord-line.doc-code = ub.ord-doc.doc-code ,
              first tt-ord-line where
                    tt-ord-line.doc-code = tt-ord-doc.doc-code and
                    tt-ord-line.gds-code = ub.ord-line.gds-code ,
              first buf_goods no-lock where
                    buf_goods.gds-code = ub.ord-line.gds-code
                    :
              if v-ordcyclg then do:
                  if  v-contract-curr <> 0 and
                      Can-Find-Spec  ( tt-ord-doc.host-code,
                                       v-contract-curr,
                                       tt-ord-line.gds-code)
                  then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  tt-ord-doc.host-code,
    INPUT  v-contract-curr,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = tt-ord-doc.host-code
      i-gl-Contract-Code  = v-contract-curr
      .
END.
FOR EACH
    grpb_contract-specif
     NO-LOCK
     WHERE
         grpb_contract-specif.Host-code    = i-gl-Host-Code
     AND grpb_contract-specif.Contract-num = i-gl-Contract-Code
                       ,
                               first grpb_goods no-lock where
                                     grpb_goods.gds-code = grpb_contract-specif.gds-code and
                                     grpb_goods.grp-code  = buf_goods.grp-code :
                                 find first newb_ord-line no-lock where
                                            newb_ord-line.doc-code = loc-ord-num and
                                            newb_ord-line.gds-code =  grpb_contract-specif.gds-code no-error .
                                        if not available  newb_ord-line then do:
                                            kk = kk + 1 .
                                            create newb_ord-line.
                                            assign
                                              newb_ord-line.doc-code      = loc-ord-num
                                              newb_ord-line.artic         = grpb_goods.artic
                                              newb_ord-line.prod-type     = grpb_goods.prod-type
                                              newb_ord-line.prod-code     = grpb_goods.prod-code
                                              newb_ord-line.gds-code      = grpb_goods.gds-code
                                              newb_ord-line.cli-qnty      =  ?
                                              newb_ord-line.price-cli     = grpb_contract-specif.price-cli
                                              newb_ord-line.vat-pc        = grpb_contract-specif.vat-pc
                                              newb_ord-line.cli-base-rate = grpb_contract-specif.cli-base-rate
                                              newb_ord-line.unit-cli      = grpb_contract-specif.unit-base
                                              newb_ord-line.price-rubl    = grpb_contract-specif.price-cli * tt-ord-doc.exch-rate / tt-ord-doc.exch-scale / newb_ord-line.cli-base-rate
                                              newb_ord-line.price-base    = newb_ord-line.price-rubl / tt-ord-doc.base-rate * tt-ord-doc.base-scale
                                              newb_ord-line.qnty          = newb_ord-line.cli-qnty * newb_ord-line.cli-base-rate
                                              newb_ord-line.sum-rubl      = newb_ord-line.qnty * newb_ord-line.price-rubl
                                              newb_ord-line.sum-base      = newb_ord-line.qnty * newb_ord-line.price-base
                                              newb_ord-line.sum-cli       = newb_ord-line.cli-qnty * newb_ord-line.price-cli
                                              newb_ord-line.line-num      = kk
                                           .
                                            find first ub.ext-artic no-lock  where
                                                          ub.ext-artic.cli-type = tt-ord-doc.cli-type
                                                      and ub.ext-artic.cli-code = tt-ord-doc.cli-code
                                                      and ub.ext-artic.gds-code = grpb_goods.gds-code
                                                      and ub.ext-artic.status_  = 'тек':U
                                                      no-error .
                                            if available ub.ext-artic then do:
                                              newb_ord-line.cli-art = ub.ext-artic.ext-artic.
                                            end.
                                            else do:
                                              newb_ord-line.cli-art = ''.
                                            end.
                                        end.
                      end.
                  end.
                  else do:
                  end.
              end.
              else do:
                  create newb_ord-line.
                  buffer-copy tt-ord-line except tt-ord-line.doc-code to newb_ord-line
                  assign
                    newb_ord-line.doc-code = loc-ord-num
                    .
              end.
           end.
  end.
  flag-all = true .
  for each tt-ord-doc :
      if not ( integer(to-day - tt-ord-doc.doc-date) >= tt-ord-doc.cycle-day ) then do:
          flag-all = false .
          next.
      end.
  end.
  if flag-all = true then
     assign
       ub.ord-doc.order-type = 0
       .
end.
p-kol-zakz = i .
if i > 0 then  do:
       v-message = substitute("&4&5 Добавлено &1 ЗАКАЗОВ. Номера С &2 ПО &3 ." , i , loc-ord-num1 , loc-ord-num , p-obj-type, p-obj-code) .
       if g#auto = false then do:
          message v-message  view-as alert-box information .
       end.
       else do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-message ) no-error .
       end.
end.
else  do:
       if can-find (first ub.ord-doc  where ub.ord-doc.cycle-day > 0
                       and ub.ord-doc.doc-date = to-day
                       and ub.ord-doc.obj-type = p-obj-type
                       and ub.ord-doc.obj-code = p-obj-code
                       and ub.ord-doc.host-code = g#host-code
                       and ub.ord-doc.order-type = 1  ) then do:
            v-message = substitute("&2&3 На сегодня повторяющиеся заказы уже рассчитаны !  &1" , to-day , p-obj-type, p-obj-code) .
            if g#auto = false then do:
              message v-message  view-as alert-box  information.
            end.
            else do:
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input v-message ) no-error .
            end.
        end.
        else do:
          v-message = substitute("&2&3 Повторяющиеся заказы не обнаружены !  &1" , to-day , p-obj-type, p-obj-code ) .
          if g#auto = false then do:
            message v-message view-as alert-box  information.
          end.
            else do:
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input v-message ) no-error .
            end.
        end.
end.
procedure clear-tt-doc :
  do
  on error undo, return error return-value
  :
   for each tt-ord-doc:
     delete tt-ord-doc.
   end.
   for each tt-ord-line:
     delete tt-ord-line.
   end.
  end.
end procedure.
procedure make-tt-doc :
define parameter buffer  buf_ord-doc  for ub.ord-doc .
define variable v-type as character no-undo .
define buffer buf_ord-doc-attr   for ub.ord-doc-attr  .
define buffer buf_ord-line-attr  for ub.ord-line-attr  .
define buffer buf_ord-line       for ub.ord-line  .
define variable v-new-code as character no-undo .
define variable v-date as character no-undo .
define variable v-ok-done as character no-undo .
  do
  on error undo, return error return-value
  :
  run clear-tt-doc.
  for each buf_ord-doc-attr no-lock where
           buf_ord-doc-attr.doc-code   begins  string( buf_ord-doc.doc-code + chr(4) ) and
           buf_ord-doc-attr.attr-code = 'cycle-doc-code':U :
      v-new-code = buf_ord-doc-attr.doc-code .
      run orddocattr-value (
          input  v-new-code,
          input  'cycle-done':U ,
          output v-ok-done,
          output v-type ) .
      if v-ok-done = "yes" then next .
      create tt-ord-doc.
      buffer-copy buf_ord-doc to tt-ord-doc
      assign
        tt-ord-doc.doc-code = buf_ord-doc-attr.attr-value
        tt-ord-doc.order-type = 1
        .
      run orddocattr-value (
          input  v-new-code,
          input  'cycle-day':U ,
          output tt-ord-doc.cycle-day,
          output v-type ) .
      run orddocattr-value (
          input  v-new-code,
          input  'cycle-contract-code':U,
          output tt-ord-doc.contract-code,
          output v-type ) .
      run orddocattr-value (
          input  v-new-code,
          input  'cycle-ship-date':U ,
          output v-date,
          output v-type ) .
      tt-ord-doc.ship-date =string-to-date(v-date) .
      run orddocattr-value (
          input  v-new-code,
          input  'cycle-ship-time':U ,
          output tt-ord-doc.ship-time,
          output v-type ) .
      run orddocattr-value (
          input  v-new-code,
          input  'cycle-date1':U  ,
          output v-date ,
          output v-type ) .
          tt-ord-doc.date-sale-1 = string-to-date(v-date) .
      run orddocattr-value (
          input  v-new-code,
          input  'cycle-date2':U ,
          output v-date,
          output v-type ) .
          tt-ord-doc.date-sale-2 = string-to-date(v-date).
      run orddocattr-value (
          input  v-new-code,
          input  'cycle-doc-date':U  ,
          output  v-date,
          output v-type ) .
          tt-ord-doc.doc-date =string-to-date(v-date) .
          for each buf_ord-line-attr no-lock where
                   buf_ord-line-attr.doc-code = v-new-code and
                   buf_ord-line-attr.attr-code = 'cycle-cli-qnty':U ,
             first buf_ord-line no-lock where
                   buf_ord-line.doc-code = buf_ord-doc.doc-code  and
                   buf_ord-line.gds-code = buf_ord-line-attr.gds-code
                   :
              create  tt-ord-line .
              buffer-copy buf_ord-line to tt-ord-line
              assign
                  tt-ord-line.doc-code = tt-ord-doc.doc-code
                  tt-ord-line.cli-qnty = decimal (buf_ord-line-attr.attr-value)
                  tt-ord-line.qnty     = tt-ord-line.cli-qnty * tt-ord-line.cli-base-rate
                  tt-ord-line.sum-rubl = tt-ord-line.qnty * tt-ord-line.price-rubl
                  tt-ord-line.sum-base = tt-ord-line.qnty * tt-ord-line.price-base
                  tt-ord-line.sum-cli  = tt-ord-line.cli-qnty * tt-ord-line.price-cli
              .
          end.
  end.
  end.
end procedure.
procedure ver-izt :
define input  parameter p-event-code as character no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-error as logical   no-undo .
define variable p-Ok as logical   no-undo .
define variable p-mess as character no-undo .
  do
  on error undo, return error return-value
  :
  p-error = false .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  p-event-code
  ,input  p-gds-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  no
  ,output p-Ok
  ,output p-mess
  ) no-error.
     if p-mess <> "" then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input p-mess ) no-error .
     end.
    if p-ok = false then p-error = true  .
  end.
end procedure.
procedure current-contract :
define input  parameter p-ord-doc       as character no-undo .
define output parameter p-contract-code as integer   no-undo .
define buffer buf_ord-doc for ub.ord-doc  .
define buffer buf-contract for ub.contract  .
  do
  on error undo, return error return-value
  :
  p-contract-code = 0.
  find first buf_ord-doc no-lock where
              buf_ord-doc.doc-code = p-ord-doc no-error .
  find first buf-contract no-lock where
             buf-contract.host-code = buf_ord-doc.host-code    and
             buf-contract.cli-type  = buf_ord-doc.cli-type     and
             buf-contract.cli-code  = buf_ord-doc.cli-code     and
             buf-contract.status_   = 'тек':U         and
             buf-contract.contract-date-beg <= buf_ord-doc.ship-date and
             ( buf-contract.contract-date-end >= buf_ord-doc.ship-date  or
               buf-contract.contract-date-end = date('') )
             no-error .
      if not available buf-contract then do:
          find first buf-contract no-lock where
                     buf-contract.host-code = buf_ord-doc.host-code    and
                     buf-contract.cli-type  = buf_ord-doc.cli-type     and
                     buf-contract.cli-code  = buf_ord-doc.cli-code     and
                     buf-contract.status_   = 'тек':U         no-error .
      end.
      if available buf-contract then do:
         p-contract-code = buf-contract.contract-code.
      end.
  end.
end procedure.
